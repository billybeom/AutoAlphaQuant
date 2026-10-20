// 슬리브 C · 조달 규약 중 정답지가 직접 보지 않는 것 — 03 §2-9 v2.27 P0S 비중 · 입력 거부 · 동률 순서.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

final SleeveCWeights _p0s = SleeveCWeights(cash: 0.0, bond: 0.65, gold: 0.35);

void main() {
  group('슬리브 C 목표 — P0S 비중(v2.27 · 현금성 0 / 미10년 0.65 / 금 0.35)', () {
    test('상한 안 — 현금성 0', () {
      final SleeveCTargets r = sleeveCUsdTargets(
        usdTotal: _d('10000000'),
        totalEquity: _d('100000000'),
        weights: _p0s,
        maxGoldPctOfTotal: 0.08,
      );
      expect(r.gold, _d('3500000'));
      expect(r.bond, _d('6500000'));
      expect(r.cash, Decimal.zero);
    });
    test('금 상한 구속 — 초과분은 현금성 칸에 남는다(비중 0 이어도)', () {
      final SleeveCTargets r = sleeveCUsdTargets(
        usdTotal: _d('40000000'),
        totalEquity: _d('100000000'),
        weights: _p0s,
        maxGoldPctOfTotal: 0.08,
      );
      expect(r.gold, _d('8000000'));
      expect(r.bond, _d('26000000'));
      expect(r.cash, _d('6000000'));
      expect(r.total, _d('40000000'));
    });
    test('금 상한 경계 — 비중 몫과 상한이 같으면 그 값', () {
      final SleeveCTargets r = sleeveCUsdTargets(
        usdTotal: _d('20000000'),
        totalEquity: _d('87500000'),
        weights: _p0s,
        maxGoldPctOfTotal: 0.08,
      );
      expect(r.gold, _d('7000000'));
      expect(r.cash, Decimal.zero);
    });
  });

  group('슬리브 C — 입력 거부', () {
    test('비중 합 ≠ 1 · 범위 밖 · NaN', () {
      expect(
        () => SleeveCWeights(cash: 0.4, bond: 0.35, gold: 0.3),
        throwsArgumentError,
      );
      expect(
        () => SleeveCWeights(cash: -0.1, bond: 0.75, gold: 0.35),
        throwsArgumentError,
      );
      expect(
        () => SleeveCWeights(cash: 1.1, bond: -0.45, gold: 0.35),
        throwsArgumentError,
      );
      expect(
        () => SleeveCWeights(cash: double.nan, bond: 0.65, gold: 0.35),
        throwsArgumentError,
      );
    });
    test('음수 잔액·총자산 · 상한 범위 밖', () {
      SleeveCTargets run({
        String usd = '1',
        String eq = '1',
        double cap = 0.08,
      }) => sleeveCUsdTargets(
        usdTotal: _d(usd),
        totalEquity: _d(eq),
        weights: _p0s,
        maxGoldPctOfTotal: cap,
      );
      expect(() => run(usd: '-1'), throwsArgumentError);
      expect(() => run(eq: '-1'), throwsArgumentError);
      expect(() => run(cap: -0.01), throwsArgumentError);
      expect(() => run(cap: 1.01), throwsArgumentError);
      expect(
        () => run(cap: double.nan),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.name,
            'name',
            'maxGoldPctOfTotal',
          ),
        ),
      );
    });
    test('달러 유입은 고정 비율 · 음수 유입 거부', () {
      final SleeveCInflow r = sleeveCAllocateInflow(
        inflow: _d('10000000'),
        currency: InflowCurrency.usd,
        weights: SleeveCWeights(cash: 0.40, bond: 0.35, gold: 0.25),
      );
      expect(r.krwCash, Decimal.zero);
      expect(r.usd.cash, _d('4000000'));
      expect(r.usd.bond, _d('3500000'));
      expect(r.usd.gold, _d('2500000'));
      expect(
        () => sleeveCAllocateInflow(
          inflow: _d('-1'),
          currency: InflowCurrency.krw,
          weights: _p0s,
        ),
        throwsArgumentError,
      );
    });
  });

  group('조달 순서', () {
    test('잉여가 같으면 입력 순서대로(안정 정렬)', () {
      FundingPlan run(Map<SleeveId, Decimal> values) => fundingOrder(
        values: values,
        targets: <SleeveId, Decimal>{
          for (final SleeveId s in values.keys) s: _d('100'),
        },
        need: _d('15'),
      );
      final FundingPlan ac = run(<SleeveId, Decimal>{
        SleeveId.a: _d('110'),
        SleeveId.c: _d('110'),
      });
      expect(ac.takes.map((FundingTake t) => t.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.c,
      ]);
      final FundingPlan ca = run(<SleeveId, Decimal>{
        SleeveId.c: _d('110'),
        SleeveId.a: _d('110'),
      });
      expect(ca.takes.map((FundingTake t) => t.sleeve), <SleeveId>[
        SleeveId.c,
        SleeveId.a,
      ]);
    });
    test('B 만 잉여면 아무것도 빼지 않고 전액 부족', () {
      final FundingPlan r = fundingOrder(
        values: <SleeveId, Decimal>{
          SleeveId.b: _d('200'),
          SleeveId.c: _d('80'),
        },
        targets: <SleeveId, Decimal>{
          SleeveId.b: _d('100'),
          SleeveId.c: _d('100'),
        },
        need: _d('10'),
      );
      expect(r.takes, isEmpty);
      expect(r.shortfall, _d('10'));
    });
    test('요구 0 이면 빼지 않는다', () {
      final FundingPlan r = fundingOrder(
        values: <SleeveId, Decimal>{SleeveId.c: _d('200')},
        targets: <SleeveId, Decimal>{SleeveId.c: _d('100')},
        need: Decimal.zero,
      );
      expect(r.takes, isEmpty);
      expect(r.shortfall, Decimal.zero);
    });
    test('입력 거부 — 음수 요구 · 슬리브 집합이 다름', () {
      expect(
        () => fundingOrder(
          values: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          targets: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          need: _d('-1'),
        ),
        throwsArgumentError,
      );
      expect(
        () => fundingOrder(
          values: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          targets: <SleeveId, Decimal>{SleeveId.a: _d('1')},
          need: _d('1'),
        ),
        throwsArgumentError,
      );
      expect(
        () => fundingOrder(
          values: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          targets: <SleeveId, Decimal>{
            SleeveId.c: _d('1'),
            SleeveId.a: _d('1'),
          },
          need: _d('1'),
        ),
        throwsArgumentError,
      );
    });
  });
}
