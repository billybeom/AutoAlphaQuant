// E11m-a — command_open 당김 클라이언트(설계 13 §8 R274 · 계약 v1.41 `CommandReadRpcNames.open` · `CommandReadRpcParams.limit`).
//
// 지키는 것: 경로 · 머리 · 본문 = 계약 글자 · 401/403 = 토큰 새로 한 번 · 갈래(연결 칸 · 로그인 · 권한 · 서버 · 꼴 · 망) ·
// 꼴 아님 = 전부 버림 · 🔴 토큰 · 주소 · 키 · 행 값이 문자열에 0.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart' show SecretVault;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, CommandReadLimits, CommandReadRpcNames, CommandReadRpcParams;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
String _access(int n) => 'acc-${'A' * 10}-$n';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 12, 8, 9);
}

class _Rig {
  _Rig({Map<String, String>? vault})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
              'supabase.refresh_token': 'ref-${'R' * 12}',
            },
      );

  final SecretVault vault;
  final List<http.Request> rpc = <http.Request>[];
  int tokenN = 0;
  http.Response Function(int i) reply = (int _) => http.Response('[]', 200);

  late final http.Client net = MockClient((http.Request r) async {
    if (r.url.path.startsWith('/auth/')) {
      return http.Response(
        jsonEncode(<String, Object?>{
          'access_token': _access(++tokenN),
          'expires_in': 3600,
          'refresh_token': 'ref-${'R' * 12}-$tokenN',
          'user': <String, Object?>{'id': 'uid-1'},
        }),
        200,
      );
    }
    rpc.add(r);
    return reply(rpc.length - 1);
  });

  late final SupabaseCommandOpen client = SupabaseCommandOpen(
    net,
    vault,
    SupabaseAuth(net, vault, clock: _Clock()),
  );
}

void main() {
  test('경로 · 머리 · 본문 = 계약 글자 · 기본 상한 · 행 = 받은 그대로', () async {
    final _Rig rig = _Rig()
      ..reply = (int _) => http.Response(
        jsonEncode(<Object>[
          <String, Object?>{'command_id': 'a', 'kind': 'KILL_SWITCH_ACTIVATE'},
          <String, Object?>{'command_id': 'b', 'kind': 'DISCLOSURE_VIEW'},
        ]),
        200,
      );
    final CommandOpenResult r = await rig.client.open();
    expect(r.ok, isTrue);
    expect(r.rows!.map((Map<String, Object?> m) => m['command_id']), <String>[
      'a',
      'b',
    ]);
    final http.Request req = rig.rpc.single;
    expect(req.method, 'POST');
    expect(req.url.toString(), '$_url/rest/v1/rpc/${CommandReadRpcNames.open}');
    expect(req.headers['apikey'], _pub);
    expect(req.headers['authorization'], 'Bearer ${_access(1)}');
    expect(jsonDecode(req.body), <String, Object?>{
      CommandReadRpcParams.limit: CommandReadLimits.openMax,
    });
    await rig.client.open(limit: 7);
    expect(jsonDecode(rig.rpc.last.body), <String, Object?>{
      CommandReadRpcParams.limit: 7,
    });
    expect(r.toString(), 'CommandOpenResult(2행)');
  });

  test('401 → 토큰 새로 한 번 다시(같은 본문) · 두 번째도 403 = unauthorized', () async {
    final _Rig rig = _Rig()
      ..reply = (int i) =>
          i == 0 ? http.Response('', 401) : http.Response('[]', 200);
    final CommandOpenResult ok = await rig.client.open();
    expect((ok.ok, rig.rpc.length), (true, 2));
    expect(rig.rpc[1].headers['authorization'], 'Bearer ${_access(2)}');
    final _Rig deny = _Rig()..reply = (int _) => http.Response('', 403);
    final CommandOpenResult r = await deny.client.open();
    expect(
      (r.failure, r.statusCode, deny.rpc.length),
      (CommandOpenFailure.unauthorized, 403, 2),
    );
  });

  test('갈래 — 5xx = server · 404(옛 판 부트스트랩) · 꼴 아님 = badResponse · 연결 칸 없음 = config · 망 = network', () async {
    final _Rig s = _Rig()..reply = (int _) => http.Response('x', 503);
    expect((await s.client.open()).failure, CommandOpenFailure.server);
    for (final http.Response bad in <http.Response>[
      http.Response('{"message":"function not found"}', 404),
      http.Response('not json', 200),
      http.Response('{"command_id":"a"}', 200),
      http.Response('[{"command_id":"a"}, 3]', 200),
    ]) {
      final _Rig b = _Rig()..reply = (int _) => bad;
      final CommandOpenResult r = await b.client.open();
      expect(r.failure, CommandOpenFailure.badResponse, reason: bad.body);
      expect(r.rows, isNull);
    }
    final _Rig none = _Rig(vault: <String, String>{});
    expect((await none.client.open()).failure, CommandOpenFailure.config);
    expect(none.rpc, isEmpty);
    final _Rig net = _Rig()
      ..reply = (int _) => throw const SocketException('down');
    expect((await net.client.open()).failure, CommandOpenFailure.network);
  });

  test('로그인 세션 없음 = notSignedIn(망 0)', () async {
    final _Rig rig = _Rig(
      vault: <String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': _pub,
      },
    );
    final CommandOpenResult r = await rig.client.open();
    expect((r.failure, rig.rpc.length), (CommandOpenFailure.notSignedIn, 0));
  });

  test('🔴 문자열에 토큰 · 주소 · 키 · 행 값 0', () async {
    final _Rig rig = _Rig()
      ..reply = (int _) => http.Response(
        '[{"command_id":"secret-row","payload":{"x":"VALUE"}}]',
        200,
      );
    final CommandOpenResult ok = await rig.client.open();
    final _Rig deny = _Rig()..reply = (int _) => http.Response('', 403);
    final CommandOpenResult failed = await deny.client.open();
    for (final String s in <String>[ok.toString(), failed.toString()]) {
      for (final String leak in <String>[
        _access(1),
        _ref,
        _pub,
        'secret-row',
        'VALUE',
      ]) {
        expect(s, isNot(contains(leak)));
      }
    }
  });
}
