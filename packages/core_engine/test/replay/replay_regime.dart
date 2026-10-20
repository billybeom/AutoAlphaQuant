// E6b 재현 국면 — 참조 엔진(백테스트6) `regime.build_raw_indicators` 의 데이터 정렬(발표 지연 · as-of)만 여기서
// 하고, 계산은 앱 코드(`lib/src/signals/` — 정규화 · 방향 · 추세성 · FSM · KOSDAQ 추세 점수)를 그대로 부른다.
//
// 🔴 달력 = 전체 US 세션(1985-01-02 ~) — 확장 백분위와 FSM 이 1985 년부터 누적된다(이식 지도 §2).
// 🔴 발표 지연(`PUBLISH_LAG` — 달력일): ofr_fsi 1 · nfci 7 · cfnai_ma3 55 · yield_curve 1 · sahm 40.
// 🔵 시험 전용 — 실전의 PIT 정렬은 데이터 수집(M1-7) 몫이다.

import 'package:core_engine/core_engine.dart';

import 'replay_market.dart';

/// 참조 엔진 `PUBLISH_LAG`.
const Map<String, int> kPublishLagDays = <String, int>{
  'nfci': 7,
  'ofr_fsi': 1,
  'yield_curve': 1,
  'cfnai_ma3': 55,
  'sahm': 40,
};

String _plusDays(String d, int n) =>
    DateTime.parse('${d}T00:00:00Z')
        .add(Duration(days: n))
        .toIso8601String()
        .substring(0, 10);

/// 참조 엔진 `_align(s, cal, lag)` — 결측 제거 → 날짜 + 지연 → 중복은 뒤쪽 → as-of 로 달력에.
DatedSeries alignWithLag(DatedSeries s, List<String> calendar, {int lag = 0}) {
  final DatedSeries x = s.dropNa();
  final Map<String, double> byDate = <String, double>{};
  for (int i = 0; i < x.length; i++) {
    byDate[lag == 0 ? x.dates[i] : _plusDays(x.dates[i], lag)] = x.values[i];
  }
  final List<String> dates = byDate.keys.toList()..sort();
  return DatedSeries(dates, <double>[
    for (final String d in dates) byDate[d]!,
  ]).asOf(calendar);
}

List<double?> _nullable(List<double> v) => <double?>[
  for (final double x in v) x.isNaN ? null : x,
];

/// 국면 재현 결과.
class ReplayRegime {
  ReplayRegime._({
    required this.calendar,
    required this.raw,
    required this.normalized,
    required this.direction,
    required this.trendinessPartScores,
    required this.trendiness,
    required this.fsm,
    required this.kosdaqCalendar,
    required this.tskrParts,
    required this.tskr,
  });

  /// 만든다.
  factory ReplayRegime.build() {
    final ReplayRaw r = ReplayRaw.load();
    final Ohlcv us = Ohlcv.fromFrame(r['gspc']);
    final List<String> cal = us.dates;
    final List<double?> close = _nullable(us.close);

    final Map<String, List<double?>> raw = <String, List<double?>>{
      ...trendIndicators(close),
      'dist_days': distributionDays(close, _nullable(us.volume)),
    };

    final DatedSeries spy = frameColumn(r['spy'], 'Adj Close').dropNa();
    final DatedSeries rsp = frameColumn(r['rsp'], 'Adj Close').dropNa();
    final DatedSeries ratio = DatedSeries(rsp.dates, <double>[
      for (int i = 0; i < rsp.length; i++)
        rsp.values[i] / (spy.at(rsp.dates[i]) ?? double.nan),
    ]).dropNa();
    final List<double?> ratioSma = sma(_nullable(ratio.values), 50);
    raw['rsp_spy_ratio'] = _nullable(
      alignWithLag(
        DatedSeries(ratio.dates, <double>[
          for (int i = 0; i < ratio.length; i++)
            ratio.values[i] / (ratioSma[i] ?? double.nan) - 1.0,
        ]),
        cal,
      ).values,
    );

    final DatedSeries vix = frameColumn(r['vix'], 'Close').dropNa();
    raw['vix_level'] = _nullable(alignWithLag(vix, cal).values);
    final DatedSeries v3 = frameColumn(r['vix3m'], 'Close').dropNa();
    raw['vix_term'] = _nullable(
      alignWithLag(
        DatedSeries(v3.dates, <double>[
          for (int i = 0; i < v3.length; i++)
            (vix.at(v3.dates[i]) ?? double.nan) / v3.values[i],
        ]).dropNa(),
        cal,
      ).values,
    );

    DatedSeries col(String file, String column) => frameColumn(r[file], column);
    raw['ofr_fsi'] = _nullable(
      alignWithLag(
        col('ofr_fsi', 'OFR FSI'),
        cal,
        lag: kPublishLagDays['ofr_fsi']!,
      ).values,
    );
    raw['nfci'] = _nullable(
      alignWithLag(
        col('nfci', 'NFCI'),
        cal,
        lag: kPublishLagDays['nfci']!,
      ).values,
    );
    raw['cfnai_ma3'] = _nullable(
      alignWithLag(
        col('cfnai_ma3', 'CFNAIMA3'),
        cal,
        lag: kPublishLagDays['cfnai_ma3']!,
      ).values,
    );
    raw['yield_curve'] = _nullable(
      alignWithLag(
        col('t10y3m', 'T10Y3M'),
        cal,
        lag: kPublishLagDays['yield_curve']!,
      ).values,
    );
    raw['sahm'] = _nullable(
      alignWithLag(
        col('sahm', 'SAHMREALTIME'),
        cal,
        lag: kPublishLagDays['sahm']!,
      ).values,
    );

    final Map<String, List<double?>> norm = normalizeIndicators(raw);
    final List<DirectionScore> dir = directionScores(norm);
    final Map<String, List<double?>> tParts = trendinessParts(
      high: _nullable(us.high),
      low: _nullable(us.low),
      close: close,
    );
    final List<double?> trend = meanOfAvailable(<List<double?>>[
      tParts['chop']!,
      tParts['adx']!,
      tParts['bbw']!,
    ], minValid: 1);
    final List<RegimeDay> fsm = runRegimeFsm(
      <double?>[for (final DirectionScore d in dir) d.direction],
      trend,
      directionConfig: DirectionHysteresis(
        up: 60,
        down: 40,
        confirmBars: 3,
        minHoldBars: 10,
      ),
      trendConfig: TrendHysteresis(trendIn: 35, trendOut: 45, confirmBars: 3),
    );

    final Ohlcv kq = Ohlcv.fromFrame(r['kq11']);
    final List<double?> kClose = _nullable(kq.close);
    final Map<String, List<double?>> kParts = normalizeIndicators(
      trendIndicators(kClose),
    );
    return ReplayRegime._(
      calendar: cal,
      raw: raw,
      normalized: norm,
      direction: dir,
      trendinessPartScores: tParts,
      trendiness: trend,
      fsm: fsm,
      kosdaqCalendar: kq.dates,
      tskrParts: kParts,
      tskr: trendScoreKr(kClose),
    );
  }

  /// US 세션(1985~).
  final List<String> calendar;

  /// 원지표 13개.
  final Map<String, List<double?>> raw;

  /// 정규화 13개.
  final Map<String, List<double?>> normalized;

  /// 날마다 방향 스코어.
  final List<DirectionScore> direction;

  /// 추세성 세 부분 · 추세성.
  final Map<String, List<double?>> trendinessPartScores;

  /// 추세성 스코어.
  final List<double?> trendiness;

  /// FSM(03 방식 — R9).
  final List<RegimeDay> fsm;

  /// KOSDAQ 달력(1996-07-01~).
  final List<String> kosdaqCalendar;

  /// KOSDAQ 추세 4지표(정규화) · 추세 점수.
  final Map<String, List<double?>> tskrParts;

  /// KOSDAQ 추세 점수.
  final List<double?> tskr;
}
