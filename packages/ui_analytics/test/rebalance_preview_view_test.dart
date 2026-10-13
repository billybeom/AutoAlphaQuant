import 'dart:async';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/src/widgets/analytics_error_view.dart';
import 'package:ui_analytics/src/widgets/analytics_skeleton.dart';
import 'package:ui_analytics/ui_analytics.dart';

import 'golden/golden_support.dart';
import 'rebalance_preview_fakes.dart';

void main() {
  testWidgets('T76c-01 entry', (WidgetTester tester) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: countdown,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

    expect(repo.watchNextCalls, 1);
    expect(repo.otherCalls, isEmpty);
    expect(whatIf.previewCalls, isEmpty);
    expect(whatIf.otherCalls, isEmpty);
    expect(find.byKey(const Key('s76c-root')), findsOneWidget);
    expect(find.byKey(const Key('s76c-preview-button')), findsOneWidget);
    expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsOneWidget);
    expect(find.byKey(const Key('s76c-draft')), findsNothing);
    expect(find.byKey(const Key('s76c-notice')), findsNothing);
    expect(find.byKey(const Key('s76c-blocked')), findsNothing);
    expect(find.byType(AnalyticsSkeleton), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final ({String name, bool stripped}) d in <({
    String name,
    bool stripped,
  })>[
    (name: 'default', stripped: false),
    (name: 'stripped', stripped: true),
  ]) {
    testWidgets('T76c-02 countdown text chain ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm raw = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final NextRebalanceVm vm =
          d.stripped ? raw.copyWith(kindLabel: null, noticeText: null) : raw;
      expect(vm.kindLabel, d.stripped ? isNull : isNotNull);

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

      await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

      final List<String?> texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('s76c-countdown')),
              matching: find.byType(Text),
            ),
          )
          .map((Text t) => t.data)
          .toList();
      final List<String?> expected = <String?>[
        vm.dDayText,
        vm.expectedDateText,
        if (vm.kindLabel != null) vm.kindLabel,
        if (vm.noticeText != null) vm.noticeText,
      ];
      expect(texts, expected);
      expect(
        tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data,
        vm.asOf.label,
      );
      expect(find.byKey(const Key('s76c-empty')), findsNothing);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-03 none', (WidgetTester tester) async {
    final NextRebalanceVm none = singleFixture(
      FixturePaths.m7M7NextRebalanceNone,
      NextRebalanceVm.fromJson,
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      vm: none,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(tester, repo: repo, whatIf: whatIf);

    expect(
      tester.widget<Text>(find.byKey(const Key('s76c-empty'))).data,
      none.emptyLabel,
    );
    expect(find.byKey(const Key('s76c-countdown')), findsNothing);
    expect(find.byKey(const Key('s76c-preview-button')), findsNothing);
    expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('s76c-asof'))).data,
      none.asOf.label,
    );
    expect(find.byKey(const Key('s76c-draft')), findsNothing);
    expect(whatIf.previewCalls, isEmpty);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final ({String name, String path, bool isNone}) d in <({
    String name,
    String path,
    bool isNone,
  })>[
    (
      name: 'countdown',
      path: FixturePaths.m7M7NextRebalanceCountdown,
      isNone: false,
    ),
    (name: 'none', path: FixturePaths.m7M7NextRebalanceNone, isNone: true),
  ]) {
    testWidgets('T76c-04 viewer null whatif ${d.name}', (
      WidgetTester tester,
    ) async {
      final NextRebalanceVm vm = singleFixture(
        d.path,
        NextRebalanceVm.fromJson,
      );
      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: vm,
      );

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: null,
      );

      expect(find.byKey(const Key('s76c-preview-button')), findsNothing);
      expect(find.text(AnalyticsLabels.rebalanceDraftButton), findsNothing);
      expect(find.byKey(const Key('s76c-draft')), findsNothing);
      expect(find.byKey(const Key('s76c-blocked')), findsNothing);
      if (d.isNone) {
        expect(find.byKey(const Key('s76c-empty')), findsOneWidget);
        expect(find.byKey(const Key('s76c-countdown')), findsNothing);
      } else {
        expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
        expect(find.byKey(const Key('s76c-empty')), findsNothing);
      }
      expect(find.byKey(const Key('s76c-asof')), findsOneWidget);
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  for (final ({
    String name,
    bool isStale,
    int safetyIndex,
    int expectedFlags,
  }) d in <({
    String name,
    bool isStale,
    int safetyIndex,
    int expectedFlags,
  })>[
    (name: 'stale_row3', isStale: true, safetyIndex: 3, expectedFlags: 2),
    (name: 'fresh_row0', isStale: false, safetyIndex: 0, expectedFlags: 0),
    (name: 'fresh_row4', isStale: false, safetyIndex: 4, expectedFlags: 1),
  ]) {
    testWidgets('T76c-12 banners ${d.name}', (WidgetTester tester) async {
      final NextRebalanceVm countdown = singleFixture(
        FixturePaths.m7M7NextRebalanceCountdown,
        NextRebalanceVm.fromJson,
      );
      final SafetyState safetyState = SafetyState.fromJson(
        fixtureEnvelope(FixturePaths.safetyStates).rows[d.safetyIndex],
      );
      final List<BlockFlag> activeFlags = safetyState.activeFlags;
      final RecordingLinkOpener opener = RecordingLinkOpener();

      final Clock clock = d.isStale
          ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
          : FixedClock(kGoldenNowUtc);

      final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
        vm: countdown,
      );
      final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

      await pumpRebalancePreview(
        tester,
        repo: repo,
        whatIf: whatIf,
        safetyState: safetyState,
        clock: clock,
        opener: opener,
      );

      expect(activeFlags, hasLength(d.expectedFlags));

      if (d.isStale) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(AnalyticsLabels.staleBannerTitle),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }

      for (final BlockFlag flag in activeFlags) {
        expect(find.text(flag.label), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(flag.label),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
      }

      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(find.byIcon(Icons.block), findsNWidgets(activeFlags.length));
      }

      final List<Finder> chain = <Finder>[
        if (d.isStale) find.text(AnalyticsLabels.staleBannerTitle),
        if (activeFlags.isNotEmpty) find.text(activeFlags.first.label),
        find.byKey(const Key('s76c-countdown')),
      ];
      for (int i = 0; i < chain.length - 1; i++) {
        expect(
          tester.getTopLeft(chain[i]).dy,
          lessThan(tester.getTopLeft(chain[i + 1]).dy),
        );
      }

      if (d.safetyIndex == 4) {
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(opener.opened, <String>[activeFlags.single.clearDeepLink!]);
      } else {
        expect(opener.opened, isEmpty);
      }

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    });
  }

  testWidgets('T76c-13a loading skeleton no banners', (
    WidgetTester tester,
  ) async {
    final StreamController<NextRebalanceVm> controller =
        StreamController<NextRebalanceVm>();
    addTearDown(() {
      unawaited(controller.close());
    });

    final SafetyState safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[3],
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      streamFactory: (int call) => controller.stream,
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(
      tester,
      repo: repo,
      whatIf: whatIf,
      safetyState: safetyState,
    );

    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s76c-root')), findsNothing);
    for (final BlockFlag flag in safetyState.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  testWidgets('T76c-13b error view and retry', (WidgetTester tester) async {
    final NextRebalanceVm countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    final SafetyState safetyState = SafetyState.fromJson(
      fixtureEnvelope(FixturePaths.safetyStates).rows[3],
    );
    final FakeNextRebalanceRepository repo = FakeNextRebalanceRepository(
      streamFactory: (int call) {
        if (call == 1) {
          return Stream<NextRebalanceVm>.error(StateError('x'));
        }
        return Stream<NextRebalanceVm>.value(countdown);
      },
    );
    final FakeRebalancePreviewApi whatIf = FakeRebalancePreviewApi();

    await pumpRebalancePreview(
      tester,
      repo: repo,
      whatIf: whatIf,
      safetyState: safetyState,
    );

    expect(find.byType(AnalyticsErrorView), findsOneWidget);
    expect(
      tester
          .widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView))
          .lastAsOfLabel,
      isNull,
    );
    for (final BlockFlag flag in safetyState.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
    expect(find.byKey(const Key('s76c-root')), findsNothing);
    expect(find.byKey(const Key('s76c-preview-button')), findsNothing);

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();
    await tester.pump();

    expect(repo.watchNextCalls, 2);
    expect(find.byKey(const Key('s76c-countdown')), findsOneWidget);
    expect(whatIf.previewCalls, isEmpty);
  });

  test('T76c-17 file inspect', () {
    final String content = File(
      'lib/src/screens/rebalance_preview_screen.dart',
    ).readAsStringSync();
    expect(content.contains('planner'), isFalse);
    expect(
      RegExp(r'Scaffold|AppBar|SafeArea|SnackBar').hasMatch(content),
      isFalse,
    );
    expect(RegExp(r'previewRebalance').allMatches(content).length, 1);
    expect(RegExp(r'DateTime').hasMatch(content), isFalse);
    expect(Directory('lib/src/rebalance/preview').existsSync(), isFalse);
  });
}
