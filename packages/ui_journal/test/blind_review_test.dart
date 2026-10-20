// blind_review_test.dart — J-4 사후 blind 리뷰 위젯 테스트 (T4-01 ~ T4-17).
//
// 🔴 가짜는 blind_review_fakes.dart 의 받침대 extends. 기대 글자는 전부 픽스처에서 온다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/src/common/journal_common.dart';
import 'package:ui_journal/ui_journal.dart';

import 'blind_review_fakes.dart';
import 'golden/golden_support.dart';

/// T4-13 의 갈래 한 줄.
class _Branch {
  const _Branch({
    required this.name,
    required this.queueKind,
    required this.card,
    required this.stale,
    required this.skeleton,
    required this.notice,
    required this.submit,
    required this.next,
    required this.retry,
    required this.banner,
  });

  final String name;

  /// 0 = 값을 내지 않음 · 1 = 에러 · 2 = 빈 큐 · 3 = 큐 3건.
  final int queueKind;

  /// null = 값을 내지 않는 카드 스트림.
  final BlindReviewCard? card;
  final bool stale;
  final bool skeleton;
  final bool notice;
  final bool submit;
  final bool next;
  final bool retry;
  final bool banner;
}

Finder k(String key) => find.byKey(Key(key));

double dyOf(WidgetTester tester, Finder finder) => tester.getTopLeft(finder).dy;

Future<void> pumpTimes(WidgetTester tester, int times) async {
  for (int n = 0; n < times; n++) {
    await tester.pump();
  }
}

Future<void> tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(k('j4-submit'));
  await tester.tap(k('j4-submit'));
  await pumpTimes(tester, 2);
}

FakeBlindReviewCommandApi idleCommands() => FakeBlindReviewCommandApi(
  submit: (BlindReviewScore score, int call) =>
      throw StateError('unexpected submit'),
  watch: (String commandId) => throw StateError('unexpected watch'),
);

FakeBlindReviewCommandApi receiptCommands(CommandReceipt receipt) =>
    FakeBlindReviewCommandApi(
      submit: (BlindReviewScore score, int call) =>
          Future<CommandReceipt>.value(receipt),
      watch: (String commandId) => Stream<CommandReceipt>.value(receipt),
    );

void main() {
  final ListResult<BlindReviewCard> queue3 = listFixture<BlindReviewCard>(
    FixturePaths.m6BlindReviewQueue3,
    BlindReviewCard.fromJson,
  );
  final ListResult<BlindReviewCard> queueEmpty = listFixture<BlindReviewCard>(
    FixturePaths.m6BlindReviewQueueEmpty,
    BlindReviewCard.fromJson,
  );
  final BlindReviewCard before = singleFixture<BlindReviewCard>(
    FixturePaths.m6BlindReviewCardBefore,
    BlindReviewCard.fromJson,
  );
  final BlindReviewCard revealed = singleFixture<BlindReviewCard>(
    FixturePaths.m6BlindReviewCardRevealed,
    BlindReviewCard.fromJson,
  );
  final BlindReviewCard revealedOpen = singleFixture<BlindReviewCard>(
    FixturePaths.m6BlindReviewCardRevealedOpen,
    BlindReviewCard.fromJson,
  );
  final List<CommandReceipt> receipts = listFixture<CommandReceipt>(
    FixturePaths.m6BlindReviewReceipts6,
    CommandReceipt.fromJson,
  ).rows;

  Stream<CommandReceipt> receiptThenFail(CommandReceipt r) async* {
    yield r;
    throw StateError('watch');
  }

  Stream<BlindReviewCard> cardThenFail(BlindReviewCard c) async* {
    yield c;
    throw StateError('card');
  }

  ListResult<BlindReviewCard> queueFrom(int start) =>
      queue3.copyWith(rows: queue3.rows.sublist(start));

  final RegExp money = RegExp(
    r'\d[\d,.]*\s*(\uC5B5|\uB9CC|\uCC9C)?\s*\uC6D0|\u20A9',
  );
  final RegExp percent = RegExp(r'\d+(\.\d+)?\s*%');
  final RegExp pnlWords = RegExp(
    r'\uC190\uC775|\uC218\uC775|\uD3C9\uAC00\uC561',
  );

  FakeBlindReviewJournalRepository repoOf({
    required ListResult<BlindReviewCard> queue,
    required BlindReviewCard card,
  }) => FakeBlindReviewJournalRepository(
    queue: (int call) => Stream<ListResult<BlindReviewCard>>.value(queue),
    card: (String id, int call) => Stream<BlindReviewCard>.value(card),
  );

  // ── T4-01 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-01 queue head is pinned', (WidgetTester tester) async {
    final StreamController<ListResult<BlindReviewCard>> ctrl =
        StreamController<ListResult<BlindReviewCard>>();
    addTearDown(() {
      unawaited(ctrl.close());
    });
    final FakeBlindReviewJournalRepository repo =
        FakeBlindReviewJournalRepository(
          queue: (int call) => ctrl.stream,
          card: (String id, int call) => Stream<BlindReviewCard>.value(before),
        );
    final FakeBlindReviewCommandApi commands = idleCommands();
    await pumpBlindReview(tester, repo: repo, commands: commands);
    ctrl.add(queue3);
    await pumpTimes(tester, 3);

    expect(repo.queueModes, <RunMode>[RunMode.live]);
    expect(repo.cardCalls, <String>[queue3.rows[0].decisionId]);
    expect(tester.widget<Text>(k('j4-title')).data, before.titleText);
    expect(tester.widget<Text>(k('j4-prompt')).data, before.promptText);
    expect(
      tester.widget<Text>(k('j4-notice')).data,
      JournalLabels.blindReviewNotice,
    );
    expect(
      find.ancestor(of: k('j4-notice'), matching: find.byType(Scrollable)),
      findsNothing,
    );
    expect(
      find.ancestor(of: k('j4-title'), matching: find.byType(Scrollable)),
      findsOneWidget,
    );

    expect(queue3.rows[1].titleText, isNot(queue3.rows[0].titleText));
    ctrl.add(queueFrom(1));
    await pumpTimes(tester, 2);

    expect(repo.cardCalls, <String>[queue3.rows[0].decisionId]);
    expect(tester.widget<Text>(k('j4-title')).data, before.titleText);
    expect(find.text(queue3.rows[1].titleText), findsNothing);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-02 ───────────────────────────────────────────────────────────────────
  for (final (String caseName, ListResult<BlindReviewCard> v, bool shown)
      in <(String, ListResult<BlindReviewCard>, bool)>[
        ('no_data', queueEmpty, true),
        (
          'not_applicable',
          queueEmpty.copyWith(emptyKind: EmptyKind.notApplicable),
          true,
        ),
        (
          'not_loaded',
          queueEmpty.copyWith(emptyKind: EmptyKind.notLoaded),
          false,
        ),
      ]) {
    testWidgets('T4-02 empty queue $caseName', (WidgetTester tester) async {
      final FakeBlindReviewJournalRepository repo =
          FakeBlindReviewJournalRepository(
            queue: (int call) => Stream<ListResult<BlindReviewCard>>.value(v),
            card: (String id, int call) =>
                const Stream<BlindReviewCard>.empty(),
          );
      await pumpBlindReview(tester, repo: repo, commands: idleCommands());
      await pumpTimes(tester, 2);

      if (shown) {
        expect(v.emptyLabel, isNotNull);
        expect(tester.widget<Text>(k('j4-empty')).data, v.emptyLabel);
      } else {
        expect(v.asOf.staleLabel, isNull);
        expect(k('j4-empty'), findsNothing);
        expect(find.text(queueEmpty.emptyLabel!), findsNothing);
      }
      expect(k('j4-asof'), findsOneWidget);
      expect(find.text(v.asOf.label), findsOneWidget);
      expect(k('j4-notice'), findsNothing);
      expect(k('j4-submit'), findsNothing);
      expect(k('j4-next'), findsNothing);
      expect(repo.cardCalls, isEmpty);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-03 ───────────────────────────────────────────────────────────────────
  for (final int row in <int>[0, 1, 2]) {
    testWidgets('T4-03 card body row$row', (WidgetTester tester) async {
      final BlindReviewCard c = queue3.rows[row];
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpBlindReview(
        tester,
        repo: repoOf(queue: queueFrom(row), card: c),
        commands: idleCommands(),
        opener: opener,
      );
      await pumpTimes(tester, 2);

      expect(tester.widget<Text>(k('j4-title')).data, c.titleText);
      expect(tester.widget<Text>(k('j4-prompt')).data, c.promptText);
      expect(tester.widget<Text>(k('j4-deviation')).data, c.deviation.label);
      expect(
        tester.widget<Text>(k('j4-journal-state')).data,
        c.journalStateLabel,
      );

      expect(c.contextChips, hasLength(1));
      for (final (int i, ReasonChip chip) in c.contextChips.indexed) {
        expect(
          find.descendant(of: k('j4-chip-$i'), matching: find.text(chip.label)),
          findsOneWidget,
        );
      }
      expect(k('j4-chip-${c.contextChips.length}'), findsNothing);

      expect(c.journal, isNotNull);
      final DecisionJournalBody body = c.journal!;
      for (final String text in <String>[
        body.writtenAtText,
        body.ruleCitedLabel,
        body.rationaleBefore,
        body.expectedOutcome,
      ]) {
        expect(
          find.descendant(of: k('j4-journal-body'), matching: find.text(text)),
          findsOneWidget,
        );
      }
      final Text rationale = tester.widget<Text>(
        find.text(body.rationaleBefore),
      );
      expect(rationale.maxLines, isNull);
      expect(rationale.overflow, isNull);
      if (body.note != null) {
        expect(find.text(body.note!), findsOneWidget);
        expect(find.text(JournalLabels.draftNote), findsOneWidget);
      } else {
        expect(find.text(JournalLabels.draftNote), findsNothing);
      }

      expect(c.questions, hasLength(5));
      for (final (int i, BlindReviewQuestion q) in c.questions.indexed) {
        expect(
          find.descendant(of: k('j4-question-$i'), matching: find.text(q.text)),
          findsOneWidget,
        );
        if (q.evidenceText != null) {
          expect(tester.widget<Text>(k('j4-evidence-$i')).data, q.evidenceText);
        } else {
          expect(k('j4-evidence-$i'), findsNothing);
        }
        expect(q.choices, hasLength(2));
        for (final (int j, BlindReviewChoice choice) in q.choices.indexed) {
          final ChoiceChip chip = tester.widget<ChoiceChip>(
            k('j4-choice-$i-$j'),
          );
          expect((chip.label as Text).data, choice.label);
          expect(chip.selected, isFalse);
          expect(find.text('${choice.score}'), findsNothing);
        }
      }

      final List<Finder> chain = <Finder>[
        k('j4-notice'),
        k('j4-asof'),
        k('j4-title'),
        k('j4-prompt'),
        k('j4-chip-0'),
        k('j4-deviation'),
        k('j4-journal-state'),
        k('j4-journal-body'),
        for (final (int i, BlindReviewQuestion _) in c.questions.indexed)
          k('j4-question-$i'),
        k('j4-submit'),
      ];
      for (int n = 1; n < chain.length; n++) {
        expect(dyOf(tester, chain[n - 1]), lessThan(dyOf(tester, chain[n])));
      }

      await tester.tap(k('j4-chip-0'));
      await tester.pump();
      expect(c.contextChips[0].detailDeepLink, isNotNull);
      expect(opener.opened, <String>[c.contextChips[0].detailDeepLink!]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-04 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-04 submit gate arguments double tap', (
    WidgetTester tester,
  ) async {
    final Completer<CommandReceipt> completer = Completer<CommandReceipt>();
    final FakeBlindReviewCommandApi commands = FakeBlindReviewCommandApi(
      submit: (BlindReviewScore score, int call) => completer.future,
      watch: (String commandId) => receiptThenFail(receipts[0]),
    );
    await pumpBlindReview(
      tester,
      repo: repoOf(queue: queue3, card: before),
      commands: commands,
    );
    await pumpTimes(tester, 2);

    expect(tester.widget<FilledButton>(k('j4-submit')).onPressed, isNull);
    final int lastIndex = before.questions.length - 1;
    for (final (int i, BlindReviewQuestion _) in before.questions.indexed) {
      final Finder chip = k('j4-choice-$i-${i % 2}');
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
      expect(
        tester.widget<FilledButton>(k('j4-submit')).onPressed,
        i == lastIndex ? isNotNull : isNull,
      );
    }

    final BlindReviewScore expected = BlindReviewScore(
      decisionId: before.decisionId,
      answers: <String, int>{
        for (final (int i, BlindReviewQuestion q) in before.questions.indexed)
          q.questionId: q.choices[i % 2].score,
      },
    );
    await tapSubmit(tester);
    expect(commands.submitted, <BlindReviewScore>[expected]);
    expect(k('j4-submit'), findsOneWidget);
    expect(tester.widget<FilledButton>(k('j4-submit')).onPressed, isNull);
    expectBlindReviewChoicesLocked(tester, locked: true);

    await tester.tap(k('j4-submit'), warnIfMissed: false);
    await pumpTimes(tester, 2);
    expect(commands.submitted, <BlindReviewScore>[expected]);

    completer.complete(receipts[0]);
    await pumpTimes(tester, 3);
    expect(tester.widget<Text>(k('j4-receipt')).data, receipts[0].stateLabel);
    expect(k('j4-submit'), findsNothing);
    expect(commands.watched, <String>[receipts[0].commandId]);
    expect(k('j4-fail'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-05 ───────────────────────────────────────────────────────────────────
  for (final (
        String caseName,
        int row,
        CommandState state,
        bool locks,
        bool stateOnly,
      )
      in <(String, int, CommandState, bool, bool)>[
        ('requested', 0, CommandState.requested, true, false),
        ('held', 1, CommandState.heldForIntegrity, true, false),
        ('executed', 2, CommandState.executed, true, false),
        ('expired', 3, CommandState.expired, false, false),
        ('rejected_invalid', 4, CommandState.rejected, false, false),
        ('rejected_already', 5, CommandState.rejected, false, false),
        ('received', 0, CommandState.received, true, true),
        ('stale_context', 0, CommandState.staleContext, true, true),
        ('pending_lease', 0, CommandState.pendingLeaseConfirm, true, true),
        ('no_operator', 0, CommandState.noOperator, true, true),
      ]) {
    testWidgets('T4-05 receipt $caseName', (WidgetTester tester) async {
      expect(receipts, hasLength(6));
      expect(receipts[row].state, stateOnly ? CommandState.requested : state);
      final CommandReceipt receipt = stateOnly
          ? receipts[row].copyWith(state: state)
          : receipts[row];
      await pumpBlindReview(
        tester,
        repo: repoOf(queue: queue3, card: before),
        commands: receiptCommands(receipt),
      );
      await pumpTimes(tester, 2);
      await pickBlindReviewAnswers(tester, before, (int i) => 0);
      await tapSubmit(tester);

      expect(tester.widget<Text>(k('j4-receipt')).data, receipt.stateLabel);
      expect(k('j4-result'), findsNothing);
      expect(k('j4-next'), findsNothing);
      if (locks) {
        expect(k('j4-submit'), findsNothing);
        expectBlindReviewChoicesLocked(tester, locked: true);
      } else {
        expect(k('j4-submit'), findsOneWidget);
        expect(
          tester.widget<FilledButton>(k('j4-submit')).onPressed,
          isNotNull,
        );
        expectBlindReviewChoicesLocked(tester, locked: false);
      }
      expect(blindReviewPickedKeys(tester), <String>[
        for (final (int i, BlindReviewQuestion _) in before.questions.indexed)
          'j4-choice-$i-0',
      ]);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-06 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-06 submit future error keeps input', (
    WidgetTester tester,
  ) async {
    expect(receipts[3].state, CommandState.expired);
    final StreamController<BlindReviewCard> cardCtrl =
        StreamController<BlindReviewCard>();
    addTearDown(() {
      unawaited(cardCtrl.close());
    });
    cardCtrl.add(before);
    final FakeBlindReviewCommandApi commands = FakeBlindReviewCommandApi(
      submit: (BlindReviewScore score, int call) => call == 1
          ? Future<CommandReceipt>.value(receipts[3])
          : Future<CommandReceipt>.error(StateError('offline')),
      watch: (String commandId) => Stream<CommandReceipt>.value(receipts[3]),
    );
    await pumpBlindReview(
      tester,
      repo: FakeBlindReviewJournalRepository(
        queue: (int call) => Stream<ListResult<BlindReviewCard>>.value(queue3),
        card: (String id, int call) => cardCtrl.stream,
      ),
      commands: commands,
    );
    await pumpTimes(tester, 3);
    await pickBlindReviewAnswers(tester, before, (int i) => i % 2);
    final BlindReviewScore expected = BlindReviewScore(
      decisionId: before.decisionId,
      answers: <String, int>{
        for (final (int i, BlindReviewQuestion q) in before.questions.indexed)
          q.questionId: q.choices[i % 2].score,
      },
    );
    final List<String> pickedKeys = <String>[
      for (final (int i, BlindReviewQuestion _) in before.questions.indexed)
        'j4-choice-$i-${i % 2}',
    ];

    await tapSubmit(tester);
    expect(
      tester.widget<Text>(k('j4-submit-not-accepted')).data,
      JournalLabels.submitNotAccepted,
    );
    expect(tester.widget<FilledButton>(k('j4-submit')).onPressed, isNotNull);
    expectBlindReviewChoicesLocked(tester, locked: false);
    expect(blindReviewPickedKeys(tester), pickedKeys);
    expect(k('j4-receipt'), findsNothing);
    expect(commands.watched, isEmpty);

    await tapSubmit(tester);
    expect(commands.submitted, <BlindReviewScore>[expected, expected]);
    expect(k('j4-submit-not-accepted'), findsNothing);
    expect(tester.widget<Text>(k('j4-receipt')).data, receipts[3].stateLabel);

    await tapSubmit(tester);
    expect(k('j4-submit-not-accepted'), findsOneWidget);

    cardCtrl.add(revealed);
    await pumpTimes(tester, 2);
    expect(k('j4-submit-not-accepted'), findsNothing);
    expect(k('j4-result'), findsOneWidget);
    expect(k('j4-next'), findsOneWidget);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-07 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-07 result arrives after execution', (
    WidgetTester tester,
  ) async {
    final StreamController<BlindReviewCard> cardCtrl =
        StreamController<BlindReviewCard>();
    addTearDown(() {
      unawaited(cardCtrl.close());
    });
    cardCtrl.add(before);
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeBlindReviewJournalRepository repo =
        FakeBlindReviewJournalRepository(
          queue: (int call) =>
              Stream<ListResult<BlindReviewCard>>.value(queue3),
          card: (String id, int call) => cardCtrl.stream,
        );
    await pumpBlindReview(
      tester,
      repo: repo,
      commands: receiptCommands(receipts[2]),
      opener: opener,
    );
    await pumpTimes(tester, 3);
    await pickBlindReviewAnswers(tester, before, (int i) => 0);
    await tapSubmit(tester);

    expect(tester.widget<Text>(k('j4-receipt')).data, receipts[2].stateLabel);
    expect(k('j4-result'), findsNothing);
    expect(k('j4-next'), findsNothing);
    expect(k('j4-submit'), findsNothing);
    expectBlindReviewChoicesLocked(tester, locked: true);

    cardCtrl.add(revealed);
    await pumpTimes(tester, 2);

    expect(revealed.result, isNotNull);
    final BlindReviewResult r = revealed.result!;
    expect(
      find.descendant(
        of: k('j4-result'),
        matching: find.text(r.processScoreText),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: k('j4-result'), matching: find.text(r.outcomeText)),
      findsOneWidget,
    );
    expect(r.detailLines, hasLength(1));
    for (final (int n, String line) in r.detailLines.indexed) {
      expect(tester.widget<Text>(k('j4-result-line-$n')).data, line);
    }
    expect(k('j4-result-line-1'), findsNothing);
    expect(r.decisionLink, isNotNull);
    expect(
      find.descendant(
        of: k('j4-link-decisionLink'),
        matching: find.text(r.decisionLink!.label),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(k('j4-link-decisionLink'));
    await tester.tap(k('j4-link-decisionLink'));
    await tester.pump();
    expect(opener.opened, <String>[r.decisionLink!.deepLink]);

    expect(
      tester
          .widget<Text>(
            find.descendant(of: k('j4-next'), matching: find.byType(Text)),
          )
          .data,
      JournalLabels.blindReviewNext,
    );
    expect(k('j4-submit'), findsNothing);
    expectBlindReviewChoicesLocked(tester, locked: true);
    expect(blindReviewPickedKeys(tester), <String>[
      for (final (int i, BlindReviewQuestion _) in before.questions.indexed)
        'j4-choice-$i-0',
    ]);
    expect(repo.cardCalls, <String>[before.decisionId]);
    expect(
      dyOf(tester, k('j4-receipt')),
      lessThan(dyOf(tester, k('j4-result'))),
    );
    expect(dyOf(tester, k('j4-result')), lessThan(dyOf(tester, k('j4-next'))));

    final Finder resultTexts = find.descendant(
      of: k('j4-result'),
      matching: find.byType(Text),
    );
    expect(
      tester.widgetList<Text>(resultTexts).map((Text t) => t.data).toList(),
      <String?>[
        r.processScoreText,
        r.outcomeText,
        ...r.detailLines,
        r.decisionLink!.label,
      ],
    );

    cardCtrl.add(revealed.copyWith(result: r.copyWith(decisionLink: null)));
    await pumpTimes(tester, 2);
    expect(k('j4-link-decisionLink'), findsNothing);
    expect(
      tester.widgetList<Text>(resultTexts).map((Text t) => t.data).toList(),
      <String?>[r.processScoreText, r.outcomeText, ...r.detailLines],
    );
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-08 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-08 already revealed without journal', (
    WidgetTester tester,
  ) async {
    expect(revealedOpen.journal, isNotNull);
    expect(revealedOpen.decisionId, queue3.rows[1].decisionId);
    expect(revealedOpen.result, isNotNull);
    final BlindReviewResult r = revealedOpen.result!;
    await pumpBlindReview(
      tester,
      repo: repoOf(
        queue: queueFrom(1),
        card: revealedOpen.copyWith(journal: null),
      ),
      commands: idleCommands(),
    );
    await pumpTimes(tester, 2);

    expect(
      tester.widget<Text>(k('j4-journal-state')).data,
      revealedOpen.journalStateLabel,
    );
    expect(k('j4-journal-body'), findsNothing);
    expect(find.text(JournalLabels.draftRuleCited), findsNothing);
    expect(find.text(JournalLabels.draftRationale), findsNothing);
    expect(find.text(JournalLabels.draftExpected), findsNothing);
    expect(
      find.descendant(
        of: k('j4-result'),
        matching: find.text(r.processScoreText),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: k('j4-result'), matching: find.text(r.outcomeText)),
      findsOneWidget,
    );
    expect(r.detailLines, hasLength(0));
    expect(k('j4-result-line-0'), findsNothing);
    expect(k('j4-submit'), findsNothing);
    expect(k('j4-receipt'), findsNothing);
    expect(k('j4-next'), findsOneWidget);
    expectBlindReviewChoicesLocked(tester, locked: true);
    expect(blindReviewPickedKeys(tester), isEmpty);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-09 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-09 result wins over already scored rejection', (
    WidgetTester tester,
  ) async {
    final StreamController<BlindReviewCard> cardCtrl =
        StreamController<BlindReviewCard>();
    addTearDown(() {
      unawaited(cardCtrl.close());
    });
    cardCtrl.add(before);
    expect(receipts[5].state, CommandState.rejected);
    await pumpBlindReview(
      tester,
      repo: FakeBlindReviewJournalRepository(
        queue: (int call) => Stream<ListResult<BlindReviewCard>>.value(queue3),
        card: (String id, int call) => cardCtrl.stream,
      ),
      commands: receiptCommands(receipts[5]),
    );
    await pumpTimes(tester, 3);
    await pickBlindReviewAnswers(tester, before, (int i) => 0);
    await tapSubmit(tester);
    expect(k('j4-submit'), findsOneWidget);

    cardCtrl.add(revealed);
    await pumpTimes(tester, 2);
    expect(k('j4-result'), findsOneWidget);
    expect(k('j4-submit'), findsNothing);
    expect(tester.widget<Text>(k('j4-receipt')).data, receipts[5].stateLabel);
    expect(k('j4-next'), findsOneWidget);
    expectBlindReviewChoicesLocked(tester, locked: true);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-10 ───────────────────────────────────────────────────────────────────
  for (final (String caseName, bool toEmpty) in <(String, bool)>[
    ('next_row', false),
    ('next_empty', true),
  ]) {
    testWidgets('T4-10 next card $caseName', (WidgetTester tester) async {
      final StreamController<ListResult<BlindReviewCard>> queueCtrl =
          StreamController<ListResult<BlindReviewCard>>();
      final StreamController<BlindReviewCard> cardCtrl =
          StreamController<BlindReviewCard>();
      final StreamController<CommandReceipt> watchCtrl =
          StreamController<CommandReceipt>.broadcast();
      addTearDown(() {
        unawaited(queueCtrl.close());
      });
      addTearDown(() {
        unawaited(cardCtrl.close());
      });
      addTearDown(() {
        unawaited(watchCtrl.close());
      });
      final Map<String, BlindReviewCard> byId = <String, BlindReviewCard>{
        for (final BlindReviewCard c in queue3.rows) c.decisionId: c,
      };
      final FakeBlindReviewJournalRepository repo =
          FakeBlindReviewJournalRepository(
            queue: (int call) => queueCtrl.stream,
            card: (String id, int call) => id == queue3.rows[0].decisionId
                ? cardCtrl.stream
                : Stream<BlindReviewCard>.value(byId[id]!),
          );
      final FakeBlindReviewCommandApi commands = FakeBlindReviewCommandApi(
        submit: (BlindReviewScore score, int call) =>
            Future<CommandReceipt>.value(receipts[2]),
        watch: (String commandId) => watchCtrl.stream,
      );
      await pumpBlindReview(tester, repo: repo, commands: commands);
      queueCtrl.add(queue3);
      cardCtrl.add(before);
      await pumpTimes(tester, 3);
      await pickBlindReviewAnswers(tester, before, (int i) => 0);
      await tapSubmit(tester);
      cardCtrl.add(revealed);
      await pumpTimes(tester, 2);

      expect(k('j4-next'), findsOneWidget);
      expect(blindReviewPickedKeys(tester), isNotEmpty);
      expect(k('j4-receipt'), findsOneWidget);

      queueCtrl.add(toEmpty ? queueEmpty : queueFrom(1));
      await pumpTimes(tester, 2);
      expect(tester.widget<Text>(k('j4-title')).data, before.titleText);

      await tester.ensureVisible(k('j4-next'));
      await tester.tap(k('j4-next'));
      await pumpTimes(tester, 2);
      watchCtrl.add(receipts[0]);
      await pumpTimes(tester, 2);

      if (toEmpty) {
        expect(tester.widget<Text>(k('j4-empty')).data, queueEmpty.emptyLabel);
        expect(repo.cardCalls, <String>[queue3.rows[0].decisionId]);
        expect(k('j4-notice'), findsNothing);
        expect(k('j4-title'), findsNothing);
      } else {
        expect(repo.cardCalls, <String>[
          queue3.rows[0].decisionId,
          queue3.rows[1].decisionId,
        ]);
        expect(
          tester.widget<Text>(k('j4-title')).data,
          queue3.rows[1].titleText,
        );
        expect(k('j4-result'), findsNothing);
        expect(k('j4-next'), findsNothing);
        expect(k('j4-receipt'), findsNothing);
        expect(k('j4-submit'), findsOneWidget);
        expect(tester.widget<FilledButton>(k('j4-submit')).onPressed, isNull);
        expect(blindReviewPickedKeys(tester), isEmpty);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-11 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-11 leaving saves nothing', (WidgetTester tester) async {
    final FakeBlindReviewCommandApi commands = idleCommands();
    await pumpBlindReview(
      tester,
      repo: repoOf(queue: queue3, card: before),
      commands: commands,
    );
    await pumpTimes(tester, 2);
    await pickBlindReviewAnswers(tester, before, (int i) => 0);
    await tester.pumpWidget(const SizedBox());
    expect(commands.submitted, isEmpty);
    expect(commands.watched, isEmpty);
  });

  // ── T4-12 ───────────────────────────────────────────────────────────────────
  for (final int row in <int>[0, 1, 2]) {
    testWidgets('T4-12 texts before reveal row$row', (
      WidgetTester tester,
    ) async {
      final BlindReviewCard c = queue3.rows[row];
      expect(c.journal, isNotNull);
      final DecisionJournalBody body = c.journal!;
      await pumpBlindReview(
        tester,
        repo: repoOf(queue: queueFrom(row), card: c),
        commands: idleCommands(),
      );
      await pumpTimes(tester, 2);

      final Set<String> allowed = <String>{
        JournalLabels.blindReviewNotice,
        c.asOf.label,
        c.titleText,
        c.promptText,
        for (final ReasonChip chip in c.contextChips) chip.label,
        c.deviation.label,
        c.journalStateLabel,
        body.writtenAtText,
        JournalLabels.draftRuleCited,
        body.ruleCitedLabel,
        JournalLabels.draftRationale,
        body.rationaleBefore,
        JournalLabels.draftExpected,
        body.expectedOutcome,
        ?(body.note == null ? null : JournalLabels.draftNote),
        ?body.note,
        for (final BlindReviewQuestion q in c.questions) ...<String>[
          q.text,
          ?q.evidenceText,
          for (final BlindReviewChoice choice in q.choices) choice.label,
        ],
        JournalLabels.draftSubmit,
      };
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
        expect(money.hasMatch(data!), isFalse);
        expect(percent.hasMatch(data), isFalse);
        expect(pnlWords.hasMatch(data), isFalse);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-13 ───────────────────────────────────────────────────────────────────
  final SafetyState blockedSafety = safetyFixtureRow(3);
  for (final _Branch b in <_Branch>[
    const _Branch(
      name: 'skeleton',
      queueKind: 0,
      card: null,
      stale: false,
      skeleton: true,
      notice: false,
      submit: false,
      next: false,
      retry: false,
      banner: false,
    ),
    const _Branch(
      name: 'card_skeleton',
      queueKind: 3,
      card: null,
      stale: false,
      skeleton: true,
      notice: false,
      submit: false,
      next: false,
      retry: false,
      banner: false,
    ),
    const _Branch(
      name: 'fail',
      queueKind: 1,
      card: null,
      stale: false,
      skeleton: false,
      notice: false,
      submit: false,
      next: false,
      retry: true,
      banner: false,
    ),
    const _Branch(
      name: 'empty',
      queueKind: 2,
      card: null,
      stale: false,
      skeleton: false,
      notice: false,
      submit: false,
      next: false,
      retry: false,
      banner: true,
    ),
    _Branch(
      name: 'card',
      queueKind: 3,
      card: before,
      stale: false,
      skeleton: false,
      notice: true,
      submit: true,
      next: false,
      retry: false,
      banner: true,
    ),
    _Branch(
      name: 'card_stale',
      queueKind: 3,
      card: before,
      stale: true,
      skeleton: false,
      notice: true,
      submit: true,
      next: false,
      retry: false,
      banner: true,
    ),
    _Branch(
      name: 'result',
      queueKind: 3,
      card: revealed,
      stale: false,
      skeleton: false,
      notice: true,
      submit: false,
      next: true,
      retry: false,
      banner: true,
    ),
  ]) {
    testWidgets('T4-13 static texts ${b.name}', (WidgetTester tester) async {
      final StreamController<ListResult<BlindReviewCard>> silentQueue =
          StreamController<ListResult<BlindReviewCard>>();
      final StreamController<BlindReviewCard> silentCard =
          StreamController<BlindReviewCard>();
      addTearDown(() {
        unawaited(silentQueue.close());
      });
      addTearDown(() {
        unawaited(silentCard.close());
      });
      final BlindReviewCard? cardValue = b.card;
      final FakeBlindReviewJournalRepository repo =
          FakeBlindReviewJournalRepository(
            queue: (int call) => b.queueKind == 0
                ? silentQueue.stream
                : b.queueKind == 1
                ? Stream<ListResult<BlindReviewCard>>.error(StateError('queue'))
                : Stream<ListResult<BlindReviewCard>>.value(
                    b.queueKind == 2 ? queueEmpty : queue3,
                  ),
            card: (String id, int call) => cardValue == null
                ? silentCard.stream
                : Stream<BlindReviewCard>.value(cardValue),
          );
      await pumpBlindReview(
        tester,
        repo: repo,
        commands: idleCommands(),
        safety: blockedSafety,
        clock: b.stale
            ? FixedClock(kGoldenNowUtc.add(const Duration(days: 2)))
            : null,
      );
      await pumpTimes(tester, 3);

      expect(k('j4-loading'), b.skeleton ? findsOneWidget : findsNothing);
      expect(
        find.text(JournalLabels.blindReviewNotice),
        b.notice ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.draftSubmit),
        b.submit ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.blindReviewNext),
        b.next ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.retry),
        b.retry ? findsOneWidget : findsNothing,
      );
      expect(
        find.text(JournalLabels.staleBannerTitle),
        b.stale ? findsOneWidget : findsNothing,
      );
      expect(blockedSafety.activeFlags, isNotEmpty);
      for (final BlockFlag f in blockedSafety.activeFlags) {
        expect(find.text(f.label), b.banner ? findsOneWidget : findsNothing);
      }
      expect(find.text(JournalLabels.submitNotAccepted), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  }

  // ── T4-14 ───────────────────────────────────────────────────────────────────
  for (final (String caseName, int row, int flagCount, int blockingIcons)
      in <(String, int, int, int)>[
        ('row0', 0, 0, 0),
        ('row1', 1, 1, 0),
        ('row3', 3, 2, 2),
        ('row4', 4, 1, 1),
      ]) {
    testWidgets('T4-14 banners $caseName', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpBlindReview(
        tester,
        repo: repoOf(queue: queue3, card: before),
        commands: idleCommands(),
        safety: safetyFixtureRow(row),
        opener: opener,
      );
      await pumpTimes(tester, 3);

      final List<BlockFlag> flags = safetyFixtureRow(row).activeFlags;
      expect(flags, hasLength(flagCount));
      for (final BlockFlag f in flags) {
        expect(find.text(f.label), findsOneWidget);
      }
      expect(
        find.byIcon(Icons.warning_amber_rounded),
        findsNWidgets(blockingIcons),
      );
      expectBlindReviewChoicesLocked(tester, locked: false);
      if (flags.isNotEmpty) {
        expect(
          dyOf(tester, k('j4-prompt')),
          lessThan(dyOf(tester, find.text(flags.first.label))),
        );
        expect(
          dyOf(tester, find.text(flags.first.label)),
          lessThan(dyOf(tester, k('j4-chip-0'))),
        );
      } else {
        expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      }
      if (row == 4) {
        expect(flags.single.clearDeepLink, isNotNull);
        await tester.tap(find.byIcon(Icons.arrow_forward_ios));
        await tester.pump();
        expect(opener.opened, <String>[flags.single.clearDeepLink!]);
      } else {
        expect(opener.opened, isEmpty);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-15 ───────────────────────────────────────────────────────────────────
  for (final (String caseName, int kind, String? wantLabel)
      in <(String, int, String?)>[
        ('queue_fail', 0, null),
        ('card_fail', 1, null),
        ('card_value_then_fail', 2, before.asOf.label),
      ]) {
    testWidgets('T4-15 error and retry $caseName', (WidgetTester tester) async {
      final FakeBlindReviewJournalRepository repo =
          FakeBlindReviewJournalRepository(
            queue: (int call) => kind == 0 && call == 0
                ? Stream<ListResult<BlindReviewCard>>.error(StateError('queue'))
                : Stream<ListResult<BlindReviewCard>>.value(queue3),
            card: (String id, int call) => kind == 1 && call == 0
                ? Stream<BlindReviewCard>.error(StateError('card'))
                : kind == 2 && call == 0
                ? cardThenFail(before)
                : Stream<BlindReviewCard>.value(before),
          );
      await pumpBlindReview(
        tester,
        repo: repo,
        commands: idleCommands(),
        safety: blockedSafety,
      );
      await pumpTimes(tester, 3);

      expect(k('j4-fail'), findsOneWidget);
      expect(
        tester
            .widget<JournalErrorView>(find.byType(JournalErrorView))
            .lastAsOfLabel,
        wantLabel,
      );
      expect(k('j4-notice'), findsNothing);
      expect(blockedSafety.activeFlags, isNotEmpty);
      for (final BlockFlag f in blockedSafety.activeFlags) {
        expect(find.text(f.label), findsNothing);
      }

      await tester.tap(find.text(JournalLabels.retry));
      await pumpTimes(tester, 3);

      expect(tester.widget<Text>(k('j4-title')).data, before.titleText);
      for (final BlockFlag f in blockedSafety.activeFlags) {
        expect(find.text(f.label), findsOneWidget);
      }
      if (kind == 0) {
        expect(repo.queueModes, <RunMode>[RunMode.live, RunMode.live]);
      } else {
        expect(repo.cardCalls, <String>[
          queue3.rows[0].decisionId,
          queue3.rows[0].decisionId,
        ]);
      }
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }

  // ── T4-16 ───────────────────────────────────────────────────────────────────
  testWidgets('T4-16 widget tree before and after reveal', (
    WidgetTester tester,
  ) async {
    final StreamController<BlindReviewCard> cardCtrl =
        StreamController<BlindReviewCard>();
    addTearDown(() {
      unawaited(cardCtrl.close());
    });
    cardCtrl.add(before);
    await pumpBlindReview(
      tester,
      repo: FakeBlindReviewJournalRepository(
        queue: (int call) => Stream<ListResult<BlindReviewCard>>.value(queue3),
        card: (String id, int call) => cardCtrl.stream,
      ),
      commands: receiptCommands(receipts[2]),
    );
    await pumpTimes(tester, 3);
    await pickBlindReviewAnswers(tester, before, (int i) => 0);

    final List<String?> beforeTexts = blindReviewTextsOutsideBottom(tester);
    expect(beforeTexts, isNotEmpty);
    final List<String> beforeKeys = blindReviewPickedKeys(tester);
    expect(k('j4-submit'), findsOneWidget);
    expect(k('j4-result'), findsNothing);
    expect(k('j4-next'), findsNothing);

    await tapSubmit(tester);
    cardCtrl.add(revealed);
    await pumpTimes(tester, 2);

    expect(blindReviewTextsOutsideBottom(tester), beforeTexts);
    expect(blindReviewPickedKeys(tester), beforeKeys);
    expect(k('j4-submit'), findsNothing);
    expect(k('j4-result'), findsOneWidget);
    expect(k('j4-next'), findsOneWidget);
    expectBlindReviewChoicesLocked(tester, locked: true);
    expect(find.text(JournalLabels.retry), findsNothing);
  });

  // ── T4-17 ───────────────────────────────────────────────────────────────────
  for (final (String caseName, BlindReviewCard card)
      in <(String, BlindReviewCard)>[
        ('before', before),
        ('revealed', revealed),
      ]) {
    testWidgets('T4-17 large font $caseName', (WidgetTester tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpBlindReview(
        tester,
        repo: repoOf(queue: queue3, card: card),
        commands: idleCommands(),
      );
      await pumpTimes(tester, 3);

      expect(tester.takeException(), isNull);
      expect(k('j4-title'), findsOneWidget);
      expect(find.text(JournalLabels.retry), findsNothing);
    });
  }
}
