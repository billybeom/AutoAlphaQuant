// 01 §4-1 — 🆕 계약 v1.39(01 §48 · K345 · 01 §8 미결 188 · 13 §8 R243 P3 ⓑ) — `M5-4` postmortem 읽기 창구(`ui_safety` 만 · 폰 전용).
//
// 🔴 기존 `IncidentRepository`(D-01 배너 · 셸 주입 · 뷰어) 무변경 — 배너는 0/1건, 이 창구는 써야 할 사건 목록(`BlockBoardRepository` 선례).
// 🔴 쓰기 = `SafetyActions.runPostmortem` 하나(상태를 바꾸는 경로 0 — C-7).

import '../dto/postmortem.dart';

/// `M5-4` 한 화면.
abstract interface class PostmortemRepository {
  Stream<PostmortemListVm> watchPostmortems();
}
