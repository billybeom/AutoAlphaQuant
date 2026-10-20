// 백분위 정규화 — `06_시스템설계/03_알고리즘.md` §0-3 · §1-1 `pit_percentile` · §1-8 `rolling_percentile`.
//
// 🔴 PIT(point-in-time): t 시점의 값은 **그 시점까지** 관측으로만 자르고 순위를 매긴다 — 미래 관측으로 과거를
//    다시 자르지 않는다. 처음 `minPeriods − 1` 개는 경계가 없어 **안 잘린 채** 순위 표본에 남는다.
// 🔴 참조 구현(백테스트6 `indicators.py`)의 pandas 의미론을 그대로: 분위수 = 선형 보간
//    (`x = q·(n−1)` · 정수면 그 값), 경계가 없으면 그쪽은 자르지 않음, 순위 = 평균 순위(동률 평균),
//    `pct = 순위 / 표본 수 × 100`. 결측은 표본에 넣지 않고 그날 값도 결측.
// 🔵 26년 경로에서 pandas 와 비트 일치를 확인했다(E6b · test/replay).

/// 03 §1-1 `pit_percentile` — 확장 윈저화(1%·99%) → 확장 평균 순위 백분위(0~100).
///
/// 표본(결측 아닌 관측) 수가 [minPeriods] 보다 적은 날과 결측인 날은 null.
List<double?> pitPercentile(
  List<double?> values, {
  int minPeriods = 756,
  double lowerQuantile = 0.01,
  double upperQuantile = 0.99,
}) {
  if (minPeriods < 1) {
    throw ArgumentError.value(minPeriods, 'minPeriods', '1 이상이어야 한다');
  }
  if (!(0 <= lowerQuantile &&
      lowerQuantile <= upperQuantile &&
      upperQuantile <= 1)) {
    throw ArgumentError('분위수는 0 ≤ 하한 ≤ 상한 ≤ 1 이어야 한다');
  }
  final List<double> raw = <double>[]; // 원값 정렬 표본(경계용)
  final List<double> clipped = <double>[]; // 잘린 값 정렬 표본(순위용)
  final List<double?> out = List<double?>.filled(values.length, null);
  for (int t = 0; t < values.length; t++) {
    final double? v = values[t];
    final bool present = v != null && !v.isNaN;
    if (present) _insort(raw, v);
    double w = present ? v : double.nan;
    if (present && raw.length >= minPeriods) {
      final double lo = _quantile(raw, lowerQuantile);
      final double hi = _quantile(raw, upperQuantile);
      if (w < lo) w = lo;
      if (w > hi) w = hi;
    }
    if (!present) continue;
    _insort(clipped, w);
    if (clipped.length < minPeriods) continue;
    out[t] = _averageRankPct(clipped, w);
  }
  return out;
}

/// 03 §1-8 `rolling_percentile` — 최근 [window] 개(오늘 포함)가 전부 있을 때만 평균 순위 백분위.
List<double?> rollingPercentile(List<double?> values, int window) {
  if (window < 1) throw ArgumentError.value(window, 'window', '1 이상');
  final List<double?> out = List<double?>.filled(values.length, null);
  for (int t = window - 1; t < values.length; t++) {
    final List<double> sample = <double>[];
    bool complete = true;
    for (int i = t - window + 1; i <= t; i++) {
      final double? v = values[i];
      if (v == null || v.isNaN) {
        complete = false;
        break;
      }
      sample.add(v);
    }
    if (!complete) continue;
    sample.sort();
    out[t] = _averageRankPct(sample, values[t]!);
  }
  return out;
}

/// 정렬 표본에서 [v] 의 평균 순위 / 표본 수 × 100.
double _averageRankPct(List<double> sorted, double v) {
  final int rMin = _lowerBound(sorted, v) + 1;
  final int rMax = _upperBound(sorted, v);
  final double rank =
      ((rMax * (rMax + 1) / 2) - ((rMin - 1) * rMin / 2)) / (rMax - rMin + 1);
  return rank / sorted.length * 100;
}

/// 선형 보간 분위수(pandas `quantile(interpolation="linear")`).
double _quantile(List<double> sorted, double q) {
  final double x = q * (sorted.length - 1);
  final int k = x.floor();
  if (x == k) return sorted[k];
  return sorted[k] + (sorted[k + 1] - sorted[k]) * (x - k);
}

void _insort(List<double> sorted, double v) =>
    sorted.insert(_upperBound(sorted, v), v);

int _lowerBound(List<double> sorted, double v) {
  int lo = 0;
  int hi = sorted.length;
  while (lo < hi) {
    final int mid = (lo + hi) >> 1;
    if (sorted[mid] < v) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

int _upperBound(List<double> sorted, double v) {
  int lo = 0;
  int hi = sorted.length;
  while (lo < hi) {
    final int mid = (lo + hi) >> 1;
    if (sorted[mid] <= v) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}
