// E6 재현 입력 — 동결 번들이 원본과 같고, Dart 가 pandas 와 같은 비트로 읽는가.
//
// 정답지 = `data/MANIFEST.json`(원본 sha256 · tool/freeze_replay_data.py) +
//          `fixtures/parse_parity.json`(pandas 3.0.6 이 읽은 열별 float64 해시 · tool/export_replay_parity.py).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import 'replay_csv.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

String _columnHash(List<double> values) {
  final ByteData b = ByteData(8 * values.length);
  for (int i = 0; i < values.length; i++) {
    final double v = values[i];
    if (v.isNaN) {
      b.setUint64(8 * i, 0x7ff8000000000000, Endian.little);
    } else {
      b.setFloat64(8 * i, v, Endian.little);
    }
  }
  return sha256.convert(b.buffer.asUint8List()).toString();
}

void main() {
  final Map<String, Object?> manifest = _json('$kReplayDataDir/MANIFEST.json');
  final Map<String, Object?> files = manifest['files']! as Map<String, Object?>;
  final Map<String, Object?> parity =
      _json('test/replay/fixtures/parse_parity.json')['files']!
          as Map<String, Object?>;

  test('번들 = 참조 엔진 load_all 의 24개', () {
    expect(files, hasLength(24));
    expect(parity.keys.toSet(), files.keys.toSet());
  });

  group('원본 바이트 그대로(gzip 을 풀면 원본 sha256)', () {
    for (final MapEntry<String, Object?> e in files.entries) {
      test(e.key, () {
        final Map<String, Object?> f = e.value! as Map<String, Object?>;
        final List<int> raw = gzip.decode(
          File('$kReplayDataDir/${e.key}.csv.gz').readAsBytesSync(),
        );
        expect(raw, hasLength(f['bytes']));
        expect(sha256.convert(raw).toString(), f['sha256']);
      });
    }
  });

  group('pandas 와 같은 비트로 읽는다(precise_xstrtod)', () {
    for (final MapEntry<String, Object?> e in parity.entries) {
      test(e.key, () {
        final Map<String, Object?> want = e.value! as Map<String, Object?>;
        final ReplayFrame frame = loadReplayCsv(e.key);
        expect(frame.index.first, want['index_first']);
        expect(frame.index.last, want['index_last']);
        final Map<String, Object?> cols =
            want['columns']! as Map<String, Object?>;
        expect(frame.columns.keys.toSet(), cols.keys.toSet());
        for (final MapEntry<String, Object?> c in cols.entries) {
          final Map<String, Object?> w = c.value! as Map<String, Object?>;
          final List<double> got = frame.column(c.key);
          expect(got, hasLength(w['rows']), reason: c.key);
          expect(
            got.where((double v) => v.isNaN).length,
            w['nan'],
            reason: c.key,
          );
          expect(_columnHash(got), w['sha256'], reason: c.key);
        }
      });
    }
  });

  group('pandasPreciseXstrtod — 정확 반올림과 다른 자리', () {
    test('17자리 넘는 값은 정확 반올림(double.parse)과 다를 수 있다', () {
      // qqq Adj Close 2019-07-19 — pandas 183.11087036132807 · float() 183.11087036132812(2 ULP).
      expect(pandasPreciseXstrtod('183.11087036132812'), 183.11087036132807);
      expect(double.parse('183.11087036132812'), 183.11087036132812);
    });
    test('짧은 소수는 정확 반올림과 같다(정수 ÷ 10^k 한 번)', () {
      expect(pandasPreciseXstrtod('17.01'), 17.01);
      expect(pandasPreciseXstrtod('-0.25'), -0.25);
      expect(pandasPreciseXstrtod('1e3'), 1000.0);
      expect(pandasPreciseXstrtod(' 42 '), 42.0);
    });
    test('숫자가 아니면 null(= coerce 의 NaN)', () {
      for (final String s in <String>[
        '',
        '.',
        'abc',
        '1.2.3',
        '1e',
        '-',
        '1,0',
      ]) {
        expect(pandasPreciseXstrtod(s), isNull, reason: s);
      }
    });
  });
}
