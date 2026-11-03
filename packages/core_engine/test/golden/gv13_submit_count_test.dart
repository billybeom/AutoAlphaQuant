// GV-13 «발주 횟수» 부분(AC-S13 · 05 §GV-13 v1~v4) — 형식 부분은 `gv09_idempotency_test.dart`(E4).
//
// 정답지(vectors/SOURCES.md): 05 §GV-13 코드 블록 원문(`gv13_decision_id.json`). «mock — submit_order 호출 횟수를
// 센다» = 포트 수준 FakeBroker(설계 13 §8 R35 V9 · V10). 🔵 v2.38: 주문 의도의 decision_id 는 `{논리 id}@{집행일}` —
// 정답지의 `decision_id` 는 논리 id 이고, 같은 날 집행이라 접미도 같다.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import '../order_path_fixture.dart';
import 'golden_vectors.dart';

void main() {
  final Map<String, Object?> gv13 = loadVector('gv13_decision_id.json');
  final Map<String, Object?> setup = asObject(gv13['setup']);
  final TradeDate td = TradeDate(asString(setup['trade_date']));
  final String symbol = asString(setup['symbol']);
  final String account = asString(setup['account']);
  final OrderSide side = asString(setup['side']) == 'SELL'
      ? OrderSide.sell
      : OrderSide.buy;
  test('정답지 설정 — EXECUTE(dry_run false) · SELL 이라 실제 제출 경로를 탄다', () {
    expect(setup['dry_run'], isFalse);
    expect(side, OrderSide.sell);
  });
  Map<String, Object?> expectedOf(String id) => asObject(
    asObjectList(gv13['cases'])
        .firstWhere((Map<String, Object?> c) => c['id'] == id)['expected'],
  );

  OrderIntentDraft draft(String logical, String strategyId) => draftOf(
    symbol: symbol,
    side: side,
    quantity: 10,
    strategyId: strategyId,
    account: account,
    logical: logical,
    price: '9350',
    instrument: InstrumentKind.stock,
    executionDate: td,
  );

  /// 같은 결정을 [times] 번 낸다 — 반환 = INSERT 가 새 행을 만들었는가(`reserve_intent_returns`).
  Future<List<bool>> fire(
    FakeOrderLedger ledger,
    FakeOrderBroker broker,
    List<OrderIntentDraft> drafts,
  ) async => <bool>[
    for (final OrderIntentDraft d in drafts)
      (await executeIntent(d, portfolioOk(), ctxOf(ledger, broker))).status !=
          ExecutionStatus.prevented,
  ];

  test(
    'v1 — intraday_stop_watch 4회(09:35 · 09:40 · 10:15 · 14:55) → 제출 1회',
    () async {
      final Map<String, Object?> e = expectedOf('v1');
      final String strategy = asString(setup['strategy_id']);
      final String logical = DecisionIds.exit(strategy, symbol, td);
      expect(logical, asString(e['decision_id']));
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final List<OrderIntentDraft> calls = <OrderIntentDraft>[
        for (int i = 0; i < 4; i++)
          draft(DecisionIds.exit(strategy, symbol, td), strategy),
      ];
      final List<bool> reserved = await fire(ledger, broker, calls);
      expect(
        reserved,
        (e['reserve_intent_returns']! as List<Object?>).cast<bool>(),
      );
      expect(
        calls.map((OrderIntentDraft d) => d.decisionId).toSet(),
        hasLength(asInt(e['distinct_decision_ids'])),
      );
      expect(
        calls.map((OrderIntentDraft d) => d.idempotencyKey).toSet(),
        hasLength(asInt(e['distinct_idempotency_keys'])),
      );
      expect(broker.submitCount, asInt(e['broker.submit_order_call_count']));
      expect(ledger.records, hasLength(asInt(e['order_intents_row_count'])));
    },
  );

  test('v2 — TIER 1.5 발동(미체결) 뒤 TIER 1B 발동 → 같은 결정 · 제출 1회', () async {
    final Map<String, Object?> e = expectedOf('v2');
    final String strategy = asString(setup['strategy_id']);
    // TIER 는 생성기 인자가 아니다 — 두 발동이 같은 논리 id 를 낸다.
    final List<OrderIntentDraft> calls = <OrderIntentDraft>[
      draft(DecisionIds.exit(strategy, symbol, td), strategy),
      draft(DecisionIds.exit(strategy, symbol, td), strategy),
    ];
    final FakeOrderBroker broker = FakeOrderBroker();
    await fire(ledgerOf(), broker, calls);
    expect(
      calls.map((OrderIntentDraft d) => d.decisionId).toSet(),
      hasLength(asInt(e['distinct_decision_ids'])),
    );
    expect(broker.submitCount, asInt(e['broker.submit_order_call_count']));
  });

  test('v3 — 두 전략이 같은 날 같은 종목을 각각 청산 → 결정 2 · 키 2 · 제출 2', () async {
    final Map<String, Object?> e = expectedOf('v3');
    final List<OrderIntentDraft> calls = <OrderIntentDraft>[
      for (final String s in <String>['satellite_kr', 'sleeve_a_kr'])
        draft(DecisionIds.exit(s, symbol, td), s),
    ];
    final FakeOrderBroker broker = FakeOrderBroker();
    await fire(ledgerOf(), broker, calls);
    expect(
      calls.map((OrderIntentDraft d) => d.decisionId).toSet(),
      hasLength(asInt(e['distinct_decision_ids'])),
    );
    expect(
      calls.map((OrderIntentDraft d) => d.idempotencyKey).toSet(),
      hasLength(asInt(e['distinct_idempotency_keys'])),
    );
    expect(broker.submitCount, asInt(e['broker.submit_order_call_count']));
  });

  test('v4 — 월간 교체 배치를 같은 날 2회 → 제출 1회', () async {
    final Map<String, Object?> e = expectedOf('v4');
    final String logical = DecisionIds.satelliteRotation(td);
    expect(logical, asString(e['decision_id']));
    final FakeOrderBroker broker = FakeOrderBroker();
    final FakeOrderLedger ledger = ledgerOf();
    for (int run = 0; run < 2; run++) {
      await runOrderBatch(
        <OrderIntentDraft>[draft(logical, asString(setup['strategy_id']))],
        brokers: <String, OrderBroker>{account: broker},
        ledger: ledger,
        limitStateFor: (OrderIntentDraft d) async => portfolioOk(),
        limitConfig: kLimitConfig,
        buyCostRate: 0.00015,
        execPolicy: ExecPolicy.execute,
        operatingMode: OperatingMode.autoTrade,
        configHash: 'cfg-test',
      );
    }
    expect(broker.submitCount, asInt(e['broker.submit_order_call_count']));
    expect(Decimal.parse('9350'), broker.submitted.single.limitPrice);
  });
}
