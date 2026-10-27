// E6 재현 입력 읽기 — 동결 번들(`test/replay/data/*.csv.gz`)을 참조 엔진(백테스트6 `engine/data.py`)과
// **같은 비트로** 읽는다.
//
// 🔴 pandas `read_csv` 의 기본 수 변환은 정확 반올림이 아니다(`float_precision=None` = `precise_xstrtod`).
//    24개 CSV 807,854 셀 중 64,661 셀이 `double.parse` 와 최대 2 ULP 다르다(2026-10-20 실측). 골든이 그 변환으로
//    만들어졌으므로 여기서도 같은 알고리즘([pandasPreciseXstrtod])을 쓴다 — `double.parse` 를 쓰면 첫날부터 갈린다.
//    재구성은 파이썬으로 pandas 3.0.6 과 807,854 셀 전부 비트 일치를 확인했고, Dart 판은
//    `fixtures/parse_parity.json`(열별 float64 해시)으로 본다.
// 🔵 읽개(파일 → 표)는 시험 전용이다. 수 변환 [pandasPreciseXstrtod] 는 lib 로 올렸다(E8c — 시드·실전 수집이 같은
//    변환을 쓴다 · `lib/src/data/pandas_number.dart`).

import 'dart:io';

import 'package:core_engine/core_engine.dart' show pandasPreciseXstrtod;

export 'package:core_engine/core_engine.dart' show pandasPreciseXstrtod;

/// 동결 CSV 하나 — 첫 열이 날짜(`index_col=0`), 나머지는 수(못 읽으면 NaN).
class ReplayFrame {
  ReplayFrame._(this.name, this.index, this.columns);

  /// 파일 이름(확장자 없이 — 참조 엔진 `load_all` 의 키).
  final String name;

  /// 날짜 열(파일 순서 그대로).
  final List<String> index;

  /// 열 이름 → 값(NaN = 결측).
  final Map<String, List<double>> columns;

  /// [column] 열. 없으면 [StateError].
  List<double> column(String column) =>
      columns[column] ??
      (throw StateError('$name 에 $column 열이 없다: ${columns.keys}'));
}

/// 패키지 루트 기준 번들 폴더.
const String kReplayDataDir = 'test/replay/data';

/// `test/replay/data/<name>.csv.gz` 를 읽는다. 따옴표가 든 줄은 이 읽개가 다루지 않으므로 거부한다.
ReplayFrame loadReplayCsv(String name) {
  final List<int> bytes = gzip.decode(
    File('$kReplayDataDir/$name.csv.gz').readAsBytesSync(),
  );
  final String text = String.fromCharCodes(bytes);
  final List<String> lines = text.split('\n');
  if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
  String strip(String l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l;
  final List<String> header = strip(lines.first).split(',');
  final List<String> index = <String>[];
  final List<List<double>> values = <List<double>>[
    for (int j = 1; j < header.length; j++) <double>[],
  ];
  for (final String raw in lines.skip(1)) {
    final String line = strip(raw);
    if (line.contains('"')) {
      throw StateError('$name: 따옴표 줄은 다루지 않는다: $line');
    }
    final List<String> cells = line.split(',');
    index.add(cells[0]);
    for (int j = 1; j < header.length; j++) {
      final String cell = j < cells.length ? cells[j] : '';
      values[j - 1].add(pandasPreciseXstrtod(cell) ?? double.nan);
    }
  }
  return ReplayFrame._(
    name,
    List<String>.unmodifiable(index),
    <String, List<double>>{
      for (int j = 1; j < header.length; j++)
        header[j]: List<double>.unmodifiable(values[j - 1]),
    },
  );
}
