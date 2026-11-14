// E11p3d-5 — 권한 요청 · 캡처 막기 · 바깥 링크가 실 Android 에서 돈다(에뮬레이터 · 로컬만 · CI 밖 · 설계 13 §8 R107).
//
//   flutter test integration_test/platform_d5_test.dart -d <기기>
//
// 🔵 FLAG_SECURE 는 Dart 에서 읽을 수 없다 — 켠 동안(15초) 바깥에서 `adb shell dumpsys window` 로 본다(실측 절차 = R107).
// 🔴 캡처 막기 시험이 맨 앞 — 권한 대화상자가 화면을 멈추면(onPause) 켜기는 «기억» 만 되고 다음 onResume 에 걸린다(설계대로).

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final AndroidOps ops = AndroidOps();

  testWidgets('🔴 캡처 막기 켜기 · 끄기(켠 동안 15초 — 바깥 dumpsys 로 확인)', (_) async {
    await ops.setSecure(true);
    // ignore: avoid_print
    print('D5_SECURE_ON');
    await Future<void>.delayed(const Duration(seconds: 15));
    await ops.setSecure(false);
    // ignore: avoid_print
    print('D5_SECURE_OFF');
    await Future<void>.delayed(const Duration(seconds: 8));
  });

  testWidgets('🔴 권한 요청 결과 = 사실 코드 · 정확 알람(13+) = 이미 허용', (_) async {
    expect(
      await ops.requestPermission(OpsPermission.exactAlarm),
      PermissionRequestOutcome.alreadyGranted,
    );
    expect(
      await ops.requestPermission(OpsPermission.notifications),
      isIn(<PermissionRequestOutcome>[
        PermissionRequestOutcome.alreadyGranted,
        PermissionRequestOutcome.requested,
        PermissionRequestOutcome.noActivity,
      ]),
    );
    expect(
      await ops.requestPermission(OpsPermission.batteryExemption),
      isIn(<PermissionRequestOutcome>[
        PermissionRequestOutcome.alreadyGranted,
        PermissionRequestOutcome.requested,
      ]),
    );
  });

  testWidgets('🔴 바깥 링크 — https 는 채널로(브라우저 유무 = bool) · 그 밖은 막는다', (_) async {
    expect(await ops.openExternalUrl('https://example.com'), isA<bool>());
    await expectLater(
      ops.openExternalUrl('http://example.com'),
      throwsArgumentError,
    );
  });
}
