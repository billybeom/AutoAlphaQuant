// C-43 J-4 사후 blind 리뷰 — 01 §16 · §7 표 C-43(🆕 계약 v1.7 · 미결 46 설계서 2026-10-19 §4-1).
//
// 정의: 「`J-4` 는 엔진이 고른 대기 카드 한 장을 고정해 그 카드 스트림만 보고 그린다 — 채점 전 카드에는 결과가
//   **없고**, 화면은 고른 선택지의 `score` 를 `BlindReviewScore.answers` 에 **옮길 뿐**이며, 결과 섹션은
//   `result != null` 하나로만 연다」. C-41(픽스처 불변식) + C-42(화면 소스 스캔)를 한 파일에 둔다(대상이 한 화면).
//
// A. 픽스처·DTO 불변식(①~⑨) — 숫자 리터럴을 코드에 적지 않고 픽스처끼리 맞댄다(C-40·C-41 선례).
//   ① 문항 3~5 · `questionId` 유일 · 선택지 ≥ 2 · 한 문항 안 `score` 유일 · 글자 비지 않음 · `evidenceText` null|비지 않음.
//   ② 허용 키 목록(카드·문항·선택지·결과 · 본문 = C-34 ⑧ 과 같은 5키) — 금지 목록이 아니다.
//   ③ 채점 전(큐·before) = `result` 부재 · 전 문자열에 금액·백분율·«손익/수익/평가액» 0 · 머리 글자 비지 않음.
//   ④ before == 큐 행 0(JSON) · 공개 카드 − `result`·`as_of` == 짝 − `as_of`(revealed ↔ 행 0 · revealed_open ↔ 행 1).
//   ⑤ 큐 행 수 == 배지 «리뷰 대기 n건» 의 n(n ≥ 1 · «0건» 금지) · `has_more` false · 행 `as_of` == 봉투 · 빈 큐 = 문장.
//   ⑥ 링크 — 채점 전·결과 밖 `aaq://` 0(칩 = handbook|null · K8) · 결과 링크 = 그 카드의 `J-2`.
//   ⑦ 저널·문맥 정합(K3 ⓓ 2026-10-20 확정 반영) — ⓐ `JOURNAL_MISSING` 이 서 있는 결정 = 큐에 없음 ⓑ 같은 결정의
//      `journal_read_written`·`_no_note` 본문·상태 글자 ⓒ 일지 행(`journal_30`·`manual_fills_8`)의 이탈 배지·사유 칩
//      ⓓ J-3 스펙의 문맥·이탈(v1.7 표본엔 해당 0 — 규칙만).
//   ⑧ 결과 — 공개 2벌 `result` 있음 · 글자 비지 않음 · 금액 꼴 0(K6 확정) · 미청산 문장 ≠ 청산 문장.
//   ⑨ 제출 꼴 견본 — 카드마다 `BlindReviewScore(answers: {questionId: choices.first.score})` 왕복 · 키 == 문항 id.
//
// B. 화면 소스 스캔(⑩~⑰) — 대상 = `packages/ui_journal/lib/src/blind_review.dart` + `lib/src/blind_review/**`
//    (01 §16-8 «공개 위젯 · 파일 자리» · 설계서 §2-5). 소스는 `stripComments`(줄 끝·블록 주석을 지우고 **문자열
//    리터럴은 남긴다** — ⑯ 의 `%`·`원` 문자열 검사에 필요)를 거친 뒤 본다. 대상 0 = 공허 통과 + 대상 수 출력.
//   ⑩ 대상 수 · 가드 — `packages/ui_*/lib`(셸 `ui_shell` 제외 — 배선 자리)에서 J-4 전용 이름을 말하는 파일 ⊆ 대상.
//   ⑪ 호출 — 금지 목록(0 =)만 기계 검사 · `watchBlindReviewQueue` 는 인자 없이.
//   ⑫ 점수 — `.score` 는 맵 값 자리에만(옮기기) · 표시·합산·비교·변환 0.
//   ⑬ 원값·키 — `decisionId`·`questionId` 표시 0 · 이탈·저널 id·거부 코드·칩 코드 0 · `.result!` 0.
//   ⑭ 분기·셸·포맷 낱말 0(운영 모드·플랫폼·시계·Scaffold·숫자 포맷 · operator 라이브러리 `journal_draft`).
//   ⑮ 문자열 가공·정렬·거르기 0(C-42 ⑨ 목록 + `maxLines`·`TextOverflow.ellipsis`·`.trim(`).
//   ⑯ 숫자 리터럴 — 소수부 ≠ 0 소수 리터럴 0 + `%`·`원` 을 품은 문자열 리터럴 0(C-42 ⑥ 정의).
//   ⑰ 자체 검증 — 양성은 걸리고(걸린 조항 번호 출력) 음성은 통과한다.
// 🔴 대상 파일이 아직 없으면(`R3-Bob-J4` 전) ⑪~⑯ 은 통과한다 — 없는 파일로 실패시키지 않는다. ⑩ 가드는 늘 실대상을 본다.
// 🔴 픽스처 값(점수·건수·날짜)을 이 파일에 적지 않는다 — 픽스처끼리 맞댄다(문항 3~5 · 선택지 ≥ 2 · 배지 n ≥ 1 은
//    규칙의 경계다). 자체 검증 스니펫의 수치는 뜻 없는 자리표시자다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/fixture_io_t2.dart' show collectStrings;

// ─── A. 픽스처 ────────────────────────────────────────────────────────────────

const String _queue = FixturePaths.m6BlindReviewQueue3;
const String _empty = FixturePaths.m6BlindReviewQueueEmpty;
const String _before = FixturePaths.m6BlindReviewCardBefore;
const String _revealed = FixturePaths.m6BlindReviewCardRevealed;
const String _revealedOpen = FixturePaths.m6BlindReviewCardRevealedOpen;

/// 카드 행을 싣는 J-4 픽스처(빈 큐 포함 — 키 검사는 행이 없어도 돈다).
const List<String> _cardFixtures = <String>[
  _queue,
  _empty,
  _before,
  _revealed,
  _revealedOpen,
];

/// 채점 전 카드(대기 목록 · 1건 첫 값).
const List<String> _beforeFixtures = <String>[_queue, _before];

/// 공개 카드 → 짝이 되는 큐 행 번호(④ — 테스트 쪽 위치 대응 · 엔진 정렬은 K4).
const Map<String, int> _revealedPairs = <String, int>{
  _revealed: 0,
  _revealedOpen: 1,
};

/// 저널 읽기 3갈래(`J-3R` · C-34 ⑧).
const List<String> _readFixtures = <String>[
  FixturePaths.m6JournalReadWritten,
  FixturePaths.m6JournalReadNoNote,
  FixturePaths.m6JournalReadNotWritten,
];

/// J-3 폼 스펙(같은 결정이면 문맥·이탈이 같다).
const List<String> _specFixtures = <String>[
  FixturePaths.m6JournalDraftSpecDiscretion,
  FixturePaths.m6JournalDraftSpecReconClear,
];

/// 일지 행(같은 결정이면 이탈 배지가 같다).
const List<String> _entryFixtures = <String>[
  FixturePaths.journal30,
  FixturePaths.m6ManualFills8,
];

/// ② 허용 키(🔴 목록에 없는 키 = 01 §16 개정이 먼저).
const Set<String> _cardKeys = <String>{
  'decision_id',
  'title_text',
  'prompt_text',
  'context_chips',
  'deviation',
  'journal_state_label',
  'journal',
  'questions',
  'result',
  'as_of',
};
const Set<String> _questionKeys = <String>{
  'question_id',
  'text',
  'evidence_text',
  'choices',
};
const Set<String> _choiceKeys = <String>{'score', 'label'};
const Set<String> _resultKeys = <String>{
  'process_score_text',
  'outcome_text',
  'detail_lines',
  'decision_link',
};

/// ② 본문 = C-34 ⑧ `bodyKeys` 와 **같은 목록**(본문 단위가 같다는 증명 — 01 §12-2).
const Set<String> _bodyKeys = <String>{
  'written_at_text',
  'rule_cited_label',
  'rationale_before',
  'expected_outcome',
  'note',
};

/// ③ 채점 전 blind 붕괴 거름망 — 금액 · 백분율 · 손익 낱말(설계서 §3-0).
final List<RegExp> _beforeLeaks = <RegExp>[
  RegExp(r'\d[\d,]*\s*원'),
  RegExp(r'\d+(\.\d+)?\s*%'),
  RegExp('손익|수익|평가액'),
];

/// ⑧ 결과의 금액 꼴(K6 — 금액(원) 0 · 원화 기호 0).
final RegExp _resultMoney = RegExp(r'\d[\d,.]*\s*(억원|만원|원)|₩');

/// ⑤ 배지 문구 끝의 «n건».
final RegExp _countSuffix = RegExp(r'([0-9]+)건$');

List<Map<String, Object?>> _rawRows(String path) =>
    decodeEnvelope(readFixture(path)).rows;

List<BlindReviewCard> _cards(String path) =>
    _rawRows(path).map(BlindReviewCard.fromJson).toList();

Map<String, Object?> _without(Map<String, Object?> m, Set<String> keys) =>
    <String, Object?>{
      for (final MapEntry<String, Object?> e in m.entries)
        if (!keys.contains(e.key)) e.key: e.value,
    };

/// `journalDecision` 에 그 결정을 끼운 기대값(테스트 쪽 조립 · C-41 `_gapMonthLink` 선례).
String _decisionLink(String decisionId) {
  const String pattern = AppRoutes.journalDecision;
  expect(pattern.split(':decisionId'), hasLength(2), reason: pattern);
  return pattern.replaceFirst(':decisionId', decisionId);
}

/// K3 ⓓ — `JOURNAL_MISSING` 깃발의 해제 링크(`journalDraft`)가 가리키는 결정.
Set<String> _journalMissingTargets() {
  final String prefix = AppRoutes.journalDraft.split(':decisionId').first;
  final Set<String> out = <String>{};
  for (final Map<String, Object?> row in _rawRows(FixturePaths.safetyStates)) {
    final SafetyState state = SafetyState.fromJson(row);
    for (final BlockFlag f in state.activeFlags) {
      final String? link = f.clearDeepLink;
      if (f.flagId == FlagIds.journalMissing &&
          link != null &&
          link.startsWith(prefix)) {
        out.add(link.substring(prefix.length));
      }
    }
  }
  return out;
}

// ─── B. 화면 소스 스캔 — 대상 ─────────────────────────────────────────────────

/// `J-4` 화면 패키지(저장소 루트 기준).
const String _j4Package = 'packages/ui_journal';

/// 공개 파일(배럴 `ui_journal.dart` 가 export 한다 · 01 §16-8).
const String _j4PublicFile = 'lib/src/blind_review.dart';

/// 내부 조각 폴더(`/` 로 끝난다 · 아래 전부가 대상 · 배럴 export 0).
const String _j4InternalDir = 'lib/src/blind_review/';

/// [rel](`packages/ui_journal` 기준)이 J-4 대상인가.
bool _isJ4Target(String rel) =>
    rel == _j4PublicFile || rel.startsWith(_j4InternalDir);

/// `packages/ui_journal` 기준 상대 경로.
String? _journalRel(String repoRel) => repoRel.startsWith('$_j4Package/')
    ? repoRel.substring(_j4Package.length + 1)
    : null;

// ─── B. 정규식 ────────────────────────────────────────────────────────────────

/// ⑩ J-4 전용 이름(DTO 4 · 명령 인자 · 창구 3 · 명령 주입 프로바이더).
final RegExp _j4Name = RegExp(
  r'\b(BlindReviewCard|BlindReviewQuestion|BlindReviewChoice|BlindReviewResult|'
  r'BlindReviewScore|watchBlindReviewQueue|watchBlindReviewCard|submitBlindReviewScore|'
  r'journalBlindReviewCommandApiProvider)\b',
);

/// ⑪ 부르지 않는 것 — J-4 2개를 뺀 `JournalRepository` 메서드 전부 · 안전 상태 직접 구독 · 다른 리포지토리 ·
/// 초안 포트 · operator 명령 주입 · J-4 밖 명령 전부(설계서 §2-6 «부르지 않는 것»).
/// 🔵 `recordDisclosureView` 0 = K6 확정(2026-10-20 · 공개 결과 = 결정 8 열람 기록 없음 · `S7-2G` 게이트 없음).
final RegExp _forbiddenCalls = RegExp(
  r'watchTimeline|watchFilterCatalog|watchDecisionDetail|watchDecisionJournal|'
  r'findByDecisionId|chainOf|fillChain|watchTimelineBadges|watchUnknownBoard|'
  r'draftFormSpec|watchRebalanceScope|\.watchState\(|HoldingsRepository|'
  r'PerformanceRepository|DraftStore|journalDraftStoreProvider|journalCommandApiProvider|'
  r'activateKillSwitch|submitJournalDraft|recordDisclosureView|registerDeposit|'
  r'recordManualFill|amendManualFill|voidManualFill|skipAdvice|submitSelfReportBalance|'
  r'acknowledgeAlert|confirmKillChecklist',
);

/// ⑪ 큐는 인자 없이 부른다(SIM 결정의 리뷰 = §8 미결 99 · K24 — v1.7 = LIVE 만).
final RegExp _queueArgCall = RegExp(r'watchBlindReviewQueue\(\s*[^)\s]');

/// ⑫ `.score` 의 모든 등장.
final RegExp _scoreAny = RegExp(r'\.score\b');

/// ⑫ 맵 값 자리(`answers[id] = c.score;` · `id: _picked[id]!.score}`) — 등장 수가 [_scoreAny] 와 같아야 한다.
final RegExp _scoreMapValue = RegExp(r'[:=]\s*[\w.\]\[!?]*\.score\s*[,;})\]]');

/// ⑫ 표시·비교·산술·변환·집계.
final List<RegExp> _scoreMath = <RegExp>[
  RegExp(r'''\$\{?[^}'"]*\.score'''),
  RegExp(r'\.score\s*[-+*/<>=!]'),
  RegExp(r'[-+*/<>]\s*[\w.]*\.score\b'),
  RegExp(r'\.score\.toString'),
  RegExp(r'\b(fold|reduce|sum)\b'),
];

/// ⑬ 원값·키.
final List<RegExp> _rawKeys = <RegExp>[
  RegExp(r'\$\{?[\w.]*\.(decisionId|questionId)\b'),
  RegExp(r'Text\(\s*[\w.]*\.(decisionId|questionId)\b'),
  RegExp(r'\.(isDeviation|kindCode|journalId|rejectReasonCode|code|wire)\b'),
  RegExp(r'\.result!'),
];

/// ⑭ 분기·셸·포맷 낱말(C-42 ⑤ 목록 + operator 라이브러리 `journal_draft` · 플래너 import 는 무관해 뺀다).
final RegExp _branchWords = RegExp(
  r'operatingMode|OperatingMode|RunMode|runMode|FeatureFlags|kIsWeb|Platform\.|'
  r'DateTime\.now|Scaffold|AppBar|SafeArea|AppLinkSchemes|toStringAsFixed|'
  r'toStringAsPrecision|NumberFormat|journal_draft',
);

/// ⑮ 문자열 가공 · 정렬·거르기 · 역순 목록(C-42 ⑨ 그대로) + 원문 자르기(01 §12-2 «자르기·trim·maxLines·말줄임 금지»).
final List<RegExp> _reshape = <RegExp>[
  RegExp(
    r'(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|'
    r'endsWith|indexOf|padLeft|padRight)\(',
  ),
  RegExp(
    r'(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|'
    r'singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet)\b',
  ),
  RegExp(r'\breverse:\s*true\b'),
  RegExp(r'\bmaxLines\b'),
  RegExp(r'TextOverflow\.ellipsis'),
  RegExp(r'\.trim\('),
];

/// ⑯ 소수부가 0 이 아닌 소수 리터럴(`16.0`·`0.0`·정수는 통과 — C-42 ⑥ 과 같은 식).
final RegExp _decimalLiteral = RegExp(r'(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])');

// ─── B. 규칙 묶음 ─────────────────────────────────────────────────────────────

class _Hit {
  const _Hit(this.clause, this.text);
  final String clause;
  final String text;

  @override
  String toString() => '$clause «$text»';
}

/// 대상 파일 한 벌의 위반(주석만 지운 소스 — 문자열 보간 안 참조까지 본다).
List<_Hit> _scan(String source) {
  final String code = stripComments(source);
  final List<_Hit> out = <_Hit>[
    for (final RegExpMatch m in _forbiddenCalls.allMatches(code))
      _Hit('⑪', m.group(0)!),
    for (final RegExpMatch m in _queueArgCall.allMatches(code))
      _Hit('⑪', m.group(0)!),
    for (final RegExp re in _scoreMath)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑫', m.group(0)!),
    for (final RegExp re in _rawKeys)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑬', m.group(0)!),
    for (final RegExpMatch m in _branchWords.allMatches(code))
      _Hit('⑭', m.group(0)!),
    for (final RegExp re in _reshape)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑮', m.group(0)!),
    for (final RegExpMatch m in _decimalLiteral.allMatches(code))
      _Hit('⑯', m.group(0)!),
    for (final String lit in _stringLiterals(code))
      if (lit.contains('%') || lit.contains('원')) _Hit('⑯', lit),
  ];
  final int any = _scoreAny.allMatches(code).length;
  final int asValue = _scoreMapValue.allMatches(code).length;
  if (any != asValue) {
    out.add(_Hit('⑫', '.score $any회 중 맵 값 자리 $asValue회'));
  }
  return out;
}

/// 주석을 지운 소스의 문자열 리터럴(따옴표 포함 · C-42 `_stringLiterals` 와 같은 토큰 규칙).
List<String> _stringLiterals(String code) {
  final List<String> out = <String>[];
  int i = 0;
  final int n = code.length;
  while (i < n) {
    final String c = code[i];
    if (c != "'" && c != '"') {
      i++;
      continue;
    }
    final bool triple = i + 2 < n && code[i + 1] == c && code[i + 2] == c;
    final String terminator = triple ? c * 3 : c;
    final int start = i;
    i += terminator.length;
    while (i < n) {
      if (code[i] == r'\') {
        i += 2;
        continue;
      }
      if (code.startsWith(terminator, i)) {
        i += terminator.length;
        break;
      }
      if (!triple && code[i] == '\n') {
        break;
      }
      i++;
    }
    out.add(code.substring(start, i > n ? n : i));
  }
  return out;
}

/// ⑩ 가드 — J-4 전용 이름을 말하는데 대상이 아닌 파일(저장소 기준 경로).
List<String> _j4MentionsOutside(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (!(_journalRel(e.key) != null && _isJ4Target(_journalRel(e.key)!)) &&
        _j4Name.hasMatch(stripComments(e.value)))
      e.key,
];

// ─── B. 실대상 ────────────────────────────────────────────────────────────────

/// ⑩ 가드 대상 — `packages/ui_*/lib`(셸 제외 · 저장소 기준 경로 → 원문).
final Map<String, String> _guardSources = <String, String>{
  for (final String p in uiPackageNames)
    if (p != 'ui_shell')
      for (final File f in dartSourcesIn(
        Directory('${repoRoot.path}/packages/$p/lib'),
      ))
        shortPath(f): f.readAsStringSync(),
};

/// J-4 대상 파일(저장소 기준 경로 → 원문). 없으면 빈 지도(공허 통과).
final Map<String, String> _targets = <String, String>{
  for (final MapEntry<String, String> e in _guardSources.entries)
    if (_journalRel(e.key) != null && _isJ4Target(_journalRel(e.key)!))
      e.key: e.value,
};

/// [clause] 의 실대상 위반.
List<String> _violations(String clause) => <String>[
  for (final MapEntry<String, String> f in _targets.entries)
    for (final _Hit h in _scan(f.value))
      if (h.clause == clause) '${f.key}: $h',
];

/// 출력(카드 0단계·C4 가 «대상 N파일»을 확인한다).
void _say(String line) {
  // ignore: avoid_print
  print(line);
}

// ─── B. ⑰ 자체 검증 스니펫 ───────────────────────────────────────────────────

/// 양성 — (스니펫, 반드시 걸려야 하는 조항).
const List<(String, String)> _positives = <(String, String)>[
  (r"Text('${c.score}점')", '⑫'),
  ('total += c.score', '⑫'),
  ('q.choices.first.score > 0', '⑫'),
  ('Text(c.score.toString())', '⑫'),
  ('final s = scores.fold(0, (a, b) => a + b);', '⑫'),
  ('repo.watchDecisionDetail(id)', '⑪'),
  ('repo.watchDecisionJournal(id)', '⑪'),
  ('watchBlindReviewQueue(mode: m)', '⑪'),
  ('ref.watch(safetyRepo).watchState()', '⑪'),
  ('ref.read(journalCommandApiProvider)', '⑪'),
  ('api.recordDisclosureView(e)', '⑪'),
  ('Text(card.decisionId)', '⑬'),
  (r"Text('${q.questionId}')", '⑬'),
  ('card.result!.outcomeText', '⑬'),
  ('if (card.deviation.isDeviation) {}', '⑬'),
  ('if (r.rejectReasonCode == x) {}', '⑬'),
  ('DateTime.now()', '⑭'),
  ('Scaffold(body: b)', '⑭'),
  ("import '../journal_draft.dart';", '⑭'),
  ("import 'package:ui_journal/journal_draft.dart';", '⑭'),
  ('rows.where((c) => c.result == null)', '⑮'),
  ('flags.where((f) => f.flagId != x)', '⑮'),
  ('Text(b.rationaleBefore, maxLines: 3)', '⑮'),
  ('Text(b.note, overflow: TextOverflow.ellipsis)', '⑮'),
  ('Text(b.expectedOutcome.trim())', '⑮'),
  ('const double k = 0.42;', '⑯'),
  ("Text('80%')", '⑯'),
  ("Text('1,000원')", '⑯'),
];

/// 음성 — 어느 조항에도 걸리지 않아야 한다.
const List<String> _negatives = <String>[
  'answers[q.questionId] = picked.score;',
  '{for (final q in qs) q.questionId: _picked[q.questionId]!.score}',
  'final r = card.result;\nif (r != null) { Text(r.outcomeText); }',
  'card.result?.outcomeText',
  'rows[0]',
  'questions.every((q) => _picked.containsKey(q.questionId))',
  'const EdgeInsets.all(16.0)',
  'Text(c.label); // c.score 는 읽지 않는다',
  '/* DateTime.now() 금지 */ const SizedBox(height: 12)',
  'JournalSafetyBanners(safety: safety)',
  'ref.watch(journalSafetyStateProvider)',
  'ref.watch(journalTimelineRepositoryProvider).watchBlindReviewQueue()',
  'ref.watch(journalTimelineRepositoryProvider).watchBlindReviewCard(pinnedId)',
  'ref.read(journalBlindReviewCommandApiProvider).submitBlindReviewScore(s)',
  'BlindReviewScore(decisionId: card.decisionId, answers: a)',
  'api.watchCommand(receipt.commandId)',
  'for (final (i, q) in card.questions.indexed) {}',
  'Text(q.text)',
  'Text(card.titleText)',
  'Text(JournalLabels.blindReviewNotice)',
];

void main() {
  group('C-43 J-4 사후 blind 리뷰 (01 §16 · 계약 v1.7)', () {
    test('C-43 ① 문항 3~5 · id 유일 · 선택지 ≥ 2 · 한 문항 안 점수 유일', () {
      int cards = 0;
      for (final String path in _cardFixtures) {
        for (final BlindReviewCard c in _cards(path)) {
          cards++;
          final List<String> ids = <String>[
            for (final BlindReviewQuestion q in c.questions) q.questionId,
          ];
          expect(
            ids.length,
            inInclusiveRange(3, 5),
            reason: '$path ${c.decisionId} — 문항은 3~5개(03_실행 §8-3).',
          );
          expect(
            ids.toSet(),
            hasLength(ids.length),
            reason: '$path — questionId 중복',
          );
          for (final BlindReviewQuestion q in c.questions) {
            final String at = '$path ${c.decisionId} ${q.questionId}';
            expect(q.text, isNotEmpty, reason: at);
            expect(
              q.evidenceText == null || q.evidenceText!.isNotEmpty,
              isTrue,
              reason: '$at — 근거 줄은 null(부재)이거나 글자가 있다.',
            );
            expect(q.choices.length, greaterThanOrEqualTo(2), reason: at);
            final List<int> scores = <int>[
              for (final BlindReviewChoice ch in q.choices) ch.score,
            ];
            expect(
              scores.toSet(),
              hasLength(scores.length),
              reason: '$at — 한 문항 안에서 점수가 겹치면 점수로 선택을 가릴 수 없다.',
            );
            for (final BlindReviewChoice ch in q.choices) {
              expect(ch.label, isNotEmpty, reason: at);
            }
          }
        }
      }
      expect(cards, greaterThan(0), reason: 'J-4 카드를 하나도 못 읽었다.');
    });

    test('C-43 ② 허용 키 목록 — 카드·문항·선택지·결과·본문에 결과·손익 류 키 0', () {
      for (final String path in _cardFixtures) {
        for (final Map<String, Object?> row in _rawRows(path)) {
          final String at = '$path ${row['decision_id']}';
          expect(
            row.keys.toSet().difference(_cardKeys),
            isEmpty,
            reason: '$at — BlindReviewCard 에 허용 목록 밖 키가 있다(01 §16 개정이 먼저다).',
          );
          final Object? body = row['journal'];
          if (body is Map<String, Object?>) {
            expect(
              body.keys.toSet().difference(_bodyKeys),
              isEmpty,
              reason:
                  '$at — 저널 본문(DecisionJournalBody)에 결과·손익 류 키가 붙었다'
                  '(C-34 ⑧ 과 같은 목록).',
            );
          }
          for (final Object? q in row['questions']! as List<Object?>) {
            final Map<String, Object?> qm = q! as Map<String, Object?>;
            expect(
              qm.keys.toSet().difference(_questionKeys),
              isEmpty,
              reason: at,
            );
            for (final Object? ch in qm['choices']! as List<Object?>) {
              expect(
                (ch! as Map<String, Object?>).keys.toSet().difference(
                  _choiceKeys,
                ),
                isEmpty,
                reason: '$at — 선택지는 점수와 글자뿐이다.',
              );
            }
          }
          final Object? result = row['result'];
          if (result is Map<String, Object?>) {
            expect(
              result.keys.toSet().difference(_resultKeys),
              isEmpty,
              reason: at,
            );
          }
        }
      }
    });

    test('C-43 ③ 채점 전 카드 — result 부재 · 금액·백분율·손익 낱말 0 · 머리 글자', () {
      for (final String path in _beforeFixtures) {
        final List<Map<String, Object?>> rows = _rawRows(path);
        expect(rows, isNotEmpty, reason: path);
        for (final Map<String, Object?> row in rows) {
          final BlindReviewCard c = BlindReviewCard.fromJson(row);
          final String at = '$path ${c.decisionId}';
          expect(
            c.result,
            isNull,
            reason: '$at — 대기 카드에는 결과가 «가려진» 것이 아니라 없다(02 §3-4 금지 ③).',
          );
          expect(c.titleText, isNotEmpty, reason: at);
          expect(c.promptText, isNotEmpty, reason: at);
          expect(c.journalStateLabel, isNotEmpty, reason: at);
          for (final ({String path, String value}) s in collectStrings(row)) {
            for (final RegExp re in _beforeLeaks) {
              expect(
                re.hasMatch(s.value),
                isFalse,
                reason: '$at ${s.path} — 채점 전 글자에 결과·손익 류가 있다: «${s.value}»',
              );
            }
          }
        }
      }
    });

    test('C-43 ④ 목록·1건 정합 — before == 큐 행 0 · 공개 카드는 result·as_of 밖이 같다', () {
      final List<Map<String, Object?>> queue = _rawRows(_queue);
      expect(
        _rawRows(_before).single,
        queue.first,
        reason: '1건 창구의 첫 값은 큐 머리 행과 JSON 이 같다(고정 카드 = rows[0]).',
      );
      const Set<String> volatile = <String>{'result', 'as_of'};
      for (final MapEntry<String, int> e in _revealedPairs.entries) {
        expect(queue.length, greaterThan(e.value), reason: e.key);
        final Map<String, Object?> revealed = _rawRows(e.key).single;
        expect(
          _without(revealed, volatile),
          _without(queue[e.value], volatile),
          reason:
              '${e.key} — 채점 전·후 카드는 result·as_of(관측 시각) 밖 필드가 같다'
              '(02 수용 (c) · K18 의 데이터 근거).',
        );
      }
    });

    test('C-43 ⑤ 배지 «리뷰 대기 n건» == 큐 행 수 · 빈 큐 = 문장', () {
      final List<JournalTimelineBadge> badges = _rawRows(
        FixturePaths.m6JournalBadges2,
      ).map(JournalTimelineBadge.fromJson).toList();
      final List<JournalTimelineBadge> pending = <JournalTimelineBadge>[
        for (final JournalTimelineBadge b in badges)
          if (b.badgeCode == JournalBadgeCodes.blindReviewPending) b,
      ];
      expect(pending, hasLength(1), reason: '배지 픽스처에 리뷰 대기 행이 없다.');
      final RegExpMatch? m = _countSuffix.firstMatch(pending.single.label);
      expect(m, isNotNull, reason: '«${pending.single.label}» 끝에 «n건» 이 없다.');
      final int n = int.parse(m!.group(1)!);
      expect(
        n,
        greaterThanOrEqualTo(1),
        reason: '«0건» 배지 금지 — 큐가 비면 배지 행 자체가 없다(정상 = 무소식).',
      );

      final ListResult<BlindReviewCard> queue = decodeList<BlindReviewCard>(
        readFixture(_queue),
        BlindReviewCard.fromJson,
      );
      expect(
        queue.rows,
        hasLength(n),
        reason: '큐 행 수 = 배지 숫자(화면이 세지 않는다 — 배지 문구가 말한다).',
      );
      expect(queue.hasMore, isFalse, reason: '대기 목록은 전체다(limit 없음).');
      for (final BlindReviewCard c in queue.rows) {
        expect(
          c.asOf,
          queue.asOf,
          reason: '${c.decisionId} — 대기 행 as_of == 봉투.',
        );
      }

      final ListResult<BlindReviewCard> empty = decodeList<BlindReviewCard>(
        readFixture(_empty),
        BlindReviewCard.fromJson,
      );
      expect(empty.rows, isEmpty);
      expect(empty.emptyKind, EmptyKind.noData);
      expect(
        empty.emptyLabel,
        isNotNull,
        reason: '빈 큐의 문장은 봉투 emptyLabel 이 말한다(무문장 금지 · K24 DRY_RUN 기간도 이 문장).',
      );
      expect(empty.emptyLabel, isNotEmpty);
    });

    test('C-43 ⑥ 링크 — 채점 전·결과 밖 aaq:// 0 · 결과 링크 = 그 카드의 J-2', () {
      for (final String path in _cardFixtures) {
        for (final Map<String, Object?> row in _rawRows(path)) {
          final BlindReviewCard c = BlindReviewCard.fromJson(row);
          final String at = '$path ${c.decisionId}';
          for (final ({String path, String value}) s in collectStrings(
            _without(row, <String>{'result'}),
          )) {
            expect(
              s.value.contains('aaq://'),
              isFalse,
              reason: '$at ${s.path} — 채점 전 카드의 앱 안 링크는 0 이다(K8 — J-2 엿보기 길).',
            );
          }
          for (final ReasonChip chip in c.contextChips) {
            final String? link = chip.detailDeepLink;
            expect(
              link == null || link.startsWith('handbook://'),
              isTrue,
              reason: '$at — 문맥 칩 링크는 핸드북 앵커이거나 없다: $link',
            );
          }
          final BlindReviewResult? r = c.result;
          if (r != null) {
            final LinkAction? link = r.decisionLink;
            expect(link, isNotNull, reason: '$at — 공개 표본은 「이 결정 보기」를 싣는다.');
            expect(link!.deepLink, _decisionLink(c.decisionId), reason: at);
            expect(link.label, isNotEmpty, reason: at);
          }
        }
      }
    });

    test('C-43 ⑦ 저널·문맥 정합 — 본문·문맥·이탈은 다른 화면의 같은 결정과 같다 · K3 ⓓ', () {
      // ⓑ 본문이 있는 J-3R 만 맞댄다(`journal_read_not_written` 의 `a_31` 은 작성됨 픽스처에도 있는 전환 표본이라
      //    «미작성 ⇔ null» 은 규칙으로 성립하지 않는다 — 설계서 §4-1 ⑦).
      final Map<String, Map<String, Object?>> written =
          <String, Map<String, Object?>>{
            for (final String path in _readFixtures)
              for (final Map<String, Object?> row in _rawRows(path))
                if (row['body'] != null) row['decision_id']! as String: row,
          };
      final Map<String, Map<String, Object?>> specs =
          <String, Map<String, Object?>>{
            for (final String path in _specFixtures)
              for (final Map<String, Object?> row in _rawRows(path))
                row['decision_id']! as String: row,
          };
      final Map<String, Map<String, Object?>> entries =
          <String, Map<String, Object?>>{
            for (final String path in _entryFixtures)
              for (final Map<String, Object?> row in _rawRows(path))
                (row['decision']! as Map<String, Object?>)['decision_id']!
                        as String:
                    row,
          };
      final Set<String> journalMissing = _journalMissingTargets();
      expect(
        journalMissing,
        isNotEmpty,
        reason: 'safety_states 의 JOURNAL_MISSING 표본을 못 읽었다 — K3 ⓓ 검사가 공허 통과한다.',
      );

      int matchedRead = 0;
      int matchedEntry = 0;
      for (final String path in _beforeFixtures) {
        for (final Map<String, Object?> row in _rawRows(path)) {
          final String id = row['decision_id']! as String;
          final String at = '$path $id';
          expect(
            journalMissing.contains(id),
            isFalse,
            reason:
                '$at — JOURNAL_MISSING 이 서 있는(J-3 작성 창이 열린) 결정은 큐에 넣지 않는다 — J-3 작성 뒤 '
                '들어온다(K3 ⓓ 확정 2026-10-20 · 결과를 본 뒤 «사전» 저널을 쓰는 길).',
          );
          final Map<String, Object?>? vm = written[id];
          if (vm != null) {
            matchedRead++;
            expect(
              row['journal'],
              vm['body'],
              reason: '$at — 같은 결정의 J-3R 본문과 다르다.',
            );
            expect(
              row['journal_state_label'],
              vm['journal_state_label'],
              reason: at,
            );
          }
          final Map<String, Object?>? spec = specs[id];
          if (spec != null) {
            expect(
              row['context_chips'],
              spec['context_chips'],
              reason: '$at — J-3 스펙의 문맥 칩과 다르다.',
            );
            expect(
              row['deviation'],
              spec['deviation'],
              reason: '$at — J-3 스펙의 이탈 배지와 다르다.',
            );
          }
          final Map<String, Object?>? entry = entries[id];
          if (entry != null) {
            matchedEntry++;
            expect(
              row['deviation'],
              entry['deviation'],
              reason: '$at — 일지 행(J-1·J-2)의 이탈 배지와 다르다.',
            );
            expect(
              row['context_chips'],
              entry['reasons'],
              reason: '$at — 일지 행(J-1·J-2)의 사유 칩과 다르다.',
            );
          }
        }
      }
      expect(matchedRead, greaterThan(0), reason: 'J-3R 와 맞대는 표본이 없다(공허 통과).');
      expect(matchedEntry, greaterThan(0), reason: '일지 행과 맞대는 표본이 없다(공허 통과).');
    });

    test('C-43 ⑧ 결과 — 공개 표본 2벌 · 글자 · 금액 꼴 0(K6) · 미청산 ≠ 청산', () {
      final Map<String, BlindReviewResult> results =
          <String, BlindReviewResult>{};
      for (final String path in _revealedPairs.keys) {
        final BlindReviewCard c = _cards(path).single;
        final BlindReviewResult? r = c.result;
        expect(r, isNotNull, reason: '$path — 공개 표본에 결과가 없다.');
        expect(r!.processScoreText, isNotEmpty, reason: path);
        expect(r.outcomeText, isNotEmpty, reason: path);
        for (final String s in <String>[
          r.processScoreText,
          r.outcomeText,
          ...r.detailLines,
        ]) {
          expect(
            _resultMoney.hasMatch(s),
            isFalse,
            reason: '$path — 결과 문장에 금액(원)이 있다: «$s»(K6 확정 — 수익률·보유기간 문장만).',
          );
        }
        results[path] = r;
      }
      expect(
        results[_revealedOpen]!.outcomeText,
        isNot(results[_revealed]!.outcomeText),
        reason: '미청산 표본의 결과 문장이 청산 표본과 같다 — 미청산 장면이 사라졌다.',
      );
    });

    test('C-43 ⑨ 제출 꼴 견본 — 고른 선택지의 score 를 옮긴 BlindReviewScore 가 왕복한다', () {
      for (final String path in _beforeFixtures) {
        for (final BlindReviewCard c in _cards(path)) {
          final BlindReviewScore score = BlindReviewScore(
            decisionId: c.decisionId,
            answers: <String, int>{
              for (final BlindReviewQuestion q in c.questions)
                q.questionId: q.choices.first.score,
            },
          );
          final Map<String, Object?> json =
              jsonDecode(jsonEncode(score.toJson())) as Map<String, Object?>;
          expect(
            BlindReviewScore.fromJson(json),
            score,
            reason: '$path ${c.decisionId}',
          );
          expect(score.answers.keys.toSet(), <String>{
            for (final BlindReviewQuestion q in c.questions) q.questionId,
          }, reason: '전 문항을 싣는다(부분 제출 없음 — K10).');
        }
      }
    });

    test('C-43 ⑩ 대상 수 · 가드 — J-4 전용 이름은 대상 파일에만', () {
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('$_j4Package/lib/'),
        ),
        isNotEmpty,
        reason: 'ui_journal/lib 를 못 읽었다 — 경로가 낡았다(빈 입력은 늘 통과한다).',
      );
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('packages/ui_shell/'),
        ),
        isEmpty,
        reason:
            '셸(ui_shell)은 배선 자리라 가드에서 뺀다(override 자리 = 조립 앱 apps/app_*/lib).',
      );
      final List<String> files = _targets.keys.toList()..sort();
      _say(
        'C-43 ⑩ 대상 J-4 ${files.length}파일 — $_j4Package/$_j4PublicFile + '
        '$_j4Package/$_j4InternalDir**'
        '${files.isEmpty ? ' — ⑪~⑯ 공허 통과' : '\n    ${files.join('\n    ')}'}',
      );
      final List<String> bad = _j4MentionsOutside(_guardSources);
      expect(
        bad,
        isEmpty,
        reason:
            'J-4 전용 DTO·창구·명령·주입 이름을 말하는 `ui_*/lib` 파일은 대상(`$_j4PublicFile` + '
            '`$_j4InternalDir**`)에만 둔다 — 밖에 두면 ⑪~⑯ 이 그 파일을 보지 않는다(셸은 제외).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑪ 호출 — 금지 목록 0 · 큐는 인자 없이', () {
      final List<String> bad = _violations('⑪');
      expect(
        bad,
        isEmpty,
        reason:
            'J-4 는 `watchBlindReviewQueue()`(인자 없이) · `watchBlindReviewCard` · `submitBlindReviewScore` · '
            '`watchCommand` + 안전 상태 `journalSafetyStateProvider` 재사용만 쓴다 — 다른 일지 창구·안전 상태 직접 구독·'
            '보유·성과·초안 포트·operator 명령 주입·다른 명령(`recordDisclosureView` 포함 · K6) 0(01 §16 호출 표).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑫ 점수 — 맵 값 자리에 옮길 뿐 · 표시·합산·비교 0', () {
      final List<String> bad = _violations('⑫');
      expect(
        bad,
        isEmpty,
        reason:
            '선택지 `score` 는 `BlindReviewScore.answers[questionId]` 에 그대로 옮기는 값이다 — 화면에 그리거나'
            '(«1점») 더하거나 비교하지 않는다(02 §3-4 금지 ① · 과정 점수 = `processScoreText`).\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑬ 원값·키 — id 표시 0 · 이탈·거부 코드 분기 0 · result 강제 0', () {
      final List<String> bad = _violations('⑬');
      expect(
        bad,
        isEmpty,
        reason:
            '`decisionId`·`questionId` 는 키다(표시 금지) · 이탈 여부·저널 id·거부 사유 코드·칩 코드로 분기하지 않는다 · '
            '결과는 `result != null` 갈래 안에서만 읽는다(`!` 강제 0).\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑭ 분기·셸·포맷 낱말 0 — operator 라이브러리 import 0', () {
      final List<String> bad = _violations('⑭');
      expect(
        bad,
        isEmpty,
        reason:
            '운영 모드·플랫폼 분기 · 시계 직접 · Scaffold/AppBar/SafeArea(셸 소유) · 숫자 포맷 · `journal_draft`'
            '(operator 라이브러리 — J-4 는 iOS·웹 뷰어도 쓴다 · T-3 · C-35 ⑥) 0.\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑮ 문자열 가공·정렬·거르기 0 — 원문 자르기 0', () {
      final List<String> bad = _violations('⑮');
      expect(
        bad,
        isEmpty,
        reason:
            '엔진 글자·사람이 쓴 원문을 잘라 붙이거나 줄이지 않고(`maxLines`·말줄임·`trim` 0), 큐를 다시 정렬·거르지 '
            '않는다(`rows[0]` · `.indexed`·`.map`·`.length`·`.every`·`.first` 는 허용 · 배너의 차단/표식 분리는 '
            '대상 밖 `JournalSafetyBanners`).\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑯ 숫자 리터럴 — 소수 리터럴·%·원 문자열 0', () {
      final List<String> bad = _violations('⑯');
      expect(
        bad,
        isEmpty,
        reason:
            '점수·결과 수치와 단위는 엔진 글자로 온다 — 화면에 소수 리터럴(`N.0` 제외)·`%`·`원` 문자열을 적지 않는다.'
            '\n${bad.join('\n')}',
      );
    });

    test('C-43 ⑰ 자체 검증 — 양성은 걸리고 음성은 통과한다', () {
      for (final (String snippet, String clause) in _positives) {
        final Set<String> got = <String>{
          for (final _Hit h in _scan(snippet)) h.clause,
        };
        expect(
          got,
          contains(clause),
          reason: '양성 스니펫을 못 잡았다($clause): $snippet',
        );
        _say('C-43 ⑰ 양성 $snippet → ${(got.toList()..sort()).join('')}');
      }
      for (final String snippet in _negatives) {
        expect(_scan(snippet), isEmpty, reason: '음성 스니펫을 잘못 잡았다: $snippet');
      }
      // ⑯ 문자열 추출 — 주석 속 `%` 는 대상이 아니고 문자열 속 `%` 는 대상이다.
      expect(
        _stringLiterals(stripComments("// 10% 아님\nText('a%b');\n")),
        <String>["'a%b'"],
      );
      // ⑩ 가드 — 대상 밖 경로만 걸린다(주석 속 언급 · 라벨 이름은 통과).
      expect(
        _j4MentionsOutside(<String, String>{
          '$_j4Package/$_j4PublicFile': 'void f(BlindReviewCard c) {}\n',
          '$_j4Package/${_j4InternalDir}question.dart':
              'void f(BlindReviewChoice c) {}\n',
          '$_j4Package/lib/src/common/x.dart': 'void f(BlindReviewCard c) {}\n',
          '$_j4Package/lib/src/timeline.dart':
              '// BlindReviewCard 는 J-4 만 말한다\n',
          '$_j4Package/lib/l10n/labels.dart':
              "static const String blindReviewNotice = 'x';\n",
          'packages/ui_analytics/lib/a.dart':
              'final p = journalBlindReviewCommandApiProvider;\n',
        }),
        <String>[
          '$_j4Package/lib/src/common/x.dart',
          'packages/ui_analytics/lib/a.dart',
        ],
      );
      _say('C-43 ⑰ 양성 [대상 밖 lib/src/common/x.dart] BlindReviewCard → ⑩');
    });
  });
}
