// 01 §4-1 — 🆕 계약 v1.22(01 §31 · K6 · K64) — X2 재개 게이트 읽기 창구(`x2ResumeGate` · `ui_safety` 만).
// 🆕 v1.25(01 §34 · K156) — X2 재개 화면 읽기 창구로 넓힘(게이트 + 리포트 감싸개 · 구현 = 받침대뿐 — 실측).
//
// 🔴 기존 `ResumeRepository`(`watchLatest` · `watchPlannedWork`)는 무변경 — ds `SqliteResumeRepository` 가 implements(실측).
// 🔴 쓰기 = `SafetyActions.run(seasonalWindowChoice, …)`(행의 `actions` 그대로).

import '../dto/resume.dart';

/// 재개 게이트 한 화면.
abstract interface class ResumeGateRepository {
  Stream<ResumeGateVm> watchGate();

  /// 🆕 v1.25(01 §34 · K156) — X2 재개 리포트 한 화면(감싸개 · 🔴 `ResumeRepository` 무변경 — ds 가 implements).
  Stream<ResumeReportVm> watchReport();
}
