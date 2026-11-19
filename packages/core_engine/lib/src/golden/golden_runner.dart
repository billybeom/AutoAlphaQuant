// 골든벡터 기기 실행기 뼈대(E11o-a · 설계 13 §8 R161 · R162 · 계획서 `10_리뷰/2026-11-19_E11o_골든실행기_나눔계획.md`).
//
// 🔴 한 정본 — 비교 논리는 여기(lib)에만 있다. 시험(`test/golden/`)은 이 케이스를 그대로 부르고, 폰도 같은 케이스를 돈다
//    (시험 = 폰 같은 판정 · 두 벌 0).
// 🔴 판정 재료만 — 통과 = null · 실패 = 한 줄. 정답지를 고치지 않는다(test/golden/README 규칙 3).
// 🔴 [GoldenSuite.complete] 가 거짓이면 «전량»이 아니다 — 앱은 버튼을 내지 않고 «판정 보류»(부분 실행으로 통과를 말하지 않는다 · R161 O5).
// 🔴 순수 — 파일 · 자산 읽기 0([GoldenBundle] 은 이름 → 원문을 받는다 · 시험 = 파일 · 앱 = 자산).

import 'dart:convert' show jsonDecode, utf8;

import 'package:crypto/crypto.dart' show sha256;

import '../migration/golden_self_test.dart' show GoldenSelfTest;

/// 벡터 묶음(파일 이름 → JSON 원문) · 지문.
class GoldenBundle {
  /// 만든다.
  GoldenBundle(Map<String, String> files)
    : _files = Map<String, String>.unmodifiable(files);

  final Map<String, String> _files;
  final Map<String, Map<String, Object?>> _decoded =
      <String, Map<String, Object?>>{};

  /// 파일 이름들(오름차순).
  List<String> get names => _files.keys.toList()..sort();

  /// 파일 하나(JSON 객체) — 없음 · 객체 아님 = [FormatException].
  Map<String, Object?> json(String name) => _decoded.putIfAbsent(name, () {
    final String? text = _files[name];
    if (text == null) throw FormatException('벡터 없음: $name');
    return gvObject(jsonDecode(text));
  });

  /// 🔴 묶음 지문 — SHA-256(이름 · 원문을 이름 차례로 이은 것).
  String get digest {
    final StringBuffer b = StringBuffer();
    for (final String n in names) {
      b
        ..write(n)
        ..write('\u0000')
        ..write(_files[n])
        ..write('\u0000');
    }
    return sha256.convert(utf8.encode(b.toString())).toString();
  }
}

/// 케이스 한 판정의 실패.
class GvFailure {
  /// 만든다.
  const GvFailure(this.caseId, this.detail);

  /// 케이스 id(«GV-1a» 꼴).
  final String caseId;

  /// 한 줄.
  final String detail;

  @override
  String toString() => '$caseId: $detail';
}

/// 케이스 하나 — [check] 통과 = null · 실패 = 한 줄.
class GvCase {
  /// 만든다.
  const GvCase(this.id, this.check);

  /// 케이스 id.
  final String id;

  /// 판정.
  final String? Function() check;
}

/// 계열 하나(GV-1 · GV-2 …).
abstract interface class GoldenFamily {
  /// 계열 id(«GV-1»).
  String get id;

  /// 이 계열이 읽는 벡터 파일.
  Set<String> get files;

  /// 케이스 목록(묶음을 읽어 만든다 — 없음 · 꼴 틀림 = [FormatException]).
  List<GvCase> cases(GoldenBundle bundle);
}

/// 한 번 돈 결과(미결 198 — 결과 꼴).
class GoldenRunResult {
  /// 만든다.
  const GoldenRunResult({
    required this.digest,
    required this.passed,
    required this.total,
    required this.failures,
    required this.complete,
  });

  /// 묶음 지문.
  final String digest;

  /// 통과 수.
  final int passed;

  /// 전체 수.
  final int total;

  /// 실패 목록(케이스 차례).
  final List<GvFailure> failures;

  /// 전 계열이 실렸나(거짓 = «전량» 아님).
  final bool complete;

  /// 전량 통과인가(전 계열 · 실패 0 · 케이스 1 이상).
  bool get allPassed => complete && total > 0 && failures.isEmpty;
}

/// 실행기(계열 목록 · 완성 여부).
class GoldenSuite {
  /// 만든다.
  const GoldenSuite(this.families, {required this.complete});

  /// 계열(차례).
  final List<GoldenFamily> families;

  /// 05 의 GV 계열이 전부 실렸나.
  final bool complete;

  /// 계열들이 읽는 벡터 파일 합(앱 자산 목록 = 이것만 · 조각 d).
  Set<String> get files => <String>{
    for (final GoldenFamily f in families) ...f.files,
  };

  /// 🔴 묶음으로 돈다 — 계열이 케이스를 못 만들면(벡터 없음 · 꼴 틀림) 그 계열 = 실패 1 · 케이스가 던지면 그 케이스 = 실패.
  GoldenRunResult run(GoldenBundle bundle) {
    final List<GvFailure> failures = <GvFailure>[];
    int total = 0;
    for (final GoldenFamily f in families) {
      final List<GvCase> cs;
      try {
        cs = f.cases(bundle);
      } on Object catch (e) {
        total++;
        failures.add(GvFailure(f.id, '케이스를 만들지 못했다 — $e'));
        continue;
      }
      for (final GvCase c in cs) {
        total++;
        String? bad;
        try {
          bad = c.check();
        } on Object catch (e) {
          bad = '예외 — $e';
        }
        if (bad != null) failures.add(GvFailure(c.id, bad));
      }
    }
    return GoldenRunResult(
      digest: bundle.digest,
      passed: total - failures.length,
      total: total,
      failures: List<GvFailure>.unmodifiable(failures),
      complete: complete,
    );
  }
}

/// 🔴 포트 구현 — 완성 전 = [StateError](돌릴 수 없으면 던진다 · 게이트에는 «아직» · 포트 머리).
class SuiteGoldenSelfTest implements GoldenSelfTest {
  /// 만든다 — [bundle] = 벡터 묶음을 주는 함수(앱 = 자산).
  const SuiteGoldenSelfTest(this.suite, this.bundle);

  /// 실행기.
  final GoldenSuite suite;

  /// 묶음.
  final Future<GoldenBundle> Function() bundle;

  @override
  Future<bool> run() async {
    if (!suite.complete) {
      throw StateError('골든 실행기 미완성 — 판정 보류');
    }
    return suite.run(await bundle()).allPassed;
  }
}

/// 판정 도우미 — 어긋남을 모았다가 한 줄로 낸다.
class GvProbe {
  final List<String> _bad = <String>[];

  /// 허용오차 안(실제 null · NaN = 실패).
  void close(
    double? actual,
    double expected,
    double tolerance, [
    String what = '',
  ]) {
    final double? a = actual;
    if (a == null || !((a - expected).abs() <= tolerance)) {
      _bad.add('$what 기대 $expected ±$tolerance · 실제 $actual');
    }
  }

  /// 같다(목록 · 객체 = 칸마다).
  void same(Object? actual, Object? expected, [String what = '']) {
    if (!_deepEquals(actual, expected)) {
      _bad.add('$what 기대 $expected · 실제 $actual');
    }
  }

  /// null 이다.
  void none(Object? actual, [String what = '']) {
    if (actual != null) _bad.add('$what 기대 null · 실제 $actual');
  }

  /// 참이다.
  void truth(bool ok, String what) {
    if (!ok) _bad.add(what);
  }

  /// 🔴 시리즈 칸마다 — 기대 null = 결측이어야 · 아니면 허용오차 안(시험 하네스 `expectSeries` 와 같은 규칙).
  void series(
    List<double?> actual,
    List<double?> expected,
    double tolerance, [
    String what = '',
  ]) {
    if (actual.length != expected.length) {
      _bad.add('$what 길이 기대 ${expected.length} · 실제 ${actual.length}');
      return;
    }
    for (int i = 0; i < expected.length; i++) {
      final double? want = expected[i];
      if (want == null) {
        none(actual[i], '$what[$i] 결측 자리');
      } else {
        close(actual[i], want, tolerance, '$what[$i]');
      }
    }
  }

  /// 결과(통과 = null).
  String? get failure => _bad.isEmpty ? null : _bad.join(' · ');
}

bool _deepEquals(Object? a, Object? b) {
  if (a is List<Object?> && b is List<Object?>) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map<Object?, Object?> && b is Map<Object?, Object?>) {
    if (a.length != b.length) return false;
    for (final Object? k in a.keys) {
      if (!b.containsKey(k) || !_deepEquals(a[k], b[k])) return false;
    }
    return true;
  }
  return a == b;
}

// ── 정답지 읽기(시험 하네스 `golden_vectors.dart` 와 같은 규칙 · 꼴 틀림 = FormatException) ──

/// JSON 객체.
Map<String, Object?> gvObject(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('정답지에서 객체를 기대했다', value);
}

/// JSON 객체 목록.
List<Map<String, Object?>> gvObjectList(Object? value) {
  if (value is List<Object?>) return value.map(gvObject).toList();
  throw FormatException('정답지에서 목록을 기대했다', value);
}

/// 문자열.
String gvString(Object? value) {
  if (value is String) return value;
  throw FormatException('정답지에서 문자열을 기대했다', value);
}

/// 문자열 목록.
List<String> gvStringList(Object? value) {
  if (value is List<Object?>) return value.map(gvString).toList();
  throw FormatException('정답지에서 문자열 목록을 기대했다', value);
}

/// 수.
double gvDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw FormatException('정답지에서 수를 기대했다', value);
}

/// 정수(`500` 과 `500.0` 같게 · 소수부 = 실패).
int gvInt(Object? value) {
  if (value is int) return value;
  if (value is double && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw FormatException('정답지에서 정수를 기대했다', value);
}

/// 정수 목록.
List<int> gvIntList(Object? value) {
  if (value is List<Object?>) return value.map(gvInt).toList();
  throw FormatException('정답지에서 정수 목록을 기대했다', value);
}

/// 수 목록(null = 결측).
List<double?> gvNumList(Object? value) {
  if (value is List<Object?>) {
    return <double?>[
      for (final Object? v in value) v == null ? null : gvDouble(v),
    ];
  }
  throw FormatException('정답지에서 수 목록을 기대했다', value);
}
