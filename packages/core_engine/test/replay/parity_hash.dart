// 재현 정답지 해시 — tool/export_replay_*.py 와 같은 규약(float64 리틀 엔디언 · NaN 하나로 · 줄 해시).

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// float64 바이트를 이어 붙인 sha256 — null·NaN 은 0x7ff8000000000000.
String floatHash(Iterable<double?> values) {
  final List<double?> v = values.toList();
  final ByteData b = ByteData(8 * v.length);
  for (int i = 0; i < v.length; i++) {
    final double? x = v[i];
    if (x == null || x.isNaN) {
      b.setUint64(8 * i, 0x7ff8000000000000, Endian.little);
    } else {
      b.setFloat64(8 * i, x, Endian.little);
    }
  }
  return sha256.convert(b.buffer.asUint8List()).toString();
}

/// «값\n» 을 이어 붙인 sha256.
String lineHash(Iterable<Object> lines) => sha256
    .convert(utf8.encode(lines.map((Object l) => '$l\n').join()))
    .toString();
