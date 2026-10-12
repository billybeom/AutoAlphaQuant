// packages/ui_analytics/test/rebalance_timeline_view_test.dart
// S7-6a 리밸런싱 회차 타임라인 — T76A-01 ~ T76A-10.

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
import 'rebalance_fakes.dart';

SafetyState _safetyRow(int n) =>
    SafetyState.fromJson(fixtureEnvelope(FixturePaths.safetyStates).rows[n]);

void main() {
  testWidgets('T76A-01 no range argument and no event call rebalance_6', (
    WidgetTester tester,
  ) async {
    final ListResult<RebalanceEvent> page = listFixture(
      FixturePaths.rebalance6,
      RebalanceEvent.fromJson,
    );
    final FakeRebalanceRepository repo = FakeRebalanceRepository(events: page);
    await pumpRebalance(
      tester,
      repo: repo,
      screen: const RebalanceTimelineScreen(),
    );
    await tester.pump();

    expect(repo.watchEventsCalls, hasLength(1));
    expect(repo.watchEventsCalls.single, isNull);
    expect(repo.watchEventCalls, isEmpty);
    expect(find.byKey(const Key('s76a-root')), findsOneWidget);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final (String, String, int) c in <(String, String, int)>[
    ('rebalance_6', FixturePaths.rebalance6, 6),
    ('sim', FixturePaths.m7M7RebalanceSim, 2),
  ]) {
    testWidgets('T76A-02 rows in received order ${c.$1}', (
      WidgetTester tester,
    ) async {
      final ListResult<RebalanceEvent> page = listFixture(
        c.$2,
        RebalanceEvent.fromJson,
      );
      final FakeRebalanceRepository repo = FakeRebalanceRepository(
        events: page,
      );
      await pumpRebalance(
        tester,
        repo: repo,
        screen: const RebalanceTimelineScreen(),
      );
      await tester.pump();

      expect(page.rows, hasLength(c.$3));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      expect(find.byType(Card), findsNWidgets(page.rows.length));
      expect(find.byKey(const Key('s76a-empty-next')), findsNothing);
      for (final RebalanceEvent e in page.rows) {
        final Finder rowFinder = find.byKey(
          ValueKey<String>('s76a-row-${e.eventId}'),
        );
        expect(rowFinder, findsOneWidget);
        final List<String?> texts = tester
            .widgetList<Text>(
              find.descendant(of: rowFinder, matching: find.byType(Text)),
            )
            .map((Text t) => t.data)
            .toList();
        expect(texts, <String?>[
          e.tradeDate.yyyyMmDd,
          e.kindLabel,
          if (e.modeLabel != null) e.modeLabel,
          e.trigger.summary,
        ]);
      }
      for (int i = 1; i < page.rows.length; i++) {
        final Finder prev = find.byKey(
          ValueKey<String>('s76a-row-${page.rows[i - 1].eventId}'),
        );
        final Finder cur = find.byKey(
          ValueKey<String>('s76a-row-${page.rows[i].eventId}'),
        );
        expect(tester.getTopLeft(prev).dy, lessThan(tester.getTopLeft(cur).dy));
      }
    });
  }

  testWidgets('T76A-03 row tap opens detail link rebalance_6', (
    WidgetTester tester,
  ) async {
    final ListResult<RebalanceEvent> page = listFixture(
      FixturePaths.rebalance6,
      RebalanceEvent.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeRebalanceRepository repo = FakeRebalanceRepository(events: page);
    await pumpRebalance(
      tester,
      repo: repo,
      screen: const RebalanceTimelineScreen(),
      opener: opener,
    );
    await tester.pump();

    expect(page.rows, hasLength(6));
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    for (final RebalanceEvent e in page.rows) {
      expect(e.detailDeepLink, isNotNull);
      await tester.tap(find.byKey(ValueKey<String>('s76a-row-${e.eventId}')));
      await tester.pump();
    }
    expect(opener.opened, <String>[
      for (final RebalanceEvent e in page.rows) e.detailDeepLink!,
    ]);
  });

  testWidgets('T76A-04 empty envelope label and next button', (
    WidgetTester tester,
  ) async {
    final ListResult<RebalanceEvent> page = listFixture(
      FixturePaths.m7M7RebalanceEmpty,
      RebalanceEvent.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeRebalanceRepository repo = FakeRebalanceRepository(events: page);
    await pumpRebalance(
      tester,
      repo: repo,
      screen: const RebalanceTimelineScreen(),
      opener: opener,
    );
    await tester.pump();

    expect(page.rows, isEmpty);
    expect(page.emptyLabel, isNotNull);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    expect(find.text(page.emptyLabel!), findsOneWidget);
    expect(find.byKey(const Key('s76a-empty-next')), findsOneWidget);
    final List<String?> buttonTexts = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('s76a-empty-next')),
            matching: find.byType(Text),
          ),
        )
        .map((Text t) => t.data)
        .toList();
    expect(buttonTexts, <String?>[AnalyticsLabels.rebalanceNextPreviewButton]);
    expect(find.byType(Card), findsNothing);
    expect(find.text(page.asOf.label), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(page.emptyLabel!)).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('s76a-empty-next'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('s76a-empty-next'))).dy,
      lessThan(tester.getTopLeft(find.text(page.asOf.label)).dy),
    );

    await tester.tap(find.byKey(const Key('s76a-empty-next')));
    await tester.pump();
    expect(opener.opened, <String>[AppRoutes.rebalancePreview]);
  });

  for (final (String, String, int) c in <(String, String, int)>[
    ('rebalance_6', FixturePaths.rebalance6, 6),
    ('sim', FixturePaths.m7M7RebalanceSim, 2),
  ]) {
    testWidgets('T76A-05 mode badge and section header ${c.$1}', (
      WidgetTester tester,
    ) async {
      final ListResult<RebalanceEvent> page = listFixture(
        c.$2,
        RebalanceEvent.fromJson,
      );
      final FakeRebalanceRepository repo = FakeRebalanceRepository(
        events: page,
      );
      await pumpRebalance(
        tester,
        repo: repo,
        screen: const RebalanceTimelineScreen(),
      );
      await tester.pump();

      expect(page.rows, hasLength(c.$3));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      int badgeRows = 0;
      for (final RebalanceEvent e in page.rows) {
        final Finder modeFinder = find.byKey(
          ValueKey<String>('s76a-mode-${e.eventId}'),
        );
        final Finder sectionFinder = find.byKey(
          ValueKey<String>('s76a-section-${e.eventId}'),
        );
        if (e.modeLabel != null) {
          badgeRows++;
          expect(modeFinder, findsOneWidget);
          final Text badge = tester.widget<Text>(modeFinder);
          expect(badge.data, e.modeLabel);
          final ColorScheme colorScheme = Theme.of(tester.element(modeFinder))
              .colorScheme;
          expect(badge.style?.color, colorScheme.onTertiaryContainer);
          final DecoratedBox box = tester.widget<DecoratedBox>(
            find
                .ancestor(of: modeFinder, matching: find.byType(DecoratedBox))
                .first,
          );
          expect(
            (box.decoration as BoxDecoration).color,
            colorScheme.tertiaryContainer,
          );
        } else {
          expect(modeFinder, findsNothing);
        }
        if (e.sectionLabel != null) {
          expect(sectionFinder, findsOneWidget);
          expect(tester.widget<Text>(sectionFinder).data, e.sectionLabel);
          expect(
            tester.getTopLeft(sectionFinder).dy,
            lessThan(
              tester
                  .getTopLeft(
                    find.byKey(ValueKey<String>('s76a-row-${e.eventId}')),
                  )
                  .dy,
            ),
          );
        } else {
          expect(sectionFinder, findsNothing);
        }
      }
      expect(
        find.byWidgetPredicate((Widget w) {
          final Key? key = w.key;
          return key is ValueKey<String> && key.value.startsWith('s76a-mode-');
        }),
        findsNWidgets(badgeRows),
      );
    });
  }

  testWidgets('T76A-06 loading skeleton without banners', (
    WidgetTester tester,
  ) async {
    final StreamController<ListResult<RebalanceEvent>> controller =
        StreamController<ListResult<RebalanceEvent>>();
    addTearDown(() {
      unawaited(controller.close());
    });
    final SafetyState safety = _safetyRow(3);
    final FakeRebalanceRepository repo = FakeRebalanceRepository(
      eventsController: controller,
    );
    await pumpRebalance(
      tester,
      repo: repo,
      screen: const RebalanceTimelineScreen(),
      safetyState: safety,
    );
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s76a-root')), findsNothing);
    expect(safety.activeFlags, isNotEmpty);
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
  });

  testWidgets('T76A-07 error view and retry', (WidgetTester tester) async {
    final SafetyState safety = _safetyRow(3);
    final FakeRebalanceRepository repo = FakeRebalanceRepository(
      error: StateError('boom'),
    );
    await pumpRebalance(
      tester,
      repo: repo,
      screen: const RebalanceTimelineScreen(),
      safetyState: safety,
    );
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsOneWidget);
    expect(
      tester
          .widget<AnalyticsErrorView>(find.byType(AnalyticsErrorView))
          .lastAsOfLabel,
      isNull,
    );
    expect(find.byKey(const Key('s76a-root')), findsNothing);
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();
    await tester.pump();
    expect(repo.watchEventsCalls, hasLength(2));
    expect(repo.watchEventsCalls, <DateRange?>[null, null]);
  });

  for (final (String, bool, int, int, bool) c
      in <(String, bool, int, int, bool)>[
        ('fresh_no_flags', false, 0, 0, false),
        ('stale_two_flags', true, 3, 2, false),
        ('fresh_one_flag_link', false, 4, 1, true),
      ]) {
    testWidgets('T76A-08 stale and block banners outside scroll ${c.$1}', (
      WidgetTester tester,
    ) async {
      final ListResult<RebalanceEvent> page = listFixture(
        FixturePaths.rebalance6,
        RebalanceEvent.fromJson,
      );
      final SafetyState safety = _safetyRow(c.$3);
      final List<BlockFlag> activeFlags = safety.activeFlags;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeRebalanceRepository repo = FakeRebalanceRepository(
        events: page,
      );
      await pumpRebalance(
        tester,
        repo: repo,
        screen: const RebalanceTimelineScreen(),
        safetyState: safety,
        clock: c.$2
            ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
            : null,
        opener: opener,
      );
      await tester.pump();

      expect(activeFlags, hasLength(c.$4));
      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      if (c.$2) {
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
        expect(find.byIcon(Icons.block), findsNWidgets(c.$4));
      }
      if (c.$5) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();
        expect(opener.opened, <String>[activeFlags.single.clearDeepLink!]);
      } else {
        expect(opener.opened, isEmpty);
      }
      expect(find.text(page.asOf.label), findsOneWidget);
      expect(
        tester
            .getTopLeft(
              find.byKey(
                ValueKey<String>('s76a-row-${page.rows.last.eventId}'),
              ),
            )
            .dy,
        lessThan(tester.getTopLeft(find.text(page.asOf.label)).dy),
      );
    });
  }

  for (final (String, String) c in <(String, String)>[
    ('rebalance_6', FixturePaths.rebalance6),
    ('sim', FixturePaths.m7M7RebalanceSim),
  ]) {
    testWidgets('T76A-09 only engine texts and no event id ${c.$1}', (
      WidgetTester tester,
    ) async {
      final ListResult<RebalanceEvent> page = listFixture(
        c.$2,
        RebalanceEvent.fromJson,
      );
      final FakeRebalanceRepository repo = FakeRebalanceRepository(
        events: page,
      );
      await pumpRebalance(
        tester,
        repo: repo,
        screen: const RebalanceTimelineScreen(),
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final Set<String> allowed = <String>{
        page.asOf.label,
        for (final RebalanceEvent e in page.rows) ...<String>[
          e.tradeDate.yyyyMmDd,
          e.kindLabel,
          e.trigger.summary,
          if (e.modeLabel != null) e.modeLabel!,
          if (e.sectionLabel != null) e.sectionLabel!,
        ],
      };
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(allowed, contains(data));
      }
      for (final RebalanceEvent e in page.rows) {
        expect(find.text(e.eventId), findsNothing);
      }
    });
  }

  test('T76A-10 barrel exports each screen once', () {
    final String source = File('lib/ui_analytics.dart').readAsStringSync();
    final List<String> exports = RegExp(
      r"^export '([^']+)';",
      multiLine: true,
    ).allMatches(source).map((RegExpMatch m) => m.group(1)!).toList();
    for (final String path in <String>[
      'src/screens/rebalance_timeline_screen.dart',
    ]) {
      expect(exports.where((String e) => e == path), hasLength(1));
    }
    expect(
      exports.where((String e) => e.startsWith('src/rebalance/')),
      isEmpty,
    );
  });
}
