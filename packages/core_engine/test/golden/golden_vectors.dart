// 골든벡터 하네스 — `test/golden/vectors/` 의 JSON 을 읽어 테스트에 넘긴다.
//
// 🔴 정답지를 고치지 않는다. 테스트가 깨지면 계산이 바뀐 것이다(README 규칙 3).
// 🔴 JSON 숫자를 Decimal 로 옮길 때는 문자열을 거친다(규약 ① 과 같은 이유 —
//    `0.0035` 의 이진 값을 그대로 옮기지 않는다).
// ⚠️ 파일 경로는 패키지 루트 기준이다 — `dart test` 는 패키지 루트에서 돈다.

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

/// 정답지 폴더(패키지 루트 기준).
const String kVectorsDir = 'test/golden/vectors';

/// 정답지 하나를 읽는다.
Map<String, Object?> loadVector(String fileName) =>
    asObject(jsonDecode(File('$kVectorsDir/$fileName').readAsStringSync()));

/// JSON 객체로 읽는다. 아니면 실패 — 정답지 꼴이 바뀐 것이다.
Map<String, Object?> asObject(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw StateError('정답지에서 객체를 기대했다: $value');
}

/// JSON 객체 목록으로 읽는다.
List<Map<String, Object?>> asObjectList(Object? value) {
  if (value is List<Object?>) return value.map(asObject).toList();
  throw StateError('정답지에서 목록을 기대했다: $value');
}

/// 문자열 목록으로 읽는다(예 `exact_fields`).
List<String> asStringList(Object? value) {
  if (value is List<Object?>) return value.map(asString).toList();
  throw StateError('정답지에서 문자열 목록을 기대했다: $value');
}

/// 문자열로 읽는다.
String asString(Object? value) {
  if (value is String) return value;
  throw StateError('정답지에서 문자열을 기대했다: $value');
}

/// 수(double)로 읽는다 — 비율·허용오차·비교용 근사값.
double asDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw StateError('정답지에서 수를 기대했다: $value');
}

/// 정수로 읽는다 — 수량. `500` 과 `500.0` 을 같게 받되 소수부가 있으면 실패.
int asInt(Object? value) {
  if (value is int) return value;
  if (value is double && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw StateError('정답지에서 정수를 기대했다: $value');
}

/// 수 목록으로 읽는다 — JSON `null` 은 결측(null)으로 둔다(지표 워밍업 구간).
List<double?> asNumList(Object? value) {
  if (value is List<Object?>) {
    return <double?>[
      for (final Object? v in value) v == null ? null : asDouble(v),
    ];
  }
  throw StateError('정답지에서 수 목록을 기대했다: $value');
}

/// 시리즈를 칸마다 대조한다 — 기대가 null 이면 결측이어야 하고, 아니면 허용오차 안.
void expectSeries(
  List<double?> actual,
  List<double?> expected,
  double tolerance,
) {
  expect(actual, hasLength(expected.length));
  for (int i = 0; i < expected.length; i++) {
    final double? want = expected[i];
    if (want == null) {
      expect(actual[i], isNull, reason: '[$i] 워밍업·결측 자리');
    } else {
      expect(actual[i], closeTo(want, tolerance), reason: '[$i]');
    }
  }
}

/// 금액·가격으로 읽는다. 문자열이든 수든 **문자열을 거쳐** Decimal 로.
Decimal asDecimal(Object? value) => switch (value) {
  final String s => Decimal.parse(s),
  final num n => Decimal.parse(n.toString()),
  _ => throw StateError('정답지에서 금액을 기대했다: $value'),
};
