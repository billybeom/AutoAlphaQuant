// blind_review_fakes.dart — J-4 위젯 테스트·골든 공용 가짜와 도우미.
//
// 🔴 가짜는 전부 testing.dart 받침대를 extends 한다 — 화면이 부르면 안 되는 창구는
//    받침대가 던져서 테스트가 실패한다. 한국어 리터럴 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';

/// J-4 읽기 창구 가짜 — 큐·카드 두 창구만 연다. 받은 인자를 호출마다 기록한다.
class FakeBlindReviewJournalRepository extends UnimplementedJournalRepository {
  FakeBlindReviewJournalRepository({required this.queue, required this.card});

  final Stream<ListResult<BlindReviewCard>> Function(int call) queue;
  final Stream<BlindReviewCard> Function(String decisionId, int call) card;

  /// watchBlindReviewQueue 의 mode — 호출마다(인자 없이 = 기본 live).
  final List<RunMode> queueModes = <RunMode>[];

  /// watchBlindReviewCard 의 decisionId — 호출마다.
  final List<String> cardCalls = <String>[];

  @override
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  }) {
    final int call = queueModes.length;
    queueModes.add(mode);
    return queue(call);
  }

  @override
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId) {
    final int call = cardCalls.length;
    cardCalls.add(decisionId);
    return card(decisionId, call);
  }
}

/// J-4 명령 가짜 — 제출·구독 두 창구만 연다.
class FakeBlindReviewCommandApi extends UnimplementedCommandApi {
  FakeBlindReviewCommandApi({required this.submit, required this.watch});

  final Future<CommandReceipt> Function(BlindReviewScore score, int call)
  submit;
  final Stream<CommandReceipt> Function(String commandId) watch;

  final List<BlindReviewScore> submitted = <BlindReviewScore>[];
  final List<String> watched = <String>[];

  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) {
    final int call = submitted.length;
    submitted.add(score);
    return submit(score, call);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watched.add(commandId);
    return watch(commandId);
  }
}

/// 안전 상태 가짜 — 호출마다 새 스트림.
class FakeBlindReviewSafetyRepository extends UnimplementedSafetyRepository {
  FakeBlindReviewSafetyRepository(this.state);

  final SafetyState state;

  @override
  Stream<SafetyState> watchState() => Stream<SafetyState>.value(state);
}

/// J-4 주입 5개.
List<Override> blindReviewOverrides({
  required FakeBlindReviewJournalRepository repo,
  required FakeBlindReviewCommandApi commands,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalTimelineRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeBlindReviewSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
  journalBlindReviewCommandApiProvider.overrideWithValue(commands),
];

/// 390×2400 · DPR 1.0 으로 J-4 를 띄운다(끝에 pump 1번).
Future<void> pumpBlindReview(
  WidgetTester tester, {
  required FakeBlindReviewJournalRepository repo,
  required FakeBlindReviewCommandApi commands,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) async {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: blindReviewOverrides(
        repo: repo,
        commands: commands,
        safety: safety,
        clock: clock,
        opener: opener,
      ),
      child: const MaterialApp(home: Scaffold(body: JournalBlindReview())),
    ),
  );
  await tester.pump();
}

/// 문항마다 [choiceOf] 가 고른 선택지를 위 → 아래로 탭한다.
Future<void> pickBlindReviewAnswers(
  WidgetTester tester,
  BlindReviewCard card,
  int Function(int questionIndex) choiceOf,
) async {
  for (final (int i, BlindReviewQuestion _) in card.questions.indexed) {
    final Finder chip = find.byKey(
      ValueKey<String>('j4-choice-$i-${choiceOf(i)}'),
    );
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pump();
  }
}

/// 모든 ChoiceChip 이 잠겼는가(onSelected == null) / 풀렸는가.
void expectBlindReviewChoicesLocked(
  WidgetTester tester, {
  required bool locked,
}) {
  final List<ChoiceChip> chips = tester
      .widgetList<ChoiceChip>(find.byType(ChoiceChip))
      .toList();
  expect(chips, isNotEmpty);
  for (final ChoiceChip c in chips) {
    expect(c.onSelected == null, locked);
  }
}

/// selected 인 ChoiceChip 의 Key 글자 목록(위 → 아래).
List<String> blindReviewPickedKeys(WidgetTester tester) => <String>[
  for (final ChoiceChip c in tester.widgetList<ChoiceChip>(
    find.byType(ChoiceChip),
  ))
    ?(c.selected ? (c.key! as ValueKey<String>).value : null),
];

/// 하단(머리 · 접수증 · 접수 실패 · 제출 · 결과 · 다음 건) 자손을 뺀 Text 의 data 목록(위 → 아래).
List<String?> blindReviewTextsOutsideBottom(WidgetTester tester) {
  final Set<Element> bottom = <Element>{
    for (final String k in <String>[
      'j4-asof',
      'j4-receipt',
      'j4-submit-not-accepted',
      'j4-submit',
      'j4-result',
      'j4-next',
    ])
      ...find
          .descendant(
            of: find.byKey(Key(k)),
            matching: find.byType(Text),
            matchRoot: true,
          )
          .evaluate(),
  };
  return <String?>[
    for (final Element e in find.byType(Text).evaluate())
      ?(bottom.contains(e) ? null : (e.widget as Text).data),
  ];
}
