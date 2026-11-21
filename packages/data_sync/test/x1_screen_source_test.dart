// 🆕 E16j-b — X1 화면 원천 · 옛 폰 단계 진행기 · 표시 hold(01 §42 · 미결 218 ⓐ ⓑ · 212 ②).
//
// 🔵 잡는 것: ① 읽기 = 이 기기 저널 → 엔진 VM(시작 전 · 모의 · 기기 id 없음 · 깨짐) ② 진행기 = 시작(D-03 결정 · epoch) · 동결 = 창 열기
//    (바깥 감시 있으면 그 모드 체크만 멈춤 · engine_alive 0 · 없으면 창 기록만) · 미체결 막힘(단계 들어간 채) · 풀리면 끝
//    ③ 🔴 그만두기 = 들어간 뒤 FAILED + 창 닫기 · DEMOTED 이후 = 쓰기 0 · 닫힌 단계 진행 = UnsupportedError(쓰기 0)
//    ④ hold = 동결 ~ 끝 전 · 그만두면 꺼짐 · 새 폰 복구 ~ 생체 전 · 깨짐 = 켬 · 안전 상태 `holds`(live ∧ 기기 id 만)
//    ⑤ 새 폰 = 원장 없음 · 복구 없음 = 막힘 문장 · 복구 있음 = 복원 카드 · 갭 막힘 · 사다리 기준 이상 = RECOVERY_FULL.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 한국 11-21 10:00.
final DateTime _t0 = DateTime.utc(2026, 11, 21, 1);
const String _dev = 'dev-old';

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_x1s_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    db.execute(
      "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'OK', 3, 'u0')",
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  int count(String sql, [List<Object?> args = const <Object?>[]]) =>
      db.select(sql, args).single['n'] as int;

  SqliteX1Screens screens({
    Database? on,
    String? device = _dev,
    RunMode mode = RunMode.live,
  }) => SqliteX1Screens(
    on ?? db,
    deviceId: device,
    runMode: mode,
    operatingMode: OperatingMode.autoTrade,
    trusted: trusted,
    clock: clock,
  );

  SqliteX1PlanStepper stepper({WatchdogRemote? watchdog}) =>
      SqliteX1PlanStepper(
        db,
        deviceId: _dev,
        runMode: RunMode.live,
        trusted: trusted,
        clock: clock,
        watchdog: watchdog,
      );

  void intent(String id, String status) => db.execute(
    'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
    "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
    "'2026-11-21', 'KR', 'pension', 'P0S_B', 'B@2026-11-21', '133690', 'BUY', 'LIMIT', 1, ?, 'c', 'x', 'LIVE')",
    <Object?>[id, 'k-$id', status],
  );

  String start() {
    final ({String? runId, String? code}) r = stepper().start(
      operatingMode: OperatingMode.autoTrade,
      decisionId: 'D03-c1',
    );
    expect(r.code, isNull);
    return r.runId!;
  }

  group('읽기', () {
    test(
      '시작 전 = D-03 한 장 + 시작 · 모의 = X1_LIVE_ONLY · 기기 id 없음 = 막힘 · 원장 없음 = 막힘',
      () {
        final X1PlanWizardVm vm = screens().planWizard();
        expect(vm.d03Card, kX1D03Card);
        expect(vm.startAction?.id, SafetyActionId.x1PlanStart);
        expect(
          screens(mode: RunMode.simInternal).planWizard().reasonCode,
          X1StartResultCodes.liveOnly,
        );
        expect(
          screens(device: null).planWizard().headline,
          X1ScreenTexts.noDevice,
        );
        expect(
          SqliteX1Screens(
            null,
            deviceId: _dev,
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
            trusted: trusted,
            clock: clock,
          ).planWizard().startAction,
          isNull,
        );
      },
    );

    test('🔴 저널 깨짐(모르는 단계 글자) = X1_JOURNAL_BROKEN · 동작 0 · hold 켬', () {
      final String run = start();
      db.execute(
        "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, 'NOPE', 'ENTERED', NULL, 'x')",
        <Object?>[run],
      );
      final X1PlanWizardVm vm = screens().planWizard();
      expect(vm.reasonCode, X1BootRefusalCodes.journalBroken);
      expect(vm.startAction, isNull);
      expect(vm.rows, isEmpty);
      expect(migrationInProgressOf(db, _dev), isTrue);
    });
  });

  group('진행기', () {
    test('🔴 시작 = D-03 결정 id · epoch = 리스 세대 · 다시 시작 = X1_RUN_EXISTS · 결정 비움 = ArgumentError', () {
      final String run = start();
      final Row r = db.select('SELECT * FROM migration_run').single;
      expect(r['run_id'], run);
      expect(r['decision_id'], 'D03-c1');
      expect(r['operator_epoch'], 3);
      expect(r['role'], 'OLD_DEVICE');
      expect(
        stepper()
            .start(operatingMode: OperatingMode.autoTrade, decisionId: 'D03-c2')
            .code,
        X1JournalResultCodes.runExists,
      );
      expect(
        () => stepper().start(
          operatingMode: OperatingMode.autoTrade,
          decisionId: ' ',
        ),
        throwsArgumentError,
      );
      final X1PlanWizardVm vm = screens().planWizard();
      expect(vm.rows.first.actions.first.args, <String, String>{
        'run_id': run,
        'step': 'FREEZE',
      });
    });

    test('신뢰 시각 모름 = 시작 거부(쓰기 0)', () {
      trusted.at = null;
      expect(
        stepper()
            .start(operatingMode: OperatingMode.autoTrade, decisionId: 'D03-c1')
            .code,
        SafetyCommonResultCodes.trustedTimeUnknown,
      );
      expect(count('SELECT COUNT(*) AS n FROM migration_run'), 0);
    });

    test('🔴 동결 = 창 열기(바깥 감시 없음 = 멈춘 체크 0) · 창 글자 · 다음 차례 · hold 켬', () async {
      final String run = start();
      expect(migrationInProgressOf(db, _dev), isFalse, reason: '시작만 = 동결 전');
      expect(
        await stepper().step(
          run,
          PlanStep.freeze,
          operatingMode: OperatingMode.autoTrade,
        ),
        isNull,
      );
      final Row w = db
          .select('SELECT run_id, event, checks_json FROM maintenance_window')
          .single;
      expect(
        (w['run_id'], w['event'], w['checks_json']),
        (run, 'OPENED', '[]'),
      );
      final X1PlanWizardVm vm = screens().planWizard();
      expect(vm.windowText, X1ScreenTexts.window('11-21 10:00'));
      expect(vm.rows.first.stateLabel, X1ScreenTexts.stateDone);
      expect(vm.rows[1].stateLabel, X1ScreenTexts.stateTurn);
      expect(migrationInProgressOf(db, _dev), isTrue);
      // 다시 = 쓰기 0(차례 아님).
      expect(
        await stepper().step(
          run,
          PlanStep.freeze,
          operatingMode: OperatingMode.autoTrade,
        ),
        X1JournalResultCodes.stepOutOfOrder,
      );
    });

    test('동결 · 바깥 감시 = 그 모드 잡 체크만 멈춤(engine_alive · 다른 모드 0)', () async {
      final FakeWatchdogRemote remote = FakeWatchdogRemote(
        initial: <RemoteCheck>[
          for (final String s in <String>[
            'live-auto-kr_order',
            'engine_alive',
            'sim-auto-kr_order',
          ])
            RemoteCheck(slug: s, status: RemoteCheckStatus.up),
        ],
      );
      final String run = start();
      expect(
        await stepper(watchdog: remote)
            .step(run, PlanStep.freeze, operatingMode: OperatingMode.autoTrade),
        isNull,
      );
      expect(
        db
            .select('SELECT checks_json FROM maintenance_window')
            .single['checks_json'],
        '["live-auto-kr_order"]',
      );
      expect(
        remote.calls.where((String c) => c.startsWith('pause:')),
        hasLength(1),
      );
    });

    test('바깥 감시 목록 못 읽음 = 창 기록만(동결은 끝난다)', () async {
      final FakeWatchdogRemote remote = FakeWatchdogRemote();
      remote.failOn[('checks', '*')] = Exception('x');
      final String run = start();
      expect(
        await stepper(watchdog: remote)
            .step(run, PlanStep.freeze, operatingMode: OperatingMode.autoTrade),
        isNull,
      );
      expect(
        db
            .select('SELECT checks_json FROM maintenance_window')
            .single['checks_json'],
        '[]',
      );
    });

    test(
      '🔴 미체결 = OPEN_ORDERS_REMAIN · 단계는 들어간 채 · VM 막힘 · 풀리면 다시 눌러 끝',
      () async {
        final String run = start();
        await stepper().step(
          run,
          PlanStep.freeze,
          operatingMode: OperatingMode.autoTrade,
        );
        intent('i1', 'SUBMITTED');
        expect(
          await stepper().step(
            run,
            PlanStep.ordersCleared,
            operatingMode: OperatingMode.autoTrade,
          ),
          X1StepBlockCodes.openOrders,
        );
        expect(
          count(
            "SELECT COUNT(*) AS n FROM migration_step WHERE step = 'ORDERS_CLEARED' AND state = 'ENTERED'",
          ),
          1,
        );
        final X1PlanWizardVm vm = screens().planWizard();
        expect(vm.reasonCode, X1StepBlockCodes.openOrders);
        expect(vm.rows[1].lines, <String>[X1ScreenTexts.openOrdersLine(1)]);
        expect(vm.rows[1].actions.single.id, SafetyActionId.x1PlanAbort);
        db.execute("UPDATE order_intents SET status = 'FILLED'");
        expect(
          await stepper().step(
            run,
            PlanStep.ordersCleared,
            operatingMode: OperatingMode.autoTrade,
          ),
          isNull,
        );
        expect(
          screens().planWizard().rows[2].stateLabel,
          X1ScreenTexts.stateTurn,
        );
      },
    );

    test('🔴 그만두기 = FAILED + 창 닫힘 · hold 꺼짐 · VM = 다시 D-03', () async {
      final String run = start();
      await stepper().step(
        run,
        PlanStep.freeze,
        operatingMode: OperatingMode.autoTrade,
      );
      expect(stepper().abort(run, PlanStep.ordersCleared), isNull);
      expect(
        db
            .select(
              "SELECT detail_json FROM migration_step WHERE state = 'FAILED'",
            )
            .single['detail_json'],
        '{"reason":"X1_PLAN_ABORT"}',
      );
      expect(
        count(
          "SELECT COUNT(*) AS n FROM maintenance_window WHERE event = 'CLOSED'",
        ),
        1,
      );
      expect(migrationInProgressOf(db, _dev), isFalse);
      final X1PlanWizardVm vm = screens().planWizard();
      expect(vm.d03Card, isNotNull);
      expect(vm.windowText, isNull);
      // 그만둔 뒤 새 이전 = 다시 시작 가능.
      expect(
        stepper()
            .start(operatingMode: OperatingMode.autoTrade, decisionId: 'D03-c2')
            .code,
        isNull,
      );
    });

    test('🔴 1~3 끝 = 4단계 진행 = UnsupportedError(쓰기 0) · 그만두기만 된다 · DEMOTED 그만두기 = 쓰기 0', () async {
      final String run = start();
      for (final PlanStep s in <PlanStep>[
        PlanStep.freeze,
        PlanStep.ordersCleared,
        PlanStep.reconZero,
      ]) {
        expect(
          await stepper().step(run, s, operatingMode: OperatingMode.autoTrade),
          isNull,
        );
      }
      final int before = count('SELECT COUNT(*) AS n FROM migration_step');
      await expectLater(
        stepper().step(
          run,
          PlanStep.backupChecksum,
          operatingMode: OperatingMode.autoTrade,
        ),
        throwsUnsupportedError,
      );
      expect(
        stepper().abort(run, PlanStep.demoted),
        X1JournalResultCodes.pastNoReturn,
      );
      expect(count('SELECT COUNT(*) AS n FROM migration_step'), before);
      final X1PlanWizardVm vm = screens().planWizard();
      expect(vm.headline, X1ScreenTexts.closedHeadline);
      expect(vm.rows[3].actions.single.id, SafetyActionId.x1PlanAbort);
      expect(stepper().abort(run, PlanStep.backupChecksum), isNull);
      expect(migrationInProgressOf(db, _dev), isFalse);
    });

    test('차례 아닌 단계 그만두기 = X1_STEP_OUT_OF_ORDER(쓰기 0)', () async {
      final String run = start();
      expect(
        stepper().abort(run, PlanStep.reconZero),
        X1JournalResultCodes.stepOutOfOrder,
      );
      expect(count('SELECT COUNT(*) AS n FROM migration_step'), 0);
    });
  });

  group('hold · 안전 상태', () {
    test(
      '🔴 안전 상태 holds = 동결 중 MIGRATION_IN_PROGRESS · 기기 id 없음 · 모의 = 0',
      () async {
        SafetyState state({
          String? device = _dev,
          RunMode mode = RunMode.live,
        }) => SqliteSafetyRepository(
          db,
          mode: mode,
          clock: clock,
          trusted: trusted,
          deviceId: device,
        ).state();
        expect(state().holds, isEmpty);
        final String run = start();
        await stepper().step(
          run,
          PlanStep.freeze,
          operatingMode: OperatingMode.autoTrade,
        );
        expect(state().holds, <String>[SafetyHoldCodes.migrationInProgress]);
        expect(state(device: null).holds, isEmpty);
        expect(state(mode: RunMode.simInternal).holds, isEmpty);
        expect(
          SqliteSafetyRepository.watchedTables,
          containsAll(<String>['migration_run', 'migration_step']),
        );
      },
    );

    test('옛 폰 9단계 끝(티켓까지) = hold 꺼짐(돌아오지 않는다)', () {
      final String run = start();
      for (final PlanStep s in PlanStep.values) {
        for (final String st in <String>['ENTERED', 'DONE']) {
          db.execute(
            'INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, NULL, ?)',
            <Object?>[run, s.wire, st, '2026-11-21T01:0${s.index}:00.000Z'],
          );
        }
      }
      expect(migrationInProgressOf(db, _dev), isFalse);
    });

    test('새 폰 = 복구 ~ 생체 전 켬 · 생체 끝 = 꺼짐', () {
      expect(
        SqliteRecoveryJournal(db, deviceId: 'dev-new', trusted: trusted)
            .start(
              kind: MigrationKind.plan,
              operatingMode: OperatingMode.autoTrade,
              decisionId: 'd1',
              operatorEpoch: 5,
              manifest: BackupManifest(
                sha256: 'a' * 64,
                chainHash: 'b' * 64,
                authoredDate: '2026-11-20',
                schemaVersion: 1,
                hashFormatVersion: 1,
                operatorEpoch: 4,
                writerDeviceId: 'dev-old',
              ),
            )
            .rejectCode,
        isNull,
      );
      expect(migrationInProgressOf(db, 'dev-new'), isTrue);
      final String run =
          db
                  .select(
                    "SELECT run_id FROM migration_run WHERE role = 'NEW_DEVICE'",
                  )
                  .single['run_id']
              as String;
      db.execute(
        "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, 'BIOMETRIC_CONFIRMED', 'DONE', NULL, 'x')",
        <Object?>[run],
      );
      expect(migrationInProgressOf(db, 'dev-new'), isFalse);
    });
  });

  group('새 폰 읽기', () {
    test('🔴 원장 없음 · 복구 없음 = 갈래별 막힘 문장 · 동작 · 슬롯 0', () {
      for (final MigrationKind k in MigrationKind.values) {
        for (final Database? on in <Database?>[null, db]) {
          final X1RecoveryVm vm = SqliteX1Screens(
            on,
            deviceId: 'dev-new',
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
            trusted: trusted,
            clock: clock,
          ).recovery(k, kr: frozenExchangeCalendar(Market.kr));
          expect(vm.level, UiLevel.blocked);
          expect(vm.startAction, isNull);
          expect(vm.scanSlotId, isNull);
          expect(vm.recoveryCodeSlotId, isNull);
          expect(vm.steps, isEmpty);
        }
      }
    });

    test('복구 있음 = 복원 카드 · 갭 막힘 · 게이트 0 · 사다리 기준 이상 = RECOVERY_FULL 링크', () {
      SqliteRecoveryJournal(db, deviceId: 'dev-new', trusted: trusted).start(
        kind: MigrationKind.emergency,
        operatingMode: OperatingMode.autoTrade,
        decisionId: 'd1',
        operatorEpoch: 5,
        manifest: BackupManifest(
          sha256: 'a' * 64,
          chainHash: '3f9a1c07${'b' * 56}',
          authoredDate: '2026-11-18',
          schemaVersion: 1,
          hashFormatVersion: 1,
          operatorEpoch: 4,
          writerDeviceId: 'dev-old',
        ),
      );
      X1RecoveryVm read(ResumeLadder? ladder) =>
          SqliteX1Screens(
            db,
            deviceId: 'dev-new',
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
            trusted: trusted,
            clock: clock,
          ).recovery(
            MigrationKind.plan,
            kr: frozenExchangeCalendar(Market.kr),
            observation: MigrationObservationConfig(
              planTradingDays: 2,
              emergencyTradingDays: 5,
            ),
            ladder: ladder,
          );
      final X1RecoveryVm vm = read(null);
      expect(vm.kindLabel, X1ScreenTexts.emergencyKind);
      expect(vm.restore?.chainHashText, '3f9a1c07');
      expect(vm.reasonCode, X1OrderSealCodes.inProgress);
      expect(vm.steps[1].lines, <String>[X1ScreenTexts.gapBlockedLine]);
      expect(vm.gate, isNull);
      final ResumeLadder small = ResumeLadder(
        gapLadderTradingDays: const <int>[1, 3, 5],
        backupGapDays: 3,
      );
      final X1RecoveryVm full = read(small);
      expect(full.reasonCode, X1OrderSealCodes.full);
      expect(full.restartLink?.deepLink, AppRoutes.onboardingRestart);
      final ResumeLadder big = ResumeLadder(
        gapLadderTradingDays: const <int>[1, 3, 5],
        backupGapDays: 7,
      );
      expect(read(big).reasonCode, X1OrderSealCodes.inProgress);
    });
  });
}
