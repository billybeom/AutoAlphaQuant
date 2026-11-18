// E11p4g 에뮬레이터 확인(설계 13 §8 R156) — 온보딩 중(운영 방식 = 자동 매매 · 확정 전) O-04 ⑥ 링크 목적지 M5-14 를 열고
// 가상 초기금을 넣으면 엔진이 실린 사람 값(R153 · R154)으로 계좌별로 나눠 넣는다(접수증 = 엔진 문장).
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 키 · 계좌 0 · 바깥 망 0 · 임시 원장 폴더(끝나면 지운다).
// 실행: `flutter test integration_test/sim_opening_cash_test.dart -d emulator-5554` · 표지 `IT_*` 마다 4초 멈춘다(캡처 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/human_inputs_loader.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:data_sync/data_sync.dart' show SqliteOnboardingStore;
import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, DecisionReasonCodes, OperatingMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_safety/sim_opening.dart' show SimOpeningCash;
import 'package:ui_shell/ui_shell.dart' show shellLinkOpenerProvider;

void _mark(String m) {
  // ignore: avoid_print
  print(m);
}

Future<void> _at(WidgetTester tester, Finder screen, String marker) async {
  for (final Element e
      in find.descendant(of: screen, matching: find.byType(Text)).evaluate()) {
    final String? t = (e.widget as Text).data;
    if (t != null) _mark('IT_TEXT $marker $t');
  }
  _mark(marker);
  final DateTime end = DateTime.now().add(const Duration(seconds: 4));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

Future<void> _until(WidgetTester tester, Finder f) async {
  final DateTime end = DateTime.now().add(const Duration(seconds: 20));
  while (f.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('기다린 위젯이 안 나타났다: $f');
    }
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('🔴 M5-14 가상 초기금 — 온보딩 중 링크 → 넣기 → 엔진이 계좌별로 나눠 넣는다', (
    WidgetTester tester,
  ) async {
    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final Directory dir = Directory.systemTemp.createTempSync('aaq_it_m514_');
    final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      deviceId: await ops.deviceId(),
      humanDecision: await loadP0sHumanDecision(rootBundle),
    );
    // 운영 방식만 고른다(확정 전) → 루트 = 온보딩 내비게이터.
    expect(
      SqliteOnboardingStore(
        files.sim,
        clock: clock,
      ).selectOperatingMode(OperatingMode.autoTrade).ok,
      isTrue,
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
      await tester.pump(const Duration(milliseconds: 500));
      container.read(shellLinkOpenerProvider).open(AppRoutes.m5SimOpeningCash);
      final Finder screen = find.byType(SimOpeningCash);
      await _until(tester, screen);
      await _at(tester, screen, 'IT_M514');

      await tester.enterText(find.byKey(const Key('m5-14-cash')), '10,000,000');
      await tester.tap(find.byKey(const Key('m5-14-submit')));
      await _until(tester, find.byKey(const Key('m5-14-receipt')));
      expect(find.text('가상 초기금 10,000,000원을 계좌 3곳에 나눠 넣었습니다.'), findsOneWidget);
      expect(
        files.sim.select(
          'SELECT COUNT(*) AS n FROM cash_flow WHERE note = ?',
          <Object?>[DecisionReasonCodes.simOpeningBalance],
        ).first['n'],
        3,
      );
      await _at(tester, screen, 'IT_M514_DONE');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      files.close();
      dir.deleteSync(recursive: true);
    }
    _mark('IT_DONE');
  });
}
