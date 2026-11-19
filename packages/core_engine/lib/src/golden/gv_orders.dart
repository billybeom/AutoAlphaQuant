// 골든벡터 GV-8 · 9 · 13 · 30(사이징 · 멱등 · 발주 횟수 · 분할 집행) 판정(E11o-b · 설계 13 §8 R163).
//
// 🔴 옛 시험(`test/golden/gv08 · gv09 · gv13 · gv30_*_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다 — 시험은 이제
//    이 케이스를 부른다(시험 = 폰 같은 판정 · 두 벌 0). 허용오차를 넓히지 않는다(GV-8a = 1 ULP 로 binding 이 뒤집힌 실측).
// 🔴 GV-13 «발주 횟수» = 05 §GV-13 «mock — submit_order 호출 횟수를 센다» — 엔진의 결정론 가짜(브로커 · 원장 · 리스)로만
//    돈다(실제 브로커 0 · `src/testing/` 을 import 하는 lib = 여기와 `testing.dart` 뿐 · 경계 시험).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../calendar/exchange_calendar.dart' show Market;
import '../calendar/frozen_calendar.dart' show frozenExchangeCalendar;
import '../decimal_rules.dart' show divide, mulDiv, multiply, promoteRatio;
import '../orders/execute_intent.dart' show ExecutionStatus, executeIntent;
import '../orders/idempotency.dart'
    show DecisionIds, idempotencyKey, idempotencyRaw;
import '../orders/order_batch.dart' show runOrderBatch;
import '../orders/order_draft.dart' show OrderIntentDraft;
import '../orders/order_ports.dart' show OrderBroker;
import '../orders/split_execution.dart'
    show SplitDay, seasonalExecutionDays, splitDay;
import '../risk/limits.dart' show InstrumentKind;
import '../risk/position_sizing.dart' show SizingResult, sizePosition;
import '../testing/fake_lease_gate.dart' show FakeLeaseGate;
import '../testing/fake_order_broker.dart' show FakeOrderBroker;
import '../testing/fake_order_ledger.dart' show FakeOrderLedger;
import '../testing/order_path_fixture.dart'
    show ctxOf, draftOf, kLimitConfig, ledgerOf, portfolioOk;
import 'golden_runner.dart';

/// GV-8 이중 상한 사이징(05 §GV-8 8a~8f · 03 §3-4 · 06 M1-1 검증 게이트).
///
/// 정답지 둘 — `gv08_sizing.json`(파일럿1 원본 8a~8d · 8e 예외 4) · `gv08_machine_block.json`(05 «기계 채점 블록»).
/// 🔵 v2.31 P0S 에서 GV-8 은 채점 외(새틀라이트 비활성)지만 Decimal 규약의 게이트다.
class Gv8Sizing implements GoldenFamily {
  /// 만든다.
  const Gv8Sizing();

  @override
  String get id => 'GV-8';

  @override
  Set<String> get files => const <String>{
    'gv08_sizing.json',
    'gv08_machine_block.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> pilot = b.json('gv08_sizing.json');
    final Map<String, Object?> pc = gvObject(pilot['common']);
    final double pTol = gvDouble(pilot['tolerance']);
    SizingResult size(Map<String, Object?> c) => sizePosition(
      accountEquity: gvDecimal(pc['account']),
      entryPrice: gvDecimal(c['entry']),
      stopPrice: gvDecimal(c['stop']),
      riskPct: gvDouble(pc['risk_pct']),
      notionalCapPct: gvDouble(pc['notional_cap_pct']),
      lotSize: gvInt(c['lot_size'] ?? pc['lot_size']),
    );

    final Map<String, Object?> machine = b.json('gv08_machine_block.json');
    final Map<String, Object?> mc = gvObject(machine['common']);
    final double mTol = gvDouble(machine['tolerance']);

    // GV-8f 공통(05 §GV-8f · 01 §0 규칙 4).
    final Decimal equity = Decimal.parse('100000000');
    final Decimal riskPerShare = Decimal.parse('700');
    Decimal qtyByNotional() =>
        mulDiv(equity, promoteRatio(0.05), Decimal.parse('10000'));

    return <GvCase>[
      for (final Map<String, Object?> c in gvObjectList(pilot['cases']))
        GvCase('GV-${gvString(c['id'])} 파일럿1 수량·binding·두 상한', () {
          final Map<String, Object?> e = gvObject(c['expected']);
          final SizingResult r = size(c);
          return (GvProbe()
                ..same(r.quantity, gvInt(e['quantity']), 'quantity')
                ..same(r.binding.code, gvString(e['binding']), 'binding')
                ..close(
                  r.qtyByRisk.toDouble(),
                  gvDouble(e['qty_by_risk']),
                  pTol,
                  'qty_by_risk',
                )
                ..close(
                  r.qtyByNotional.toDouble(),
                  gvDouble(e['qty_by_notional']),
                  pTol,
                  'qty_by_notional',
                ))
              .failure;
        }),
      for (final Map<String, Object?> c in gvObjectList(
        pilot['exception_cases'],
      ))
        if (c['expect'] == 'ValueError')
          GvCase(
            'GV-${gvString(c['id'])} 규칙 밖 입력은 거부(ValueError ↔ ArgumentError)',
            () =>
                (GvProbe()..throws(
                      () => size(c),
                      (Object e) => e is ArgumentError,
                      'ArgumentError',
                    ))
                    .failure,
          )
        else
          GvCase('GV-${gvString(c['id'])} 손절폭 1원 — 명목 상한이 막는다', () {
            final Map<String, Object?> e = gvObject(c['expected']);
            final SizingResult r = size(c);
            return (GvProbe()
                  ..same(r.quantity, gvInt(e['quantity']), 'quantity')
                  ..same(r.binding.code, gvString(e['binding']), 'binding'))
                .failure;
          }),
      GvCase(
        'GV-8 기계 채점 exact_fields',
        () =>
            (GvProbe()..same(gvStringList(machine['exact_fields']), <String>[
                  'quantity',
                  'binding',
                  'notional_value',
                ], 'exact_fields'))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(machine['cases']))
        GvCase('GV-${gvString(c['id'])} 기계 채점 정확 일치 + 근사', () {
          final Map<String, Object?> e = gvObject(c['expected']);
          final SizingResult r = sizePosition(
            accountEquity: gvDecimal(mc['account_equity']),
            entryPrice: gvDecimal(c['entry']),
            stopPrice: gvDecimal(c['stop']),
            riskPct: gvDouble(mc['risk_pct']),
            notionalCapPct: gvDouble(mc['notional_cap_pct']),
            lotSize: gvInt(c['lot_size'] ?? mc['lot_size']),
          );
          return (GvProbe()
                ..same(r.quantity, gvInt(e['quantity']), 'quantity')
                ..same(r.binding.code, gvString(e['binding']), 'binding')
                ..same(
                  r.notionalValue,
                  gvDecimal(e['notional_value']),
                  'notional_value(lot 내림 후 수량 × 진입가 · 03 §3-4)',
                )
                ..close(
                  r.qtyByRisk.toDouble(),
                  gvDouble(e['qty_by_risk']),
                  mTol,
                  'qty_by_risk',
                )
                ..close(
                  r.qtyByNotional.toDouble(),
                  gvDouble(e['qty_by_notional']),
                  mTol,
                  'qty_by_notional',
                ))
              .failure;
        }),
      GvCase('GV-8 두 정답지가 8a~8d 에서 같은 수량·binding', () {
        Map<String, Map<String, Object?>> byId(Map<String, Object?> v) =>
            <String, Map<String, Object?>>{
              for (final Map<String, Object?> c in gvObjectList(v['cases']))
                gvString(c['id']): gvObject(c['expected']),
            };
        final Map<String, Map<String, Object?>> p = byId(pilot);
        final Map<String, Map<String, Object?>> s = byId(machine);
        final GvProbe probe = GvProbe()
          ..same(p.keys.toSet(), s.keys.toSet(), 'ids');
        for (final String id in s.keys) {
          probe
            ..same(
              p[id] == null ? null : gvInt(p[id]!['quantity']),
              gvInt(s[id]!['quantity']),
              '$id quantity',
            )
            ..same(p[id]?['binding'], s[id]!['binding'], '$id binding');
        }
        return probe.failure;
      }),
      GvCase('GV-8f 곱셈 선행 = 500 — 동률이라 binding 은 RISK', () {
        final Decimal qtyByRisk = mulDiv(
          equity,
          promoteRatio(0.0035),
          riskPerShare,
        );
        final Decimal notional = qtyByNotional();
        return (GvProbe()
              ..same(qtyByRisk, Decimal.parse('500'), 'qty_by_risk')
              ..same(notional, Decimal.parse('500'), 'qty_by_notional')
              ..truth(qtyByRisk <= notional, 'RISK 가 묶어야 한다'))
            .failure;
      }),
      GvCase('GV-8f 나눗셈 선행은 파이썬과 같은 값으로 뒤집힌다', () {
        // 01 §0 의 파이썬 예시 그대로: (D(100_000_000) / D(700)) * D("0.0035")
        final Decimal divided = divide(equity, riskPerShare);
        final Decimal divideFirst = multiply(divided, promoteRatio(0.0035));
        return (GvProbe()
              ..same(
                divided,
                Decimal.parse('142857.1428571428571428571429'),
                'divided',
              )
              ..same(
                divideFirst,
                Decimal.parse('500.0000000000000000000000002'),
                'divide_first',
              )
              ..truth(
                !(divideFirst <= qtyByNotional()),
                '나눗셈을 먼저 하면 binding 이 NOTIONAL 로 뒤집혀야 한다(GV-8a 정답 = RISK)',
              ))
            .failure;
      }),
      GvCase('GV-8f 순수 double 나눗셈 선행도 1 ULP 로 뒤집힌다', () {
        const double divideFirst = 100000000 * (0.0035 / 700);
        return (GvProbe()
              ..same(divideFirst.toString(), '500.00000000000006', 'double')
              ..truth(divideFirst > 500, '500 보다 커야 한다'))
            .failure;
      }),
    ];
  }
}

/// GV-9 멱등키(05 §GV-9 · AC-B09) · GV-13 decision_id 형식 부분(05 §GV-13 · AC-S13) — 04 §3-2.
class Gv9Idempotency implements GoldenFamily {
  /// 만든다.
  const Gv9Idempotency();

  @override
  String get id => 'GV-9';

  @override
  Set<String> get files => const <String>{
    'gv09_idempotency_key.json',
    'gv13_decision_id.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> v = b.json('gv09_idempotency_key.json');
    String key(Map<String, Object?> input) => idempotencyKey(
      market: gvString(input['market']),
      account: gvString(input['account']),
      symbol: gvString(input['symbol']),
      side: gvString(input['side']),
      decisionId: gvString(input['decision_id']),
    );

    final Map<String, Object?> v13 = b.json('gv13_decision_id.json');
    final Map<String, Object?> setup = gvObject(v13['setup']);
    final TradeDate day = TradeDate(gvString(setup['trade_date']));
    final String symbol = gvString(setup['symbol']);
    String keyOf(String decisionId) => idempotencyKey(
      market: gvString(setup['market']),
      account: gvString(setup['account']),
      symbol: symbol,
      side: gvString(setup['side']),
      decisionId: decisionId,
    );
    Map<String, Object?> expectedOf(String id) =>
        gvObject(_caseById(v13, id)['expected']);

    return <GvCase>[
      GvCase(
        'GV-9 정확 일치 필드 = 원문 · 키',
        () =>
            (GvProbe()..same(gvStringList(v['exact_fields']), <String>[
                  'expected_raw',
                  'expected_key',
                ], 'exact_fields'))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(v['cases']))
        GvCase('GV-9 ${gvString(c['expected_raw'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          return (GvProbe()
                ..same(
                  idempotencyRaw(
                    market: gvString(input['market']),
                    account: gvString(input['account']),
                    symbol: gvString(input['symbol']),
                    side: gvString(input['side']),
                    decisionId: gvString(input['decision_id']),
                  ),
                  gvString(c['expected_raw']),
                  'raw',
                )
                ..same(key(input), gvString(c['expected_key']), 'key'))
              .failure;
        }),
      GvCase('GV-9 불변식 — 결정론 · side · decision_id 만 달라도 다른 해시 · 길이 64', () {
        final Map<String, Object?> base = gvObject(
          gvObjectList(v['cases']).first['input'],
        );
        return (GvProbe()
              ..same(key(base), key(base), '결정론')
              ..truth(
                key(<String, Object?>{...base, 'side': 'SELL'}) != key(base),
                'side 만 달라도 다른 해시',
              )
              ..truth(
                key(<String, Object?>{
                      ...base,
                      'decision_id': 'A-REBAL-2026-08-05',
                    }) !=
                    key(base),
                'decision_id 만 달라도 다른 해시',
              )
              ..same(key(base).length, 64, '길이')
              ..truth(
                RegExp(r'^[0-9a-f]{64}$').hasMatch(key(base)),
                '소문자 16진 64자',
              ))
            .failure;
      }),
      GvCase('GV-13 형식 v1 같은 날 4번 감시해도 id·멱등키는 하나', () {
        final List<String> ids = <String>[
          for (int i = 0; i < 4; i++)
            DecisionIds.exit(gvString(setup['strategy_id']), symbol, day),
        ];
        final Map<String, Object?> e = expectedOf('v1');
        return (GvProbe()
              ..same(ids.first, gvString(e['decision_id']), 'decision_id')
              ..same(
                ids.toSet().length,
                gvInt(e['distinct_decision_ids']),
                'distinct_decision_ids',
              )
              ..same(
                ids.map(keyOf).toSet().length,
                gvInt(e['distinct_idempotency_keys']),
                'distinct_idempotency_keys',
              ))
            .failure;
      }),
      GvCase('GV-13 형식 v2 TIER 1.5 · 1B 가 이어 걸려도 id 는 하나', () {
        final Set<String> ids = <String>{
          DecisionIds.exit(gvString(setup['strategy_id']), symbol, day),
          DecisionIds.exit(gvString(setup['strategy_id']), symbol, day),
        };
        return (GvProbe()..same(
              ids.length,
              gvInt(expectedOf('v2')['distinct_decision_ids']),
              'distinct_decision_ids',
            ))
            .failure;
      }),
      GvCase('GV-13 형식 v3 두 전략이 같은 종목을 청산하면 id·멱등키가 둘', () {
        final List<String> ids = <String>[
          DecisionIds.exit('satellite_kr', symbol, day),
          DecisionIds.exit('sleeve_a_kr', symbol, day),
        ];
        final Map<String, Object?> e = expectedOf('v3');
        return (GvProbe()
              ..same(
                ids.toSet().length,
                gvInt(e['distinct_decision_ids']),
                'distinct_decision_ids',
              )
              ..same(
                ids.map(keyOf).toSet().length,
                gvInt(e['distinct_idempotency_keys']),
                'distinct_idempotency_keys',
              ))
            .failure;
      }),
      GvCase(
        'GV-13 형식 v4 월간 새틀라이트 교체는 날짜 하나로 정해진다',
        () =>
            (GvProbe()..same(
                  DecisionIds.satelliteRotation(day),
                  gvString(expectedOf('v4')['decision_id']),
                  'decision_id',
                ))
                .failure,
      ),
    ];
  }
}

Map<String, Object?> _caseById(Map<String, Object?> v, String id) =>
    gvObjectList(v['cases']).firstWhere(
      (Map<String, Object?> c) => c['id'] == id,
      orElse: () => throw FormatException('정답지에 케이스가 없다: $id'),
    );

/// GV-13 «발주 횟수»(AC-S13 · 05 §GV-13 v1~v4) — 포트 수준 가짜 브로커로 submit_order 호출을 센다(설계 13 §8 R35 V9 · V10).
///
/// 🔵 v2.38: 주문 의도의 decision_id 는 `{논리 id}@{집행일}` — 정답지의 `decision_id` 는 논리 id 이고, 같은 날 집행이라 접미도 같다.
class Gv13SubmitCount implements GoldenFamily {
  /// 만든다.
  const Gv13SubmitCount();

  @override
  String get id => 'GV-13';

  @override
  Set<String> get files => const <String>{'gv13_decision_id.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> gv13 = b.json('gv13_decision_id.json');
    final Map<String, Object?> setup = gvObject(gv13['setup']);
    final TradeDate td = TradeDate(gvString(setup['trade_date']));
    final String symbol = gvString(setup['symbol']);
    final String account = gvString(setup['account']);
    final OrderSide side = gvString(setup['side']) == 'SELL'
        ? OrderSide.sell
        : OrderSide.buy;
    Map<String, Object?> expectedOf(String id) =>
        gvObject(_caseById(gv13, id)['expected']);

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

    /// 같은 결정을 차례로 낸다 — 반환 = INSERT 가 새 행을 만들었는가(`reserve_intent_returns`).
    Future<List<bool>> fire(
      FakeOrderLedger ledger,
      FakeOrderBroker broker,
      List<OrderIntentDraft> drafts,
    ) async => <bool>[
      for (final OrderIntentDraft d in drafts)
        (await executeIntent(d, portfolioOk(), ctxOf(ledger, broker))).status !=
            ExecutionStatus.prevented,
    ];

    return <GvCase>[
      GvCase(
        'GV-13 정답지 설정 — EXECUTE(dry_run false) · SELL',
        () =>
            (GvProbe()
                  ..same(setup['dry_run'], false, 'dry_run')
                  ..same(side, OrderSide.sell, 'side'))
                .failure,
      ),
      GvCase('GV-13 v1 감시 4회 → 제출 1회', () async {
        final Map<String, Object?> e = expectedOf('v1');
        final String strategy = gvString(setup['strategy_id']);
        final String logical = DecisionIds.exit(strategy, symbol, td);
        final FakeOrderLedger ledger = ledgerOf();
        final FakeOrderBroker broker = FakeOrderBroker();
        final List<OrderIntentDraft> calls = <OrderIntentDraft>[
          for (int i = 0; i < 4; i++)
            draft(DecisionIds.exit(strategy, symbol, td), strategy),
        ];
        final List<bool> reserved = await fire(ledger, broker, calls);
        return (GvProbe()
              ..same(logical, gvString(e['decision_id']), 'decision_id')
              ..same(reserved, <bool>[
                for (final Object? x
                    in e['reserve_intent_returns']! as List<Object?>)
                  x! as bool,
              ], 'reserve_intent_returns')
              ..same(
                calls.map((OrderIntentDraft d) => d.decisionId).toSet().length,
                gvInt(e['distinct_decision_ids']),
                'distinct_decision_ids',
              )
              ..same(
                calls
                    .map((OrderIntentDraft d) => d.idempotencyKey)
                    .toSet()
                    .length,
                gvInt(e['distinct_idempotency_keys']),
                'distinct_idempotency_keys',
              )
              ..same(
                broker.submitCount,
                gvInt(e['broker.submit_order_call_count']),
                'submit_order 호출',
              )
              ..same(
                ledger.records.length,
                gvInt(e['order_intents_row_count']),
                'order_intents 행',
              ))
            .failure;
      }),
      GvCase('GV-13 v2 TIER 1.5 뒤 1B → 같은 결정 · 제출 1회', () async {
        final Map<String, Object?> e = expectedOf('v2');
        final String strategy = gvString(setup['strategy_id']);
        // TIER 는 생성기 인자가 아니다 — 두 발동이 같은 논리 id 를 낸다.
        final List<OrderIntentDraft> calls = <OrderIntentDraft>[
          draft(DecisionIds.exit(strategy, symbol, td), strategy),
          draft(DecisionIds.exit(strategy, symbol, td), strategy),
        ];
        final FakeOrderBroker broker = FakeOrderBroker();
        await fire(ledgerOf(), broker, calls);
        return (GvProbe()
              ..same(
                calls.map((OrderIntentDraft d) => d.decisionId).toSet().length,
                gvInt(e['distinct_decision_ids']),
                'distinct_decision_ids',
              )
              ..same(
                broker.submitCount,
                gvInt(e['broker.submit_order_call_count']),
                'submit_order 호출',
              ))
            .failure;
      }),
      GvCase('GV-13 v3 두 전략이 각각 청산 → 결정 2 · 키 2 · 제출 2', () async {
        final Map<String, Object?> e = expectedOf('v3');
        final List<OrderIntentDraft> calls = <OrderIntentDraft>[
          for (final String s in <String>['satellite_kr', 'sleeve_a_kr'])
            draft(DecisionIds.exit(s, symbol, td), s),
        ];
        final FakeOrderBroker broker = FakeOrderBroker();
        await fire(ledgerOf(), broker, calls);
        return (GvProbe()
              ..same(
                calls.map((OrderIntentDraft d) => d.decisionId).toSet().length,
                gvInt(e['distinct_decision_ids']),
                'distinct_decision_ids',
              )
              ..same(
                calls
                    .map((OrderIntentDraft d) => d.idempotencyKey)
                    .toSet()
                    .length,
                gvInt(e['distinct_idempotency_keys']),
                'distinct_idempotency_keys',
              )
              ..same(
                broker.submitCount,
                gvInt(e['broker.submit_order_call_count']),
                'submit_order 호출',
              ))
            .failure;
      }),
      GvCase('GV-13 v4 월간 교체 배치를 같은 날 2회 → 제출 1회', () async {
        final Map<String, Object?> e = expectedOf('v4');
        final String logical = DecisionIds.satelliteRotation(td);
        final FakeOrderBroker broker = FakeOrderBroker();
        final FakeOrderLedger ledger = ledgerOf();
        for (int run = 0; run < 2; run++) {
          await runOrderBatch(
            <OrderIntentDraft>[draft(logical, gvString(setup['strategy_id']))],
            brokers: <String, OrderBroker>{account: broker},
            ledger: ledger,
            lease: FakeLeaseGate(),
            limitStateFor: (OrderIntentDraft d) async => portfolioOk(),
            limitConfig: kLimitConfig,
            buyCostRate: 0.00015,
            execPolicy: ExecPolicy.execute,
            operatingMode: OperatingMode.autoTrade,
            configHash: 'cfg-test',
          );
        }
        return (GvProbe()
              ..same(logical, gvString(e['decision_id']), 'decision_id')
              ..same(
                broker.submitCount,
                gvInt(e['broker.submit_order_call_count']),
                'submit_order 호출',
              )
              ..same(
                broker.submitted.length == 1
                    ? broker.submitted.single.limitPrice
                    : null,
                Decimal.parse('9350'),
                '지정가',
              ))
            .failure;
      }),
    ];
  }
}

/// GV-30 계절성 분할 집행(AC-B23 · e1~e4) — 03 §5-3-1 v2.10 · v2.38 · 06 M1-9b.
///
/// `filled` 가 없는 케이스는 계획대로 전량 체결된다고 본다(블록 검산 «잔량 66 → 33»). e4 의 `filled` = 1·2일차 체결 수량.
/// 🔴 e4 해석(v2.38 · 설계 13 §8 R33 D8): 중간 날 = 계획 잔량 기준 ceil · 마지막 날 = 목표 − 누적 체결.
class Gv30SplitExecution implements GoldenFamily {
  /// 만든다.
  const Gv30SplitExecution();

  @override
  String get id => 'GV-30';

  @override
  Set<String> get files => const <String>{'gv30_split_execution.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> gv30 = b.json('gv30_split_execution.json');
    final int days = gvInt(gvObject(gv30['config'])['execution_days']);
    return <GvCase>[
      GvCase(
        'GV-30 집행일 = anchor 포함 거꾸로 3세션(동결 XKRX 달력)',
        () =>
            (GvProbe()..same(
                  seasonalExecutionDays(
                    frozenExchangeCalendar(Market.kr),
                    TradeDate(gvString(gv30['anchor_date'])),
                    days,
                  ).map((TradeDate d) => d.yyyyMmDd).toList(),
                  gvStringList(gv30['sessions']),
                  'sessions',
                ))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(gv30['cases']))
        GvCase('GV-30 ${gvString(c['id'])} 일별 수량', () {
          final Map<String, Object?> e = gvObject(c['expected']);
          final int target = gvInt(c['target_qty']);
          final List<int>? filled = c['filled'] == null
              ? null
              : gvIntList(c['filled']);
          final List<int> daily = <int>[];
          final List<bool> market = <bool>[];
          int planned = 0;
          int filledSum = 0;
          for (int i = 0; i < days; i++) {
            final SplitDay d = splitDay(
              target: target,
              days: days,
              dayIndex: i,
              plannedBefore: planned,
              filledBefore: filledSum,
            );
            daily.add(d.quantity);
            market.add(d.marketOrder);
            planned += d.quantity;
            if (i < days - 1) {
              filledSum += filled == null ? d.quantity : filled[i];
            }
          }
          return (GvProbe()
                ..same(daily, gvIntList(e['daily_qty']), 'daily_qty')
                // 마지막 날만 시장가(v2.38 D7).
                ..same(market, <bool>[false, false, true], 'market_order'))
              .failure;
        }),
    ];
  }
}
