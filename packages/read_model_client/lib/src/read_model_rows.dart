// 🆕 E11-viewer-223(설계 13 §8 R250 · 01 §8 미결 223 ⓐ · 계약 v1.36 §45 K304 · K306 · K307 · K309) — 읽기 모델 행 → 계약 DTO.
//
// 🔴 규칙 = 계약 상수 `ReadModelTables` 하나(C-69 ⑥ 꼴): 행에서 그 결속 접두를 떼고 · 펼친 키는 다시 묶고 ·
//    제외 키에 뷰어 판 값을 넣어 `X.fromJson` 한 번. 열 이름 · 접두 · 제외 · 뷰어 판 값을 이 파일이 따로 적지 않는다.
// 🔴 못 읽으면 던진다(K206 뷰어 판) — 열이 없거나(키 부재) · 필수 칸 null · 형 틀림 · 모르는 와이어 값 =
//    [FormatException]. 빈 VM · 기본 글자 · 빈 목록으로 채우지 않는다. 버전 게이트는 이 예외를 `incompatible` 로
//    읽는다(미결 223 ⓔ · `readModelGateAfter`).
// 🔴 이 패키지는 `domain_contracts` 만 읽는다(core 0 · 축약 타입 0 — 01 §1-1 · tool/check_boundaries.sh [9]).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceInboxSummary,
        AdviceItem,
        AlertItem,
        AllocationEditorVm,
        AllocationReadModelColumns,
        BlindReviewCard,
        ContributionSetting,
        ContributionVm,
        DisclosureGateVm,
        DrawdownContextVm,
        ExecutionGapResult,
        FeatureFlags,
        HoldingRow,
        JournalRebalanceScope,
        LedgerDiffRow,
        LedgerTrustBadge,
        MonthlyReport,
        OpsDailySummary,
        OpsRhythmRow,
        PerfPoint,
        PerformanceSeries,
        ReadModelBinding,
        ReadModelColumn,
        ReadModelExclusion,
        ReadModelExtraColumn,
        ReadModelPushColumns,
        ReadModelTable,
        ReadModelTables,
        RebalanceEvent,
        ReportArchiveVm,
        SafetyState,
        SleeveAllocationVm,
        SleeveCatalogEntry,
        TradeJournalEntry,
        WatchdogBoardVm;

/// 읽기 모델 행 하나 — 열 이름 → 값(jsonb 열 = JSON 으로 풀린 값 · Supabase 행 그대로).
typedef ReadModelRow = Map<String, Object?>;

/// 펼친 결속(K306 · v1.28 K201)의 하위 객체 열 — 접두 포함 열 이름(정본 = 계약 상수).
/// 🔴 계약이 새 펼침을 더하면 여기에 없어서 [ReadModelReader.fromRow] 가 [StateError] 를 던진다(시험이 잡는다).
const Map<String, List<String>> _flattenColumns = <String, List<String>>{
  'AllocationProfileCard': <String>[
    AllocationReadModelColumns.label,
    AllocationReadModelColumns.weightsText,
    AllocationReadModelColumns.backtestText,
    AllocationReadModelColumns.honestNoteText,
  ],
};

/// 결속 하나가 읽는 열(표 상수 차례) — 접두 결속 = 그 접두 열 · 무접두 = DTO 밖 열 · 다른 접두 열을 뺀 나머지.
List<String> readModelBindingColumns(
  ReadModelTable table,
  ReadModelBinding binding,
) {
  final Set<String> extra = <String>{
    for (final ReadModelExtraColumn c in table.extraColumns) c.name,
  };
  final List<String> others = <String>[
    for (final ReadModelBinding b in table.bindings)
      if (!identical(b, binding) && b.prefix.isNotEmpty) b.prefix,
  ];
  return <String>[
    for (final ReadModelColumn c in table.columns)
      if (binding.prefix.isEmpty
          ? !extra.contains(c.name) && !others.any(c.name.startsWith)
          : c.name.startsWith(binding.prefix))
        c.name,
  ];
}

/// 행 → 그 결속의 DTO JSON(접두 떼기 · 펼친 키 다시 묶기 · 제외 키 = 뷰어 판 값 — C-69 ⑥ 꼴).
///
/// 🔴 결속 열이 행에 없으면(키 부재) [FormatException] — 값 null 은 여기서 판정하지 않는다(DTO `fromJson` 몫).
/// 🔵 무접두 결속은 규칙 5조 `mode` 칸을 DTO `mode` 키로도 넘긴다(DTO 에 그 키가 있는 결속 — 일지 · 회차 · 안전 상태).
Map<String, Object?> readModelBindingJson(
  ReadModelTable table,
  ReadModelBinding binding,
  ReadModelRow row,
) {
  final String where = '${table.name}(${binding.dto})';
  final Map<String, Object?> json = <String, Object?>{};
  for (final String col in readModelBindingColumns(table, binding)) {
    if (!row.containsKey(col)) {
      throw FormatException('$where: 열 $col 없음');
    }
    json[col.substring(binding.prefix.length)] = row[col];
  }
  if (binding.prefix.isEmpty) {
    final String mode = ReadModelPushColumns.mode.name;
    if (!row.containsKey(mode)) {
      throw FormatException('$where: 열 $mode 없음');
    }
    json[mode] = row[mode];
  }
  binding.flatten.forEach((String key, String sub) {
    final List<String>? cols = _flattenColumns[sub];
    if (cols == null) {
      throw StateError('$where: 펼침 $key($sub) — 뷰어가 모르는 펼침(계약 새 판)');
    }
    json[key] = <String, Object?>{
      for (final String c in cols)
        c.substring(binding.prefix.length): json.remove(
          c.substring(binding.prefix.length),
        ),
    };
  });
  for (final ReadModelExclusion e in binding.excluded) {
    json[e.key] = switch (e.viewerValue) {
      'null' => null,
      '[]' => <Object?>[],
      final String col => _sameRowColumn(where, row, col),
    };
  }
  return json;
}

Object? _sameRowColumn(String where, ReadModelRow row, String col) {
  if (!row.containsKey(col)) {
    throw FormatException('$where: 뷰어 판 값 열 $col 없음');
  }
  return row[col];
}

/// 결속 하나의 읽개 — 표 · DTO · `fromJson`.
final class ReadModelReader<T extends Object> {
  ReadModelReader._(this.table, this.dto, this._fromJson, this._toJson);

  /// 표.
  final ReadModelTable table;

  /// 계약 타입 이름(= [ReadModelBinding.dto]).
  final String dto;

  final T Function(Map<String, dynamic>) _fromJson;

  final Map<String, dynamic> Function(T) _toJson;

  /// 이 읽개의 결속(표 상수에서).
  ReadModelBinding get binding {
    for (final ReadModelBinding b in table.bindings) {
      if (b.dto == dto) return b;
    }
    throw StateError('${table.name}: 결속 $dto 없음');
  }

  /// 행 → DTO. 🔴 못 읽으면 [FormatException](빈 DTO · 기본 값 0).
  ///
  /// 🔴 null 칸이 DTO 기본 값(`@Default` — 빈 목록 등)으로 메워지면 그것도 못 읽음이다 — push 는 `toJson()` 값을
  ///    싣으므로 null 이 아닌 칸에 null 이 왔다 = 행이 계약 꼴이 아니다(«없음»을 «빈 것»으로 그리지 않는다).
  T fromRow(ReadModelRow row) {
    final String where = '${table.name}($dto)';
    final ReadModelBinding b = binding;
    final Map<String, Object?> json = readModelBindingJson(table, b, row);
    final T v = decodeReadModelJson(where, json, _fromJson);
    final Set<String> excluded = <String>{
      for (final ReadModelExclusion e in b.excluded) e.key,
    };
    final Map<String, dynamic> back = _toJson(v);
    for (final MapEntry<String, Object?> e in json.entries) {
      if (excluded.contains(e.key)) continue;
      _rejectFilled(where, e.key, e.value, back[e.key]);
    }
    return v;
  }
}

void _rejectFilled(String where, String key, Object? given, Object? back) {
  if (given == null && back != null) {
    throw FormatException('$where: $key null → 기본 값으로 메워짐(못 읽음)');
  }
  if (given is Map<String, Object?> && back is Map<String, Object?>) {
    for (final MapEntry<String, Object?> e in given.entries) {
      if (e.value == null && back[e.key] != null) {
        throw FormatException('$where: $key.${e.key} null → 기본 값으로 메워짐(못 읽음)');
      }
    }
  }
}

/// `fromJson` 한 번 — 형 오류 · 모르는 와이어 값 · 필수 칸 null 을 [FormatException] 하나로 바꿔 낸다.
T decodeReadModelJson<T>(
  String where,
  Map<String, Object?> json,
  T Function(Map<String, dynamic>) fromJson,
) {
  try {
    return fromJson(json);
  } on FormatException catch (e) {
    throw FormatException('$where: ${e.message}');
  } on Object catch (e) {
    // 🔴 json_serializable 은 꼴이 틀리면 형 오류 · ArgumentError 를 낸다 — 이 패키지의 약속(FormatException 하나)으로.
    throw FormatException('$where: 꼴 아님($e)');
  }
}

/// 22표의 결속 읽개 전부(계약 v1.36 · 결속 25 — `rm_list_envelope` 는 결속 0 → `list_envelope.dart`).
abstract final class ReadModelReaders {
  /// `rm_journal` — `TradeJournalEntry`.
  static final ReadModelReader<TradeJournalEntry> journalEntry =
      ReadModelReader<TradeJournalEntry>._(
        ReadModelTables.journal,
        'TradeJournalEntry',
        TradeJournalEntry.fromJson,
        (TradeJournalEntry v) => v.toJson(),
      );

  /// `rm_holding` — `HoldingRow`(`pnl` = null · K15).
  static final ReadModelReader<HoldingRow> holding =
      ReadModelReader<HoldingRow>._(
        ReadModelTables.holding,
        'HoldingRow',
        HoldingRow.fromJson,
        (HoldingRow v) => v.toJson(),
      );

  /// `rm_performance_point` — `PerfPoint`.
  static final ReadModelReader<PerfPoint> perfPoint =
      ReadModelReader<PerfPoint>._(
        ReadModelTables.performancePoint,
        'PerfPoint',
        PerfPoint.fromJson,
        (PerfPoint v) => v.toJson(),
      );

  /// `rm_performance_series` — `PerformanceSeries`(`points` = [] · 점은 [performanceSeriesOfRows]).
  static final ReadModelReader<PerformanceSeries> performanceSeries =
      ReadModelReader<PerformanceSeries>._(
        ReadModelTables.performanceSeries,
        'PerformanceSeries',
        PerformanceSeries.fromJson,
        (PerformanceSeries v) => v.toJson(),
      );

  /// `rm_rebalance_event` — `RebalanceEvent`.
  static final ReadModelReader<RebalanceEvent> rebalanceEvent =
      ReadModelReader<RebalanceEvent>._(
        ReadModelTables.rebalanceEvent,
        'RebalanceEvent',
        RebalanceEvent.fromJson,
        (RebalanceEvent v) => v.toJson(),
      );

  /// `rm_rebalance_event` `scope_` — `JournalRebalanceScope`(`rebalance_event_id` = `event_id` 열).
  static final ReadModelReader<JournalRebalanceScope> rebalanceScope =
      ReadModelReader<JournalRebalanceScope>._(
        ReadModelTables.rebalanceEvent,
        'JournalRebalanceScope',
        JournalRebalanceScope.fromJson,
        (JournalRebalanceScope v) => v.toJson(),
      );

  /// `rm_alert` — `AlertItem`.
  static final ReadModelReader<AlertItem> alert = ReadModelReader<AlertItem>._(
    ReadModelTables.alert,
    'AlertItem',
    AlertItem.fromJson,
    (AlertItem v) => v.toJson(),
  );

  /// `rm_safety_state` — `SafetyState`.
  static final ReadModelReader<SafetyState> safetyState =
      ReadModelReader<SafetyState>._(
        ReadModelTables.safetyState,
        'SafetyState',
        SafetyState.fromJson,
        (SafetyState v) => v.toJson(),
      );

  /// `rm_config_view` — `FeatureFlags`.
  static final ReadModelReader<FeatureFlags> featureFlags =
      ReadModelReader<FeatureFlags>._(
        ReadModelTables.configView,
        'FeatureFlags',
        FeatureFlags.fromJson,
        (FeatureFlags v) => v.toJson(),
      );

  /// `rm_config_view` `contribution_` — `ContributionSetting`(G-44).
  static final ReadModelReader<ContributionSetting> contributionSetting =
      ReadModelReader<ContributionSetting>._(
        ReadModelTables.configView,
        'ContributionSetting',
        ContributionSetting.fromJson,
        (ContributionSetting v) => v.toJson(),
      );

  /// `rm_config_view` `allocation_` — `AllocationEditorVm`(`current` 펼침 · v1.28 7열).
  static final ReadModelReader<AllocationEditorVm> allocationEditor =
      ReadModelReader<AllocationEditorVm>._(
        ReadModelTables.configView,
        'AllocationEditorVm',
        AllocationEditorVm.fromJson,
        (AllocationEditorVm v) => v.toJson(),
      );

  /// `rm_advice` — `AdviceItem`(A6 10 = 뷰어 판 null · `actions` = []).
  static final ReadModelReader<AdviceItem> advice =
      ReadModelReader<AdviceItem>._(
        ReadModelTables.advice,
        'AdviceItem',
        AdviceItem.fromJson,
        (AdviceItem v) => v.toJson(),
      );

  /// `rm_advice_summary` — `AdviceInboxSummary`(수기 입력 2 = null).
  static final ReadModelReader<AdviceInboxSummary> adviceSummary =
      ReadModelReader<AdviceInboxSummary>._(
        ReadModelTables.adviceSummary,
        'AdviceInboxSummary',
        AdviceInboxSummary.fromJson,
        (AdviceInboxSummary v) => v.toJson(),
      );

  /// `rm_monthly_report` — `MonthlyReport`.
  static final ReadModelReader<MonthlyReport> monthlyReport =
      ReadModelReader<MonthlyReport>._(
        ReadModelTables.monthlyReport,
        'MonthlyReport',
        MonthlyReport.fromJson,
        (MonthlyReport v) => v.toJson(),
      );

  /// `rm_report_archive` — `ReportArchiveVm`(모드별 1행).
  static final ReadModelReader<ReportArchiveVm> reportArchive =
      ReadModelReader<ReportArchiveVm>._(
        ReadModelTables.reportArchive,
        'ReportArchiveVm',
        ReportArchiveVm.fromJson,
        (ReportArchiveVm v) => v.toJson(),
      );

  /// `rm_ledger_diff` — `LedgerDiffRow`(`action_link` = null).
  static final ReadModelReader<LedgerDiffRow> ledgerDiff =
      ReadModelReader<LedgerDiffRow>._(
        ReadModelTables.ledgerDiff,
        'LedgerDiffRow',
        LedgerDiffRow.fromJson,
        (LedgerDiffRow v) => v.toJson(),
      );

  /// `rm_sleeve_allocation` — `SleeveAllocationVm`(금액 칸 = 엔진 가림 글자 · K309).
  static final ReadModelReader<SleeveAllocationVm> sleeveAllocation =
      ReadModelReader<SleeveAllocationVm>._(
        ReadModelTables.sleeveAllocation,
        'SleeveAllocationVm',
        SleeveAllocationVm.fromJson,
        (SleeveAllocationVm v) => v.toJson(),
      );

  /// `rm_perf_context` `drawdown_` — `DrawdownContextVm`.
  static final ReadModelReader<DrawdownContextVm> drawdownContext =
      ReadModelReader<DrawdownContextVm>._(
        ReadModelTables.perfContext,
        'DrawdownContextVm',
        DrawdownContextVm.fromJson,
        (DrawdownContextVm v) => v.toJson(),
      );

  /// `rm_perf_context` `contribution_` — `ContributionVm`.
  static final ReadModelReader<ContributionVm> contribution =
      ReadModelReader<ContributionVm>._(
        ReadModelTables.perfContext,
        'ContributionVm',
        ContributionVm.fromJson,
        (ContributionVm v) => v.toJson(),
      );

  /// `rm_disclosure_view` — `DisclosureGateVm`(모드별 1행).
  static final ReadModelReader<DisclosureGateVm> disclosureGate =
      ReadModelReader<DisclosureGateVm>._(
        ReadModelTables.disclosureView,
        'DisclosureGateVm',
        DisclosureGateVm.fromJson,
        (DisclosureGateVm v) => v.toJson(),
      );

  /// `rm_ops_summary` — `OpsDailySummary`.
  static final ReadModelReader<OpsDailySummary> opsDailySummary =
      ReadModelReader<OpsDailySummary>._(
        ReadModelTables.opsSummary,
        'OpsDailySummary',
        OpsDailySummary.fromJson,
        (OpsDailySummary v) => v.toJson(),
      );

  /// `rm_ledger_trust` — `LedgerTrustBadge`.
  static final ReadModelReader<LedgerTrustBadge> ledgerTrust =
      ReadModelReader<LedgerTrustBadge>._(
        ReadModelTables.ledgerTrust,
        'LedgerTrustBadge',
        LedgerTrustBadge.fromJson,
        (LedgerTrustBadge v) => v.toJson(),
      );

  /// `rm_execution_gap` — `ExecutionGapResult`.
  static final ReadModelReader<ExecutionGapResult> executionGap =
      ReadModelReader<ExecutionGapResult>._(
        ReadModelTables.executionGap,
        'ExecutionGapResult',
        ExecutionGapResult.fromJson,
        (ExecutionGapResult v) => v.toJson(),
      );

  /// `rm_blind_review` — `BlindReviewCard`.
  static final ReadModelReader<BlindReviewCard> blindReview =
      ReadModelReader<BlindReviewCard>._(
        ReadModelTables.blindReview,
        'BlindReviewCard',
        BlindReviewCard.fromJson,
        (BlindReviewCard v) => v.toJson(),
      );

  /// `rm_watchdog` — `WatchdogBoardVm`(모드별 1행 · K313).
  static final ReadModelReader<WatchdogBoardVm> watchdog =
      ReadModelReader<WatchdogBoardVm>._(
        ReadModelTables.watchdog,
        'WatchdogBoardVm',
        WatchdogBoardVm.fromJson,
        (WatchdogBoardVm v) => v.toJson(),
      );

  /// 전부(표 상수 차례 → 결속 차례).
  static final List<ReadModelReader<Object>> all = <ReadModelReader<Object>>[
    journalEntry,
    holding,
    perfPoint,
    performanceSeries,
    rebalanceEvent,
    rebalanceScope,
    alert,
    safetyState,
    featureFlags,
    contributionSetting,
    allocationEditor,
    advice,
    adviceSummary,
    monthlyReport,
    reportArchive,
    ledgerDiff,
    sleeveAllocation,
    drawdownContext,
    contribution,
    disclosureGate,
    opsDailySummary,
    ledgerTrust,
    executionGap,
    blindReview,
    watchdog,
  ];
}

/// `rm_performance_series` 한 행 + 그 시리즈의 `rm_performance_point` 행 → `PerformanceSeries`.
///
/// 🔴 점 = 그 시리즈 행(`metric` · `granularity` · `cumulative` 같음 — 다르면 [FormatException]) · `date` 오름차순
///    (계약 제외 사유 «date 오름차순 · 뷰어가 다시 정규화하지 않는다») · 결측 점(`value` null)도 행 그대로(K312).
PerformanceSeries performanceSeriesOfRows(
  ReadModelRow seriesRow,
  List<ReadModelRow> pointRows,
) {
  final PerformanceSeries head = ReadModelReaders.performanceSeries.fromRow(
    seriesRow,
  );
  const List<String> key = <String>['metric', 'granularity', 'cumulative'];
  final List<(String, PerfPoint)> points = <(String, PerfPoint)>[];
  for (final ReadModelRow p in pointRows) {
    for (final String k in key) {
      if (p[k] != seriesRow[k]) {
        throw FormatException(
          '${ReadModelTables.performancePoint.name}: $k ${p[k]} ≠ 시리즈 ${seriesRow[k]}',
        );
      }
    }
    final Object? date = p['date'];
    if (date is! String) {
      throw FormatException(
        '${ReadModelTables.performancePoint.name}: date 글자 아님',
      );
    }
    points.add((date, ReadModelReaders.perfPoint.fromRow(p)));
  }
  points.sort(
    ((String, PerfPoint) a, (String, PerfPoint) b) => a.$1.compareTo(b.$1),
  );
  return head.copyWith(
    points: <PerfPoint>[for (final (String, PerfPoint) p in points) p.$2],
  );
}

/// `rm_config_view.sleeve_catalog`(DTO 밖 열 · K308) → `ConfigRepository.watchSleeves` 목록(받은 순서).
List<SleeveCatalogEntry> sleeveCatalogOfRow(ReadModelRow row) =>
    _jsonList<SleeveCatalogEntry>(
      ReadModelTables.configView.name,
      row,
      'sleeve_catalog',
      SleeveCatalogEntry.fromJson,
      (SleeveCatalogEntry v) => v.toJson(),
    );

/// `rm_ops_summary.rhythm`(DTO 밖 열 · K308) → `watchRhythm` 행 목록(받은 순서 = 표 순서).
List<OpsRhythmRow> opsRhythmOfRow(ReadModelRow row) => _jsonList<OpsRhythmRow>(
  ReadModelTables.opsSummary.name,
  row,
  'rhythm',
  OpsRhythmRow.fromJson,
  (OpsRhythmRow v) => v.toJson(),
);

List<T> _jsonList<T>(
  String table,
  ReadModelRow row,
  String col,
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(T) toJson,
) {
  if (!row.containsKey(col)) {
    throw FormatException('$table: 열 $col 없음');
  }
  final Object? v = row[col];
  if (v is! List<Object?>) {
    throw FormatException('$table: $col 목록 아님');
  }
  final List<T> out = <T>[];
  for (final (int i, Object? e) in v.indexed) {
    if (e is! Map<String, Object?>) {
      throw FormatException('$table: $col[$i] 객체 아님');
    }
    final String where = '$table.$col[$i]';
    final T d = decodeReadModelJson(where, e, fromJson);
    final Map<String, dynamic> back = toJson(d);
    for (final MapEntry<String, Object?> f in e.entries) {
      _rejectFilled(where, f.key, f.value, back[f.key]);
    }
    out.add(d);
  }
  return out;
}
