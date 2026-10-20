// test/golden/j4_golden_test.dart — J-4 사후 blind 리뷰 골든 (6이름 × light/dark = 12장)
//
// 🔴 --update-goldens 는 이 파일만 지정한다:
//      flutter test --update-goldens test/golden/j4_golden_test.dart

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import '../blind_review_fakes.dart';
import 'golden_support.dart';

const Size _kTallPhone = Size(390, 1600);

/// 골든 한 장의 흐름 — 이름마다 조건 없는 한 덩어리(seed · steps).
class _Flow {
  const _Flow({
    required this.name,
    required this.queue,
    required this.commands,
    required this.seed,
    required this.steps,
    required this.bottomKey,
  });

  final String name;
  final ListResult<BlindReviewCard> queue;

  /// 명령 창구 가짜(제출하지 않는 흐름 = 끝나지 않는 Future).
  final FakeBlindReviewCommandApi Function() commands;

  /// 띄우기 전에 카드 컨트롤러에 넣는 것.
  final void Function(StreamController<BlindReviewCard> cardCtrl) seed;

  /// 띄운 뒤의 선택 · 제출 · 결과.
  final Future<void> Function(
    WidgetTester tester,
    StreamController<BlindReviewCard> cardCtrl,
  )
  steps;
  final String bottomKey;
}

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
  final ListResult<BlindReviewCard> queueRow1 = queue3.copyWith(
    rows: queue3.rows.sublist(1),
  );

  FakeBlindReviewCommandApi commandsOf(CommandReceipt receipt) =>
      FakeBlindReviewCommandApi(
        submit: (BlindReviewScore score, int call) =>
            Future<CommandReceipt>.value(receipt),
        watch: (String commandId) => Stream<CommandReceipt>.value(receipt),
      );

  FakeBlindReviewCommandApi idleCommands() => FakeBlindReviewCommandApi(
    submit: (BlindReviewScore score, int call) =>
        Completer<CommandReceipt>().future,
    watch: (String commandId) => const Stream<CommandReceipt>.empty(),
  );

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('j4-submit')));
    await tester.tap(find.byKey(const Key('j4-submit')));
    await tester.pump();
    await tester.pump();
  }

  Future<void> reveal(
    WidgetTester tester,
    StreamController<BlindReviewCard> cardCtrl,
    BlindReviewCard card,
  ) async {
    cardCtrl.add(card);
    await tester.pump();
    await tester.pump();
  }

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'j4_before_reveal',
      queue: queue3,
      commands: idleCommands,
      seed: (StreamController<BlindReviewCard> c) => c.add(before),
      steps: (WidgetTester tester, StreamController<BlindReviewCard> c) =>
          pickBlindReviewAnswers(tester, before, (int i) => 0),
      bottomKey: 'j4-submit',
    ),
    _Flow(
      name: 'j4_after_reveal',
      queue: queue3,
      commands: () => commandsOf(receipts[2]),
      seed: (StreamController<BlindReviewCard> c) => c.add(before),
      steps: (WidgetTester tester, StreamController<BlindReviewCard> c) async {
        await pickBlindReviewAnswers(tester, before, (int i) => 0);
        await submit(tester);
        await reveal(tester, c, revealed);
      },
      bottomKey: 'j4-next',
    ),
    _Flow(
      name: 'j4_after_reveal_open',
      queue: queueRow1,
      commands: () => commandsOf(receipts[2]),
      seed: (StreamController<BlindReviewCard> c) => c.add(queue3.rows[1]),
      steps: (WidgetTester tester, StreamController<BlindReviewCard> c) async {
        await pickBlindReviewAnswers(tester, queue3.rows[1], (int i) => 0);
        await submit(tester);
        await reveal(tester, c, revealedOpen);
      },
      bottomKey: 'j4-next',
    ),
    _Flow(
      name: 'j4_waiting',
      queue: queue3,
      commands: () => commandsOf(receipts[0]),
      seed: (StreamController<BlindReviewCard> c) => c.add(before),
      steps: (WidgetTester tester, StreamController<BlindReviewCard> c) async {
        await pickBlindReviewAnswers(tester, before, (int i) => 0);
        await submit(tester);
      },
      bottomKey: 'j4-receipt',
    ),
    _Flow(
      name: 'j4_rejected',
      queue: queue3,
      commands: () => commandsOf(receipts[4]),
      seed: (StreamController<BlindReviewCard> c) => c.add(before),
      steps: (WidgetTester tester, StreamController<BlindReviewCard> c) async {
        await pickBlindReviewAnswers(tester, before, (int i) => 0);
        await submit(tester);
      },
      bottomKey: 'j4-submit',
    ),
    _Flow(
      name: 'j4_empty',
      queue: queueEmpty,
      commands: idleCommands,
      seed: (StreamController<BlindReviewCard> c) {},
      steps: (
        WidgetTester tester,
        StreamController<BlindReviewCard> c,
      ) async {},
      bottomKey: 'j4-empty',
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        final StreamController<BlindReviewCard> cardCtrl =
            StreamController<BlindReviewCard>();
        addTearDown(() {
          unawaited(cardCtrl.close());
        });
        flow.seed(cardCtrl);
        final FakeBlindReviewJournalRepository repo =
            FakeBlindReviewJournalRepository(
              queue: (int call) =>
                  Stream<ListResult<BlindReviewCard>>.value(flow.queue),
              card: (String id, int call) => cardCtrl.stream,
            );
        await pumpForGolden(
          tester,
          const JournalBlindReview(),
          brightness: b,
          logicalSize: _kTallPhone,
          wrapApp: (Widget app) => ProviderScope(
            overrides: blindReviewOverrides(
              repo: repo,
              commands: flow.commands(),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump();

        await flow.steps(tester, cardCtrl);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(Key(flow.bottomKey))).dy,
          lessThan(_kTallPhone.height),
        );
        await expectGolden(flow.name, b);
      });
    }
  }
}
