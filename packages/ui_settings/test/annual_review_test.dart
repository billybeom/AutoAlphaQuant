// test/annual_review_test.dart
//
// M9 S12 - AnnualReviewEntry widget tests.
//
// ASCII only. No Korean literals. No collection-if. No bare if statements.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

void main() {
  final AnnualReviewIndexVm open = singleFixture(
    FixturePaths.m9AnnualReviewIndexOpen,
    AnnualReviewIndexVm.fromJson,
  );
  final AnnualReviewIndexVm closed = singleFixture(
    FixturePaths.m9AnnualReviewIndexClosed,
    AnnualReviewIndexVm.fromJson,
  );
  final AnnualReviewIndexVm firstYear = singleFixture(
    FixturePaths.m9AnnualReviewIndexFirstYear,
    AnnualReviewIndexVm.fromJson,
  );
  final AnnualReviewIndexVm stale = singleFixture(
    FixturePaths.m9AnnualReviewIndexStale,
    AnnualReviewIndexVm.fromJson,
  );

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.error(StateError('no write')),
  );
  SettingsActions? noActions() => null;

  // -- M9S12-01: block order, texts, row count, pledge only when received ----

  for (final c in <({String name, AnnualReviewIndexVm v, List<Key> chain})>[
    (
      name: 'open',
      v: open,
      chain: <Key>[
        const Key('m9s12-head'),
        const Key('m9s12-entries'),
        const Key('m9s12-pledge'),
        const Key('m9s12-asof'),
      ],
    ),
    (
      name: 'closed',
      v: closed,
      chain: <Key>[
        const Key('m9s12-head'),
        const Key('m9s12-entries'),
        const Key('m9s12-asof'),
      ],
    ),
    (
      name: 'first_year',
      v: firstYear,
      chain: <Key>[
        const Key('m9s12-head'),
        const Key('m9s12-entries'),
        const Key('m9s12-asof'),
      ],
    ),
  ]) {
    testWidgets('M9S12-01 block order texts ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsAnnualReviewRepository repo =
          FakeSettingsAnnualReviewRepository(annual: (int call) => one(c.v));
      await pumpAnnualReview(
        tester,
        overrides: annualReviewOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s12-entries')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-head'))),
        annualHeadTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-entries'))),
        annualEntryLabels(c.v),
      );
      expect(
        find.byWidgetPredicate(isAnnualEntryRow),
        findsNWidgets(c.v.entries.length),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-pledge'))),
        <String?>[?c.v.pledgeLink?.label],
      );
      expect(shownTexts(tester, find.byKey(const Key('m9s12-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.byWidgetPredicate(isAnyButton), findsNothing);
      expect(find.byKey(const Key('m9s12-stale')), findsNothing);

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S12-02: row keys, row tap opens that row link, nothing written ------

  for (final c in <({String name, AnnualReviewIndexVm v})>[
    (name: 'open', v: open),
    (name: 'closed', v: closed),
    (name: 'first_year', v: firstYear),
  ]) {
    testWidgets('M9S12-02 row tap opens received link ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.v.entries, isNotEmpty); // pre

      final FakeSettingsAnnualReviewRepository repo =
          FakeSettingsAnnualReviewRepository(annual: (int call) => one(c.v));
      final FakeSettingsActions actions = okActions();
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpAnnualReview(
        tester,
        overrides: annualReviewOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(opener.opened, <String>[]);
      for (final (int i, LinkAction entry) in c.v.entries.indexed) {
        expect(
          shownTexts(tester, find.byKey(Key('m9s12-entry-$i'))),
          annualEntryTexts(entry),
        );
        await tester.tap(find.byKey(Key('m9s12-entry-$i')));
      }
      await tester.pump();
      expect(opener.opened, annualEntryLinks(c.v));
      expect(actions.ids, <SettingsActionId>[]);
      expect(actions.watchCalls, 0);
      expect(repo.annualCalls, 1);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-entries'))),
        annualEntryLabels(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-head'))),
        annualHeadTexts(c.v),
      );

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S12-03: pledge tap opens the received pledge link --------------------

  testWidgets('M9S12-03 pledge tap opens received link open', (
    WidgetTester tester,
  ) async {
    expect(open.pledgeLink, isNotNull); // pre

    final FakeSettingsAnnualReviewRepository repo =
        FakeSettingsAnnualReviewRepository(annual: (int call) => one(open));
    final FakeSettingsActions actions = okActions();
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAnnualReview(
      tester,
      overrides: annualReviewOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(opener.opened, <String>[]);
    await tester.tap(find.byKey(const Key('m9s12-pledge')));
    await tester.pump();
    expect(opener.opened, <String>[?open.pledgeLink?.deepLink]);
    expect(actions.ids, <SettingsActionId>[]);
    expect(repo.annualCalls, 1);
    expect(find.byType(EditableText), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('m9s12-pledge'))), <String?>[
      ?open.pledgeLink?.label,
    ]);
    expect(
      shownTexts(tester, find.byKey(const Key('m9s12-entries'))),
      annualEntryLabels(open),
    );

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S12-04: viewer branch (no actions injected) shows the same tree ------

  testWidgets('M9S12-04 viewer branch same data and link open_viewer', (
    WidgetTester tester,
  ) async {
    expect(open.pledgeLink, isNotNull); // pre

    final FakeSettingsAnnualReviewRepository repo =
        FakeSettingsAnnualReviewRepository(annual: (int call) => one(open));
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpAnnualReview(
      tester,
      overrides: annualReviewOverrides(
        repo: repo,
        actions: null,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(find.byKey(const Key('m9s12-head')), findsOneWidget);
    expect(
      shownTexts(tester, find.byKey(const Key('m9s12-head'))),
      annualHeadTexts(open),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s12-entries'))),
      annualEntryLabels(open),
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s12-pledge'))), <String?>[
      ?open.pledgeLink?.label,
    ]);
    expect(find.byWidgetPredicate(isAnyButton), findsNothing);

    await tester.tap(find.byKey(const Key('m9s12-pledge')));
    await tester.pump();
    expect(opener.opened, <String>[?open.pledgeLink?.deepLink]);
    expect(repo.annualCalls, 1);

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S12-05: asof line and stale banner -----------------------------------

  for (final c
      in <
        ({
          String name,
          AnnualReviewIndexVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: open,
          clock: FixedClock(open.asOf.observedAt),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s12-head'), const Key('m9s12-asof')],
        ),
        (
          name: 'stale',
          v: stale,
          clock: FixedClock(
            stale.asOf.observedAt
                .add(stale.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?stale.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s12-stale'),
            const Key('m9s12-head'),
            const Key('m9s12-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S12-05 asof and stale banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(stale.asOf.staleLabel, isNotNull); // pre

      final FakeSettingsAnnualReviewRepository repo =
          FakeSettingsAnnualReviewRepository(annual: (int call) => one(c.v));
      await pumpAnnualReview(
        tester,
        overrides: annualReviewOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s12-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s12-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s12-stale'))),
        c.staleTexts,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S12-06: loading and error branches -----------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<AnnualReviewIndexVm> Function(int call) annual,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          annual: (int call) => Stream<AnnualReviewIndexVm>.multi(
            (MultiStreamController<AnnualReviewIndexVm> m) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          annual: (int call) =>
              Stream<AnnualReviewIndexVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S12-06 state branch ${c.name}', (WidgetTester tester) async {
      final FakeSettingsAnnualReviewRepository repo =
          FakeSettingsAnnualReviewRepository(annual: c.annual);
      await pumpAnnualReview(
        tester,
        overrides: annualReviewOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s12-loading')), c.loading);
      expect(find.byKey(const Key('m9s12-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s12-entries')), findsNothing);
    });
  }

  // -- M9S12-07: retry subscribes once more -----------------------------------

  testWidgets('M9S12-07 retry after error', (WidgetTester tester) async {
    final FakeSettingsAnnualReviewRepository repo =
        FakeSettingsAnnualReviewRepository(
          annual: (int call) => call == 0
              ? Stream<AnnualReviewIndexVm>.error(StateError('fail'))
              : one(open),
        );
    await pumpAnnualReview(
      tester,
      overrides: annualReviewOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s12-fail')), findsNothing);
    expect(find.byKey(const Key('m9s12-entries')), findsOneWidget);
    expect(repo.annualCalls, 2);

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S12-08: every Text is received data (large font) ---------------------

  for (final c
      in <
        ({
          String name,
          AnnualReviewIndexVm v,
          SettingsActions? Function() actionsFactory,
        })
      >[
        (name: 'open', v: open, actionsFactory: okActions),
        (name: 'closed', v: closed, actionsFactory: okActions),
        (name: 'first_year', v: firstYear, actionsFactory: okActions),
        (name: 'open_viewer', v: open, actionsFactory: noActions),
      ]) {
    testWidgets('M9S12-08 all texts allowed large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final FakeSettingsAnnualReviewRepository repo =
          FakeSettingsAnnualReviewRepository(annual: (int call) => one(c.v));
      await pumpAnnualReview(
        tester,
        overrides: annualReviewOverrides(
          repo: repo,
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byType(EditableText), findsNothing);
      final Set<String> allowed = annualReviewAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(find.byType(IconButton), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
