// 봉함 포트(설계 13 §8 R44 E6 · 06 M4-9 · 01 §12-1 «해독 실패 = load null»).
//
// 🔴 열기 실패(키 소실 · 백업 복원 · 변조 · aad 다름)는 **null** — 던지지 않는다. 초안 · 큐는 «없음»으로 보고
//    새로 시작한다(01 §12-1 의무). 🔴 aad = 계열(SIM · LIVE) · 이름공간을 묶는다 — 다른 계열에서 열리지 않는다.
// 🔵 실물 = Android Keystore 비내보내기 키로 감싼 DEK + AES-GCM(E11p) · 내구 큐 · 초안(E11e)이 쓴다.

import 'dart:typed_data';

/// 봉함 포트.
abstract interface class SealedBox {
  /// [plain] 을 [aad] 에 묶어 봉한다.
  Future<Uint8List> seal(Uint8List plain, {required String aad});

  /// 연다 — 🔴 실패 = null(던지지 않는다).
  Future<Uint8List?> open(Uint8List sealed, {required String aad});
}
