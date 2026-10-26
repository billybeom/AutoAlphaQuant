// E6b 재현 국면 — 참조 엔진(백테스트6) `regime.build_raw_indicators` 의 데이터 정렬(발표 지연 · as-of)만 여기서
// 하고, 계산은 앱 코드(`lib/src/signals/` — 정규화 · 방향 · 추세성 · FSM · KOSDAQ 추세 점수)를 그대로 부른다.
//
// 🔴 달력 = 전체 US 세션(1985-01-02 ~) — 확장 백분위와 FSM 이 1985 년부터 누적된다(이식 지도 §2).
// 🔴 발표 지연(`PUBLISH_LAG` — 달력일): ofr_fsi 1 · nfci 7 · cfnai_ma3 55 · yield_curve 1 · sahm 40.
// 🔵 E8b1(설계 13 §8 R24 B2) — 발표 지연 표(`kPublishLagDays`)와 `alignWithLag` 는 lib(`src/data/pit_align.dart`)로
//    옮겼다. 이 하네스가 lib 를 부르므로 26년 재현 비트 일치가 실전 PIT 정렬의 회귀 시험이다.

import 'package:core_engine/core_engine.dart';

import 'replay_market.dart';

List<double?> _nullable(List<double> v) => <double?>[
  for (final double x in v) x.isNaN ? null : x,
];

/// 동결 번들 CSV → 국면 원천 한 벌(참조 엔진 `load_all` 의 열 이름 그대로).
RegimeSources regimeSourcesFromBundle(ReplayRaw r) {
  final Ohlcv us = Ohlcv.fromFrame(r['gspc']);
  DatedSeries col(String file, String column) => frameColumn(r[file], column);
  return RegimeSources(
    usDates: us.dates,
    usClose: _nullable(us.close),
    usHigh: _nullable(us.high),
    usLow: _nullable(us.low),
    usVolume: _nullable(us.volume),
    spyAdjClose: col('spy', 'Adj Close'),
    rspAdjClose: col('rsp', 'Adj Close'),
    vix: col('vix', 'Close'),
    vix3m: col('vix3m', 'Close'),
    ofrFsi: col('ofr_fsi', 'OFR FSI'),
    nfci: col('nfci', 'NFCI'),
    cfnaiMa3: col('cfnai_ma3', 'CFNAIMA3'),
    t10y3m: col('t10y3m', 'T10Y3M'),
    sahm: col('sahm', 'SAHMREALTIME'),
  );
}

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
    // 🔵 E8b2(설계 13 §8 R24 B2) — 원지표 조립 → 정규화 → 방향 → 추세성 → FSM 은 lib(`src/data/regime_inputs.dart`)다.
    final RegimeComputation comp = computeRegime(regimeSourcesFromBundle(r));
    final List<String> cal = comp.calendar;

    final Ohlcv kq = Ohlcv.fromFrame(r['kq11']);
    final List<double?> kClose = _nullable(kq.close);
    final Map<String, List<double?>> kParts = normalizeIndicators(
      trendIndicators(kClose),
    );
    return ReplayRegime._(
      calendar: cal,
      raw: comp.raw,
      normalized: comp.normalized,
      direction: comp.direction,
      trendinessPartScores: comp.trendinessParts,
      trendiness: comp.trendiness,
      fsm: comp.fsm,
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
