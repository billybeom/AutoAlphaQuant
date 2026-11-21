// E11k-e1 — 리스 RPC 클라이언트 · 원격 리스 판정(설계 13 §8 R215 · 계약 v1.29 `schema/supabase_rpc.dart`).
//
// 🔵 잡는 것: ① RPC = `rest/v1/rpc/<계약 이름>` · apikey + Bearer · 본문 = 계약 인자 이름 ② 반환 한 행(배열 · 객체) · 거부 코드 =
//    서버 글자만(모르는 코드 · 꼴 = badResponse) ③ 401 = 토큰 한 번 새로 받아 다시 · 그래도 401 = unauthorized ④ 연결 칸 · 로그인 없음 = 망 0
//    ⑤ 판정: 쥔 epoch 0 = 무효(자동 클레임 0 · 망 0) · 갱신 성공 = 유효 + sync_state(epoch · last_ok_at · OK) · LOST = 클레임 한 번 ·
//    다른 기기 = 무효 · 망 · 서버 · 인증 = 모름 ⑥ 🔴 봉인 행은 바꾸지 않는다 ⑦ 🔴 문자열에 토큰 · 복구 코드 · 주소 · 키 0
//    ⑧ `SqliteLeaseGate(remote:)` 에 끼우면 봉인이 먼저.
// 🔴 시험 값은 이어 붙여 만든다(실 Supabase 호출 0).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart' show LeaseVerdict;
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
const String _device = 'dev-aaaa';
final String _recovery = 'rc-${'Z' * 14}';
String _access(int n) => 'acc-${'A' * 10}-$n';
String _refresh(int n) => 'ref-${'R' * 10}-$n';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

http.Response _tokens(int n) => http.Response(
  jsonEncode(<String, Object?>{
    'access_token': _access(n),
    'expires_in': 3600,
    'refresh_token': _refresh(n),
    'user': <String, Object?>{'id': 'uid-1'},
  }),
  200,
);

http.Response _row(
  Object? code,
  Object? epoch,
  Object? exp, {
  bool list = true,
}) {
  final Map<String, Object?> r = <String, Object?>{
    'code': code,
    'epoch': epoch,
    'expires_at': exp,
  };
  return http.Response(jsonEncode(list ? <Object>[r] : r), 200);
}

const String _exp = '2026-12-08T09:30:00+00:00';

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
  final _Clock clock = _Clock(DateTime.utc(2026, 12, 8, 9));
  final List<http.Request> rpc = <http.Request>[];
  final List<http.Request> auth = <http.Request>[];
  int tokenN = 0;

  /// RPC 응답(차례대로 · i = RPC 몇 번째).
  late http.Response Function(http.Request r, int i) reply;

  late final http.Client net = MockClient((http.Request r) async {
    if (r.url.path.startsWith('/auth/')) {
      auth.add(r);
      return _tokens(++tokenN);
    }
    rpc.add(r);
    return reply(r, rpc.length - 1);
  });
  late final SupabaseAuth sa = SupabaseAuth(net, vault, clock: clock);
  late final SupabaseLeaseRpc client = SupabaseLeaseRpc(net, vault, sa);

  Map<String, Object?> body(int i) =>
      jsonDecode(rpc[i].body) as Map<String, Object?>;
}

void main() {
  group('RPC 클라이언트', () {
    test(
      '🔴 renew = rest/v1/rpc/lease_renew · apikey + Bearer · 계약 인자 · 한 행 → 성공',
      () async {
        final _Rig r = _Rig()..reply = (_, _) => _row(null, 4, _exp);
        final LeaseRpcResult res = await r.client.renew(
          deviceId: _device,
          epoch: 4,
        );
        expect(res.granted, isTrue);
        expect(res.epoch, 4);
        expect(res.expiresAtUtc, DateTime.utc(2026, 12, 8, 9, 30));
        final http.Request q = r.rpc.single;
        expect(q.method, 'POST');
        expect(q.url.toString(), '$_url/rest/v1/rpc/lease_renew');
        expect(q.headers['apikey'], _pub);
        expect(q.headers['authorization'], 'Bearer ${_access(1)}');
        expect(r.body(0), <String, Object?>{
          'p_device_id': _device,
          'p_epoch': 4,
        });
      },
    );

    test('claim · revoke = 계약 이름 · 인자(첫 클레임 해시 null 허용)', () async {
      final _Rig r = _Rig()..reply = (_, _) => _row(null, 5, _exp, list: false);
      expect((await r.client.claim(deviceId: _device)).granted, isTrue);
      expect(r.rpc[0].url.path, '/rest/v1/rpc/lease_claim');
      expect(r.body(0), <String, Object?>{
        'p_device_id': _device,
        'p_recovery_code_hash': null,
      });
      await r.client.revoke(
        deviceId: _device,
        recoveryCode: _recovery,
        newRecoveryCodeHash: 'h' * 64,
      );
      expect(r.rpc[1].url.path, '/rest/v1/rpc/lease_revoke');
      expect(r.body(1), <String, Object?>{
        'p_device_id': _device,
        'p_recovery_code': _recovery,
        'p_new_recovery_code_hash': 'h' * 64,
      });
    });

    test('서버 거부 = 그 글자 그대로(답함 · 유효 아님)', () async {
      for (final String code in LeaseRpcResultCodes.values) {
        final _Rig r = _Rig()..reply = (_, _) => _row(code, 3, null);
        final LeaseRpcResult res = await r.client.renew(
          deviceId: _device,
          epoch: 3,
        );
        expect(res.code, code);
        expect(res.failure, isNull);
        expect(res.granted, isFalse);
      }
    });

    for (final (String name, http.Response Function() resp)
        in <(String, http.Response Function())>[
          ('모르는 코드', () => _row('NOPE', 3, _exp)),
          ('성공인데 epoch 없음', () => _row(null, null, _exp)),
          ('성공인데 만료 없음', () => _row(null, 3, null)),
          ('만료 오프셋 없음', () => _row(null, 3, '2026-12-08T09:30:00')),
          ('epoch 글자', () => _row(null, '3', _exp)),
          (
            '두 행',
            () => http.Response(
              jsonEncode(<Object>[<String, Object?>{}, <String, Object?>{}]),
              200,
            ),
          ),
          ('JSON 아님', () => http.Response('<html>', 200)),
          ('404', () => http.Response('{}', 404)),
        ]) {
      test('🔴 $name = badResponse(코드를 짓지 않는다)', () async {
        final _Rig r = _Rig()..reply = (_, _) => resp();
        final LeaseRpcResult res = await r.client.renew(
          deviceId: _device,
          epoch: 3,
        );
        expect(res.failure, LeaseRpcFailure.badResponse);
        expect(res.code, isNull);
      });
    }

    test('🔴 200 이 아니면 행이 실려 와도 badResponse(201 · 404)', () async {
      for (final int code in <int>[201, 404]) {
        final _Rig r = _Rig()
          ..reply = (_, _) => http.Response(
            jsonEncode(<String, Object?>{
              'code': null,
              'epoch': 3,
              'expires_at': _exp,
            }),
            code,
          );
        final LeaseRpcResult res = await r.client.renew(
          deviceId: _device,
          epoch: 3,
        );
        expect(res.failure, LeaseRpcFailure.badResponse, reason: '$code');
        expect(res.statusCode, code);
        expect(res.granted, isFalse);
      }
    });

    test('granted = 답함 ∧ 거부 없음 ∧ epoch 있음', () {
      expect(
        LeaseRpcResult.answered(
          code: null,
          epoch: 3,
          expiresAtUtc: DateTime.utc(2026),
        ).granted,
        isTrue,
      );
      expect(
        const LeaseRpcResult.answered(
          code: null,
          epoch: null,
          expiresAtUtc: null,
        ).granted,
        isFalse,
      );
      expect(
        const LeaseRpcResult.answered(
          code: 'LEASE_LOST',
          epoch: 3,
          expiresAtUtc: null,
        ).granted,
        isFalse,
      );
    });

    test('5xx = server · 끊김 = network', () async {
      final _Rig a = _Rig()..reply = (_, _) => http.Response('', 503);
      expect(
        (await a.client.renew(deviceId: _device, epoch: 3)).failure,
        LeaseRpcFailure.server,
      );
      final _Rig b = _Rig()..reply = (_, _) => throw http.ClientException('x');
      expect(
        (await b.client.renew(deviceId: _device, epoch: 3)).failure,
        LeaseRpcFailure.network,
      );
    });

    test('🔴 401 = 토큰 한 번 새로 받아 다시 → 성공', () async {
      final _Rig r = _Rig()
        ..reply = (_, int i) =>
            i == 0 ? http.Response('', 401) : _row(null, 3, _exp);
      final LeaseRpcResult res = await r.client.renew(
        deviceId: _device,
        epoch: 3,
      );
      expect(res.granted, isTrue);
      expect(r.rpc, hasLength(2));
      expect(r.rpc[1].headers['authorization'], 'Bearer ${_access(2)}');
      expect(r.auth, hasLength(2));
    });

    test('그래도 403 = unauthorized(두 번까지만)', () async {
      final _Rig r = _Rig()..reply = (_, _) => http.Response('', 403);
      final LeaseRpcResult res = await r.client.renew(
        deviceId: _device,
        epoch: 3,
      );
      expect(res.failure, LeaseRpcFailure.unauthorized);
      expect(res.statusCode, 403);
      expect(r.rpc, hasLength(2));
    });

    test('연결 칸 없음 = config · 로그인 없음 = notSignedIn · 둘 다 RPC 0', () async {
      final _Rig a = _Rig(vault: <String, String>{})
        ..reply = (_, _) => _row(null, 3, _exp);
      expect(
        (await a.client.renew(deviceId: _device, epoch: 3)).failure,
        LeaseRpcFailure.config,
      );
      final _Rig b = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
        },
      )..reply = (_, _) => _row(null, 3, _exp);
      expect(
        (await b.client.renew(deviceId: _device, epoch: 3)).failure,
        LeaseRpcFailure.notSignedIn,
      );
      expect(a.rpc, isEmpty);
      expect(b.rpc, isEmpty);
    });

    test('🔴 결과 문자열에 토큰 · 복구 코드 · 주소 · 키 0', () async {
      final _Rig r = _Rig()
        ..reply = (_, _) => _row('RECOVERY_CODE_INVALID', 3, null);
      final LeaseRpcResult res = await r.client.revoke(
        deviceId: _device,
        recoveryCode: _recovery,
        newRecoveryCodeHash: 'h' * 64,
      );
      for (final String s in <String>[_access(1), _recovery, _ref, _pub]) {
        expect(res.toString(), isNot(contains(s)));
      }
      expect(res.toString(), 'LeaseRpcResult(RECOVERY_CODE_INVALID · epoch 3)');
      expect(
        const LeaseRpcResult.failed(
          LeaseRpcFailure.server,
          statusCode: 503,
        ).toString(),
        'LeaseRpcResult(server · HTTP 503)',
      );
    });
  });

  group('원격 리스 판정', () {
    late Directory dir;
    late Database db;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aaq_lease_rpc_');
      db = openLocalLedger(
        dir.path,
        RunMode.live,
        clock: () => DateTime.utc(2026, 12, 8),
      );
    });
    tearDown(() {
      db.close();
      dir.deleteSync(recursive: true);
    });

    void held(int epoch, {String status = 'OK'}) => db.execute(
      "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', '2026-12-08T08:00:00.000Z', ?, ?, '2026-12-08T08:00:00.000Z')",
      <Object?>[status, epoch],
    );

    Map<String, Object?> row() =>
        db.select("SELECT * FROM sync_state WHERE target = 'SUPABASE'").first;

    SupabaseLeaseGate gate(_Rig r) =>
        SupabaseLeaseGate(r.client, db, deviceId: _device, clock: r.clock);

    test('🔴 쥔 epoch 0(행 없음) = 무효 · 자동 클레임 0 · 망 0', () async {
      final _Rig r = _Rig()..reply = (_, _) => _row(null, 1, _exp);
      final SupabaseLeaseGate g = gate(r);
      expect(await g.check(), LeaseVerdict.invalid);
      expect(r.rpc, isEmpty);
      expect(r.auth, isEmpty);
      expect(g.last, isNull);
    });

    test('🔴 갱신 성공 = 유효 + sync_state(epoch · last_ok_at = 지금 · OK)', () async {
      held(4);
      final _Rig r = _Rig()..reply = (_, _) => _row(null, 4, _exp);
      expect(await gate(r).check(), LeaseVerdict.valid);
      expect(r.rpc.single.url.path, '/rest/v1/rpc/lease_renew');
      expect(r.body(0)['p_epoch'], 4);
      expect(row()['operator_epoch'], 4);
      expect(row()['status'], 'OK');
      expect(row()['last_ok_at'], '2026-12-08T09:00:00.000Z');
    });

    test('🔴 LOST = 클레임 한 번 → 되찾음(새 epoch 기록) · 다른 기기 = 무효', () async {
      held(4);
      final _Rig a = _Rig()
        ..reply = (_, int i) =>
            i == 0 ? _row('LEASE_LOST', 6, null) : _row(null, 7, _exp);
      expect(await gate(a).check(), LeaseVerdict.valid);
      expect(a.rpc.map((http.Request q) => q.url.path), <String>[
        '/rest/v1/rpc/lease_renew',
        '/rest/v1/rpc/lease_claim',
      ]);
      expect(a.body(1)['p_recovery_code_hash'], isNull);
      expect(row()['operator_epoch'], 7);
      final _Rig b = _Rig()
        ..reply = (_, int i) => i == 0
            ? _row('LEASE_LOST', 7, null)
            : _row('LEASE_HELD_BY_OTHER', 8, null);
      expect(await gate(b).check(), LeaseVerdict.invalid);
      expect(row()['operator_epoch'], 7, reason: '거부 = 기록 안 바꿈');
    });

    for (final String code in <String>[
      'LEASE_HELD_BY_OTHER',
      'LEASE_DEVICE_NOT_ELIGIBLE',
      'RECOVERY_CODE_REQUIRED',
    ]) {
      test('갱신 거부 $code = 무효 · 클레임 0 · 기록 그대로', () async {
        held(4);
        final _Rig r = _Rig()..reply = (_, _) => _row(code, 4, null);
        expect(await gate(r).check(), LeaseVerdict.invalid);
        expect(r.rpc, hasLength(1));
        expect(row()['last_ok_at'], '2026-12-08T08:00:00.000Z');
      });
    }

    for (final (String name, http.Response Function(http.Request, int) reply)
        in <(String, http.Response Function(http.Request, int))>[
          ('5xx', (_, _) => http.Response('', 500)),
          ('끊김', (_, _) => throw http.ClientException('x')),
          ('꼴', (_, _) => http.Response('[]', 200)),
          (
            'LOST 뒤 클레임 끊김',
            (_, int i) => i == 0
                ? _row('LEASE_LOST', 4, null)
                : throw http.ClientException('x'),
          ),
        ]) {
      test('🔴 $name = 모름(막는다) · 기록 그대로', () async {
        held(4);
        final _Rig r = _Rig()..reply = reply;
        expect(await gate(r).check(), LeaseVerdict.unknown);
        expect(row()['last_ok_at'], '2026-12-08T08:00:00.000Z');
      });
    }

    test('🔴 로그인 없음 = 모름(RPC 0)', () async {
      held(4);
      final _Rig r = _Rig(
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
        },
      )..reply = (_, _) => _row(null, 4, _exp);
      expect(await gate(r).check(), LeaseVerdict.unknown);
      expect(r.rpc, isEmpty);
    });

    test('🔴 봉인 행은 바꾸지 않는다 · SqliteLeaseGate 에 끼우면 봉인이 먼저(RPC 0)', () async {
      held(4, status: 'SEALED');
      final _Rig r = _Rig()..reply = (_, _) => _row(null, 4, _exp);
      // 원격 판정만 따로 부르면 유효여도 봉인 행은 그대로.
      expect(await gate(r).check(), LeaseVerdict.valid);
      expect(row()['status'], 'SEALED');
      expect(row()['last_ok_at'], '2026-12-08T08:00:00.000Z');
      final _Rig r2 = _Rig()..reply = (_, _) => _row(null, 4, _exp);
      final SqliteLeaseGate local = SqliteLeaseGate(
        db,
        mode: RunMode.live,
        clock: r2.clock,
        remote: gate(r2),
      );
      expect(await local.check(), LeaseVerdict.invalid);
      expect(r2.rpc, isEmpty);
    });

    test('SqliteLeaseGate(remote:) — 실전 = 원격 판정을 쓴다', () async {
      held(4);
      final _Rig r = _Rig()..reply = (_, _) => _row(null, 4, _exp);
      final SqliteLeaseGate local = SqliteLeaseGate(
        db,
        mode: RunMode.live,
        clock: r.clock,
        remote: gate(r),
      );
      expect(await local.check(), LeaseVerdict.valid);
      expect(await local.derivedWritesAllowed(), isTrue);
    });
  });
}
