// 파이썬 참조 구현(pandas · numpy)과 같은 double 을 내는 수치 함수 — 골든 대조가 «4자리 반올림 일치»를
// 우연이 아니라 연산 순서 일치로 서게 한다(설계 13 §8 R16 · E6e).
//
// 🔴 정본은 참조 라이브러리의 동작이다. 여기 함수는 그 동작을 옮긴 것이고, 재현 하네스(`test/replay/`)가
//    26년 실행으로 비트 일치를 확인했다(E6c `npSum` · E6e `pyRound` · E7a1 `kahanGroupSum`).

import 'dart:typed_data';

/// numpy 짝 합산(`pairwise_sum`) — n < 8 은 0 부터 차례로 · n ≤ 128 은 누산기 8개 · 그보다 크면 반으로 나눠 재귀
/// (반 = n/2 를 8 의 배수로 내림). `np.mean` · pandas `Series.sum`(bottleneck 없음)이 이 값이다.
double npSum(List<double> a, [int start = 0, int? end]) {
  final int stop = end ?? a.length;
  final int n = stop - start;
  if (n < 8) {
    double res = 0.0;
    for (int i = start; i < stop; i++) {
      res += a[i];
    }
    return res;
  }
  if (n <= 128) {
    final List<double> r = a.sublist(start, start + 8);
    int i = 8;
    for (; i < n - (n % 8); i += 8) {
      for (int j = 0; j < 8; j++) {
        r[j] += a[start + i + j];
      }
    }
    double res =
        ((r[0] + r[1]) + (r[2] + r[3])) + ((r[4] + r[5]) + (r[6] + r[7]));
    for (; i < n; i++) {
      res += a[start + i];
    }
    return res;
  }
  int n2 = n ~/ 2;
  n2 -= n2 % 8;
  return npSum(a, start, start + n2) + npSum(a, start + n2, stop);
}

/// pandas `groupby(key).sum()` — 무리별 카한 합산(`_libs/groupby.pyx::group_sum`) · 키 오름차순.
/// 무리 안 순서는 들어온 순서다.
List<(K, double)> kahanGroupSum<K extends Comparable<Object>>(
  Iterable<(K, double)> rows,
) {
  final Map<K, (double, double)> acc = <K, (double, double)>{};
  for (final (K k, double v) in rows) {
    final (double sumx, double comp) = acc[k] ?? (0.0, 0.0);
    final double y = v - comp;
    final double t = sumx + y;
    final double c = t - sumx - y;
    acc[k] = (t, c.isNaN ? 0.0 : c);
  }
  final List<K> keys = acc.keys.toList()..sort();
  return <(K, double)>[for (final K k in keys) (k, acc[k]!.$1)];
}

/// 파이썬 `round(x, nd)` — 이진수 정확값을 소수 nd 자리로 반올림(동률은 짝수)한 뒤 가장 가까운 double.
double pyRound(double x, int nd) {
  if (x.isNaN || x.isInfinite || x == 0) return x;
  final (bool neg, BigInt q) = _roundScaled(x, nd);
  final double out = double.parse('${q}e-$nd');
  return neg ? -out : out;
}

/// 파이썬 `round(x)`(자릿수 없음) — 동률은 짝수인 정수.
int pyRoundInt(double x) {
  if (x.isNaN || x.isInfinite) {
    throw ArgumentError.value(x, 'x', '유한한 값이어야 한다');
  }
  if (x == 0) return 0;
  final (bool neg, BigInt q) = _roundScaled(x, 0);
  return neg ? -q.toInt() : q.toInt();
}

/// |x| × 10^nd 를 동률 짝수로 반올림한 정수(부호는 따로).
(bool, BigInt) _roundScaled(double x, int nd) {
  final ByteData bd = ByteData(8)..setFloat64(0, x);
  final int bits = bd.getInt64(0);
  final bool neg = bits < 0;
  final int ex = (bits >> 52) & 0x7ff;
  final int frac = bits & 0xfffffffffffff;
  final BigInt mant = BigInt.from(ex == 0 ? frac : frac | (1 << 52));
  final int e2 = (ex == 0 ? 1 : ex) - 1075; // |x| = mant × 2^e2
  BigInt num = mant * BigInt.from(10).pow(nd);
  BigInt den = BigInt.one;
  if (e2 >= 0) {
    num <<= e2;
  } else {
    den <<= -e2;
  }
  BigInt q = num ~/ den;
  final BigInt rem2 = (num - q * den) * BigInt.two;
  if (rem2 > den || (rem2 == den && q.isOdd)) q += BigInt.one;
  return (neg, q);
}
