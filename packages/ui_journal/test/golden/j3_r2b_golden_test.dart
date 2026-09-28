// test/golden/j3_r2b_golden_test.dart — J-3 R2b 신규 골든 (3종 × light/dark = 6장)
//
// 🔴 링크 오프너 주입 안 함(카드 규칙 «골든은 링크 오프너만 주입하지 않는다»).
// 🔴 CommandApi·DraftStore·읽기 가짜는 주입한다(이 파일 안에 정의).
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j3_r2b_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/src/journal_draft/journal_draft_form.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

// ── Fake repositories ──────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo({required this.spec, this.journalStream});
  final JournalDraftFormSpec spec;
  final Stream<DecisionJournalVm> Function()? journalStream;

  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) =>
      Future<JournalDraftFormSpec>.value(spec);

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) {
    if (journalStream != null) return journalStream!();
    return Stream<DecisionJournalVm>.value(
      singleFixture(FixturePaths.m6JournalReadWritten, DecisionJournalVm.fromJson),
    );
  }
}

class _FakeSafetyRepository extends UnimplementedSafetyRepository {
  _FakeSafetyRepository(this._state);
  final SafetyState _state;
  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(_state);
}

/// G6: callbacks so each call gets a fresh Future/Stream.
class _FakeCommandApi extends UnimplementedCommandApi {
  _FakeCommandApi({required this.onSubmit, required this.onWatch});
  final Future<CommandReceipt> Function() onSubmit;
  final Stream<CommandReceipt> Function() onWatch;

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) => onSubmit();

  @override
  Stream<CommandReceipt> watchCommand(String commandId) => onWatch();
}

// ── Helper ─────────────────────────────────────────────────────────────────────

CommandReceipt _receiptIn(CommandState state) {
  return listFixture(
    FixturePaths.m6JournalDraftReceipts5,
    CommandReceipt.fromJson,
  ).rows.firstWhere((CommandReceipt r) => r.state == state);
}

List<Override> _baseOverrides(
  JournalDraftFormSpec spec, {
  CommandApi? cmdApi,
  RecordingDraftStore? store,
  Stream<DecisionJournalVm> Function()? journalStream,
}) {
  return <Override>[
    journalTimelineRepositoryProvider.overrideWithValue(
      _FakeJournalRepo(spec: spec, journalStream: journalStream),
    ),
    journalSafetyRepositoryProvider.overrideWithValue(
      _FakeSafetyRepository(safetyFixtureRow(0)),
    ),
    journalClockProvider.overrideWithValue(FixedClock(kGoldenNowUtc)),
    // 🔴 링크 오프너 주입 안 함
    journalDraftStoreProvider.overrideWithValue(store ?? RecordingDraftStore()),
    if (cmdApi != null) journalCommandApiProvider.overrideWithValue(cmdApi),
  ];
}

// ── Goldens ────────────────────────────────────────────────────────────────────

void main() {
  final JournalDraftFormSpec discSpec = singleFixture(
    FixturePaths.m6JournalDraftSpecDiscretion,
    JournalDraftFormSpec.fromJson,
  );
  final List<DraftRecord> draftRows = listFixture(
    FixturePaths.m6DraftRecordsJ3,
    DraftRecord.fromJson,
  ).rows;

  for (final Brightness b in Brightness.values) {
    // ── j3_restored_rejected ─────────────────────────────────────────────────
    // 스펙 discretion + 행 2 시드 + watchCommand = REJECTED 행
    testWidgets('j3_restored_rejected ${b.name}', (WidgetTester tester) async {
      final DraftRecord row2 = draftRows[2];
      final CommandReceipt rejected = _receiptIn(CommandState.rejected);

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row2],
      );
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(rejected),
        onWatch: () => Stream<CommandReceipt>.value(rejected),
      );

      await pumpForGolden(
        tester,
        JournalDraftForm(decisionId: discSpec.decisionId),
        brightness: b,
        logicalSize: _kTallPhone,
        wrapApp: (Widget app) => ProviderScope(
          overrides: _baseOverrides(
            discSpec,
            cmdApi: api,
            store: store,
          ),
          child: app,
        ),
      );
      await tester.pumpAndSettle();

      // 전제: rejected.stateLabel 1
      expect(find.text(rejected.stateLabel), findsOneWidget);
      // 맨 아래 = FilledButton (re-submit)
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_restored_rejected', b);
    });

    // ── j3_submit_not_accepted ───────────────────────────────────────────────
    // 스펙 discretion + 행 1 시드 + submitJournalDraft = Future.error
    testWidgets('j3_submit_not_accepted ${b.name}', (WidgetTester tester) async {
      final DraftRecord row1 = draftRows[1];

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row1],
      );
      // 🔴 콜백으로 생성 — 미리 만든 Future.error 는 탭 전에 «잡히지 않은 비동기 에러»로 실패
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.error(Exception('submit rejected')),
        onWatch: () => const Stream<CommandReceipt>.empty(),
      );

      await pumpForGolden(
        tester,
        JournalDraftForm(decisionId: discSpec.decisionId),
        brightness: b,
        logicalSize: _kTallPhone,
        wrapApp: (Widget app) => ProviderScope(
          overrides: _baseOverrides(discSpec, cmdApi: api, store: store),
          child: app,
        ),
      );
      await tester.pumpAndSettle();

      // Submit 버튼 탭 1회
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 에러 단언 (submitJournalDraft Future.error)
      expect(tester.takeException(), isNotNull);

      // 전제: j3-submit-not-accepted 보임
      expect(find.byKey(const Key('j3-submit-not-accepted')), findsOneWidget);
      // 맨 아래 = FilledButton
      expect(
        tester.getBottomLeft(find.byType(FilledButton)).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_submit_not_accepted', b);
    });

    // ── j3_executed_read ─────────────────────────────────────────────────────
    // 스펙 discretion + 행 2 시드 + watchCommand = EXECUTED + watchDecisionJournal = written
    testWidgets('j3_executed_read ${b.name}', (WidgetTester tester) async {
      final DraftRecord row2 = draftRows[2];
      final CommandReceipt executed = _receiptIn(CommandState.executed);
      final DecisionJournalVm written = singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      );

      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[row2],
      );
      final _FakeCommandApi api = _FakeCommandApi(
        onSubmit: () => Future<CommandReceipt>.value(executed),
        onWatch: () => Stream<CommandReceipt>.value(executed),
      );

      await pumpForGolden(
        tester,
        JournalDraftForm(decisionId: discSpec.decisionId),
        brightness: b,
        logicalSize: _kTallPhone,
        wrapApp: (Widget app) => ProviderScope(
          overrides: _baseOverrides(
            discSpec,
            cmdApi: api,
            store: store,
            journalStream: () => Stream<DecisionJournalVm>.value(written),
          ),
          child: app,
        ),
      );
      await tester.pumpAndSettle();

      // 전제: JournalAsOfHeader 1개만(끼워 넣기 헤더 생략 증명)
      expect(find.byType(JournalAsOfHeader), findsOneWidget);
      // 맨 아래 = j3r-link-decision
      expect(
        tester.getBottomLeft(
          find.byKey(const Key('j3r-link-decision')),
        ).dy,
        lessThan(_kTallPhone.height),
      );
      await expectGolden('j3_executed_read', b);
    });
  }
}
