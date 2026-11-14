// 설정 지문(E11p3b-1 · 설계 13 §8 R90 · 06 01_모듈 `config_hash` «설정 내용의 SHA-256 앞 16자» · 00_SPEC).
//
// 🔴 지문 = SHA-256(정규 JSON) 의 hex 앞 16자. 정규 JSON = 맵 키 ASCII 순 · 공백 없음 · 잎은
//    null · bool · int · double(원장 해시와 같은 정규 표기 `canonicalDouble`) · Decimal(문자열) · String 만.
//    그 밖의 꼴 · 문자열이 아닌 맵 키 = ArgumentError(지어내지 않는다).
// 🔵 운영 파라미터(02 §4 `operations:` · 월 납입 등)는 지문에 넣지 않는다 — 부르는 쪽이 내용에서 뺀다.

import 'dart:convert' show utf8;

import 'package:crypto/crypto.dart' show sha256;
import 'package:decimal/decimal.dart';

import 'ledger_hash.dart' show canonicalDouble, canonicalString;

/// 설정 지문 길이(hex 자리).
const int kConfigFingerprintLength = 16;

/// 설정 내용의 정규 JSON.
String canonicalConfigJson(Object? v) {
  final StringBuffer b = StringBuffer();
  _write(b, v);
  return b.toString();
}

void _write(StringBuffer b, Object? v) {
  switch (v) {
    case null:
      b.write('null');
    case final bool x:
      b.write(x ? 'true' : 'false');
    case final int x:
      b.write(x.toString());
    case final double x:
      b.write(canonicalDouble(x));
    case final Decimal x:
      b.write(canonicalString(x.toString()));
    case final String x:
      b.write(canonicalString(x));
    case final List<Object?> xs:
      b.write('[');
      for (int i = 0; i < xs.length; i++) {
        if (i > 0) b.write(',');
        _write(b, xs[i]);
      }
      b.write(']');
    case final Map<Object?, Object?> m:
      final List<String> keys = <String>[];
      for (final Object? k in m.keys) {
        if (k is! String) {
          throw ArgumentError.value(k, 'key', '설정 맵의 키는 문자열이어야 한다');
        }
        keys.add(k);
      }
      keys.sort();
      b.write('{');
      for (int i = 0; i < keys.length; i++) {
        if (i > 0) b.write(',');
        b
          ..write(canonicalString(keys[i]))
          ..write(':');
        _write(b, m[keys[i]]);
      }
      b.write('}');
    default:
      throw ArgumentError.value(
        v,
        'value',
        '설정 값으로 쓸 수 없는 꼴: ${v.runtimeType}',
      );
  }
}

/// 🔴 설정 지문 = SHA-256(정규 JSON) hex 앞 16자.
String configFingerprint(Object? content) => sha256
    .convert(utf8.encode(canonicalConfigJson(content)))
    .toString()
    .substring(0, kConfigFingerprintLength);
