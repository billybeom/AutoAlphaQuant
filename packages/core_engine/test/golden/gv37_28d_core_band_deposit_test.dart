// GV-37 코어 밴드 전액 자동 + 연금 한도 다리(AC-B26 일부) · GV-28d 납입 배분(AC-B21 일부) —
// 03 §5-2 v2.20·v2.21 · §5-5b DEPOSIT v2.23.
//
// 정답지 = 파일럿5 `gv35_38.json`(GV-37 · E5b 에서 들어옴) + 파일럿5 `gv28d_vectors.json`(vectors/SOURCES.md).
// 🔴 GV-37 은 생성기(`gen_v220_vectors.py` gv37_core_band)가 B 목표 0.287(3차 배분) · band 0.03 ·
//    원화 1e18 · 한도 ∞ 를 **기본 인자로 숨겨** 계산했다. 발주자 결정(2026-10-20 · 설계 13 §8 R14 ①)대로
//    그 값을 아래에 드러내 적고 «식»만 본다 — P0S 의 B 0.42 경로는 GV-P0S(E6)가 잰다.
// 🔵 GV-37 의 기대 금액 = 재분류 + 납입 합계(생성기는 둘을 더해 하나로 낸다).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

/// GV-37 생성기의 숨은 기본 인자.
const double _gv37TargetW = 0.287;
const double _gv37Band = 0.03;
final Decimal _gv37NoLimit = Decimal.parse(
  '1000000000000000000',
); // 1e18 = 사실상 ∞

/// 생성기 허용오차(`TOL = 1e-9`) — 금액이 1억 단위라 원 단위 1e-6 으로 본다.
const double _tol = 1e-6;

Decimal _opt(Map<String, Object?> m, String key, Decimal fallback) =>
    m.containsKey(key) ? asDecimal(m[key]) : fallback;

SleeveId _sleeve(String name) => switch (name) {
  'sleeve_b' => SleeveId.b,
  'sleeve_c' => SleeveId.c,
  'satellite' => SleeveId.satellite,
  _ => throw StateError('정답지 슬리브 이름이 낯설다: $name'),
};

void main() {
  group('GV-37 코어 밴드 — 전액 자동 · strict · 재진입 재원 보호 · 연금 한도 다리', () {
    final List<Map<String, Object?>> cases = asObjectList(
      loadVector('gv35_38_decisions.json')['GV-37'],
    );
    test('8케이스', () => expect(cases, hasLength(8)));
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      test(asString(c['id']), () {
        final CoreBandMove r = coreBandMove(
          bValue: asDecimal(input['b_value']),
          totalEquity: asDecimal(input['total_equity']),
          targetWeight: _gv37TargetW,
          band: _gv37Band,
          krwCash: _opt(input, 'c_cash', _gv37NoLimit),
          reservedKrw: _opt(input, 'reserved_krw', Decimal.zero),
          reclassifiedPark: _opt(input, 'park_c', Decimal.zero),
          annualQuota: _opt(input, 'annual_quota', _gv37NoLimit),
          pensionUsedThisYear: _opt(input, 'pension_used', Decimal.zero),
        );
        final List<Object?> e = c['expected']! as List<Object?>;
        final CoreBandDirection want = switch (asString(e[0])) {
          'B->C' => CoreBandDirection.bToC,
          'C->B' => CoreBandDirection.cToB,
          'NONE' => CoreBandDirection.none,
          final String other => throw StateError('낯선 방향: $other'),
        };
        expect(r.direction, want);
        expect(r.total.toDouble(), closeTo(asDouble(e[1]), _tol));
      });
    }
  });

  group('GV-28d 납입 — 부족분 큰 순 · B promote(한도 캡) · 한도 0 이면 B 제외 · 잔여', () {
    final Map<String, Object?> v = loadVector('gv28d_deposit.json');
    final List<Map<String, Object?>> cases = asObjectList(v['GV-28d']);
    final double tol = asDouble(asObject(v['_meta'])['tolerance']);
    test('8케이스', () => expect(cases, hasLength(8)));
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      final Map<String, Object?> e = asObject(c['expected']);
      test(asString(c['id']), () {
        final Map<SleeveId, Decimal> currents = <SleeveId, Decimal>{};
        final Map<SleeveId, Decimal> targets = <SleeveId, Decimal>{};
        for (final MapEntry<String, Object?> kv in asObject(
          input['sleeves'],
        ).entries) {
          final Map<String, Object?> s = asObject(kv.value);
          currents[_sleeve(kv.key)] = asDecimal(s['current']);
          targets[_sleeve(kv.key)] = asDecimal(s['target']);
        }
        final DepositAllocation r = allocateDeposit(
          amount: asDecimal(input['amount']),
          currents: currents,
          targets: targets,
          remainingPensionQuota: asDecimal(input['quota']),
        );
        final List<Object?> filled = e['filled']! as List<Object?>;
        expect(r.filled, hasLength(filled.length));
        for (int i = 0; i < filled.length; i++) {
          final List<Object?> pair = filled[i]! as List<Object?>;
          expect(
            r.filled[i].sleeve,
            _sleeve(asString(pair[0])),
            reason: '[$i]',
          );
          expect(
            r.filled[i].amount.toDouble(),
            closeTo(asDouble(pair[1]), tol),
            reason: '[$i]',
          );
        }
        expect(r.residual.toDouble(), closeTo(asDouble(e['residual']), tol));
      });
    }
  });
}
