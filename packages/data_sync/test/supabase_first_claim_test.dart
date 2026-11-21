// E11k-e3 — O-04 ⑤ 복구 카드 발급 · 첫 클레임 명시 흐름 · 기기 행 등록 · 원격 판정 «쥔 epoch» 대체(설계 13 §8 R229).
//
// 🔵 잡는 것: ① 복구 코드 = 32글자(0 1 I O 0개) × 20 = 100비트 · 4자 묶음 · 정규화 뒤 그대로 · 소금 16바이트 ② 대조 = 같은 소금 해시
//    (대소문자 · 하이픈 · 띄어쓰기 무관 · 한 글자 다름 = 틀림 · 꼴 아님 = 틀림) ③ 흐름: 다름 = 기록 · 망 0 / 맞음 = 대기 행(해시만) →
//    `POST rest/v1/app_device`(v1.34 RLS 꼴 · return=minimal) → `lease_claim`(그 해시) → 실행됨(epoch) · epoch > 1 = 예전 카드 ·
//    서버 거부 = 거부됨(새 카드) · 망 = 대기 그대로(같은 해시로 다시) · 연결 · 로그인 없음 = 먼저 o_07 ④ 🔴 평문은 원장 어느 칸에도 없다 ·
//    `toString` 0 ⑤ 판정: 원장 행 없음 + 첫 클레임 기록 = 그 epoch 로 갱신 → LOST → 클레임 / 기록 0 = 자동 클레임 0 ⑥ 성공 기록이
//    SUPABASE 행 상태(FORK · PUSH_FAILED)를 덮지 않는다.
// 🔴 시험 값은 이어 붙여 만든다(실 Supabase 호출 0 · MockClient).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show
        FirstClaimOutcome,
        LeaseVerdict,
        RecoveryCardTexts,
        kOperatorDeviceLabel,
        kRecoveryCardKind;
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
const String _device = '0f1e2d3c-4b5a-4978-8a6b-5c4d3e2f1a0b';
const String _uid = '11111111-2222-4333-8444-555555555555';
String _access(int n) => 'acc-${'A' * 10}-$n';
String _refresh(int n) => 'ref-${'R' * 10}-$n';
const String _exp = '2026-12-08T09:30:00+00:00';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

http.Response _row(Object? code, Object? epoch, Object? exp) => http.Response(
  jsonEncode(<Map<String, Object?>>[
    <String, Object?>{'code': code, 'epoch': epoch, 'expires_at': exp},
  ]),
  200,
);

class _Rig {
  _Rig({Map<String, String>? vault, required this.db, this.seed = 7})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
              'supabase.refresh_token': _refresh(0),
            },
      );

  final Database db;
  final int seed;
  final MemorySecretVault vault;
  final _Clock clock = _Clock(DateTime.utc(2026, 12, 8, 9));
  final List<http.Request> calls = <http.Request>[];
  int tokenN = 0;

  /// 기기 행 응답 차례(i = 몇 번째 POST).
  http.Response Function(int i) device = (_) => http.Response('', 201);

  /// RPC 응답 차례.
  http.Response Function(int i) rpc = (_) => _row(null, 1, _exp);

  List<http.Request> get rest => calls
      .where((http.Request r) => !r.url.path.startsWith('/auth/'))
      .toList();

  late final http.Client net = MockClient((http.Request r) async {
    calls.add(r);
    if (r.url.path.startsWith('/auth/')) {
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
      return device(
        calls.where((http.Request q) => q.url.path == r.url.path).length - 1,
      );
    }
    return rpc(
      calls.where((http.Request q) => q.url.path.contains('/rpc/')).length - 1,
    );
  });
  late final SupabaseAuth auth = SupabaseAuth(net, vault, clock: clock);
  late final SupabaseLeaseRpc client = SupabaseLeaseRpc(net, vault, auth);
  late final SupabaseFirstClaim flow = SupabaseFirstClaim(
    client,
    db,
    deviceId: _device,
    clock: clock,
    random: Random(seed),
  );

  /// 지금 열린 카드의 코드(카드 줄에서).
  String code() => flow
      .issueLines()
      .firstWhere((String l) => l.startsWith('복구 코드: '))
      .substring('복구 코드: '.length);

  List<Map<String, Object?>> inbox() => <Map<String, Object?>>[
    for (final Row r in db.select(
      'SELECT * FROM command_inbox WHERE kind = ? ORDER BY rowid',
      <Object?>[kRecoveryCardKind],
    ))
      Map<String, Object?>.of(r),
  ];
}

void main() {
  late Directory dir;
  late Database db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_first_claim_');
    db = openLocalLedger(
      dir.path,
      RunMode.simInternal,
      clock: () => DateTime.utc(2026, 12, 8),
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  group('복구 코드 발급 · 대조', () {
    test('🔴 글자 32(0 1 I O 0개 · 중복 0) × 20 = 100비트 · 4자 묶음 5 · 정규화 뒤 그대로', () {
      expect(kRecoveryCodeAlphabet.length, 32);
      expect(kRecoveryCodeAlphabet.split('').toSet(), hasLength(32));
      for (final String bad in <String>['0', '1', 'I', 'O']) {
        expect(kRecoveryCodeAlphabet, isNot(contains(bad)));
      }
      expect(
        normalizeRecoveryCode(kRecoveryCodeAlphabet),
        kRecoveryCodeAlphabet,
      );
      expect(kRecoveryCodeLength * 5, greaterThanOrEqualTo(100));
      final RegExp shape = RegExp(
        '^[$kRecoveryCodeAlphabet]{4}(-[$kRecoveryCodeAlphabet]{4}){4}\$',
      );
      final Random r = Random(1);
      for (int i = 0; i < 200; i++) {
        expect(newRecoveryCode(r), matches(shape));
      }
      final Random s = Random.secure();
      expect(newRecoveryCode(s), isNot(newRecoveryCode(s)));
    });

    test('소금 = 16바이트 소문자 16진 32 · 해시 꼴 = 서버 정규식', () {
      final Random r = Random(2);
      for (int i = 0; i < 50; i++) {
        expect(newRecoverySaltHex(r), matches(RegExp(r'^[0-9a-f]{32}$')));
      }
      final IssuedRecoveryCode c = issueRecoveryCode(Random(3));
      expect(c.hash, matches(kRecoveryCodeHashShape));
      expect(c.toString(), isNot(contains(c.code)));
      expect(c.toString(), isNot(contains(c.hash)));
    });

    test('🔴 대조 = 대소문자 · 하이픈 · 띄어쓰기 무관 · 한 글자 다름 = 틀림 · 꼴 아님 = 틀림', () {
      final IssuedRecoveryCode c = issueRecoveryCode(Random(4));
      expect(recoveryCodeMatches(c.code, c.hash), isTrue);
      expect(
        recoveryCodeMatches(c.code.toLowerCase().replaceAll('-', ' '), c.hash),
        isTrue,
      );
      final String last = c.code.substring(c.code.length - 1);
      final String other =
          kRecoveryCodeAlphabet[(kRecoveryCodeAlphabet.indexOf(last) + 1) % 32];
      expect(
        recoveryCodeMatches(
          c.code.substring(0, c.code.length - 1) + other,
          c.hash,
        ),
        isFalse,
      );
      expect(recoveryCodeMatches('', c.hash), isFalse);
      expect(recoveryCodeMatches(c.code, 'sha256:xyz'), isFalse);
      expect(recoveryCodeMatches(c.code, c.hash.toUpperCase()), isFalse);
    });
  });

  group('첫 클레임 흐름', () {
    test('🔴 열림 = 카드 줄에 코드 한 번 · 같은 프로세스 = 같은 카드 · 사실 = 시작 전', () {
      final _Rig r = _Rig(db: db);
      final List<String> a = r.flow.issueLines();
      expect(a, hasLength(4));
      expect(a.first, startsWith('복구 코드: '));
      expect(r.flow.issueLines(), a);
      final RecoveryCardFact f = r.flow.fact();
      expect(f.done, isFalse);
      expect(f.pending, isFalse);
      expect(f.lines, isEmpty);
      expect(r.calls, isEmpty);
    });

    test('🔴 다름 = 기록 0 · 망 0 · 카드 그대로(다시 입력)', () async {
      final _Rig r = _Rig(db: db);
      final String code = r.code();
      expect(
        await r.flow.confirm('${code.substring(1)}2'),
        FirstClaimOutcome.mismatch,
      );
      expect(r.inbox(), isEmpty);
      expect(r.calls, isEmpty);
      expect(r.code(), code);
    });

    test('🔴 맞음 = 대기 행(해시만) → 기기 행(v1.34 RLS 꼴) → lease_claim(그 해시) → 실행됨 epoch 1 · 평문 0', () async {
      final _Rig r = _Rig(db: db);
      final String code = r.code();
      expect(
        await r.flow.confirm(code.toLowerCase().replaceAll('-', '')),
        FirstClaimOutcome.claimed,
      );
      final List<http.Request> rest = r.rest;
      expect(rest, hasLength(2));
      final http.Request dev = rest[0];
      expect(dev.method, 'POST');
      expect(dev.url.toString(), '$_url/rest/v1/app_device');
      expect(dev.headers['apikey'], _pub);
      expect(dev.headers['authorization'], 'Bearer ${_access(1)}');
      expect(dev.headers['prefer'], 'return=minimal');
      expect(jsonDecode(dev.body), <String, Object?>{
        'device_id': _device,
        'label': kOperatorDeviceLabel,
        'role': 'viewer',
        'status': 'PENDING',
        'platform': 'android',
        'owner_uid': _uid,
        'auth_uid': _uid,
      });
      final http.Request claim = rest[1];
      expect(claim.url.path, '/rest/v1/rpc/lease_claim');
      final Map<String, Object?> body =
          jsonDecode(claim.body) as Map<String, Object?>;
      expect(body['p_device_id'], _device);
      final String hash = body['p_recovery_code_hash']! as String;
      expect(hash, matches(kRecoveryCodeHashShape));
      expect(recoveryCodeMatches(code, hash), isTrue);
      // 행 둘(덧붙이기) — 대기 → 실행됨 · 둘 다 해시만.
      final List<Map<String, Object?>> rows = r.inbox();
      expect(rows.map((Map<String, Object?> x) => x['state']), <String>[
        'PENDING_LEASE_CONFIRM',
        'EXECUTED',
      ]);
      expect(rows.last['lease_epoch'], 1);
      for (final Map<String, Object?> x in rows) {
        expect(x['payload_digest'], hash);
        for (final Object? v in x.values) {
          expect('$v', isNot(contains(normalizeRecoveryCode(code))));
          expect('$v', isNot(contains(code)));
        }
      }
      final RecoveryCardFact f = r.flow.fact();
      expect(f.done, isTrue);
      expect(f.lines, <String>[RecoveryCardTexts.doneLine]);
      expect(r.flow.issueLines(), isEmpty);
      expect(r.flow.claimedEpoch(), 1);
      // 끝 뒤 = 카드 없음 · 망 0.
      final int before = r.calls.length;
      expect(await r.flow.confirm(code), FirstClaimOutcome.noCard);
      expect(r.calls.length, before);
      expect(r.flow.toString(), isNot(contains(code)));
    });

    test('기기 행 409(이미 있음) = 다음 · 401 = 토큰 한 번 새로 받아 다시', () async {
      final _Rig r = _Rig(db: db)
        ..device = (int i) => i == 0
            ? http.Response('', 401)
            : http.Response('{"code":"23505"}', 409);
      expect(await r.flow.confirm(r.code()), FirstClaimOutcome.claimed);
      final List<http.Request> dev = r.rest
          .where((http.Request q) => q.url.path == '/rest/v1/app_device')
          .toList();
      expect(dev, hasLength(2));
      expect(dev[1].headers['authorization'], 'Bearer ${_access(2)}');
    });

    test('🔴 기기 행 등록 실패(서버 · 거절) = 클레임하지 않는다 · 대기 그대로 · 다시 시도', () async {
      final _Rig r = _Rig(db: db)
        ..device = (int i) =>
            i == 0 ? http.Response('down', 500) : http.Response('', 201);
      expect(await r.flow.confirm(r.code()), FirstClaimOutcome.retryLater);
      expect(
        r.rest.where((http.Request q) => q.url.path.contains('/rpc/')),
        isEmpty,
      );
      expect(r.flow.fact().pending, isTrue);
      expect(await r.flow.retry(), FirstClaimOutcome.claimed);
      final _Rig s = _Rig(db: db, seed: 8)
        ..device = (_) => http.Response('{"code":"42501"}', 403);
      SqliteRecoveryCardStore(db, clock: s.clock).append(
        commandId: 'reset',
        state: RecoveryCardState.rejected,
        hash: issueRecoveryCode(Random(5)).hash,
        rejectCode: 'X',
      );
      expect(await s.flow.confirm(s.code()), FirstClaimOutcome.retryLater);
      expect(
        s.rest.where((http.Request q) => q.url.path.contains('/rpc/')),
        isEmpty,
      );
    });

    test('🔴 epoch > 1 = 예전 카드(이 해시는 서버에 없다) · 끝 · 예전 카드 줄', () async {
      final _Rig r = _Rig(db: db)..rpc = (_) => _row(null, 3, _exp);
      expect(await r.flow.confirm(r.code()), FirstClaimOutcome.existingCard);
      final RecoveryCardFact f = r.flow.fact();
      expect(f.done, isTrue);
      expect(f.lines, <String>[RecoveryCardTexts.existingLine]);
      expect(r.flow.claimedEpoch(), 3);
    });

    test(
      '🔴 서버 거부 = 거부됨(그 카드 무효) · 새 카드(머리 줄) · 다른 기기 = heldByOther',
      () async {
        final _Rig r = _Rig(db: db)
          ..rpc = (_) => _row(LeaseRpcResultCodes.heldByOther, 4, _exp);
        final String first = r.code();
        expect(await r.flow.confirm(first), FirstClaimOutcome.heldByOther);
        expect(r.inbox().last['state'], 'REJECTED');
        expect(r.inbox().last['reject_reason_code'], 'LEASE_HELD_BY_OTHER');
        expect(r.flow.fact().done, isFalse);
        expect(r.flow.fact().pending, isFalse);
        expect(r.flow.claimedEpoch(), 0);
        final List<String> again = r.flow.issueLines();
        expect(again.first, RecoveryCardTexts.reissuedLine);
        expect(r.code(), isNot(first));
        // 그 밖 거부 = refused.
        r.rpc = (_) => _row(LeaseRpcResultCodes.deviceNotEligible, null, null);
        expect(await r.flow.confirm(r.code()), FirstClaimOutcome.refused);
      },
    );

    test('🔴 망 = 대기 그대로(종이 유효) · 다시 시도 = 같은 해시 · 입력 안 봄', () async {
      final _Rig r = _Rig(db: db)
        ..rpc = (int i) =>
            i == 0 ? http.Response('down', 503) : _row(null, 1, _exp);
      final String code = r.code();
      expect(await r.flow.confirm(code), FirstClaimOutcome.retryLater);
      expect(r.inbox().map((Map<String, Object?> x) => x['state']), <String>[
        'PENDING_LEASE_CONFIRM',
      ]);
      final RecoveryCardFact f = r.flow.fact();
      expect(f.pending, isTrue);
      expect(f.lines, <String>[RecoveryCardTexts.pendingLine]);
      expect(r.flow.issueLines(), isEmpty);
      expect(await r.flow.retry(), FirstClaimOutcome.claimed);
      final List<http.Request> claims = r.rest
          .where((http.Request q) => q.url.path.contains('/rpc/'))
          .toList();
      expect(claims, hasLength(2));
      expect(claims[0].body, claims[1].body);
    });

    test('🔴 연결 칸 · 로그인 없음 = notConnected · 대기 행(종이 확인됨) · 망 0', () async {
      final _Rig r = _Rig(db: db, vault: <String, String>{});
      expect(await r.flow.confirm(r.code()), FirstClaimOutcome.notConnected);
      expect(r.calls, isEmpty);
      expect(r.flow.fact().pending, isTrue);
      final _Rig s = _Rig(
        db: db,
        vault: <String, String>{
          'supabase.project_url': _url,
          'supabase.publishable_key': _pub,
        },
      );
      expect(await s.flow.retry(), FirstClaimOutcome.notConnected);
    });

    test('카드 없음(발급 전) = noCard · 겹쳐 누름 = 한 번만 보낸다', () async {
      final _Rig r = _Rig(db: db);
      expect(await r.flow.confirm('ABCD'), FirstClaimOutcome.noCard);
      final String code = r.code();
      final List<FirstClaimOutcome> both = await Future.wait(
        <Future<FirstClaimOutcome>>[r.flow.confirm(code), r.flow.confirm(code)],
      );
      expect(both, <FirstClaimOutcome>[
        FirstClaimOutcome.claimed,
        FirstClaimOutcome.claimed,
      ]);
      expect(r.rest, hasLength(2));
      expect(r.inbox(), hasLength(2));
    });
  });

  group('원격 판정 «쥔 epoch» 대체 · 상태 보존', () {
    late Directory ldir;
    late Database live;
    setUp(() {
      ldir = Directory.systemTemp.createTempSync('aaq_first_claim_live_');
      live = openLocalLedger(
        ldir.path,
        RunMode.live,
        clock: () => DateTime.utc(2026, 12, 8),
      );
    });
    tearDown(() {
      live.close();
      ldir.deleteSync(recursive: true);
    });

    Map<String, Object?>? row() {
      final ResultSet rs = live.select(
        "SELECT * FROM sync_state WHERE target = 'SUPABASE'",
      );
      return rs.isEmpty ? null : Map<String, Object?>.of(rs.first);
    }

    test(
      '🔴 원장 행 없음 + 첫 클레임 기록 = 그 epoch 로 갱신 → LOST → 클레임 한 번 → 유효 · 원장에 적음',
      () async {
        final _Rig r = _Rig(db: db)
          ..rpc = (int i) => i == 0
              ? _row(LeaseRpcResultCodes.lost, 1, _exp)
              : _row(null, 1, _exp);
        final SupabaseLeaseGate g = SupabaseLeaseGate(
          r.client,
          live,
          deviceId: _device,
          clock: r.clock,
          claimedEpoch: () => 1,
        );
        expect(await g.check(), LeaseVerdict.valid);
        final List<http.Request> q = r.rest;
        expect(q[0].url.path, '/rest/v1/rpc/lease_renew');
        expect(jsonDecode(q[0].body), <String, Object?>{
          'p_device_id': _device,
          'p_epoch': 1,
        });
        expect(q[1].url.path, '/rest/v1/rpc/lease_claim');
        expect(
          (jsonDecode(q[1].body)
              as Map<String, Object?>)['p_recovery_code_hash'],
          isNull,
        );
        expect(row()!['operator_epoch'], 1);
        expect(row()!['status'], 'OK');
      },
    );

    test('🔴 기록 0 = 자동 클레임 0 · 망 0 · 원장 행이 있으면 대체를 읽지 않는다', () async {
      final _Rig r = _Rig(db: db)..rpc = (_) => _row(null, 5, _exp);
      int reads = 0;
      final SupabaseLeaseGate none = SupabaseLeaseGate(
        r.client,
        live,
        deviceId: _device,
        clock: r.clock,
        claimedEpoch: () {
          reads++;
          return 0;
        },
      );
      expect(await none.check(), LeaseVerdict.invalid);
      expect(r.calls, isEmpty);
      live.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'OK', 5, '2026-12-08T08:00:00.000Z')",
      );
      reads = 0;
      expect(await none.check(), LeaseVerdict.valid);
      expect(reads, 0);
      expect(jsonDecode(r.rest.single.body), <String, Object?>{
        'p_device_id': _device,
        'p_epoch': 5,
      });
    });

    test('🔴 성공 기록 = 있는 행 상태 그대로(FORK · PUSH_FAILED) · 봉인 = 안 바꿈', () async {
      for (final String status in <String>['FORK', 'PUSH_FAILED', 'SEALED']) {
        live.execute("DELETE FROM sync_state WHERE target = 'SUPABASE'");
        live.execute(
          "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, ?, 2, '2026-12-08T08:00:00.000Z')",
          <Object?>[status],
        );
        final _Rig r = _Rig(db: db)..rpc = (_) => _row(null, 2, _exp);
        final SupabaseLeaseGate g = SupabaseLeaseGate(
          r.client,
          live,
          deviceId: _device,
          clock: r.clock,
        );
        expect(await g.check(), LeaseVerdict.valid, reason: status);
        expect(row()!['status'], status, reason: status);
        expect(
          row()!['last_ok_at'],
          status == 'SEALED' ? isNull : '2026-12-08T09:00:00.000Z',
          reason: status,
        );
      }
    });

    test('기록 저장소 = 마지막 행 · claimedEpoch(실행됨만) · 예전 카드 판정', () {
      final SqliteRecoveryCardStore s = SqliteRecoveryCardStore(
        db,
        clock: _Clock(DateTime.utc(2026, 12, 8)),
      );
      expect(s.latest(), isNull);
      expect(s.claimedEpoch(), 0);
      final String h = issueRecoveryCode(Random(9)).hash;
      s.append(commandId: 'c1', state: RecoveryCardState.pending, hash: h);
      expect(s.claimedEpoch(), 0);
      // 🔴 서버 거부 응답에도 epoch 가 실린다(R221 S2) — 거부 행의 epoch 는 «쥔 epoch» 가 아니다.
      s.append(
        commandId: 'c0',
        state: RecoveryCardState.rejected,
        hash: h,
        epoch: 4,
        rejectCode: 'LEASE_HELD_BY_OTHER',
      );
      expect(s.claimedEpoch(), 0);
      s.append(
        commandId: 'c2',
        state: RecoveryCardState.claimed,
        hash: h,
        epoch: 2,
      );
      expect(s.latest()!.existingCard, isTrue);
      expect(s.claimedEpoch(), 2);
      expect(s.latest().toString(), isNot(contains(h)));
    });
  });
}
