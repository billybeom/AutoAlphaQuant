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
//    1.4.0 상향 때 122개 · 1.5.0 상향 때 126개 · 1.6.0 상향 때 135개 · 1.7.0 상향 때 141개 · 1.8.0 상향 때 159개) — 한쪽만 올리면 C-1·C-15 가
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
// 🔴 '1.0.0' 은 «⚠️ M2-8 이름 미확정이 코드에서 사라졌다»는 뜻이지 «미결이 0건»이라는 뜻이
//    아니다. `docs/m2-8_naming.md` 의 ⏸ 22행은 **이름만 확정**이고 그 기능은 여전히 대기다
//    (01 §8). ⏸ 항목에 걸린 화면은 계속 «픽스처 고정 모드»다.

/// 이 패키지가 표현하는 M2 계약의 버전.
const String contractVersion = '1.8.0';

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
// ⛔ **`schemaVersion`·`hashFormatVersion` 상수를 여기 두지 않는다 — 아직 값이 없다.**
//    ⓐ `schema_version` 번호는 «배치 A~F 마이그레이션 창 전체에 하나만» 배정되며(01 §6-0·§6-5)
//       그 번호가 아직 배정되지 않았다. §6-0 은 「`00_SPEC §9` 최신값 +1 을 쓰되 v2.31(P0S)
//       소비 여부를 먼저 확인」이라고만 정했다.
//    ⓑ `hash_format_version` 은 배치 F 가 `executions` 에 11컬럼을 더하면서 **올리고 골든벡터를
//       다시 고정**해야 하는 값이다(01 §6-6 말미). 새 값도 골든도 아직 없다.
//    🔴 둘 중 어느 것이든 임의의 숫자를 상수로 박으면 뷰어의 버전 게이트가 **틀린 판정을
//       조용히 통과시킨다**(없는 것보다 나쁘다). 값이 배정되는 커밋에서 함께 넣는다.

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
