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
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/src/journal_draft/journal_draft_form.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo({required this.spec, this.journalStream});

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
      singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      ),
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

Future<_FakeJournalRepo> _pump(
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

  final _FakeJournalRepo repo = _FakeJournalRepo(
    spec: spec,
    journalStream: journal,
  );
  final List<Override> overrides = <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(repo),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safety),
    ),
    journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
    journalLinkOpenerProvider.overrideWithValue(opener),
    journalDraftStoreProvider.overrideWithValue(store ?? RecordingDraftStore()),
    if (commandApi != null)
      journalCommandApiProvider.overrideWithValue(commandApi),
  ];

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(), // R-5: fresh scope each pump
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: JournalDraftForm(decisionId: decisionId)),
      ),
    ),
  );
  await tester.pump();
  // 복원은 한 마이크로태스크 뒤 끝난다
  await tester.pump();
  return repo;
}

/// S-10 (T8): the two text inputs keep what [_fillToReady] typed and report
/// the expected enabled state.
void _expectFilledInputs(
  WidgetTester tester,
  JournalDraftFormSpec spec, {
  required bool enabled,
}) {
  final TextField rationale = tester.widget<TextField>(
    find.byType(TextField).first,
  );
  final TextField expected = tester.widget<TextField>(
    find.byType(TextField).at(1),
  );
  expect(rationale.controller!.text, 'a' * spec.rationaleMinChars);
  expect(expected.controller!.text, 'some outcome');
  expect(rationale.enabled, enabled);
  expect(expected.enabled, enabled);
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
    // R-4: positive anchor — noticeLine always visible
    expect(find.text(spec.noticeLine), findsOneWidget);
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
    // R-4: positive anchor — noticeLine always visible
    expect(find.text(spec.noticeLine), findsOneWidget);
    expect(find.byKey(const Key('j3-pledge-block')), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
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

  // ── R-7: safety row(3) — blocking flags shown but submit still active ────────

  testWidgets(
    'R-7: safety row(3) — blocking flags shown, submit active when form ready',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(3),
        opener: RecordingLinkOpener(),
        decisionId: spec.decisionId,
      );
      await tester.pump();

      // Precondition: blocking flags visible
      final SafetyState halted = safetyFixtureRow(3);
      final List<BlockFlag> blocking = halted.activeFlags
          .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
          .toList();
      expect(blocking.length, 2);
      expect(find.text(blocking[0].label), findsOneWidget);

      // Fill form to ready state — submit must be active despite blocking flags
      await _fillToReady(tester, spec);
      // R-7: submit button present and enabled (FlagIds never disable submit)
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    },
  );

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
    // R-4: exact match — not just contains
    expect(opener.opened, equals(<String>[chip.detailDeepLink!]));
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
  // ── T1: 행 0 복원 — 사전 근거만, 규칙 미선택 ──────────────────────────────────

  testWidgets('T1: row 0 restore → rationale text, no rule, submit inactive', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row0 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[0];
    final DraftKey key = DraftKey(
      kind: DraftKind.journalDraft,
      targetId: spec.decisionId,
    );
    expect(row0.key.targetId, spec.decisionId);
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row0],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    // 복원 전제
    expect(store.loaded, equals(<DraftKey>[key]));
    // 세 입력란 text = 행 0 원문
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      row0.journal!.rationaleBefore,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      row0.journal!.expectedOutcome,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      row0.journal!.note,
    );
    // 규칙 미선택 (row0.journal!.ruleCited == null)
    expect(
      tester
          .widget<DropdownButton<ReasonOption>>(
            find.byType(DropdownButton<ReasonOption>),
          )
          .value,
      isNull,
    );
    // 제출 비활성
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T2: 행 1 복원 — 규칙 있음, 드롭다운 value, 제출 활성 ─────────────────────

  testWidgets('T2: row 1 restore → rule dropdown value, submit active', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row1 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[1];
    expect(row1.key.targetId, spec.decisionId);
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row1],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    // 드롭다운 value.code == 행 1 의 journal!.ruleCited
    final DropdownButton<ReasonOption> dd = tester.widget(
      find.byType(DropdownButton<ReasonOption>),
    );
    expect(dd.value?.code, row1.journal!.ruleCited);
    // 그 선택지 label 보임
    expect(find.text(dd.value!.label), findsWidgets);
    // 제출 활성
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T3: 화면층 재시작 생존 ────────────────────────────────────────────────────

  testWidgets('T3: layer restart survival — values and rule restored', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final RecordingDraftStore store = RecordingDraftStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    final int minChars = spec.rationaleMinChars;
    final ReasonOption noNoteRule = spec.ruleCitedOptions.firstWhere(
      (ReasonOption o) => !o.requiresNote,
    );

    await tester.enterText(find.byType(TextField).first, 'a' * minChars);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'outcome');
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<ReasonOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(noNoteRule.label).last);
    await tester.pumpAndSettle();

    // 위젯 트리를 내렸다가 같은 store 로 새 ProviderScope 로 다시 띄운다
    // (실물 영속 증명 아님 — 06 M4-9)
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          journalTimelineRepositoryProvider.overrideWithValue(
            _FakeJournalRepo(spec: spec),
          ),
          journalSafetyRepositoryProvider.overrideWithValue(
            _FakeSafetyRepository(safetyFixtureRow(0)),
          ),
          journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
          journalLinkOpenerProvider.overrideWithValue(RecordingLinkOpener()),
          journalDraftStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(
          home: Scaffold(body: JournalDraftForm(decisionId: spec.decisionId)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // 값·규칙 복원
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'a' * minChars,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      'outcome',
    );
    expect(
      tester
          .widget<DropdownButton<ReasonOption>>(
            find.byType(DropdownButton<ReasonOption>),
          )
          .value
          ?.code,
      noNoteRule.code,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4: 입력마다 저장 — trim 없는 원문 ──────────────────────────────────────

  testWidgets('T4: save on input — raw text preserved, key correct', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final RecordingDraftStore store = RecordingDraftStore();
    final DraftKey key = DraftKey(
      kind: DraftKind.journalDraft,
      targetId: spec.decisionId,
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    // 앞뒤 공백을 넣은 ASCII 입력
    const String rawText = '  ab  ';
    await tester.enterText(find.byType(TextField).first, rawText);
    await tester.pump();

    // saved.last.journal!.rationaleBefore == 친 원문 그대로(trim 없음)
    expect(store.saved, isNotEmpty);
    expect(store.saved.last.journal!.rationaleBefore, rawText);
    // saved 의 key 전부 == key
    for (final DraftRecord r in store.saved) {
      expect(r.key, key);
    }
    // 제출 전 saved.last.lastCommandId == null
    expect(store.saved.last.lastCommandId, isNull);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T5: 행 1 복원만 → saved 비어 있음 ────────────────────────────────────────

  testWidgets('T5: row 1 seed only → saved empty (no-op on same value)', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row1 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[1];
    expect(row1.key.targetId, spec.decisionId);
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row1],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    // 복원만 했고 입력이 없으므로 saved 비어 있음
    expect(store.saved, isEmpty);
    // 입력란을 탭(포커스)만 해도 비어 있음(같은 값 저장 생략)
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(store.saved, isEmpty);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T6: 제출 성공(REQUESTED) → lastCommandId 저장 + watchedIds ──────────────

  testWidgets(
    'T6: submit REQUESTED → lastCommandId saved, watchedIds correct',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(requested),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      final DraftKey key = DraftKey(
        kind: DraftKind.journalDraft,
        targetId: spec.decisionId,
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // saved.last.lastCommandId == 돌려준 commandId
      expect(store.saved, isNotEmpty);
      expect(store.saved.last.lastCommandId, requested.commandId);
      // api.watchedIds == <String>[그 commandId]
      expect(api.watchedIds, equals(<String>[requested.commandId]));
      // key 일치
      expect(store.saved.last.key, key);
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── T7: EXECUTED → cleared, JournalReadContent 보임 ─────────────────────────

  testWidgets('T7: EXECUTED → store cleared, JournalReadContent shown', (
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
    final RecordingDraftStore store = RecordingDraftStore();
    final DraftKey key = DraftKey(
      kind: DraftKind.journalDraft,
      targetId: spec.decisionId,
    );

    final _FakeJournalRepo repo = await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    await _fillToReady(tester, spec);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // cleared == <DraftKey>[key]
    expect(store.cleared, equals(<DraftKey>[key]));
    // TextField 0
    expect(find.byType(TextField), findsNothing);
    // JournalReadContent 1
    expect(find.byType(JournalReadContent), findsOneWidget);
    // spec.noticeLine 1
    expect(find.text(spec.noticeLine), findsOneWidget);
    // S-8: the embedded read view received the spec decisionId
    expect(repo.receivedIds, <String>[spec.decisionId]);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T8: rejected·expired·heldForIntegrity — cleared 비어 있음 ──────────────

  testWidgets('T8-rejected: cleared empty, input preserved, submit active', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt rejected = _receiptIn(CommandState.rejected);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => Stream<CommandReceipt>.value(rejected),
    );
    final RecordingDraftStore store = RecordingDraftStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    await _fillToReady(tester, spec);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(store.cleared, isEmpty);
    // 제출 버튼 활성 (재제출)
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(find.text(JournalLabels.draftSubmit), findsOneWidget);
    // S-10: typed input kept and editable
    _expectFilledInputs(tester, spec, enabled: true);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T8-expired: cleared empty, submit active', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final CommandReceipt expired = _receiptIn(CommandState.expired);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => Stream<CommandReceipt>.value(expired),
    );
    final RecordingDraftStore store = RecordingDraftStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    await _fillToReady(tester, spec);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(store.cleared, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    // S-10: typed input kept and editable
    _expectFilledInputs(tester, spec, enabled: true);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  testWidgets('T8-heldForIntegrity: cleared empty, locked', (
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
    final RecordingDraftStore store = RecordingDraftStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    await _fillToReady(tester, spec);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(store.cleared, isEmpty);
    // 잠금 상태 — 제출 라벨 0
    expect(find.text(JournalLabels.draftSubmit), findsNothing);
    expect(find.text(held.stateLabel), findsOneWidget);
    // S-10: typed input kept but locked
    _expectFilledInputs(tester, spec, enabled: false);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T9: 행 2 복원 → 재구독 잠금 ──────────────────────────────────────────────

  testWidgets('T9: row 2 restore → resubscribe lock, then receipt unlocks', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row2 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[2];
    expect(row2.key.targetId, spec.decisionId);
    expect(row2.lastCommandId, isNotNull);

    final StreamController<CommandReceipt> ctrl =
        StreamController<CommandReceipt>();
    addTearDown(ctrl.close);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Completer<CommandReceipt>().future,
      onWatch: () => ctrl.stream,
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row2],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    // api.watchedIds == <String>[행 2 의 lastCommandId]
    expect(api.watchedIds, equals(<String>[row2.lastCommandId!]));
    // 첫 접수증 전: TextField 3개 전부 enabled == false
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.enabled, isFalse);
    }
    // 제출 라벨 0
    expect(find.text(JournalLabels.draftSubmit), findsNothing);
    // j3-resubscribe 0
    expect(find.byKey(const Key('j3-resubscribe')), findsNothing);
    // j3-submit-not-accepted 0
    expect(find.byKey(const Key('j3-submit-not-accepted')), findsNothing);

    // REQUESTED 행 add
    final CommandReceipt requested = _receiptIn(CommandState.requested);
    ctrl.add(requested);
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);

    // stateLabel 1
    expect(find.text(requested.stateLabel), findsOneWidget);
    // 여전히 잠금 (REQUESTED 는 locked)
    expect(find.text(JournalLabels.draftSubmit), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T10: 행 2 + REJECTED → 복원 원문 + 재제출 가능 ─────────────────────────

  testWidgets('T10: row 2 + REJECTED → original text restored, re-submit', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row2 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[2];
    expect(row2.key.targetId, spec.decisionId);

    final CommandReceipt rejected = _receiptIn(CommandState.rejected);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Completer<CommandReceipt>().future,
      onWatch: () => Stream<CommandReceipt>.value(rejected),
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row2],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    // 행 2 원문 복원
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      row2.journal!.rationaleBefore,
    );
    // rejected.stateLabel 1
    expect(find.text(rejected.stateLabel), findsOneWidget);
    // 제출 버튼 활성 (재제출)
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T11: 행 2 + EXECUTED → cleared, JournalReadContent ──────────────────────

  testWidgets('T11: row 2 + EXECUTED → cleared, j3r-body shown', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row2 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[2];
    expect(row2.key.targetId, spec.decisionId);
    final DraftKey key = DraftKey(
      kind: DraftKind.journalDraft,
      targetId: spec.decisionId,
    );

    final CommandReceipt executed = _receiptIn(CommandState.executed);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Completer<CommandReceipt>().future,
      onWatch: () => Stream<CommandReceipt>.value(executed),
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row2],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      decisionId: spec.decisionId,
    );

    expect(store.cleared, equals(<DraftKey>[key]));
    expect(find.byKey(const Key('j3r-body')), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── R2b C4: executed clear 는 1회(01 §12-1-4) ───────────────────────────────
  // 대상 변이: M06(clear once 가드 제거 → 제출 Future·스트림의 EXECUTED 마다 clear)

  testWidgets(
    'R2b C4 — EXECUTED from both submit and stream clears the draft exactly once',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt executed = _receiptIn(CommandState.executed);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(executed),
        onWatch: () => Stream<CommandReceipt>.value(executed),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      final DraftKey key = DraftKey(
        kind: DraftKind.journalDraft,
        targetId: spec.decisionId,
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 전제: 제출 1회 · 같은 명령 구독 1회(스트림이 EXECUTED 를 한 번 더 준다)
      expect(api.submitted.length, 1);
      expect(api.watchedIds, equals(<String>[executed.commandId]));
      // clear 정확히 1회
      expect(store.cleared, equals(<DraftKey>[key]));
    },
  );

  // ── R2b C4: 순서 규칙 — 연결 save → 반영(clear) → 구독 ──────────────────────
  // 대상 변이: M31(반영=clear 먼저 → 연결 save 나중 → clear 뒤 save 가 초안을 되살림)

  testWidgets(
    'R2b C4 — submit returning EXECUTED saves the link before clear, no draft left',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt executed = _receiptIn(CommandState.executed);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(executed),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore();
      final DraftKey key = DraftKey(
        kind: DraftKind.journalDraft,
        targetId: spec.decisionId,
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 연결 save 가 나갔다(돌려준 commandId)
      expect(store.saved, isNotEmpty);
      expect(store.saved.last.lastCommandId, executed.commandId);
      // clear 1회
      expect(store.cleared, equals(<DraftKey>[key]));
      // 순서 규칙: clear 가 마지막 → 저장소에 초안이 남지 않는다
      expect(store.current(key), isNull);
    },
  );

  // ── T12: 행 2 + 첫 값 전 구독 에러 → j3-resubscribe + 재구독 ──────────────

  testWidgets(
    'T12: row 2 + watch error before receipt → resubscribe button works',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row2 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[2];
      expect(row2.key.targetId, spec.decisionId);

      final CommandReceipt requested = _receiptIn(CommandState.requested);
      int watchCount = 0;
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Completer<CommandReceipt>().future,
        onWatch: () {
          watchCount++;
          if (watchCount == 1) {
            return Stream<CommandReceipt>.error(Exception('watch error'));
          }
          return Stream<CommandReceipt>.value(requested);
        },
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row2],
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      // 에러 소비
      expect(tester.takeException(), isNotNull);

      // 잠금 유지
      expect(find.text(JournalLabels.draftSubmit), findsNothing);
      // j3-resubscribe 1 이고 TextButton (key 가 TextButton 자체에 있음)
      expect(find.byKey(const Key('j3-resubscribe')), findsOneWidget);
      expect(
        tester.widget(find.byKey(const Key('j3-resubscribe'))),
        isA<TextButton>(),
      );

      // 탭 → 재구독
      await tester.tap(find.byKey(const Key('j3-resubscribe')));
      await tester.pump();
      await tester.pump();

      // watchedIds.length == 2 (initial + resubscribe)
      expect(api.watchedIds.length, 2);
      // REQUESTED stateLabel 1
      expect(find.text(requested.stateLabel), findsOneWidget);
      // 여전히 잠금 (REQUESTED)
      expect(find.text(JournalLabels.draftSubmit), findsNothing);
    },
  );

  // ── R2b C4: 재구독 에러 뒤·재시도 창도 잠금(01 §12-1-4 🔴 재시작 뒤 이중 제출) ──
  // 대상 변이: M11(구독 에러 때 _awaitingReceipt 해제 → 재시도 창에 제출 버튼 · 2차 제출)
  //           M11b(구독 에러 때 입력만 풀림)
  // «잠금» = 제출 버튼 부재 + TextField enabled false 둘 다.
  // 2회차 구독 = add 하지 않은 StreamController → «다시 시도» 뒤 첫 값 전 창을 관찰한다.

  testWidgets(
    'R2b C4 — resubscribe error and retry window before first receipt stay locked',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row2 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[2];
      expect(row2.key.targetId, spec.decisionId);
      expect(row2.lastCommandId, isNotNull);

      final StreamController<CommandReceipt> ctrl =
          StreamController<CommandReceipt>();
      // 늦게 구독되는 컨트롤러: 탭 전 단언이 실패하면 구독자 0 → close() Future 가
      // 끝나지 않아 teardown 이 매달린다. 그래서 close 는 호출하되 기다리지 않는다.
      addTearDown(() {
        unawaited(ctrl.close());
      });
      int watchCount = 0;
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Completer<CommandReceipt>().future,
        onWatch: () {
          watchCount++;
          if (watchCount == 1) {
            return Stream<CommandReceipt>.error(Exception('watch error'));
          }
          return ctrl.stream;
        },
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: RecordingDraftStore(seed: <DraftRecord>[row2]),
        decisionId: spec.decisionId,
      );

      // 1회차 구독 에러 소비
      expect(tester.takeException(), isNotNull);
      expect(find.byKey(const Key('j3-resubscribe')), findsOneWidget);
      // 에러 뒤 잠금 — 제출 버튼 0 · 입력 3개 전부 enabled false
      expect(find.text(JournalLabels.draftSubmit), findsNothing);
      expect(find.byType(TextField), findsNWidgets(3));
      for (final TextField f in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(f.enabled, isFalse);
      }

      // «다시 시도» 탭 → 2회차 구독(아직 값 없음)
      await tester.tap(find.byKey(const Key('j3-resubscribe')));
      await tester.pump();
      await tester.pump();

      expect(
        api.watchedIds,
        equals(<String>[row2.lastCommandId!, row2.lastCommandId!]),
      );
      expect(find.byKey(const Key('j3-resubscribe')), findsNothing);
      // 재시도 창(첫 값 전)도 잠금 — 제출 버튼 0 · 입력 enabled false
      expect(find.text(JournalLabels.draftSubmit), findsNothing);
      expect(find.byType(TextField), findsNWidgets(3));
      for (final TextField f in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(f.enabled, isFalse);
      }

      // 기준점: 창 안에는 접수증이 없고, 첫 접수증이 오면 보인다(관찰한 창이 «첫 값 전»이었다)
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      expect(find.text(requested.stateLabel), findsNothing);
      ctrl.add(requested);
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
      expect(find.text(requested.stateLabel), findsOneWidget);
    },
  );

  // ── T13: load 에러 → 빈 폼 편집 가능 ────────────────────────────────────────

  testWidgets('T13: load error → empty form editable, no error text', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );

    // load 만 Future.error 인 저장소
    final _LoadErrorStore loadErrorStore = _LoadErrorStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: loadErrorStore,
      decisionId: spec.decisionId,
    );

    // 에러 소비
    expect(tester.takeException(), isNotNull);
    // 빈 폼 편집 가능 (TextField 있음)
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField field in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(field.enabled, isTrue);
    }
    // j3-submit-not-accepted 0
    expect(find.byKey(const Key('j3-submit-not-accepted')), findsNothing);
  });

  // ── R2b C4: 복원 중 = 스켈레톤만(01 §12-4 1행) ──────────────────────────────
  // 대상 변이: M27(복원 스켈레톤 게이트 제거 → 복원 전 빈 폼이 뜬다)

  testWidgets('R2b C4 — restore in progress shows skeleton only, no inputs', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftKey key = DraftKey(
      kind: DraftKind.journalDraft,
      targetId: spec.decisionId,
    );
    final _HangLoadStore store = _HangLoadStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    // 전제: 복원 load 가 이 키로 불렸고 끝나지 않았다
    expect(store.loaded, equals(<DraftKey>[key]));
    // 스켈레톤 1 · 입력란 0 · 제출 라벨 0
    expect(find.byType(JournalSkeleton), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(JournalLabels.draftSubmit), findsNothing);
  });

  // ── T14: save 에러 → 입력 유지, 문구 0 ──────────────────────────────────────

  testWidgets('T14: save error → input kept, no error text', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );

    final _SaveErrorStore saveErrorStore = _SaveErrorStore();

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: saveErrorStore,
      decisionId: spec.decisionId,
    );

    await tester.enterText(find.byType(TextField).first, 'abc');
    await tester.pump();

    // 에러 소비
    expect(tester.takeException(), isNotNull);
    // 입력 유지
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'abc',
    );
    // 문구 0
    expect(find.byKey(const Key('j3-submit-not-accepted')), findsNothing);
    // retry 0(에러 상태 아님)
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T15: 51④: 1회차 제출 에러 → j3-submit-not-accepted, 2회차 시작에 사라짐 ─

  testWidgets(
    'T15: submit error → j3-submit-not-accepted shown, clears on next submit',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final Completer<CommandReceipt> hangCompleter =
          Completer<CommandReceipt>();
      int submitCount = 0;
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () {
          submitCount++;
          if (submitCount == 1) {
            return Future<CommandReceipt>.error(Exception('fail'));
          }
          return hangCompleter.future;
        },
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore();

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);

      // 1회차 제출 Future.error
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNotNull);
      // j3-submit-not-accepted 1
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
      // 입력 유지
      expect(find.byType(TextField), findsNWidgets(3));
      // cleared 0
      expect(store.cleared, isEmpty);

      // 2회차(끝나지 않는 completer) 제출 탭 → 제출 중에는 그 줄 0
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.byKey(const Key('j3-submit-not-accepted')), findsNothing);

      // cleanup
      hangCompleter.completeError(Exception('hang'));
      await tester.pumpAndSettle();
      tester.takeException(); // consume
    },
  );

  // ── R2b C4: 51 ④ 줄은 입력 편집으로 사라지지 않는다(01 §12-3) ───────────────
  // 대상 변이: M16(입력 변경이 j3-submit-not-accepted 를 지움)

  testWidgets(
    'R2b C4 — submitNotAccepted line survives input edits, submit stays active',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.error(Exception('fail')),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore();

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNotNull);
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
      // 전제: 메모 칸은 편집 가능(잠금 아님)
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).enabled,
        isTrue,
      );

      // 메모 칸 편집
      const String memoText = 'memo';
      await tester.enterText(find.byType(TextField).at(2), memoText);
      await tester.pump();

      // 전제: 편집이 입력 변경 경로를 탔다(초안 저장에 반영)
      expect(store.saved.last.journal!.note, memoText);
      // 편집으로 사라지지 않는다 — 다음 제출 시작에만 사라진다(T15)
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
      // 재제출 가능
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    },
  );

  // ── R2b C4: 명령 Future 에러 → DraftStore 호출 0(01 §12-4) ──────────────────
  // 대상 변이: M17(Future 에러 때 같은 내용 save 1회 더)
  // 같은 내용을 한 번 더 save 하는 변이는 내용 단언으로 가릴 수 없어 «저장 기록 불변»으로 본다.
  // 카드 규칙 «saved 개수 단언은 T5(0건)에만»의 완화 = C4 부록 S-7(발주자 승인 대안 (나)).

  testWidgets(
    'R2b C4 — command Future error makes no DraftStore call (save log unchanged, no clear)',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.error(Exception('fail')),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore();

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      // 전제: 입력 저장이 이 저장소로 들어왔다(기록기가 연결돼 있다)
      expect(store.saved, isNotEmpty);
      final List<DraftRecord> savedBefore = List<DraftRecord>.of(store.saved);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNotNull);
      // 전제: 제출은 실제로 나갔고 51 ④ 로 끝났다
      expect(api.submitted.length, 1);
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
      // 저장 기록 불변 · clear 0
      expect(store.saved, orderedEquals(savedBefore));
      expect(store.cleared, isEmpty);
    },
  );

  // ── T16: 51④ 공존: REQUESTED → REJECTED → 2회차 에러 → 둘 다 보임 ──────────

  testWidgets(
    'T16: rejected stateLabel + submitNotAccepted both shown after re-submit error',
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
          return Future<CommandReceipt>.error(Exception('re-fail'));
        },
        onWatch: () => Stream<CommandReceipt>.value(rejected),
      );
      final RecordingDraftStore store = RecordingDraftStore();

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);

      // 1회차 제출 → REQUESTED → REJECTED
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text(rejected.stateLabel), findsOneWidget);

      // 2회차 제출 → Future.error
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNotNull);

      // rejected.stateLabel 1 그리고 j3-submit-not-accepted 1
      expect(find.text(rejected.stateLabel), findsOneWidget);
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
    },
  );

  // ── T17: 51③ 경계: REQUESTED 뒤 watchCommand 에러 → submitNotAccepted 0 ─────

  testWidgets(
    'T17: REQUESTED then watchCommand error → no submitNotAccepted, receipt kept',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(requested),
        onWatch: () => Stream<CommandReceipt>.error(Exception('watch err')),
      );
      final RecordingDraftStore store = RecordingDraftStore();

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // j3-submit-not-accepted 0 (watchCommand 에러라 submitNotAccepted 아님)
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsNothing);
      // requested.stateLabel 1
      expect(find.text(requested.stateLabel), findsOneWidget);
      // 에러 소비
      expect(tester.takeException(), isNotNull);
    },
  );

  // ── R2b C4: 접수증 뒤 구독 에러 → «다시 시도» 없음(51 ③) ─────────────────────
  // 대상 변이: M28(접수증이 이미 있는데도 구독 에러에 «다시 시도»)

  testWidgets(
    'R2b C4 — watch error after a receipt keeps the receipt, no resubscribe',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final CommandReceipt requested = _receiptIn(CommandState.requested);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(requested),
        onWatch: () => Stream<CommandReceipt>.error(Exception('watch err')),
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: RecordingDraftStore(),
        decisionId: spec.decisionId,
      );

      await _fillToReady(tester, spec);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 에러 소비
      expect(tester.takeException(), isNotNull);
      // 전제: 에러는 접수증 명령의 구독에서 났다
      expect(api.watchedIds, equals(<String>[requested.commandId]));
      // 마지막 접수증 유지
      expect(find.text(requested.stateLabel), findsOneWidget);
      // «다시 시도» 0 — 키로도 라벨로도
      expect(find.byKey(const Key('j3-resubscribe')), findsNothing);
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── T18a: 다른 키 → 입력란 3개 빈 칸 ────────────────────────────────────────

  testWidgets(
    'T18a: row 3 seed + discretion decisionId → row 3 text not shown, fields empty',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row3 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[3];
      // 전제: 행 3 의 key.targetId ≠ discretion spec 의 decisionId
      expect(row3.key.targetId, isNot(spec.decisionId));

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row3],
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        store: store,
        decisionId: spec.decisionId,
      );

      // 행 3 원문 findsNothing(다른 키)
      expect(find.text(row3.journal!.rationaleBefore), findsNothing);
      // 입력란 3개 빈 칸
      expect(find.byType(TextField), findsNWidgets(3));
      for (final TextField f in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(f.controller!.text, isEmpty);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── T18b: 행 3 + recon_clear 스펙 → 복원·드롭다운 null(폐기 code) ─────────

  testWidgets(
    'T18b: row 3 seed + recon_clear spec → text restored, dropdown null (retired code)',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecReconClear,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row3 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[3];
      // 전제: 행 3 의 key.targetId == recon_clear spec 의 decisionId
      expect(row3.key.targetId, spec.decisionId);

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row3],
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        store: store,
        decisionId: spec.decisionId,
      );

      // 원문 복원
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        row3.journal!.rationaleBefore,
      );
      // 드롭다운 value == null (폐기 code — 선택지에 없음)
      expect(
        tester
            .widget<DropdownButton<ReasonOption>>(
              find.byType(DropdownButton<ReasonOption>),
            )
            .value,
        isNull,
      );
      // 제출 비활성 (규칙 미선택)
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    },
  );

  // ── T25: 동기 throw 방어 ─────────────────────────────────────────────────────

  testWidgets('T25: sync throw save → submit succeeds, REQUESTED shown', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row1 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[1];
    expect(row1.key.targetId, spec.decisionId);

    final CommandReceipt requested = _receiptIn(CommandState.requested);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Future<CommandReceipt>.value(requested),
      onWatch: () => const Stream<CommandReceipt>.empty(),
    );
    final _SyncThrowStore syncThrowStore = _SyncThrowStore(
      seed: <DraftRecord>[row1],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: syncThrowStore,
      decisionId: spec.decisionId,
    );

    // 행 1 복원은 정상 (load 는 정상, save 만 동기 throw)
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // 동기 throw 를 _port 가 잡아 에러 보고
    expect(tester.takeException(), isNotNull);
    // watchedIds == <String>[commandId]
    expect(api.watchedIds, equals(<String>[requested.commandId]));
    // REQUESTED stateLabel 1
    expect(find.text(requested.stateLabel), findsOneWidget);
    // 입력 잠금 — 입력란 3개가 실제로 있다
    expect(find.byType(TextField), findsNWidgets(3));
    for (final TextField f in tester.widgetList<TextField>(
      find.byType(TextField),
    )) {
      expect(f.enabled, isFalse);
    }
    // 제출 라벨 0
    expect(find.text(JournalLabels.draftSubmit), findsNothing);
    // api.submitted.length == 1
    expect(api.submitted.length, 1);
  });

  // ── T26: 재구독 무값 완료 → j3-resubscribe 1 ─────────────────────────────────

  testWidgets(
    'T26: row 2 + empty stream → lock + j3-resubscribe, tap resubscribes',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row2 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[2];
      expect(row2.key.targetId, spec.decisionId);

      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Completer<CommandReceipt>().future,
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row2],
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      // 잠금 유지
      expect(find.text(JournalLabels.draftSubmit), findsNothing);
      // j3-resubscribe 1
      expect(find.byKey(const Key('j3-resubscribe')), findsOneWidget);

      // 탭 → 재구독
      await tester.tap(find.byKey(const Key('j3-resubscribe')));
      await tester.pump();

      expect(api.watchedIds.length, 2);
    },
  );

  // ── T27: executed 직후 전환 → 본문 스트림 교체 ────────────────────────────────

  testWidgets('T27: executed + journal stream updates body live', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row2 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[2];
    expect(row2.key.targetId, spec.decisionId);

    final DecisionJournalVm notWritten = listFixture(
      FixturePaths.m6JournalReadNotWritten,
      DecisionJournalVm.fromJson,
    ).rows[1]; // row 1: decision_id = d_20260901_a_31, body = null
    final DecisionJournalVm written = singleFixture(
      FixturePaths.m6JournalReadWritten,
      DecisionJournalVm.fromJson,
    );

    final StreamController<DecisionJournalVm> journalCtrl =
        StreamController<DecisionJournalVm>();
    addTearDown(journalCtrl.close);

    final CommandReceipt executed = _receiptIn(CommandState.executed);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Completer<CommandReceipt>().future,
      onWatch: () => Stream<CommandReceipt>.value(executed),
    );
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row2],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: store,
      journal: () => journalCtrl.stream,
      decisionId: spec.decisionId,
    );

    // not_written 행 1 추가 → body 0
    journalCtrl.add(notWritten);
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);

    expect(find.byKey(const Key('j3r-body')), findsNothing);
    expect(find.text(notWritten.journalStateLabel), findsOneWidget);

    // written 추가 → body 1
    journalCtrl.add(written);
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);

    expect(find.byKey(const Key('j3r-body')), findsOneWidget);
  });

  // ── T28: 행 4 — 메모 + requiresNote rule ────────────────────────────────────

  testWidgets(
    'T28: row 4 restore → memo shown, note required rule selected, submit active; clear note → inactive',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row4 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[4];
      expect(row4.key.targetId, spec.decisionId);
      expect(row4.journal!.note, isNotEmpty);

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row4],
      );

      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        store: store,
        decisionId: spec.decisionId,
      );

      // 메모 칸 = 행 4 원문
      expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
        row4.journal!.note,
      );
      // 드롭다운 label = 행 4 code 의 선택지 label (requiresNote true)
      final DropdownButton<ReasonOption> dd = tester.widget(
        find.byType(DropdownButton<ReasonOption>),
      );
      expect(dd.value?.code, row4.journal!.ruleCited);
      expect(dd.value?.requiresNote, isTrue);
      // 선택된 규칙 label 이 화면에 보인다
      expect(find.text(dd.value!.label), findsWidgets);
      // 제출 활성
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );

      // 메모 칸 enterText('') → 비활성
      await tester.enterText(find.byType(TextField).at(2), '');
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    },
  );

  // ── T29: T11 화면에서 JournalAsOfHeader 1 · stale banner ────────────────────

  testWidgets(
    'T29: executed = one JournalAsOfHeader; stale clock shows StaleBanner',
    (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final DraftRecord row2 = listFixture(
        FixturePaths.m6DraftRecordsJ3,
        DraftRecord.fromJson,
      ).rows[2];
      expect(row2.key.targetId, spec.decisionId);

      final CommandReceipt executed = _receiptIn(CommandState.executed);
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Completer<CommandReceipt>().future,
        onWatch: () => Stream<CommandReceipt>.value(executed),
      );
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row2],
      );

      // 신선 시계 → JournalAsOfHeader 1 (J-3 위쪽만)
      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: api,
        store: store,
        decisionId: spec.decisionId,
      );

      expect(find.byType(JournalAsOfHeader), findsOneWidget);
      // 데이터 기준점 — 머리 글자 1
      expect(find.text(spec.asOf.label), findsOneWidget);

      // 스테일 시계로 같은 화면
      await _pump(
        tester,
        spec: spec,
        safety: safetyFixtureRow(0),
        opener: RecordingLinkOpener(),
        commandApi: _FakeCommandApi(
          onSubmit: () => Completer<CommandReceipt>().future,
          onWatch: () => Stream<CommandReceipt>.value(executed),
        ),
        store: RecordingDraftStore(seed: <DraftRecord>[row2]),
        clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
        decisionId: spec.decisionId,
      );

      expect(find.byType(JournalStaleBanner), findsOneWidget);
    },
  );

  // ── S11: executed 끼워 넣은 읽기 본문의 값 → 에러 ──────────────────────────────

  testWidgets('S11 J-3 executed read value then error keeps lastAsOfLabel', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row2 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[2];
    expect(row2.key.targetId, spec.decisionId);
    final DecisionJournalVm written = singleFixture(
      FixturePaths.m6JournalReadWritten,
      DecisionJournalVm.fromJson,
    );

    final StreamController<DecisionJournalVm> journalCtrl =
        StreamController<DecisionJournalVm>();
    addTearDown(() {
      unawaited(journalCtrl.close());
    });

    final CommandReceipt executed = _receiptIn(CommandState.executed);
    final _FakeCommandApi api = _FakeCommandApi(
      onSubmit: () => Completer<CommandReceipt>().future,
      onWatch: () => Stream<CommandReceipt>.value(executed),
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      commandApi: api,
      store: RecordingDraftStore(seed: <DraftRecord>[row2]),
      journal: () => journalCtrl.stream,
      decisionId: spec.decisionId,
    );

    journalCtrl.add(written);
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    expect(find.byKey(const Key('j3r-body')), findsOneWidget);
    expect(find.byType(JournalErrorView), findsNothing);

    journalCtrl.addError(Exception('after value'));
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    expect(find.byType(JournalErrorView), findsOneWidget);
    expect(
      tester
          .widget<JournalErrorView>(find.byType(JournalErrorView))
          .lastAsOfLabel,
      written.asOf.label,
    );
  });

  // ── S1: 긴 선택 label 의 둘째 줄이 밑줄 위에 있다 ─────────────────────────────

  testWidgets('S1 long selected rule label wraps above the underline', (
    WidgetTester tester,
  ) async {
    final JournalDraftFormSpec spec = singleFixture(
      FixturePaths.m6JournalDraftSpecDiscretion,
      JournalDraftFormSpec.fromJson,
    );
    final DraftRecord row1 = listFixture(
      FixturePaths.m6DraftRecordsJ3,
      DraftRecord.fromJson,
    ).rows[1];
    expect(row1.key.targetId, spec.decisionId);
    final RecordingDraftStore store = RecordingDraftStore(
      seed: <DraftRecord>[row1],
    );

    await _pump(
      tester,
      spec: spec,
      safety: safetyFixtureRow(0),
      opener: RecordingLinkOpener(),
      store: store,
      decisionId: spec.decisionId,
    );

    final Finder dropdown = find.byType(DropdownButton<ReasonOption>);
    final ReasonOption? picked = tester
        .widget<DropdownButton<ReasonOption>>(dropdown)
        .value;
    expect(picked, isNotNull);
    final Finder labelText = find
        .descendant(of: dropdown, matching: find.text(picked!.label))
        .first;
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      labelText,
    );
    expect(paragraph.maxLines, isNull);
    expect(paragraph.softWrap, isTrue);
    expect(
      tester.getBottomLeft(labelText).dy,
      lessThan(tester.getBottomLeft(dropdown).dy - 1),
    );
    expect(find.text(JournalLabels.retry), findsNothing);
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

/// load 만 에러인 저장소 (T13).
class _LoadErrorStore extends RecordingDraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) =>
      Future<DraftRecord?>.error(StateError('load fail'));
}

/// save 만 에러인 저장소 (T14).
class _SaveErrorStore extends RecordingDraftStore {
  @override
  Future<void> save(DraftRecord record) =>
      Future<void>.error(StateError('save fail'));
}

/// save 가 동기 throw 인 저장소 (T25 — _port 방어 검증).
class _SyncThrowStore extends RecordingDraftStore {
  _SyncThrowStore({super.seed});

  @override
  Future<void> save(DraftRecord record) => throw StateError('save sync throw');
}

/// load 가 끝나지 않는 저장소 (R2b C4 — 복원 중 스켈레톤 · M27).
class _HangLoadStore extends RecordingDraftStore {
  @override
  Future<DraftRecord?> load(DraftKey key) {
    loaded.add(key);
    return Completer<DraftRecord?>().future;
  }
}
