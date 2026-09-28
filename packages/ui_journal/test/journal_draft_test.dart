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
  _FakeJournalRepo({
    required this.spec,
    this.journalStream,
  });

  final JournalDraftFormSpec? spec;
  final Stream<DecisionJournalVm> Function()? journalStream;
  int callCount = 0;
  final List<String> receivedIds = <String>[];

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) {
    callCount++;
    if (spec != null) return Future<JournalDraftFormSpec>.value(spec!);
    return Completer<JournalDraftFormSpec>().future; // skeleton forever
  }

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) {
    receivedIds.add(decisionId);
    if (journalStream != null) return journalStream!();
    return Stream<DecisionJournalVm>.value(
      singleFixture(FixturePaths.m6JournalReadWritten, DecisionJournalVm.fromJson),
    );
  }
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this.state);
  final SafetyState state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

/// G6: callbacks so each call gets a fresh Future/Stream (no shared instance).
class _FakeCommandApi extends UnimplementedCommandApi {
  _FakeCommandApi({required this.onSubmit, required this.onWatch});

  final Future<CommandReceipt> Function() onSubmit;
  final Stream<CommandReceipt> Function() onWatch;

  final List<JournalDraft> submitted = <JournalDraft>[];
  final List<String> watchedIds = <String>[];

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) {
    submitted.add(draft);
    return onSubmit();
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watchedIds.add(commandId);
    return onWatch();
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

Future<void> _pump(
  WidgetTester tester, {
  required JournalDraftFormSpec? spec,
  required SafetyState safety,
  required RecordingLinkOpener opener,
  _FakeCommandApi? commandApi,
  RecordingDraftStore? store,
  Stream<DecisionJournalVm> Function()? journal,
  Clock? clock,
  required String decisionId,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final List<Override> overrides = <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(
      _FakeJournalRepo(spec: spec, journalStream: journal),
    ),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safety),
    ),
    journalClockProvider.overrideWithValue(
      clock ?? FixedClock(kGoldenNowUtc),
    ),
    journalLinkOpenerProvider.overrideWithValue(opener),
    journalDraftStoreProvider.overrideWithValue(
      store ?? RecordingDraftStore(),
    ),
    if (commandApi != null)
      journalCommandApiProvider.overrideWithValue(commandApi),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: JournalDraftForm(decisionId: decisionId)),
      ),
    ),
  );
  await tester.pump();
  // 복원은 한 마이크로태스크 뒤 끝난다
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

// ── Helpers: fill form to ready state ─────────────────────────────────────────

Future<void> _fillToReady(
  WidgetTester tester,
  JournalDraftFormSpec spec,
) async {
  final int minChars = spec.rationaleMinChars;
  final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
    (ReasonOption o) => !o.requiresNote,
  );
  await tester.enterText(find.byType(TextField).first, 'a' * minChars);
  await tester.pump();
  await tester.enterText(find.byType(TextField).at(1), 'some outcome');
  await tester.pump();
  await tester.tap(find.byType(DropdownButton<ReasonOption>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(rule.label).last);
  await tester.pumpAndSettle();
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
      decisionId: 'test-id',
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
          journalDraftStoreProvider.overrideWithValue(RecordingDraftStore()),
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

  testWidgets('stale banner absent with fresh clock', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
    );
    expect(find.text(JournalLabels.staleBannerTitle), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('stale banner shown when clock advances 2 days', (
    WidgetTester tester,
  ) async {
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
          journalDraftStoreProvider.overrideWithValue(RecordingDraftStore()),
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
      decisionId: 'test-id',
    );
    await tester
        .pump(); // ensure both FutureProvider and StreamProvider resolve
    final SafetyState halted = safetyFixtureRow(3);
    final List<BlockFlag> blocking = halted.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(blocking.length, 2);
    expect(find.text(blocking[0].label), findsOneWidget);
    expect(find.text(blocking[1].label), findsOneWidget);
  });

  // ── discretion: pledge block ────────────────────────────────────────────────

  testWidgets('discretion: pledge block present with all lines', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    expect(
      spec.pledgeLines,
      isNotEmpty,
      reason: 'discretion fixture must have pledgeLines',
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
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

  testWidgets('recon_clear: pledge block absent when pledgeLines empty', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecReconClear,
      JournalDraftFormSpec.fromJson,
    );
    expect(
      spec.pledgeLines,
      isEmpty,
      reason: 'recon_clear fixture must have empty pledgeLines',
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
    );
    expect(find.byKey(const Key('j3-pledge-block')), findsNothing);
  });

  // ── G5: trim test ───────────────────────────────────────────────────────────

  testWidgets('G5: whitespace-only rationale does not activate submit', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final int minChars = spec.rationaleMinChars;
    final ReasonOption noNoteRule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
    );

    // Fill expected outcome and select rule
    await tester.enterText(find.byType(TextField).at(1), 'some outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(noNoteRule.label).last);
    await tester.pumpAndSettle();

    FilledButton submitBtn() =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    // Spaces equal to min → still disabled (trim())
    await tester.enterText(find.byType(TextField).first, ' ' * minChars);
    await tester.pump();
    expect(submitBtn().onPressed, isNull);

    // Spaces + one char below min → disabled
    await tester.enterText(
      find.byType(TextField).first,
      'a' * (minChars - 1) + ' ',
    );
    await tester.pump();
    expect(submitBtn().onPressed, isNull);

    // Exactly min non-space chars → active
    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    expect(submitBtn().onPressed, isNotNull);
  });

  // ── G5: double-submit prevention ───────────────────────────────────────────

  testWidgets('G5: button disabled during submit, double-tap → 1 submission', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);

    // onSubmit never resolves (Completer)
    final Completer<CommandReceipt> completer = Completer<CommandReceipt>();
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => completer.future,
      onWatch: () => const Stream<CommandReceipt>.empty(),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      decisionId: 'test-id',
    );

    await _fillToReady(tester, spec);

    // First tap — submit starts (button not yet resolved)
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // Button must be disabled (onPressed == null) while awaiting
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    // TextFields must be disabled too
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.enabled, isFalse);
    }

    // Second tap on disabled button → still just 1 submission
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(api.submitted.length, 1);

    // Cleanup
    completer.complete(requested);
    await tester.pumpAndSettle();
  });

  // ── Submit button activation ────────────────────────────────────────────────

  testWidgets('submit inactive → active as inputs filled', (
    WidgetTester tester,
  ) async {
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
      decisionId: 'test-id',
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
    final ReasonOption noNoteRule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(noNoteRule.label).last);
    await tester.pumpAndSettle();
    expect(submitBtn().onPressed, isNotNull); // now active

    // Now select rule that requires note → disabled again
    final ReasonOption noteRule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => o.requiresNote,
    );
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

  testWidgets('submit → REQUESTED: lock fields, show stateLabel', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    // watchCommand returns empty stream (no further updates)
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => const Stream<CommandReceipt>.empty(),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      decisionId: spec.decisionId,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'some outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();

    // G7: verify 3 TextFields exist before tapping (loop guard)
    expect(find.byType(TextField), findsNWidgets(3));

    // Tap submit
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // 1 submission recorded
    expect(api.submitted.length, 1);
    expect(api.submitted.first.decisionId, spec.decisionId);
    // G7: recorded draft fields
    expect(api.submitted.first.rationaleBefore, 'a' * minChars);
    expect(api.submitted.first.expectedOutcome, 'some outcome');
    expect(api.submitted.first.ruleCited, rule.code);
    expect(api.submitted.first.note, isNull); // empty note → null
    expect(api.watchedIds.first, requested.commandId);

    // REQUESTED state: fields locked
    expect(find.text(requested.stateLabel), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.enabled, isFalse);
    }
    // G7: dropdown locked
    expect(
      tester
          .widget<DropdownButton<ReasonOption>>(
            find.byType(DropdownButton<ReasonOption>),
          )
          .onChanged,
      isNull,
    );
    // Submit button absent (locked state has no submit)
    expect(find.byType(FilledButton), findsNothing);

    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── G7: HELD_FOR_INTEGRITY locked ──────────────────────────────────────────

  testWidgets('HELD_FOR_INTEGRITY: fields locked, no submit button', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt held = _receiptIn(CommandState.heldForIntegrity);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => Stream<CommandReceipt>.value(held),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      decisionId: spec.decisionId,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rule.label).last);
    await tester.pumpAndSettle();

    // G7: verify 3 TextFields before submitting
    expect(find.byType(TextField), findsNWidgets(3));

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Locked: fields disabled
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.enabled, isFalse);
    }
    // G7: dropdown locked
    expect(
      tester
          .widget<DropdownButton<ReasonOption>>(
            find.byType(DropdownButton<ReasonOption>),
          )
          .onChanged,
      isNull,
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text(held.stateLabel), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── Submit → EXECUTED: input area gone ──────────────────────────────────────

  testWidgets('submit → EXECUTED: input area gone, stateLabel shown', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt executed = _receiptIn(CommandState.executed);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => Stream<CommandReceipt>.value(executed),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      decisionId: spec.decisionId,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );

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

    // EXECUTED: noticeLine visible (G7)
    expect(find.text(spec.noticeLine), findsOneWidget);

    // EXECUTED: no input widgets
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(DropdownButton<ReasonOption>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    // stateLabel visible
    expect(find.text(executed.stateLabel), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── G7: EXECUTED: discretion pledge·deviation·contextChips·pledge order ────

  testWidgets(
    'EXECUTED: discretion — noticeLine·deviation·contextChips shown',
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
        decisionId: 'test-id',
      );

      expect(find.text(spec.noticeLine), findsOneWidget);
      expect(find.text(spec.deviation.label), findsOneWidget);

      for (final ReasonChip chip in spec.contextChips) {
        expect(find.text(chip.label), findsWidgets);
      }

      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── G7: pledge lines in order ───────────────────────────────────────────────

  testWidgets('discretion: pledge lines in top-to-bottom order', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    expect(spec.pledgeLines.length, greaterThan(1));

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
    );

    double prevDy = double.negativeInfinity;
    for (final String line in spec.pledgeLines) {
      final double dy = tester
          .getBottomLeft(
            find.descendant(
              of: find.byKey(const Key('j3-pledge-block')),
              matching: find.text(line),
            ),
          )
          .dy;
      expect(dy, greaterThan(prevDy));
      prevDy = dy;
    }
  });

  // ── G7: safety row(3): blocking[0] and blocking[1] both shown ──────────────

  testWidgets('safety row(3): blocking[0] and blocking[1] both shown', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(3),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
    );
    await tester.pump();
    final SafetyState halted = safetyFixtureRow(3);
    final List<BlockFlag> blocking = halted.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    expect(blocking.length, 2);
    expect(find.text(blocking[0].label), findsOneWidget);
    expect(find.text(blocking[1].label), findsOneWidget);
  });

  // ── Submit → REJECTED and EXPIRED: re-editable ──────────────────────────────

  testWidgets(
    'submit → REJECTED and EXPIRED: inputs preserved, re-submit possible',
    (WidgetTester tester) async {
      for (final CommandState finalState in <CommandState>[
        CommandState.rejected,
        CommandState.expired,
      ]) {
        final JournalDraftFormSpec spec = singleFixture(
          FixturePaths.m6JournalDraftSpecDiscretion,
          JournalDraftFormSpec.fromJson,
        );
        final CommandReceipt requested = _receiptIn(CommandState.requested);
        final CommandReceipt finalReceipt = _receiptIn(finalState);

        // G6: callbacks, not shared instances
        final _FakeCommandApi api = _FakeCommandApi(
          onSubmit: () => Future<CommandReceipt>.value(requested),
          onWatch: () => Stream<CommandReceipt>.value(finalReceipt),
        );

        await _pump(
          tester,
          spec: spec,
          safety: safetyFixtureRow(0),
          opener: RecordingLinkOpener(),
          commandApi: api,
          decisionId: spec.decisionId,
        );

        final int minChars = spec.rationaleMinChars;
        final String rationaleText = 'a' * minChars;
        final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
          (ReasonOption o) => !o.requiresNote,
        );

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

        // Inputs preserved
        final TextField rationale = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        expect(rationale.controller!.text, rationaleText);

        // G6+G7: watchedIds length 2 (first submit + second submit each add one)
        // After first submit, api.watchedIds.length == 1
        expect(api.watchedIds.length, 1);

        // rejectReasonCode handling
        final CommandReceipt r = finalReceipt;
        // Precondition: REJECTED has rejectReasonCode, EXPIRED does not
        expect(
          r.rejectReasonCode,
          finalState == CommandState.rejected ? isNotNull : isNull,
        );
        // rejectReasonCode must NOT appear in UI (even for REJECTED)
        if (finalState == CommandState.rejected) {
          expect(find.text(r.rejectReasonCode!), findsNothing);
        }

        // Re-submit works (second submission)
        expect(find.byType(FilledButton), findsOneWidget);
        // G7: rationaleBefore input preserved
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          rationaleText,
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(api.submitted.length, 2);

        // G6: watchedIds.length == 2 after second submit
        expect(api.watchedIds.length, 2);

        // After second submit → REJECTED/EXPIRED again: re-editable
        expect(find.byType(FilledButton), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          rationaleText,
        );
      }
    },
  );

  // ── G6: submitJournalDraft Future.error ─────────────────────────────────────

  testWidgets(
    'G6: submitJournalDraft Future.error → inputs kept, retry active',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final Exception err = Exception('submit failed');
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.error(err),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        decisionId: spec.decisionId,
      );

      final int minChars = spec.rationaleMinChars;
      final String rationaleText = 'a' * minChars;
      final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
        (ReasonOption o) => !o.requiresNote,
      );

      await tester.enterText(find.byType(TextField).first, rationaleText);
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), 'my outcome');
      await tester.pump();
      await tester.tap(find.byType(DropdownButton<ReasonOption>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(rule.label).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Input preserved
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        rationaleText,
      );
      // Submit button active again
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      // Error was reported (tester.takeException picks up FlutterError)
      expect(tester.takeException(), isNotNull);
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── G6: re-submit Future.error (01 §11-10 🆕 2행) ───────────────────────────

  testWidgets(
    'G6: re-submit Future.error → previous receipt kept, watchedIds unchanged',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      final CommandReceipt rejected = _receiptIn(CommandState.rejected);

      int submitCount = 0;
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () {
          submitCount++;
          if (submitCount == 1) {
            return Future<CommandReceipt>.value(requested);
          }
          return Future<CommandReceipt>.error(Exception('re-submit failed'));
        },
        onWatch: () => Stream<CommandReceipt>.value(rejected),
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        decisionId: spec.decisionId,
      );

      final int minChars = spec.rationaleMinChars;
      final String rationaleText = 'a' * minChars;
      final ReasonOption rule = spec.ruleCitedOptions.firstWhere(
        (ReasonOption o) => !o.requiresNote,
      );

      await tester.enterText(find.byType(TextField).first, rationaleText);
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), 'my outcome');
      await tester.pump();
      await tester.tap(find.byType(DropdownButton<ReasonOption>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(rule.label).last);
      await tester.pumpAndSettle();

      // First submit → REJECTED
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text(rejected.stateLabel), findsOneWidget);
      expect(api.watchedIds.length, 1);

      // Second submit → Future.error
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Previous receipt stateLabel still shown (낙관 갱신 없음)
      expect(find.text(rejected.stateLabel), findsOneWidget);
      // watchedIds still 1 (no new subscribe)
      expect(api.watchedIds.length, 1);
      expect(api.submitted.length, 2);
      // Input preserved
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        rationaleText,
      );
      // Submit button active
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      // Error reported
      expect(tester.takeException(), isNotNull);
    },
  );

  // ── G6: watchCommand Stream.error ───────────────────────────────────────────

  testWidgets(
    'G6: watchCommand Stream.error → REQUESTED kept, error reported',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(requested),
        onWatch: () => Stream<CommandReceipt>.error(Exception('watch error')),
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // REQUESTED stateLabel still shown
      expect(find.text(requested.stateLabel), findsOneWidget);
      // Still locked (no FilledButton)
      expect(find.byType(FilledButton), findsNothing);
      // Error reported
      expect(tester.takeException(), isNotNull);
    },
  );

  // ── contextChip tap opens deepLink ───────────────────────────────────────────

  testWidgets('context chip tap opens detailDeepLink', (
    WidgetTester tester,
  ) async {
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
      decisionId: 'test-id',
    );

    final ReasonChip chip = spec.contextChips.firstWhere(
      (ReasonChip c) => c.detailDeepLink != null,
    );
    await tester.tap(find.text(chip.label));
    await tester.pump();
    expect(opener.opened, contains(chip.detailDeepLink!));
  });

  // ── dropdown options visible ─────────────────────────────────────────────────

  testWidgets('dropdown tap shows all ruleCitedOptions labels', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      decisionId: 'test-id',
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
