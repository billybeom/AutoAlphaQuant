// 주문 원장 — core `OrderLedger` 포트의 SQLite 구현(설계 13 §8 R33 D12 · R36 W1~W9 · 04 §3-1 · §1 · 02 §2-4 · §2-6 · §3-2).
//
// 🔴 6.5 COMMIT — [insertIntent] 는 **자동 커밋 한 문장**이다. 돌아오면 그 행은 커밋됐고 별도 커넥션에서 보인다(AC-S04).
//    연결에 열린 트랜잭션이 있으면(누가 BEGIN 해 두었으면) INSERT 하지 않고 StateError — 그 INSERT 는 브로커 호출 뒤
//    롤백될 수 있어 NR-1 이 무력해진다(04 §3-1 v1.5).
// 🔴 상태 전이는 `WHERE status = 앞 상태` 로만 바꾼다 — 바뀐 행이 1 이 아니면 StateError(순서를 건너뛴 기록을 받지 않는다).
// 🔴 브로커 거절은 `error_message` 접두 `BROKER: ` 로 1~5단계 거부와 가른다(orders_today 에 센다 — R33 D22 · R36 W5).
// 🔴 SAF-408 · 410 판정은 SQL 을 직접 돌려 `trading_block` 플래그를 **자동** 설정 · 해제하고 그 결과를 돌려준다 —
//    사람이 해제하는 경로는 없다(`cleared_by = 'auto:SAF-40x'` · 04 §1 v2.11 · v2.15 SF-01 · 파일럿4 `safety/gates.py`).
// 🆕 E10e1 — 체결 원장(`FillLedger` · 설계 13 §8 R38 Z2~Z6 · Z9): 실행 행 · 브로커 주문 누적 · 포지션 · 의도 상태를 한 트랜잭션.
//    🔴 누적 정본 = `broker_orders.raw_response` 에 마지막으로 본 원주문 행의 누적 칸(실행 행 단가는 REAL 이라 Σ 로 되살리지 못한다).
//    🔴 매도가 보유를 넘으면 StateError(원장이 틀렸다 — 쓰지 않는다) · 0 이면 포지션 행을 지운다.
// 🆕 E10e2 — 이월 원장(`CarryLedger`) · 해소 원장(`UnknownLedger`) · 설계 13 §8 R39 T2 · T4 · T9.
//    🔴 논리 id 비교는 `substr(decision_id, 1, n) = '{논리 id}@'` — `LIKE` 를 쓰지 않는다(`_` · `%` 가 와일드카드).
//    🔴 UNKNOWN 해소 거절(`UNKNOWN_NOT_FOUND: `)도 7단계를 지났다 — orders_today · 분할 계획 합에 센다.
// 🆕 E10f — 대사 원장(`ReconLedger` · 설계 13 §8 R40 A2 · A7 · A8): `reconciliation_log` + `ledger_diff`(CANON_BROKER) +
//    `trading_block(RECON_MISMATCH)` 를 한 트랜잭션. 🔴 대사는 플래그를 세우기만 한다(풀기 = `clearReconBlock` 뿐 ·
//    저널 `RECON_CLEAR` 확인은 core `clearRecon`). 🔴 positions · executions 를 고치지 않는다(자동 수정 금지).

import 'dart:convert' show jsonEncode;

import 'package:core_engine/core_engine.dart'
    show
        BlockBundles,
        BreakerLevel,
        DailyFillRow,
        ExchangeCalendar,
        ExpiredIntent,
        FillApplication,
        FillDelta,
        FillVerdict,
        IntentRow,
        IntentStatus,
        LedgerHolding,
        LedgerOrderFill,
        OpenIntent,
        OrderPathLedger,
        ReconClearance,
        ReconDiff,
        ReconRecord,
        RecordedFill,
        SafetyIncident,
        SplitProgress,
        UnknownIntent,
        averageFillPrice,
        averagePriceAfterBuy,
        demoteToDouble,
        diffSeverityFor,
        kUnknownNotFoundPrefix,
        ledgerDiffIdOf,
        logicalIdOf,
        parseRecordedCancelJson,
        parseRecordedFillJson,
        recordedFillJson,
        writableOriginCodesFor;
import 'package:core_engine/core_engine.dart' as core show killSwitchActive;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        DiffStatus,
        ExecPolicy,
        FlagIds,
        LedgerPair,
        OrderSide,
        RunMode,
        TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'kill_switch_store.dart' show readKillSwitchRecord;

/// 브로커 거절의 `error_message` 접두(R36 W5).
const String kBrokerRejectedPrefix = 'BROKER: ';

/// orders_today 가 세는 상태 — 7단계(SUBMITTING)에 들어선 것(R33 D22).
const List<IntentStatus> _submittedOrLater = <IntentStatus>[
  IntentStatus.submitting,
  IntentStatus.submitted,
  IntentStatus.filled,
  IntentStatus.partial,
  IntentStatus.cancelled,
  IntentStatus.unknown,
  IntentStatus.expired,
];

/// SAF-410 유예 — 월말 뒤 이 거래일 수까지는 판정 기록이 없어도 막지 않는다(04 §1).
const int kTierBGraceSessions = 3;

/// 로컬 원장 파일 하나의 주문 원장(포트 구현).
final class SqliteOrderLedger implements OrderPathLedger {
  /// 원장을 만든다. [kr] = SAF-410 의 영업일 달력(동결 XKRX · 범위 밖이면 StateError).
  SqliteOrderLedger(
    this._db, {
    required this.mode,
    required this.clock,
    required this.kr,
  });

  final Database _db;

  /// 이 파일의 실행 모드(`order_intents.mode` — 배치 A CHECK 가 잘못 연 파일을 막는다).
  final RunMode mode;

  /// 엔진 시각(`created_at` · `updated_at` · 플래그 시각).
  final Clock clock;

  /// KR 거래소 달력.
  final ExchangeCalendar kr;

  String _now() => clock.nowUtc().toUtc().toIso8601String();

  bool _exists(String sql, [List<Object?> args = const <Object?>[]]) =>
      _db.select(sql, args).isNotEmpty;

  @override
  Future<bool> killSwitchActive() async =>
      // 🆕 E13b — SPEC v2.40 04 §3-6 판정식(48h = 체크리스트 확인부터 · 손으로 고친 행은 못 푼다 · 설계 13 §8 R57 B6).
      core.killSwitchActive(readKillSwitchRecord(_db));

  @override
  Future<BreakerLevel> breakerLevel(TradeDate executionDate) async {
    // 🆕 E13d1 — 집행일 이하 마지막 스냅숏(없으면 NORMAL · 모르는 코드 = 던짐 → 원장 불가 · R60 B1).
    final ResultSet rs = _db.select(
      'SELECT breaker_level FROM equity_snapshot WHERE trade_date <= ? '
      'ORDER BY trade_date DESC LIMIT 1',
      <Object?>[executionDate.yyyyMmDd],
    );
    return rs.isEmpty
        ? BreakerLevel.normal
        : BreakerLevel.fromCode(rs.first['breaker_level'] as String);
  }

  @override
  Future<Set<String>> activeBlockFlags() async {
    // 04 §3-1 ① 판정 SQL — 묶음 밖(표식 · LEDGER_FIX)은 읽지 않는다.
    final List<String> bundle = <String>[
      ...BlockBundles.allOrders,
      ...BlockBundles.newBuys,
      ...BlockBundles.entryAdvice,
    ]..sort();
    final String marks = List<String>.filled(bundle.length, '?').join(', ');
    return <String>{
      for (final Row r in _db.select(
        'SELECT flag_id FROM trading_block '
        'WHERE cleared_at IS NULL AND flag_id IN ($marks)',
        bundle,
      ))
        r['flag_id'] as String,
    };
  }

  @override
  Future<bool> hasUnresolvedUnknown(
    String market,
    String symbol,
    String strategyId,
  ) async => _exists(
    "SELECT 1 FROM order_intents WHERE status = 'UNKNOWN' "
    'AND market = ? AND symbol = ? AND strategy_id = ? LIMIT 1',
    <Object?>[market, symbol, strategyId],
  );

  @override
  Future<bool> strategyRegistered(String strategyId) async => _exists(
    'SELECT 1 FROM strategy_state_current WHERE strategy_id = ?',
    <Object?>[strategyId],
  );

  /// 7단계를 지난 의도의 조건(R33 D22 · R39 T9) — orders_today · 분할 계획 합이 같이 쓴다. 인자 = [_sentArgs].
  static String _sentWhere(String a) {
    final String marks = List<String>.filled(
      _submittedOrLater.length,
      '?',
    ).join(', ');
    return '($a.status IN ($marks) OR '
        "($a.status = 'REJECTED' AND (substr($a.error_message, 1, ?) = ? "
        'OR substr($a.error_message, 1, ?) = ?)))';
  }

  static List<Object?> get _sentArgs => <Object?>[
    for (final IntentStatus s in _submittedOrLater) s.code,
    kBrokerRejectedPrefix.length,
    kBrokerRejectedPrefix,
    kUnknownNotFoundPrefix.length,
    kUnknownNotFoundPrefix,
  ];

  @override
  Future<int> ordersToday(TradeDate tradeDate) async =>
      _db.select(
            'SELECT COUNT(*) AS n FROM order_intents i WHERE i.trade_date = ? AND '
            '${_sentWhere('i')}',
            <Object?>[tradeDate.yyyyMmDd, ..._sentArgs],
          ).single['n']
          as int;

  @override
  Future<bool> journalMissing() async {
    // 04 §1 SAF-408 판정 SQL 그대로.
    final bool missing = _exists(
      'SELECT 1 FROM decision_journal WHERE is_deviation = 1 AND '
      '(rationale_before IS NULL OR expected_outcome IS NULL OR rule_cited IS NULL) LIMIT 1',
    );
    _refreshFlag(
      FlagIds.journalMissing,
      blocked: missing,
      reason: '이탈 저널 사전 필드 미작성 (SAF-408)',
      clearedBy: 'auto:SAF-408',
    );
    return missing;
  }

  @override
  Future<bool> tierBUnjudged(TradeDate tradeDate) async {
    final String day = tradeDate.yyyyMmDd;
    final int y = int.parse(day.substring(0, 4));
    final int m = int.parse(day.substring(5, 7));
    final String month = m == 1
        ? '${y - 1}-12'
        : '$y-${(m - 1).toString().padLeft(2, '0')}';
    final TradeDate monthStart = TradeDate('${day.substring(0, 8)}01');
    // 월말 다음 날 ~ 집행일(포함)의 거래일 수 — 동결 XKRX(발주자 결정 5-b · 범위 밖 = StateError).
    int sessions = kr.isSession(tradeDate) ? 1 : 0;
    TradeDate d = tradeDate;
    while (true) {
      final TradeDate prev = kr.nthSessionBefore(d, 1);
      if (prev.yyyyMmDd.compareTo(monthStart.yyyyMmDd) < 0) break;
      sessions++;
      d = prev;
    }
    final bool flagged = _exists(
      'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[FlagIds.tierBUnjudged],
    );
    if (sessions <= kTierBGraceSessions) return flagged;
    final List<String> unjudged = <String>[
      for (final Row r in _db.select(
        'SELECT s.strategy_id FROM strategy_state_current s '
        'WHERE NOT EXISTS (SELECT 1 FROM tier_b_judgement j '
        'WHERE j.judged_month = ? AND j.strategy_id = s.strategy_id) '
        'ORDER BY s.strategy_id',
        <Object?>[month],
      ))
        r['strategy_id'] as String,
    ];
    _refreshFlag(
      FlagIds.tierBUnjudged,
      blocked: unjudged.isNotEmpty,
      reason: '$month 계층 B 판정 누락: ${unjudged.join(',')} (SAF-410)',
      clearedBy: 'auto:SAF-410',
    );
    return unjudged.isNotEmpty;
  }

  /// 판정 결과로 플래그를 세우거나(없으면) 자동 해제한다(있으면).
  void _refreshFlag(
    String flag, {
    required bool blocked,
    required String reason,
    required String clearedBy,
  }) {
    final bool active = _exists(
      'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[flag],
    );
    if (blocked && !active) {
      // PK = flag_id — 해제된 옛 행은 새 설정으로 덮는다.
      _db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?) '
        'ON CONFLICT(flag_id) DO UPDATE SET set_at = excluded.set_at, '
        'reason = excluded.reason, origin_code = NULL, cleared_at = NULL, '
        'cleared_by = NULL, decision_id = NULL',
        <Object?>[flag, _now(), reason],
      );
    } else if (!blocked && active) {
      _db.execute(
        'UPDATE trading_block SET cleared_at = ?, cleared_by = ? '
        'WHERE flag_id = ? AND cleared_at IS NULL',
        <Object?>[_now(), clearedBy, flag],
      );
    }
  }

  @override
  Future<bool> insertIntent(IntentRow row) async {
    if (!_db.autocommit) {
      // 🔴 열린 트랜잭션 안의 INSERT 는 커밋을 보장하지 못한다(6.5).
      throw StateError('열린 트랜잭션 안에서 의도를 예약하지 않는다(04 §3-1 6.5)');
    }
    if (!const <IntentStatus>{
      IntentStatus.reserved,
      IntentStatus.rejected,
      IntentStatus.skipped,
    }.contains(row.status)) {
      throw StateError(
        'INSERT 상태는 RESERVED · REJECTED · SKIPPED 뿐이다: ${row.status.code}',
      );
    }
    final String now = _now();
    try {
      _db.execute(
        'INSERT INTO order_intents (intent_id, idempotency_key, created_at, trade_date, market, '
        'account, strategy_id, decision_id, symbol, side, order_type, quantity, limit_price, '
        'status, config_hash, dry_run, error_message, updated_at, mode, operating_mode) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          row.intentId,
          row.idempotencyKey,
          now,
          row.tradeDate.yyyyMmDd,
          row.market,
          row.account,
          row.strategyId,
          row.decisionId,
          row.symbol,
          row.side.wire,
          row.orderType,
          row.quantity,
          switch (row.limitPrice) {
            final p? => demoteToDouble(p),
            null => null,
          },
          row.status.code,
          row.configHash,
          row.execPolicy == ExecPolicy.dryRun ? 1 : 0,
          row.errorMessage,
          now,
          mode.wire,
          row.operatingMode.wire,
        ],
      );
      return true;
    } on SqliteException catch (e) {
      // NR-6 — UNIQUE · PK 충돌만 «이미 처리됨»이다. 그 밖(CHECK · FK · 디스크)은 그대로 던진다.
      if (e.extendedResultCode == SqlExtendedError.SQLITE_CONSTRAINT_UNIQUE ||
          e.extendedResultCode ==
              SqlExtendedError.SQLITE_CONSTRAINT_PRIMARYKEY) {
        return false;
      }
      rethrow;
    }
  }

  /// [from] 상태인 의도를 [to] 로 바꾼다 — 바뀐 행이 1 이 아니면 StateError.
  void _move(
    String intentId,
    IntentStatus from,
    IntentStatus to, {
    String? message,
  }) {
    _db.execute(
      'UPDATE order_intents SET status = ?, updated_at = ?, error_message = ? '
      'WHERE intent_id = ? AND status = ?',
      <Object?>[to.code, _now(), message, intentId, from.code],
    );
    if (_db.updatedRows != 1) {
      throw StateError(
        '$intentId: ${from.code} → ${to.code} 전이를 할 수 없다(지금 상태가 다르거나 없는 의도)',
      );
    }
  }

  @override
  Future<void> markSubmitting(String intentId) async =>
      _move(intentId, IntentStatus.reserved, IntentStatus.submitting);

  @override
  Future<void> markSubmitted(String intentId, String brokerOrderNo) async {
    _db.execute('BEGIN IMMEDIATE');
    try {
      final ResultSet rows = _db.select(
        'SELECT quantity, updated_at FROM order_intents WHERE intent_id = ? AND status = ?',
        <Object?>[intentId, IntentStatus.submitting.code],
      );
      if (rows.isEmpty) {
        throw StateError('$intentId: SUBMITTING 이 아니다');
      }
      // submitted_at = SUBMITTING 기록 시각(= 브로커 호출 직전 · 02 §3-2 · R36 W6).
      _db.execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, '
        'filled_qty, remaining_qty) VALUES (?, ?, ?, ?, 0, ?)',
        <Object?>[
          brokerOrderNo,
          intentId,
          rows.single['updated_at'],
          IntentStatus.submitted.code,
          rows.single['quantity'],
        ],
      );
      _move(intentId, IntentStatus.submitting, IntentStatus.submitted);
      _db.execute('COMMIT');
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<void> markBrokerRejected(String intentId, String message) async =>
      _move(
        intentId,
        IntentStatus.submitting,
        IntentStatus.rejected,
        message: '$kBrokerRejectedPrefix$message',
      );

  @override
  Future<void> markUnknown(String intentId, String message) async => _move(
    intentId,
    IntentStatus.submitting,
    IntentStatus.unknown,
    message: message,
  );

  @override
  Future<void> markSkipped(String intentId, String message) async => _move(
    intentId,
    IntentStatus.reserved,
    IntentStatus.skipped,
    message: message,
  );
  // ── 🆕 E10e1 체결 원장(FillLedger · R38) ─────────────────────────────────

  static const List<String> _openCodes = <String>['SUBMITTED', 'PARTIAL'];

  @override
  Future<List<OpenIntent>> openIntents(TradeDate tradeDate) async {
    final List<OpenIntent> out = <OpenIntent>[];
    final Set<String> seen = <String>{};
    for (final Row r in _db.select(
      'SELECT i.intent_id, b.broker_order_no, i.trade_date, i.market, i.account, i.strategy_id, '
      'i.symbol, i.side, i.quantity, i.decision_id, i.status FROM order_intents i '
      'JOIN broker_orders b ON b.intent_id = i.intent_id '
      'WHERE i.trade_date = ? AND i.status IN (?, ?) ORDER BY i.created_at, i.intent_id',
      <Object?>[tradeDate.yyyyMmDd, ..._openCodes],
    )) {
      final String id = r['intent_id'] as String;
      if (!seen.add(id)) {
        // 이 판은 의도 하나 = 브로커 주문 하나다(정정 · 재주문 없음) — 둘이면 원장이 틀렸다.
        throw StateError('$id: 브로커 주문이 둘 이상이다');
      }
      out.add(
        OpenIntent(
          intentId: id,
          brokerOrderNo: r['broker_order_no'] as String,
          tradeDate: TradeDate(r['trade_date'] as String),
          market: r['market'] as String,
          account: r['account'] as String,
          strategyId: r['strategy_id'] as String,
          symbol: r['symbol'] as String,
          side: r['side'] == 'BUY' ? OrderSide.buy : OrderSide.sell,
          quantity: r['quantity'] as int,
          decisionId: r['decision_id'] as String,
          status: r['status'] == 'PARTIAL'
              ? IntentStatus.partial
              : IntentStatus.submitted,
        ),
      );
    }
    return out;
  }

  @override
  Future<RecordedFill?> recordedFill(String brokerOrderNo) async {
    final ResultSet rows = _db.select(
      'SELECT raw_response FROM broker_orders WHERE broker_order_no = ?',
      <Object?>[brokerOrderNo],
    );
    if (rows.isEmpty) throw StateError('없는 브로커 주문: $brokerOrderNo');
    final Object? raw = rows.single['raw_response'];
    if (raw == null) return null;
    try {
      return parseRecordedFillJson(raw as String);
    } on FormatException {
      throw StateError('$brokerOrderNo: 기록된 누적의 꼴이 틀렸다');
    }
  }

  @override
  Future<void> applyFill(FillApplication application) async {
    final FillVerdict v = application.verdict;
    final OpenIntent it = v.intent;
    final DailyFillRow? row = v.row;
    if (row == null) throw StateError('${it.intentId}: 원주문 행이 없는 판정은 쓸 수 없다');
    if (application.costs.length != v.deltas.length) {
      throw ArgumentError('체결 행과 비용의 개수가 다르다');
    }
    final String now = application.seenAtUtc.toUtc().toIso8601String();
    _db.execute('BEGIN IMMEDIATE');
    try {
      for (int i = 0; i < v.deltas.length; i++) {
        final FillDelta d = v.deltas[i];
        final c = application.costs[i]; // (commission, tax) — 금액 타입은 core 의 것
        _db.execute(
          'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, '
          'commission, tax, authored_at, fill_origin, cost_source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            d.executionId,
            d.brokerOrderNo,
            now,
            d.quantity,
            demoteToDouble(d.price),
            demoteToDouble(c.commission),
            demoteToDouble(c.tax),
            now,
            'BROKER',
            'ESTIMATED',
          ],
        );
        _position(it, d, now);
      }
      final int cum = row.cumFilledQty;
      _db.execute(
        'UPDATE broker_orders SET status = ?, filled_qty = ?, remaining_qty = ?, '
        'avg_fill_price = ?, raw_response = ? WHERE broker_order_no = ?',
        <Object?>[
          v.status.code,
          cum,
          row.remainingQty,
          averageFillPrice(row),
          recordedFillJson(row, application.seenAtUtc),
          it.brokerOrderNo,
        ],
      );
      if (_db.updatedRows != 1) {
        throw StateError('없는 브로커 주문: ${it.brokerOrderNo}');
      }
      _db.execute(
        'UPDATE order_intents SET status = ?, error_message = ?, updated_at = ? '
        'WHERE intent_id = ? AND status = ?',
        <Object?>[v.status.code, v.message, now, it.intentId, it.status.code],
      );
      if (_db.updatedRows != 1) {
        throw StateError(
          '${it.intentId}: ${it.status.code} 가 아니다(체결 적용 전이 불가)',
        );
      }
      _db.execute('COMMIT');
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// 포지션 갱신(R38 Z6) — 매수 = 평단 갱신 · 매도 = 수량만 · 음수 = StateError · 0 = 지운다.
  void _position(OpenIntent it, FillDelta d, String now) {
    final ResultSet rows = _db.select(
      'SELECT quantity, avg_price FROM positions WHERE market = ? AND symbol = ? AND strategy_id = ?',
      <Object?>[it.market, it.symbol, it.strategyId],
    );
    final int q0 = rows.isEmpty ? 0 : rows.single['quantity'] as int;
    if (d.side == OrderSide.buy) {
      final int q1 = q0 + d.quantity;
      if (rows.isEmpty) {
        _db.execute(
          'INSERT INTO positions (market, symbol, strategy_id, quantity, avg_price, entry_date, '
          'updated_at, entry_decision_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            it.market,
            it.symbol,
            it.strategyId,
            q1,
            demoteToDouble(d.price),
            it.tradeDate.yyyyMmDd,
            now,
            it.decisionId,
          ],
        );
        return;
      }
      final double a1 = averagePriceAfterBuy(
        heldQty: q0,
        heldAvg: (rows.single['avg_price'] as num).toDouble(),
        buy: d,
      );
      _db.execute(
        'UPDATE positions SET quantity = ?, avg_price = ?, updated_at = ? '
        'WHERE market = ? AND symbol = ? AND strategy_id = ?',
        <Object?>[q1, a1, now, it.market, it.symbol, it.strategyId],
      );
      return;
    }
    final int q1 = q0 - d.quantity;
    if (q1 < 0) {
      throw StateError(
        '${it.symbol}(${it.strategyId}): 매도 ${d.quantity}주가 보유 $q0주를 넘는다',
      );
    }
    if (q1 == 0) {
      _db.execute(
        'DELETE FROM positions WHERE market = ? AND symbol = ? AND strategy_id = ?',
        <Object?>[it.market, it.symbol, it.strategyId],
      );
    } else {
      _db.execute(
        'UPDATE positions SET quantity = ?, updated_at = ? '
        'WHERE market = ? AND symbol = ? AND strategy_id = ?',
        <Object?>[q1, now, it.market, it.symbol, it.strategyId],
      );
    }
  }

  @override
  Future<void> markUnresolved(String intentId, String message) async {
    _db.execute(
      'UPDATE order_intents SET status = ?, error_message = ?, updated_at = ? '
      'WHERE intent_id = ? AND status IN (?, ?)',
      <Object?>[
        IntentStatus.unknown.code,
        message,
        _now(),
        intentId,
        ..._openCodes,
      ],
    );
    if (_db.updatedRows != 1) {
      throw StateError('$intentId: 열린 의도(SUBMITTED · PARTIAL)가 아니다');
    }
  }

  // ── 🆕 E10e2 이월 원장(CarryLedger · R39 T2 · T4) ───────────────────────────

  /// `substr(decision_id, 1, n) = '{논리 id}@'` 의 인자(n · 접두).
  static List<Object?> _logicalArgs(String logical) {
    final String prefix = '$logical@';
    return <Object?>[prefix.length, prefix];
  }

  @override
  Future<List<ExpiredIntent>> expiredIntents(TradeDate tradeDate) async {
    final List<ExpiredIntent> out = <ExpiredIntent>[];
    final Set<String> seen = <String>{};
    for (final Row r in _db.select(
      'SELECT i.intent_id, i.decision_id, i.strategy_id, i.symbol, i.side, i.quantity, '
      'b.broker_order_no, b.filled_qty, b.raw_response FROM order_intents i '
      'JOIN broker_orders b ON b.intent_id = i.intent_id '
      "WHERE i.trade_date = ? AND i.status = 'EXPIRED' ORDER BY i.created_at, i.intent_id",
      <Object?>[tradeDate.yyyyMmDd],
    )) {
      final String id = r['intent_id'] as String;
      if (!seen.add(id)) throw StateError('$id: 브로커 주문이 둘 이상이다');
      final String no = r['broker_order_no'] as String;
      final Object? raw = r['raw_response'];
      if (raw == null) throw StateError('$no: 실효인데 기록된 누적이 없다');
      final int cancelled;
      try {
        cancelled = parseRecordedCancelJson(raw as String);
      } on FormatException {
        throw StateError('$no: 기록된 취소 확인의 꼴이 틀렸다');
      }
      final String logical = logicalIdOf(r['decision_id'] as String);
      final String strategyId = r['strategy_id'] as String;
      final String symbol = r['symbol'] as String;
      out.add(
        ExpiredIntent(
          intentId: id,
          logicalDecisionId: logical,
          strategyId: strategyId,
          symbol: symbol,
          side: r['side'] == 'BUY' ? OrderSide.buy : OrderSide.sell,
          expiredQty:
              (r['quantity'] as int) - (r['filled_qty'] as int) - cancelled,
          // 어느 상태든 센다(막힌 날도 — 보수 · R39 T2).
          sessionsUsed:
              _db.select(
                    'SELECT COUNT(DISTINCT trade_date) AS n FROM order_intents '
                    'WHERE strategy_id = ? AND symbol = ? AND substr(decision_id, 1, ?) = ?',
                    <Object?>[strategyId, symbol, ..._logicalArgs(logical)],
                  ).single['n']
                  as int,
        ),
      );
    }
    return out;
  }

  @override
  Future<SplitProgress> splitProgress(
    String logicalDecisionId, {
    required String strategyId,
    required String symbol,
    required TradeDate before,
  }) async {
    final Row r = _db.select(
      'SELECT COALESCE(SUM(i.quantity), 0) AS planned, COALESCE(SUM(b.filled_qty), 0) AS filled '
      'FROM order_intents i LEFT JOIN broker_orders b ON b.intent_id = i.intent_id '
      'WHERE i.strategy_id = ? AND i.symbol = ? AND substr(i.decision_id, 1, ?) = ? '
      'AND i.trade_date < ? AND ${_sentWhere('i')}',
      <Object?>[
        strategyId,
        symbol,
        ..._logicalArgs(logicalDecisionId),
        before.yyyyMmDd,
        ..._sentArgs,
      ],
    ).single;
    return SplitProgress(
      planned: r['planned'] as int,
      filled: r['filled'] as int,
    );
  }

  // ── 🆕 E10e2 해소 원장(UnknownLedger · R39 T9) ─────────────────────────────

  static const String _noBrokerOrder =
      'NOT EXISTS (SELECT 1 FROM broker_orders b WHERE b.intent_id = i.intent_id)';

  /// 🆕 E14d1(R75 N6) — UNKNOWN 의도 전체 수(브로커 주문이 있든 없든 · 재개 child 전제).
  int unknownCount() =>
      _db
              .select(
                "SELECT COUNT(*) AS n FROM order_intents WHERE status = 'UNKNOWN'",
              )
              .first['n']!
          as int;

  /// 🆕 E14d1(R75 N6) — RESERVED · SUBMITTING 잔류 수(재개 child 전제 · 보강 (a)).
  int residualCount() =>
      _db
              .select(
                "SELECT COUNT(*) AS n FROM order_intents WHERE status IN ('RESERVED', 'SUBMITTING')",
              )
              .first['n']!
          as int;

  @override
  Future<List<UnknownIntent>> unknownIntents() async => <UnknownIntent>[
    for (final Row r in _db.select(
      'SELECT i.intent_id, i.trade_date, i.account, i.symbol, i.side, i.quantity, i.limit_price, '
      "i.created_at, i.error_message FROM order_intents i WHERE i.status = 'UNKNOWN' "
      'AND $_noBrokerOrder ORDER BY i.created_at, i.intent_id',
    ))
      UnknownIntent(
        intentId: r['intent_id'] as String,
        tradeDate: TradeDate(r['trade_date'] as String),
        account: r['account'] as String,
        symbol: r['symbol'] as String,
        side: r['side'] == 'BUY' ? OrderSide.buy : OrderSide.sell,
        quantity: r['quantity'] as int,
        limitPrice: (r['limit_price'] as num?)?.toDouble(),
        createdAtUtc: DateTime.parse(r['created_at'] as String).toUtc(),
        errorMessage: r['error_message'] as String?,
      ),
  ];

  @override
  Future<Set<String>> linkedOrderNos(Iterable<String> brokerOrderNos) async {
    final List<String> all = brokerOrderNos.toSet().toList();
    final Set<String> out = <String>{};
    for (int i = 0; i < all.length; i += 500) {
      final List<String> part = all.sublist(
        i,
        i + 500 < all.length ? i + 500 : all.length,
      );
      final String marks = List<String>.filled(part.length, '?').join(', ');
      for (final Row r in _db.select(
        'SELECT broker_order_no FROM broker_orders WHERE broker_order_no IN ($marks)',
        part,
      )) {
        out.add(r['broker_order_no'] as String);
      }
    }
    return out;
  }

  @override
  Future<void> linkUnknown(String intentId, String brokerOrderNo) async {
    _db.execute('BEGIN IMMEDIATE');
    try {
      final ResultSet rows = _db.select(
        'SELECT i.quantity, i.created_at FROM order_intents i '
        "WHERE i.intent_id = ? AND i.status = 'UNKNOWN' AND $_noBrokerOrder",
        <Object?>[intentId],
      );
      if (rows.isEmpty) {
        throw StateError('$intentId: 브로커 주문이 없는 UNKNOWN 이 아니다');
      }
      if (_exists(
        'SELECT 1 FROM broker_orders WHERE broker_order_no = ?',
        <Object?>[brokerOrderNo],
      )) {
        throw StateError('$brokerOrderNo: 이미 다른 의도에 붙어 있다');
      }
      // submitted_at = 예약 시각(SUBMITTING 시각은 UNKNOWN 기록이 덮었다 — 이르게 잡힌다 · R39 T5).
      _db.execute(
        'INSERT INTO broker_orders (broker_order_no, intent_id, submitted_at, status, '
        'filled_qty, remaining_qty) VALUES (?, ?, ?, ?, 0, ?)',
        <Object?>[
          brokerOrderNo,
          intentId,
          rows.single['created_at'],
          IntentStatus.submitted.code,
          rows.single['quantity'],
        ],
      );
      _move(intentId, IntentStatus.unknown, IntentStatus.submitted);
      _db.execute('COMMIT');
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<void> rejectUnknown(String intentId, String message) async {
    if (!message.startsWith(kUnknownNotFoundPrefix)) {
      throw ArgumentError.value(
        message,
        'message',
        '`$kUnknownNotFoundPrefix` 접두가 없다',
      );
    }
    _db.execute(
      'UPDATE order_intents AS i SET status = ?, error_message = ?, updated_at = ? '
      "WHERE i.intent_id = ? AND i.status = 'UNKNOWN' AND $_noBrokerOrder",
      <Object?>[IntentStatus.rejected.code, message, _now(), intentId],
    );
    if (_db.updatedRows != 1) {
      throw StateError('$intentId: 브로커 주문이 없는 UNKNOWN 이 아니다');
    }
  }

  @override
  Future<void> noteUnknownMiss(String intentId, String message) async {
    _db.execute(
      'UPDATE order_intents SET error_message = ?, updated_at = ? '
      "WHERE intent_id = ? AND status = 'UNKNOWN'",
      <Object?>[message, _now(), intentId],
    );
    if (_db.updatedRows != 1) throw StateError('$intentId: UNKNOWN 이 아니다');
  }

  // ── 🆕 E10f 대사 원장(ReconLedger · R40 A2 · A7 · A8) ─────────────────────────

  /// `reconciliation_log.recon_id` — `{접두}{시각}#{그 시각의 일련}`(열린 트랜잭션 안에서 부른다).
  String _reconLogId(String prefix, String at) {
    final int n =
        _db.select(
              'SELECT COUNT(*) AS n FROM reconciliation_log WHERE run_at = ?',
              <Object?>[at],
            ).single['n']
            as int;
    return '$prefix$at#${n + 1}';
  }

  bool _reconActive() => _exists(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.reconMismatch],
  );

  @override
  Future<List<LedgerHolding>> krHoldings() async => <LedgerHolding>[
    for (final Row r in _db.select(
      "SELECT strategy_id, symbol, quantity FROM positions WHERE market = 'KR' "
      'ORDER BY strategy_id, symbol',
    ))
      LedgerHolding(
        r['strategy_id'] as String,
        r['symbol'] as String,
        r['quantity'] as int,
      ),
  ];

  @override
  Future<List<LedgerOrderFill>> orderFills(
    TradeDate tradeDate,
  ) async => <LedgerOrderFill>[
    for (final Row r in _db.select(
      'SELECT b.broker_order_no, i.account, i.symbol, '
      '(SELECT COALESCE(SUM(e.quantity), 0) FROM executions e '
      'WHERE e.broker_order_no = b.broker_order_no) AS filled '
      'FROM broker_orders b JOIN order_intents i ON i.intent_id = b.intent_id '
      "WHERE i.trade_date = ? AND i.market = 'KR' ORDER BY b.broker_order_no",
      <Object?>[tradeDate.yyyyMmDd],
    ))
      LedgerOrderFill(
        brokerOrderNo: r['broker_order_no'] as String,
        account: r['account'] as String,
        symbol: r['symbol'] as String,
        filledQty: r['filled'] as int,
      ),
  ];

  @override
  Future<String> recordReconciliation(ReconRecord record) async {
    final String at = record.runAtUtc.toUtc().toIso8601String();
    _db.execute('BEGIN IMMEDIATE');
    try {
      final String reconId = _reconLogId('rc-', at);
      _db.execute(
        'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
        'VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          reconId,
          at,
          record.matched ? 1 : 0,
          record.discrepanciesJson,
          record.action.code,
        ],
      );
      for (final ReconDiff d in record.blocking) {
        // 같은 날 같은 어긋남 = 같은 행(내용 해시) · 해제 뒤 다시 보이면 다시 연다.
        _db.execute(
          'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, '
          'severity, origin_code, status, detected_at, applicable) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, 1) '
          'ON CONFLICT(diff_id) DO UPDATE SET status = excluded.status, origin_code = NULL, '
          'detected_at = excluded.detected_at WHERE ledger_diff.status <> excluded.status',
          <Object?>[
            ledgerDiffIdOf(record.tradeDate, d),
            LedgerPair.canonBroker.wire,
            d.axis.wire,
            record.tradeDate.yyyyMmDd,
            d.deltaJson,
            d.label,
            // 🆕 E13c1 — 심각도 = 쌍 · 축 규칙(R58 C8 · 브로커 수량 · 체결 = 차단).
            diffSeverityFor(LedgerPair.canonBroker, d.axis).wire,
            DiffStatus.open.wire,
            at,
          ],
        );
      }
      if (record.blocking.isNotEmpty && !_reconActive()) {
        // 🔴 세우기만 — 일치하는 대사도 풀지 않는다(04 §3-5 ④).
        _db.execute(
          'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?) '
          'ON CONFLICT(flag_id) DO UPDATE SET set_at = excluded.set_at, '
          'reason = excluded.reason, origin_code = NULL, cleared_at = NULL, '
          'cleared_by = NULL, decision_id = NULL',
          <Object?>[
            FlagIds.reconMismatch,
            at,
            '대사 불일치 ${record.blocking.length}건 — 재대사 뒤 잔존 (SAF-407 · $reconId)',
          ],
        );
      }
      _db.execute('COMMIT');
      return reconId;
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<bool> reconBlocked() async => _reconActive();

  @override
  Future<bool> reconClearJournalExists(String decisionId) async => _exists(
    "SELECT 1 FROM decision_journal WHERE journal_id = ? AND kind = 'RECON_CLEAR'",
    <Object?>[decisionId],
  );

  @override
  Future<void> clearReconBlock(ReconClearance clearance) async {
    // 🆕 E13c1 — 원인 코드 쓰기 화이트리스트(R58 C7) · 밖이면 아무것도 쓰지 않는다.
    if (!writableOriginCodesFor(LedgerPair.canonBroker)
        .contains(clearance.originCode)) {
      throw ArgumentError.value(
        clearance.originCode,
        'originCode',
        '대사 해제에 쓸 수 없는 원인 코드',
      );
    }
    final String at = clearance.clearedAtUtc.toUtc().toIso8601String();
    _db.execute('BEGIN IMMEDIATE');
    try {
      _db.execute(
        'UPDATE trading_block SET cleared_at = ?, cleared_by = ?, decision_id = ?, origin_code = ? '
        'WHERE flag_id = ? AND cleared_at IS NULL',
        <Object?>[
          at,
          clearance.clearedBy,
          clearance.decisionId,
          clearance.originCode,
          FlagIds.reconMismatch,
        ],
      );
      if (_db.updatedRows != 1) {
        throw StateError('RECON_MISMATCH 가 서 있지 않다');
      }
      _db.execute(
        'UPDATE ledger_diff SET status = ?, origin_code = ? WHERE pair = ? AND status = ?',
        <Object?>[
          DiffStatus.resolved.wire,
          clearance.originCode,
          LedgerPair.canonBroker.wire,
          DiffStatus.open.wire,
        ],
      );
      final int resolved = _db.updatedRows;
      // 🆕 E13e2 — MANUAL_ORDER = 같은 트랜잭션에 SEV2 postmortem 7일(04 §3-5 ④ · R63 V1 · 다시 = 1건).
      final SafetyIncident? incident = clearance.incident;
      if (incident != null) {
        _db.execute(
          'INSERT OR IGNORE INTO incidents (incident_id, occurred_at, severity, category, description, '
          'resolved_at, postmortem, due_at) VALUES (?, ?, ?, ?, ?, NULL, NULL, ?)',
          <Object?>[
            incident.incidentId,
            incident.occurredAtUtc.toIso8601String(),
            incident.severity,
            incident.category,
            incident.description,
            incident.dueAtUtc.toIso8601String(),
          ],
        );
      }
      // 해제도 로그 한 행(원인 코드를 남긴다 — 04 §3-5 ②). matched = 0 — 대사 판이 아니다.
      _db.execute(
        'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
        "VALUES (?, ?, 0, ?, 'CLEARED')",
        <Object?>[
          _reconLogId('rc-clear-', at),
          at,
          jsonEncode(<String, Object?>{
            'origin_code': clearance.originCode,
            'decision_id': clearance.decisionId,
            'cleared_by': clearance.clearedBy,
            'resolved': resolved,
          }),
        ],
      );
      _db.execute('COMMIT');
    } catch (_) {
      if (!_db.autocommit) _db.execute('ROLLBACK');
      rethrow;
    }
  }
}
