// E8b2 — 신선도 상한(설계 13 §8 R23 D6)이 26년 경로에서 «걸렸을 날»을 세어 단언한다.
//
// 🔵 참조 엔진은 ffill 이 무제한이라 골든 재현은 상한 없이 돈다. 상한은 실전 경로만 — 그래서 여기서 «상한이 있었다면
//    무엇이 달라졌나»를 고정한다(R9 방식). 숫자가 바뀌면 번들이나 상한 규칙이 바뀐 것이다.
// 🔵 2026-10-26 실측: vix_term 15일(번들 vix3m 이 2026-07-17 에서 끊김) · sahm 10일(2025-11~12 발표 공백) · 그 밖 0 ·
//    상한을 걸면 FSM 방향 상태가 2026-08-07 이후 6일만 다르다 = 마지막 월말(2026-07-31) 뒤 → 월말 판정 영향 0.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'replay_market.dart';
import 'replay_regime.dart';

void main() {
  final RegimeSources s = regimeSourcesFromBundle(ReplayRaw.load());

  test('상한을 넘는 날 — vix_term 15 · sahm 10 · 나머지 0', () {
    final Map<String, List<String>> stale = regimeStaleDays(s);
    expect(stale.keys.toSet(), kRegimeSourceCadence.keys.toSet());
    expect(
      <String, int>{
        for (final MapEntry<String, List<String>> e in stale.entries)
          e.key: e.value.length,
      },
      <String, int>{
        'rsp_spy_ratio': 0,
        'vix_level': 0,
        'vix_term': 15,
        'ofr_fsi': 0,
        'nfci': 0,
        'cfnai_ma3': 0,
        'yield_curve': 0,
        'sahm': 10,
      },
    );
    expect(
      <String>[stale['vix_term']!.first, stale['vix_term']!.last],
      <String>['2026-07-27', '2026-08-14'],
    );
    expect(
      <String>[stale['sahm']!.first, stale['sahm']!.last],
      <String>['2025-11-26', '2025-12-10'],
    );
  });

  test('상한을 걸어도 월말 판정은 그대로 — 바뀌는 날은 마지막 월말(2026-07-31) 뒤뿐', () {
    final RegimeComputation base = computeRegime(s);
    final RegimeComputation capped = computeRegime(
      s,
      raw: applyFreshnessCaps(s, regimeRawIndicators(s)),
    );
    final List<String> changed = <String>[
      for (int i = 0; i < base.fsm.length; i++)
        if (base.fsm[i].directionState != capped.fsm[i].directionState)
          base.calendar[i],
    ];
    expect(changed, hasLength(6));
    expect(changed.first, '2026-08-07');
    expect(changed.every((String d) => d.compareTo('2026-07-31') > 0), isTrue);
    // 상한이 지표 값을 지우는 자리 = regimeStaleDays 의 날뿐(다른 날은 원값 그대로).
    final Map<String, List<double?>> raw = regimeRawIndicators(s);
    final Map<String, List<double?>> cappedRaw = applyFreshnessCaps(s, raw);
    final Map<String, List<String>> stale = regimeStaleDays(s);
    for (final String k in raw.keys) {
      final Set<String> days = (stale[k] ?? const <String>[]).toSet();
      for (int i = 0; i < raw[k]!.length; i++) {
        if (days.contains(s.usDates[i])) {
          expect(cappedRaw[k]![i], isNull, reason: '$k ${s.usDates[i]}');
        } else {
          expect(cappedRaw[k]![i], raw[k]![i], reason: '$k ${s.usDates[i]}');
        }
      }
    }
  });
}
