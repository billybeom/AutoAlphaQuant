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
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/secret/kis_key_set_field.dart';
import 'package:core_engine/core_engine.dart' show alertInboxOf;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart' show SqliteAlertSink, storedAlerts;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertCodes,
        AlertItem,
        AppRoutes,
        BlockFlag,
        FlagIds,
        OnboardingSlotIds,
        OperatingMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_analytics/ui_analytics.dart'
    show
        analyticsClockProvider,
        analyticsLinkOpenerProvider,
        safetyRepositoryProvider;
import 'package:ui_journal/ui_journal.dart'
    show
        LedgerDiffs,
        LedgerRepairs,
        journalClockProvider,
        journalLedgerRepositoryProvider,
        journalLinkOpenerProvider,
        journalSafetyRepositoryProvider;
import 'package:ui_settings/ui_settings.dart'
    show
        Credentials,
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
    // 🔴 원천 없는 셋 — 슬리브 비중 = 다시 시도(지어내지 않는다) · 안내 · 실사 카드 = 부재.
    expect(find.byKey(const Key('h01-alloc-fail')), findsOneWidget);
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
    expect(
      container.read(shellHoldingsRepositoryProvider),
      isA<OperatorHoldingsRepository>(),
    );
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

  test('🔴 온보딩 슬롯 빌더(R115) = 주입됨 · SECRET_KIS_MOCK = 키 세트 칸(실행 묶음의 넘김 · 캡처 막기) · 나머지 = 자리 부재', () {
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
      } else {
        expect(w.key, const Key('m4-slot-absent'), reason: id);
      }
    }
    expect(b!('SECRET_KIS_LIVE').key, const Key('m4-slot-absent'));
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
    expect(b('SECRET_KIS_LIVE').key, const Key('m4-slot-absent'));
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
      expect(inHome('모의투자 미등록'), findsOneWidget);
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
