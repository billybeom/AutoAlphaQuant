// 비용 모델 규약 중 정답지(GV-11·11e·11d·19·24)가 직접 보지 않는 것 — 03 §5-6 · §5-7 · 02 §4.
//
// 🔴 P0S 주문은 전부 국내상장 ETF 라 매도세가 0 이다(02 §4 `etf_tax_rate_sell`). GV-11 은 소형주만 본다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

final Decimal _tenMillion = Decimal.parse('10000000');
final Decimal _bigAdv = Decimal.parse('20000000000');

TradeCost _cost({
  LimitSide side = LimitSide.sell,
  Decimal? orderValue,
  Decimal? adv20,
  double sigma = 0.0,
  bool isEtf = false,
  KrCostConfig? config,
}) => tradeCost(
  market: Market.kr,
  side: side,
  orderValue: orderValue ?? _tenMillion,
  adv20: adv20 ?? _bigAdv,
  sigmaDaily: sigma,
  isEtf: isEtf,
  config: config ?? krCostsFromSpec(),
);

Matcher _argError(String name) => throwsA(
  isA<ArgumentError>().having((ArgumentError e) => e.name, 'name', name),
);

void main() {
  group('증권거래세 — ETF 면제 · 매수 없음', () {
    test('ETF 매도 = 0 · 개별주 매도 = 0.20%', () {
      expect(_cost(isEtf: true).tax, Decimal.zero);
      expect(_cost().tax, Decimal.fromInt(20000));
    });
    test('ETF 면제율도 설정값을 읽는다(0 고정이 아니다)', () {
      final KrCostConfig c = KrCostConfig(
        commissionRate: 0.00015,
        taxRateSell: 0.0020,
        etfTaxRateSell: 0.0005,
        slippageByAdv: krCostsFromSpec().slippageByAdv,
        impactY: 1.0,
        participationRate: 0.03,
      );
      expect(_cost(isEtf: true, config: c).tax, Decimal.fromInt(5000));
    });
    test('매수는 ETF 든 아니든 0', () {
      expect(_cost(side: LimitSide.buy).tax, Decimal.zero);
      expect(_cost(side: LimitSide.buy, isEtf: true).tax, Decimal.zero);
    });
    test('P0S 꼴 — ETF 1,000만 매도(거래대금 200억) = 수수료 1,500 + 슬리피지 10,000', () {
      expect(_cost(isEtf: true).total, Decimal.fromInt(11500));
    });
  });

  group('슬리피지 구간표', () {
    test('오름차순으로 받아도 내림차순으로 정렬해 첫 구간을 고른다', () {
      final KrCostConfig c = KrCostConfig(
        commissionRate: 0.00015,
        taxRateSell: 0.0020,
        etfTaxRateSell: 0.0,
        slippageByAdv: krCostsFromSpec().slippageByAdv.reversed.toList(),
        impactY: 1.0,
        participationRate: 0.03,
      );
      expect(c.slippageByAdv.first.minAdv, Decimal.parse('10000000000'));
      expect(_cost(config: c).slippage, Decimal.fromInt(10000));
    });
    test('min_adv 0 구간이 없거나 표가 비면 거부(0 거래대금이 미정의가 된다 · 05 GV-11 v1.5)', () {
      KrCostConfig make(List<SlippageTier> tiers) => KrCostConfig(
        commissionRate: 0.00015,
        taxRateSell: 0.0020,
        etfTaxRateSell: 0.0,
        slippageByAdv: tiers,
        impactY: 1.0,
        participationRate: 0.03,
      );
      expect(
        () => make(<SlippageTier>[
          SlippageTier(minAdv: Decimal.parse('500000000'), rate: 0.006),
        ]),
        throwsArgumentError,
      );
      expect(() => make(<SlippageTier>[]), throwsArgumentError);
    });
  });

  group('시장충격', () {
    test('σ > 0 인데 거래대금 0 이면 정의되지 않는다고 거부', () {
      expect(
        () => _cost(adv20: Decimal.zero, sigma: 0.02),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message.toString(),
            'message',
            contains('거래대금 0'),
          ),
        ),
      );
    });
    test('계수 Y 를 설정에서 읽는다 — Y 2.0 이면 GV-11c 의 두 배', () {
      final KrCostConfig c = KrCostConfig(
        commissionRate: 0.00015,
        taxRateSell: 0.0020,
        etfTaxRateSell: 0.0,
        slippageByAdv: krCostsFromSpec().slippageByAdv,
        impactY: 2.0,
        participationRate: 0.03,
      );
      final TradeCost r = _cost(
        side: LimitSide.buy,
        adv20: Decimal.parse('500000000'),
        sigma: 0.025,
        config: c,
      );
      expect(r.impactPct, closeTo(0.007071067811865475, 1e-15));
      expect(r.marketImpact.toDouble(), closeTo(70710.68, 0.01));
    });
    test('음수 σ · NaN σ 는 거부', () {
      expect(() => _cost(sigma: -0.01), _argError('sigmaDaily'));
      expect(() => _cost(sigma: double.nan), _argError('sigmaDaily'));
    });
    test('음수 주문금액 · 거래대금은 거부', () {
      expect(() => _cost(orderValue: Decimal.fromInt(-1)), throwsArgumentError);
      expect(() => _cost(adv20: Decimal.fromInt(-1)), throwsArgumentError);
    });
  });

  group('참여율 절단', () {
    test('상한 아래면 전부 오늘 · 이월 0', () {
      final ParticipationCut r = participationCut(
        desiredValue: Decimal.parse('10000000'),
        adv20: Decimal.parse('500000000'),
        participationRate: 0.03,
      );
      expect(r.allowedValue, Decimal.parse('10000000'));
      expect(r.deferredValue, Decimal.zero);
    });
    test('정확히 상한이면 이월 0', () {
      final ParticipationCut r = participationCut(
        desiredValue: Decimal.parse('15000000'),
        adv20: Decimal.parse('500000000'),
        participationRate: 0.03,
      );
      expect(r.allowedValue, Decimal.parse('15000000'));
      expect(r.deferredValue, Decimal.zero);
    });
  });

  group('왕복 손익', () {
    test('값이 오른 왕복 — 총손익은 (매도가 − 매수가) × 수량 · 매도 비용은 매도가 기준', () {
      final RoundTripPnl r = roundTripPnl(
        entryPrice: Decimal.parse('10000'),
        exitPrice: Decimal.parse('12000'),
        quantity: 1000,
        adv20: Decimal.parse('800000000'),
        sigmaDaily: 0.0,
        isEtf: false,
        config: krCostsFromSpec(),
      );
      expect(r.grossPnl, Decimal.fromInt(2000000));
      // 매수 1,000만: 1,500 + 60,000 · 매도 1,200만: 1,800 + 24,000 + 72,000
      expect(r.buyCost, Decimal.fromInt(61500));
      expect(r.sellCost, Decimal.fromInt(97800));
      expect(r.netPnl, Decimal.fromInt(2000000 - 61500 - 97800));
    });
    test('ETF 왕복은 매도세가 없다', () {
      final RoundTripPnl r = roundTripPnl(
        entryPrice: Decimal.parse('10000'),
        exitPrice: Decimal.parse('10000'),
        quantity: 1000,
        adv20: _bigAdv,
        sigmaDaily: 0.0,
        isEtf: true,
        config: krCostsFromSpec(),
      );
      expect(r.totalCost, Decimal.fromInt(23000));
    });
  });

  group('보유비용 — 인자 검사', () {
    Decimal hold({double er = 0.001, int days = 10, int perYear = 252}) =>
        applyHoldingCost(
          positionValue: _tenMillion,
          expenseRatio: er,
          tradingDays: days,
          tradingDaysPerYear: perYear,
        );
    test('음수 · NaN 총보수 거부', () {
      expect(() => hold(er: -0.001), _argError('expenseRatio'));
      expect(() => hold(er: double.nan), _argError('expenseRatio'));
    });
    test('음수 거래일 · 연 거래일 0 거부', () {
      expect(() => hold(days: -1), throwsArgumentError);
      expect(
        () => hold(perYear: 0),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message.toString(),
            'message',
            contains('연 거래일은 1 이상'),
          ),
        ),
      );
    });
    test('연 거래일 설정을 읽는다(252 하드코딩 아님)', () {
      expect(hold(er: 0.01, days: 1, perYear: 100), Decimal.parse('9999000'));
    });
  });
}
