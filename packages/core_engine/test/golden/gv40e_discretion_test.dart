// GV-40e 재량 예산 원장(SAF-409 · AC-S18 의 e 몫 · 설계 13 §8 R64 W8).
//
// 정답지(vectors/SOURCES.md): gv40_saf_warn.json — 파일럿5 원본 통째 · 이 판은 `GV-40e` 9건만 본다.
// 🔵 정답지 `decision_id` 의 «미연결» = null → `journalLinked: false`(저널 사실 판정은 discretion_test 가 본다).
// 🔵 `triggered` · `action` 은 사유가 있느냐로 정해진다(참조 `gv40e_discretion`).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  final List<Map<String, Object?>> cases = asObjectList(
    loadVector('gv40_saf_warn.json')['GV-40e'],
  );

  test('GV-40e = 9건(e1~e9)', () {
    expect(
      cases.map((Map<String, Object?> c) => asString(c['id']).split(' ').first),
      <String>['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9'],
    );
  });

  for (final Map<String, Object?> c in cases) {
    test(asString(c['id']), () {
      final Map<String, Object?> input = asObject(c['input']);
      final Map<String, Object?> exp = asObject(c['expected']);
      final DiscretionJudgement j = judgeDiscretion(
        deltaPct: asDouble(input['delta_pct']),
        journalLinked: input['decision_id'] != null,
        priorUseDates: asStringList(input['history']),
        today: asString(input['now']),
      );
      expect(j.rejectReasons, asStringList(exp['reject_reasons']));
      expect(j.applies ? '반영' : '요청 거부', asString(exp['action']));
      expect(
        j.applies ? <String>[] : <String>['SAF-409'],
        asStringList(exp['triggered']),
      );
      final Map<String, Object?> m = asObject(exp['metrics']);
      expect(j.rolling12mCount, asInt(m['rolling_12m_count']));
      expect(j.deltaPct, asDouble(m['delta_pct']));
    });
  }
}
