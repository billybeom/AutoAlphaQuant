// 국면 원천의 저장 이름 — `market_series.series_id` · `daily_prices`(market, symbol)(설계 13 §8 R26 H1 · E8c).
//
// 🔴 `series_id` 는 «논리 계열»이다 — 원천이 바뀌어도(시드 → KIS · 장애 때 FRED 폴백) 같은 이름에 쌓이고, 행마다
//    `source` 가 어디서 왔는지를 남긴다(R23 D7). FRED 가 싣는 계열은 FRED 이름을 쓴다(DDL 주석 예시와 같음).
// 🔴 OHLCV 가 있는 것(^GSPC · KOSDAQ 지수)은 `daily_prices` · 종가만 있는 것은 `market_series`(R23 D8).

import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;

/// `market_series.series_id` — 국면 입력(P0S) 9계열.
abstract final class MarketSeriesIds {
  /// SPY 수정종가(BREADTH `rsp_spy_ratio` · 원천 = KIS 해외 시세 E8d).
  static const String spyAdjClose = 'SPY_ADJ';

  /// RSP 수정종가(같은 지표).
  static const String rspAdjClose = 'RSP_ADJ';

  /// ^VIX 종가(VOLATILITY · KIS E8d — 장애 폴백 FRED `VIXCLS`).
  static const String vix = 'VIXCLS';

  /// ^VIX3M 종가(VOLATILITY `vix_term` · KIS E8d — 장애 폴백 FRED `VXVCLS`).
  static const String vix3m = 'VXVCLS';

  /// OFR 금융스트레스지수(CREDIT · FR-110).
  static const String ofrFsi = 'OFR_FSI';

  /// NFCI(CREDIT · 주간).
  static const String nfci = 'NFCI';

  /// CFNAIMA3(MACRO · 월간).
  static const String cfnaiMa3 = 'CFNAIMA3';

  /// T10Y3M(MACRO `yield_curve` · 일간).
  static const String t10y3m = 'T10Y3M';

  /// SAHMREALTIME(MACRO · 월간).
  static const String sahm = 'SAHMREALTIME';
}

/// `daily_prices` 의 지수 행.
abstract final class MarketSymbols {
  /// S&P 500(국면 달력 · TREND · `dist_days` · 추세성) — market = US.
  static const String gspc = '^GSPC';

  /// KOSDAQ 종합지수(`trend_score_kr` 진입 게이트 ③) — market = KR.
  static const String kosdaq = 'KQ11';
}

/// 원천 하나 — 수집기가 부르는 원천 계열 이름(FRED `series_id` · OFR 칸 이름).
class SeriesFeed {
  const SeriesFeed(this.source, this.code);

  final MarketDataSource source;
  final String code;
}

/// 계열 하나의 원천 순서(FR-111 «정의된 폴백 순서») — 첫째가 평소 원천.
class SeriesPlan {
  const SeriesPlan(this.seriesId, this.feeds);

  final String seriesId;
  final List<SeriesFeed> feeds;

  /// 평소 원천.
  MarketDataSource get primary => feeds.first.source;
}

/// 9계열의 원천 순서 — KIS 가 평소 원천인 4계열은 E8d 가 받는다(이 패키지의 수집기는 FRED·OFR 이 평소인 것만).
/// 🔵 `FRED_CSV` 는 키 없는 같은 계열(`fredgraph.csv`) — FRED 클라이언트가 JSON 실패 때 스스로 옮긴다.
const List<SeriesPlan> kRegimeSeriesPlans = <SeriesPlan>[
  SeriesPlan(MarketSeriesIds.spyAdjClose, <SeriesFeed>[
    SeriesFeed(MarketDataSource.kis, 'SPY'),
  ]),
  SeriesPlan(MarketSeriesIds.rspAdjClose, <SeriesFeed>[
    SeriesFeed(MarketDataSource.kis, 'RSP'),
  ]),
  SeriesPlan(MarketSeriesIds.vix, <SeriesFeed>[
    SeriesFeed(MarketDataSource.kis, 'VIX'),
    SeriesFeed(MarketDataSource.fred, 'VIXCLS'),
  ]),
  SeriesPlan(MarketSeriesIds.vix3m, <SeriesFeed>[
    SeriesFeed(MarketDataSource.kis, 'VIX3M'),
    SeriesFeed(MarketDataSource.fred, 'VXVCLS'),
  ]),
  SeriesPlan(MarketSeriesIds.ofrFsi, <SeriesFeed>[
    SeriesFeed(MarketDataSource.ofr, 'OFR FSI'),
  ]),
  SeriesPlan(MarketSeriesIds.nfci, <SeriesFeed>[
    SeriesFeed(MarketDataSource.fred, 'NFCI'),
  ]),
  SeriesPlan(MarketSeriesIds.cfnaiMa3, <SeriesFeed>[
    SeriesFeed(MarketDataSource.fred, 'CFNAIMA3'),
  ]),
  SeriesPlan(MarketSeriesIds.t10y3m, <SeriesFeed>[
    SeriesFeed(MarketDataSource.fred, 'T10Y3M'),
  ]),
  SeriesPlan(MarketSeriesIds.sahm, <SeriesFeed>[
    SeriesFeed(MarketDataSource.fred, 'SAHMREALTIME'),
  ]),
];
