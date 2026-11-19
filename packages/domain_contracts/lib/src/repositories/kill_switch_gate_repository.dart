// 01 §4-1 — 🆕 계약 v1.21(01 §30 · K6) — M5-2 킬스위치 재개 게이트 읽기 창구(폰 전용 · `ui_safety` 만).
// 🆕 v1.25(01 §34 · K146) — 킬스위치 화면 읽기 창구로 넓힘(`M5-1` 화면 + `M5-2` 게이트 · 구현 = 받침대뿐 — 실측).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용 `watchState`)는 무변경 — 넓히면 UI 가짜 7 · ds 구현 · 조립 앱이 깨진다(실측).
// 🔴 상태를 바꾸는 경로 0(C-7) — 쓰기 = `SafetyActions.runKillResumeItem`.

import '../dto/safety_gate.dart';

/// 재개 게이트 한 화면.
abstract interface class KillSwitchGateRepository {
  Stream<KillResumeGateVm> watchResumeGate();

  /// 🆕 v1.25(01 §34 · K146) — `M5-1` 킬스위치 한 화면(발동 버튼 · 취소 보고 · 발동 뒤 기록 폼 · 게이트 링크).
  Stream<KillSwitchScreenVm> watchKillSwitch();
}
