// 골든벡터 설정 받침 — 정답지가 산문으로만 주는 설정(E11o-b · 설계 13 §8 R163 · 옛 `test/golden/kr_costs_fixture.dart`).
//
// 🔴 02 §4 `costs.kr`(1423~1437행) 값 그대로 · 05 §GV-11 «설정» 블록과 같다. 05 GV-11 의 설정은 코드 블록이 아니라
//    산문(`slippage_tier = { ">=100억": ... }`)이라 정답지 파일로 옮길 수 없다 — 그래서 여기 한 곳에 적고 시험 · 폰이 이것만 쓴다.
// 🔴 운영 비용 설정이 아니다 — 골든 판정 입력이다(운영 = 설정 판 · 03 §5-6).
// 🔴 `tax_rate_sell` 은 v2.10(2026 기준) 0.0020 이다. 05 GV-19 는 그 전 값 0.0018 로 계산돼 있다
//    (설계 13 §8 R13) — 그 판정만 [kGv19StaleTaxRate] 로 덮는다.

import 'package:decimal/decimal.dart';

import '../costs/trade_costs.dart' show KrCostConfig, SlippageTier;

/// 02 §4 `costs.kr`.
KrCostConfig krCostsFromSpec({double taxRateSell = 0.0020}) => KrCostConfig(
  commissionRate: 0.00015,
  taxRateSell: taxRateSell,
  etfTaxRateSell: 0.0,
  slippageByAdv: <SlippageTier>[
    SlippageTier(minAdv: Decimal.parse('10000000000'), rate: 0.0010),
    SlippageTier(minAdv: Decimal.parse('1000000000'), rate: 0.0030),
    SlippageTier(minAdv: Decimal.zero, rate: 0.0060),
  ],
  impactY: 1.0,
  participationRate: 0.03,
);

/// 05 GV-19 이 쓴 옛 증권거래세(02 v2.10 이전 0.18%).
const double kGv19StaleTaxRate = 0.0018;

/// 02 §4 `common.trading_days_per_year`.
const int kTradingDaysPerYear = 252;
