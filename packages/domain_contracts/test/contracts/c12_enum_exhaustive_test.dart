// C-12 열거값 전수 커버 — 01 §7 표 C-12 · §1-2 enum 직렬화 규약 · 인벤토리 §9(🟡).
//
// 정의: 「모든 enum 을 `default:` 없이 exhaustive switch 로 분기하는지」.
// 잡는 것: **신규 코드 조용히 무시**.
//
// 🔴 루트 `analysis_options.yaml` 주석대로 「enum 값이 늘었는데 switch 가 조용히
//    넘어감」은 Dart 3 에서 **이미 컴파일 오류**다(non_exhaustive_switch). 단
//    `default:` 를 적으면 그 보호가 사라진다 — 그래서 C-12 가 검사하는 것은
//    ① `default:` 가 없는가 ② 열거값이 **직렬화 표기와 1:1로 못 박혀 있는가** 다.
//    (표기가 자동 변환에 맡겨지면 픽스처·DDL 과 갈라지고 C-15 가 실패한다.)

import 'dart:io';

import 'package:test/test.dart';

import 'c00_support.dart';

/// 🔴 `wire` 필드 없이 선언된 열거형 — **문서화된 예외**다.
///
/// 다른 52 종은 전부 `@JsonValue` 와 같은 문자열을 `wire` 로 노출한다(01 §1-2 규약).
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

    test(
      'C-12 ui_* 의 switch 전수(default: 금지 · 신규 값 파급)',
      () {},
      skip:
          'ui_* 에 화면 코드가 아직 없다. 🔴 이 검사의 파급은 «의도된 게이트»다 — '
          '열거형·필수 필드·픽스처가 한꺼번에 바뀌면 M6·M7·M8·M9 산출물이 동시에 '
          '리베이스 대상이 된다(01 §7 C19 주석). 화면이 들어오는 PR 에서 채운다.',
    );
  });
}

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
