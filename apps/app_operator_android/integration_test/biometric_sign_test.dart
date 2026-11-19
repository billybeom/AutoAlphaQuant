// E11p4j 에뮬레이터 확인(설계 13 §8 R159) — 온보딩 중 ② 서약을 둔 뒤(시험용 고정 신뢰 시각 — E11k 전) 마무리 O-04 ③
// 슬롯에 생체 서명 칸이 서고, 누르면 실제 Kotlin `BiometricGate`(프레임워크 BiometricPrompt)가 판정한다.
// 🔴 에뮬레이터 = 생체 미등록 → «생체 확인을 할 수 없어 진행하지 않았습니다.» · 서명 0행(지어내지 않는다).
//
// 🔴 로컬 실측용(CI 밖) · 키 · 계좌 0 · 바깥 망 0 · 임시 원장 폴더(끝나면 지운다).
// 실행: `flutter test integration_test/biometric_sign_test.dart -d emulator-5554` · 표지 `IT_*` 마다 4초 멈춘다(캡처 자리).

import 'dart:io';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/main.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:app_operator_android/safety/biometric_sign_field.dart';
import 'package:core_engine/core_engine.dart'
    show TrustedClock, kBiometricSignKind;
import 'package:data_sync/data_sync.dart'
    show SqliteOnboardingStore, SqlitePledgeStore;
import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, OperatingMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui_shell/ui_shell.dart' show shellLinkOpenerProvider;

/// 시험용 신뢰 시각(E11k 전 — ② 서약을 두기 위해서만).
class _NowTrusted implements TrustedClock {
  const _NowTrusted();
  @override
  DateTime? trustedNowUtc() => DateTime.now().toUtc();
}

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

  testWidgets(
    '🔴 O-04 ③ 생체 서명 — 서약 뒤 칸 → 누름 → 실제 BiometricPrompt 판정(에뮬레이터 = 미등록)',
    (WidgetTester tester) async {
      const SystemClock clock = SystemClock();
      final AndroidOps ops = AndroidOps();
      final Directory dir = Directory.systemTemp.createTempSync('aaq_it_bio_');
      final LedgerFiles files = LedgerFiles.open(dir.path, clock: clock);
      final OperatorRuntime rt = OperatorRuntime(
        files: files,
        clock: clock,
        secure: SecureScreen(ops.setSecure),
        deviceId: await ops.deviceId(),
        trusted: const _NowTrusted(),
        biometricSign: ops.biometricSign,
      );
      expect(
        SqliteOnboardingStore(
          files.sim,
          clock: clock,
        ).selectOperatingMode(OperatingMode.autoTrade).ok,
        isTrue,
      );
      expect(
        SqlitePledgeStore(files.sim, clock: clock, trusted: const _NowTrusted())
            .writeFirst(
              commandId: 'it-pledge',
              payloadDigest: 'it',
              sentences: const <String>[
                '정한 날에만 산다',
                '하락에도 규칙을 지킨다',
                '멈춘 뒤엔 점검부터',
              ],
              decisionId: 'it-pledge',
            )
            .executed,
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
        container
            .read(shellLinkOpenerProvider)
            .open(AppRoutes.onboardingFinish);
        final Finder field = find.byType(BiometricSignField);
        await _until(tester, field);
        await tester.ensureVisible(field);
        await _at(tester, field, 'IT_M5BIO');

        await tester.tap(find.byKey(const Key('m5-bio-sign')));
        await _until(tester, find.byKey(const Key('m5-bio-result')));
        expect(find.text('생체 확인을 할 수 없어 진행하지 않았습니다.'), findsOneWidget);
        expect(
          files.sim.select(
            'SELECT COUNT(*) AS n FROM command_inbox WHERE kind = ?',
            <Object?>[kBiometricSignKind],
          ).first['n'],
          0,
        );
        await _at(tester, field, 'IT_M5BIO_RESULT');
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        files.close();
        dir.deleteSync(recursive: true);
      }
      _mark('IT_DONE');
    },
  );
}
