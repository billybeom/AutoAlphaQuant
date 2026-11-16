// E11p 에뮬레이터 확인 — 온보딩 시작 → 운영 방식 → 단계 목록 → O-02 모의 키 붙여넣기 · 검증 · 저장 → S02 키 목록(로컬만 · CI 밖).
//
//   flutter test integration_test/onboarding_flow_test.dart -d <기기>
//
// 🔴 실키를 쓰지 않는다 — 연습 값(가짜 앱키 · 비밀 · 계좌)만 · KIS 는 가짜 서버(MockClient — 바깥 호출 0).
// 🔴 기기에 이미 모의 키 칸이 있으면(발주자 폰) 아무것도 건드리지 않고 건너뛴다 — 시험이 사람이 넣은 키를 지우지 않게.
// 🔵 FLAG_SECURE 는 Dart 에서 읽을 수 없다 — 화면마다 표지(`IT_*`)를 찍고 4초 멈춘다(바깥 `adb shell dumpsys window` · 캡처).
//    안에서는 겹침 수(`SecureScreen.depth`)를 화면마다 본다 — 켜짐 = O-02 시크릿 칸 · S02 뿐 · 나머지 = 꺼짐.
// 🔵 마무리(O-13)는 DRY_RUN 계층 B 카드 원천이 없어 지금 끝까지 못 간다 — S02 확인 앞에서 확정 행 · 모드 행을 직접 둔다(시험 몫 · 표시함).

import 'dart:convert';
import 'dart:io';

import 'package:app_operator_android/app/operator_onboarding.dart'
    show OnboardingProbe;
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart' show OnboardingStepFact;
import 'package:data_sync/data_sync.dart'
    show ModeAxis, SqliteModeStore, SqliteOnboardingProgressStore;
import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, ExecPolicy, LedgerFile, OperatingMode, RunMode, StepState;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_shell/ui_shell.dart' show ShellRoot, shellLinkOpenerProvider;

// 연습 값 — 실키 아님(형식 판정만 지나게 · 금지 접두 없음).
const String _appKey = 'PSPRACTICEKEY000000000001';
const String _appSecret = 'PRACTICESECRETabcdefghijklmnop0123456789';
const String _account = '50123456-01';

http.Response _json(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

void _mark(String m) {
  // ignore: avoid_print
  print(m);
}

/// 화면 하나에 멈춘다 — 캡처 막기 겹침([secure] = 켜져 있어야 함)을 보고, 표지를 찍고, 바깥 `dumpsys` · 캡처가 따라오게 [hold] 기다린다.
Future<void> _at(
  WidgetTester tester,
  OperatorRuntime rt,
  String marker, {
  required bool secure,
  Duration hold = const Duration(seconds: 4),
}) async {
  expect(rt.secure.depth > 0, secure, reason: '$marker 캡처 막기');
  _mark(marker);
  final DateTime end = DateTime.now().add(hold);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

Future<void> _until(
  WidgetTester tester,
  Finder f, {
  Duration timeout = const Duration(seconds: 20),
  bool gone = false,
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (f.evaluate().isEmpty != gone) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('기다린 위젯이 ${gone ? '안 사라졌다' : '안 나타났다'}: $f');
    }
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _until(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
}

Future<void> _paste(WidgetTester tester, String field, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  await _tap(tester, find.byKey(Key('m4-secret-$field-paste')));
  await _until(tester, find.byKey(Key('m4-secret-$field-shown')));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('🔴 온보딩 → O-02 연습 값 검증 · 저장 → S02 «정상» · 다시 검증', (
    WidgetTester tester,
  ) async {
    final AndroidSecretVault vault = AndroidSecretVault();
    final KisCredentialSlots slots = KisCredentialSlots.of(KisKeySet.paper);
    if (slots.all.any((await vault.ids()).contains)) {
      markTestSkipped('기기에 모의 키 칸이 있다 — 건드리지 않는다');
      return;
    }

    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final Directory dir = Directory.systemTemp.createTempSync('aaq_it_onb_');
    final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
    final List<String> calls = <String>[];
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      vault: vault,
      kisHttp: MockClient((http.Request r) async {
        calls.add(r.url.path);
        return r.url.path == '/oauth2/tokenP'
            ? _json(<String, Object>{
                'access_token': 'PRACTICE-TOKEN',
                'token_type': 'Bearer',
                'expires_in': 86400,
              })
            : _json(<String, Object>{
                'rt_cd': '0',
                'msg_cd': '20310000',
                'msg1': '모의투자 조회가 완료되었습니다.',
                'output1': <Object>[],
                'output2': <Object>[
                  <String, String>{'prvs_rcdl_excc_amt': '10000000'},
                ],
              });
      }),
      onboardingProbe: () async {
        final SurvivalFacts f = await ops.diagnose();
        return OnboardingProbe(
          notificationsEnabled: f.notificationsEnabled,
          batteryExempt: f.batteryExempt,
        );
      },
    );
    final ProviderContainer container = ProviderContainer(
      overrides: operatorShellOverrides(rt),
    );

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AutoAlphaQuantOperatorApp(shell: true),
        ),
      );

      // O-00 시작 → «처음 시작하기»(트랙 0).
      await _until(tester, find.byKey(const Key('o00-headline')));
      await _at(tester, rt, 'IT_O00', secure: false);
      await _tap(tester, find.byKey(const ValueKey<String>('o00-track-0')));

      // O-00b 운영 방식 → 자동(카드 0) → 다음.
      await _tap(tester, find.byKey(const ValueKey<String>('o00b-card-0')));
      await _until(tester, find.byKey(const Key('o00b-result')));
      await _until(tester, find.byKey(const ValueKey<String>('o00b-check-0')));
      await _at(tester, rt, 'IT_O00B', secure: false);
      await _tap(tester, find.byKey(const Key('o00b-next')));

      // O-01 단계 목록 → o_02(행 1 · 자동 트랙 = o_01 다음).
      await _until(tester, find.byKey(const Key('o01-progress')));
      expect(find.text('KIS 모의 앱키 등록'), findsWidgets);
      await _at(tester, rt, 'IT_O01', secure: false);
      await _tap(tester, find.byKey(const ValueKey<String>('o01-row-1')));

      // O-02 → 시크릿 칸(캡처 막기 켜짐).
      await _until(tester, find.byKey(const Key('o02-head')));
      await _until(
        tester,
        find.byKey(Key('m4-secret-${KisKeySet.paper.wire}')),
      );
      await _at(tester, rt, 'IT_SECURE_ON', secure: true);

      await _paste(tester, 'appKey', _appKey);
      await _paste(tester, 'appSecret', _appSecret);
      await _paste(tester, 'account', _account);
      // 가린 글자만 보인다(원문 없음).
      expect(find.textContaining(_appKey), findsNothing);
      expect(find.textContaining(_appSecret), findsNothing);

      // O-03 검증 → 통과 = 저장.
      await _tap(tester, find.byKey(const Key('o03-run')));
      await _until(tester, find.byKey(const Key('o03-result')));
      expect(find.textContaining('검증을 통과해 저장했습니다'), findsOneWidget);
      expect(calls, <String>[
        '/oauth2/tokenP',
        '/uapi/domestic-stock/v1/trading/inquire-balance',
      ]);
      final KisCredentialRead got = await readKisCredentials(
        vault,
        KisKeySet.paper,
      );
      expect(got, isA<KisCredentialsStored>());
      final KisCredentials c = (got as KisCredentialsStored).credentials;
      expect(
        (c.appKey, c.accountNo, c.productCode),
        (_appKey, '50123456', '01'),
      );
      final OnboardingStepFact? o2 = SqliteOnboardingProgressStore(
        files.sim,
        clock: clock,
      ).facts()['o_02'];
      expect(o2?.state, StepState.verified);
      await _at(tester, rt, 'IT_O03_SAVED', secure: true);

      // 🔵 마무리 대신(DRY_RUN 원천 없음) — 확정 · 모드 행을 시험이 둔다 → 루트가 셸로 바뀐다.
      files.sim.execute(
        'UPDATE onboarding_choice SET committed_at = ? WHERE id = 1',
        <Object?>[clock.nowUtc().toIso8601String()],
      );
      final String? denied =
          SqliteModeStore(files.sim, LedgerFile.sim, clock: clock).record(
            axis: ModeAxis.runMode,
            runMode: RunMode.simInternal,
            execPolicy: ExecPolicy.execute,
            operatingMode: OperatingMode.autoTrade,
            handoverSessionValid: false,
            decisionId: 'D-IT-SIM-OPEN',
          );
      expect(denied, isNull);
      final EngineBoot boot = await bootEngine(files, clock: clock);
      rt.view.value = operatorViewOf(boot, files);
      expect(rt.view.value, isNotNull);
      await _until(tester, find.byType(ShellRoot));
      // 🔴 온보딩 내비게이터가 내려가면 시크릿 칸도 내려간다 = 캡처 막기 꺼짐(켠 채로 두면 다른 화면까지 캡처 불가).
      await _at(tester, rt, 'IT_SHELL', secure: false);

      // S02 키 목록 → 모의 카드 «정상» → 다시 검증(금고 키).
      container
          .read(shellLinkOpenerProvider)
          .open(AppRoutes.settingsCredentials);
      await _until(tester, find.byKey(const ValueKey<String>('m9s02-card-0')));
      expect(find.text('정상'), findsOneWidget);
      // 🔴 S02 = 라우트 단위 캡처 막기(R107 kSecureRoutePatterns).
      await _at(tester, rt, 'IT_S02', secure: true);
      await _tap(tester, find.byKey(const ValueKey<String>('m9s02-verify-0')));
      await _until(tester, find.byKey(const Key('m9s02-result')));
      expect(find.textContaining('다시 검증했습니다'), findsOneWidget);
      expect(calls, hasLength(4));
      await _at(tester, rt, 'IT_S02_REVERIFIED', secure: true);

      // S02 를 나가면 = 꺼짐.
      await container
          .read(operatorShellNavigatorKeyProvider)
          .currentState!
          .maybePop();
      await _until(
        tester,
        find.byKey(const ValueKey<String>('m9s02-card-0')),
        gone: true,
      );
      await _at(tester, rt, 'IT_S02_LEFT', secure: false);
    } finally {
      await deleteKisCredentials(vault, KisKeySet.paper);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      files.close();
      dir.deleteSync(recursive: true);
    }
    expect((await vault.ids()).intersection(slots.all.toSet()), isEmpty);
    expect(rt.secure.depth, 0);
    _mark('IT_DONE');
  });
}
