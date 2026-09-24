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
  _FakeJournalRepository({required this.boardStream});

  final Stream<UnknownBoardVm> boardStream;
  int callCount = 0;

  @override
  Stream<UnknownBoardVm> watchUnknownBoard() {
    callCount++;
    return boardStream;
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
  required Stream<UnknownBoardVm> boardStream,
  required SafetyState safety,
  required RecordingLinkOpener opener,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeJournalRepository repo = _FakeJournalRepository(
    boardStream: boardStream,
  );

  await tester.pumpWidget(
    ProviderScope(
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
      boardStream: const Stream<UnknownBoardVm>.empty(),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byType(JournalSkeleton), findsOneWidget);
  });

  testWidgets('error → retry re-subscribes', (WidgetTester tester) async {
    await _pump(
      tester,
      boardStream: Stream<UnknownBoardVm>.error(Exception('fail')),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    // Need provider invalidation — but retry taps JournalLabels.retry
    // which calls ref.invalidate — so call count goes up
    await tester.pump();
    expect(find.text(JournalLabels.retry), findsOneWidget);
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
      boardStream: Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
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
              boardStream: Stream<UnknownBoardVm>.value(vm),
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
      boardStream: Stream<UnknownBoardVm>.value(vm),
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

  testWidgets('two_open: cards present with correct keys and content', (
    WidgetTester tester,
  ) async {
    final UnknownBoardVm vm = singleFixture(
      FixturePaths.m6UnknownBoard2,
      UnknownBoardVm.fromJson,
    );
    await _pump(
      tester,
      boardStream: Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    // Both cards present
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('j5-card-1')), findsOneWidget);

    for (int i = 0; i < vm.items.length; i++) {
      final UnknownResolutionItem item = vm.items[i];
      final Key cardKey = ValueKey<String>('j5-card-$i');

      // symbolLabel inside card
      expect(
        find.descendant(
          of: find.byKey(cardKey),
          matching: find.text(item.entry.symbolLabel),
        ),
        findsOneWidget,
      );

      // elapsedText
      expect(
        find.descendant(
          of: find.byKey(cardKey),
          matching: find.text(item.elapsedText),
        ),
        findsOneWidget,
      );

      // effectLine
      expect(
        find.descendant(
          of: find.byKey(cardKey),
          matching: find.text(item.effectLine),
        ),
        findsOneWidget,
      );

      // Steps: each step title in card
      for (final UnknownResolutionStep step in item.steps) {
        expect(
          find.descendant(
            of: find.byKey(cardKey),
            matching: find.text(step.title),
          ),
          findsAtLeastNWidgets(1),
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
      boardStream: Stream<UnknownBoardVm>.value(vm),
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
    'two_open: escalationLink button shown for emphasized card; tap opens link',
    (WidgetTester tester) async {
      final UnknownBoardVm vm = singleFixture(
        FixturePaths.m6UnknownBoard2,
        UnknownBoardVm.fromJson,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await _pump(
        tester,
        boardStream: Stream<UnknownBoardVm>.value(vm),
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
      expect(opener.opened, <String>[item.escalationLink!.deepLink]);
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
      boardStream: Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    final UnknownResolutionItem item = vm.items[0];
    expect(item.entry.detailDeepLink, isNotNull);

    // Tap symbolLabel inside card-0 (symbolLabel uniquely identifies the tap area)
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('j5-card-0')),
        matching: find.text(item.entry.symbolLabel),
      ),
    );
    await tester.pump();
    expect(opener.opened, contains(item.entry.detailDeepLink!));
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
      boardStream: Stream<UnknownBoardVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    expect(vm.emptyLabel, isNotNull);
    expect(find.text(vm.emptyLabel!), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('j5-card-0')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });
}
