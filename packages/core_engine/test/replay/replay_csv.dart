// E6 재현 입력 읽기 — 동결 번들(`test/replay/data/*.csv.gz`)을 참조 엔진(백테스트6 `engine/data.py`)과
// **같은 비트로** 읽는다.
//
// 🔴 pandas `read_csv` 의 기본 수 변환은 정확 반올림이 아니다(`float_precision=None` = `precise_xstrtod`).
//    24개 CSV 807,854 셀 중 64,661 셀이 `double.parse` 와 최대 2 ULP 다르다(2026-10-20 실측). 골든이 그 변환으로
//    만들어졌으므로 여기서도 같은 알고리즘([pandasPreciseXstrtod])을 쓴다 — `double.parse` 를 쓰면 첫날부터 갈린다.
//    재구성은 파이썬으로 pandas 3.0.6 과 807,854 셀 전부 비트 일치를 확인했고, Dart 판은
//    `fixtures/parse_parity.json`(열별 float64 해시)으로 본다.
// 🔵 시험 전용 — 백테스트 입력이라 앱(lib)에 넣지 않는다. 실전 시세는 KIS 에서 온다(M1-7).

import 'dart:io';

/// pandas `tokenizer.c::precise_xstrtod`(최대 17자리 누적 · 10 거듭제곱 표로 한 번 곱/나눔 · 부정규수 두 단계)
/// 의 Dart 판. 숫자가 아니면 null(= `to_numeric(errors="coerce")` 의 NaN).
double? pandasPreciseXstrtod(String s) {
  const int maxDigits = 17;
  int p = 0;
  final int n = s.length;
  bool space(int i) => i < n && ' \t\r\n\f\v'.contains(s[i]);
  bool digit(int i) =>
      i < n && s.codeUnitAt(i) >= 0x30 && s.codeUnitAt(i) <= 0x39;
  while (space(p)) {
    p++;
  }
  bool negative = false;
  if (p < n && (s[p] == '+' || s[p] == '-')) {
    negative = s[p] == '-';
    p++;
  }
  double number = 0.0;
  int exponent = 0;
  int numDigits = 0;
  int numDecimals = 0;
  while (digit(p)) {
    if (numDigits < maxDigits) {
      number = number * 10.0 + (s.codeUnitAt(p) - 0x30);
      numDigits++;
    } else {
      exponent++;
    }
    p++;
  }
  if (p < n && s[p] == '.') {
    p++;
    while (numDigits < maxDigits && digit(p)) {
      number = number * 10.0 + (s.codeUnitAt(p) - 0x30);
      p++;
      numDigits++;
      numDecimals++;
    }
    if (numDigits >= maxDigits) {
      while (digit(p)) {
        p++;
      }
    }
    exponent -= numDecimals;
  }
  if (numDigits == 0) return null;
  if (negative) number = -number;
  if (p < n && (s[p] == 'e' || s[p] == 'E')) {
    p++;
    bool expNegative = false;
    if (p < n && (s[p] == '+' || s[p] == '-')) {
      expNegative = s[p] == '-';
      p++;
    }
    if (!digit(p)) return null;
    int e = 0;
    while (digit(p)) {
      e = e * 10 + (s.codeUnitAt(p) - 0x30);
      p++;
    }
    exponent += expNegative ? -e : e;
  }
  while (space(p)) {
    p++;
  }
  if (p != n) return null;
  if (exponent > 308) {
    return negative ? double.negativeInfinity : double.infinity;
  } else if (exponent > 0) {
    number *= _pow10[exponent];
  } else if (exponent < -308) {
    if (exponent < -616) {
      number = 0.0;
    } else {
      number /= _pow10[-308 - exponent];
      number /= _pow10[308];
    }
  } else {
    number /= _pow10[-exponent];
  }
  return number;
}

/// C 리터럴 `1e0`~`1e308` 과 같은 값(정확 반올림 상수).
final List<double> _pow10 = List<double>.generate(
  309,
  (int k) => double.parse('1e$k'),
  growable: false,
);

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
