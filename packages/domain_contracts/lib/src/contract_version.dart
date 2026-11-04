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
//    1.4.0 상향 때 122개 · 1.5.0 상향 때 126개 · 1.6.0 상향 때 135개 · 1.7.0 상향 때 141개 · 1.8.0 상향 때 159개 · 1.12.0 상향 때 174개 · 1.13.0 상향 때 176개 · 1.14.0 상향 때 176개) — 한쪽만 올리면 C-1·C-15 가
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
//    엔진 다음 계약 판 = 1.18.0(13 §8 R55 E13i1·i2 · E11d X12 등 «계약 창» 몫 · 06 변경 이력).
// 🔴 '1.0.0' 은 «⚠️ M2-8 이름 미확정이 코드에서 사라졌다»는 뜻이지 «미결이 0건»이라는 뜻이
//    아니다. `docs/m2-8_naming.md` 의 ⏸ 22행은 **이름만 확정**이고 그 기능은 여전히 대기다
//    (01 §8). ⏸ 항목에 걸린 화면은 계속 «픽스처 고정 모드»다.

/// 이 패키지가 표현하는 M2 계약의 버전.
const String contractVersion = '1.17.0';

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
