// 05 GV 계열 처리 구분표(E11o-c2 · 설계 13 §8 R165 · §7 P-2) — 실행기 케이스와 표가 서로 맞는가 · «전량» 표시가 표를 따르는가.
//
// 🔴 «전량»(`kDeviceGoldenSuite.complete`)은 P-2 범위에 빠진 계열이 0 일 때만 참이다 — 지금은 GV-40a~c(엔진 미구현)가 남아 거짓.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  final List<String> caseIds = <String>[
    for (final GoldenFamily f in kDeviceGoldenSuite.families)
      for (final GvCase c in f.cases(bundleOf(f.files))) c.id,
  ];

  test('계열 id 겹침 없음 · 05 항목(AC-B01~B30 · 엔진 관련 게이트) 전부가 표에 있다', () {
    final List<String> ids = <String>[
      for (final GvCoverage c in kGoldenCoverage) c.id,
    ];
    expect(ids.toSet(), hasLength(ids.length));
    expect(
      <String>{for (final GvCoverage c in kGoldenCoverage) c.ac},
      <String>{
        for (int i = 1; i <= 30; i++) 'AC-B${i.toString().padLeft(2, '0')}',
        'AC-S11',
        'AC-S13',
        'AC-S14',
        'AC-S16',
        'AC-S17',
        'AC-S18',
        '게이트',
      },
    );
  });

  test('실행기 케이스는 전부 «기기» 계열에 속한다', () {
    final List<String> stray = <String>[
      for (final String id in caseIds)
        if (goldenCoverageOfCase(id)?.disposition != GvDisposition.device) id,
    ];
    expect(stray, isEmpty);
  });

  test('«기기» 계열은 전부 실행기 케이스가 하나 이상 있다', () {
    final Set<String> covered = <String>{
      for (final String id in caseIds) goldenCoverageOfCase(id)!.id,
    };
    expect(<String>[
      for (final GvCoverage c in kGoldenCoverage)
        if (c.disposition == GvDisposition.device && !covered.contains(c.id))
          c.id,
    ], isEmpty);
  });

  test('🔴 빠진 계열 = GV-40a~c(엔진 미구현) · «전량» 표시는 표를 따른다', () {
    expect(goldenCoverageGaps.map((GvCoverage c) => c.id), <String>[
      'GV-40a',
      'GV-40b',
      'GV-40c',
    ]);
    expect(goldenCoverageComplete, isFalse);
    expect(kDeviceGoldenSuite.complete, goldenCoverageComplete);
  });

  test('P-2 대조 — 05 v2.31 비활성 7 중 GV-8(M1-1 게이트) 밖은 제외 · GV-P0S = CI', () {
    GvDisposition of(String id) =>
        kGoldenCoverage.firstWhere((GvCoverage c) => c.id == id).disposition;
    for (final String id in <String>[
      'GV-10',
      'GV-21',
      'GV-26',
      'GV-27',
      'GV-29',
      'GV-34',
    ]) {
      expect(of(id), GvDisposition.excluded, reason: id);
    }
    expect(of('GV-8'), GvDisposition.device);
    expect(of('GV-P0S'), GvDisposition.ciOnly);
    for (final String id in <String>[
      'GV-5',
      'GV-6',
      'GV-7',
      'GV-15',
      'GV-41',
      'GV-12b',
      'GV-25',
      'GV-28w',
      'GV-33',
    ]) {
      expect(of(id), GvDisposition.excluded, reason: 'P-2 $id');
    }
  });

  test('케이스 id → 계열(글자 붙은 계열이 먼저 · 없으면 번호)', () {
    expect(goldenCoverageOfCase('GV-12c 2026-01-29')?.id, 'GV-12');
    expect(goldenCoverageOfCase('GV-28d d1 …')?.id, 'GV-28d');
    expect(goldenCoverageOfCase('GV-40e e1')?.id, 'GV-40e');
    expect(goldenCoverageOfCase('GV-1e1')?.id, 'GV-1');
    expect(goldenCoverageOfCase('GV-11e c1')?.id, 'GV-11');
    expect(
      goldenCoverageOfCase('GV-12b x')?.disposition,
      GvDisposition.excluded,
    );
    expect(goldenCoverageOfCase('없음'), isNull);
  });
}
