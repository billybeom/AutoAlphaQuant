// GV-11 거래비용(AC-B11) · GV-11e 구간 경계 · 미국 fail-closed · GV-11d 참여율 절단 · GV-19 비용의 손익
// 반영 · GV-24 보유비용 — 03 §5-6 · §5-7.
//
// 정답지 = 05 v1.22 본문 블록 원문(vectors/SOURCES.md). 설정 = 02 §4 `costs.kr`(kr_costs_fixture.dart).
// 🔴 05 GV-11 의 a·b 는 «소형주»라 개별주 세율(ETF 아님)로 계산한다. P0S 의 ETF 매도세 0 은 단위 시험 몫.
// 🔴 GV-19 기대값은 증권거래세 0.18% 시절 값이다(05 검산 «18,000»). 통합 경로는 그 설정으로 정답지와
//    맞추고, 현행 0.20% 로는 매도 비용이 GV-11b 와 같아야 함을 따로 본다(설계 13 §8 R13).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';
import 'kr_costs_fixture.dart';

Market _market(Object? code) => switch (asString(code)) {
  'KR' => Market.kr,
  'US' => Market.us,
  final String other => throw StateError('정답지 시장 코드가 낯설다: $other'),
};

LimitSide _side(Object? code) => switch (asString(code)) {
  'BUY' => LimitSide.buy,
  'SELL' => LimitSide.sell,
  final String other => throw StateError('정답지 매매 방향이 낯설다: $other'),
};

TradeCost _cost(Map<String, Object?> c, {String? market}) => tradeCost(
  market: _market(market ?? c['market']),
  side: _side(c['side']),
  orderValue: asDecimal(c['order_value']),
  adv20: asDecimal(c['adv20']),
  sigmaDaily: asDouble(c['sigma_daily']),
  isEtf: false,
  config: krCostsFromSpec(),
);

void _expectAmount(Decimal actual, Object? expected, double tol, String what) {
  expect(
    actual.toDouble(),
    closeTo(asDouble(expected), tol),
    reason: '$what ${actual.toString()}',
  );
}

void main() {
  group('GV-11 거래비용 — total 에 시장충격 포함', () {
    final Map<String, Object?> v = loadVector('gv11_trade_cost.json');
    final Map<String, Object?> tol = asObject(v['tolerance']);
    final double amounts = asDouble(tol['amounts']);
    final double ratios = asDouble(tol['ratios']);
    test('허용오차가 필드별로 나뉘어 있다(v1.5 — 비율에 0.01 을 쓰면 시장충격을 빼먹어도 통과)', () {
      expect(amounts, 0.01);
      expect(ratios, 1e-8);
    });
    final List<Map<String, Object?>> cases = asObjectList(v['cases']);
    for (int i = 0; i < cases.length; i++) {
      final Map<String, Object?> c = cases[i];
      final Map<String, Object?> e = asObject(c['expected']);
      test(
        '11${'abc'[i]} ${c['side']} adv20=${c['adv20']} σ=${c['sigma_daily']}',
        () {
          final TradeCost r = _cost(c, market: asString(v['market']));
          _expectAmount(r.commission, e['commission'], amounts, 'commission');
          _expectAmount(r.tax, e['tax'], amounts, 'tax');
          _expectAmount(r.slippage, e['slippage'], amounts, 'slippage');
          _expectAmount(r.marketImpact, e['market_impact'], amounts, 'impact');
          _expectAmount(r.total, e['total'], amounts, 'total');
          if (e.containsKey('impact_pct')) {
            expect(r.impactPct, closeTo(asDouble(e['impact_pct']), ratios));
          }
          // 02 §3 불변식 — total = 네 항목의 합.
          expect(r.total, r.commission + r.tax + r.slippage + r.marketImpact);
        },
      );
    }
    test('왕복 a + b = 143,000원(05 «왕복 = 1.43%»)', () {
      final TradeCost buy = _cost(cases[0], market: 'KR');
      final TradeCost sell = _cost(cases[1], market: 'KR');
      expect(buy.total + sell.total, Decimal.fromInt(143000));
    });
  });

  group('GV-11e 슬리피지 구간 경계(>=) · 미국 fail-closed', () {
    final Map<String, Object?> v = loadVector('gv11e_tier_boundary_us.json');
    final double amounts = asDouble(asObject(v['tolerance'])['amounts']);
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      final Map<String, Object?> e = asObject(c['expected']);
      test('${c['id']} ${c['market']} adv20=${c['adv20']}', () {
        if (e.containsKey('raises')) {
          expect(asString(e['raises']), 'NotImplementedError');
          expect(() => _cost(c), throwsA(isA<UnimplementedError>()));
          return;
        }
        final TradeCost r = _cost(c);
        _expectAmount(r.slippage, e['slippage'], amounts, 'slippage');
        _expectAmount(r.commission, e['commission'], amounts, 'commission');
        _expectAmount(r.total, e['total'], amounts, 'total');
        expect(r.tax, Decimal.zero, reason: '매수는 거래세 없음');
        expect(r.marketImpact, Decimal.zero, reason: 'σ = 0');
      });
    }
  });

  group('GV-11d 참여율 절단', () {
    final Map<String, Object?> v = loadVector('gv11d_participation.json');
    final Map<String, Object?> input = asObject(v['input']);
    final Map<String, Object?> e = asObject(v['expected']);
    test('5,000만 원하는데 거래대금 5억 × 3% = 1,500만만 오늘, 나머지 이월', () {
      final ParticipationCut r = participationCut(
        desiredValue: asDecimal(input['desired_value']),
        adv20: asDecimal(input['adv20']),
        participationRate: asDouble(input['participation_rate']),
      );
      expect(r.allowedValue, asDecimal(e['allowed_value']));
      expect(r.deferredValue, asDecimal(e['deferred_value']));
    });
  });

  group('GV-19 비용이 손익에 실제로 들어간다(통합)', () {
    final Map<String, Object?> v = loadVector('gv19_cost_in_pnl.json');
    final Map<String, Object?> input = asObject(v['input']);
    final Map<String, Object?> trade = asObjectList(input['trades']).single;
    final Map<String, Object?> e = asObject(v['expected']);
    final double amounts = asDouble(asObject(v['tolerance'])['amounts']);
    test('설정은 GV-11 과 같다(02 §4 `costs.kr`)', () {
      expect(asString(input['costs']), 'GV-11 설정과 동일');
    });

    RoundTripPnl run(KrCostConfig config) {
      expect(asString(trade['market']), 'KR');
      return roundTripPnl(
        entryPrice: asDecimal(trade['entry_price']),
        exitPrice: asDecimal(trade['exit_price']),
        quantity: asInt(trade['quantity']),
        adv20: asDecimal(trade['adv20']),
        sigmaDaily: asDouble(trade['sigma_daily']),
        isEtf: false,
        config: config,
      );
    }

    test('정답지 원문(0.18% 시절 설정) — 매수가 = 매도가인데 net = −비용', () {
      final RoundTripPnl r = run(
        krCostsFromSpec(taxRateSell: kGv19StaleTaxRate),
      );
      _expectAmount(r.grossPnl, e['gross_pnl'], amounts, 'gross');
      _expectAmount(r.buyCost, e['buy_cost'], amounts, 'buy');
      _expectAmount(r.sellCost, e['sell_cost'], amounts, 'sell');
      _expectAmount(r.totalCost, e['total_cost'], amounts, 'total');
      _expectAmount(r.netPnl, e['net_pnl'], amounts, 'net');
    });

    test(
      '현행 0.20% — 매도 비용 = GV-11b 81,500 · net −143,000(정답지 79,500 은 낡았다 · R13)',
      () {
        final RoundTripPnl r = run(krCostsFromSpec());
        final Map<String, Object?> gv11b = asObject(
          asObjectList(
            loadVector('gv11_trade_cost.json')['cases'],
          )[1]['expected'],
        );
        expect(r.buyCost, Decimal.fromInt(61500));
        expect(r.sellCost, asDecimal(gv11b['total']));
        expect(r.netPnl, Decimal.fromInt(-143000));
      },
    );
  });

  group('GV-24 보유비용(총보수) — 일할 복리 · 백테스트 전용', () {
    final Map<String, Object?> v = loadVector('gv24_holding_cost.json');
    final Map<String, Object?> tol = asObject(v['tolerance']);
    final double amounts = asDouble(tol['amounts']);
    final double ratios = asDouble(tol['ratios']);
    test('마크업 1.15 는 정답지 er 에 이미 곱해져 있다(e1 0.00115 = 0.100% × 1.15)', () {
      expect(asDouble(asObject(v['config'])['expense_ratio_markup']), 1.15);
    });
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test('${c['id']} er=${c['expense_ratio']} days=${c['trading_days']}', () {
        final Decimal start = asDecimal(c['position_value']);
        final Decimal r = applyHoldingCost(
          positionValue: start,
          expenseRatio: asDouble(c['expense_ratio']),
          tradingDays: asInt(c['trading_days']),
          tradingDaysPerYear: kTradingDaysPerYear,
        );
        _expectAmount(r, c['expected_value'], amounts, 'value');
        if (c.containsKey('expected_cost')) {
          _expectAmount(start - r, c['expected_cost'], amounts, 'cost');
        }
      });
    }
    test('sleeve_b_weighted — 0.0019205(v2.4 정정값)', () {
      final Map<String, Object?> w = asObject(v['sleeve_b_weighted']);
      final double er = weightedExpenseRatio(<({double er, double weight})>[
        for (final Map<String, Object?> a in asObjectList(w['assets']))
          (er: asDouble(a['er']), weight: asDouble(a['w'])),
      ]);
      expect(er, closeTo(asDouble(w['expected_weighted_er']), ratios));
    });
  });
}
