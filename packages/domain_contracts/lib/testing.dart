// domain_contracts/testing.dart — 🆕 계약 v1.1 · **테스트 전용** 받침대(test doubles).
//
// 왜 있는가: 화면 테스트의 가짜 리포지토리가 `implements XRepository` 로 인터페이스를 통째로
//   구현하면, M2 가 창구를 **하나 더할 때마다 모든 화면 테스트가 컴파일에서 깨진다**
//   (v1.1 에서 실제로 일어났다 — `JournalRepository` 에 5개를 더하자 J-1 테스트가 죽었다).
//   그래서 «전부 UnimplementedError 를 던지는» 받침대를 M2 가 계약과 **같은 커밋에서** 고친다.
//   화면 테스트는 이것을 `extends` 하고 필요한 메서드만 override 한다.
//
//     class _FakeJournal extends UnimplementedJournalRepository {
//       @override
//       Stream<ListResult<TradeJournalEntry>> watchTimeline({...}) => Stream.value(result);
//     }
//
// 받침대 목록 — `UnimplementedJournalRepository` · `UnimplementedPerformanceRepository` ·
//   `UnimplementedConfigRepository` · `RecordingLinkOpener`(링크 기록기) ·
//   🆕 계약 v1.1 R2 준비(2026-09-23) — `UnimplementedCommandApi`(명령 13종) ·
//   `UnimplementedSafetyRepository`(안전 상태 1종).
//   🆕 계약 v1.2 R2b 선행(2026-09-25) — `UnimplementedDraftStore`(초안 포트 · 전부 `Future` 에러) ·
//   `RecordingDraftStore`(메모리 + 호출 기록 · 픽스처 시드) ·
//   `UnimplementedJournalRepository.watchDecisionJournal`.
//   🆕 계약 v1.4 R11 선행(2026-09-30) — `UnimplementedWhatIfApi`(미리보기 5종 · 전부 `Future` 에러) ·
//   `UnimplementedPerformanceRepository.goalPath` · `UnimplementedCommandApi.registerDeposit` 는
//   새 인자(`DepositRegistration(planId:)` 하나)를 받는다(시그니처 무변경).
//   🆕 계약 v1.5 R12 선행(01 §15-3) — `UnimplementedRebalanceRepository`(리밸런싱 읽기 창구 ·
//   R12 `S7-6a/b/c` 가짜의 받침대 — 그전까지 이 받침대가 없어 `implements` 가 강요됐다) ·
//   `watchEvents` 봉투(`ListResult`) · `watchEvent`(회차 1건) · `UnimplementedJournalRepository.watchRebalanceScope`.
//   🆕 계약 v1.6 R12 선행(01 §15-4) — `UnimplementedExecutionGapRepository`(이행 갭 읽기 창구 ·
//   R12 `S7-10` 가짜의 받침대 · `monthly({String? yyyyMm})` → `ExecutionGapResult`) ·
//   `UnimplementedRebalanceRepository.watchEvents({DateRange? range})` ·
//   `UnimplementedWhatIfApi.previewRebalance` → `Future<RebalancePreviewResult>` 에러 ·
//   `UnimplementedPerformanceRepository.annualReview({String? year})`. Ops 받침대는 만들지 않는다
//   (`S7-7` = `PerformanceRepository` 하나).
//   🆕 계약 v1.7 J-4 선행(01 §16 · §8 미결 46) — `UnimplementedJournalRepository.watchBlindReviewQueue`
//   (대기 목록 봉투 · `{RunMode mode = RunMode.live}`) · `watchBlindReviewCard`(카드 1건). 명령 받침대는
//   무변경(`UnimplementedCommandApi.submitBlindReviewScore` 는 v1.1 부터 있다 · `BlindReviewScore` 필드 무변경).
//   🆕 계약 v1.8 R4 선행(01 §17) — `UnimplementedHoldingsRepository`(보유 읽기 창구 4 · `H6-*` 가짜의 받침대 ·
//   `watchHoldings` · `watchHoldingsOverview` · `watchHoldingDetail(holdingId)` · `watchAllocation`).
//   🆕 E7a0(2026-10-21 · 설계 13 §8 R18 D-12 · 계약 버전 불변) — What-if 표시 계약 **판정 함수**
//   (`src/testing/what_if_rules.dart` · C-38 ①~⑧ · C-41 ①②) — 픽스처(계약 테스트)와 실엔진 출력(core_engine 시험)에
//   같은 판정을 건다. 받침대가 아니라 «위반 문장 목록»을 돌려주는 순수 함수다.
//   🆕 계약 v1.11 E7b0(01 §20 · 설계 13 §8 R22 D14) — 실입금 등록 접수증 판정 `depositReceiptViolations`
//   (`src/testing/deposit_register_rules.dart` · C-38 ⑨) — 픽스처와 실엔진 접수증(E7b2)에 같은 판정을 건다.
//   🆕 계약 v1.12 R5·R13 선행(01 §21 · K28) — `UnimplementedLedgerRepository`(3) · `UnimplementedAdviceRepository`(6) ·
//   `UnimplementedLedgerTrustRepository`(2) · `UnimplementedOpsSummaryRepository`(2 — 🔵 v1.6 «Ops 받침대는 만들지
//   않는다»는 `S7-7` 한정이었다 · R13 이 필요로 한다) · `UnimplementedSettingsActions`(2 · **`Future` 에러 / 에러 스트림** —
//   `L-3` `dispose` 경로에서도 동기 throw 0) · `UnimplementedCommandApi` X7 3 인자 교체(제출 DTO) + `deferAdviceConfirm`.
//   🆕 계약 v1.15 R14 선행(01 §24 · K18) — `UnimplementedAlertRepository`(3) · `UnimplementedOpsStatusRepository`(6 —
//   v1.6 «Ops 받침대는 만들지 않는다» 는 `S7-7` 한정 · R14 가 필요로 한다) · `UnimplementedCommandApi.acknowledgeAlert(String alertId)`.
//   🆕 계약 v1.16 R15 선행(01 §25 · K30) — `UnimplementedOnboardingRepository`(7) · `UnimplementedPairingRepository`(1 ·
//   뷰어 `V-01`) · `UnimplementedSettingsActions` 주석(O-00b·O-03·O-04 는 결과를 읽는다).
//   🆕 계약 v1.17 R16 선행(01 §26 · K23) — `UnimplementedIncidentRepository`(1) · `UnimplementedRunbookRepository`(3) ·
//   `UnimplementedHandbookRepository`(2) · `UnimplementedOpsStatusRepository` +1(`watchDeviceRisk` · 7).
//
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다 — `test/` 에서만 쓴다(배럴에 없다).
// 🔴 받침대는 **값을 지어내지 않는다** — 기본 동작은 전부 `UnimplementedError` 다. 값은
//    픽스처에서 읽어 override 로 준다(01 §5).

import 'package:decimal/decimal.dart';

import 'domain_contracts.dart';

export 'src/testing/deposit_register_rules.dart';
export 'src/testing/what_if_rules.dart';

/// [RebalanceRepository] 받침대 — 필요한 메서드만 override 한다(🆕 계약 v1.5 · 01 §15-3).
class UnimplementedRebalanceRepository implements RebalanceRepository {
  @override
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range}) =>
      throw UnimplementedError('watchEvents');

  @override
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId) =>
      throw UnimplementedError('watchEvent');

  @override
  Stream<NextRebalanceVm> watchNext() => throw UnimplementedError('watchNext');
}

/// [ExecutionGapRepository] 받침대 — 필요한 메서드만 override 한다(🆕 계약 v1.6 · 01 §15-4).
///
/// 🔴 리포지토리 받침대 관행대로 **동기로 던진다**([UnimplementedWhatIfApi] 의 `Future` 에러와 다르다).
/// 🔴 결과는 지어내지 않는다 — `m7/execution_gap_*` 픽스처 행을 열어 override 로 돌려준다.
class UnimplementedExecutionGapRepository implements ExecutionGapRepository {
  @override
  Future<ExecutionGapResult> monthly({String? yyyyMm}) =>
      throw UnimplementedError('monthly');

  @override
  Stream<ExecutionGapReport> watchRolling() =>
      throw UnimplementedError('watchRolling');
}

/// 🆕 계약 v1.8(01 §17) — [HoldingsRepository] 받침대(`H6-*` 가짜의 받침대 · 그전까지 없어 `implements` 가 강요됐다).
/// 🔴 동기로 던진다(리포지토리 받침대 관행). 값은 지어내지 않는다 — `m6/holdings_*`·`m6/holding_detail_*`·`m6/allocation_*` 픽스처를 override 로.
class UnimplementedHoldingsRepository implements HoldingsRepository {
  @override
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false}) =>
      throw UnimplementedError('watchHoldings');
  @override
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) =>
      throw UnimplementedError('watchHoldingsOverview');
  @override
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  }) => throw UnimplementedError('watchHoldingDetail');
  @override
  Stream<SleeveAllocationVm> watchAllocation() =>
      throw UnimplementedError('watchAllocation');
}

/// 🆕 계약 v1.12(01 §21 · K28) — [LedgerRepository] 받침대(`L-1`·`L-2` 가짜의 받침대).
/// 🔴 동기로 던진다(리포지토리 받침대 관행). 값은 지어내지 않는다 — `ledger_diffs_4`·`m6/ledger_repairs_*` 픽스처를 override 로.
class UnimplementedLedgerRepository implements LedgerRepository {
  @override
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs() =>
      throw UnimplementedError('watchOpenDiffs');
  @override
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings() =>
      throw UnimplementedError('watchExternalHoldings');
  @override
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50}) =>
      throw UnimplementedError('watchRepairs');
}

/// 🆕 계약 v1.12(01 §21 · K28) — [AdviceRepository] 받침대(`A-1`~`A-4`·「지난 안내」 가짜의 받침대).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m6/advice_*`·`m6/fill_form_spec*`·`m6/advice_fills_ad0005` 픽스처를 override 로.
class UnimplementedAdviceRepository implements AdviceRepository {
  @override
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  }) => throw UnimplementedError('watchInbox');
  @override
  Stream<AdviceInboxSummary> watchSummary() =>
      throw UnimplementedError('watchSummary');
  @override
  Future<AdviceItem?> findById(String adviceId) =>
      throw UnimplementedError('findById');
  @override
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range}) =>
      throw UnimplementedError('watchHistory');
  @override
  Stream<ManualFillFormSpec> watchManualFillFormSpec() =>
      throw UnimplementedError('watchManualFillFormSpec');
  @override
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId) =>
      throw UnimplementedError('fillsOfAdvice');
}

/// 🆕 계약 v1.12(01 §21 · K28) — [LedgerTrustRepository] 받침대(`L-3`·홈 블록 9b 가짜의 받침대).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m7/ledger_trust_*`·`m6/self_report_*` 픽스처를 override 로.
class UnimplementedLedgerTrustRepository implements LedgerTrustRepository {
  @override
  Stream<LedgerTrustBadge> watchGrade() =>
      throw UnimplementedError('watchGrade');
  @override
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  ) => throw UnimplementedError('watchSelfReportSession');
}

/// 🆕 계약 v1.12(01 §21 · K28) — [OpsSummaryRepository] 받침대(`H-01`·`H-02` 가짜의 받침대 · R13).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m8/ops_home_*`·`m8/ops_rhythm_*` 픽스처를 override 로.
class UnimplementedOpsSummaryRepository implements OpsSummaryRepository {
  @override
  Stream<OpsDailySummary> watchToday() =>
      throw UnimplementedError('watchToday');
  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() =>
      throw UnimplementedError('watchRhythm');
}

/// 🆕 계약 v1.15(01 §24 · K18) — [AlertRepository] 받침대(`N-01`·`N-02`·`S-01` 가짜의 받침대).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m8/alert_center_*`·`m8/alert_detail_*`·`alerts_*` 픽스처를 override 로.
class UnimplementedAlertRepository implements AlertRepository {
  @override
  Stream<List<AlertItem>> watchInbox({AlertLevel? min}) =>
      throw UnimplementedError('watchInbox');
  @override
  Stream<AlertCenterVm> watchCenter({required bool p0Only}) =>
      throw UnimplementedError('watchCenter');
  @override
  Stream<AlertDetailVm> watchAlert(String alertId) =>
      throw UnimplementedError('watchAlert');
}

/// 🆕 계약 v1.15(01 §24 · K18) — [OpsStatusRepository] 받침대(`W-01`·`H-01` 블록 6 가짜의 받침대 · 7메서드 전부(🆕 v1.17 `watchDeviceRisk`)).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m8/watchdog_*`·`m8/recon_board_*` 픽스처를 override 로.
class UnimplementedOpsStatusRepository implements OpsStatusRepository {
  @override
  Stream<WatchdogBoardVm> watchWatchdog() =>
      throw UnimplementedError('watchWatchdog');
  @override
  Stream<ConnectionsVm> watchConnections() =>
      throw UnimplementedError('watchConnections');
  @override
  Stream<DeviceAccessVm> watchDeviceAccess() =>
      throw UnimplementedError('watchDeviceAccess');
  @override
  Stream<BackupVm> watchBackup() => throw UnimplementedError('watchBackup');
  @override
  Stream<DiagnosticsVm> watchDiagnostics() =>
      throw UnimplementedError('watchDiagnostics');
  @override
  Stream<AnnualReviewVm> watchAnnualReview() =>
      throw UnimplementedError('watchAnnualReview');
  @override
  Stream<DeviceRiskVm> watchDeviceRisk() =>
      throw UnimplementedError('watchDeviceRisk');
}

/// 🆕 계약 v1.16(01 §25 · K30) — [OnboardingRepository] 받침대(`O-00`~`O-04`·`R-01` 가짜의 받침대 · 7메서드 전부).
/// 🔴 동기로 던진다. 값은 지어내지 않는다 — `m8/onboarding_*`·`m8/restart_vm_*` 픽스처를 override 로.
class UnimplementedOnboardingRepository implements OnboardingRepository {
  @override
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack t) =>
      throw UnimplementedError('watchSteps');
  @override
  Stream<OnboardingStartVm> watchStart() =>
      throw UnimplementedError('watchStart');
  @override
  Stream<OnboardingModeChoiceVm> watchModeChoice() =>
      throw UnimplementedError('watchModeChoice');
  @override
  Stream<OnboardingStepsVm> watchStepList() =>
      throw UnimplementedError('watchStepList');
  @override
  Stream<OnboardingStepDetailVm> watchStep(String stepId) =>
      throw UnimplementedError('watchStep');
  @override
  Stream<OnboardingFinishVm> watchFinish() =>
      throw UnimplementedError('watchFinish');
  @override
  Stream<RestartVm> watchRestart() => throw UnimplementedError('watchRestart');
}

/// 🆕 계약 v1.16(01 §25 · K30) — [PairingRepository] 받침대(`V-01` 가짜의 받침대). 🔴 동기로 던진다.
class UnimplementedPairingRepository implements PairingRepository {
  @override
  Stream<PairingVm> watchPairing() => throw UnimplementedError('watchPairing');
}

/// 🆕 계약 v1.17(01 §26 · K23) — [IncidentRepository] 받침대(`D-01` 가짜의 받침대). 🔴 동기로 던진다.
class UnimplementedIncidentRepository implements IncidentRepository {
  @override
  Stream<IncidentBannerVm> watchIncident() =>
      throw UnimplementedError('watchIncident');
}

/// 🆕 계약 v1.17(01 §26 · K23) — [RunbookRepository] 받침대(`D-02`·`D-03` 가짜의 받침대 · 3메서드 전부). 🔴 동기로 던진다.
class UnimplementedRunbookRepository implements RunbookRepository {
  @override
  Stream<RunbookIndexVm> watchRunbookIndex() =>
      throw UnimplementedError('watchRunbookIndex');

  @override
  Stream<RunbookVm> watchRunbook(String runbookId) =>
      throw UnimplementedError('watchRunbook');

  @override
  Stream<EmergencyCardVm> watchEmergencyCard() =>
      throw UnimplementedError('watchEmergencyCard');
}

/// 🆕 계약 v1.17(01 §26 · K23) — [HandbookRepository] 받침대(`B-01`·`B-02` 가짜의 받침대). 🔴 동기로 던진다.
class UnimplementedHandbookRepository implements HandbookRepository {
  @override
  Stream<HandbookIndex> watchIndex() => throw UnimplementedError('watchIndex');

  @override
  Stream<HandbookPage> watchPage(String anchor) =>
      throw UnimplementedError('watchPage');
}

/// 🆕 계약 v1.12(01 §21 · K9 · K28) — [SettingsActions] 받침대(`L-3` 세션 start·stop 가짜의 받침대).
///
/// 🔴 리포지토리 받침대와 달리 **동기로 던지지 않는다**([UnimplementedWhatIfApi] 선례) — `run` = `Future` 에러 ·
///    `watch` = 에러 스트림. `L-3` 은 `dispose` 에서 `initState` 에 잡아 둔 인스턴스로 stop 을 부르고 그 결과를
///    삼키므로(`.then((_) {}, onError: …)`), override 하지 않은 받침대를 주입해도 위젯 트리가 깨지지 않는다.
/// 🔴 결과(`ActionResult`)는 지어내지 않는다 — `L-3` 은 결과를 읽지 않는다(갈래 = `SelfReportSession.sessionClosedText`) ·
///    🆕 v1.16 `O-00b`·`O-03`·`O-04` 는 `run` 의 결과를 **읽는다** — 결과는 가짜가 픽스처(`m8/onboarding_*_results`)로 준다.
class UnimplementedSettingsActions implements SettingsActions {
  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) => Future<ActionResult>.error(UnimplementedError('run'));
  @override
  Stream<ActionResult> watch(String actionRunId) =>
      Stream<ActionResult>.error(UnimplementedError('watch'));
}

/// [JournalRepository] 받침대 — 필요한 메서드만 override 한다.
class UnimplementedJournalRepository implements JournalRepository {
  @override
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) => throw UnimplementedError('watchTimeline');

  @override
  Future<TradeJournalEntry?> findByDecisionId(String decisionId) =>
      throw UnimplementedError('findByDecisionId');

  @override
  Future<List<TradeJournalEntry>> chainOf(String decisionId) =>
      throw UnimplementedError('chainOf');

  @override
  Future<List<TradeJournalEntry>> fillChain(String entryId) =>
      throw UnimplementedError('fillChain');

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() =>
      throw UnimplementedError('watchFilterCatalog');

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => throw UnimplementedError('watchTimelineBadges');

  @override
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId) =>
      throw UnimplementedError('watchDecisionDetail');

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) =>
      throw UnimplementedError('draftFormSpec');

  @override
  Stream<UnknownBoardVm> watchUnknownBoard() =>
      throw UnimplementedError('watchUnknownBoard');

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) =>
      throw UnimplementedError('watchDecisionJournal');

  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) =>
      throw UnimplementedError('watchRebalanceScope');

  @override
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  }) => throw UnimplementedError('watchBlindReviewQueue');

  @override
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId) =>
      throw UnimplementedError('watchBlindReviewCard');
}

/// [PerformanceRepository] 받침대.
class UnimplementedPerformanceRepository implements PerformanceRepository {
  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  }) => throw UnimplementedError('series');

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) =>
      throw UnimplementedError('monthlyReport');

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      throw UnimplementedError('afterTaxLadder');

  @override
  Future<ReportArchiveVm> reportArchive() =>
      throw UnimplementedError('reportArchive');

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() =>
      throw UnimplementedError('watchDisclosureGate');

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) =>
      throw UnimplementedError('drawdownContext');

  @override
  Future<ContributionVm> contribution({required DateRange range}) =>
      throw UnimplementedError('contribution');

  @override
  Future<AnnualReviewVm> annualReview({String? year}) =>
      throw UnimplementedError('annualReview');

  /// 🆕 v1.4 — S7-9 목표 경로. 🔵 이 클래스의 관행대로 **동기로 던진다**(아래
  /// [UnimplementedWhatIfApi] 는 `Future` 에러 — 받침대마다 다르다는 것을 적어 둔다).
  @override
  Future<GoalPathVm> goalPath({required String yyyyMm}) =>
      throw UnimplementedError('goalPath');
}

/// [ConfigRepository] 받침대.
class UnimplementedConfigRepository implements ConfigRepository {
  @override
  Stream<FeatureFlags> watchFlags() => throw UnimplementedError('watchFlags');

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      throw UnimplementedError('watchSleeves');

  @override
  Stream<List<DateRange>> watchRangePresets() =>
      throw UnimplementedError('watchRangePresets');

  @override
  Stream<ContributionSetting> watchContributionSetting() =>
      throw UnimplementedError('watchContributionSetting');
}

/// 🆕 계약 v1.1 R2 준비(2026-09-23) — [CommandApi] 받침대(명령 13종 전부 · 🆕 v1.10 +1 · 🆕 v1.12 +1 = 15).
/// 필요한 명령만 override 한다.
/// 🆕 v1.12(01 §21 · K4) — X7 기록 3종의 인자 = 제출 DTO(`ManualFillSubmission`·`AdviceSkipSubmission`·
///    `SelfReportSubmission`) · 🆕 `deferAdviceConfirm(adviceId)`. 접수증은 `m6/manual_fill_receipts_7`·
///    `m6/advice_skip_receipts_5`·`m6/self_report_receipts_5`·`m6/advice_defer_receipts_3` 의 행을 `state` 로 골라 준다.
///
/// 🔴 override 하지 않은 명령을 부르면 곧바로 던진다. 탭·제출 **핸들러**에서 부른 것은
///    잡히지 않은 오류로 테스트가 실패한다(예: `J-3` 은 `submitJournalDraft`·`watchCommand`
///    둘뿐이다). 다만 프로바이더 **안에서** 부른 것은 에러 상태(`AsyncError`)로 삼켜질 수
///    있다 — 그래서 테스트는 에러 상태가 없음(정상 본문이 보임)을 함께 확인한다.
/// 🔴 접수증은 지어내지 않는다 — `m6/journal_draft_receipts_5.json` 같은 픽스처의 행을
///    `state` 로 골라 돌려준다(`stateLabel` 은 엔진 문구다).
class UnimplementedCommandApi implements CommandApi {
  @override
  Future<CommandReceipt> activateKillSwitch({
    required String reasonFreeText,
    required String deviceId,
  }) => throw UnimplementedError('activateKillSwitch');

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) =>
      throw UnimplementedError('submitJournalDraft');

  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) =>
      throw UnimplementedError('submitBlindReviewScore');

  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) =>
      throw UnimplementedError('recordDisclosureView');

  /// 🆕 v1.4 — 인자는 `DepositRegistration(planId:)` 하나다(01 §14-7).
  @override
  Future<CommandReceipt> registerDeposit(DepositRegistration registration) =>
      throw UnimplementedError('registerDeposit');

  @override
  Stream<CommandReceipt> watchCommand(String commandId) =>
      throw UnimplementedError('watchCommand');

  @override
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission) =>
      throw UnimplementedError('recordManualFill');

  @override
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment) =>
      throw UnimplementedError('amendManualFill');

  @override
  Future<CommandReceipt> voidManualFill(ManualFillVoid v) =>
      throw UnimplementedError('voidManualFill');

  @override
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission) =>
      throw UnimplementedError('skipAdvice');

  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) => throw UnimplementedError('submitSelfReportBalance');

  @override
  Future<CommandReceipt> acknowledgeAlert(String alertId) =>
      throw UnimplementedError('acknowledgeAlert');

  @override
  Future<CommandReceipt> confirmKillChecklist(KillChecklistAck ack) =>
      throw UnimplementedError('confirmKillChecklist');

  @override
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record) =>
      throw UnimplementedError('recordLedgerEvent');

  /// 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」.
  @override
  Future<CommandReceipt> deferAdviceConfirm(String adviceId) =>
      throw UnimplementedError('deferAdviceConfirm');
}

/// 🆕 계약 v1.4 R11 선행(2026-09-30) — [WhatIfApi] 받침대(미리보기 5종 · **전부 `Future` 에러**).
///
/// 🔴 다른 리포지토리 받침대(동기 throw)와 달리 **`Future` 에러**다([UnimplementedDraftStore]
///    선례) — 플래너(S7-4)는 `simulateDeposit` 의 `Future` 에러를 «계산 실패»(공통 에러 뷰 +
///    입력 유지 + 재시도)로 그리므로, override 하지 않은 메서드를 불러도 동기 예외로 위젯
///    트리가 깨지지 않고 그 갈래로 드러난다.
/// 🔴 결과는 지어내지 않는다 — `m7/m7_deposit_plan_*` 픽스처 행(`DepositPreviewResult`)을
///    `listFixture(...)` 로 열어 override 로 돌려준다. 🆕 v1.6 — `S7-6c` 는
///    `m7/m7_rebalance_preview_*` 픽스처 행(`RebalancePreviewResult`)을 같은 방식으로 돌려준다.
class UnimplementedWhatIfApi implements WhatIfApi {
  @override
  Future<DepositPreviewResult> simulateDeposit({required String amountInput}) =>
      Future<DepositPreviewResult>.error(UnimplementedError('simulateDeposit'));

  @override
  Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount}) =>
      Future<WithdrawalPlan>.error(UnimplementedError('simulateWithdrawal'));

  @override
  Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate}) =>
      Future<RebalancePreviewResult>.error(
        UnimplementedError('previewRebalance'),
      );

  @override
  Future<CostEstimate> estimateCosts(String planId) =>
      Future<CostEstimate>.error(UnimplementedError('estimateCosts'));

  @override
  Future<DepositPlan?> findPlan(String planId) =>
      Future<DepositPlan?>.error(UnimplementedError('findPlan'));
}

/// 🆕 계약 v1.1 R2 준비(2026-09-23) — [SafetyRepository] 받침대.
///
/// 🔴 안전 상태는 `safety_states.json` 의 행을 `SafetyState.fromJson` 으로 열어 준다 —
///    테스트가 `SafetyState(...)` 를 직접 짓지 않는다.
class UnimplementedSafetyRepository implements SafetyRepository {
  @override
  Stream<SafetyState> watchState() => throw UnimplementedError('watchState');
}

/// 🆕 계약 v1.2 — [DraftStore] 받침대(전부 `Future` 에러 · **초안 포트를 읽지 않는 화면**용).
///
/// 🔴 다른 받침대와 달리 **동기로 던지지 않는다** — 포트 계약이 «세 메서드는 동기로 던지지 않는다 ·
///    에러는 전부 `Future`»이기 때문이다(01 §12-1-2 · `DraftStore` 머리).
/// 🔴 `J-3` 테스트에는 쓰지 않는다 — `J-3` 은 마운트할 때마다 `load` 를 부르므로 이것을 주입하면
///    전부 에러 보고로 실패한다. `J-3` 테스트는 항상 [RecordingDraftStore](빈 것 포함)다.
class UnimplementedDraftStore implements DraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) =>
      Future<DraftRecord?>.error(UnimplementedError('load'));

  @override
  Future<void> save(DraftRecord record) =>
      Future<void>.error(UnimplementedError('save'));

  @override
  Future<void> clear(DraftKey key) =>
      Future<void>.error(UnimplementedError('clear'));
}

/// 🆕 계약 v1.2 — 메모리 [DraftStore] + **호출 기록**.
///
/// 🔴 값을 지어내지 않는다 — `load` 는 시드(픽스처 행)나 앞서 `save` 된 값만 돌려준다.
/// 🔴 계약 사후조건을 같이 지킨다 — 본문 칸이 `key.kind` 의 칸 1개가 아니면 `save` 가
///    `Future` 에러(`ArgumentError`)다.
/// 「재시작 생존」의 **화면층** 증명 = 같은 인스턴스로 위젯 트리를 내렸다가 새 `ProviderScope` 로
/// 다시 띄운다(실물 영속 증명은 06 M4-9).
///
///     final RecordingDraftStore store = RecordingDraftStore(
///       seed: <DraftRecord>[
///         listFixture(FixturePaths.m6DraftRecordsJ3, DraftRecord.fromJson).rows[1],
///       ],
///     );
///
/// 실패 재현은 `extends RecordingDraftStore` 로 `load`/`save` 만 `Future.error(...)` 로 override
/// 한다(받침대에 스위치를 두지 않는다).
class RecordingDraftStore implements DraftStore {
  RecordingDraftStore({Iterable<DraftRecord> seed = const <DraftRecord>[]}) {
    for (final DraftRecord r in seed) {
      _byKey[r.key] = r;
    }
  }

  final Map<DraftKey, DraftRecord> _byKey = <DraftKey, DraftRecord>{};

  /// `load` 에 넘어온 키 — 호출 순서 그대로.
  final List<DraftKey> loaded = <DraftKey>[];

  /// `save` 에 넘어온 레코드 — 호출 순서 그대로(거절된 것은 없다).
  final List<DraftRecord> saved = <DraftRecord>[];

  /// `clear` 에 넘어온 키 — 호출 순서 그대로.
  final List<DraftKey> cleared = <DraftKey>[];

  /// 지금 들고 있는 값(단언용).
  DraftRecord? current(DraftKey key) => _byKey[key];

  @override
  Future<DraftRecord?> load(DraftKey key) {
    loaded.add(key);
    return Future<DraftRecord?>.value(_byKey[key]);
  }

  @override
  Future<void> save(DraftRecord record) {
    if (!_bodyMatchesKind(record)) {
      return Future<void>.error(
        ArgumentError(
          'DraftRecord body slot must be exactly the one of key.kind',
        ),
      );
    }
    saved.add(record);
    _byKey[record.key] = record;
    return Future<void>.value();
  }

  @override
  Future<void> clear(DraftKey key) {
    cleared.add(key);
    _byKey.remove(key);
    return Future<void>.value();
  }
}

bool _bodyMatchesKind(DraftRecord r) {
  final int filled = <Object?>[
    r.journal,
    r.manualFill,
    r.adviceSkip,
    r.selfReport,
  ].where((Object? b) => b != null).length;
  if (filled != 1) {
    return false;
  }
  return switch (r.key.kind) {
    DraftKind.journalDraft => r.journal != null,
    DraftKind.manualFillRecord => r.manualFill != null,
    DraftKind.adviceSkip => r.adviceSkip != null,
    DraftKind.selfReportBalance => r.selfReport != null,
  };
}

/// 넘어온 링크를 **순서대로 기록**하는 [AppLinkOpener] — 「DTO 의 링크가 그대로 전달됐는가」를
/// 확인할 때 쓴다(01 §4-4).
///
///     final RecordingLinkOpener opener = RecordingLinkOpener();
///     ... 탭 ...
///     expect(opener.opened, <String>[entry.detailDeepLink!]);
class RecordingLinkOpener implements AppLinkOpener {
  /// `open` 에 넘어온 문자열 — 호출 순서 그대로.
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}
