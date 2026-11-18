// E11p4h 에뮬레이터 확인(설계 13 §8 R157) — 온보딩 중(운영 방식 = 자동 매매 · 확정 전) 마무리 O-04 ② 슬롯에 M5-8 서약 칸이
// 서고, 세 문장을 저장하면 엔진이 판정한다. 🔴 실제 런타임 = 신뢰 시각 «모름»(E11k 전) → 엔진 문장
// «서버 시각을 확인하지 못해 저장하지 않았습니다.» · 서약 0행(지어내지 않는다).
//
// 🔴 로컬 실측용(CI 밖) · 키 · 계좌 0 · 바깥 망 0 · 임시 원장 폴더(끝나면 지운다).
// 실행: `flutter test integration_test/pledge_test.dart -d emulator-5554` · 표지 `IT_*` 마다 4초 멈춘다(캡처 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:data_sync/data_sync.dart' show SqliteOnboardingStore;
import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, OperatingMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_safety/ui_safety.dart' show PledgePanel;
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

  testWidgets('🔴 M5-8 서약 — 마무리 ② 슬롯 → 세 문장 저장 → 신뢰 시각 모름 = 엔진 거부 문장', (
    WidgetTester tester,
  ) async {
    const SystemClock clock = SystemClock();
    final AndroidOps ops = AndroidOps();
    final Directory dir = Directory.systemTemp.createTempSync('aaq_it_m58_');
    final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      secure: SecureScreen(ops.setSecure),
      deviceId: await ops.deviceId(),
    );
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
      container.read(shellLinkOpenerProvider).open(AppRoutes.onboardingFinish);
      final Finder panel = find.byType(PledgePanel);
      await _until(tester, panel);
      await _at(tester, panel, 'IT_M58');

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
      await _until(tester, find.byKey(const Key('m5-8-result')));
      expect(find.text('서버 시각을 확인하지 못해 저장하지 않았습니다.'), findsOneWidget);
      expect(
        files.sim.select('SELECT COUNT(*) AS n FROM pledge').first['n'],
        0,
      );
      await tester.ensureVisible(find.byKey(const Key('m5-8-result')));
      await _at(tester, panel, 'IT_M58_RESULT');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      files.close();
      dir.deleteSync(recursive: true);
    }
    _mark('IT_DONE');
  });
}
