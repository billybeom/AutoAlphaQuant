// 골든벡터 기기 실행기(E11o-a · b · c1 · 설계 13 §8 R161 · R162 · R163 · R164) — 결과 꼴 · 지문 · 실패 집계 · 판정 보류.
//
// 🔴 이식 전후 케이스 수를 고정한다([_kCases] — 옛 시험 수 그대로 · 05 총계가 아니다(README 규칙 4 와 다름)).
// 🔴 정답지 값을 하나 바꾸면 그 케이스만 실패해야 한다(실행기가 «통과»를 지어내지 않는다).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
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

/// JSON 안 경로의 객체(문자열 = 키 · 정수 = 목록 자리).
Map<String, Object?> _at(Map<String, Object?> json, List<Object> path) {
  Object? cur = json;
  for (final Object k in path) {
    cur = k is int
        ? (cur! as List<Object?>)[k]
        : (cur! as Map<String, Object?>)[k];
  }
  return cur! as Map<String, Object?>;
}

/// 수 칸에 1 을 더한다.
void _bump(Map<String, Object?> o, String key) => o[key] = (o[key]! as num) + 1;

/// 참거짓 칸을 뒤집는다.
void _flip(Map<String, Object?> o, String key) => o[key] = !(o[key]! as bool);

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

/// 계열별 케이스 수 = 옛 시험 수(GV-3 = 벡터 8 · 코드 규칙 3 은 시험에 남음 · GV-12 = 벡터 14 · 세션 표 머리말 1 은
/// 시험에 남음 · GV-11 = 11 · 11e · 11d · 19 · 24 · GV-20 = 20 · 23 · 38 · GV-22 = 22 · 35 · 36 · GV-31 = 31 · s_h5_1 · 18
/// · GV-32 = 32 · 39 · 17 · GV-37 = 37 · 28d).
const Map<String, int> _kCases = <String, int>{
  'GV-1': 7,
  'GV-2': 12,
  'GV-3': 8,
  'GV-4': 13,
  'GV-8': 17,
  'GV-9': 8,
  'GV-11': 22,
  'GV-12': 14,
  'GV-13': 5,
  'GV-30': 5,
  'GV-20': 18,
  'GV-22': 15,
  'GV-31': 36,
  'GV-32': 87,
  'GV-37': 18,
  'GV-40d': 4,
  'GV-40e': 10,
  'GV-42': 13,
  'GV-16': 7,
};

final int _total = _kCases.values.fold(0, (int a, int b) => a + b);

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
    test('옮긴 계열 전부 통과 · 아직 «전량» 아님', () async {
      final GoldenRunResult r = await kDeviceGoldenSuite.run(bundleOf(files));
      expect(r.failures, isEmpty);
      expect(_total, 319);
      expect(r.total, _total);
      expect(r.passed, _total);
      expect(r.complete, isFalse);
      expect(r.allPassed, isFalse, reason: '부분 실행으로 «통과»를 말하지 않는다(R161 O5)');
      expect(r.digest, bundleOf(files).digest);
    });

    test('계열별 케이스 수 = 옛 시험 수(이식 전후 같음)', () {
      final GoldenBundle b = bundleOf(files);
      expect(<String, int>{
        for (final GoldenFamily f in kDeviceGoldenSuite.families)
          f.id: f.cases(b).length,
      }, _kCases);
      expect(
        kDeviceGoldenSuite.families.map((GoldenFamily f) => f.id).toSet(),
        hasLength(kDeviceGoldenSuite.families.length),
        reason: '계열 id 겹침 없음',
      );
    });

    test('파일 합 = 계열 선언 합(49) · 케이스 id 겹침 없음', () {
      expect(files, hasLength(49));
      final List<String> ids = <String>[
        for (final GoldenFamily f in kDeviceGoldenSuite.families)
          for (final GvCase c in f.cases(bundleOf(files))) c.id,
      ];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('완성 표시 실행기 = 전량 통과 · 포트 = 참', () async {
      expect((await completeSuite.run(bundleOf(files))).allPassed, isTrue);
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
          (
            'gv08_sizing.json',
            'GV-8a 파일럿1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0, 'expected'])['qty_by_risk'] = 501.0,
          ),
          (
            'gv08_machine_block.json',
            'GV-8a 기계 채점',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0, 'expected'])['notional_value'] =
                    5000001,
          ),
          (
            'gv09_idempotency_key.json',
            'GV-9 v1|KR|',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0])['expected_key'] = '0' * 64,
          ),
          (
            'gv13_decision_id.json',
            'GV-13 v1 감시 4회',
            (Map<String, Object?> j) => _at(j, <Object>[
              'cases',
              0,
              'expected',
            ])['broker.submit_order_call_count'] = 2,
          ),
          (
            'gv11_trade_cost.json',
            'GV-11a',
            (Map<String, Object?> j) => _bump(
              _at(j, <Object>['cases', 0, 'expected']),
              'market_impact',
            ),
          ),
          (
            'gv11e_tier_boundary_us.json',
            'GV-11e c1',
            (Map<String, Object?> j) =>
                _bump(_at(j, <Object>['cases', 0, 'expected']), 'slippage'),
          ),
          (
            'gv19_cost_in_pnl.json',
            'GV-19 정답지 원문',
            (Map<String, Object?> j) =>
                _at(j, <Object>['expected'])['net_pnl'] = -140999,
          ),
          (
            'gv24_holding_cost.json',
            'GV-24 e1',
            (Map<String, Object?> j) =>
                _bump(_at(j, <Object>['cases', 0]), 'expected_value'),
          ),
          (
            'gv12_trading_day.json',
            'GV-12 XKRX 2026-08-31',
            (Map<String, Object?> j) =>
                _flip(_at(j, <Object>['cases', 0, 'expected']), 'is_session'),
          ),
          (
            'gv12c_last_session_negative.json',
            'GV-12c 2026-01-29',
            (Map<String, Object?> j) => _flip(
              _at(j, <Object>['cases', 0, 'expected']),
              'is_last_session_of_month',
            ),
          ),
          (
            'gv30_split_execution.json',
            'GV-30 e4',
            (Map<String, Object?> j) {
              final List<Object?> q =
                  _at(j, <Object>['cases', 3, 'expected'])['daily_qty']!
                      as List<Object?>;
              q[2] = (q[2]! as int) + 1;
            },
          ),
          (
            'gv30_split_execution.json',
            'GV-30 집행일',
            (Map<String, Object?> j) =>
                (j['sessions']! as List<Object?>)[0] = '2026-01-02',
          ),
          (
            'gv20_sleeve_b_tranche.json',
            'GV-20 b1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0])['expected_ratio'] = 0.5,
          ),
          (
            'gv23_partial_exit.json',
            'GV-23 r1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0])['expected_exit_fraction'] = 0.5,
          ),
          (
            'gv35_38_decisions.json',
            'GV-38 38-1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['GV-38', 0])['expected'] = 0.5,
          ),
          (
            'gv22_sleeve_c_gold_cap.json',
            'GV-22 q2',
            (Map<String, Object?> j) =>
                _bump(_at(j, <Object>['cases', 1, 'expected']), 'IAU'),
          ),
          (
            'gv35_38_decisions.json',
            'GV-36 36-1',
            (Map<String, Object?> j) {
              final List<Object?> pair =
                  (_at(j, <Object>['GV-36', 0])['expected']!
                          as List<Object?>)[0]!
                      as List<Object?>;
              pair[1] = (pair[1]! as num) + 1;
            },
          ),
          (
            'gv35_38_decisions.json',
            'GV-37 37-1',
            (Map<String, Object?> j) {
              final List<Object?> e =
                  _at(j, <Object>['GV-37', 0])['expected']! as List<Object?>;
              e[1] = (e[1]! as num) + 1;
            },
          ),
          (
            'gv28d_deposit.json',
            'GV-28d d1',
            (Map<String, Object?> j) =>
                _bump(_at(j, <Object>['GV-28d', 0, 'expected']), 'residual'),
          ),
          (
            'gv42_allocation.json',
            'GV-42 42-1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['GV-42', 0, 'expected'])['sleeve_a'] =
                    (_at(j, <Object>['GV-42', 0, 'expected'])['sleeve_a']!
                        as num) +
                    0.001,
          ),
          (
            'gv42_allocation.json',
            'GV-42 42-6',
            (Map<String, Object?> j) =>
                _at(j, <Object>['GV-42', 5, 'expected'])['reason_contains'] =
                    '다른 사유',
          ),
          (
            'gv31_breaker_vectors.json',
            'GV-31 단발 s01',
            (Map<String, Object?> j) =>
                _at(j, <Object>['step_cases', 0])['expected'] = 'ALERT',
          ),
          (
            'gv31_breaker_vectors.json',
            'GV-31 시퀀스 q1_full_descent',
            (Map<String, Object?> j) {
              final List<Object?> levels =
                  _at(j, <Object>[
                        'sequence_cases',
                        'q1_full_descent',
                      ])['expected_levels']!
                      as List<Object?>;
              levels[levels.length - 1] = 'BOGUS';
            },
          ),
          (
            'gv31_s_h5_1_J1_stopped.json',
            'GV-31 s_h5_1 off',
            (Map<String, Object?> j) => _at(j, <Object>[
              'vectorB_deterministic',
              'off',
            ])['final_level'] = 'NORMAL',
          ),
          (
            'gv18_exposure_multiplier.json',
            'GV-18 NORMAL',
            (Map<String, Object?> j) =>
                _bump(_at(j, <Object>['cases', 0, 'expected']), 'sleeve_a'),
          ),
          (
            'gv32_saf_vectors.json',
            'GV-32 s00_pass_kr',
            (Map<String, Object?> j) =>
                _flip(_at(j, <Object>['cases', 0, 'expected']), 'allowed'),
          ),
          (
            'gv39_trace_vectors.json',
            'GV-39 g01',
            (Map<String, Object?> j) {
              final Map<String, Object?> e = _at(j, <Object>[
                'cases',
                1,
                'expected',
              ]);
              e['trace'] = (e['trace']! as List<Object?>).reversed.toList();
            },
          ),
          (
            'gv17_fail_closed.json',
            'GV-17 x1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['cases', 0])['expected'] = <String, Object?>{
                  'allowed': true,
                  'violated': <Object?>['X'],
                },
          ),
          (
            'gv17_fail_closed.json',
            'GV-17 x7',
            (Map<String, Object?> j) =>
                _flip(_at(j, <Object>['cases', 6, 'expected']), 'allowed'),
          ),
          (
            'gv16_pit_percentile.json',
            'GV-16 out[755]',
            (Map<String, Object?> j) =>
                _at(j, <Object>['expected'])['out[755]'] = 68.5,
          ),
          (
            'gv16_pit_percentile.json',
            'GV-16 생성식',
            (Map<String, Object?> j) =>
                _at(j, <Object>['invariants'])['warmup'] = '다른 산문',
          ),
          (
            'gv40_saf_warn.json',
            'GV-40d d1',
            (Map<String, Object?> j) =>
                _at(j, <Object>['GV-40d', 0, 'expected'])['action'] = '기동 거부',
          ),
          (
            'gv40_saf_warn.json',
            'GV-40e e1',
            (Map<String, Object?> j) => _bump(
              _at(j, <Object>['GV-40e', 0, 'expected', 'metrics']),
              'rolling_12m_count',
            ),
          ),
        ]) {
      test('$file → $caseId', () async {
        final GoldenBundle b = _edited(files, file, edit);
        final GoldenRunResult r = await completeSuite.run(b);
        expect(r.failures, hasLength(1), reason: '${r.failures}');
        expect(r.failures.single.caseId, startsWith(caseId));
        expect(r.total, _total);
        expect(r.passed, _total - 1);
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
    test('계열이 먼저 읽는 파일이 없으면 계열 = 실패 1', () async {
      final GoldenRunResult r = await completeSuite.run(
        _raw(files, <String, String?>{'gv02f_adx_values.json': null}),
      );
      expect(r.failures, hasLength(1));
      expect(r.failures.single.caseId, 'GV-2');
      expect(
        r.failures.single.detail,
        contains('벡터 없음: gv02f_adx_values.json'),
      );
      expect(r.total, _total - 12 + 1);
      expect(r.allPassed, isFalse);
    });

    test('케이스가 읽는 파일이 없으면 그 케이스 = 실패', () async {
      final GoldenRunResult r = await completeSuite.run(
        _raw(files, <String, String?>{'gv01a_all_valid.json': null}),
      );
      expect(r.failures.map((GvFailure f) => f.caseId), <String>['GV-1a']);
      expect(r.failures.single.detail, contains('벡터 없음'));
      expect(r.total, _total);
    });

    test('JSON 이 깨지면 실패', () async {
      final GoldenRunResult r = await completeSuite.run(
        _raw(files, <String, String?>{'gv03_exposure_gate.json': '{'}),
      );
      expect(r.failures.map((GvFailure f) => f.caseId), <String>['GV-3']);
    });

    test('꼴이 틀리면(수 자리에 글자) 실패', () async {
      final GoldenRunResult r = await completeSuite.run(
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

    test('케이스가 던지면 그 케이스 = 실패 · 나머지는 그대로', () async {
      final GoldenRunResult r = await const GoldenSuite(<GoldenFamily>[
        _Throwing(),
      ], complete: true).run(GoldenBundle(const <String, String>{}));
      expect(r.total, 2);
      expect(r.passed, 1);
      expect(r.failures.single.caseId, 'GV-T 던짐');
      expect(r.failures.single.detail, contains('예외'));
    });

    test('케이스 0 = 전량 통과 아님', () async {
      final GoldenRunResult r = await const GoldenSuite(
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

    test('throws — 맞는 예외 = 통과 · 안 던짐 · 다른 예외 = 실패', () {
      bool isArg(Object e) => e is ArgumentError;
      expect(
        (GvProbe()..throws(() => throw ArgumentError('x'), isArg, 'A')).failure,
        isNull,
      );
      expect(
        (GvProbe()..throws(() {}, isArg, 'A')).failure,
        contains('던지지 않았다'),
      );
      expect(
        (GvProbe()..throws(() => throw StateError('x'), isArg, 'A')).failure,
        contains('다른 예외'),
      );
    });

    test('same — 집합은 차례 무관 · 원소가 다르면 실패', () {
      expect(
        (GvProbe()..same(<String>{'a', 'b'}, <String>{'b', 'a'})).failure,
        isNull,
      );
      expect(
        (GvProbe()..same(<String>{'a', 'b'}, <String>{'a', 'c'})).failure,
        isNotNull,
      );
    });

    test('gvDecimal — 문자열을 거친다 · 수 · 글자 · 그 밖 = FormatException', () {
      expect(gvDecimal(0.0035), Decimal.parse('0.0035'));
      expect(gvDecimal('174180.5'), Decimal.parse('174180.5'));
      expect(gvDecimal(5000000), Decimal.parse('5000000'));
      expect(() => gvDecimal(true), throwsFormatException);
      expect(() => gvDecimal('1,000'), throwsFormatException);
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
