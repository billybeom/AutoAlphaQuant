// 🆕 E16j-b — X1 기기 이전 operator 판(01 §42 · 미결 218 ⓐ ⓑ ⓘ · 212 ②) — 실 SQLite(live 원장) · 엔진 VM · 진행기 · 결과 글자.
//
// 🔴 `run` X1 id 6 — 시작 = D-03 결정 id(`D03-<명령 id>`) · 단계 = 열린 단계만(닫힘 = 오류 · 쓰기 0) · 그만두기 = 엔진 판정 ·
//    비상 시작 · 재발급 · 새 폰 복원 = 오류(막힘 · 지어내지 않는다) · 모의 = `X1_LIVE_ONLY` 글자 · 결과 = `watch` 로 다시 읽힌다.
// 🔴 읽기 = 화면 상태 원장(옛 폰) · live 원장(새 폰 — 없으면 막힘 문장) · 안전 상태 hold = 동결 중만.

import 'dart:async';
import 'dart:math';

import 'package:app_operator_android/app/operator_migration.dart';
import 'package:app_operator_android/app/operator_pledge.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_safety.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show TrustedClock, X1ScreenTexts, kX1D03Card;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

const String _dev = 'dev-op-1';

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

    final OperatorSafetyActions a = actions(r);
    final SafetyActionResult res = await a.run(
      before.startAction!.id,
      args: before.startAction!.args,
    );
    expect((res.level, res.reasonCode), (UiLevel.ok, null));
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
      await expectLater(
        a.run(
          SafetyActionId.x1ReissueRecord,
          args: <String, String>{'run_id': id, 'item': 'KIS_APP_KEY'},
        ),
        throwsUnsupportedError,
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
}
