// ============================================================================
// precheck.dart — 푸시 전 사전검사(화면 담당이 PR 을 올리기 전에 스스로 돌린다)
//
// 왜 있나: C4 병합 검사의 반려 사유 중 «같은 꼴이 카드를 바꿔 가며 다시 나는 것»을
//   리뷰가 아니라 제출 전 기계 검사로 옮긴다(2026-10-19 점검 — 첫 제출 반려율 81% ·
//   else 없는 if 세 번째 = R11b C4b-5 · R12b C12b-1 · R12d C12d-1).
//
// 무엇을 보나(커밋된 HEAD 를 base 와의 공통 조상부터 비교 — PR 이 바꾼 줄만 · ui_*·apps 의 test/):
//   [T1] 🔴 else 없는 if — 문장 if 가 else 없이 단언·조용한 건너뛰기·빈 블록·목록 넣기를 품는가
//              (탭·pump 같은 동작만 하는 if · 값을 돌려주는 가짜 안의 if 는 걸지 않는다)
//              + null 검사 if 안의 흐름 칸 호출(if (s != null) { await s(tester); }) · C4r14b-3
//   [T2] 🔴 collection-if 개수 — 목록·집합 안의 if 수가 카드가 정한 수(--collection-if)와 같은가
//   [T3] 🔴 늘 참 단언 — 코드 모양만으로 결과가 정해지는 expect(…)(anything · 상수끼리 · 같은 식 ·
//              한 값과 같은 것만 남긴 목록의 any/every · find.byType(Text·Icon·Padding …) +
//              findsWidgets/findsAtLeast 단독 — C4r14b-3 · C4r15a-3)
//   [T4] 🔴 빈 루프 단언 — 화면에서 찾은 목록(widgetList·evaluate …)을 도는 단언 루프 앞에
//              그 목록의 expect(양성 기준점)가 없는가(픽스처 목록은 ⓗ 몫이라 보지 않는다)
//   [T5] 🔴 ⓗ 한 줄 — hasLength( 를 품은 expect 가 dart format 뒤 여러 줄
//   [T6] 🟡 가짜 공장 안 if — «(int call) {» 블록 몸 안의 if(--factory-if 0 이면 🔴) · C4r8a-2
//   [T7] 🟡 쓰기만 하는 셈 변수 — 지역 «int <이름> = 0;» 을 대입·증감만 하고 읽지 않음 · C4r8a-2
//   [R1] 🔴 보고 글 첫 줄 = «## ① …» · 섹션 머리 5줄이 글자 그대로 · 차례대로 한 번씩
//   [R2] 🔴 색·테마 이름 0(명령 출력 코드 블록 밖)
//   [R3] 🔴 골든 표 행 수 = --goldens · «— 잘림 …» 꼬리 행 수가 같다 · 배치·잘림 칸 영문 0 · 금지 말 0
//   [R4] 🔴 S05 결과 줄 꼴(«<파일>:<줄> — 탭 콜백 안») · 정적 묶음 S05 출력과 같은 줄
//   [R5] 🔴 12항 괄호 비움 0 · «flutter test: 시작 기준 N → 끝 <끝 줄>» 꼴
//   [R6] 🔴 «ⓡ = T20 출력:»·«ⓗ = T21 출력:» 아래 줄 = 같은 글 정적 블록 «## T20»·«## T21» 출력 · C4r9a-6
//   [R7] 🟡 check:labels 줄 «apps/** N» = head 에서 check_labels.sh 를 Git Bash 로 다시 잰 «/apps/» 줄 수
//              (bash 를 못 찾으면 세지 않고 알리기만 · --no-labels 로 끔) · C4r9a-6
//   [R8] 🟡 ② 복사 상자(번호 줄) 바로 뒤 빈 줄 = 정확히 1(«N항 줄 수:» 상자를 붙이는 꼴만) · C4r9c-3
//   [R9] 🔴 ① «바뀐 파일:»·«커밋 목록:» 블록 줄 수 = git 출력 줄 수 · 깨진 글자(U+FFFD · «쨌») 0
//              (한자 = 🟡 깨짐일 수 있다) · C4r14b-3
//   [G1] 🟡 골든 표 «글자 n줄»·덩어리 차례 ↔ PNG 에서 센 글자 행·덩어리(PNG 를 다시 열 신호)
//
// 어떻게 부르나(저장소 루트에서 · 카드가 준 줄 그대로):
//   dart tool/precheck.dart --base origin/main --collection-if 0 \
//        --report <제출 글 파일> --golden-prefix s710_ --goldens 12
//   (Windows PowerShell 5.1 은 먼저 [Console]::OutputEncoding = [Text.Encoding]::UTF8)
// 끝 코드: 0 = 🔴 0건(🟡 는 남을 수 있다) · 1 = 🔴 있음 · 2 = 쓰는 법·git 오류
//
// 🔵 외부 패키지 없이 dart:io 만 쓴다 — pub get 없이 Git Bash·PowerShell·리눅스 CI 어디서나 돈다.
// 🔴 이 검사를 통과시키려고 규칙을 줄이지 말 것. 헛경보라고 생각되면 카드·설계 12 §3 을 먼저 고친다.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ── 결과 모음 ────────────────────────────────────────────────────────────────

class Finding {
  Finding(this.red, this.code, this.where, this.message);

  final bool red;
  final String code;
  final String where;
  final String message;
}

final List<Finding> findings = <Finding>[];

/// 판정이 아닌 알림(다시 잰 수 · 건너뛴 까닭) — 결과 머리에 한 줄씩.
final List<String> notes = <String>[];

void red(String code, String where, String message) =>
    findings.add(Finding(true, code, where, message));

void yellow(String code, String where, String message) =>
    findings.add(Finding(false, code, where, message));

void say(String line) => stdout.writeln(line);

// ── 옵션 ────────────────────────────────────────────────────────────────────

class Options {
  String repo = '.';
  String base = 'origin/main';
  String head = 'HEAD';
  int? collectionIf = 0; // null = 카드가 수를 정하지 않음(세기만)
  bool factoryIfZero = false; // true = 카드가 «공장 안 if 0» 을 정함(T6 🔴)
  String? report;
  bool labelsRerun = true; // R7 — check:labels 수를 head 에서 다시 잰다
  String? goldenPrefix;
  int? goldens;
}

const String usage = '''
쓰는 법: dart tool/precheck.dart [옵션]
  --base <rev>            비교 기준(기본 origin/main · 공통 조상부터 본다)
  --head <rev>            검사할 커밋(기본 HEAD)
  --repo <폴더>           저장소 루트(기본 .)
  --collection-if <N|any> 테스트 코드의 collection-if 기대 수(기본 0 · any = 세기만)
  --factory-if <0|any>    가짜 공장 몸 안 if 기대(0 = 카드가 «공장 안 if 0» → 🔴 · 기본 any = 🟡)
  --report <파일>         채팅 보고 글(①~⑤)을 저장한 UTF-8 파일
  --no-labels             R7(check:labels 수 다시 재기 · Git Bash 필요)을 건너뛴다
  --golden-prefix <접두>  골든 이름 접두(예 s710_) — 골든 표·PNG 검사
  --goldens <N>           골든 표 행 수(이름 × 밝기)
''';

Options parseArgs(List<String> args) {
  final Options o = Options();
  for (int i = 0; i < args.length; i++) {
    final String a = args[i];
    String next() {
      if (i + 1 >= args.length) {
        stderr.writeln('$a 뒤에 값이 없다\n$usage');
        exit(2);
      }
      return args[++i];
    }

    switch (a) {
      case '--repo':
        o.repo = next();
      case '--base':
        o.base = next();
      case '--head':
        o.head = next();
      case '--collection-if':
        final String v = next();
        o.collectionIf = v == 'any' ? null : int.tryParse(v);
        if (v != 'any' && o.collectionIf == null) {
          stderr.writeln('--collection-if 는 숫자 또는 any\n$usage');
          exit(2);
        }
      case '--factory-if':
        final String v = next();
        if (v != '0' && v != 'any') {
          stderr.writeln('--factory-if 는 0 또는 any\n$usage');
          exit(2);
        }
        o.factoryIfZero = v == '0';
      case '--report':
        o.report = next();
      case '--no-labels':
        o.labelsRerun = false;
      case '--golden-prefix':
        o.goldenPrefix = next();
      case '--goldens':
        o.goldens = int.tryParse(next());
      case '-h':
      case '--help':
        stdout.write(usage);
        exit(0);
      default:
        stderr.writeln('모르는 옵션: $a\n$usage');
        exit(2);
    }
  }
  return o;
}

// ── git ─────────────────────────────────────────────────────────────────────

late String repoDir;

String git(List<String> args) {
  final ProcessResult r = Process.runSync(
    'git',
    <String>['-C', repoDir, '-c', 'core.quotePath=false', ...args],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (r.exitCode != 0) {
    stderr.writeln('git ${args.join(' ')} 실패:\n${r.stderr}');
    exit(2);
  }
  return r.stdout as String;
}

Uint8List gitBytes(String rev, String path) {
  final ProcessResult r = Process.runSync('git', <String>[
    '-C',
    repoDir,
    'show',
    '$rev:$path',
  ], stdoutEncoding: null);
  if (r.exitCode != 0) {
    return Uint8List(0);
  }
  return Uint8List.fromList(r.stdout as List<int>);
}

/// `git diff -U0` 의 «+» 쪽 줄 번호 집합.
Set<int> addedLines(String mergeBase, String head, String path) {
  final Set<int> out = <int>{};
  final RegExp hunk = RegExp(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@');
  for (final String line in const LineSplitter().convert(
    git(<String>['diff', '-U0', '--no-color', mergeBase, head, '--', path]),
  )) {
    final RegExpMatch? m = hunk.firstMatch(line);
    if (m == null) {
      continue;
    }
    final int start = int.parse(m.group(1)!);
    final int count = m.group(2) == null ? 1 : int.parse(m.group(2)!);
    for (int l = start; l < start + count; l++) {
      out.add(l);
    }
  }
  return out;
}

// ── Dart 토큰 ───────────────────────────────────────────────────────────────
// 분석기 패키지 없이 쓰는 작은 어휘 분석 — 주석·문자열(보간 포함)을 건너뛰고 괄호 짝을 맞춘다.

enum TokKind { ident, number, string, punct }

class Tok {
  Tok(this.kind, this.text, this.line);

  final TokKind kind;
  final String text;
  final int line;

  bool get isLiteral =>
      kind == TokKind.number ||
      kind == TokKind.string ||
      text == 'true' ||
      text == 'false' ||
      text == 'null';
}

const List<String> multiPunct = <String>[
  '...?',
  '?..',
  '...',
  '??=',
  '=>',
  '==',
  '!=',
  '<=',
  '>=',
  '&&',
  '||',
  '??',
  '?.',
  '..',
  '++',
  '--',
  '+=',
  '-=',
  '*=',
  '/=',
  '~/',
];

class Lexer {
  Lexer(this.src);

  final String src;
  int i = 0;
  int line = 1;
  final List<Tok> toks = <Tok>[];

  static bool isIdStart(int c) =>
      (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 || c == 36;

  static bool isIdPart(int c) => isIdStart(c) || (c >= 48 && c <= 57);

  List<Tok> run() {
    final int n = src.length;
    while (i < n) {
      final int c = src.codeUnitAt(i);
      if (c == 10) {
        line++;
        i++;
      } else if (c == 32 || c == 9 || c == 13) {
        i++;
      } else if (src.startsWith('//', i)) {
        while (i < n && src.codeUnitAt(i) != 10) {
          i++;
        }
      } else if (src.startsWith('/*', i)) {
        skipBlockComment();
      } else if (c == 39 || c == 34) {
        final int startLine = line;
        final int s = i;
        scanString(raw: false);
        toks.add(Tok(TokKind.string, src.substring(s, i), startLine));
      } else if (isIdStart(c)) {
        final int s = i;
        while (i < n && isIdPart(src.codeUnitAt(i))) {
          i++;
        }
        final String id = src.substring(s, i);
        if (id == 'r' && i < n && (src[i] == "'" || src[i] == '"')) {
          final int startLine = line;
          scanString(raw: true);
          toks.add(Tok(TokKind.string, src.substring(s, i), startLine));
        } else {
          toks.add(Tok(TokKind.ident, id, line));
        }
      } else if (c >= 48 && c <= 57) {
        final int s = i;
        while (i < n &&
            (isIdPart(src.codeUnitAt(i)) ||
                (src[i] == '.' &&
                    i + 1 < n &&
                    src.codeUnitAt(i + 1) >= 48 &&
                    src.codeUnitAt(i + 1) <= 57))) {
          i++;
        }
        toks.add(Tok(TokKind.number, src.substring(s, i), line));
      } else {
        String? p;
        for (final String m in multiPunct) {
          if (src.startsWith(m, i)) {
            p = m;
            break;
          }
        }
        p ??= src[i];
        toks.add(Tok(TokKind.punct, p, line));
        i += p.length;
      }
    }
    return toks;
  }

  void skipBlockComment() {
    int depth = 0;
    while (i < src.length) {
      if (src.startsWith('/*', i)) {
        depth++;
        i += 2;
      } else if (src.startsWith('*/', i)) {
        depth--;
        i += 2;
        if (depth == 0) {
          return;
        }
      } else {
        if (src.codeUnitAt(i) == 10) {
          line++;
        }
        i++;
      }
    }
  }

  void scanString({required bool raw}) {
    final String q = src[i];
    final bool triple = src.startsWith(q * 3, i);
    i += triple ? 3 : 1;
    while (i < src.length) {
      final String ch = src[i];
      if (!raw && ch == r'\') {
        i += 2;
        continue;
      }
      if (ch == '\n') {
        line++;
      }
      if (!raw && ch == r'$' && i + 1 < src.length && src[i + 1] == '{') {
        i += 2;
        skipInterpolation();
        continue;
      }
      if (triple ? src.startsWith(q * 3, i) : ch == q) {
        i += triple ? 3 : 1;
        return;
      }
      i++;
    }
  }

  void skipInterpolation() {
    int depth = 1;
    while (i < src.length) {
      final String ch = src[i];
      if (ch == "'" || ch == '"') {
        scanString(raw: i > 0 && src[i - 1] == 'r');
        continue;
      }
      if (ch == '\n') {
        line++;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          i++;
          return;
        }
      }
      i++;
    }
  }
}

/// 괄호 짝 · 둘러싼 괄호 · 중괄호가 «블록»인지 «컬렉션»인지.
class Structure {
  Structure(this.toks) {
    final int n = toks.length;
    match = List<int>.filled(n, -1);
    enclosing = List<int>.filled(n, -1);
    literalBrace = List<bool>.filled(n, false);
    final List<int> stack = <int>[];
    for (int k = 0; k < n; k++) {
      enclosing[k] = stack.isEmpty ? -1 : stack.last;
      final String t = toks[k].text;
      if (toks[k].kind != TokKind.punct) {
        continue;
      }
      if (t == '(' || t == '[' || t == '{') {
        if (t == '{') {
          literalBrace[k] = classifyBrace(k);
        }
        stack.add(k);
      } else if (t == ')' || t == ']' || t == '}') {
        if (stack.isNotEmpty) {
          final int open = stack.removeLast();
          match[open] = k;
          match[k] = open;
        }
      }
    }
  }

  final List<Tok> toks;
  late final List<int> match;
  late final List<int> enclosing;
  late final List<bool> literalBrace;

  String t(int k) => k >= 0 && k < toks.length ? toks[k].text : '';

  bool isCollectionContext(int k) {
    final int e = enclosing[k];
    if (e < 0) {
      return false;
    }
    return t(e) == '[' || (t(e) == '{' && literalBrace[e]);
  }

  bool classifyBrace(int k) {
    final String p = t(k - 1);
    const Set<String> literalBefore = <String>{
      '=>',
      '>',
      '=',
      '(',
      ',',
      '[',
      ':',
      '?',
      '??',
      '...',
      '...?',
      'return',
      '&&',
      '||',
      '!',
      '==',
      'yield',
      'await',
      'const',
    };
    if (literalBefore.contains(p)) {
      return true;
    }
    if (p == '{') {
      final int e = enclosing[k];
      return e >= 0 && literalBrace[e];
    }
    if (p == ')') {
      // 컬렉션 안의 if (…) {…} / for (…) {…} 는 집합 원소다.
      final int open = match[k - 1];
      final String kw = open > 0 ? t(open - 1) : '';
      return (kw == 'if' || kw == 'for') && isCollectionContext(open - 1);
    }
    return false;
  }

  /// t 에서 시작한 문장의 끝(`;`) 위치.
  int statementEnd(int k) {
    int j = k;
    while (j < toks.length) {
      final String s = t(j);
      if ((s == '(' || s == '[' || s == '{') && match[j] > j) {
        j = match[j] + 1;
        continue;
      }
      if (s == ';') {
        return j;
      }
      if (s == '}' || s == ')' || s == ']') {
        return j - 1;
      }
      j++;
    }
    return toks.length - 1;
  }

  /// `if`/`for` 의 몸(블록이면 `{`…`}` · 아니면 한 문장) 범위.
  (int, int) bodyRange(int afterParen) {
    if (t(afterParen) == '{' && match[afterParen] > afterParen) {
      return (afterParen, match[afterParen]);
    }
    return (afterParen, statementEnd(afterParen));
  }

  List<List<Tok>> splitArgs(int open) {
    final List<List<Tok>> out = <List<Tok>>[<Tok>[]];
    final int close = match[open];
    int j = open + 1;
    while (j < close) {
      final String s = t(j);
      if ((s == '(' || s == '[' || s == '{') && match[j] > j) {
        out.last.addAll(toks.sublist(j, match[j] + 1));
        j = match[j] + 1;
        continue;
      }
      if (s == ',') {
        out.add(<Tok>[]);
      } else {
        out.last.add(toks[j]);
      }
      j++;
    }
    if (out.last.isEmpty) {
      out.removeLast();
    }
    return out;
  }
}

String joinToks(Iterable<Tok> ts) => ts.map((Tok x) => x.text).join(' ');

const Set<String> assertCalls = <String>{
  'expect',
  'expectLater',
  'fail',
  'markTestSkipped',
};

const Set<String> constMatchers = <String>{
  'isTrue',
  'isFalse',
  'isNull',
  'isNotNull',
  'isEmpty',
  'isNotEmpty',
};

/// 어느 화면을 펌프해도 트리에 있는 틀·글자 위젯 — find.byType(X) + findsWidgets 가 늘 참.
const Set<String> everywhereWidgets = <String>{
  'Text',
  'RichText',
  'Icon',
  'Padding',
  'SizedBox',
  'Container',
  'Column',
  'Row',
  'Center',
  'Align',
  'DecoratedBox',
  'ColoredBox',
  'Material',
  'Semantics',
  'Directionality',
  'MediaQuery',
  'Theme',
  'DefaultTextStyle',
  'Builder',
};

bool hasAssert(Structure s, int from, int to) {
  for (int j = from; j <= to && j < s.toks.length; j++) {
    if (assertCalls.contains(s.t(j)) && s.t(j + 1) == '(') {
      return true;
    }
  }
  return false;
}

// ── 테스트 코드 검사 ────────────────────────────────────────────────────────

class TestFile {
  TestFile(this.path, this.src, this.added);

  final String path;
  final String src;
  final Set<int>? added; // null = 새 파일(모든 줄)

  bool touched(int from, int to) {
    if (added == null) {
      return true;
    }
    for (int l = from; l <= to; l++) {
      if (added!.contains(l)) {
        return true;
      }
    }
    return false;
  }

  bool get isTest => path.endsWith('_test.dart');
}

int collectionIfTotal = 0;
final List<String> collectionIfWhere = <String>[];

void checkTestFile(TestFile f, {bool factoryIfZero = false}) {
  final List<Tok> toks = Lexer(f.src).run();
  final Structure s = Structure(toks);
  String at(int k) => '${f.path}:${toks[k].line}';
  checkFakeFactories(f, s, factoryIfZero: factoryIfZero);
  checkWriteOnlyCounters(f, s);

  // 같은 값만 남긴 목록(T3 · R12c C12c-1 꼴): V = ….where((e) => e == '…')
  final Map<String, int> equalityFiltered = <String, int>{};
  for (int k = 1; k + 1 < toks.length; k++) {
    if (s.t(k) != '=' ||
        toks[k - 1].kind != TokKind.ident ||
        s.t(k - 2) == '.') {
      continue;
    }
    final int end = s.statementEnd(k + 1);
    for (int j = k + 1; j < end - 6; j++) {
      if (s.t(j) == 'where' && s.t(j + 1) == '(' && s.t(j + 2) == '(') {
        final int pClose = s.match[j + 2];
        if (pClose < 0) {
          continue;
        }
        final String param = s.t(pClose - 1);
        final List<Tok> body = <Tok>[
          for (int q = pClose + 1; q < s.match[j + 1]; q++) toks[q],
        ];
        final bool eqLit =
            body.length == 4 &&
            body[0].text == '=>' &&
            body[2].text == '==' &&
            ((body[1].text == param && body[3].kind == TokKind.string) ||
                (body[1].kind == TokKind.string && body[3].text == param));
        if (eqLit) {
          equalityFiltered[toks[k - 1].text] = k;
        }
      }
    }
  }

  for (int k = 0; k < toks.length; k++) {
    final String w = s.t(k);

    // ── if ─────────────────────────────────────────────────────────────────
    if (w == 'if' && s.t(k + 1) == '(' && s.match[k + 1] > k) {
      final int condClose = s.match[k + 1];
      if (s.isCollectionContext(k)) {
        if (f.touched(toks[k].line, toks[condClose].line)) {
          collectionIfTotal++;
          collectionIfWhere.add(at(k));
        }
        continue;
      }
      final (int bodyStart, int bodyEnd) = s.bodyRange(condClose + 1);
      final bool hasElse = s.t(bodyEnd + 1) == 'else';
      final int endLine =
          toks[bodyEnd < toks.length ? bodyEnd : toks.length - 1].line;
      if (hasElse || !f.touched(toks[k].line, endLine)) {
        continue;
      }
      final bool empty = s.t(bodyStart) == '{' && bodyEnd == bodyStart + 1;
      bool silentSkip = false;
      bool addsToList = false;
      for (int j = bodyStart; j <= bodyEnd; j++) {
        final String b = s.t(j);
        if ((b == 'return' || b == 'continue' || b == 'break') &&
            s.t(j + 1) == ';') {
          silentSkip = true;
        }
        if (s.t(j - 1) == '.' &&
            (b == 'add' || b == 'addAll') &&
            s.t(j + 1) == '(') {
          addsToList = true;
        }
      }
      if (empty && f.isTest) {
        red('T1', at(k), '빈 if 블록 — 단언을 넣거나 if 를 지운다');
      } else if (hasAssert(s, bodyStart, bodyEnd)) {
        red(
          'T1',
          at(k),
          'else 없는 if 안의 단언 — 조건이 거짓이면 아무것도 단언하지 않는다. '
              '없는 쪽도 else 로 단언하거나(if/else 짝), if 없이 단언한다(카드 규칙 11)',
        );
      } else if (silentSkip && f.isTest) {
        red('T1', at(k), '조용한 건너뛰기(return;·continue;·break;) — 전제는 expect 로');
      } else if (addsToList && f.isTest) {
        red(
          'T1',
          at(k),
          'else 없는 if 로 목록에 넣는다 — 없는 쪽은 else 에서 findsNothing 으로 단언한다'
              '(사슬 «없는 쪽» 견본 ㉠ · R11b F1)',
        );
      } else if (f.isTest &&
          nullSlotCall(s, k + 2, condClose - 1, bodyStart, bodyEnd)) {
        red(
          'T1',
          at(k),
          'null 검사 if 안의 흐름 칸 호출(if (s != null) { await s(tester); }) — 칸이 null 이면 '
              '동작도 단언도 없이 지나간다. 칸을 non-null 로 받거나(빈 동작도 함수로) if 없이 '
              '부른다(C4r14b-3 · R15 nullable steps)',
        );
      }
      continue;
    }

    // ── for (… in …) ───────────────────────────────────────────────────────
    if (w == 'for' && s.t(k + 1) == '(' && s.match[k + 1] > k && f.isTest) {
      final int close = s.match[k + 1];
      int inAt = -1;
      for (int j = k + 2; j < close; j++) {
        if (s.t(j) == 'in' && s.enclosing[j] == k + 1) {
          inAt = j;
          break;
        }
      }
      if (inAt < 0 || s.isCollectionContext(k)) {
        continue;
      }
      final (int bodyStart, int bodyEnd) = s.bodyRange(close + 1);
      if (!hasAssert(s, bodyStart, bodyEnd) ||
          !f.touched(toks[k].line, toks[close].line) ||
          makesTests(s, bodyStart, bodyEnd)) {
        continue;
      }
      final List<Tok> iter = toks.sublist(inAt + 1, close);
      final String iterText = joinToks(iter);
      // 화면에서 찾은 목록(widgetList · evaluate …)만 본다 — 픽스처 목록은 ⓗ(hasLength)가 맡는다.
      final bool direct = queriesScreen(iter);
      final bool viaVar =
          iter.length == 1 &&
          iter.first.kind == TokKind.ident &&
          declaredFromScreen(s, iter.first.text);
      if (!direct && !viaVar) {
        continue;
      }
      if (viaVar && anchoredBefore(s, k, iter)) {
        continue;
      }
      red(
        'T4',
        at(k),
        '빈 루프 단언 — 화면에서 찾은 «$iterText» 가 비면 루프가 0번 돌아 늘 통과한다. '
            '목록을 변수로 받고 루프 앞에 expect(<변수>, isNotEmpty); 를 둔다(C4d-1 견본)',
      );
      continue;
    }

    // ── expect(…) ───────────────────────────────────────────────────────────
    if (w == 'expect' && s.t(k + 1) == '(' && s.match[k + 1] > k) {
      final int close = s.match[k + 1];
      if (!f.touched(toks[k].line, toks[close].line)) {
        continue;
      }
      final List<List<Tok>> args = s.splitArgs(k + 1);
      if (args.length >= 2) {
        final List<Tok> a0 = args[0];
        final List<Tok> a1 = args[1];
        final String t0 = joinToks(a0);
        final String t1 = joinToks(a1);
        if (t1 == 'anything') {
          red('T3', at(k), '늘 참 단언 — expect(…, anything)');
        } else if (a0.length == 1 &&
            a0.first.isLiteral &&
            ((a1.length == 1 && a1.first.isLiteral) ||
                constMatchers.contains(t1) ||
                (a1.length == 4 &&
                    a1.first.text == 'equals' &&
                    a1[2].isLiteral))) {
          red('T3', at(k), '늘 참(또는 늘 거짓) 단언 — 첫 인자가 상수 «${a0.first.text}»');
        } else if (t0 == t1 && t0.isNotEmpty) {
          red('T3', at(k), '늘 참 단언 — 두 인자가 같은 식 «$t0»');
        } else if (t1 == 'greaterThanOrEqualTo ( 0 )' &&
            t0.endsWith('. length')) {
          red('T3', at(k), '늘 참 단언 — 길이 >= 0');
        } else if (t1 == 'findsAtLeastNWidgets ( 0 )' ||
            t1 == 'findsAtLeast ( 0 )') {
          red('T3', at(k), '늘 참 단언 — 0개 이상');
        } else if (t1 == 'isNotNull' &&
            a0.isNotEmpty &&
            a0.first.text == 'find') {
          red('T3', at(k), '늘 참 단언 — Finder 는 null 이 아니다');
        } else if (a0.length == 6 &&
            t0.startsWith('find . byType (') &&
            a0[5].text == ')' &&
            everywhereWidgets.contains(a0[4].text) &&
            (t1 == 'findsWidgets' ||
                RegExp(r'^findsAtLeast(NWidgets)? \( \d+ \)$').hasMatch(t1))) {
          red(
            'T3',
            at(k),
            '늘 참 단언 — find.byType(${a0[4].text}) 는 어느 화면에나 있다($t1). '
                'Key·descendant 로 좁히고 글자·수를 단언한다(C4r14b-3 · C4r15a-3)',
          );
        } else if (a0.length >= 4 &&
            equalityFiltered.containsKey(a0[0].text) &&
            a0[1].text == '.' &&
            const <String>{
              'any',
              'every',
              'contains',
              'where',
            }.contains(a0[2].text)) {
          red(
            'T3',
            at(k),
            '값이 미리 정해진 단언 — «${a0[0].text}» 는 '
                '${f.path}:${toks[equalityFiltered[a0[0].text]!].line} 에서 '
                '한 값과 같은 것만 남긴 목록이라 ${a0[2].text}(…) 결과가 코드 모양만으로 정해진다. '
                '거르기 전 목록으로 단언한다',
          );
        }
      }
      if (f.isTest &&
          toks[k].line != toks[close].line &&
          hasLengthInside(s, k + 1, close)) {
        red(
          'T5',
          at(k),
          'ⓗ 가 여러 줄(${toks[k].line}~${toks[close].line}행) — 기대 수를 final int '
              '변수나 경우 목록 레코드로 받아 expect(<목록>, hasLength(n)); 한 줄로',
        );
      }
    }
  }
}

/// `X != null`(X = 이름 · a.b 사슬) 조건에 몸이 그 X 를 부르는 한 문장뿐인가
/// (`await X(…);` · `X!(…);` · `X.call(…);` · `X!.call(…);`).
bool nullSlotCall(Structure s, int c0, int c1, int b0, int b1) {
  List<String> chainAt(int from, int to) {
    final List<String> out = <String>[];
    for (int j = from; j <= to; j++) {
      out.add(s.t(j));
    }
    return out;
  }

  bool isChain(List<String> xs) {
    if (xs.isEmpty || xs.length.isEven) {
      return false;
    }
    for (int i = 0; i < xs.length; i++) {
      final bool dot = i.isOdd;
      if (dot ? xs[i] != '.' : !RegExp(r'^[A-Za-z_$][\w$]*$').hasMatch(xs[i])) {
        return false;
      }
    }
    return true;
  }

  List<String> slot;
  if (s.t(c1) == 'null' && s.t(c1 - 1) == '!=') {
    slot = chainAt(c0, c1 - 2);
  } else if (s.t(c0) == 'null' && s.t(c0 + 1) == '!=') {
    slot = chainAt(c0 + 2, c1);
  } else {
    return false;
  }
  if (!isChain(slot)) {
    return false;
  }
  int j = b0;
  int end = b1;
  if (s.t(b0) == '{') {
    j = b0 + 1;
    end = b1 - 1;
  }
  if (s.t(j) == 'await') {
    j++;
  }
  for (final String x in slot) {
    if (s.t(j) != x) {
      return false;
    }
    j++;
  }
  if (s.t(j) == '!') {
    j++;
  }
  if ((s.t(j) == '.' || s.t(j) == '?.') && s.t(j + 1) == 'call') {
    j += 2;
  }
  if (s.t(j) != '(' || s.match[j] <= j) {
    return false;
  }
  j = s.match[j] + 1;
  return s.t(j) == ';' && j == end;
}

/// [T6] 가짜 공장 블록 몸 안 if(C4r8a-2 · R8a C4X-1) — `(int call) {` · `name: (int n) {` 꼴의
/// 함수 literal 몸 안 `if (` 를 센다. 공장은 받은 call 로 삼항 한 식(C4r4b-7)이라 몸 안 if 는
/// 경우 가르기·early-return 이다. 카드가 «공장 안 if 0» 이면(--factory-if 0) 🔴 · 아니면 🟡.
void checkFakeFactories(
  TestFile f,
  Structure s, {
  required bool factoryIfZero,
}) {
  final List<Tok> toks = s.toks;
  for (int k = 0; k + 4 < toks.length; k++) {
    if (s.t(k) != '(' ||
        s.t(k + 1) != 'int' ||
        toks[k + 2].kind != TokKind.ident ||
        s.t(k + 3) != ')') {
      continue;
    }
    // 받는 이름이 call 이거나 이름 붙은 인자 자리(«contribution: (int n) {»)일 때만 — List.generate 같은
    // 자리 인자 콜백은 가짜 공장이 아니다.
    if (toks[k + 2].text != 'call' && s.t(k - 1) != ':') {
      continue;
    }
    int b = k + 4;
    if (s.t(b) == 'async' || s.t(b) == 'sync') {
      b++;
      if (s.t(b) == '*') {
        b++;
      }
    }
    if (s.t(b) != '{' || s.match[b] <= b) {
      continue;
    }
    final int end = s.match[b];
    for (int j = b + 1; j < end; j++) {
      if (s.t(j) != 'if' || s.t(j + 1) != '(') {
        continue;
      }
      if (!f.touched(toks[j].line, toks[j].line)) {
        continue;
      }
      final String where = '${f.path}:${toks[j].line}';
      const String how =
          '공장은 받은 call 로 삼항 한 식으로 — (int call) => call == 0 ? <첫 값> : <다음 값> '
          '(C4r4b-7 · R8a C4X-1)';
      if (factoryIfZero) {
        red(
          'T6',
          where,
          '가짜 공장 몸(${f.path}:${toks[k].line}) 안 if — 카드 «공장 안 if 0». $how',
        );
      } else {
        yellow(
          'T6',
          where,
          '가짜 공장 몸(${f.path}:${toks[k].line}) 안 if — 카드가 «공장 안 if 0» 이면 반려 꼴. $how',
        );
      }
    }
    k = end;
  }
}

/// [T7] 쓰기만 하고 읽지 않는 지역 셈 변수(C4r8a-2 · R8a C4X-1 `callCount`) — 함수 몸 안의
/// `int <이름> = 0;` 이 같은 블록에서 대입·증감으로만 쓰이고 한 번도 읽히지 않는다.
void checkWriteOnlyCounters(TestFile f, Structure s) {
  final List<Tok> toks = s.toks;
  const Set<String> blockOpeners = <String>{
    ')',
    'async',
    '*',
    'else',
    'try',
    'finally',
    'do',
    '{',
    ';',
    '}',
  };
  const Set<String> stmtStart = <String>{'{', ';', '}', ')', 'else'};
  const Set<String> writeOps = <String>{
    '=',
    '+=',
    '-=',
    '*=',
    '/=',
    '??=',
    '++',
    '--',
  };
  for (int k = 1; k + 4 < toks.length; k++) {
    if (s.t(k) != 'int' ||
        toks[k + 1].kind != TokKind.ident ||
        s.t(k + 2) != '=' ||
        s.t(k + 3) != '0' ||
        s.t(k + 4) != ';' ||
        !const <String>{'{', ';', '}'}.contains(s.t(k - 1))) {
      continue;
    }
    final int e = s.enclosing[k];
    if (e < 0 ||
        s.t(e) != '{' ||
        s.literalBrace[e] ||
        !blockOpeners.contains(s.t(e - 1)) ||
        s.match[e] <= e) {
      continue; // 맨 위 · 클래스 몸(필드는 다른 파일에서 읽힌다) · 컬렉션
    }
    if (!f.touched(toks[k].line, toks[k].line)) {
      continue;
    }
    final String name = toks[k + 1].text;
    int writes = 0;
    int reads = 0;
    int selfUntil = -1; // `x = x + 1;` 의 오른쪽 x 는 읽기가 아니라 같은 쓰기
    // 문자열 보간 안($x · ${… x …})은 어휘 분석이 건너뛰므로 글자로 찾는다 = 읽기.
    final RegExp interp = RegExp(
      '\\\$(\\{[^}]*\\b$name\\b|$name(?![A-Za-z0-9_]))',
    );
    for (int j = k + 5; j < s.match[e]; j++) {
      if (toks[j].kind == TokKind.string && interp.hasMatch(toks[j].text)) {
        reads++;
        continue;
      }
      if (s.t(j) != name || toks[j].kind != TokKind.ident) {
        continue;
      }
      if (s.t(j - 1) == '.' || s.t(j - 1) == '?.') {
        continue; // 다른 객체의 같은 이름 칸
      }
      if (s.t(j + 1) == ':' && (s.t(j - 1) == '(' || s.t(j - 1) == ',')) {
        continue; // 이름 붙은 인자 이름
      }
      // 문장 머리에 선 대입·증감만 쓰기다 — `(m++).toString()` · `x = m++` 처럼 값을 쓰면 읽기.
      final bool prefix = s.t(j - 1) == '++' || s.t(j - 1) == '--';
      final String op = s.t(j + 1);
      if (j <= selfUntil) {
        writes++;
      } else if (prefix &&
          stmtStart.contains(s.t(j - 2)) &&
          s.t(j + 1) == ';') {
        writes++;
      } else if (!prefix &&
          stmtStart.contains(s.t(j - 1)) &&
          writeOps.contains(op) &&
          ((op != '++' && op != '--') || s.t(j + 2) == ';')) {
        writes++;
        if (op == '=') {
          selfUntil = s.statementEnd(j + 2);
        }
      } else {
        reads++;
      }
    }
    if (reads == 0) {
      yellow(
        'T7',
        '${f.path}:${toks[k].line}',
        '셈 변수 «$name» 를 쓰기만 하고($writes번) 읽지 않는다 — 호출 수는 가짜의 호출 수 칸'
            '(예 repo.contributionCalls)으로 단언하고 이 변수는 지운다(R8a C4X-1)',
      );
    }
  }
}

/// 몸 안에서 testWidgets(·test(·group( 를 부르는 루프 = 테스트를 만드는 루프(0번이면 테스트 수가 준다).
bool makesTests(Structure s, int from, int to) {
  for (int j = from; j <= to; j++) {
    final String w = s.t(j);
    if ((w == 'testWidgets' || w == 'test' || w == 'group') &&
        s.t(j + 1) == '(') {
      return true;
    }
  }
  return false;
}

bool hasLengthInside(Structure s, int open, int close) {
  for (int j = open; j < close; j++) {
    if (s.t(j) == 'hasLength' && s.t(j + 1) == '(') {
      return true;
    }
  }
  return false;
}

const Set<String> screenQueries = <String>{
  'widgetList',
  'elementList',
  'renderObjectList',
  'stateList',
  'layerListOf',
  'evaluate',
};

bool queriesScreen(Iterable<Tok> ts) =>
    ts.any((Tok x) => screenQueries.contains(x.text));

/// `V = …widgetList…;` 처럼 화면에서 찾은 목록으로 선언됐는가.
bool declaredFromScreen(Structure s, String name) {
  for (int k = 1; k + 1 < s.toks.length; k++) {
    if (s.t(k) == name && s.t(k + 1) == '=' && s.t(k - 1) != '.') {
      final int end = s.statementEnd(k + 2);
      return queriesScreen(s.toks.sublist(k + 2, end + 1));
    }
  }
  return false;
}

/// 루프 앞(같은 테스트 안)에 그 목록을 첫 인자로 받은 expect 가 있는가.
bool anchoredBefore(Structure s, int forAt, List<Tok> iter) {
  final String want = joinToks(iter);
  for (int j = forAt - 1; j >= 0; j--) {
    final String w = s.t(j);
    if (w == 'testWidgets' || w == 'test') {
      return false;
    }
    if (w == 'expect' && s.t(j + 1) == '(' && s.match[j + 1] > j) {
      final List<List<Tok>> args = s.splitArgs(j + 1);
      if (args.isNotEmpty) {
        final String a0 = joinToks(args[0]);
        if (a0 == want || a0 == '$want . length') {
          // 첫 인자가 그 목록인 expect = 양성 기준점(isNotEmpty · hasLength 등)
          return true;
        }
      }
    }
  }
  return false;
}

// ── 보고 글 검사 ────────────────────────────────────────────────────────────

const List<String> sectionHeads = <String>[
  '## ① 구현한 화면 ID · 바뀐 파일 · 커밋',
  '## ② 자체 점검 12항 · 정적 묶음 · 명령 출력',
  '## ③ 스크린샷 서술 · 골든 표',
  '## ④ 질문 목록',
  '## ⑤ 추측한 것 목록',
];

final RegExp colorWords = RegExp(
  r'파란|파랑|푸른|보라|빨간|빨강|붉은|주황|초록|녹색|노란|노랑|회색|분홍|남색|갈색|하늘색|'
  r'(?<![A-Za-z0-9_])(primary|secondary|tertiary|error|surface)(?![a-z0-9_])',
  caseSensitive: false,
);

final RegExp cellBanned = RegExp(r'띠|고정|스크롤 밖');

class GoldenRow {
  GoldenRow(this.lineNo, this.name, this.cell);

  final int lineNo;
  final String name; // 예 s710_cant_dark
  final String cell;
}

List<GoldenRow> checkReport(
  String path,
  Options o,
  String headRev,
  String mergeBase,
) {
  final File file = File(path);
  if (!file.existsSync()) {
    red('R0', path, '보고 글 파일이 없다');
    return <GoldenRow>[];
  }
  String text;
  try {
    text = utf8.decode(file.readAsBytesSync());
  } on FormatException {
    red(
      'R0',
      path,
      'UTF-8 이 아니다 — 메모장 «UTF-8» 로 저장하거나 Out-File -Encoding utf8',
    );
    return <GoldenRow>[];
  }
  if (text.startsWith('﻿')) {
    text = text.substring(1);
  }
  final List<String> lines = const LineSplitter().convert(text);

  // R1 첫 줄 · 섹션 머리
  final String first = lines.isEmpty ? '' : lines.first;
  if (first != sectionHeads.first) {
    red(
      'R1',
      '$path:1',
      '첫 줄이 «${sectionHeads.first}» 가 아니다(지금 «$first») — 그 위의 글·빈 줄·--- 를 지운다',
    );
  }
  int lastAt = -1;
  for (final String h in sectionHeads) {
    final List<int> at = <int>[
      for (int i = 0; i < lines.length; i++)
        if (lines[i] == h) i,
    ];
    if (at.length != 1) {
      red('R1', path, '섹션 머리 «$h» 가 ${at.length}번 — 글자 그대로 한 번');
    } else if (at.first < lastAt) {
      red('R1', '$path:${at.first + 1}', '섹션 머리 «$h» 의 차례가 다르다');
    } else {
      lastAt = at.first;
    }
  }

  // 코드 블록 밖 줄
  final List<bool> inCode = List<bool>.filled(lines.length, false);
  bool fence = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trimLeft().startsWith('```')) {
      fence = !fence;
      inCode[i] = true;
      continue;
    }
    inCode[i] = fence;
  }

  // R2 색·테마 이름
  for (int i = 0; i < lines.length; i++) {
    if (!inCode[i] && colorWords.hasMatch(lines[i])) {
      red(
        'R2',
        '$path:${i + 1}',
        '색·테마 이름 «${colorWords.firstMatch(lines[i])!.group(0)}» — '
            'PNG 에 보이는 말로(예 «버튼 글자»)',
      );
    }
  }

  // R3 골든 표
  final List<GoldenRow> rows = <GoldenRow>[];
  final String? prefix = o.goldenPrefix;
  if (prefix != null) {
    final RegExp rowRe = RegExp('^\\| *`?${RegExp.escape(prefix)}');
    int tails = 0;
    for (int i = 0; i < lines.length; i++) {
      final String l = lines[i];
      if (inCode[i] || !rowRe.hasMatch(l)) {
        continue;
      }
      final List<String> cells = l
          .split('|')
          .map((String c) => c.trim())
          .toList();
      // 앞뒤 빈 칸을 뺀 칸
      final List<String> body = cells.sublist(1, cells.length - 1);
      final String cell = body.isEmpty ? '' : body.last;
      final String where = '$path:${i + 1}';
      if (RegExp(r'— 잘림[^|]*\| *$').hasMatch(l)) {
        tails++;
      } else {
        red('R3', where, '배치·잘림 칸 끝이 «— 잘림 없음» / «— 잘림: …» 가 아니다');
      }
      if (RegExp('[A-Za-z]').hasMatch(cell)) {
        red('R3', where, '배치·잘림 칸에 영문 낱말(코드 이름) — PNG 에 보이는 말로');
      }
      final RegExpMatch? banned = cellBanned.firstMatch(cell);
      if (banned != null) {
        red('R3', where, '배치·잘림 칸에 PNG 에서 안 보이는 말 «${banned.group(0)}»');
      }
      rows.add(GoldenRow(i + 1, goldenFileName(body.first), cell));
    }
    if (o.goldens != null && rows.length != o.goldens) {
      red(
        'R3',
        path,
        '골든 표 행 ${rows.length} ≠ 기대 ${o.goldens}(이름 × 밝기 · 한 행 한 줄)',
      );
    }
    if (rows.length != tails) {
      red('R3', path, '«— 잘림» 꼬리 행 $tails ≠ 골든 표 행 ${rows.length}');
    }
  }

  // R4 S05 결과 줄
  final List<String> s05Out = <String>[];
  for (int i = 0; i < lines.length; i++) {
    if (inCode[i] && lines[i].startsWith('## S05')) {
      for (int j = i + 1; j < lines.length && inCode[j]; j++) {
        if (lines[j].startsWith('EXIT') || lines[j].startsWith('## ')) {
          break;
        }
        final RegExpMatch? m = RegExp(r'^([^:\s]+:\d+):').firstMatch(lines[j]);
        if (m != null) {
          s05Out.add(m.group(1)!);
        }
      }
      break;
    }
  }
  final int s05At = lines.indexWhere((String l) => l.trim() == 'S05 결과:');
  if (s05At >= 0) {
    final List<String> said = <String>[];
    for (int j = s05At + 1; j < lines.length; j++) {
      final String l = lines[j];
      if (!RegExp(r'^\S+:\d+').hasMatch(l)) {
        break;
      }
      if (!RegExp(r'^[^ ]+:[0-9]+ — 탭 콜백 안$').hasMatch(l)) {
        red('R4', '$path:${j + 1}', 'S05 줄 꼴이 «<파일>:<줄> — 탭 콜백 안» 이 아니다');
      }
      said.add(l.split(' ').first);
    }
    if (s05Out.isNotEmpty && said.join(',') != s05Out.join(',')) {
      red(
        'R4',
        '$path:${s05At + 1}',
        'S05 결과 줄(${said.join(' ')}) ≠ 정적 묶음 S05 출력(${s05Out.join(' ')})',
      );
    }
  }

  // R5 12항 괄호 · flutter test 끝 줄
  for (int i = 0; i < lines.length; i++) {
    final String l = lines[i];
    if (!inCode[i] && RegExp(r'^ ?\d{1,2}\. .*\[x\] \(\s*\)\s*$').hasMatch(l)) {
      red('R5', '$path:${i + 1}', '12항 괄호가 비었다 — 카드가 준 괄호 글자를 채운다');
    }
    if (!inCode[i] && RegExp(r'^ ?\d{1,2}\. .*\[( |—|-)\]').hasMatch(l)) {
      red('R5', '$path:${i + 1}', '12항은 [x] + 괄호만(범위 밖도 [x])');
    }
    if (l.startsWith('flutter test: 시작 기준') &&
        !RegExp(
          r'^flutter test: 시작 기준 \d+ → 끝 \d{2}:\d{2} \+\d+: All tests passed!$',
        ).hasMatch(l)) {
      red(
        'R5',
        '$path:${i + 1}',
        '«flutter test: 시작 기준 <N> → 끝 <끝 줄 그대로>» 꼴이 아니다(끝 줄 = «mm:ss +M: All tests passed!»)',
      );
    }
  }

  // R6 ⓡ·ⓗ 상자 ↔ 같은 글 정적 블록 T20·T21 출력(C4r9a-6 · R9a C4Y-1)
  checkBoxAgainstStatic(path, lines, inCode, 'ⓡ', 'T20');
  checkBoxAgainstStatic(path, lines, inCode, 'ⓗ', 'T21');

  // R7 check:labels 줄 «apps/** N» ↔ check_labels.sh 다시 잰 수(C4r9a-6 · R9a C4Y-2)
  if (o.labelsRerun) {
    checkLabelsCount(path, lines, inCode, headRev);
  }

  // R8 ② 복사 상자(번호 줄) 바로 뒤 빈 줄 = 정확히 1(«N항 줄 수:» 상자 앞 · C4r9c-3 · R9c C4AA-1)
  checkBlankAfterBox(path, lines, inCode);

  // R9 ① 두 블록 줄 수 = git 출력 줄 수 · 깨진 글자(C4r14b-3 · R14b C4H-4)
  checkSectionOneBlocks(path, lines, inCode, o.base, mergeBase, headRev);
  checkBrokenText(path, lines);
  return rows;
}

/// «바뀐 파일:» · «커밋 목록:» 바로 아래 코드 블록의 줄 수 ↔ git 출력 줄 수(한 줄로 이어 붙인 꼴 ·
/// 빠진 줄). 카드 명령 = git diff --name-status origin/main...HEAD · git log --oneline origin/main..HEAD.
void checkSectionOneBlocks(
  String path,
  List<String> lines,
  List<bool> inCode,
  String base,
  String mergeBase,
  String head,
) {
  int? blockLines(String label) {
    final int at = lines.indexWhere((String l) => l.trim() == label);
    if (at < 0 ||
        at + 1 >= lines.length ||
        !lines[at + 1].trimLeft().startsWith('```')) {
      return null;
    }
    int n = 0;
    for (int j = at + 2; j < lines.length; j++) {
      if (lines[j].trimLeft().startsWith('```')) {
        return n;
      }
      if (lines[j].trim().isNotEmpty) {
        n++;
      }
    }
    return null;
  }

  int gitLines(List<String> args) => const LineSplitter()
      .convert(git(args))
      .where((String l) => l.trim().isNotEmpty)
      .length;

  final List<(String, int Function())> blocks = <(String, int Function())>[
    (
      '바뀐 파일:',
      () => gitLines(<String>['diff', '--name-status', mergeBase, head]),
    ),
    ('커밋 목록:', () => gitLines(<String>['log', '--oneline', '$base..$head'])),
  ];
  for (final (String label, int Function() want) in blocks) {
    final int? got = blockLines(label);
    if (got == null) {
      continue;
    }
    final int n = want();
    if (got != n) {
      red(
        'R9',
        '$path:${lines.indexWhere((String l) => l.trim() == label) + 1}',
        '① «$label» 블록 $got줄 ≠ git 출력 $n줄 — 출력 파일을 줄 그대로 붙인다'
            '(PowerShell 은 -join "`n" · 한 줄로 이어 붙이지 않는다 · R14b C4H-4)',
      );
    }
  }
}

/// 깨진 글자 — U+FFFD(대체 문자) · «쨌»(UTF-8 «·» 를 CP949 로 읽은 꼴) = 🔴 · 한자 = 🟡(깨짐일 수 있다).
void checkBrokenText(String path, List<String> lines) {
  final RegExp hanja = RegExp(r'[一-鿿豈-﫿]');
  int hanjaLine = -1;
  for (int i = 0; i < lines.length; i++) {
    final String l = lines[i];
    if (l.contains('�') || l.contains('쨌')) {
      red(
        'R9',
        '$path:${i + 1}',
        '깨진 글자(${l.contains('�') ? 'U+FFFD' : '«쨌»'}) — UTF-8 출력을 CP949 로 읽은 꼴. '
            '[Console]::OutputEncoding = [Text.Encoding]::UTF8 뒤 다시 저장한다(R14b C4H-4)',
      );
    } else if (hanjaLine < 0 && hanja.hasMatch(l)) {
      hanjaLine = i;
    }
  }
  if (hanjaLine >= 0) {
    yellow(
      'R9',
      '$path:${hanjaLine + 1}',
      '한자 «${hanja.firstMatch(lines[hanjaLine])!.group(0)}» — 깨진 글자(CP949 로 읽은 UTF-8)'
          '일 수 있다. 그 줄을 다시 본다',
    );
  }
}

void checkBlankAfterBox(String path, List<String> lines, List<bool> inCode) {
  final int head2 = lines.indexOf(sectionHeads[1]);
  if (head2 < 0) {
    return;
  }
  final RegExp item = RegExp(r'^ ?\d{1,2}\. ');
  int i = head2 + 1;
  while (i < lines.length && (inCode[i] || !item.hasMatch(lines[i]))) {
    if (lines[i].startsWith('## ')) {
      return; // ② 안에 번호 줄이 없다
    }
    i++;
  }
  while (i < lines.length && !inCode[i] && item.hasMatch(lines[i])) {
    i++;
  }
  final int lastItem = i; // 1부터 센 마지막 번호 줄의 행
  int blanks = 0;
  while (i < lines.length && lines[i].trim().isEmpty) {
    blanks++;
    i++;
  }
  if (i >= lines.length || !RegExp(r'^\d+항 줄 수:').hasMatch(lines[i])) {
    return; // «N항 줄 수:» 상자를 붙이는 카드 꼴이 아니다
  }
  if (blanks != 1) {
    yellow(
      'R8',
      '$path:$lastItem',
      '② 복사 상자 마지막 번호 줄 뒤 빈 줄 $blanks개 — 카드 «빈 줄 한 줄»(C4r15c-6): '
          '상자 바로 뒤에 빈 줄 하나를 두고 «${lines[i]}» 상자를 붙인다(R9c C4AA-1)',
    );
  }
}

final RegExp grepCountLine = RegExp(r'^\S+:\d+$');

/// «ⓡ = T20 출력:» 아래 줄(들) ↔ 정적 묶음 «## T20 …» 아래 출력 줄(EXIT 앞까지). 둘 다 git grep -c 의
/// «<파일>:<수>» 줄만 견준다. 정적 출력이 없으면(EXIT:1) 상자에도 «<파일>:<수>» 줄이 없어야 한다.
void checkBoxAgainstStatic(
  String path,
  List<String> lines,
  List<bool> inCode,
  String mark,
  String id,
) {
  final String marker = '$mark = $id 출력:';
  final int boxAt = lines.indexWhere((String l) => l.trim() == marker);
  int staticAt = -1;
  for (int i = 0; i < lines.length; i++) {
    if (inCode[i] && (lines[i] == '## $id' || lines[i].startsWith('## $id '))) {
      staticAt = i;
      break;
    }
  }
  if (boxAt < 0 || staticAt < 0) {
    return; // 이 카드 꼴에 상자나 정적 블록이 없다
  }
  final List<String> want = <String>[];
  for (int j = staticAt + 1; j < lines.length && inCode[j]; j++) {
    final String l = lines[j].trimRight();
    if (l.startsWith('EXIT') ||
        l.startsWith('## ') ||
        l.trimLeft().startsWith('```')) {
      break;
    }
    if (grepCountLine.hasMatch(l)) {
      want.add(l);
    }
  }
  final List<String> said = <String>[];
  int j = boxAt + 1;
  if (j < lines.length && lines[j].trimLeft().startsWith('```')) {
    j++; // 상자를 코드 블록으로 감싼 꼴
  }
  for (; j < lines.length; j++) {
    final String l = lines[j].trimRight();
    if (!grepCountLine.hasMatch(l)) {
      break;
    }
    said.add(l);
  }
  if (said.join('\n') != want.join('\n')) {
    String show(List<String> xs) => xs.isEmpty ? '출력 없음' : xs.join(' · ');
    red(
      'R6',
      '$path:${boxAt + 1}',
      '«$marker» 아래 «${show(said)}» ≠ 같은 글 정적 블록 «## $id» '
          '(${staticAt + 1}행) 출력 «${show(want)}» — 정적 출력 파일의 $id 줄을 그대로 옮긴다'
          '(다른 T 줄을 옮긴 꼴 · R9a C4Y-1)',
    );
  }
}

/// ② 끝 «check:labels = … apps/** N줄 …» 의 N ↔ head 의 check_labels.sh 를 Git Bash 로 다시 돌려
/// «/apps/» 줄을 센 수(카드 N9 와 같은 셈). bash 를 못 찾거나 돌지 않으면 세지 않고 알리기만 한다.
void checkLabelsCount(
  String path,
  List<String> lines,
  List<bool> inCode,
  String head,
) {
  final RegExp re = RegExp(r'check:labels = .*apps/\*\* (\d+)줄');
  int at = -1;
  int said = 0;
  for (int i = 0; i < lines.length; i++) {
    final RegExpMatch? m = inCode[i] ? null : re.firstMatch(lines[i]);
    if (m != null) {
      at = i;
      said = int.parse(m.group(1)!);
      break;
    }
  }
  if (at < 0) {
    return; // 줄이 없거나 수가 숫자가 아니다(카드 N9 몫)
  }
  final (int? got, String why) = rerunCheckLabels(head);
  if (got == null) {
    notes.add('check:labels 다시 재기 안 함 — $why');
    return;
  }
  notes.add('check:labels 다시 잰 수 apps/** $got(보고 $said)');
  if (got != said) {
    yellow(
      'R7',
      '$path:${at + 1}',
      'check:labels 줄 «apps/** $said줄» ≠ head 에서 다시 잰 $got — 손으로 세지 말고 '
          'Git Bash 로 check_labels.sh 를 돌린 출력 파일의 «/apps/» 줄 수를 옮긴다(R9a C4Y-2)',
    );
  }
}

/// head 의 packages/·apps/ lib 와 check_labels.sh 를 임시 폴더에 풀어 Git Bash 로 돌린다.
(int?, String) rerunCheckLabels(String head) {
  final String? bash = findBash();
  if (bash == null) {
    return (
      null,
      'Git Bash 를 못 찾았다(Windows 는 «C:\\Program Files\\Git\\bin\\bash.exe»)',
    );
  }
  final Directory tmp = Directory.systemTemp.createTempSync('precheck_labels_');
  try {
    String posix(String p) => p.replaceAll(r'\', '/');
    final String repo = posix(Directory(repoDir).absolute.path);
    final String dir = posix(tmp.path);
    final String script =
        'set -o pipefail; git -C "$repo" archive --format=tar $head -- '
        "':(glob)packages/*/lib/**' ':(glob)apps/*/lib/**' "
        'packages/domain_contracts/tool/check_labels.sh | tar -xf - -C "$dir" '
        '&& bash "$dir/packages/domain_contracts/tool/check_labels.sh"';
    final ProcessResult r = Process.runSync(
      bash,
      <String>['-c', script],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    final String out = r.stdout as String;
    if ((r.exitCode != 0 && r.exitCode != 1) || !out.contains('대상')) {
      return (null, 'check_labels.sh 가 돌지 않았다(rc ${r.exitCode})');
    }
    final int n = const LineSplitter()
        .convert(out)
        .where((String l) => l.contains('/apps/'))
        .length;
    return (n, '');
  } finally {
    try {
      tmp.deleteSync(recursive: true);
    } on FileSystemException {
      // 임시 폴더를 못 지워도 검사 결과는 그대로다.
    }
  }
}

/// Windows = Git for Windows 의 bash.exe(그냥 «bash» 는 WSL 일 수 있다 · C4r9a-7) · 그 밖 = bash.
String? findBash() {
  if (!Platform.isWindows) {
    try {
      return Process.runSync('bash', <String>['-c', 'true']).exitCode == 0
          ? 'bash'
          : null;
    } on ProcessException {
      return null;
    }
  }
  final List<String> roots = <String>[
    for (final String k in <String>['ProgramW6432', 'ProgramFiles'])
      if (Platform.environment[k] != null) '${Platform.environment[k]}\\Git',
  ];
  final ProcessResult r = Process.runSync('git', <String>['--exec-path']);
  final String exec = (r.stdout as String).trim().replaceAll(r'\', '/');
  final int cut = exec.indexOf('/mingw64/');
  if (cut > 0) {
    roots.add(exec.substring(0, cut));
  }
  for (final String root in roots) {
    final File f = File('$root/bin/bash.exe');
    if (f.existsSync()) {
      return f.path;
    }
  }
  return null;
}

/// «`s710_cant` (dark)» · «s76c_none dark» · «s77_december_light» → s710_cant_dark
String goldenFileName(String firstCell) {
  final String c = firstCell.replaceAll('`', '').trim();
  final RegExpMatch? m = RegExp(
    r'^([A-Za-z0-9_]+?)(?:_(light|dark)|\s*\(?(light|dark)\)?)?$',
  ).firstMatch(c);
  if (m == null) {
    return c;
  }
  final String? b = m.group(2) ?? m.group(3);
  return b == null ? m.group(1)! : '${m.group(1)}_$b';
}

// ── PNG ─────────────────────────────────────────────────────────────────────

class Img {
  Img(this.w, this.h, this.rgb);

  final int w;
  final int h;
  final Int32List rgb; // 0xRRGGBB

  int at(int x, int y) => rgb[y * w + x];
}

int _be32(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

Img? decodePng(Uint8List b) {
  const List<int> sig = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  if (b.length < 8) {
    return null;
  }
  for (int i = 0; i < 8; i++) {
    if (b[i] != sig[i]) {
      return null;
    }
  }
  int p = 8;
  int w = 0;
  int h = 0;
  int depth = 0;
  int colorType = 0;
  int interlace = 0;
  final BytesBuilder idat = BytesBuilder(copy: false);
  while (p + 8 <= b.length) {
    final int len = _be32(b, p);
    final String type = String.fromCharCodes(b.sublist(p + 4, p + 8));
    final Uint8List data = Uint8List.sublistView(b, p + 8, p + 8 + len);
    if (type == 'IHDR') {
      w = _be32(data, 0);
      h = _be32(data, 4);
      depth = data[8];
      colorType = data[9];
      interlace = data[12];
    } else if (type == 'IDAT') {
      idat.add(data);
    } else if (type == 'IEND') {
      break;
    }
    p += 12 + len;
  }
  final int ch = switch (colorType) {
    6 => 4,
    2 => 3,
    4 => 2,
    0 => 1,
    _ => 0,
  };
  if (depth != 8 || interlace != 0 || ch == 0 || w == 0) {
    return null;
  }
  final List<int> raw = ZLibDecoder().convert(idat.takeBytes());
  final int stride = w * ch;
  Uint8List prev = Uint8List(stride);
  Uint8List cur = Uint8List(stride);
  final Int32List out = Int32List(w * h);
  int rp = 0;
  for (int y = 0; y < h; y++) {
    final int f = raw[rp++];
    for (int i = 0; i < stride; i++) {
      final int x = raw[rp + i];
      final int a = i >= ch ? cur[i - ch] : 0;
      final int up = prev[i];
      final int c = i >= ch ? prev[i - ch] : 0;
      int v;
      switch (f) {
        case 1:
          v = x + a;
        case 2:
          v = x + up;
        case 3:
          v = x + ((a + up) >> 1);
        case 4:
          final int pa = (up - c).abs();
          final int pb = (a - c).abs();
          final int pc = (a + up - 2 * c).abs();
          v = x + (pa <= pb && pa <= pc ? a : (pb <= pc ? up : c));
        default:
          v = x;
      }
      cur[i] = v & 255;
    }
    rp += stride;
    for (int x = 0; x < w; x++) {
      final int o = x * ch;
      out[y * w + x] = ch >= 3
          ? (cur[o] << 16) | (cur[o + 1] << 8) | cur[o + 2]
          : (cur[o] << 16) | (cur[o] << 8) | cur[o];
    }
    final Uint8List t = prev;
    prev = cur;
    cur = t;
  }
  return Img(w, h, out);
}

int _dist(int a, int b) =>
    ((a >> 16 & 255) - (b >> 16 & 255)).abs() +
    ((a >> 8 & 255) - (b >> 8 & 255)).abs() +
    ((a & 255) - (b & 255)).abs();

class Comp {
  Comp(this.x0, this.y0, this.x1, this.y1);

  int x0;
  int y0;
  int x1;
  int y1;

  int get w => x1 - x0 + 1;
  int get h => y1 - y0 + 1;

  bool inside(Comp o) => x0 >= o.x0 && x1 <= o.x1 && y0 >= o.y0 && y1 <= o.y1;
}

int _mode(Iterable<int> xs) {
  final Map<int, int> count = <int, int>{};
  for (final int x in xs) {
    count[x] = (count[x] ?? 0) + 1;
  }
  int best = 0;
  int bestN = -1;
  count.forEach((int k, int v) {
    if (v > bestN) {
      best = k;
      bestN = v;
    }
  });
  return best;
}

/// (x0..x1, y0..y1) 안에서 bg 와 (색 거리 > th) 다른 픽셀의 4-연결 덩어리.
List<Comp> components(
  Img img,
  int bg,
  int x0,
  int y0,
  int x1,
  int y1, {
  int th = 40,
}) {
  final int bw = x1 - x0 + 1;
  final int bh = y1 - y0 + 1;
  final Uint8List seen = Uint8List(bw * bh);
  final List<Comp> out = <Comp>[];
  final List<int> stack = <int>[];
  for (int y = y0; y <= y1; y++) {
    for (int x = x0; x <= x1; x++) {
      final int idx = (y - y0) * bw + (x - x0);
      if (seen[idx] == 1 || _dist(img.at(x, y), bg) <= th) {
        continue;
      }
      final Comp c = Comp(x, y, x, y);
      seen[idx] = 1;
      stack.add(idx);
      while (stack.isNotEmpty) {
        final int q = stack.removeLast();
        final int qx = q % bw + x0;
        final int qy = q ~/ bw + y0;
        if (qx < c.x0) {
          c.x0 = qx;
        }
        if (qx > c.x1) {
          c.x1 = qx;
        }
        if (qy < c.y0) {
          c.y0 = qy;
        }
        if (qy > c.y1) {
          c.y1 = qy;
        }
        for (final (int dx, int dy) in const <(int, int)>[
          (1, 0),
          (-1, 0),
          (0, 1),
          (0, -1),
        ]) {
          final int nx = qx + dx;
          final int ny = qy + dy;
          if (nx < x0 || nx > x1 || ny < y0 || ny > y1) {
            continue;
          }
          final int ni = (ny - y0) * bw + (nx - x0);
          if (seen[ni] == 0 && _dist(img.at(nx, ny), bg) > th) {
            seen[ni] = 1;
            stack.add(ni);
          }
        }
      }
      out.add(c);
    }
  }
  return out;
}

/// 글자 줄 수 — 세로로 겹치는 덩어리를 한 줄로 묶는다. 같은 높이 이웃이 없는 큰 네모
/// (줄 사이에 걸친 아이콘)는 두 줄을 붙이므로 뺀다.
int lineCount(List<Comp> cs) {
  if (cs.isEmpty) {
    return 0;
  }
  final List<int> hs = <int>[for (final Comp c in cs) c.h]..sort();
  final int median = hs[hs.length ~/ 2];
  bool sibling(Comp c) => cs.any(
    (Comp o) =>
        !identical(o, c) &&
        (o.h - c.h).abs() <= 2 &&
        o.y0 <= c.y1 &&
        c.y0 <= o.y1,
  );
  final List<Comp> sorted = <Comp>[
    for (final Comp c in cs)
      if (c.h <= median * 1.25 || sibling(c)) c,
  ]..sort((Comp a, Comp b) => a.y0.compareTo(b.y0));
  int n = 0;
  int bottom = -1;
  for (final Comp c in sorted) {
    if (c.y0 > bottom) {
      n++;
    }
    if (c.y1 > bottom) {
      bottom = c.y1;
    }
  }
  return n;
}

/// 행 띠(배경과 다른 픽셀이 있는 줄이 이어진 구간)의 높이 중 가장 흔한 것 = 글자 줄 높이.
int bandHeight(Img img, int bg) {
  final List<int> hs = <int>[];
  int run = 0;
  for (int y = 0; y <= img.h; y++) {
    bool busy = false;
    if (y < img.h) {
      // 양 끝 4픽셀은 보지 않는다 — 위젯만 찍은 골든은 세로 테두리가 모든 줄에 걸친다.
      for (int x = 4; x < img.w - 4; x++) {
        if (_dist(img.at(x, y), bg) > 12) {
          busy = true;
          break;
        }
      }
    }
    if (busy) {
      run++;
    } else {
      if (run >= 6 && run <= 40) {
        hs.add(run);
      }
      run = 0;
    }
  }
  return hs.isEmpty ? 0 : _mode(hs);
}

/// 덩어리 차례의 한 칸: TEXT(줄 수) · BOX(안 줄 수) · FULL(안 줄 수) · BAR · CHIPS(개수).
class Block {
  Block(this.kind, this.n, [this.inner]);

  final String kind;
  int n;
  final int? inner;

  @override
  String toString() => switch (kind) {
    'TEXT' => '글자 $n줄',
    'BOX' => inner == null ? '상자' : '상자(안 글자 $inner줄)',
    'FULL' => inner == null ? '폭 전체 배경 덩어리' : '폭 전체 배경 덩어리(글자 $inner줄)',
    'BAR' => '가로 막대',
    'CHIPS' => '칩 $n개',
    _ => '?',
  };
}

List<Block> reduceBlocks(List<Block> bs) {
  final List<Block> out = <Block>[];
  for (final Block b in bs) {
    if (out.isNotEmpty &&
        out.last.kind == b.kind &&
        (b.kind == 'TEXT' || b.kind == 'CHIPS')) {
      out.last.n += b.n;
    } else {
      out.add(Block(b.kind, b.n, b.inner));
    }
  }
  return out;
}

/// PNG 의 위→아래 덩어리 차례(테스트 글꼴은 글자를 네모로 그린다 — 그 네모 줄을 센다).
List<Block>? pngBlocks(Img img) {
  // 화면 바탕 = 가장자리(맨 아래 줄 · 왼쪽·오른쪽 끝 열)에서 가장 흔한 색 — 큰 카드가 화면 대부분을
  // 덮으면 전체에서 가장 흔한 색은 카드 바탕이 된다(s77_december). 위젯 하나만 찍은 골든은
  // 테두리가 가장자리에 닿아 행 띠가 없다 — 그때는 전체에서 가장 흔한 색(카드 바탕)을 바탕으로 본다
  // (s77_aftertax_ladder_*).
  int bg = _mode(<int>[
    for (int x = 0; x < img.w; x++) img.at(x, img.h - 1),
    for (int y = 0; y < img.h; y++) ...<int>[
      img.at(0, y),
      img.at(img.w - 1, y),
    ],
  ]);
  int g = bandHeight(img, bg); // 글자 줄 높이(한글 빈 네모는 이보다 작다)
  if (g == 0) {
    bg = _mode(img.rgb);
    g = bandHeight(img, bg);
  }
  if (g == 0) {
    return null;
  }
  // 문턱 12 — 어두운 테마의 카드 바탕은 화면 바탕과 색 거리가 20~30 뿐이다.
  final List<Comp> all = components(
    img,
    bg,
    0,
    0,
    img.w - 1,
    img.h - 1,
    th: 12,
  );
  final List<Comp> containers = <Comp>[];
  final List<Comp> bars = <Comp>[];
  final List<Comp> glyphs = <Comp>[];
  for (final Comp c in all) {
    if (c.h > 2 * g || (c.h > 1.4 * g && c.w >= img.w * 0.5)) {
      containers.add(c);
    } else if (c.h < 0.7 * g && c.w >= 4 * g) {
      bars.add(c);
    } else if (c.h >= 4) {
      glyphs.add(c);
    }
  }
  final List<(int, Block)> blocks = <(int, Block)>[];
  for (final Comp c in containers) {
    final int fill = _mode(<int>[
      for (int y = c.y0; y <= c.y1; y++)
        for (int x = c.x0; x <= c.x1; x++)
          if (_dist(img.at(x, y), bg) > 12) img.at(x, y),
    ]);
    final List<Comp> innerGlyphs = <Comp>[
      for (final Comp q in components(img, fill, c.x0, c.y0, c.x1, c.y1))
        if (q.h >= 4 &&
            q.h <= 2 * g &&
            q.x0 > c.x0 + 1 &&
            q.x1 < c.x1 - 1 &&
            q.y0 > c.y0 + 1 &&
            q.y1 < c.y1 - 1 &&
            q.w < c.w * 0.95)
          q,
      for (final Comp q in glyphs)
        if (q.inside(c)) q,
    ];
    final int inner = lineCount(innerGlyphs);
    final bool full = c.x0 <= 1 && c.x1 >= img.w - 2;
    // 칩 = 한 줄 높이의 둥근 덩어리(폭은 글자 길이를 따른다 — 화면 폭 상자보다 좁다).
    final bool chip = !full && c.h <= 2.8 * g && c.w < img.w * 0.85;
    blocks.add((
      c.y0,
      full
          ? Block('FULL', 1, inner)
          : chip
          ? Block('CHIPS', 1)
          : Block('BOX', 1, inner),
    ));
  }
  for (final Comp c in bars) {
    if (!containers.any(c.inside)) {
      blocks.add((c.y0, Block('BAR', 1)));
    }
  }
  final List<Comp> page = <Comp>[
    for (final Comp q in glyphs)
      if (!containers.any(q.inside)) q,
  ]..sort((Comp a, Comp b) => a.y0.compareTo(b.y0));
  // 덩어리 사이 구간마다 따로 센다(줄 묶기가 덩어리를 건너 붙지 않게).
  final List<int> cuts = <int>[for (final (int, Block) b in blocks) b.$1, img.h]
    ..sort();
  int from = -1;
  for (final int cut in cuts) {
    final List<Comp> seg = <Comp>[
      for (final Comp q in page)
        if (q.y0 > from && q.y0 < cut) q,
    ];
    final int n = lineCount(seg);
    if (n > 0) {
      blocks.add((seg.first.y0, Block('TEXT', n)));
    }
    from = cut;
  }
  blocks.sort(((int, Block) a, (int, Block) b) => a.$1.compareTo(b.$1));
  return reduceBlocks(<Block>[for (final (int, Block) b in blocks) b.$2]);
}

/// 골든 표 배치·잘림 칸 → 덩어리 차례. 셀 수 없는 칸이 있으면 null.
List<Block>? cellBlocks(String cell, List<String> unknown) {
  final String body = cell.replaceFirst(RegExp(r'\s*— 잘림.*$'), '');
  final List<Block> out = <Block>[];
  int? num(String s) {
    final RegExpMatch? m =
        RegExp(r'(\d+)\s*줄').firstMatch(s) ??
        RegExp(r'줄\s*(\d+)').firstMatch(s);
    return m == null ? null : int.parse(m.group(1)!);
  }

  for (final String raw in body.split('→')) {
    final String t = raw.trim();
    if (t.isEmpty) {
      continue;
    }
    if (RegExp(r'[·,、]').hasMatch(t.replaceAll(RegExp(r'\([^)]*\)'), ''))) {
      unknown.add(t); // «·» 로 나열한 옛 꼴 — 덩어리 하나로 셀 수 없다
    } else if (t.contains('배경 덩어리')) {
      out.add(Block('FULL', 1, num(t)));
    } else if (t.startsWith('상자 안')) {
      out.add(Block('BOX', 1, num(t)));
    } else if (t.contains('상자')) {
      out.add(Block('BOX', 1));
    } else if (t.contains('막대')) {
      out.add(Block('BAR', 1));
    } else if (RegExp(r'칩\s*(\d+)\s*개').hasMatch(t)) {
      out.add(
        Block(
          'CHIPS',
          int.parse(RegExp(r'칩\s*(\d+)\s*개').firstMatch(t)!.group(1)!),
        ),
      );
    } else if (t.contains('버튼 글자')) {
      out.add(Block('TEXT', 1));
    } else if (num(t) != null) {
      out.add(Block('TEXT', num(t)!));
    } else {
      unknown.add(t);
    }
  }
  return unknown.isEmpty ? reduceBlocks(out) : null;
}

bool sameBlocks(List<Block> png, List<Block> cell) {
  if (png.length != cell.length) {
    return false;
  }
  for (int i = 0; i < png.length; i++) {
    final Block a = png[i];
    final Block b = cell[i];
    if (a.kind != b.kind) {
      return false;
    }
    if ((a.kind == 'TEXT' || a.kind == 'CHIPS') && a.n != b.n) {
      return false;
    }
    if (b.inner != null && a.inner != b.inner) {
      return false;
    }
  }
  return true;
}

void checkGoldenRows(
  List<GoldenRow> rows,
  Map<String, String> pngPaths,
  String head,
  String reportPath,
) {
  final List<String> unparsed = <String>[];
  for (final GoldenRow r in rows) {
    final String where = '$reportPath:${r.lineNo}';
    final String? p = pngPaths[r.name];
    if (p == null) {
      yellow('G1', where, '«${r.name}.png» 를 HEAD 에서 못 찾았다 — 이름 칸 확인');
      continue;
    }
    final Img? img = decodePng(gitBytes(head, p));
    final List<Block>? got = img == null ? null : pngBlocks(img);
    if (got == null) {
      yellow('G1', where, '«${r.name}.png» 를 읽지 못해 세지 않았다');
      continue;
    }
    final List<String> unknown = <String>[];
    final List<Block>? want = cellBlocks(r.cell, unknown);
    if (want == null) {
      unparsed.add('${r.lineNo}');
      continue;
    }
    if (!sameBlocks(got, want)) {
      yellow(
        'G1',
        where,
        '${r.name}: 표 «${want.join(' → ')}» ≠ PNG «${got.join(' → ')}» — '
            'PNG 를 다시 연다(글자 n줄 = PNG 에 보이는 행 수 · 줄바꿈된 행도 센다 · '
            '상자 = 테두리·모서리가 보이는 덩어리 · 폭 전체 배경 = 배경 덩어리)',
      );
    }
  }
  if (unparsed.isNotEmpty) {
    yellow(
      'G1',
      '$reportPath:${unparsed.join(',')}',
      '배치·잘림 칸을 덩어리로 셀 수 없어 PNG 와 대조하지 않았다 — 칸은 «→» 로 잇는 꼴'
          '(«글자 n줄 → 상자 → 가로 막대 → 칩 n개 … — 잘림 없음»)',
    );
  }
}

// ── 본체 ────────────────────────────────────────────────────────────────────

void main(List<String> args) {
  stdout.encoding = utf8;
  final Options o = parseArgs(args);
  repoDir = o.repo;
  git(<String>['rev-parse', '--verify', '${o.base}^{commit}']);
  final String head = git(<String>[
    'rev-parse',
    '--verify',
    '${o.head}^{commit}',
  ]).trim();
  final String mergeBase = git(<String>['merge-base', o.base, head]).trim();
  say(
    '── 사전검사 · head ${head.substring(0, 7)} · 공통 조상 ${mergeBase.substring(0, 7)}',
  );
  if (o.head == 'HEAD' &&
      git(<String>['status', '--porcelain']).trim().isNotEmpty) {
    yellow('W0', repoDir, '커밋 안 된 변경이 있다 — 이 검사는 커밋(HEAD)만 본다');
  }

  final Map<String, String> status = <String, String>{};
  for (final String l in const LineSplitter().convert(
    git(<String>['diff', '--name-status', '--no-renames', mergeBase, head]),
  )) {
    final List<String> parts = l.split('\t');
    if (parts.length >= 2) {
      status[parts.last] = parts.first;
    }
  }

  // 화면 담당이 쓰는 테스트만(ui_* · 조립 앱) — domain_contracts 계약 테스트는 M2(통합 담당) 몫.
  final RegExp testPath = RegExp(
    r'^(packages/ui_[^/]+|apps/[^/]+)/test/.*\.dart$',
  );
  final RegExp generated = RegExp(r'\.(g|freezed|mocks)\.dart$');
  int testFiles = 0;
  status.forEach((String path, String st) {
    if (!testPath.hasMatch(path) ||
        generated.hasMatch(path) ||
        (st != 'A' && st != 'M')) {
      return;
    }
    testFiles++;
    final String src = utf8.decode(gitBytes(head, path), allowMalformed: true);
    checkTestFile(
      TestFile(path, src, st == 'A' ? null : addedLines(mergeBase, head, path)),
      factoryIfZero: o.factoryIfZero,
    );
  });
  final int? wantIf = o.collectionIf;
  if (wantIf != null && collectionIfTotal != wantIf) {
    red(
      'T2',
      collectionIfWhere.join(' '),
      'collection-if $collectionIfTotal개 ≠ 카드 기대 $wantIf — 있으면 넣는 원소는 '
          'null-aware 원소(?x · ...?xs)로(카드 규칙 11)',
    );
  }

  List<GoldenRow> rows = <GoldenRow>[];
  if (o.report != null) {
    rows = checkReport(o.report!, o, head, mergeBase);
  }
  if (rows.isNotEmpty) {
    final Map<String, String> pngs = <String, String>{};
    for (final String p in const LineSplitter().convert(
      git(<String>['ls-tree', '-r', '--name-only', head]),
    )) {
      if (p.endsWith('.png') && p.contains('/goldens/')) {
        pngs[p.substring(p.lastIndexOf('/') + 1, p.length - 4)] = p;
      }
    }
    checkGoldenRows(rows, pngs, head, o.report!);
  }

  // ── 출력 ──────────────────────────────────────────────────────────────────
  const Map<String, String> titles = <String, String>{
    'W0': '작업 트리',
    'T1': 'else 없는 if',
    'T2': 'collection-if 개수',
    'T3': '늘 참 단언',
    'T4': '빈 루프 단언',
    'T5': 'ⓗ 한 줄',
    'T6': '가짜 공장 안 if',
    'T7': '쓰기만 하는 셈 변수',
    'R0': '보고 글 파일',
    'R1': '첫 줄 · 섹션 머리',
    'R2': '색·테마 이름',
    'R3': '골든 표 꼴',
    'R4': 'S05 결과 줄',
    'R5': '12항 괄호 · flutter test 줄',
    'R6': 'ⓡ·ⓗ 상자 ↔ 정적 T20·T21',
    'R7': 'check:labels 수',
    'R8': '② 상자 뒤 빈 줄',
    'R9': '① 블록 줄 수 · 깨진 글자',
    'G1': '골든 표 ↔ PNG 셈',
  };
  say(
    '   테스트 파일 $testFiles개 · collection-if $collectionIfTotal개'
    '(기대 ${wantIf ?? '세기만'})',
  );
  for (final String n in notes) {
    say('   $n');
  }
  final Set<String> ran = <String>{
    'T1',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    if (o.report != null) ...<String>[
      'R0',
      'R1',
      'R2',
      'R4',
      'R5',
      'R6',
      'R8',
      'R9',
    ],
    if (o.report != null && o.labelsRerun) 'R7',
    if (o.report != null && o.goldenPrefix != null) ...<String>['R3', 'G1'],
  };
  for (final String code in titles.keys) {
    final List<Finding> fs = <Finding>[
      for (final Finding f in findings)
        if (f.code == code) f,
    ];
    if (fs.isEmpty) {
      if (ran.contains(code)) {
        say('✅ [$code] ${titles[code]} — 0건');
      }
      continue;
    }
    for (final Finding f in fs) {
      say('${f.red ? '🔴' : '🟡'} [$code] ${titles[code]} — ${f.where}');
      say('     ${f.message}');
    }
  }
  final int reds = findings.where((Finding f) => f.red).length;
  final int yellows = findings.length - reds;
  say(
    '── 결과: 🔴 $reds · 🟡 $yellows'
    '${reds == 0 ? ' — 푸시해도 된다(🟡 는 PNG·글을 다시 보고 판단)' : ' — 고친 뒤 다시 돌린다(푸시 금지)'}',
  );
  exit(reds == 0 ? 0 : 1);
}
