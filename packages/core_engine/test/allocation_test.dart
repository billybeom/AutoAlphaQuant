// 자본 배분 해석 중 GV-42 가 직접 보지 않는 것 — 02 §5-7 규칙 4b·6b.
//
// 기대 문구·값은 참조 구현(백테스트6 `engine/config.py::resolve_alloc`)을 같은 입력으로 돌려 받았다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

Matcher _rejects(String message) => throwsA(
  isA<ArgumentError>().having(
    (ArgumentError e) => e.message.toString(),
    'message',
    message,
  ),
);

AllocationTargets _custom(Map<String, double> custom) =>
    resolveAllocation(profile: 'custom', custom: custom);

void main() {
  group('거부 문구 — 참조 구현과 글자까지', () {
    test('빈 custom 은 «배분 미제공»(«부족» 이 아니다)', () {
      expect(
        () => _custom(<String, double>{}),
        _rejects(
          "profile='custom' 이면 custom 배분을 함께 주어야 합니다 "
          "(예: {'sleeve_a':0.18,'sleeve_b':0.48,'satellite_target':0.08})",
        ),
      );
    });
    test('2개만 — 있는 키를 이름순으로', () {
      expect(
        () =>
            _custom(<String, double>{'sleeve_b': 0.4, 'satellite_target': 0.1}),
        _rejects(
          "배분이 부족합니다 — 최소 3개가 필요한데 ['satellite_target', 'sleeve_b'] 만 있습니다",
        ),
      );
    });
    test('합 1.2 — 전체 문구', () {
      expect(
        () => _custom(<String, double>{
          'sleeve_a': 0.3,
          'sleeve_b': 0.3,
          'sleeve_c': 0.3,
          'satellite_target': 0.3,
        }),
        _rejects(
          '배분 합이 1.2000 입니다 — 1.0 이어야 합니다 '
          '(A 0.300 + B 0.300 + C 0.300 + 새틀 0.300)',
        ),
      );
    });
    test('모르는 프로파일 — 가능한 이름 전부를 이름순으로', () {
      expect(
        () => resolveAllocation(profile: 'moderate'),
        _rejects(
          "모르는 프로파일 'moderate'. 가능: ['aggressive', 'balanced', 'defensive'] 또는 'custom'",
        ),
      );
    });
    test('범위 검사는 주어진 키 다음 잔여 키 순서 — sleeve_a 가 빠지면 sleeve_b 가 먼저 걸린다', () {
      expect(
        () => _custom(<String, double>{
          'sleeve_b': 1.5,
          'sleeve_c': 0.1,
          'satellite_target': 0.0,
        }),
        _rejects('sleeve_b=1.5 가 0~1 범위를 벗어납니다'),
      );
    });
    test('잔여가 음수가 되면 잔여 키가 걸린다', () {
      expect(
        () => _custom(<String, double>{
          'sleeve_a': 0.6,
          'sleeve_b': 0.6,
          'satellite_target': 0.0,
        }),
        _rejects('sleeve_c=-0.2 가 0~1 범위를 벗어납니다'),
      );
    });
    test('NaN 도 범위 밖(Dart 표기 `NaN` · 파이썬 `nan`)', () {
      expect(
        () => _custom(<String, double>{
          'sleeve_a': double.nan,
          'sleeve_b': 0.42,
          'sleeve_c': 0.38,
        }),
        _rejects('sleeve_a=NaN 가 0~1 범위를 벗어납니다'),
      );
    });
    test('합 오차 1e-6 초과는 거부 — 4자리로 찍으면 1.0000 이어도', () {
      expect(
        () => _custom(<String, double>{
          'sleeve_a': 0.2,
          'sleeve_b': 0.42,
          'sleeve_c': 0.380002,
          'satellite_target': 0.0,
        }),
        _rejects(
          '배분 합이 1.0000 입니다 — 1.0 이어야 합니다 '
          '(A 0.200 + B 0.420 + C 0.380 + 새틀 0.000)',
        ),
      );
    });
  });

  group('허용', () {
    test('잔여는 소수 10자리로 반올림 — 0.1 + 0.2 + 0.3 의 잔여는 정확히 0.4', () {
      final AllocationTargets r = _custom(<String, double>{
        'sleeve_a': 0.1,
        'sleeve_b': 0.2,
        'satellite_target': 0.3,
      });
      expect(r.sleeveC, 0.4);
      expect(r.satelliteBandLow, 0.25);
    });
    test('잔여 키가 sleeve_a 여도 채운다(0.19999999999999996 → 0.2)', () {
      final AllocationTargets r = _custom(<String, double>{
        'sleeve_b': 0.42,
        'sleeve_c': 0.38,
        'satellite_target': 0.0,
      });
      expect(r.sleeveA, 0.2);
    });
    test('경계 — 한 슬리브 1.0 · 나머지 0 은 허용', () {
      final AllocationTargets r = _custom(<String, double>{
        'sleeve_a': 1.0,
        'sleeve_b': 0.0,
        'satellite_target': 0.0,
      });
      expect(r.sleeveA, 1.0);
      expect(r.sleeveC, 0.0);
    });
    test('합 오차 1e-6 이내는 허용 · 모르는 키는 무시', () {
      final AllocationTargets r = _custom(<String, double>{
        'sleeve_a': 0.2,
        'sleeve_b': 0.42,
        'sleeve_c': 0.3800005,
        'satellite_target': 0.0,
        'foo': 9.0,
      });
      expect(r.sleeveC, 0.3800005);
    });
    test('정본 P0S 꼴 — balanced 에서 새틀 0 · 해제분 잔여 C(밴드 0)', () {
      final AllocationTargets r = _custom(<String, double>{
        'sleeve_a': 0.20,
        'sleeve_b': 0.42,
        'satellite_target': 0.0,
      });
      expect(r.sleeveC, 0.38);
      expect(r.satelliteBandLow, 0.0);
      expect(r.satelliteBandHigh, 0.0);
    });
  });
}
