// M3-5 · M2-9 ⓒ — 세후 사다리 산식(«전 계좌 세후»). 06 M3-5 · 01 §2-4 · §8 미결 18.
//
// 🔴 세율·통산 규약의 정본은 설계 저장소 `09_백테스트/백테스트6/exp/tax_lib.py`(독스트링)다 — 여기는 그
//    `aftertax_full` 을 **같은 연산 순서의 double** 로 옮긴 것이다(정본을 둘로 만들지 않는다 · 06 M2-9 ⓒ).
//    합은 pandas 와 같게 — 날짜·연도 무리는 카한([kahanGroupSum]), `Series.sum` 은 numpy 짝 합산([npSum]).
// 🔴 **무납입 전용**이다. 외부 현금흐름(월 납입)이 있는 원장은 세금 차감이 납입일 수익률을 오염시키므로
//    보정판 산식이 확정될 때까지(§8 미결 18) [afterTaxFull] 이 거부한다 — tax_lib 의 `assert` 와 같은 자리.
// 🔵 골든 = `golden_p0s.json` 의 `aftertax_full_S7`(4자리) · 재현 하네스가 S7 26년 원장으로 대조한다(E7a1).
//
// 사다리(갈래 하나):
//   세전 e → ① POT 매도 이익 × POT 세율(정본 갈래 = 절세계좌라 0) → ② C(IEI·IAU) 매도 이익 × 15.4%
//   (+ 반사실의 종합과세: 연 실현이익 2,000만 초과분 × (한계세율 − 15.4%) 를 그 해 마지막 이익일에)
//   → 끝 시점 연금 인출세(5.5% · 16.5%) = (연금계좌 잔고 − 세액공제 미수령 원금) × 세율 · 환급 두 줄.
//   세금은 그날 수익률에서 «세금 ÷ 전날 자산»을 뺀다(비례 근사 — tax_lib 독스트링).

import 'dart:math' as math;

import 'package:domain_contracts/domain_contracts.dart' show TaxLadderBranch;

import '../numeric/pandas_compat.dart';

/// 배당소득세(국내상장 해외 ETF 매매차익 · POT 일반계좌) — tax_lib `T_DIV`.
const double kDividendTaxRate = 0.154;

/// 연금 세액공제 대상 납입 상한(연금저축 600 + IRP 300) — tax_lib `CREDIT_CAP`.
const double kPensionCreditCap = 9000000.0;

/// 세액공제 환급률(총급여 5,500만 초과 가정) — tax_lib `CREDIT_RATE`.
const double kPensionCreditRate = 0.132;

/// 금융소득종합과세 기준(연) — tax_lib `FIN_INCOME_THRESHOLD`.
const double kFinancialIncomeThreshold = 20000000.0;

/// 연금 인출세 두 갈래 — 연금 수령 5.5% · 분리과세 16.5%(tax_lib `ladder` 의 `wd_5p5` · `wd_16p5`).
const List<(String, double)> kPensionWithdrawalTaxes = <(String, double)>[
  ('wd_5p5', 0.055),
  ('wd_16p5', 0.165),
];

/// 갈래 → (POT 세율, 종합과세 한계세율 또는 null) — tax_lib `aftertax_full` 의 `out` 네 줄.
const Map<TaxLadderBranch, (double, double?)> kTaxLadderBranchRates =
    <TaxLadderBranch, (double, double?)>{
      TaxLadderBranch.specPotTaxFree: (0.0, null),
      TaxLadderBranch.cfPotTaxableComp26: (kDividendTaxRate, 0.264),
      TaxLadderBranch.cfPotTaxableComp38: (kDividendTaxRate, 0.385),
      TaxLadderBranch.cfPotTaxableFlat: (kDividendTaxRate, null),
    };

/// 골든 블록 키(`spec_pot_taxfree` …) — 🔴 `wire` 소문자가 아니다.
const Map<TaxLadderBranch, String> kTaxLadderGoldenKeys =
    <TaxLadderBranch, String>{
      TaxLadderBranch.specPotTaxFree: 'spec_pot_taxfree',
      TaxLadderBranch.cfPotTaxableComp26: 'cf_pot_taxable_comp26',
      TaxLadderBranch.cfPotTaxableComp38: 'cf_pot_taxable_comp38',
      TaxLadderBranch.cfPotTaxableFlat: 'cf_pot_taxable_flat',
    };

/// 사다리 한 갈래의 층 키 — 골든 블록 순서 그대로.
const List<String> kAfterTaxPointKeys = <String>[
  'pretax',
  'after_pot',
  'after_pot_c',
  'wd_5p5',
  'wd_5p5_refund_nominal',
  'wd_5p5_refund_reinvested',
  'wd_16p5',
  'wd_16p5_refund_nominal',
  'wd_16p5_refund_reinvested',
];

/// 세후 계산이 읽는 원장 한 행(tax_lib 이 쓰는 열만).
class TaxLedgerRow {
  const TaxLedgerRow({
    required this.date,
    required this.sleeve,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.gross,
  });

  /// `YYYY-MM-DD`.
  final String date;
  final String sleeve, symbol, side;
  final double qty, gross;
}

/// 세후 계산 입력 — 일별 자산(날짜 오름차순) + 원장 + 끝 시점 연금계좌 잔고.
class AfterTaxInputs {
  const AfterTaxInputs({
    required this.dates,
    required this.equity,
    required this.ledger,
    required this.pensionEndB,
    required this.pensionEndParkC,
    this.externalFlows,
  });

  /// 세션 날짜 `YYYY-MM-DD`(오름차순 · 결측일 없음).
  final List<String> dates;

  /// 일별 총자산(원).
  final List<double> equity;
  final List<TaxLedgerRow> ledger;

  /// 끝 시점 슬리브 B 평가액 — 연금계좌 잔고의 몫 하나(tax_lib `eq["B"]` 마지막 값).
  final double pensionEndB;

  /// 끝 시점 회계상 C 로 재분류된 파킹(`c_park_c`) — 연금계좌 잔고의 나머지 몫.
  final double pensionEndParkC;

  /// 일별 외부 현금흐름(원). null 또는 전부 0 이어야 한다(무납입 전용).
  final List<double>? externalFlows;
}

/// 사다리 한 층의 반올림 전 값 — `cagrPct` 는 % 단위(11.13… = 연 11.13%).
class AfterTaxPoint {
  const AfterTaxPoint(this.cagrPct, this.endMult);
  final double cagrPct, endMult;
}

/// 사다리 한 갈래 — 층 9개(세전 · POT · C · 인출세 2종 × 환급 3줄) + 재투자 환급액.
class AfterTaxBranch {
  const AfterTaxBranch(this.points, this.refundReinvestedKrw);

  /// 키 = [kAfterTaxPointKeys].
  final Map<String, AfterTaxPoint> points;
  final double refundReinvestedKrw;
}

/// tax_lib `inputs` 블록(반올림 전).
class AfterTaxFullInputs {
  const AfterTaxFullInputs({
    required this.pensionEnd,
    required this.pensionEndB,
    required this.pensionSharePct,
    required this.contribTotal,
    required this.credited,
    required this.nonCredited,
    required this.refundNominal,
    required this.taxablePension,
    required this.potGains,
    required this.cGains,
    required this.yearsOverThreshold,
    required this.maxYearGain,
  });

  final double pensionEnd, pensionEndB, pensionSharePct, contribTotal;
  final double credited, nonCredited, refundNominal, taxablePension;
  final double potGains, cGains;
  final int yearsOverThreshold;

  /// 실현이익이 없으면 null(tax_lib 는 0 을 적는다).
  final double? maxYearGain;
}

/// 갈래 4개 + 입력 요약 — tax_lib `aftertax_full` 의 반환값(반올림 전).
class AfterTaxFull {
  const AfterTaxFull(this.branches, this.inputs);

  final Map<TaxLadderBranch, AfterTaxBranch> branches;

  /// 골든 사본에서 읽었으면 null(골든 블록의 `inputs` 는 반올림된 정수라 되돌리지 않는다).
  final AfterTaxFullInputs? inputs;

  /// 골든 블록(`aftertax_full_S7`)에서 읽는다 — 4자리 값을 그대로 층 값으로 쓴다.
  /// 🔵 실행 중 앱이 내는 «골든 참고 사다리»(§8 미결 18 확정 전)의 원천이다.
  factory AfterTaxFull.fromGoldenJson(Map<String, Object?> block) {
    double d(Object? v) => (v! as num).toDouble();
    return AfterTaxFull(<TaxLadderBranch, AfterTaxBranch>{
      for (final MapEntry<TaxLadderBranch, String> kv
          in kTaxLadderGoldenKeys.entries)
        if (block[kv.value] case final Map<String, Object?> b)
          kv.key: AfterTaxBranch(<String, AfterTaxPoint>{
            for (final String k in kAfterTaxPointKeys)
              k: AfterTaxPoint(
                d((b[k]! as Map<String, Object?>)['cagr_pct']),
                d((b[k]! as Map<String, Object?>)['end_mult']),
              ),
          }, d(b['refund_reinvested_krw'])),
    }, null);
  }

  /// tax_lib 출력과 같은 꼴(층 = 4자리 · 원 = 정수 · 연금 비중 = 2자리) — `assumption` 문장은 싣지 않는다.
  Map<String, Object?> toGoldenJson() => <String, Object?>{
    for (final MapEntry<TaxLadderBranch, AfterTaxBranch> kv in branches.entries)
      kTaxLadderGoldenKeys[kv.key]!: <String, Object?>{
        for (final String k in kAfterTaxPointKeys)
          k: <String, Object?>{
            'cagr_pct': pyRound(kv.value.points[k]!.cagrPct, 4),
            'end_mult': pyRound(kv.value.points[k]!.endMult, 4),
          },
        'refund_reinvested_krw': pyRoundInt(kv.value.refundReinvestedKrw),
      },
    if (inputs case final AfterTaxFullInputs i)
      'inputs': <String, Object?>{
        'pension_end_krw': pyRoundInt(i.pensionEnd),
        'pension_end_B_only_krw': pyRoundInt(i.pensionEndB),
        'pension_share_pct': pyRound(i.pensionSharePct, 2),
        'contrib_total_krw': pyRoundInt(i.contribTotal),
        'credited_krw': pyRoundInt(i.credited),
        'non_credited_krw': pyRoundInt(i.nonCredited),
        'refund_nominal_krw': pyRoundInt(i.refundNominal),
        'taxable_pension_krw': pyRoundInt(i.taxablePension),
        'pot_gains_krw': pyRoundInt(i.potGains),
        'c_gains_krw': pyRoundInt(i.cGains),
        'years_over_2000man': i.yearsOverThreshold,
        'max_year_gain_krw': i.maxYearGain == null
            ? 0
            : pyRoundInt(i.maxYearGain!),
      },
  };
}

/// tax_lib `realized_gains` — 매도 건별 이익(종목별 평균 단가) 중 **양의 건만**(손실은 통산하지 않는다) ·
/// 날짜별 합(카한) · 날짜 오름차순. [symbols] 를 주면 그 종목만.
List<(String, double)> realizedGains(
  List<TaxLedgerRow> ledger,
  String sleeve, {
  Set<String>? symbols,
}) {
  final Map<String, List<double>> basis = <String, List<double>>{};
  final List<(String, double)> gains = <(String, double)>[];
  for (final TaxLedgerRow r in ledger) {
    if (r.sleeve != sleeve || r.symbol == 'CASH') continue;
    if (symbols != null && !symbols.contains(r.symbol)) continue;
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
      if (gain > 0) gains.add((r.date, gain));
    }
  }
  return kahanGroupSum<String>(gains);
}

/// tax_lib `_apply_daily_tax` — 세금 낸 날 수익률에서 «세금 ÷ 전날 자산»을 빼고 첫 값에서 다시 쌓는다.
/// 세금 날짜가 세션이 아니면 그 뒤 첫 세션에 뺀다.
List<double> applyDailyTax(
  List<String> dates,
  List<double> e,
  List<(String, double)> taxes,
) {
  final List<double> r = <double>[0.0];
  for (int k = 1; k < e.length; k++) {
    r.add(e[k] / e[k - 1] - 1.0);
  }
  for (final (String d, double tv) in taxes) {
    final int k = _firstAtOrAfter(dates, d);
    if (k == dates.length) continue; // 마지막 세션 뒤 — tax_lib 도 건너뛴다
    if (k == 0) {
      // tax_lib `e.loc[:d].iloc[-2]` 가 IndexError 를 내는 자리 — 첫 세션에는 전날 자산이 없다.
      throw StateError('첫 세션($d)의 세금은 전날 자산이 없어 뺄 수 없다');
    }
    r[k] -= tv / e[k - 1];
  }
  final List<double> out = <double>[];
  double cp = 1.0;
  for (final double x in r) {
    cp *= 1.0 + x; // numpy `cumprod` — 1.0 × 첫 값은 정확하다
    out.add(cp * e.first);
  }
  return out;
}

/// tax_lib `_comprehensive_extra` — 연 실현이익 합(짝 합산)이 2,000만을 넘는 해에 초과분 × (한계세율 − 15.4%)
/// 를 그 해 마지막 이익일에 매긴다. [gains] = POT 이익 다음 C 이익을 날짜순으로 이은 것.
List<(String, double)> comprehensiveExtra(
  List<(String, double)> gains,
  double marginal,
) {
  final List<(String, double)> out = <(String, double)>[];
  for (final List<(String, double)> year in _byYear(gains)) {
    final double tot = npSum(<double>[for (final (_, double v) in year) v]);
    if (tot > kFinancialIncomeThreshold) {
      out.add((
        year.last.$1,
        (tot - kFinancialIncomeThreshold) * (marginal - kDividendTaxRate),
      ));
    }
  }
  return out;
}

/// tax_lib `aftertax_full` — 갈래 4개의 사다리와 입력 요약(반올림 전).
/// 🔴 외부 현금흐름이 0 이 아니면 [ArgumentError](무납입 전용 · §8 미결 18).
AfterTaxFull afterTaxFull(AfterTaxInputs inp) {
  final List<double>? flows = inp.externalFlows;
  if (flows != null && flows.any((double f) => f != 0)) {
    throw ArgumentError.value(
      'externalFlows',
      'externalFlows',
      '외부 현금흐름이 있는 실행에는 TWR 보정이 필요하다 — 무납입 전용(01 §8 미결 18)',
    );
  }
  if (inp.dates.length != inp.equity.length || inp.equity.length < 2) {
    throw ArgumentError('날짜와 자산의 길이가 같고 2 이상이어야 한다');
  }
  final List<String> dates = inp.dates;
  final List<double> e = inp.equity;
  final double yrs = _days(dates.first, dates.last) / 365.25;
  final double e0 = e.first;
  final List<(String, double)> gPot = realizedGains(inp.ledger, 'POT');
  final List<(String, double)> gC = realizedGains(
    inp.ledger,
    'C',
    symbols: const <String>{'IEI', 'IAU'},
  );
  // 연금 납입(원장 «C->B» 행) 연도별 합 — 세액공제 대상 / 미수령 원금.
  final List<(int, double)> byYear = kahanGroupSum<int>(<(int, double)>[
    for (final TaxLedgerRow r in inp.ledger)
      if (r.symbol == 'C->B') (int.parse(r.date.substring(0, 4)), r.gross),
  ]);
  final List<double> clipped = <double>[
    for (final (_, double c) in byYear)
      c > kPensionCreditCap ? kPensionCreditCap : c,
  ];
  final double credited = npSum(clipped);
  final double nonCredited = npSum(<double>[
    for (int k = 0; k < byYear.length; k++) byYear[k].$2 - clipped[k],
  ]);
  final double penEnd = inp.pensionEndB + inp.pensionEndParkC;
  final double taxable = penEnd - nonCredited > 0.0
      ? penEnd - nonCredited
      : 0.0;
  final double refundNominal = credited * kPensionCreditRate;
  final List<(String, double)> potThenC = _sortedStable(<(String, double)>[
    ...gPot,
    ...gC,
  ]);

  AfterTaxBranch ladder(double potRate, double? comprehensive) {
    final List<double> e1 = potRate > 0
        ? applyDailyTax(dates, e, <(String, double)>[
            for (final (String d, double g) in gPot) (d, g * potRate),
          ])
        : List<double>.of(e);
    List<double> e2 = applyDailyTax(dates, e1, <(String, double)>[
      for (final (String d, double g) in gC) (d, g * kDividendTaxRate),
    ]);
    if (comprehensive != null) {
      e2 = applyDailyTax(
        dates,
        e2,
        comprehensiveExtra(potThenC, comprehensive),
      );
    }
    // 환급 재투자 상한: 납입 다음 해 5월 말부터 이 경로의 수익률로 굴린다.
    double refundReinv = 0.0;
    for (final (int y, double c) in byYear) {
      final double amt =
          (c < kPensionCreditCap ? c : kPensionCreditCap) * kPensionCreditRate;
      final int k = _firstAtOrAfter(dates, '${y + 1}-05-31');
      refundReinv += k < dates.length ? amt * (e2.last / e2[k]) : amt;
    }
    final double end2 = e2.last;
    final Map<String, AfterTaxPoint> pts = <String, AfterTaxPoint>{
      'pretax': AfterTaxPoint(_cagr(e, yrs) * 100, e.last / e0),
      'after_pot': AfterTaxPoint(_cagr(e1, yrs) * 100, e1.last / e0),
      'after_pot_c': AfterTaxPoint(_cagr(e2, yrs) * 100, end2 / e0),
    };
    for (final (String name, double rate) in kPensionWithdrawalTaxes) {
      for (final (String suffix, double add) in <(String, double)>[
        ('', 0.0),
        ('_refund_nominal', refundNominal),
        ('_refund_reinvested', refundReinv),
      ]) {
        final double endV = end2 - taxable * rate + add;
        pts[name + suffix] = AfterTaxPoint(
          _pow(endV / e0, 1 / yrs) * 100 - 100,
          endV / e0,
        );
      }
    }
    return AfterTaxBranch(pts, refundReinv);
  }

  final List<(int, double)> yearlyGain = kahanGroupSum<int>(<(int, double)>[
    for (final (String d, double g) in potThenC)
      (int.parse(d.substring(0, 4)), g),
  ]);
  double? maxYear;
  for (final (_, double g) in yearlyGain) {
    if (maxYear == null || g > maxYear) maxYear = g;
  }
  return AfterTaxFull(
    <TaxLadderBranch, AfterTaxBranch>{
      for (final MapEntry<TaxLadderBranch, (double, double?)> kv
          in kTaxLadderBranchRates.entries)
        kv.key: ladder(kv.value.$1, kv.value.$2),
    },
    AfterTaxFullInputs(
      pensionEnd: penEnd,
      pensionEndB: inp.pensionEndB,
      pensionSharePct: penEnd / e.last * 100,
      contribTotal: npSum(<double>[for (final (_, double c) in byYear) c]),
      credited: credited,
      nonCredited: nonCredited,
      refundNominal: refundNominal,
      taxablePension: taxable,
      potGains: npSum(<double>[for (final (_, double g) in gPot) g]),
      cGains: npSum(<double>[for (final (_, double g) in gC) g]),
      yearsOverThreshold: yearlyGain
          .where(((int, double) t) => t.$2 > kFinancialIncomeThreshold)
          .length,
      maxYearGain: maxYear,
    ),
  );
}

// tax_lib `_cagr` — `float(e[-1] / e[0]) ** (1 / yrs) - 1`.
double _cagr(List<double> e, double yrs) => _pow(e.last / e.first, 1 / yrs) - 1;

// 파이썬 float `**` = C `pow`. dart:math `pow` 도 double 끼리면 C `pow` 다(플랫폼 libm — E6e 실측 ULP 0).
double _pow(double x, double y) => math.pow(x, y).toDouble();

int _days(String a, String b) =>
    DateTime.parse('${b}T00:00:00Z')
        .difference(DateTime.parse('${a}T00:00:00Z'))
        .inDays;

/// [d] 와 같거나 그 뒤인 첫 세션의 위치(없으면 `dates.length`).
int _firstAtOrAfter(List<String> dates, String d) {
  int lo = 0, hi = dates.length;
  while (lo < hi) {
    final int mid = (lo + hi) >> 1;
    if (dates[mid].compareTo(d) < 0) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// 날짜순 안정 정렬(같은 날은 들어온 순서 — POT 다음 C).
List<(String, double)> _sortedStable(List<(String, double)> rows) {
  final List<int> idx = List<int>.generate(rows.length, (int i) => i)
    ..sort((int a, int b) {
      final int c = rows[a].$1.compareTo(rows[b].$1);
      return c != 0 ? c : a - b;
    });
  return <(String, double)>[for (final int i in idx) rows[i]];
}

/// 연도별로 자른다(입력은 날짜순).
List<List<(String, double)>> _byYear(List<(String, double)> rows) {
  final List<List<(String, double)>> out = <List<(String, double)>>[];
  String? y;
  for (final (String, double) r in rows) {
    final String ry = r.$1.substring(0, 4);
    if (ry != y) {
      out.add(<(String, double)>[]);
      y = ry;
    }
    out.last.add(r);
  }
  return out;
}
