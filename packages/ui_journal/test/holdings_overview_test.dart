// holdings_overview_test.dart - H6-1 holdings overview widget tests (T61-01..15).
//
// Fixtures only: no DTO is built by hand. The one allowed copyWith is the
// card slice in T61-02.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

/// Top edge of the widget with [key].
double _dy(WidgetTester tester, Key key) =>
    tester.getTopLeft(find.byKey(key)).dy;

/// One branch of T61-12.
class _Branch {
  _Branch({
    required this.name,
    required this.overview,
    required this.steps,
    required this.skeleton,
    required this.fail,
    required this.asOf,
    required this.banner,
    required this.stale,
    required this.empty,
    this.clock,
  });

  final String name;
  final Stream<HoldingsOverviewVm> Function(
    bool includePnl,
    StreamController<HoldingsOverviewVm> silent,
  )
  overview;
  final Clock? clock;
  final Future<void> Function(WidgetTester tester) steps;
  final bool skeleton;
  final bool fail;
  final bool asOf;
  final bool banner;
  final bool stale;
  final bool empty;
}

/// One case of T61-13.
class _RetryCase {
  _RetryCase({
    required this.name,
    required this.overview,
    required this.steps,
    required this.lastAsOf,
    required this.calls,
  });

  final String name;
  final Stream<HoldingsOverviewVm> Function(bool includePnl, int call) overview;
  final Future<void> Function(WidgetTester tester) steps;
  final String? lastAsOf;
  final List<bool> calls;
}

void main() {
  final HoldingsOverviewVm normal = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewNormal,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm recon = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewRecon,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm integrity = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewIntegrity,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm empty = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewEmpty,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm pnl = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewPnl,
    HoldingsOverviewVm.fromJson,
  );
  final HoldingsOverviewVm viewer = singleFixture<HoldingsOverviewVm>(
    FixturePaths.m6HoldingsOverviewViewer,
    HoldingsOverviewVm.fromJson,
  );

  Stream<HoldingsOverviewVm> valueThenFail(HoldingsOverviewVm v) async* {
    yield v;
    throw StateError('overview');
  }

  // ── T61-01 ────────────────────────────────────────────────────────────────
  testWidgets('T61-01 entry and card heads', (WidgetTester tester) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    expect(repo.calls, <bool>[false]);
    expect(holdingsShownTexts(tester, const Key('h61-asof')), <String?>[
      normal.asOf.label,
    ]);
    final ColorScheme cs = Theme.of(
      tester.element(find.byKey(const Key('h61-asof'))),
    ).colorScheme;
    expect(normal.cards, hasLength(3));
    for (final (int c, HoldingsSleeveCard card) in normal.cards.indexed) {
      final Key head = ValueKey<String>('h61-card-toggle-$c');
      expect(holdingsShownTexts(tester, head), holdingsCardHeadTexts(card));
      final SleeveWeight? w = card.allocation.sleeveWeight;
      if (w != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h61-card-weight-$c')))
              .data,
          w.label,
        );
      } else {
        expect(
          find.byKey(ValueKey<String>('h61-card-weight-$c')),
          findsNothing,
        );
      }
      final String? note = card.allocation.bandNoteText;
      if (note != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h61-card-note-$c')))
              .data,
          note,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h61-card-note-$c')), findsNothing);
      }
      final SleeveBandState? state = card.allocation.bandState;
      if (state != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h61-card-state-$c')))
              .data,
          card.allocation.bandStateLabel,
        );
        final Color want = switch (state) {
          SleeveBandState.inBand => cs.primary,
          SleeveBandState.nearEdge => cs.tertiary,
          SleeveBandState.outOfBand => cs.error,
        };
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: find.byKey(head),
                  matching: find.byIcon(Icons.circle),
                ),
              )
              .color,
          want,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h61-card-state-$c')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(head),
            matching: find.byIcon(Icons.circle),
          ),
          findsNothing,
        );
      }
      expect(find.byKey(ValueKey<String>('h61-row-$c-0')), findsNothing);
    }
    expect(find.byKey(const ValueKey<String>('h61-card-3')), findsNothing);
    expect(normal.pnlToggleLabel, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-pnl-toggle')),
        matching: find.text(normal.pnlToggleLabel!),
      ),
      findsOneWidget,
    );
    expect(normal.allocationLink, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-alloc-link')),
        matching: find.text(normal.allocationLink!.label),
      ),
      findsOneWidget,
    );
    expect(
      _dy(tester, const Key('h61-asof')),
      lessThan(_dy(tester, const Key('h61-alloc-link'))),
    );
    expect(
      _dy(tester, const Key('h61-alloc-link')),
      lessThan(_dy(tester, const Key('h61-pnl-toggle'))),
    );
    expect(
      _dy(tester, const Key('h61-pnl-toggle')),
      lessThan(_dy(tester, const ValueKey<String>('h61-card-0'))),
    );
    expect(find.text(JournalLabels.holdingsAvgPrice), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-02 ────────────────────────────────────────────────────────────────
  final List<(String, HoldingsOverviewVm, int)> countCases =
      <(String, HoldingsOverviewVm, int)>[
        ('all', normal, 3),
        ('first_two', normal.copyWith(cards: normal.cards.sublist(0, 2)), 2),
      ];
  for (final (String name, HoldingsOverviewVm v, int cardCount) in countCases) {
    testWidgets('T61-02 card count follows data $name', (
      WidgetTester tester,
    ) async {
      final FakeHoldingsRepository repo = fakeHoldingsOverview(v, v);
      await pumpHoldingsOverview(
        tester,
        overrides: holdingsOverviewOverrides(repo: repo),
      );
      await tester.pump();
      expect(v.cards, hasLength(cardCount));
      for (final (int c, HoldingsSleeveCard card) in v.cards.indexed) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h61-card-title-$c')))
              .data,
          card.titleText,
        );
      }
      expect(find.byKey(ValueKey<String>('h61-card-$cardCount')), findsNothing);
      expect(repo.calls, <bool>[false]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T61-03 ────────────────────────────────────────────────────────────────
  testWidgets('T61-03 card B open and close', (WidgetTester tester) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    await openHoldingsCard(tester, 1);
    final HoldingsSleeveCard b = normal.cards[1];
    expect(b.rows, hasLength(2));
    for (final (int r, HoldingRow row) in b.rows.indexed) {
      final Finder rowFinder = find.byKey(ValueKey<String>('h61-row-1-$r'));
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-row-1-$r')),
        holdingsRowTexts(row),
      );
      if (row.pendingText != null) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('h61-pending-1-$r')),
            matching: find.text(row.pendingText!),
          ),
          findsOneWidget,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h61-pending-1-$r')), findsNothing);
      }
      if (row.subBookLabel != null) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('h61-subbook-1-$r')),
            matching: find.text(row.subBookLabel!),
          ),
          findsOneWidget,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h61-subbook-1-$r')), findsNothing);
      }
      for (final TrancheStep s in row.smaTranches) {
        expect(
          holdingsChipIcon(tester, rowFinder, s.label),
          s.filled ? Icons.check_circle : Icons.radio_button_unchecked,
        );
      }
      for (final GateBadge g in row.gates) {
        expect(g.state, GateState.pass);
        expect(
          holdingsChipIcon(tester, rowFinder, g.label),
          Icons.check_circle_outline,
        );
      }
    }
    expect(
      _dy(tester, const ValueKey<String>('h61-card-toggle-1')),
      lessThan(_dy(tester, const ValueKey<String>('h61-row-1-0'))),
    );
    expect(
      _dy(tester, const ValueKey<String>('h61-row-1-0')),
      lessThan(_dy(tester, const ValueKey<String>('h61-row-1-1'))),
    );
    expect(
      _dy(tester, const ValueKey<String>('h61-row-1-1')),
      lessThan(_dy(tester, const ValueKey<String>('h61-card-2'))),
    );
    expect(find.byKey(const ValueKey<String>('h61-row-0-0')), findsNothing);
    expect(find.byKey(const ValueKey<String>('h61-row-2-0')), findsNothing);
    await openHoldingsCard(tester, 1);
    expect(find.byKey(const ValueKey<String>('h61-row-1-0')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-04 ────────────────────────────────────────────────────────────────
  testWidgets('T61-04 card A with POT rows last', (WidgetTester tester) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    expect(normal.cards[0].rows[2].subBookLabel, isNotNull);
    await openHoldingsCard(tester, 0);
    final HoldingsSleeveCard a = normal.cards[0];
    expect(a.rows, hasLength(3));
    for (final (int r, HoldingRow row) in a.rows.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-row-0-$r')),
        holdingsRowTexts(row),
      );
      if (row.subBookLabel != null) {
        expect(
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byKey(ValueKey<String>('h61-subbook-0-$r')),
                  matching: find.byType(Text),
                ),
              )
              .data,
          row.subBookLabel,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h61-subbook-0-$r')), findsNothing);
      }
    }
    expect(
      _dy(tester, const ValueKey<String>('h61-row-0-0')),
      lessThan(_dy(tester, const ValueKey<String>('h61-row-0-1'))),
    );
    expect(
      _dy(tester, const ValueKey<String>('h61-row-0-1')),
      lessThan(_dy(tester, const ValueKey<String>('h61-row-0-2'))),
    );
    expect(
      _dy(tester, const ValueKey<String>('h61-row-0-2')),
      lessThan(_dy(tester, const ValueKey<String>('h61-card-1'))),
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-05 ────────────────────────────────────────────────────────────────
  testWidgets('T61-05 external section', (WidgetTester tester) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    expect(normal.external, isNotNull);
    final HoldingsExternalSection ext = normal.external!;
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-ext')),
        matching: find.text(ext.titleText),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('h61-ext-notice'))).data,
      ext.noticeText,
    );
    expect(ext.bannerText, isNull);
    expect(find.byKey(const Key('h61-ext-banner')), findsNothing);
    expect(find.byKey(const ValueKey<String>('h61-ext-row-0')), findsNothing);
    await openHoldingsExternal(tester);
    expect(ext.rows, hasLength(2));
    for (final (int k, ExternalHoldingRow x) in ext.rows.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-ext-row-$k')),
        holdingsExternalRowTexts(x),
      );
    }
    expect(find.byKey(const ValueKey<String>('h61-ext-row-2')), findsNothing);
    expect(find.byKey(const Key('h61-ext-notice')), findsOneWidget);
    expect(
      _dy(tester, const ValueKey<String>('h61-card-2')),
      lessThan(_dy(tester, const Key('h61-ext'))),
    );
    await openHoldingsExternal(tester);
    expect(find.byKey(const ValueKey<String>('h61-ext-row-0')), findsNothing);
    expect(find.byKey(const Key('h61-ext-notice')), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-06 ────────────────────────────────────────────────────────────────
  testWidgets('T61-06 pnl toggle resubscribes and reentry closes', (
    WidgetTester tester,
  ) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    final List<Override> overrides = holdingsOverviewOverrides(repo: repo);
    await pumpHoldingsOverview(tester, overrides: overrides);
    await tester.pump();
    await openHoldingsCard(tester, 0);
    await openHoldingsCard(tester, 1);
    await openHoldingsCard(tester, 2);
    expect(repo.calls, <bool>[false]);
    expect(pnl.cards, hasLength(3));
    for (final (int c, HoldingsSleeveCard card) in pnl.cards.indexed) {
      for (final (int r, HoldingRow _) in card.rows.indexed) {
        expect(find.byKey(ValueKey<String>('h61-pnl-$c-$r')), findsNothing);
      }
    }
    await tapHoldingsPnlToggle(tester);
    expect(repo.calls, <bool>[false, true]);
    for (final (int c, HoldingsSleeveCard card) in pnl.cards.indexed) {
      for (final (int r, HoldingRow row) in card.rows.indexed) {
        if (row.pnl != null) {
          expect(
            holdingsShownTexts(tester, ValueKey<String>('h61-row-$c-$r')),
            holdingsRowTexts(row),
          );
          expect(find.byKey(ValueKey<String>('h61-pnl-$c-$r')), findsOneWidget);
        } else {
          expect(find.byKey(ValueKey<String>('h61-pnl-$c-$r')), findsNothing);
        }
      }
    }
    expect(find.byKey(const ValueKey<String>('h61-row-0-0')), findsOneWidget);
    expect(pnl.pnlToggleLabel, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-pnl-toggle')),
        matching: find.text(pnl.pnlToggleLabel!),
      ),
      findsOneWidget,
    );
    await tapHoldingsPnlToggle(tester);
    expect(repo.calls, <bool>[false, true]);
    for (final (int c, HoldingsSleeveCard card) in pnl.cards.indexed) {
      for (final (int r, HoldingRow _) in card.rows.indexed) {
        expect(find.byKey(ValueKey<String>('h61-pnl-$c-$r')), findsNothing);
      }
    }
    await tapHoldingsPnlToggle(tester);
    expect(repo.calls, <bool>[false, true]);
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-pnl-toggle')),
        matching: find.byIcon(Icons.expand_less),
      ),
      findsOneWidget,
    );
    await pumpHoldingsOverview(
      tester,
      overrides: overrides,
      screenKey: const ValueKey<String>('again'),
    );
    await tester.pump();
    expect(repo.calls, <bool>[false, true]);
    expect(find.byKey(const ValueKey<String>('h61-row-0-0')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('h61-pnl-toggle')),
        matching: find.byIcon(Icons.expand_more),
      ),
      findsOneWidget,
    );
    await openHoldingsCard(tester, 0);
    expect(find.byKey(const ValueKey<String>('h61-pnl-0-0')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-07 ────────────────────────────────────────────────────────────────
  testWidgets('T61-07 recon shows engine text only', (
    WidgetTester tester,
  ) async {
    final SafetyState safety = safetyFixtureRow(3);
    final FakeHoldingsRepository repo = fakeHoldingsOverview(recon, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo, safety: safety),
    );
    await tester.pump();
    expect(safety.activeFlags, isNotEmpty);
    for (final BlockFlag f in safety.activeFlags) {
      expect(find.text(f.label), findsOneWidget);
    }
    final HoldingsSleeveCard rc = recon.cards[1];
    expect(rc.allocation.sleeveWeight, isNotNull);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h61-card-weight-1')))
          .data,
      rc.allocation.sleeveWeight!.label,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h61-card-state-1')))
          .data,
      rc.allocation.bandStateLabel,
    );
    await openHoldingsCard(tester, 1);
    expect(rc.rows, hasLength(2));
    for (final (int r, HoldingRow row) in rc.rows.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-row-1-$r')),
        holdingsRowTexts(row),
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('h61-row-1-$r')),
          matching: find.byIcon(Icons.warning_amber_rounded),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('h61-row-1-$r')),
          matching: find.byIcon(Icons.error_outline),
        ),
        findsNothing,
      );
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-08 ────────────────────────────────────────────────────────────────
  testWidgets('T61-08 integrity shows masked text and no chips', (
    WidgetTester tester,
  ) async {
    final SafetyState safety = safetyFixtureRow(4);
    final FakeHoldingsRepository repo = fakeHoldingsOverview(integrity, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo, safety: safety),
    );
    await tester.pump();
    expect(safety.activeFlags, isNotEmpty);
    for (final BlockFlag f in safety.activeFlags) {
      expect(find.text(f.label), findsOneWidget);
    }
    expect(integrity.cards, hasLength(3));
    for (final (int c, HoldingsSleeveCard card) in integrity.cards.indexed) {
      expect(card.allocation.sleeveWeight, isNull);
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-card-toggle-$c')),
        holdingsCardHeadTexts(card),
      );
      expect(find.byKey(ValueKey<String>('h61-card-weight-$c')), findsNothing);
      expect(find.byKey(ValueKey<String>('h61-card-state-$c')), findsNothing);
      await openHoldingsCard(tester, c);
      for (final (int r, HoldingRow row) in card.rows.indexed) {
        expect(row.smaTranches, isEmpty);
        expect(row.pendingText, isNull);
        expect(
          holdingsShownTexts(tester, ValueKey<String>('h61-row-$c-$r')),
          holdingsRowTexts(row),
        );
        expect(find.byKey(ValueKey<String>('h61-pending-$c-$r')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('h61-row-$c-$r')),
            matching: find.byIcon(Icons.check_circle),
          ),
          findsNothing,
        );
      }
    }
    await openHoldingsExternal(tester);
    final HoldingsExternalSection ext = integrity.external!;
    for (final (int k, ExternalHoldingRow x) in ext.rows.indexed) {
      expect(x.quantityText, normal.external!.rows[k].quantityText);
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h61-ext-row-$k')),
        holdingsExternalRowTexts(x),
      );
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-09 ────────────────────────────────────────────────────────────────
  final List<(String, HoldingsOverviewVm, Future<void> Function(WidgetTester))>
  textCases =
      <(String, HoldingsOverviewVm, Future<void> Function(WidgetTester))>[
        (
          'closed',
          normal,
          (WidgetTester t) async {
            await openHoldingsCard(t, 0);
            await openHoldingsCard(t, 1);
            await openHoldingsCard(t, 2);
            await openHoldingsExternal(t);
          },
        ),
        (
          'expanded',
          pnl,
          (WidgetTester t) async {
            await tapHoldingsPnlToggle(t);
            await openHoldingsCard(t, 0);
            await openHoldingsCard(t, 1);
            await openHoldingsCard(t, 2);
            await openHoldingsExternal(t);
          },
        ),
      ];
  for (final (
        String name,
        HoldingsOverviewVm vm,
        Future<void> Function(WidgetTester) steps,
      )
      in textCases) {
    testWidgets('T61-09 every Text is engine text $name', (
      WidgetTester tester,
    ) async {
      final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
      await pumpHoldingsOverview(
        tester,
        overrides: holdingsOverviewOverrides(repo: repo),
      );
      await tester.pump();
      await steps(tester);
      final Set<String> allowed = holdingsOverviewAllowed(vm);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T61-10 ────────────────────────────────────────────────────────────────
  testWidgets('T61-10 viewer has no toggle and no external', (
    WidgetTester tester,
  ) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(viewer, viewer);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    expect(viewer.pnlToggleLabel, isNull);
    expect(viewer.external, isNull);
    expect(find.byKey(const Key('h61-pnl-toggle')), findsNothing);
    expect(find.byKey(const Key('h61-ext')), findsNothing);
    expect(find.byKey(const ValueKey<String>('h61-card-2')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('h61-card-3')), findsNothing);
    expect(find.byKey(const Key('h61-alloc-link')), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(viewer.cards.length));
    expect(repo.calls, <bool>[false]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-11 ────────────────────────────────────────────────────────────────
  testWidgets('T61-11 links come from data only', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeHoldingsRepository repo = fakeHoldingsOverview(normal, pnl);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo, opener: opener),
    );
    await tester.pump();
    await openHoldingsCard(tester, 1);
    final HoldingRow r0 = normal.cards[1].rows[0];
    final HoldingRow r1 = normal.cards[1].rows[1];
    expect(r0.detailDeepLink, isNotNull);
    expect(r1.entryReasons[0].detailDeepLink, isNotNull);
    expect(normal.allocationLink, isNotNull);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h61-row-1-0')),
        matching: find.text(r0.symbolLabel),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h61-row-1-1')),
        matching: find.byType(ActionChip),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('h61-alloc-link')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('h61-card-toggle-2')));
    await tester.pump();
    expect(opener.opened, <String>[
      r0.detailDeepLink!,
      r1.entryReasons[0].detailDeepLink!,
      normal.allocationLink!.deepLink,
    ]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T61-12 ────────────────────────────────────────────────────────────────
  final DateTime staleNow = kGoldenNowUtc.add(const Duration(days: 2));
  Future<void> noSteps(WidgetTester t) async {}
  final List<_Branch> branches = <_Branch>[
    _Branch(
      name: 'loading',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          silent.stream,
      steps: noSteps,
      skeleton: true,
      fail: false,
      asOf: false,
      banner: false,
      stale: false,
      empty: false,
    ),
    _Branch(
      name: 'fail',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.error(StateError('overview')),
      steps: noSteps,
      skeleton: false,
      fail: true,
      asOf: false,
      banner: false,
      stale: false,
      empty: false,
    ),
    _Branch(
      name: 'empty',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.value(empty),
      steps: noSteps,
      skeleton: false,
      fail: false,
      asOf: true,
      banner: true,
      stale: false,
      empty: true,
    ),
    _Branch(
      name: 'empty_stale',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.value(empty),
      clock: FixedClock(staleNow),
      steps: noSteps,
      skeleton: false,
      fail: false,
      asOf: true,
      banner: true,
      stale: true,
      empty: true,
    ),
    _Branch(
      name: 'normal',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.value(normal),
      steps: noSteps,
      skeleton: false,
      fail: false,
      asOf: true,
      banner: true,
      stale: false,
      empty: false,
    ),
    _Branch(
      name: 'normal_stale',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.value(normal),
      clock: FixedClock(staleNow),
      steps: noSteps,
      skeleton: false,
      fail: false,
      asOf: true,
      banner: true,
      stale: true,
      empty: false,
    ),
    _Branch(
      name: 'integrity',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          Stream<HoldingsOverviewVm>.value(integrity),
      steps: noSteps,
      skeleton: false,
      fail: false,
      asOf: true,
      banner: true,
      stale: false,
      empty: false,
    ),
    _Branch(
      name: 'pnl_loading',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) =>
          p ? silent.stream : Stream<HoldingsOverviewVm>.value(normal),
      steps: tapHoldingsPnlToggle,
      skeleton: true,
      fail: false,
      asOf: false,
      banner: false,
      stale: false,
      empty: false,
    ),
    _Branch(
      name: 'pnl_fail',
      overview: (bool p, StreamController<HoldingsOverviewVm> silent) => p
          ? Stream<HoldingsOverviewVm>.error(StateError('overview'))
          : Stream<HoldingsOverviewVm>.value(normal),
      steps: tapHoldingsPnlToggle,
      skeleton: false,
      fail: true,
      asOf: false,
      banner: false,
      stale: false,
      empty: false,
    ),
  ];
  for (final _Branch b in branches) {
    testWidgets('T61-12 branch text and banners ${b.name}', (
      WidgetTester tester,
    ) async {
      final SafetyState safety = safetyFixtureRow(3);
      final StreamController<HoldingsOverviewVm> silent =
          StreamController<HoldingsOverviewVm>();
      addTearDown(() {
        unawaited(silent.close());
      });
      final FakeHoldingsRepository repo = FakeHoldingsRepository(
        overview: (bool includePnl, int call) => b.overview(includePnl, silent),
      );
      await pumpHoldingsOverview(
        tester,
        overrides: holdingsOverviewOverrides(
          repo: repo,
          safety: safety,
          clock: b.clock,
        ),
      );
      await tester.pump();
      await b.steps(tester);
      expect(
        find.byKey(const Key('h61-loading')),
        b.skeleton ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('h61-fail')),
        b.fail ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('h61-asof')),
        b.asOf ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.staleBannerTitle),
        b.stale ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('h61-empty')),
        b.empty ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.retry),
        b.fail ? findsOneWidget : findsNothing,
      );
      expect(safety.activeFlags, isNotEmpty);
      for (final BlockFlag f in safety.activeFlags) {
        expect(find.text(f.label), b.banner ? findsOneWidget : findsNothing);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text(JournalLabels.holdingsAvgPrice), findsNothing);
    });
  }

  // ── T61-13 ────────────────────────────────────────────────────────────────
  final List<_RetryCase> retryCases = <_RetryCase>[
    _RetryCase(
      name: 'overview_fail',
      overview: (bool p, int call) => call == 0
          ? Stream<HoldingsOverviewVm>.error(StateError('overview'))
          : Stream<HoldingsOverviewVm>.value(normal),
      steps: noSteps,
      lastAsOf: null,
      calls: <bool>[false, false],
    ),
    _RetryCase(
      name: 'pnl_fail',
      overview: (bool p, int call) => p
          ? (call == 1
                ? Stream<HoldingsOverviewVm>.error(StateError('overview'))
                : Stream<HoldingsOverviewVm>.value(pnl))
          : Stream<HoldingsOverviewVm>.value(normal),
      steps: tapHoldingsPnlToggle,
      lastAsOf: null,
      calls: <bool>[false, true, true],
    ),
    _RetryCase(
      name: 'value_then_fail',
      overview: (bool p, int call) => call == 0
          ? valueThenFail(normal)
          : Stream<HoldingsOverviewVm>.value(normal),
      steps: noSteps,
      lastAsOf: normal.asOf.label,
      calls: <bool>[false, false],
    ),
  ];
  for (final _RetryCase rc in retryCases) {
    testWidgets('T61-13 error and retry ${rc.name}', (
      WidgetTester tester,
    ) async {
      final SafetyState safety = safetyFixtureRow(3);
      final FakeHoldingsRepository repo = FakeHoldingsRepository(
        overview: rc.overview,
      );
      await pumpHoldingsOverview(
        tester,
        overrides: holdingsOverviewOverrides(repo: repo, safety: safety),
      );
      await tester.pump();
      await rc.steps(tester);
      expect(find.byKey(const Key('h61-fail')), findsOneWidget);
      expect(
        tester
            .widget<JournalErrorView>(find.byType(JournalErrorView))
            .lastAsOfLabel,
        rc.lastAsOf,
      );
      expect(safety.activeFlags, isNotEmpty);
      for (final BlockFlag f in safety.activeFlags) {
        expect(find.text(f.label), findsNothing);
      }
      await tester.tap(find.text(JournalLabels.retry));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('h61-fail')), findsNothing);
      expect(find.byKey(const Key('h61-asof')), findsOneWidget);
      expect(repo.calls, rc.calls);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T61-14 ────────────────────────────────────────────────────────────────
  final List<(String, HoldingsOverviewVm, Future<void> Function(WidgetTester))>
  scaleCases =
      <(String, HoldingsOverviewVm, Future<void> Function(WidgetTester))>[
        (
          'open',
          normal,
          (WidgetTester t) async {
            await openHoldingsCard(t, 0);
            await openHoldingsCard(t, 1);
            await openHoldingsCard(t, 2);
            await openHoldingsExternal(t);
          },
        ),
        ('empty', empty, noSteps),
      ];
  for (final (
        String name,
        HoldingsOverviewVm vm,
        Future<void> Function(WidgetTester) steps,
      )
      in scaleCases) {
    testWidgets('T61-14 large font no overflow $name', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final FakeHoldingsRepository repo = fakeHoldingsOverview(vm, vm);
      await pumpHoldingsOverview(
        tester,
        overrides: holdingsOverviewOverrides(repo: repo),
      );
      await tester.pump();
      await steps(tester);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byKey(const Key('h61-asof')), -300);
      expect(find.byKey(const Key('h61-asof')), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T61-15 ────────────────────────────────────────────────────────────────
  testWidgets('T61-15 pnl lines follow data not the toggle', (
    WidgetTester tester,
  ) async {
    final FakeHoldingsRepository repo = fakeHoldingsOverview(pnl, normal);
    await pumpHoldingsOverview(
      tester,
      overrides: holdingsOverviewOverrides(repo: repo),
    );
    await tester.pump();
    expect(pnl.cards[0].rows[0].pnl, isNotNull);
    await openHoldingsCard(tester, 0);
    expect(repo.calls, <bool>[false]);
    expect(find.byKey(const ValueKey<String>('h61-pnl-0-0')), findsOneWidget);
    await tapHoldingsPnlToggle(tester);
    expect(repo.calls, <bool>[false, true]);
    expect(find.byKey(const ValueKey<String>('h61-row-0-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('h61-pnl-0-0')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
