// E7a1 — M3-5 «무납입 4자리»: lib 세후 산식(`afterTaxFull`)을 Dart 재현 S7(26년 원장)에 돌린 값이
// 정본 골든 `golden_p0s.json` 의 `aftertax_full_S7`(tax_lib · 갈래 4 × 층 9 + 재투자 환급 + 입력 12)과 글자까지 같은가.
//
// 🔵 06 M3-5 검증 ① «무납입 원장에서 tax_lib 와 4자리 일치(하드 회귀 기준선)» · M2-9 ⓓ — G-GV 채점 항목은 아니다(참고 벡터).
// 🔵 반올림 전 값은 `fixtures/aftertax_parity.json`(tool/export_replay_aftertax.py — tax_lib 함수를 그대로 부른 값)과
//    비트로 맞댄다. CAGR 만 C `pow` 라 ULP 2 까지 허용한다(이 PC 실측 ULP 0). 종합과세 갈래의 연 합은 같은 날
//    POT·C 이익을 «POT 다음 C» 로 잇는다 — pandas `sort_index` 는 안정 정렬이 아니지만 이 데이터에서는 비트 일치.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show TaxLadderBranch;
import 'package:test/test.dart';

import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_metrics.dart' show ulpDistance;
import 'replay_regime.dart';

Map<String, Object?> _obj(Object? o) => o! as Map<String, Object?>;
double _d(Object? o) => (o! as num).toDouble();

void main() {
  final Map<String, Object?> golden = _obj(
    _obj(
      jsonDecode(
        File('test/golden/vectors/golden_p0s.json').readAsStringSync(),
      ),
    )['aftertax_full_S7'],
  );
  final Map<String, Object?> parity = _obj(
    jsonDecode(
      File('test/replay/fixtures/aftertax_parity.json').readAsStringSync(),
    ),
  );
  final ReplayEngine e = ReplayEngine(
    ReplayMarket.build(),
    ReplayRegime.build(),
  )..run();
  final AfterTaxInputs inputs = AfterTaxInputs(
    dates: <String>[for (final DailyRow d in e.daily) d.date],
    equity: <double>[for (final DailyRow d in e.daily) d.values['equity']!],
    ledger: <TaxLedgerRow>[
      for (final LedgerRow r in e.ledger)
        TaxLedgerRow(
          date: r.date,
          sleeve: r.sleeve,
          symbol: r.symbol,
          side: r.side,
          qty: r.qty,
          gross: r.gross,
        ),
    ],
    pensionEndB: e.daily.last.values['B']!,
    pensionEndParkC: e.daily.last.values['c_park_c']!,
    // 참조 엔진 P0S 는 수시 납입이 없다(E6e 정답지 `ext_flow_nonzero` 0).
    externalFlows: List<double>.filled(e.daily.length, 0.0),
  );
  final AfterTaxFull full = afterTaxFull(inputs);

  test('aftertax_full_S7 — 갈래 4 × 층 9 · 재투자 환급 · 입력 12 가 골든과 글자까지 같다', () {
    final Map<String, Object?> want = <String, Object?>{
      for (final MapEntry<String, Object?> kv in golden.entries)
        if (kv.key != 'assumption') kv.key: kv.value,
    };
    expect(full.toGoldenJson(), want);
  });

  test('중간값 — POT·C 이익 · 연도별 납입 · 공제 · 과세 대상이 tax_lib 와 비트 일치', () {
    final Map<String, Object?> i = _obj(parity['intermediate']);
    List<(String, double)> pairs(String dk, String vk) => <(String, double)>[
      for (int k = 0; k < (i[dk]! as List<Object?>).length; k++)
        (
          (i[dk]! as List<Object?>)[k]! as String,
          _d((i[vk]! as List<Object?>)[k]),
        ),
    ];
    expect(
      realizedGains(inputs.ledger, 'POT'),
      pairs('pot_gain_dates', 'pot_gains'),
    );
    expect(
      realizedGains(inputs.ledger, 'C', symbols: const <String>{'IEI', 'IAU'}),
      pairs('c_gain_dates', 'c_gains'),
    );
    final AfterTaxFullInputs got = full.inputs!;
    expect(got.credited, _d(i['credited']));
    expect(got.nonCredited, _d(i['non_credited']));
    expect(got.pensionEnd, _d(i['pension_end']));
    expect(got.pensionEndB, _d(i['pension_end_b']));
    expect(got.taxablePension, _d(i['taxable']));
    expect(got.refundNominal, _d(i['refund_nominal']));
    expect(
      got.contribTotal,
      npSum(<double>[
        for (final Object? v in _obj(i['contrib_by_year']).values) _d(v),
      ]),
    );
  });

  test('반올림 전 층 값 — tax_lib 함수 출력과 비트 일치(CAGR 만 ULP ≤ 2)', () {
    final Map<String, Object?> pb = _obj(parity['branches']);
    for (final MapEntry<TaxLadderBranch, String> kv
        in kTaxLadderGoldenKeys.entries) {
      final Map<String, Object?> w = _obj(pb[kv.value]);
      final AfterTaxBranch b = full.branches[kv.key]!;
      void same(double got, double want, String what, {bool pow = false}) {
        if (pow) {
          expect(
            ulpDistance(got, want),
            lessThanOrEqualTo(2),
            reason: '${kv.value} $what',
          );
        } else {
          expect(got, want, reason: '${kv.value} $what');
        }
      }

      for (final String k in kAfterTaxPointKeys) {
        same(
          b.points[k]!.cagrPct,
          _d(_obj(w[k])['cagr_pct']),
          '$k cagr',
          pow: true,
        );
        same(b.points[k]!.endMult, _d(_obj(w[k])['end_mult']), '$k end_mult');
      }
      same(b.refundReinvestedKrw, _d(w['refund_reinvested_krw']), '재투자 환급');
    }
  });

  test('§8 미결 18 — 같은 원장에 납입이 한 번이라도 있으면 계산하지 않는다', () {
    final List<double> flows = List<double>.filled(e.daily.length, 0.0)
      ..[100] = 100000;
    expect(
      () => afterTaxFull(
        AfterTaxInputs(
          dates: inputs.dates,
          equity: inputs.equity,
          ledger: inputs.ledger,
          pensionEndB: inputs.pensionEndB,
          pensionEndParkC: inputs.pensionEndParkC,
          externalFlows: flows,
        ),
      ),
      throwsArgumentError,
    );
  });
}
