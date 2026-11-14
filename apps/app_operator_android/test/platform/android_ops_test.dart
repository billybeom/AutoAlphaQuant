// E11p2 · P5 · P8 · P12 — 운영 채널 어댑터 계약(Kotlin `OpsChannel` 흉내).

import 'package:app_operator_android/platform/platform.dart';
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
}
