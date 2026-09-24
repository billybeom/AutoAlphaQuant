// test/journal_draft_test.dart — J-3 사전 저널 폼 단위 테스트.
//
// 🔴 No Korean literals.
// 🔴 No self-injected-value tests.
// 🔴 Fake CommandApi: submitJournalDraft + watchCommand only.

import 'dart:async';
import 'dart:math';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/src/journal_draft/journal_draft_form.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo({required this.spec});
  final JournalDraftFormSpec? spec;
  int callCount = 0;

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) {
    callCount++;
    if (spec != null) return Future<JournalDraftFormSpec>.value(spec!);
    return Completer<JournalDraftFormSpec>().future; // skeleton forever
  }
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this.state);
  final SafetyState state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

class _FakeCommandApi extends UnimplementedCommandApi {
  _FakeCommandApi({
    required this.submitResponse,
    required this.watchResponse,
  });

  final CommandReceipt submitResponse;
  final Stream<CommandReceipt> watchResponse;

  final List<JournalDraft> submitted = <JournalDraft>[];
  final List<String> watchedIds = <String>[];

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) {
    submitted.add(draft);
    return Future<CommandReceipt>.value(submitResponse);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watchedIds.add(commandId);
    return watchResponse;
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Future<void> _pump(
  WidgetTester tester, {
  required JournalDraftFormSpec? spec,
  required SafetyState safety,
  required RecordingLinkOpener opener,
  _FakeCommandApi? commandApi,
  String decisionId = 'test-id',
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final List<Override> overrides = <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(
      _FakeJournalRepo(spec: spec),
    ),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safety),
    ),
    journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
    journalLinkOpenerProvider.overrideWithValue(opener),
    if (commandApi != null)
      journalCommandApiProvider.overrideWithValue(commandApi),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: JournalDraftForm(decisionId: decisionId),
        ),
      ),
    ),
  );
  await tester.pump();
}

// ── Receipts from fixture ──────────────────────────────────────────────────────

CommandReceipt _receiptIn(CommandState state) {
  final List<CommandReceipt> receipts = listFixture(
    FixturePaths.m6JournalDraftReceipts5,
    CommandReceipt.fromJson,
  ).rows;
  return receipts.firstWhere((CommandReceipt r) => r.state == state);
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── Common states ───────────────────────────────────────────────────────────

  testWidgets('skeleton shown while spec loading', (WidgetTester tester) async {
    await _pump(
      tester,
      spec: null, // completer → forever loading
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byType(JournalSkeleton), findsOneWidget);
  });

  testWidgets('error → retry re-fetches spec', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Override to throw
    final _FakeThrowingRepo throwing = _FakeThrowingRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(throwing),
          journalSafetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyFixtureRow(0)),
          ),
          journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          journalLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: JournalDraftForm(decisionId: 'x')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text(JournalLabels.retry), findsOneWidget);
    final int callsBefore = throwing.calls;
    await tester.tap(find.text(JournalLabels.retry));
    await tester.pump();
    expect(throwing.calls, greaterThan(callsBefore));
  });

  testWidgets('stale banner absent with fresh clock', (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('stale banner shown when clock advances 2 days',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(
            _FakeJournalRepo(spec: spec),
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
          home: Scaffold(body: JournalDraftForm(decisionId: 'x')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    // asOf label is spec.asOf.label
    expect(find.text(spec.asOf.label), findsWidgets);
  });

  testWidgets('safety row(3) → 2 blocking flags', (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(3),
      opener: RecordingLinkOpener(),
    );
    await tester.pump(); // ensure both FutureProvider and StreamProvider resolve
    final SafetyState halted = safetyFixtureRow(3);
    final List<BlockFlag> blocking = halted.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(blocking.length, 2);
    expect(find.text(blocking[0].label), findsOneWidget);
  });

  // ── discretion: pledge block ────────────────────────────────────────────────

  testWidgets('discretion: pledge block present with all lines',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    expect(spec.pledgeLines, isNotEmpty,
        reason: 'discretion fixture must have pledgeLines');
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byKey(const Key('j3-pledge-block')), findsOneWidget);
    for (final String line in spec.pledgeLines) {
      expect(
        find.descendant(
          of: find.byKey(const Key('j3-pledge-block')),
          matching: find.text(line),
        ),
        findsOneWidget,
      );
    }
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── recon_clear: no pledge block ───────────────────────────────────────────

  testWidgets('recon_clear: pledge block absent when pledgeLines empty',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecReconClear,
      JournalDraftFormSpec.fromJson,
    );
    expect(spec.pledgeLines, isEmpty,
        reason: 'recon_clear fixture must have empty pledgeLines');
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    expect(find.byKey(const Key('j3-pledge-block')), findsNothing);
  });

  // ── Submit button activation ────────────────────────────────────────────────

  testWidgets('submit inactive → active as inputs filled',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final int minChars = spec.rationaleMinChars;

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );

    FilledButton submitBtn() =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    // Initially disabled
    expect(submitBtn().onPressed, isNull);

    // Fill rationale below min → still disabled
    await tester.enterText(
      find.byType(TextField).first,
      'a' * max(0, minChars - 1),
    );
    await tester.pump();
    expect(submitBtn().onPressed, isNull);

    // Fill rationale to min
    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    expect(submitBtn().onPressed, isNull); // expected still null

    // Fill expected outcome
    await tester.enterText(find.byType(TextField).at(1), 'good outcome');
    await tester.pump();
    expect(submitBtn().onPressed, isNull); // still no rule

    // Select rule that does NOT require note
    final ReasonOption noNoteRule = spec.ruleCitedOptions
        .firstWhere((ReasonOption o) => !o.requiresNote);
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(noNoteRule.label).last);
    await tester.pumpAndSettle();
    expect(submitBtn().onPressed, isNotNull); // now active

    // Now select rule that requires note → disabled again
    final ReasonOption noteRule = spec.ruleCitedOptions
        .firstWhere((ReasonOption o) => o.requiresNote);
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(noteRule.label).last);
    await tester.pumpAndSettle();
    expect(submitBtn().onPressed, isNull);

    // Fill note → active again
    await tester.enterText(find.byType(TextField).at(2), 'my note');
    await tester.pump();
    expect(submitBtn().onPressed, isNotNull);
  });

  // ── Submit → REQUESTED (locked) ─────────────────────────────────────────────

  testWidgets('submit → REQUESTED: lock fields, show stateLabel',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    // watchCommand returns empty stream (no further updates)
    final _FakeCommandApi api = _FakeCommandApi(
      submitResponse: requested,
      watchResponse: const Stream<CommandReceipt>.empty(),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule =
        spec.ruleCitedOptions.firstWhere((ReasonOption o) => !o.requiresNote);

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'some outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // 1 submission recorded
    expect(api.submitted.length, 1);
    expect(api.submitted.first.decisionId, spec.decisionId);
    expect(api.submitted.first.ruleCited, rule.code);
    expect(api.submitted.first.note, isNull); // empty note → null
    expect(api.watchedIds.first, requested.commandId);

    // REQUESTED state: fields locked
    expect(find.text(requested.stateLabel), findsOneWidget);
    for (final TextField field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    // Submit button absent (locked state has no submit)
    expect(find.byType(FilledButton), findsNothing);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── Submit → EXECUTED: input area gone ──────────────────────────────────────

  testWidgets('submit → EXECUTED: input area gone, stateLabel shown',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt executed = _receiptIn(CommandState.executed);
    final _FakeCommandApi api = _FakeCommandApi(
      submitResponse: requested,
      watchResponse: Stream<CommandReceipt>.value(executed),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule =
        spec.ruleCitedOptions.firstWhere((ReasonOption o) => !o.requiresNote);

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // EXECUTED: no input widgets
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(DropdownButton<ReasonOption>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    // stateLabel visible
    expect(find.text(executed.stateLabel), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── Submit → REJECTED: re-editable ──────────────────────────────────────────

  testWidgets('submit → REJECTED: inputs preserved, re-submit possible',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt rejected = _receiptIn(CommandState.rejected);
    final _FakeCommandApi api = _FakeCommandApi(
      submitResponse: requested,
      watchResponse: Stream<CommandReceipt>.value(rejected),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
    );

    final int minChars = spec.rationaleMinChars;
    final String rationaleText = 'a' * minChars;
    final ReasonOption rule =
        spec.ruleCitedOptions.firstWhere((ReasonOption o) => !o.requiresNote);

    await tester.enterText(find.byType(TextField).first, rationaleText);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'expected');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // REJECTED: inputs preserved
    final TextField rationale = tester.widget<TextField>(find.byType(TextField).first);
    expect(rationale.controller!.text, rationaleText);

    // rejectReasonCode must NOT appear in UI
    expect(find.text(rejected.rejectReasonCode ?? ''), findsNothing);

    // Re-submit works (second submission)
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(api.submitted.length, 2);
  });

  // ── HELD_FOR_INTEGRITY: locked ───────────────────────────────────────────────

  testWidgets('HELD_FOR_INTEGRITY: fields locked, no submit button',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt held = _receiptIn(CommandState.heldForIntegrity);
    final _FakeCommandApi api = _FakeCommandApi(
      submitResponse: requested,
      watchResponse: Stream<CommandReceipt>.value(held),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule =
        spec.ruleCitedOptions.firstWhere((ReasonOption o) => !o.requiresNote);

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Locked: fields disabled
    for (final TextField field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text(held.stateLabel), findsOneWidget);
  });

  // ── contextChip tap opens deepLink ───────────────────────────────────────────

  testWidgets('context chip tap opens detailDeepLink', (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: opener,
    );

    final ReasonChip chip = spec.contextChips.firstWhere(
      (ReasonChip c) => c.detailDeepLink != null,
    );
    await tester.tap(find.text(chip.label));
    await tester.pump();
    expect(opener.opened, contains(chip.detailDeepLink!));
  });

  // ── dropdown options visible ─────────────────────────────────────────────────

  testWidgets('dropdown tap shows all ruleCitedOptions labels',
      (WidgetTester tester) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
    );
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    for (final ReasonOption o in spec.ruleCitedOptions) {
      expect(find.text(o.label), findsWidgets);
    }
  });
}

// Helper class for error test
class _FakeThrowingRepo extends UnimplementedJournalRepository {
  int calls = 0;
  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) {
    calls++;
    throw Exception('fail');
  }
}
