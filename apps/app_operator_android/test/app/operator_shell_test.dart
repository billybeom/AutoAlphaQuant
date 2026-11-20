// E11p3d-1 셸 뼈대 조립(설계 13 §8 R104) — 실제 앱 루트 + 실제 주입 목록 + 실 SQLite(알림 저장).
//
// 🔴 잡는 것: 실물 있는 칸만 주입해도 셸이 선다 · 알림 센터 · 상세 = 실물 원장 · 올리지 않은 라우트 = «자리 부재»(크래시 아님).

import 'dart:io';

import 'package:app_operator_android/app/operator_ops_status.dart';
import 'package:app_operator_android/app/operator_ops_summary.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_safety.dart';
import 'package:app_operator_android/app/operator_settings_actions.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/safety/biometric_sign_field.dart';
import 'package:app_operator_android/secret/kis_key_set_field.dart';
import 'package:broker_gateway/broker_gateway.dart' show KisKeySet;
import 'package:core_engine/core_engine.dart'
    show
        BlockBoardTexts,
        DeviceRiskFacts,
        RuleChangeGateTexts,
        HoldingsTexts,
        KillSwitchScreenTexts,
        LiveObservationConfig,
        P0sHumanInputs,
        ReconClearTexts,
        TrustedClock,
        alertInboxOf;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show P0sHumanDecision, SqliteAlertSink, SqliteOnboardingStore, storedAlerts;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertCodes,
        AlertItem,
        AppRoutes,
        BlockFlag,
        DecisionReasonCodes,
        FlagIds,
        OnboardingSlotIds,
        OperatingMode,
        OpsSlotIds;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_analytics/planner.dart'
    show
        DepositPlannerScreen,
        plannerCommandApiProvider,
        plannerConfigRepositoryProvider,
        plannerWhatIfApiProvider;
import 'package:ui_analytics/ui_analytics.dart'
    show
        RebalanceEventScreen,
        RebalancePreviewScreen,
        RebalanceTimelineScreen,
        analyticsClockProvider,
        analyticsLinkOpenerProvider,
        analyticsWhatIfApiProvider,
        rebalanceRepositoryProvider,
        safetyRepositoryProvider;
import 'package:ui_journal/ui_journal.dart'
    show
        LedgerDiffs,
        LedgerRepairs,
        journalClockProvider,
        journalHoldingsRepositoryProvider,
        journalLedgerRepositoryProvider,
        journalLinkOpenerProvider,
        journalRebalanceRepositoryProvider,
        journalSafetyRepositoryProvider;
import 'package:ui_safety/sim_opening.dart' show SimOpeningCash;
import 'package:ui_safety/ui_safety.dart'
    show
        BlockBoardScreen,
        KillResumeGateScreen,
        KillSwitchScreen,
        KillSwitchSlot,
        PledgePanel,
        ResumeGateScreen,
        HandoverWizardScreen,
        ResumeReportScreen,
        RuleChangeGateScreen,
        safetyBlockBoardRepositoryProvider,
        safetyKillCommandApiProvider,
        safetyKillSwitchGateRepositoryProvider,
        safetyHandoverRepositoryProvider,
        safetyResumeGateRepositoryProvider,
        safetyRuleChangeGateRepositoryProvider,
        safetySettingsActionsProvider;
import 'package:ui_settings/ui_settings.dart'
    show
        Accounts,
        Connections,
        Credentials,
        Devices,
        Diagnostics,
        MonthlyContribution,
        SettingsHome,
        SettingsSlotBuilder,
        settingsActionsProvider,
        settingsClockProvider,
        settingsLinkOpenerProvider,
        settingsOpsStatusRepositoryProvider,
        settingsRepositoryProvider,
        settingsSlotBuilderProvider;
import 'package:ui_shell/ui_shell.dart';

import '../engine/support.dart';

/// 🆕 R157 — 고정 신뢰 시각(E11k 전 · 시험만).
class _FixedTrusted implements TrustedClock {
  const _FixedTrusted(this.at);

  final DateTime at;

  @override
  DateTime? trustedNowUtc() => at;
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late Directory dir;
  late LedgerFiles files;
  late OperatorRuntime rt;
  late ProviderContainer container;
  bool disposed = false;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 22, 9, 30));
    dir = tempLedgerDir();
    files = openFiles(dir, clock);
    rt = OperatorRuntime(files: files, clock: clock);
    container = ProviderContainer(overrides: operatorShellOverrides(rt));
    disposed = false;
  });
  tearDown(() {
    if (!disposed) container.dispose();
    files.close();
  });

  /// 🆕 R125 — [onboarded] = 온보딩 확정 행을 먼저 둔다(루트 = 셸 · 아니면 온보딩 내비게이터).
  /// 🔵 확정이 «바뀌는» 순간의 다시 냄은 SQLite 갱신 훅(실제 이벤트 루프)이라 위젯 시험의 가짜 시간 밖 —
  ///    그 몫은 `operator_onboarding_test`(실제 시간)가 지킨다.
  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    if (onboarded) {
      files.sim.execute(
        'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
        <Object?>[
          OperatingMode.autoTrade.wire,
          clock.nowUtc().toIso8601String(),
          clock.nowUtc().toIso8601String(),
        ],
      );
    }
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AutoAlphaQuantOperatorApp(shell: true),
      ),
    );
    await tester.pump();
  }

  Future<void> ready(WidgetTester tester) async {
    // 확정 행은 pumpApp 이 먼저 뒀다 — 여기는 모드 행만.
    writeSimMode(files.sim, clock);
    final EngineBoot b = await tester.runAsync(
      () => bootEngine(files, clock: clock),
    ) as EngineBoot;
    rt.view.value = operatorViewOf(b, files);
    await tester.pump();
    await tester.pump();
  }

  Future<void> open(WidgetTester tester, String link) async {
    container.read(shellLinkOpenerProvider).open(link);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  test(
    '🔴 화면이 읽는 원장 = 기동 판정이 고른 파일(거부 live = live 파일 · 첫 깨어남 전 = sim)',
    () async {
      expect(identical(container.read(operatorDbProvider), files.sim), true);
      writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
      final Database live = writeLiveMode(dir, clock);
      addTearDown(live.close);
      rt.view.value = operatorViewOf(
        await bootEngine(files, clock: clock),
        files,
      );
      expect(
        identical(container.read(operatorDbProvider), files.liveIfExists()),
        true,
      );
    },
  );

  test('🔴 조립 셸의 링크 열기(R107) — https = 바깥 · 앱 링크는 셸에 남는다', () async {
    final List<String> outside = <String>[];
    final ProviderContainer c = ProviderContainer(
      overrides: operatorShellOverrides(
        OperatorRuntime(
          files: files,
          clock: clock,
          openExternal: (String u) async {
            outside.add(u);
            return true;
          },
        ),
      ),
    );
    addTearDown(c.dispose);
    c.read(shellLinkOpenerProvider).open('https://healthchecks.io');
    c.read(shellLinkOpenerProvider).open(AppRoutes.alertsInbox);
    await Future<void>.delayed(Duration.zero);
    expect(outside, <String>['https://healthchecks.io']);
  });

  testWidgets('🔴 깨어남 전(온보딩 확정 뒤) = 셸이 플래그를 기다린다(크래시 없음)', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(ShellRoot), findsOneWidget);
  });

  testWidgets(
    '🔴 첫 실행(R125 · 미결 158) — 온보딩 확정 전 = 온보딩 첫 화면(셸 아님) · 링크 = 온보딩 내비게이터로',
    (WidgetTester tester) async {
      await pumpApp(tester, onboarded: false);
      // 판정 첫 값 · 첫 화면 VM = 다음 프레임들.
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(ShellRoot), findsNothing);
      expect(find.byType(OnboardingStart), findsOneWidget);
      expect(find.text('처음 시작하기'), findsOneWidget);
      await open(tester, AppRoutes.onboardingModePick);
      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingModePick), findsOneWidget);
      await open(tester, AppRoutes.onboardingSteps);
      expect(find.byType(OnboardingStepList), findsOneWidget);
      await open(
        tester,
        AppRoutes.onboardingStep.replaceFirst(':stepId', 'o_02'),
      );
      expect(find.byType(OnboardingStepDetail), findsOneWidget);
      // 🆕 R127 — 마무리(O-04) 등록.
      await open(tester, AppRoutes.onboardingFinish);
      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingFinish), findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets('🔴 준비 = 셸이 선다 · 홈 = 운영 홈(R133) · 일지 = 자리 부재(실물 원천 전)', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('s01-home-slot')), findsNothing);
    expect(find.byType(OpsHome), findsOneWidget);
    expect(find.byKey(const Key('h01-asof')), findsOneWidget);
    // 블록 7 = 엔진 문장 그대로(빈 원장 = 0건 · 정의 없는 칸 = 판정 보류).
    expect(find.text('오늘 주문 0건'), findsOneWidget);
    expect(find.text('오늘 오류 0건'), findsOneWidget);
    expect(find.text('신호 일치 판정 보류'), findsOneWidget);
    // 🆕 R172 — 슬리브 비중 = 원장 배분(개시 전 = 엔진 빈 문장) · 🔴 원천 없는 둘(안내 · 실사 카드) = 부재.
    expect(find.byKey(const Key('h01-alloc-fail')), findsNothing);
    expect(find.byKey(const Key('h01-alloc')), findsOneWidget);
    expect(find.text(HoldingsTexts.allocationEmpty), findsOneWidget);
    expect(find.byKey(const Key('h01-fail')), findsNothing);
    await open(tester, AppRoutes.journalTimeline);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('s01-placeholder')), findsOneWidget);
    // 홈 흐름의 1분 타이머는 컨테이너가 닫힐 때 멈춘다 — 시험 안에서 닫는다.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets('🔴 운영 리듬(H-02 · R133) = 조립 셸에 등록 · 원천 있는 두 행', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.opsRhythm);
    expect(tester.takeException(), isNull);
    expect(find.byType(OpsRhythm), findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    // 홈(아래 라우트)의 블록 8 도 같은 행을 그린다 — 리듬 화면 안에서만 찾는다.
    Finder inRhythm(String t) =>
        find.descendant(of: find.byType(OpsRhythm), matching: find.text(t));
    expect(inRhythm('월간 정기 리밸런싱'), findsOneWidget);
    expect(inRhythm('월 납입'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets('🔴 알림 센터 · 상세 = 엔진 원장의 알림(같은 연결)', (WidgetTester tester) async {
    await pumpApp(tester);
    await ready(tester);
    await tester.runAsync(
      () => SqliteAlertSink(
        files.sim,
        clock: clock,
      ).emit('sim-auto-daily_reconcile', <String>{AlertCodes.reconMismatch}),
    );
    final AlertItem a = alertInboxOf(
      rows: storedAlerts(files.sim),
      nowUtc: clock.nowUtc(),
    ).first;
    await open(tester, AppRoutes.alertsInbox);
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertCenter), findsOneWidget);
    expect(find.text(a.title), findsWidgets);
    await open(
      tester,
      AppRoutes.alertDetail.replaceFirst(':alertId', a.alertId),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDetail), findsOneWidget);
    expect(find.text(a.title), findsWidgets);
    // 🆕 R133 — 홈 흐름의 1분 타이머는 컨테이너가 닫힐 때 멈춘다 — 시험 안에서 닫는다.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets('🔴 감시 보드(R109) = 조립 셸에 등록 · 로컬 판정 행이 선다(바깥 없음 = 머리 문구)', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.opsWatchdog);
    expect(tester.takeException(), isNull);
    expect(find.byType(WatchdogBoard), findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    // 보드 흐름의 1분 타이머는 컨테이너가 닫힐 때 멈춘다 — 시험 안에서 닫는다.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets(
    '🔴 원장 대조 · 수리 기록(R111) = 조립 셸에 등록 · 같은 원장(빈 원장 = 빈 목록 · 크래시 없음)',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      await open(tester, AppRoutes.ledgerDiffs);
      expect(tester.takeException(), isNull);
      expect(find.byType(LedgerDiffs), findsOneWidget);
      await open(tester, AppRoutes.ledgerRepairs);
      expect(tester.takeException(), isNull);
      expect(find.byType(LedgerRepairs), findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      // 🆕 R113 — 안전 흐름(배너)의 1분 타이머는 컨테이너가 닫힐 때 멈춘다 — 시험 안에서 닫는다.
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  test('🔴 주입 의무 표(R113) — 실물이 있는 칸은 전부 주입 · 안전 = 한 인스턴스 · 운영 상태 = 한 인스턴스', () {
    final Object safety = container.read(operatorSafetyProvider);
    expect(safety, isA<OperatorSafetyRepository>());
    for (final Object s in <Object>[
      container.read(shellSafetyRepositoryProvider),
      container.read(journalSafetyRepositoryProvider),
      container.read(safetyRepositoryProvider),
    ]) {
      expect(identical(s, safety), true);
    }
    // 🆕 R133 — 홈 오늘 요약 · 리듬 = 한 인스턴스 · 원천 없는 셋 = operator 의 «원천 없음»(받침대 아님).
    expect(
      identical(
        container.read(shellOpsSummaryRepositoryProvider),
        container.read(operatorOpsSummaryProvider),
      ),
      true,
    );
    expect(
      container.read(shellAdviceRepositoryProvider),
      isA<OperatorAdviceRepository>(),
    );
    // 🆕 R172 — 다음 리밸런싱(H6-3 하단) = 한 인스턴스.
    expect(
      identical(
        container.read(journalRebalanceRepositoryProvider),
        container.read(operatorRebalanceProvider),
      ),
      true,
    );
    // 🆕 R173 — M7 리밸런싱 칸 = 같은 인스턴스 · 초안 창구 = 엔진 What-if(원장 어댑터).
    expect(
      identical(
        container.read(rebalanceRepositoryProvider),
        container.read(operatorRebalanceProvider),
      ),
      true,
    );
    expect(
      container.read(analyticsWhatIfApiProvider),
      isA<OperatorWhatIfApi>(),
    );
    // 🆕 R178 — M5-1 킬스위치 읽기 = 한 인스턴스 · 명령 = 기기 id 없음 → null(버튼 부재).
    expect(
      identical(
        container.read(safetyKillSwitchGateRepositoryProvider),
        container.read(operatorKillSwitchGateProvider),
      ),
      true,
    );
    expect(container.read(safetyKillCommandApiProvider), isNull);
    // 🆕 R180 — M5-2 재개판 초안 = 게이트 읽기 · 문항 제출 같은 인스턴스.
    expect(
      identical(
        container.read(operatorKillSwitchGateProvider).draft,
        container.read(operatorKillResumeDraftProvider),
      ),
      true,
    );
    expect(
      identical(
        container.read(operatorSafetyActionsProvider).draft,
        container.read(operatorKillResumeDraftProvider),
      ),
      true,
    );
    // 🆕 R185 — M5-5 차단 보드 읽기 = 한 인스턴스 · 레지스트리 등록.
    expect(
      identical(
        container.read(safetyBlockBoardRepositoryProvider),
        container.read(operatorBlockBoardProvider),
      ),
      true,
    );
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5BlockBoard),
      true,
    );
    // 🆕 R189 — 폰 = RECON 해제 폼을 낸다(쓰기 창구 늘 · 잠김 0).
    expect(container.read(operatorBlockBoardProvider).reconClearable, true);
    // 🆕 R186 — X2 재개 리포트 · 게이트 읽기 = 한 인스턴스 · 레지스트리 둘 · 🆕 R195 계절 3택 쓰기 = 켜짐.
    expect(
      identical(
        container.read(safetyResumeGateRepositoryProvider),
        container.read(operatorResumeGateProvider),
      ),
      true,
    );
    expect(container.read(operatorResumeGateProvider).canChoose, true);
    for (final String r in <String>[
      AppRoutes.x2ResumeReport,
      AppRoutes.x2ResumeGate,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(r), true, reason: r);
    }
    // 🆕 R188 — M5-9 규칙 변경 게이트 읽기 = 한 인스턴스 · 레지스트리.
    expect(
      identical(
        container.read(safetyRuleChangeGateRepositoryProvider),
        container.read(operatorRuleChangeGateProvider),
      ),
      true,
    );
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5RuleChangeGate),
      true,
    );
    // 🆕 R191 — M5-11 위저드 읽기 = 한 인스턴스 · 동작 = 설정 동작 인스턴스(시험 조립 = 금고 0 → null) ·
    //    레지스트리 둘(`handoverStatus` = 같은 본문 · K173) · M5-10 게이트 = 빈 자리(K174).
    expect(
      identical(
        container.read(safetyHandoverRepositoryProvider),
        container.read(operatorHandoverRepositoryProvider),
      ),
      true,
    );
    expect(
      identical(
        container.read(safetySettingsActionsProvider),
        container.read(operatorSettingsActionsProvider),
      ),
      true,
    );
    expect(container.read(operatorHandoverRepositoryProvider).canAct, false);
    for (final String r in <String>[
      AppRoutes.m5HandoverWizard,
      AppRoutes.handoverStatus,
    ]) {
      expect(kOperatorRouteBodies.byPattern.containsKey(r), true, reason: r);
    }
    expect(
      kOperatorRouteBodies.byPattern.containsKey(AppRoutes.m5HandoverGate),
      false,
    );
    // 🆕 R182 — M8 운영 슬롯 빌더 = 셸 킬스위치 자리(ui_safety 자리 위젯) · 인쇄 = 자리 부재.
    expect(
      identical(container.read(shellOpsSlotBuilderProvider), operatorOpsSlot),
      true,
    );
    expect(operatorOpsSlot(OpsSlotIds.killSwitch), isA<KillSwitchSlot>());
    expect(
      operatorOpsSlot(OpsSlotIds.emergencyCardPrint).key,
      const Key('m8-slot-absent'),
    );
    // 🆕 R174 — S7-4 플래너 칸 = 같은 What-if · 같은 명령 API · 셸 설정 원천(한 인스턴스).
    expect(
      identical(
        container.read(plannerWhatIfApiProvider),
        container.read(operatorWhatIfApiProvider),
      ),
      true,
    );
    expect(
      identical(
        container.read(plannerCommandApiProvider),
        container.read(operatorCommandApiProvider),
      ),
      true,
    );
    expect(
      identical(
        container.read(plannerConfigRepositoryProvider),
        container.read(shellConfigRepositoryProvider),
      ),
      true,
    );
    // 🆕 R171 — 보유 = 셸 홈 · 일지(H6-1) 한 인스턴스.
    final Object holdings = container.read(operatorHoldingsProvider);
    expect(holdings, isA<OperatorHoldingsRepository>());
    for (final Object h in <Object>[
      container.read(shellHoldingsRepositoryProvider),
      container.read(journalHoldingsRepositoryProvider),
    ]) {
      expect(identical(h, holdings), true);
    }
    expect(
      container.read(shellLedgerTrustRepositoryProvider),
      isA<OperatorLedgerTrustRepository>(),
    );
    final Object ops = container.read(operatorOpsStatusProvider);
    expect(ops, isA<OperatorOpsStatusRepository>());
    expect(
      identical(container.read(shellOpsStatusRepositoryProvider), ops),
      true,
    );
    expect(
      identical(container.read(settingsOpsStatusRepositoryProvider), ops),
      true,
    );
    for (final Object c in <Object>[
      container.read(shellClockProvider),
      container.read(journalClockProvider),
      container.read(analyticsClockProvider),
      container.read(settingsClockProvider),
    ]) {
      expect(identical(c, clock), true);
    }
    final Object link = container.read(shellLinkOpenerProvider);
    for (final Object l in <Object>[
      container.read(journalLinkOpenerProvider),
      container.read(analyticsLinkOpenerProvider),
      container.read(settingsLinkOpenerProvider),
    ]) {
      expect(identical(l, link), true);
    }
  });

  testWidgets('🔴 원장 대조 화면 = 엔진 원장의 차단 배너(R113 — 빠지면 소리 없이 사라진다)', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    files.sim.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
      <Object?>[
        FlagIds.ledgerIntegrity,
        clock.nowUtc().toIso8601String(),
        '시험 차단',
      ],
    );
    final BlockFlag f = OperatorSafetyRepository(rt).state().activeFlags.single;
    await open(tester, AppRoutes.ledgerDiffs);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(LedgerDiffs), findsOneWidget);
    // 🆕 R133 — 홈(아래 라우트) 블록 3 도 같은 플래그를 그린다 — 대조 화면 안에서만 찾는다.
    expect(
      find.descendant(
        of: find.byType(LedgerDiffs),
        matching: find.text(f.label),
      ),
      findsOneWidget,
    );
    // 안전 흐름의 1분 타이머는 컨테이너가 닫힐 때 멈춘다 — 시험 안에서 닫는다.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  test('🔴 온보딩 슬롯 빌더(R115) = 주입됨 · SECRET_KIS_MOCK = 키 세트 칸(실행 묶음의 넘김 · 캡처 막기) · 🆕 PLEDGE_WRITE = 서약 칸(R157) · 🆕 BIOMETRIC_SIGN = 생체 서명 칸(R159) · 나머지 = 자리 부재', () {
    final ShellSlotBuilder? b = container.read(
      shellOnboardingSlotBuilderProvider,
    );
    expect(b, isNotNull);
    for (final String id in OnboardingSlotIds.values) {
      final Widget w = b!(id);
      if (id == OnboardingSlotIds.secretKisMock) {
        expect(w, isA<KisKeySetField>());
        final KisKeySetField f = w as KisKeySetField;
        expect(identical(f.handoff, rt.secrets), true);
        expect(identical(f.janitor, rt.clipboard), true);
        expect(identical(f.secure, rt.secure), true);
      } else if (id == OnboardingSlotIds.pledgeWrite) {
        expect(w, isA<PledgePanel>());
      } else if (id == OnboardingSlotIds.biometricSign) {
        expect(w, isA<BiometricSignField>());
      } else {
        expect(w.key, const Key('m4-slot-absent'), reason: id);
      }
    }
    // 🆕 R196 — 실전 세트 칸 = 키 세트 칸(실전 · ISA) · 대사 전용 = 아직 자리 부재.
    expect((b!('SECRET_KIS_LIVE') as KisKeySetField).set, KisKeySet.live);
    expect((b('SECRET_KIS_ISA') as KisKeySetField).set, KisKeySet.isa);
    expect(b('SECRET_KIS_RECONCILE').key, const Key('m4-slot-absent'));
  });

  test(
    '🔴 설정 · 온보딩 동작(R118) — 금고 · 검증 HTTP 가 있으면 주입(한 인스턴스) · 없으면 null(컨트롤 부재)',
    () {
      expect(container.read(settingsActionsProvider), isNull);
      expect(container.read(shellOnboardingActionsProvider), isNull);
      final ProviderContainer c = ProviderContainer(
        overrides: operatorShellOverrides(
          OperatorRuntime(
            files: files,
            clock: clock,
            vault: MemorySecretVault(),
            kisHttp: MockClient(
              (http.Request r) async => http.Response('', 500),
            ),
          ),
        ),
      );
      addTearDown(c.dispose);
      final Object? a = c.read(settingsActionsProvider);
      expect(a, isA<OperatorSettingsActions>());
      expect(identical(c.read(shellOnboardingActionsProvider), a), true);
    },
  );

  test('🔴 내비게이터 키(R125) = 온보딩 중 온보딩 키 · 확정 뒤 셸 키 — 두 내비게이터가 키를 나눠 쓰지 않는다(실제 갱신 훅)', () async {
    Future<void> until(bool Function() ok) async {
      final Stopwatch w = Stopwatch()..start();
      while (!ok() && w.elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    final ProviderSubscription<GlobalKey<NavigatorState>> sub = container
        .listen(shellNavigatorKeyProvider, (_, _) {}, fireImmediately: true);
    addTearDown(sub.close);
    await until(() => container.read(operatorOnboardingDoneProvider).hasValue);
    final GlobalKey<NavigatorState> onb = container.read(
      operatorOnboardingNavigatorKeyProvider,
    );
    final GlobalKey<NavigatorState> shell = container.read(
      operatorShellNavigatorKeyProvider,
    );
    expect(identical(onb, shell), false);
    expect(identical(container.read(shellNavigatorKeyProvider), onb), true);
    files.sim.execute(
      'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
      <Object?>[
        OperatingMode.autoTrade.wire,
        clock.nowUtc().toIso8601String(),
        clock.nowUtc().toIso8601String(),
      ],
    );
    await until(
      () => container.read(operatorOnboardingDoneProvider).valueOrNull == true,
    );
    expect(identical(container.read(shellNavigatorKeyProvider), shell), true);
  });

  test('🔴 설정 슬롯 빌더(R129 · M4-12 ⑦ 주입 의무) = 비-null · 모의 키 칸 = 온보딩과 같은 위젯 · 설정 읽기 모델 = operator', () {
    final SettingsSlotBuilder? b = container.read(settingsSlotBuilderProvider);
    expect(b, isNotNull);
    final Widget w = b!(OnboardingSlotIds.secretKisMock);
    expect(w, isA<KisKeySetField>());
    expect(identical((w as KisKeySetField).handoff, rt.secrets), true);
    expect((b('SECRET_KIS_LIVE') as KisKeySetField).set, KisKeySet.live);
    expect(b('SECRET_KIS_RECONCILE').key, const Key('m4-slot-absent'));
    expect(
      container.read(settingsRepositoryProvider),
      isA<OperatorSettingsRepository>(),
    );
  });

  testWidgets('🔴 S02 증권사 키(R129) = 조립 셸에 등록 · 모의 카드 · 크래시 없음', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.settingsCredentials);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Credentials), findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets(
    '🔴 알림 확인(R147) — 기기 id 있음 = «확인» 버튼 · 누르면 엔진 원장에 확인 · 기기 id 없음 = 버튼 부재',
    (WidgetTester tester) async {
      // 기본 조립(기기 id 없음) = 주입 없음.
      expect(container.read(shellAlertCommandApiProvider), isNull);
      container.dispose();
      rt = OperatorRuntime(
        files: files,
        clock: clock,
        deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
      );
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      expect(
        identical(
          container.read(shellAlertCommandApiProvider),
          container.read(operatorCommandApiProvider),
        ),
        true,
      );
      await pumpApp(tester);
      await ready(tester);
      await tester.runAsync(
        () => SqliteAlertSink(
          files.sim,
          clock: clock,
        ).emit('sim-auto-daily_reconcile', <String>{AlertCodes.reconMismatch}),
      );
      final AlertItem a = alertInboxOf(
        rows: storedAlerts(files.sim),
        nowUtc: clock.nowUtc(),
      ).first;
      await open(
        tester,
        AppRoutes.alertDetail.replaceFirst(':alertId', a.alertId),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      final Finder ack = find.byKey(const ValueKey<String>('n02-ack'));
      expect(ack, findsOneWidget);
      await tester.tap(ack);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        files.sim.select(
          'SELECT COUNT(*) AS n FROM alert_ack WHERE alert_id = ?',
          <Object?>[a.alertId],
        ).first['n'],
        1,
      );
      expect(find.text('실행됨'), findsWidgets);
      // 확인 기록이 원장 감시(갱신 훅 · 0초 타이머)를 깨운다 — 가짜 시간을 흘려 보내고 닫는다.
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 S03 계좌 · 매핑(R151) = 조립 셸에 등록 · 모의 «등록 전» · 슬리브 셋 미지정(운영 설정 전)',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      await open(tester, AppRoutes.settingsAccounts);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      final Finder screen = find.byType(Accounts);
      expect(screen, findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      Finder inScreen(String t) =>
          find.descendant(of: screen, matching: find.text(t));
      expect(inScreen('모의투자'), findsWidgets);
      expect(inScreen('등록 전'), findsWidgets);
      expect(inScreen('슬리브 A'), findsOneWidget);
      expect(inScreen('미지정 — 이 슬리브의 주문은 내지 않습니다.'), findsNWidgets(3));
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 M5-14 가상 초기금(R156) = 조립 셸에 등록 · 기기 id 없음 = 제출 버튼 부재(칸은 보인다)',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      await open(tester, AppRoutes.m5SimOpeningCash);
      expect(tester.takeException(), isNull);
      expect(find.byType(SimOpeningCash), findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(find.byKey(const Key('m5-14-cash')), findsOneWidget);
      expect(find.byKey(const Key('m5-14-submit')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 M5-14(R156) — 온보딩 중 링크로 열어 넣으면 엔진이 계좌별로 나눠 넣는다 · 접수증 = 엔진 문장 · 칸 · 버튼 잠금',
    (WidgetTester tester) async {
      container.dispose();
      rt = OperatorRuntime(
        files: files,
        clock: clock,
        deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
        humanDecision: P0sHumanDecision(
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
        ),
      );
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      await pumpApp(tester, onboarded: false);
      await open(tester, AppRoutes.m5SimOpeningCash);
      expect(tester.takeException(), isNull);
      expect(find.byType(SimOpeningCash), findsOneWidget);
      await tester.enterText(find.byKey(const Key('m5-14-cash')), '10,000,000');
      await tester.tap(find.byKey(const Key('m5-14-submit')));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('가상 초기금 10,000,000원을 계좌 3곳에 나눠 넣었습니다.'), findsOneWidget);
      expect(
        files.sim.select(
          'SELECT COUNT(*) AS n FROM decision_log WHERE reason_code = ?',
          <Object?>[DecisionReasonCodes.simOpeningBalance],
        ).first['n'],
        1,
      );
      expect(
        tester.widget<TextField>(find.byKey(const Key('m5-14-cash'))).enabled,
        isFalse,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('m5-14-submit')))
            .onPressed,
        isNull,
      );
      // 선언 기록이 원장 감시(갱신 훅 · 0초 타이머)를 깨운다 — 가짜 시간을 흘려 보내고 닫는다.
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 O-04 ② 서약(R157) = 마무리 슬롯에 M5-8 칸 · 세 문장 저장 = 엔진 실행(엔진 문장) · 서약 1행',
    (WidgetTester tester) async {
      container.dispose();
      rt = OperatorRuntime(
        files: files,
        clock: clock,
        trusted: _FixedTrusted(DateTime.utc(2026, 11, 19, 0, 30)),
      );
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      await pumpApp(tester, onboarded: false);
      await open(tester, AppRoutes.onboardingFinish);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(PledgePanel), findsOneWidget);
      for (final (int i, String t) in <String>[
        '정한 날에만 산다',
        '하락에도 규칙을 지킨다',
        '멈춘 뒤엔 점검부터',
      ].indexed) {
        final Finder f = find.byKey(ValueKey<String>('m5-8-input-$i'));
        await tester.ensureVisible(f);
        await tester.enterText(f, t);
      }
      await tester.ensureVisible(find.byKey(const Key('m5-8-save')));
      await tester.tap(find.byKey(const Key('m5-8-save')));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('서약 첫 판을 저장했습니다.'), findsOneWidget);
      expect(
        files.sim.select('SELECT COUNT(*) AS n FROM pledge').first['n'],
        1,
      );
      // 🔵 «저장 → ② 닫힘»(갱신 훅 = 실제 이벤트 루프 · 가짜 시간 밖) = `operator_pledge_test`(실제 시간)가 지킨다.
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets('🔴 S10 진단(R160) = 조립 셸에 등록 · 골든 = 판정 보류 · 무결성 카드 · 크래시 없음', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.settingsDiagnostics);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder screen = find.byType(Diagnostics);
    expect(screen, findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    Finder inScreen(String t) =>
        find.descendant(of: screen, matching: find.text(t));
    expect(inScreen('골든벡터 판정 보류'), findsOneWidget);
    expect(inScreen('무결성 자가진단'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets(
    '🔴 M7 리밸런싱(R173) = 조립 셸에 등록 · 회차 0 = 엔진 빈 문장 · 다음 회차 · 초안 버튼 = 예정이 있을 때만 · 크래시 없음',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      Future<void> settle() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
        await tester.pump();
      }

      await open(tester, AppRoutes.rebalanceHistory);
      await settle();
      expect(tester.takeException(), isNull);
      final Finder history = find.byType(RebalanceTimelineScreen);
      expect(history, findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(
        find.descendant(of: history, matching: find.text('아직 리밸런싱 회차가 없습니다')),
        findsOneWidget,
      );
      await open(tester, AppRoutes.rebalancePreview);
      await settle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RebalancePreviewScreen), findsOneWidget);
      final bool countdown = find
          .byKey(const Key('s76c-countdown'))
          .evaluate()
          .isNotEmpty;
      expect(
        countdown || find.byKey(const Key('s76c-empty')).evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.byKey(const Key('s76c-preview-button')),
        countdown ? findsOneWidget : findsNothing,
      );
      await open(tester, 'aaq://rebalance/event/nope');
      await settle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RebalanceEventScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets('🔴 S7-4 납입 플래너 · S13 월 납입(R174) = 조립 셸에 등록 · 크래시 없음', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
    }

    await open(tester, AppRoutes.planDeposit);
    await settle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DepositPlannerScreen), findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    await open(tester, AppRoutes.settingsContribution);
    await settle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MonthlyContribution), findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets(
    '🔴 M5-1 킬스위치(R178) = 조립 셸에 등록 · 꺼짐 머리 · 기기 id 없음 = 발동 버튼 부재 · 크래시 없음',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      await open(tester, AppRoutes.m5KillSwitch);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      final Finder screen = find.byType(KillSwitchScreen);
      expect(screen, findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(
        find.descendant(of: screen, matching: find.text('킬스위치 꺼짐')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m51-activate')), findsNothing);
      // 🆕 R182 — 링크 화면 앱바 자리 = 같은 자리 위젯(기기 id 없음 = 버튼 부재).
      expect(
        find.descendant(
          of: find.byKey(const Key('s01-link-kill-slot')),
          matching: find.byType(KillSwitchSlot),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ks-slot-activate')), findsNothing);
      // 🆕 R180 — M5-2 재개 게이트 = 등록 · 꺼짐 꼴(받을 문항 0).
      await open(tester, AppRoutes.m5ReleaseGate);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(KillResumeGateScreen), findsOneWidget);
      expect(find.byKey(const Key('m52-confirm')), findsNothing);
      // 🆕 R185 — M5-5 차단 보드 = 등록 · 막힌 것 0 · 빈 문장 · 사다리 지금 단 = 정상 · 킬스위치 진입.
      await open(tester, AppRoutes.m5BlockBoard);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      final Finder board = find.byType(BlockBoardScreen);
      expect(board, findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(
        find.descendant(
          of: board,
          matching: find.text(BlockBoardTexts.clearHeadline),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-empty')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('m55-ladder-NORMAL')),
          matching: find.byKey(const Key('m55-ladder-now')),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-kill')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 셸 킬스위치 자리(R182) — 홈 앱바 = 발동 버튼(한 번 · 확인 대화 0) → 원장 켜짐 → 상태 칩 → M5-1 화면',
    (WidgetTester tester) async {
      // 기기 id 있는 조립(명령 API 주입) — 기본 setUp 컨테이너는 닫고 바꾼다.
      container.dispose();
      rt = OperatorRuntime(files: files, clock: clock, deviceId: 'dev-1');
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      await pumpApp(tester);
      await ready(tester);
      Future<void> settle() async {
        for (int i = 0; i < 3; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump();
        }
      }

      await settle();
      expect(tester.takeException(), isNull);
      final Finder home = find.byKey(const Key('s01-kill-slot'));
      expect(home, findsOneWidget);
      final Finder activate = find.descendant(
        of: home,
        matching: find.byKey(const Key('ks-slot-activate')),
      );
      expect(activate, findsOneWidget);
      expect(
        find.descendant(
          of: activate,
          matching: find.text(KillSwitchScreenTexts.activate),
        ),
        findsOneWidget,
      );

      await tester.tap(activate);
      await settle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      // 원장 = 켜짐(발동 기기 = 운영 폰 별칭 · 해제 전).
      final List<Map<String, Object?>> ks = files.sim
          .select(
            'SELECT activated_at, activated_by, cleared_at FROM kill_switch_state',
          )
          .toList();
      expect(ks.single['activated_at'], isNotNull);
      expect(ks.single['activated_by'], KillSwitchScreenTexts.operatorPhone);
      expect(ks.single['cleared_at'], isNull);
      // 원장 변경 → 다시 냄(SQLite 갱신 훅)은 가짜 시간 밖(위 pumpApp 주석 · 실시간 몫 = operator_kill_switch_test) —
      // 여기서는 읽기 창구의 1분 주기 다시 읽기로 자리가 바뀌는 것을 본다.
      await tester.pump(const Duration(minutes: 1));
      await settle();
      final Finder chip = find.descendant(
        of: home,
        matching: find.byKey(const Key('ks-slot-active')),
      );
      expect(chip, findsOneWidget);
      expect(find.byKey(const Key('ks-slot-activate')), findsNothing);

      await tester.tap(chip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      expect(tester.takeException(), isNull);
      final Finder screen = find.byType(KillSwitchScreen);
      expect(screen, findsOneWidget);
      expect(
        find.descendant(of: screen, matching: find.textContaining('킬스위치 작동 중')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('s01-link-kill-slot')),
          matching: find.byKey(const Key('ks-slot-active')),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 M5-5 차단 보드(R185) — 홈 블록 3 탭 → 보드 · 켜진 킬스위치 먼저 + 원장 플래그(엔진 차례 · 표식 제외) · 대사 불일치 = 행 링크 0 · 🆕 R189 RECON 해제 폼 → 엔진 저널 함께 쓰기 → 행 빠짐 · 킬스위치 행 → M5-1',
    (WidgetTester tester) async {
      // 켜진 킬스위치 + 활성 플래그 셋(대사 불일치 · 재개 미완 · 표식 DST) — 화면이 서기 전에 원장에 둔다.
      files.sim.execute(
        'INSERT OR REPLACE INTO kill_switch_state (id, activated_at, activated_by) VALUES (1, ?, ?)',
        <Object?>[
          '2026-11-18T01:02:00.000Z',
          KillSwitchScreenTexts.operatorPhone,
        ],
      );
      for (final (String id, String at, String? origin)
          in <(String, String, String?)>[
            (FlagIds.resumeIncomplete, '2026-11-18T00:12:00.000Z', null),
            (FlagIds.dstWeek, '2026-11-17T00:00:00.000Z', null),
            (FlagIds.reconMismatch, '2026-11-18T03:30:00.000Z', 'FILL_LAG'),
          ]) {
        files.sim.execute(
          'INSERT INTO trading_block (flag_id, set_at, reason, origin_code) VALUES (?, ?, ?, ?)',
          <Object?>[id, at, 'test', origin],
        );
      }
      await pumpApp(tester);
      await ready(tester);
      Future<void> settle() async {
        for (int i = 0; i < 3; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump();
        }
      }

      await settle();
      expect(tester.takeException(), isNull);
      final Finder blocked = find.byKey(const Key('h01-blocked'));
      expect(blocked, findsOneWidget);
      await tester.ensureVisible(blocked);
      await tester.tap(blocked);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      expect(tester.takeException(), isNull);
      final Finder board = find.byType(BlockBoardScreen);
      expect(board, findsOneWidget);
      expect(
        find.descendant(
          of: board,
          matching: find.text('막힌 것 3 — 킬스위치 · 대사 불일치 · 재개 점검'),
        ),
        findsOneWidget,
      );
      final List<String> rows = <String>[
        for (final Element e
            in find
                .descendant(of: board, matching: find.byType(Card))
                .evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      expect(rows, <String>[
        'm55-row-KILL_SWITCH',
        'm55-row-${FlagIds.reconMismatch}',
        'm55-row-${FlagIds.resumeIncomplete}',
      ]);
      // 대사 불일치 = 이 보드 자신 → 링크 0 · 🆕 R186 재개 화면(X2 게이트) 등록 → 재개 미완 행 링크가 선다.
      expect(
        find.byKey(const Key('m55-row-link-RECON_MISMATCH')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('m55-row-link-RESUME_INCOMPLETE')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-empty')), findsNothing);

      // 🆕 R189 — RECON 행만 해제 폼(폰 = 쓰기 창구) → 원인 코드 + 사전 저널 세 칸 → 확인 = 엔진 «저널 함께 쓰기» →
      //    행이 빠지고 결과 = 엔진 글자 · 원장 = 해제 한 사람 «운영 폰» · 저널 RECON_CLEAR(신뢰 시각 없이도).
      expect(
        find.descendant(
          of: find.byKey(Key('m55-row-${FlagIds.reconMismatch}')),
          matching: find.byKey(const Key('m55-recon-form')),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-recon-form')), findsOneWidget);
      final Finder openForm = find.byKey(const Key('m55-recon-open'));
      await tester.ensureVisible(openForm);
      await tester.tap(openForm);
      await tester.pump();
      final Finder chip = find.byKey(const Key('m55-recon-origin-FILL_LAG'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('m55-recon-rationale')),
        '체결 보고가 늦게 왔다',
      );
      await tester.enterText(
        find.byKey(const Key('m55-recon-expected')),
        '다음 대사에서 맞는다',
      );
      await tester.enterText(
        find.byKey(const Key('m55-recon-rule')),
        '04 §3-5 ②',
      );
      final Finder clear = find.byKey(const Key('m55-recon-submit'));
      await tester.ensureVisible(clear);
      await tester.tap(clear);
      await tester.pump();
      // 원장 감시 = 다음 이벤트 루프 차례(Timer.run)로 다시 읽는다 → 시계를 조금 흘린다.
      await tester.pump(const Duration(milliseconds: 50));
      await settle();
      expect(tester.takeException(), isNull);
      expect(find.text(ReconClearTexts.cleared), findsOneWidget);
      expect(find.byKey(Key('m55-row-${FlagIds.reconMismatch}')), findsNothing);
      expect(find.byKey(const Key('m55-recon-form')), findsNothing);
      final Map<String, Object?> cleared = files.sim
          .select(
            "SELECT cleared_by, decision_id, origin_code FROM trading_block WHERE flag_id = 'RECON_MISMATCH'",
          )
          .single;
      expect(cleared['cleared_by'], KillSwitchScreenTexts.operatorPhone);
      expect(cleared['origin_code'], 'FILL_LAG');
      expect(
        files.sim.select(
          'SELECT kind FROM decision_journal WHERE journal_id = ?',
          <Object?>[cleared['decision_id']],
        ).single['kind'],
        'RECON_CLEAR',
      );

      expect(find.byKey(const Key('m55-kill')), findsOneWidget);
      // 킬스위치 행 링크 = 레지스트리에 본문이 있는 M5-1(조립 앱 hasBody) → 켜짐 화면.
      final Finder ksLink = find.byKey(const Key('m55-row-link-KILL_SWITCH'));
      await tester.ensureVisible(ksLink);
      await tester.tap(ksLink);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      expect(tester.takeException(), isNull);
      final Finder ks = find.byType(KillSwitchScreen);
      expect(ks, findsOneWidget);
      expect(
        find.descendant(of: ks, matching: find.textContaining('킬스위치 작동 중')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets(
    '🔴 X2 재개(R186 · R195) — 차단 보드 재개 미완 행 링크 → 게이트(막힌 계획 · 계절 3택 = 사람 결정 행에만 · 누르면 엔진 결과) → 리포트(항목 차례)',
    (WidgetTester tester) async {
      // 끝난 재개 회차(계절 대기 · 기한 지남 · 집행 예정) + 재개 미완 플래그 — 화면이 서기 전에 원장에 둔다.
      files.sim.execute(
        'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          'RR-2026-11-18-1',
          '2026-11-18T00:12:00.000Z',
          '2026-11-18T00:41:00.000Z',
          2,
          'NORMAL',
          'R8',
          '{"executed":1,"expired":1,"superseded":0,"blocked":1,"unrecoverable":0}',
          '2거래일 미실행: 재판정 1 / 만료 1 / 대체 0 / 차단 1 / 복구 불가 0. 주문은 다음 주문 회차가 냅니다.',
        ],
      );
      for (final (int seq, String work, String reason, String verdict)
          in <(int, String, String, String)>[
            (0, 'w_done', 'REEVALUATED', 'EXECUTED_AS_REEVALUATED'),
            (1, 'w_season', 'HUMAN_DECISION', 'BLOCKED'),
            (2, 'w_due', 'DUE_PASSED', 'EXPIRED'),
          ]) {
        files.sim.execute(
          'INSERT INTO resume_item (resume_run_id, work_id, seq, one_line, planned_line, reevaluated_line, '
          'verdict_code, verdict_label, reason_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            'RR-2026-11-18-1',
            work,
            seq,
            '$work 한 줄',
            '11월 14일 계획됨',
            '$reason 글자',
            verdict,
            '$verdict 글자',
            reason,
          ],
        );
      }
      files.sim.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[
          FlagIds.resumeIncomplete,
          '2026-11-18T00:12:00.000Z',
          '재개 회차 RR-2026-11-18-1',
        ],
      );
      await pumpApp(tester);
      await ready(tester);
      Future<void> settle() async {
        for (int i = 0; i < 3; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump();
        }
      }

      await open(tester, AppRoutes.m5BlockBoard);
      await settle();
      expect(tester.takeException(), isNull);
      // 🔴 R185 의 재개 미완 행 링크가 이제 선다(X2 게이트 등록 → 보드 hasBody).
      final Finder rowLink = find.byKey(
        const Key('m55-row-link-RESUME_INCOMPLETE'),
      );
      expect(rowLink, findsOneWidget);
      await tester.ensureVisible(rowLink);
      await tester.tap(rowLink);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      expect(tester.takeException(), isNull);
      final Finder gate = find.byType(ResumeGateScreen);
      expect(gate, findsOneWidget);
      expect(
        find.descendant(
          of: gate,
          matching: find.text(
            '2거래일 미실행: 재판정 1 / 만료 1 / 대체 0 / 차단 1 / 복구 불가 0. 주문은 다음 주문 회차가 냅니다.',
          ),
        ),
        findsOneWidget,
      );
      expect(
        <String>[
          for (final Element e
              in find
                  .descendant(of: gate, matching: find.byType(Card))
                  .evaluate())
            (e.widget.key! as ValueKey<String>).value,
        ],
        <String>['x2g-row-w_season', 'x2g-row-w_due'],
      );
      // 🆕 R195 — 계절 3택 = 사람 결정 행에만(기한 지난 행 = 0) · 누르면 엔진 판정(이 원장엔 계획 행이 없어 PLANNED_WORK_UNKNOWN 원문).
      expect(
        find.descendant(
          of: find.byKey(const Key('x2g-row-w_season')),
          matching: find.byType(OutlinedButton),
        ),
        findsNWidgets(3),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('x2g-row-w_due')),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('x2g-act-w_season-SKIP')));
      await tester.pump();
      await settle();
      expect(tester.takeException(), isNull);
      expect(
        find.text('그 작업을 찾지 못했습니다. (PLANNED_WORK_UNKNOWN)'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('x2g-report')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      expect(tester.takeException(), isNull);
      final Finder report = find.byType(ResumeReportScreen);
      expect(report, findsOneWidget);
      expect(
        <String>[
          for (final Element e
              in find
                  .descendant(of: report, matching: find.byType(Card))
                  .evaluate())
            (e.widget.key! as ValueKey<String>).value,
        ],
        <String>['x2r-item-w_done', 'x2r-item-w_season', 'x2r-item-w_due'],
      );
      expect(find.text('11-18 09:12 ~ 09:41'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  testWidgets('🔴 M5-9 규칙 변경 게이트(R188) = 조립 셸에 등록 · 엔진 머리(승인 0) · 크래시 없음', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.m5RuleChangeGate);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder screen = find.byType(RuleChangeGateScreen);
    expect(screen, findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    final String headline = tester
        .widget<Text>(find.byKey(const Key('m59-headline')))
        .data!;
    expect(<String>[
      RuleChangeGateTexts.headlineFirst,
      RuleChangeGateTexts.headlineNoConfig,
    ], contains(headline));
    expect(find.byKey(const Key('m59-window')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  for (final String route in <String>[
    AppRoutes.m5HandoverWizard,
    AppRoutes.handoverStatus,
  ]) {
    testWidgets('🔴 M5-11 위저드(R191) — $route = 같은 본문 · 엔진 머리 · 크래시 없음', (
      WidgetTester tester,
    ) async {
      container.dispose();
      rt = OperatorRuntime(
        files: files,
        clock: clock,
        liveObservation: LiveObservationConfig(requiredTradingDays: 2),
      );
      container = ProviderContainer(overrides: operatorShellOverrides(rt));
      await pumpApp(tester);
      await ready(tester);
      await open(tester, route);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(HandoverWizardScreen), findsOneWidget);
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(find.byKey(const Key('m511-read-failed')), findsNothing);
      expect(find.byKey(const Key('m511-headline')), findsOneWidget);
      // 시험 조립 = 설정 동작 인스턴스 없음(금고 0) → 버튼 0.
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('m511-act-'),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    });
  }

  testWidgets('🔴 S06 기기 · 접근(R146) = 조립 셸에 등록 · 이 폰 한 행 · 모의 단독 리스 · 캡처 막기', (
    WidgetTester tester,
  ) async {
    container.dispose();
    final List<bool> secure = <bool>[];
    rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceId: '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e',
      secure: SecureScreen((bool on) async => secure.add(on)),
    );
    container = ProviderContainer(overrides: operatorShellOverrides(rt));
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.settingsDevices);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder screen = find.byType(Devices);
    expect(screen, findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    Finder inScreen(String t) =>
        find.descendant(of: screen, matching: find.text(t));
    expect(inScreen('이 폰(운영)'), findsWidgets);
    expect(inScreen('유효 — 이 폰 단독 리스(모의)'), findsOneWidget);
    expect(inScreen('연결된 조회 전용 기기가 없습니다.'), findsOneWidget);
    // 🔴 S06 = 캡처 막기 라우트(R107 · QR 자리가 생길 화면).
    expect(rt.secure.depth, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets('🔴 S07 연결(R140) = 조립 셸에 등록 · 원천 있는 네 행 · 증권사 행 탭 = S02', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.settingsConnections);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder screen = find.byType(Connections);
    expect(screen, findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    Finder inScreen(String t) =>
        find.descendant(of: screen, matching: find.text(t));
    expect(inScreen('증권사 연결(모의투자)'), findsOneWidget);
    expect(inScreen('미러(Supabase)'), findsOneWidget);
    expect(inScreen('아카이브(GitHub)'), findsOneWidget);
    expect(inScreen('생존 신호(healthchecks)'), findsOneWidget);
    // 증권사 행 = S02 등록 → 연다(링크 = 셸이 쓰는 레지스트리).
    await tester.tap(inScreen('증권사 연결(모의투자)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Credentials), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets('🔴 H-03 물리 리스크(R136) = 조립 셸에 등록 · 기기 측정 → 엔진 행 · 크래시 없음', (
    WidgetTester tester,
  ) async {
    container.dispose();
    rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceProbe: () async => DeviceRiskFacts(
        measuredAtUtc: clock.nowUtc(),
        storageFreeBytes: 3100000000,
        batteryTempTenthsC: 470,
      ),
    );
    container = ProviderContainer(overrides: operatorShellOverrides(rt));
    await pumpApp(tester);
    await ready(tester);
    await open(tester, AppRoutes.opsDeviceRisk);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final Finder board = find.byType(DeviceRiskBoard);
    expect(board, findsOneWidget);
    expect(find.byKey(const Key('s01-placeholder')), findsNothing);
    Finder inBoard(String t) =>
        find.descendant(of: board, matching: find.text(t));
    expect(inBoard('남은 공간 3.1GB'), findsOneWidget);
    expect(inBoard('현재 47도'), findsOneWidget);
    expect(inBoard('충전기를 빼고 그늘로 옮기세요'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    disposed = true;
  });

  testWidgets(
    '🔴 더보기 = S01 설정 홈(R134) · 원천 있는 카드 · 링크 = 등록된 화면만(키 → S02 · 운용 = 탭 부재)',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await ready(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('s01-tabs')),
          matching: find.text('더보기'),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      final Finder home = find.byType(SettingsHome);
      expect(home, findsOneWidget);
      Finder inHome(String t) =>
          find.descendant(of: home, matching: find.text(t));
      expect(inHome('모의 · 내부 가상 체결 · 자동 매매'), findsOneWidget);
      // 🆕 R196 — 키 3벌(실전 · ISA = SIM 봉인 INFO · 모의 = 필수 미등록 ACT).
      expect(inHome('3벌 중 1벌 확인 필요'), findsOneWidget);
      expect(inHome('모의 · 자동 매매'), findsOneWidget);
      expect(inHome('월 10만원'), findsOneWidget);
      // 시험 원장 = 운영 설정 없음(지문 '') → 전략 카드는 P0S 를 지어내지 않는다.
      expect(inHome('운영 설정을 읽지 못했습니다'), findsOneWidget);
      // 운용 관리 = S05 본문 미등록 → 탭 부재(눌러도 그대로).
      await tester.tap(inHome('운용 관리'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('s01-placeholder')), findsNothing);
      expect(find.byType(Credentials), findsNothing);
      // 증권사 키 = S02 등록 → 연다.
      await tester.tap(inHome('증권사 키'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Credentials), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );

  test('🔴 일지 패키지 링크 열기 = 셸과 같은 것(https = 바깥)', () async {
    final List<String> outside = <String>[];
    final ProviderContainer c = ProviderContainer(
      overrides: operatorShellOverrides(
        OperatorRuntime(
          files: files,
          clock: clock,
          openExternal: (String u) async {
            outside.add(u);
            return true;
          },
        ),
      ),
    );
    addTearDown(c.dispose);
    expect(
      identical(
        c.read(journalLinkOpenerProvider),
        c.read(shellLinkOpenerProvider),
      ),
      true,
    );
    c.read(journalLinkOpenerProvider).open('https://github.com');
    await Future<void>.delayed(Duration.zero);
    expect(outside, <String>['https://github.com']);
    expect(c.read(journalLedgerRepositoryProvider), isNotNull);
  });
}
