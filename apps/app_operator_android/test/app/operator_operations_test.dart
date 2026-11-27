// 🆕 E11q-s05 — M9 S05 운용 관리 operator 판(설계 13 §8 R252 · 01 §28) — 실 SQLite(sim · live) · 엔진 VM · 동작 2(전환 요청 · 승격) ·
// 레지스트리 본문.

import 'dart:io';

import 'package:app_operator_android/app/operator_live_promotion.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_shell.dart'
    show kOperatorRouteBodies;
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart'
    show EngineRejected;
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisRestClient;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        LiveObservationConfig,
        LivePromotionCodes,
        OperationsTexts,
        kLeaseInvalidCode,
        livePromotionHeadline;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        BiometricPurpose,
        FeatureFlags,
        OperatingMode,
        OperationsVm,
        RunMode,
        SafetyHoldCodes,
        SettingsActionCall,
        SettingsActionId,
        SettingsHomeVm,
        UiLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart' show kJobTable;

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late Directory dir;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 24, 19, 0));
    dir = tempLedgerDir();
    files = openFiles(dir, clock);
  });
  tearDown(() => files.close());

  OperatorRuntime runtime({bool observe = true, BiometricAsk? bio}) =>
      OperatorRuntime(
        files: files,
        clock: clock,
        vault: MemorySecretVault(),
        liveObservation: observe
            ? LiveObservationConfig(requiredTradingDays: 2)
            : null,
        biometricSign: bio,
      );

  OperatorView viewOf(
    Database db, {
    RunMode run = RunMode.simInternal,
    OperatingMode op = OperatingMode.autoTrade,
    Set<String> holds = const <String>{},
    List<String> rejected = const <String>[],
  }) => OperatorView(
    db: db,
    holds: holds,
    rejected: rejected,
    flags: FeatureFlags(
      satelliteEnabled: false,
      webViewerEnabled: false,
      calendarEnabled: false,
      runMode: run,
      operatingMode: op,
      configHash: 'cfg_test',
    ),
  );

  bool wizardOnly(String r) => r == AppRoutes.m5HandoverWizard;

  group('S05 읽기(R252)', () {
    test('🔴 화면 상태 없음(온보딩 전) = 오류(지어내지 않는다)', () async {
      await expectLater(
        OperatorSettingsRepository(runtime()).watchOperations(),
        emitsError(isA<StateError>()),
      );
    });

    test('🔴 모의 = 엔진 VM — 칩 · 모드 · 체험 카드 · 램프 빈 까닭 · 잡 표 전부 · 엔진 줄 = 다음 잡 · 버튼 = 창구가 있을 때만', () async {
      writeSimMode(files.sim, clock);
      final OperatorRuntime rt = runtime(bio: (_) async => BiometricOutcome.ok);
      rt.view.value = viewOf(files.sim);
      final OperationsVm bare = await OperatorSettingsRepository(
        rt,
        hasBody: wizardOnly,
      ).watchOperations().first;
      expect(bare.statusChip.label, '모의 · 내부 가상 체결 · 자동 매매');
      expect(
        (bare.mode.label, bare.mode.level, bare.mode.holdLabel),
        ('모의 · 내부 가상 체결', UiLevel.info, null),
      );
      expect(bare.mode.switchActions, isEmpty);
      expect(bare.mode.promotionAction, isNull);
      expect(bare.trial, isNotNull);
      expect(bare.ramp.emptyLabel, OperationsTexts.rampSimEmpty);
      expect(bare.jobs, hasLength(kJobTable.length));
      expect(bare.jobs.every((j) => j.statusCode == 'NONE'), isTrue);
      expect(bare.control.stateLabel, startsWith('돌고 있음 — 다음 잡: 오늘 20:00 '));
      expect(bare.control.stopActions, isEmpty);
      expect(bare.control.startAction, isNull);
      expect(
        (bare.updateGate, bare.lastRequestNotice, bare.lockedLabel),
        (null, null, null),
      );
      // 동작 창구 ∧ 위저드 본문 = 실전 전환 요청 버튼(표본 글자) · 본문 없음 = 부재.
      final OperationsVm can = await OperatorSettingsRepository(
        rt,
        hasBody: wizardOnly,
        canAct: true,
      ).operations();
      expect(can.mode.switchActions, const <SettingsActionCall>[
        SettingsActionCall(
          id: SettingsActionId.runtimeModeSwitchRequest,
          args: <String, String>{'run_mode': 'LIVE'},
          label: '실전 전환 요청',
        ),
      ]);
      expect(can.mode.switchNoticeText, OperationsTexts.switchNotice);
      expect(
        (await OperatorSettingsRepository(
          rt,
          canAct: true,
        ).operations()).mode.switchActions,
        isEmpty,
      );
    });

    test(
      '🔴 실전 관찰 = 관찰 판정(실전 파일 · 관찰 설정) · 칩 승격 줄 = S01 과 같은 값 · 아직 불가 = 승격 버튼 0',
      () async {
        final Database live = writeLiveMode(dir, clock);
        addTearDown(live.close);
        clock.now = kst(2026, 11, 24, 20, 0);
        final OperatorRuntime rt = runtime(
          bio: (_) async => BiometricOutcome.ok,
        );
        rt.view.value = viewOf(live, run: RunMode.live);
        final OperatorSettingsRepository repo = OperatorSettingsRepository(
          rt,
          canAct: true,
        );
        final OperationsVm vm = await repo.operations();
        expect((vm.mode.label, vm.mode.level), ('실전 · 관찰 중', UiLevel.watch));
        expect(vm.mode.observation?.progressText, '무결 거래일 0/2');
        expect(vm.mode.promotionAction, isNull);
        expect(vm.trial, isNull);
        expect(vm.statusChip.promotionLabel, '승격 불가 — 무결 거래일이 아직 모자랍니다(0/2)');
        final SettingsHomeVm home = await repo.home();
        expect(home.statusChip, vm.statusChip);
        // 관찰 설정 없음 = 판정 0(칩 줄 · 관찰 칸 없음 — 지어내지 않는다).
        final OperatorRuntime noCfg = runtime(observe: false);
        noCfg.view.value = viewOf(live, run: RunMode.live);
        final OperationsVm none = await OperatorSettingsRepository(noCfg)
            .operations();
        expect(
          (none.statusChip.promotionLabel, none.mode.observation),
          (null, null),
        );
      },
    );

    test(
      '🔴 hold · 기동 거부 = 엔진 줄(배치 멈춤 · 거부 코드) · 램프 = ramp_state(DST 하향)',
      () async {
        writeSimMode(files.sim, clock);
        final OperatorRuntime rt = runtime();
        rt.view.value = viewOf(
          files.sim,
          holds: const <String>{SafetyHoldCodes.migrationInProgress},
        );
        final OperationsVm held = await OperatorSettingsRepository(rt)
            .operations();
        expect(
          (held.control.stateLabel, held.control.level),
          (OperationsTexts.heldBatches, UiLevel.watch),
        );
        expect(held.mode.holdLabel, isNotNull);
        rt.view.value = viewOf(files.sim, rejected: const <String>['SAF-405']);
        final OperationsVm no = await OperatorSettingsRepository(rt)
            .operations();
        expect(
          (no.control.stateLabel, no.control.level),
          ('멈춤 — 기동 판정이 시작을 거부했습니다(SAF-405)', UiLevel.blocked),
        );
        final Database live = writeLiveMode(dir, clock);
        addTearDown(live.close);
        live.execute(
          'INSERT OR REPLACE INTO ramp_state(id, level, pre_dst_level, updated_at) VALUES (1, 2, 3, ?)',
          <Object?>[clock.nowUtc().toIso8601String()],
        );
        rt.view.value = viewOf(live, run: RunMode.live);
        final OperationsVm ramp = await OperatorSettingsRepository(rt)
            .operations();
        expect(
          (ramp.ramp.levelLabel, ramp.ramp.level, ramp.ramp.dstNoticeText),
          (
            'L2 · 15% — DST 주간이라 한 단계 낮춤(원래 L3)',
            UiLevel.watch,
            OperationsTexts.rampDstNotice,
          ),
        );
      },
    );

    test('🔴 잡 기록이 생기면 다시 낸다(job_run)', () async {
      writeSimMode(files.sim, clock);
      final OperatorRuntime rt = runtime();
      rt.view.value = viewOf(files.sim);
      final List<OperationsVm> got = <OperationsVm>[];
      final sub = OperatorSettingsRepository(rt)
          .watchOperations()
          .listen(got.add);
      addTearDown(sub.cancel);
      final Stopwatch w = Stopwatch()..start();
      while (got.isEmpty && w.elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      files.sim.execute(
        'INSERT INTO job_run (rid, check_name, session_day, started_at, finished_at, status) '
        "VALUES ('r1', 'sim-auto-daily_data', '2026-11-24', ?, ?, 'SUCCESS')",
        <Object?>[
          // 🔴 모드 시작(19:00 · writeSimMode) 뒤 기록만 본다.
          clock.nowUtc().add(const Duration(minutes: 5)).toIso8601String(),
          clock.nowUtc().add(const Duration(minutes: 10)).toIso8601String(),
        ],
      );
      while (got.length < 2 && w.elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(got, hasLength(2));
      expect(
        got.last.jobs
            .where((j) => j.statusCode == 'SUCCESS')
            .single
            .lastRunText,
        '오늘 19:10 끝남',
      );
    });
  });

  group('S05 동작(R252)', () {
    OperatorSettingsActions acts(
      OperatorRuntime rt, {
      bool modeSwitch = false,
      bool promotion = false,
    }) => OperatorSettingsActions(
      secrets: SecretHandoff(),
      vault: MemorySecretVault(),
      clientOf: (KisCredentials c) => KisRestClient(
        MockClient((http.Request _) async => http.Response('', 500)),
        c,
        environment: c.environment,
      ),
      clock: clock,
      modeSwitch: modeSwitch,
      livePromotion: promotion ? OperatorLivePromotion(rt) : null,
    );

    test('🔴 실전 전환 요청 = 위저드로 넘김(표본 글자 · 상태 변경 0) · args 꼴 틀림 = ArgumentError · 위저드 없음 = 구현 없음', () async {
      final OperatorRuntime rt = runtime();
      final OperatorSettingsActions a = acts(rt, modeSwitch: true);
      final ActionResult r = await a.run(
        SettingsActionId.runtimeModeSwitchRequest,
        args: const <String, String>{'run_mode': 'LIVE'},
      );
      expect(
        (r.level, r.headline, r.handoffRoute, r.reasonCode, r.retryable),
        (
          UiLevel.info,
          OperationsTexts.switchRequested,
          AppRoutes.m5HandoverWizard,
          null,
          false,
        ),
      );
      expect(await a.watch(r.actionRunId).first, r);
      expect(files.liveIfExists(), isNull, reason: '요청은 실전 파일을 만들지 않는다');
      await expectLater(
        a.run(
          SettingsActionId.runtimeModeSwitchRequest,
          args: const <String, String>{'run_mode': 'SIM_INTERNAL'},
        ),
        throwsArgumentError,
      );
      await expectLater(
        acts(rt).run(
          SettingsActionId.runtimeModeSwitchRequest,
          args: const <String, String>{'run_mode': 'LIVE'},
        ),
        throwsUnsupportedError,
      );
      // 운영 방식 전환 · 엔진 시작 · 중지 = 그대로 구현 없음(미결 173).
      for (final SettingsActionId id in <SettingsActionId>[
        SettingsActionId.runtimeOperatingModeSwitchRequest,
        SettingsActionId.runtimeEngineStart,
        SettingsActionId.runtimeEngineStop,
      ]) {
        await expectLater(a.run(id), throwsUnsupportedError, reason: '$id');
      }
    });

    test('🔴 승격 — 실전 파일 없음 = 관찰 아님(INFO) · 생체 취소 = BIOMETRIC_UNAVAILABLE · 리스 모름 = LEASE_INVALID · 쓰기 0', () async {
      int asked = 0;
      final Set<BiometricPurpose> purposes = <BiometricPurpose>{};
      BiometricOutcome answer = BiometricOutcome.canceled;
      final OperatorRuntime rt = runtime(
        bio: (BiometricPurpose p) async {
          asked++;
          purposes.add(p);
          return answer;
        },
      );
      final OperatorSettingsActions a = acts(rt, promotion: true);
      final ActionResult none = await a.run(
        SettingsActionId.runtimeLivePromotion,
      );
      expect(
        (none.level, none.reasonCode, none.headline, asked),
        (
          UiLevel.info,
          LivePromotionCodes.notObserving,
          livePromotionHeadline(LivePromotionCodes.notObserving),
          0,
        ),
      );
      final Database live = writeLiveMode(dir, clock);
      addTearDown(live.close);
      clock.now = kst(2026, 11, 24, 20, 0);
      final ActionResult bio = await a.run(
        SettingsActionId.runtimeLivePromotion,
      );
      expect(
        (bio.level, bio.reasonCode, asked),
        (UiLevel.blocked, LivePromotionCodes.biometricUnavailable, 1),
      );
      // 🆕 미결 243 ⓑ(R276 · K350) — 대화상자 = «실제 주문 켜기»(실주문을 켜는 동작 · 서약 글자 아님).
      expect(purposes, <BiometricPurpose>{BiometricPurpose.livePromotion});
      answer = BiometricOutcome.ok;
      final ActionResult lease = await a.run(
        SettingsActionId.runtimeLivePromotion,
      );
      expect(
        (lease.level, lease.reasonCode, lease.headline),
        (
          UiLevel.blocked,
          kLeaseInvalidCode,
          livePromotionHeadline(kLeaseInvalidCode),
        ),
      );
      expect(
        live
            .select(
              "SELECT COUNT(*) AS n FROM mode_transition WHERE exec_policy = 'EXECUTE'",
            )
            .single['n'],
        0,
        reason: '거부 = 아무것도 쓰지 않는다',
      );
      await expectLater(
        a.run(
          SettingsActionId.runtimeLivePromotion,
          args: const <String, String>{'x': '1'},
        ),
        throwsArgumentError,
      );
      await expectLater(
        acts(rt).run(SettingsActionId.runtimeLivePromotion),
        throwsUnsupportedError,
      );
    });

    test('🔴 승격 창구 = 생체 ∧ 관찰 설정이 있을 때만', () {
      expect(OperatorLivePromotion.availableIn(runtime()), isFalse);
      expect(
        OperatorLivePromotion.availableIn(
          runtime(bio: (_) async => BiometricOutcome.ok),
        ),
        isTrue,
      );
      expect(
        OperatorLivePromotion.availableIn(
          runtime(observe: false, bio: (_) async => BiometricOutcome.ok),
        ),
        isFalse,
      );
    });
  });

  test('🔴 기동 거부 → 화면 상태 rejected = 엔진 거부 사유 차례 그대로 · 기동 = 빈', () {
    final OperatorView? no = operatorViewOf(
      const EngineRejected(
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        triggered: <String>['SAF-405', 'MODE_COMBINATION_DENIED'],
        repaired: false,
      ),
      files,
    );
    expect(no?.rejected, <String>['SAF-405', 'MODE_COMBINATION_DENIED']);
    expect(viewOf(files.sim).rejected, isEmpty);
  });

  test('🔴 레지스트리 = S05 본문(M5-11 확정 성공 목적지 K175 · 설정 홈 «운용 관리» 카드 링크가 선다)', () {
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.settingsOperations),
      isTrue,
    );
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5HandoverWizard),
      isTrue,
    );
  });
}
