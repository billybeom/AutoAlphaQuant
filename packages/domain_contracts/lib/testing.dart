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
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다 — `test/` 에서만 쓴다(배럴에 없다).
// 🔴 받침대는 **값을 지어내지 않는다** — 기본 동작은 전부 `UnimplementedError` 다. 값은
//    픽스처에서 읽어 override 로 준다(01 §5).

import 'domain_contracts.dart';

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
}

/// [PerformanceRepository] 받침대.
class UnimplementedPerformanceRepository implements PerformanceRepository {
  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required DateRange range,
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
  Future<AnnualReviewVm> annualReview({required String year}) =>
      throw UnimplementedError('annualReview');
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
