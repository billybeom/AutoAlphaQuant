// 골든벡터 기기 실행기 뼈대(E11o-a · 설계 13 §8 R161 · R162) — 결과 꼴 · 지문 · 실패 집계 · 판정 보류.
//
// 🔴 이식 전후 케이스 수를 고정한다(GV-1 7 · GV-2 12 · GV-3 8 · GV-4 13 = 40 — 옛 시험 수 그대로).
// 🔴 정답지 값을 하나 바꾸면 그 케이스만 실패해야 한다(실행기가 «통과»를 지어내지 않는다).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

/// 묶음의 파일 하나를 JSON 으로 고친 사본.
GoldenBundle _edited(
  Set<String> names,
  String name,
  void Function(Map<String, Object?> json) edit,
) {
  final GoldenBundle base = bundleOf(names);
  final Map<String, Object?> json =
      jsonDecode(jsonEncode(base.json(name))) as Map<String, Object?>;
  edit(json);
  return GoldenBundle(<String, String>{
    for (final String n in names) n: n == name ? jsonEncode(json) : _text(n),
  });
}

/// 원문 그대로(지문이 바뀐 파일 몫만 달라지게).
String _text(String name) => File('$kVectorsDir/$name').readAsStringSync();

/// 파일 하나를 빼거나 원문을 바꾼 묶음.
GoldenBundle _raw(Set<String> names, Map<String, String?> overrides) =>
    GoldenBundle(<String, String>{
      for (final String n in names)
        if (!overrides.containsKey(n)) n: _text(n),
      for (final MapEntry<String, String?> e in overrides.entries)
        if (e.value != null) e.key: e.value!,
    });

class _Throwing implements GoldenFamily {
  const _Throwing();

  @override
  String get id => 'GV-T';

  @override
  Set<String> get files => const <String>{};

  @override
  List<GvCase> cases(GoldenBundle bundle) => <GvCase>[
    GvCase('GV-T 통과', () => null),
    GvCase('GV-T 던짐', () => throw StateError('부서짐')),
  ];
}

void main() {
  final Set<String> files = kDeviceGoldenSuite.files;
  final GoldenSuite completeSuite = GoldenSuite(
    kDeviceGoldenSuite.families,
    complete: true,
  );

  group('실제 벡터', () {
    test('GV-1~4 = 40 케이스 전부 통과 · 아직 «전량» 아님', () {
      final GoldenRunResult r = kDeviceGoldenSuite.run(bundleOf(files));
      expect(r.failures, isEmpty);
      expect(r.total, 40);
      expect(r.passed, 40);
      expect(r.complete, isFalse);
      expect(r.allPassed, isFalse, reason: '부분 실행으로 «통과»를 말하지 않는다(R161 O5)');
      expect(r.digest, bundleOf(files).digest);
    });

    test('계열별 케이스 수 = 옛 시험 수(이식 전후 같음)', () {
      final GoldenBundle b = bundleOf(files);
      expect(
        <String, int>{
          for (final GoldenFamily f in kDeviceGoldenSuite.families)
            f.id: f.cases(b).length,
        },
        <String, int>{'GV-1': 7, 'GV-2': 12, 'GV-3': 8, 'GV-4': 13},
      );
      expect(
        kDeviceGoldenSuite.families.map((GoldenFamily f) => f.id).toSet(),
        hasLength(kDeviceGoldenSuite.families.length),
        reason: '계열 id 겹침 없음',
      );
    });

    test('파일 합 = 계열 선언 합(23) · 케이스 id 겹침 없음', () {
      expect(files, hasLength(23));
      final List<String> ids = <String>[
        for (final GoldenFamily f in kDeviceGoldenSuite.families)
          for (final GvCase c in f.cases(bundleOf(files))) c.id,
      ];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('완성 표시 실행기 = 전량 통과 · 포트 = 참', () async {
      expect(completeSuite.run(bundleOf(files)).allPassed, isTrue);
      expect(
        await SuiteGoldenSelfTest(
          completeSuite,
          () async => bundleOf(files),
        ).run(),
        isTrue,
      );
    });

    test('🔴 미완성 실행기의 포트 = 던진다(게이트에는 «아직»)', () {
      expect(
        SuiteGoldenSelfTest(
          kDeviceGoldenSuite,
          () async => bundleOf(files),
        ).run(),
        throwsStateError,
      );
    });
  });

  group('🔴 정답지 값을 하나 바꾸면 그 케이스만 실패', () {
    for (final (
          String file,
          String caseId,
          void Function(Map<String, Object?>) edit,
        )
        in <(String, String, void Function(Map<String, Object?>))>[
          (
            'gv01a_all_valid.json',
            'GV-1a',
            (Map<String, Object?> j) =>
                (j['expected']! as Map<String, Object?>)['direction'] = 60.001,
          ),
          (
            'gv02d_wilder_rma.json',
            'GV-2d Wilder 한 걸음',
            (Map<String, Object?> j) =>
                (j['expected']! as Map<String, Object?>)['rma'] = 10.7143,
          ),
          (
            'gv02f_adx_values.json',
            'GV-2f adx[199]',
            (Map<String, Object?> j) =>
                (j['expected']! as Map<String, Object?>)['adx[199]'] = 49.82292,
          ),
          (
            'gv03_exposure_gate.json',
            'GV-3 BULL × LOW',
            (Map<String, Object?> j) =>
                ((j['cases']! as List<Object?>)[1]!
                        as Map<String, Object?>)['expected_exposure'] =
                    0.5001,
          ),
          (
            'gv04_hysteresis.json',
            'GV-4 방향 25봉 bars_in_state',
            (Map<String, Object?> j) {
              final List<Object?> bars =
                  (j['expected']! as Map<String, Object?>)['bars_in_state']!
                      as List<Object?>;
              bars[0] = (bars[0]! as int) + 1;
            },
          ),
          (
            'gv01c_category_exclusion.json',
            'GV-1c',
            (Map<String, Object?> j) =>
                (j['expected']!
                        as Map<String, Object?>)['excluded_categories'] =
                    <Object?>[],
          ),
          (
            'gv01d_all_missing.json',
            'GV-1d',
            (Map<String, Object?> j) =>
                (j['expected']! as Map<String, Object?>)['status'] = 'OK',
          ),
          (
            'gv02c_adx_warmup.json',
            'GV-2c ADX 워밍업',
            (Map<String, Object?> j) =>
                (j['expected']! as Map<String, Object?>)['adx'] = 1.0,
          ),
          (
            'gv02e_bbw.json',
            'GV-2e BBW',
            (Map<String, Object?> j) =>
                ((j['expected']! as Map<String, Object?>)['bbw']!
                        as List<Object?>)[0] =
                    1.0,
          ),
          (
            'gv04f_trend_deadband.json',
            'GV-4f 추세성 dead-band',
            (Map<String, Object?> j) =>
                ((j['expected']! as Map<String, Object?>)['g']!
                        as List<Object?>)[0] =
                    1.0,
          ),
          (
            'gv04fb_trend_strict.json',
            'GV-4f-b b2',
            (Map<String, Object?> j) =>
                ((((j['cases']! as List<Object?>)[1]!
                                as Map<String, Object?>)['expected']!
                            as Map<String, Object?>)['trend_states']!
                        as List<Object?>)[0] =
                    'LOW',
          ),
        ]) {
      test('$file → $caseId', () async {
        final GoldenBundle b = _edited(files, file, edit);
        final GoldenRunResult r = completeSuite.run(b);
        expect(r.failures.map((GvFailure f) => f.caseId), <String>[caseId]);
        expect(r.total, 40);
        expect(r.passed, 39);
        expect(r.allPassed, isFalse);
        expect(r.digest, isNot(bundleOf(files).digest));
        expect(
          await SuiteGoldenSelfTest(completeSuite, () async => b).run(),
          isFalse,
        );
      });
    }
  });

  group('벡터가 없거나 꼴이 틀리면 실패(통과로 세지 않는다)', () {
    test('계열이 먼저 읽는 파일이 없으면 계열 = 실패 1', () {
      final GoldenRunResult r = completeSuite.run(
        _raw(files, <String, String?>{'gv02f_adx_values.json': null}),
      );
      expect(r.failures, hasLength(1));
      expect(r.failures.single.caseId, 'GV-2');
      expect(
        r.failures.single.detail,
        contains('벡터 없음: gv02f_adx_values.json'),
      );
      expect(r.total, 40 - 12 + 1);
      expect(r.allPassed, isFalse);
    });

    test('케이스가 읽는 파일이 없으면 그 케이스 = 실패', () {
      final GoldenRunResult r = completeSuite.run(
        _raw(files, <String, String?>{'gv01a_all_valid.json': null}),
      );
      expect(r.failures.map((GvFailure f) => f.caseId), <String>['GV-1a']);
      expect(r.failures.single.detail, contains('벡터 없음'));
      expect(r.total, 40);
    });

    test('JSON 이 깨지면 실패', () {
      final GoldenRunResult r = completeSuite.run(
        _raw(files, <String, String?>{'gv03_exposure_gate.json': '{'}),
      );
      expect(r.failures.map((GvFailure f) => f.caseId), <String>['GV-3']);
    });

    test('꼴이 틀리면(수 자리에 글자) 실패', () {
      final GoldenRunResult r = completeSuite.run(
        _edited(
          files,
          'gv02d_wilder_rma.json',
          (Map<String, Object?> j) =>
              (j['expected']! as Map<String, Object?>)['rma'] = '10.714286',
        ),
      );
      expect(r.failures.map((GvFailure f) => f.caseId), <String>[
        'GV-2d Wilder 한 걸음',
      ]);
    });

    test('케이스가 던지면 그 케이스 = 실패 · 나머지는 그대로', () {
      final GoldenRunResult r = const GoldenSuite(<GoldenFamily>[
        _Throwing(),
      ], complete: true).run(GoldenBundle(const <String, String>{}));
      expect(r.total, 2);
      expect(r.passed, 1);
      expect(r.failures.single.caseId, 'GV-T 던짐');
      expect(r.failures.single.detail, contains('예외'));
    });

    test('케이스 0 = 전량 통과 아님', () {
      final GoldenRunResult r = const GoldenSuite(
        <GoldenFamily>[],
        complete: true,
      ).run(GoldenBundle(const <String, String>{}));
      expect(r.total, 0);
      expect(r.allPassed, isFalse);
    });
  });

  group('묶음 지문', () {
    test('넣은 차례와 무관 · 원문이 바뀌면 다르다', () {
      final GoldenBundle a = GoldenBundle(const <String, String>{
        'x.json': '{}',
        'y.json': '{"a":1}',
      });
      final GoldenBundle b = GoldenBundle(const <String, String>{
        'y.json': '{"a":1}',
        'x.json': '{}',
      });
      final GoldenBundle c = GoldenBundle(const <String, String>{
        'x.json': '{}',
        'y.json': '{"a":2}',
      });
      expect(a.digest, b.digest);
      expect(a.digest, isNot(c.digest));
      expect(a.digest, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('이름 · 원문 경계가 섞이지 않는다', () {
      expect(
        GoldenBundle(const <String, String>{'a': 'bc'}).digest,
        isNot(GoldenBundle(const <String, String>{'ab': 'c'}).digest),
      );
    });

    test('빈 묶음 = 빈 입력의 SHA-256', () {
      expect(
        GoldenBundle(const <String, String>{}).digest,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('names = 오름차순', () {
      expect(
        GoldenBundle(const <String, String>{'b': '{}', 'a': '{}'}).names,
        <String>['a', 'b'],
      );
    });
  });

  group('판정 도우미', () {
    test('close — 허용오차 경계 안 · 밖 · null · NaN', () {
      expect((GvProbe()..close(1.0, 1.1, 0.1 + 1e-12)).failure, isNull);
      expect((GvProbe()..close(1.0, 1.2, 0.1)).failure, isNotNull);
      expect((GvProbe()..close(null, 1.0, 0.1)).failure, isNotNull);
      expect((GvProbe()..close(double.nan, 1.0, 0.1)).failure, isNotNull);
    });

    test('series — 길이 · 결측 자리 · 값', () {
      expect(
        (GvProbe()..series(<double?>[null, 1.0], <double?>[null, 1.0], 0))
            .failure,
        isNull,
      );
      expect(
        (GvProbe()..series(<double?>[1.0], <double?>[1.0, 2.0], 0)).failure,
        contains('길이'),
      );
      expect(
        (GvProbe()..series(<double?>[0.0, 1.0], <double?>[null, 1.0], 0))
            .failure,
        contains('결측 자리'),
      );
      expect(
        (GvProbe()..series(<double?>[null, 1.0], <double?>[null, 2.0], 0.5))
            .failure,
        isNotNull,
      );
    });

    test('same — 목록 · 객체 칸마다 · 수 1 = 1.0', () {
      expect(
        (GvProbe()..same(
              <Object?>[
                1,
                <String, Object?>{
                  'a': <int>[1],
                },
              ],
              <Object?>[
                1.0,
                <String, Object?>{
                  'a': <double>[1.0],
                },
              ],
            ))
            .failure,
        isNull,
      );
      expect((GvProbe()..same(<int>[1, 2], <int>[1])).failure, isNotNull);
      expect(
        (GvProbe()..same(<String, Object?>{'a': 1}, <String, Object?>{'b': 1}))
            .failure,
        isNotNull,
      );
    });

    test('여러 어긋남은 한 줄로 이어 낸다', () {
      final GvProbe p = GvProbe()
        ..truth(false, 'A')
        ..none(1, 'B');
      expect(p.failure, 'A · B 기대 null · 실제 1');
    });

    test('읽기 — 정수 소수부 = 거부 · 결측 = null · 꼴 틀림 = FormatException', () {
      expect(gvInt(500.0), 500);
      expect(() => gvInt(1.5), throwsFormatException);
      expect(gvNumList(<Object?>[null, 1]), <double?>[null, 1.0]);
      expect(() => gvObject(<Object?>[]), throwsFormatException);
      expect(() => gvString(1), throwsFormatException);
      expect(() => gvIntList('x'), throwsFormatException);
      expect(
        () => GoldenBundle(const <String, String>{'a': '[]'}).json('a'),
        throwsFormatException,
      );
    });
  });
}
