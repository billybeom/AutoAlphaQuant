// 기술 지표 — `06_시스템설계/03_알고리즘.md` §0-3(워밍업) · §1-5(추세성 지표) · §3-5(ATR) · 05 GV-2.
//
// 참조 구현 = `09_백테스트/백테스트6/engine/indicators.py`(전략 골든 `golden_p0s.json` 을 만든 엔진).
// 규약은 그 파일 머리와 03 이 같다:
//   · TR[0] = high[0] − low[0]          (close₋₁ 이 없으므로 첫 항만)
//   · ±DM[0] = 0.0
//   · rma(x, n): 선행 결측은 건너뛰고 첫 유효값부터 n개 SMA 로 시작, 이후 Wilder 재귀
//               (α = 1/n — 표준 EMA 2/(n+1) 이 아니다). 중간 결측이 오면 그 뒤는 전부 결측
//   · ADX 는 warmup 봉 하드 게이트 — 길이 < warmup 이면 전부 결측, 아니면 [0, warmup−2] 결측
//   · BBW 만 ddof = 0(모표준편차)
//   · 중간 계산에 반올림 금지(03 §0-4)
//
// 결측 표현: 공개 함수는 `List<double?>` 를 받고 돌려준다(null = 결측). 안에서는 numpy 처럼
// NaN 으로 계산한다 — 참조 구현의 «NaN 비교는 거짓» 동작(예: 고가가 빠진 날의 ±DM = 0)을
// 그대로 옮기기 위해서다.
//
// ⚠️ 합·평균은 창마다 왼쪽부터 더한다. 참조 구현은 pandas 의 보정 합(rolling)과 numpy 의
// 쌍별 합(시드 평균)을 쓰므로 마지막 자리(ULP)가 다를 수 있다. GV-2 허용오차(1e-4~1e-6)
// 안이며, 26년 경로에서 경계 판정을 바꾸는지는 E6(전략 4자리 대조)에서 잰다(13 §8 R2).
// ⚠️ Dart 에는 log10 이 없어 ln(x)/ln(10) 으로 쓴다 — libm log10 과 1 ULP 다를 수 있다(같은 사유).

import 'dart:math' as math;

/// 단순이동평균 SMA(n). 창에 결측이 하나라도 있으면 결측(pandas `min_periods = n`).
List<double?> sma(List<double?> values, int period) {
  _checkPeriod(period, 1);
  return _toNullable(_rollingMean(_toNaN(values), period));
}

/// True Range. TR[0] = H−L, 이후 max(H−L, |H−C₋₁|, |L−C₋₁|) — 셋 중 하나라도 결측이면 결측.
List<double?> trueRange(
  List<double?> high,
  List<double?> low,
  List<double?> close,
) => _toNullable(_trueRange(_toNaN(high), _toNaN(low), _toNaN(close)));

/// Wilder 평활 rma(x, n).
List<double?> rma(List<double?> values, int period) {
  _checkPeriod(period, 1);
  return _toNullable(_rma(_toNaN(values), period));
}

/// Wilder 재귀 한 걸음: `(prev × (n−1) + value) / n` (GV-2d).
double rmaStep(double previous, double value, int period) {
  _checkPeriod(period, 1);
  return (previous * (period - 1) + value) / period;
}

/// ATR(n, Wilder) = rma(TR, n). 첫 유효 인덱스 = n−1(03 §0-3).
List<double?> atr(
  List<double?> high,
  List<double?> low,
  List<double?> close,
  int period,
) {
  _checkPeriod(period, 1);
  final List<double> h = _toNaN(high);
  final List<double> l = _toNaN(low);
  final List<double> c = _toNaN(close);
  return _toNullable(_rma(_trueRange(h, l, c), period));
}

/// ADX(n, Wilder) — 🔴 [warmup] 봉 하드 게이트(03 §0-3 · §1-5 · GV-2c·2f).
///
/// 길이 < [warmup] 이면 전부 결측. 아니면 인덱스 [warmup]−1 이 첫 유효값이다.
List<double?> adx(
  List<double?> high,
  List<double?> low,
  List<double?> close, {
  required int period,
  required int warmup,
}) {
  _checkPeriod(period, 1);
  if (warmup < 1) {
    throw ArgumentError.value(warmup, 'warmup', '1 이상이어야 한다');
  }
  final List<double> h = _toNaN(high);
  final List<double> l = _toNaN(low);
  final List<double> c = _toNaN(close);
  _checkSameLength(h, l, c);
  final int length = h.length;
  if (length < warmup) return List<double?>.filled(length, null);

  final ({List<double> plus, List<double> minus}) dm = _directionalMovement(
    h,
    l,
  );
  final List<double> trN = _rma(_trueRange(h, l, c), period);
  final List<double> plusN = _rma(dm.plus, period);
  final List<double> minusN = _rma(dm.minus, period);
  final List<double> dx = List<double>.filled(length, double.nan);
  for (int i = 0; i < length; i++) {
    final double plusDi = 100 * plusN[i] / trN[i];
    final double minusDi = 100 * minusN[i] / trN[i];
    final double denominator = plusDi + minusDi;
    // 합이 0 이면 결측(03 §1-5 «(+DI + −DI) == 0 이면 NaN»). 결측끼리의 합은 NaN 이라 그대로 간다.
    if (denominator != 0) {
      dx[i] = 100 * (plusDi - minusDi).abs() / denominator;
    }
  }

  final List<double> out = _rma(dx, period);
  for (int i = 0; i < warmup - 1; i++) {
    out[i] = double.nan;
  }
  return _toNullable(out);
}

/// Choppiness Index CHOP(n) = 100 · log10(ΣTR(n) / (max H(n) − min L(n))) / log10(n).
///
/// 첫 유효 인덱스 = n−1(첫 봉 TR = H−L 덕분). 범위가 0 이면 결측(상수 시리즈).
List<double?> chop(
  List<double?> high,
  List<double?> low,
  List<double?> close,
  int period,
) {
  _checkPeriod(period, 2); // log10(1) = 0 이라 n = 1 은 뜻이 없다
  final List<double> h = _toNaN(high);
  final List<double> l = _toNaN(low);
  final List<double> c = _toNaN(close);
  _checkSameLength(h, l, c);
  final List<double> trSum = _rollingSum(_trueRange(h, l, c), period);
  final List<double> highMax = _rollingExtreme(h, period, math.max);
  final List<double> lowMin = _rollingExtreme(l, period, math.min);
  final double logPeriod = _log10(period.toDouble());
  final List<double> out = List<double>.filled(h.length, double.nan);
  for (int i = 0; i < h.length; i++) {
    final double range = highMax[i] - lowMin[i];
    if (range != 0) out[i] = 100 * _log10(trSum[i] / range) / logPeriod;
  }
  return _toNullable(out);
}

/// Bollinger BandWidth = (upper − lower) / mid × 100 = 2·k·sd / mid × 100.
///
/// 🔴 sd 는 **ddof = 0**(모표준편차) — BBW 만 그렇다(03 §0-5 · GV-2e).
List<double?> bbw(
  List<double?> close, {
  required int period,
  required double numStd,
}) {
  _checkPeriod(period, 1);
  final List<double> c = _toNaN(close);
  final List<double> mid = _rollingMean(c, period);
  final List<double> out = List<double>.filled(c.length, double.nan);
  for (int i = period - 1; i < c.length; i++) {
    if (mid[i].isNaN) continue;
    double squares = 0;
    for (int j = i - period + 1; j <= i; j++) {
      final double d = c[j] - mid[i];
      squares += d * d;
    }
    final double sd = math.sqrt(squares / period);
    out[i] = (2 * numStd * sd) / mid[i] * 100;
  }
  return _toNullable(out);
}

/// ±DM(방향성 움직임) — ADX 의 입력(03 §1-5).
///
/// - +DM = 고가 상승폭이 저가 하락폭보다 **크고** 0 보다 크면 그 폭, 아니면 0(−DM 은 반대).
///   두 폭이 같으면 둘 다 0 이다.
/// - 첫 봉은 둘 다 0. 차분이 결측이면 비교가 거짓이라 0 이다(참조 구현 `np.where` 와 같다).
///
/// 🔵 배럴로 내보내지 않는다 — ADX 의 내부 단계이고 시험을 위해서만 열어 둔다.
({List<double> plus, List<double> minus}) directionalMovement(
  List<double?> high,
  List<double?> low,
) {
  final List<double> h = _toNaN(high);
  final List<double> l = _toNaN(low);
  if (h.length != l.length) {
    throw ArgumentError('high·low 길이가 다르다: ${h.length}/${l.length}');
  }
  return _directionalMovement(h, l);
}

// ── 내부: NaN 으로 계산한다 ──────────────────────────────────────────────

({List<double> plus, List<double> minus}) _directionalMovement(
  List<double> h,
  List<double> l,
) {
  final List<double> plus = List<double>.filled(h.length, 0.0);
  final List<double> minus = List<double>.filled(h.length, 0.0);
  for (int i = 1; i < h.length; i++) {
    final double up = h[i] - h[i - 1];
    final double down = l[i - 1] - l[i];
    if (up > down && up > 0) plus[i] = up;
    if (down > up && down > 0) minus[i] = down;
  }
  return (plus: plus, minus: minus);
}

List<double> _trueRange(List<double> h, List<double> l, List<double> c) {
  _checkSameLength(h, l, c);
  final List<double> tr = List<double>.filled(h.length, double.nan);
  if (h.isEmpty) return tr;
  tr[0] = h[0] - l[0]; // 🔴 첫 봉만 예외
  for (int i = 1; i < h.length; i++) {
    final double a = h[i] - l[i];
    final double b = (h[i] - c[i - 1]).abs();
    final double d = (l[i] - c[i - 1]).abs();
    // pandas max(skipna=False): 하나라도 결측이면 결측.
    tr[i] = (a.isNaN || b.isNaN || d.isNaN)
        ? double.nan
        : math.max(a, math.max(b, d));
  }
  return tr;
}

List<double> _rma(List<double> x, int n) {
  final List<double> out = List<double>.filled(x.length, double.nan);
  final int start = x.indexWhere((double v) => !v.isNaN);
  if (start < 0 || start + n > x.length) return out;
  double seed = 0;
  for (int i = start; i < start + n; i++) {
    // 선행 구간에 중간 결측이 섞이면 시드를 만들 수 없다 — 전부 결측(참조 구현과 같다).
    if (x[i].isNaN) return out;
    seed += x[i];
  }
  double previous = seed / n;
  out[start + n - 1] = previous;
  for (int i = start + n; i < x.length; i++) {
    previous = (previous * (n - 1) + x[i]) / n; // 결측이 들어오면 NaN 이 끝까지 간다
    out[i] = previous;
  }
  return out;
}

List<double> _rollingSum(List<double> x, int n) {
  final List<double> out = List<double>.filled(x.length, double.nan);
  for (int i = n - 1; i < x.length; i++) {
    double sum = 0;
    for (int j = i - n + 1; j <= i; j++) {
      sum += x[j];
    }
    out[i] = sum; // 창에 NaN 이 있으면 NaN
  }
  return out;
}

List<double> _rollingMean(List<double> x, int n) => <double>[
  for (final double s in _rollingSum(x, n)) s / n,
];

List<double> _rollingExtreme(
  List<double> x,
  int n,
  double Function(double, double) pick,
) {
  final List<double> out = List<double>.filled(x.length, double.nan);
  for (int i = n - 1; i < x.length; i++) {
    double best = x[i - n + 1];
    bool missing = best.isNaN;
    for (int j = i - n + 2; j <= i && !missing; j++) {
      if (x[j].isNaN) {
        missing = true;
      } else {
        best = pick(best, x[j]);
      }
    }
    out[i] = missing ? double.nan : best;
  }
  return out;
}

double _log10(double x) => math.log(x) / math.ln10;

List<double> _toNaN(List<double?> values) => <double>[
  for (final double? v in values) v ?? double.nan,
];

List<double?> _toNullable(List<double> values) => <double?>[
  for (final double v in values) v.isNaN ? null : v,
];

void _checkPeriod(int period, int minimum) {
  if (period < minimum) {
    throw ArgumentError.value(period, 'period', '$minimum 이상이어야 한다');
  }
}

void _checkSameLength(List<double> h, List<double> l, List<double> c) {
  if (h.length != l.length || h.length != c.length) {
    throw ArgumentError(
      'high·low·close 길이가 다르다: ${h.length}/${l.length}/${c.length}',
    );
  }
}
