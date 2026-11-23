// 월말 계획기 입력 조립 — 원장 보유 → `MonthEndState`(설계 13 §8 R48 P4~P6 · 참조 = 시험 하네스 `ReplayEngine.monthEndInput`).
//
// 🔴 순수 조립이다(조회 · 저장 0) — 쓰는 곳 = data_sync `MonthlyRebalanceJob`.
// 🔴 귀속은 원장의 전략 칸으로만 한다 — `P0S_A` · `P0S_B`(B 자산 · 파킹) · `P0S_C`(채권 · 금 · C 로 재분류된 파킹) · `P0S_POT`(B 자산).
//    그 밖의 (전략 · 종목) 보유는 실패다(귀속 불가 — 지어내지 않는다).
// 🔴 보유가 있는데 종가가 없으면 실패 · 안 가진 B 자산 · 금의 종가가 없으면 null(계획기 규약 — 그 종목을 건너뛴다).
// 🔴 POT 현금 · 예약 원화는 받은 값이다(E11f3 전 = 0) · C 원화 = 현금 − POT − 예약(음수 = 실패).

import 'package:decimal/decimal.dart';

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../orders/order_draft.dart'
    show OrderTarget, P0sStrategyIds, targetsFromMonthEnd;
import '../orders/order_ports.dart' show OrderBroker;
import '../orders/reconcile.dart' show LedgerHolding;
import '../portfolio/month_end_plan.dart';
import '../risk/limits.dart' show InstrumentKind;
import '../signals/regime_states.dart' show DirectionState;
import '../whatif/deposit_register.dart' show LedgerCashRow, pensionUsedInYear;
import 'tier_b.dart' show P0sRiskCaps;

/// 조립 실패 — 🔴 사유 = 전략 · 종목만(금액 0).
class MonthEndInputError implements Exception {
  /// 실패를 만든다.
  const MonthEndInputError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'MonthEndInputError($reason)';
}

/// 달마다 마지막 종가(R48 P6 · 하네스 `bMonthly` 꼴) — [bars] = (날짜 `YYYY-MM-DD`, 수정 종가) · [uptoMonth] = `YYYY-MM`(포함).
/// 0 이하 · NaN 종가는 버린다.
List<double> monthlyLastCloses(
  Iterable<(String, double)> bars,
  String uptoMonth,
) {
  final Map<String, (String, double)> last = <String, (String, double)>{};
  for (final (String d, double c) in bars) {
    if (c.isNaN || !c.isFinite || c <= 0) continue;
    final String m = d.substring(0, 7);
    if (m.compareTo(uptoMonth) > 0) continue;
    final (String, double)? prev = last[m];
    if (prev == null || d.compareTo(prev.$1) > 0) last[m] = (d, c);
  }
  final List<String> months = last.keys.toList()..sort();
  return <double>[for (final String m in months) last[m]!.$2];
}

/// 원장 보유 · 종가 · 현금 → 계획기 입력(R48 P4~P6).
///
/// [closes] = 월말 원가 종가(설정 종목 전부 · 없으면 빠진다) · [cashKrw] = 계좌 현금 합(D+2).
MonthEndState monthEndStateFromLedger({
  required List<LedgerHolding> holdings,
  required Map<String, Decimal> closes,
  required Decimal cashKrw,
  required Decimal potCash,
  required Decimal reservedKrw,
  required Decimal pensionUsedThisYear,
  required int monthIndex,
  required DirectionState? regimeState,
  required Map<String, List<double>> monthlyCloses,
  required bool hasNextKrSession,
  required bool hasNextUsSession,
  required MonthEndConfig config,
  required String parkingSymbol,
}) {
  if (monthIndex < 1) throw ArgumentError.value(monthIndex, 'monthIndex');
  if (cashKrw < Decimal.zero ||
      potCash < Decimal.zero ||
      reservedKrw < Decimal.zero) {
    throw ArgumentError('현금 · POT · 예약은 음수가 아니다');
  }
  final Set<String> bSyms = <String>{
    for (final (String s, Decimal _) in config.bAssets) s,
  };
  final Map<(String, String), int> qty = <(String, String), int>{};
  for (final LedgerHolding h in holdings) {
    final (String, String) k = (h.strategyId, h.symbol);
    qty[k] = (qty[k] ?? 0) + h.quantity;
  }
  final Map<String, Decimal> bVal = <String, Decimal>{};
  final Map<String, Decimal> potVal = <String, Decimal>{};
  Decimal a = Decimal.zero,
      bPark = Decimal.zero,
      cPark = Decimal.zero,
      cBond = Decimal.zero,
      cGold = Decimal.zero;
  bool goldHeld = false;
  final List<(String, String)> keys = qty.keys.toList()
    ..sort(
      ((String, String) x, (String, String) y) =>
          x.$1 == y.$1 ? x.$2.compareTo(y.$2) : x.$1.compareTo(y.$1),
    );
  for (final (String strategy, String symbol) in keys) {
    final int q = qty[(strategy, symbol)]!;
    if (q == 0) continue;
    if (q < 0) throw MonthEndInputError('보유 수량 음수: $strategy $symbol');
    final Decimal? px = closes[symbol];
    if (px == null || px <= Decimal.zero) {
      throw MonthEndInputError('종가 없음: $strategy $symbol');
    }
    final Decimal v = px * Decimal.fromInt(q);
    switch (strategy) {
      case P0sStrategyIds.sleeveA:
        a += v;
      case P0sStrategyIds.sleeveB when bSyms.contains(symbol):
        bVal[symbol] = (bVal[symbol] ?? Decimal.zero) + v;
      case P0sStrategyIds.sleeveB when symbol == parkingSymbol:
        bPark += v;
      case P0sStrategyIds.sleeveC when symbol == config.cBondSymbol:
        cBond += v;
      case P0sStrategyIds.sleeveC when symbol == config.cGoldSymbol:
        cGold += v;
        goldHeld = true;
      case P0sStrategyIds.sleeveC when symbol == parkingSymbol:
        cPark += v;
      case P0sStrategyIds.pot when bSyms.contains(symbol):
        potVal[symbol] = (potVal[symbol] ?? Decimal.zero) + v;
      default:
        throw MonthEndInputError('귀속 불가 보유: $strategy $symbol');
    }
  }
  final Decimal krw = cashKrw - potCash - reservedKrw;
  if (krw < Decimal.zero) {
    throw const MonthEndInputError('POT · 예약이 현금보다 크다');
  }
  Decimal? priced(String s, Decimal held) =>
      closes.containsKey(s) && closes[s]! > Decimal.zero ? held : null;
  final Map<String, Decimal?> bAssets = <String, Decimal?>{
    for (final (String s, Decimal _) in config.bAssets)
      s: priced(s, bVal[s] ?? Decimal.zero),
  };
  final Map<String, Decimal?> potAssets = <String, Decimal?>{
    for (final (String s, Decimal _) in config.bAssets)
      s: priced(s, potVal[s] ?? Decimal.zero),
  };
  final Decimal total =
      a +
      bVal.values.fold(Decimal.zero, (Decimal x, Decimal y) => x + y) +
      bPark +
      cPark +
      cBond +
      cGold +
      potVal.values.fold(Decimal.zero, (Decimal x, Decimal y) => x + y) +
      cashKrw;
  return MonthEndState(
    totalEquity: total,
    bAssets: bAssets,
    bParking: bPark,
    bParkingReclassified: cPark,
    krwCash: krw,
    reservedKrw: reservedKrw,
    cBond: cBond,
    cGold: goldHeld ? cGold : priced(config.cGoldSymbol, Decimal.zero),
    potCash: potCash,
    potAssets: potAssets,
    pensionUsedThisYear: pensionUsedThisYear,
    monthIndex: monthIndex,
    regimeState: regimeState,
    monthlyCloses: monthlyCloses,
    hasNextKrSession: hasNextKrSession,
    hasNextUsSession: hasNextUsSession,
  );
}

/// 슬리브 비중(A · B · C · POT · 합 1) — `rebalance_event.weights_*` 용. 총평가 0 이하 = 전부 0.
Map<String, double> sleeveWeightsOf(MonthEndState s) {
  Decimal sum(Iterable<Decimal?> vs) =>
      vs.fold(Decimal.zero, (Decimal x, Decimal? y) => y == null ? x : x + y);
  final Decimal b = sum(s.bAssets.values) + s.bParking;
  final Decimal c =
      s.cBond +
      (s.cGold ?? Decimal.zero) +
      s.bParkingReclassified +
      s.krwCash +
      s.reservedKrw;
  final Decimal pot = s.potCash + sum(s.potAssets.values);
  final Decimal total = s.totalEquity;
  if (total <= Decimal.zero) {
    return const <String, double>{'A': 0, 'B': 0, 'C': 0, 'POT': 0};
  }
  final Decimal a = total - b - c - pot;
  double w(Decimal v) => v.toDouble() / total.toDouble();
  return <String, double>{'A': w(a), 'B': w(b), 'C': w(c), 'POT': w(pot)};
}

/// 계획 상태 → JSON(금액 = 글자 · `plan_snapshot.inputs` · `outputs.after`).
Map<String, Object?> monthEndStateToJson(MonthEndState s) => <String, Object?>{
  'total_equity': s.totalEquity.toString(),
  'b_assets': <String, Object?>{
    for (final MapEntry<String, Decimal?> e in s.bAssets.entries)
      e.key: e.value?.toString(),
  },
  'b_parking': s.bParking.toString(),
  'b_parking_reclassified': s.bParkingReclassified.toString(),
  'krw_cash': s.krwCash.toString(),
  'reserved_krw': s.reservedKrw.toString(),
  'c_bond': s.cBond.toString(),
  'c_gold': s.cGold?.toString(),
  'pot_cash': s.potCash.toString(),
  'pot_assets': <String, Object?>{
    for (final MapEntry<String, Decimal?> e in s.potAssets.entries)
      e.key: e.value?.toString(),
  },
  'pension_used_this_year': s.pensionUsedThisYear.toString(),
  'month_index': s.monthIndex,
  'regime_state': s.regimeState?.code,
};

/// 계획 행동 → JSON.
Map<String, Object?> monthEndActionToJson(MonthEndAction a) =>
    <String, Object?>{
      'kind': a.kind.name,
      'symbol': a.symbol,
      'is_buy': a.isBuy,
      'amount': a.amount.toString(),
      'cost': a.cost.toString(),
    };

/// 월말 계획 한 번의 결과.
class MonthEndRun {
  /// 결과를 만든다.
  const MonthEndRun({
    required this.state,
    required this.plan,
    required this.targets,
    required this.weightsBefore,
    required this.weightsAfter,
  });

  /// 계획 전 상태.
  final MonthEndState state;

  /// 계획.
  final MonthEndPlan plan;

  /// 주문 대상.
  final List<OrderTarget> targets;

  /// 슬리브 비중(전 · 후).
  final Map<String, double> weightsBefore, weightsAfter;
}

/// 원장 보유 · 종가 글자 · 계좌 현금 → 상태 → 계획 → 대상(R48 P4~P7).
///
/// [closeTexts] = 월말 원가 종가 글자 · [cashAccounts] = 계좌 별칭 → 브로커(🔴 `orderableCashKrw` = D+2) ·
/// [pensionRows] · [pensionAlias] · [pensionOutsideText] = 연금 한도 사용액 계산 입력 · [potCashText] = POT 현금(🆕 E11f3 —
/// 체결에서 다시 센 값 · 음수 = 실패) · 예약 원화 = 0(S7 · R49).
/// 종가 · 귀속 · 현금 조회 실패 = [MonthEndInputError](금액 0).
/// 🆕 R247 — [caps] = 계층 B 위험 슬리브 상한(B · POT 를 계획기로 · A 는 계절 잡 · 기본 = 상한 없음).
Future<MonthEndRun> computeMonthEndRun({
  required TradeDate monthEnd,
  required List<LedgerHolding> holdings,
  required Map<String, String> closeTexts,
  required Map<String, OrderBroker> cashAccounts,
  required Iterable<LedgerCashRow> pensionRows,
  required String pensionAlias,
  required int monthIndex,
  required DirectionState? regimeState,
  required Map<String, List<double>> monthlyCloses,
  required bool hasNextKrSession,
  required bool hasNextUsSession,
  required MonthEndConfig config,
  required String parkingSymbol,
  required Map<String, InstrumentKind> instruments,
  String pensionOutsideText = '0',
  String potCashText = '0',
  P0sRiskCaps caps = P0sRiskCaps.full,
}) async {
  if (cashAccounts.isEmpty) throw ArgumentError('현금 계좌가 없다');
  final Decimal? outside = Decimal.tryParse(pensionOutsideText);
  if (outside == null || outside < Decimal.zero) {
    throw ArgumentError.value(pensionOutsideText, 'pensionOutsideText');
  }
  final Decimal? pot = Decimal.tryParse(potCashText);
  if (pot == null || pot < Decimal.zero) {
    throw MonthEndInputError('POT 현금이 음수거나 숫자가 아니다');
  }
  Decimal cash = Decimal.zero;
  for (final String a in cashAccounts.keys.toList()..sort()) {
    try {
      cash += await cashAccounts[a]!.orderableCashKrw();
    } on Object {
      throw MonthEndInputError('현금 조회 실패: $a');
    }
  }
  final Map<String, Decimal> closes = <String, Decimal>{
    for (final MapEntry<String, String> e in closeTexts.entries)
      if (Decimal.tryParse(e.value) case final Decimal v) e.key: v,
  };
  final MonthEndState state = monthEndStateFromLedger(
    holdings: holdings,
    closes: closes,
    cashKrw: cash,
    potCash: pot,
    reservedKrw: Decimal.zero,
    pensionUsedThisYear: pensionUsedInYear(
      pensionRows,
      pensionAlias: pensionAlias,
      year: int.parse(monthEnd.yyyyMmDd.substring(0, 4)),
      declaredOutside: outside,
    ),
    monthIndex: monthIndex,
    regimeState: regimeState,
    monthlyCloses: monthlyCloses,
    hasNextKrSession: hasNextKrSession,
    hasNextUsSession: hasNextUsSession,
    config: config,
    parkingSymbol: parkingSymbol,
  );
  Decimal? capOf(double c) => c >= 1.0 ? null : Decimal.parse(c.toString());
  final MonthEndPlan plan = planMonthEnd(
    state,
    config,
    capB: capOf(caps.b),
    capPot: capOf(caps.pot),
  );
  return MonthEndRun(
    state: state,
    plan: plan,
    targets: targetsFromMonthEnd(
      plan,
      judgmentDate: monthEnd,
      instruments: instruments,
    ),
    weightsBefore: sleeveWeightsOf(state),
    weightsAfter: sleeveWeightsOf(plan.after),
  );
}
