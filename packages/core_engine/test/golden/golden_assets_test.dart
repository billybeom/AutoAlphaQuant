// 기기 골든 자산 목록(E11o-d · 설계 13 §8 R167) — `pubspec.yaml` `flutter: assets:` = 실행기 선언 파일과 정확히 같다.
//
// 🔴 빠지면 폰에서 «벡터 없음» 실패 · 남으면 쓰지 않는 파일(26년 재현 등)이 앱에 실린다.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  test('pubspec 자산 = kDeviceGoldenSuite.files(빠짐 · 남음 0) · 파일이 있다', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExp line = RegExp(
      r'^    - test/golden/vectors/(\S+)$',
      multiLine: true,
    );
    final List<String> declared = <String>[
      for (final RegExpMatch m in line.allMatches(pubspec)) m.group(1)!,
    ];
    expect(declared.toSet(), hasLength(declared.length), reason: '겹침');
    expect(declared.toSet(), kDeviceGoldenSuite.files);
    for (final String n in declared) {
      expect(File('$kVectorsDir/$n').existsSync(), isTrue, reason: n);
    }
    expect(
      declared.where((String n) => n.endsWith('.golden.json')),
      isEmpty,
      reason: 'CI 골든 스냅샷 잡 이름 규칙',
    );
  });

  test('caseCount = run 의 total(돌리기 전 «전체 m»)', () async {
    final GoldenBundle b = bundleOf(kDeviceGoldenSuite.files);
    final GoldenRunResult r = await kDeviceGoldenSuite.run(b);
    expect(kDeviceGoldenSuite.caseCount(b), r.total);
    expect(
      kDeviceGoldenSuite.caseCount(GoldenBundle(const <String, String>{})),
      kDeviceGoldenSuite.families.length,
      reason: '계열이 케이스를 못 만들면 1 씩(run 과 같은 셈)',
    );
  });
}
