// `kr_order` 2단계 배치 · 예수금 비례 축소(04 §3-4 v2.38 · 설계 13 §8 R33 D10 · R35 V8).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'order_path_fixture.dart';

Decimal _d(String s) => Decimal.parse(s);

/// 제출 · 예수금 조회를 한 줄로 기록하는 가짜.
class _LoggingBroker extends FakeOrderBroker {
  _LoggingBroker(this.log, {super.script, super.cashKrw, super.cashError});

  final List<String> log;

  @override
  Future<BrokerSubmitResult> submit(BrokerOrderRequest request) {
    log.add(
      'submit ${request.symbol} ${request.side.wire} ${request.quantity}',
    );
    return super.submit(request);
  }

  @override
  Future<Decimal> orderableCashKrw() {
    log.add('cash');
    return super.orderableCashKrw();
  }
}

Future<BatchOutcome> _run(
  List<OrderIntentDraft> drafts,
  Map<String, OrderBroker> brokers, {
  FakeOrderLedger? ledger,
  Future<LimitState> Function(OrderIntentDraft)? limitStateFor,
  LeaseGate? lease,
}) => runOrderBatch(
  drafts,
  brokers: brokers,
  ledger: ledger ?? ledgerOf(),
  limitStateFor: limitStateFor ?? (OrderIntentDraft d) async => portfolioOk(),
  limitConfig: kLimitConfig,
  buyCostRate: 0,
  execPolicy: ExecPolicy.execute,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg-test',
  lease: lease ?? FakeLeaseGate(),
);

void main() {
  group('예수금 비례 축소(fitBuysToCash)', () {
    final List<OrderIntentDraft> buys = <OrderIntentDraft>[
      draftOf(symbol: 'A', quantity: 10, price: '1000', logical: 'L-A'),
      draftOf(symbol: 'B', quantity: 4, price: '2500', logical: 'L-B'),
    ];

    test('예수금이 넉넉하면 그대로 · 경계(필요액 = 예수금)도 그대로', () {
      CashFit f = fitBuysToCash(buys, _d('30000'), 0);
      expect(f.fitted.map((OrderIntentDraft d) => d.quantity), <int>[10, 4]);
      expect(f.shortfalls, isEmpty);
      f = fitBuysToCash(buys, _d('20000'), 0); // 10×1000 + 4×2500
      expect(f.fitted.map((OrderIntentDraft d) => d.quantity), <int>[10, 4]);
    });

    test('모자라면 수량 × 예수금 ÷ 필요액 을 내림 — 비중을 지킨다', () {
      final CashFit f = fitBuysToCash(buys, _d('10000'), 0); // 절반
      expect(
        f.fitted.map((OrderIntentDraft d) => (d.symbol, d.quantity)),
        <(String, int)>[('A', 5), ('B', 2)],
      );
      expect(
        f.shortfalls.map(
          (CashShortfall s) => (s.draft.symbol, s.missingQuantity),
        ),
        <(String, int)>[('A', 5), ('B', 2)],
      );
      // 결정 id · 멱등키는 그대로다.
      expect(f.fitted.first.idempotencyKey, buys.first.idempotencyKey);
    });

    test('비용률이 필요액에 들어간다', () {
      expect(fitBuysToCash(buys, _d('20000'), 0.01).shortfalls, isNotEmpty);
    });

    test('0주가 된 매수는 내지 않고 부족분으로만 보고 · 예수금 0 이하 = 전부 0', () {
      CashFit f = fitBuysToCash(buys, _d('1500'), 0);
      expect(f.fitted.map((OrderIntentDraft d) => d.symbol), <String>[]);
      expect(f.shortfalls.map((CashShortfall s) => s.fittedQuantity), <int>[
        0,
        0,
      ]);
      f = fitBuysToCash(buys, Decimal.zero, 0);
      expect(f.fitted, isEmpty);
      expect(f.shortfalls, hasLength(2));
      f = fitBuysToCash(buys, _d('-1'), 0);
      expect(f.fitted, isEmpty);
    });

    test('매도가 섞이면 거절', () {
      expect(
        () => fitBuysToCash(
          <OrderIntentDraft>[draftOf(side: OrderSide.sell)],
          _d('1'),
          0,
        ),
        throwsArgumentError,
      );
    });

    test('수량 사본은 1주 이상만 · 결정 id 는 그대로', () {
      final OrderIntentDraft d = draftOf(quantity: 10);
      expect(d.withQuantity(3).quantity, 3);
      expect(d.withQuantity(3).decisionId, d.decisionId);
      expect(() => d.withQuantity(0), throwsArgumentError);
    });
  });

  group('배치(runOrderBatch)', () {
    test('계좌마다 ① 매도 → ② 예수금 → ③ 매수(축소)', () async {
      final List<String> log = <String>[];
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[
          draftOf(symbol: 'A', quantity: 10, price: '1000', logical: 'L-A'),
          draftOf(
            symbol: 'S',
            side: OrderSide.sell,
            quantity: 3,
            price: '1000',
            logical: 'L-S',
          ),
          draftOf(symbol: 'B', quantity: 4, price: '2500', logical: 'L-B'),
        ],
        <String, OrderBroker>{
          'pension': _LoggingBroker(log, cashKrw: _d('10000')),
        },
      );
      expect(log, <String>[
        'submit S SELL 3',
        'cash',
        'submit A BUY 5',
        'submit B BUY 2',
      ]);
      expect(o.shortfalls.map((CashShortfall s) => s.draft.symbol), <String>[
        'A',
        'B',
      ]);
      expect(
        o.outcomes.map((ExecutionOutcome e) => e.status),
        everyElement(ExecutionStatus.submitted),
      );
      expect(o.unknowns, isEmpty);
      expect(o.alertCodes, isEmpty);
    });

    test('계좌별로 따로 — 다른 계좌의 예수금을 쓰지 않는다', () async {
      final List<String> pension = <String>[];
      final List<String> general = <String>[];
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[
          draftOf(symbol: 'P', quantity: 10, price: '1000', logical: 'L-P'),
          draftOf(
            symbol: 'G',
            quantity: 10,
            price: '1000',
            logical: 'L-G',
            account: 'general',
            strategyId: P0sStrategyIds.sleeveC,
          ),
        ],
        <String, OrderBroker>{
          'pension': _LoggingBroker(pension, cashKrw: _d('100000')),
          'general': _LoggingBroker(general, cashKrw: _d('5000')),
        },
      );
      expect(pension, <String>['cash', 'submit P BUY 10']);
      expect(general, <String>['cash', 'submit G BUY 5']);
      expect(o.shortfalls.single.draft.symbol, 'G');
    });

    test('브로커가 없는 계좌 = 보류(BROKER_UNMAPPED) · 원장 행 0', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[draftOf(account: 'isa')],
        <String, OrderBroker>{},
        ledger: ledger,
      );
      expect(o.held.single.$2, 'BROKER_UNMAPPED');
      expect(ledger.records, isEmpty);
    });

    test('예수금을 못 읽으면 그 계좌 매수는 보류(CASH_UNAVAILABLE) — 매도는 이미 냈다', () async {
      final List<String> log = <String>[];
      final FakeOrderLedger ledger = ledgerOf();
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[
          draftOf(symbol: 'S', side: OrderSide.sell, logical: 'L-S'),
          draftOf(symbol: 'A', logical: 'L-A'),
        ],
        <String, OrderBroker>{
          'pension': _LoggingBroker(log, cashError: StateError('잔고 조회 실패')),
        },
        ledger: ledger,
      );
      expect(log, <String>['submit S SELL 5', 'cash']);
      expect(o.held.single.$1.symbol, 'A');
      expect(o.held.single.$2, 'CASH_UNAVAILABLE');
      expect(ledger.records, hasLength(1));
    });

    test('결과 불명은 그 의도만 멈춘다 — 배치는 이어 가고 알림 코드는 한 번', () async {
      final List<String> log = <String>[];
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[
          draftOf(symbol: 'S1', side: OrderSide.sell, logical: 'L-1'),
          draftOf(symbol: 'S2', side: OrderSide.sell, logical: 'L-2'),
          draftOf(symbol: 'S3', side: OrderSide.sell, logical: 'L-3'),
        ],
        <String, OrderBroker>{
          'pension': _LoggingBroker(
            log,
            script: <FakeSubmitStep>[
              const FakeUnknown(),
              const FakeUnknown(),
              const FakeReject('40580000', '장종료'),
            ],
          ),
        },
      );
      expect(log, hasLength(3));
      expect(o.unknowns, hasLength(2));
      expect(o.outcomes.single.message, '40580000: 장종료');
      expect(o.alertCodes, <String>{
        AlertCodes.orderOutcomeUnknown,
        AlertCodes.orderRejected,
      });
    });

    test('한도 입력을 못 재면 그 의도는 RISK_UNAVAILABLE 로 거부 · 행이 남는다', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[draftOf(side: OrderSide.sell)],
        <String, OrderBroker>{'pension': FakeOrderBroker()},
        ledger: ledger,
        limitStateFor: (OrderIntentDraft d) async => throw StateError('평가 실패'),
      );
      expect(o.outcomes.single.status, ExecutionStatus.rejected);
      expect(o.outcomes.single.message, startsWith('RISK_UNAVAILABLE'));
      expect(ledger.records.values.single.status, IntentStatus.rejected);
    });

    test('같은 종목 · 전략의 다음 의도는 2.5 단계가 막는다(배치 안에서도)', () async {
      final FakeOrderBroker broker = FakeOrderBroker(
        script: <FakeSubmitStep>[const FakeUnknown()],
      );
      final BatchOutcome o = await _run(
        <OrderIntentDraft>[
          draftOf(side: OrderSide.sell, logical: 'L-1'),
          draftOf(logical: 'L-2'),
        ],
        <String, OrderBroker>{'pension': broker},
      );
      expect(broker.submitCount, 1);
      expect(o.outcomes.single.message, startsWith('UNKNOWN_UNRESOLVED'));
    });
  });
}
