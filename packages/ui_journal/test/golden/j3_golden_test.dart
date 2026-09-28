// test/golden/j3_golden_test.dart — J-3 사전 저널 골든 (R2 신규 · 4종 × light/dark = 8장)
//
// 🔴 링크 오프너 주입 안 함. #12(j3_rejected)만 CommandApi 가짜 주입.
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j3_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/journal_draft/journal_draft_form.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

// ── Fake repositories ─────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo(this._spec);
  final JournalDraftFormSpec _spec;

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) =>
      Future<JournalDraftFormSpec>.value(_spec);
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

/// Command API fake for golden #12 (j3_rejected).
class _FakeCommandApi extends UnimplementedCommandApi {
  _FakeCommandApi({required this.submitResponse, required this.watchResponse});
  final CommandReceipt submitResponse;
  final Stream<CommandReceipt> watchResponse;

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) =>
      Future<CommandReceipt>.value(submitResponse);

  @override
  Stream<CommandReceipt> watchCommand(String commandId) => watchResponse;
}

// ── Helper ─────────────────────────────────────────────────────────────────────

List<Override> _baseOverrides(JournalDraftFormSpec spec, {CommandApi? cmdApi}) {
  return <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(_FakeJournalRepo(spec)),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safetyFixtureRow(0)),
    ),
    journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
    // G8: no journalLinkOpenerProvider (카드 규칙 «골든은 링크 오프너만 주입하지 않는다»)
    journalDraftStoreProvider.overrideWithValue(RecordingDraftStore()),
    if (cmdApi != null) journalCommandApiProvider.overrideWithValue(cmdApi),
  ];
}

Future<void> _pumpForm(
  WidgetTester tester,
  JournalDraftFormSpec spec,
  Brightness b, {
  CommandApi? cmdApi,
}) async {
  await pumpForGolden(
    tester,
    JournalDraftForm(decisionId: spec.decisionId),
    brightness: b,
    logicalSize: _kTallPhone,
    wrapApp: (Widget app) => ProviderScope(
      overrides: _baseOverrides(spec, cmdApi: cmdApi),
      child: app,
    ),
  );
}

// ── Goldens ────────────────────────────────────────────────────────────────────

void main() {
  for (final Brightness b in Brightness.values) {
    // ── 9. j3_discretion ─────────────────────────────────────────────────────
    testWidgets('j3_discretion ${b.name}', (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      await _pumpForm(tester, spec, b);
      // G8: position precondition
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_discretion', b);
    });

    // ── 10. j3_recon_clear ────────────────────────────────────────────────────
    testWidgets('j3_recon_clear ${b.name}', (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecReconClear,
        JournalDraftFormSpec.fromJson,
      );
      await _pumpForm(tester, spec, b);
      expect(find.byKey(const Key('j3-pledge-block')), findsNothing);
      // G8: position precondition
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_recon_clear', b);
    });

    // ── 11. j3_rule_menu_open ─────────────────────────────────────────────────
    testWidgets('j3_rule_menu_open ${b.name}', (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      await _pumpForm(tester, spec, b);
      // G8: precondition before opening dropdown
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      // Tap dropdown to open menu
      await tester.tap(find.byType(DropdownButton<ReasonOption>));
      await tester.pumpAndSettle();
      await expectGolden('j3_rule_menu_open', b);
    });

    // ── 12. j3_rejected ──────────────────────────────────────────────────────
    testWidgets('j3_rejected ${b.name}', (WidgetTester tester) async {
      final JournalDraftFormSpec spec = singleFixture(
        FixturePaths.m6JournalDraftSpecDiscretion,
        JournalDraftFormSpec.fromJson,
      );
      final List<CommandReceipt> receipts = listFixture(
        FixturePaths.m6JournalDraftReceipts5,
        CommandReceipt.fromJson,
      ).rows;
      final CommandReceipt requested = receipts.firstWhere(
        (CommandReceipt r) => r.state == CommandState.requested,
      );
      final CommandReceipt rejected = receipts.firstWhere(
        (CommandReceipt r) => r.state == CommandState.rejected,
      );

      final _FakeCommandApi api = _FakeCommandApi(
        submitResponse: requested,
        watchResponse: Stream<CommandReceipt>.value(rejected),
      );

      await _pumpForm(tester, spec, b, cmdApi: api);

      final int minChars = spec.rationaleMinChars;

      // Enter rationale (min chars)
      await tester.enterText(find.byType(TextField).first, 'a' * minChars);
      await tester.pump();

      // Enter expected outcome ('b')
      await tester.enterText(find.byType(TextField).at(1), 'b');
      await tester.pump();

      // Select rule that does not require note
      final ReasonOption noNoteRule = spec.ruleCitedOptions.firstWhere(
        (ReasonOption o) => !o.requiresNote,
      );
      await tester.tap(find.byType(DropdownButton<ReasonOption>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(noNoteRule.label).last);
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Precondition: submit button visible again (rejected = re-editable)
      expect(find.byType(FilledButton), findsOneWidget);
      // Show precondition: bottom of form is within viewport
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_rejected', b);
    });
  }
}
