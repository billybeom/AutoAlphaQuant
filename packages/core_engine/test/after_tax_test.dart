// M3-5 · M2-9 ⓒ 세후 산식 단위 시험 — 손으로 셀 수 있는 작은 원장으로 tax_lib 규약을 하나씩 본다.
// 26년 골든 대조(`aftertax_full_S7` 4자리)는 `test/replay/replay_aftertax_test.dart` 몫이다.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/src/numeric/pandas_compat.dart';
import 'package:domain_contracts/domain_contracts.dart' show TaxLadderBranch;
import 'package:test/test.dart';

TaxLedgerRow _row(
  String date,
  String sleeve,
  String symbol,
  String side,
  double qty,
  double gross,
) => TaxLedgerRow(
  date: date,
  sleeve: sleeve,
  symbol: symbol,
  side: side,
  qty: qty,
  gross: gross,
);

void main() {
  group('pandas 수치 — 카한 무리 합 · 파이썬 정수 반올림 · 짝 합산', () {
    test('카한 합은 단순 합이 버리는 1 을 되살린다(1e16 + 1 + 1) · 키 오름차순', () {
      final List<(String, double)> g = kahanGroupSum<String>(<(String, double)>[
        ('b', 1e16),
        ('a', 3.0),
        ('b', 1.0),
        ('b', 1.0),
      ]);
      expect(g.map(((String, double) t) => t.$1), <String>['a', 'b']);
      expect(g[0].$2, 3.0);
      expect(1e16 + 1.0 + 1.0, 1e16, reason: '단순 합은 1 을 두 번 다 잃는다');
      expect(g[1].$2, 10000000000000002.0);
    });

    test('pyRoundInt — 동률은 짝수 · 음수 대칭', () {
      expect(pyRoundInt(0.5), 0);
      expect(pyRoundInt(1.5), 2);
      expect(pyRoundInt(2.5), 2);
      expect(pyRoundInt(-2.5), -2);
      expect(pyRoundInt(54574243.5), 54574244);
      expect(pyRoundInt(24289863.12), 24289863);
      expect(() => pyRoundInt(double.nan), throwsArgumentError);
    });

    test('npSum — 8개 미만은 차례로 · 그 이상은 누산기 8개', () {
      // 0.1 을 9 번: 차례 합과 짝 합이 다른 자리에서 반올림한다.
      final List<double> nine = List<double>.filled(9, 0.1);
      double seq = 0.0;
      for (final double x in nine) {
        seq += x;
      }
      final double pair =
          (((0.1 + 0.1) + (0.1 + 0.1)) + ((0.1 + 0.1) + (0.1 + 0.1))) + 0.1;
      expect(npSum(nine), pair);
      expect(npSum(nine), isNot(seq));
      expect(npSum(<double>[0.1, 0.2, 0.3]), 0.1 + 0.2 + 0.3);
    });
  });

  group('realizedGains — 평균 단가 · 양의 건만 · 날짜별 합', () {
    final List<TaxLedgerRow> ledger = <TaxLedgerRow>[
      _row('2021-01-04', 'POT', 'X', 'BUY', 10, 1000),
      _row('2021-01-05', 'POT', 'X', 'BUY', 10, 3000), // 단가 200
      _row('2021-01-05', 'POT', 'CASH', 'IN', 1, 5000), // 현금 행은 건너뛴다
      _row('2021-01-06', 'POT', 'X', 'SELL', 5, 1500), // 이익 500
      _row('2021-01-06', 'POT', 'Y', 'BUY', 1, 100),
      _row('2021-01-06', 'POT', 'Y', 'SELL', 1, 150), // 이익 50 — 같은 날 합 550
      _row('2021-01-07', 'POT', 'X', 'SELL', 5, 800), // 손실 −200 — 통산하지 않는다
      _row('2021-01-07', 'POT', 'Z', 'SELL', 1, 999), // 보유 0 — 건너뛴다
      _row('2021-01-04', 'C', 'IEI', 'BUY', 1, 100),
      _row('2021-01-07', 'C', 'IEI', 'SELL', 1, 130), // 이익 30
      _row('2021-01-07', 'C', 'BIL', 'BUY', 1, 100),
      _row('2021-01-08', 'C', 'BIL', 'SELL', 1, 200), // 종목 밖
    ];

    test('POT — 2021-01-06 에 550 하나(손실·현금·보유 0 행 제외)', () {
      expect(realizedGains(ledger, 'POT'), <(String, double)>[
        ('2021-01-06', 550.0),
      ]);
    });

    test('이익이 정확히 0 인 매도는 싣지 않는다(양의 건만) · 현금 행은 매매 꼴이어도 건너뛴다', () {
      final List<TaxLedgerRow> l = <TaxLedgerRow>[
        _row('2021-01-04', 'POT', 'X', 'BUY', 10, 1000),
        _row('2021-01-05', 'POT', 'X', 'SELL', 5, 500), // 원가 그대로 — 이익 0
        _row('2021-01-04', 'POT', 'CASH', 'BUY', 1, 100),
        _row('2021-01-06', 'POT', 'CASH', 'SELL', 1, 900), // 현금 — 이익으로 보지 않는다
      ];
      expect(realizedGains(l, 'POT'), isEmpty);
    });

    test('C — IEI·IAU 만(BIL 제외)', () {
      expect(
        realizedGains(ledger, 'C', symbols: const <String>{'IEI', 'IAU'}),
        <(String, double)>[('2021-01-07', 30.0)],
      );
      expect(realizedGains(ledger, 'C'), hasLength(2));
    });

    test('손실 매도 뒤 남은 원가 = 평균 단가 × 남은 수량(다음 매도 이익의 기준)', () {
      final List<TaxLedgerRow> l = <TaxLedgerRow>[
        ...ledger.where((TaxLedgerRow r) => r.symbol == 'X'),
        _row('2021-01-08', 'POT', 'X', 'SELL', 10, 2500), // 원가 2000 → 이익 500
      ];
      expect(realizedGains(l, 'POT'), <(String, double)>[
        ('2021-01-06', 500.0),
        ('2021-01-08', 500.0),
      ]);
    });
  });

  group('applyDailyTax — «세금 ÷ 전날 자산» 차감 뒤 다시 쌓기', () {
    const List<String> dates = <String>[
      '2021-01-04',
      '2021-01-05',
      '2021-01-07',
    ];
    const List<double> e = <double>[100, 110, 121];

    test('세금 날의 수익률만 줄고 이후 수익률은 그대로', () {
      final List<double> out = applyDailyTax(dates, e, <(String, double)>[
        ('2021-01-05', 11),
      ]);
      expect(out[0], 100);
      expect(out[1], closeTo(99, 1e-9)); // +10% − 11/100
      expect(out[2], closeTo(108.9, 1e-9)); // 그 뒤 +10%
    });

    test('세션이 아닌 날은 그 뒤 첫 세션에 · 마지막 세션 뒤는 버린다 · 첫 세션은 전날이 없어 멈춘다', () {
      expect(
        applyDailyTax(dates, e, <(String, double)>[('2021-01-06', 11)]),
        applyDailyTax(dates, e, <(String, double)>[('2021-01-07', 11)]),
      );
      expect(
        applyDailyTax(dates, e, <(String, double)>[('2021-02-01', 11)]),
        applyDailyTax(dates, e, const <(String, double)>[]),
      );
      expect(
        () => applyDailyTax(dates, e, <(String, double)>[('2021-01-04', 1)]),
        throwsStateError,
      );
    });
  });

  test('comprehensiveExtra — 연 합이 2,000만을 넘는 해만 · 초과분 × (한계 − 15.4%) · 그 해 마지막 이익일', () {
    final List<(String, double)> x = comprehensiveExtra(<(String, double)>[
      ('2020-03-02', 15e6),
      ('2020-06-01', 10e6),
      ('2021-01-05', 5e6),
    ], 0.385);
    expect(x, hasLength(1));
    expect(x.single.$1, '2020-06-01');
    expect(x.single.$2, closeTo(5e6 * 0.231, 1e-6));
  });

  test('comprehensiveExtra — 연 합은 pandas `Series.sum`(짝 합산 · 8개 미만은 차례로)이지 카한이 아니다', () {
    // 차례 합은 1e16 뒤의 1 두 개를 잃는다 — 카한이면 되살아나 세금이 0.462 만큼 커진다.
    final List<(String, double)> x = comprehensiveExtra(<(String, double)>[
      ('2020-03-02', 1e16),
      ('2020-04-01', 1.0),
      ('2020-05-04', 1.0),
    ], 0.385);
    expect(
      x.single.$2,
      (1e16 - kFinancialIncomeThreshold) * (0.385 - kDividendTaxRate),
    );
  });

  test('과세 대상은 0 아래로 내려가지 않는다(미수령 원금 > 연금계좌 잔고)', () {
    final AfterTaxFull f = afterTaxFull(
      AfterTaxInputs(
        dates: const <String>['2020-01-02', '2021-01-04'],
        equity: const <double>[1e8, 1.1e8],
        ledger: <TaxLedgerRow>[
          _row('2020-01-31', 'XFER', 'C->B', 'MOVE', 2e7, 2e7),
        ], // 미수령 1,100만
        pensionEndB: 5e6,
        pensionEndParkC: 0,
      ),
    );
    expect(f.inputs!.nonCredited, 11e6);
    expect(f.inputs!.taxablePension, 0.0);
    final AfterTaxBranch b = f.branches[TaxLadderBranch.specPotTaxFree]!;
    expect(b.points['wd_16p5']!.endMult, b.points['after_pot_c']!.endMult);
  });

  group('afterTaxFull — 작은 원장', () {
    const List<String> dates = <String>[
      '2020-01-02',
      '2020-06-01',
      '2021-01-04',
      '2021-06-01',
      '2022-01-03',
    ];
    const List<double> eq = <double>[1e8, 1.1e8, 1.2e8, 1.3e8, 1.4e8];
    final List<TaxLedgerRow> ledger = <TaxLedgerRow>[
      _row('2020-01-31', 'XFER', 'C->B', 'MOVE', 6e6, 6e6),
      _row(
        '2020-02-28',
        'XFER',
        'C->B',
        'MOVE',
        5e6,
        5e6,
      ), // 2020 합 1,100만 — 공제 900 · 미수령 200
      _row('2020-03-31', 'XFER', 'C->B(재분류환원)', 'MOVE', 7e6, 7e6), // 납입 아님
      _row('2021-02-26', 'XFER', 'C->B', 'MOVE', 3e6, 3e6),
      _row('2020-06-01', 'POT', 'X', 'BUY', 100, 4e6),
      _row('2021-01-04', 'POT', 'X', 'SELL', 100, 5e6), // POT 이익 100만
      _row('2020-06-01', 'C', 'IAU', 'BUY', 10, 1e6),
      _row('2021-06-01', 'C', 'IAU', 'SELL', 10, 1.2e6), // C 이익 20만
    ];
    final AfterTaxFull full = afterTaxFull(
      AfterTaxInputs(
        dates: dates,
        equity: eq,
        ledger: ledger,
        pensionEndB: 5e7,
        pensionEndParkC: 1e6,
        externalFlows: List<double>.filled(5, 0.0),
      ),
    );
    final double yrs = 732 / 365.25;

    test('연금 입력 — 공제 1,200만 · 미수령 200만 · 과세 대상 = 잔고 5,100만 − 200만', () {
      final AfterTaxFullInputs i = full.inputs!;
      expect(i.credited, 12e6);
      expect(i.nonCredited, 2e6);
      expect(i.contribTotal, 14e6);
      expect(i.pensionEnd, 51e6);
      expect(i.taxablePension, 49e6);
      expect(i.refundNominal, 12e6 * 0.132);
      expect(i.potGains, 1e6);
      expect(i.cGains, 2e5);
      expect(i.yearsOverThreshold, 0);
      expect(i.maxYearGain, 1.2e6);
    });

    test('정본 갈래 — 파킹 과세 0 이라 세금 전 = 파킹 과세 뒤 · 방어 자산 과세는 C 이익만큼 낮다', () {
      final Map<String, AfterTaxPoint> p =
          full.branches[TaxLadderBranch.specPotTaxFree]!.points;
      expect(
        p['pretax']!.cagrPct,
        closeTo((_pow(1.4, 1 / yrs) - 1) * 100, 1e-9),
      );
      expect(p['after_pot']!.cagrPct, p['pretax']!.cagrPct);
      expect(p['after_pot']!.endMult, p['pretax']!.endMult);
      // C 세금 = 20만 × 15.4% · 전날 자산 1.2억 → 끝 배수 1.4 × (1 − 30,800/1.3억 비율만큼)
      final double r3 = 1.3e8 / 1.2e8 - 1 - 2e5 * 0.154 / 1.2e8;
      expect(
        p['after_pot_c']!.endMult,
        closeTo(1.1 * (1.2 / 1.1) * (1 + r3) * (1.4 / 1.3), 1e-12),
      );
    });

    test('인출 층 — 끝 자산 − 과세 대상 × 세율(+ 환급) · 재투자 환급은 다음 해 5월 말 뒤 첫 세션부터', () {
      final AfterTaxBranch b = full.branches[TaxLadderBranch.specPotTaxFree]!;
      final double end2 = b.points['after_pot_c']!.endMult * 1e8;
      expect(
        b.points['wd_16p5']!.endMult,
        closeTo((end2 - 49e6 * 0.165) / 1e8, 1e-12),
      );
      expect(
        b.points['wd_5p5_refund_nominal']!.endMult,
        closeTo((end2 - 49e6 * 0.055 + 12e6 * 0.132) / 1e8, 1e-12),
      );
      // 2020 공제 900만 → 2021-06-01(세션) 부터 굴림 · 2021 공제 300만 → 2022-05-31 뒤 세션 없음 = 명목
      final List<double> e2 = applyDailyTax(dates, eq, <(String, double)>[
        ('2021-06-01', 2e5 * 0.154),
      ]);
      expect(
        b.refundReinvestedKrw,
        closeTo(9e6 * 0.132 * (e2.last / e2[3]) + 3e6 * 0.132, 1e-6),
      );
      expect(
        b.points['wd_16p5']!.cagrPct,
        closeTo(
          (_pow(b.points['wd_16p5']!.endMult, 1 / yrs)) * 100 - 100,
          1e-9,
        ),
      );
    });

    test('반사실 — 파킹 과세가 층을 낮춘다 · 종합과세 구간 밖이면 26.4% = 38.5% = 단일', () {
      final Map<String, AfterTaxPoint> flat =
          full.branches[TaxLadderBranch.cfPotTaxableFlat]!.points;
      expect(flat['after_pot']!.cagrPct, lessThan(flat['pretax']!.cagrPct));
      for (final TaxLadderBranch c in <TaxLadderBranch>[
        TaxLadderBranch.cfPotTaxableComp26,
        TaxLadderBranch.cfPotTaxableComp38,
      ]) {
        // 🔵 종합과세 갈래는 넘는 해가 없어도 tax_lib 가 자산곡선을 한 번 더 다시 쌓는다
        //    (`_apply_daily_tax(e2, 빈 목록)`) — 그 반올림만큼(1 ULP 안팎) 다를 수 있다.
        for (final String k in kAfterTaxPointKeys) {
          expect(
            full.branches[c]!.points[k]!.endMult,
            closeTo(flat[k]!.endMult, 1e-13),
            reason: '$c $k',
          );
        }
      }
    });

    test('외부 현금흐름이 있으면 거부(무납입 전용 · §8 미결 18) · 길이가 다르면 거부', () {
      expect(
        () => afterTaxFull(
          AfterTaxInputs(
            dates: dates,
            equity: eq,
            ledger: ledger,
            pensionEndB: 0,
            pensionEndParkC: 0,
            externalFlows: <double>[0, 0, 100000, 0, 0],
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => afterTaxFull(
          AfterTaxInputs(
            dates: dates,
            equity: eq.sublist(1),
            ledger: ledger,
            pensionEndB: 0,
            pensionEndParkC: 0,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  test('골든 블록 왕복 — fromGoldenJson → toGoldenJson 이 갈래 4개를 글자 그대로 돌려준다', () {
    final Map<String, Object?> block =
        (jsonDecode(
              File('test/golden/vectors/golden_p0s.json').readAsStringSync(),
            ) as Map<String, Object?>)['aftertax_full_S7']!
            as Map<String, Object?>;
    final AfterTaxFull g = AfterTaxFull.fromGoldenJson(block);
    expect(g.inputs, isNull);
    expect(g.branches.keys, unorderedEquals(TaxLadderBranch.values));
    expect(g.toGoldenJson(), <String, Object?>{
      for (final String k in kTaxLadderGoldenKeys.values) k: block[k],
    });
  });
}

// 손 계산 기대값은 closeTo 로 본다 — lib 와 같은 `pow` 여도 비트 비교가 아니다.
double _pow(double x, double y) => math.pow(x, y).toDouble();
