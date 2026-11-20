// E11k-c — o_07 ② 연결 확인 결과(설계 13 §8 R206 · 계약 v1.29 01 §39 · 표본 `m8/onboarding_supabase_connect_results`).
//
// 🔵 잡는 것: ① 표본 12줄 = 엔진 결과(등급 · 글자 · 사유 코드 · 재시도) 글자 그대로 ② 입력 6 · 망 5 전수 · 🔴 금고 3 = StateError
//    ③ 첫 문제 차례(빈 칸 → 주소 → 키) ④ 연결 확인 = 입력 문제면 망 0 · 통과 = 1회 · 🔴 금고를 읽지도 쓰지도 않는다
//    ⑤ 저장 = 꼴 맞을 때만(바탕 주소 · 앞뒤 빈칸 뗌) · 꼴 아님 = 금고 쓰기 0.
// 🔴 시험 주소 · 키는 이어 붙여 만든다(저장소에 키 꼴 리터럴 0 · 실 Supabase 호출 0).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show UiLevel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
final String _secret = 'sb_${'secret'}_${'K' * 12}${'4' * 10}';
const String _date = 'Tue, 08 Dec 2026 00:00:07 GMT';

List<Map<String, Object?>> _fixture() =>
    ((jsonDecode(
              File(
                '../domain_contracts/fixtures/m8/onboarding_supabase_connect_results.json',
              ).readAsStringSync(),
            ) as Map<String, Object?>)['rows']!
            as List<Object?>)
        .cast<Map<String, Object?>>();

SupabaseConnectOutcome _engineFor(String? code) {
  if (code == null) return kSupabaseConnectOk;
  for (final SupabaseInputProblem p in SupabaseInputProblem.values) {
    if (p.wire == code) return supabaseInputOutcome(p);
  }
  for (final SupabaseTimeFailure f in SupabaseTimeFailure.values) {
    if (f.wire == code) return supabaseTimeOutcome(f);
  }
  throw StateError('엔진에 없는 코드: $code');
}

class _Rig {
  _Rig(this.respond);
  final Future<http.Response> Function(http.Request r) respond;
  final List<http.Request> requests = <http.Request>[];
  final MemorySecretVault vault = MemorySecretVault();
  late final SupabaseServerTime time = SupabaseServerTime(
    MockClient((http.Request r) async {
      requests.add(r);
      return respond(r);
    }),
    vault,
    timeout: const Duration(milliseconds: 200),
  );
}

http.Response _ok({int code = 200}) =>
    http.Response('{}', code, headers: <String, String>{'date': _date});

void main() {
  group('표본 12줄 = 엔진 결과', () {
    final List<Map<String, Object?>> rows = _fixture();

    test('줄 수 = 통과 1 + 입력 6 + 망 5', () {
      expect(rows, hasLength(12));
      final Set<String?> codes = rows
          .map((Map<String, Object?> r) => r['reason_code'] as String?)
          .toSet();
      expect(codes, <String?>{
        null,
        ...SupabaseInputProblem.values.map((SupabaseInputProblem p) => p.wire),
        SupabaseTimeFailure.unauthorized.wire,
        SupabaseTimeFailure.server.wire,
        SupabaseTimeFailure.badResponse.wire,
        SupabaseTimeFailure.noDate.wire,
        SupabaseTimeFailure.network.wire,
      });
    });

    for (final Map<String, Object?> row in _fixture()) {
      test(
        '${row['action_run_id']} ${row['reason_code'] ?? 'OK'} — 등급 · 글자 · 재시도 글자 그대로',
        () {
          final SupabaseConnectOutcome got = _engineFor(
            row['reason_code'] as String?,
          );
          expect(got.level.wire, row['level']);
          expect(got.headline, row['headline']);
          expect(got.reasonCode, row['reason_code']);
          expect(got.retryable, row['retryable']);
          expect(row['id'], 'CONNECTION_TEST');
          expect(row['handoff_route'], isNull);
        },
      );
    }

    for (final SupabaseTimeFailure f in <SupabaseTimeFailure>[
      SupabaseTimeFailure.notConfigured,
      SupabaseTimeFailure.badConfig,
      SupabaseTimeFailure.vault,
    ]) {
      test('🔴 금고 실패 ${f.name} = 연결 확인에서 나올 수 없음(StateError)', () {
        expect(() => supabaseTimeOutcome(f), throwsStateError);
      });
    }

    test('통과 = OK · 사유 0 · 재시도 아님', () {
      expect(kSupabaseConnectOk.level, UiLevel.ok);
      expect(kSupabaseConnectOk.reasonCode, isNull);
      expect(kSupabaseConnectOk.retryable, isFalse);
    });
  });

  group('첫 문제 차례', () {
    test('하나라도 비면(null · 빈칸만) = empty', () {
      expect(
        supabaseConnectInputProblem(url: null, key: _pub),
        SupabaseInputProblem.empty,
      );
      expect(
        supabaseConnectInputProblem(url: _url, key: null),
        SupabaseInputProblem.empty,
      );
      expect(
        supabaseConnectInputProblem(url: '  ', key: _pub),
        SupabaseInputProblem.empty,
      );
      expect(
        supabaseConnectInputProblem(url: _url, key: ' '),
        SupabaseInputProblem.empty,
      );
    });

    test('🔴 한 칸이라도 비면 다른 칸이 틀려도 empty(조치 = 둘 다 붙여 넣기)', () {
      expect(
        supabaseConnectInputProblem(
          url: 'https://$_ref.example.com',
          key: null,
        ),
        SupabaseInputProblem.empty,
      );
      expect(
        supabaseConnectInputProblem(url: null, key: _secret),
        SupabaseInputProblem.empty,
      );
    });

    test('주소 문제가 키 문제보다 먼저 · 둘 다 맞으면 null', () {
      expect(
        supabaseConnectInputProblem(
          url: 'https://$_ref.example.com',
          key: _secret,
        ),
        SupabaseInputProblem.notProjectUrl,
      );
      expect(
        supabaseConnectInputProblem(url: _url, key: _secret),
        SupabaseInputProblem.secretKey,
      );
      expect(
        supabaseConnectInputProblem(url: '$_url/', key: ' $_pub '),
        isNull,
      );
    });
  });

  group('연결 확인', () {
    test('🔴 입력 문제 = 망 0 · 금고 0', () async {
      final _Rig r = _Rig((_) async => _ok());
      final SupabaseConnectOutcome o = await checkSupabaseConnection(
        r.time,
        url: _url,
        key: _secret,
      );
      expect(o.reasonCode, SupabaseInputProblem.secretKey.wire);
      expect(r.requests, isEmpty);
      expect(r.vault.calls, isEmpty);
    });

    test('🔴 통과 = 붙여 넣은 값으로 1회(주소 · apikey) · 금고를 읽지도 쓰지도 않는다', () async {
      final _Rig r = _Rig((_) async => _ok());
      final SupabaseConnectOutcome o = await checkSupabaseConnection(
        r.time,
        url: '$_url/',
        key: ' $_pub ',
      );
      expect(o, kSupabaseConnectOk);
      expect(r.requests, hasLength(1));
      expect(r.requests.single.url.toString(), '$_url/auth/v1/health');
      expect(r.requests.single.headers['apikey'], _pub);
      expect(r.vault.calls, isEmpty);
    });

    test('망 실패 = 그 결과(401 = 키 거절 · 503 = 서버 · 끊김 = 망)', () async {
      Future<String?> code(
        Future<http.Response> Function(http.Request) f,
      ) async => (await checkSupabaseConnection(
        _Rig(f).time,
        url: _url,
        key: _pub,
      )).reasonCode;
      expect(await code((_) async => _ok(code: 401)), 'SUPABASE_UNAUTHORIZED');
      expect(await code((_) async => _ok(code: 503)), 'SUPABASE_SERVER_ERROR');
      expect(
        await code((_) async => throw http.ClientException('끊김')),
        'SUPABASE_NETWORK',
      );
    });

    test('probe — 꼴 아님 = 망 0 · badConfig', () async {
      final _Rig r = _Rig((_) async => _ok());
      expect(
        (await r.time.probe('https://$_ref.example.com', _pub)).failure,
        SupabaseTimeFailure.badConfig,
      );
      expect(
        (await r.time.probe(_url, _secret)).failure,
        SupabaseTimeFailure.badConfig,
      );
      expect(r.requests, isEmpty);
    });
  });

  group('금고 저장', () {
    test('바탕 주소(끝 / 없음) · 키 앞뒤 빈칸 뗌 → 금고 두 칸', () async {
      final MemorySecretVault v = MemorySecretVault();
      await storeSupabaseConnection(v, url: ' $_url/ ', key: ' $_pub ');
      expect(v.peek('supabase.project_url'), _url);
      expect(v.peek('supabase.publishable_key'), _pub);
    });

    test('🔴 꼴 아님 = ArgumentError · 금고 쓰기 0 · 오류 글에 값 0', () async {
      for (final (String u, String k) in <(String, String)>[
        ('https://$_ref.example.com', _pub),
        (_url, _secret),
      ]) {
        final MemorySecretVault v = MemorySecretVault();
        Object? err;
        try {
          await storeSupabaseConnection(v, url: u, key: k);
        } on ArgumentError catch (e) {
          err = e;
        }
        expect(err, isA<ArgumentError>());
        expect(err.toString(), isNot(contains(_ref)));
        expect(err.toString(), isNot(contains(_secret)));
        expect(v.calls, isEmpty);
      }
    });

    test('저장한 값으로 금고 읽기 = 시각', () async {
      final _Rig r = _Rig((_) async => _ok());
      await storeSupabaseConnection(r.vault, url: _url, key: _pub);
      expect(
        (await r.time.read()).serverUtc,
        DateTime.utc(2026, 12, 8, 0, 0, 7),
      );
    });
  });
}
