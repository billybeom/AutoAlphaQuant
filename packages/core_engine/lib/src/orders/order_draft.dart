// 주문 초안기 — 주문 대상(월말 계획 행동 · 계절 분할 · 입금) → 주문 의도 초안(계좌 · 전략 · 수량 · 지정가 ·
// decision_id). 04 §3-2 v2.38 · 03 §5-3-1 v2.38 · 설계 13 §8 R33 D2 · D9 · D17 · D18 · D19 · R34 U3~U7.
//
// 🔴 값만 낸다(부작용 0) — 한도 판정 · 예약 · 발주는 순서기(E10b)가 이 초안을 받아 NR-1 1~9 를 탄다.
// 🔴 fail-closed: 계좌 · 시세 · 보유를 모르면 그 종목은 초안을 내지 않고 [DraftIssue] 로 돌려준다(추측 금지).
// 🔴 호가 단위 · 상 · 하한은 **시세 입력**이다(KIS 현재가 `aspr_unit` · `stck_mxpr` · `stck_llam`) — 상품 ·
//    가격대마다 다른 KRX 호가표를 코드에 박지 않는다(R34 U3).
// 🔴 지정가 = 직전 세션 **원 종가** × (1 ± offset) → 호가 안쪽 맞춤(매수 내림 · 매도 올림) → 상 · 하한 안(D9).
// 🔴 순매매(D17): 같은 집행일 · (계좌 · 종목 · strategy_id) 안에서 방향별 주수로 바꾼 뒤 합친다. 서로 다른
//    strategy_id 가 같은 (계좌 · 종목)에 오면 내지 않는다 — `positions` PK 가 strategy_id 단위라 순체결을 나눌
//    규칙이 없다(R34 U6 · 02 v2.38 계좌 대응표 확정 때 다시).
// 🔴 계좌는 설정 맵(strategy_id → 계좌 별칭)에서만 온다 — 대응표(02 v2.38)가 ⬜ 인 동안 코드 상수로 박지 않는다(U7).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../decimal_rules.dart';
import '../portfolio/month_end_plan.dart';
import '../risk/limits.dart';
import 'idempotency.dart';

/// P0S 의 strategy_id(02 §2-4 v2.38 · 설계 13 §8 R33 D18) — 슬리브 단위.
abstract final class P0sStrategyIds {
  /// 슬리브 A(계절 · KOSDAQ 지수 ETF).
  static const String sleeveA = 'P0S_A';

  /// 슬리브 B(코어 · 연금 계좌).
  static const String sleeveB = 'P0S_B';

  /// 슬리브 C(방어 · 국내상장 ETF).
  static const String sleeveC = 'P0S_C';

  /// POT 서브북(회계 소속 = 슬리브 A · 절세계좌).
  static const String pot = 'P0S_POT';

  /// 월 납입 배분(입금 — 슬리브를 가로지르는 포트폴리오 단위 · R12).
  static const String deposit = 'P0S';
}

/// `order_intents.order_type` 값(02 §2-4 v2.38 · R33 D19) — KIS `ORD_DVSN` 대응은 broker_gateway 몫.
abstract final class OrderTypes {
  /// 지정가.
  static const String limit = 'LIMIT';

  /// 시장가 — 계절 분할의 마지막 날만(03 §5-3-1 v2.38 · D7).
  static const String market = 'MARKET';
}

/// 주문 크기.
sealed class OrderSizing {
  const OrderSizing();
}

/// 금액(원) — 수량은 지정가로 내림해 잰다(D9).
final class AmountSizing extends OrderSizing {
  /// 금액 크기.
  const AmountSizing(this.krw);

  /// 금액(원 · 양수).
  final Decimal krw;
}

/// 주수(계절 분할의 하루 몫 등).
final class ShareSizing extends OrderSizing {
  /// 주수 크기.
  const ShareSizing(this.shares);

  /// 주수(0 이상 — 0 이면 초안 없음).
  final int shares;
}

/// 보유 전량(매도만 — 계절 청산 · POT 전량 청산).
final class AllHeldSizing extends OrderSizing {
  /// 전량.
  const AllHeldSizing();
}

/// 주문 대상 하나 — 논리 결정 · 전략 · 종목 · 방향 · 크기.
class OrderTarget {
  /// 대상을 만든다. 크기가 방향과 맞지 않으면(매수 전량 · 금액 ≤ 0 · 음수 주수) [ArgumentError].
  OrderTarget({
    required this.logicalDecisionId,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.sizing,
    this.instrument = InstrumentKind.stock,
    this.marketOrder = false,
  }) {
    switch (sizing) {
      case AmountSizing(:final Decimal krw) when krw <= Decimal.zero:
        throw ArgumentError.value(krw, 'sizing', '금액이 0 이하다');
      case ShareSizing(:final int shares) when shares < 0:
        throw ArgumentError.value(shares, 'sizing', '주수가 음수다');
      case AllHeldSizing() when side == OrderSide.buy:
        throw ArgumentError.value(sizing, 'sizing', '전량은 매도만이다');
      case AmountSizing() || ShareSizing() || AllHeldSizing():
        break;
    }
  }

  /// 논리 결정 id(04 §3-2 표의 값 — 집행일 접미 없음).
  final String logicalDecisionId;

  /// strategy_id(P0S 는 [P0sStrategyIds]).
  final String strategyId;

  /// 종목 코드(KR).
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 크기.
  final OrderSizing sizing;

  /// 상품 구분 — 비면 개별주(04 §1 v2.38 «비면 STOCK» · fail-closed).
  final InstrumentKind instrument;

  /// 시장가로 낼 것인가(계절 분할 마지막 날).
  final bool marketOrder;
}

/// 초안에 쓰는 그 종목의 시세(직전 세션 원 종가 + 오늘 호가 단위 · 상 · 하한 — KIS 현재가).
class DraftQuote {
  /// 시세를 만든다.
  const DraftQuote({
    required this.previousClose,
    required this.tickSize,
    required this.upperLimit,
    required this.lowerLimit,
  });

  /// 직전 세션 **원** 종가(수정 종가 아님 — D9).
  final Decimal previousClose;

  /// 호가 단위(`aspr_unit`).
  final Decimal tickSize;

  /// 오늘 상한가(`stck_mxpr`).
  final Decimal upperLimit;

  /// 오늘 하한가(`stck_llam`).
  final Decimal lowerLimit;

  /// 값이 앞뒤가 맞는가 — 모두 양수 · 하한 ≤ 상한.
  bool get isValid =>
      previousClose > Decimal.zero &&
      tickSize > Decimal.zero &&
      lowerLimit > Decimal.zero &&
      lowerLimit <= upperLimit;
}

/// 초안 설정(02 §4 — 값은 config 에서 온다).
class DraftConfig {
  /// 설정을 만든다.
  const DraftConfig({
    required this.limitOffsetPct,
    required this.buyCostRate,
    required this.accountByStrategy,
  });

  /// 지정가 여유(`seasonality.limit_offset_pct` — 매수 +, 매도 −).
  final double limitOffsetPct;

  /// 매수 비용률(수수료 등) — 금액 → 주수 환산에서 지정가에 곱한다(D9 «매수는 비용 포함»).
  final double buyCostRate;

  /// strategy_id → 계좌 별칭(`cash_flow.account_alias` 와 같은 축 · R34 U7).
  final Map<String, String> accountByStrategy;
}

/// 초안을 내지 못한 사유(R34 U3 · U5 · U6 · U7).
enum DraftIssueCode {
  /// strategy_id 의 계좌가 설정에 없다.
  accountUnmapped('ACCOUNT_UNMAPPED'),

  /// 그 종목 시세가 없다.
  quoteMissing('QUOTE_MISSING'),

  /// 시세 값이 앞뒤가 안 맞는다(0 이하 · 하한 > 상한).
  quoteInvalid('QUOTE_INVALID'),

  /// 매도인데 보유 수량을 모른다.
  holdingUnknown('HOLDING_UNKNOWN'),

  /// 잰 수량이 0 주다(`order_intents.quantity > 0` — 행을 만들 수 없다).
  zeroQuantity('ZERO_QUANTITY'),

  /// 매수 · 매도가 서로 지워져 순 0 주다.
  nettedOut('NETTED_OUT'),

  /// 서로 다른 strategy_id 가 같은 (계좌 · 종목)에 왔다.
  strategyConflict('STRATEGY_CONFLICT');

  const DraftIssueCode(this.code);

  /// 기록 표기.
  final String code;
}

/// 초안을 내지 못한 묶음 하나.
class DraftIssue {
  /// 사유를 만든다.
  const DraftIssue(
    this.code, {
    required this.symbol,
    required this.account,
    required this.strategyIds,
    required this.logicalDecisionIds,
  });

  /// 사유.
  final DraftIssueCode code;

  /// 종목.
  final String symbol;

  /// 계좌 별칭(못 찾았으면 null).
  final String? account;

  /// 관련 strategy_id(정렬).
  final List<String> strategyIds;

  /// 관련 논리 결정 id(정렬).
  final List<String> logicalDecisionIds;

  @override
  String toString() =>
      '${code.code} $symbol ${account ?? '-'} $strategyIds $logicalDecisionIds';
}

/// 주문 의도 초안 — `order_intents` 한 행의 값(상태 · 시각 · config_hash 는 순서기 몫).
class OrderIntentDraft {
  /// 초안을 만든다.
  const OrderIntentDraft({
    required this.executionDate,
    required this.account,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.orderType,
    required this.limitPrice,
    required this.sizingPrice,
    required this.logicalDecisionId,
    required this.decisionId,
    required this.instrument,
  });

  /// 시장 — P0S 주문은 전부 KR(실전 C = 국내상장 ETF · R17 ⑤).
  String get market => 'KR';

  /// 집행일(KR 거래일).
  final TradeDate executionDate;

  /// 계좌 별칭.
  final String account;

  /// strategy_id.
  final String strategyId;

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 수량(≥ 1).
  final int quantity;

  /// [OrderTypes] 값.
  final String orderType;

  /// 지정가(시장가면 null).
  final Decimal? limitPrice;

  /// 수량을 잰 가격 — 지정가면 [limitPrice] 와 같고, 시장가면 «냈을 지정가»(SAF-402 평가 단가).
  final Decimal sizingPrice;

  /// 논리 결정 id(순매매로 합쳤으면 `+` 결합 — R34 U6).
  final String logicalDecisionId;

  /// 주문 의도의 decision_id = `{논리 id}@{집행일}`(04 §3-2 v2.38).
  final String decisionId;

  /// 상품 구분.
  final InstrumentKind instrument;

  /// 멱등키(04 §3-2 · 05 GV-9) — 같은 날 같은 결정의 재실행은 같은 키다.
  String get idempotencyKey => _idempotencyKey(
    market: market,
    account: account,
    symbol: symbol,
    side: side.wire,
    decisionId: decisionId,
  );

  /// 한도 판정(04 §1-5) 입력 — 손절가는 없다(개별주 매수면 SAF-103 이 [RiskCheckUnavailable] · fail-closed).
  LimitIntent toLimitIntent() => LimitIntent(
    side: side == OrderSide.buy ? LimitSide.buy : LimitSide.sell,
    isUsMarket: false,
    orderType: orderType,
    quantity: quantity,
    limitPrice: limitPrice,
    entryPrice: sizingPrice,
    stopPrice: null,
    isSatellite: false,
    instrument: instrument,
  );

  /// 수량만 바꾼 사본(예수금 축소 — 결정 id · 멱등키는 그대로 · R35 V8). [quantity] < 1 이면 [ArgumentError].
  OrderIntentDraft withQuantity(int quantity) {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', '1 이상이어야 한다');
    }
    return OrderIntentDraft(
      executionDate: executionDate,
      account: account,
      strategyId: strategyId,
      symbol: symbol,
      side: side,
      quantity: quantity,
      orderType: orderType,
      limitPrice: limitPrice,
      sizingPrice: sizingPrice,
      logicalDecisionId: logicalDecisionId,
      decisionId: decisionId,
      instrument: instrument,
    );
  }

  @override
  String toString() =>
      '$decisionId $account $strategyId $symbol ${side.wire} $quantity '
      '$orderType ${limitPrice ?? '-'}';
}

String _idempotencyKey({
  required String market,
  required String account,
  required String symbol,
  required String side,
  required String decisionId,
}) => idempotencyKey(
  market: market,
  account: account,
  symbol: symbol,
  side: side,
  decisionId: decisionId,
);

/// 초안 결과 — 초안(매도 먼저 · 계좌 · 종목 순 — `kr_order` 2단계 D10 의 순서) + 내지 못한 사유.
class DraftResult {
  /// 결과를 만든다.
  const DraftResult(this.drafts, this.issues);

  /// 초안.
  final List<OrderIntentDraft> drafts;

  /// 내지 못한 사유(계좌 · 종목 순).
  final List<DraftIssue> issues;
}

/// 지정가 — 직전 세션 원 종가 × (1 ± offset) → 호가 안쪽 맞춤(매수 내림 · 매도 올림) → 상 · 하한 안(D9).
///
/// 시세가 앞뒤가 안 맞거나 offset 이 [0, 1) 밖이면 [ArgumentError].
Decimal limitPriceFor(OrderSide side, DraftQuote quote, double limitOffsetPct) {
  if (!quote.isValid) {
    throw ArgumentError.value(quote, 'quote', '시세 값이 앞뒤가 안 맞는다');
  }
  final Decimal offset = promoteRatio(limitOffsetPct);
  if (offset < Decimal.zero || offset >= Decimal.one) {
    throw ArgumentError.value(limitOffsetPct, 'limitOffsetPct', '[0, 1) 밖이다');
  }
  final bool buy = side == OrderSide.buy;
  final Decimal raw = multiply(
    quote.previousClose,
    buy ? Decimal.one + offset : Decimal.one - offset,
  );
  final Decimal tick = quote.tickSize;
  Decimal price = buy ? _floorToTick(raw, tick) : _ceilToTick(raw, tick);
  final Decimal upper = _floorToTick(quote.upperLimit, tick);
  final Decimal lower = _ceilToTick(quote.lowerLimit, tick);
  if (price > upper) price = upper;
  if (price < lower) price = lower;
  return price;
}

Decimal _floorToTick(Decimal value, Decimal tick) =>
    divide(value, tick).floor() * tick;

Decimal _ceilToTick(Decimal value, Decimal tick) =>
    divide(value, tick).ceil() * tick;

int _floorInt(Decimal value) {
  final int q = value.floor().toBigInt().toInt();
  return q < 0 ? 0 : q;
}

/// 주문 대상 → 초안(R34 U3~U7). [holdings] 키 = (strategy_id, 종목) — `positions` PK 와 같은 축.
DraftResult draftOrders(
  Iterable<OrderTarget> targets, {
  required TradeDate executionDate,
  required Map<String, DraftQuote> quotes,
  required Map<(String, String), int> holdings,
  required DraftConfig config,
}) {
  final List<DraftIssue> issues = <DraftIssue>[];
  // (계좌, 종목) → 대상. 계좌를 모르는 대상은 (strategy_id, 종목) 마다 사유 하나.
  final Map<(String, String), List<OrderTarget>> groups =
      <(String, String), List<OrderTarget>>{};
  final Map<(String, String), List<OrderTarget>> unmapped =
      <(String, String), List<OrderTarget>>{};
  for (final OrderTarget t in targets) {
    final String? account = config.accountByStrategy[t.strategyId];
    if (account == null) {
      (unmapped[(t.strategyId, t.symbol)] ??= <OrderTarget>[]).add(t);
    } else {
      (groups[(account, t.symbol)] ??= <OrderTarget>[]).add(t);
    }
  }
  for (final MapEntry<(String, String), List<OrderTarget>> e
      in unmapped.entries) {
    issues.add(_issue(DraftIssueCode.accountUnmapped, e.key.$2, null, e.value));
  }

  final List<OrderIntentDraft> drafts = <OrderIntentDraft>[];
  for (final MapEntry<(String, String), List<OrderTarget>> e
      in groups.entries) {
    final (String account, String symbol) = e.key;
    final List<OrderTarget> group = e.value;
    DraftIssue issue(DraftIssueCode code) =>
        _issue(code, symbol, account, group);

    final Set<String> strategies = <String>{
      for (final OrderTarget t in group) t.strategyId,
    };
    if (strategies.length > 1) {
      issues.add(issue(DraftIssueCode.strategyConflict));
      continue;
    }
    final String strategyId = strategies.single;
    final DraftQuote? quote = quotes[symbol];
    if (quote == null) {
      issues.add(issue(DraftIssueCode.quoteMissing));
      continue;
    }
    if (!quote.isValid) {
      issues.add(issue(DraftIssueCode.quoteInvalid));
      continue;
    }
    final bool sells = group.any((OrderTarget t) => t.side == OrderSide.sell);
    final int? held = holdings[(strategyId, symbol)];
    if (sells && held == null) {
      issues.add(issue(DraftIssueCode.holdingUnknown));
      continue;
    }

    final Decimal buyPrice = limitPriceFor(
      OrderSide.buy,
      quote,
      config.limitOffsetPct,
    );
    final Decimal sellPrice = limitPriceFor(
      OrderSide.sell,
      quote,
      config.limitOffsetPct,
    );
    final Decimal buyUnit = multiply(
      buyPrice,
      Decimal.one + promoteRatio(config.buyCostRate),
    );
    int buyQty = 0;
    int sellQty = 0;
    for (final OrderTarget t in group) {
      final bool buy = t.side == OrderSide.buy;
      final int q = switch (t.sizing) {
        AmountSizing(:final Decimal krw) => _floorInt(
          divide(krw, buy ? buyUnit : sellPrice),
        ),
        ShareSizing(:final int shares) => shares,
        AllHeldSizing() => held!,
      };
      if (buy) {
        buyQty += q;
      } else {
        sellQty += q;
      }
    }
    // 매도 합은 보유를 넘지 않는다(U6).
    if (sells && sellQty > held!) sellQty = held;

    if (buyQty == 0 && sellQty == 0) {
      issues.add(issue(DraftIssueCode.zeroQuantity));
      continue;
    }
    final int net = buyQty - sellQty;
    if (net == 0) {
      issues.add(issue(DraftIssueCode.nettedOut));
      continue;
    }
    final OrderSide side = net > 0 ? OrderSide.buy : OrderSide.sell;
    final bool market = group.any((OrderTarget t) => t.marketOrder);
    final Decimal price = side == OrderSide.buy ? buyPrice : sellPrice;
    // 🆕 R259(리뷰 3차 G-U1b) — 이월 대상은 앞날 결합 id(`A+B`)를 그대로 싣는다 → 조각으로 풀어 다시 결합한다
    //    (`combined` 는 조각만 받는다 — 풀지 않으면 `+` 거부 예외로 그날 배치 전체가 실패).
    final String logical = DecisionIds.combined(
      group.expand((OrderTarget t) => t.logicalDecisionId.split('+')),
    );
    drafts.add(
      OrderIntentDraft(
        executionDate: executionDate,
        account: account,
        strategyId: strategyId,
        symbol: symbol,
        side: side,
        quantity: net.abs(),
        orderType: market ? OrderTypes.market : OrderTypes.limit,
        limitPrice: market ? null : price,
        sizingPrice: price,
        logicalDecisionId: logical,
        decisionId: DecisionIds.forExecution(logical, executionDate),
        // 갈리면 개별주(L1 을 거는 쪽).
        instrument:
            group.every((OrderTarget t) => t.instrument == InstrumentKind.etf)
            ? InstrumentKind.etf
            : InstrumentKind.stock,
      ),
    );
  }

  drafts.sort((OrderIntentDraft a, OrderIntentDraft b) {
    if (a.side != b.side) return a.side == OrderSide.sell ? -1 : 1;
    final int byAccount = a.account.compareTo(b.account);
    return byAccount != 0 ? byAccount : a.symbol.compareTo(b.symbol);
  });
  // 🔴 List.sort 는 안정 정렬이 아니다 — (계좌 · 종목)이 같은 사유(계좌를 모르는 두 전략 등)도 순서가 정해지게
  //    전략 · 사유 코드로 끝까지 가른다.
  issues.sort((DraftIssue a, DraftIssue b) {
    final int byAccount = (a.account ?? '').compareTo(b.account ?? '');
    if (byAccount != 0) return byAccount;
    final int bySymbol = a.symbol.compareTo(b.symbol);
    if (bySymbol != 0) return bySymbol;
    final int byStrategy = a.strategyIds
        .join(',')
        .compareTo(b.strategyIds.join(','));
    return byStrategy != 0 ? byStrategy : a.code.code.compareTo(b.code.code);
  });
  return DraftResult(
    List<OrderIntentDraft>.unmodifiable(drafts),
    List<DraftIssue>.unmodifiable(issues),
  );
}

DraftIssue _issue(
  DraftIssueCode code,
  String symbol,
  String? account,
  List<OrderTarget> group,
) => DraftIssue(
  code,
  symbol: symbol,
  account: account,
  strategyIds: (<String>{
    for (final OrderTarget t in group) t.strategyId,
  }.toList()..sort()),
  logicalDecisionIds: (<String>{
    for (final OrderTarget t in group) t.logicalDecisionId,
  }.toList()..sort()),
);

/// 월말 계획 행동 → 주문 대상(R34 U4). [judgmentDate] = 판정일(그 달 마지막 KR 거래일 · 논리 id 의 `{td}`).
///
/// 이체 4종(램프 · 밴드 납입 · 재분류 · 환원)은 주문이 아니라 건너뛴다. 매매 행동에 종목 · 방향이 없으면
/// [StateError](계획기 결함). [instruments] 에 없는 종목은 개별주로 본다(fail-closed).
List<OrderTarget> targetsFromMonthEnd(
  MonthEndPlan plan, {
  required TradeDate judgmentDate,
  Map<String, InstrumentKind> instruments = const <String, InstrumentKind>{},
}) {
  final List<OrderTarget> out = <OrderTarget>[];
  for (final MonthEndAction a in plan.actions) {
    final (String, String)? route = switch (a.kind) {
      MonthEndActionKind.rampContribution ||
      MonthEndActionKind.coreBandReclassify ||
      MonthEndActionKind.coreBandReclaim ||
      MonthEndActionKind.coreBandContribution => null,
      MonthEndActionKind.raiseKrw => (
        DecisionIds.pensionFunding(judgmentDate),
        P0sStrategyIds.sleeveC,
      ),
      MonthEndActionKind.sleeveBFundingSell => (
        DecisionIds.band('B', judgmentDate),
        P0sStrategyIds.sleeveB,
      ),
      MonthEndActionKind.potTrade => (
        DecisionIds.potSma(judgmentDate),
        P0sStrategyIds.pot,
      ),
      MonthEndActionKind.sleeveBOrder => (
        DecisionIds.sleeveBSma(judgmentDate),
        P0sStrategyIds.sleeveB,
      ),
      MonthEndActionKind.sleeveCOrder => (
        DecisionIds.sleeveCRebalance(judgmentDate),
        P0sStrategyIds.sleeveC,
      ),
    };
    if (route == null) continue;
    final String? symbol = a.symbol;
    final bool? isBuy = a.isBuy;
    if (symbol == null || isBuy == null) {
      throw StateError('매매 행동에 종목·방향이 없다: $a');
    }
    out.add(
      OrderTarget(
        logicalDecisionId: route.$1,
        strategyId: route.$2,
        symbol: symbol,
        side: isBuy ? OrderSide.buy : OrderSide.sell,
        sizing: AmountSizing(a.amount),
        instrument: instruments[symbol] ?? InstrumentKind.stock,
      ),
    );
  }
  return out;
}
