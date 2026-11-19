// 골든 실행기 경계(E11o-b · 설계 13 §8 R163) — core_engine lib 안에서 시험 받침대(`src/testing/`)를 부르는 곳은
// `testing.dart`(시험용 배럴)와 `src/golden/`(기기 골든 실행기 — 05 GV-13 «mock» 그대로 가짜 브로커로 센다)뿐이다.
//
// 🔴 운영 주문 경로가 가짜 브로커 · 원장을 부르면 안 된다 — 새 lib 파일이 `src/testing/` 을 import 하면 여기서 깨진다.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('lib 안 src/testing import = testing.dart · src/golden/ 뿐', () {
    final RegExp imp = RegExp(
      r'''^\s*(import|export)\s+'([^']*)'.*$''',
      multiLine: true,
    );
    final List<String> offenders = <String>[];
    final List<String> goldenUsers = <String>[];
    for (final FileSystemEntity f in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String path = f.path.replaceAll(r'\', '/');
      for (final RegExpMatch m in imp.allMatches(f.readAsStringSync())) {
        final String target = m.group(2)!;
        final bool toTesting =
            target.contains('src/testing/') ||
            target.startsWith('../testing/') ||
            target.startsWith('testing/') ||
            target == 'package:core_engine/testing.dart';
        if (!toTesting) continue;
        if (path == 'lib/testing.dart' || path.startsWith('lib/src/testing/')) {
          continue;
        }
        if (path.startsWith('lib/src/golden/')) {
          goldenUsers.add(path);
          continue;
        }
        offenders.add('$path → $target');
      }
    }
    expect(offenders, isEmpty);
    expect(goldenUsers.toSet(), <String>{
      'lib/src/golden/gv_orders.dart',
    }, reason: '가짜를 부르는 골든 파일 = GV-13 발주 횟수 하나');
  });
}
