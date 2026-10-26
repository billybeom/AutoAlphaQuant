// 🆕 계약 v1.14(E8a · 설계 13 §8 R23 D7 · R24 B4 · R25 G3) — 시세·지표 데이터의 출처.
//
// 🔴 이 값은 «어디서 받았나»의 기록이다 — `market_series.source` · `daily_prices.source` · `fetch_log.source`
//    (배치 G) 의 CHECK 와 C-15 가 맞댄다. 화면은 이 값을 표시·분기하지 않는다(엔진·저장소 전용).
// 🔴 `AsOfSource`(LOCAL_SQLITE · SUPABASE_MIRROR · ARCHIVE)는 «저장 위치»이고 이것은 «원천»이다 — 다른 축.

import 'package:json_annotation/json_annotation.dart';

/// 시세·지표의 원천(R23 D1 «세 소스» + 시드 · 폴백 · 수기).
enum MarketDataSource {
  /// 동결 번들 시드(R23 D9 — 2026-08-14 기준일까지).
  @JsonValue('SEED_BUNDLE')
  seedBundle('SEED_BUNDLE'),

  /// 한국투자증권 Open API(국내 일봉 · 국내 지수 · 휴장일 · 해외 시세 — R23 D2).
  @JsonValue('KIS')
  kis('KIS'),

  /// FRED API(JSON).
  @JsonValue('FRED')
  fred('FRED'),

  /// FRED 키 없는 CSV 경로(`fredgraph.csv` — 폴백 · FR-111).
  @JsonValue('FRED_CSV')
  fredCsv('FRED_CSV'),

  /// OFR 금융스트레스지수 사이트(FR-110).
  @JsonValue('OFR')
  ofr('OFR'),

  /// 사람이 넣은 값(정정 · 장애 대체 — 근거는 `fetch_log.detail`).
  @JsonValue('MANUAL')
  manual('MANUAL');

  const MarketDataSource(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
