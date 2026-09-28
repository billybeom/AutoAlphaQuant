// test/journal_read_test.dart — J-3R 사전 저널 읽기 뷰 단위 테스트.
//
// 🔴 No Korean literals.
// 🔴 Fake = extends UnimplementedJournalRepository (watchDecisionJournal).
// 🔴 Widget under test = JournalReadView (라우트 본문).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeJournalRepo extends UnimplementedJournalRepository {
  _FakeJournalRepo({required this.journalStream});

  final Stream<DecisionJournalVm> Function() journalStream;
  final List<String> receivedIds = <String>[];

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) {
    receivedIds.add(decisionId);
    return journalStream();
  }
}

// ── Pump helper ───────────────────────────────────────────────────────────────

Future<_FakeJournalRepo> _pump(
  WidgetTester tester, {
  required Stream<DecisionJournalVm> Function() journalStream,
  required String decisionId,
  Clock? clock,
  RecordingLinkOpener? opener,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeJournalRepo repo = _FakeJournalRepo(journalStream: journalStream);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        journalTimelineRepositoryProvider.overrideWithValue(repo),
        journalClockProvider.overrideWithValue(
          clock ?? FixedClock(kGoldenNowUtc),
        ),
        journalLinkOpenerProvider.overrideWithValue(
          opener ?? RecordingLinkOpener(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: JournalReadView(decisionId: decisionId)),
      ),
    ),
  );
  await tester.pump();
  return repo;
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── T19: loading → error → retry → value; value → error (lastAsOfLabel) ─────

  testWidgets(
    'T19: loading state shown; error triggers retry; value→error keeps lastAsOfLabel',
    (WidgetTester tester) async {
      // Part 1: loading state — StreamController with no add yet
      final StreamController<DecisionJournalVm> ctrl =
          StreamController<DecisionJournalVm>();
      addTearDown(ctrl.close);

      final _FakeJournalRepo repo = await _pump(
        tester,
        journalStream: () => ctrl.stream,
        decisionId: 'd_read_test',
      );

      // j3r-loading 1 (no value yet)
      expect(find.byKey(const Key('j3r-loading')), findsOneWidget);

      // Part 2: stream error → JournalLabels.retry shown → tap retry → call count +1
      ctrl.addError(Exception('read error'));
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      expect(find.text(JournalLabels.retry), findsOneWidget);
      final int callsBefore = repo.receivedIds.length;
      await tester.tap(find.text(JournalLabels.retry));
      await tester.pump();
      expect(repo.receivedIds.length, greaterThan(callsBefore));
    },
  );

  testWidgets(
    'T19b: value → error keeps lastAsOfLabel',
    (WidgetTester tester) async {
      final DecisionJournalVm written = singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      );

      final StreamController<DecisionJournalVm> ctrl =
          StreamController<DecisionJournalVm>();
      addTearDown(ctrl.close);

      await _pump(
        tester,
        journalStream: () => ctrl.stream,
        decisionId: written.decisionId,
      );

      // add value first
      ctrl.add(written);
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      // then error
      ctrl.addError(Exception('after value error'));
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);

      // lastAsOfLabel from the written vm
      expect(find.text(written.asOf.label), findsOneWidget);
      // retry shown
      expect(find.text(JournalLabels.retry), findsOneWidget);
    },
  );

  // ── T20: written — all fields + no trim + link tap + receivedIds ─────────────

  testWidgets(
    'T20: written fixture — all body fields shown, no trim, link tap, receivedId',
    (WidgetTester tester) async {
      final DecisionJournalVm vm = singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      final _FakeJournalRepo repo = await _pump(
        tester,
        journalStream: () => Stream<DecisionJournalVm>.value(vm),
        decisionId: vm.decisionId,
        opener: opener,
      );

      // All body fields visible
      expect(find.text(vm.body!.writtenAtText), findsOneWidget);
      expect(find.text(vm.body!.ruleCitedLabel), findsOneWidget);
      expect(find.text(vm.body!.rationaleBefore), findsOneWidget);
      expect(find.text(vm.body!.expectedOutcome), findsOneWidget);
      expect(find.text(vm.body!.note!), findsOneWidget);

      // rationaleBefore Text widget: maxLines == null, overflow == null (no truncation)
      final RenderParagraph para = tester.renderObject<RenderParagraph>(
        find.text(vm.body!.rationaleBefore),
      );
      expect(para.maxLines, isNull);
      expect(para.overflow, TextOverflow.clip); // default = clip (no ellipsis)

      // link tap
      expect(find.byKey(const Key('j3r-link-decision')), findsOneWidget);
      await tester.tap(find.byKey(const Key('j3r-link-decision')));
      await tester.pump();
      expect(opener.opened, equals(<String>[vm.decisionLink!.deepLink]));

      // repo received correct decisionId
      expect(repo.receivedIds, equals(<String>[vm.decisionId]));
    },
  );

  // ── T21: no_note — draftNote absent, j3r-link-decision absent ─────────────

  testWidgets(
    'T21: no_note fixture — draftNote absent, link absent, journalStateLabel present, retry absent',
    (WidgetTester tester) async {
      final DecisionJournalVm vm = singleFixture(
        FixturePaths.m6JournalReadNoNote,
        DecisionJournalVm.fromJson,
      );

      await _pump(
        tester,
        journalStream: () => Stream<DecisionJournalVm>.value(vm),
        decisionId: vm.decisionId,
      );

      // draftNote header absent (note == null)
      expect(find.text(JournalLabels.draftNote), findsNothing);
      // link absent
      expect(find.byKey(const Key('j3r-link-decision')), findsNothing);
      // positive anchor: journalStateLabel present
      expect(find.text(vm.journalStateLabel), findsOneWidget);
      // retry absent (healthy state)
      expect(find.text(JournalLabels.retry), findsNothing);
    },
  );

  // ── T22: not_written row 0 — body absent, link absent ────────────────────────

  testWidgets(
    'T22: not_written row 0 — journalStateLabel shown, j3r-body absent, link absent',
    (WidgetTester tester) async {
      final DecisionJournalVm vm = listFixture(
        FixturePaths.m6JournalReadNotWritten,
        DecisionJournalVm.fromJson,
      ).rows[0]; // row 0: no body, no decisionLink

      await _pump(
        tester,
        journalStream: () => Stream<DecisionJournalVm>.value(vm),
        decisionId: vm.decisionId,
      );

      // journalStateLabel shown
      expect(find.text(vm.journalStateLabel), findsOneWidget);
      // body absent
      expect(find.byKey(const Key('j3r-body')), findsNothing);
      // link absent
      expect(find.byKey(const Key('j3r-link-decision')), findsNothing);
    },
  );

  // ── T23: staleness — fresh clock = no banner; +2 days = banner ───────────────

  testWidgets(
    'T23: fresh clock — no stale banner; stale clock — stale banner shown',
    (WidgetTester tester) async {
      final DecisionJournalVm vm = singleFixture(
        FixturePaths.m6JournalReadWritten,
        DecisionJournalVm.fromJson,
      );

      // Fresh clock → no banner
      await _pump(
        tester,
        journalStream: () => Stream<DecisionJournalVm>.value(vm),
        decisionId: vm.decisionId,
        clock: FixedClock(kGoldenNowUtc),
      );
      expect(find.text(JournalLabels.staleBannerTitle), findsNothing);

      // Stale clock (+2 days) → banner shown
      await _pump(
        tester,
        journalStream: () => Stream<DecisionJournalVm>.value(vm),
        decisionId: vm.decisionId,
        clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
      );
      expect(find.text(JournalLabels.staleBannerTitle), findsOneWidget);
    },
  );
}
