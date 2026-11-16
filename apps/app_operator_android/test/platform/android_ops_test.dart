// E11p2 · P5 · P8 · P12 — 운영 채널 어댑터 계약(Kotlin `OpsChannel` 흉내).

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart' show DeviceRiskFacts;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.ops);

Future<void> _fromNative(String method, Object? args) =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          OperatorChannelNames.ops,
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(method, args),
          ),
          (_) {},
        );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final List<MethodCall> calls = <MethodCall>[];
  Object? reply;

  void install(Future<Object?> Function(MethodCall)? h) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_ch, h);

  setUp(() {
    calls.clear();
    reply = null;
    install((MethodCall c) async {
      calls.add(c);
      return reply;
    });
  });
  tearDown(() => install(null));

  test('arm — 꼬리표 · UTC 밀리초 · 정확 여부를 돌려받는다(없으면 false)', () async {
    reply = true;
    final bool exact = await AndroidOps().arm(<AlarmItem>[
      AlarmItem(
        tag: 'kr_order@2026-11-16',
        atUtc: DateTime.utc(2026, 11, 16, 0, 5),
      ),
    ]);
    expect(exact, isTrue);
    expect(calls.single.method, 'arm');
    expect(calls.single.arguments, <String, Object?>{
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'tag': 'kr_order@2026-11-16',
          'atMs': DateTime.utc(2026, 11, 16, 0, 5).millisecondsSinceEpoch,
        },
      ],
    });
    reply = null;
    expect(await AndroidOps().arm(const <AlarmItem>[]), isFalse);
  });

  test('🔴 H-03 기기 측정(R136) — 값 그대로 · 잰 시각 = 넘긴 시각(UTC) · 모르는 칸 · 꼴 틀림 · 음수 · 빈 글자 = null', () async {
    final DateTime at = DateTime.utc(2026, 11, 16, 23, 55);
    reply = <String, Object?>{
      'storageFreeBytes': 5123456789,
      'batteryHealth': 'GOOD',
      'batteryCycleCount': 312,
      'batteryTempTenthsC': 365,
      'securityPatch': '2026-10-05',
    };
    final DeviceRiskFacts f = await AndroidOps().deviceRisk(at);
    expect(calls.single.method, 'deviceRisk');
    expect(f.measuredAtUtc, at);
    expect(f.storageFreeBytes, 5123456789);
    expect(f.batteryHealth, 'GOOD');
    expect(f.batteryCycleCount, 312);
    expect(f.batteryTempTenthsC, 365);
    expect(f.securityPatch, '2026-10-05');
    final DeviceRiskFacts bad = deviceRiskFactsFromWire(<String, Object?>{
      'storageFreeBytes': -1,
      'batteryHealth': '  ',
      'batteryCycleCount': -1,
      'batteryTempTenthsC': '365',
      'securityPatch': 20261005,
    }, at);
    expect(bad.storageFreeBytes, isNull);
    expect(bad.batteryHealth, isNull);
    expect(bad.batteryCycleCount, isNull);
    expect(bad.batteryTempTenthsC, isNull);
    expect(bad.securityPatch, isNull);
    // 영하 온도는 음수라도 값이다.
    expect(
      deviceRiskFactsFromWire(<String, Object?>{
        'batteryTempTenthsC': -5,
      }, at).batteryTempTenthsC,
      -5,
    );
    final DeviceRiskFacts none = deviceRiskFactsFromWire(null, at);
    expect(<Object?>[
      none.storageFreeBytes,
      none.batteryHealth,
      none.batteryCycleCount,
      none.batteryTempTenthsC,
      none.securityPatch,
    ], everyElement(isNull));
    expect(
      deviceRiskFactsFromWire(
        null,
        DateTime(2026, 11, 17, 8, 55),
      ).measuredAtUtc.isUtc,
      isTrue,
    );
  });

  test('🔴 자가진단 — 모르는 칸 · 꼴 틀림은 «좋음»으로 지어내지 않는다(false · 0)', () async {
    reply = <String, Object?>{
      'notificationsEnabled': true,
      'exactAlarm': 'yes',
      'batteryExempt': null,
      'fgsRunning': true,
      'fgsStartDenied': 3,
    };
    final SurvivalFacts f = await AndroidOps().diagnose();
    expect(f.notificationsEnabled, isTrue);
    expect(f.exactAlarm, isFalse);
    expect(f.batteryExempt, isFalse);
    expect(f.p0BypassDnd, isFalse);
    expect(f.fgsRunning, isTrue);
    expect(f.fgsStartDenied, 3);
    reply = 'garbage';
    final SurvivalFacts g = await AndroidOps().diagnose();
    expect(<bool>[
      g.notificationsEnabled,
      g.exactAlarm,
      g.batteryExempt,
      g.p0BypassDnd,
      g.fgsRunning,
    ], everyElement(isFalse));
  });

  test('listen — 받기를 먼저 걸고 그다음 ready(모아 둔 깨어남을 놓치지 않게)', () async {
    final List<WakeEvent> wakes = <WakeEvent>[];
    final List<String> links = <String>[];
    install((MethodCall c) async {
      calls.add(c);
      if (c.method == 'ready') {
        // Kotlin 이 ready 를 받자마자 모아 둔 것을 보낸다.
        await _fromNative('onWake', <String, Object?>{
          'reason': 'boot',
          'tag': null,
          'scheduledAtMs': null,
          'firedAtMs': 1000,
        });
        await _fromNative('onLink', 'aaq://alerts/detail/a1');
      }
      return null;
    });
    await AndroidOps().listen(onWake: wakes.add, onLink: links.add);
    expect(calls.single.method, 'ready');
    expect(wakes.single.reason, WakeReason.boot);
    expect(wakes.single.delay, isNull);
    expect(links, <String>['aaq://alerts/detail/a1']);
  });

  test('깨어남 와이어 — 지연 · 모르는 까닭 · 꼴 틀림은 버린다', () {
    final WakeEvent e = WakeEvent.fromWire(<String, Object?>{
      'reason': 'alarm',
      'tag': 'kr_order@2026-11-16',
      'scheduledAtMs': 1000,
      'firedAtMs': 61000,
    })!;
    expect(e.delay, const Duration(minutes: 1));
    expect(
      WakeEvent.fromWire(<String, Object?>{'reason': 'zzz', 'firedAtMs': 1})!
          .reason,
      WakeReason.unknown,
    );
    expect(WakeEvent.fromWire(<String, Object?>{'reason': 'alarm'}), isNull);
    expect(WakeEvent.fromWire('x'), isNull);
  });

  test('ensureChannels — 채널 이름 표 그대로 · id 는 FgsChannel 글자', () async {
    await AndroidOps().ensureChannels(kOpsChannelNames);
    expect(calls.single.arguments, <String, Object?>{
      'names': kOpsChannelNames,
    });
    expect(
      kOpsChannelNames.keys,
      unorderedEquals(<String>['ops_status', 'ops_p0']),
    );
  });

  test('paths — 엔진 원장 = noBackup/engine · 🔴 꼴이 아니면 지어내지 않고 던진다', () async {
    reply = <String, Object?>{'files': '/d/files', 'noBackup': '/d/no_backup'};
    final OperatorPaths p = await AndroidOps().paths();
    expect(calls.single.method, 'paths');
    expect(p.files, '/d/files');
    expect(p.engineDir, '/d/no_backup/engine');
    for (final Object? bad in <Object?>[
      null,
      'x',
      <String, Object?>{'files': '/d/files'},
      <String, Object?>{'files': '', 'noBackup': '/n'},
      <String, Object?>{'files': 1, 'noBackup': '/n'},
    ]) {
      reply = bad;
      await expectLater(
        AndroidOps().paths(),
        throwsA(isA<StateError>()),
        reason: '$bad',
      );
    }
  });
}
