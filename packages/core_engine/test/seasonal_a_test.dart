// 슬리브 A 계절 판정 · POT 현금 · 입력 조립 · 대상 출처 묶음(설계 13 §8 R49 Q2 · Q3 · Q5 · Q6 · 하네스 `_seasonalCheck` 규칙).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

SeasonalADecision _go({
  int month = 10,
  int defer = 0,
  double? score = 70,
  BreakerLevel breaker = BreakerLevel.normal,
  String eq = '10000000',
  String a = '0',
  String close = '10000',
  int held = 0,
  int monthCount = 6,
}) => decideSeasonalA(
  SeasonalAInput(
    month: month,
    deferCount: defer,
    score: score,
    breaker: breaker,
    prevEquity: _d(eq),
    aValue: _d(a),
    aPrevClose: _d(close),
    aHeldShares: held,
    monthCount: monthCount,
  ),
);

class _Src implements TargetSource {
  _Src(this.ts);
  final List<OrderTarget> ts;
  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async => ts;
}

OrderTarget _t(String id) => OrderTarget(
  logicalDecisionId: id,
  strategyId: 'S',
  symbol: 'Y',
  side: OrderSide.buy,
  sizing: const ShareSizing(1),
);

void main() {
  group('판정 규칙(하네스 그대로)', () {
    test('10월 점수 ≥ 60 = 진입 · POT 청산 · 목표 주수 = ⌊(평가 × 0.2 × 램프 − A) ÷ 종가⌋', () {
      final SeasonalADecision d = _go(a: '500000');
      expect(d.outcome, SeasonalAOutcome.enter);
      expect(
        (d.liquidatePot, d.side, d.deferCountAfter),
        (true, OrderSide.buy, 0),
      );
      expect(d.deltaKrw, _d('1500000'));
      expect(d.targetShares, 150);
      expect(d.outcome.reasonCode, 'SEASONAL_ENTRY');
    });

    test('10월 점수 < 60 = 연기 1 · POT 그대로 · 점수 없음(NaN) = 진입', () {
      final SeasonalADecision d = _go(score: 59.9);
      expect(
        (d.outcome, d.deferCountAfter, d.liquidatePot, d.side),
        (SeasonalAOutcome.defer, 1, false, null),
      );
      expect(_go(score: null).outcome, SeasonalAOutcome.enter);
      expect(_go(score: double.nan).outcome, SeasonalAOutcome.enter);
      expect(_go(score: 60).outcome, SeasonalAOutcome.enter);
    });

    test('🔴 10월 HALTED · STOPPED = 문턱 안 보고 POT 만 청산 · 사지 않음', () {
      for (final BreakerLevel l in <BreakerLevel>[
        BreakerLevel.halted,
        BreakerLevel.stopped,
      ]) {
        final SeasonalADecision d = _go(breaker: l, score: 10);
        expect(
          (d.outcome, d.liquidatePot, d.side, d.targetShares),
          (SeasonalAOutcome.breakerSkip, true, null, 0),
        );
      }
      expect(
        _go(breaker: BreakerLevel.reduced, score: 10).outcome,
        SeasonalAOutcome.defer,
      );
    });

    test('연기 뒤(11 · 12월) — 점수 < 60 = 연기 + 1 · ≥ 60 = 늦은 진입 · 2번 연기 = 강제 · HALTED = 그대로 기다림', () {
      expect(
        (
          _go(month: 11, defer: 1, score: 50).outcome,
          _go(month: 11, defer: 1, score: 50).deferCountAfter,
        ),
        (SeasonalAOutcome.defer, 2),
      );
      final SeasonalADecision late = _go(month: 11, defer: 1, score: 65);
      expect(
        (late.outcome, late.liquidatePot, late.deferCountAfter),
        (SeasonalAOutcome.lateEnter, true, 0),
      );
      expect(late.outcome.reasonCode, 'F1_ENTRY_LATE');
      expect(
        _go(month: 12, defer: 2, score: 10).outcome,
        SeasonalAOutcome.lateEnter,
      );
      // 문턱 경계 — 60 = 통과(≥).
      expect(
        _go(month: 11, defer: 1, score: 60).outcome,
        SeasonalAOutcome.lateEnter,
      );
      expect(
        _go(month: 12, defer: 2, score: null).outcome,
        SeasonalAOutcome.lateEnter,
      );
      final SeasonalADecision h = _go(
        month: 11,
        defer: 1,
        breaker: BreakerLevel.halted,
      );
      expect(
        (h.outcome, h.deferCountAfter, h.liquidatePot),
        (SeasonalAOutcome.breakerSkip, 1, false),
      );
      expect(
        _go(month: 1, defer: 2, score: 10).outcome,
        SeasonalAOutcome.lateEnter,
      );
    });

    test('4월 = A 보유 전량 매도 · 보유 0 = 할 일 없음 · 다른 달 · 연기 없음 = 할 일 없음', () {
      final SeasonalADecision x = _go(month: 4, held: 37, a: '370000');
      expect(
        (x.outcome, x.side, x.targetShares, x.liquidatePot),
        (SeasonalAOutcome.exit, OrderSide.sell, 37, false),
      );
      expect(_go(month: 4).outcome, SeasonalAOutcome.nothing);
      for (final int m in <int>[1, 2, 3, 5, 6, 7, 8, 9, 11, 12]) {
        expect(_go(month: m).outcome, SeasonalAOutcome.nothing, reason: '$m');
      }
    });

    test('램프 = min(월말 수 ÷ 6, 1) · 차이 ≤ 평가 0.1% · A 가 이미 크면 = 청산만 · 사지 않음', () {
      expect(_go(monthCount: 3).deltaKrw, _d('1000000'));
      expect(_go(monthCount: 10).deltaKrw, _d('2000000'));
      expect(_go(monthCount: 0).targetShares, 0);
      final SeasonalADecision tiny = _go(a: '1990000');
      expect(
        (tiny.liquidatePot, tiny.side, tiny.targetShares),
        (true, null, 0),
      );
      final SeasonalADecision over = _go(a: '3000000');
      expect(
        (over.outcome, over.side, over.targetShares),
        (SeasonalAOutcome.enter, null, 0),
      );
      expect(_go(close: '0').targetShares, 0);
    });

    test('잘못된 입력 = ArgumentError', () {
      expect(() => _go(month: 13), throwsArgumentError);
      expect(() => _go(defer: -1), throwsArgumentError);
      expect(() => _go(held: -1), throwsArgumentError);
    });
  });

  group('POT 현금 · 입력 조립 · 묶음', () {
    test('potCashOf = 매도 순대금 + − 매수 대금 · 글자 틀림 = FormatException', () {
      expect(
        potCashOf(const <PotCashFlow>[
          PotCashFlow(
            PotCashFlowKind.aExitSell,
            quantity: 10,
            priceText: '20000.0',
            commissionText: '30',
            taxText: '0',
          ),
          PotCashFlow(
            PotCashFlowKind.potBuy,
            quantity: 1,
            priceText: '150000',
            commissionText: '22.5',
          ),
          PotCashFlow(
            PotCashFlowKind.potSell,
            quantity: 1,
            priceText: '1000',
            taxText: '1',
          ),
        ]),
        _d('199970') - _d('150022.5') + _d('999'),
      );
      expect(
        () => potCashOf(const <PotCashFlow>[
          PotCashFlow(PotCashFlowKind.potBuy, quantity: 1, priceText: 'x'),
        ]),
        throwsFormatException,
      );
    });

    test('입력 조립 = 보유 × 직전 종가 + D+2 현금 · A 평가 = P0S_A × A 종목만 · 실패 = SeasonalAInputError', () async {
      Future<SeasonalAInput> go({
        List<LedgerHolding> h = const <LedgerHolding>[
          LedgerHolding('P0S_A', '229200', 10),
          LedgerHolding('P0S_B', '133690', 2),
          LedgerHolding('P0S_C', '229200', 1),
        ],
        Map<String, String> closes = const <String, String>{
          '229200': '10000.0',
          '133690': '150000',
        },
        Map<String, OrderBroker>? cash,
      }) => seasonalAInputFromLedger(
        month: 10,
        deferCount: 0,
        score: 70,
        breaker: BreakerLevel.normal,
        holdings: h,
        closeTexts: closes,
        cashAccounts:
            cash ??
            <String, OrderBroker>{'main': FakeOrderBroker(cashKrw: _d('1000'))},
        aSymbol: '229200',
        monthCount: 6,
      );
      final SeasonalAInput i = await go();
      expect(
        (i.prevEquity, i.aValue, i.aPrevClose, i.aHeldShares),
        (
          _d('100000') + _d('300000') + _d('10000') + _d('1000'),
          _d('100000'),
          _d('10000'),
          10,
        ),
      );
      await expectLater(
        go(closes: const <String, String>{'133690': '1'}),
        throwsA(isA<SeasonalAInputError>()),
      );
      await expectLater(
        go(closes: const <String, String>{'229200': '1'}),
        throwsA(
          isA<SeasonalAInputError>().having(
            (SeasonalAInputError e) => e.reason,
            'r',
            '종가 없음: P0S_B 133690',
          ),
        ),
      );
      await expectLater(
        go(
          cash: <String, OrderBroker>{
            'isa': FakeOrderBroker(cashError: StateError('x')),
          },
        ),
        throwsA(
          isA<SeasonalAInputError>().having(
            (SeasonalAInputError e) => e.reason,
            'r',
            '현금 조회 실패: isa',
          ),
        ),
      );
      await expectLater(
        go(cash: const <String, OrderBroker>{}),
        throwsArgumentError,
      );
    });

    test('CompositeTargetSource = 넘긴 차례대로 이어 붙인다', () async {
      final CompositeTargetSource c = CompositeTargetSource(<TargetSource>[
        _Src(<OrderTarget>[_t('a'), _t('b')]),
        _Src(const <OrderTarget>[]),
        _Src(<OrderTarget>[_t('c')]),
      ]);
      expect(
        (await c.targetsFor(const TradeDate('2026-10-29')))
            .map((OrderTarget t) => t.logicalDecisionId),
        <String>['a', 'b', 'c'],
      );
    });
  });
}
