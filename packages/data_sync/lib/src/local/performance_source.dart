// 🆕 E11q-q5b — M7 `S7-2` 성과 탐색 시리즈 · `S7-2G` 열람 게이트 · 열람 기록의 원장 원천(설계 13 §8 R223).
//
// 🔴 시리즈 = 계층 B · 월간 리포트와 같은 점(`tierBSeries` — 개시 뒤 마감 스냅숏 + 그 사이 입출금) → 엔진 `performanceSeriesOf`.
// 🔴 무결성 가림 = `LEDGER_INTEGRITY` 깃발(풀리지 않은 차단) — 보유 · 일지와 같은 판정.
// 🔴 열람 기록 = `command_inbox` 한 행(kind `DISCLOSURE_VIEW` · append-only · 지문만) · 집계 = 접수 시각의 한국 달(G-42 —
//    화면이 넣은 `viewedAt` 아님) · 무결성 점검 중 = «보류됨» 행(보관 — 열람은 일어났다 · 집계에 든다).

import 'package:core_engine/core_engine.dart'
    show
        DisclosureViewCommand,
        EquityPoint,
        disclosureGateVmOf,
        disclosureMonthOf,
        kstDateText,
        performanceSeriesOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        CommandKind,
        CommandReceipt,
        DisclosureGateVm,
        FlagIds,
        OperatingMode,
        PerfGranularity,
        PerfMetric,
        PerformanceSeries,
        RunMode;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

import '../jobs/tier_b_step.dart' show tierBSeries;

/// 성과 탐색 · 열람 게이트 원천(같은 원장 한 파일).
class SqlitePerformanceSource {
  /// 만든다.
  SqlitePerformanceSource(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 시리즈 · 게이트가 읽는 표(원장 변경 감시).
  static const Set<String> watchedTables = <String>{
    'equity_snapshot',
    'cash_flow',
    'decision_log',
    'command_inbox',
    'trading_block',
  };

  /// 개시 뒤 마감 스냅숏(오늘까지).
  List<EquityPoint> equity(String today) => tierBSeries(_db, today);

  /// 원장 무결성 점검 중인가.
  bool integrityHidden() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// [yyyyMm](한국 달) 열람 기록 수 — 접수 시각 기준.
  int disclosureViews(String yyyyMm) {
    int n = 0;
    for (final Row r in _db.select(
      'SELECT ingested_at FROM command_inbox WHERE kind = ?',
      <Object?>[CommandKind.disclosureView.wire],
    )) {
      final DateTime? at = DateTime.tryParse(r['ingested_at'] as String);
      if (at != null && disclosureMonthOf(at.toUtc()) == yyyyMm) n++;
    }
    return n;
  }

  /// `S7-2G` 게이트.
  DisclosureGateVm gate() {
    final DateTime now = _clock.nowUtc();
    return disclosureGateVmOf(
      viewCountThisMonth: disclosureViews(disclosureMonthOf(now)),
      integrityHidden: integrityHidden(),
      nowUtc: now,
    );
  }

  /// `S7-2` 시리즈 — [isSession] = 한국 세션.
  PerformanceSeries series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required bool Function(String ymd) isSession,
  }) {
    final DateTime now = _clock.nowUtc();
    return performanceSeriesOf(
      metric: metric,
      granularity: granularity,
      cumulative: cumulative,
      equity: equity(kstDateText(now)),
      isSession: isSession,
      nowUtc: now,
      viewCountThisMonth: disclosureViews(disclosureMonthOf(now)),
      integrityHidden: integrityHidden(),
    );
  }

  /// 열람 기록 한 행 — 무결성 점검 중 = 보류(보관) · 그 밖 = 기록됨 · 접수증 글자 = 남긴 글자 그대로.
  CommandReceipt record(
    DisclosureViewCommand c, {
    required RunMode runMode,
    required OperatingMode operatingMode,
    int? leaseEpoch,
  }) {
    final CommandReceipt receipt = c.receipt(held: integrityHidden());
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      'VALUES (?, ?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?)',
      <Object?>[
        c.commandId,
        CommandKind.disclosureView.wire,
        _clock.nowUtc().toUtc().toIso8601String(),
        receipt.state.wire,
        receipt.stateLabel,
        runMode.wire,
        operatingMode.wire,
        leaseEpoch,
        c.payloadDigest,
      ],
    );
    return receipt;
  }
}
