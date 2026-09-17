// 픽스처 ↔ 뷰모델 등록부 — C-1(역직렬화)·C-8(JSON 라운드트립)의 공용 입력.
//
// 🔴 **등록부가 정본이 아니다.** 정본은 01 §5 픽스처 목록과 §2 DTO 이며, 이 파일은
//    「어느 봉투의 행이 어느 타입인가」를 한 곳에 모아 두 검사가 같은 것을 보게 한다.
// 🔴 매핑이 **없는** 픽스처는 지우지 않고 [unmappedFixtures] 에 **사유와 함께** 남긴다 —
//    조용히 빠지면 「검사했는데 입력이 없었다」가 된다(01 §5 · C-26 의 교훈).
// 🔴 픽스처를 새로 넣으면 C-1 이 «등록부에 없다»로 실패한다. 그것이 의도다.

import 'package:domain_contracts/domain_contracts.dart';

/// 한 타입의 `fromJson`/`toJson` 짝.
///
/// 🔴 `dynamic` 호출을 쓰지 않기 위한 상자다(루트 lint `avoid_dynamic_calls`).
class DtoCodec<T extends Object> {
  const DtoCodec(this.typeName, this._from, this._to);

  /// 계약 타입 이름(실패 메시지·C-8 인구조사에 쓴다).
  final String typeName;

  final T Function(Map<String, dynamic>) _from;
  final Map<String, dynamic> Function(T) _to;

  /// JSON → DTO.
  Object decode(Map<String, Object?> json) => _from(json);

  /// DTO → JSON.
  Map<String, dynamic> encode(Object value) => _to(value as T);
}

/// 픽스처 한 건의 등록 내용.
class FixtureBinding {
  const FixtureBinding(
    this.rows, {
    this.extras = const <String, DtoCodec<Object>>{},
  });

  /// `rows` 원소의 타입.
  final DtoCodec<Object> rows;

  /// 봉투에 얹힌 추가 블록(예: 안내함의 `summary`).
  final Map<String, DtoCodec<Object>> extras;
}

/// 봉투 밖 추가 블록의 표준 이름 — 안내 목록의 요약(01 §2-11 `AdviceInboxSummary`).
const String adviceSummaryKey = 'summary';

final DtoCodec<Object> _adviceItem = DtoCodec<AdviceItem>(
  'AdviceItem',
  AdviceItem.fromJson,
  (AdviceItem v) => v.toJson(),
);
final DtoCodec<Object> _adviceInboxSummary = DtoCodec<AdviceInboxSummary>(
  'AdviceInboxSummary',
  AdviceInboxSummary.fromJson,
  (AdviceInboxSummary v) => v.toJson(),
);
final DtoCodec<Object> _alertItem = DtoCodec<AlertItem>(
  'AlertItem',
  AlertItem.fromJson,
  (AlertItem v) => v.toJson(),
);
final DtoCodec<Object> _depositPlan = DtoCodec<DepositPlan>(
  'DepositPlan',
  DepositPlan.fromJson,
  (DepositPlan v) => v.toJson(),
);
final DtoCodec<Object> _onboardingStep = DtoCodec<OnboardingStep>(
  'OnboardingStep',
  OnboardingStep.fromJson,
  (OnboardingStep v) => v.toJson(),
);
final DtoCodec<Object> _performanceSeries = DtoCodec<PerformanceSeries>(
  'PerformanceSeries',
  PerformanceSeries.fromJson,
  (PerformanceSeries v) => v.toJson(),
);
final DtoCodec<Object> _rebalanceEvent = DtoCodec<RebalanceEvent>(
  'RebalanceEvent',
  RebalanceEvent.fromJson,
  (RebalanceEvent v) => v.toJson(),
);
final DtoCodec<Object> _tradeJournalEntry = DtoCodec<TradeJournalEntry>(
  'TradeJournalEntry',
  TradeJournalEntry.fromJson,
  (TradeJournalEntry v) => v.toJson(),
);
final DtoCodec<Object> _executionGapReport = DtoCodec<ExecutionGapReport>(
  'ExecutionGapReport',
  ExecutionGapReport.fromJson,
  (ExecutionGapReport v) => v.toJson(),
);
final DtoCodec<Object> _monthlyReport = DtoCodec<MonthlyReport>(
  'MonthlyReport',
  MonthlyReport.fromJson,
  (MonthlyReport v) => v.toJson(),
);
final DtoCodec<Object> _withdrawalPlan = DtoCodec<WithdrawalPlan>(
  'WithdrawalPlan',
  WithdrawalPlan.fromJson,
  (WithdrawalPlan v) => v.toJson(),
);
final DtoCodec<Object> _opsDailySummary = DtoCodec<OpsDailySummary>(
  'OpsDailySummary',
  OpsDailySummary.fromJson,
  (OpsDailySummary v) => v.toJson(),
);
final DtoCodec<Object> _watchdogCheck = DtoCodec<WatchdogCheck>(
  'WatchdogCheck',
  WatchdogCheck.fromJson,
  (WatchdogCheck v) => v.toJson(),
);
final DtoCodec<Object> _manualFillFormSpec = DtoCodec<ManualFillFormSpec>(
  'ManualFillFormSpec',
  ManualFillFormSpec.fromJson,
  (ManualFillFormSpec v) => v.toJson(),
);
final DtoCodec<Object> _annualReviewVm = DtoCodec<AnnualReviewVm>(
  'AnnualReviewVm',
  AnnualReviewVm.fromJson,
  (AnnualReviewVm v) => v.toJson(),
);
final DtoCodec<Object> _drawdownContextVm = DtoCodec<DrawdownContextVm>(
  'DrawdownContextVm',
  DrawdownContextVm.fromJson,
  (DrawdownContextVm v) => v.toJson(),
);
final DtoCodec<Object> _contributionVm = DtoCodec<ContributionVm>(
  'ContributionVm',
  ContributionVm.fromJson,
  (ContributionVm v) => v.toJson(),
);
final DtoCodec<Object> _decisionDetailVm = DtoCodec<DecisionDetailVm>(
  'DecisionDetailVm',
  DecisionDetailVm.fromJson,
  (DecisionDetailVm v) => v.toJson(),
);
final DtoCodec<Object> _journalDraftFormSpec = DtoCodec<JournalDraftFormSpec>(
  'JournalDraftFormSpec',
  JournalDraftFormSpec.fromJson,
  (JournalDraftFormSpec v) => v.toJson(),
);
final DtoCodec<Object> _unknownBoardVm = DtoCodec<UnknownBoardVm>(
  'UnknownBoardVm',
  UnknownBoardVm.fromJson,
  (UnknownBoardVm v) => v.toJson(),
);
final DtoCodec<Object> _goalPathVm = DtoCodec<GoalPathVm>(
  'GoalPathVm',
  GoalPathVm.fromJson,
  (GoalPathVm v) => v.toJson(),
);

/// 픽스처 상대 경로 → 등록 내용.
///
/// 🔴 키는 `FixturePaths` 상수를 그대로 쓴다 — 문자열을 두 번 적지 않는다(01 §5).
final Map<String, FixtureBinding> fixtureBindings = <String, FixtureBinding>{
  // ── 계약 코어(인벤토리 §8-2) ──────────────────────────────────────────────
  FixturePaths.alerts12: FixtureBinding(_alertItem),
  FixturePaths.depositPlan1: FixtureBinding(_depositPlan),
  FixturePaths.depositPlanFunding1: FixtureBinding(_depositPlan),
  FixturePaths.holdings6: FixtureBinding(
    DtoCodec<HoldingRow>(
      'HoldingRow',
      HoldingRow.fromJson,
      (HoldingRow v) => v.toJson(),
    ),
  ),
  FixturePaths.journal30: FixtureBinding(_tradeJournalEntry),
  FixturePaths.ledgerDiffs4: FixtureBinding(
    DtoCodec<LedgerDiffRow>(
      'LedgerDiffRow',
      LedgerDiffRow.fromJson,
      (LedgerDiffRow v) => v.toJson(),
    ),
  ),
  FixturePaths.onboardingFresh: FixtureBinding(_onboardingStep),
  FixturePaths.onboardingReconnect: FixtureBinding(_onboardingStep),
  FixturePaths.performance24m: FixtureBinding(_performanceSeries),
  // 🆕 v1.1 — 구간 프리셋(§8 미결 33 `isDefault`).
  FixturePaths.rangePresets4: FixtureBinding(
    DtoCodec<DateRange>(
      'DateRange',
      DateRange.fromJson,
      (DateRange v) => v.toJson(),
    ),
  ),
  FixturePaths.rebalance6: FixtureBinding(_rebalanceEvent),
  FixturePaths.resumeReport1: FixtureBinding(
    DtoCodec<ResumeReport>(
      'ResumeReport',
      ResumeReport.fromJson,
      (ResumeReport v) => v.toJson(),
    ),
  ),
  FixturePaths.safetyStates: FixtureBinding(
    DtoCodec<SafetyState>(
      'SafetyState',
      SafetyState.fromJson,
      (SafetyState v) => v.toJson(),
    ),
  ),
  // 🆕 v1.1 — 슬리브 카탈로그(01 §2-1 — 목록의 유일한 창구).
  FixturePaths.sleeveCatalog4: FixtureBinding(
    DtoCodec<SleeveCatalogEntry>(
      'SleeveCatalogEntry',
      SleeveCatalogEntry.fromJson,
      (SleeveCatalogEntry v) => v.toJson(),
    ),
  ),

  // ── m6/ — 안내·수기 체결(01 §2-11) ───────────────────────────────────────
  FixturePaths.m6Advice12: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceBlocked: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceDetailOnhold: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceDetailPartial: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceEmpty: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceExpiredConfirm: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceHandoverCooling: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceNoAction: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceViewer4: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceSkipReasons: FixtureBinding(
    DtoCodec<ReasonOption>(
      'ReasonOption',
      ReasonOption.fromJson,
      (ReasonOption v) => v.toJson(),
    ),
  ),
  FixturePaths.m6ExternalHoldings2: FixtureBinding(
    DtoCodec<ExternalHoldingRow>(
      'ExternalHoldingRow',
      ExternalHoldingRow.fromJson,
      (ExternalHoldingRow v) => v.toJson(),
    ),
  ),
  FixturePaths.m6FillFormSpec: FixtureBinding(_manualFillFormSpec),
  FixturePaths.m6FillFormSpecStale: FixtureBinding(_manualFillFormSpec),
  FixturePaths.m6FillRejectedPrice: FixtureBinding(
    DtoCodec<CommandReceipt>(
      'CommandReceipt',
      CommandReceipt.fromJson,
      (CommandReceipt v) => v.toJson(),
    ),
  ),
  // 🆕 v1.1 — J-2 거래 상세 6갈래 · J-1 배지·필터·가림 · J-3 폼 스펙 · J-5 보드.
  FixturePaths.m6DecisionDetailAmended: FixtureBinding(_decisionDetailVm),
  FixturePaths.m6DecisionDetailFull: FixtureBinding(_decisionDetailVm),
  FixturePaths.m6DecisionDetailPartial: FixtureBinding(_decisionDetailVm),
  FixturePaths.m6DecisionDetailReevaluatedChild: FixtureBinding(
    _decisionDetailVm,
  ),
  FixturePaths.m6DecisionDetailRejectedSaf309: FixtureBinding(
    _decisionDetailVm,
  ),
  FixturePaths.m6DecisionDetailUnknown: FixtureBinding(_decisionDetailVm),
  FixturePaths.m6JournalBadges2: FixtureBinding(
    DtoCodec<JournalTimelineBadge>(
      'JournalTimelineBadge',
      JournalTimelineBadge.fromJson,
      (JournalTimelineBadge v) => v.toJson(),
    ),
  ),
  FixturePaths.m6JournalDraftSpecDiscretion: FixtureBinding(
    _journalDraftFormSpec,
  ),
  FixturePaths.m6JournalDraftSpecReconClear: FixtureBinding(
    _journalDraftFormSpec,
  ),
  FixturePaths.m6JournalFilterCatalog: FixtureBinding(
    DtoCodec<JournalFilterCatalog>(
      'JournalFilterCatalog',
      JournalFilterCatalog.fromJson,
      (JournalFilterCatalog v) => v.toJson(),
    ),
  ),
  FixturePaths.m6JournalMaskedIntegrity: FixtureBinding(_tradeJournalEntry),
  FixturePaths.m6UnknownBoard2: FixtureBinding(_unknownBoardVm),
  FixturePaths.m6UnknownBoardEmpty: FixtureBinding(_unknownBoardVm),
  // 🆕 2026-09-17 — 0행이지만 봉투 타입은 같다(C-1 은 빈 rows 도 등록부를 요구한다).
  FixturePaths.m6JournalEmpty: FixtureBinding(_tradeJournalEntry),
  FixturePaths.m6ManualFills8: FixtureBinding(_tradeJournalEntry),

  // ── m7/ — 성과·플래너·이행 갭 ────────────────────────────────────────────
  FixturePaths.m7AftertaxLadder1: FixtureBinding(
    DtoCodec<AfterTaxLadder>(
      'AfterTaxLadder',
      AfterTaxLadder.fromJson,
      (AfterTaxLadder v) => v.toJson(),
    ),
  ),
  FixturePaths.m7ExecutionGap1: FixtureBinding(_executionGapReport),
  FixturePaths.m7ExecutionGapCant: FixtureBinding(_executionGapReport),
  FixturePaths.m7ExecutionGapMixed: FixtureBinding(_executionGapReport),
  FixturePaths.m7ExecutionGapWont: FixtureBinding(_executionGapReport),
  FixturePaths.m7LedgerTrust4: FixtureBinding(
    DtoCodec<LedgerTrustBadge>(
      'LedgerTrustBadge',
      LedgerTrustBadge.fromJson,
      (LedgerTrustBadge v) => v.toJson(),
    ),
  ),
  FixturePaths.m7M7Annual2026: FixtureBinding(_annualReviewVm),
  FixturePaths.m7M7AnnualFirstYear: FixtureBinding(_annualReviewVm),
  FixturePaths.m7M7Contrib3sleeve: FixtureBinding(_contributionVm),
  FixturePaths.m7M7ContribPartial: FixtureBinding(_contributionVm),
  FixturePaths.m7M7DdContextDeep: FixtureBinding(_drawdownContextVm),
  FixturePaths.m7M7DdContextNormal: FixtureBinding(_drawdownContextVm),
  FixturePaths.m7M7DepositPlanDefault: FixtureBinding(_depositPlan),
  FixturePaths.m7M7DepositPlanExpired: FixtureBinding(_depositPlan),
  FixturePaths.m7M7DepositPlanLimit: FixtureBinding(_depositPlan),
  FixturePaths.m7M7DisclosureGate: FixtureBinding(
    DtoCodec<DisclosureGateVm>(
      'DisclosureGateVm',
      DisclosureGateVm.fromJson,
      (DisclosureGateVm v) => v.toJson(),
    ),
  ),
  FixturePaths.m7M7GoalPathHold: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7GoalPathOn: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7GoalPathRealworld: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7Monthly202608: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyGap: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyMaskedIntegrity: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyMaskedRecon: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyPending: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7NextRebalanceD6: FixtureBinding(
    DtoCodec<NextRebalanceVm>(
      'NextRebalanceVm',
      NextRebalanceVm.fromJson,
      (NextRebalanceVm v) => v.toJson(),
    ),
  ),
  FixturePaths.m7M7PerfDailyGap: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7RebalanceDetailBand: FixtureBinding(_rebalanceEvent),
  FixturePaths.m7M7ReportArchive18: FixtureBinding(
    DtoCodec<ReportArchiveVm>(
      'ReportArchiveVm',
      ReportArchiveVm.fromJson,
      (ReportArchiveVm v) => v.toJson(),
    ),
  ),
  FixturePaths.m7M7WithdrawalGeneral: FixtureBinding(_withdrawalPlan),
  FixturePaths.m7M7WithdrawalPensionPenalty: FixtureBinding(_withdrawalPlan),
  FixturePaths.m7M7WithdrawalShortfall: FixtureBinding(_withdrawalPlan),
  FixturePaths.m7RealizedAllocS7: FixtureBinding(
    DtoCodec<SleeveAllocationRow>(
      'SleeveAllocationRow',
      SleeveAllocationRow.fromJson,
      (SleeveAllocationRow v) => v.toJson(),
    ),
  ),

  // ── m8/ — 셸·운영 홈·알림·온보딩 ─────────────────────────────────────────
  FixturePaths.m8AlertsAdvice9codes: FixtureBinding(_alertItem),
  FixturePaths.m8AlertsDigest: FixtureBinding(_alertItem),
  FixturePaths.m8AlertsP0Ack: FixtureBinding(_alertItem),
  FixturePaths.m8HandbookPageSleeveB: FixtureBinding(
    DtoCodec<HandbookPage>(
      'HandbookPage',
      HandbookPage.fromJson,
      (HandbookPage v) => v.toJson(),
    ),
  ),
  FixturePaths.m8OnboardingFinish: FixtureBinding(_onboardingStep),
  FixturePaths.m8OnboardingFreshAdvisory: FixtureBinding(_onboardingStep),
  FixturePaths.m8OnboardingModePick: FixtureBinding(
    DtoCodec<OperatingModeView>(
      'OperatingModeView',
      OperatingModeView.fromJson,
      (OperatingModeView v) => v.toJson(),
    ),
  ),
  FixturePaths.m8OpsHomeAdviceOpen: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeAdviceZero: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeBlocked: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeNormal: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeResumeGap7: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsRhythmRows: FixtureBinding(
    DtoCodec<OpsRhythmRow>(
      'OpsRhythmRow',
      OpsRhythmRow.fromJson,
      (OpsRhythmRow v) => v.toJson(),
    ),
  ),
  FixturePaths.m8ReconBoardDiff: FixtureBinding(
    DtoCodec<DiagnosticsVm>(
      'DiagnosticsVm',
      DiagnosticsVm.fromJson,
      (DiagnosticsVm v) => v.toJson(),
    ),
  ),
  FixturePaths.m8RestartLostPhone: FixtureBinding(_onboardingStep),
  FixturePaths.m8WatchdogDelayed: FixtureBinding(_watchdogCheck),
  FixturePaths.m8WatchdogHoliday: FixtureBinding(_watchdogCheck),

  // ── m9/ — 설정·운영 모드 전환 ────────────────────────────────────────────
  FixturePaths.m9HandoverStates: FixtureBinding(
    DtoCodec<HandoverPlan>(
      'HandoverPlan',
      HandoverPlan.fromJson,
      (HandoverPlan v) => v.toJson(),
    ),
  ),
};

/// 🔴 **뷰모델이 아직 계약에 없는 픽스처** — 지우지 않고 사유와 함께 남긴다.
///
/// 이 셋은 봉투(`as_of`·`empty_kind`·`empty_label`·`has_more`)까지만 검사한다.
/// 이름이 확정되어 DTO 가 들어오면 [fixtureBindings] 로 옮기고 여기서 지운다.
const Map<String, String> unmappedFixtures = <String, String>{
  'm6/entry_gate_nov_pass_1.json':
      '계절 진입 게이트 뷰모델이 계약에 없다. 01 §3-7 은 상태 5값·사유 코드 3종만 정하고 '
      '화면 타입(state·gates·history·trigger 묶음)은 §2 에 등재되지 않았다 — 이름 확정 대기.',
  'm6/self_report_1.json':
      'L-3 실사 «세션» 뷰모델이 계약에 없다. 01 §4-2 의 SelfReportBalance 는 명령 인자라 '
      'CommandContext 가 required 이고, 그 봉투는 CommandApi 구현이 채운다(C-28 G-19) — '
      '화면 픽스처가 실을 값이 아니다.',
  'm8/incident_token_expired.json':
      'IncidentBanner·Runbook 이름 미확정(배럴 머리 주석 · M2-8 §G 표 미등재).',
};
