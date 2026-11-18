// ui_safety operator 전용 라이브러리 — M5-14 가상 초기금(설계 13 §8 R156 · 06 M5-14 · O-04 ⑥ 자동 매매 갈래).
//
// 🔴 배럴(`ui_safety.dart`)에 넣지 않는다 — 이 화면은 폰(operator) 전용 기록 명령(`submitSelfReportBalance`)과 본문 입력
//    DTO(`SelfReportInput`)를 말한다. 뷰어(iOS · 웹) 조립도 `ui_safety` 를 싣기 때문에(킬스위치 발동) 배럴에 두면 뷰어가
//    이것을 끌어온다 — `ui_journal/journal_draft.dart` · `ui_analytics/planner.dart` 와 같은 꼴(C-35 ⑥ · TARGETS T-3).
// 🔴 방향 = 이 라이브러리 → 배럴 쪽(글자 사전)만. 배럴 쪽 파일이 이것을 import · export 하면 C-35 ⑥ 이 막는다.

export 'src/sim_opening/sim_opening_cash.dart'
    show SimOpeningCash, safetySimOpeningCommandApiProvider;
