// 재현 하네스 변형 → lib 월말 계획기 설정(P0sConfig 값 그대로 · 참조 엔진 비용) — 하네스 대조 시험들이 함께 쓴다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';

import 'replay_engine.dart';

Decimal _dec(double x) => Decimal.parse(x.toString());

/// 하네스 변형 → lib 설정(P0sConfig 값 그대로).
MonthEndConfig harnessMonthEndConfig(ReplayVariant v) => MonthEndConfig(
  allocB: _dec(P0sConfig.allocB),
  coreBand: _dec(P0sConfig.coreBand),
  rampMonths: P0sConfig.rampMonths,
  bAssets: <(String, Decimal)>[
    for (final (String t, double w, double _) in P0sConfig.bAssets)
      (t, _dec(w)),
  ],
  lookbackMonths: P0sConfig.lookbacks,
  assist: SleeveBAssist(
    floor: v.bSmaFloor,
    cutState: v.assistCut == null ? null : DirectionState.bear,
    cut: v.assistCut ?? 0.0,
  ),
  cBondSymbol: 'IEI',
  cGoldSymbol: 'IAU',
  cBondWeight: _dec(P0sConfig.cIeiW),
  cGoldWeight: _dec(P0sConfig.cIauW),
  maxGoldPctOfTotal: _dec(P0sConfig.maxGoldPctOfTotal),
  cRelativeBand: _dec(P0sConfig.satBandHi - 1.0),
  bOrderThreshold: Decimal.parse('0.005'),
  cOrderThreshold: Decimal.parse('0.002'),
  potOrderThreshold: Decimal.parse('0.005'),
  topupMinFraction: Decimal.parse('0.001'),
  krwUsableFraction: Decimal.parse('0.98'),
  pensionAnnualLimit: _dec(P0sConfig.pensionAnnualLimit),
  pensionFunding: v.pensionFunding,
  bSellCostRate: _dec(
    P0sConfig.krCommission + P0sConfig.krSlipEtf + P0sConfig.krTaxSellEtf,
  ),
  cSellCostRate: _dec(
    P0sConfig.usCommission +
        P0sConfig.usSlippage +
        P0sConfig.fxSpreadRoundtrip / 2.0,
  ),
  potCostRate: _dec(P0sConfig.krCommission + P0sConfig.krSlipEtf),
);
