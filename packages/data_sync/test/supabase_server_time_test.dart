// E11k-a — Supabase 서버 시각 어댑터(설계 13 §8 R197 T1 · T5 · T6) — `MockClient` 로 주소 · 머리 · 응답 코드 · `Date` 를 본다.
//
// 🔵 잡는 것: ① 주소 = `https://<ref>.supabase.co` 꼴만(남의 호스트 · http · 대문자 · 경로 = 거부) ② 공개 키 = publishable ·
//    anon JWT 만 · 🔴 비밀 키 · service_role JWT 는 따로 짚는다 ③ 금고 값 없음 · 꼴 아님 = 망에 가지 않는다
//    ④ `GET /auth/v1/health` · `apikey` 머리만(로그인 머리 0) ⑤ 2xx + `Date` 만 성공 · 코드별 종류 · 망 · 시간 초과
//    ⑥ 🔴 결과 문자열에 주소 · 키 0 ⑦ core `AnchoredTrustedClock` 원천으로 끼우면 신뢰 시각이 선다.
// 🔴 시험 주소 · 키는 이어 붙여 만든다(저장소에 키 꼴 리터럴 0 · 실 Supabase 호출 0).

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
final String _secret = 'sb_${'secret'}_${'K' * 12}${'4' * 10}';

String _jwt(Map<String, Object?> payload) {
  String seg(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg(<String, String>{'alg': 'HS256', 'typ': 'JWT'})}.'
      '${seg(payload)}.${'s' * 20}';
}

const String _date = 'Tue, 08 Dec 2026 00:00:07 GMT';
final DateTime _dateUtc = DateTime.utc(2026, 12, 8, 0, 0, 7);

class _Rig {
  _Rig(this.respond, {Map<String, String>? vault})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
            },
      );

  final Future<http.Response> Function(http.Request r) respond;
  final MemorySecretVault vault;
  final List<http.Request> requests = <http.Request>[];

  late final SupabaseServerTime time = SupabaseServerTime(
    MockClient((http.Request r) async {
      requests.add(r);
      return respond(r);
    }),
    vault,
    timeout: const Duration(milliseconds: 200),
  );
}

http.Response _ok({String? date = _date, int code = 200}) => http.Response(
  '{"name":"GoTrue"}',
  code,
  headers: <String, String>{
    'content-type': 'application/json',
    if (date != null) 'date': date,
  },
);

void main() {
  group('입력 판정 — 주소', () {
    test('꼴 맞음(끝 / 있어도) = null · 바탕 주소는 끝 / 없음', () {
      expect(supabaseProjectUrlProblem(_url), isNull);
      expect(supabaseProjectUrlProblem('  $_url/ '), isNull);
      expect(supabaseProjectUri('$_url/').toString(), _url);
      expect(supabaseProjectUri(_url).toString(), _url);
    });

    for (final (String name, String v, SupabaseInputProblem p)
        in <(String, String, SupabaseInputProblem)>[
          ('빈칸', '   ', SupabaseInputProblem.empty),
          (
            '가운데 빈칸',
            'https://$_ref .supabase.co',
            SupabaseInputProblem.whitespace,
          ),
          (
            'http',
            'http://$_ref.supabase.co',
            SupabaseInputProblem.notProjectUrl,
          ),
          (
            '대문자',
            'https://${_ref.toUpperCase()}.supabase.co',
            SupabaseInputProblem.notProjectUrl,
          ),
          (
            '다른 호스트',
            'https://$_ref.example.com',
            SupabaseInputProblem.notProjectUrl,
          ),
          (
            '꼬리 호스트',
            'https://$_ref.supabase.co.example.com',
            SupabaseInputProblem.notProjectUrl,
          ),
          ('경로', '$_url/rest/v1', SupabaseInputProblem.notProjectUrl),
          ('ref 만', _ref, SupabaseInputProblem.notProjectUrl),
          (
            'ref 짧음',
            'https://${'q' * 15}.supabase.co',
            SupabaseInputProblem.notProjectUrl,
          ),
        ]) {
      test('$name = ${p.name} · 바탕 주소 없음', () {
        expect(supabaseProjectUrlProblem(v), p);
        expect(supabaseProjectUri(v), isNull);
      });
    }
  });

  group('입력 판정 — 공개 키', () {
    test('publishable · anon JWT = null', () {
      expect(supabasePublishableKeyProblem(_pub), isNull);
      expect(
        supabasePublishableKeyProblem(_jwt(<String, Object?>{'role': 'anon'})),
        isNull,
      );
    });

    for (final (String name, String Function() v, SupabaseInputProblem p)
        in <(String, String Function(), SupabaseInputProblem)>[
          ('빈칸', () => '', SupabaseInputProblem.empty),
          (
            '가운데 줄바꿈',
            () => '${_pub.substring(0, 12)}\n${_pub.substring(12)}',
            SupabaseInputProblem.whitespace,
          ),
          ('🔴 비밀 키', () => _secret, SupabaseInputProblem.secretKey),
          (
            '🔴 service_role JWT',
            () => _jwt(<String, Object?>{'role': 'service_role'}),
            SupabaseInputProblem.serviceRoleKey,
          ),
          (
            'role 없는 JWT',
            () => _jwt(<String, Object?>{'sub': 'x'}),
            SupabaseInputProblem.notPublishableKey,
          ),
          (
            '조각 둘 JWT',
            () => 'eyJ${'a' * 10}.${'b' * 10}',
            SupabaseInputProblem.notPublishableKey,
          ),
          (
            '깨진 JWT',
            () => 'eyJ${'a' * 10}.%%%.${'b' * 10}',
            SupabaseInputProblem.notPublishableKey,
          ),
          (
            'publishable 짧음',
            () => 'sb_${'publishable'}_abc',
            SupabaseInputProblem.notPublishableKey,
          ),
          ('KIS 앱키 꼴', () => 'P' * 36, SupabaseInputProblem.notPublishableKey),
        ]) {
      test('$name = ${p.name}', () {
        expect(supabasePublishableKeyProblem(v()), p);
      });
    }

    test('앞뒤 빈칸은 떼고 본다', () {
      expect(supabasePublishableKeyProblem('  $_pub  '), isNull);
    });
  });

  group('서버 시각 읽기', () {
    test(
      '🔴 GET <주소>/auth/v1/health · apikey 머리만 · 2xx + Date = 성공(UTC)',
      () async {
        final _Rig r = _Rig((_) async => _ok());
        final SupabaseTimeRead read = await r.time.read();
        expect(read.failure, isNull);
        expect(read.serverUtc, _dateUtc);
        expect(read.serverUtc!.isUtc, isTrue);
        expect(r.requests, hasLength(1));
        final http.Request q = r.requests.single;
        expect(q.method, 'GET');
        expect(q.url.toString(), '$_url/auth/v1/health');
        expect(q.headers['apikey'], _pub);
        expect(q.headers.containsKey('authorization'), isFalse);
        expect(await r.time.serverTimeUtc(), _dateUtc);
      },
    );

    test('금고 값 끝 / · 앞뒤 빈칸이어도 같은 주소', () async {
      final _Rig r = _Rig(
        (_) async => _ok(),
        vault: <String, String>{
          'supabase.project_url': '$_url/',
          'supabase.publishable_key': ' $_pub ',
        },
      );
      expect((await r.time.read()).serverUtc, _dateUtc);
      expect(r.requests.single.url.toString(), '$_url/auth/v1/health');
      expect(r.requests.single.headers['apikey'], _pub);
    });

    for (final (String name, Map<String, String> v, SupabaseTimeFailure f)
        in <(String, Map<String, String>, SupabaseTimeFailure)>[
          ('둘 다 없음', <String, String>{}, SupabaseTimeFailure.notConfigured),
          (
            '키 없음',
            <String, String>{'supabase.project_url': _url},
            SupabaseTimeFailure.notConfigured,
          ),
          (
            '주소 빈 값',
            <String, String>{
              'supabase.project_url': '',
              'supabase.publishable_key': _pub,
            },
            SupabaseTimeFailure.notConfigured,
          ),
          (
            '🔴 남의 호스트',
            <String, String>{
              'supabase.project_url': 'https://$_ref.example.com',
              'supabase.publishable_key': _pub,
            },
            SupabaseTimeFailure.badConfig,
          ),
          (
            '🔴 비밀 키',
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _secret,
            },
            SupabaseTimeFailure.badConfig,
          ),
        ]) {
      test('$name = ${f.name} · 🔴 망에 가지 않는다', () async {
        final _Rig r = _Rig((_) async => _ok(), vault: v);
        final SupabaseTimeRead read = await r.time.read();
        expect(read.failure, f);
        expect(read.serverUtc, isNull);
        expect(r.requests, isEmpty);
      });
    }

    test('금고 읽기 실패 = vault · 망 0', () async {
      final _Rig r = _Rig((_) async => _ok());
      r.vault.failReadsOf.add('supabase.publishable_key');
      expect((await r.time.read()).failure, SupabaseTimeFailure.vault);
      expect(r.requests, isEmpty);
    });

    for (final (int code, SupabaseTimeFailure f)
        in <(int, SupabaseTimeFailure)>[
          (401, SupabaseTimeFailure.unauthorized),
          (403, SupabaseTimeFailure.unauthorized),
          (404, SupabaseTimeFailure.badResponse),
          (429, SupabaseTimeFailure.badResponse),
          (500, SupabaseTimeFailure.server),
          (503, SupabaseTimeFailure.server),
          (199, SupabaseTimeFailure.badResponse),
          (300, SupabaseTimeFailure.badResponse),
        ]) {
      test('🔴 HTTP $code = ${f.name} · Date 가 있어도 시각을 쓰지 않는다', () async {
        final _Rig r = _Rig((_) async => _ok(code: code));
        final SupabaseTimeRead read = await r.time.read();
        expect(read.failure, f);
        expect(read.statusCode, code);
        expect(read.serverUtc, isNull);
      });
    }

    test('2xx 경계 — 204 = 성공', () async {
      final _Rig r = _Rig((_) async => _ok(code: 204));
      expect((await r.time.read()).serverUtc, _dateUtc);
    });

    for (final (String name, String? date) in <(String, String?)>[
      ('Date 없음', null),
      ('Date 꼴 아님', 'yesterday'),
    ]) {
      test('$name = noDate', () async {
        final _Rig r = _Rig((_) async => _ok(date: date));
        final SupabaseTimeRead read = await r.time.read();
        expect(read.failure, SupabaseTimeFailure.noDate);
        expect(read.statusCode, 200);
        expect(read.serverUtc, isNull);
      });
    }

    test('망 실패 · 시간 초과 = network(던지지 않는다)', () async {
      final _Rig down = _Rig((_) async => throw http.ClientException('끊김'));
      expect((await down.time.read()).failure, SupabaseTimeFailure.network);
      final _Rig slow = _Rig((_) => Completer<http.Response>().future);
      expect((await slow.time.read()).failure, SupabaseTimeFailure.network);
      expect(await slow.time.serverTimeUtc(), isNull);
    });

    test('🔴 결과 문자열에 주소 · ref · 키 0', () async {
      final List<SupabaseTimeRead> reads = <SupabaseTimeRead>[
        await _Rig((_) async => _ok()).time.read(),
        await _Rig((_) async => _ok(code: 401)).time.read(),
        await _Rig((_) async => throw http.ClientException(_url)).time.read(),
        await _Rig(
          (_) async => _ok(),
          vault: <String, String>{
            'supabase.project_url': 'https://$_ref.example.com',
            'supabase.publishable_key': _pub,
          },
        ).time.read(),
      ];
      for (final SupabaseTimeRead x in reads) {
        final String s = x.toString();
        expect(s, isNot(contains(_ref)));
        expect(s, isNot(contains(_pub)));
        expect(s, isNot(contains('supabase.co')));
      }
      expect(reads[1].toString(), 'SupabaseTimeRead(unauthorized · HTTP 401)');
      expect(reads[0].toString(), 'SupabaseTimeRead(ok)');
    });
  });

  group('core 신뢰 시각에 끼우기', () {
    test('갱신 → 서버 Date 가 신뢰 시각 · 연결 전 = 모름', () async {
      Duration mono = Duration.zero;
      final _Wall wall = _Wall(DateTime.utc(2026, 12, 8, 0, 9));
      final _Rig r = _Rig((_) async {
        mono += const Duration(milliseconds: 250);
        return _ok();
      });
      final AnchoredTrustedClock c = AnchoredTrustedClock(
        source: r.time,
        wall: wall,
        monotonic: () => mono,
      );
      expect(c.trustedNowUtc(), isNull);
      expect(await c.refresh(), isTrue);
      expect(c.trustedNowUtc(), _dateUtc);

      final _Rig none = _Rig((_) async => _ok(), vault: <String, String>{});
      final AnchoredTrustedClock n = AnchoredTrustedClock(
        source: none.time,
        wall: wall,
        monotonic: () => mono,
      );
      expect(await n.refresh(), isFalse);
      expect(n.trustedNowUtc(), isNull);
      expect(none.requests, isEmpty);
    });
  });
}

class _Wall implements Clock {
  _Wall(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}
