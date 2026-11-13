// 🆕 E15c2 — «모의 전용 분기 0»(설계 13 §8 R84 Z3 · SPEC v2.44 04 §3-1 v2.44 ③ · 앱 06 X6-3).
//
// 🔴 주문 경로(NR-1 · 초안 · 이월 · 대사 · 체결 동기화 · 배치 · UNKNOWN 해소)는 실전과 모의가 **같은 코드**다 —
//    모의는 브로커 포트의 구현(`sim/`)으로만 갈린다. 이 파일은 core `lib/src/orders/` 에 모드 낱말이 들어오면 실패한다.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('🔴 core orders/ 전 파일에 모드 낱말 0(RunMode · isSim · simInternal · SimInternal · SIMULATED)', () {
    final List<File> files =
        Directory('lib/src/orders')
            .listSync()
            .whereType<File>()
            .where((File f) => f.path.endsWith('.dart'))
            .toList()
          ..sort((File a, File b) => a.path.compareTo(b.path));
    expect(files.length, greaterThanOrEqualTo(16));
    final RegExp word = RegExp(
      r'RunMode|isSim|simInternal|SimInternal|SIMULATED',
    );
    final List<String> hits = <String>[
      for (final File f in files)
        for (final (int i, String line) in f.readAsLinesSync().indexed)
          if (word.hasMatch(line)) '${f.path}:${i + 1}: $line',
    ];
    expect(hits, isEmpty);
  });

  test('검사 자체가 낱말을 잡는다(가짜 줄)', () {
    final RegExp word = RegExp(
      r'RunMode|isSim|simInternal|SimInternal|SIMULATED',
    );
    expect(
      <String>[
        'if (mode.isSim) return;',
        'RunMode.live',
        "'SIMULATED'",
        'SimInternalBroker(',
        'simInternal',
      ].every(word.hasMatch),
      isTrue,
    );
    expect(word.hasMatch('runOrderBatch(drafts)'), isFalse);
  });
}
