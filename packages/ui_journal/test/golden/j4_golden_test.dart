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

/// 골든 한 장의 흐름.
class _Flow {
  const _Flow({
    required this.name,
    required this.queue,
    required this.card,
    required this.receipt,
    required this.reveal,
    required this.bottomKey,
  });

  final String name;
  final ListResult<BlindReviewCard> queue;

  /// 처음 내는 카드(null = 카드 없음 · 빈 큐).
  final BlindReviewCard? card;

  /// null = 제출하지 않는다.
  final CommandReceipt? receipt;

  /// 제출 뒤 카드 컨트롤러에 더하는 결과 카드(null = 더하지 않음).
  final BlindReviewCard? reveal;
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

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'j4_before_reveal',
      queue: queue3,
      card: before,
      receipt: null,
      reveal: null,
      bottomKey: 'j4-submit',
    ),
    _Flow(
      name: 'j4_after_reveal',
      queue: queue3,
      card: before,
      receipt: receipts[2],
      reveal: revealed,
      bottomKey: 'j4-next',
    ),
    _Flow(
      name: 'j4_after_reveal_open',
      queue: queueRow1,
      card: queue3.rows[1],
      receipt: receipts[2],
      reveal: revealedOpen,
      bottomKey: 'j4-next',
    ),
    _Flow(
      name: 'j4_waiting',
      queue: queue3,
      card: before,
      receipt: receipts[0],
      reveal: null,
      bottomKey: 'j4-receipt',
    ),
    _Flow(
      name: 'j4_rejected',
      queue: queue3,
      card: before,
      receipt: receipts[4],
      reveal: null,
      bottomKey: 'j4-submit',
    ),
    _Flow(
      name: 'j4_empty',
      queue: queueEmpty,
      card: null,
      receipt: null,
      reveal: null,
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
        final BlindReviewCard? first = flow.card;
        if (first != null) {
          cardCtrl.add(first);
        }
        final CommandReceipt? receipt = flow.receipt;
        final FakeBlindReviewCommandApi commands = FakeBlindReviewCommandApi(
          submit: (BlindReviewScore score, int call) =>
              Future<CommandReceipt>.value(receipt),
          watch: (String commandId) => Stream<CommandReceipt>.value(receipt!),
        );
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
            overrides: blindReviewOverrides(repo: repo, commands: commands),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump();

        if (first != null) {
          await pickBlindReviewAnswers(tester, first, (int i) => 0);
        }
        if (receipt != null) {
          await tester.ensureVisible(find.byKey(const Key('j4-submit')));
          await tester.tap(find.byKey(const Key('j4-submit')));
          await tester.pump();
          await tester.pump();
        }
        final BlindReviewCard? reveal = flow.reveal;
        if (reveal != null) {
          cardCtrl.add(reveal);
          await tester.pump();
          await tester.pump();
        }
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
