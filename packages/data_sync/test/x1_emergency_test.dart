// 🆕 E16t3c(설계 13 §8 R244) — X1-3 비상 앞쪽: 새 복구 카드 · 종이 확인 · 기기 행 · `lease_revoke` · 회수 기록 · 재발급 기록 · 화면 재료
// (01 §8 미결 218 ⓒ ⓓ · 06 X1-3 · 08 그림 9-2).
//
// 🔵 잡는 것: ① 새 카드 = 처음 부를 때 발급 · 같은 프로세스 같은 카드 · 종이 확인 전 시작 = RECOVERY_CODE_REQUIRED(망 0) · 빈 코드 = INVALID(망 0)
//    ② 시작 = 기기 행 → `lease_revoke`(옛 코드 평문 · 새 해시) → sim `command_inbox` 회수 행(서버 REVOKED 시각 · epoch · 결정 · 새 해시) ·
//    평문 버림 · 같은 폰 두 번째 = X1_RUN_EXISTS ③ 서버 거부 = 거부 행(감사) · 상태 0 · 새 카드 그대로(같은 해시로 다시) ④ 망 = 기록 0 ·
//    카드 그대로 · 연결 · 로그인 없음 = 계약 글자 ⑤ 🔴 평문 = 원장 어느 칸에도 0 ⑥ 재발급: 회수 판 아님 = FENCING_NOT_STARTED · 해당 없음 ·
//    KEY_REUSED · 신뢰 시각 모름 · 두 번 = 거부 · 받음 = 한 행(지문만) ⑦ 화면: sim 기록 → 펜싱 카드 · 재발급 6행 · live 있음 = 시작 0 ·
//    어긋난 기록 = 저널 깨짐.
// 🔴 실 Supabase 호출 0(MockClient) · 시험 값은 이어 붙여 만든다.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
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
const String _oldCode = 'ABCD-EFGH-JKLM-NPQR-STUV';
// 서버 즉시 만료 시각 = REVOKED(한국 12-08 18:30).
const String _revokedAt = '2026-12-08T09:30:00+00:00';
final DateTime _revoked = DateTime.utc(2026, 12, 8, 9, 30);

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

http.Response _row(Object? code, Object? epoch, Object? exp) => http.Response(
  jsonEncode(<Map<String, Object?>>[
    <String, Object?>{'code': code, 'epoch': epoch, 'expires_at': exp},
  ]),
  200,
);

class _Rig {
  _Rig(this.sim, {Map<String, String>? vault})
    : vault = MemorySecretVault(
        vault ??
            <String, String>{
              'supabase.project_url': _url,
              'supabase.publishable_key': _pub,
              'supabase.refresh_token': _refresh(0),
            },
      );

  final Database sim;
  final MemorySecretVault vault;
  final _Clock clock = _Clock(DateTime.utc(2026, 12, 8, 9, 29));
  final List<http.Request> calls = <http.Request>[];
  int tokenN = 0;

  http.Response Function(int i) device = (_) => http.Response('', 201);
  http.Response Function(int i) rpc = (_) => _row(null, 5, _revokedAt);
  Exception? throwOnRpc;

  List<http.Request> get rpcCalls =>
      calls.where((http.Request r) => r.url.path.contains('/rpc/')).toList();

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
    final Exception? t = throwOnRpc;
    if (t != null) throw t;
    return rpc(rpcCalls.length - 1);
  });
  late final SupabaseAuth auth = SupabaseAuth(net, vault, clock: clock);
  late final SupabaseLeaseRpc client = SupabaseLeaseRpc(net, vault, auth);
  late final SupabaseX1Emergency flow = SupabaseX1Emergency(
    client,
    sim,
    deviceId: _device,
    clock: clock,
    random: Random(11),
  );

  String newCode() => flow
      .cardLines()
      .firstWhere((String l) => l.startsWith('복구 코드: '))
      .substring('복구 코드: '.length);

  List<Map<String, Object?>> rows(String kind) => <Map<String, Object?>>[
    for (final Row r in sim.select(
      'SELECT * FROM command_inbox WHERE kind = ? ORDER BY rowid',
      <Object?>[kind],
    ))
      Map<String, Object?>.of(r),
  ];
}

void main() {
  late Directory dir;
  late Database sim;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_x1_emergency_');
    sim = openLocalLedger(
      dir.path,
      RunMode.simInternal,
      clock: () => DateTime.utc(2026, 12, 8),
    );
  });
  tearDown(() {
    sim.close();
    dir.deleteSync(recursive: true);
  });

  group('비상 시작', () {
    test('🔴 새 카드 = 처음 부를 때 발급 · 같은 카드 · 종이 확인 전 = RECOVERY_CODE_REQUIRED(망 0) · 빈 코드 = INVALID', () async {
      final _Rig rig = _Rig(sim);
      final String code = rig.newCode();
      expect(rig.newCode(), code);
      expect(
        await rig.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
        LeaseRpcResultCodes.recoveryCodeRequired,
      );
      expect(rig.flow.confirmCard('${code}X'), isFalse);
      expect(rig.flow.cardConfirmed, isFalse);
      expect(
        rig.flow.confirmCard(code.toLowerCase().replaceAll('-', ' ')),
        isTrue,
      );
      expect(rig.flow.cardConfirmed, isTrue);
      expect(
        await rig.flow.start(recoveryCode: ' - ', decisionId: 'X1EMG-1'),
        LeaseRpcResultCodes.recoveryCodeInvalid,
      );
      expect(rig.calls, isEmpty);
      expect(
        () => rig.flow.start(recoveryCode: _oldCode, decisionId: ' '),
        throwsArgumentError,
      );
    });

    test('🔴 시작 = 기기 행 → lease_revoke(옛 평문 · 새 해시) → 회수 행 · 평문 버림 · 두 번째 = X1_RUN_EXISTS', () async {
      final _Rig rig = _Rig(sim);
      final String code = rig.newCode();
      rig.flow.confirmCard(code);
      expect(
        await rig.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-c1'),
        isNull,
      );
      final http.Request dev = rig.calls.firstWhere(
        (http.Request r) => r.url.path == '/rest/v1/app_device',
      );
      expect(jsonDecode(dev.body), <String, Object?>{
        'device_id': _device,
        'label': kOperatorDeviceLabel,
        'role': 'viewer',
        'status': 'PENDING',
        'platform': 'android',
        'owner_uid': _uid,
        'auth_uid': _uid,
      });
      final http.Request rpc = rig.rpcCalls.single;
      expect(rpc.url.path, '/rest/v1/rpc/lease_revoke');
      final Map<String, Object?> body =
          jsonDecode(rpc.body) as Map<String, Object?>;
      expect(body['p_device_id'], _device);
      expect(body['p_recovery_code'], _oldCode);
      final String hash = body['p_new_recovery_code_hash']! as String;
      expect(recoveryCodeMatches(code, hash), isTrue);
      final List<Map<String, Object?>> rows = rig.rows(kX1EmergencyRevokeKind);
      expect(rows, hasLength(1));
      expect(rows.single['command_id'], 'rec-2026-12-08-1');
      expect(rows.single['state'], 'EXECUTED');
      expect(rows.single['ingested_at'], _revoked.toIso8601String());
      expect(rows.single['lease_epoch'], 5);
      expect(rows.single['decision_id'], 'X1EMG-c1');
      expect(rows.single['run_mode'], 'LIVE');
      expect(rows.single['payload_digest'], hash);
      // 🔴 평문 0 — 새 코드 · 옛 코드가 원장 어느 칸에도 없다.
      final String dump = jsonEncode(<Object?>[
        for (final Row r in sim.select('SELECT * FROM command_inbox'))
          Map<String, Object?>.of(r),
      ]);
      expect(dump, isNot(contains(normalizeRecoveryCode(code))));
      expect(dump, isNot(contains(normalizeRecoveryCode(_oldCode))));
      expect(rig.flow.cardLines(), isEmpty);
      expect(rig.flow.cardConfirmed, isFalse);
      expect(rig.flow.toString(), isNot(contains(code)));
      expect(
        await rig.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-c2'),
        X1JournalResultCodes.runExists,
      );
      expect(rig.rpcCalls, hasLength(1));
      final X1EmergencyRecord rec = SqliteX1EmergencyStore(sim).latest()!;
      expect(rec.runId, 'rec-2026-12-08-1');
      expect(rec.operatorEpoch, 5);
      expect(rec.revokedAtUtc, _revoked);
      expect(rec.toString(), isNot(contains(hash)));
    });

    test('🔴 서버 거부 = 거부 행(감사) · 상태 0 · 새 카드 그대로(같은 해시로 다시 → 성공)', () async {
      final _Rig rig = _Rig(sim)
        ..rpc = (int i) => i == 0
            ? _row(LeaseRpcResultCodes.recoveryCodeInvalid, null, null)
            : _row(null, 3, _revokedAt);
      final String code = rig.newCode();
      rig.flow.confirmCard(code);
      expect(
        await rig.flow.start(recoveryCode: 'WRONG', decisionId: 'X1EMG-1'),
        LeaseRpcResultCodes.recoveryCodeInvalid,
      );
      final List<Map<String, Object?>> rej = rig.rows(kX1EmergencyRevokeKind);
      expect(rej.single['state'], 'REJECTED');
      expect(
        rej.single['reject_reason_code'],
        LeaseRpcResultCodes.recoveryCodeInvalid,
      );
      expect(rej.single['ingested_at'], rig.clock.now.toIso8601String());
      expect(SqliteX1EmergencyStore(sim).latest(), isNull);
      expect(rig.newCode(), code);
      expect(rig.flow.cardConfirmed, isTrue);
      expect(
        await rig.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-2'),
        isNull,
      );
      final List<String> hashes = <String>[
        for (final http.Request r in rig.rpcCalls)
          (jsonDecode(r.body)
                  as Map<String, Object?>)['p_new_recovery_code_hash']!
              as String,
      ];
      expect(hashes.toSet(), hasLength(1));
      expect(SqliteX1EmergencyStore(sim).latest()!.operatorEpoch, 3);
    });

    test(
      '망 · 서버 = 기록 0 · 카드 그대로 · 연결 없음 · 로그인 없음 = 계약 글자 · 성공인데 시각 없음 = 꼴 아님',
      () async {
        final _Rig net = _Rig(sim)..throwOnRpc = const SocketException('끊김');
        net.flow.confirmCard(net.newCode());
        expect(
          await net.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
          SupabaseTimeResultCodes.network,
        );
        expect(net.rows(kX1EmergencyRevokeKind), isEmpty);
        expect(net.flow.cardConfirmed, isTrue);

        final _Rig srv = _Rig(sim)..rpc = (_) => http.Response('boom', 503);
        srv.flow.confirmCard(srv.newCode());
        expect(
          await srv.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
          SupabaseTimeResultCodes.server,
        );

        final _Rig none = _Rig(sim, vault: <String, String>{});
        none.flow.confirmCard(none.newCode());
        expect(
          await none.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
          SupabaseTimeResultCodes.notConfigured,
        );
        final _Rig out = _Rig(
          sim,
          vault: <String, String>{
            'supabase.project_url': _url,
            'supabase.publishable_key': _pub,
          },
        );
        out.flow.confirmCard(out.newCode());
        expect(
          await out.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
          SupabaseAuthResultCodes.notSignedIn,
        );

        final _Rig odd = _Rig(sim)..rpc = (_) => _row(null, 5, null);
        odd.flow.confirmCard(odd.newCode());
        expect(
          await odd.flow.start(recoveryCode: _oldCode, decisionId: 'X1EMG-1'),
          SupabaseTimeResultCodes.badResponse,
        );
        expect(odd.rows(kX1EmergencyRevokeKind), isEmpty);
      },
    );

    test('실패 종류 6 → 계약 글자(망라)', () {
      expect(
        <String>{
          for (final LeaseRpcFailure f in LeaseRpcFailure.values)
            SupabaseX1Emergency.failureCodeOf(f),
        },
        <String>{
          SupabaseTimeResultCodes.notConfigured,
          SupabaseAuthResultCodes.notSignedIn,
          SupabaseTimeResultCodes.unauthorized,
          SupabaseTimeResultCodes.server,
          SupabaseTimeResultCodes.badResponse,
          SupabaseTimeResultCodes.network,
        },
      );
    });
  });

  group('재발급 기록', () {
    void revoke(SqliteX1EmergencyStore s) => s.recordRevoked(
      runId: 'rec-2026-12-08-1',
      decisionId: 'X1EMG-1',
      operatorEpoch: 5,
      revokedAtUtc: _revoked,
      newCodeHash: 'sha256:${'a' * 32}:${'b' * 64}',
    );
    final DateTime t = _revoked.add(const Duration(minutes: 5));

    test(
      '🔴 회수 판 아님 = FENCING_NOT_STARTED · 해당 없음 · 지문 꼴 · 신뢰 시각 모름 = 거부 · 행 0',
      () {
        final SqliteX1EmergencyStore s = SqliteX1EmergencyStore(sim);
        String? put(
          ReissueItem i,
          String? fp, {
          DateTime? at,
          String run = 'rec-2026-12-08-1',
        }) => s.recordReissue(
          runId: run,
          item: i,
          fingerprint: fp,
          priorFingerprints: const <String>{},
          trustedNowUtc: at,
        );
        expect(
          put(ReissueItem.kisAppKey, '0123abcd', at: t),
          X1FencingResultCodes.notStarted,
        );
        revoke(s);
        expect(
          put(ReissueItem.kisAppKey, '0123abcd', at: t, run: 'rec-other'),
          X1FencingResultCodes.notStarted,
        );
        expect(
          put(ReissueItem.githubPat, '0123abcd', at: t),
          X1ReissueResultCodes.notApplicable,
        );
        expect(
          put(ReissueItem.kisAppKey, null, at: t),
          X1ReissueResultCodes.fingerprintRequired,
        );
        expect(
          put(ReissueItem.supabaseSession, '0123abcd', at: t),
          X1ReissueResultCodes.fingerprintUnexpected,
        );
        expect(
          put(ReissueItem.kisAppKey, '0123abcd'),
          SafetyCommonResultCodes.trustedTimeUnknown,
        );
        expect(
          sim.select('SELECT 1 FROM command_inbox WHERE kind = ?', <Object?>[
            kX1ReissueRecordKind,
          ]),
          isEmpty,
        );
      },
    );

    test('🔴 옛 지문 = KEY_REUSED · 받음 = 한 행(지문만 · 이름 = 판:항목) · 두 번 = 중복 · 확인만 = 빈 지문', () {
      final SqliteX1EmergencyStore s = SqliteX1EmergencyStore(sim);
      revoke(s);
      expect(
        s.recordReissue(
          runId: 'rec-2026-12-08-1',
          item: ReissueItem.kisAppKey,
          fingerprint: '0123abcd',
          priorFingerprints: const <String>{'0123abcd'},
          trustedNowUtc: t,
        ),
        X1ReissueResultCodes.keyReused,
      );
      String? put(ReissueItem i, String? fp) => s.recordReissue(
        runId: 'rec-2026-12-08-1',
        item: i,
        fingerprint: fp,
        priorFingerprints: const <String>{'ffff0000'},
        trustedNowUtc: t,
      );
      expect(put(ReissueItem.kisAppKey, '0123abcd'), isNull);
      expect(
        put(ReissueItem.kisAppKey, '0123abce'),
        X1ReissueResultCodes.duplicate,
      );
      expect(put(ReissueItem.supabaseSession, null), isNull);
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[
        for (final Row r in sim.select(
          'SELECT * FROM command_inbox WHERE kind = ? ORDER BY rowid',
          <Object?>[kX1ReissueRecordKind],
        ))
          Map<String, Object?>.of(r),
      ];
      expect(rows.map((Map<String, Object?> r) => r['command_id']), <String>[
        'rec-2026-12-08-1:KIS_APP_KEY',
        'rec-2026-12-08-1:SUPABASE_SESSION',
      ]);
      expect(rows.first['payload_digest'], '0123abcd');
      expect(rows.last['payload_digest'], '');
      expect(rows.first['ingested_at'], t.toIso8601String());
      expect(rows.first['decision_id'], 'rec-2026-12-08-1');
      final X1EmergencyFacts f = s.facts()!;
      expect(f.checklist.remaining, <ReissueItem>[ReissueItem.watchdogPingKey]);
      expect(
        f.checklist.entries[ReissueItem.supabaseSession]!.fingerprint,
        isNull,
      );
      expect(put(ReissueItem.watchdogPingKey, '9999aaaa'), isNull);
      expect(s.facts()!.checklist.complete, isTrue);
    });

    test('🔴 어긋난 기록(꼴 아닌 epoch · 모르는 항목) = FormatException', () {
      final SqliteX1EmergencyStore s = SqliteX1EmergencyStore(sim);
      revoke(s);
      sim.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, decision_id, payload_digest) '
        "VALUES ('rec-2026-12-08-1:NOPE', ?, ?, 'EXECUTED', '실행됨', 'rec-2026-12-08-1', '')",
        <Object?>[kX1ReissueRecordKind, t.toIso8601String()],
      );
      expect(s.facts, throwsFormatException);
      sim.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, decision_id, lease_epoch, payload_digest) '
        "VALUES ('rec-2026-12-08-2', ?, ?, 'EXECUTED', '실행됨', 'X1EMG-2', 0, 'h')",
        <Object?>[kX1EmergencyRevokeKind, t.toIso8601String()],
      );
      expect(s.latest, throwsFormatException);
    });
  });

  group('화면 재료(SqliteX1Screens.recovery)', () {
    final FencingConfig cfg = FencingConfig(
      margin: const Duration(minutes: 10),
    );

    X1RecoveryVm read({
      Database? live,
      DateTime? trusted,
      MigrationKind kind = MigrationKind.emergency,
    }) =>
        SqliteX1Screens(
          live,
          deviceId: _device,
          runMode: RunMode.live,
          operatingMode: OperatingMode.autoTrade,
          trusted: _Trusted(trusted),
          clock: _Clock(_revoked),
        ).recovery(
          kind,
          kr: frozenExchangeCalendar(Market.kr),
          sim: sim,
          fencing: cfg,
          emergencyRunnable: true,
        );

    test('🔴 기록 0 = 시작 전 VM · 기록 = 펜싱 카드 · 재발급 6행 · 받기 갈래 = 기록 무시', () {
      expect(read().startAction?.id, SafetyActionId.x1EmergencyStart);
      final SqliteX1EmergencyStore s = SqliteX1EmergencyStore(sim)
        ..recordRevoked(
          runId: 'rec-2026-12-08-1',
          decisionId: 'X1EMG-1',
          operatorEpoch: 5,
          revokedAtUtc: _revoked,
          newCodeHash: 'sha256:${'a' * 32}:${'b' * 64}',
        );
      expect(
        s.recordReissue(
          runId: 'rec-2026-12-08-1',
          item: ReissueItem.kisAppKey,
          fingerprint: '0123abcd',
          priorFingerprints: const <String>{},
          trustedNowUtc: _revoked,
        ),
        isNull,
      );
      final X1RecoveryVm vm = read(trusted: _revoked);
      expect(vm.startAction, isNull);
      expect(vm.reasonCode, X1FencingResultCodes.waiting);
      expect(vm.fencing!.endsAtText, '12-09 18:30 부터');
      expect(vm.reissue, hasLength(6));
      expect(vm.reissue.first.stateLabel, X1ScreenTexts.reissueDone);
      expect(
        read(trusted: null).reasonCode,
        SafetyCommonResultCodes.trustedTimeUnknown,
      );
      final X1RecoveryVm passed = read(
        trusted: _revoked.add(const Duration(hours: 24)),
      );
      expect(passed.headline, X1ScreenTexts.emergencyReissue);
      final X1RecoveryVm plan = read(kind: MigrationKind.plan);
      expect(plan.headline, X1ScreenTexts.planBlocked);
      expect(plan.reissue, isEmpty);
    });

    test('live 있음 · 기록 0 = 시작 0(X1_LIVE_EXISTS) · 어긋난 기록 = 저널 깨짐', () {
      final Directory d2 = Directory.systemTemp.createTempSync('aaq_x1e_live_');
      final Database live = openLocalLedger(
        d2.path,
        RunMode.live,
        clock: () => DateTime.utc(2026, 12, 8),
      );
      addTearDown(() {
        live.close();
        d2.deleteSync(recursive: true);
      });
      final X1RecoveryVm vm = read(live: live, trusted: _revoked);
      expect(vm.reasonCode, X1RestoreResultCodes.liveExists);
      expect(vm.startAction, isNull);
      sim.execute(
        'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, decision_id, lease_epoch, payload_digest) '
        "VALUES ('rec-2026-12-08-1', ?, ?, 'EXECUTED', '실행됨', NULL, 5, 'h')",
        <Object?>[kX1EmergencyRevokeKind, _revoked.toIso8601String()],
      );
      final X1RecoveryVm broken = read(trusted: _revoked);
      expect(broken.reasonCode, X1BootRefusalCodes.journalBroken);
      expect(broken.startAction, isNull);
    });
  });
}
