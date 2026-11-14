// E11p · P2 — 봉함 어댑터의 채널 계약(Kotlin `DekSealedBox` 를 흉내 낸 가짜 쪽과 맞춘다).
//
// 🔴 포트 약속: 열기 실패 = null(던지지 않는다) · 봉함 실패 = 던진다(값 0).
// 실 Keystore · AES-GCM 은 integration_test/ (에뮬레이터 · 폰) 몫이다.

import 'dart:convert';

import 'package:app_operator_android/platform/platform.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.sealedBox);

/// Kotlin 쪽 흉내 — aad 를 앞에 붙여 «봉한» 척한다(aad 가 다르면 null).
Future<Object?> _fakeNative(MethodCall call) async {
  final Map<Object?, Object?> a = call.arguments as Map<Object?, Object?>;
  final List<int> aad = utf8.encode(a['aad']! as String);
  switch (call.method) {
    case 'seal':
      return Uint8List.fromList(<int>[
        aad.length,
        ...aad,
        ...a['plain']! as Uint8List,
      ]);
    case 'open':
      final Uint8List s = a['sealed']! as Uint8List;
      final int n = s.isEmpty ? -1 : s[0];
      if (n < 0 || s.length < 1 + n) return null;
      if (!listEquals(s.sublist(1, 1 + n), aad)) return null;
      return Uint8List.fromList(s.sublist(1 + n));
  }
  throw MissingPluginException();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AndroidSealedBox box;
  final Uint8List plain = Uint8List.fromList(
    utf8.encode('{"draft":"PLAIN-9f3a"}'),
  );

  void install(Future<Object?> Function(MethodCall)? h) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_ch, h);

  setUp(() {
    install(_fakeNative);
    box = AndroidSealedBox();
  });

  tearDown(() => install(null));

  test('봉함 · 열기 왕복 · 부른 이름과 인자', () async {
    final List<MethodCall> seen = <MethodCall>[];
    install((MethodCall c) {
      seen.add(c);
      return _fakeNative(c);
    });
    final Uint8List s = await box.seal(plain, aad: 'v1|LIVE|draft|k1');
    expect(await box.open(s, aad: 'v1|LIVE|draft|k1'), plain);
    expect(seen.map((MethodCall c) => c.method), <String>['seal', 'open']);
    expect(
      (seen.first.arguments as Map<Object?, Object?>).keys,
      unorderedEquals(<String>['plain', 'aad']),
    );
    expect(
      (seen.last.arguments as Map<Object?, Object?>).keys,
      unorderedEquals(<String>['sealed', 'aad']),
    );
  });

  test('🔴 aad 가 다르면 null(다른 계열 · 이름공간에서 열리지 않는다)', () async {
    final Uint8List s = await box.seal(plain, aad: 'v1|SIM|draft|k1');
    expect(await box.open(s, aad: 'v1|LIVE|draft|k1'), isNull);
  });

  test('🔴 열기 — 플랫폼 오류 · 어댑터 없음 · 꼴 틀린 답 모두 null(던지지 않는다)', () async {
    install((MethodCall c) async => throw PlatformException(code: 'boom'));
    expect(await box.open(plain, aad: 'a'), isNull);
    install(null);
    expect(await box.open(plain, aad: 'a'), isNull);
    install((MethodCall c) async => 'not bytes');
    expect(await box.open(plain, aad: 'a'), isNull);
  });

  test('🔴 봉함 실패 = SealedBoxFailure(값 0) — 플랫폼 오류 · 어댑터 없음 · 빈 답', () async {
    final List<Future<Object?> Function(MethodCall)?> natives =
        <Future<Object?> Function(MethodCall)?>[
          (MethodCall c) async => throw PlatformException(
            code: OperatorChannelCodes.sealFailed,
            message: 'PLAIN-9f3a',
          ),
          null,
          (MethodCall c) async => null,
          (MethodCall c) async => Uint8List(0),
        ];
    for (final Future<Object?> Function(MethodCall)? n in natives) {
      install(n);
      await expectLater(
        box.seal(plain, aad: 'a'),
        throwsA(
          isA<SealedBoxFailure>().having(
            (SealedBoxFailure e) => e.toString(),
            'toString',
            isNot(contains('PLAIN-9f3a')),
          ),
        ),
      );
    }
  });
}
