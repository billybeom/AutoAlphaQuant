// 01 §4-1 — 안전 상태(M5·M8) 읽기 창구.
//
// 🔴 소유 경계는 타입이 아니라 «무엇을 그리는가»다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**다. C-7 이 그 표대로 검사한다.

import '../dto/safety.dart';

/// 브레이커·차단 플래그·킬스위치 표시 상태.
abstract interface class SafetyRepository {
  Stream<SafetyState> watchState();
}
