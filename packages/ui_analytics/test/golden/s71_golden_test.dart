// packages/ui_analytics/test/golden/s71_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden_support.dart';

class _FakePerformanceRepository extends UnimplementedPerformanceRepository {
  _FakePerformanceRepository(this._report);
  final MonthlyReport _report;

  @override
  Future<MonthlyReport> monthlyReport(String yyyyMm) async => _report;
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
  final maskedIntegrity = singleFixture(
    FixturePaths.m7M7MonthlyMaskedIntegrity,
    MonthlyReport.fromJson,
  );
  final maskedRecon = singleFixture(
    FixturePaths.m7M7MonthlyMaskedRecon,
    MonthlyReport.fromJson,
  );

  final safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);
  final safetyRow0 = SafetyState.fromJson(safetyEnvelope.rows[0]);
  final safetyRow3 = SafetyState.fromJson(safetyEnvelope.rows[3]);
  final safetyRow4 = SafetyState.fromJson(safetyEnvelope.rows[4]);

  final testCases = <(String, MonthlyReport, SafetyState)>[
    ('s71_normal', normal, safetyRow0),
    ('s71_partial_gap', gap, safetyRow0),
    ('s71_not_generated', pending, safetyRow0),
    ('s71_masked_integrity', maskedIntegrity, safetyRow4),
    ('s71_masked_recon', maskedRecon, safetyRow3),
  ];

  for (final (name, report, safetyState) in testCases) {
    for (final b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: <Override>[
              analyticsClockProvider.overrideWithValue(
                FixedClock(kGoldenNowUtc),
              ),
              analyticsLinkOpenerProvider.overrideWithValue(
                RecordingLinkOpener(),
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
