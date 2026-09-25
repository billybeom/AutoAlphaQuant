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

// G4: viewport height matches _kTallPhone (2400)
const double _kTestHeight = 2400;

Future<_FakeJournalRepository> _pump(
  WidgetTester tester, {
  required Stream<DecisionDetailVm> Function(String) detailStream,
  required SafetyState safety,
  required RecordingLinkOpener opener,
  String decisionId = 'test-id',
}) async {
  tester.view.physicalSize = const Size(390, _kTestHeight);
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
        home: Scaffold(body: JournalDecisionDetail(decisionId: decisionId)),
      ),
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

  testWidgets('stale banner absent with fresh clock', (
    WidgetTester tester,
  ) async {
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

  testWidgets('stale banner shown when clock advances 2 days', (
    WidgetTester tester,
  ) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    tester.view.physicalSize = const Size(390, _kTestHeight);
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
          home: Scaffold(body: JournalDecisionDetail(decisionId: 'x')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    // Stale asOf label should be vm.asOf.label (not entry.asOf.label)
    expect(find.text(vm.asOf.label), findsWidgets);
  });

  testWidgets('safety row(3) → 2 blocking flag cards', (
    WidgetTester tester,
  ) async {
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

  testWidgets('decisionId is passed to watchDecisionDetail', (
    WidgetTester tester,
  ) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    const String testId = 'd_20260803_a_01';
    final _FakeJournalRepository repo = await _pump(
      tester,
      detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: testId,
    );
    // Received decisionId matches what was passed
    expect(repo.receivedIds, equals(<String>[testId]));
    expect(find.text(vm.journalStateLabel), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── full fixture ─────────────────────────────────────────────────────────────

  testWidgets('full: chain steps in order, decisionId arrives', (
    WidgetTester tester,
  ) async {
    final DecisionDetailVm vm = singleFixture(
      FixturePaths.m6DecisionDetailFull,
      DecisionDetailVm.fromJson,
    );
    final _FakeJournalRepository repo = await _pump(
      tester,
      detailStream: (String id) => Stream<DecisionDetailVm>.value(vm),
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: vm.entry.decision.decisionId,
    );

    expect(repo.receivedIds, equals(<String>[vm.entry.decision.decisionId]));

    // 6 steps all descendants of j2-chain
    for (int i = 0; i < vm.steps.length; i++) {
      expect(
        find.descendant(
          of: find.byKey(const Key('j2-chain')),
          matching: find.byKey(ValueKey<String>('j2-step-$i')),
        ),
        findsOneWidget,
      );
      // stageLabel and stateLabel in that row
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('j2-step-$i')),
          matching: find.text(vm.steps[i].stageLabel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('j2-step-$i')),
          matching: find.text(vm.steps[i].stateLabel),
        ),
        findsOneWidget,
      );
    }

    // Steps in top-to-bottom order
    for (int i = 0; i < vm.steps.length - 1; i++) {
      final double y0 = tester
          .getTopLeft(find.byKey(ValueKey<String>('j2-step-$i')))
          .dy;
      final double y1 = tester
          .getTopLeft(find.byKey(ValueKey<String>('j2-step-${i + 1}')))
          .dy;
      expect(y0, lessThan(y1));
    }

    // journalStateLabel shown (at bottom — G4)
    expect(find.text(vm.journalStateLabel), findsOneWidget);
    // no error
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('full: snapshot expand → configHash long-press copies', (
    WidgetTester tester,
  ) async {
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

    // full: after expand, verify rawValues keys absent and thresholdRegistered absent
    // (snapshot must be expanded first — previously checked while collapsed = trivially passing)
    expect(vm.snapshot!.trigger.thresholdRegistered, isNotNull);
    final TriggerSnapshot trigger = vm.snapshot!.trigger;
    for (final String key in trigger.rawValues.keys) {
      expect(find.text(key), findsNothing);
    }
    expect(find.text(vm.entry.price.toString()), findsNothing);

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

  // ── full: link matrix ─────────────────────────────────────────────────────────

  testWidgets('full: rebalanceLink present, tap opens exact link', (
    WidgetTester tester,
  ) async {
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
    expect(opener.opened, equals(<String>[vm.rebalanceLink!.deepLink]));
  });

  testWidgets('full: journalLink absent (null in fixture)', (
    WidgetTester tester,
  ) async {
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

  // ── full: raw values not shown ────────────────────────────────────────────────

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

    // raw values must not appear (check after snapshot expanded)
    await tester.tap(find.text(JournalLabels.decisionSnapshot));
    await tester.pumpAndSettle();

    final TriggerSnapshot trigger = vm.snapshot!.trigger;
    for (final String key in trigger.rawValues.keys) {
      expect(find.text(key), findsNothing);
    }
    // entry price as raw string must not appear (only *Text fields allowed)
    expect(find.text(vm.entry.price.toString()), findsNothing);

    // entry symbolLabel tap should NOT open a link
    final RecordingLinkOpener opener = RecordingLinkOpener();
    tester.view.physicalSize = const Size(390, _kTestHeight);
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
    await tester.tap(
      find
          .descendant(
            of: find.byType(JournalEntryCard),
            matching: find.text(vm.entry.symbolLabel),
          )
          .first,
    );
    await tester.pump();
    expect(opener.opened, isEmpty);
  });

  // ── G7: 6-fixture loop ────────────────────────────────────────────────────────

  final List<(String, String)> allFixtures = <(String, String)>[
    (FixturePaths.m6DecisionDetailFull, 'full'),
    (FixturePaths.m6DecisionDetailPartial, 'partial'),
    (FixturePaths.m6DecisionDetailUnknown, 'unknown'),
    (FixturePaths.m6DecisionDetailRejectedSaf309, 'rejected_saf309'),
    (FixturePaths.m6DecisionDetailReevaluatedChild, 'reevaluated_child'),
    (FixturePaths.m6DecisionDetailAmended, 'amended'),
  ];

  testWidgets('G7: 6-fixture loop — chain steps, journalStateLabel, links', (
    WidgetTester tester,
  ) async {
    for (final (String path, String name) in allFixtures) {
      final DecisionDetailVm vm = singleFixture(
        path,
        DecisionDetailVm.fromJson,
      );

      final _FakeJournalRepository repo = await _pump(
        tester,
        detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        decisionId: vm.entry.decision.decisionId,
      );

      // decisionId arrived correctly — last call is the correct one
      expect(
        repo.receivedIds.last,
        equals(vm.entry.decision.decisionId),
        reason: 'fixture=$name',
      );

      // All steps are under j2-chain
      for (int i = 0; i < vm.steps.length; i++) {
        expect(
          find.descendant(
            of: find.byKey(const Key('j2-chain')),
            matching: find.byKey(ValueKey<String>('j2-step-$i')),
          ),
          findsOneWidget,
          reason: 'fixture=$name step=$i',
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('j2-step-$i')),
            matching: find.text(vm.steps[i].stageLabel),
          ),
          findsOneWidget,
          reason: 'fixture=$name step=$i stageLabel',
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey<String>('j2-step-$i')),
            matching: find.text(vm.steps[i].stateLabel),
          ),
          findsOneWidget,
          reason: 'fixture=$name step=$i stateLabel',
        );
      }

      // Steps dy order
      for (int i = 0; i < vm.steps.length - 1; i++) {
        final double y0 = tester
            .getTopLeft(find.byKey(ValueKey<String>('j2-step-$i')))
            .dy;
        final double y1 = tester
            .getTopLeft(find.byKey(ValueKey<String>('j2-step-${i + 1}')))
            .dy;
        expect(y0, lessThan(y1), reason: 'fixture=$name step $i < ${i + 1}');
      }

      // journalStateLabel
      expect(
        find.text(vm.journalStateLabel),
        findsOneWidget,
        reason: 'fixture=$name journalStateLabel',
      );
      expect(
        find.text(JournalLabels.retry),
        findsNothing,
        reason: 'fixture=$name no retry',
      );

      // Link matrix — 4 keys
      for (final (String fieldName, LinkAction? link)
          in <(String, LinkAction?)>[
            ('rebalanceLink', vm.rebalanceLink),
            ('parentLink', vm.parentLink),
            ('journalLink', vm.journalLink),
            ('amendLink', vm.amendLink),
          ]) {
        final Finder keyFinder = find.byKey(
          ValueKey<String>('j2-link-$fieldName'),
        );
        if (link != null) {
          expect(
            keyFinder,
            findsOneWidget,
            reason: 'fixture=$name $fieldName present',
          );
          expect(
            find.descendant(of: keyFinder, matching: find.text(link.label)),
            findsOneWidget,
            reason: 'fixture=$name $fieldName label',
          );
        } else {
          expect(
            keyFinder,
            findsNothing,
            reason: 'fixture=$name $fieldName absent',
          );
        }
      }
    }
  });

  // ── G7: partial: remainingText, passed false row ─────────────────────────────

  testWidgets(
    'partial: remainingText shown; threshold passed=false shows remove icon',
    (WidgetTester tester) async {
      final DecisionDetailVm vm = singleFixture(
        FixturePaths.m6DecisionDetailPartial,
        DecisionDetailVm.fromJson,
      );
      await _pump(
        tester,
        detailStream: (_) => Stream<DecisionDetailVm>.value(vm),
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
      );

      expect(vm.remainingText, isNotNull);
      await tester.scrollUntilVisible(find.text(vm.remainingText!).first, 100);
      expect(find.text(vm.remainingText!), findsAtLeastNWidgets(1));
      expect(find.text(JournalLabels.retry), findsNothing);

      // G2: passed=false row should show Icons.remove, not Icons.check
      final int falseIdx = vm.thresholds.indexWhere(
        (ThresholdCompare t) => !t.passed,
      );
      if (falseIdx >= 0) {
        final Finder rowFinder = find.byKey(
          ValueKey<String>('j2-thr-$falseIdx'),
        );
        // make sure it's built (use .first in case key matches multiple)
        await tester.scrollUntilVisible(rowFinder.first, 100);
        expect(
          find.descendant(of: rowFinder, matching: find.byIcon(Icons.check)),
          findsNothing,
          reason: 'passed=false row should not show check icon',
        );
        expect(
          find.descendant(of: rowFinder, matching: find.byIcon(Icons.remove)),
          findsOneWidget,
          reason: 'passed=false row should show remove icon',
        );
      }
    },
  );

  // ── G2: full fixture — passed=true rows have check icon ─────────────────────

  testWidgets('full: threshold passed=true rows show check icon', (
    WidgetTester tester,
  ) async {
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

    for (int i = 0; i < vm.thresholds.length; i++) {
      final Finder rowFinder = find.byKey(ValueKey<String>('j2-thr-$i'));
      await tester.scrollUntilVisible(rowFinder.first, 100);
      if (vm.thresholds[i].passed) {
        expect(
          find.descendant(of: rowFinder, matching: find.byIcon(Icons.check)),
          findsOneWidget,
          reason: 'thr-$i passed=true should show check',
        );
      } else {
        expect(
          find.descendant(of: rowFinder, matching: find.byIcon(Icons.remove)),
          findsOneWidget,
          reason: 'thr-$i passed=false should show remove',
        );
      }
    }
  });

  // ── reevaluated_child: parentLink ─────────────────────────────────────────

  testWidgets('reevaluated_child: parentLink button tap opens exact link', (
    WidgetTester tester,
  ) async {
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
    await tester.tap(find.byKey(const ValueKey<String>('j2-link-parentLink')));
    await tester.pump();
    expect(opener.opened, equals(<String>[vm.parentLink!.deepLink]));
  });

  // ── amended: snapshotMissingLabel + amendLink ────────────────────────────────

  testWidgets('amended: snapshotMissingLabel shown; no configHash', (
    WidgetTester tester,
  ) async {
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
    await tester.scrollUntilVisible(find.text(vm.snapshotMissingLabel!), 100);
    expect(find.text(vm.snapshotMissingLabel!), findsOneWidget);
    // configHash not shown (no snapshot)
    expect(find.text(vm.entry.decision.configHash), findsNothing);
  });

  testWidgets('amended: amendLink present; tap opens exact link', (
    WidgetTester tester,
  ) async {
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
    await tester.tap(find.byKey(const ValueKey<String>('j2-link-amendLink')));
    await tester.pump();
    expect(opener.opened, equals(<String>[vm.amendLink!.deepLink]));
  });

  testWidgets('amended: step with deepLink tap opens link', (
    WidgetTester tester,
  ) async {
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
    final int stepIdx = vm.steps.indexWhere(
      (DecisionChainStep s) => s.deepLink != null,
    );
    expect(stepIdx, isNot(-1));
    final DecisionChainStep linkedStep = vm.steps[stepIdx];

    await tester.tap(find.byKey(ValueKey<String>('j2-step-$stepIdx')));
    await tester.pump();
    expect(opener.opened, equals(<String>[linkedStep.deepLink!]));
  });

  testWidgets('amended: reason chip with deepLink tap opens link', (
    WidgetTester tester,
  ) async {
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
    await tester.ensureVisible(
      find
          .descendant(
            of: find.byType(ActionChip),
            matching: find.text(linkedChip.label),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(ActionChip),
            matching: find.text(linkedChip.label),
          )
          .first,
    );
    await tester.pump();
    expect(opener.opened, equals(<String>[linkedChip.detailDeepLink!]));
  });

  // ── unknown: no threshold table, no reject trace section ─────────────────────

  testWidgets('unknown: thresholdCompare and rejectTrace headers absent', (
    WidgetTester tester,
  ) async {
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

  // ── rejected_saf309: rejectTrace collapsible + reasonCode (G1) ──────────────

  testWidgets(
    'rejected_saf309: rejectTrace collapsed → expand shows trace + reasonCode',
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

      // G1: before tap — reasonCode count is n0 (may appear in detailLines)
      final int n0 = find.text(trace.reasonCode).evaluate().length;
      // Precondition: reasonCode already visible in chain detailLines (n0 >= 1)
      expect(n0, greaterThanOrEqualTo(1));

      // Before tap: stageLabel not visible (collapsed)
      expect(find.text(trace.stageLabel), findsNothing);

      // Tap reject trace header
      await tester.tap(find.text(JournalLabels.rejectTrace));
      await tester.pumpAndSettle();

      // After tap: stageLabel visible
      expect(find.text(trace.stageLabel), findsOneWidget);

      // G1: reasonCode count increased by 1 (now also in trace section)
      expect(find.text(trace.reasonCode).evaluate().length, equals(n0 + 1));
    },
  );
}
