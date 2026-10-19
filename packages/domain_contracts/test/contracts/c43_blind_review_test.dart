// C-43 J-4 사후 blind 리뷰 — 01 §16 · §7 표 C-43(🆕 계약 v1.7 · 미결 46 설계서 2026-10-19 §4-1).
//
// 정의: 「`J-4` 는 엔진이 고른 대기 카드 한 장을 고정해 그 카드 스트림만 보고 그린다 — 채점 전 카드에는 결과가
//   **없고**, 화면은 고른 선택지의 `score` 를 `BlindReviewScore.answers` 에 **옮길 뿐**이며, 결과 섹션은
//   `result != null` 하나로만 연다」. C-41(픽스처 불변식) + C-42(화면 소스 스캔)를 한 파일에 둔다(대상이 한 화면).
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
// 🔴 숫자를 이 파일에 적지 않는다 — 자체 검증 스니펫의 수치는 뜻 없는 자리표시자다.

import 'dart:io';

import 'package:test/test.dart';

import 'c00_support.dart';

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
