// test/settings_home_test.dart
//
// M9 S01 — SettingsHome widget tests (16 tests).
//
// 🔴 ASCII only · no Korean literals · if 0 · collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// ── Level/lock look helpers (lib copies) ────────────────────────────────────────

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

IconData? wantLock(SettingTier tier) => switch (tier) {
  SettingTier.general => null,
  SettingTier.operational => Icons.lock_outline,
  SettingTier.rule => Icons.lock_outline,
};

// ── Fixtures ────────────────────────────────────────────────────────────────────

final SettingsHomeVm home = singleFixture(
  FixturePaths.m9SettingsHome,
  SettingsHomeVm.fromJson,
);
final SettingsHomeVm noReview = singleFixture(
  FixturePaths.m9SettingsHomeNoReview,
  SettingsHomeVm.fromJson,
);
final SettingsHomeVm viewer = singleFixture(
  FixturePaths.m9SettingsHomeViewer,
  SettingsHomeVm.fromJson,
);

void main() {
  // ── M9S01-01: group/card order and text ────────────────────────────────────

  testWidgets('M9S01-01 group card order text', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(home)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(home.groups, hasLength(3)); // ⓗ
    expect(home.groups[0].cards, hasLength(1)); // ⓗ
    expect(home.groups[1].cards, hasLength(9)); // ⓗ
    expect(home.groups[2].cards, hasLength(1)); // ⓗ

    for (final (int g, SettingsGroup group) in home.groups.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s01-group-$g'))),
        <String>[group.label],
      );
      for (final (int c, SettingsCard card) in group.cards.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s01-card-$g-$c'))),
          settingsCardTexts(card),
        );
      }
    }

    expect(
      shownTexts(tester, find.byKey(const Key('m9s01-chip'))),
      <String>[home.statusChip.label, home.statusChip.promotionLabel!],
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s01-review'))),
      <String>[home.annualReviewLink!.label],
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s01-asof'))),
      <String>[home.asOf.label],
    );

    // chain dy
    final List<Key> chain = <Key>[
      const Key('m9s01-chip'),
      const Key('m9s01-review'),
      ValueKey<String>('m9s01-group-0'),
      ValueKey<String>('m9s01-card-0-0'),
      ValueKey<String>('m9s01-group-1'),
      ValueKey<String>('m9s01-card-1-0'),
      ValueKey<String>('m9s01-card-1-1'),
      ValueKey<String>('m9s01-card-1-2'),
      ValueKey<String>('m9s01-card-1-3'),
      ValueKey<String>('m9s01-card-1-4'),
      ValueKey<String>('m9s01-card-1-5'),
      ValueKey<String>('m9s01-card-1-6'),
      ValueKey<String>('m9s01-card-1-7'),
      ValueKey<String>('m9s01-card-1-8'),
      ValueKey<String>('m9s01-group-2'),
      ValueKey<String>('m9s01-card-2-0'),
      const Key('m9s01-asof'),
    ];
    for (int i = 0; i < chain.length - 1; i++) {
      final double dyA = tester.getTopLeft(find.byKey(chain[i])).dy;
      final double dyB = tester.getTopLeft(find.byKey(chain[i + 1])).dy;
      expect(dyA, lessThanOrEqualTo(dyB));
    }

    // absent keys
    expect(find.byKey(const ValueKey<String>('m9s01-group-3')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s01-card-0-1')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s01-card-1-9')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s01-card-2-1')), findsNothing);
    expect(find.byKey(const Key('m9s01-stale')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-02: level icon and color ─────────────────────────────────────────

  testWidgets('M9S01-02 level icon color', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(home)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    final ColorScheme cs = Theme.of(
      tester.element(find.byType(SettingsHome)),
    ).colorScheme;

    expect(home.groups[1].cards, hasLength(9)); // ⓗ
    expect(
      home.groups[1].cards.map((SettingsCard k) => k.level).toSet().length,
      greaterThan(1),
    ); // pre

    for (final (int c, SettingsCard card) in home.groups[1].cards.indexed) {
      final Icon icon = tester.widget<Icon>(
        find.byKey(ValueKey<String>('m9s01-level-1-$c')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(cs, card.level);
      expect(icon.icon, wantIcon);
      expect(icon.color, wantColor);
    }

    final Icon chipIcon = tester.widget<Icon>(
      find.byKey(const Key('m9s01-chip-level')),
    );
    final (IconData wantChipIcon, Color wantChipColor) = wantLevel(
      cs,
      home.statusChip.level,
    );
    expect(chipIcon.icon, wantChipIcon);
    expect(chipIcon.color, wantChipColor);

    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-03: group header lock = tier ─────────────────────────────────────

  testWidgets('M9S01-03 group lock tier', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(home)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      home.groups.map((SettingsGroup g) => g.tier).toList(),
      <SettingTier>[SettingTier.general, SettingTier.operational, SettingTier.rule],
    ); // pre

    final List<Matcher> lockMatchers = <Matcher>[
      findsNothing,
      findsOneWidget,
      findsOneWidget,
    ];
    for (int g = 0; g < home.groups.length; g++) {
      expect(
        find.byKey(ValueKey<String>('m9s01-lock-$g')),
        lockMatchers[g],
      );
    }

    for (final int g in <int>[1, 2]) {
      final Icon lockIcon = tester.widget<Icon>(
        find.byKey(ValueKey<String>('m9s01-lock-$g')),
      );
      expect(lockIcon.icon, wantLock(home.groups[g].tier));
    }

    expect(find.byKey(const ValueKey<String>('m9s01-group-0')), findsOneWidget);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-04: annual review card and promotion label = data ───────────────

  ({
    String name,
    SettingsHomeVm v,
    Matcher reviewMatcher,
    List<String> reviewTexts,
    List<String> chipTexts,
    Future<void> Function(WidgetTester t) flow,
    List<String> wantOpened,
  })
  caseHome = (
    name: 'home',
    v: home,
    reviewMatcher: findsOneWidget,
    reviewTexts: <String>[home.annualReviewLink!.label],
    chipTexts: <String>[
      home.statusChip.label,
      home.statusChip.promotionLabel!,
    ],
    flow: (WidgetTester t) async {
      await t.tap(find.byKey(const Key('m9s01-review')));
      await t.pump();
    },
    wantOpened: <String>[home.annualReviewLink!.deepLink],
  );

  ({
    String name,
    SettingsHomeVm v,
    Matcher reviewMatcher,
    List<String> reviewTexts,
    List<String> chipTexts,
    Future<void> Function(WidgetTester t) flow,
    List<String> wantOpened,
  })
  caseNoReview = (
    name: 'no_review',
    v: noReview,
    reviewMatcher: findsNothing,
    reviewTexts: <String>[],
    chipTexts: <String>[noReview.statusChip.label],
    flow: (WidgetTester t) async {},
    wantOpened: <String>[],
  );

  for (final c in <({
    String name,
    SettingsHomeVm v,
    Matcher reviewMatcher,
    List<String> reviewTexts,
    List<String> chipTexts,
    Future<void> Function(WidgetTester t) flow,
    List<String> wantOpened,
  })>[caseHome, caseNoReview]) {
    testWidgets('M9S01-04 annual review promotion ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(home.annualReviewLink, isNotNull); // pre
      expect(noReview.annualReviewLink, isNull); // pre

      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSettingsHome(
        tester,
        overrides: settingsHomeOverrides(
          repo: FakeSettingsRepository(home: (int call) => one(c.v)),
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s01-chip')), findsOneWidget);
      expect(find.byKey(const Key('m9s01-review')), c.reviewMatcher);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s01-review'))),
        c.reviewTexts,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s01-chip'))),
        c.chipTexts,
      );
      await c.flow(tester);
      expect(opener.opened, c.wantOpened);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S01-05: card tap = route as-is ───────────────────────────────────────

  testWidgets('M9S01-05 card tap route', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(home)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    final List<String> wantRoutes = <String>[
      for (final SettingsGroup g in home.groups)
        for (final SettingsCard k in g.cards) ?k.route,
    ];
    expect(wantRoutes, hasLength(11)); // ⓗ

    for (int g = 0; g < home.groups.length; g++) {
      for (int c = 0; c < home.groups[g].cards.length; c++) {
        await tester.tap(find.byKey(ValueKey<String>('m9s01-card-$g-$c')));
        await tester.pump();
      }
    }

    expect(opener.opened, wantRoutes);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-06: attention badge = attentionText as-is ────────────────────────

  testWidgets('M9S01-06 attention badge', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(home)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(home.groups[1].cards, hasLength(9)); // ⓗ
    expect(home.groups[1].cards[0].attentionText, isNotNull); // pre
    expect(home.groups[1].cards[1].attentionText, isNull); // pre

    for (final (int c, SettingsCard card) in home.groups[1].cards.indexed) {
      expect(
        find.byKey(ValueKey<String>('m9s01-attention-1-$c')),
        card.attentionText == null ? findsNothing : findsOneWidget,
      );
      expect(
        shownTexts(
          tester,
          find.byKey(ValueKey<String>('m9s01-attention-1-$c')),
        ),
        <String?>[?card.attentionText],
      );
    }

    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-07: viewer = received as-is ──────────────────────────────────────

  testWidgets('M9S01-07 viewer received as-is', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: FakeSettingsRepository(home: (int call) => one(viewer)),
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(viewer.groups[1].tier, SettingTier.operational); // pre

    for (final (int g, SettingsGroup group) in viewer.groups.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s01-group-$g'))),
        <String>[group.label],
      );
    }

    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s01-card-0-0'))),
      settingsCardTexts(viewer.groups[0].cards[0]),
    );
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s01-card-1-0'))),
      settingsCardTexts(viewer.groups[1].cards[0]),
    );
    expect(
      shownTexts(tester, find.byKey(const ValueKey<String>('m9s01-card-2-0'))),
      settingsCardTexts(viewer.groups[2].cards[0]),
    );
    expect(
      find.byKey(const ValueKey<String>('m9s01-card-1-1')),
      findsNothing,
    );
    expect(
      shownTexts(
        tester,
        find.byKey(const ValueKey<String>('m9s01-attention-1-0')),
      ),
      <String?>[viewer.groups[1].cards[0].attentionText],
    );
    expect(find.byKey(const Key('m9s01-review')), findsOneWidget);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-08: asOf line and stale banner two cases ─────────────────────────

  ({
    String name,
    Clock clock,
    Matcher staleMatcher,
    List<Key> chain,
  })
  caseFresh = (
    name: 'fresh',
    clock: FixedClock(kGoldenNowUtc),
    staleMatcher: findsNothing,
    chain: <Key>[const Key('m9s01-chip'), const Key('m9s01-asof')],
  );

  ({
    String name,
    Clock clock,
    Matcher staleMatcher,
    List<Key> chain,
  })
  caseStale = (
    name: 'stale',
    clock: FixedClock(
      home.asOf.observedAt.add(home.asOf.staleAfter).add(
        const Duration(seconds: 1),
      ),
    ),
    staleMatcher: findsOneWidget,
    chain: <Key>[
      const Key('m9s01-stale'),
      const Key('m9s01-chip'),
      const Key('m9s01-asof'),
    ],
  );

  for (final c in <({
    String name,
    Clock clock,
    Matcher staleMatcher,
    List<Key> chain,
  })>[caseFresh, caseStale]) {
    testWidgets('M9S01-08 asof stale ${c.name}', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSettingsHome(
        tester,
        overrides: settingsHomeOverrides(
          repo: FakeSettingsRepository(home: (int call) => one(home)),
          opener: opener,
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s01-stale')), c.staleMatcher);
      if (c.staleMatcher == findsOneWidget) {
        expect(
          shownTexts(tester, find.byKey(const Key('m9s01-stale'))),
          <String?>[SettingsLabels.staleBannerTitle, ?home.asOf.staleLabel],
        );
      }

      for (int i = 0; i < c.chain.length - 1; i++) {
        final double dyA = tester.getTopLeft(find.byKey(c.chain[i])).dy;
        final double dyB = tester.getTopLeft(find.byKey(c.chain[i + 1])).dy;
        expect(dyA, lessThanOrEqualTo(dyB));
      }

      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // ── M9S01-09: state branches two cases ─────────────────────────────────────

  ({String name, Stream<SettingsHomeVm> Function(int) repoFn, Matcher loadMatcher, Matcher failMatcher, Matcher chipMatcher})
  caseLoading = (
    name: 'loading',
    repoFn: (int call) =>
        Stream<SettingsHomeVm>.multi((MultiStreamController<SettingsHomeVm> c) {}),
    loadMatcher: findsOneWidget,
    failMatcher: findsNothing,
    chipMatcher: findsNothing,
  );

  ({String name, Stream<SettingsHomeVm> Function(int) repoFn, Matcher loadMatcher, Matcher failMatcher, Matcher chipMatcher})
  caseFail = (
    name: 'fail',
    repoFn: (int call) => Stream<SettingsHomeVm>.error(StateError('fail')),
    loadMatcher: findsNothing,
    failMatcher: findsOneWidget,
    chipMatcher: findsNothing,
  );

  for (final c in <({String name, Stream<SettingsHomeVm> Function(int) repoFn, Matcher loadMatcher, Matcher failMatcher, Matcher chipMatcher})>[
    caseLoading,
    caseFail,
  ]) {
    testWidgets('M9S01-09 state branch ${c.name}', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSettingsHome(
        tester,
        overrides: settingsHomeOverrides(
          repo: FakeSettingsRepository(home: c.repoFn),
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s01-loading')), c.loadMatcher);
      expect(find.byKey(const Key('m9s01-fail')), c.failMatcher);
      expect(find.byKey(const Key('m9s01-chip')), c.chipMatcher);
      if (c.failMatcher == findsOneWidget) {
        expect(find.text(SettingsLabels.retry), findsOneWidget);
      }
    });
  }

  // ── M9S01-10: retry ─────────────────────────────────────────────────────────

  testWidgets('M9S01-10 retry invalidate', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeSettingsRepository repo = FakeSettingsRepository(
      home: (int call) => call == 0
          ? Stream<SettingsHomeVm>.error(StateError('fail'))
          : one(home),
    );

    await pumpSettingsHome(
      tester,
      overrides: settingsHomeOverrides(
        repo: repo,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s01-fail')), findsNothing);
    expect(find.byKey(const Key('m9s01-chip')), findsOneWidget);
    expect(repo.homeCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // ── M9S01-11: all screen texts and large font three cases ──────────────────

  ({String name, SettingsHomeVm v})
  case11Home = (name: 'home', v: home);
  ({String name, SettingsHomeVm v})
  case11NoReview = (name: 'no_review', v: noReview);
  ({String name, SettingsHomeVm v})
  case11Viewer = (name: 'viewer', v: viewer);

  for (final c in <({String name, SettingsHomeVm v})>[
    case11Home,
    case11NoReview,
    case11Viewer,
  ]) {
    testWidgets('M9S01-11 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpSettingsHome(
        tester,
        overrides: settingsHomeOverrides(
          repo: FakeSettingsRepository(home: (int call) => one(c.v)),
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final Set<String> allowed = settingsHomeAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byType(IconButton), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }
}
