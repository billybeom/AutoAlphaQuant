// E11p3d-2c 에뮬레이터 확인(설계 13 §8 R135) — 실제 Kotlin `OpsChannel.deviceRisk` 측정 → 엔진 `deviceRiskVmOf` → H-03 화면.
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 값 · 키 · 계좌 0(기기 상태만).
// 실행: `flutter test integration_test/device_risk_test.dart -d emulator-5554` · 표지 `IT_H03` 에서 4초 멈춘다(캡처 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart' show DeviceRiskFacts;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_shell/ui_shell.dart' show DeviceRiskBoard;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('🔴 H-03 실제 기기 측정 → 엔진 행 → 화면', (WidgetTester tester) async {
    final AndroidOps ops = AndroidOps();
    const SystemClock clock = SystemClock();
    final DeviceRiskFacts f = await ops.deviceRisk(clock.nowUtc());
    // ignore: avoid_print
    print(
      'IT_FACTS free=${f.storageFreeBytes} health=${f.batteryHealth} '
      'cycles=${f.batteryCycleCount} temp=${f.batteryTempTenthsC} patch=${f.securityPatch}',
    );
    expect(f.storageFreeBytes, isNotNull);
    expect(f.batteryHealth, isNotNull);
    expect(f.batteryTempTenthsC, isNotNull);
    expect(f.securityPatch, isNotNull);

    final Directory dir = Directory.systemTemp.createTempSync('aaq_h03_');
    final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
    final OperatorRuntime rt = OperatorRuntime(
      files: files,
      clock: clock,
      deviceProbe: () => ops.deviceRisk(clock.nowUtc()),
    );
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: operatorShellOverrides(rt),
          child: const MaterialApp(home: Scaffold(body: DeviceRiskBoard())),
        ),
      );
      final Finder row = find.textContaining('남은 공간');
      for (int i = 0; i < 100 && row.evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      expect(row, findsOneWidget);
      expect(find.textContaining('보안 패치 20'), findsOneWidget);
      expect(find.textContaining('현재 '), findsOneWidget);
      for (final Element e in find.byType(Text).evaluate()) {
        final String? t = (e.widget as Text).data;
        // ignore: avoid_print
        if (t != null) print('IT_ROW $t');
      }
      // ignore: avoid_print
      print('IT_H03');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 4)),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    } finally {
      files.close();
      dir.deleteSync(recursive: true);
    }
  });
}
