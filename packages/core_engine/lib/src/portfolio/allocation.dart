// 자본 배분 해석 · 검증 — `06_시스템설계/02_데이터모델.md` §4-2 · §5-7 규칙 4b·6b · 05 GV-42(AC-B30).
//
// 참조 구현 = `09_백테스트/백테스트6/engine/config.py` `resolve_alloc`(v2.31 판).
// 🔴 합이 1.0 이 아니면 거부한다 — **조용히 정규화하지 않는다**(의도치 않은 배분 방지).
// 🔴 넷 중 하나만 빠지면 잔여로 채우고, 둘 이상 빠지면 거부한다.
// 🔴 새틀라이트 밴드 = 목표 × (15/18, 21/18) — 상대폭 ±16.7% 고정. v2.31: 목표 0 허용(밴드 0.0).
// 🔵 프로파일 표는 02 §5-7 의 세 프로파일(새틀 6% 시절 값)이다. 정본 P0S 는 그 위에 프리셋으로 새틀을 0 으로
//    덮고 해제분을 잔여 C 로 흡수한다(`golden_p0s.json` meta «balanced 배분에서 새틀 0%»).
// 🔵 미결 193 ⓐ(2026-11-19) — M9 S04 첫 판은 이 표를 읽지 않는다(옛 판 수치를 지금 수치처럼 보이지 않게 · 쓰는 곳 = 골든
//    실행기 `gv_sleeves.dart` 뿐). 표 정리 = 편집기 판(P0S 판 재실행)과 함께(설계 13 §8 R190).
// 🔴 오류 문구는 참조 구현과 글자까지 같게 둔다 — 정답지가 문구의 앞부분을 본다.

/// 해석된 자본 배분(총자산 대비 비율).
class AllocationTargets {
  /// 결과를 만든다.
  const AllocationTargets({
    required this.sleeveA,
    required this.sleeveB,
    required this.sleeveC,
    required this.satelliteTarget,
    required this.satelliteBandLow,
    required this.satelliteBandHigh,
  });

  /// 슬리브 A.
  final double sleeveA;

  /// 슬리브 B.
  final double sleeveB;

  /// 슬리브 C.
  final double sleeveC;

  /// 새틀라이트 목표.
  final double satelliteTarget;

  /// 새틀라이트 밴드 하한.
  final double satelliteBandLow;

  /// 새틀라이트 밴드 상한.
  final double satelliteBandHigh;
}

/// 02 §5-7 프로파일.
const Map<String, Map<String, double>> kAllocationProfiles =
    <String, Map<String, double>>{
      'defensive': <String, double>{
        'sleeve_a': 0.10,
        'sleeve_b': 0.42,
        'sleeve_c': 0.42,
        'satellite_target': 0.06,
      },
      'balanced': <String, double>{
        'sleeve_a': 0.20,
        'sleeve_b': 0.42,
        'sleeve_c': 0.32,
        'satellite_target': 0.06,
      },
      'aggressive': <String, double>{
        'sleeve_a': 0.20,
        'sleeve_b': 0.58,
        'sleeve_c': 0.16,
        'satellite_target': 0.06,
      },
    };

const double _bandLow = 15.0 / 18.0;
const double _bandHigh = 21.0 / 18.0;
const List<String> _keys = <String>[
  'sleeve_a',
  'sleeve_b',
  'sleeve_c',
  'satellite_target',
];

/// 프로파일 이름 또는 커스텀 배분을 풀어 검증한다. 규칙 밖이면 [ArgumentError](파이썬 `ValueError`).
AllocationTargets resolveAllocation({
  required String profile,
  Map<String, double>? custom,
}) {
  final Map<String, double> base;
  if (profile == 'custom') {
    if (custom == null || custom.isEmpty) {
      throw ArgumentError(
        "profile='custom' 이면 custom 배분을 함께 주어야 합니다 "
        "(예: {'sleeve_a':0.18,'sleeve_b':0.48,'satellite_target':0.08})",
      );
    }
    base = custom;
  } else {
    final Map<String, double>? p = kAllocationProfiles[profile];
    if (p == null) {
      final List<String> names = kAllocationProfiles.keys.toList()..sort();
      throw ArgumentError(
        "모르는 프로파일 '$profile'. 가능: ${_pyList(names)} 또는 'custom'",
      );
    }
    base = p;
  }

  // 파이썬 dict 삽입 순서 그대로: 주어진 키(정해진 순서) 다음에 잔여 키.
  final Map<String, double> given = <String, double>{
    for (final String k in _keys)
      if (base.containsKey(k)) k: base[k]!,
  };
  final List<String> missing = <String>[
    for (final String k in _keys)
      if (!given.containsKey(k)) k,
  ];
  if (missing.length == 1) {
    double sum = 0;
    for (final double v in given.values) {
      sum += v;
    }
    given[missing.single] = double.parse((1.0 - sum).toStringAsFixed(10));
  } else if (missing.isNotEmpty) {
    final List<String> have = given.keys.toList()..sort();
    throw ArgumentError('배분이 부족합니다 — 최소 3개가 필요한데 ${_pyList(have)} 만 있습니다');
  }

  for (final MapEntry<String, double> e in given.entries) {
    if (!(e.value >= 0.0 && e.value <= 1.0)) {
      // VM 의 double.toString 은 파이썬 str(float) 와 같은 최단 표기다(지수 표기 구간만 다르다 —
      // 파이썬은 |v| < 1e-4 에서 `1e-05` 꼴. 정답지에 그런 값은 없다).
      throw ArgumentError('${e.key}=${e.value} 가 0~1 범위를 벗어납니다');
    }
  }
  double total = 0;
  for (final double v in given.values) {
    total += v;
  }
  if ((total - 1.0).abs() > 1e-6) {
    throw ArgumentError(
      '배분 합이 ${total.toStringAsFixed(4)} 입니다 — 1.0 이어야 합니다 '
      '(A ${given['sleeve_a']!.toStringAsFixed(3)} + '
      'B ${given['sleeve_b']!.toStringAsFixed(3)} + '
      'C ${given['sleeve_c']!.toStringAsFixed(3)} + '
      '새틀 ${given['satellite_target']!.toStringAsFixed(3)})',
    );
  }
  final double sat = given['satellite_target']!;
  return AllocationTargets(
    sleeveA: given['sleeve_a']!,
    sleeveB: given['sleeve_b']!,
    sleeveC: given['sleeve_c']!,
    satelliteTarget: sat,
    satelliteBandLow: sat * _bandLow,
    satelliteBandHigh: sat * _bandHigh,
  );
}

/// 파이썬 `repr(list[str])` 꼴 — `['a', 'b']`.
String _pyList(List<String> items) =>
    '[${items.map((String s) => "'$s'").join(', ')}]';
