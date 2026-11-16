// 01 §4-1 — 🆕 계약 v1.22(01 §31 · K6 · K65) — `M5-4` 브레이커 사다리 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용 `watchState`)는 무변경 — 넓히면 UI 가짜 7 · ds 구현 · 조립 앱이 깨진다(v1.21 실측).

import '../dto/safety_gate.dart';

/// 사다리 한 화면.
abstract interface class BreakerLadderRepository {
  Stream<BreakerLadderVm> watchLadder();
}
