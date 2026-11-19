// 엔진 내부 가상 체결 브로커(`SIM_INTERNAL` · SPEC v2.44 04 §3-1 v2.44 ③ · 앱 06 X6-3 · 설계 13 §8 R83 Y3~Y7).
//
// 🔴 같은 포트(`AccountBroker`)의 구현이다 — NR-1 · 초안 · 이월 · 대사 · 체결 동기화는 실전과 **같은 코드**로 이 브로커를 부른다.
// 🔴 받은 주문 = 엔진이 원장에 쓴 행(`SimLedgerView`) — 시뮬레이터는 따로 저장하지 않는다(재시작해도 같은 주문).
// 🔴 판정 = 주문일 15:40 KST(일 마감 확인) 뒤에만 · 그날 봉으로 `virtualFillPrice` · 전량 또는 0 · 봉 없음 = 미체결 + 공백 기록.
// 🔴 현금 · 잔고 = 원장에서 셈(대사 = 구조상 0) · 판정 전 매수 주문은 예약으로 뺀다.
// 🟡 취소 기억은 메모리(재시작하면 잊고 마감에 판정 — R83 Y4 · E15c2 재검토).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;

import '../calendar/exchange_calendar.dart' show Market;
import '../data/quote_feed.dart';
import '../orders/fill_sync.dart' show kDayEndCheckAfterKst;
import '../orders/fills.dart' show DailyFillRow, brokerOrderNoOf;
import '../orders/order_path_ports.dart' show AccountBroker;
import '../orders/order_ports.dart';
import '../orders/reconcile.dart' show BrokerBalance;
import 'virtual_fill.dart';

/// 제출 거부 코드(수량 · 주문 꼴).
const String kSimInvalidOrder = 'SIM_INVALID_ORDER';

/// 취소 거부 — 모르는 주문.
const String kSimOrderNotFound = 'SIM_ORDER_NOT_FOUND';

/// 취소 거부 — 이미 판정했거나 취소했다.
const String kSimCancelTooLate = 'SIM_CANCEL_TOO_LATE';

/// 시뮬레이터 주문번호 접두.
const String kSimOdnoPrefix = 'SIM';

/// 가상 주문 가능 현금(원) — 입출금 합 + 체결(매도 = 대금 − 비용 · 매수 = −(대금 + 비용)) − 판정 전 지정가 매수 예약.
///
/// 🔴 브로커(`SimInternalBroker.orderableCashKrw`)와 보유 화면(E11q1 · 설계 13 §8 R171)이 같이 쓰는 한 셈이다.
/// [cancelled] = 이 브로커가 취소한 주문번호(예약에서 뺀다 · 메모리 — 화면 = 빈 집합 = 새 브로커와 같다).
Decimal simOrderableCashOf(
  double cashFlowSum,
  Iterable<SimExecution> executions,
  Iterable<SimOrder> openBuys, {
  Set<String> cancelled = const <String>{},
}) {
  Decimal dec(double v) => Decimal.parse('$v');
  Decimal cash = dec(cashFlowSum);
  for (final SimExecution e in executions) {
    final Decimal gross = dec(e.price) * Decimal.fromInt(e.quantity);
    final Decimal fees = dec(e.commission) + dec(e.tax);
    cash += switch (e.side) {
      OrderSide.sell => gross - fees,
      OrderSide.buy => -(gross + fees),
    };
  }
  for (final SimOrder o in openBuys) {
    final double? px = o.limitPrice;
    if (cancelled.contains(o.brokerOrderNo) || px == null) continue;
    cash -= dec(px) * Decimal.fromInt(o.quantity);
  }
  return cash;
}

/// 원장에 있는 시뮬레이터 주문 하나.
class SimOrder {
  /// 주문을 만든다.
  const SimOrder({
    required this.orderDate,
    required this.odno,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.orderType,
    required this.limitPrice,
  });

  /// 주문일.
  final TradeDate orderDate;

  /// 주문번호(원문).
  final String odno;

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 수량.
  final int quantity;

  /// `LIMIT` · `MARKET`.
  final String orderType;

  /// 지정가(시가 주문 = null).
  final double? limitPrice;

  /// `{주문일}:{주문번호}`.
  String get brokerOrderNo => brokerOrderNoOf(orderDate, odno);
}

/// 원장에 있는 체결 하나(현금 셈).
class SimExecution {
  /// 체결을 만든다.
  const SimExecution({
    required this.side,
    required this.quantity,
    required this.price,
    required this.commission,
    required this.tax,
  });

  /// 방향.
  final OrderSide side;

  /// 수량.
  final int quantity;

  /// 체결가 · 수수료 · 세금.
  final double price, commission, tax;
}

/// 시뮬레이터가 읽는 원장(계좌 하나 · 구현 = data_sync).
abstract interface class SimLedgerView {
  /// 그날 이 계좌의 시뮬레이터 주문(접수 차례).
  Future<List<SimOrder>> ordersOf(TradeDate orderDate);

  /// [brokerOrderNo] 의 주문(이 계좌 · 없으면 null).
  Future<SimOrder?> orderNo(String brokerOrderNo);

  /// 그날 원장의 시뮬레이터 주문번호 최대 순번(모든 계좌 · 없으면 0).
  Future<int> maxSimSeq(TradeDate orderDate);

  /// 이 계좌의 현금 흐름 합(입금 + · 출금 −).
  Future<double> cashFlowSum();

  /// 이 계좌의 체결.
  Future<List<SimExecution>> executions();

  /// 이 계좌의 아직 판정 안 된(접수 상태) 매수 주문.
  Future<List<SimOrder>> openBuys();

  /// 이 계좌 전략들의 보유(종목 → 수량 · 0 제외).
  Future<Map<String, int>> holdings();

  /// 그날 봉이 없어 판정 못 함(공백 기록 · 같은 날 · 종목 = 1행).
  Future<void> recordBarGap(TradeDate date, String symbol);
}

/// 🔴 엔진 내부 가상 체결 브로커(R83 Y3).
class SimInternalBroker implements AccountBroker {
  /// 브로커를 만든다.
  SimInternalBroker({
    required this._ledger,
    required this._bars,
    required this._nowUtc,
  });

  final SimLedgerView _ledger;
  final DailyQuoteFeed _bars;
  final DateTime Function() _nowUtc;

  final Map<String, Decimal?> _judged = <String, Decimal?>{};
  final Set<String> _cancelled = <String>{};
  final Map<String, int> _issued = <String, int>{};

  TradeDate _today() => TradeDate(
    _nowUtc()
        .toUtc()
        .add(const Duration(hours: 9))
        .toIso8601String()
        .substring(0, 10),
  );

  bool _judgeable(TradeDate orderDate) => !_nowUtc().toUtc().isBefore(
    DateTime.parse('${orderDate.yyyyMmDd}T00:00:00Z')
        .add(kDayEndCheckAfterKst)
        .subtract(const Duration(hours: 9)),
  );

  static Decimal? _dec(double? v) => v == null ? null : Decimal.parse('$v');

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) async {
    final bool valid =
        request.quantity > 0 &&
        (request.orderType == kVirtualMarketOrder ||
            (request.orderType == kVirtualLimitOrder &&
                request.limitPrice != null));
    if (!valid) {
      return BrokerRejected(
        code: kSimInvalidOrder,
        message: '가상 체결이 받지 않는 주문: $request',
      );
    }
    final TradeDate day = _today();
    final int seq =
        <int>[
          await _ledger.maxSimSeq(day),
          _issued[day.yyyyMmDd] ?? 0,
        ].reduce((int a, int b) => a > b ? a : b) +
        1;
    _issued[day.yyyyMmDd] = seq;
    return BrokerAccepted(
      odno: '$kSimOdnoPrefix${seq.toString().padLeft(7, '0')}',
      orderDate: day,
    );
  }

  @override
  Future<BrokerSubmitResult> cancel(String brokerOrderNo) async {
    final SimOrder? o = await _ledger.orderNo(brokerOrderNo);
    if (o == null) {
      return BrokerRejected(code: kSimOrderNotFound, message: brokerOrderNo);
    }
    if (_cancelled.contains(brokerOrderNo) || _judgeable(o.orderDate)) {
      return BrokerRejected(code: kSimCancelTooLate, message: brokerOrderNo);
    }
    _cancelled.add(brokerOrderNo);
    return BrokerAccepted(odno: o.odno, orderDate: o.orderDate);
  }

  Future<Decimal?> _judge(SimOrder o) async {
    final String key = o.brokerOrderNo;
    if (_judged.containsKey(key)) return _judged[key];
    QuoteBar? bar;
    try {
      final QuoteFetch f = await _bars.daily(
        market: Market.kr,
        symbol: o.symbol,
        kind: QuoteKind.stock,
        from: o.orderDate.yyyyMmDd,
        to: o.orderDate.yyyyMmDd,
      );
      for (final QuoteBar b in f.bars) {
        if (b.date == o.orderDate.yyyyMmDd) bar = b;
      }
    } on QuoteFeedDown {
      bar = null;
    }
    final Decimal? price = bar == null
        ? null
        : virtualFillPrice(
            side: o.side,
            orderType: o.orderType,
            limitPrice: _dec(o.limitPrice),
            open: _dec(bar.open),
            high: _dec(bar.high),
            low: _dec(bar.low),
          );
    if (bar == null || bar.open == null) {
      await _ledger.recordBarGap(o.orderDate, o.symbol);
    }
    _judged[key] = price;
    return price;
  }

  @override
  Future<List<DailyFillRow>> dailyFills(TradeDate orderDate) async {
    final bool judgeable = _judgeable(orderDate);
    final List<DailyFillRow> out = <DailyFillRow>[];
    for (final SimOrder o in await _ledger.ordersOf(orderDate)) {
      final bool cancelled = _cancelled.contains(o.brokerOrderNo);
      final Decimal? price = cancelled || !judgeable ? null : await _judge(o);
      out.add(
        DailyFillRow(
          orderDate: o.orderDate,
          odno: o.odno,
          isCancelRow: false,
          symbol: o.symbol,
          side: o.side,
          orderQty: o.quantity,
          orderPrice: _dec(o.limitPrice),
          cumFilledQty: price == null ? 0 : o.quantity,
          cumFilledAmount: price == null
              ? Decimal.zero
              : price * Decimal.fromInt(o.quantity),
          remainingQty: price != null || cancelled ? 0 : o.quantity,
          cancelConfirmedQty: cancelled ? o.quantity : 0,
        ),
      );
    }
    return out;
  }

  @override
  Future<Decimal> orderableCashKrw() async => simOrderableCashOf(
    await _ledger.cashFlowSum(),
    await _ledger.executions(),
    await _ledger.openBuys(),
    cancelled: _cancelled,
  );

  @override
  Future<BrokerBalance> balance() async => BrokerBalance(
    holdings: await _ledger.holdings(),
    cashKrw: await orderableCashKrw(),
  );
}
