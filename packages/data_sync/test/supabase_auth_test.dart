// E11k-d1 — Supabase Auth 어댑터(설계 13 §8 R209 · R197 T8) — `MockClient` 로 주소 · 방법 · 머리 · 본문 · 응답 코드를 본다.
//
// 🔵 잡는 것: ① 로그인 = `token?grant_type=password` · apikey · 본문(이메일 앞뒤 빈칸 뗌) · 🔴 비밀번호 쥐지 않음 · 새로고침 토큰 = 금고
//    ② 꼴 · 연결 칸 문제 = 망 0 ③ 코드별 종류(400 = 틀림 · 401 = 키 · 429 · 5xx · 망 · 꼴) ④ 기동 뒤 = 금고 토큰으로 새로고침 · 🔴 회전
//    ⑤ 만료 5분 전 경계 · 강제 새로고침 ⑥ 🔴 겹친 새로고침 = 한 번 ⑦ 새로고침 400 = 세션 잃음 · 금고 칸 지움 · 401 · 망 = 그대로
//    ⑧ 🔴 회전 금고 쓰기 실패 = 메모리 세션은 새것 ⑨ 로그아웃 = local · global · 결과와 무관하게 금고 · 메모리 지움 · 기동 뒤 = 새로고침 먼저
//    ⑩ 🔴 결과 문자열에 이메일 · 비밀번호 · 토큰 · 주소 · 키 0.
// 🔴 시험 값은 이어 붙여 만든다(저장소에 키 · 토큰 꼴 리터럴 0 · 실 Supabase 호출 0).

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
const String _email = 'owner@example.com';
final String _password = 'pw-${'Z' * 16}';
const String _uid = '0f8fad5b-d9cb-469f-a165-70867728950e';
String _access(int n) => 'acc-${'A' * 10}-$n';
String _refresh(int n) => 'ref-${'R' * 10}-$n';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

http.Response _tokens(int n, {int expiresIn = 3600}) => http.Response(
  jsonEncode(<String, Object?>{
    'access_token': _access(n),
    'token_type': 'bearer',
    'expires_in': expiresIn,
    'refresh_token': _refresh(n),
    'user': <String, Object?>{'id': _uid, 'email': _email},
  }),
  200,
  headers: <String, String>{'content-type': 'application/json'},
);

class _Rig {
  _Rig({Map<String, String>? vault, this.respond})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
            },
      );

  final MemorySecretVault vault;
  Future<http.Response> Function(http.Request r, int i)? respond;
  final List<http.Request> requests = <http.Request>[];
  final _Clock clock = _Clock(DateTime.utc(2026, 12, 8, 9));
  Completer<void>? hold;

  late final SupabaseAuth auth = SupabaseAuth(
    MockClient((http.Request r) async {
      requests.add(r);
      final Completer<void>? h = hold;
      if (h != null) await h.future;
      return respond!(r, requests.length - 1);
    }),
    vault,
    clock: clock,
    timeout: const Duration(milliseconds: 200),
  );

  Map<String, Object?> body(int i) =>
      jsonDecode(requests[i].body) as Map<String, Object?>;
}

void main() {
  group('로그인', () {
    test(
      '🔴 token?grant_type=password · apikey · 본문 · 새로고침 토큰 = 금고 · 접근 토큰 = 메모리',
      () async {
        final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
        final SupabaseAuthResult res = await r.auth.signIn(
          email: '  $_email ',
          password: _password,
        );
        expect(res.ok, isTrue);
        expect(res.userId, _uid);
        expect(r.auth.userId, _uid);
        final http.Request q = r.requests.single;
        expect(q.method, 'POST');
        expect(q.url.toString(), '$_url/auth/v1/token?grant_type=password');
        expect(q.headers['apikey'], _pub);
        expect(q.headers.containsKey('authorization'), isFalse);
        expect(r.body(0), <String, Object?>{
          'email': _email,
          'password': _password,
        });
        expect(r.vault.peek('supabase.refresh_token'), _refresh(1));
        expect(await r.auth.accessToken(), _access(1));
        expect(r.requests, hasLength(1), reason: '만료 전 = 망 0');
        expect(await r.auth.hasSession(), isTrue);
      },
    );

    for (final (String name, String email, String pw)
        in <(String, String, String)>[
          ('이메일 꼴 아님', 'owner', 'pw'),
          ('이메일 빈칸 섞임', 'own er@example.com', 'pw'),
          ('비밀번호 빔', _email, ''),
        ]) {
      test('$name = badInput · 망 0 · 금고 쓰기 0', () async {
        final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
        final SupabaseAuthResult res = await r.auth.signIn(
          email: email,
          password: pw,
        );
        expect(res.failure, SupabaseAuthFailure.badInput);
        expect(r.requests, isEmpty);
        expect(
          r.vault.calls.where((String c) => c.startsWith('write')),
          isEmpty,
        );
      });
    }

    for (final (String name, Map<String, String> v, SupabaseAuthFailure f)
        in <(String, Map<String, String>, SupabaseAuthFailure)>[
          ('연결 칸 없음', <String, String>{}, SupabaseAuthFailure.notConfigured),
          (
            '🔴 남의 호스트',
            <String, String>{
              'supabase.project_url': 'https://$_ref.example.com',
              'supabase.publishable_key': _pub,
            },
            SupabaseAuthFailure.badConfig,
          ),
        ]) {
      test('$name = ${f.name} · 망 0', () async {
        final _Rig r = _Rig(vault: v, respond: (_, _) async => _tokens(1));
        expect(
          (await r.auth.signIn(email: _email, password: _password)).failure,
          f,
        );
        expect(r.requests, isEmpty);
      });
    }

    test('금고 읽기 실패 = vault · 망 0', () async {
      final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
      r.vault.failReadsOf.add('supabase.project_url');
      expect(
        (await r.auth.signIn(email: _email, password: _password)).failure,
        SupabaseAuthFailure.vault,
      );
      expect(r.requests, isEmpty);
    });

    for (final (Object reply, SupabaseAuthFailure f, int? code)
        in <(Object, SupabaseAuthFailure, int?)>[
          (400, SupabaseAuthFailure.invalidCredentials, 400),
          (401, SupabaseAuthFailure.unauthorized, 401),
          (403, SupabaseAuthFailure.unauthorized, 403),
          (429, SupabaseAuthFailure.rateLimited, 429),
          (503, SupabaseAuthFailure.server, 503),
          (302, SupabaseAuthFailure.badResponse, 302),
          ('끊김', SupabaseAuthFailure.network, null),
          ('{"access_token":"x"}', SupabaseAuthFailure.badResponse, 200),
          ('not json', SupabaseAuthFailure.badResponse, 200),
        ]) {
      test('🔴 응답 $reply = ${f.name} · 금고 쓰기 0 · 세션 0', () async {
        final _Rig r = _Rig(
          respond: (_, _) async {
            if (reply is int) return http.Response('{"error":"x"}', reply);
            if (reply == '끊김') throw http.ClientException('끊김');
            return http.Response(reply as String, 200);
          },
        );
        final SupabaseAuthResult res = await r.auth.signIn(
          email: _email,
          password: _password,
        );
        expect(res.failure, f);
        expect(res.statusCode, code);
        expect(r.vault.peek('supabase.refresh_token'), isNull);
        expect(r.auth.userId, isNull);
      });
    }
  });

  group('새로고침 · 회전', () {
    test('로그인 전(금고 토큰 없음) = notSignedIn · 접근 토큰 null · 망 0', () async {
      final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
      expect(await r.auth.accessToken(), isNull);
      expect((await r.auth.refresh()).failure, SupabaseAuthFailure.notSignedIn);
      expect(await r.auth.hasSession(), isFalse);
      expect(r.requests, isEmpty);
    });

    test('🔴 기동 뒤 = 금고 토큰으로 새로고침 → 새 토큰을 금고에(회전) → 새 접근 토큰', () async {
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
          'supabase.refresh_token': _refresh(1),
        },
        respond: (_, _) async => _tokens(2),
      );
      expect(await r.auth.accessToken(), _access(2));
      final http.Request q = r.requests.single;
      expect(q.url.toString(), '$_url/auth/v1/token?grant_type=refresh_token');
      expect(q.headers['apikey'], _pub);
      expect(r.body(0), <String, Object?>{'refresh_token': _refresh(1)});
      expect(r.vault.peek('supabase.refresh_token'), _refresh(2));
      expect(r.auth.userId, _uid);
    });

    test('🔴 만료 5분 전 경계 — 5분 넘게 남음 = 그대로 · 5분 = 새로고침 · 강제 = 새로고침', () async {
      int n = 1;
      final _Rig r = _Rig(respond: (_, _) async => _tokens(n++));
      await r.auth.signIn(email: _email, password: _password);
      final DateTime t0 = r.clock.now;
      r.clock.now = t0.add(
        const Duration(minutes: 55) - const Duration(seconds: 1),
      );
      expect(await r.auth.accessToken(), _access(1));
      expect(r.requests, hasLength(1));
      r.clock.now = t0.add(const Duration(minutes: 55));
      expect(await r.auth.accessToken(), _access(2));
      expect(r.requests, hasLength(2));
      expect(await r.auth.accessToken(forceRefresh: true), _access(3));
      expect(r.vault.peek('supabase.refresh_token'), _refresh(3));
    });

    test('🔴 겹친 새로고침 = 한 번만 날린다(같은 토큰 두 번 = 서버 재사용 감지)', () async {
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
          'supabase.refresh_token': _refresh(1),
        },
        respond: (_, _) async => _tokens(2),
      );
      r.hold = Completer<void>();
      final Future<String?> a = r.auth.accessToken();
      final Future<SupabaseAuthResult> b = r.auth.refresh();
      final Future<String?> c = r.auth.accessToken(forceRefresh: true);
      await Future<void>.delayed(Duration.zero);
      r.hold!.complete();
      expect(await a, _access(2));
      expect((await b).ok, isTrue);
      expect(await c, _access(2));
      expect(r.requests, hasLength(1));
    });

    test('🔴 금고 토큰이 사라졌으면(밖에서 지움) 새로고침 = notSignedIn · 메모리 세션도 버린다', () async {
      final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
      await r.auth.signIn(email: _email, password: _password);
      await r.vault.delete(SupabaseSecretIds.refreshToken);
      expect(await r.auth.accessToken(forceRefresh: true), isNull);
      expect(r.auth.userId, isNull);
      expect(await r.auth.accessToken(), isNull);
      expect(r.requests, hasLength(1));
    });

    test('🔴 새로고침 400 = 세션 잃음 · 금고 칸 지움 · 접근 토큰 null', () async {
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
          'supabase.refresh_token': _refresh(1),
        },
        respond: (_, _) async => http.Response('{"error":"x"}', 400),
      );
      final SupabaseAuthResult res = await r.auth.refresh();
      expect(res.failure, SupabaseAuthFailure.sessionLost);
      expect(res.statusCode, 400);
      expect(r.vault.peek('supabase.refresh_token'), isNull);
      expect(await r.auth.hasSession(), isFalse);
      expect(await r.auth.accessToken(), isNull);
      expect(r.auth.userId, isNull);
    });

    for (final (Object reply, SupabaseAuthFailure f)
        in <(Object, SupabaseAuthFailure)>[
          (401, SupabaseAuthFailure.unauthorized),
          (503, SupabaseAuthFailure.server),
          ('끊김', SupabaseAuthFailure.network),
        ]) {
      test('새로고침 $reply = ${f.name} · 금고 토큰 그대로(다시 시도할 수 있다)', () async {
        final _Rig r = _Rig(
          vault: <String, String>{
            'supabase.project_url': _url,
            'supabase.publishable_key': _pub,
            'supabase.refresh_token': _refresh(1),
          },
          respond: (_, _) async {
            if (reply is int) return http.Response('', reply);
            throw http.ClientException('끊김');
          },
        );
        expect((await r.auth.refresh()).failure, f);
        expect(r.vault.peek('supabase.refresh_token'), _refresh(1));
        expect(await r.auth.accessToken(), isNull);
      });
    }

    test('🔴 회전 금고 쓰기 실패 = vault 실패 · 메모리 세션은 새것(다음 기동 = 다시 로그인)', () async {
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
          'supabase.refresh_token': _refresh(1),
        },
        respond: (_, _) async => _tokens(2),
      );
      r.vault.failWritesTo.add('supabase.refresh_token');
      expect(await r.auth.accessToken(), _access(2));
      expect(r.vault.peek('supabase.refresh_token'), _refresh(1));
      r.vault.failWritesTo.clear();
      expect((await r.auth.refresh()).failure, isNull);
    });
  });

  group('로그아웃', () {
    test('🔴 이 기기 = logout?scope=local · Bearer 접근 토큰 · 금고 · 메모리 지움', () async {
      final _Rig r = _Rig(
        respond: (http.Request q, int i) async =>
            i == 0 ? _tokens(1) : http.Response('', 204),
      );
      await r.auth.signIn(email: _email, password: _password);
      final SupabaseAuthResult res = await r.auth.signOut();
      expect(res.ok, isTrue);
      final http.Request q = r.requests[1];
      expect(q.method, 'POST');
      expect(q.url.toString(), '$_url/auth/v1/logout?scope=local');
      expect(q.headers['authorization'], 'Bearer ${_access(1)}');
      expect(q.headers['apikey'], _pub);
      expect(r.vault.peek('supabase.refresh_token'), isNull);
      expect(r.auth.userId, isNull);
      expect(await r.auth.accessToken(), isNull);
    });

    test('모든 기기(재발급 «원격 세션 철회») = scope=global', () async {
      final _Rig r = _Rig(
        respond: (http.Request q, int i) async =>
            i == 0 ? _tokens(1) : http.Response('', 204),
      );
      await r.auth.signIn(email: _email, password: _password);
      expect((await r.auth.signOut(everywhere: true)).ok, isTrue);
      expect(r.requests[1].url.queryParameters['scope'], 'global');
    });

    test('🔴 서버 실패여도 이 기기는 로그아웃(금고 · 메모리 지움) · 결과 = 실패 종류', () async {
      final _Rig r = _Rig(
        respond: (http.Request q, int i) async =>
            i == 0 ? _tokens(1) : http.Response('', 503),
      );
      await r.auth.signIn(email: _email, password: _password);
      final SupabaseAuthResult res = await r.auth.signOut(everywhere: true);
      expect(res.failure, SupabaseAuthFailure.server);
      expect(r.vault.peek('supabase.refresh_token'), isNull);
      expect(r.auth.userId, isNull);
    });

    test('기동 뒤(메모리 세션 없음) = 새로고침 먼저 → 새 접근 토큰으로 로그아웃', () async {
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
          'supabase.refresh_token': _refresh(1),
        },
        respond: (http.Request q, int i) async =>
            i == 0 ? _tokens(2) : http.Response('', 204),
      );
      expect((await r.auth.signOut()).ok, isTrue);
      expect(r.requests, hasLength(2));
      expect(r.requests[1].headers['authorization'], 'Bearer ${_access(2)}');
      expect(r.vault.peek('supabase.refresh_token'), isNull);
    });

    test('로그인한 적 없음 = notSignedIn · 망 0', () async {
      final _Rig r = _Rig(respond: (_, _) async => _tokens(1));
      expect((await r.auth.signOut()).failure, SupabaseAuthFailure.notSignedIn);
      expect(r.requests, isEmpty);
    });
  });

  test('🔴 결과 문자열에 이메일 · 비밀번호 · 토큰 · 주소 · 키 0', () async {
    final _Rig r = _Rig(
      respond: (http.Request q, int i) async => switch (i) {
        0 => _tokens(1),
        1 => http.Response('', 400),
        _ => throw http.ClientException('$_url $_password'),
      },
    );
    final List<SupabaseAuthResult> rs = <SupabaseAuthResult>[
      await r.auth.signIn(email: _email, password: _password),
      await r.auth.signIn(email: _email, password: _password),
      await r.auth.signIn(email: _email, password: _password),
    ];
    for (final SupabaseAuthResult x in rs) {
      final String s = x.toString();
      for (final String secret in <String>[
        _email,
        _password,
        _access(1),
        _refresh(1),
        _ref,
        _pub,
        _uid,
      ]) {
        expect(s, isNot(contains(secret)));
      }
    }
    expect(rs.map((SupabaseAuthResult x) => x.toString()), <String>[
      'SupabaseAuthResult(ok)',
      'SupabaseAuthResult(invalidCredentials · HTTP 400)',
      'SupabaseAuthResult(network)',
    ]);
  });
}
