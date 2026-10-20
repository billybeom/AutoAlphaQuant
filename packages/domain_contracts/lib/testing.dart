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
//
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다 — `test/` 에서만 쓴다(배럴에 없다).
// 🔴 받침대는 **값을 지어내지 않는다** — 기본 동작은 전부 `UnimplementedError` 다. 값은
//    픽스처에서 읽어 override 로 준다(01 §5).

import 'package:decimal/decimal.dart';

import 'domain_contracts.dart';

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

/// 🆕 계약 v1.1 R2 준비(2026-09-23) — [CommandApi] 받침대(명령 13종 전부).
/// 필요한 명령만 override 한다.
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
  Future<CommandReceipt> recordManualFill(ManualFillRecord record) =>
      throw UnimplementedError('recordManualFill');

  @override
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment) =>
      throw UnimplementedError('amendManualFill');

  @override
  Future<CommandReceipt> voidManualFill(ManualFillVoid v) =>
      throw UnimplementedError('voidManualFill');

  @override
  Future<CommandReceipt> skipAdvice(AdviceSkip skip) =>
      throw UnimplementedError('skipAdvice');

  @override
  Future<CommandReceipt> submitSelfReportBalance(SelfReportBalance b) =>
      throw UnimplementedError('submitSelfReportBalance');

  @override
  Future<CommandReceipt> acknowledgeAlert(AlertAck ack) =>
      throw UnimplementedError('acknowledgeAlert');

  @override
  Future<CommandReceipt> confirmKillChecklist(KillChecklistAck ack) =>
      throw UnimplementedError('confirmKillChecklist');
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
