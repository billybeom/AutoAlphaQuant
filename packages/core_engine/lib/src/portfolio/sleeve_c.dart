// 슬리브 C — 통화 분리 · 달러 분모 고정 비율 · 금 상한 — `06_시스템설계/03_알고리즘.md` §2-9-1 · §2-9-2 ·
// v2.19 · v2.27 블록 · 05 GV-22 · GV-35.
//
// 🔴 원화는 이 배분을 거치지 않는다(§2-9-1 · v2.19 «분모 = 달러 잔액»). 그래서 [sleeveCUsdTargets] 는
//    원화 금액을 **받을 인자가 아예 없다** — 원화 현금성은 따로 든 그대로다(05 GV-35).
// 🔴 금 상한 = `min(달러 잔액 × 금 비중, 총자산 × max_gold_pct_of_total)` — 초과분은 초단기 현금성으로,
//    중기 국채 목표는 그대로다(05 GV-22 q3). v2.27 «총자산 20%» 는 B·POT 금까지 세는 **모니터링**이고
//    이 캡(0.08)은 P0S 에서도 유지된다.
// 🔵 P0S 비중(v2.27) = 현금성 0 / 미10년 0.65 / 금 0.35. 현금성 비중이 0 이어도 금 초과분은 현금성 칸에 남는다.
// ⚠️ 분모에 무엇을 넣는지는 호출자(E6 배선) 몫이다 — 참조 엔진 P0S(`_sleeve_c_rebalance`)는 «비예약 원화 +
//    미10년 + 금» 을 분모로 쓰고 초과분을 원화로 남긴다. 정답지(GV-35)는 달러 잔액만 분모다(설계 13 §8 R14).

import 'package:decimal/decimal.dart';

import '../decimal_rules.dart';

/// 슬리브 C 달러 배분 비중 — 02 §4 `sleeve_c` (현금성 · 중기 국채 · 금).
class SleeveCWeights {
  /// 비중을 만든다. 각 0~1 · 합 1(오차 1e-9)이 아니면 [ArgumentError].
  SleeveCWeights({required this.cash, required this.bond, required this.gold}) {
    for (final (String name, double w) in <(String, double)>[
      ('cash', cash),
      ('bond', bond),
      ('gold', gold),
    ]) {
      if (w.isNaN || w < 0 || w > 1) {
        throw ArgumentError.value(w, name, '0~1 이어야 한다');
      }
    }
    if ((cash + bond + gold - 1.0).abs() > 1e-9) {
      throw ArgumentError('슬리브 C 비중 합이 1 이 아니다: ${cash + bond + gold}');
    }
  }

  /// 초단기 현금성(`BIL` · 원화 계좌라면 `A214980`).
  final double cash;

  /// 중기 국채(`IEI` · P0S 는 `UST10`).
  final double bond;

  /// 금(`IAU`).
  final double gold;
}

/// 슬리브 C 달러 자산 목표(원).
class SleeveCTargets {
  /// 결과를 만든다.
  const SleeveCTargets({
    required this.cash,
    required this.bond,
    required this.gold,
  });

  /// 초단기 현금성 — 금 상한 초과분을 받는다.
  final Decimal cash;

  /// 중기 국채.
  final Decimal bond;

  /// 금.
  final Decimal gold;

  /// 합계 — 달러 잔액과 같다(05 GV-22 불변식).
  Decimal get total => cash + bond + gold;
}

/// 03 §2-9-2 `sleeve_c_rebalance` 의 목표 — 달러 잔액만 분모, 금은 총자산 상한까지.
SleeveCTargets sleeveCUsdTargets({
  required Decimal usdTotal,
  required Decimal totalEquity,
  required SleeveCWeights weights,
  required double maxGoldPctOfTotal,
}) {
  if (usdTotal < Decimal.zero || totalEquity < Decimal.zero) {
    throw ArgumentError('달러 잔액·총자산은 0 이상이어야 한다');
  }
  if (maxGoldPctOfTotal.isNaN ||
      maxGoldPctOfTotal < 0 ||
      maxGoldPctOfTotal > 1) {
    throw ArgumentError.value(
      maxGoldPctOfTotal,
      'maxGoldPctOfTotal',
      '0~1 이어야 한다',
    );
  }
  final Decimal goldByWeight = multiply(usdTotal, promoteRatio(weights.gold));
  final Decimal goldCap = multiply(
    totalEquity,
    promoteRatio(maxGoldPctOfTotal),
  );
  final Decimal gold = goldByWeight < goldCap ? goldByWeight : goldCap;
  final Decimal bond = multiply(usdTotal, promoteRatio(weights.bond));
  return SleeveCTargets(cash: usdTotal - gold - bond, bond: bond, gold: gold);
}

/// 유입 통화.
enum InflowCurrency {
  /// 원화(슬리브 A 청산 대금 등).
  krw,

  /// 달러(슬리브 B·새틀라이트에서 나온 돈).
  usd,
}

/// 03 §2-9-1 `sleeve_c_allocate` 의 결과 — 원화 현금성 몫 + 달러 3종 몫.
class SleeveCInflow {
  /// 결과를 만든다.
  const SleeveCInflow({required this.krwCash, required this.usd});

  /// 원화 현금성(`krw_cash_ticker`)에 넣을 금액.
  final Decimal krwCash;

  /// 달러 3종에 넣을 금액 — 원화 유입이면 전부 0.
  final SleeveCTargets usd;
}

/// 03 §2-9-1 `sleeve_c_allocate` — 원화 유입은 **전액 원화 현금성**(환전 왕복 금지 · 05 GV-22 q1),
/// 달러 유입은 고정 비율로.
///
/// 🔵 P0S 에서 슬리브 A 의 비계절 원화는 POT 서브북(§2-9-3 · 회계 = A)으로 가므로 이 경로를 타지 않는다.
SleeveCInflow sleeveCAllocateInflow({
  required Decimal inflow,
  required InflowCurrency currency,
  required SleeveCWeights weights,
}) {
  if (inflow < Decimal.zero) {
    throw ArgumentError.value(inflow, 'inflow', '0 이상이어야 한다');
  }
  if (currency == InflowCurrency.krw) {
    return SleeveCInflow(
      krwCash: inflow,
      usd: SleeveCTargets(
        cash: Decimal.zero,
        bond: Decimal.zero,
        gold: Decimal.zero,
      ),
    );
  }
  final Decimal gold = multiply(inflow, promoteRatio(weights.gold));
  final Decimal bond = multiply(inflow, promoteRatio(weights.bond));
  return SleeveCInflow(
    krwCash: Decimal.zero,
    usd: SleeveCTargets(cash: inflow - gold - bond, bond: bond, gold: gold),
  );
}
