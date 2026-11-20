// 계약 버전 — 화면·픽스처·골든이 같은 계약을 보고 있는지 확인하는 단 하나의 값.
//
// 🔴 픽스처 봉투의 `meta.contract_version`(01 §5)과 같은 축이다. 한쪽만 올리면
//    C-1(뷰모델 골든)·C-15(픽스처↔DDL 정합)가 갈라진 채로 통과한다.
//
// ✅ **'1.0.0' 로 상향(2026-09-08 · G3 확정)** — 01 문서가 «상태: 확정 v1.0» 줄을 받는
//    바로 그 커밋이 이 값을 올리는 커밋이다(구 주석의 조건이 성립했다). 인벤토리 §10-1 의
//    「영역 E 첫 커밋은 올리지 않는다(보류)」는 그 커밋이 아니었다는 뜻이며, 지금 해제된다.
// 🔴 이 상수와 **전 픽스처 봉투**의 `meta.contract_version` 은 언제나 **같은 커밋에서 함께**
//    움직인다(1.0.0 상향 때 77개 · 1.1.0 상향 때 96개 · 1.2.0 상향 때 104개 · 1.3.0 상향 때 115개 ·
//    1.4.0 상향 때 122개 · 1.5.0 상향 때 126개 · 1.6.0 상향 때 135개 · 1.7.0 상향 때 141개 · 1.8.0 상향 때 159개 · 1.12.0 상향 때 174개 · 1.13.0 상향 때 176개 · 1.14.0 상향 때 176개 · 1.17.0 상향 때 240개 · 1.18.0 상향 때 248개 · 1.19.0 상향 때 256개 · 1.20.0 상향 때 271개 · 1.21.0 상향 때 283개 · 1.22.0 상향 때 298개 · 1.23.0 상향 때 305개 · 1.24.0 상향 때 322개 · 1.25.0 상향 때 339개 · 1.29.0 상향 때 365개 · 1.30.0 상향 때 365개) — 한쪽만 올리면 C-1·C-15 가
//    갈라진 채로 통과한다.
// 🆕 '1.2.0'(R2b 선행 M2 보강 · 01 §12) — 초안 포트 `DraftStore`·`DraftKind`·`DraftRecord`·입력 4종 ·
//    `JournalRepository.watchDecisionJournal`·`DecisionJournalVm` · 라우트 `journalRead`(41).
// 🆕 '1.3.0'(R10 선행 M2 보강 · 01 §13) — 성과 시리즈 표시 필드(`PerfPoint.xNormalized`·
//    `yNormalized`·`dateText`·`valueText` · `PerfSegment.startNormalized`·`endNormalized` ·
//    `PerfAxisTick` · `PerformanceSeries.seriesLabel`·`periodLabel`·`yTicks`·`unavailableLabel`) ·
//    `ReportArchiveRow.sectionLabel` · `DisclosureViewEvent.durationSec` 기본값 0 ·
//    `PerformanceRepository.series(range:)` nullable · 코드 `DisclosureSurfaceCodes`·
//    `GapReasonCodes.simExcluded` · 동작 링크 `AppNavActions.back`.
// 🆕 '1.4.0'(R11 선행 M2 보강 · 01 §14) — 입금 미리보기 `WhatIfApi.simulateDeposit({amountInput})` →
//    `DepositPreviewResult`(plan | 입력 거부 | 차단) · `PensionLimitVm` · `DepositPlan`·`OrderDraft`·
//    `SleeveAllocation` 표시 필드 · `ContributionSetting`/`MonthlyContributionVm.amountInputText` ·
//    `DepositRegistration(planId:)` 하나 · `DEPOSIT_REGISTER` 폰 전용(뷰어 4종) · 목표 경로
//    `PerformanceRepository.goalPath({yyyyMm})` · `GoalPathVm` 재설계(`GoalPathPoint` 폐기 ·
//    `PerfPoint` 재사용 · C-4 동시 금지 폐기) · `MonthlyReport.goalDeepLink` · 라우트
//    `reportGoalPath`(42) · 코드 `PlannerReasonCodes` · 받침대 `UnimplementedWhatIfApi`.
//    ⏸ S7-5(`WithdrawalPlan`)는 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor(번호는 그때 · 01 §14-15 · §15-3).
// 🆕 '1.5.0'(R12 선행 M2 보강 · 01 §15-3 · §8 미결 49) — 라우트 `journalRebalance`(43) ·
//    `RebalanceEvent.journalTimelineLink`·`detailDeepLink` · `JournalRebalanceScope` +
//    `JournalRepository.watchRebalanceScope` · `RebalanceRepository.watchEvent` · `watchEvents` 봉투
//    (`ListResult`) · 받침대 `UnimplementedRebalanceRepository` · 픽스처 122 → 126.
// 🆕 '1.6.0'(R12 선행 M2 보강 · 01 §15-4 · 발주자 결정 ①② 2026-10-07) — `S7-6a/b/c`·`S7-7`·`S7-10` 표시 계약:
//    `RebalancePreviewResult`(초안 | 차단) + `WhatIfApi.previewRebalance` 반환 · `ExecutionGapResult`
//    (리포트 | 빈·해당없음) + `ExecutionGapRepository.monthly({yyyyMm})` · `RebalanceRepository.watchEvents({range})`
//    (null = 전체 기간) · `PerformanceRepository.annualReview({year})`(null = 엔진 기본 연도) ·
//    `RebalanceEvent.thresholds`·`modeLabel`·`sectionLabel`(+ `asOf` = 관측 시각) · `RebalancePreview` 표시
//    필드 5 · `NextRebalanceVm.asOf`(+ 두 글자 nullable) · `AnnualReviewVm.yearLabel`·`afterTax`·
//    `afterTaxCounterfactual` · `AfterTaxLadder.referenceOnlyLabel` · `ExecutionGapReport.countLines`·
//    `correctionLines`(+ `complianceRateNormalized`·`modeAdviceLine` nullable) · `ThresholdCompare` →
//    `dto/common.dart`(이름·JSON 무변경) · 라우트 `ledgerExecutionGapMonth`·`rebalanceHistory`(45) ·
//    받침대 `UnimplementedExecutionGapRepository` · 픽스처 126 → 135(신설 9 · 개정 14 · 개명 1) —
//    🆕 tool/gen_r12_v16_fixtures.py(기준 542d13c 원문에서 멱등 생성).
// 🆕 '1.7.0'(J-4 선행 · 01 §16 · §8 미결 46 · 발주자 결정 2026-10-20 K1~K24 권고대로) — `J-4` 사후 blind 리뷰:
//    `BlindReviewChoice{score, label}`(선택지가 점수를 싣는다 · `BlindReviewScore` 필드 무변경) · `BlindReviewResult`
//    (채점 집행 뒤에만 · 금액 0 — K6) · `BlindReviewCard` +7(`titleText`·`contextChips`·`deviation`·
//    `journalStateLabel`·`journal`·`result`·`asOf`) · `BlindReviewQuestion.evidenceText` + `choices` 형 교체 ·
//    `JournalRepository.watchBlindReviewQueue({mode})`(봉투) · `watchBlindReviewCard(decisionId)` · 거부 코드
//    `BlindReviewRejectCodes`(`blind_review_reject`) · 받침대 2줄 · 라우트 45 그대로 · 픽스처 135 → 141(신설 6) —
//    🆕 tool/gen_j4_v17_fixtures.py(기준 76c2404 원문에서 멱등 생성).
// 🆕 '1.8.0'(R4 선행 · 01 §17 · 화면 ID `H6-*` · 발주자 결정 2026-10-20 K1~K5 · 2026-10-21 K14·K15·K16·K17·K27 권고대로) —
//    보유현황 `H6-1`~`H6-3` 표시 계약: `HoldingsRepository.watchHoldingsOverview({includePnl})` → `HoldingsOverviewVm`
//    (`HoldingsSleeveCard` · `HoldingsExternalSection` — 시스템 밖 행 = `ExternalHoldingRow` · K14) ·
//    `watchHoldingDetail(holdingId, {includePnl})` → `HoldingDetailVm`(손절선 = 기존 `StopLineNormalized` 글자 행 · K3) ·
//    `watchAllocation()` → `SleeveAllocationVm` · `HoldingRow` +7(`holdingId` · 표시 문자열 · 칩 · 링크) · `HoldingPnl` +2 ·
//    `SleeveAllocationRow` +7(밴드 축 `sleeveWeight`·`bandState`·`gauge` — 밴드 행 = B 만 · K27 · 비율 2 nullable) ·
//    🆕 `SleeveBandState` · `SleeveBandGauge` · `ExternalHoldingRow.quantityText` · 코드 `StopTierCodes`(`stop_tier`) ·
//    라우트 `holdingsOverview`·`holdingsDetail`·`holdingsAllocation`(48) · 받침대 `UnimplementedHoldingsRepository` ·
//    픽스처 141 → 159(신설 18 · 개정 3) — 🆕 tool/gen_h6_v18_fixtures.py(기준 f46e72f 원문에서 멱등 생성).
// 🆕 '1.9.0'(E9a · 단계 1b 마이그레이션 창 · 설계 13 §8 R19 · R20 · 발주자 결정 2026-10-21 추천안) —
//    스키마 v1 결정 반영: `ddl/*` = `mode` 3값 + 파일별 CHECK(`-- @sim` 태그 · `DEFAULT 'SIM'` 삭제) ·
//    명령 state 2표 8값(`NO_OPERATOR` 포함) · `CORPORATE_ACTION` 통합 · `dry_run` ⇔ `ExecPolicy` 파생 규칙 ·
//    수기 체결 `broker_order_no` NULL(+ CHECK) · `batch_e` 보관 · 🆕 [schemaVersion] = 1 · [hashFormatVersion] = 1 ·
//    `LedgerFile`(두 파일 · `application_id`) · `LedgerModeCheck` · `ledgerDdlFor`(SIM 판 파생) ·
//    C-15 열린 물음 2검사 → 등식 검사 · 픽스처 159(봉투 버전만 · 값 무변경).
// 🆕 '1.10.0'(E9a2 · X7 ㊲ · 설계 13 §8 R21 L1~L6 · 발주자 결정 2026-10-21 추천안) — 원장 사건:
//    `LedgerEventKind`(4) · `CorporateActionType`(분할·병합) · `CashFlowKind`(5) + `isExternal`(TWR 외부 흐름 =
//    입금·출금만) · `CommandKind.ledgerEventRecord` · `CommandApi.recordLedgerEvent(LedgerEventRecord)` ·
//    거부 코드 `LedgerEventRejectCodes`(`ledger_event_reject` 8) · 사유 코드 +5(`LEDGER_EVENT_*`) ·
//    `ddl/batch_f` = `ledger_event` 신설 + `cash_flow` 5값 재작성(+`source_event_id`) · `batch_d` 명령 kind +1 ·
//    받침대 1메서드 · 🆕 C-45 · 픽스처 159(봉투 버전만).
// 🆕 '1.11.0'(E7b0 · M3-2·M3-4 · 설계 13 §8 R22 D4·D5·D6·D14 · 발주자 결정 2026-10-21 추천안) — 실입금 등록:
//    거부 코드 `DepositRegisterRejectCodes`(`deposit_register_reject` 6 + 판정 순서 `precedence`) ·
//    사유 코드 `DEPOSIT_REGISTERED` · `ddl/batch_f` `cash_flow.account_alias`(계좌별 입금 행) ·
//    픽스처 `m7_deposit_register_receipts_4` → `_5`(`REJECTED` 1행 · 01 §8 미결 74 ✅) ·
//    판정 `depositReceiptViolations` → `testing.dart`(C-38 ⑨) · 픽스처 159(개명 1 · 봉투 버전).
// 🆕 '1.12.0'(R5·R13 선행 · 01 §21 · 발주자 확정 2026-10-22 — 🔴 8건 K9·K14·K18·K30·K35·K36·K46·K47 권고대로) —
//    X7 `A-1`~`A-4`·`L-3` + X5 `L-1`·`L-2` + `H-02` 리듬: 라우트 48 → 52(교체 2 `adviceFill`·`ledgerSelfReport` ·
//    신설 4 `adviceSkip`·`ledgerDiffs`·`ledgerRepairs`·`opsRhythm`) · `CommandApi` X7 3 인자 = 제출 DTO
//    (`ManualFillSubmission`·`AdviceSkipSubmission`·`SelfReportSubmission` — 파싱·맥락 = 구현 · K4) + `deferAdviceConfirm`
//    (`AdviceDeferConfirm` · `DEFER_ADVICE_CONFIRM` · K14 ⓐ) · `watchCommand` 구현 의무 ④(K42) · `CommandReceipt.retryCode`·
//    `retryLabel` · `SelfReportSession`·`SelfReportResult` + `watchSelfReportSession(yyyyMm, accountAlias)` · `SettingsActionId`
//    세션 2값(K9) · `AdviceItem` +7 · `AdviceAction.deepLink` · `AdviceInboxSummary` +4 · `ManualFillFormSpec` +5 ·
//    `SideOption`·`TradeDateOption` · `ReasonOption.deepLink` · `LedgerDiffRow` +8 · `LedgerRepairRow` +7 ·
//    `watchRepairs` · `OpsSummaryRepository.watchRhythm` · `OpsDailySummary.resumeLine` · 코드 `AdviceRejectCodes` 18 ·
//    `AdviceRetryCodes` · `ManualFillPrefillFields` · 받침대 +5 · 🆕 C-46·C-47 · 픽스처 159 → 174(신설 15 · 개정 22 ·
//    알림 등급 5행 — 미결 114) — 🆕 tool/gen_r5r13_v112_fixtures.py(기준 f54f602 원문에서 멱등 생성).
// 🆕 '1.13.0'(R13b 선행 · 01 §23 · 발주자 확정 2026-10-26 — 🔴 K1·K2·K7 권고대로) — `DiagnosticCell.level`
//    (`UiLevel` · 칸 색·아이콘 원천 · 해당 없음 = info · 파생 3쌍 blocked 0) · `DiagnosticsVm.headline` «늘 엔진 문장»
//    규약(주석) · 픽스처 174 → 176(신설 `m8/recon_board_ok`·`m8/ops_home_advice_suppressed_due` · 개정
//    `m8/recon_board_diff` · 등록부 m8 `advice_summary` extras 3) · C-47 ⑩⑪ — 🆕 tool/gen_r13b_v113_fixtures.py
//    (기준 fc25f77 원문에서 멱등 생성). 🔵 13 §8 R25 G7 의 E8a «1.13.0» 은 1.14.0 으로 민다(K1).
// 🆕 '1.14.0'(E8a · M1-7 데이터 어댑터 · 설계 13 §8 R23 D7·D8 · R24 B4·B5 · R25 G1~G8 — 발주자 «권고안대로» ·
//    '1.13.0'(R13b 선행 2 · PR #72 `638fca4`) 위로 다시 올렸다 — 13 §8 R25 G7·G8) —
//    `MarketDataSource`(시세·지표 원천 6값) · `GapReasonCodes` +5(`MISSING_ROW`·`NON_POSITIVE_PRICE`·`NEGATIVE_VOLUME`·
//    `PRICE_JUMP`·`CALENDAR_SUSPECT` — `data_gap.reason_code`) · 🆕 `ddl/batch_g_market_data.sql`(`market_series`·`fetch_log`
//    신설 · `daily_prices` += `source`·`fetched_at` · `regime_score_daily` += `source` · 스키마 v1 한 판) · `data_gap.dataset`
//    주석 += macro·regime·calendar · 🆕 C-48 · C-15 축 +3 · 픽스처 176(봉투 버전만).
// 🆕 '1.15.0'(R14 선행 · 01 §24 · 발주자 결정 2026-10-30 ①~④ · K1~K23) — 알림 센터·상세·워치독 표시 계약:
//    `AlertCenterVm`·`AlertSection`·`AlertDetailVm` · `AlertItem` +3(`raisedAtText`·`groupedText`·`detailDeepLink`) ·
//    `AlertRepository.watchCenter({required bool p0Only})`·`watchAlert(alertId)`(추가형 · `watchInbox` 무변경) ·
//    `CommandApi.acknowledgeAlert(String alertId)`(인자 교체 · 와이어 `AlertAck` 무변경) · 라우트 `alertsInbox`·`alertDetail`(54) ·
//    `WatchdogBoardVm` · `watchWatchdog()` 반환 교체 · `WatchdogCheck` − `slug` + `checkId` + `level` · 받침대
//    `UnimplementedAlertRepository`·`UnimplementedOpsStatusRepository` · 🆕 C-49 · 픽스처 176 → 187(신설 11 · 개정 5) —
//    🆕 tool/gen_r14_v115_fixtures.py(기준 1bb1a84 원문에서 멱등 생성).
// 🆕 '1.16.0'(R15 선행 · 01 §25 · 발주자 결정 2026-11-03 ①~④ · K1~K35) — X3 온보딩 위저드 표시·동작 계약:
//    `dto/onboarding.dart` VM 7(`OnboardingStartVm`·`OnboardingModeChoiceVm`·`OnboardingStepsVm`·`OnboardingStepDetailVm`·
//    `OnboardingFinishVm`·`RestartVm`·`PairingVm`) + 부품 5 · `OnboardingStep` +6(`requirementLabel` 등) ·
//    `OnboardingRepository` +6(추가형) · 🆕 `PairingRepository` · `SettingsActionId.onboardingDryRunStart` · args 화이트리스트 ·
//    라우트 64(온보딩 6 · `ledgerSimOpening` · `m5SimOpeningCash` · X1 2) · 사전 3축(`OnboardingResultCodes`·`BrokerRawCodes`·
//    `OnboardingSlotIds`) · 받침대 2 · 🆕 C-50 · 픽스처 187 → 219(신설 32 · 개정 6) — 🆕 tool/gen_r15_v116_fixtures.py
//    (기준 267e867 원문에서 멱등 생성). 엔진 다음 계약 판 = 1.17.0(E10 D11 4건 · 06 변경 이력) — 🆕 v1.17 이 R16 선행과
//    한 판으로 실었다(아래).
// 🆕 '1.17.0'(R16 선행 + 엔진 E10 D11 · 01 §26 · 발주자 결정 2026-11-04 ①~④ · K1~K33) — M8 장애·DR·핸드북·기기 리스크 표시 계약:
//    `dto/incident.dart`(`IncidentBanner`·`IncidentBannerVm` · `RunbookIndexVm`·`RunbookRow`·`RunbookVm`·`RunbookStep` · `EmergencyCardVm`) ·
//    enum `IncidentKind`·`HandbookEntryState` · 핸드북 추가형(`state`·`stateLabel`·`deepLink`·`children` · `outdatedNotice` ·
//    `missingLabel` · `asOf?` · `HandbookLiveValue`) · `DeviceRiskItem`·`DeviceRiskVm` · 🆕 `IncidentRepository`·`RunbookRepository`·
//    `HandbookRepository` · `OpsStatusRepository.watchDeviceRisk`(추가형) · 라우트 69 · `OpsSlotIds` · 받침대 3 + 1 · 🆕 C-51 ·
//    🔴 엔진 D11 4건(R31 체결 키 주석 · `JournalStatus.expired` · `AlertCodes.staleOrdersHeld` · PREVENTED 근거 = `JournalReasonCodes`) ·
//    픽스처 219 → 240(신설 21 · 개정 3) — 🆕 tool/gen_r16_v117_fixtures.py(기준 = M2 밑동 원문에서 멱등 생성).
//    엔진 다음 계약 판 = 1.18.0(13 §8 R55 E13i1·i2 · E11d X12 등 «계약 창» 몫 · 06 변경 이력) — 🆕 v1.18 이 R6 선행과
//    한 판으로 엔진 등재형 7 을 실었다 · E13i1·i2 등 나머지 = 1.19.0(아래).
// 🆕 '1.18.0'(R6 선행 + 엔진 등재형 7 · 01 §27 · 발주자 결정 2026-11-13 Q1~Q4 · K-a~K-z) — M9 S01 설정 홈 · S07 연결 관리 표시·동작 계약:
//    `SettingsHomeVm` 교체(`statusChip`·`annualReviewLink`·`groups`·`asOf`) · 🆕 `SettingsGroup`·`EngineStatusChip`·enum `SettingTier` ·
//    `SettingsCard` += `attentionText` − `actionAvailable` · `ConnectionsVm` += `lockedLabel` · `ConnectionRow` += `detailLine`·`level`·
//    `actions`·`channelPicker` − `actionAvailable` · 🆕 `NotifyChannelCard`·`NotifyChannelOption` · `typedef SettingsActionCall` ·
//    `SettingsActionId.notifyChannelSelect` · 🆕 `SettingsRepository` · 라우트 80(M9 11) · 사전 3(`connection_target`·`notify_channel`·
//    `settings_result`) · 받침대 1 · 🆕 C-52 · 🔴 엔진 등재형 7(`AlertCodes.safety` 3 · `resume` 3 · `JournalReasonCodes.leaseInvalid`) ·
//    픽스처 240 → 248(신설 8 · 개정 1 — `incident_token_expired` 바인딩) — 🆕 tool/gen_r6_v118_fixtures.py(기준 = M2 밑동 원문에서 멱등).
//    엔진 다음 계약 판 = 1.19.0(13 §8 R55 E13i1·i2 · E14i 재개 VM · E11d X12 등 + R6c S05 `OperationsVm` · 06 변경 이력) —
//    🆕 v1.19 가 R6c 선행과 한 판으로 E15i 굳은 몫을 실었다 · E13i·E14i 등 = 1.20.0(아래).
// 🆕 '1.19.0'(R6c 선행 + 엔진 E15i 굳은 몫 · 01 §28 · 발주자 위임 2026-11-14 — 권고대로 · K1~K26) — M9 S05 운용 관리 표시·동작 계약:
//    🆕 dto/operations.dart — `OperationsVm`·`RunModeCard`·`SimTrialCard`·`SimTrialCheck`·`RampBoard`·`RampCondition`·`JobRow`·
//    `EngineControl`·`UpdateGateCard` · `OperatingModeView` += `switchActions` · `SafetyState` += `holds` · `RampLevel` 주석(L0 미발행) ·
//    `SettingsRepository.watchOperations` · 🆕 `SettingsActionId.runtimeLivePromotion` · S05 args 5 · 사전 +7(`engine_stop_reason` ·
//    `sim_trial_item` · `sim_trial_state` · `live_observation_block` · `live_promotion_result` · `mode_startup` · `sim_opening_result`) ·
//    `SettingsResultCodes` +2 · `DecisionReasonCodes` += `LIVE_EXECUTE_PROMOTION`(엔진 E15e2 #161) ·
//    받침대 메서드 1 · 🆕 C-53 · 픽스처 248 → 256(신설 8) — 🆕 tool/gen_r6c_v119_fixtures.py(기준 = M2 밑동 원문에서 멱등).
//    엔진 다음 계약 판 = 1.20.0(E13i1 `SafetyActions`·거부 코드·라우트 3·`GaugeCodes`·생체 포트 · E13i2 VM · E14i 코드·동작·`ResumeGateVm` ·
//    fill-origin · `simToAuto` 표본 · 픽스처 정정 F1~F8 · 이름 붙은 알림 — 06 변경 이력 «2026-11-14 · 계약 v1.19») —
//    🆕 v1.20 이 R7 선행 + 겹침 몫으로 번호를 가져갔다 · 엔진 덩어리 = 1.21.0(아래).
// 🆕 '1.20.0'(R7 선행 + 엔진 겹침 몫 · 01 §29 · 발주자 위임 2026-11-14 — 권고대로 · K1~K39) — M9 S02 증권사 키 · S06 기기·접근 · S03 계좌 매핑 표시·동작 계약:
//    `CredentialListVm` += `modeNotice`·`leakRunbookLink`·`lockedLabel`·`asOf` · `CredentialCardVm` += `level`·`lastVerifiedText`·`requirementLabel`·
//    `whyLine`·`sealLabel`·`credentialSlotId`·`verifyAction`·`rotateLink`(키 조각 0 · 1단) · `DeviceAccessVm` += `leaseLevel`·`leaseEpochText`·
//    `migrationLink`·`pairing`·`emptyLabel`·`lockedLabel` · `DeviceRow` += `level`·`revokeAction`·`revokeConfirmText` · 🆕 `PairingTicketCard` ·
//    🆕 dto/accounts.dart — `AccountMappingVm`·`AccountRow`·`SleeveMappingRow`·`AccountMappingOption`(K39 — v1.12 `AccountOption` 과 이름 겹침 회피) ·
//    `SettingsRepository.watchCredentials`·`watchAccountMapping` · 라우트 81(`m4KeyRotation`) · R7 args 5 · 사전 +2(`credential_kind` — 엔진
//    `KisKeySet.wire` 겹침 · `settings_slot`) · `SettingsResultCodes` +3 · 받침대 메서드 2 · 🆕 C-54 · 픽스처 256 → 271(신설 15 · 개정 1 —
//    온보딩 `KIS_MOCK` → `KIS_PAPER`) — 🆕 tool/gen_r7_v120_fixtures.py(기준 = M2 밑동 원문에서 멱등 생성).
//    엔진 다음 계약 판 = 1.21.0(E15i 코드 등재 모음 · E13i1 `SafetyActions`·거부 코드·라우트 3·`GaugeCodes`·생체 포트 · E13i2 VM · E14i ·
//    E16i(13 R112 D21) · fill-origin · `simToAuto` 표본 · 픽스처 정정 F1~F8 · 이름 붙은 알림 — 창 = R7a 병합 뒤 · R7b 발송 전 ·
//    06 변경 이력 «2026-11-15 · 계약 v1.20») — 🆕 v1.21 이 포트·킬스위치·서약 몫을 실었다 · 나머지 = 1.22.0 · 1.23.0+(아래).
// 🆕 '1.21.0'(엔진 예고 1/2 · 01 §30 · 발주자 위임 2026-11-14 — 권고대로 · K1~K47) — M5 안전 쓰기 포트 + 체험 길:
//    🆕 commands/safety_actions.dart — `SafetyActions`(넷째 쓰기 창구 · 폰 전용 · `ui_safety` 만 · 표면 run·runKillResumeItem·
//    runPledge·watch) · `SafetyActionResult` · `SafetyActionCall` · `KillResumeItemSubmission` · `PledgeSubmission` ·
//    🆕 `SafetyActionId`(KILL_SWITCH_RESUME · PLEDGE_WRITE · PLEDGE_EDIT — run 화이트리스트 0) · `KillChecklistAck` += `activation` ·
//    🆕 `KillActivationRecord` · 열거 4(`KillActivationReason` · `KillActivationScope` · `KillResumeScenario` · `KillResumeCondition`) ·
//    🆕 dto/safety_gate.dart — `KillResumeGateVm`·`KillResumeItemRow`·`KillResumeChoice`·`PledgeVm` · 창구 2(`KillSwitchGateRepository` ·
//    `PledgeRepository`) · 라우트 84(`m5StoppedDecision`·`m5Pledge`·`m5RuleChangeGate`) · 사전 +4(`kill_switch_result` 12 ·
//    `safety_common_result` 2 · `pledge_result` 6 · `gauge` 4) · 받침대 3 · 🆕 C-55 · C-16 정정 · 픽스처 271 → 283(신설 12 · 개정 1 —
//    F3 `safety_states` L0 → L1) — 🆕 tool/gen_v121_fixtures.py(기준 = M2 밑동 원문에서 멱등 생성).
//    엔진 다음 계약 판 = 1.22.0(E13 나머지 — STOPPED·postmortem·개입·규칙 변경·재량·RECON 해제 · 사다리 · E14i 전량 ·
//    E15i 남은 굳은 몫(simToAuto 코드·단계·세션·결정 사유·위저드 동작·표본·가상 체결·모드 표지) · fill-origin · `resume_mode` · F8 ·
//    01 §6-7 — 창 = R7b 병합 뒤 · R7c 발송 전) · 1.23.0+(E16i · 엔진 문구 0 VM 3 · 이름 없는 알림 · 승격 세션 종류 ·
//    PNG 흔드는 F1·F2·F4~F7 — 굳는 대로) · 06 변경 이력 «2026-11-15 · 계약 판 나눔» — 🆕 v1.22 가 1.22.0 몫을 실었다 ·
//    나머지 = 1.23.0+(아래).
// 🆕 '1.22.0'(엔진 예고 2/2 · 01 §31 · 발주자 위임 2026-11-14 — 권고대로 · K48~K71) — M5 나머지 + X2 재개 + simToAuto + DDL 글자:
//    `SafetyActionId` +8(STOPPED_DECISION · INCIDENT_POSTMORTEM · RECON_CLEAR · INTERVENTION_STEP · DISCRETION_ADJUST ·
//    RULE_CHANGE_CANCEL · RULE_CHANGE_APPROVE · SEASONAL_WINDOW_CHOICE) · `SafetyActions` 표면 8(+ runStoppedDecision · runPostmortem ·
//    runRuleChangeApproval · runDiscretionAdjust · run 화이트리스트 4) · 제출 DTO 4 · 열거 3(`StoppedDecisionChoice` · `InterventionStepOutcome` ·
//    `SeasonalEntryChoice` — 🔴 타입 이름 ≠ 엔진) · 🆕 `BreakerLadderVm` · `ResumeGateVm` + 창구 2 · 받침대 3 · 사전 +12(E13 5 · E14i 3 ·
//    E15i 4) + 확장 4(`PlannedWorkKindCodes` · `GapReasonCodes` · `DecisionReasonCodes` · `BrokerRawCodes`) · `ModeMarkerText` ·
//    `SettingsActionId` handover +3 · 🆕 `KillChecklistSubmission`(`confirmKillChecklist` 인자 교체 — 미결 183 ⓐ) ·
//    `LedgerModeCheck.fillOrigin`(⏸ 태그 줄 = 엔진 재생성 PR) · DDL `resume_run_mirror.resume_mode` · 🆕 C-56 · 픽스처 283 → 298
//    (신설 15 · 개정 2 — F8 `resume_report_1` · `m9/handover_states` SIM_TO_AUTO) — 🆕 tool/gen_v122_fixtures.py.
//    엔진 다음 계약 판 = 1.23.0+(E16i · 엔진 문구 0 VM 3 · 이름 없는 알림 · 승격 세션 종류 · PNG 흔드는 F1·F2·F4~F7 ·
//    M5-1 폼 VM(미결 186) · M5-11 위저드 VM(미결 187) · `RuleChangeCategory` · postmortem·재량 원천 VM(미결 188) — 굳는 대로) ·
//    06 변경 이력 «2026-11-17 · 계약 v1.22» — 🆕 1.23.0 은 R8a 월 납입 몫이 가져갔다 · 엔진 예약 = 1.24.0+(아래).
// 🆕 '1.23.0'(R8a 선행 · 01 §32 · 발주자 위임 2026-11-14 — 권고대로 · K74~K103) — M9 `S13` 월 납입 설정:
//    `MonthlyContributionVm` 추가형(asOf · lockedLabel · changeLabel · editable = ui 미참조 표식) · 🆕 `SettingsRepository.watchContribution()` ·
//    🆕 `ContributionUpdateSubmission{amountInput 원문}` + `SettingsActions.runContributionUpdate`(표면 run·runContributionUpdate·watch — C-7) ·
//    🆕 `ContributionResultCodes` 6(엔진 `ContributionRejectCodes` 7 − 공용 `TRUSTED_TIME_UNKNOWN` · 🔴 타입 이름 ≠ 엔진) · 받침대 +2 ·
//    🆕 C-57 · 픽스처 298 → 305(신설 7 — `m9/monthly_contribution*` 6 · `m9/contribution_action_results`) — 🆕 tool/gen_r8_v123_fixtures.py.
//    다음 판 = 1.24.0(S04 창 — 엔진 결정 대기 01 §8 미결 190~194 · 엔진 예약 E16i · 엔진 문구 0 VM 3 · 이름 없는 알림 · 승격 세션 종류 ·
//    PNG 흔드는 F1·F2·F4~F7 · M5-1 폼 VM(미결 186) · M5-11 위저드 VM(미결 187) · `RuleChangeCategory` · E13 원천 VM(미결 188) 중
//    먼저 굳는 쪽 · 나머지 = 그 다음 번호) · 06 변경 이력 «2026-11-17 · 계약 v1.23» — 🆕 1.24.0 은 R9 세 화면 몫이 가져갔다 ·
//    나머지 = 1.25.0+(아래).
// 🆕 '1.24.0'(R9 선행 · 01 §33 · 발주자 위임 2026-11-14 — 권고대로 · K104~K143) — M9 `S09` 백업·복원 · `S10` 진단 · `S12` 연간 리뷰 목차:
//    `BackupVm` 교체(소비자 0) + 🆕 `RestorePointRow` · 🆕 `DiagnosticsScreenVm` + `SelfTestCard`(감싸개 — `DiagnosticsVm` 무변경) +
//    🆕 `SettingsRepository.watchDiagnosticsScreen()` · 🆕 `AnnualReviewIndexVm`(`OpsStatusRepository.watchAnnualReview` 반환 교체 · 이름 그대로 ·
//    세후·수치 칸 0) · args `backupRunNow`·`selftestGoldenRun`·`selftestIntegrityRun` = `{}` · 🆕 `BackupResultCodes` 8(`take` 경로) ·
//    `LedgerIntegrityResultCodes` 7(E13c1 · 🔴 타입 이름 ≠ 엔진) · C-5 도메인 간 중복 +2 · 받침대 · 🆕 C-58 · 픽스처 305 → 322(신설 17) —
//    🆕 tool/gen_r9_v124_fixtures.py. 🔴 S08(X4) · S11 = 이 판 0(⏸ R9d · R9e).
//    다음 판 = 1.25.0(E16i 나머지 + E16j 화면 · S04 창(01 §8 미결 190~194) · E13i2 VM 3 · 이름 없는 알림 · 승격 세션 종류 ·
//    PNG 흔드는 F1·F2·F4~F7 · M5-1 폼 VM(미결 186) · M5-11 위저드 VM(미결 187) · `RuleChangeCategory` · E13 원천 VM(미결 188) 중
//    먼저 굳는 쪽 · 나머지 = 그 다음 번호) · 06 변경 이력 «2026-11-18 · 계약 v1.24».
// 🆕 '1.25.0'(트랙 B 선행 · 01 §34 · 발주자 위임 2026-11-14 — 권고대로 · K144~K165) — 모의 체험 ④ X2 재개 · ⑤ 킬스위치 필수 화면:
//    🆕 `M5-1` `KillSwitchScreenVm`(+ `KillCancelRow` · 발동 뒤 기록 폼 `KillActivationFormVm`·`KillActivationItemRow`·`KillActivationChoice` —
//    01 §8 미결 186 닫음) · `KillSwitchGateRepository.watchKillSwitch()` · 🆕 `M5-5` `BlockBoardVm`·`BlockBoardRow` + 🆕 `BlockBoardRepository`
//    (사다리 `M5-4` · 게이지 `M5-7` 감싸기) · 🆕 X2 `ResumeReportVm` + `ResumeGateRepository.watchReport()`(`ResumeReport` 무변경) ·
//    `CommandApi.activateKillSwitch()` 인자 0(화면 기기 id·사유 0) · 🆕 `KillCancelOutcomeCodes` 5(엔진 wire · 🔴 타입 이름 ≠ 엔진) ·
//    `OpsSlotIds.killSwitch` · 받침대 · 🆕 C-59 · 픽스처 322 → 339(신설 17) — 🆕 tool/gen_trackb_v125_fixtures.py.
//    다음 판 = 1.26.0(M5-11 위저드 VM(미결 187 · 01-08 전 창) · RECON 해제 동작·E13 원천 VM(188 남은 몫) · E13i2 VM 3 ·
//    E16i 나머지 + E16j · S04 창(190~194) · 이름 없는 알림 · 승격 세션 종류 · PNG F1·F2·F4~F7 · `RuleChangeCategory` 중
//    먼저 굳는 쪽 · 나머지 = 그 다음 번호) · 06 변경 이력 «2026-11-19 · 계약 v1.25».
// 🆕 '1.26.0'(트랙 C 선행 · 01 §35 · 발주자 위임 2026-11-14 — 권고대로 · K166~K186) — 실전 커밋 필수 3묶음 + 사전 저널 꼴:
//    🆕 `M5-11` `HandoverWizardVm`·`HandoverWizardStepRow`(`HandoverStep` 감싸기 · 동작 = 기존 `SettingsActionId` · 세션 id = 엔진이 args 에 ·
//    01 §8 미결 187 닫음) + 🆕 `HandoverRepository.watchWizard()` · `handoverStatus` = 같은 본문(C-33 소유 +1) ·
//    🔴 SAF-405 첫 승인 최소판 `M5-9` 🆕 `RuleChangeGateVm`·`RuleChangeCandidateRow`·`RuleChangeQueueRow` + 🆕 `RuleChangeGateRepository` ·
//    🆕 `SafetyActionId.ruleChangeRequest` · `RuleChangeRequestSubmission` · `SafetyActions.runRuleChangeRequest`(냉각 30일·SAF-405 무변경) ·
//    🔴 RECON 해제 `BlockBoardRow.reconClear`(추가형) · 🆕 `ReconClearForm`·`ReconOriginChoice` · `ReconClearSubmission` ·
//    `SafetyActions.runReconClear`(표면 8 → 10) · `run` 화이트리스트에서 `reconClear` 뺌 · 🆕 `ReconClearResultCodes` 3(엔진 예고) ·
//    사전 저널 꼴 ⓐ(제출 DTO 3필드 + 구현이 id + 한 트랜잭션) · 받침대 +2 · 🆕 C-60 · 픽스처 339 → 359(신설 20) —
//    🆕 tool/gen_trackc_v126_fixtures.py.
//    다음 판 = 1.27.0(서약 편집(01 §8 미결 208 뒤) · 규칙 변경 CHANGELOG · `RuleChangeCategory` · 둘째 승인부터 창·DD 글자 · 개입 ·
//    재량 · postmortem 목록 · M5-3 STOPPED VM · `SIM_TO_AUTO_CONFIG_NOT_APPROVED` 등재 · S04 보기 VM(192 뒤) · E16i/E16j ·
//    이름 없는 알림 · PNG F1·F2·F4~F7 중 먼저 굳는 쪽 · 나머지 = 그 다음 번호) · 06 변경 이력 «2026-11-20 · 계약 v1.26».
// 🆕 '1.27.0'(E3d 계약 창 · 01 §36 · 발주자 위임 2026-11-14 — 권고대로 · K187~K195) — 엔진 등재 대기 알림 5 등재(`kAlertLevels` 표 밖 0):
//    🆕 `AlertCodes.safetyWarn` 4(`DEFENSIVE_FLOOR_BREACHED` · `GOLD_SHARE_HIGH` · `FINANCIAL_INCOME_CAP_EXCEEDED` · `KRW_LIQUIDITY_LOW` —
//    04 §1 Level 3 · §5-3 v2.46 · 엔진 E3d) · 🆕 `AlertCodes.derivedSync` 1(`DERIVED_FORK` — 04 §5-3 v2.45 · E16i 의 알림 몫만) ·
//    `values` 31 → 36 · 등급 = 주석 «잠정»(등급 사전 0 조문 그대로) · SAF-307 «초과 일수» = 계약 칸 0(월간 리포트 `D2_ALLOCATION`
//    메모 = 엔진 문자열 · 13항목 불변 C-25 · 01 §8 미결 209) · 🆕 C-61 · 픽스처 359 → 360(신설 1) — 🆕 tool/gen_e3d_v127_fixtures.py.
//    다음 판 = 1.28.0(v1.26 예고 «다음 판 = 1.27.0» 목록을 그대로 이어받는다 — 서약 편집(미결 208 뒤) · 규칙 변경 CHANGELOG ·
//    `RuleChangeCategory` · 둘째 승인부터 창·DD 글자 · 개입 · 재량 · postmortem 목록 · M5-3 STOPPED VM ·
//    `SIM_TO_AUTO_CONFIG_NOT_APPROVED` 등재 · S04 보기 VM(192 뒤) · E16i 나머지/E16j · 이름 없는 알림 · PNG F1·F2·F4~F7 중
//    먼저 굳는 쪽 · 나머지 = 그 다음 번호) · 06 변경 이력 «2026-11-20 · 계약 v1.27».
// 🆕 '1.28.0'(S04 첫 판 · 01 §37 · 발주자 위임 2026-11-14 — 권고대로 · K196~K207) — M9 `S04` 배분 화면 보기 전용:
//    🆕 `AllocationEditorVm`·`AllocationProfileCard`·`AllocationReadOnlySection`·`AllocationReadOnlyRow`(엔진 `AllocationView` 칸 1:1 ·
//    판정·잠김·빈 칸 0) · 🆕 `SettingsRepository.watchAllocationEditor()`(폰 · 뷰어) · 🆕 `AllocationRowCodes` 10(`allocation_row`) ·
//    🆕 `AllocationReadModelColumns` 7(`rm_config_view` 배분 열 · 01 §6-4 · 🔴 타입 이름 ≠ 엔진) · 받침대 +1 · 🆕 C-62 ·
//    픽스처 360 → 362(신설 2 — `m9/allocation_editor` · `_stale`) — 🆕 tool/gen_s04_v128_fixtures.py.
//    다음 판 = 1.29.0(v1.27 예약 목록 그대로 — 서약 편집(미결 208 뒤) · 규칙 변경 CHANGELOG · `RuleChangeCategory` · 둘째 승인부터 창·DD 글자 ·
//    개입 · 재량 · postmortem 목록 · M5-3 VM · `SIM_TO_AUTO_CONFIG_NOT_APPROVED` 등재 · S04 편집기 판(미결 190 · 191 · 194) · E16i/E16j ·
//    이름 없는 알림 · PNG F1·F2·F4~F7 중 먼저 굳는 쪽) · 06 변경 이력 «2026-11-20 · 계약 v1.28».
// 🆕 '1.29.0'(E11k-b 계약 창 · 01 §39 · 발주자 위임 2026-11-14 — 권고대로 · K223~K236 · 🔴 E16i 사전(01 §38)보다 먼저 —
//    12-08 SAF-405 첫 승인 요청 창 전 신뢰 시각) — Supabase 연결 · 신뢰 시각 · 리스:
//    🆕 `OnboardingSlotIds.supabaseConnect` = `SECRET_SUPABASE_CONNECT`(o_07 ② · 검증 = 기존 `connectionTest{target: SUPABASE}` · 1단 — 통과 = 금고) ·
//    🆕 `labels/supabase_codes.dart` `SupabaseInputResultCodes` 6 · `SupabaseTimeResultCodes` 8(엔진 enum 1:1 · 와이어 = 계약) ·
//    `LeaseRpcResultCodes` 5(`LEASE_INVALID` = v1.18 `JournalReasonCodes` 한 벌 · 새 사전 0) · 🆕 `schema/supabase_rpc.dart`
//    리스 RPC 표(이름 3 · 인자 5 · 반환 칸 3 · 🔴 `server_now` 0) · DDL `app_device.auth_uid`(D5) · RPC 서명 주석 · R-01 로그인 주석 정정 ·
//    🔴 o_07 VERIFIED = 쓰기-읽기 왕복 뒤(첫 판 = `IN_PROGRESS` 중간 상태) · 알림 · config 키 = 엔진 E11k-f 제안 뒤 · 🆕 C-64 ·
//    픽스처 363 → 365(신설 2 — `m8/onboarding_step_detail_supabase` · `m8/onboarding_supabase_connect_results`) —
//    🆕 tool/gen_e11k_v129_fixtures.py.
//    다음 판 = 1.30.0(🔴 E16i 계약 창 — 01 §38 · 설계 끝 · 이 판 병합 뒤 번호만 1.30.0) · 그다음 = E16j 화면 계약(01 §8 미결 211) ·
//    v1.28 예약 목록 나머지 · 06 변경 이력 «2026-11-2x · 계약 v1.29».
// 🆕 '1.30.0'(E16i 계약 창 · 01 §38 · 발주자 위임 2026-11-14 — 권고대로 · K209~K222 · 설계가 v1.29 보다 먼저 · 번호 = 병합 차례) —
//    X1 기기 이전 · X5 정정의 엔진 글자 사전: 🆕 `labels/migration_codes.dart` 21무리 · `labels/repair_codes.dart` 4무리 = 상수 103
//    (거부 · 막음 44 · 열거 글자 59 · 엔진 1:1 − 공용 `TRUSTED_TIME_UNKNOWN` − `BackupResultCodes` 한 벌 · 🔴 타입 이름 ≠ 엔진) ·
//    `byDomain` 76 → 101 · 🆕 `SafetyHoldCodes` `MIGRATION_IN_PROGRESS`(표시 hold) · C-5 문서 중복 7 → 15 · 🆕 C-63 · 엔진 대조 시험 2 ·
//    DTO · VM · 창구 · 라우트 0 · 픽스처 365 그대로(신설 0 · 버전 줄만) — 🆕 tool/gen_e16i_v130_fixtures.py.
//    다음 판 = 1.31.0(🔴 첫 후보 = E16j 화면 계약 — VM · 정정 명령 · 라우트 인자 · 01 §8 미결 211 · 그 밖 v1.28 예약 목록 그대로) ·
//    06 변경 이력 «2026-11-2x · 계약 v1.30».
// 🔴 '1.0.0' 은 «⚠️ M2-8 이름 미확정이 코드에서 사라졌다»는 뜻이지 «미결이 0건»이라는 뜻이
//    아니다. `docs/m2-8_naming.md` 의 ⏸ 22행은 **이름만 확정**이고 그 기능은 여전히 대기다
//    (01 §8). ⏸ 항목에 걸린 화면은 계속 «픽스처 고정 모드»다.

/// 이 패키지가 표현하는 M2 계약의 버전.
const String contractVersion = '1.30.0';

// ════════════════════════════════════════════════════════════════════════════
// G-36 버전 스탬프 3필드 — `rm_config_view` 가 push 때마다 함께 갱신하는 값
// ════════════════════════════════════════════════════════════════════════════
// 01 §6-4 `rm_config_view` 는 `schema_version`(배치 DDL 번호) ·
// `hash_format_version`(X5-1 정규 직렬화 규약) · `contract_version`(이 파일) 셋을 싣는다.
// 뷰어는 **자기 빌드에 컴파일된 값**과 그 셋을 비교해 `ok`/`degraded`/`incompatible` 을
// 판정한다(04 §2-4 스키마 버전 게이트의 유일한 입력). 🔴 판정 문자열도 엔진이 준다.
// 🔴 이 행을 못 읽는 경우(표 부재·RLS 거부)는 `ok` 가 아니라 **`incompatible`** 이다 —
//    잘못 그리는 것보다 안 그리는 것이 안전하다.
//
// ✅ **값이 배정됐다(계약 v1.9.0 · 2026-10-21 · 설계 13 §8 R19 E9-10·E9-11).**
//    ⓐ `schema_version` = 02 기본 + 배치 A·B·C·F 를 한 판으로 만든 첫 스키마(01 §6-0). SPEC 개정 번호
//       (v2.33)와는 다른 축이다. 🔴 v1 은 첫 실기기 설치 때 얼리고, 그 전의 v1 수정은 번호를 바꾸지
//       않는다(R20 Q0) — 그 뒤 변경은 2.
//    ⓑ `hash_format_version` = 배치 F 의 `executions` 11컬럼을 포함한 정규 직렬화의 첫 판. 해시 체인
//       구현·해시 든 골든이 아직 없어 올릴 옛 값도 다시 고정할 것도 없다.
//    🔴 이 두 값을 바꾸는 커밋은 `ddl/README` 규약 3·6 과 뷰어 게이트(G-36)를 함께 움직인다.

/// 로컬 SQLite 스키마 번호(`schema_version` 표의 행 · `rm_config_view.schema_version`).
const int schemaVersion = 1;

/// X5-1 정규 직렬화 규약 번호(`ledger_daily_hash.hash_format_version` · `rm_config_view`).
const int hashFormatVersion = 1;

// ════════════════════════════════════════════════════════════════════════════
// `config_hash` 의 자리 — 🔴 여기 상수로 두지 않는다
// ════════════════════════════════════════════════════════════════════════════
// `config_hash` 는 **엔진이 런타임에 만드는 값**이고, 계약에서는 DTO 필드로만 흐른다:
//   `DecisionRef.configHash` · `FeatureFlags.configHash` · `TriggerSnapshot.configHash` ·
//   `AfterTaxLadder.configHash` · `DepositPlan.configHash` · `HandbookIndex.configHash` ·
//   `CalendarEventDto.configHash` · 픽스처 봉투 `meta.config_hash`.
// 🔴 빌드 시점 상수를 두면 화면이 «지금 보고 있는 값»과 «컴파일된 값»을 비교하기 시작하고,
//    그 비교는 엔진의 판정을 화면이 재구현하는 것이다(경계 규칙 ①).
// 🔴 픽스처의 `config_hash` 는 `cfg_fake_…` 로 시작하는 **합성값**이며(01 §5 봉투),
//    C-13 이 픽스처의 값과 핸드북 메타의 값이 어긋나면 실패시킨다.
// 🔴 `operating_param_log`(월 납입 운영값)는 전략 `config_hash` 에 **들어가지 않는다**
//    (01 §6-2 — 골든벡터 불변).
