// test/unknown_board_test.dart — J-5 UNKNOWN 해소 보드 단위 테스트.
//
// 🔴 No Korean literals.
// 🔴 No self-injected-value tests.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository({required this.boardStreamFn});

  /// G7: callback so each call gets a fresh stream
  final Stream<UnknownBoardVm> Function() boardStreamFn;
  int callCount = 0;

  @override
  Stream<UnknownBoardVm> watchUnknownBoard() {
    callCount++;
    return boardStreamFn();
  }
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this.state);
  final SafetyState state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Future<_FakeJournalRepository> _pump(
  WidgetTester tester, {
  required Stream<UnknownBoardVm> Function() boardStreamFn,
  required SafetyState safety,
  required RecordingLinkOpener opener,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeJournalRepository repo = _FakeJournalRepository(
    boardStreamFn: boardStreamFn,
  );

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(), // R-5: fresh scope each pump
      overrides: <Override>[
        journalTimelineRepositoryProvider.overrideWithValue(repo),
        journalSafetyRepositoryProvider.overrideWithValue(
          _FakeSafetyRepository(safety),
        ),
        journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
        journalLinkOpenerProvider.overrideWithValue(opener),
      ],
      child: const MaterialApp(home: Scaffold(body: JournalUnknownBoard())),
    ),
  );
  await tester.pump();
  return repo;
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── Common states ───────────────────────────────────────────────────────────

  testWidgets('skeleton shown before first value', (WidgetTester tester) async {
    await _pump(
      tester,
      boardStreamFn: () => const Stream<UnknownBoardVm>.empty(),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byType(JournalSkeleton), findsOneWidget);
  });

  testWidgets('error → retry re-subscribes', (WidgetTester tester) async {
    final _FakeJournalRepository repo = await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.error(Exception('fail')),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    await tester.pump();
    expect(find.text(JournalLabels.retry), findsOneWidget);
    final int before = repo.callCount;
    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    expect(repo.callCount, greaterThan(before));
  });

  testWidgets('stale banner absent with fresh clock', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    // R-4: positive anchor — first card key always visible
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsOneWidget);
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('stale banner shown when clock advances 2 days', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(
            _FakeJournalRepository(
              boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
            ),
          ),
          journalSafetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyFixtureRow(0)),
          ),
          journalClockProvider.overrideWithValue(
            FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
          ),
          journalLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
        ],
        child: const MaterialApp(home: Scaffold(body: JournalUnknownBoard())),
      ),
    );
    await tester.pump();
    expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    expect(find.text(vm.asOf.label), findsWidgets);
  });

  testWidgets('safety row(3) → 2 blocking flags shown', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(3),
      opener: RecordingLinkOpener(),
    );
    final SafetyState halted = safetyFixtureRow(3);
    final List<BlockFlag> blocking = halted.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(blocking.length, 2);
    expect(find.text(blocking[0].label), findsOneWidget);
    expect(find.text(blocking[1].label), findsOneWidget);
  });

  // ── two_open: two cards ───────────────────────────────────────────────────────

  testWidgets('two_open: all display fields shown per card (G7)', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    // Both cards present
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('j5-card-1')), findsOneWidget);

    // G7: count-based field check per card (handles values that appear twice in a card)
    for (int i = 0; i < vm.items.length; i++) {
      final UnknownResolutionItem item = vm.items[i];
      final Key cardKey = ValueKey<String>('j5-card-$i');

      // Build list of all text values in this card
      final List<String> allTexts = <String>[
        item.entry.symbolLabel,
        item.entry.sideLabel,
        item.entry.quantityText,
        item.entry.statusLabel,
        item.elapsedText,
        item.effectLine,
        ...item.steps.map((UnknownResolutionStep s) => s.title),
        ...item.steps.map((UnknownResolutionStep s) => s.stateLabel),
        ...item.steps.map((UnknownResolutionStep s) => s.whyLine),
      ];

      for (final String t in allTexts) {
        // Count how many times t appears in this item's data
        int expected = 0;
        for (final String v in allTexts) {
          if (v == t) expected++;
        }
        expect(
          find.descendant(of: find.byKey(cardKey), matching: find.text(t)),
          findsNWidgets(expected),
          reason: 'card=$i text="$t"',
        );
      }
    }

    // nextBatchNoticeText
    expect(find.text(vm.nextBatchNoticeText!), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('two_open: cards in top-to-bottom order', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    final double y0 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('j5-card-0')))
        .dy;
    final double y1 = tester
        .getTopLeft(find.byKey(const ValueKey<String>('j5-card-1')))
        .dy;
    expect(y0, lessThan(y1));
  });

  testWidgets(
    'two_open: escalationLink button shown for emphasized card; tap opens exact link',
    (WidgetTester tester) async {
      final UnknownBoardVm vm = singleFixture(
        FixturePaths.m6UnknownBoard2,
        UnknownBoardVm.fromJson,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await _pump(
        tester,
        boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
        safety: safetyFixtureRow(0),
        opener: opener,
      );

      // Find which card has escalationLink
      final int idx = vm.items.indexWhere(
        (UnknownResolutionItem i) => i.escalationLink != null,
      );
      expect(idx, isNot(-1));
      final UnknownResolutionItem item = vm.items[idx];

      expect(find.text(item.escalationLink!.label), findsOneWidget);
      await tester.tap(find.text(item.escalationLink!.label));
      await tester.pump();
      expect(opener.opened, equals(<String>[item.escalationLink!.deepLink]));
    },
  );

  // ── G7: all cards: symbolLabel tap → opener.opened exact list ─────────────────

  testWidgets('two_open: all card symbolLabel taps open exact deepLinks', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    final List<String> expectedLinks = <String>[];
    for (int i = 0; i < vm.items.length; i++) {
      final UnknownResolutionItem item = vm.items[i];
      expect(item.entry.detailDeepLink, isNotNull);
      await tester.tap(
        find.descendant(
          of: find.byKey(ValueKey<String>('j5-card-$i')),
          matching: find.text(item.entry.symbolLabel),
        ),
      );
      await tester.pump();
      expectedLinks.add(item.entry.detailDeepLink!);
    }
    expect(opener.opened, equals(expectedLinks));
  });

  // ── G3: emphasized highlights ─────────────────────────────────────────────────

  testWidgets('G3: emphasized card has different shape than non-emphasized', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    // Find emphasized and non-emphasized indices
    final int emphIdx = vm.items.indexWhere(
      (UnknownResolutionItem i) => i.emphasized,
    );
    final int plainIdx = vm.items.indexWhere(
      (UnknownResolutionItem i) => !i.emphasized,
    );
    expect(emphIdx, isNot(-1), reason: 'fixture must have emphasized item');
    expect(
      plainIdx,
      isNot(-1),
      reason: 'fixture must have non-emphasized item',
    );

    final Card emphCard = tester.widget<Card>(
      find.descendant(
        of: find.byKey(ValueKey<String>('j5-card-$emphIdx')),
        matching: find.byType(Card),
      ),
    );
    final Card plainCard = tester.widget<Card>(
      find.descendant(
        of: find.byKey(ValueKey<String>('j5-card-$plainIdx')),
        matching: find.byType(Card),
      ),
    );
    // emphasized card should have a border (shape != plain shape)
    expect(emphCard.shape, isNot(equals(plainCard.shape)));
  });

  testWidgets('G3: emphasized=true + escalationLink=null → still highlighted', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm full = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    // Strip escalation link from emphasized item
    final int emphIdx = full.items.indexWhere(
      (UnknownResolutionItem i) => i.emphasized,
    );
    final UnknownBoardVm vm = full.copyWith(
      items: <UnknownResolutionItem>[
        full.items[emphIdx].copyWith(escalationLink: null),
        ...full.items.where((UnknownResolutionItem i) => !i.emphasized),
      ],
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    final Card emphCard = tester.widget<Card>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('j5-card-0')),
        matching: find.byType(Card),
      ),
    );
    final Card plainCard = tester.widget<Card>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('j5-card-1')),
        matching: find.byType(Card),
      ),
    );
    // Even with no escalationLink, emphasized card shape differs
    expect(emphCard.shape, isNot(equals(plainCard.shape)));
  });

  testWidgets(
    'G3: emphasized=false + escalationLink present → not highlighted',
    (WidgetTester tester) async {
      final UnknownBoardVm full = singleFixture(
        FixturePaths.m6UnknownBoard2,
        UnknownBoardVm.fromJson,
      );
      // R-4: preconditions — items[0] must be emphasized with a link
      expect(full.items[0].emphasized, isTrue, reason: 'fixture items[0] must be emphasized');
      expect(full.items[0].escalationLink, isNotNull, reason: 'fixture items[0] must have escalationLink');
      // Turn off emphasized but keep escalationLink
      final UnknownBoardVm vm = full.copyWith(
        items: <UnknownResolutionItem>[
          full.items[0].copyWith(emphasized: false),
          full.items[1],
        ],
      );
      await _pump(
        tester,
        boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
      );

      final Card card0 = tester.widget<Card>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('j5-card-0')),
          matching: find.byType(Card),
        ),
      );
      final Card card1 = tester.widget<Card>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('j5-card-1')),
          matching: find.byType(Card),
        ),
      );
      // Both non-emphasized → same shape
      expect(card0.shape, equals(card1.shape));
    },
  );

  testWidgets('two_open: card tap opens entry.detailDeepLink', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    final UnknownResolutionItem item = vm.items[0];
    expect(item.entry.detailDeepLink, isNotNull);

    // Tap symbolLabel inside card-0
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('j5-card-0')),
        matching: find.text(item.entry.symbolLabel),
      ),
    );
    await tester.pump();
    // R-4: exact match — not just contains
    expect(opener.opened, equals(<String>[item.entry.detailDeepLink!]));
  });

  // ── empty board ───────────────────────────────────────────────────────────────

  testWidgets('empty: emptyLabel shown, no card keys', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoardEmpty,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    expect(vm.emptyLabel, isNotNull);
    expect(find.text(vm.emptyLabel!), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── R-7: emptyLabel null → no text shown ─────────────────────────────────────

  testWidgets('R-7: emptyLabel null → no empty label text shown', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm base = singleFixture(
      FixturePaths.m6UnknownBoardEmpty,
      UnknownBoardVm.fromJson,
    );
    // R-7: emptyLabel null variant — no label text
    final UnknownBoardVm vm = base.copyWith(emptyLabel: null);
    await _pump(
      tester,
      boardStreamFn: () => Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(vm.emptyLabel, isNull);
    // No card-0 (empty board)
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsNothing);
    // No text that would match a null emptyLabel (was 'unwrap' accident)
    if (base.emptyLabel != null) {
      expect(find.text(base.emptyLabel!), findsNothing);
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
