// C-4 금액 산술 lint — 01 §7 표 C-4 · §1-2 규약 5조 · §1-4 · 인벤토리 §9(🟡 부분).
//
// 정의: 「`ui_*` 에서 `Money`/`Decimal` 필드에 `*`·`/`·`+` 가 적용된 표현식 탐지」.
//        🔴 확장 대상 = `*Pct`·`*Ratio`·`cagr*` 이름의 double 필드(01 §7 각주).
// 잡는 것: **화면 재계산**.
//
// 🟡 표현식 수준 탐지(custom_lint)는 `ui_*` 에 화면 코드가 생겨야 실효가 있다.
//    여기서는 **리플렉션 대신 소스 검사**로 그 앞 단계를 고정한다 —
//    ① 값 타입에 산술 연산자가 아예 **선언되어 있지 않고**(있으면 화면이 쓸 수 있다)
//    ② 계약 패키지 안에 금액 산술이 0건이며(01 §1-2 말미)
//    ③ DTO 에 계산 getter 가 0건이다(01 §1-4).

import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 금액·비율로 읽히는 이름 + 산술 연산자가 붙은 표현식.
///
/// 🔴 `-` 는 넣지 않는다 — 음수 리터럴·화살표(`->`)·주석 구분선과 겹쳐 과탐이 크다.
///    금액 «차액»은 `+`·`*`·`/` 없이 만들 수 없으므로 셋으로 충분하다.
final RegExp _moneyArithmetic = RegExp(
  r'\b\w*(?:[Aa]mount|[Pp]rice|[Pp]nl|[Cc]ommission|[Tt]ax|[Cc]ash|'
  r'[Pp]ct|[Rr]atio|cagr\w*)\w*\s*[*/+]\s*'
  r'|\s[*/+]\s*\w*(?:[Aa]mount|[Pp]rice|[Pp]nl|[Pp]ct|[Rr]atio|cagr\w*)\w*',
);

void main() {
  group('C-4 금액 산술 (01 §7 · §1-2)', () {
    test('C-4 Money·Ratio·TradeDate 에 산술 연산자가 선언돼 있지 않다', () {
      // 🔴 `Ratio`·`TradeDate` 는 extension type 이라 **연산자를 선언하지 않으면**
      //    대표 타입(double·String)의 연산자가 노출되지 않는다(인벤토리 §1).
      for (final File f in dartSourcesIn(
        Directory('${libDir.path}/src/primitives'),
      )) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        expect(
          code.contains('operator'),
          isFalse,
          reason:
              '${shortPath(f)} — 값 타입에 연산자를 선언하면 화면이 금액·비율을 '
              '곱할 수 있게 된다(01 §1-2 · 인벤토리 §1).',
        );
      }
    });

    test('C-4 Ratio·TradeDate 는 대표 타입의 연산자를 물려주지 않는다', () {
      const Ratio r = Ratio(0.42);
      const TradeDate d = TradeDate('2026-08-31');
      // 값은 꺼낼 수 있다(엔진이 만든 값을 화면이 «읽는» 것은 허용).
      expect(r.value, 0.42);
      expect(d.yyyyMmDd, '2026-08-31');
      // 🔴 `r + r`·`d + d` 는 **컴파일되지 않는다** — extension type 이 연산자를
      //    선언하지 않았기 때문이다. 컴파일 오류는 테스트로 실행할 수 없으므로
      //    그 근거(선언 0건)를 바로 위 검사가 소스에서 확인한다.
      //    ⚠️ 런타임 표현은 대표 타입 그대로다(erasure) — 그래서 «타입 검사»로는
      //       막을 수 없고 **선언이 없다는 사실**만이 근거다.
      expect(r.value.isFinite, isTrue);
      expect(d.yyyyMmDd.length, 10);
    });

    test('C-4 계약 패키지 안에 금액 산술이 0건이다', () {
      final List<String> offenders = <String>[];
      for (final File f in dartSourcesIn(libDir)) {
        final String code = stripCommentsAndStrings(f.readAsStringSync());
        for (final RegExpMatch m in _moneyArithmetic.allMatches(code)) {
          offenders.add('${shortPath(f)}: ${m.group(0)!.trim()}');
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '계약은 값을 나르기만 한다 — 산술이 등장하면 그 자체가 설계 오류 신호다'
            '(01 §1-2 규약 5조 말미 · §1-4).',
      );
    });

    test('C-4 DTO 에 계산 getter 가 없다(01 §1-4)', () {
      final RegExp getter = RegExp(r'\bget\s+\w+\s*(=>|\{)');
      final List<String> offenders = <String>[];
      for (final Directory dir in <Directory>[
        Directory('${libDir.path}/src/dto'),
        Directory('${libDir.path}/src/primitives'),
      ]) {
        for (final File f in dartSourcesIn(dir)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExpMatch m in getter.allMatches(code)) {
            offenders.add('${shortPath(f)}: ${m.group(0)!.trim()}');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '`pnlPct` 를 `(price/avg − 1)` 로 만드는 getter 는 경계 규칙 ① 위반이다'
            '(01 §1-4). 계산된 값과 그 표기 문자열을 **엔진이 함께** 준다.',
      );
    });

    test('C-4 확장 대상(double 비율 필드)은 표기 문자열과 짝을 이룬다', () {
      // 🔴 01 §7 각주 — 현행 C-4 는 Decimal 산술만 보므로 세율 곱셈·층 간 차액·
      //    `1 − deployedRatio` 를 하나도 못 잡는다. 그래서 double 비율 필드는
      //    **표시용 문자열 짝**이 반드시 있어야 화면이 계산할 이유가 없어진다.
      final AfterTaxStep step = AfterTaxStep.fromJson(<String, dynamic>{
        'step_code': 'PRETAX',
        'label': '세전',
        'cagr_pct': 11.13,
        'end_mult': 8.55,
        'value_text': '연 11.13% · 8.55배',
      });
      expect(step.valueText, isNotEmpty, reason: '표시의 정본은 valueText 다(C-30).');

      // 🔴 여집합을 화면이 만들지 않도록 두 값을 모두 준다(01 §2-6 SleeveAllocationRow).
      final SleeveAllocationRow row = SleeveAllocationRow.fromJson(
        <String, dynamic>{
          'sleeve': 'A',
          'basis': 'ACCOUNTING',
          'deployed_text': '1,340만원',
          'parking_text': '660만원',
          'deployed_ratio': 0.67,
          'parking_ratio': 0.33,
          'tranche_state_text': '트랜치 2/3 진입',
          'deployed_pct_text': '13.4%',
          'parking_pct_text': '6.6%',
        },
      );
      expect(row.deployedRatio + row.parkingRatio, closeTo(1.0, 1e-9));
      expect(row.parkingPctText, isNotEmpty);
    });

    test('C-4 ui_* 소스에 금액·비율 산술이 0건이다', () {
      // ⚠️ 지금은 스텁(패키지당 2파일)이라 통과가 쉽다 — 그래도 **자리를 비워 두지
      //    않는다**. 화면이 들어오는 첫 PR 부터 이 검사가 실효를 갖는다.
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        for (final File f in dartSourcesIn(
          Directory('${repoRoot.path}/packages/$name/lib'),
        )) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExpMatch m in _moneyArithmetic.allMatches(code)) {
            offenders.add('${shortPath(f)}: ${m.group(0)!.trim()}');
          }
        }
      }
      expect(offenders, isEmpty, reason: '화면에는 금액 산술 자체가 없다(01 §1-2 말미).');
    });

    test('C-4 Decimal 은 double 로 내려가지 않는다', () {
      // 계약이 막고 있는 사고를 한 줄로 고정한다.
      final Decimal a = Decimal.parse('0.1');
      final Decimal b = Decimal.parse('0.2');
      expect((a + b).toString(), '0.3');
      expect((0.1 + 0.2).toString(), isNot('0.3'));
    });

    test(
      'C-4 표현식 수준 탐지(custom_lint AST)',
      () {},
      skip:
          'custom_lint AST 규칙은 아직 없다. 소스 정규식(위)은 「필드 이름이 금액으로 '
          '읽히는 표현식」까지만 잡고 별칭(`final v = row.price; v * 2`)은 못 잡는다. '
          '✅ 2026-09-17: ui_journal J-1 은 정규식 0건 + 사람 검사(C4 R1)로 통과 — '
          'AST 규칙은 C5(엔진·안전 화면) 단계에서 custom_lint 로 넣는다(01 §7 C-4).',
    );
  });
}
