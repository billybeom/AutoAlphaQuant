// E7a3-1 월말 계획기 단위 시험 — 26년 재현 대조(`replay/replay_month_end_test.dart`)가 한 번도 건드리지 않은 경계를
// 손으로 지은 상태로 본다: 램프 마지막 달 · 램프 문턱 · 원화 98% · A 재진입 예약 보호 · 조달 끔/켬 · 다음 세션 없음.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

MonthEndConfig _cfg({bool funding = true}) => MonthEndConfig(
  allocB: _d('0.42'),
  coreBand: _d('0.03'),
  rampMonths: 6,
  bAssets: <(String, Decimal)>[('133690', _d('0.8')), ('411060', _d('0.2'))],
  lookbackMonths: const <int>[8, 10, 12],
  assist: SleeveBAssist(
    floor: 1 / 3,
    cutState: DirectionState.bear,
    cut: 2 / 3,
  ),
  cBondSymbol: 'IEI',
  cGoldSymbol: 'IAU',
  cBondWeight: _d('0.65'),
  cGoldWeight: _d('0.35'),
  maxGoldPctOfTotal: _d('0.08'),
  cRelativeBand: _d('0.1666666666666667'),
  bOrderThreshold: _d('0.005'),
  cOrderThreshold: _d('0.002'),
  potOrderThreshold: _d('0.005'),
  topupMinFraction: _d('0.001'),
  krwUsableFraction: _d('0.98'),
  pensionAnnualLimit: _d('18000000'),
  pensionFunding: funding,
  bSellCostRate: _d('0.00115'),
  cSellCostRate: _d('0.002'),
  potCostRate: _d('0.00115'),
);

/// 총자산 1억 · B 는 파킹만 [bPark] · C 원화 [krw] (예약 [reserved]) · 채권 [bond] · 금 [gold].
/// 월봉이 없어 B·POT 신호는 0(워밍업) — 신호 주문을 보지 않는 시험용.
MonthEndState _s({
  required int month,
  String bPark = '0',
  String krw = '50000000',
  String reserved = '0',
  String bond = '30000000',
  String gold = '20000000',
  String used = '0',
  bool nextKr = true,
  bool nextUs = true,
}) => MonthEndState(
  totalEquity: _d('100000000'),
  bAssets: <String, Decimal?>{'133690': Decimal.zero, '411060': Decimal.zero},
  bParking: _d(bPark),
  bParkingReclassified: Decimal.zero,
  krwCash: _d(krw),
  reservedKrw: _d(reserved),
  cBond: _d(bond),
  cGold: _d(gold),
  potCash: Decimal.zero,
  potAssets: const <String, Decimal?>{'133690': null, '411060': null},
  pensionUsedThisYear: _d(used),
  monthIndex: month,
  regimeState: DirectionState.neutral,
  monthlyCloses: const <String, List<double>>{},
  hasNextKrSession: nextKr,
  hasNextUsSession: nextUs,
);

List<MonthEndAction> _of(MonthEndPlan p, MonthEndActionKind k) =>
    p.actions.where((MonthEndAction a) => a.kind == k).toList();

void main() {
  group('① 램프 납입', () {
    test('6번째 달(진행 비율 1)까지는 램프가 돈다 — 7번째 달부터는 코어 밴드만', () {
      // B 목표 = 1억 × 0.42 × 1 = 4,200만 · B 파킹 3,000만 → 부족 1,200만.
      final MonthEndPlan m6 = planMonthEnd(
        _s(month: 6, bPark: '30000000'),
        _cfg(),
      );
      expect(
        _of(m6, MonthEndActionKind.rampContribution).single.amount,
        _d('12000000'),
      );
      final MonthEndPlan m7 = planMonthEnd(
        _s(month: 7, bPark: '30000000'),
        _cfg(),
      );
      expect(_of(m7, MonthEndActionKind.rampContribution), isEmpty);
      expect(
        _of(m7, MonthEndActionKind.coreBandContribution).single.amount,
        _d('12000000'),
      );
    });

    test('문턱 — 부족분이 총자산의 0.1% 이하면 납입하지 않는다', () {
      // 3번째 달 목표 = 1억 × 0.42 × 0.5 = 2,100만.
      expect(
        _of(
          planMonthEnd(_s(month: 3, bPark: '20900000'), _cfg()),
          MonthEndActionKind.rampContribution,
        ),
        isEmpty,
        reason: '부족 10만 = 0.1% 정확히 — 넘지 않음',
      );
      expect(
        _of(
          planMonthEnd(_s(month: 3, bPark: '20899999'), _cfg()),
          MonthEndActionKind.rampContribution,
        ).single.amount,
        _d('100001'),
      );
    });

    test('원화는 98% 까지만 쓴다 · 조달을 끄면 모자라도 팔지 않는다', () {
      final MonthEndPlan p = planMonthEnd(
        _s(month: 1, krw: '1000000'),
        _cfg(funding: false),
      );
      expect(
        _of(p, MonthEndActionKind.rampContribution).single.amount,
        _d('980000'),
      );
      expect(_of(p, MonthEndActionKind.raiseKrw), isEmpty);
    });

    test('조달을 켜면 모자란 만큼 금 → 채권 순서로 먼저 판다(비용 그로스업) · 납입은 연 한도까지', () {
      // 1번째 달 목표 = 700만 · 원화 100만(98% = 98만) → 부족 602만을 금(2,000만)에서.
      final MonthEndPlan p = planMonthEnd(_s(month: 1, krw: '1000000'), _cfg());
      final MonthEndAction raise = _of(p, MonthEndActionKind.raiseKrw).single;
      expect(raise.symbol, 'IAU');
      expect(raise.amount - raise.cost, closeToDecimal(_d('6020000')));
      expect(
        _of(p, MonthEndActionKind.rampContribution).single.amount,
        closeToDecimal(_d('6879600')),
        reason: '조달 뒤 원화 702만 × 98%',
      );
      final MonthEndPlan capped = planMonthEnd(
        _s(month: 1, used: '17000000'),
        _cfg(),
      );
      expect(
        _of(capped, MonthEndActionKind.rampContribution).single.amount,
        _d('1000000'),
        reason: '연 한도 남은 100만',
      );
    });
  });

  group('② 코어 밴드 — B 미달 납입은 A 재진입 예약분을 쓰지 않는다', () {
    test('조달 끔 — 예약 밖 원화(50만)까지만', () {
      final MonthEndPlan p = planMonthEnd(
        _s(month: 7, bPark: '38000000', krw: '10000000', reserved: '9500000'),
        _cfg(funding: false),
      );
      expect(
        _of(p, MonthEndActionKind.coreBandContribution).single.amount,
        _d('500000'),
      );
    });

    test('조달 켬 — 예약 밖 원화가 모자란 만큼 먼저 팔고 부족 400만을 다 납입', () {
      final MonthEndPlan p = planMonthEnd(
        _s(month: 7, bPark: '38000000', krw: '10000000', reserved: '9500000'),
        _cfg(),
      );
      expect(_of(p, MonthEndActionKind.raiseKrw), isNotEmpty);
      expect(
        _of(p, MonthEndActionKind.coreBandContribution).single.amount,
        closeToDecimal(_d('4000000')),
      );
      expect(
        p.after.krwCash >= p.after.reservedKrw - _d('0.000001'),
        isTrue,
        reason: '예약분은 그대로',
      );
    });

    test('경계는 strict — B 지분이 정확히 39%(목표 − 3%p)면 이체 없음 · 1원 모자라면 이체', () {
      expect(
        _of(
          planMonthEnd(_s(month: 7, bPark: '39000000'), _cfg()),
          MonthEndActionKind.coreBandContribution,
        ),
        isEmpty,
      );
      expect(
        _of(
          planMonthEnd(_s(month: 7, bPark: '38999999'), _cfg()),
          MonthEndActionKind.coreBandContribution,
        ).single.amount,
        _d('3000001'),
      );
    });
  });

  group('③④ 다음 세션이 없으면 주문을 내지 않는다', () {
    test('KR · US 다음 세션 없음 → B · C 주문 0', () {
      final MonthEndPlan p = planMonthEnd(
        _s(
          month: 7,
          bPark: '42000000',
          nextKr: false,
          nextUs: false,
          krw: '1000000',
          bond: '1000000',
          gold: '56000000',
        ),
        _cfg(),
      );
      expect(_of(p, MonthEndActionKind.sleeveBOrder), isEmpty);
      expect(_of(p, MonthEndActionKind.sleeveCOrder), isEmpty);
    });
  });
}

/// Decimal 근사 비교(원 미만 1e-6).
Matcher closeToDecimal(Decimal want) => predicate<Decimal>(
  (Decimal got) => (got - want).abs() < _d('0.000001'),
  '≈ $want',
);
