// E6e 재현 지표 — 참조 엔진(백테스트6) 골든 생성기 `exp/N2_golden_p0s.py` 의 성과·세후·금 비중·실현 배분을
// 같은 연산 순서의 double 로 옮긴다.
//
// 🔴 정본은 파이썬 코드다: 성과 = `exp/harness.py::stats` · 세후 = N2 `pot_tax` · `aftertax` · 반올림 = N2 `pct4`.
//    평균·표준편차는 pandas(`nanops.nanmean` · `nanvar` — bottleneck 없음) = numpy 짝 합산([npSum])이다.
// 🔵 거듭제곱(CAGR) 하나만 C 라이브러리 `pow` 를 탄다 — 플랫폼마다 1 ULP 쯤 다를 수 있어 반올림 전 대조는 ULP 로 잰다.

import 'dart:math' as math;
import 'dart:typed_data';

import 'replay_engine.dart';

/// `harness.stats` 의 판정 항목.
class PerfStats {
  const PerfStats(this.cagr, this.mdd, this.vol, this.years, this.endMult);
  final double cagr, mdd, vol, years, endMult;
}

/// pandas `Series.std(ddof=1)` = `nanvar` 두 번 훑기(평균 = 합 ÷ n · 편차 제곱합 ÷ (n − 1))의 제곱근.
double pdStd(List<double> v) {
  final double avg = npSum(v) / v.length;
  final List<double> sqr = <double>[
    for (final double x in v) (avg - x) * (avg - x),
  ];
  return math.sqrt(npSum(sqr) / (v.length - 1));
}

/// pandas `pct_change().dropna()` — `x / x.shift(1) − 1` 에서 첫 칸을 뺀다.
List<double> pctChange(List<double> e) => <double>[
  for (int k = 1; k < e.length; k++) e[k] / e[k - 1] - 1.0,
];

int _days(String a, String b) =>
    DateTime.parse('${b}T00:00:00Z')
        .difference(DateTime.parse('${a}T00:00:00Z'))
        .inDays;

/// `harness.stats(equity, flows)` — `flows` 를 주면 TWR 로 다시 쌓는다
/// (`r = (e − f) / e.shift(1) − 1` · `e' = [100] + cumprod(1 + r) × 100`).
PerfStats harnessStats(
  List<String> dates,
  List<double> equity, {
  List<double>? flows,
}) {
  List<double> e = equity;
  if (flows != null) {
    final List<double> tw = <double>[100.0];
    double cp = 1.0;
    for (int k = 1; k < equity.length; k++) {
      final double r = (equity[k] - flows[k]) / equity[k - 1] - 1.0;
      cp *= 1.0 + r; // numpy `cumprod` — 1.0 × 첫 값은 정확하다
      tw.add(cp * 100.0);
    }
    e = tw;
  }
  final List<double> r = pctChange(e);
  final double yrs = math.max(_days(dates.first, dates.last) / 365.25, 1e-9);
  final double endMult = e.last / e.first;
  final double cagr = math.pow(endMult, 1 / yrs).toDouble() - 1.0;
  final double vol = pdStd(r) * math.sqrt(252);
  double peak = double.negativeInfinity;
  double mdd = double.infinity;
  for (final double x in e) {
    if (x > peak) peak = x;
    final double dd = x / peak - 1.0;
    if (dd < mdd) mdd = dd;
  }
  return PerfStats(cagr, mdd, vol, yrs, endMult);
}

/// N2 `pot_tax` — POT 서브북(현금 제외) 매도 이익 × 15.4%(종목별 평균 단가 · 손실은 0).
/// 🔵 원장은 이미 날짜순이다(엔진이 날짜순으로 쌓는다) — `sort_values("date")` 는 순서를 바꾸지 않는다고 본다(정답지가 판정).
List<(String, double)> potTax(List<LedgerRow> ledger) {
  final Map<String, List<double>> basis = <String, List<double>>{};
  final List<(String, double)> taxes = <(String, double)>[];
  for (final LedgerRow r in ledger) {
    if (r.sleeve != 'POT' || r.symbol == 'CASH') continue;
    final List<double> b = basis.putIfAbsent(
      r.symbol,
      () => <double>[0.0, 0.0],
    );
    if (r.side == 'BUY') {
      b[0] += r.qty;
      b[1] += r.gross;
    } else if (r.side == 'SELL' && b[0] > 0) {
      final double unit = b[1] / b[0];
      final double gain = r.gross - unit * r.qty;
      b[0] -= r.qty;
      b[1] -= unit * r.qty;
      if (gain > 0) taxes.add((r.date, gain * 0.154));
    }
  }
  return taxes;
}

/// pandas `groupby(...).sum()` — 무리별 카한 합산(`_libs/groupby.pyx::group_sum`) · 키 오름차순.
List<(String, double)> groupSumByDate(List<(String, double)> rows) {
  final Map<String, (double, double)> acc = <String, (double, double)>{};
  for (final (String d, double v) in rows) {
    final (double sumx, double comp) = acc[d] ?? (0.0, 0.0);
    final double y = v - comp;
    final double t = sumx + y;
    final double c = t - sumx - y;
    acc[d] = (t, c.isNaN ? 0.0 : c);
  }
  final List<String> keys = acc.keys.toList()..sort();
  return <(String, double)>[for (final String k in keys) (k, acc[k]!.$1)];
}

/// N2 `aftertax` — 세금 낸 날의 수익률에서 «세금 ÷ 전날 자산»을 빼고 다시 쌓아 `stats`(유출입 없이).
(PerfStats, List<double>) afterTax(
  List<String> dates,
  List<double> equity,
  List<double> flows,
  List<LedgerRow> ledger,
) {
  final List<double> r = <double>[0.0];
  for (int k = 1; k < equity.length; k++) {
    r.add((equity[k] - flows[k]) / equity[k - 1] - 1.0);
  }
  final Map<String, int> pos = <String, int>{
    for (int k = 0; k < dates.length; k++) dates[k]: k,
  };
  for (final (String d, double tv) in groupSumByDate(potTax(ledger))) {
    final int? k = pos[d];
    if (k != null) r[k] -= tv / equity[k - 1];
  }
  final List<double> e2 = <double>[];
  double cp = 1.0;
  for (final double x in r) {
    cp *= 1.0 + x; // numpy `cumprod` — 1.0 × 첫 값은 정확하다
    e2.add(cp * 100.0);
  }
  return (harnessStats(dates, e2), e2);
}

/// N2 금 총자산 비중 — `gold_total = c_iau + gold_b + gold_pot` ÷ 자산(무한대·NaN 은 뺀다).
class GoldShare {
  GoldShare(List<DailyRow> daily) {
    final List<double> share = <double>[], sc = <double>[], sb = <double>[];
    for (final DailyRow d in daily) {
      final Map<String, double> v = d.values;
      final double eq = v['equity']!;
      final double s = (v['c_iau']! + v['gold_b']! + v['gold_pot']!) / eq;
      if (s.isNaN || s.isInfinite) continue;
      share.add(s);
      sc.add(v['c_iau']! / eq);
      sb.add((v['gold_b']! + v['gold_pot']!) / eq);
    }
    n = share.length;
    mean = npMean(share);
    max = share.reduce(math.max);
    cMean = npMean(sc);
    bPotMean = npMean(sb);
    gt20 = share.where((double s) => s > 0.20).length / n;
  }
  late final int n;
  late final double mean, max, cMean, bPotMean, gt20;
}

/// N2 실현 배분 — 일별 열 비율의 전 기간 평균(회계 소속: A_acct = A + POT · C_acct = C − POT).
Map<String, double> realizedAlloc(List<DailyRow> daily) {
  double Function(DailyRow) col(String k) =>
      (DailyRow d) => d.values[k]!;
  double mean(double Function(DailyRow) num) => npMean(<double>[
    for (final DailyRow d in daily) num(d) / d.values['equity']!,
  ]);
  return <String, double>{
    'A': mean(col('A')),
    'B': mean(col('B')),
    'C_incl_pot': mean(col('C')),
    'krw_cash': mean(
      (DailyRow d) => d.values['c_krw']! + d.values['c_park_c']!,
    ),
    'c_bond': mean(col('c_iei')),
    'c_gold': mean(col('c_iau')),
    'A_acct_incl_pot': mean((DailyRow d) => d.values['A']! + d.values['pot']!),
    'C_acct_excl_pot': mean((DailyRow d) => d.values['C']! - d.values['pot']!),
    'pot': mean(col('pot')),
  };
}

/// 파이썬 `round(x, nd)` — 이진수 정확값을 소수 nd 자리로 반올림(동률은 짝수)한 뒤 가장 가까운 double.
double pyRound(double x, int nd) {
  if (x.isNaN || x.isInfinite || x == 0) return x;
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
  final double out = double.parse('${q}e-$nd');
  return neg ? -out : out;
}

/// N2 `pct4` — `round(x × 100, 4)`.
double pct4(double x) => pyRound(x * 100.0, 4);

/// 두 double 사이의 ULP 거리(같은 부호 가정).
int ulpDistance(double a, double b) {
  final ByteData bd = ByteData(16)
    ..setFloat64(0, a)
    ..setFloat64(8, b);
  return (bd.getInt64(0) - bd.getInt64(8)).abs();
}
