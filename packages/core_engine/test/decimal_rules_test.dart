// Decimal 규약 5조 · 환원 규칙(유효숫자 28 · HALF_EVEN) — 06 M1-1 · 01 §0.
//
// 기대값은 파이썬 `decimal` 기본 문맥이 내는 값이다(`getcontext().prec == 28`,
// `ROUND_HALF_EVEN`). 엔진이 파이썬 참조 구현과 같은 답을 내야 골든이 성립한다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  group('규약 ① 비율 승격', () {
    test('문자열을 거쳐 승격한다 — 0.0035 는 정확히 0.0035', () {
      expect(promoteRatio(0.0035), d('0.0035'));
      expect(d('100000000') * promoteRatio(0.0035), d('350000'));
    });

    test('NaN·무한대는 승격하지 않는다', () {
      expect(() => promoteRatio(double.nan), throwsArgumentError);
      expect(() => promoteRatio(double.infinity), throwsArgumentError);
    });
  });

  group('규약 ⑤ (1 − 비율)은 Decimal 안에서', () {
    test('oneMinus(0.07) = 0.93 — double 로 먼저 빼면 0.9299999999999999', () {
      expect(oneMinus(0.07), d('0.93'));
      expect((1 - 0.07).toString(), '0.9299999999999999');
    });
  });

  group('환원 규칙 — 유효숫자 28 · HALF_EVEN', () {
    test('유효숫자는 28 이다', () {
      expect(kContextPrecision, 28);
    });

    test('비종료 소수는 28자리에서 끊는다(1/3 · 2/3 · −2/3)', () {
      expect(divide(d('1'), d('3')), d('0.${'3' * 28}'));
      expect(divide(d('2'), d('3')), d('0.${'6' * 27}7'));
      expect(divide(d('-2'), d('3')), d('-0.${'6' * 27}7'));
    });

    test('끝자리가 정확히 5 면 짝수 쪽으로(HALF_EVEN)', () {
      // 29번째 유효숫자가 5 이고 뒤가 없다 — 28번째가 짝수면 내림, 홀수면 올림.
      expect(multiply(d('1.${'0' * 27}5'), Decimal.one), Decimal.one);
      expect(multiply(d('1.${'0' * 26}15'), Decimal.one), d('1.${'0' * 26}2'));
      expect(
        multiply(d('-1.${'0' * 26}15'), Decimal.one),
        d('-1.${'0' * 26}2'),
      );
    });

    test('5 보다 크면 올리고 작으면 버린다', () {
      expect(multiply(d('1.${'0' * 27}51'), Decimal.one), d('1.${'0' * 26}1'));
      expect(multiply(d('1.${'0' * 27}49'), Decimal.one), Decimal.one);
    });

    test('큰 수도 유효숫자 28 이다(10^30 / 3)', () {
      expect(divide(d('1${'0' * 30}'), d('3')), d('${'3' * 28}00'));
    });

    test('작은 수도 유효숫자 28 이다(1 / 7,000,000)', () {
      expect(
        divide(d('1'), d('7000000')),
        d('0.0000001428571428571428571428571429'),
      );
    });

    test('나누어떨어지면 정확한 값 그대로', () {
      expect(divide(d('350000'), d('700')), d('500'));
      expect(divide(d('5000000'), d('10000')), d('500'));
      expect(divide(d('0'), d('3')), Decimal.zero);
    });

    test('0 으로 나누면 거부한다', () {
      expect(() => divide(d('1'), Decimal.zero), throwsArgumentError);
    });
  });

  group('규약 ④ mulDiv 는 곱셈 먼저', () {
    test('mulDiv(a, b, c) == divide(multiply(a, b), c)', () {
      expect(
        mulDiv(d('100000000'), d('0.0035'), d('2333')),
        divide(multiply(d('100000000'), d('0.0035')), d('2333')),
      );
      expect(
        mulDiv(d('100000000'), d('0.0035'), d('2333')),
        d('150.0214316330904414916416631'),
      );
    });
  });
}
