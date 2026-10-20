// 거래비용 · 참여율 절단 · 보유비용 — `06_시스템설계/03_알고리즘.md` §5-6 · §5-7 · 02 §4 `costs` ·
// 05 GV-11 · GV-19 · GV-24.
//
// 🔴 `total = commission + tax + slippage + market_impact`(02 §3 불변식) — 시장충격을 빼지 않는다.
// 🔴 슬리피지 구간은 `min_adv` 내림차순으로 보고 `adv20 >= min_adv` 인 첫 구간(경계 `>=`).
// 🔴 국내상장 ETF 는 증권거래세 면제(02 §4 `etf_tax_rate_sell: 0.0`) — P0S 주문은 전부 ETF 다.
// 🔴 미국 비용식은 명세에 없다 → `UnimplementedError`(fail-closed · 05 GV-11e c6). P0S 는 미국 주문이 없다.
// 🔴 보유비용(총보수)은 **백테스트 전용**이다 — 실거래는 시세에 이미 들어 있어 두 번 빼게 된다(03 §5-7).
//    거래비용에 넣지 않는다(진입 당일 청산이면 0 · 05 GV-24 e5).
// ⚠️ 참조 백테스트 엔진(백테스트6 `config.Costs`)은 ETF 에 구간표 대신 상수 슬리피지 0.10% 를 쓴다 —
//    ETF 의 거래대금은 100억 이상이라 같은 값이 된다. 시장충격은 그 엔진에 없다(E6 에서 sigma 0 으로 맞춘다).

import 'dart:math' as math;

import 'package:decimal/decimal.dart';

import '../calendar/exchange_calendar.dart';
import '../decimal_rules.dart';
import '../risk/limits.dart';

/// 거래대금 구간 하나 — `adv20 >= minAdv` 면 [rate].
class SlippageTier {
  /// 구간을 만든다.
  const SlippageTier({required this.minAdv, required this.rate});

  /// 구간 하한(원 · 포함).
  final Decimal minAdv;

  /// 편도 슬리피지 비율.
  final double rate;
}

/// 한국 비용 설정(02 §4 `costs.kr`).
class KrCostConfig {
  /// 설정을 만든다. 구간표가 비었거나 `min_adv: 0` 구간이 없으면 [ArgumentError](0 거래대금이 미정의가 된다).
  KrCostConfig({
    required this.commissionRate,
    required this.taxRateSell,
    required this.etfTaxRateSell,
    required List<SlippageTier> slippageByAdv,
    required this.impactY,
    required this.participationRate,
  }) : slippageByAdv = List<SlippageTier>.unmodifiable(
         List<SlippageTier>.of(slippageByAdv)..sort(
           (SlippageTier a, SlippageTier b) => b.minAdv.compareTo(a.minAdv),
         ),
       ) {
    if (this.slippageByAdv.isEmpty ||
        this.slippageByAdv.last.minAdv != Decimal.zero) {
      throw ArgumentError('slippage_by_adv 에 min_adv 0 구간이 있어야 한다');
    }
  }

  /// 위탁수수료(매수·매도).
  final double commissionRate;

  /// 증권거래세(개별주 매도).
  final double taxRateSell;

  /// 증권거래세(국내상장 ETF 매도 — 기본 0).
  final double etfTaxRateSell;

  /// 거래대금 구간표(내림차순으로 정렬해 둔다).
  final List<SlippageTier> slippageByAdv;

  /// 시장충격 계수 Y.
  final double impactY;

  /// 참여율 상한(거래대금 대비).
  final double participationRate;
}

/// 거래비용 한 건(원).
class TradeCost {
  /// 결과를 만든다.
  const TradeCost({
    required this.commission,
    required this.tax,
    required this.slippage,
    required this.marketImpact,
    required this.impactPct,
  });

  /// 위탁수수료.
  final Decimal commission;

  /// 증권거래세.
  final Decimal tax;

  /// 슬리피지.
  final Decimal slippage;

  /// 시장충격 금액.
  final Decimal marketImpact;

  /// 시장충격 비율 = Y × σ × sqrt(주문금액 / adv20).
  final double impactPct;

  /// 합계 — 시장충격 포함(02 §3 불변식).
  Decimal get total => commission + tax + slippage + marketImpact;
}

/// 03 §5-6 `trade_cost`.
TradeCost tradeCost({
  required Market market,
  required LimitSide side,
  required Decimal orderValue,
  required Decimal adv20,
  required double sigmaDaily,
  required bool isEtf,
  required KrCostConfig config,
}) {
  if (market != Market.kr) {
    throw UnimplementedError('미국 비용식은 명세에 없다(05 GV-11e c6 · fail-closed)');
  }
  if (orderValue < Decimal.zero || adv20 < Decimal.zero) {
    throw ArgumentError('주문금액·거래대금은 0 이상이어야 한다');
  }
  if (sigmaDaily.isNaN || sigmaDaily < 0) {
    throw ArgumentError.value(sigmaDaily, 'sigmaDaily', '0 이상이어야 한다');
  }
  final double slipRate = config.slippageByAdv
      .firstWhere((SlippageTier t) => adv20 >= t.minAdv)
      .rate;
  final double taxRate = side == LimitSide.sell
      ? (isEtf ? config.etfTaxRateSell : config.taxRateSell)
      : 0.0;
  final double impactPct;
  if (sigmaDaily == 0) {
    impactPct = 0.0; // adv20 = 0 이어도 정의된다(05 GV-11e c5)
  } else if (adv20 == Decimal.zero) {
    throw ArgumentError('거래대금 0 에서 시장충격은 정의되지 않는다');
  } else {
    final double ratio = divide(orderValue, adv20).toDouble();
    impactPct = config.impactY * sigmaDaily * math.sqrt(ratio);
  }
  return TradeCost(
    commission: multiply(orderValue, promoteRatio(config.commissionRate)),
    tax: multiply(orderValue, promoteRatio(taxRate)),
    slippage: multiply(orderValue, promoteRatio(slipRate)),
    marketImpact: multiply(orderValue, promoteRatio(impactPct)),
    impactPct: impactPct,
  );
}

/// 참여율 절단 결과.
class ParticipationCut {
  /// 결과를 만든다.
  const ParticipationCut({
    required this.allowedValue,
    required this.deferredValue,
  });

  /// 오늘 낼 수 있는 금액.
  final Decimal allowedValue;

  /// 다음 거래일로 이월할 금액.
  final Decimal deferredValue;
}

/// 03 §5-6 참여율 절단 — `adv20 × rate` 를 넘는 부분은 다음 거래일로(05 GV-11d).
ParticipationCut participationCut({
  required Decimal desiredValue,
  required Decimal adv20,
  required double participationRate,
}) {
  final Decimal cap = multiply(adv20, promoteRatio(participationRate));
  final Decimal allowed = desiredValue < cap ? desiredValue : cap;
  return ParticipationCut(
    allowedValue: allowed,
    deferredValue: desiredValue - allowed,
  );
}

/// 왕복 한 번의 손익(05 GV-19 — 비용이 손익 경로에 실제로 들어가는가).
class RoundTripPnl {
  /// 결과를 만든다.
  const RoundTripPnl({
    required this.grossPnl,
    required this.buyCost,
    required this.sellCost,
  });

  /// 비용 전 손익.
  final Decimal grossPnl;

  /// 매수 비용 합계.
  final Decimal buyCost;

  /// 매도 비용 합계.
  final Decimal sellCost;

  /// 비용 합계.
  Decimal get totalCost => buyCost + sellCost;

  /// 비용 뒤 손익.
  Decimal get netPnl => grossPnl - totalCost;
}

/// 같은 수량을 사서 판 왕복의 손익 — 매수·매도 비용을 [tradeCost] 로 물린다.
RoundTripPnl roundTripPnl({
  required Decimal entryPrice,
  required Decimal exitPrice,
  required int quantity,
  required Decimal adv20,
  required double sigmaDaily,
  required bool isEtf,
  required KrCostConfig config,
}) {
  final Decimal qty = Decimal.fromInt(quantity);
  TradeCost leg(LimitSide side, Decimal price) => tradeCost(
    market: Market.kr,
    side: side,
    orderValue: price * qty,
    adv20: adv20,
    sigmaDaily: sigmaDaily,
    isEtf: isEtf,
    config: config,
  );
  return RoundTripPnl(
    grossPnl: (exitPrice - entryPrice) * qty,
    buyCost: leg(LimitSide.buy, entryPrice).total,
    sellCost: leg(LimitSide.sell, exitPrice).total,
  );
}

/// 03 §5-7 `apply_holding_cost` — `value × (1 − er/252)^days`(일할 복리). 🔴 백테스트 전용.
///
/// [expenseRatio] 는 이미 마크업(`expense_ratio_markup` 1.15)을 곱한 값이다. [tradingDays] 는 실제 보유
/// 거래일 수(달력일 아님).
Decimal applyHoldingCost({
  required Decimal positionValue,
  required double expenseRatio,
  required int tradingDays,
  required int tradingDaysPerYear,
}) {
  if (expenseRatio.isNaN || expenseRatio < 0) {
    throw ArgumentError.value(expenseRatio, 'expenseRatio', '0 이상이어야 한다');
  }
  if (tradingDays < 0 || tradingDaysPerYear < 1) {
    throw ArgumentError('보유 거래일은 0 이상 · 연 거래일은 1 이상이어야 한다');
  }
  final double factor = math
      .pow(1.0 - expenseRatio / tradingDaysPerYear, tradingDays)
      .toDouble();
  return multiply(positionValue, promoteRatio(factor));
}

/// 가중 총보수 = Σ 총보수 × 비중(05 GV-24 `sleeve_b_weighted`).
double weightedExpenseRatio(List<({double er, double weight})> assets) {
  double sum = 0;
  for (final ({double er, double weight}) a in assets) {
    sum += a.er * a.weight;
  }
  return sum;
}
