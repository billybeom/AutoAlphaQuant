// E11k-e3 — 리스 판정 조립 자리(설계 13 §8 R229 F8 · R70 D8 · R71 L3).
//
// 🔵 잡는 것: ① simInternal = 원격 원천을 부르지도 않는다(로컬 단독 · 망 0) ② live · simBroker = 원격 판정 ③ 원천 없음 = 실물 전과 같다
//    (live = 모름) ④ 봉인이 원격보다 먼저 ⑤ 조립 앱 묶음: 기기 id 없음 = 흐름 · 원천 둘 다 없음 / 있음 = 원격의 «쥔 epoch» 대체 = 같은
//    흐름의 첫 클레임 기록(sim 원장) → 갱신 RPC 에 그 epoch.

import 'dart:convert';

import 'package:app_operator_android/engine/lease_wiring.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/platform/bootstrap.dart'
    show operatorLeaseParts;
import 'package:core_engine/core_engine.dart' show LeaseGate, LeaseVerdict;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        RecoveryCardState,
        SqliteRecoveryCardStore,
        SupabaseAuth,
        SupabaseLeaseRpc;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'support.dart';

class _Remote implements LeaseGate {
  _Remote(this.verdict);
  final LeaseVerdict verdict;
  int checks = 0;
  @override
  Future<LeaseVerdict> check() async {
    checks++;
    return verdict;
  }
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  setUp(() {
    clock = FakeClock(kst(2026, 12, 8, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  test(
    '🔴 simInternal = 원격 원천을 부르지 않는다(로컬 단독 = 유효) · live · simBroker = 원격 판정',
    () async {
      final List<Database> asked = <Database>[];
      final _Remote remote = _Remote(LeaseVerdict.invalid);
      LeaseGate? of(Database db) {
        asked.add(db);
        return remote;
      }

      expect(leaseRemoteApplies(RunMode.simInternal), isFalse);
      expect(leaseRemoteApplies(RunMode.simBroker), isTrue);
      expect(leaseRemoteApplies(RunMode.live), isTrue);
      expect(
        await operatorLeaseGate(
          files.sim,
          mode: RunMode.simInternal,
          clock: clock,
          remote: of,
        ).check(),
        LeaseVerdict.valid,
      );
      expect(asked, isEmpty);
      for (final RunMode m in <RunMode>[RunMode.simBroker, RunMode.live]) {
        expect(
          await operatorLeaseGate(
            files.sim,
            mode: m,
            clock: clock,
            remote: of,
          ).check(),
          LeaseVerdict.invalid,
          reason: m.wire,
        );
      }
      expect(asked, <Database>[files.sim, files.sim]);
      expect(remote.checks, 2);
    },
  );

  test(
    '원천 없음 = 실물 전과 같다(live · simBroker = 모름) · 봉인 = 원격보다 먼저(원격 0)',
    () async {
      expect(
        await operatorLeaseGate(
          files.sim,
          mode: RunMode.live,
          clock: clock,
        ).check(),
        LeaseVerdict.unknown,
      );
      files.sim.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'SEALED', 1, '2026-12-08T00:00:00.000Z')",
      );
      final _Remote remote = _Remote(LeaseVerdict.valid);
      expect(
        await operatorLeaseGate(
          files.sim,
          mode: RunMode.live,
          clock: clock,
          remote: (_) => remote,
        ).check(),
        LeaseVerdict.invalid,
      );
      expect(remote.checks, 0);
    },
  );

  test('🔴 조립 묶음 — 기기 id 없음 = 둘 다 없음 · 있음 = 원격 «쥔 epoch» 대체 = 첫 클레임 기록(갱신 RPC 에 그 epoch)', () async {
    final List<http.Request> net = <http.Request>[];
    final http.Client client = MockClient((http.Request q) async {
      net.add(q);
      if (q.url.path.startsWith('/auth/')) {
        return http.Response(
          jsonEncode(<String, Object?>{
            'access_token': 'acc-${'A' * 8}',
            'expires_in': 3600,
            'refresh_token': 'ref-${'R' * 8}',
            'user': <String, Object?>{'id': 'uid-1'},
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode(<Map<String, Object?>>[
          <String, Object?>{
            'code': null,
            'epoch': 1,
            'expires_at': '2026-12-08T00:30:00+00:00',
          },
        ]),
        200,
      );
    });
    final MemorySecretVault vault = MemorySecretVault(<String, String>{
      'supabase.project_url': 'https://${'q' * 20}.supabase.co',
      'supabase.publishable_key': 'sb_${'publishable'}_${'K' * 22}',
      'supabase.refresh_token': 'ref-${'R' * 8}',
    });
    final SupabaseLeaseRpc rpc = SupabaseLeaseRpc(
      client,
      vault,
      SupabaseAuth(client, vault, clock: clock),
    );
    final none = operatorLeaseParts(
      rpc: rpc,
      sim: files.sim,
      deviceId: null,
      clock: clock,
    );
    expect(none.firstClaim, isNull);
    expect(none.leaseRemote, isNull);
    final parts = operatorLeaseParts(
      rpc: rpc,
      sim: files.sim,
      deviceId: '0f1e2d3c-4b5a-4978-8a6b-5c4d3e2f1a0b',
      clock: clock,
    );
    expect(parts.firstClaim, isNotNull);
    final Database live = writeLiveMode(tempLedgerDir(), clock);
    addTearDown(live.close);
    // 기록 0 = 자동 클레임 0 · 망 0.
    expect(
      await operatorLeaseGate(
        live,
        mode: RunMode.live,
        clock: clock,
        remote: parts.leaseRemote,
      ).check(),
      LeaseVerdict.invalid,
    );
    expect(net, isEmpty);
    SqliteRecoveryCardStore(files.sim, clock: clock).append(
      commandId: 'rc-1',
      state: RecoveryCardState.claimed,
      hash: 'sha256:${'a' * 32}:${'b' * 64}',
      epoch: 1,
    );
    expect(
      await operatorLeaseGate(
        live,
        mode: RunMode.live,
        clock: clock,
        remote: parts.leaseRemote,
      ).check(),
      LeaseVerdict.valid,
    );
    final http.Request renew = net.firstWhere(
      (http.Request q) => q.url.path.contains('/rpc/'),
    );
    expect(renew.url.path, '/rest/v1/rpc/lease_renew');
    expect(jsonDecode(renew.body), <String, Object?>{
      'p_device_id': '0f1e2d3c-4b5a-4978-8a6b-5c4d3e2f1a0b',
      'p_epoch': 1,
    });
    expect(
      live
          .select(
            "SELECT operator_epoch FROM sync_state WHERE target = 'SUPABASE'",
          )
          .single['operator_epoch'],
      1,
    );
  });
}
