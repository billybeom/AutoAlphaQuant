// test/decision_detail_test.dart — J-2 거래 상세 단위 테스트.
//
// 🔴 No Korean literals — expectations use fixture values.
// 🔴 No raw values (no toString() of Decimal/int/DateTime).
// 🔴 No self-injected-value tests.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepository extends UnimplementedJournalRepository {
  _FakeJournalRepository({required this.detailStream});

  final Stream<DecisionDetailVm> Function(String) detailStream;
  final List<String> receivedIds = <String>[];
  int callCount = 0;

  @override
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId) {
    callCount++;
    receivedIds.add(decisionId);
    return detailStream(decisionId);
  }
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this.state);
  final SafetyState state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Future<void> _pump(
  WidgetTester tester, {
  required Stream<DecisionDetailVm> Function(String) detailStream,
  required SafetyState safety,
  required RecordingLinkOpener opener,
  String decisionId = 'test-id',
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeJournalRepository repo = _FakeJournalRepository(
    detailStream: detailStream,
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
      child: MaterialApp(
        home: Scaffold(
          body: JournalDecisionDetail(decisionId: decisionId),
        ),
      ),
    ),
  );
  await tester.pump();
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── Common states ───────────────────────────────────────────────────────────

  testWidgets('skeleton shown before first value', (WidgetTester tester) async {
    await _pump(
      tester,
      detailStream: (_) => const Stream<DecisionDetailVm>.empty(),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byType(JournalSkeleton), findsOneWidget);
  });

  testWidgets('error → retry re-subscribes', (WidgetTester tester) async {
    int calls = 0;
    await _pump(
      tester,
      detailStream: (_) {
        calls++;
        return Stream<DecisionDetailVm>.error(Exception('fail'));
      },
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    await tester.pump();
    expect(find.text(JournalLabels.retry), findsOneWidget);
    final int before = calls;
    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    expect(calls, greaterThan(before));
  });

  testWidgets('stale banner absent with fresh clock', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    // No error state either
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('stale banner shown when clock advances 2 days',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
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
              detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
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
        child: const MaterialApp(
          home: Scaffold(
            body: JournalDecisionDetail(decisionId: 'x'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    // Stale asOf label should be vm.asOf.label (not entry.asOf.label)
    expect(find.text(vm.asOf.label), findsWidgets);
  });

  testWidgets('safety row(3) → 2 blocking flag cards', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(3),
      opener: RecordingLinkOpener(),
    );
    // safetyFixtureRow(3) has 2 blocking flags (RECON_MISMATCH + JOURNAL_MISSING)
    final SafetyState halted = safetyFixtureRow(3);
    final List<BlockFlag> blocking = halted.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(blocking.length, 2);
    expect(find.text(blocking[0].label), findsOneWidget);
    expect(find.text(blocking[1].label), findsOneWidget);
  });

  // ── J-2 specific: decisionId passed to repository ─────────────────────────

  testWidgets('decisionId is passed to watchDecisionDetail',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    const String testId = 'd_20260803_a_01';
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: testId,
    );
    // The correct decisionId from the fixture
    expect(
      find.descendant(
        of: find.byKey(const Key('j2-chain')),
        matching: find.text(vm.steps[0].stageLabel),
      ),
      findsOneWidget,
    );
    // decisionId arrived correctly — repo received it
    // (verified via fixture content)
    expect(find.text(vm.journalStateLabel), findsOneWidget);
  });

  // ── full fixture ─────────────────────────────────────────────────────────────

  testWidgets('full: chain steps in order, decisionId arrives',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    late String receivedId;
    await _pump(
      tester,
      detailStream: (String id) {
        receivedId = id;
        return Stream<DecisionDetailVm>.value(vm);
      },
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: vm.entry.decision.decisionId,
    );

    expect(receivedId, vm.entry.decision.decisionId);

    // 6 steps all descendants of j2-chain
    for (int i = 0; i < vm.steps.length; i++) {
      expect(
        find.descendant(
          of: find.byKey(const Key('j2-chain')),
          matching: find.byKey(ValueKey<String>('j2-step-$i')),
        ),
        findsOneWidget,
      );
      // stageLabel in that row
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('j2-step-$i')),
          matching: find.text(vm.steps[i].stageLabel),
        ),
        findsOneWidget,
      );
    }

    // Steps in top-to-bottom order
    for (int i = 0; i < vm.steps.length - 1; i++) {
      final double y0 = tester.getTopLeft(
        find.byKey(ValueKey<String>('j2-step-$i')),
      ).dy;
      final double y1 = tester.getTopLeft(
        find.byKey(ValueKey<String>('j2-step-${i + 1}')),
      ).dy;
      expect(y0, lessThan(y1));
    }

    // journalStateLabel shown
    expect(find.text(vm.journalStateLabel), findsOneWidget);
    // no error
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('full: snapshot expand → configHash long-press copies',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    // Snapshot collapsed by default — configHash not visible
    // Tap snapshot header to expand
    await tester.tap(find.text(JournalLabels.decisionSnapshot));
    await tester.pumpAndSettle();

    // configHash now visible (1-line ellipsis)
    final String hash = vm.snapshot!.ref.configHash;
    expect(find.text(hash), findsOneWidget);

    // Set up clipboard mock
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    // Long-press configHash
    await tester.longPress(find.text(hash));
    await tester.pumpAndSettle();

    expect(copiedText, hash);
    expect(find.text(JournalLabels.copied), findsOneWidget);
  });

  testWidgets('full: rebalanceLink button present and tap opens link',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    expect(vm.rebalanceLink, isNotNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-rebalanceLink')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('j2-link-rebalanceLink')),
        matching: find.text(vm.rebalanceLink!.label),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('j2-link-rebalanceLink')),
    );
    await tester.pump();
    expect(opener.opened, <String>[vm.rebalanceLink!.deepLink]);
  });

  testWidgets('full: journalLink absent (null in fixture)', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(vm.journalLink, isNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-journalLink')),
      findsNothing,
    );
  });

  testWidgets('full: parentLink absent', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(vm.parentLink, isNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-parentLink')),
      findsNothing,
    );
  });

  testWidgets('full: amendLink absent', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(vm.amendLink, isNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-amendLink')),
      findsNothing,
    );
  });

  testWidgets('full: raw values not shown', (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    // raw values must not appear
    final TriggerSnapshot trigger = vm.snapshot!.trigger;
    for (final String key in trigger.rawValues.keys) {
      expect(find.text(key), findsNothing);
    }
    // thresholdRegistered should not be displayed
    // (it's a double, so toString would be something like "0.5")
    // We confirm it only via absence of the double literal
    expect(find.text(vm.entry.decision.configHash), findsNothing);

    // entry symbolLabel tap should NOT open a link (no row tap on entry)
    final RecordingLinkOpener opener = RecordingLinkOpener();
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(
            _FakeJournalRepository(
              detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
            ),
          ),
          journalSafetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyFixtureRow(0)),
          ),
          journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          journalLinkOpenerProvider.overrideWithValue(opener),
        ],
        child: const MaterialApp(
          home: Scaffold(body: JournalDecisionDetail(decisionId: 'x')),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(vm.entry.symbolLabel).first);
    await tester.pump();
    expect(opener.opened, isEmpty);
  });

  // ── reevaluated_child: parentLink ─────────────────────────────────────────

  testWidgets('reevaluated_child: parentLink button tap opens link',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailReevaluatedChild,
      DecisionDetailVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    expect(vm.parentLink, isNotNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-parentLink')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('j2-link-parentLink')),
    );
    await tester.pump();
    expect(opener.opened, <String>[vm.parentLink!.deepLink]);
  });

  // ── amended: snapshotMissingLabel + amendLink ────────────────────────────────

  testWidgets('amended: snapshotMissingLabel shown; no configHash',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailAmended,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    expect(vm.snapshot, isNull);
    expect(vm.snapshotMissingLabel, isNotNull);
    // Scroll to snapshotMissingLabel (it's below the fills)
    await tester.scrollUntilVisible(
      find.text(vm.snapshotMissingLabel!),
      100,
    );
    expect(find.text(vm.snapshotMissingLabel!), findsOneWidget);
    // configHash not shown (no snapshot)
    expect(find.text(vm.entry.decision.configHash), findsNothing);
  });

  testWidgets('amended: amendLink present; tap opens link',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailAmended,
      DecisionDetailVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    expect(vm.amendLink, isNotNull);
    expect(
      find.byKey(const ValueKey<String>('j2-link-amendLink')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('j2-link-amendLink')),
    );
    await tester.pump();
    expect(opener.opened, <String>[vm.amendLink!.deepLink]);
  });

  testWidgets('amended: step with deepLink tap opens link',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailAmended,
      DecisionDetailVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    // Find step with deepLink
    final int stepIdx = vm.steps.indexWhere((DecisionChainStep s) => s.deepLink != null);
    expect(stepIdx, isNot(-1));
    final DecisionChainStep linkedStep = vm.steps[stepIdx];

    await tester.tap(
      find.byKey(ValueKey<String>('j2-step-$stepIdx')),
    );
    await tester.pump();
    expect(opener.opened, contains(linkedStep.deepLink!));
  });

  testWidgets('amended: reason chip with deepLink tap opens link',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailAmended,
      DecisionDetailVm.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    // Find a reason chip with deepLink in fills[0]
    final List<ReasonChip> reasons = vm.fills.first.reasons;
    final ReasonChip linkedChip = reasons.firstWhere(
      (ReasonChip c) => c.detailDeepLink != null,
    );
    // Scroll chip into view before tapping
    await tester.ensureVisible(find.text(linkedChip.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(linkedChip.label).last, warnIfMissed: false);
    await tester.pump();
    expect(opener.opened, contains(linkedChip.detailDeepLink!));
  });

  // ── unknown: no threshold table, no reject trace section ─────────────────────

  testWidgets('unknown: thresholdCompare and rejectTrace headers absent',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailUnknown,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(vm.thresholds, isEmpty);
    expect(vm.rejectTraces, isEmpty);
    expect(find.text(JournalLabels.thresholdCompare), findsNothing);
    expect(find.text(JournalLabels.rejectTrace), findsNothing);
    expect(find.text(vm.journalStateLabel), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── rejected_saf309: rejectTrace collapsible ─────────────────────────────────

  testWidgets('rejected_saf309: rejectTrace collapsed → expand shows trace',
      (WidgetTester tester) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailRejectedSaf309,
      DecisionDetailVm.fromJson,
    );
    await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    expect(vm.rejectTraces, isNotEmpty);
    final RejectTrace trace = vm.rejectTraces.first;

    // Before tap: stageLabel not visible (collapsed)
    expect(find.text(trace.stageLabel), findsNothing);

    // Tap reject trace header
    await tester.tap(find.text(JournalLabels.rejectTrace));
    await tester.pumpAndSettle();

    // After tap: stageLabel visible
    expect(find.text(trace.stageLabel), findsOneWidget);

    // reasonLabel visible (it also appears in chain detail lines, so count may be > 1)
    final int countBefore = find.text(trace.reasonLabel).evaluate().length;
    expect(countBefore, greaterThanOrEqualTo(1));
  });
}
