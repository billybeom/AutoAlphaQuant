// 01 §4-1 — 🆕 계약 v1.21(01 §30 · K6) — M5-2 킬스위치 재개 게이트 읽기 창구(폰 전용 · `ui_safety` 만).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용 `watchState`)는 무변경 — 넓히면 UI 가짜 7 · ds 구현 · 조립 앱이 깨진다(실측).
// 🔴 상태를 바꾸는 경로 0(C-7) — 쓰기 = `SafetyActions.runKillResumeItem`.

import '../dto/safety_gate.dart';

/// 재개 게이트 한 화면.
abstract interface class KillSwitchGateRepository {
  Stream<KillResumeGateVm> watchResumeGate();
}
