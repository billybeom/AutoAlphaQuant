// GV-40d 기동 통제(SAF-405 · AC-S18 의 d 몫 · 설계 13 §8 R66 Y6 · Y9).
//
// 정답지(vectors/SOURCES.md): gv40_saf_warn.json — 파일럿5 원본 통째 · 이 판은 `GV-40d` 3건을 본다(e 는 E13f1).
// 🔵 정답지는 live 기동의 판정이다(04 §1 «미승인 config로 live 실행») — 모의 모드는 discretion 밖이라 rule_change_test 가 본다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  final List<Map<String, Object?>> cases = asObjectList(
    loadVector('gv40_saf_warn.json')['GV-40d'],
  );

  test('GV-40d = 3건(d1~d3)', () {
    expect(
      cases.map((Map<String, Object?> c) => asString(c['id']).split(' ').first),
      <String>['d1', 'd2', 'd3'],
    );
  });

  for (final Map<String, Object?> c in cases) {
    test(asString(c['id']), () {
      final Object? approved = asObject(c['input'])['approved'];
      final Map<String, Object?> exp = asObject(c['expected']);
      final StartupGate g = startupConfigGate(
        runMode: RunMode.live,
        approved: approved == null ? null : asInt(approved),
      );
      expect(g.start ? '기동' : '기동 거부', asString(exp['action']));
      expect(g.triggered, asStringList(exp['triggered']));
    });
  }
}
