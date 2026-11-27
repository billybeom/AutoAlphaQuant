// 🆕 E16j-b — X1 기기 이전 operator 판(01 §42 · 미결 218 ⓐ ⓑ ⓘ · 212 ②) — 실 SQLite(live 원장) · 엔진 VM · 진행기 · 결과 글자.
//
// 🔴 `run` X1 id 6 — 시작 = D-03 결정 id(`D03-<명령 id>`) · 단계 = 열린 단계만(닫힘 = 오류 · 쓰기 0) · 그만두기 = 엔진 판정 ·
//    비상 시작 · 재발급 · 새 폰 복원 = 오류(막힘 · 지어내지 않는다) · 모의 = `X1_LIVE_ONLY` 글자 · 결과 = `watch` 로 다시 읽힌다.
// 🔴 읽기 = 화면 상태 원장(옛 폰) · live 원장(새 폰 — 없으면 막힘 문장) · 안전 상태 hold = 동결 중만.
// 🆕 E16t3c(R244) — 비상 앞쪽: 시작 = 옛 종이 코드(슬롯 칸 · 한 번 쓰고 비움) + 새 카드 → 기기 행 → `lease_revoke`(MockClient · 실 호출 0) →
//    sim 회수 행(결정 id `X1EMG-`) → 화면 = 펜싱 · 재발급 6행 · 재발급 = 값 → 지문만 · 이 폰 금고 옛 지문 = KEY_REUSED · live 있음 = 시작 0.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_operator_android/app/operator_migration.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_safety.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart'
    show X1SecretDraftSource;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        OperationsConfig,
        TrustedClock,
        X1ScreenTexts,
        kX1D03Card,
        kX1EmergencyRevokeKind,
        kX1ReissueRecordKind,
        secretFingerprint;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show SupabaseAuth, SupabaseLeaseRpc, SupabaseX1Emergency;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

const String _dev = 'dev-op-1';

/// 🆕 E16t3c — 슬롯 칸 대신(값 = 이 객체에만 · 비우기를 센다).
class _Draft implements X1SecretDraftSource {
  _Draft(this.value);
  String? value;
  int clears = 0;
  @override
  String? current() => value;
  @override
  void clear() {
    clears++;
    value = null;
  }
}

void main() {
  tearDownAll(deleteTempDirs);
  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;
  setUp(() {
    clock = FakeClock(kst(2027, 2, 10, 10, 0));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(DateTime.utc(2027, 2, 10, 1));
  });
  tearDown(() => files.close());

  FeatureFlags flags(RunMode mode) => FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: mode,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg',
  );

  Database live() {
    final Database db = files.openLive();
    db.execute(
      "INSERT OR IGNORE INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'OK', 2, 'u0')",
    );
    return db;
  }

  OperatorRuntime rt({bool liveView = true, String? device = _dev}) {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: trusted,
      deviceId: device,
    );
    r.view.value = liveView
        ? OperatorView(db: live(), flags: flags(RunMode.live))
        : OperatorView(db: files.sim, flags: flags(RunMode.simInternal));
    return r;
  }

  OperatorSafetyActions actions(OperatorRuntime r) =>
      OperatorSafetyActions(r, random: Random(7));

  Future<T> first<T>(Stream<T> s) => s.first;

  String runId(Database db) =>
      db.select('SELECT run_id FROM migration_run').single['run_id'] as String;

  test('🔴 시작 전 = 엔진 VM(D-03 · 시작) · 시작 = D-03 결정 id · epoch · 결과 글자 · watch 같은 결과 · 화면이 9행으로', () async {
    final OperatorRuntime r = rt();
    final OperatorMigrationRepository repo = OperatorMigrationRepository(r);
    final X1PlanWizardVm before = await first(repo.watchPlanWizard());
    expect(before.d03Card, kX1D03Card);
    expect(before.startAction?.id, SafetyActionId.x1PlanStart);

    // 🆕 리뷰 3차 H1(R261) — 이전 시작 = 표시 hold(`MIGRATION_IN_PROGRESS`) 전이 → 엔진 깨어남 한 번(FGS).
    int wakes = 0;
    r.attachWake(() async => wakes++);
    final OperatorSafetyActions a = actions(r);
    final SafetyActionResult res = await a.run(
      before.startAction!.id,
      args: before.startAction!.args,
    );
    expect((res.level, res.reasonCode), (UiLevel.ok, null));
    expect(wakes, 1);
    expect(res.headline, X1ScreenTexts.accepted(SafetyActionId.x1PlanStart));
    expect(await a.watch(res.actionRunId).first, res);
    final Database db = r.view.value!.db;
    final row = db
        .select(
          'SELECT decision_id, operator_epoch, device_id FROM migration_run',
        )
        .single;
    expect((row['decision_id'] as String).startsWith('D03-'), isTrue);
    expect(row['operator_epoch'], 2);
    expect(row['device_id'], _dev);

    final X1PlanWizardVm after = await first(repo.watchPlanWizard());
    expect(after.rows, hasLength(9));
    expect(after.rows.first.actions.first.args['run_id'], runId(db));
  });

  test(
    '🔴 동결 = 창 열림 · hold · 미체결 막힘 = 다시 가능 글자 · 그만두기 = 창 닫힘 · hold 꺼짐',
    () async {
      final OperatorRuntime r = rt();
      final OperatorSafetyActions a = actions(r);
      await a.run(SafetyActionId.x1PlanStart);
      final Database db = r.view.value!.db;
      final String id = runId(db);
      final SafetyActionResult f = await a.run(
        SafetyActionId.x1PlanStep,
        args: <String, String>{'run_id': id, 'step': 'FREEZE'},
      );
      expect(f.reasonCode, isNull);
      expect(
        db.select('SELECT event FROM maintenance_window').single['event'],
        'OPENED',
      );
      expect(OperatorSafetyRepository(r).state().holds, <String>[
        SafetyHoldCodes.migrationInProgress,
      ]);

      db.execute(
        'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
        "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES ('i1', 'k1', 'x', "
        "'2027-02-10', 'KR', 'pension', 'P0S_B', 'B@2027-02-10', '133690', 'BUY', 'LIMIT', 1, 'SUBMITTED', 'c', 'x', 'LIVE')",
      );
      final SafetyActionResult blocked = await a.run(
        SafetyActionId.x1PlanStep,
        args: <String, String>{'run_id': id, 'step': 'ORDERS_CLEARED'},
      );
      expect(
        (blocked.level, blocked.reasonCode, blocked.retryable),
        (UiLevel.blocked, X1StepBlockCodes.openOrders, true),
      );
      final SafetyActionResult ab = await a.run(
        SafetyActionId.x1PlanAbort,
        args: <String, String>{'run_id': id, 'step': 'ORDERS_CLEARED'},
      );
      expect(ab.reasonCode, isNull);
      expect(ab.headline, X1ScreenTexts.accepted(SafetyActionId.x1PlanAbort));
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM maintenance_window WHERE event = 'CLOSED'",
            )
            .single['n'],
        1,
      );
      expect(OperatorSafetyRepository(r).state().holds, isEmpty);
    },
  );

  test(
    '🔴 닫힌 단계 · 비상 · 재발급 · 새 폰 복원 = 오류(쓰기 0) · args 없음 = ArgumentError',
    () async {
      final OperatorRuntime r = rt();
      final OperatorSafetyActions a = actions(r);
      await a.run(SafetyActionId.x1PlanStart);
      final Database db = r.view.value!.db;
      final String id = runId(db);
      for (final String s in <String>[
        'FREEZE',
        'ORDERS_CLEARED',
        'RECON_ZERO',
      ]) {
        expect(
          (await a.run(
            SafetyActionId.x1PlanStep,
            args: <String, String>{'run_id': id, 'step': s},
          )).reasonCode,
          isNull,
          reason: s,
        );
      }
      final int steps =
          db.select('SELECT COUNT(*) AS n FROM migration_step').single['n']
              as int;
      await expectLater(
        a.run(
          SafetyActionId.x1PlanStep,
          args: <String, String>{'run_id': id, 'step': 'BACKUP_CHECKSUM'},
        ),
        throwsUnsupportedError,
      );
      await expectLater(
        a.run(SafetyActionId.x1EmergencyStart),
        throwsUnsupportedError,
      );
      // 🆕 E16t3c — 재발급 = 회수 판이 아니면 엔진 거부(쓰기 0) · 비상 시작 = 조립 없음(기기 id · Supabase) = 오류.
      expect(
        (await a.run(
          SafetyActionId.x1ReissueRecord,
          args: <String, String>{'run_id': id, 'item': 'KIS_APP_KEY'},
        )).reasonCode,
        X1FencingResultCodes.notStarted,
      );
      await expectLater(
        a.run(
          SafetyActionId.x1RecoveryStep,
          args: <String, String>{'run_id': id, 'step': 'RESTORED'},
        ),
        throwsUnsupportedError,
      );
      await expectLater(
        a.run(SafetyActionId.x1PlanStep, args: const <String, String>{}),
        throwsArgumentError,
      );
      expect(
        db.select('SELECT COUNT(*) AS n FROM migration_step').single['n'],
        steps,
      );
      final SafetyActionResult past = await a.run(
        SafetyActionId.x1PlanAbort,
        args: <String, String>{'run_id': id, 'step': 'DEMOTED'},
      );
      expect(past.reasonCode, X1JournalResultCodes.pastNoReturn);
    },
  );

  test('모의 화면 = 엔진 X1_LIVE_ONLY(VM · 시작 결과) · 쓰기 0', () async {
    final OperatorRuntime r = rt(liveView: false);
    int wakes = 0;
    r.attachWake(() async => wakes++);
    final X1PlanWizardVm vm = await first(
      OperatorMigrationRepository(r).watchPlanWizard(),
    );
    expect(vm.reasonCode, X1StartResultCodes.liveOnly);
    final SafetyActionResult res = await actions(r)
        .run(SafetyActionId.x1PlanStart);
    expect(
      (res.level, res.reasonCode),
      (UiLevel.info, X1StartResultCodes.liveOnly),
    );
    expect(wakes, 0, reason: '🆕 R261 — 거부 = 깨어남 0');
    expect(
      files.sim.select('SELECT COUNT(*) AS n FROM migration_run').single['n'],
      0,
    );
  });

  test('새 폰 — live 원장 없음 · 복구 없음 = 갈래별 막힘 문장 · 동작 0', () async {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: trusted,
      deviceId: 'dev-new',
    );
    final OperatorMigrationRepository repo = OperatorMigrationRepository(r);
    final X1RecoveryVm p = await first(repo.watchPlanRecovery());
    final X1RecoveryVm e = await first(repo.watchEmergencyRecovery());
    expect(p.headline, X1ScreenTexts.planBlocked);
    expect(e.headline, X1ScreenTexts.emergencyBlocked);
    for (final X1RecoveryVm vm in <X1RecoveryVm>[p, e]) {
      expect(vm.startAction, isNull);
      expect(vm.steps, isEmpty);
    }
    live();
    expect(
      (await first(repo.watchPlanRecovery())).noticeText,
      X1ScreenTexts.planBlockedNotice,
    );
  });

  test('기기 id 없음 = 막힘 VM · 동작 = StateError', () async {
    final OperatorRuntime r = rt(device: null);
    final X1PlanWizardVm vm = await first(
      OperatorMigrationRepository(r).watchPlanWizard(),
    );
    expect(vm.headline, X1ScreenTexts.noDevice);
    await expectLater(
      actions(r).run(SafetyActionId.x1PlanStart),
      throwsStateError,
    );
  });

  test(
    'X1 밖 id 는 그대로(규칙 변경 취소 args 없음 = ArgumentError) · X1 id 6 집합',
    () async {
      expect(kX1ActionIds, hasLength(6));
      await expectLater(
        actions(rt()).run(SafetyActionId.ruleChangeCancel),
        throwsArgumentError,
      );
      unawaited(Future<void>.value());
    },
  );

  test('🆕 미결 243 ⓑ(R276 · K350) — X1 복구 생체 단계 = 대화상자 «이 폰에서 운영 이어받기» · 할 수 없음 = BIOMETRIC_UNAVAILABLE', () async {
    live();
    final List<BiometricPurpose> asked = <BiometricPurpose>[];
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      trusted: trusted,
      deviceId: _dev,
      operations: OperationsConfig.fromJson(<String, Object?>{
        'migration': <String, Object?>{
          'observation_trading_days': <String, Object?>{
            'plan': 5,
            'emergency': 10,
          },
        },
      }),
      biometricSign: (BiometricPurpose p) async {
        asked.add(p);
        return BiometricOutcome.unavailable;
      },
    );
    final SafetyActionResult res = await actions(r).run(
      SafetyActionId.x1RecoveryStep,
      args: <String, String>{'step': 'BIOMETRIC_CONFIRMED'},
    );
    expect(res.reasonCode, SettingsResultCodes.biometricUnavailable);
    expect(asked, <BiometricPurpose>[BiometricPurpose.x1Migration]);
  });

  group('🆕 E16t3c 비상 앞쪽', () {
    final String url = 'https://${'q' * 12}${'7' * 8}.supabase.co';
    final String pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
    final String oldKis = 'PS${'k' * 34}';

    ({OperatorRuntime rt, SupabaseX1Emergency flow, List<http.Request> calls})
    rig() {
      final List<http.Request> calls = <http.Request>[];
      final MemorySecretVault vault = MemorySecretVault(<String, String>{
        'supabase.project_url': url,
        'supabase.publishable_key': pub,
        'supabase.refresh_token': 'ref-${'R' * 10}-0',
        'kis.live.app_key': oldKis,
      });
      final http.Client net = MockClient((http.Request r) async {
        calls.add(r);
        if (r.url.path.startsWith('/auth/')) {
          return http.Response(
            jsonEncode(<String, Object?>{
              'access_token': 'acc-${'A' * 10}',
              'expires_in': 3600,
              'refresh_token': 'ref-${'R' * 10}-1',
              'user': <String, Object?>{
                'id': '11111111-2222-4333-8444-555555555555',
              },
            }),
            200,
          );
        }
        if (r.url.path == '/rest/v1/app_device') return http.Response('', 201);
        return http.Response(
          jsonEncode(<Map<String, Object?>>[
            <String, Object?>{
              'code': null,
              'epoch': 3,
              'expires_at': '2027-02-10T01:00:00+00:00',
            },
          ]),
          200,
        );
      });
      final SupabaseLeaseRpc rpc = SupabaseLeaseRpc(
        net,
        vault,
        SupabaseAuth(net, vault, clock: clock),
      );
      final SupabaseX1Emergency flow = SupabaseX1Emergency(
        rpc,
        files.sim,
        deviceId: 'dev-new',
        clock: clock,
        random: Random(3),
      );
      final OperatorRuntime r = OperatorRuntime(
        files: files,
        clock: clock,
        trusted: trusted,
        deviceId: 'dev-new',
        vault: vault,
        x1Emergency: flow,
      );
      return (rt: r, flow: flow, calls: calls);
    }

    String newCode(SupabaseX1Emergency f) => f
        .cardLines()
        .firstWhere((String l) => l.startsWith('복구 코드: '))
        .substring('복구 코드: '.length);

    test('🔴 시작 = 옛 코드(한 번 · 비움) + 새 카드 → revoke → 회수 행 → 펜싱 · 재발급 6행 · 재발급 = 지문만 · 이 폰 옛 지문 = KEY_REUSED', () async {
      final ({
        OperatorRuntime rt,
        SupabaseX1Emergency flow,
        List<http.Request> calls,
      })
      g = rig();
      final OperatorMigrationRepository repo = OperatorMigrationRepository(
        g.rt,
      );
      final X1RecoveryVm start = await first(repo.watchEmergencyRecovery());
      expect(start.startAction?.id, SafetyActionId.x1EmergencyStart);
      expect(start.recoveryCodeSlotId, X1SlotIds.recoveryCode);

      final OperatorSafetyActions a = actions(g.rt);
      // 새 카드 확인 전 = 엔진 거부 · 옛 코드 칸은 그래도 비운다 · 망 0.
      final _Draft old = _Draft('ABCD-EFGH-JKLM-NPQR-STUV');
      g.rt.secrets.attachX1RecoveryCode(old);
      expect(
        (await a.run(start.startAction!.id)).reasonCode,
        LeaseRpcResultCodes.recoveryCodeRequired,
      );
      expect(old.clears, 1);
      expect(g.calls, isEmpty);

      g.flow.confirmCard(newCode(g.flow));
      old.value = 'ABCD-EFGH-JKLM-NPQR-STUV';
      final SafetyActionResult ok = await a.run(start.startAction!.id);
      expect((ok.level, ok.reasonCode), (UiLevel.ok, null));
      expect(
        ok.headline,
        X1ScreenTexts.accepted(SafetyActionId.x1EmergencyStart),
      );
      expect(old.value, isNull);
      final Map<String, Object?> body = jsonDecode(
        g.calls
            .firstWhere(
              (http.Request r) => r.url.path.endsWith('/lease_revoke'),
            )
            .body,
      ) as Map<String, Object?>;
      expect(body['p_recovery_code'], 'ABCD-EFGH-JKLM-NPQR-STUV');
      expect(body['p_device_id'], 'dev-new');
      final row = files.sim.select(
        'SELECT command_id, decision_id, lease_epoch FROM command_inbox WHERE kind = ?',
        <Object?>[kX1EmergencyRevokeKind],
      ).single;
      expect((row['decision_id'] as String).startsWith('X1EMG-'), isTrue);
      expect(row['lease_epoch'], 3);
      final String runId = row['command_id'] as String;

      final X1RecoveryVm fencing = await first(repo.watchEmergencyRecovery());
      expect(fencing.startAction, isNull);
      expect(fencing.fencing, isNotNull);
      expect(fencing.reissue, hasLength(6));
      final X1ReissueRow kis = fencing.reissue.first;
      expect(kis.reissueSlotId, X1SlotIds.reissueSecret);
      final SafetyActionCall record = kis.recordAction!;
      expect(record.args, <String, String>{
        'run_id': runId,
        'item': 'KIS_APP_KEY',
      });

      // 이 폰 금고의 옛 앱키와 같은 값 = KEY_REUSED · 칸 비움 · 행 0.
      final _Draft v = _Draft(oldKis);
      g.rt.secrets.attachX1Reissue(v);
      expect(
        (await a.run(record.id, args: record.args)).reasonCode,
        X1ReissueResultCodes.keyReused,
      );
      expect(v.value, isNull);
      // 칸 비어 있음 = 지문 필요.
      expect(
        (await a.run(record.id, args: record.args)).reasonCode,
        X1ReissueResultCodes.fingerprintRequired,
      );
      // 새 값 = 받음 · 지문만.
      final String fresh = 'PS${'n' * 34}';
      v.value = fresh;
      expect((await a.run(record.id, args: record.args)).reasonCode, isNull);
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[
        for (final r in files.sim.select(
          'SELECT command_id, payload_digest FROM command_inbox WHERE kind = ?',
          <Object?>[kX1ReissueRecordKind],
        ))
          Map<String, Object?>.of(r),
      ];
      expect(rows.single['command_id'], '$runId:KIS_APP_KEY');
      expect(rows.single['payload_digest'], secretFingerprint(fresh));
      final String dump = jsonEncode(<Object?>[
        for (final r in files.sim.select('SELECT * FROM command_inbox'))
          Map<String, Object?>.of(r),
      ]);
      expect(dump, isNot(contains(fresh)));
      expect(dump, isNot(contains('ABCDEFGHJKLMNPQRSTUV')));
      // 확인만 항목(값 칸 무시) · 신뢰 시각 모름 = 거부.
      trusted.at = null;
      expect(
        (await a.run(
          SafetyActionId.x1ReissueRecord,
          args: <String, String>{'run_id': runId, 'item': 'SUPABASE_SESSION'},
        )).reasonCode,
        SafetyCommonResultCodes.trustedTimeUnknown,
      );
      trusted.at = DateTime.utc(2027, 2, 10, 1);
      v.value = 'ignored';
      expect(
        (await a.run(
          SafetyActionId.x1ReissueRecord,
          args: <String, String>{'run_id': runId, 'item': 'SUPABASE_SESSION'},
        )).reasonCode,
        isNull,
      );
      expect(v.value, isNull);
      final X1RecoveryVm after = await first(repo.watchEmergencyRecovery());
      expect(
        after.reissue
            .where((X1ReissueRow r) => r.recordAction != null)
            .map((X1ReissueRow r) => r.code),
        <String>['WATCHDOG_PING_KEY'],
      );
      await expectLater(
        a.run(
          SafetyActionId.x1ReissueRecord,
          args: const <String, String>{'run_id': 'x', 'item': 'NOPE'},
        ),
        throwsArgumentError,
      );
    });

    test(
      '🔴 live 원장 있음 = 시작 0(X1_LIVE_EXISTS · 옛 코드 비움 · 망 0) · 화면 = 시작 없음',
      () async {
        final ({
          OperatorRuntime rt,
          SupabaseX1Emergency flow,
          List<http.Request> calls,
        })
        g = rig();
        live();
        final X1RecoveryVm vm = await first(
          OperatorMigrationRepository(g.rt).watchEmergencyRecovery(),
        );
        expect(vm.reasonCode, X1RestoreResultCodes.liveExists);
        expect(vm.startAction, isNull);
        g.flow.confirmCard(newCode(g.flow));
        final _Draft old = _Draft('ABCD-EFGH-JKLM-NPQR-STUV');
        g.rt.secrets.attachX1RecoveryCode(old);
        expect(
          (await actions(g.rt).run(SafetyActionId.x1EmergencyStart)).reasonCode,
          X1RestoreResultCodes.liveExists,
        );
        expect(old.value, isNull);
        expect(g.calls, isEmpty);
      },
    );
  });
}
