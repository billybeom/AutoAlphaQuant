// E11q-q6 — `L-3` 정기 실사 원장 원천(앱 계약 01 §21-4 · 02 §3-10 · 엔진 몫 = core `ops/self_report.dart`).
//
// 🔴 원장 수량(기준일) = 보유 화면과 같은 원천 — 지금 포지션(그 계좌에 묶인 전략 · KR) − 기준일 뒤 브로커 체결
//    (`krSignedFillsAfter` — 슬리브 기여 · 월간 리포트와 같은 «그날 보유» 규칙). 화면에 싣지 않는다(앵커링 금지).
// 🔴 기록 = 한 트랜잭션: `self_report_balance` 1 + `self_report_line` n + `ledger_diff`(CANON_SELF_REPORT · 수량 축 ·
//    OBSERVATIONAL) + `command_inbox`(EXECUTED · 엔진 글자) — 실패 = 전부 되돌림. 무결성 점검 중 = 보관 행만(B18).
// 🔴 그 달 그 계좌 실사 = 한 번(같은 기준일 · 같은 별칭 행이 있으면 [StateError] — 부르는 쪽이 세션으로 막는다).

import 'package:core_engine/core_engine.dart'
    show
        LedgerHolding,
        SelfReportDiffRow,
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
        LedgerAxis,
        LedgerPair,
        OperatingMode,
        RunMode,
        SelfReportBalance,
        SelfReportLine,
        SleeveId,
        TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

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
  bool integrityBroken() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 🔴 실사 기록(한 트랜잭션) — [diffs] = 엔진 대조 결과 · [stateLabel] = 엔진 접수증 글자 · 같은 기준일 · 계좌 실사가
  /// 이미 있으면 [StateError](쓰기 0).
  void record({
    required SelfReportBalance wire,
    required String commandId,
    required String deviceId,
    required DateTime reportedAtUtc,
    required List<SelfReportDiffRow> diffs,
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
        'cash_krw, declared_complete, device_id, command_id, reported_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
            LedgerAxis.quantity.wire,
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
