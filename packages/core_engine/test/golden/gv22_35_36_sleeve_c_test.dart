// GV-22 슬리브 C 통화 분리·금 상한(AC-B15) · GV-35 분모 = 달러 잔액 · GV-36 조달 상대 = 잉여 큰 순 · B 제외
// (AC-B26 일부) — 03 §2-9-1·2 · §5-2 v2.19·v2.21.
//
// 정답지 = 05 v1.22 §GV-22 블록 원문 + 파일럿5 `gv35_38.json`(vectors/SOURCES.md).
// 🔴 GV-35 는 생성기(`gen_v220_vectors.py` gv35_sleeve_c_targets)가 비중 0.40/0.35/0.25 · 금 상한 0.08 을
//    **기본 인자로 숨겨** 계산했다(JSON 입력에 없다). 발주자 결정(2026-10-20 · 설계 13 §8 R14 ①)대로
//    그 값을 아래에 드러내 적고 «식»만 본다 — P0S 비중(0 / 0.65 / 0.35)의 값은 GV-P0S(E6)가 잰다.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

/// GV-35 생성기의 숨은 기본 인자(`w=(0.40, 0.35, 0.25)` · `gold_cap_pct=0.08`).
final SleeveCWeights _gv35HiddenWeights = SleeveCWeights(
  cash: 0.40,
  bond: 0.35,
  gold: 0.25,
);
const double _gv35HiddenGoldCap = 0.08;

/// 생성기 허용오차(`TOL = 1e-9`) — 금액이 1억 단위라 원 단위 1e-6 으로 본다.
const double _tol = 1e-6;

SleeveId _sleeve(String wire) => SleeveId.values.firstWhere(
  (SleeveId s) => s.wire == wire,
  orElse: () => throw StateError('정답지 슬리브가 낯설다: $wire'),
);

void _expectTargets(SleeveCTargets r, Map<String, Object?> e, double tol) {
  expect(r.cash.toDouble(), closeTo(asDouble(e['BIL']), tol), reason: 'BIL');
  expect(r.bond.toDouble(), closeTo(asDouble(e['IEI']), tol), reason: 'IEI');
  expect(r.gold.toDouble(), closeTo(asDouble(e['IAU']), tol), reason: 'IAU');
}

void main() {
  group('GV-22 통화 분리 · 금 상한(초과분은 현금성 · 국채 불변)', () {
    final Map<String, Object?> v = loadVector('gv22_sleeve_c_gold_cap.json');
    final Map<String, Object?> config = asObject(v['config']);
    final Map<String, Object?> w = asObject(config['usd_weights']);
    final SleeveCWeights weights = SleeveCWeights(
      cash: asDouble(w['BIL']),
      bond: asDouble(w['IEI']),
      gold: asDouble(w['IAU']),
    );
    final double cap = asDouble(config['max_gold_pct_of_total']);
    final String krwTicker = asString(config['krw_cash_ticker']);
    final double amounts = asDouble(asObject(v['tolerance'])['amounts']);
    test('불변식은 «합 = 달러 잔액» 하나', () {
      expect(asStringList(v['invariants']), hasLength(1));
    });
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test(asString(c['id']), () {
        if (c.containsKey('inflow')) {
          // q1 — 원화 유입은 전액 원화 현금성.
          expect(asString(c['currency']), 'KRW');
          final SleeveCInflow r = sleeveCAllocateInflow(
            inflow: asDecimal(c['inflow']),
            currency: InflowCurrency.krw,
            weights: weights,
          );
          final Map<String, Object?> e = asObject(c['expected']);
          expect(e.keys, <String>[krwTicker]);
          expect(r.krwCash, asDecimal(e[krwTicker]));
          expect(r.usd.total, Decimal.zero);
          return;
        }
        final Decimal usd = asDecimal(c['sleeve_c_usd_total']);
        final SleeveCTargets r = sleeveCUsdTargets(
          usdTotal: usd,
          totalEquity: asDecimal(c['total_equity']),
          weights: weights,
          maxGoldPctOfTotal: cap,
        );
        expect(r.total.toDouble(), closeTo(usd.toDouble(), amounts));
        if (c.containsKey('expected')) {
          _expectTargets(r, asObject(c['expected']), amounts);
        } else {
          // q4 — 상한을 빼먹은 결과가 나오면 오답.
          final Map<String, Object?> no = asObject(c['expected_not']);
          expect(
            r.gold.toDouble(),
            isNot(closeTo(asDouble(no['IAU']), amounts)),
          );
          expect(
            r.cash.toDouble(),
            isNot(closeTo(asDouble(no['BIL']), amounts)),
          );
        }
      });
    }
  });

  group('GV-35 분모 = 달러 잔액(원화는 배분을 거치지 않는다)', () {
    final List<Map<String, Object?>> cases = asObjectList(
      loadVector('gv35_38_decisions.json')['GV-35'],
    );
    test('4케이스', () => expect(cases, hasLength(4)));
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      final Map<String, Object?> e = asObject(c['expected']);
      test(asString(c['id']), () {
        final SleeveCTargets r = sleeveCUsdTargets(
          usdTotal: asDecimal(input['usd_total']),
          totalEquity: asDecimal(input['total_equity']),
          weights: _gv35HiddenWeights,
          maxGoldPctOfTotal: _gv35HiddenGoldCap,
        );
        _expectTargets(r, e, _tol);
        // 원화는 인자로 받지도 않는다 — 그대로 남아야 한다.
        expect(asDouble(e['KRW_CASH']), asDouble(input['krw_cash']));
      });
    }
  });

  group('GV-36 조달 상대 — 잉여 큰 순 · B 제외 · 잉여까지만', () {
    final List<Map<String, Object?>> cases = asObjectList(
      loadVector('gv35_38_decisions.json')['GV-36'],
    );
    test('4케이스', () => expect(cases, hasLength(4)));
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      test(asString(c['id']), () {
        Map<SleeveId, Decimal> read(Object? m) => <SleeveId, Decimal>{
          for (final MapEntry<String, Object?> kv in asObject(m).entries)
            _sleeve(kv.key): asDecimal(kv.value),
        };
        final Decimal need = asDecimal(input['need']);
        final FundingPlan r = fundingOrder(
          values: read(input['values']),
          targets: read(input['targets']),
          need: need,
        );
        final List<Object?> e = c['expected']! as List<Object?>;
        expect(r.takes, hasLength(e.length));
        Decimal taken = Decimal.zero;
        for (int i = 0; i < e.length; i++) {
          final List<Object?> pair = e[i]! as List<Object?>;
          expect(r.takes[i].sleeve, _sleeve(asString(pair[0])), reason: '[$i]');
          expect(
            r.takes[i].amount.toDouble(),
            closeTo(asDouble(pair[1]), _tol),
            reason: '[$i]',
          );
          taken += r.takes[i].amount;
        }
        expect(r.shortfall, need - taken);
      });
    }
  });
}
