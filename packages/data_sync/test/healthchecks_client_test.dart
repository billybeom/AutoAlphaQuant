// healthchecks 어댑터(설계 13 §8 R45 C2~C6) — `MockClient` 로 URL · 방법 · rid · 본문 · 키 머리 · 응답 코드를 본다.
//
// 🔵 잡는 것: ① 슬러그 핑 꼴 · `rid`(UUID 일 때만) · 🔴 `create` 없음 ② 200 만 성공 · 코드별 종류 · 재시도(망 · 429 · 5xx 만)
//    ③ 키는 부를 때마다 금고에서 · 없으면 망에 안 간다 ④ 체크 읽기 = 🔴 uuid 를 담지 않는다 ⑤ pause · resume = 그때 다시
//    찾는다 · 엔진 생존 체크 거절 · 읽기 전용 키 ⑥ 🔴 오류 · 문자열에 핑 키 · API 키 · uuid · 주소 0.
// 🔴 시험 키 · uuid 는 이어 붙여 만든다(저장소에 키 꼴 리터럴 0).

import 'dart:async';
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _pingKey = 'pk${'Q' * 10}${'7' * 10}';
final String _apiKey = 'ak${'R' * 15}${'3' * 15}';
final String _uuid =
    '${'a' * 8}-${'b' * 4}-4${'c' * 3}-8${'d' * 3}-${'e' * 12}';
const String _slug = 'live-auto-daily_data';
const String _rid = '0f1e2d3c-4b5a-4968-8778-6a5b4c3d2e1f';

class _Rig {
  _Rig(this.respond, {MemorySecretVault? vault})
    : vault =
          vault ??
          MemorySecretVault(<String, String>{
            'healthchecks.ping_key': _pingKey,
            'healthchecks.api_key': _apiKey,
          });

  final Future<http.Response> Function(http.Request r, int i) respond;
  final MemorySecretVault vault;
  final List<http.Request> requests = <http.Request>[];
  final List<Duration> slept = <Duration>[];

  late final HealthchecksClient client = HealthchecksClient(
    MockClient((http.Request r) async {
      requests.add(r);
      return respond(r, requests.length - 1);
    }),
    vault,
    timeout: const Duration(milliseconds: 200),
    sleep: (Duration d) async => slept.add(d),
  );
}

http.Response _ok([String body = 'OK']) => http.Response(body, 200);

http.Response _json(Object body, [int code = 200]) => http.Response(
  jsonEncode(body),
  code,
  headers: <String, String>{'content-type': 'application/json'},
);

Map<String, Object?> _row(
  String slug, {
  String status = 'up',
  bool withUuid = true,
  Object? lastPing = '2026-11-04T00:12:03+00:00',
}) => <String, Object?>{
  'name': slug,
  'slug': slug,
  'tags': 'live',
  'grace': 1800,
  'n_pings': 3,
  'status': status,
  'started': false,
  'last_ping': lastPing,
  'next_ping': '2026-11-05T00:10:00+00:00',
  if (withUuid) 'uuid': _uuid,
  if (withUuid) 'ping_url': 'https://hc-ping.com/$_uuid',
  if (!withUuid) 'unique_key': 'f' * 40,
};

/// 🔴 문자열에 비밀이 없다.
void _clean(Object e) {
  final String s = '$e';
  for (final String bad in <String>[
    _pingKey,
    _apiKey,
    _uuid,
    'hc-ping',
    'http',
  ]) {
    expect(s.contains(bad), isFalse, reason: '$bad in $s');
  }
}

Future<HealthchecksError> _fails(Future<Object?> f) async {
  try {
    await f;
  } on HealthchecksError catch (e) {
    _clean(e);
    return e;
  }
  fail('HealthchecksError 를 기대했다');
}

void main() {
  group('핑(R45 C2 · C3)', () {
    test('성공 = 꼬리 없음 · start · fail = 꼬리 · POST · rid = UUID · 🔴 create 없음 · 본문 = 메모', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _ok());
      await rig.client.ping(_slug, PingStatus.start, rid: _rid);
      await rig.client.ping(_slug, PingStatus.success, note: '휴장', rid: _rid);
      await rig.client.ping(_slug, PingStatus.fail, note: '본체 예외', rid: _rid);
      expect(rig.requests.map((http.Request r) => r.method).toSet(), <String>{
        'POST',
      });
      expect(rig.requests.map((http.Request r) => r.url.toString()), <String>[
        'https://hc-ping.com/$_pingKey/$_slug/start?rid=$_rid',
        'https://hc-ping.com/$_pingKey/$_slug?rid=$_rid',
        'https://hc-ping.com/$_pingKey/$_slug/fail?rid=$_rid',
      ]);
      expect(rig.requests.map((http.Request r) => r.body), <String>[
        '',
        '휴장',
        '본체 예외',
      ]);
      for (final http.Request r in rig.requests) {
        expect(r.url.queryParameters.containsKey('create'), isFalse);
        expect(r.headers.containsKey('X-Api-Key'), isFalse);
        expect(r.headers['content-type'], startsWith('text/plain'));
      }
      expect(rig.slept, isEmpty);
    });

    test(
      'rid 가 UUID 꼴이 아니면 빼고 보낸다 · 대문자 UUID 는 소문자로 · rid 없음 = 쿼리 없음',
      () async {
        final _Rig rig = _Rig((http.Request r, int i) async => _ok());
        await rig.client.ping(_slug, PingStatus.success, rid: 'run-17');
        await rig.client.ping(
          _slug,
          PingStatus.success,
          rid: _rid.toUpperCase(),
        );
        await rig.client.ping(_slug, PingStatus.success);
        expect(rig.requests.map((http.Request r) => r.url.query), <String>[
          '',
          'rid=$_rid',
          '',
        ]);
      },
    );

    test('runJob 의 회차 id(runIdFor 꼴)가 그대로 rid 로 간다', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _ok());
      const String jobRid = '12ab34cd-56ef-4a78-8b90-c1d2e3f4a5b6';
      await rig.client.ping(_slug, PingStatus.start, rid: jobRid);
      expect(rig.requests.single.url.queryParameters['rid'], jobRid);
    });

    test('메모 = 1,000자 상한(…) · 🔴 핑 키 · API 키 값은 <가림>', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _ok());
      await rig.client.ping(_slug, PingStatus.fail, note: 'x' * 1500);
      await rig.client.ping(
        _slug,
        PingStatus.fail,
        note: 'GET https://hc-ping.com/$_pingKey 실패 · key=$_apiKey',
      );
      expect(rig.requests[0].body, '${'x' * 1000}…');
      expect(rig.requests[1].body.contains(_pingKey), isFalse);
      expect(rig.requests[1].body.contains(_apiKey), isFalse);
      expect(rig.requests[1].body, contains(kRedacted));
    });

    test(
      '200 만 성공 — 404 체크 없음 · 409 겹침 · 400 · 401 · 403 = 바로 실패(재시도 0)',
      () async {
        for (final (int code, HealthchecksErrorKind kind)
            in <(int, HealthchecksErrorKind)>[
              (404, HealthchecksErrorKind.unknownCheck),
              (409, HealthchecksErrorKind.ambiguousSlug),
              (400, HealthchecksErrorKind.badRequest),
              (401, HealthchecksErrorKind.unauthorized),
              (403, HealthchecksErrorKind.unauthorized),
              (201, HealthchecksErrorKind.badResponse),
            ]) {
          final _Rig rig = _Rig(
            (http.Request r, int i) async => http.Response('x', code),
          );
          final HealthchecksError e = await _fails(
            rig.client.ping(_slug, PingStatus.success),
          );
          expect((e.kind, e.statusCode, e.attempts), (kind, code, 1));
          expect(rig.requests, hasLength(1), reason: '$code');
          expect(rig.slept, isEmpty);
        }
      },
    );

    test('429 · 5xx · 망 실패 · 시간 초과 = 1 → 2초 기다려 두 번 더 · 끝내 실패면 시도 3', () async {
      for (final (
            Future<http.Response> Function() reply,
            HealthchecksErrorKind kind,
          )
          in <(Future<http.Response> Function(), HealthchecksErrorKind)>[
            (
              () async => http.Response('slow', 429),
              HealthchecksErrorKind.rateLimited,
            ),
            (
              () async => http.Response('down', 503),
              HealthchecksErrorKind.server,
            ),
            (
              () async => throw http.ClientException('연결 끊김 $_pingKey'),
              HealthchecksErrorKind.network,
            ),
            (
              () => Completer<http.Response>().future,
              HealthchecksErrorKind.network,
            ),
          ]) {
        final _Rig rig = _Rig((http.Request r, int i) => reply());
        final HealthchecksError e = await _fails(
          rig.client.ping(_slug, PingStatus.success),
        );
        expect((e.kind, e.attempts), (kind, 3));
        expect(rig.requests, hasLength(3));
        expect(rig.slept, const <Duration>[
          Duration(seconds: 1),
          Duration(seconds: 2),
        ]);
      }
    });

    test('503 뒤 200 = 성공(기다림 1번)', () async {
      final _Rig rig = _Rig(
        (http.Request r, int i) async =>
            i == 0 ? http.Response('down', 503) : _ok(),
      );
      await rig.client.ping(_slug, PingStatus.success);
      expect(rig.requests, hasLength(2));
      expect(rig.slept, const <Duration>[Duration(seconds: 1)]);
    });

    test(
      '슬러그 꼴이 아니면 망에 가기 전 ArgumentError(값 0) · 키 없으면 missingKey(망 0)',
      () async {
        final _Rig rig = _Rig((http.Request r, int i) async => _ok());
        for (final String bad in <String>[
          'Live-auto-x',
          'live/auto',
          '',
          'a' * 101,
          'live auto',
          '../$_pingKey',
        ]) {
          await expectLater(
            rig.client.ping(bad, PingStatus.success),
            throwsA(
              isA<ArgumentError>().having(
                (ArgumentError e) => '$e'.contains(_pingKey),
                '키 없음',
                isFalse,
              ),
            ),
          );
        }
        final _Rig empty = _Rig(
          (http.Request r, int i) async => _ok(),
          vault: MemorySecretVault(),
        );
        final HealthchecksError e = await _fails(
          empty.client.ping(_slug, PingStatus.success),
        );
        expect(e.kind, HealthchecksErrorKind.missingKey);
        final _Rig blank = _Rig(
          (http.Request r, int i) async => _ok(),
          vault: MemorySecretVault(<String, String>{
            'healthchecks.ping_key': '',
          }),
        );
        expect(
          (await _fails(blank.client.ping(_slug, PingStatus.success))).kind,
          HealthchecksErrorKind.missingKey,
        );
        expect(rig.requests, isEmpty);
        expect(empty.requests, isEmpty);
        expect(blank.requests, isEmpty);
      },
    );

    test('🔴 키는 부를 때마다 금고에서 — 회전 뒤 다음 핑이 새 키를 쓴다', () async {
      final _Rig rig = _Rig((http.Request r, int i) async => _ok());
      await rig.client.ping(_slug, PingStatus.success);
      final String fresh = 'pk${'N' * 20}';
      await rig.vault.write(HealthchecksClient.pingKeyId, fresh);
      await rig.client.ping(_slug, PingStatus.success);
      expect(
        rig.requests.map((http.Request r) => r.url.pathSegments.first),
        <String>[_pingKey, fresh],
      );
    });

    test('https 만 · 바탕 경로를 이어 붙인다(자체 호스팅)', () async {
      expect(
        () => HealthchecksClient(
          MockClient((http.Request r) async => _ok()),
          MemorySecretVault(),
          pingBase: Uri.parse('http://hc-ping.com'),
        ),
        throwsArgumentError,
      );
      final List<Uri> seen = <Uri>[];
      final HealthchecksClient c = HealthchecksClient(
        MockClient((http.Request r) async {
          seen.add(r.url);
          return _ok();
        }),
        MemorySecretVault(<String, String>{'healthchecks.ping_key': _pingKey}),
        pingBase: Uri.parse('https://hc.example.test/ping'),
      );
      await c.ping(_slug, PingStatus.start);
      expect(
        seen.single.toString(),
        'https://hc.example.test/ping/$_pingKey/$_slug/start',
      );
      expect('$c', 'HealthchecksClient(hc.example.test · healthchecks.io)');
    });
  });

  group('체크 읽기(R45 C5)', () {
    test(
      'GET /api/v3/checks/ · X-Api-Key · 상태 · 시각(UTC) · 유예 · 🔴 uuid 는 담지 않는다',
      () async {
        final _Rig rig = _Rig(
          (http.Request r, int i) async => _json(<String, Object?>{
            'checks': <Object?>[
              _row(_slug),
              _row('live-auto-daily_signal', status: 'new', lastPing: null),
              _row('live-auto-daily_reconcile', status: 'grace'),
              _row('live-auto-equity_snapshot', status: 'down'),
              _row('live-auto-engine_alive', status: 'paused'),
              _row('live-auto-backup_age', status: 'weird'),
              <String, Object?>{'name': '슬러그 없음', 'status': 'up'},
              <String, Object?>{'name': '빈 슬러그', 'slug': '', 'status': 'up'},
            ],
          }),
        );
        final List<RemoteCheck> cs = await rig.client.checks();
        final http.Request q = rig.requests.single;
        expect(
          (q.method, q.url.toString()),
          ('GET', 'https://healthchecks.io/api/v3/checks/'),
        );
        expect(q.headers['X-Api-Key'], _apiKey);
        expect(cs.map((RemoteCheck c) => c.status), <RemoteCheckStatus>[
          RemoteCheckStatus.up,
          RemoteCheckStatus.fresh,
          RemoteCheckStatus.grace,
          RemoteCheckStatus.down,
          RemoteCheckStatus.paused,
          RemoteCheckStatus.unknown,
        ]);
        final RemoteCheck first = cs.first;
        expect(first.slug, _slug);
        expect(first.lastPingUtc, DateTime.utc(2026, 11, 4, 0, 12, 3));
        expect(first.lastPingUtc!.isUtc, isTrue);
        expect(first.nextPingUtc, DateTime.utc(2026, 11, 5, 0, 10));
        expect(first.grace, const Duration(minutes: 30));
        expect(cs[1].lastPingUtc, isNull);
        for (final RemoteCheck c in cs) {
          _clean(c);
        }
      },
    );

    test('깨진 본문 · checks 가 목록 아님 · 행이 객체 아님 = badResponse · 401 = unauthorized · 키 없음 = missingKey', () async {
      for (final http.Response bad in <http.Response>[
        http.Response('{broken', 200),
        _json(<String, Object?>{'checks': 3}),
        _json(<Object?>[]),
        _json(<String, Object?>{
          'checks': <Object?>['x'],
        }),
      ]) {
        final _Rig rig = _Rig((http.Request r, int i) async => bad);
        expect(
          (await _fails(rig.client.checks())).kind,
          HealthchecksErrorKind.badResponse,
        );
      }
      final _Rig denied = _Rig(
        (http.Request r, int i) async => http.Response('denied', 401),
      );
      expect(
        (await _fails(denied.client.checks())).kind,
        HealthchecksErrorKind.unauthorized,
      );
      final _Rig noKey = _Rig(
        (http.Request r, int i) async => _ok(),
        vault: MemorySecretVault(<String, String>{
          'healthchecks.ping_key': _pingKey,
        }),
      );
      expect(
        (await _fails(noKey.client.checks())).kind,
        HealthchecksErrorKind.missingKey,
      );
      expect(noKey.requests, isEmpty);
    });
  });

  group('pause · resume(R45 C6)', () {
    test(
      '그때 ?slug= 로 찾아 uuid 로 POST · 키 머리 · resume 200 = true · 409 = false',
      () async {
        final List<int> resumeCodes = <int>[200, 409];
        final _Rig rig = _Rig((http.Request r, int i) async {
          if (r.method == 'GET') {
            return _json(<String, Object?>{
              'checks': <Object?>[_row(_slug)],
            });
          }
          if (r.url.path.endsWith('/resume')) {
            return http.Response('{}', resumeCodes.removeAt(0));
          }
          return http.Response('{}', 200);
        });
        await rig.client.pause(_slug, reason: PauseReason.modeSwitchCommit);
        expect(
          await rig.client.resume(_slug, reason: PauseReason.maintenanceWindow),
          isTrue,
        );
        expect(
          await rig.client.resume(_slug, reason: PauseReason.maintenanceWindow),
          isFalse,
        );
        expect(
          rig.requests.map((http.Request r) => '${r.method} ${r.url}'),
          <String>[
            'GET https://healthchecks.io/api/v3/checks/?slug=$_slug',
            'POST https://healthchecks.io/api/v3/checks/$_uuid/pause',
            'GET https://healthchecks.io/api/v3/checks/?slug=$_slug',
            'POST https://healthchecks.io/api/v3/checks/$_uuid/resume',
            'GET https://healthchecks.io/api/v3/checks/?slug=$_slug',
            'POST https://healthchecks.io/api/v3/checks/$_uuid/resume',
          ],
        );
        for (final http.Request r in rig.requests) {
          expect(r.headers['X-Api-Key'], _apiKey);
        }
      },
    );

    test('🔴 엔진 생존 체크는 멈추지 않는다(망 0) · 재개는 된다', () async {
      final _Rig rig = _Rig((http.Request r, int i) async {
        if (r.method == 'GET') {
          return _json(<String, Object?>{
            'checks': <Object?>[_row('live-auto-engine_alive')],
          });
        }
        return http.Response('{}', 200);
      });
      for (final String s in <String>[
        'live-auto-engine_alive',
        'sim-advisory-engine_alive',
        'engine_alive',
      ]) {
        final HealthchecksError e = await _fails(
          rig.client.pause(s, reason: PauseReason.maintenanceWindow),
        );
        expect(e.kind, HealthchecksErrorKind.refusedPause);
      }
      expect(rig.requests, isEmpty);
      expect(
        await rig.client.resume(
          'live-auto-engine_alive',
          reason: PauseReason.maintenanceWindow,
        ),
        isTrue,
      );
    });

    test(
      '0개 = 체크 없음 · 2개 = 겹침 · uuid 없음 = 읽기 전용 키 · 다른 슬러그 행은 무시 — POST 0',
      () async {
        for (final (List<Object?> rows, HealthchecksErrorKind kind)
            in <(List<Object?>, HealthchecksErrorKind)>[
              (<Object?>[], HealthchecksErrorKind.unknownCheck),
              (
                <Object?>[_row('live-auto-other')],
                HealthchecksErrorKind.unknownCheck,
              ),
              (
                <Object?>[_row(_slug), _row(_slug)],
                HealthchecksErrorKind.ambiguousSlug,
              ),
              (
                <Object?>[_row(_slug, withUuid: false)],
                HealthchecksErrorKind.readOnlyKey,
              ),
            ]) {
          final _Rig rig = _Rig(
            (http.Request r, int i) async =>
                _json(<String, Object?>{'checks': rows}),
          );
          final HealthchecksError e = await _fails(
            rig.client.pause(_slug, reason: PauseReason.maintenanceWindow),
          );
          expect(e.kind, kind);
          expect(
            rig.requests.where((http.Request r) => r.method == 'POST'),
            isEmpty,
          );
        }
      },
    );

    test('pause 409 · 404 = 실패 · 🔴 오류에 uuid · 키 없음', () async {
      for (final int code in <int>[409, 404, 500]) {
        final _Rig rig = _Rig((http.Request r, int i) async {
          if (r.method == 'GET') {
            return _json(<String, Object?>{
              'checks': <Object?>[_row(_slug)],
            });
          }
          return http.Response('{}', code);
        });
        final HealthchecksError e = await _fails(
          rig.client.pause(_slug, reason: PauseReason.maintenanceWindow),
        );
        expect(e.statusCode, code);
        expect(
          e.kind,
          code == 500
              ? HealthchecksErrorKind.server
              : HealthchecksErrorKind.badResponse,
        );
      }
    });
  });

  test('isNeverPauseSlug — 2축 합성 끝 이름 · 맨 이름', () {
    expect(isNeverPauseSlug('live-auto-engine_alive'), isTrue);
    expect(isNeverPauseSlug('engine_alive'), isTrue);
    expect(isNeverPauseSlug('live-auto-engine_alive_2'), isFalse);
    expect(isNeverPauseSlug('live-auto-daily_data'), isFalse);
    expect(isNeverPauseSlug('engine-alive'), isFalse);
  });
}
