// holdings_allocation_test.dart — H6-3 HoldingsAllocation widget tests (T63-01~T63-14).
// No Korean string literals. All test names ASCII.
// imports: directives_ordering — as verified by analyze.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_allocation_fakes.dart';
import 'holdings_overview_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

void main() {
  late SleeveAllocationVm inBand;
  late SleeveAllocationVm outOfBand;
  late SleeveAllocationVm tranche;
  late SleeveAllocationVm parking;
  late SleeveAllocationVm allocInteg;
  late SleeveAllocationVm allocRecon;
  late SleeveAllocationVm allocEmpty;
  late NextRebalanceVm countdown;
  late NextRebalanceVm none;

  setUpAll(() {
    inBand = singleFixture(
      FixturePaths.m6AllocationInBand,
      SleeveAllocationVm.fromJson,
    );
    outOfBand = singleFixture(
      FixturePaths.m6AllocationOutOfBand,
      SleeveAllocationVm.fromJson,
    );
    tranche = singleFixture(
      FixturePaths.m6AllocationTrancheProgress,
      SleeveAllocationVm.fromJson,
    );
    parking = singleFixture(
      FixturePaths.m6AllocationParkingLarge,
      SleeveAllocationVm.fromJson,
    );
    allocInteg = singleFixture(
      FixturePaths.m6AllocationIntegrity,
      SleeveAllocationVm.fromJson,
    );
    allocRecon = singleFixture(
      FixturePaths.m6AllocationRecon,
      SleeveAllocationVm.fromJson,
    );
    allocEmpty = singleFixture(
      FixturePaths.m6AllocationEmpty,
      SleeveAllocationVm.fromJson,
    );
    countdown = singleFixture(
      FixturePaths.m7M7NextRebalanceCountdown,
      NextRebalanceVm.fromJson,
    );
    none = singleFixture(
      FixturePaths.m7M7NextRebalanceNone,
      NextRebalanceVm.fromJson,
    );
  });

  // T63-01: entry, row order, indentation, bar presence
  testWidgets('T63-01 entry row order indentation bar',
      (WidgetTester tester) async {
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
      ),
    );

    expect(holdings.calls, 1);
    expect(rebalance.calls, 1);

    expect(
      holdingsShownTexts(tester, const Key('h63-asof')),
      <String>[inBand.asOf.label],
    );
    expect(inBand.noticeText, isNotNull);
    expect(
      tester.widget<Text>(find.byKey(const Key('h63-notice'))).data,
      inBand.noticeText,
    );

    expect(inBand.rows, hasLength(5));
    for (final (int i, SleeveAllocationRow r) in inBand.rows.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h63-row-$i')),
        allocationRowTexts(r),
      );

      if (r.sleeveWeight != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h63-weight-$i')))
              .data,
          r.sleeveWeight!.label,
        );
      } else {
        expect(
          find.byKey(ValueKey<String>('h63-weight-$i')),
          findsNothing,
        );
      }

      if (r.bandNoteText != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h63-band-note-$i')))
              .data,
          r.bandNoteText,
        );
      } else {
        expect(
          find.byKey(ValueKey<String>('h63-band-note-$i')),
          findsNothing,
        );
      }

      if (r.bandStateLabel != null) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('h63-state-$i')))
              .data,
          r.bandStateLabel,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h63-state-$i')), findsNothing);
      }

      if (r.gauge != null) {
        expect(
          find.byKey(ValueKey<String>('h63-gauge-$i')),
          findsOneWidget,
        );
      } else {
        expect(find.byKey(ValueKey<String>('h63-gauge-$i')), findsNothing);
      }

      if (r.deployedRatio != null) {
        expect(find.byKey(ValueKey<String>('h63-bar-$i')), findsOneWidget);
      } else {
        expect(find.byKey(ValueKey<String>('h63-bar-$i')), findsNothing);
      }

      if (r.engineColumnNote != null) {
        expect(
          find.byKey(ValueKey<String>('h63-note-toggle-$i')),
          findsOneWidget,
        );
      } else {
        expect(
          find.byKey(ValueKey<String>('h63-note-toggle-$i')),
          findsNothing,
        );
      }

      expect(find.byKey(ValueKey<String>('h63-note-$i')), findsNothing);
    }

    // indentation
    expect(inBand.rows[0].parentSleeve, isNull);
    final double baseDx =
        tester.getTopLeft(find.byKey(const ValueKey<String>('h63-label-0'))).dx;
    for (final (int i, SleeveAllocationRow r) in inBand.rows.indexed.skip(1)) {
      final double dx =
          tester.getTopLeft(find.byKey(ValueKey<String>('h63-label-$i'))).dx;
      if (r.parentSleeve != null) {
        expect(dx, greaterThan(baseDx), reason: 'row $i should be indented');
      } else {
        expect(dx, equals(baseDx), reason: 'row $i should not be indented');
      }
    }

    // chain dy
    for (int i = 0; i < 4; i++) {
      final double dy0 =
          tester.getTopLeft(find.byKey(ValueKey<String>('h63-row-$i'))).dy;
      final double dy1 =
          tester.getTopLeft(find.byKey(ValueKey<String>('h63-row-${i + 1}'))).dy;
      expect(dy0, lessThan(dy1));
    }
    final double dyLast =
        tester.getTopLeft(find.byKey(const ValueKey<String>('h63-row-4'))).dy;
    final double dyNext =
        tester.getTopLeft(find.byKey(const Key('h63-next'))).dy;
    expect(dyLast, lessThan(dyNext));

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-02: band state color 3 values
  final List<(String, SleeveBandState)> t63Cases02 =
      <(String, SleeveBandState)>[
    ('in_band', SleeveBandState.inBand),
    ('out_of_band', SleeveBandState.outOfBand),
    ('tranche_progress', SleeveBandState.nearEdge),
  ];

  for (final (
    String caseName,
    SleeveBandState want,
  ) in t63Cases02) {
    testWidgets('T63-02 band state color $caseName', (WidgetTester tester) async {
      // rows are lazily initialized in setUpAll; access them here
      final SleeveAllocationVm fixtureVm;
      if (caseName == 'in_band') {
        fixtureVm = inBand;
      } else if (caseName == 'out_of_band') {
        fixtureVm = outOfBand;
      } else {
        fixtureVm = tranche;
      }

      final FakeAllocationRepository holdings = FakeAllocationRepository(
        allocation: (_) => Stream<SleeveAllocationVm>.value(fixtureVm),
      );
      final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
        next: (_) => Stream<NextRebalanceVm>.value(countdown),
      );
      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
        ),
      );

      final SleeveAllocationRow b = fixtureVm.rows[2];
      expect(b.bandState, want, reason: caseName);

      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey<String>('h63-state-2')))
            .data,
        b.bandStateLabel,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey<String>('h63-weight-2')))
            .data,
        b.sleeveWeight!.label,
      );

      final ColorScheme cs =
          Theme.of(tester.element(find.byKey(const ValueKey<String>('h63-row-2')))).colorScheme;
      final Color wantColor = switch (want) {
        SleeveBandState.inBand => cs.primary,
        SleeveBandState.nearEdge => cs.tertiary,
        SleeveBandState.outOfBand => cs.error,
      };

      final Icon stateIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('h63-row-2')),
          matching: find.byIcon(Icons.circle),
        ),
      );
      expect(stateIcon.color, wantColor, reason: caseName);
      expect(find.byKey(const ValueKey<String>('h63-gauge-2')), findsOneWidget);

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T63-03: seasonal pending chip
  testWidgets('T63-03 seasonal pending chip', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(tranche),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
        opener: opener,
      ),
    );

    final SleeveAllocationRow a = tranche.rows[0];
    expect(a.stateChips, hasLength(1));

    for (final ReasonChip chip in a.stateChips) {
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('h63-row-0')),
          matching: find.text(chip.label),
        ),
        findsOneWidget,
      );
    }

    expect(a.stateChips[0].detailDeepLink, isNotNull);
    await tester.ensureVisible(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h63-row-0')),
        matching: find.byType(ActionChip),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h63-row-0')),
        matching: find.byType(ActionChip),
      ),
    );
    await tester.pump();
    expect(opener.opened, <String>[a.stateChips[0].detailDeepLink!]);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-04: large parking = not warning color
  testWidgets('T63-04 large parking not warning color',
      (WidgetTester tester) async {
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(parking),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
      ),
    );

    final SleeveAllocationRow b = parking.rows[2];
    expect(b.bandState, SleeveBandState.inBand);

    final ColorScheme cs =
        Theme.of(tester.element(find.byKey(const ValueKey<String>('h63-row-2')))).colorScheme;
    final Icon stateIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h63-row-2')),
        matching: find.byIcon(Icons.circle),
      ),
    );
    expect(stateIcon.color, cs.primary);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h63-row-2')),
        matching: find.text(b.parkingNoteText!),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('h63-row-2')),
        matching: find.byIcon(Icons.warning_amber_rounded),
      ),
      findsNothing,
    );

    expect(find.byKey(const ValueKey<String>('h63-bar-2')), findsOneWidget);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-05: INTEGRITY = geometry absent, masked text
  testWidgets('T63-05 INTEGRITY geometry absent masked text',
      (WidgetTester tester) async {
    final SafetyState safety = safetyFixtureRow(4);
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(allocInteg),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
        safety: safety,
      ),
    );

    for (final BlockFlag f in safety.activeFlags) {
      expect(find.text(f.label), findsOneWidget);
    }

    expect(allocInteg.rows, hasLength(5));
    for (final (int i, SleeveAllocationRow r) in allocInteg.rows.indexed) {
      expect(r.gauge, isNull);
      expect(r.deployedRatio, isNull);

      expect(find.byKey(ValueKey<String>('h63-gauge-$i')), findsNothing);
      expect(find.byKey(ValueKey<String>('h63-bar-$i')), findsNothing);
      expect(find.byKey(ValueKey<String>('h63-weight-$i')), findsNothing);
      expect(find.byKey(ValueKey<String>('h63-state-$i')), findsNothing);

      expect(
        holdingsShownTexts(tester, ValueKey<String>('h63-row-$i')),
        allocationRowTexts(r),
      );
    }

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-06: RECON = geometry kept, text only
  testWidgets('T63-06 RECON geometry kept text only',
      (WidgetTester tester) async {
    final SafetyState safety = safetyFixtureRow(3);
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(allocRecon),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
        safety: safety,
      ),
    );

    expect(allocRecon.rows, hasLength(5));
    for (final (int i, SleeveAllocationRow r) in allocRecon.rows.indexed) {
      expect(
        holdingsShownTexts(tester, ValueKey<String>('h63-row-$i')),
        allocationRowTexts(r),
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('h63-row-$i')),
          matching: find.byIcon(Icons.warning_amber_rounded),
        ),
        findsNothing,
      );
    }

    final SleeveAllocationRow b = allocRecon.rows[2];
    expect(find.byKey(const ValueKey<String>('h63-gauge-2')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('h63-bar-2')), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h63-state-2')))
          .data,
      b.bandStateLabel,
    );

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-07: engine column note expand
  testWidgets('T63-07 engine column note expand', (WidgetTester tester) async {
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
      ),
    );

    expect(inBand.rows[0].engineColumnNote, isNotNull);

    await openAllocationNote(tester, 0);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('h63-note-0')))
          .data,
      inBand.rows[0].engineColumnNote,
    );

    expect(find.byKey(const ValueKey<String>('h63-row-1')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('h63-note-1')), findsNothing);

    await openAllocationNote(tester, 0);
    expect(find.byKey(const ValueKey<String>('h63-note-0')), findsNothing);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-08: empty state
  testWidgets('T63-08 empty state', (WidgetTester tester) async {
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(allocEmpty),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
      ),
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('h63-empty'))).data,
      allocEmpty.emptyLabel,
    );
    expect(find.byKey(const ValueKey<String>('h63-row-0')), findsNothing);
    expect(allocEmpty.noticeText, isNull);
    expect(find.byKey(const Key('h63-notice')), findsNothing);
    expect(find.byKey(const Key('h63-asof')), findsOneWidget);
    expect(find.byKey(const Key('h63-next')), findsOneWidget);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // T63-09: next rebalance two branches
  final List<(String, bool)> t63Cases09 = <(String, bool)>[
    ('countdown', true),
    ('none', false),
  ];

  for (final (String caseName, bool wantRoute) in t63Cases09) {
    testWidgets('T63-09 next rebalance $caseName', (WidgetTester tester) async {
      final NextRebalanceVm nextVm;
      if (caseName == 'countdown') {
        nextVm = countdown;
      } else {
        nextVm = none;
      }

      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeAllocationRepository holdings = FakeAllocationRepository(
        allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
      );
      final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
        next: (_) => Stream<NextRebalanceVm>.value(nextVm),
      );
      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
          opener: opener,
        ),
      );

      expect(
        holdingsShownTexts(tester, const Key('h63-next')),
        nextRebalanceTexts(nextVm),
      );

      if (wantRoute) {
        expect(nextVm.previewRoute, isNotNull);
      } else {
        expect(nextVm.previewRoute, isNull);
      }

      await tester.ensureVisible(find.byKey(const Key('h63-next')));
      await tester.tap(find.byKey(const Key('h63-next')));
      await tester.pump();

      if (wantRoute) {
        expect(opener.opened, <String>[nextVm.previewRoute!]);
      } else {
        expect(opener.opened, <String>[]);
      }

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T63-10: all Text in allowed set
  final List<(String, Future<void> Function(WidgetTester))> t63Cases10 =
      <(String, Future<void> Function(WidgetTester))>[
    ('closed', (_) async {}),
    (
      'note_open',
      (WidgetTester t) async {
        await openAllocationNote(t, 0);
        await openAllocationNote(t, 1);
      },
    ),
  ];

  for (final (String caseName, Future<void> Function(WidgetTester) steps)
      in t63Cases10) {
    testWidgets('T63-10 all screen texts in allowed set $caseName',
        (WidgetTester tester) async {
      final FakeAllocationRepository holdings = FakeAllocationRepository(
        allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
      );
      final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
        next: (_) => Stream<NextRebalanceVm>.value(countdown),
      );
      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
        ),
      );

      await steps(tester);

      final Set<String> allowedSet = allocationAllowed(inBand, countdown);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowedSet));
      }

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T63-11: branch x banner
  final List<(
    String,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
  )> t63Cases11 = <(
    String,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
  )>[
    // (name, wantSkeleton, wantError, wantHead, wantBanner, wantStale, wantEmpty, wantRow, wantNext)
    ('alloc_loading', true, false, false, false, false, false, false, false),
    ('alloc_fail', false, true, false, false, false, false, false, false),
    ('alloc_empty', false, false, true, true, false, true, false, true),
    ('normal', false, false, true, true, false, false, true, true),
    ('normal_stale', false, false, true, true, true, false, true, true),
    ('integrity', false, false, true, true, false, false, true, true),
    ('next_loading', false, false, true, true, false, false, true, false),
    ('next_fail', false, false, true, true, false, false, true, false),
    ('empty_next_loading', false, false, true, true, false, true, false, false),
    ('empty_next_fail', false, false, true, true, false, true, false, false),
  ];

  for (final (
    String caseName,
    bool wantSkeleton,
    bool wantError,
    bool wantHead,
    bool wantBanner,
    bool wantStale,
    bool wantEmpty,
    bool wantRow,
    bool wantNext,
  ) in t63Cases11) {
    testWidgets('T63-11 branch x banner $caseName', (WidgetTester tester) async {
      final SafetyState safety = safetyFixtureRow(3);
      final DateTime staleNow = kGoldenNowUtc.add(const Duration(days: 2));

      final FakeAllocationRepository holdings;
      final FakeNextRebalanceRepository rebalance;

      if (caseName == 'alloc_loading') {
        final StreamController<SleeveAllocationVm> ctrl =
            StreamController<SleeveAllocationVm>();
        addTearDown(() { unawaited(ctrl.close()); });
        holdings = FakeAllocationRepository(
          allocation: (_) => ctrl.stream,
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'alloc_fail') {
        holdings = FakeAllocationRepository(
          allocation: (_) =>
              Stream<SleeveAllocationVm>.error(StateError('fail')),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'alloc_empty') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(allocEmpty),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'normal') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'normal_stale') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'integrity') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(allocInteg),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.value(countdown),
        );
      } else if (caseName == 'next_loading') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
        );
        final StreamController<NextRebalanceVm> ctrl =
            StreamController<NextRebalanceVm>();
        addTearDown(() { unawaited(ctrl.close()); });
        rebalance = FakeNextRebalanceRepository(next: (_) => ctrl.stream);
      } else if (caseName == 'next_fail') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.error(StateError('fail')),
        );
      } else if (caseName == 'empty_next_loading') {
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(allocEmpty),
        );
        final StreamController<NextRebalanceVm> ctrl =
            StreamController<NextRebalanceVm>();
        addTearDown(() { unawaited(ctrl.close()); });
        rebalance = FakeNextRebalanceRepository(next: (_) => ctrl.stream);
      } else {
        // empty_next_fail
        holdings = FakeAllocationRepository(
          allocation: (_) => Stream<SleeveAllocationVm>.value(allocEmpty),
        );
        rebalance = FakeNextRebalanceRepository(
          next: (_) => Stream<NextRebalanceVm>.error(StateError('fail')),
        );
      }

      final Clock clock = caseName == 'normal_stale'
          ? FixedClock(staleNow)
          : FixedClock(kGoldenNowUtc);

      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
          safety: safety,
          clock: clock,
        ),
      );

      expect(
        find.byKey(const Key('h63-loading')),
        wantSkeleton ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h63-fail')),
        wantError ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h63-asof')),
        wantHead ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.text(JournalLabels.staleBannerTitle),
        wantStale ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h63-next')),
        wantNext ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const ValueKey<String>('h63-row-0')),
        wantRow ? findsOneWidget : findsNothing,
        reason: caseName,
      );
      expect(
        find.text(JournalLabels.retry),
        wantError ? findsOneWidget : findsNothing,
        reason: caseName,
      );

      // empty label check
      final String? emptyLabelWant = wantEmpty ? allocEmpty.emptyLabel : null;
      if (emptyLabelWant != null) {
        expect(allocEmpty.emptyLabel, isNotNull);
        expect(
          tester.widget<Text>(find.byKey(const Key('h63-empty'))).data,
          emptyLabelWant,
          reason: caseName,
        );
      } else {
        expect(find.byKey(const Key('h63-empty')), findsNothing, reason: caseName);
      }

      // banner flags
      final bool bannerCases = wantBanner;
      for (final BlockFlag f in safety.activeFlags) {
        expect(
          find.text(f.label),
          bannerCases ? findsOneWidget : findsNothing,
          reason: '$caseName flag ${f.label}',
        );
      }

      expect(find.byType(CircularProgressIndicator), findsNothing, reason: caseName);
      expect(find.byType(LinearProgressIndicator), findsNothing, reason: caseName);
    });
  }

  // T63-12: error and retry
  final List<(
    String,
    FakeAllocationRepository Function(),
    String? Function(),
  )> t63Cases12 = <(
    String,
    FakeAllocationRepository Function(),
    String? Function(),
  )>[
    (
      'alloc_fail',
      () {
        int holdingsCalls = 0;
        return FakeAllocationRepository(
          allocation: (_) {
            holdingsCalls++;
            if (holdingsCalls == 1) {
              return Stream<SleeveAllocationVm>.error(StateError('fail'));
            }
            return Stream<SleeveAllocationVm>.value(inBand);
          },
        );
      },
      () => null,
    ),
    (
      'value_then_fail',
      () => FakeAllocationRepository(
        allocation: (int call) {
          if (call == 0) {
            return valueThenFail(inBand);
          }
          return Stream<SleeveAllocationVm>.value(inBand);
        },
      ),
      () => inBand.asOf.label,
    ),
  ];

  for (final (
    String caseName,
    FakeAllocationRepository Function() holdingsFactory,
    String? Function() wantLastAsOfFn,
  ) in t63Cases12) {
    testWidgets('T63-12 error and retry $caseName',
        (WidgetTester tester) async {
      final SafetyState safety = safetyFixtureRow(3);
      final FakeAllocationRepository holdings = holdingsFactory();
      final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
        next: (_) => Stream<NextRebalanceVm>.value(countdown),
      );
      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
          safety: safety,
        ),
      );

      expect(
        find.byKey(const Key('h63-fail')),
        findsOneWidget,
        reason: caseName,
      );
      final JournalErrorView errorView =
          tester.widget<JournalErrorView>(find.byKey(const Key('h63-fail')));
      expect(errorView.lastAsOfLabel, wantLastAsOfFn(), reason: caseName);
      for (final BlockFlag f in safety.activeFlags) {
        expect(find.text(f.label), findsNothing, reason: caseName);
      }
      expect(
        find.byKey(const Key('h63-next')),
        findsNothing,
        reason: caseName,
      );

      await tester.ensureVisible(find.text(JournalLabels.retry));
      await tester.tap(find.text(JournalLabels.retry));
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const Key('h63-fail')),
        findsNothing,
        reason: caseName,
      );
      expect(
        find.byKey(const Key('h63-asof')),
        findsOneWidget,
        reason: caseName,
      );
      expect(holdings.calls, 2, reason: caseName);

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T63-13: large font
  final List<(
    String,
    SleeveAllocationVm Function(),
    Future<void> Function(WidgetTester),
  )> t63Cases13 = <(
    String,
    SleeveAllocationVm Function(),
    Future<void> Function(WidgetTester),
  )>[
    (
      'in_band',
      () => inBand,
      (WidgetTester t) async { await openAllocationNote(t, 0); },
    ),
    ('out_of_band', () => outOfBand, (_) async {}),
  ];

  for (final (
    String caseName,
    SleeveAllocationVm Function() vmFn,
    Future<void> Function(WidgetTester) steps,
  ) in t63Cases13) {
    testWidgets('T63-13 large font $caseName', (WidgetTester tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final FakeAllocationRepository holdings = FakeAllocationRepository(
        allocation: (_) => Stream<SleeveAllocationVm>.value(vmFn()),
      );
      final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
        next: (_) => Stream<NextRebalanceVm>.value(countdown),
      );
      await pumpHoldingsAllocation(
        tester,
        overrides: holdingsAllocationOverrides(
          holdings: holdings,
          rebalance: rebalance,
        ),
      );
      await steps(tester);

      expect(tester.takeException(), isNull, reason: caseName);
      expect(
        find.byKey(const Key('h63-asof')),
        findsOneWidget,
        reason: caseName,
      );

      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // T63-14: bar segment ratio x width
  testWidgets('T63-14 bar segment ratio x width', (WidgetTester tester) async {
    final FakeAllocationRepository holdings = FakeAllocationRepository(
      allocation: (_) => Stream<SleeveAllocationVm>.value(inBand),
    );
    final FakeNextRebalanceRepository rebalance = FakeNextRebalanceRepository(
      next: (_) => Stream<NextRebalanceVm>.value(countdown),
    );
    await pumpHoldingsAllocation(
      tester,
      overrides: holdingsAllocationOverrides(
        holdings: holdings,
        rebalance: rebalance,
      ),
    );

    final SleeveAllocationRow b = inBand.rows[2];
    expect(b.deployedRatio, isNotNull);
    expect(b.parkingRatio, isNotNull);

    final double full = tester
        .getSize(find.byKey(const ValueKey<String>('h63-bar-2')))
        .width;
    final Finder segs = find.descendant(
      of: find.byKey(const ValueKey<String>('h63-bar-2')),
      matching: find.byType(ColoredBox),
    );
    expect(segs, findsNWidgets(2));

    expect(
      tester.getSize(segs.at(0)).width,
      closeTo(full * b.deployedRatio!, 0.5),
    );
    expect(
      tester.getSize(segs.at(1)).width,
      closeTo(full * b.parkingRatio!, 0.5),
    );
    expect(tester.getSize(segs.at(0)).height, greaterThan(0));

    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
