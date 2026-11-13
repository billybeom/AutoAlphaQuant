// 🆕 E15c1 — 엔진 내부 가상 체결 브로커(설계 13 §8 R83 Y3~Y7 · SPEC v2.44 04 §3-1 v2.44 ③).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _day = TradeDate('2026-11-02');

class _Ledger implements SimLedgerView {
  final List<SimOrder> orders = <SimOrder>[];
  final List<SimExecution> fills = <SimExecution>[];
  final List<SimOrder> open = <SimOrder>[];
  final Map<String, int> held = <String, int>{};
  final List<(String, String)> gaps = <(String, String)>[];
  int maxSeq = 0;
  double flows = 0;

  @override
  Future<List<SimOrder>> ordersOf(TradeDate orderDate) async => <SimOrder>[
    for (final SimOrder o in orders)
      if (o.orderDate == orderDate) o,
  ];

  @override
  Future<SimOrder?> orderNo(String brokerOrderNo) async {
    for (final SimOrder o in orders) {
      if (o.brokerOrderNo == brokerOrderNo) return o;
    }
    return null;
  }

  @override
  Future<int> maxSimSeq(TradeDate orderDate) async => maxSeq;

  @override
  Future<double> cashFlowSum() async => flows;

  @override
  Future<List<SimExecution>> executions() async => fills;

  @override
  Future<List<SimOrder>> openBuys() async => open;

  @override
  Future<Map<String, int>> holdings() async => held;

  @override
  Future<void> recordBarGap(TradeDate date, String symbol) async =>
      gaps.add((date.yyyyMmDd, symbol));
}

class _Bars implements DailyQuoteFeed {
  final Map<String, QuoteBar> bars = <String, QuoteBar>{};
  final Set<String> down = <String>{};
  final List<String> calls = <String>[];

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async {
    calls.add('$symbol $from $to ${market.name} ${kind.name} ${adjust.name}');
    if (down.contains(symbol)) {
      throw const QuoteFeedDown('HTTP 503', attempts: 4);
    }
    final QuoteBar? b = bars[symbol];
    return QuoteFetch(
      bars: <QuoteBar>[
        // 다른 날 봉이 섞여도 그날 봉만 쓴다.
        QuoteBar(date: '2026-11-01', close: 1, open: 1, high: 1, low: 1),
        ?b,
      ],
      pageBodies: const <String>[],
      attempts: 1,
    );
  }
}

SimOrder _order(
  String odno,
  String symbol, {
  OrderSide side = OrderSide.buy,
  int qty = 5,
  String type = kVirtualLimitOrder,
  double? limit = 1000,
  TradeDate day = _day,
}) => SimOrder(
  orderDate: day,
  odno: odno,
  symbol: symbol,
  side: side,
  quantity: qty,
  orderType: type,
  limitPrice: limit,
);

// 2026-11-02 KST 시각 → UTC.
DateTime _kst(int h, int m) => DateTime.utc(2026, 11, 2, h - 9, m);

void main() {
  late _Ledger ledger;
  late _Bars bars;
  late DateTime now;
  late SimInternalBroker broker;

  setUp(() {
    ledger = _Ledger();
    bars = _Bars();
    now = _kst(9, 10);
    broker = SimInternalBroker(ledger: ledger, bars: bars, nowUtc: () => now);
  });

  BrokerOrderRequest req({
    int qty = 5,
    String type = kVirtualLimitOrder,
    String? limit = '1000',
  }) => BrokerOrderRequest(
    symbol: 'A',
    side: OrderSide.buy,
    quantity: qty,
    orderType: type,
    limitPrice: limit == null ? null : Decimal.parse(limit),
  );

  group('제출(Y7)', () {
    test('수량 0 · 지정가 없는 지정가 · 모르는 꼴 = 거부 코드', () async {
      for (final BrokerOrderRequest r in <BrokerOrderRequest>[
        req(qty: 0),
        req(limit: null),
        req(type: 'STOP'),
      ]) {
        final BrokerSubmitResult res = await broker.submit(r);
        expect((res as BrokerRejected).code, kSimInvalidOrder);
      }
      expect(
        await broker.submit(req(type: kVirtualMarketOrder, limit: null)),
        isA<BrokerAccepted>(),
      );
    });

    test('주문번호 = SIM 7자리 · 원장 최대 다음 · 메모리로도 이어감 · 주문일 = KST 날짜', () async {
      ledger.maxSeq = 5;
      final BrokerAccepted a = await broker.submit(req()) as BrokerAccepted;
      final BrokerAccepted b = await broker.submit(req()) as BrokerAccepted;
      expect((a.odno, b.odno), ('SIM0000006', 'SIM0000007'));
      expect(a.orderDate, _day);
      ledger.maxSeq = 9;
      expect(
        ((await broker.submit(req())) as BrokerAccepted).odno,
        'SIM0000010',
      );
      now = DateTime.utc(2026, 11, 1, 15, 30); // KST 11-02 00:30
      expect(((await broker.submit(req())) as BrokerAccepted).orderDate, _day);
      now = DateTime.utc(2026, 11, 1, 14, 59); // KST 11-01 23:59
      final BrokerAccepted prev = await broker.submit(req()) as BrokerAccepted;
      expect(
        (prev.orderDate, prev.odno),
        (const TradeDate('2026-11-01'), 'SIM0000010'),
      );
    });
  });

  group('판정(Y3)', () {
    test('15:40 앞 = 미판정(누적 0 · 잔여 = 수량) · 봉을 묻지 않는다', () async {
      ledger.orders.add(_order('SIM0000001', 'A'));
      bars.bars['A'] = const QuoteBar(
        date: '2026-11-02',
        close: 950,
        open: 900,
        high: 1000,
        low: 890,
      );
      now = _kst(15, 39);
      final DailyFillRow r = (await broker.dailyFills(_day)).single;
      expect(
        (r.odno, r.cumFilledQty, r.remainingQty, r.cancelConfirmedQty),
        ('SIM0000001', 0, 5, 0),
      );
      expect(r.cumFilledAmount, Decimal.zero);
      expect(bars.calls, isEmpty);
    });

    test(
      '15:40 뒤 = 당일 봉 · 시가 · 지정가 · 미체결 · 매도 · 시가 주문 · 금액 = 가격 × 수량 · 한 번만 묻는다',
      () async {
        ledger.orders.addAll(<SimOrder>[
          _order('SIM0000001', 'A'),
          _order('SIM0000002', 'B'),
          _order('SIM0000003', 'C'),
          _order('SIM0000004', 'D', side: OrderSide.sell, qty: 3, limit: 2000),
          _order('SIM0000005', 'E', type: kVirtualMarketOrder, limit: null),
        ]);
        bars.bars
          ..['A'] = const QuoteBar(
            date: '2026-11-02',
            close: 1,
            open: 900,
            high: 1000,
            low: 890,
          )
          ..['B'] = const QuoteBar(
            date: '2026-11-02',
            close: 1,
            open: 1100,
            high: 1200,
            low: 990,
          )
          ..['C'] = const QuoteBar(
            date: '2026-11-02',
            close: 1,
            open: 1100,
            high: 1200,
            low: 1001,
          )
          ..['D'] = const QuoteBar(
            date: '2026-11-02',
            close: 1,
            open: 1900,
            high: 2100,
            low: 1800,
          )
          ..['E'] = const QuoteBar(
            date: '2026-11-02',
            close: 1,
            open: 777,
            high: 800,
            low: 700,
          );
        now = _kst(15, 40);
        List<DailyFillRow> rows = await broker.dailyFills(_day);
        expect(
          <(String, int, int, Decimal)>[
            for (final DailyFillRow r in rows)
              (r.odno, r.cumFilledQty, r.remainingQty, r.cumFilledAmount),
          ],
          <(String, int, int, Decimal)>[
            ('SIM0000001', 5, 0, Decimal.parse('4500')),
            ('SIM0000002', 5, 0, Decimal.parse('5000')),
            ('SIM0000003', 0, 5, Decimal.zero),
            ('SIM0000004', 3, 0, Decimal.parse('6000')),
            ('SIM0000005', 5, 0, Decimal.parse('3885')),
          ],
        );
        expect(rows.first.orderPrice, Decimal.parse('1000'));
        expect(rows.last.orderPrice, isNull);
        expect(rows.first.brokerOrderNo, '2026-11-02:SIM0000001');
        expect(bars.calls.first, 'A 2026-11-02 2026-11-02 kr stock raw');
        bars.bars['A'] = const QuoteBar(
          date: '2026-11-02',
          close: 1,
          open: 5000,
          high: 5000,
          low: 5000,
        );
        rows = await broker.dailyFills(_day);
        expect(rows.first.cumFilledQty, 5);
        expect(bars.calls, hasLength(5));
        expect(ledger.gaps, isEmpty);
      },
    );

    test('🔴 봉 없음 · 원천 장애 · 시가 빠짐 = 미체결 + 공백 기록(지어내지 않는다)', () async {
      ledger.orders.addAll(<SimOrder>[
        _order('SIM0000001', 'A'),
        _order('SIM0000002', 'B'),
        _order('SIM0000003', 'C'),
      ]);
      bars.down.add('B');
      bars.bars['C'] = const QuoteBar(
        date: '2026-11-02',
        close: 900,
        low: 800,
        high: 950,
      );
      now = _kst(16, 0);
      final List<DailyFillRow> rows = await broker.dailyFills(_day);
      expect(
        rows.map((DailyFillRow r) => (r.cumFilledQty, r.remainingQty)),
        <(int, int)>[(0, 5), (0, 5), (0, 5)],
      );
      expect(ledger.gaps, <(String, String)>[
        ('2026-11-02', 'A'),
        ('2026-11-02', 'B'),
        ('2026-11-02', 'C'),
      ]);
    });
  });

  group('취소(Y4)', () {
    test(
      '판정 전 = 받음 → 원주문 행 잔여 0 · 취소 확인 = 수량(봉 안 봄) · 다시 · 판정 뒤 · 모르는 번호 = 거부',
      () async {
        ledger.orders.addAll(<SimOrder>[
          _order('SIM0000001', 'A'),
          _order('SIM0000002', 'B'),
        ]);
        expect(
          ((await broker.cancel(
            '2026-11-02:SIM0000009',
          )) as BrokerRejected).code,
          kSimOrderNotFound,
        );
        final BrokerAccepted ok =
            await broker.cancel('2026-11-02:SIM0000001') as BrokerAccepted;
        expect((ok.odno, ok.orderDate), ('SIM0000001', _day));
        expect(
          ((await broker.cancel(
            '2026-11-02:SIM0000001',
          )) as BrokerRejected).code,
          kSimCancelTooLate,
        );
        bars.bars['B'] = const QuoteBar(
          date: '2026-11-02',
          close: 1,
          open: 900,
          high: 900,
          low: 900,
        );
        now = _kst(15, 40);
        expect(
          ((await broker.cancel(
            '2026-11-02:SIM0000002',
          )) as BrokerRejected).code,
          kSimCancelTooLate,
        );
        final List<DailyFillRow> rows = await broker.dailyFills(_day);
        expect(
          (
            rows[0].cumFilledQty,
            rows[0].remainingQty,
            rows[0].cancelConfirmedQty,
          ),
          (0, 0, 5),
        );
        expect(rows[1].cumFilledQty, 5);
        expect(bars.calls, hasLength(1));
      },
    );
  });

  group('현금 · 잔고(Y5)', () {
    test('흐름 + 매도(금액 − 비용) − 매수(금액 + 비용) − 판정 전 매수 예약(취소 · 시가 주문 제외) · 잔고 = 보유 + 같은 현금', () async {
      ledger.flows = 1000000;
      ledger.fills.addAll(const <SimExecution>[
        SimExecution(
          side: OrderSide.sell,
          quantity: 10,
          price: 1000,
          commission: 5,
          tax: 2,
        ),
        SimExecution(
          side: OrderSide.buy,
          quantity: 5,
          price: 2000,
          commission: 3,
          tax: 0,
        ),
      ]);
      ledger.orders.add(_order('SIM0000001', 'A', qty: 2, limit: 1500));
      ledger.open.addAll(<SimOrder>[
        _order('SIM0000001', 'A', qty: 2, limit: 1500),
        _order('SIM0000002', 'B', qty: 4, limit: 100),
        _order('SIM0000003', 'C', type: kVirtualMarketOrder, limit: null),
      ]);
      ledger.orders.add(_order('SIM0000002', 'B', qty: 4, limit: 100));
      ledger.held['A'] = 7;
      // 1,000,000 + (10,000 − 7) − (10,000 + 3) − 3,000 − 400
      expect(await broker.orderableCashKrw(), Decimal.parse('996590'));
      await broker.cancel('2026-11-02:SIM0000002');
      expect(await broker.orderableCashKrw(), Decimal.parse('996990'));
      final BrokerBalance b = await broker.balance();
      expect(b.holdings, <String, int>{'A': 7});
      expect(b.cashKrw, Decimal.parse('996990'));
    });
  });
}
