// E11p3d-5 운영 채널 — 권한 요청 · 캡처 막기 · 바깥 링크(설계 13 §8 R107) · 채널 = 흉내.

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.ops);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> calls;
  Object? reply;

  setUp(() {
    calls = <MethodCall>[];
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ch, (MethodCall c) async {
          calls.add(c);
          return reply;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ch, null),
  );

  test('🔴 권한 요청 = 종류 글자를 보내고 결과 넷을 그대로 · 모르는 응답 = 불가', () async {
    final AndroidOps ops = AndroidOps();
    final Map<String, PermissionRequestOutcome> want =
        <String, PermissionRequestOutcome>{
          'ALREADY_GRANTED': PermissionRequestOutcome.alreadyGranted,
          'REQUESTED': PermissionRequestOutcome.requested,
          'NO_ACTIVITY': PermissionRequestOutcome.noActivity,
          'UNSUPPORTED': PermissionRequestOutcome.unsupported,
          'WHAT': PermissionRequestOutcome.unsupported,
        };
    for (final MapEntry<String, PermissionRequestOutcome> e in want.entries) {
      reply = e.key;
      expect(
        await ops.requestPermission(OpsPermission.batteryExemption),
        e.value,
      );
    }
    reply = null;
    expect(
      await ops.requestPermission(OpsPermission.notifications),
      PermissionRequestOutcome.unsupported,
    );
    expect(
      calls.map((MethodCall c) => (c.method, (c.arguments as Map)['kind'])),
      everyElement(
        isA<(String, Object?)>().having(
          ((String, Object?) r) => r.$1,
          'method',
          'requestPermission',
        ),
      ),
    );
    expect((calls.last.arguments as Map)['kind'], 'notifications');
    expect(OpsPermission.values.map((OpsPermission p) => p.wire), <String>[
      'notifications',
      'batteryExemption',
      'exactAlarm',
    ]);
  });

  test('캡처 막기 = 켜기 · 끄기 그대로', () async {
    final AndroidOps ops = AndroidOps();
    await ops.setSecure(true);
    await ops.setSecure(false);
    expect(calls.map((MethodCall c) => c.method), <String>[
      'setSecure',
      'setSecure',
    ]);
    expect(calls.map((MethodCall c) => (c.arguments as Map)['on']), <bool>[
      true,
      false,
    ]);
  });

  test('🔴 바깥 링크 = https 만 채널로 · 그 밖 = ArgumentError(보내지 않는다)', () async {
    final AndroidOps ops = AndroidOps();
    reply = true;
    expect(
      await ops.openExternalUrl('https://apiportal.koreainvestment.com'),
      true,
    );
    expect(calls.single.method, 'openUrl');
    expect(
      (calls.single.arguments as Map)['url'],
      'https://apiportal.koreainvestment.com',
    );
    for (final String bad in <String>[
      'http://example.com',
      'aaq://alerts/inbox',
      'https://',
      'javascript:alert(1)',
      '',
    ]) {
      await expectLater(
        ops.openExternalUrl(bad),
        throwsArgumentError,
        reason: bad,
      );
    }
    expect(calls, hasLength(1));
    reply = null;
    expect(await ops.openExternalUrl('https://github.com'), false);
  });

  test('바깥 링크 판정', () {
    expect(isExternalHttps('https://healthchecks.io/projects'), true);
    expect(isExternalHttps('https://x'), true);
    expect(isExternalHttps('http://healthchecks.io'), false);
    expect(isExternalHttps('aaq://settings'), false);
    expect(isExternalHttps('https:///nohost'), false);
  });
}
