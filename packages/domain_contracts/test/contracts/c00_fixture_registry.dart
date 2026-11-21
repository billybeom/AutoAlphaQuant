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

/// 봉투 밖 추가 블록 — 운영 홈의 안내 요약(🆕 v1.13 · 01 §23 K9 · `m8/ops_home_advice_*`).
const String opsHomeAdviceSummaryKey = 'advice_summary';

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
// 🆕 계약 v1.15(R14 선행 · 01 §24) — `N-01` 센터 · `N-02` 상세 · `W-01` 보드(VM 1행 봉투).
final DtoCodec<Object> _alertCenterVm = DtoCodec<AlertCenterVm>(
  'AlertCenterVm',
  AlertCenterVm.fromJson,
  (AlertCenterVm v) => v.toJson(),
);
final DtoCodec<Object> _alertDetailVm = DtoCodec<AlertDetailVm>(
  'AlertDetailVm',
  AlertDetailVm.fromJson,
  (AlertDetailVm v) => v.toJson(),
);
final DtoCodec<Object> _watchdogBoardVm = DtoCodec<WatchdogBoardVm>(
  'WatchdogBoardVm',
  WatchdogBoardVm.fromJson,
  (WatchdogBoardVm v) => v.toJson(),
);
// 🆕 계약 v1.16(R15 선행 · 01 §25) — 온보딩 한 화면 VM 7(VM 1행 봉투) + 결과 `ActionResult`(목록 봉투 · C-8).
final DtoCodec<Object> _onboardingStartVm = DtoCodec<OnboardingStartVm>(
  'OnboardingStartVm',
  OnboardingStartVm.fromJson,
  (OnboardingStartVm v) => v.toJson(),
);
final DtoCodec<Object> _onboardingModeChoiceVm =
    DtoCodec<OnboardingModeChoiceVm>(
      'OnboardingModeChoiceVm',
      OnboardingModeChoiceVm.fromJson,
      (OnboardingModeChoiceVm v) => v.toJson(),
    );
final DtoCodec<Object> _onboardingStepsVm = DtoCodec<OnboardingStepsVm>(
  'OnboardingStepsVm',
  OnboardingStepsVm.fromJson,
  (OnboardingStepsVm v) => v.toJson(),
);
final DtoCodec<Object> _onboardingStepDetailVm =
    DtoCodec<OnboardingStepDetailVm>(
      'OnboardingStepDetailVm',
      OnboardingStepDetailVm.fromJson,
      (OnboardingStepDetailVm v) => v.toJson(),
    );
final DtoCodec<Object> _onboardingFinishVm = DtoCodec<OnboardingFinishVm>(
  'OnboardingFinishVm',
  OnboardingFinishVm.fromJson,
  (OnboardingFinishVm v) => v.toJson(),
);
final DtoCodec<Object> _restartVm = DtoCodec<RestartVm>(
  'RestartVm',
  RestartVm.fromJson,
  (RestartVm v) => v.toJson(),
);
final DtoCodec<Object> _pairingVm = DtoCodec<PairingVm>(
  'PairingVm',
  PairingVm.fromJson,
  (PairingVm v) => v.toJson(),
);
final DtoCodec<Object> _actionResult = DtoCodec<ActionResult>(
  'ActionResult',
  ActionResult.fromJson,
  (ActionResult v) => v.toJson(),
);
// 🆕 계약 v1.17(R16 선행 · 01 §26) — `D-01` 배너 · `D-02` 런북 · `D-03` 카드 · `B-01`·`B-02` 핸드북 · `H-03` 기기 리스크(VM 1행 봉투).
final DtoCodec<Object> _incidentBannerVm = DtoCodec<IncidentBannerVm>(
  'IncidentBannerVm',
  IncidentBannerVm.fromJson,
  (IncidentBannerVm v) => v.toJson(),
);
final DtoCodec<Object> _runbookIndexVm = DtoCodec<RunbookIndexVm>(
  'RunbookIndexVm',
  RunbookIndexVm.fromJson,
  (RunbookIndexVm v) => v.toJson(),
);
final DtoCodec<Object> _runbookVm = DtoCodec<RunbookVm>(
  'RunbookVm',
  RunbookVm.fromJson,
  (RunbookVm v) => v.toJson(),
);
final DtoCodec<Object> _emergencyCardVm = DtoCodec<EmergencyCardVm>(
  'EmergencyCardVm',
  EmergencyCardVm.fromJson,
  (EmergencyCardVm v) => v.toJson(),
);
final DtoCodec<Object> _handbookIndex = DtoCodec<HandbookIndex>(
  'HandbookIndex',
  HandbookIndex.fromJson,
  (HandbookIndex v) => v.toJson(),
);
final DtoCodec<Object> _handbookPage = DtoCodec<HandbookPage>(
  'HandbookPage',
  HandbookPage.fromJson,
  (HandbookPage v) => v.toJson(),
);
final DtoCodec<Object> _deviceRiskVm = DtoCodec<DeviceRiskVm>(
  'DeviceRiskVm',
  DeviceRiskVm.fromJson,
  (DeviceRiskVm v) => v.toJson(),
);
// 🆕 계약 v1.18(R6 선행 · 01 §27) — M9 `S01` 설정 홈 · `S07` 연결 관리 VM.
final DtoCodec<Object> _settingsHomeVm = DtoCodec<SettingsHomeVm>(
  'SettingsHomeVm',
  SettingsHomeVm.fromJson,
  (SettingsHomeVm v) => v.toJson(),
);
final DtoCodec<Object> _connectionsVm = DtoCodec<ConnectionsVm>(
  'ConnectionsVm',
  ConnectionsVm.fromJson,
  (ConnectionsVm v) => v.toJson(),
);
// 🆕 계약 v1.20(R7 선행 · 01 §29) — M9 `S02` 증권사 키 · `S06` 기기·접근 · `S03` 계좌 매핑 VM.
final DtoCodec<Object> _credentialListVm = DtoCodec<CredentialListVm>(
  'CredentialListVm',
  CredentialListVm.fromJson,
  (CredentialListVm v) => v.toJson(),
);
final DtoCodec<Object> _deviceAccessVm = DtoCodec<DeviceAccessVm>(
  'DeviceAccessVm',
  DeviceAccessVm.fromJson,
  (DeviceAccessVm v) => v.toJson(),
);
final DtoCodec<Object> _accountMappingVm = DtoCodec<AccountMappingVm>(
  'AccountMappingVm',
  AccountMappingVm.fromJson,
  (AccountMappingVm v) => v.toJson(),
);
// 🆕 계약 v1.21(엔진 예고 1/2 · 01 §30) — M5 안전 동작 결과 · M5-2 재개 게이트 · 서약 VM.
final DtoCodec<Object> _safetyActionResult = DtoCodec<SafetyActionResult>(
  'SafetyActionResult',
  SafetyActionResult.fromJson,
  (SafetyActionResult v) => v.toJson(),
);
final DtoCodec<Object> _killResumeGateVm = DtoCodec<KillResumeGateVm>(
  'KillResumeGateVm',
  KillResumeGateVm.fromJson,
  (KillResumeGateVm v) => v.toJson(),
);
final DtoCodec<Object> _pledgeVm = DtoCodec<PledgeVm>(
  'PledgeVm',
  PledgeVm.fromJson,
  (PledgeVm v) => v.toJson(),
);
// 🆕 계약 v1.22(엔진 예고 2/2 · 01 §31) — M5-4 사다리 · X2 재개 게이트 · simToAuto 계획 · 재개 리포트.
final DtoCodec<Object> _breakerLadderVm = DtoCodec<BreakerLadderVm>(
  'BreakerLadderVm',
  BreakerLadderVm.fromJson,
  (BreakerLadderVm v) => v.toJson(),
);
// 🆕 계약 v1.33(E16j-b · 01 §42) — X1 기기 이전.
final DtoCodec<Object> _x1PlanWizardVm = DtoCodec<X1PlanWizardVm>(
  'X1PlanWizardVm',
  X1PlanWizardVm.fromJson,
  (X1PlanWizardVm v) => v.toJson(),
);
final DtoCodec<Object> _x1RecoveryVm = DtoCodec<X1RecoveryVm>(
  'X1RecoveryVm',
  X1RecoveryVm.fromJson,
  (X1RecoveryVm v) => v.toJson(),
);
// 🆕 계약 v1.32(E16j-a · 01 §41) — X5 정정 마법사.
final DtoCodec<Object> _repairWizardVm = DtoCodec<RepairWizardVm>(
  'RepairWizardVm',
  RepairWizardVm.fromJson,
  (RepairWizardVm v) => v.toJson(),
);
final DtoCodec<Object> _resumeGateVm = DtoCodec<ResumeGateVm>(
  'ResumeGateVm',
  ResumeGateVm.fromJson,
  (ResumeGateVm v) => v.toJson(),
);
// 🆕 계약 v1.25(트랙 B · 01 §34) — M5-1 킬스위치 화면 · M5-5 차단 보드 · X2 재개 리포트 감싸개.
final DtoCodec<Object> _killSwitchScreenVm = DtoCodec<KillSwitchScreenVm>(
  'KillSwitchScreenVm',
  KillSwitchScreenVm.fromJson,
  (KillSwitchScreenVm v) => v.toJson(),
);
final DtoCodec<Object> _blockBoardVm = DtoCodec<BlockBoardVm>(
  'BlockBoardVm',
  BlockBoardVm.fromJson,
  (BlockBoardVm v) => v.toJson(),
);
final DtoCodec<Object> _resumeReportVm = DtoCodec<ResumeReportVm>(
  'ResumeReportVm',
  ResumeReportVm.fromJson,
  (ResumeReportVm v) => v.toJson(),
);
// 🆕 계약 v1.26(트랙 C 선행 · 01 §35) — M5-11 위저드 · M5-9 첫 승인 최소판(보드 RECON = `_blockBoardVm` · 결과 = `_safetyActionResult`).
final DtoCodec<Object> _handoverWizardVm = DtoCodec<HandoverWizardVm>(
  'HandoverWizardVm',
  HandoverWizardVm.fromJson,
  (HandoverWizardVm v) => v.toJson(),
);
final DtoCodec<Object> _ruleChangeGateVm = DtoCodec<RuleChangeGateVm>(
  'RuleChangeGateVm',
  RuleChangeGateVm.fromJson,
  (RuleChangeGateVm v) => v.toJson(),
);
final DtoCodec<Object> _handoverPlan = DtoCodec<HandoverPlan>(
  'HandoverPlan',
  HandoverPlan.fromJson,
  (HandoverPlan v) => v.toJson(),
);
final DtoCodec<Object> _resumeReport = DtoCodec<ResumeReport>(
  'ResumeReport',
  ResumeReport.fromJson,
  (ResumeReport v) => v.toJson(),
);
// 🆕 계약 v1.28(S04 첫 판 · 01 §37) — M9 `S04` 배분 화면(보기 전용).
final DtoCodec<Object> _allocationEditorVm = DtoCodec<AllocationEditorVm>(
  'AllocationEditorVm',
  AllocationEditorVm.fromJson,
  (AllocationEditorVm v) => v.toJson(),
);
// 🆕 계약 v1.24(R9 선행 · 01 §33) — M9 `S09` 백업 · `S10` 진단 감싸개 · `S12` 연간 리뷰 목차 VM.
final DtoCodec<Object> _backupVm = DtoCodec<BackupVm>(
  'BackupVm',
  BackupVm.fromJson,
  (BackupVm v) => v.toJson(),
);
final DtoCodec<Object> _diagnosticsScreenVm = DtoCodec<DiagnosticsScreenVm>(
  'DiagnosticsScreenVm',
  DiagnosticsScreenVm.fromJson,
  (DiagnosticsScreenVm v) => v.toJson(),
);
final DtoCodec<Object> _annualReviewIndexVm = DtoCodec<AnnualReviewIndexVm>(
  'AnnualReviewIndexVm',
  AnnualReviewIndexVm.fromJson,
  (AnnualReviewIndexVm v) => v.toJson(),
);
// 🆕 계약 v1.23(R8a 선행 · 01 §32) — M9 `S13` 월 납입 설정 VM.
final DtoCodec<Object> _monthlyContributionVm = DtoCodec<MonthlyContributionVm>(
  'MonthlyContributionVm',
  MonthlyContributionVm.fromJson,
  (MonthlyContributionVm v) => v.toJson(),
);
// 🆕 계약 v1.19(R6c 선행 · 01 §28) — M9 `S05` 운용 관리 VM.
final DtoCodec<Object> _operationsVm = DtoCodec<OperationsVm>(
  'OperationsVm',
  OperationsVm.fromJson,
  (OperationsVm v) => v.toJson(),
);
final DtoCodec<Object> _depositPlan = DtoCodec<DepositPlan>(
  'DepositPlan',
  DepositPlan.fromJson,
  (DepositPlan v) => v.toJson(),
);
// 🆕 계약 v1.6(R12 선행 · 01 §15-4) — 리밸런싱 미리보기 결과(초안 | 차단).
final DtoCodec<Object> _rebalancePreviewResult =
    DtoCodec<RebalancePreviewResult>(
      'RebalancePreviewResult',
      RebalancePreviewResult.fromJson,
      (RebalancePreviewResult v) => v.toJson(),
    );
final DtoCodec<Object> _nextRebalanceVm = DtoCodec<NextRebalanceVm>(
  'NextRebalanceVm',
  NextRebalanceVm.fromJson,
  (NextRebalanceVm v) => v.toJson(),
);
// 🆕 계약 v1.4(R11 선행 · 01 §14-1) — 입금 미리보기 결과(plan | 입력 거부 | 차단).
final DtoCodec<Object> _depositPreviewResult = DtoCodec<DepositPreviewResult>(
  'DepositPreviewResult',
  DepositPreviewResult.fromJson,
  (DepositPreviewResult v) => v.toJson(),
);
// 🆕 계약 v1.4 — 월 납입 설정(`ConfigRepository.watchContributionSetting()` · M9 첫 픽스처).
final DtoCodec<Object> _contributionSetting = DtoCodec<ContributionSetting>(
  'ContributionSetting',
  ContributionSetting.fromJson,
  (ContributionSetting v) => v.toJson(),
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
// 🆕 v1.5(01 §15-3) — `J-1` 회차 조건의 범위 설명.
final DtoCodec<Object> _journalRebalanceScope = DtoCodec<JournalRebalanceScope>(
  'JournalRebalanceScope',
  JournalRebalanceScope.fromJson,
  (JournalRebalanceScope v) => v.toJson(),
);
final DtoCodec<Object> _tradeJournalEntry = DtoCodec<TradeJournalEntry>(
  'TradeJournalEntry',
  TradeJournalEntry.fromJson,
  (TradeJournalEntry v) => v.toJson(),
);
// 🆕 v1.6(01 §15-4) — 월간 이행 갭 결과(report | 빈·해당없음 문장). 기존 4벌도 래퍼로 재바인딩 —
//    `ExecutionGapReport` 는 래퍼 안쪽으로 덮인다(C-8 폐포).
final DtoCodec<Object> _executionGapResult = DtoCodec<ExecutionGapResult>(
  'ExecutionGapResult',
  ExecutionGapResult.fromJson,
  (ExecutionGapResult v) => v.toJson(),
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
// 🆕 계약 v1.12(R5·R13 선행 · 01 §21) — `L-3` 세션 · `L-2` 정정 이력 · 공용(차이 행·신뢰 배지·안전 상태·리듬 행).
final DtoCodec<Object> _selfReportSession = DtoCodec<SelfReportSession>(
  'SelfReportSession',
  SelfReportSession.fromJson,
  (SelfReportSession v) => v.toJson(),
);
final DtoCodec<Object> _ledgerRepairRow = DtoCodec<LedgerRepairRow>(
  'LedgerRepairRow',
  LedgerRepairRow.fromJson,
  (LedgerRepairRow v) => v.toJson(),
);
final DtoCodec<Object> _ledgerDiffRow = DtoCodec<LedgerDiffRow>(
  'LedgerDiffRow',
  LedgerDiffRow.fromJson,
  (LedgerDiffRow v) => v.toJson(),
);
final DtoCodec<Object> _ledgerTrustBadge = DtoCodec<LedgerTrustBadge>(
  'LedgerTrustBadge',
  LedgerTrustBadge.fromJson,
  (LedgerTrustBadge v) => v.toJson(),
);
final DtoCodec<Object> _safetyState = DtoCodec<SafetyState>(
  'SafetyState',
  SafetyState.fromJson,
  (SafetyState v) => v.toJson(),
);
final DtoCodec<Object> _opsRhythmRow = DtoCodec<OpsRhythmRow>(
  'OpsRhythmRow',
  OpsRhythmRow.fromJson,
  (OpsRhythmRow v) => v.toJson(),
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
// 🆕 v1.1 R2 준비(2026-09-23) — 접수증 픽스처가 X7(수기 체결 거부)·J-3(사전 저널 5상태) 둘이 됐다.
final DtoCodec<Object> _commandReceipt = DtoCodec<CommandReceipt>(
  'CommandReceipt',
  CommandReceipt.fromJson,
  (CommandReceipt v) => v.toJson(),
);
// 🆕 계약 v1.2(R2b 선행 · 01 §12-1·§12-2) — 기기 로컬 초안 · 사전 저널 읽기.
final DtoCodec<Object> _draftRecord = DtoCodec<DraftRecord>(
  'DraftRecord',
  DraftRecord.fromJson,
  (DraftRecord v) => v.toJson(),
);
final DtoCodec<Object> _decisionJournalVm = DtoCodec<DecisionJournalVm>(
  'DecisionJournalVm',
  DecisionJournalVm.fromJson,
  (DecisionJournalVm v) => v.toJson(),
);
// 🆕 계약 v1.7(J-4 선행 · 01 §16) — blind 리뷰 카드(대기 목록 · 1건 · 공개 뒤) 5벌이 같은 행 타입이다.
final DtoCodec<Object> _blindReviewCard = DtoCodec<BlindReviewCard>(
  'BlindReviewCard',
  BlindReviewCard.fromJson,
  (BlindReviewCard v) => v.toJson(),
);
// 🆕 계약 v1.8(R4 선행 · 01 §17) — 보유 화면 셋의 VM(행 1 · `unknown_board_2` 선례).
final DtoCodec<Object> _holdingsOverviewVm = DtoCodec<HoldingsOverviewVm>(
  'HoldingsOverviewVm',
  HoldingsOverviewVm.fromJson,
  (HoldingsOverviewVm v) => v.toJson(),
);
final DtoCodec<Object> _holdingDetailVm = DtoCodec<HoldingDetailVm>(
  'HoldingDetailVm',
  HoldingDetailVm.fromJson,
  (HoldingDetailVm v) => v.toJson(),
);
final DtoCodec<Object> _sleeveAllocationVm = DtoCodec<SleeveAllocationVm>(
  'SleeveAllocationVm',
  SleeveAllocationVm.fromJson,
  (SleeveAllocationVm v) => v.toJson(),
);
// 🆕 계약 v1.3(R10 선행 · 01 §13) — 게이트·아카이브 픽스처가 여럿이 됐다.
final DtoCodec<Object> _disclosureGateVm = DtoCodec<DisclosureGateVm>(
  'DisclosureGateVm',
  DisclosureGateVm.fromJson,
  (DisclosureGateVm v) => v.toJson(),
);
final DtoCodec<Object> _reportArchiveVm = DtoCodec<ReportArchiveVm>(
  'ReportArchiveVm',
  ReportArchiveVm.fromJson,
  (ReportArchiveVm v) => v.toJson(),
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
  FixturePaths.ledgerDiffs4: FixtureBinding(_ledgerDiffRow),
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
  FixturePaths.resumeReport1: FixtureBinding(_resumeReport),
  FixturePaths.safetyStates: FixtureBinding(_safetyState),
  // 🆕 v1.1 — 슬리브 카탈로그(01 §2-1 — 목록의 유일한 창구).
  FixturePaths.sleeveCatalog4: FixtureBinding(
    DtoCodec<SleeveCatalogEntry>(
      'SleeveCatalogEntry',
      SleeveCatalogEntry.fromJson,
      (SleeveCatalogEntry v) => v.toJson(),
    ),
  ),

  // ── m5/ — 🆕 v1.21(01 §30) M5 안전 동작 ─────────────────────────────────
  // 🆕 v1.22(01 §31) — 사다리 2 · simToAuto 계획 4 · 위저드 결과 1 · E13 결과 1.
  // 🆕 v1.25(01 §34) — 킬스위치 화면 7 · 발동 접수증 1 · 게이트 꺼짐 1 · 차단 보드 4.
  FixturePaths.m5BlockBoardClear: FixtureBinding(_blockBoardVm),
  FixturePaths.m5BlockBoardKillActive: FixtureBinding(_blockBoardVm),
  FixturePaths.m5BlockBoardResumeIncomplete: FixtureBinding(_blockBoardVm),
  FixturePaths.m5BlockBoardStopped: FixtureBinding(_blockBoardVm),
  FixturePaths.m5KillResumeGateOff: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillSwitchActivateReceipts: FixtureBinding(_commandReceipt),
  FixturePaths.m5KillSwitchActiveLocked: FixtureBinding(_killSwitchScreenVm),
  FixturePaths.m5KillSwitchActiveUnrecorded: FixtureBinding(
    _killSwitchScreenVm,
  ),
  FixturePaths.m5KillSwitchCancelReadFailed: FixtureBinding(
    _killSwitchScreenVm,
  ),
  FixturePaths.m5KillSwitchLocked: FixtureBinding(_killSwitchScreenVm),
  FixturePaths.m5KillSwitchOff: FixtureBinding(_killSwitchScreenVm),
  FixturePaths.m5KillSwitchRecordedReady: FixtureBinding(_killSwitchScreenVm),
  FixturePaths.m5KillSwitchRecordedWaiting: FixtureBinding(_killSwitchScreenVm),
  FixturePaths.m5BreakerLadderNormal: FixtureBinding(_breakerLadderVm),
  FixturePaths.m5BreakerLadderStopped: FixtureBinding(_breakerLadderVm),
  FixturePaths.m5HandoverSimToAutoActionResults: FixtureBinding(_actionResult),
  FixturePaths.m5HandoverSimToAutoCooling: FixtureBinding(_handoverPlan),
  FixturePaths.m5HandoverSimToAutoFatePending: FixtureBinding(_handoverPlan),
  FixturePaths.m5HandoverSimToAutoReady: FixtureBinding(_handoverPlan),
  FixturePaths.m5HandoverSimToAutoS3Blocked: FixtureBinding(_handoverPlan),
  // 재개 게이트 7벌 · 서약 3벌 · 안전 동작 결과 14행 · 발동 기록 접수증 7행(기존 `_commandReceipt`).
  FixturePaths.m5KillChecklistReceipts: FixtureBinding(_commandReceipt),
  FixturePaths.m5KillResumeGateConditionUnmet: FixtureBinding(
    _killResumeGateVm,
  ),
  FixturePaths.m5KillResumeGateInProgress: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillResumeGateLocked: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillResumeGateNotConfirmed: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillResumeGateReady: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillResumeGateTimeUnknown: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5KillResumeGateWaiting: FixtureBinding(_killResumeGateVm),
  FixturePaths.m5PledgeEditWindow: FixtureBinding(_pledgeVm),
  FixturePaths.m5PledgeNotWritten: FixtureBinding(_pledgeVm),
  FixturePaths.m5PledgeWritten: FixtureBinding(_pledgeVm),
  FixturePaths.m5SafetyActionResults: FixtureBinding(_safetyActionResult),
  FixturePaths.m5SafetyActionResultsE13: FixtureBinding(_safetyActionResult),
  // 🆕 v1.26(01 §35) — 보드 RECON 1 · 위저드 12 · 규칙 변경 게이트 5 · 결과 2.
  FixturePaths.m5BlockBoardReconMismatch: FixtureBinding(_blockBoardVm),
  FixturePaths.m5HandoverWizardCommitReady: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardCommitted: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardCooling: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardExpired: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardFatePending: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardLocked: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardNotApplicable: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardS3Blocked: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardStartReady: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardTimeUnknown: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5HandoverWizardTrialIncomplete: FixtureBinding(
    _handoverWizardVm,
  ),
  FixturePaths.m5HandoverWizardWindowBlocked: FixtureBinding(_handoverWizardVm),
  FixturePaths.m5RuleChangeGateApprovable: FixtureBinding(_ruleChangeGateVm),
  FixturePaths.m5RuleChangeGateCooling: FixtureBinding(_ruleChangeGateVm),
  FixturePaths.m5RuleChangeGateEmpty: FixtureBinding(_ruleChangeGateVm),
  FixturePaths.m5RuleChangeGateFirstCandidate: FixtureBinding(
    _ruleChangeGateVm,
  ),
  FixturePaths.m5RuleChangeGateLocked: FixtureBinding(_ruleChangeGateVm),
  FixturePaths.m5RuleChangeRequestResults: FixtureBinding(_safetyActionResult),
  FixturePaths.m5ReconClearResults: FixtureBinding(_safetyActionResult),

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
  // 🆕 v1.12(01 §21) — 배치 결측 · `A-2` 체결 · 「내일 다시」·`A-4` 접수증.
  FixturePaths.m6AdviceStale: FixtureBinding(
    _adviceItem,
    extras: <String, DtoCodec<Object>>{adviceSummaryKey: _adviceInboxSummary},
  ),
  FixturePaths.m6AdviceFillsAd0005: FixtureBinding(_tradeJournalEntry),
  FixturePaths.m6AdviceDeferReceipts3: FixtureBinding(_commandReceipt),
  FixturePaths.m6AdviceSkipReceipts5: FixtureBinding(_commandReceipt),
  // 🆕 v1.8(01 §17) — `H6-3` 배분 7갈래(밴드 내 · 이탈 · 근접+보류 칩 · 파킹 큼 · INTEGRITY · RECON · 빈).
  FixturePaths.m6AllocationEmpty: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationInBand: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationIntegrity: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationOutOfBand: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationParkingLarge: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationRecon: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AllocationTrancheProgress: FixtureBinding(_sleeveAllocationVm),
  FixturePaths.m6AdviceSkipReasons: FixtureBinding(
    DtoCodec<ReasonOption>(
      'ReasonOption',
      ReasonOption.fromJson,
      (ReasonOption v) => v.toJson(),
    ),
  ),
  // 🆕 v1.7(01 §16) — J-4 blind 리뷰: 대기 목록 · 빈 큐 · 카드 1건 3갈래(전 · 공개 · 공개 미청산) · 접수증 6행.
  FixturePaths.m6BlindReviewQueue3: FixtureBinding(_blindReviewCard),
  FixturePaths.m6BlindReviewQueueEmpty: FixtureBinding(_blindReviewCard),
  FixturePaths.m6BlindReviewCardBefore: FixtureBinding(_blindReviewCard),
  FixturePaths.m6BlindReviewCardRevealed: FixtureBinding(_blindReviewCard),
  FixturePaths.m6BlindReviewCardRevealedOpen: FixtureBinding(_blindReviewCard),
  FixturePaths.m6BlindReviewReceipts6: FixtureBinding(_commandReceipt),
  FixturePaths.m6ExternalHoldings2: FixtureBinding(
    DtoCodec<ExternalHoldingRow>(
      'ExternalHoldingRow',
      ExternalHoldingRow.fromJson,
      (ExternalHoldingRow v) => v.toJson(),
    ),
  ),
  FixturePaths.m6FillFormSpec: FixtureBinding(_manualFillFormSpec),
  FixturePaths.m6FillFormSpecStale: FixtureBinding(_manualFillFormSpec),
  FixturePaths.m6FillRejectedPrice: FixtureBinding(_commandReceipt),
  // 🆕 v1.12(01 §21) — 제출 차단 폼 · `L-2` 이력 2 · `L-1` 현금 관측 · `A-3` 접수증 · `L-3` 세션 4 · 안내 배너 안전 상태.
  FixturePaths.m6FillFormSpecBlocked: FixtureBinding(_manualFillFormSpec),
  FixturePaths.m6LedgerRepairs4: FixtureBinding(_ledgerRepairRow),
  FixturePaths.m6LedgerRepairsEmpty: FixtureBinding(_ledgerRepairRow),
  FixturePaths.m6LedgerDiffsCashObserve: FixtureBinding(_ledgerDiffRow),
  FixturePaths.m6ManualFillReceipts7: FixtureBinding(_commandReceipt),
  FixturePaths.m6SelfReport1: FixtureBinding(_selfReportSession),
  FixturePaths.m6SelfReportDiffResult: FixtureBinding(_selfReportSession),
  FixturePaths.m6SelfReportSessionClosed: FixtureBinding(_selfReportSession),
  FixturePaths.m6SelfReportReceipts5: FixtureBinding(_commandReceipt),
  FixturePaths.m6SafetyAdviceBlocked: FixtureBinding(_safetyState),
  // 🆕 v1.8(01 §17) — `H6-2` 종목 상세 5갈래 · `H6-1` 보유현황 6갈래.
  FixturePaths.m6HoldingDetailIntegrity: FixtureBinding(_holdingDetailVm),
  FixturePaths.m6HoldingDetailNoStop: FixtureBinding(_holdingDetailVm),
  FixturePaths.m6HoldingDetailPnl: FixtureBinding(_holdingDetailVm),
  FixturePaths.m6HoldingDetailRecon: FixtureBinding(_holdingDetailVm),
  FixturePaths.m6HoldingDetailWithStops: FixtureBinding(_holdingDetailVm),
  FixturePaths.m6HoldingsOverviewEmpty: FixtureBinding(_holdingsOverviewVm),
  FixturePaths.m6HoldingsOverviewIntegrity: FixtureBinding(_holdingsOverviewVm),
  FixturePaths.m6HoldingsOverviewNormal: FixtureBinding(_holdingsOverviewVm),
  FixturePaths.m6HoldingsOverviewPnl: FixtureBinding(_holdingsOverviewVm),
  FixturePaths.m6HoldingsOverviewRecon: FixtureBinding(_holdingsOverviewVm),
  FixturePaths.m6HoldingsOverviewViewer: FixtureBinding(_holdingsOverviewVm),
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
  // 🆕 v1.2 — J-2 `journalLink` 목적지 2갈래(작성됨 → journal/read · 미작성 → journal/draft).
  FixturePaths.m6DecisionDetailJournalWritten: FixtureBinding(
    _decisionDetailVm,
  ),
  FixturePaths.m6DecisionDetailJournalDraftLink: FixtureBinding(
    _decisionDetailVm,
  ),
  // 🆕 v1.2 — 기기 로컬 초안(`draft_records_j3` 는 행 순서가 의미) · J-3R 읽기 3갈래.
  FixturePaths.m6DraftRecordsJ3: FixtureBinding(_draftRecord),
  FixturePaths.m6DraftRecordsX7: FixtureBinding(_draftRecord),
  FixturePaths.m6JournalReadWritten: FixtureBinding(_decisionJournalVm),
  // 🆕 v1.22(01 §31 · K66) — J-1 모의 가상 체결 거부 1행.
  FixturePaths.m6JournalSimBrokerReject: FixtureBinding(_tradeJournalEntry),
  FixturePaths.m6JournalReadNoNote: FixtureBinding(_decisionJournalVm),
  FixturePaths.m6JournalReadNotWritten: FixtureBinding(_decisionJournalVm),
  FixturePaths.m6JournalBadges2: FixtureBinding(
    DtoCodec<JournalTimelineBadge>(
      'JournalTimelineBadge',
      JournalTimelineBadge.fromJson,
      (JournalTimelineBadge v) => v.toJson(),
    ),
  ),
  // 🆕 v1.1 R2 준비(2026-09-23) — J-3 제출 결과 5상태(한 명령의 갈래).
  FixturePaths.m6JournalDraftReceipts5: FixtureBinding(_commandReceipt),
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
  // 🆕 v1.17(01 §26 · 엔진 D11) — 일 마감 실효 1행.
  FixturePaths.m6JournalExpired1: FixtureBinding(_tradeJournalEntry),
  // 🆕 v1.5(01 §15-3) — 회차 범위 · 모르는 회차의 0행 봉투.
  FixturePaths.m6JournalRebalanceScope1: FixtureBinding(_journalRebalanceScope),
  FixturePaths.m6JournalRebalanceUnknown: FixtureBinding(_tradeJournalEntry),
  FixturePaths.m6ManualFills8: FixtureBinding(_tradeJournalEntry),

  // ── m7/ — 성과·플래너·이행 갭 ────────────────────────────────────────────
  FixturePaths.m7AftertaxLadder1: FixtureBinding(
    DtoCodec<AfterTaxLadder>(
      'AfterTaxLadder',
      AfterTaxLadder.fromJson,
      (AfterTaxLadder v) => v.toJson(),
    ),
  ),
  // 🔵 v1.6 — 4벌은 행 타입이 `ExecutionGapReport` → `ExecutionGapResult` 래퍼로 바뀌었다(재바인딩).
  FixturePaths.m7ExecutionGap1: FixtureBinding(_executionGapResult),
  FixturePaths.m7ExecutionGapCant: FixtureBinding(_executionGapResult),
  // 🆕 v1.6 — 안내 0건 · RECON_MISMATCH 가림 · 자동 매매 구간.
  FixturePaths.m7ExecutionGapEmpty: FixtureBinding(_executionGapResult),
  FixturePaths.m7ExecutionGapMaskedRecon: FixtureBinding(_executionGapResult),
  FixturePaths.m7ExecutionGapMixed: FixtureBinding(_executionGapResult),
  FixturePaths.m7ExecutionGapNotApplicable: FixtureBinding(_executionGapResult),
  FixturePaths.m7ExecutionGapWont: FixtureBinding(_executionGapResult),
  FixturePaths.m7LedgerTrust4: FixtureBinding(_ledgerTrustBadge),
  // 🆕 v1.12(K45) — 9b 실사 카드 배지(`action_deep_link` = `L-3`).
  FixturePaths.m7LedgerTrustSelfAuditDue: FixtureBinding(_ledgerTrustBadge),
  FixturePaths.m7M7Annual2026: FixtureBinding(_annualReviewVm),
  FixturePaths.m7M7AnnualFirstYear: FixtureBinding(_annualReviewVm),
  // 🆕 v1.6 — 창 밖(2025 · CLOSED · 기본 연도 규칙 표본).
  FixturePaths.m7M7AnnualOffwindow: FixtureBinding(_annualReviewVm),
  FixturePaths.m7M7Contrib3sleeve: FixtureBinding(_contributionVm),
  FixturePaths.m7M7ContribPartial: FixtureBinding(_contributionVm),
  FixturePaths.m7M7DdContextDeep: FixtureBinding(_drawdownContextVm),
  FixturePaths.m7M7DdContextNormal: FixtureBinding(_drawdownContextVm),
  // 🔵 v1.4 — 화면 픽스처 3건은 행 타입이 `DepositPlan` → `DepositPreviewResult` 래퍼로 바뀌었다
  //    (재바인딩 · 코어 `depositPlan1`·`depositPlanFunding1` 은 `DepositPlan` 그대로).
  FixturePaths.m7M7DepositPlanBlocked: FixtureBinding(_depositPreviewResult),
  FixturePaths.m7M7DepositPlanDefault: FixtureBinding(_depositPreviewResult),
  FixturePaths.m7M7DepositPlanExpired: FixtureBinding(_depositPreviewResult),
  FixturePaths.m7M7DepositPlanFunding: FixtureBinding(_depositPreviewResult),
  FixturePaths.m7M7DepositPlanInputRejected: FixtureBinding(
    _depositPreviewResult,
  ),
  FixturePaths.m7M7DepositPlanLimit: FixtureBinding(_depositPreviewResult),
  // 🆕 v1.4 — 실입금 등록 접수증 4상태(한 명령의 갈래 · 행 순서 = 뜻).
  FixturePaths.m7M7DepositRegisterReceipts5: FixtureBinding(_commandReceipt),
  FixturePaths.m7M7DisclosureGate: FixtureBinding(_disclosureGateVm),
  // 🆕 v1.3 — `S7-2G` 게이트 3갈래(닫힘 · 첫 열람 · 잦은 열람) + 열람 기록 접수증 4상태.
  FixturePaths.m7M7DisclosureGateClosed: FixtureBinding(_disclosureGateVm),
  FixturePaths.m7M7DisclosureGateFirst: FixtureBinding(_disclosureGateVm),
  FixturePaths.m7M7DisclosureGateFrequent: FixtureBinding(_disclosureGateVm),
  FixturePaths.m7M7DisclosureViewReceipts4: FixtureBinding(_commandReceipt),
  FixturePaths.m7M7GoalPathHold: FixtureBinding(_goalPathVm),
  // 🆕 v1.4 — 목표 경로 이탈(`deviation_text`).
  FixturePaths.m7M7GoalPathOff: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7GoalPathOn: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7GoalPathRealworld: FixtureBinding(_goalPathVm),
  FixturePaths.m7M7Monthly202608: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyGap: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyMaskedIntegrity: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyMaskedRecon: FixtureBinding(_monthlyReport),
  FixturePaths.m7M7MonthlyPending: FixtureBinding(_monthlyReport),
  // 🔵 v1.6 — 개명(구 `m7NextRebalanceD6` · «D-1») + 예정 없음 표본.
  FixturePaths.m7M7NextRebalanceCountdown: FixtureBinding(_nextRebalanceVm),
  FixturePaths.m7M7NextRebalanceNone: FixtureBinding(_nextRebalanceVm),
  FixturePaths.m7M7PerfDailyGap: FixtureBinding(_performanceSeries),
  // 🆕 v1.3 — `S7-2` 성과 시리즈 6갈래(수동 집행 · 가림 · 월별 · 모의 분리 · 불가 · 연간).
  FixturePaths.m7M7PerfDailyManual: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7PerfMaskedIntegrity: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7PerfMonthlyPeriod: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7PerfMonthlySimSplit: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7PerfUnavailableGap: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7PerfYearly: FixtureBinding(_performanceSeries),
  FixturePaths.m7M7RebalanceDetailBand: FixtureBinding(_rebalanceEvent),
  // 🆕 v1.5(01 §15-3) — advisory 거울 · `S7-6a` 빈 타임라인.
  FixturePaths.m7M7RebalanceDetailAdvisory: FixtureBinding(_rebalanceEvent),
  FixturePaths.m7M7RebalanceEmpty: FixtureBinding(_rebalanceEvent),
  // 🆕 v1.6(01 §15-4) — `S7-6c` 미리보기 결과 3벌 · `S7-6a` 모의투자 회차.
  FixturePaths.m7M7RebalancePreviewBlocked: FixtureBinding(
    _rebalancePreviewResult,
  ),
  FixturePaths.m7M7RebalancePreviewDefault: FixtureBinding(
    _rebalancePreviewResult,
  ),
  FixturePaths.m7M7RebalancePreviewInBand: FixtureBinding(
    _rebalancePreviewResult,
  ),
  FixturePaths.m7M7RebalanceSim: FixtureBinding(_rebalanceEvent),
  FixturePaths.m7M7ReportArchive18: FixtureBinding(_reportArchiveVm),
  // 🆕 v1.3 — `S7-1b` 빈 아카이브.
  FixturePaths.m7M7ReportArchiveEmpty: FixtureBinding(_reportArchiveVm),
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
  // 🆕 v1.15 — `ALERT_ACK` 접수증 3갈래 · 알림 센터 5 · 상세 3.
  FixturePaths.m8AlertAckReceipts3: FixtureBinding(_commandReceipt),
  FixturePaths.m8AlertCenterDigest: FixtureBinding(_alertCenterVm),
  FixturePaths.m8AlertCenterEmpty: FixtureBinding(_alertCenterVm),
  FixturePaths.m8AlertCenterP0Ack: FixtureBinding(_alertCenterVm),
  FixturePaths.m8AlertCenterP0AckReordered: FixtureBinding(_alertCenterVm),
  FixturePaths.m8AlertCenterP0Only: FixtureBinding(_alertCenterVm),
  FixturePaths.m8AlertDetailFull: FixtureBinding(_alertDetailVm),
  FixturePaths.m8AlertDetailMissing: FixtureBinding(_alertDetailVm),
  FixturePaths.m8AlertDetailNoLink: FixtureBinding(_alertDetailVm),
  FixturePaths.m8AlertsAdvice9codes: FixtureBinding(_alertItem),
  FixturePaths.m8AlertsDigest: FixtureBinding(_alertItem),
  FixturePaths.m8AlertsP0Ack: FixtureBinding(_alertItem),
  // 🆕 v1.18(01 §27 · 엔진 등재형 K-z) — `AlertCodes.safety` 3 · `resume` 3 알림 6행.
  FixturePaths.m8AlertsSafetyResume: FixtureBinding(_alertItem),
  // 🆕 v1.27(01 §36 · K191) — 엔진 등재형 5(`safetyWarn` 4 · `derivedSync` 1) 알림 5행.
  FixturePaths.m8AlertsEngineProposalsV127: FixtureBinding(_alertItem),
  // 🆕 v1.17(01 §26 · 엔진 D11) — `STALE_ORDERS_HELD` 알림 1행.
  FixturePaths.m8AlertsStaleOrdersHeld: FixtureBinding(_alertItem),
  // 🆕 v1.17(01 §26 · R16c) — `H-03` 기기 리스크 2.
  FixturePaths.m8DeviceRiskEmpty: FixtureBinding(_deviceRiskVm),
  FixturePaths.m8DeviceRiskItems: FixtureBinding(_deviceRiskVm),
  // 🆕 v1.17(01 §26 · R16a) — `D-03` 긴급정지 카드 2.
  FixturePaths.m8EmergencyCard: FixtureBinding(_emergencyCardVm),
  FixturePaths.m8EmergencyCardNoPrint: FixtureBinding(_emergencyCardVm),
  // 🆕 v1.17(01 §26 · R16b) — `B-01` 목차 2 · `B-02` 페이지 3 + 개정 `sleeve_b`(형제 키 `index` 삭제 · K22).
  FixturePaths.m8HandbookIndex: FixtureBinding(_handbookIndex),
  FixturePaths.m8HandbookIndexOutdated: FixtureBinding(_handbookIndex),
  FixturePaths.m8HandbookPageArchived: FixtureBinding(_handbookPage),
  FixturePaths.m8HandbookPageMissing: FixtureBinding(_handbookPage),
  FixturePaths.m8HandbookPageOutdated: FixtureBinding(_handbookPage),
  FixturePaths.m8HandbookPageSleeveB: FixtureBinding(_handbookPage),
  // 🆕 v1.17(01 §26 · R16a) — `D-01` 장애 배너 6.
  FixturePaths.m8IncidentBannerNetworkDown: FixtureBinding(_incidentBannerVm),
  FixturePaths.m8IncidentBannerNone: FixtureBinding(_incidentBannerVm),
  FixturePaths.m8IncidentBannerOrderRejected: FixtureBinding(_incidentBannerVm),
  FixturePaths.m8IncidentBannerOther: FixtureBinding(_incidentBannerVm),
  FixturePaths.m8IncidentBannerPhoneDown: FixtureBinding(_incidentBannerVm),
  FixturePaths.m8IncidentBannerTokenExpired: FixtureBinding(_incidentBannerVm),
  // 🆕 v1.18(01 §27 · 미결 165 해소) — 연결 4행 = `ConnectionsVm`(형제 키 `incident_alert` = 곁 블록 · [unboundSiblingKeys]).
  FixturePaths.m8IncidentTokenExpired: FixtureBinding(_connectionsVm),
  FixturePaths.m8OnboardingFinish: FixtureBinding(_onboardingStep),
  // 🆕 v1.16(01 §25 · R15c) — `O-04` 마무리 7 · DRY_RUN 결과.
  FixturePaths.m8OnboardingFinishAdvisory: FixtureBinding(_onboardingFinishVm),
  FixturePaths.m8OnboardingFinishAdvisoryDeclared: FixtureBinding(
    _onboardingFinishVm,
  ),
  FixturePaths.m8OnboardingFinishAuto: FixtureBinding(_onboardingFinishVm),
  FixturePaths.m8OnboardingFinishAutoDeclared: FixtureBinding(
    _onboardingFinishVm,
  ),
  FixturePaths.m8OnboardingFinishAutoReady: FixtureBinding(_onboardingFinishVm),
  FixturePaths.m8OnboardingFinishDone: FixtureBinding(_onboardingFinishVm),
  FixturePaths.m8OnboardingFinishNoExpectation: FixtureBinding(
    _onboardingFinishVm,
  ),
  FixturePaths.m8OnboardingFinishResults: FixtureBinding(_actionResult),
  FixturePaths.m8OnboardingFreshAdvisory: FixtureBinding(_onboardingStep),
  // 🆕 v1.16(01 §25 · R15a) — `O-00b` 4 · 선택 결과.
  FixturePaths.m8OnboardingModeAdvisory: FixtureBinding(
    _onboardingModeChoiceVm,
  ),
  FixturePaths.m8OnboardingModeAuto: FixtureBinding(_onboardingModeChoiceVm),
  FixturePaths.m8OnboardingModeLocked: FixtureBinding(_onboardingModeChoiceVm),
  FixturePaths.m8OnboardingModePick: FixtureBinding(
    DtoCodec<OperatingModeView>(
      'OperatingModeView',
      OperatingModeView.fromJson,
      (OperatingModeView v) => v.toJson(),
    ),
  ),
  FixturePaths.m8OnboardingModeSelectResults: FixtureBinding(_actionResult),
  FixturePaths.m8OnboardingModeUnselected: FixtureBinding(
    _onboardingModeChoiceVm,
  ),
  // 🆕 v1.16(01 §25 · R15a·R15b) — `O-00` 2 · `O-02` 3 · `O-01` 6 · 검증 결과.
  FixturePaths.m8OnboardingStart: FixtureBinding(_onboardingStartVm),
  FixturePaths.m8OnboardingStartNoViewer: FixtureBinding(_onboardingStartVm),
  FixturePaths.m8OnboardingStepDetailKisMock: FixtureBinding(
    _onboardingStepDetailVm,
  ),
  FixturePaths.m8OnboardingStepDetailMissing: FixtureBinding(
    _onboardingStepDetailVm,
  ),
  FixturePaths.m8OnboardingStepDetailNoVerify: FixtureBinding(
    _onboardingStepDetailVm,
  ),
  // 🆕 v1.29(01 §39 · E11k-b) — o_07 상세 · 연결 확인 결과.
  FixturePaths.m8OnboardingStepDetailSupabase: FixtureBinding(
    _onboardingStepDetailVm,
  ),
  // 🆕 v1.31(01 §40 · E11k-d2) — o_07 ③ 상세 · 로그인 결과.
  FixturePaths.m8OnboardingStepDetailSupabaseLogin: FixtureBinding(
    _onboardingStepDetailVm,
  ),
  FixturePaths.m8OnboardingStepsAdvisory: FixtureBinding(_onboardingStepsVm),
  FixturePaths.m8OnboardingStepsAllVerifiedLocked: FixtureBinding(
    _onboardingStepsVm,
  ),
  FixturePaths.m8OnboardingStepsEmpty: FixtureBinding(_onboardingStepsVm),
  FixturePaths.m8OnboardingStepsFinishReady: FixtureBinding(_onboardingStepsVm),
  FixturePaths.m8OnboardingStepsFinishReadyWarn: FixtureBinding(
    _onboardingStepsVm,
  ),
  FixturePaths.m8OnboardingStepsFresh: FixtureBinding(_onboardingStepsVm),
  FixturePaths.m8OnboardingVerifyResults: FixtureBinding(_actionResult),
  FixturePaths.m8OnboardingSupabaseConnectResults: FixtureBinding(
    _actionResult,
  ),
  FixturePaths.m8OnboardingSupabaseSigninResults: FixtureBinding(_actionResult),
  // 🆕 v1.13(01 §23 K9) — 형제 키 `advice_summary` 를 C-1·C-8 이 연다(3벌 · 옛 2벌은 행만 묶었다).
  FixturePaths.m8OpsHomeAdviceOpen: FixtureBinding(
    _opsDailySummary,
    extras: <String, DtoCodec<Object>>{
      opsHomeAdviceSummaryKey: _adviceInboxSummary,
    },
  ),
  FixturePaths.m8OpsHomeAdviceSuppressedDue: FixtureBinding(
    _opsDailySummary,
    extras: <String, DtoCodec<Object>>{
      opsHomeAdviceSummaryKey: _adviceInboxSummary,
    },
  ),
  FixturePaths.m8OpsHomeAdviceZero: FixtureBinding(
    _opsDailySummary,
    extras: <String, DtoCodec<Object>>{
      opsHomeAdviceSummaryKey: _adviceInboxSummary,
    },
  ),
  FixturePaths.m8OpsHomeBlocked: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeNormal: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsHomeResumeGap7: FixtureBinding(_opsDailySummary),
  FixturePaths.m8OpsRhythmRows: FixtureBinding(_opsRhythmRow),
  // 🆕 v1.12(K29) — `H-02` 리듬 모름(NOT_LOADED).
  FixturePaths.m8OpsRhythmEmpty: FixtureBinding(_opsRhythmRow),
  // 🆕 v1.16(01 §25 · R15d) — `V-01` 페어링 3.
  FixturePaths.m8PairingFail: FixtureBinding(_pairingVm),
  FixturePaths.m8PairingOk: FixtureBinding(_pairingVm),
  FixturePaths.m8PairingWaiting: FixtureBinding(_pairingVm),
  FixturePaths.m8ReconBoardDiff: FixtureBinding(
    DtoCodec<DiagnosticsVm>(
      'DiagnosticsVm',
      DiagnosticsVm.fromJson,
      (DiagnosticsVm v) => v.toJson(),
    ),
  ),
  // 🆕 v1.13(01 §23 K5) — 대조 보드 전부 일치.
  FixturePaths.m8ReconBoardOk: FixtureBinding(
    DtoCodec<DiagnosticsVm>(
      'DiagnosticsVm',
      DiagnosticsVm.fromJson,
      (DiagnosticsVm v) => v.toJson(),
    ),
  ),
  FixturePaths.m8RestartLostPhone: FixtureBinding(_onboardingStep),
  // 🆕 v1.16(01 §25 · R15d) — `R-01` 다시 시작 4.
  FixturePaths.m8RestartVmGap7: FixtureBinding(_restartVm),
  FixturePaths.m8RestartVmLoggedOut: FixtureBinding(_restartVm),
  FixturePaths.m8RestartVmLostPhone: FixtureBinding(_restartVm),
  FixturePaths.m8RestartVmUnknown: FixtureBinding(_restartVm),
  // 🆕 v1.17(01 §26 · R16a) — `D-02` 런북 목록 2 · 상세 2.
  FixturePaths.m8RunbookHostLost: FixtureBinding(_runbookVm),
  FixturePaths.m8RunbookIndex: FixtureBinding(_runbookIndexVm),
  FixturePaths.m8RunbookIndexEmpty: FixtureBinding(_runbookIndexVm),
  FixturePaths.m8RunbookMissing: FixtureBinding(_runbookVm),
  // 🆕 v1.15(K3) — 워치독 4벌 = `WatchdogBoardVm` 1행(구 `WatchdogCheck` 목록 · 형제 키 `holiday_notice` → VM 필드).
  FixturePaths.m8WatchdogDelayed: FixtureBinding(_watchdogBoardVm),
  FixturePaths.m8WatchdogEmpty: FixtureBinding(_watchdogBoardVm),
  FixturePaths.m8WatchdogHoliday: FixtureBinding(_watchdogBoardVm),
  FixturePaths.m8WatchdogPaused: FixtureBinding(_watchdogBoardVm),

  // ── m9/ — 설정·운영 모드 전환 ────────────────────────────────────────────
  // 🆕 v1.20(01 §29 · R7c) — `S03` 계좌 매핑 3벌 · S03 동작 결과 8행.
  FixturePaths.m9AccountMapping: FixtureBinding(_accountMappingVm),
  FixturePaths.m9AccountMappingActionResults: FixtureBinding(_actionResult),
  FixturePaths.m9AccountMappingLocked: FixtureBinding(_accountMappingVm),
  FixturePaths.m9AccountMappingUnmapped: FixtureBinding(_accountMappingVm),
  // 🆕 v1.28(01 §37) — S04 첫 판 2.
  FixturePaths.m9AllocationEditor: FixtureBinding(_allocationEditorVm),
  FixturePaths.m9AllocationEditorStale: FixtureBinding(_allocationEditorVm),
  // 🆕 v1.24(01 §33 · R9c) — `S12` 연간 리뷰 목차 4벌.
  FixturePaths.m9AnnualReviewIndexClosed: FixtureBinding(_annualReviewIndexVm),
  FixturePaths.m9AnnualReviewIndexFirstYear: FixtureBinding(
    _annualReviewIndexVm,
  ),
  FixturePaths.m9AnnualReviewIndexOpen: FixtureBinding(_annualReviewIndexVm),
  FixturePaths.m9AnnualReviewIndexStale: FixtureBinding(_annualReviewIndexVm),
  // 🆕 v1.24(01 §33 · R9a) — `S09` 백업·복원 6벌 · 결과 10행.
  FixturePaths.m9Backup: FixtureBinding(_backupVm),
  FixturePaths.m9BackupActionResults: FixtureBinding(_actionResult),
  FixturePaths.m9BackupAgeWarn: FixtureBinding(_backupVm),
  FixturePaths.m9BackupEmpty: FixtureBinding(_backupVm),
  FixturePaths.m9BackupLocked: FixtureBinding(_backupVm),
  FixturePaths.m9BackupSim: FixtureBinding(_backupVm),
  FixturePaths.m9BackupStale: FixtureBinding(_backupVm),
  // 🆕 v1.18(01 §27 · R6b) — `S07` 연결 관리 3벌.
  FixturePaths.m9Connections: FixtureBinding(_connectionsVm),
  FixturePaths.m9ConnectionsLocked: FixtureBinding(_connectionsVm),
  FixturePaths.m9ConnectionsTelegram: FixtureBinding(_connectionsVm),
  // 🆕 v1.23(01 §32 · R8a) — `S13` 동작 결과 9행.
  FixturePaths.m9ContributionActionResults: FixtureBinding(_actionResult),
  // 🆕 v1.4 — 월 납입 설정 2갈래(`pension_limit_note_text` 있음 / 없음).
  FixturePaths.m9ContributionSettingDefault: FixtureBinding(
    _contributionSetting,
  ),
  FixturePaths.m9ContributionSettingNoLimitNote: FixtureBinding(
    _contributionSetting,
  ),
  // 🆕 v1.20(01 §29 · R7a · R7b) — `S02` 증권사 키 4벌 · 결과 6행 · `S06` 기기·접근 5벌 · 결과 6행.
  FixturePaths.m9CredentialActionResults: FixtureBinding(_actionResult),
  FixturePaths.m9Credentials: FixtureBinding(_credentialListVm),
  FixturePaths.m9CredentialsAdvisory: FixtureBinding(_credentialListVm),
  FixturePaths.m9CredentialsLocked: FixtureBinding(_credentialListVm),
  FixturePaths.m9CredentialsSimSealed: FixtureBinding(_credentialListVm),
  // 🆕 v1.28 K208(R196) — SIM 실전 미등록 카드(봉인 + 칸 + 검증).
  FixturePaths.m9CredentialsSimUnregistered: FixtureBinding(_credentialListVm),
  FixturePaths.m9DeviceAccess: FixtureBinding(_deviceAccessVm),
  FixturePaths.m9DeviceAccessLocked: FixtureBinding(_deviceAccessVm),
  FixturePaths.m9DeviceAccessNoViewers: FixtureBinding(_deviceAccessVm),
  FixturePaths.m9DeviceAccessStale: FixtureBinding(_deviceAccessVm),
  FixturePaths.m9DeviceAccessTicket: FixtureBinding(_deviceAccessVm),
  FixturePaths.m9DeviceActionResults: FixtureBinding(_actionResult),
  // 🆕 v1.24(01 §33 · R9b) — `S10` 진단 감싸개 5벌.
  FixturePaths.m9DiagnosticsScreen: FixtureBinding(_diagnosticsScreenVm),
  FixturePaths.m9DiagnosticsScreenDiff: FixtureBinding(_diagnosticsScreenVm),
  FixturePaths.m9DiagnosticsScreenLocked: FixtureBinding(_diagnosticsScreenVm),
  FixturePaths.m9DiagnosticsScreenRunning: FixtureBinding(_diagnosticsScreenVm),
  FixturePaths.m9DiagnosticsScreenStale: FixtureBinding(_diagnosticsScreenVm),
  FixturePaths.m9HandoverStates: FixtureBinding(_handoverPlan),
  // 🆕 v1.23(01 §32 · R8a) — `S13` 월 납입 설정 6벌.
  FixturePaths.m9MonthlyContribution: FixtureBinding(_monthlyContributionVm),
  FixturePaths.m9MonthlyContributionLocked: FixtureBinding(
    _monthlyContributionVm,
  ),
  FixturePaths.m9MonthlyContributionNoLimitNote: FixtureBinding(
    _monthlyContributionVm,
  ),
  FixturePaths.m9MonthlyContributionNoRecord: FixtureBinding(
    _monthlyContributionVm,
  ),
  FixturePaths.m9MonthlyContributionPending: FixtureBinding(
    _monthlyContributionVm,
  ),
  FixturePaths.m9MonthlyContributionStale: FixtureBinding(
    _monthlyContributionVm,
  ),
  // 🆕 v1.19(01 §28 · R6c) — `S05` 운용 관리 7벌 · S05 동작 결과 13행.
  FixturePaths.m9OperationsActionResults: FixtureBinding(_actionResult),
  FixturePaths.m9OperationsAdvisory: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsLiveHoldKeys: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsLiveObserve: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsLivePromotable: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsLocked: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsSimAuto: FixtureBinding(_operationsVm),
  FixturePaths.m9OperationsSimComplete: FixtureBinding(_operationsVm),
  // 🆕 v1.24(01 §33 · R9b) — `S10` 동작 결과 12행.
  FixturePaths.m9SelftestActionResults: FixtureBinding(_actionResult),
  // 🆕 v1.18(01 §27 · R6b) — M9 동작 결과 5행.
  FixturePaths.m9SettingsActionResults: FixtureBinding(_actionResult),
  // 🆕 v1.18(01 §27 · R6a) — `S01` 설정 홈 3벌.
  FixturePaths.m9SettingsHome: FixtureBinding(_settingsHomeVm),
  FixturePaths.m9SettingsHomeNoReview: FixtureBinding(_settingsHomeVm),
  FixturePaths.m9SettingsHomeViewer: FixtureBinding(_settingsHomeVm),

  // ── x1/ — 🆕 v1.33(01 §42 · K279) X1 기기 이전 옛 폰 6 · 새 폰 8 · 결과 1 ──────
  FixturePaths.x1PlanWizardBlocked: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1PlanWizardD03: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1PlanWizardDemoted: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1PlanWizardLiveOnly: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1PlanWizardLocked: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1PlanWizardTicket: FixtureBinding(_x1PlanWizardVm),
  FixturePaths.x1RecoveryEmergencyFencing: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryEmergencyStart: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryFull: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryGapViolation: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryGateBiometric: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryGateObserving: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryPlanScan: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1RecoveryRestoreRejected: FixtureBinding(_x1RecoveryVm),
  FixturePaths.x1X1ActionResults: FixtureBinding(_safetyActionResult),

  // ── x2/ — 🆕 v1.22(01 §31 · K63 · K64) X2 재개 게이트 · 리포트 ──────────────
  FixturePaths.x2ResumeGateConservativeDefer: FixtureBinding(_resumeGateVm),
  FixturePaths.x2ResumeGateLocked: FixtureBinding(_resumeGateVm),
  FixturePaths.x2ResumeGateReevaluationFailed: FixtureBinding(_resumeGateVm),
  FixturePaths.x2ResumeGateSeasonalPending: FixtureBinding(_resumeGateVm),
  FixturePaths.x2ResumeReportNormal: FixtureBinding(_resumeReport),
  FixturePaths.x2ResumeReportRecoveryFull: FixtureBinding(_resumeReport),
  // 🆕 v1.25(01 §34) — 게이트 막힌 것 0 · 리포트 화면 감싸개 3.
  FixturePaths.x2ResumeGateClear: FixtureBinding(_resumeGateVm),
  FixturePaths.x2ResumeReportScreenEmpty: FixtureBinding(_resumeReportVm),
  FixturePaths.x2ResumeReportScreenNormal: FixtureBinding(_resumeReportVm),
  FixturePaths.x2ResumeReportScreenRecoveryFull: FixtureBinding(
    _resumeReportVm,
  ),

  // ── x5/ — 🆕 v1.32(01 §41 · K260) X5 정정 마법사 7 · 결과 1 ──────────────
  FixturePaths.x5RepairActionResults: FixtureBinding(_safetyActionResult),
  FixturePaths.x5RepairBoundaryX1: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairDiffDefault: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairDiffReady: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairDiffStage3: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairHubEmpty: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairHubTargets: FixtureBinding(_repairWizardVm),
  FixturePaths.x5RepairIntegrityReady: FixtureBinding(_repairWizardVm),
};

/// 🔴 **뷰모델이 아직 계약에 없는 픽스처** — 지우지 않고 사유와 함께 남긴다.
///
/// 이 목록(🆕 v1.18 = 1건)은 봉투(`as_of`·`empty_kind`·`empty_label`·`has_more`)까지만 검사한다.
/// 🆕 v1.12 — `m6/self_report_1.json` 은 `L-3` 세션 VM(`SelfReportSession`)이 생겨 바인딩으로 옮겼다(01 §21 · K8).
/// 🆕 v1.18 — `m8/incident_token_expired.json` 은 행 `level`·`actions` 가 생겨 `ConnectionsVm` 바인딩으로 옮겼다(01 §27 · 미결 165).
/// 이름이 확정되어 DTO 가 들어오면 [fixtureBindings] 로 옮기고 여기서 지운다.
const Map<String, String> unmappedFixtures = <String, String>{
  'm6/entry_gate_nov_pass_1.json':
      '계절 진입 게이트 뷰모델이 계약에 없다. 01 §3-7 은 상태 5값·사유 코드 3종만 정하고 '
      '화면 타입(state·gates·history·trigger 묶음)은 §2 에 등재되지 않았다 — 이름 확정 대기. '
      'v1.8 — `H6-3` 은 `SleeveAllocationRow.stateChips` 로 보류를 말한다 · `enteredInNov` 골든 의무는 '
      '`A-2` `ReasonChip`(`F1_ENTRY_LATE`) 몫(01 §17 · K13).',
};

/// 봉투 필수 6키 — 이 밖의 최상위 키가 «형제 키»다(fixtures/README «봉투 형제 키 표»).
const Set<String> envelopeKeys = <String>{
  'meta',
  'as_of',
  'empty_kind',
  'empty_label',
  'has_more',
  'rows',
};

/// 🆕 v1.13 검증 반영(2026-10-26 · 01 §23 K9 · 변이 R5·V23C) — **extras 로 묶지 않는 형제 키**와 그 사유.
///
/// 🔴 C-1 은 등록된 픽스처의 형제 키가 [FixtureBinding.extras] 에 있거나 여기 있어야 통과시킨다 —
///    `summary`·`advice_summary` 는 여기 **없다**(extras 를 빼면 C-1 이 실패한다 · 조용히 열지 않게 되는 일을 막는다).
/// 키를 늘리면 README 표와 이 목록을 함께 고친다.
const Map<String, String> unboundSiblingKeys = <String, String>{
  'active_flags': '`BlockFlag` 목록 — Map 블록이 아니라 extras 상자(Map → DTO)로 열 수 없다 · C-15 ⑥ 이 형제 키 표로 본다.',
  'counterfactual':
      '`AfterTaxLadder` — C-30 골든 대조 전용(C-30 ⓒ 가 직접 연다 · 화면 경로 = '
      '`AnnualReviewVm.afterTaxCounterfactual`).',
  'counterfactual_collapsed': 'bool 원시 — C-30 ⓒ 대조 전용 · DTO 아님.',
  'credential_use': '원시 글자 — DTO 아님.',
  'finish_headline': '문장(원시) — DTO 아님.',
  'incident_alert':
      '`AlertItem` — `ConnectionsVm` 봉투의 곁 블록(🆕 v1.18 바인딩 · 01 §27 · 미결 165 해소) · extras 묶음 밖 · '
      '등급은 C-47 ⑥ 전 픽스처 walk 가 본다.',
  'lease_notice': '문장(원시) — DTO 아님.',
  'operating_mode': '원시 글자 — DTO 아님(C-18 ② 가 값을 본다).',
  'preserved_input': '원시(`ManualFillRecord` 모양 · `context` 없음) — DTO 아님.',
  'price_range_source_date':
      'TradeDate 글자(원시) — Map 블록이 아니라 extras 상자로 열 수 없다.',
  'reject_reason':
      '`ReasonChip` — 거부 영수증 표본의 곁 블록 · 행(`CommandReceipt`)의 사유 코드는 C-16 이 본다 · '
      'extras 묶음은 v1.13 K9 밖.',
};

/// 한 픽스처에서 extras 로도 사유 목록으로도 덮이지 않은 형제 키(C-1 · 자체 검증용으로 공개).
List<String> unboundSiblingsOf(
  String path,
  Map<String, Object?> envelope,
  Set<String> extrasKeys,
) => <String>[
  for (final String key in envelope.keys)
    if (!envelopeKeys.contains(key) &&
        !extrasKeys.contains(key) &&
        !unboundSiblingKeys.containsKey(key))
      '$path.$key',
];
