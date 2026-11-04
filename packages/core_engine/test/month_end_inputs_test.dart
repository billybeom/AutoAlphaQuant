// 월말 계획기 입력 조립 · 대상 직렬화(설계 13 §8 R48 P4~P9).
//
// 🔵 잡는 것: ① 전략 칸 귀속(B 자산 · B 파킹 · C 채권 · 금 · C 재분류 파킹 · POT · A) · 귀속 불가 · 종가 없음 = 실패
//    ② 안 가진 B 자산 · 금의 종가 없음 = null ③ C 원화 = 현금 − POT − 예약 ④ 달마다 마지막 종가 ⑤ 비중 합 1
//    ⑥ computeMonthEndRun = 계획기 · 대상 함수를 그대로 부른 것과 같다 · 현금 실패 ⑦ 대상 JSON 왕복.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

final MonthEndConfig _cfg = p0sMonthEndConfig();

final Map<String, Decimal> _closes = <String, Decimal>{
  '133690': _d('160000'),
  '411060': _d('15000'),
  '0085P0': _d('10000'),
  '214980': _d('100000'),
};

MonthEndState _state(
  List<LedgerHolding> h, {
  Map<String, Decimal>? closes,
  String cash = '1000000',
  String pot = '0',
  String reserved = '0',
  int monthIndex = 1,
}) => monthEndStateFromLedger(
  holdings: h,
  closes: closes ?? _closes,
  cashKrw: _d(cash),
  potCash: _d(pot),
  reservedKrw: _d(reserved),
  pensionUsedThisYear: Decimal.zero,
  monthIndex: monthIndex,
  regimeState: DirectionState.bull,
  monthlyCloses: const <String, List<double>>{},
  hasNextKrSession: true,
  hasNextUsSession: true,
  config: _cfg,
  parkingSymbol: kP0sParkingSymbol,
);

void main() {
  group('보유 → 슬리브(P4)', () {
    test('전략 칸 귀속 · C 재분류 파킹 = P0S_C × 파킹 · 총평가 = 보유 + 현금', () {
      final MonthEndState s = _state(
        const <LedgerHolding>[
          LedgerHolding('P0S_A', '229200', 2),
          LedgerHolding('P0S_B', '133690', 3),
          LedgerHolding('P0S_B', '411060', 4),
          LedgerHolding('P0S_B', '214980', 1),
          LedgerHolding('P0S_C', '0085P0', 5),
          LedgerHolding('P0S_C', '411060', 6),
          LedgerHolding('P0S_C', '214980', 2),
        ],
        closes: <String, Decimal>{..._closes, '229200': _d('20000')},
      );
      expect(s.bAssets, <String, Decimal?>{
        '133690': _d('480000'),
        '411060': _d('60000'),
      });
      expect(s.bParking, _d('100000'));
      expect(s.bParkingReclassified, _d('200000'));
      expect(s.cBond, _d('50000'));
      expect(s.cGold, _d('90000'));
      expect(s.potAssets, <String, Decimal?>{
        '133690': Decimal.zero,
        '411060': Decimal.zero,
      });
      expect(s.krwCash, _d('1000000'));
      expect(
        s.totalEquity,
        _d('40000') +
            _d('480000') +
            _d('60000') +
            _d('100000') +
            _d('50000') +
            _d('90000') +
            _d('200000') +
            _d('1000000'),
      );
    });

    test('POT 자산 · 같은 종목 여러 줄 합 · 0 수량 무시', () {
      final MonthEndState s = _state(
        const <LedgerHolding>[
          LedgerHolding('P0S_POT', '133690', 1),
          LedgerHolding('P0S_POT', '133690', 1),
          LedgerHolding('P0S_B', '133690', 0),
          // 0 수량 = 귀속 · 종가를 보지 않는다(귀속 불가 전략 · 종가 없는 종목이어도).
          LedgerHolding('P0S_X', 'NOPRICE', 0),
        ],
        pot: '100',
        reserved: '200',
      );
      expect(s.potAssets['133690'], _d('320000'));
      expect(s.bAssets['133690'], Decimal.zero);
      expect(
        (s.potCash, s.reservedKrw, s.krwCash),
        (_d('100'), _d('200'), _d('999700')),
      );
    });

    test('🔴 귀속 불가 · 보유 종가 없음 · 음수 = MonthEndInputError(전략 · 종목만)', () {
      for (final (List<LedgerHolding> h, String why)
          in <(List<LedgerHolding>, String)>[
            (
              const <LedgerHolding>[LedgerHolding('P0S_X', '133690', 1)],
              '귀속 불가 보유: P0S_X 133690',
            ),
            (
              const <LedgerHolding>[LedgerHolding('P0S_B', '0085P0', 1)],
              '귀속 불가 보유: P0S_B 0085P0',
            ),
            (
              const <LedgerHolding>[LedgerHolding('P0S_C', '133690', 1)],
              '귀속 불가 보유: P0S_C 133690',
            ),
            (
              const <LedgerHolding>[LedgerHolding('P0S_POT', '214980', 1)],
              '귀속 불가 보유: P0S_POT 214980',
            ),
            (
              const <LedgerHolding>[LedgerHolding('P0S_A', 'NOPRICE', 1)],
              '종가 없음: P0S_A NOPRICE',
            ),
            (
              const <LedgerHolding>[LedgerHolding('P0S_B', '133690', -1)],
              '보유 수량 음수: P0S_B 133690',
            ),
          ]) {
        expect(
          () => _state(h),
          throwsA(
            isA<MonthEndInputError>().having(
              (MonthEndInputError e) => e.reason,
              'reason',
              why,
            ),
          ),
        );
      }
    });

    test('안 가진 B 자산 · 금의 종가 없음 = null · 금 종가 있으면 0 · 보유 금 = 값', () {
      final MonthEndState s = _state(
        const <LedgerHolding>[],
        closes: <String, Decimal>{'133690': _d('1'), '0085P0': _d('1')},
      );
      expect(s.bAssets, <String, Decimal?>{
        '133690': Decimal.zero,
        '411060': null,
      });
      expect(s.cGold, isNull);
      expect(_state(const <LedgerHolding>[]).cGold, Decimal.zero);
    });

    test('POT + 예약 > 현금 = 실패 · 음수 입력 · monthIndex 0 = ArgumentError', () {
      expect(
        () => _state(
          const <LedgerHolding>[],
          cash: '100',
          pot: '60',
          reserved: '50',
        ),
        throwsA(isA<MonthEndInputError>()),
      );
      expect(
        () => _state(const <LedgerHolding>[], cash: '-1'),
        throwsArgumentError,
      );
      expect(
        () => _state(const <LedgerHolding>[], monthIndex: 0),
        throwsArgumentError,
      );
    });
  });

  group('달마다 마지막 종가 · 비중(P6 · P7)', () {
    test('달의 마지막 날 값 · 기준 달까지 · 0 이하 · NaN 버림 · 순서 무관', () {
      expect(
        monthlyLastCloses(<(String, double)>[
          ('2026-06-30', 12),
          ('2026-05-02', 9),
          ('2026-05-29', 10),
          ('2026-06-15', 11),
          ('2026-07-31', 13),
          ('2026-06-29', double.nan),
          ('2026-04-30', 0),
        ], '2026-06'),
        <double>[10, 12],
      );
    });

    test('비중 = A · B · C · POT 합 1 · 총평가 0 = 전부 0', () {
      final Map<String, double> w = sleeveWeightsOf(
        _state(const <LedgerHolding>[
          LedgerHolding('P0S_B', '133690', 1),
          LedgerHolding('P0S_C', '0085P0', 10),
        ], cash: '40000'),
      );
      expect(w.keys, <String>['A', 'B', 'C', 'POT']);
      expect(w['B'], closeTo(160000 / 300000, 1e-12));
      expect(w['C'], closeTo(140000 / 300000, 1e-12));
      expect(
        w.values.fold(0.0, (double a, double b) => a + b),
        closeTo(1, 1e-12),
      );
      expect(
        sleeveWeightsOf(_state(const <LedgerHolding>[], cash: '0')),
        <String, double>{'A': 0, 'B': 0, 'C': 0, 'POT': 0},
      );
    });
  });

  group('computeMonthEndRun(P7)', () {
    Future<MonthEndRun> run({
      Map<String, OrderBroker>? cash,
      String outside = '0',
    }) => computeMonthEndRun(
      monthEnd: const TradeDate('2026-07-31'),
      holdings: const <LedgerHolding>[LedgerHolding('P0S_B', '133690', 10)],
      closeTexts: <String, String>{
        for (final MapEntry<String, Decimal> e in _closes.entries)
          e.key: '${e.value}.0',
      },
      cashAccounts:
          cash ??
          <String, OrderBroker>{
            'main': FakeOrderBroker(cashKrw: _d('8000000')),
            'pension': FakeOrderBroker(cashKrw: _d('2000000')),
          },
      pensionRows: const <LedgerCashRow>[],
      pensionAlias: 'pension',
      pensionOutsideText: outside,
      monthIndex: 1,
      regimeState: DirectionState.bull,
      monthlyCloses: <String, List<double>>{
        '133690': <double>[for (int i = 0; i < 14; i++) 100.0 + i],
        '411060': <double>[for (int i = 0; i < 14; i++) 200.0 - i],
      },
      hasNextKrSession: true,
      hasNextUsSession: true,
      config: _cfg,
      parkingSymbol: kP0sParkingSymbol,
      instruments: const <String, InstrumentKind>{'133690': InstrumentKind.etf},
    );

    test(
      '= 상태 조립 → planMonthEnd → targetsFromMonthEnd 를 그대로 부른 것 · 현금 = 계좌 합',
      () async {
        final MonthEndRun r = await run();
        expect(r.state.krwCash, _d('10000000'));
        expect(r.state.totalEquity, _d('11600000'));
        final MonthEndPlan direct = planMonthEnd(r.state, _cfg);
        expect(
          r.plan.actions.map((MonthEndAction a) => '$a'),
          direct.actions.map((MonthEndAction a) => '$a'),
        );
        final List<OrderTarget> t = targetsFromMonthEnd(
          direct,
          judgmentDate: const TradeDate('2026-07-31'),
          instruments: const <String, InstrumentKind>{
            '133690': InstrumentKind.etf,
          },
        );
        expect(
          r.targets.map(orderTargetToJson).toList(),
          t.map(orderTargetToJson).toList(),
        );
        expect(r.targets, isNotEmpty);
        expect(r.weightsBefore, sleeveWeightsOf(r.state));
        expect(r.weightsAfter, sleeveWeightsOf(r.plan.after));
      },
    );

    test(
      '현금 조회 실패 = MonthEndInputError(별칭만) · 밖 연금 글자 틀림 · 계좌 없음 = ArgumentError',
      () async {
        await expectLater(
          run(
            cash: <String, OrderBroker>{
              'isa': FakeOrderBroker(cashError: StateError('9999 원')),
            },
          ),
          throwsA(
            isA<MonthEndInputError>().having(
              (MonthEndInputError e) => '$e',
              's',
              'MonthEndInputError(현금 조회 실패: isa)',
            ),
          ),
        );
        await expectLater(run(outside: 'x'), throwsArgumentError);
        await expectLater(run(outside: '-1'), throwsArgumentError);
        await expectLater(
          run(cash: const <String, OrderBroker>{}),
          throwsArgumentError,
        );
      },
    );

    test('상태 · 행동 JSON = 금액 글자 · 칸 이름', () async {
      final MonthEndRun r = await run();
      final Map<String, Object?> j = monthEndStateToJson(r.state);
      expect(j['total_equity'], '11600000');
      expect((j['b_assets']! as Map<String, Object?>)['133690'], '1600000');
      expect(j['regime_state'], 'BULL');
      expect(j['month_index'], 1);
      final Map<String, Object?> a = monthEndActionToJson(r.plan.actions.first);
      expect(a.keys, <String>['kind', 'symbol', 'is_buy', 'amount', 'cost']);
    });
  });

  group('대상 직렬화(P9)', () {
    test('왕복 = 같다(금액 · 주수 · 전량 · 상품 · 시장가)', () {
      final List<OrderTarget> ts = <OrderTarget>[
        OrderTarget(
          logicalDecisionId: 'B-SMA-2026-07-31-133690',
          strategyId: 'P0S_B',
          symbol: '133690',
          side: OrderSide.buy,
          sizing: AmountSizing(_d('123456.789')),
          instrument: InstrumentKind.etf,
        ),
        OrderTarget(
          logicalDecisionId: 'C-REBAL-2026-07-31-0085P0',
          strategyId: 'P0S_C',
          symbol: '0085P0',
          side: OrderSide.sell,
          sizing: const ShareSizing(7),
          marketOrder: true,
        ),
        OrderTarget(
          logicalDecisionId: 'X',
          strategyId: 'P0S_POT',
          symbol: '411060',
          side: OrderSide.sell,
          sizing: const AllHeldSizing(),
        ),
      ];
      for (final OrderTarget t in ts) {
        expect(
          orderTargetToJson(orderTargetFromJson(orderTargetToJson(t))),
          orderTargetToJson(t),
        );
      }
      expect(orderTargetToJson(ts.first)['sizing'], <String, Object?>{
        'kind': 'AMOUNT',
        'krw': '123456.789',
      });
      expect(orderTargetToJson(ts.first)['instrument'], 'ETF');
      // 🔴 금액은 글자로 — double 로 거치면 자릿수를 잃는다.
      final OrderTarget big = OrderTarget(
        logicalDecisionId: 'L',
        strategyId: 'S',
        symbol: 'Y',
        side: OrderSide.buy,
        sizing: AmountSizing(_d('12345678901234567.123')),
      );
      expect(
        (orderTargetToJson(big)['sizing']! as Map<String, Object?>)['krw'],
        '12345678901234567.123',
      );
      expect(orderTargetToJson(ts[1])['instrument'], 'STOCK');
    });

    test('꼴이 틀리면 FormatException(규칙 위반 포함)', () {
      final Map<String, Object?> ok = orderTargetToJson(
        OrderTarget(
          logicalDecisionId: 'L',
          strategyId: 'S',
          symbol: 'Y',
          side: OrderSide.buy,
          sizing: AmountSizing(_d('1')),
        ),
      );
      for (final Map<String, Object?> bad in <Map<String, Object?>>[
        <String, Object?>{...ok, 'logical_decision_id': ''},
        <String, Object?>{...ok, 'side': 'HOLD'},
        <String, Object?>{...ok, 'instrument': 'BOND'},
        <String, Object?>{...ok, 'market_order': 'no'},
        <String, Object?>{...ok, 'sizing': 3},
        <String, Object?>{
          ...ok,
          'sizing': <String, Object?>{'kind': 'AMOUNT', 'krw': 'x'},
        },
        <String, Object?>{
          ...ok,
          'sizing': <String, Object?>{'kind': 'AMOUNT', 'krw': '0'},
        },
        <String, Object?>{
          ...ok,
          'sizing': <String, Object?>{'kind': 'SHARES', 'shares': '3'},
        },
        <String, Object?>{
          ...ok,
          'sizing': <String, Object?>{'kind': 'ALL_HELD'},
        },
        <String, Object?>{
          ...ok,
          'sizing': <String, Object?>{'kind': 'WEIRD'},
        },
      ]) {
        expect(
          () => orderTargetFromJson(bad),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });
  });
}
