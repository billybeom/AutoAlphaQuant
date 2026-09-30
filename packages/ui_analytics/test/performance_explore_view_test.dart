// test/performance_explore_view_test.dart

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/l10n/labels.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';

import 'explore_fakes.dart';
import 'golden/chart_probe.dart';
import 'golden/golden_support.dart';

void main() {
  DisclosureGateVm openGate() =>
      singleFixture(FixturePaths.m7M7DisclosureGate, DisclosureGateVm.fromJson);

  CommandReceipt receipt0() => listFixture(
    FixturePaths.m7M7DisclosureViewReceipts4,
    CommandReceipt.fromJson,
  ).rows[0];

  group('PerformanceExploreView - E1 to E8 toggle interactions', () {
    testWidgets('E1 pass gate records initial series query', (tester) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      expect(repo.seriesCalls.length, 1);
      final call = repo.seriesCalls[0];
      expect(call.metric, PerfMetric.twr);
      expect(call.granularity, PerfGranularity.monthly);
      expect(call.cumulative, isTrue);
      expect(call.range, isNull);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E2 switch to mwr records metric mwr', (tester) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      await tester.tap(find.text(AnalyticsLabels.metricMwr));
      await tester.pump();
      await tester.pump();

      expect(repo.seriesCalls.length, 2);
      final last = repo.seriesCalls.last;
      expect(last.metric, PerfMetric.mwr);
      expect(last.granularity, PerfGranularity.monthly);
      expect(last.cumulative, isTrue);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E3 switch to daily records granularity daily', (tester) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();
      await tester.pump();

      expect(repo.seriesCalls.length, 2);
      final last = repo.seriesCalls.last;
      expect(last.metric, PerfMetric.twr);
      expect(last.granularity, PerfGranularity.daily);
      expect(last.cumulative, isTrue);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E4 switch to yearly records granularity yearly', (
      tester,
    ) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      await tester.tap(find.text(AnalyticsLabels.granularityYearly));
      await tester.pump();
      await tester.pump();

      expect(repo.seriesCalls.length, 2);
      final last = repo.seriesCalls.last;
      expect(last.metric, PerfMetric.twr);
      expect(last.granularity, PerfGranularity.yearly);
      expect(last.cumulative, isTrue);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E5 switch to period records cumulative false', (tester) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      await tester.tap(find.text(AnalyticsLabels.cumulativeOff));
      await tester.pump();
      await tester.pump();

      expect(repo.seriesCalls.length, 2);
      final last = repo.seriesCalls.last;
      expect(last.metric, PerfMetric.twr);
      expect(last.granularity, PerfGranularity.monthly);
      expect(last.cumulative, isFalse);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets(
      'E6 switch monthly to daily to monthly calls series each time',
      (tester) async {
        final repo = TableFakePerformanceRepository(
          gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
        );
        final commandApi = FakeCommandApi();

        await pumpExplore(tester, repo: repo, commandApi: commandApi);
        await passGate(tester);
        await tester.pump();
        expect(repo.seriesCalls.length, 1);

        await tester.tap(find.text(AnalyticsLabels.granularityDaily));
        await tester.pump();
        await tester.pump();
        expect(repo.seriesCalls.length, 2);

        await tester.tap(find.text(AnalyticsLabels.granularityMonthly));
        await tester.pump();
        await tester.pump();
        expect(repo.seriesCalls.length, 3);
        expect(repo.seriesCalls.last.granularity, PerfGranularity.monthly);
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      },
    );

    testWidgets('E8 no weekly segment in granularity toggle', (tester) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      final segBtn = tester.widget<SegmentedButton<PerfGranularity>>(
        find.byKey(const Key('s72-toggle-granularity')),
      );
      final segValues = segBtn.segments.map((s) => s.value).toList();
      expect(segValues, <PerfGranularity>[
        PerfGranularity.daily,
        PerfGranularity.monthly,
        PerfGranularity.yearly,
      ]);
      expect(find.text(AnalyticsLabels.granularityDaily), findsOneWidget);
      expect(find.text(AnalyticsLabels.granularityMonthly), findsOneWidget);
      expect(find.text(AnalyticsLabels.granularityYearly), findsOneWidget);

      expect(repo.seriesCalls, hasLength(1));
      for (final call in repo.seriesCalls) {
        expect(call.granularity, isNot(PerfGranularity.weekly));
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  });

  group('PerformanceExploreView - E9 to E10 error and loading', () {
    testWidgets('E9 error view with retry and persistent safety banner', (
      tester,
    ) async {
      final safety3 = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[3],
      );
      final repo = ThrowingFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        safetyState: safety3,
      );
      await passGate(tester);
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
      final errorView = tester.widget<AnalyticsErrorView>(
        find.byType(AnalyticsErrorView),
      );
      expect(errorView.lastAsOfLabel, isNull);

      expect(find.byKey(const Key('s72-disclosure')), findsNothing);
      expect(find.byKey(const Key('s72-link-drawdown')), findsNothing);
      expect(find.byKey(const Key('s72-link-contribution')), findsNothing);

      expect(safety3.activeFlags, hasLength(2));
      for (final flag in safety3.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }

      await tester.tap(find.text(AnalyticsLabels.retryButton));
      await tester.pump();

      expect(repo.seriesCalls.length, 2);
      expect(repo.seriesCalls[1].metric, repo.seriesCalls[0].metric);
      expect(repo.seriesCalls[1].granularity, repo.seriesCalls[0].granularity);
      expect(repo.seriesCalls[1].cumulative, repo.seriesCalls[0].cumulative);
    });

    testWidgets('E10 loading skeleton with persistent safety banner', (
      tester,
    ) async {
      final safety3 = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[3],
      );
      final completer = Completer<PerformanceSeries>();
      final repo = CompleterFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
        completer: completer,
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        safetyState: safety3,
      );
      await passGate(tester);
      await tester.pump();

      // First query complete
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);

      // Trigger re-query by switching to daily (completer hangs)
      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();

      expect(find.byKey(const Key('s72-toggle-metric')), findsOneWidget);
      expect(find.byKey(const Key('s72-toggle-granularity')), findsOneWidget);
      expect(find.byKey(const Key('s72-toggle-cumulative')), findsOneWidget);
      expect(find.byKey(kChartProbeKey), findsNothing);

      expect(find.byType(AnalyticsSkeleton), findsOneWidget);
      final skel = tester.widget<AnalyticsSkeleton>(
        find.byType(AnalyticsSkeleton),
      );
      expect(skel.blocks, 3);

      expect(find.byKey(const Key('s72-disclosure')), findsNothing);
      expect(find.byKey(const Key('s72-link-drawdown')), findsNothing);
      expect(find.byKey(const Key('s72-link-contribution')), findsNothing);

      expect(safety3.activeFlags, hasLength(2));
      for (final flag in safety3.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }

      completer.complete(
        singleFixture(
          FixturePaths.m7M7PerfDailyGap,
          PerformanceSeries.fromJson,
        ),
      );
      await tester.pump();
    });
  });

  group('PerformanceExploreView - E11 to E19 fixtures rendering', () {
    final normalFixtureList = <PerformanceSeries>[
      listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows[0],
      listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows[1],
      singleFixture(FixturePaths.m7M7PerfDailyGap, PerformanceSeries.fromJson),
      singleFixture(
        FixturePaths.m7M7PerfMonthlySimSplit,
        PerformanceSeries.fromJson,
      ),
      singleFixture(
        FixturePaths.m7M7PerfDailyManual,
        PerformanceSeries.fromJson,
      ),
      singleFixture(
        FixturePaths.m7M7PerfMonthlyPeriod,
        PerformanceSeries.fromJson,
      ),
      singleFixture(FixturePaths.m7M7PerfYearly, PerformanceSeries.fromJson),
    ];

    final allNineSeries = <PerformanceSeries>[
      ...normalFixtureList,
      singleFixture(
        FixturePaths.m7M7PerfUnavailableGap,
        PerformanceSeries.fromJson,
      ),
      singleFixture(
        FixturePaths.m7M7PerfMaskedIntegrity,
        PerformanceSeries.fromJson,
      ),
    ];

    testWidgets('E11 disclosure lines rendered across all 9 series', (
      tester,
    ) async {
      for (final s in allNineSeries) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        expect(find.text(s.disclosure.sampleSizeLine), findsOneWidget);
        expect(find.text(s.disclosure.honestExpectationLine), findsOneWidget);
        expect(s.disclosure.drawdownCaveatLine, isNotNull);
        expect(find.text(s.disclosure.drawdownCaveatLine!), findsOneWidget);
        expect(find.text(s.disclosure.interstitialText), findsNothing);
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E12 main line probe matches across 7 normal series', (
      tester,
    ) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        final scheme = chartSchemeOf(tester);
        final recording = recordChart(tester);
        expectMainLineMatches(recording, s, scheme);
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E13 bands probe matches across 7 normal series', (
      tester,
    ) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        final scheme = chartSchemeOf(tester);
        final recording = recordChart(tester);
        expectBandsMatch(recording, s, scheme);
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E14 benchmark probe and legend across 7 normal series', (
      tester,
    ) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        final scheme = chartSchemeOf(tester);
        final recording = recordChart(tester);
        expectBenchmarkMatches(recording, s, scheme);

        if (s.benchmark != null) {
          expect(find.byKey(const Key('s72-legend-benchmark')), findsOneWidget);
          expect(find.byKey(const Key('s72-benchmark-note')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('s72-legend-benchmark')), findsNothing);
          expect(find.byKey(const Key('s72-benchmark-note')), findsNothing);
        }
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E15 ticks probe matches and labels on left', (tester) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        final scheme = chartSchemeOf(tester);
        final recording = recordChart(tester);
        expectTicksMatch(recording, s, scheme);

        final chartRect = tester.getRect(find.byKey(kChartProbeKey));
        for (var i = 0; i < s.yTicks.length; i++) {
          final tickKey = Key('s72-tick-$i');
          expect(find.byKey(tickKey), findsOneWidget);
          final tickText = find.text(s.yTicks[i].label);
          expect(tickText, findsOneWidget);
          final tickRect = tester.getRect(find.byKey(tickKey));
          expect(tickRect.right, lessThanOrEqualTo(chartRect.left));
        }
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E16 segment captions only for non-measured segments', (
      tester,
    ) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        for (var i = 0; i < s.segments.length; i++) {
          final seg = s.segments[i];
          final capKey = ValueKey<String>('s72-segment-caption-$i');
          if (seg.kind != SegmentKind.measured) {
            expect(find.byKey(capKey), findsOneWidget);
            expect(find.text(seg.label), findsOneWidget);
          } else {
            expect(find.byKey(capKey), findsNothing);
            expect(find.text(seg.label), findsNothing);
          }
        }
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets(
      'E18 unavailable series shows card and hides chart components',
      (tester) async {
        final unavailList = <PerformanceSeries>[
          singleFixture(
            FixturePaths.m7M7PerfUnavailableGap,
            PerformanceSeries.fromJson,
          ),
          singleFixture(
            FixturePaths.m7M7PerfMaskedIntegrity,
            PerformanceSeries.fromJson,
          ),
        ];

        for (final s in unavailList) {
          final repo = FakePerformanceRepository(seriesResult: s);
          final commandApi = FakeCommandApi();

          await pumpExplore(
            tester,
            repo: repo,
            commandApi: commandApi,
            bodyReceipt: receipt0(),
          );

          expect(find.text(s.unavailableLabel!), findsOneWidget);
          expect(find.byKey(kChartProbeKey), findsNothing);
          expect(find.byKey(const Key('s72-legend-main')), findsNothing);
          expect(find.byKey(const Key('s72-values-toggle')), findsNothing);
          expect(find.byKey(const Key('s72-disclosure')), findsOneWidget);
          expect(find.byKey(const Key('s72-link-drawdown')), findsOneWidget);
          expect(
            find.byKey(const Key('s72-link-contribution')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('s72-tick-0')), findsNothing);
          expect(find.text(AnalyticsLabels.retryButton), findsNothing);
        }
      },
    );

    testWidgets('E19 labels and x bounds alignment across 7 normal series', (
      tester,
    ) async {
      for (final s in normalFixtureList) {
        final repo = FakePerformanceRepository(seriesResult: s);
        final commandApi = FakeCommandApi();

        await pumpExplore(
          tester,
          repo: repo,
          commandApi: commandApi,
          bodyReceipt: receipt0(),
        );

        expect(find.text(s.points.first.dateText), findsOneWidget);
        expect(find.text(s.points.last.dateText), findsOneWidget);
        expect(find.text(s.periodLabel), findsOneWidget);
        expect(find.text(s.seriesLabel), findsOneWidget);
        expect(find.text(s.asOf.label), findsOneWidget);

        final xFirstTopLeft = tester.getTopLeft(
          find.byKey(const Key('s72-x-first')),
        );
        final chartRect = tester.getRect(find.byKey(kChartProbeKey));
        expect(xFirstTopLeft.dx, equals(chartRect.left));
        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      }
    });

    testWidgets('E20 navigation buttons open routes', (tester) async {
      final s = normalFixtureList[0];
      final opener = RecordingLinkOpener();
      final repo = FakePerformanceRepository(seriesResult: s);
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        opener: opener,
        bodyReceipt: receipt0(),
      );

      await tester.tap(find.byKey(const Key('s72-link-drawdown')));
      expect(opener.opened, <String>[AppRoutes.performanceDrawdown]);

      await tester.tap(find.byKey(const Key('s72-link-contribution')));
      expect(opener.opened, <String>[
        AppRoutes.performanceDrawdown,
        AppRoutes.performanceContribution,
      ]);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E21 clock +3 days and safety states', (tester) async {
      final s = normalFixtureList[0];
      final repo = FakePerformanceRepository(seriesResult: s);
      final commandApi = FakeCommandApi();
      final safety3 = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[3],
      );

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 3))),
        safetyState: safety3,
        bodyReceipt: receipt0(),
      );

      expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      expect(safety3.activeFlags, hasLength(2));
      for (final flag in safety3.activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('E22 layout order caption disclosure note values links', (
      tester,
    ) async {
      double topOf(String k) => tester.getTopLeft(find.byKey(Key(k))).dy;

      for (final s in normalFixtureList) {
        await pumpExplore(
          tester,
          repo: FakePerformanceRepository(seriesResult: s),
          commandApi: FakeCommandApi(),
          bodyReceipt: receipt0(),
        );

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
        expect(
          topOf('s72-legend-main'),
          lessThan(topOf('s72-disclosure')),
        ); // 8 < 10

        for (var i = 0; i < s.segments.length; i++) {
          if (s.segments[i].kind != SegmentKind.measured) {
            expect(
              topOf('s72-segment-caption-$i'),
              lessThan(topOf('s72-disclosure')),
            ); // 9 < 10
          } else {
            expect(
              find.byKey(ValueKey<String>('s72-segment-caption-$i')),
              findsNothing,
            );
          }
        }

        if (s.benchmark != null) {
          expect(
            topOf('s72-disclosure'),
            lessThan(topOf('s72-benchmark-note')),
          ); // 10 < 11
          expect(
            topOf('s72-benchmark-note'),
            lessThan(topOf('s72-values-toggle')),
          ); // 11 < 12
        } else {
          expect(find.byKey(const Key('s72-benchmark-note')), findsNothing);
          expect(
            topOf('s72-disclosure'),
            lessThan(topOf('s72-values-toggle')),
          ); // 10 < 12
        }

        expect(
          topOf('s72-values-toggle'),
          lessThan(topOf('s72-link-drawdown')),
        ); // 12 < 13
      }

      for (final s in <PerformanceSeries>[
        singleFixture(
          FixturePaths.m7M7PerfUnavailableGap,
          PerformanceSeries.fromJson,
        ),
        singleFixture(
          FixturePaths.m7M7PerfMaskedIntegrity,
          PerformanceSeries.fromJson,
        ),
      ]) {
        await pumpExplore(
          tester,
          repo: FakePerformanceRepository(seriesResult: s),
          commandApi: FakeCommandApi(),
          bodyReceipt: receipt0(),
        );

        expect(find.text(AnalyticsLabels.retryButton), findsNothing);
        expect(topOf('s72-unavailable'), lessThan(topOf('s72-disclosure')));
        expect(topOf('s72-disclosure'), lessThan(topOf('s72-link-drawdown')));
      }
    });
  });

  group('PerformanceExploreView - V1 to V3 values table', () {
    testWidgets('V1 values table initially collapsed', (tester) async {
      final s = listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows[0];
      final repo = FakePerformanceRepository(seriesResult: s);
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        bodyReceipt: receipt0(),
      );

      expect(find.byKey(const Key('s72-value-row-0')), findsNothing);
      expect(find.text(AnalyticsLabels.valuesShowButton), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('V2 values table expanded with benchmark', (tester) async {
      final s = listFixture(
        FixturePaths.performance24m,
        PerformanceSeries.fromJson,
      ).rows[0];
      final repo = FakePerformanceRepository(seriesResult: s);
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        bodyReceipt: receipt0(),
      );

      await tester.tap(find.byKey(const Key('s72-values-toggle')));
      await tester.pump();

      expect(find.text(AnalyticsLabels.valuesHideButton), findsOneWidget);
      expect(find.text(AnalyticsLabels.valuesColumnBenchmark), findsOneWidget);

      final rowCount = s.points.length;
      for (var i = 0; i < rowCount; i++) {
        expect(
          find.byKey(ValueKey<String>('s72-value-row-$i')),
          findsOneWidget,
        );
      }

      int? missingIdx;
      for (var i = 0; i < s.points.length; i++) {
        if (s.points[i].yNormalized == null) {
          missingIdx = i;
          break;
        }
      }
      expect(missingIdx, isNotNull); // 전제 — 두 픽스처 모두 결측 점이 있다

      final checkIndices = <int>[0, missingIdx!, s.points.length - 1];

      for (final idx in checkIndices) {
        final rowTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('s72-value-row-$idx')),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data)
            .toList();

        final expected = <String>[
          s.points[idx].dateText,
          s.points[idx].valueText,
          s.benchmark!.points[idx].valueText,
        ];
        expect(rowTexts, equals(expected));
      }
      expect(
        find.byKey(ValueKey<String>('s72-value-row-${s.points.length}')),
        findsNothing,
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('V2 without benchmark', (tester) async {
      final s = singleFixture(
        FixturePaths.m7M7PerfDailyGap,
        PerformanceSeries.fromJson,
      );
      final repo = FakePerformanceRepository(seriesResult: s);
      final commandApi = FakeCommandApi();

      await pumpExplore(
        tester,
        repo: repo,
        commandApi: commandApi,
        bodyReceipt: receipt0(),
      );

      await tester.tap(find.byKey(const Key('s72-values-toggle')));
      await tester.pump();

      expect(find.text(AnalyticsLabels.valuesHideButton), findsOneWidget);
      expect(find.text(AnalyticsLabels.valuesColumnBenchmark), findsNothing);

      final rowCount = s.points.length;
      for (var i = 0; i < rowCount; i++) {
        expect(
          find.byKey(ValueKey<String>('s72-value-row-$i')),
          findsOneWidget,
        );
      }

      int? missingIdx;
      for (var i = 0; i < s.points.length; i++) {
        if (s.points[i].yNormalized == null) {
          missingIdx = i;
          break;
        }
      }
      expect(missingIdx, isNotNull); // 전제 — 두 픽스처 모두 결측 점이 있다

      final checkIndices = <int>[0, missingIdx!, s.points.length - 1];

      for (final idx in checkIndices) {
        final rowTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('s72-value-row-$idx')),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data)
            .toList();

        final expected = <String>[
          s.points[idx].dateText,
          s.points[idx].valueText,
        ];
        expect(rowTexts, equals(expected));
      }
      expect(
        find.byKey(ValueKey<String>('s72-value-row-${s.points.length}')),
        findsNothing,
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });

    testWidgets('V3 switch toggle keeps table expanded and updates rows', (
      tester,
    ) async {
      final repo = TableFakePerformanceRepository(
        gateStreamFactory: () => Stream<DisclosureGateVm>.value(openGate()),
      );
      final commandApi = FakeCommandApi();

      await pumpExplore(tester, repo: repo, commandApi: commandApi);
      await passGate(tester);
      await tester.pump();

      await tester.tap(find.byKey(const Key('s72-values-toggle')));
      await tester.pump();

      expect(find.text(AnalyticsLabels.valuesHideButton), findsOneWidget);

      await tester.tap(find.text(AnalyticsLabels.granularityDaily));
      await tester.pump();
      await tester.pump();

      final dailyGap = singleFixture(
        FixturePaths.m7M7PerfDailyGap,
        PerformanceSeries.fromJson,
      );

      expect(find.text(AnalyticsLabels.valuesHideButton), findsOneWidget);
      for (var i = 0; i < dailyGap.points.length; i++) {
        expect(
          find.byKey(ValueKey<String>('s72-value-row-$i')),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(ValueKey<String>('s72-value-row-${dailyGap.points.length}')),
        findsNothing,
      );

      final firstRowTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('s72-value-row-0')),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();

      expect(firstRowTexts[0], equals(dailyGap.points.first.dateText));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  });
}
