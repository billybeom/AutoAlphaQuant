// E11p3b-2 — 한도 판정 입력(설계 13 §8 R91 · 02 §2 `PortfolioState` · 04 §1 SAF-301 · 303 · 304 · 403).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

import 'order_path_fixture.dart' show draftOf, kExec;

Decimal _d(String s) => Decimal.parse(s);

/// 보유: A(999990) 10 × 1,000 · B 주식(133690) 5 × 2,000 · 금(411060) 3 × 1,000 · 현금 5,000 → 총자산 28,000.
LimitInputs _inputs({
  Map<String, Decimal>? prices,
  String cash = '5000',
  String previous = '27000',
  String flows = '500',
  List<LedgerHolding>? holdings,
}) => LimitInputs(
  holdings:
      holdings ??
      const <LedgerHolding>[
        LedgerHolding('P0S_A', '999990', 10),
        LedgerHolding('P0S_B', '133690', 5),
        LedgerHolding('P0S_B', '411060', 3),
        LedgerHolding('P0S_C', '0085P0', 0),
      ],
  prices:
      prices ??
      <String, Decimal>{
        '999990': _d('1000'),
        '133690': _d('2000'),
        '411060': _d('1000'),
      },
  cashKrw: _d(cash),
  previousEquity: _d(previous),
  flowsToday: _d(flows),
  riskSymbols: const <String>{'999990', '133690'},
);

class _Broker implements OrderBroker {
  _Broker(this.cash);

  final String cash;
  int calls = 0;

  @override
  Future<Decimal> orderableCashKrw() async {
    calls++;
    return _d(cash);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Facts implements LimitLedgerFactsSource {
  _Facts(this.facts);

  final LimitLedgerFacts facts;
  final List<TradeDate> asked = <TradeDate>[];

  @override
  LimitLedgerFacts factsFor(TradeDate day) {
    asked.add(day);
    return facts;
  }
}

void main() {
  group('limitStateOf', () {
    test('🔴 총자산 = 보유 × 현재가 + 현금 · 수량 0 종목은 현재가가 없어도 된다', () {
      final LimitState s = limitStateOf(
        _inputs(),
        draftOf(quantity: 2, price: '2000'),
      );
      expect(s.totalEquity, _d('28000'));
    });

    test('🔴 오늘 손익률 = (총자산 − 전일 − 오늘 입출금) / (전일 + 오늘 입출금)', () {
      final LimitState s = limitStateOf(_inputs(), draftOf());
      expect(s.dailyPnlPct, closeTo((28000 - 27000 - 500) / 27500, 1e-12));
      // 입금만 들어온 날(손익 0) — 입금은 손익이 아니다.
      expect(
        limitStateOf(
          _inputs(previous: '23000', flows: '5000'),
          draftOf(),
        ).dailyPnlPct,
        0,
      );
      // 개시 날(전일 0 · 입금만).
      expect(
        limitStateOf(
          _inputs(previous: '0', flows: '28000'),
          draftOf(),
        ).dailyPnlPct,
        0,
      );
    });

    test('🔴 분모 0 이하 = 모름(null → 매수 거부)', () {
      expect(
        limitStateOf(_inputs(previous: '0', flows: '0'), draftOf()).dailyPnlPct,
        isNull,
      );
    });

    test('위험자산 · 레버리지 · 보유 수 — 위험 종목 매수', () {
      final LimitState s = limitStateOf(
        _inputs(),
        draftOf(symbol: '133690', quantity: 2, price: '2000'),
      );
      expect(
        s.riskExposureAfter,
        closeTo((10000 + 10000 + 4000) / 28000, 1e-12),
      );
      expect(s.leverageAfter, closeTo((23000 + 4000) / 28000, 1e-12));
      expect(s.positionsAfter, 3);
    });

    test('방어 종목 매수 = 위험자산 그대로 · 새 종목이면 보유 수 + 1', () {
      final LimitState s = limitStateOf(
        _inputs(),
        draftOf(symbol: '0085P0', quantity: 2, price: '1000'),
      );
      expect(s.riskExposureAfter, closeTo(20000 / 28000, 1e-12));
      expect(s.leverageAfter, closeTo(25000 / 28000, 1e-12));
      expect(s.positionsAfter, 4);
    });

    test('매도 = 빼고(0 아래로 가지 않는다) · 보유 수 그대로', () {
      final LimitState s = limitStateOf(
        _inputs(),
        draftOf(
          symbol: '999990',
          side: OrderSide.sell,
          quantity: 30,
          price: '1000',
        ),
      );
      expect(s.riskExposureAfter, 0);
      expect(s.leverageAfter, 0);
      expect(s.positionsAfter, 3);
    });

    test('🔴 잴 수 없음 — 보유 종목 현재가 없음 · 0 이하 · 총자산 0 이하 = 던진다', () {
      expect(
        () => limitStateOf(
          _inputs(prices: <String, Decimal>{'999990': _d('1000')}),
          draftOf(),
        ),
        throwsA(isA<LimitInputsUnavailable>()),
      );
      expect(
        () => limitStateOf(
          _inputs(
            prices: <String, Decimal>{
              '999990': _d('0'),
              '133690': _d('2000'),
              '411060': _d('1000'),
            },
          ),
          draftOf(),
        ),
        throwsA(isA<LimitInputsUnavailable>()),
      );
      expect(
        () => limitStateOf(
          _inputs(holdings: const <LedgerHolding>[], cash: '0'),
          draftOf(),
        ),
        throwsA(isA<LimitInputsUnavailable>()),
      );
    });

    test('원장이 덮는 칸 · 새틀라이트 · 환율 = null(지어내지 않는다)', () {
      final LimitState s = limitStateOf(_inputs(), draftOf());
      expect(s.ordersToday, isNull);
      expect(s.strategyRegistered, isNull);
      expect(s.tradingBlocked, isNull);
      expect(s.journalMissing, isNull);
      expect(s.tierBUnjudged, isNull);
      expect(s.satellitePositionsAfter, isNull);
      expect(s.fxRateUsdKrw, isNull);
    });
  });

  group('LimitInputsCollector', () {
    late _Broker a;
    late _Broker b;
    late _Facts facts;
    late Map<String, int> priced;
    late bool failPrice;

    LimitInputsCollector make({double? snap = 27000}) {
      a = _Broker('3000');
      b = _Broker('2000');
      facts = _Facts(
        LimitLedgerFacts(
          previousSnapshotEquity: snap,
          flowsBefore: 25000,
          flowsToday: 500,
        ),
      );
      priced = <String, int>{};
      failPrice = false;
      return LimitInputsCollector(
        holdings: () async => const <LedgerHolding>[
          LedgerHolding('P0S_A', '999990', 10),
          LedgerHolding('P0S_B', '133690', 5),
          LedgerHolding('P0S_B', '411060', 3),
        ],
        cash: <String, OrderBroker>{'acct_b': b, 'acct_a': a},
        price: (String s) async {
          if (failPrice) throw StateError('조회 실패');
          priced[s] = (priced[s] ?? 0) + 1;
          return switch (s) {
            '999990' => _d('1000'),
            '133690' => _d('2000'),
            _ => _d('1000'),
          };
        },
        riskSymbols: const <String>{'999990', '133690'},
        ledger: facts,
      );
    }

    test('🔴 현금 = 계좌 합 · 전일 = 평가 행 · 날 하나에 한 번 모은다', () async {
      final LimitInputsCollector c = make();
      final LimitState s1 = await c.stateFor(draftOf());
      final LimitState s2 = await c.stateFor(draftOf(symbol: '411060'));
      expect(s1.totalEquity, _d('28000'));
      expect(s2.totalEquity, _d('28000'));
      expect(s1.dailyPnlPct, closeTo(500 / 27500, 1e-12));
      expect(priced.values.toSet(), <int>{1});
      expect(a.calls + b.calls, 2);
      expect(facts.asked, <TradeDate>[kExec]);
    });

    test('🔴 평가 행이 없으면 전일 = 그날 앞 입출금 합(원가)', () async {
      final LimitInputsCollector c = make(snap: null);
      final LimitInputs x = await c.inputsFor(kExec);
      expect(x.previousEquity, _d('25000'));
      expect(x.flowsToday, _d('500'));
    });

    test('🔴 모으기 실패 = 던진다 · 그날은 다음에 다시 모은다', () async {
      final LimitInputsCollector c = make();
      failPrice = true;
      await expectLater(c.stateFor(draftOf()), throwsStateError);
      failPrice = false;
      expect((await c.stateFor(draftOf())).totalEquity, _d('28000'));
    });

    test('현금 계좌 없음 = ArgumentError', () {
      expect(
        () => LimitInputsCollector(
          holdings: () async => const <LedgerHolding>[],
          cash: const <String, OrderBroker>{},
          price: (String _) async => null,
          riskSymbols: const <String>{},
          ledger: _Facts(
            const LimitLedgerFacts(
              previousSnapshotEquity: null,
              flowsBefore: 0,
              flowsToday: 0,
            ),
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  test('🔴 P0S 위험 종목 = A + B 주식(금 · 채권 · 파킹 제외)', () {
    final P0sOpsConfig c = P0sOpsConfig.of(
      P0sHumanInputs(
        aSymbol: '999990',
        accountByStrategy: <String, String>{
          P0sStrategyIds.sleeveA: 'acct_x',
          P0sStrategyIds.sleeveB: 'acct_pension',
          P0sStrategyIds.sleeveC: 'acct_general',
          P0sStrategyIds.pot: 'acct_x',
        },
      ),
    );
    expect(c.riskSymbols, <String>{'999990', '133690'});
    for (final String s in <String>['411060', '0085P0', kP0sParkingSymbol]) {
      expect(c.riskSymbols.contains(s), false, reason: s);
    }
  });
}
