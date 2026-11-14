// 한도 판정 입력(E11p3b-2 · 설계 13 §8 R91 · 정본 = 02 §2 `PortfolioState` · 04 §1 SAF-301 · 303 · 304 · 403 · NR-4).
//
// 🔴 SPEC 은 칸만 정했다(산식 없음) → R91 정의(보수적 · 잴 수 있는 것만):
//    · 총자산 = Σ(보유 수량 × 현재가) + 주문 가능 현금(계좌 합 — `equity_snapshot` 과 같은 축).
//    · 오늘 손익률(SAF-403) = (총자산 − 전일 평가 − 오늘 입출금) / (전일 평가 + 오늘 입출금)
//      — 입출금은 하루 시작에 들어온 것으로 본다(입금은 손익이 아니다). 전일 평가 = 오늘 앞 마지막 `equity_snapshot`,
//      없으면 오늘 앞 입출금 합(원가). 분모 ≤ 0 = 모름(null → 매수 거부).
//    · 위험자산 익스포저(SAF-301) = (위험 종목 평가액 ± 이 주문 금액) / 총자산 — 위험 종목 = 설정이 준다(P0S = 주식 ETF).
//    · 레버리지(SAF-303) = (보유 평가액 ± 이 주문 금액) / 총자산 — 현금 계좌라 매수가 현금 안이면 1 이하.
//    · 동시 보유 종목 수(SAF-304) = 수량 > 0 종목 수 + (새 종목 매수면 1).
// 🔴 잴 수 없으면 던진다(보유 종목 현재가 없음 · 총자산 ≤ 0) — 주문 배치가 받아 «잴 수 없음»(전부 null)으로 태우고
//    4단계가 RISK_UNAVAILABLE 로 거부한다(fail-closed · 기본값 · 직전값 금지 02 §2 v1.5).
// 🔵 배치 안 앞 주문의 영향은 더하지 않는다(주문마다 독립 — P0S 는 한도에서 멀다 · 체결 전 보유는 그대로).
// 🔵 오늘 낸 주문 수 · 전략 등록 · 차단 · 일지 · 계층 B 칸은 주문 경로가 원장에서 덮어쓴다(execute_intent 4단계) — 여기는 null.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;

import '../risk/limits.dart' show LimitState;
import 'order_draft.dart' show OrderIntentDraft;
import 'order_ports.dart' show OrderBroker;
import 'reconcile.dart' show LedgerHolding;

/// 배치 한 번의 한도 원재료(R91).
class LimitInputs {
  /// 만든다.
  LimitInputs({
    required List<LedgerHolding> holdings,
    required Map<String, Decimal> prices,
    required this.cashKrw,
    required this.previousEquity,
    required this.flowsToday,
    required Set<String> riskSymbols,
  }) : holdings = List<LedgerHolding>.unmodifiable(holdings),
       prices = Map<String, Decimal>.unmodifiable(prices),
       riskSymbols = Set<String>.unmodifiable(riskSymbols);

  /// 원장 보유(KR).
  final List<LedgerHolding> holdings;

  /// 현재가(보유 종목 전부가 있어야 한다).
  final Map<String, Decimal> prices;

  /// 주문 가능 현금 합(원).
  final Decimal cashKrw;

  /// 전일 평가(원) — 오늘 앞 마지막 평가, 없으면 오늘 앞 입출금 합 · 둘 다 없으면 0.
  final Decimal previousEquity;

  /// 오늘 입출금 합(입금 +).
  final Decimal flowsToday;

  /// 위험 종목.
  final Set<String> riskSymbols;

  Map<String, int> get _qty {
    final Map<String, int> q = <String, int>{};
    for (final LedgerHolding h in holdings) {
      q[h.symbol] = (q[h.symbol] ?? 0) + h.quantity;
    }
    q.removeWhere((String _, int n) => n == 0);
    return q;
  }
}

/// 한도 입력을 잴 수 없다.
class LimitInputsUnavailable implements Exception {
  /// 만든다.
  const LimitInputsUnavailable(this.reason);

  /// 까닭(부품 이름 · 종목).
  final String reason;

  @override
  String toString() => 'LimitInputsUnavailable: $reason';
}

double _ratio(Decimal a, Decimal b) => (a / b).toDouble();

/// 🔴 [d] 하나의 한도 입력(R91) — 잴 수 없으면 [LimitInputsUnavailable].
LimitState limitStateOf(LimitInputs x, OrderIntentDraft d) {
  final Map<String, int> qty = x._qty;
  Decimal held = Decimal.zero;
  Decimal risky = Decimal.zero;
  for (final MapEntry<String, int> e in qty.entries) {
    final Decimal? p = x.prices[e.key];
    if (p == null || p <= Decimal.zero) {
      throw LimitInputsUnavailable('현재가 없음: ${e.key}');
    }
    final Decimal v = Decimal.fromInt(e.value) * p;
    held += v;
    if (x.riskSymbols.contains(e.key)) {
      risky += v;
    }
  }
  final Decimal equity = held + x.cashKrw;
  if (equity <= Decimal.zero) {
    throw const LimitInputsUnavailable('총자산 0 이하');
  }
  final Decimal order = Decimal.fromInt(d.quantity) * d.sizingPrice;
  final bool buy = d.side == OrderSide.buy;
  final Decimal signed = buy ? order : -order;
  final Decimal base = x.previousEquity + x.flowsToday;
  final Decimal riskAfter = x.riskSymbols.contains(d.symbol)
      ? risky + signed
      : risky;
  final Decimal heldAfter = held + signed;
  return LimitState(
    totalEquity: equity,
    ordersToday: null,
    riskExposureAfter: _ratio(
      riskAfter < Decimal.zero ? Decimal.zero : riskAfter,
      equity,
    ),
    leverageAfter: _ratio(
      heldAfter < Decimal.zero ? Decimal.zero : heldAfter,
      equity,
    ),
    positionsAfter: qty.length + (buy && !qty.containsKey(d.symbol) ? 1 : 0),
    satellitePositionsAfter: null,
    satelliteSectorCountAfter: null,
    satelliteAllocation: null,
    satelliteExposure: null,
    satelliteDeployedBefore: null,
    dailyPnlPct: base <= Decimal.zero
        ? null
        : _ratio(equity - x.previousEquity - x.flowsToday, base),
    fxRateUsdKrw: null,
    strategyRegistered: null,
    tradingBlocked: null,
    journalMissing: null,
    tierBUnjudged: null,
  );
}

/// 원장 사실(REAL 칸 그대로 · 원 단위) — 전일 평가 · 입출금.
class LimitLedgerFacts {
  /// 만든다.
  const LimitLedgerFacts({
    required this.previousSnapshotEquity,
    required this.flowsBefore,
    required this.flowsToday,
  });

  /// 그날 앞 마지막 `equity_snapshot.total_equity`(없으면 null).
  final double? previousSnapshotEquity;

  /// 그날 앞 입출금 합(입금 +).
  final double flowsBefore;

  /// 그날 입출금 합(입금 +).
  final double flowsToday;
}

/// 원장 사실 원천(data_sync `SqliteLimitLedgerFacts`).
abstract interface class LimitLedgerFactsSource {
  /// [day] 의 사실 — 못 읽으면 던진다.
  LimitLedgerFacts factsFor(TradeDate day);
}

/// 현재가(없으면 null — 정지 · 조회 실패 아님).
typedef LimitCurrentPrice = Future<Decimal?> Function(String symbol);

Decimal _fromReal(double v) {
  if (!v.isFinite) throw LimitInputsUnavailable('금액이 유한하지 않다: $v');
  return Decimal.parse(v.toString());
}

/// 🔴 한도 입력 모으기(R91) — 배치 날 하나에 한 번 모으고 그날 주문마다 같은 원재료를 쓴다.
///
/// 원재료: 보유 = 원장 · 현재가 = 주입(KIS · 조립) · 현금 = 계좌마다 `orderableCashKrw`(`equity_snapshot` 과 같은 축) ·
/// 전일 평가 = 그날 앞 마지막 평가(없으면 그날 앞 입출금 합 = 원가) · 오늘 입출금. 무엇 하나 못 읽으면 던진다
/// (주문 배치가 «잴 수 없음»으로 태워 4단계가 거부한다 · 실패한 날은 다음에 다시 모은다).
class LimitInputsCollector {
  /// 만든다 — [cash] = 계좌 별칭 → 브로커 · [riskSymbols] = 설정(P0S `P0sOpsConfig.riskSymbols`).
  LimitInputsCollector({
    required this._holdings,
    required Map<String, OrderBroker> cash,
    required this._price,
    required Set<String> riskSymbols,
    required this._ledger,
  }) : _cash = Map<String, OrderBroker>.unmodifiable(cash),
       _risk = Set<String>.unmodifiable(riskSymbols) {
    if (cash.isEmpty) throw ArgumentError('현금 계좌가 없다');
  }

  final Future<List<LedgerHolding>> Function() _holdings;
  final Map<String, OrderBroker> _cash;
  final LimitCurrentPrice _price;
  final Set<String> _risk;
  final LimitLedgerFactsSource _ledger;
  final Map<String, Future<LimitInputs>> _byDay =
      <String, Future<LimitInputs>>{};

  /// 🔴 주문 하나의 한도 입력(`KrOrderJobs.limitStateFor` 자리).
  Future<LimitState> stateFor(OrderIntentDraft d) async =>
      limitStateOf(await inputsFor(d.executionDate), d);

  /// [day] 의 원재료.
  Future<LimitInputs> inputsFor(TradeDate day) {
    final String k = day.yyyyMmDd;
    final Future<LimitInputs>? have = _byDay[k];
    if (have != null) return have;
    final Future<LimitInputs> f = _collect(day);
    _byDay[k] = f;
    f.then<void>(
      (_) {},
      onError: (Object _) {
        _byDay.remove(k);
      },
    );
    return f;
  }

  Future<LimitInputs> _collect(TradeDate day) async {
    final List<LedgerHolding> held = await _holdings();
    final Map<String, Decimal> prices = <String, Decimal>{};
    final Set<String> symbols = <String>{
      for (final LedgerHolding h in held)
        if (h.quantity != 0) h.symbol,
    };
    for (final String s in symbols.toList()..sort()) {
      final Decimal? p = await _price(s);
      if (p != null) prices[s] = p;
    }
    Decimal cash = Decimal.zero;
    for (final String a in _cash.keys.toList()..sort()) {
      cash += await _cash[a]!.orderableCashKrw();
    }
    final LimitLedgerFacts f = _ledger.factsFor(day);
    final double? snap = f.previousSnapshotEquity;
    return LimitInputs(
      holdings: held,
      prices: prices,
      cashKrw: cash,
      previousEquity: _fromReal(snap ?? f.flowsBefore),
      flowsToday: _fromReal(f.flowsToday),
      riskSymbols: _risk,
    );
  }
}
