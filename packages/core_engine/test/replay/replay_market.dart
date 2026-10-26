// E6a 재현 시장 번들 — 참조 엔진(백테스트6) `engine/data.py` · `market.py::build` · `apply_p0_market` ·
// `Backtest._prep` 이 P0S 에서 읽는 것만 같은 식·같은 연산 순서로 다시 만든다.
//
// 🔴 정본은 참조 엔진 코드다(설계 13 §2 E6 · 이식 지도 §1). 식을 «더 맞게» 고치지 않는다 — 골든 재현이 목적.
//    예: 한국 세션의 국내상장 미국 ETF 값 = «그날보다 엄격히 앞선 미국 종가»(룩어헤드 방지 · `_to_kr_calendar`),
//    금(IAU)은 US 세션에 정확히 맞춘 뒤 앞으로 채움(as-of 아님), 세션 = 데이터 날짜(동결 캘린더 아님 · 설계 13 §8 R15).
// 🔴 pandas 의 ffill·as-of·cumprod·나눗셈 순서를 그대로 따른다 — 정답지(`fixtures/market_parity.json`)가 비트로 본다.
// 🔵 시험 전용 — 합성 시세는 백테스트 입력이다. 실전 시세는 KIS 에서 온다(M1-7).

import 'package:core_engine/core_engine.dart'
    show DatedSeries, daysBetween, toKrCalendar, unionSorted;

import 'replay_csv.dart';

// 🔵 E8b1(설계 13 §8 R24 B2) — `DatedSeries` · 날짜 도우미 · `toKrCalendar` 는 lib(`src/data/`)로 옮겼다. 하네스는 그것을
//    부르고 그대로 내보낸다(이 파일을 import 하는 시험이 바뀌지 않게) — 26년 재현 비트 일치가 lib 의 회귀 시험이다.
export 'package:core_engine/core_engine.dart'
    show DatedSeries, daysBetween, minusOneDay, toKrCalendar, unionSorted;

/// 한 CSV 열을 날짜 시리즈로(`_num` — 못 읽은 칸은 NaN).
DatedSeries frameColumn(ReplayFrame f, String column) =>
    DatedSeries(f.index, f.column(column));

/// 원천 CSV 24개 — 참조 엔진 `load_all`.
class ReplayRaw {
  ReplayRaw._(this._frames);

  /// 번들 전부를 읽는다.
  factory ReplayRaw.load() => ReplayRaw._(<String, ReplayFrame>{});

  final Map<String, ReplayFrame> _frames;

  /// [name] 을 읽는다(한 번만).
  ReplayFrame operator [](String name) =>
      _frames.putIfAbsent(name, () => loadReplayCsv(name));
}

/// `usdkrw` — FRED 우선, FRED 가 없는 날만 FDR(`combine_first`) · 결측 제거.
DatedSeries usdkrw(ReplayRaw raw) {
  final DatedSeries fred = frameColumn(raw['usdkrw_fred'], 'DEXKOUS').dropNa();
  final DatedSeries fdr = frameColumn(raw['usdkrw_fdr'], 'Close').dropNa();
  final List<String> idx = unionSorted(fred.dates, fdr.dates);
  final List<double> out = <double>[
    for (final String d in idx) fred.at(d) ?? fdr.at(d)!,
  ];
  return DatedSeries(idx, out).dropNa();
}

/// OHLCV 표(종가 결측 행은 버림) — `us_index` · `kosdaq`.
class Ohlcv {
  Ohlcv._(this.dates, this.open, this.high, this.low, this.close, this.volume);

  /// [frame] 에서 만든다.
  factory Ohlcv.fromFrame(ReplayFrame frame) {
    final List<double> c = frame.column('Close');
    final List<int> keep = <int>[
      for (int i = 0; i < c.length; i++)
        if (!c[i].isNaN) i,
    ];
    List<double> pick(String col) {
      final List<double> v = frame.columns.containsKey(col)
          ? frame.column(col)
          : List<double>.filled(c.length, double.nan);
      return <double>[for (final int i in keep) v[i]];
    }

    return Ohlcv._(
      <String>[for (final int i in keep) frame.index[i]],
      pick('Open'),
      pick('High'),
      pick('Low'),
      pick('Close'),
      pick('Volume'),
    );
  }

  /// 날짜(= 세션).
  final List<String> dates;

  /// 시가 · 고가 · 저가 · 종가 · 거래량.
  final List<double> open, high, low, close, volume;

  /// 종가 시리즈.
  DatedSeries get closeSeries => DatedSeries(dates, close);
}

/// `to_krw` — 달러 시리즈 × 그날 이하 마지막 환율 → 결측 제거 → 첫 값 = 100.
DatedSeries toKrwIndex(DatedSeries usd, DatedSeries fx) {
  final DatedSeries f = fx.asOf(usd.dates);
  final DatedSeries out = DatedSeries(usd.dates, <double>[
    for (int i = 0; i < usd.length; i++) usd.values[i] * f.values[i],
  ]).dropNa();
  final double first = out.values.first;
  return DatedSeries(out.dates, <double>[
    for (final double v in out.values) v / first * 100.0,
  ]);
}

/// 슬리브 B 바스켓(P0S) 원화 지수 — 133690 = QQQ 총수익을 ^NDX 로 소급 연결 · 411060 = 금 선물.
Map<String, DatedSeries> sleeveBAssets(ReplayRaw raw, DatedSeries fx) {
  final DatedSeries qqq = frameColumn(raw['qqq'], 'Adj Close').dropNa();
  final DatedSeries ndx = frameColumn(raw['ndx'], 'Close').dropNa();
  final String q0 = qqq.dates.first;
  final double ndxAtQ0 = ndx.at(q0) ?? ndx.values[ndx.lastAtOrBefore(q0)];
  final double scale = qqq.values.first / ndxAtQ0;
  final List<String> d = <String>[];
  final List<double> v = <double>[];
  for (int i = 0; i < ndx.length && ndx.dates[i].compareTo(q0) < 0; i++) {
    d.add(ndx.dates[i]);
    v.add(ndx.values[i] * scale);
  }
  d.addAll(qqq.dates);
  v.addAll(qqq.values);
  final DatedSeries nasdaq = DatedSeries(d, v);
  final DatedSeries gold = frameColumn(raw['gold_fut'], 'Close').dropNa();
  return <String, DatedSeries>{
    '133690': toKrwIndex(nasdaq, fx),
    '411060': toKrwIndex(gold, fx),
  };
}

/// `_rate_to_index` — 연율 % → 실제 경과일 일할 복리 지수(첫 값 = 100). 🔴 bfill 금지 · 선행 결측 = 이자 0.
DatedSeries rateToIndex(
  DatedSeries ratePct,
  List<String> calendar, {
  int daysPerYear = 365,
}) {
  final DatedSeries r = ratePct.asOf(calendar);
  final List<double> growth = <double>[];
  double g = 1.0;
  for (int t = 0; t < calendar.length; t++) {
    final double rate = r.values[t] / 100.0;
    final double dt = t == 0
        ? 0.0
        : daysBetween(
            calendar[t - 1],
            calendar[t],
          ).clamp(0, 1 << 30).toDouble();
    final double term = 1.0 + (rate.isNaN ? 0.0 : rate) * dt / daysPerYear;
    g = t == 0 ? term : g * term;
    growth.add(g);
  }
  final double g0 = growth.first;
  return DatedSeries(calendar, <double>[
    for (final double x in growth) x / g0 * 100.0,
  ]);
}

/// `ust10_index` — DGS3MO + T10Y3M 으로 10년 수익률 복원 → 불변만기 총수익 근사(D 8.4 · C 85 · 첫 값 = 100).
DatedSeries ust10Index(ReplayRaw raw, List<String> calendar) {
  final DatedSeries t3 = frameColumn(raw['dgs3mo'], 'DGS3MO').dropNa();
  final DatedSeries sp = frameColumn(raw['t10y3m'], 'T10Y3M').dropNa();
  final Set<String> spDates = sp.dates.toSet();
  final List<String> both = <String>[
    for (final String d in t3.dates)
      if (spDates.contains(d)) d,
  ];
  final DatedSeries y0 = DatedSeries(both, <double>[
    for (final String d in both) (t3.at(d)! + sp.at(d)!),
  ]).dropNa();
  final DatedSeries yRaw = DatedSeries(y0.dates, <double>[
    for (final double v in y0.values) v / 100.0,
  ]);
  final List<double> y = yRaw.asOf(calendar).values;
  const double dur = 8.4;
  const double conv = 85.0;
  final List<double> idx = <double>[];
  double acc = 1.0;
  for (int t = 0; t < y.length; t++) {
    final double dy = t == 0 ? 0.0 : (y[t] - y[t - 1]);
    final double dyFilled = dy.isNaN ? 0.0 : dy;
    final double prev = t == 0 ? y[0] : (y[t - 1].isNaN ? y[0] : y[t - 1]);
    final double ret =
        prev / 252.0 - dur * dyFilled + 0.5 * conv * (dyFilled * dyFilled);
    acc = t == 0 ? (1.0 + ret) : acc * (1.0 + ret);
    idx.add(acc);
  }
  final double i0 = idx.first;
  return DatedSeries(calendar, <double>[
    for (final double x in idx) x / i0 * 100.0,
  ]);
}

/// P0S 가 읽는 시장 번들 + `Backtest._prep` 의 정렬.
class ReplayMarket {
  ReplayMarket._({
    required this.fx,
    required this.usIndex,
    required this.kosdaq,
    required this.sleeveBUs,
    required this.sleeveBKr,
    required this.krwCash,
    required this.ust10,
    required this.iau,
    required this.us,
    required this.kr,
    required this.allDays,
    required this.usMonthEnds,
    required this.krMonthEnds,
    required this.krTail,
    required this.px,
    required this.bMonthly,
  });

  /// 번들을 만든다 — 기간 = 정답지(2000-01-03 ~ 2026-08-14) · 월 마지막 [executionDays] 세션.
  factory ReplayMarket.build({
    String start = '2000-01-03',
    String end = '2026-08-14',
    int executionDays = 3,
  }) {
    final ReplayRaw raw = ReplayRaw.load();
    final DatedSeries fx = usdkrw(raw);
    final Ohlcv usIndex = Ohlcv.fromFrame(raw['gspc']);
    final Ohlcv kosdaq = Ohlcv.fromFrame(raw['kq11']);
    final List<String> usSessions = usIndex.dates;
    final List<String> krSessions = kosdaq.dates;
    final Map<String, DatedSeries> bUs = sleeveBAssets(raw, fx);
    final Map<String, DatedSeries> bKr = <String, DatedSeries>{
      for (final MapEntry<String, DatedSeries> e in bUs.entries)
        e.key: toKrCalendar(e.value, krSessions),
    };
    final DatedSeries krwCash = rateToIndex(
      frameColumn(raw['kr_3m'], 'IR3TIB01KRM156N').dropNa(),
      krSessions,
    );
    final DatedSeries ust10 = ust10Index(raw, usSessions);
    final DatedSeries iau = frameColumn(
      raw['gold_fut'],
      'Close',
    ).dropNa().reindexFfill(usSessions);

    bool inRange(String d) => d.compareTo(start) >= 0 && d.compareTo(end) <= 0;
    final List<String> us = usSessions.where(inRange).toList();
    final List<String> kr = krSessions.where(inRange).toList();
    final List<String> allDays = unionSorted(us, kr);

    Set<String> monthEnds(List<String> sessions) {
      final Map<String, String> last = <String, String>{};
      for (final String d in sessions) {
        last[d.substring(0, 7)] = d; // 오름차순 → 달마다 마지막이 남는다(= groupby.max)
      }
      return last.values.toSet();
    }

    final Map<String, (int, int)> krTail = <String, (int, int)>{};
    final Map<String, List<String>> byMonth = <String, List<String>>{};
    for (final String d in kr) {
      byMonth.putIfAbsent(d.substring(0, 7), () => <String>[]).add(d);
    }
    for (final List<String> days in byMonth.values) {
      final List<String> tail = days.length > executionDays
          ? days.sublist(days.length - executionDays)
          : days;
      for (int i = 0; i < tail.length; i++) {
        krTail[tail[i]] = (i, tail.length);
      }
    }

    DatedSeries align(DatedSeries s) => s.dropNa().asOf(allDays);
    final Map<String, DatedSeries> px = <String, DatedSeries>{
      'fx': align(fx),
      'A': align(kosdaq.closeSeries),
      'PARK': align(krwCash),
      'CKRW': align(krwCash),
      'IEI': align(ust10),
      'IAU': align(iau),
      '133690': align(bKr['133690']!),
      '411060': align(bKr['411060']!),
    };

    final Map<String, DatedSeries> bMonthly = <String, DatedSeries>{};
    for (final MapEntry<String, DatedSeries> e in bKr.entries) {
      final DatedSeries s = e.value.dropNa();
      final Map<String, double> last = <String, double>{};
      for (int i = 0; i < s.length; i++) {
        last[s.dates[i].substring(0, 7)] = s.values[i];
      }
      final List<String> keys = last.keys.toList()..sort();
      bMonthly[e.key] = DatedSeries(keys, <double>[
        for (final String k in keys) last[k]!,
      ]);
    }

    return ReplayMarket._(
      fx: fx,
      usIndex: usIndex,
      kosdaq: kosdaq,
      sleeveBUs: bUs,
      sleeveBKr: bKr,
      krwCash: krwCash,
      ust10: ust10,
      iau: iau,
      us: us,
      kr: kr,
      allDays: allDays,
      usMonthEnds: monthEnds(us),
      krMonthEnds: monthEnds(kr),
      krTail: krTail,
      px: px,
      bMonthly: bMonthly,
    );
  }

  /// 원/달러.
  final DatedSeries fx;

  /// 미국 지수(^GSPC) · KOSDAQ.
  final Ohlcv usIndex, kosdaq;

  /// 슬리브 B 원화 지수 — 미국 날짜 · 한국 세션.
  final Map<String, DatedSeries> sleeveBUs, sleeveBKr;

  /// 원화 현금 지수(파킹·C 원화·POT 현금 공용) · UST10 · 금(USD).
  final DatedSeries krwCash, ust10, iau;

  /// 기간 안 US · KR 세션과 합집합.
  final List<String> us, kr, allDays;

  /// 기간 안 월말(달마다 마지막 세션).
  final Set<String> usMonthEnds, krMonthEnds;

  /// 한국 세션 → (그 달 끝 N 세션 중 몇 번째, N).
  final Map<String, (int, int)> krTail;

  /// 가격 패널(합집합 날짜 · 그날 이하 마지막 값).
  final Map<String, DatedSeries> px;

  /// 슬리브 B 월봉(키 = YYYY-MM · 잘라내지 않은 전체 · 그달 마지막 값).
  final Map<String, DatedSeries> bMonthly;
}
