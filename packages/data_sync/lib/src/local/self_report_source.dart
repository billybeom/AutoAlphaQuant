// E11q-q6 — `L-3` 정기 실사 원장 원천(앱 계약 01 §21-4 · 02 §3-10 · 엔진 몫 = core `ops/self_report.dart`).
//
// 🔴 원장 수량(기준일) = 보유 화면과 같은 원천 — 지금 포지션(그 계좌에 묶인 전략 · KR) − 기준일 뒤 브로커 체결
//    (`krSignedFillsAfter` — 슬리브 기여 · 월간 리포트와 같은 «그날 보유» 규칙). 화면에 싣지 않는다(앵커링 금지).
// 🔴 기록 = 한 트랜잭션: `self_report_balance` 1 + `self_report_line` n + `ledger_diff`(CANON_SELF_REPORT · 수량 축 · 🆕 R278 현금 축 ·
//    OBSERVATIONAL) + `command_inbox`(EXECUTED · 엔진 글자) — 실패 = 전부 되돌림. 무결성 점검 중 = 보관 행만(B18).
// 🔴 그 달 그 계좌 실사 = 한 번(같은 기준일 · 같은 별칭 행이 있으면 [StateError] — 부르는 쪽이 세션으로 막는다).
// 🆕 R278(01 §8 미결 227 · 계약 v1.37 §46 K323) — 현금 축 원천 = 그 계좌 원화 `cash_flow`(별칭) + 그 계좌(`order_intents.account`)
//    KR 브로커 체결 대금 · 기준일까지(수량 축과 같은 «그날» = 집행일) · 계좌를 모르는 현금 · 체결 = 모름 · 셈 = core.
//    🔴 이 패키지는 Decimal 을 쓰지 않는다 — 원천 사실만 읽어 넘긴다(셈 · 판정 = core `selfReportLedgerCashOf`).
// 🆕 R281(01 §8 미결 256 · 계약 v1.42 §51) — 실사 행에 제출 순간의 현금 축 판정(`cash_check` · `cash_tolerance_krw`)을 같이 적고
//    결과는 그 칸을 읽는다(읽을 때 다시 정하지 않는다) · 두 칸 = 원장 해시 투영 밖.

import 'package:core_engine/core_engine.dart'
    show
        LedgerHolding,
        SelfReportCashFacts,
        SelfReportDiffRow,
        SimExecution,
        StoredLedgerDiff,
        selfReportAccountOfDelta,
        selfReportPayloadDigestOf,
        selfReportSleeveOfStrategy;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        CommandKind,
        CommandState,
        DiffStatus,
        FlagIds,
        LedgerPair,
        OperatingMode,
        OrderSide,
        RunMode,
        SelfReportBalance,
        SelfReportCashCheck,
        SelfReportLine,
        SleeveId,
        TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

import 'fill_sign_sql.dart' show signedFillSql;
import 'ledger_read_model.dart' show storedLedgerDiffs;
import 'position_replay_sql.dart' show krSignedFillsAfter;

/// 정기 실사 원장 원천.
class SqliteSelfReportSource {
  /// 만든다 — [clock] = 기록 시각(접수 · 보관 행).
  SqliteSelfReportSource(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 감시 표(세션 VM · 결과가 이 표들의 변화로 다시 선다).
  static const Set<String> watchedTables = <String>{
    'self_report_balance',
    'self_report_line',
    'ledger_diff',
    'positions',
    'executions',
    'trading_block',
    'cash_flow',
  };

  /// 🔴 기준일 원장 수량(종목 → 수량 · 0 = 빠짐) — [strategies] = 그 계좌에 묶인 전략.
  Map<String, int> ledgerQuantities(TradeDate asOf, List<String> strategies) {
    final Set<String> mine = strategies.toSet();
    final Map<String, int> q = <String, int>{};
    for (final Row r in _db.select(
      "SELECT strategy_id, symbol, quantity FROM positions WHERE market = 'KR'",
    )) {
      if (!mine.contains(r['strategy_id'])) continue;
      final String s = r['symbol'] as String;
      q[s] = (q[s] ?? 0) + (r['quantity'] as int);
    }
    for (final LedgerHolding h in krSignedFillsAfter(_db, asOf.yyyyMmDd)) {
      if (!mine.contains(h.strategyId)) continue;
      q[h.symbol] = (q[h.symbol] ?? 0) - h.quantity;
    }
    q.removeWhere((String _, int v) => v == 0);
    return q;
  }

  /// 지금 원장에 남은 종목 → 슬리브(그 계좌에 묶인 전략 · 수량 ≠ 0 · 설정 밖 종목이 실사 목록에서 빠지지 않게).
  Map<String, SleeveId> heldSleeves(List<String> strategies) {
    final Set<String> mine = strategies.toSet();
    final Map<String, SleeveId> out = <String, SleeveId>{};
    for (final Row r in _db.select(
      "SELECT strategy_id, symbol FROM positions WHERE market = 'KR' AND quantity <> 0 "
      'ORDER BY strategy_id, symbol',
    )) {
      final String strategy = r['strategy_id'] as String;
      if (!mine.contains(strategy)) continue;
      final SleeveId? s = selfReportSleeveOfStrategy(strategy);
      if (s != null) out.putIfAbsent(r['symbol'] as String, () => s);
    }
    return out;
  }

  /// 그 기준일에 실사를 마친 계좌 별칭.
  Set<String> auditedAccounts(TradeDate asOf) => <String>{
    for (final Row r in _db.select(
      'SELECT DISTINCT account_alias FROM self_report_balance WHERE as_of_trade_date = ?',
      <Object?>[asOf.yyyyMmDd],
    ))
      r['account_alias'] as String,
  };

  /// 그 계좌의 마지막 실사 기준일(없음 = null).
  TradeDate? lastVerifiedOn(String alias) {
    final Object? v = _db.select(
      'SELECT MAX(as_of_trade_date) AS d FROM self_report_balance WHERE account_alias = ?',
      <Object?>[alias],
    ).first['d'];
    return v is String ? TradeDate(v) : null;
  }

  /// 그 기준일 · 계좌의 실사 차이(저장 행 · 탐지 차례 → id).
  List<StoredLedgerDiff> diffsOf(TradeDate asOf, String alias) =>
      <StoredLedgerDiff>[
        for (final StoredLedgerDiff d in storedLedgerDiffs(_db))
          if (d.pair == LedgerPair.canonSelfReport &&
              d.authoredDate == asOf &&
              selfReportAccountOfDelta(d.delta) == alias)
            d,
      ]..sort((StoredLedgerDiff a, StoredLedgerDiff b) {
        final int t = a.detectedAtUtc.compareTo(b.detectedAtUtc);
        return t != 0 ? t : a.diffId.compareTo(b.diffId);
      });

  /// 원장 무결성 점검 중인가(`LEDGER_INTEGRITY` 가 서 있다 — 기록 명령 = 보관).
  bool integrityBroken() => _flagStanding(FlagIds.ledgerIntegrity);

  /// 🆕 R278 — 실사 패턴 미검증 표식이 서 있나(`SELF_AUDIT_PATTERN_UNVERIFIED` — 서 있으면 현금 허용 오차 = 0원 · K323 ③).
  bool patternUnverifiedStanding() =>
      _flagStanding(FlagIds.selfAuditPatternUnverified);

  bool _flagStanding(String flagId) => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[flagId],
  ).isNotEmpty;

  /// 🆕 R278 🔴 기준일 계좌 원장 현금 원천(K323 ①) — 그 계좌 원화 `cash_flow` 합(거래일 ≤ 기준일) + 그 계좌 KR 브로커 체결
  /// (집행일 ≤ 기준일 · `REVERSAL` = 수량 · 비용 음수 — 시뮬레이터 현금 셈과 같은 부호) · 모름 = 기준일까지 별칭 빈 `cash_flow` 행 ·
  /// 계좌 빈 의도의 체결 · 살아 있는 수기 체결(브로커 주문 없음 · 되돌림 아님 · 되돌려지지 않음 — 행에 계좌 칸이 없다 · 한국
  /// 날짜 ≤ 기준일)이 하나라도 있으면.
  SelfReportCashFacts cashFactsOf(TradeDate asOf, String alias) {
    final String d = asOf.yyyyMmDd;
    bool any(String sql) => _db.select(sql, <Object?>[d]).isNotEmpty;
    final bool unattributed =
        any(
          "SELECT 1 FROM cash_flow WHERE (account_alias IS NULL OR TRIM(account_alias) = '') "
          'AND trade_date <= ? LIMIT 1',
        ) ||
        any(
          'SELECT 1 FROM executions e '
          'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
          'JOIN order_intents i ON i.intent_id = b.intent_id '
          "WHERE i.market = 'KR' AND TRIM(i.account) = '' AND i.trade_date <= ? LIMIT 1",
        ) ||
        any(
          "SELECT 1 FROM executions e WHERE e.broker_order_no IS NULL AND e.fill_kind <> 'REVERSAL' "
          'AND NOT EXISTS (SELECT 1 FROM executions v WHERE v.reverses_fill_id = e.execution_id) '
          "AND date(e.executed_at, '+9 hours') <= ? LIMIT 1",
        );
    final double sum =
        (_db.select(
                  'SELECT COALESCE(SUM(amount), 0) AS s FROM cash_flow '
                  "WHERE account_alias = ? AND trade_date <= ? AND currency = 'KRW'",
                  <Object?>[alias, d],
                ).first['s']!
                as num)
            .toDouble();
    return SelfReportCashFacts(
      cashFlowSum: sum,
      executions: <SimExecution>[
        for (final Row r in _db.select(
          'SELECT i.side, ${signedFillSql('e', 'quantity')} AS quantity, e.price, '
          '${signedFillSql('e', 'commission')} AS commission, '
          '${signedFillSql('e', 'tax')} AS tax FROM executions e '
          'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
          'JOIN order_intents i ON i.intent_id = b.intent_id '
          "WHERE i.account = ? AND i.market = 'KR' AND i.trade_date <= ? "
          'ORDER BY e.execution_id',
          <Object?>[alias, d],
        ))
          SimExecution(
            side: OrderSide.values.firstWhere(
              (OrderSide s) => s.wire == r['side'],
            ),
            quantity: r['quantity'] as int,
            price: (r['price'] as num).toDouble(),
            commission: (r['commission'] as num).toDouble(),
            tax: (r['tax'] as num).toDouble(),
          ),
      ],
      unattributed: unattributed,
    );
  }

  /// 🆕 R278 — 그 기준일 · 계좌 실사가 0오차였나(K321 ④ · `M5-13` 해제가 읽는다 — 미결 226) = 실사가 있고 그 실사가 남긴 차이
  /// 행(수량 · 현금 · 상태 무관) 0 — 현금 행은 대조해 넘은 때만 생기므로 «현금 축은 대조한 때만 센다»와 같다 · 실사 없음 = false.
  bool zeroErrorAudit(TradeDate asOf, String alias) =>
      auditedAccounts(asOf).contains(alias) && diffsOf(asOf, alias).isEmpty;

  /// 🆕 R281 — 그 기준일 · 계좌 실사에 적힌 현금 축 판정(결과 빈 문장의 원천) · 실사 없음 = [StateError](결과는 실사가 있을 때만
  /// 짓는다 — 지어내지 않는다).
  SelfReportCashCheck cashCheckOf(TradeDate asOf, String alias) {
    final List<Row> rows = _db.select(
      'SELECT cash_check FROM self_report_balance WHERE as_of_trade_date = ? AND account_alias = ?',
      <Object?>[asOf.yyyyMmDd, alias],
    );
    if (rows.isEmpty) {
      throw StateError('실사 없음: ${asOf.yyyyMmDd} $alias');
    }
    final Object? v = rows.single['cash_check'];
    return SelfReportCashCheck.values.firstWhere(
      (SelfReportCashCheck c) => c.wire == v,
    );
  }

  /// 🔴 실사 기록(한 트랜잭션) — [diffs] = 엔진 대조 결과 · [stateLabel] = 엔진 접수증 글자 · 🆕 R281 [cashCheck] ·
  /// [cashToleranceKrw] = 제출 순간 현금 축 판정(core `selfReportCashRecordOf` — 대조함일 때만 허용 오차 · DDL 짝 CHECK) ·
  /// 같은 기준일 · 계좌 실사가 이미 있으면 [StateError](쓰기 0).
  void record({
    required SelfReportBalance wire,
    required String commandId,
    required String deviceId,
    required DateTime reportedAtUtc,
    required List<SelfReportDiffRow> diffs,
    required SelfReportCashCheck cashCheck,
    required double? cashToleranceKrw,
    required String stateLabel,
    required RunMode runMode,
    required OperatingMode operatingMode,
    int? leaseEpoch,
  }) {
    final String at = reportedAtUtc.toUtc().toIso8601String();
    final String reportId = 'sr_$commandId';
    _db.execute('BEGIN IMMEDIATE');
    try {
      if (_db.select(
        'SELECT 1 FROM self_report_balance WHERE as_of_trade_date = ? AND account_alias = ?',
        <Object?>[wire.asOfTradeDate.yyyyMmDd, wire.accountAlias],
      ).isNotEmpty) {
        throw StateError(
          '실사 이미 있음: ${wire.asOfTradeDate.yyyyMmDd} ${wire.accountAlias}',
        );
      }
      _db.execute(
        'INSERT INTO self_report_balance (report_id, as_of_trade_date, account_alias, session_started_at, '
        'cash_krw, declared_complete, device_id, command_id, reported_at, cash_check, cash_tolerance_krw) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          reportId,
          wire.asOfTradeDate.yyyyMmDd,
          wire.accountAlias,
          wire.sessionStartedAt.toUtc().toIso8601String(),
          wire.cashKrw.toDouble(),
          wire.declaredComplete ? 1 : 0,
          deviceId,
          commandId,
          at,
          cashCheck.wire,
          cashToleranceKrw,
        ],
      );
      for (final SelfReportLine l in wire.lines) {
        _db.execute(
          'INSERT INTO self_report_line (report_id, symbol, quantity) VALUES (?, ?, ?)',
          <Object?>[reportId, l.symbol, l.quantity],
        );
      }
      for (final SelfReportDiffRow d in diffs) {
        _db.execute(
          'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, '
          'origin_code, status, detected_at, applicable) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, 1)',
          <Object?>[
            d.diffId,
            LedgerPair.canonSelfReport.wire,
            d.axis.wire,
            wire.asOfTradeDate.yyyyMmDd,
            d.delta,
            d.deltaLabel,
            d.severity.wire,
            DiffStatus.open.wire,
            at,
          ],
        );
      }
      _inbox(
        commandId: commandId,
        state: CommandState.executed,
        stateLabel: stateLabel,
        runMode: runMode,
        operatingMode: operatingMode,
        leaseEpoch: leaseEpoch,
        payloadDigest: selfReportPayloadDigestOf(wire),
      );
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// 무결성 점검 중 보관 — `command_inbox` 보관 행 하나(원장 쓰기 0 · 원문 재저장 0 — 초안은 기기에 남는다).
  void hold({
    required SelfReportBalance wire,
    required String commandId,
    required String stateLabel,
    required RunMode runMode,
    required OperatingMode operatingMode,
    int? leaseEpoch,
  }) => _inbox(
    commandId: commandId,
    state: CommandState.heldForIntegrity,
    stateLabel: stateLabel,
    runMode: runMode,
    operatingMode: operatingMode,
    leaseEpoch: leaseEpoch,
    payloadDigest: selfReportPayloadDigestOf(wire),
  );

  void _inbox({
    required String commandId,
    required CommandState state,
    required String stateLabel,
    required RunMode runMode,
    required OperatingMode operatingMode,
    required int? leaseEpoch,
    required String payloadDigest,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?)',
    <Object?>[
      commandId,
      CommandKind.selfReportBalance.wire,
      _clock.nowUtc().toUtc().toIso8601String(),
      state.wire,
      stateLabel,
      runMode.wire,
      operatingMode.wire,
      leaseEpoch,
      payloadDigest,
    ],
  );
}
