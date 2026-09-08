// 01 §5 «모의 데이터 픽스처» · 인벤토리 §8 — 픽스처 상대 경로 상수.
//
// 🔴 경로는 **저장소 루트 기준 상대 경로**다(01 §5 · 04 §10 · 05 §8-2).
//    절대 경로가 코드에 들어가면 반려다.
// 🔴 파일을 읽는 것은 호출자의 일이다 — 이 파일도 `dart:io` 를 쓰지 않는다(§8-5).
// 🔴 파일명은 계약이다 — 「테스트가 안 맞아서」 이름을 바꾸는 것은 반려 사유이고,
//    픽스처 갱신은 M2 만 한다(01 §5).

/// 픽스처 디렉터리(저장소 루트 기준).
const String fixtureRoot = 'packages/domain_contracts/fixtures';

/// 픽스처 파일의 [fixtureRoot] 기준 상대 경로 모음.
abstract final class FixturePaths {
  // ── 계약 코어 · 인벤토리 §8-2·§8-3 (`fixtures/` 바로 아래) ──
  static const String alerts12 = 'alerts_12.json';
  static const String depositPlan1 = 'deposit_plan_1.json';
  static const String depositPlanFunding1 = 'deposit_plan_funding_1.json';
  static const String holdings6 = 'holdings_6.json';
  static const String journal30 = 'journal_30.json';
  static const String ledgerDiffs4 = 'ledger_diffs_4.json';
  static const String onboardingFresh = 'onboarding_fresh.json';
  static const String onboardingReconnect = 'onboarding_reconnect.json';
  static const String performance24m = 'performance_24m.json';
  static const String rebalance6 = 'rebalance_6.json';
  static const String resumeReport1 = 'resume_report_1.json';
  static const String safetyStates = 'safety_states.json';

  // ── m6/ — 매매일지·보유·X7 안내·수기 체결 (02 «모의 데이터») ──
  static const String m6Advice12 = 'm6/advice_12.json';
  static const String m6AdviceBlocked = 'm6/advice_blocked.json';
  static const String m6AdviceDetailOnhold = 'm6/advice_detail_onhold.json';
  static const String m6AdviceDetailPartial = 'm6/advice_detail_partial.json';
  static const String m6AdviceEmpty = 'm6/advice_empty.json';
  static const String m6AdviceExpiredConfirm = 'm6/advice_expired_confirm.json';
  static const String m6AdviceHandoverCooling =
      'm6/advice_handover_cooling.json';
  static const String m6AdviceNoAction = 'm6/advice_no_action.json';
  static const String m6AdviceSkipReasons = 'm6/advice_skip_reasons.json';
  static const String m6AdviceViewer4 = 'm6/advice_viewer_4.json';
  static const String m6EntryGateNovPass1 = 'm6/entry_gate_nov_pass_1.json';
  static const String m6ExternalHoldings2 = 'm6/external_holdings_2.json';
  static const String m6FillFormSpec = 'm6/fill_form_spec.json';
  static const String m6FillFormSpecStale = 'm6/fill_form_spec_stale.json';
  static const String m6FillRejectedPrice = 'm6/fill_rejected_price.json';
  static const String m6ManualFills8 = 'm6/manual_fills_8.json';
  static const String m6SelfReport1 = 'm6/self_report_1.json';

  // ── m7/ — 성과·리밸런싱·플래너·세후·이행 갭 (03 §15) ──
  static const String m7AftertaxLadder1 = 'm7/aftertax_ladder_1.json';
  static const String m7ExecutionGap1 = 'm7/execution_gap_1.json';
  static const String m7ExecutionGapCant = 'm7/execution_gap_cant.json';
  static const String m7ExecutionGapMixed = 'm7/execution_gap_mixed.json';
  static const String m7ExecutionGapWont = 'm7/execution_gap_wont.json';
  static const String m7LedgerTrust4 = 'm7/ledger_trust_4.json';
  static const String m7M7Annual2026 = 'm7/m7_annual_2026.json';
  static const String m7M7AnnualFirstYear = 'm7/m7_annual_first_year.json';
  static const String m7M7Contrib3sleeve = 'm7/m7_contrib_3sleeve.json';
  static const String m7M7DdContextDeep = 'm7/m7_dd_context_deep.json';
  static const String m7M7DdContextNormal = 'm7/m7_dd_context_normal.json';
  static const String m7M7DepositPlanDefault =
      'm7/m7_deposit_plan_default.json';
  static const String m7M7DepositPlanExpired =
      'm7/m7_deposit_plan_expired.json';
  static const String m7M7DepositPlanLimit = 'm7/m7_deposit_plan_limit.json';
  static const String m7M7DisclosureGate = 'm7/m7_disclosure_gate.json';
  static const String m7M7GoalPathHold = 'm7/m7_goal_path_hold.json';
  static const String m7M7GoalPathOn = 'm7/m7_goal_path_on.json';
  static const String m7M7GoalPathRealworld = 'm7/m7_goal_path_realworld.json';
  static const String m7M7Monthly202608 = 'm7/m7_monthly_2026_08.json';
  static const String m7M7MonthlyGap = 'm7/m7_monthly_gap.json';
  static const String m7M7MonthlyPending = 'm7/m7_monthly_pending.json';
  static const String m7M7NextRebalanceD6 = 'm7/m7_next_rebalance_d6.json';
  static const String m7M7PerfDailyGap = 'm7/m7_perf_daily_gap.json';
  static const String m7M7RebalanceDetailBand =
      'm7/m7_rebalance_detail_band.json';
  static const String m7M7ReportArchive18 = 'm7/m7_report_archive_18.json';
  static const String m7M7WithdrawalGeneral = 'm7/m7_withdrawal_general.json';
  static const String m7M7WithdrawalPensionPenalty =
      'm7/m7_withdrawal_pension_penalty.json';
  static const String m7M7WithdrawalShortfall =
      'm7/m7_withdrawal_shortfall.json';
  static const String m7RealizedAllocS7 = 'm7/realized_alloc_S7.json';

  // ── m8/ — 셸·운영 홈·알림·온보딩 (04 §10) ──
  static const String m8AlertsAdvice9codes = 'm8/alerts_advice_9codes.json';
  static const String m8AlertsDigest = 'm8/alerts_digest.json';
  static const String m8AlertsP0Ack = 'm8/alerts_p0_ack.json';
  static const String m8HandbookPageSleeveB = 'm8/handbook_page_sleeve_b.json';
  static const String m8IncidentTokenExpired = 'm8/incident_token_expired.json';
  static const String m8OnboardingFinish = 'm8/onboarding_finish.json';
  static const String m8OnboardingFreshAdvisory =
      'm8/onboarding_fresh_advisory.json';
  static const String m8OnboardingModePick = 'm8/onboarding_mode_pick.json';
  static const String m8OpsHomeAdviceOpen = 'm8/ops_home_advice_open.json';
  static const String m8OpsHomeAdviceZero = 'm8/ops_home_advice_zero.json';
  static const String m8OpsHomeBlocked = 'm8/ops_home_blocked.json';
  static const String m8OpsHomeNormal = 'm8/ops_home_normal.json';
  static const String m8OpsHomeResumeGap7 = 'm8/ops_home_resume_gap7.json';
  static const String m8OpsRhythmRows = 'm8/ops_rhythm_rows.json';
  static const String m8ReconBoardDiff = 'm8/recon_board_diff.json';
  static const String m8RestartLostPhone = 'm8/restart_lost_phone.json';
  static const String m8WatchdogDelayed = 'm8/watchdog_delayed.json';
  static const String m8WatchdogHoliday = 'm8/watchdog_holiday.json';

  // ── m9/ — 설정·운영 모드 전환 (05) ──
  static const String m9HandoverStates = 'm9/handover_states.json';

  /// 전량 목록 — C-14 시크릿 스캔·C-15 열거값 대조가 이 목록을 돈다.
  static const List<String> all = <String>[
    alerts12,
    depositPlan1,
    depositPlanFunding1,
    holdings6,
    journal30,
    ledgerDiffs4,
    onboardingFresh,
    onboardingReconnect,
    performance24m,
    rebalance6,
    resumeReport1,
    safetyStates,
    m6Advice12,
    m6AdviceBlocked,
    m6AdviceDetailOnhold,
    m6AdviceDetailPartial,
    m6AdviceEmpty,
    m6AdviceExpiredConfirm,
    m6AdviceHandoverCooling,
    m6AdviceNoAction,
    m6AdviceSkipReasons,
    m6AdviceViewer4,
    m6EntryGateNovPass1,
    m6ExternalHoldings2,
    m6FillFormSpec,
    m6FillFormSpecStale,
    m6FillRejectedPrice,
    m6ManualFills8,
    m6SelfReport1,
    m7AftertaxLadder1,
    m7ExecutionGap1,
    m7ExecutionGapCant,
    m7ExecutionGapMixed,
    m7ExecutionGapWont,
    m7LedgerTrust4,
    m7M7Annual2026,
    m7M7AnnualFirstYear,
    m7M7Contrib3sleeve,
    m7M7DdContextDeep,
    m7M7DdContextNormal,
    m7M7DepositPlanDefault,
    m7M7DepositPlanExpired,
    m7M7DepositPlanLimit,
    m7M7DisclosureGate,
    m7M7GoalPathHold,
    m7M7GoalPathOn,
    m7M7GoalPathRealworld,
    m7M7Monthly202608,
    m7M7MonthlyGap,
    m7M7MonthlyPending,
    m7M7NextRebalanceD6,
    m7M7PerfDailyGap,
    m7M7RebalanceDetailBand,
    m7M7ReportArchive18,
    m7M7WithdrawalGeneral,
    m7M7WithdrawalPensionPenalty,
    m7M7WithdrawalShortfall,
    m7RealizedAllocS7,
    m8AlertsAdvice9codes,
    m8AlertsDigest,
    m8AlertsP0Ack,
    m8HandbookPageSleeveB,
    m8IncidentTokenExpired,
    m8OnboardingFinish,
    m8OnboardingFreshAdvisory,
    m8OnboardingModePick,
    m8OpsHomeAdviceOpen,
    m8OpsHomeAdviceZero,
    m8OpsHomeBlocked,
    m8OpsHomeNormal,
    m8OpsHomeResumeGap7,
    m8OpsRhythmRows,
    m8ReconBoardDiff,
    m8RestartLostPhone,
    m8WatchdogDelayed,
    m8WatchdogHoliday,
    m9HandoverStates,
  ];
}
