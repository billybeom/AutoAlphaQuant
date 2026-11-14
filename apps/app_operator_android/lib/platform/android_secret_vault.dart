// 키 금고 — core `SecretVault` 포트의 Android 어댑터(E11p · 설계 e11p-map P3 · 06 M4-4 · D20).
//
// 실물 = Kotlin `KeystoreVault`(Keystore 키로 봉한 칸 파일 · noBackupFilesDir). 여기는 채널을 건너는 일만 한다.
// 🔴 «없음» = null · «못 엶» = `SecretVaultError` — 시크릿 스캔이 못 연 칸을 조용히 건너뛰지 않게.
// 🔴 오류 메시지는 이름 · 사유만(값 0) — Kotlin 이 보낸 message · details 는 읽지 않는다.

import 'package:core_engine/core_engine.dart'
    show SecretId, SecretVault, SecretVaultError;
import 'package:flutter/services.dart';

import 'operator_channels.dart';

/// Android Keystore 금고 어댑터.
class AndroidSecretVault implements SecretVault {
  /// 어댑터를 만든다 — [channel] 은 시험용 대체.
  AndroidSecretVault({MethodChannel? channel})
    : _ch = channel ?? const MethodChannel(OperatorChannelNames.vault);

  final MethodChannel _ch;

  @override
  Future<String?> read(SecretId id) => _guard(
    id,
    () => _ch.invokeMethod<String>('read', <String, Object?>{'id': id.value}),
  );

  @override
  Future<void> write(SecretId id, String value) => _guard(
    id,
    () => _ch.invokeMethod<void>('write', <String, Object?>{
      'id': id.value,
      'value': value,
    }),
  );

  @override
  Future<void> delete(SecretId id) => _guard(
    id,
    () => _ch.invokeMethod<void>('delete', <String, Object?>{'id': id.value}),
  );

  @override
  Future<Set<SecretId>> ids() async {
    final List<String>? names = await _guard(
      null,
      () => _ch.invokeListMethod<String>('ids'),
    );
    final Set<SecretId> out = <SecretId>{};
    for (final String n in names ?? const <String>[]) {
      try {
        out.add(SecretId(n));
      } on ArgumentError {
        // 🔴 꼴이 아닌 칸은 «없음»으로 넘기지 않는다 — 스캔이 그 칸을 빠뜨린 채 통과하지 않게.
        throw const SecretVaultError('이름 꼴이 아닌 칸이 있다');
      }
    }
    return out;
  }

  Future<T> _guard<T>(SecretId? id, Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      throw SecretVaultError(_message(e.code, id));
    } on MissingPluginException {
      throw const SecretVaultError('금고 어댑터가 없다');
    }
  }

  static String _message(String code, SecretId? id) {
    final String name = id == null ? '' : ': ${id.value}';
    return switch (code) {
      OperatorChannelCodes.unreadable => '읽을 수 없다$name',
      OperatorChannelCodes.badId => '이름 꼴이 아니다',
      OperatorChannelCodes.badArgs => '인자 꼴이 아니다',
      OperatorChannelCodes.io => '저장소 입출력 실패$name',
      _ => '금고를 쓸 수 없다$name',
    };
  }
}
