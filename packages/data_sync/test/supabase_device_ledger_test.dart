// R248 — R-01 기기 원장 읽기(`SupabaseDeviceLedger`) · 실 Supabase 호출 0(MockClient).
//
// 🔵 잡는 것: ① 연결 칸 없음 · 꼴 아님 = config(망 0) · `connected()` ② 로그인 전 = notSignedIn(망 0) ③ 읽기 = GET 두 번
//    (`app_device` · `operator_lease` · select 열 · apikey · Bearer · 쓰기 0) → 기기 행 · 리스 행(빈 배열 = 없음) ④ 401 = 토큰을
//    새로 받아 한 번 더 · 또 401 = unauthorized ⑤ 5xx = server · 꼴 = badResponse(상태 · 시각 꼴 · 리스 둘) · 망 = network ⑥ 세션은
//    금고에 있는데 새로고침 망 실패 = tokenRefresh(로그인 전이 아니다) ⑦ 토큰 · 키는 `toString` 에 없다.
// 🔴 시험 값은 이어 붙여 만든다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart' show RestartLedger;
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
const String _uid = '11111111-2222-4333-8444-555555555555';
String _access(int n) => 'acc-${'A' * 10}-$n';
String _refresh(int n) => 'ref-${'R' * 10}-$n';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 12, 8, 9);
}

final List<Map<String, Object?>> _devices = <Map<String, Object?>>[
  <String, Object?>{
    'device_id': 'dev-old',
    'label': '거실 폰',
    'status': 'ACTIVE',
    'platform': 'android',
    'last_seen_at': '2026-12-08T08:55:00.123456+00:00',
  },
  <String, Object?>{
    'device_id': 'dev-new',
    'label': '운영 폰',
    'status': 'PENDING',
    'platform': null,
    'last_seen_at': null,
  },
];

final List<Map<String, Object?>> _lease = <Map<String, Object?>>[
  <String, Object?>{
    'device_id': 'dev-old',
    'epoch': 4,
    'expires_at': '2026-12-08T09:20:00+00:00',
  },
];

/// 🔴 머리 charset 없이 UTF-8 바이트(한글 라벨이 그대로 와야 한다).
http.Response _json(Object body) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), 200);

class _Rig {
  _Rig({Map<String, String>? vault})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
              'supabase.refresh_token': _refresh(0),
            },
      );

  final MemorySecretVault vault;
  final List<http.Request> calls = <http.Request>[];
  int tokenN = 0;

  /// 토큰 응답(i = 몇 번째).
  http.Response Function(int i)? token;

  /// 기기 표 응답.
  http.Response Function(int i) devices = (_) => _json(_devices);

  /// 리스 표 응답.
  http.Response Function(int i) lease = (_) => _json(_lease);

  int _n(String path) =>
      calls.where((http.Request q) => q.url.path == path).length - 1;

  late final http.Client net = MockClient((http.Request r) async {
    calls.add(r);
    if (r.url.path.startsWith('/auth/')) {
      final http.Response Function(int)? t = token;
      if (t != null) return t(tokenN++);
      tokenN++;
      return http.Response(
        jsonEncode(<String, Object?>{
          'access_token': _access(tokenN),
          'expires_in': 3600,
          'refresh_token': _refresh(tokenN),
          'user': <String, Object?>{'id': _uid},
        }),
        200,
      );
    }
    if (r.url.path == '/rest/v1/app_device') {
      return devices(_n(r.url.path));
    }
    if (r.url.path == '/rest/v1/operator_lease') {
      return lease(_n(r.url.path));
    }
    return http.Response('', 404);
  });

  late final SupabaseAuth auth = SupabaseAuth(net, vault, clock: _Clock());
  late final SupabaseDeviceLedger reader = SupabaseDeviceLedger(
    net,
    vault,
    auth,
  );

  List<http.Request> get rest =>
      calls.where((http.Request r) => r.url.path.startsWith('/rest/')).toList();
}

void main() {
  test('🔴 연결 칸 없음 · 꼴 아님 = config(망 0) · connected() 거짓', () async {
    for (final Map<String, String> v in <Map<String, String>>[
      <String, String>{},
      <String, String>{'supabase.project_url': _url},
      <String, String>{
        'supabase.project_url': 'http://example.com',
        'supabase.publishable_key': _pub,
      },
      <String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': 'sb_${'secret'}_${'Z' * 20}',
      },
    ]) {
      final _Rig rig = _Rig(vault: v);
      expect(await rig.reader.connected(), isFalse);
      final DeviceLedgerRead r = await rig.reader.read();
      expect(r.failure, DeviceLedgerFailure.config);
      expect(r.signedIn, isFalse);
      expect(rig.calls, isEmpty);
    }
    expect(await _Rig().reader.connected(), isTrue);
  });

  test('🔴 로그인 전(금고에 새로고침 토큰 없음) = notSignedIn · 망 0', () async {
    final _Rig rig = _Rig(
      vault: <String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': _pub,
      },
    );
    final DeviceLedgerRead r = await rig.reader.read();
    expect(r.failure, DeviceLedgerFailure.notSignedIn);
    expect(r.signedIn, isFalse);
    expect(rig.calls, isEmpty);
  });

  test('🔴 읽기 = GET 둘(열 · 머리 · 쓰기 0) → 기기 행 · 리스 행', () async {
    final _Rig rig = _Rig();
    final DeviceLedgerRead r = await rig.reader.read();
    expect(r.failure, isNull);
    expect(r.signedIn, isTrue);
    final RestartLedger l = r.ledger!;
    expect(l.devices.map((d) => d.deviceId), <String>['dev-old', 'dev-new']);
    expect(l.devices.first.label, '거실 폰');
    expect(l.devices.first.status, 'ACTIVE');
    expect(l.devices.first.platform, 'android');
    expect(
      l.devices.first.lastSeenAtUtc,
      DateTime.utc(2026, 12, 8, 8, 55, 0, 123, 456),
    );
    expect(l.devices.last.platform, isNull);
    expect(l.devices.last.lastSeenAtUtc, isNull);
    expect(l.lease!.deviceId, 'dev-old');
    expect(l.lease!.epoch, 4);
    expect(l.lease!.expiresAtUtc, DateTime.utc(2026, 12, 8, 9, 20));
    expect(rig.rest, hasLength(2));
    for (final http.Request q in rig.rest) {
      expect(q.method, 'GET');
      expect(q.url.host, '$_ref.supabase.co');
      expect(q.headers['apikey'], _pub);
      expect(q.headers['authorization'], 'Bearer ${_access(1)}');
    }
    expect(rig.rest[0].url.path, '/rest/v1/app_device');
    expect(rig.rest[0].url.queryParameters, <String, String>{
      'select': 'device_id,label,status,platform,last_seen_at',
    });
    expect(rig.rest[1].url.path, '/rest/v1/operator_lease');
    expect(rig.rest[1].url.queryParameters, <String, String>{
      'select': 'device_id,epoch,expires_at',
    });
    // 🔴 토큰 · 키 · 주소는 결과 글자에 없다.
    for (final String secret in <String>[_access(1), _pub, _ref]) {
      expect(r.toString(), isNot(contains(secret)));
    }
  });

  test('리스 빈 배열 = 리스 없음(첫 클레임 전)', () async {
    final _Rig rig = _Rig()..lease = (_) => http.Response('[]', 200);
    final DeviceLedgerRead r = await rig.reader.read();
    expect(r.failure, isNull);
    expect(r.ledger!.lease, isNull);
  });

  test('🔴 401 = 토큰 새로 받아 한 번 더(같은 표) · 또 401 = unauthorized', () async {
    final _Rig once = _Rig()
      ..devices = (int i) => i == 0 ? http.Response('', 401) : _json(_devices);
    final DeviceLedgerRead ok = await once.reader.read();
    expect(ok.failure, isNull);
    expect(
      once.rest.map((http.Request q) => q.headers['authorization']).toList(),
      <String>[
        'Bearer ${_access(1)}',
        'Bearer ${_access(2)}',
        'Bearer ${_access(2)}',
      ],
    );
    final _Rig twice = _Rig()..lease = (_) => http.Response('', 403);
    final DeviceLedgerRead no = await twice.reader.read();
    expect(no.failure, DeviceLedgerFailure.unauthorized);
    expect(no.statusCode, 403);
    expect(no.signedIn, isTrue);
  });

  test('5xx = server · 그 밖 HTTP = badResponse · 망 = network', () async {
    expect(
      (await (_Rig()..devices = (_) => http.Response('', 503)).reader.read())
          .failure,
      DeviceLedgerFailure.server,
    );
    expect(
      (await (_Rig()..lease = (_) => http.Response('', 404)).reader.read())
          .failure,
      DeviceLedgerFailure.badResponse,
    );
    final _Rig down = _Rig()
      ..devices = (_) => throw const SocketException('down');
    expect((await down.reader.read()).failure, DeviceLedgerFailure.network);
  });

  test('🔴 꼴 아님 = badResponse(상태 · 시각 · 리스 둘 · 객체 · 글자)', () async {
    Future<DeviceLedgerFailure?> devices(Object body) async =>
        (await (_Rig()..devices = (_) => _json(body)).reader.read()).failure;
    Future<DeviceLedgerFailure?> lease(Object body) async =>
        (await (_Rig()..lease = (_) => _json(body)).reader.read()).failure;
    Map<String, Object?> dev(String k, Object? v) => <String, Object?>{
      ..._devices.first,
      k: v,
    };
    Map<String, Object?> ls(String k, Object? v) => <String, Object?>{
      ..._lease.single,
      k: v,
    };
    const DeviceLedgerFailure bad = DeviceLedgerFailure.badResponse;
    expect(await devices(<Object?>[dev('status', 'LOST')]), bad);
    expect(await devices(<Object?>[dev('device_id', '')]), bad);
    expect(await devices(<Object?>[dev('label', 3)]), bad);
    expect(await devices(<Object?>[dev('platform', 1)]), bad);
    expect(
      await devices(<Object?>[dev('last_seen_at', '2026-12-08T08:55:00')]),
      bad,
    );
    expect(await devices(_devices.first), bad);
    expect(await lease(<Object?>[_lease.single, _lease.single]), bad);
    expect(await lease(<Object?>[ls('epoch', 0)]), bad);
    expect(await lease(<Object?>[ls('epoch', '4')]), bad);
    expect(await lease(<Object?>[ls('expires_at', null)]), bad);
    expect(
      (await (_Rig()..lease = (_) => http.Response('not json', 200)).reader
              .read())
          .failure,
      bad,
    );
    expect(
      (await (_Rig()
                ..devices = (_) =>
                    http.Response.bytes(<int>[0x5b, 0xff, 0x5d], 200))
              .reader
              .read())
          .failure,
      bad,
    );
  });

  test('🔴 세션은 금고에 있는데 새로고침 망 실패 = tokenRefresh(로그인 전이 아니다) · 거부(400) = notSignedIn', () async {
    final _Rig net = _Rig()..token = (_) => throw const SocketException('down');
    final DeviceLedgerRead r = await net.reader.read();
    expect(r.failure, DeviceLedgerFailure.tokenRefresh);
    expect(r.signedIn, isTrue);
    expect(net.rest, isEmpty);
    final _Rig lost = _Rig()
      ..token = (_) => http.Response(
        jsonEncode(<String, Object?>{'error': 'invalid_grant'}),
        400,
      );
    final DeviceLedgerRead gone = await lost.reader.read();
    expect(gone.failure, DeviceLedgerFailure.notSignedIn);
    expect(gone.signedIn, isFalse);
  });
}
