// GV-42 자본 배분 설정 검증(AC-B30) — 02 §5-7 규칙 4b·6b · §4-2 6b 단서(v2.31 새틀 0 허용).
//
// 정답지 = 파일럿5 `vectors/gv42.json`(05 §GV-42 가 지목 · vectors/SOURCES.md).
// 🔴 거부 사유는 정답지가 문구의 앞 40자(`reason_contains`)를 준다 — 앞부분 일치로 본다.
// 🔵 기대값은 생성기가 소수 10자리로 반올림했다(`gv42_gen_vectors.py` `round(v, 10)`) — 허용오차 1e-9.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

const double _tol = 1e-9;

void main() {
  group('GV-42 자본 배분 — 합 1.0 거부 · 상대 밴드 · 프로파일 3종', () {
    final List<Map<String, Object?>> cases = asObjectList(
      loadVector('gv42_allocation.json')['GV-42'],
    );
    test('12케이스 = 허용 6 · 거부 6(05 v1.20 이후 총계)', () {
      expect(cases, hasLength(12));
      final int accepted = cases
          .where(
            (Map<String, Object?> c) =>
                asObject(c['expected'])['accepted'] == true,
          )
          .length;
      expect(accepted, 6);
    });
    for (final Map<String, Object?> c in cases) {
      final Map<String, Object?> input = asObject(c['input']);
      final Map<String, Object?> e = asObject(c['expected']);
      final Object? rawCustom = input['custom'];
      final Map<String, double>? custom = rawCustom == null
          ? null
          : <String, double>{
              for (final MapEntry<String, Object?> kv in asObject(
                rawCustom,
              ).entries)
                kv.key: asDouble(kv.value),
            };
      AllocationTargets run() => resolveAllocation(
        profile: asString(input['profile']),
        custom: custom,
      );
      test(asString(c['id']), () {
        if (e['accepted'] == true) {
          final AllocationTargets r = run();
          expect(r.sleeveA, closeTo(asDouble(e['sleeve_a']), _tol));
          expect(r.sleeveB, closeTo(asDouble(e['sleeve_b']), _tol));
          expect(r.sleeveC, closeTo(asDouble(e['sleeve_c']), _tol));
          expect(
            r.satelliteTarget,
            closeTo(asDouble(e['satellite_target']), _tol),
          );
          expect(
            r.satelliteBandLow,
            closeTo(asDouble(e['satellite_band_low']), _tol),
          );
          expect(
            r.satelliteBandHigh,
            closeTo(asDouble(e['satellite_band_high']), _tol),
          );
        } else {
          expect(asString(e['error']), 'ValueError');
          expect(
            run,
            throwsA(
              isA<ArgumentError>().having(
                (ArgumentError err) => err.message.toString(),
                'message',
                startsWith(asString(e['reason_contains'])),
              ),
            ),
          );
        }
      });
    }
  });
}
