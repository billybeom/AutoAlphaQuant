// E11p4b 온보딩 읽기 모델 operator 판 · 첫 실행 판정(설계 13 §8 R125) — 실 SQLite(sim 파일) · 실제 시간(갱신 훅).

import 'dart:async';

import 'package:app_operator_android/app/operator_onboarding.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        onboardingModeChoiceVmOf,
        onboardingStartVmOf;
import 'package:data_sync/data_sync.dart'
    show
        SqliteConfigVersionStore,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        CommandContext,
        GateState,
        OnboardingFinishVm,
        OnboardingModeChoiceVm,
        OnboardingSlotIds,
        OnboardingStep,
        OnboardingStepDetailVm,
        OnboardingStepsVm,
        OnboardingTrack,
        OperatingMode,
        RunMode,
        SelfReportBalance,
        SelfReportLine,
        SelfReportPurpose,
        SettingsActionId,
        StepState,
        TradeDate;
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  OnboardingProbe? probe;
  late OperatorRuntime rt;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 9, 0));
    files = openFiles(tempLedgerDir(), clock);
    probe = null;
    rt = OperatorRuntime(
      files: files,
      clock: clock,
      onboardingProbe: () async => probe,
    );
  });
  tearDown(() => files.close());

  SqliteOnboardingStore store() =>
      SqliteOnboardingStore(files.sim, clock: clock);

  Future<void> until(bool Function() ok) async {
    final Stopwatch w = Stopwatch()..start();
    while (!ok() && w.elapsed < const Duration(seconds: 5)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  OnboardingStep row(OnboardingStepsVm vm, String id) =>
      vm.rows.singleWhere((OnboardingStep s) => s.stepId == id);

  test('🔴 첫 화면 = 엔진 짓기(재시작 링크 없음 · 조회 전용 카드 없음 — operator · 4d 전)', () async {
    expect(
      await OperatorOnboardingRepository(rt).watchStart().first,
      onboardingStartVmOf(reconnectReady: false, viewerTrack: false),
    );
  });

  test(
    '🔴 운영 방식 = sim 파일 선택 — 고르기 전 → 고름(다음 링크) → 확정(잠김) · 바뀔 때마다 다시 낸다',
    () async {
      final List<OnboardingModeChoiceVm> got = <OnboardingModeChoiceVm>[];
      final StreamSubscription<OnboardingModeChoiceVm> sub =
          OperatorOnboardingRepository(rt).watchModeChoice().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(
        got.last,
        onboardingModeChoiceVmOf(selected: null, committed: false),
      );
      expect(store().selectOperatingMode(OperatingMode.advisory).ok, true);
      await until(() => got.length >= 2);
      expect(
        got.last,
        onboardingModeChoiceVmOf(
          selected: OperatingMode.advisory,
          committed: false,
        ),
      );
      files.sim.execute(
        'UPDATE onboarding_choice SET committed_at = ? WHERE id = 1',
        <Object?>[clock.nowUtc().toIso8601String()],
      );
      await until(() => got.length >= 3);
      expect(got.last.lockedLabel, isNotNull);
      expect(got.last.nextDeepLink, isNull);
    },
  );

  test('🔴 단계 목록 = 선택 · 진척 · 실측 — 고르기 전 0행 · 고르면 그 방식 · 실측 = 알림 o_05 · 배터리 o_06 · 진척 → 다시 낸다', () async {
    probe = const OnboardingProbe(
      notificationsEnabled: true,
      batteryExempt: false,
    );
    final List<OnboardingStepsVm> got = <OnboardingStepsVm>[];
    final StreamSubscription<OnboardingStepsVm> sub =
        OperatorOnboardingRepository(rt).watchStepList().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(got.last.rows, isEmpty);
    expect(got.last.emptyLabel, isNotNull);
    store().selectOperatingMode(OperatingMode.autoTrade);
    await until(() => got.last.rows.isNotEmpty);
    final OnboardingStepsVm auto = got.last;
    expect(auto.rows, hasLength(12));
    expect(row(auto, 'o_05').state, StepState.verified);
    expect(row(auto, 'o_06').state, StepState.notStarted);
    // 원천 없는 필수 = UNKNOWN(막힘) · 앞 단계 = 막힘.
    expect(row(auto, 'o_07').gate?.state, GateState.unknown);
    expect(row(auto, 'o_03').gate?.state, GateState.block);
    expect(auto.finishDeepLink, isNull);
    SqliteOnboardingProgressStore(
      files.sim,
      clock: clock,
    ).record('o_02', StepState.verified);
    await until(() => row(got.last, 'o_02').state == StepState.verified);
    expect(row(got.last, 'o_03').gate?.state, GateState.unknown);
  });

  test('🔴 실측 모름(Android 아님) = 진척 행만 · 실측은 주기마다 다시', () async {
    final OperatorOnboardingRepository r = OperatorOnboardingRepository(
      rt,
      tick: const Duration(milliseconds: 20),
    );
    store().selectOperatingMode(OperatingMode.autoTrade);
    final List<OnboardingStepsVm> got = <OnboardingStepsVm>[];
    final StreamSubscription<OnboardingStepsVm> sub = r.watchStepList().listen(
      got.add,
    );
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    expect(row(got.last, 'o_05').state, StepState.notStarted);
    expect(row(got.last, 'o_05').gate, isNull);
    probe = const OnboardingProbe(
      notificationsEnabled: true,
      batteryExempt: true,
    );
    await until(() => row(got.last, 'o_06').state == StepState.verified);
    expect(row(got.last, 'o_05').state, StepState.verified);
  });

  test('🔴 단계 상세 o_02 = 키 검증 동작 + 모의 키 슬롯 · 없는 단계 = 빈 문장', () async {
    store().selectOperatingMode(OperatingMode.autoTrade);
    final OnboardingStepDetailVm d = await OperatorOnboardingRepository(rt)
        .watchStep('o_02')
        .first;
    expect(d.verify?.id, SettingsActionId.credentialVerify);
    expect(d.secretSlotId, OnboardingSlotIds.secretKisMock);
    final OnboardingStepDetailVm m = await OperatorOnboardingRepository(rt)
        .watchStep('o_99')
        .first;
    expect(m.step, isNull);
    expect(m.missingLabel, isNotNull);
  });

  test('🔴 재시작 · 옛 창구 = 오류(4d 전 · 지어내지 않는다)', () async {
    final OperatorOnboardingRepository r = OperatorOnboardingRepository(rt);
    await expectLater(r.watchRestart(), emitsError(isA<UnsupportedError>()));
    await expectLater(
      r.watchSteps(OnboardingTrack.fresh),
      emitsError(isA<UnsupportedError>()),
    );
  });

  test('🔴 마무리(R127) — 고르기 전 = 오류 · 고른 뒤 6단계(원천 없는 ③④⑤ = 막힘 · ⑥ 막힘) · 서약 → ② 끝(다시 낸다)', () async {
    await expectLater(
      OperatorOnboardingRepository(rt).watchFinish(),
      emitsError(isA<StateError>()),
    );
    store().selectOperatingMode(OperatingMode.autoTrade);
    final List<OnboardingFinishVm> got = <OnboardingFinishVm>[];
    final StreamSubscription<OnboardingFinishVm> sub =
        OperatorOnboardingRepository(rt).watchFinish().listen(got.add);
    addTearDown(sub.cancel);
    await until(() => got.isNotEmpty);
    final OnboardingFinishVm v = got.last;
    expect(v.stages, hasLength(6));
    // ① 설정 해시 = 모의 개시 전 → 줄 없음.
    expect(v.stages[0].lines, hasLength(2));
    expect(v.stages[1].state, StepState.notStarted);
    expect(v.stages[1].slotId, OnboardingSlotIds.pledgeWrite);
    expect(v.stages[2].gate?.state, GateState.block);
    expect(v.stages[3].gate?.state, GateState.unknown);
    expect(v.stages[4].gate?.state, GateState.unknown);
    expect(v.stages[5].gate?.state, GateState.block);
    expect(v.stages[5].action, isNull);
    files.sim.execute(
      'INSERT INTO pledge(pledge_id, version, sentence_1, sentence_2, sentence_3, written_at, decision_id) '
      'VALUES (?, 1, ?, ?, ?, ?, ?)',
      <Object?>[
        'PL-1',
        '첫 문장',
        '둘째 문장',
        '셋째 문장',
        clock.nowUtc().toIso8601String(),
        'D-PLEDGE-1',
      ],
    );
    await until(() => got.last.stages[1].state == StepState.verified);
    expect(got.last.stages[1].slotId, isNull);
    // ② 끝 → ③ = 원천 없음(UNKNOWN · 슬롯 없음).
    expect(got.last.stages[2].gate?.state, GateState.unknown);
    expect(got.last.stages[2].slotId, isNull);
  });

  test(
    '🔴 마무리(R127) — 모의 개시 뒤 = ① 설정 해시 줄 · ⑥ «시작 상태를 선언했습니다»(엔진 저장소 그대로)',
    () async {
      final P0sOpsConfig cfg = P0sOpsConfig.of(
        P0sHumanInputs(aSymbol: '999990', accountByStrategy: _accounts),
      );
      final String hash = SqliteConfigVersionStore(
        files.sim,
        clock: clock,
      ).register(cfg.content());
      final SqliteOnboardingStore s = store();
      expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
      expect(
        s
            .declareSimOpening(
              SelfReportBalance(
                asOfTradeDate: const TradeDate('2026-12-01'),
                purpose: SelfReportPurpose.simOpening,
                sessionStartedAt: clock.now,
                lines: const <SelfReportLine>[],
                cashKrw: Decimal.parse('10000000'),
                accountAlias: 'general',
                declaredComplete: true,
                context: const CommandContext(
                  runMode: RunMode.simInternal,
                  operatingMode: OperatingMode.autoTrade,
                  leaseEpoch: 0,
                  deviceId: 'dev-1',
                ),
              ),
              accountByStrategy: _accounts,
              configHash: hash,
            )
            .ok,
        true,
      );
      final OnboardingFinishVm v = await OperatorOnboardingRepository(rt)
          .watchFinish()
          .first;
      expect(v.stages[0].lines, contains('설정 해시 $hash'));
      expect(v.stages[5].lines, contains('시작 상태를 선언했습니다'));
    },
  );

  test(
    '🔴 첫 실행 판정 = committed_at — 없음 → 고름(아직) → 확정 = 끝 · 바뀔 때 다시 낸다(실제 갱신 훅)',
    () async {
      final List<bool> got = <bool>[];
      final StreamSubscription<bool> sub = watchOnboardingDone(rt)
          .listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got, <bool>[false]);
      store().selectOperatingMode(OperatingMode.autoTrade);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(got, <bool>[false]);
      files.sim.execute(
        'UPDATE onboarding_choice SET committed_at = ? WHERE id = 1',
        <Object?>[clock.nowUtc().toIso8601String()],
      );
      await until(() => got.length >= 2);
      expect(got, <bool>[false, true]);
    },
  );
}
