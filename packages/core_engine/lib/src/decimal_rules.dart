// Decimal 규약 5조의 실행체 — 06 M1-1 · 01 §1-2 · `06_시스템설계/01_모듈_인터페이스.md` §0.
//
// 🔴 엔진의 금액·수량 산술은 이 파일의 함수를 지나간다. 규약을 어기면 GV-8a 처럼
//    완전 동률인 판정이 1 ULP 로 뒤집힌다(05 §GV-8f).
//
// ① 금액 × 비율은 비율을 문자열로 승격한 뒤 곱한다 → [promoteRatio]
// ② 중간값은 Decimal 로 계산하고 double 필드에 담을 때만 내린다(호출자 몫)
// ③ 금액 필드는 끝까지 Decimal(호출자 몫)
// ④ 곱셈 먼저, 나눗셈 나중 → [mulDiv]
// ⑤ (1 − 비율)은 Decimal 안에서 → [oneMinus]
//
// 🔴 환원 규칙(E1 에서 정함 · 13 §3-3): Dart 의 `Decimal / Decimal` 은 유리수를
//    돌려주고 `toDecimal(scaleOnInfinitePrecision:)` 은 **버림**이다. 파이썬 참조
//    구현의 `Decimal` 은 기본 문맥(유효숫자 28 · ROUND_HALF_EVEN)으로 끊는다.
//    엔진이 파이썬과 같은 답을 내야 골든이 성립하므로 나눗셈·곱셈 결과는
//    **유효숫자 28 · HALF_EVEN** 으로 환원한다. 자릿수를 정해 버리는 방식(C-9 의
//    scale 20)은 «나눗셈 선행»이 뒤집히는 방향까지 바꾼다 — 버리면 500 아래로,
//    파이썬은 500 위로 간다(05 §GV-8f).
//    덧셈·뺄셈은 Dart 가 정확히 계산한다. 엔진 값 범위(금액 1e12 · 소수 4자리
//    안팎)에서는 28자리를 넘지 않으므로 파이썬과 갈리지 않는다.
//
// ⚠️ 01 §1-1 의 core_engine 허용 의존은 `domain_contracts`·`decimal` 둘이다.
//    `decimal` 이 끌어오는 `rational` 을 직접 import 하지 않으려고 환원은 분자·분모
//    BigInt 로만 한다.

import 'package:decimal/decimal.dart';

/// 파이썬 `decimal` 기본 문맥의 유효숫자(`getcontext().prec`).
const int kContextPrecision = 28;

final BigInt _ten = BigInt.from(10);
final BigInt _two = BigInt.two;

/// 비율(double)을 Decimal 로 승격한다 — 규약 ①.
///
/// `Decimal.parse(r.toString())` 이다. double 의 이진 값을 그대로 옮기지 않는다
/// (`0.0035` 의 이진 값은 0.003500000000000000029… 다).
Decimal promoteRatio(double ratio) {
  if (ratio.isNaN || ratio.isInfinite) {
    throw ArgumentError.value(ratio, 'ratio', '유한한 값이어야 한다');
  }
  return Decimal.parse(ratio.toString());
}

/// `1 − ratio` 를 Decimal 안에서 계산한다 — 규약 ⑤.
///
/// `1 - 0.07` 을 double 로 먼저 빼면 0.9299999999999999 가 된다.
Decimal oneMinus(double ratio) => Decimal.one - promoteRatio(ratio);

/// `a / b` — 파이썬 `Decimal` 나눗셈과 같은 답(유효숫자 28 · HALF_EVEN).
Decimal divide(Decimal a, Decimal b) {
  if (b == Decimal.zero) {
    throw ArgumentError.value(b, 'b', '0 으로 나눌 수 없다');
  }
  final ra = a.toRational();
  final rb = b.toRational();
  return _contextRound(
    ra.numerator * rb.denominator,
    ra.denominator * rb.numerator,
  );
}

/// `a × b` — 파이썬 `Decimal` 곱셈과 같은 답(28자리를 넘으면 문맥으로 끊는다).
Decimal multiply(Decimal a, Decimal b) {
  final ra = a.toRational();
  final rb = b.toRational();
  return _contextRound(
    ra.numerator * rb.numerator,
    ra.denominator * rb.denominator,
  );
}

/// Decimal → double — 규약 ② «double 필드에 담을 때만 내린다»의 **내리는 길**(🆕 E10e1).
///
/// 🔴 `Decimal.toDouble()` 은 유리수의 분자 ÷ 분모를 double 로 나눠 마지막 자리가 어긋난다(유효숫자 28 로 환원한
///    `105.000…` 이 `104.99999999999999` 가 된다 — 실측). 십진 문자열을 거쳐 가장 가까운 double 로 내린다.
double demoteToDouble(Decimal value) => double.parse(value.toString());

/// `(a × b) / c` — 규약 ④ «곱셈 먼저, 나눗셈 나중»을 모양으로 강제한다.
///
/// `(a / c) × b` 로 쓰면 비종료 소수가 먼저 생겨 동률 판정이 뒤집힌다(05 §GV-8f).
Decimal mulDiv(Decimal a, Decimal b, Decimal c) => divide(multiply(a, b), c);

/// 분수 `numerator / denominator` 를 유효숫자 28 · HALF_EVEN 으로 환원한다.
Decimal _contextRound(BigInt numerator, BigInt denominator) {
  if (numerator == BigInt.zero) return Decimal.zero;
  final bool negative = numerator.isNegative != denominator.isNegative;
  final BigInt n = numerator.abs();
  final BigInt d = denominator.abs();

  // 10^e <= n/d < 10^(e+1) 인 e(조정 지수)를 찾는다.
  int exponent = n.toString().length - d.toString().length;
  if (_lessThanPow10(n, d, exponent)) exponent -= 1;

  // 소수 몇 자리까지 남길지 — 유효숫자 28 이 되도록.
  final int fractionDigits = kContextPrecision - 1 - exponent;
  final BigInt scaledN = fractionDigits >= 0 ? n * _ten.pow(fractionDigits) : n;
  final BigInt scaledD = fractionDigits >= 0
      ? d
      : d * _ten.pow(-fractionDigits);

  BigInt digits = scaledN ~/ scaledD;
  final BigInt twiceRemainder = (scaledN - digits * scaledD) * _two;
  if (twiceRemainder > scaledD || (twiceRemainder == scaledD && digits.isOdd)) {
    digits += BigInt.one;
  }

  final Decimal rounded = Decimal.fromBigInt(digits).shift(-fractionDigits);
  return negative ? -rounded : rounded;
}

/// `n / d < 10^exponent` 인가.
bool _lessThanPow10(BigInt n, BigInt d, int exponent) =>
    exponent >= 0 ? n < d * _ten.pow(exponent) : n * _ten.pow(-exponent) < d;
