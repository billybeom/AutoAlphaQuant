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
// 🆕 M5-5 차단 보드(설계 13 §8 R185 · 🆕 R189 RECON 행 해제 폼 — 쓰기 = 안전 동작 창구 `runReconClear`).
export 'src/block_board/block_board_screen.dart'
    show BlockBoardScreen, safetyBlockBoardRepositoryProvider;
// 🆕 M5-11 simToAuto 위저드 · handoverStatus 같은 본문(설계 13 §8 R191 · 동작 = SettingsActions.run · 행에 엔진이 준 것만).
export 'src/handover/handover_wizard_screen.dart'
    show
        HandoverWizardScreen,
        safetyHandoverRepositoryProvider,
        safetySettingsActionsProvider;
export 'src/kill_switch/kill_resume_gate_screen.dart' show KillResumeGateScreen;
export 'src/kill_switch/kill_switch_screen.dart'
    show
        KillSwitchActivateButton,
        KillSwitchScreen,
        KillSwitchSlot,
        safetyKillCommandApiProvider,
        safetyKillSwitchGateRepositoryProvider,
        safetyLinkOpenerProvider;
// 🆕 X1 기기 이전(E16j-b · 01 §42 · 옛 폰 마법사 · 새 폰 받기 · 비상 — 동작 = 엔진이 VM · 행에 준 것만 · 슬롯 = 조립 앱).
export 'src/migration/x1_screens.dart'
    show
        SafetyX1SlotBuilder,
        X1PlanWizardScreen,
        X1RecoveryRoute,
        X1RecoveryScreen,
        safetyMigrationRepositoryProvider,
        safetyX1SlotBuilderProvider;
// 🆕 M5-8 서약(설계 13 §8 R157) — 읽기 + 쓰기(쓰기 주입 = 폰만 · 뷰어 null = 컨트롤 부재 → 배럴에 둔다).
export 'src/pledge/pledge_panel.dart'
    show PledgePanel, safetyActionsProvider, safetyPledgeRepositoryProvider;
// 🆕 X5 정정 마법사(설계 13 §8 R227 · 허브 · 대상 한 화면 — 동작 = 엔진이 준 것 · 제출 3 = 안전 동작 창구).
export 'src/repair/repair_wizard_screen.dart'
    show RepairWizardScreen, safetyRepairWizardRepositoryProvider;
// 🆕 X2 재개 리포트 · 게이트(설계 13 §8 R186 · 읽기 + 계절 3택 — 동작 = 엔진이 행에 준 것만).
export 'src/resume/resume_screens.dart'
    show
        ResumeGateScreen,
        ResumeReportScreen,
        safetyResumeGateRepositoryProvider;
// 🆕 M5-9 규칙 변경 게이트 «첫 승인 최소판»(설계 13 §8 R188 · 요청 · 승인 · 취소 = 안전 동작 창구).
export 'src/rule_change/rule_change_gate_screen.dart'
    show RuleChangeGateScreen, safetyRuleChangeGateRepositoryProvider;
