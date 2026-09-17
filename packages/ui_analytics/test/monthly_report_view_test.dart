// packages/ui_analytics/test/monthly_report_view_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';

class FakePerformanceRepository implements PerformanceRepository {
  FakePerformanceRepository(this._report);
  final MonthlyReport _report;

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async => _report;

  @override
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    required DateRange range,
  }) =>
      throw UnimplementedError();

  @override
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear}) =>
      throw UnimplementedError();

  @override
  Future<ReportArchiveVm> reportArchive() => throw UnimplementedError();

  @override
  Stream<DisclosureGateVm> watchDisclosureGate() => throw UnimplementedError();

  @override
  Future<DrawdownContextVm> drawdownContext({DateRange? range}) =>
      throw UnimplementedError();

  @override
  Future<ContributionVm> contribution({required DateRange range}) =>
      throw UnimplementedError();

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
  final report = singleFixture(
    FixturePaths.m7M7Monthly202608,
    MonthlyReport.fromJson,
  );
  final safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);
  final safetyRow0 = SafetyState.fromJson(safetyEnvelope.rows[0]);
  final safetyRow1 = SafetyState.fromJson(safetyEnvelope.rows[1]);
  final safetyRow3 = SafetyState.fromJson(safetyEnvelope.rows[3]);

  testWidgets('S7-1 13개 항목 title 전수 렌더 및 픽스처 데이터 표시 검증',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider
              .overrideWithValue(FakePerformanceRepository(report)),
          safetyRepositoryProvider
              .overrideWithValue(FakeSafetyRepository(safetyRow0)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: report.yyyyMm),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (final item in report.items) {
      expect(find.text(item.title), findsOneWidget);
      expect(find.text(item.valueText), findsOneWidget);
    }

    expect(find.text(report.trust.label), findsOneWidget);
    expect(find.text(report.goalLine), findsOneWidget);
    expect(find.text(report.disclosureViewCountText), findsOneWidget);
    if (report.backdateFootnote != null) {
      expect(find.text(report.backdateFootnote!), findsOneWidget);
    }
  });

  testWidgets('S7-1 신선도 검사: staleAfter 초과 시 오래된 데이터 제목 노출',
      (WidgetTester tester) async {
    final expiredClock = FixedClock(kGoldenNowUtc.add(const Duration(days: 3)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(expiredClock),
          performanceRepositoryProvider
              .overrideWithValue(FakePerformanceRepository(report)),
          safetyRepositoryProvider
              .overrideWithValue(FakeSafetyRepository(safetyRow0)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: report.yyyyMm),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
  });

  testWidgets('S7-1 차단 배너 label 표시 검증 (safety_states row 3)',
      (WidgetTester tester) async {
    final blockingFlag = safetyRow3.activeFlags.firstWhere(
      (f) => !FlagIds.markerOnly.contains(f.flagId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider
              .overrideWithValue(FakePerformanceRepository(report)),
          safetyRepositoryProvider
              .overrideWithValue(FakeSafetyRepository(safetyRow3)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: report.yyyyMm),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(blockingFlag.label), findsOneWidget);
    expect(find.text(blockingFlag.clearInstruction), findsOneWidget);
  });

  testWidgets('S7-1 표식 칩 표시 검증 (safety_states row 1 SELF_AUDIT_DUE)',
      (WidgetTester tester) async {
    final markerFlag = safetyRow1.activeFlags.firstWhere(
      (f) => FlagIds.markerOnly.contains(f.flagId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyticsClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          performanceRepositoryProvider
              .overrideWithValue(FakePerformanceRepository(report)),
          safetyRepositoryProvider
              .overrideWithValue(FakeSafetyRepository(safetyRow1)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MonthlyReportScreen(yyyyMm: report.yyyyMm),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(markerFlag.label), findsOneWidget);
  });
}
