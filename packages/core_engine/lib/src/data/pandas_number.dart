// M1-7 수 변환 — 시세·지표 문자열 → double 을 참조 엔진(pandas `read_csv`)과 **같은 비트로**(설계 13 §8 R26 H9 · E8c).
//
// 🔴 pandas `read_csv` 의 기본 수 변환은 정확 반올림이 아니다(`float_precision=None` = `precise_xstrtod`). 동결 번들
//    24개 CSV 807,854 셀 중 64,661 셀이 `double.parse` 와 최대 2 ULP 다르다(2026-10-20 실측 · E6). 골든이 그 변환으로
//    만들어졌으므로 시드 적재와 실전 수집(data_sync · E8c)도 같은 변환을 쓴다 — `double.parse` 면 `vix_term` 같은 비율의
//    백분위 순위가 갈려 골든 경로에서 벗어나고, 시드 값과 실전 값의 겹친 날 비교가 같은 글자를 «다르다»고 본다.
// 🔵 E6 재현 하네스(`test/replay/replay_csv.dart`)에서 옮겼다 — 하네스도 이것을 부르고 `fixtures/parse_parity.json`
//    (열별 float64 해시)이 회귀 시험이다.

/// pandas `tokenizer.c::precise_xstrtod`(최대 17자리 누적 · 10 거듭제곱 표로 한 번 곱/나눔 · 부정규수 두 단계)
/// 의 Dart 판. 숫자가 아니면 null(= `to_numeric(errors="coerce")` 의 NaN).
double? pandasPreciseXstrtod(String s) {
  const int maxDigits = 17;
  int p = 0;
  final int n = s.length;
  bool space(int i) => i < n && ' \t\r\n\f\v'.contains(s[i]);
  bool digit(int i) =>
      i < n && s.codeUnitAt(i) >= 0x30 && s.codeUnitAt(i) <= 0x39;
  while (space(p)) {
    p++;
  }
  bool negative = false;
  if (p < n && (s[p] == '+' || s[p] == '-')) {
    negative = s[p] == '-';
    p++;
  }
  double number = 0.0;
  int exponent = 0;
  int numDigits = 0;
  int numDecimals = 0;
  while (digit(p)) {
    if (numDigits < maxDigits) {
      number = number * 10.0 + (s.codeUnitAt(p) - 0x30);
      numDigits++;
    } else {
      exponent++;
    }
    p++;
  }
  if (p < n && s[p] == '.') {
    p++;
    while (numDigits < maxDigits && digit(p)) {
      number = number * 10.0 + (s.codeUnitAt(p) - 0x30);
      p++;
      numDigits++;
      numDecimals++;
    }
    if (numDigits >= maxDigits) {
      while (digit(p)) {
        p++;
      }
    }
    exponent -= numDecimals;
  }
  if (numDigits == 0) return null;
  if (negative) number = -number;
  if (p < n && (s[p] == 'e' || s[p] == 'E')) {
    p++;
    bool expNegative = false;
    if (p < n && (s[p] == '+' || s[p] == '-')) {
      expNegative = s[p] == '-';
      p++;
    }
    if (!digit(p)) return null;
    int e = 0;
    while (digit(p)) {
      e = e * 10 + (s.codeUnitAt(p) - 0x30);
      p++;
    }
    exponent += expNegative ? -e : e;
  }
  while (space(p)) {
    p++;
  }
  if (p != n) return null;
  if (exponent > 308) {
    return negative ? double.negativeInfinity : double.infinity;
  } else if (exponent > 0) {
    number *= _pow10[exponent];
  } else if (exponent < -308) {
    if (exponent < -616) {
      number = 0.0;
    } else {
      number /= _pow10[-308 - exponent];
      number /= _pow10[308];
    }
  } else {
    number /= _pow10[-exponent];
  }
  return number;
}

/// C 리터럴 `1e0`~`1e308` 과 같은 값(정확 반올림 상수).
final List<double> _pow10 = List<double>.generate(
  309,
  (int k) => double.parse('1e$k'),
  growable: false,
);
