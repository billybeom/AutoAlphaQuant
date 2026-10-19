// GV-3 익스포저 게이트(곱셈 구조) · GV-3c UNKNOWN fail-closed — 05 §GV-3 · 03 §1-8.
//
// 정답지: 05 v1.22 의 GV-3(6건) · GV-3c(2건) 블록을 원문 그대로 옮긴 것.
// 🔴 파일럿1 `GV-3_exposure_gate.json` 은 쓰지 않는다 — 원시 점수(`trendiness`)를
//    35 와 직접 비교하던 v1.9 이전 의미이고 05 v1.10 이 폐기했다(SOURCES.md).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  void runCases(String fileName) {
    final Map<String, Object?> vector = loadVector(fileName);
    final double tolerance = asDouble(vector['tolerance']);
    for (final Map<String, Object?> c in asObjectList(vector['cases'])) {
      final String direction = asString(c['direction_state']);
      final String trend = asString(c['trend_state']);
      test('$direction × $trend', () {
        expect(
          exposureGate(
            DirectionState.fromCode(direction),
            TrendState.fromCode(trend),
          ),
          closeTo(asDouble(c['expected_exposure']), tolerance),
        );
      });
    }
  }

  group('GV-3 익스포저 = f(방향) × g(추세성)', () {
    runCases('gv03_exposure_gate.json');
  });

  group('GV-3c UNKNOWN 은 추세성과 무관하게 0 (fail-closed)', () {
    runCases('gv03c_unknown_fail_closed.json');
  });

  group('상태 코드 읽기는 fail-closed 가 아니라 «거부»다', () {
    test('모르는 방향 코드를 UNKNOWN 으로 바꾸지 않고 거부한다', () {
      expect(() => DirectionState.fromCode('bull'), throwsArgumentError);
      expect(() => DirectionState.fromCode(''), throwsArgumentError);
    });

    test('모르는 추세성 코드도 거부한다', () {
      expect(() => TrendState.fromCode('MID'), throwsArgumentError);
    });

    test('코드는 저장 표기와 한 글자도 다르지 않다', () {
      expect(DirectionState.values.map((DirectionState s) => s.code), <String>[
        'BULL',
        'NEUTRAL',
        'BEAR',
        'UNKNOWN',
      ]);
      expect(TrendState.values.map((TrendState s) => s.code), <String>[
        'HIGH',
        'LOW',
      ]);
    });
  });
}
