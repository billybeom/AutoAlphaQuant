// 🆕 R280 — `M5-13` 원장 실사 «해소» 게이트 원장 원천(01 §8 미결 226 · 계약 v1.37 §46 K318~K322 · 엔진 = core
// `ops/self_audit_resolve.dart` · 설계 13 §8 R280).
//
// 🔴 플래그 = `trading_block` `ADVICE_LEDGER_UNVERIFIED` — 세우기 = [SqliteSelfAuditResolveSource.raiseUnverified](엔진 판정 ·
//    문턱 = 01 §8 미결 118 ⓐ 발주자 수치 대기 → 값 없음 = 발동 0) · 내리기 = 실사 기록 트랜잭션 안
//    ([releaseAdviceLedgerUnverifiedIn] — 대응 계좌 전부 발동 뒤 기준일 0오차) 하나뿐(수동 해제 0).
// 🔴 보관 묶음 = `command_inbox` `HELD_FOR_INTEGRITY`(접수 차례) · 일괄 확정 = 한 트랜잭션(판정 · 묶음 전부 → `RECEIVED`) · 버림 0.
// 🔴 미처리 갭 원천 = 원장 `advice`(만료 = 저장 `EXPIRED` 또는 마감이 지난 `OPEN` · `PARTIAL` — A4 파생 · 회수(`HANDOVER_CLOSED`) ·
//    `NO_ACTION` 제외) · 셈 = core.
// 🔴 읽기 = 부작용 0.

import 'package:core_engine/core_engine.dart'
    show
        AdviceWindow,
        ExchangeCalendar,
        LapsedAdvice,
        SelfAuditResolveTexts,
        StoredHeldCommand,
        StoredLedgerDiff,
        adviceLedgerUnverifiedRaiseOf,
        adviceLedgerUnverifiedReleaseOf,
        heldReviewIdOf,
        heldReviewRejectOf,
        kstDateText,
        kstMinuteText,
        selfAuditUnprocessedGapOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        CommandState,
        DiffStatus,
        FlagIds,
        LedgerPair,
        OperatingMode,
        TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database, ResultSet, Row;

import '../market/market_store.dart' show inLedgerTransaction;
import 'ledger_read_model.dart' show storedLedgerDiffs;
import 'self_report_source.dart' show latestZeroErrorByAccountIn;

/// 해소 게이트 낸 곳(`trading_block.cleared_by` 꼬리).
const String kSelfAuditResolveCheck = 'self_audit_resolve';

DateTime? _unverifiedSetAt(Database db) {
  final ResultSet r = db.select(
    'SELECT set_at FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.adviceLedgerUnverified],
  );
  return r.isEmpty ? null : DateTime.parse(r.first['set_at'] as String).toUtc();
}

/// 🔴 플래그 해제(K321 ④ · 부르는 쪽 트랜잭션 안 — 실사 기록) — 서 있고 대응 계좌 전부가 발동한 날(한국 날) 이후 기준일의 0오차
/// 실사를 가졌으면 내린다 · 내렸나.
bool releaseAdviceLedgerUnverifiedIn(
  Database db, {
  required List<String> accounts,
  required DateTime nowUtc,
}) {
  final DateTime? at = _unverifiedSetAt(db);
  if (at == null) return false;
  if (!adviceLedgerUnverifiedReleaseOf(
    flagSetDay: TradeDate(kstDateText(at)),
    accounts: accounts,
    latestZeroError: latestZeroErrorByAccountIn(db),
  )) {
    return false;
  }
  db.execute(
    'UPDATE trading_block SET cleared_at = ?, cleared_by = ? '
    'WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[
      nowUtc.toUtc().toIso8601String(),
      'auto:$kSelfAuditResolveCheck',
      FlagIds.adviceLedgerUnverified,
    ],
  );
  return true;
}

/// 일괄 확정 결과(사유 코드 null = 확정 · [confirmed] = 옮긴 건수).
class HeldReviewWrite {
  /// 만든다.
  const HeldReviewWrite({required this.code, required this.confirmed});

  /// 거부 사유(`HeldReviewResultCodes`) · null = 확정.
  final String? code;

  /// `RECEIVED` 로 옮긴 건수.
  final int confirmed;
}

/// `M5-13` 원장 원천.
class SqliteSelfAuditResolveSource {
  /// 만든다.
  SqliteSelfAuditResolveSource(this._db);

  final Database _db;

  /// 감시 표(VM 이 이 표들의 변화로 다시 선다 · 카운터는 시간만 흘러도 바뀐다 — 주기는 부르는 쪽).
  static const Set<String> watchedTables = <String>{
    'trading_block',
    'command_inbox',
    'ledger_diff',
    'self_report_balance',
    'advice',
  };

  /// `ADVICE_LEDGER_UNVERIFIED` 가 서 있으면 선 시각(UTC · 아니면 null).
  DateTime? unverifiedSetAt() => _unverifiedSetAt(_db);

  /// 원장 무결성 점검 중인가(`LEDGER_INTEGRITY` — 보관 확정 막힘).
  bool integrityActive() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 열린 `CANON_SELF_REPORT` 차이.
  List<StoredLedgerDiff> openSelfReportDiffs() => <StoredLedgerDiff>[
    for (final StoredLedgerDiff d in storedLedgerDiffs(_db))
      if (d.pair == LedgerPair.canonSelfReport && d.status == DiffStatus.open)
        d,
  ];

  /// 보관 묶음(`HELD_FOR_INTEGRITY` · 순서 = 엔진이 정한다).
  List<StoredHeldCommand> heldCommands() => <StoredHeldCommand>[
    for (final Row r in _db.select(
      'SELECT command_id, kind, ingested_at FROM command_inbox WHERE state = ?',
      <Object?>[CommandState.heldForIntegrity.wire],
    ))
      StoredHeldCommand(
        commandId: r['command_id'] as String,
        kind: r['kind'] as String,
        ingestedAtUtc: DateTime.parse(r['ingested_at'] as String).toUtc(),
      ),
  ];

  /// 계좌 → 가장 늦은 0오차 실사 기준일.
  Map<String, TradeDate> latestZeroError() => latestZeroErrorByAccountIn(_db);

  /// 계좌 → 마지막 정기 실사 기준일(실사 갭 원천 · R240 과 같은 표).
  Map<String, TradeDate> lastVerifiedByAccount() => <String, TradeDate>{
    for (final Row r in _db.select(
      'SELECT account_alias, MAX(as_of_trade_date) AS d FROM self_report_balance '
      'GROUP BY account_alias ORDER BY account_alias',
    ))
      r['account_alias'] as String: TradeDate(r['d'] as String),
  };

  /// 만료(미이행 · 미기록)로 닫힌 안내 — [today] = 신뢰 시각의 한국 날(마감이 지난 `OPEN` · `PARTIAL` = 만료 파생 · A4).
  List<LapsedAdvice> lapsedAdvices(TradeDate today) => <LapsedAdvice>[
    for (final Row r in _db.select(
      "SELECT valid_until_date, account_alias FROM advice WHERE kind <> 'NO_ACTION' "
      "AND COALESCE(close_reason_code, '') <> 'HANDOVER_CLOSED' "
      "AND (status = 'EXPIRED' OR (status IN ('OPEN', 'PARTIAL') AND valid_until_date < ?)) "
      'ORDER BY valid_until_date, advice_id',
      <Object?>[today.yyyyMmDd],
    ))
      LapsedAdvice(
        deadline: TradeDate(r['valid_until_date'] as String),
        accountAlias: r['account_alias'] as String?,
      ),
  ];

  /// 안내가 열린 창(발행일 ~ 마감 · `NO_ACTION` 제외).
  List<AdviceWindow> adviceWindows() => <AdviceWindow>[
    for (final Row r in _db.select(
      "SELECT trade_date, valid_until_date FROM advice WHERE kind <> 'NO_ACTION' "
      'ORDER BY trade_date, advice_id',
    ))
      AdviceWindow(
        from: TradeDate(r['trade_date'] as String),
        until: TradeDate(r['valid_until_date'] as String),
      ),
  ];

  /// 🔴 미처리 갭(거래일 · 엔진 셈) — [today] = 신뢰 시각의 한국 날 · 달력 밖 = null.
  int? unprocessedGap({
    required List<String> accounts,
    required TradeDate today,
    required ExchangeCalendar kr,
  }) => selfAuditUnprocessedGapOf(
    lapsed: lapsedAdvices(today),
    windows: adviceWindows(),
    latestZeroError: latestZeroError(),
    accounts: accounts,
    today: today,
    kr: kr,
  );

  /// 🔴 플래그 발동 맞춤(엔진 일정 · K321 ①) — 미처리 갭 ≥ 문턱이면 세운다 · 🔴 [thresholdTradingDays] = 01 §8 미결 118 ⓐ 발주자
  /// 수치 대기(값 없음 = 발동 0 — 엔진 기본값 0) · 세웠나.
  bool refreshUnverified({
    required OperatingMode operatingMode,
    required List<String> accounts,
    required DateTime trustedNowUtc,
    required ExchangeCalendar kr,
    required int? thresholdTradingDays,
  }) {
    final int? t = thresholdTradingDays;
    final int? gap = t == null
        ? null
        : unprocessedGap(
            accounts: accounts,
            today: TradeDate(kstDateText(trustedNowUtc)),
            kr: kr,
          );
    final bool raise = adviceLedgerUnverifiedRaiseOf(
      operatingMode: operatingMode,
      unprocessedGap: gap,
      thresholdTradingDays: t,
    );
    return raiseUnverified(
      raise: raise,
      nowUtc: trustedNowUtc,
      reason: raise ? SelfAuditResolveTexts.raiseReason(gap!, t!) : '',
    );
  }

  /// 🔴 플래그 발동(K321 ①) — [raise] = 엔진 판정(`adviceLedgerUnverifiedRaiseOf`) · 서 있지 않을 때만 세운다(선 시각 = [nowUtc]
  /// 신뢰 시각 · reason = 엔진 글자) · 세웠나.
  bool raiseUnverified({
    required bool raise,
    required DateTime nowUtc,
    required String reason,
  }) {
    if (!raise) return false;
    return inLedgerTransaction(_db, () {
      if (_unverifiedSetAt(_db) != null) return false;
      // PK = flag_id — 내려간 옛 행은 새로 서는 값으로 덮는다.
      _db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?) '
        'ON CONFLICT(flag_id) DO UPDATE SET set_at = excluded.set_at, '
        'reason = excluded.reason, origin_code = NULL, cleared_at = NULL, '
        'cleared_by = NULL, decision_id = NULL',
        <Object?>[
          FlagIds.adviceLedgerUnverified,
          nowUtc.toUtc().toIso8601String(),
          reason,
        ],
      );
      return true;
    });
  }

  /// 🔴 보관 명령 일괄 확정(K319 · 한 트랜잭션) — 판정 = 엔진(`heldReviewRejectOf` · 인자 꼴 → 무결성 점검 → 묶음 스냅숏) ·
  /// 확정 = 그 묶음 전부 `HELD_FOR_INTEGRITY` → `RECEIVED`(글자 = 엔진 · 확정 시각) · 거부 = 쓰기 0 · 버림 0.
  HeldReviewWrite confirmHeld({
    required Map<String, String> args,
    required DateTime nowUtc,
  }) => inLedgerTransaction(_db, () {
    final List<StoredHeldCommand> held = heldCommands();
    final String? code = heldReviewRejectOf(
      args: args,
      integrityActive: integrityActive(),
      currentReviewId: heldReviewIdOf(held),
    );
    if (code != null) return HeldReviewWrite(code: code, confirmed: 0);
    final String label = SelfAuditResolveTexts.confirmedState(
      kstMinuteText(nowUtc),
    );
    for (final StoredHeldCommand c in held) {
      _db.execute(
        'UPDATE command_inbox SET state = ?, state_label = ? WHERE command_id = ? AND state = ?',
        <Object?>[
          CommandState.received.wire,
          label,
          c.commandId,
          CommandState.heldForIntegrity.wire,
        ],
      );
      if (_db.updatedRows != 1) {
        throw StateError('보관 확정: ${c.commandId} 영향 행 ${_db.updatedRows}');
      }
    }
    return HeldReviewWrite(code: null, confirmed: held.length);
  });
}
