// 주문 원장 — core `OrderLedger` 포트의 SQLite 구현(설계 13 §8 R33 D12 · R36 W1~W9 · 04 §3-1 · §1 · 02 §2-4 · §2-6 · §3-2).
//
// 🔴 6.5 COMMIT — [insertIntent] 는 **자동 커밋 한 문장**이다. 돌아오면 그 행은 커밋됐고 별도 커넥션에서 보인다(AC-S04).
//    연결에 열린 트랜잭션이 있으면(누가 BEGIN 해 두었으면) INSERT 하지 않고 StateError — 그 INSERT 는 브로커 호출 뒤
//    롤백될 수 있어 NR-1 이 무력해진다(04 §3-1 v1.5).
// 🔴 상태 전이는 `WHERE status = 앞 상태` 로만 바꾼다 — 바뀐 행이 1 이 아니면 StateError(순서를 건너뛴 기록을 받지 않는다).
// 🔴 브로커 거절은 `error_message` 접두 `BROKER: ` 로 1~5단계 거부와 가른다(orders_today 에 센다 — R33 D22 · R36 W5).
// 🔴 SAF-408 · 410 판정은 SQL 을 직접 돌려 `trading_block` 플래그를 **자동** 설정 · 해제하고 그 결과를 돌려준다 —
//    사람이 해제하는 경로는 없다(`cleared_by = 'auto:SAF-40x'` · 04 §1 v2.11 · v2.15 SF-01 · 파일럿4 `safety/gates.py`).
// 🔵 체결 기록(`broker_orders` 갱신 · `executions` · `positions`)은 E10e(R36 W1).

import 'package:core_engine/core_engine.dart'
    show BlockBundles, ExchangeCalendar, IntentRow, IntentStatus, OrderLedger;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, FlagIds, RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart';

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
final class SqliteOrderLedger implements OrderLedger {
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
  Future<bool> killSwitchActive() async => _exists(
    'SELECT 1 FROM kill_switch_state '
    'WHERE id = 1 AND activated_at IS NOT NULL AND cleared_at IS NULL',
  );

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

  @override
  Future<int> ordersToday(TradeDate tradeDate) async {
    final String marks = List<String>.filled(
      _submittedOrLater.length,
      '?',
    ).join(', ');
    return _db.select(
          'SELECT COUNT(*) AS n FROM order_intents WHERE trade_date = ? AND ('
          'status IN ($marks) OR '
          "(status = 'REJECTED' AND substr(error_message, 1, ?) = ?))",
          <Object?>[
            tradeDate.yyyyMmDd,
            for (final IntentStatus s in _submittedOrLater) s.code,
            kBrokerRejectedPrefix.length,
            kBrokerRejectedPrefix,
          ],
        ).single['n']
        as int;
  }

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
          row.limitPrice?.toDouble(),
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
}
