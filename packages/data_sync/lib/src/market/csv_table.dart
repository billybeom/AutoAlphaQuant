// 시세·지표 CSV 읽기 — 동결 번들 시드 · FRED `fredgraph.csv` · OFR `fsi.csv`(설계 13 §8 R23 D9 · E8c).
//
// 🔴 수 변환 = 참조 엔진(pandas `read_csv`)과 같은 비트 — core_engine [pandasPreciseXstrtod](정확 반올림이 아니다 ·
//    시드와 실전 수집이 같은 변환을 써야 골든 경로가 지켜지고 겹친 날 비교가 같은 글자를 같다고 본다 · R26 H9).
// 🔴 빈 칸 · `.`(FRED 결측) · `NaN` 은 결측(NaN)이다. 그 밖에 숫자로 못 읽는 글자는 [FormatException] — pandas 는
//    조용히 NaN 으로 바꾸지만(`errors="coerce"`) 실전 응답의 이상한 글자는 응답이 틀린 것이라 그 길을 실패로 본다.
// 🔵 줄 끝 CRLF·LF 둘 다 · 따옴표 칸(RFC 4180 — `""` = 따옴표 하나)을 받는다. 번들은 따옴표가 없다.

import 'package:core_engine/core_engine.dart' show pandasPreciseXstrtod;

/// 머리줄 + 행(칸 문자열).
class CsvTable {
  CsvTable._(this.header, this.rows);

  /// [text] 를 읽는다. 머리줄이 없으면 [FormatException].
  factory CsvTable.parse(String text) {
    final List<List<String>> lines = <List<String>>[];
    for (final String raw in text.split('\n')) {
      final String line = raw.endsWith('\r')
          ? raw.substring(0, raw.length - 1)
          : raw;
      if (line.isEmpty) continue;
      lines.add(_splitLine(line));
    }
    if (lines.isEmpty) throw const FormatException('CSV 머리줄이 없다');
    final List<String> header = lines.first;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].length != header.length) {
        throw FormatException(
          'CSV ${i + 1}번째 줄 칸 ${lines[i].length} ≠ 머리줄 ${header.length}',
        );
      }
    }
    return CsvTable._(header, lines.sublist(1));
  }

  /// 머리줄(칸 이름).
  final List<String> header;

  /// 행.
  final List<List<String>> rows;

  /// 칸 [name] 의 위치 — 없으면 [FormatException].
  int indexOf(String name) {
    final int i = header.indexOf(name);
    if (i < 0) throw FormatException('CSV 칸 «$name» 이 없다: $header');
    return i;
  }
}

/// 칸 글자 → 값(빈 칸 · `.` · `NaN` = 결측 NaN).
double csvNumber(String cell) {
  final String s = cell.trim();
  if (s.isEmpty || s == '.' || s == 'NaN' || s == 'nan') return double.nan;
  final double? v = pandasPreciseXstrtod(s);
  if (v == null) throw FormatException('숫자가 아니다: «$cell»');
  return v;
}

List<String> _splitLine(String line) {
  final List<String> out = <String>[];
  final StringBuffer cell = StringBuffer();
  bool quoted = false;
  for (int i = 0; i < line.length; i++) {
    final String ch = line[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == ',') {
      out.add(cell.toString());
      cell.clear();
    } else {
      cell.write(ch);
    }
  }
  if (quoted) throw FormatException('따옴표가 닫히지 않았다: $line');
  out.add(cell.toString());
  return out;
}
