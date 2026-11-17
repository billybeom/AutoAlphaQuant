// E11p3d-5g 에뮬레이터 확인(설계 13 §8 R142) — 실제 Kotlin `DeviceId` · 백업 제외 자리 · 같은 기기 = 같은 값.
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 키 · 계좌 0.
// 실행: `flutter test integration_test/device_id_test.dart -d emulator-5554` · 표지 `IT_DEVICE_ID` 줄에 값이 찍힌다.

import 'dart:io';

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('🔴 기기 id — UUID v4 · 두 번 불러도 같다 · noBackup 에만 산다', () async {
    final AndroidOps ops = AndroidOps();
    final String a = await ops.deviceId();
    final String b = await ops.deviceId();
    // ignore: avoid_print
    print('IT_DEVICE_ID $a');
    expect(kDeviceIdPattern.hasMatch(a), isTrue);
    expect(b, a);
    final OperatorPaths p = await ops.paths();
    final File inNoBackup = File('${p.noBackup}/aaq_device_id');
    expect(inNoBackup.existsSync(), isTrue);
    expect(inNoBackup.readAsStringSync().trim(), a);
    // 백업되는 자리에는 없다.
    expect(File('${p.files}/aaq_device_id').existsSync(), isFalse);
    expect(File('${p.noBackup}/aaq_device_id.tmp').existsSync(), isFalse);
  });
}
