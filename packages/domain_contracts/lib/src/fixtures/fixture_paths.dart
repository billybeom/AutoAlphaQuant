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
  static const String m6ManualFills8 = 'm6/manual_fills_8.json';
  static const String m6SelfReport1 = 'm6/self_report_1.json';

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
  // 🆕 v1.4(R11 선행) — `ConfigRepository.watchContributionSetting()` 의 입력(폴더 규약상 `m9_` 접두 없음).
  /// 월 납입 설정 — `pension_limit_note_text` 있음.
  static const String m9ContributionSettingDefault =
      'm9/contribution_setting_default.json';

  /// 월 납입 설정 — `pension_limit_note_text` 없음(그 줄 부재).
  static const String m9ContributionSettingNoLimitNote =
      'm9/contribution_setting_no_limit_note.json';
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
    rangePresets4,
    rebalance6,
    resumeReport1,
    safetyStates,
    sleeveCatalog4,
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
    m6ManualFills8,
    m6SelfReport1,
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
    m9ContributionSettingDefault,
    m9ContributionSettingNoLimitNote,
    m9HandoverStates,
  ];
}
