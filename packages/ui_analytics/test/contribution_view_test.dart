// packages/ui_analytics/test/contribution_view_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

class FakePerformanceRepository implements PerformanceRepository {
  FakePerformanceRepository({this.contributionVm});

  final ContributionVm? contributionVm;

  @override
  Future<ContributionVm> contribution({required DateRange range}) async {
    final vm = contributionVm;
    if (vm != null) {
      return vm;
    }
    throw UnimplementedError();
  }

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) =>
      throw UnimplementedError();

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) =>
      throw UnimplementedError();

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required DateRange range,
  }) => throw UnimplementedError();

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      throw UnimplementedError();

  @override
  Future<ReportArchiveVm> reportArchive() => throw UnimplementedError();

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() => throw UnimplementedError();

  @override
  Future<AnnualReviewVm> annualReview({required String year}) =>
      throw UnimplementedError();
}

class FakeSafetyRepository implements SafetyRepository {
  FakeSafetyRepository(this._state);

  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final contrib = singleFixture(
    FixturePaths.m7M7Contrib3sleeve,
    ContributionVm.fromJson,
  );
  final safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);
  final safetyRow0 = SafetyState.fromJson(safetyEnvelope.rows[0]);
  const testRange = DateRange(
    from: TradeDate('2026-08-01'),
    to: TradeDate('2026-08-31'),
    presetCode: 'FIXTURE',
  );

  testWidgets('S7-3b 기여 분해 픽스처 렌더 검증: 슬리브 행·기여도·산식 주석 표시', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(contributionVm: contrib),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContributionScreen(range: testRange)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(contrib.periodLabel), findsOneWidget);
    for (final row in contrib.rows) {
      expect(find.text(row.label), findsOneWidget);
      expect(find.text(row.contributionText), findsOneWidget);
    }
    expect(find.text(contrib.methodNoteText), findsOneWidget);
    if (contrib.fxNoteText != null) {
      expect(find.text(contrib.fxNoteText!), findsOneWidget);
    }
  });

  testWidgets('S7-3b 신선도 검사: staleAfter 초과 시 오래된 데이터 배너 노출', (
    WidgetTester tester,
  ) async {
    final expiredClock = FixedClock(kGoldenNowUtc.add(const Duration(days: 3)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(expiredClock),
          performanceRepositoryProvider.overrideWithValue(
            FakePerformanceRepository(contributionVm: contrib),
          ),
          safetyRepositoryProvider.overrideWithValue(
            FakeSafetyRepository(safetyRow0),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ContributionScreen(range: testRange)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
  });
}
