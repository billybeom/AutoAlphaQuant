// packages/ui_analytics/test/goal_path_view_test.dart

import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'goal_path_fakes.dart';
import 'golden/chart_probe.dart';
import 'golden/golden_support.dart';

void main() {
  final GoalPathVm on = singleFixture(
    FixturePaths.m7M7GoalPathOn,
    GoalPathVm.fromJson,
  );
  final GoalPathVm off = singleFixture(
    FixturePaths.m7M7GoalPathOff,
    GoalPathVm.fromJson,
  );
  final GoalPathVm hold = singleFixture(
    FixturePaths.m7M7GoalPathHold,
    GoalPathVm.fromJson,
  );
  final GoalPathVm realworld = singleFixture(
    FixturePaths.m7M7GoalPathRealworld,
    GoalPathVm.fromJson,
  );

  final FixtureEnvelope safetyEnvelope = fixtureEnvelope(FixturePaths.safetyStates);

  testWidgets('T79-01 goalPathCalls', (WidgetTester tester) async {
    final repo = FakeGoalPathRepository(vm: on);
    await pumpGoalPath(tester, repo: repo, yyyyMm: on.yyyyMm);
    expect(repo.goalPathCalls, hasLength(1));
    expect(repo.goalPathCalls, <String>[on.yyyyMm]);
    expect(find.byKey(ValueKey<String>('s79-${on.yyyyMm}')), findsOneWidget);
    expect(find.text(on.yyyyMm), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final (String name, GoalPathVm vm, bool isStale, int safetyRow) in <(
    String,
    GoalPathVm,
    bool,
    int,
  )>[
    ('on', on, false, 0),
    ('off', off, true, 4),
    ('realworld', realworld, false, 3),
  ]) {
    testWidgets('T79-02 layout chain $name', (WidgetTester tester) async {
      final Clock clock = isStale
          ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
          : FixedClock(kGoldenNowUtc);
      final SafetyState safety = SafetyState.fromJson(safetyEnvelope.rows[safetyRow]);
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(
        tester,
        repo: repo,
        yyyyMm: vm.yyyyMm,
        safetyState: safety,
        clock: clock,
      );

      final List<BlockFlag> activeFlags = safety.activeFlags;

      final List<Finder> chain = <Finder>[
        if (isStale) find.text(AnalyticsLabels.staleBannerTitle),
        if (activeFlags.isNotEmpty) find.text(activeFlags.first.label),
        find.byKey(const Key('s79-asof')),
        find.byKey(const Key('s79-judgement')),
        find.byKey(const Key('s79-basis')),
        if (vm.deviationText != null) find.byKey(const Key('s79-deviation')),
        find.byKey(const Key('s79-period')),
        if (vm.chartUnavailableLabel == null) ...<Finder>[
          find.byKey(const Key('s79-chart')),
          find.byKey(const Key('s79-x-first')),
          find.byKey(const Key('s79-legend-actual')),
          find.byKey(const Key('s79-legend-planned')),
          for (int i = 0; i < vm.segments.length; i++)
            if (vm.segments[i].kind != SegmentKind.measured)
              find.byKey(ValueKey<String>('s79-segment-caption-$i')),
          find.byKey(const Key('s79-values-toggle')),
        ],
        find.byKey(const Key('s79-assumption-header')),
        find.byKey(const Key('s79-backtest-basis')),
        find.byKey(const Key('s79-starting-capital')),
        find.byKey(const Key('s79-honest')),
        find.byKey(const Key('s79-honest-worst')),
        find.byKey(const Key('s79-disclaimer')),
      ];

      for (final f in chain) {
        expect(f, findsOneWidget);
      }
      for (int i = 0; i < chain.length - 1; i++) {
        expect(
          tester.getTopLeft(chain[i]).dy,
          lessThan(tester.getTopLeft(chain[i + 1]).dy),
        );
      }

      if (isStale) {
        // stale shows banner
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      }
      if (vm.deviationText == null) {
        expect(find.byKey(const Key('s79-deviation')), findsNothing);
      }
      // check segment captions: measured segments have no key
      for (int i = 0; i < vm.segments.length; i++) {
        if (vm.segments[i].kind == SegmentKind.measured) {
          expect(find.byKey(ValueKey<String>('s79-segment-caption-$i')), findsNothing);
        }
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('off', off),
    ('hold', hold),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-03 deviation line only when present $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      if (vm.deviationText != null) {
        expect(find.byKey(const Key('s79-deviation')), findsOneWidget);
        expect(find.text(vm.deviationText!), findsOneWidget);
      } else {
        expect(find.byKey(const Key('s79-deviation')), findsNothing);
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T79-04 hold unavailable card', (WidgetTester tester) async {
    final repo = FakeGoalPathRepository(vm: hold);
    await pumpGoalPath(tester, repo: repo, yyyyMm: hold.yyyyMm);

    expect(find.byKey(const Key('s79-unavailable')), findsOneWidget);
    final Text unavailableText = tester.widget<Text>(find.byKey(const Key('s79-unavailable')));
    expect(unavailableText.data, hold.chartUnavailableLabel);
    expect(find.byKey(kGoalPathChartProbeKey), findsNothing);
    expect(find.byKey(const Key('s79-tick-0')), findsNothing);
    expect(find.byKey(const Key('s79-x-first')), findsNothing);
    expect(find.byKey(const Key('s79-legend-actual')), findsNothing);
    expect(find.byKey(const Key('s79-legend-planned')), findsNothing);
    expect(find.byKey(const Key('s79-values-toggle')), findsNothing);
    expect(find.byKey(const Key('s79-period')), findsOneWidget);

    final List<Finder> chain = <Finder>[
      find.byKey(const Key('s79-asof')),
      find.byKey(const Key('s79-judgement')),
      find.byKey(const Key('s79-basis')),
      find.byKey(const Key('s79-period')),
      find.byKey(const Key('s79-unavailable')),
      find.byKey(const Key('s79-assumption-header')),
      find.byKey(const Key('s79-backtest-basis')),
      find.byKey(const Key('s79-starting-capital')),
      find.byKey(const Key('s79-honest')),
      find.byKey(const Key('s79-honest-worst')),
      find.byKey(const Key('s79-disclaimer')),
    ];
    for (final f in chain) {
      expect(f, findsOneWidget);
    }
    for (int i = 0; i < chain.length - 1; i++) {
      expect(
        tester.getTopLeft(chain[i]).dy,
        lessThan(tester.getTopLeft(chain[i + 1]).dy),
      );
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('off', off),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-05 yTicks labels $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      expect(vm.yTicks, hasLength(4));
      for (int i = 0; i < vm.yTicks.length; i++) {
        final Finder tickFinder = find.byKey(ValueKey<String>('s79-tick-$i'));
        expect(tickFinder, findsOneWidget);
        final Text tickText = tester.widget<Text>(tickFinder);
        expect(tickText.data, vm.yTicks[i].label);
        final Rect chartRect = tester.getRect(find.byKey(kGoalPathChartProbeKey));
        expect(tester.getTopRight(tickFinder).dx, lessThanOrEqualTo(chartRect.left));
      }
      expect(find.byKey(ValueKey<String>('s79-tick-4')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('off', off),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-06 x end labels $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      final Text firstText = tester.widget<Text>(find.byKey(const Key('s79-x-first')));
      expect(firstText.data, vm.actual.first.dateText);
      final Text lastText = tester.widget<Text>(find.byKey(const Key('s79-x-last')));
      expect(lastText.data, vm.actual.last.dateText);
      final Rect chartRect = tester.getRect(find.byKey(kGoalPathChartProbeKey));
      expect(tester.getTopLeft(find.byKey(const Key('s79-x-first'))).dx, chartRect.left);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-07 values table $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      expect(vm.planned, hasLength(8));
      expect(
        vm.actual.any((PerfPoint p) => p.yNormalized == null),
        name == 'on' ? isFalse : isTrue,
      );

      expect(find.byKey(const Key('s79-value-row-0')), findsNothing);
      expect(find.text(AnalyticsLabels.goalPathValuesButton), findsOneWidget);

      await tester.tap(find.byKey(const Key('s79-values-toggle')));
      await tester.pump();

      expect(find.byKey(const Key('s79-values-table')), findsOneWidget);

      final List<Widget> headerTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('s79-values-header')),
              matching: find.byType(Text),
            ),
          )
          .toList();
      expect(headerTexts.map((Widget w) => (w as Text).data).toList(), <String>[
        AnalyticsLabels.goalPathColumnDate,
        vm.plannedLabel,
        vm.actualLabel,
      ]);

      for (int i = 0; i < vm.planned.length; i++) {
        final List<String?> rowTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(ValueKey<String>('s79-value-row-$i')),
                matching: find.byType(Text),
              ),
            )
            .map((Widget w) => (w as Text).data)
            .toList();
        expect(rowTexts, <String>[
          vm.planned[i].dateText,
          vm.planned[i].valueText,
          vm.actual[i].valueText,
        ]);
      }

      expect(find.byKey(const Key('s79-value-row-8')), findsNothing);
      expect(find.text(AnalyticsLabels.valuesHideButton), findsOneWidget);

      await tester.tap(find.byKey(const Key('s79-values-toggle')));
      await tester.pump();

      expect(find.byKey(const Key('s79-value-row-0')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T79-08a loading', (WidgetTester tester) async {
    final Completer<GoalPathVm> completer = Completer<GoalPathVm>();
    final SafetyState safety = SafetyState.fromJson(safetyEnvelope.rows[3]);
    final repo = FakeGoalPathRepository(completer: completer);
    await pumpGoalPath(
      tester,
      repo: repo,
      yyyyMm: on.yyyyMm,
      safetyState: safety,
    );

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s79-judgement')), findsNothing);
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  testWidgets('T79-08b error', (WidgetTester tester) async {
    final SafetyState safety = SafetyState.fromJson(safetyEnvelope.rows[3]);
    final repo = FakeGoalPathRepository(error: StateError('load error'));
    await pumpGoalPath(
      tester,
      repo: repo,
      yyyyMm: on.yyyyMm,
      safetyState: safety,
    );

    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(
      tester.widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView)).lastAsOfLabel,
      isNull,
    );
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.byKey(const Key('s79-judgement')), findsNothing);

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();
    expect(repo.goalPathCalls, hasLength(2));
    expect(repo.goalPathCalls[0], on.yyyyMm);
    expect(repo.goalPathCalls[1], on.yyyyMm);
  });

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('off', off),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-09 chart probe $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      expectGoalPathMatches(
        recordChart(tester, key: kGoalPathChartProbeKey),
        vm,
        chartSchemeOf(tester, key: kGoalPathChartProbeKey),
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, GoalPathVm vm) in <(String, GoalPathVm)>[
    ('on', on),
    ('realworld', realworld),
  ]) {
    testWidgets('T79-10 no fabricated strings $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      await tester.tap(find.byKey(const Key('s79-values-toggle')));
      await tester.pump();
      expect(find.byKey(const Key('s79-values-table')), findsOneWidget);

      final Set<String?> allowed = <String?>{
        vm.asOf.label,
        vm.judgementText,
        vm.basisText,
        if (vm.deviationText != null) vm.deviationText,
        vm.periodLabel,
        vm.plannedLabel,
        vm.actualLabel,
        vm.backtestBasisText,
        vm.startingCapitalAssumptionText,
        vm.honestExpectationText,
        vm.honestExpectationWorstText,
        vm.disclaimerText,
        ...vm.yTicks.map((PerfAxisTick t) => t.label),
        ...vm.planned.map((PerfPoint p) => p.dateText),
        ...vm.planned.map((PerfPoint p) => p.valueText),
        ...vm.actual.map((PerfPoint p) => p.dateText),
        ...vm.actual.map((PerfPoint p) => p.valueText),
        ...vm.segments.map((PerfSegment s) => s.label),
        AnalyticsLabels.goalPathAssumptionHeader,
        AnalyticsLabels.goalPathValuesButton,
        AnalyticsLabels.valuesHideButton,
        AnalyticsLabels.goalPathColumnDate,
      };

      final List<String?> allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();

      for (final String? text in allTexts) {
        expect(allowed, contains(text));
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final (String name, DateTime clock) in <(String, DateTime)>[
    ('fresh', kGoldenNowUtc),
    ('stale', kGoldenNowUtc.add(const Duration(days: 3))),
  ]) {
    testWidgets('T79-11 stale banner $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: on);
      await pumpGoalPath(
        tester,
        repo: repo,
        yyyyMm: on.yyyyMm,
        clock: FixedClock(clock),
      );

      if (name == 'stale') {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T79-12 no ConfigRepository or planner in files', (WidgetTester tester) async {
    final List<File> files = <File>[
      File('lib/src/screens/goal_path_screen.dart'),
      ...Directory('lib/src/goal_path')
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart')),
    ];
    expect(files, hasLength(3));
    for (final File file in files) {
      final String content = file.readAsStringSync();
      expect(RegExp(r'[Cc]onfigRepository|planner').hasMatch(content), isFalse);
    }
  });

  for (final (String name, GoalPathVm vm, int expectedLen) in <(
    String,
    GoalPathVm,
    int,
  )>[
    ('on', on, 0),
    ('off', off, 0),
    ('realworld', realworld, 1),
  ]) {
    testWidgets('T79-13 segment captions $name', (WidgetTester tester) async {
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(tester, repo: repo, yyyyMm: vm.yyyyMm);

      expect(vm.segments, hasLength(expectedLen));
      for (int i = 0; i < vm.segments.length; i++) {
        if (vm.segments[i].kind != SegmentKind.measured) {
          expect(
            find.byKey(ValueKey<String>('s79-segment-caption-$i')),
            findsOneWidget,
          );
          final Text t = tester.widget<Text>(
            find.byKey(ValueKey<String>('s79-segment-caption-$i')),
          );
          expect(t.data, vm.segments[i].label);
        } else {
          expect(
            find.byKey(ValueKey<String>('s79-segment-caption-$i')),
            findsNothing,
          );
        }
      }
      expect(
        find.byKey(ValueKey<String>('s79-segment-caption-$expectedLen')),
        findsNothing,
      );
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T79-14 barrel exports', (WidgetTester tester) async {
    final String content = File('lib/ui_analytics.dart').readAsStringSync();
    final List<String> exports =
        RegExp(r"^export '([^']+)';", multiLine: true)
            .allMatches(content)
            .map((RegExpMatch m) => m.group(1)!)
            .toList();
    expect(exports, hasLength(8));
    expect(exports.toSet(), <String>{
      'l10n/labels.dart',
      'src/providers/analytics_providers.dart',
      'src/screens/contribution_screen.dart',
      'src/screens/drawdown_context_screen.dart',
      'src/screens/goal_path_screen.dart',
      'src/screens/monthly_report_screen.dart',
      'src/screens/performance_explore_screen.dart',
      'src/screens/report_archive_screen.dart',
    });
  });

  for (final (String name, GoalPathVm vm, int flagCount, int blockIconCount) in <(
    String,
    GoalPathVm,
    int,
    int,
  )>[
    ('row0', on, 0, 0),
    ('row3', on, 2, 2),
    ('row4', on, 1, 1),
  ]) {
    testWidgets('T79-15 safety flags $name', (WidgetTester tester) async {
      final int safetyRowIndex = name == 'row0' ? 0 : name == 'row3' ? 3 : 4;
      final SafetyState safety = SafetyState.fromJson(safetyEnvelope.rows[safetyRowIndex]);
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final repo = FakeGoalPathRepository(vm: vm);
      await pumpGoalPath(
        tester,
        repo: repo,
        yyyyMm: vm.yyyyMm,
        safetyState: safety,
        opener: opener,
      );

      final List<BlockFlag> activeFlags = safety.activeFlags;
      expect(activeFlags, hasLength(flagCount));

      for (final BlockFlag flag in activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
      }

      if (flagCount == 0) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(find.byIcon(Icons.block), findsNWidgets(blockIconCount));
      }

      if (name == 'row4') {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(
          opener.opened,
          <String>[activeFlags.single.clearDeepLink!],
        );
      } else {
        expect(opener.opened, isEmpty);
      }
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }
}
