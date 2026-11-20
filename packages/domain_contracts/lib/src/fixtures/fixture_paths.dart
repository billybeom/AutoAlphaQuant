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

  /// 🔵 v1.4 — 코어 전용(행 = `DepositPlan`) · 화면 미사용. 화면 픽스처는 `m7M7DepositPlan…`
  ///    (행 = `DepositPreviewResult` 래퍼)이다.
  static const String depositPlan1 = 'deposit_plan_1.json';

  /// 🔵 v1.4 — 코어 전용 · 납입 조달 발동(C 방어 자산 매도 초안 + 조달 단계 1).
  static const String depositPlanFunding1 = 'deposit_plan_funding_1.json';

  /// 🔵 v1.8(01 §17) — 평면 창구 `watchHoldings` 의 표본(6행 · pnl 3행 · C-6). 행 == `m6/holdings_overview_pnl`
  ///    의 같은 `holding_id` 행(C-44 ④) · 종목 라벨 = 입금 픽스처 이름(미결 82 보유 몫 · K4).
  static const String holdings6 = 'holdings_6.json';
  static const String journal30 = 'journal_30.json';
  static const String ledgerDiffs4 = 'ledger_diffs_4.json';
  static const String onboardingFresh = 'onboarding_fresh.json';
  static const String onboardingReconnect = 'onboarding_reconnect.json';
  static const String performance24m = 'performance_24m.json';

  /// 🆕 v1.1 — `ConfigRepository.watchRangePresets()` 의 입력. `is_default` 는 정확히 1건.
  static const String rangePresets4 = 'range_presets_4.json';
  static const String rebalance6 = 'rebalance_6.json';
  static const String resumeReport1 = 'resume_report_1.json';
  static const String safetyStates = 'safety_states.json';

  /// 🆕 v1.1 — `ConfigRepository.watchSleeves()` 의 입력(P0S — 새틀라이트 행 없음).
  static const String sleeveCatalog4 = 'sleeve_catalog_4.json';

  // ── m5/ — 🆕 v1.21(01 §30) M5 안전 동작 · 폴더 신설 · 게이트 7 · 서약 3 · 결과 1 · 접수증 1 ──
  //    🆕 v1.25(01 §34) — 킬스위치 화면 7 · 발동 접수증 1 · 게이트 꺼짐 1 · 차단 보드 4(같은 차례 규약).
  //    (파일 이름 바이트 차례 · `all` 도 같은 차례)
  //    🆕 v1.22(01 §31) — 사다리 2 · simToAuto 계획 4 · 위저드 결과 1 · E13 결과 1(같은 차례 규약).
  //    🆕 v1.26(01 §35) — 보드 RECON 1 · 위저드 12 · RECON 결과 1 · 규칙 변경 게이트 5 · 요청 결과 1(같은 차례 규약).

  /// 🆕 v1.25(K154) — `M5-5` 보드 · 막힌 것 0(빈 문장 · 사다리 정상).
  static const String m5BlockBoardClear = 'm5/block_board_clear.json';

  /// 🆕 v1.25 — `M5-5` 보드 · 킬스위치 행(기록 뒤 대기) · COOLDOWN 게이지.
  static const String m5BlockBoardKillActive =
      'm5/block_board_kill_active.json';

  /// 🆕 v1.26 — `M5-5` 보드 · RECON 행 해제 폼(원인 코드 6 · K181) + JOURNAL_MISSING(폼 0).
  static const String m5BlockBoardReconMismatch =
      'm5/block_board_recon_mismatch.json';

  /// 🆕 v1.25(K155) — `M5-5` 보드 · RESUME_INCOMPLETE(→ X2 게이트) + JOURNAL_MISSING.
  static const String m5BlockBoardResumeIncomplete =
      'm5/block_board_resume_incomplete.json';

  /// 🆕 v1.25 — `M5-5` 보드 · 정지 단계 · 재개 결정 링크 · 사다리 stopped.
  static const String m5BlockBoardStopped = 'm5/block_board_stopped.json';

  /// 🆕 v1.22(K65) — `M5-4` 사다리 · 지금 = 정상(글자 = 엔진 `breakerLadderOf` 출력).
  static const String m5BreakerLadderNormal = 'm5/breaker_ladder_normal.json';

  /// 🆕 v1.22 — `M5-4` 사다리 · 지금 = 정지(두 표본 `current` 빼면 바이트 같음 — C-56 ⑤).
  static const String m5BreakerLadderStopped = 'm5/breaker_ladder_stopped.json';

  /// 🆕 v1.22(K56 · K58) — `M5-11` 위저드 동작 결과 20행(fate 3 · 세션 열기 7 · 취소 2 · 확정 8 · 확정 성공 행 0).
  static const String m5HandoverSimToAutoActionResults =
      'm5/handover_sim_to_auto_action_results.json';

  /// 🆕 v1.22(K59) — simToAuto 계획 · 7단계 S7 냉각 중(`SIM_TO_AUTO_COOLING`).
  static const String m5HandoverSimToAutoCooling =
      'm5/handover_sim_to_auto_cooling.json';

  /// 🆕 v1.22 — simToAuto 계획 · 5단계 고르기 전(S5~S7 UNKNOWN · 코드 null).
  static const String m5HandoverSimToAutoFatePending =
      'm5/handover_sim_to_auto_fate_pending.json';

  /// 🆕 v1.22 — simToAuto 계획 · 7단계 전부 통과(확정 가능).
  static const String m5HandoverSimToAutoReady =
      'm5/handover_sim_to_auto_ready.json';

  /// 🆕 v1.22 — simToAuto 계획 · 3단계 실전 키 조회 실패(`SIM_TO_AUTO_LIVE_KEYS_FAILED`).
  static const String m5HandoverSimToAutoS3Blocked =
      'm5/handover_sim_to_auto_s3_blocked.json';

  /// 🆕 v1.26 — `M5-11` 확정 가능(S7 통과 · 확정 + 취소 · 커밋 창 글자 · 머리 OK).
  static const String m5HandoverWizardCommitReady =
      'm5/handover_wizard_commit_ready.json';

  /// 🆕 v1.26 — `M5-11` 확정됨(상태 문장 · 동작 0).
  static const String m5HandoverWizardCommitted =
      'm5/handover_wizard_committed.json';

  /// 🆕 v1.26 — `M5-11` 냉각 중(S7 막힘 WATCH · 취소 1 · 냉각 끝·확정 기한 글자).
  static const String m5HandoverWizardCooling =
      'm5/handover_wizard_cooling.json';

  /// 🆕 v1.26 — `M5-11` 확정 기한 지남(S7 막힘 · S6 다시 시작 1).
  static const String m5HandoverWizardExpired =
      'm5/handover_wizard_expired.json';

  /// 🆕 v1.26 — `M5-11` S5 고르기(동작 2 · 세션 전 · 머리 code = 단계 id).
  static const String m5HandoverWizardFatePending =
      'm5/handover_wizard_fate_pending.json';

  /// 🆕 v1.26 — `M5-11` 확정 가능 + 잠김(모든 동작 0).
  static const String m5HandoverWizardLocked = 'm5/handover_wizard_locked.json';

  /// 🆕 v1.26 — `M5-11` 전제 밖(모의 자동 매매 아님 · 행 0).
  static const String m5HandoverWizardNotApplicable =
      'm5/handover_wizard_not_applicable.json';

  /// 🆕 v1.26 — `M5-11` S3 막힘(S2·S3·S4 링크).
  static const String m5HandoverWizardS3Blocked =
      'm5/handover_wizard_s3_blocked.json';

  /// 🆕 v1.26 — `M5-11` S6 시작(동작 1 · 승인 config 고지).
  static const String m5HandoverWizardStartReady =
      'm5/handover_wizard_start_ready.json';

  /// 🆕 v1.26 — `M5-11` 신뢰 시각 모름(S7 UNKNOWN WATCH · 취소 자리 그대로 — K176).
  static const String m5HandoverWizardTimeUnknown =
      'm5/handover_wizard_time_unknown.json';

  /// 🆕 v1.26 — `M5-11` 체험 미완(S1 막힘 · 체험 카드 · 동작 0).
  static const String m5HandoverWizardTrialIncomplete =
      'm5/handover_wizard_trial_incomplete.json';

  /// 🆕 v1.26 — `M5-11` 커밋 창 막힘(7 통과 · 머리 = 창 라벨 · 확정 0).
  static const String m5HandoverWizardWindowBlocked =
      'm5/handover_wizard_window_blocked.json';

  static const String m5KillChecklistReceipts =
      'm5/kill_checklist_receipts.json';
  static const String m5KillResumeGateConditionUnmet =
      'm5/kill_resume_gate_condition_unmet.json';
  static const String m5KillResumeGateInProgress =
      'm5/kill_resume_gate_in_progress.json';
  static const String m5KillResumeGateLocked =
      'm5/kill_resume_gate_locked.json';
  static const String m5KillResumeGateNotConfirmed =
      'm5/kill_resume_gate_not_confirmed.json';

  /// 🆕 v1.25(K153) — `M5-2` 재개를 마친 뒤(«킬스위치 꺼짐» · 다음·막힘 0).
  static const String m5KillResumeGateOff = 'm5/kill_resume_gate_off.json';

  static const String m5KillResumeGateReady = 'm5/kill_resume_gate_ready.json';
  static const String m5KillResumeGateTimeUnknown =
      'm5/kill_resume_gate_time_unknown.json';
  static const String m5KillResumeGateWaiting =
      'm5/kill_resume_gate_waiting.json';

  /// 🆕 v1.25(K149) — `KILL_SWITCH_ACTIVATE` 접수증 2(폰 EXECUTED · 뷰어 REQUESTED · 거부 0).
  static const String m5KillSwitchActivateReceipts =
      'm5/kill_switch_activate_receipts.json';

  /// 🆕 v1.25(K150) — `M5-1` 켜짐·기록 전 + 잠김(폼 0).
  static const String m5KillSwitchActiveLocked =
      'm5/kill_switch_active_locked.json';

  /// 🆕 v1.25(K146 · K147) — `M5-1` 켜짐·기록 전(취소 보고 3행 · 발동 뒤 기록 폼).
  static const String m5KillSwitchActiveUnrecorded =
      'm5/kill_switch_active_unrecorded.json';

  /// 🆕 v1.25(K151) — `M5-1` 켜짐·기록 전 · 미체결 후보 읽기 실패(행 0 · 실패 머리).
  static const String m5KillSwitchCancelReadFailed =
      'm5/kill_switch_cancel_read_failed.json';

  /// 🆕 v1.25(K150) — `M5-1` 꺼짐 + 잠김(🔴 발동 버튼 남음).
  static const String m5KillSwitchLocked = 'm5/kill_switch_locked.json';

  /// 🆕 v1.25(K146) — `M5-1` 꺼짐(발동 버튼 · 3중 경로).
  static const String m5KillSwitchOff = 'm5/kill_switch_off.json';

  /// 🆕 v1.25 — `M5-1` 기록 뒤 · 해제 가능(게이트 링크).
  static const String m5KillSwitchRecordedReady =
      'm5/kill_switch_recorded_ready.json';

  /// 🆕 v1.25 — `M5-1` 기록 뒤 · 48h 대기(ETA · 게이트 링크).
  static const String m5KillSwitchRecordedWaiting =
      'm5/kill_switch_recorded_waiting.json';

  static const String m5PledgeEditWindow = 'm5/pledge_edit_window.json';
  static const String m5PledgeNotWritten = 'm5/pledge_not_written.json';
  static const String m5PledgeWritten = 'm5/pledge_written.json';

  /// 🆕 v1.26 — `runReconClear` 결과 6행(성공 · `ReconClearResultCodes` 3 · 공용 2 · K182).
  static const String m5ReconClearResults = 'm5/recon_clear_results.json';

  /// 🆕 v1.26 — `M5-9` 냉각 끝(승인 폼 · 취소).
  static const String m5RuleChangeGateApprovable =
      'm5/rule_change_gate_approvable.json';

  /// 🆕 v1.26 — `M5-9` 첫 승인 요청 냉각 중(승인 0 · 취소 1).
  static const String m5RuleChangeGateCooling =
      'm5/rule_change_gate_cooling.json';

  /// 🆕 v1.26 — `M5-9` 승인된 설정 · 후보 0 · 큐 0(빈 문장).
  static const String m5RuleChangeGateEmpty = 'm5/rule_change_gate_empty.json';

  /// 🆕 v1.26 — `M5-9` 승인 config 0 · 후보 1(첫 승인 요청).
  static const String m5RuleChangeGateFirstCandidate =
      'm5/rule_change_gate_first_candidate.json';

  /// 🆕 v1.26 — `M5-9` 잠김(후보 0 · 승인·취소 0).
  static const String m5RuleChangeGateLocked =
      'm5/rule_change_gate_locked.json';

  /// 🆕 v1.26 — `runRuleChangeRequest` 결과 7행(성공 · 사전 3 · 공용 2 · 생체 · K178).
  static const String m5RuleChangeRequestResults =
      'm5/rule_change_request_results.json';

  static const String m5SafetyActionResults = 'm5/safety_action_results.json';

  /// 🆕 v1.22(K52~K55) — E13 나머지 동작 8 결과 31행(`SafetyActionResult` · RECON 해제 = 생체 코드만 · K55).
  static const String m5SafetyActionResultsE13 =
      'm5/safety_action_results_e13.json';

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

  /// 🆕 v1.12(01 §21 · K41) — 배치 결측(요약 `stale_reason_code`·`stale_label`) — `advice_12` 의 OPEN 2행 · 행 `actions` =
  ///    RECORD 만(엔진이 줄여 보낸다 · `A-3` 기록 경로는 살아 있다) · 요약 = `summary` 형제 키 — 위젯 테스트(골든 아님).
  static const String m6AdviceStale = 'm6/advice_stale.json';

  /// 🆕 v1.12(K40) — `A-2` 「기록된 체결」(`fillsOfAdvice('ad_0005')`) 1행 · ORIGINAL 8주 — `advice_detail_partial` ad_0005 와
  ///    짝(그 행 글자 그대로 · K23 예외) · 뷰어 판 = 빈 목록(엔진) — 골든 `a2_partial`.
  static const String m6AdviceFillsAd0005 = 'm6/advice_fills_ad0005.json';

  /// 🆕 v1.12(K14 ⓐ) — `DEFER_ADVICE_CONFIRM` 접수증 3행(REQUESTED · EXECUTED · REJECTED `DEFER_ALREADY_USED`) ·
  ///    한 명령의 갈래(행을 `state` 로 골라 쓴다) — 만료 확인 카드 「내일 다시」 위젯 테스트.
  static const String m6AdviceDeferReceipts3 =
      'm6/advice_defer_receipts_3.json';

  /// 🆕 v1.12 — `SKIP_ADVICE` 접수증 5행(REQUESTED · EXECUTED · REJECTED `LEASE_EXPIRED` · REJECTED `ADVICE_NOT_OPEN` ·
  ///    HELD_FOR_INTEGRITY) — `A-4` 위젯 테스트.
  static const String m6AdviceSkipReceipts5 = 'm6/advice_skip_receipts_5.json';

  /// 🆕 v1.8(01 §17 · R4 선행) — `H6-3` 슬리브·비중(`HoldingsRepository.watchAllocation` · 행 1 = `SleeveAllocationVm`).
  ///    행 = A → POT(A 하위) → B → C → 현금 대기 · 전부 회계 기준 · 🔴 밴드 행 = **B 만**(K27 — A·C·POT·CASH =
  ///    `band_note_text`). 밴드 내 = 골든 `h63_in_band`·`h63_pot_under_a`(A 펼침 = `engine_column_note`).
  static const String m6AllocationInBand = 'm6/allocation_in_band.json';

  /// 🆕 v1.8 — `in_band` 에서 B 만 밴드 이탈(«밴드 이탈 — 다음 배치에서 리밸런싱 대상» · 게이지 실측 > 상단) — 골든 `h63_out_of_band`.
  static const String m6AllocationOutOfBand = 'm6/allocation_out_of_band.json';

  /// 🆕 v1.8 — B 경계 근접 + A 상태 칩 1(`F1_ENTRY_DEFER` · 핸드북 링크 · K13) — 골든 `h63_tranche_progress`.
  static const String m6AllocationTrancheProgress =
      'm6/allocation_tranche_progress.json';

  /// 🆕 v1.8 — B 투자분 트랜치 1/3 · 파킹 큼(밴드 내 · «미달이 아닙니다» — 경고색 아님) — 테스트(골든 아님).
  static const String m6AllocationParkingLarge =
      'm6/allocation_parking_large.json';

  /// 🆕 v1.8 — `LEDGER_INTEGRITY` 가림판: 전 행 금액·%·트랜치·밴드 글자 «숨김» · 기하·`sleeve_weight` 부재 —
  ///    `holdings_overview_integrity` 카드 머리의 짝(C-44 ③⑥).
  static const String m6AllocationIntegrity = 'm6/allocation_integrity.json';

  /// 🆕 v1.8 — `RECON_MISMATCH` 판: B 행 금액·% 글자 끝 «?» · 기하·`band_state` 는 `in_band` 그대로 —
  ///    `holdings_overview_recon` 카드 머리의 짝(C-44 ③⑥).
  static const String m6AllocationRecon = 'm6/allocation_recon.json';

  /// 🆕 v1.8 — 빈 배분(`rows: []` + 엔진 문장 · «없음» 전용 — K26) — 테스트.
  static const String m6AllocationEmpty = 'm6/allocation_empty.json';

  /// 🆕 v1.7(01 §16 · §8 미결 46) — `J-4` 사후 blind 리뷰. 대기 목록(`watchBlindReviewQueue` 봉투) 3행 =
  ///    이탈 결정 중 저널이 작성된 셋 · 오래된 결정부터(K4): `d_20260811_c_28`(매수 · 메모 있음) → `d_mf_0002`(매수 ·
  ///    본문 == `journal_read_no_note`) → `d_mf_0004`(매도 · 메모 있음). 🔴 `JOURNAL_MISSING` 이 서 있는 결정
  ///    (`d_20260810_b_27`)은 큐에 없다(K3 ⓓ 확정 2026-10-20). 행 `result` 키 부재 · `journal_badges_2`
  ///    «리뷰 대기 3건» == 행 수(C-43 ⑤).
  static const String m6BlindReviewQueue3 = 'm6/blind_review_queue_3.json';

  /// 🆕 v1.7 — 빈 큐(`NO_DATA` + «리뷰할 결정이 없습니다») — 골든 `j4_empty` · 모의투자(DRY_RUN) 기간의 장면도 이것(K24).
  static const String m6BlindReviewQueueEmpty =
      'm6/blind_review_queue_empty.json';

  /// 🆕 v1.7 — 카드 1건(`watchBlindReviewCard`) 첫 값 = 큐 행 0 **JSON 그대로**(채점 전 · `result` 키 부재).
  static const String m6BlindReviewCardBefore =
      'm6/blind_review_card_before.json';

  /// 🆕 v1.7 — 같은 카드의 채점 집행 뒤 값 = before + `result`(청산 · 수익률·보유기간·방향 · 금액 0 · K6) — 골든 `j4_after_reveal`.
  ///    `result` 밖 필드 == before(C-43 ④).
  static const String m6BlindReviewCardRevealed =
      'm6/blind_review_card_revealed.json';

  /// 🆕 v1.7 — 큐 행 1(`d_mf_0002`) + `result`(«미청산 — 결과 미확정») — 골든 `j4_after_reveal_open`.
  static const String m6BlindReviewCardRevealedOpen =
      'm6/blind_review_card_revealed_open.json';

  /// 🆕 v1.7 — 점수 제출 결과(`CommandReceipt` · `BLIND_REVIEW_SCORE`) 6행: REQUESTED·HELD_FOR_INTEGRITY·EXECUTED·
  ///    EXPIRED·REJECTED(`BLIND_REVIEW_ANSWERS_INVALID`)·REJECTED(`BLIND_REVIEW_ALREADY_SCORED`). 한 명령(같은
  ///    `command_id`)의 갈래이며 테스트는 행을 골라 쓴다(`copyWith(state:)`·생성자 0).
  static const String m6BlindReviewReceipts6 =
      'm6/blind_review_receipts_6.json';

  // 🆕 v1.1 — `J-2` 거래 상세(`JournalRepository.watchDecisionDetail`) 6갈래.
  static const String m6DecisionDetailAmended =
      'm6/decision_detail_amended.json';
  static const String m6DecisionDetailFull = 'm6/decision_detail_full.json';

  /// 🆕 v1.2(R2b 선행 · 01 §12-2) — `J-2 journalLink` 목적지 2갈래. `decision_detail_amended`
  ///    사본에서 `journal_state_label`·`journal_link` 두 키만 다르다(작성됨 → `journal/read` ·
  ///    미작성 → `journal/draft`).
  static const String m6DecisionDetailJournalDraftLink =
      'm6/decision_detail_journal_draft_link.json';
  static const String m6DecisionDetailJournalWritten =
      'm6/decision_detail_journal_written.json';
  static const String m6DecisionDetailPartial =
      'm6/decision_detail_partial.json';
  static const String m6DecisionDetailReevaluatedChild =
      'm6/decision_detail_reevaluated_child.json';
  static const String m6DecisionDetailRejectedSaf309 =
      'm6/decision_detail_rejected_saf309.json';
  static const String m6DecisionDetailUnknown =
      'm6/decision_detail_unknown.json';

  /// 🆕 v1.2(R2b 선행 · 01 §12-1) — 기기 로컬 입력 초안(`DraftRecord`).
  ///    🔴 `draft_records_j3` 는 **행 순서가 의미**다(0 작성 중 · 1 완성 · 2 제출됨 · 3 폐기 규칙 ·
  ///    4 메모 필수 규칙 — fixtures/README.md 표). 테스트는 **한 행씩** 시드한다. `draft_records_x7` 는
  ///    X7 모양 고정용.
  static const String m6DraftRecordsJ3 = 'm6/draft_records_j3.json';
  static const String m6DraftRecordsX7 = 'm6/draft_records_x7.json';
  static const String m6EntryGateNovPass1 = 'm6/entry_gate_nov_pass_1.json';
  static const String m6ExternalHoldings2 = 'm6/external_holdings_2.json';
  static const String m6FillFormSpec = 'm6/fill_form_spec.json';
  static const String m6FillFormSpecStale = 'm6/fill_form_spec_stale.json';
  static const String m6FillRejectedPrice = 'm6/fill_rejected_price.json';

  /// 🆕 v1.12(K21) — `fill_form_spec` + `blocked_text`(제출 **부재** + 문장) + `banner_text`(`LEDGER_INTEGRITY` 격리 고지) —
  ///    `A-3`·`A-4` 위젯 테스트(골든 아님).
  static const String m6FillFormSpecBlocked = 'm6/fill_form_spec_blocked.json';

  /// 🆕 v1.12(K25 · 02 §5-2 모의 데이터) — `L-2` 정정 이력 4행(자동 재동기화 2 + 정본 정정 1 + 그 정정의 정정 1 ·
  ///    순서 = 엔진 · 정정의 정정은 원본 **바로 뒤** · 원본 `superseded_label`) — 골든 `l2_chain_two_repairs`.
  static const String m6LedgerRepairs4 = 'm6/ledger_repairs_4.json';

  /// 🆕 v1.12 — `L-2` 빈 이력(«정정 이력이 없습니다» · 정상) — 골든 `l2_empty`.
  static const String m6LedgerRepairsEmpty = 'm6/ledger_repairs_empty.json';

  /// 🆕 v1.12(K26) — `L-1` 현금 축 관측 1행(`CANON_BROKER`·`CASH`·`OBSERVATIONAL` · 조치 링크 null · 허용 오차 값 0) —
  ///    골든 `l1_cash_observe`(`ledger_diffs_4` 에 현금 축 행이 없다).
  static const String m6LedgerDiffsCashObserve =
      'm6/ledger_diffs_cash_observe.json';

  /// 🆕 v1.12(K4 · K20) — `RECORD_MANUAL_FILL` 접수증 7행(REQUESTED · EXECUTED · REJECTED `DUPLICATE_SUSPECTED` +
  ///    `retry_code` DUPLICATE_ACK · REJECTED `INPUT_INVALID` · HELD_FOR_INTEGRITY · PENDING_LEASE_CONFIRM · STALE_CONTEXT) ·
  ///    🔴 `LEASE_EXPIRED` 0(사실 추가는 강등 접수) — `A-3` 위젯 테스트.
  static const String m6ManualFillReceipts7 = 'm6/manual_fill_receipts_7.json';

  /// 🆕 v1.8(01 §17 · R4 선행) — `H6-2` 종목 상세(`watchHoldingDetail(holdingId)` · 행 1 = `HoldingDetailVm`).
  ///    `holding` == `holdings_overview_*` 의 같은 `holding_id` 행(C-44 ④). 손절선 행 = A `069500` 의 TIER_1B 1행 —
  ///    🔴 **보존 경로 표본**(P0S 정상 장면 아님 · 골든 아님 · K16 ⓓ) · `recent_entries` = `journal_30` 행 JSON 그대로.
  static const String m6HoldingDetailWithStops =
      'm6/holding_detail_with_stops.json';

  /// 🆕 v1.8 — B `133690` · 손절선 0행 + «개별 손절선을 쓰지 않습니다» · 최근 체결 0행 + 문장 — 골든 `h62_etf_no_stop`.
  static const String m6HoldingDetailNoStop = 'm6/holding_detail_no_stop.json';

  /// 🆕 v1.8 — `no_stop` + `holding.pnl`(`holdings_overview_pnl` 의 같은 행) — 골든 `h62_pnl_expanded`(K16 ⓑ).
  static const String m6HoldingDetailPnl = 'm6/holding_detail_pnl.json';

  /// 🆕 v1.8 — `no_stop` 의 가림판(`holding` == `holdings_overview_recon` 의 같은 행) — 골든 `h62_recon_mismatch`.
  static const String m6HoldingDetailRecon = 'm6/holding_detail_recon.json';

  /// 🆕 v1.8 — `with_stops` 의 가림판(`holding` == `holdings_overview_integrity` A 행 · 손절선 글자 «숨김» ·
  ///    `recent_entries` = `journal_masked_integrity` 의 같은 보유 행) — 골든 `h62_integrity`(K16 ⓓ).
  static const String m6HoldingDetailIntegrity =
      'm6/holding_detail_integrity.json';

  /// 🆕 v1.8(01 §17 · R4 선행) — `H6-1` 보유현황(`watchHoldingsOverview` · 행 1 = `HoldingsOverviewVm`).
  ///    카드 3(A·B·C = `sleeve_catalog_4` 의 최상위 행 순) · POT 2행 = A 카드 맨 끝(`sub_book_label` · K17) ·
  ///    B `133690` 행 «반영 대기 +12주» · 시스템 밖 섹션 = `external_holdings_2` 행 · 카드 머리 = `allocation_in_band`
  ///    의 같은 슬리브 행 — 골든 `h61_normal`.
  static const String m6HoldingsOverviewNormal =
      'm6/holdings_overview_normal.json';

  /// 🆕 v1.8 — `RECON_MISMATCH` 대상 1행(B `133690`) 글자 끝 «?» · B 카드 머리 = `allocation_recon` — 골든 `h61_recon_mismatch`.
  static const String m6HoldingsOverviewRecon =
      'm6/holdings_overview_recon.json';

  /// 🆕 v1.8 — `LEDGER_INTEGRITY`: 관리 대상 행 수량·매수가·비중 «숨김» · 반영 대기 칩 부재 · 카드 머리 =
  ///    `allocation_integrity` · 🔵 시스템 밖 수량은 그대로(사람 입력 · K14) — 골든 `h61_integrity`.
  static const String m6HoldingsOverviewIntegrity =
      'm6/holdings_overview_integrity.json';

  /// 🆕 v1.8 — 카드 0(`cards: []` + 엔진 문장 · 섹션·토글·「비중 보기」 부재) — 골든 `h61_empty`.
  static const String m6HoldingsOverviewEmpty =
      'm6/holdings_overview_empty.json';

  /// 🆕 v1.8 — `includePnl: true` 의 값: `normal` + 3행 `pnl`(`holdings_6` 의 pnl 3행과 같은 값 · C-44 ④) — 골든 `h61_pnl_expanded`.
  static const String m6HoldingsOverviewPnl = 'm6/holdings_overview_pnl.json';

  /// 🆕 v1.8 — 뷰어(iOS) 판: `normal` 에서 `pnl_toggle_label`·`external` 없음(K15 · K14 ⓑ) — 테스트.
  static const String m6HoldingsOverviewViewer =
      'm6/holdings_overview_viewer.json';

  /// 🆕 2026-09-17(C4 · R1-Bob-J1) — `J-1` 빈 상태 골든 `j1_empty` 의 입력.
  ///    `journal_30.json` 의 0행 슬라이스는 `empty_label` 이 null 이라 화면이 그릴 것이 없다 —
  ///    「없음」(NO_DATA)은 문구를 실어야 하므로(계약 3조 ③) M2 가 파일로 준다(02 §3-1 · §6).
  static const String m6JournalEmpty = 'm6/journal_empty.json';

  /// 🆕 v1.17(01 §26 · 엔진 D11 · K26) — `JournalStatus.expired` 1행(일 마감 실효 · 칩 `DAY_END_EXPIRED` · R31 꼴 `broker_order_no`).
  static const String m6JournalExpired1 = 'm6/journal_expired_1.json';

  // 🆕 v1.1 — `J-1` 배지·필터 · `J-3` 폼 스펙 · 가림(LEDGER_INTEGRITY) 일지.
  static const String m6JournalBadges2 = 'm6/journal_badges_2.json';

  /// 🆕 v1.1 R2 준비(2026-09-23) — `J-3` 제출 결과(`CommandReceipt` · `JOURNAL_DRAFT`) 5상태:
  ///    REQUESTED·EXECUTED·REJECTED·EXPIRED·HELD_FOR_INTEGRITY. 한 명령(같은 `command_id`)의
  ///    갈래이며 테스트는 `state` 로 골라 쓴다. 🔴 사유까지 실린 문구는 `state_label` 하나다.
  static const String m6JournalDraftReceipts5 =
      'm6/journal_draft_receipts_5.json';
  static const String m6JournalDraftSpecDiscretion =
      'm6/journal_draft_spec_discretion.json';
  static const String m6JournalDraftSpecReconClear =
      'm6/journal_draft_spec_recon_clear.json';
  static const String m6JournalFilterCatalog = 'm6/journal_filter_catalog.json';
  static const String m6JournalMaskedIntegrity =
      'm6/journal_masked_integrity.json';

  /// 🆕 v1.5(01 §15-3) — `J-1` 회차 조건의 범위 설명(`JournalRebalanceScope` · 회차 칩 글자 + 씨앗 기간).
  ///    회차 = `journal_30` 에서 일지 행이 묶인 유일한 회차 · 기간은 그 행 전부를 덮는다(C-40 ⑨).
  static const String m6JournalRebalanceScope1 =
      'm6/journal_rebalance_scope_1.json';

  /// 🆕 v1.5 — 모르는 회차로 연 `J-1` 봉투(0행 + 엔진 문장 · `journal_empty` 와 다른 문장 — C-40 ⑦).
  static const String m6JournalRebalanceUnknown =
      'm6/journal_rebalance_unknown.json';

  /// 🆕 v1.2(R2b 선행 · 01 §12-2) — `J-3R` 사전 저널 읽기(`DecisionJournalVm`) 3갈래:
  ///    작성됨 · 작성됨(메모·결정 링크 부재) · 미작성(`body` null — 2행: 0 = `b_27` · 1 = `a_31`,
  ///    작성됨과 같은 결정의 «미작성» = `J-3` executed 직후 전환 표본).
  static const String m6JournalReadNoNote = 'm6/journal_read_no_note.json';
  static const String m6JournalReadNotWritten =
      'm6/journal_read_not_written.json';
  static const String m6JournalReadWritten = 'm6/journal_read_written.json';

  /// 🆕 v1.22(01 §31 · K66) — `J-1` 모의 가상 체결 브로커 거부 1행(`BrokerRawCodes.simInvalidOrder` 칩 · `fill_origin` SIMULATED ·
  ///    제출 거부 = 주문번호 0 · 가격 칸 = J-1 꼴 · 소비 = 화면 판 1.23.0+).
  static const String m6JournalSimBrokerReject =
      'm6/journal_sim_broker_reject.json';
  static const String m6ManualFills8 = 'm6/manual_fills_8.json';

  /// 🔵 v1.12(01 §21 · K8) — **꼴 교체**: `L-3` 열린 실사 세션(`SelfReportSession` 12키 · 2026-08 · 연금저축 ·
  ///    SPEC 유니버스 4) — 옛 «`SelfReportBalance` 모양 + 형제 키 `trust`» 는 지웠다(등록부 미매핑 → 바인딩) — 골든 `l3_session`.
  static const String m6SelfReport1 = 'm6/self_report_1.json';

  /// 🆕 v1.12 — `L-3` 결과(`result.diffs` 1 = `CANON_SELF_REPORT` · `resolve_link` · `next_account_link`) — 골든 `l3_diff_result`.
  static const String m6SelfReportDiffResult =
      'm6/self_report_diff_result.json';

  /// 🆕 v1.12(K9) — `L-3` 세션 닫힘(`session_closed_text` · 폼 부재) — 위젯 테스트.
  static const String m6SelfReportSessionClosed =
      'm6/self_report_session_closed.json';

  /// 🆕 v1.12 — `SELF_REPORT_BALANCE` 접수증 5행(REQUESTED · EXECUTED · REJECTED `SELF_REPORT_OUTSIDE_SESSION` ·
  ///    REJECTED `INPUT_INVALID` · HELD_FOR_INTEGRITY) — `L-3` 위젯 테스트.
  static const String m6SelfReportReceipts5 = 'm6/self_report_receipts_5.json';

  /// 🆕 v1.12(N12) — `a1_blocked` 의 안전 배너 입력(`journalSafetyStateProvider`) — `safety_states` rows[1] 꼴(ALERT) +
  ///    `active_flags` = `advice_blocked` 의 형제 키 블록 그대로(`ADVICE_LEDGER_UNVERIFIED`).
  static const String m6SafetyAdviceBlocked = 'm6/safety_advice_blocked.json';

  // 🆕 v1.1 — `J-5` UNKNOWN 해소 보드.
  static const String m6UnknownBoard2 = 'm6/unknown_board_2.json';
  static const String m6UnknownBoardEmpty = 'm6/unknown_board_empty.json';

  // ── m7/ — 성과·리밸런싱·플래너·세후·이행 갭 (03 §15) ──
  static const String m7AftertaxLadder1 = 'm7/aftertax_ladder_1.json';
  // 🆕 v1.6(R12 선행 · 01 §15-4) — 행 = `ExecutionGapResult` 래퍼(report | 빈·해당없음 문장 ·
  //    C-41 ⑧). 기존 4벌(`_1`·`cant`·`mixed`·`wont`)은 `{report, as_of}` 로 재생성.
  static const String m7ExecutionGap1 = 'm7/execution_gap_1.json';
  static const String m7ExecutionGapCant = 'm7/execution_gap_cant.json';

  /// 🆕 v1.6 — 안내 0건(`NO_DATA` + 엔진 문장 · 골든 `s710_empty`).
  static const String m7ExecutionGapEmpty = 'm7/execution_gap_empty.json';

  /// 🆕 v1.6 — RECON_MISMATCH 가림(줄 안 «?» · 게이지 부재 · 골든 `s710_masked_recon`).
  static const String m7ExecutionGapMaskedRecon =
      'm7/execution_gap_masked_recon.json';
  static const String m7ExecutionGapMixed = 'm7/execution_gap_mixed.json';

  /// 🆕 v1.6 — 자동 매매 구간(`NOT_APPLICABLE` + 엔진 문장 · 골든 `s710_not_applicable`).
  static const String m7ExecutionGapNotApplicable =
      'm7/execution_gap_not_applicable.json';
  static const String m7ExecutionGapWont = 'm7/execution_gap_wont.json';
  static const String m7LedgerTrust4 = 'm7/ledger_trust_4.json';

  /// 🆕 v1.12(K45) — `SELF_AUDIT_DUE` 시기의 신뢰 배지 1행(차단색 아님 · `action_deep_link` = `L-3` 그 달·그 계좌) —
  ///    R13b `h01_self_audit_due`(`safety_states` rows[1] 와 짝).
  static const String m7LedgerTrustSelfAuditDue =
      'm7/ledger_trust_self_audit_due.json';
  static const String m7M7Annual2026 = 'm7/m7_annual_2026.json';
  static const String m7M7AnnualFirstYear = 'm7/m7_annual_first_year.json';

  /// 🆕 v1.6 — 창 밖(2025 · CLOSED — 기본 연도 규칙 표본 · 골든 `s77_offwindow`).
  static const String m7M7AnnualOffwindow = 'm7/m7_annual_offwindow.json';
  static const String m7M7Contrib3sleeve = 'm7/m7_contrib_3sleeve.json';

  /// 🆕 v1.1(§8 미결 45) — 산출 불가 슬리브 1행(`unavailable_label`).
  static const String m7M7ContribPartial = 'm7/m7_contrib_partial.json';
  static const String m7M7DdContextDeep = 'm7/m7_dd_context_deep.json';
  static const String m7M7DdContextNormal = 'm7/m7_dd_context_normal.json';
  // 🆕 v1.4(R11 선행 · 01 §14) — 입금 미리보기(`S7-4`). 행 = `DepositPreviewResult` 래퍼
  //    (plan | input_rejected_text | blocked_text 중 정확히 하나 · C-38 ①).
  /// 차단 2행 — 0 `blocked_text` 만(버튼 부재) · 1 `blocked_text` + `blocked_action`(재개 리포트).
  static const String m7M7DepositPlanBlocked =
      'm7/m7_deposit_plan_blocked.json';

  /// 정상 — 연금 라우팅 · 잔여 = 원화 현금 대기 · 한도 카드(제안·조달 안내 없음).
  static const String m7M7DepositPlanDefault =
      'm7/m7_deposit_plan_default.json';

  /// 만료 — `register_blocked_text`(등록 부재) · 봉투·행 기준일 2026-08-28.
  static const String m7M7DepositPlanExpired =
      'm7/m7_deposit_plan_expired.json';

  /// 납입 조달 발동 + `register_blocked_text`(브로커 대조 미완 — 등록만 불가) 동시 표본.
  static const String m7M7DepositPlanFunding =
      'm7/m7_deposit_plan_funding.json';

  /// 입력 거부 — `input_rejected_text` 만.
  static const String m7M7DepositPlanInputRejected =
      'm7/m7_deposit_plan_input_rejected.json';

  /// 연 합산 납입한도 소진 — B 행 없음 · 주문 초안 빈 목록 + `orders_empty_text` · 경고 1.
  static const String m7M7DepositPlanLimit = 'm7/m7_deposit_plan_limit.json';

  /// 실입금 등록 `CommandReceipt` 5행 — 🔴 **한 명령의 갈래**(행 순서 = 뜻):
  /// 0 `REQUESTED` · 1 `EXECUTED` · 2 `EXPIRED` · 3 `HELD_FOR_INTEGRITY` ·
  /// 4 `REJECTED`(`DEPOSIT_PLAN_EXPIRED`). 🆕 v1.11 — 구 `_4` 에 거부 행을 더해 개명(01 §20).
  static const String m7M7DepositRegisterReceipts5 =
      'm7/m7_deposit_register_receipts_5.json';
  static const String m7M7DisclosureGate = 'm7/m7_disclosure_gate.json';

  // 🆕 v1.3(R10 선행 · 01 §13-5·§13-6) — `S7-2G` 게이트 3갈래 + 열람 기록 접수증.
  /// 닫힌 게이트 — `gate_open: false` · `route`·`friction_line` 키 없음 · `headline` = 닫힌 까닭.
  static const String m7M7DisclosureGateClosed =
      'm7/m7_disclosure_gate_closed.json';

  /// 이번 달 첫 열람 — `friction_line` 키 없음(그 줄이 없다).
  static const String m7M7DisclosureGateFirst =
      'm7/m7_disclosure_gate_first.json';

  /// 잦은 열람 — `friction_line` 있음.
  static const String m7M7DisclosureGateFrequent =
      'm7/m7_disclosure_gate_frequent.json';

  /// 열람 기록 `CommandReceipt` 4행 — 🔴 **한 명령의 갈래**(행 순서 = 뜻):
  /// 0 `REQUESTED` · 1 `EXECUTED` · 2 `EXPIRED` · 3 `HELD_FOR_INTEGRITY`.
  static const String m7M7DisclosureViewReceipts4 =
      'm7/m7_disclosure_view_receipts_4.json';
  // 🔵 v1.4 — 목표 경로(`S7-9` · `GoalPathVm`) 4갈래 · 생성 스크립트 `tool/gen_r11_fixtures.py`.
  /// 판정 유보 — `chart_unavailable_label` + 네 목록 빈 목록.
  static const String m7M7GoalPathHold = 'm7/m7_goal_path_hold.json';

  /// 🆕 v1.4 — 이탈 · `deviation_text` 있음.
  static const String m7M7GoalPathOff = 'm7/m7_goal_path_off.json';

  /// 유지.
  static const String m7M7GoalPathOn = 'm7/m7_goal_path_on.json';

  /// 실전 조건 문장(금액 없이) · 갭 1(`UNAVAILABLE` 띠 · 실제선 결측 2점).
  static const String m7M7GoalPathRealworld = 'm7/m7_goal_path_realworld.json';
  static const String m7M7Monthly202608 = 'm7/m7_monthly_2026_08.json';
  static const String m7M7MonthlyGap = 'm7/m7_monthly_gap.json';

  // 🆕 v1.1(§8 미결 42) — 엔진 읽기 경로가 **가려서 준** 월간 리포트 2갈래.
  static const String m7M7MonthlyMaskedIntegrity =
      'm7/m7_monthly_masked_integrity.json';
  static const String m7M7MonthlyMaskedRecon =
      'm7/m7_monthly_masked_recon.json';
  static const String m7M7MonthlyPending = 'm7/m7_monthly_pending.json';

  /// 🆕 v1.6 개명(구 `m7NextRebalanceD6`) — «2026년 9월 1일 · D-1» 카운트다운(골든 `s76c_countdown`).
  static const String m7M7NextRebalanceCountdown =
      'm7/m7_next_rebalance_countdown.json';

  /// 🆕 v1.6 — 예정 없음(`empty_label` 만 · 골든 `s76c_none`).
  static const String m7M7NextRebalanceNone = 'm7/m7_next_rebalance_none.json';
  static const String m7M7PerfDailyGap = 'm7/m7_perf_daily_gap.json';

  // 🆕 v1.3(R10 선행 · 01 §13-1·§13-3) — `S7-2` 성과 시리즈 6갈래.
  /// 일간 · `MANUAL_EXECUTED` 구간(결측 없음 — 구간 안에서도 선이 이어진다).
  static const String m7M7PerfDailyManual = 'm7/m7_perf_daily_manual.json';

  /// 차단 가림 — `points` 빈 목록 + `unavailable_label`(`safety_states` 행 4 와 짝).
  static const String m7M7PerfMaskedIntegrity =
      'm7/m7_perf_masked_integrity.json';

  /// 월간 · **비누적**(월별) · 음수 · 기준선이 가운데 · 벤치마크 있음.
  static const String m7M7PerfMonthlyPeriod = 'm7/m7_perf_monthly_period.json';

  /// 월간 · 누적 · 앞 3점 `SIM_EXCLUDED`(모의 — 합산 제외).
  static const String m7M7PerfMonthlySimSplit =
      'm7/m7_perf_monthly_sim_split.json';

  /// 불가 — 기록이 비어 `points` 빈 목록 + `unavailable_label`.
  static const String m7M7PerfUnavailableGap =
      'm7/m7_perf_unavailable_gap.json';

  /// 연간 · 누적 · 3점(마지막 해는 8월까지).
  static const String m7M7PerfYearly = 'm7/m7_perf_yearly.json';
  static const String m7M7RebalanceDetailBand =
      'm7/m7_rebalance_detail_band.json';

  /// 🆕 v1.5(01 §15-3) — band 의 거울(같은 회차) · 버튼 글자만 advisory 갈래 낱말(03 §11-d 치환 ·
  ///    골든 `s76b_advisory`). 🔵 이 표본이 advisory 임을 말하는 것은 **라벨 글자뿐**이다.
  static const String m7M7RebalanceDetailAdvisory =
      'm7/m7_rebalance_detail_advisory.json';

  /// 🆕 v1.5 — `S7-6a` 빈 타임라인(0행 + 엔진 문장 · 골든 `s76a_empty`).
  static const String m7M7RebalanceEmpty = 'm7/m7_rebalance_empty.json';
  // 🆕 v1.6(R12 선행 · 01 §15-4) — 리밸런싱 미리보기(`S7-6c`). 행 = `RebalancePreviewResult` 래퍼
  //    (preview | blocked_text 중 정확히 하나 · C-41 ①).
  /// 차단 2행 — 0 `blocked_text` 만(버튼 부재 · 골든 입력) · 1 `blocked_text` + `blocked_action`
  /// (재개 리포트 · 위젯 테스트 전용).
  static const String m7M7RebalancePreviewBlocked =
      'm7/m7_rebalance_preview_blocked.json';

  /// 정상 — 초안 2행 · 비용 · 고지(골든 `s76c_preview`).
  static const String m7M7RebalancePreviewDefault =
      'm7/m7_rebalance_preview_default.json';

  /// 빈 초안 — `order_drafts` 빈 목록 + `orders_empty_text` · 경고 1(골든 `s76c_draft_empty`).
  static const String m7M7RebalancePreviewInBand =
      'm7/m7_rebalance_preview_in_band.json';

  /// 🆕 v1.6 — `S7-6a` 모의투자 회차 2행(행 `mode` SIM · 배지 2 · 머리글 1 · 봉투 LIVE · 골든 `s76a_sim`).
  static const String m7M7RebalanceSim = 'm7/m7_rebalance_sim.json';
  static const String m7M7ReportArchive18 = 'm7/m7_report_archive_18.json';

  /// 🆕 v1.3 — `S7-1b` 빈 아카이브(`rows` 0 + VM `empty_label`).
  static const String m7M7ReportArchiveEmpty =
      'm7/m7_report_archive_empty.json';
  static const String m7M7WithdrawalGeneral = 'm7/m7_withdrawal_general.json';
  static const String m7M7WithdrawalPensionPenalty =
      'm7/m7_withdrawal_pension_penalty.json';
  static const String m7M7WithdrawalShortfall =
      'm7/m7_withdrawal_shortfall.json';
  static const String m7RealizedAllocS7 = 'm7/realized_alloc_S7.json';

  // ── m8/ — 셸·운영 홈·알림·온보딩 (04 §10) ──
  /// 🆕 v1.15(01 §24 · K12) — `ALERT_ACK` 접수증 3갈래(REQUESTED · EXECUTED · REJECTED `INPUT_INVALID`) — R14a 확인 조각.
  static const String m8AlertAckReceipts3 = 'm8/alert_ack_receipts_3.json';

  /// 🆕 v1.15(K10) — 알림 센터(`AlertCenterVm`) 5벌(digest · empty · p0_ack · p0_ack_reordered · p0_only).
  static const String m8AlertCenterDigest = 'm8/alert_center_digest.json';
  static const String m8AlertCenterEmpty = 'm8/alert_center_empty.json';
  static const String m8AlertCenterP0Ack = 'm8/alert_center_p0_ack.json';
  static const String m8AlertCenterP0AckReordered =
      'm8/alert_center_p0_ack_reordered.json';
  static const String m8AlertCenterP0Only = 'm8/alert_center_p0_only.json';

  /// 🆕 v1.15(K11) — 알림 상세(`AlertDetailVm`) 3벌(full · missing · no_link).
  static const String m8AlertDetailFull = 'm8/alert_detail_full.json';
  static const String m8AlertDetailMissing = 'm8/alert_detail_missing.json';
  static const String m8AlertDetailNoLink = 'm8/alert_detail_no_link.json';
  static const String m8AlertsAdvice9codes = 'm8/alerts_advice_9codes.json';
  static const String m8AlertsDigest = 'm8/alerts_digest.json';
  static const String m8AlertsP0Ack = 'm8/alerts_p0_ack.json';

  /// 🆕 v1.18(01 §27 · 엔진 등재형 K-z) — `AlertCodes.safety` 3 · `resume` 3 각 1행(글자 = 엔진 `alert_text.dart` 초안 ·
  /// 등급 = 엔진 `kAlertLevels` · 등급 순).
  static const String m8AlertsSafetyResume = 'm8/alerts_safety_resume.json';

  /// 🆕 v1.17(01 §26 · 엔진 D11 · K27) — `STALE_ORDERS_HELD`(P1 · 다음 날 가드 보류) 알림 1행.
  static const String m8AlertsStaleOrdersHeld =
      'm8/alerts_stale_orders_held.json';

  /// 🆕 v1.17(01 §26 · K29 · R16c) — `H-03` 기기 리스크(`DeviceRiskVm`) 2벌(empty · items 5행 등급 5값).
  static const String m8DeviceRiskEmpty = 'm8/device_risk_empty.json';
  static const String m8DeviceRiskItems = 'm8/device_risk_items.json';

  /// 🆕 v1.17(01 §26 · K29 · R16a) — `D-03` 긴급정지 카드(`EmergencyCardVm`) 2벌(인쇄 슬롯 있음 · 없음).
  static const String m8EmergencyCard = 'm8/emergency_card.json';
  static const String m8EmergencyCardNoPrint =
      'm8/emergency_card_no_print.json';

  /// 🆕 v1.17(01 §26 · K29 · R16b) — `B-01` 목차(`HandbookIndex`) 2벌 · `B-02` 페이지(`HandbookPage`) 3벌(archived · missing · outdated).
  static const String m8HandbookIndex = 'm8/handbook_index.json';
  static const String m8HandbookIndexOutdated =
      'm8/handbook_index_outdated.json';
  static const String m8HandbookPageArchived = 'm8/handbook_page_archived.json';
  static const String m8HandbookPageMissing = 'm8/handbook_page_missing.json';
  static const String m8HandbookPageOutdated = 'm8/handbook_page_outdated.json';
  static const String m8HandbookPageSleeveB = 'm8/handbook_page_sleeve_b.json';

  /// 🆕 v1.17(01 §26 · K29 · R16a) — `D-01` 장애 배너(`IncidentBannerVm`) 6벌(종류 5 + 배너 없음).
  static const String m8IncidentBannerNetworkDown =
      'm8/incident_banner_network_down.json';
  static const String m8IncidentBannerNone = 'm8/incident_banner_none.json';
  static const String m8IncidentBannerOrderRejected =
      'm8/incident_banner_order_rejected.json';
  static const String m8IncidentBannerOther = 'm8/incident_banner_other.json';
  static const String m8IncidentBannerPhoneDown =
      'm8/incident_banner_phone_down.json';
  static const String m8IncidentBannerTokenExpired =
      'm8/incident_banner_token_expired.json';
  static const String m8IncidentTokenExpired = 'm8/incident_token_expired.json';
  static const String m8OnboardingFinish = 'm8/onboarding_finish.json';

  /// 🆕 v1.16(01 §25 · K23 · R15c) — `O-04` 마무리(`OnboardingFinishVm`) 7벌 + DRY_RUN 결과(`ActionResult` 2).
  static const String m8OnboardingFinishAdvisory =
      'm8/onboarding_finish_advisory.json';
  static const String m8OnboardingFinishAdvisoryDeclared =
      'm8/onboarding_finish_advisory_declared.json';
  static const String m8OnboardingFinishAuto = 'm8/onboarding_finish_auto.json';
  static const String m8OnboardingFinishAutoDeclared =
      'm8/onboarding_finish_auto_declared.json';
  static const String m8OnboardingFinishAutoReady =
      'm8/onboarding_finish_auto_ready.json';
  static const String m8OnboardingFinishDone = 'm8/onboarding_finish_done.json';
  static const String m8OnboardingFinishNoExpectation =
      'm8/onboarding_finish_no_expectation.json';
  static const String m8OnboardingFinishResults =
      'm8/onboarding_finish_results.json';
  static const String m8OnboardingFreshAdvisory =
      'm8/onboarding_fresh_advisory.json';

  /// 🆕 v1.16(01 §25 · K12 · R15a) — `O-00b` 운영 방식 선택(`OnboardingModeChoiceVm`) 4벌 + 선택 결과(`ActionResult` 2).
  static const String m8OnboardingModeAdvisory =
      'm8/onboarding_mode_advisory.json';
  static const String m8OnboardingModeAuto = 'm8/onboarding_mode_auto.json';
  static const String m8OnboardingModeLocked = 'm8/onboarding_mode_locked.json';
  static const String m8OnboardingModePick = 'm8/onboarding_mode_pick.json';
  static const String m8OnboardingModeSelectResults =
      'm8/onboarding_mode_select_results.json';
  static const String m8OnboardingModeUnselected =
      'm8/onboarding_mode_unselected.json';

  /// 🆕 v1.16(01 §25 · K11·K17·K18 · R15a·R15b) — `O-00` 첫 실행(`OnboardingStartVm`) 2 · `O-02` 상세(`OnboardingStepDetailVm`) 3 · `O-01` 목록(`OnboardingStepsVm`) 6 · 검증 결과(`ActionResult` 3).
  static const String m8OnboardingStart = 'm8/onboarding_start.json';
  static const String m8OnboardingStartNoViewer =
      'm8/onboarding_start_no_viewer.json';
  static const String m8OnboardingStepDetailKisMock =
      'm8/onboarding_step_detail_kis_mock.json';
  static const String m8OnboardingStepDetailMissing =
      'm8/onboarding_step_detail_missing.json';
  static const String m8OnboardingStepDetailNoVerify =
      'm8/onboarding_step_detail_no_verify.json';
  static const String m8OnboardingStepsAdvisory =
      'm8/onboarding_steps_advisory.json';
  static const String m8OnboardingStepsAllVerifiedLocked =
      'm8/onboarding_steps_all_verified_locked.json';
  static const String m8OnboardingStepsEmpty = 'm8/onboarding_steps_empty.json';
  static const String m8OnboardingStepsFinishReady =
      'm8/onboarding_steps_finish_ready.json';
  static const String m8OnboardingStepsFinishReadyWarn =
      'm8/onboarding_steps_finish_ready_warn.json';
  static const String m8OnboardingStepsFresh = 'm8/onboarding_steps_fresh.json';
  static const String m8OnboardingVerifyResults =
      'm8/onboarding_verify_results.json';
  static const String m8OpsHomeAdviceOpen = 'm8/ops_home_advice_open.json';

  /// 🆕 v1.13(01 §23 · K7 ⓑ) — 억제 + 기한 라벨(`H-01` 3b 억제 갈래 = `headline` 한 줄만 · R13b 참고 변이 표본).
  static const String m8OpsHomeAdviceSuppressedDue =
      'm8/ops_home_advice_suppressed_due.json';
  static const String m8OpsHomeAdviceZero = 'm8/ops_home_advice_zero.json';
  static const String m8OpsHomeBlocked = 'm8/ops_home_blocked.json';
  static const String m8OpsHomeNormal = 'm8/ops_home_normal.json';
  static const String m8OpsHomeResumeGap7 = 'm8/ops_home_resume_gap7.json';
  static const String m8OpsRhythmRows = 'm8/ops_rhythm_rows.json';

  /// 🆕 v1.12(K29) — `H-02` 리듬을 아직 받지 못함(`NOT_LOADED` · «모름» ≠ «없음») — R13a 위젯 테스트.
  static const String m8OpsRhythmEmpty = 'm8/ops_rhythm_empty.json';

  /// 🆕 v1.16(01 §25 · K27 · R15d) — `V-01` 페어링(`PairingVm`) 3벌(fail · ok · waiting).
  static const String m8PairingFail = 'm8/pairing_fail.json';
  static const String m8PairingOk = 'm8/pairing_ok.json';
  static const String m8PairingWaiting = 'm8/pairing_waiting.json';
  static const String m8ReconBoardDiff = 'm8/recon_board_diff.json';

  /// 🆕 v1.13(01 §23 · K5) — 대조 보드 전부 일치(칸 5 · 자가보고 해당 없음 · `headline` = 엔진 일치 문장) — R13b `h01_normal` 계열.
  static const String m8ReconBoardOk = 'm8/recon_board_ok.json';
  static const String m8RestartLostPhone = 'm8/restart_lost_phone.json';

  /// 🆕 v1.16(01 §25 · K26 · R15d) — `R-01` 다시 시작(`RestartVm`) 4벌(gap7 · logged_out · lost_phone · unknown).
  static const String m8RestartVmGap7 = 'm8/restart_vm_gap7.json';
  static const String m8RestartVmLoggedOut = 'm8/restart_vm_logged_out.json';
  static const String m8RestartVmLostPhone = 'm8/restart_vm_lost_phone.json';
  static const String m8RestartVmUnknown = 'm8/restart_vm_unknown.json';

  /// 🆕 v1.17(01 §26 · K29 · R16a) — `D-02` 런북 상세(`RunbookVm`) 2벌(host_lost · missing) · 목록(`RunbookIndexVm`) 2벌(index · index_empty).
  static const String m8RunbookHostLost = 'm8/runbook_host_lost.json';
  static const String m8RunbookIndex = 'm8/runbook_index.json';
  static const String m8RunbookIndexEmpty = 'm8/runbook_index_empty.json';
  static const String m8RunbookMissing = 'm8/runbook_missing.json';

  /// 🆕 v1.15(01 §24 · K3) 꼴 = `WatchdogBoardVm` 1행(6행 · 실패 1).
  static const String m8WatchdogDelayed = 'm8/watchdog_delayed.json';

  /// 🆕 v1.15(K15) — 행 0(`emptyLabel`) · 받은 적 없음(`lastReceivedText` null).
  static const String m8WatchdogEmpty = 'm8/watchdog_empty.json';

  /// 🆕 v1.15 — 휴장 행 = 성공 핑(OK · ok) · `holidayNotice`.
  static const String m8WatchdogHoliday = 'm8/watchdog_holiday.json';

  /// 🆕 v1.15(K16) — X1 유지보수 창 일시정지(`info`) 3행.
  static const String m8WatchdogPaused = 'm8/watchdog_paused.json';

  // ── m9/ — 설정·운영 모드 전환 (05) ──
  // 🆕 v1.20(01 §29) — `S02` 4 · `S06` 5 · `S03` 3 · 결과 3(파일 이름 바이트 차례 · `all` 도 같은 차례).
  /// 🆕 v1.20 — `S03` 정상(계좌 5 · 매핑 3 · A 행 POT 한 줄 · SAF-309 막힌 선택지 · DC «수동» 배지 · 전체 검증).
  static const String m9AccountMapping = 'm9/account_mapping.json';

  /// 🆕 v1.20 — `S03` 동작 결과 `ActionResult` 8(레벨 5값 · 매핑 · 전체 검증 · 넘김 0 · 재시도 0).
  static const String m9AccountMappingActionResults =
      'm9/account_mapping_action_results.json';

  /// 🆕 v1.20 — `S03` 잠김(`account_mapping` 에서 전체 검증·선택지 호출·영향을 비운 판 + `lockedLabel`).
  static const String m9AccountMappingLocked = 'm9/account_mapping_locked.json';

  /// 🆕 v1.20 — `S03` C 미지정(ACT) · ISA 잔고 확인 실패(BLOCKED) · 미지정 행 선택지 2 + 막힘 1.
  static const String m9AccountMappingUnmapped =
      'm9/account_mapping_unmapped.json';

  // 🆕 v1.24(01 §33) — S09 VM 6 · 결과 1 · S10 VM 5 · 결과 1 · S12 VM 4(파일 이름 바이트 차례 · all 도 같은 차례).
  /// 🆕 v1.24(K118) — `S12` 닫힘(2025년 · 창 닫힘 글자 = `m7_annual_offwindow` · 목차 4 · 서약 링크 null).
  static const String m9AnnualReviewIndexClosed =
      'm9/annual_review_index_closed.json';

  /// 🆕 v1.24 — `S12` 첫해(«첫 해라 비교 대상이 없습니다» · 목차 2 = 받은 것만 · 서약 링크 null).
  static const String m9AnnualReviewIndexFirstYear =
      'm9/annual_review_index_first_year.json';

  /// 🆕 v1.24 — `S12` 열림(2026년 · 목차 4 = M7 링크 · 서약 편집 링크 · 세후·수치 칸 0).
  static const String m9AnnualReviewIndexOpen =
      'm9/annual_review_index_open.json';

  /// 🆕 v1.24 — `S12` 오래됨(`annual_review_index_open` 에서 VM `as_of.stale_label` 만 다른 판 · 봉투 그대로).
  static const String m9AnnualReviewIndexStale =
      'm9/annual_review_index_stale.json';

  /// 🆕 v1.24(K110) — `S09` 정상(마지막 백업 · 지점 2 · 해시 앞 8 · 고지 · «지금 백업» · X1 링크).
  static const String m9Backup = 'm9/backup.json';

  /// 🆕 v1.24(K132 · K133) — `S09` 동작 결과 `ActionResult` 10(레벨 5값 · `BackupResultCodes` 8 전수 · 생체 · 접수 합성 · 넘김 0 · 재시도 0).
  static const String m9BackupActionResults = 'm9/backup_action_results.json';

  /// 🆕 v1.24 — `S09` 나이 배지(WATCH · 배지 문장 숫자 0 · 지점 1).
  static const String m9BackupAgeWarn = 'm9/backup_age_warn.json';

  /// 🆕 v1.24 — `S09` 빈 지점(`points_empty_label` · 버튼·링크 있음 · 골든 아님).
  static const String m9BackupEmpty = 'm9/backup_empty.json';

  /// 🆕 v1.24 — `S09` 잠김(`backup` 에서 `run_action`·`migration_link` 를 비우고 `locked_label` 만 더한 판 · K138).
  static const String m9BackupLocked = 'm9/backup_locked.json';

  /// 🆕 v1.24(K135) — `S09` 모의(지금 실기기 기본 꼴 · 고지 · 빈 지점 · 버튼·링크 부재 — `X1_LIVE_ONLY`).
  static const String m9BackupSim = 'm9/backup_sim.json';

  /// 🆕 v1.24 — `S09` 오래됨(`backup` 에서 VM `as_of.stale_label` 만 다른 판 · 봉투 그대로).
  static const String m9BackupStale = 'm9/backup_stale.json';

  // 🆕 v1.18(01 §27) — `S01` 3 · `S07` 3 · M9 동작 결과 1(파일 이름 바이트 차례 · `all` 도 같은 차례).
  /// 🆕 v1.18 — `S07` 정상(행 5 · 레벨 5값 전수 · 부분 동기 · 실패 2 · 미설정 · 워치독·캘린더 링크 · 카카오 선택 + 배지).
  static const String m9Connections = 'm9/connections.json';

  /// 🆕 v1.18 — `S07` 잠김(운영 등급 생체 축소 · `lockedLabel` · 모든 `actions` 빈 · `selectAction` 전부 null).
  static const String m9ConnectionsLocked = 'm9/connections_locked.json';

  /// 🆕 v1.18 — `S07` 전부 정상 · 행 4(캘린더 행 0 = `calendarEnabled` false 엔진 몫) · 텔레그램 선택.
  static const String m9ConnectionsTelegram = 'm9/connections_telegram.json';

  // 🆕 v1.23(01 §32) — S13 VM 6 · 결과 1(파일 이름 바이트 차례 · all 도 같은 차례).
  /// 🆕 v1.23(K80 · K101) — `S13` 동작 결과 `ActionResult` 9(레벨 5값 · 접수 합성 · 생체 · 엔진 거부 문장 7 · 넘김 0 · 재시도 0).
  static const String m9ContributionActionResults =
      'm9/contribution_action_results.json';

  // 🆕 v1.4(R11 선행) — `ConfigRepository.watchContributionSetting()` 의 입력(폴더 규약상 `m9_` 접두 없음).
  /// 월 납입 설정 — `pension_limit_note_text` 있음.
  static const String m9ContributionSettingDefault =
      'm9/contribution_setting_default.json';

  /// 월 납입 설정 — `pension_limit_note_text` 없음(그 줄 부재).
  static const String m9ContributionSettingNoLimitNote =
      'm9/contribution_setting_no_limit_note.json';

  /// 🆕 v1.20 — `S02` 동작 결과 `ActionResult` 6(레벨 5값 · `CREDENTIAL_VERIFY` · 넘김 0 · 재시도 0).
  static const String m9CredentialActionResults =
      'm9/credential_action_results.json';

  /// 🆕 v1.20 — `S02` `live × autoTrade` · 검증됨 · 만료 임박 + 회전 링크 · 검증 실패 + 슬롯 + 검증 버튼.
  static const String m9Credentials = 'm9/credentials.json';

  /// 🆕 v1.20 — `S02` `live × advisory` · 실전 키 «선택» 미등록 · 대사 키 «권장» 미등록(info · `whyLine`).
  static const String m9CredentialsAdvisory = 'm9/credentials_advisory.json';

  /// 🆕 v1.20 — `S02` 잠김(`credentials` 에서 슬롯·검증·회전을 비운 판 + `lockedLabel` · 런북 링크 유지).
  static const String m9CredentialsLocked = 'm9/credentials_locked.json';

  /// 🆕 v1.20 — `S02` `simInternal × autoTrade` · 봉인 머리 줄 · 봉인 배지 2 · 모의 키 만료(BLOCKED).
  static const String m9CredentialsSimSealed = 'm9/credentials_sim_sealed.json';

  /// 🆕 v1.20 — `S06` 정상(이 폰 + viewer 3 · 리스 유효 · X1 링크 · 발급 버튼).
  static const String m9DeviceAccess = 'm9/device_access.json';

  /// 🆕 v1.20 — `S06` 잠김(폐기·발급·QR·X1 링크를 비운 판 + `lockedLabel`).
  static const String m9DeviceAccessLocked = 'm9/device_access_locked.json';

  /// 🆕 v1.20 — `S06` viewer 0 · 리스 대기(BLOCKED · epoch null) · `emptyLabel`.
  static const String m9DeviceAccessNoViewers =
      'm9/device_access_no_viewers.json';

  /// 🆕 v1.20 — `S06` 오래됨(`device_access` 에서 VM `as_of.stale_label` 만 다른 판 · 봉투 그대로).
  static const String m9DeviceAccessStale = 'm9/device_access_stale.json';

  /// 🆕 v1.20 — `S06` QR 자리(`device_access` 에서 `pairing` 만 티켓 판).
  static const String m9DeviceAccessTicket = 'm9/device_access_ticket.json';

  /// 🆕 v1.20 — `S06` 동작 결과 `ActionResult` 6(레벨 5값 · 발급 · 폐기 · 넘김 0 · 재시도 0).
  static const String m9DeviceActionResults = 'm9/device_action_results.json';

  /// 🆕 v1.24(K113 · K143) — `S10` 기본(지금 실물 꼴 · 골든 «판정 보류» 버튼 부재 · 무결성 버튼 · 보드 = `m8/recon_board_ok` · 권장 배너).
  static const String m9DiagnosticsScreen = 'm9/diagnostics_screen.json';

  /// 🆕 v1.24(K143) — `S10` 차이(E11o 뒤 꼴 · 두 버튼 · 보드 = `m8/recon_board_diff` · 차이 상세 링크).
  static const String m9DiagnosticsScreenDiff =
      'm9/diagnostics_screen_diff.json';

  /// 🆕 v1.24(K138) — `S10` 잠김(`diagnostics_screen_diff` 에서 두 `run_action` 을 비우고 `locked_label` 을 더한 판 · 차이 링크 남음).
  static const String m9DiagnosticsScreenLocked =
      'm9/diagnostics_screen_locked.json';

  /// 🆕 v1.24 — `S10` 골든 실행 중(골든 버튼 부재 · 무결성 버튼 그대로).
  static const String m9DiagnosticsScreenRunning =
      'm9/diagnostics_screen_running.json';

  /// 🆕 v1.24 — `S10` 오래됨(`diagnostics_screen` 에서 VM `as_of.stale_label` 만 다른 판 · 봉투 그대로).
  static const String m9DiagnosticsScreenStale =
      'm9/diagnostics_screen_stale.json';
  static const String m9HandoverStates = 'm9/handover_states.json';

  /// 🆕 v1.23(K79 · K101) — `S13` 정상(글자 = 엔진 `contributionSettingOf` 출력 · 10만원 · 예정 없음 · 버튼 «바꾸기»).
  static const String m9MonthlyContribution = 'm9/monthly_contribution.json';

  /// 🆕 v1.23 — `S13` 잠김(`monthly_contribution` 에서 `locked_label` · `change_label` null · `editable` false 만 다른 판).
  static const String m9MonthlyContributionLocked =
      'm9/monthly_contribution_locked.json';

  /// 🆕 v1.23 — `S13` 0원(납입 멈춤 · 한도 줄 null · 등가 «부족»).
  static const String m9MonthlyContributionNoLimitNote =
      'm9/monthly_contribution_no_limit_note.json';

  /// 🆕 v1.23 — `S13` 기록 없음(기본값 · `last_changed_text` 만 다른 판).
  static const String m9MonthlyContributionNoRecord =
      'm9/monthly_contribution_no_record.json';

  /// 🆕 v1.23 — `S13` 예정 있음(지금 값 10만원 그대로 · 다음 주기부터 0원 문장 — N-S4-01).
  static const String m9MonthlyContributionPending =
      'm9/monthly_contribution_pending.json';

  /// 🆕 v1.23 — `S13` 오래됨(`monthly_contribution` 에서 VM `as_of.stale_label` 만 다른 판 · 봉투 그대로).
  static const String m9MonthlyContributionStale =
      'm9/monthly_contribution_stale.json';

  // 🆕 v1.19(01 §28) — `S05` 7 · S05 동작 결과 1(파일 이름 바이트 차례 · `all` 도 같은 차례).
  /// 🆕 v1.19 — `S05` 동작 결과 `ActionResult` 13(레벨 5값 · id 5 전수 · 넘김 = 전환 요청 3 · 재시도 0).
  static const String m9OperationsActionResults =
      'm9/operations_action_results.json';

  /// 🆕 v1.19 — `S05` `live × advisory` · 운영 방식 전환 요청 1 · `switchGates` PASS + BLOCK · 신뢰 SELF_REPORTED.
  static const String m9OperationsAdvisory = 'm9/operations_advisory.json';

  /// 🆕 v1.19 — `S05` `live × autoTrade` + `LIVE_AWAITING_KEYS` hold · 엔진 멈춤 · DST 표식 · 업데이트 보류(기준일 2026-11-02).
  static const String m9OperationsLiveHoldKeys =
      'm9/operations_live_hold_keys.json';

  /// 🆕 v1.19 — `S05` 실전 관찰 1/2 · 승격 불가 · 램프 조건 5.
  static const String m9OperationsLiveObserve =
      'm9/operations_live_observe.json';

  /// 🆕 v1.19 — `S05` 실전 관찰 2/2 · 승격 버튼.
  static const String m9OperationsLivePromotable =
      'm9/operations_live_promotable.json';

  /// 🆕 v1.19 — `S05` 잠김(`operations_live_promotable` 에서 동작 칸 5 를 비운 판 + `lockedLabel`).
  static const String m9OperationsLocked = 'm9/operations_locked.json';

  /// 🆕 v1.19 — `S05` `simInternal × autoTrade` 체험 진행 중(레벨 5값 · 체험 상태 4값 · 잡 상태 5값 전수).
  static const String m9OperationsSimAuto = 'm9/operations_sim_auto.json';

  /// 🆕 v1.19 — `S05` `simBroker × autoTrade` 체험 5항목 완료 · 업데이트 대기 · 지난 요청 줄.
  static const String m9OperationsSimComplete =
      'm9/operations_sim_complete.json';

  /// 🆕 v1.24(K114 · K115 · K143) — `S10` 동작 결과 `ActionResult` 12(골든 3 = 통과·불일치·생체 · 무결성 9 = 일치·생체·사유 7 전수 BLOCKED).
  static const String m9SelftestActionResults =
      'm9/selftest_action_results.json';

  /// 🆕 v1.18 — M9 `S07` 동작 결과 `ActionResult` 5(레벨 5값 · `SettingsResultCodes` 3 + null 2 · 넘김 0 · 재시도 0).
  static const String m9SettingsActionResults =
      'm9/settings_action_results.json';

  /// 🆕 v1.18 — `S01` 정상(묶음 3 · 카드 11 · 레벨 5값 · 주의 배지 · 승격 줄 · 연간 리뷰 링크).
  static const String m9SettingsHome = 'm9/settings_home.json';

  /// 🆕 v1.18 — `S01` 연간 리뷰 링크 0 · 승격 줄 0.
  static const String m9SettingsHomeNoReview =
      'm9/settings_home_no_review.json';

  /// 🆕 v1.18 — `S01` 뷰어 판(폰 전용 행을 엔진이 뺀 VM).
  static const String m9SettingsHomeViewer = 'm9/settings_home_viewer.json';

  // ── x2/ — 🆕 v1.22(01 §31 · K63 · K64) X2 재개 게이트 4 · 재개 리포트 2 · 폴더 신설(파일 이름 바이트 차례) ──
  //    🆕 v1.25(01 §34) — 게이트 막힌 것 0 · 리포트 화면 감싸개 3.

  /// 🆕 v1.25(K157) — 재개 게이트 · 막힌 계획 0(행 0 · 리포트 링크).
  static const String x2ResumeGateClear = 'x2/resume_gate_clear.json';

  /// 🆕 v1.22 — 보수 모드 · 보수 이월 1 + 계절 진입 1(3택).
  static const String x2ResumeGateConservativeDefer =
      'x2/resume_gate_conservative_defer.json';

  /// 🆕 v1.22 — `seasonal_pending` 의 잠김 판(`locked_label` · 모든 행 `actions` 빈 · 그 밖 바이트 같음).
  static const String x2ResumeGateLocked = 'x2/resume_gate_locked.json';

  /// 🆕 v1.22 — 재판정 실패로 멈춤(`REEVALUATION_FAILED` · VM `level` BLOCKED).
  static const String x2ResumeGateReevaluationFailed =
      'x2/resume_gate_reevaluation_failed.json';

  /// 🆕 v1.22 — 평상 · 계절 진입 사람 결정 1(3택 `seasonalWindowChoice`) + 기한 지남 1.
  static const String x2ResumeGateSeasonalPending =
      'x2/resume_gate_seasonal_pending.json';

  /// 🆕 v1.22 — 재개 리포트 NORMAL(재판정 위임 1 · 대체 1 · 만료 1 · 공백 0).
  static const String x2ResumeReportNormal = 'x2/resume_report_normal.json';

  /// 🆕 v1.22 — 재개 리포트 RECOVERY_FULL(안전 정지 2 · 만료 1 · 복구 불가 공백 1).
  static const String x2ResumeReportRecoveryFull =
      'x2/resume_report_recovery_full.json';

  /// 🆕 v1.25(K156) — 재개 리포트 화면 · 회차 0(빈 문장).
  static const String x2ResumeReportScreenEmpty =
      'x2/resume_report_screen_empty.json';

  /// 🆕 v1.25(K156) — 재개 리포트 화면 · `resume_report_normal` 원판 + 시각·단계.
  static const String x2ResumeReportScreenNormal =
      'x2/resume_report_screen_normal.json';

  /// 🆕 v1.25(K156) — 재개 리포트 화면 · `resume_report_recovery_full` 원판 + 시각·단계.
  static const String x2ResumeReportScreenRecoveryFull =
      'x2/resume_report_screen_recovery_full.json';

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
    rangePresets4,
    rebalance6,
    resumeReport1,
    safetyStates,
    sleeveCatalog4,
    m5BlockBoardClear,
    m5BlockBoardKillActive,
    m5BlockBoardReconMismatch,
    m5BlockBoardResumeIncomplete,
    m5BlockBoardStopped,
    m5BreakerLadderNormal,
    m5BreakerLadderStopped,
    m5HandoverSimToAutoActionResults,
    m5HandoverSimToAutoCooling,
    m5HandoverSimToAutoFatePending,
    m5HandoverSimToAutoReady,
    m5HandoverSimToAutoS3Blocked,
    m5HandoverWizardCommitReady,
    m5HandoverWizardCommitted,
    m5HandoverWizardCooling,
    m5HandoverWizardExpired,
    m5HandoverWizardFatePending,
    m5HandoverWizardLocked,
    m5HandoverWizardNotApplicable,
    m5HandoverWizardS3Blocked,
    m5HandoverWizardStartReady,
    m5HandoverWizardTimeUnknown,
    m5HandoverWizardTrialIncomplete,
    m5HandoverWizardWindowBlocked,
    m5KillChecklistReceipts,
    m5KillResumeGateConditionUnmet,
    m5KillResumeGateInProgress,
    m5KillResumeGateLocked,
    m5KillResumeGateNotConfirmed,
    m5KillResumeGateOff,
    m5KillResumeGateReady,
    m5KillResumeGateTimeUnknown,
    m5KillResumeGateWaiting,
    m5KillSwitchActivateReceipts,
    m5KillSwitchActiveLocked,
    m5KillSwitchActiveUnrecorded,
    m5KillSwitchCancelReadFailed,
    m5KillSwitchLocked,
    m5KillSwitchOff,
    m5KillSwitchRecordedReady,
    m5KillSwitchRecordedWaiting,
    m5PledgeEditWindow,
    m5PledgeNotWritten,
    m5PledgeWritten,
    m5ReconClearResults,
    m5RuleChangeGateApprovable,
    m5RuleChangeGateCooling,
    m5RuleChangeGateEmpty,
    m5RuleChangeGateFirstCandidate,
    m5RuleChangeGateLocked,
    m5RuleChangeRequestResults,
    m5SafetyActionResults,
    m5SafetyActionResultsE13,
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
    m6AdviceStale,
    m6AdviceFillsAd0005,
    m6AdviceDeferReceipts3,
    m6AdviceSkipReceipts5,
    m6AllocationEmpty,
    m6AllocationInBand,
    m6AllocationIntegrity,
    m6AllocationOutOfBand,
    m6AllocationParkingLarge,
    m6AllocationRecon,
    m6AllocationTrancheProgress,
    m6BlindReviewCardBefore,
    m6BlindReviewCardRevealed,
    m6BlindReviewCardRevealedOpen,
    m6BlindReviewQueue3,
    m6BlindReviewQueueEmpty,
    m6BlindReviewReceipts6,
    m6DecisionDetailAmended,
    m6DecisionDetailFull,
    m6DecisionDetailJournalDraftLink,
    m6DecisionDetailJournalWritten,
    m6DecisionDetailPartial,
    m6DecisionDetailReevaluatedChild,
    m6DecisionDetailRejectedSaf309,
    m6DecisionDetailUnknown,
    m6DraftRecordsJ3,
    m6DraftRecordsX7,
    m6EntryGateNovPass1,
    m6ExternalHoldings2,
    m6FillFormSpec,
    m6FillFormSpecStale,
    m6FillRejectedPrice,
    m6FillFormSpecBlocked,
    m6LedgerRepairs4,
    m6LedgerRepairsEmpty,
    m6LedgerDiffsCashObserve,
    m6ManualFillReceipts7,
    m6HoldingDetailIntegrity,
    m6HoldingDetailNoStop,
    m6HoldingDetailPnl,
    m6HoldingDetailRecon,
    m6HoldingDetailWithStops,
    m6HoldingsOverviewEmpty,
    m6HoldingsOverviewIntegrity,
    m6HoldingsOverviewNormal,
    m6HoldingsOverviewPnl,
    m6HoldingsOverviewRecon,
    m6HoldingsOverviewViewer,
    m6JournalEmpty,
    m6JournalExpired1,
    m6JournalBadges2,
    m6JournalDraftReceipts5,
    m6JournalDraftSpecDiscretion,
    m6JournalDraftSpecReconClear,
    m6JournalFilterCatalog,
    m6JournalMaskedIntegrity,
    m6JournalRebalanceScope1,
    m6JournalRebalanceUnknown,
    m6JournalReadNoNote,
    m6JournalReadNotWritten,
    m6JournalReadWritten,
    m6JournalSimBrokerReject,
    m6ManualFills8,
    m6SelfReport1,
    m6SelfReportDiffResult,
    m6SelfReportSessionClosed,
    m6SelfReportReceipts5,
    m6SafetyAdviceBlocked,
    m6UnknownBoard2,
    m6UnknownBoardEmpty,
    m7AftertaxLadder1,
    m7ExecutionGap1,
    m7ExecutionGapCant,
    m7ExecutionGapEmpty,
    m7ExecutionGapMaskedRecon,
    m7ExecutionGapMixed,
    m7ExecutionGapNotApplicable,
    m7ExecutionGapWont,
    m7LedgerTrust4,
    m7LedgerTrustSelfAuditDue,
    m7M7Annual2026,
    m7M7AnnualFirstYear,
    m7M7AnnualOffwindow,
    m7M7Contrib3sleeve,
    m7M7ContribPartial,
    m7M7DdContextDeep,
    m7M7DdContextNormal,
    m7M7DepositPlanBlocked,
    m7M7DepositPlanDefault,
    m7M7DepositPlanExpired,
    m7M7DepositPlanFunding,
    m7M7DepositPlanInputRejected,
    m7M7DepositPlanLimit,
    m7M7DepositRegisterReceipts5,
    m7M7DisclosureGate,
    m7M7DisclosureGateClosed,
    m7M7DisclosureGateFirst,
    m7M7DisclosureGateFrequent,
    m7M7DisclosureViewReceipts4,
    m7M7GoalPathHold,
    m7M7GoalPathOff,
    m7M7GoalPathOn,
    m7M7GoalPathRealworld,
    m7M7Monthly202608,
    m7M7MonthlyGap,
    m7M7MonthlyMaskedIntegrity,
    m7M7MonthlyMaskedRecon,
    m7M7MonthlyPending,
    m7M7NextRebalanceCountdown,
    m7M7NextRebalanceNone,
    m7M7PerfDailyGap,
    m7M7PerfDailyManual,
    m7M7PerfMaskedIntegrity,
    m7M7PerfMonthlyPeriod,
    m7M7PerfMonthlySimSplit,
    m7M7PerfUnavailableGap,
    m7M7PerfYearly,
    m7M7RebalanceDetailBand,
    m7M7RebalanceDetailAdvisory,
    m7M7RebalanceEmpty,
    m7M7RebalancePreviewBlocked,
    m7M7RebalancePreviewDefault,
    m7M7RebalancePreviewInBand,
    m7M7RebalanceSim,
    m7M7ReportArchive18,
    m7M7ReportArchiveEmpty,
    m7M7WithdrawalGeneral,
    m7M7WithdrawalPensionPenalty,
    m7M7WithdrawalShortfall,
    m7RealizedAllocS7,
    m8AlertAckReceipts3,
    m8AlertCenterDigest,
    m8AlertCenterEmpty,
    m8AlertCenterP0Ack,
    m8AlertCenterP0AckReordered,
    m8AlertCenterP0Only,
    m8AlertDetailFull,
    m8AlertDetailMissing,
    m8AlertDetailNoLink,
    m8AlertsAdvice9codes,
    m8AlertsDigest,
    m8AlertsP0Ack,
    m8AlertsSafetyResume,
    m8AlertsStaleOrdersHeld,
    m8DeviceRiskEmpty,
    m8DeviceRiskItems,
    m8EmergencyCard,
    m8EmergencyCardNoPrint,
    m8HandbookIndex,
    m8HandbookIndexOutdated,
    m8HandbookPageArchived,
    m8HandbookPageMissing,
    m8HandbookPageOutdated,
    m8HandbookPageSleeveB,
    m8IncidentBannerNetworkDown,
    m8IncidentBannerNone,
    m8IncidentBannerOrderRejected,
    m8IncidentBannerOther,
    m8IncidentBannerPhoneDown,
    m8IncidentBannerTokenExpired,
    m8IncidentTokenExpired,
    m8OnboardingFinish,
    m8OnboardingFinishAdvisory,
    m8OnboardingFinishAdvisoryDeclared,
    m8OnboardingFinishAuto,
    m8OnboardingFinishAutoDeclared,
    m8OnboardingFinishAutoReady,
    m8OnboardingFinishDone,
    m8OnboardingFinishNoExpectation,
    m8OnboardingFinishResults,
    m8OnboardingFreshAdvisory,
    m8OnboardingModeAdvisory,
    m8OnboardingModeAuto,
    m8OnboardingModeLocked,
    m8OnboardingModePick,
    m8OnboardingModeSelectResults,
    m8OnboardingModeUnselected,
    m8OnboardingStart,
    m8OnboardingStartNoViewer,
    m8OnboardingStepDetailKisMock,
    m8OnboardingStepDetailMissing,
    m8OnboardingStepDetailNoVerify,
    m8OnboardingStepsAdvisory,
    m8OnboardingStepsAllVerifiedLocked,
    m8OnboardingStepsEmpty,
    m8OnboardingStepsFinishReady,
    m8OnboardingStepsFinishReadyWarn,
    m8OnboardingStepsFresh,
    m8OnboardingVerifyResults,
    m8OpsHomeAdviceOpen,
    m8OpsHomeAdviceSuppressedDue,
    m8OpsHomeAdviceZero,
    m8OpsHomeBlocked,
    m8OpsHomeNormal,
    m8OpsHomeResumeGap7,
    m8OpsRhythmRows,
    m8OpsRhythmEmpty,
    m8PairingFail,
    m8PairingOk,
    m8PairingWaiting,
    m8ReconBoardDiff,
    m8ReconBoardOk,
    m8RestartLostPhone,
    m8RestartVmGap7,
    m8RestartVmLoggedOut,
    m8RestartVmLostPhone,
    m8RestartVmUnknown,
    m8RunbookHostLost,
    m8RunbookIndex,
    m8RunbookIndexEmpty,
    m8RunbookMissing,
    m8WatchdogDelayed,
    m8WatchdogEmpty,
    m8WatchdogHoliday,
    m8WatchdogPaused,
    m9AccountMapping,
    m9AccountMappingActionResults,
    m9AccountMappingLocked,
    m9AccountMappingUnmapped,
    m9AnnualReviewIndexClosed,
    m9AnnualReviewIndexFirstYear,
    m9AnnualReviewIndexOpen,
    m9AnnualReviewIndexStale,
    m9Backup,
    m9BackupActionResults,
    m9BackupAgeWarn,
    m9BackupEmpty,
    m9BackupLocked,
    m9BackupSim,
    m9BackupStale,
    m9Connections,
    m9ConnectionsLocked,
    m9ConnectionsTelegram,
    m9ContributionActionResults,
    m9ContributionSettingDefault,
    m9ContributionSettingNoLimitNote,
    m9CredentialActionResults,
    m9Credentials,
    m9CredentialsAdvisory,
    m9CredentialsLocked,
    m9CredentialsSimSealed,
    m9DeviceAccess,
    m9DeviceAccessLocked,
    m9DeviceAccessNoViewers,
    m9DeviceAccessStale,
    m9DeviceAccessTicket,
    m9DeviceActionResults,
    m9DiagnosticsScreen,
    m9DiagnosticsScreenDiff,
    m9DiagnosticsScreenLocked,
    m9DiagnosticsScreenRunning,
    m9DiagnosticsScreenStale,
    m9HandoverStates,
    m9MonthlyContribution,
    m9MonthlyContributionLocked,
    m9MonthlyContributionNoLimitNote,
    m9MonthlyContributionNoRecord,
    m9MonthlyContributionPending,
    m9MonthlyContributionStale,
    m9OperationsActionResults,
    m9OperationsAdvisory,
    m9OperationsLiveHoldKeys,
    m9OperationsLiveObserve,
    m9OperationsLivePromotable,
    m9OperationsLocked,
    m9OperationsSimAuto,
    m9OperationsSimComplete,
    m9SelftestActionResults,
    m9SettingsActionResults,
    m9SettingsHome,
    m9SettingsHomeNoReview,
    m9SettingsHomeViewer,
    x2ResumeGateClear,
    x2ResumeGateConservativeDefer,
    x2ResumeGateLocked,
    x2ResumeGateReevaluationFailed,
    x2ResumeGateSeasonalPending,
    x2ResumeReportNormal,
    x2ResumeReportRecoveryFull,
    x2ResumeReportScreenEmpty,
    x2ResumeReportScreenNormal,
    x2ResumeReportScreenRecoveryFull,
  ];
}
