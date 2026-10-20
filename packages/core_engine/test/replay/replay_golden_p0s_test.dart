// E6e — G-GV 의 GV-P0S 몫: Dart 재현 실행의 지표가 정본 정답지 `golden_p0s.json`(05 §GV-P0S · v2.32)과
// % 단위 소수 4자리 반올림으로 완전히 같은가(05 허용오차 «반올림 후 완전 일치»).
//
// 범위 = 설계 13 §7 P-2 결정(발주자 2026-10-20): 스택 S6 · S7(CAGR · MDD · vol · 주문 934 · 비용 · S6 = S7) ·
// 스트레스 3종(순서 포함 · worst-of) · 세후 S7 · 금 비중 · 실현 배분. S5_P0 · 부트스트랩은 범위 밖 · `aftertax_full_S7` 은 E7a.
// 🔵 반올림 전 값은 `fixtures/metrics_parity.json`(tool/export_replay_metrics.py)과 비트로 맞춘다 — 4자리 일치가
//    우연(경계 근처 반올림)이 아님을 보이기 위해서다. CAGR 만 C `pow` 를 타서 ULP 2 까지 허용한다.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'parity_hash.dart';
import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_metrics.dart';
import 'replay_regime.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Map<String, Object?> _obj(Map<String, Object?> m, String k) =>
    m[k]! as Map<String, Object?>;

double _d(Map<String, Object?> m, String k) => (m[k]! as num).toDouble();

void main() {
  final Map<String, Object?> golden = _json(
    'test/golden/vectors/golden_p0s.json',
  );
  final Map<String, Object?> parity = _json(
    'test/replay/fixtures/metrics_parity.json',
  );
  final ReplayMarket market = ReplayMarket.build();
  final ReplayRegime regime = ReplayRegime.build();

  const Map<ReplayVariant, String> names = <ReplayVariant, String>{
    ReplayVariant.s7: 'S7_P0S',
    ReplayVariant.s6: 'S6_P0S_residual',
    ReplayVariant.delay1: 'delay1',
    ReplayVariant.nogate: 'nogate',
    ReplayVariant.nocut: 'nocut',
  };
  const List<ReplayVariant> stress = <ReplayVariant>[
    ReplayVariant.delay1,
    ReplayVariant.nogate,
    ReplayVariant.nocut,
  ];
  final Map<ReplayVariant, ReplayEngine> runs = <ReplayVariant, ReplayEngine>{};
  final Map<ReplayVariant, PerfStats> perf = <ReplayVariant, PerfStats>{};
  late List<String> dates7;
  late List<double> eq7, flows7;

  setUpAll(() {
    for (final ReplayVariant v in names.keys) {
      final ReplayEngine e = ReplayEngine(market, regime, variant: v)..run();
      runs[v] = e;
      final List<String> dates = <String>[
        for (final DailyRow d in e.daily) d.date,
      ];
      final List<double> eq = <double>[
        for (final DailyRow d in e.daily) d.values['equity']!,
      ];
      // 참조 엔진 P0S 는 수시 납입이 없어 `ext_flow` 가 늘 0 이다(정답지가 확인) — 스택은 그래도 TWR 로 다시 쌓는다.
      final List<double> flows = List<double>.filled(eq.length, 0.0);
      perf[v] = stress.contains(v)
          ? harnessStats(dates, eq)
          : harnessStats(dates, eq, flows: flows);
      if (v == ReplayVariant.s7) {
        dates7 = dates;
        eq7 = eq;
        flows7 = flows;
      }
    }
  });

  void expectTrio(PerfStats s, Map<String, Object?> g, String label) {
    expect(pct4(s.cagr), _d(g, 'cagr_pct'), reason: '$label CAGR');
    expect(pct4(s.mdd), _d(g, 'mdd_pct'), reason: '$label MDD');
    expect(pct4(s.vol), _d(g, 'vol_pct'), reason: '$label vol');
  }

  test('정답지 범위 — 수시 납입 없음 · 반올림 전 값 생성 판(파이썬 · pandas · numpy)', () {
    final Map<String, Object?> pr = _obj(parity, 'runs');
    for (final String n in names.values) {
      expect(_obj(pr, n)['ext_flow_nonzero'], 0, reason: n);
    }
    expect(_obj(golden, 'meta')['version'], 'v2.32');
    expect(_obj(golden, 'meta')['preset'], 'P0S');
  });

  group('GV-P0S-S 스택', () {
    test('S7 · S6 — CAGR · MDD · vol 4자리 · 주문 934 · 비용 24,289,863원', () {
      final Map<String, Object?> st = _obj(golden, 'stack');
      for (final ReplayVariant v in <ReplayVariant>[
        ReplayVariant.s7,
        ReplayVariant.s6,
      ]) {
        final Map<String, Object?> g = _obj(st, names[v]!);
        expectTrio(perf[v]!, g, names[v]!);
        expect(runs[v]!.ledger, hasLength(g['n_orders']));
        // N2: `round(float(ledger["cost_krw"].sum()), 0)` — pandas 합 = numpy 짝 합산.
        expect(
          pyRound(
            npSum(<double>[for (final LedgerRow r in runs[v]!.ledger) r.cost]),
            0,
          ),
          _d(g, 'cost_krw'),
        );
      }
    });

    test('S6 = S7 — 네 지표가 반올림 전 값까지 같다(05 판별점 ②)', () {
      final PerfStats a = perf[ReplayVariant.s7]!, b = perf[ReplayVariant.s6]!;
      expect(<double>[b.cagr, b.mdd, b.vol], <double>[a.cagr, a.mdd, a.vol]);
      expect(
        runs[ReplayVariant.s6]!.ledger.length,
        runs[ReplayVariant.s7]!.ledger.length,
      );
    });
  });

  test(
    'GV-P0S-X 스트레스 3종 — 4자리 · worst-of −14.3391 · 순서 nocut < delay1 < nogate',
    () {
      final Map<String, Object?> sx = _obj(golden, 'stress_S7');
      for (final ReplayVariant v in stress) {
        expectTrio(perf[v]!, _obj(sx, names[v]!), names[v]!);
      }
      final double worst = <double>[
        for (final ReplayVariant v in stress) pct4(perf[v]!.mdd),
      ].reduce((double a, double b) => a < b ? a : b);
      expect(worst, _d(sx, 'worst_of_mdd_pct'));
      expect(worst, greaterThan(-15.0), reason: '채택 전제 −15% 이내');
      // 05 판정 규약: 최악 nocut · 근소한 차로 delay1 — 두 값의 순서까지.
      expect(
        perf[ReplayVariant.nocut]!.mdd,
        lessThan(perf[ReplayVariant.delay1]!.mdd),
      );
      expect(
        perf[ReplayVariant.delay1]!.mdd,
        lessThan(perf[ReplayVariant.nogate]!.mdd),
      );
    },
  );

  test('GV-P0S-T 세후 S7 — POT 15.4% · 4자리 · 세금 93건이 참조 엔진과 비트 일치', () {
    final ReplayEngine e7 = runs[ReplayVariant.s7]!;
    final Map<String, Object?> pa = _obj(parity, 'aftertax_S7');
    List<double> nums(String k) => <double>[
      for (final Object? x in pa[k]! as List<Object?>) (x! as num).toDouble(),
    ];
    String key((String, double) t) => '${t.$1}|${t.$2}';
    final List<(String, double)> tx = potTax(e7.ledger);
    // 🔵 N2 `sort_values("date")` 는 안정 정렬이 아니다 — 같은 날 두 건(2003-06-30 등)의 순서가 원장과 바뀌어 나온다.
    //    그래서 건별 목록은 순서 없이(날짜|값 묶음) 대조하고, 세후가 실제로 쓰는 날짜별 합은 비트로 대조한다.
    //    같은 날 최대 2건이라 합산 순서는 결과를 바꾸지 못한다(a + b = b + a).
    final List<String> wantRows = <String>[
      for (int k = 0; k < nums('tax').length; k++)
        key((
          (pa['tax_dates']! as List<Object?>)[k]! as String,
          nums('tax')[k],
        )),
    ];
    expect(tx.map(key).toList()..sort(), wantRows..sort(), reason: '세금 93건');
    expect(pa['max_same_day'], lessThanOrEqualTo(2));
    final List<(String, double)> byDate = groupSumByDate(tx);
    expect(
      byDate.map(((String, double) t) => t.$1).toList(),
      pa['tax_by_date_dates'],
    );
    expect(
      byDate.map(((String, double) t) => t.$2).toList(),
      nums('tax_by_date'),
      reason: '날짜별 세금 합',
    );
    final (PerfStats s, List<double> e2) = afterTax(
      dates7,
      eq7,
      flows7,
      e7.ledger,
    );
    expect(floatHash(e2), pa['e2_sha256'], reason: '세후 자산곡선');
    expectTrio(s, _obj(golden, 'aftertax_S7'), '세후');
  });

  test('GV-P0S-T 금 총자산 비중 — 평균 · 최대 · C · B+POT · 20% 초과일 4자리', () {
    final List<DailyRow> d7 = runs[ReplayVariant.s7]!.daily;
    final Map<String, Object?> pg = _obj(parity, 'gold_share_S7');
    expect(
      floatHash(d7.map((DailyRow d) => d.values['gold_b'])),
      pg['gold_b_sha256'],
    );
    expect(
      floatHash(d7.map((DailyRow d) => d.values['gold_pot'])),
      pg['gold_pot_sha256'],
    );
    final GoldShare gs = GoldShare(d7);
    expect(gs.n, pg['n']);
    final Map<String, Object?> g = _obj(golden, 'gold_share_S7');
    expect(pct4(gs.mean), _d(g, 'mean_pct'));
    expect(pct4(gs.max), _d(g, 'max_pct'));
    expect(pct4(gs.cMean), _d(g, 'c_mean_pct'));
    expect(pct4(gs.bPotMean), _d(g, 'b_pot_mean_pct'));
    expect(pct4(gs.gt20), _d(g, 'gt20_days_pct'));
    // 05: 최대치가 모니터링 임계 20% 를 넘는 날이 있는 것이 정상 동작.
    expect(gs.max, greaterThan(0.20));
  });

  test('GV-P0S-T 실현 배분 — 9항목 4자리 · C(POT 포함) 51.5525%', () {
    final Map<String, double> ra = realizedAlloc(runs[ReplayVariant.s7]!.daily);
    final Map<String, Object?> g = _obj(golden, 'realized_alloc_S7');
    expect(ra.keys.map((String k) => '${k}_pct').toSet(), g.keys.toSet());
    for (final MapEntry<String, double> kv in ra.entries) {
      expect(pct4(kv.value), _d(g, '${kv.key}_pct'), reason: kv.key);
    }
  });

  group('반올림 전 값 = 참조 엔진(metrics_parity.json)', () {
    void expectStats(PerfStats s, Map<String, Object?> w, String label) {
      expect(
        ulpDistance(s.cagr, _d(w, 'cagr')),
        lessThanOrEqualTo(2),
        reason: '$label CAGR (C pow)',
      );
      expect(s.mdd, _d(w, 'mdd'), reason: '$label MDD');
      expect(s.vol, _d(w, 'vol'), reason: '$label vol');
      expect(s.years, _d(w, 'years'), reason: '$label 연수');
      expect(s.endMult, _d(w, 'end_mult'), reason: '$label 배수');
    }

    test('다섯 실행 성과', () {
      for (final MapEntry<ReplayVariant, String> kv in names.entries) {
        expectStats(
          perf[kv.key]!,
          _obj(_obj(parity, 'runs'), kv.value),
          kv.value,
        );
      }
    });

    test('세후 · 금 비중 · 실현 배분', () {
      final ReplayEngine e7 = runs[ReplayVariant.s7]!;
      expectStats(
        afterTax(dates7, eq7, flows7, e7.ledger).$1,
        _obj(parity, 'aftertax_S7'),
        '세후',
      );
      final GoldShare gs = GoldShare(e7.daily);
      final Map<String, Object?> pg = _obj(parity, 'gold_share_S7');
      expect(
        <double>[gs.mean, gs.max, gs.cMean, gs.bPotMean, gs.gt20],
        <double>[
          _d(pg, 'mean'),
          _d(pg, 'max'),
          _d(pg, 'c_mean'),
          _d(pg, 'b_pot_mean'),
          _d(pg, 'gt20'),
        ],
      );
      final Map<String, Object?> pr = _obj(parity, 'realized_alloc_S7');
      final Map<String, double> ra = realizedAlloc(e7.daily);
      for (final MapEntry<String, double> kv in ra.entries) {
        expect(kv.value, _d(pr, kv.key), reason: kv.key);
      }
    });
  });

  group('파이썬 반올림 pyRound', () {
    test('이진수 정확값 기준 — 2.675 → 2.67 · 1.005 → 1.0(둘 다 이진수로는 아래쪽)', () {
      expect(pyRound(2.675, 2), 2.67);
      expect(pyRound(1.005, 2), 1.0);
      expect(pyRound(0.125, 2), 0.12); // 정확한 동률 → 짝수
      expect(pyRound(0.375, 2), 0.38);
    });

    test('동률은 짝수 — 0.03125 → 0.0312 · 0.5 → 0 · 1.5 → 2 · 2.5 → 2 · 음수 대칭', () {
      expect(pyRound(0.03125, 4), 0.0312);
      expect(pyRound(0.5, 0), 0.0);
      expect(pyRound(1.5, 0), 2.0);
      expect(pyRound(2.5, 0), 2.0);
      expect(pyRound(-2.5, 0), -2.0);
      expect(pyRound(-0.03125, 4), -0.0312);
    });

    test('골든 값 — pct4 는 «× 100 뒤 4자리»', () {
      expect(pct4(-0.1259521521548862), -12.5952);
      expect(pct4(0.08889025398219029), 8.889);
      expect(pct4(0.18391304347826087), 18.3913);
      expect(pyRound(24289863.12, 0), 24289863.0);
      expect(pyRound(0.0, 4), 0.0);
    });
  });
}
