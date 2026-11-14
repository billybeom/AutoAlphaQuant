// 봉함 — core `SealedBox` 포트의 Android 어댑터(E11p · 설계 e11p-map P2 · 06 M4-9 ① · 01 §12-1).
//
// 실물 = Kotlin `DekSealedBox`(Keystore 비내보내기 키로 감싼 DEK + AES-GCM · noBackupFilesDir).
// 🔴 열기 실패는 어떤 경우든 null — 던지지 않는다(포트 약속 · 초안 · 큐는 «없음»으로 새로 시작).
// 🔴 봉함 실패는 `SealedBoxFailure` 로 던진다(값 0) — `DeviceLocal` 이 `writeFailed` 로 옮긴다.

import 'package:core_engine/core_engine.dart' show SealedBox;
import 'package:flutter/services.dart';

import 'operator_channels.dart';

/// 봉함 실패 — 🔴 값 · 사유 글 없음.
class SealedBoxFailure implements Exception {
  /// 실패를 만든다.
  const SealedBoxFailure();

  @override
  String toString() => 'SealedBoxFailure: 봉함 실패';
}

/// Android Keystore 봉함 어댑터.
class AndroidSealedBox implements SealedBox {
  /// 어댑터를 만든다 — [channel] 은 시험용 대체.
  AndroidSealedBox({MethodChannel? channel})
    : _ch = channel ?? const MethodChannel(OperatorChannelNames.sealedBox);

  final MethodChannel _ch;

  @override
  Future<Uint8List> seal(Uint8List plain, {required String aad}) async {
    final Uint8List? out;
    try {
      out = await _ch.invokeMethod<Uint8List>('seal', <String, Object?>{
        'plain': plain,
        'aad': aad,
      });
    } on PlatformException {
      throw const SealedBoxFailure();
    } on MissingPluginException {
      throw const SealedBoxFailure();
    }
    if (out == null || out.isEmpty) throw const SealedBoxFailure();
    return out;
  }

  @override
  Future<Uint8List?> open(Uint8List sealed, {required String aad}) async {
    try {
      return await _ch.invokeMethod<Uint8List>('open', <String, Object?>{
        'sealed': sealed,
        'aad': aad,
      });
    } on Object {
      return null;
    }
  }
}
