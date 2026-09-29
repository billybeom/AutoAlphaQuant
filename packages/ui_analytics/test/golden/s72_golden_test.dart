// test/golden/s72_golden_test.dart
// S7-2 수익률 탐색 골든 — 12장
//   (s72_monthly_cum · s72_daily_gap · s72_sim_split · s72_manual_segment ·
//    s72_monthly_period · s72_unavailable × light/dark)
//
// 📐 크기: 390 × 1400
// 🔴 찍기 전 위치 전제 — s72-link-contribution 의 아래 끝 < 1400.
// 🔴 모든 테스트는 게이트를 실제로 눌러 통과한 뒤 본문을 찍는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/l10n/labels.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../explore_fakes.dart';
import 'golden_support.dart';

const Size kS72GoldenSize = Size(390, 1400);

void main() {
  final DisclosureGateVm gateOpen = listFixture(
    FixturePaths.m7M7DisclosureGate,
    DisclosureGateVm.fromJson,
  ).rows[0];

  final PerformanceSeries monthlyCum = listFixture(
    FixturePaths.performance24m,
    PerformanceSeries.fromJson,
  ).rows[0];

  final PerformanceSeries dailyGap = singleFixture(
    FixturePaths.m7M7PerfDailyGap,
    PerformanceSeries.fromJson,
  );

  final PerformanceSeries simSplit = singleFixture(
    FixturePaths.m7M7PerfMonthlySimSplit,
    PerformanceSeries.fromJson,
  );

  final PerformanceSeries dailyManual = singleFixture(
    FixturePaths.m7M7PerfDailyManual,
    PerformanceSeries.fromJson,
  );

  final PerformanceSeries monthlyPeriod = singleFixture(
    FixturePaths.m7M7PerfMonthlyPeriod,
    PerformanceSeries.fromJson,
  );

  final PerformanceSeries unavailable = singleFixture(
    FixturePaths.m7M7PerfUnavailableGap,
    PerformanceSeries.fromJson,
  );

  // ── s72_monthly_cum ────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_monthly_cum ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: monthlyCum,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_monthly_cum', b);
    });
  }

  // ── s72_daily_gap ──────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_daily_gap ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: dailyGap,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_daily_gap', b);
    });
  }

  // ── s72_sim_split ──────────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_sim_split ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: simSplit,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_sim_split', b);
    });
  }

  // ── s72_manual_segment ────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_manual_segment ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: dailyManual,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_manual_segment', b);
    });
  }

  // ── s72_monthly_period ────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_monthly_period ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: monthlyPeriod,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.tap(find.text(AnalyticsLabels.cumulativeOff));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_monthly_period', b);
    });
  }

  // ── s72_unavailable ───────────────────────────────────────────────────────
  for (final Brightness b in Brightness.values) {
    testWidgets('s72_unavailable ${brightnessSuffix(b)}', (
      WidgetTester tester,
    ) async {
      final repo = FakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(gateOpen),
        seriesResult: unavailable,
      );
      final api = FakeCommandApi();

      await pumpForGolden(
        tester,
        ProviderScope(
          overrides: exploreOverrides(repo: repo, commandApi: api),
          child: const PerformanceExploreScreen(),
        ),
        brightness: b,
        logicalSize: kS72GoldenSize,
      );

      await passGate(tester);
      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .getBottomLeft(find.byKey(const Key('s72-link-contribution')))
            .dy,
        lessThan(kS72GoldenSize.height),
      );

      await expectGolden('s72_unavailable', b);
    });
  }
}
