// E11p2 · P13 ② — 실 Android 로 도는 생존 경로 시험(에뮬레이터 · 폰 · 로컬만 · CI 밖).
//
//   flutter test integration_test/ops_test.dart -d <기기>
//
// 정확 알람 → AlarmReceiver → EngineService(FGS) → OpsChannel → Dart `onWake` 의 끝에서 끝.
// 🔴 FGS 5분 생존 · Doze 지연 · 재부팅 재무장은 `tool/measure_survival.sh` 몫(시간이 걸리고 화면을 꺼야 한다).

import 'dart:io';

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const String _files =
    '/data/user/0/com.billybeom.autoalphaquant.operator/files';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final AndroidOps ops = AndroidOps();
  final List<WakeEvent> wakes = <WakeEvent>[];

  setUpAll(() async {
    await ops.ensureChannels(kOpsChannelNames);
    await ops.listen(onWake: wakes.add, onLink: (_) {});
    await ops.startService();
  });

  tearDownAll(() async {
    await ops.arm(const <AlarmItem>[]);
    await ops.idle();
  });

  testWidgets('FGS 가 돈다 · 정확 알람을 걸 수 있다(사실)', (_) async {
    SurvivalFacts f = await ops.diagnose();
    for (int i = 0; i < 40 && !f.fgsRunning; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      f = await ops.diagnose();
    }
    expect(f.fgsRunning, isTrue);
    expect(f.exactAlarm, isTrue, reason: 'USE_EXACT_ALARM(33+)');
    debugPrint(
      'FACTS notif=${f.notificationsEnabled} exact=${f.exactAlarm} '
      'battery=${f.batteryExempt} p0dnd=${f.p0BypassDnd} '
      'fgs=${f.fgsRunning} denied=${f.fgsStartDenied}',
    );
  });

  testWidgets('🔴 정확 알람 → 수신기 → FGS → Dart onWake(꼬리표 · 예정 시각 · 지연)', (
    _,
  ) async {
    final DateTime at = DateTime.now().toUtc().add(const Duration(seconds: 8));
    final DateTime atMs = DateTime.fromMillisecondsSinceEpoch(
      at.millisecondsSinceEpoch,
      isUtc: true,
    );
    expect(
      await ops.arm(<AlarmItem>[AlarmItem(tag: 'it-probe', atUtc: at)]),
      isTrue,
    );
    WakeEvent? got;
    for (int i = 0; i < 240 && got == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      for (final WakeEvent e in wakes) {
        if (e.tag == 'it-probe') got = e;
      }
    }
    expect(got, isNotNull, reason: '60초 안에 깨어남이 와야 한다');
    expect(got!.reason, WakeReason.alarm);
    expect(got.scheduledAtUtc, atMs);
    expect(got.delay!.isNegative, isFalse);
    expect(got.delay!.inSeconds, lessThan(30));
    debugPrint('PROBE delay=${got.delay!.inMilliseconds}ms');
    await ops.idle();
  });

  testWidgets('🔴 깨어남은 Kotlin 이 먼저 실측 기록에 적는다(엔진이 죽어도 남게)', (_) async {
    final File log = File('$_files/aaq_wake_log.jsonl');
    expect(log.existsSync(), isTrue);
    final String body = log.readAsStringSync();
    expect(body, contains('"tag":"it-probe"'));
    expect(body, contains('"reason":"alarm"'));
    expect(body, contains('"deviceIdle":'));
  });

  testWidgets('계획 교체 — 빈 계획이면 앞 알람이 울리지 않는다', (_) async {
    final DateTime at = DateTime.now().toUtc().add(const Duration(seconds: 5));
    await ops.arm(<AlarmItem>[AlarmItem(tag: 'it-cancelled', atUtc: at)]);
    await ops.arm(const <AlarmItem>[]);
    await Future<void>.delayed(const Duration(seconds: 12));
    expect(wakes.where((WakeEvent e) => e.tag == 'it-cancelled'), isEmpty);
  });
}
