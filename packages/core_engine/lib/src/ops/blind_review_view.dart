// 🆕 E11q-j4 — M6 J-4 사후 blind 리뷰 VM(대기 목록 · 카드 1건) · 점수 제출 판정 · 과정 점수 글자
// (설계 13 §8 · 01 §16 · 06 M1-25 · 02 §3-4 · 03_실행 §8-3 · §8-4).
//
// 🔴 대상 = [blindReviewTargetsOf](journal_view — K3 ⓐ 이탈 결정 · ⓑ 그 달 월간 리포트 발행 뒤 · ⓓ 사전 3칸이 다 찬 저널 ·
//    K4 결정 시각 오름차순 · K24 LIVE 원장만) · 큐 = 그 차례 그대로 · 행 결과 = 늘 null(M1-25 ①) · 행 수 = J-1 배지 n.
// 🔴 가림(blind) = 채점 전 카드에 결과 · 손익 · 금액 · 백분율 칸이 «없다»(가리는 것이 아니라 없음 — 02 §3-4 금지 ③ · C-43 ③):
//    머리 = 거래일 · 종목 이름표 · 방향 · 문맥 = 그 결정의 J-1 일지 행 칩 · 이탈 배지(C-43 ⑦ⓒ) · 저널 = J-3R 과 같은 본문(⑦ⓑ) ·
//    문항 근거 = 이탈 글자 · 기록 시각뿐. 앱 안 링크 0(K8 — 칩 링크 = 일지 행 그대로).
// 🔴 글자 = 계약 표본 문장 그대로(«(합성)»만 뺀다 · 표본 개정 0) · 근거 줄 = 원장에 사실이 있는 것만(입력 데이터 기준일 · PIT 수정
//    기록 = 원장 원천 없음 → 줄 부재 · 지어내지 않는다).
// 🔴 채점 기록 · 결과 = 점수 기록 표가 로컬 원장(02 데이터모델 v1)에 없다 · 결과 문장 산식(M1-25 ⑥) 미정 → 계약 창 대기(01 §8) —
//    그 전까지 카드 `result` = 늘 null · 채점된 결정 빼기 0. 거부 판정 · 과정 점수 · 접수증 글자 = 계약 · 03 §8-3 · 표본 그대로
//    (점수 기록 표가 서면 그대로 쓴다).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        BlindReviewCard,
        BlindReviewChoice,
        BlindReviewQuestion,
        BlindReviewRejectCodes,
        BlindReviewScore,
        EmptyKind,
        ListResult,
        RunMode,
        TradeDate,
        TradeJournalEntry;

import 'journal_view.dart'
    show
        BlindReviewTarget,
        JournalFacts,
        JournalTexts,
        blindReviewTargetsOf,
        journalBodyOf,
        journalKeyOf,
        kJournalStaleAfter;
import 'ledger_views.dart' show kstMinuteText;

/// blind 리뷰 글자(표본 `m6/blind_review_*` · 엔진 정본).
abstract final class BlindReviewTexts {
  /// 카드 안내(표본).
  static const String prompt = '결과를 보기 전에 이 결정의 과정을 채점합니다';

  /// 빈 큐(표본 `blind_review_queue_empty`).
  static const String empty = '리뷰할 결정이 없습니다';

  /// 기준 줄(표본 «리뷰 기준 2026-08-31»).
  static String asOfLabel(String day) => '리뷰 기준 $day';

  /// 머리(표본 «2026-08-11 · 0085P0 KODEX 국고채30년 · 매수 결정» — 종목 이름표 = 일지 행 글자 그대로).
  static String title(String day, String symbolLabel, String sideLabel) =>
      '$day · $symbolLabel · $sideLabel 결정';

  /// 문항 ①(표본 · 03_실행 §8-3).
  static const String pitInfoOnly = '결정 시점에 가용했던 정보만 썼는가';

  /// 문항 ②.
  static const String ruleFollowed = '규칙이 지시한 대로 했는가';

  /// 문항 ③.
  static const String pitInput = '입력 데이터가 그때 알 수 있었던 값(PIT)이었는가';

  /// 문항 ④.
  static const String falsifierWritten = '사전에 반증 조건(이러면 내가 틀린 것)을 적었는가';

  /// 문항 ⑤.
  static const String writtenAtDecision = '저널을 결정 시점에 작성했는가';

  /// 선택지(표본).
  static const String yes = '예';

  /// 선택지(표본).
  static const String no = '아니오';

  /// 문항 ② 근거(표본 «이탈 기록: …» — 이탈 배지 글자 그대로).
  static String ruleEvidence(String deviationLabel) => '이탈 기록: $deviationLabel';

  /// 문항 ⑤ 근거(표본 «저널 작성 2026-08-11 13:55 · 주문 2026-08-11 14:39»).
  static String writtenEvidence(String journalAt, String orderAt) =>
      '저널 작성 $journalAt · 주문 $orderAt';

  /// 과정 점수(표본 — 4점 이상 = 좋은 결정 · 03_실행 §8-3).
  static String processScore(int score) => score >= kBlindReviewGoodScore
      ? '과정 점수 $score점 — 좋은 결정($kBlindReviewGoodScore점 이상)'
      : '과정 점수 $score점 — 좋은 결정 기준($kBlindReviewGoodScore점) 미만';

  /// 접수증 — 기록(표본 `blind_review_receipts_6` EXECUTED).
  static const String executed = '기록됨 — 과정 점수가 저장되었습니다';

  /// 접수증 — 답이 카드와 맞지 않음(표본 REJECTED · ANSWERS_INVALID).
  static const String answersInvalid =
      '거부됨 — 답이 카드의 문항과 맞지 않습니다. 고른 답은 그대로 남아 있습니다';

  /// 접수증 — 이미 채점(표본 REJECTED · ALREADY_SCORED).
  static const String alreadyScored =
      '거부됨 — 이 결정은 이미 채점되었습니다. 먼저 기록된 채점이 유지됩니다';
}

/// 문항 키(표본 · 키 전용 · 사전 등재 0 — 01 §16-3).
abstract final class BlindReviewQuestionIds {
  /// ① 결정 시점에 가용했던 정보만.
  static const String pitInfoOnly = 'PIT_INFO_ONLY';

  /// ② 규칙대로.
  static const String ruleFollowed = 'RULE_FOLLOWED';

  /// ③ PIT 입력.
  static const String pitInput = 'PIT_INPUT';

  /// ④ 반증 조건.
  static const String falsifierWritten = 'FALSIFIER_WRITTEN';

  /// ⑤ 결정 시점 기록.
  static const String writtenAtDecision = 'WRITTEN_AT_DECISION';
}

/// 좋은 결정 기준 과정 점수(03_실행 §8-3 «4점 이상이면 좋은 결정»).
const int kBlindReviewGoodScore = 4;

/// 대기 목록(`watchBlindReviewQueue`) — [mode] 가 LIVE 이고 이 원장도 LIVE 일 때만 대상(K24 · SIM 리뷰 = 01 §8 미결 99) ·
/// 그 밖 = 0행 · `notApplicable`(해당 없음) · 비면 표본 빈 문장 · `hasMore` 늘 false · 행 `asOf` = 봉투(C-43 ⑤).
ListResult<BlindReviewCard> blindReviewQueueOf(
  JournalFacts f, {
  RunMode mode = RunMode.live,
}) {
  final AsOf asOf = _asOf(f);
  final bool live = mode == RunMode.live && f.runMode == RunMode.live;
  final List<BlindReviewCard> rows = <BlindReviewCard>[
    if (live)
      for (final BlindReviewTarget t in blindReviewTargetsOf(f)) _card(t, asOf),
  ];
  return ListResult<BlindReviewCard>(
    rows: rows,
    asOf: asOf,
    emptyKind: live ? EmptyKind.noData : EmptyKind.notApplicable,
    emptyLabel: rows.isEmpty ? BlindReviewTexts.empty : null,
    hasMore: false,
  );
}

/// 카드 1건(`watchBlindReviewCard`) — 큐 행과 같은 값(C-43 ④) · 모르는 · 대상이 아닌 결정 = 실패(잠정 규칙 · 01 §8 미결 50 ③).
BlindReviewCard blindReviewCardOf(JournalFacts f, String routeDecisionId) {
  final String key = journalKeyOf(routeDecisionId);
  for (final BlindReviewTarget t in blindReviewTargetsOf(f)) {
    if (t.decisionId == key) return _card(t, _asOf(f));
  }
  throw StateError('blind 리뷰 대상이 아니다: $key');
}

/// 점수 제출 판정(06 M1-25 ⑤ · K10 · K12) — null = 받는다. 이미 채점 = `ALREADY_SCORED`(먼저 집행된 채점이 이긴다 · 답보다 먼저) ·
/// 답 = 카드 문항 id 집합과 같고 값마다 그 문항 선택지의 점수 — 아니면 `ANSWERS_INVALID`(빠진 · 모르는 문항 · 선택지에 없는 점수 ·
/// 다른 결정의 카드).
String? blindReviewRejectOf(
  BlindReviewCard card,
  BlindReviewScore score, {
  required bool alreadyScored,
}) {
  if (alreadyScored) return BlindReviewRejectCodes.alreadyScored;
  if (score.decisionId != card.decisionId) {
    return BlindReviewRejectCodes.answersInvalid;
  }
  final Map<String, Set<int>> allowed = <String, Set<int>>{
    for (final BlindReviewQuestion q in card.questions)
      q.questionId: <int>{for (final BlindReviewChoice c in q.choices) c.score},
  };
  if (score.answers.length != allowed.length) {
    return BlindReviewRejectCodes.answersInvalid;
  }
  for (final MapEntry<String, int> a in score.answers.entries) {
    final Set<int>? ok = allowed[a.key];
    if (ok == null || !ok.contains(a.value)) {
      return BlindReviewRejectCodes.answersInvalid;
    }
  }
  return null;
}

/// 접수증 글자(표본 그대로) — null = 기록 · 사전 밖 코드 = 실패(지어내지 않는다).
String blindReviewStateLabelOf(String? rejectCode) => switch (rejectCode) {
  null => BlindReviewTexts.executed,
  BlindReviewRejectCodes.answersInvalid => BlindReviewTexts.answersInvalid,
  BlindReviewRejectCodes.alreadyScored => BlindReviewTexts.alreadyScored,
  final String c => throw ArgumentError.value(c, 'rejectCode', '사전 밖 거부 코드'),
};

/// 과정 점수(03_실행 §8-3 — 충족 개수 → 1~5: 5 → 5 · 4 → 4 · 3 → 3 · 2 → 2 · 0~1 → 1) · 충족 수 = 답 점수 합
/// (선택지 점수 = 엔진이 정한 1 · 0). 🔴 [blindReviewRejectOf] 를 통과한 답만 넘긴다.
int blindReviewProcessScoreOf(Map<String, int> answers) {
  final int met = answers.values.fold(0, (int a, int s) => a + s);
  return met <= 1 ? 1 : (met > 5 ? 5 : met);
}

// ── 내부 ──────────────────────────────────────────────────────────────────────

AsOf _asOf(JournalFacts f) => AsOf(
  observedAt: f.nowUtc.toUtc(),
  tradeDate: TradeDate(f.today),
  source: AsOfSource.localSqlite,
  staleAfter: kJournalStaleAfter,
  label: BlindReviewTexts.asOfLabel(f.today),
);

const List<BlindReviewChoice> _choices = <BlindReviewChoice>[
  BlindReviewChoice(score: 1, label: BlindReviewTexts.yes),
  BlindReviewChoice(score: 0, label: BlindReviewTexts.no),
];

BlindReviewCard _card(BlindReviewTarget t, AsOf asOf) {
  final TradeJournalEntry e = t.entry;
  final DateTime? sent = t.firstOrderAt;
  return BlindReviewCard(
    decisionId: t.decisionId,
    titleText: BlindReviewTexts.title(
      e.tradeDate.yyyyMmDd,
      e.symbolLabel,
      e.sideLabel,
    ),
    promptText: BlindReviewTexts.prompt,
    contextChips: e.reasons,
    deviation: e.deviation,
    journalStateLabel: JournalTexts.journalWritten,
    journal: journalBodyOf(t.note),
    questions: <BlindReviewQuestion>[
      const BlindReviewQuestion(
        questionId: BlindReviewQuestionIds.pitInfoOnly,
        text: BlindReviewTexts.pitInfoOnly,
        choices: _choices,
      ),
      BlindReviewQuestion(
        questionId: BlindReviewQuestionIds.ruleFollowed,
        text: BlindReviewTexts.ruleFollowed,
        evidenceText: BlindReviewTexts.ruleEvidence(e.deviation.label),
        choices: _choices,
      ),
      const BlindReviewQuestion(
        questionId: BlindReviewQuestionIds.pitInput,
        text: BlindReviewTexts.pitInput,
        choices: _choices,
      ),
      const BlindReviewQuestion(
        questionId: BlindReviewQuestionIds.falsifierWritten,
        text: BlindReviewTexts.falsifierWritten,
        choices: _choices,
      ),
      BlindReviewQuestion(
        questionId: BlindReviewQuestionIds.writtenAtDecision,
        text: BlindReviewTexts.writtenAtDecision,
        evidenceText: sent == null
            ? null
            : BlindReviewTexts.writtenEvidence(
                kstMinuteText(t.note.createdAt),
                kstMinuteText(sent),
              ),
        choices: _choices,
      ),
    ],
    asOf: asOf,
  );
}
