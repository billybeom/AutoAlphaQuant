// C-12 열거값 전수 커버 — 01 §7 표 C-12 · §1-2 enum 직렬화 규약 · 인벤토리 §9.
//
// 정의: 「모든 enum 을 **전부 받기** 없이 exhaustive switch 로 분기하는지」.
// 잡는 것: **신규 코드 조용히 무시**.
//
// 🔴 루트 `analysis_options.yaml` 주석대로 「enum 값이 늘었는데 switch 가 조용히
//    넘어감」은 Dart 3 에서 **이미 컴파일 오류**다(non_exhaustive_switch). 단
//    «전부 받기»를 적으면 그 보호가 사라진다 — 그래서 C-12 가 검사하는 것은
//    ① 전부 받기가 없는가 ② 열거값이 **직렬화 표기와 1:1로 못 박혀 있는가** 다.
//    (표기가 자동 변환에 맡겨지면 픽스처·DDL 과 갈라지고 C-15 가 실패한다.)
// 🔴 «전부 받기» 6형태(2026-09-24 확장 · 계약 v1.2 PR 커밋 1): ① `default:` ② 식 `_ =>`
//    ③ 문 `case _:` ④ 타입 와일드카드 `T _ =>`·`case T _:` ⑤ 식 `final x =>`·`var x =>`
//    ⑥ 문 `case final x:`·`case var x:`(🆕 v1.2 검증 반영 + 타입 바인딩 `case T x:`·`case final T x:`).
//    알려진 미탐은 `_catchAll` 주석. 가드 달린 `_ when c =>` 는 전수에 세지 않으므로
//    위반이 아니다. 범위 = 계약 `lib/` + `ui_*/lib` + `apps/*/lib` — 화면·앱은 **대상 타입
//    불문** 전면 금지다(전부 받기가 없으면 비-enum switch 는 컴파일되지 않으므로 금지가 곧
//    «화면은 enum·bool 로만 switch»다). 🔴 switch 만 본다 — `if`·`==` 사슬은 범위 밖이다.

import 'dart:io';

import 'package:test/test.dart';

import 'c00_support.dart';

/// 🔴 `wire` 필드 없이 선언된 열거형 — **문서화된 예외**다.
///
/// 다른 55 종은 전부 `@JsonValue` 와 같은 문자열을 `wire` 로 노출한다(01 §1-2 규약).
/// 목록이 늘거나 줄면 이 검사가 실패한다 — 「조용히 하나 더」를 막는다.
const Map<String, String> _enumsWithoutWireField = <String, String>{
  'RampLevel':
      '영역 B 가 dto/safety.dart 에 선언한 열거형이다(인벤토리 §2 의 52종 표에 없고 '
      '§3-14 가 이 파일로 배정했다). `@JsonValue` 는 붙어 있으나 `wire` 접근자가 없어 '
      '코드에서 표기 문자열을 꺼낼 통로가 없다 — 통합 단계의 판단 대상이다.',
};

void main() {
  group('C-12 열거값 전수 커버 (01 §7 · §1-2)', () {
    test('C-12 모든 열거값에 @JsonValue 가 붙어 있다(자동 변환 0건)', () {
      final List<_EnumDecl> enums = _declaredEnums();
      expect(enums.length, greaterThan(50), reason: '열거형을 제대로 못 읽었다.');

      for (final _EnumDecl e in enums) {
        expect(
          e.jsonValues,
          hasLength(e.memberCount),
          reason:
              '${e.name} — 값 ${e.memberCount}개 중 @JsonValue 가 '
              '${e.jsonValues.length}개다. 자동 변환에 맡기면 픽스처(§5)·DDL CHECK(§6)와 '
              '갈라지고 C-15 가 실패한다(01 §1-2).',
        );
      }
    });

    test('C-12 JSON 표기는 SCREAMING_SNAKE_CASE 이고 열거형 안에서 유일하다', () {
      for (final _EnumDecl e in _declaredEnums()) {
        expect(
          e.jsonValues.toSet(),
          hasLength(e.jsonValues.length),
          reason: '${e.name} — 같은 표기를 두 값이 쓴다.',
        );
        for (final String wire in e.jsonValues) {
          expect(
            RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(wire),
            isTrue,
            reason:
                '${e.name}.$wire — JSON·DDL 표기는 SCREAMING_SNAKE_CASE 다(01 §1-2).',
          );
        }
      }
    });

    test('C-12 wire 접근자는 @JsonValue 와 **같은 문자열**이다', () {
      for (final _EnumDecl e in _declaredEnums()) {
        if (!e.hasWireField) {
          continue;
        }
        expect(
          e.wirePairs,
          hasLength(e.memberCount),
          reason: '${e.name} — `@JsonValue(\'X\') name(\'X\')` 형태가 아닌 값이 있다.',
        );
        for (final MapEntry<String, String> pair in e.wirePairs.entries) {
          expect(
            pair.value,
            pair.key,
            reason:
                '${e.name} — @JsonValue 와 wire 가 갈라졌다. 한쪽만 고치면 '
                '픽스처·DDL 과 어긋난 채 컴파일된다.',
          );
        }
      }
    });

    test('C-12 wire 접근자가 없는 열거형은 문서화된 것뿐이다', () {
      final Set<String> without = <String>{
        for (final _EnumDecl e in _declaredEnums())
          if (!e.hasWireField) e.name,
      };
      expect(
        without,
        _enumsWithoutWireField.keys.toSet(),
        reason:
            '표기 문자열을 꺼낼 통로가 없는 열거형이 늘었거나 줄었다 — '
            '목록과 사유를 함께 고친다.',
      );
    });

    test('C-12 계약 소스에 default: 가 0건이다', () {
      final List<String> offenders = <String>[];
      for (final File f in dartSourcesIn(libDir)) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        if (RegExp(r'(^|\s)default\s*:', multiLine: true).hasMatch(code)) {
          offenders.add(shortPath(f));
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '`default:` 를 적으면 Dart 3 의 exhaustive 검사가 꺼진다 — '
            '열거값이 늘어도 조용히 넘어간다(루트 analysis_options.yaml 주석).',
      );
    });

    test('C-12 enums/ 의 모든 파일이 배럴로 재수출된다', () {
      final String barrel = File('${libDir.path}/src/enums.dart')
          .readAsStringSync();
      for (final File f in dartSourcesIn(
        Directory('${libDir.path}/src/enums'),
      )) {
        final String name = f.uri.pathSegments.last;
        expect(
          barrel.contains("export 'enums/$name'"),
          isTrue,
          reason:
              '$name 이 배럴에 없다 — 화면은 lib/src 를 직접 import 하지 않으므로'
              '(인벤토리 §0) 그 열거형은 계약에 «없는» 것과 같다.',
        );
      }
    });

    test('C-12 계약 소스에 switch 의 다른 전부 받기(4형태)가 0건이다', () {
      // 🔴 위 `default:` 검사와 **한 정규식으로 합치지 않는다** — 기존 통과분의 뜻을 보존한다.
      final List<String> offenders = <String>[];
      for (final File f in dartSourcesIn(libDir)) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        for (final String hit in _catchAllHits(code)) {
          if (hit != _defaultPatternName) {
            offenders.add('${shortPath(f)}: $hit');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '`_ =>`·`case _:`·`T _`·`final x =>`·`case final x:` 도 `default:` 와 '
            '같다 — Dart 3 의 exhaustive 검사가 꺼져 열거값이 늘어도 조용히 넘어간다'
            '(2026-09-24 확장).',
      );
    });

    test('C-12 ui_*·apps 의 switch 에 전부 받기가 없다(예외 맵과 일치)', () {
      final Map<String, List<String>> hits = <String, List<String>>{};
      final List<Directory> roots = <Directory>[
        for (final String name in uiPackageNames)
          Directory('${repoRoot.path}/packages/$name/lib'),
        for (final String name in appNames)
          Directory('${repoRoot.path}/apps/$name/lib'),
      ];
      int scanned = 0;
      for (final Directory root in roots) {
        for (final File f in dartSourcesIn(root)) {
          scanned++;
          final List<String> found = _catchAllHits(
            stripCommentsAndStrings(f.readAsStringSync()),
          );
          if (found.isNotEmpty) {
            hits[shortPath(f)] = found;
          }
        }
      }
      expect(scanned, greaterThan(0), reason: 'ui_*·apps 의 lib 를 못 읽었다.');
      final String listing = <String>[
        for (final MapEntry<String, List<String>> e in hits.entries)
          '${e.key}: ${e.value.join(' · ')}',
      ].join('\n');
      expect(
        hits.keys.toSet(),
        _catchAllExceptions.keys.toSet(),
        reason:
            '$listing\n'
            '`default:` 를 적으면 Dart 3 의 exhaustive 검사가 꺼진다 — '
            '열거값이 늘어도 조용히 넘어간다(루트 analysis_options.yaml 주석). '
            '`_ =>` 도 default 와 같다(2026-09-24). 예외는 `_catchAllExceptions` 에 '
            '사유와 함께 올리고, 고치면 맵에서도 지운다(양방향).',
      );
    });

    test('C-12 전부 받기 정규식 자체 검증', () {
      // 🔴 스캔 대상은 `lib/` 뿐이라 이 스니펫이 자기 자신을 잡지 않는다.
      final Set<String> fired = <String>{};
      for (final String snippet in _catchAllPositives) {
        final List<String> found = _catchAllHits(
          stripCommentsAndStrings(snippet),
        );
        expect(found, isNotEmpty, reason: '양성 스니펫을 못 잡았다: $snippet');
        fired.addAll(found);
      }
      expect(
        fired,
        _catchAll.keys.toSet(),
        reason: '양성 스니펫이 한 번도 건드리지 않은 패턴이 있다 — 죽은 정규식이다.',
      );
      for (final String snippet in _catchAllNegatives) {
        expect(
          _catchAllHits(stripCommentsAndStrings(snippet)),
          isEmpty,
          reason: '음성 스니펫을 잘못 잡았다(오탐): $snippet',
        );
      }
    });
  });
}

/// `_catchAll` 의 `default:` 항목 이름 — 계약 소스 검사가 기존 `default:` 테스트와 나눠 센다.
const String _defaultPatternName = '`default:`';

/// C-12 — switch 의 «전부 받기»(= `default:` 와 같은 효과 · 01 §7 C-12 · 2026-09-24 확장 · §12-5).
/// `stripCommentsAndStrings` 뒤에 적용한다.
/// 🔴 알려진 미탐(🆕 v1.2 검증 반영 — 같은 정규식의 탐침 실측으로 목록을 채웠다 · 01 §12-5):
///    ① 식의 타입 변수 `T x =>`·`final T x =>` ② 제네릭 타입 `case Foo<Bar> _:`·`case Foo<Bar> x:`
///    ③ 괄호 와일드카드 `case (_):`·식 `(_) =>`(람다 `(_) =>` 와 글자로 구별되지 않는다)
///    ④ 전부 와일드카드 레코드 `(_, _) =>` ⑤ 공백 없는 `{default:`(포맷 게이트가 막는다)
///    ⑥ 문자열 보간 안의 switch(스트리퍼가 보간을 문자열로 지운다).
///    2026-09-25 실측: `ui_*/lib`·`apps/*/lib` 에 ①~⑥ 형태 0건(`onSelected: (_) =>` 람다 9개만 — 정상 무시).
///    하나라도 실제로 나타나면 구문 AST(`package:analyzer` `parseString` — 이미 전이 의존 14.4.0)로
///    올린다. 해석 AST 는 쓰지 않는다(30초 · bootstrap·build:gen 의존 → 고칠 수 없는 조건으로 점검이
///    실패한다). 문의 타입 바인딩 `case T x:`·`case final T x:` 는 🆕 v1.2 검증 반영으로 ⑥ 에 넣었다
///    (비-enum 타입 검사 자체가 화면 정책 위반이다).
final Map<String, RegExp> _catchAll = <String, RegExp>{
  _defaultPatternName: RegExp(r'(^|\s)default\s*:', multiLine: true),
  'switch 식 `_ =>`(`T _ =>` 포함)': RegExp(r'(?<![\w$])_\s*=>'),
  'switch 문 `case _:`·`case T _:`': RegExp(
    r'\bcase\s+(?:final\s+|var\s+|[A-Z]\w*\??\s+)?_\s*:',
  ),
  'switch 식 `final x =>`·`var x =>`': RegExp(
    r'(?<![\w$])(?:final|var)\s+[a-z_]\w*\s*=>',
  ),
  'switch 문 `case final x:`·`case var x:`·`case T x:`': RegExp(
    r'\bcase\s+(?:(?:final|var)\s+[a-z_]\w*'
    r'|(?:final\s+|var\s+)?[A-Z]\w*\??\s+[a-z_]\w*)\s*:',
  ),
};

/// ui_*·apps 의 문서화된 전부 받기 예외 — 🔴 지금 **빈 맵**. 늘거나 줄면 실패한다.
///
/// 키 = `shortPath`(저장소 루트 기준 `packages/ui_x/lib/...`) · 값 = 사유. 병합 직전 재스캔에서
/// 적중이 나오면 skip 으로 되돌리지 않고 여기에 사유와 함께 올린 뒤, 카드 «고칠 것»의 제거
/// PR 이 병합될 때 맵에서도 지운다(양방향 검사가 강제한다).
const Map<String, String> _catchAllExceptions = <String, String>{};

/// [code](주석·문자열 제거 뒤)에서 적중한 패턴 이름.
List<String> _catchAllHits(String code) => <String>[
  for (final MapEntry<String, RegExp> e in _catchAll.entries)
    if (e.value.hasMatch(code)) e.key,
];

/// 자체 검증 — 반드시 잡혀야 하는 스니펫.
const List<String> _catchAllPositives = <String>[
  'switch (t) { case T.a: break; default: break; }',
  'final x = switch (t) { T.a => 1, _ => 2 };',
  'switch (t) { case T.a: break; case _: break; }',
  'final x = switch (c) { Color _ => 0 };',
  'switch (t) { case Tone _: break; }',
  'final x = switch (t) { T.a => 1, final other => 2 };',
  'final x = switch (t) { T.a => 1, var other => 2 };',
  'switch (t) { case final other: break; }',
  'switch (t) { case var other: break; }',
  // 🆕 v1.2 검증 반영 — 문의 타입 바인딩.
  'switch (t) { case Tone x: break; }',
  'switch (t) { case final Tone x: break; }',
  'switch (t) { case Tone? x: break; }',
  // String 대상 — 정책상 위반(화면은 enum·bool 로만 switch).
  "switch (s) { case 'a': break; default: break; }",
];

/// 자체 검증 — 잡혀서는 안 되는 스니펫.
const List<String> _catchAllNegatives = <String>[
  'final x = switch (t) { T.a => 1, _ when flag => 2, T.b => 3 };',
  '// default: _ => case _:',
  '/* default: */ int a = 1;',
  "const s = 'default: _ => case _:';",
  'xs.map((_) => 1);',
  'f((_, __) {});',
  'onError: (Object e, _) => null,',
  '@Default(<String>[]) List<String> xs,',
  'for (final x in xs) {}',
  'switch (t) { case final x when x.isEmpty: break; case T.a: break; }',
  'switch (t) { case Tone x when x.isOk: break; case T.a: break; }',
  'switch (t) { case T.a: break; case Foo(): break; }',
];

/// 소스에서 읽은 열거형 선언 하나.
class _EnumDecl {
  const _EnumDecl({
    required this.name,
    required this.memberCount,
    required this.jsonValues,
    required this.wirePairs,
    required this.hasWireField,
  });

  final String name;
  final int memberCount;
  final List<String> jsonValues;

  /// `@JsonValue('X')` → 생성자 인자로 넘긴 `wire` 문자열.
  final Map<String, String> wirePairs;

  final bool hasWireField;
}

List<_EnumDecl> _declaredEnums() {
  final List<_EnumDecl> out = <_EnumDecl>[];
  final RegExp enumRe = RegExp(r'\benum\s+(\w+)\s*\{(.*?)\n\}', dotAll: true);
  for (final File f in dartSourcesIn(libDir)) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in enumRe.allMatches(source)) {
      final String body = m.group(2)!;
      // 값 목록은 첫 `;` 앞까지다(그 뒤는 생성자·필드·메서드).
      final String members = body.split(';').first;
      final List<String> jsonValues = RegExp(r"@JsonValue\('([^']*)'\)")
          .allMatches(members)
          .map((RegExpMatch v) => v.group(1)!)
          .toList();
      final Map<String, String> wirePairs = <String, String>{
        for (final RegExpMatch p in RegExp(
          r"@JsonValue\('([^']*)'\)\s*\w+\('([^']*)'\)",
        ).allMatches(members))
          p.group(1)!: p.group(2)!,
      };
      // 값 선언 = 줄머리의 `이름(` 또는 `이름,`.
      final int memberCount = RegExp(
        r'^\s*[a-z_]\w*\s*[(,]',
        multiLine: true,
      ).allMatches(members).length;
      out.add(
        _EnumDecl(
          name: m.group(1)!,
          memberCount: memberCount,
          jsonValues: jsonValues,
          wirePairs: wirePairs,
          hasWireField: body.contains('final String wire'),
        ),
      );
    }
  }
  return out;
}
