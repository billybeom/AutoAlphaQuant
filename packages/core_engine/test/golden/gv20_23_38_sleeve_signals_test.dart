// GV-20 슬리브 B 3-트랜치 SMA(AC-B13) · GV-23 계절성 부분 청산(AC-B16) · GV-38 4월 청산 기본값 = 전량
// (AC-B26 일부) — 03 §2-7-2·3 · §5-3-2.
//
// 정답지 = 05 v1.22 본문 블록 원문(GV-20 · GV-23) + 파일럿5 `gv35_38.json`(GV-38 — vectors/SOURCES.md).
// 🔵 GV-23 은 enabled 경로라 P0S 에서 돌지 않지만, GV-38-4 가 «enabled 경로는 GV-23 그대로»를 같은
//    함수로 묻기 때문에 함께 시험한다. GV-35~37 은 다음 PR(슬리브 C · 코어 밴드)에서 읽는다.
// 🔵 GV-23 의 매도 금액은 «비율 × 슬리브 금액» 검산이다 — 종목별 배분(§5-3-2 v2.9)은 주문 산출의 몫.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  group('GV-20 3-트랜치 — 다수결이 아니다 · 판정월 포함 · 워밍업 0.0', () {
    final Map<String, Object?> v = loadVector('gv20_sleeve_b_tranche.json');
    final Map<String, Object?> common = asObject(v['common']);
    final List<int> lookbacks = <int>[
      for (final Object? n in common['lookback_months']! as List<Object?>)
        asInt(n),
    ];
    final List<double> head = <double>[
      for (final double? x in asNumList(common['monthly_closes_head'])) x!,
    ];
    final double tol = asDouble(v['tolerance']);
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test('${c['id']} → ${c['expected_ratio']}', () {
        final List<double> closes;
        if (c.containsKey('last_close')) {
          closes = <double>[...head, asDouble(c['last_close'])];
        } else {
          // b5 — «head only (11개월)»: 가장 긴 룩백 12 에 하나 모자란다.
          expect(asString(c['monthly_closes']), startsWith('head only'));
          closes = head;
        }
        expect(
          sleeveBTargetWeight(closes, lookbackMonths: lookbacks),
          closeTo(asDouble(c['expected_ratio']), tol),
        );
      });
    }
  });

  group('GV-23 부분 청산(enabled 경로) — 추세가 강할수록 덜 판다', () {
    final Map<String, Object?> v = loadVector('gv23_partial_exit.json');
    final Map<String, Object?> partial = asObject(
      asObject(v['config'])['partial'],
    );
    final Map<String, Object?> tol = asObject(v['tolerance']);
    final Decimal sleeveA = asDecimal(v['sleeve_a_value']);
    for (final Map<String, Object?> c in asObjectList(v['cases'])) {
      test('${c['id']} score=${c['trend_score_kr']}', () {
        final Map<String, Object?> override = c.containsKey('config_override')
            ? asObject(asObject(c['config_override'])['partial'])
            : const <String, Object?>{};
        final Object? enabled = override['enabled'] ?? partial['enabled'];
        final Object? score = c['trend_score_kr'];
        final double f = seasonalExitFraction(
          score == null ? null : asDouble(score),
          partialEnabled: enabled == true,
          minScore: asDouble(partial['min_score']),
        );
        expect(
          f,
          closeTo(
            asDouble(c['expected_exit_fraction']),
            asDouble(tol['fraction']),
          ),
        );
        expect(
          multiply(sleeveA, promoteRatio(f)).toDouble(),
          closeTo(asDouble(c['expected_sell_value']), asDouble(tol['amounts'])),
        );
      });
    }
  });

  group('GV-38 4월 청산 기본값 = 전량(v2.19)', () {
    final List<Map<String, Object?>> cases = asObjectList(
      loadVector('gv35_38_decisions.json')['GV-38'],
    );
    test('4케이스', () => expect(cases, hasLength(4)));
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      test(asString(c['id']), () {
        final Object? score = input['score'];
        // 생성기(`gen_v220_vectors.py` gv38_exit_fraction) 기본 인자 = enabled False · min_score 40.
        final double f = seasonalExitFraction(
          score == null ? null : asDouble(score),
          partialEnabled: input['partial_enabled'] == true,
          minScore: 40.0,
        );
        expect(f, asDouble(c['expected']));
      });
    }
  });
}
