// packages/ui_analytics/test/golden/s71_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden_support.dart';

class _FakePerformanceRepository implements PerformanceRepository {
  _FakePerformanceRepository(this._report);
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

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

void main() {
  final normal = singleFixture(
    FixturePaths.m7M7Monthly202608,
    MonthlyReport.fromJson,
  );
  final gap = singleFixture(
    FixturePaths.m7M7MonthlyGap,
    MonthlyReport.fromJson,
  );
  final pending = singleFixture(
    FixturePaths.m7M7MonthlyPending,
    MonthlyReport.fromJson,
  );
  final safetyState = SafetyState.fromJson(
    fixtureEnvelope(FixturePaths.safetyStates).rows[0],
  );

  final testCases = <(String, MonthlyReport)>[
    ('s71_normal', normal),
    ('s71_partial_gap', gap),
    ('s71_not_generated', pending),
  ];

  for (final (name, report) in testCases) {
    for (final b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: <Override>[
              analyticsClockProvider.overrideWithValue(
                FixedClock(kGoldenNowUtc),
              ),
              performanceRepositoryProvider.overrideWithValue(
                _FakePerformanceRepository(report),
              ),
              safetyRepositoryProvider.overrideWithValue(
                _FakeSafetyRepository(safetyState),
              ),
            ],
            child: MonthlyReportScreen(yyyyMm: report.yyyyMm),
          ),
          brightness: b,
        );
        await expectGolden(name, b);
      });
    }
  }
}
