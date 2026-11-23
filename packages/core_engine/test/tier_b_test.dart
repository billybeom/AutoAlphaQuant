// E11g — 계층 B 계산(설계 13 §8 R50 T2~T4).
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;
import 'package:test/test.dart';

const TierBCard _card = TierBCard(
  b1R12mFloor: -0.15,
  b2DdFloor: -0.34,
  b3TuwMonths: 31,
);

TierBMetrics _m({double? r12m, double dd = 0, double tuw = 0}) => TierBMetrics(
  asOf: '2027-01-29',
  r12m: r12m,
  dd: dd,
  tuwMonths: tuw,
  peakDate: '2026-01-01',
);

void main() {
  group('twrIndex', () {
    test('입금 · 출금은 수익이 아니다', () {
      final List<double> idx = twrIndex(const <EquityPoint>[
        EquityPoint('2026-01-02', 100),
        EquityPoint('2026-01-05', 160, flow: 50), // 110 → +10%
        EquityPoint('2026-01-06', 120, flow: -40), // 160 → 160 = 0%
        EquityPoint('2026-01-07', 132), // +10%
      ]);
      expect(idx[0], 1);
      expect(idx[1], closeTo(1.1, 1e-12));
      expect(idx[2], closeTo(1.1, 1e-12));
      expect(idx[3], closeTo(1.21, 1e-12));
    });

    test('앞 평가 0 이하 = 그날 수익 0', () {
      final List<double> idx = twrIndex(const <EquityPoint>[
        EquityPoint('2026-01-02', 0),
        EquityPoint('2026-01-05', 100, flow: 100),
        EquityPoint('2026-01-06', 90),
      ]);
      expect(idx, <Object>[1, 1, closeTo(0.9, 1e-12)]);
    });

    test('빈 시리즈 = 빈 지수', () {
      expect(twrIndex(const <EquityPoint>[]), isEmpty);
    });
  });

  group('tierBMetrics', () {
    test('롤링 12M = 12달 전 같은 날 이하 마지막 점 · DD · TUW', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2025-12-30', 100),
        EquityPoint('2026-01-30', 120), // 기준 = 2026-01-30 이하 마지막
        EquityPoint('2026-02-02', 150), // 최고점
        EquityPoint('2026-06-30', 140),
        EquityPoint('2027-01-29', 132),
        EquityPoint('2027-02-01', 999), // 월말 뒤 — 안 본다
      ], '2027-01-29');
      expect(m.asOf, '2027-01-29');
      // 기준 = 2026-01-29 이하 마지막 = 2025-12-30(100).
      expect(m.r12m, closeTo(0.32, 1e-12));
      expect(m.dd, closeTo(132 / 150 - 1, 1e-12));
      expect(m.peakDate, '2026-02-02');
      expect(m.tuwMonths, closeTo(361 / 30.4375, 1e-12));
    });

    test('기준 날 바로 그 점이 있으면 그 점', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2025-12-30', 100),
        EquityPoint('2026-01-29', 110),
        EquityPoint('2027-01-29', 121),
      ], '2027-01-29');
      expect(m.r12m, closeTo(0.1, 1e-12));
    });

    test('12달 이력 없음 = r12 없음', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2026-02-02', 100),
        EquityPoint('2027-01-29', 80),
      ], '2027-01-29');
      expect(m.r12m, isNull);
      expect(m.dd, closeTo(-0.2, 1e-12));
    });

    test('최고점이면 DD 0 · TUW 0 · 같은 높이는 뒤 점이 최고점', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2026-11-02', 100),
        EquityPoint('2026-11-30', 120),
        EquityPoint('2026-12-15', 110),
        EquityPoint('2026-12-30', 120),
      ], '2026-12-31');
      expect(m.dd, 0);
      expect(m.tuwMonths, 0);
      expect(m.peakDate, '2026-12-30');
    });

    test('윤년 2월 29일 → 앞 해 2월 28일', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2027-02-26', 100),
        EquityPoint('2027-03-01', 999),
        EquityPoint('2028-02-29', 110),
      ], '2028-02-29');
      expect(m.r12m, closeTo(0.1, 1e-12));
    });

    test('그 달 점 없음 = TierBError', () {
      expect(
        () => tierBMetrics(const <EquityPoint>[
          EquityPoint('2026-11-30', 100),
        ], '2026-12-31'),
        throwsA(
          isA<TierBError>().having(
            (e) => e.reason,
            'reason',
            contains('2026-12'),
          ),
        ),
      );
      expect(
        () => tierBMetrics(const <EquityPoint>[
          EquityPoint('2027-01-04', 100),
        ], '2026-12-31'),
        throwsA(isA<TierBError>()),
      );
    });

    test('날짜 순 아님 · 같은 날 두 점 = ArgumentError', () {
      expect(
        () => tierBMetrics(const <EquityPoint>[
          EquityPoint('2026-12-30', 100),
          EquityPoint('2026-12-29', 100),
        ], '2026-12-31'),
        throwsArgumentError,
      );
      expect(
        () => tierBMetrics(const <EquityPoint>[
          EquityPoint('2026-12-30', 100),
          EquityPoint('2026-12-30', 100),
        ], '2026-12-31'),
        throwsArgumentError,
      );
    });

    test('입출금이 섞여도 TWR 로 본다', () {
      final TierBMetrics m = tierBMetrics(const <EquityPoint>[
        EquityPoint('2026-11-02', 100),
        EquityPoint('2026-12-30', 190, flow: 100), // 큰 입금 — 평가는 올랐어도 −10%
      ], '2026-12-31');
      expect(m.dd, closeTo(-0.1, 1e-12));
      expect(m.peakDate, '2026-11-02');
    });
  });

  group('judgeTierB', () {
    test('B1 = r12 < 하한(같으면 아님) · r12 없음 = 아님', () {
      expect(judgeTierB(_m(r12m: -0.1501), _card).b1, isTrue);
      expect(judgeTierB(_m(r12m: -0.15), _card).b1, isFalse);
      expect(judgeTierB(_m(), _card).b1, isFalse);
    });

    test('B2 = DD ≤ 하한(같으면 충족)', () {
      expect(judgeTierB(_m(dd: -0.34), _card).b2, isTrue);
      expect(judgeTierB(_m(dd: -0.3399), _card).b2, isFalse);
    });

    test('B3 = TUW > 상한(같으면 아님)', () {
      expect(judgeTierB(_m(tuw: 31.01), _card).b3, isTrue);
      expect(judgeTierB(_m(tuw: 31), _card).b3, isFalse);
    });

    test('firstCode · any · trigger', () {
      final TierBMetrics m = _m(r12m: -0.2, dd: -0.4, tuw: 40);
      final TierBVerdict all = judgeTierB(m, _card);
      expect(all.any, isTrue);
      expect(all.firstCode, 'B1');
      expect(tierBTrigger(m, _card, all), (-0.2, -0.15));

      final TierBMetrics m2 = _m(dd: -0.4, tuw: 40);
      final TierBVerdict v2 = judgeTierB(m2, _card);
      expect(v2.firstCode, 'B2');
      expect(tierBTrigger(m2, _card, v2), (-0.4, -0.34));

      final TierBMetrics m3 = _m(tuw: 40);
      final TierBVerdict v3 = judgeTierB(m3, _card);
      expect(v3.firstCode, 'B3');
      expect(tierBTrigger(m3, _card, v3), (40.0, 31.0));

      final TierBVerdict none = judgeTierB(_m(), _card);
      expect(none.any, isFalse);
      expect(none.firstCode, isNull);
      expect(tierBTrigger(_m(), _card, none), isNull);
      expect(none.toString(), contains('B1 false'));
    });

    test('하나만 충족해도 any', () {
      expect(judgeTierB(_m(dd: -0.5), _card).any, isTrue);
      expect(judgeTierB(_m(tuw: 32), _card).any, isTrue);
    });
  });

  test(
    '🔴 P0S 카드 = 발주자 확정 값(R158) — B1 −0.19 · B2 −0.24 · B3 38달 · 경계 그대로',
    () {
      final TierBCard c = p0sTierBCard()!;
      expect(c.b1R12mFloor, -0.19);
      expect(c.b2DdFloor, -0.24);
      expect(c.b3TuwMonths, 38);
      // 같은 판정식(B1 < · B2 ≤ · B3 >)을 확정 값에 그대로 건다.
      expect(judgeTierB(_m(r12m: -0.1901), c).b1, isTrue);
      expect(judgeTierB(_m(r12m: -0.19), c).b1, isFalse);
      expect(judgeTierB(_m(dd: -0.24), c).b2, isTrue);
      expect(judgeTierB(_m(dd: -0.2399), c).b2, isFalse);
      expect(judgeTierB(_m(tuw: 38.01), c).b3, isTrue);
      expect(judgeTierB(_m(tuw: 38), c).b3, isFalse);
      // 정본 26.6년의 실제 극단(보고서 §0 — 최악 1년 −10.86% · MDD −12.60% · 최장 물속 22.1달) = 하나도 걸리지 않는다.
      expect(
        judgeTierB(_m(r12m: -0.1086, dd: -0.1260, tuw: 22.1), c).any,
        isFalse,
      );
    },
  );

  // ── 🆕 R247(R50 T10 · 03 §1-5 «P0S 등록») ──
  group('🆕 R247 PROBATION 복귀 · 만료 · 상한', () {
    TierBMetrics m(double? r12) => TierBMetrics(
      asOf: '2026-07-31',
      r12m: r12,
      dd: -0.05,
      tuwMonths: 2,
      peakDate: '2026-05-29',
    );
    const TierBVerdict ok = TierBVerdict(b1: false, b2: false, b3: false);
    const TierBProbationRule rule = TierBProbationRule(
      returnR12mFloor: 0.05,
      maxJudgements: 24,
    );

    test('P0S 규칙 = 발주자 위임 값(+5% · 24회)', () {
      expect(
        (p0sProbationRule().returnR12mFloor, p0sProbationRule().maxJudgements),
        (0.05, 24),
      );
    });

    test('복귀 = r12 ≥ 문턱 AND 안 걸림 · 경계 같음 = 복귀 · r12 없음 = 아님', () {
      expect(
        judgeProbation(m(0.05), ok, observations: 1, rule: rule),
        TierBProbationOutcome.returned,
      );
      expect(
        judgeProbation(m(0.0499999), ok, observations: 1, rule: rule),
        TierBProbationOutcome.stay,
      );
      expect(
        judgeProbation(m(null), ok, observations: 1, rule: rule),
        TierBProbationOutcome.stay,
      );
      for (final TierBVerdict v in const <TierBVerdict>[
        TierBVerdict(b1: true, b2: false, b3: false),
        TierBVerdict(b1: false, b2: true, b3: false),
        TierBVerdict(b1: false, b2: false, b3: true),
      ]) {
        expect(
          judgeProbation(m(0.3), v, observations: 1, rule: rule),
          TierBProbationOutcome.stay,
        );
      }
    });

    test('만료 = 24번째 판정에서도 복귀 못 함 · 23번째 = 그대로 · 24번째 복귀 = 복귀가 먼저', () {
      expect(
        judgeProbation(m(0), ok, observations: 23, rule: rule),
        TierBProbationOutcome.stay,
      );
      expect(
        judgeProbation(m(0), ok, observations: 24, rule: rule),
        TierBProbationOutcome.expired,
      );
      expect(
        judgeProbation(m(0.2), ok, observations: 24, rule: rule),
        TierBProbationOutcome.returned,
      );
      expect(
        () => judgeProbation(m(0), ok, observations: 0, rule: rule),
        throwsArgumentError,
      );
    });

    test(
      '계획기 상한 읽기 — ACTIVE · PROBATION = 값(0~1) · RETIRED = 0 · 그 밖 · 없음 = 1',
      () {
        expect(plannerCapOf('ACTIVE', 1.0), 1.0);
        expect(plannerCapOf('PROBATION', 0.5), 0.5);
        expect(plannerCapOf('PROBATION', 1.7), 1.0);
        expect(plannerCapOf('PROBATION', -1), 0.0);
        expect(plannerCapOf('RETIRED', 1.0), 0.0);
        expect(plannerCapOf('CANDIDATE', 0.0), 1.0);
        expect(plannerCapOf('PILOT', 0.1), 1.0);
        expect(plannerCapOf(null, null), 1.0);
        expect(tierBCapReceiver(P0sStrategyIds.sleeveC), isTrue);
        for (final String id in <String>[
          P0sStrategyIds.sleeveA,
          P0sStrategyIds.sleeveB,
          P0sStrategyIds.pot,
        ]) {
          expect(tierBCapReceiver(id), isFalse);
        }
      },
    );

    test('상한 JSON 왕복 · 없음 = full', () {
      const P0sRiskCaps c = P0sRiskCaps(a: 0.5, b: 0, pot: 0.5);
      expect(P0sRiskCaps.fromJson(c.toJson()), c);
      expect(P0sRiskCaps.fromJson(null), P0sRiskCaps.full);
      expect(P0sRiskCaps.full.isFull, isTrue);
      expect(c.isFull, isFalse);
    });

    test('A 축소 매도 — 0.5 = 보유 − ⌊보유 × 0.5⌋ · 0 = 전량 · 1 · 보유 0 = 없음 · 논리 id = 한도 청산 꼴', () {
      const TradeDate me = TradeDate('2026-07-31');
      final OrderTarget t = sleeveACapTrim(
        symbol: '229200',
        heldShares: 7,
        capA: 0.5,
        judgmentDate: me,
      )!;
      expect(
        (t.logicalDecisionId, t.strategyId, t.side, t.instrument),
        (
          'RISK-P0S_A-229200-2026-07-31',
          P0sStrategyIds.sleeveA,
          OrderSide.sell,
          InstrumentKind.etf,
        ),
      );
      expect((t.sizing as ShareSizing).shares, 4);
      expect(
        sleeveACapTrim(
          symbol: '229200',
          heldShares: 7,
          capA: 0,
          judgmentDate: me,
        )!.sizing,
        isA<AllHeldSizing>(),
      );
      expect(
        sleeveACapTrim(
          symbol: '229200',
          heldShares: 7,
          capA: 1,
          judgmentDate: me,
        ),
        isNull,
      );
      expect(
        sleeveACapTrim(
          symbol: '229200',
          heldShares: 0,
          capA: 0.5,
          judgmentDate: me,
        ),
        isNull,
      );
    });
  });
}
