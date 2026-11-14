// E11p · P3 — 금고 어댑터의 채널 계약(Kotlin `KeystoreVault` 를 흉내 낸 가짜 쪽과 맞춘다).
//
// 실 Keystore 왕복은 integration_test/ (에뮬레이터 · 폰) 몫이다.

import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.vault);
const String _secret = 'PLAIN-SECRET-9f3a';

/// Kotlin 쪽 흉내 — 칸 지도 + 강제 오류 코드.
class _FakeNative {
  final Map<String, String> cells = <String, String>{};
  final List<MethodCall> calls = <MethodCall>[];
  String? failCode;
  List<String>? idsOverride;

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    final String? code = failCode;
    if (code != null) {
      // 🔴 Kotlin 은 message · details 를 null 로 보내지만, 어댑터가 그것에 기대지 않는지 보려고 값을 일부러 싣는다.
      throw PlatformException(code: code, message: _secret, details: _secret);
    }
    final Map<Object?, Object?> a =
        (call.arguments as Map<Object?, Object?>?) ??
        const <Object?, Object?>{};
    switch (call.method) {
      case 'read':
        return cells[a['id']! as String];
      case 'write':
        cells[a['id']! as String] = a['value']! as String;
        return null;
      case 'delete':
        cells.remove(a['id']! as String);
        return null;
      case 'ids':
        return idsOverride ?? (cells.keys.toList()..sort());
    }
    throw MissingPluginException();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeNative native;
  late AndroidSecretVault vault;
  final SecretId appKey = SecretId('kis.live.app_key');

  void install(Future<Object?> Function(MethodCall)? h) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_ch, h);

  setUp(() {
    native = _FakeNative();
    install(native.handle);
    vault = AndroidSecretVault();
  });

  tearDown(() => install(null));

  test('없는 칸 = null · 부른 이름 = read · 인자 = id 하나', () async {
    expect(await vault.read(appKey), isNull);
    expect(native.calls.single.method, 'read');
    expect(native.calls.single.arguments, <String, Object?>{
      'id': 'kis.live.app_key',
    });
  });

  test('쓰고 읽기 · 지우기 · 이름 목록', () async {
    await vault.write(appKey, _secret);
    await vault.write(SecretId('hc.ping_key'), 'k2');
    expect(native.calls.first.arguments, <String, Object?>{
      'id': 'kis.live.app_key',
      'value': _secret,
    });
    expect(await vault.read(appKey), _secret);
    expect(await vault.ids(), <SecretId>{appKey, SecretId('hc.ping_key')});
    await vault.delete(appKey);
    expect(await vault.read(appKey), isNull);
    expect(await vault.ids(), <SecretId>{SecretId('hc.ping_key')});
  });

  test('🔴 못 엶(unreadable) = 오류 — null 이 아니다 · 이름은 실리고 값은 안 실린다', () async {
    native.failCode = OperatorChannelCodes.unreadable;
    final Object e = await vault
        .read(appKey)
        .then<Object>((_) => fail('던져야 한다'), onError: (Object e) => e);
    expect(e, isA<SecretVaultError>());
    final String s = e.toString();
    expect(s, contains('읽을 수 없다'));
    expect(s, contains('kis.live.app_key'));
    expect(s, isNot(contains(_secret)));
  });

  test('🔴 쓰기 실패에도 값이 오류 글에 없다', () async {
    native.failCode = OperatorChannelCodes.io;
    await expectLater(
      vault.write(appKey, _secret),
      throwsA(
        isA<SecretVaultError>()
            .having(
              (SecretVaultError e) => e.message,
              'message',
              contains('입출력'),
            )
            .having(
              (SecretVaultError e) => e.toString(),
              'toString',
              isNot(contains(_secret)),
            ),
      ),
    );
  });

  test('코드 → 사유(모르는 코드 = 쓸 수 없다)', () async {
    final Map<String, String> want = <String, String>{
      OperatorChannelCodes.badId: '이름 꼴이 아니다',
      OperatorChannelCodes.badArgs: '인자 꼴이 아니다',
      OperatorChannelCodes.unavailable: '금고를 쓸 수 없다',
      'something_new': '금고를 쓸 수 없다',
    };
    for (final MapEntry<String, String> w in want.entries) {
      native.failCode = w.key;
      await expectLater(
        vault.delete(appKey),
        throwsA(
          isA<SecretVaultError>().having(
            (SecretVaultError e) => e.message,
            'message ${w.key}',
            startsWith(w.value),
          ),
        ),
      );
    }
  });

  test('어댑터가 없다(채널 미등록) = SecretVaultError', () async {
    install(null);
    await expectLater(
      vault.read(appKey),
      throwsA(
        isA<SecretVaultError>().having(
          (SecretVaultError e) => e.message,
          'message',
          '금고 어댑터가 없다',
        ),
      ),
    );
  });

  test('🔴 꼴이 아닌 이름이 오면 건너뛰지 않고 던진다', () async {
    native.idsOverride = <String>['ok.name', '../escape'];
    await expectLater(vault.ids(), throwsA(isA<SecretVaultError>()));
  });

  test('🔴 readAllSecretValues — 못 연 칸이 있으면 스캔 목록이 조용히 줄지 않고 던진다', () async {
    await vault.write(appKey, _secret);
    await vault.write(SecretId('hc.ping_key'), 'k2');
    expect(await readAllSecretValues(vault), <String>['k2', _secret]);
    // 목록은 돌려주되 read 가 못 엶을 내는 Kotlin 흉내.
    install((MethodCall call) async {
      if (call.method == 'ids') {
        return <String>['hc.ping_key', 'kis.live.app_key'];
      }
      throw PlatformException(code: OperatorChannelCodes.unreadable);
    });
    await expectLater(
      readAllSecretValues(vault),
      throwsA(isA<SecretVaultError>()),
    );
  });
}
