// 🆕 계약 v1.28(01 §37 · K200) — M9 `S04` 읽기 행 코드. 엔진 `AllocationViewRowCodes`(core `ops/allocation_view.dart`) 글자 1:1 ·
// 🔴 타입 이름 ≠ 엔진(`ambiguous_import` 회피 K80). 🔴 화면 미참조(시험 · 열 대조 · Key = 순번) — 코드로 분기·색을 고르지 않는다.

/// S04 읽기 행 코드(도메인 `allocation_row` · 차례 = 엔진 묶음 차례).
abstract final class AllocationRowCodes {
  /// 슬리브 B 코어 밴드.
  static const String bandCoreB = 'BAND_CORE_B';

  /// 슬리브 C 안 리밸런싱 문턱.
  static const String bandSleeveC = 'BAND_SLEEVE_C';

  /// 새틀라이트 밴드(P0S = 해당 없음).
  static const String bandSatellite = 'BAND_SATELLITE';

  /// 낙폭 단계(서킷브레이커).
  static const String riskDrawdown = 'RISK_DRAWDOWN';

  /// 하루 손실 한도(SAF-403).
  static const String riskDailyLoss = 'RISK_DAILY_LOSS';

  /// 위험자산 비중 상한(SAF-301).
  static const String riskExposure = 'RISK_EXPOSURE';

  /// 방어 비중 하한(SAF-302 · 경고).
  static const String riskDefensiveFloor = 'RISK_DEFENSIVE_FLOOR';

  /// 주문 한도(SAF-401 · 402).
  static const String riskOrderCaps = 'RISK_ORDER_CAPS';

  /// 금 상한 — 슬리브 C 안 하드 캡.
  static const String goldSleeveCCap = 'GOLD_SLEEVE_C_CAP';

  /// 금 총비중 감시선(SAF-308 · 감시선 — 하드 캡 아님).
  static const String goldTotalMonitor = 'GOLD_TOTAL_MONITOR';

  /// 차례 = 엔진 묶음 차례(밴드 3 · 한도 5 · 금 2).
  static const List<String> ordered = <String>[
    bandCoreB,
    bandSleeveC,
    bandSatellite,
    riskDrawdown,
    riskDailyLoss,
    riskExposure,
    riskDefensiveFloor,
    riskOrderCaps,
    goldSleeveCCap,
    goldTotalMonitor,
  ];

  static const Set<String> values = <String>{
    bandCoreB,
    bandSleeveC,
    bandSatellite,
    riskDrawdown,
    riskDailyLoss,
    riskExposure,
    riskDefensiveFloor,
    riskOrderCaps,
    goldSleeveCCap,
    goldTotalMonitor,
  };
}
