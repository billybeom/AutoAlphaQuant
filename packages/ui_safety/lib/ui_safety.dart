// ui_safety — M5(안전·마찰) 화면 패키지의 배럴.
//   M5 킬스위치·해제 게이트 · X1 기기 이전 마법사 · X2 재개 게이트 ·
//   X5 정정 마법사.
//
// 🔴 **소유자는 Claude다.** 다른 AI는 이 패키지의 파일을 편집하지 않는다.
//    C-7(안전 화면 소유권)은 이 패키지를 제외한 ui_*에서 해당 렌더·조작을
//    찾으면 실패한다 — 여기가 그 «허용된 한 곳»이다.
//
// 🔴 **불편이 사양이다**(경계 규칙 ③). 킬스위치 48h 대기·체크리스트 7항 순차
//    통과·저널 요구는 «UX 개선»의 대상이 아니다. 발동은 확인 대화 없이 즉시,
//    해제는 느리고 번거롭게 — 이 비대칭이 설계다.
//
// 🔴 마찰 카운트다운을 로컬 시계로 계산하지 않는다. 신뢰 시각은 Supabase 서버
//    시각이고, 화면은 SafetyState.releaseProgress를 그대로 표시한다.
//
// 화면 위젯은 lib/src/ 아래로 들어오고 공개할 것만 여기에서 export 한다.
// 🔴 operator 전용 화면은 여기 넣지 않는다 — 🆕 M5-14 가상 초기금 = `package:ui_safety/sim_opening.dart`
//    (설계 13 §8 R156 · C-35 ⑥ — 뷰어 조립도 이 배럴을 싣는다).

export 'l10n/labels.dart';
export 'src/kill_switch/kill_resume_gate_screen.dart' show KillResumeGateScreen;
export 'src/kill_switch/kill_switch_screen.dart'
    show
        KillSwitchActivateButton,
        KillSwitchScreen,
        KillSwitchSlot,
        safetyKillCommandApiProvider,
        safetyKillSwitchGateRepositoryProvider,
        safetyLinkOpenerProvider;
// 🆕 M5-8 서약(설계 13 §8 R157) — 읽기 + 쓰기(쓰기 주입 = 폰만 · 뷰어 null = 컨트롤 부재 → 배럴에 둔다).
export 'src/pledge/pledge_panel.dart'
    show PledgePanel, safetyActionsProvider, safetyPledgeRepositoryProvider;
