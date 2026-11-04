// M3-1 What-if 설정 — 설계 13 §8 R18 D-2 · D-5 · D-7 · D-16(발주자 2026-10-21 · 추천안).
//
// 🔴 기본값은 문서에 적힌 값이다 — 02 §4 에 `what_if.*` · `pension.*` 키가 생길 때까지(06 개정 창) 이 객체가
//    그 자리를 맡는다. 값은 화면에 내려보내지 않는다(범위·만료는 엔진 문장으로만 — 06 M3-1 · M3-2 ⓐ).
// 🔴 월 납입 **운영값**(M3-6)은 여기 없다 — 전략 `config_hash` 밖의 운영 파라미터다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show SleeveId;

import '../portfolio/month_end_plan.dart';
import '../signals/regime_states.dart';
import '../signals/sleeve_b_tranche.dart';

/// What-if 미리보기 설정.
class WhatIfConfig {
  WhatIfConfig({
    required this.planTtl,
    required this.pensionAnnualLimit,
    required this.taxCreditBand,
    required this.depositMin,
    required this.depositMax,
    Map<SleeveId, Decimal>? targetWeights,
    Decimal? commissionRate,
    this.parkingSymbol = kP0sParkingSymbol,
    Map<String, String>? symbolLabels,
    Map<SleeveId, String>? sleeveLabels,
    this.asOfStaleAfter = const Duration(seconds: 93600),
    MonthEndConfig? monthEnd,
  }) : monthEnd = monthEnd ?? p0sMonthEndConfig(),
       targetWeights = Map<SleeveId, Decimal>.unmodifiable(
         targetWeights ?? _p0sWeights,
       ),
       commissionRate = commissionRate ?? Decimal.parse('0.00015'),
       symbolLabels = Map<String, String>.unmodifiable(
         symbolLabels ?? _symbolLabels,
       ),
       sleeveLabels = Map<SleeveId, String>.unmodifiable(
         sleeveLabels ?? _sleeveLabels,
       ) {
    final Decimal sum = this.targetWeights.values.fold(
      Decimal.zero,
      (Decimal a, Decimal b) => a + b,
    );
    if (sum != Decimal.one) {
      throw ArgumentError.value(sum, 'targetWeights', '목표 비중의 합은 1 이어야 한다');
    }
  }

  /// 계획 스냅샷 유효기한 — 계산 시각 + 이 값(06 M3-2 ⓐ «현행 픽스처 관행 = +24h»).
  final Duration planTtl;

  /// 연금저축 + IRP 합산 연 납입한도(03 §2-7-1 · 원).
  final Decimal pensionAnnualLimit;

  /// 세액공제 대상 납입 구간(연금저축 600 + IRP 300 · `exp/tax_lib.py` `CREDIT_CAP` · 원).
  final Decimal taxCreditBand;

  /// 입금 미리보기 금액 하한 · 상한(원 · D-2 — 0 · 음수는 따로 거부한다).
  final Decimal depositMin, depositMax;

  /// 슬리브 목표 비중(02 §4 `capital_allocation` · P0S v2.31 = A 0.20 · B 0.42 · C 잔여 0.38 · 새틀 0).
  final Map<SleeveId, Decimal> targetWeights;

  /// 위탁수수료율(02 §4 `costs.kr.commission` · 국내상장 ETF 매수는 거래세 0).
  final Decimal commissionRate;

  /// 슬리브 B 파킹 ETF(02 §4 `sleeve_b.parking_ticker` — 같은 연금 계좌 안의 초단기채).
  final String parkingSymbol;

  /// 종목 표시 이름(D-16 — 종목 화이트리스트 한 원천).
  final Map<String, String> symbolLabels;

  /// 슬리브 표시 이름(D-16).
  final Map<SleeveId, String> sleeveLabels;

  /// 기준일 고지의 신선도 한계(픽스처 `stale_after_seconds` 93600 = 26시간).
  final Duration asOfStaleAfter;

  /// 🆕 E7a3-2 — 리밸런싱 미리보기의 월말 계획기 설정(실전 값 — C 는 국내상장 ETF · R17 ⑤).
  final MonthEndConfig monthEnd;

  /// 문서 값 기본판(D-5).
  static final WhatIfConfig defaults = WhatIfConfig(
    planTtl: const Duration(hours: 24),
    pensionAnnualLimit: Decimal.fromInt(18000000),
    taxCreditBand: Decimal.fromInt(9000000),
    depositMin: Decimal.one,
    depositMax: Decimal.fromInt(1000000000),
  );
}

final Map<SleeveId, Decimal> _p0sWeights = <SleeveId, Decimal>{
  SleeveId.a: Decimal.parse('0.20'),
  SleeveId.b: Decimal.parse('0.42'),
  SleeveId.c: Decimal.parse('0.38'),
};

/// 03 §2-7-1 · §2-9-2(v2.27) · 02 §4 의 P0S 종목.
const Map<String, String> _symbolLabels = <String, String>{
  '214980': '214980 KODEX 단기채권PLUS',
  '133690': '133690 TIGER 미국나스닥100',
  '411060': '411060 ACE KRX금현물',
  '0085P0': '0085P0 ACE 미국10년국채액티브',
};

/// P0S 파킹 ETF(단기채 · 슬리브 B 대기 자금 — 03 §2-7-1).
const String kP0sParkingSymbol = '214980';

/// P0S 의 KR 계획 종목(B 자산 · C 채권 · C 금 · 파킹 — 슬리브 A 종목은 아직 정해지지 않아 부르는 쪽이 더한다 · 설계 13 §8 R47 F3).
List<String> p0sKrPlanSymbols() {
  final MonthEndConfig m = p0sMonthEndConfig();
  return <String>{
    for (final (String s, _) in m.bAssets) s,
    m.cBondSymbol,
    m.cGoldSymbol,
    kP0sParkingSymbol,
  }.toList()..sort();
}

/// P0S 정본 월말 계획기 설정(02 §4 · 실전 비용 — 국내상장 ETF 수수료 0.015% + 슬리피지 0.10% · 거래세 0).
/// ⬜ 슬리브 C 의 국내상장 종목은 확정 대기다(02 §4 는 미국 상장 UST10·IAU) — 채권 0085P0(픽스처) · 금 411060 을 기본으로 둔다.
MonthEndConfig p0sMonthEndConfig() => MonthEndConfig(
  allocB: Decimal.parse('0.42'),
  coreBand: Decimal.parse('0.03'),
  rampMonths: 6,
  bAssets: <(String, Decimal)>[
    ('133690', Decimal.parse('0.8')),
    ('411060', Decimal.parse('0.2')),
  ],
  lookbackMonths: const <int>[8, 10, 12],
  assist: SleeveBAssist(
    floor: 1 / 3,
    cutState: DirectionState.bear,
    cut: 2 / 3,
  ),
  cBondSymbol: '0085P0',
  cGoldSymbol: '411060',
  cBondWeight: Decimal.parse('0.65'),
  cGoldWeight: Decimal.parse('0.35'),
  maxGoldPctOfTotal: Decimal.parse('0.08'),
  cRelativeBand: Decimal.parse('0.1666666666666667'),
  bOrderThreshold: Decimal.parse('0.005'),
  cOrderThreshold: Decimal.parse('0.002'),
  potOrderThreshold: Decimal.parse('0.005'),
  topupMinFraction: Decimal.parse('0.001'),
  krwUsableFraction: Decimal.parse('0.98'),
  pensionAnnualLimit: Decimal.parse('18000000'),
  pensionFunding: true,
  bSellCostRate: Decimal.parse('0.00115'),
  cSellCostRate: Decimal.parse('0.00115'),
  potCostRate: Decimal.parse('0.00115'),
);

/// 픽스처 꼴(`fixtures/m7/m7_deposit_plan_default.json`).
const Map<SleeveId, String> _sleeveLabels = <SleeveId, String>{
  SleeveId.a: 'A · 국내 지수 ETF',
  SleeveId.b: 'B · 해외 지수·금 ETF',
  SleeveId.c: 'C · 방어 자산',
};
