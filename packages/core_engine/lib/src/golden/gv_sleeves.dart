// 골든벡터 슬리브 · 배분 계열 판정(E11o-c1 · 설계 13 §8 R164) — GV-20 · 23 · 38 · GV-22 · 35 · 36 · GV-37 · 28d · GV-42.
//
// 🔴 옛 시험(`test/golden/gv20_23_38 · gv22_35_36 · gv37_28d · gv42_*_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다
//    (시험 = 폰 같은 판정 · 두 벌 0).
// 🔴 GV-35 · GV-37 은 생성기(`gen_v220_vectors.py`)가 비중 · 상한 · 목표 · 한도를 **기본 인자로 숨겨** 계산했다.
//    발주자 결정(2026-10-20 · 설계 13 §8 R14 ①)대로 그 값을 아래에 드러내 적고 «식»만 본다 — P0S 의 값은 GV-P0S(CI)가 잰다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show SleeveId;

import '../decimal_rules.dart' show multiply, promoteRatio;
import '../portfolio/allocation.dart' show AllocationTargets, resolveAllocation;
import '../portfolio/core_band.dart'
    show CoreBandDirection, CoreBandMove, coreBandMove;
import '../portfolio/deposit.dart' show DepositAllocation, allocateDeposit;
import '../portfolio/funding.dart' show FundingPlan, fundingOrder;
import '../portfolio/sleeve_c.dart'
    show
        InflowCurrency,
        SleeveCInflow,
        SleeveCTargets,
        SleeveCWeights,
        sleeveCAllocateInflow,
        sleeveCUsdTargets;
import '../signals/seasonal_exit.dart' show seasonalExitFraction;
import '../signals/sleeve_b_tranche.dart' show sleeveBTargetWeight;
import 'golden_runner.dart';

/// 생성기 허용오차(`TOL = 1e-9`) — 금액이 1억 단위라 원 단위 1e-6 으로 본다(GV-35 · 36 · 37).
const double _tol = 1e-6;

/// «n케이스» 머리 판정(옛 시험 `expect(cases, hasLength(n))`).
GvCase _count(String id, List<Object?> cases, int n) =>
    GvCase(id, () => (GvProbe()..same(cases.length, n, '케이스 수')).failure);

/// GV-20 슬리브 B 3-트랜치 SMA(AC-B13) · GV-23 계절성 부분 청산(AC-B16) · GV-38 4월 청산 기본값 = 전량(AC-B26 일부)
/// — 03 §2-7-2 · 3 · §5-3-2.
///
/// 🔵 GV-23 은 enabled 경로라 P0S 에서 돌지 않지만, GV-38-4 가 «enabled 경로는 GV-23 그대로»를 같은 함수로 묻기 때문에
/// 함께 본다. 🔵 GV-23 의 매도 금액은 «비율 × 슬리브 금액» 검산이다 — 종목별 배분(§5-3-2 v2.9)은 주문 산출의 몫.
class Gv20SleeveSignals implements GoldenFamily {
  /// 만든다.
  const Gv20SleeveSignals();

  @override
  String get id => 'GV-20';

  @override
  Set<String> get files => const <String>{
    'gv20_sleeve_b_tranche.json',
    'gv23_partial_exit.json',
    'gv35_38_decisions.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> v20 = b.json('gv20_sleeve_b_tranche.json');
    final Map<String, Object?> common = gvObject(v20['common']);
    final List<int> lookbacks = gvIntList(common['lookback_months']);
    final double tol20 = gvDouble(v20['tolerance']);

    final Map<String, Object?> v23 = b.json('gv23_partial_exit.json');
    final Map<String, Object?> partial = gvObject(
      gvObject(v23['config'])['partial'],
    );
    final Map<String, Object?> tol23 = gvObject(v23['tolerance']);

    final List<Map<String, Object?>> c38 = gvObjectList(
      b.json('gv35_38_decisions.json')['GV-38'],
    );

    return <GvCase>[
      for (final Map<String, Object?> c in gvObjectList(v20['cases']))
        GvCase('GV-20 ${c['id']} → ${c['expected_ratio']}', () {
          final List<double> head = <double>[
            for (final double? x in gvNumList(common['monthly_closes_head']))
              x ?? (throw const FormatException('monthly_closes_head 에 null')),
          ];
          final GvProbe p = GvProbe();
          final List<double> closes;
          if (c.containsKey('last_close')) {
            closes = <double>[...head, gvDouble(c['last_close'])];
          } else {
            // b5 — «head only (11개월)»: 가장 긴 룩백 12 에 하나 모자란다.
            p.truth(
              gvString(c['monthly_closes']).startsWith('head only'),
              'monthly_closes = head only',
            );
            closes = head;
          }
          return (p..close(
                sleeveBTargetWeight(closes, lookbackMonths: lookbacks),
                gvDouble(c['expected_ratio']),
                tol20,
                'ratio',
              ))
              .failure;
        }),
      for (final Map<String, Object?> c in gvObjectList(v23['cases']))
        GvCase('GV-23 ${c['id']} score=${c['trend_score_kr']}', () {
          final Map<String, Object?> override = c.containsKey('config_override')
              ? gvObject(gvObject(c['config_override'])['partial'])
              : const <String, Object?>{};
          final Object? enabled = override['enabled'] ?? partial['enabled'];
          final Object? score = c['trend_score_kr'];
          final double f = seasonalExitFraction(
            score == null ? null : gvDouble(score),
            partialEnabled: enabled == true,
            minScore: gvDouble(partial['min_score']),
          );
          final Decimal sleeveA = gvDecimal(v23['sleeve_a_value']);
          return (GvProbe()
                ..close(
                  f,
                  gvDouble(c['expected_exit_fraction']),
                  gvDouble(tol23['fraction']),
                  'fraction',
                )
                ..close(
                  multiply(sleeveA, promoteRatio(f)).toDouble(),
                  gvDouble(c['expected_sell_value']),
                  gvDouble(tol23['amounts']),
                  'sell_value',
                ))
              .failure;
        }),
      _count('GV-38 4케이스', c38, 4),
      for (final Map<String, Object?> c in c38)
        GvCase('GV-38 ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Object? score = input['score'];
          // 생성기(`gen_v220_vectors.py` gv38_exit_fraction) 기본 인자 = enabled False · min_score 40.
          final double f = seasonalExitFraction(
            score == null ? null : gvDouble(score),
            partialEnabled: input['partial_enabled'] == true,
            minScore: 40.0,
          );
          return (GvProbe()..same(f, gvDouble(c['expected']), 'fraction'))
              .failure;
        }),
    ];
  }
}

/// GV-35 생성기의 숨은 기본 인자(`w=(0.40, 0.35, 0.25)` · `gold_cap_pct=0.08`).
final SleeveCWeights _gv35HiddenWeights = SleeveCWeights(
  cash: 0.40,
  bond: 0.35,
  gold: 0.25,
);
const double _gv35HiddenGoldCap = 0.08;

SleeveId _sleeveByWire(String wire) => SleeveId.values.firstWhere(
  (SleeveId s) => s.wire == wire,
  orElse: () => throw FormatException('정답지 슬리브가 낯설다: $wire'),
);

void _targets(GvProbe p, SleeveCTargets r, Map<String, Object?> e, double tol) {
  p
    ..close(r.cash.toDouble(), gvDouble(e['BIL']), tol, 'BIL')
    ..close(r.bond.toDouble(), gvDouble(e['IEI']), tol, 'IEI')
    ..close(r.gold.toDouble(), gvDouble(e['IAU']), tol, 'IAU');
}

/// GV-22 슬리브 C 통화 분리 · 금 상한(AC-B15) · GV-35 분모 = 달러 잔액 · GV-36 조달 상대 = 잉여 큰 순 · B 제외
/// (AC-B26 일부) — 03 §2-9-1 · 2 · §5-2 v2.19 · v2.21.
class Gv22SleeveC implements GoldenFamily {
  /// 만든다.
  const Gv22SleeveC();

  @override
  String get id => 'GV-22';

  @override
  Set<String> get files => const <String>{
    'gv22_sleeve_c_gold_cap.json',
    'gv35_38_decisions.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<String, Object?> v = b.json('gv22_sleeve_c_gold_cap.json');
    final Map<String, Object?> config = gvObject(v['config']);
    final Map<String, Object?> w = gvObject(config['usd_weights']);
    final SleeveCWeights weights = SleeveCWeights(
      cash: gvDouble(w['BIL']),
      bond: gvDouble(w['IEI']),
      gold: gvDouble(w['IAU']),
    );
    final double cap = gvDouble(config['max_gold_pct_of_total']);
    final String krwTicker = gvString(config['krw_cash_ticker']);
    final double amounts = gvDouble(gvObject(v['tolerance'])['amounts']);
    final Map<String, Object?> d = b.json('gv35_38_decisions.json');
    final List<Map<String, Object?>> c35 = gvObjectList(d['GV-35']);
    final List<Map<String, Object?>> c36 = gvObjectList(d['GV-36']);

    Map<SleeveId, Decimal> read(Object? m) => <SleeveId, Decimal>{
      for (final MapEntry<String, Object?> kv in gvObject(m).entries)
        _sleeveByWire(kv.key): gvDecimal(kv.value),
    };

    return <GvCase>[
      GvCase(
        'GV-22 불변식은 «합 = 달러 잔액» 하나',
        () =>
            (GvProbe()
                  ..same(gvStringList(v['invariants']).length, 1, 'invariants'))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(v['cases']))
        GvCase('GV-22 ${gvString(c['id'])}', () {
          final GvProbe p = GvProbe();
          if (c.containsKey('inflow')) {
            // q1 — 원화 유입은 전액 원화 현금성.
            p.same(gvString(c['currency']), 'KRW', 'currency');
            final SleeveCInflow r = sleeveCAllocateInflow(
              inflow: gvDecimal(c['inflow']),
              currency: InflowCurrency.krw,
              weights: weights,
            );
            final Map<String, Object?> e = gvObject(c['expected']);
            return (p
                  ..same(e.keys.toList(), <String>[krwTicker], 'keys')
                  ..same(r.krwCash, gvDecimal(e[krwTicker]), 'krw_cash')
                  ..same(r.usd.total, Decimal.zero, 'usd'))
                .failure;
          }
          final Decimal usd = gvDecimal(c['sleeve_c_usd_total']);
          final SleeveCTargets r = sleeveCUsdTargets(
            usdTotal: usd,
            totalEquity: gvDecimal(c['total_equity']),
            weights: weights,
            maxGoldPctOfTotal: cap,
          );
          p.close(r.total.toDouble(), usd.toDouble(), amounts, '합');
          if (c.containsKey('expected')) {
            _targets(p, r, gvObject(c['expected']), amounts);
          } else {
            // q4 — 상한을 빼먹은 결과가 나오면 오답.
            final Map<String, Object?> no = gvObject(c['expected_not']);
            p
              ..truth(
                !((r.gold.toDouble() - gvDouble(no['IAU'])).abs() <= amounts),
                'IAU 가 상한을 빼먹은 값이면 오답',
              )
              ..truth(
                !((r.cash.toDouble() - gvDouble(no['BIL'])).abs() <= amounts),
                'BIL 이 상한을 빼먹은 값이면 오답',
              );
          }
          return p.failure;
        }),
      _count('GV-35 4케이스', c35, 4),
      for (final Map<String, Object?> c in c35)
        GvCase('GV-35 ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> e = gvObject(c['expected']);
          final SleeveCTargets r = sleeveCUsdTargets(
            usdTotal: gvDecimal(input['usd_total']),
            totalEquity: gvDecimal(input['total_equity']),
            weights: _gv35HiddenWeights,
            maxGoldPctOfTotal: _gv35HiddenGoldCap,
          );
          final GvProbe p = GvProbe();
          _targets(p, r, e, _tol);
          // 원화는 인자로 받지도 않는다 — 그대로 남아야 한다.
          return (p..same(
                gvDouble(e['KRW_CASH']),
                gvDouble(input['krw_cash']),
                'KRW_CASH',
              ))
              .failure;
        }),
      _count('GV-36 4케이스', c36, 4),
      for (final Map<String, Object?> c in c36)
        GvCase('GV-36 ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Decimal need = gvDecimal(input['need']);
          final FundingPlan r = fundingOrder(
            values: read(input['values']),
            targets: read(input['targets']),
            need: need,
          );
          final List<Object?> e = c['expected'] is List<Object?>
              ? c['expected']! as List<Object?>
              : throw const FormatException('expected 가 목록이 아니다');
          final GvProbe p = GvProbe()..same(r.takes.length, e.length, '조달 수');
          if (r.takes.length != e.length) return p.failure;
          Decimal taken = Decimal.zero;
          for (int i = 0; i < e.length; i++) {
            final List<Object?> pair = e[i]! as List<Object?>;
            p
              ..same(
                r.takes[i].sleeve,
                _sleeveByWire(gvString(pair[0])),
                '[$i]',
              )
              ..close(
                r.takes[i].amount.toDouble(),
                gvDouble(pair[1]),
                _tol,
                '[$i]',
              );
            taken += r.takes[i].amount;
          }
          return (p..same(r.shortfall, need - taken, 'shortfall')).failure;
        }),
    ];
  }
}

/// GV-37 생성기의 숨은 기본 인자.
const double _gv37TargetW = 0.287;
const double _gv37Band = 0.03;
final Decimal _gv37NoLimit = Decimal.parse(
  '1000000000000000000',
); // 1e18 = 사실상 ∞

Decimal _opt(Map<String, Object?> m, String key, Decimal fallback) =>
    m.containsKey(key) ? gvDecimal(m[key]) : fallback;

SleeveId _sleeveByName(String name) => switch (name) {
  'sleeve_b' => SleeveId.b,
  'sleeve_c' => SleeveId.c,
  'satellite' => SleeveId.satellite,
  _ => throw FormatException('정답지 슬리브 이름이 낯설다: $name'),
};

/// GV-37 코어 밴드 전액 자동 + 연금 한도 다리(AC-B26 일부) · GV-28d 납입 배분(AC-B21 일부) — 03 §5-2 v2.20 · v2.21 ·
/// §5-5b DEPOSIT v2.23. 🔵 GV-37 의 기대 금액 = 재분류 + 납입 합계(생성기는 둘을 더해 하나로 낸다).
class Gv37CoreBandDeposit implements GoldenFamily {
  /// 만든다.
  const Gv37CoreBandDeposit();

  @override
  String get id => 'GV-37';

  @override
  Set<String> get files => const <String>{
    'gv35_38_decisions.json',
    'gv28d_deposit.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> c37 = gvObjectList(
      b.json('gv35_38_decisions.json')['GV-37'],
    );
    final Map<String, Object?> v28 = b.json('gv28d_deposit.json');
    final List<Map<String, Object?>> c28 = gvObjectList(v28['GV-28d']);
    final double tol28 = gvDouble(gvObject(v28['_meta'])['tolerance']);
    return <GvCase>[
      _count('GV-37 8케이스', c37, 8),
      for (final Map<String, Object?> c in c37)
        GvCase('GV-37 ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final CoreBandMove r = coreBandMove(
            bValue: gvDecimal(input['b_value']),
            totalEquity: gvDecimal(input['total_equity']),
            targetWeight: _gv37TargetW,
            band: _gv37Band,
            krwCash: _opt(input, 'c_cash', _gv37NoLimit),
            reservedKrw: _opt(input, 'reserved_krw', Decimal.zero),
            reclassifiedPark: _opt(input, 'park_c', Decimal.zero),
            annualQuota: _opt(input, 'annual_quota', _gv37NoLimit),
            pensionUsedThisYear: _opt(input, 'pension_used', Decimal.zero),
          );
          final List<Object?> e = c['expected']! as List<Object?>;
          final CoreBandDirection want = switch (gvString(e[0])) {
            'B->C' => CoreBandDirection.bToC,
            'C->B' => CoreBandDirection.cToB,
            'NONE' => CoreBandDirection.none,
            final String other => throw FormatException('낯선 방향: $other'),
          };
          return (GvProbe()
                ..same(r.direction, want, 'direction')
                ..close(r.total.toDouble(), gvDouble(e[1]), _tol, 'total'))
              .failure;
        }),
      _count('GV-28d 8케이스', c28, 8),
      for (final Map<String, Object?> c in c28)
        GvCase('GV-28d ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> e = gvObject(c['expected']);
          final Map<SleeveId, Decimal> currents = <SleeveId, Decimal>{};
          final Map<SleeveId, Decimal> targets = <SleeveId, Decimal>{};
          for (final MapEntry<String, Object?> kv in gvObject(
            input['sleeves'],
          ).entries) {
            final Map<String, Object?> s = gvObject(kv.value);
            currents[_sleeveByName(kv.key)] = gvDecimal(s['current']);
            targets[_sleeveByName(kv.key)] = gvDecimal(s['target']);
          }
          final DepositAllocation r = allocateDeposit(
            amount: gvDecimal(input['amount']),
            currents: currents,
            targets: targets,
            remainingPensionQuota: gvDecimal(input['quota']),
          );
          final List<Object?> filled = e['filled']! as List<Object?>;
          final GvProbe p = GvProbe()
            ..same(r.filled.length, filled.length, '채운 수');
          if (r.filled.length == filled.length) {
            for (int i = 0; i < filled.length; i++) {
              final List<Object?> pair = filled[i]! as List<Object?>;
              p
                ..same(
                  r.filled[i].sleeve,
                  _sleeveByName(gvString(pair[0])),
                  '[$i]',
                )
                ..close(
                  r.filled[i].amount.toDouble(),
                  gvDouble(pair[1]),
                  tol28,
                  '[$i]',
                );
            }
          }
          return (p..close(
                r.residual.toDouble(),
                gvDouble(e['residual']),
                tol28,
                'residual',
              ))
              .failure;
        }),
    ];
  }
}

/// GV-42 자본 배분 설정 검증(AC-B30) — 02 §5-7 규칙 4b · 6b · §4-2 6b 단서(v2.31 새틀 0 허용).
///
/// 🔴 거부 사유는 정답지가 문구의 앞 40자(`reason_contains`)를 준다 — 앞부분 일치로 본다.
/// 🔵 기대값은 생성기가 소수 10자리로 반올림했다(`gv42_gen_vectors.py` `round(v, 10)`) — 허용오차 1e-9.
class Gv42Allocation implements GoldenFamily {
  /// 만든다.
  const Gv42Allocation();

  @override
  String get id => 'GV-42';

  @override
  Set<String> get files => const <String>{'gv42_allocation.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    const double tol = 1e-9;
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv42_allocation.json')['GV-42'],
    );
    return <GvCase>[
      GvCase(
        'GV-42 12케이스 = 허용 6 · 거부 6(05 v1.20 이후 총계)',
        () =>
            (GvProbe()
                  ..same(cases.length, 12, '케이스 수')
                  ..same(
                    cases
                        .where(
                          (Map<String, Object?> c) =>
                              gvObject(c['expected'])['accepted'] == true,
                        )
                        .length,
                    6,
                    '허용 수',
                  ))
                .failure,
      ),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-42 ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> e = gvObject(c['expected']);
          final Object? rawCustom = input['custom'];
          final Map<String, double>? custom = rawCustom == null
              ? null
              : <String, double>{
                  for (final MapEntry<String, Object?> kv in gvObject(
                    rawCustom,
                  ).entries)
                    kv.key: gvDouble(kv.value),
                };
          AllocationTargets run() => resolveAllocation(
            profile: gvString(input['profile']),
            custom: custom,
          );
          if (e['accepted'] == true) {
            final AllocationTargets r = run();
            return (GvProbe()
                  ..close(r.sleeveA, gvDouble(e['sleeve_a']), tol, 'sleeve_a')
                  ..close(r.sleeveB, gvDouble(e['sleeve_b']), tol, 'sleeve_b')
                  ..close(r.sleeveC, gvDouble(e['sleeve_c']), tol, 'sleeve_c')
                  ..close(
                    r.satelliteTarget,
                    gvDouble(e['satellite_target']),
                    tol,
                    'satellite_target',
                  )
                  ..close(
                    r.satelliteBandLow,
                    gvDouble(e['satellite_band_low']),
                    tol,
                    'satellite_band_low',
                  )
                  ..close(
                    r.satelliteBandHigh,
                    gvDouble(e['satellite_band_high']),
                    tol,
                    'satellite_band_high',
                  ))
                .failure;
          }
          final String prefix = gvString(e['reason_contains']);
          return (GvProbe()
                ..same(gvString(e['error']), 'ValueError', 'error')
                ..throws(
                  run,
                  (Object x) =>
                      x is ArgumentError &&
                      x.message.toString().startsWith(prefix),
                  'ArgumentError(사유 앞부분 «$prefix»)',
                ))
              .failure;
        }),
    ];
  }
}
