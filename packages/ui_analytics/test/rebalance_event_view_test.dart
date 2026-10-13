// packages/ui_analytics/test/rebalance_event_view_test.dart
// S7-6b 리밸런싱 회차 상세 — T76B-01 ~ T76B-10.

import 'dart:async';

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

RebalanceEvent _band() => singleFixture(
  FixturePaths.m7M7RebalanceDetailBand,
  RebalanceEvent.fromJson,
);

RebalanceEvent _advisory() => singleFixture(
  FixturePaths.m7M7RebalanceDetailAdvisory,
  RebalanceEvent.fromJson,
);

List<String?> _texts(WidgetTester tester, Finder of) => tester
    .widgetList<Text>(find.descendant(of: of, matching: find.byType(Text)))
    .map((Text t) => t.data)
    .toList();

void main() {
  testWidgets('T76B-01 subscribes by id only detail_band', (
    WidgetTester tester,
  ) async {
    final RebalanceEvent band = _band();
    final FakeRebalanceRepository repo = FakeRebalanceRepository(event: band);
    await pumpRebalance(
      tester,
      repo: repo,
      screen: RebalanceEventScreen(rebalanceEventId: band.eventId),
    );
    await tester.pump();

    expect(repo.watchEventCalls, hasLength(1));
    expect(repo.watchEventCalls.single, band.eventId);
    expect(repo.watchEventsCalls, isEmpty);
    expect(find.byKey(const Key('s76b-root')), findsOneWidget);
    expect(find.text(band.eventId), findsNothing);
    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
  });

  for (final (String, RebalanceEvent, bool, int) c
      in <(String, RebalanceEvent, bool, int)>[
        ('detail_band', _band(), false, 0),
        ('seasonal', rebalance6Event(kSeasonalEventId), true, 4),
        ('monthly', rebalance6Event(kMonthlyEventId), false, 3),
      ]) {
    testWidgets('T76B-02 layout chain ${c.$1}', (WidgetTester tester) async {
      final RebalanceEvent e = c.$2;
      final SafetyState safety = _safetyRow(c.$4);
      final List<BlockFlag> activeFlags = safety.activeFlags;
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
        safetyState: safety,
        clock: c.$3
            ? FixedClock(kGoldenNowUtc.add(const Duration(days: 3)))
            : null,
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final ExecutionQuality? quality = e.quality;
      final LinkAction? link = e.journalTimelineLink;
      final List<Finder> chain = <Finder>[
        if (c.$3) find.text(AnalyticsLabels.staleBannerTitle),
        if (activeFlags.isNotEmpty) find.text(activeFlags.first.label),
        find.text(e.kindLabel),
        find.byKey(const Key('s76b-before')),
        find.byKey(const Key('s76b-after')),
        if (e.thresholds.isNotEmpty) find.byKey(const Key('s76b-thresholds')),
        find.byKey(const Key('s76b-snapshot')),
        if (quality != null) find.byKey(const Key('s76b-quality')),
        if (link != null)
          find.byKey(const Key('s76b-link-journalTimelineLink')),
        find.byKey(const Key('s76b-asof')),
      ];
      for (final Finder f in chain) {
        expect(f, findsOneWidget);
      }
      for (int i = 1; i < chain.length; i++) {
        expect(
          tester.getTopLeft(chain[i - 1]).dy,
          lessThan(tester.getTopLeft(chain[i]).dy),
        );
      }
      expect(find.text(e.tradeDate.yyyyMmDd), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(e.tradeDate.yyyyMmDd)).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('s76b-before'))).dy),
      );

      if (c.$3) {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsOneWidget);
      } else {
        expect(find.text(AnalyticsLabels.staleBannerTitle), findsNothing);
      }
      if (activeFlags.isEmpty) {
        expect(find.byIcon(Icons.block), findsNothing);
      } else {
        expect(find.byIcon(Icons.block), findsNWidgets(c.$4 == 4 ? 1 : 2));
      }
      if (e.thresholds.isEmpty) {
        expect(find.byKey(const Key('s76b-thresholds')), findsNothing);
      } else {
        expect(find.byKey(const Key('s76b-thresholds')), findsOneWidget);
      }
      if (quality == null) {
        expect(find.byKey(const Key('s76b-quality')), findsNothing);
      } else {
        expect(find.byKey(const Key('s76b-quality')), findsOneWidget);
      }
      if (link == null) {
        expect(
          find.byKey(const Key('s76b-link-journalTimelineLink')),
          findsNothing,
        );
      } else {
        expect(
          find.byKey(const Key('s76b-link-journalTimelineLink')),
          findsOneWidget,
        );
      }
      expect(
        tester.widget<Text>(find.byKey(const Key('s76b-asof'))).data,
        e.asOf.label,
      );
    });
  }

  for (final (String, RebalanceEvent) c in <(String, RebalanceEvent)>[
    ('detail_band', _band()),
    ('seasonal', rebalance6Event(kSeasonalEventId)),
  ]) {
    testWidgets('T76B-03 before and after in received order ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent e = c.$2;
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      expect(_texts(tester, find.byKey(const Key('s76b-before'))), <String?>[
        AnalyticsLabels.rebalanceBeforeHeader,
        for (final SleeveWeight w in e.before) w.label,
      ]);
      expect(_texts(tester, find.byKey(const Key('s76b-after'))), <String?>[
        AnalyticsLabels.rebalanceAfterHeader,
        for (final SleeveWeight w in e.after) w.label,
      ]);
    });
  }

  for (final (String, RebalanceEvent) c in <(String, RebalanceEvent)>[
    ('detail_band', _band()),
    ('seasonal', rebalance6Event(kSeasonalEventId)),
    ('monthly', rebalance6Event(kMonthlyEventId)),
  ]) {
    testWidgets('T76B-04 thresholds table outside fold ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent e = c.$2;
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final Finder table = find.byKey(const Key('s76b-thresholds'));
      if (e.thresholds.isNotEmpty) {
        expect(table, findsOneWidget);
        expect(_texts(tester, table), <String?>[
          AnalyticsLabels.rebalanceThresholdsHeader,
          for (final ThresholdCompare t in e.thresholds) ...<String?>[
            t.metricLabel,
            t.observedText,
            t.thresholdText,
            t.verdictLabel,
          ],
        ]);
        expect(
          find.descendant(of: table, matching: find.byType(Icon)),
          findsNWidgets(e.thresholds.length),
        );
        int passedCount = 0;
        int failedCount = 0;
        for (final ThresholdCompare t in e.thresholds) {
          if (t.passed) {
            passedCount++;
          } else {
            failedCount++;
          }
        }
        expect(
          find.descendant(of: table, matching: find.byIcon(Icons.check)),
          findsNWidgets(passedCount),
        );
        expect(
          find.descendant(of: table, matching: find.byIcon(Icons.remove)),
          findsNWidgets(failedCount),
        );
      } else {
        expect(e.thresholds, isEmpty);
        expect(table, findsNothing);
      }
    });
  }

  testWidgets('T76B-05 snapshot folded by default detail_band', (
    WidgetTester tester,
  ) async {
    final RebalanceEvent e = _band();
    final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
    await pumpRebalance(
      tester,
      repo: repo,
      screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
    );
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    final Finder snapshot = find.byKey(const Key('s76b-snapshot'));
    expect(snapshot, findsOneWidget);
    expect(_texts(tester, snapshot), <String?>[
      AnalyticsLabels.rebalanceSnapshotHeader,
    ]);
    expect(find.text(e.trigger.summary), findsNothing);
    expect(find.text(e.trigger.configHash), findsNothing);
    expect(find.byKey(const Key('s76b-thresholds')), findsOneWidget);

    await tester.tap(snapshot);
    await tester.pump();
    expect(find.text(e.trigger.summary), findsOneWidget);
    expect(find.text(e.trigger.configHash), findsOneWidget);
    final List<Finder> chain = <Finder>[
      snapshot,
      find.text(e.trigger.summary),
      find.text(e.trigger.configHash),
      find.byKey(const Key('s76b-quality')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    await tester.tap(snapshot);
    await tester.pump();
    expect(find.text(e.trigger.summary), findsNothing);
  });

  for (final (String, RebalanceEvent) c in <(String, RebalanceEvent)>[
    ('detail_band', _band()),
    ('seasonal', rebalance6Event(kSeasonalEventId)),
  ]) {
    testWidgets('T76B-06 quality panel only when present ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent e = c.$2;
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final ExecutionQuality? quality = e.quality;
      final Finder panel = find.byKey(const Key('s76b-quality'));
      if (quality != null) {
        expect(panel, findsOneWidget);
        expect(_texts(tester, panel), <String?>[
          AnalyticsLabels.rebalanceQualityHeader,
          quality.slippageText,
          quality.assumedSlippageText,
          quality.unfilledRateText,
          quality.summary,
        ]);
      } else {
        expect(panel, findsNothing);
      }
    });
  }

  for (final (String, RebalanceEvent) c in <(String, RebalanceEvent)>[
    ('detail_band', _band()),
    ('detail_advisory', _advisory()),
    ('seasonal', rebalance6Event(kSeasonalEventId)),
  ]) {
    testWidgets('T76B-07 journal link only when present ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent e = c.$2;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
        opener: opener,
      );
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final LinkAction? link = e.journalTimelineLink;
      final Finder button = find.byKey(
        const Key('s76b-link-journalTimelineLink'),
      );
      if (link != null) {
        expect(button, findsOneWidget);
        expect(_texts(tester, button), <String?>[link.label]);
        await tester.tap(button);
        await tester.pump();
        expect(opener.opened, <String>[link.deepLink]);
      } else {
        expect(button, findsNothing);
        expect(opener.opened, isEmpty);
      }
    });
  }

  testWidgets('T76B-08a loading skeleton without banners', (
    WidgetTester tester,
  ) async {
    final RebalanceEvent band = _band();
    final StreamController<RebalanceEvent> controller =
        StreamController<RebalanceEvent>();
    addTearDown(() {
      unawaited(controller.close());
    });
    final SafetyState safety = _safetyRow(3);
    final FakeRebalanceRepository repo = FakeRebalanceRepository(
      eventController: controller,
    );
    await pumpRebalance(
      tester,
      repo: repo,
      screen: RebalanceEventScreen(rebalanceEventId: band.eventId),
      safetyState: safety,
    );
    await tester.pump();

    expect(find.text(AnalyticsLabels.retryButton), findsNothing);
    expect(find.byType(AnalyticsSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('s76b-root')), findsNothing);
    expect(safety.activeFlags, isNotEmpty);
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }
  });

  testWidgets('T76B-08b error view and retry', (WidgetTester tester) async {
    final RebalanceEvent band = _band();
    final SafetyState safety = _safetyRow(3);
    final FakeRebalanceRepository repo = FakeRebalanceRepository(
      error: StateError('boom'),
    );
    await pumpRebalance(
      tester,
      repo: repo,
      screen: RebalanceEventScreen(rebalanceEventId: band.eventId),
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
    expect(find.byKey(const Key('s76b-root')), findsNothing);
    for (final BlockFlag flag in safety.activeFlags) {
      expect(find.text(flag.label), findsNothing);
    }

    await tester.tap(find.text(AnalyticsLabels.retryButton));
    await tester.pump();
    await tester.pump();
    expect(repo.watchEventCalls, hasLength(2));
    expect(repo.watchEventCalls, <String>[band.eventId, band.eventId]);
  });

  for (final (String, bool, int, int, bool) c
      in <(String, bool, int, int, bool)>[
        ('fresh_no_flags', false, 0, 0, false),
        ('stale_two_flags', true, 3, 2, false),
        ('fresh_one_flag_link', false, 4, 1, true),
      ]) {
    testWidgets('T76B-09 stale and block banners outside scroll ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent band = _band();
      final SafetyState safety = _safetyRow(c.$3);
      final List<BlockFlag> activeFlags = safety.activeFlags;
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: band);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: band.eventId),
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
      expect(find.byKey(const Key('s76b-asof')), findsOneWidget);
    });
  }

  for (final (String, RebalanceEvent) c in <(String, RebalanceEvent)>[
    ('detail_band', _band()),
    ('seasonal', rebalance6Event(kSeasonalEventId)),
    ('detail_advisory', _advisory()),
  ]) {
    testWidgets('T76B-10 only engine texts and no event id ${c.$1}', (
      WidgetTester tester,
    ) async {
      final RebalanceEvent e = c.$2;
      final FakeRebalanceRepository repo = FakeRebalanceRepository(event: e);
      await pumpRebalance(
        tester,
        repo: repo,
        screen: RebalanceEventScreen(rebalanceEventId: e.eventId),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('s76b-snapshot')));
      await tester.pump();

      expect(find.text(AnalyticsLabels.retryButton), findsNothing);
      final ExecutionQuality? quality = e.quality;
      final LinkAction? link = e.journalTimelineLink;
      final Set<String> allowed = <String>{
        e.tradeDate.yyyyMmDd,
        e.kindLabel,
        for (final SleeveWeight w in e.before) w.label,
        for (final SleeveWeight w in e.after) w.label,
        for (final ThresholdCompare t in e.thresholds) ...<String>[
          t.metricLabel,
          t.observedText,
          t.thresholdText,
          t.verdictLabel,
        ],
        e.trigger.summary,
        e.trigger.configHash,
        if (quality != null) ...<String>[
          quality.slippageText,
          quality.assumedSlippageText,
          quality.unfilledRateText,
          quality.summary,
        ],
        if (link != null) link.label,
        e.asOf.label,
        AnalyticsLabels.rebalanceBeforeHeader,
        AnalyticsLabels.rebalanceAfterHeader,
        AnalyticsLabels.rebalanceThresholdsHeader,
        AnalyticsLabels.rebalanceSnapshotHeader,
        AnalyticsLabels.rebalanceQualityHeader,
      };
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(allowed, contains(data));
      }
      expect(find.text(e.eventId), findsNothing);
    });
  }
}
