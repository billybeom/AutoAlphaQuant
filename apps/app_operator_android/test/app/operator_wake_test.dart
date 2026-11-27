// 리뷰 3차 H1(설계 13 §8 R261 · 01 §8 미결 235) — 화면 동작 뒤 엔진 깨어남 창구 — 실 SQLite · 실 엔진(`OperatorEngine`).
//
// 🔴 재현: 화면 상태(`OperatorView`) · FGS 는 엔진 깨어남 때만 바뀐다 → 온보딩 마무리 뒤 셸 플래그 0(ⓐ) · 안전 명령 뒤 FGS «정상»(ⓒ) ·
//    simToAuto 커밋 뒤 닫힌 모의 원장(ⓑ — `operator_handover_test`) · 모의 개시 뒤 설정 지문 빈 글자(ⓕ).

import 'dart:io' show Directory;

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_live_promotion.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart' show KisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        JobRunEntry,
        JobRunStatus,
        LiveObservationConfig,
        LivePromotionCodes,
        P0sHumanInputs,
        P0sOpsConfig,
        TrustedClock;
import 'package:core_engine/testing.dart' show FakeLeaseGate, MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigReady,
        P0sHumanDecision,
        SqliteAlertSink,
        SqliteJobRunLog,
        SqliteModeStore,
        currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart' show FgsStatus;

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

class _Trusted implements TrustedClock {
  _Trusted(this.at);

  DateTime? at;

  @override
  DateTime? trustedNowUtc() => at;
}

final P0sHumanDecision _human = P0sHumanDecision(
  inputs: P0sHumanInputs(
    aSymbol: '229200',
    accountByStrategy: const <String, String>{
      'P0S_A': 'isa',
      'P0S_B': 'pension',
      'P0S_C': 'general',
      'P0S_POT': 'isa',
    },
  ),
  accountLabels: const <String, String>{
    'isa': 'ISA',
    'pension': '연금저축',
    'general': '일반 위탁',
  },
  decisionRef: 'R153',
);

const KillChecklistSubmission _checklist = KillChecklistSubmission(
  ruleAction: '규칙대로 신규 진입을 멈춘다',
  reasonKind: KillActivationReason.rule,
  scenarioId: 'W3',
  resumeCondition: '체결 오류 0',
  scope: KillActivationScope.newEntriesOnly,
  openOrdersQueried: true,
  openOrdersCancelled: true,
  remainingCountZero: true,
  note: '한 줄',
);

const FeatureFlags _simFlags = FeatureFlags(
  satelliteEnabled: false,
  webViewerEnabled: false,
  calendarEnabled: false,
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  configHash: 'cfg_test',
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late _Trusted trusted;

  setUp(() {
    // 토요일 14:00 KST — 다음 알람 = 월 07:00(약 41시간 · H1-1 재현 조건).
    clock = FakeClock(kst(2026, 12, 19, 14, 0));
    files = openFiles(tempLedgerDir(), clock);
    trusted = _Trusted(clock.nowUtc());
  });
  tearDown(() => files.close());

  OperatorRuntime runtime() => OperatorRuntime(
    files: files,
    clock: clock,
    deviceId: _dev,
    trusted: trusted,
    humanDecision: _human,
  );

  /// 실 엔진 깨어남을 런타임에 단다(조립 = `engineWakeHandler` 와 같은 꼴: 깨어남 → `runtime.onWake`) · [shown] = FGS 기록.
  ({
    List<FgsStatus> shown,
    int Function() asked,
    Future<void> Function() settle,
  })
  attachEngine(OperatorRuntime rt) {
    final List<FgsStatus> shown = <FgsStatus>[];
    final List<Future<void>> pending = <Future<void>>[];
    final OperatorEngine engine = OperatorEngine(
      openFiles: () => rt.files,
      calendars: calendars(),
      heartbeat: RecordingHeartbeat(),
      clock: clock,
      bootInputs: BootInputs(trusted: trusted, deviceId: _dev),
      fgs: (FgsStatus s) async => shown.add(s),
    );
    rt.attachWake(() {
      final Future<void> f = () async {
        final EngineWakeReport r = await engine.wake();
        rt.onWake(r);
      }();
      pending.add(f);
      return f;
    });
    return (
      shown: shown,
      asked: () => pending.length,
      settle: () => Future.wait(pending),
    );
  }

  OperatorSettingsActions actions(OperatorRuntime rt) =>
      OperatorSettingsActions(
        secrets: SecretHandoff(),
        vault: MemorySecretVault(),
        clientOf: (KisCredentials c) => throw UnimplementedError('검증 없음'),
        clock: clock,
        sim: files.sim,
        wake: rt.wakeNow,
      );

  group('🔴 ⓐ H1-1 · ⓕ B-U1 — 온보딩 마무리(모의 운영 시작) 뒤 깨어남 한 번 → 셸 플래그 · 설정 지문', () {
    test('모의 개시 · 마무리 = 깨어남 각 1 · 셸 플래그 = 모의 · 지문 = 모의 개시 판 · FGS = 정상(다음 알람을 기다리지 않는다)', () async {
      final OperatorRuntime rt = runtime();
      final w = attachEngine(rt);
      final OperatorSettingsActions acts = actions(rt);
      await acts.run(
        SettingsActionId.onboardingOperatingModeSelect,
        args: <String, String>{'operating_mode': 'AUTO_TRADE'},
      );
      expect(w.asked(), 0, reason: '운영 방식 고르기 = 상태 전이 아님');
      final CommandReceipt opened = await OperatorCommandApi(rt)
          .submitSelfReportBalance(
            const SelfReportSubmission(
              purpose: SelfReportPurpose.simOpening,
              input: SelfReportInput(cashKrwText: '10,000,000'),
              declaredComplete: true,
            ),
          );
      expect(opened.state, CommandState.executed, reason: opened.stateLabel);
      expect(w.asked(), 1, reason: 'ⓕ 모의 개시 뒤 깨어남 한 번');
      await w.settle();
      expect(rt.view.value, isNull, reason: '마무리 전 = 온보딩 미완 그대로');
      final ActionResult done = await acts.run(
        SettingsActionId.onboardingDryRunStart,
      );
      expect(done.level, UiLevel.ok, reason: done.headline);
      expect(w.asked(), 2, reason: 'ⓐ 마무리 뒤 깨어남 한 번');
      await w.settle();
      final OperatorView v = rt.view.value!;
      expect(identical(v.db, files.sim), isTrue);
      expect(v.flags.runMode, RunMode.simInternal);
      expect(v.flags.operatingMode, OperatingMode.autoTrade);
      final OpsConfigReady cfg =
          currentP0sOpsConfig(files.sim, RunMode.simInternal) as OpsConfigReady;
      expect(v.flags.configHash, cfg.configHash);
      expect(v.flags.configHash, isNotEmpty);
      final FeatureFlags flags = await OperatorConfigRepository(
        rt.view,
        clock: clock,
        kr: rt.calendars.kr,
      ).watchFlags().first.timeout(const Duration(seconds: 5));
      expect(flags, v.flags);
      expect(w.shown.last.level, UiLevel.ok);
      expect(w.shown.last.runMode, RunMode.simInternal);
    });

    test('마무리 거부(앞 조건) = 깨어남 0', () async {
      final OperatorRuntime rt = runtime();
      final w = attachEngine(rt);
      final OperatorSettingsActions acts = actions(rt);
      await acts.run(
        SettingsActionId.onboardingOperatingModeSelect,
        args: <String, String>{'operating_mode': 'AUTO_TRADE'},
      );
      final ActionResult r = await acts.run(
        SettingsActionId.onboardingDryRunStart,
      );
      expect(r.level, UiLevel.blocked);
      expect(w.asked(), 0);
    });
  });

  group('🔴 ⓒ H1-3 — 안전 명령 뒤 깨어남 한 번 → FGS 가 바로 바뀐다(다음 알람까지 «정상» 0)', () {
    Future<
      (
        OperatorRuntime,
        ({
          List<FgsStatus> shown,
          int Function() asked,
          Future<void> Function() settle,
        }),
      )
    >
    started() async {
      writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
      final OperatorRuntime rt = runtime();
      final w = attachEngine(rt);
      await rt.wakeNow();
      await w.settle();
      return (rt, w);
    }

    test(
      '킬스위치 발동 = 깨어남 1 → FGS BLOCKED · 기록 확인(실행) = 깨어남 1 · 거부 = 0',
      () async {
        final (OperatorRuntime rt, w) = await started();
        expect(rt.view.value, isNotNull);
        expect(w.shown.last.level, UiLevel.ok);
        final int before = w.asked();
        final OperatorCommandApi api = OperatorCommandApi(rt);
        final CommandReceipt on = await api.activateKillSwitch();
        expect(on.state, CommandState.executed);
        expect(w.asked(), before + 1);
        await w.settle();
        expect(w.shown.last.level, UiLevel.blocked);
        final CommandReceipt bad = await api.confirmKillChecklist(
          _checklist.copyWith(reasonKind: null),
        );
        expect(bad.state, CommandState.rejected);
        expect(w.asked(), before + 1, reason: '거부 = 상태 전이 아님');
        final CommandReceipt yes = await api.confirmKillChecklist(_checklist);
        expect(yes.state, CommandState.executed, reason: yes.stateLabel);
        expect(w.asked(), before + 2);
        await w.settle();
        expect(w.shown.last.level, UiLevel.blocked);
      },
    );

    test('알림 수신 확인(실행) = 깨어남 1 → FGS 의 열린 P0 가 바로 빠진다', () async {
      final (OperatorRuntime rt, w) = await started();
      await SqliteAlertSink(
        files.sim,
        clock: clock,
      ).emit('sim-auto-daily_reconcile', <String>{AlertCodes.reconMismatch});
      await rt.wakeNow();
      await w.settle();
      expect(w.shown.last.level, UiLevel.act);
      final String id = w.shown.last.p0AlertId!;
      final int before = w.asked();
      final CommandReceipt r = await OperatorCommandApi(rt)
          .acknowledgeAlert(id);
      expect(r.state, CommandState.executed);
      expect(w.asked(), before + 1);
      await w.settle();
      expect(w.shown.last.level, UiLevel.ok);
    });
  });

  group('승격(S05) 뒤 깨어남', () {
    test('🔴 승격 = 실행 정책 전이 → 깨어남 1 · 거부(생체 취소) = 0', () async {
      // 실전 dryRun 커밋 01-12(화) 15:00 · 무결 01-13 · 01-14 · 승격 = 01-14 18:00(data_sync 승격 시험과 같은 꼴).
      clock.now = kst(2027, 1, 12, 15, 0);
      final Database live = writeLiveMode(Directory(files.directory), clock);
      addTearDown(live.close);
      // 🆕 R265 — 커밋의 live 몫 = 실전 개시 판도(승격 결정의 설정 지문 원천 · 못 읽음 = 거부).
      final String hash = writeLiveOpening(
        live,
        clock,
        P0sOpsConfig.of(_human.inputs),
      );
      for (final String d in <String>['2027-01-13', '2027-01-14']) {
        final DateTime at = kst(
          int.parse(d.substring(0, 4)),
          int.parse(d.substring(5, 7)),
          int.parse(d.substring(8, 10)),
          9,
          10,
        );
        await SqliteJobRunLog(live).record(
          JobRunEntry(
            rid: 'live-auto-kr_order-$d',
            checkName: 'live-auto-kr_order',
            sessionDay: TradeDate(d),
            startedAtUtc: at,
            finishedAtUtc: at.add(const Duration(minutes: 1)),
            status: JobRunStatus.success,
          ),
        );
        live.execute(
          'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
          "VALUES (?, ?, 1, '[]', 'NONE')",
          <Object?>[
            'rc-$d',
            at.add(const Duration(minutes: 10)).toIso8601String(),
          ],
        );
      }
      clock.now = kst(2027, 1, 14, 18, 0);
      BiometricOutcome answer = BiometricOutcome.canceled;
      final OperatorRuntime rt = OperatorRuntime(
        files: files,
        clock: clock,
        liveObservation: LiveObservationConfig(requiredTradingDays: 2),
        biometricSign: (_) async => answer,
        leaseRemote: (Database _) => FakeLeaseGate(),
      );
      int wakes = 0;
      rt.attachWake(() async => wakes++);
      final OperatorLivePromotion p = OperatorLivePromotion(rt);
      final ActionResult no = await p.run('ar-1', const <String, String>{});
      expect(no.reasonCode, LivePromotionCodes.biometricUnavailable);
      expect(wakes, 0);
      answer = BiometricOutcome.ok;
      final ActionResult yes = await p.run('ar-2', const <String, String>{});
      expect(yes.reasonCode, isNull, reason: yes.headline);
      expect(wakes, 1);
      expect(
        live
            .select(
              "SELECT config_hash FROM decision_log WHERE reason_code = 'LIVE_EXECUTE_PROMOTION'",
            )
            .single['config_hash'],
        hash,
        reason: '승격 결정 = 실전 개시 판 지문(빈 글자 0)',
      );
    });

    test('🆕 리뷰 3차 H2-02(R265) — 실전 개시 판을 못 읽음 = CONFIG_UNAVAILABLE · 쓰기 0 · 깨어남 0', () async {
      clock.now = kst(2027, 1, 12, 15, 0);
      final Database live = writeLiveMode(Directory(files.directory), clock);
      addTearDown(live.close);
      final OperatorRuntime rt = OperatorRuntime(
        files: files,
        clock: clock,
        liveObservation: LiveObservationConfig(requiredTradingDays: 2),
        biometricSign: (_) async => BiometricOutcome.ok,
        leaseRemote: (Database _) => FakeLeaseGate(),
      );
      int wakes = 0;
      rt.attachWake(() async => wakes++);
      clock.now = kst(2027, 1, 14, 18, 0);
      final ActionResult r = await OperatorLivePromotion(rt)
          .run('ar-x', const <String, String>{});
      expect(r.reasonCode, LivePromotionCodes.configUnavailable);
      expect(r.level, UiLevel.blocked);
      expect(r.retryable, isFalse);
      expect(wakes, 0);
      expect(
        live
            .select(
              "SELECT COUNT(*) AS n FROM decision_log WHERE reason_code = 'LIVE_EXECUTE_PROMOTION'",
            )
            .first['n'],
        0,
      );
    });
  });

  group('창구 — OperatorRuntime.wakeNow', () {
    test('창구 없음 = 깨어남 0 · 던지지 않는다 · 깨어남이 던져도 삼킨다', () async {
      final OperatorRuntime rt = runtime();
      await rt.wakeNow();
      int calls = 0;
      rt.attachWake(() async {
        calls++;
        throw StateError('깨어남 실패');
      });
      await rt.wakeNow();
      expect(calls, 1);
    });

    test(
      '🔴 ⓑ 깨어남 뒤에도 화면 상태가 닫힌(CLOSE) 모의 원장이면 비운다 — 열린 모의 · 실전 = 그대로',
      () async {
        writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
        final OperatorRuntime rt = runtime();
        rt.view.value = OperatorView(db: files.sim, flags: _simFlags);
        await rt.wakeNow();
        expect(rt.view.value, isNotNull, reason: '열린 모의 원장 = 그대로');
        final OperatorView live = OperatorView(
          db: writeLiveMode(Directory(files.directory), clock),
          flags: _simFlags.copyWith(runMode: RunMode.live),
        );
        SqliteModeStore(
          files.sim,
          LedgerFile.sim,
          clock: clock,
        ).close(decisionId: 'D-LIVE');
        rt.view.value = live;
        await rt.wakeNow();
        expect(rt.view.value, same(live), reason: '실전 원장 = 그대로');
        rt.view.value = OperatorView(db: files.sim, flags: _simFlags);
        await rt.wakeNow();
        expect(
          rt.view.value,
          isNull,
          reason: '닫힌 모의 원장 = 비움(쓰기 = 화면 상태 없음 오류)',
        );
        await expectLater(
          OperatorCommandApi(rt).activateKillSwitch(),
          throwsA(isA<StateError>()),
        );
        expect(
          files.sim
              .select('SELECT COUNT(*) AS n FROM kill_switch_state')
              .first['n'],
          0,
          reason: '닫힌 모의 원장에 킬스위치를 쓰지 않는다',
        );
      },
    );
  });
}
