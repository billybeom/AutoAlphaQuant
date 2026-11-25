# `contracts_bundle.md` — `domain_contracts` 공개 API 원문 (웹 채팅 첨부용)

> **저장소를 클론할 수 있으면 이 파일을 쓰지 마십시오.** 실제 코드(`packages/domain_contracts/`)가
> 최종 정본이고, 이것은 그 시점의 **사본**입니다. 웹 채팅처럼 저장소를 붙일 수 없는 자리에만 씁니다.
>
> 담은 것 = 배럴 `lib/domain_contracts.dart` + `lib/src/**/*.dart` 중 **생성물 제외** 원문
> (`*.freezed.dart`·`*.g.dart`는 `build_runner` 산출물이라 뺐습니다 — 필요하면 저장소에서 생성합니다).
> 담지 않은 것 = 픽스처 JSON · 계약 테스트 · DDL · 엔진 명세 · 청사진 HTML.
>
> 파일 135개 · 계약 v1.40.0 · 조립일 2026-11-25(`python tool/make_contracts_bundle.py`). 각 절의 제목이 저장소 기준 파일 경로입니다.


---

## `packages/domain_contracts/lib/domain_contracts.dart`

```dart
// domain_contracts — M2 도메인 계약의 공개 진입점(배럴).
//
// 🔴 화면(ui_*)이 import 하는 파일은 이것 하나다. lib/src/ 아래를 직접 import
//    하지 않는다 — 내부 구조를 바꿀 때 화면이 조용히 깨진다(인벤토리 §0).
// 🔴 **이 파일은 통합 담당만 편집한다.** 영역 구현자는 자기 폴더에 파일을
//    더하고, 그 폴더의 재수출 창구(`src/<영역>.dart`)에 통합 단계가 줄을 넣는다.
//
// 창구 10개 — 영역 A(primitives·enums) · B·C(dto) · D(repositories·commands) ·
// E(labels·contract_version) · F(fixtures) · G(navigation — 🆕 v1.1) ·
// H(schema — 🆕 v1.9 로컬 원장 두 파일 · SIM 판 파생). 어느 창구에 무엇이 있는지는
// 각 `src/<영역>.dart` 머리 주석과 `docs/contracts_inventory.md` 가 정본이다.
//
// ⚠️ 아직 여기에 없는 것(= 계약에 아직 존재하지 않는 것)은 각 영역의 인계
//    사항에 사유와 함께 적혀 있다. 대표적으로 `LedgerEventKind`/
//    `LedgerEventRecord`(결정 ㊲ 대기 · M2-8 A-15·J-6) · `SplitExecutionLeg`
//    (M2-8 C-11) · `AllocationEditorVm`
//    (~~M2-8 §G 표 미등재 · S04 창 — 엔진 결정 대기 · 01 §8 미결 190~194~~ → 🆕 v1.28 01 §37 등재 — 첫 판 보기 전용 · 편집 칸 = 편집기 판)이다. 🆕 v1.17(01 §26) — `IncidentBanner`·`Runbook`·긴급정지 카드는 이름이 확정돼
//    들어왔다(`dto/incident.dart`).
//    🆕 v1.18(01 §27) — `S01`·`S07` 계약 확정(`SettingsHomeVm` 교체 · `SettingsRepository`).
//    🆕 v1.19(01 §28) — `S05` 계약 확정(`OperationsVm` · 부품 8 · `watchOperations`).
//    🆕 v1.20(01 §29) — `S02`·`S06`·`S03` 계약 확정(`CredentialListVm` 추가형 · `DeviceAccessVm` 추가형 + `PairingTicketCard` ·
//    🆕 `AccountMappingVm` · `watchCredentials`·`watchAccountMapping`).
//    🆕 v1.23(01 §32) — `S13` 월 납입 계약 확정(`MonthlyContributionVm` 추가형 · `watchContribution` · `ContributionUpdateSubmission` · `runContributionUpdate` · `ContributionResultCodes`).
//    🆕 v1.24(01 §33) — `S09`·`S10`·`S12` 계약(`BackupVm` 교체 · `RestorePointRow` · `DiagnosticsScreenVm` · `SelfTestCard` · `AnnualReviewIndexVm` ·
//    `watchDiagnosticsScreen` · `BackupResultCodes` · `LedgerIntegrityResultCodes`).
//    🔴 화면이 대신 지어내지 않는다 — 이름이 확정된 뒤 계약에 들어온다.

export 'src/biometric_prompt_text.dart'; // 🆕 v1.39 영역 E — 생체 대화상자 글자(사전 아님 · 01 §48 K350)
export 'src/commands.dart';
export 'src/contract_version.dart';
export 'src/dto.dart';
export 'src/enums.dart';
export 'src/fixtures.dart';
export 'src/labels/labels.dart';
export 'src/mode_marker_text.dart'; // 🆕 v1.22 영역 E — 표지 글자(사전 아님 · 01 §31 K67)
export 'src/navigation.dart';
export 'src/primitives.dart';
export 'src/repositories.dart';
export 'src/schema/ledger_file.dart';
export 'src/schema/read_model_columns.dart'; // 🆕 v1.28 — rm_config_view S04 배분 7열(01 §37 K201)
export 'src/schema/read_model_tables.dart'; // 🆕 v1.36 — 읽기 모델 rm_* 표 22 · 열 · 키 · 형 · 결속 DTO(01 §45 K303 · 지도 D15)
export 'src/schema/supabase_rpc.dart'; // 🆕 v1.29 — operator 리스 RPC 표(01 §39 K228 · 지도 X18)
```

---

## `packages/domain_contracts/lib/src/biometric_prompt_text.dart`

```dart
// 🆕 계약 v1.39(01 §48 · K350 · 01 §8 미결 238 · 리뷰 3차 A-3) — OS 생체 대화상자 글자(목적마다 한 벌).
// 🔴 표지 글자 상수라 C-5 사전 대상(`lib/src/labels/`) 밖에 둔다(`ModeMarkerText` 선례 · byDomain 0).
// 🔴 무엇에 동의하는지 그대로 말한다 — 서약 글자는 [BiometricPurpose.pledgeSign] 에만 · 실주문을 켜는 동작은 «실제 주문»을 말한다.
// 🔴 금액 · 계좌 · 종목 · 수치 0(대화상자는 잠금 화면 위에도 뜬다).
// 🔵 서약 글자 = 엔진 core `BiometricSignTexts.promptTitle` · `promptSubtitle`(R159) 와 같은 글자 — 조립 배선 카드가 엔진을 이 상수로 옮긴다.

import 'enums/biometric.dart';

/// 생체 대화상자 한 벌(제목 · 설명).
final class BiometricPrompt {
  const BiometricPrompt(this.title, this.subtitle);

  /// 대화상자 제목.
  final String title;

  /// 대화상자 설명(한 문장).
  final String subtitle;
}

/// 목적 → 대화상자 글자.
abstract final class BiometricPromptText {
  /// 취소 버튼(목적 공통).
  static const String cancel = '취소';

  /// `O-04` ③ 서약 서명.
  static const BiometricPrompt pledgeSign = BiometricPrompt(
    '서약에 생체로 서명',
    '방금 쓴 서약 세 문장을 이 폰의 생체 인증으로 확인합니다.',
  );

  /// `M5-11` 실전 전환 시작.
  static const BiometricPrompt handoverStart = BiometricPrompt(
    '실전 전환 시작',
    '모의 운영을 마치고 실전 계좌로 옮기는 전환을 시작합니다. 확정 전까지 실제 주문은 나가지 않습니다.',
  );

  /// `S05` 실전 집행 승격.
  static const BiometricPrompt livePromotion = BiometricPrompt(
    '실제 주문 켜기',
    '관찰을 마치고 다음 회차부터 실전 계좌에 실제 주문을 내기 시작합니다.',
  );

  /// X1 기기 이전 — 새 폰에서 실거래 다시 열기.
  static const BiometricPrompt x1Migration = BiometricPrompt(
    '이 폰에서 운영 이어받기',
    '기기 이전을 마치고 이 폰에서 실거래를 다시 엽니다.',
  );

  /// 목적 → 글자(빠짐 0 — 새 목적 = 컴파일 실패).
  static BiometricPrompt of(BiometricPurpose p) => switch (p) {
    BiometricPurpose.pledgeSign => pledgeSign,
    BiometricPurpose.handoverStart => handoverStart,
    BiometricPurpose.livePromotion => livePromotion,
    BiometricPurpose.x1Migration => x1Migration,
  };
}
```

---

## `packages/domain_contracts/lib/src/commands.dart`

```dart
// 영역 D 재수출 창구 — 명령 API·명령 인자·설정 액션(`lib/src/commands/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 화면이 상태를 바꾸는 경로는 여기 있는 것이 전부다. 리포지토리에는
//    쓰기 메서드가 없다(01 §4-1·§4-2).
// 🆕 v1.2 — 셋째 쓰기 창구 = 기기 로컬 초안 `DraftStore`(01 §12-1 · 원장·명령 쓰기가 아니다).
// 🆕 v1.21 — 넷째 쓰기 창구 = `SafetyActions`(M5 폰 로컬 · 01 §30).
//
// 근거: 01 §4-2·§4-3 · 인벤토리 §5-4.

export 'commands/command_api.dart';
export 'commands/command_context.dart';
export 'commands/command_receipt.dart';
export 'commands/command_state_machine.dart';
export 'commands/draft_store.dart';
export 'commands/drafts.dart';
export 'commands/payloads.dart';
export 'commands/payloads_x7.dart';
export 'commands/safety_actions.dart';
export 'commands/settings_actions.dart';
```

---

## `packages/domain_contracts/lib/src/contract_version.dart`

```dart
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
//    1.4.0 상향 때 122개 · 1.5.0 상향 때 126개 · 1.6.0 상향 때 135개 · 1.7.0 상향 때 141개 · 1.8.0 상향 때 159개 · 1.12.0 상향 때 174개 · 1.13.0 상향 때 176개 · 1.14.0 상향 때 176개 · 1.17.0 상향 때 240개 · 1.18.0 상향 때 248개 · 1.19.0 상향 때 256개 · 1.20.0 상향 때 271개 · 1.21.0 상향 때 283개 · 1.22.0 상향 때 298개 · 1.23.0 상향 때 305개 · 1.24.0 상향 때 322개 · 1.25.0 상향 때 339개 · 1.29.0 상향 때 365개 · 1.30.0 상향 때 365개 · 1.31.0 상향 때 367개 · 1.32.0 상향 때 375개 · 1.33.0 상향 때 390개 · 1.34.0 상향 때 390개 · 1.35.0 상향 때 393개 · 1.36.0 상향 때 393개 · 1.37.0 상향 때 398개 · 1.38.0 상향 때 398개 · 1.39.0 상향 때 402개 · 1.40.0 상향 때 402개) — 한쪽만 올리면 C-1·C-15 가
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
// 🆕 '1.31.0'(E11k-d2 계약 창 · 01 §40 · 발주자 위임 2026-11-14 — 권고대로 · K237~K246) — o_07 ③ Supabase 로그인:
//    🆕 `OnboardingSlotIds.supabaseLogin` = `SECRET_SUPABASE_LOGIN`(② 통과 뒤 같은 단계에서 ② 슬롯 대신 · VM 칸 추가 0) ·
//    🆕 `SettingsActionId.supabaseSignIn`(`SUPABASE_SIGN_IN` · args `{}` · 1단 — 통과 = 새로고침 토큰 금고) ·
//    🆕 `SupabaseAuthResultCodes` 6(`supabase_auth_result` · 엔진 `SupabaseAuthFailure` 12 가운데 고유 6 · 전송 6 = `SupabaseTimeResultCodes` 한 벌) ·
//    🔴 o_07 VERIFIED = 쓰기-읽기 왕복 뒤(로그인 통과 = 여전히 `IN_PROGRESS`) · 로그아웃 노출 = 0(미결 216) · 🆕 C-65 ·
//    픽스처 365 → 367(신설 2 — `m8/onboarding_step_detail_supabase_login` · `m8/onboarding_supabase_signin_results`) —
//    🆕 tool/gen_e11k_d2_v131_fixtures.py.
//    다음 판 = 1.32.0(🔴 첫 후보 = E16j 화면 계약 — 01 §8 미결 211 · 그 밖 v1.28 예약 목록 그대로) · 06 변경 이력 «2026-11-2x · 계약 v1.31».
// 🆕 '1.32.0'(E16j-a 계약 창 · 01 §41 · 발주자 위임 2026-11-14 — 권고대로 · K247~K263) — X5 정정 마법사(E16j 나눔 a · X1 = 1.33.0):
//    🆕 `RepairWizardVm` · `RepairOriginChoice` · `RepairStageRow` · `RepairCorrectionForm` · `RepairFillChoice`(`dto/repair.dart`) ·
//    🆕 `RepairWizardRepository.watchRepair({targetId})` · 🆕 라우트 `x5RepairTarget`(`/:targetId` · 84 → 85 · 허브 `x5RepairWizard` 그대로) ·
//    `SafetyActions` +3(`runRepairCorrect` · `runRepairBaseline` · `runInterventionJournal`) + 제출 DTO 3 · `SafetyActionId` +4
//    (`repairAccept` = `run{diff_id}` 화이트리스트 · 나머지 = 결과 id) · 🆕 `BaselineApplyResultCodes` 1 · 받침대 +4 · op stub 3 · 🆕 C-66 ·
//    픽스처 367 → 375(신설 8 — 🆕 폴더 `x5/`) — 🆕 tool/gen_e16j_a_v132_fixtures.py · 🔴 엔진 결속 · 후보 · 재대사 · VM 생산 = 미결 217.
//    다음 판 = 1.33.0(🔴 첫 후보 = E16j-b X1 화면 계약 — 미결 211 남은 몫 · 그 밖 v1.28 예약 목록 그대로) · 06 변경 이력 «2026-11-2x · 계약 v1.32».
// 🆕 '1.33.0'(E16j-b 계약 창 · 01 §42 · 발주자 위임 2026-11-14 — 권고대로 · K264~K281) — X1 기기 이전 화면(미결 211 닫음):
//    🆕 `X1PlanWizardVm` · `X1RecoveryVm` · `X1StepRow` · `X1TicketCard` · `X1FencingCard` · `X1ReissueRow` · `X1RestoreCard` · `X1GateCard`
//    (`dto/migration.dart` · D-03 = `EmergencyCardVm` 재사용) · 🆕 `MigrationRepository`(3 스트림) · 라우트 신설 0 · 인자 0(주석 정정만) ·
//    `SafetyActionId` +6(`x1PlanStart` · `x1PlanStep` · `x1PlanAbort` · `x1EmergencyStart` · `x1ReissueRecord` · `x1RecoveryStep` — 전부 `run`
//    화이트리스트 · 표면 무변경) · 🆕 `X1SlotIds` 4(`x1_slot`) · 받침대 +1 · 🆕 C-67 · C-5 필드 규칙 +4 ·
//    픽스처 375 → 390(신설 15 — 🆕 폴더 `x1/`) — 🆕 tool/gen_e16j_b_v133_fixtures.py · 🔴 VM 생산 · 단계 진행기 · 저장 · 백업 원천 = 미결 218.
//    다음 판 = 1.34.0(첫 후보 = v1.28 예약 목록 그대로) · 06 변경 이력 «2026-11-2x · 계약 v1.33».
// 🆕 '1.34.0'(미결 214 작은 계약 창 · 01 §43 · 발주자 위임 2026-11-14 — 권고대로 · K282~K289) — Supabase 신원 모델(D5) DDL 만:
//    `ddl/batch_d_supabase.sql` `app_device.auth_uid` = not null · 🔴 unique 0(X1 새 폰 = 같은 운영 사용자 · 13 R221 PGlite 실증) +
//    색인 `ix_app_device_auth_uid` · RLS 6 «`app_device` 조인»(JWT `app_metadata` 클레임 0 · 미결 13 닫음 · 두 명령 INSERT 정책 분리 유지) ·
//    `recovery_secret.algo` 기본값 'sha256' · C-64 ③ 정정 + ⑨ · Dart 공개 API · 픽스처 내용 0(버전 줄만 390) ·
//    🔴 data_sync 부트스트랩 사본 재생성(`tool/make_supabase_bootstrap.py`). 다음 판 = 1.35.0(첫 후보 = v1.28 예약 목록 그대로) ·
//    06 변경 이력 «2026-11-21 · 계약 v1.34».
// 🆕 '1.35.0'(쌓인 계약 숙제 창 · 01 §44 · 발주자 위임 2026-11-14 — 권고대로 · K290~K302) — 미결 217 꼬리 4 · 219 · J-3 쓰기 · 저널 kind:
//    🆕 `RepairInputResultCodes` 1(`repair_input_result` · `REPAIR_AMOUNT_INVALID` · `runRepairCorrect` 거부 합집합) ·
//    정정 체인 상한 = 운영 설정 `operations.amend_chain_max`(SPEC 02 §4 · 계약 상수 0) · 표본 `ledger_diffs_4` L-1 조치 링크 = 대상 라우트 ·
//    🆕 `DecisionJournalKinds` 8(`decision_journal_kind` · 개입 3단계 = `INTERVENTION_JOURNAL` · C-5 문서 중복 15 → 18) ·
//    `SafetyState` += `holdLabels`(짝 문장 · 같은 차례 · 같은 길이 · 미결 219 닫음) · J-3 키 = 저널 id(안전 동작 `decision_id` 한 벌) ·
//    갈래 채우기 · 새 행 · `JournalDraftRejectCodes` 1 → 3 · 🆕 `JournalRuleCitedCodes` 3(`journal_rule_cited`) · `byDomain` +3 · 🆕 C-68 ·
//    픽스처 390 → 393(신설 3 · 개정 1) — 🆕 tool/gen_v135_contract_debts_fixtures.py · 🔴 엔진 · 조립 몫 = 미결 220 · 화면(Bob) = 미결 221.
//    다음 판 = 1.36.0(🔴 첫 후보 = D15 읽기 모델 열 표 — 13 §8 R230 L2 · E11l1 선행) · 06 변경 이력 «2026-11-21 · 계약 v1.35».
// 🆕 '1.36.0'(D15 읽기 모델 열 표 · 01 §45 · 13 R230 L2 · 발주자 위임 2026-11-14 — 권고대로 · K303~K316) — E11l1 선행 계약 창:
//    🆕 `schema/read_model_tables.dart` `ReadModelTables` 22(01 §6-4 20 + `rm_watchdog`(미결 142) + 🆕 `rm_list_envelope`(ListResult 봉투)) ·
//    열 = 결속 DTO `toJson()` 최상위 키(접두 · 제외 · 펼침 한 겹) + DTO 밖 열 + 규칙 5조 4칸 · 형 = 와이어 그대로 · NOT NULL = 키 + 5조 ·
//    펼친 옛 글자 → DTO 키(`rm_journal` `backdate` · `rm_advice` `reasons`·`decision` · `rm_advice_summary` `trust` · `rm_monthly_report`
//    `disclosure_view_count_text`) · G-22 어김 2 = 열 추가 · A6 = 열 0(뷰어 판 null) · `rm_sleeve_allocation` 금액 = 엔진 가림 글자(DTO 0줄) ·
//    목록 VM = 모드별 1행 · `ReadModelListCodes` 8 · RLS = select 전용 `app_device` ACTIVE 조인 · 🆕 C-69 · 픽스처 393(버전 줄만) —
//    🆕 tool/gen_v136_read_model_fixtures.py · `ddl/batch_d_supabase.sql` 주석(표 22 · 정본 = 이 상수) + data_sync 부트스트랩 사본 재생성.
//    🔴 엔진 · 조립 = 미결 222(E11l1 생성기 · E11l2 push) · 뷰어 조립 = 미결 223 · 다음 판 = 1.37.0(M5-13 · L-3 현금 축 — 미결 224 · 225).
// 🆕 '1.37.0'(M5 판 · 01 §46 · 13 §8 R249 · 발주자 위임 2026-11-14 — 권고대로 · K317~K329) — 미결 224 · 225 · 218 ⓕⓖ(X1 넘김 4):
//    🆕 `M5-13` 원장 실사 해소 게이트 `SelfAuditResolveVm` · `HeldCommandRow` · 창구 `SelfAuditResolveRepository.watchResolve()`(라우트 =
//    기존 `m5SelfAuditResolve` · 수동 해제 필드 0) · `SafetyActionId.heldCommandsConfirm`(`run{review_id}` · 표면 무변경) · 🆕
//    `HeldReviewResultCodes` 3(`held_review_result`) · `CANON_SELF_REPORT` = X5 정정 대상 아님(해소 = 다시 실사 0오차) · L-3 현금 축
//    (원천 = 계좌 별칭 두 갈래 · 허용 오차 = 운영 설정 키 · 값 = 발주자 수치 대기 · 계약 수치 0) · X1 🆕 `LeaseHandoverRpcNames`
//    (`device_retire`) · `LeaseHandoverRpcParams` 3 · 🆕 `LeaseHandoverResultCodes` 3(`lease_handover_result`) · `operator_lease` 티켓 2열 ·
//    `DecisionReasonCodes` +2(`X1_D03_CONFIRMED` · `X1_EMERGENCY_DECLARED` · kind = `SAFETY` · 스키마 0) · `byDomain` +2 · 🆕 C-70 ·
//    픽스처 393 → 398(신설 5) — 🆕 tool/gen_v137_m5_x7_x1_fixtures.py · 🔴 엔진 · 조립 = 미결 226 · 227 · 228 · postmortem = 1.38.0.
// 🆕 '1.38.0'(읽기 모델 push RPC 표 · 01 §47 · 13 §8 R251 · 발주자 위임 2026-11-14 — 권고대로 · K330~K337) — E11l2 선행 작은 창:
//    🆕 `schema/supabase_rpc.dart` `ReadModelPushRpcNames`(`rm_push`) · `ReadModelPushRpcParams` 4(`p_device_id` · `p_epoch` = 리스 글자 ·
//    `p_table` · `p_rows`) · `ReadModelPushRpcColumns` 4(`code` · `epoch` · `accepted` · `skipped`) · 🆕 `ReadModelPushResultCodes` 2
//    (`read_model_push_result` · 리스 거부 = `LeaseRpcResultCodes` 그대로) · 🆕 C-71 · 픽스처 398(버전 줄만) — 🆕 tool/gen_v138_rm_push_rpc_fixtures.py.
//    🔴 SQL 본문 · 클라이언트 = 엔진 E11l2(미결 222 ⓑ) · 다른 select 전용 표 쓰기 창구 = 미결 229 · 다음 판 = 1.39.0(뷰어 행 표 목록 차례 · 소속 열 ·
//    postmortem — 미결 230 · 188).
// 🆕 '1.39.0'(뷰어 목록 열 · postmortem · 리뷰 3차 등재 · 생체 목적 · 01 §48 · 13 §8 R269 · 발주자 위임 2026-11-14 — 권고대로 ·
//    K338~K352) — 미결 230 ⓐ~ⓔ · 188 postmortem · 238 · 리뷰 3차 엔진 예약 등재(231 · 233 · 235 · 205 ⓓ) · 236 계약 창 대기:
//    🆕 `ReadModelListColumn`(목록 열 · `listColumns`) — 차례 열 9(`timeline_rank` · `holdings_rank` · `series_rank` · `events_rank` ·
//    `rm_alert.inbox_rank` · `rm_advice.inbox_rank` · `history_rank` · `open_diffs_rank` · `queue_rank` · null = 목록 밖) · 봉투 +3
//    (`filtered_empty_label` · `scope_empty_label` · `has_more`) · `rm_config_view.range_presets` · 🆕 `routeParamKeyOf` · 230 ⓒ
//    `OpsSummaryRepository` 글자(`ReadModelListCodes.opsSummaryWatchRhythm`) · 🆕 `M5-4` `PostmortemListVm` · `PostmortemRow` ·
//    `PostmortemForm` · 창구 `PostmortemRepository.watchPostmortems` · 라우트 `m5Postmortem`(86) · 등재 `LIVE_PROMOTION_CONFIG_UNAVAILABLE` ·
//    `SIM_LEDGER_FATE_CONFIG_UNAVAILABLE` · `SIM_TO_AUTO_CONFIG_NOT_APPROVED` · `SIM_TO_AUTO_ACCOUNT_DUPLICATE` · 🆕 `LedgerWriteGateCodes`
//    (`LEDGER_CLOSED` · `ledger_write_gate`) · `AlertCodes` +3(`KILL_SWITCH_ACK_MISMATCH` P0 · push 2 P1 → 39) · 🆕
//    `SupabaseSignupResultCodes`(`SUPABASE_SIGNUP_OPEN`) · 배치 D 기기 넣기 정책 좁힘 · 리스 클레임 문언 · 🆕 `BiometricPurpose` 4 ·
//    `BiometricPromptText` · 🆕 C-72(+ 엔진 코드 ⊆ 계약 원천 대조 — 리뷰 3차 I-2) · 픽스처 398 → 402(신설 4 · 개정 1 gap7) —
//    🆕 tool/gen_v139_fixtures.py. 🔴 엔진 · 조립 = 미결 242(목록 열 채우기 · 봉투 글자) · 243(postmortem 조립 · 생체 배선 · 경보 · 가입 확인).
// 🆕 '1.40.0'(운영 폰 공유 표 push RPC · 01 §49 · 13 §8 R270 · 발주자 위임 2026-11-14 — 권고대로 · K353~) — 미결 229 · 222 ⓕ 작은 창:
//    🆕 `schema/supabase_rpc.dart` `OpsPushRpcNames`(`op_push`) · `OpsPushRpcParams` 4 · `OpsPushRpcColumns` 4(= `rm_push` 글자) ·
//    `OpsPushTables` 5(`command_ack` · `planned_work_mirror` · `resume_run_mirror` · `ledger_stamp` · `calendar_sync_status`) · 🆕
//    `OpsPushResultCodes` 2(`ops_push_result` · 리스 거부 = `LeaseRpcResultCodes` 그대로) · 배치 D 옛 4표 select `using (true)` →
//    `ReadModelRls.selectUsing`(K311 · ACTIVE 기기) · `command_ack` 머리 «op_push 만 · append-only» · 🆕 C-73 · 픽스처 402(버전 줄만) —
//    🆕 tool/gen_v140_ops_push_fixtures.py. 🔴 SQL 본문 = data_sync `sql/supabase_ops_push_rpc.sql`(부트스트랩 다섯째 조각 · 같은 PR) ·
//    실행기(X2 미러 · X5 스탬프) = 미결 244 · ack 쓰기 = E11m.
// 🔴 '1.0.0' 은 «⚠️ M2-8 이름 미확정이 코드에서 사라졌다»는 뜻이지 «미결이 0건»이라는 뜻이
//    아니다. `docs/m2-8_naming.md` 의 ⏸ 22행은 **이름만 확정**이고 그 기능은 여전히 대기다
//    (01 §8). ⏸ 항목에 걸린 화면은 계속 «픽스처 고정 모드»다.

/// 이 패키지가 표현하는 M2 계약의 버전.
const String contractVersion = '1.40.0';

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
```

---

## `packages/domain_contracts/lib/src/dto.dart`

```dart
// 영역 B·C 재수출 창구 — DTO·뷰모델(`lib/src/dto/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔵 B(1조: common·journal·holdings·resume·calendar·ledger·safety)와
//    C(2조: performance·rebalance·plan·advice·ledger_trust·handover·ops·settings·
//    handbook)를 한 창구로 합친다 — 화면에게 «1조·2조»는 의미가 없다.
//
// 근거: 01 §2 · 인벤토리 §3.

export 'dto/accounts.dart';
export 'dto/advice.dart';
export 'dto/allocation.dart'; // 🆕 v1.28 — S04 첫 판(01 §37)
export 'dto/calendar.dart';
export 'dto/common.dart';
export 'dto/handbook.dart';
export 'dto/handover.dart';
export 'dto/holdings.dart';
export 'dto/incident.dart';
export 'dto/journal.dart';
export 'dto/ledger.dart';
export 'dto/ledger_trust.dart';
export 'dto/migration.dart'; // 🆕 v1.33 — X1 기기 이전(01 §42)
export 'dto/onboarding.dart';
export 'dto/operations.dart';
export 'dto/ops.dart';
export 'dto/performance.dart';
export 'dto/plan.dart';
export 'dto/postmortem.dart'; // 🆕 v1.39 — M5-4 postmortem 목록(01 §48 K345)
export 'dto/rebalance.dart';
export 'dto/repair.dart'; // 🆕 v1.32 — X5 정정 마법사(01 §41)
export 'dto/resume.dart';
export 'dto/safety.dart';
export 'dto/safety_gate.dart';
export 'dto/self_audit.dart'; // 🆕 v1.37 — M5-13 원장 실사 해소 게이트(01 §46)
export 'dto/settings.dart';
```

---

## `packages/domain_contracts/lib/src/enums.dart`

```dart
// 영역 A 재수출 창구 — 열거형 전량(`lib/src/enums/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 열거값의 JSON·DB 표기는 `@JsonValue` 가 유일한 출처다(인벤토리 §0-2 5조).
//    여기에 별칭·재정의를 두지 않는다.
//
// 근거: 01 §2-1 · 인벤토리 §2.

export 'enums/advice.dart';
export 'enums/biometric.dart'; // 🆕 v1.39 — 생체 대화상자 목적(01 §48 K350 · 미결 238)
export 'enums/calendar.dart';
export 'enums/command.dart';
export 'enums/draft.dart';
export 'enums/handbook.dart';
export 'enums/incident.dart';
export 'enums/journal.dart';
export 'enums/ledger.dart';
export 'enums/market_data.dart';
export 'enums/mode.dart';
export 'enums/onboarding.dart';
export 'enums/order.dart';
export 'enums/performance.dart';
export 'enums/rebalance.dart';
export 'enums/resume.dart';
export 'enums/safety.dart';
export 'enums/settings.dart';
export 'enums/sleeve.dart';
export 'enums/ui.dart';
```

---

## `packages/domain_contracts/lib/src/fixtures.dart`

```dart
// 영역 F 재수출 창구 — 픽스처 경로·봉투 로더(`lib/src/fixtures/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 픽스처는 **합성 데이터**다(C-14 · 실키 0건). `scanForSecrets` 가 그
//    검사의 술어이며 화면 코드가 픽스처를 실행 경로에서 읽지 않는다.
// 🔵 배럴에 올리는 이유: 화면·테스트가 `lib/src/` 를 직접 import 하는 것이
//    인벤토리 §0 의 금지 사항이기 때문이다(영역 F 인계 사항).
//
// 근거: 01 §5 · 인벤토리 §8.

export 'fixtures/fixture_loader.dart';
export 'fixtures/fixture_paths.dart';
```

---

## `packages/domain_contracts/lib/src/mode_marker_text.dart`

```dart
// 🆕 계약 v1.22(01 §31 · K67) — 모드 표지 글자. 🔴 표지 글자 상수라 C-5 사전 대상(`lib/src/labels/`) 밖에 둔다(C-5 예외 0).

/// 모드 표지 글자(엔진 core `ops/mode_marker.dart:11-20` · 셸 `ui_shell/lib/l10n/labels.dart:31-32`
/// 두 벌 → 한 벌). 🔴 «코드 → 문구» 사전이 아니다 — 표지 글자 상수(사전 도메인 0 · byDomain 0).
/// 소비 이전 = 엔진 다음 조각 · 셸 = 다음 test-only/PNG 창.
abstract final class ModeMarkerText {
  /// 모의 표지.
  static const String sim = '모의투자';

  /// 투자 안내(X7) 표지.
  static const String advisory = '투자 안내';

  /// OS 알림·다이제스트 제목 접두 — 모의(앱 안 화면은 셸 띠가 덮는다 — 이중 표지 0).
  static const String osSimPrefix = '[모의]';

  /// OS 알림·다이제스트 제목 접두 — 투자 안내.
  static const String osAdvisoryPrefix = '[안내]';
}
```

---

## `packages/domain_contracts/lib/src/navigation.dart`

```dart
// 영역 G — 내비게이션 계약의 재수출 창구(🆕 계약 v1.1 · 01 §4-4).
//
// 🔴 「링크는 데이터로 온다」 — 화면은 링크를 만들지도 해석하지도 않고 `AppLinkOpener` 에
//    그대로 넘긴다. 라우트 정본 목록은 `AppRoutes.all` 이며 셸(M8)이 전량 등록한다.

export 'navigation/app_links.dart';
```

---

## `packages/domain_contracts/lib/src/primitives.dart`

```dart
// 영역 A 재수출 창구 — 원시타입(`lib/src/primitives/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다. 영역 구현자는 자기 폴더의 파일만 만들고
//    여기에 줄을 더하지 않는다(인벤토리 §0).
// 🔴 `primitives/converters.dart` 는 `money.dart` 의 컨버터 4종을 재수출하는
//    창구일 뿐이라 여기서 다시 내보내지 않는다 — 같은 선언이 두 경로로
//    배럴에 오르면 «어느 쪽이 정본인가»가 다시 흐려진다(인벤토리 §1).
//
// 근거: 01 §1-2(금액) · §1-3(시각·날짜·신선도) · §2-1(봉투·구간).

export 'primitives/as_of.dart';
export 'primitives/date_range.dart';
export 'primitives/list_result.dart';
export 'primitives/money.dart';
```

---

## `packages/domain_contracts/lib/src/repositories.dart`

```dart
// 영역 D 재수출 창구 — 읽기 리포지토리 인터페이스(`lib/src/repositories/**`).
//
// 🔴 이 파일은 통합 담당이 관리한다(인벤토리 §0).
// 🔴 리포지토리는 **읽기 전용**이다. 쓰기는 `CommandApi`·`SettingsActions`
//    (🆕 v1.2 `DraftStore` · 🆕 v1.21 `SafetyActions`)뿐이며 `save_`/`write_`/`submit_`/`send_` 이름은 계약에 존재하지
//    않는다(01 §1-4 · 인벤토리 §0-2 3조).
//
// 근거: 01 §4-1 · 인벤토리 §5.

export 'repositories/advice_repository.dart';
export 'repositories/alert_repository.dart';
export 'repositories/block_board_repository.dart';
export 'repositories/breaker_ladder_repository.dart';
export 'repositories/calendar_repository.dart';
export 'repositories/config_repository.dart';
export 'repositories/execution_gap_repository.dart';
export 'repositories/handbook_repository.dart';
export 'repositories/handover_repository.dart';
export 'repositories/holdings_repository.dart';
export 'repositories/incident_repository.dart';
export 'repositories/journal_repository.dart';
export 'repositories/kill_switch_gate_repository.dart';
export 'repositories/ledger_repository.dart';
export 'repositories/ledger_trust_repository.dart';
export 'repositories/migration_repository.dart'; // 🆕 v1.33 — X1 기기 이전(01 §42)
export 'repositories/onboarding_repository.dart';
export 'repositories/ops_repository.dart';
export 'repositories/pairing_repository.dart';
export 'repositories/performance_repository.dart';
export 'repositories/pledge_repository.dart';
export 'repositories/postmortem_repository.dart'; // 🆕 v1.39 — M5-4(01 §48)
export 'repositories/rebalance_repository.dart';
export 'repositories/repair_wizard_repository.dart'; // 🆕 v1.32 — X5 정정 마법사(01 §41)
export 'repositories/resume_gate_repository.dart';
export 'repositories/resume_repository.dart';
export 'repositories/rule_change_gate_repository.dart';
export 'repositories/runbook_repository.dart';
export 'repositories/safety_repository.dart';
export 'repositories/self_audit_resolve_repository.dart'; // 🆕 v1.37 — M5-13(01 §46)
export 'repositories/settings_repository.dart';
export 'repositories/what_if_api.dart';
```

---

## `packages/domain_contracts/lib/src/commands/command_api.dart`

```dart
// 01 §4-2 · §5-1 — 앱이 호출할 수 있는 **전부**.
//
// 🔴 경계 규칙 ②. 앱은 DB 에 쓰지 않는다. Supabase append-only 명령 테이블에 INSERT 하고
//    엔진이 구독·검증·집행한다. 반환값은 «요청 접수»이지 «집행 완료»가 아니다.
// 🔴 구현은 `command_queue` 에 UPDATE·DELETE 를 부르지 않는다(C-16).
// 🔴 **킬스위치 «해제» 명령은 없다**(결정 6). 해제는 폰 M5 재개 게이트 전용이며
//    `deactivate` 추가 제안은 **거절이 기본값**이다.
// 🔴 **뷰어가 쓸 수 있는 것은 앞 4종이 전부다**(킬스위치·사전 저널·blind 리뷰·열람 기록).
//    🆕 v1.4 정정(01 §14-2) — 구 «앞 5종»의 다섯째 `registerDeposit`(`DEPOSIT_REGISTER`)는
//    **폰(operator) 전용**이다(RLS 01 §6-4 `command_insert_viewer` · DDL `batch_d_supabase.sql`
//    과 일치). X7 8종(+ `LEDGER_EVENT_RECORD`)도 전량 폰 전용이라 뷰어 화이트리스트를 건드리지 않는다. ⏸ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이고
//    현행 4종 화이트리스트를 유지한다(J-3).
// 🔴 화면은 `CommandReceipt.state` 를 스스로 낙관 갱신하지 않는다.
// 🔴 **`OperatingMode` 전환은 여기 없다** — `SettingsActionId.runtimeOperatingModeSwitchRequest`
//    1종이며 반환 `ActionResult.handoffRoute` 로 위저드에 넘긴다(§4-3).
// 🆕 v1.12(01 §21 · K4) — X7 기록 3종(`recordManualFill`·`skipAdvice`·`submitSelfReportBalance`)의 인자 = «화면 제출»
//    DTO(원문 · `payloads_x7.dart`). 화면은 와이어 DTO·`CommandContext` 를 만들지 않는다 — 파싱·맥락 부착·세션 시각은
//    이 인터페이스의 구현이 한다(실패 = 큐 적재 없는 `rejected` 접수증 `INPUT_INVALID`).
// 🆕 v1.15(01 §24 · K12) — `acknowledgeAlert` 인자 = `String alertId`(와이어 `AlertAck` = 구현이 만든다).
// 🆕 v1.22(01 §31 · K60) — `confirmKillChecklist` 인자 = «화면 제출» `KillChecklistSubmission`(와이어 `KillChecklistAck` =
//    구현이 만든다 · v1.15 `acknowledgeAlert` 선례).
// 🆕 v1.25(01 §34 · K149) — `activateKillSwitch()` 인자 0(구 `{reasonFreeText, deviceId}`) — 화면이 기기 id·사유를 짓지 않는다
//    (기기·채널·시각 = 구현 `CommandContext` · 사유 = 발동 뒤 기록 `confirmKillChecklist` 1·2번).

import 'command_receipt.dart';
import 'payloads.dart';
import 'payloads_x7.dart';

/// 명령 발행 창구.
abstract interface class CommandApi {
  /// 🆕 v1.25(01 §34 · K149) 인자 교체(구 `{required String reasonFreeText, required String deviceId}`) — 🔴 확인 대화 없이 즉시(06 M5-1) ·
  /// 기기·채널·시각 = 구현 `CommandContext`(`command_context.dart` 머리) · 사유 = 발동 뒤 기록(`confirmKillChecklist`) 1·2번 ·
  /// 거부 코드 0(엔진 발동 = 멱등 — 이미 켜져 있으면 첫 발동 시각 유지 · 실패 = `Future` 에러 = 접수 실패) · 뷰어 = 같은 메서드(Supabase 명령).
  Future<CommandReceipt> activateKillSwitch();

  /// 사전 저널 제출(폰 · `J-3`). viewer 경로를 그리는 화면은 없다(`J-3` = 폰 전용 · 01 §11-10).
  /// 🔴 🆕 v1.2 부터 «초안»은 제출 **전** 기기 로컬 입력 원문(`DraftStore` · 01 §12-1)을 뜻한다 —
  ///    이 메서드는 그것이 아니라 **제출**이다(인자 이름 `JournalDraft` 는 그대로).
  /// 🆕 v1.35(01 §44 · K296 ~ K299) — 키 = 저널 id · 갈래(채우기 · 새 행) = 엔진이 키로 가른다 · 거부 = `JournalDraftRejectCodes` 3 ·
  ///    🔴 신뢰 시각 비의존(RECON 해제 선례 · 저널 시각 = 기기 시계) · 같은 `commandId` 재제출 = 같은 접수증(기존 수신함 규칙) ·
  ///    `LEDGER_INTEGRITY` 가 서 있으면 `heldForIntegrity`(보관 · 해제 뒤 집행 — 01 §3-8 «접수하되 보관» · 02 §3-3 R2 ⓕ) ·
  ///    저널 쓰기와 접수는 한 트랜잭션(고아 저널 0).
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft);

  /// 사후 blind 리뷰(결정 9b).
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score);

  /// 열람 기록(결정 8).
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event);

  /// 실입금 등록 — 🔴 폰(operator) 전용(01 §14-2). 🆕 v1.4 인자 = `planId` 하나.
  /// 1회 호출 · 이후 상태는 [watchCommand] 의 `stateLabel` 로만 안다(01 §14 · D7).
  Future<CommandReceipt> registerDeposit(DepositRegistration registration);

  /// 명령 1건의 접수증 흐름 — 화면이 `state` 를 갱신하는 **유일한** 경로(낙관 갱신 금지).
  ///
  /// 🔴 구현 의무(🆕 v1.2 · 시그니처 무변경 · 01 §4-2 · §12-1-6 ⑦) — `DraftStore.load` 가 복원한
  ///    `lastCommandId` 의 재구독이 잠긴 채 멈추지 않게:
  ///    ① 로컬 내구 큐 ⓐ 에만 있는 명령도 첫 값(`requested` — «전송 대기»)을 **곧바로** 낸다.
  ///    ② 종단 상태(`executed`·`rejected`·`expired`) 전에는 **완료하지 않는다**(값 없이 끝나지 않는다).
  ///    ③ 모르는 [commandId] 는 스트림 **에러**로 알린다(침묵·빈 완료 금지).
  ///    🆕 v1.12 ④(01 §21 · K42) — 이 구현이 큐 적재 없이 낸 **로컬 거부 접수증**(`INPUT_INVALID`·
  ///    `SELF_REPORT_OUTSIDE_SESSION`)의 id 도 종단 `rejected` 1값을 곧바로 다시 낸다(기기 로컬 보관 — ③ 의
  ///    «모르는 id» 가 아니다 · 복원 재구독이 잠금에 갇히지 않게).
  /// 화면: 스트림 에러 = 마지막 접수증 유지(01 §8 미결 51 ③) · 복원 재구독의 첫 접수증 전 에러·완료 =
  /// 잠금 유지 + 정적 «다시 시도»(01 §12-4). 명령 메서드 `Future` 의 에러는 «접수 실패»다(01 §4-2).
  Stream<CommandReceipt> watchCommand(String commandId);

  // ───── 🆕 X7(§10) 7종 + 🆕 v1.12 `deferAdviceConfirm` — 🔴 전량 폰(operator) 전용 ─────

  /// 사실 추가. 🆕 v1.12 인자 교체(구 `ManualFillRecord` — 와이어는 구현이 만든다 · K4).
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission);

  /// 정정 = 상쇄 + 재기재.
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment);

  /// 무효 = 상쇄만.
  Future<CommandReceipt> voidManualFill(ManualFillVoid v);

  /// 미이행 + 사유 코드. 🆕 v1.12 인자 교체(구 `AdviceSkip`).
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission);

  /// 원장 실사. 🆕 v1.12 인자 교체(구 `SelfReportBalance` — 세션 시각·기준일은 구현이 붙인다 · 세션 밖 =
  /// `SELF_REPORT_OUTSIDE_SESSION` · K9).
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  );

  /// 🔴 효력 없는 «수신 확인»(P0 승급 사다리 정지만 · `SafetyState` 무영향 · A5).
  /// 🆕 v1.15(01 §24 · K12) 인자 교체(구 `AlertAck ack` — 화면은 `CommandContext` 를 만들지 않는다 · G-19 · C-28 ⑨) ·
  /// 와이어 = [AlertAck](구현이 맥락을 붙인다 · [deferAdviceConfirm] 선례) · 🔴 폰(operator) 전용
  /// (뷰어 = 주입 없음 = 버튼 부재 · §8-10).
  /// 구현 의무 ⓐ [alertId] 단위 멱등 — 이미 확인된 알림의 두 번째 확인은 거부가 아니라 `executed`(효과 0)
  /// ⓑ 모르는 id · 사다리 없는 알림(`ack == null`) = 큐 적재 없는 `rejected`(`INPUT_INVALID` · [watchCommand] 의무 ④).
  Future<CommandReceipt> acknowledgeAlert(String alertId);

  /// 🔴 48h 해제 카운트다운 개시의 유일한 방아쇠.
  /// 🆕 v1.21(01 §30 · K9 · K40) — 와이어 `activation` = 발동 뒤 기록 7(엔진 한 명령). 거부 = `KillSwitchResultCodes` ∪
  /// `SafetyCommonResultCodes`(C-16 · `m5/kill_checklist_receipts`).
  /// 🆕 v1.22(01 §31 · K60) 인자 교체(구 `KillChecklistAck ack`) — 원문 [KillChecklistSubmission] · 와이어 `KillChecklistAck` =
  /// 구현(켜진 사건 · 신뢰 시각 · 새 저널 id · 맥락) · 파싱 실패·빈 선택 = 큐 적재 없는 rejected `KILL_CHECKLIST_ITEM_MISSING`.
  Future<CommandReceipt> confirmKillChecklist(
    KillChecklistSubmission submission,
  );

  /// 🆕 v1.10 · ㊲ — 매매가 아닌데 원장을 바꾸는 사실(인출 · 분배금 · 기업행위 · 원천징수) 1건 ·
  /// `voidsEventId` 가 있으면 무효(상쇄만). 🔴 폰(operator) 전용 · 자동·안내 둘 다(설계 13 §8 R21 L3).
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record);

  /// 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」(폰 전용 · `AdviceItem.deferAvailable` 이 true 일 때만
  /// 버튼이 있다 · 02:947 «버튼은 명령을 직접 부르지 않는다» 의 예외 1건). 와이어 = [AdviceDeferConfirm](구현이 맥락을
  /// 붙인다) · 거부 = `DEFER_ALREADY_USED`.
  Future<CommandReceipt> deferAdviceConfirm(String adviceId);
}
```

---

## `packages/domain_contracts/lib/src/commands/command_context.dart`

```dart
// 01 §4-2(A10) · §5-3 — 명령 봉투의 **실행 맥락**.
//
// 🔴 명령은 Supabase 에 INSERT 되고 엔진이 **나중에** 소비하므로, «어느 맥락에 적용할
//    명령인가»가 명령 안에 있어야 한다. 없으면 소비 시점 런타임이 정하고, 모드가 그 사이
//    바뀌면 모의 체결이 `ledger.sqlite` 에 들어가 §9-5 ④(파일 분리가 경계)가 무너진다.
//
// 🔴 **`context` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이다**(G-19). 화면은
//    `ManualFillRecord` 등을 만들 때 이 필드를 비운 형태로 넘기고, 런타임 값
//    (`runMode`·`operatingMode`·`leaseEpoch`·`deviceId`)은 **폰 구현체가 실어 준다**.
//    🔴 뷰모델·화면 계층에서 `CommandContext` 를 생성하는 코드가 **0건**인 것을 C-28 이 검사한다.
//
// 🔴 소비 규칙 — 발행 시점 맥락으로 판정하고, 소비 시점 런타임과 다르면 **거부하지 않고
//    `CommandState.staleContext`**. 단 **`runMode` 불일치는 예외 없이 거부**한다
//    (파일 경계는 협상 대상이 아니다).
//
// ⏸ H-6 — 기존 5종(`journalDraft` 등)에도 이 필드를 붙일지는 M2-8 물음(§8-21)이며
//    「붙인다」가 권고 확정이다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로
//    **배치 D 와 같은 창**이어야 성립한다 → 이 회차의 코드는 **X7 8종에만** 붙인다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';

part 'command_context.freezed.dart';
part 'command_context.g.dart';

/// 명령 발행 시점의 실행 맥락.
@freezed
abstract class CommandContext with _$CommandContext {
  const factory CommandContext({
    /// 🔴 발행 시점 값.
    required RunMode runMode,

    /// 🔴 발행 시점 값.
    required OperatingMode operatingMode,

    /// 🔴 발행 시점 X1 리스 epoch.
    required int leaseEpoch,
    required String deviceId,
  }) = _CommandContext;

  factory CommandContext.fromJson(Map<String, dynamic> json) =>
      _$CommandContextFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/commands/command_receipt.dart`

```dart
// 01 §4-2 · §5-2 — 명령 접수증.
//
// 🔴 반환값은 «요청 접수»이지 «집행 완료»가 아니다. 화면은 `state` 를 스스로 낙관
//    갱신하지 않는다 — 「요청됨」과 「집행됨」의 구별이 이 계약의 목적이다.
//    🔴 X7 에서는 이것이 표류 인지의 출발점이다: 「기록 버튼을 눌렀다」와 「원장에 들어갔다」는
//    다른 사건이다.
// 🔴 멱등은 봉투가 보장한다(`command_id` + `unique(kind, nonce)`) — payload 에
//    `idempotencyKey` 를 두지 않는다(A9).
// 🔴 표시 문구는 `stateLabel` 하나다. 화면이 `state` 를 보고 문장을 조합하지 않는다(§1-5).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';

part 'command_receipt.freezed.dart';
part 'command_receipt.g.dart';

/// 명령 1건의 접수 상태.
@freezed
abstract class CommandReceipt with _$CommandReceipt {
  const factory CommandReceipt({
    required String commandId,
    required CommandKind kind,
    required CommandState state,

    /// 「요청됨 — 엔진 수신 대기」 — 🔴 엔진 생성 문자열.
    /// 🔴 `CommandState.noOperator` 의 문구는 **M2 가 사전 공급한 고정 카탈로그**에서
    ///    고른 값이 실려 온다(§10-8) — 앱이 상태를 조합해 문장을 만들지 않는다.
    required String stateLabel,
    required DateTime requestedAt,

    /// TTL. 🔴 **보류 4상태는 TTL 을 소비하지 않는다**(`CommandStateMachine.consumesTtl`).
    required DateTime expiresAt,
    required String nonce,
    required String issuedByDeviceId,

    /// 🔴 `state == CommandState.rejected` 이면 필수다(§5-2 ·
    ///    `CommandStateMachine.requiresRejectReasonCode`).
    ///    🔴 **거부는 초안을 지우지 않는다**(C17) — 초안 삭제는 `executed` 수신 시에만.
    ///    🆕 v1.39(01 §48 · K347) — 종류 공통 거부 `LedgerWriteGateCodes.ledgerClosed`(`LEDGER_CLOSED` · 화면 상태가 가리키는 원장이
    ///    닫혔다 — 실전 전환 커밋 ~ 깨어남 끝 틈 · 쓰기 0 · 다시 누르면 새 원장에 적힌다) — 종류별 거부 사전과 함께 온다.
    String? rejectReasonCode,

    /// 🆕 v1.12(01 §21 · K20) — 거부 뒤 엔진이 실은 «재제출 선택지» 1개(B5 시간외·단주 · A9 중복 확인).
    /// `state == rejected` 일 때만 · [retryLabel] 과 짝 · 값 = `AdviceRetryCodes`. 🔴 X7 기록 명령 전용(01 §21).
    /// 🔴 화면은 [retryCode] 를 해석하지 않는다 — [retryLabel] 버튼 → 제출 DTO `retryCodes` 에 더한다.
    String? retryCode,

    /// "시간외·단주 신고로 다시 제출" — 엔진.
    String? retryLabel,
  }) = _CommandReceipt;

  factory CommandReceipt.fromJson(Map<String, dynamic> json) =>
      _$CommandReceiptFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/commands/command_state_machine.dart`

```dart
// 01 §4-2 · §5-2 — `CommandReceipt` 상태기계를 **선언 표**로 옮긴 것.
//
// 🔴 이 파일은 «판정»이 아니라 «문서의 전이 표»다. 문구를 고르거나 상태를 만들어 내지
//    않는다 — 표시 문구의 유일한 출처는 `CommandReceipt.stateLabel` 이고(§1-5), 상태를
//    바꾸는 주체는 엔진·Supabase RPC 다. 여기 있는 것은 **순수 함수 4개**뿐이고 소비처는
//    ⓐ 계약 회귀 테스트(§7) ⓑ `data_sync` 구현체의 자기 점검이다.
//
// 🔴 화면(`ui_*`)이 이 표로 분기해 문장을 만들면 §1-5 위반이다.
//
// 01 §5-2 원문 다이어그램:
//
//   requested ──▶ received ──┬──▶ executed        (종단)
//                            ├──▶ rejected        (종단 · rejectReasonCode 필수)
//                            └──▶ expired         (종단 · 서버 expires_at)
//   requested/received ──┬──▶ staleContext        ┐
//                        ├──▶ heldForIntegrity    ├ 🔴 보류 3(+1)상태 — TTL 을 소비하지 않는다
//                        ├──▶ pendingLeaseConfirm ┘   재확인·인수·복구 후 received 로 되돌아온다
//                        └──▶ noOperator          — 소비할 엔진이 없는 창(X1 이전·비상 TTL 대기)
//
// 🔴 **보류는 거부가 아니다.** 무결성 차단·리스 만료·오프라인·맥락 불일치에서 기록 명령을
//    거부하지 않고 보류한다 — 명령은 ⓐ 기기 로컬 내구 큐(암호화·재부팅 생존·**만료 없음**)에
//    먼저 쌓이고 ⓑ 네트워크가 되면 `command_queue` 에 INSERT 된다.
//
// ⚠️ 이름 주의 — `CommandStateMachine` 과 그 멤버 이름은 `docs/m2-8_naming.md` 에 없는
//    **영역 D 작성 이름**이다(전이 표를 코드로 옮기라는 이번 회차 지시의 산물). 계약 타입이
//    아니라 표의 접근자이므로 이름 확정 창에서 바꿔도 DTO·픽스처·DDL 은 흔들리지 않는다.

import '../enums/command.dart';

/// 01 §5-2 전이 표 · 그 표에서 바로 읽히는 술어들.
abstract final class CommandStateMachine {
  /// 🔴 표를 넓히려면 §5-2 원문을 먼저 고친다 — 코드가 문서를 앞지르지 않는다.
  static const Map<CommandState, Set<CommandState>> transitions =
      <CommandState, Set<CommandState>>{
        CommandState.requested: <CommandState>{
          CommandState.received,
          CommandState.staleContext,
          CommandState.heldForIntegrity,
          CommandState.pendingLeaseConfirm,
          CommandState.noOperator,
        },
        CommandState.received: <CommandState>{
          CommandState.executed,
          CommandState.rejected,
          CommandState.expired,
          CommandState.staleContext,
          CommandState.heldForIntegrity,
          CommandState.pendingLeaseConfirm,
          CommandState.noOperator,
        },
        // 🔴 보류 4상태는 «재확인·인수·복구» 뒤 `received` 로 되돌아온다.
        CommandState.staleContext: <CommandState>{CommandState.received},
        CommandState.heldForIntegrity: <CommandState>{CommandState.received},
        CommandState.pendingLeaseConfirm: <CommandState>{CommandState.received},
        CommandState.noOperator: <CommandState>{CommandState.received},
        // 🔴 종단 3상태에서 나가는 화살표는 없다.
        CommandState.executed: <CommandState>{},
        CommandState.rejected: <CommandState>{},
        CommandState.expired: <CommandState>{},
      };

  /// 종단 3상태 — 어떤 경로로도 되살아나지 않는다.
  static const Set<CommandState> terminal = <CommandState>{
    CommandState.executed,
    CommandState.rejected,
    CommandState.expired,
  };

  /// 보류 4상태 — 🔴 **TTL 을 소비하지 않는다**(§5-2).
  static const Set<CommandState> hold = <CommandState>{
    CommandState.staleContext,
    CommandState.heldForIntegrity,
    CommandState.pendingLeaseConfirm,
    CommandState.noOperator,
  };

  /// `from → to` 가 §5-2 표에 있는 화살표인가.
  static bool allows(CommandState from, CommandState to) =>
      transitions[from]?.contains(to) ?? false;

  /// 종단 상태인가.
  static bool isTerminal(CommandState state) => terminal.contains(state);

  /// TTL(`CommandReceipt.expiresAt`)을 소비하는 상태인가.
  /// 🔴 보류 4상태는 `false` — 보류가 만료로 둔갑하면 「명령은 사실을 잃지 않는다」가 깨진다.
  static bool consumesTtl(CommandState state) => !hold.contains(state);

  /// `CommandReceipt.rejectReasonCode` 가 필수인 상태인가(§5-2 「종단 · rejectReasonCode 필수」).
  static bool requiresRejectReasonCode(CommandState state) =>
      state == CommandState.rejected;
}
```

---

## `packages/domain_contracts/lib/src/commands/draft_store.dart`

```dart
// 01 §12-1 — 🆕 계약 v1.2. **셋째 쓰기 창구** — 기기 로컬 입력 초안.
//
// 🔴 원장·명령·공유 저장소 쓰기가 **아니다**. 사람이 적던 입력을 **이 기기 안에** 보존할 뿐이며
//    제출은 여전히 `CommandApi` 하나다(01 §1-4 예외 1 · C-7 ⑤⑥).
// 🔴 구현 = `data_sync`(06 M4-9) · 주입 = **operator 조립 앱**의 `ProviderScope(overrides:)`.
//    viewer(iOS·웹) 조립에는 구현도 주입도 없다(TARGETS T-3).
// 🔴 화면은 저장 위치·암호화·모드(계열)를 모른다 — 아래 «구현 의무»는 전부 구현의 일이다.
//
// 구현 의무(01 §12-1-6 — 요지): ① 기기 로컬·정본 원장 파일(`ledger*.sqlite`) 밖 ② 하드웨어 결속 키로
// 암호화 ③ Supabase·GitHub·DB 백업·OS 백업·로그·오류 보고로 반출 금지 — 포트가 내는 에러 객체·메시지에도
// 본문 값을 싣지 않는다 ④ 모드 계열(§9-2 `RunModeIsSim`)별 분리 — `load` 는 현재 계열만 ⑤ `save` 완료 =
// 재부팅 생존 · `save`·`clear` 는 호출 순서대로 적용(`clear` 는 그 전에 호출된 모든 `save` 뒤에 효력)
// ⑥ 복호·해독 실패 = `load` null ⑦ `load` 가 준 `lastCommandId` 는 `watchCommand` 가 첫 값을 낼 수 있는 id
// ⑧ executed 관찰 시 연결된 초안 삭제 ⑨ 날짜 만료 없음 · 기기 이전 불이동 ⑩ 본문 칸 ≠ `key.kind` 면 `save`
// 거절 · 세 메서드는 **동기로 던지지 않는다**(에러는 전부 반환 `Future` 의 에러).

import 'drafts.dart';

/// 기기 로컬 입력 초안 포트.
///
/// 🔴 세 메서드는 **동기로 던지지 않는다** — 에러는 전부 반환 `Future` 의 에러다(구현·받침대 공통 ·
///    01 §12-1-2). 에러 객체·메시지에 본문 값을 싣지 않는다(01 §12-1-6 ③ — 화면은 그것을 그대로
///    `FlutterError.reportError` 로 올린다).
/// 화면 쪽 수명 주기(언제 `load`·`save`·`clear` 를 부르는가) = 01 §12-1-4 · `J-3` 상태 표 = 01 §12-4.
abstract interface class DraftStore {
  /// [key] 의 초안. 없으면 null — 다른 모드 계열의 초안 · 복호·해독 실패(구현이 값 없이 내부 보고)도 null.
  /// 🔴 돌려준 `lastCommandId` 는 `CommandApi.watchCommand` 가 첫 값을 낼 수 있는 id 다 —
  ///    구현이 그 명령을 모르면 `lastCommandId: null` 로 준다(잠긴 채 멈춤 방지).
  /// `Future` 에러 = 저장소 자체를 열 수 없음.
  Future<DraftRecord?> load(DraftKey key);

  /// 같은 키의 레코드를 **통째로 교체**(upsert)한다. 자주 불러도 된다 — 쓰기 합치기는 구현 몫이며,
  /// 호출 순서대로 적용된다(마지막 호출이 이긴다). 각 `Future` 는 그 값(또는 더 새 값)이 내구 기록되면 완료.
  /// `Future` 에러 = 쓰기 실패 · 본문 칸이 `key.kind` 의 칸 1개가 아님(`ArgumentError`).
  Future<void> save(DraftRecord record);

  /// 지운다. 없어도 에러가 아니다(멱등).
  /// `save` 와 같은 순서 규칙 — 그 전에 호출된 모든 `save` 뒤에 효력이 난다(합쳐져 아직 기록되지 않은
  /// 옛 `save` 가 지운 초안을 되살리지 않는다 · 01 §12-1-6 ⑤).
  /// 🔴 화면이 부르는 곳은 `CommandState.executed` 수신 **하나뿐**이다(01 §3-8 C17).
  Future<void> clear(DraftKey key);
}
```

---

## `packages/domain_contracts/lib/src/commands/drafts.dart`

```dart
// 01 §12-1 — 🆕 계약 v1.2. 기기 로컬 **입력 초안**의 키·봉투·본문.
//
// 🔴 초안 = **사람이 친 입력의 원문**이다. 원장 사실도, 명령도 아니다(제출은 여전히 CommandApi 뿐).
// 🔴 본문 필드 규칙(C-35 ④)
//    ① 이름 = 그 명령 인자(`JournalDraft`·`ManualFillRecord`·`AdviceSkip`·`SelfReportBalance`)의 필드 이름.
//    ② 화면이 만들 수 없는 타입(`Decimal`·`int` 수량)은 **원문 문자열** `<인자 이름>Text`(trim·파싱·0 채움 없음).
//    ③ 담지 않는다 — `CommandContext`(구현이 채운다 · G-19) · 대상 id(키에 있다) · 확인값 3종
//       (`duplicateAck`·`offHourTrade`·`declaredComplete` — «그 순간의 확인»은 복원되면 확인이 아니다) ·
//       세션값(`sessionStartedAt` — 새 세션이 준다) · 엔진 문구(`*Label`) · 모드·기기·시각.
//    ④ **추가형으로만 진화**한다 — 모든 필드는 nullable 이거나 `@Default` 다. 필드를 지우거나 이름·타입을
//       바꾸면 앱 업데이트 전에 저장된 초안이 읽히지 않는다(= 초안 유실 · C17 위반). C-35 ④ 가
//       `fromJson(<String, dynamic>{})` 성공으로 검사한다. 🔴 **유일한 예외 = `SelfReportLineInput.symbol`**
//       (행의 정체 — v1.2 첫 모양부터 required 라 저장된 행에는 반드시 있다). 그 DTO 에도 **새로 더하는**
//       필드는 nullable/`@Default` 다 — C-35 ④ 가 `fromJson({'symbol': …})` 성공으로 검사한다.
//    ⑤ 열거형 선택값(`side`·`reason`)은 **모르는 값 = null(미선택)** 이다(`unknownEnumValue:
//       JsonKey.nullForUndefinedEnumValue`) — 값이 사라진 앱 업데이트 뒤에도 초안 전체가 해독 실패로
//       유실되지 않게(01 §12-1-3 «사라진 선택지 = 미선택» · C-35 ④). 🔵 엔진이 주는 VM 의 열거값은 이와
//       달리 모르면 던진다(fixtures/README «역직렬화 실측») — 초안은 기기에 오래 남는 사람의 입력이라 다르다.
// 🔴 로그·오류 보고·분석 이벤트에 본문 값을 싣지 않는다(자유 서술 칸에 무엇이 붙여 넣어졌을지 모른다).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/draft.dart';
import '../enums/order.dart';
import '../primitives/money.dart';

part 'drafts.freezed.dart';
part 'drafts.g.dart';

/// 초안 하나의 자리 = (종류, 대상 id).
///
/// 🔴 화면은 [targetId] 를 **위젯 생성자 인자 그대로** 넣는다(셸이 라우트 파라미터에서 꺼낸 값 —
///    01 §11-10). 링크 조립이 아니다. 대상 id 표(01 §12-1): `journalDraft` = `decisionId`(🆕 v1.35 K296 — 값 = 저널 id) ·
///    `manualFillRecord`·`adviceSkip` = `adviceId`(라우트) · 🆕 v1.12 `selfReportBalance` = `L-3` 라우트 `:yyyyMm` 과
///    `:accountAlias` 를 `/` 로 이은 글자(`2026-08/연금저축` — «생성자 인자 그대로»의 2인자 판 · K7 · K36 ⓐ) ·
///    `O-04` 시작 상태 선언(🆕 v1.16 `AppRoutes.ledgerSimOpening` · 계좌마다) = `SIM_OPENING/<accountAlias>`
///    («생성자 인자 그대로»의 2조각 판 — `L-3` simOpening 갈래 구현 = 01 §8 미결 153). 지난 달·다른 계좌의
///    초안은 복원 경로가 0 이다.
/// 🔴 모드(계열)는 키에 **없다** — 구현이 계열별로 저장 공간을 가른다(화면은 모드를 모른다 · A7).
@freezed
abstract class DraftKey with _$DraftKey {
  const factory DraftKey({
    required DraftKind kind,

    /// 빈 문자열 금지.
    required String targetId,
  }) = _DraftKey;

  factory DraftKey.fromJson(Map<String, dynamic> json) =>
      _$DraftKeyFromJson(json);
}

/// 초안 1건.
///
/// 🔴 본문 칸은 **정확히 하나**만 non-null 이고 그것이 `key.kind` 의 칸이다 — 아니면 `DraftStore.save`
///    가 `Future` 에러(`ArgumentError`)로 거절한다(구현·받침대 공통 · C-35 ①).
@freezed
abstract class DraftRecord with _$DraftRecord {
  const factory DraftRecord({
    required DraftKey key,

    /// `kind == journalDraft`(`J-3`).
    JournalDraftInput? journal,

    /// `kind == manualFillRecord`(`A-3`).
    ManualFillInput? manualFill,

    /// `kind == adviceSkip`(`A-4`).
    AdviceSkipInput? adviceSkip,

    /// `kind == selfReportBalance`(`L-3` · `O-04` 재사용 포함).
    SelfReportInput? selfReport,

    /// 이 초안으로 **마지막으로 접수된** 명령. null = 아직 접수증이 없다.
    /// 🔴 non-null 이면 화면은 복원 때 `CommandApi.watchCommand(lastCommandId)` 를 다시 구독하고
    ///    첫 접수증 전까지 입력을 잠근다(재시작 뒤 이중 제출 차단 · 01 §8 미결 51 ②).
    String? lastCommandId,
  }) = _DraftRecord;

  factory DraftRecord.fromJson(Map<String, dynamic> json) =>
      _$DraftRecordFromJson(json);
}

/// `J-3` 사전 저널 초안 — [JournalDraft] 에서 `decisionId` 를 뺀 것(C-35 ④).
@freezed
abstract class JournalDraftInput with _$JournalDraftInput {
  const factory JournalDraftInput({
    /// 원문(trim 전).
    @Default('') String rationaleBefore,
    @Default('') String expectedOutcome,

    /// 고른 `JournalDraftFormSpec.ruleCitedOptions[].code`. null = 미선택.
    /// 🔴 복원 때 그 시점의 선택지와 **code 로** 대조하고, 없으면 미선택(문구 없음).
    String? ruleCited,

    /// 원문. '' = 비어 있음(제출 때 `note: null` 로 바꾸는 것은 화면 — 01 §11-10).
    @Default('') String note,
  }) = _JournalDraftInput;

  factory JournalDraftInput.fromJson(Map<String, dynamic> json) =>
      _$JournalDraftInputFromJson(json);
}

/// `A-3` 수기 체결 초안 — [ManualFillRecord] 에서 `adviceId`(키)·`context`·`offHourTrade`·
/// `duplicateAck`(확인값)를 뺐다. 🔴 복원 = 사람이 친 값만(A1 — 안내 값 프리필이 아니다).
@freezed
abstract class ManualFillInput with _$ManualFillInput {
  const factory ManualFillInput({
    @TradeDateConverter() TradeDate? tradeDate,

    /// `ManualFillFormSpec.symbols[].symbol`.
    String? symbol,

    /// 모르는 값(앱 업데이트로 사라진 값) = null = 미선택(머리 ⑤).
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    OrderSide? side,
    @Default('') String quantityText,
    @Default('') String priceText,

    /// '' = 비움(«모름» — 0 이 아니다 · 인자의 `commission: null` 과 같은 뜻).
    @Default('') String commissionText,
    @Default('') String taxText,

    /// `ManualFillFormSpec.accounts[].alias`. 🔴 계좌 전체번호를 싣지 않는다.
    String? accountAlias,

    /// A1 — 「안내 수량 채우기」를 쓴 필드(인자와 같은 뜻 · 원문 그대로 복원).
    @Default(<String>[]) List<String> prefilledFields,
    @Default('') String deviationNote,
  }) = _ManualFillInput;

  factory ManualFillInput.fromJson(Map<String, dynamic> json) =>
      _$ManualFillInputFromJson(json);
}

/// `A-4` 미이행 사유 초안 — [AdviceSkip] 에서 `adviceId`(키)·`context` 를 뺐다.
@freezed
abstract class AdviceSkipInput with _$AdviceSkipInput {
  const factory AdviceSkipInput({
    /// 모르는 값(앱 업데이트로 사라진 값) = null = 미선택(머리 ⑤).
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    AdviceSkipReason? reason,
    @Default('') String note,
  }) = _AdviceSkipInput;

  factory AdviceSkipInput.fromJson(Map<String, dynamic> json) =>
      _$AdviceSkipInputFromJson(json);

  /// 🆕 v1.12(01 §21 · K12) — `A-4` 1탭: 고른 `ReasonOption.code` 를 그대로 해독한다(모르는 코드 = `reason: null`
  /// 미선택 · 머리 ⑤ · 필드 무변경 — 계산 getter 가 아니라 [AdviceSkipInput.fromJson] 과 같은 해독).
  /// 🔴 화면은 `AdviceSkipReason` 을 고르지 않는다(C-46 ⑱).
  factory AdviceSkipInput.fromReasonCode(String code) =>
      AdviceSkipInput.fromJson(<String, dynamic>{'reason': code});
}

/// `L-3` 원장 실사 초안 — [SelfReportBalance] 에서 `purpose`(키)·`sessionStartedAt`(세션값)·
/// `declaredComplete`(확인값)·`context` 를 뺐다. ✅ v1.12 — `asOfTradeDate` 는 엔진이 정한다(사람이 고르지 않는다 ·
/// 세션 시작 때 · `SelfReportSession.asOfTradeDateText`) — 초안에 넣지 않는다(K8 · 01 §8 미결 52 ④).
/// 🔴 복원값 = 사람이 전에 적은 값뿐(원장 현재값 프리필 금지 — 앵커링 · 02 §3-10).
@freezed
abstract class SelfReportInput with _$SelfReportInput {
  const factory SelfReportInput({
    @Default(<SelfReportLineInput>[]) List<SelfReportLineInput> lines,
    @Default('') String cashKrwText,
    String? accountAlias,
  }) = _SelfReportInput;

  factory SelfReportInput.fromJson(Map<String, dynamic> json) =>
      _$SelfReportInputFromJson(json);
}

/// `L-3` 한 종목 행. 🔴 `quantityText == ''` = 아직 안 적음(0 으로 바꾸지 않는다 — «0» 은 사람이 적은 0).
@freezed
abstract class SelfReportLineInput with _$SelfReportLineInput {
  const factory SelfReportLineInput({
    /// 행의 정체 — 본문 DTO 에서 **유일하게 허용된 required 필드**(머리 ④ 예외 · C-35 ④).
    required String symbol,
    @Default('') String quantityText,
  }) = _SelfReportLineInput;

  factory SelfReportLineInput.fromJson(Map<String, dynamic> json) =>
      _$SelfReportLineInputFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/commands/payloads.dart`

```dart
// 01 §4-2 · §5-4 — 명령 인자 DTO(기존 5종 계열).
//
// 🔴 인자가 2개를 넘는 명령은 전부 DTO 로 받는다 — `@DecimalStringConverter()` 는
//    **필드 어노테이션**이라 메서드 인자에 붙여도 아무 일도 하지 않고, 직렬화 규약이
//    사라진 payload 가 만들어진다.
// 🔴 payload 에 `idempotencyKey` 를 두지 않는다(A9) — 멱등은 봉투가 보장한다
//    (`command_queue.command_id` + `unique(kind, nonce)`).
// ⏸ H-6 — 이 4종에 `CommandContext` 를 붙일지는 M2-8 물음(§8-21)이며 「붙인다」가 권고
//    확정이다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로 배치 D 와 같은 창이어야
//    성립한다 → 확정 전까지 여기에 `context` 필드를 만들지 않는다.
//
// 🔴 X7 8종은 `payloads_x7.dart` 에 있다(파일 크기 규약상 분리 · 계약상 같은 §5-4 표).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'payloads.freezed.dart';
part 'payloads.g.dart';

/// 실입금 등록(§2-6 · 플래너 계획 스냅샷 소비).
/// 🆕 v1.4(01 §14-7) — 인자는 **`planId` 하나**다. 금액·기준일은 엔진이 계획 스냅샷에서 가져오고,
///    실입금 대조는 원장이 한다(06 M3-2). 구 `amount`·`valueDate` 는 삭제됐다 — valueDate 의
///    공급원이 없었고 amount 의 출처가 문서마다 달랐다.
/// 🔴 `DEPOSIT_REGISTER` 는 폰(operator) 전용이다(01 §14-2 · RLS · `command_api.dart` 머리).
@freezed
abstract class DepositRegistration with _$DepositRegistration {
  const factory DepositRegistration({
    /// 🔴 화면에 **그려진 계획의** `planId` 만 넣는다. 등록할 수 없는 계획(만료 등)은 엔진이
    ///    `DepositPlan.registerBlockedText` 로 미리 말하고, 그래도 오면 엔진이 거부한다 —
    ///    화면이 만료를 미리 판정하지 않는다.
    required String planId,
  }) = _DepositRegistration;

  factory DepositRegistration.fromJson(Map<String, dynamic> json) =>
      _$DepositRegistrationFromJson(json);
}

/// ✅ H-1 — 사전 작성 저널 초안(결정 9b · 폰은 사전 작성 / viewer 는 초안).
@freezed
abstract class JournalDraft with _$JournalDraft {
  const factory JournalDraft({
    /// 🆕 v1.35(01 §44 · K296) — 🔴 값 = **저널 id**(이름은 그대로 · 화면은 `JournalDraftFormSpec.decisionId` 를 그대로 넣는다).
    /// 갈래(K297) = 엔진이 이 키로 가른다 — ⓐ 채우기(사전 3칸이 빈 있는 저널 행 · SAF-408 자동 해제) · ⓑ 새 행(엔진이 J-3 링크에
    /// 실어 발급한 새 저널 id · 목적 `DISCRETION` · `PLEDGE_EDIT`) · 둘 다 아님 = `JOURNAL_TARGET_UNKNOWN`.
    required String decisionId,
    required String rationaleBefore,
    required String expectedOutcome,

    /// 🔴 **엔진 제공 목록의 코드**다(자유 입력 금지). 선택지는
    ///    `JournalDraftFormSpec.ruleCitedOptions`(E-4)가 준다. 🆕 v1.35(K300) — 값 ∈ `JournalRuleCitedCodes`(목록 밖 = `JOURNAL_INPUT_INVALID`).
    required String ruleCited,
    String? note,
  }) = _JournalDraft;

  factory JournalDraft.fromJson(Map<String, dynamic> json) =>
      _$JournalDraftFromJson(json);
}

/// ✅ H-2 — 사후 blind 리뷰 점수(결정 9b). 🆕 v1.7 주석(01 §16) — 필드 무변경.
@freezed
abstract class BlindReviewScore with _$BlindReviewScore {
  const factory BlindReviewScore({
    /// 그려진 카드의 `BlindReviewCard.decisionId` 그대로.
    required String decisionId,

    /// 문항 id → **고른 `BlindReviewChoice.score` 를 그대로 옮긴 값**(v1.7 — 코드→점수 변환 0).
    /// 🔴 카드의 **전 문항**을 싣는다(부분 제출 없음 — K10). 최종 판정은 엔진(거부 = `BlindReviewRejectCodes`).
    /// 🔴 문항·선택지 문구와 점수는 `BlindReviewCard`(E-5)가 준다 — 화면이 짓지 않는다.
    required Map<String, int> answers,
  }) = _BlindReviewScore;

  factory BlindReviewScore.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewScoreFromJson(json);
}

/// ✅ H-3 — 성과 열람 기록(결정 8 · G-42). 🆕 v1.3 — 세 값의 뜻(01 §13-6).
@freezed
abstract class DisclosureViewEvent with _$DisclosureViewEvent {
  const factory DisclosureViewEvent({
    /// 어느 화면의 열람인가 — 값은 `DisclosureSurfaceCodes` 가 정본이다.
    required String surfaceCode,

    /// 「그래도 보기」를 누른 순간의 주입 시계 값(`Clock.nowUtc()`) — 관측 시각이며 참고값이다.
    /// 🔴 집계 키 `yyyy_mm` 을 화면이 넣지 않는다 — 집계 월은 엔진이 접수·서버 시각으로
    ///    확정한다(G-42).
    required DateTime viewedAt,

    /// 🆕 v1.3 — 진입 시점 기록은 **0**. 화면은 이 값을 적지 않는다(열람 길이 = 미결 60).
    @Default(0) int durationSec,
  }) = _DisclosureViewEvent;

  factory DisclosureViewEvent.fromJson(Map<String, dynamic> json) =>
      _$DisclosureViewEventFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/commands/payloads_x7.dart`

```dart
// 01 §4-2 · §5-4 · §10 — 🆕 X7 명령 인자 DTO 8종 + 🆕 v1.10 ㊲ `LedgerEventRecord`
// + 🆕 v1.12(01 §21 · K4 · K14 ⓐ) «화면 제출» DTO 3 + 와이어 1(`AdviceDeferConfirm`).
//
// 🔴 각 DTO 의 `deviceId` 는 `CommandContext` 로 **옮겨졌다** — payload 가 기기를 다시
//    말하지 않는다. 🔴 payload 에 `idempotencyKey` 를 두지 않는다(A9).
// 🔴 `context` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이다(G-19 · C-28).
// 🔴 X7 8종은 **전량 폰(operator) 전용**이며 뷰어 화이트리스트를 건드리지 않는다.
//
// (§5-4 표는 기존 5종 계열과 이 8종을 한 표로 적는다 — 파일만 크기 규약상 나눴다.)
// 🆕 v1.21(01 §30) — `KillChecklistAck.activation` + `KillActivationRecord`(카드 ④ 발동 뒤 기록 · 와이어 · 한 명령).
// 🆕 v1.22(01 §31 · K60) — `KillChecklistSubmission`(«화면 제출» · `confirmKillChecklist` 인자 · 와이어 = 구현).

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../dto/ledger_trust.dart';
import '../enums/advice.dart';
import '../enums/ledger.dart';
import '../enums/order.dart';
import '../enums/safety.dart';
import '../primitives/money.dart';
import 'command_context.dart';
import 'drafts.dart';

part 'payloads_x7.freezed.dart';
part 'payloads_x7.g.dart';

/// 수기 체결 «사실 추가».
@freezed
abstract class ManualFillRecord with _$ManualFillRecord {
  const factory ManualFillRecord({
    /// null = 안내와 무관한 수기 신규 → 🔴 `MANUAL_ENTRY`(재량 예산 **차감**).
    String? adviceId,

    /// 🔴 «거래일자 변경»의 자리 — 검증(거래일 여부·안내 창 안인지)은 §3-8 거부 코드가 한다.
    @TradeDateConverter() required TradeDate tradeDate,

    /// 🔴 `sleeve` 를 보내지 않는다 — 엔진이 판정한다.
    required String symbol,
    required OrderSide side,
    required int quantity,
    @DecimalStringConverter() required Decimal price,

    /// null = 미입력(0 이 아니다 — 「없음」과 「모름」).
    /// 🔴 엔진이 채우면 `CostSource.estimated` 가 되고 C-24 가 그 배지를 요구한다.
    @DecimalStringConverter() Decimal? commission,
    @DecimalStringConverter() Decimal? tax,
    required String accountAlias,

    /// 🔴 B5 — 폼의 체크박스가 **아니다**. `PRICE_OUT_OF_RANGE` 거부 뒤 엔진이 «실을지
    ///    판정해서» 준 옵션으로만 true 가 된다.
    required bool offHourTrade,

    /// 🆕 A9 — `DUPLICATE_SUSPECTED` 재제출 시 true(평시 false).
    required bool duplicateAck,

    /// 🆕 A1 — 「안내 수량 채우기」 버튼을 쓴 필드 목록(평시 빈 목록).
    /// 이행 갭이 «직접 적은 값»과 «옮겨 온 값»을 구별한다.
    required List<String> prefilledFields,

    /// 지정가 밖·소급 등 마찰이 붙었을 때 1줄.
    String? deviationNote,
    required CommandContext context,
  }) = _ManualFillRecord;

  factory ManualFillRecord.fromJson(Map<String, dynamic> json) =>
      _$ManualFillRecordFromJson(json);
}

/// 🔴 A13 — amend 가 고칠 수 있는 것은 «한 체결의 속성»뿐이다. **종목·방향은 여기 없다.**
///    종목·방향 변경은 `void` + 새 `record` 2명령으로 강제한다 — 「없던 일 + 새 사실」이
///    실제로 일어난 일이므로 원장 표현도 그래야 한다(거부 코드 `AMEND_SYMBOL_OR_SIDE_CHANGE`).
@freezed
abstract class ManualFillPatchable with _$ManualFillPatchable {
  const factory ManualFillPatchable({
    @TradeDateConverter() required TradeDate tradeDate,
    required int quantity,
    @DecimalStringConverter() required Decimal price,
    @DecimalStringConverter() Decimal? commission,
    @DecimalStringConverter() Decimal? tax,
    required String accountAlias,
    required bool offHourTrade,
    String? deviationNote,
  }) = _ManualFillPatchable;

  factory ManualFillPatchable.fromJson(Map<String, dynamic> json) =>
      _$ManualFillPatchableFromJson(json);
}

/// 정정 = 상쇄 + 재기재. 🔴 엔진이 `REVERSAL`+`RESTATEMENT` **2행**을 원자적으로 낳는다(C-21).
@freezed
abstract class ManualFillAmendment with _$ManualFillAmendment {
  const factory ManualFillAmendment({
    required String targetFillId,

    /// 🔴 부분 패치가 아니라 **전체 값**이다.
    required ManualFillPatchable replacement,

    /// 🔴 엔진 제공 목록의 코드(자유 입력 금지) + 1줄 필수(마찰).
    required String reasonCode,
    required String note,
    required CommandContext context,
  }) = _ManualFillAmendment;

  factory ManualFillAmendment.fromJson(Map<String, dynamic> json) =>
      _$ManualFillAmendmentFromJson(json);
}

/// 무효 = 상쇄만.
@freezed
abstract class ManualFillVoid with _$ManualFillVoid {
  const factory ManualFillVoid({
    required String targetFillId,
    required String reasonCode,
    required String note,
    required CommandContext context,
  }) = _ManualFillVoid;

  factory ManualFillVoid.fromJson(Map<String, dynamic> json) =>
      _$ManualFillVoidFromJson(json);
}

/// 안내 미이행 + 사유 코드.
@freezed
abstract class AdviceSkip with _$AdviceSkip {
  const factory AdviceSkip({
    required String adviceId,

    /// 🔴 «유효기한 방치»는 이 열거형에 없다 — 사람이 고르는 값이 아니라 엔진 전이다.
    required AdviceSkipReason reason,

    /// 🔴 A2·B3 — **예산 코드 2종에만 필수**다(거부 코드 `SKIP_NOTE_REQUIRED`).
    ///    나머지 사유는 1탭으로 끝난다 — 경량 경로가 사유 수집의 정본이다.
    String? note,
    required CommandContext context,
  }) = _AdviceSkip;

  factory AdviceSkip.fromJson(Map<String, dynamic> json) =>
      _$AdviceSkipFromJson(json);
}

/// 원장 실사. 🔴 «지금 계좌에 무엇이 얼마나 있는가»를 사람이 옮겨 적는다.
///
/// 🔴 `purpose == simOpening` 의 완화 3가지 — ① `sessionStartedAt` 이 «세션 밖 제출 거부»의
///    대상이 아니다 ② autoTrade 갈래는 `lines` 빈 배열 + `cashKrw` 1칸 ③ `ledger_sim.sqlite`
///    만 쓰고 `ledger_diff` 를 열지 않는다 — 는 `periodicAudit` 에 **하나도** 적용되지 않는다.
@freezed
abstract class SelfReportBalance with _$SelfReportBalance {
  const factory SelfReportBalance({
    @TradeDateConverter() required TradeDate asOfTradeDate,

    /// 🔴 **기본값을 두지 않는다**(A-10) — 목적이 없으면 엔진이 세 규약을 어디에 걸지 모른다.
    required SelfReportPurpose purpose,

    /// 🆕 B15 — 🔴 세션 밖 제출 거부·앱 전역 가림의 근거.
    required DateTime sessionStartedAt,

    /// 종목·수량. 🔴 `periodicAudit` 에서는 유니버스 전 종목 행이며 0 도 필수 입력이다.
    required List<SelfReportLine> lines,
    @DecimalStringConverter() required Decimal cashKrw,
    required String accountAlias,

    /// «이것이 전부입니다» 확인 1단계.
    required bool declaredComplete,
    required CommandContext context,
  }) = _SelfReportBalance;

  factory SelfReportBalance.fromJson(Map<String, dynamic> json) =>
      _$SelfReportBalanceFromJson(json);
}

/// 🔴 A5 — 순수 수신 확인. `SafetyState` 에 **아무 효력이 없다**. P0 승급 사다리 정지만.
/// 🆕 v1.15(01 §24 · K12) — 화면 인자 아님 · `CommandApi.acknowledgeAlert(String)` 구현이 만든다.
/// ⏸ J-3 — 뷰어 허용 여부는 §8-10 미결이며 현행 `command_insert_viewer` 4종 화이트리스트를
///    유지한다(= 지금은 폰 전용).
@freezed
abstract class AlertAck with _$AlertAck {
  const factory AlertAck({
    required String alertId,
    required CommandContext context,
  }) = _AlertAck;

  factory AlertAck.fromJson(Map<String, dynamic> json) =>
      _$AlertAckFromJson(json);
}

/// 🔴 A5 — 킬스위치 체크리스트 이행 «선언». **이것만이 48h 해제 카운트다운을 개시**한다.
///    폰 전용 · M5 소유 화면 · 생체인증 · 항목별 개별 체크. 🔴 대사 전용 키가 있으면 엔진의
///    미체결 조회 0건으로 교차검증하고 불일치면 확인을 무효로 하고 P0 를 다시 올린다.
/// 🆕 v1.21(01 §30 · K9) — [activation] = 카드 ④ 발동 뒤 기록 7(엔진 `confirmChecklist(answers, ack)` 한 명령 —
///    두 번 나누지 않는다). null = 엔진 거부 `KILL_CHECKLIST_ITEM_MISSING`(추가형 · 기본 null · 옛 JSON 그대로 열린다).
@freezed
abstract class KillChecklistAck with _$KillChecklistAck {
  const factory KillChecklistAck({
    required String safetyEventId,

    /// 미체결 주문 조회함.
    required bool openOrdersQueried,

    /// 전량 취소함.
    required bool openOrdersCancelled,

    /// 잔여 건수 0 확인.
    required bool remainingCountZero,

    /// 증권사 앱에서 조회한 시각.
    required DateTime queriedAt,

    /// 1줄 필수.
    required String note,
    required CommandContext context,

    /// 🆕 v1.21 — 발동 뒤 기록(카드 ④ 7).
    KillActivationRecord? activation,
  }) = _KillChecklistAck;
  // 🆕 v1.22(01 §31 · K60) — 이 와이어는 구현이 [KillChecklistSubmission] 에서 만든다(화면 생성 0).

  factory KillChecklistAck.fromJson(Map<String, dynamic> json) =>
      _$KillChecklistAckFromJson(json);
}

/// 🆕 v1.21(01 §30 · K9) — 카드 ④ 발동 뒤 기록(엔진 core `KillActivationAnswers` · `kill_checklist.dart:30` 칸 1:1 ·
/// 6번 «재개 최소 대기 시작 시각» = 엔진이 채운다). 판정(1·4·7 빈칸 · 2 감정이면 셋 필수 · 3 W번호 또는 «해당 없음») = 엔진.
/// 🔵 와이어 칸이라 숫자 타입이다 — 화면 파싱 문제·입력 원천(`journalDecisionId` 등) = 01 §8 미결 183(1.22.0 판단).
@freezed
abstract class KillActivationRecord with _$KillActivationRecord {
  const factory KillActivationRecord({
    /// 1 · 규칙이 지시한 행동.
    required String ruleAction,

    /// 2 · 규칙인가 감정인가.
    required KillActivationReason reasonKind,

    /// 2 · 감정 · 강도 0~10 · 수면 0~24(감정이면 필수 — 엔진 판정).
    String? emotion,
    int? intensity,
    double? sleepHours,

    /// 3 · W번호 · 트리거 ID(«해당 없음» = [scenarioNone]).
    String? scenarioId,
    @Default(false) bool scenarioNone,

    /// 4 · 재개 조건.
    required String resumeCondition,

    /// 5 · 끄는 범위.
    required KillActivationScope scope,

    /// 7 · 저널 `decision_id`(새 저널 · 겹치면 엔진 `JOURNAL_ID_TAKEN`).
    required String journalDecisionId,
  }) = _KillActivationRecord;

  factory KillActivationRecord.fromJson(Map<String, dynamic> json) =>
      _$KillActivationRecordFromJson(json);
}
// JSON 키: rule_action · reason_kind · emotion · intensity · sleep_hours · scenario_id · scenario_none ·
//          resume_condition · scope · journal_decision_id

/// 🆕 v1.22(01 §31 · K60 · 01 §8 미결 183 ⓐ) — `M5-1` 발동 뒤 기록 «화면 제출»(카드 ④ (가) 7 + 확인 3 · 원문 그대로).
/// 🔴 화면은 와이어([KillChecklistAck]·[KillActivationRecord])·`CommandContext`·저널 id·사건 id·조회 시각을 만들지 않는다 —
///    구현이 켜진 킬스위치 사건 · 신뢰 시각 · 새 저널 id(겹치면 `JOURNAL_ID_TAKEN`)를 붙여 와이어를 만든다(X7 K4 결).
/// 🔴 파싱 실패(강도 0~10 · 수면 0~24 밖·글자) · [reasonKind]·[scope] 빈 선택 = `KILL_CHECKLIST_ITEM_MISSING`
///    (큐 적재 없는 rejected 접수증 · K35 결). 문항 글자 원천 = 01 §8 미결 186(1.23.0).
@freezed
abstract class KillChecklistSubmission with _$KillChecklistSubmission {
  const factory KillChecklistSubmission({
    /// 1 · 규칙이 지시한 행동.
    required String ruleAction,

    /// 2 · 규칙인가 감정인가(null = 고르지 않음).
    KillActivationReason? reasonKind,
    String? emotion,

    /// 2 · 강도 원문.
    String? intensity,

    /// 2 · 수면 시간 원문.
    String? sleepHours,

    /// 3 · W번호 · 트리거 ID / «해당 없음».
    String? scenarioId,
    @Default(false) bool scenarioNone,

    /// 4 · 재개 조건.
    required String resumeCondition,

    /// 5 · 끄는 범위(null = 고르지 않음).
    KillActivationScope? scope,

    /// 확인 3 + 1줄.
    @Default(false) bool openOrdersQueried,
    @Default(false) bool openOrdersCancelled,
    @Default(false) bool remainingCountZero,
    required String note,
  }) = _KillChecklistSubmission;

  factory KillChecklistSubmission.fromJson(Map<String, dynamic> json) =>
      _$KillChecklistSubmissionFromJson(json);
}
// JSON 키: rule_action · reason_kind · emotion · intensity · sleep_hours · scenario_id · scenario_none · resume_condition · scope ·
//          open_orders_queried · open_orders_cancelled · remaining_count_zero · note

// ════════════════════════════════════════════════════════════════════════════
// 🆕 v1.12(01 §21 · K4) — «화면 제출» DTO 3. 기존 와이어 8종(`ManualFillRecord`…)은 **무변경** —
//   엔진이 읽는 `command_queue.payload` 모양이다. 🔴 화면은 와이어를 만들지 않는다(C-46 ⑳): `CommandApi` 구현이
//   제출 DTO 의 원문을 파싱(`int`·`Decimal`)하고 `CommandContext`(G-19)·`sessionStartedAt`(B15)·`asOfTradeDate`(K8)를
//   붙인다. 파싱·빈칸·상한 실패 = 큐 적재 없이 `rejected` 접수증(`rejectReasonCode = AdviceRejectCodes.inputInvalid` ·
//   `stateLabel` 이 어느 칸인지 말한다) · 그 id 도 `watchCommand` 가 종단 접수증으로 다시 낸다(구현 의무 ④ · K42).
//   🔴 셋 다 `fromJson` 을 둔다(관행 · C-8 모집단 — `_knownUncovered` 에 `_reasonCommandPayload` 로 등재).
// ════════════════════════════════════════════════════════════════════════════

/// `A-3` 제출(→ 와이어 [ManualFillRecord]) — 🆕 v1.12.
@freezed
abstract class ManualFillSubmission with _$ManualFillSubmission {
  const factory ManualFillSubmission({
    /// `A-3` = 라우트 값 그대로(필수). null = 안내 밖 수기 신규(`MANUAL_ENTRY` · `M5-6` 만 · 06:229·238).
    String? adviceId,

    /// 초안 본문 그대로(01 §12-1 · 사람이 친 원문 · 방향 = `SideOption.side` · 거래일 = `TradeDateOption.date`).
    required ManualFillInput input,

    /// 사람이 누른 재제출 선택지의 `CommandReceipt.retryCode` **누적**(K20 · 폼 수명 동안만 · 초안 밖 — 확인값).
    /// 구현이 `offHourTrade`·`duplicateAck` 로 옮긴다(`AdviceRetryCodes`).
    @Default(<String>[]) List<String> retryCodes,
  }) = _ManualFillSubmission;

  factory ManualFillSubmission.fromJson(Map<String, dynamic> json) =>
      _$ManualFillSubmissionFromJson(json);
}

/// `A-4` 제출(→ 와이어 [AdviceSkip]) — 🆕 v1.12.
@freezed
abstract class AdviceSkipSubmission with _$AdviceSkipSubmission {
  const factory AdviceSkipSubmission({
    required String adviceId,

    /// `reason == null` = 구현 거부(`inputInvalid`). 예산 코드 2종은 제출하지 않는다(`ReasonOption.deepLink` push · K12).
    required AdviceSkipInput input,
  }) = _AdviceSkipSubmission;

  factory AdviceSkipSubmission.fromJson(Map<String, dynamic> json) =>
      _$AdviceSkipSubmissionFromJson(json);
}

/// `L-3`·`O-04` 제출(→ 와이어 [SelfReportBalance]) — 🆕 v1.12.
@freezed
abstract class SelfReportSubmission with _$SelfReportSubmission {
  const factory SelfReportSubmission({
    /// 🔴 기본값 없음(A-10 · 01 §4-2) — `L-3` = periodicAudit · `O-04` = simOpening(R15 · 01 §8 미결 120).
    required SelfReportPurpose purpose,

    /// periodicAudit = 라우트 `:yyyyMm` 그대로(필수 — 없으면 구현 거부). simOpening = null.
    String? yyyyMm,

    /// 초안 본문 그대로 — 🔴 periodicAudit 의 `input.accountAlias` = 라우트 `:accountAlias`(폼이 처음 만들 때 넣는다 ·
    ///    K36 ⓐ) · 구현이 세션 계좌와 대조(다르면 `INPUT_INVALID`).
    required SelfReportInput input,

    /// «이것이 전부입니다» — 확인값(초안에 없다 · 매 제출 새로 누른다 · 01 §12-1-3 ③).
    required bool declaredComplete,
  }) = _SelfReportSubmission;

  factory SelfReportSubmission.fromJson(Map<String, dynamic> json) =>
      _$SelfReportSubmissionFromJson(json);
}

/// 🆕 v1.12 와이어 — 만료 확인 카드 「내일 다시」(G-86 · K14 ⓐ). 엔진 = `advice_transition(cause_code='DEFER_CONFIRM')` 1행.
/// 🔴 이미 한 번 미룬 안내(두 기기·두 번 탭) = 거부 `DEFER_ALREADY_USED`. 🔴 폰(operator) 전용 · 초안 영구 제외.
@freezed
abstract class AdviceDeferConfirm with _$AdviceDeferConfirm {
  const factory AdviceDeferConfirm({
    required String adviceId,
    required CommandContext context,
  }) = _AdviceDeferConfirm;

  factory AdviceDeferConfirm.fromJson(Map<String, dynamic> json) =>
      _$AdviceDeferConfirmFromJson(json);
}

// ⏸ `LedgerEventRecord` — 🔴 **결정 ㊲ 채택 시에만** 신설한다(J-6 · A-15).
//    이름은 확정됐고 **코드는 만들지 않는다**. 채택되지 않으면 인출·분배금·기업행위·
//    원천징수가 원장 밖에 남아 현금 추정이 단조적으로 어긋나고 그 위에서 안내 수량이
//    계산된다 — 그 사실을 여기 주석으로 남겨 둔다.

/// 🆕 v1.10 · X7 ㊲ — **매매가 아닌데 원장을 바꾸는 사실** 1건(인출 · 분배금 · 기업행위 · 원천징수).
///
/// 🔴 명령 1종이다(설계 13 §8 R21 L2) — [voidsEventId] 가 있으면 그 사건의 **무효(상쇄만)**이고 값 칸은
///    전부 null 이어야 한다. 정정 = 무효 + 새 기록 **2명령**(수기 체결의 종목·방향 변경 A13 과 같은 규칙).
/// 🔴 **사실은 거부하지 않는다**(R21 L6) — 인출 > 추정 현금 · 원장에 없는 종목의 분배금도 접수하고 엔진이
///    원장 신뢰 등급을 `drifting` 으로 내린다. 거부(`LedgerEventRejectCodes`)는 형식 오류·재해석만이다.
/// 🔴 `sleeve` 를 보내지 않는다(엔진이 판정) · 기기는 `context` 안 · `idempotencyKey` 없음(A9).
/// 🔴 kind 별 칸(엔진이 `LEDGER_EVENT_FIELDS_MISMATCH` 로 강제 — 화면은 kind 가 고른 칸만 그린다):
///    · withdrawal — amountKrw 필수 · symbol·taxWithheldKrw·actionType·ratio·cashInLieuKrw null
///    · distribution — symbol·amountKrw(세전) 필수 · taxWithheldKrw 선택(R21 L4)
///    · taxWithheld — amountKrw 필수 · symbol 선택(분배금에 묶이지 않는 원천징수)
///    · corporateAction — symbol·actionType·ratioFrom·ratioTo 필수 · cashInLieuKrw 선택(병합 단주 대금)
@freezed
abstract class LedgerEventRecord with _$LedgerEventRecord {
  const factory LedgerEventRecord({
    required LedgerEventKind kind,

    /// 효력일(입출금일 · 지급일 · 권리락일). 🔴 거래일·개시일 판정은 엔진(`LEDGER_EVENT_DATE_INVALID`).
    @TradeDateConverter() required TradeDate effectiveDate,
    required String accountAlias,
    String? symbol,

    /// 양수. 부호는 [kind] 가 정한다.
    @DecimalStringConverter() Decimal? amountKrw,

    /// distribution 만 — 원천징수 금액. null = 미입력(0 과 다르다 — 「없음」과 「모름」).
    @DecimalStringConverter() Decimal? taxWithheldKrw,

    /// corporateAction 만.
    CorporateActionType? actionType,

    /// corporateAction 만 — 1주 → 2주 분할 = from 1 · to 2.
    int? ratioFrom,
    int? ratioTo,

    /// corporateAction(병합) 만 — 단주 대금.
    @DecimalStringConverter() Decimal? cashInLieuKrw,

    /// non-null = 그 사건의 무효(상쇄만).
    String? voidsEventId,

    /// 🆕 A9 꼴 — `LEDGER_EVENT_DUPLICATE_SUSPECTED` 재제출 시 true(평시 false).
    required bool duplicateAck,
    String? note,
    required CommandContext context,
  }) = _LedgerEventRecord;

  factory LedgerEventRecord.fromJson(Map<String, dynamic> json) =>
      _$LedgerEventRecordFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/commands/safety_actions.dart`

```dart
// 01 §30 — 🆕 계약 v1.21 · M5 «안전 동작». ⚠️ `CommandApi` 가 아니다 · 넷째 쓰기 창구(C-7 · 🆕 v1.22 표면 여덟 — 01 §31 K52).
//
// 🔴 M5 의 재개·서약 쓰기는 Supabase 명령 테이블을 거치지 않는다 — **폰 로컬에서 operator 구현이 엔진(data_sync
//    `kill_switch_store` · `pledge_store`)을 직접 부른다**(뷰어에 경로가 있어서는 안 된다 · 01 §4-3 `SettingsActions` 와 같은 결).
// 🔴 **폰(operator) 빌드에만 구현체가 주입된다.** 뷰어 빌드 = `null` → 화면은 컨트롤을 **렌더하지 않는다**(부재 · 비활성 아님).
// 🔴 **`ui_safety` 만 참조한다**(C-55 ⑯ — `ui_settings`·`ui_shell`·`ui_journal`·`ui_analytics` 0 · 조립 앱 = 주입만).
// 🔴 **«동작»만이다**(G-29) — 상태 구독은 `KillSwitchGateRepository`·`PledgeRepository` 다. 화면이 `run…()` 을 폴링해
//    상태를 만들면 경계 규칙 ① 위반이다(어디까지 왔나 = `KillResumeGateVm.nextItemNo` 로만).
// 🔴 생체 = 구현(조립 앱 M5 가드 · 01 §8 미결 169) — 실패·미등록 = 결과 `reasonCode` `BIOMETRIC_UNAVAILABLE`(한 벌).
// 🔴 킬스위치 «해제» 버튼·명령은 여전히 없다 — 재개는 7문항을 한 문항씩 통과한 결과일 뿐이다(`command_api.dart` 머리).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/safety.dart';
import '../enums/ui.dart';

part 'safety_actions.freezed.dart';
part 'safety_actions.g.dart';

/// M5 안전 동작의 주입 콜백(폰 전용).
///
/// · `run(id, args)` — 엔진이 [SafetyActionCall] 에 완성한 호출(🔴 1.21.0 = 받는 id 0 · 부르면 구현 `ArgumentError`
///   `Future` 에러 · 화이트리스트 = 1.22.0 이 이 머리에 적는다).
/// · `runKillResumeItem` — 재개 게이트(M5-2) 한 문항. 🔴 구현 의무(K36): ① 재개 준비 확인(`ready` 아니면 엔진 `tryResume`
///   차례 그대로 `KILL_SWITCH_NOT_ACTIVE` · `RESUME_CHECKLIST_NOT_CONFIRMED` · `RESUME_TRUSTED_TIME_UNKNOWN` · `RESUME_TOO_SOON`)
///   ② 생체 ③ 엔진 `ResumeChecklist.accept`(순차 · 앞 번호 = `RESUME_ITEM_OUT_OF_ORDER` · 빈칸·범위 밖·파싱 실패 =
///   `RESUME_ITEM_MISSING` · 4번 미충족 뒤 = `RESUME_CONDITION_UNMET`) ④ 7번 통과 = 엔진 `resume()` 한 트랜잭션(해제 ·
///   `decision_id` = 구현이 짓는 새 저널 id — 겹치면 `JOURNAL_ID_TAKEN`) · **1번 제출 = 초안을 비우고 처음부터**(R56 K4
///   «뒤로 고치기 = 처음부터») · 초안 = 구현이 든다 · 결과 id = 늘 [SafetyActionId.killSwitchResume].
/// · `runPledge` — 서약 첫 판(`pledgeWrite` · `decisionId` null — 구현 = 명령 id · R67 Z1) / 편집(`pledgeEdit` · `decisionId`
///   = 사전 저널 id · R67 Z2). 그 밖 id = 구현 `ArgumentError`. 거부 = `PledgeResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`.
/// 🔴 화면은 [SafetyActionResult] 의 `headline` + `reasonCode` 원문만 그린다(분기 0 · `handoffRoute`·`retryable` 1.21.0 표본 null·false).
/// 🆕 v1.22(01 §31 · K52~K55) — `run(id, args)` 화이트리스트(엔진이 [SafetyActionCall] 에 완성 · 🔴 화면은 그대로 넘긴다 · 키 = snake_case):
///    · `interventionStep`     = `{session_id, stage /* '1'~'5' */, outcome ∈ InterventionStepOutcome.wire, decision_id?}`
///    · `ruleChangeCancel`     = `{request_id}`
///    · ~~`reconClear`~~ — 🆕 v1.26(01 §35 · K181) 화이트리스트에서 뺐다: `run(reconClear, …)` = 구현 `ArgumentError` ·
///                               해제 = [SafetyActions.runReconClear](사람 글 = 제출 DTO · K7) · `SafetyActionId.reconClear` = 결과 id 로 남는다.
///    · `seasonalWindowChoice` = `{work_id, choice ∈ SeasonalEntryChoice.wire}`(`decision_id` = 구현이 짓는다 — K54 · 거부 =
///                               `SeasonalChoiceResultCodes` ∪ `PlannedWorkRejectCodes` ∪ 멈춤 사유 7(`ResumeItemReasonCodes`))
///  그 밖 id 를 `run` 으로 부르면 구현 `ArgumentError`(`Future` 에러 · 결과 코드 0).
/// · `runStoppedDecision` — `M5-3` 결정(`decision_id` = 구현이 짓는 새 저널 id · 겹치면 `JOURNAL_ID_TAKEN`) · 거부 = `StoppedDecisionResultCodes`.
/// · `runPostmortem` — 사건 postmortem(거부 = `PostmortemResultCodes`).
/// · `runRuleChangeApproval` — 승인(거부 = `RuleChangeResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`).
/// · `runDiscretionAdjust` — 재량 조정(조정폭 원문 · 파싱 실패 = `DELTA_EXCEEDED` · 여러 사유 = 엔진 정렬 첫째 · 거부 =
///   `DiscretionResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`).
/// 🔴 결과 id = 늘 그 동작의 id · 생체 = 구현(K11) · 화면은 `headline` + `reasonCode` 원문만 그린다(분기 0).
/// 🆕 v1.26(01 §35 · K178 · K180 · K181 · 표면 열 — C-7):
/// · `runRuleChangeRequest` — `M5-9` 규칙 변경 요청(첫 승인 포함 · 유형·`hashBefore`·`hashAfter` = 엔진 후보 행(`candidateId`) ·
///   자기 신고 0 · `decision_id` = 구현이 짓는 새 저널 id · 저널 + 요청 한 트랜잭션 · 거부 = `RuleChangeResultCodes` ∪
///   `TRUSTED_TIME_UNKNOWN` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.ruleChangeRequest].
/// · `runReconClear` — `M5-5` RECON 해제(`decision_id` = 구현 · `cleared_by` = 구현(기기 별칭) · 저널 `RECON_CLEAR` + 해제 한
///   트랜잭션 · 신뢰 시각 비의존 · 거부 = `ReconClearResultCodes` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.reconClear].
/// 🔴 사전 저널 꼴 ⓐ(K180) — 사람 글 3필드(`rationaleBefore` · `expectedOutcome` · `ruleCited` 원문)는 제출 DTO 에 · 저널 id 는
///    구현 · 저널 행과 동작은 한 트랜잭션(고아 저널 0 · 엔진 «저널 함께 쓰기» 판 = 01 §8 미결 206).
/// 🆕 v1.32(01 §41 · K251~K259 · E16j-a · X5 정정 마법사 `RepairWizardVm`):
/// · `run` 화이트리스트 +1(🆕 v1.33 에 표 꼴로 맞춤 — C-60 ⑮):
///    · `repairAccept`     = `{diff_id}`(아무것도 안 하기 · 구현 = 살아 있는 개입 세션 `DO_NOTHING` + diff ACCEPTED ·
///                           무결성 갈래 0 · 결과 id = [SafetyActionId.repairAccept]).
/// · `runRepairCorrect` — 정본 정정(diff 갈래 · 5단계 통과 뒤 · 원문 4칸 파싱 = 구현 · 직전 재대사 = 구현 · `decision_id` = 개입 세션 저널 ·
///   거부 = `RepairResultCodes` ∪ `AdviceRejectCodes` 정정 3 ∪ `InterventionResultCodes` ∪ `TRUSTED_TIME_UNKNOWN` ∪ 🆕 v1.35
///   `RepairInputResultCodes`(원문 파싱 · K291)). 결과 id = [SafetyActionId.repairCorrect].
///   🆕 v1.35(K292) — 정정 체인 상한 = 운영 설정 `operations.amend_chain_max`(SPEC 02 §4 · 값 = 01 §10-3 B6 · 계약 상수 0 · C-32).
/// · `runRepairBaseline` — 새 기준점(무결성 갈래 · 거부 = `BaselineResultCodes` ∪ `BaselineApplyResultCodes` ∪ `InterventionResultCodes` ∪
///   `TRUSTED_TIME_UNKNOWN`). 결과 id = [SafetyActionId.repairBaseline].
/// · `runInterventionJournal` — 개입 3단계 사전 저널(K180 꼴 3칸 · 구현 = 살아 있는 세션 하나에 붙인다 · 저널 + 3단계 한 트랜잭션 · M5-6 재사용 ·
///   거부 = `InterventionResultCodes` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.interventionJournal].
///   🆕 v1.35(01 §44 · K294) — 그 저널 행 `kind` = `DecisionJournalKinds.interventionJournal`(`INTERVENTION_JOURNAL` · 지금 엔진 NULL → 미결 220 ⓒ).
/// 🆕 v1.35(01 §44 · K296) — 🔴 **저널 키 한 벌**: 이 표면의 `decision_id`(재개 7번 · STOPPED · RECON 해제 · 규칙 변경 요청 · 개입 3단계 ·
///    재량 조정 `DiscretionAdjustSubmission.decisionId` · 서약 편집 `PledgeSubmission.decisionId`) = `decision_journal.journal_id` 이고,
///    `J-3` 키(`AppRoutes.journalDraft` `:decisionId` · `JournalDraft.decisionId`)도 같은 저널 id 다. 재량 · 서약 편집은 저널을 J-3 가 먼저
///    쓰고(새 행 갈래 · kind = `DISCRETION` · `PLEDGE_EDIT`) 동작이 그 id 를 받는다 · 나머지는 동작이 저널 + 동작을 한 트랜잭션으로 쓴다(K180 ⓐ).
/// 🔴 정정 · 새 기준점 커밋이 개입 세션 5단계 · 실행 창 · `decision == journalId` 를 보게 하는 결속 = 엔진 숙제(01 §8 미결 217).
/// 🆕 v1.33(01 §42 · K273 · E16j-b · X1 기기 이전 `X1PlanWizardVm` · `X1RecoveryVm`) — `run` 화이트리스트 +6(표면 무변경 · 제출 DTO 0 ·
///    시크릿 = 슬롯 ↔ 구현 사이만 · `run_id` = 엔진이 args 에 싣는다):
///    · `x1PlanStart`      = `{}`(옛 폰 «봤습니다 — 이전 시작» · D-03 확인 결정 + 저널 시작 = 구현 · 거부 = `X1StartResultCodes` ∪ `X1JournalResultCodes` ∪ 공용)
///    · `x1PlanStep`       = `{run_id, step ∈ X1StepCodes}`(거부 = `X1StepBlockCodes` ∪ `X1JournalResultCodes` ∪ 공용)
///    · `x1PlanAbort`      = `{run_id, step}`(DEMOTED 앞만 · 거부 = `X1JournalResultCodes`)
///    · `x1EmergencyStart` = `{}`(비상 선언 결정 + 복구 코드 슬롯 → epoch+1 = 구현 · 거부 = `X1StartResultCodes` ∪ `X1RecoveryResultCodes` ∪ 공용)
///    · `x1ReissueRecord`  = `{run_id, item ∈ X1ReissueItemCodes}`(값 = 슬롯 · 지문만 엔진 · 거부 = `X1ReissueResultCodes`)
///    · `x1RecoveryStep`   = `{run_id, step ∈ X1RecoveryStepCodes}`(골든 · 체크리스트 · 생체 = 구현이 가른다 · 거부 = `X1GateReasonCodes` ∪
///                           `X1RestoreResultCodes` ∪ `BackupResultCodes` ∪ `X1OrderSealCodes` ∪ `X1RecoveryResultCodes` ∪ `BIOMETRIC_UNAVAILABLE`)
/// 🔴 VM 생산 · 단계 진행기 · REVOKED · 재발급 저장 · 백업 바이트 원천 = 엔진 · 조립 숙제(01 §8 미결 218) — 그 전 운영 앱 = 모르는 id 오류.
/// 🆕 v1.37(01 §46 · K319 · `M5-13` 원장 실사 해소 게이트) — `run` 화이트리스트 +1(표면 무변경 · 제출 DTO 0 · 운영 앱 받침 0):
///    · `heldCommandsConfirm` = `{review_id}`(엔진 완성 `SelfAuditResolveVm.confirmHeld` · 보관 묶음 스냅숏 id · 구현 = 그 묶음의
///                              `HELD_FOR_INTEGRITY` 전부 → `RECEIVED`(그 뒤 판정 = 보통 소비 규칙) · 버림 동작 0 · 거부 =
///                              `HeldReviewResultCodes` ∪ `BIOMETRIC_UNAVAILABLE` · 신뢰 시각 비의존 · 결과 id = 같은 id).
/// 🔴 `ADVICE_LEDGER_UNVERIFIED` 해제 동작은 없다(해제 = 실사 0오차를 본 엔진이 스스로 · 06 M5-13 · C-70 ③) — 생산 = 01 §8 미결 226.
abstract interface class SafetyActions {
  /// ⚠️ `SettingsActions.run` 과 같은 최소 보정 — non-nullable 선택 명명 인자에 `const {}` 기본값.
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  });

  Future<SafetyActionResult> runKillResumeItem(
    KillResumeItemSubmission submission,
  );

  Future<SafetyActionResult> runPledge(PledgeSubmission submission);

  Future<SafetyActionResult> runStoppedDecision(
    StoppedDecisionSubmission submission,
  );

  Future<SafetyActionResult> runPostmortem(PostmortemSubmission submission);

  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  );

  Future<SafetyActionResult> runDiscretionAdjust(
    DiscretionAdjustSubmission submission,
  );

  /// 🆕 v1.26(01 §35 · K178) — `M5-9` 규칙 변경 요청(첫 승인 포함).
  Future<SafetyActionResult> runRuleChangeRequest(
    RuleChangeRequestSubmission submission,
  );

  /// 🆕 v1.26(01 §35 · K181) — `M5-5` 차단 보드 RECON 해제.
  Future<SafetyActionResult> runReconClear(ReconClearSubmission submission);

  /// 🆕 v1.32(01 §41 · K255) — X5 정본 정정(diff 갈래).
  Future<SafetyActionResult> runRepairCorrect(
    RepairCorrectSubmission submission,
  );

  /// 🆕 v1.32(01 §41 · K256) — X5 새 기준점(무결성 갈래).
  Future<SafetyActionResult> runRepairBaseline(
    RepairBaselineSubmission submission,
  );

  /// 🆕 v1.32(01 §41 · K252) — 개입 3단계 사전 저널(X5 마찰 · M5-6 공용).
  Future<SafetyActionResult> runInterventionJournal(
    InterventionJournalSubmission submission,
  );

  Stream<SafetyActionResult> watch(String actionRunId);
}

/// 안전 동작 1회의 결과(`ActionResult` 꼴 · [id] 타입만 다르다 — `ActionResult.id` 는 `SettingsActionId` required).
@freezed
abstract class SafetyActionResult with _$SafetyActionResult {
  const factory SafetyActionResult({
    required String actionRunId,
    required SafetyActionId id,
    required UiLevel level,

    /// 결과 문구 — 🔴 엔진 생성(요약·의역 금지).
    required String headline,

    /// 값 ∈ `KillSwitchResultCodes` ∪ `SafetyCommonResultCodes` ∪ `PledgeResultCodes` ∪ 🆕 v1.22 `StoppedDecisionResultCodes` ∪
    /// `PostmortemResultCodes` ∪ `InterventionResultCodes` ∪ `RuleChangeResultCodes` ∪ `DiscretionResultCodes` ∪
    /// `SeasonalChoiceResultCodes` ∪ `PlannedWorkRejectCodes` ∪ `ResumeItemReasonCodes`(멈춤 사유 7) ∪ 🆕 v1.26
    /// `ReconClearResultCodes` ∪ 🆕 v1.32 `RepairResultCodes` ∪ `BaselineResultCodes` ∪ `BaselineApplyResultCodes` ∪ `AdviceRejectCodes` 정정 3 ∪
    /// 🆕 v1.35 `RepairInputResultCodes` ∪ 🆕 v1.37 `HeldReviewResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`}(C-55 ② · C-56 ② · C-60 ⑩ ·
    /// C-66 · C-68 · C-70 ④) ∪ 🆕 v1.39 `LedgerWriteGateCodes`(원장에 쓰는 동작 · 닫힌 원장 = 쓰기 0 · `retryable` true · 01 §48 K347).
    String? reasonCode,

    /// ⏸ 1.21.0 · 1.22.0 표본 null(넘김 동작 = 화면 판 · 목적지 = M5·X 라우트 상수만).
    String? handoffRoute,
    required bool retryable,
  }) = _SafetyActionResult;

  factory SafetyActionResult.fromJson(Map<String, dynamic> json) =>
      _$SafetyActionResultFromJson(json);
}
// JSON 키: action_run_id · id · level · headline · reason_code · handoff_route · retryable

/// 엔진이 완성한 `SafetyActions.run` 호출 1개(`SettingsActionCall` 꼴). 🔴 화면은 [id]·[args] 를 그대로 넘긴다.
/// 🆕 v1.22 — 첫 사용처 = `ResumeGateRow.actions`(계절 3택 · 01 §31 K64).
@freezed
abstract class SafetyActionCall with _$SafetyActionCall {
  const factory SafetyActionCall({
    required SafetyActionId id,
    required Map<String, String> args,

    /// 버튼 글자 — 엔진.
    required String label,
  }) = _SafetyActionCall;

  factory SafetyActionCall.fromJson(Map<String, dynamic> json) =>
      _$SafetyActionCallFromJson(json);
}
// JSON 키: id · args · label

/// `M5-2` 재개 게이트 한 문항 제출(엔진 core `ResumeItemAnswer` 칸 − `decisionId`(구현이 짓는다 · K34) · 숫자 2 = 원문 · K35).
/// 🔴 그 번호에 맞는 칸만 채운다 — 1 `text` · 2 `emotion`·`intensity`·`sleepHours` · 3 `scenario` · 4 `condition` ·
///    5·6 `acknowledged` · 7 `rationaleBefore`·`expectedOutcome`·`ruleCited`. 3·4번 값 = 고른 `KillResumeChoice` 의 칸 그대로.
/// 🔴 화면은 검증·파싱하지 않는다(빈칸·범위 = 엔진 판정 · `RESUME_ITEM_MISSING`).
@freezed
abstract class KillResumeItemSubmission with _$KillResumeItemSubmission {
  const factory KillResumeItemSubmission({
    /// 지금 차례 = `KillResumeGateVm.nextItemNo`(1~7 · 1 = 처음부터).
    required int itemNo,
    String? text,
    String? emotion,

    /// 강도 원문(0~10 판정 = 엔진).
    String? intensity,

    /// 수면 시간 원문(0~24 판정 = 엔진).
    String? sleepHours,
    KillResumeScenario? scenario,
    KillResumeCondition? condition,
    @Default(false) bool acknowledged,
    String? rationaleBefore,
    String? expectedOutcome,

    /// 🔵 원문(엔진 = 비지 않음만 · J-3 의 «엔진 선택지 코드»와 다르다 — 01 §8 미결 184).
    String? ruleCited,
  }) = _KillResumeItemSubmission;

  factory KillResumeItemSubmission.fromJson(Map<String, dynamic> json) =>
      _$KillResumeItemSubmissionFromJson(json);
}
// JSON 키: item_no · text · emotion · intensity · sleep_hours · scenario · condition · acknowledged ·
//          rationale_before · expected_outcome · rule_cited

/// 서약 첫 판·편집 제출(엔진 `pledge_store.writeFirst` · `edit`). 🔴 문장 = 사람이 친 원문 그대로(프리필 0 · 다듬기 = 엔진).
@freezed
abstract class PledgeSubmission with _$PledgeSubmission {
  const factory PledgeSubmission({
    /// `pledgeWrite` · `pledgeEdit` 만(K32 · 그 밖 = 구현 `ArgumentError`).
    required SafetyActionId id,

    /// 세 문장(차례대로 · 셋 아님·빈칸 = 엔진 `PLEDGE_SENTENCES_MISSING`).
    required List<String> sentences,

    /// 첫 판 = null(구현 = 명령 id · R67 Z1) · 편집 = 사전 저널 id(R67 Z2 · 원천 = 01 §8 미결 185).
    String? decisionId,
  }) = _PledgeSubmission;

  factory PledgeSubmission.fromJson(Map<String, dynamic> json) =>
      _$PledgeSubmissionFromJson(json);
}
// JSON 키: id · sentences · decision_id

/// 🆕 v1.22(01 §31 · K53) — `M5-3` STOPPED 결정 제출(엔진 core `StoppedDecisionAnswers` 칸 − `decisionId`(구현이 짓는다)).
/// 🔴 [choice] = 누른 버튼(A·B·C — 선택지 글자·자격 = 엔진) · 사전 3필드 = 사람이 친 원문(빈칸 = 엔진 `JOURNAL_REQUIRED`).
@freezed
abstract class StoppedDecisionSubmission with _$StoppedDecisionSubmission {
  const factory StoppedDecisionSubmission({
    required StoppedDecisionChoice choice,

    /// 가족 합의서 당사자가 참석했다는 사람 선언(엔진은 선언만 받는다 · false = `FAMILY_AGREEMENT_MISSING`).
    @Default(false) bool familyAgreement,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _StoppedDecisionSubmission;

  factory StoppedDecisionSubmission.fromJson(Map<String, dynamic> json) =>
      _$StoppedDecisionSubmissionFromJson(json);
}
// JSON 키: choice · family_agreement · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.22 — 사건 postmortem 제출(ds `incident_store.dart:85` `recordPostmortem(incidentId, text)`).
/// 🔴 [incidentId] = 엔진이 VM 에 실은 값 그대로(원천 VM = 1.23.0+ · 01 §8 미결 188) · [text] = 원문(빈칸 = `POSTMORTEM_BLANK`).
@freezed
abstract class PostmortemSubmission with _$PostmortemSubmission {
  const factory PostmortemSubmission({
    required String incidentId,
    required String text,
  }) = _PostmortemSubmission;

  factory PostmortemSubmission.fromJson(Map<String, dynamic> json) =>
      _$PostmortemSubmissionFromJson(json);
}
// JSON 키: incident_id · text

/// 🆕 v1.22 — `M5-9` 규칙 변경 승인 제출(ds `rule_change_store.dart:364` `approve` 인자 1:1 · `requestId` = 엔진 값 그대로).
/// 🔴 [goldenChanged] null · [approver] 빈칸 = `RULE_CHANGE_APPROVAL_FIELDS_MISSING` · [thirdPartyNotified] false = `_THIRD_PARTY_MISSING`.
@freezed
abstract class RuleChangeApprovalSubmission
    with _$RuleChangeApprovalSubmission {
  const factory RuleChangeApprovalSubmission({
    required String requestId,
    bool? goldenChanged,
    required String approver,
    @Default(false) bool thirdPartyNotified,
  }) = _RuleChangeApprovalSubmission;

  factory RuleChangeApprovalSubmission.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeApprovalSubmissionFromJson(json);
}
// JSON 키: request_id · golden_changed · approver · third_party_notified

/// 🆕 v1.22 — `M5-6`·`M5-7` 재량 조정 제출(ds `discretion_store.dart:121` `requestAdjustment(deltaPct, decisionId)`).
/// 🔴 [deltaPct] = 원문(파싱 = 구현 · 실패·NaN = 엔진과 같은 `DELTA_EXCEEDED`) · [decisionId] = 사전 저널(`DISCRETION` ·
///    null = `JOURNAL_MISSING` · 원천 = 01 §8 미결 188).
@freezed
abstract class DiscretionAdjustSubmission with _$DiscretionAdjustSubmission {
  const factory DiscretionAdjustSubmission({
    required String deltaPct,
    String? decisionId,
  }) = _DiscretionAdjustSubmission;

  factory DiscretionAdjustSubmission.fromJson(Map<String, dynamic> json) =>
      _$DiscretionAdjustSubmissionFromJson(json);
}
// JSON 키: delta_pct · decision_id

/// 🆕 v1.26(01 §35 · K178 · K180) — `M5-9` 규칙 변경 요청 제출(ds `rule_change_store.dart` `request` 인자 − 유형·해시(엔진 후보) −
/// `decisionId`(구현)).
/// 🔴 사람 글 5칸 = 원문 그대로(빈칸 = 엔진 `RULE_CHANGE_FIELDS_MISSING` · 저널 3칸 빈칸 = `RULE_CHANGE_JOURNAL_MISSING`) ·
///    화면은 검증·파싱하지 않는다.
@freezed
abstract class RuleChangeRequestSubmission with _$RuleChangeRequestSubmission {
  const factory RuleChangeRequestSubmission({
    /// 엔진 후보 행 값 그대로(`RuleChangeCandidateRow.candidateId`).
    required String candidateId,
    required String reason,
    required String rollbackMethod,
    required String rationaleBefore,
    required String expectedOutcome,

    /// 근거 규칙(원문 · 01 §8 미결 184 ③ 결).
    required String ruleCited,
  }) = _RuleChangeRequestSubmission;

  factory RuleChangeRequestSubmission.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeRequestSubmissionFromJson(json);
}
// JSON 키: candidate_id · reason · rollback_method · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.26(01 §35 · K180 · K181) — `M5-5` RECON 해제 제출(ds `order_ledger.dart` `clearReconBlock` −
/// `clearedBy`·`decisionId`·시각(구현)).
/// 🔴 [originCode] = 고른 `ReconOriginChoice.originCode` 그대로 · 저널 3칸 = 원문(빈칸 = `RECON_JOURNAL_MISSING`).
@freezed
abstract class ReconClearSubmission with _$ReconClearSubmission {
  const factory ReconClearSubmission({
    required String originCode,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _ReconClearSubmission;

  factory ReconClearSubmission.fromJson(Map<String, dynamic> json) =>
      _$ReconClearSubmissionFromJson(json);
}
// JSON 키: origin_code · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.32(01 §41 · K255) — X5 정본 정정 제출(ds `correctFill` 칸 − 구현 몫(정정 id · 직전 재대사 diff · 결정 id · 체인 상한)).
/// 🔴 [targetId] · [fillRef] · [originCode] = VM 이 실은 값 그대로 · 수량 · 가격 · 수수료 · 세금 = 사람이 친 **원문**(파싱 = 구현 ·
///    거부 코드 = 엔진이 먼저 정한다 — 그 전 표본 0) · [voidFill] true = 무효(네 칸 무시).
@freezed
abstract class RepairCorrectSubmission with _$RepairCorrectSubmission {
  const factory RepairCorrectSubmission({
    required String targetId,
    required String fillRef,
    required String originCode,
    required bool voidFill,
    String? quantityText,
    String? priceText,
    String? commissionText,
    String? taxText,
  }) = _RepairCorrectSubmission;

  factory RepairCorrectSubmission.fromJson(Map<String, dynamic> json) =>
      _$RepairCorrectSubmissionFromJson(json);
}
// JSON 키: target_id · fill_ref · origin_code · void_fill · quantity_text · price_text · commission_text · tax_text

/// 🆕 v1.32(01 §41 · K256) — X5 새 기준점 제출(ds `applyBaseline` · [targetId] = 무결성 합성 id `li-…` · 원인 = 3종 ∩ 경계 후보).
@freezed
abstract class RepairBaselineSubmission with _$RepairBaselineSubmission {
  const factory RepairBaselineSubmission({
    required String targetId,
    required String originCode,
  }) = _RepairBaselineSubmission;

  factory RepairBaselineSubmission.fromJson(Map<String, dynamic> json) =>
      _$RepairBaselineSubmissionFromJson(json);
}
// JSON 키: target_id · origin_code

/// 🆕 v1.32(01 §41 · K252) — 개입 3단계 사전 저널 제출(K180 꼴 · 사람 글 3칸 원문 · 저널 id = 구현 · 세션 = 살아 있는 하나).
@freezed
abstract class InterventionJournalSubmission
    with _$InterventionJournalSubmission {
  const factory InterventionJournalSubmission({
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _InterventionJournalSubmission;

  factory InterventionJournalSubmission.fromJson(Map<String, dynamic> json) =>
      _$InterventionJournalSubmissionFromJson(json);
}
// JSON 키: rationale_before · expected_outcome · rule_cited
```

---

## `packages/domain_contracts/lib/src/commands/settings_actions.dart`

```dart
// 01 §4-3 · §5-5 — 설정·진단 «동작». ⚠️ `CommandApi` 가 아니다.
//
// 🔴 M9 의 «적용»·«검증»·«백업»·«셀프테스트»와 M8 온보딩의 «검증 드라이런 실행»은 Supabase
//    명령 테이블을 거치지 않는다 — **폰 로컬에서 Claude 소유 구현체가 직접 수행**한다
//    (시크릿이 관여하므로 뷰어에 경로가 있어서는 안 된다).
// 🔴 **폰(operator) 빌드에만 구현체가 주입된다.** 뷰어 빌드에서는 `null` 이고 그때 화면은
//    컨트롤을 **렌더하지 않는다**(«비활성»이 아니라 **부재** — 05 §5-2).
// 🔴 **«동작»만이다**(G-29) — 상태 구독은 `OpsStatusRepository`·`OpsSummaryRepository` 다.
//    화면이 `run()` 을 폴링해 상태를 만들면 경계 규칙 ① 위반이다.
// 🔴 «적용»류는 **`run()` 1회 + `handoffRoute` 이동**으로 끝난다. 냉각 30일·12월 창·48h
//    대기·체크리스트 7항 UI 를 화면이 만들면 반려다.
// 🆕 v1.16(01 §25) — 온보딩 args 화이트리스트(`onboardingOperatingModeSelect` · `onboardingDryRunStart` · 검증 3) ·
//    O-00b·O-03·O-04 는 결과를 읽는다.
// 🆕 v1.18(01 §27) — M9 `S07` args 화이트리스트(`connectionTest`·`connectionSyncNow` = `{target}` ·
//    `notifyChannelSelect` = `{channel}`) · S07 은 결과를 읽는다(`SettingsResultCodes`).
// 🆕 v1.19(01 §28) — M9 `S05` args 화이트리스트(전환 2 · 엔진 시작·중지 · 승격) · S05 는 결과를 읽는다.
// 🆕 v1.20(01 §29) — M9 `S02`·`S06`·`S03` args 화이트리스트(검증 1단 · 발급 · 폐기 · 매핑 · 전체 검증) · 🔴 시크릿 값 args 0.
// 🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드 args 화이트리스트(handover +3 · 확정 = 기존 `handoverCommit`).
// 🆕 v1.23(01 §32 · K77) — M9 `S13` 월 납입 = 원문 제출 DTO `ContributionUpdateSubmission` + `runContributionUpdate`(표면 run·runContributionUpdate·watch 셋 — C-7) · `run` 화이트리스트 밖.
// 🆕 v1.31(01 §40 · K239) — 온보딩 검증 +1 `supabaseSignIn` = `{}`(o_07 ③ 로그인 · 결과 = `SupabaseAuthResultCodes` ∪ 전송 6).
// 🆕 v1.39(01 §48 · K349 ④) — `supabaseSignIn` 통과 뒤 공개 가입 확인 1회(`/auth/v1/settings` `disable_signup`) · 열림 = `SUPABASE_SIGNUP_OPEN`
//    (`SupabaseSignupResultCodes` · o_07 VERIFIED 아님 · 새로고침 토큰은 금고에 둔다 · 다시 누르면 다시 확인).
// 🆕 v1.24(01 §33 · K120) — M9 `S09`·`S10` args 화이트리스트(`backupRunNow`·`selftestGoldenRun`·`selftestIntegrityRun` = `{}`) · `backupRestoreStart` = 화면 미호출 · 두 화면은 결과를 읽는다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/ui.dart';

part 'settings_actions.freezed.dart';
part 'settings_actions.g.dart';

/// 설정·진단 동작의 주입 콜백.
///
/// 🔴 **`args` 는 화이트리스트다** — 「무엇을 뺄까」가 아니라 「무엇만 넣을까」로 정의한다.
///    키는 **snake_case** 다(H-7 — `Map<String, String>` 이므로 Dart 관례가 아니라 전송 규약을 따른다):
///
///    · `handoverAdoptionSet`      = `{handover_session_id, symbol, disposition ∈ {ADOPT, EXTERNAL}}`
///    · `handoverExternalRegister` = `{handover_session_id, symbol, quantity, account_alias,
///                                     action ∈ {REGISTER, RELEASE}}`
///    · `handoverCommit`           = `{handover_session_id}`
///
///    🔴 `handover_session_id` 는 세 동작 모두 **필수**이고 그 토큰의 정의처는 §6-6
///    `handover_session` 이다(G-02). 🔴 세 동작 모두 `decision_log(kind='MANUAL')` 1행을
///    **엔진이** 낳으며, 그 세 갈래는 재량 예산·이탈 집계의 모집단이 **아니다**(§10-3).
///
///    🆕 v1.12(01 §21 · K9) — `L-3` 실사 세션(폰 로컬 · 뷰어 경로 0):
///    · `selfReportSessionStart` = `{yyyy_mm, account_alias}`(라우트 두 값 그대로 · 🔴 계좌 전체번호 금지)
///    · `selfReportSessionStop`  = `{yyyy_mm, account_alias}`
///    🔴 가림 범위 = **그 폰 한 대**(뷰어 iOS·웹은 가리지 않는다 · ✅ 발주자 2026-10-22). 화면은 [ActionResult] 를
///    읽지 않는다(갈래 = `SelfReportSession.sessionClosedText` 하나) · `dispose` 의 stop 은 `initState` 에서 잡아 둔
///    인스턴스로 부른다(`dispose` 안 `ref` 0 · C-46 ㉔).
///
///    🆕 v1.16(01 §25 · K13 · K19 · K24) — X3 온보딩(폰 로컬 · 뷰어 경로 0):
///    · `onboardingOperatingModeSelect` = `{operating_mode ∈ {AUTO_TRADE, ADVISORY}}`(값 = `OperatingMode.wire` —
///      화면이 고른 카드의 `OperatingModeOption.mode.wire` 그대로) · 결과 = 접수(`ok`) / 거부(`blocked` ·
///      `ONBOARDING_CHOICE_COMMITTED` · `committed_at` 뒤 — 이후 변경 = `runtimeOperatingModeSwitchRequest` → 🔒 `M5-11`) ·
///      같은 값 재선택 = 접수(멱등)
///    · `onboardingDryRunStart`        = `{}`(O-04 ⑥ · 종착 조합은 엔진이 `onboarding_choice` 로 안다 ·
///      첫 `committed_at` 과 같은 트랜잭션 · 실패 = 둘 다 되돌림 `DRY_RUN_START_ROLLED_BACK`)
///    · 검증 동작 — `OnboardingAction` 이 id·args 를 **완성해서** 싣는다(🔴 화면은 그대로 넘긴다 · 짓지 않는다):
///      `credentialVerify` = `{kind}` · `connectionTest` = `{target}` · `accountVerifyMapping` = `{}` ·
///      🆕 v1.31(01 §40 · K239) `supabaseSignIn` = `{}`(o_07 ③ · 값 = 슬롯 `SECRET_SUPABASE_LOGIN` ↔ 구현 사이만 · args · 결과 0)
///      (`kind`·`target` 값 = 엔진 표기 — 05 §7 꼴 · 값 사전 = 01 §8 미결 151)
///    🔴 `O-00b`·`O-03`·`O-04` 는 [ActionResult] 를 **읽는다** — `headline` + `reasonCode` 원문
///      (`O-03` 은 + `retryable` · `O-00b`·`O-04` 는 다시 시도 갈래가 없다 — 표본 `retryable` 전부 false)
///      (표본 = `m8/onboarding_mode_select_results` · `m8/onboarding_verify_results` · `m8/onboarding_finish_results`).
///      `level`·`handoffRoute`·`actionRunId` 로 화면이 분기하지 않는다(아이콘 = `level` 5값 전수).
///
///    🆕 v1.18(01 §27 · K-r · K-s · K-u) — M9 `S07`(폰 로컬 · 운영 등급 · 뷰어 경로 0):
///    · `connectionTest`·`connectionSyncNow` = `{target ∈ ConnectionTargetCodes}`(엔진이 `ConnectionRow.actions` 에 완성 —
///      값 = 그 행의 `target` · 🔴 화면은 그대로 넘긴다 · 01 §8 미결 151 의 `target` 몫 해소)
///    · `notifyChannelSelect` = `{channel ∈ NotifyChannelCodes}`(`NotifyChannelOption.selectAction`)
///    🔴 `S07` 은 [ActionResult] 를 읽는다 — `headline` + `reasonCode` 원문(`SettingsResultCodes`) · `retryable` 전부 false
///      (버튼 = 행 `actions` 뿐 · 05 «재시도 무한 버튼 0») · `handoffRoute` null(표본 = `m9/settings_action_results`).
///    🆕 v1.19(01 §28 · K6 · K7 · K16) — M9 `S05`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `runtimeModeSwitchRequest`          = `{run_mode ∈ RunMode.wire}`(`RunModeCard.switchActions` · 실전 전환 =
///      `handoffRoute` `m5HandoverWizard`(K-h) · advisory 안내 개시 = `m5HandoverGate` — 목적지 = 엔진)
///    · `runtimeOperatingModeSwitchRequest` = `{operating_mode ∈ OperatingMode.wire}`(`OperatingModeView.switchActions` ·
///      값 ≠ 지금 `current` · 목적지 `M5-10`/`M5-11` = 엔진)
///    · `runtimeEngineStart`                = `{}`(`EngineControl.startAction` · 기동 거부 = `reasonCode` ∈ `ModeStartupCodes` ∪
///      `AdviceRejectCodes.modeCombinationDenied`)
///    · `runtimeEngineStop`                 = `{reason_code ∈ EngineStopReasonCodes}`(`EngineControl.stopActions` — 사유마다 1)
///    · 🆕 `runtimeLivePromotion`           = `{}`(`RunModeCard.promotionAction` · 생체 1회 = 구현 · 결과 `reasonCode` ∈
///      `LiveObservationBlockCodes` ∪ `LivePromotionResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`, 🆕 v1.39 `LEASE_INVALID`}
///      · 🆕 v1.39(01 §48 K346) 사전 판정 차례 = 생체 → 세션 → 관찰 중 → 자동 매매 → 시각 → 리스 → 설정(`LIVE_PROMOTION_CONFIG_UNAVAILABLE`) → 재판정 ·
///      생체 대화상자 목적 = `BiometricPurpose.livePromotion`(01 §48 K350))
///    🔴 키 `target` 을 쓰지 않는다(C-5 `connection_target` 사전 키). `S05` 는 [ActionResult] 를 읽는다 — `headline` + `reasonCode`
///      원문 · `handoffRoute` 가 있으면 `AppLinkOpener.open(handoffRoute)` 하고 끝 · `retryable` 전부 false(버튼 = VM 의 호출뿐)
///      (표본 = `m9/operations_action_results`).
///    🆕 v1.20(01 §29 · K5 · K6 · K15 · K19 · K32 · K33) — M9 `S02`·`S06`·`S03`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `credentialVerify`          = `{kind ∈ CredentialKindCodes}`(`CredentialCardVm.verifyAction` · 🔴 1단 — 통과 = 구현이 Keystore 에 저장 ·
///      값은 슬롯 위젯 ↔ 이 구현 사이(조립 앱 내부)로만 · args·VM·결과 어디에도 0) · 거절 = `CREDENTIAL_REJECTED`(온보딩 한 벌) ·
///      다른 환경 키 = `WRONG_KEY_SET` · 생체 = `BIOMETRIC_UNAVAILABLE`
///    · `credentialRegister`        = 🔴 화면 미호출(1단 · 조립·엔진 내부 — 회전 마법사 `M4-4` 등 · args 미정 유지)
///    · `devicePairingTicketCreate` = `{}`(`PairingTicketCard.issueAction` · 티켓·QR = VM 스트림 + 슬롯 — 결과에 페이로드 0)
///    · `deviceTokenRevoke`         = `{device_id}`(`DeviceRow.revokeAction` · 값 = 그 행 `deviceId` — 🔴 화면은 읽지 않는다 ·
///      중복 = `DEVICE_ALREADY_REVOKED`)
///    · `accountMapSleeve`          = `{sleeve ∈ {A, B, C}, account_alias}`(`AccountMappingOption.selectAction` · 🔴 계좌번호 키 0 · 엔진이 안에서
///      드라이런 + SAF-309 재확인 뒤 원자 저장 · 거부 = `Saf309Codes` · `MAPPING_VERIFY_FAILED`)
///    · `accountVerifyMapping`      = `{}`(v1.16 그대로 · `AccountMappingVm.verifyAction` = 전체 검증)
///    🔴 R7 세 화면은 [ActionResult] 의 `headline` + `reasonCode` 원문만 읽는다 — `handoffRoute`·`retryable` 미참조(표본 null·false ·
///      다시 시도 = VM 의 같은 버튼)(표본 = `m9/credential_action_results` · `m9/device_action_results` · `m9/account_mapping_action_results`).
///    🆕 v1.23(01 §32 · K77) — `settingsContributionUpdate` = **제출 경로**(`runContributionUpdate(ContributionUpdateSubmission)`) ·
///      🔴 `run` 화이트리스트 **밖**(사람이 친 금액 = 원문 제출 DTO — K7 이 표면 고정을 이긴다 · v1.22 K52 선례 · `run(settingsContributionUpdate)`
///      = 구현 `ArgumentError`) · 결과 id = 늘 `settingsContributionUpdate` · `reasonCode` ∈ `ContributionResultCodes` ∪
///      {`TRUSTED_TIME_UNKNOWN`, `BIOMETRIC_UNAVAILABLE`} ∪ null(접수) · `handoffRoute` null · `retryable` false
///      (표본 = `m9/contribution_action_results`) · R9 동작 = 🆕 v1.24(아래).
///    🆕 v1.24(01 §33 · K111 · K112 · K114 · K115 · K120 · K132) — M9 `S09`·`S10`(폰 로컬 · 운영 등급 · 뷰어 경로 0 · 엔진이 `SettingsActionCall` 에 완성):
///    · `backupRunNow`         = `{}`(`BackupVm.runAction` · 구현 권고 = X1 스냅숏 `take` — live 원장만 · 트랜잭션 밖 · 아카이브 `IN_SYNC` 일 때만 ·
///      결과 `reasonCode` ∈ `BackupResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`} ∪ null(접수))
///    · `backupRestoreStart`   = 🔴 화면 미호출(복원 = X1 마법사 · 새 폰 `R-01` — 같은 폰 복원 = 엔진 `X1_LIVE_EXISTS` · args 미정 유지)
///    · `selftestGoldenRun`    = `{}`(`DiagnosticsScreenVm.golden.runAction` · 실행기 = E11o — 전 = 버튼 부재 · 결과 `reasonCode` ∈
///      {`BIOMETRIC_UNAVAILABLE`} ∪ null — 통과·불일치 = `headline` 만 · 코드를 지어내지 않는다)
///    · `selftestIntegrityRun` = `{}`(`DiagnosticsScreenVm.integrity.runAction` · 구현 권고 = 정본 자가 대조(로컬 · 브로커 0) · 🔴 불일치 =
///      `LEDGER_INTEGRITY` 차단(일일 잡과 같은 fail-closed — 엔진 headline 이 말한다) · 결과 `reasonCode` ∈ `LedgerIntegrityResultCodes` ∪
///      {`BIOMETRIC_UNAVAILABLE`} ∪ null(일치))
///    🔴 두 화면은 [ActionResult] 의 `headline` + `reasonCode` 원문만 읽는다 — `handoffRoute`(늘 null)·`retryable`(늘 false)·`level` 분기 0
///      (표본 = `m9/backup_action_results` · `m9/selftest_action_results`). ⏸ `calendarSyncNow`·`calendarRebackfill`·`calendarReconnect`
///      = X4(⏸ R9d · 01 §8 미결 5 · 196) · `settingsGeneralUpdate` = S11 창(⏸ R9e · 미결 197) — args 미정 유지.
///    🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드(🔒 `ui_safety` · 폰 로컬 · 뷰어 경로 0 · M9 `S05` 는 부르지 않는다):
///    · `handoverSimLedgerFate` = `{fate ∈ {KEEP, DISCARD}}`(엔진 `SimLedgerFate.wire` · 🔴 **세션 전** — 5단계는 6단계 생체(세션 열림) 앞이라
///      `handover_session_id` 를 넣지 않는다 · 결과 `reasonCode` ∈ {`SIM_LEDGER_FATE_SIM_CLOSED`, `SIM_TO_AUTO_NOT_SIM_AUTO`,
///      🆕 v1.39 `SIM_LEDGER_FATE_CONFIG_UNAVAILABLE`(01 §48 K346 · 모의 파일 지금 설정 못 읽음 = 쓰기 0)})
///    · `handoverSessionStart`  = `{path ∈ {SIM_TO_AUTO}}`(1.22.0 화이트리스트 = 하나 · 생체 1회 = 구현 · 결과 `reasonCode` ∈
///      `SimToAutoResultCodes` ∪ `SimToAutoStepIds` ∪ `HandoverSessionResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`} · 🆕 v1.39 생체 대화상자
///      목적 = `BiometricPurpose.handoverStart`(«실전 전환 시작» — 서약 글자 0 · 01 §48 K350))
///    · `handoverSessionCancel` = `{handover_session_id}`(결과 = 정상 · `HANDOVER_SESSION_INVALID`)
///    · `handoverCommit`(simToAuto) = 위 그대로 `{handover_session_id}` · 결과 `reasonCode` ∈ `SimToAutoCommitResultCodes` ∪ `SimToAutoResultCodes` ∪
///      `SimToAutoStepIds` ∪ {`HANDOVER_SESSION_INVALID`, `LEASE_INVALID`}(구현 = 엔진 오케스트레이터 `SimToAutoSwitchResult` · 🆕 v1.39 엔진 예약
///      3 등재 = `SIM_TO_AUTO_CONFIG_NOT_APPROVED` · `SIM_TO_AUTO_ACCOUNT_DUPLICATE` · `SIM_LEDGER_FATE_CONFIG_UNAVAILABLE` — 사전 안)
///    🔴 위 «세 동작 모두 필수»(`handover_session_id`)는 adoption·external·commit 셋의 조문이다 — `handoverSimLedgerFate` 는 그 밖.
///    🔴 결과 문구 = 엔진 `headline`(확정 성공 문장 = 금액을 품는다 → 표본 0) · 🆕 v1.26 위저드 읽기 창구·VM = `HandoverRepository.watchWizard` · `HandoverWizardVm`(01 §35 · K167~K169 · 미결 187 닫음 · 단계별 허용 id = 행 머리).
///
/// 🔴 **`Config.fx_overlay` 계열 키를 `strategyPreview`·`strategyApplyRequest` 의 args 에
///    넣지 않는다** — 영구 기각된 규칙의 부활 경로다(P 회차 실측: 반사실 부호 역전).
///
/// ⚠️ 나머지 동작(🆕 v1.24 기준 = `strategyPreview`·`strategyApplyRequest`(S04 편집기 판 — v1.28 첫 판 = 보기 전용 · 호출 0) · `credentialRegister`·`backupRestoreStart`(화면 미호출) ·
///    calendar 3 · `settingsGeneralUpdate`)의 args 스키마는 **미확정**이다(§4-3 말미 · 05 §7 표가 입력) — 확정 전에는
///    화면이 키를 지어내지 않는다.
abstract interface class SettingsActions {
  /// ⚠️ 01 §4-3 원문은 `{Map<String, String> args}` 이지만 Dart 에서 non-nullable 선택
  ///    명명 인자는 기본값 없이는 선언되지 않는다 — **의미(선택·비어 있을 수 있음)를 지키는
  ///    최소 보정**으로 `const {}` 기본값을 둔다. 타입·이름은 원문 그대로다.
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  });

  /// 🆕 v1.23(01 §32 · K77) — M9 `S13` 월 납입 운영값 변경(운영 등급 · 생체 = 구현). 🔴 화면은 입력칸 글자를 **원문 그대로** 싣는다
  ///    (손질·파싱·범위 판정·버튼 비활성 0 · 빈칸·0 도 보낸다) · `actionRunId`·기기 id·신뢰 시각 = 구현.
  ///    🔴 E11k(신뢰 시각) 전에는 형식이 맞는 입력 전부 `TRUSTED_TIME_UNKNOWN`(fail-closed · K98).
  Future<ActionResult> runContributionUpdate(
    ContributionUpdateSubmission submission,
  );

  Stream<ActionResult> watch(String actionRunId);
}

/// 동작 1회의 결과.
@freezed
abstract class ActionResult with _$ActionResult {
  const factory ActionResult({
    required String actionRunId,
    required SettingsActionId id,
    required UiLevel level,

    /// 결과 문구 — 🔴 엔진 생성(요약·의역 금지).
    /// 🔴 월 납입 범위 판정 같은 «허용/불허»도 이 문장과 `reasonCode` 로만 돌아온다 —
    ///    화면이 범위를 미리 알면 「저장 버튼 비활성」이라는 **화면의 판정**이 생긴다(§2-6).
    required String headline,

    /// 원문 코드(예 `'EGW00133'`)가 있으면 함께 온다.
    /// 🆕 v1.16 — 값 = 사전 등재 코드(`OnboardingResultCodes` · `BrokerRawCodes` 등 · C-5) · 화면은 글자 그대로(분기 0).
    String? reasonCode,

    /// 🔴 게이트가 필요한 동작은 여기로 넘긴다(M5).
    /// ⏸ H-9 — 반환값은 M5·X1·X2·X5 라우트 **권고 확정 목록에 있는 이름만**이며 화면이
    ///    이름을 지어 쓰지 않는다.
    String? handoffRoute,
    required bool retryable,
  }) = _ActionResult;

  factory ActionResult.fromJson(Map<String, dynamic> json) =>
      _$ActionResultFromJson(json);
}

/// 🆕 v1.23(01 §32 · K77 · K103) — M9 `S13` 월 납입 변경 «화면 제출»(core `decideContributionChange(amountInput …)` :304 ·
/// ds `ContributionSettingSource.change({amountInput, actionRunId})` :119 의 사람 몫 1 칸).
/// 🔴 [amountInput] = 입력칸 글자 **원문 그대로**(콤마·공백·빈칸·음수·글자 포함 가능 — 판정 = 엔진 차례 빈칸 → 음수 → 숫자 아님 →
///    상한 → 신뢰 시각 → 시계 전진 → 같은 값) · `actionRunId`(재생 멱등 = 같은 회차만)·기기 id·신뢰 시각 = 구현이 붙인다(화면 생성 0).
@freezed
abstract class ContributionUpdateSubmission
    with _$ContributionUpdateSubmission {
  const factory ContributionUpdateSubmission({required String amountInput}) =
      _ContributionUpdateSubmission;

  factory ContributionUpdateSubmission.fromJson(Map<String, dynamic> json) =>
      _$ContributionUpdateSubmissionFromJson(json);
}
// JSON 키: amount_input
```

---

## `packages/domain_contracts/lib/src/dto/accounts.dart`

```dart
// 01 §29 · 🆕 계약 v1.20(R7 선행 · K19~K21 · 발주자 위임 2026-11-14 — 권고대로) — M9 `S03` 계좌 연동·슬리브↔계좌 매핑.
//
// 🔴 계좌 전체번호·계좌 종류 코드·별칭 키는 어떤 칸에도 오지 않는다 — 번호 = 엔진 마스킹 글자(`maskAccount` «****1234» · SAF-906) ·
//    종류 = 글자(`kindLabel`) · 별칭 = 엔진이 완성한 호출의 args 안에만(`accountMapSleeve{sleeve, account_alias}`).
// 🔴 칸 수 = 받은 [AccountMappingVm.mappings] 길이(P0S = A·B·C 3행 · POT 행 0 — A 행의 [SleeveMappingRow.subbookLine]) ·
//    선택지 = 엔진이 미리 판정해 싣는다(SAF-309 막힘 = [AccountMappingOption.blockedText] · 영향 = [AccountMappingOption.impacts]) ·
//    확인 = 화면 안 펼침(시트·다이얼로그 0 · K18) · «확인» = [AccountMappingOption.selectAction] run 1회(엔진이 안에서 드라이런 · SAF-309 재확인 뒤
//    원자 저장 — pending 0 · K19).
// 🔴 화면이 계좌 종류로 절세 여부를 판정하지 않는다 · 세후 갈래를 계산·전달하지 않는다 · 금액 0.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'onboarding.dart'; // SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다 — ops.dart 선례)
import 'settings.dart'; // SettingsActionCall

part 'accounts.freezed.dart';
part 'accounts.g.dart';

/// 🆕 v1.20 — `S03` VM(창구 = `SettingsRepository.watchAccountMapping()` · 폰 전용).
@freezed
abstract class AccountMappingVm with _$AccountMappingVm {
  const factory AccountMappingVm({
    /// 계좌 목록 — 받은 차례 · 1행 이상(엔진 의무 · K29). DC·IRP = «시스템 밖 자산(수동)» 배지 행(매핑 선택지에는 엔진이 넣지 않는다).
    required List<AccountRow> accounts,

    /// 슬리브 칸 — 받은 길이·차례(🔴 칸 수 상수 0 · POT 행 0 · K20).
    required List<SleeveMappingRow> mappings,

    /// 전체 검증(`accountVerifyMapping{}` · 잔고 드라이런). null = 버튼 부재.
    SettingsActionCall? verifyAction,

    /// 운영 등급 생체 축소(non-null = 보기만). 🔴 엔진 의무 = [verifyAction] null · 모든 선택지 `selectAction` null · `impacts` 빈(K35).
    String? lockedLabel,
    required AsOf asOf,
  }) = _AccountMappingVm;

  factory AccountMappingVm.fromJson(Map<String, dynamic> json) =>
      _$AccountMappingVmFromJson(json);
}
// JSON 키: accounts · mappings · verify_action · locked_label · as_of

/// 🆕 v1.20 — 계좌 1행.
@freezed
abstract class AccountRow with _$AccountRow {
  const factory AccountRow({
    /// «연금저축» — 엔진(사람 별칭 글자).
    required String label,

    /// «연금저축 22» · «ISA 중개형» · «퇴직연금 DC» — 엔진 글자(🔴 종류 코드 칸 0 — 화면이 종류로 판정하지 못하게).
    required String kindLabel,

    /// 엔진 마스킹 글자(«****4821») — 🔴 화면이 자르거나 다시 가리지 않는다.
    required String maskedNumberText,

    /// 잔고 드라이런 배지 한 줄. null = 줄 없음.
    String? checkText,

    /// «시스템 밖 자산(수동)» 류 배지. null = 배지 부재.
    String? badgeText,
    required UiLevel level,
  }) = _AccountRow;

  factory AccountRow.fromJson(Map<String, dynamic> json) =>
      _$AccountRowFromJson(json);
}
// JSON 키: label · kind_label · masked_number_text · check_text · badge_text · level

/// 🆕 v1.20 — 슬리브 칸 1행.
@freezed
abstract class SleeveMappingRow with _$SleeveMappingRow {
  const factory SleeveMappingRow({
    /// «슬리브 A» — 엔진.
    required String sleeveLabel,

    /// 지금 연결된 계좌 글자. null = 미지정(그 사실의 글자 = [statusLine]).
    String? accountLabel,

    /// A 행의 POT 서브북 한 줄(«POT 서브북도 이 계좌에서 운용합니다») — 🔴 4번째 칸 아님. null = 줄 없음.
    String? subbookLine,

    /// 상태 한 줄(미지정 · 잔고 확인 실패 등) — 엔진. null = 줄 없음(정상).
    String? statusLine,
    required UiLevel level,

    /// 선택지 — 받은 차례(지금 계좌 = `selected` · 막힌 선택지 = `blockedText`).
    required List<AccountMappingOption> options,
  }) = _SleeveMappingRow;

  factory SleeveMappingRow.fromJson(Map<String, dynamic> json) =>
      _$SleeveMappingRowFromJson(json);
}
// JSON 키: sleeve_label · account_label · subbook_line · status_line · level · options

/// 🆕 v1.20 — 계좌 선택지 1개(`NotifyChannelOption` 꼴 · 🔴 기본 선택을 화면이 정하지 않는다).
/// 🔵 이름 = `AccountMappingOption`(설계서 이름표 #13 의 «AccountOption» 은 v1.12 `dto/advice.dart` `AccountOption{alias, label}`
///    (`ManualFillFormSpec.accounts`)과 겹쳐 배럴 export 가 모호해진다 — 구현 실측 · K39 · 발주자 위임 2026-11-14 — 권고대로).
@freezed
abstract class AccountMappingOption with _$AccountMappingOption {
  const factory AccountMappingOption({
    /// «ISA · ****7730» — 엔진.
    required String label,

    /// 지금 연결된 계좌(행마다 많아야 1 · 엔진 의무).
    required bool selected,

    /// 펼침 확인에 보일 «이 변경이 영향을 주는 것» 줄 — 엔진. 🔴 [selectAction] non-null ⇔ 비지 않음.
    @Default(<String>[]) List<String> impacts,

    /// SAF-309 등 미리 판정한 막힘 사유 — 엔진 글자. 🔴 non-null ⇒ [selectAction] null.
    String? blockedText,

    /// 엔진이 완성한 `accountMapSleeve{sleeve, account_alias}`. null = 고를 수 없음(지금 계좌 · 막힘 · 잠김).
    SettingsActionCall? selectAction,
  }) = _AccountMappingOption;

  factory AccountMappingOption.fromJson(Map<String, dynamic> json) =>
      _$AccountMappingOptionFromJson(json);
}
// JSON 키: label · selected · impacts · blocked_text · select_action
```

---

## `packages/domain_contracts/lib/src/dto/advice.dart`

```dart
// 01 §2-11 — X7 투자 안내 뷰모델(안내 · 폼 선택지).
//
// 🔴 계산 산출물이므로 화면이 만들지 않는다(경계 규칙 ①).
// 🔴 금액 필드는 «가격»뿐이고 평가액·손익은 타입에 없다(결정 8).
// 🔴 A7 — `AdviceItem` 에 `mode`·`operatingMode` 필드를 두지 않는다. 모드가 표시에
//    영향을 주는 자리는 셸의 띠 하나뿐이고 그것은 `FeatureFlags` 가 담당한다.
// 🔴 §10-7 — viewer 판은 종목·수량·가격이 **오지 않는다**(A6 마스킹 · C-27).
// 🆕 계약 v1.12(01 §21 · R5 선행) — 버튼·카드의 목적지는 데이터로 온다(`AdviceAction.deepLink` ·
//    `AdviceItem.detailDeepLink` · K5) · 만료 확인 카드·수량 채우기·회수 문장·방향 글자 · 요약의 현금 고지·
//    «미확인 만료 n건»·안내 밖 기록 링크 · 폼 사양의 방향·거래일 선택지·`A-4` 문구·제출 차단 문장(K13~K22 · K37 ·
//    K39) · 🆕 `SideOption`·`TradeDateOption`. 🔴 새 이름은 쓰기 동사 접두를 피한다(C-7 `_writeVerb` · G57).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/order.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'ledger_trust.dart';

part 'advice.freezed.dart';
part 'advice.g.dart';

/// 01 §2-11 — 안내 1건.
/// 🔴 `kind == noAction` 이면 폰 판에서도 `symbol`·`quantity`·`side` 가 null 이고
///    `suppressed == true` · `suppressedLabel` 필수 · `actions` 는 빈 목록이다(G-08).
/// 🆕 v1.12(01 §21) — 🔴 `status`(저장값)·`closeReasonCode` = ui 미참조 · `effectiveStatus` 는 02 §8-14 의
///    «배지·정렬» 몫이지만 v1.12 는 배지 = `statusLabel`·`statusTone` · 정렬 = 엔진(K13 — 확인 카드 → `isUrgent`
///    → 나머지)이라 화면 분기 0(C-18 (d) · C-46 ⑱) · `onHold`·`suppressed` = 짝 글자(`holdReasonLabel`·
///    `suppressedLabel`)의 null 여부로만.
@freezed
abstract class AdviceItem with _$AdviceItem {
  const factory AdviceItem({
    required String adviceId,
    required String batchId,
    required AdviceKind kind,

    /// 안내가 겨냥한 거래일.
    @TradeDateConverter() required TradeDate tradeDate,
    required DateTime issuedAt,

    /// 🔴 거래일 달력. 화면이 D-day 를 세지 않는다.
    @TradeDateConverter() required TradeDate validUntilDate,

    /// "오늘 장 마감까지 · D-0" — 엔진 생성.
    required String validityLabel,

    /// 계열 표시용 — viewer 도 본다.
    required SleeveId sleeve,

    /// "3분할 중 2회차 · 12주" — 엔진 생성.
    /// 🔴 `unverifiable`·`drifting` 등급의 청산 안내는 수량 대신 «보유 전량» 계열
    ///    표현이 오며, 바뀌는 것은 라벨뿐이고 `quantity` 는 엔진이 아는 최선의
    ///    원장값으로 채운다(G-85).
    required String sizingLabel,

    /// "12주 중 7주 기록됨" — 엔진 생성.
    /// 🔴 viewer 판은 `phoneOnlyLabel` 과 같은 고정 문장이다(G-21).
    required String progressLabel,

    /// 진입 사유 / 청산 티어 — 🔴 최소 1개.
    required List<ReasonChip> reasons,

    /// 🔴 저장값. 화면은 배지·정렬에도 이것을 쓰지 않는다.
    required AdviceStatus status,

    /// 🔴 만료는 UPDATE 가 아니라 **파생 판정**이다(A4). 화면이 쓰는 유일한 값.
    required AdviceStatus effectiveStatus,
    required String statusLabel,
    required ChipTone statusTone,

    /// 🔴 A8 — 버튼의 유일한 근거. 상태를 조합해 버튼을 판정하지 않는다.
    /// 🆕 v1.12(K5) — 엔진은 RECORD·SKIP 만 싣는다(DETAIL 0 — 상세 = [detailDeepLink]) · viewer 판 = **빈 목록**
    ///    (K6 · 01 §6-4 rm_advice) · 배치 결측(`AdviceInboxSummary.staleLabel` non-null) = RECORD 만(K41).
    required List<AdviceAction> actions,

    /// 🔴 A1 — «안내와 다름»은 명령 집행 후 엔진이 **사후** 재발행으로 싣는다.
    required List<ReasonChip> recordedDeviationChips,

    /// 🔴 손절 계열 — 알림 등급의 근거. 화면은 배지만 그린다.
    required bool isUrgent,

    /// 선행 미이행이면 보류.
    required bool onHold,

    /// decision_log 체인 — 자동 모드와 **같은 타입**.
    required DecisionRef decision,

    /// 🔴 엔진이 안내를 낼 수 없는 상태.
    required bool suppressed,

    /// 🔴 G-86 — 만료 확인 카드의 「내일 다시」 노출 여부. **엔진 판정**이며
    ///    화면이 «몇 번 미뤘나»를 세지 않는다(저장 정본은
    ///    `advice_transition(cause_code='DEFER_CONFIRM')` 행의 존재 자체다).
    required bool deferAvailable,
    required AsOf asOf,

    /// 🔴 viewer 판은 null(A6) · `kind == noAction` 이면 폰 판도 null(G-08).
    String? symbol,
    String? symbolLabel,

    /// "종목·수량은 운영 폰에서 확인합니다" — 엔진 생성.
    String? phoneOnlyLabel,
    OrderSide? side,
    int? quantity,

    /// 🔴 viewer 판은 null · null 이면 라벨이 그 사실을 말한다.
    AdvicePriceBand? priceBand,

    /// 지금까지 기록된 합 — 🔴 화면이 더하지 않는다.
    /// 🔴 viewer 판은 null(0 을 채우면 「0주 기록됨」이라는 거짓이 된다 · G-22).
    int? recordedQuantity,

    /// skipped·expired·superseded·revoked 의 사유 코드.
    String? closeReasonCode,

    /// 🔴 조달 순서 의존(`PENSION_FUNDING` · X2 «매도 먼저»).
    String? dependsOnAdviceId,
    String? holdReasonLabel,

    /// "연금저축" — 🔴 계좌 전체번호 금지.
    String? accountAlias,

    /// "골든벡터 재검증 실패 — 오늘은 아무것도 하지 마십시오" 계열.
    String? suppressedLabel,

    // ── 🆕 계약 v1.12(01 §21 · R5 선행) ──────────────────────────────────────────
    /// 카드 탭 → `A-2`(`aaq://advice/detail/<adviceId>` — 엔진 완성 · K5). 🔴 전 플랫폼(뷰어 포함).
    required String detailDeepLink,

    /// "매수" — 🔴 viewer 판·`kind == noAction` 은 null([side] 와 같이 비운다 · §10-7 · K16).
    String? sideLabel,

    /// non-null ⇔ `A-1` 상단 **만료 확인 카드**로 그린다("혹시 이미 매매하셨나요?" — 엔진 · K13).
    /// 🔴 엔진이 고른다: `effectiveStatus == expired` · 미분류 · X2 일괄 만료 아님 · **최대 3장** · 목록 **맨 앞**(02 §3-6 C16).
    /// 🔴 확인 카드 밖의 미분류 만료는 `watchInbox` 행에 **오지 않는다** — `AdviceInboxSummary.overdueUnrecordedLink` 1줄과
    ///    `watchHistory` 에만 있다. 확인 카드의 [actions] == [RECORD, SKIP](순서까지).
    String? expiredConfirmLabel,

    /// → `J-2`(`aaq://journal/decision/<decision.decisionId>` — 엔진 완성 · K18). `A-2` 「결정 당시 스냅샷」 = 이 링크 1개 ·
    /// 뷰어 non-null(`journalDecision` = 전 플랫폼 목적지 · K6).
    LinkAction? decisionLink,

    /// `A-3` 「안내 수량 채우기」 — 입력칸에 넣을 원문("200"). 🔴 [prefillQuantityLabel] 과 둘 다 null 이거나 둘 다 non-null ·
    ///    폰 판 · `effectiveStatus ∈ {open, partial}` 만(엔진 · K19). 누르면 `ManualFillInput.prefilledFields` 에
    ///    `ManualFillPrefillFields.quantity` 를 더한다(A1 · 02 §3-8).
    String? prefillQuantityText,

    /// "안내 수량(200주) 채우기" — 엔진.
    String? prefillQuantityLabel,

    /// non-null ⇔ [closeReasonCode] non-null — 닫힌 사유의 엔진 문장(회수 = «사람 잘못이 아닙니다» 계열 · B8 · K39).
    String? closeReasonLabel,
  }) = _AdviceItem;

  factory AdviceItem.fromJson(Map<String, dynamic> json) =>
      _$AdviceItemFromJson(json);
}

/// 01 §2-11 A8 — 화면은 이 목록을 «순서대로 그리기»만 한다. 없으면 버튼을
/// 만들지 않는다. 🔴 `status`·`effectiveStatus`·`onHold`·`suppressed` 를 조합해
/// 버튼을 판정하지 않는다(조합이 7×2×2×4다).
/// 🆕 v1.12(01 §21 · K5) — 버튼의 목적지는 데이터로 온다(01 §11-1 규칙 ③). 🔴 엔진은 RECORD·SKIP 만 싣는다
///    (DETAIL 0 — 상세 = [AdviceItem.detailDeepLink]) · viewer 판 `actions` = 빈 목록(01 §6-4 · K6).
@freezed
abstract class AdviceAction with _$AdviceAction {
  const factory AdviceAction({
    /// 🔴 ui 미참조(v1.12) — 버튼 = [label] + [deepLink].
    required AdviceActionId actionId,

    /// 엔진 생성.
    required String label,
    required bool enabled,

    /// 엔진 생성 — `enabled == false` 일 때만.
    String? disabledReasonLabel,

    /// 🆕 v1.12 — RECORD → `aaq://advice/fill/<adviceId>` · SKIP → `aaq://advice/skip/<adviceId>`(엔진 완성).
    /// `enabled == false` 여도 있다(누르면 열지 않을 뿐).
    required String deepLink,
  }) = _AdviceAction;

  factory AdviceAction.fromJson(Map<String, dynamic> json) =>
      _$AdviceActionFromJson(json);
}

/// 01 §2-11 — 지정가 밴드. 🔴 `reference` 가 이행 갭의 기준가다.
@freezed
abstract class AdvicePriceBand with _$AdvicePriceBand {
  const factory AdvicePriceBand({
    @DecimalStringConverter() required Decimal low,
    @DecimalStringConverter() required Decimal high,
    @DecimalStringConverter() required Decimal reference,

    /// "38,100 ~ 38,400 지정가" — 엔진 생성.
    required String label,
  }) = _AdvicePriceBand;

  factory AdvicePriceBand.fromJson(Map<String, dynamic> json) =>
      _$AdvicePriceBandFromJson(json);
}

/// 01 §2-11 — 홈 한 줄·알림 앵커·`A-1` 헤더가 **같은 값**을 본다. 🔴 손익 필드 없음.
/// 🔴 `openCount == 0` 이면 홈 블록·배지를 렌더하지 않는다(C14·D16). 예외는 둘 —
///    `hasSuppressedNotice == true` 와 `handoverCoolingActive == true`.
@freezed
abstract class AdviceInboxSummary with _$AdviceInboxSummary {
  const factory AdviceInboxSummary({
    required String batchId,
    @TradeDateConverter() required TradeDate tradeDate,

    /// G-08 정의 — `effectiveStatus ∈ {open, partial}` 이고 `suppressed == false`
    /// 인 안내의 수. `onHold == true` 는 세고 `suppressed == true` 는 세지 않는다.
    /// 🔴 화면이 이 정의를 재구현하지 않는다(목록 길이로 세지 않는다).
    required int openCount,
    required int dueTodayCount,

    /// 🔴 C14 의 예외 ① — 「오늘은 아무것도 하지 마십시오」는 무소식이 아니다.
    required bool hasSuppressedNotice,

    /// 🔴 표류의 선행 지표(만료 미확인 건수).
    required int overdueUnrecordedCount,

    /// "9월 7일 매매 안내 3건 · 미기록 1건" — 엔진 생성.
    required String headline,

    /// 🔴 색의 근거. 값의 부호로 고르지 않는다.
    required UiLevel level,

    /// 🔴 C14 의 예외 ② — 전환 냉각 24h 창(N-1). 화면이 위저드 상태·
    ///    `handover_session` 을 직접 읽어 배너를 만들지 않는다.
    required bool handoverCoolingActive,
    required LedgerTrustBadge trust,
    required AsOf asOf,
    String? dueSoonLabel,

    /// 🔴 A4 — 엔진이 멈추면 안내의 유효성을 보증하지 않는다.
    /// 🆕 v1.12(K41) — [staleLabel] non-null ⇒ 전 행 `actions` ⊆ {RECORD}(엔진 의무 · 02 §3-6 «`A-3` 기록 경로는
    ///    살아 있다») · 킬스위치 = [headline] 에 «신규 안내 중단» 문장 + 행 `statusTone`(엔진 · 화면은 킬스위치를 읽지 않는다).
    String? staleReasonCode,
    String? staleLabel,
    String? handoverCoolingLabel,

    // ── 🆕 계약 v1.12(01 §21) ────────────────────────────────────────────────────
    /// `A-1` 상단 ② 현금 추정 고지(02 §3-6 · K15). null = 부재.
    CashEstimateNotice? cashNotice,

    /// «미확인 만료 n건» 1줄(라벨 = 엔진 · → `aaq://advice/history` · K13 · K38).
    /// null ⇔ 확인 카드 밖 미분류 만료 0(= [overdueUnrecordedCount] 가 확인 카드 수를 넘지 않는다).
    LinkAction? overdueUnrecordedLink,

    /// 하단 「안내에 없는 매매를 기록합니다」(→ `aaq://m5/intervention` · `M5-6` · K17). 뷰어·autoTrade = null.
    LinkAction? manualEntryLink,

    /// 그 링크 앞 엔진 문구("이 기록은 안내 밖 매매로 남고 이번 달 재량 예산 2회 중 1회를 씁니다"). [manualEntryLink] 와 짝.
    String? manualEntryNoticeText,
  }) = _AdviceInboxSummary;

  factory AdviceInboxSummary.fromJson(Map<String, dynamic> json) =>
      _$AdviceInboxSummaryFromJson(json);
}

/// 01 §2-11 — 수기 체결 기록 폼 규격(`A-3`).
/// 🔴 A16 — 창구는 **Stream** 이며 신선도 초과면 화면이 폼을 열지 않는다.
/// 🔴 A3 — `amendReasons`·`voidReasons` 는 여기 **없다**(정정·무효는 `M5-12` 소유).
/// 🔴 B5 — 시간외·단주 힌트도 **없다**(검증 강도를 사람이 고르지 않는다 — 재제출 선택지는
///    `CommandReceipt.retryCode`·`retryLabel` 로 거부 뒤에만 온다 · 🆕 v1.12 K20).
/// 🆕 v1.12(01 §21 · K37) — 🔴 [minTradeDate]·[maxTradeDate]·[nonTradingDates]·[quantityMax] = ui 미참조(엔진·구현
///    검증용 · 수량 상한 초과 = 구현 `INPUT_INVALID`) · 화면은 [sides]·[tradeDateOptions] 를 그대로 고르게 한다.
@freezed
abstract class ManualFillFormSpec with _$ManualFillFormSpec {
  const factory ManualFillFormSpec({
    /// 매핑된 종목만 — 🔴 자유 티커 입력 금지.
    required List<SymbolOption> symbols,

    /// 별칭만.
    required List<AccountOption> accounts,
    required List<ReasonOption> skipReasons,
    @TradeDateConverter() required TradeDate minTradeDate,
    @TradeDateConverter() required TradeDate maxTradeDate,

    /// 🔴 「토·일 제외」 근사는 임시공휴일에 틀린다.
    @TradeDateConverter() required List<TradeDate> nonTradingDates,

    /// "1주당 원화. 세금·수수료는 비워 두면 추정합니다" — 엔진 생성.
    required String priceHintLabel,

    /// 오입력 방어(0 하나 더 찍기).
    required int quantityMax,

    /// "원본은 지워지지 않습니다" — 엔진 생성.
    required String appendOnlyNotice,
    required AsOf asOf,

    // ── 🆕 계약 v1.12(01 §21 · K37 · K21) ─────────────────────────────────────────
    /// `A-3` 방향 선택지("매수"·"매도"). 선택 = `option.side` 그대로(화면이 `OrderSide.*` 를 적지 않는다).
    required List<SideOption> sides,

    /// 고를 수 있는 거래일(엔진이 [minTradeDate]~[maxTradeDate] 에서 휴장일을 뺀다 · 받은 순서). 선택 = `option.date` 그대로.
    required List<TradeDateOption> tradeDateOptions,

    /// `A-4` 제출 전 엔진 문구 1줄("이 안내는 오늘로 닫히고, 다음 배치는 지금 보유 상태로 다시 계산합니다" · 02 §3-9).
    required String skipNoticeText,

    /// non-null = 제출 **부재** + 이 문장(`LEDGER_FIX` 등 · K21). 🔴 화면이 `SafetyState` 로 끄지 않는다.
    String? blockedText,

    /// 폼 고유 배너 1(킬스위치·HALT 중 «시스템 정지 중의 개입으로 남습니다»(B9) · `LEDGER_INTEGRITY` 격리 고지(B18)).
    /// 🔴 §2-2 안전 배너(`BlockFlag`)와 겹치지 않는다 — 그것은 `journalSafetyStateProvider` + `JournalSafetyBanners` 가 그린다.
    String? bannerText,
  }) = _ManualFillFormSpec;

  factory ManualFillFormSpec.fromJson(Map<String, dynamic> json) =>
      _$ManualFillFormSpecFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ①.
@freezed
abstract class SymbolOption with _$SymbolOption {
  const factory SymbolOption({
    required String symbol,
    required String label,
    required SleeveId sleeve,
  }) = _SymbolOption;

  factory SymbolOption.fromJson(Map<String, dynamic> json) =>
      _$SymbolOptionFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ②. 🔴 계좌 전체번호 금지.
@freezed
abstract class AccountOption with _$AccountOption {
  const factory AccountOption({required String alias, required String label}) =
      _AccountOption;

  factory AccountOption.fromJson(Map<String, dynamic> json) =>
      _$AccountOptionFromJson(json);
}

/// 🆕 v1.12(01 §21 · K37) — `A-3` 방향 선택지. 선례 `SymbolOption{symbol, label}`·`AccountOption{alias, label}`
/// («선택지 = 값 + 글자»).
@freezed
abstract class SideOption with _$SideOption {
  const factory SideOption({required OrderSide side, required String label}) =
      _SideOption;

  factory SideOption.fromJson(Map<String, dynamic> json) =>
      _$SideOptionFromJson(json);
}

/// 🆕 v1.12(01 §21 · K37) — 거래일 선택지("8/28(금)" — 엔진). 🔴 화면은 날짜를 만들거나 비교하지 않는다
/// (`DateTime.parse`·서식·`showDatePicker` 0 · C-46 ⑲).
@freezed
abstract class TradeDateOption with _$TradeDateOption {
  const factory TradeDateOption({
    @TradeDateConverter() required TradeDate date,
    required String label,
  }) = _TradeDateOption;

  factory TradeDateOption.fromJson(Map<String, dynamic> json) =>
      _$TradeDateOptionFromJson(json);
}

/// 01 §2-11 · m2-8 H-4 — 폼 선택지 3형제 ③.
/// ⏸ m2-8 H-5 — `J-3` 의 `rule_cited` 목록과 **통합한다**(같은 타입을 쓴다).
///    통합 여부 자체는 §8-20 · D19 의 선행 미결이며, 통합 전까지 사유 목록이 두
///    벌이 되어 한쪽만 갱신되는 사고를 막는 것이 이 결정의 이유다.
@freezed
abstract class ReasonOption with _$ReasonOption {
  const factory ReasonOption({
    required String code,
    required String label,

    /// 🔴 예산 코드 2종은 1줄 메모가 필수다(§3-8 `SKIP_NOTE_REQUIRED`).
    /// 🆕 v1.12(K22) — 정본 = 02 §3-9 표(예산 2종만 true · 나머지 1탭) — 옛 주석 «`other` 계열·» 삭제.
    required bool requiresNote,

    /// 🆕 v1.12(01 §21 · K12) — non-null = 명령 없이 이 링크로 push(`A-4` 예산 코드 2종 → `aaq://m5/intervention`).
    /// null = 1탭 제출(`skipAdvice`). 🔵 `J-3` `ruleCitedOptions` 는 늘 null.
    String? deepLink,
  }) = _ReasonOption;

  factory ReasonOption.fromJson(Map<String, dynamic> json) =>
      _$ReasonOptionFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/allocation.dart`

```dart
// 01 §37 — 🆕 계약 v1.28 · M9 `S04` 배분 화면 첫 판(보기 전용 · 2026-11-19 발주자 결정 193 ⓐ 프리셋 부재 · 194 ⓐ 앱 첫 판 custom 0).
//
// 🔴 쓰기 0 · 판정 0 · 화면은 받은 글자·차례 그대로(묶음·행 재정렬 0) — 색(`level`) · 잠김 · 빈 상태 칸 0(K198).
// 🔴 폰 · 뷰어 같은 값(창구 = `SettingsRepository.watchAllocationEditor()` · 뷰어 원천 = `rm_config_view` 배분 7열 ·
//    `AllocationReadModelColumns` · 01 §6-4).
// 🔴 엔진 원천 = core `ops/allocation_view.dart`(PR #276 · 엔진 지역 꼴 `AllocationView` — 🔴 이 파일의 이름은 엔진과 다르다 ·
//    `ambiguous_import` 회피 K80). 편집 칸(초안 · 슬라이더 · 미리보기 · 적용 · 프리셋) = 편집기 판 추가형(01 §8 미결 190 · 191 · 194).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../primitives/as_of.dart';

part 'allocation.freezed.dart';
part 'allocation.g.dart';

/// 🆕 v1.28(01 §37 · K197) — `S04` 한 화면. 이름 = M2-8 예약(`AllocationEditorVm`) · 첫 판 = 보기 칸만.
@freezed
abstract class AllocationEditorVm with _$AllocationEditorVm {
  const factory AllocationEditorVm({
    /// 지금 배분(정본 하나 — 193 ⓐ 프리셋 부재).
    required AllocationProfileCard current,

    /// 읽기 묶음(엔진 차례 · 첫 판 = 리밸런싱 밴드 · 리스크 한도 · 금 상한).
    @Default(<AllocationReadOnlySection>[])
    List<AllocationReadOnlySection> sections,

    /// «바꾸는 길» 안내(엔진 차례 · 🔴 링크 0).
    @Default(<String>[]) List<String> changePathLines,
    required AsOf asOf,
  }) = _AllocationEditorVm;

  factory AllocationEditorVm.fromJson(Map<String, dynamic> json) =>
      _$AllocationEditorVmFromJson(json);
}
// JSON 키: current · sections · change_path_lines · as_of

/// 🆕 v1.28(K197) — 지금 배분 카드(엔진 글자 · 백테스트 줄 = M9 손익 금지의 유일한 예외(05 원칙 3) · 🔴 정직 기대 줄과 함께만).
@freezed
abstract class AllocationProfileCard with _$AllocationProfileCard {
  const factory AllocationProfileCard({
    /// 프로파일 글자(S01 카드 상태 줄과 같은 글자 — 엔진).
    required String label,

    /// 비중 한 줄(엔진 · 잔여 C 표기 포함).
    required String weightsText,

    /// 백테스트 근거 한 줄(엔진 · 세금 전 점추정).
    required String backtestText,

    /// 정직 기대 줄(엔진 · 온보딩과 같은 글자).
    required String honestNoteText,
  }) = _AllocationProfileCard;

  factory AllocationProfileCard.fromJson(Map<String, dynamic> json) =>
      _$AllocationProfileCardFromJson(json);
}
// JSON 키: label · weights_text · backtest_text · honest_note_text

/// 🆕 v1.28(K197) — 읽기 묶음(묶음 = 엔진이 짓는다 · 화면이 묶지 않는다).
@freezed
abstract class AllocationReadOnlySection with _$AllocationReadOnlySection {
  const factory AllocationReadOnlySection({
    required String title,
    @Default(<AllocationReadOnlyRow>[]) List<AllocationReadOnlyRow> rows,
  }) = _AllocationReadOnlySection;

  factory AllocationReadOnlySection.fromJson(Map<String, dynamic> json) =>
      _$AllocationReadOnlySectionFromJson(json);
}
// JSON 키: title · rows

/// 🆕 v1.28(K197 · K200) — 읽기 행 하나.
@freezed
abstract class AllocationReadOnlyRow with _$AllocationReadOnlyRow {
  const factory AllocationReadOnlyRow({
    /// 🔴 화면 미참조(시험 · 열 대조) — ∈ `AllocationRowCodes.values` · Key = 순번.
    required String code,
    required String label,
    required String valueText,

    /// 덧붙임 한 줄(엔진). null = 부재.
    String? noteText,
  }) = _AllocationReadOnlyRow;

  factory AllocationReadOnlyRow.fromJson(Map<String, dynamic> json) =>
      _$AllocationReadOnlyRowFromJson(json);
}
// JSON 키: code · label · value_text · note_text (= `rm_config_view.allocation_sections` 행 키 · K201)
```

---

## `packages/domain_contracts/lib/src/dto/calendar.dart`

```dart
// packages/domain_contracts/lib/src/dto/calendar.dart
//
// 01 §2-8 «CalendarEventDto — X4(화이트리스트 필드만)» + m2-8 D-8(`CalendarSyncStatus`)
// · 인벤토리 §3-5 · §3-14(영역 B).
//
// ⏸ m2-8 J-5 — X4 채택 자체가 미결(01 §8-5, OAuth 동의화면 7일 만료 스모크)이다.
//    **이름·타입은 등재하되 기능(동기·재백필)은 구현하지 않는다.**
// 🔴 **화이트리스트 직렬화** — 블랙리스트 정규식이 아니라 «허용 필드만 있는 타입»으로
//    강제한다. 타입에 아예 없음: 손익·수익률·평가액·잔고·계좌 전체번호·시크릿.
// 🔴 **미래 시각 이벤트를 만들지 않는다**(예정 리밸런싱·월 납입 예정 금지).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/calendar.dart';
import '../primitives/money.dart';

part 'calendar.freezed.dart';
part 'calendar.g.dart';

/// 캘린더 이벤트 1건(01 §2-8).
///
/// `kind ↔ source_table ↔ aaq_key` 매핑 9행은 01 §2-8 표가 정본이다.
/// 🔴 `advice`·`advice_batch`·`self_report_balance` 는 캘린더에 내지 않는다.
/// 🔴 extendedProperties 는 **6키**(`aaq_key`·`kind`·`decision_id`·`origin`·`config_hash`
///    + `chain_hash`) — 타입에 없는 필드는 나갈 수 없다.
@freezed
abstract class CalendarEventDto with _$CalendarEventDto {
  const factory CalendarEventDto({
    /// 'exec.{execution_id}' 등 멱등 원문 키
    required String aaqKey,
    required CalendarEventKind kind,
    required DateTime startUtc,
    DateTime? endUtc,
    required bool allDay,

    /// "체결 · 매수 069500" — 엔진 생성
    required String title,

    /// 수량·체결가·수수료·비중%·사유 코드·계좌 별칭까지만 — 엔진 생성
    required String body,
    required CalendarOrigin origin,
    String? decisionId,
    required String configHash,

    /// 🆕 G-09(X5) — 🔴 `dailySummary`(종일 요약) 이벤트에만 싣는다.
    /// 정본 `ledger_daily_hash.chain_hash` 앞 N자(축약 규칙은 X5-1 정규 직렬화와
    /// **같은 골든벡터**). 🔴 이 한 필드가 `canonCalendar` 대조를 O(1) 로 만든다.
    String? chainHash,
  }) = _CalendarEventDto;

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventDtoFromJson(json);
}

/// 캘린더 동기 상태 — `calendar_sync_status` 컬럼 + G-34(m2-8 D-8).
///
/// 🔴 «사용자 삭제 n건»은 불일치가 아니라 **별도 수치**다(G-34) — 대조 모집단에서
///    빠지며 되살리기는 기간 재배치의 `resurrect` 하나뿐이다.
/// 🔴 `modeCode` 는 캘린더 축의 **계열 2값**(`LIVE`·`SIM`)이며 `RunMode` 3값이 아니다
///    (G-32 · 🔵 v1 은 `LIVE` 행 하나).
@freezed
abstract class CalendarSyncStatus with _$CalendarSyncStatus {
  const factory CalendarSyncStatus({
    required String modeCode,
    @TradeDateConverter() TradeDate? lastOkDate,
    required String statusCode,
    required String statusLabel,
    required int quarantinedCount,
    required int userDeletedCount,
    String? actionDeepLink,
  }) = _CalendarSyncStatus;

  factory CalendarSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$CalendarSyncStatusFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/common.dart`

```dart
// packages/domain_contracts/lib/src/dto/common.dart
//
// 01 §2-1 «공통 값 객체» · 인벤토리 §3-1(영역 B).
// 사유 칩 · 결정 체인 참조 · 게이트 배지 · 피처 플래그 · 슬리브 카탈로그 ·
// 🆕 v1.6 임계값 대조 1행(`ThresholdCompare` — `journal.dart` 에서 이동 · 01 §15-4).
//
// 🔴 문구(`label`)는 전부 **엔진 생성**이다(01 §1-5) — 화면이 코드→문구 매핑을
//    만들면 §7 C-5 가 빌드를 깨뜨린다.
// 🔴 계산 getter 0건(01 §1-4).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// 사유 칩 — 진입 사유·청산 티어·거부 사유의 표시 단위(01 §2-1).
///
/// 🔴 `label` 은 엔진 생성이며 화면은 조립하지 않는다.
@freezed
abstract class ReasonChip with _$ReasonChip {
  const factory ReasonChip({
    /// 'TIER_1B' · 'SAF309_ACCOUNT_UNVERIFIED' · 'REBALANCE_BAND' (코드 목록은 영역 E 의 사전이 정본)
    required String code,

    /// "TIER 1B 절대손절 −7.0% 도달" — 엔진 생성
    required String label,
    required ChipTone tone,

    /// M8 핸드북 앵커 'handbook://exit/tier1b'
    String? detailDeepLink,
  }) = _ReasonChip;

  factory ReasonChip.fromJson(Map<String, dynamic> json) =>
      _$ReasonChipFromJson(json);
}

/// 🆕 v1.1 — 엔진이 준 «이동 버튼 1개»(01 §4-4 내비게이션 계약).
///
/// 🔴 버튼 문구(`label`)도 목적지(`deepLink`)도 엔진이 준다. 화면은 이 객체가 **null 이면
///    버튼을 그리지 않고**(비활성 아님) non-null 이면 `label` 을 찍고 탭에서
///    `AppLinkOpener.open(deepLink)` 를 부른다 — 그것이 전부다.
@freezed
abstract class LinkAction with _$LinkAction {
  const factory LinkAction({
    /// "이 회차 보기" · "원행 보기" · "저널 작성" — 엔진 생성
    required String label,

    /// `aaq://…` 또는 `handbook://…` — 화면은 해석하지 않는다.
    required String deepLink,
  }) = _LinkAction;

  factory LinkAction.fromJson(Map<String, dynamic> json) =>
      _$LinkActionFromJson(json);
}

/// 결정 체인 참조 — 매매일지 상세의 뼈대(01 §2-1).
@freezed
abstract class DecisionRef with _$DecisionRef {
  const factory DecisionRef({
    required String decisionId,

    /// X2 재판정 child 의 원행
    String? parentDecisionId,
    String? intentId,

    /// 🆕 v1.17(엔진 D11 · 13 §8 R31 · R33 D3 · 02 §3-2 v2.38) — 브로커 주문 번호 = `{주문일}:{ODNO}`(주문일 = KR 거래일 ISO ·
    /// ODNO = KIS 주문번호 원문 — KIS 번호는 날마다 새로 매겨져 단독으로는 날을 넘겨 겹친다). 수기 체결(X7 `MANUAL`) = null.
    /// 🔴 화면은 이 값을 쪼개거나 표시하지 않는다(식별자 · 표시 = `*Label`). 합성 표본(`B0018` 꼴)은 이 꼴이 아니어도 된다(01 §8 미결 166).
    String? brokerOrderNo,

    /// 🆕 v1.17(엔진 D11 · R31 (a) · R33 D3·D4) — 브로커 체결 = `{brokerOrderNo}#{누적 체결수량}`(체결조회 누적이 늘 때마다 새 행 ·
    /// Δ수량 ≤ 0 = 행 없음). 수기·가상 체결 = 엔진의 다른 꼴. 🔴 화면은 파싱하지 않는다.
    String? executionId,
    required String configHash,
  }) = _DecisionRef;

  factory DecisionRef.fromJson(Map<String, dynamic> json) =>
      _$DecisionRefFromJson(json);
}

/// 국면·진입 게이트 배지(01 §2-1).
///
/// 🔴 `GateState.unknown` 은 `notApplicable` 과 다르다 — «모름»이며 진행 차단이다(04 §9-8).
@freezed
abstract class GateBadge with _$GateBadge {
  const factory GateBadge({
    required String code,
    required String label,
    required GateState state,
    String? blockedReasonCode,
  }) = _GateBadge;

  factory GateBadge.fromJson(Map<String, dynamic> json) =>
      _$GateBadgeFromJson(json);
}

/// 피처 플래그(01 §2-1).
///
/// 🔴 화면이 «지금 슬리브가 3칸»을 상수로 아는 것을 막는 유일한 통로다.
/// 🔴 `ExecPolicy` 를 여기에 **넣지 않는다**(01 §10-1) — 넣는 순간 화면이 3축을 곱해 분기한다.
/// 🔴 `operatingMode` 에 기본값을 주지 않는다(m2-8 C-2 · J-1) — «온보딩 미완»은 «자동 매매»가
///    아니다(G-02). 뷰어가 명시적으로 죽는 쪽이 조용한 전제보다 낫다.
@freezed
abstract class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    /// v2.31 P0S = false. 🔵 되살아나면 목록에 행이 늘 뿐 화면은 그대로다.
    required bool satelliteEnabled,

    /// Q-D 미결(01 §8-2) — 발주자 판단까지 레이아웃 분기만
    required bool webViewerEnabled,

    /// X4 채택 미결(01 §8-5) — false 면 M9 캘린더 화면 자체가 없다
    required bool calendarEnabled,

    /// 🆕 X6(01 §9) — 모드 판정의 유일한 통로. 🔴 화면은 이 값으로 타이틀 접두를
    /// 만들지 않는다(셸이 주입 · C-17 이 강제).
    required RunMode runMode,

    /// 🆕 X7(01 §10) — `runMode` 와 대칭. 🔴 접두·띠는 셸 주입(C-18).
    required OperatingMode operatingMode,

    /// 🔴 C-13 핸드북 정합 게이트의 입력
    required String configHash,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}

/// 슬리브 목록의 유일한 창구(01 §2-1).
///
/// 🔴 화면이 `SleeveId` 를 순회하며 `satellite` 를 걸러내는 코드를 쓰지 않는다 —
///    거르는 규칙이 화면에 생기면 그것이 판정이다.
@freezed
abstract class SleeveCatalogEntry with _$SleeveCatalogEntry {
  const factory SleeveCatalogEntry({
    required SleeveId sleeve,

    /// "A · KOSDAQ 지수 ETF" — 엔진 생성
    required String label,

    /// P 회차: POT → A (회계 소속, 03 §2-9-3). 화면이 아니라 엔진이 정한다.
    SleeveId? rollsUpTo,
    required int order,
  }) = _SleeveCatalogEntry;

  factory SleeveCatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$SleeveCatalogEntryFromJson(json);
}

/// 임계값 대조 1행(02 §8-1 · m2-8 E-2).
///
/// 🔴 수치는 전부 **엔진 포맷 문자열**이다 — 화면이 비교식을 만들지 않는다.
/// 🆕 v1.6(01 §15-4) — `journal.dart` 에서 옮겼다(이름·필드·JSON·배럴 export 무변경). J-2
///    `DecisionDetailVm.thresholds` 와 `S7-6b` `RebalanceEvent.thresholds` 가 같은 타입을 쓴다
///    (`journal.dart` → `rebalance.dart` import 방향 때문에 순환을 피해 공통 파일에 둔다).
@freezed
abstract class ThresholdCompare with _$ThresholdCompare {
  const factory ThresholdCompare({
    required String metricKey,
    required String metricLabel,
    required String observedText,
    required String thresholdText,
    required bool passed,
    required String verdictLabel,
  }) = _ThresholdCompare;

  factory ThresholdCompare.fromJson(Map<String, dynamic> json) =>
      _$ThresholdCompareFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/handbook.dart`

```dart
// 01 §2-6(요구 6 핸드북) · m2-8 D-9 — 04 §8 이 렌더하는 핸드북.
//
// 🔴 `ReasonChip.detailDeepLink`(`handbook://…`)의 **도착지**다.
// 🔴 **C-13 의 `config_hash` 메타를 싣는 주체**이며, 픽스처의 `config_hash` 와
//    어긋나면 계약 테스트가 실패한다 — 화면이 두 값을 비교하지 않는다.
// 🔴 본문 문구는 전부 원고(엔진·핸드북 소스)에서 오며 화면이 문장을 짓지 않는다.
// 🆕 계약 v1.17(01 §26 · R16 선행 · 발주자 결정 2026-11-04 ④) — 목차 상태·자식·링크 · 뒤처짐 글자 · 모르는 앵커 · live 블록:
//    ① «설명이 규칙보다 뒤처졌다» 판정 = **엔진**(원고 메타 해시 ↔ 지금 config 대조) — 결과는 [HandbookIndex.outdatedNotice]·
//       [HandbookPage.outdatedNotice] 글자로만 온다(숨김·닫기 0 · P1 알림 = 엔진). 뒤처짐 표본도 `config_hash` = 봉투 meta(C-13 ⓐ).
//    ② 목차 항목 수·차례·접힘 = 받은 그대로(8 리터럴 0) · 링크 = [HandbookEntry.deepLink](화면이 `handbook://$anchor` 를 짓지 않는다).
//    ③ 모르는 앵커 = [HandbookPage.missingLabel](값 · 스트림 에러 아님) · 앵커 별칭 해석 = 엔진.
//    ④ live «현재 상태» 블록이 하나라도 있으면 [HandbookPage.asOf] non-null(엔진 의무) — 지금 값을 보이므로 조회 화면이다.
//       live 가 없으면 asOf 0(문서 콘텐츠 · K20).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/handbook.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';

part 'handbook.freezed.dart';
part 'handbook.g.dart';

/// m2-8 D-9 — 핸드북 목차.
@freezed
abstract class HandbookIndex with _$HandbookIndex {
  const factory HandbookIndex({
    required List<HandbookEntry> entries,
    required String configHash,

    /// 🆕 v1.17 — 뒤처짐 고지(엔진 판정 글자). null = 고지 없음.
    String? outdatedNotice,
  }) = _HandbookIndex;

  factory HandbookIndex.fromJson(Map<String, dynamic> json) =>
      _$HandbookIndexFromJson(json);
}
// JSON 키: entries · config_hash · outdated_notice

/// m2-8 D-9 — 목차 1행. 🔴 `order` 는 엔진이 정한다(화면이 정렬하지 않는다).
@freezed
abstract class HandbookEntry with _$HandbookEntry {
  const factory HandbookEntry({
    required String anchor,
    required String title,
    required int order,

    /// 🆕 v1.17 — 아이콘·색에만. 키가 없는 옛 표본 = [HandbookEntryState.ready].
    @Default(HandbookEntryState.ready) HandbookEntryState state,

    /// 🆕 v1.17 — «준비 중» · «보관됨»(엔진). `ready` 면 null.
    String? stateLabel,

    /// 🆕 v1.17 — 탭 목적지(`handbook://…` · 엔진 완성). null = 탭 부재(준비 중).
    String? deepLink,

    /// 🆕 v1.17 — 하위 항목(② 슬리브 A·B·C · 보관된 새틀라이트 — 받은 차례). 키 없음 = [].
    @Default(<HandbookEntry>[]) List<HandbookEntry> children,
  }) = _HandbookEntry;

  factory HandbookEntry.fromJson(Map<String, dynamic> json) =>
      _$HandbookEntryFromJson(json);
}
// JSON 키: anchor · title · order · state · state_label · deep_link · children

/// m2-8 D-9 — 핸드북 한 쪽.
@freezed
abstract class HandbookPage with _$HandbookPage {
  const factory HandbookPage({
    required String anchor,
    required String title,
    required List<HandbookBlock> blocks,
    required String configHash,

    /// 🆕 v1.17 — 뒤처짐 고지(엔진 판정 글자 · 맨 위 · 숨김 0). null = 없음.
    String? outdatedNotice,

    /// 🆕 v1.17 — 모르는 앵커 문장(엔진). non-null ⇔ [blocks] 0.
    String? missingLabel,

    /// 🆕 v1.17(발주자 결정 2026-11-04 ④ R16b ⑨) — live 블록이 하나라도 있으면 non-null(엔진 의무) · 없으면 null.
    AsOf? asOf,
  }) = _HandbookPage;

  factory HandbookPage.fromJson(Map<String, dynamic> json) =>
      _$HandbookPageFromJson(json);
}
// JSON 키: anchor · title · blocks · config_hash · outdated_notice · missing_label · as_of

/// m2-8 D-9 — 본문 블록 1개. 🔴 `kind` 는 엔진이 준 블록 종류 코드이며 화면이
/// 이 값으로 문구를 고르지 않는다(C-5).
@freezed
abstract class HandbookBlock with _$HandbookBlock {
  const factory HandbookBlock({
    required String kind,
    required String text,
    String? deepLink,

    /// 🆕 v1.17 — «현재 상태» 라이브 값(라벨 = 엔진 · 등급 = 아이콘·색만). null = 일반 블록.
    HandbookLiveValue? live,
  }) = _HandbookBlock;

  factory HandbookBlock.fromJson(Map<String, dynamic> json) =>
      _$HandbookBlockFromJson(json);
}
// JSON 키: kind · text · deep_link · live

/// 🆕 v1.17(01 §26 · K13) — 블록의 «현재 상태» 값(예 «금 비중이 상한에 가깝습니다» · WATCH).
@freezed
abstract class HandbookLiveValue with _$HandbookLiveValue {
  const factory HandbookLiveValue({
    /// 값·라벨 — 엔진(🔴 화면 숫자 0).
    required String label,

    /// 아이콘·색에만.
    required UiLevel level,
  }) = _HandbookLiveValue;

  factory HandbookLiveValue.fromJson(Map<String, dynamic> json) =>
      _$HandbookLiveValueFromJson(json);
}
// JSON 키: label · level
```

---

## `packages/domain_contracts/lib/src/dto/handover.dart`

```dart
// 01 §2-11 — X7 운영 방식 표시와 전환 위저드(`M5-10` 게이트 · `M5-11` 위저드).
//
// 🔴 `OperatingMode` 전환은 `CommandApi` 에 없다 — `SettingsActions` 의
//    `runtimeOperatingModeSwitchRequest` 1종이며 반환 `handoffRoute` 로 위저드에
//    넘긴다(01 §4-3).
// 🔴 엔진의 어떤 안전 강등도 `OperatingMode` 를 건드리지 않는다(§10-1 · C-20).
// 🔒 전환 위저드는 M5 소유 화면이다 — 다른 화면은 읽을 수는 있으나 렌더하지 않는다.
// 🆕 v1.19(01 §28 · K8) — `S05` 는 `OperationsVm.operatingMode` 로 이 타입을 받는다(창구 = `SettingsRepository.watchOperations`) ·
//    전환 버튼 = [OperatingModeView.switchActions].
// 🆕 v1.26(01 §35 · K167~K175) — `M5-11` simToAuto 위저드 한 화면 [HandoverWizardVm] · 단계 행 [HandoverWizardStepRow]
//    (창구 = `HandoverRepository.watchWizard()` · `handoverStatus` = 같은 본문 · 🔒 `ui_safety`) · [HandoverPlan]·[HandoverStep] 무변경.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart';
import 'ledger_trust.dart';
import 'operations.dart'; // 🆕 v1.26 — SimTrialCard(S1 상세 · K171)
import 'settings.dart'; // 🆕 v1.19 — SettingsActionCall

part 'handover.freezed.dart';
part 'handover.g.dart';

/// 01 §2-11 — M9 `S05` 표시(지금 운영 방식 · `current` 늘 값). 🆕 v1.16(01 §25 · K12) — `O-00b` 는
/// 이 타입을 읽지 않는다(`OnboardingModeChoiceVm` — «아직 안 고름» = `selected` null) · 카드 1장 =
/// **같은 타입** [OperatingModeOption](S05·O-00b 공용).
@freezed
abstract class OperatingModeView with _$OperatingModeView {
  const factory OperatingModeView({
    required OperatingMode current,

    /// "투자 안내(수동 매매)" — 엔진 생성.
    required String label,
    required String explainLine,

    /// S05 의 카드 묶음(🔵 v1.16 — O-00b 는 `OnboardingModeChoiceVm.options`) — 🔴 **기본 선택 없음**
    /// («온보딩 미완»은 «자동 매매»가 아니다 · G-02).
    required List<OperatingModeOption> options,
    required LedgerTrustBadge trust,

    /// 전환 사전 점검 결과.
    required List<GateBadge> switchGates,

    /// 🆕 v1.19(01 §28 · K8) — `S05` 운영 방식 전환 요청 버튼(엔진 완성 `runtimeOperatingModeSwitchRequest` ·
    /// args `{operating_mode}` · 값 ≠ [current]). 빈 = 부재 · 🔴 [options] 카드에 버튼을 붙이지 않는다(O-00b 공용 · 기본 선택 0).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> switchActions,
  }) = _OperatingModeView;

  factory OperatingModeView.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeViewFromJson(json);
}
// JSON 키: current · label · explain_line · options · trust · switch_gates · switch_actions

/// 01 §2-11 — 선택 카드 1장. 🔴 전부 엔진 문구다.
@freezed
abstract class OperatingModeOption with _$OperatingModeOption {
  const factory OperatingModeOption({
    required OperatingMode mode,
    required String title,
    required String body,
    required String prepLine,
    required String honestyLine,
  }) = _OperatingModeOption;

  factory OperatingModeOption.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeOptionFromJson(json);
}

/// 01 §2-11 — 전환 계획(`M5-11`).
/// 🔴 B13 — `asOf` 는 스냅샷 신선도다. 낡으면 커밋 직전에 되돌린다.
@freezed
abstract class HandoverPlan with _$HandoverPlan {
  const factory HandoverPlan({
    required HandoverPath path,
    required String pathLabel,
    required List<HandoverStep> steps,
    required List<AdoptionPreviewRow> adoptionPreview,
    required AsOf asOf,

    /// 🔴 B12 — **엔진이 갈래를 판정한다**(사고 대응 / 자발적 전환).
    ///    화면은 준 갈래만 표시하고 자체 판정하지 않는다.
    String? handbackBranch,
    String? branchReasonLabel,
  }) = _HandoverPlan;

  factory HandoverPlan.fromJson(Map<String, dynamic> json) =>
      _$HandoverPlanFromJson(json);
}

/// 01 §2-11 — 전환 단계 1행(`OnboardingStep`·`UnknownResolutionStep` 과 같은 모양).
@freezed
abstract class HandoverStep with _$HandoverStep {
  const factory HandoverStep({
    required String stepId,
    required int order,
    required String title,
    required String whyLine,
    required GateState state,
    required String stateLabel,
    String? blockedReasonCode,
  }) = _HandoverStep;

  factory HandoverStep.fromJson(Map<String, dynamic> json) =>
      _$HandoverStepFromJson(json);
}

/// 01 §2-11 — 편입 미리보기 1행.
/// 🔴 G-03 — `disposition` 은 엔진이 준 **현재** 처분(`'ADOPT'`|`'EXTERNAL'`)이며,
///    바꿀 때는 `handoverAdoptionSet` 를 호출한 뒤 **되돌아온 값**을 다시 그린다
///    (낙관 갱신 금지 — 커밋 전 상태를 화면이 소유하지 않는다).
@freezed
abstract class AdoptionPreviewRow with _$AdoptionPreviewRow {
  const factory AdoptionPreviewRow({
    required String symbol,
    required String symbolLabel,
    required int quantity,
    required SleeveId sleeve,

    /// 🔴 처분 제출의 대상 식별자. 티커 문자열로 지목하면 같은 종목이 두 계좌에
    ///    있을 때 조용히 한쪽만 반영된다.
    required String adoptionId,
    required String disposition,

    /// "편입" / "제외(시스템 밖 자산)" — 엔진 생성.
    required String dispositionLabel,
  }) = _AdoptionPreviewRow;

  factory AdoptionPreviewRow.fromJson(Map<String, dynamic> json) =>
      _$AdoptionPreviewRowFromJson(json);
}

/// 🆕 v1.26(01 §35 · K168) — `M5-11` simToAuto 위저드 한 화면(`AppRoutes.m5HandoverWizard` · `handoverStatus` 같은 본문 — K173).
/// 🔴 머리·단계·시각 글자 = 엔진(`judgeSimToAuto` · `simToAutoPlan` 감싸기) · 화면은 분기 0 · 카운트다운 0(시각이 지나면 새 VM).
/// 🔴 1.26.0 = `HandoverPath.simToAuto` 하나(다른 경로 = 추가형 나중).
/// 🔴 불변식(C-60 ②~⑥) — [rows] 길이 ∈ {0, 7}(0 ⇔ 전제 밖) · 7 이면 `step.stepId` 차례 = `SimToAutoStepIds.ordered` ·
///    [lockedLabel] 또는 [doneLabel] non-null ⇒ 모든 행 `actions` 빈 목록.
@freezed
abstract class HandoverWizardVm with _$HandoverWizardVm {
  const factory HandoverWizardVm({
    /// 판정 머리(엔진 `SimToAutoReport.headline` · 전제 밖 = 엔진 전제 문장).
    required String headline,

    /// 머리 색(엔진 짝 — 확정 가능 = OK · 막힘 = BLOCKED · 냉각·시각 모름 = WATCH · 진행 중 = INFO).
    required UiLevel level,

    /// 🔴 화면 미참조(시험·로그) — 엔진 `SimToAutoReport.code`(∈ `SimToAutoResultCodes`) · null = 막힘 0.
    String? reasonCode,

    /// 경로 글자(엔진 · «모의투자 → 실전 자동 매매(관찰부터)»).
    required String pathLabel,

    /// 7단계(엔진 차례 = `SimToAutoStepIds.ordered`) · 🔴 전제 밖 = 0.
    @Default(<HandoverWizardStepRow>[]) List<HandoverWizardStepRow> rows,

    /// S1 상세(체험 5항목 · 04 :1222 같은 그릇 · K171). null = 부재.
    SimTrialCard? trial,

    /// 냉각 끝 글자(엔진 · 세션 열린 뒤만). null = 부재.
    String? coolingText,

    /// 확정 기한 글자(엔진 · 세션 열린 뒤만). null = 부재.
    String? deadlineText,

    /// 커밋 창 글자(엔진 `SimToAutoCommitWindow.label` — 허용 때도 · K170). null = 부재.
    String? windowText,

    /// 고지 한 줄(엔진 · 예: 경고 후 진행 · 승인 config 없음). null = 부재.
    String? noticeText,

    /// 확정됨 상태 문장(엔진 · non-null ⇔ 확정 뒤 — 그때 `rows` 는 그대로 · 동작 0 · K175).
    String? doneLabel,

    /// 잠김(운영 등급 생체 · 다른 기기 리스 — 01 §8 미결 169) · non-null ⇒ 모든 행 `actions` 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _HandoverWizardVm;

  factory HandoverWizardVm.fromJson(Map<String, dynamic> json) =>
      _$HandoverWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · path_label · rows · trial · cooling_text · deadline_text · window_text ·
//          notice_text · done_label · locked_label · as_of

/// 🆕 v1.26(01 §35 · K168 · K169 · K172) — 위저드 한 단계(기존 [HandoverStep] 무변경 감싸기).
/// 🔴 단계별 허용 동작(K169 · C-60 ③) — S2 ⊆ {`selftestGoldenRun`} · S5 ⊆ {`handoverSimLedgerFate`} ·
///    S6 ⊆ {`handoverSessionStart`} · S7 ⊆ {`handoverSessionCancel`, `handoverCommit`} · 그 밖 단계 = 0 ·
///    세션 id = 엔진이 `handover_session_id` args 에 넣는다(화면 읽기 0) · `handoverCommit` = S7 PASS 일 때만.
@freezed
abstract class HandoverWizardStepRow with _$HandoverWizardStepRow {
  const factory HandoverWizardStepRow({
    /// 엔진 `simToAutoPlan` 단계 그대로(제목 · 왜 · 상태 · 상태 글자 · 막힘 코드).
    required HandoverStep step,

    /// 🔴 색의 유일한 근거(K172) — `step.state` 가 UNKNOWN 이어도 «아직»은 INFO · 시각 모름 = WATCH.
    required UiLevel level,

    /// 다른 화면으로(엔진 · S2 → `settingsDiagnostics` · S3 → `settingsCredentials` · S4 → `settingsAccounts`). null = 이동 0.
    LinkAction? link,

    /// 단계 안 엔진 완성 호출(`SettingsActions.run` · 허용 id = 위 표). 빈 목록 = 버튼 0.
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> actions,
  }) = _HandoverWizardStepRow;

  factory HandoverWizardStepRow.fromJson(Map<String, dynamic> json) =>
      _$HandoverWizardStepRowFromJson(json);
}
// JSON 키: step · level · link · actions
```

---

## `packages/domain_contracts/lib/src/dto/holdings.dart`

```dart
// packages/domain_contracts/lib/src/dto/holdings.dart
//
// 01 §2-3 «HoldingRow — 보유현황 1행»(M6, 요구 3) + m2-8 D-7(`MomentumPanel`)
// · E-8(`StopLineNormalized`) · 인벤토리 §3-3 · §3-14(영역 B).
//
// 🔴 결정 8 — `HoldingPnl` 은 `watchHoldings(includePnl: true)` 일 때만 채워진다.
//    홈·알림·위젯·일지 타임라인에 이 타입을 렌더하면 §7 C-6 실패.
// 🔴 X7 D7 — 파생은 `positions` 만 읽는다. `external_holding`(= `scope == external`)의
//    표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).
// 🆕 v1.8(01 §17 · R4 선행) — `HoldingRow` +7 · `HoldingPnl` +2 · 화면 VM 4(`HoldingsOverviewVm`·
//    `HoldingsSleeveCard`·`HoldingsExternalSection` = `H6-1` · `HoldingDetailVm` = `H6-2`).

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'journal.dart';
import 'ledger_trust.dart';
import 'rebalance.dart';

part 'holdings.freezed.dart';
part 'holdings.g.dart';

/// 보유현황 1행(01 §2-3). 🆕 v1.8(01 §17) — 키 1 · 표시 문자열 4 · 칩 2 · 링크 1.
///
/// 🔴 v1.8 부터 `H6-1`·`H6-2` 가 그리는 것은 `*Text`·`*Label`·칩·배지뿐이다 — 원값
///    (`quantity`·`avgPrice`·`stopLine`·`pnl.unrealizedPnl`·`pnl.pnlPct`)과 키(`symbol`·`sleeve`·
///    `entryDecision`·`scope`)는 **ui 미참조**(C-44 ⑮). 가림(`RECON_MISMATCH` «?» · `LEDGER_INTEGRITY` «숨김»)은
///    엔진이 문자열 안에서 끝낸다(01 §11-2) — 화면은 `activeFlags` 로 값을 바꾸지 않는다.
/// 🔴 `H6-1` 목록(`HoldingsOverviewVm`)의 행은 늘 `scope == managed` 다 — 시스템 밖 자산은
///    `HoldingsExternalSection.rows`(`ExternalHoldingRow`)로 온다(K14).
@freezed
abstract class HoldingRow with _$HoldingRow {
  const factory HoldingRow({
    required String symbol, // 🔴 ui 미참조(C-44) — 표시는 [symbolLabel]
    required String symbolLabel,
    required SleeveId sleeve, // 🔴 ui 미참조 — 카드 자리는 엔진이 정한다
    /// "연금저축" — 🔴 계좌 전체번호 금지
    required String accountAlias,
    required int quantity, // 🔴 ui 미참조 — 표시는 [quantityText]
    /// 매수가 — 🔴 ui 미참조 — 표시는 [avgPriceText]
    @DecimalStringConverter() required Decimal avgPrice,

    /// 표시 = `entryDate.yyyyMmDd` 그대로(예외 1개 — `RebalanceEvent.tradeDate` 선례 · 날짜는 가림 대상 아님).
    @TradeDateConverter() required TradeDate entryDate,

    /// `positions.entry_decision_id` — 🔴 ui 미참조 — 이동은 `HoldingDetailVm.entryDecisionLink`
    required DecisionRef entryDecision,
    required List<ReasonChip> entryReasons,

    /// SMA 트랜치 진행 — 🆕 v1.8 표본 규칙: 슬리브 B 행에만 온다(P 회차 · 그 밖 = 빈 목록).
    required List<TrancheStep> smaTranches,
    required List<GateBadge> gates,

    /// 🔴 ui 미참조(v1.8) — 표시는 `HoldingDetailVm.stopLines`(글자 행 · 01 §17 · K3).
    StopLine? stopLine,

    /// 🔵 v2.31: 개별주 소멸 — 거의 항상 null · null 이면 모멘텀 패널 **부재**
    MomentumPanel? momentum,

    /// 🔴 기본 접힘(결정 8) · `includePnl: true` 일 때만 · 뷰어는 늘 null(K15)
    @Default(null) HoldingPnl? pnl,
    required HoldingScope scope, // 🔴 ui 미참조(H6)
    required String scopeLabel, // 🔴 ui 미참조(H6) — 시스템 밖 섹션 고지는 `HoldingsExternalSection.noticeText`
    required AsOf asOf,

    // ── 🆕 계약 v1.8(01 §17 · R4 선행) ─────────────────────────────────────
    /// 보유 1건의 키 — 엔진이 `positions (market, symbol, strategy_id)` 를 묶은 불투명 id.
    /// 🔴 표시 금지 · Key 문자열에도 넣지 않는다(Key = 순번 — C-44 ⑮ · §6) · 라우트 파라미터·family 키 전용. 같은 종목이 B 와 POT 에 함께 있을 수 있다 —
    ///    화면이 종목 코드로 행을 찾지 않는다.
    required String holdingId,

    /// "212주" · RECON 대상 "212주?" · INTEGRITY "숨김" — 천 단위·단위까지 엔진 완성.
    required String quantityText,

    /// "38,410원" · 가림 같은 규칙.
    required String avgPriceText,

    /// "비중 4.1%" — 회계 기준 총자산 대비(엔진 생성) · 가림 같은 규칙 · 🔴 화면이 비중을 계산·합산하지 않는다.
    required String weightText,

    /// "반영 대기 +12주"(02 §2-1 갈래 C — `H6-*` 의 칩 원천 · E15) — null = 칩 부재. 🔴 화면이 수량에 더하지 않는다.
    /// 가림 = 엔진: `LEDGER_INTEGRITY`(·`L-3` 세션) = null(칩 부재) · `RECON_MISMATCH` 대상 행 = 끝 «?»(C-44 ③).
    String? pendingText,

    /// "POT 서브북 · A 하위(연금저축)" — null = 칩 부재. POT 행을 A 카드에 넣는 것은 엔진이다(K17 ✅).
    String? subBookLabel,

    /// → `H6-2`(`aaq://holdings/detail/<holdingId>` — 엔진 완성). null = 행 탭 반응 없음.
    /// 🔴 `H6-2` 안에서는 쓰지 않는다(자기 자신 — `TradeJournalEntry.detailDeepLink` 규약).
    String? detailDeepLink,
  }) = _HoldingRow;

  factory HoldingRow.fromJson(Map<String, dynamic> json) =>
      _$HoldingRowFromJson(json);
}

/// SMA 트랜치 1단계(01 §2-3).
@freezed
abstract class TrancheStep with _$TrancheStep {
  const factory TrancheStep({
    required int stepNo,
    required bool filled,

    /// "1/3 진입 (SMA200 상회)" — 엔진 생성
    required String label,
    @TradeDateConverter() TradeDate? filledOn,
  }) = _TrancheStep;

  factory TrancheStep.fromJson(Map<String, dynamic> json) =>
      _$TrancheStepFromJson(json);
}

/// 손절선(01 §2-3).
@freezed
abstract class StopLine with _$StopLine {
  const factory StopLine({
    /// TIER 1B
    @DecimalStringConverter() Decimal? absoluteStop,

    /// TIER 2 (단조 비감소)
    @DecimalStringConverter() Decimal? trailStop,

    /// TIER 1A ⚠️ 1차 릴리스에서 항상 null
    @DecimalStringConverter() Decimal? customStop,
    @DecimalStringConverter() Decimal? highWaterMark,

    /// "트레일링 −2.5×ATR(20)" — 엔진 생성
    required String label,
  }) = _StopLine;

  factory StopLine.fromJson(Map<String, dynamic> json) =>
      _$StopLineFromJson(json);
}

/// 🔴 결정 8 — 종목 손익은 **별도 optional 필드**다. 기본 접힘, 손익 정렬·합계 미제공.
/// 🆕 v1.8 — 표시 문자열 2(원값 2 는 ui 미참조 · C-44 ⑮).
@freezed
abstract class HoldingPnl with _$HoldingPnl {
  const factory HoldingPnl({
    @DecimalStringConverter() required Decimal unrealizedPnl, // 🔴 ui 미참조
    required double pnlPct, // 🔴 ui 미참조
    /// "전일 종가 기준 · 평가 손익" — 엔진 생성 · 🔴 늘 함께 그린다(02 §2-3) · 열람 기록 문구 금지(결정 ⑤).
    required String disclosureNote,

    /// 🆕 v1.8 — "+158,420원" · INTEGRITY "숨김".
    required String pnlText,

    /// 🆕 v1.8 — "+1.93%" · INTEGRITY "숨김".
    required String pnlPctText,
  }) = _HoldingPnl;

  factory HoldingPnl.fromJson(Map<String, dynamic> json) =>
      _$HoldingPnlFromJson(json);
}

/// 모멘텀 패널 — `holding_signal_daily` 컬럼 1:1 (m2-8 D-7).
///
/// 🔵 v2.31 P0S 에서 **거의 항상 null** 이다(개별주 소멸).
@freezed
abstract class MomentumPanel with _$MomentumPanel {
  const factory MomentumPanel({
    /// `holding_signal_daily.momentum_12_1`(01 §6-1 배치 A) —
    /// 🔴 컬럼명이 `momentum_12_1` 이라 자동 snake 변환(`momentum121`)과 갈린다.
    @JsonKey(name: 'momentum_12_1') double? momentum121,
    @JsonKey(name: 'rs_rank') int? rsRank,
    @JsonKey(name: 'template_passed') bool? templatePassed,

    /// `failed_conditions`(JSON) — 🔴 문구는 엔진 생성
    required List<ReasonChip> failedConditions,
    required String label,
  }) = _MomentumPanel;

  factory MomentumPanel.fromJson(Map<String, dynamic> json) =>
      _$MomentumPanelFromJson(json);
}

/// 손절선 표시 정규화판(02 §8-1 · m2-8 E-8).
///
/// 🔴 `StopLine`(01 §2-3)을 **대체하지 않는다** — 표시용 정규화 1행이다.
/// 🔴 `levelText` 가 표시의 정본이고 `level` 은 정렬·대조용이다.
@freezed
abstract class StopLineNormalized with _$StopLineNormalized {
  const factory StopLineNormalized({
    /// 'TIER_1A' · 'TIER_1B' · 'TIER_2' (코드 목록은 영역 E 의 사전)
    required String tierCode,
    required String tierLabel,
    @DecimalStringConverter() Decimal? level,
    required String levelText,
    required bool isActive,
    required String basisLabel,
  }) = _StopLineNormalized;

  factory StopLineNormalized.fromJson(Map<String, dynamic> json) =>
      _$StopLineNormalizedFromJson(json);
}

/// 🆕 v1.8 — `H6-1` 보유현황 한 화면의 전부(01 §17). 창구 = `HoldingsRepository.watchHoldingsOverview`.
///
/// 🔴 카드 수 = [cards] 의 길이다 — 화면이 3 을 적지 않는다. 위성 플래그가 켜지면 엔진이 카드를 싣는다
///    (화면은 `FeatureFlags` 를 읽지 않는다 · C-44 ⑱).
/// 🔴 화면은 카드·행·섹션을 **받은 순서 그대로** 그린다 — 정렬(슬리브 → 비중 내림차순)·묶기·떼기는 엔진.
/// 🔴 합계(수량·비중·평가액·손익) 줄은 없다 — 만들지 않는다(02 §4-1 금지 ①③).
@freezed
abstract class HoldingsOverviewVm with _$HoldingsOverviewVm {
  const factory HoldingsOverviewVm({
    required List<HoldingsSleeveCard> cards,

    /// 시스템 밖 자산 섹션 — null = 섹션 **부재**(빈 섹션 금지).
    HoldingsExternalSection? external,

    /// 「비중 보기」 → `H6-3`(`aaq://holdings/allocation`). null = 버튼 부재.
    LinkAction? allocationLink,

    /// 종목 손익 펼침 토글 글자 — null = 토글 **부재**(뷰어 · K15). 펼침 = `includePnl: true` 재구독(02 §2-3).
    String? pnlToggleLabel,

    /// non-null ⇔ [cards] 가 빈 목록 — 화면은 이 문장**만** 그린다(다음 트랜치 안내도 이 안에 · 02 §4-1 P 회차).
    /// 🔴 «없음» 전용 — «모름»(첫 동기화 전·로컬 DB 미도착)에는 엔진이 값을 내지 않거나 스트림 에러로 준다(01 §11-10 · K26).
    String? emptyLabel,

    /// 헤더 기준일 고지 = `asOf.label` 그대로("잔고 기준 2026-08-31 종가 · 엔진은 일 1회 배치" — 02 §2-1 갈래 B).
    required AsOf asOf,
  }) = _HoldingsOverviewVm;

  factory HoldingsOverviewVm.fromJson(Map<String, dynamic> json) =>
      _$HoldingsOverviewVmFromJson(json);
}

/// 🆕 v1.8 — `H6-1` 슬리브 카드 1장.
@freezed
abstract class HoldingsSleeveCard with _$HoldingsSleeveCard {
  const factory HoldingsSleeveCard({
    required SleeveId sleeve, // 🔴 ui 미참조(C-44) — Key 는 카드 순번
    /// "A · 국내 지수 ETF" — 엔진 생성(`SleeveCatalogEntry.label` 과 같은 사전).
    required String titleText,

    /// 카드 머리 — 같은 화면의 `H6-3` 행과 **같은 값**(C-44 ⑥). 머리 큰 글자 = `allocation.sleeveWeight?.label`,
    /// 상태 = `bandStateLabel`(색 = `bandState`) · `sleeveWeight == null` 이면 `bandNoteText` 만(K27 권고상 A·C 카드가 이 갈래).
    required SleeveAllocationRow allocation,

    /// 펼침 = 종목 행 — 받은 순서(엔진 = 비중 내림차순 · POT 행은 A 카드 펼침 안 맨 끝 · `subBookLabel` 상시 동반 — K17 ✅).
    required List<HoldingRow> rows,

    /// non-null ⇔ [rows] 가 빈 목록 — "이 슬리브에 보유 종목이 없습니다".
    String? rowsEmptyText,
  }) = _HoldingsSleeveCard;

  factory HoldingsSleeveCard.fromJson(Map<String, dynamic> json) =>
      _$HoldingsSleeveCardFromJson(json);
}

/// 🆕 v1.8 — `H6-1` 시스템 밖 자산(수동) 섹션(02 §4-1 X7 · §8 행 15 — v1 = 접힘 섹션 + 고지 상시).
/// 🔴 관리 대상과 합계를 합치지 않는다(D7 · C-23) — 이 섹션에는 비중이 없다.
@freezed
abstract class HoldingsExternalSection with _$HoldingsExternalSection {
  const factory HoldingsExternalSection({
    /// "시스템 밖 자산(수동)" — 엔진 생성.
    required String titleText,

    /// "비중 계산에서 빠집니다" — 🔴 접혀 있어도 늘 그린다.
    required String noticeText,

    /// "대사 미확인" 배너 — null = 배너 부재(조건 = 엔진).
    String? bannerText,

    /// 받은 순서 · 비지 않는다(빈 섹션이면 [HoldingsOverviewVm.external] 이 null).
    required List<ExternalHoldingRow> rows,
  }) = _HoldingsExternalSection;

  factory HoldingsExternalSection.fromJson(Map<String, dynamic> json) =>
      _$HoldingsExternalSectionFromJson(json);
}

/// 🆕 v1.8 — `H6-2` 종목 상세 한 화면의 전부(01 §17). 창구 = `watchHoldingDetail(holdingId)`.
///
/// 🔴 손절까지 남은 폭·%를 화면이 계산하지 않는다 — v1 은 [stopLines] 글자 행만(K3 · 게이지 = 미결 104).
/// 🔴 화면은 `watchTimeline` 으로 이력을 조립하지 않는다 — 이력은 [recentEntries] 로 온다(K19).
@freezed
abstract class HoldingDetailVm with _$HoldingDetailVm {
  const factory HoldingDetailVm({
    /// 같은 `holdingId` 의 `H6-1` 행과 같은 값(손익 제외 — C-44 ④).
    required HoldingRow holding,

    /// "B · 해외 지수·금 ETF" — 엔진 생성.
    required String sleeveLabel,

    /// 「매수 결정 보기」 → `J-2`(`aaq://journal/decision/<id>` — 엔진 완성). 🔴 **늘 있다**(02 `H6-2` 수용 (c)
    /// «`entryDecision` 링크가 항상 동작» · K16 ⓔ) — `HoldingRow.entryDecision` 이 required 라 원천이 늘 있다.
    required LinkAction entryDecisionLink,

    /// 손절선 글자 행 — 받은 순서 · `levelText`·`tierLabel`·`basisLabel` 만 그린다(`level`·`tierCode` ui 미참조).
    /// 🔴 비었으면 [noStopLineText] 하나(0행 ⇔ non-null).
    required List<StopLineNormalized> stopLines,

    /// "이 슬리브는 개별 손절선을 쓰지 않습니다 — 리밸런싱 규칙으로 관리"(02 §4-2 «문구 M2»).
    String? noStopLineText,

    /// 이 보유의 최근 체결 — 엔진이 고르고 자른다(시간 역순 · 같은 `holdingId`) · 행 탭 = 행의 `detailDeepLink`(J-2).
    required List<TradeJournalEntry> recentEntries,

    /// non-null ⇔ [recentEntries] 가 빈 목록.
    String? recentEmptyLabel,

    /// [HoldingsOverviewVm.pnlToggleLabel] 과 같은 규칙(null = 토글 부재 · K15).
    String? pnlToggleLabel,
    required AsOf asOf,
  }) = _HoldingDetailVm;

  factory HoldingDetailVm.fromJson(Map<String, dynamic> json) =>
      _$HoldingDetailVmFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/incident.dart`

```dart
// 🆕 계약 v1.17(01 §26 · R16 선행 · 발주자 결정 2026-11-04 ①~④) — M8 `D-01` 장애 배너 · `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드.
//
// 🔴 배너 고르기·정렬·최대 1건·원인 해소 = 전부 엔진(04 §6) — 화면은 받은 0/1건을 그린다. 배너 ≠ 알림(배너 = 원인이 남아 있는
//    상태 · 알림 = 사건 · 등급(P0/P1/P2)은 알림에만 있다). 닫기·«다시 보지 않기» 칸이 없다 — 해소되면 데이터에서 사라진다.
// 🔴 문구·조치는 완성돼 온다 — [IncidentKind] 는 아이콘에만 · `UiLevel` 은 색에만(🔴 `ok` 는 배너에 오지 않는다).
// 🔴 asOf 칸이 없다(K20 — 지속 상태 1건 · 절차서 · 안내 · R15 온보딩 꼴 · 04 §2-3 «모든 조회 화면» 의 예외 · 01 §8 미결 148).
// 🔴 런북 원고 = 03_실행 §10-5 여섯 시나리오 · 긴급 카드 원고 = 04_안전장치 §5-5 + 03_실행 §10-5 ⑥ — M2 번들(엔진이 늘 싣는다 ·
//    뷰어도 같은 번들 — 폰이 죽어도 읽힌다 · K3).
// 🔴 런북 «확인» 체크는 화면 로컬 표시다 — 이 계약에 그 상태 칸·명령이 없다(저장 0 · 명령 0 · 그 사실 = [RunbookVm.localCheckNotice]).
//    «지금 실행» 류 단계별 실행 자리도 칸이 없다(01 §8 미결 161 · M5·M9 창) — 이 판 = 부재.
// 🔴 인쇄·PDF = 플랫폼 슬롯([EmergencyCardVm.printSlotId] = `OpsSlotIds` · 위젯 = 조립 앱 06 M4-12) — 04 §2-1 금지 5 의 유일한 예외.
// 🔴 링크 = 데이터(01 §4-4) — [IncidentBanner.actionLink] · [RunbookRow.deepLink] · 화면이 id 로 링크를 짓지 않는다.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/incident.dart';
import '../enums/ui.dart';
import 'common.dart';

part 'incident.freezed.dart';
part 'incident.g.dart';

/// `D-01` 배너 1건(04 §6 · K8).
@freezed
abstract class IncidentBanner with _$IncidentBanner {
  const factory IncidentBanner({
    /// 아이콘 선택에만. 모르는 wire = [IncidentKind.other].
    @JsonKey(unknownEnumValue: IncidentKind.other) required IncidentKind kind,

    /// 색 선택에만(`blocked`·`act`·`watch`·`info` — 🔴 `ok` 는 오지 않는다).
    required UiLevel level,

    /// «증권사 접근 토큰이 만료되었습니다» — 엔진(종류별로 다른 문구 · 04 §6).
    required String title,

    /// 본문 한 문단 — 엔진.
    required String bodyText,

    /// 조치 버튼 0/1(글자 + 목적지 = 엔진 · 예 «연결 설정 열기» → `aaq://settings/credentials`). null = 버튼 부재.
    /// 🔴 칸 이름 `action` 을 쓰지 않는다 — C-50 ⑨ 가 «모든 픽스처의 `action` 키 = `OnboardingAction`» 으로 걷는다(드라이런).
    LinkAction? actionLink,
  }) = _IncidentBanner;

  factory IncidentBanner.fromJson(Map<String, dynamic> json) =>
      _$IncidentBannerFromJson(json);
}
// JSON 키: kind · level · title · body_text · action_link

/// `D-01` VM(K9) — 🔴 **최대 1건**. 여러 건이면 엔진이 정렬해 첫 건을 준다. null = 배너 없음(스트림은 늘 값을 낸다).
@freezed
abstract class IncidentBannerVm with _$IncidentBannerVm {
  const factory IncidentBannerVm({IncidentBanner? banner}) = _IncidentBannerVm;

  factory IncidentBannerVm.fromJson(Map<String, dynamic> json) =>
      _$IncidentBannerVmFromJson(json);
}
// JSON 키: banner

/// `D-02` 목록 1행(K10).
@freezed
abstract class RunbookRow with _$RunbookRow {
  const factory RunbookRow({
    /// «운영 폰을 잃어버렸거나 고장 났을 때» — 엔진(원고).
    required String title,

    /// 한 줄 요약 — 엔진. null = 줄 없음.
    String? summaryText,

    /// 상세 링크(`aaq://ops/runbooks/<runbookId>` · ⑥ = `aaq://ops/emergency-card`) — 엔진 완성 · 🔴 화면은 열기만.
    required String deepLink,
  }) = _RunbookRow;

  factory RunbookRow.fromJson(Map<String, dynamic> json) =>
      _$RunbookRowFromJson(json);
}
// JSON 키: title · summary_text · deep_link

/// `D-02` 목록 VM(K10). 🔴 행 수·차례 = 받은 그대로(6 리터럴 0).
@freezed
abstract class RunbookIndexVm with _$RunbookIndexVm {
  const factory RunbookIndexVm({
    required List<RunbookRow> rows,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,
  }) = _RunbookIndexVm;

  factory RunbookIndexVm.fromJson(Map<String, dynamic> json) =>
      _$RunbookIndexVmFromJson(json);
}
// JSON 키: rows · empty_label

/// 런북·긴급 카드의 단계 1개(K10). 🔴 번호 = [orderText] 글자(화면이 `i + 1` 로 짓지 않는다 · «2-1.» 꼴도 온다).
@freezed
abstract class RunbookStep with _$RunbookStep {
  const factory RunbookStep({
    /// «1.» · «2-1.» — 엔진.
    required String orderText,

    /// 단계 글자 — 엔진(원고).
    required String text,
  }) = _RunbookStep;

  factory RunbookStep.fromJson(Map<String, dynamic> json) =>
      _$RunbookStepFromJson(json);
}
// JSON 키: order_text · text

/// `D-02` 상세 VM(K10). 🔴 [missingLabel] non-null ⇔ [steps] 0 ∧ [introText] null(모르는 id = 값 · 스트림 에러 아님).
@freezed
abstract class RunbookVm with _$RunbookVm {
  const factory RunbookVm({
    required String title,

    /// 머리 한 문단 — 엔진. null = 없음.
    String? introText,

    /// 번호 단계(받은 차례 그대로).
    required List<RunbookStep> steps,

    /// 하단 고지 «확인 표시는 이 화면에서만 보입니다. 저장되지 않고, 아무것도 실행하지 않습니다.» — 엔진(늘 싣는다).
    required String localCheckNotice,

    /// 모르는·지난 id = 엔진 문장.
    String? missingLabel,
  }) = _RunbookVm;

  factory RunbookVm.fromJson(Map<String, dynamic> json) =>
      _$RunbookVmFromJson(json);
}
// JSON 키: title · intro_text · steps · local_check_notice · missing_label

/// `D-03` 오프라인 긴급정지 카드 VM(K11) — 가족용 한 장(전문 용어 0 · 문안 = 원고).
/// 🔴 계좌번호·앱키·개인 연락처는 이 VM 어디에도 없다(C-14 · C-51 ⑤ · 엔진 원고 검증 게이트).
@freezed
abstract class EmergencyCardVm with _$EmergencyCardVm {
  const factory EmergencyCardVm({
    required String title,

    /// 정지 단계(받은 차례 · `RunbookStep` 재사용).
    required List<RunbookStep> steps,

    /// «한국투자증권 고객센터 1544-5000 · 연락처는 종이에 직접 적어 둡니다» — 엔진(공개 대표번호만).
    required String contactLine,

    /// «이 카드는 인쇄해 종이로 보관하세요. 계좌번호와 앱키는 이 카드에 없습니다.» — 엔진(늘 싣는다).
    required String keepOnPaperNotice,

    /// 인쇄·PDF 슬롯 이름(`OpsSlotIds.emergencyCardPrint`). null = 인쇄 자리 부재(인쇄할 수 없는 빌드).
    String? printSlotId,
  }) = _EmergencyCardVm;

  factory EmergencyCardVm.fromJson(Map<String, dynamic> json) =>
      _$EmergencyCardVmFromJson(json);
}
// JSON 키: title · steps · contact_line · keep_on_paper_notice · print_slot_id
```

---

## `packages/domain_contracts/lib/src/dto/journal.dart`

```dart
// packages/domain_contracts/lib/src/dto/journal.dart
//
// 01 §2-2 «TradeJournalEntry — 매매일지 1행»(M6, 요구 1) + 01 §2-11 `BackdateStamp`(X7)
// + M6 미정의 9건 중 6건(m2-8 E-1~E-5 · D-10) · 인벤토리 §3-2 · §3-14(영역 B).
//
// 조인 체인 `signals → order_intents → broker_orders → executions → trades → decision_log`
// 을 **화면이 조인하지 않도록** 평탄화한 것이다(01 §2-2).
//
// 🔴 계산 getter 0건(01 §1-4) · 문구는 전부 엔진 생성(01 §1-5).
// 🔴 분할 집행 진도는 이 타입에 **없다**(01 §2-2 말미 · G-46 · m2-8 C-11 ⏸) —
//    「n일차」·「이월 n주」 필드를 만들지 않는다.

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/journal.dart';
import '../enums/mode.dart';
import '../enums/order.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/date_range.dart';
import '../primitives/money.dart';
import 'advice.dart';
import 'common.dart';
import 'rebalance.dart';

part 'journal.freezed.dart';
part 'journal.g.dart';

/// 매매일지 1행(01 §2-2).
///
/// 🔴 `status == prevented` 는 «이중 발주 차단이 작동함»이며 **성공으로 렌더**한다.
/// 🔴 `status == unknown` 은 UNKNOWN 해소 보드로 딥링크한다 — 화면이 «실패»로 단정하지 않는다.
/// 🔴 `fillKind == reversal`·`restatement` 행은 «매매로 읽히는 표현»을 쓰지 않는다
///    (방향 색 금지 · 손익 기여 0) — 문구는 `statusLabel`·`originLabel` 이 준다.
/// 🆕 v1.17(엔진 D11) — `status == expired` = 일 마감 실효(취소 아님 · 사유 칩 `DAY_END_EXPIRED`). `status == prevented` 행의 근거 =
/// [decision] 의 `intentId`(그 멱등키를 이미 가진 **원 의도** · 새 의도 행 0 — R33 D24) + 사유 칩 `DUPLICATE_ORDER_PREVENTED`(`JournalReasonCodes`).
@freezed
abstract class TradeJournalEntry with _$TradeJournalEntry {
  const factory TradeJournalEntry({
    required String entryId,

    /// SIM 행은 배지 + 수익률 집계 제외
    required RunMode mode,
    @TradeDateConverter() required TradeDate tradeDate,

    /// UTC. null 이면 미체결.
    /// 🔴 정렬·비교용이지 표시용이 아니다(01 §1-3).
    DateTime? executedAt,
    required String symbol,

    /// "069500 KODEX 200" — 엔진 생성
    required String symbolLabel,
    required SleeveId sleeve,

    /// 🔴 필터 인자·테스트용이지 **표시용이 아니다** — 화면은 [sideLabel] 을 그린다.
    required OrderSide side,

    /// 🆕 v1.1(§8 미결 34) — "매수" · "매도" / 정정 행은 "역분개" · "재기재" — 엔진 생성.
    /// 🔴 화면이 `side`·`fillKind` 로 문구를 고르지 않는다(01 §1-5).
    required String sideLabel,

    // ── 원값 4종 — 🔴 **표시용이 아니다**(계약 테스트 C-22 합산·정렬의 입력).
    //    화면은 아래 `*Text` 만 그린다(v1.1 · §8 미결 35).
    required int quantity,
    @DecimalStringConverter() required Decimal price,
    @DecimalStringConverter() required Decimal commission,
    @DecimalStringConverter() required Decimal tax,

    // ── 🆕 v1.1(§8 미결 35) 표시 문자열 4종 — 천 단위 구분·단위·부호까지 엔진 완성.
    //    🔴 차단 시 **가림도 여기서 끝난다**(01 §2-10 «값 가림의 주체 = 엔진 읽기 경로») —
    //       `LEDGER_INTEGRITY` 면 "숨김", `RECON_MISMATCH` 대상 종목이면 "120주?" 로 온다.
    //       화면은 플래그를 보고 이 문자열을 바꾸거나 감추지 않는다.
    /// "120주" · "−8주"(역분개) · "숨김"
    required String quantityText,

    /// "38,250원"
    required String priceText,

    /// "688원"
    required String commissionText,

    /// "0원"
    required String taxText,
    required JournalStatus status,

    /// "체결" · "결과 확인 중" · "이중 발주 차단됨" — 엔진 생성.
    /// 🔴 화면이 `status` 로 문구를 고르지 않는다(01 §1-5).
    required String statusLabel,

    /// 배지 색의 근거. `prevented` 는 실패가 아니라 방어다.
    required ChipTone statusTone,
    required FillVisibility visibility,

    /// "반영 대기 +12주" · "확정" — 엔진 생성.
    /// 🔴 화면이 수량을 더해 만들지 않는다.
    required String visibilityLabel,

    /// 진입 사유 / 청산 티어 / 거부 사유 — 🔴 **최소 1개**
    required List<ReasonChip> reasons,
    required DecisionRef decision,
    required DeviationBadge deviation,

    /// "연금저축" — 🔴 계좌 전체번호 금지
    String? accountAlias,

    // ── 🆕 X7(01 §10) — 수기 체결이 같은 스트림으로 들어오므로
    //    «누가·무엇을·언제 적었나»가 행에 붙는다 ──────────────────────────
    required FillOrigin fillOrigin,
    required FillKind fillKind,

    /// null = 안내와 무관한 수기 신규(01 §10-3)
    String? adviceId,

    /// 🔴 «기록일 ≠ 거래일»의 유일한 표현 — 화면이 두 날짜를 빼지 않는다.
    required BackdateStamp backdate,

    /// 🆕 C18 — 구 `costsOverridden`(bool) 폐기
    required CostSource costSource,

    /// "비용 추정치" / "비용 수정됨" / 공백 — 엔진 생성
    required String costSourceLabel,

    /// "수기 기록" / "브로커 체결" — 엔진 생성
    required String originLabel,

    /// 🆕 G-40 — 이 체결이 속한 리밸런싱 회차. null = 회차 밖.
    /// 🔵 v1.5(01 §15-3) — `RebalanceKind.deposit`(월 납입 배분) 회차의 체결은 그 회차에 묶인다
    ///    (입금 배분 = 회차 안). advisory 회차에서 나온 수기 체결도 그 회차에 묶인다(발주자 결정 ④-2 ·
    ///    엔진 숙제 06 X7-1) — 그래야 «이 회차의 … N건» 버튼이 빈 목록을 열지 않는다.
    /// 🔴 화면이 `RebalanceEvent.orderIntentIds` 배열로 목록을 거르지 않게 하는 필드다.
    String? rebalanceEventId,

    /// 🆕 v1.1(§8 미결 36) — 이 행의 `J-2` 거래 상세 링크(`aaq://journal/decision/…`).
    /// 🔴 null 이면 행 탭에 반응이 없다(상세 없음). 화면이 `decisionId` 로 링크를 조립하지 않는다.
    String? detailDeepLink,
    required AsOf asOf,
  }) = _TradeJournalEntry;

  factory TradeJournalEntry.fromJson(Map<String, dynamic> json) =>
      _$TradeJournalEntryFromJson(json);
}

/// 규칙대로인가, 사람이 개입했나(01 §2-2).
///
/// `kindCode` 값 13종은 영역 E 의 `labels/deviation_kind_codes.dart` 가 정본이다
/// (기존 4 + X7 9 · 인벤토리 §6-10).
@freezed
abstract class DeviationBadge with _$DeviationBadge {
  const factory DeviationBadge({
    required bool isDeviation,
    String? kindCode,

    /// "규칙대로" / "재량 조정 (롤링 12개월 4회 중 2회째)" — 엔진 생성
    required String label,

    /// `decision_journal` 링크(사전 근거·기대 결과·인용 규칙)
    String? journalId,
  }) = _DeviationBadge;

  factory DeviationBadge.fromJson(Map<String, dynamic> json) =>
      _$DeviationBadgeFromJson(json);
}

/// 🆕 X7 — «기록일 ≠ 거래일»의 유일한 표현(01 §2-11).
///
/// 🔴 화면이 두 날짜를 빼지 않는다. 🔴 `priceRangeSourceDate` 는 **검증의 근거일**이며
///    라벨에 "가격은 9월 2일 기준 [저가, 고가]로 검증됨"을 엔진이 쓴다(B4) —
///    근거일이 보이지 않으면 사람은 그것을 조작 축으로 쓴다.
@freezed
abstract class BackdateStamp with _$BackdateStamp {
  const factory BackdateStamp({
    @TradeDateConverter() required TradeDate tradeDate,
    required DateTime authoredAt,
    required int backdateTradingDays,
    required bool isBackdated,

    /// "소급 기록 · 거래일 대비 D+4" — 엔진 생성
    required String label,
    @TradeDateConverter() required TradeDate priceRangeSourceDate,

    /// 월간 리포트가 발행된 달로의 소급
    required bool crossesClosedPeriod,
    String? closedPeriodNote,
  }) = _BackdateStamp;

  factory BackdateStamp.fromJson(Map<String, dynamic> json) =>
      _$BackdateStampFromJson(json);
}

/// 결정 스냅샷 — `J-2` 결정 상세의 뼈대(02 §8-1 · m2-8 E-1).
///
/// 🔴 `ruleCited` 는 엔진 제공 목록의 코드다(자유 입력 금지).
@freezed
abstract class DecisionSnapshot with _$DecisionSnapshot {
  const factory DecisionSnapshot({
    required DecisionRef ref,
    @TradeDateConverter() required TradeDate tradeDate,

    /// "진입" · "청산(TIER 1B)" — 엔진 생성
    required String kindLabel,
    required List<ReasonChip> reasons,
    required TriggerSnapshot trigger,
    String? ruleCited,

    /// 한 줄 요약 — 엔진 생성
    required String summary,
  }) = _DecisionSnapshot;

  factory DecisionSnapshot.fromJson(Map<String, dynamic> json) =>
      _$DecisionSnapshotFromJson(json);
}

// 🆕 v1.6(01 §15-4) — `ThresholdCompare`(임계값 대조 1행)는 `common.dart` 로 옮겼다(이름·필드·JSON·
//    배럴 export 무변경). `rebalance.dart` 의 `RebalanceEvent.thresholds` 가 같은 타입을 쓰는데, 이 파일이
//    이미 `rebalance.dart` 를 import 하므로 여기 두면 순환이 된다.

/// 거부 추적 1행 — 어느 단계에서 왜 막혔나(02 §8-1 · m2-8 E-3).
///
/// `stageCode` = 전수 검사의 층(`labels/journal_codes.dart` `SafetyCheckLevelCodes` —
/// 04_안전장치 P2 «Level 4 → 3 → 2 → 1»). `reasonCode` 는 SAF 코드 **원문 그대로**다.
@freezed
abstract class RejectTrace with _$RejectTrace {
  const factory RejectTrace({
    required String stageCode,
    required String stageLabel,
    required String reasonCode,
    required String reasonLabel,

    /// 🔴 정렬·비교용이지 표시용이 아니다(01 §1-3).
    required DateTime occurredAt,

    /// 🆕 v1.1 — "08-13 09:01" 엔진 포맷. 화면이 `occurredAt` 을 포맷하지 않는다.
    String? occurredAtText,
  }) = _RejectTrace;

  factory RejectTrace.fromJson(Map<String, dynamic> json) =>
      _$RejectTraceFromJson(json);
}

/// 사전 저널(`J-3`) 폼 스펙(02 §8-1 · m2-8 E-4).
///
/// 🔴 `ruleCitedOptions` 는 **엔진 제공 목록**이며 자유 입력을 허용하지 않는다.
/// ⏸ `ReasonOption` 재사용은 m2-8 H-5(선행 미결 §8-20 · D19) — 통합 권고를 따랐다.
/// 🆕 v1.1 — 읽기 창구 `JournalRepository.draftFormSpec(decisionId)` 와 함께 4필드 추가:
///    `decisionId`(제출 `JournalDraft.decisionId` 에 그대로 넣는 값) · `pledgeLines`(본인
///    서약문 — 🔴 편집 불가 · 0줄이면 서약 블록 자체가 없다) · `contextChips`(문맥 칩) ·
///    `deviation`(표시만 — 🔴 화면이 이탈 여부를 판정하지 않는다).
/// 🆕 v1.35(01 §44 · K296 · K300) — [decisionId] 값 = **저널 id**(이름 그대로) · `pledgeLines` = 지금 서약 판을 재량 예산을 쓰는
///    목적(`DISCRETION` · 채우기 갈래의 `MANUAL_ORDER` · `MANUAL_ENTRY`)에만 · 그 밖 0줄 · `ruleCitedOptions[].code` ∈ `JournalRuleCitedCodes`.
@freezed
abstract class JournalDraftFormSpec with _$JournalDraftFormSpec {
  const factory JournalDraftFormSpec({
    required String decisionId,

    /// 본인 서약문(청사진 §9-2) — 엔진이 준 문장을 **그대로·순서대로** 그린다.
    required List<String> pledgeLines,
    required List<ReasonChip> contextChips,
    required DeviationBadge deviation,
    required List<ReasonOption> ruleCitedOptions,
    required int rationaleMinChars,

    /// "제출 뒤에는 수정할 수 없습니다" — 엔진 생성
    required String noticeLine,
    required AsOf asOf,
  }) = _JournalDraftFormSpec;

  factory JournalDraftFormSpec.fromJson(Map<String, dynamic> json) =>
      _$JournalDraftFormSpecFromJson(json);
}

/// 블라인드 리뷰 카드(`J-4`)(02 §3-4 · m2-8 E-5). 🆕 v1.7(01 §16 · §8 미결 46).
/// 창구 = `JournalRepository.watchBlindReviewQueue()`(대기 목록 · 봉투) · `watchBlindReviewCard(decisionId)`(1건).
///
/// 🔴 [result] 가 null 인 동안 이 카드에는 결과·손익이 **없다** — 가리는 것이 아니라 없음(02 §3-4 금지 ③).
///    엔진은 채점 명령(`BLIND_REVIEW_SCORE`)이 **집행된 뒤에만** [result] 를 채운다.
/// 🔴 화면은 [result] 의 null 여부 **하나로만** 결과 섹션을 그린다 — 접수증 상태로 공개를 판정하지 않는다.
/// 🔴 [result]·[asOf] 를 뺀 나머지 필드는 채점 전·후 **같다**(C-43 ④ — 골든 `j4_before_reveal` ↔ `j4_after_reveal` 의 근거).
///    [asOf] 는 관측 시각이라 집행 뒤 새 값이 오면 바뀌는 것이 정상이다(v1.6 뜻 고정 — `rebalance.dart:9·25`).
///    [journal]·[journalStateLabel] 도 같다 — 큐에 들어온 뒤에는 바뀌지 않는다(엔진 의무 · K3 ⓓ).
/// 🔴 앱 안 이동 링크는 [result] 안에만 있다 — 채점 전 카드의 링크는 문맥 칩의 핸드북 앵커뿐이다(K8).
/// 🔴 화면이 [questions] 의 점수를 합산·표시·비교하지 않는다 — 과정 점수는 [BlindReviewResult.processScoreText](엔진).
@freezed
abstract class BlindReviewCard with _$BlindReviewCard {
  const factory BlindReviewCard({
    /// 키 — 🔴 표시 금지. 제출 `BlindReviewScore.decisionId` 에 그대로 넣는다.
    required String decisionId,

    /// 🆕 v1.7 — "2026-08-11 · 0085P0 KODEX 국고채30년 · 매수 결정" — 엔진 생성.
    /// 🔴 금액·수량·가격·수익률·손익 없음(C-43 ③).
    required String titleText,

    /// "결과를 보기 전에 이 결정의 과정을 채점합니다" 류 — 엔진 생성.
    required String promptText,

    /// 🆕 v1.7 — 결정 문맥 칩(진입 사유 등) — `JournalDraftFormSpec.contextChips` 와 같은 사전.
    /// 🔴 칩 `detailDeepLink` 는 `handbook://` 이거나 null(채점 전 앱 안 링크 0 — C-43 ⑥).
    required List<ReasonChip> contextChips,

    /// 🆕 v1.7 — 이탈 배지 — 표시만(🔴 화면이 이탈 여부를 판정하지 않는다 · `isDeviation` 미참조).
    required DeviationBadge deviation,

    /// 🆕 v1.7 — "저널 작성됨" · "저널 미작성" — `DecisionJournalVm.journalStateLabel` 과 같은 사전.
    required String journalStateLabel,

    /// 🆕 v1.7 — 사전 저널 본문(01 §12-2 · 결과·손익 없음 · 추가 금지 — C-34 ⑧).
    /// null = 미작성 → 본문 블록 **부재**(자리표시자 금지).
    DecisionJournalBody? journal,

    /// 과정 채점 문항 — **받은 순서 그대로**(3~5문항 · 03_실행 §8-3).
    required List<BlindReviewQuestion> questions,

    /// 🆕 v1.7 — 채점 결과. 🔴 null = 채점 전(대기 목록의 행은 **늘** null).
    BlindReviewResult? result,

    /// 🆕 v1.7 — 1건 창구(봉투 없는 값)의 머리·신선도 = 읽기 모델 **관측 시각**(v1.6 뜻).
    /// 대기 목록의 행에서는 봉투 `as_of` 와 같다. 채점 집행 뒤 새 값에서는 바뀌어도 된다.
    required AsOf asOf,
  }) = _BlindReviewCard;

  factory BlindReviewCard.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewCardFromJson(json);
}

/// 블라인드 리뷰 문항 1건(m2-8 E-5). 🆕 v1.7 — 선택지 형 교체 · 근거 줄.
@freezed
abstract class BlindReviewQuestion with _$BlindReviewQuestion {
  const factory BlindReviewQuestion({
    /// 키 — 🔴 표시 금지. `BlindReviewScore.answers` 의 키.
    required String questionId,

    /// "결정 시점에 가용했던 정보만 썼는가" — 엔진 생성.
    required String text,

    /// 🆕 v1.7 — 판단 근거 한 줄("입력 데이터 기준 2026-08-10 · 결정 2026-08-11 09:05") — 엔진 생성.
    /// null = 줄 부재. 🔴 결과·손익 없음.
    String? evidenceText,

    /// 🆕 v1.7 — 구 `List<ReasonOption>`(코드) → 점수를 싣는 선택지(§8 미결 46 축 정렬) · 받은 순서 그대로.
    required List<BlindReviewChoice> choices,
  }) = _BlindReviewQuestion;

  factory BlindReviewQuestion.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewQuestionFromJson(json);
}

/// 🆕 v1.7 — blind 리뷰 선택지 1건(01 §16 · §8 미결 46).
///
/// 🔴 [score] 는 **엔진이 정한 값**이다. 화면은 고른 선택지의 [score] 를
///    `BlindReviewScore.answers[questionId]` 에 **그대로 옮길 뿐**이다 — 표시·합산·비교·변환 0(C-43 ⑫ · 제출 견본 ⑨).
/// 🔴 한 문항 안에서 [score] 는 서로 다르다(C-43 ① — 점수가 곧 선택의 식별자다).
@freezed
abstract class BlindReviewChoice with _$BlindReviewChoice {
  const factory BlindReviewChoice({
    required int score,

    /// "예" · "아니오" — 엔진 생성.
    required String label,
  }) = _BlindReviewChoice;

  factory BlindReviewChoice.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewChoiceFromJson(json);
}

/// 🆕 v1.7 — blind 리뷰 결과(공개 섹션). 🔴 엔진은 채점 명령 집행 **뒤에만** 싣는다.
/// 🔴 `LEDGER_INTEGRITY` 중에는 [outcomeText]·[detailLines] 가 엔진 쪽에서 가려져 온다(01 §2-10 «가림의 주체 = 엔진»).
/// 🔴 (K6 ✅ 확정 2026-10-20) 금액(원) 문자열 0 · 수익률·보유기간·방향 문장만(미이행 결정 = 반사실 금액 0 · 방향·bp 만).
@freezed
abstract class BlindReviewResult with _$BlindReviewResult {
  const factory BlindReviewResult({
    /// "과정 점수 4점 — 좋은 결정(4점 이상)" — 엔진이 제출된 답에서 셈(🔴 화면 집계 0 · 02 금지 ①).
    required String processScoreText,

    /// "결과: 수익률 +x.x% · 보유 n거래일" / "미청산 — 결과 미확정" — 엔진 생성.
    required String outcomeText,

    /// 보조 줄 — 받은 순서 그대로 · 0줄 = 블록 부재.
    @Default(<String>[]) List<String> detailLines,

    /// 「이 결정 보기」 → `J-2`(`aaq://journal/decision/<id>`). null = 부재.
    LinkAction? decisionLink,
  }) = _BlindReviewResult;

  factory BlindReviewResult.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewResultFromJson(json);
}

/// UNKNOWN 해소 보드의 단계 1행(02 §8-1 · m2-8 D-10).
///
/// `OnboardingStep`·`HandoverStep` 과 **같은 모양**을 따른다 — 같은 모양을 세 번째로
/// 만드는 것이 새 모양을 만드는 것보다 낫다.
@freezed
abstract class UnknownResolutionStep with _$UnknownResolutionStep {
  const factory UnknownResolutionStep({
    required String stepId,
    required int order,
    required String title,

    /// 왜 필요한가 — 엔진 생성
    required String whyLine,
    required GateState state,
    required String stateLabel,
    String? deepLink,
  }) = _UnknownResolutionStep;

  factory UnknownResolutionStep.fromJson(Map<String, dynamic> json) =>
      _$UnknownResolutionStepFromJson(json);
}

// ════════════════════════════════════════════════════════════════════════════
// 🆕 계약 v1.1(2026-09-17 · M2 보강) — J-1 필터·배지 · J-2 상세 · J-5 보드
// ════════════════════════════════════════════════════════════════════════════

/// `J-1` 필터의 「상태」 선택지 1건(§8 미결 37).
///
/// 🔴 선택지의 **목록·순서·문구**를 엔진이 준다 — 화면이 `JournalStatus.values` 를 순회하며
///    라벨을 붙이지 않는다(01 §1-5). 고른 값은 `watchTimeline(status:)` 인자로 그대로 간다.
@freezed
abstract class JournalStatusOption with _$JournalStatusOption {
  const factory JournalStatusOption({
    required JournalStatus status,

    /// "체결" · "결과 확인 중" — 엔진 생성
    required String label,
  }) = _JournalStatusOption;

  factory JournalStatusOption.fromJson(Map<String, dynamic> json) =>
      _$JournalStatusOptionFromJson(json);
}

/// `J-1` 필터의 「출처」 선택지 1건(§8 미결 37 · G-39).
@freezed
abstract class FillOriginOption with _$FillOriginOption {
  const factory FillOriginOption({
    required FillOrigin origin,

    /// "브로커 체결만" · "수기 기록만" — 엔진 생성
    required String label,
  }) = _FillOriginOption;

  factory FillOriginOption.fromJson(Map<String, dynamic> json) =>
      _$FillOriginOptionFromJson(json);
}

/// `J-1` 필터 카탈로그(§8 미결 37) — 창구는 `JournalRepository.watchFilterCatalog()`.
///
/// 🔵 기간은 `ConfigRepository.watchRangePresets()`, 슬리브는 `watchSleeves()` 가 준다 —
///    이 타입은 **나머지 셋**(상태·출처·종목)만 싣는다(같은 목록을 두 벌 두지 않는다).
/// 🔴 「전체」(필터 없음)는 선택지가 아니라 **인자 null** 이다 — 그 버튼 문구는 정적 라벨이다.
@freezed
abstract class JournalFilterCatalog with _$JournalFilterCatalog {
  const factory JournalFilterCatalog({
    required List<JournalStatusOption> statusOptions,
    required List<FillOriginOption> originOptions,

    /// 일지에 등장한 종목 — 🔴 화면이 `rows` 에서 종목을 모으지 않는다.
    required List<SymbolOption> symbolOptions,
    required AsOf asOf,
  }) = _JournalFilterCatalog;

  factory JournalFilterCatalog.fromJson(Map<String, dynamic> json) =>
      _$JournalFilterCatalogFromJson(json);
}

/// 🆕 v1.5(01 §15-3 · §8 미결 49) — `J-1` 회차 조건의 **범위 설명**: 회차 칩 글자 + 씨앗 기간.
/// 창구 = `JournalRepository.watchRebalanceScope`.
/// 🔴 시트의 선택지가 아니다(회차 조건은 링크로만 들어온다 · 시트 상태 필드 신설 금지 — A14) —
///    그래서 `JournalStatusOption`·`FillOriginOption` 의 `*Option` 꼴이 아니다.
/// 🔴 화면이 `rebalanceEventId`·`RebalanceEvent.kindLabel`·`tradeDate` 로 글자를 만들거나
///    날짜 산술로 기간을 만들지 않는다.
@freezed
abstract class JournalRebalanceScope with _$JournalRebalanceScope {
  const factory JournalRebalanceScope({
    /// 키 용 — 🔴 표시 금지.
    required String rebalanceEventId,

    /// "2026-08-03 월 납입 배분 회차" — 엔진 생성 · 🔴 식별자를 담지 않는다.
    required String label,

    /// 씨앗 기간 — 그 회차에 묶인 일지 행 **전부**를 덮는 구간(발주자 결정 ⑥ · 2026-10-07).
    /// `label` 은 엔진 생성 · 프리셋이 아니다(`presetCode` null · `isDefault` false).
    /// 🔴 화면은 이 값을 첫 쿼리의 `range` 로 그대로 쓴다(날짜 산술 0).
    required DateRange range,
  }) = _JournalRebalanceScope;

  factory JournalRebalanceScope.fromJson(Map<String, dynamic> json) =>
      _$JournalRebalanceScopeFromJson(json);
}

/// `J-1` 상단 배지 1건(§8 미결 38) — 창구는 `JournalRepository.watchTimelineBadges()`.
///
/// 🔴 **건수는 문구 안에 있다**("확인 중 2건") — 화면이 `rows` 를 세지 않는다(집계 = 재계산).
/// 🔴 목록이 비면 배지 줄 자체가 없다(「정상 = 무소식」 · 02 §3-5).
/// `badgeCode` 값은 `labels/journal_codes.dart` 의 `JournalBadgeCodes` 가 정본이다.
@freezed
abstract class JournalTimelineBadge with _$JournalTimelineBadge {
  const factory JournalTimelineBadge({
    required String badgeCode,

    /// "확인 중 2건" — 엔진 생성
    required String label,
    required ChipTone tone,

    /// 탭 목적지(`aaq://journal/unknown-board`). null 이면 탭 반응 없음.
    String? deepLink,
  }) = _JournalTimelineBadge;

  factory JournalTimelineBadge.fromJson(Map<String, dynamic> json) =>
      _$JournalTimelineBadgeFromJson(json);
}

/// `J-2` 체인 타임라인의 1단계(02 §3-2).
///
/// 🔴 단계는 **언제나 6칸**이고 결측이어도 자리를 유지한다 — 엔진이 6건을 순서대로 준다.
///    화면은 받은 순서대로 그리고 `stageCode` 로 문구·아이콘을 고르지 않는다.
/// 🔵 advisory 체인의 치환(브로커 주문·체결 → 안내·수기 기록)도 엔진이 이미 했다 —
///    화면이 `operatingMode` 로 갈래를 고르지 않는다.
/// `stageCode` 값은 `labels/journal_codes.dart` 의 `DecisionChainStageCodes` 가 정본이다.
@freezed
abstract class DecisionChainStep with _$DecisionChainStep {
  const factory DecisionChainStep({
    required String stageCode,

    /// "신호" · "의도" · "브로커 주문" · "안내" — 엔진 생성
    required String stageLabel,

    /// "완료" · "확인 중" · "거부" · "기록 없음" — 엔진 생성
    required String stateLabel,
    required ChipTone tone,

    /// "08-03 14:12" — 엔진 포맷(01 §1-3). null = 그 단계에 시각이 없다.
    String? occurredAtText,

    /// 단계 아래 보조 줄 — "주문번호 B0006" · "잔여 40주 미체결". 엔진 생성 · 순서 그대로.
    @Default(<String>[]) List<String> detailLines,

    /// 그 단계의 상세로 가는 링크(예 「안내」 노드 → `A-2`). null = 탭 반응 없음.
    String? deepLink,
  }) = _DecisionChainStep;

  factory DecisionChainStep.fromJson(Map<String, dynamic> json) =>
      _$DecisionChainStepFromJson(json);
}

/// `J-2` 거래 상세 한 화면의 전부 — 창구는 `JournalRepository.watchDecisionDetail(decisionId)`.
///
/// 🔴 화면이 조인·추정 재구성을 하지 않게 하는 타입이다: 체인 6단계 · 결정 당시 스냅샷 ·
///    임계값 대조 · 거부 추적 · 부분 체결/정정 체인 · 이동 버튼 4종이 **한 번에** 온다.
/// 🔴 손익 필드 없음(02 §3-2 금지 ③). 「재시도」·「강제 취소」 류 조작 링크도 오지 않는다.
/// 🔴 `LEDGER_INTEGRITY` 중에는 `entry`·`fills` 의 `*Text` 가 가려져 온다(구조만 렌더).
@freezed
abstract class DecisionDetailVm with _$DecisionDetailVm {
  const factory DecisionDetailVm({
    /// 상단 요약 — `J-1` 의 그 행과 같은 객체다.
    required TradeJournalEntry entry,

    /// 🔴 **항상 6건**(결측 단계도 자리 유지).
    required List<DecisionChainStep> steps,

    /// 결정 당시 스냅샷. null 이면 [snapshotMissingLabel] 을 그린다.
    DecisionSnapshot? snapshot,

    /// "스냅샷 없음(구 버전 기록)" — 🔴 화면이 추정해 재구성하지 않는다.
    String? snapshotMissingLabel,

    /// 트리거 값 vs 사전 등록 임계값 — 0건이면 표 자체가 없다.
    required List<ThresholdCompare> thresholds,

    /// 거부 추적(전수 검사 Level 4→1 순 · 04_안전장치 P2) — 0건이면 접이식 자체가 없다.
    required List<RejectTrace> rejectTraces,

    /// 이 결정의 체결 행들 — 부분 체결 다중 행 · 정정 체인(원본→역분개→재기재).
    /// 🔴 엔진이 정렬해서 준다. 화면이 체인 길이를 세어 버튼을 감추지 않는다.
    required List<TradeJournalEntry> fills,

    /// "잔여 40주 미체결" — 엔진 생성. 🔴 화면이 수량을 빼서 만들지 않는다.
    String? remainingText,

    /// "브로커 결과 확인 중 — 다음 배치에서 확정됩니다" — `status == unknown` 일 때.
    String? pendingNoticeText,

    /// X2 재판정 child 의 「원행 보기」.
    LinkAction? parentLink,

    /// 「이 회차」 → `S7-6b`. 🔴 null 이면 버튼은 **부재**다(비활성 아님 · G-40).
    LinkAction? rebalanceLink,

    /// "저널 작성됨" · "저널 미작성" — 엔진 생성
    required String journalStateLabel,

    /// 이 결정의 저널 버튼 — 🆕 v1.2 **엔진이 목적지를 고른다**(01 §12-2 표): 작성됨 = `journalRead`
    /// 링크(전 플랫폼) · 저널 대상·미작성 = 폰 읽기 경로만 `journalDraft` 링크(웹·iOS = null) ·
    /// 대상 아님 = null. 버튼 문구 = `label`(엔진) — 화면 분기 0.
    LinkAction? journalLink,

    /// 수기 체결 「정정」 → `M5-12`. 🔴 폰 읽기 경로만 채운다(웹·iOS 는 null = 진입점 부재).
    LinkAction? amendLink,
    required AsOf asOf,
  }) = _DecisionDetailVm;

  factory DecisionDetailVm.fromJson(Map<String, dynamic> json) =>
      _$DecisionDetailVmFromJson(json);
}

/// `J-5` UNKNOWN 해소 보드의 카드 1건(02 §3-5).
///
/// 🔴 경과 시간·건수를 화면이 계산하지 않는다 — `elapsedText` 가 준다.
/// 🔴 「재조회」·「강제 해소」 링크는 **오지 않는다**(브로커 재호출은 엔진 소관).
@freezed
abstract class UnknownResolutionItem with _$UnknownResolutionItem {
  const factory UnknownResolutionItem({
    required TradeJournalEntry entry,

    /// "발생 08-21 14:02 · 3영업일 경과" — 엔진 생성
    required String elapsedText,

    /// "이 종목의 신규 주문이 막혀 있습니다" — 엔진 생성
    required String effectLine,

    /// 단계 진행 4칸(`RECORDED → QUERY_PENDING → BROKER_CONFIRMED → RESOLVED`).
    required List<UnknownResolutionStep> steps,

    /// 장기 미해소 강조 — 🔴 임계 배치 수는 엔진이 판정한다(화면 상수 금지 · 02 §8-4).
    required bool emphasized,

    /// 장기 미해소일 때의 M5 안내 링크.
    LinkAction? escalationLink,
  }) = _UnknownResolutionItem;

  factory UnknownResolutionItem.fromJson(Map<String, dynamic> json) =>
      _$UnknownResolutionItemFromJson(json);
}

/// `J-5` 보드 전체 — 창구는 `JournalRepository.watchUnknownBoard()`.
@freezed
abstract class UnknownBoardVm with _$UnknownBoardVm {
  const factory UnknownBoardVm({
    required List<UnknownResolutionItem> items,

    /// "다음 배치(18:10)에서 조회로 확정됩니다" — 엔진 생성
    String? nextBatchNoticeText,

    /// "미해소 건이 없습니다" — `items` 가 비었을 때.
    String? emptyLabel,
    required AsOf asOf,
  }) = _UnknownBoardVm;

  factory UnknownBoardVm.fromJson(Map<String, dynamic> json) =>
      _$UnknownBoardVmFromJson(json);
}

// ════════════════════════════════════════════════════════════════════════════
// 🆕 계약 v1.2(R2b 선행 M2 보강 · 01 §12-2) — `J-3` 사전 저널 읽기(`J-3R`)
// ════════════════════════════════════════════════════════════════════════════

/// 🆕 v1.2 — 사전 저널 읽기(`J-3R` · 02 §3-3 R2b 블록). 봉투 없는 VM(01 §11-10 공통 상태 규칙).
/// 창구는 `JournalRepository.watchDecisionJournal(decisionId)`.
///
/// 🔴 결과·손익·수량·가격 필드가 **없고, 더하지 않는다** — `J-3` 안에 그려지므로 02 §3-3 금지 ③
///    «작성 중 손익 노출 금지»를 물려받고, ✅ v1.7 — `J-4` blind 리뷰의 `BlindReviewCard.journal` 이
///    [DecisionJournalBody] 를 재사용한다(01 §16). C-34 ⑧ 이 허용 키 목록으로 막는다(필드 추가 = 01 개정이 먼저).
@freezed
abstract class DecisionJournalVm with _$DecisionJournalVm {
  const factory DecisionJournalVm({
    required String decisionId,

    /// "저널 작성됨" · "저널 미작성" 류 — 엔진 생성(`DecisionDetailVm.journalStateLabel` 과 같은 사전).
    required String journalStateLabel,

    /// null = 아직 작성되지 않음 → 본문 블록 **부재**(자리표시자 금지).
    DecisionJournalBody? body,

    /// 「이 결정 보기」 → `J-2`. null = 부재(엔진이 정한다 — 화면은 판정하지 않는다).
    LinkAction? decisionLink,
    required AsOf asOf,
  }) = _DecisionJournalVm;

  factory DecisionJournalVm.fromJson(Map<String, dynamic> json) =>
      _$DecisionJournalVmFromJson(json);
}

/// 🆕 v1.2 — 사전 저널 본문. ✅ v1.7 — `BlindReviewCard.journal` 이 같은 타입을 싣는다(01 §16).
@freezed
abstract class DecisionJournalBody with _$DecisionJournalBody {
  const factory DecisionJournalBody({
    /// "2026-08-31 09:12 작성" — 엔진 생성(🔴 화면이 시각을 포맷하지 않는다).
    required String writtenAtText,

    /// 인용 규칙 code 의 문구(작성 당시 선택지 label) — 엔진이 준다(🔴 화면이 선택지 목록으로 찾지 않는다).
    required String ruleCitedLabel,

    /// ↓ 사람이 쓴 **원문** — 그대로 그린다(자르기·trim·`maxLines`·말줄임 금지 · 여러 줄 유지).
    required String rationaleBefore,
    required String expectedOutcome,

    /// null = 메모 블록 **부재**.
    String? note,
  }) = _DecisionJournalBody;

  factory DecisionJournalBody.fromJson(Map<String, dynamic> json) =>
      _$DecisionJournalBodyFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/ledger.dart`

```dart
// packages/domain_contracts/lib/src/dto/ledger.dart
//
// 01 §2-9 «LedgerDiffRow — X5 정합 검사» + m2-8 E-9(`LedgerRepairRow`)
// · 인벤토리 §3-6 · §3-14(영역 B).
//
// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
//    주문을 막지 않는다** — 화면이 «매매 중단»으로 읽히는 문구를 만들지 않는다.
// 🔴 대조 보드의 칸 수는 모드와 무관하게 **5 고정**이고 `applicable == false` 인 칸은
//    «점검 안 함»으로 그린다(빈칸·통과로 그리지 않는다).
// 🆕 계약 v1.12(01 §21 · R5 선행 · K25 · K26) — `L-1`·`L-2` 표시 계약: 짝 라벨·원인 후보 칩·표시 시각·조치 링크 ·
//    정정 행의 방향 색·대상 글자·체인 스탬프·결정 링크. 원값은 색·아이콘 exhaustive switch(C-12)와 들여쓰기
//    (`supersedes != null`)에만 쓰고 표시는 `*Label`·`*Text`·칩·링크뿐이다(C-47 ⑦).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'ledger.freezed.dart';
part 'ledger.g.dart';

/// 정합 검사 1행(01 §2-9).
/// 🆕 v1.12 — `L-1` 이 그리는 것은 `*Label`·`*Text`·칩·링크뿐 · 원값(`pair`·`axis`·`severity`·`status`·`route`)은
///    색·아이콘 exhaustive switch 에만(C-12) · 원값 표시 허용 = `evidenceHash`(그대로)·`authoredDate.yyyyMmDd`(날짜 예외 —
///    v1.8 E4) · `candidateOriginCodes`·`diffId` = 🔴 ui 미참조(C-47 ⑦) · 🔵 폰 «브로커 근거 원문» = v1 부재(해시만 ·
///    두 플랫폼 같음 · K26).
@freezed
abstract class LedgerDiffRow with _$LedgerDiffRow {
  const factory LedgerDiffRow({
    required String diffId,
    required LedgerPair pair,
    required LedgerAxis axis,
    @TradeDateConverter() required TradeDate authoredDate,

    /// "069500 수량 −3주 (정본 120 / 브로커 123)" — 엔진 생성
    required String deltaLabel,
    required DiffSeverity severity,

    /// 원인 코드 후보(01 §3-4) — 문자열 상수의 정본은 영역 E 의 `labels/origin_codes.dart`
    /// 🔴 ui 미참조(v1.12) — 표시는 [candidateOrigins].
    required List<String> candidateOriginCodes,
    required DiffStatus status,
    required RepairRoute route,

    /// 🔴 브로커 근거 원문은 로컬 전용 — 외부엔 해시만
    required String evidenceHash,

    /// 🆕 X7(C15 · G-27) — 🔴 «해당 없음»과 «일치»를 가르는 값.
    /// 저장 컬럼은 01 §6-6 배치 F 의 `ledger_diff.applicable` 이다.
    required bool applicable,

    // ── 🆕 계약 v1.12(01 §21 · K26) ─────────────────────────────────────────────
    /// "브로커 대조" — `DiagnosticCell.label`(`m8/recon_board_diff`) 과 같은 사전(C-47 ②).
    required String pairLabel,

    /// "수량" · "체결 건" · "현금" · "체인 해시".
    required String axisLabel,

    /// "주문 차단" · "관측 항목 — 주문을 막지 않습니다"(02 §5-1 상태).
    required String severityLabel,

    /// "열림" · "해소됨 · 2026-08-29" · "받아들임 · 2026-08-30"(🔴 accepted = resolved 와 같은 비중 · 02 §5-1).
    required String statusLabel,

    /// "자동 재동기화" · "승인 필요" · "X1 비상".
    required String routeLabel,

    /// 원인 후보 — 열람만(선택 UI·자유 서술 금지) · 칩 탭 = `detailDeepLink`(핸드북) · 받은 순서
    /// (== [candidateOriginCodes] 순서 · C-47 ②).
    required List<ReasonChip> candidateOrigins,

    /// 근거 카드 "탐지 2026-08-28 09:00" — 엔진.
    required String detectedAtText,

    /// 조치 1개(엔진이 고른다): `route == approval` ∧ 폰 = «정정하기» → `aaq://x5/repair-wizard` ·
    /// `pair == canonSelfReport` ∧ 폰 = «다시 실사하기» → `aaq://ledger/self-report/<yyyy-MM>/<별칭>`(02 §5-1 X7 추가 · K26) ·
    /// `SelfReportResult.diffs` 안 = null · 그 밖·뷰어 = null(부재). 해소(`M5-13`) = `SelfReportResult.resolveLink`.
    LinkAction? actionLink,
  }) = _LedgerDiffRow;

  factory LedgerDiffRow.fromJson(Map<String, dynamic> json) =>
      _$LedgerDiffRowFromJson(json);
}

/// 정정 이력 1행 — `ledger_repair`(append-only)의 표시판(02 §8-1 · m2-8 E-9).
///
/// 🔴 `recomputedFrom` 이 C-29(소급 정정 시계열 재계산)의 표시 축이다 —
///    이 값이 있으면 «그 날짜부터 다시 계산됐다»가 보여야 한다.
/// 🔴 `directionCode` 는 `ledger_repair.direction` CHECK 2값
///    (`DERIVED_RESYNC`·`CANON_CORRECT`)이며 화면이 문구를 고르지 않는다.
/// 🆕 v1.12(01 §21 · K24 · K25) — `L-2` 1행. 🔴 순서 = 엔진(시간 역순 묶음 · 정정의 정정은 그 원본 **바로 뒤** ·
///    02 §5-2 «원본 아래 계단식») · 들여쓰기 = `supersedes != null` 여부만(화면이 묶지 않는다) · 기존 [label](재계산
///    고지 · C-29)·[directionLabel] 은 그린다 · 원값(`appliedAt`·`directionCode`·`originCode`·`decisionId`·
///    `recomputedFrom`·`diffId`·`repairId`)은 ui 미참조.
@freezed
abstract class LedgerRepairRow with _$LedgerRepairRow {
  const factory LedgerRepairRow({
    required String repairId,
    required String diffId,
    required String directionCode,
    required String directionLabel,

    /// 원인 코드(01 §3-4)
    required String originCode,
    String? decisionId,
    required String evidenceHash,

    /// 이 정정이 대체한 앞선 정정 행
    String? supersedes,

    /// 🔴 소급 정정이면 여기부터 시계열을 다시 계산한다(C-29)
    @TradeDateConverter() TradeDate? recomputedFrom,
    required DateTime appliedAt,

    /// "브로커 기준으로 수량 정정 · 2026-08-24부터 재계산" — 엔진 생성
    required String label,

    // ── 🆕 계약 v1.12(01 §21 · K25) ─────────────────────────────────────────────
    /// "2026-08-24 11:02 적용" — 엔진.
    required String appliedAtText,

    /// 방향 배지 색(파생 재생성 = 자동 / 정본 정정 = 승인) — 🔴 화면이 `directionCode` 를 비교하지 않는다.
    required ChipTone directionTone,

    /// 원인 코드의 글자(01 §3-4) — 🔴 해설 생성 금지(02 §5-2).
    required String originLabel,

    /// "069500 수량 120 → 132주" · `LEDGER_INTEGRITY` = "숨김"(엔진 · 02 §5-2 상태).
    required String targetText,

    /// → `J-2`(`aaq://journal/decision/<decisionId>`) · null = 결정 없음. 저널(`J-3R`) 링크 = v1 부재(01 §8 미결 121).
    LinkAction? decisionLink,

    /// "이후 정정됨" — non-null ⇔ 뒤 행 하나가 이 행을 `supersedes` 한다(엔진).
    String? supersededLabel,

    /// 체인 스탬프 축약("chn_7f3a…c2" — `chain_hash` 의 축약 · 🔴 `evidenceHash` 와 다른 값 · 엔진) — 표시·복사.
    required String chainStampText,
  }) = _LedgerRepairRow;

  factory LedgerRepairRow.fromJson(Map<String, dynamic> json) =>
      _$LedgerRepairRowFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/ledger_trust.dart`

```dart
// 01 §2-11 — X7 원장 신뢰 등급 · 이행 갭 · 시스템 밖 자산 · 현금 추정 고지.
//
// 🔴 `LedgerTrustGrade.selfReported` 는 **실패가 아니라 정상 운영 상태**다.
// 🔴 이행 갭에 원화 손익 필드가 없다 — 가격 갭은 **bp** 로만 온다(C-25).
// 🔴 «추천·권유·자문·시그널» 금지어 규약이 `modeAdviceLine` 에도 적용된다(§10-1).
// 🆕 v1.6(01 §15-4 · R12 선행) — 월간 결과 래퍼 `ExecutionGapResult`(리포트 | 빈·해당없음 문장) ·
//    `ExecutionGapReport.countLines`·`correctionLines` · `complianceRateNormalized`·`modeAdviceLine` nullable.
//    `S7-10` 의 «읽지 않는 필드»는 `// 🔴 ui 미참조(C-42)` 표식이다.
// 🆕 v1.12(01 §21 · K8 · K9 · K36 ⓐ) — `L-3` 원장 실사 세션 VM `SelfReportSession`(+ 결과 `SelfReportResult`) ·
//    창구 `LedgerTrustRepository.watchSelfReportSession(yyyyMm, accountAlias)` · 세션 열기·닫기 = `SettingsActions`.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/date_range.dart';
import '../primitives/money.dart';
import 'advice.dart';
import 'common.dart';
import 'ledger.dart';

part 'ledger_trust.freezed.dart';
part 'ledger_trust.g.dart';

/// 01 §2-11 — 원장 신뢰 배지.
/// 🔴 `consequenceLine` 은 **어느 카운터 때문인지**를 말한다(B22) — "마지막 실사
///    후 63일 경과 — 실사 1회로 회복됩니다" 계열. 화면이 카운터를 세지 않는다.
@freezed
abstract class LedgerTrustBadge with _$LedgerTrustBadge {
  const factory LedgerTrustBadge({
    required LedgerTrustGrade grade,
    required UiLevel level,

    /// "자가 기록 — 브로커 대조 없음" — 엔진 생성.
    required String label,
    required String consequenceLine,

    /// "대사 전용 키를 등록하면 대조가 켜집니다" — 엔진 생성.
    String? upgradeHint,
    @TradeDateConverter() TradeDate? lastVerifiedOn,
    String? actionDeepLink,
  }) = _LedgerTrustBadge;

  factory LedgerTrustBadge.fromJson(Map<String, dynamic> json) =>
      _$LedgerTrustBadgeFromJson(json);
}

/// 🆕 v1.6 · 01 §15-4 — 월간 이행 갭 결과(`ExecutionGapRepository.monthly` 의 반환).
/// 🔴 [report] · [emptyLabel] 중 **정확히 하나** non-null · [emptyKind] ⇔ [emptyLabel](C-41 ⑧).
/// 🔴 안내 0건 = `EmptyKind.noData` · autoTrade 구간 = `EmptyKind.notApplicable`(03 §14-b) —
///    화면은 [emptyLabel] 문장 카드 하나만 그린다(`issued == 0`·`operatingMode` 로 고르지 않는다).
@freezed
abstract class ExecutionGapResult with _$ExecutionGapResult {
  const factory ExecutionGapResult({
    ExecutionGapReport? report,
    EmptyKind? emptyKind,
    String? emptyLabel,

    /// [report] 가 있으면 `report.asOf` 와 같은 값(C-41 ⑧).
    required AsOf asOf,
  }) = _ExecutionGapResult;

  factory ExecutionGapResult.fromJson(Map<String, dynamic> json) =>
      _$ExecutionGapResultFromJson(json);
}

/// 01 §2-11 — 이행 갭. M7 이 그리는 유일한 X7 지표 묶음(`S7-10`).
/// 🔴 `lateFilled`(지연 이행)는 분자에 **별도 계상**하고 라벨에 "(지연 이행 n건
///    포함)"을 엔진이 붙인다 — 지표는 정직하게, 벌점은 없다(A4).
@freezed
abstract class ExecutionGapReport with _$ExecutionGapReport {
  const factory ExecutionGapReport({
    required DateRange range, // 🔴 ui 미참조(C-42) — 표시는 [periodLabel]
    required String periodLabel,
    // 🔴 int 9종 전부 ui 미참조(C-42) — 표시는 [countLines]·[correctionLines].
    required int issued,
    required int filled,
    required int partial,
    required int skipped,
    required int lapsed,
    required int revoked,
    required int lateFilled,

    /// 🆕 v1.6 nullable — 0.0~1.0 · 게이지 **폭 전용**. null = 게이지 부재(가림 — RECON_MISMATCH 등).
    /// 표시는 `complianceRateLabel`.
    double? complianceRateNormalized,

    /// "이행률 82%(건수) · 76%(금액 가중)" — 엔진 생성. 가림이면 엔진이 «?» 로 가린 글자.
    required String complianceRateLabel,

    /// "기록까지 중앙값 1거래일" — 엔진 생성.
    required String medianDelayLabel,

    /// "안내 대비 중앙값 +9bp(불리)" — 🔴 bp, 금액 아님.
    required String priceGapLabel,

    /// 정정 체인 길이(상한 2회) — B6.
    required String amendChainMaxLabel,
    required List<ReasonChip> skipReasonBuckets,

    /// 진입/청산 이행률 비대칭 표식 — B2. 🔴 알림을 만들지 않는다.
    required List<ReasonChip> selectiveExecutionChips,
    required int backdatedCount, // 🔴 ui 미참조(C-42)
    required int selfReportCorrectionCount, // 🔴 ui 미참조(C-42)
    required LedgerTrustBadge trust,

    /// 🆕 v1.6 — 건수 묶음. 줄마다 엔진 완성 문장(«안내 24건» · «이행 12건 · 부분 이행 2건 · 지연 이행 1건» ·
    /// «건너뜀 6건 · 만료 4건 · 철회 0건») · 받은 순서 · 가림이면 줄 안 «?».
    required List<String> countLines,

    /// 🆕 v1.6 — 원장 교정·소급(«소급 기록 1건» · «자가 보고 정정 0건») · 둘 다 0 이면 **빈 목록** = 절 부재.
    required List<String> correctionLines,

    /// 🆕 v1.6 nullable — B21 3갈래: ⓐ «못 함» 우세 = 이관 제안 / ⓑ «안 함» 우세 = 이관을 제안하지 않고
    /// `J-4` blind 리뷰·연간 반증 조건 점검을 **문장 안에서** 가리킨다(버튼·링크 0) /
    /// ⓒ 갈리지 않음·정상 달 = **null = 줄 부재**(03 §14-b ⓒ «빈 줄을 자리표시자로 채우지 않는다»).
    String? modeAdviceLine,
    required AsOf asOf,
  }) = _ExecutionGapReport;

  factory ExecutionGapReport.fromJson(Map<String, dynamic> json) =>
      _$ExecutionGapReportFromJson(json);
}

/// 01 §2-11 — 시스템 밖 자산 1행(`external_holding`).
/// 🔴 표시 UNION 은 `HoldingsRepository` 한 곳에서만 만든다(D7 · C-23).
/// 🔴 유니버스 종목은 등록할 수 없다(`SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL`).
@freezed
abstract class ExternalHoldingRow with _$ExternalHoldingRow {
  const factory ExternalHoldingRow({
    required String externalId,
    required String symbol,
    required String symbolLabel,
    required String accountAlias,
    required int quantity,
    @TradeDateConverter() required TradeDate registeredOn,

    /// "시스템 밖 자산(수동) — 비중 계산에서 빠집니다" — 엔진 생성.
    required String scopeLabel,

    /// 🔴 등록도 결정이다.
    required DecisionRef decision,

    /// 🆕 v1.8 — "40주" — 엔진 완성. 🔵 사람이 등록한 값이라 `LEDGER_INTEGRITY` 가림 대상이 아니다
    ///    (02 §2-2 X7 B18 ① · K14 ✅). 🔴 화면이 관리 대상 수량과 더하지 않는다.
    required String quantityText,
  }) = _ExternalHoldingRow;

  factory ExternalHoldingRow.fromJson(Map<String, dynamic> json) =>
      _$ExternalHoldingRowFromJson(json);
}

/// 01 §2-11 — 현금 추정 고지. 키가 없으면 예수금을 모른다는 사실을 그대로 말한다.
@freezed
abstract class CashEstimateNotice with _$CashEstimateNotice {
  const factory CashEstimateNotice({
    required bool isEstimate,

    /// "현금은 기록 기반 추정치입니다 · 마지막 확인 9/1" — 엔진 생성.
    required String label,
    @TradeDateConverter() TradeDate? lastConfirmedOn,
  }) = _CashEstimateNotice;

  factory CashEstimateNotice.fromJson(Map<String, dynamic> json) =>
      _$CashEstimateNoticeFromJson(json);
}

/// 🆕 v1.12(01 §21 · K8 · K36 ⓐ) — `L-3` 원장 실사 세션 1개 = 그 달 · 그 계좌.
/// 창구 = `LedgerTrustRepository.watchSelfReportSession(yyyyMm, accountAlias)`.
/// 🔴 원장 현재값이 **없다**(앵커링 금지 · 02 §3-10) — 결과(엔진이 연 차이)는 제출 집행 뒤 [result] 로만 온다.
/// 🔴 세션은 `SettingsActions.run(selfReportSessionStart, {yyyy_mm, account_alias})` 로 열고 `selfReportSessionStop` 으로 닫는다
///    (K9) — 열린 동안 **그 폰의** 원장 파생 표시(H6·J-1·L-1…)는 `LEDGER_INTEGRITY` 와 같은 글자로 온다(엔진 · 화면은
///    모른다 · 가림 목록 필드 0). 🔴 `asOfTradeDate` 원값은 VM 에 두지 않는다(구현이 세션 기록에서 붙인다 · 초안 밖).
@freezed
abstract class SelfReportSession with _$SelfReportSession {
  const factory SelfReportSession({
    /// "8월 정기 실사" — 엔진.
    required String titleText,

    /// "실사 중에는 이 폰의 화면에서 보유 수량·금액이 가려집니다 · 원장 값은 제출 뒤에 보입니다" — 엔진(B15).
    required String noticeText,

    /// "2026-08-31 종가 기준으로 적으십시오" — 기준일은 엔진이 세션 시작 때 정한다(K8). 🔴 원값은 VM 에 없다.
    required String asOfTradeDateText,

    /// 유니버스 전 종목 — 받은 순서 = 행 순서 · 🔴 0 포함 필수 입력(B14) · 빈칸을 0 으로 바꾸지 않는다(`SelfReportLineInput`).
    required List<SymbolOption> symbols,

    /// "연금저축 계좌" — 이 세션의 계좌(라우트 `:accountAlias` 의 글자 · 🔴 계좌 전체번호 금지).
    required String accountLabel,

    /// "원화 현금 — 원 단위까지 적으십시오"(`SELF_AUDIT_PATTERN_UNVERIFIED` 뒤 · 02 §3-10) — 엔진.
    required String cashHintLabel,

    /// "이것이 전부입니다" 확인 글자 — 엔진.
    required String declareCompleteLabel,

    /// non-null = 세션이 열려 있지 않다(시작 거부·만료) → 폼 **부재** · 이 문장만.
    String? sessionClosedText,

    /// non-null = 제출 부재 + 문장(K21).
    String? blockedText,

    /// 제출 집행 뒤 결과 — non-null 이면 폼 부재 · 결과만(02 §3-10 «제출 후 = 엔진이 준 차이 목록만»).
    SelfReportResult? result,
    required LedgerTrustBadge trust,
    required AsOf asOf,
  }) = _SelfReportSession;

  factory SelfReportSession.fromJson(Map<String, dynamic> json) =>
      _$SelfReportSessionFromJson(json);
}

/// 🆕 v1.12(01 §21) — 실사 결과(골든 `l3_diff_result`).
@freezed
abstract class SelfReportResult with _$SelfReportResult {
  const factory SelfReportResult({
    /// 엔진이 연 `ledger_diff(pair == canonSelfReport)` — 받은 순서 · 🔴 화면이 차이를 계산하지 않는다 ·
    /// 각 행 `actionLink` = null(자기 자신으로 가는 고리 방지).
    required List<LedgerDiffRow> diffs,

    /// non-null ⇔ [diffs] 빈 목록 — "실사 결과가 원장과 맞습니다".
    String? emptyLabel,

    /// → `M5-13`(`aaq://m5/self-audit-resolve`) · null = 해소할 것 없음.
    LinkAction? resolveLink,

    /// 🆕(K36 ⓐ) "다음 계좌 실사 — 일반 계좌" → `aaq://ledger/self-report/<yyyy-MM>/<다음 별칭>` · null = 이 달 실사 끝.
    LinkAction? nextAccountLink,
  }) = _SelfReportResult;

  factory SelfReportResult.fromJson(Map<String, dynamic> json) =>
      _$SelfReportResultFromJson(json);
}

/// 01 §2-11 — 자가 실사 1행(`SelfReportBalance.lines` 의 원소).
@freezed
abstract class SelfReportLine with _$SelfReportLine {
  const factory SelfReportLine({
    required String symbol,
    required String symbolLabel,
    required int quantity,
  }) = _SelfReportLine;

  factory SelfReportLine.fromJson(Map<String, dynamic> json) =>
      _$SelfReportLineFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/migration.dart`

```dart
// 🆕 계약 v1.33(01 §42 · K264~K281 · E16j-b) — X1 기기 이전 화면(`X1-2`~`X1-6` · 🔒 `ui_safety`) VM.
//
// 옛 폰 계획 마법사(`x1Migration`) = [X1PlanWizardVm] · 새 폰 받기(`x1MigrationPlan`) · 새 폰 비상 복구(`x1MigrationEmergency`) =
// [X1RecoveryVm](같은 꼴 · 엔진이 갈래를 고른다). 창구 = `MigrationRepository`(폰 전용 · 라우트 인자 0 — 한 기기 한 이전 · 엔진이 마지막 run 을 안다).
// 🔴 문장 · 라벨 · 시각 · 해시 글자 = 엔진 · `code`/`reasonCode`/`blockCode`/`gateStateCode` 칸 = 화면 미참조(표본 · 사전 검사용) · 색 = `level` 하나.
// 🔴 동작 = 엔진이 완성한 `SafetyActionCall`(그대로 `SafetyActions.run` · args 의 `run_id` = 엔진) — 화면은 id · args 를 짓지 않는다.
// 🔴 발주자 수치(관찰 일수 · 넘김 시간 · 펜싱 마진 · 재생성 상한 · 티켓 TTL) = 엔진 글자로만(칸 0) · 카운트다운 0(절대 시각 글자).
// 🔴 시크릿(복구 코드 · 재발급 키 값) = 슬롯 ↔ 구현 사이만(동작 args 0 · v1.31 `supabaseSignIn` 선례) · 기기 id 원문 · sha256 전체 0.
// 🔴 VM 생산 · 단계 진행기 · 저장(REVOKED · 재발급) · 백업 바이트 원천 = 엔진 · 조립 숙제(01 §8 미결 218) — 그 전에는 엔진이 이 VM 을 내지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'incident.dart'; // EmergencyCardVm

part 'migration.freezed.dart';
part 'migration.g.dart';

/// 옛 폰 계획 교체 마법사(`x1Migration` · 06 X1-2 · 08 그림 9-1).
///
/// 🔴 시작 전 = [d03Card] 한 장(건너뛰기 0) + [startAction] «봤습니다 — 이전 시작» · 그때 [rows] 빈 목록.
/// 🔴 [lockedLabel] · [doneLabel] 가 non-null 이면 동작 0([startAction] · 행 동작) · 슬롯 0.
@freezed
abstract class X1PlanWizardVm with _$X1PlanWizardVm {
  const factory X1PlanWizardVm({
    /// 머리 문장(시작 전 · 단계 · 강등 뒤 · 끝) — 엔진.
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1StartResultCodes` ∪ `X1StepBlockCodes` ∪ `X1JournalResultCodes` ∪ `X1BootRefusalCodes` ∪ 공용.
    String? reasonCode,

    /// `D-03` 긴급정지 카드 한 장(기존 VM 재사용) — 시작 전만.
    EmergencyCardVm? d03Card,

    /// 엔진이 완성한 `x1PlanStart{}` — [d03Card] non-null ⇔ non-null(잠김 · 거부 제외).
    SafetyActionCall? startAction,

    /// 단계 9(`X1StepCodes.ordered` 차례) 또는 빈 목록(시작 전 · 거부).
    required List<X1StepRow> rows,

    /// 감시 유지보수 창 글자(열림 시각 · 넘김 — 엔진 글자 · 시간 칸 0).
    String? windowText,

    /// 보내지 않은 기록 · 초안 · 유예 경고 줄(D18 · D6) — 엔진(원천 = 미결 218 ⓐ).
    required List<String> warningLines,

    /// 티켓 QR 카드 — `TICKET_ISSUED` 뒤만.
    X1TicketCard? ticket,

    /// 끝난 뒤 문장. non-null ⇒ 동작 0.
    String? doneLabel,

    /// 생체 · 리스 · 뷰어 잠김. non-null ⇒ 동작 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _X1PlanWizardVm;

  factory X1PlanWizardVm.fromJson(Map<String, dynamic> json) =>
      _$X1PlanWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · d03_card · start_action · rows · window_text · warning_lines · ticket · done_label ·
//          locked_label · as_of

/// 단계 한 행 — 옛 폰 9 · 새 폰 5 공용.
@freezed
abstract class X1StepRow with _$X1StepRow {
  const factory X1StepRow({
    /// 🔴 화면 미참조 — ∈ `X1StepCodes` ∪ `X1RecoveryStepCodes`.
    required String code,
    required String title,

    /// 상태 글자(원천 = 저널 `X1StepStateCodes`) — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 막힘 이유 · DEMOTED «여기부터 되돌릴 수 없음» · 갭 위반 줄 — 엔진.
    required List<String> lines,

    /// 🔴 화면 미참조 — ∈ `X1StepBlockCodes` ∪ `X1GapViolationCodes` ∪ `X1GateReasonCodes`.
    String? blockCode,

    /// 엔진 완성 — 옛 폰 `x1PlanStep{run_id, step}` · `x1PlanAbort{run_id, step}`(DEMOTED 앞만) · 새 폰 `x1RecoveryStep{run_id, step}`.
    required List<SafetyActionCall> actions,
  }) = _X1StepRow;

  factory X1StepRow.fromJson(Map<String, dynamic> json) =>
      _$X1StepRowFromJson(json);
}
// JSON 키: code · title · state_label · level · lines · block_code · actions

/// 이전 티켓 QR 카드(옛 폰 · 강등 뒤). 🔴 페이로드 칸 0 — QR 은 슬롯 위젯이 구현에서 받아 그린다(`PairingTicketCard` 꼴).
@freezed
abstract class X1TicketCard with _$X1TicketCard {
  const factory X1TicketCard({
    required String headline,

    /// QR 표시 자리 이름(`X1SlotIds.ticketQrDisplay`). null = 자리 부재.
    String? ticketSlotId,

    /// «09:15 까지 유효» — 엔진 절대 시각 글자(🔴 남은 초를 세지 않는다).
    String? expiresText,

    /// 백업 날 · 체인 8자 등 — 엔진.
    required List<String> lines,
  }) = _X1TicketCard;

  factory X1TicketCard.fromJson(Map<String, dynamic> json) =>
      _$X1TicketCardFromJson(json);
}
// JSON 키: headline · ticket_slot_id · expires_text · lines

/// 새 폰 복구(받기 · 비상 공용 · 06 X1-3~X1-5 · 08 그림 9-2).
///
/// 🔴 받기 = [scanSlotId] · [startAction] null · [reissue] 빈 목록 / 비상 = [startAction] `x1EmergencyStart{}` · [recoveryCodeSlotId] ·
///    [fencing] · [reissue] 6행.
/// 🔴 [lockedLabel] · [doneLabel] 가 non-null 이면 동작 0 · 슬롯 0. [restartLink] non-null ⇔ `X1_RECOVERY_FULL`(그때 동작 0).
@freezed
abstract class X1RecoveryVm with _$X1RecoveryVm {
  const factory X1RecoveryVm({
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1RecoveryResultCodes` ∪ `X1RestoreResultCodes` ∪ `BackupResultCodes` ∪ `X1OrderSealCodes` ∪
    ///    `X1FencingResultCodes` ∪ `X1ReissueResultCodes` ∪ `X1StartResultCodes` ∪ `X1GateReasonCodes` ∪ 공용.
    String? reasonCode,

    /// «계획 이전» · «비상 이전» — 엔진.
    required String kindLabel,

    /// 비상 = 엔진 완성 `x1EmergencyStart{}`(선언 결정 + 복구 코드 슬롯 → epoch+1 = 구현) · 받기 = null.
    SafetyActionCall? startAction,

    /// 복구 코드 입력 자리(`X1SlotIds.recoveryCode` · 비상 시작 전만).
    String? recoveryCodeSlotId,

    /// 펜싱 대기(비상만).
    X1FencingCard? fencing,

    /// 재발급 6행(`X1ReissueItemCodes.ordered` 차례 · 비상만) 또는 빈 목록.
    required List<X1ReissueRow> reissue,

    /// 티켓 QR 스캔 자리(`X1SlotIds.ticketQrScan` · 받기 시작 전만).
    String? scanSlotId,

    /// 복원 판정 카드.
    X1RestoreCard? restore,

    /// 복구 단계 5(`X1RecoveryStepCodes.ordered` 차례) 또는 빈 목록.
    required List<X1StepRow> steps,

    /// LIVE 재개 게이트(GAP_REBUILT 뒤).
    X1GateCard? gate,

    /// RECOVERY_FULL → `onboardingRestart`(잔고 승계 새 시작 · 엔진 완성).
    LinkAction? restartLink,

    /// 감시 창 글자 — 엔진.
    String? windowText,

    /// «정정 · 재발급은 되돌리지 않습니다» 류 — 엔진.
    String? noticeText,
    String? doneLabel,
    String? lockedLabel,
    required AsOf asOf,
  }) = _X1RecoveryVm;

  factory X1RecoveryVm.fromJson(Map<String, dynamic> json) =>
      _$X1RecoveryVmFromJson(json);
}
// JSON 키: headline · level · reason_code · kind_label · start_action · recovery_code_slot_id · fencing · reissue · scan_slot_id ·
//          restore · steps · gate · restart_link · window_text · notice_text · done_label · locked_label · as_of

/// 펜싱 대기 카드(비상 · 옛 리스 만료까지).
@freezed
abstract class X1FencingCard with _$X1FencingCard {
  const factory X1FencingCard({
    required String headline,
    required UiLevel level,

    /// 대기 끝 절대 시각 글자(«11-22 09:15 부터») — 엔진(🔴 카운트다운 0 · 마진 칸 0).
    String? endsAtText,

    /// 🔴 화면 미참조 — ∈ `X1FencingResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`.
    String? code,
    required List<String> lines,
  }) = _X1FencingCard;

  factory X1FencingCard.fromJson(Map<String, dynamic> json) =>
      _$X1FencingCardFromJson(json);
}
// JSON 키: headline · level · ends_at_text · code · lines

/// 재발급 체크리스트 한 행(비상).
@freezed
abstract class X1ReissueRow with _$X1ReissueRow {
  const factory X1ReissueRow({
    /// 🔴 화면 미참조 — ∈ `X1ReissueItemCodes`.
    required String code,

    /// 항목 이름 — 엔진(`ReissueItem.label`).
    required String label,

    /// «받음» · «남음» · «해당 없음» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 새 값 입력 자리(`X1SlotIds.reissueSecret` · 시크릿 항목만). null = 자리 부재.
    String? reissueSlotId,

    /// 엔진 완성 `x1ReissueRecord{run_id, item}` — 값 = 슬롯 ↔ 구현 · 지문만 엔진. null = 끝 · 해당 없음.
    SafetyActionCall? recordAction,
  }) = _X1ReissueRow;

  factory X1ReissueRow.fromJson(Map<String, dynamic> json) =>
      _$X1ReissueRowFromJson(json);
}
// JSON 키: code · label · state_label · level · reissue_slot_id · record_action

/// 복원 판정 카드(매니페스트 요약 · 거부 사유).
@freezed
abstract class X1RestoreCard with _$X1RestoreCard {
  const factory X1RestoreCard({
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1RestoreResultCodes` ∪ `BackupResultCodes`.
    String? code,

    /// 매니페스트 날 · 스키마 · 해시 판 · epoch + 판정 사유 — 엔진 문장(🔴 sha256 전체 · 기기 id 0).
    required List<String> lines,

    /// 체인 해시 8자 — 엔진이 자른다(`RestorePointRow.chainHashText` 선례).
    String? chainHashText,
  }) = _X1RestoreCard;

  factory X1RestoreCard.fromJson(Map<String, dynamic> json) =>
      _$X1RestoreCardFromJson(json);
}
// JSON 키: headline · level · code · lines · chain_hash_text

/// LIVE 재개 게이트 카드(`X1-5` · 녹/황/적 · 왜 막혔는지 + 지금 할 조치).
@freezed
abstract class X1GateCard with _$X1GateCard {
  const factory X1GateCard({
    required String stateLabel,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1GateStateCodes`.
    required String gateStateCode,

    /// 🔴 화면 미참조 — ∈ `X1GateReasonCodes`.
    String? code,

    /// 관찰 «n/m 거래일» — 엔진 글자(🔴 일수 칸 0).
    String? observeText,
    required String whyLine,
    String? actionLine,

    /// 확인 항목 — 엔진(문안 = 발주자 · 원천 = 미결 218 ⓗ).
    required List<String> checklistLines,
  }) = _X1GateCard;

  factory X1GateCard.fromJson(Map<String, dynamic> json) =>
      _$X1GateCardFromJson(json);
}
// JSON 키: state_label · level · gate_state_code · code · observe_text · why_line · action_line · checklist_lines
```

---

## `packages/domain_contracts/lib/src/dto/onboarding.dart`

```dart
// packages/domain_contracts/lib/src/dto/onboarding.dart
//
// 🆕 계약 v1.16(01 §25 · R15 선행 · 발주자 결정 2026-11-03 ①~④) — X3 온보딩 위저드(04 §9) **한 화면 VM 7종** + 부품 5종.
//
// 🔴 판정·게이트·순서·문구 = 전부 엔진(04 §9 머리 «게이트 판정은 전부 Claude»). 화면은 받은 차례 그대로 그리고 null = 부재.
// 🔴 asOf 칸이 없다(K6 ⓐ · K10) — 온보딩 화면 공통 상태 = 로딩·에러 둘(04 §2-3 예외 · 01 §8 미결 148).
//    모르는 id = 값(`missingLabel`) · 스트림 에러 = 읽기 실패.
// 🔴 링크 = 데이터(01 §4-4) — 문자열 칸 = `*DeepLink` · 글자 + 링크 = [LinkAction](같은 뜻 같은 이름 · K9).
// 🔴 🔒 자리 = 슬롯 이름(`OnboardingSlotIds`)만 싣는다 — 위젯은 조립 앱이 주입한다(K22 · 06 M4-11).
// 🔴 `OperatingModeView`(M9 `S05`)는 여기서 쓰지 않는다 — `current` 가 required 라 «아직 안 고름»을 표현하지 못한다(K12).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/mode.dart';
import '../enums/onboarding.dart';
import '../enums/ui.dart';
import 'common.dart';
import 'handover.dart';
import 'safety.dart';

part 'onboarding.freezed.dart';
part 'onboarding.g.dart';

/// `O-00` 첫 실행 갈래(04 §9-1 · K11). 🔴 운영 방식은 갈래가 아니다 — 넷째 갈래 0.
@freezed
abstract class OnboardingStartVm with _$OnboardingStartVm {
  const factory OnboardingStartVm({
    /// 첫 화면 머리 — 엔진 문장.
    required String headline,

    /// 계정 축 갈래(처음 · 다시) — 엔진 차례 그대로.
    required List<OnboardingTrackCard> tracks,

    /// 조회 전용 갈래 한 칸(🔵 청사진 §9-1b ⑦ 권고 선반영 · 되돌림 = 엔진이 null). null = 첫 화면에 내지 않는다.
    OnboardingTrackCard? viewerTrack,
  }) = _OnboardingStartVm;

  factory OnboardingStartVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStartVmFromJson(json);
}
// JSON 키: headline · tracks · viewer_track

/// `O-00` 갈래 카드 1장(K11).
@freezed
abstract class OnboardingTrackCard with _$OnboardingTrackCard {
  const factory OnboardingTrackCard({
    /// 엔진 표지 — 🔴 화면은 이 값으로 분기·글자·아이콘을 고르지 않는다.
    required OnboardingTrack track,

    /// «처음 시작하기» — 엔진.
    required String title,

    /// «약 60~90분» — 엔진(🔴 화면이 시간을 셈하지 않는다).
    required String estimatedText,

    /// 다음 화면(엔진 완성 · `aaq://onboarding/mode` 등). null = 탭 없음.
    String? deepLink,
  }) = _OnboardingTrackCard;

  factory OnboardingTrackCard.fromJson(Map<String, dynamic> json) =>
      _$OnboardingTrackCardFromJson(json);
}
// JSON 키: track · title · estimated_text · deep_link

/// `O-00b` 운영 방식 선택(04 §9-1b · K12). 🔴 기본값 없음 — [selected] null = 아직 안 고름.
@freezed
abstract class OnboardingModeChoiceVm with _$OnboardingModeChoiceVm {
  const factory OnboardingModeChoiceVm({
    required String headline,

    /// 카드 2장(엔진 차례 · 기존 [OperatingModeOption] — M9 `S05` 와 같은 타입). 🔴 크기·색·순서 우대 0.
    required List<OperatingModeOption> options,

    /// 고른 값(엔진이 `onboarding_choice` 에서 읽은 것). null = 아직 안 고름(진입 때 체크·포커스·«다음» 0).
    OperatingMode? selected,

    /// 하단 고정 고지 «투자 안내에서는 … 기록하지 않은 매매는 시스템이 알 수 없습니다.» — 엔진.
    required String recordGapNotice,

    /// 정직 고지 한 문단 — 엔진(🔴 기대치 숫자는 이 문장 안에만 · 화면 리터럴 0).
    required String honestyText,

    /// `O-01` 링크 — 엔진이 **고른 뒤에만** 준다(`aaq://onboarding/steps`). null = «다음» 부재.
    String? nextDeepLink,

    /// `committed_at` 뒤 읽기 전용 문장. non-null = 카드 탭 부재(이후 변경 = 🔒 `M5-11`).
    String? lockedLabel,
  }) = _OnboardingModeChoiceVm;

  factory OnboardingModeChoiceVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingModeChoiceVmFromJson(json);
}
// JSON 키: headline · options · selected · record_gap_notice · honesty_text · next_deep_link · locked_label

/// `O-01` 단계 목록(04 §9-2 · K17). 🔴 갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른 목록이다.
@freezed
abstract class OnboardingStepsVm with _$OnboardingStepsVm {
  const factory OnboardingStepsVm({
    /// «1/12 완료» — 엔진(🔴 비율 계산 0).
    required String progressText,

    /// 단계 행(받은 차례 그대로).
    required List<OnboardingStep> rows,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,

    /// `O-04` 링크(`aaq://onboarding/finish`) — 엔진이 필수 통과·게이트를 판정한 뒤에만. null = «다음» 부재.
    String? finishDeepLink,
  }) = _OnboardingStepsVm;

  factory OnboardingStepsVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepsVmFromJson(json);
}
// JSON 키: progress_text · rows · empty_label · finish_deep_link

/// `O-02` 단계 상세 + `O-03` 검증(04 §9-3·§9-4 · K18). [step] non-null XOR [missingLabel] non-null.
@freezed
abstract class OnboardingStepDetailVm with _$OnboardingStepDetailVm {
  const factory OnboardingStepDetailVm({
    /// 그 단계(목록의 같은 `stepId` 객체와 같은 값).
    OnboardingStep? step,

    /// 모르는·지난 id = 엔진 문장(🔴 스트림 에러가 아니라 값이다).
    String? missingLabel,

    /// «어디서 받나» — 엔진 글자(🔴 결정 ② · 외부 열기 = 플랫폼 · 화면 링크 0).
    String? whereText,

    /// «어떻게 검증하나» — 엔진 글자.
    String? howText,

    /// 검증 동작(엔진이 id·args 완성). null = 버튼 부재.
    OnboardingAction? verify,

    /// 시크릿 자리 이름(`OnboardingSlotIds` · `SecretField` = 조립 앱 슬롯). null = 자리 없음.
    String? secretSlotId,
  }) = _OnboardingStepDetailVm;

  factory OnboardingStepDetailVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepDetailVmFromJson(json);
}
// JSON 키: step · missing_label · where_text · how_text · verify · secret_slot_id

/// 엔진이 완성한 `SettingsActions.run` 호출 1개(K19 · 검증 · DRY_RUN 공용).
/// 🔴 화면은 [id]·[args] 를 **그대로** 넘긴다(키·값을 짓지 않는다 · 화이트리스트 = `settings_actions.dart`).
@freezed
abstract class OnboardingAction with _$OnboardingAction {
  const factory OnboardingAction({
    required SettingsActionId id,
    required Map<String, String> args,

    /// 버튼 글자 «검증 실행» · «모의 운영 시작» — 엔진.
    required String label,
  }) = _OnboardingAction;

  factory OnboardingAction.fromJson(Map<String, dynamic> json) =>
      _$OnboardingActionFromJson(json);
}
// JSON 키: id · args · label

/// `O-04` 마무리(04 §9-5 · K23). 🔴 6단계 순서 고정 · 건너뛰기 0 · 열림 = 엔진 · 모드 선택 컨트롤 0.
@freezed
abstract class OnboardingFinishVm with _$OnboardingFinishVm {
  const factory OnboardingFinishVm({
    required String headline,

    /// 6단계(엔진 차례 · 🔴 화면이 순번으로 칸 뜻을 고르지 않는다 — 칸은 단계 객체가 싣는다).
    required List<OnboardingFinishStage> stages,

    /// DRY_RUN 시작 뒤 문장(모의투자 진입). null = 아직.
    String? doneLabel,

    /// 완료 체크(X3 배관 점검 — 판정 = 서버 · DRY_RUN 시작 전 = 빈 목록).
    required List<OnboardingFinishCheck> checks,
  }) = _OnboardingFinishVm;

  factory OnboardingFinishVm.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishVmFromJson(json);
}
// JSON 키: headline · stages · done_label · checks

/// `O-04` 한 단계(K23).
@freezed
abstract class OnboardingFinishStage with _$OnboardingFinishStage {
  const factory OnboardingFinishStage({
    required String title,
    required StepState state,

    /// 열림·잠금(엔진 판정 · `unknown` = 진행 차단). null = 게이트 없음.
    GateBadge? gate,

    /// 엔진 글자 줄(배분·금 상한(config)·`config_hash` · «통과 n/전체 n» · 복구 카드 4칸 · 램프 L1·종착 조합).
    required List<String> lines,

    /// ① 정직한 기대치 한 줄(04 §9-5 ⚠️ `expectationLine?` = 이 칸) — 값이 없으면 null(줄 0).
    String? expectationLine,

    /// 🔒 자리 이름(②~⑤ · 열린 단계만 · 닫힌·끝난 단계 = null).
    String? slotId,

    /// ⑥ 시작 상태 선언(두 갈래 · 결정 ③ · 선언 뒤 = null).
    LinkAction? link,

    /// ⑥ DRY_RUN 시작(앞 단계 미통과·선언 전 = null — 엔진 판정).
    OnboardingAction? action,
  }) = _OnboardingFinishStage;

  factory OnboardingFinishStage.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishStageFromJson(json);
}
// JSON 키: title · state · gate · lines · expectation_line · slot_id · link · action

/// 완료 체크 한 줄(04 §9-5 «체크리스트로 보이되 판정은 전부 서버» · 그림 20 `CHK`).
@freezed
abstract class OnboardingFinishCheck with _$OnboardingFinishCheck {
  const factory OnboardingFinishCheck({
    required String label,
    required StepState state,
  }) = _OnboardingFinishCheck;

  factory OnboardingFinishCheck.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFinishCheckFromJson(json);
}
// JSON 키: label · state

/// `R-01` 기존 계정에서 다시 시작(04 §9-6 · K26). 🔴 3)에서 역할 끝 — 분기 = 엔진이 고른 링크 · 갭 일수 판정 0.
@freezed
abstract class RestartVm with _$RestartVm {
  const factory RestartVm({
    required String headline,

    /// ① 복구 카드 로그인 자리(이메일 + 비밀번호 = 플랫폼 · 🆕 v1.29 E11k T8 — ~~매직링크/OTP~~ 정정). null = 이미 로그인.
    String? loginSlotId,

    /// ② 기기 원장 요약(구 폰 라벨 · 마지막 접속 · 리스 잔여 — 엔진 글자). null = 로그인 전(원장을 아직 못 읽음).
    List<String>? ledgerLines,

    /// 리스·기기 원장 3상(`unknown` = 진행 차단 · 엔진이 그때 [branches] 를 비운다).
    GateBadge? leaseGate,

    /// ③ 분기(엔진이 고른 목록 · 모름·로그인 전 = 빈 목록).
    required List<LinkAction> branches,

    /// 킬스위치·차단 플래그 승계 고지(🔴 «초기화» 선택지 0).
    String? inheritNotice,
  }) = _RestartVm;

  factory RestartVm.fromJson(Map<String, dynamic> json) =>
      _$RestartVmFromJson(json);
}
// JSON 키: headline · login_slot_id · ledger_lines · lease_gate · branches · inherit_notice

/// `V-01` 조회 전용 QR 페어링(04 §9-7 · K27). 🔴 스캔·클레임 = 플랫폼 · 수동 입력 대체 경로 0.
@freezed
abstract class PairingVm with _$PairingVm {
  const factory PairingVm({
    required String headline,

    /// 스캐너 자리(플랫폼 카메라 · 대기·재시도 때). null = 자리 없음(성공 뒤).
    String? scannerSlotId,

    /// 클레임 결과. null = 아직 스캔 전.
    PairingResult? result,
  }) = _PairingVm;

  factory PairingVm.fromJson(Map<String, dynamic> json) =>
      _$PairingVmFromJson(json);
}
// JSON 키: headline · scanner_slot_id · result

/// `V-01` 클레임 결과(판정 = 엔진·플랫폼 · 폐기된 토큰 = 즉시 차단).
@freezed
abstract class PairingResult with _$PairingResult {
  const factory PairingResult({
    required UiLevel level,
    required String headline,

    /// 원문 코드(`OnboardingResultCodes` 등). `OK` 밖이면 non-null.
    String? reasonCode,

    /// 다음 화면(`OK` 일 때만 · 엔진 완성). null = 부재.
    LinkAction? nextLink,
  }) = _PairingResult;

  factory PairingResult.fromJson(Map<String, dynamic> json) =>
      _$PairingResultFromJson(json);
}
// JSON 키: level · headline · reason_code · next_link
```

---

## `packages/domain_contracts/lib/src/dto/operations.dart`

```dart
// 01 §4-1 · 05 §3 S05 — M9 운용 관리 뷰모델(🆕 계약 v1.19 · 01 §28 · R6c 선행 · 발주자 위임 2026-11-14 · K2~K20).
//
// 🔴 전부 엔진(폰 로컬 VM 산출)이 완성한다 — 화면은 받은 차례·글자 그대로 그린다(정렬·세기·묶기·분기 0).
// 🔴 두 축(`mode` = RunMode · `operatingMode` = OperatingMode)은 **각각** 그린다 — 합성 라벨 0 · 토글 0(K4).
// 🔴 버튼은 엔진이 `id`·`args` 까지 완성한 [SettingsActionCall] 뿐이다(빈 목록·null = 부재 · 화면이 짓지 않는다 ·
//    화이트리스트 = `settings_actions.dart` 머리). 결과는 `ActionResult` — `handoffRoute` 가 있으면 그리로 넘기고 끝.
// 🔴 «DRY_RUN» 글자 0 · 손익 성격 글자 0(G-63 · 결정 8) · 킬스위치 칸 0(엔진 중지 ≠ 킬스위치 — 05:449).
// 🔴 `scope`·`HandoverPlan`·`contribution` 칸은 없다(K3 — P0S 범위 = 늘 null · 🔒 M5-11 · 월 납입 = 별도 화면).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'handover.dart'; // OperatingModeView
import 'onboarding.dart'; // SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다 — ops.dart:14 선례)
import 'ops.dart'; // LiveDryRunObservationVm
import 'settings.dart'; // EngineStatusChip · SettingsActionCall

part 'operations.freezed.dart';
part 'operations.g.dart';

/// 🆕 v1.19(01 §28 · K3) — 운용 관리(05 `S05`). 칸 차례 = 화면 위 → 아래.
@freezed
abstract class OperationsVm with _$OperationsVm {
  const factory OperationsVm({
    /// 엔진 상태 칩 — `S01` 과 **같은 값**(생산 하나 · v1.18 K-o) · `promotionLabel` = 관찰 중일 때만.
    required EngineStatusChip statusChip,

    /// 모드 카드(runMode 축).
    required RunModeCard mode,

    /// 운영 방식 카드(operatingMode 축 · 🆕 v1.19 `switchActions`).
    required OperatingModeView operatingMode,

    /// 모의 체험 카드 — SIM 계열일 때만 non-null(엔진 의무 · live = null).
    SimTrialCard? trial,
    required RampBoard ramp,

    /// 잡 행 — 행 수·차례 = 엔진(잡 이름 상수 0).
    required List<JobRow> jobs,
    required EngineControl control,

    /// 엔진 버전 전환 게이트 — 대기 버전이 있을 때만 non-null.
    UpdateGateCard? updateGate,

    /// 지난 전환 요청이 M5 에서 나중에 미통과로 끝난 사유 한 줄(두 축 공용 · null = 줄 없음 · K18).
    String? lastRequestNotice,

    /// 운영 등급 생체 축소 글자(non-null = 보기만 · 🔴 엔진 의무 = 동작 칸 5 전부 비움 — K19).
    String? lockedLabel,
    required AsOf asOf,
  }) = _OperationsVm;

  factory OperationsVm.fromJson(Map<String, dynamic> json) =>
      _$OperationsVmFromJson(json);
}
// JSON 키: status_chip · mode · operating_mode · trial · ramp · jobs · control · update_gate · last_request_notice ·
//          locked_label · as_of

/// 🆕 v1.19(K5 · K6) — 모드 카드(runMode 축 칩 1).
@freezed
abstract class RunModeCard with _$RunModeCard {
  const factory RunModeCard({
    /// «모의 · 내부 가상 체결» · «실전 · 관찰 중» — 엔진(🔴 «DRY_RUN» 0 · 세 값 분기 0).
    required String label,
    required UiLevel level,

    /// hold 한 줄(`LIVE_AWAITING_KEYS` 등 · 🔴 «모의» 글자 0). null = 줄 없음.
    String? holdLabel,

    /// `live × autoTrade × dryRun` 관찰 중일 때만(엔진 #159 그대로). 🔴 화면은 `progressText`·`stateLabel` 만.
    LiveDryRunObservationVm? observation,

    /// 승격 버튼 — 관찰 중 ∧ 승격 가능일 때만(엔진 완성 `runtimeLivePromotion` · args `{}` · K6). null = 부재.
    SettingsActionCall? promotionAction,

    /// 전환 부작용 고지(«기존 계획이 무효화되고 …») — `switchActions` 가 비지 않을 때만.
    String? switchNoticeText,

    /// 전환 요청 버튼(엔진 완성 `runtimeModeSwitchRequest` · args `{run_mode}`). 빈 = 부재.
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> switchActions,
  }) = _RunModeCard;

  factory RunModeCard.fromJson(Map<String, dynamic> json) =>
      _$RunModeCardFromJson(json);
}
// JSON 키: label · level · hold_label · observation · promotion_action · switch_notice_text · switch_actions

/// 🆕 v1.19(K9 · K10 · 엔진 E15d2 `sim_trial.dart`) — 모의 체험 카드. 🔴 손익 0 · 화면은 개수·비율·잔여를 세지 않는다.
@freezed
abstract class SimTrialCard with _$SimTrialCard {
  const factory SimTrialCard({
    /// 엔진 머리말(`SimTrialReport.headline`).
    required String headline,

    /// 요약 카운터 문장(`SimTrialCounters.text` — «체험 N일 · 배치 n회 · 리밸런싱 r회 · 경보 k건 · 개입 m회»).
    required String summaryText,

    /// 체험 완료 기준 줄 — 차례·항목 수 = 엔진(정본 04 §9-5 · 1개 이상).
    required List<SimTrialCheck> checks,
  }) = _SimTrialCard;

  factory SimTrialCard.fromJson(Map<String, dynamic> json) =>
      _$SimTrialCardFromJson(json);
}
// JSON 키: headline · summary_text · checks

/// 🆕 v1.19(K9) — 체험 완료 기준 1줄. 🔴 `GateState` 아님 · `OnboardingFinishCheck`(X3 배관 점검) 아님.
/// 짝(엔진 의무 · C-53 ⑨): PASSED·AUTO_PASSED ⇒ ok · OPEN ⇒ watch · OPEN_WARN ⇒ info(🔴 act·blocked 0).
@freezed
abstract class SimTrialCheck with _$SimTrialCheck {
  const factory SimTrialCheck({
    /// `SimTrialItemCodes` 값 — 🔴 화면 미참조(Key = 순번).
    required String itemCode,

    /// 항목 이름(엔진 `SimTrialItem.label`).
    required String label,

    /// 진척·사유 문장(엔진 `SimTrialItemResult.detail`).
    required String detailText,

    /// `SimTrialItemStateCodes` 값 — 🔴 화면 미참조(엔진 4값 와이어).
    required String itemState,

    /// «통과» · «자동 통과» · «아직» · «아직 — 경고 후 진행» — 엔진.
    required String stateLabel,

    /// 🔴 아이콘·색의 유일한 근거.
    required UiLevel level,
  }) = _SimTrialCheck;

  factory SimTrialCheck.fromJson(Map<String, dynamic> json) =>
      _$SimTrialCheckFromJson(json);
}
// JSON 키: item_code · label · detail_text · item_state · state_label · level

/// 🆕 v1.19(K11) — 운영 램프 보드(OpsRamp). 🔴 레벨 열거 미사용(`levelLabel` 글자만) · 성과 조건 0.
@freezed
abstract class RampBoard with _$RampBoard {
  const factory RampBoard({
    /// «L1 · 5% · 최저 단계» — 엔진(발행 집합 L1~L5).
    required String levelLabel,
    required UiLevel level,

    /// 승급 조건 현황(받은 차례). 빈 ⇔ [emptyLabel] non-null.
    @Default(<RampCondition>[]) List<RampCondition> conditions,

    /// 조건 줄이 없는 까닭(«모의 계좌에서는 승급 조건을 세지 않습니다 …»).
    String? emptyLabel,

    /// DST 주간 1단계 하향 표식 — 🔴 주문 차단이 아니다(non-null ⇒ [level] ∉ {act, blocked}).
    String? dstNoticeText,
  }) = _RampBoard;

  factory RampBoard.fromJson(Map<String, dynamic> json) =>
      _$RampBoardFromJson(json);
}
// JSON 키: level_label · level · conditions · empty_label · dst_notice_text

/// 🆕 v1.19(K11) — 승급 조건 1줄(03 §9-3 «배관» 항목). 🔴 [level] ∈ {ok, info, watch}.
@freezed
abstract class RampCondition with _$RampCondition {
  const factory RampCondition({
    required String label,

    /// «충족» · «집계 중 — 기록 2건» — 엔진(🔴 화면이 n/m 을 조립하지 않는다).
    required String progressText,
    required UiLevel level,
  }) = _RampCondition;

  factory RampCondition.fromJson(Map<String, dynamic> json) =>
      _$RampConditionFromJson(json);
}
// JSON 키: label · progress_text · level

/// 🆕 v1.19(K12) — 잡 1행(성공 · 지연 · 실패 3분법 + 휴장 · 아직).
/// 짝(엔진 의무 · C-53 ⑩): SUCCESS ⇒ ok · LATE ⇒ watch · HOLIDAY ⇒ info · NONE ⇒ info · FAILED ⇒ act·blocked.
@freezed
abstract class JobRow with _$JobRow {
  const factory JobRow({
    /// «국내 주문» — 엔진(🔴 잡 이름 상수 0).
    required String label,

    /// «평일 09:10 · 유예 1시간» — 엔진.
    required String scheduleText,

    /// «오늘 10:31 끝남» — 엔진.
    required String lastRunText,

    /// `SUCCESS`·`LATE`·`FAILED`·`HOLIDAY`(엔진 `job_run.status`) · `NONE`(아직 회차 없음) — 🔴 화면 미참조.
    required String statusCode,

    /// «지연 — 성공» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 한 줄 상세(«유예를 21분 넘겨 끝났습니다 …»). null = 줄 없음.
    String? detailLine,
  }) = _JobRow;

  factory JobRow.fromJson(Map<String, dynamic> json) => _$JobRowFromJson(json);
}
// JSON 키: label · schedule_text · last_run_text · status_code · state_label · level · detail_line

/// 🆕 v1.19(K13) — 엔진 시작·중지. 🔴 킬스위치가 아니다(칸 0 · 다른 색·자리).
/// 잠김 밖 = [startAction] non-null xor [stopActions] 비지 않음 · [stopActions] 비지 않음 ⇔ [stopPromptText] non-null.
@freezed
abstract class EngineControl with _$EngineControl {
  const factory EngineControl({
    /// «돌고 있음 — 다음 잡: …» · «멈춤 — … 계획 점검으로 멈췄습니다» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 엔진 완성 `runtimeEngineStart`(args `{}`) — 멈춰 있을 때만.
    SettingsActionCall? startAction,

    /// 사유 고르기 머리말 — [stopActions] 가 비지 않을 때만.
    String? stopPromptText,

    /// 사유마다 1 — 엔진 완성 `runtimeEngineStop`(args `{reason_code}` 서로 다름 · 라벨 = 사유 글자).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> stopActions,
  }) = _EngineControl;

  factory EngineControl.fromJson(Map<String, dynamic> json) =>
      _$EngineControlFromJson(json);
}
// JSON 키: state_label · level · start_action · stop_prompt_text · stop_actions

/// 🆕 v1.19(K17) — 엔진 버전 전환 게이트. 🔴 «지금 업데이트» 강행 칸 없음(구조로 막는다).
@freezed
abstract class UpdateGateCard with _$UpdateGateCard {
  const factory UpdateGateCard({
    /// «새 버전 대기 — 비거래 시간대에 바꿉니다» — 엔진.
    required String stateLabel,
    required String bodyText,
    required UiLevel level,
  }) = _UpdateGateCard;

  factory UpdateGateCard.fromJson(Map<String, dynamic> json) =>
      _$UpdateGateCardFromJson(json);
}
// JSON 키: state_label · body_text · level
```

---

## `packages/domain_contracts/lib/src/dto/ops.dart`

```dart
// 01 §2-6 · §4-1 — M8·M9 운영 상태 뷰모델(m2-8 G-1~G-4 · G-7~G-10 · J-2).
//
// 🔴 **읽기 전용**이다. 조작은 §4-3 `SettingsActions` 이며, 뷰어 빌드에서는 그
//    구현체가 주입되지 않으므로 컨트롤은 «비활성»이 아니라 **부재**다.
// 🔴 홈 블록 5·7 의 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록
//    길이로 만들지 않는다(01 §4-1 · G-29). int·double 산술이라 C-4 가 잡지 못한다.
// 🔴 🆕 v1.24 — 이 파일에 `actionAvailable` 칸 0(v1.18 `ConnectionRow` · v1.24 `BackupVm` 삭제) · 버튼 유무 =
//    `SettingsActionCall?`/`LinkAction?` null = **부재**(«비활성» 0).
// 🆕 v1.20(01 §29) — `S06` `DeviceAccessVm`·`DeviceRow` 추가형 · 🆕 `PairingTicketCard`.
// 🆕 v1.24(01 §33 · K110 · K113 · K118) — `S09` `BackupVm` 교체(소비자 0) + `RestorePointRow` · `S10` 감싸개 `DiagnosticsScreenVm` +
//    `SelfTestCard`(`DiagnosticsVm` 무변경 — H-01 과 같은 값) · `S12` 전용 목차 `AnnualReviewIndexVm`(세후·수치 칸 0 — `AnnualReviewVm` 무변경).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart'; // 🆕 v1.13 — DiagnosticCell.level
import '../primitives/as_of.dart';
import 'common.dart';
import 'onboarding.dart'; // 🆕 v1.18 — SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다)
import 'settings.dart'; // 🆕 v1.18 — SettingsActionCall

part 'ops.freezed.dart';
part 'ops.g.dart';

/// m2-8 G-1 — 셸(`ui_shell`)이 주입하는 모드 접두와 상단 띠.
/// 🔴 **띠는 하나이고 칩이 2개**다(2줄로 만들지 않는다 · C-18).
/// 🔴 접두 순서는 «모의투자 · 투자 안내 · 제목» 이며 화면이 접두를 직접 쓰지
///    않는다(01 §9-3 · C-17 — 한 화면만 빠뜨려도 그 화면이 실전처럼 보인다).
@freezed
abstract class ShellVm with _$ShellVm {
  const factory ShellVm({
    required List<ShellChip> bandChips,

    /// null 이면 접두를 붙이지 않는다(`live` 는 접두가 없다).
    String? runModePrefix,

    /// null 이면 접두를 붙이지 않는다(`autoTrade` 는 접두가 없다).
    String? operatingModePrefix,

    /// 🔴 색의 근거는 이 코드다 — 값의 부호로 고르지 않는다.
    String? bandToneCode,
  }) = _ShellVm;

  factory ShellVm.fromJson(Map<String, dynamic> json) =>
      _$ShellVmFromJson(json);
}

/// ⚠️ **M2-8 미확정** — G-1 이 `List<ShellChip>` 이라는 **이름만** 확정했고 필드
/// 축은 문서에 없다. 아래는 `GateBadge`(§2-1)·`SettingsCard`(G-5)와 같은 모양으로
/// 둔 **임시 최소 축**이다. 🔴 문구는 엔진이 주고 화면이 조합하지 않는다.
@freezed
abstract class ShellChip with _$ShellChip {
  const factory ShellChip({
    required String code,
    required String label,
    String? toneCode,
  }) = _ShellChip;

  factory ShellChip.fromJson(Map<String, dynamic> json) =>
      _$ShellChipFromJson(json);
}

/// m2-8 G-2 — 운영 리듬 1행(04 §4-7 `H-02`).
/// 🔴 `dDayText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
/// 🆕 v1.12(01 §21 · K29 · K30) — 전체 목록 = `OpsSummaryRepository.watchRhythm()` · 행 탭 = [route](null = 반응 없음) ·
///    `H-02` «조치» 열 = 없음(2026-10-22 삭제 — 할 일은 [title] 이 말한다).
///    필드 5개가 전부다 — 등급·선행·조치 칸 0(04 §4-7 · 2026-10-22 결정).
@freezed
abstract class OpsRhythmRow with _$OpsRhythmRow {
  const factory OpsRhythmRow({
    required String code,
    required String title,
    required String whenText,
    String? dDayText,
    String? route,
  }) = _OpsRhythmRow;

  factory OpsRhythmRow.fromJson(Map<String, dynamic> json) =>
      _$OpsRhythmRowFromJson(json);
}

/// m2-8 G-3 — 워치독 체크 1행(04 §7 `W-01`). 🆕 v1.15(01 §24 · K4 · K16 · K17) — `slug` 삭제 → [checkId] · [level].
///
/// 🔴 목록의 길이·이름·차례는 **서버가 준다** — 화면이 상수 배열을 갖지 않는다.
/// 🔴 healthchecks 슬러그(2축 합성 `{sim|live}-{auto|advisory}-{체크명}` · §9-5 ⑦ · C20)·ping URL·키는 이 DTO 에
///    **오지 않는다**(엔진·워치독 설정 몫 · 04 §7 «뷰모델에 그 필드가 없어야 정상» · C-49 ⑪).
@freezed
abstract class WatchdogCheck with _$WatchdogCheck {
  const factory WatchdogCheck({
    /// 🆕 v1.15(K17) — 엔진이 짓는 불투명 id(보드 안 유일). 🔴 슬러그·URL 에서 파생하지 않는다 ·
    /// 화면은 그리지도 · Key 로도 · 비교로도 쓰지 않는다(Key = 순번).
    required String checkId,
    required String label,

    /// 화면 미참조(사전 아님 — 엔진 몫).
    required String stateCode,
    required String stateLabel,

    /// 🆕 v1.15(K16) — 상태 모양의 유일한 근거(성공·휴장 성공 핑 = ok · 지연 = watch · 실패 = blocked ·
    /// 일시정지 = info). 🔴 화면은 [stateCode] 로 색·아이콘을 고르지 않는다(v1.13 `DiagnosticCell.level` 선례).
    required UiLevel level,
    required String lastPingText,
    String? graceText,
    String? route,
  }) = _WatchdogCheck;

  factory WatchdogCheck.fromJson(Map<String, dynamic> json) =>
      _$WatchdogCheckFromJson(json);
}

/// 🆕 v1.15(01 §24 · K3 · K15 · 발주자 결정 ②(b)) — `W-01` 워치독 보드 한 화면
/// (창구 [OpsStatusRepository.watchWatchdog] 의 반환 · 구 `ListResult<WatchdogCheck>`).
@freezed
abstract class WatchdogBoardVm with _$WatchdogBoardVm {
  const factory WatchdogBoardVm({
    /// 서버가 준 목록 그대로(개수·이름·차례 = 엔진).
    required List<WatchdogCheck> rows,
    required AsOf asOf,

    /// 행 0 일 때만 non-null(엔진 문장). 행이 있으면 null.
    String? emptyLabel,

    /// 휴장일 고지(구 봉투 형제 키 `holiday_notice`) — 휴장일만 non-null.
    String? holidayNotice,

    /// 하단 한계 고지(healthchecks.io 자체 장애 계열 · 04 §7 «한계·이력»).
    /// 엔진 의무 = 늘 싣는다(행 0 보드 포함). null = 부재.
    String? limitNotice,

    /// 머리 «마지막 수신 17:58»(엔진 글자). 받은 적이 없으면 null.
    String? lastReceivedText,
  }) = _WatchdogBoardVm;

  factory WatchdogBoardVm.fromJson(Map<String, dynamic> json) =>
      _$WatchdogBoardVmFromJson(json);
}

/// 01 §4-1 · m2-8 G-4 — 홈 블록 5·7 의 오늘 요약.
/// 🔴 **전부 엔진 완성 문자열이며 수치 필드가 0건**이다.
@freezed
abstract class OpsDailySummary with _$OpsDailySummary {
  const factory OpsDailySummary({
    required AsOf asOf,
    required String todayOrdersText,
    required String todayErrorsText,
    required String signalMatchText,
    required String streakText,
    required String discretionBudgetText,
    required String nextRebalanceDDayText,

    /// 🔴 `watchRhythm()` 목록의 **앞 ≤3 과 같은 값**이다(엔진 의무 · 🆕 v1.12 · C-47 ⑤).
    required List<OpsRhythmRow> upcoming,

    /// 🆕 v1.12(01 §21 · K44) — `H-01` 블록 2 «X2 한 줄»(엔진 한 문장 · → `aaq://x2/resume-report`). null = 블록 2 부재
    /// (평시 문장을 엔진이 늘 싣는지 = 01 §8 미결 122).
    LinkAction? resumeLine,
  }) = _OpsDailySummary;

  factory OpsDailySummary.fromJson(Map<String, dynamic> json) =>
      _$OpsDailySummaryFromJson(json);
}

/// m2-8 G-7 — 연결 관리(05 `S07`). 🆕 v1.18(01 §27 · K-r · K-t) — [lockedLabel] 추가.
/// 🔴 행 수·차례 = 엔진(«5장 고정» 아님 · `calendarEnabled == false` 면 캘린더 행 0).
@freezed
abstract class ConnectionsVm with _$ConnectionsVm {
  const factory ConnectionsVm({
    required List<ConnectionRow> rows,
    required AsOf asOf,

    /// 🆕 v1.18 — 운영 등급 생체 축소 글자(non-null = 보기만). 🔴 엔진 의무 = 이때 모든 행 `actions` 빈 ·
    /// `selectAction` 전부 null — 화면은 이 칸으로 컨트롤을 거르지 않는다(받은 대로 + 머리 글자 한 줄).
    String? lockedLabel,
  }) = _ConnectionsVm;

  factory ConnectionsVm.fromJson(Map<String, dynamic> json) =>
      _$ConnectionsVmFromJson(json);
}
// JSON 키: rows · as_of · locked_label

/// m2-8 G-7 — 연결 1행. 🆕 v1.18(K-q · K-r · K-s) — `actionAvailable` 삭제 · [detailLine] · [level] · [actions] · [channelPicker].
/// 🔴 토큰·키·전체 URL 은 어떤 칸에도 오지 않는다(PAT = 만료일만 · C-14).
@freezed
abstract class ConnectionRow with _$ConnectionRow {
  const factory ConnectionRow({
    /// `ConnectionTargetCodes` 값 — 🔴 화면 미참조(Key = 순번 · 행 찾기 0).
    required String target,
    required String label,

    /// 🔴 화면 미참조(색 근거 아님 — [level]). 사전 밖 상태 축(C-5 `_fieldsOutsideDictionary`).
    required String statusCode,
    required String statusLabel,
    required String lastOkText,

    /// 🆕 v1.18 — 한 줄 상세(부분 동기 «9개 표 중 1개 지연 — 보유현황» · GitHub 커밋 줄). null = 줄 없음.
    String? detailLine,

    /// 🆕 v1.18 — 상태 점의 유일한 근거(짝 규칙 = 01 §27 K-r · C-52 ⑤).
    required UiLevel level,

    /// 🆕 v1.18 — 엔진이 완성한 호출(«연결 테스트» · «지금 동기화» · «시험 발송»). 빈 = 버튼 부재(뷰어는 화면이 그리지 않는다).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> actions,

    /// 상세 화면 링크(`settingsCalendar` · `opsWatchdog` · `settingsCredentials`). null = 탭 부재.
    String? route,

    /// 🆕 v1.18 — 알림 채널 행에만 non-null(엔진 의무 · 화면은 `target` 으로 행을 찾지 않는다).
    NotifyChannelCard? channelPicker,
  }) = _ConnectionRow;

  factory ConnectionRow.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRowFromJson(json);
}
// JSON 키: target · label · status_code · status_label · last_ok_text · detail_line · level · actions · route · channel_picker

/// 🆕 v1.18(01 §27 · K-s · 01 §8 미결 140) — `S07` 알림 채널 선택 블록(텔레그램 / 카카오톡).
@freezed
abstract class NotifyChannelCard with _$NotifyChannelCard {
  const factory NotifyChannelCard({
    /// «받을 채널» — 엔진.
    required String label,

    /// 받은 차례 · `selected` 정확히 1(엔진 의무).
    required List<NotifyChannelOption> options,

    /// 능력 차이 고지문 — 엔진(늘 · 04 §5-5 와 같은 글자 원천).
    required String capabilityNotice,

    /// 카카오 리프레시·만료 임박 배지 — 엔진. null = 배지 부재.
    String? tokenBadgeText,

    /// «생존 신호 경보는 따로 텔레그램이나 이메일로» — 엔진(늘 · 🔴 «중복»으로 숨기지 않는다).
    required String watchdogChannelLine,
  }) = _NotifyChannelCard;

  factory NotifyChannelCard.fromJson(Map<String, dynamic> json) =>
      _$NotifyChannelCardFromJson(json);
}
// JSON 키: label · options · capability_notice · token_badge_text · watchdog_channel_line

/// 🆕 v1.18 — 채널 선택지 1개. 🔴 선택된 옵션 = [selectAction] null · 기본 선택을 화면이 정하지 않는다.
@freezed
abstract class NotifyChannelOption with _$NotifyChannelOption {
  const factory NotifyChannelOption({
    /// `NotifyChannelCodes` 값 — 🔴 화면 미참조.
    required String code,
    required String label,
    required bool selected,

    /// 엔진이 완성한 `notifyChannelSelect` 호출(`{channel}`). null = 그 선택지로 바꾸는 컨트롤 부재.
    SettingsActionCall? selectAction,
  }) = _NotifyChannelOption;

  factory NotifyChannelOption.fromJson(Map<String, dynamic> json) =>
      _$NotifyChannelOptionFromJson(json);
}
// JSON 키: code · label · selected · select_action

/// m2-8 G-8 · 🆕 v1.20 추가형(01 §29 · K14~K16 · K18 · K35) — 기기·접근 관리(05 `S06` · 폰 전용 · 운영 등급). 🔴 **리스는 읽기 전용**이다.
/// 🔴 이 폰(operator)·조회 전용 기기(viewer)는 **한 목록**([devices] · 차례 = 엔진 · 역할 = [DeviceRow.roleLabel] 글자).
/// 🔴 QR 은 결과가 아니라 이 VM 의 [pairing] 으로 온다(`ActionResult` 페이로드 칸 0 · 그리기 = 슬롯) · 이전·강등·비상 = [migrationLink] 하나.
@freezed
abstract class DeviceAccessVm with _$DeviceAccessVm {
  const factory DeviceAccessVm({
    required List<DeviceRow> devices,
    required String leaseHolderLabel,
    required String leaseStateLabel,
    required AsOf asOf,

    /// 🔴 신뢰 시각(Supabase 서버 시각) 기반 엔진 문자열 — 폰 시계로 남은 시간을
    ///    계산하지 않는다.
    String? leaseEtaText,

    /// 🆕 v1.20 — 리스 카드 색의 유일한 근거(짝 = 엔진 · 유효 ⇒ ok · 늦음 ⇒ watch/act · 무효·대기 ⇒ blocked).
    required UiLevel leaseLevel,

    /// 🆕 v1.20 — «세대 3» 류 epoch 글자(Supabase `operator_lease.epoch` · E11k 전 null).
    String? leaseEpochText,

    /// 🆕 v1.20 — X1 기기 이전·강등·비상 복구 진입(`AppRoutes.x1Migration` · 🔒 X1 · 리스 편집 칸 0). null = 링크 부재(잠김 포함).
    LinkAction? migrationLink,

    /// 🆕 v1.20 — viewer QR 페어링 티켓 카드(발급 쪽 · 🔴 X1 이전 QR 아님 — K16). null = 카드 부재.
    PairingTicketCard? pairing,

    /// 🆕 v1.20 — 조회 전용 기기가 0대일 때만 한 줄(«연결된 조회 전용 기기가 없습니다.» · K29). null = 줄 없음.
    String? emptyLabel,

    /// 🆕 v1.20 — 운영 등급 생체 축소(non-null = 보기만). 🔴 엔진 의무 = 모든 행 `revokeAction`·`revokeConfirmText` null ·
    /// [pairing] 의 `issueAction`·`qrSlotId`·`expiresText` null · [migrationLink] null — 화면은 거르지 않는다(K35).
    String? lockedLabel,
  }) = _DeviceAccessVm;

  factory DeviceAccessVm.fromJson(Map<String, dynamic> json) =>
      _$DeviceAccessVmFromJson(json);
}
// JSON 키: devices · lease_holder_label · lease_state_label · as_of · lease_eta_text · lease_level · lease_epoch_text ·
//          migration_link · pairing · empty_label · locked_label

/// m2-8 G-8 · 🆕 v1.20 추가형 — 기기 1행. 🔴 기기 전체 식별자를 화면 문구로 만들지 않는다.
@freezed
abstract class DeviceRow with _$DeviceRow {
  const factory DeviceRow({
    /// 🔴 화면 미참조(글자·Key 0 — Key = 순번 · K10). 폐기 호출 args 는 엔진이 [revokeAction] 에 완성한다.
    required String deviceId,
    required String label,
    required String roleLabel,
    required String statusLabel,
    required String lastSeenText,

    /// 🆕 v1.20 — 행 색의 유일한 근거.
    required UiLevel level,

    /// 🆕 v1.20 — 엔진이 완성한 `deviceTokenRevoke{device_id}`(viewer 행만 · 이 폰 행·폐기된 행·잠김 = null).
    SettingsActionCall? revokeAction,

    /// 🆕 v1.20 — 펼침 확인 글자(«즉시 조회가 차단됩니다 …» · 엔진 · K18). 🔴 [revokeAction] non-null ⇔ non-null.
    String? revokeConfirmText,
  }) = _DeviceRow;

  factory DeviceRow.fromJson(Map<String, dynamic> json) =>
      _$DeviceRowFromJson(json);
}
// JSON 키: device_id · label · role_label · status_label · last_seen_text · level · revoke_action · revoke_confirm_text

/// 🆕 v1.20(01 §29 · K15 · K16) — `S06` viewer QR 페어링 티켓 카드(발급 쪽 · 스캔 = M8 `V-01` `VIEWER_QR_SCAN`).
/// 🔴 잠김 밖에서는 [issueAction] XOR [qrSlotId](티켓 없음 = 발급 버튼 · 유효 티켓 = QR 자리) · [qrSlotId] ⇔ [expiresText].
/// 🔴 페이로드·토큰 칸 0(QR 은 슬롯 위젯 안에서만 — 조립 앱 · 06 `M4-12` ⑦) · 카운트다운 0(만료 = 엔진이 카드를 닫은 새 VM).
@freezed
abstract class PairingTicketCard with _$PairingTicketCard {
  const factory PairingTicketCard({
    /// 카드 머리 한 줄 — 엔진.
    required String headline,

    /// 엔진이 완성한 `devicePairingTicketCreate{}`(«QR 만들기»). null = 버튼 부재.
    SettingsActionCall? issueAction,

    /// QR 표시 자리 이름(`SettingsSlotIds.pairingQrDisplay`). null = 자리 부재.
    String? qrSlotId,

    /// «09:15 까지 유효» — 엔진 절대 시각 글자(🔴 남은 초를 세지 않는다).
    String? expiresText,
  }) = _PairingTicketCard;

  factory PairingTicketCard.fromJson(Map<String, dynamic> json) =>
      _$PairingTicketCardFromJson(json);
}
// JSON 키: headline · issue_action · qr_slot_id · expires_text

/// m2-8 G-9 · 🆕 v1.24 교체(01 §33 · K110) — 백업·복원(05 `S09`) 화면 VM. 🔴 소비자 0 에서 바꿨다(v1.18 `SettingsHomeVm` 교체 선례) —
///    옛 칸 `lastOkText`·`statusCode`·`statusLabel`·`actionAvailable`·`sizeText`·`route` 는 **삭제**(«부재 = 목록에 없음» K-q · 뜻 불명).
/// 🔴 글자·시각·해시 = 엔진(화면은 자르기·잇기·세기 0 — `substring` 0) · 파일 경로·파일 이름·크기 칸 0(05 S09 «노출 금지») ·
///    나이 판정·임계 = 엔진(`BACKUP_STALE` 와 같은 원천 · 화면 `DateTime.now()` 0).
/// 🔴 **복원 버튼 0**(K111) — 복원 = 새 폰 X1 마법사(`R-01`) 몫 · 이 화면은 [migrationLink] 하나 · `backupRestoreStart` 화면 미호출.
/// 🔴 [runAction] null = 버튼 **부재**(모의 원장 · 스탬프 0 · 아카이브 미일치 · 잠김 · 실행 중 — 판정 = 엔진 · K133) ·
///    [lockedLabel] non-null ⇒ [runAction] null(K-t · C-58 ②).
@freezed
abstract class BackupVm with _$BackupVm {
  const factory BackupVm({
    /// «마지막 백업 11-17 21:40» — 엔진이 아카이브 나이와 스냅숏을 묶은 글자(K112 · 화면 분기 0).
    required String lastBackupText,

    /// 나이 배지(문구·임계 = 엔진). null = 배지 부재.
    String? ageBadgeText,

    /// [lastBackupText]·[ageBadgeText] 줄의 색·아이콘 근거.
    required UiLevel level,

    /// 고지 한 줄(«백업은 이 폰 안에만 있습니다 …» · 모의 «… 실전 원장에서만 …» — 엔진). null = 줄 부재.
    String? noticeText,

    /// 엔진이 완성한 `backupRunNow{}`(«지금 백업»). 🔴 null = 버튼 부재 — 화면은 그대로 `SettingsActions.run` 1회.
    SettingsActionCall? runAction,

    /// 운영 등급 생체 축소 등 «보기만» 한 줄(엔진·조립). non-null ⇒ [runAction] null.
    String? lockedLabel,

    /// 복원 지점(받은 차례 · 행 동작 0 — K111).
    required List<RestorePointRow> points,

    /// [points] 가 비었을 때의 엔진 한 줄. 🔴 [points] 빈 ⇔ non-null(C-58 ③).
    String? pointsEmptyLabel,

    /// «폰을 바꾸시나요?» + X1 기기 이전 링크(글자·목적지 = 엔진 · `x1Migration`). null = 부재(잠김 · 원천 없음).
    LinkAction? migrationLink,
    required AsOf asOf,
  }) = _BackupVm;

  factory BackupVm.fromJson(Map<String, dynamic> json) =>
      _$BackupVmFromJson(json);
}
// JSON 키: last_backup_text · age_badge_text · level · notice_text · run_action · locked_label · points · points_empty_label ·
//          migration_link · as_of

/// 🆕 v1.24(01 §33 · K110 · K111) — `S09` 복원 지점 1행(원천 = X1 스냅숏 매니페스트 목록 — 목록 함수 = 엔진 숙제 · 01 §8 미결 199).
/// 🔴 **행 동작 칸 0**(복원 = X1 마법사 · K111) · 크기·파일 이름·경로 칸 0.
@freezed
abstract class RestorePointRow with _$RestorePointRow {
  const factory RestorePointRow({
    /// 🔴 ui 미참조(Key = 받은 차례 순번 — C4r7c-4).
    required String code,

    /// 시각·장부 날 글자(엔진 · 스냅숏 이름 = 시각 + 매니페스트 `authored_date`).
    required String label,

    /// 체인 해시 앞 8자 — 🔴 **엔진이 자른다**(화면 `substring` 0 · C-58 ④ `^[0-9a-f]{8}$`).
    required String chainHashText,

    /// 검증 상태 한 줄(엔진). null = 줄 부재.
    String? stateLabel,
  }) = _RestorePointRow;

  factory RestorePointRow.fromJson(Map<String, dynamic> json) =>
      _$RestorePointRowFromJson(json);
}
// JSON 키: code · label · chain_hash_text · state_label

/// m2-8 G-10 — 진단 보드(05 `S10`) · 🆕 v1.13 `H-01` 블록 6(R13b)도 이 VM 을 그린다(01 §23).
/// 🔴 **칸 수 5 고정은 엔진이 준다** — 모드와 무관하며 화면이 세지 않는다(§2-9).
/// 🆕 v1.13(01 §23 · K4) — [headline] 은 **늘 엔진 문장**이다(전부 일치 날 = 일치를 말하는 문장 · 빈 글자 0) ·
///    화면은 늘 그린다 — 칸 상태로 문장을 고르거나 숨기지 않는다.
@freezed
abstract class DiagnosticsVm with _$DiagnosticsVm {
  const factory DiagnosticsVm({
    required List<DiagnosticCell> cells,
    required String headline,
    required AsOf asOf,
  }) = _DiagnosticsVm;

  factory DiagnosticsVm.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticsVmFromJson(json);
}

/// m2-8 G-10 — 진단 1칸.
/// 🔴 `applicable == false` 칸도 빼지 않는다 — 엔진의 [stateLabel](«해당 없음»·«점검하지 않음» 등)을
///    그대로 그린다 · 빈칸·통과로 그리지 않는다(C15 · G-27).
/// 🆕 v1.13(01 §23 · K2 · K3) — [level] = 신호등 색·아이콘의 유일한 근거(04 §2-3 «색+아이콘+텍스트 3중») ·
///    [stateCode] 로 색을 고르지 않는다(ui 미참조) · 엔진 의무: `applicable == false` ⇒ `info` ·
///    `blocked` 는 `canonBroker`·`canonSelfReport` 만(파생 불일치는 주문을 막지 않는다) · 점검한 칸
///    (`applicable == true`)은 `stateCode == 'OK'` ⇔ `level == ok`(«어긋납니다» 를 초록으로 그리지 않는다 · K3 ⓒ) — C-47 ⑩.
@freezed
abstract class DiagnosticCell with _$DiagnosticCell {
  const factory DiagnosticCell({
    required LedgerPair pair,
    required String label,
    required bool applicable,
    required String stateCode,
    required String stateLabel,
    required UiLevel level,
  }) = _DiagnosticCell;

  factory DiagnosticCell.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticCellFromJson(json);
}

/// 🆕 v1.24(01 §33 · K113) — 진단(05 `S10`) 화면 VM = **감싸개**(원천 1 스트림 · `SettingsRepository.watchDiagnosticsScreen`).
/// 🔴 [board] = `H-01` 블록 6 과 **같은 값**(엔진 `diagnosticsOf` 하나 · 두 벌 0) · `board.asOf` 는 ui 미참조(오래됨 = [asOf]) ·
///    무결성 칸 요약 문장 = `board.headline`(카드가 따로 짓지 않는다 · K137).
/// 🔴 [lockedLabel] non-null ⇒ 두 카드 `runAction` null(C-58 ②) · [diffsLink] = 조회 링크(잠김에도 남을 수 있다 — K138).
/// 🔴 05 옛 꼴 `{SelfTestVm golden, IntegrityVm integrity}`·`blocking` 은 쓰지 않는다(01 §8 미결 128 «05 꼴» 몫 닫음 · 차단 = `DiagnosticCell.level`).
@freezed
abstract class DiagnosticsScreenVm with _$DiagnosticsScreenVm {
  const factory DiagnosticsScreenVm({
    /// 골든벡터 셀프테스트 카드(E11o 전 = «판정 보류» · `runAction` null — K114).
    required SelfTestCard golden,

    /// 무결성 자가진단 카드(`statusLabel` = «마지막 검증 …» · 실행 = 정본 자가 대조 — K115 · K137).
    required SelfTestCard integrity,

    /// 5칸 대조 보드(`DiagnosticsVm` 무변경).
    required DiagnosticsVm board,

    /// 차이 상세 링크(글자·목적지 = 엔진 · `ledgerDiffs` · 🔴 정정 마법사 링크·렌더 0 — K116). null = 부재.
    LinkAction? diffsLink,

    /// 진입 권장 배너(«앱 업데이트 후 · 기기 이전 후 · 실전 전환 직전» — 엔진). null = 부재.
    String? recommendText,

    /// 운영 등급 생체 축소 등 «보기만» 한 줄. non-null ⇒ 두 카드 `runAction` null.
    String? lockedLabel,
    required AsOf asOf,
  }) = _DiagnosticsScreenVm;

  factory DiagnosticsScreenVm.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticsScreenVmFromJson(json);
}
// JSON 키: golden · integrity · board · diffs_link · recommend_text · locked_label · as_of

/// 🆕 v1.24(01 §33 · K113 · K114 · K137) — `S10` 실행 카드 1장(골든 · 무결성 같은 꼴).
/// 🔴 총계·비율·«n/m» 은 [summaryText] 엔진 글자 안에서만(화면 상수·조립 0 · 05 §8-1) · 실패 행 칸 = 이번 판 0(E11o 뒤 추가형 · 미결 198).
/// 🔴 [runAction] null = 버튼 부재(실행기 없음 · 실행 중 · 잠김 — 판정 = 엔진) · 화면은 그대로 `SettingsActions.run` 1회.
@freezed
abstract class SelfTestCard with _$SelfTestCard {
  const factory SelfTestCard({
    /// 카드 제목(엔진 · 정적 라벨 0 — K137).
    required String title,

    /// 상태 한 줄(«골든벡터 판정 보류» · «실행 중» · «통과» · «마지막 검증 11-18 03:10» — 엔진).
    required String statusLabel,

    /// 카드 색·아이콘 근거.
    required UiLevel level,

    /// 마지막 실행 줄(엔진). null = 줄 부재.
    String? lastRunText,

    /// 요약 줄(엔진 · 총계 상수 0). null = 줄 부재.
    String? summaryText,

    /// 엔진이 완성한 `selftestGoldenRun{}` / `selftestIntegrityRun{}`. null = 버튼 부재.
    SettingsActionCall? runAction,
  }) = _SelfTestCard;

  factory SelfTestCard.fromJson(Map<String, dynamic> json) =>
      _$SelfTestCardFromJson(json);
}
// JSON 키: title · status_label · level · last_run_text · summary_text · run_action

/// 🆕 v1.24(01 §33 · K118 · 01 §8 미결 95 (b)) — M9 `S12` 12월 연간 리뷰 **목차** VM(`OpsStatusRepository.watchAnnualReview` 반환).
/// 🔴 세후·수익률·평가액·`lines`·연도 원값·창 상태 원값 칸 **0** — 타입에 없으면 나갈 수 없다(결정 8 · 01 §2-8 화이트리스트 원칙) ·
///    M7 `S7-7` 의 `AnnualReviewVm` 은 무변경(다른 타입).
/// 🔴 [entries] = 받은 차례 · M7 화면 링크만(기각 등록부 행 = HB-3 채택 전 0) · 화면이 행을 더하지 않는다 · 0 이면 행 0(K139) ·
///    [pledgeLink] = 창 OPEN 일 때만 엔진이 채운다(목적지 `m5Pledge` · 편집 = M5-8) · 화면은 달·창을 판정하지 않는다.
@freezed
abstract class AnnualReviewIndexVm with _$AnnualReviewIndexVm {
  const factory AnnualReviewIndexVm({
    /// «2026년 연간 리뷰» — 엔진(`AnnualReviewVm.yearLabel` 과 같은 말).
    required String yearLabel,

    /// 창 상태 한 줄(엔진 · 원값 칸 0).
    required String windowStateLabel,

    /// 목차 행(M7 링크 · 받은 차례).
    required List<LinkAction> entries,

    /// 서약 편집 진입(M5-8 · OPEN 때만). null = 부재.
    LinkAction? pledgeLink,
    required AsOf asOf,
  }) = _AnnualReviewIndexVm;

  factory AnnualReviewIndexVm.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewIndexVmFromJson(json);
}
// JSON 키: year_label · window_state_label · entries · pledge_link · as_of

/// ⏸ m2-8 J-2 — `live × dryRun` 관찰 기간·승격 확인(§8-28 G-43).
/// 🔴 **이름만 확정이고 기능은 발주자 확정 대기**다: 관찰 거래일 수는 엔진 config
///    신설 키이며 화면·계약이 상수로 적지 않는다(`requiredTradingDays` 로 온다).
/// 🔴 **승격에 새 화면·새 라우트를 만들지 않는다** — `S05` 엔진 상태 칩 + 기존 M5
///    게이트 다이얼로그(생체 1회)다.
@freezed
abstract class LiveDryRunObservationVm with _$LiveDryRunObservationVm {
  const factory LiveDryRunObservationVm({
    required int observedTradingDays,
    required int requiredTradingDays,

    /// 🔴 표시의 정본 — 화면이 두 수치로 「n/m」을 조립하지 않는다.
    required String progressText,
    required bool promotionAvailable,
    required String stateLabel,
  }) = _LiveDryRunObservationVm;

  factory LiveDryRunObservationVm.fromJson(Map<String, dynamic> json) =>
      _$LiveDryRunObservationVmFromJson(json);
}

/// 🆕 계약 v1.17(01 §26 · K17 · 01 §8 미결 123) — `H-03` 물리 리스크 항목 1행.
/// 🔴 글자 전부 = 엔진(측정 = 플랫폼 API · 임계·판정·조치 문구 = 엔진) · 화면은 비교·남은 일수 계산을 하지 않는다 ·
///    [level] = 아이콘·색만.
@freezed
abstract class DeviceRiskItem with _$DeviceRiskItem {
  const factory DeviceRiskItem({
    /// «저장공간» — 엔진.
    required String label,

    /// «남은 공간 3.1GB» — 엔진.
    required String currentText,

    /// «임계 2GB 미만» — 엔진.
    required String thresholdText,

    /// «오래된 아카이브를 PC로 옮기세요» — 엔진.
    required String actionText,

    /// «마지막 점검 08-31 08:55» — 엔진(KST).
    required String lastCheckedText,
    required UiLevel level,
  }) = _DeviceRiskItem;

  factory DeviceRiskItem.fromJson(Map<String, dynamic> json) =>
      _$DeviceRiskItemFromJson(json);
}
// JSON 키: label · current_text · threshold_text · action_text · last_checked_text · level

/// 🆕 계약 v1.17 — `H-03` 물리 리스크 점검 상세(창구 [OpsStatusRepository.watchDeviceRisk] · 04 §4-6 그림 8).
/// 🔴 항목 목록·수·차례 = 받은 그대로(넷 하드코딩 0) · 조작 버튼(로그 정리·백업 실행) 칸 0 = 01 §8 미결 161 · asOf 있음(측정값).
@freezed
abstract class DeviceRiskVm with _$DeviceRiskVm {
  const factory DeviceRiskVm({
    required List<DeviceRiskItem> rows,

    /// «비상 복구가 아니라 계획 교체» 안내 — 엔진(늘 싣는다).
    required String guidanceText,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,
    required AsOf asOf,
  }) = _DeviceRiskVm;

  factory DeviceRiskVm.fromJson(Map<String, dynamic> json) =>
      _$DeviceRiskVmFromJson(json);
}
// JSON 키: rows · guidance_text · empty_label · as_of
```

---

## `packages/domain_contracts/lib/src/dto/performance.dart`

```dart
// 01 §2-4 — 수익률(M7 요구 2) · 세후 사다리 · §2-6 M7 뷰모델(G-41).
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간
//    차액도 금지이며 C-30 이 이것을 검사한다(01 §2-4 말미).
// 🔴 «정직 기대»·사다리 4자리 수치를 코드·라벨·주석에 옮기지 않는다 —
//    인용처는 픽스처 `aftertax_ladder_1.json` 과 골든 `aftertax_full_S7` 뿐이다.
// 🔴 `PerfMetric.twr` 은 외부 현금흐름 «보정판»이다(01 §2-4 P 회차 실측).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/performance.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'ledger_trust.dart';

part 'performance.freezed.dart';
part 'performance.g.dart';

/// 01 §2-4 — 수익률 시리즈. 🔴 누적/비누적 토글도 엔진이 두 시리즈를 주거나
/// `cumulative` 로 재요청한다(화면 누적곱은 단일 산식 원칙 위반).
@freezed
abstract class PerformanceSeries with _$PerformanceSeries {
  const factory PerformanceSeries({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,

    /// 🔴 결측·재개로 분절된 구간들.
    required List<PerfSegment> segments,
    required List<PerfPoint> points,

    /// 표본 크기 고지·인터스티셜 문구·열람 횟수(01 §2-4).
    required PerfDisclosure disclosure,
    required AsOf asOf,

    /// 🆕 v1.3 — 본선의 이름(범례). "내 계좌 · 시간가중 · 누적" — 엔진 생성.
    required String seriesLabel,

    /// 🆕 v1.3 — 이 시리즈가 덮는 기간. "2024년 9월 ~ 2026년 8월" — 엔진 생성.
    /// `range == null` 요청에서 엔진이 고른 구간을 말하는 유일한 글자다.
    required String periodLabel,

    /// 🆕 v1.3 — 세로축 눈금(아래 → 위 순서). 비면 눈금 없음. 많아야 5개다(C-36 ④).
    @Default(<PerfAxisTick>[]) List<PerfAxisTick> yTicks,

    /// 🆕 v1.3 — non-null ⇔ `points` 가 비어 있다(C-36 ⑤). 그때는 차트·눈금·범례·값 표
    /// 대신 **이 문장 카드 1장**이다. `segments`·`yTicks` 도 비고 `benchmark` 는 null 이다.
    /// 기록이 비었든 차단으로 가렸든 엔진이 이 필드로 말한다.
    /// 🔴 화면은 점을 세거나 훑어 상태를 고르지 않는다. 점이 하나라도 오면 그중 하나는
    ///    값이 있다.
    String? unavailableLabel,

    /// KOSPI 50% + S&P500(KRW) 50% — m2-8 F-9.
    BenchmarkSeries? benchmark,

    /// 🆕 P 회차 — 세후는 «층»이다. 단일 스칼라 필드를 만들지 않는다.
    AfterTaxLadder? afterTax,
  }) = _PerformanceSeries;

  factory PerformanceSeries.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSeriesFromJson(json);
}

/// 01 §2-4 · §13-1 — 시계열 1점. 🔴 `value == null` 은 결측이며 **보간 금지**(C-10).
@freezed
abstract class PerfPoint with _$PerfPoint {
  const factory PerfPoint({
    @TradeDateConverter() required TradeDate date,

    /// 🆕 v1.3 — 가로 자리(0.0 = 그림 영역 왼쪽 끝 · 1.0 = 오른쪽 끝). 🔴 그래프 기하 전용.
    /// 점의 순서대로 **오름차순**으로 온다. 점이 1개면 0.5 다.
    required double xNormalized,

    /// 🆕 v1.3 — 이 점을 가리키는 날짜 글자("2026-08-31" · "2026년 8월" · "2026년").
    /// 주기에 맞춰 엔진이 만든다. 화면이 `date` 를 자르거나 포맷하지 않는다.
    required String dateText,

    /// 🆕 v1.3 — **표시의 정본**("1.42%"). 결측 점에도 온다("산출 불가" · "합산 제외").
    required String valueText,

    /// 🆕 v1.3 — 세로 자리(0.0 = 아래 끝 · 1.0 = 위 끝). 🔴 그래프 기하 전용.
    /// null = 결측 — 선을 끊는다. `value == null` 과 언제나 함께 온다(C-10 ⑤).
    /// 🔴 본선과 벤치마크는 **같은 축**으로 정규화돼 온다 — 화면은 축 범위를 모른다.
    double? yNormalized,

    /// 🔴 v1.3 — 골든 대조·회귀 전용. `ui_*` 에서 참조하지 않는다(C-36 ⑦). null = 결측.
    /// 결측은 공백으로 그린다 — 이어 붙이지 않는다.
    double? value,

    /// `EQUITY_SNAPSHOT_MISSING` · `RESUME_GAP` · 🆕 v1.3 `SIM_EXCLUDED`(인벤토리 §6-14).
    String? gapReasonCode,
  }) = _PerfPoint;

  factory PerfPoint.fromJson(Map<String, dynamic> json) =>
      _$PerfPointFromJson(json);
}

/// 01 §2-4 · §13-3 — 분절 구간. 🔴 `manualExecuted` 는 `simExcluded` 와 달리 합산에
/// 포함되고 경계는 실선이다(D6). 겹치면 `freshAuto` 절단선이 이긴다.
@freezed
abstract class PerfSegment with _$PerfSegment {
  const factory PerfSegment({
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,
    required SegmentKind kind,

    /// "7거래일 미실행 — 산출 불가" — 엔진 생성.
    required String label,

    /// 🆕 v1.3 — 띠의 가로 범위(그림 영역 폭에 대한 비율 · start ≤ end). 🔴 기하 전용.
    /// 엔진이 «덮는 점의 앞뒤 반 칸»까지 넓혀서 준다(0.0~1.0 으로 자른다).
    /// 화면은 `from`·`to` 를 점의 날짜와 **비교하지 않는다**.
    /// 구간은 받은 순서대로이고 서로 겹치지 않는다(C-36 ④b).
    required double startNormalized,
    required double endNormalized,
  }) = _PerfSegment;

  factory PerfSegment.fromJson(Map<String, dynamic> json) =>
      _$PerfSegmentFromJson(json);
}

/// 🆕 v1.3 · 01 §13-1 — 세로축 눈금 1개.
@freezed
abstract class PerfAxisTick with _$PerfAxisTick {
  const factory PerfAxisTick({
    /// 세로 자리(0.0~1.0). 🔴 기하 전용.
    required double normalized,

    /// "0%" · "4%" — 엔진 생성.
    required String label,

    /// 0 기준선인가. 한 시리즈에 많아야 하나다(C-36 ④).
    @Default(false) bool isBaseline,
  }) = _PerfAxisTick;

  factory PerfAxisTick.fromJson(Map<String, dynamic> json) =>
      _$PerfAxisTickFromJson(json);
}

/// 01 §2-4 · m2-8 F-9 — 벤치마크 시리즈.
@freezed
abstract class BenchmarkSeries with _$BenchmarkSeries {
  const factory BenchmarkSeries({
    required String label,

    /// 🆕 v1.3 — 본선(`PerformanceSeries.points`)과 **같은 길이 · 같은 날짜 순서 ·
    /// 같은 `xNormalized`** 로 온다(C-36 ②). `yNormalized` 도 본선과 같은 축이다.
    required List<PerfPoint> points,

    /// 구성 고지 한 줄 — 엔진 생성.
    required String compositionNote,
  }) = _BenchmarkSeries;

  factory BenchmarkSeries.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkSeriesFromJson(json);
}

/// 01 §2-6 · m2-8 F-8 — 기대치 문구의 유일한 운반처(🔴 **M7 화면 한정**).
/// 🔴 M8 온보딩·핸드북은 같은 문자열을 **각자의 뷰모델 필드**로 받는다 —
///    성과 타입을 건너 참조하지 않는 것이 C-3 규약이다.
@freezed
abstract class PerfDisclosure with _$PerfDisclosure {
  const factory PerfDisclosure({
    required String sampleSizeLine,
    required String interstitialText,

    /// 🔴 명령 테이블(append-only)의 이번 달 집계 — 화면이 세지 않는다(G-42).
    required int viewCountThisMonth,
    required String honestExpectationLine,
    String? drawdownCaveatLine,
  }) = _PerfDisclosure;

  factory PerfDisclosure.fromJson(Map<String, dynamic> json) =>
      _$PerfDisclosureFromJson(json);
}

/// 01 §2-4 · m2-8 A-7 · F-16 — 세후 사다리의 한 층.
/// 🔴 `valueText` 가 **표시의 정본**이다. `cagrPct`·`endMult` 는 골든 대조·회귀
///    전용이며 `ui_*` 위젯트리에서 참조하면 C-30 이 실패한다.
@freezed
abstract class AfterTaxStep with _$AfterTaxStep {
  const factory AfterTaxStep({
    /// `PRETAX`·`AFTER_POT`·`AFTER_POT_C`·`WD_5P5`·`WD_16P5`·`HONEST`
    /// (인벤토리 §6-13 · 영역 E 의 상수 목록이 정본).
    required String stepCode,

    /// "② 전 계좌 세후 — 연금 인출세 16.5%" — 엔진 생성.
    required String label,

    /// 🔴 표시의 정본. 엔진이 포맷한 완성 문자열.
    required String valueText,

    /// 🔴 골든 대조 전용 — 화면 참조 금지(C-30).
    double? cagrPct,

    /// 🔴 같음 — 층 간 차액을 빼는 경로를 데이터 형태로도 열지 않는다.
    double? endMult,
    String? noteLine,
  }) = _AfterTaxStep;

  factory AfterTaxStep.fromJson(Map<String, dynamic> json) =>
      _$AfterTaxStepFromJson(json);
}

/// 01 §2-4 — 세후 사다리. 🔴 갈래는 **계좌 배치가 정한다**(SAF-309) —
/// 화면·인자로 고르는 경로를 만들지 않는다.
@freezed
abstract class AfterTaxLadder with _$AfterTaxLadder {
  const factory AfterTaxLadder({
    required TaxLadderBranch branch,

    /// "POT = 절세계좌(명세 준수)" — 엔진 생성.
    required String branchLabel,

    /// 🔴 순서 그대로 그린다. 층을 합치거나 건너뛰지 않는다.
    required List<AfterTaxStep> steps,

    /// 🔴 숫자 상수 금지 — 엔진 생성 문장을 그대로 그린다.
    required String honestExpectationLine,
    required String basisNote,

    /// 🔴 §8-18 확정 전에는 **항상 true**(골든 참고치이지 실계좌 산출이 아니다).
    /// 🔴 SIM 에서도 이 라벨을 유지한다(01 §9-4).
    /// 🔴 화면 미참조(C-42) — 표지는 [referenceOnlyLabel] 이 말한다.
    required bool isReferenceOnly,

    /// 🆕 v1.6 — «골든 참고치입니다. 실계좌로 산출한 값이 아닙니다» — 엔진 문장.
    /// 🔴 non-null ⇔ [isReferenceOnly](C-41 ⑦) · SIM 에서도 같다(01 §9-4) · 화면 = [basisNote] 다음 줄 그대로.
    String? referenceOnlyLabel,
    required String configHash, // S7-7 미표시
    required AsOf asOf, // S7-7 미표시(하단은 `AnnualReviewVm.asOf` 하나)
  }) = _AfterTaxLadder;

  factory AfterTaxLadder.fromJson(Map<String, dynamic> json) =>
      _$AfterTaxLadderFromJson(json);
}

/// 01 §2-6 · m2-8 F-7 — 월간 1페이지 리포트(`S7-1`).
/// 🔴 **단일 `afterTaxPct` 필드를 만들지 않는다** — 세후는 `AfterTaxLadder` 로만
///    실어 나른다. 🔴 반사실 항목을 14번째로 늘리지 않는다(C-25).
@freezed
abstract class MonthlyReport with _$MonthlyReport {
  const factory MonthlyReport({
    required String yyyyMm,

    /// 🔴 **13항목 고정 배열**. 결측에서도 자리를 유지하며 항목을 더하거나
    ///    빼지 않는다(03 §3 · C-25).
    required List<ReportItem> items,
    required String goalLine,

    /// 🔴 화면이 「n회」를 숫자로 조립하지 않는다(G-42).
    required String disclosureViewCountText,

    /// X7 — 헤더 배지(01 §2-11 · G-97).
    required LedgerTrustBadge trust,
    required AsOf asOf,

    /// 세후 사다리. 🔴 13항목 배열에는 넣지 않는다(03 §3).
    AfterTaxLadder? afterTax,

    /// 전월 소급 정정 각주 — 🔴 마감된 달을 재계산하지 않는다(G-97).
    String? backdateFootnote,

    /// 🆕 v1.1(§8 미결 40) — 미생성 달의 한 문장: "9월 1일 생성일에 만들어집니다 · D-4".
    /// 🔴 non-null 이면 헤더 아래에 그대로 그린다. 화면이 D-day 를 계산하지 않는다.
    String? pendingNoticeText,

    /// 🆕 v1.1(§8 미결 43) — "2026-09-01 생성" · 미생성이면 null.
    String? generatedAtText,

    /// 🆕 v1.1(§8 미결 43) — 이 리포트를 만든 설정의 해시(모노스페이스 축약 표시용).
    /// 🔴 화면이 다른 해시와 비교하지 않는다(contract_version.dart 말미 조문). 미생성이면 null.
    String? configHash,

    /// 🆕 v1.4(01 §14-9) — «목표 경로 보기» 버튼의 목적지(`AppRoutes.reportGoalPath` 꼴 · C-33).
    /// null = **버튼 부재**(자리표시자 없음). 엔진은 과거 달·가림·미생성 달이면 null 로 둘 수 있다.
    /// 🔴 화면은 이 문자열을 해석·조립하지 않고 `AppLinkOpener.open` 에 그대로 넘긴다.
    String? goalDeepLink,
  }) = _MonthlyReport;

  factory MonthlyReport.fromJson(Map<String, dynamic> json) =>
      _$MonthlyReportFromJson(json);
}

/// ⚠️ **M2-8 미확정** — `m2-8_naming.md` F-7 이 `List<ReportItem>` 이라는 **이름만**
/// 확정했고 필드 축은 어느 문서에도 없다. 아래는 03 §3(13항목 고정 배열 · 섹션
/// A~G · 「결측에서도 자리를 유지」 · 전부 엔진 완성 문자열)에서 읽어낸 **임시
/// 최소 축**이며, `AnnualReviewSection`(F-6)·`OpsRhythmRow`(G-2)와 같은 모양이다.
/// 🔴 화면 담당은 이 타입을 픽스처 고정 모드로만 쓰고, 축 확정 전에는 항목을
///    코드로 세거나 순서를 재정렬하지 않는다.
@freezed
abstract class ReportItem with _$ReportItem {
  const factory ReportItem({
    required String code,

    /// 🔴 13항목의 고정 순서. 화면이 정렬 키를 만들지 않는다.
    required int order,

    /// 섹션 A~G(03 §3).
    required String sectionCode,
    required String title,

    /// 🔴 엔진 완성 문자열 — 결측이면 그 사실도 이 문자열이 말한다.
    /// 🔴 차단 시 가림도 엔진 읽기 경로가 끝낸다(01 §2-10) — 화면은 바꾸지 않는다.
    required String valueText,
    String? noteText,

    /// 🆕 v1.1(§8 미결 41) — 이 항목의 「자세히」 목적지. 🔴 **non-null 인 항목에만** 버튼을
    ///    그린다. 어느 항목에 링크가 붙는지는 엔진이 정한다 — 화면이 `order`·`code`·
    ///    `OperatingMode` 로 판정하지 않는다.
    String? detailDeepLink,
  }) = _ReportItem;

  factory ReportItem.fromJson(Map<String, dynamic> json) =>
      _$ReportItemFromJson(json);
}

/// 01 §2-6 · m2-8 F-1 — 월간 리포트 아카이브(`S7-1b`). 🔴 **수치 필드 0건**.
@freezed
abstract class ReportArchiveVm with _$ReportArchiveVm {
  const factory ReportArchiveVm({
    /// 🆕 v1.3 — 엔진이 **최신 달부터** 정렬해서 준다. 화면은 받은 순서 그대로 그린다.
    required List<ReportArchiveRow> rows,
    required AsOf asOf,
    String? emptyLabel,
  }) = _ReportArchiveVm;

  factory ReportArchiveVm.fromJson(Map<String, dynamic> json) =>
      _$ReportArchiveVmFromJson(json);
}

/// m2-8 F-1 — 아카이브 1행. 🔴 수치 컬럼이 없다(`rm_report_archive`).
@freezed
abstract class ReportArchiveRow with _$ReportArchiveRow {
  const factory ReportArchiveRow({
    required String yyyyMm,
    required String label,
    required bool generated,

    /// 🔴 모드 표시도 엔진 문자열이다 — 화면이 `RunMode` 로 분기하지 않는다.
    required String modeLabel,
    String? reasonLabel,
    String? route,

    /// 🆕 v1.3 — non-null 이면 **이 행 위에** 머리글 1줄을 그린다("2026년" · "2025년 · 모의투자").
    /// 🔴 화면은 앞 행과 비교하지 않는다 — 묶음의 첫 행에만 엔진이 실어 준다.
    String? sectionLabel,
  }) = _ReportArchiveRow;

  factory ReportArchiveRow.fromJson(Map<String, dynamic> json) =>
      _$ReportArchiveRowFromJson(json);
}

/// 01 §4-1 · m2-8 F-2 — 성과 열람 게이트(`S7-2G`).
/// 🔴 `viewCountThisMonth` 숫자 필드를 두지 않는다 — 화면이 「n회」를 조립하지
///    않게 `viewCountText` 하나만 온다.
@freezed
abstract class DisclosureGateVm with _$DisclosureGateVm {
  const factory DisclosureGateVm({
    /// 🆕 v1.3(뜻 확정 · 01 §13-5) — **엔진이 지금 진입을 허용하는가.**
    /// false 면 「그래도 보기」가 없다(「돌아가기」만). «게이트를 건너뛴다»는 뜻이 아니다.
    required bool gateOpen,

    /// 게이트 머리 문장 — 엔진 생성. 닫힌 게이트에서는 **닫힌 까닭**을 말한다.
    required String headline,
    required String viewCountText,
    required AsOf asOf,

    /// 🆕 v1.3(뜻 확정) — null = **그 줄이 없다**(자리표시자·빈 줄을 그리지 않는다).
    String? frictionLine,

    /// 🆕 v1.3(뜻 확정) — `gateOpen` 의 링크 표현이다(`gateOpen == (route != null)` · C-37 ①).
    /// **게이트 밖 진입점용**이며 🔴 게이트 화면은 이 링크를 열지 않는다
    /// (열면 자기 자신이 다시 뜬다).
    String? route,
  }) = _DisclosureGateVm;

  factory DisclosureGateVm.fromJson(Map<String, dynamic> json) =>
      _$DisclosureGateVmFromJson(json);
}

/// 01 §2-6 · m2-8 F-3 — 드로다운 맥락(`S7-3`).
/// 🔴 `referenceBandCaveatText` 가 null 이면 그 줄을 **그리지 않는다**
///    («최대낙폭은 하한»의 단서이며 화면이 대신 문장을 짓지 않는다).
@freezed
abstract class DrawdownContextVm with _$DrawdownContextVm {
  const factory DrawdownContextVm({
    /// "최근 24개월" — `range == null` 이면 엔진 기본 구간이고 그 결과를 이 문구가 말한다.
    required String periodLabel,

    // 🔴 아래 세 값은 짧은 숫자가 아니라 **제목을 포함한 엔진 완성 문장**이다(C4 R2-Gem-S73
    //    교훈). 화면이 제목을 따로 달면 같은 말을 두 번 하게 되고, 좁은 칸에 넣으면
    //    들어가지 않는다 — 전체 폭 한 줄씩 그린다. `FittedBox` 로 줄이지 않는다.
    /// "현재 낙폭 −2.1%"
    required String currentDdText,

    /// "최대 낙폭 −6.4%"
    required String maxDdText,

    /// "회복까지 걸린 최장 기간 3개월"
    required String tuwText,

    /// 🔴 게이지 폭 전용 정규값(0.0~1.0). 표시는 `*Text` 필드다.
    required double ddNormalized,
    required AsOf asOf,
    String? referenceBandText,
    String? referenceBandCaveatText,
  }) = _DrawdownContextVm;

  factory DrawdownContextVm.fromJson(Map<String, dynamic> json) =>
      _$DrawdownContextVmFromJson(json);
}

/// 01 §2-6 · m2-8 F-4 — **슬리브 기여 분해**(`S7-3b` · 03 §10).
/// 🔴 `MonthlyContributionVm`(월 납입 운영값 카드 · `settings.dart`)과 **다른
///    타입**이며 이름을 공유하지 않는다(01 §2-6 이름 충돌 방지 조문 · N-01).
/// 🔴 **종목 단위 행 없음**.
@freezed
abstract class ContributionVm with _$ContributionVm {
  const factory ContributionVm({
    required String periodLabel,
    required List<ContributionRow> rows,
    required String methodNoteText,
    required AsOf asOf,
    String? fxNoteText,
  }) = _ContributionVm;

  factory ContributionVm.fromJson(Map<String, dynamic> json) =>
      _$ContributionVmFromJson(json);
}

/// m2-8 F-4 — 슬리브 1행. 🔴 `normalized` 는 막대 폭 전용이고 표시는
/// `contributionText` 다(화면이 비율로 문장을 만들지 않는다).
@freezed
abstract class ContributionRow with _$ContributionRow {
  const factory ContributionRow({
    required SleeveId sleeve,

    /// "A · 국내 지수 ETF" — 엔진 생성(화면이 `sleeve` 로 문구를 고르지 않는다)
    required String label,

    /// "+0.42%p" · 산출 불가면 "산출 불가" — 엔진 생성
    required String contributionText,

    /// 막대 폭 전용(0.0~1.0). 🔴 [unavailableLabel] 이 non-null 이면 **0.0** 으로 온다.
    required double normalized,

    /// 🆕 v1.1(§8 미결 45) — 「이 슬리브는 산출할 수 없다」의 사유 한 줄
    ///    ("8월 12~14일 가격 결측 — 산출 불가"). 🔴 non-null 이면 **막대를 그리지 않고**
    ///    이 문장을 그린다. 🔴 화면이 나머지 행을 100% 로 재정규화하지 않는다(03 §8).
    String? unavailableLabel,
  }) = _ContributionRow;

  factory ContributionRow.fromJson(Map<String, dynamic> json) =>
      _$ContributionRowFromJson(json);
}

/// 01 §2-6 · m2-8 F-6 — 연간 리뷰(`S7-7`). 🔴 **묶음이지 재집계가 아니다** —
/// 화면이 `windowState` 를 «달»로 판정하지 않는다.
/// 🔴 세후는 `AfterTaxLadder` 를 그대로 실어 나르고 재계산하지 않는다(M1-20b).
/// 🆕 v1.6(01 §15-4) — `yearLabel` · 세후 두 갈래 `afterTax`·`afterTaxCounterfactual`(VM 최상위).
@freezed
abstract class AnnualReviewVm with _$AnnualReviewVm {
  const factory AnnualReviewVm({
    required String year, // 🔴 ui 미참조(C-42) — 표시는 [yearLabel]
    /// 🆕 v1.6(K24 · 비평 #9) — «2026년 연간 리뷰» — 엔진 생성 · 상단 첫 줄. 기본 연도를 엔진이 고르므로
    /// 어느 해인지 말하는 **유일한 글자**다(C-41 ⑥ — 비지 않음 ∧ [year] 를 품는다).
    required String yearLabel,
    required String windowStateCode, // 🔴 ui 미참조(C-42) — 표시는 [windowStateLabel]
    required String windowStateLabel, // 상단 고정 1줄
    required List<AnnualReviewSection> sections,
    required AsOf asOf,

    /// 🆕 v1.6 — 세후 사다리 본문 갈래(«묶음은 엔진» · `WithdrawalPlan.afterTax` 이름 선례). null = 블록 부재.
    /// 🆕 v1.24(01 §33 K118) — M9 `S12` 는 다른 타입 `AnnualReviewIndexVm`(세후 칸 0) · 이 타입의 소비자 = M7 `S7-7` 하나.
    AfterTaxLadder? afterTax,

    /// 🆕 v1.6 — 반사실 갈래. 🔴 non-null ⇒ [afterTax] non-null(C-41 ⑥) · 화면 = **늘 기본 접힘** 카드
    /// (접힘 값은 DTO 에 두지 않는다 — 봉투 형제 키 `counterfactual_collapsed` 는 C-30 대조 전용).
    AfterTaxLadder? afterTaxCounterfactual,
  }) = _AnnualReviewVm;

  factory AnnualReviewVm.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewVmFromJson(json);
}

/// m2-8 F-6 — 연간 리뷰 섹션. 🔴 `lines` 는 전부 엔진 완성 문자열이다.
@freezed
abstract class AnnualReviewSection with _$AnnualReviewSection {
  const factory AnnualReviewSection({
    required String code, // 🔴 ui 미참조(C-42)
    required String title,
    required List<String> lines,
    String? route,
  }) = _AnnualReviewSection;

  factory AnnualReviewSection.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewSectionFromJson(json);
}

/// 01 §2-6 · m2-8 F-15 · 🆕 v1.4 01 §14-10 — 목표 경로(`S7-9`).
/// 🔴 **01 §14-10 «필드 → 자리» 대응표가 정본**이다. 화면은 필드마다 정해진 한 자리에만 그린다.
/// 🔴 v1.4 — C-4 «`basisText`·`backtestBasisText` 를 동시에 그리지 않는다» 조문은 **폐기**됐다
///    (03 §14 가정 카드가 두 줄을 요구한다). 대신 역할을 고정한다: `basisText` = 판정 근거 줄 ·
///    `backtestBasisText` = 가정 카드 1줄 · `startingCapitalAssumptionText` = 가정 카드 2줄
///    (03 §14·§17-17 의 `contributionAssumptionText` 를 대체 · 01 §14 결정 뒤집기 기록).
/// 🔴 `honestExpectationText`·`honestExpectationWorstText` 는 세후 사다리 마지막 층을 인용하는
///    **완성 문장**이지 스칼라가 아니다 — 01 §2-6 «`PerfDisclosure` = 기대치 문구의 유일한
///    운반처(M7 한정)»의 **명시 예외**(01 §14 · 문자열 출처는 같은 엔진 상수 블록). 화면은 숫자를
///    옮겨 적지 않는다.
/// 🔴 `planned`·`actual` 은 `PerfPoint` 를 재사용한다(01 §13 세 식 준용 · C-39). 화면이 두 목록을
///    합치거나 차액·달성률을 계산하지 않는다.
/// 🔴 S7-9 는 `ConfigRepository` 를 읽지 않는다(03 §17-17 이 이긴다).
@freezed
abstract class GoalPathVm with _$GoalPathVm {
  const factory GoalPathVm({
    /// 🆕 v1.4 — 이 경로의 달(`yyyy-MM`). Key 용 · 🔴 표시 금지.
    required String yyyyMm,

    /// 🆕 v1.4 — «유지»/«이탈»/«판정 유보» 문장 — 엔진 생성.
    required String judgementText,

    /// 역할 고정(v1.4): **판정 근거 줄**.
    required String basisText,

    /// 🆕 v1.4 — 이탈 문장(구 봉투 `lag_notice` 승격) — null = 줄 부재.
    String? deviationText,

    /// 🆕 v1.4 — 이 경로가 덮는 기간 — 엔진 생성.
    required String periodLabel,

    /// 🆕 v1.4 — 범례: 계획선.
    required String plannedLabel,

    /// 🆕 v1.4 — 범례: 실제선.
    required String actualLabel,

    /// 🆕 v1.4 — 계획선. 🔴 `yNormalized` 결측 없음 · [actual] 과 같은 길이·date·xNormalized(C-39 ②).
    required List<PerfPoint> planned,

    /// 🆕 v1.4 — 실제선. 결측(`yNormalized == null`)은 선을 끊는다 — 보간 금지(C-10 준용).
    required List<PerfPoint> actual,

    /// 🆕 v1.4 — 세로축 눈금(아래 → 위) · 많아야 5개(C-39 ④).
    required List<PerfAxisTick> yTicks,

    /// 🆕 v1.4 — 갭·SIM 제외 띠 — 받은 순서 · 겹침 없음(C-39 ⑤).
    required List<PerfSegment> segments,

    /// 🆕 v1.4 — non-null ⇔ [planned]·[actual]·[yTicks]·[segments] 가 모두 빈 목록(C-39 ③).
    /// 그때는 차트 대신 이 문장 카드 1장이고 [deviationText] 는 null 이다.
    String? chartUnavailableLabel,

    /// 역할 고정(v1.4): **가정 카드 1줄**(백테스트 기준 실행).
    required String backtestBasisText,

    /// 역할 고정(v1.4): **가정 카드 2줄**(당신의 현재 원금·납입).
    required String startingCapitalAssumptionText,

    /// 🆕 v1.4 — 정직 기대 본값 **인용 문장**(위 예외 조문).
    required String honestExpectationText,

    /// 최악 가정 한 문장(인용 문장 · 위 예외 조문).
    required String honestExpectationWorstText,

    /// 🆕 v1.4 — «보증하지 않습니다» 엔진 고지.
    required String disclaimerText,
    required AsOf asOf,
  }) = _GoalPathVm;

  factory GoalPathVm.fromJson(Map<String, dynamic> json) =>
      _$GoalPathVmFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/plan.dart`

```dart
// 01 §2-6 — 미리보기 계획 스냅샷(M3·M7 요구 4 · Q-F)와 그 값 객체들.
// 🆕 v1.4(R11 선행 · 01 §14) — 입금 미리보기 결과 `DepositPreviewResult`(plan | 입력 거부 | 차단) ·
//    한도 카드 `PensionLimitVm` · `DepositPlan`·`OrderDraft`·`SleeveAllocation` 표시 필드.
//
// 🔴 **월 추가 납입 운영값을 화면(`ui_*/lib` · `labels.dart` 포함)·계약 코드에 상수로 적지
//    않는다**(01 §2-6 · C-32 · 🆕 v1.4 문구 통일 01 §14-13). 픽스처는 **폐기값만** 금지이고
//    금액 예시값은 하나를 쓴다(`fixture_conventions_test.dart` 머리 주석). 읽기 창구는
//    `ConfigRepository.watchContributionSetting()` 하나이고 변경 창구는 `SettingsActions`(운영 등급)다.
// 🔴 `fundingSteps` 가 null·빈 목록이면 화면은 그 절을 **통째로 숨긴다** —
//    0건을 「0원」으로 그리지 않는다(01 §2-6 v2.32 `PENSION_FUNDING`).
// 🔴 🆕 v1.4 — «읽지 않는 필드»(`/// 🔴 ui 미참조(C-38 ⑩)` 표식)는 엔진·명령·골든 대조 쪽 원값이다.
//    화면은 같은 뜻의 `*Text`·`*Label` 필드만 그린다(01 §14-4 · C-38 ⑩ 정규식과 **같은 목록**).
// 🆕 v1.6(01 §15-4 · R12 선행 · 발주자 결정 ②) — 리밸런싱 미리보기 결과 `RebalancePreviewResult`
//    (초안 | 차단) · `RebalancePreview` 표시 필드(`plannedDateText`·`asOf`·`orderDraftsTitle`·
//    `ordersEmptyText`·`warningLines`). `S7-6c` 의 «읽지 않는 필드»는 `// 🔴 ui 미참조(C-42)` 표식이다.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/journal.dart';
import '../enums/order.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'performance.dart';
import 'rebalance.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

/// 🆕 v1.4 · 01 §14-3 — 입금 미리보기 결과(`WhatIfApi.simulateDeposit` 의 반환).
/// 🔴 `plan` · `inputRejectedText` · `blockedText` 중 **정확히 하나** non-null(C-38 ①).
/// 🔴 `blockedAction` 은 `blockedText` 가 있을 때만 non-null 일 수 있다(null = 버튼 부재).
/// 🔴 화면은 셋 중 무엇이 non-null 인가로만 갈린다 — 문장을 해석하거나 flagId 로
///    진입을 막지 않는다(D21 · 03 §1-4 플래너 열 v1.4 재해석).
@freezed
abstract class DepositPreviewResult with _$DepositPreviewResult {
  const factory DepositPreviewResult({
    DepositPlan? plan,

    /// 빈칸·숫자 아님·0·범위 밖 — 엔진 판정. 화면 = 입력칸 바로 아래 1줄(스텝 ① 유지).
    String? inputRejectedText,

    /// 미리보기 차단(무결성·재개 미완·복구·계좌 매핑 미완) — 화면 = 문장 카드 1장(D21).
    String? blockedText,

    /// 차단 문장 카드의 이동 버튼 — 탭 = `AppLinkOpener.open(deepLink)` 그대로.
    LinkAction? blockedAction,
  }) = _DepositPreviewResult;

  factory DepositPreviewResult.fromJson(Map<String, dynamic> json) =>
      _$DepositPreviewResultFromJson(json);
}

/// 🆕 v1.6 · 01 §15-4 — 리밸런싱 미리보기 결과(`WhatIfApi.previewRebalance` 의 반환).
/// 🔴 [preview] · [blockedText] 중 **정확히 하나** non-null(C-41 ①). 입력 거부 갈래는 없다(입력이 없다).
/// 🔴 [blockedAction] 은 [blockedText] 가 있을 때만 non-null 일 수 있다(null = 버튼 부재 · C-38 ① 준용).
/// 🔴 화면은 둘 중 무엇이 non-null 인가로만 갈린다 — 문장을 해석하지 않는다.
@freezed
abstract class RebalancePreviewResult with _$RebalancePreviewResult {
  const factory RebalancePreviewResult({
    RebalancePreview? preview,

    /// 초안을 계산하지 않은 까닭(무결성·재개 미완·예정 없음 등) — 엔진 문장 · 화면 = 문장 카드 1장.
    String? blockedText,

    /// 차단 카드의 이동 버튼 — 탭 = `AppLinkOpener.open(deepLink)` 그대로.
    LinkAction? blockedAction,
  }) = _RebalancePreviewResult;

  factory RebalancePreviewResult.fromJson(Map<String, dynamic> json) =>
      _$RebalancePreviewResultFromJson(json);
}

/// 01 §2-6 — 입금 미리보기 계획.
/// 🔴 등록할 수 없는 계획(만료·정합 불일치·원장 정정 중·금액 범위 등)은 엔진이
///    [registerBlockedText] 로 말한다 — 화면이 `expiresAt` 을 시계와 비교하지 않는다.
/// 🆕 v1.4 — 표시 필드(01 §14-4 null 규칙 표). null 이면 **부재**, non-null 이면 그대로 그린다.
@freezed
abstract class DepositPlan with _$DepositPlan {
  const factory DepositPlan({
    /// 🔴 실입금 등록 시 바인딩(계획 대비 실제 대조) — `DepositRegistration(planId:)` 하나.
    required String planId,

    /// 🔴 ui 미참조(C-38 ⑩).
    required DateTime computedAt,

    /// 🔴 ui 미참조(C-38 ⑩). 기준일 표시는 [asOf] 의 `label` 이다.
    @TradeDateConverter() required TradeDate asOfTradeDate,

    /// 🔴 ui 미참조(C-38 ⑩) — 만료 판정은 엔진([registerBlockedText]).
    required DateTime expiresAt,
    required String configHash,

    /// 🆕 v1.4 — 봉투 `as_of` 를 행으로(스텝 ②③ 기준일 줄 · `StaleBanner`).
    required AsOf asOf,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [depositAmountText].
    @DecimalStringConverter() required Decimal depositAmount,

    /// 🆕 v1.4 — 워터폴 머리(입금액) — 엔진 생성.
    required String depositAmountText,

    /// 슬리브별 충당액 — m2-8 F-11.
    required List<SleeveAllocation> allocations,

    /// 🆕 v1.4 조문(01 §14-6) — 올해 연금저축+IRP **합산 납입 누계**(이번 입금 반영 후).
    /// 🔴 ui 미참조(C-38 ⑩). 한도 카드는 [pensionLimit] 이다.
    @DecimalStringConverter() required Decimal pensionLimitConsumed,

    /// 🆕 v1.4 — 한도 카드(03 §9 스텝 ②). null = 카드 부재.
    PensionLimitVm? pensionLimit,

    /// D2 = 원화 현금 대기(결정 7b). 🔴 유휴 자금이 아니다.
    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [residualKrwCashText].
    @DecimalStringConverter() required Decimal residualKrwCash,

    /// 🆕 v1.4 — 잔여 행 문장. null ⇔ 잔여 0 → **행 부재**(C-38 ②).
    String? residualKrwCashText,

    /// 🆕 v1.4 — 주문 초안 표 제목(«주문 초안» / advisory 이름) — 엔진 생성.
    required String orderDraftsTitle,
    required List<OrderDraft> orderDrafts,

    /// 🆕 v1.4 — non-null ⇔ [orderDrafts] 빈 목록(C-38 ②). 그때 표 대신 이 한 줄.
    String? ordersEmptyText,
    required CostEstimate costs,

    /// 🔴 v1.4 조문(01 §14-5) — «미리보기입니다…» 고지 **전용**. 경고·만료를 싣지 않는다.
    required String previewNotice,

    /// 🆕 v1.4 — 현금 부족·한도 초과 등 경고 문장 — **받은 순서** 그대로.
    @Default(<String>[]) List<String> warningLines,

    /// 🆕 v1.4 — non-null = 이 계획으로 등록할 수 없다(만료·정합 불일치·원장 정정 중·금액
    /// 범위 등 — 까닭은 엔진 문장). 화면 = 등록 섹션 자리에 이 1줄(등록 버튼 부재).
    /// 🔴 `expiresAt` 을 시계와 비교하지 않는다.
    String? registerBlockedText,

    /// 🆕 v2.32 연금 납입 조달 단계(§3-6 `PENSION_FUNDING`).
    /// 🔴 null·빈 목록 = 절을 통째로 숨긴다.
    List<FundingStep>? fundingSteps,
  }) = _DepositPlan;

  factory DepositPlan.fromJson(Map<String, dynamic> json) =>
      _$DepositPlanFromJson(json);
}

/// 🆕 v1.4 · 01 §14-4 — 한도 카드(03 §9 스텝 ② · 그림 M7-17 PANEL). 모든 줄이 **완성 문장**이다.
/// 🔴 화면이 금액·비율·D-day 를 계산하지 않는다.
@freezed
abstract class PensionLimitVm with _$PensionLimitVm {
  const factory PensionLimitVm({
    /// 연 합산 납입한도 대비 사용·남은 금액 한 줄.
    required String annualLimitText,

    /// 세액공제 구간 소진 한 줄.
    required String taxCreditText,

    /// 12월 마감 D-day 한 줄.
    required String deadlineText,

    /// 라우팅 제안 — null = 줄 부재.
    String? suggestionText,

    /// 조달 순서 안내 한 줄(그림 M7-17 PANEL · 03 §9) — null = 줄 부재.
    String? fundingNoteText,
  }) = _PensionLimitVm;

  factory PensionLimitVm.fromJson(Map<String, dynamic> json) =>
      _$PensionLimitVmFromJson(json);
}

/// 01 §2-6 — 주문 초안 1행.
/// 🆕 v1.4 — 표시 필드 4(`sideLabel`·`quantityText`·`limitPriceText`·`pendingNoteText`).
@freezed
abstract class OrderDraft with _$OrderDraft {
  const factory OrderDraft({
    required String symbol,
    required String symbolLabel,
    required SleeveId sleeve,

    /// 🔴 계좌 전체번호 금지 — 별칭만.
    required String accountAlias,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [sideLabel].
    required OrderSide side,

    /// 🆕 v1.4 — «매수»/«매도» — 엔진 생성.
    required String sideLabel,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [quantityText].
    required int quantity,

    /// 🆕 v1.4 — 수량 글자 — 엔진 생성.
    required String quantityText,

    /// 사유 칩. 🔴 플래너(S7-4)·`S7-6c` 는 `label`·`tone` 만 — `detailDeepLink` 는 읽지 않는다
    /// (D20 · §8 미결 81).
    required List<ReasonChip> reasons,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [limitPriceText].
    @DecimalStringConverter() Decimal? limitPrice,

    /// 🆕 v1.4 — 지정가 글자. non-null ⇔ [limitPrice] != null(C-38 ② · 🆕 v1.6 C-41 ② ·
    /// `DepositPlan`·`RebalancePreview`(인출 초안 제외) —
    /// 인출 초안(`WithdrawalPlan.orderDrafts`)은 인출 규칙 결정 뒤 첫 minor 재생성 전까지 이 짝을 지키지 않는다 · 01 §14-4 · §14-15).
    String? limitPriceText,

    /// 🆕 v1.4 — «미확정 수량 있음»(UNKNOWN 표기) 한 줄 — null = 줄 부재.
    String? pendingNoteText,
  }) = _OrderDraft;

  factory OrderDraft.fromJson(Map<String, dynamic> json) =>
      _$OrderDraftFromJson(json);
}

/// 01 §2-6 · m2-8 F-11 — 플래너 충당액 1행.
/// 🔴 `SleeveAllocationRow`(배분 현황 행 · `rebalance.dart`)와 **다른 타입**이다.
@freezed
abstract class SleeveAllocation with _$SleeveAllocation {
  const factory SleeveAllocation({
    required SleeveId sleeve,
    required String label,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [amountText].
    @DecimalStringConverter() required Decimal amount,

    /// 🔴 표시의 정본 — 화면이 금액을 포맷하지 않는다.
    required String amountText,
    String? accountAlias,

    /// 🆕 v1.4 — 이 슬리브가 이 계좌로 간 까닭 한 줄 — null = 줄 부재.
    String? routingReasonText,
  }) = _SleeveAllocation;

  factory SleeveAllocation.fromJson(Map<String, dynamic> json) =>
      _$SleeveAllocationFromJson(json);
}

/// 01 §2-6 · m2-8 F-12 — 비용 추정(C18).
/// 🔴 구 `costsOverridden`(bool)은 폐기됐고 출처는 `CostSource` 가 말한다.
@freezed
abstract class CostEstimate with _$CostEstimate {
  const factory CostEstimate({
    /// 🔴 ui 미참조(C-38 ⑩) — 수수료·세금 따로 표시는 v1.4 범위 밖(01 §8 미결 70).
    @DecimalStringConverter() required Decimal commission,

    /// 🔴 ui 미참조(C-38 ⑩).
    @DecimalStringConverter() required Decimal tax,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [totalText].
    @DecimalStringConverter() required Decimal total,
    required String totalText,
    required CostSource source,
    required String sourceLabel,
    required String basisNote,
  }) = _CostEstimate;

  factory CostEstimate.fromJson(Map<String, dynamic> json) =>
      _$CostEstimateFromJson(json);
}

/// 01 §2-6 · m2-8 C-3 — 연금 납입 조달 1단계(SPEC v2.32 · 03 §5-5b).
/// C 원화현금이 부족할 때 «무엇을 얼마나 팔아 납입했는지»를 순서대로 담는다.
@freezed
abstract class FundingStep with _$FundingStep {
  const factory FundingStep({
    /// 🔴 실행 순서. 화면이 정렬 키를 만들지 않는다.
    required int order,

    /// 🔴 ui 미참조(C-38 ⑩).
    required SleeveId sourceSleeve,

    /// 🔴 ui 미참조(C-38 ⑩).
    required int quantity,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [label] 문장 안이다.
    @DecimalStringConverter() required Decimal expectedProceeds,

    /// 근거 규칙 코드 — 🔴 엔진 제공 목록의 값이며 자유 입력이 아니다.
    /// 🔴 ui 미참조(C-38 ⑩) — 🆕 v1.4 조문: 화면에 표시하지 않는다.
    required String ruleCited,

    /// 엔진 생성 한 줄.
    required String label,
    String? symbol,
    String? symbolLabel,
  }) = _FundingStep;

  factory FundingStep.fromJson(Map<String, dynamic> json) =>
      _$FundingStepFromJson(json);
}

/// 01 §2-6 · m2-8 F-13 — 인출 미리보기(`DepositPlan` 대칭).
/// ⏸ v1.4 무변경 — S7-5 는 인출 규칙 결정 뒤 첫 minor(01 §14-15 «예정» · 인출 규칙 발주자 결정 뒤)에서 바뀐다
///    (`WithdrawalPreviewResult` · `steps` · orderDrafts·costs·afterTax 제거).
@freezed
abstract class WithdrawalPlan with _$WithdrawalPlan {
  const factory WithdrawalPlan({
    required String planId,
    required DateTime computedAt,
    required DateTime expiresAt,
    @DecimalStringConverter() required Decimal amount,
    required List<OrderDraft> orderDrafts,
    required CostEstimate costs,
    required String previewNotice,
    required String configHash,

    /// 🔴 세후는 층이다 — 단일 스칼라 필드를 만들지 않는다(§2-4).
    AfterTaxLadder? afterTax,
  }) = _WithdrawalPlan;

  factory WithdrawalPlan.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalPlanFromJson(json);
}

/// 01 §2-6 · m2-8 F-14 — 리밸런싱 미리보기. 🆕 v1.6 표시 필드(01 §15-4 필드 → 자리 표).
/// 🔴 `DepositPlan` 과 **같은** `fundingSteps` 를 싣는다(v2.32).
@freezed
abstract class RebalancePreview with _$RebalancePreview {
  const factory RebalancePreview({
    /// 🔴 ui 미참조(C-42).
    required String planId,

    /// 🔴 ui 미참조(C-42) — 표시는 [plannedDateText].
    @TradeDateConverter() required TradeDate plannedDate,

    /// 🆕 v1.6 — «2026년 9월 1일 회차» — 엔진 생성(초안 머리 1줄).
    required String plannedDateText,

    /// 🆕 v1.6 — 초안의 기준 시각(봉투 as_of 를 행으로 · `DepositPlan.asOf` 선례).
    required AsOf asOf,

    /// 🔴 ui 미참조 — R12 는 전후 비중을 그리지 않는다(§8 미결 92).
    required List<SleeveWeight> before,
    required List<SleeveWeight> after,

    /// 🆕 v1.6 — 주문 초안 표 제목(«주문 초안» / advisory 이름) — 엔진 생성.
    required String orderDraftsTitle,
    required List<OrderDraft> orderDrafts,

    /// 🆕 v1.6 — non-null ⇔ [orderDrafts] 빈 목록(C-41 ②). 그때 표 대신 이 한 줄.
    String? ordersEmptyText,
    required CostEstimate costs,

    /// «미리보기입니다…» 고지 **전용**(v1.4 §14-5 준용).
    required String previewNotice,

    /// 🆕 v1.6 — 경고 문장 — **받은 순서** 그대로.
    @Default(<String>[]) List<String> warningLines,

    /// 🔴 ui 미참조 — R12 는 조달 절을 그리지 않는다(§8 미결 92). null·빈 목록 규약은 그대로.
    List<FundingStep>? fundingSteps,
  }) = _RebalancePreview;

  factory RebalancePreview.fromJson(Map<String, dynamic> json) =>
      _$RebalancePreviewFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/postmortem.dart`

```dart
// 🆕 계약 v1.39(01 §48 · K345 · 01 §8 미결 188 · 230 ⓑ · 13 §8 R243 P3) — `M5-4` 안전 사건 postmortem 목록 + 쓰기 한 화면.
//
// 🔴 쓰기 = 기존 `SafetyActions.runPostmortem(PostmortemSubmission{incidentId, text})`(v1.22 · 결과 `PostmortemResultCodes` 3 · C-7 표면
//    무변경) — 이 VM 은 «무엇을 · 언제까지 써야 하는가»와 제출에 넘길 [PostmortemRow.incidentId] 원천이다.
// 🔴 행 = 열린 사건 가운데 postmortem 칸이 있는 것(SEV1 STOPPED · SEV2 수동 주문 — 엔진 `openIncidentsOf` + postmortem 칸) · 차례 = 엔진
//    (`compareIncidentUrgency` — 심각도 → 기한 → 연 시각 → id) · 화면은 재정렬 · 거르기 · 세기 0.
// 🔴 한 번만 쓴다(`POSTMORTEM_ALREADY_RECORDED`) — 쓴 행 = [PostmortemRow.writtenText] 읽기 전용 · [PostmortemRow.form] null.
//    SEV1 은 써도 열린 채(닫기 = `M5-3` STOPPED 결정) → [PostmortemRow.nextLink] = `m5StoppedDecision`(본문 있을 때만).
// 🔴 기한 = 엔진 상수(SEV1 3일 · SEV2 7일 — 03_운영 §4-6) · 이 계약에 수치 0 · 글자만(«기한 11-27 18:00» · «기한이 지났습니다»).
// 🔴 뷰어 = 부재(폰 전용 · 읽기 모델 열 0 · `ui_safety` 만).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart';

part 'postmortem.freezed.dart';
part 'postmortem.g.dart';

/// 쓰기 칸 하나(쓸 차례인 행만).
@freezed
abstract class PostmortemForm with _$PostmortemForm {
  const factory PostmortemForm({
    /// «무슨 일이 있었고, 무엇을 바꾸겠습니까?» — 엔진.
    required String promptText,

    /// 입력 칸 안내(엔진) · null = 없음.
    String? hintText,

    /// «한 번만 씁니다 — 고칠 일은 새 저널로» — 엔진 · null = 없음.
    String? noticeText,

    /// 저장 버튼 글자 «postmortem 저장» — 엔진(🔴 칸 이름에 쓰기 동사 0 — C-7).
    required String buttonLabel,
  }) = _PostmortemForm;

  factory PostmortemForm.fromJson(Map<String, dynamic> json) =>
      _$PostmortemFormFromJson(json);
}
// JSON 키: prompt_text · hint_text · notice_text · button_label

/// 사건 한 건.
/// 🔴 불변식(C-72 ⑥): [form] non-null ⇒ [writtenText] null · [incidentId] 빈칸 금지 · [nextLink] 목적지 = `AppRoutes.m5StoppedDecision`.
@freezed
abstract class PostmortemRow with _$PostmortemRow {
  const factory PostmortemRow({
    /// 제출 DTO `PostmortemSubmission.incidentId` 로 그대로 넘긴다 — 🔴 화면 미표시 · 해석 0.
    required String incidentId,

    /// «서킷브레이커 STOPPED» · «수동 주문 1건» — 엔진(금액 0).
    required String title,

    /// «SEV1» · «SEV2» — 엔진 글자(화면은 분기 0).
    required String severityLabel,

    /// 색에만(`blocked` · `act` · `info`).
    required UiLevel level,

    /// «11-20 10:12 발생» — 엔진.
    required String occurredText,

    /// «기한 11-23 10:12» · «기한이 지났습니다» — 엔진 · null = 기한 없음(쓴 행).
    String? dueText,

    /// 기한이 지났다(색 · 정렬 아님 — 정렬은 엔진).
    required bool overdue,

    /// «쓸 차례» · «썼습니다 — STOPPED 결정이 닫습니다» — 엔진.
    required String stateLabel,

    /// 쓴 글(읽기 전용 · 원문 그대로) · null = 아직 안 씀.
    String? writtenText,

    /// 쓰기 칸 · null = 이미 썼다(또는 쓸 수 없는 자리).
    PostmortemForm? form,

    /// SEV1 을 쓴 뒤 «STOPPED 결정으로» — 엔진(목적지 본문 있을 때만) · null = 부재.
    LinkAction? nextLink,
  }) = _PostmortemRow;

  factory PostmortemRow.fromJson(Map<String, dynamic> json) =>
      _$PostmortemRowFromJson(json);
}
// JSON 키: incident_id · title · severity_label · level · occurred_text · due_text · overdue · state_label · written_text · form · next_link

/// `M5-4` 한 화면(목록 + 쓰기).
/// 🔴 불변식(C-72 ⑥): [rows] 빔 ⇔ [emptyLabel] non-null.
@freezed
abstract class PostmortemListVm with _$PostmortemListVm {
  const factory PostmortemListVm({
    /// «써야 할 postmortem 1건» · «써야 할 postmortem 이 없습니다» — 엔진.
    required String headline,
    required UiLevel level,

    /// 차례 = 엔진(심각도 → 기한 → 연 시각 → id).
    required List<PostmortemRow> rows,

    /// 행 0 일 때만 — 엔진.
    String? emptyLabel,
    required AsOf asOf,
  }) = _PostmortemListVm;

  factory PostmortemListVm.fromJson(Map<String, dynamic> json) =>
      _$PostmortemListVmFromJson(json);
}
// JSON 키: headline · level · rows · empty_label · as_of
```

---

## `packages/domain_contracts/lib/src/dto/rebalance.dart`

```dart
// 01 §2-5 — 리밸런싱(M7 요구 5) · §2-6 배분 현황 행(P 회차) · 다음 회차 예고.
//
// 🔴 `SleeveWeight.basis` 는 `accounting` 외 값을 갖지 않는다(01 §2-5). 엔진 원장
//    열의 값은 `SleeveAllocationRow.engineColumnNote`(문자열)로만 흐르며, 두 기준을
//    한 표에 섞어 합계 100% 를 만들지 않는다 — C-31 이 basis 혼합과 `A + POT`
//    산술을 탐지한다.
// 🔴 P 회차 실측 수치(엔진 열 vs 회계 열)를 코드·주석에 상수로 옮기지 않는다.
// 🆕 v1.6(01 §15-4 · R12 선행) — `RebalanceEvent.thresholds`(J-2 `ThresholdCompare` 재사용 · `common.dart`)·
//    `modeLabel`·`sectionLabel` · `asOf` = 읽기 모델 관측 시각 · `SleeveWeight.label` = 완성 문장 ·
//    `NextRebalanceVm` 두 글자 nullable + `asOf`. 🔴 `// 🔴 ui 미참조(C-42)` 표식 = R12 화면이 읽지 않는 원값.
// 🆕 v1.8(01 §17 · R4 선행) — `SleeveAllocationRow` 밴드 축 +7(비율 2 nullable) · `SleeveBandGauge` ·
//    `SleeveAllocationVm`(`H6-3`). 🔴 `// 🔴 ui 미참조(C-44)` 표식 = `H6-*` 화면이 읽지 않는 원값.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/rebalance.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'rebalance.freezed.dart';
part 'rebalance.g.dart';

/// 01 §2-5 — 리밸런싱 1회차.
/// 🆕 v1.6(01 §15-4) — `thresholds`·`modeLabel`·`sectionLabel` · `asOf` 뜻 고정(관측 시각).
@freezed
abstract class RebalanceEvent with _$RebalanceEvent {
  const factory RebalanceEvent({
    required String eventId, // 🔴 표시 금지 · Key 전용
    required RunMode mode, // 🔴 ui 미참조(C-42) — 배지는 [modeLabel]
    // 표시 = `tradeDate.yyyyMmDd` 그대로(카드 예외 1개)
    @TradeDateConverter() required TradeDate tradeDate,
    required RebalanceKind kind, // 🔴 ui 미참조(C-42) — 칩은 [kindLabel]
    /// 엔진 생성.
    required String kindLabel,
    required List<SleeveWeight> before,
    required List<SleeveWeight> after,

    /// 당시 국면·신호 원값·밴드 여유.
    required TriggerSnapshot trigger,
    required List<String> orderIntentIds, // 🔴 ui 미참조(C-42 · C-40 ⑧)
    /// 🆕 v1.6 뜻 고정(01 §15-4) — **읽기 모델의 관측 시각**(마지막 배치) = 목록 봉투 `as_of` 와
    /// 같은 값. 회차 시각이 아니다(회차 일자 = [tradeDate]). `S7-6b` 하단·StaleBanner 의 원천.
    required AsOf asOf,

    /// 실측 슬리피지 vs 가정치·미체결률 — m2-8 F-10. null = 패널 부재.
    ExecutionQuality? quality,

    /// 🆕 v1.6 — 사전 등록 임계 ↔ 실제값 대조(03 §11-b 수용 (a) · J-2 `DecisionDetailVm.thresholds`
    /// 와 같은 타입) · 엔진 포맷 행 · 0건 = 표 부재.
    /// 🔴 비어 있지 않음 ⇔ `trigger.thresholdRegistered != null`(C-41 ④).
    required List<ThresholdCompare> thresholds,

    /// 🆕 v1.6 — 「모의」 배지 글자. non-null ⇔ `mode != LIVE`(C-41 ④). 🔴 화면이 `mode` 로 고르지 않는다.
    String? modeLabel,

    /// 🆕 v1.6 — non-null 이면 **이 행 위에** 머리글 1줄(«모의투자 회차»). 같은 모드 묶음의 첫 행에만
    /// 엔진이 싣는다 — 화면은 앞 행과 비교하지 않는다(`ReportArchiveRow.sectionLabel` 선례).
    /// 🔴 LIVE·SIM 이 섞인 목록에서 «시간 역순»과 «모드 묶음의 첫 행»은 함께 성립하지 않는다 —
    ///    섞인 목록의 정렬 키는 §8 미결 89 · 그때까지 표본은 SIM 단독 봉투(C-41 ④ 한정 · 비평 #23).
    String? sectionLabel,

    /// 🆕 v1.5(01 §15-3 · §8 미결 49) — `S7-6b` 하단 «이 회차의 … N건» 버튼 **하나**
    /// (목적지 = `J-1` 회차 조건 · `AppRoutes.journalRebalance` 를 엔진이 완성).
    /// `label` = 엔진 완성 문장. N = 그 회차에 묶인 일지 행 **전체** 수(정정 행 포함 · 기간 무관) —
    /// 링크가 처음 여는 목록의 행 수와 같다(씨앗 기간 = `JournalRebalanceScope.range`).
    /// 낱말(자동 갈래 «주문» · advisory 갈래는 행을 가리키는 말 — 03 §11-d)도 이 글자 안에서 끝난다.
    /// 🔴 null = 버튼 **부재**(비활성 아님) — 엔진은 그 회차에 묶인 일지 행이 0 이면 null 로 준다.
    /// 🔴 화면이 `orderIntentIds.length` 로 N 을 세거나 `eventId` 로 링크를 조립하면 반려.
    LinkAction? journalTimelineLink,

    /// 🆕 v1.5(01 §15-3) — `S7-6a` 행 탭 → `S7-6b`(`AppRoutes.rebalanceEvent` 를 엔진이 완성).
    /// 🔴 null 이면 행 탭에 반응이 없다. 화면이 `eventId` 로 링크를 조립하지 않는다.
    /// `S7-6b` 안에서는 쓰지 않는다(자기 자신 — `TradeJournalEntry.detailDeepLink` 와 같은 규약).
    String? detailDeepLink,
  }) = _RebalanceEvent;

  factory RebalanceEvent.fromJson(Map<String, dynamic> json) =>
      _$RebalanceEventFromJson(json);
}

/// 01 §2-5 — 슬리브 비중 1행. 홈의 «목표 대비 편차·밴드 여유»가 이 타입이다.
/// 🔴 `basis` 는 M2-2 배치 전까지 **nullable** 이며 null = 미표기 →
///    목표·밴드와 비교하지 않는다. 승격은 M2 하나가 하며, 올리면 이 타입을
///    싣는 모든 픽스처·C-1 골든이 동시에 깨진다(01 §2-5).
@freezed
abstract class SleeveWeight with _$SleeveWeight {
  const factory SleeveWeight({
    required SleeveId sleeve, // 🔴 ui 미참조(C-42 ⑧)
    required double weight, // 🔴 ui 미참조(C-42) — 표시는 [label]
    required double targetWeight, // 〃
    required double bandLow, // 〃
    required double bandHigh, // 〃
    /// "B 42.0% (목표 42.0%, 밴드 여유 1.8%p)" — 엔진 생성.
    ///
    /// 🆕 v1.6 뜻 고정(정본 = 이 타입 머리 «목표 대비 편차·밴드 여유» + 기존 예시 «B 42.0% (목표 42.0%,
    /// 밴드 여유 1.8%p)»의 요소) — 이 행의 **완성 문장**: 현재·목표·편차·밴드 여유를 엔진이 한 줄에 담고,
    /// 밴드 밖이면 여유 자리에 초과폭을 말한다(«B 42.0% (목표 42.0%, 편차 0.0%p, 밴드 여유 5.0%p)» ·
    /// «B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 0.8%p 초과)»). 🔴 이름만 싣지 않는다(C-41 ④ `%`).
    /// 🔴 기존 주석 예시(:75)는 바꾸지 않는다 — 홈 블록 4 가 같은 타입이다(K11 · 비평 #13).
    required String label,

    /// 🆕 P 회차 — 기준 축. 🔴 `accounting` 외 값을 갖지 않는다.
    AllocationBasis? basis,
  }) = _SleeveWeight;

  factory SleeveWeight.fromJson(Map<String, dynamic> json) =>
      _$SleeveWeightFromJson(json);
}

/// 01 §2-5 — 판정 근거 스냅샷. 🔴 수치는 전부 엔진이 포맷한 문자열이다.
@freezed
abstract class TriggerSnapshot with _$TriggerSnapshot {
  const factory TriggerSnapshot({
    required String configHash,

    /// 지표명 → 엔진 포맷 문자열. 계절 게이트 키는 `trend_score_kr`.
    /// 🔴 ui 미참조(C-42 · J-2 ⓒ).
    required Map<String, String> rawValues,

    /// 엔진 생성 한 줄.
    required String summary,

    /// 🔴 ui 미참조(C-42 · J-2 ⓒ).
    @DecimalStringConverter() Decimal? triggerPrice,

    /// 🔴 사전 등록 임계값 — 사후 변경 감사용.
    /// 🔴 ui 미참조(C-42 · J-2 ⓒ) — 표시는 `RebalanceEvent.thresholds`(v1.6).
    double? thresholdRegistered,
  }) = _TriggerSnapshot;

  factory TriggerSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TriggerSnapshotFromJson(json);
}

/// 01 §2-5 · m2-8 F-10 — 실행 품질. 🔴 실측 vs 가정치 비교 문장도 엔진이 만든다.
@freezed
abstract class ExecutionQuality with _$ExecutionQuality {
  const factory ExecutionQuality({
    required String slippageText,
    required String assumedSlippageText,
    required String unfilledRateText,
    required String summary,
  }) = _ExecutionQuality;

  factory ExecutionQuality.fromJson(Map<String, dynamic> json) =>
      _$ExecutionQualityFromJson(json);
}

/// 01 §2-6 · m2-8 C-7 · E-7 — 배분 현황 1행(`H6-1` 카드 머리 · `H6-3` 행). 🆕 v1.8(01 §17) — 밴드 축.
/// 🔴 `SleeveWeight`·`AllocationBasis` 와 **같은 파일**에 둔다 — C-31 이 한 트리에서 basis 혼합을 검사할 수 있어야 한다(E-7).
/// 🔴 `SleeveAllocation`(플래너 충당액 · `plan.dart`)과 **다른 타입**이다.
/// 🔴 홈 블록 4(M8 `H-01`)가 재사용할 때는 [sleeveWeight] · [deployedPctText] · [parkingPctText] 만(금액 문자열 금지 — 04 §2-6).
@freezed
abstract class SleeveAllocationRow with _$SleeveAllocationRow {
  const factory SleeveAllocationRow({
    required SleeveId sleeve, // 🔴 ui 미참조(C-44 · C-42 ⑧ 와 같은 뜻)
    required AllocationBasis basis, // 🔴 ui 미참조
    /// 투입분 금액 문자열 — 🔴 홈으로 새면 04 §2-6 금지에 걸린다 · INTEGRITY "숨김".
    required String deployedText,
    required String parkingText,

    /// 🔴 막대 세그먼트 **기하 전용**(× 폭만). 여집합 `1 − x` 를 화면이 계산하지 않도록 두 값을 모두 준다.
    /// 🆕 v1.8 nullable — 둘 다 null ⇔ 막대 **부재**(`LEDGER_INTEGRITY` 가림 · C-44 ⑥ · RECON 은 유지).
    /// 🔴 [gauge] 와 **다른 막대**다(계좌 잔고 막대 · 합 1 · 파킹 = 회색 세그먼트 — 02:1349) — 두 값을 한 식에서 곱하지 않는다(C-44 ⑯).
    double? deployedRatio,
    double? parkingRatio,
    required String trancheStateText,

    /// 🔴 홈 재사용은 **비중(%) 전용 필드**로만 한다(금액 문자열 금지).
    required String deployedPctText,
    required String parkingPctText,

    /// POT → A 의 하위 행(회계 소속 · 03 §2-9-3). 🔴 화면은 null 여부(들여쓰기)만 본다.
    SleeveId? parentSleeve,

    /// 엔진 원장 열 값의 유일한 출구 — 🔴 문자열이며 비교·합산하지 않는다.
    String? engineColumnNote,
    String? parkingNoteText,

    // ── 🆕 계약 v1.8(01 §17 · R4 선행) ─────────────────────────────────────
    /// "슬리브 A" · "POT 서브북 (A 하위)" · "원화 현금 대기" — 엔진 생성.
    required String sleeveLabel,

    /// 목표·밴드 대비 — `label` = v1.6 완성 문장(현재·목표·편차·밴드 여유 · 밖이면 초과폭). 원값 4 는 ui 미참조.
    /// 🔴 이름 = `sleeveWeight` — `weight` 로 두면 `SleeveWeight.weight` 원값 금지(C-44 ⑮ `\.weight\b`)가 표시 경로까지 막는다.
    /// 🔴 `basis` 는 행과 같은 `accounting` 만(C-44 ⑥ · 02 `H6-3` 수용 (a)).
    /// null = 밴드 판정 없음 — 밴드가 없는 슬리브(K27 권고 = A·C) · POT · CASH · INTEGRITY 가림 → [bandNoteText].
    SleeveWeight? sleeveWeight,

    /// 🔴 색의 **유일한** 원천 — 화면 임계값·편차 부호로 색을 고르지 않는다(02 §4-3 수용 (b) · 04 §4-3). non-null ⇔ [sleeveWeight] non-null.
    SleeveBandState? bandState,

    /// "밴드 내" · "경계 근접" · "밴드 이탈 — 다음 배치에서 리밸런싱 대상"(🔴 실행 예고 아님). non-null ⇔ [bandState] non-null.
    String? bandStateLabel,

    /// 목표 막대 기하 — null = 게이지 부재(밴드 판정 없음 · INTEGRITY 가림). non-null ⇒ [sleeveWeight] non-null. RECON = 기하 유지·글자만 «?».
    SleeveBandGauge? gauge,

    /// non-null ⇔ [sleeveWeight] == null — 🔴 그 행의 현재 비중 글자의 **유일한 출구**(INTEGRITY 가림 외에는 `%` 를 품는다 · C-44 ⑥ · 04:464)
    /// — "C ‹n›% · 목표 잔여 — 게이지 없음" · "A ‹n›% · 목표 20.0% — 계절 슬리브 · 밴드 판정 없음"(K27) · "POT ‹n›% — A 에 포함(회계 기준)" ·
    ///   "원화 현금 대기 ‹n›% — 유휴가 아닙니다"(‹n› = 엔진 값 · 픽스처는 합성 둥근 값 · 🔴 골든 4자리 수치를 주석에 옮기지 않는다).
    String? bandNoteText,

    /// 상태 칩(계절 진입 게이트 보류 등 · 칩 탭 = `detailDeepLink` 의 핸드북) — 0개 = 칩 줄 부재(K13).
    @Default(<ReasonChip>[]) List<ReasonChip> stateChips,
  }) = _SleeveAllocationRow;

  factory SleeveAllocationRow.fromJson(Map<String, dynamic> json) =>
      _$SleeveAllocationRowFromJson(json);
}

/// 🆕 v1.8 — 목표 막대 위 실제 마커·밴드 음영의 **정규 위치**(0.0~1.0 · 엔진이 고른 눈금).
/// 🔴 화면 산술 = `값 × 폭` 하나(02 §2-4 금지 ① 의 «레이아웃 계산» · 01 §13-2 세 식 준용) — 차·여유 폭 계산 0.
/// 🔴 `bandLowNormalized ≤ targetNormalized ≤ bandHighNormalized`(C-44 ⑥) · 이름 = `*Normalized`(계약 관례 `xNormalized`·`complianceRateNormalized` —
///    [0,1] 범위는 C-34 ④ 가 키 끝 `normalized` 로 자동 검사) · 🔴 계좌 잔고 막대(`deployedRatio`·`parkingRatio`)와 다른 막대 — 둘을 곱하지 않는다.
@freezed
abstract class SleeveBandGauge with _$SleeveBandGauge {
  const factory SleeveBandGauge({
    required double actualNormalized,
    required double targetNormalized,
    required double bandLowNormalized,
    required double bandHighNormalized,
  }) = _SleeveBandGauge;

  factory SleeveBandGauge.fromJson(Map<String, dynamic> json) =>
      _$SleeveBandGaugeFromJson(json);
}

/// 🆕 v1.8 — `H6-3` 슬리브·비중 한 화면(01 §17). 창구 = `HoldingsRepository.watchAllocation()`.
/// 🔴 행 = 받은 순서(A → POT(A 하위) → B → C → 현금 대기) · 전부 `basis == accounting`(C-31) ·
///    POT 는 독립 항이 아니다(02 §4-3 수용 (e)) — 화면은 합계 행을 만들지 않는다.
@freezed
abstract class SleeveAllocationVm with _$SleeveAllocationVm {
  const factory SleeveAllocationVm({
    required List<SleeveAllocationRow> rows,

    /// "회계 기준입니다 — POT 는 A 에 포함됩니다" — null = 줄 부재.
    String? noticeText,

    /// non-null ⇔ [rows] 가 빈 목록.
    String? emptyLabel,
    required AsOf asOf,
  }) = _SleeveAllocationVm;

  factory SleeveAllocationVm.fromJson(Map<String, dynamic> json) =>
      _$SleeveAllocationVmFromJson(json);
}

/// 01 §4-1 · m2-8 F-5 — 다음 회차 예고(`S7-6c`·`H-02`).
/// 🔴 리포지토리 반환은 **nullable 이 아니다**(N-4) — 「예정 없음」도 값으로 오며
///    그때 `emptyLabel` 이 non-null 이면 카운트다운 카드를 그리지 않고 이 문장만
///    그린다(계약 3조 ③).
/// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지
///    않는다.
@freezed
abstract class NextRebalanceVm with _$NextRebalanceVm {
  const factory NextRebalanceVm({
    /// 🆕 v1.6 nullable — null ⇔ [emptyLabel] non-null(C-41 ③). 엔진 생성 · 화면이 날짜를 빼지 않는다.
    String? expectedDateText,
    String? dDayText,

    /// non-null = «예정 없음» — 화면은 이 문장**만** 그린다(카운트다운·초안 버튼 부재).
    String? emptyLabel,
    RebalanceKind? expectedKind, // 🔴 ui 미참조(C-42)
    String? kindLabel, // null = 줄 부재
    /// 🔴 `S7-6c` 안에서 쓰지 않는다(자기 자신 · `H-02`·알림 행·M6 `H6-3` 하단 몫) · non-null 이면 `AppRoutes.rebalancePreview`.
    String? previewRoute,
    String? noticeText, // null = 줄 부재
    /// 🆕 v1.6 — 봉투 as_of 를 행으로(`DepositPlan.asOf` 선례 · `H-02` 도 같은 필드).
    required AsOf asOf,
  }) = _NextRebalanceVm;

  factory NextRebalanceVm.fromJson(Map<String, dynamic> json) =>
      _$NextRebalanceVmFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/repair.dart`

```dart
// 🆕 계약 v1.32(01 §41 · K247~K263 · E16j-a) — X5 정정 마법사(`X5-3` · 🔒 `ui_safety`) 한 화면.
//
// 허브(`x5RepairWizard` · 열린 대상 고르기)와 대상 화면(`x5RepairTarget/:targetId` · 시작 → 원인 → 마찰 1~5 → 실행 / 아무것도 안 하기)이
// 같은 VM 을 쓴다(창구 = `RepairWizardRepository.watchRepair({targetId})` · 폰 전용).
// 🔴 문장 · 라벨 · 시각 글자 = 엔진 · `code`/`reasonCode` 칸 = 화면 미참조(표본 · 사전 검사용) · 색 = `level` 하나.
// 🔴 동작 = 엔진이 완성한 `SafetyActionCall`(그대로 `SafetyActions.run`) 또는 제출 DTO(`runRepairCorrect` · `runRepairBaseline` ·
//    `runInterventionJournal`) — 화면은 id · args 를 짓지 않는다.
// 🔴 발주자 수치(냉각 24h · 정정 체인 상한 · 실행 창) = 엔진 글자로만(칸 0) · 정정은 되돌리지 않는다(정정의 정정만 · 엔진 문장).
// 🔴 정정 커밋 ↔ 개입 세션 5단계 결속 · 체결 후보 목록 · 직전 재대사 = 엔진 숙제(01 §8 미결 217) — 그 전에는 엔진이 이 VM 을 내지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'ledger.dart'; // LedgerDiffRow

part 'repair.freezed.dart';
part 'repair.g.dart';

/// X5 정정 마법사 한 화면(허브 · 대상 공용).
///
/// 🔴 허브 = [targetLinks] 비지 않음 · 그때 [diff] · [stages] · [origins] · 동작 0.
/// 🔴 [lockedLabel] · [doneLabel] · [x1GuideLink] 가 non-null 이면 동작 0([doNothingAction] · [correction] · [baselineLabel] · [stages] 의 동작).
/// 🔴 [correction](정본 정정 · diff 갈래)과 [baselineLabel](새 기준점 · 무결성 갈래)은 동시에 non-null 이 아니다.
@freezed
abstract class RepairWizardVm with _$RepairWizardVm {
  const factory RepairWizardVm({
    /// 허브 문장 · diff 요약 · 경계 문장 — 엔진.
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `LedgerBoundaryReasonCodes` ∪ `RepairResultCodes` ∪ `BaselineResultCodes` ∪ `BaselineApplyResultCodes`.
    String? reasonCode,

    /// 허브만 — 열린 대상마다 하나(→ `x5RepairTarget` · 엔진이 인자를 완성). 대상 화면 = 빈 목록.
    required List<LinkAction> targetLinks,

    /// 탐지 시점 근거(L-1 행 재사용 · 🔴 그 안의 `actionLink` = null). 무결성 갈래 · 허브 = null.
    LedgerDiffRow? diff,

    /// 대상 요약 — 무결성 첫 어긋난 날 · 사유 · 대상 체결 요약(엔진 글자).
    required List<String> targetLines,

    /// 처음 고른 칸이 «아무것도 안 하기»인가(FILL_LAG · 현금 축 — 엔진 `defaultRepairChoiceOf`). 🔴 글자를 고르는 데 쓰지 않는다.
    required bool doNothingDefault,

    /// 고를 수 있는 원인 — 정정 = 쌍 쓰기 목록 · 새 기준점 = 3종 ∩ 경계 후보(엔진). 🔴 자유 서술 0.
    required List<RepairOriginChoice> origins,

    /// 마찰 1~5(개입 세션 · 길이 ∈ {0, 5}).
    required List<RepairStageRow> stages,

    /// 아무것도 안 하기(`repairAccept{diff_id}` · 엔진 완성). 무결성 갈래 · 허브 = null.
    SafetyActionCall? doNothingAction,

    /// 정본 정정 폼 — non-null ⇔ 5단계 실행 가능(diff 갈래). 제출 = `runRepairCorrect`.
    RepairCorrectionForm? correction,

    /// 새 기준점 버튼 글자 — non-null ⇔ 실행 가능(무결성 갈래). 제출 = `runRepairBaseline`.
    String? baselineLabel,

    /// «정정은 되돌리지 않습니다 — 정정의 정정만» 류 — 엔진.
    String? noticeText,

    /// 끝난 뒤 문장. non-null ⇒ 동작 0.
    String? doneLabel,

    /// 정정 이력(→ `ledgerRepairs`).
    LinkAction? historyLink,

    /// 경계 X1(원장을 믿을 수 없음 → `x1MigrationEmergency`). non-null ⇒ 동작 0.
    LinkAction? x1GuideLink,

    /// 생체 · 리스 · 뷰어 잠김 — non-null ⇒ 동작 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _RepairWizardVm;

  factory RepairWizardVm.fromJson(Map<String, dynamic> json) =>
      _$RepairWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · target_links · diff · target_lines · do_nothing_default · origins · stages ·
//          do_nothing_action · correction · baseline_label · notice_text · done_label · history_link · x1_guide_link ·
//          locked_label · as_of

/// 원인 한 칸(`ReconOriginChoice` 와 같은 꼴 · 정정 · 새 기준점 공용).
@freezed
abstract class RepairOriginChoice with _$RepairOriginChoice {
  const factory RepairOriginChoice({
    /// ∈ `OriginCodes` — 제출 DTO 의 `originCode` 로 그대로.
    required String originCode,

    /// 칩 글자 — 엔진.
    required String label,
  }) = _RepairOriginChoice;

  factory RepairOriginChoice.fromJson(Map<String, dynamic> json) =>
      _$RepairOriginChoiceFromJson(json);
}
// JSON 키: origin_code · label

/// 마찰 한 단계(개입 세션 재사용 — 1 규칙 대비 · 2 카드 + 서약 재생 · 3 저널 · 4 냉각 · 5 실행 창).
@freezed
abstract class RepairStageRow with _$RepairStageRow {
  const factory RepairStageRow({
    required String title,
    required String stateLabel,
    required UiLevel level,

    /// 규칙 대비 · 서약 3문장 재생 · 냉각 끝 «MM-DD HH:mm 부터» — 엔진 글자.
    required List<String> lines,

    /// 기존 `interventionStep{session_id, stage, outcome, decision_id?}` — 엔진 완성 · 그대로 `run`.
    required List<SafetyActionCall> actions,

    /// 3단계만 true — 저널 3칸 폼(제출 = `runInterventionJournal`).
    required bool journalForm,
  }) = _RepairStageRow;

  factory RepairStageRow.fromJson(Map<String, dynamic> json) =>
      _$RepairStageRowFromJson(json);
}
// JSON 키: title · state_label · level · lines · actions · journal_form

/// 정본 정정 폼(diff 갈래 · 5단계 통과 뒤).
@freezed
abstract class RepairCorrectionForm with _$RepairCorrectionForm {
  const factory RepairCorrectionForm({
    /// 정정할 브로커 체결 후보(빈 목록 금지 — 엔진 숙제 미결 217).
    required List<RepairFillChoice> fills,

    /// 수량 · 가격 재기재가 허용되나(아니면 무효만).
    required bool amendAllowed,

    /// 폼 머리 문장 — 엔진.
    String? noticeText,
  }) = _RepairCorrectionForm;

  factory RepairCorrectionForm.fromJson(Map<String, dynamic> json) =>
      _$RepairCorrectionFormFromJson(json);
}
// JSON 키: fills · amend_allowed · notice_text

/// 정정 대상 체결 한 칸.
@freezed
abstract class RepairFillChoice with _$RepairFillChoice {
  const factory RepairFillChoice({
    /// 🔴 화면 미참조 — 체결 id(제출 DTO 의 `fillRef` 로 그대로).
    required String fillRef,

    /// 체결 요약 — 엔진(날 · 종목 · 수량 · 가격 글자).
    required String label,
  }) = _RepairFillChoice;

  factory RepairFillChoice.fromJson(Map<String, dynamic> json) =>
      _$RepairFillChoiceFromJson(json);
}
// JSON 키: fill_ref · label
```

---

## `packages/domain_contracts/lib/src/dto/resume.dart`

```dart
// packages/domain_contracts/lib/src/dto/resume.dart
//
// 01 §2-7 «PlannedWorkSummary · ResumeReport — X2 재개» + m2-8 D-4·D-5·D-6
// · 인벤토리 §3-4 · §3-14(영역 B).
//
// 🔴 재개 리포트는 **M5 소유 화면**이다(안전·마찰) — 다른 AI 는 이 DTO 를 읽을 수는
//    있으나 원본 화면을 렌더하지 않는다(01 §2-10 소유 표 · §7 C-7).
// 🔴 **손익 필드 없음**(청사진 X2 화면 · 결정 8).
// 🆕 v1.25(01 §34 · K156) — 재개 리포트 한 화면 감싸개 `ResumeReportVm`(`ResumeReport` 무변경 — ds 가 짓는다).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall(🆕 v1.22 · K47 «1.22.0 VM 이 쓴다»)
import '../enums/resume.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart'; // LinkAction

part 'resume.freezed.dart';
part 'resume.g.dart';

/// Supabase 미러 목록 1행(01 §2-7).
///
/// 🔴 계획 **원문이 아니라** digest + 한 줄 요약뿐이다(X2 원칙 ②).
@freezed
abstract class PlannedWorkSummary with _$PlannedWorkSummary {
  const factory PlannedWorkSummary({
    required String workId,

    /// sha256 앞 12자
    required String digest,

    /// "10월말 슬리브 A 진입 게이트 판정" — 엔진 생성
    required String oneLine,
    @TradeDateConverter() required TradeDate dueBy,
    required PlannedWorkState state,
    required String stateLabel,
    required int rowVersion,
    required int leaseEpoch,
  }) = _PlannedWorkSummary;

  factory PlannedWorkSummary.fromJson(Map<String, dynamic> json) =>
      _$PlannedWorkSummaryFromJson(json);
}

/// 재개 리포트(01 §2-7).
///
/// 🔴 손익 필드 없음. 🔴 «램프»라는 낱말은 접두 없이 쓰지 않는다
///    («운영 램프» / «초기 진입» — 01 §2-6 말미 · M2-3 추가 검사).
@freezed
abstract class ResumeReport with _$ResumeReport {
  const factory ResumeReport({
    required String resumeRunId,
    required DateTime startedAt,
    DateTime? finishedAt,
    required int gapTradingDays,
    required ResumeMode mode,

    /// "7거래일 미실행 — RECOVERY_DRY" — 엔진 생성
    required String modeLabel,
    required ResumePhase phase,

    /// 실행/만료/대체/차단/복구불가
    required ResumeCounts counts,

    /// 항목별 계획 vs 재판정 vs 사유
    required List<ResumeItem> items,
    required List<DataGapRow> unrecoverableGaps,

    /// "7거래일 미실행: 실행 4 / 만료 3 / 대체 2 / 차단 1 / 복구 불가 2" — 엔진 생성
    required String headline,
  }) = _ResumeReport;

  factory ResumeReport.fromJson(Map<String, dynamic> json) =>
      _$ResumeReportFromJson(json);
}

/// 재개 집계 — `resume_run.counts` JSON 키 그대로(01 §6-3 · m2-8 D-4).
///
/// 🔴 화면이 합계를 만들지 않는다 — 표시 문장은 `ResumeReport.headline` 이다.
@freezed
abstract class ResumeCounts with _$ResumeCounts {
  const factory ResumeCounts({
    required int executed,
    required int expired,
    required int superseded,
    required int blocked,
    required int unrecoverable,
  }) = _ResumeCounts;

  factory ResumeCounts.fromJson(Map<String, dynamic> json) =>
      _$ResumeCountsFromJson(json);
}

/// 재개 항목 1행 — 계획 vs 재판정 vs 사유(01 §2-7 · m2-8 D-5).
///
/// `verdictCode` 5종은 영역 E 의 `labels/verdict_codes.dart` 가 정본이다(01 §3-3).
@freezed
abstract class ResumeItem with _$ResumeItem {
  const factory ResumeItem({
    required String workId,
    required String oneLine,

    /// 계획 시점의 한 줄 — 엔진 생성
    required String plannedLine,

    /// 재판정 결과의 한 줄 — 엔진 생성
    required String reevaluatedLine,
    required String verdictCode,
    required String verdictLabel,
  }) = _ResumeItem;

  factory ResumeItem.fromJson(Map<String, dynamic> json) =>
      _$ResumeItemFromJson(json);
}

/// 복구 불가 데이터 공백 1행 — `data_gap` 표 컬럼 1:1 + `label`(m2-8 D-6).
@freezed
abstract class DataGapRow with _$DataGapRow {
  const factory DataGapRow({
    required String gapId,
    required String dataset,
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,
    required bool recoverable,
    required String reasonCode,

    /// "2026-08-24~08-28 일봉 없음 — 복구 불가" — 엔진 생성
    required String label,
  }) = _DataGapRow;

  factory DataGapRow.fromJson(Map<String, dynamic> json) =>
      _$DataGapRowFromJson(json);
}

/// 🆕 v1.22(01 §31 · K64) — X2 재개 게이트 한 화면(`x2ResumeGate` · 창구 = `ResumeGateRepository.watchGate()` · 🔒 `ui_safety`).
/// 🔴 머리·줄 = 엔진 `resume_text.dart` 문장 그대로 · 화면이 D+n · 모드 · 멈춤 사유를 계산하지 않는다.
/// 🔴 [lockedLabel] non-null ⇒ 모든 행 `actions` 빈(보기만 · 운영 등급 생체 축소 — 01 §8 미결 169).
@freezed
abstract class ResumeGateVm with _$ResumeGateVm {
  const factory ResumeGateVm({
    /// 엔진 `resumeHeadline`(집계 한 줄 + 멈춤 꼬리).
    required String headline,

    /// 엔진 `resumeModeLabel`(«n거래일 미실행 — 이름»).
    required String modeLabel,
    required UiLevel level,
    required List<ResumeGateRow> rows,

    /// 재개 리포트 링크(엔진 완성 · 목적지 = `AppRoutes.x2ResumeReport` · null = 버튼 부재).
    LinkAction? reportLink,
    String? lockedLabel,
    required AsOf asOf,
  }) = _ResumeGateVm;

  factory ResumeGateVm.fromJson(Map<String, dynamic> json) =>
      _$ResumeGateVmFromJson(json);
}
// JSON 키: headline · mode_label · level · rows · report_link · locked_label · as_of

/// 게이트 한 행 — 계획 한 건이 왜 서 있나(+ 사람이 고를 것).
@freezed
abstract class ResumeGateRow with _$ResumeGateRow {
  const factory ResumeGateRow({
    /// 🔴 화면은 읽지 않는다(시험 · 키 전용 — 호출 args 의 `work_id` 와 같다).
    required String workId,

    /// 엔진 생성 요약(`planned_work.one_line`).
    required String oneLine,

    /// ∈ `ResumeItemReasonCodes`(🔴 화면 분기 0).
    required String reasonCode,

    /// 엔진 `resumeReevaluatedLine` 글자.
    required String reasonLabel,
    required UiLevel level,

    /// 고를 것 — 계절 진입(`HUMAN_DECISION`)이면 엔진이 완성한 3택(`seasonalWindowChoice`) · 그 밖 빈.
    @Default(<SafetyActionCall>[]) List<SafetyActionCall> actions,
  }) = _ResumeGateRow;

  factory ResumeGateRow.fromJson(Map<String, dynamic> json) =>
      _$ResumeGateRowFromJson(json);
}
// JSON 키: work_id · one_line · reason_code · reason_label · level · actions

/// 🆕 v1.25(01 §34 · K156) — X2 재개 리포트 한 화면(`x2ResumeReport` · 창구 = `ResumeGateRepository.watchReport()` · 🔒 `ui_safety`).
/// 🔴 [report] = 엔진 `ResumeReport` 그대로(가장 최근 **끝난** 회차 · 손익 0) · 화면이 시각·단계·셈 문장을 짓지 않는다.
/// 🔴 불변식(C-59 ⑭) — [report] null ⇔ [emptyLabel] non-null · [report] non-null ⇒ [periodText]·[phaseLabel] non-null.
@freezed
abstract class ResumeReportVm with _$ResumeReportVm {
  const factory ResumeReportVm({
    ResumeReport? report,

    /// 회차 시각 «MM-DD HH:mm ~ HH:mm»(엔진 · `startedAt`·`finishedAt` 의 표시 — 01 §1-3).
    String? periodText,

    /// 단계 글자(엔진 · `ResumePhase` 짝 Label — 01 §1-5).
    String? phaseLabel,

    /// 회차 0 문장(엔진).
    String? emptyLabel,
    required AsOf asOf,
  }) = _ResumeReportVm;

  factory ResumeReportVm.fromJson(Map<String, dynamic> json) =>
      _$ResumeReportVmFromJson(json);
}
// JSON 키: report · period_text · phase_label · empty_label · as_of
```

---

## `packages/domain_contracts/lib/src/dto/safety.dart`

```dart
// packages/domain_contracts/lib/src/dto/safety.dart
//
// 🆕 v1.16 — `OnboardingStep` 표시 칸 6(01 §25) · 온보딩 한 화면 VM = `onboarding.dart`.
//
// 01 §2-10 «AlertItem · SafetyState · OnboardingStep» + m2-8 D-1~D-3(`KillSwitchView`·
// `AckState`·`GaugeProgress`) · C-5(`EntryRampProgress`) · C-6(`RampLevel`)
// · 인벤토리 §3-7 · §3-14(영역 B).
//
// 🔴 소유 경계는 «타입»이 아니라 «무엇을 그리는가»다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**다. §7 C-7 이 그 표대로 검사한다.
// 🔴 신뢰 시각(킬스위치 48h·냉각 30일)은 **Supabase 서버 시각**이다 — 로컬 시계로
//    카운트다운을 만들지 말고 `releaseProgress` 를 그대로 표시한다(01 §1-3).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/mode.dart';
import '../enums/onboarding.dart';
import '../enums/safety.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'common.dart';

part 'safety.freezed.dart';
part 'safety.g.dart';

/// 운영 램프 단계 — **OpsRamp** L0~L5(03_실행 §9 자금 투입 단계 · `ramp_state` 단일 행).
///
/// 🔴 전략 §12-⑫ 의 **EntryRamp**(초기 진입 6개월 분할)와 **다른 것**이다
///    (01 §2-6 말미 · m2-8 C-6) — 하나의 «램프 진행» 위젯으로 합치지 않는다.
/// ⚠️ 인벤토리 §2 열거형 52종 표에는 이 이름이 없고 §3-14 가 이 파일(영역 B)로
///    배정했다 — 영역 A 가 `enums/` 에 같은 이름을 만들면 통합 단계에서 한쪽을 지운다.
/// 🆕 v1.19(01 §28 · K11) — 🔴 v1 엔진은 **L0 을 내지 않는다**(발행 집합 L1~L5 · `rampLevelOf` D19 · `ramp_state.level`
///    CHECK 1..5 · 행 없음 = L1 fail-closed) · `l0` 은 삭제하지 않는다(major) · `S05` 는 이 열거를 쓰지 않는다(`RampBoard.levelLabel`).
/// 🆕 v1.21 F3 — `safety_states` L0 행 → L1(C-55 ⑲).
enum RampLevel {
  @JsonValue('L0')
  l0,
  @JsonValue('L1')
  l1,
  @JsonValue('L2')
  l2,
  @JsonValue('L3')
  l3,
  @JsonValue('L4')
  l4,
  @JsonValue('L5')
  l5,
}

/// 알림 1건(01 §2-10).
///
/// 🔴 **손익 필드 없음**(결정 8).
/// 🔴 `level` 의 표시 계층 사적 재분류 금지(결정 7c).
/// 🔴 `bodyText`(무슨 일인가)와 `actionLine`(지금 할 일)은 **분리**돼야
///    「조치가 다르면 다르게 말한다」가 지켜진다(04 §5-3).
@freezed
abstract class AlertItem with _$AlertItem {
  const factory AlertItem({
    required String alertId,
    required AlertLevel level,

    /// 🔴 표시용 아님 — 화면은 [raisedAtText] 만 그린다(🆕 v1.15 · 01 §24).
    required DateTime raisedAt,

    /// 'SAF-407' · 'RESUME_INCOMPLETE' · 'WATCHDOG_LATE'
    /// (코드 목록은 영역 E 의 `labels/alert_codes.dart` 가 정본)
    required String code,
    required String title,

    /// 「무슨 일인가」 문단 — 엔진 생성
    required String bodyText,

    /// 「지금 할 일」 한 줄 — 조치가 같으면 엔진이 이미 묶었다
    required String actionLine,

    /// 🔴 화면은 이 수로 글자를 만들지 않는다 — [groupedText](🆕 v1.15).
    required int groupedCount,
    String? deepLink,

    /// P0 수신 확인 사다리 ⚠️ 쓰기 경로 미결(01 §8-10 · m2-8 J-3)
    /// 🆕 v1.15(01 §24 · K14) — 🔴 P0 만 · `ADVICE_EXIT_URGENT` 엔 오지 않는다(04 §5-4 · C-49 ⑥).
    AckState? ack,

    /// 🆕 v1.15(01 §24 · K5) — 표시 시각 «10:05»(엔진 글자 · 기기 시간대).
    /// null = 부재(묶음이 시각 하나로 말할 수 없을 때 등).
    String? raisedAtText,

    /// 🆕 v1.15(K5) — 묶음 배지 «2건»(엔진 글자 · [groupedCount] ≤ 1 이면 null).
    String? groupedText,

    /// 🆕 v1.15(K9 · `AdviceItem.detailDeepLink` 선례) — `N-02` 상세 링크
    /// (`aaq://alerts/detail/<alertId>` · 엔진이 완성). null = 행 탭 없음.
    String? detailDeepLink,
  }) = _AlertItem;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);
}

/// 🆕 v1.15(01 §24 · K2 · K10) — `N-01` 알림 센터 한 화면. 고정·묶음·접힘·정렬 = 엔진이 끝냈다.
///
/// 🔴 화면은 받은 차례 그대로 그린다(재분류·재정렬·재그룹·건수 집계 0) · `level` 은 아이콘·색에만.
/// 🔴 불변식(엔진 의무 · C-49 ②~⑤) — [pinned] = P0 만 · 섹션 `rows` = P1 만 · `digestRows` = P2 만 ·
///    [emptyLabel] non-null ⇔ [pinned] 0 ∧ [sections] 0 · `watchCenter(p0Only: true)` ⇒ [sections] 0.
@freezed
abstract class AlertCenterVm with _$AlertCenterVm {
  const factory AlertCenterVm({
    required AsOf asOf,

    /// 고정 P0(엔진 순서 · 🔴 P0 만 · 확인됨 포함 · 고정을 언제 푸는지 = 엔진).
    required List<AlertItem> pinned,

    /// 날짜 묶음(엔진 순서 · 최신 날 먼저). `watchCenter(p0Only: true)` 이면 빈 목록.
    required List<AlertSection> sections,

    /// 고정·묶음이 다 빌 때만 non-null(«정상 = 무소식» 엔진 문장 · 04 §5-2). 행이 있으면 null.
    String? emptyLabel,
  }) = _AlertCenterVm;

  factory AlertCenterVm.fromJson(Map<String, dynamic> json) =>
      _$AlertCenterVmFromJson(json);
}

/// 🆕 v1.15(01 §24 · K10) — 날짜 묶음 1개(머리 · 펼친 P1 행 · 접힌 P2 묶음).
///
/// 🔴 `rows ∪ digestRows` 는 비지 않는다 · [digestLabel] non-null ⇔ [digestRows] non-empty.
@freezed
abstract class AlertSection with _$AlertSection {
  const factory AlertSection({
    /// «오늘» · «2026-08-30» — 엔진 글자.
    required String headerText,

    /// 펼친 행 — 🔴 P1 만(엔진 순서).
    required List<AlertItem> rows,

    /// 접힌 묶음 머리 «P2 3건» — 엔진 글자 · [digestRows] 가 비면 null.
    String? digestLabel,

    /// 접힌 행 — 🔴 P2 만 · 펼침 여부 = 화면 표시 상태(데이터 0 · 기본 접힘).
    required List<AlertItem> digestRows,
  }) = _AlertSection;

  factory AlertSection.fromJson(Map<String, dynamic> json) =>
      _$AlertSectionFromJson(json);
}

/// 🆕 v1.15(01 §24 · K2 · K11 · 발주자 결정 ②(a)) — `N-02` 알림 상세 한 화면.
///
/// 🔴 [item] non-null XOR [missingLabel] non-null · [item] = 센터의 같은 `alertId` 객체와 같은 값(같은 엔진 산출).
@freezed
abstract class AlertDetailVm with _$AlertDetailVm {
  const factory AlertDetailVm({
    required AsOf asOf,

    /// 그 알림(센터의 같은 `alertId` 객체와 같은 값).
    AlertItem? item,

    /// 모르는·지난 id = 엔진 문장 — 🔴 스트림 에러가 아니라 값이다.
    String? missingLabel,
  }) = _AlertDetailVm;

  factory AlertDetailVm.fromJson(Map<String, dynamic> json) =>
      _$AlertDetailVmFromJson(json);
}

/// P0 수신 확인 상태(m2-8 D-2).
///
/// ⚠️ 쓰기 경로(`alertAck` 명령의 뷰어 허용 여부)는 01 §8-10 미결이다 —
///    m2-8 J-3 권고는 «허용하지 않는다»(현행 viewer 4종 화이트리스트 유지).
/// 🔴 ack 는 `SafetyState` 에 아무 효력이 없다(A5 — P0 승급 사다리 정지만).
/// 🆕 v1.15(01 §24 · K5 · K14) — P0 만 · `ADVICE_EXIT_URGENT` 엔 오지 않는다(04 §5-4) ·
///    사다리 단계 줄 = 부재(01 §8 미결 138).
@freezed
abstract class AckState with _$AckState {
  const factory AckState({
    required bool acked,
    DateTime? ackedAt,
    required String stateLabel,
    required int escalationStep,
  }) = _AckState;

  factory AckState.fromJson(Map<String, dynamic> json) =>
      _$AckStateFromJson(json);
}

/// 안전 상태(01 §2-10).
///
/// 🔴 **읽기 전용**이다 — 화면은 상태를 바꾸지 않는다. 킬스위치 «발동»만 01 §4-2 명령 API 다.
/// 🔴 `killSwitch`·`releaseProgress`·`stoppedReleaseEligible` **판정 UI** 는 M5 소유다.
@freezed
abstract class SafetyState with _$SafetyState {
  const factory SafetyState({
    required BreakerLevel breakerLevel,
    required String breakerLabel,
    required double drawdown,
    required List<BlockFlag> activeFlags,
    required KillSwitchView killSwitch,

    /// v2.29 STOPPED_RELEASE_ELIGIBLE
    required bool stoppedReleaseEligible,

    /// 48h 카운트다운 · dd 회복 잔여 · BULL 연속일
    required List<GaugeProgress> releaseProgress,

    /// v2.30 — 🔵 v2.31 대상 없음(문구는 엔진 판단)
    required bool alertBlockSatEntry,

    /// 🔵 OpsRamp(L0~L5) — 초기 진입 분할(EntryRamp)이 아니다(01 §2-6)
    required RampLevel rampLevel,
    required RunMode mode,

    /// 🆕 v1.19(01 §28 · K21 · 엔진 E15b R82 W7) — 기동은 하되 배치를 멈추는 hold 사유(값 ⊆ `SafetyHoldCodes` ·
    /// 읽을 때 파생 = 엔진 `ModeStartupGate.holds`). 빈 = hold 없음. 🔴 기동 거부(`ModeStartupCodes`)는 여기 오지 않는다.
    /// 🆕 v1.35(01 §44 · K295 · 미결 219) — 🔴 **화면 미참조**(코드 축 · 표시는 [holdLabels]).
    @Default(<String>[]) List<String> holds,

    /// 🆕 v1.35(01 §44 · K295 · 미결 219 · 01 §1-5 «열거값에는 짝 Label») — hold 한 줄 문장(엔진 완성 · 예 «실전 키 검증 전 —
    /// 자동 매매 배치를 멈췄습니다»). 🔴 `holds[i]` ↔ `holdLabels[i]` **같은 차례 · 같은 길이**(C-68 ⑥) · 화면은 이 문장을
    /// 차례대로 그대로 그린다(hold 줄 한 꼴 · 색 · 아이콘을 코드로 고르지 않는다 · 빈 = 줄 없음) · 문장 사전 = 엔진 한 벌
    /// (S05 `RunModeCard.holdLabel` 과 같은 문장 — 미결 220 ⓓ).
    @Default(<String>[]) List<String> holdLabels,
    required AsOf asOf,
  }) = _SafetyState;

  factory SafetyState.fromJson(Map<String, dynamic> json) =>
      _$SafetyStateFromJson(json);
}

/// 킬스위치 상태(m2-8 D-1).
///
/// 🔒 **M5 만 렌더**한다(결정 6). 🔴 «해제» 필드·버튼을 만들지 않는다 —
///    킬스위치 해제 명령은 계약에 존재하지 않는다(01 §4-2).
@freezed
abstract class KillSwitchView with _$KillSwitchView {
  const factory KillSwitchView({
    required bool active,
    required String stateLabel,
    DateTime? activatedAt,

    /// 🔴 기기 별칭 — 기기 식별자 원문을 화면에 싣지 않는다
    String? activatedByDeviceLabel,
    String? checklistStateLabel,

    /// "해제 가능 예정 09-10 14:00" — 엔진 생성(신뢰 시각 기준)
    String? releaseEtaText,
  }) = _KillSwitchView;
  // 🆕 v1.21 — 재개 게이트(M5-2) 한 화면 = `KillResumeGateVm`(`safety_gate.dart`).

  factory KillSwitchView.fromJson(Map<String, dynamic> json) =>
      _$KillSwitchViewFromJson(json);
}

/// 진행 게이지 1칸(m2-8 D-3).
///
/// 🔴 `normalized` 는 **게이지 폭 전용**이고 표시는 `valueText` 다
///    (§2-11 `complianceRateNormalized` 와 같은 형식).
@freezed
abstract class GaugeProgress with _$GaugeProgress {
  const factory GaugeProgress({
    /// 🆕 v1.21(01 §30) — 값 ∈ `GaugeCodes`(`DD_RECOVERY` · `HOLD` · `BULL_STREAK` · `COOLDOWN` · 검사 = C-55 ⑭).
    required String code,
    required String label,

    /// 0.0~1.0
    required double normalized,
    required String valueText,
  }) = _GaugeProgress;

  factory GaugeProgress.fromJson(Map<String, dynamic> json) =>
      _$GaugeProgressFromJson(json);
}

/// 차단 플래그 1건(01 §2-10).
///
/// 🔴 `clearInstruction` 은 **플래그마다 다른 문구**다(경보 피로 규칙) —
///    화면이 하나의 문장으로 뭉치지 않는다.
@freezed
abstract class BlockFlag with _$BlockFlag {
  const factory BlockFlag({
    /// 01 §3-5 의 12종 — 정본은 영역 E 의 `labels/flag_ids.dart`
    required String flagId,
    required String label,
    required DateTime setAt,

    /// 🔴 **해제가 어떤 성격인가**(자동·원인 코드 필요·수동 경로 없음·마법사 전용)이지
    ///    이동 목적지가 아니다 — 목적지는 [clearDeepLink] 다.
    required ClearRoute clearRoute,
    required String clearInstruction,
    String? originCode,

    /// 🆕 v1.1(§8 미결 39) — "마지막 검증 09-05 18:10" · `LEDGER_INTEGRITY` 배너의
    ///    «마지막 검증 체크포인트 시각»(02 §2-2 표). 엔진 완성 문자열(01 §1-3).
    String? checkpointLabel,

    /// 🆕 v1.1(§8 미결 36) — 조치 진입점 링크(`aaq://m5/…` · `aaq://journal/draft/…` 등).
    /// 🔴 null 이면 배너에 이동 화살표·버튼이 **없다**(`LEDGER_FIX` 처럼 해제 경로가 없는 것).
    /// 🔴 화면이 `flagId`·`clearRoute` 로 목적지를 고르지 않는다(그 표가 곧 판정이다).
    String? clearDeepLink,
  }) = _BlockFlag;

  factory BlockFlag.fromJson(Map<String, dynamic> json) =>
      _$BlockFlagFromJson(json);
}

/// 온보딩 단계 1행 — X3(01 §2-10). 🆕 v1.16(01 §25 · K15) — 표시 칸 6.
///
/// 🔴 화면이 `Duration` 을 포맷하지 않는다(01 §1-3) — 표시는 `estimatedText` 다.
/// 🔴 화면 미참조 = [stepId] · [track] · [order] · [estimated] · [requirement] · [verifiedUntil] · [whereDeepLink]
///    (값으로 글자·차단·정렬·Key 를 고르지 않는다 — 글자는 `*Label`·`*Text` 칸).
@freezed
abstract class OnboardingStep with _$OnboardingStep {
  const factory OnboardingStep({
    required String stepId,
    required OnboardingTrack track,
    required int order,
    required String title,

    /// 왜 필요한가 — 엔진 생성
    required String whyLine,

    /// 🔵 v1.16(K16) — 화면 미참조(옛 뜻 = 자기 단계 링크 · «어디서 받나» = `OnboardingStepDetailVm.whereText` ·
    ///    외부 열기 = 플랫폼 · 01 §8 미결 150). 신설 표본은 null.
    String? whereDeepLink,

    /// 정렬·집계용. JSON 키는 `*_seconds`(01 §1-2 `DurationSecondsConverter`)
    @JsonKey(name: 'estimated_seconds')
    @DurationSecondsConverter()
    required Duration estimated,

    /// "약 20분" — 엔진 생성
    required String estimatedText,
    required StepRequirement requirement,
    required StepState state,

    /// "KIS 토큰 발급 + 잔고 조회 1회" — 엔진 생성
    String? verificationLabel,

    /// 검증 유효기간(KIS 접근토큰 24h · PAT 만료일 등) — 🔵 v1.16 화면 미참조(표시 = [verifiedUntilText]).
    DateTime? verifiedUntil,
    String? failureReasonCode,

    /// 🆕 v1.16 — 등급 글자 «필수»·«권장»·«선택»(엔진). 🔴 화면은 [requirement] 로 글자·차단을 고르지 않는다.
    required String requirementLabel,

    /// 🆕 v1.16 — 권장 미통과 경고 배지(엔진 판정 · null = 부재). 🔴 차단이 아니다 — 차단 = [gate].
    String? warningLabel,

    /// 🆕 v1.16 — 만료 글자 «2026-11-30까지» · «2026-08-30에 만료됨»(엔진 · [verifiedUntil] non-null ⇒ non-null · C-50 ⑥).
    String? verifiedUntilText,

    /// 🆕 v1.16 — 실패 문장(엔진 · [failureReasonCode] 원문과 **함께** 그린다 · 요약·의역 0).
    String? failureText,

    /// 🆕 v1.16 — 단계 게이트(엔진 판정 · null = 게이트 없음 · `unknown` = 진행 차단 · 04 §9-8).
    GateBadge? gate,

    /// 🆕 v1.16 — `O-02` 링크(`aaq://onboarding/<stepId>` · 엔진 완성). null = 행 탭 없음.
    String? detailDeepLink,
  }) = _OnboardingStep;

  factory OnboardingStep.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStepFromJson(json);
}

/// 초기 진입 램프(**EntryRamp**) 진행 — 슬리브별 상태 목록(m2-8 C-5).
///
/// 🔴 «n/6» **단일 게이지가 아니다** — A(계절 캘린더)·C(첫 달 즉시 배분)에 n/6 을
///    그리면 거짓 진행률이다(01 §2-6 말미).
/// 🔴 `RampLevel`(OpsRamp)과 하나의 위젯으로 합치지 않는다.
/// ⚠️ 파일 배정 주의 — 인벤토리 §3-14 «공통·안전» 행은 이 타입을 영역 B 로 두면서도
///    «앞 4 = safety.dart · 뒤 3 = resume.dart» 로만 갈라 이 타입의 파일을 남겨 두지
///    않았다. 이름·필드는 m2-8 C-5 확정본 그대로이고 **파일만 잠정**이다.
@freezed
abstract class EntryRampProgress with _$EntryRampProgress {
  const factory EntryRampProgress({
    required List<EntryRampSleeveState> sleeves,
  }) = _EntryRampProgress;

  factory EntryRampProgress.fromJson(Map<String, dynamic> json) =>
      _$EntryRampProgressFromJson(json);
}

/// 초기 진입 램프의 슬리브 1행(m2-8 C-5).
///
/// `stateCode` ∈ {`MONTHLY_SPLIT`, `COMPLETED_IMMEDIATELY`, `AWAITING_SEASONAL_GATE`}.
/// 🔴 조기 종료 여부는 엔진이 판정해 `stepLabel` 로 준다 — 화면이 한도 소진을 계산하지 않는다.
@freezed
abstract class EntryRampSleeveState with _$EntryRampSleeveState {
  const factory EntryRampSleeveState({
    required SleeveId sleeve,
    required String stateCode,
    required String stepLabel,
  }) = _EntryRampSleeveState;

  factory EntryRampSleeveState.fromJson(Map<String, dynamic> json) =>
      _$EntryRampSleeveStateFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/dto/safety_gate.dart`

```dart
// packages/domain_contracts/lib/src/dto/safety_gate.dart
//
// 🆕 계약 v1.21(01 §30) — M5-2 킬스위치 재개 게이트 · M5-8/`O-04` ② 서약 표시 VM.
// 🆕 v1.22(01 §31 · K65) — `M5-4` 브레이커 사다리(문장 = 엔진 `breakerLadderOf` 글자 그대로).
// 🆕 v1.25(01 §34 · K146 · K147 · K154) — `M5-1` 킬스위치 화면 · 발동 뒤 기록 폼(01 §8 미결 186) ·
//    `M5-5` 차단 보드(사다리 `M5-4` · 게이지 `M5-7` 감싸기).
// 🆕 v1.26(01 §35 · K179 · K181) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판»(후보 · 큐) · `M5-5` RECON 행 해제 폼
//    (`BlockBoardRow.reconClear` 추가형).
// 🔴 M5 만 렌더한다(`ui_safety` · 01 §2-10 표 · C-7) · 상태를 바꾸는 경로 = `SafetyActions`(포트) 뿐.
// 🔴 화면은 받은 글자·차례 그대로 그린다 — 단계·남은 시간을 계산하지 않는다(카운트다운 0 · 새 VM 으로만).
// 🔴 7문항 글자 출처 = SPEC v2.40 04 §3-6 ③ «재개판» 원문(발주자 확정 2026-11-04 · 정규화 = 01 §30 K38) —
//    엔진이 같은 상수를 두고 계약 표본과 대조한다(엔진 숙제 · 06 변경 이력 «2026-11-15 · 계약 판 나눔»).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall(🆕 v1.26 — 규칙 변경 큐 행 취소 · resume.dart 선례)
import '../enums/safety.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction(🆕 v1.25)
import 'safety.dart';

part 'safety_gate.freezed.dart';
part 'safety_gate.g.dart';

/// `M5-2` 재개 게이트 한 화면(창구 = `KillSwitchGateRepository.watchResumeGate()`).
/// 🔴 불변식(엔진 의무 · C-55 ④~⑨) — [items] = 7(받은 길이 · 엔진 config `resumeChecklistItems`) · [nextItemNo] non-null ⇒
///    준비됨 ∧ [blockedText]·[lockedLabel] null · 답한 행 = 앞에서부터 이어짐 · [lockedLabel] non-null ⇒ [nextItemNo] null.
@freezed
abstract class KillResumeGateVm with _$KillResumeGateVm {
  const factory KillResumeGateVm({
    /// 머리 줄 — 엔진 `killSwitchViewOf.stateLabel` 글자 그대로.
    required String readinessLabel,
    required UiLevel level,

    /// 해제 시각 줄 — 엔진 `releaseEtaText`(«해제 가능 예정 11-18 14:00» · 시각 모름 · 해제 가능). null = 부재(확인 전).
    String? etaText,

    /// 48h 냉각 게이지 — `code` = `GaugeCodes.cooldown` · 표시 = `valueText`(엔진 «남은 n시간»). null = 확인 전.
    GaugeProgress? cooldown,

    /// 재개판 7문항(엔진 차례 · 🔴 화면이 7 을 박지 않는다 — 받은 길이).
    required List<KillResumeItemRow> items,

    /// 지금 받을 문항 번호(1~7). null = 받을 문항 없음(대기 · 확인 전 · 시각 모름 · 4번 미충족 · 잠김 · 꺼짐).
    int? nextItemNo,

    /// 막힌 까닭 한 줄 — 확인 전 = 엔진 «체크리스트를 먼저 마치십시오 — …» · 4번 미충족 = SPEC «미충족이면 재개하지 않는다».
    String? blockedText,

    /// 운영 등급 생체 축소(보기만) — non-null ⇒ [nextItemNo] null(01 §8 미결 169).
    String? lockedLabel,
    required AsOf asOf,
  }) = _KillResumeGateVm;

  factory KillResumeGateVm.fromJson(Map<String, dynamic> json) =>
      _$KillResumeGateVmFromJson(json);
}
// JSON 키: readiness_label · level · eta_text · cooldown · items · next_item_no · blocked_text · locked_label · as_of

/// 재개판 한 문항.
@freezed
abstract class KillResumeItemRow with _$KillResumeItemRow {
  const factory KillResumeItemRow({
    /// 1~7 — 🔴 화면은 이 번호로 글자·칸을 고르지 않는다(제출 `itemNo` 에 그대로).
    required int itemNo,

    /// 문항 글자(SPEC 원문 · K38).
    required String label,

    /// 발동 때 답(카드 ④ 같은 번호 · 엔진이 발동 기록에서 재생 · 6번 = «체크리스트 확인 …» · 7번 = null · 확인 전 = 전부 null).
    String? replayText,

    /// 지금 받은 답(통과한 문항만 · 엔진 글자).
    String? answeredText,
    required UiLevel level,

    /// 고를 것(3번 3 · 4번 2 · 그 밖 빈) — 글자·값 = 엔진. 비면 = 글 입력(1·2·7) 또는 확인(5·6) 문항.
    @Default(<KillResumeChoice>[]) List<KillResumeChoice> choices,
  }) = _KillResumeItemRow;

  factory KillResumeItemRow.fromJson(Map<String, dynamic> json) =>
      _$KillResumeItemRowFromJson(json);
}
// JSON 키: item_no · label · replay_text · answered_text · level · choices

/// 3·4번 선택지 1개 — 🔴 [scenario]·[condition] 중 **정확히 하나** non-null · 화면은 그 칸을 제출 DTO 에 그대로 옮긴다.
@freezed
abstract class KillResumeChoice with _$KillResumeChoice {
  const factory KillResumeChoice({
    /// «해소됨» · «진행 중» · «해당 없었음» · «충족» · «미충족»(SPEC 원문).
    required String label,
    KillResumeScenario? scenario,
    KillResumeCondition? condition,
  }) = _KillResumeChoice;

  factory KillResumeChoice.fromJson(Map<String, dynamic> json) =>
      _$KillResumeChoiceFromJson(json);
}
// JSON 키: label · scenario · condition

/// `M5-8` · `O-04` ② 서약(창구 = `PledgeRepository.watchPledge()` · 재생처도 이 줄만 읽는다 — 원문은 한 번만).
/// 🔴 [lines] = 0(첫 판 없음 = 쓰기 자리) 또는 3 · [editable] ⇒ 3 줄 ∧ 12월 창(엔진 판정) · [lockedLabel] ⇒ [editable] false.
/// 🔴 엔진 글자가 없는 칸([statusLine] · [replayNotice])은 null 이다(K16 · 표본 null — 화면이 글자를 짓지 않는다).
@freezed
abstract class PledgeVm with _$PledgeVm {
  const factory PledgeVm({
    /// 사용자 원문(지금 판 · 차례대로).
    @Default(<String>[]) List<String> lines,

    /// 판·작성 시각 줄 — ⏸ 엔진 글자 0(표본 null).
    String? statusLine,

    /// DD 최초 도달 재생 까닭 — ⏸ 엔진 글자 0(표본 null · 재생 대상 판정 = 엔진 `replayDue`).
    String? replayNotice,

    /// 편집 가능(12월 창 · 판 있음 — 엔진 판정). 🔴 화면이 달력으로 판정하지 않는다.
    @Default(false) bool editable,
    String? lockedLabel,
    required AsOf asOf,
  }) = _PledgeVm;

  factory PledgeVm.fromJson(Map<String, dynamic> json) =>
      _$PledgeVmFromJson(json);
}
// JSON 키: lines · status_line · replay_notice · editable · locked_label · as_of

/// 🆕 v1.22(01 §31 · K65) — `M5-4` 브레이커 사다리 한 화면(창구 = `BreakerLadderRepository.watchLadder()`).
/// 🔴 문장 = 엔진 `breakerLadderOf` 글자 그대로(% · 거래일 = 엔진 설정 값 · 화면이 짓지 않는다) · [rows] = 받은 길이(엔진 5).
@freezed
abstract class BreakerLadderVm with _$BreakerLadderVm {
  const factory BreakerLadderVm({
    required List<BreakerLadderRow> rows,
    required AsOf asOf,
  }) = _BreakerLadderVm;

  factory BreakerLadderVm.fromJson(Map<String, dynamic> json) =>
      _$BreakerLadderVmFromJson(json);
}
// JSON 키: rows · as_of

/// 사다리 한 단(엔진 core `BreakerLadderStep` · `safety/breaker_ladder.dart:12` 칸 1:1).
@freezed
abstract class BreakerLadderRow with _$BreakerLadderRow {
  const factory BreakerLadderRow({
    required BreakerLevel level,

    /// «정상» · «경보» · «축소 운용» · «중지» · «정지»(엔진 `breakerLabelOf`).
    required String label,
    required String triggerText,
    required String releaseText,
    required String actionText,

    /// 지금 단(정확히 한 행 — C-56 ⑤).
    required bool current,
  }) = _BreakerLadderRow;

  factory BreakerLadderRow.fromJson(Map<String, dynamic> json) =>
      _$BreakerLadderRowFromJson(json);
}
// JSON 키: level · label · trigger_text · release_text · action_text · current

/// 🆕 v1.25(01 §34 · K146) — `M5-1` 킬스위치 한 화면(창구 = `KillSwitchGateRepository.watchKillSwitch()` · 🔒 `ui_safety`).
/// 🔴 불변식(엔진 의무 · C-59 ②~⑦) — [activateLabel] non-null ⇔ 꺼짐 · 꺼짐 ⇒ [activatedText]·[cancelHeadline]·[checklistStateLabel]·
///    [form]·[etaText]·[gateLink] null ∧ [cancelRows] 빈 · [pathLines] non-empty ⇒ 꺼짐 · [form] non-null ⇒ 켜짐 ∧ 기록 전 ∧
///    [lockedLabel] null · [gateLink]·[etaText] non-null ⇒ 기록 뒤 · [lockedLabel] 은 [activateLabel] 을 지우지 않는다(끄기는 등급 밖 · K150).
/// 🔴 버튼을 누르면 확인 대화 없이 `CommandApi.activateKillSwitch()` — 화면이 대화·지연·두 번 누르기를 더하지 않는다(06 M5-1).
/// 🔴 카운트다운 0 · 해제 칸·버튼 0(해제 = `m5ReleaseGate` 7번 통과뿐).
@freezed
abstract class KillSwitchScreenVm with _$KillSwitchScreenVm {
  const factory KillSwitchScreenVm({
    /// 머리 — 엔진 `killSwitchViewOf.stateLabel`(«킬스위치 꺼짐» · «킬스위치 작동 중 — 신규 주문을 막고 있습니다»).
    required String stateLabel,
    required UiLevel level,

    /// 발동 줄(켜짐만 · 엔진 — 시각 «MM-DD HH:mm» + 기기 별칭 · 🔴 기기 id 원문 0).
    String? activatedText,

    /// 발동 버튼 글자(꺼짐만 · 엔진). null = 버튼 부재(이미 켜짐).
    String? activateLabel,

    /// 3중 경로 안내(꺼짐만 · 엔진 글자 · 받은 차례).
    @Default(<String>[]) List<String> pathLines,

    /// 미체결 취소 보고 머리(켜짐만 · 엔진 — 건수 문장 · 후보 읽기 실패 문장). null = 보고 부재.
    String? cancelHeadline,

    /// 건별(엔진 차례 · 금액·수량·주문번호·intent id 0).
    @Default(<KillCancelRow>[]) List<KillCancelRow> cancelRows,

    /// 기록 상태 — 엔진 `checklistStateLabel`(«체크리스트를 먼저 마치십시오 — …» · «체크리스트 확인 MM-DD HH:mm»). 꺼짐 = null.
    String? checklistStateLabel,

    /// 발동 뒤 기록 폼(켜짐 ∧ 기록 전 ∧ 잠김 아님 · 폰). 제출 = `CommandApi.confirmKillChecklist(KillChecklistSubmission)`.
    KillActivationFormVm? form,

    /// 해제 시각 줄 — 엔진 `releaseEtaText`(기록 뒤만).
    String? etaText,

    /// 재개 게이트로(엔진 완성 · 목적지 `AppRoutes.m5ReleaseGate` · 기록 뒤만).
    LinkAction? gateLink,

    /// 운영 등급 생체 축소(폼 0 · 🔴 발동 버튼은 남는다).
    String? lockedLabel,
    required AsOf asOf,
  }) = _KillSwitchScreenVm;

  factory KillSwitchScreenVm.fromJson(Map<String, dynamic> json) =>
      _$KillSwitchScreenVmFromJson(json);
}
// JSON 키: state_label · level · activated_text · activate_label · path_lines · cancel_headline · cancel_rows ·
//          checklist_state_label · form · eta_text · gate_link · locked_label · as_of

/// 🆕 v1.25(01 §34 · K151) — 미체결 취소 한 건(엔진 `KillCancelItem` − intent id · 코드 · 🔴 금액·수량·주문번호 0).
@freezed
abstract class KillCancelRow with _$KillCancelRow {
  const factory KillCancelRow({
    /// 종목 표시(엔진).
    required String symbolText,

    /// ∈ `KillCancelOutcomeCodes`(🔴 화면 분기 0 — 시험·Key 전용).
    required String outcomeCode,

    /// 결과 글자(엔진 · «불명»은 다시 부르지 않았다는 뜻까지).
    required String outcomeLabel,
    required UiLevel level,
  }) = _KillCancelRow;

  factory KillCancelRow.fromJson(Map<String, dynamic> json) =>
      _$KillCancelRowFromJson(json);
}
// JSON 키: symbol_text · outcome_code · outcome_label · level

/// 🆕 v1.25(01 §34 · K147 · 01 §8 미결 186) — `M5-1` 발동 뒤 기록 폼(카드 ④ (가) 7 + 확인 3 + 1줄).
/// 🔴 차단은 이미 걸려 있다(SPEC v2.40 §3-6 ③) — 이 폼은 발동을 늦추지 않는다 · 마친 시각 = 48h 기준(엔진).
/// 🔴 [items] = 받은 길이(엔진 7) · 입력 칸 꼴(번호별 글·선택·숫자 원문) · 칸 머리 · 제출 버튼 = 카드 정적 라벨(v1.21 K37 결).
/// 🔴 예시·프리필 0 — 사람이 친 원문이 `KillChecklistSubmission` 에 그대로 간다(파싱 = 구현).
@freezed
abstract class KillActivationFormVm with _$KillActivationFormVm {
  const factory KillActivationFormVm({
    required List<KillActivationItemRow> items,

    /// 확인 3 · 1줄 — 제출 칸 `openOrdersQueried` · `openOrdersCancelled` · `remainingCountZero` · `note` 와 1:1(엔진 글자).
    required String ackQueriedLabel,
    required String ackCancelledLabel,
    required String ackRemainingZeroLabel,
    required String noteLabel,

    /// 폼 고지(엔진 — «이 기록은 주문을 내지 않는다 · 전량 청산 = 기록만»). null = 부재.
    String? noticeText,
  }) = _KillActivationFormVm;

  factory KillActivationFormVm.fromJson(Map<String, dynamic> json) =>
      _$KillActivationFormVmFromJson(json);
}
// JSON 키: items · ack_queried_label · ack_cancelled_label · ack_remaining_zero_label · note_label · notice_text

/// 🆕 v1.25(01 §34 · K147 · K148) — 카드 ④ (가) 한 문항.
/// 🔴 [choices] non-empty ⇔ 2번(2) · 5번(2) · [fixedText] non-null ⇔ 6 · 7번(입력 0) · 둘 다 non-null 0.
@freezed
abstract class KillActivationItemRow with _$KillActivationItemRow {
  const factory KillActivationItemRow({
    /// 1~7 — 🔴 제출 칸 대응은 카드 정적(1 ruleAction · 2 reasonKind·emotion·intensity·sleepHours · 3 scenarioId·scenarioNone ·
    ///    4 resumeCondition · 5 scope).
    required int itemNo,

    /// 문항(SPEC 04 §3-6 «카드 ④(발동 뒤 기록)» 원문 · 01 §30 K38 정규화).
    required String label,

    /// 종이 카드 원문 보탬 줄(03 §7-4 · 3·5번만 — K148). null = 부재.
    String? hintText,

    /// 입력 없는 문항의 글자(6 = 시작 시각은 엔진이 적는다 · 7 = 저널은 구현이 만든다 — 엔진). null = 입력 문항.
    String? fixedText,

    /// 고를 것(2번 규칙/감정 · 5번 범위 — 글자·값 = 엔진).
    @Default(<KillActivationChoice>[]) List<KillActivationChoice> choices,
  }) = _KillActivationItemRow;

  factory KillActivationItemRow.fromJson(Map<String, dynamic> json) =>
      _$KillActivationItemRowFromJson(json);
}
// JSON 키: item_no · label · hint_text · fixed_text · choices

/// 🆕 v1.25(01 §34 · K147) — 2·5번 선택지 1개 — 🔴 [reasonKind]·[scope] 중 **정확히 하나** non-null ·
/// 화면은 그 칸을 제출 DTO 에 그대로 옮긴다.
@freezed
abstract class KillActivationChoice with _$KillActivationChoice {
  const factory KillActivationChoice({
    /// «규칙» · «감정» · «신규 진입 차단만» · «전량 청산»(SPEC 원문).
    required String label,
    KillActivationReason? reasonKind,
    KillActivationScope? scope,
  }) = _KillActivationChoice;

  factory KillActivationChoice.fromJson(Map<String, dynamic> json) =>
      _$KillActivationChoiceFromJson(json);
}
// JSON 키: label · reason_kind · scope

/// 🆕 v1.25(01 §34 · K154 · 01 §8 미결 188 M5-5 읽기 몫) — `M5-5` 차단 보드 한 화면
/// (창구 = `BlockBoardRepository.watchBoard()` · 🔒 `ui_safety`).
/// 🔴 불변식(C-59 ⑩~⑫) — [killSwitchLink] 늘 non-null(목적지 `AppRoutes.m5KillSwitch` · 끄기는 언제나) ·
///    [emptyLabel] non-null ⇒ [rows] 빈 · [ladder] 의 current 행 라벨 == [breakerLabel] ·
///    [stoppedDecisionLink] non-null ⇒ 목적지 `AppRoutes.m5StoppedDecision`.
/// 🔴 화면은 받은 차례 그대로(재정렬·재분류 0) · 행 링크 = 엔진 · 🆕 v1.26 — RECON 행만 해제 폼(`BlockBoardRow.reconClear` ·
///    01 §35 K181) · 그 밖 해제 = 링크.
@freezed
abstract class BlockBoardVm with _$BlockBoardVm {
  const factory BlockBoardVm({
    /// 머리(엔진 — 막힌 것 요약 한 줄).
    required String headline,
    required UiLevel level,

    /// 지금 단(엔진 `breakerLabelOf` — `SafetyState.breakerLabel` 과 같은 글자).
    required String breakerLabel,

    /// 막힌 것(켜진 킬스위치 먼저 + 차단 플래그 · 엔진 차례).
    @Default(<BlockBoardRow>[]) List<BlockBoardRow> rows,

    /// 해제 진행 게이지(M5-7 · `SafetyState.releaseProgress` 와 같은 값 · code ∈ `GaugeCodes`).
    @Default(<GaugeProgress>[]) List<GaugeProgress> gauges,

    /// 서킷브레이커 사다리(M5-4 · 엔진 `breakerLadderOf` 글자 그대로 — `BreakerLadderVm` 감싸기).
    required BreakerLadderVm ladder,

    /// STOPPED 재개 결정(엔진 · 자격 때만 · 목적지 `AppRoutes.m5StoppedDecision`).
    LinkAction? stoppedDecisionLink,

    /// 킬스위치 진입(엔진 · 늘 · 목적지 `AppRoutes.m5KillSwitch`).
    required LinkAction killSwitchLink,

    /// «막힌 것 없음» 문장(엔진 · 행 0 ∧ 브레이커 정상일 때만).
    String? emptyLabel,
    required AsOf asOf,
  }) = _BlockBoardVm;

  factory BlockBoardVm.fromJson(Map<String, dynamic> json) =>
      _$BlockBoardVmFromJson(json);
}
// JSON 키: headline · level · breaker_label · rows · gauges · ladder · stopped_decision_link · kill_switch_link · empty_label · as_of

/// 🆕 v1.25(01 §34 · K155) — 보드 한 행(막힌 것 하나 · 해제 성격과 경로가 행마다 다르다 — 06 M5-5).
@freezed
abstract class BlockBoardRow with _$BlockBoardRow {
  const factory BlockBoardRow({
    /// 🔴 화면 미참조(시험·Key) — ∈ `FlagIds.values` ∪ {`KILL_SWITCH`}.
    required String rowId,

    /// 플래그 = 엔진 플래그 사전 라벨 · 킬스위치 = `killSwitchViewOf.stateLabel`.
    required String label,

    /// «MM-DD HH:mm부터»(엔진). null = 부재.
    String? setAtText,

    /// 해제 성격(`ClearRoute` 짝 글자 · 엔진 — 킬스위치 = «재개 게이트로만»).
    required String clearKindLabel,

    /// 할 일(플래그 = 엔진 사전 해제 문장 · 킬스위치 = 엔진 기록 상태·ETA 문장).
    required String clearInstruction,
    required UiLevel level,

    /// 조치 진입(엔진 · 플래그 = `clearDeepLink` · 킬스위치 = `m5KillSwitch`). null = 이동 0.
    LinkAction? link,

    /// 🆕 v1.26(01 §35 · K181) — `RECON_MISMATCH` 행만 · 해제 폼(엔진). null = 해제 동작 0(그 밖 행 · 막힘 없음 · 잠김).
    ReconClearForm? reconClear,
  }) = _BlockBoardRow;

  factory BlockBoardRow.fromJson(Map<String, dynamic> json) =>
      _$BlockBoardRowFromJson(json);
}
// JSON 키: row_id · label · set_at_text · clear_kind_label · clear_instruction · level · link · recon_clear(🆕 v1.26)

/// 🆕 v1.26(01 §35 · K181) — 차단 보드 RECON 행의 해제 폼(`BlockBoardRow.reconClear`).
/// 🔴 제출 = `SafetyActions.runReconClear(ReconClearSubmission)` — `run(reconClear, …)` 은 받지 않는다(구현 `ArgumentError`).
@freezed
abstract class ReconClearForm with _$ReconClearForm {
  const factory ReconClearForm({
    /// 원인 코드 선택지(엔진 쓰기 화이트리스트 ∩ 자동 갈래 · 차례 = 엔진). 🔴 빈 목록 금지(C-60 ⑨).
    required List<ReconOriginChoice> choices,

    /// 고지(엔진 · 예: «해제는 저널과 함께 기록됩니다 — 주문을 내지 않습니다»). null = 부재.
    String? noticeText,
  }) = _ReconClearForm;

  factory ReconClearForm.fromJson(Map<String, dynamic> json) =>
      _$ReconClearFormFromJson(json);
}
// JSON 키: choices · notice_text

/// 🆕 v1.26(01 §35 · K181) — RECON 원인 코드 선택지 하나.
@freezed
abstract class ReconOriginChoice with _$ReconOriginChoice {
  const factory ReconOriginChoice({
    /// ∈ `OriginCodes.writable` — 제출 `ReconClearSubmission.originCode` 로 그대로.
    required String originCode,

    /// 엔진 글자.
    required String label,
  }) = _ReconOriginChoice;

  factory ReconOriginChoice.fromJson(Map<String, dynamic> json) =>
      _$ReconOriginChoiceFromJson(json);
}
// JSON 키: origin_code · label

/// 🆕 v1.26(01 §35 · K177 · K179) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판»(`AppRoutes.m5RuleChangeGate` ·
/// 창구 = `RuleChangeGateRepository.watchGate()` · 🔒 `ui_safety`).
/// 🔴 1.26.0 = 후보(첫 승인할 지금 config) + 큐(요청 · 냉각 · 승인 · 취소). CHANGELOG · 창 밖 안내 · DD 락 글자 = 1.27.0+.
/// 🔴 냉각 30일 · SAF-405 · 12월 창 면제 규칙 = SPEC·엔진 그대로(글자로만 싣는다 — 새 수치 0).
/// 🔴 불변식(C-60 ⑦) — [lockedLabel] non-null ⇒ [candidates] 빈 ∧ 모든 행 `cancel`·`approveLabel` null.
@freezed
abstract class RuleChangeGateVm with _$RuleChangeGateVm {
  const factory RuleChangeGateVm({
    /// 엔진 머리(예: «승인된 설정이 없습니다 — 실전 기동 전에 첫 승인이 필요합니다»).
    required String headline,
    required UiLevel level,

    /// 창 글자(엔진 · 첫 승인 = 창 면제 문장 · 둘째부터 = 12월 창). null = 부재.
    String? windowText,

    /// 요청할 수 있는 후보(엔진 · v1 = 0 또는 1). 빈 목록 = 요청 버튼 0.
    @Default(<RuleChangeCandidateRow>[])
    List<RuleChangeCandidateRow> candidates,

    /// 열린 요청(엔진 `queue()` 차례).
    @Default(<RuleChangeQueueRow>[]) List<RuleChangeQueueRow> rows,

    /// 후보 0 ∧ 큐 0 일 때 문장(엔진). null = 부재.
    String? emptyLabel,

    /// 잠김(01 §8 미결 169) · non-null ⇒ 요청·승인·취소 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _RuleChangeGateVm;

  factory RuleChangeGateVm.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeGateVmFromJson(json);
}
// JSON 키: headline · level · window_text · candidates · rows · empty_label · locked_label · as_of

/// 🆕 v1.26(01 §35 · K178 · K179) — 요청할 수 있는 config 후보 한 행(유형·해시 = 엔진 · 자기 신고 0 — 03운 §6-3).
@freezed
abstract class RuleChangeCandidateRow with _$RuleChangeCandidateRow {
  const factory RuleChangeCandidateRow({
    /// 🔴 화면 미참조(제출용) — `RuleChangeRequestSubmission.candidateId` 로 그대로 되돌린다.
    required String candidateId,

    /// 후보 이름(엔진 · 예: «지금 쓰는 설정 — 첫 승인»).
    required String label,

    /// 변경 유형 글자(엔진 분류).
    required String categoryLabel,

    /// 해시 글자(엔진 · 앞 8자).
    required String hashText,

    /// 요청 버튼 글자(엔진).
    required String requestLabel,

    /// 고지(엔진 · 예: «요청 뒤 30일 냉각이 끝나야 승인할 수 있습니다»). null = 부재.
    String? noticeText,
  }) = _RuleChangeCandidateRow;

  factory RuleChangeCandidateRow.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeCandidateRowFromJson(json);
}
// JSON 키: candidate_id · label · category_label · hash_text · request_label · notice_text

/// 🆕 v1.26(01 §35 · K179) — 열린 규칙 변경 요청 한 행(엔진 `rule_change_store.queue()`).
@freezed
abstract class RuleChangeQueueRow with _$RuleChangeQueueRow {
  const factory RuleChangeQueueRow({
    /// 🔴 화면 미참조(제출용) — `RuleChangeApprovalSubmission.requestId` 로 그대로.
    required String requestId,
    required String categoryLabel,
    required String hashText,

    /// «MM-DD HH:mm 요청»(엔진).
    required String requestedText,

    /// 냉각 글자(엔진 · «냉각 중 — MM-DD HH:mm 이후 승인» · «냉각 끝»).
    required String coolingText,

    /// 상태 글자(엔진).
    required String stateLabel,
    required UiLevel level,

    /// 승인 폼 버튼 글자(엔진 · non-null ⇔ 지금 승인 판정이 냉각·창·DD 에 걸리지 않음). null = 승인 폼 0.
    String? approveLabel,

    /// 취소(엔진 완성 `run(ruleChangeCancel{request_id})`). null = 취소 0.
    SafetyActionCall? cancel,
  }) = _RuleChangeQueueRow;

  factory RuleChangeQueueRow.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeQueueRowFromJson(json);
}
// JSON 키: request_id · category_label · hash_text · requested_text · cooling_text · state_label · level · approve_label · cancel
```

---

## `packages/domain_contracts/lib/src/dto/self_audit.dart`

```dart
// packages/domain_contracts/lib/src/dto/self_audit.dart
//
// 🆕 계약 v1.37(01 §46 · K318~K323 · 01 §8 미결 224) — `M5-13` 원장 실사 «해소» 게이트 한 화면
//    (창구 = `SelfAuditResolveRepository.watchResolve()` · 라우트 = `AppRoutes.m5SelfAuditResolve`(파라미터 0) · 🔒 `ui_safety`).
// 🔴 해제 경로 = **실사 0오차 통과 하나**(06 M5-13 · D8) — 수동 해제 버튼 · 필드 · 동작 0(M5-5 꼴 · C-70 ③).
//    플래그 `ADVICE_LEDGER_UNVERIFIED` 는 엔진이 0오차 실사를 본 순간 스스로 내린다(화면이 부르는 동작 없음).
// 🔴 `CANON_SELF_REPORT` 차이는 X5 정정 마법사 대상이 아니다(K320) — 행 조치 = «다시 실사하기»(그 달 · 그 계좌 `L-3`) ·
//    차이를 없애는 길 = 기록(`A-3` · `M5-6`) · 정정(`M5-12`) 뒤 다시 실사 · 닫힘 = RESOLVED(ACCEPTED 갈래 0).
// 🔴 보관 명령(`CommandState.heldForIntegrity` · B18) 검토 = **일괄 확정** 하나(K319) — 버림 동작 0(«명령은 사실을 잃지 않는다» 01 §10-8) ·
//    확정 = 엔진 완성 `SafetyActionCall`(`heldCommandsConfirm` · `{review_id}`) 을 화면이 그대로 넘긴다.
// 🔴 폰 전용 · 읽기 모델 열 0(v1.36 `ReadModelTables` 무변경 · K321 ⑤) · 화면은 받은 글자 · 차례 그대로(분기 0).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'ledger.dart'; // LedgerDiffRow

part 'self_audit.freezed.dart';
part 'self_audit.g.dart';

/// `M5-13` 원장 실사 해소 게이트 한 화면.
/// 🔴 불변식(엔진 의무 · C-70 ②) — [diffsEmptyLabel] non-null ⇔ [diffs] 빈 · [heldEmptyLabel] non-null ⇔ [heldCommands] 빈 ·
///    [confirmHeld] non-null ⇒ [heldCommands] 비지 않음 ∧ [heldBlockedText] null ∧ id = `heldCommandsConfirm` ∧ args 키 = {`review_id`} ·
///    [heldBlockedText] non-null ⇒ [confirmHeld] null ∧ [heldCommands] 비지 않음 · [counterLines] 길이 ∈ {0, 2}(투자 안내 모드 = 2 ·
///    미처리 갭 → 실사 갭 차례 · 그 밖 = 0) · [diffs] 행 = `CANON_SELF_REPORT` ∧ 열림 · [auditLinks] 목적지 = `L-3`(그 달 · 그 계좌).
@freezed
abstract class SelfAuditResolveVm with _$SelfAuditResolveVm {
  const factory SelfAuditResolveVm({
    /// 머리(엔진 — «신규 진입 안내가 멈춰 있습니다» · «원장 미검증 표식이 없습니다»).
    required String headline,
    required UiLevel level,

    /// 플래그 상태 한 줄(엔진 — 언제부터 · 무엇을 막는지 · 청산 · 방어 안내는 그대로라는 사실).
    required String flagLine,

    /// 해제 규칙 문장(엔진 — «대응 계좌의 실사가 0오차로 통과하면 풀립니다 · 수동 해제는 없습니다»).
    required String releaseRuleText,

    /// 두 카운터(B22 · X7-3) — 받은 차례 = [미처리 갭, 실사 갭] · 엔진 완성 문장 · 투자 안내 모드가 아니면 빈 목록.
    @Default(<String>[]) List<String> counterLines,

    /// 열린 `CANON_SELF_REPORT` 차이(`L-1` 과 같은 엔진 사전 · 받은 차례) — 행 `actionLink` = «다시 실사하기»(폰 · 그 달 · 그 계좌 `L-3`).
    @Default(<LedgerDiffRow>[]) List<LedgerDiffRow> diffs,

    /// «열린 차이가 없습니다»(엔진) — non-null ⇔ [diffs] 빈.
    String? diffsEmptyLabel,

    /// 0오차 실사가 아직 필요한 계좌(엔진 차례) — «연금저축 계좌 실사 하기» → `aaq://ledger/self-report/<yyyy-MM>/<별칭>`.
    @Default(<LinkAction>[]) List<LinkAction> auditLinks,

    /// 보관 명령(`HELD_FOR_INTEGRITY` · 받은 차례 = 접수 차례).
    @Default(<HeldCommandRow>[]) List<HeldCommandRow> heldCommands,

    /// «보관된 명령이 없습니다»(엔진) — non-null ⇔ [heldCommands] 빈.
    String? heldEmptyLabel,

    /// 일괄 확정(엔진 완성 · `SafetyActionId.heldCommandsConfirm` · `{review_id}`) — null = 확정할 것 없음 또는 무결성 점검 중.
    SafetyActionCall? confirmHeld,

    /// «원장 무결성 점검이 끝나야 확정할 수 있습니다»(엔진) — non-null ⇒ [confirmHeld] null.
    String? heldBlockedText,
    required AsOf asOf,
  }) = _SelfAuditResolveVm;

  factory SelfAuditResolveVm.fromJson(Map<String, dynamic> json) =>
      _$SelfAuditResolveVmFromJson(json);
}
// JSON 키: headline · level · flag_line · release_rule_text · counter_lines · diffs · diffs_empty_label · audit_links ·
//         held_commands · held_empty_label · confirm_held · held_blocked_text · as_of

/// 🆕 v1.37(K318) — 보관 명령 한 행(사람이 낸 사실 — 엔진이 계산한 값이 아니라 가림 대상 아님 · 01 §10-8 B18).
@freezed
abstract class HeldCommandRow with _$HeldCommandRow {
  const factory HeldCommandRow({
    /// 🔴 화면 미참조(시험 · Key) — `command_inbox.command_id`.
    required String commandId,

    /// «수기 체결 기록» · «실입금 등록» · «정기 실사 제출»(엔진 — 명령 종류 글자).
    required String kindLabel,

    /// 한 줄 요약(엔진 — «069500 매수 3주 · 2026-09-02 체결» 꼴).
    required String summaryText,

    /// «2026-09-02 10:14 접수»(엔진).
    required String receivedAtText,

    /// «보관 — 무결성 점검 뒤 확정»(엔진 · `CommandState` 짝 글자).
    required String stateLabel,
  }) = _HeldCommandRow;

  factory HeldCommandRow.fromJson(Map<String, dynamic> json) =>
      _$HeldCommandRowFromJson(json);
}
// JSON 키: command_id · kind_label · summary_text · received_at_text · state_label
```

---

## `packages/domain_contracts/lib/src/dto/settings.dart`

```dart
// 01 §4-1(G-07) · §2-6 — M9 설정 뷰모델과 월 납입 운영값.
//
// 🔴 **월 추가 납입 운영값을 화면(`ui_*/lib` · `labels.dart` 포함)·계약 코드에 상수로 적지
//    않는다**(C-32 · 🆕 v1.4 문구 통일 01 §14-13). 픽스처는 **폐기값만** 금지이고 금액 예시값은
//    하나를 쓴다(`fixture_conventions_test.dart` 머리 주석).
// 🔵 v1.23 정정(01 §32 · K78) — **값의 원천은 엔진 `contributionSettingOf` 하나**이고 읽기 창구는 둘이다:
//    `ConfigRepository.watchContributionSetting()`(원값 `ContributionSetting` · S7-4·H-02) ·
//    🆕 `SettingsRepository.watchContribution()`(M9 `S13` 화면 투영 `MonthlyContributionVm` · 잠김·버튼 칸).
//    변경 창구는 `SettingsActions.runContributionUpdate`(운영 등급 · 🆕 v1.23 원문 제출 DTO `ContributionUpdateSubmission`)다.
// 🔴 화면이 `금액 × 12` 를 계산하지 않는다 — 한도 판정은 엔진 단일 소스다.
// 🔴 **최소·최대·0 허용 여부를 필드로 내려보내지 않는다** — 범위 판정은 저장
//    명령의 `ActionResult.headline`·`reasonCode` 로만 돌아온다(그래야 「저장 버튼
//    비활성」이라는 **화면의 판정**이 생기지 않는다).
// 🆕 계약 v1.18(01 §27 · R6 선행 · 발주자 결정 2026-11-13 Q1~Q4 · K-o~K-q):
//    ① `S01` = 엔진이 묶은 그룹 VM — 그룹 차례(일반 → 운영 → 규칙)·카드 차례·요약 글자·주의 배지 글자 = **엔진** ·
//       화면은 받은 차례 그대로(정렬·세기·묶기 0) · 폰 전용 행은 뷰어 VM 에 엔진이 싣지 않는다(`isViewer` 칸 0).
//    ② 12월 연간 리뷰 카드 = [SettingsHomeVm.annualReviewLink](OPEN 판정 = 엔진 · 화면이 달을 보지 않는다).
//    ③ `actionAvailable` 삭제 — «부재 = 목록에 없음» 한 원칙(K-q).
//    ④ «엔진이 완성한 호출 1개» = [SettingsActionCall](`OnboardingAction` 별칭 · 화면은 id·args 를 그대로 넘긴다).
// 🆕 계약 v1.20(01 §29) — `S02` `CredentialListVm`·`CredentialCardVm` 추가형(색 · 동작 · 슬롯 · 잠김 · asOf · 봉인 · 런북 ·
//    회전 링크 · 키 조각 0 · 1단).
// 🆕 계약 v1.23(01 §32 · K79) — `MonthlyContributionVm` 추가형(asOf · lockedLabel · changeLabel · editable = ui 미참조 표식) — M9 `S13` 화면 VM.
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/settings.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/converters.dart';
import 'common.dart'; // LinkAction
import 'onboarding.dart'; // OnboardingAction

part 'settings.freezed.dart';
part 'settings.g.dart';

/// 01 §4-1 G-07 — 월 납입 운영 파라미터의 읽기 창구가 내려주는 값.
/// 🔴 `amount`·`amountText` 는 «지금 유효한 값»이다(N-S4-01) — 접수됐으나 아직
///    시작되지 않은 변경은 `appliesFromText` 가 **문장으로만** 알린다. 예정 금액을
///    `amount` 에 넣지 않는다.
/// 🔴 🆕 v1.4 — `amount` 는 엔진·명령 쪽 원값이다. 플래너 입력칸의 초기 글자는
///    [amountInputText] 이다(01 §14 · D4).
/// 🔴 설정 문장(`amountText`·`equivalentNoteText`·`appliesFromText`·`pensionLimitNoteText`)은
///    **설정값 기준 설명**이지 플래너에 입력한 금액 기준 판정이 아니다.
@freezed
abstract class ContributionSetting with _$ContributionSetting {
  const factory ContributionSetting({
    /// 🔴 ui 미참조(C-38 ⑩) — 엔진·명령 쪽 원값. 입력칸 초기 글자는 [amountInputText].
    @DecimalStringConverter() required Decimal amount,

    /// 표시 문자열 — 엔진 생성.
    required String amountText,

    /// 🆕 v1.4 — 플래너 스텝 ① 입력칸의 **초기 글자 전용**(엔진이 만든 숫자 글자).
    /// 🔴 입력칸은 스트림의 **첫 값만** 채운다 — 이후 값은 편집 중인 입력을 덮지 않는다.
    /// 🔴 화면이 `amount.toString()` 으로 대신 만들지 않는다(표시 자릿수는 컨버터의 일이 아니다 ·
    ///    `money.dart`).
    required String amountInputText,

    /// 12%-등가 참고 + 「충족/부족」 한 줄 — 엔진 생성.
    required String equivalentNoteText,

    /// 「다음 납입 주기」 문구 — 엔진 생성(§2-6 `contribution_day` 규칙).
    required String appliesFromText,

    /// 「최근 변경: …」 한 줄 — 엔진 생성(G-101).
    required String lastChangedText,
    required AsOf asOf,

    /// 연 한도·세액공제 구간과의 관계 한 줄 — 엔진 생성(G-102).
    /// 🔴 null 이면 화면이 이 줄을 **그리지 않는다**.
    String? pensionLimitNoteText,
  }) = _ContributionSetting;

  factory ContributionSetting.fromJson(Map<String, dynamic> json) =>
      _$ContributionSettingFromJson(json);
}

/// m2-8 G-11 · 🆕 v1.23(01 §32 · K79) — 05 `S13` 월 납입 설정 화면 VM(~~`S05` 카드~~ — v1.19 K3 `S05` 칸 0).
/// 🔴 앞 7 칸(− `editable`)과 [asOf] 는 `ContributionSetting` 의 **1:1 투영**이다(같은 이름 · N-S4-03).
/// 🔴 **필드를 이어 붙여 문장을 만들지 않는다.** 투영을 늘리는 것은 허용된다(엔진 문자열 필드가 늘면 여기도 같은 이름으로).
/// 🔴 03 §8 `S7-3b` 의 `ContributionVm`(슬리브 기여 분해)과 **다른 타입**이며 이름을 재사용하지 않는다(N-01 · G-67).
/// 🆕 v1.23 — 입력칸·버튼 유무 = [changeLabel](엔진·조립 · null = **부재**) + `SettingsActions` 주입(뷰어 = 화면 부재 · 폰 전용) ·
///    [lockedLabel] non-null ⇒ [changeLabel] null(K-t · C-57 ②) · 🔴 최소·최대·0 허용 칸 0(범위 판정 = 결과 `reasonCode` 로만).
@freezed
abstract class MonthlyContributionVm with _$MonthlyContributionVm {
  const factory MonthlyContributionVm({
    required String amountText,

    /// 🆕 v1.4 — `ContributionSetting.amountInputText` 의 투영(N-S4-03 · 같은 이름) · 입력칸은 스트림의 **첫 값만** 채운다.
    required String amountInputText,
    required String equivalentNoteText,
    required String appliesFromText,
    required String lastChangedText,

    /// 🔴 ui 미참조(🆕 v1.23 · K79) — 값 = `changeLabel != null`(C-57 ③) · 지우지 않는다(파괴 변경 0 · 추가형 원칙) ·
    ///    화면은 [changeLabel] 의 null 여부로만 가른다.
    required bool editable,
    String? pensionLimitNoteText,

    /// 🆕 v1.23 — `ContributionSetting.asOf` 의 투영(오래됨 배너 · 하단 고지).
    required AsOf asOf,

    /// 🆕 v1.23 — 운영 등급 생체 축소 등 «보기만» 한 줄(엔진·조립). non-null ⇒ [changeLabel] null.
    String? lockedLabel,

    /// 🆕 v1.23 — 변경 버튼 글자(엔진·조립). 🔴 null = 입력칸·버튼 **부재**(잠김 · 원천 없음) — 화면이 글자·유무를 짓지 않는다.
    String? changeLabel,
  }) = _MonthlyContributionVm;

  factory MonthlyContributionVm.fromJson(Map<String, dynamic> json) =>
      _$MonthlyContributionVmFromJson(json);
}
// JSON 키: amount_text · amount_input_text · equivalent_note_text · applies_from_text · last_changed_text · editable ·
//          pension_limit_note_text · as_of · locked_label · change_label

/// 🆕 v1.18(01 §27 · K-d) — 엔진이 완성한 `SettingsActions.run` 호출 1개(M9 공용 이름).
/// 🔴 화면은 [OnboardingAction.id]·[OnboardingAction.args] 를 **그대로** 넘긴다(키·값을 짓지 않는다 · 화이트리스트 =
///    `settings_actions.dart` 머리) · 버튼 글자 = [OnboardingAction.label](엔진). JSON 키 = id · args · label.
typedef SettingsActionCall = OnboardingAction;

/// m2-8 G-5 · 🆕 v1.18 **교체**(01 §27 · K-o) — 설정 홈(05 `S01`).
/// 🔴 [groups] 차례 = 엔진(일반 → 운영 → 규칙 · 빈 그룹은 엔진이 뺀다) · [asOf] = 조회 화면(하단 고지 · 오래됨 = 카드 몫).
@freezed
abstract class SettingsHomeVm with _$SettingsHomeVm {
  const factory SettingsHomeVm({
    /// 엔진 상태 칩(늘 그린다 — «정상 = 무소식» 의 예외 05:43).
    required EngineStatusChip statusChip,

    /// 12월 연간 리뷰 카드 — 창이 OPEN 일 때만 non-null(엔진 판정 · 목적지 = `AppRoutes.settingsAnnualReview`).
    LinkAction? annualReviewLink,
    required List<SettingsGroup> groups,
    required AsOf asOf,
  }) = _SettingsHomeVm;

  factory SettingsHomeVm.fromJson(Map<String, dynamic> json) =>
      _$SettingsHomeVmFromJson(json);
}
// JSON 키: status_chip · annual_review_link · groups · as_of

/// 🆕 v1.18(01 §27 · K-o) — 설정 홈 묶음 1개(05 그림 4).
@freezed
abstract class SettingsGroup with _$SettingsGroup {
  const factory SettingsGroup({
    /// 자물쇠 아이콘·묶음 머리에만(🔴 화면이 등급을 정하지 않는다).
    required SettingTier tier,

    /// 머리 글자 «운영 · 들어갈 때 생체 인증» — 엔진(등급 라벨 포함).
    required String label,

    /// 받은 차례 그대로 · 1장 이상(빈 묶음 = 엔진이 뺀다).
    required List<SettingsCard> cards,
  }) = _SettingsGroup;

  factory SettingsGroup.fromJson(Map<String, dynamic> json) =>
      _$SettingsGroupFromJson(json);
}
// JSON 키: tier · label · cards

/// 🆕 v1.18(01 §27 · K-o) — 엔진 상태 칩. 🔴 손익 성격 글자 0 · «DRY_RUN» 글자 0(G-63) · [level] = 색·아이콘만.
@freezed
abstract class EngineStatusChip with _$EngineStatusChip {
  const factory EngineStatusChip({
    /// «실전 · 관찰 중 · 골든벡터 통과» — 엔진.
    required String label,
    required UiLevel level,

    /// `live × dryRun` 관찰 중일 때만 «승격 가능/불가 + 사유» 한 줄(06 `M1-22`). null = 줄 없음.
    String? promotionLabel,
  }) = _EngineStatusChip;

  factory EngineStatusChip.fromJson(Map<String, dynamic> json) =>
      _$EngineStatusChipFromJson(json);
}
// JSON 키: label · level · promotion_label

/// m2-8 G-5 — 설정 카드 1장. 🆕 v1.18(K-p · K-q) — `actionAvailable` 삭제 · [attentionText] 추가.
/// 🔴 [code] = 엔진 불투명 id(화면 미참조 · Key = 순번) · 행 아이콘 = [level] 상태 아이콘뿐(카테고리 아이콘 사전 0).
/// 🔴 갈 수 없는 카드는 «비활성»이 아니라 **목록에 없다**(엔진이 싣지 않는다).
@freezed
abstract class SettingsCard with _$SettingsCard {
  const factory SettingsCard({
    required String code,
    required String title,

    /// 🔴 색·상태 아이콘의 근거. 값의 부호로 고르지 않는다.
    required UiLevel level,

    /// 현재 상태 한 줄 — 엔진(화면이 조립하지 않는다).
    String? statusLabel,

    /// 🆕 v1.18 — 주의 배지 글자(«1»). null = 배지 부재 · 🔴 int 아님(화면이 하위 항목을 세지 않는다 · `OpsDailySummary` 선례).
    String? attentionText,

    /// 하위 화면 링크(`AppRoutes` M9 묶음). null = 탭 부재.
    String? route,
  }) = _SettingsCard;

  factory SettingsCard.fromJson(Map<String, dynamic> json) =>
      _$SettingsCardFromJson(json);
}
// JSON 키: code · title · level · status_label · attention_text · route

/// m2-8 G-6 · 🆕 v1.20 추가형(01 §29 · K1 · K29 · K35) — 증권사 키 관리(05 `S02` · 폰 전용 · 운영 등급).
/// 🔴 값·키 조각(«앞4…뒤4» 포함)은 어떤 필드로도 오지 않는다(K7) — 마스킹 표시는 조립 앱 `SecretField` 안에서만(06 `M4-4`).
/// 🔴 [cards] 장 수·차례 = 엔진(종류·개수 상수 0 · 모드·운영 방식에 따라 엔진이 싣는다) · 1장 이상(엔진 의무 — 필수 세트는
///    미등록이어도 카드가 있다 · 빈 칸 0 — K29).
@freezed
abstract class CredentialListVm with _$CredentialListVm {
  const factory CredentialListVm({
    required List<CredentialCardVm> cards,

    /// 🆕 v1.20 — 모드 봉인 머리 한 줄(SIM 계열 «모의투자 중입니다 — 실전 키의 주문 경로는 봉인돼 있습니다 …» · 01 §9-3). null = 줄 없음.
    String? modeNotice,

    /// 🆕 v1.20 — 키 유출 대응 런북 링크(엔진 완성 · `AppRoutes.opsRunbook` 의 한 값 · 읽기 문서라 잠김에도 남는다). null = 링크 부재.
    LinkAction? leakRunbookLink,

    /// 🆕 v1.20 — 운영 등급 생체 축소 글자(non-null = 보기만). 🔴 엔진 의무 = 이때 모든 카드 [CredentialCardVm.credentialSlotId]·
    /// [CredentialCardVm.verifyAction]·[CredentialCardVm.rotateLink] null — 화면은 이 칸으로 컨트롤을 거르지 않는다(K23 · K35).
    String? lockedLabel,

    /// 🆕 v1.20 — 조회 화면 하단 고지(05 §0-4 · 오래됨 = `staleLabel`).
    required AsOf asOf,
  }) = _CredentialListVm;

  factory CredentialListVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialListVmFromJson(json);
}
// JSON 키: cards · mode_notice · leak_runbook_link · locked_label · as_of

/// m2-8 G-6 · 🆕 v1.20 추가형(01 §29 · K6 · K7 · K10~K12 · K30) — 키 카드 1장. `kind` 에는 X7 의 `KIS_RECONCILE` 이 포함된다.
/// 🔴 `CredentialUse` 는 브로커 속성이 아니라 **앱 측 런타임 봉인 선언**이다.
/// 🔴 화면이 읽는 칸 = [kindLabel]·[healthLabel]·[usageLabel]·[expiresText]·[level]·[lastVerifiedText]·[requirementLabel]·[whyLine]·
///    [sealLabel]·[credentialSlotId](빌더에 그대로)·[verifyAction]·[rotateLink] — [alias]·[kind]·[healthCode]·[usage] 는 화면 미참조.
/// 🔴 키 조각 칸 0(K7) · 저장 동작 칸 0(K6 — 검증 통과 = 구현이 저장하는 1단).
@freezed
abstract class CredentialCardVm with _$CredentialCardVm {
  const factory CredentialCardVm({
    /// 엔진 식별자(`credential_registry.alias` · `kis_live` 꼴) — 🔴 화면 미참조(Key = 순번 · K30).
    required String alias,

    /// `CredentialKindCodes` 값(K8) — 🔴 화면 미참조(분기·아이콘 0).
    required String kind,

    /// 카드 제목 — 엔진(«실전 · 위탁 01 + 연금저축 22»).
    required String kindLabel,

    /// 🔴 화면 미참조 · 사전 밖 축(DDL `credential_registry.health` 5 ∪ `NOT_REGISTERED` — C-5 `_fieldsOutsideDictionary`) · 색 = [level].
    required String healthCode,
    required String healthLabel,

    /// 🔴 화면 미참조(봉인 표시 = [sealLabel] 글자).
    required CredentialUse usage,
    required String usageLabel,

    /// 만료 고지 — 엔진 생성. 🔴 화면이 남은 일수를 세지 않는다.
    String? expiresText,

    /// 🆕 v1.20 — 색·상태 아이콘의 유일한 근거(K11 · advisory 미등록 ≠ 경고 — 엔진이 info 로 싣는다).
    required UiLevel level,

    /// 🆕 v1.20 — 마지막 검증 한 줄(성공·실패 · 원문 코드 포함 가능) — 엔진. null = 줄 없음(미등록).
    String? lastVerifiedText,

    /// 🆕 v1.20 — «필수»·«권장»·«선택» — 엔진 글자(🔴 `StepRequirement` 분기 0).
    String? requirementLabel,

    /// 🆕 v1.20 — 미등록의 결과 한 줄(X7 «원장 신뢰 등급이 자기 보고로 고정됩니다») — 경고 아님. null = 줄 없음.
    String? whyLine,

    /// 🆕 v1.20 — 봉인 배지(«대사 전용 — 주문 경로 봉인됨» · SIM «모의투자 중 — 주문 경로 봉인됨»). 🔴 해제 컨트롤 0.
    String? sealLabel,

    /// 🆕 v1.20 — 시크릿 입력 자리 이름(`SettingsSlotIds` · 모의 = `OnboardingSlotIds.secretKisMock` 재사용 — K8 · K9 · K31).
    /// null = 자리 부재(잠김 포함). 🔴 화면은 이름을 슬롯 빌더에 그대로 넘긴다(분기·상수 0).
    String? credentialSlotId,

    /// 🆕 v1.20 — 엔진이 완성한 `credentialVerify{kind}` 호출(«검증 후 저장» · «다시 검증»). null = 버튼 부재.
    /// 🔴 통과 = 구현이 저장한다(1단 · K6) — 저장 버튼·`credentialRegister` 호출 0.
    SettingsActionCall? verifyAction,

    /// 🆕 v1.20 — 키 회전 마법사 진입(`AppRoutes.m4KeyRotation` · 🔒 06 `M4-4` · K12). null = 링크 부재.
    LinkAction? rotateLink,
  }) = _CredentialCardVm;

  factory CredentialCardVm.fromJson(Map<String, dynamic> json) =>
      _$CredentialCardVmFromJson(json);
}
// JSON 키: alias · kind · kind_label · health_code · health_label · usage · usage_label · expires_text · level ·
//          last_verified_text · requirement_label · why_line · seal_label · credential_slot_id · verify_action · rotate_link
```

---

## `packages/domain_contracts/lib/src/enums/advice.dart`

```dart
// 01 §2-1(X7 신규 열거형) · §3-7(계절 진입 게이트) · §4-2 — 안내·기록·전환 축(인벤토리 §2-12).
//
// ✅ X7 13종은 `m2-8_naming.md` A-5 로 확정됐다 — 「X7 확정 식별자 목록 ③ 의 이름을 그대로
//    쓰고 이후 바꾸지 않는다」.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · `advice.status` CHECK — 안내 1건의 생애.
///
/// 🔴 terminal 4종(`filled`·`skipped`·`expired`·`superseded`)과 `revoked` 는 **어떤 경로로도
///    되살아나지 않는다**(X2 원칙 ①과 동형). 전이 이력은 `advice_transition` 에 병행 append.
/// 🔴 저장값 `status` 는 배지·정렬에 쓰지 않는다 — 화면이 쓰는 유일한 값은
///    `AdviceItem.effectiveStatus` 다.
enum AdviceStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('PARTIAL')
  partial('PARTIAL'),
  @JsonValue('FILLED')
  filled('FILLED'),
  @JsonValue('SKIPPED')
  skipped('SKIPPED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('SUPERSEDED')
  superseded('SUPERSEDED'),
  @JsonValue('REVOKED')
  revoked('REVOKED');

  const AdviceStatus(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-1(G-08) · `advice.kind` CHECK.
///
/// `decision_log.kind` 와 같은 갈래 + `funding`(v2.32 `PENSION_FUNDING` 조달 단계 · §3-6).
/// 🔴 `noAction` — «오늘은 아무것도 하지 마십시오»(suppressed)와 «믿을 수 없는 원장의 방어
///    안내»를 표현하지 못하면 억제된 날의 홈 블록 3b·`J-1` 배지가 통째로 사라지고(C14),
///    그 침묵이 「엔진이 죽었다」와 구별되지 않는다.
/// 🔴 이 값이 붙은 행의 NULL 허용 범위는 §6-6 `advice` DDL 조문이 정한다(둘뿐이다).
enum AdviceKind {
  @JsonValue('ENTRY')
  entry('ENTRY'),
  @JsonValue('EXIT')
  exit('EXIT'),
  @JsonValue('REBALANCE')
  rebalance('REBALANCE'),
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT'),
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('FUNDING')
  funding('FUNDING'),
  @JsonValue('NO_ACTION')
  noAction('NO_ACTION');

  const AdviceKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 — 사람이 «건너뜀»을 고를 때의 사유.
///
/// 🔴 자유 서술 거부(§3-4 X5 원인 코드 원칙 준용). `other` 를 고르면 1줄이 필수다.
/// 🔴 «유효기한 방치»는 **여기 없다** — 사람이 고르는 값이 아니라 엔진이 부여하는 전이다.
/// 🔴 `note` 가 필수인 것은 예산 코드 2종과 `other` 뿐이다(01 §5-4 `AdviceSkip` 조문).
enum AdviceSkipReason {
  @JsonValue('PRICE_UNACCEPTABLE')
  priceUnacceptable('PRICE_UNACCEPTABLE'),
  @JsonValue('CASH_SHORT')
  cashShort('CASH_SHORT'),
  @JsonValue('INTENTIONAL_PAUSE')
  intentionalPause('INTENTIONAL_PAUSE'),
  @JsonValue('BROKER_ISSUE')
  brokerIssue('BROKER_ISSUE'),
  @JsonValue('MISISSUED')
  misissued('MISISSUED'),
  @JsonValue('OTHER')
  other('OTHER');

  const AdviceSkipReason(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(A8) — 버튼 노출·비활성의 **유일한** 근거.
/// 🔴 화면은 `status`·`onHold`·`suppressed` 를 조합해 버튼을 만들지 않는다(C-18).
///
/// ⚠️ 인벤토리 §2-12 는 이 열거형을 «뷰모델 전용 · JSON 표기 없음»(대응 DB 컬럼 없음)으로
///    적었다. 그래도 `@JsonValue` 를 붙이는 이유는 픽스처가 JSON 이고 「자동 변환 0건」이
///    규약이기 때문이다(인벤토리 §10-1 영역 A 체크리스트). 🔴 표기는 §1-2 규약대로
///    SCREAMING_SNAKE 이며 픽스처도 이 표기를 쓴다.
/// ✅ `deferConfirm` 흡수 여부는 `m2-8_naming.md` A-16 이 **3값 유지**로 확정했다 —
///    「내일 다시」는 `AdviceItem.deferAvailable`(bool) 필드로 남는다.
enum AdviceActionId {
  @JsonValue('RECORD')
  record('RECORD'),
  @JsonValue('SKIP')
  skip('SKIP'),
  @JsonValue('DETAIL')
  detail('DETAIL');

  const AdviceActionId(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음).
  final String wire;
}

/// 01 §2-1 · `rm_holding.scope` — «관리 대상»과 «시스템 밖 자산»을 한 목록에 섞지 않게 한다.
/// 🔴 `external` 행의 표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).
enum HoldingScope {
  @JsonValue('MANAGED')
  managed('MANAGED'),
  @JsonValue('EXTERNAL')
  external('EXTERNAL');

  const HoldingScope(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · `handover_session.path` CHECK — 집행 주체 전환 위저드(`M5-11`)의 진입 상태.
/// 🔴 «안내 개시»는 여기 없다 — 별도 게이트 `M5-10` 이다.
enum HandoverPath {
  @JsonValue('SIM_TO_AUTO')
  simToAuto('SIM_TO_AUTO'),
  @JsonValue('FRESH_AUTO')
  freshAuto('FRESH_AUTO'),
  @JsonValue('ADOPT_LEDGER')
  adoptLedger('ADOPT_LEDGER'),
  @JsonValue('HANDBACK_MANUAL')
  handbackManual('HANDBACK_MANUAL');

  const HandoverPath(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · `credential_registry.usage` CHECK — 키의 사용 범위.
/// 🔴 브로커가 주는 속성이 아니라 **앱 측 런타임 봉인 선언**이다(§9-3 「키 봉인」 재사용).
enum CredentialUse {
  @JsonValue('RECONCILE_ONLY')
  reconcileOnly('RECONCILE_ONLY'),
  @JsonValue('FULL')
  full('FULL');

  const CredentialUse(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §4-2(N-2) — 원장 실사의 목적. `m2-8_naming.md` A-10 확정.
///
/// 🔴 **기본값을 두지 않는다** — 목적이 없으면 엔진이 세 규약(세션 밖 제출 거부 ·
///    `lines` 전 종목 필수 · `ledger_diff` 개시)을 어디에 걸지 모른다.
/// 🔴 `simOpening` 의 완화 3가지는 `periodicAudit` 에 **하나도** 적용되지 않는다.
enum SelfReportPurpose {
  @JsonValue('PERIODIC_AUDIT')
  periodicAudit('PERIODIC_AUDIT'),
  @JsonValue('SIM_OPENING')
  simOpening('SIM_OPENING');

  const SelfReportPurpose(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §3-7(P 회차) — 슬리브 A 계절 진입 게이트의 상태. `m2-8_naming.md` A-8 확정.
///
/// 🔴 **상태 5 : 사유 코드 3 의 비대칭을 화면이 분기로 메우지 않는다** — 화면은 상태값으로
///    색·배지만 고르고 문구는 전부 `label` 을 쓴다.
///    (`octPassed` = ⏸ `F1_ENTRY_OK` · `deferredToNov`·`deferredToDec` = `F1_ENTRY_DEFER` ·
///     `enteredInNov`·`forcedEntryDec` = `F1_ENTRY_LATE`)
/// 🔴 임계값과 보류 상한을 화면·계약에 상수로 적지 않는다 — 엔진 config 키를 읽어 문자열로 받는다.
enum SeasonalEntryGateState {
  @JsonValue('OCT_PASSED')
  octPassed('OCT_PASSED'),
  @JsonValue('DEFERRED_TO_NOV')
  deferredToNov('DEFERRED_TO_NOV'),
  @JsonValue('ENTERED_IN_NOV')
  enteredInNov('ENTERED_IN_NOV'),
  @JsonValue('DEFERRED_TO_DEC')
  deferredToDec('DEFERRED_TO_DEC'),
  @JsonValue('FORCED_ENTRY_DEC')
  forcedEntryDec('FORCED_ENTRY_DEC');

  const SeasonalEntryGateState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/biometric.dart`

```dart
// 🆕 계약 v1.39(01 §48 · K350 · 01 §8 미결 238 · 리뷰 3차 A-3) — OS 생체 대화상자의 목적(무엇에 동의하는가).
//
// 🔴 생체 대화상자 하나(`biometricSign`)를 네 동작이 같이 쓰면서 모두 «서약에 생체로 서명»을 띄웠다 — 실전 집행 승격(실주문을 켜는
//    동작)에서도 «방금 쓴 서약 세 문장을 확인합니다»라고 알렸다. 목적을 인자로 받고 글자는 [BiometricPurpose] 마다 하나다
//    (`BiometricPromptText` · 플랫폼(Kotlin)은 문장을 짓지 않는다).
// 🔴 게이트 판정(생체 확인 결과 · 실패 = `BIOMETRIC_UNAVAILABLE`)은 목적과 무관하다 — 목적은 대화상자 글자만 고른다.
// 🔵 조립 배선(`biometricSign(purpose)` · 호출 넷) = 다음 카드(미결 238 남은 몫) — 그 전 = 늘 [pledgeSign] 글자(지금 그대로).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 생체 대화상자 목적(차례 = 사람이 처음 만나는 차례).
enum BiometricPurpose {
  /// `O-04` ③ 서약에 생체로 서명(온보딩 · 지금 글자 그대로).
  @JsonValue('PLEDGE_SIGN')
  pledgeSign('PLEDGE_SIGN'),

  /// `M5-11` 6단계 — 실전 전환 시작(simToAuto 세션 열기 · 확정 = 냉각 뒤 · 실주문 0 = 관찰부터).
  @JsonValue('HANDOVER_START')
  handoverStart('HANDOVER_START'),

  /// `S05` 실전 집행 승격(관찰 → 실주문을 켠다 · 01 §10-2 G-43).
  @JsonValue('LIVE_PROMOTION')
  livePromotion('LIVE_PROMOTION'),

  /// X1 기기 이전 — 새 폰에서 실거래를 다시 연다(복구 마지막 단계 `biometricConfirmed`).
  @JsonValue('X1_MIGRATION')
  x1Migration('X1_MIGRATION');

  const BiometricPurpose(this.wire);

  /// 채널 · 로그 표기(대화상자 글자 아님).
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/calendar.dart`

```dart
// 01 §2-8 «X4 캘린더» 축(인벤토리 §2-8).
//
// ⏸ X4 채택 자체가 미결이다(`m2-8_naming.md` J-5 · 01 §8-5 OAuth 동의화면 7일 만료).
//    🔴 **이름·타입은 등재하되 기능을 구현하지 않는다** — 이 파일은 그 등재분이다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-8 · `calendar_event_log.origin` CHECK(G-28 배치 E 재작성).
/// 🔴 `MANUAL_ENTRY` 가 없으면 수기 체결 이벤트가 `QUARANTINED` 로 빠지고
///    `canonCalendar` 대사가 매일 불일치한다.
enum CalendarOrigin {
  @JsonValue('LIVE')
  live('LIVE'),
  @JsonValue('ARCHIVE')
  archive('ARCHIVE'),
  @JsonValue('BROKER_RECOVERED')
  brokerRecovered('BROKER_RECOVERED'),
  @JsonValue('INFERRED')
  inferred('INFERRED'),
  @JsonValue('MANUAL_ENTRY')
  manualEntry('MANUAL_ENTRY');

  const CalendarOrigin(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-8(C11) — 캘린더 이벤트의 갈래.
///
/// 🔴 정정 2행을 «체결» 3건으로 그리지 않는다 — 캘린더는 앱 밖에서 보는 통로라
///    「내가 3번 샀나」로 읽히고, 그 오인이 이중 매수를 부른다. `canonCalendar` 대사는
///    1:1 이라 감사로도 잡히지 않는다.
enum CalendarEventKind {
  @JsonValue('EXECUTION')
  execution('EXECUTION'),
  @JsonValue('ORDER_ACCEPTED')
  orderAccepted('ORDER_ACCEPTED'),
  @JsonValue('ORDER_REJECTED')
  orderRejected('ORDER_REJECTED'),
  @JsonValue('ORDER_CANCELLED')
  orderCancelled('ORDER_CANCELLED'),
  @JsonValue('REBALANCE')
  rebalance('REBALANCE'),
  @JsonValue('CASH_FLOW')
  cashFlow('CASH_FLOW'),
  @JsonValue('SAFETY')
  safety('SAFETY'),
  @JsonValue('SYSTEM')
  system('SYSTEM'),
  @JsonValue('DAILY_SUMMARY')
  dailySummary('DAILY_SUMMARY'),
  @JsonValue('ENGINE_DOWN')
  engineDown('ENGINE_DOWN'),
  @JsonValue('EXECUTION_CORRECTION')
  executionCorrection('EXECUTION_CORRECTION');

  const CalendarEventKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/command.dart`

```dart
// 01 §4-2 «명령 API» · §4-3 «설정 동작» 축(인벤토리 §2-13).
//
// 🔴 이 네 열거형은(🆕 v1.21 `SafetyActionId`) **영역 A 가 소유**하고 `lib/src/commands/`(영역 D)는 import 만 한다 —
//    열거형이 두 영역에 흩어지면 `@JsonValue` 규약의 소유자가 둘이 된다(인벤토리 §2 서문).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §4-2 · §6-6 `command_queue.kind` CHECK.
///
/// 🔴 **X7 4종은 Dart 이름과 DB 값의 어순이 뒤집혀 있다**(`manualFillRecord` ↔
///    `'RECORD_MANUAL_FILL'`) — 기계 변환에 맡기면 CHECK 위반이 런타임에 터진다.
///    Dart 이름은 §4-2 열거형이, DB 값은 `command_queue.kind` CHECK 가 각각 정본이고
///    **둘 다 바꾸지 않는다**(`m2-8_naming.md` B-3). C-15 가 이 비대칭을 검사한다.
/// 🔴 뒤 3종(`selfReportBalance`·`alertAck`·`killChecklistConfirm`)은 기계 변환과 일치한다 —
///    그래서 위 4종과 섞이면 더 위험하다(B-4).
/// 🔴 X7 8종(+ `LEDGER_EVENT_RECORD`)은 **전량 폰(operator) 전용**이며 뷰어 화이트리스트(앞 4종)를 건드리지 않는다.
///    🆕 v1.12(01 §21 · K14 ⓐ) — 8번째 = `DEFER_ADVICE_CONFIRM`(만료 확인 카드 「내일 다시」).
/// 🆕 v1.4 정정(01 §14-2) — `depositRegister` 도 폰 전용이다(구 «앞 5종» → 4종).
/// 🔴 킬스위치 «해제» 명령은 없다(결정 6).
enum CommandKind {
  @JsonValue('KILL_SWITCH_ACTIVATE')
  killSwitchActivate('KILL_SWITCH_ACTIVATE'),
  @JsonValue('JOURNAL_DRAFT')
  journalDraft('JOURNAL_DRAFT'),
  @JsonValue('BLIND_REVIEW_SCORE')
  blindReviewScore('BLIND_REVIEW_SCORE'),
  @JsonValue('DISCLOSURE_VIEW')
  disclosureView('DISCLOSURE_VIEW'),
  @JsonValue('DEPOSIT_REGISTER')
  depositRegister('DEPOSIT_REGISTER'),

  // ── X7 7종 · 🔴 전량 operator 전용 ──
  @JsonValue('RECORD_MANUAL_FILL')
  manualFillRecord('RECORD_MANUAL_FILL'),
  @JsonValue('AMEND_MANUAL_FILL')
  manualFillAmend('AMEND_MANUAL_FILL'),
  @JsonValue('VOID_MANUAL_FILL')
  manualFillVoid('VOID_MANUAL_FILL'),
  @JsonValue('SKIP_ADVICE')
  adviceSkip('SKIP_ADVICE'),
  @JsonValue('SELF_REPORT_BALANCE')
  selfReportBalance('SELF_REPORT_BALANCE'),
  @JsonValue('ALERT_ACK')
  alertAck('ALERT_ACK'),
  @JsonValue('KILL_CHECKLIST_CONFIRM')
  killChecklistConfirm('KILL_CHECKLIST_CONFIRM'),

  // ── 🆕 v1.10 · X7 ㊲ 원장 사건(8번째) · 🔴 operator 전용 · 기록 계열 TTL(㊵) ──
  @JsonValue('LEDGER_EVENT_RECORD')
  ledgerEventRecord('LEDGER_EVENT_RECORD'),

  // ── 🆕 v1.12(01 §21 · K14 ⓐ) — 만료 확인 카드 「내일 다시」 · 🔴 폰 전용 · 초안 영구 제외(C-35 ②) ──
  //    엔진 = `advice_transition(cause_code='DEFER_CONFIRM')` 1행 · 거부 = `DEFER_ALREADY_USED`.
  @JsonValue('DEFER_ADVICE_CONFIRM')
  adviceDeferConfirm('DEFER_ADVICE_CONFIRM');

  const CommandKind(this.wire);

  /// JSON·DDL 표기(01 §1-2). 🔴 Dart 이름과 어순이 다른 값이 넷 있다 — 위 조문 참조.
  final String wire;
}

/// 01 §4-2 · §6-2 `command_inbox.state` CHECK(G-30).
///
/// ```
/// requested ──▶ received ──┬──▶ executed        (종단)
///                          ├──▶ rejected        (종단 · rejectReasonCode 필수)
///                          └──▶ expired         (종단 · 서버 expires_at)
/// requested/received ──┬──▶ staleContext        ┐
///                      ├──▶ heldForIntegrity    ├ 🔴 보류 3(+1)상태 — TTL 을 소비하지 않는다
///                      ├──▶ pendingLeaseConfirm ┘
///                      └──▶ noOperator
/// ```
///
/// 🔴 **보류는 거부가 아니다.** 무결성 차단·리스 만료·오프라인·맥락 불일치에서 기록 명령을
///    거부하지 않고 보류한다.
/// 🔴 화면이 `state` 를 낙관 갱신하지 않는다 — 「요청됨」과 「집행됨」의 구별이 이 계약의 목적이다.
/// 🔴 `noOperator` 는 「요청됨」이 «껐다»로 읽히는 것을 막는 유일한 값이며, 표시 문구는
///    M2 가 사전 공급한 **고정 카탈로그**에서 고른다(앱이 상태를 조합해 문장을 만들지 않는다).
/// ✅ DDL 자리 = `command_inbox.state` = `command_ack.state` = **[requested] 를 뺀 8값**
///    (계약 v1.9.0 · 설계 13 §8 R19 E9-6 · R20 · 인벤토리 §10-2 ① 해소 · G-30). `command_queue` 에는
///    state 칸이 없다 — [requested] 는 기기 쪽 내구 큐의 상태라 엔진 표에 오지 않는다.
enum CommandState {
  @JsonValue('REQUESTED')
  requested('REQUESTED'),
  @JsonValue('RECEIVED')
  received('RECEIVED'),
  @JsonValue('EXECUTED')
  executed('EXECUTED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('STALE_CONTEXT')
  staleContext('STALE_CONTEXT'),
  @JsonValue('HELD_FOR_INTEGRITY')
  heldForIntegrity('HELD_FOR_INTEGRITY'),
  @JsonValue('PENDING_LEASE_CONFIRM')
  pendingLeaseConfirm('PENDING_LEASE_CONFIRM'),
  @JsonValue('NO_OPERATOR')
  noOperator('NO_OPERATOR');

  const CommandState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §4-3 — `SettingsActions.run(id, args:)` 가 받는 동작 식별자.
///
/// 🔴 **개수를 숫자로 적지 않는다**(G-91 · §8-17 — 골든벡터 총계와 같은 이유).
/// 🔴 `M9` 가 부르는 값은 05 §7 이 정본이고 행이 늘면 여기가 따라온다. 그러나
///    **`M5`·`M8` 전용 5값**(`onboardingOperatingModeSelect`·`handoverAdoptionSet`·
///    `handoverExternalRegister`·`handoverCommit` · 🆕 v1.16 `onboardingDryRunStart`)은 **이 파일이 정본**이며 05 §7 표에
///    나타나지 않는 것이 설계다 — 🔴 05 §7 에 없다는 이유로 지우지 않는다. 지우면 G-01·G-03
///    이 닫은 구멍(위저드·온보딩의 쓰기 경로 부재)이 되살아난다.
/// 🔴 DDL `CHECK` 대응 컬럼은 없다. 표기는 §1-2 규약대로 SCREAMING_SNAKE 다.
enum SettingsActionId {
  /// ⏸ v1.24(01 §33 · K106) — `S11` = ⏸ R9e(엔진 원천 뒤 · 01 §8 미결 197) · args 미정.
  @JsonValue('SETTINGS_GENERAL_UPDATE')
  settingsGeneralUpdate('SETTINGS_GENERAL_UPDATE'),

  /// 🆕 v1.20(01 §29 K6) — `S02` 1단(통과 = 구현이 저장) · args `{kind ∈ CredentialKindCodes}`.
  @JsonValue('CREDENTIAL_VERIFY')
  credentialVerify('CREDENTIAL_VERIFY'),

  /// 🆕 v1.20 — 🔴 화면 미호출(1단) · 조립·엔진 내부(`M4-4` 회전 마법사 등) · args 미정.
  @JsonValue('CREDENTIAL_REGISTER')
  credentialRegister('CREDENTIAL_REGISTER'),

  /// 🆕 v1.20 — `S03` 전체 검증 · args = `settings_actions.dart` 머리.
  @JsonValue('ACCOUNT_VERIFY_MAPPING')
  accountVerifyMapping('ACCOUNT_VERIFY_MAPPING'),

  /// 🆕 v1.20 — `S03` 슬리브↔계좌 원자 저장 · args = `settings_actions.dart` 머리.
  @JsonValue('ACCOUNT_MAP_SLEEVE')
  accountMapSleeve('ACCOUNT_MAP_SLEEVE'),
  @JsonValue('STRATEGY_PREVIEW')
  strategyPreview('STRATEGY_PREVIEW'),
  @JsonValue('STRATEGY_APPLY_REQUEST')
  strategyApplyRequest('STRATEGY_APPLY_REQUEST'),

  /// 🆕 G-01 — 🔴 온보딩 `O-00b` 의 **최초 선택 전용**이다. 전환이 아니므로 M5 게이트를
  /// 거치지 않으며, `O-04` 완료 후에는 이 동작이 거부되고 아래 전환 요청으로만 바뀐다.
  @JsonValue('ONBOARDING_OPERATING_MODE_SELECT')
  onboardingOperatingModeSelect('ONBOARDING_OPERATING_MODE_SELECT'),

  /// 🆕 v1.16(01 §25 · K24) — 🔴 온보딩 `O-04` ⑥ «DRY_RUN 시작» 전용(M8). 첫 `onboarding_choice.committed_at` 을
  /// **같은 트랜잭션**에서 채운다(01 §8-23) — 실패하면 둘 다 되돌린다. `runtimeEngineStart`(M9 운용 관리 ·
  /// 온보딩을 마친 엔진의 시작)와 다르다. args = `{}`.
  @JsonValue('ONBOARDING_DRY_RUN_START')
  onboardingDryRunStart('ONBOARDING_DRY_RUN_START'),

  @JsonValue('RUNTIME_MODE_SWITCH_REQUEST')
  runtimeModeSwitchRequest('RUNTIME_MODE_SWITCH_REQUEST'),
  @JsonValue('RUNTIME_OPERATING_MODE_SWITCH_REQUEST')
  runtimeOperatingModeSwitchRequest('RUNTIME_OPERATING_MODE_SWITCH_REQUEST'),

  /// 🆕 G-03 X7 — 귀속 1건의 처분 제출(편입/제외). `M5-11` 위저드 안에서만 호출된다.
  @JsonValue('HANDOVER_ADOPTION_SET')
  handoverAdoptionSet('HANDOVER_ADOPTION_SET'),

  /// 🆕 G-03 X7 — 시스템 밖 자산 등록·해제(`released_at`).
  @JsonValue('HANDOVER_EXTERNAL_REGISTER')
  handoverExternalRegister('HANDOVER_EXTERNAL_REGISTER'),

  /// 🆕 G-03 X7 — 위저드 커밋 1회.
  @JsonValue('HANDOVER_COMMIT')
  handoverCommit('HANDOVER_COMMIT'),

  /// 🆕 v1.22(01 §31 · K56) — `M5-11` simToAuto 위저드 6단계 생체 확인 = 전환 세션 열기(`{path}` · 1.22.0 화이트리스트 =
  /// `SIM_TO_AUTO` 하나 · ds `handover_session_store.dart:159` · 🔴 이름에 `OPEN` 을 쓰지 않는다 — 거부 코드 `HANDOVER_SESSION_OPEN` 과 겹침).
  @JsonValue('HANDOVER_SESSION_START')
  handoverSessionStart('HANDOVER_SESSION_START'),

  /// 🆕 v1.22 — 전환 세션 물러나기(`{handover_session_id}` · ds `:242` · 시각 = 기기 시계).
  @JsonValue('HANDOVER_SESSION_CANCEL')
  handoverSessionCancel('HANDOVER_SESSION_CANCEL'),

  /// 🆕 v1.22(K56) — 위저드 5단계 모의 기록 보관·지움(`{fate ∈ KEEP|DISCARD}` · 🔴 **세션 전** — `handover_session_id` 0 ·
  /// ds `sim_ledger_fate_store.dart:51` · 결정 사유 `SIM_LEDGER_KEEP`·`SIM_LEDGER_DISCARD`).
  @JsonValue('HANDOVER_SIM_LEDGER_FATE')
  handoverSimLedgerFate('HANDOVER_SIM_LEDGER_FATE'),

  @JsonValue('RUNTIME_ENGINE_START')
  runtimeEngineStart('RUNTIME_ENGINE_START'),
  @JsonValue('RUNTIME_ENGINE_STOP')
  runtimeEngineStop('RUNTIME_ENGINE_STOP'),

  /// 🆕 v1.19(01 §28 · K6) — `S05` 첫 실전 주문 승격(`live × autoTrade × dryRun` → `execute` · 06 `M1-22` · 13 R91).
  /// args = `{}`(엔진이 `RunModeCard.promotionAction` 에 완성 · 관찰 중 ∧ 승격 가능일 때만) · 🔴 생체 1회 = operator 구현이
  /// 기존 M5 게이트 다이얼로그로 받는다(새 라우트·새 화면 0 · `handoffRoute` null) · 자동 승격 0.
  @JsonValue('RUNTIME_LIVE_PROMOTION')
  runtimeLivePromotion('RUNTIME_LIVE_PROMOTION'),

  /// 🆕 v1.12(01 §21 · K9) — `L-3` 실사 세션 열기(폰 로컬 · `args` = {yyyy_mm, account_alias} ·
  /// 그 폰의 원장 파생 표시를 가린다 — 뷰어는 가리지 않는다). `L-3` 이 `initState` 에서 부른다.
  @JsonValue('SELF_REPORT_SESSION_START')
  selfReportSessionStart('SELF_REPORT_SESSION_START'),

  /// 🆕 v1.12 — 닫기(`L-3` `dispose` · `initState` 에서 잡아 둔 인스턴스로 · 세션 만료는 엔진이 스스로 닫는다).
  @JsonValue('SELF_REPORT_SESSION_STOP')
  selfReportSessionStop('SELF_REPORT_SESSION_STOP'),

  /// 🆕 v1.20 — `S06` viewer QR 티켓 발급(🔴 `deviceAppLockSet` 만들지 않음 — K17).
  @JsonValue('DEVICE_PAIRING_TICKET_CREATE')
  devicePairingTicketCreate('DEVICE_PAIRING_TICKET_CREATE'),

  /// 🆕 v1.20 — `S06` viewer 연결 끊기 · args `{device_id}`.
  @JsonValue('DEVICE_TOKEN_REVOKE')
  deviceTokenRevoke('DEVICE_TOKEN_REVOKE'),
  @JsonValue('CONNECTION_TEST')
  connectionTest('CONNECTION_TEST'),
  @JsonValue('CONNECTION_SYNC_NOW')
  connectionSyncNow('CONNECTION_SYNC_NOW'),

  /// 🆕 v1.31(01 §40 · K239 · E11k-d2) — `o_07` ③ Supabase 로그인(이메일 + 비밀번호 = 슬롯 `SECRET_SUPABASE_LOGIN` ↔ 구현 사이만) · args `{}` ·
  /// 1단(통과 = 구현이 새로고침 토큰을 금고에) · 결과 `reasonCode` ∈ `SupabaseAuthResultCodes` ∪ `SupabaseTimeResultCodes` 전송 6 ∪
  /// 🆕 v1.39 `SupabaseSignupResultCodes`(로그인 통과 뒤 공개 가입 확인 — 열림 = o_07 VERIFIED 아님 · 01 §48 K349 ④) ∪ null ·
  /// 🔴 `connectionTest{SUPABASE}`(o_07 ② 연결)과 다른 동작 — 한 단계 안 두 결과를 섞지 않는다.
  @JsonValue('SUPABASE_SIGN_IN')
  supabaseSignIn('SUPABASE_SIGN_IN'),

  /// 🆕 v1.18(01 §27 · K-s · 05 §7 C22) — `S07` 알림 채널 선택(운영 등급 · 🔴 `settingsGeneralUpdate` 로 태우지 않는다 —
  /// 채널은 안전장치의 일부). args = `{channel ∈ NotifyChannelCodes}`(엔진이 `NotifyChannelOption.selectAction` 에 완성).
  @JsonValue('NOTIFY_CHANNEL_SELECT')
  notifyChannelSelect('NOTIFY_CHANNEL_SELECT'),

  /// ⏸ v1.24(01 §33 · K107) — X4 = R9 밖(⏸ R9d · 01 §8 미결 5 · 196) · args 미정.
  @JsonValue('CALENDAR_SYNC_NOW')
  calendarSyncNow('CALENDAR_SYNC_NOW'),
  @JsonValue('CALENDAR_REBACKFILL')
  calendarRebackfill('CALENDAR_REBACKFILL'),

  /// 🆕 v1.24(01 §33 · K112) — `S09` «지금 백업» · args `{}`(엔진 완성 `BackupVm.runAction`) · 결과 `BackupResultCodes`.
  @JsonValue('BACKUP_RUN_NOW')
  backupRunNow('BACKUP_RUN_NOW'),

  /// 🆕 v1.24(01 §33 · K111) — 🔴 화면 미호출(복원 = X1 마법사 · 같은 폰 = 엔진 `X1_LIVE_EXISTS`) · args 미정 유지(`credentialRegister` 선례).
  @JsonValue('BACKUP_RESTORE_START')
  backupRestoreStart('BACKUP_RESTORE_START'),

  /// 🆕 v1.24(01 §33 · K114) — `S10` 골든벡터 셀프테스트 · args `{}` · 실행기 = E11o(전 = 버튼 부재).
  @JsonValue('SELFTEST_GOLDEN_RUN')
  selftestGoldenRun('SELFTEST_GOLDEN_RUN'),

  /// 🆕 v1.24(01 §33 · K115) — `S10` 무결성 자가진단(정본 자가 대조 권고 · 불일치 = `LEDGER_INTEGRITY`) · args `{}` · 결과 `LedgerIntegrityResultCodes`.
  @JsonValue('SELFTEST_INTEGRITY_RUN')
  selftestIntegrityRun('SELFTEST_INTEGRITY_RUN'),

  /// ⏸ `m2-8_naming.md` A-13(G-45) — 월 납입 운영값 변경.
  /// 🔴 **«운영 등급»이며 `settingsGeneralUpdate` 로 태우지 않는다** — 일반 등급이면
  /// 「즉시 반영」이 되어 「다음 납입 주기부터 적용」이 깨지고 생체 재인증도 건너뛴다.
  /// ✅ v1.23(01 §32 · K77) — 05 §1 등급표 «운영 — 월 납입» 행 있음 · 제출 경로 = `SettingsActions.runContributionUpdate`(`ContributionUpdateSubmission`) · `run` 화이트리스트 밖 · 화면 = M9 `S13`.
  @JsonValue('SETTINGS_CONTRIBUTION_UPDATE')
  settingsContributionUpdate('SETTINGS_CONTRIBUTION_UPDATE'),

  /// ⏸ `m2-8_naming.md` A-14(G-64) — 캘린더 재연결.
  /// ⏸ 사유 = X4 채택 자체가 미결이다(§8-5). **이름만 등재**한다.
  /// ⏸ v1.24 — R9d(E17 뒤).
  @JsonValue('CALENDAR_RECONNECT')
  calendarReconnect('CALENDAR_RECONNECT');

  const SettingsActionId(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음).
  final String wire;
}

/// 🆕 v1.21(01 §30 · K5 · K39) — `SafetyActions`(M5 · 폰 로컬)의 동작 식별자.
///
/// 🔴 와이어 = 엔진 data_sync 명령 kind 글자 그대로(`kill_switch_store.dart:352` · `pledge_store.dart:15`) —
///    `command_queue.kind` CHECK 대응 아님(폰 로컬 · DDL 0).
/// 🔴 같은 글자 다른 축 — `KILL_SWITCH_RESUME` = `DeviationKindCodes.killSwitchResume`(배지 종류 사전) ·
///    `PLEDGE_WRITE` = `OnboardingSlotIds.pledgeWrite`(슬롯 이름 사전). 열거 와이어 ↔ 사전 값이라 C-5 충돌 아님.
/// 🔴 1.21.0 의 값은 전부 **제출 DTO 경로**(`runKillResumeItem` · `runPledge`)이고 `run(id, args)` 가 받는 값은 0 이다
///    (화이트리스트 = 1.22.0 · K39). 개수를 숫자로 적지 않는다(G-91).
/// 🆕 v1.22(01 §31 · K52) — `run(id, args)` 화이트리스트 = `interventionStep` · `ruleChangeCancel` · `reconClear` ·
///    `seasonalWindowChoice`(엔진이 `SafetyActionCall` 에 완성) · 그 밖 값 = 제출 DTO 경로(`run…` 메서드).
/// 🆕 v1.26(01 §35 · K178 · K181) — `reconClear` 를 `run` 화이트리스트에서 뺐다(`runReconClear` · 값은 결과 id 로 남는다) ·
///    `ruleChangeRequest` 추가(`runRuleChangeRequest` 전용).
enum SafetyActionId {
  /// 킬스위치 재개 게이트(M5-2) 문항 제출의 결과 id — 7번 통과 = 해제.
  @JsonValue('KILL_SWITCH_RESUME')
  killSwitchResume('KILL_SWITCH_RESUME'),

  /// 서약 첫 판(`O-04` ② · 언제든 · 한 번만 — 엔진 R67 Z1).
  @JsonValue('PLEDGE_WRITE')
  pledgeWrite('PLEDGE_WRITE'),

  /// 서약 편집(새 판 · 12월 창만 — 엔진 R67 Z2 · M5-8).
  @JsonValue('PLEDGE_EDIT')
  pledgeEdit('PLEDGE_EDIT'),

  /// 🆕 v1.22(01 §31 · K52 · K53) — `M5-3` STOPPED 결정 A·B·C(제출 `runStoppedDecision` · 엔진 ds `stopped_decision_store.dart:19`).
  @JsonValue('STOPPED_DECISION')
  stoppedDecision('STOPPED_DECISION'),

  /// 🆕 v1.22 — `M5-3`·`M5-4` 사건 postmortem 쓰기(제출 `runPostmortem` · ds `incident_store.dart:13`).
  @JsonValue('INCIDENT_POSTMORTEM')
  postmortemRecord('INCIDENT_POSTMORTEM'),

  /// 🆕 v1.22(K55) — `M5-5` 대사 불일치 해제(`run{origin_code, decision_id}` · 🔵 엔진 명령 kind 0 → 계약이 짓는다 ·
  /// `DeviationKindCodes.reconClear` 배지 사전 · 저널 kind 와 같은 글자 = 축 다름).
  @JsonValue('RECON_CLEAR')
  reconClear('RECON_CLEAR'),

  /// 🆕 v1.22 — `M5-6` 수동 개입 한 단계(`run{session_id, stage, outcome, decision_id?}` · ds `intervention_store.dart:16` ·
  /// «아무것도 안 하기» 도 같은 동작 · outcome 만 다르다 — 메모 K17).
  @JsonValue('INTERVENTION_STEP')
  interventionStep('INTERVENTION_STEP'),

  /// 🆕 v1.22 — `M5-6`·`M5-7` 재량 조정(제출 `runDiscretionAdjust` · ds `discretion_store.dart:15`).
  @JsonValue('DISCRETION_ADJUST')
  discretionAdjust('DISCRETION_ADJUST'),

  /// 🆕 v1.26(01 §35 · K178) — `M5-9` 규칙 변경 요청(첫 승인 포함 · 제출 `runRuleChangeRequest` 전용 — `run` 으로 받지 않는다 ·
  /// ds `rule_change_store.dart` `kRuleChangeRequestKind` 와 같은 글자).
  @JsonValue('RULE_CHANGE_REQUEST')
  ruleChangeRequest('RULE_CHANGE_REQUEST'),

  /// 🆕 v1.22 — `M5-9` 규칙 변경 요청 취소(`run{request_id}` · ds `rule_change_store.dart:17` · 요청 = 🆕 v1.26 M5-9 `ruleChangeRequest`(`runRuleChangeRequest`) · M9 `strategyApplyRequest` = S04 편집기 판).
  @JsonValue('RULE_CHANGE_CANCEL')
  ruleChangeCancel('RULE_CHANGE_CANCEL'),

  /// 🆕 v1.22 — `M5-9` 규칙 변경 승인(제출 `runRuleChangeApproval` · ds `rule_change_store.dart:18`).
  @JsonValue('RULE_CHANGE_APPROVE')
  ruleChangeApprove('RULE_CHANGE_APPROVE'),

  /// 🆕 v1.22(K54) — X2 재개 게이트 계절 A 진입 3택(`run{work_id, choice}` · 🔵 엔진 명령 kind 0 → 계약이 짓는다 ·
  /// ds `jobs/resume_job.dart:399` `applySeasonalChoice` · `decision_id` = 구현이 짓는다).
  @JsonValue('SEASONAL_WINDOW_CHOICE')
  seasonalWindowChoice('SEASONAL_WINDOW_CHOICE'),

  /// 🆕 v1.32(01 §41 · K254 · E16j-a) — X5 아무것도 안 하기(`run{diff_id}` · 화이트리스트 · ACCEPTED).
  @JsonValue('REPAIR_ACCEPT')
  repairAccept('REPAIR_ACCEPT'),

  /// 🆕 v1.32(K255) — X5 정본 정정(제출 `runRepairCorrect` · 결과 id).
  @JsonValue('REPAIR_CORRECT')
  repairCorrect('REPAIR_CORRECT'),

  /// 🆕 v1.32(K256) — X5 새 기준점(제출 `runRepairBaseline` · 결과 id).
  @JsonValue('REPAIR_BASELINE')
  repairBaseline('REPAIR_BASELINE'),

  /// 🆕 v1.32(K252) — 개입 3단계 사전 저널(제출 `runInterventionJournal` · 결과 id · M5-6 공용).
  @JsonValue('INTERVENTION_JOURNAL')
  interventionJournal('INTERVENTION_JOURNAL'),

  /// 🆕 v1.33(01 §42 · K273 · E16j-b) — X1 옛 폰 «봤습니다 — 이전 시작»(`run{}` · D-03 확인 결정 = 구현).
  @JsonValue('X1_PLAN_START')
  x1PlanStart('X1_PLAN_START'),

  /// 🆕 v1.33(K273) — X1 옛 폰 단계 진행(`run{run_id, step}`).
  @JsonValue('X1_PLAN_STEP')
  x1PlanStep('X1_PLAN_STEP'),

  /// 🆕 v1.33(K273) — X1 옛 폰 이전 그만두기(`run{run_id, step}` · DEMOTED 앞 행만).
  @JsonValue('X1_PLAN_ABORT')
  x1PlanAbort('X1_PLAN_ABORT'),

  /// 🆕 v1.33(K273) — X1 새 폰 비상 시작(`run{}` · 선언 결정 + 복구 코드 슬롯 → epoch+1 = 구현).
  @JsonValue('X1_EMERGENCY_START')
  x1EmergencyStart('X1_EMERGENCY_START'),

  /// 🆕 v1.33(K273) — X1 재발급 한 항목 기록(`run{run_id, item}` · 값 = 슬롯 ↔ 구현 · 지문만 엔진).
  @JsonValue('X1_REISSUE_RECORD')
  x1ReissueRecord('X1_REISSUE_RECORD'),

  /// 🆕 v1.33(K273) — X1 새 폰 복구 단계(`run{run_id, step}` · 골든 · 체크리스트 · 생체 = 구현이 가른다 · 생체 = 구현 K11).
  @JsonValue('X1_RECOVERY_STEP')
  x1RecoveryStep('X1_RECOVERY_STEP'),

  /// 🆕 v1.37(01 §46 · K319) — `M5-13` 보관 명령 일괄 확정(`run{review_id}` · 엔진 완성 `SelfAuditResolveVm.confirmHeld` ·
  /// 거부 = `HeldReviewResultCodes` ∪ `BIOMETRIC_UNAVAILABLE` · 생체 = 구현 K11 · 버림 동작 0).
  @JsonValue('HELD_COMMANDS_CONFIRM')
  heldCommandsConfirm('HELD_COMMANDS_CONFIRM');

  const SafetyActionId(this.wire);

  /// 표기(01 §1-2).
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/draft.dart`

```dart
// 01 §12-1 — 🆕 계약 v1.2. 기기 로컬 초안 포트(`DraftStore`)의 «종류» 축.
//
// 🔴 이 열거형은 **영역 A 가 소유**하고 `lib/src/commands/` 는 import 만 한다(command.dart 머리와 같은 규칙).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 초안을 둘 수 있는 입력 폼의 종류.
///
/// 🔴 **Dart 이름과 JSON 표기가 [CommandKind] 의 같은 이름 값과 똑같다**(C-35 ②) — 초안은 그 명령의
///    전 단계다. X7 4종의 어순 비대칭(`manualFillRecord` ↔ `'RECORD_MANUAL_FILL'`)도 그대로 물려받는다.
/// 🔴 **영구 제외 7종** — `BLIND_REVIEW_SCORE`(`J-4` 는 «제출 전 뒤로가기 = 점수 미저장»이 수용 기준 ·
///    02 §3-4 (b)) · `KILL_SWITCH_ACTIVATE` · `DISCLOSURE_VIEW` · `DEPOSIT_REGISTER` · `ALERT_ACK` ·
///    `KILL_CHECKLIST_CONFIRM` · 🆕 v1.12 `DEFER_ADVICE_CONFIRM`(확인·즉시성 명령 · K14 ⓐ). C-35 ② 가 막는다.
/// ⏸ `M5-12` 정정·무효(`manualFillAmend`·`manualFillVoid`)는 M5 창이 본문 DTO 와 함께 더한다.
enum DraftKind {
  @JsonValue('JOURNAL_DRAFT')
  journalDraft('JOURNAL_DRAFT'),
  @JsonValue('RECORD_MANUAL_FILL')
  manualFillRecord('RECORD_MANUAL_FILL'),
  @JsonValue('SKIP_ADVICE')
  adviceSkip('SKIP_ADVICE'),
  @JsonValue('SELF_REPORT_BALANCE')
  selfReportBalance('SELF_REPORT_BALANCE');

  const DraftKind(this.wire);

  /// JSON 표기. 🔴 `CommandKind.values.byName(name).wire` 와 같다(C-35 ②).
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/handbook.dart`

```dart
// 🆕 계약 v1.17(01 §26 · K13) — M8 `B-01` 목차 항목 상태.
import 'package:freezed_annotation/freezed_annotation.dart';

/// `B-01` 목차 항목 상태 — 🔴 화면은 **아이콘·색 선택에만** 쓴다(글자 = `HandbookEntry.stateLabel`).
/// [preparing] = 원고 대기(04 §8 ⑥⑦⑧ · 06 §3-11 HB-1~HB-3 — 본문을 대신 쓰지 않는다) ·
/// [archived] = 보관됨(새틀라이트 — «왜 없앴나» 한 단락 · 목차에서 접힘 = 엔진이 상태 글자로 보낸다 · 화면 접기 판정 0).
enum HandbookEntryState {
  @JsonValue('READY')
  ready('READY'),
  @JsonValue('PREPARING')
  preparing('PREPARING'),
  @JsonValue('ARCHIVED')
  archived('ARCHIVED');

  const HandbookEntryState(this.wire);

  /// JSON 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/incident.dart`

```dart
// 🆕 계약 v1.17(01 §26 · K8) — M8 `D-01` 장애 배너 종류.
import 'package:freezed_annotation/freezed_annotation.dart';

/// `D-01` 장애 종류 — 🔴 화면은 **아이콘 선택에만** 쓴다(문구·조치는 [IncidentBanner] 가 완성해 준다 · 04 §6).
/// 🔴 모르는 wire 값 = [other](`IncidentBanner.kind` 의 `unknownEnumValue` · 엔진이 종류를 늘려도 화면이 죽지 않는다).
/// 원천: [phoneDown] = 뷰어가 rm_* 신선도로 파생(죽은 폰은 push 못 한다 · 04 §2-3) · 그 밖 = 엔진 `incidents` 표(06 숙제).
enum IncidentKind {
  @JsonValue('PHONE_DOWN')
  phoneDown('PHONE_DOWN'),
  @JsonValue('NETWORK_DOWN')
  networkDown('NETWORK_DOWN'),
  @JsonValue('TOKEN_EXPIRED')
  tokenExpired('TOKEN_EXPIRED'),
  @JsonValue('ORDER_REJECTED')
  orderRejected('ORDER_REJECTED'),
  @JsonValue('OTHER')
  other('OTHER');

  const IncidentKind(this.wire);

  /// JSON 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/journal.dart`

```dart
// 01 §2-2 «TradeJournalEntry» · §2-1(X7) — 일지·체결 축(인벤토리 §2-4).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-2 — 체결 1행의 상태.
///
/// 🔴 `reversed`·`restated` 는 X7 §10-3 정정 규약(역분개 + 재기재)이다.
/// 🔴 `prevented` = «이중 발주 차단 작동» 이며 **성공으로 렌더**한다.
///    `unknown` 은 UNKNOWN 해소 보드로 딥링크한다.
/// 🔴 C-12(`default:` 없는 망라 switch)가 전 화면을 동시에 깨뜨리는 것이 **의도된 게이트**다.
/// 🆕 v1.17(엔진 D11 · 13 §8 R33 D5 · 04_안전장치 §3-1 ③) — `expired` = 일 마감 실효(🔴 취소 아님 · 잔량 = 다음 거래일 의도로 이월 · 근거 칩 `JournalReasonCodes.dayEndExpired`).
enum JournalStatus {
  @JsonValue('FILLED')
  filled('FILLED'),
  @JsonValue('PARTIAL')
  partial('PARTIAL'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('UNKNOWN')
  unknown('UNKNOWN'),
  @JsonValue('SKIPPED')
  skipped('SKIPPED'),
  @JsonValue('PREVENTED')
  prevented('PREVENTED'),
  @JsonValue('REVERSED')
  reversed('REVERSED'),
  @JsonValue('RESTATED')
  restated('RESTATED');

  const JournalStatus(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-2 — 「체결 → 표시 as-of 계약」의 3상태(청사진 §9-2).
/// ✅ `m2-8_naming.md` A-1 로 초안 지위 해제 — 값은 01 §2-2 원문 3값 그대로다.
enum FillVisibility {
  @JsonValue('SETTLED')
  settled('SETTLED'),
  @JsonValue('PENDING_BATCH')
  pendingBatch('PENDING_BATCH'),
  @JsonValue('AWAITING_CONFIRM')
  awaitingConfirm('AWAITING_CONFIRM');

  const FillVisibility(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1(X7) · `executions.fill_origin` CHECK — 체결 1행의 **출처**.
/// 🔴 원장은 한 스트림이고, [FillOrigin]·[FillKind] 두 값이 그 안에서 «누가·무엇을» 말한다.
enum FillOrigin {
  @JsonValue('BROKER')
  broker('BROKER'),
  @JsonValue('MANUAL')
  manual('MANUAL'),
  @JsonValue('SIMULATED')
  simulated('SIMULATED'),
  @JsonValue('BROKER_RECOVERED')
  brokerRecovered('BROKER_RECOVERED');

  const FillOrigin(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(X7) · `executions.fill_kind` CHECK — 체결 1행의 **성격**.
/// 🔴 정정 1회 = `REVERSAL` + `RESTATEMENT` **2행**이며 UPDATE·DELETE 는 없다(C-21).
enum FillKind {
  @JsonValue('ORIGINAL')
  original('ORIGINAL'),
  @JsonValue('REVERSAL')
  reversal('REVERSAL'),
  @JsonValue('RESTATEMENT')
  restatement('RESTATEMENT');

  const FillKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1(X7 C18) · `executions.cost_source` CHECK — 비용의 출처.
///
/// 🔴 구 `costsOverridden`(bool) 은 **폐기**됐다 — 하나로는 «브로커 확정»과 «엔진 추정»이
///    구별되지 않는다. 추정치를 확정치처럼 그리지 않는다는 원칙을 비용에도 적용한 것이며,
///    `estimated` 배지의 존재는 C-24 가 검사한다.
enum CostSource {
  @JsonValue('BROKER')
  broker('BROKER'),
  @JsonValue('USER_ENTERED')
  userEntered('USER_ENTERED'),
  @JsonValue('ESTIMATED')
  estimated('ESTIMATED');

  const CostSource(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/ledger.dart`

```dart
// 01 §2-9 «X5 정합» · §2-1(X7 신뢰) 축(인벤토리 §2-9).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-9 · `ledger_diff.pair` CHECK **재작성 N-01**(4값 → 5값).
///
/// 🔴 재작성 없이 `applicable = 0` 의 `CANON_SELF_REPORT` 행을 넣으면 CHECK 위반으로
///    보드가 4칸으로 퇴화한다. 🔴 보드 칸 수는 모드와 무관하게 **5 고정**이다.
/// 🔵 `canonSelfReport` 의 기본 심각도는 `observational` 이다(A12) — 차단은 «차이의 크기»가
///    아니라 «실사의 부재»(`SELF_AUDIT_OVERDUE`)에만 건다.
/// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
///    주문을 막지 않는다**.
enum LedgerPair {
  @JsonValue('CANON_BROKER')
  canonBroker('CANON_BROKER'),
  @JsonValue('CANON_SUPABASE')
  canonSupabase('CANON_SUPABASE'),
  @JsonValue('CANON_GITHUB')
  canonGithub('CANON_GITHUB'),
  @JsonValue('CANON_CALENDAR')
  canonCalendar('CANON_CALENDAR'),
  @JsonValue('CANON_SELF_REPORT')
  canonSelfReport('CANON_SELF_REPORT');

  const LedgerPair(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-9 · `ledger_diff.axis` CHECK.
enum LedgerAxis {
  @JsonValue('QUANTITY')
  quantity('QUANTITY'),
  @JsonValue('EXECUTION_ROW')
  executionRow('EXECUTION_ROW'),
  @JsonValue('CASH')
  cash('CASH'),
  @JsonValue('CHAIN_HASH')
  chainHash('CHAIN_HASH');

  const LedgerAxis(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 · `ledger_diff.severity` CHECK.
enum DiffSeverity {
  @JsonValue('BLOCKING')
  blocking('BLOCKING'),
  @JsonValue('OBSERVATIONAL')
  observational('OBSERVATIONAL');

  const DiffSeverity(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 · `ledger_diff.status` CHECK.
enum DiffStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('RESOLVED')
  resolved('RESOLVED'),
  @JsonValue('ACCEPTED')
  accepted('ACCEPTED');

  const DiffStatus(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-9 — 복구 경로. DDL 대응 컬럼이 없는 **뷰모델 파생값**이다.
/// 🔴 `x1Emergency` ↔ `'X1_EMERGENCY'` — 숫자를 낀 camelCase 의 표기 규약을 여기서 못 박는다
///    (`m2-8_naming.md` B-5 · `X_1_EMERGENCY` 가 아니다).
enum RepairRoute {
  @JsonValue('AUTO')
  auto('AUTO'),
  @JsonValue('APPROVAL')
  approval('APPROVAL'),
  @JsonValue('X1_EMERGENCY')
  x1Emergency('X1_EMERGENCY');

  const RepairRoute(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1(X7) — 원장을 얼마나 믿을 수 있는가.
///
/// 🔴 배너·리포트 헤더·안내 발행 범위의 유일한 근거다.
/// 🔴 `selfReported` 는 **실패가 아니라 정상 운영 상태**다 — 키 없이 도는 것이 요구의 핵심이다.
enum LedgerTrustGrade {
  @JsonValue('RECONCILED')
  reconciled('RECONCILED'),
  @JsonValue('SELF_REPORTED')
  selfReported('SELF_REPORTED'),
  @JsonValue('DRIFTING')
  drifting('DRIFTING'),
  @JsonValue('UNVERIFIABLE')
  unverifiable('UNVERIFIABLE');

  const LedgerTrustGrade(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · X7 ㊲ — **매매가 아닌데 원장을 바꾸는 사실**(계약 v1.10 · 설계 13 §8 R21 · `m2-8_naming.md`
/// A-15 · J-6 이름 그대로).
///
/// 🔴 네 값의 효과가 다르다 — 인출 = 현금 − · TWR 외부 흐름 / 분배금 = 현금 + · 수익 /
///    원천징수 = 현금 − · 비용 / 기업행위 = 수량 × 비율(현금 없음 · 병합 단주 대금만).
///    현금 효과는 엔진이 같은 트랜잭션에서 `cash_flow` 로 투영한다([CashFlowKind] · R21 L1).
/// 🔴 채택되지 않았다면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 현금 추정이 단조적으로
///    어긋나고 그 위에서 안내 수량이 계산된다(J-6 조문).
enum LedgerEventKind {
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('DISTRIBUTION')
  distribution('DISTRIBUTION'),
  @JsonValue('CORPORATE_ACTION')
  corporateAction('CORPORATE_ACTION'),
  @JsonValue('TAX_WITHHELD')
  taxWithheld('TAX_WITHHELD');

  const LedgerEventKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// ㊲ 기업행위의 v1 범위 — **분할·병합만**(설계 13 §8 R21 L5).
///
/// 🔴 합병·상장폐지·권리는 종목 자체가 바뀌므로 `CORPORATE_ACTION_UNSUPPORTED` 로 거부하고
///    `L-3` 실사로 원장을 다시 세운다.
enum CorporateActionType {
  @JsonValue('SPLIT')
  split('SPLIT'),
  @JsonValue('REVERSE_SPLIT')
  reverseSplit('REVERSE_SPLIT');

  const CorporateActionType(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// `cash_flow.kind` — 매매가 아닌 현금 이동 전부(설계 13 §8 R21 L1 · 계약 v1.10).
///
/// 🔴 **현금 = `Σ cash_flow + Σ executions`** 두 갈래로 순진한 SUM 이 옳다 — 원장 사건의 현금 효과를
///    별도 표에 두지 않는 이유다(현금이 틀리면 안내 수량이 조용히 줄어든다).
/// 🔴 대가: TWR·MWR 의 **외부 흐름**은 이 중 일부뿐이다 — 판정은 [CashFlowKindIsExternal.isExternal]
///    **하나로만** 한다(분배금·원천징수·단주 대금은 수익·비용이지 외부 흐름이 아니다).
enum CashFlowKind {
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT'),
  @JsonValue('WITHDRAWAL')
  withdrawal('WITHDRAWAL'),
  @JsonValue('DISTRIBUTION')
  distribution('DISTRIBUTION'),
  @JsonValue('TAX_WITHHELD')
  taxWithheld('TAX_WITHHELD'),
  @JsonValue('CASH_IN_LIEU')
  cashInLieu('CASH_IN_LIEU');

  const CashFlowKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// TWR·MWR 의 «외부 현금흐름» 판정의 **유일한** 창구(설계 13 §8 R21 L1).
///
/// 🔴 `default:` 없는 망라 switch 다 — 값이 늘면 컴파일이 깨져 판정을 다시 하게 만든다(C-12).
extension CashFlowKindIsExternal on CashFlowKind {
  bool get isExternal => switch (this) {
    CashFlowKind.deposit || CashFlowKind.withdrawal => true,
    CashFlowKind.distribution ||
    CashFlowKind.taxWithheld ||
    CashFlowKind.cashInLieu => false,
  };
}

// ✅ `CORPORATE_ACTION` vs `CORP_ACTION` = **`CORPORATE_ACTION` 으로 통합**(계약 v1.9.0 · R19 E9-4 ·
//    인벤토리 §10-2 ③ 해소). 픽스처·신규 코드는 `CORPORATE_ACTION` 만 쓴다.
```

---

## `packages/domain_contracts/lib/src/enums/market_data.dart`

```dart
// 🆕 계약 v1.14(E8a · 설계 13 §8 R23 D7 · R24 B4 · R25 G3) — 시세·지표 데이터의 출처.
//
// 🔴 이 값은 «어디서 받았나»의 기록이다 — `market_series.source` · `daily_prices.source` · `fetch_log.source`
//    (배치 G) 의 CHECK 와 C-15 가 맞댄다. 화면은 이 값을 표시·분기하지 않는다(엔진·저장소 전용).
// 🔴 `AsOfSource`(LOCAL_SQLITE · SUPABASE_MIRROR · ARCHIVE)는 «저장 위치»이고 이것은 «원천»이다 — 다른 축.

import 'package:json_annotation/json_annotation.dart';

/// 시세·지표의 원천(R23 D1 «세 소스» + 시드 · 폴백 · 수기).
enum MarketDataSource {
  /// 동결 번들 시드(R23 D9 — 2026-08-14 기준일까지).
  @JsonValue('SEED_BUNDLE')
  seedBundle('SEED_BUNDLE'),

  /// 한국투자증권 Open API(국내 일봉 · 국내 지수 · 휴장일 · 해외 시세 — R23 D2).
  @JsonValue('KIS')
  kis('KIS'),

  /// FRED API(JSON).
  @JsonValue('FRED')
  fred('FRED'),

  /// FRED 키 없는 CSV 경로(`fredgraph.csv` — 폴백 · FR-111).
  @JsonValue('FRED_CSV')
  fredCsv('FRED_CSV'),

  /// OFR 금융스트레스지수 사이트(FR-110).
  @JsonValue('OFR')
  ofr('OFR'),

  /// 사람이 넣은 값(정정 · 장애 대체 — 근거는 `fetch_log.detail`).
  @JsonValue('MANUAL')
  manual('MANUAL');

  const MarketDataSource(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/mode.dart`

```dart
// 01 §2-1 · §9(X6 모의투자) · §10(X7 투자 안내) — **직교하는 3축**(인벤토리 §2-2).
//
// 🔴 세 축은 서로를 대체하지 않는다:
//    `RunMode`        = 어느 계좌·어느 서버인가
//    `OperatingMode`  = 누가 주문을 집행하는가
//    `ExecPolicy`     = 엔진이 이번 배치에 바깥으로 무엇을 내보내는가
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · §9-1 — X6 모의투자 모드의 축(Q-E).
///
/// ✅ 적대 검증 완료(2026-09-07 · §9-5)로 초안 지위 해제 · `m2-8_naming.md` A-3 확정.
/// 🔴 화면은 세 값을 개별 분기하지 말고 뷰모델이 준 라벨·배지를 그린다. 「모의냐」 판정이 꼭
///    필요하면 [RunModeIsSim.isSim] 만 쓴다(01 §2-1 주석 원문).
/// 🔴 화면은 이 값으로 타이틀 접두를 만들지 않는다 — 셸이 주입하고 C-17 이 강제한다.
/// ✅ 로컬 DDL = **3값 + 파일별 CHECK**(계약 v1.9.0 · 설계 13 §8 R19 E9-2 · R20 Q1 · 인벤토리 §10-2 ②
///    해소) — `ledger.sqlite` 는 `LIVE` 만, `ledger_sim.sqlite` 는 SIM 계열만 받는다. 파일은
///    `LedgerFile.of` 가 정하고 SIM 판 CHECK 는 `ledgerDdlFor` 가 만든다.
enum RunMode {
  @JsonValue('SIM_INTERNAL')
  simInternal('SIM_INTERNAL'),
  @JsonValue('SIM_BROKER')
  simBroker('SIM_BROKER'),
  @JsonValue('LIVE')
  live('LIVE');

  const RunMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 — 「SIM 계열 = {simInternal, simBroker}」의 **유일한** 판정 창구.
///
/// 🔴 `default:` 없는 망라 switch 다 — 값이 늘면 컴파일이 깨진다(C-12 의 의도된 게이트).
extension RunModeIsSim on RunMode {
  bool get isSim => switch (this) {
    RunMode.simInternal || RunMode.simBroker => true,
    RunMode.live => false,
  };
}

/// 01 §9-5 ① · §10-1 — 「이번 배치가 어디까지 가는가」.
/// `m2-8_naming.md` A-4 확정.
///
/// 🔴 **`FeatureFlags` 에 넣지 않는다**(01 §2-1 조문) — 넣는 순간 화면이 3축을 곱해 분기한다.
/// 🔴 **3값으로 넓히지 않는다**(§10-1) — 넓히면 골든벡터 재검증 실패의 `dryRun` 강등이
///    발주자가 고른 운영 방식을 덮어써 지우고, 복구 시 원래 값을 알 수 없어 그림자 필드가
///    필요해지며, 그것이 §8-7 이 닫은 이중 정본의 부활이다.
/// ✅ 구 `order_intents.dry_run` 의 «이름만 바꾼 것»이며 **컬럼은 그대로 둔다**(계약 v1.9.0 ·
///    설계 13 §8 R19 E9-5 · 인벤토리 §10-2 ④ 해소). 파생 규칙: `dry_run = 1` ⇔ [ExecPolicy.dryRun] ·
///    `dry_run = 0` ⇔ [ExecPolicy.execute]. 🔴 [RunMode] 와 독립이다 — 강등은 이 값만 바꾼다.
enum ExecPolicy {
  @JsonValue('DRY_RUN')
  dryRun('DRY_RUN'),
  @JsonValue('EXECUTE')
  execute('EXECUTE');

  const ExecPolicy(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-1 · §10-1(X7) — 「누가 주문을 집행하는가」.
///
/// 🔴 값을 바꾸는 유일한 경로는 M5 게이트(`M5-10`)·위저드(`M5-11`)다.
/// 🔴 **엔진의 어떤 안전 강등도 이 값을 건드리지 않는다** — 강등은 [ExecPolicy] 전용이다
///    (§9-5 ①③ · C-20 이 검사한다).
/// 🔴 화면은 이 값으로 문구를 고르지 않는다 — 라벨은 뷰모델, 접두·띠는 셸 주입(§10-5 · C-18).
enum OperatingMode {
  @JsonValue('AUTO_TRADE')
  autoTrade('AUTO_TRADE'),
  @JsonValue('ADVISORY')
  advisory('ADVISORY');

  const OperatingMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/onboarding.dart`

```dart
// 01 §2-10 «X3 온보딩» 축(인벤토리 §2-11).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-10 · `onboarding_progress.track` CHECK.
/// 🔴 갈래별 준비물의 근거는 `onboarding_choice` 이며 `OnboardingRepository.watchSteps` 에
///    `OperatingMode` 를 인자로 넘기지 않는다(G-01).
enum OnboardingTrack {
  @JsonValue('FRESH')
  fresh('FRESH'),
  @JsonValue('RECONNECT')
  reconnect('RECONNECT'),
  @JsonValue('VIEWER_PAIRING')
  viewerPairing('VIEWER_PAIRING');

  const OnboardingTrack(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-10 — 단계의 필수도.
///
/// 🔴 `required_` 의 트레일링 언더스코어는 **Dart 예약어 회피**이며 표기에 새지 않는다 —
///    `@JsonValue('REQUIRED')` 로 못 박는다(`m2-8_naming.md` B-2). 기계 변환하면
///    `REQUIRED_` 가 되어 픽스처와 갈린다.
enum StepRequirement {
  @JsonValue('REQUIRED')
  required_('REQUIRED'),
  @JsonValue('RECOMMENDED')
  recommended('RECOMMENDED'),
  @JsonValue('OPTIONAL')
  optional('OPTIONAL');

  const StepRequirement(this.wire);

  /// JSON·DDL 표기. 🔴 `required_` 의 표기는 `'REQUIRED'` 다(언더스코어 없음).
  final String wire;
}

/// 01 §2-10 · `onboarding_progress.state` CHECK.
enum StepState {
  @JsonValue('NOT_STARTED')
  notStarted('NOT_STARTED'),
  @JsonValue('IN_PROGRESS')
  inProgress('IN_PROGRESS'),
  @JsonValue('VERIFIED')
  verified('VERIFIED'),
  @JsonValue('FAILED')
  failed('FAILED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED');

  const StepState(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/order.dart`

```dart
// 01 §2-1 — 주문 방향(인벤토리 §2-3 · `advice.side` CHECK).
import 'package:freezed_annotation/freezed_annotation.dart';

enum OrderSide {
  @JsonValue('BUY')
  buy('BUY'),
  @JsonValue('SELL')
  sell('SELL');

  const OrderSide(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/performance.dart`

```dart
// 01 §2-4 «성과·세후» 축(인벤토리 §2-5).
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간 차액도 금지 —
//    C-30 이 검사한다.
// 🔴 «정직 기대»·사다리 4자리 수치를 코드·라벨·주석에 옮기지 않는다(01 §2-4 조문).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-4 · `rm_performance_point.metric`.
/// 🔵 `twr` 은 **외부 현금흐름 보정판**이다(P 회차 실측으로 MWR 과 유의한 차가 확인됐다).
enum PerfMetric {
  @JsonValue('TWR')
  twr('TWR'),
  @JsonValue('MWR')
  mwr('MWR');

  const PerfMetric(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-4 — 시계열 간격.
enum PerfGranularity {
  @JsonValue('DAILY')
  daily('DAILY'),
  @JsonValue('WEEKLY')
  weekly('WEEKLY'),
  @JsonValue('MONTHLY')
  monthly('MONTHLY'),
  @JsonValue('YEARLY')
  yearly('YEARLY');

  const PerfGranularity(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-4 — 구간의 성격.
///
/// 🔴 `manualExecuted`(X7)는 `simExcluded` 와 달리 **합산에 포함**되고 경계는 실선이다(D6).
///    겹치면 `freshAuto` 절단선이 이긴다.
enum SegmentKind {
  @JsonValue('MEASURED')
  measured('MEASURED'),
  @JsonValue('UNAVAILABLE')
  unavailable('UNAVAILABLE'),
  @JsonValue('SIM_EXCLUDED')
  simExcluded('SIM_EXCLUDED'),
  @JsonValue('MANUAL_EXECUTED')
  manualExecuted('MANUAL_EXECUTED');

  const SegmentKind(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-4(P 회차) — 세후 사다리의 갈래. `m2-8_naming.md` A-7 확정.
///
/// 🔴 **갈래는 계좌 배치가 정한다**(SAF-309) — 화면·인자로 고르는 경로를 만들지 않는다.
///    `PerformanceRepository.afterTaxLadder({required String fiscalYear})` 의 인자는 연도 하나다.
enum TaxLadderBranch {
  @JsonValue('SPEC_POT_TAX_FREE')
  specPotTaxFree('SPEC_POT_TAX_FREE'),
  @JsonValue('CF_POT_TAXABLE_COMP26')
  cfPotTaxableComp26('CF_POT_TAXABLE_COMP26'),
  @JsonValue('CF_POT_TAXABLE_COMP38')
  cfPotTaxableComp38('CF_POT_TAXABLE_COMP38'),
  @JsonValue('CF_POT_TAXABLE_FLAT')
  cfPotTaxableFlat('CF_POT_TAXABLE_FLAT');

  const TaxLadderBranch(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/rebalance.dart`

```dart
// 01 §2-5 — 리밸런싱 회차의 갈래(인벤토리 §2-6 · `rebalance_event.kind` CHECK).
// 🆕 v1.8(01 §17) — `SleeveBandState`(밴드 내 · 경계 근접 · 이탈 — `H6-1` 카드 머리 · `H6-3` 행 색의 원천).
import 'package:freezed_annotation/freezed_annotation.dart';

enum RebalanceKind {
  @JsonValue('MONTHLY_REGULAR')
  monthlyRegular('MONTHLY_REGULAR'),
  @JsonValue('SEASONAL')
  seasonal('SEASONAL'),
  @JsonValue('BAND')
  band('BAND'),
  @JsonValue('REGIME')
  regime('REGIME'),
  @JsonValue('DEPOSIT')
  deposit('DEPOSIT');

  const RebalanceKind(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 🆕 v1.8(01 §17) — 슬리브 밴드 상태. 🔴 판정은 엔진 · 화면은 색만(C-12 exhaustive switch · `default:` 금지).
/// 🔴 파킹은 상태가 아니다 — 신호 미점등 파킹분으로 `outOfBand`·경고색을 만들지 않는다(02 §4-3 «파킹 상태»).
enum SleeveBandState {
  @JsonValue('IN_BAND')
  inBand('IN_BAND'),
  @JsonValue('NEAR_EDGE')
  nearEdge('NEAR_EDGE'),
  @JsonValue('OUT_OF_BAND')
  outOfBand('OUT_OF_BAND');

  const SleeveBandState(this.wire);

  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/resume.dart`

```dart
// 01 §2-7 «X2 재개» 축(인벤토리 §2-7).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-7 · `planned_work.state` CHECK.
/// 🔴 X2 원칙 ① — 종단 상태는 어떤 경로로도 되살아나지 않는다.
enum PlannedWorkState {
  @JsonValue('PLANNED')
  planned('PLANNED'),
  @JsonValue('REEVALUATED')
  reevaluated('REEVALUATED'),
  @JsonValue('SUPERSEDED')
  superseded('SUPERSEDED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('DONE')
  done('DONE'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED');

  const PlannedWorkState(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-7 · `resume_run.mode` CHECK.
enum ResumeMode {
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('CONSERVATIVE')
  conservative('CONSERVATIVE'),
  @JsonValue('RECOVERY_DRY')
  recoveryDry('RECOVERY_DRY'),
  @JsonValue('RECOVERY_FULL')
  recoveryFull('RECOVERY_FULL');

  const ResumeMode(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-7 · `resume_run.phase`.
/// 🔴 DDL 에 `CHECK` 가 없다 — **값 도메인의 정본이 이 열거형**이다(인벤토리 §2-7).
enum ResumePhase {
  @JsonValue('R0')
  r0('R0'),
  @JsonValue('R1')
  r1('R1'),
  @JsonValue('R2')
  r2('R2'),
  @JsonValue('R3')
  r3('R3'),
  @JsonValue('R4')
  r4('R4'),
  @JsonValue('R5')
  r5('R5'),
  @JsonValue('R6')
  r6('R6'),
  @JsonValue('R7')
  r7('R7'),
  @JsonValue('R8')
  r8('R8');

  const ResumePhase(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.22(01 §31 · K10 · K49) — X2 재개 게이트 계절 A 진입 3택(엔진 core `SeasonalWindowChoice` ·
/// `resume/resume_judge.dart:345` · 값 1:1 · 🔴 타입 이름 ≠ 엔진(`ambiguous_import`) · 엔진 enum 에 wire 0 → 와이어 = 값 이름의
/// 기계적 SCREAMING_SNAKE · 엔진이 따른다 · «아무것도 안 하기» = 고르지 않음(1월 만료)).
enum SeasonalEntryChoice {
  @JsonValue('SKIP')
  skip('SKIP'),
  @JsonValue('REDUCED')
  reduced('REDUCED'),
  @JsonValue('AS_IS')
  asIs('AS_IS');

  const SeasonalEntryChoice(this.wire);

  /// JSON 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/safety.dart`

```dart
// 01 §2-10 «알림·브레이커» 축(인벤토리 §2-10).
//
// 🔴 소유 경계는 타입이 아니라 «무엇을 그리는가» 다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**. C-7 이 그 표대로 검사한다.
// 🆕 v1.21(01 §30) — 킬스위치 발동 기록·재개 열거 4(엔진 값 1:1 · 이름 따로 · 와이어 = 값 이름 SCREAMING_SNAKE).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-10 — 알림 등급.
/// 🔴 **표시 계층의 사적 재분류 금지**(결정 7c). 배치 E 가 구 `INFO`/`ALERT`/`DIGEST` 를
///    이 3값으로 개편한다.
enum AlertLevel {
  @JsonValue('P0')
  p0('P0'),
  @JsonValue('P1')
  p1('P1'),
  @JsonValue('P2')
  p2('P2');

  const AlertLevel(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-10 — 브레이커 단계.
/// 🔵 `stopped` 의 자격 판정은 명세 v2.29 조문이 정한다 — 화면은 `stoppedReleaseEligible`
///    필드를 그대로 그리고 자격을 재판정하지 않는다.
enum BreakerLevel {
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('ALERT')
  alert('ALERT'),
  @JsonValue('REDUCED')
  reduced('REDUCED'),
  @JsonValue('HALTED')
  halted('HALTED'),
  @JsonValue('STOPPED')
  stopped('STOPPED');

  const BreakerLevel(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-10·§3-5 — 차단 플래그의 해제 경로.
/// 🔴 해제 문구는 **플래그마다 다르다**(`BlockFlag.clearInstruction`) — 화면이 경로로
///    문구를 고르지 않는다.
/// 🆕 v1.25(01 §34 · K155) — 짝 글자 = `BlockBoardRow.clearKindLabel`(엔진).
enum ClearRoute {
  @JsonValue('AUTOMATIC')
  automatic('AUTOMATIC'),
  @JsonValue('CAUSE_CODE_REQUIRED')
  causeCodeRequired('CAUSE_CODE_REQUIRED'),
  @JsonValue('NO_MANUAL_PATH')
  noManualPath('NO_MANUAL_PATH'),
  @JsonValue('WIZARD_ONLY')
  wizardOnly('WIZARD_ONLY');

  const ClearRoute(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 🆕 v1.21(01 §30 · K10 · K33) — 카드 ④ 2번 «끄는 것이 규칙인가 감정인가»(엔진 core `KillReasonKind` ·
/// `safety/kill_checklist.dart:12` 와 값 1:1). 🔴 타입 이름은 엔진과 다르다(같은 이름 = 엔진 시험 `ambiguous_import`) ·
/// 와이어 = 엔진 값 이름의 기계적 SCREAMING_SNAKE(엔진 enum 에 wire 0 → 엔진이 이 표기를 따른다).
enum KillActivationReason {
  @JsonValue('RULE')
  rule('RULE'),
  @JsonValue('EMOTION')
  emotion('EMOTION');

  const KillActivationReason(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.21 — 카드 ④ 5번 끄는 범위(엔진 `KillScope` · `:21`). 🔴 `liquidateAll` 이어도 앱은 자동으로 팔지 않는다(기록만).
enum KillActivationScope {
  @JsonValue('NEW_ENTRIES_ONLY')
  newEntriesOnly('NEW_ENTRIES_ONLY'),
  @JsonValue('LIQUIDATE_ALL')
  liquidateAll('LIQUIDATE_ALL');

  const KillActivationScope(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.21 — 재개판 3번 «그때 짚은 시나리오가 지금 어떻게 됐는가»(엔진 `ScenarioStatus` · `:157`).
enum KillResumeScenario {
  @JsonValue('RESOLVED')
  resolved('RESOLVED'),
  @JsonValue('ONGOING')
  ongoing('ONGOING'),
  @JsonValue('NOT_APPLICABLE')
  notApplicable('NOT_APPLICABLE');

  const KillResumeScenario(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.21 — 재개판 4번 «그때 적은 재개 조건이 지금 충족됐는가»(엔진 `ResumeConditionStatus` · `:169`).
/// 🔴 `unmet` = 재개하지 않는다(엔진 판정 · 화면이 막지 않는다 — 결과 `RESUME_CONDITION_UNMET`).
enum KillResumeCondition {
  @JsonValue('MET')
  met('MET'),
  @JsonValue('UNMET')
  unmet('UNMET');

  const KillResumeCondition(this.wire);

  /// JSON 표기.
  final String wire;
}

// 🆕 v1.22(01 §31 · K49) — 엔진 값 1:1 · 🔴 타입 이름 ≠ 엔진(`ambiguous_import`).

/// 🆕 v1.22 — `M5-3` STOPPED 결정(엔진 core `StoppedDecisionKind` · `safety/stopped_decision.dart:11` · 와이어 = 엔진 글자 ✅).
/// A = 전량 방어 슬리브 이전 · B = 재가동(자격 = 엔진) · C = 청산(설명 글자 = 엔진 · 화면이 짓지 않는다).
enum StoppedDecisionChoice {
  @JsonValue('A')
  a('A'),
  @JsonValue('B')
  b('B'),
  @JsonValue('C')
  c('C');

  const StoppedDecisionChoice(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 🆕 v1.22 — `M5-6` 개입 한 단계 결과(엔진 `InterventionOutcome` · `safety/intervention.dart:22` · 와이어 ✅) ·
/// 🔴 `doNothing` = «아무것도 안 하기» 도 같은 마찰(동급 배치 · 13 R65 X2).
enum InterventionStepOutcome {
  @JsonValue('PASSED')
  passed('PASSED'),
  @JsonValue('DO_NOTHING')
  doNothing('DO_NOTHING'),
  @JsonValue('ABANDONED')
  abandoned('ABANDONED');

  const InterventionStepOutcome(this.wire);

  /// JSON 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/settings.dart`

```dart
// 01 §4-1 · 05 §1 — M9 설정 3등급(🆕 계약 v1.18 · 01 §27 · K-o).
//
// 🔴 등급은 엔진(M2·M4)이 정한다 — 화면은 이 값으로 **자물쇠 아이콘·묶음 머리**만 고른다(`general` = 자물쇠 0).
//    등급별 마찰(즉시 반영 · 진입 생체 · 냉각 30일·12월 창)은 화면이 아니라 엔진·M5 게이트의 일이다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 05 §1 — 설정 등급.
enum SettingTier {
  @JsonValue('GENERAL')
  general('GENERAL'),
  @JsonValue('OPERATIONAL')
  operational('OPERATIONAL'),
  @JsonValue('RULE')
  rule('RULE');

  const SettingTier(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음 — 뷰모델 전용).
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/sleeve.dart`

```dart
// 01 §2-1 «공통 값 객체» — 슬리브·기준 축(인벤토리 §2-1).
//
// 🔴 열거값의 JSON·DDL 표기는 `@JsonValue` 로 못 박는다(01 §1-2 enum 직렬화 규약).
//    자동 변환에 맡기면 픽스처(§5)·DDL `CHECK`(§6)와 갈라지고 §7 C-15 가 실패한다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 · §6-1 `decision_log.sleeve`·`advice.sleeve` CHECK.
///
/// 🔴 `satellite` ↔ `'SAT'` 은 **기계적 대문자 변환이 아니다**(m2-8_naming B-1).
/// 🔵 v2.31 P0S 에서 `satellite` 는 **열거값 보존·화면 미노출**이다
///    (`satellite_enabled = false`). 🔴 화면이 `SleeveId` 를 순회하며 `satellite` 를 걸러내는
///    코드를 쓰지 않게 슬리브 목록은 `SleeveCatalogEntry` 로 온다 — 거르는 규칙이 화면에
///    생기면 그것이 판정이다.
enum SleeveId {
  @JsonValue('A')
  a('A'),
  @JsonValue('B')
  b('B'),
  @JsonValue('C')
  c('C'),
  @JsonValue('POT')
  pot('POT'),
  @JsonValue('CASH')
  cash('CASH'),
  @JsonValue('SAT')
  satellite('SAT');

  const SleeveId(this.wire);

  /// JSON·DDL 표기. 🔴 바로 위 `@JsonValue` 와 **같은 문자열**이며 한쪽만 고치지 않는다.
  final String wire;
}

/// 01 §2-1(P 회차 K §6 ⑪) — 같은 «비중»에 기준이 둘이다.
/// 섞으면 슬리브 A 가 8.1% 로도 20.2% 로도 보인다.
///
/// - `engineColumn` = 엔진 원장 열(POT 잔액이 C 에 합산됨)
/// - `accounting` = 회계 소속(POT → A, 03 §2-9-3)
///
/// 🔴 목표 배분·밴드 판정과 비교할 수 있는 것은 **`accounting` 하나뿐**이다.
/// 🔴 화면은 `basis` 로 분기하지 않는다 — `SleeveWeight.basis` 는 `accounting` 외 값을 갖지
///    않으며(엔진 쪽 계약), `engineColumn` 행은 진단 전용 별도 창구로만 온다. 혼합은 C-31 이 잡는다.
enum AllocationBasis {
  @JsonValue('ENGINE_COLUMN')
  engineColumn('ENGINE_COLUMN'),
  @JsonValue('ACCOUNTING')
  accounting('ACCOUNTING');

  const AllocationBasis(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/enums/ui.dart`

```dart
// 01 §2-1 — 표시 공통 축(인벤토리 §2-3).
//
// 🔴 이 파일의 네 열거형은 **뷰모델 전용**이라 DDL `CHECK` 대응 컬럼이 없다.
//    그래도 `@JsonValue` 를 붙인다 — 픽스처가 JSON 이고, 자동 변환 0건이 규약이다(인벤토리 §10-1 A).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-1 — 사유 칩의 색조.
/// 🔴 `prevented` 는 **실패가 아니라 방어**다(이중 발주 차단 작동 = 성공으로 렌더).
enum ChipTone {
  @JsonValue('NEUTRAL')
  neutral('NEUTRAL'),
  @JsonValue('CAUTION')
  caution('CAUTION'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED'),
  @JsonValue('PREVENTED')
  prevented('PREVENTED');

  const ChipTone(this.wire);

  /// JSON 표기(01 §1-2).
  final String wire;
}

/// 01 §2-1 — 게이트 판정.
/// 🔴 `unknown` 은 `notApplicable` 과 뜻이 다르다 — X3 리스·기기 원장 판정의 «모름»이며
///    **진행 차단**이다(04 §9-8).
enum GateState {
  @JsonValue('PASS')
  pass('PASS'),
  @JsonValue('BLOCK')
  block('BLOCK'),
  @JsonValue('NOT_APPLICABLE')
  notApplicable('NOT_APPLICABLE'),
  @JsonValue('UNKNOWN')
  unknown('UNKNOWN');

  const GateState(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1 — 색·아이콘의 유일한 근거.
/// 🔴 **값의 부호로 색을 고르지 않는다**(음수=빨강은 손익 은유다).
enum UiLevel {
  @JsonValue('OK')
  ok('OK'),
  @JsonValue('INFO')
  info('INFO'),
  @JsonValue('WATCH')
  watch('WATCH'),
  @JsonValue('ACT')
  act('ACT'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED');

  const UiLevel(this.wire);

  /// JSON 표기.
  final String wire;
}

/// 01 §2-1 — 빈 상태 3분. «없는 것»·«못 받은 것»·«해당 없음» 은 다르다(계약 3조 ③).
enum EmptyKind {
  @JsonValue('NO_DATA')
  noData('NO_DATA'),
  @JsonValue('NOT_LOADED')
  notLoaded('NOT_LOADED'),
  @JsonValue('NOT_APPLICABLE')
  notApplicable('NOT_APPLICABLE');

  const EmptyKind(this.wire);

  /// JSON 표기.
  final String wire;
}
```

---

## `packages/domain_contracts/lib/src/fixtures/fixture_loader.dart`

```dart
// 01 §5 «모의 데이터 픽스처» — 봉투(meta + as_of + empty_kind + empty_label +
// has_more + rows) 디코더와 검증 헬퍼.
//
// 🔴 순수 Dart 여야 한다(인벤토리 §8-5) — `dart:io` 를 쓰면 web viewer 빌드가
//    깨진다. 파일을 읽는 것은 호출자(테스트·화면 하네스)의 일이고 이 파일은
//    «문자열 → DTO» 만 한다.
// 🔴 봉투 필수 4값(as_of·empty_kind·empty_label·has_more)이 하나라도 없으면
//    빈 값으로 넘기지 않고 예외를 던진다(같은 §8-5). 「없음」(NO_DATA + 문구)과
//    「모름」(NOT_LOADED + stale_reason_code)이 화면에서 갈리는 근거가 이 넷이다.
// 🔴 이 파일은 판정하지 않는다(01 §1-4) — 계산 getter·부작용 함수 0건.

import 'dart:convert';

import '../enums/ui.dart'; // EmptyKind — 영역 A
import '../primitives/as_of.dart'; // AsOf — 영역 A
import '../primitives/list_result.dart'; // ListResult<T> — 영역 A

/// 픽스처 봉투가 계약대로 생기지 않았을 때 던진다.
///
/// 🔴 「필드가 없으면 기본값」은 이 계약의 반대다 — 빠진 값은 실패로 드러낸다.
class FixtureFormatException implements Exception {
  const FixtureFormatException(this.message, {this.path});

  /// 사람이 읽을 사유 한 줄.
  final String message;

  /// 문제가 난 자리(`meta.seed`·`rows[3].price` 처럼 점 표기).
  final String? path;

  @override
  String toString() => path == null
      ? 'FixtureFormatException: $message'
      : 'FixtureFormatException: $message (at $path)';
}

/// 봉투 머리의 `meta` 블록(01 §5 봉투 형식).
///
/// 🔴 `contractVersion` 은 `lib/src/contract_version.dart` 상수와 **같은 축**이다
///    — 한쪽만 올리면 C-1(뷰모델 골든)·C-15(픽스처↔DDL)가 갈라진 채 통과한다.
class FixtureMeta {
  const FixtureMeta({
    required this.fixtureVersion,
    required this.contractVersion,
    required this.generatedAt,
    required this.mode,
    required this.configHash,
    required this.seed,
    required this.notice,
  });

  /// 픽스처 묶음 자체의 판본.
  final String fixtureVersion;

  /// 이 픽스처가 표현하는 M2 계약의 판본.
  final String contractVersion;

  /// 픽스처를 생성한 시각(UTC 문자열 원문 — 표시용이 아니다).
  final String generatedAt;

  /// `RunMode` 의 JSON 표기(`SIM_INTERNAL`·`SIM_BROKER`·`LIVE`).
  final String mode;

  /// 합성 config 해시(`cfg_fake_…`).
  final String configHash;

  /// 합성 데이터 생성 시드.
  final int seed;

  /// 「합성 데이터. 실계좌·실키 없음.」 고지 문구.
  final String notice;
}

/// 디코드된 봉투. `rows` 는 아직 DTO 가 아니라 원시 Map 이다.
class FixtureEnvelope {
  const FixtureEnvelope({
    required this.meta,
    required this.asOf,
    required this.emptyKind,
    required this.emptyLabel,
    required this.hasMore,
    required this.rows,
  });

  final FixtureMeta meta;

  /// 봉투의 `as_of` 원문 Map. `AsOf.fromJson` 의 입력이다.
  final Map<String, Object?> asOf;

  /// `EmptyKind` 의 JSON 표기(`NO_DATA`·`NOT_LOADED`·`NOT_APPLICABLE`).
  final String emptyKind;

  /// 빈 목록일 때 화면이 그대로 그릴 문구. 엔진 생성 — 화면이 짓지 않는다.
  final String? emptyLabel;

  final bool hasMore;

  /// 엔진이 **이미 정렬한** 행. 🔴 화면·테스트가 재정렬하지 않는다.
  final List<Map<String, Object?>> rows;
}

/// 봉투 JSON 문자열을 검증하며 디코드한다.
///
/// 필수 키가 없거나 타입이 다르면 [FixtureFormatException].
FixtureEnvelope decodeEnvelope(String json) {
  final Object? decoded = jsonDecode(json);
  if (decoded is! Map<String, Object?>) {
    throw const FixtureFormatException('봉투 최상위가 객체가 아니다.');
  }

  final Map<String, Object?> metaJson = _requireMap(decoded, 'meta');
  final Map<String, Object?> asOfJson = _requireMap(decoded, 'as_of');

  // 🔴 empty_label 은 값이 null 이어도 «키가 있어야» 한다 — 「없음」과
  //    「고지를 아직 못 받았다」를 구별하는 것이 이 계약의 목적이다.
  if (!decoded.containsKey('empty_label')) {
    throw const FixtureFormatException(
      '봉투에 empty_label 키가 없다.',
      path: 'empty_label',
    );
  }
  final Object? emptyLabel = decoded['empty_label'];
  if (emptyLabel != null && emptyLabel is! String) {
    throw const FixtureFormatException(
      'empty_label 은 문자열이거나 null 이다.',
      path: 'empty_label',
    );
  }

  final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
  final Object? rawRows = decoded['rows'];
  if (rawRows is! List) {
    throw const FixtureFormatException('봉투에 rows 배열이 없다.', path: 'rows');
  }
  for (int i = 0; i < rawRows.length; i++) {
    final Object? row = rawRows[i];
    if (row is! Map<String, Object?>) {
      throw FixtureFormatException('행이 객체가 아니다.', path: 'rows[$i]');
    }
    rows.add(row);
  }

  return FixtureEnvelope(
    meta: FixtureMeta(
      fixtureVersion: _requireString(
        metaJson,
        'fixture_version',
        prefix: 'meta',
      ),
      contractVersion: _requireString(
        metaJson,
        'contract_version',
        prefix: 'meta',
      ),
      generatedAt: _requireString(metaJson, 'generated_at', prefix: 'meta'),
      mode: _requireString(metaJson, 'mode', prefix: 'meta'),
      configHash: _requireString(metaJson, 'config_hash', prefix: 'meta'),
      seed: _requireInt(metaJson, 'seed', prefix: 'meta'),
      notice: _requireString(metaJson, 'notice', prefix: 'meta'),
    ),
    asOf: asOfJson,
    emptyKind: _requireString(decoded, 'empty_kind'),
    emptyLabel: emptyLabel as String?,
    hasMore: _requireBool(decoded, 'has_more'),
    rows: rows,
  );
}

/// 봉투 JSON 을 `ListResult<T>` 로 디코드한다(인벤토리 §8-5 시그니처 축).
///
/// [rowFrom] 은 각 DTO 의 `fromJson` 을 그대로 넘긴다.
ListResult<T> decodeList<T>(
  String json,
  T Function(Map<String, Object?>) rowFrom,
) {
  final FixtureEnvelope envelope = decodeEnvelope(json);
  return ListResult<T>(
    rows: envelope.rows.map(rowFrom).toList(growable: false),
    asOf: AsOf.fromJson(envelope.asOf),
    emptyKind: emptyKindFromJson(envelope.emptyKind),
    emptyLabel: envelope.emptyLabel,
    hasMore: envelope.hasMore,
  );
}

/// 단일 객체 픽스처(`resume_report_1.json` 처럼 `rows` 가 1행인 것)의 편의 창구.
///
/// 🔴 행이 정확히 1개가 아니면 예외다 — 「첫 행을 쓴다」는 조용한 판정이 된다.
T decodeSingle<T>(String json, T Function(Map<String, Object?>) rowFrom) {
  final FixtureEnvelope envelope = decodeEnvelope(json);
  if (envelope.rows.length != 1) {
    throw FixtureFormatException(
      '단일 객체 픽스처인데 행이 ${envelope.rows.length}개다.',
      path: 'rows',
    );
  }
  return rowFrom(envelope.rows.single);
}

/// `EmptyKind` 의 JSON 표기 → 열거값(01 §2-1).
///
/// 🔴 표기 문자열의 정본은 영역 A 의 `EmptyKind.wire` 하나다 — 여기에 두 번째
///    목록을 만들지 않는다. 🔴 알 수 없는 값을 기본값으로 흘려보내지 않는다.
EmptyKind emptyKindFromJson(String raw) {
  for (final EmptyKind kind in EmptyKind.values) {
    if (kind.wire == raw) {
      return kind;
    }
  }
  throw FixtureFormatException('알 수 없는 empty_kind: $raw', path: 'empty_kind');
}

// ─────────────────────────────────────────────────────────────────────────────
// 시크릿 스캔 — C-14 의 판정부(인벤토리 §9)
// ─────────────────────────────────────────────────────────────────────────────

/// C-14 가 찾는 패턴 하나.
class SecretPattern {
  const SecretPattern(this.code, this.description, this.pattern);

  /// 사유 코드(테스트 실패 메시지에 그대로 실린다).
  final String code;

  /// 무엇을 찾는가.
  final String description;

  final RegExp pattern;
}

/// C-14 스캔 결과 1건.
class SecretFinding {
  const SecretFinding({
    required this.code,
    required this.description,
    required this.matchedText,
    required this.offset,
  });

  final String code;
  final String description;

  /// 걸린 문자열 원문. 🔴 실키를 로그에 남기지 않기 위해 호출자가 마스킹한다.
  final String matchedText;

  /// 원문에서의 위치(0-기반).
  final int offset;

  @override
  String toString() => '$code($description) @$offset: $matchedText';
}

/// 픽스처 원문에서 시크릿으로 보이는 것을 찾는다(C-14).
///
/// 🔴 판정은 «찾았다/못 찾았다» 뿐이다 — 이 함수는 파일을 고치지 않는다.
List<SecretFinding> scanForSecrets(String text) {
  final List<SecretFinding> findings = <SecretFinding>[];
  for (final SecretPattern rule in secretPatterns) {
    for (final RegExpMatch m in rule.pattern.allMatches(text)) {
      findings.add(
        SecretFinding(
          code: rule.code,
          description: rule.description,
          matchedText: m[0]!,
          offset: m.start,
        ),
      );
    }
  }
  findings.sort(
    (SecretFinding a, SecretFinding b) => a.offset.compareTo(b.offset),
  );
  return findings;
}

/// C-14 패턴 목록(01 §5 대원칙 · 인벤토리 §9 C-14).
///
/// 🔴 「KIS 앱키 · `ya29.` · `1//` · 8자리 계좌」 네 축이 문서가 지목한 것이고,
///    나머지 둘은 같은 사고(자격증명이 픽스처에 새는 것)의 이웃 패턴이다.
/// 🔴 «8자리 이상 연속 숫자» 를 그대로 잡으면 **금액 문자열이 걸린다**
///    (`"30000000"` = 3천만원 인출 · 1억은 9자리다). 그래서 계좌번호는
///    ① 계좌번호꼴(`123456-78`) ② 계좌를 가리키는 키의 값 ③ 「계좌」 뒤의 숫자
///    세 갈래로만 찾는다. 🔴 계좌는 픽스처에 **별칭만** 실리므로 이 셋이면 충분하다.
final List<SecretPattern> secretPatterns = <SecretPattern>[
  SecretPattern(
    'KIS_APP_KEY',
    'KIS 앱키·앱시크릿으로 보이는 긴 영숫자 토큰',
    // KIS 앱키는 36자, 앱시크릿은 180자 안팎의 연속 영숫자다.
    // 픽스처의 정상 값(티커·별칭·`cfg_fake_…`·sha256 앞 12자)은 밑줄·하이픈이
    // 섞이거나 32자 미만이다.
    RegExp('"[A-Za-z0-9]{32,}"'),
  ),
  SecretPattern(
    'GOOGLE_OAUTH_ACCESS_TOKEN',
    'Google OAuth 액세스 토큰 접두 ya29.',
    RegExp(r'ya29\.[A-Za-z0-9_\-]+'),
  ),
  SecretPattern(
    'GOOGLE_OAUTH_REFRESH_TOKEN',
    'Google OAuth 리프레시 토큰 접두 1//',
    RegExp(r'"1//[A-Za-z0-9_\-]+'),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_FORM',
    '계좌번호꼴 숫자(6자리 이상 - 2자리 이상)',
    RegExp('[0-9]{6,}-[0-9]{2,}'),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_FIELD',
    '계좌를 가리키는 키에 실린 8자리 이상 연속 숫자',
    RegExp(
      '"[A-Za-z_]*account[A-Za-z_]*"\\s*:\\s*"[0-9]{8,}"',
      caseSensitive: false,
    ),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_IN_TEXT',
    '문구 안에 적힌 계좌 전체번호',
    RegExp('계좌[^0-9]{0,4}[0-9]{8,}'),
  ),
  SecretPattern(
    'BEARER_TOKEN',
    'Authorization 헤더 형태의 Bearer 토큰',
    RegExp(r'[Bb]earer\s+[A-Za-z0-9._\-]{16,}'),
  ),
  SecretPattern(
    'PRIVATE_KEY_BLOCK',
    'PEM 개인키 블록',
    RegExp('BEGIN [A-Z ]*PRIVATE KEY'),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 원시 접근 헬퍼 — 「없으면 기본값」을 금지하기 위한 것이다.
// ─────────────────────────────────────────────────────────────────────────────

Map<String, Object?> _requireMap(
  Map<String, Object?> json,
  String key, {
  String? prefix,
}) {
  final Object? v = json[key];
  if (v is! Map<String, Object?>) {
    throw FixtureFormatException(
      '$key 블록이 없거나 객체가 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

String _requireString(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! String) {
    throw FixtureFormatException(
      '$key 가 없거나 문자열이 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

int _requireInt(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! int) {
    throw FixtureFormatException(
      '$key 가 없거나 정수가 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

bool _requireBool(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! bool) {
    throw FixtureFormatException(
      '$key 가 없거나 참·거짓이 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

String _path(String? prefix, String key) =>
    prefix == null ? key : '$prefix.$key';
```

---

## `packages/domain_contracts/lib/src/fixtures/fixture_paths.dart`

```dart
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

  /// 🆕 v1.35(01 §44 · K295) — `SafetyState` hold 짝 문장 2행(`LIVE_AWAITING_KEYS` · `MIGRATION_IN_PROGRESS` — `holds[i]` ↔ `holdLabels[i]`).
  static const String safetyStatesHolds = 'safety_states_holds.json';

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

  /// 🆕 v1.37(01 §46 · K318 · K321) — `M5-13` 해소 게이트: 플래그 섬 · 카운터 2 · 열린 자가 보고 차이 2(수량 · 현금) · 실사 링크 1 ·
  /// 보관 1 · 일괄 확정(`SelfAuditResolveVm`).
  static const String m5SelfAuditResolveOpen =
      'm5/self_audit_resolve_open.json';

  /// 🆕 v1.37(K319) — `M5-13` 보관 2 · 무결성 점검 중(확정 null · 막힘 문장) · 차이 0.
  static const String m5SelfAuditResolveHeldBlocked =
      'm5/self_audit_resolve_held_blocked.json';

  /// 🆕 v1.37 — `M5-13` 표식 없음 · 차이 0 · 보관 0(빈 문장들).
  static const String m5SelfAuditResolveClear =
      'm5/self_audit_resolve_clear.json';

  /// 🆕 v1.37(K319) — 보관 명령 일괄 확정 결과 4행(`HELD_COMMANDS_CONFIRM` · 확정 1 · 거부 3 = `HeldReviewResultCodes`).
  static const String m5HeldReviewResults = 'm5/held_review_results.json';

  /// 🆕 v1.39(01 §48 · K345 · 미결 188 · 13 R243 P3 ⓔ) — `M5-4` postmortem 목록 빈 상태(행 0 · `empty_label`).
  static const String m5PostmortemListEmpty = 'm5/postmortem_list_empty.json';

  /// 🆕 v1.39 — `M5-4` SEV2 수동 주문 1건 쓸 차례(기한 전 · 쓰기 칸).
  static const String m5PostmortemListDue = 'm5/postmortem_list_due.json';

  /// 🆕 v1.39 — `M5-4` SEV1 STOPPED 씀(읽기 전용 · STOPPED 결정 링크) + SEV2 기한 넘김(쓰기 칸) · 차례 = 심각도 → 기한.
  static const String m5PostmortemListWrittenOverdue =
      'm5/postmortem_list_written_overdue.json';

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

  /// 🆕 v1.35(01 §44 · K298) — `J-3` 거부 접수증 2행(`JOURNAL_TARGET_UNKNOWN` · `JOURNAL_INPUT_INVALID` · 명령 2 · `receipts_5` 무변경).
  static const String m6JournalDraftReceiptsReject2 =
      'm6/journal_draft_receipts_reject_2.json';
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

  /// 🆕 v1.37(01 §46 · K323 · 미결 225) — `L-3` 현금 축: ① 현금 차이 1(`CANON_SELF_REPORT` · `CASH` · 관측) ② 차이 0 · 현금 미대조 문장
  /// (허용 오차 값 없음 · `SelfReportSession` 2행).
  static const String m6SelfReportCash2 = 'm6/self_report_cash_2.json';

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

  /// 🆕 v1.27(01 §36 · K191) — 엔진 등재형 5(`AlertCodes.safetyWarn` 4 · `derivedSync` 1) 각 1행(글자 = 엔진 `alert_text.dart` ·
  /// 등급 = 엔진 `kAlertLevels` · 등급 순).
  static const String m8AlertsEngineProposalsV127 =
      'm8/alerts_engine_proposals_v127.json';

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

  /// 🆕 v1.39(01 §48 · K345 · 13 R243 P3 ⓔ) — `D-01` postmortem 기한 배너(종류 OTHER · 조치 «postmortem 쓰기» → `m5Postmortem`) ·
  /// 기존 `other` 표본(조치 0) 무변경.
  static const String m8IncidentBannerPostmortemDue =
      'm8/incident_banner_postmortem_due.json';
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

  /// 🆕 v1.29(01 §39 · E11k-b) — `o_07` 상세 «연결됨 · 서버 시각 확인» 중간 상태(`IN_PROGRESS` · 검증 = `CONNECTION_TEST{target: SUPABASE}` ·
  /// 슬롯 `SECRET_SUPABASE_CONNECT` · 🔴 VERIFIED = 쓰기-읽기 왕복 뒤).
  static const String m8OnboardingStepDetailSupabase =
      'm8/onboarding_step_detail_supabase.json';

  /// 🆕 v1.31(01 §40 · E11k-d2) — `o_07` ③ 상세(② 통과 뒤 같은 단계 · `IN_PROGRESS` · 검증 = `SUPABASE_SIGN_IN{}` ·
  /// 슬롯 `SECRET_SUPABASE_LOGIN` · 🔴 VERIFIED = 쓰기-읽기 왕복 뒤).
  static const String m8OnboardingStepDetailSupabaseLogin =
      'm8/onboarding_step_detail_supabase_login.json';
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

  /// 🆕 v1.29(01 §39 · E11k-b) — `o_07` 연결 확인 결과 12행(접수 1 · 입력 문제 6 · 망 실패 5 · `ActionResult`).
  static const String m8OnboardingSupabaseConnectResults =
      'm8/onboarding_supabase_connect_results.json';

  /// 🆕 v1.31(01 §40 · E11k-d2) — `o_07` ③ 로그인 결과 9행(접수 1 · 인증 4 · 전송 4 · `ActionResult`).
  static const String m8OnboardingSupabaseSigninResults =
      'm8/onboarding_supabase_signin_results.json';
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

  // 🆕 v1.28(01 §37) — S04 첫 판 VM 2(파일 이름 바이트 차례 · all 도 같은 차례).
  /// 🆕 v1.28(K197 · K202) — `S04` 정본 P0S(카드 · 묶음 셋 · 바꾸는 길 · 엔진 시험 글자 그대로).
  static const String m9AllocationEditor = 'm9/allocation_editor.json';

  /// 🆕 v1.28(K202) — `S04` 같은 VM · 낡음(`as_of.stale_label` · 봉투 `as_of` 에는 없음).
  static const String m9AllocationEditorStale =
      'm9/allocation_editor_stale.json';

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

  /// 🆕 v1.28 K208(R196) — `S02` SIM · 실전 미등록 카드 = 봉인 표시 그대로 + 칸 + «검증 후 저장»(조회만) · ISA 통과 = 동작 0.
  static const String m9CredentialsSimUnregistered =
      'm9/credentials_sim_unregistered.json';

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

  // ── x1/ — 🆕 v1.33(01 §42 · K279 · E16j-b) X1 기기 이전 `X1PlanWizardVm` 6 · `X1RecoveryVm` 8 · 결과 1 · 폴더 신설(파일 이름 바이트 차례) ──
  /// 🆕 v1.33 — 옛 폰 단계 막힘(ORDERS_CLEARED · `OPEN_ORDERS_REMAIN` · 되돌리기 동작).
  static const String x1PlanWizardBlocked = 'x1/plan_wizard_blocked.json';

  /// 🆕 v1.33 — 옛 폰 시작 전(D-03 한 장 + `X1_PLAN_START{}` · 행 0).
  static const String x1PlanWizardD03 = 'x1/plan_wizard_d03.json';

  /// 🆕 v1.33 — 옛 폰 강등 뒤(DEMOTED 끝 · 되돌리기 0 · 경고 줄).
  static const String x1PlanWizardDemoted = 'x1/plan_wizard_demoted.json';

  /// 🆕 v1.33 — 옛 폰 모의 거부(`X1_LIVE_ONLY` · 동작 0).
  static const String x1PlanWizardLiveOnly = 'x1/plan_wizard_live_only.json';

  /// 🆕 v1.33 — 옛 폰 잠김(`locked_label` · 동작 0).
  static const String x1PlanWizardLocked = 'x1/plan_wizard_locked.json';

  /// 🆕 v1.33 — 옛 폰 티켓 발급 뒤(9단계 끝 · QR 카드).
  static const String x1PlanWizardTicket = 'x1/plan_wizard_ticket.json';

  /// 🆕 v1.33 — 새 폰 비상 펜싱 대기 · 재발급 6행.
  static const String x1RecoveryEmergencyFencing =
      'x1/recovery_emergency_fencing.json';

  /// 🆕 v1.33 — 새 폰 비상 시작 전(복구 코드 자리 + `X1_EMERGENCY_START{}`).
  static const String x1RecoveryEmergencyStart =
      'x1/recovery_emergency_start.json';

  /// 🆕 v1.33 — 새 폰 RECOVERY_FULL(`restart_link` → `onboardingRestart` · 동작 0).
  static const String x1RecoveryFull = 'x1/recovery_full.json';

  /// 🆕 v1.33 — 새 폰 공백 재구성 막힘(`GAP_OVERSOLD`).
  static const String x1RecoveryGapViolation = 'x1/recovery_gap_violation.json';

  /// 🆕 v1.33 — 새 폰 게이트 생체 대기(`X1_RECOVERY_STEP{BIOMETRIC_CONFIRMED}`).
  static const String x1RecoveryGateBiometric =
      'x1/recovery_gate_biometric.json';

  /// 🆕 v1.33 — 새 폰 게이트 관찰 n/m.
  static const String x1RecoveryGateObserving =
      'x1/recovery_gate_observing.json';

  /// 🆕 v1.33 — 새 폰 받기 시작 전(QR 스캔 자리).
  static const String x1RecoveryPlanScan = 'x1/recovery_plan_scan.json';

  /// 🆕 v1.33 — 새 폰 복원 거부(`RESTORE_ROLLBACK`).
  static const String x1RecoveryRestoreRejected =
      'x1/recovery_restore_rejected.json';

  /// 🆕 v1.33 — 결과 14행(`SafetyActionResult` · 동작 6 · 거부 사전 합집합).
  static const String x1X1ActionResults = 'x1/x1_action_results.json';

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

  // ── x5/ — 🆕 v1.32(01 §41 · K260 · E16j-a) X5 정정 마법사 `RepairWizardVm` 7 · 결과 1 · 폴더 신설(파일 이름 바이트 차례) ──
  /// 🆕 v1.32 — 결과 11행(`SafetyActionResult` · 동작 4 · 거부 사전 합집합).
  static const String x5RepairActionResults = 'x5/repair_action_results.json';

  /// 🆕 v1.32 — 경계 X1(원장 불신 · `x1GuideLink` · 동작 0).
  static const String x5RepairBoundaryX1 = 'x5/repair_boundary_x1.json';

  /// 🆕 v1.32 — diff 갈래 기본(FILL_LAG = 아무것도 안 하기 · 1단계 차례).
  static const String x5RepairDiffDefault = 'x5/repair_diff_default.json';

  /// 🆕 v1.32 — diff 갈래 실행 준비(5단계 통과 · 정정 폼).
  static const String x5RepairDiffReady = 'x5/repair_diff_ready.json';

  /// 🆕 v1.32 — diff 갈래 3단계(사전 저널 폼).
  static const String x5RepairDiffStage3 = 'x5/repair_diff_stage3.json';

  /// 🆕 v1.32 — 허브 빈(열린 대상 0 · `doneLabel`).
  static const String x5RepairHubEmpty = 'x5/repair_hub_empty.json';

  /// 🆕 v1.32 — 허브 대상 2(→ `x5RepairTarget` · diff · 무결성).
  static const String x5RepairHubTargets = 'x5/repair_hub_targets.json';

  /// 🆕 v1.35(01 §44 · K291) — 정정 원문 파싱 거부 결과 1행(`REPAIR_CORRECT` · `REPAIR_AMOUNT_INVALID`).
  static const String x5RepairInputResults = 'x5/repair_input_results.json';

  /// 🆕 v1.32 — 무결성 갈래 새 기준점 준비.
  static const String x5RepairIntegrityReady = 'x5/repair_integrity_ready.json';

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
    safetyStatesHolds,
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
    m5SelfAuditResolveOpen,
    m5SelfAuditResolveHeldBlocked,
    m5SelfAuditResolveClear,
    m5HeldReviewResults,
    m5PostmortemListEmpty,
    m5PostmortemListDue,
    m5PostmortemListWrittenOverdue,
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
    m6JournalDraftReceiptsReject2,
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
    m6SelfReportCash2,
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
    m8AlertsEngineProposalsV127,
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
    m8IncidentBannerPostmortemDue,
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
    m8OnboardingStepDetailSupabase,
    m8OnboardingStepDetailSupabaseLogin,
    m8OnboardingStepsAdvisory,
    m8OnboardingStepsAllVerifiedLocked,
    m8OnboardingStepsEmpty,
    m8OnboardingStepsFinishReady,
    m8OnboardingStepsFinishReadyWarn,
    m8OnboardingStepsFresh,
    m8OnboardingVerifyResults,
    m8OnboardingSupabaseConnectResults,
    m8OnboardingSupabaseSigninResults,
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
    m9AllocationEditor,
    m9AllocationEditorStale,
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
    m9CredentialsSimUnregistered,
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
    x1PlanWizardBlocked,
    x1PlanWizardD03,
    x1PlanWizardDemoted,
    x1PlanWizardLiveOnly,
    x1PlanWizardLocked,
    x1PlanWizardTicket,
    x1RecoveryEmergencyFencing,
    x1RecoveryEmergencyStart,
    x1RecoveryFull,
    x1RecoveryGapViolation,
    x1RecoveryGateBiometric,
    x1RecoveryGateObserving,
    x1RecoveryPlanScan,
    x1RecoveryRestoreRejected,
    x1X1ActionResults,
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
    x5RepairActionResults,
    x5RepairBoundaryX1,
    x5RepairDiffDefault,
    x5RepairDiffReady,
    x5RepairDiffStage3,
    x5RepairHubEmpty,
    x5RepairHubTargets,
    x5RepairInputResults,
    x5RepairIntegrityReady,
  ];
}
```

---

## `packages/domain_contracts/lib/src/labels/advice_codes.dart`

```dart
// 01 §3-8 X7 명령 거부 사유 18종(🆕 v1.12 +3) · §6-6 `advice_transition.cause_code` 9종
// · `decision_log.reason_code` 특수값 3종 · §3-7 슬리브 A 계절 진입 게이트 사유 3종
// · 🆕 v1.12(01 §21) 재제출 선택지 2종(`AdviceRetryCodes`) · 수량 채우기 필드 1종(`ManualFillPrefillFields`).
//
// 🔴 전부 «어떤 코드가 오는가»의 목록이다. 거부 사유의 문구는 `ActionResult.headline`·
//    `CommandReceipt.stateLabel` 에, 게이트 사유의 문구는 `ReasonChip.label` 에 실려 온다.
// 🔴 **거부는 초안을 지우지 않는다**(C17) — 어떤 거부 코드로 돌아와도 화면은 값을 채운 채
//    사유와 재제출 버튼을 보인다. 초안 삭제는 `CommandReceipt.state == executed` 수신 시에만.

/// X7 명령 거부 사유 코드 18종(01 §3-8 · 🆕 v1.12 +3 — `INPUT_INVALID`·`SELF_REPORT_OUTSIDE_SESSION`·
/// `DEFER_ALREADY_USED`).
///
/// 🔴 **폐기** — `LEDGER_INTEGRITY_BLOCKED`(B18). 무결성 차단 중에도 기록 명령은 거부하지 않고
///    `CommandState.heldForIntegrity` 로 **보관**한다. 이 상수를 되살리지 않는다.
abstract final class AdviceRejectCodes {
  /// 금지 조합(01 §10-2) 진입 시도. 🔴 조건부 칸 #12 는 `handover_session_id` 가 없으면 여기로.
  static const String modeCombinationDenied = 'MODE_COMBINATION_DENIED';

  /// `autoTrade` 에 수기 기록 명령이 도착.
  static const String operatingModeMismatch = 'OPERATING_MODE_MISMATCH';

  /// 🔴 `SKIPPED`·`REVOKED`·`SUPERSEDED` **3종에만** 적용한다 — `EXPIRED` 는 **제외**(A4).
  /// 만료 뒤 도착한 기록은 «지연 이행»이며 받는다.
  static const String adviceNotOpen = 'ADVICE_NOT_OPEN';

  /// 거래일자가 휴장일·미래일·모드 개시 이전. 🔴 판정은 거래소 캘린더를 아는 엔진만.
  static const String fillDateNotTradingDay = 'FILL_DATE_NOT_TRADING_DAY';

  /// 🔴 B4 — 기록의 `tradeDate` 가 [안내 발행 거래일, `validUntilDate`] 창 밖.
  static const String fillDateOutsideAdviceWindow =
      'FILL_DATE_OUTSIDE_ADVICE_WINDOW';

  /// 그날 그 종목의 [저가, 고가] 밖. 🔴 B5 — **완화는 사용자가 고르지 않는다**:
  /// 엔진이 「시간외·단주 신고로 재제출」 옵션을 실을지 판정해 담고 화면은 준 옵션만 그린다.
  static const String priceOutOfRange = 'PRICE_OUT_OF_RANGE';

  /// 슬리브 매핑 밖 종목. 🔴 «시스템 밖 자산 등록» 경로를 함께 제시한다.
  static const String symbolNotMapped = 'SYMBOL_NOT_MAPPED';

  /// 🔴 B11 — 유니버스 종목을 `external_holding` 으로 등록하려는 시도(«2배 노출» 방어).
  static const String symbolInUniverseCannotBeExternal =
      'SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL';

  /// 이미 상쇄·재기재된 행을 다시 정정.
  static const String amendTargetNotActive = 'AMEND_TARGET_NOT_ACTIVE';

  /// 🔴 A13 — `amend` 에 종목·방향 변경이 실림. 그 변경은 `void` + 새 `record` **2명령**이다.
  static const String amendSymbolOrSideChange = 'AMEND_SYMBOL_OR_SIDE_CHANGE';

  /// 🔴 B6 — 정정 체인 길이 상한(엔진 config · 권고 2회) 초과 → `L-3` 실사로 유도.
  static const String amendLimitExceeded = 'AMEND_LIMIT_EXCEEDED';

  /// 안내의 종목과 다른 체결이 그 `advice_id` 로 들어옴.
  static const String adviceFillSymbolMismatch = 'ADVICE_FILL_SYMBOL_MISMATCH';

  /// 🔴 예산 코드 2종(`intentionalPause`·`priceUnacceptable`)에만 — 나머지 사유는 1탭으로 끝난다.
  static const String skipNoteRequired = 'SKIP_NOTE_REQUIRED';

  /// 🔴 B19 — `amend`·`void`·`skip`·`selfReport`(원장 재해석 계열)에만 남는다.
  /// `recordManualFill`(사실 추가)은 거부가 아니라 `pendingLeaseConfirm` 강등 접수다.
  static const String leaseExpired = 'LEASE_EXPIRED';

  /// 🔴 A9 — 24h 내 유사 기록(같은 `advice_id`·거래일·수량·가격).
  /// 재제출은 `duplicateAck = true`.
  static const String duplicateSuspected = 'DUPLICATE_SUSPECTED';

  /// 🆕 v1.12(01 §21 · K4) — 원문 파싱·필수 칸·상한 실패(수량·가격·현금·사유·계좌 · 어느 칸인지는
  /// `CommandReceipt.stateLabel`). 🔴 `CommandApi` 구현이 **큐 적재 없이** 낸 로컬 거부다(그 id 도
  /// `watchCommand` 가 다시 낸다 — 구현 의무 ④ · K42).
  static const String inputInvalid = 'INPUT_INVALID';

  /// 🆕 v1.12(K9 · 01 §4-2 «세션 밖 제출 거부») — 열린 실사 세션이 없다(`SettingsActionId.selfReportSessionStart`
  /// 뒤가 아니다). 🔴 큐 적재 0(로컬 거부 · 구현 의무 ④).
  static const String selfReportOutsideSession = 'SELF_REPORT_OUTSIDE_SESSION';

  /// 🆕 v1.12(K14 ⓐ) — 「내일 다시」를 이미 쓴 안내(G-86 «안내 1건당 1회» · 두 기기·두 번 탭 경합).
  /// 🔴 `ADVICE_NOT_OPEN` 은 `EXPIRED` 를 제외하는 코드라 재사용하지 않는다.
  static const String deferAlreadyUsed = 'DEFER_ALREADY_USED';

  /// 전량 18종.
  static const Set<String> values = <String>{
    modeCombinationDenied,
    operatingModeMismatch,
    adviceNotOpen,
    fillDateNotTradingDay,
    fillDateOutsideAdviceWindow,
    priceOutOfRange,
    symbolNotMapped,
    symbolInUniverseCannotBeExternal,
    amendTargetNotActive,
    amendSymbolOrSideChange,
    amendLimitExceeded,
    adviceFillSymbolMismatch,
    skipNoteRequired,
    leaseExpired,
    duplicateSuspected,
    inputInvalid,
    selfReportOutsideSession,
    deferAlreadyUsed,
  };
}

/// 🆕 v1.12(01 §21 · K20) — 재제출 선택지 코드(`CommandReceipt.retryCode` · X7 기록 명령 전용).
///
/// 🔴 화면은 이 코드로 분기하지 않는다 — `CommandReceipt.retryLabel` 버튼을 누르면 그 `retryCode` 를 제출 DTO
///    `retryCodes` 에 **더할** 뿐이다(누적 · B5 → A9 연쇄 거부 뒤 셋째 제출은 둘 다 싣는다). 와이어
///    `ManualFillRecord.offHourTrade`·`duplicateAck` 로 옮기는 것은 `CommandApi` 구현이다.
abstract final class AdviceRetryCodes {
  /// B5 — `PRICE_OUT_OF_RANGE` 뒤 «시간외·단주 신고로 다시 제출»(엔진이 실을지 판정한다).
  static const String offHourTrade = 'OFF_HOUR_TRADE';

  /// A9 — `DUPLICATE_SUSPECTED` 뒤 «같은 체결이 아닙니다 — 다시 제출».
  static const String duplicateAck = 'DUPLICATE_ACK';

  /// 전량 2종.
  static const Set<String> values = <String>{offHourTrade, duplicateAck};
}

/// 🆕 v1.12(01 §21 · K19) — `ManualFillInput.prefilledFields` 의 값(A1 — `A-3` 의 「채우기」 버튼은 수량 1개뿐 ·
/// 가격·거래일 버튼 없음 · 02 §3-8).
abstract final class ManualFillPrefillFields {
  /// 「안내 수량 채우기」(`AdviceItem.prefillQuantityText` 를 입력칸에 넣었다).
  static const String quantity = 'quantity';

  /// 전량 1종.
  static const Set<String> values = <String>{quantity};
}

/// `advice_transition.cause_code` 9종(01 §6-6 CHECK).
abstract final class AdviceTransitionCauseCodes {
  /// 수기 체결 기록.
  static const String record = 'RECORD';

  /// 미이행 선언.
  static const String skip = 'SKIP';

  /// 유효기한 경과(엔진 스윕).
  static const String lapse = 'LAPSE';

  /// 새 안내가 자리를 대체.
  static const String supersede = 'SUPERSEDE';

  /// 회수(킬스위치·차단·억제).
  static const String revoke = 'REVOKE';

  /// 기록 정정.
  static const String amend = 'AMEND';

  /// 🔴 A4 — 만료 뒤 기록. **상태를 바꾸지 않고** `EXPIRED → EXPIRED` 1행으로 사실만 남긴다.
  static const String lateFill = 'LATE_FILL';

  /// 🔴 G-20 — 집행 주체 전환 커밋이 살아 있는 안내를 **회수**한 사실.
  /// 사람의 미이행이 아니므로 **예산 미차감·이행률 분모 제외**다.
  static const String handoverClose = 'HANDOVER_CLOSE';

  /// 🔴 G-86 — 만료 확인 카드를 하루 미룬 사실. 상태는 바꾸지 않고
  /// (`EXPIRED → EXPIRED`) **행의 존재 자체가 «이미 한 번 미뤘다»의 정본**이다.
  static const String deferConfirm = 'DEFER_CONFIRM';

  /// 전량 9종.
  static const Set<String> values = <String>{
    record,
    skip,
    lapse,
    supersede,
    revoke,
    amend,
    lateFill,
    handoverClose,
    deferConfirm,
  };
}

/// `decision_log.reason_code` 의 특수값 3종(인벤토리 §6-12) + 🆕 v1.10 ㊲ 원장 사건 5종 + 🆕 v1.11 실입금 등록 1종.
///
/// 🔴 `decision_log.kind='MANUAL'` 인 **세 갈래**(정정 · `external_holding` 등록 · 경로 b 귀속)는
///    재량 예산·이탈 집계의 **모집단이 아니다**(C7).
abstract final class DecisionReasonCodes {
  /// G-04 — 실전 개시 원장(`kind='MANUAL'` 1행 공유).
  static const String openingBalance = 'OPENING_BALANCE';

  /// N-2 — 모의 개시 원장.
  static const String simOpeningBalance = 'SIM_OPENING_BALANCE';

  /// G-20 — `advice.close_reason_code` 에 실리는 전환 커밋 회수 사유.
  static const String handoverClosed = 'HANDOVER_CLOSED';

  /// 🆕 v1.10 ㊲ — 인출(`decision_log.kind='WITHDRAWAL'`).
  static const String ledgerEventWithdrawal = 'LEDGER_EVENT_WITHDRAWAL';

  /// 🆕 v1.10 ㊲ — 분배금(`kind='MANUAL'` — 재량 예산·이탈 모집단 아님).
  static const String ledgerEventDistribution = 'LEDGER_EVENT_DISTRIBUTION';

  /// 🆕 v1.10 ㊲ — 원천징수(`kind='MANUAL'`).
  static const String ledgerEventTaxWithheld = 'LEDGER_EVENT_TAX_WITHHELD';

  /// 🆕 v1.10 ㊲ — 분할·병합(`kind='MANUAL'`).
  static const String ledgerEventCorporateAction =
      'LEDGER_EVENT_CORPORATE_ACTION';

  /// 🆕 v1.10 ㊲ — 원장 사건의 무효(상쇄만 · `kind='MANUAL'`).
  static const String ledgerEventVoid = 'LEDGER_EVENT_VOID';

  /// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D5) — 실입금 등록(`decision_log.kind='DEPOSIT'` · 계획 바인딩과 한 트랜잭션).
  /// 칩 코드 `DEPOSIT_ROUTING`(플래너 사전)과 다른 도메인이다 — 결정 사유는 이 사전만 쓴다.
  static const String depositRegistered = 'DEPOSIT_REGISTERED';

  /// 🆕 v1.19(01 §28 · K21 · 엔진 E15e2 #161 `kLivePromotionReasonCode`) — 첫 실전 주문 승격
  /// (`decision_log.kind='MANUAL'` · 전략 `P0S` · `OPENING_BALANCE`·`SIM_OPENING_BALANCE` 와 같은 축).
  static const String livePromotion = 'LIVE_EXECUTE_PROMOTION';

  /// 🆕 v1.22(01 §31 · K57 · core `mode/sim_to_auto_commit.dart:91 · 94`) — 위저드 5단계 모의 기록 보관
  /// (`decision_log` MANUAL · 모의 파일). 🔴 `LIVE_OPENING` 은 `strategy_state_log.reason` 이라 여기 없다 ·
  /// 실전 개시 결정 = [openingBalance].
  static const String simLedgerKeep = 'SIM_LEDGER_KEEP';

  /// 🆕 v1.22 — 위저드 5단계 모의 기록 지움.
  static const String simLedgerDiscard = 'SIM_LEDGER_DISCARD';

  /// 🆕 v1.37(01 §46 · K326 · 01 §8 미결 218 ⓖ · 13 §8 R244 넘김 (라)) — X1 계획 이전 `D-03` 오프라인 긴급정지 카드 확인
  /// (옛 폰 · 이전 시작 전 · `decision_log.kind='SAFETY'` · 결정 id = `migration_run.decision_id` 와 같은 값 · 전략 `P0S` ·
  /// 백업 체크섬 앞이라 새 폰으로 함께 넘어간다). 🔴 `decision_log.kind` 새 값 0(CHECK 9 그대로 · 스키마 0).
  static const String x1D03Confirmed = 'X1_D03_CONFIRMED';

  /// 🆕 v1.37(K326) — X1 비상 선언(새 폰 · `decision_log.kind='SAFETY'` · 결정 id = 회수 행 `decision_id`(`X1EMG-<명령 id>` ·
  /// R244 W6) · 복원 전엔 live 원장이 없으니 복원 뒤 그 원장에 같은 id 로 1행 — R244 W2 sim `command_inbox` 기록이 원천).
  static const String x1EmergencyDeclared = 'X1_EMERGENCY_DECLARED';

  /// 전량 14종(🆕 v1.22 +2 · 🆕 v1.37 +2).
  static const Set<String> values = <String>{
    openingBalance,
    simOpeningBalance,
    handoverClosed,
    ledgerEventWithdrawal,
    ledgerEventDistribution,
    ledgerEventTaxWithheld,
    ledgerEventCorporateAction,
    ledgerEventVoid,
    depositRegistered,
    livePromotion,
    simLedgerKeep,
    simLedgerDiscard,
    x1D03Confirmed,
    x1EmergencyDeclared,
  };
}

/// 슬리브 A 계절 진입 게이트 사유 코드 3종(01 §3-7).
///
/// 🔴 **상태 5값 ↔ 코드 3종의 비대칭을 화면이 분기로 메우지 않는다** —
///    `octPassed`→[entryOk] · `deferredToNov`·`deferredToDec`→[entryDefer] ·
///    `enteredInNov`·`forcedEntryDec`→[entryLate]. 화면은 상태값으로 색·배지만 고르고
///    문구는 전부 `ReasonChip.label` 을 쓴다.
/// 🔴 임계값·보류 상한(`seasonality.f1_entry_gate_score`·`f1_entry_defer_max`)을
///    **상수로 적지 않는다** — 값이 화면에 박히면 조문과 화면이 각자 정본이 된다.
/// 🔴 **보류에 안내를 만들지 않는다**(G-25) — 매달 오는 «안 함»의 통보는 경보 피로다.
abstract final class SeasonalEntryGateCodes {
  /// ⏸ 정상 통과. ⚠️ **엔진 코드명 M2-3 확정 대기**(M2-8 A-9) —
  /// 03_알고리즘에 통과 케이스용 이벤트 이름이 아직 없다.
  /// 🔴 등재 전에는 픽스처 봉투의 `ENTRY_GATE_OCT` 를 **고치지 않는다**
  ///    (정상 통과가 «보류·지연»으로 오표기되는 것을 막는다).
  static const String entryOk = 'F1_ENTRY_OK';

  /// 임계 미만(또는 결측 = fail-closed) → 이번 달 보류.
  static const String entryDefer = 'F1_ENTRY_DEFER';

  /// 보류 뒤 실제 진입(11월말 재판정 통과 / 12월말 강제).
  static const String entryLate = 'F1_ENTRY_LATE';

  /// 전량 3종.
  static const Set<String> values = <String>{entryOk, entryDefer, entryLate};

  /// ⏸ 코드명 확정 전까지 픽스처 봉투가 «통과»에 쓰는 값(01 §3-7 · §5 봉투 예시).
  ///
  /// 🔴 [entryOk] 로 갈아치우지 않는다 — M2-3 등재가 끝난 창에서만 옮긴다.
  static const String fixtureEntryGatePass = 'ENTRY_GATE_OCT';
}
```

---

## `packages/domain_contracts/lib/src/labels/alert_codes.dart`

```dart
// 알림 코드 39종(🆕 v1.39 킬스위치 확인 1 · 읽기 모델 push 2 — 01 §48 K344 · K348) — 04 §5-1b(X7 9 + 전환 2) · §5-1c(자동 매매 11 + 유지보수 2) · §5-1d(운영 1)(🆕 v1.17 `STALE_ORDERS_HELD` · 엔진 D11) ·
// 🆕 v1.18 안전 3(E13 · 04 §5-3 v2.40·v2.41 제안) · 재개 3(E14 · 04 §5-3 v2.42 제안) ·
// 🆕 v1.27 SAF 경고 4(E3d · 04 §1 Level 3 · §5-3 v2.46 제안) · 파생 동기 1(E16 · 04 §5-3 v2.45 제안 · 01 §36).
// 인벤토리 §6-9 의 분류를 그대로 쓴다.
//
// 🔴 **등급(P0/P1/P2)을 이 파일에 사전으로 만들지 않는다.** 등급의 런타임 정본은
//    `AlertItem.level` 하나이고(01 §2-10 · 결정 7c 표시 계층의 사적 재분류 금지),
//    최종 정본은 엔진 `06_시스템설계/04_안전장치.md` 의 notify 등급이다.
//    아래 각 코드의 주석에 적은 등급은 04 의 **잠정 카탈로그 기록**이며,
//    «앱 알림 코드 ↔ 엔진 등급 대조 1회»(06 §4 ③)를 통과하기 전에는 유효하지 않다.
// 🔴 **등재 전에는 화면이 `code` 로 아이콘·색도 고르지 않는다**(픽스처 고정) — 04 §5-1b·§5-1c 말미.
// 🔴 **알림을 만들지 않는 것** — 키 미등록 · `ADVICE_SELECTIVE_EXECUTION` ·
//    `SELF_AUDIT_PATTERN_UNVERIFIED`(전부 상태 표식·월간 리포트로만).

/// 알림 코드(04 §5-1b·§5-1c·§5-1d).
abstract final class AlertCodes {
  // ── X7 안내 9 (04 §5-1b) ──────────────────────────────────────────────────
  /// 잠정 P1 · 🔴 **배치당 1건**(항목별 발송 금지).
  static const String adviceIssued = 'ADVICE_ISSUED';

  /// 잠정 P0 · 🔴 **ack 승급 사다리 미적용** — 대신 T-90분 [adviceDueSoon] 이 한 번 더 온다.
  /// 🆕 v1.15 — 이 코드의 `AlertItem.ack` = 늘 null(C-49 ⑥).
  static const String adviceExitUrgent = 'ADVICE_EXIT_URGENT';

  /// 잠정 P1 · 유효기한 당일 장 마감 T-90분, 미기록 잔존. 1건으로 묶음.
  static const String adviceDueSoon = 'ADVICE_DUE_SOON';

  /// 잠정 P2 · 만료 스윕 직후. 일 1건 묶음.
  static const String adviceExpired = 'ADVICE_EXPIRED';

  /// 잠정 P0 · 🔴 **독립 `AlertItem`** 이며 킬스위치 알림과 **엔진 순서로 인접**해 온다
  /// (`groupKey` 필드 없음 · 🆕 v1.15 · 화면은 받은 차례 그대로)
  /// («동봉»은 세 번째 발송 형태라 만들지 않는다 · C13).
  static const String adviceRevoked = 'ADVICE_REVOKED';

  /// 잠정 P0 · 골든벡터 재검증 실패 등으로 안내가 눌렸을 때.
  static const String adviceSuppressed = 'ADVICE_SUPPRESSED';

  /// 잠정 P1 · 신뢰 등급 하향 시 **1회**.
  static const String ledgerTrustDowngrade = 'LEDGER_TRUST_DOWNGRADE';

  /// 잠정 P2 · 월 1회 원장 실사 요구. 🔴 같은 이름의 `flag_id` 와 **다른 축**이다.
  static const String selfAuditDue = 'SELF_AUDIT_DUE';

  /// 잠정 P1 · 가격 범위·거래일 검증 거부. 즉시.
  static const String manualFillRejected = 'MANUAL_FILL_REJECTED';

  // ── 전환 2 (04 §5-1b) ─────────────────────────────────────────────────────
  /// 잠정 P1 · 전환 냉각 24h 동안 **1일 1건**. 🔴 조르지 않는다(경보 피로 규칙).
  static const String handoverCoolingActive = 'HANDOVER_COOLING_ACTIVE';

  /// 잠정 P1 · 전환 커밋 성공 직후 **1회** — 띠·탭이 바뀐 이유를 말하는 유일한 자리.
  static const String handoverCommitted = 'HANDOVER_COMMITTED';

  // ── 자동 매매 11 (04 §5-1c) ───────────────────────────────────────────────
  /// 잠정 P1 · 주문 거부. 배치당 묶음.
  static const String orderRejected = 'ORDER_REJECTED';

  /// 잠정 P0 · 결과 불명(UNKNOWN) 잔존. 🔴 배치당 1건으로 묶음.
  static const String orderOutcomeUnknown = 'ORDER_OUTCOME_UNKNOWN';

  /// 잠정 P0 · 재대사 후에도 잔존하는 불일치. 🔴 재대사 전에는 발행하지 않는다.
  /// 🔴 같은 이름의 `flag_id` 와 **다른 축**이다.
  static const String reconMismatch = 'RECON_MISMATCH';

  /// 잠정 P2 · 월말 리밸런싱 D-7 예고. 🔴 회차당 1건.
  static const String rebalanceD7 = 'REBALANCE_D7';

  /// 잠정 P1 · 월말 리밸런싱 D-1 통보. advisory 에서는 [adviceIssued] 에 **묶여** 온다.
  /// 🔴 묶는 주체는 엔진이며 화면이 두 알림을 발견해 합치지 않는다.
  static const String rebalanceD1 = 'REBALANCE_D1';

  /// 잠정 P1 · 워치독 유예 초과. 체크당 1건.
  static const String watchdogLate = 'WATCHDOG_LATE';

  /// 잠정 P0 · 브로커 인증 실패(토큰·앱키).
  static const String brokerAuthFailed = 'BROKER_AUTH_FAILED';

  /// 잠정 P1 · 시세·데이터 소스 장애. 소스당 1건.
  static const String dataSourceDown = 'DATA_SOURCE_DOWN';

  /// 잠정 P1 · 백업 나이 26h 초과. 일 1건.
  static const String backupStale = 'BACKUP_STALE';

  /// 잠정 P2 · 월 납입 리마인더(`H-02` 행과 같은 트리거). 일일 다이제스트.
  static const String depositReminder = 'DEPOSIT_REMINDER';

  /// 🆕 v1.17(01 §26 · 엔진 D11 · 13 §8 R33 D11 · R38 Z8) — 잠정 P1 · **다음 날 가드 보류**: 그날 계좌 첫 주문 앞 체결조회에
  /// 지난 거래일 원주문 행이 보이거나(`STALE_ORDERS`) 그 조회가 실패해(`STALE_GUARD_UNAVAILABLE` · fail-closed) **그 계좌의
  /// 그날 배치를 보류**했다(이중 매수 방지 · 04_안전장치 §3-1 ③ 5). 🔴 계좌·날 1건 · 등급 정본 등재(§5-3 표) = 엔진 다음 SPEC 판.
  static const String staleOrdersHeld = 'STALE_ORDERS_HELD';

  // ── 유지보수 창 2 (04 §5-1c · S7 재추적 N-2) ────────────────────────────────
  /// 잠정 P1 · X1 유지보수 창이 T시간을 넘겨 열려 있음. 🔴 창 1개당 1건.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String maintenanceWindowOverdue = 'MAINTENANCE_WINDOW_OVERDUE';

  /// 잠정 P0 · 부팅 시 미종료 창을 감지해 `/resume` 을 시도했으나 실패. 부팅 1회당 1건.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String maintenanceResumeFailed = 'MAINTENANCE_RESUME_FAILED';

  // ── 운영 파라미터 1 (04 §5-1d) ─────────────────────────────────────────────
  /// 잠정 P2 · 월 납입 운영값 변경 명령이 집행된 직후.
  /// 🔴 변경 1건당 1건(멱등 키 = `operating_param_log.row_id`) · **일일 다이제스트에만** 실린다.
  /// 🔴 앱이 은행을 대신 바꾸지 않으므로 «지금 변경» 버튼·딥링크를 만들지 않는다.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String contributionChanged = 'CONTRIBUTION_CHANGED';

  // ── 🆕 v1.18 안전 3 (01 §27 · K-z · 엔진 E13d1·E13c1 상수 = 등재 · 등급 = 엔진 `kAlertLevels`) ──────────
  /// 잠정 P0 · 서킷브레이커 STOPPED 진입(신규 주문 전면 중단 · 보유 그대로 · postmortem 3일 · 엔진 `kBreakerStoppedAlertCode`).
  static const String breakerStopped = 'BREAKER_STOPPED';

  /// 잠정 P0 · 원장 자가 무결성 실패(지난 날 해시 불일치 → 전 신규 주문 차단 · 엔진 `kLedgerIntegrityAlertCode` · E13c1).
  static const String ledgerIntegrityBroken = 'LEDGER_INTEGRITY_BROKEN';

  /// 잠정 P1 · STOPPED 재개 자격 충족(v2.29 · 자동으로 풀리지 않는다 · 에피소드당 1회 · 엔진 `kStoppedReleaseEligibleAlertCode` ·
  /// 🔵 E11f1 `equity_snapshot` 보고 «재개 자격» 과 **같은 사건** — 한 코드).
  static const String stoppedReleaseEligible = 'STOPPED_RELEASE_ELIGIBLE';

  // ── 🆕 v1.18 재개 3 (01 §27 · K-z · 엔진 E14b `resume_alerts.dart` · 회차 끝 묶음 · 한국 날 ≤ 1) ──────────
  /// 잠정 P0 · 재개 뒤 매매 정지 유지(`RESUME_INCOMPLETE` 유지 · [resumeCompleted] 와 배타).
  static const String resumeTradingHalted = 'RESUME_TRADING_HALTED';

  /// 잠정 P1 · 재개 완료(해제 · 주문은 다음 `kr_order` 회차가 낸다).
  static const String resumeCompleted = 'RESUME_COMPLETED';

  /// 잠정 P2 · 되살릴 수 없는 기록 공백(복구 불가 갭이 있을 때 더한다).
  static const String resumeDataGap = 'RESUME_DATA_GAP';

  // ── 🆕 v1.27 SAF 경고 4 (01 §36 K189 · 04 §1 Level 3 · §5-3 v2.46 · 엔진 E3d `p0s_warn.dart` · 주문을 막지 않는다) ──────────
  /// 잠정 P1 · SAF-302 방어 자산(슬리브 C) 비중이 하한 밑 — 넘은 첫날 1건(엣지 · 머무는 동안 다시 내지 않는다 ·
  /// 엔진 `kDefensiveFloorAlertCode`).
  static const String defensiveFloorBreached = 'DEFENSIVE_FLOOR_BREACHED';

  /// 잠정 P1 · SAF-308 금 총비중이 감시선을 넘음 — 넘은 첫날 1건 · 강제 매도 0(엔진 `kGoldShareAlertCode`).
  static const String goldShareHigh = 'GOLD_SHARE_HIGH';

  /// 잠정 P1 · SAF-306 일반계좌 과세연도 금융소득 누계가 기준을 넘음 — 첫 초과 월 1건(월간 잡 · 엔진 `kFinancialIncomeAlertCode`).
  static const String financialIncomeCapExceeded =
      'FINANCIAL_INCOME_CAP_EXCEEDED';

  /// 잠정 P2 · SAF-307 부속 원화 유동성(원화 현금 + 파킹)이 하한 밑 — 넘은 첫날 1건(엔진 `kKrwLiquidityAlertCode`).
  /// 🔴 SAF-307 의 달러 노출 기준선 초과는 알림 코드가 없다 — 월간 리포트 `D2_ALLOCATION` 메모(01 §36 K192).
  static const String krwLiquidityLow = 'KRW_LIQUIDITY_LOW';

  // ── 🆕 v1.27 파생 동기 1 (01 §36 K188 · 04 §5-3 v2.45 · 엔진 E16 `derived_sync.dart` · E16i 의 알림 몫) ──────────
  /// 잠정 P0 · 사본(아카이브 등)이 원장과 갈라져 그 사본 쓰기를 멈춤 — 대상마다 1건(끈적) · 주문은 막지 않는다 ·
  /// 할 일 = X1 복원 또는 새 기준점(사람만 · 엔진 `kDerivedForkAlertCode`).
  static const String derivedFork = 'DERIVED_FORK';

  // ── 🆕 v1.39 킬스위치 확인 1 (01 §48 K348 · 13 §8 R261 H7 · 리뷰 3차 B-03 · 04 §5-3 등급 행 = 이 판 제안) ──────────
  /// 🔴 계약 먼저 등재 — 엔진 등급(`kAlertLevels`) · 글자(`kAlertTexts`) · 내는 자리 = 미결 243(그 전 = 알림 0).
  /// 잠정 P0 · 킬스위치 발동 뒤 기록 확인이 엔진이 본 미체결 수와 어긋남(core `KillChecklistVerdict` `KILL_ACK_MISMATCH` · `p0: true` —
  /// 조립이 이 코드로 P0 경보 1건 · 🔴 알림 코드 ≠ 확인 결과 코드(`KillSwitchResultCodes.ackMismatch` = 화면 결과 축) — 같은 사건 두 축).
  static const String killSwitchAckMismatch = 'KILL_SWITCH_ACK_MISMATCH';

  // ── 🆕 v1.39 읽기 모델 push 2 (01 §48 K344 · 13 §8 R263 C3 · C7 · 미결 230 ⓓ · 04 §5-3 등급 행 = 이 판 제안) ──────────
  /// 🔴 계약 먼저 등재 — 엔진 등급 · 글자 · 내는 자리(push 보고서 실패 목록 → 알림) = 미결 243(그 전 = 알림 0).
  /// 잠정 P1 · push 가 시크릿 꼴 글자를 찾아 그 표를 보내지 않았다(PUSH_FAILED · 시크릿 차단 — 뷰어 사본이 멈춘다 · 조치 = 원인 확인).
  /// 🔴 본문에 찾은 글자 · 값 0(표 이름 · 종류만).
  static const String readModelPushSecretBlocked =
      'READ_MODEL_PUSH_SECRET_BLOCKED';

  /// 잠정 P1 · 서버 표와 앱이 어긋나 push 가 거부됐다(PUSH_FAILED · `READ_MODEL_ROWS_INVALID` · `READ_MODEL_TABLE_UNKNOWN` · 응답 꼴 ·
  /// 행을 못 만듦 — 조치 = 앱 업데이트 · 부트스트랩 다시). 🔴 망 · 서버 · 로그인 · 리스(PUSH_LAG)는 알림 0(다음 깨우기에 다시 — 경보 피로).
  static const String readModelPushRejected = 'READ_MODEL_PUSH_REJECTED';

  /// X7 안내 9종.
  static const Set<String> x7Advice = <String>{
    adviceIssued,
    adviceExitUrgent,
    adviceDueSoon,
    adviceExpired,
    adviceRevoked,
    adviceSuppressed,
    ledgerTrustDowngrade,
    selfAuditDue,
    manualFillRejected,
  };

  /// 집행 주체 전환 2종.
  static const Set<String> handover = <String>{
    handoverCoolingActive,
    handoverCommitted,
  };

  /// 자동 매매 11종.
  static const Set<String> autoTrade = <String>{
    orderRejected,
    orderOutcomeUnknown,
    reconMismatch,
    rebalanceD7,
    rebalanceD1,
    watchdogLate,
    brokerAuthFailed,
    dataSourceDown,
    backupStale,
    depositReminder,
    staleOrdersHeld,
  };

  /// 유지보수 창 2종.
  static const Set<String> maintenance = <String>{
    maintenanceWindowOverdue,
    maintenanceResumeFailed,
  };

  /// 운영 파라미터 1종.
  static const Set<String> operatingParam = <String>{contributionChanged};

  /// 🆕 v1.18 안전 3종.
  static const Set<String> safety = <String>{
    breakerStopped,
    ledgerIntegrityBroken,
    stoppedReleaseEligible,
  };

  /// 🆕 v1.18 재개 3종.
  static const Set<String> resume = <String>{
    resumeTradingHalted,
    resumeCompleted,
    resumeDataGap,
  };

  /// 🆕 v1.27 SAF 경고 4종.
  static const Set<String> safetyWarn = <String>{
    defensiveFloorBreached,
    goldShareHigh,
    financialIncomeCapExceeded,
    krwLiquidityLow,
  };

  /// 🆕 v1.27 파생 동기 1종.
  static const Set<String> derivedSync = <String>{derivedFork};

  /// 🆕 v1.39 킬스위치 확인 1종.
  static const Set<String> killSwitch = <String>{killSwitchAckMismatch};

  /// 🆕 v1.39 읽기 모델 push 2종.
  static const Set<String> readModelPush = <String>{
    readModelPushSecretBlocked,
    readModelPushRejected,
  };

  /// 전량 39종(🆕 v1.39 +3).
  static const Set<String> values = <String>{
    ...x7Advice,
    ...handover,
    ...autoTrade,
    ...maintenance,
    ...operatingParam,
    ...safety,
    ...resume,
    ...safetyWarn,
    ...derivedSync,
    ...killSwitch,
    ...readModelPush,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/allocation_codes.dart`

```dart
// 🆕 계약 v1.28(01 §37 · K200) — M9 `S04` 읽기 행 코드. 엔진 `AllocationViewRowCodes`(core `ops/allocation_view.dart`) 글자 1:1 ·
// 🔴 타입 이름 ≠ 엔진(`ambiguous_import` 회피 K80). 🔴 화면 미참조(시험 · 열 대조 · Key = 순번) — 코드로 분기·색을 고르지 않는다.

/// S04 읽기 행 코드(도메인 `allocation_row` · 차례 = 엔진 묶음 차례).
abstract final class AllocationRowCodes {
  /// 슬리브 B 코어 밴드.
  static const String bandCoreB = 'BAND_CORE_B';

  /// 슬리브 C 안 리밸런싱 문턱.
  static const String bandSleeveC = 'BAND_SLEEVE_C';

  /// 새틀라이트 밴드(P0S = 해당 없음).
  static const String bandSatellite = 'BAND_SATELLITE';

  /// 낙폭 단계(서킷브레이커).
  static const String riskDrawdown = 'RISK_DRAWDOWN';

  /// 하루 손실 한도(SAF-403).
  static const String riskDailyLoss = 'RISK_DAILY_LOSS';

  /// 위험자산 비중 상한(SAF-301).
  static const String riskExposure = 'RISK_EXPOSURE';

  /// 방어 비중 하한(SAF-302 · 경고).
  static const String riskDefensiveFloor = 'RISK_DEFENSIVE_FLOOR';

  /// 주문 한도(SAF-401 · 402).
  static const String riskOrderCaps = 'RISK_ORDER_CAPS';

  /// 금 상한 — 슬리브 C 안 하드 캡.
  static const String goldSleeveCCap = 'GOLD_SLEEVE_C_CAP';

  /// 금 총비중 감시선(SAF-308 · 감시선 — 하드 캡 아님).
  static const String goldTotalMonitor = 'GOLD_TOTAL_MONITOR';

  /// 차례 = 엔진 묶음 차례(밴드 3 · 한도 5 · 금 2).
  static const List<String> ordered = <String>[
    bandCoreB,
    bandSleeveC,
    bandSatellite,
    riskDrawdown,
    riskDailyLoss,
    riskExposure,
    riskDefensiveFloor,
    riskOrderCaps,
    goldSleeveCCap,
    goldTotalMonitor,
  ];

  static const Set<String> values = <String>{
    bandCoreB,
    bandSleeveC,
    bandSatellite,
    riskDrawdown,
    riskDailyLoss,
    riskExposure,
    riskDefensiveFloor,
    riskOrderCaps,
    goldSleeveCCap,
    goldTotalMonitor,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/deviation_kind_codes.dart`

```dart
// 01 §2-2 — `DeviationBadge.kindCode` 13종(기존 4 + X7 9).
//
// 🔴 이 목록의 **정본은 이 파일**이다(인벤토리 §3-2 말미 조문). `DeviationBadge` 자체는
//    영역 B 의 `dto/journal.dart` 가 만들고, 여기는 그 `kindCode` 가 가질 수 있는 값의 집합이다.
// 🔴 「예산 차감」·「저널 필요」 여부는 주석으로만 적는다 — 판정은 엔진이고
//    화면은 `DeviationBadge.label` 을 그대로 그린다.

/// `DeviationBadge.kindCode` 값 13종(01 §2-2).
abstract final class DeviationKindCodes {
  // ── 기존 4 ────────────────────────────────────────────────────────────────
  /// 재량 행사(예산 차감).
  static const String discretion = 'DISCRETION';

  /// 수동 주문. 🔴 자동 모드의 규칙 이탈 — 저널 + SEV2 postmortem 이 함께 열린다.
  static const String manualOrder = 'MANUAL_ORDER';

  /// 대사 불일치 해제.
  static const String reconClear = 'RECON_CLEAR';

  /// 킬스위치 해제 후 재개.
  static const String killSwitchResume = 'KILL_SWITCH_RESUME';

  // ── X7 9 ─────────────────────────────────────────────────────────────────
  /// 안내 유효기한 경과(미이행). 🔴 **예산 미차감**.
  static const String adviceLapse = 'ADVICE_LAPSE';

  /// 사람이 미이행을 선언.
  static const String adviceSkip = 'ADVICE_SKIP';

  /// 만료 뒤 지연 이행. 🔴 **예산 미차감 · 정식 저널 불요**.
  static const String adviceLateFill = 'ADVICE_LATE_FILL';

  /// 안내와 무관한 수기 신규. 🔴 **예산 차감 · `M5-6`**.
  static const String manualEntry = 'MANUAL_ENTRY';

  /// 안내 가격대 밖 체결.
  static const String advicePriceDeviation = 'ADVICE_PRICE_DEVIATION';

  /// 안내 수량과 다른 체결.
  static const String adviceQtyDeviation = 'ADVICE_QTY_DEVIATION';

  /// 청산 안내를 피함.
  static const String adviceExitAvoided = 'ADVICE_EXIT_AVOIDED';

  /// 기록 정정(상쇄 + 재기재).
  static const String fillAmended = 'FILL_AMENDED';

  /// 소급 기재.
  static const String backdatedFill = 'BACKDATED_FILL';

  /// 기존 4종.
  static const Set<String> legacy = <String>{
    discretion,
    manualOrder,
    reconClear,
    killSwitchResume,
  };

  /// X7 9종.
  static const Set<String> x7 = <String>{
    adviceLapse,
    adviceSkip,
    adviceLateFill,
    manualEntry,
    advicePriceDeviation,
    adviceQtyDeviation,
    adviceExitAvoided,
    fillAmended,
    backdatedFill,
  };

  /// 전량 13종.
  static const Set<String> values = <String>{...legacy, ...x7};
}
```

---

## `packages/domain_contracts/lib/src/labels/disclosure_codes.dart`

```dart
// 🆕 계약 v1.3(2026-09-28 · R10 선행 M2 보강 · 01 §13-6) — 성과 열람 기록의 «어느 화면인가» 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    화면은 이 상수를 `DisclosureViewEvent.surfaceCode` 에 **그대로** 넘긴다 — 문자열을 짓지 않는다.
//    엔진(명령 수신)은 이 목록에 없는 값을 받지 않는다.

/// `DisclosureViewEvent.surfaceCode` 의 값(01 §2-6 · §13-6).
///
/// 🔴 목록은 M2 가 늘린다 — 열람 기록을 남기는 화면이 늘면 여기에 상수를 더한다.
abstract final class DisclosureSurfaceCodes {
  /// `S7-2` 수익률 탐색(게이트 `S7-2G` 의 「그래도 보기」).
  static const String performanceExplore = 'PERFORMANCE_EXPLORE';

  /// 전량 1종.
  static const Set<String> values = <String>{performanceExplore};
}
```

---

## `packages/domain_contracts/lib/src/labels/exit_kind.dart`

```dart
// 01 §3-1 — `exit_kind` 6종. `decision_log.exit_kind` CHECK 와 문자 그대로 일치한다.
//
// 🔴 이 파일은 «어떤 코드가 오는가»의 목록이다. 문구(«TIER 1B 절대손절 −7.0% 도달»)는
//    엔진이 만들어 DTO 의 label·reason 필드에 실어 준다 — 화면이 코드로 문구를 고르면 C-5 위반이다.
// 🔵 v2.31 P0S 에서는 대부분 비집행이지만 코드는 보존한다(01 §3-1 표제).
// 🆕 v1.8(01 §17) — 파일 끝 `StopTierCodes`(손절선 등급 · `byDomain 'stop_tier'`) — 배럴 import·export 무변경.

/// `exit_kind` — 청산 사유의 갈래(01 §3-1 · `decision_log.exit_kind` CHECK).
abstract final class ExitKindCodes {
  /// TIER 0 기업행위 청산 — 쿨다운 영구(재진입 불가).
  static const String corporate = 'CORPORATE';

  /// TIER 1A·1B 손절.
  static const String stop = 'STOP';

  /// TIER 1.5·2 추세 이탈.
  static const String trendBreak = 'TREND_BREAK';

  /// TIER 3 목표가 도달.
  static const String target = 'TARGET';

  /// 정기 교체.
  static const String rebalance = 'REBALANCE';

  /// 브레이커·한도·대사·킬스위치에 의한 시스템 게이트 청산.
  static const String risk = 'RISK';

  /// 전량 — 픽스처·C-15 대조용. 🔴 `decision_log.exit_kind` CHECK 와 같은 집합이어야 한다.
  static const Set<String> values = <String>{
    corporate,
    stop,
    trendBreak,
    target,
    rebalance,
    risk,
  };
}

/// 🆕 v1.8(01 §17) — `StopLineNormalized.tierCode` 의 값(m2-8 E-8 «코드 목록은 영역 E 의 사전»의 실물).
/// 🔴 키 전용 — 화면은 표시·분기하지 않는다(문구 = `tierLabel`).
abstract final class StopTierCodes {
  static const String tier1a = 'TIER_1A';
  static const String tier1b = 'TIER_1B';
  static const String tier2 = 'TIER_2';
  static const Set<String> values = <String>{tier1a, tier1b, tier2};
}
```

---

## `packages/domain_contracts/lib/src/labels/flag_ids.dart`

```dart
// 01 §3-5 — 차단 플래그 `flag_id` 12종 · §9-5 ③ `SafetyState` hold 사유 1종.
//
// 🔴 «차단 범위»와 «해제 경로»는 주석으로만 적는다 — 런타임 값은 `BlockFlag.clearRoute` 와
//    `BlockFlag.clearInstruction`(플래그마다 다른 문구)로 온다. 화면이 flag_id 로 문구·경로를
//    고르는 사전을 만들면 C-5 위반이다.
// 🔴 저장 위치는 `trading_block`(06 §2-6 02_데이터모델)이며 **그 표에는 `flag_id` CHECK 가 없다** —
//    열거는 이 목록과 그 표의 주석, 그리고 04 §3-1 2단계 판정 SQL 이 함께 갖는다(배치 E 참조).

/// 주문 차단·상태 표식 플래그(01 §3-5 · `trading_block.flag_id`).
abstract final class FlagIds {
  /// 대사 불일치 — **전 주문** 차단. 해제 = `causeCodeRequired`(원인 코드 + `decision_id`).
  /// 🔴 `/resume` 으로 풀리지 않는다.
  static const String reconMismatch = 'RECON_MISMATCH';

  /// 이탈 저널 미작성 — **신규 매수** 차단. 해제 = `automatic`.
  /// 🔴 수동 해제 버튼이 **존재하지 않는다**.
  static const String journalMissing = 'JOURNAL_MISSING';

  /// 계층 B 월간 미판정 — **신규 매수** 차단. 해제 = `automatic`.
  static const String tierBUnjudged = 'TIER_B_UNJUDGED';

  /// DST 전환 주간. ⚠️ **차단이 아니라 상태 표식**(램프 하향으로 통과). 해제 = `automatic`(주간 종료).
  static const String dstWeek = 'DST_WEEK';

  /// X2 재개 미완 — **전 주문** 차단. 해제 = `automatic`(재개 완료 시).
  static const String resumeIncomplete = 'RESUME_INCOMPLETE';

  /// X5 정정 트랜잭션 뮤텍스. 🔴 자동·사람 해제가 **둘 다 없다**(트랜잭션 종료 시 소멸).
  static const String ledgerFix = 'LEDGER_FIX';

  /// X5 원장 무결성 — **전 주문** 차단. 해제 = `wizardOnly`(원인 코드 + `decision_id` + 체인 재스탬프).
  static const String ledgerIntegrity = 'LEDGER_INTEGRITY';

  /// X7 원장 미검증 — **신규 진입 안내**만 중단(청산·방어 안내는 유지 · 비대칭 원칙).
  /// 해제 = `wizardOnly` → `M5-13`.
  static const String adviceLedgerUnverified = 'ADVICE_LEDGER_UNVERIFIED';

  /// X7 실사 기한 초과 — **신규 진입 안내** 중단. 해제 = `automatic`(실사 1회 통과).
  /// 🔴 차단은 **차이의 크기가 아니라 실사의 부재**에만 건다(A12).
  static const String selfAuditOverdue = 'SELF_AUDIT_OVERDUE';

  /// X7 실사 예정. ⚠️ **차단 아님** — 상태 표식(D-15 재고지 → D-0 `SELF_AUDIT_OVERDUE`).
  static const String selfAuditDue = 'SELF_AUDIT_DUE';

  /// X7 실사 패턴 미검증. ⚠️ **차단 아님** — 상태 표식.
  static const String selfAuditPatternUnverified =
      'SELF_AUDIT_PATTERN_UNVERIFIED';

  /// X7 선택적 이행(진입/청산 이행률 비대칭). ⚠️ **차단 아님** — 상태 표식.
  /// 🔴 **알림을 만들지 않는다** — 월간 리포트에만 실린다.
  static const String adviceSelectiveExecution = 'ADVICE_SELECTIVE_EXECUTION';

  /// 전량 12종.
  static const Set<String> values = <String>{
    reconMismatch,
    journalMissing,
    tierBUnjudged,
    dstWeek,
    resumeIncomplete,
    ledgerFix,
    ledgerIntegrity,
    adviceLedgerUnverified,
    selfAuditOverdue,
    selfAuditDue,
    selfAuditPatternUnverified,
    adviceSelectiveExecution,
  };

  /// 주문을 실제로 막는 것 — 04 §3-1 2단계 판정 SQL 이 읽어야 하는 집합.
  ///
  /// 🔴 배치 E 는 이 넷을 판정 SQL 에 **실제로 추가**할 것을 요구한다(01 §6-5) —
  ///    플래그만 읽고 SQL 을 안 고친 구현은 실격이다.
  static const Set<String> blocking = <String>{
    reconMismatch,
    journalMissing,
    tierBUnjudged,
    resumeIncomplete,
    ledgerIntegrity,
    adviceLedgerUnverified,
    selfAuditOverdue,
  };

  /// 차단하지 않는 상태 표식 4종.
  static const Set<String> markerOnly = <String>{
    dstWeek,
    selfAuditDue,
    selfAuditPatternUnverified,
    adviceSelectiveExecution,
  };
}

/// `SafetyState` 의 배치 보류 사유 코드(01 §9-5 ③ · M2-8 A-17).
///
/// 🔴 `trading_block.flag_id` 가 **아니다** — 안전 상태의 hold 사유다.
/// 🆕 v1.35(01 §44 · K295 · 미결 219 닫음) — 짝 문장 = `SafetyState.holdLabels`(같은 차례 · 같은 길이) · 화면은 이 코드를 보지 않는다.
///    엔진 생산: `MIGRATION_IN_PROGRESS` = ds 안전 읽기 모델(미결 212 ② ✅) · `LIVE_AWAITING_KEYS` = 기동 게이트 → `SafetyState` 싣기 +
///    짝 문장 = 미결 220 ⓓ.
abstract final class SafetyHoldCodes {
  /// 실키 검증 전 보류.
  ///
  /// 🔴 **`operatingMode == autoTrade` 에서만 배치를 중단한다**(C9). `live × advisory` 에서는
  ///    키가 없는 것이 **정상 상태**이므로 hold 를 걸지 않는다 —
  ///    걸면 배치가 무기한 중단되고 안내가 영영 나오지 않는다(«침묵이 안전으로 위장되는» 상태).
  static const String liveAwaitingKeys = 'LIVE_AWAITING_KEYS';

  /// 🆕 v1.30(01 §38 · SPEC v2.45 04 §3-1 ① · E16i) — 기기 이전 진행 중(**표시** hold).
  ///
  /// 🔴 막는 정본은 이 글자가 아니라 엔진 리스 판정이다 — 이전 세션이 «신규 주문 동결»에 들어서면 NR-1 0단계 리스 = 무효
  ///    (`LEASE_INVALID` · 막는 것은 주문뿐 · 백업 커밋 · 아카이브는 원래 리스 판정 그대로). 이 hold 는 그 상태를 보여 줄 뿐이다.
  ///    엔진 생산(`SafetyState.holds` 에 싣기) = 엔진 숙제(01 §8 미결 212 ② — ✅ R225 #312).
  static const String migrationInProgress = 'MIGRATION_IN_PROGRESS';

  /// 전량 2종.
  static const Set<String> values = <String>{
    liveAwaitingKeys,
    migrationInProgress,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/journal_codes.dart`

```dart
// 🆕 계약 v1.1(2026-09-17) — 매매일지 상세(J-2)·UNKNOWN 보드(J-5)·타임라인 배지(J-1)의 코드 상수.
// 🆕 계약 v1.1 R2 준비(2026-09-23) — 사전 저널(J-3) 제출의 거부 사유 코드.
// 🆕 계약 v1.7(01 §16 · §8 미결 46) — 사후 blind 리뷰(J-4) 점수 제출의 거부 사유 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    문구는 짝이 되는 `*Label` 필드가 준다 — 화면이 이 상수로 문구·아이콘·색을 고르지 않는다.
//    쓰는 곳은 테스트(«6단계가 이 순서로 왔는가»)와 엔진 구현이다.

/// `J-2` 체인 타임라인의 단계(02 §3-2) — 자동 매매 6단계 + advisory 치환 2단계.
///
/// 🔴 한 체인은 **언제나 6칸**이다: `SIGNAL → INTENT → (BROKER_ORDER | ADVICE) →
///    (EXECUTION | MANUAL_RECORD) → TRADE → JOURNAL`. 어느 갈래인지는 엔진이 정한다.
abstract final class DecisionChainStageCodes {
  static const String signal = 'SIGNAL';
  static const String intent = 'INTENT';
  static const String brokerOrder = 'BROKER_ORDER';
  static const String execution = 'EXECUTION';
  static const String trade = 'TRADE';
  static const String journal = 'JOURNAL';

  /// X7 advisory — `BROKER_ORDER` 자리의 치환.
  static const String advice = 'ADVICE';

  /// X7 advisory — `EXECUTION` 자리의 치환.
  static const String manualRecord = 'MANUAL_RECORD';

  static const Set<String> values = <String>{
    signal,
    intent,
    brokerOrder,
    execution,
    trade,
    journal,
    advice,
    manualRecord,
  };
}

/// 주문 전 전수 검사의 층(04_안전장치 P2 — 검사 순서 Level 4 → 3 → 2 → 1).
/// `RejectTrace.stageCode` 의 값이다.
abstract final class SafetyCheckLevelCodes {
  /// Level 4 — 시스템.
  static const String level4System = 'LEVEL_4_SYSTEM';

  /// Level 3 — 포트폴리오.
  static const String level3Portfolio = 'LEVEL_3_PORTFOLIO';

  /// Level 2 — 슬리브.
  static const String level2Sleeve = 'LEVEL_2_SLEEVE';

  /// Level 1 — 종목.
  static const String level1Position = 'LEVEL_1_POSITION';

  static const Set<String> values = <String>{
    level4System,
    level3Portfolio,
    level2Sleeve,
    level1Position,
  };
}

/// `J-5` UNKNOWN 해소 단계 4칸(02 §3-5) — `UnknownResolutionStep.stepId` 의 값이다.
abstract final class UnknownResolutionStageCodes {
  static const String recorded = 'RECORDED';
  static const String queryPending = 'QUERY_PENDING';
  static const String brokerConfirmed = 'BROKER_CONFIRMED';
  static const String resolved = 'RESOLVED';

  static const Set<String> values = <String>{
    recorded,
    queryPending,
    brokerConfirmed,
    resolved,
  };
}

/// `J-1` 상단 배지의 종류 — `JournalTimelineBadge.badgeCode` 의 값이다.
abstract final class JournalBadgeCodes {
  /// 「확인 중 N건」 → `J-5`.
  static const String unknownOpen = 'UNKNOWN_OPEN';

  /// 「리뷰 대기 N건」 → `J-4`.
  static const String blindReviewPending = 'BLIND_REVIEW_PENDING';

  static const Set<String> values = <String>{unknownOpen, blindReviewPending};
}

/// 🆕 계약 v1.1 R2 준비(2026-09-23) — `J-3` 사전 저널 제출(`CommandKind.journalDraft`)의
/// 거부 사유. `CommandReceipt.rejectReasonCode` 의 값이다(`state == rejected` 일 때).
///
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다(advice_codes.dart 머리와 같은
///    규칙) — 화면은 이 코드로 문구를 고르지 않고, 코드를 표시하지도 않는다.
/// 🔴 거부는 초안을 지우지 않는다(C17) — 화면은 값을 채운 채 `stateLabel` 과 재제출 버튼을 보인다.
/// 🔴 X7 명령의 거부 사유(`AdviceRejectCodes`)와 **다른 도메인**이다 — 섞어 조회하지 않는다
///    (`ContractCodes.byDomain` 키 `journal_draft_reject`).
/// ⏸ 픽스처가 쓰는 1종에서 시작한다. 엔진(M1)이 새 사유를 내면 **여기와 픽스처를 함께** 넓힌다.
/// 🆕 v1.35(01 §44 · K296 ~ K298) — J-3 키 = **저널 id**(`decision_journal.journal_id` · 안전 동작의 `decision_id` 와 한 벌) ·
///    제출 갈래 = 엔진이 키로 가른다(ⓐ 채우기 = 사전 3칸이 빈 있는 행 · ⓑ 새 행 = 엔진이 J-3 링크에 실어 발급한 새 저널 id) ·
///    1종 → 3종(키 · 입력 거부). 🔴 화면은 이 코드로 분기 · 문구 · 표시를 하지 않는다(위 머리 그대로 — 문구 = `stateLabel`).
abstract final class JournalDraftRejectCodes {
  /// 이 키의 사전 저널이 이미 접수돼 있다 — 채우기 갈래의 행이 이미 세 칸 다 찼거나 새 행 갈래의 키로 이미 썼다.
  static const String journalAlreadyExists = 'JOURNAL_ALREADY_EXISTS';

  /// 🆕 v1.35(K298) — 키가 저널 대상이 아니다(모르는 id · 결정 id 를 넣었다 · 엔진이 발급하지 않은 새 키).
  static const String journalTargetUnknown = 'JOURNAL_TARGET_UNKNOWN';

  /// 🆕 v1.35(K298) — 입력이 폼 조건을 못 채운다(근거 앞뒤 공백 뺀 글자 < `rationaleMinChars` · 기대 결과 빈칸 ·
  /// 인용 규칙 ∉ 그 폼 `ruleCitedOptions` · `requiresNote` 인데 메모 빈칸) — 화면 «제출 가능 조건»과 같은 판정을 엔진이 다시 한다.
  static const String journalInputInvalid = 'JOURNAL_INPUT_INVALID';

  /// 전량(🆕 v1.35 3종).
  static const Set<String> values = <String>{
    journalAlreadyExists,
    journalTargetUnknown,
    journalInputInvalid,
  };
}

/// 🆕 v1.35(01 §44 · K300) — `J-3` 인용 규칙 선택지 코드(`JournalDraftFormSpec.ruleCitedOptions[].code` · `JournalDraft.ruleCited` ·
/// J-3 가 쓴 `decision_journal.rule_cited`) — 도메인 `journal_rule_cited` · 표본 3 = 엔진 첫 목록.
/// 🔴 다른 안전 동작의 `ruleCited`(재개 7번 · 개입 3단계 · RECON 해제 · 규칙 변경 요청)는 **원문**이다 — 이 사전과 축이 다르다(01 §8 미결 184 ③).
/// 🔴 선택지 글자(`label`) · 메모 필수(`requiresNote`) = 엔진 VM 칸 · 화면은 이 코드로 분기 · 문구를 고르지 않는다.
/// 엔진이 새 규칙을 내면 **여기와 픽스처를 함께** 넓힌다.
abstract final class JournalRuleCitedCodes {
  /// 재량 예산(롤링 12개월) 안에서 조정.
  static const String discretionBudget = 'RULE_DISCRETION_BUDGET';

  /// 대사 불일치 — 원인 코드 확인 뒤 해소.
  static const String reconCause = 'RULE_RECON_CAUSE';

  /// 그 밖의 규칙(메모 필수).
  static const String other = 'RULE_OTHER';

  static const Set<String> values = <String>{
    discretionBudget,
    reconCause,
    other,
  };
}

/// 🆕 v1.35(01 §44 · K294 · 미결 206 꼬리 · 217 ④) — 로컬 원장 `decision_journal.kind` 열의 값(도메인 `decision_journal_kind` ·
/// SPEC 02D `decision_journal` 주석과 한 벌). 🔴 표시 칸이 아니다 — 화면은 이 글자를 받지도 그리지도 않는다(배지 = `DeviationBadge.kindCode`).
/// 규칙: 글자 = 그 저널을 쓰는 안전 동작의 id 와이어(`SafetyActionId`) — 예외 둘([killSwitchChecklist] · [discretion] = 기존 엔진 · SPEC 글자).
/// 🔴 같은 글자 다른 축 셋 — [discretion] · [reconClear] · [killSwitchResume] = `DeviationKindCodes`(배지 종류 · C-5 문서 쌍).
/// 🔴 NULL = 옛 행(읽기 호환 · SAF-408 판정은 kind 를 보지 않는다) — 새로 쓰는 행은 이 사전 값만(엔진 숙제 = 01 §8 미결 220 ⓒ).
/// X1 D-03 · 비상 선언 결정(01 §8 미결 218 ⓖ) = 이전 저널 표 칸이라 이 사전 밖이다.
abstract final class DecisionJournalKinds {
  /// 킬스위치 발동 뒤 기록(M5-1 · `confirmKillChecklist` · ds `kill_switch_store` — 🔵 예외: 명령 와이어 `KILL_CHECKLIST_CONFIRM` 와 다르다).
  static const String killSwitchChecklist = 'KILL_SWITCH_CHECKLIST';

  /// 킬스위치 재개 7번(M5-2 · `SafetyActionId.killSwitchResume`).
  static const String killSwitchResume = 'KILL_SWITCH_RESUME';

  /// STOPPED 결정 A · B · C(M5-3 · `SafetyActionId.stoppedDecision`).
  static const String stoppedDecision = 'STOPPED_DECISION';

  /// 대사 불일치 해제(M5-5 · `SafetyActionId.reconClear`).
  static const String reconClear = 'RECON_CLEAR';

  /// 규칙 변경 요청(M5-9 · `SafetyActionId.ruleChangeRequest`).
  static const String ruleChangeRequest = 'RULE_CHANGE_REQUEST';

  /// 수동 개입 3단계 사전 저널(M5-6 · X5 마찰 · `SafetyActionId.interventionJournal` · 🔵 지금 엔진 = NULL → 미결 220 ⓒ).
  static const String interventionJournal = 'INTERVENTION_JOURNAL';

  /// 재량 조정의 사전 저널(M5-7 · J-3 새 행 갈래 · `DiscretionAdjustSubmission.decisionId` 가 가리킨다 · 🔵 예외: SPEC v2.15 ·
  /// 엔진 `kDiscretionJournalKind` 글자 — 동작 와이어 `DISCRETION_ADJUST` 와 다르다).
  static const String discretion = 'DISCRETION';

  /// 서약 편집의 사전 저널(M5-8 · J-3 새 행 갈래 · `SafetyActionId.pledgeEdit` · `PledgeSubmission.decisionId` 가 가리킨다).
  static const String pledgeEdit = 'PLEDGE_EDIT';

  /// 전량 8종.
  static const Set<String> values = <String>{
    killSwitchChecklist,
    killSwitchResume,
    stoppedDecision,
    reconClear,
    ruleChangeRequest,
    interventionJournal,
    discretion,
    pledgeEdit,
  };

  /// J-3 새 행 갈래의 목적(K297 ⓑ) — 저널을 먼저 쓰고 동작이 그 id 를 받는 둘.
  static const Set<String> draftPurposes = <String>{discretion, pledgeEdit};
}

/// 🆕 v1.7(01 §16) — `J-4` blind 리뷰 점수 제출(`CommandKind.blindReviewScore`)의 거부 사유.
/// `CommandReceipt.rejectReasonCode` 의 값(`state == rejected` 일 때) · `ContractCodes.byDomain` 키 `blind_review_reject`.
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다 — 화면은 이 코드를 표시·분기하지 않는다.
/// ⏸ 픽스처(`m6/blind_review_receipts_6`)가 두 사유를 다 싣는다. 엔진(M1)이 새 사유를 내면 **여기와 픽스처를 함께** 넓힌다.
abstract final class BlindReviewRejectCodes {
  /// 이 결정은 이미 채점됐다(먼저 집행된 채점이 이긴다 — K12).
  static const String alreadyScored = 'BLIND_REVIEW_ALREADY_SCORED';

  /// 답이 카드와 맞지 않는다(빠진 문항 · 모르는 문항 · 선택지에 없는 점수).
  static const String answersInvalid = 'BLIND_REVIEW_ANSWERS_INVALID';

  static const Set<String> values = <String>{alreadyScored, answersInvalid};
}

/// 🆕 계약 v1.17(01 §26 · 엔진 D11 · 13 §8 R33 D11·D24) — `TradeJournalEntry.reasons[].code` 중 **엔진이 정한 3종**
/// (D11 2 · 🆕 v1.18 E14a 1 — 01 §27 · K-n ⓕ).
///
/// 🔴 **전수 목록이 아니다** — 일지 사유 칩 코드 전수 등재 = 01 §8 미결 166. 화면은 이 코드로 분기·문구·아이콘을 고르지 않는다
///    (칩 `label`·`tone` 이 준다). 쓰는 곳 = 계약 테스트(C-51 ⑩⑪)와 엔진 구현.
abstract final class JournalReasonCodes {
  /// `status == prevented` 행의 근거 — 같은 멱등키의 의도가 이미 있어 새 의도 행을 만들지 않았다(NR-1 6.5 · R33 D24).
  /// 🔴 그 행의 `decision.intentId` = **이미 그 키를 가진 원 의도**.
  static const String duplicateOrderPrevented = 'DUPLICATE_ORDER_PREVENTED';

  /// `status == expired` 행의 근거 — 장 마감까지 체결되지 않은 잔량을 실효로 기록했다(취소 아님 · 04_안전장치 §3-1 ③ · R33 D5).
  static const String dayEndExpired = 'DAY_END_EXPIRED';

  /// 🆕 v1.18(01 §27 · K-n ⓕ · 엔진 E14a `kLeaseInvalidCode`) — `status == rejected`(NR-1 0단계) · `skipped`(6.9 직전 재확인) 행의 근거 —
  /// 이 기기에 발주권(리스)이 없거나 모른다(fail-closed · 그 키를 먹는다 = 그날 보류). 🔴 `AdviceRejectCodes.leaseExpired`
  /// (명령 접수 축 · 발행 epoch)와 **다른 축**이다.
  static const String leaseInvalid = 'LEASE_INVALID';

  static const Set<String> values = <String>{
    duplicateOrderPrevented,
    dayEndExpired,
    leaseInvalid,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/labels.dart`

```dart
// 01 §1-5 조문 + §3 코드 사전의 **단일 소스**.
//
// ════════════════════════════════════════════════════════════════════════════
// §1-5 화면 문자열 규약 — «사유 문구»와 «정적 라벨»의 경계 (조문)
// ════════════════════════════════════════════════════════════════════════════
// 금지 2항은 «한국어를 한 글자도 쓰지 말라»가 아니라
// **«상태를 설명하는 문장을 화면이 만들지 말라»** 이다.
//
//   | 갈래                | 누가 만드나                | 어디에 두나                          |
//   |---------------------|---------------------------|--------------------------------------|
//   | 사유·상태·판정 문구 | 🔴 엔진(M2)               | DTO 의 label·actionLine·             |
//   |                     |                           | clearInstruction·headline·           |
//   |                     |                           | stateLabel·statusLabel·emptyLabel·   |
//   |                     |                           | disclosureNote — 화면 코드에         |
//   |                     |                           | 리터럴로 존재하지 않는다             |
//   | 정적 UI 라벨        | 화면 담당                 | `<패키지>/lib/l10n/labels.dart`       |
//   |                     |                           | **한 파일에만** 상수로               |
//
// - **판단 기준**: 데이터가 바뀌어도 글자가 그대로면 정적 라벨,
//   데이터·상태에 따라 달라지면 사유 문구다.
//   `if 상태 then A else B` 처럼 **분기로 고르는 것은 정적 라벨이 아니라 생성**이다.
// - 그래서 열거값에는 짝이 되는 `*Label` 문자열 필드가 반드시 붙는다
//   (`status`↔`statusLabel` · `visibility`↔`visibilityLabel` · `state`↔`stateLabel`).
//   짝이 없는 열거값을 발견하면 화면이 문구를 지어내지 말고 **계약 결함으로 보고**한다.
// - C-5 는 `lib/l10n/labels.dart` 를 제외한 `ui_*` 전 파일에서 한글 리터럴 0건을 요구한다.
//   `labels.dart` 안에서도 §3 의 사유 문구를 베껴 적으면 위반이다.
//   (보조 스캐너 = `tool/check_labels.sh`)
//
// 🔴 **이 폴더의 성격** — 여기 두는 것은 «어떤 **코드**가 오는가»의 상수 목록이지
//    화면이 코드를 보고 문자열을 고르라는 사전이 **아니다**. 화면이 매핑을 만들면 C-5 가
//    빌드를 실패시킨다. 이 목록의 쓰임은 ① 픽스처·DDL 대조(C-15) ② 미등록 코드 조기 실패다.
// 🔴 C-32 — 이 파일도 예외가 아니다. 월 납입 금액으로 읽힐 숫자·문자열을 적지 않는다.

import 'advice_codes.dart';
import 'alert_codes.dart';
import 'allocation_codes.dart'; // 🆕 v1.28
import 'deviation_kind_codes.dart';
import 'disclosure_codes.dart';
import 'exit_kind.dart';
import 'flag_ids.dart';
import 'journal_codes.dart';
import 'ledger_event_codes.dart';
import 'migration_codes.dart'; // 🆕 v1.30
import 'onboarding_codes.dart';
import 'ops_codes.dart';
import 'origin_codes.dart';
import 'plan_codes.dart';
import 'repair_codes.dart'; // 🆕 v1.30
import 'saf_codes.dart';
import 'safety_codes.dart';
import 'settings_codes.dart';
import 'sim_codes.dart';
import 'supabase_codes.dart'; // 🆕 v1.29
import 'verdict_codes.dart';

export 'advice_codes.dart';
export 'alert_codes.dart';
export 'allocation_codes.dart'; // 🆕 v1.28
export 'deviation_kind_codes.dart';
export 'disclosure_codes.dart';
export 'exit_kind.dart';
export 'flag_ids.dart';
export 'journal_codes.dart';
export 'ledger_event_codes.dart';
export 'migration_codes.dart'; // 🆕 v1.30
export 'onboarding_codes.dart';
export 'ops_codes.dart';
export 'origin_codes.dart';
export 'plan_codes.dart';
export 'repair_codes.dart'; // 🆕 v1.30
export 'saf_codes.dart';
export 'safety_codes.dart';
export 'settings_codes.dart';
export 'sim_codes.dart';
export 'supabase_codes.dart'; // 🆕 v1.29
export 'verdict_codes.dart';

/// 세후 사다리 층 코드 6종(01 §2-4 `AfterTaxStep.stepCode` · M2-8 A-7).
///
/// 🔴 **층을 합치거나 건너뛰지 않는다** — `AfterTaxLadder.steps` 의 순서 그대로 그린다.
/// 🔴 «정직 기대»·사다리 4자리 수치를 **코드·라벨·주석에 옮기지 않는다**(C-30).
///    인용처는 픽스처 `aftertax_ladder_1.json` 과 골든 `aftertax_full_S7` 뿐이다.
/// 🔴 표시의 정본은 `AfterTaxStep.valueText` 이고 `cagrPct`·`endMult` 는 골든 대조 전용이다.
abstract final class AfterTaxStepCodes {
  /// 세전.
  static const String pretax = 'PRETAX';

  /// POT 반영 후.
  static const String afterPot = 'AFTER_POT';

  /// POT + C 반영 후.
  static const String afterPotC = 'AFTER_POT_C';

  /// 인출세 5.5% 적용.
  static const String wd5p5 = 'WD_5P5';

  /// 인출세 16.5% 적용.
  static const String wd16p5 = 'WD_16P5';

  /// 정직 기대.
  static const String honest = 'HONEST';

  /// 전량 6종(순서 = 사다리 층 순서).
  static const Set<String> values = <String>{
    pretax,
    afterPot,
    afterPotC,
    wd5p5,
    wd16p5,
    honest,
  };
}

/// ⏸ `AsOf.staleReasonCode` 최소 카탈로그 4값(M2-8 A-2 · 01 §8-8).
///
/// ⏸ **엔진(M1) 확정 대기.** 문서 전체를 통틀어 이 필드의 값이 한 번도 열거되지 않았고,
/// 아래 4값은 §1-3·§2-11 `staleLabel` 용례에서 **역산**한 것이다.
/// 🔴 그래도 상수로 둔다 — 자유 문자열로 두면 화면이 코드→문구 매핑을 만들고
///    그것이 C-5 위반의 입구다. 🔴 값이 확정되면 **이 목록을 고치고 픽스처를 함께 고친다**.
abstract final class StaleReasonCodes {
  /// 엔진 정지.
  static const String engineDown = 'ENGINE_DOWN';

  /// push 지연. 🔴 [OriginCodes.pushLag] 와 **문자열이 같고 축이 다르다**.
  static const String pushLag = 'PUSH_LAG';

  /// 배치 미수행.
  static const String batchMissing = 'BATCH_MISSING';

  /// 시계 어긋남.
  static const String clockSkew = 'CLOCK_SKEW';

  /// 전량 4종(⏸).
  static const Set<String> values = <String>{
    engineDown,
    pushLag,
    batchMissing,
    clockSkew,
  };
}

/// 등재되지 않은 코드가 사전 조회에 들어왔을 때 던진다.
///
/// 🔴 «모르는 코드를 조용히 통과시키는 것»이 이 계약이 가장 막고 싶은 것이다 —
///    통과하면 화면이 그 코드를 보고 자기 나름의 문구·아이콘·색을 고르기 시작한다.
final class UnregisteredContractCodeError extends Error {
  UnregisteredContractCodeError(this.code, {this.domain});

  /// 등재되지 않은 코드.
  final String code;

  /// 조회 대상 도메인(전역 조회면 null).
  final String? domain;

  @override
  String toString() => domain == null
      ? 'UnregisteredContractCodeError: "$code" is not in the 01 §3 code dictionary'
      : 'UnregisteredContractCodeError: "$code" is not registered in domain "$domain"';
}

/// 01 §3 코드 사전의 **단일 소스**(인벤토리 §6 «전 목록 배럴»).
///
/// 집계: 문서 137 + 6 =
///   ① SAF 접두 대역 7행 → 접두 **문자열** 8개(§3-2 표가 `SAF-8xx`·`SAF-9xx` 를 한 행으로 묶는다)
///   ② 계절 게이트 픽스처값 `ENTRY_GATE_OCT` 1개(⏸ 코드명 확정 전까지 픽스처가 쓰는 값)
///   ③ ⏸ `AsOf.staleReasonCode` 4개(M2-8 A-2 · 엔진 확정 대기)
/// 🔴 도메인이 다르면 **같은 문자열이 두 번 등재될 수 있다**
///    (`MANUAL_ORDER`·`RECON_MISMATCH`·`SELF_AUDIT_DUE`·`PUSH_LAG` 네 쌍 + 🆕 v1.22 `JOURNAL_MISSING`(`flag_id` ↔
///    `discretion_result`) = 다섯 쌍 + 🆕 v1.24 `CHAIN_BROKEN`(`origin_code` ↔ `ledger_integrity_result`) ·
///    `RESTORE_ROLLBACK`(`origin_code` ↔ `backup_result`) = 일곱 쌍 + 🆕 v1.30 E16i(01 §38 · v1.24 K140 예고 실현 + 열거 글자) 여덟 —
///    `X1_LIVE_ONLY`(`backup_result` ↔ `x1_start_result`) · `UNKNOWN_ORDERS_REMAIN`(`resume_reason` ↔ `x1_step_block`) ·
///    `FAILED`(`kill_cancel_outcome` ↔ `x1_step_state`) · `BLOCKED`(`verdict_code` ↔ `x1_gate_state`) ·
///    `OBSERVING`(`resume_reason` ↔ `x1_gate_state`) · `PASSED`(`sim_trial_state` ↔ `x1_gate_state`) ·
///    `SQLITE_INTEGRITY`·`FORMAT_VERSION`(`ledger_integrity_result` ↔ `ledger_boundary_reason`) = **열다섯 글자**
///    (`RESTORE_ROLLBACK` 은 `ledger_boundary_reason` 까지 세 축) + 🆕 v1.35(01 §44 · K294) 저널 kind 셋 —
///    `DISCRETION` · `RECON_CLEAR` · `KILL_SWITCH_RESUME`(`deviation_kind` ↔ `decision_journal_kind`) = **열여덟 글자**) —
///    그래서 [all] 의 크기는 등재 건수보다 작다. 전역 조회보다 [requireRegisteredIn] 을 쓴다.
abstract final class ContractCodes {
  /// 도메인 → 코드 집합. 🔴 키 이름은 01 §3·§6 의 절 제목에서 따온다.
  static const Map<String, Set<String>> byDomain = <String, Set<String>>{
    'exit_kind': ExitKindCodes.values,
    'saf_band': SafBandCodes.values,
    'saf309': Saf309Codes.values,
    'verdict_code': VerdictCodes.values,
    'planned_work_kind': PlannedWorkKindCodes.values,
    'gap_reason_code': GapReasonCodes.values,
    'origin_code': OriginCodes.values,
    'flag_id': FlagIds.values,
    'safety_hold': SafetyHoldCodes.values,
    'advice_reject': AdviceRejectCodes.values,
    'advice_transition_cause': AdviceTransitionCauseCodes.values,
    'decision_reason': DecisionReasonCodes.values,
    'seasonal_entry_gate': SeasonalEntryGateCodes.values,
    'seasonal_entry_gate_fixture': <String>{
      SeasonalEntryGateCodes.fixtureEntryGatePass,
    },
    'alert_code': AlertCodes.values,
    'deviation_kind': DeviationKindCodes.values,
    'ledger_event': LedgerEventCodes.values,
    'operating_param_key': OperatingParamKeys.values,
    'aftertax_step': AfterTaxStepCodes.values,
    'stale_reason': StaleReasonCodes.values,
    // 🆕 v1.1 — J-2 체인 단계 · 전수 검사 층 · J-5 해소 단계 · J-1 배지
    'decision_chain_stage': DecisionChainStageCodes.values,
    'safety_check_level': SafetyCheckLevelCodes.values,
    'unknown_resolution_stage': UnknownResolutionStageCodes.values,
    'journal_badge': JournalBadgeCodes.values,
    // 🆕 v1.1 R2 준비(2026-09-23) — J-3 사전 저널 제출의 거부 사유
    //    (`CommandReceipt.rejectReasonCode` — X7 의 `advice_reject` 와 다른 축)
    'journal_draft_reject': JournalDraftRejectCodes.values,
    // 🆕 v1.3(R10 선행) — 성과 열람 기록의 화면 코드(`DisclosureViewEvent.surfaceCode`)
    'disclosure_surface': DisclosureSurfaceCodes.values,
    // 🆕 v1.4(R11 선행) — 플래너 주문 초안의 사유 칩(`OrderDraft.reasons[].code`)
    'planner_reason': PlannerReasonCodes.values,
    // 🆕 E7a3-2(설계 13 §8 R18 D-11 · 계약 버전 불변) — 리밸런싱 미리보기 초안의 사유 칩
    'rebalance_reason': RebalanceReasonCodes.values,
    // 🆕 v1.7(J-4 선행) — blind 리뷰 점수 제출의 거부 사유(`CommandReceipt.rejectReasonCode`)
    'blind_review_reject': BlindReviewRejectCodes.values,
    // 🆕 v1.8(R4 선행) — 손절선 등급(`StopLineNormalized.tierCode` · C-44 ⑦ 이 픽스처와 맞댄다)
    'stop_tier': StopTierCodes.values,
    // 🆕 v1.10(E9a2 · ㊲) — 원장 사건 기록의 거부 사유(`CommandReceipt.rejectReasonCode`)
    'ledger_event_reject': LedgerEventRejectCodes.values,
    // 🆕 v1.11(E7b0) — 실입금 등록의 거부 사유(`CommandReceipt.rejectReasonCode`)
    'deposit_register_reject': DepositRegisterRejectCodes.values,
    // 🆕 v1.12(01 §21 · K20) — X7 기록 명령의 재제출 선택지(`CommandReceipt.retryCode`)
    'advice_retry': AdviceRetryCodes.values,
    // 🆕 v1.12(K19) — 수기 체결 초안의 «채우기» 필드(`ManualFillInput.prefilledFields` · C-5 «values 집합 = 등재»)
    'manual_fill_prefill': ManualFillPrefillFields.values,
    // 🆕 v1.16(01 §25 · K21) — 온보딩·페어링 결과의 앱 코드(`ActionResult.reasonCode` · `PairingResult.reasonCode`)
    'onboarding_result': OnboardingResultCodes.values,
    // 🆕 v1.16(01 §25 · K21) — 브로커 원문 코드(계약 표본이 쓰는 것 · 전수 아님 · 01 §8 미결 157)
    'broker_raw': BrokerRawCodes.values,
    // 🆕 v1.16(01 §25 · K21) — 온보딩 🔒 슬롯 이름(`secretSlotId`·`slotId`·`loginSlotId`·`scannerSlotId`)
    'onboarding_slot': OnboardingSlotIds.values,
    // 🆕 v1.17(01 §26 · K19) — M8 운영 슬롯 이름(`EmergencyCardVm.printSlotId`)
    'ops_slot': OpsSlotIds.values,
    // 🆕 v1.17(01 §26 · 엔진 D11 · K28) — 일지 사유 칩 코드 중 D11 2종(`TradeJournalEntry.reasons[].code` · 🔴 전수 아님)
    'journal_reason': JournalReasonCodes.values,
    // 🆕 v1.18(01 §27 · K-n ⓗ) — M9 연결 대상 · 알림 채널 · 설정 동작 결과
    'connection_target': ConnectionTargetCodes.values,
    'notify_channel': NotifyChannelCodes.values,
    'settings_result': SettingsResultCodes.values,
    // 🆕 v1.19(01 §28 · K14) — S05 엔진 중지 사유(사람)
    'engine_stop_reason': EngineStopReasonCodes.values,
    // 🆕 v1.19(01 §28 · K15 · K21) — E15i 등재형(엔진 글자 1:1)
    'sim_trial_item': SimTrialItemCodes.values,
    'sim_trial_state': SimTrialItemStateCodes.values,
    'live_observation_block': LiveObservationBlockCodes.values,
    'live_promotion_result': LivePromotionResultCodes.values,
    'mode_startup': ModeStartupCodes.values,
    'sim_opening_result': SimOpeningResultCodes.values,
    // 🆕 v1.20(01 §29 · K8 · K9) — S02 키 세트 종류(엔진 겹침) · M9 슬롯 이름
    'credential_kind': CredentialKindCodes.values,
    'settings_slot': SettingsSlotIds.values,
    // 🆕 v1.21(01 §30 · K12 · K13) — M5 결과 · 게이지(엔진 글자 1:1)
    'kill_switch_result': KillSwitchResultCodes.values,
    'safety_common_result': SafetyCommonResultCodes.values,
    'pledge_result': PledgeResultCodes.values,
    'gauge': GaugeCodes.values,
    // 🆕 v1.22(01 §31) — E13 나머지 · E14i · E15i(엔진 글자 1:1)
    'stopped_decision_result': StoppedDecisionResultCodes.values,
    'postmortem_result': PostmortemResultCodes.values,
    'intervention_result': InterventionResultCodes.values,
    'rule_change_result': RuleChangeResultCodes.values,
    'discretion_result': DiscretionResultCodes.values,
    'resume_reason': ResumeItemReasonCodes.values,
    'seasonal_choice_result': SeasonalChoiceResultCodes.values,
    'planned_work_reject': PlannedWorkRejectCodes.values,
    'sim_to_auto_result': SimToAutoResultCodes.values,
    'sim_to_auto_commit_result': SimToAutoCommitResultCodes.values,
    'handover_session_result': HandoverSessionResultCodes.values,
    'sim_to_auto_step': SimToAutoStepIds.values,
    // 🆕 v1.23(01 §32 · K80) — S13 월 납입 거부(엔진 글자 1:1 − 공용)
    'contribution_result': ContributionResultCodes.values,
    // 🆕 v1.24(01 §33 · K119) — S09 백업 거부 · S10 무결성 사유(엔진 글자 1:1)
    'backup_result': BackupResultCodes.values,
    'ledger_integrity_result': LedgerIntegrityResultCodes.values,
    // 🆕 v1.25(01 §34 · K151) — 킬스위치 미체결 취소 결과(엔진 wire 1:1 · 사전 도메인 사이 겹침 0 — 같은 글자는 열거 와이어뿐)
    'kill_cancel_outcome': KillCancelOutcomeCodes.values,
    // 🆕 v1.26(01 §35 · K182) — RECON 해제 거부(엔진 예고 · 공용 2 따로)
    'recon_clear_result': ReconClearResultCodes.values,
    // 🆕 v1.28(01 §37 · K200) — S04 읽기 행 코드(엔진 글자 1:1 · 화면 미참조)
    'allocation_row': AllocationRowCodes.values,
    // 🆕 v1.29(01 §39 · E11k-b) — Supabase 연결 · 신뢰 시각 · 리스(엔진 enum 1:1 · 와이어 글자 = 계약 · 🔴 타입 이름 ≠ 엔진)
    'supabase_input_result': SupabaseInputResultCodes.values,
    'supabase_time_result': SupabaseTimeResultCodes.values,
    'lease_rpc_result': LeaseRpcResultCodes.values,
    // 🆕 v1.31(01 §40 · E11k-d2) — Supabase 로그인 · 세션 고유 실패(전송 6 = `supabase_time_result` 한 벌)
    'supabase_auth_result': SupabaseAuthResultCodes.values,
    // 🆕 v1.30(01 §38 · E16i) — X1 기기 이전 · 새 폰 복구 · 유지보수 창(엔진 글자 1:1 − 공용 `TRUSTED_TIME_UNKNOWN`)
    'x1_start_result': X1StartResultCodes.values,
    'x1_step_block': X1StepBlockCodes.values,
    'x1_journal_result': X1JournalResultCodes.values,
    'x1_boot_refusal': X1BootRefusalCodes.values,
    'x1_restore_result': X1RestoreResultCodes.values,
    'x1_fencing_result': X1FencingResultCodes.values,
    'x1_reissue_result': X1ReissueResultCodes.values,
    'x1_reissue_item': X1ReissueItemCodes.values,
    'x1_recovery_result': X1RecoveryResultCodes.values,
    'x1_order_seal': X1OrderSealCodes.values,
    'x1_gate_reason': X1GateReasonCodes.values,
    'maintenance_window_result': MaintenanceWindowResultCodes.values,
    'x1_intent_reason': X1IntentReasonCodes.values,
    'x1_plan_step': X1StepCodes.values,
    'x1_step_state': X1StepStateCodes.values,
    'x1_kind': X1KindCodes.values,
    'x1_role': X1RoleCodes.values,
    'x1_recovery_step': X1RecoveryStepCodes.values,
    'x1_gate_state': X1GateStateCodes.values,
    'x1_gap_violation': X1GapViolationCodes.values,
    'maintenance_window_event': MaintenanceWindowEventCodes.values,
    // 🆕 v1.30(01 §38 · E16i) — X5 정정 · 새 기준점 · X1/X5 경계 · 파생 관계(엔진 글자 1:1)
    'repair_result': RepairResultCodes.values,
    'baseline_result': BaselineResultCodes.values,
    'ledger_boundary_reason': LedgerBoundaryReasonCodes.values,
    'derived_relation': DerivedRelationCodes.values,
    // 🆕 v1.32(01 §41 · E16j-a) — 새 기준점 저장 쪽 거부(ds `BaselineStoreCodes` − 공용)
    'baseline_apply_result': BaselineApplyResultCodes.values,
    // 🆕 v1.33(01 §42 · E16j-b) — X1 이전 화면 🔒 슬롯 이름
    'x1_slot': X1SlotIds.values,
    // 🆕 v1.35(01 §44) — X5 정정 원문 거부(K291) · 원장 저널 kind(K294) · J-3 인용 규칙(K300)
    'repair_input_result': RepairInputResultCodes.values,
    'decision_journal_kind': DecisionJournalKinds.values,
    'journal_rule_cited': JournalRuleCitedCodes.values,
    // 🆕 v1.37(01 §46) — M5-13 보관 명령 일괄 확정 거부(K319) · X1 계획 이전 리스 넘김 거부(K324 · K325)
    'held_review_result': HeldReviewResultCodes.values,
    'lease_handover_result': LeaseHandoverResultCodes.values,
    // 🆕 v1.38(01 §47 · K333 · E11l2) — 읽기 모델 push RPC 고유 거부 2(리스 거부 = `lease_rpc_result` 한 벌)
    'read_model_push_result': ReadModelPushResultCodes.values,
    // 🆕 v1.39(01 §48 · K347 · K349 ④) — 닫힌 원장 쓰기 거부(모든 명령 접수증 · 동작 결과) · o_07 공개 가입 확인
    'ledger_write_gate': LedgerWriteGateCodes.values,
    'supabase_signup_result': SupabaseSignupResultCodes.values,
    // 🆕 v1.40(01 §49 · 미결 229 · 13 R270) — 운영 폰 공유 표 push RPC 고유 거부 2(리스 거부 = `lease_rpc_result` 한 벌)
    'ops_push_result': OpsPushResultCodes.values,
  };

  /// 전 도메인의 코드 합집합(중복 문자열은 한 번만 남는다).
  static final Set<String> all = <String>{
    for (final Set<String> codes in byDomain.values) ...codes,
  };

  /// 이 도메인이 사전에 있는가.
  static bool hasDomain(String domain) => byDomain.containsKey(domain);

  /// 어느 도메인에든 등재된 코드인가.
  static bool isRegistered(String code) => all.contains(code);

  /// 이 도메인에 등재된 코드인가. 도메인 자체가 없으면 false.
  static bool isRegisteredIn(String domain, String code) =>
      byDomain[domain]?.contains(code) ?? false;

  /// 이 코드가 속한 도메인 전부(중복 등재가 있으므로 **집합**을 돌려준다).
  static Set<String> domainsOf(String code) => <String>{
    for (final MapEntry<String, Set<String>> e in byDomain.entries)
      if (e.value.contains(code)) e.key,
  };

  /// 🔴 **미등록이면 실패한다** — 도메인을 지정한 조회(권장).
  ///
  /// 반환값은 입력 [code] 그대로이므로 파이프라인 안에서 그대로 쓸 수 있다.
  /// Throws [UnregisteredContractCodeError].
  static String requireRegisteredIn(String domain, String code) {
    if (!byDomain.containsKey(domain)) {
      throw UnregisteredContractCodeError(code, domain: domain);
    }
    if (!byDomain[domain]!.contains(code)) {
      throw UnregisteredContractCodeError(code, domain: domain);
    }
    return code;
  }

  /// 🔴 **미등록이면 실패한다** — 도메인을 모를 때의 전역 조회.
  ///
  /// 🔴 도메인을 아는 자리에서는 [requireRegisteredIn] 을 쓴다.
  /// 전역 조회는 «`flag_id` 자리에 알림 코드가 들어온 것»을 잡지 못한다.
  /// Throws [UnregisteredContractCodeError].
  static String requireRegistered(String code) {
    if (!all.contains(code)) {
      throw UnregisteredContractCodeError(code);
    }
    return code;
  }
}
```

---

## `packages/domain_contracts/lib/src/labels/ledger_event_codes.dart`

```dart
// 01 §3-6 — 원장 이벤트 코드 1종(납입 조달) · §6-2 `operating_param_log.param_key` 1종 ·
// 🆕 v1.10 ㊲ `recordLedgerEvent` 거부 사유 8종(01 §19).
//
// 🔴 **조달은 계산이지 화면의 판단이 아니다.** 무엇을 얼마나 파는지는 엔진이
//    `00_SPEC §5-5b` 순서로 정하고, 화면은 `DepositPlan`·`RebalancePreview` 가 실어 주는
//    **조달 단계 목록을 순서 그대로** 그린다. 화면이 "부족하니 이걸 팔면 된다"를 계산하면 C-5 위반이다.

/// 원장 이벤트 코드(01 §3-6).
abstract final class LedgerEventCodes {
  /// v2.32 납입 조달 — 코어 밴드·초기 램프의 C→B 신규 납입에서 슬리브 C 원화현금이
  /// 한도 내 필요액에 못 미쳐 부족분을 조달 순서(**연금계좌 제외** · 새틀 잉여 → C 방어자산 매각)로
  /// 먼저 조달한 경우. 엔진 플래그 `pension_funding=true`.
  ///
  /// ⚠️ 이 코드가 `decision_log.reason_code` 로만 오는지 `decision_log.kind` 값을 신설할지는
  ///    **배치 E 판단**(01 §3-6 말미). 🔴 확정 전까지 화면은 `reason_code` 문자열로만 분기한다.
  ///    배치 E 는 「`decision_log.kind` 추가 없음」을 명시하므로 현재는 `reason_code` 다.
  static const String pensionFunding = 'PENSION_FUNDING';

  /// 전량 1종.
  static const Set<String> values = <String>{pensionFunding};
}

/// `operating_param_log.param_key` 화이트리스트(01 §6-2 · 인벤토리 §6-14).
///
/// 🔴 **화이트리스트다** — `fx_overlay` 계열 키를 넣지 않는다(영구 기각된 규칙의 부활 경로).
/// 🔴 이 표는 전략 `config_hash` 에 들어가지 않는다(골든벡터 불변).
/// 🔴 **금액 자체를 여기 상수로 적지 않는다**(C-32) — 값은 `operating_param_log.value_text` 다.
abstract final class OperatingParamKeys {
  /// 월 추가 납입 운영값.
  static const String monthlyContribution = 'monthly_contribution';

  /// 전량 1종.
  static const Set<String> values = <String>{monthlyContribution};
}

// ⏸ `LedgerEventKind { withdrawal, distribution, corporateAction, taxWithheld }`
//    (`WITHDRAWAL`·`DISTRIBUTION`·`CORPORATE_ACTION`·`TAX_WITHHELD`)
//    — M2-8 A-15·J-6. 🔴 **결정 ㊲ 채택 시에만 신설**하며 지금은 코드로 만들지 않는다.
//    열거형 자체의 자리는 영역 A 의 `enums/ledger.dart` 주석이고, 여기 상수로 앞질러 두지 않는다.
//    채택되지 않으면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 현금 추정이 단조적으로
//    어긋나고 그 위에서 안내 수량이 계산된다(J-6).

/// 🆕 v1.10 · ㊲ `recordLedgerEvent` 의 거부 사유 8종(`CommandReceipt.rejectReasonCode` · 설계 13 §8 R21 L6).
///
/// 🔴 **형식 오류·재해석만 거부한다.** 인출 > 추정 현금 · 원장에 없는 종목의 분배금은 거부가 아니라
///    접수 + 원장 신뢰 등급 `drifting` 이다 — 사실을 거부하면 원장이 거짓이 된다(01 §10-4).
/// 🔴 새 기록에 리스가 없으면 거부가 아니라 `pendingLeaseConfirm` 강등 접수 · 무효(재해석)는
///    `AdviceRejectCodes.leaseExpired` 를 쓴다(B19) · 무결성 차단 중은 `heldForIntegrity` 보관(B18).
abstract final class LedgerEventRejectCodes {
  /// kind 와 칸 조합 위반(인출에 종목 · 기업행위에 비율 없음 · 무효에 값 칸 등).
  static const String fieldsMismatch = 'LEDGER_EVENT_FIELDS_MISMATCH';

  /// 미래일 · 원장 개시일 이전 · 휴장일. 🔴 판정은 거래소 캘린더를 아는 엔진만.
  static const String dateInvalid = 'LEDGER_EVENT_DATE_INVALID';

  /// 0 이하 · 설정 상한 초과 · 원천징수 > 세전 분배금.
  static const String amountInvalid = 'LEDGER_EVENT_AMOUNT_INVALID';

  /// 분할·병합 밖(합병·상장폐지·권리) → `L-3` 실사 경로를 함께 제시한다(R21 L5).
  static const String corporateActionUnsupported =
      'CORPORATE_ACTION_UNSUPPORTED';

  /// 비율 ≤ 0 · from = to · 분할인데 to < from(병합은 그 반대).
  static const String corporateActionRatioInvalid =
      'CORPORATE_ACTION_RATIO_INVALID';

  /// 효력일에 원장 보유 0 인 종목의 분할·병합 — 바꿀 수량이 없다(실사 유도).
  static const String corporateActionSymbolNotHeld =
      'CORPORATE_ACTION_SYMBOL_NOT_HELD';

  /// 이미 상쇄된 사건 · 없는 사건의 무효.
  static const String voidTargetNotActive =
      'LEDGER_EVENT_VOID_TARGET_NOT_ACTIVE';

  /// 24h 안 같은 kind·효력일·금액 → `duplicateAck = true` 로 재제출.
  static const String duplicateSuspected = 'LEDGER_EVENT_DUPLICATE_SUSPECTED';

  /// 전량 8종.
  static const Set<String> values = <String>{
    fieldsMismatch,
    dateInvalid,
    amountInvalid,
    corporateActionUnsupported,
    corporateActionRatioInvalid,
    corporateActionSymbolNotHeld,
    voidTargetNotActive,
    duplicateSuspected,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/migration_codes.dart`

```dart
// 🆕 계약 v1.30(01 §38 · K209~ · E16i 계약 창) — X1 기기 이전 · 새 폰 복구 · 감시 유지보수 창의 **엔진 글자 사전**.
//
// 엔진(E16b~E16t3a)이 «계약 등재 = E16i 전 문자열»로 이미 쓰는 거부 · 막음 · 단계 · 상태 글자를 1:1 로 등재한다.
// 🔴 타입 이름 ≠ 엔진(core `MigrationStartCodes` · `PlanBlockCodes` · `FencingCodes` · `ReissueCodes` · `ReissueItem` ·
//    `RecoverySealCodes` · `MigrationGateCodes` · `PlanStep` · `MigrationStepState` · `MigrationKind` · `MigrationRole` ·
//    `RecoveryStep` · `MigrationGateState` · `GapViolationKind` · `WindowEvent` · data_sync `MigrationStoreCodes` ·
//    `MigrationBootCodes` · `RecoveryCodes` · `WindowStoreCodes` · `LedgerRestoreCodes` — 같으면 엔진 시험이 두 배럴을 함께
//    import 해 `ambiguous_import` · v1.21 K33 · v1.23 K80 결). 엔진이 계약 참조로 옮길 때 지역 선언을 지운다(엔진 숙제).
// 🔴 공용 `TRUSTED_TIME_UNKNOWN` 은 싣지 않는다 — `SafetyCommonResultCodes` 한 벌(K45). 이전 시작 · 펜싱 · 재발급 · 유지보수 창
//    거부 전집 = 이 사전 ∪ 공용.
// 🔴 이 글자로 화면이 분기 · 아이콘 · 색 · 문구를 고르지 않는다 — 문구 · 레벨 · 단계 표시는 엔진이 VM 에 실어 준다(E16j 화면 계약 =
//    다음 판 · 01 §8 미결 211). 이 사전의 쓰임 = 픽스처 · 엔진 대조(C-63) · 미등록 코드 조기 실패.
// 🔴 수치 0 — 관찰 일수 · 넘김 시간 · 펜싱 마진 · 재생성 상한 = 엔진 운영 설정 `operations.migration`(⬜ 발주자 수치 · 잠정) 그대로.

/// 이전 시작 거부(도메인 `x1_start_result` · 엔진 core `migration/migration_plan.dart:112-127` 5 − 공용 1).
/// 🔴 [liveOnly] = `BackupResultCodes.liveOnly` 와 같은 글자 다른 축(C-5 문서 쌍 · v1.24 K140 예고 실현).
abstract final class X1StartResultCodes {
  /// live 파일이 아니다(체험 중 폰 교체 = 모의 폐기 + 새 개시).
  static const String liveOnly = 'X1_LIVE_ONLY';

  /// 안내 모드 기기 이전 = 조건 결정 대기.
  static const String advisoryPending = 'X1_ADVISORY_PENDING';

  /// 계획 교체인데 `D-03` 확인 결정이 없다.
  static const String d03NotConfirmed = 'D03_NOT_CONFIRMED';

  /// 비상인데 선언 결정이 없다.
  static const String emergencyNotDeclared = 'EMERGENCY_NOT_DECLARED';

  static const Set<String> values = <String>{
    liveOnly,
    advisoryPending,
    d03NotConfirmed,
    emergencyNotDeclared,
  };
}

/// 계획 교체 단계 막음(도메인 `x1_step_block` · 엔진 core `migration_plan.dart:348-363` 5).
/// 🔴 [unknownOrders] = `ResumeItemReasonCodes.unknownOrders` 와 같은 글자 다른 축(C-5 문서 쌍).
abstract final class X1StepBlockCodes {
  /// 미체결 주문이 남았다.
  static const String openOrders = 'OPEN_ORDERS_REMAIN';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'UNKNOWN_ORDERS_REMAIN';

  /// 최종 대사가 0오차가 아니다.
  static const String reconNotZero = 'RECON_NOT_ZERO';

  /// 체크섬 백업이 없다.
  static const String backupMissing = 'BACKUP_MISSING';

  /// 백업 매니페스트 체인이 지금 체인과 다르다.
  static const String backupChainMismatch = 'BACKUP_CHAIN_MISMATCH';

  static const Set<String> values = <String>{
    openOrders,
    unknownOrders,
    reconNotZero,
    backupMissing,
    backupChainMismatch,
  };
}

/// 이전 저널 저장 거부(도메인 `x1_journal_result` · 엔진 data_sync `migration/migration_journal_store.dart:22-31` 3).
abstract final class X1JournalResultCodes {
  /// 이 파일에 진행 중인 이전이 이미 있다.
  static const String runExists = 'X1_RUN_EXISTS';

  /// 단계 차례가 어긋났다.
  static const String stepOutOfOrder = 'X1_STEP_OUT_OF_ORDER';

  /// 되돌릴 수 없는 점(DEMOTED)을 지났다.
  static const String pastNoReturn = 'X1_PAST_NO_RETURN';

  static const Set<String> values = <String>{
    runExists,
    stepOutOfOrder,
    pastNoReturn,
  };
}

/// 이전 기동 거부(도메인 `x1_boot_refusal` · 엔진 data_sync `migration/migration_lease_gate.dart:13-19` 2).
/// 🔴 기동 거부 전집(data_sync `migration/x1_startup.dart:39-49`) = 이 사전 ∪ X1 길 경계 사유([LedgerBoundaryReasonCodes] 가운데
///    `DB_OPEN_FAILED` · `SQLITE_INTEGRITY` · `STAMP_CHAIN_BROKEN` · `RESTORE_ROLLBACK` · `ARCHIVE_DIVERGED`).
abstract final class X1BootRefusalCodes {
  /// 이 기기는 강등됐다(DEMOTED 들어감).
  static const String demoted = 'X1_DEMOTED';

  /// 이전 저널을 읽을 수 없다.
  static const String journalBroken = 'X1_JOURNAL_BROKEN';

  static const Set<String> values = <String>{demoted, journalBroken};
}

/// 새 폰 복원 검증 · 적용 거부 중 v1.24 에 없던 몫(도메인 `x1_restore_result` · 엔진 core `migration/backup_manifest.dart:137-160`
/// `RestoreReason` 7 가운데 2 + data_sync `migration/ledger_restore.dart:21-24` 1).
/// 🔴 복원 거부 전집 = 이 사전 ∪ `BackupResultCodes` 의 `liveOnly` · `unreadable` · `schemaSkew` · `sqliteIntegrity` ·
///    `chainInvalid` · `rollback`(같은 엔진 상수 = 한 벌 · v1.24 K132 나눔을 잇는다 — 두 번 등재하지 않는다).
abstract final class X1RestoreResultCodes {
  /// 사본 sha256 이 매니페스트와 다르다.
  static const String shaMismatch = 'RESTORE_SHA_MISMATCH';

  /// 사본 머리가 매니페스트와 다르다.
  static const String manifestMismatch = 'RESTORE_MANIFEST_MISMATCH';

  /// 이 폰에 live 원장이 이미 있다(같은 폰 복원 금지 · 덮지 않는다).
  static const String liveExists = 'X1_LIVE_EXISTS';

  static const Set<String> values = <String>{
    shaMismatch,
    manifestMismatch,
    liveExists,
  };
}

/// 비상 펜싱 대기(도메인 `x1_fencing_result` · 엔진 core `migration/fencing.dart:44-53` 3 − 공용 1).
abstract final class X1FencingResultCodes {
  /// REVOKED 가 아직 없다(대기 시작 전).
  static const String notStarted = 'FENCING_NOT_STARTED';

  /// 펜싱 대기 중(끝 시각 = 엔진 · 마진 = ⬜ 발주자 수치).
  static const String waiting = 'FENCING_WAIT';

  static const Set<String> values = <String>{notStarted, waiting};
}

/// 비상 재발급 거부(도메인 `x1_reissue_result` · 엔진 core `migration/reissue_checklist.dart:43-61` 6 − 공용 1).
abstract final class X1ReissueResultCodes {
  /// 새 값의 지문이 옛 지문 가운데 하나다(보관한 옛 문자열 재입력 0).
  static const String keyReused = 'KEY_REUSED';

  /// 이 항목은 «해당 없음»으로 둘 수 없다(KIS 앱키 = 늘 필수).
  static const String notApplicable = 'REISSUE_NOT_APPLICABLE';

  /// 이미 기록한 항목이다.
  static const String duplicate = 'REISSUE_DUPLICATE';

  /// 값이 있는 항목인데 새 지문이 없다.
  static const String fingerprintRequired = 'REISSUE_FINGERPRINT_REQUIRED';

  /// 값이 없는 항목(철회 · 재로그인 확인)인데 지문이 왔다.
  static const String fingerprintUnexpected = 'REISSUE_FINGERPRINT_UNEXPECTED';

  static const Set<String> values = <String>{
    keyReused,
    notApplicable,
    duplicate,
    fingerprintRequired,
    fingerprintUnexpected,
  };
}

/// 비상 재발급 항목(도메인 `x1_reissue_item` · 엔진 core `reissue_checklist.dart:11-29` `ReissueItem.wire` 6 · 차례 = 06 X1-3).
/// 🔴 항목 문구(«증권사 앱키» 등)는 엔진 글자 — 계약은 싣지 않는다(VM = 다음 판).
abstract final class X1ReissueItemCodes {
  /// KIS 앱키(새 키 지문 · 늘 필수).
  static const String kisAppKey = 'KIS_APP_KEY';

  /// 메신저 토큰.
  static const String messengerToken = 'MESSENGER_TOKEN';

  /// 워치독 핑 키.
  static const String watchdogPingKey = 'WATCHDOG_PING_KEY';

  /// GitHub PAT.
  static const String githubPat = 'GITHUB_PAT';

  /// 원격 세션 철회(값 없음 — 확인만).
  static const String supabaseSession = 'SUPABASE_SESSION';

  /// 옛 기기 Google 액세스 철회(값 없음 — 확인만).
  static const String googleAccess = 'GOOGLE_ACCESS';

  /// 차례 = 엔진 선언 차례(06 X1-3).
  static const List<String> ordered = <String>[
    kisAppKey,
    messengerToken,
    watchdogPingKey,
    githubPat,
    supabaseSession,
    googleAccess,
  ];

  static const Set<String> values = <String>{
    kisAppKey,
    messengerToken,
    watchdogPingKey,
    githubPat,
    supabaseSession,
    googleAccess,
  };
}

/// 새 폰 복구 저널 거부(도메인 `x1_recovery_result` · 엔진 data_sync `migration/recovery_journal_store.dart:21-27` 2).
abstract final class X1RecoveryResultCodes {
  /// 아직 복원(RESTORED)하지 않았다.
  static const String notRestored = 'X1_NOT_RESTORED';

  /// 리스 epoch 가 매니페스트보다 앞서지 않았다.
  static const String epochNotAdvanced = 'X1_EPOCH_NOT_ADVANCED';

  static const Set<String> values = <String>{notRestored, epochNotAdvanced};
}

/// 새 폰 복구 주문 봉인(도메인 `x1_order_seal` · 엔진 core `migration/gap_rebuild.dart:393-399` 2 ·
/// 앱 `engine/x1_wiring.dart:20` `X1OrderSealed(code)` 의 code).
abstract final class X1OrderSealCodes {
  /// 갭 재구성이 끝나지 않았다 — 주문 봉인.
  static const String inProgress = 'X1_RECOVERY_IN_PROGRESS';

  /// RECOVERY_FULL — 사람의 R-01 «잔고 승계 새 시작»까지 안전 정지.
  static const String full = 'X1_RECOVERY_FULL';

  static const Set<String> values = <String>{inProgress, full};
}

/// X1-5 LIVE 재개 게이트 막음(도메인 `x1_gate_reason` · 엔진 core `migration/migration_gate.dart:62-86` 8).
abstract final class X1GateReasonCodes {
  /// 골든 자가검사 아직.
  static const String goldenNotRun = 'X1_GOLDEN_NOT_RUN';

  /// 골든 자가검사 실패.
  static const String goldenFailed = 'X1_GOLDEN_FAILED';

  /// 대사가 0오차가 아니다.
  static const String reconNotZero = 'X1_RECON_NOT_ZERO';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'X1_UNKNOWN_ORDERS_REMAIN';

  /// 미체결 주문이 남았다.
  static const String openOrders = 'X1_OPEN_ORDERS_REMAIN';

  /// 관찰 중(n/m · 관찰 일수 = ⬜ 발주자 수치).
  static const String observing = 'X1_OBSERVING';

  /// 체크리스트 확인 대기.
  static const String checklistPending = 'X1_CHECKLIST_PENDING';

  /// 생체 확인 대기.
  static const String biometricPending = 'X1_BIOMETRIC_PENDING';

  static const Set<String> values = <String>{
    goldenNotRun,
    goldenFailed,
    reconNotZero,
    unknownOrders,
    openOrders,
    observing,
    checklistPending,
    biometricPending,
  };
}

/// 감시 유지보수 창 열기 거부(도메인 `maintenance_window_result` · 엔진 data_sync
/// `migration/maintenance_window_store.dart:19-25` 2 − 공용 1).
abstract final class MaintenanceWindowResultCodes {
  /// 이미 열린 창이 있다.
  static const String alreadyOpen = 'MW_ALREADY_OPEN';

  static const Set<String> values = <String>{alreadyOpen};
}

/// 복구 주문 의도 표지(도메인 `x1_intent_reason` · 엔진 core `migration/gap_rebuild.dart:40` `kX1RecoveredReason` ·
/// `order_intents.error_message` — 갭 재구성이 지은 의도 · authored = 복구).
abstract final class X1IntentReasonCodes {
  /// 새 폰 복구가 지은 의도.
  static const String recovered = 'X1_RECOVERED';

  static const Set<String> values = <String>{recovered};
}

// ── 열거 글자(와이어 · 저장 값) ─────────────────────────────────────────────

/// 옛 폰 계획 교체 단계(도메인 `x1_plan_step` · 엔진 core `migration_plan.dart:68-95` `PlanStep.wire` 9 · `migration_step.step`).
abstract final class X1StepCodes {
  /// 신규 주문 동결.
  static const String freeze = 'FREEZE';

  /// 미체결 0 ∧ UNKNOWN 0.
  static const String ordersCleared = 'ORDERS_CLEARED';

  /// 최종 대사 0오차.
  static const String reconZero = 'RECON_ZERO';

  /// 체크섬 백업.
  static const String backupChecksum = 'BACKUP_CHECKSUM';

  /// 🔴 로컬 강등 표시 — 되돌릴 수 없는 점.
  static const String demoted = 'DEMOTED';

  /// 키 삭제.
  static const String keysDeleted = 'KEYS_DELETED';

  /// RETIRED 서명.
  static const String retired = 'RETIRED';

  /// 서비스 종료.
  static const String serviceStopped = 'SERVICE_STOPPED';

  /// 이전 티켓 발급(강등 끝난 뒤에만).
  static const String ticketIssued = 'TICKET_ISSUED';

  /// 차례 = 엔진 선언 차례(R117 B3).
  static const List<String> ordered = <String>[
    freeze,
    ordersCleared,
    reconZero,
    backupChecksum,
    demoted,
    keysDeleted,
    retired,
    serviceStopped,
    ticketIssued,
  ];

  static const Set<String> values = <String>{
    freeze,
    ordersCleared,
    reconZero,
    backupChecksum,
    demoted,
    keysDeleted,
    retired,
    serviceStopped,
    ticketIssued,
  };
}

/// 이전 단계 행 상태(도메인 `x1_step_state` · 엔진 core `migration_plan.dart:45-54` `MigrationStepState.wire` 3 ·
/// `migration_step.state`).
/// 🔴 [failed] = `KillCancelOutcomeCodes.failed` 와 같은 글자 다른 축(C-5 문서 쌍).
abstract final class X1StepStateCodes {
  /// 들어감.
  static const String entered = 'ENTERED';

  /// 끝남.
  static const String done = 'DONE';

  /// 실패(DEMOTED 앞에서만).
  static const String failed = 'FAILED';

  static const Set<String> values = <String>{entered, done, failed};
}

/// 이전 갈래(도메인 `x1_kind` · 엔진 core `migration_plan.dart:17-23` `MigrationKind.wire` 2 · `migration_run.kind`).
abstract final class X1KindCodes {
  /// 계획 교체(옛 폰이 옆에 있다).
  static const String plan = 'PLAN';

  /// 비상(옛 폰을 잃었다).
  static const String emergency = 'EMERGENCY';

  static const Set<String> values = <String>{plan, emergency};
}

/// 이 파일 기기의 이전 역할(도메인 `x1_role` · 엔진 core `migration_plan.dart:31-37` `MigrationRole.wire` 2 ·
/// `migration_run.role`).
abstract final class X1RoleCodes {
  /// 옛 폰.
  static const String oldDevice = 'OLD_DEVICE';

  /// 새 폰.
  static const String newDevice = 'NEW_DEVICE';

  static const Set<String> values = <String>{oldDevice, newDevice};
}

/// 새 폰 복구 단계(도메인 `x1_recovery_step` · 엔진 core `migration/recovery_steps.dart:7-22` `RecoveryStep.wire` 5).
abstract final class X1RecoveryStepCodes {
  /// 백업 복원.
  static const String restored = 'RESTORED';

  /// 갭 재구성 끝.
  static const String gapRebuilt = 'GAP_REBUILT';

  /// 골든 자가 시험.
  static const String goldenSelfTest = 'GOLDEN_SELF_TEST';

  /// 체크리스트 확인.
  static const String checklistConfirmed = 'CHECKLIST_CONFIRMED';

  /// 생체 확인.
  static const String biometricConfirmed = 'BIOMETRIC_CONFIRMED';

  /// 차례 = 엔진 선언 차례.
  static const List<String> ordered = <String>[
    restored,
    gapRebuilt,
    goldenSelfTest,
    checklistConfirmed,
    biometricConfirmed,
  ];

  static const Set<String> values = <String>{
    restored,
    gapRebuilt,
    goldenSelfTest,
    checklistConfirmed,
    biometricConfirmed,
  };
}

/// X1-5 LIVE 재개 게이트 상태(도메인 `x1_gate_state` · 엔진 core `migration_gate.dart:42-54` `MigrationGateState.wire` 4).
/// 🔴 [blocked] = `VerdictCodes.blocked` · [observing] = `ResumeItemReasonCodes.observing` · [passed] =
///    `SimTrialItemStateCodes.passed` 와 같은 글자 다른 축(C-5 문서 쌍 셋). 관찰 n/m = 엔진 글자(다음 판 VM).
abstract final class X1GateStateCodes {
  /// 막힘(매매 없는 안전 정지 그대로 · 막음 코드 = [X1GateReasonCodes]).
  static const String blocked = 'BLOCKED';

  /// 관찰 중(dryRun).
  static const String observing = 'OBSERVING';

  /// 승인 대기(체크리스트 → 생체).
  static const String awaitingApproval = 'AWAITING_APPROVAL';

  /// 통과(LIVE 재개 가능).
  static const String passed = 'PASSED';

  static const Set<String> values = <String>{
    blocked,
    observing,
    awaitingApproval,
    passed,
  };
}

/// 갭 재구성 위반(도메인 `x1_gap_violation` · 엔진 core `migration/gap_rebuild.dart:275-284` `GapViolationKind.wire` 3 ·
/// 위반 = 대사 차단 · «봇 전용 계좌» 위반).
abstract final class X1GapViolationCodes {
  /// 복원 보유 + 갭 체결 ≠ 브로커 보유.
  static const String holdingMismatch = 'GAP_HOLDING_MISMATCH';

  /// 보유보다 많이 팔았다(중간 음수).
  static const String oversold = 'GAP_OVERSOLD';

  /// 전략 대응이 없다(복구 의도를 지을 수 없다).
  static const String unmappedStrategy = 'GAP_UNMAPPED_STRATEGY';

  static const Set<String> values = <String>{
    holdingMismatch,
    oversold,
    unmappedStrategy,
  };
}

/// 감시 유지보수 창 사건(도메인 `maintenance_window_event` · 엔진 core `migration/maintenance_window.dart:15-27`
/// `WindowEvent.wire` 4). 알림 = `AlertCodes.maintenanceWindowOverdue` · `maintenanceResumeFailed`(다른 글자 · 겹침 0).
abstract final class MaintenanceWindowEventCodes {
  /// 열림(감시 일시정지).
  static const String opened = 'OPENED';

  /// 넘김(P1 · 창당 1건 · 넘김 시간 = ⬜ 발주자 수치).
  static const String overdue = 'OVERDUE';

  /// 닫힘(감시 재개).
  static const String closed = 'CLOSED';

  /// 부팅 때 재개 실패(P0 · 부팅당 1건).
  static const String resumeFailed = 'RESUME_FAILED';

  static const Set<String> values = <String>{
    opened,
    overdue,
    closed,
    resumeFailed,
  };
}

/// 🆕 v1.33(01 §42 · K274 · E16j-b) — X1 이전 화면의 🔒 슬롯 이름(도메인 `x1_slot` · 화면은 해석하지 않고 주입된 슬롯 빌더에 넘긴다).
/// 시크릿 자리 = `SECRET_` 접두(v1.20 K31 선례) · 값은 슬롯 ↔ 구현 사이만(동작 args 0).
abstract final class X1SlotIds {
  /// 옛 폰 — 이전 티켓 QR 표시(`X1TicketCard.ticketSlotId` · FLAG_SECURE = 슬롯 위젯).
  static const String ticketQrDisplay = 'X1_TICKET_QR_DISPLAY';

  /// 새 폰 받기 — 티켓 QR 스캔(`X1RecoveryVm.scanSlotId`).
  static const String ticketQrScan = 'X1_TICKET_QR_SCAN';

  /// 새 폰 비상 — 복구 코드 입력(`X1RecoveryVm.recoveryCodeSlotId` · 시크릿).
  static const String recoveryCode = 'SECRET_X1_RECOVERY_CODE';

  /// 새 폰 비상 — 재발급한 키 · 토큰 값 입력(`X1ReissueRow.reissueSlotId` · 시크릿 · 지문만 엔진).
  static const String reissueSecret = 'SECRET_X1_REISSUE';

  static const Set<String> values = <String>{
    ticketQrDisplay,
    ticketQrScan,
    recoveryCode,
    reissueSecret,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/onboarding_codes.dart`

```dart
// 01 §3 · 🆕 계약 v1.16(01 §25 · K21) — X3 온보딩·페어링 코드 사전 3축.
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다(labels.dart 머리) — 문구는 엔진이
//    함께 싣는다(`ActionResult.headline` · `PairingResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.

/// `ActionResult.reasonCode`·`PairingResult.reasonCode` 의 온보딩 앱 코드(도메인 `onboarding_result`).
abstract final class OnboardingResultCodes {
  /// `O-00b` 재선택 거부 — `onboarding_choice.committed_at` 뒤(`O-04` 완료 · 01 §8-23). 이후 변경 = 🔒 `M5-11`.
  static const String choiceCommitted = 'ONBOARDING_CHOICE_COMMITTED';

  /// `O-03` 검증 거절 — 다시 눌러도 같다(키를 다시 발급·입력해야 한다 · `retryable` false).
  static const String credentialRejected = 'CREDENTIAL_REJECTED';

  /// `O-04` ⑥ DRY_RUN 시작 실패 — `committed_at` 도 함께 되돌렸다(01 §8-23).
  static const String dryRunStartRolledBack = 'DRY_RUN_START_ROLLED_BACK';

  /// `V-01` 폐기된 연결 코드(M9 `S06` 이 폐기 · 즉시 차단 · 04 §9-7).
  static const String pairingTokenRevoked = 'PAIRING_TOKEN_REVOKED';

  static const Set<String> values = <String>{
    choiceCommitted,
    credentialRejected,
    dryRunStartRolledBack,
    pairingTokenRevoked,
  };
}

/// 브로커 원문 코드(도메인 `broker_raw`) — 엔진이 받은 그대로 `reasonCode` 에 싣는 외부 코드 중 **계약 표본이 쓰는 것**.
/// 🔴 전수 목록이 아니다 — 실 응답 등재는 엔진 레인이 늘린다(SPEC 02 §5-1 에러표 · 13 §8 R33 D15 · 01 §8 미결 157).
abstract final class BrokerRawCodes {
  /// KIS — 접근토큰 발급 제한(1분 1회 · 잠시 뒤 재시도 = `retryable` true).
  static const String kisTokenRateLimited = 'EGW00133';

  /// 🆕 v1.22(01 §31 · K66 · core `sim/sim_internal_broker.dart:23 · 26 · 29`) — 모의 가상 체결 브로커 거부
  /// (표본 `m6/journal_sim_broker_reject` 칩 · 축 = J-1 `ReasonChip.code`). 수량·주문 꼴이 맞지 않음.
  static const String simInvalidOrder = 'SIM_INVALID_ORDER';

  /// 🆕 v1.22 — 취소 거부 · 모르는 주문.
  static const String simOrderNotFound = 'SIM_ORDER_NOT_FOUND';

  /// 🆕 v1.22 — 취소 거부 · 이미 판정했거나 취소했다.
  static const String simCancelTooLate = 'SIM_CANCEL_TOO_LATE';

  static const Set<String> values = <String>{
    kisTokenRateLimited,
    simInvalidOrder,
    simOrderNotFound,
    simCancelTooLate,
  };
}

/// 온보딩 🔒 슬롯 이름(도메인 `onboarding_slot`) — VM 칸 `secretSlotId`·`slotId`·`loginSlotId`·`scannerSlotId` 의 값.
/// 🔴 `ui_shell` 은 이름을 해석하지 않는다 — 주입된 슬롯 빌더에 그대로 넘긴다. 이름 → 위젯 = 조립 앱(06 M4-11).
/// 🔴 더할 때 = 엔진(VM 산출)·조립 앱(빌더)이 같은 회차에 — 01 §8 미결 152.
abstract final class OnboardingSlotIds {
  /// `O-02` KIS 모의 앱키 — M4-4 `SecretField`.
  static const String secretKisMock = 'SECRET_KIS_MOCK';

  /// `O-04` ② 본인 서약문 3문장 — 🔒 M5-8(프리필 0 · 건너뛰기 0).
  static const String pledgeWrite = 'PLEDGE_WRITE';

  /// `O-04` ③ 생체 서명 — 🔒 M5.
  static const String biometricSign = 'BIOMETRIC_SIGN';

  /// `O-04` ④ 골든벡터 셀프테스트 실행 버튼 — 🔒 M9(`selftestGoldenRun` 은 위젯 안에서).
  static const String selftestRun = 'SELFTEST_RUN';

  /// `O-04` ⑤ 복구 카드 체크섬 입력 — 🔒 M9 입력 위젯(06 M4-10 · 결정 ②).
  static const String recoveryChecksum = 'RECOVERY_CHECKSUM';

  /// `R-01` ① 복구 카드 로그인 — 플랫폼(06 M4-11) · 🆕 v1.29(01 §39 · E11k T8) 방식 = 이메일 + 비밀번호(새로고침 토큰만 금고 ·
  /// 공개 가입 끔 = o_07 ④) — ~~매직링크/OTP~~ 정정.
  static const String recoveryLogin = 'RECOVERY_LOGIN';

  /// `V-01` QR 스캔·토큰 클레임 — 플랫폼(06 M4-11 · 01 §8 미결 13).
  static const String viewerQrScan = 'VIEWER_QR_SCAN';

  /// 🆕 v1.29(01 §39 · E11k-b) — `o_07` ② Supabase 연결 값 붙여넣기(프로젝트 주소 + 공개 키 두 칸) — 🔒 조립 앱 슬롯(06 M4-11 ·
  /// `secretSlotId` 자리 = `SECRET_` 접두 · C-50 ⑮).
  /// 🔴 값 = 슬롯 ↔ `connectionTest{target: SUPABASE}` 구현 사이만(VM · args · 결과 · 로그 0) · 비밀 키 · service_role = 거부
  ///    (`SupabaseInputResultCodes`) · 통과 = 서버 시각 1회 확인 뒤 금고(`supabase.project_url` · `supabase.publishable_key`).
  static const String supabaseConnect = 'SECRET_SUPABASE_CONNECT';

  /// 🆕 v1.31(01 §40 · K238 · E11k-d2) — `o_07` ③ Supabase 로그인(이메일 + 비밀번호 두 칸 · 붙여넣기만) — 🔒 조립 앱 슬롯(06 M4-11).
  /// 🔴 같은 `o_07` 단계에서 ② 통과(`IN_PROGRESS`) 뒤 엔진 상세 VM 이 [supabaseConnect] 대신 내준다(한 화면에 슬롯 하나) ·
  ///    비밀번호 = 슬롯 ↔ `supabaseSignIn` 구현 사이만(필드 · 금고 · 결과 · 로그 0) · 새로고침 토큰만 금고.
  static const String supabaseLogin = 'SECRET_SUPABASE_LOGIN';

  static const Set<String> values = <String>{
    secretKisMock,
    pledgeWrite,
    biometricSign,
    selftestRun,
    recoveryChecksum,
    recoveryLogin,
    viewerQrScan,
    supabaseConnect,
    supabaseLogin,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/ops_codes.dart`

```dart
// 01 §3 · 🆕 계약 v1.17(01 §26 · K19) — M8 운영 화면의 🔒/플랫폼 슬롯 이름.
//
// 🔴 «어떤 슬롯 이름이 오는가» 의 상수 목록이다 — 화면은 이름을 슬롯 빌더(`shellOpsSlotBuilderProvider`)에 그대로 넘기고
//    이름으로 분기·위젯을 고르지 않는다. 이름 → 위젯 = 조립 앱(06 M4-12 · v1.16 `OnboardingSlotIds` 꼴).

/// M8 운영 슬롯 이름.
abstract final class OpsSlotIds {
  /// `D-03` 긴급정지 카드 인쇄·PDF 저장 — 플랫폼(조립 앱 · 04 §2-1 금지 5 의 유일한 예외).
  static const String emergencyCardPrint = 'EMERGENCY_CARD_PRINT';

  /// 🆕 v1.25(01 §34 · K152) — 셸 킬스위치 자리(폰 앱바 · 웹 사이드바 `s02-kill-slot`) · 위젯 = `ui_safety` 발동 버튼(조립 앱 슬롯 빌더) ·
  /// 🔴 셸 = 자리만(확인 대화·핸들러 감싸기 0 — 04 §3-2) · 빌더 null = 자리 부재 · 잠금 오버레이가 덮지 않는다(05 §1).
  static const String killSwitch = 'KILL_SWITCH';

  static const Set<String> values = <String>{emergencyCardPrint, killSwitch};
}
```

---

## `packages/domain_contracts/lib/src/labels/origin_codes.dart`

```dart
// 01 §3-4 — X5 대사·정합 원인 코드 20종 (🔴 자유 서술 거부).
//
// 소비처: `trading_block.origin_code`(RECON_MISMATCH 전용) · `ledger_diff.origin_code` ·
//        `ledger_repair.origin_code` · `LedgerDiffRow.candidateOriginCodes` · `BlockFlag.originCode`.
// 🔴 `reasonCode` 는 자유 서술을 거부한다 — `note` 는 그 위의 한 줄이지 사유 코드의 대체가 아니다.

/// X5 대사·정합 원인 코드(01 §3-4).
abstract final class OriginCodes {
  // ── 브로커 계열 7 (04 §3-5 기존 4 + X2·X5 확장) ────────────────────────────
  /// 체결 보고 지연.
  static const String fillLag = 'FILL_LAG';

  /// 수동 주문. ⚠️ 이 코드로 해제하면 **저널과 SEV2 postmortem(7일)이 동시에 열린다**(04 §3-5) —
  /// 화면은 이 분기를 만들지 말고 정정 마법사(M5)로 넘긴다.
  static const String manualOrder = 'MANUAL_ORDER';

  /// 로컬 DB 오류.
  static const String dbError = 'DB_ERROR';

  /// 브로커 API 오류.
  static const String brokerError = 'BROKER_ERROR';

  /// 시스템 밖 입출금.
  static const String externalCashflow = 'EXTERNAL_CASHFLOW';

  /// 기업행위. 🔴 X2 계열이 먼저 등재된 이름이며 **픽스처·신규 코드는 이 이름만 쓴다**.
  static const String corporateAction = 'CORPORATE_ACTION';

  /// 기업행위(X5 계열의 옛 표기). ✅ **`corporateAction` 으로 통합됐다**(계약 v1.9.0 · 01 §8-6 ·
  /// 인벤토리 §10-2 ③ 해소) — 옛 기록을 읽기 위한 **상수로만** 남고 픽스처·신규 코드에 쓰지 않는다.
  static const String corpActionLegacy = 'CORP_ACTION';

  // ── 파생 계열 7 (X5 신설) ─────────────────────────────────────────────────
  /// Supabase push 지연.
  static const String pushLag = 'PUSH_LAG';

  /// Supabase push 실패.
  static const String pushFailed = 'PUSH_FAILED';

  /// GitHub 아카이브 적체.
  static const String archiveLag = 'ARCHIVE_LAG';

  /// 캘린더 쓰기 실패.
  static const String calWriteFailed = 'CAL_WRITE_FAILED';

  /// 스키마 어긋남.
  static const String schemaSkew = 'SCHEMA_SKEW';

  /// 해시 체인 단절.
  /// 🔴 v1.24 — 같은 글자 다른 축 = `LedgerIntegrityResultCodes.chainBroken`(무결성 결과 · C-5 문서 쌍).
  static const String chainBroken = 'CHAIN_BROKEN';

  /// 복원 롤백.
  /// 🔴 v1.24 — 같은 글자 다른 축 = `BackupResultCodes.rollback`(백업 거부 · C-5 문서 쌍).
  static const String restoreRollback = 'RESTORE_ROLLBACK';

  // ── X7 계열 6 (01 §10) ────────────────────────────────────────────────────
  /// 🔴 안내 모드의 **정상** 수기 체결. 이 코드가 없으면 advisory 의 모든 체결이
  /// `MANUAL_ORDER` 로 들어가 「저널 + SEV2 postmortem 7일」을 매일 연다(경보 피로 규칙 정면 위반).
  static const String advisoryFill = 'ADVISORY_FILL';

  /// 체결이 있었는데 기록되지 않음.
  static const String unrecordedFill = 'UNRECORDED_FILL';

  /// 잘못 기록된 체결. 🔴 소급 정정이 `ledger_repair(direction='DERIVED_RESYNC')` 1행을
  /// 낳는 원인 코드다(C-29).
  static const String misrecordedFill = 'MISRECORDED_FILL';

  /// 원장 실사(자가보고)에서 나온 정정.
  static const String selfReportCorrection = 'SELF_REPORT_CORRECTION';

  /// 시스템 밖 자산.
  static const String externalHolding = 'EXTERNAL_HOLDING';

  /// 🔴 D11 — 대사 키가 있으면 계좌별 잔고 대조로 교차검증하고, 불일치는
  /// `SELF_REPORT_CORRECTION` 이 아니라 **이 코드**로 `ledger_diff` 를 연다.
  static const String accountMisdeclared = 'ACCOUNT_MISDECLARED';

  /// 브로커 계열 7종.
  static const Set<String> broker = <String>{
    fillLag,
    manualOrder,
    dbError,
    brokerError,
    externalCashflow,
    corporateAction,
    corpActionLegacy,
  };

  /// 파생 계열 7종.
  static const Set<String> derived = <String>{
    pushLag,
    pushFailed,
    archiveLag,
    calWriteFailed,
    schemaSkew,
    chainBroken,
    restoreRollback,
  };

  /// X7 계열 6종.
  static const Set<String> x7 = <String>{
    advisoryFill,
    unrecordedFill,
    misrecordedFill,
    selfReportCorrection,
    externalHolding,
    accountMisdeclared,
  };

  /// 전량 20종.
  static const Set<String> values = <String>{...broker, ...derived, ...x7};

  /// 픽스처·신규 코드가 쓸 수 있는 것 — 옛 표기 `CORP_ACTION` 을 뺀 19종.
  ///
  /// ✅ 인벤토리 §10-2 ③ 해소(계약 v1.9.0) — 쓰는 이름은 `CORPORATE_ACTION` 하나다.
  static const Set<String> writable = <String>{
    fillLag,
    manualOrder,
    dbError,
    brokerError,
    externalCashflow,
    corporateAction,
    ...derived,
    ...x7,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/plan_codes.dart`

```dart
// 🆕 계약 v1.4(2026-09-30 · R11 선행 M2 보강 · 01 §14) — 플래너(S7-4) 사유 칩 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    칩의 글자는 `ReasonChip.label`(엔진 문장)이고, 화면은 이 상수를 보고 문구를 고르지 않는다.
// 🔵 까닭: 입금 계획 픽스처(`deposit_plan_*`·`m7_deposit_plan_*`)와 `journal_30`·`advice_12` 가
//    `DEPOSIT_ROUTING` 을 쓰는데 사전에 없었다(미등록 코드 조기 실패의 빈틈 · 설계 D9 ⑦).
// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D4 · 01 §8 미결 74 ✅) — `DEPOSIT_REGISTER` 거부 코드 사전([DepositRegisterRejectCodes]).

/// 플래너 주문 초안의 사유 칩 코드(`OrderDraft.reasons[].code` · 01 §2-6).
///
/// ⚠️ 플래너 초안 칩에는 `PENSION_FUNDING`(원장 이벤트 사전 · `ledger_event_codes.dart`)도 온다
///    (`m7_deposit_plan_funding` 매도 초안 · C-38 ⑧ 은 그래서 전 도메인 isRegistered 로 본다).
///    이 사전은 플래너 **전용** 코드만 싣는다.
///
/// 🔴 목록은 M2 가 늘린다.
abstract final class PlannerReasonCodes {
  /// 월 납입 배분(입금액을 슬리브·계좌로 나눈 결과의 초안).
  static const String depositRouting = 'DEPOSIT_ROUTING';

  /// 플래너 전용 코드 전량 1종(`PENSION_FUNDING` 은 원장 이벤트 사전 몫).
  static const Set<String> values = <String>{depositRouting};
}

/// 🆕 E7a3-2(2026-10-21 · 설계 13 §8 R18 D-11 · 계약 버전 불변 — 코드 사전 추가만) — 리밸런싱 미리보기
/// 초안의 사유 칩 코드(`RebalancePreview.orderDrafts[].reasons[].code` · 01 §15-4).
///
/// 🔵 까닭: 픽스처 `m7_rebalance_preview_default` 가 `REBALANCE_BAND` 를 쓰는데 사전에 없었다 · 엔진 월말 계획기
///    (`core_engine` `planMonthEnd`)의 매매 갈래마다 하나씩 둔다. 원화 조달 매도는 `PENSION_FUNDING`(원장 이벤트 사전).
/// 🔴 목록은 M2 가 늘린다.
abstract final class RebalanceReasonCodes {
  /// 코어 밴드 — B 지분 목표 ± band 이탈(재원 매도 포함).
  static const String rebalanceBand = 'REBALANCE_BAND';

  /// 슬리브 B 3-트랜치 신호(하한 · BEAR 차감 포함).
  static const String sleeveBSignal = 'SLEEVE_B_SIGNAL';

  /// 슬리브 C 채권 · 금 비중 조정.
  static const String sleeveCRebalance = 'SLEEVE_C_REBALANCE';

  /// POT 서브북 3-트랜치 신호.
  static const String potSignal = 'POT_SIGNAL';

  /// 전량 4종.
  static const Set<String> values = <String>{
    rebalanceBand,
    sleeveBSignal,
    sleeveCRebalance,
    potSignal,
  };
}

/// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D4·D13 · 01 §20) — 실입금 등록(`CommandKind.depositRegister`)의 거부 사유.
/// `CommandReceipt.rejectReasonCode` 의 값(`state == rejected` 일 때) · `ContractCodes.byDomain` 키 `deposit_register_reject`.
///
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다 — 화면은 이 코드를 표시·분기하지 않는다(01 §14-7).
/// 🔴 거부는 **계획 바인딩의 거부**이지 입금 사실의 거부가 아니다 — 돈은 계좌에 남고, 새 계획(planId)으로 다시 등록한다.
/// 🔴 원장 무결성 점검 중(`LEDGER_INTEGRITY` 플래그)이면 거부가 아니라 **보류**다(`CommandState.heldForIntegrity` · 사유 코드 없음).
/// 🔴 판정 순서 = [precedence](구조 → 보류 → 대조·정정·만료 → 한도) — `DepositPlan.registerBlockedText` 와 같은 순서라
///    화면 문장과 거부 코드가 엇갈리지 않는다. 만료는 명령의 서버 `requested_at` 으로 잰다(R22 D9).
abstract final class DepositRegisterRejectCodes {
  /// 그런 계획이 없다(저장된 적 없는 planId · 다른 파일(모의/실계좌)의 planId).
  static const String planNotFound = 'DEPOSIT_PLAN_NOT_FOUND';

  /// 이 계획은 이미 등록됐다 — 계획 하나에 등록 하나(`plan_snapshot.consumed_by_decision_id`).
  static const String planAlreadyRegistered = 'DEPOSIT_PLAN_ALREADY_REGISTERED';

  /// 브로커 잔고 대조가 끝나지 않았다(`RECON_MISMATCH` 플래그).
  static const String reconPending = 'DEPOSIT_RECON_PENDING';

  /// 원장 정정이 끝나지 않았다(`LEDGER_FIX` 플래그).
  static const String ledgerFixPending = 'DEPOSIT_LEDGER_FIX_PENDING';

  /// 계획이 만료됐다(명령 `requested_at` ≥ `expiresAt`).
  static const String planExpired = 'DEPOSIT_PLAN_EXPIRED';

  /// 지금 남은 연금 납입 한도 < 계획의 B 몫(해 넘김 포함 · R22 D13) — 세금 사고를 막는다.
  static const String pensionQuotaChanged = 'DEPOSIT_PENSION_QUOTA_CHANGED';

  /// 판정 순서(앞이 먼저 · 보류 `heldForIntegrity` 는 «이미 등록» 다음 · «대조» 앞에 끼인다).
  static const List<String> precedence = <String>[
    planNotFound,
    planAlreadyRegistered,
    reconPending,
    ledgerFixPending,
    planExpired,
    pensionQuotaChanged,
  ];

  /// 전량 6종.
  static const Set<String> values = <String>{
    planNotFound,
    planAlreadyRegistered,
    reconPending,
    ledgerFixPending,
    planExpired,
    pensionQuotaChanged,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/repair_codes.dart`

```dart
// 🆕 계약 v1.30(01 §38 · E16i 계약 창) — X5 정합 복구 · 새 기준점 · X1/X5 경계 · 파생 관계의 **엔진 글자 사전**.
//
// 🔴 타입 이름 ≠ 엔진(core `RepairCodes` · `BaselineCodes` · `BoundaryReason` · `DerivedRelation` — `ambiguous_import` 회피 K80).
// 🔴 화면은 이 글자로 분기 · 색 · 문구를 고르지 않는다 — 정정 마법사 VM · 경계 안내 = 다음 판(01 §8 미결 211).
// 🔴 같은 글자 다른 축(C-5 문서 쌍): [LedgerBoundaryReasonCodes.sqliteIntegrity] · [LedgerBoundaryReasonCodes.formatVersion] =
//    `LedgerIntegrityResultCodes` · [LedgerBoundaryReasonCodes.restoreRollback] = `OriginCodes.restoreRollback` ·
//    `BackupResultCodes.rollback`(v1.24 K140 예고 실현).

/// X5 정정 거부(도메인 `repair_result` · 엔진 core `repair/repair_plan.dart:49-79` 10).
abstract final class RepairResultCodes {
  /// 탐지 때 차이(diff)가 재대사에 없다(delta 가 바뀌었다).
  static const String deltaChanged = 'REPAIR_DELTA_CHANGED';

  /// 불변 스트림이 아닌 표.
  static const String targetNotImmutable = 'REPAIR_TARGET_NOT_IMMUTABLE';

  /// 이 방향 · 쌍에 쓸 수 없는 원인 코드.
  static const String originNotAllowed = 'REPAIR_ORIGIN_NOT_ALLOWED';

  /// 정본 정정인데 결정이 없다.
  static const String decisionRequired = 'REPAIR_DECISION_REQUIRED';

  /// 바뀌는 게 없다.
  static const String noChange = 'REPAIR_NO_CHANGE';

  /// 고를 차이가 OPEN `CANON_BROKER` 가 아니다.
  static const String diffNotOpen = 'REPAIR_DIFF_NOT_OPEN';

  /// 브로커 체결이 아니거나 없다.
  static const String fillNotBroker = 'REPAIR_FILL_NOT_BROKER';

  /// 주문이 아직 열려 있다(체결 동기가 누적을 다시 센다).
  static const String orderOpen = 'REPAIR_ORDER_OPEN';

  /// 정정 전 재생이 저장 포지션과 다르다.
  static const String positionDrift = 'REPAIR_POSITION_DRIFT';

  /// 정정 뒤 포지션이 중간에 음수가 된다.
  static const String positionNegative = 'REPAIR_POSITION_NEGATIVE';

  static const Set<String> values = <String>{
    deltaChanged,
    targetNotImmutable,
    originNotAllowed,
    decisionRequired,
    noChange,
    diffNotOpen,
    fillNotBroker,
    orderOpen,
    positionDrift,
    positionNegative,
  };
}

/// X5 새 기준점 거부(도메인 `baseline_result` · 엔진 core `repair/baseline_plan.dart:23-29` 2).
abstract final class BaselineResultCodes {
  /// 경계가 X5 가 아니다(X1 비상 경로 · 또는 깨끗함).
  static const String notX5 = 'BASELINE_NOT_X5';

  /// 첫 어긋난 날을 모른다.
  static const String firstBadDateUnknown = 'BASELINE_FIRST_BAD_DATE_UNKNOWN';

  static const Set<String> values = <String>{notX5, firstBadDateUnknown};
}

/// 🆕 v1.32(01 §41 · K257 · E16j-a) — 새 기준점 저장 쪽 거부(도메인 `baseline_apply_result` · data_sync `local/ledger_repair_store.dart:33-40`
/// `BaselineStoreCodes` 2 − 공용 `TRUSTED_TIME_UNKNOWN` · 🔴 타입 이름 ≠ 엔진). 정정 중 겹침(`LedgerFixBusy`)은 코드 0 — 구현이 «잠시 뒤 다시» 결과.
abstract final class BaselineApplyResultCodes {
  /// `LEDGER_INTEGRITY` 가 서 있지 않다.
  static const String flagNotSet = 'BASELINE_FLAG_NOT_SET';

  static const Set<String> values = <String>{flagNotSet};
}

/// 🆕 v1.35(01 §44 · K291 · 미결 217 ①) — X5 정정 원문 4칸(수량 · 가격 · 수수료 · 세금) 파싱 거부(도메인 `repair_input_result` ·
/// 엔진 core `repair/repair_wizard.dart` `RepairInputCodes` 1:1 · 🔴 타입 이름 ≠ 엔진 K80).
/// 🔴 [RepairResultCodes](엔진 `repair_plan` 판정 10 의 거울)에 넣지 않는다 — 축이 다르다(계획 판정 ↔ 원문 파싱 · 대조 한 벌씩).
/// 결과 `SafetyActionResult.reasonCode`(id = `REPAIR_CORRECT`)로만 나간다 · 화면은 분기 · 표시 0(`headline` 만).
abstract final class RepairInputResultCodes {
  /// 원문을 읽을 수 없다(빈칸 · 숫자 아님 · 범위 밖).
  static const String amountInvalid = 'REPAIR_AMOUNT_INVALID';

  static const Set<String> values = <String>{amountInvalid};
}

/// X1/X5 경계 사유(도메인 `ledger_boundary_reason` · 엔진 core `ops/ledger_boundary.dart:17-41` `BoundaryReason.wire` 8 ·
/// 나쁜 쪽이 이긴다 — 파일 → PRAGMA → 스탬프 사슬 → 아카이브 → 내용 → 형식 판 → 깨끗).
/// 🔴 X1 길 다섯([dbOpenFailed] · [sqliteIntegrity] · [stampChainBroken] · [restoreRollback] · [archiveDiverged])은 기동 거부 글자로도
///    나간다(data_sync `migration/x1_startup.dart:39-41` → FGS 머리말) · X5 길 = [contentMismatch] · [formatVersion] · 할 일 없음 = [clean].
abstract final class LedgerBoundaryReasonCodes {
  /// 원장 파일이 열리지 않았다.
  static const String dbOpenFailed = 'DB_OPEN_FAILED';

  /// `PRAGMA integrity_check` 가 ok 가 아니다.
  static const String sqliteIntegrity = 'SQLITE_INTEGRITY';

  /// 스탬프 사슬이 끊겼다.
  static const String stampChainBroken = 'STAMP_CHAIN_BROKEN';

  /// 정본이 아카이브보다 과거(아카이브 AHEAD).
  static const String restoreRollback = 'RESTORE_ROLLBACK';

  /// 아카이브와 갈라졌다.
  static const String archiveDiverged = 'ARCHIVE_DIVERGED';

  /// 지난 기록이 스탬프와 다르다.
  static const String contentMismatch = 'CONTENT_MISMATCH';

  /// 스탬프 형식 판이 다르다.
  static const String formatVersion = 'FORMAT_VERSION';

  /// 깨끗하다.
  static const String clean = 'CLEAN';

  static const Set<String> values = <String>{
    dbOpenFailed,
    sqliteIntegrity,
    stampChainBroken,
    restoreRollback,
    archiveDiverged,
    contentMismatch,
    formatVersion,
    clean,
  };
}

/// 파생(아카이브 · 뷰어) 관계(도메인 `derived_relation` · 엔진 core `ops/derived_sync.dart:210-231` `DerivedRelation.wire` 7 ·
/// FORK 알림 = `AlertCodes.derivedFork`).
abstract final class DerivedRelationCodes {
  /// 같다.
  static const String inSync = 'IN_SYNC';

  /// 파생이 비었다.
  static const String empty = 'EMPTY';

  /// 파생이 뒤처졌다(같은 사슬).
  static const String behind = 'BEHIND';

  /// 새 기준점 전 기록(재생성).
  static const String rebased = 'REBASED';

  /// 파생이 정본보다 앞섰다(FORK · RESTORE_ROLLBACK).
  static const String ahead = 'AHEAD';

  /// 갈라졌다(FORK).
  static const String diverged = 'DIVERGED';

  /// 더 새 기기의 기록(FORK).
  static const String epochAhead = 'EPOCH_AHEAD';

  static const Set<String> values = <String>{
    inSync,
    empty,
    behind,
    rebased,
    ahead,
    diverged,
    epochAhead,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/saf_codes.dart`

```dart
// 01 §3-2 — SAF 코드 접두 대역 + `SAF309_` 상세 6종.
//
// 🔴 개별 SAF 코드(37종)의 정본은 엔진 `06_시스템설계/04_안전장치.md` 다. 여기 두는 것은
//    ① 화면·픽스처가 만나는 **접두 대역**과 ② 주문 게이트 진리표가 내는 **SAF309_ 상세 6종**이다.
// 🔴 화면은 배지로만 쓴다 — 진리표는 주문 게이트의 사양 벡터이지 표시 분기가 아니다(01 §3-2 말미).
// 🔴 `ui_*` 소스에 `'SAF-'` 리터럴이 있으면 C-5 가 실패시킨다. 이 파일은 `domain_contracts` 이므로
//    C-5 의 대상이 아니지만, **여기서 문구를 만들지 않는다**는 규약은 같다.

/// SAF 코드의 접두 대역(01 §3-2).
abstract final class SafBandCodes {
  /// 포지션 리스크 한도.
  static const String band1xx = 'SAF-1xx';

  /// 슬리브 한도·종목 필터.
  static const String band2xx = 'SAF-2xx';

  /// 포트폴리오·세금 게이트.
  static const String band3xx = 'SAF-3xx';

  /// 시스템·주문 게이트.
  static const String band4xx = 'SAF-4xx';

  /// 드로다운 서킷브레이커. 🔵 v2.31 P0S 에서 대상 없음.
  static const String band5xx = 'SAF-5xx';

  /// 타임존·스케줄.
  static const String band7xx = 'SAF-7xx';

  /// 장애 대응. 🔴 §3-2 표는 8xx·9xx 를 **한 행**(장애·보안)으로 묶어 «7대역»이라 부른다 —
  ///    접두 **문자열**은 둘이므로 이 집합의 원소는 8개다(대역 수 7 ≠ 접두 문자열 수 8).
  static const String band8xx = 'SAF-8xx';

  /// 보안. §3-2 표에서 `SAF-8xx` 와 한 행이다.
  static const String band9xx = 'SAF-9xx';

  /// 전량 — 접두 문자열 8개(대역은 7행).
  static const Set<String> values = <String>{
    band1xx,
    band2xx,
    band3xx,
    band4xx,
    band5xx,
    band7xx,
    band8xx,
    band9xx,
  };
}

/// SAF-309(POT 주문 계좌 절세 게이트) 상세 사유 코드 6종.
///
/// 진리표 원본 = `09_백테스트/백테스트6/runs/H2_saf/saf309_vector.json` (05 GV-SAF-309).
/// 🔴 `SAF309_` 접두가 **코드 문자열의 일부**다(진리표의 `reason_codes` 키와 문자 그대로 일치).
/// 🔴 갈래는 계좌 배치가 정한다 — 화면·인자로 고르는 경로를 만들지 않는다.
abstract final class Saf309Codes {
  /// 등록 절세계좌 확인 — 주문 허용.
  static const String okTaxAdvantaged = 'SAF309_OK_TAX_ADVANTAGED';

  /// 일반계좌 — 실주문 거부.
  static const String denyTaxableAccount = 'SAF309_DENY_TAXABLE_ACCOUNT';

  /// 계좌 유형 확인 불가 — fail-closed 거부.
  static const String denyUnverifiedFailClosed =
      'SAF309_DENY_UNVERIFIED_FAIL_CLOSED';

  /// DRY_RUN·백테스트 — 일반계좌 경고.
  static const String warnTaxableAccount = 'SAF309_WARN_TAXABLE_ACCOUNT';

  /// DRY_RUN·백테스트 — 확인 불가 경고.
  static const String warnUnverified = 'SAF309_WARN_UNVERIFIED';

  /// 조회는 주문이 아님 — 게이트 대상 아님.
  static const String naQueryNotAnOrder = 'SAF309_NA_QUERY_NOT_AN_ORDER';

  /// 전량 6종.
  ///
  /// ⚠️ `contracts_inventory.md` §3-1 의 `ReasonChip.code` 예시 `'SAF309_ACCOUNT_UNVERIFIED'` 는
  ///    이 6종에 **없다**. 예시가 진리표와 어긋난 것이므로 임의로 추가하지 않는다(멈추고 보고).
  static const Set<String> values = <String>{
    okTaxAdvantaged,
    denyTaxableAccount,
    denyUnverifiedFailClosed,
    warnTaxableAccount,
    warnUnverified,
    naQueryNotAnOrder,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/safety_codes.dart`

```dart
// 🆕 계약 v1.21(01 §30 · K12 · K13 · K45) — M5 안전 동작 결과 코드 · 게이지 코드. 엔진 글자 1:1(core·ds 실물 · 01 §30-8).
//
// 🔴 «어떤 코드가 오는가» 의 목록이지 코드 → 문구 사전이 아니다(labels.dart 머리) — 화면은 `headline`·`stateLabel`
//    원문을 그린다. 코드로 분기·아이콘·색을 고르지 않는다.
// 🔴 공용 두 글자(`TRUSTED_TIME_UNKNOWN` · `JOURNAL_ID_TAKEN`)는 [SafetyCommonResultCodes] 한 벌이다 — 도메인 사전
//    (킬스위치 · 서약 · 1.22.0 개입 · 규칙 변경 · 재량 · STOPPED)에 다시 적지 않는다(C-5 «같은 글자 두 사전 0»).

/// 킬스위치 발동 기록·재개 거부(도메인 `kill_switch_result` · 엔진 core `kill_checklist.dart` 리터럴 12 — 상수 클래스 0 →
/// 엔진이 이 사전을 참조로 바꾼다). 축 = `SafetyActionResult.reasonCode`(재개) · `CommandReceipt.rejectReasonCode`(발동 기록).
abstract final class KillSwitchResultCodes {
  /// 확인 3 중 빈 것(발동 기록).
  static const String ackIncomplete = 'KILL_ACK_INCOMPLETE';

  /// «잔여 0» 인데 엔진이 본 미체결 > 0 — 🔴 P0 를 다시 올린다(발동 기록).
  static const String ackMismatch = 'KILL_ACK_MISMATCH';

  /// 카드 ④ 7 중 빈 것(1 · 2 감정 · 3 · 4 · 7 · 발동 기록 · `activation` null 포함).
  static const String checklistItemMissing = 'KILL_CHECKLIST_ITEM_MISSING';

  /// 꺼져 있다(발동 기록 · 재개).
  static const String notActive = 'KILL_SWITCH_NOT_ACTIVE';

  /// 7문항을 이미 마쳤다.
  static const String resumeChecklistDone = 'RESUME_CHECKLIST_DONE';

  /// 7문항 미완(해제 시도).
  static const String resumeChecklistIncomplete = 'RESUME_CHECKLIST_INCOMPLETE';

  /// 발동 뒤 기록 확인 전(카운트다운 없음).
  static const String resumeChecklistNotConfirmed =
      'RESUME_CHECKLIST_NOT_CONFIRMED';

  /// 4번 미충족 — 재개하지 않는다.
  static const String resumeConditionUnmet = 'RESUME_CONDITION_UNMET';

  /// 그 번호 칸이 비었다(범위 밖·파싱 실패 포함).
  static const String resumeItemMissing = 'RESUME_ITEM_MISSING';

  /// 차례가 아니다(앞 항목 통과 전 · 일괄 0).
  static const String resumeItemOutOfOrder = 'RESUME_ITEM_OUT_OF_ORDER';

  /// 48h 미경과.
  static const String resumeTooSoon = 'RESUME_TOO_SOON';

  /// 신뢰 시각 모름(재개). 🔴 공용 `TRUSTED_TIME_UNKNOWN` 과 글자가 다르다 — 엔진 이력(명령 행 저장 값 · 바꾸지 않는다).
  static const String resumeTrustedTimeUnknown = 'RESUME_TRUSTED_TIME_UNKNOWN';

  static const Set<String> values = <String>{
    ackIncomplete,
    ackMismatch,
    checklistItemMissing,
    notActive,
    resumeChecklistDone,
    resumeChecklistIncomplete,
    resumeChecklistNotConfirmed,
    resumeConditionUnmet,
    resumeItemMissing,
    resumeItemOutOfOrder,
    resumeTooSoon,
    resumeTrustedTimeUnknown,
  };
}

/// M5 공용 거부(도메인 `safety_common_result` · 엔진 core `discretion`·`intervention`·`pledge`·`rule_change`·
/// `ops/contribution_setting` 다섯 사전 + ds 킬스위치·STOPPED 저장이 같은 글자를 품는다 → 한 벌 · K12 · K45).
abstract final class SafetyCommonResultCodes {
  /// 신뢰 시각 모름(발동 기록 확인 · 서약 · 1.22.0 개입·규칙 변경·재량 · 🆕 1.23.0 월 납입 `runContributionUpdate` — `ContributionResultCodes` 의 짝 · K45).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';

  /// 저널 id 가 이미 있다(발동 기록 · 재개 · 1.22.0 STOPPED).
  static const String journalIdTaken = 'JOURNAL_ID_TAKEN';

  static const Set<String> values = <String>{
    trustedTimeUnknown,
    journalIdTaken,
  };
}

/// 서약 거부(도메인 `pledge_result` · 엔진 core `pledge.dart:18` `PledgeCodes` 7 − 공용 1).
abstract final class PledgeResultCodes {
  /// 이미 첫 판이 있다(원문은 한 번만).
  static const String alreadyWritten = 'PLEDGE_ALREADY_WRITTEN';

  /// 편집 저널 미연결.
  static const String journalMissing = 'PLEDGE_JOURNAL_MISSING';

  /// 첫 판이 없다(편집할 것이 없다).
  static const String notWritten = 'PLEDGE_NOT_WRITTEN';

  /// 12월 창 밖.
  static const String outOfWindow = 'PLEDGE_OUT_OF_WINDOW';

  /// 문장 빈칸 · 셋이 아님.
  static const String sentencesMissing = 'PLEDGE_SENTENCES_MISSING';

  /// 지금 판과 같다.
  static const String unchanged = 'PLEDGE_UNCHANGED';

  static const Set<String> values = <String>{
    alreadyWritten,
    journalMissing,
    notWritten,
    outOfWindow,
    sentencesMissing,
    unchanged,
  };
}

/// 해제 진행 게이지 코드(도메인 `gauge` · 엔진 core `safety_text.dart:192` · `GaugeProgress.code` 의 값 · 검사 = C-55 ⑭).
/// 🔴 화면은 코드로 글자·색을 고르지 않는다 — `label`·`valueText`·`normalized`(폭) 를 그린다.
abstract final class GaugeCodes {
  /// 드로다운 회복.
  static const String ddRecovery = 'DD_RECOVERY';

  /// 유지 기간.
  static const String hold = 'HOLD';

  /// BULL 연속.
  static const String bullStreak = 'BULL_STREAK';

  /// 킬스위치 48h 냉각.
  static const String cooldown = 'COOLDOWN';

  static const Set<String> values = <String>{
    ddRecovery,
    hold,
    bullStreak,
    cooldown,
  };
}

// 🆕 v1.22(01 §31 · K12) — E13 나머지 거부 사전 5(엔진 글자 1:1 · 공용 `TRUSTED_TIME_UNKNOWN` 은 뺀다 — 한 벌).

/// 🆕 v1.22 — STOPPED 결정 거부(도메인 `stopped_decision_result` · core `safety/stopped_decision.dart:28` 7).
abstract final class StoppedDecisionResultCodes {
  /// 지금 STOPPED 가 아니다.
  static const String notActive = 'STOPPED_NOT_ACTIVE';

  /// 기다릴 거래일이 아직이다(일수 = 엔진 설정).
  static const String wait20d = 'STOPPED_WAIT_20D';

  /// 이 에피소드에 결정이 이미 있다.
  static const String alreadyMade = 'DECISION_ALREADY_MADE';

  /// SEV1 postmortem 이 비었다.
  static const String postmortemMissing = 'POSTMORTEM_MISSING';

  /// 가족 합의 선언이 없다.
  static const String familyAgreementMissing = 'FAMILY_AGREEMENT_MISSING';

  /// 사전 필드 3 이 비었다.
  static const String journalRequired = 'JOURNAL_REQUIRED';

  /// B 인데 재개 자격이 없다.
  static const String notEligible = 'STOPPED_NOT_ELIGIBLE';

  static const Set<String> values = <String>{
    notActive,
    wait20d,
    alreadyMade,
    postmortemMissing,
    familyAgreementMissing,
    journalRequired,
    notEligible,
  };
}

/// 🆕 v1.22 — postmortem 거부(도메인 `postmortem_result` · core `safety/incident.dart:61` 3).
abstract final class PostmortemResultCodes {
  /// 건이 없다.
  static const String notFound = 'INCIDENT_NOT_FOUND';

  /// 글이 비었다.
  static const String blank = 'POSTMORTEM_BLANK';

  /// 이미 썼다.
  static const String alreadyRecorded = 'POSTMORTEM_ALREADY_RECORDED';

  static const Set<String> values = <String>{notFound, blank, alreadyRecorded};
}

/// 🆕 v1.22 — 개입 거부(도메인 `intervention_result` · core `safety/intervention.dart:47` 7 − 공용 1).
abstract final class InterventionResultCodes {
  /// 이미 닫힌 세션.
  static const String closed = 'INTERVENTION_CLOSED';

  /// 냉각 중.
  static const String cooling = 'INTERVENTION_COOLING';

  /// 실행 창이 지났다.
  static const String expired = 'INTERVENTION_EXPIRED';

  /// 저널 미연결.
  static const String journalMissing = 'INTERVENTION_JOURNAL_MISSING';

  /// 차례가 아닌 단계(건너뛰기 · 되풀이).
  static const String outOfOrder = 'INTERVENTION_STAGE_OUT_OF_ORDER';

  /// 다른 세션이 살아 있다.
  static const String sessionOpen = 'INTERVENTION_SESSION_OPEN';

  static const Set<String> values = <String>{
    closed,
    cooling,
    expired,
    journalMissing,
    outOfOrder,
    sessionOpen,
  };
}

/// 🆕 v1.22 — 규칙 변경 취소·승인 거부(도메인 `rule_change_result` · core `safety/rule_change.dart:56` 12 − 공용 1).
abstract final class RuleChangeResultCodes {
  /// 승인 칸(골든 영향 · 승인자) 빈칸.
  static const String approvalFieldsMissing =
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING';

  /// 전 hash 가 지금 승인된 것이 아니다.
  static const String baseStale = 'RULE_CHANGE_BASE_STALE';

  /// 후 hash 가 `config_versions` 에 없다.
  static const String configUnknown = 'RULE_CHANGE_CONFIG_UNKNOWN';

  /// 냉각 전.
  static const String cooling = 'RULE_CHANGE_COOLING';

  /// 드로다운 락.
  static const String ddLocked = 'RULE_CHANGE_DD_LOCKED';

  /// 이미 결정됐다(취소 · 승인).
  static const String decided = 'RULE_CHANGE_DECIDED';

  /// 요청 칸 빈칸 · 전후 같음.
  static const String fieldsMissing = 'RULE_CHANGE_FIELDS_MISSING';

  /// 저널 미연결.
  static const String journalMissing = 'RULE_CHANGE_JOURNAL_MISSING';

  /// 요청 없음.
  static const String notFound = 'RULE_CHANGE_NOT_FOUND';

  /// 12월 창 밖.
  static const String outOfWindow = 'RULE_CHANGE_OUT_OF_WINDOW';

  /// 제3자 통지 없음.
  static const String thirdPartyMissing = 'RULE_CHANGE_THIRD_PARTY_MISSING';

  static const Set<String> values = <String>{
    approvalFieldsMissing,
    baseStale,
    configUnknown,
    cooling,
    ddLocked,
    decided,
    fieldsMissing,
    journalMissing,
    notFound,
    outOfWindow,
    thirdPartyMissing,
  };
}

/// 🆕 v1.22 — 재량 조정 거부(도메인 `discretion_result` · core `safety/discretion.dart:19` 4 − 공용 1).
/// 🔴 `JOURNAL_MISSING` = `FlagIds.journalMissing` 와 같은 글자 — 축 다름(재량 저널 미연결 ↔ 차단 플래그) · C-5 문서화 중복 다섯째 쌍.
abstract final class DiscretionResultCodes {
  /// 롤링 12개월 사용이 이미 상한.
  static const String countExceeded = 'COUNT_EXCEEDED';

  /// 조정폭이 상한 밖(파싱 실패·NaN 포함 — fail-closed).
  static const String deltaExceeded = 'DELTA_EXCEEDED';

  /// 저널 미연결.
  static const String journalMissing = 'JOURNAL_MISSING';

  static const Set<String> values = <String>{
    countExceeded,
    deltaExceeded,
    journalMissing,
  };
}

/// 🆕 v1.25(01 §34 · K151) — 킬스위치 미체결 취소 결과(도메인 `kill_cancel_outcome` · 엔진 core `KillCancelOutcome` wire 1:1 ·
/// `safety/kill_activation.dart:50-70` · 🔴 타입 이름 ≠ 엔진 — `ambiguous_import` 회피). 화면 분기 0(`KillCancelRow.outcomeCode` = 시험·Key).
abstract final class KillCancelOutcomeCodes {
  /// 취소 접수.
  static const String cancelled = 'CANCELLED';

  /// 분명한 거절 · 브로커 없음 · 오류.
  static const String failed = 'FAILED';

  /// 취소 결과 불명(🔴 다시 부르지 않는다 — NR-2).
  static const String unknown = 'UNKNOWN';

  /// 주문 결과가 불명이라 취소하지 않고 보고만.
  static const String notCancelledUnknownIntent =
      'NOT_CANCELLED_UNKNOWN_INTENT';

  /// 제출 중(브로커에 닿지 않았거나 닿는 중) — 보고만.
  static const String inFlight = 'IN_FLIGHT';

  static const Set<String> values = <String>{
    cancelled,
    failed,
    unknown,
    notCancelledUnknownIntent,
    inFlight,
  };
}

/// 🆕 v1.26(01 §35 · K182) — `M5-5` RECON 해제 거부(도메인 `recon_clear_result` · 🔵 **엔진 예고** — 엔진 «저널 함께 쓰기» 판
/// (01 §8 미결 206)이 지금의 예외(ds `order_ledger.dart` `clearReconBlock` — 원인 코드 밖 = `ArgumentError` · 막힘 없음 =
/// `StateError`)를 이 코드로 바꾼다 · 글자 같음 시험 = 엔진 PR). 공용 `JOURNAL_ID_TAKEN`(`SafetyCommonResultCodes`) ·
/// `BIOMETRIC_UNAVAILABLE`(`SettingsResultCodes`)은 따로 — 다시 적지 않는다.
abstract final class ReconClearResultCodes {
  /// 풀 RECON_MISMATCH 가 서 있지 않다.
  static const String notBlocked = 'RECON_NOT_BLOCKED';

  /// 원인 코드가 쓰기 화이트리스트 밖.
  static const String originNotAllowed = 'RECON_ORIGIN_NOT_ALLOWED';

  /// 사전 저널 3칸 중 빈칸.
  static const String journalMissing = 'RECON_JOURNAL_MISSING';

  static const Set<String> values = <String>{
    notBlocked,
    originNotAllowed,
    journalMissing,
  };
}

/// 🆕 v1.37(01 §46 · K319 · 01 §8 미결 224 ⓑ) — `M5-13` 보관 명령 일괄 확정 거부(도메인 `held_review_result` · 🔵 **엔진 예고** —
/// 생산 = 01 §8 미결 226). 확정 = 엔진 완성 `SafetyActionCall`(`heldCommandsConfirm` · `{review_id}`)을 그대로 넘긴 것만 받는다.
/// 공용 `BIOMETRIC_UNAVAILABLE`(`SettingsResultCodes`)은 따로 — 다시 적지 않는다.
/// 🔴 버림(DISCARD) 코드 0 — 보관 명령은 사람이 낸 사실이라 버리지 않는다(01 §10-8) · 확정 뒤 판정 = 보통 소비 규칙
///    (`staleContext` · 접수증 거부 사전 그대로).
abstract final class HeldReviewResultCodes {
  /// `review_id` 가 지금 보관 묶음과 다르다(그 사이 새 보관 · 이미 확정) — 화면을 다시 읽고 다시 누른다.
  static const String stale = 'HELD_REVIEW_STALE';

  /// `LEDGER_INTEGRITY` 가 아직 서 있다(무결성 점검이 끝나야 확정 — B18).
  static const String integrityActive = 'HELD_REVIEW_INTEGRITY_ACTIVE';

  /// 인자가 `{review_id}` 꼴이 아니다(모르는 키 · 열거형 밖 자유 서술 — 06 M5-13 검증 게이트).
  static const String argsInvalid = 'HELD_REVIEW_ARGS_INVALID';

  static const Set<String> values = <String>{
    stale,
    integrityActive,
    argsInvalid,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/settings_codes.dart`

```dart
// 01 §3 · 🆕 계약 v1.18(01 §27 · K-n ⓗ · K-s · K-u) — M9 설정 코드 사전 3축.
// 🆕 계약 v1.19(01 §28 · K14 · K16) — `EngineStopReasonCodes`(S05 엔진 중지 사유 · 사람) · `SettingsResultCodes` +2.
// 🆕 계약 v1.20(01 §29 · K8 · K9 · K13 · K32) — `CredentialKindCodes`(겹침 몫 · 엔진 `KisKeySet.wire` 1:1) · `SettingsSlotIds` · `SettingsResultCodes` +3.
// 🆕 계약 v1.23(01 §32 · K80) — `ContributionResultCodes`(S13 월 납입 거부 · 엔진 `ContributionRejectCodes` 7 − 공용 1).
// 🆕 계약 v1.24(01 §33 · K119 · K132) — `BackupResultCodes`(S09 «지금 백업» = X1 스냅숏 `take` 거부 8) · `LedgerIntegrityResultCodes`(S10 무결성 = E13c1 사유 7).
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다(labels.dart 머리) — 문구는 엔진이 함께 싣는다
//    (`ConnectionRow.label` · `NotifyChannelOption.label` · `ActionResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.

/// `ConnectionRow.target` · `connectionTest`·`connectionSyncNow` args `target` 의 값(도메인 `connection_target` · 01 §8 미결 151).
abstract final class ConnectionTargetCodes {
  /// Supabase 미러(읽기 모델 push · 무료 티어 일시정지 경고).
  static const String supabase = 'SUPABASE';

  /// GitHub 아카이브(운영 이력 · `sim/` · PAT = 만료일만).
  static const String githubArchive = 'GITHUB_ARCHIVE';

  /// 알림 채널(텔레그램/카카오톡 — 선택 = `ConnectionRow.channelPicker`).
  static const String notifyChannel = 'NOTIFY_CHANNEL';

  /// healthchecks.io 생존 신호(목록 = `W-01` · 행 = 요약 1 + `opsWatchdog` 링크).
  static const String healthchecks = 'HEALTHCHECKS';

  /// 구글 캘린더(X4 · `calendarEnabled == false` 면 행 0 · 상세 = `S08`).
  static const String calendar = 'CALENDAR';

  /// 증권사(KIS) 연결 — `m8/incident_token_expired` 행 · 키 관리 = `S02`.
  static const String brokerKis = 'BROKER_KIS';

  static const Set<String> values = <String>{
    supabase,
    githubArchive,
    notifyChannel,
    healthchecks,
    calendar,
    brokerKis,
  };
}

/// `NotifyChannelOption.code` · `notifyChannelSelect` args `channel` 의 값(도메인 `notify_channel`).
abstract final class NotifyChannelCodes {
  /// 텔레그램 — 원격 `/stop` 가능.
  static const String telegram = 'TELEGRAM';

  /// 카카오톡 «나에게 보내기» — 발신 전용(원격 정지 불가 · 토큰 주기 만료).
  static const String kakao = 'KAKAO';

  static const Set<String> values = <String>{telegram, kakao};
}

/// M9 `ActionResult.reasonCode` 의 앱 코드(도메인 `settings_result`). 🔴 전수 아님 — 뒤 카드(R6c~R9)가 늘린다.
abstract final class SettingsResultCodes {
  /// 운영 등급 동작 거부 — 생체 실패·미등록·세션 만료(`blocked` · 다시 들어와 인증).
  static const String biometricUnavailable = 'BIOMETRIC_UNAVAILABLE';

  /// 연결 테스트 실패 — 원인 = `headline`(엔진 문장).
  static const String connectionTestFailed = 'CONNECTION_TEST_FAILED';

  /// 지금 동기화 중복 요청 — 이미 도는 중(멱등 접수 · `info`).
  static const String syncAlreadyRunning = 'SYNC_ALREADY_RUNNING';

  /// 🆕 v1.19(01 §28 · K16) — 엔진 시작 중복 요청(이미 돌고 있음 · 멱등 접수 · `info`).
  static const String engineAlreadyRunning = 'ENGINE_ALREADY_RUNNING';

  /// 🆕 v1.19(01 §28 · K16) — 엔진 중지 중복 요청(이미 멈춰 있음 · 멱등 접수 · `info`).
  static const String engineAlreadyStopped = 'ENGINE_ALREADY_STOPPED';

  /// 🆕 v1.20(01 §29 · K13) — 다른 환경의 키(모의 칸에 실전 키 등 · 엔진 `KisGuardError`) — 저장하지 않았다(`act`).
  /// 🔴 기동 거부 `ModeStartupCodes.credentialEnvMismatch`(저장된 키 ↔ 지금 모드)와 다른 뜻.
  static const String wrongKeySet = 'WRONG_KEY_SET';

  /// 🆕 v1.20(K13) — 잔고 드라이런 실패로 매핑을 바꾸지 않았거나 전체 검증을 마치지 못했다(`act`).
  static const String mappingVerifyFailed = 'MAPPING_VERIFY_FAILED';

  /// 🆕 v1.20(K13) — 이미 폐기된 기기의 폐기 요청(멱등 접수 · `info`).
  static const String deviceAlreadyRevoked = 'DEVICE_ALREADY_REVOKED';

  // 🔴 S02 검증 거절 = `OnboardingResultCodes.credentialRejected` 한 벌(K32 — `CREDENTIAL_VERIFY_FAILED` · `CREDENTIAL_NOT_VERIFIED` 0).
  static const Set<String> values = <String>{
    biometricUnavailable,
    connectionTestFailed,
    syncAlreadyRunning,
    engineAlreadyRunning,
    engineAlreadyStopped,
    wrongKeySet,
    mappingVerifyFailed,
    deviceAlreadyRevoked,
  };
}

/// 🆕 v1.19(01 §28 · K14) — `runtimeEngineStop` args `reason_code` 의 값(도메인 `engine_stop_reason` · 사람이 고르는 사유).
/// 🔵 잠정 2 — 값 확정 = 엔진 SPEC 판(01 §8 미결 173 · 추가 = 추가형 minor).
/// 🔴 «시장이 불안해서» 류 사유를 넣지 않는다(시장 판단 중지 = 재량 개입 — 킬스위치·개입 경로) · 기기 이전 = X1 마법사(두 길 0).
/// 🔴 엔진이 기동을 거부한 사유는 이 사전이 아니다 — `ModeStartupCodes`(labels/sim_codes.dart).
abstract final class EngineStopReasonCodes {
  /// 계획 점검(앱·OS 업데이트 · 기기 손질).
  static const String plannedMaintenance = 'PLANNED_MAINTENANCE';

  /// 이상 조사(알림·잡·연결이 이상해 원인을 볼 동안).
  static const String troubleshooting = 'TROUBLESHOOTING';

  static const Set<String> values = <String>{
    plannedMaintenance,
    troubleshooting,
  };
}

/// 🆕 v1.20(01 §29 · K8 · 01 §8 미결 151 ✅) — 증권사 KIS 키 세트 종류(도메인 `credential_kind`) —
/// `CredentialCardVm.kind` · `credentialVerify` args `kind` 의 값.
/// 🔴 엔진 `broker_gateway` `KisKeySet.wire` 와 **같은 글자**다(실물 = `paper('KIS_PAPER')` · 나머지 3 = 엔진이 이 사전을 보고 더한다 —
///    `kis_credential_vault.dart:8` «계약 창(R7) 뒤» · 06 변경 이력 «2026-11-15 · 계약 v1.20»).
/// 🔴 `SECRET_KIS_MOCK`(슬롯 이름)은 이 사전의 값이 아니다 — 자리 이름과 키 세트는 다른 축(v1.16 표본 `KIS_MOCK` = v1.20 에서 `KIS_PAPER` 로 정정).
/// 🔴 화면은 이 값으로 분기·아이콘·색을 고르지 않는다(카드 글자 = `kindLabel` · 색 = `level`).
abstract final class CredentialKindCodes {
  /// 실전 종합계좌(위탁 01 + 연금저축 22 공유) — 주문·조회.
  static const String kisLive = 'KIS_LIVE';

  /// ISA 중개형 전용 종합계좌.
  static const String kisIsa = 'KIS_ISA';

  /// 모의투자(SIM 계열 · 내부 시뮬레이터도 시세는 이 키 — 01 §9-5 ②).
  static const String kisPaper = 'KIS_PAPER';

  /// X7 대사 전용(`CredentialUse.reconcileOnly` · 주문 경로 봉인).
  static const String kisReconcile = 'KIS_RECONCILE';

  static const Set<String> values = <String>{
    kisLive,
    kisIsa,
    kisPaper,
    kisReconcile,
  };
}

/// 🆕 v1.20(01 §29 · K9 · K15 · K31 · 01 §8 미결 152 🟡) — M9 🔒/플랫폼 슬롯 이름(도메인 `settings_slot`) —
/// `CredentialCardVm.credentialSlotId` · `PairingTicketCard.qrSlotId` 의 값.
/// 🔴 화면(`ui_settings`)은 이름을 해석하지 않는다 — 주입된 슬롯 빌더에 그대로 넘긴다. 이름 → 위젯 = 조립 앱(06 `M4-12` ⑦).
/// 🔴 모의 키 카드 = `OnboardingSlotIds.secretKisMock` 재사용(같은 금고 칸 = 같은 자리 · 05 §4-1 «두 벌 금지») — 두 번째 이름을 만들지 않는다.
/// 🔴 세 슬롯 사전(`onboarding_slot` · `ops_slot` · `settings_slot`) 값 겹침 0(C-54 ④).
abstract final class SettingsSlotIds {
  /// `S02` 실전 키 입력 — 06 `M4-4` `SecretField`.
  static const String secretKisLive = 'SECRET_KIS_LIVE';

  /// `S02` ISA 키 입력 — 같은 위젯.
  static const String secretKisIsa = 'SECRET_KIS_ISA';

  /// `S02` 대사 전용 키 입력 — 같은 위젯(X7).
  static const String secretKisReconcile = 'SECRET_KIS_RECONCILE';

  /// `S06` viewer 페어링 QR 표시 — 플랫폼(QR 그리기 · 페이로드는 위젯 안에서만 · `VIEWER_QR_SCAN` 의 짝).
  static const String pairingQrDisplay = 'PAIRING_QR_DISPLAY';

  static const Set<String> values = <String>{
    secretKisLive,
    secretKisIsa,
    secretKisReconcile,
    pairingQrDisplay,
  };
}

/// 🆕 v1.23(01 §32 · K80 · v1.21 K45) — M9 `S13` 월 납입 변경 거부(도메인 `contribution_result` · 엔진 core
/// `ops/contribution_setting.dart:241` `ContributionRejectCodes` 7 − 공용 `TRUSTED_TIME_UNKNOWN`(`SafetyCommonResultCodes` 한 벌)).
/// 🔴 타입 이름 ≠ 엔진 — 같으면 core `test/contribution_setting_test.dart` · ds `test/operating_param_store_test.dart` 가 두 배럴을
///    `hide BreakerLevel` 만 붙여 함께 import 해 `ambiguous_import`(v1.21 K33 · v1.22 K49 결) · 엔진이 계약 참조로 옮길 때 지역 선언을 지운다.
/// 🔴 엔진 판정 차례 = 빈칸 → 음수 → 숫자 아님 → 상한 → (신뢰 시각 = 공용) → 시계 전진 → 같은 값(`decideContributionChange` :304).
///    화면은 이 값으로 분기·아이콘·색을 고르지 않는다(결과 줄 = `headline` + `reasonCode` 원문).
abstract final class ContributionResultCodes {
  /// 빈칸.
  static const String blank = 'CONTRIBUTION_INPUT_BLANK';

  /// 음수.
  static const String negative = 'CONTRIBUTION_INPUT_NEGATIVE';

  /// 원 단위 숫자 아님(콤마·앞뒤 공백은 엔진이 지운 뒤 판정).
  static const String notNumber = 'CONTRIBUTION_INPUT_NOT_NUMBER';

  /// 상한 초과(상한 = 엔진 config `maxAmount` · 숫자 = 발주자 대기 05 §8-16).
  static const String overMax = 'CONTRIBUTION_INPUT_OVER_MAX';

  /// 신뢰 시각이 마지막 기록보다 앞서지 않음(같은 순간 · 되감김).
  static const String clockNotAdvanced = 'CONTRIBUTION_CLOCK_NOT_ADVANCED';

  /// 바뀌는 게 없음(가장 최근에 접수된 값 — 예정 포함 — 과 같다).
  static const String unchanged = 'CONTRIBUTION_UNCHANGED';

  static const Set<String> values = <String>{
    blank,
    negative,
    notNumber,
    overMax,
    clockNotAdvanced,
    unchanged,
  };
}

/// 🆕 v1.24(01 §33 · K119 · K132) — M9 `S09` «지금 백업»(`backupRunNow`) 거부(도메인 `backup_result` · 엔진 = ds
/// `migration/ledger_snapshot.dart` `SqliteLedgerSnapshotter.take` :250-315 가 낼 수 있는 코드 **전수**).
/// 🔴 타입 이름 ≠ 엔진(core `SnapshotCodes` · `RestoreReason` · `MigrationStartCodes` — 같으면 엔진 시험이 두 배럴을 함께 import 해
///    `ambiguous_import` · v1.21 K33 · v1.23 K80 결) · 엔진이 계약 참조로 옮길 때 지역 선언을 지운다.
/// 🔴 `take` 에서 구조상 나올 수 없는 `RESTORE_SHA_MISMATCH`·`RESTORE_MANIFEST_MISMATCH`(매니페스트 = 같은 사본의 digest·머리)는 싣지 않는다 —
///    새 폰 복원 검증(X1 마법사)의 남은 둘과 `X1_LIVE_EXISTS` = 🆕 v1.30 `X1RestoreResultCodes`(01 §38 · 복원 거부 전집 = 그 셋 ∪ 이 사전의
///    [liveOnly] · [unreadable] · [schemaSkew] · [sqliteIntegrity] · [chainInvalid] · [rollback] — 같은 엔진 상수 = 한 벌 · K132).
/// 🔴 같은 글자 다른 축: [rollback] = `OriginCodes.restoreRollback` · `LedgerBoundaryReasonCodes.restoreRollback` · [liveOnly] =
///    `X1StartResultCodes.liveOnly`(C-5 문서 쌍 · v1.24 K140 예고 → v1.30 실현).
///    화면은 이 값으로 분기·아이콘·색을 고르지 않는다(결과 줄 = `headline` + `reasonCode` 원문).
abstract final class BackupResultCodes {
  /// live 원장이 아니다(모의 원장 — 백업은 실전 원장에서만).
  static const String liveOnly = 'X1_LIVE_ONLY';

  /// 스탬프(장부 마감)가 없다 — 체인·날을 지어내지 않는다.
  static const String noStamp = 'SNAPSHOT_NO_STAMP';

  /// 그 이름(시각)의 매니페스트가 이미 있다(덮지 않는다).
  static const String exists = 'SNAPSHOT_EXISTS';

  /// 만든 사본을 열거나 읽지 못했다(사본 = 지웠다).
  static const String unreadable = 'RESTORE_UNREADABLE';

  /// 사본 `schema_version` 이 이 앱과 다르다.
  static const String schemaSkew = 'RESTORE_SCHEMA_SKEW';

  /// 사본 `PRAGMA integrity_check` 가 ok 가 아니다.
  static const String sqliteIntegrity = 'RESTORE_SQLITE_INTEGRITY';

  /// 사본 스탬프 체인 자가 대조 실패.
  static const String chainInvalid = 'RESTORE_CHAIN_INVALID';

  /// 아카이브 체크포인트와 같지 않다(없음 · 뒤처짐 · 앞섬 — SPEC ⑧ «같음만» · K133).
  static const String rollback = 'RESTORE_ROLLBACK';

  static const Set<String> values = <String>{
    liveOnly,
    noStamp,
    exists,
    unreadable,
    schemaSkew,
    sqliteIntegrity,
    chainInvalid,
    rollback,
  };
}

/// 🆕 v1.24(01 §33 · K115 · K119) — M9 `S10` 무결성 자가진단(`selftestIntegrityRun`) 불일치 사유(도메인 `ledger_integrity_result` ·
/// 엔진 core `ops/ledger_integrity.dart:16-43` `LedgerIntegrityReason` 7 — E13c1 · 🔴 타입 이름 ≠ 엔진).
/// 🔴 불일치 = 엔진이 `trading_block` `LEDGER_INTEGRITY` 를 세운다(일치해도 풀지 않는다 — 해제 = X5-3 정정) · 일치 = `reasonCode` null.
/// 🔴 같은 글자 다른 축: [chainBroken] = `OriginCodes.chainBroken`(C-5 문서 쌍) · [sqliteIntegrity]·[formatVersion] =
///    `LedgerBoundaryReasonCodes`(C-5 문서 쌍 · v1.24 K140 예고 → v1.30 실현).
abstract final class LedgerIntegrityResultCodes {
  /// 스탬프의 직렬화 형식 판이 현행과 다르다.
  static const String formatVersion = 'FORMAT_VERSION';

  /// 스탬프 날이 달력일로 이어지지 않는다.
  static const String dateGap = 'DATE_GAP';

  /// 체인 칸이 앞 체인 ‖ day_hash 와 다르다.
  static const String chainBroken = 'CHAIN_BROKEN';

  /// 지금 원장으로 다시 센 day_hash 가 스탬프와 다르다.
  static const String dayHashMismatch = 'DAY_HASH_MISMATCH';

  /// 첫 스탬프 앞 날에 귀속되는 행이 있다(소급 삽입).
  static const String rowsBeforeFirstStamp = 'ROWS_BEFORE_FIRST_STAMP';

  /// 행을 날에 귀속하지 못했다(다시 셀 수 없으면 일치를 말할 수 없다 — fail-closed).
  static const String attribution = 'ATTRIBUTION';

  /// `PRAGMA integrity_check` 가 ok 가 아니다.
  static const String sqliteIntegrity = 'SQLITE_INTEGRITY';

  static const Set<String> values = <String>{
    formatVersion,
    dateGap,
    chainBroken,
    dayHashMismatch,
    rowsBeforeFirstStamp,
    attribution,
    sqliteIntegrity,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/sim_codes.dart`

```dart
// 01 §3 · 🆕 계약 v1.19(01 §28 · K15 · K21) — X6 모의투자·관찰·기동 판정 코드 사전(엔진 E15 실물 글자 그대로).
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다 — 문구는 엔진이 함께 싣는다
//    (`SimTrialCheck.label`·`stateLabel` · `ActionResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.
// 🔴 출처(origin/main 175cbd5) — core_engine `sim/sim_trial.dart` `SimTrialItem`·`SimTrialItemState` ·
//    `mode/live_observation.dart` `LiveObservationBlock` · `mode/mode_guard.dart` `kCredentialEnvMismatch` ·
//    `safety/rule_change.dart` `kSaf405` · `sim/sim_opening.dart` `SimOpeningCodes` · `mode/live_promotion.dart`
//    `LivePromotionCodes`(E15e2 #161). 엔진 로컬 상수 → 이 사전 참조 = 엔진 다음 조각(01 §8 미결 177).

/// `SimTrialCheck.itemCode` — 자동 매매 갈래 체험 5항목(도메인 `sim_trial_item` · 차례 = 04 §9-5 = 엔진 `SimTrialItem`).
abstract final class SimTrialItemCodes {
  /// ① 연속 2거래주 정상 배치.
  static const String twoTradingWeeks = 'SIM_TRIAL_TWO_TRADING_WEEKS';

  /// ② 월말 정기 리밸런싱 1회(🔴 소프트 — 미경험 = 경고 후 진행 허용).
  static const String monthEndRebalance = 'SIM_TRIAL_MONTH_END_REBALANCE';

  /// ③ 대사 0오차(simBroker 만 · simInternal = 자동 통과).
  static const String reconciliation = 'SIM_TRIAL_RECONCILIATION';

  /// ④ X2 재개 1회 시연.
  static const String resume = 'SIM_TRIAL_RESUME';

  /// ⑤ 킬스위치 발동·재개 1회 연습.
  static const String killSwitch = 'SIM_TRIAL_KILL_SWITCH';

  static const Set<String> values = <String>{
    twoTradingWeeks,
    monthEndRebalance,
    reconciliation,
    resume,
    killSwitch,
  };
}

/// `SimTrialCheck.itemState` — 항목 상태(도메인 `sim_trial_state` · 엔진 `SimTrialItemState.wire`).
/// 🔴 `GateState` 가 아니다(K9) — 색 = `SimTrialCheck.level`(짝 = 01 §28 K9).
abstract final class SimTrialItemStateCodes {
  /// 채웠다.
  static const String passed = 'PASSED';

  /// 해당 없음 — 자동 통과(③ simInternal).
  static const String autoPassed = 'AUTO_PASSED';

  /// 아직(단단한 문).
  static const String open = 'OPEN';

  /// 아직 — 경고 후 진행 허용(② 소프트).
  static const String openWarn = 'OPEN_WARN';

  static const Set<String> values = <String>{
    passed,
    autoPassed,
    open,
    openWarn,
  };
}

/// 실전 관찰 판정이 승격을 막는 사유(도메인 `live_observation_block` · 차례 = 판정 차례 · 엔진 `LiveObservationBlock.code`) —
/// `runtimeLivePromotion` 결과 `ActionResult.reasonCode`(13 R91 AD4 재판정).
abstract final class LiveObservationBlockCodes {
  /// 킬스위치 켜짐.
  static const String killSwitch = 'LIVE_OBSERVATION_KILL_SWITCH';

  /// 주문 차단 플래그.
  static const String tradingBlock = 'LIVE_OBSERVATION_TRADING_BLOCK';

  /// 확인 안 된 주문.
  static const String unknownOrders = 'LIVE_OBSERVATION_UNKNOWN_ORDERS';

  /// 연속 무결 거래일 모자람.
  static const String notEnoughDays = 'LIVE_OBSERVATION_NOT_ENOUGH_DAYS';

  static const Set<String> values = <String>{
    killSwitch,
    tradingBlock,
    unknownOrders,
    notEnoughDays,
  };
}

/// 🆕 E15e2(#161) — 승격 커밋 거부·결과(도메인 `live_promotion_result` · 엔진 `LivePromotionCodes` 글자 그대로) —
/// `runtimeLivePromotion` 결과 `ActionResult.reasonCode`.
/// 🆕 v1.39(01 §48 · K346) 사전 판정 차례 = 생체 → 세션 → 관찰 중 → 자동 매매 → 시각 → **리스 → 설정 → 재판정**
/// (core `livePromotionReject` · 리스 = E15f5 R108 · 설정 = 리뷰 3차 H2-02 · 13 §8 R265 — 설정을 못 읽으면 잡이 실패해 무결일이 0 이라
/// «일수 부족»이 진짜 사유를 가린다 → 재판정보다 먼저).
/// 🔴 생체 없음 = `SettingsResultCodes.biometricUnavailable` · 리스 무효 = `JournalReasonCodes.leaseInvalid`(`LEASE_INVALID` · core
///    `kLeaseInvalidCode`) — 둘 다 한 벌(이 사전에 다시 싣지 않는다) · 재판정 막힘 = [LiveObservationBlockCodes].
abstract final class LivePromotionResultCodes {
  /// 준 세션이 없거나 닫혔거나 만료.
  static const String sessionInvalid = 'HANDOVER_SESSION_INVALID';

  /// 현재 행이 실전 관찰(live × dryRun)이 아니다.
  static const String notObserving = 'LIVE_PROMOTION_NOT_OBSERVING';

  /// 운영 방식이 자동 매매가 아니다(모름 포함).
  static const String notAutoTrade = 'LIVE_PROMOTION_NOT_AUTO_TRADE';

  /// 지금이 현재 행 커밋 시각보다 늦지 않다.
  static const String clockBehind = 'LIVE_PROMOTION_CLOCK_BEHIND';

  /// 저장 실패 — 전부 되돌렸다.
  static const String rolledBack = 'LIVE_PROMOTION_ROLLED_BACK';

  /// 🆕 v1.39(01 §48 · K346 · 13 §8 R265 S3) — 실전 파일의 지금 설정(실전 개시 판)을 못 읽었다(빈 지문으로 실주문을 켜지 않는다 ·
  /// 쓰기 0 · 다시 시도 0 · 화면 = headline 그대로).
  static const String configUnavailable = 'LIVE_PROMOTION_CONFIG_UNAVAILABLE';

  static const Set<String> values = <String>{
    sessionInvalid,
    notObserving,
    notAutoTrade,
    clockBehind,
    rolledBack,
    configUnavailable,
  };
}

/// 엔진 기동 판정이 시작을 거부한 사유(도메인 `mode_startup` · 차례 = SAF-405 → 조합 → 자격증명 환경) —
/// `runtimeEngineStart` 결과 `ActionResult.reasonCode`.
/// 🔴 조합 금지 = `AdviceRejectCodes.modeCombinationDenied`(01 §10-2 · 같은 글자 한 벌 — 이 사전에 다시 싣지 않는다).
/// 🔴 hold(`SafetyHoldCodes` · 기동은 하되 배치를 멈춤)와 다르다.
abstract final class ModeStartupCodes {
  /// 승인되지 않은 규칙·설정 변경이 있다(엔진 `kSaf405`).
  static const String saf405 = 'SAF-405';

  /// 금고 자격증명의 환경 ≠ 실행 모드가 기대하는 환경(엔진 `kCredentialEnvMismatch`).
  static const String credentialEnvMismatch = 'CREDENTIAL_ENV_MISMATCH';

  static const Set<String> values = <String>{saf405, credentialEnvMismatch};
}

/// 모의 개시·온보딩 커밋 거부(도메인 `sim_opening_result` · 엔진 `SimOpeningCodes`) — `onboardingDryRunStart` 결과
/// `ActionResult.reasonCode` · `submitSelfReportBalance(purpose: simOpening)` 의 `CommandReceipt.rejectReasonCode`(M5-14).
abstract final class SimOpeningResultCodes {
  /// 금액이 0 이하.
  static const String notPositive = 'SIM_OPENING_NOT_POSITIVE';

  /// 금액에 원 미만 자리가 있다.
  static const String notWholeWon = 'SIM_OPENING_NOT_WHOLE_WON';

  /// 비중이 있는 전략의 계좌가 설정에 없다.
  static const String accountUnmapped = 'SIM_OPENING_ACCOUNT_UNMAPPED';

  /// 자동 매매 개시에 보유 줄이 왔다(금액 1칸만 받는다).
  static const String linesNotAllowed = 'SIM_OPENING_LINES_NOT_ALLOWED';

  /// 정기 실사 등 다른 목적의 제출.
  static const String wrongPurpose = 'SIM_OPENING_WRONG_PURPOSE';

  /// 이미 선언했다(append-only).
  static const String alreadyDeclared = 'SIM_OPENING_ALREADY_DECLARED';

  /// 커밋 전에 가상 초기금 선언이 없다.
  static const String notDeclared = 'SIM_OPENING_NOT_DECLARED';

  /// 운영 방식 선택(O-00b)이 없다.
  static const String choiceMissing = 'ONBOARDING_CHOICE_MISSING';

  /// 투자 안내 갈래의 모의 개시(보유 선언 · L-3 폼) = E18.
  static const String advisoryNotReady = 'SIM_OPENING_ADVISORY_NOT_READY';

  /// 계층 B 카드 미등록 — 체험 시작 금지.
  static const String tierBCardMissing = 'TIER_B_CARD_MISSING';

  static const Set<String> values = <String>{
    notPositive,
    notWholeWon,
    accountUnmapped,
    linesNotAllowed,
    wrongPurpose,
    alreadyDeclared,
    notDeclared,
    choiceMissing,
    advisoryNotReady,
    tierBCardMissing,
  };
}

// 🆕 v1.22(01 §31 · K21 · K51 · K58 · K67) — simToAuto 판정·확정·세션·단계 · 모드 표지(엔진 E15 실물 글자 그대로 ·
// origin/main 4f85259 · 엔진 로컬 상수 → 이 사전 참조 = 엔진 다음 조각).

/// 🆕 v1.22 — simToAuto 판정·막힘(도메인 `sim_to_auto_result` · core `SimToAutoCodes` · `mode/sim_to_auto.dart:92-123` 10).
/// 축 = `HandoverStep.blockedReasonCode`(simToAuto) · `ActionResult.reasonCode`(위저드 동작).
abstract final class SimToAutoResultCodes {
  /// 모의 자동 매매가 아니다(모의 파일 현재 행 · 닫힘 · 운영 방식).
  static const String notSimAuto = 'SIM_TO_AUTO_NOT_SIM_AUTO';

  /// 킬스위치 · 주문 차단 플래그.
  static const String safetyBlock = 'SIM_TO_AUTO_SAFETY_BLOCK';

  /// 체험 미완.
  static const String trialIncomplete = 'SIM_TO_AUTO_TRIAL_INCOMPLETE';

  /// 골든 벡터 실패.
  static const String goldenVectorFailed = 'SIM_TO_AUTO_GOLDEN_VECTOR_FAILED';

  /// 실전 키 검증 실패.
  static const String liveKeysFailed = 'SIM_TO_AUTO_LIVE_KEYS_FAILED';

  /// 계좌 없는 전략.
  static const String accountUnmapped = 'SIM_TO_AUTO_ACCOUNT_UNMAPPED';

  /// 냉각 중.
  static const String cooling = 'SIM_TO_AUTO_COOLING';

  /// 확정 기한 지남(세션 만료).
  static const String sessionExpired = 'SIM_TO_AUTO_SESSION_EXPIRED';

  /// 신뢰 시각 없음 — 🔴 공용 `TRUSTED_TIME_UNKNOWN` 과 다른 글자(엔진 이력 · K12).
  static const String trustedTimeUnavailable =
      'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE';

  /// 다음 정기 집행 전에 관찰을 채울 수 없다(🔴 상수 이름 ≠ 엔진 `commitWindow` — C-7 `_writeVerb` · K51).
  static const String windowBlocked = 'SIM_TO_AUTO_COMMIT_WINDOW';

  static const Set<String> values = <String>{
    notSimAuto,
    safetyBlock,
    trialIncomplete,
    goldenVectorFailed,
    liveKeysFailed,
    accountUnmapped,
    cooling,
    sessionExpired,
    trustedTimeUnavailable,
    windowBlocked,
  };
}

/// 🆕 v1.22(K58) — simToAuto 확정 1단계 · 오케스트레이터 결과(도메인 `sim_to_auto_commit_result` ·
/// core `SimToAutoCommitCodes`(`mode/sim_to_auto_commit.dart`) 전부 + `mode/sim_to_auto_switch.dart` 2).
/// 🆕 v1.39(01 §48 · K346) 엔진 안 예약 3 등재 — [fateConfigUnavailable](13 R265 S4) · [configNotApproved](13 R192 AA4) ·
/// [accountDuplicate](13 R262 D3) · 🔴 엔진 `SimToAutoCommitCodes` ⊆ 이 사전(C-72 ⑧ 원천 대조 — 리뷰 3차 I-2).
/// 판정 차례(core `simToAutoCommitReject` · 13 R192 · R262) = 신뢰 시각 → 세션 → 리스 → 이미 커밋 → **승인 config** → 재판정(냉각) →
/// 계좌 조회 없음 → **별칭 중복** → 신선도 → 보유 → 활동 → 예수금(모름 · 0원).
abstract final class SimToAutoCommitResultCodes {
  /// 실전 파일에 이미 모드 행이 있다.
  static const String alreadyCommitted = 'SIM_TO_AUTO_ALREADY_COMMITTED';

  /// 대응 계좌 가운데 조회가 없는 곳이 있다.
  static const String probeMissing = 'SIM_TO_AUTO_ACCOUNT_PROBE_MISSING';

  /// 조회가 오래됐거나 미래 시각이다.
  static const String snapshotStale = 'SIM_TO_AUTO_SNAPSHOT_STALE';

  /// 실전 계좌에 보유 종목이 있다.
  static const String holdingsNotZero = 'SIM_TO_AUTO_HOLDINGS_NOT_ZERO';

  /// 오늘 브로커 주문 · 체결이 있다.
  static const String brokerActivityToday = 'SIM_TO_AUTO_BROKER_ACTIVITY_TODAY';

  /// 예수금을 알 수 없다.
  static const String cashUnknown = 'SIM_TO_AUTO_CASH_UNKNOWN';

  /// 예수금 합계가 없다.
  static const String zeroCash = 'SIM_TO_AUTO_ZERO_CASH';

  /// 쓰기 실패 — 전부 되돌리고 세션을 닫았다.
  static const String rolledBack = 'SIM_TO_AUTO_COMMIT_ROLLED_BACK';

  /// 세션을 연 기기 · 리스 세대가 지금과 다르다.
  static const String leaseMismatch = 'SIM_TO_AUTO_LEASE_MISMATCH';

  /// 닫힌 모의 파일에는 5단계 고름을 적지 않는다.
  static const String simClosed = 'SIM_LEDGER_FATE_SIM_CLOSED';

  /// 오케스트레이터 — 새 감시 체크 준비 실패(전환하지 않았다).
  static const String watchdogPrepareFailed =
      'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED';

  /// 오케스트레이터 — 커밋 콜백 결과 모름(보상 0 · 🔴 상수 이름 ≠ 엔진 `kSimToAutoCommitUnknown` — C-7 · K51).
  static const String outcomeUnknown = 'SIM_TO_AUTO_COMMIT_UNKNOWN';

  /// 🆕 v1.39(13 R265 S4 · 리뷰 3차 H2-02) — 모의 파일의 지금 설정(모의 개시 판)을 못 읽어 5단계 고름을 적지 않았다(쓰기 0 · 빈 지문 결정 0) ·
  /// 축 = `handoverSimLedgerFate` 결과(S5 · [simClosed] 와 같은 자리).
  static const String fateConfigUnavailable =
      'SIM_LEDGER_FATE_CONFIG_UNAVAILABLE';

  /// 🆕 v1.39(13 R192 AA4 · 미결 205 ⓓ) — 지금 설정(실전 개시에 붙일 판)이 규칙 변경 승인을 받지 않았다(승인 config 0 · 승인 기록 없음 ·
  /// 다른 판 승인) — 쓰기 0 · 세션 그대로(SAF-405 · 실전 기동 = 승인 config 필수).
  static const String configNotApproved = 'SIM_TO_AUTO_CONFIG_NOT_APPROVED';

  /// 🆕 v1.39(13 R262 D3 · 리뷰 3차 A-2) — 서로 다른 별칭이 같은 실전 계좌(종합계좌 · 상품코드)를 가리킨다 — 쓰기 0 · 세션 그대로
  /// (한 계좌 예수금을 두 번 개시 현금으로 적지 않는다).
  static const String accountDuplicate = 'SIM_TO_AUTO_ACCOUNT_DUPLICATE';

  static const Set<String> values = <String>{
    alreadyCommitted,
    probeMissing,
    snapshotStale,
    holdingsNotZero,
    brokerActivityToday,
    cashUnknown,
    zeroCash,
    rolledBack,
    leaseMismatch,
    simClosed,
    watchdogPrepareFailed,
    outcomeUnknown,
    fateConfigUnavailable,
    configNotApproved,
    accountDuplicate,
  };
}

/// 🆕 v1.39(01 §48 · K347 · 13 §8 R261 H5 · 리뷰 3차 H1-2) — 닫힌 원장 쓰기 거부(도메인 `ledger_write_gate`).
/// 축 = `CommandReceipt.rejectReasonCode`(모든 명령 종류) · `ActionResult.reasonCode` · `SafetyActionResult.reasonCode`(원장에 쓰는 동작).
/// 🔴 뜻 = 화면 상태가 가리키는 원장이 닫혔다(simToAuto 커밋으로 CLOSE 된 모의 원장 · 커밋 ~ 깨어남 끝 몇 초 틈) → 쓰기 0 · 접수증 = rejected ·
///    다시 누르면 깨어남 뒤 새 원장에 적힌다(`retryable` true · 글자 = 엔진 headline · `stateLabel`).
/// 🔴 `runMode` 불일치 거부(01 §5-3 · 파일 경계)와 다른 축 — 같은 모드라도 원장 행이 CLOSE 면 이 글자.
abstract final class LedgerWriteGateCodes {
  /// 닫힌(CLOSE) 원장에는 쓰지 않는다.
  static const String ledgerClosed = 'LEDGER_CLOSED';

  static const Set<String> values = <String>{ledgerClosed};
}

/// 🆕 v1.22(K21) — 전환 세션 결과(도메인 `handover_session_result` · core `HandoverSessionCodes` `mode/handover_session.dart:75-88`
/// − `INVALID`(v1.19 `LivePromotionResultCodes.sessionInvalid` 한 벌 — simToAuto 도 그 글자) − 생체(`SettingsResultCodes`)).
abstract final class HandoverSessionResultCodes {
  /// 이미 열린 세션이 있다.
  static const String sessionOpen = 'HANDOVER_SESSION_OPEN';

  /// 저장 실패 — 전부 되돌렸다.
  static const String rolledBack = 'HANDOVER_SESSION_ROLLED_BACK';

  static const Set<String> values = <String>{sessionOpen, rolledBack};
}

/// 🆕 v1.22 — simToAuto 7단계 id(도메인 `sim_to_auto_step` · core `SimToAutoStep.stepId` `mode/sim_to_auto.dart:53-77` ·
/// 축 = `HandoverStep.stepId`(simToAuto) · 막힘 코드 없는 첫 열린 단계의 거부 `reasonCode` · `UnknownResolutionStep.stepId` 선례).
/// 🔴 [cooling] ↔ `SimToAutoResultCodes.cooling` = 다른 클래스 · 다른 글자(`SIM_TO_AUTO_S7` ↔ `SIM_TO_AUTO_COOLING`).
abstract final class SimToAutoStepIds {
  /// 1 모의 체험 확인.
  static const String trial = 'SIM_TO_AUTO_S1';

  /// 2 골든 벡터 자가검사.
  static const String goldenVector = 'SIM_TO_AUTO_S2';

  /// 3 실전 키 등록 · 조회 검증.
  static const String liveKeys = 'SIM_TO_AUTO_S3';

  /// 4 계좌 연결.
  static const String accounts = 'SIM_TO_AUTO_S4';

  /// 5 모의 기록 보관 · 지움.
  static const String simLedger = 'SIM_TO_AUTO_S5';

  /// 6 생체 확인.
  static const String biometric = 'SIM_TO_AUTO_S6';

  /// 7 냉각.
  static const String cooling = 'SIM_TO_AUTO_S7';

  /// 차례 = 단계 차례(C-56 ④).
  static const List<String> ordered = <String>[
    trial,
    goldenVector,
    liveKeys,
    accounts,
    simLedger,
    biometric,
    cooling,
  ];

  static const Set<String> values = <String>{
    trial,
    goldenVector,
    liveKeys,
    accounts,
    simLedger,
    biometric,
    cooling,
  };
}
```

---

## `packages/domain_contracts/lib/src/labels/supabase_codes.dart`

```dart
// 🆕 계약 v1.29(01 §39 · K223~ · E11k-b 계약 창) — Supabase 연결(o_07 ②) · 신뢰 시각 · operator 리스의 코드 사전.
//
// 🔴 타입 이름 ≠ 엔진(data_sync `SupabaseInputProblem` · `SupabaseTimeFailure` · 🆕 v1.31 `SupabaseAuthFailure` — 같으면 엔진 시험이
//    두 배럴을 함께 import 해 `ambiguous_import` · K80). 엔진 enum 은 와이어 글자가 없다 — enum → 이 글자 매핑 = 엔진 숙제(E11k-c ·
//    01 §8 미결 213).
// 🔴 리스 무효 `LEASE_INVALID`(주문 거부 · core `kLeaseInvalidCode`)는 v1.18 `JournalReasonCodes.leaseInvalid` 한 벌 — 여기 다시 두지 않는다.
// 🔴 화면은 이 글자로 분기 · 아이콘 · 색 · 문구를 고르지 않는다 — 결과 줄 = `ActionResult.headline` + `reasonCode` 원문.
// 🔴 주소 · 키 · 토큰 값은 어떤 코드 · 결과 · 로그에도 싣지 않는다(종류만).

/// o_07 ② 연결 값 입력 문제(도메인 `supabase_input_result` · data_sync `supabase/supabase_server_time.dart` `SupabaseInputProblem` 6 1:1 ·
/// `connectionTest{target: SUPABASE}` 의 `ActionResult.reasonCode` · 🔴 망에 가기 전 판정).
abstract final class SupabaseInputResultCodes {
  /// 비었다.
  static const String empty = 'SUPABASE_INPUT_EMPTY';

  /// 빈칸 · 줄바꿈 · 따옴표가 섞였다.
  static const String whitespace = 'SUPABASE_INPUT_WHITESPACE';

  /// 프로젝트 주소 꼴(`https://<ref>.supabase.co`)이 아니다.
  static const String notProjectUrl = 'SUPABASE_URL_INVALID';

  /// 🔴 비밀 키(`sb_secret_…`)다 — 앱은 받지 않는다.
  static const String secretKey = 'SUPABASE_SECRET_KEY_REJECTED';

  /// 🔴 service_role JWT 다 — 앱은 받지 않는다.
  static const String serviceRoleKey = 'SUPABASE_SERVICE_ROLE_REJECTED';

  /// 공개 키(publishable · 옛 anon) 꼴이 아니다.
  static const String notPublishableKey = 'SUPABASE_KEY_INVALID';

  static const Set<String> values = <String>{
    empty,
    whitespace,
    notProjectUrl,
    secretKey,
    serviceRoleKey,
    notPublishableKey,
  };
}

/// 서버 시각 읽기 실패(도메인 `supabase_time_result` · data_sync `supabase/supabase_server_time.dart` `SupabaseTimeFailure` 8 1:1).
/// 🔴 o_07 ② 연결 검증(`connectionTest{target: SUPABASE}`)에서 나오는 것 = 망 다섯([unauthorized] · [server] · [badResponse] ·
///    [noDate] · [network]) · 금고 셋([notConfigured] · [badConfig] · [vault]) = 신뢰 시각 기준점(엔진 깨어남 · 앞 화면 주기)이 금고를
///    읽을 때만(연결 진단 · S07 줄 · 로그 축).
abstract final class SupabaseTimeResultCodes {
  /// 금고에 주소 · 키가 없다(o_07 ② 전) — 망에 가지 않았다.
  static const String notConfigured = 'SUPABASE_NOT_CONFIGURED';

  /// 금고 값이 꼴이 아니다 — 망에 가지 않았다.
  static const String badConfig = 'SUPABASE_CONFIG_INVALID';

  /// 금고를 읽지 못했다.
  static const String vault = 'SUPABASE_VAULT_UNREADABLE';

  /// 키가 틀렸다(401 · 403).
  static const String unauthorized = 'SUPABASE_UNAUTHORIZED';

  /// 서버 오류(5xx).
  static const String server = 'SUPABASE_SERVER_ERROR';

  /// 그 밖의 HTTP 상태.
  static const String badResponse = 'SUPABASE_BAD_RESPONSE';

  /// 2xx 인데 `Date` 머리가 없거나 읽을 수 없다.
  static const String noDate = 'SUPABASE_DATE_MISSING';

  /// 망 · 시간 초과.
  static const String network = 'SUPABASE_NETWORK';

  static const Set<String> values = <String>{
    notConfigured,
    badConfig,
    vault,
    unauthorized,
    server,
    badResponse,
    noDate,
    network,
  };
}

/// 🆕 v1.31(01 §40 · K240 · E11k-d2) — Supabase 로그인 · 세션 고유 실패(도메인 `supabase_auth_result` · data_sync
/// `supabase/supabase_auth.dart` `SupabaseAuthFailure` 12 가운데 6 · 🔴 타입 이름 ≠ 엔진).
/// 🔴 전송 6(`notConfigured` · `badConfig` · `unauthorized` · `server` · `badResponse` · `network`) = [SupabaseTimeResultCodes] 글자 한 벌
///    (같은 사건 · 새 글자 0) · 🔴 금고 = 여기 [vault](읽기 «또는 쓰기» 실패 — 시각 쪽 `SUPABASE_VAULT_UNREADABLE` 은 읽기만이라 다른 뜻).
/// 🔴 `supabaseSignIn` 결과에 나오는 것 = [badInput] · [invalidCredentials] · [rateLimited] · [vault] + 전송 · [notSignedIn] · [sessionLost] =
///    토큰 갱신 축(엔진 깨어남 · S07 · 로그).
abstract final class SupabaseAuthResultCodes {
  /// 이메일 · 비밀번호 꼴이 아니다(빈칸 등) — 망에 가지 않았다.
  static const String badInput = 'SUPABASE_AUTH_INPUT_INVALID';

  /// 로그인한 적이 없다(금고에 새로고침 토큰 없음) — 망에 가지 않았다.
  static const String notSignedIn = 'SUPABASE_NOT_SIGNED_IN';

  /// 이메일 · 비밀번호가 틀렸다(로그인 400).
  static const String invalidCredentials = 'SUPABASE_CREDENTIALS_REJECTED';

  /// 세션을 잃었다(새로고침 400 — 만료 · 재사용 · 철회) — 금고 칸을 지웠다 · 다시 로그인.
  static const String sessionLost = 'SUPABASE_SESSION_LOST';

  /// 과속(429).
  static const String rateLimited = 'SUPABASE_RATE_LIMITED';

  /// 금고를 읽거나 쓰지 못했다.
  static const String vault = 'SUPABASE_AUTH_VAULT_FAILED';

  static const Set<String> values = <String>{
    badInput,
    notSignedIn,
    invalidCredentials,
    sessionLost,
    rateLimited,
    vault,
  };
}

/// 🆕 v1.39(01 §48 · K349 ④ · 13 §8 R267 L4 · 리뷰 3차 C-2 = I-U2) — o_07 공개 가입 확인(도메인 `supabase_signup_result`).
/// 🔴 자리 = `supabaseSignIn`(o_07 ③) 로그인 통과 뒤 `GET /auth/v1/settings`(공개 키 · 인증 0) 1회 — `disable_signup == true` 만 통과.
///    열림 = [signupOpen](o_07 = VERIFIED 아님 · IN_PROGRESS 그대로 · 새로고침 토큰은 금고에 둔다 — 로그인 자체는 성공) · 읽기 실패 =
///    `SupabaseTimeResultCodes` 전송 글자 그대로(새 글자 0) · 칸 없음 · 꼴 아님 = `SUPABASE_BAD_RESPONSE`(모름 = 통과 아님).
/// 🔴 끄는 곳 = 발주자(Supabase 대시보드 «Allow new users to sign up» · 17 절차서 §3-7 · ✅ 2026-11-24) — 앱은 확인만 한다(설정 바꾸기 0).
abstract final class SupabaseSignupResultCodes {
  /// 공개 가입이 열려 있다(아무나 계정을 만들어 리스 · 읽기 모델을 넘볼 수 있다).
  static const String signupOpen = 'SUPABASE_SIGNUP_OPEN';

  static const Set<String> values = <String>{signupOpen};
}

/// 리스 RPC 거부(도메인 `lease_rpc_result` · RPC 표 = 01 §6-4 · `schema/supabase_rpc.dart` · 본문 = E11k-e · 🔴 SQL 이 이 글자를
/// 돌려주고 data_sync 클라이언트가 그대로 읽는다 — 클라이언트가 HTTP 상태로 코드를 짓지 않는다).
abstract final class LeaseRpcResultCodes {
  /// 다른 기기가 유효한 리스를 가졌다(`lease_claim` CAS 실패).
  static const String heldByOther = 'LEASE_HELD_BY_OTHER';

  /// 이 기기가 보유자가 아니거나 epoch 가 다르거나 만료됐다(`lease_renew` · 자발 반납).
  static const String lost = 'LEASE_LOST';

  /// 이 기기를 쓸 수 없다(이 인증 사용자의 기기가 아님 · `REVOKED` · `RETIRED`).
  static const String deviceNotEligible = 'LEASE_DEVICE_NOT_ELIGIBLE';

  /// 첫 클레임인데 복구 코드 해시가 없다(M4-3 — 첫 클레임과 같은 트랜잭션에서 발급).
  static const String recoveryCodeRequired = 'RECOVERY_CODE_REQUIRED';

  /// 복구 코드가 맞지 않는다(`lease_revoke` · 🔴 쓴 코드도 여기 — 같은 트랜잭션에서 새 해시로 갈아 끼워 옛 코드는 «틀림»이 된다).
  static const String recoveryCodeInvalid = 'RECOVERY_CODE_INVALID';

  static const Set<String> values = <String>{
    heldByOther,
    lost,
    deviceNotEligible,
    recoveryCodeRequired,
    recoveryCodeInvalid,
  };
}

/// 🆕 v1.37(01 §46 · K324 · K325 · 01 §8 미결 218 ⓕ) — X1 계획 이전 리스 넘김 거부(도메인 `lease_handover_result` · 🔵 **엔진 예고** —
/// SQL 본문 · 클라이언트 = 01 §8 미결 228). `device_retire` · `lease_claim`(티켓 논스) 이 돌려준다.
/// 🔴 [LeaseRpcResultCodes] 와 따로 둔다 — 그 사전 5 = 지금 SQL(E11k-e2) 이 쓰는 글자 전부라는 data_sync 부트스트랩 대조 시험이
///    서 있다(K291 결 · 엔진이 SQL 을 지을 때 두 사전 합집합으로 시험을 넓힌다). 공용 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는
///    [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다.
abstract final class LeaseHandoverResultCodes {
  /// 티켓이 있어야 한다(`device_retire` 에 논스 해시 없음 · 넘김 대기 중 `lease_claim` 에 논스 없음).
  static const String ticketRequired = 'LEASE_TICKET_REQUIRED';

  /// 논스가 대기 티켓 해시와 맞지 않는다.
  static const String ticketInvalid = 'LEASE_TICKET_INVALID';

  /// 대기 티켓이 만료됐다(서버 `now()` 기준) — 옛 폰이 `device_retire` 를 다시 불러 티켓을 바꾸거나(재발급) 비상 경로.
  static const String ticketExpired = 'LEASE_TICKET_EXPIRED';

  static const Set<String> values = <String>{
    ticketRequired,
    ticketInvalid,
    ticketExpired,
  };
}

/// 🆕 v1.38(01 §47 · K333) — 읽기 모델 push RPC 고유 거부(도메인 `read_model_push_result` · RPC 표 = `schema/supabase_rpc.dart`
/// `ReadModelPushRpc*` · 본문 = 엔진 E11l2 · 01 §8 미결 222 ⓑ). 🔴 리스 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는
/// [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다(v1.37 [LeaseHandoverResultCodes] 결).
abstract final class ReadModelPushResultCodes {
  /// 표 이름이 `ReadModelTables` 에 없다(SQL 은 표 이름을 그 목록과만 맞춘다 — 동적 SQL 은 목록 안 이름만).
  static const String tableUnknown = 'READ_MODEL_TABLE_UNKNOWN';

  /// 행 묶음을 넣지 못했다(JSON 배열 아님 · 기본 키 · `mode` · 형 · check 위반) — 🔴 그 호출 전부 0행(부분 반영 0).
  static const String rowsInvalid = 'READ_MODEL_ROWS_INVALID';

  static const Set<String> values = <String>{tableUnknown, rowsInvalid};
}

/// 🆕 v1.40(01 §49 · 01 §8 미결 229 · 13 §8 R270) — 운영 폰 공유 표 push RPC 고유 거부(도메인 `ops_push_result` · RPC 표 =
/// `schema/supabase_rpc.dart` `OpsPushRpc*` · `OpsPushTables` · 본문 = data_sync `sql/supabase_ops_push_rpc.sql`).
/// 🔴 리스 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)는 [LeaseRpcResultCodes] 그대로 — 다시 적지 않는다(v1.38
///    [ReadModelPushResultCodes] 결) · 읽기 모델 push 거부(`READ_MODEL_*`)와 다른 글자 — 표 무리가 다르다(조치는 같다 = 앱 ↔ 서버 표 어긋남).
abstract final class OpsPushResultCodes {
  /// 표 이름이 `OpsPushTables.all` 에 없다(표마다 정적 SQL — 목록 밖 이름 = 0행).
  static const String tableUnknown = 'OPS_PUSH_TABLE_UNKNOWN';

  /// 행 묶음을 넣지 못했다(JSON 배열 아님 · 형 · 기본 키 · not null · check · 참조 위반 · 같은 키 두 번 · `command_ack` 남의 명령 ·
  /// 한 호출에 같은 명령 두 번) — 🔴 그 호출 전부 0행(부분 반영 0).
  static const String rowsInvalid = 'OPS_PUSH_ROWS_INVALID';

  static const Set<String> values = <String>{tableUnknown, rowsInvalid};
}
```

---

## `packages/domain_contracts/lib/src/labels/verdict_codes.dart`

```dart
// 01 §3-3 — X2 재판정 `verdict_code` 5종.
// + `planned_work.kind` 3종(01 §6-3 DDL 주석) · 결측 사유 코드 2종(01 §2-4 `PerfPoint.gapReasonCode`).
//
// 🔴 세 묶음을 한 파일에 두는 이유: 전부 X2(재개·계획 작업·결측 복원)의 코드 축이고,
//    `contracts_inventory.md` §6 의 `labels/` 파일 배치가 X2 전용 파일을 하나만 둔다.
// 🔴 문구는 엔진이 만든다 — `ResumeItem.verdictLabel`·`DataGapRow.label` 에 실려 온다.

/// X2 재판정 결과 코드(01 §3-3 · `planned_work.verdict_code`·`planned_work_transition.verdict_code`).
abstract final class VerdictCodes {
  /// 재판정 후 실행(수량·가격이 재개일 기준으로 바뀔 수 있다).
  static const String executedAsReevaluated = 'EXECUTED_AS_REEVALUATED';

  /// 창을 지나 만료.
  static const String expired = 'EXPIRED';

  /// 보수 모드 등으로 다음 정기 회차에 자리를 넘김.
  static const String superseded = 'SUPERSEDED';

  /// 차단 플래그로 진행 불가.
  static const String blocked = 'BLOCKED';

  /// 소급 복원 불가.
  static const String unrecoverable = 'UNRECOVERABLE';

  /// 전량 5종.
  static const Set<String> values = <String>{
    executedAsReevaluated,
    expired,
    superseded,
    blocked,
    unrecoverable,
  };
}

/// `planned_work.kind`(01 §6-3 DDL) — 🆕 v1.22(01 §31 · K18) 5종: P0S 판 = `MONTHLY_PLAN` · `SEASONAL_WINDOW` · `CARRY_OVER`
/// (엔진 `ResumeWorkKinds` · `resume/resume_judge.dart:39` · 🔴 `CARRY_OVER` = 행 등록 0 · 원장 파생 — 재개 판정 항목의 kind 로만 ·
/// ds `planned_work_store.dart:5`) · 옛 `DEFER_COUNT` · `SPLIT_LEG` = P0S 미사용(지우지 않는다 · v1.19 K22 ⓕ) ·
/// DDL 주석 = 엔진 재생성 PR(01 §31 K61).
///
/// 🔴 `SPLIT_LEG` 는 이름만 있고 **분할 집행 진도 필드는 계약에 없다**(01 §2-2 · M2-8 C-11) —
///    화면이 「n일차」·「이월 n주」를 만들지 않는다.
abstract final class PlannedWorkKindCodes {
  /// 계절 진입 창(슬리브 A).
  static const String seasonalWindow = 'SEASONAL_WINDOW';

  /// 보류 회차 카운트.
  static const String deferCount = 'DEFER_COUNT';

  /// 분할 집행 leg.
  static const String splitLeg = 'SPLIT_LEG';

  /// 🆕 v1.22 — 월말 계획(P0S).
  static const String monthlyPlan = 'MONTHLY_PLAN';

  /// 🆕 v1.22 — 이월 의도(P0S · 행 등록 0 · 재개 판정 항목의 kind 로만).
  static const String carryOver = 'CARRY_OVER';

  /// 전량 5종(🆕 v1.22 +2).
  static const Set<String> values = <String>{
    seasonalWindow,
    deferCount,
    splitLeg,
    monthlyPlan,
    carryOver,
  };
}

/// 성과 시계열의 결측 사유 코드 3종(01 §2-4 · §13-3 `PerfPoint.gapReasonCode`).
///
/// 🔴 `PerfPoint.value == null` 은 **결측이며 보간하지 않는다**(C-10). 이 코드는 «왜 비었는가»다.
abstract final class GapReasonCodes {
  /// `equity_snapshot` 결측.
  static const String equitySnapshotMissing = 'EQUITY_SNAPSHOT_MISSING';

  /// 재개 갭 구간.
  static const String resumeGap = 'RESUME_GAP';

  /// 🆕 v1.3 — 모의 구간(`SegmentKind.simExcluded`) 안의 점. 합산하지 않아 값이 없다.
  static const String simExcluded = 'SIM_EXCLUDED';

  /// 🆕 v1.14(E8a · 설계 13 §8 R23 D4 · R25 G4) — `data_gap.reason_code` 의 시세 결측 5종(엔진 `DataGapCause` 와 같은
  /// 글자 · core 시험이 맞댄다). 세션인데 행이 없다.
  static const String missingRow = 'MISSING_ROW';

  /// 🆕 v1.14 — 종가 ≤ 0.
  static const String nonPositivePrice = 'NON_POSITIVE_PRICE';

  /// 🆕 v1.14 — 거래량 < 0.
  static const String negativeVolume = 'NEGATIVE_VOLUME';

  /// 🆕 v1.14 — 전 세션 대비 |변동| ≥ 60%(FR-112).
  static const String priceJump = 'PRICE_JUMP';

  /// 🆕 v1.14 — 전 종목이 같은 날 함께 비었다(캘린더 의심 · 표 자동 수정 금지).
  static const String calendarSuspect = 'CALENDAR_SUSPECT';

  /// 🆕 v1.22(01 §31 · K66) — 모의 가상 체결 봉 없음(`data_gap.reason_code` · ds `local/sim_ledger_view.dart:19` ·
  /// dataset `sim_fill_bar` — DDL 주석 = 엔진 재생성 PR).
  static const String simBarMissing = 'SIM_BAR_MISSING';

  /// 전량 9종(🆕 v1.22 +1).
  static const Set<String> values = <String>{
    equitySnapshotMissing,
    resumeGap,
    simExcluded,
    missingRow,
    nonPositivePrice,
    negativeVolume,
    priceJump,
    calendarSuspect,
    simBarMissing,
  };
}

/// 🆕 v1.22(01 §31 · K49) — 재개 항목 판정 사유 · 매매 멈춤 사유(도메인 `resume_reason` · core `ResumeReasonCodes` ·
/// `resume/resume_judge.dart:51-95` 15 · 문구 = `resume_text.dart` · 🔴 타입 이름 ≠ 엔진 — `ambiguous_import`).
/// 축 = `ResumeGateRow.reasonCode` · 계절 선택 거부 `SafetyActionResult.reasonCode`(멈춤 사유 7).
abstract final class ResumeItemReasonCodes {
  /// 기한을 넘겼다.
  static const String duePassed = 'DUE_PASSED';

  /// 안내 모드 재개 조건 결정 대기.
  static const String advisoryPending = 'ADVISORY_PENDING';

  /// RECOVERY_FULL — 매매 없는 안전 정지.
  static const String safetyStop = 'SAFETY_STOP';

  /// RECOVERY_DRY — 관찰 회차.
  static const String observing = 'OBSERVING';

  /// 대사 불일치가 남았다.
  static const String reconMismatch = 'RECON_MISMATCH_REMAINS';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'UNKNOWN_ORDERS_REMAIN';

  /// RESERVED · SUBMITTING 잔류.
  static const String residualOrders = 'RESIDUAL_ORDERS_REMAIN';

  /// 계절 A 진입 — 사람 결정 대기.
  static const String humanDecision = 'HUMAN_DECISION';

  /// 보수 모드 — 다음 정기 회차.
  static const String conservativeDefer = 'CONSERVATIVE_DEFER';

  /// 재판정 결과 할 일 없음.
  static const String reevaluatedEmpty = 'REEVALUATED_EMPTY';

  /// 재판정 값으로 다음 주문 회차에 위임.
  static const String reevaluated = 'REEVALUATED';

  /// 사람이 건너뜀.
  static const String humanSkip = 'HUMAN_SKIP';

  /// 사람이 축소 진입을 고름.
  static const String humanReduced = 'HUMAN_REDUCED';

  /// 사람이 그대로를 고름.
  static const String humanAsIs = 'HUMAN_AS_IS';

  /// 재판정 포트가 실패했다(항목 그대로 · 플래그 유지).
  static const String reevaluationFailed = 'REEVALUATION_FAILED';

  static const Set<String> values = <String>{
    duePassed,
    advisoryPending,
    safetyStop,
    observing,
    reconMismatch,
    unknownOrders,
    residualOrders,
    humanDecision,
    conservativeDefer,
    reevaluatedEmpty,
    reevaluated,
    humanSkip,
    humanReduced,
    humanAsIs,
    reevaluationFailed,
  };
}

/// 🆕 v1.22 — 계절 선택 거부(도메인 `seasonal_choice_result` · core `SeasonalChoiceCodes` · `resume_judge.dart:99` 4).
abstract final class SeasonalChoiceResultCodes {
  /// `decision_id` 없음(구현이 짓는다 — 화면 경로에서는 나오지 않아야 한다).
  static const String decisionMissing = 'SEASONAL_DECISION_MISSING';

  /// 계절 A 진입 항목이 아님.
  static const String notSeasonalEntry = 'SEASONAL_NOT_ENTRY';

  /// 사람 결정을 기다리는 상태가 아님(종단 등).
  static const String notPending = 'SEASONAL_NOT_PENDING';

  /// 기한을 넘겼다(1월 판정 날 자동 만료).
  static const String pastDue = 'SEASONAL_PAST_DUE';

  static const Set<String> values = <String>{
    decisionMissing,
    notSeasonalEntry,
    notPending,
    pastDue,
  };
}

/// 🆕 v1.22 — `planned_work` 전이 거부(도메인 `planned_work_reject` · core `PlannedWorkCodes` ·
/// `resume/planned_work_machine.dart:20` 6 · 계약 이름 = 축을 드러낸다).
abstract final class PlannedWorkRejectCodes {
  /// 같은 상태로의 전이.
  static const String unchanged = 'PLANNED_WORK_UNCHANGED';

  /// 종단 상태에서의 전이.
  static const String terminal = 'PLANNED_WORK_TERMINAL';

  /// 기한이 지났다.
  static const String pastDue = 'PLANNED_WORK_PAST_DUE';

  /// 아직 때가 아니다.
  static const String notDue = 'PLANNED_WORK_NOT_DUE';

  /// 허용되지 않는 전이.
  static const String illegal = 'PLANNED_WORK_ILLEGAL';

  /// 그런 작업이 없다.
  static const String unknown = 'PLANNED_WORK_UNKNOWN';

  static const Set<String> values = <String>{
    unchanged,
    terminal,
    pastDue,
    notDue,
    illegal,
    unknown,
  };
}
```

---

## `packages/domain_contracts/lib/src/navigation/app_links.dart`

```dart
// 01 §4-4 «내비게이션 계약» — 🆕 계약 v1.1(2026-09-17 · §8 미결 36 해소).
//
// 한 문장: **링크는 데이터로 온다.** 화면은 링크 문자열을 만들지도 해석하지도 않는다 —
// DTO 가 실어 온 문자열을 그대로 [AppLinkOpener.open] 에 넘긴다. 여는 일(라우트 테이블 ·
// 가드 리다이렉트 · 핸드북 뷰어)은 셸(M8)의 몫이다(04 §1-2 「라우트 테이블은 정적으로 전
// 라우트를 등록하고 «부재»는 가드 리다이렉트」).
//
// 🔴 화면 규칙 4조
//   ① 링크 필드가 null 이면 그 진입점은 **부재**다(비활성 버튼·자리표시자를 그리지 않는다).
//   ② 링크 문자열을 파싱·분기하지 않는다(`startsWith('aaq://m5')` 같은 코드 = 판정).
//   ③ [AppRoutes] 의 **패턴**(`:param` 이 든 것)에 값을 끼워 링크를 조립하지 않는다 —
//      파라미터가 든 링크는 언제나 엔진이 완성해서 준다.
//   ④ 파라미터 없는 고정 목적지는 화면 명세가 그 버튼을 **명시한 경우에만** [AppRoutes]
//      상수를 그대로 넘길 수 있다. 목록에 없는 목적지가 필요하면 멈추고 질문한다.
//      🆕 v1.3 — [AppNavActions].* 도 같다.
// 🔴 엔진·픽스처 규칙: `aaq://` 링크는 전부 [AppRoutes.all] 의 패턴 하나와 일치해야 한다
//    (계약 테스트 C-33). `handbook://` 는 핸드북 앵커이며 도착지는 `HandbookPage` 다.
// 🔴 이 파일은 순수 Dart 다(Flutter import 없음 — 01 §1-1). 구현체는 `ui_shell` 이 준다.

/// 화면이 링크를 여는 **유일한** 창구. 구현은 셸(M8)이 주입한다.
///
/// 화면 패키지는 `Provider<AppLinkOpener>((_) => throw UnimplementedError(...))` 를 두고
/// 조립 앱(`apps/*/lib/main.dart`)이 override 한다(01 §4-1 주입 규약과 같은 모양).
/// 테스트는 넘어온 문자열을 기록하는 가짜 구현으로 «DTO 의 링크가 그대로 전달되는가»를 본다.
abstract interface class AppLinkOpener {
  /// [link] 는 DTO 가 준 문자열 **그대로**다(`aaq://…` · `handbook://…`).
  void open(String link);
}

/// 링크의 스킴 2종.
abstract final class AppLinkSchemes {
  /// 앱 안의 화면.
  static const String app = 'aaq';

  /// 핸드북 앵커(`ReasonChip.detailDeepLink` 의 도착지).
  static const String handbook = 'handbook';

  static const Set<String> values = <String>{app, handbook};
}

/// 🆕 v1.3 · 01 §13-7 — **동작 링크**. 목적지가 아니라 «지금 화면을 닫는다»는 뜻이다.
/// 셸(M8)의 [AppLinkOpener] 구현이 뜻을 정한다: 닫을 화면이 있으면 닫고,
/// 없으면(링크로 바로 들어온 경우) 그 플랫폼의 첫 화면으로 간다.
/// 🔴 동작 링크는 `back` 하나다 — 더하는 것은 계약 버전 사안이다.
/// 🔴 화면 명세가 그 버튼을 **명시한 경우에만** 쓴다(규칙 ④ 와 같다).
/// 🔴 [AppRoutes.all] 에 넣지 않는다(목적지가 아니다). DTO·픽스처에 실리지 않는다
///    (C-33 이 검사한다).
abstract final class AppNavActions {
  /// 「돌아가기」 — 지금 화면을 닫는다.
  static const String back = 'aaq://nav/back';

  /// 전량 1종.
  static const Set<String> all = <String>{back};
}

/// 앱 라우트 **정본 목록**. 셸은 [all] 을 전량 라우트 테이블에 등록한다(04 §1-2).
///
/// `:name` 세그먼트는 파라미터다(빈 문자열 불가). 고정 세그먼트가 파라미터보다 먼저
/// 일치한다(`aaq://report/archive` 는 `reportArchive` 이지 `reportMonthly` 가 아니다).
/// 🔴 목록은 회차마다 **M2 가** 늘린다 — 화면·엔진이 이름을 지어 쓰지 않는다.
abstract final class AppRoutes {
  // ── M6 매매일지·안내·원장(02) ─────────────────────────────────────────────
  /// `J-1` 매매일지 타임라인.
  static const String journalTimeline = 'aaq://journal/timeline';

  /// `J-2` 거래 상세 — `TradeJournalEntry.detailDeepLink` 가 완성해서 준다.
  static const String journalDecision = 'aaq://journal/decision/:decisionId';

  /// `J-3` 사전 저널 작성(폰 전용) — `DecisionDetailVm.journalLink` 등이 준다.
  /// 🆕 v1.35(01 §44 · K296) — 🔴 `:decisionId` 의 값 = **저널 id**(`decision_journal.journal_id` · 안전 동작의 `decision_id` 와 한 벌 ·
  /// 이름은 그대로) — 엔진이 링크에 싣는 불투명 id(`JOURNAL_MISSING` 배너 · 차단 보드 · M5 게이트 · J-2 «저널 작성») · 화면 조립 0.
  static const String journalDraft = 'aaq://journal/draft/:decisionId';

  /// `J-3` 사전 저널 **읽기**(`J-3R` · 🆕 v1.2) — `DecisionDetailVm.journalLink`(작성됨)가 준다.
  /// 등록 = 전 플랫폼(`all`) · 본문 = Android·iOS `JournalReadView` · 웹 = Q-D 전 셸 «부재» 가드(01 §12-2 · 04 §1-2).
  static const String journalRead = 'aaq://journal/read/:decisionId';

  /// 🆕 v1.5(01 §15-3 · §8 미결 49) — `J-1` 매매일지 타임라인을 **회차 조건으로** 연다.
  /// `RebalanceEvent.journalTimelineLink` 가 완성해서 준다(`S7-6b` 하단 버튼).
  /// 셸 본문 = `JournalTimeline(key: ValueKey(id), rebalanceEventId: id)` · 등록 = 전 플랫폼 ·
  /// 웹 가드 = `journalTimeline` 과 같다. `journal/decision`·`draft`·`read` 와 세그먼트 수가 같고
  /// 둘째 고정 세그먼트로 갈린다(v1.2 `journalRead` 선례) · `journalTimeline` 과는 세그먼트 수가 다르다.
  static const String journalRebalance =
      'aaq://journal/rebalance/:rebalanceEventId';

  /// `J-4` 사후 blind 리뷰.
  /// 🆕 v1.7 — 셸 본문 = `JournalBlindReview()`(대기 목록의 머리 카드 · 01 §16).
  static const String journalBlindReview = 'aaq://journal/blind-review';

  /// `J-5` UNKNOWN 해소 보드 — `JournalTimelineBadge.deepLink` 가 준다.
  static const String journalUnknownBoard = 'aaq://journal/unknown-board';

  /// 🆕 v1.8(01 §17) — `H6-1` 보유현황(`HoldingsOverview()`). 등록 = 전 플랫폼 · 본문 = Android·iOS · 웹 = Q-D 전 셸 «부재» 가드.
  static const String holdingsOverview = 'aaq://holdings/overview';

  /// 🆕 v1.8 — `H6-2` 종목 상세(`HoldingDetail(holdingId:)`) — `HoldingRow.detailDeepLink` 가 준다(엔진 완성).
  static const String holdingsDetail = 'aaq://holdings/detail/:holdingId';

  /// 🆕 v1.8 — `H6-3` 슬리브·비중(`HoldingsAllocation()`) — `HoldingsOverviewVm.allocationLink` · 홈 블록 4 탭(R13).
  static const String holdingsAllocation = 'aaq://holdings/allocation';

  /// `A-1` 안내 인박스.
  static const String adviceInbox = 'aaq://advice/inbox';

  /// `A-2` 안내 상세.
  static const String adviceDetail = 'aaq://advice/detail/:adviceId';

  /// `A-3` 수기 체결 기록(폰 전용). 🆕 v1.12(01 §21 · §8 미결 52 ①) — `:adviceId` · `AdviceAction.deepLink`(RECORD)가
  /// 완성해서 준다. 등록 = 전 플랫폼 · 본문 = Android `ManualFillForm(adviceId:)`(operator 라이브러리) · iOS 뷰어 셸 =
  /// «폰에서만» 부재 안내 · 웹 = `ui_journal` 없음(TARGETS T-3) — 셸 가드(선례 `journalDraft`).
  /// 🔵 v1.12 교체(구 `aaq://advice/fill` — 파라미터 없는 `A-3` 은 02 에 없다 · 안내 밖 매매 = `M5-6`).
  static const String adviceFill = 'aaq://advice/fill/:adviceId';

  /// 🆕 v1.12(01 §21 · 미결 52 ②) — `A-4` 미이행 사유 1탭(폰 전용) · `AdviceAction.deepLink`(SKIP) ·
  /// 본문 `AdviceSkipForm(adviceId:)` · 가드 = [adviceFill] 과 같다. `advice/fill`·`detail` 과 세그먼트 수가 같고
  /// **둘째 고정 세그먼트**로 갈린다(v1.2 `journalRead` 선례).
  static const String adviceSkip = 'aaq://advice/skip/:adviceId';

  /// 안내 이력.
  static const String adviceHistory = 'aaq://advice/history';

  /// `L-3` 원장 실사(폰 전용). 🆕 v1.12(01 §21 · 미결 52 ⑧ · K7 · K36 ⓐ) — 그 달(`yyyy-MM`) · 그 계좌 별칭
  /// (🔴 계좌 전체번호 아님)의 정기 실사. 엔진이 완성해서 준다(`LedgerTrustBadge.actionDeepLink` · `SELF_AUDIT_DUE`
  /// 알림·플래그 `clearDeepLink` · `H-02` 리듬 행 · `LedgerDiffRow.actionLink`(canonSelfReport) ·
  /// `SelfReportResult.nextAccountLink`). 본문 = `SelfReportForm(yyyyMm:, accountAlias:)` · 가드 = [adviceFill] 과 같다.
  /// `'/'` 로 쪼갠 조각 수(6)가 `ledger/*` 다른 라우트와 달라 겹치지 않는다. 🔵 v1.12 교체(구 `aaq://ledger/self-report`).
  /// 🔴 별칭에 `/`·`?`·`#` 가 없게 하는 것은 엔진 의무다(C-46 ⑮).
  static const String ledgerSelfReport =
      'aaq://ledger/self-report/:yyyyMm/:accountAlias';

  /// 🆕 v1.16(01 §25 · K3 · K25) — `O-04` ⑥ 투자 안내 갈래 시작 상태 선언 = `L-3` 폼 재사용(`SelfReportPurpose.simOpening` ·
  /// 세션 없음 · `yyyyMm` 없음 · 계좌 별칭 = 그 계좌). 들어오는 링크 = `OnboardingFinishStage.link`(엔진 완성).
  /// 본문 = `ui_journal` 의 `L-3` simOpening 갈래(01 §8 미결 153 — 그 카드 전까지 셸 = 빈 자리).
  /// `'/'` 조각 수(5)가 `ledger/execution-gap/:yyyyMm` 과 같고 **둘째 고정 조각**으로 갈린다.
  static const String ledgerSimOpening =
      'aaq://ledger/sim-opening/:accountAlias';

  /// 원장 신뢰 등급 설명.
  static const String ledgerTrust = 'aaq://ledger/trust';

  /// 🆕 v1.12(01 §21 · K27) — `L-1` 차이 상세(읽기 · `LedgerDiffs()`). 홈 블록 6 탭 = 이 상수(04 §4-5 · 규칙 ④).
  /// 등록 = 전 플랫폼 · 본문 = Android·iOS(`rm_ledger_diff` v1 필수) · 웹 = Q-D 전 셸 «부재» 가드.
  static const String ledgerDiffs = 'aaq://ledger/diffs';

  /// 🆕 v1.12(01 §21 · K27) — `L-2` 정정 이력·감사(읽기 · `LedgerRepairs()`). `L-1` 하단 = 이 상수(02 §5-2 · 규칙 ④).
  /// 등록 = 전 플랫폼 · 본문 = **Android 만** · iOS·웹 = 셸 «폰에서만» 부재 안내(`rm_ledger_repair` 없음 · 01 §8 미결 117).
  static const String ledgerRepairs = 'aaq://ledger/repairs';

  /// `S7-10` 이행 갭 — 🆕 v1.6 주석: `S7-10` 은 **M7(03 §14-b) 화면**이다 · 이 묶음 표기는 역사적(H63).
  /// 인자 없는 진입(「계획」 탭 ⑤) = 엔진 기본 달 · 셸 본문 = `ExecutionGapScreen()`.
  static const String ledgerExecutionGap = 'aaq://ledger/execution-gap';

  /// 🆕 v1.6(01 §15-4 · K1) — `S7-10` 의 **그 달**(`yyyy-MM`). `MonthlyReport` ⑧ `D3_EXECUTION.detailDeepLink`
  /// 를 엔진이 완성해서 준다. 셸 본문 = `ExecutionGapScreen(key: ValueKey(m), yyyyMm: m)` — **두 라우트 · 한 위젯**
  /// (v1.5 `journalRebalance` 다음 두 번째 사례). 세그먼트 수가 달라 [ledgerExecutionGap] 과 겹치지 않는다.
  static const String ledgerExecutionGapMonth =
      'aaq://ledger/execution-gap/:yyyyMm';

  // ── M7 성과·리밸런싱·플래너(03) ───────────────────────────────────────────
  /// `S7-1b` 리포트 아카이브.
  static const String reportArchive = 'aaq://report/archive';

  /// 세후 사다리 단독 보기 — 03 §12 `S7-7` 세후 카드와 같은 `AfterTaxLadder`(03 에 별도 화면 ID 없음).
  /// 🆕 v1.4 주석 정정 — 구 «`S7-7` 세후 사다리»·«`S7-8` 연간 리뷰»는 오기였다
  /// (`S7-7` = 12월 연간 리뷰 · `S7-8` = X2 재개 리포트 읽기 사본 · 03 §2).
  /// 🆕 v1.6 — 03 에 화면 없음 · R12 밖 · `S7-7` 세후는 VM `afterTax` 블록.
  static const String reportAfterTax = 'aaq://report/aftertax';

  /// `S7-7` 12월 연간 리뷰 패키지. 🆕 v1.6 — 셸 본문 = `AnnualReviewScreen()`.
  static const String reportAnnual = 'aaq://report/annual';

  /// `S7-1` 월간 리포트(`yyyy-MM`).
  static const String reportMonthly = 'aaq://report/:yyyyMm';

  /// 🆕 v1.4(01 §14-9) — `S7-9` 목표 경로(`yyyy-MM`) — `MonthlyReport.goalDeepLink` 가 완성해서 준다.
  /// 세그먼트 수가 [reportMonthly] 와 달라 겹치지 않는다(고정 `goal` + 파라미터).
  static const String reportGoalPath = 'aaq://report/goal/:yyyyMm';

  /// `S7-2` 성과 탐색(열람 게이트 뒤).
  static const String performanceExplore = 'aaq://performance/explore';

  /// `S7-3` 드로다운·TUW 컨텍스트.
  static const String performanceDrawdown = 'aaq://performance/drawdown';

  /// `S7-3b` 슬리브 기여 분해.
  static const String performanceContribution =
      'aaq://performance/contribution';

  /// `S7-4` 납입 플래너.
  /// 🆕 v1.4(01 §14-1) — **operator 전용 화면**(`package:ui_analytics/planner.dart` · 배럴 밖).
  /// viewer 셸도 [all] 대로 등록하되 목적지는 «폰에서만 쓸 수 있습니다» 부재 안내다(셸 몫 · 01 §14 ·
  /// 선례 = `journalDraft` 의 iOS 셸 가드).
  /// ⏸ `planWithdrawal`(S7-5) 은 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor 에서 더한다(01 §14-15 · §15-3).
  static const String planDeposit = 'aaq://plan/deposit';

  // M7 묶음 — `all` 에서도 rebalancePreview 앞
  /// 🆕 v1.6(01 §15-4 · K5) — `S7-6a` 리밸런싱 회차 타임라인(`RebalanceTimelineScreen()`).
  static const String rebalanceHistory = 'aaq://rebalance/history';

  /// `S7-6c` 리밸런싱 미리보기. 🆕 v1.6 — 셸 본문 = `RebalancePreviewScreen()`.
  static const String rebalancePreview = 'aaq://rebalance/preview';

  /// `S7-6b` 리밸런싱 회차 상세 — `DecisionDetailVm.rebalanceLink` 등이 준다.
  static const String rebalanceEvent =
      'aaq://rebalance/event/:rebalanceEventId';

  // ── M8 셸·운영·온보딩 · M9 설정(04 · 05) ─────────────────────────────────
  /// 🆕 v1.16(01 §25 · K28) — `O-00` 첫 실행(`OnboardingStart()` · `ui_shell`). 들어오는 길 = 첫 실행 판정(조립 앱 · 06 M4-11).
  /// 🔴 아래 고정 6 은 [all] 에서 [onboardingStep] **앞**이다(고정 조각이 파라미터보다 먼저 일치 — `report/archive` 선례 · C-33 ⑦).
  ///    엔진 의무 = `stepId` 꼴 `^[orv]_[0-9]{2}[a-z]?$`(고정 조각과 겹치지 않는다 · C-50 ⑥).
  static const String onboardingStart = 'aaq://onboarding/start';

  /// 🆕 v1.16 — `O-00b` 운영 방식 선택 · 들어오는 링크 = `OnboardingTrackCard.deepLink`(fresh) · `RestartVm.branches`(갭 7일).
  static const String onboardingModePick = 'aaq://onboarding/mode';

  /// 🆕 v1.16 — `O-01` 단계 목록 · 들어오는 링크 = `OnboardingModeChoiceVm.nextDeepLink`.
  static const String onboardingSteps = 'aaq://onboarding/steps';

  /// 🆕 v1.16 — `O-04` 마무리 · 들어오는 링크 = `OnboardingStepsVm.finishDeepLink`.
  static const String onboardingFinish = 'aaq://onboarding/finish';

  /// 🆕 v1.16 — `R-01` 기존 계정에서 다시 시작 · 들어오는 링크 = `OnboardingTrackCard.deepLink`(reconnect).
  static const String onboardingRestart = 'aaq://onboarding/restart';

  /// 🆕 v1.16 — `V-01` 조회 전용 QR 페어링(뷰어) · 들어오는 링크 = `OnboardingStartVm.viewerTrack.deepLink`.
  static const String onboardingPairing = 'aaq://onboarding/pairing';

  /// 온보딩·재연결 단계(`o_00`~ · `r_00`~). 🆕 v1.16 — 들어오는 링크 = `OnboardingStep.detailDeepLink`(`O-02`).
  static const String onboardingStep = 'aaq://onboarding/:stepId';
  static const String opsArchive = 'aaq://ops/archive';
  static const String opsMaintenance = 'aaq://ops/maintenance';
  static const String opsWatchdog = 'aaq://ops/watchdog';

  /// 🆕 v1.12(01 §21 · K43) — `H-02` 운영 리듬 표(`OpsRhythm()` · `ui_shell`). 홈 블록 7·8 탭·«더 보기» = 이 상수
  /// (04 §4-6 · 규칙 ④). 등록 = 전 플랫폼 · 본문 = 전 플랫폼(`rm_ops_summary` v1 필수 · N-07).
  static const String opsRhythm = 'aaq://ops/rhythm';

  /// 🆕 v1.17(01 §26 · K18) — `D-02` DR 런북 목록(`RunbookList()` · `ui_shell` · R16a). 등록 = 전 플랫폼 · 가드 = 기본 open
  /// (뷰어에도 보인다 — 발주자 결정 2026-11-04 ③). 들어오는 링크 = 데이터(셸 진입 UI = 카드 몫).
  static const String opsRunbooks = 'aaq://ops/runbooks';

  /// 🆕 v1.17 — `D-02` 런북 상세(`RunbookDetail(runbookId:)`) · 들어오는 링크 = `RunbookRow.deepLink`(엔진 완성 ·
  /// `runbookId` 꼴 `^[a-z][a-z0-9-]*$` — 엔진 의무 · C-51 ③). 🔴 화면은 id 로 링크를 짓지 않는다.
  static const String opsRunbook = 'aaq://ops/runbooks/:runbookId';

  /// 🆕 v1.17 — `D-03` 오프라인 긴급정지 카드(`EmergencyStopCard()`) · 들어오는 링크 = 런북 ⑥ 행 `deepLink` 등(데이터).
  /// 등록 = 전 플랫폼 · 가드 = 기본 open(결정 ③) · 인쇄 = 플랫폼 슬롯(`OpsSlotIds.emergencyCardPrint`).
  static const String opsEmergencyCard = 'aaq://ops/emergency-card';

  /// 🆕 v1.17 — `H-03` 물리 리스크 점검 상세(`DeviceRiskBoard()` · R16c). 🔴 Android(operator) 전용 = 조립 앱 레지스트리가
  /// 뷰어 빌드에 본문을 주지 않는 것으로 지킨다 — 셸 가드 표 무변경(발주자 결정 ④ R16c ③ · 01 §8 미결 127).
  static const String opsDeviceRisk = 'aaq://ops/device-risk';

  /// 🆕 v1.17 — `B-01` 전략 핸드북 목차(`HandbookContents()` · R16b · 웹 사이드바 «핸드북»). 🔴 페이지(`B-02`)는 이 상수가 아니라
  /// `handbook://<앵커>` 스킴이다(셸 라우터 한 곳이 앵커 = `handbook://` 뒤 글자 전부로 연다).
  static const String handbookIndex = 'aaq://handbook';

  /// 🆕 v1.15(01 §24 · K7) — `N-01` 알림 센터(`AlertCenter()` · `ui_shell`). 등록 = 전 플랫폼 · 가드 = 기본 open
  /// (뷰어 = 조회 · 확인 버튼 부재). 진입 = 데이터 링크·푸시·FGS 탭(셸 진입 UI 0 · K22).
  static const String alertsInbox = 'aaq://alerts/inbox';

  /// 🆕 v1.15 — `N-02` 알림 상세(`AlertDetail(alertId:)`) · 들어오는 링크 = `AlertItem.detailDeepLink`(데이터) ·
  /// 푸시·FGS 탭(엔진).
  static const String alertDetail = 'aaq://alerts/detail/:alertId';

  /// 🆕 v1.23(01 §32 · K75) — M9 `S13` 월 납입 설정(R8a · 운영 등급 · 🔴 폰 전용 — 뷰어 레지스트리 빈 자리). 들어오는 링크 = `S01` 운영 묶음 카드(`SET_CONTRIBUTION` · 데이터).
  static const String settingsContribution = 'aaq://settings/contribution';
  static const String settingsCredentials = 'aaq://settings/credentials';

  /// 🆕 v1.18(01 §27 · K-w · 발주자 결정 2026-11-13 Q2) — M9 `S01` 설정 홈(`SettingsHome()` · `ui_settings` · R6a) =
  /// 폰·iOS 뷰어 «더보기» 탭 몸통(셸 `ShellRouteBody` · 04 §3-1) · 웹 = 탭 없음(04 §3-2). 들어오는 링크 = 셸 탭 · 데이터.
  static const String settingsHome = 'aaq://settings';

  /// 🆕 v1.18 — `S03` 계좌 연동·슬리브↔계좌 매핑(R7 · 폰 전용 · 01 §8 미결 72 목적지).
  static const String settingsAccounts = 'aaq://settings/accounts';

  /// 🆕 v1.18 — `S04` 전략·배분 편집기(R8 · 규칙 등급 · 조회 = 전 플랫폼).
  static const String settingsAllocation = 'aaq://settings/allocation';

  /// 🆕 v1.18 — `S05` 운용 관리(R6c · 계약 = v1.19 · 폰 전용 기본 — 05 C3 = v1.19 창).
  static const String settingsOperations = 'aaq://settings/operations';

  /// 🆕 v1.18 — `S06` 기기·접근(QR 페어링 · R7 · 폰 전용).
  static const String settingsDevices = 'aaq://settings/devices';

  /// 🆕 v1.18 — `S07` 연결 관리(`Connections()` · R6b · 상태 조회 = 폰·iOS 뷰어 · 버튼 = 폰만).
  static const String settingsConnections = 'aaq://settings/connections';

  /// 🆕 v1.18 — `S08` 구글 캘린더(X4 · ⏸ R9d — E17 판독 뒤 계약 창 · 01 §33 K107 · 폰 전용 · `ConnectionRow.route` 목적지).
  static const String settingsCalendar = 'aaq://settings/calendar';

  /// 🆕 v1.18 — `S09` 백업·복원(🆕 v1.24 R9a · `BackupVm` · 폰 전용).
  static const String settingsBackup = 'aaq://settings/backup';

  /// 🆕 v1.18 — `S10` 진단(골든벡터 셀프테스트 · 무결성 · 🆕 v1.24 R9b · `DiagnosticsScreenVm` · 폰 전용).
  static const String settingsDiagnostics = 'aaq://settings/diagnostics';

  /// 🆕 v1.18 — `S11` 일반 설정·방해금지(⏸ R9e — 엔진 원천 뒤 · 01 §8 미결 197 · 170 닫음).
  static const String settingsGeneral = 'aaq://settings/general';

  /// 🆕 v1.18 — `S12` 12월 연간 리뷰 진입(M9 목차 · `SettingsHomeVm.annualReviewLink` 목적지 · M7 `reportAnnual` 과 다른 화면 ·
  /// 🆕 v1.24 R9c · `AnnualReviewIndexVm` · v1 뷰어 = 레지스트리 빈 자리 · 미결 95·170 닫음).
  static const String settingsAnnualReview = 'aaq://settings/annual-review';

  /// 🆕 v1.26(01 §35 · K173) — 🔒 `M5-11` 위저드와 **같은 본문·같은 VM**(`HandoverRepository.watchWizard` · 본문 = `ui_safety` ·
  /// 조립 = 레지스트리 두 칸에 같은 위젯) · 엔진 알림 `HANDOVER_COOLING_ACTIVE` · `HANDOVER_COMMITTED` 목적지(냉각 끝 재진입 길) ·
  /// 소유 = M5(Claude · C-33).
  static const String handoverStatus = 'aaq://handover/status';

  // ── M4 · M5 · X1 · X2 · X5 소유(06 §3-5 목록 — 위젯은 Claude, 등록은 셸) ────────
  /// 🆕 v1.20(01 §29 · K12 · K37) — 🔒 06 `M4-4` 키 회전 마법사(`S02` 카드 `rotateLink` 목적지 · 파라미터 0 — 세트는 마법사가 VM 으로 안다) ·
  /// 본문 = 마법사가 생길 때까지 조립 앱 레지스트리 빈 자리(v1.16 `x1MigrationPlan` 선례) · 셸 가드 무변경.
  static const String m4KeyRotation = 'aaq://m4/key-rotation';

  /// 🆕 v1.25(01 §34 · K146 · K152) — 🔒 `M5-1` 본문 = `ui_safety`(VM = `KillSwitchScreenVm` · 셸 자리 = `OpsSlotIds.killSwitch`).
  static const String m5KillSwitch = 'aaq://m5/kill-switch';

  /// 🆕 v1.25(01 §34 · K153) — 🔒 `M5-2` 본문 = `ui_safety`(VM = `KillResumeGateVm` · 서약 재생 = `PledgeRepository`).
  static const String m5ReleaseGate = 'aaq://m5/release-gate';

  /// 🆕 v1.25(01 §34 · K154) — 🔒 `M5-5` 본문 = `ui_safety`(VM = `BlockBoardVm` · 사다리 `M5-4` · 게이지 `M5-7` 포함).
  static const String m5BlockBoard = 'aaq://m5/block-board';
  static const String m5Intervention = 'aaq://m5/intervention';

  /// `M5-10` 안내 개시 게이트(advisory) — 🆕 v1.26(01 §35 · K174) 범위 밖 · 레지스트리 빈 자리.
  static const String m5HandoverGate = 'aaq://m5/handover-gate';

  /// 🆕 v1.26(01 §35 · K167 · K168) — 🔒 `M5-11` simToAuto 위저드 본문 = `ui_safety`(VM = `HandoverWizardVm` ·
  /// 창구 = `HandoverRepository.watchWizard` · `handoverStatus` = 같은 본문).
  static const String m5HandoverWizard = 'aaq://m5/handover-wizard';

  /// `M5-13` 원장 실사 해소·격리 검토.
  static const String m5SelfAuditResolve = 'aaq://m5/self-audit-resolve';

  /// 🆕 v1.16(01 §25 · K3) — `O-04` ⑥ 자동 매매 갈래 시작 상태 선언 = 가상 초기금 1칸(🔒 M5 위젯 · 06 M5-14 · 기본값 없음).
  static const String m5SimOpeningCash = 'aaq://m5/sim-opening-cash';

  /// 🆕 v1.21(01 §30 · K14) — 🔒 `M5-3` STOPPED 결정(A·B·C) 화면 · 본문 = 화면이 생길 때까지 레지스트리 빈 자리(1.22.0 동작).
  static const String m5StoppedDecision = 'aaq://m5/stopped-decision';

  /// 🆕 v1.21 — 🔒 `M5-8` 서약 보기·편집(12월 창) · 본문 = 빈 자리(E13m).
  static const String m5Pledge = 'aaq://m5/pledge';

  /// 🆕 v1.21 — 🔒 `M5-9` 규칙 변경 게이트(M9 `S04` «적용» `ActionResult.handoffRoute` 목적지 · R8) · 본문 = 빈 자리(E13m).
  static const String m5RuleChangeGate = 'aaq://m5/rule-change-gate';

  /// 🆕 v1.39(01 §48 · K345 · 미결 188 · 13 §8 R243 P3 ⓐ) — 🔒 `M5-4` 안전 사건 postmortem 목록 + 쓰기 한 화면(파라미터 0 · 본문 =
  /// `ui_safety` · VM = `PostmortemListVm` · 창구 = `PostmortemRepository.watchPostmortems` · 쓰기 = `SafetyActions.runPostmortem`) ·
  /// D-01 배너 조치 «postmortem 쓰기» 목적지 · 본문 = 화면이 생길 때까지 레지스트리 빈 자리(엔진 `hasBody` 거짓 = 조치 부재).
  static const String m5Postmortem = 'aaq://m5/postmortem';

  /// 🔒 X1 **옛 폰 계획 교체 마법사**(`X1-2` · S06 리스 카드 · S09 «폰을 바꾸시나요?» 진입) — 🆕 v1.33(01 §42 · K265) VM = `X1PlanWizardVm`.
  static const String x1Migration = 'aaq://x1/migration';

  /// 🆕 v1.16(01 §25 · K5) — `R-01` 분기 «구 폰이 옆에 있어요» = X1 **새 폰 받기**(QR 스캔 · 🔒 X1-4 · X1-5) — 🆕 v1.33(K265) 정정:
  /// 옛 «X1-2» 표기는 옛 폰 몫(`x1Migration`)이다 · VM = `X1RecoveryVm`(`MigrationRepository.watchPlanRecovery`).
  static const String x1MigrationPlan = 'aaq://x1/migration/plan';

  /// 🆕 v1.16 — `R-01` 분기 «잃어버렸어요» = X1 비상 경로(복구 코드 → epoch+1 → TTL 대기 · 🔒 X1-3) · 경계 X1 안내(X1-G) —
  /// 🆕 v1.33(K265) VM = `X1RecoveryVm`(`MigrationRepository.watchEmergencyRecovery`).
  static const String x1MigrationEmergency = 'aaq://x1/migration/emergency';

  /// 🆕 v1.25(01 §34 · K156) — 🔒 X2-6 리포트 본문 = `ui_safety`(VM = `ResumeReportVm`).
  static const String x2ResumeReport = 'aaq://x2/resume-report';

  /// 🆕 v1.25(01 §34 · K157) — 🔒 X2-6 게이트 본문 = `ui_safety`(VM = `ResumeGateVm`).
  static const String x2ResumeGate = 'aaq://x2/resume-gate';

  /// `X5-3`·`M5-12` 정합 복구·수기 체결 정정 마법사 — 🆕 v1.32(01 §41 · K248) = **허브**(열린 대상 고르기 · 파라미터 0 · 엔진 링크 그대로).
  static const String x5RepairWizard = 'aaq://x5/repair-wizard';

  /// 🆕 v1.32(01 §41 · K248 · E16j-a) — 🔒 X5 정정 마법사 **대상 화면**(`:targetId` = `ld-…` diff id 또는 `li-…` 무결성 합성 id ·
  /// 엔진이 완성 · 5조각 = 허브 4조각과 겹침 0 · 본문 = `ui_safety` · VM = `RepairWizardVm` · 01 §8 미결 115 닫음).
  static const String x5RepairTarget = 'aaq://x5/repair-wizard/:targetId';

  /// 전량 — 셸 라우트 테이블과 C-33 의 모집단(🆕 v1.5 = 43 · `journalRebalance` ·
  /// 🆕 v1.6 = 45 · `ledgerExecutionGapMonth`·`rebalanceHistory` · 🆕 v1.8 = 48 · `holdingsOverview`·
  /// `holdingsDetail`·`holdingsAllocation` · 🆕 v1.12 = **52** · `adviceSkip`·`ledgerDiffs`·`ledgerRepairs`·`opsRhythm`
  /// + 교체 2 `adviceFill`·`ledgerSelfReport`). 순서 = 첫 일치(C-33 ⑦ · 겹침 0) — `adviceSkip` 은 `adviceFill` 뒤 ·
  /// `ledgerDiffs`·`ledgerRepairs` 는 `ledgerTrust` 뒤 · `opsRhythm` 은 `opsWatchdog` 뒤.
  /// 🆕 v1.16 = **64** · 온보딩 6(`onboardingStep` 앞 — 첫 일치) · `ledgerSimOpening` · `m5SimOpeningCash` · X1 2.
  /// 🆕 v1.17 = **69** · `opsRunbooks`·`opsRunbook`·`opsEmergencyCard`·`opsDeviceRisk`·`handbookIndex`(`opsRhythm` 뒤 ·
  /// 조각 수 4·5·4·4·3 — 기존 패턴과 겹침 0).
  /// 🆕 v1.18 = **80** · M9 11(`settingsCredentials` 뒤 · S 번호 차례 · 3조각 1 + 4조각 10 · 파라미터 0 — 기존 패턴과 겹침 0).
  /// 🆕 v1.20 = **81** · `m4KeyRotation`(Claude 소유 묶음 머리 · 4조각 · 파라미터 0 — 기존 패턴과 겹침 0).
  /// 🆕 v1.21 = **84** · M5 3(`m5SimOpeningCash` 뒤 · M5 번호 차례 · 4조각 · 파라미터 0 — 기존 패턴과 겹침 0).
  static const List<String> all = <String>[
    journalTimeline,
    journalDecision,
    journalDraft,
    journalRead,
    journalRebalance,
    journalBlindReview,
    journalUnknownBoard,
    holdingsOverview,
    holdingsDetail,
    holdingsAllocation,
    adviceInbox,
    adviceDetail,
    adviceFill,
    adviceSkip,
    adviceHistory,
    ledgerSelfReport,
    ledgerSimOpening,
    ledgerTrust,
    ledgerDiffs,
    ledgerRepairs,
    ledgerExecutionGap,
    ledgerExecutionGapMonth,
    reportArchive,
    reportAfterTax,
    reportAnnual,
    reportMonthly,
    reportGoalPath,
    performanceExplore,
    performanceDrawdown,
    performanceContribution,
    planDeposit,
    rebalanceHistory,
    rebalancePreview,
    rebalanceEvent,
    onboardingStart,
    onboardingModePick,
    onboardingSteps,
    onboardingFinish,
    onboardingRestart,
    onboardingPairing,
    onboardingStep,
    opsArchive,
    opsMaintenance,
    opsWatchdog,
    opsRhythm,
    opsRunbooks,
    opsRunbook,
    opsEmergencyCard,
    opsDeviceRisk,
    handbookIndex,
    alertsInbox,
    alertDetail,
    settingsContribution,
    settingsCredentials,
    settingsHome,
    settingsAccounts,
    settingsAllocation,
    settingsOperations,
    settingsDevices,
    settingsConnections,
    settingsCalendar,
    settingsBackup,
    settingsDiagnostics,
    settingsGeneral,
    settingsAnnualReview,
    handoverStatus,
    m4KeyRotation,
    m5KillSwitch,
    m5ReleaseGate,
    m5BlockBoard,
    m5Intervention,
    m5HandoverGate,
    m5HandoverWizard,
    m5SelfAuditResolve,
    m5SimOpeningCash,
    m5StoppedDecision,
    m5Pledge,
    m5RuleChangeGate,
    x1Migration,
    x1MigrationPlan,
    x1MigrationEmergency,
    x2ResumeReport,
    x2ResumeGate,
    x5RepairWizard,
    x5RepairTarget, // 🆕 v1.32 = 85(01 §41 · K248)
    m5Postmortem, // 🆕 v1.39 = 86(01 §48 · K345 · 파라미터 0 — 첫 일치 겹침 0 · 맨 끝)
  ];

  /// [link] 가 [all] 의 패턴 하나와 일치하는가.
  ///
  /// 🔴 **화면은 부르지 않는다**(규칙 ② — 해석 금지). 쓰는 곳은 셸의 라우트 등록 검증과
  ///    계약 테스트 C-33 둘이다. 쿼리·프래그먼트가 붙은 링크는 일치하지 않는다(링크에
  ///    개인 정보·상태를 싣지 않는다).
  static bool isRegistered(String link) {
    for (final String pattern in all) {
      if (_matches(pattern, link)) {
        return true;
      }
    }
    return false;
  }

  static bool _matches(String pattern, String link) {
    final List<String> p = pattern.split('/');
    final List<String> l = link.split('/');
    if (p.length != l.length) {
      return false;
    }
    for (int i = 0; i < p.length; i++) {
      final bool isParam = p[i].startsWith(':');
      if (isParam) {
        if (l[i].isEmpty || l[i].contains('?') || l[i].contains('#')) {
          return false;
        }
      } else if (p[i] != l[i]) {
        return false;
      }
    }
    return true;
  }
}

/// 🆕 v1.39(01 §48 · K342 · 미결 230 ⓐ · 13 §8 R250 ④) — 라우트 조각 → 키(엔진이 링크를 지을 때 `%` · `#` · `?` · `/` 를 퍼센트 꼴로
/// 감싼다 → 퍼센트 꼴을 **한 번** 푼다 · 풀 수 없는 글자 = 그대로). 엔진 core `journalKeyOf` 와 같은 규칙.
/// 🔴 화면은 부르지 않는다(규칙 ② — 링크 해석 금지) — 쓰는 곳 = 셸이 경로 조각을 창구 인자로 넘길 때 · 뷰어 일지 회차 필터
///    (`watchTimeline(rebalanceEventId:)` → `rm_journal.rebalance_event_id` 같음).
String routeParamKeyOf(String routeParam) {
  try {
    return Uri.decodeComponent(routeParam);
  } on ArgumentError {
    return routeParam;
  }
}
```

---

## `packages/domain_contracts/lib/src/primitives/as_of.dart`

```dart
// 01 §1-3 «시각·날짜·신선도» 원문.
//
// 🔴 화면 명세들이 부르는 «`AsOfStamp`»·«기준일 고지»는 전부 **이 `AsOf` 하나**이며
//    표시 문구는 `label` 이다. 별도 타입은 실재하지 않는다(01 §1-3 · 인벤토리 §1).
// 🔴 UTC `DateTime` 필드는 정렬·비교용이지 표시용이 아니다. 화면이 시각을 포맷하는 자리는
//    `TzInstant` 가 실린 필드뿐이다.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'as_of.freezed.dart';
part 'as_of.g.dart';

/// 01 §1-3 — 이 값이 어디서 왔는가.
/// 🔵 viewer 의 «엔진이 멈췄다» 는 push 된 상태값이 아니라 `observedAt` 신선도에서 **파생**한다
///    (계약 3조 ② · 청사진 X2 규칙) — 죽은 엔진은 「나 죽었다」를 보내 주지 않는다.
enum AsOfSource {
  @JsonValue('LOCAL_SQLITE')
  localSqlite('LOCAL_SQLITE'),
  @JsonValue('SUPABASE_MIRROR')
  supabaseMirror('SUPABASE_MIRROR'),
  @JsonValue('ARCHIVE')
  archive('ARCHIVE');

  const AsOfSource(this.wire);

  /// JSON·DDL 표기(01 §1-2). 🔴 바로 위 `@JsonValue` 와 같은 문자열이다.
  final String wire;
}

/// 01 §1-3 — 기준일 고지. 🔴 **빈 목록에도 실려 온다**(계약 3조 ③).
@freezed
abstract class AsOf with _$AsOf {
  const factory AsOf({
    /// UTC — 이 값이 만들어진 시각(정렬·신선도 판정용).
    required DateTime observedAt,

    /// 어느 거래일 기준인가.
    @TradeDateConverter() required TradeDate tradeDate,

    required AsOfSource source,

    /// 초과 시 「오래된 데이터」 배너(M4 신선도 계약).
    /// 🔴 JSON 키는 `stale_after_seconds` 다(01 §1-2 · §5 봉투 예시).
    @JsonKey(name: 'stale_after_seconds')
    @DurationSecondsConverter()
    required Duration staleAfter,

    /// 화면에 그대로 찍는 기준일 고지 문구 — **엔진 생성**(01 §1-5).
    /// 「잔고 기준 2026-09-05 종가」 · 「체결 반영 09:12」.
    required String label,

    /// 이미 stale 이면 그 사유 코드(문구는 01 §3 매핑 사전).
    /// ⚠️ 값 목록은 **엔진(M1) 확정 대기**다 — `m2-8_naming.md` A-2 의 권고 4값
    ///    (`ENGINE_DOWN`·`PUSH_LAG`·`BATCH_MISSING`·`CLOCK_SKEW`)은 역산이며 ⏸ 다.
    ///    🔴 그래서 이 필드는 열거형이 아니라 String 이다 — 화면이 코드→문구 매핑을 만들지 않는다.
    String? staleReasonCode,

    /// 그 사유의 배너 문구 — 엔진 생성.
    String? staleLabel,
  }) = _AsOf;

  factory AsOf.fromJson(Map<String, dynamic> json) => _$AsOfFromJson(json);
}

/// 01 §1-3 — 화면이 포맷해도 되는 **유일한** 시각 표현.
/// 화면은 `tzName` 으로만 포맷한다(⚠️ 표시 구현은 `package:timezone` · 이 패키지 밖).
@freezed
abstract class TzInstant with _$TzInstant {
  const factory TzInstant({
    required DateTime utc,
    @Default('Asia/Seoul') String tzName,
  }) = _TzInstant;

  factory TzInstant.fromJson(Map<String, dynamic> json) =>
      _$TzInstantFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/primitives/converters.dart`

```dart
// 01 §1-2 · docs/toolchain_notes.md §3-3 — JSON 컨버터 4종의 재수출 창구.
//
// 🔴 **선언은 `money.dart` 에 있다**(인벤토리 §1 표: money.dart 가 `DecimalStringConverter`·
//    `DurationSecondsConverter` 를 담는다). toolchain_notes §3-1 의 템플릿이 부르는 경로가
//    `../primitives/converters.dart` 라 두 문서의 경로가 갈리므로, 어느 쪽으로 import 해도
//    같은 4종이 오도록 여기서 다시 내보낸다.
// 🔴 이 파일에 새 컨버터를 **선언하지 않는다** — 선언이 두 곳이 되면 규약의 소유자가 둘이 된다.
export 'money.dart'
    show
        DecimalStringConverter,
        DurationSecondsConverter,
        RatioConverter,
        TradeDateConverter;
```

---

## `packages/domain_contracts/lib/src/primitives/date_range.dart`

```dart
// 01 §2-1 «조회 구간» 원문.
//
// 🔴 화면이 날짜 산술로 만들지 않는다 — 프리셋의 창구는
//    `ConfigRepository.watchRangePresets()` **하나**다(G-38 · 01 §4-1).
//    화면이 `presetCode` 문자열을 코드에 나열하거나 `DateTime` 산술로 from·to 를 만들지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'date_range.freezed.dart';
part 'date_range.g.dart';

@freezed
abstract class DateRange with _$DateRange {
  const factory DateRange({
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,

    /// 엔진이 준 프리셋의 식별자. 화면이 값을 나열하지 않는다.
    String? presetCode,

    /// 「최근 30일」 — 엔진 생성(01 §1-5).
    String? label,

    /// 🆕 v1.1(§8 미결 33) — 프리셋 목록에서 **첫 화면의 기본**인 항목.
    /// 🔴 `watchRangePresets()` 목록에서 `true` 는 **정확히 하나**다(엔진 보장 · C-34).
    ///    화면은 그 항목을 고르기만 한다 — 날짜 산술로 기본 구간을 만들지 않는다.
    @Default(false) bool isDefault,
  }) = _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
}
```

---

## `packages/domain_contracts/lib/src/primitives/list_result.dart`

```dart
// 01 §2-1 «목록 스트림의 봉투» 원문.
//
// 🔴 계약 3조 ③ «없는 것»·«못 받은 것»·«해당 없음» 의 구별을 **타입으로** 강제한다 —
//    빈 목록에도 `asOf`·`emptyKind`·`emptyLabel`·`hasMore` 가 실려 오므로 화면이 빈 상태를
//    지어낼 필요가 없다.
// 🔴 `rows` 는 **엔진이 이미 정렬해서** 준다 — 화면 재정렬 금지(인벤토리 §4 말미).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import 'as_of.dart';

part 'list_result.freezed.dart';

/// 🔴 `fromJson`/`toJson` 을 두지 않는다 — 픽스처 봉투는 영역 F 의 로더가
/// `decodeList<T>(String json, T Function(Map<String,Object?>) rowFrom)` 로 조립한다
/// (인벤토리 §8-5). 제네릭 팩토리를 계약에 열면 행 타입마다 생성기 설정이 갈린다.
@freezed
abstract class ListResult<T> with _$ListResult<T> {
  const factory ListResult({
    /// 엔진이 이미 정렬해서 준다 — 화면 재정렬 금지.
    required List<T> rows,
    required AsOf asOf,

    /// `rows` 가 비어 있을 때의 갈래.
    required EmptyKind emptyKind,

    /// 「아직 기록된 거래가 없습니다 · 다음 리밸런싱 D-6」 — 엔진 생성(01 §1-5).
    String? emptyLabel,

    /// 더 받을 것이 남았는가(01 §4-1 페이징 — 커서가 아니라 `limit` 증가 재구독).
    required bool hasMore,
  }) = _ListResult<T>;
}
```

---

## `packages/domain_contracts/lib/src/primitives/money.dart`

```dart
// 01 §1-2 «금액 — Decimal 문자열 승격» · §1-3 «시각·날짜·신선도»의 원시타입 원문.
// 🔴 이름·필드·규약은 01 §1-2 가 정본이고, **클래스 선언 문법만** freezed 4 로 바꿔 읽는다
//    (docs/toolchain_notes.md §3-1 — 01 의 코드 예시는 freezed 2.x 문법이다).
// 🔴 이 파일에는 산술이 없다. `domain_contracts` 안에 Decimal 산술이 등장하면
//    그 자체가 설계 오류 신호다(toolchain_notes §4-2 말미 · 01 §1-2 규약 5조 말미).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// 01 §1-2 — 통화 축.
///
/// 🔵 v2.31 P0S 1차 자동화는 국내상장 ETF 만이라 전 금액이 KRW 다. 통화가 섞이는 시점
///    (미국 직접주문 부활)에 상위 DTO 의 `currency` 축이 이 값을 싣는다.
enum Currency {
  @JsonValue('KRW')
  krw('KRW'),
  @JsonValue('USD')
  usd('USD');

  const Currency(this.wire);

  /// JSON·DDL 표기(01 §1-2 enum 직렬화 규약). 🔴 바로 위 `@JsonValue` 와 **같은 문자열**이며
  /// 한쪽만 고치지 않는다 — 갈라지면 픽스처·DDL `CHECK` 와 어긋나고 §7 C-15 가 실패한다.
  final String wire;
}

/// ⚠️ **예약 타입 — 1차 릴리스 DTO 에서는 쓰지 않는다**(인벤토리 §1 · 01 §1-2 주석 원문).
///
/// P0S 는 전 금액이 KRW 라 §2 의 금액 필드는 `Decimal` 하나로 쓰고 통화는 상위 DTO
/// (계좌·플랜)의 `currency` 축으로 표현한다. 지금 전면 도입하면 값 객체 한 겹이
/// 화면·픽스처·골든에 그대로 비용으로 남는다.
/// 🔴 화면의 산술 차단은 `Money` 유무가 아니라 §7 C-4(`Decimal` 필드까지 탐지)가 한다.
@freezed
abstract class Money with _$Money {
  // 🔴 이름 있는 factory 를 두므로 private 생성자가 필수다(toolchain_notes §3-1 규칙 3).
  const Money._();

  const factory Money({
    @DecimalStringConverter() required Decimal amount,
    required Currency currency,
  }) = _Money;

  /// 🔴 유일한 생성 경로는 **문자열**이다.
  /// `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회 금지(01 §1-2).
  factory Money.krw(String v) =>
      Money(amount: Decimal.parse(v), currency: Currency.krw);

  factory Money.usd(String v) =>
      Money(amount: Decimal.parse(v), currency: Currency.usd);

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);
}

/// 01 §1-2 — 비율·스코어는 `double`.
/// 🔴 산술 연산자를 정의하지 않는다(인벤토리 §1) — 정의하는 순간 화면이 비율을 곱할 수 있게 된다.
extension type const Ratio(double value) {}

/// 01 §1-2 — 해당 시장 **현지** 거래일 `'YYYY-MM-DD'`(US 는 ET · KST 환산 금지).
/// 🔴 **날짜 산술 없음** — 「다음 거래일」·「D-6」 은 거래소 캘린더를 아는 엔진만 판정한다(M1-6).
extension type const TradeDate(String yyyyMmDd) {}

/// 01 §1-2·§1-3 — 화면이 `DateTime.now()` 를 부르지 않게 하는 유일한 통로.
/// 구현체 주입은 `data_sync`.
///
/// 🔴 화면이 이 값을 쓰는 자리는 **둘이다**(🆕 v1.3 · 01 §13-6) —
///    ① 신선도 비교 `observedAt + staleAfter < clock.nowUtc()`(신선도 배너)
///    ② 명령 페이로드의 관측 시각(`DisclosureViewEvent.viewedAt`) — 판정이 아니며
///       집계 월은 엔진이 접수·서버 시각으로 확정한다.
///    카운트다운·경과·D-day·TTL 잔여는 엔진이 문자열 필드로 준다.
/// 🔴 신뢰 시각(리스 TTL·킬스위치 48h·냉각 30일)은 **Supabase 서버 시각**이다.
///    로컬 시계로 마찰 카운트다운을 만들지 않는다.
abstract interface class Clock {
  DateTime nowUtc();
}

/// 01 §1-2 — 금액의 JSON 표기는 **문자열**이다(`"38250.00"`). 숫자로 쓰면 파서가 double 로 읽어
/// 정밀도가 날아간다.
///
/// 🔴 **필드 어노테이션이다** — 메서드 인자에 붙여도 아무 일도 하지 않는다(01 §4-2 조문).
///    그래서 인자가 2개를 넘는 명령은 전부 DTO 로 받는다.
/// ⚠️ decimal 3.x 는 값을 정규화한다 — `Decimal.parse('38250.00').toString() == '38250'`.
///    값 왕복(`fromJson(toJson(d)) == d`)은 안전하지만 **문자열 왕복은 보장되지 않는다**
///    (toolchain_notes §4-1). 픽스처의 금액 문자열은 정규형으로 적는다.
/// 🔴 표시용 자릿수는 컨버터의 일이 아니다 — 화면 문자열은 전부 엔진 완성 문자열이다(01 §1-5).
class DecimalStringConverter implements JsonConverter<Decimal, String> {
  const DecimalStringConverter();

  @override
  Decimal fromJson(String s) => Decimal.parse(s);

  @override
  String toJson(Decimal d) => d.toString();
}

/// 01 §1-2 — `Duration` 의 JSON 표기는 **초(int)** 이고 키는 `*_seconds` 다.
/// 키 이름은 필드마다 `@JsonKey(name: '..._seconds')` 로 직접 적는다
/// (build.yaml 의 `field_rename: snake` 는 `_seconds` 접미를 붙여 주지 않는다).
class DurationSecondsConverter implements JsonConverter<Duration, int> {
  const DurationSecondsConverter();

  @override
  Duration fromJson(int s) => Duration(seconds: s);

  @override
  int toJson(Duration d) => d.inSeconds;
}

/// docs/toolchain_notes.md §3-3 — 🔴 extension type 에는 컨버터가 **반드시** 필요하다.
/// json_serializable 은 extension type 을 대표 타입(double)으로 자동으로 풀어 주지 않는다 —
/// 애너테이션 없이 두면 «cannot handle» 로 생성이 실패한다.
class RatioConverter implements JsonConverter<Ratio, double> {
  const RatioConverter();

  @override
  Ratio fromJson(double v) => Ratio(v);

  @override
  double toJson(Ratio r) => r.value;
}

/// docs/toolchain_notes.md §3-3 — `TradeDate` 의 대표 타입(String) 풀이.
class TradeDateConverter implements JsonConverter<TradeDate, String> {
  const TradeDateConverter();

  @override
  TradeDate fromJson(String s) => TradeDate(s);

  @override
  String toJson(TradeDate d) => d.yyyyMmDd;
}
```

---

## `packages/domain_contracts/lib/src/repositories/advice_repository.dart`

```dart
// 01 §4-1 · §10 — 🆕 X7 투자 안내 읽기 창구.
//
// 🔴 전부 읽기 전용이며 쓰기는 §4-2 명령 API 경유다.

import '../dto/advice.dart';
import '../dto/journal.dart';
import '../enums/advice.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 안내함 · 요약 · 상세 · 이력 · 수기 기록 폼 사양.
abstract interface class AdviceRepository {
  /// `A-1` 안내함.
  /// 🆕 v1.12(01 §21 · K13) — 🔴 `A-1` 은 **인자 없이** 부른다(`status` 인자 금지) · 순서 = 엔진(확인 카드 → `isUrgent`
  ///    → 나머지) · 확인 카드 밖 미분류 만료는 이 목록에 오지 않는다(요약 `overdueUnrecordedLink` · [watchHistory]).
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  });

  /// 홈·알림 앵커.
  /// 🔴 `openCount` 의 정의는 엔진이 갖는다(G-08) — 화면이 재구현하지 않는다.
  Stream<AdviceInboxSummary> watchSummary();

  /// `A-2` 상세.
  Future<AdviceItem?> findById(String adviceId);

  /// 🆕 v1.12(K38) — 「지난 안내」(`AdviceHistory()`)의 원천 · 범위 = `ConfigRepository.watchRangePresets()` 의
  /// `isDefault` 1건(화면이 날짜를 만들지 않는다 · 01 §1-3).
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range});

  /// `A-3` 수기 기록 폼 사양.
  /// 🔴 A16 — **Future 가 아니라 Stream 이다.** 계약 3조 ②(모든 스트림은 `AsOf` 를 싣는다)를
  ///    Future 한 방으로 우회하면, 임시공휴일 해제·슬리브 종목 교체 뒤에도 화면이 **오래된
  ///    판정으로** 사람의 실제 거래일을 막는다. 신선도 초과면 `A-3` 는 폼을 열지 않고
  ///    엔진 문구를 보인다 — 🔴 «오래된 규칙으로 막는 것»보다 «막지 못한다고 말하는 것»이 안전하다.
  Stream<ManualFillFormSpec> watchManualFillFormSpec();

  /// 🆕 G-23 — 이 **안내**에 연결된 체결 목록(`A-2` 「기록된 체결」 블록).
  /// 🔴 `JournalRepository.fillChain(entryId)` 와 **다른 것이다** — `fillChain` 은 «한 체결의
  ///    정정 체인», 이것은 «한 안내의 체결들»이다. 02 §3-7 의 `fillChain(adviceId)` 인용은
  ///    오기이며 정본 우선순위상 01 이 이긴다.
  /// 🔴 정정된 행도 전부 온다 — 🆕 v1.12(01 §21 · K18) **받은 순서 그대로 그린다**(옛 «화면이 `fillKind` 로 접어
  ///    묶는다» 삭제 — 묶기도 판정이다 · 접기 = 01 §8 미결 115) · 행 탭 = `TradeJournalEntry.detailDeepLink`(→ `J-2`).
  /// 🔴 지연 이행(`LATE_FILL`)으로 참조만 걸린 체결도 포함한다.
  /// 🆕 v1.12(K40) — viewer 판은 **빈 목록**(rm_advice A6 마스킹의 연장 · `recorded_quantity` 도 싣지 않는다).
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId);
}
```

---

## `packages/domain_contracts/lib/src/repositories/alert_repository.dart`

```dart
// 01 §4-1 — 알림함(M8) 읽기 창구.
//
// 🔴 `AlertLevel` 의 **표시 계층 사적 재분류는 금지**다(결정 7c) — `min` 은 거르기이지
//    등급을 다시 매기는 자리가 아니다.

import '../dto/safety.dart';
import '../enums/safety.dart';

/// 알림 창구(M8).
abstract interface class AlertRepository {
  /// `S-01` P0 점(🔵 v1.15 무변경). 받은 차례 = 엔진 순서(등급 순 P0 → P1 → P2 · 같은 등급 안 = 엔진 · K13).
  Stream<List<AlertItem>> watchInbox({AlertLevel? min});

  /// 🆕 v1.15(01 §24 · K2 · K10) — `N-01` 알림 센터. [p0Only] = «P0만 보기»(창구 인자 · 바꾸면 재구독) —
  /// true 면 `sections` 빈 목록 · `pinned` 그대로. 🔴 화면은 받은 VM 을 거르거나 다시 묶지 않는다.
  Stream<AlertCenterVm> watchCenter({required bool p0Only});

  /// 🆕 v1.15(K2 · 발주자 결정 ②(a)) — `N-02` 알림 상세. 모르는·지난 [alertId] = `item` null + `missingLabel`
  /// (값 · 에러 아님) · 스트림 에러 = 읽기 실패.
  Stream<AlertDetailVm> watchAlert(String alertId);
}
```

---

## `packages/domain_contracts/lib/src/repositories/block_board_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.25(01 §34 · K154) — `M5-5` 차단 보드 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용) · `BreakerLadderRepository`(사다리 단독) 무변경 — 보드는 둘을 감싼 한 스트림이다(v1.24 K113 결).

import '../dto/safety_gate.dart';

/// 차단 보드 한 화면.
abstract interface class BlockBoardRepository {
  Stream<BlockBoardVm> watchBoard();
}
```

---

## `packages/domain_contracts/lib/src/repositories/breaker_ladder_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.22(01 §31 · K6 · K65) — `M5-4` 브레이커 사다리 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용 `watchState`)는 무변경 — 넓히면 UI 가짜 7 · ds 구현 · 조립 앱이 깨진다(v1.21 실측).

import '../dto/safety_gate.dart';

/// 사다리 한 화면.
abstract interface class BreakerLadderRepository {
  Stream<BreakerLadderVm> watchLadder();
}
```

---

## `packages/domain_contracts/lib/src/repositories/calendar_repository.dart`

```dart
// 01 §4-1 — X4 구글 캘린더 동기 상태 읽기 창구.
//
// ⏸ J-5 — X4 계열 전체는 **이름·타입을 등재하되 구현하지 않는다**(OAuth 동의화면
//    «테스트» 상태 7일 만료 스모크가 미결 · §8-5). 인터페이스 선언까지가 이 회차의 몫이다.
// ⏸ v1.24(01 §33 · K107) — `S08` 은 1.24.0 에서 뺐다(X4 = 13 E17 «실험 3 · 실전 뒤» · 카드 ⏸ `R9d-Bob-M9S08`) — 이 창구·`CalendarSyncStatus` 는
//    지우지 않는다(J-5 그대로 · 계약 창 = E17 판독 뒤 · 01 §8 미결 196).

import '../dto/calendar.dart';

/// 캘린더 동기 상태 1건.
abstract interface class CalendarRepository {
  Future<CalendarSyncStatus> status();
}
```

---

## `packages/domain_contracts/lib/src/repositories/config_repository.dart`

```dart
// 01 §4-1 — 플래그·슬리브 카탈로그·구간 프리셋·운영 파라미터 읽기 창구.
//
// 🔴 화면이 「지금 슬리브가 몇 칸인가」·「캘린더 화면을 그릴 것인가」를 아는 유일한 경로다.
//    상수·컴파일 타임 분기로 대체하면 플래그가 켜졌을 때 화면이 조용히 틀린다.

import '../dto/common.dart';
import '../dto/settings.dart';
import '../primitives/date_range.dart';

/// 런타임 구성 읽기.
abstract interface class ConfigRepository {
  Stream<FeatureFlags> watchFlags();

  /// 🔴 슬리브 목록은 플래그가 아니라 `SleeveCatalogEntry` 목록으로 온다 — 화면이
  ///    `SleeveId` 를 순회하며 `satellite` 를 걸러내는 코드를 쓰지 않게(거르는 규칙이
  ///    화면에 생기면 그것이 판정이다).
  Stream<List<SleeveCatalogEntry>> watchSleeves();

  /// 🆕 G-38 조회 구간 프리셋 목록 — 🔴 「최근 30일」·「이번 달」·「올해」의 `from`·`to`·
  ///    `label` 을 엔진이 **거래일 캘린더(M1-6)로** 만들어 준다. 화면이 `DateTime` 산술로
  ///    만들지 않는다. 🔴 목록의 길이·순서도 엔진이 정한다.
  Stream<List<DateRange>> watchRangePresets();

  /// 🆕 G-07 월 납입 운영값 — 🔴 「S05·S7-4·H-02 가 **같은 값 하나**를 읽는다」의 그 하나다.
  ///    값을 바꾸는 경로는 §4-3(운영 등급)이고 여기는 **읽기 전용**이다.
  /// 🆕 v1.4 정정(01 §14-10 · 03 §17-17 이 이긴다) — **S7-9 는 이 창구를 읽지 않는다.** 목표 경로
  ///    가정 카드 2줄은 `GoalPathVm.startingCapitalAssumptionText`(엔진 문장)가 준다.
  /// ✅ C-10 — 소속 리포지토리는 `ConfigRepository` 로 확정(별도 리포지토리를 만들지 않는다).
  /// 🔴 화면·계약·픽스처가 월 납입 금액을 상수로 적지 않는다(C-32).
  /// 🆕 v1.23(01 §32 · K78) — `S05` 칸 0(v1.19 K3) · M9 `S13` 은 같은 값의 화면 투영 `SettingsRepository.watchContribution()` 을 읽는다(값의 원천 = 엔진 `contributionSettingOf` 하나 · 두 벌 문장 0).
  Stream<ContributionSetting> watchContributionSetting();
}
```

---

## `packages/domain_contracts/lib/src/repositories/execution_gap_repository.dart`

```dart
// 01 §4-1 · §10 — 🆕 X7 이행 갭 리포트 읽기 창구.
// 🆕 v1.6(01 §15-4) — `monthly({String? yyyyMm})` → `ExecutionGapResult`(리포트 | 빈·해당없음 문장).

import '../dto/ledger_trust.dart';

/// 월간 이행 갭(`S7-10`) · 롤링 이행 갭.
/// 🔴 `modeAdviceLine` 은 엔진이 **3갈래로 갈라 생성**한다(B21) — 화면이 조립하지 않는다.
abstract interface class ExecutionGapRepository {
  /// 🆕 v1.6 — [yyyyMm](`yyyy-MM`) == null = **엔진 기본 달**(06 X7-4 — 권고: 월간 리포트가 발행된
  /// 가장 최근 달). 기간은 `report.periodLabel` 이 말한다. 「계획」 탭 ⑤ = null · `S7-1` ⑧ = 그 달
  /// (`AppRoutes.ledgerExecutionGapMonth` → 셸 → `ExecutionGapScreen(yyyyMm:)` → 이 인자).
  Future<ExecutionGapResult> monthly({String? yyyyMm});

  /// 🔴 R12 화면 미사용 — 롤링 창 정의 = 06 X7-4(정의 전).
  Stream<ExecutionGapReport> watchRolling();
}
```

---

## `packages/domain_contracts/lib/src/repositories/handbook_repository.dart`

```dart
// 🆕 계약 v1.17(01 §26 · K16) — M8 `B-01`·`B-02` 전략 핸드북 읽기 창구.
// 🔴 앵커 = `handbook://` 뒤 글자 전부(셸 라우터 한 곳이 뗀다) · 별칭 해석·모르는 앵커 판정 = 엔진.
// 🔴 셸 주입은 nullable 기본 null(셸 핸드북 자리표시자 그대로) — 조립 앱 override 의무(06 M4-12).

import '../dto/handbook.dart';

/// `B-01` 목차 · `B-02` 페이지.
abstract interface class HandbookRepository {
  Stream<HandbookIndex> watchIndex();

  /// 모르는 앵커 = `HandbookPage.missingLabel`(스트림 에러 아님).
  Stream<HandbookPage> watchPage(String anchor);
}
```

---

## `packages/domain_contracts/lib/src/repositories/handover_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.26(01 §35 · K167) — `M5-11` simToAuto 위저드 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 `SettingsRepository` 를 넓히지 않는다(05 «7단계 전부 M5 소유» · M9/M5 경계 · v1.25 `BlockBoardRepository` 선례).
// 🔴 `handoverStatus` = 같은 본문 · 같은 스트림(K173).
// 🔴 시각이 지나면(냉각 끝 · 확정 기한 · 커밋 창) 새 VM 을 낸다 — 화면 카운트다운 0.
// 🔴 세션 저장 = 실전 파일(ds `handover_session_store.dart`) — 열기·여는 때는 구현 몫(01 §8 미결 207).
// 🔴 쓰기 = `SettingsActions.run`(행의 `actions` 그대로 · K169).

import '../dto/handover.dart';

/// 위저드 한 화면.
abstract interface class HandoverRepository {
  Stream<HandoverWizardVm> watchWizard();
}
```

---

## `packages/domain_contracts/lib/src/repositories/holdings_repository.dart`

```dart
// 01 §4-1 — 보유현황(M6) 읽기 창구.
// 🆕 v1.8(01 §17 · R4 선행) — `H6-1`~`H6-3` 화면 창구 3(`watchHoldingsOverview` · `watchHoldingDetail` ·
//    `watchAllocation`) · 받침대 `UnimplementedHoldingsRepository`(`lib/testing.dart`).

import '../dto/holdings.dart';
import '../dto/rebalance.dart';
import '../primitives/list_result.dart';

/// 보유 종목 목록.
abstract interface class HoldingsRepository {
  /// 🔴 `includePnl` 은 **기본 false**다(결정 8) — 화면이 값을 받아 놓고 접기만 하면
  ///    결정 8이 렌더 구현 디테일에 의존하게 된다.
  /// 🔴 X7 D7 — `external_holding`(= `scope == external`)의 표시 UNION 은
  ///    **이 리포지토리 한 곳에서만** 만든다(C-23). 파생 계산 경로는 `positions` 만 읽는다.
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false});

  // ── 🆕 계약 v1.8(R4 선행 M2 보강 · 01 §17) ───────────────────────────────
  // 🔵 [watchHoldings] 는 남는다(시그니처 무변경) — `H6-*` 화면은 부르지 않는다(C-44 ⑬).

  /// 🆕 v1.8 — `H6-1` 한 화면(카드·종목 행·시스템 밖 섹션). 🔴 `includePnl` 기본 false(결정 8) —
  /// 펼침 조작 1회 = `true` 재구독 · 화면 이탈 = 상태 소멸(저장 0). 뷰어 구현은 `true` 여도 `pnl` 을 싣지 않는다(K15).
  /// 🔴 X7 D7 — 시스템 밖 자산의 표시 UNION 은 여기서 만든다(`external`) · 파생 경로는 `positions` 만.
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false});

  /// 🆕 v1.8 — `H6-2` 보유 1건. [holdingId] = `HoldingRow.holdingId`(셸이 라우트에서 꺼내 생성자로 준다).
  /// 모르는 id = 스트림 에러(봉투 없는 VM 의 **잠정** 규칙 — §8 미결 50 ③). `includePnl` 규칙은 위와 같다.
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  });

  /// 🆕 v1.8 — `H6-3` 배분 행 전부(회계 기준). 홈 블록 4(R13)도 이 창구의 `sleeveWeight`·`*PctText` 만 쓴다.
  Stream<SleeveAllocationVm> watchAllocation();
}
```

---

## `packages/domain_contracts/lib/src/repositories/incident_repository.dart`

```dart
// 🆕 계약 v1.17(01 §26 · K9) — M8 `D-01` 장애 배너 읽기 창구.
// 🔴 폰(로컬 엔진)·뷰어(rm_* + `phoneDown` 파생 — 06 숙제)가 **같은 DTO** 를 준다(01 §4-1 계약 3조 ①).
// 🔴 셸 주입은 nullable 기본 null(배너 부재) — 조립 앱은 반드시 override 하고 조립 테스트 1줄로 비-null 을 단언한다(06 M4-12).

import '../dto/incident.dart';

/// `D-01` 장애 배너 — 최대 1건(엔진이 고름).
abstract interface class IncidentRepository {
  /// 늘 값을 낸다 — 배너 없음 = `IncidentBannerVm(banner: null)`.
  Stream<IncidentBannerVm> watchIncident();
}
```

---

## `packages/domain_contracts/lib/src/repositories/journal_repository.dart`

```dart
// 01 §4-1 — 매매일지(M6) 읽기 창구.
//
// 🔴 여기에는 인터페이스만 있다. 구현체는 둘뿐이고 둘 다 같은 DTO를 돌려준다
//    (`LocalSqliteReader` = 폰 정본 SQLite / `SupabaseReadModel` = viewer RLS + Realtime).

import '../dto/journal.dart';
import '../enums/journal.dart';
import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 매매일지 타임라인·결정 체인·정정 체인.
abstract interface class JournalRepository {
  /// 🔴 `rows` 는 **엔진이 시간 역순으로 정렬해서** 준다 — 화면이 정렬 키를 만들지 않는다.
  /// 🔴 페이징은 커서가 아니라 `limit` 증가 재구독 하나뿐이다(1인 사용자·연 ~934건).
  ///    무한 스크롤 = 바닥 도달 시 `limit += 100` 으로 재구독하고 `hasMore == false` 면 멈춘다.
  /// 🆕 G-39 `origin` — 「수기 기록만」·「브로커 체결만」 필터(02 §3-1 X7).
  ///    🔴 화면이 `rows` 를 받아 거르지 않는다 — **거르기도 판정이다**.
  /// 🆕 G-40 `rebalanceEventId` — `S7-6b` 「이 회차의 주문 N건」 딥링크의 **유일한 경로**.
  ///    🆕 v1.5(01 §15-3) — 운반 = `AppRoutes.journalRebalance` → 셸 → `JournalTimeline(rebalanceEventId:)`
  ///    → 이 인자. 씨앗 기간은 [watchRebalanceScope] 의 `range` 다.
  ///    🔴 화면이 `RebalanceEvent.orderIntentIds` 를 순회해 거르는 구현은 반려.
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  });

  Future<TradeJournalEntry?> findByDecisionId(String decisionId);

  /// 의도 → 주문 → 체결.
  Future<List<TradeJournalEntry>> chainOf(String decisionId);

  /// 🆕 X7 — 한 체결의 **정정 체인**(ORIGINAL → REVERSAL → RESTATEMENT).
  /// 🔴 `AdviceRepository.fillsOfAdvice(adviceId)` 와 **다른 것이다**(G-23) — 이쪽은
  ///    «한 체결의 정정 체인», 저쪽은 «한 안내의 체결들»이다.
  Future<List<TradeJournalEntry>> fillChain(String entryId);

  // ── 🆕 계약 v1.1(2026-09-17 · M2 보강) ────────────────────────────────────

  /// `J-1` 필터의 상태·출처·종목 선택지(§8 미결 37).
  /// 🔵 기간 = `ConfigRepository.watchRangePresets()` · 슬리브 = `watchSleeves()`.
  /// 🔴 화면이 열거값을 순회해 선택지를 만들거나 `rows` 에서 종목을 모으지 않는다.
  Stream<JournalFilterCatalog> watchFilterCatalog();

  /// `J-1` 상단 배지(「확인 중 2건」 등 — §8 미결 38). 🔴 비면 배지 줄이 없다.
  /// 🔴 화면이 `watchTimeline` 의 `rows` 를 세어 건수를 만들지 않는다.
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  });

  /// `J-2` 거래 상세 한 화면의 전부 — 체인 6단계·스냅샷·임계 대조·거부 추적·체결 행·이동 버튼.
  /// 🔵 `chainOf`·`findByDecisionId`·`fillChain` 은 남는다(다른 화면의 참조 링크용) — `J-2` 는
  ///    이 메서드 **하나만** 구독한다(화면이 세 결과를 조립하면 그것이 조인이다).
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId);

  /// `J-3` 사전 저널 폼 스펙(서약문·문맥 칩·규칙 인용 선택지).
  /// 🔴 제출은 `CommandApi.submitJournalDraft` — 여기는 읽기뿐이다.
  /// 🆕 v1.35(01 §44 · K296 · K300) — 인자 = **저널 id**(`AppRoutes.journalDraft` 의 `:decisionId` 그대로) · 모르는 키 = `Future` 에러 ·
  /// 서약 줄 = 재량 예산을 쓰는 목적에만(그 밖 0줄) · 인용 규칙 선택지 코드 ∈ `JournalRuleCitedCodes`.
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId);

  /// `J-5` UNKNOWN 해소 보드. 🔴 이 화면에서 `CommandApi` 호출은 0건이다(02 §3-5 수용 a).
  Stream<UnknownBoardVm> watchUnknownBoard();

  // ── 🆕 계약 v1.2(R2b 선행 M2 보강 · 01 §12-2) ─────────────────────────────

  /// 🆕 v1.2 — 결정 1건의 **사전 저널 본문**(`J-3` 읽기 뷰 `J-3R` · `J-3` executed 뒤 · iOS 의
  /// `journalDraft` 대체 · `J-2 journalLink`(작성됨)의 목적지).
  /// 결정은 있는데 저널이 아직 없으면 `body == null` 인 값을 흘린다(«미작성»도 값이다).
  /// 결정 자체가 없으면 스트림 에러 — `watchDecisionDetail` 의 **잠정** 규칙(01 §8 미결 50 ③ · ⬜ 확인
  /// 대기)과 같게 둔다. 50 ③ 이 확정되면 두 메서드를 함께 고친다(화면은 어느 쪽이든 공통 에러 상태).
  /// 🔴 화면은 `findByDecisionId`·`chainOf` 로 조립하지 않는다 — 이 스트림 하나만 구독한다.
  /// 🆕 v1.35(01 §44 · K296) — 인자 = 결정 id(J-2 «작성됨» 링크 `journalRead`) **또는** 저널 id(`J-3` executed 뒤 끼워 넣기 ·
  /// 안전 저널) 둘 다 받는다 — 해석(저널 id 먼저 · 없으면 결정 id → `decision_log.journal_id`) = 엔진 · 저널 id 로 열리면
  /// `decisionLink` = 그 저널이 붙은 결정이 있을 때만(없으면 null — 기존 «null = 부재») · 둘 다 아니면 스트림 에러(위 규칙 그대로).
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId);

  // ── 🆕 계약 v1.5(R12 선행 M2 보강 · 01 §15-3 · §8 미결 49) ─────────────────────

  /// 🆕 v1.5 — `J-1` 회차 조건의 범위 설명(회차 칩 글자 + 씨앗 기간). 키 = 셸이 라우트 파라미터에서
  /// 꺼내 `JournalTimeline(rebalanceEventId:)` 로 준 값.
  /// null = 엔진이 그 회차를 모른다 → 칩 **부재**. 🔴 엔진 규칙: null 이면 같은 id 의
  /// [watchTimeline] 은 0행이고 «없음»의 문장은 그 봉투의 `emptyLabel` 이 말한다
  /// (봉투 있는 목록 = 빈 상태 · 봉투 없는 VM(`J-2`)의 «스트림 에러» 잠정 규칙(§8 미결 50 ③)과 다른 축).
  /// 🔴 `RebalanceEvent.journalTimelineLink` 가 non-null 인 회차에 대해서는 null 을 주지 않는다.
  /// 🔴 화면이 `RebalanceRepository` 를 구독해 글자를 조립하지 않는다(그것이 조인이다).
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId);

  // ── 🆕 계약 v1.7(J-4 선행 M2 보강 · 01 §16 · §8 미결 46) ───────────────────────

  /// 🆕 v1.7 — `J-4` 채점 **대기** 카드 목록. 봉투(`ListResult`) · 빈 상태 문장 = 봉투 `emptyLabel`.
  /// 🔴 `rows` 의 [BlindReviewCard.result] 는 **늘 null** 이다(대기 = 채점 전).
  /// 🔴 엔진이 정렬해서 준다(오래된 결정부터 — K4) — 화면은 재정렬·거르기·세기 0, `rows[0]` 을 고정 카드로 쓴다.
  /// 🔴 엔진 의무: 채점이 집행돼 그 결정의 카드에 `result` 가 실리는 **같은 갱신에서** 그 결정은 이 목록에서 빠진다.
  /// 🔴 행 수 = 같은 [mode] 의 `watchTimelineBadges` «리뷰 대기 n건»의 n — 화면이 세지 않는다(배지 문구가 말한다).
  /// 🔴 큐가 비면 같은 [mode] 의 배지 목록에 `BLIND_REVIEW_PENDING` 행이 **없다**(«0건» 배지 금지 — 정상 = 무소식).
  /// 대상·진입 시점 = 엔진 규칙(K3 · 06). `hasMore` 는 늘 false(목록 전체 · `limit` 없음) — 화면 미사용.
  /// `J-4` 화면은 **인자 없이** 부른다(SIM 결정의 리뷰 = §8 미결 99).
  /// 🔵 K24 확정(2026-10-20) — v1.7 = LIVE 만: 모의투자(DRY_RUN) 기간에는 LIVE 결정이 없어 큐가 비고 봉투의
  /// `emptyLabel` 만 보인다(화면 무변경으로 뒤에 넓힐 수 있다 — X6 창).
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  });

  /// 🆕 v1.7 — `J-4` 카드 1건(고정 카드). 채점 전 = `result == null` · 채점 집행 뒤 = **같은 스트림에**
  /// `result` 가 실린 값이 온다(02 그림 M6-13 «재조회» — 화면이 다시 부르거나 기다리지 않는다).
  /// 모르는·리뷰 대상이 아닌 id = 스트림 에러(봉투 없는 VM 의 **잠정** 규칙 — §8 미결 50 ③ · `watchDecisionJournal` 과 같다).
  /// 🔴 화면은 `watchDecisionDetail`·`watchDecisionJournal`·`watchTimeline` 으로 카드를 조립하지 않는다.
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId);
}
```

---

## `packages/domain_contracts/lib/src/repositories/kill_switch_gate_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.21(01 §30 · K6) — M5-2 킬스위치 재개 게이트 읽기 창구(폰 전용 · `ui_safety` 만).
// 🆕 v1.25(01 §34 · K146) — 킬스위치 화면 읽기 창구로 넓힘(`M5-1` 화면 + `M5-2` 게이트 · 구현 = 받침대뿐 — 실측).
//
// 🔴 기존 `SafetyRepository`(배너·홈 공용 `watchState`)는 무변경 — 넓히면 UI 가짜 7 · ds 구현 · 조립 앱이 깨진다(실측).
// 🔴 상태를 바꾸는 경로 0(C-7) — 쓰기 = `SafetyActions.runKillResumeItem`.

import '../dto/safety_gate.dart';

/// 재개 게이트 한 화면.
abstract interface class KillSwitchGateRepository {
  Stream<KillResumeGateVm> watchResumeGate();

  /// 🆕 v1.25(01 §34 · K146) — `M5-1` 킬스위치 한 화면(발동 버튼 · 취소 보고 · 발동 뒤 기록 폼 · 게이트 링크).
  Stream<KillSwitchScreenVm> watchKillSwitch();
}
```

---

## `packages/domain_contracts/lib/src/repositories/ledger_repository.dart`

```dart
// 01 §4-1 — X5 정합(원장 대조) 읽기 창구.

import '../dto/ledger.dart';
import '../dto/ledger_trust.dart';
import '../primitives/list_result.dart';

/// 열린 불일치 목록 · 시스템 밖 자산 목록 · 🆕 v1.12 정정 이력.
abstract interface class LedgerRepository {
  /// 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도
  ///    주문을 막지 않는다**(01 §2-9).
  /// 🔴 `applicable == false` 인 칸은 «점검 안 함»으로 그린다 — 보드 칸 수는 모드와
  ///    무관하게 **5 고정**이다.
  /// 🆕 v1.12 주석(01 §21 · G32) — 이름은 «열린» 이지만 **최근의 해소·수용된 차이도 온다**(`L-1` 이 resolved·
  ///    accepted 를 그린다 · 최근 차이 = 열린 것 + 해소·수용된 것). 이름 바꾸기는 파괴라 별도 창(W9).
  Stream<ListResult<LedgerDiffRow>> watchOpenDiffs();

  /// 🆕 X7 — 시스템 밖 자산(`external_holding`).
  /// 🔴 이 목록은 표시 전용이며 파생 계산 경로가 읽지 않는다(C-23).
  Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings();

  /// 🆕 v1.12(01 §21 · K24) — `L-2` 정정 이력(append-only 표시판 · 순서 = 엔진(계단식 · K25) · 빈 = `emptyLabel`
  /// «정정 이력이 없습니다» · 뷰어 원천 0 = 01 §8 미결 117 — iOS·웹 = 셸 «폰에서만»).
  Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50});
}
```

---

## `packages/domain_contracts/lib/src/repositories/ledger_trust_repository.dart`

```dart
// 01 §4-1 · §10 — 🆕 X7 원장 신뢰 등급 읽기 창구.

import '../dto/ledger_trust.dart';

/// 원장 신뢰 등급 배지.
/// 🔴 `LedgerTrustGrade.selfReported` 는 **실패가 아니라 정상 운영 상태**다(01 §2-1 X7).
abstract interface class LedgerTrustRepository {
  Stream<LedgerTrustBadge> watchGrade();

  /// 🆕 v1.12(01 §21 · K8 · K36 ⓐ) — `L-3` 세션(키 = 라우트 두 값 그대로 — 그 달 `yyyy-MM` · 그 계좌 별칭).
  /// 🔴 세션을 여닫지 않는다(K9 — `SettingsActions` `selfReportSessionStart`·`Stop`) · 부작용 0(01 §1-4 «읽기»).
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  );
}
```

---

## `packages/domain_contracts/lib/src/repositories/migration_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.33(01 §42 · K266 · E16j-b) — X1 기기 이전 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 라우트 인자 0 — 한 기기 한 이전 · 열린 창 하나(엔진이 마지막 run 을 안다 · 동작 args 의 `run_id` = 엔진).
// 🔴 시작 전 · 끝난 뒤 · 거부 = 엔진 문장 VM(스트림 에러가 아니다).
// 🔴 쓰기 = `SafetyActions.run`(VM · 행의 동작 그대로 · X1 id 6 · 제출 DTO 0).

import '../dto/migration.dart';

/// X1 기기 이전 화면 셋.
abstract interface class MigrationRepository {
  /// 옛 폰 계획 교체 마법사(`x1Migration`).
  Stream<X1PlanWizardVm> watchPlanWizard();

  /// 새 폰 받기(`x1MigrationPlan` · QR 스캔 → 복원 → 복구 단계 → 게이트).
  Stream<X1RecoveryVm> watchPlanRecovery();

  /// 새 폰 비상 복구(`x1MigrationEmergency` · 복구 코드 → 펜싱 → 재발급 → 복원 → 이하 받기와 같음).
  Stream<X1RecoveryVm> watchEmergencyRecovery();
}
```

---

## `packages/domain_contracts/lib/src/repositories/onboarding_repository.dart`

```dart
// 01 §4-1 — X3 온보딩 읽기 창구. 🆕 v1.16(01 §25 · K29) — 한 화면 VM 창구 6(추가형 · `watchSteps` 무변경).

import '../dto/onboarding.dart';
import '../dto/safety.dart';
import '../enums/onboarding.dart';

/// 온보딩 읽기 창구(폰 · 엔진 로컬). 🔴 읽기 전용 — 쓰기 = `SettingsActions`·`CommandApi`.
abstract interface class OnboardingRepository {
  /// 🆕 G-01 — 🔴 **갈래별(자동 매매 / 투자 안내) 준비물 목록의 근거는 `onboarding_choice`**
  ///    이며 화면이 `OperatingMode` 를 **인자로 넘기지 않는다**. 선택 전에는 공통 단계만
  ///    오고, `O-00b` 가 선택을 저장한 뒤부터 갈래 단계가 목록에 나타난다.
  /// 🔵 v1.16 — R15 화면은 부르지 않는다(`O-01` = [watchStepList]) · 존폐 = 01 §8 미결 149.
  Stream<List<OnboardingStep>> watchSteps(OnboardingTrack t);

  /// 🆕 v1.16 — `O-00` 첫 실행 갈래.
  Stream<OnboardingStartVm> watchStart();

  /// 🆕 v1.16 — `O-00b` 운영 방식 선택(🔴 기본값 없음 = `selected` null).
  Stream<OnboardingModeChoiceVm> watchModeChoice();

  /// 🆕 v1.16 — `O-01` 단계 목록(🔴 갈래 인자 0 — 엔진이 `onboarding_choice` 로 고른다).
  Stream<OnboardingStepsVm> watchStepList();

  /// 🆕 v1.16 — `O-02`·`O-03` 단계 상세. 모르는·지난 [stepId] = `step` null + `missingLabel`(값 · 에러 아님).
  Stream<OnboardingStepDetailVm> watchStep(String stepId);

  /// 🆕 v1.16 — `O-04` 마무리 6단계.
  Stream<OnboardingFinishVm> watchFinish();

  /// 🆕 v1.16 — `R-01` 기존 계정에서 다시 시작(분기까지).
  Stream<RestartVm> watchRestart();
}
```

---

## `packages/domain_contracts/lib/src/repositories/ops_repository.dart`

```dart
// 01 §4-1 — 🆕 G-29 M8·M9 운영 상태 읽기 창구.
//
// 🔴 **읽기 전용**이고 조작은 §4-3 `SettingsActions` 다. 화면이 `SettingsActions.run()` 을
//    폴링해 상태를 만들면 경계 규칙 ① 위반이다 — 「버튼을 누르지 않았는데 값이 갱신되는
//    자리」는 전부 여기다.
// 🔴 폰 빌드는 로컬에서, viewer 는 `rm_*` 읽기 모델에서 **같은 DTO** 를 받는다(계약 3조 ①).

import '../dto/ops.dart';
import '../primitives/list_result.dart';

/// 워치독·연결·기기·백업·진단·연간 리뷰.
/// ✅ H-8 — 반환 타입 이름은 `m2-8_naming.md` G-3·G-7·G-8·G-9·G-10·F-6 이 확정한 그대로다 · 🆕 v1.24 — `watchAnnualReview` 반환 =
///    F-6 밖 새 타입 `AnnualReviewIndexVm`(K118).
abstract interface class OpsStatusRepository {
  /// `W-01` — 🆕 v1.15(01 §24 · K3) 반환 = [WatchdogBoardVm](구 `ListResult<WatchdogCheck>`).
  /// 🔴 목록 길이·이름·차례는 서버가 준다 · healthchecks 슬러그·ping URL·키는 이 창구에 오지 않는다(K4 · K17).
  Stream<WatchdogBoardVm> watchWatchdog();

  /// `S07`.
  Stream<ConnectionsVm> watchConnections();

  /// `S06` — 🔴 리스는 읽기 전용이다.
  Stream<DeviceAccessVm> watchDeviceAccess();

  /// `S09` — 🆕 v1.24(01 §33 · K110) 반환 = 교체된 [BackupVm](타입 이름 그대로 · 칸 교체 — 소비자 0 에서) · 🔴 폰 전용(뷰어 원천 0).
  Stream<BackupVm> watchBackup();

  /// `S10` — 🔴 칸 수 5 고정은 엔진이 준다(§2-9 `applicable`).
  /// 🆕 v1.13(01 §23) — `H-01` 블록 6(R13b)의 원천도 이 창구다(칸 색 = `DiagnosticCell.level` · `headline` 늘) ·
  ///    뷰어 원천 = 01 §8 미결 128.
  /// 🆕 v1.24(01 §33 · K113) — M9 `S10` 화면은 `SettingsRepository.watchDiagnosticsScreen()`(감싸개 · 같은 보드 값)을 읽는다 · 이 창구 무변경.
  Stream<DiagnosticsVm> watchDiagnostics();

  /// `S12` — 🔴 화면이 창을 «달»로 판정하지 않는다.
  /// 🆕 v1.24(01 §33 · K118 · §8 미결 95 (b)) — 반환 = **[AnnualReviewIndexVm]**(목차 전용 · 세후·수익률·`lines` 칸 0 — 타입으로 막는다) ·
  ///    ~~`AnnualReviewVm`(세후 두 필드 null 의무 · v1.6 K25)~~ · 이름 그대로(C-42 `_windowMethods` 가 쥔다) · M7 `S7-7` =
  ///    `PerformanceRepository.annualReview` 의 `AnnualReviewVm` 그대로.
  Stream<AnnualReviewIndexVm> watchAnnualReview();

  /// 🆕 v1.17(01 §26 · K17 · 01 §8 미결 123) — `H-03` 물리 리스크 점검(측정 = 플랫폼 · 판정·문구 = 엔진 · asOf 있음).
  /// 🔴 Android(operator) 화면이다 — 뷰어 빌드에는 본문이 등록되지 않는다(조립 앱 레지스트리 · 셸 가드 무변경).
  Stream<DeviceRiskVm> watchDeviceRisk();
}

/// 홈 블록 5·7 의 오늘 요약.
/// 🔴 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록 길이로 만들지 않는다
///    (double·int 산술이라 C-4 가 잡지 못한다 — 그래서 조문이 필요하다).
/// ✅ N-07(2026-10-22 · 발주자 결정) — 뷰어 원천 = `rm_ops_summary` v1 필수(01 §6-4 · 옛 열린 물음 §10-2 ⑤).
///    🆕 계약 v1.12 — 같은 표가 [watchRhythm] 의 전체 목록 열을 싣는다(열 이름 = 엔진 배치).
abstract interface class OpsSummaryRepository {
  Stream<OpsDailySummary> watchToday();

  /// 🆕 v1.12(01 §21 · §8 미결 113 · K29) — `H-02` 운영 리듬 표 전체(받은 순서 = 표 순서 · 화면이 거르거나 채우지 않는다).
  /// 🔴 [watchToday] 의 `upcoming` 은 이 목록의 **앞 ≤3 과 같은 값**이다(엔진 의무 · C-47 ⑤) · 뷰어 = `rm_ops_summary`
  ///    전체 목록 열(열 이름 = 엔진 배치).
  Stream<ListResult<OpsRhythmRow>> watchRhythm();
}
```

---

## `packages/domain_contracts/lib/src/repositories/pairing_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.16(01 §25 · K4 · K27 · 발주자 결정 2026-11-03 ③) — `V-01` 조회 전용 QR 페어링 읽기 창구.
//
// 🔴 **뷰어(iOS) 빌드에 주입된다** — 뷰어에는 `SettingsActions` 가 주입되지 않는다(settings_actions.dart 머리).
// 🔴 스캔·토큰 클레임·저장 = **플랫폼**(조립 앱 · 카메라 플러그인 = C-3 밖 · 01 §8 미결 13 과 한 창) —
//    플랫폼이 클레임한 결과를 이 스트림에 싣는다. 화면은 스캐너 자리를 비우고 결과를 그대로 그린다
//    (쓰기 0 · URL·키 수동 입력 0 · 04 §9-7).

import '../dto/onboarding.dart';

/// `V-01` 페어링 상태 읽기 창구.
abstract interface class PairingRepository {
  /// 스캔 전(`result` null) → 결과(`OK` · 실패 + 원문 코드). 폐기된 토큰 = 엔진·플랫폼이 즉시 차단해 실패로 싣는다.
  Stream<PairingVm> watchPairing();
}
```

---

## `packages/domain_contracts/lib/src/repositories/performance_repository.dart`

```dart
// 01 §4-1 — 성과·리포트(M7) 읽기 창구.
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간 차액도
//    금지이며 C-30 이 검사한다(01 §2-4).

import '../dto/performance.dart';
import '../enums/performance.dart';
import '../primitives/date_range.dart';

/// 성과 시리즈 · 월간 리포트 · 세후 사다리 + G-41 뷰모델 창구 5종(+ 🆕 v1.4 목표 경로).
/// 🆕 v1.4 주석 정정 — G-41 «6종» = 여기 5종 + `RebalanceRepository.watchNext` 1.
abstract interface class PerformanceRepository {
  /// `S7-2` 성과 시리즈.
  /// 🆕 v1.3 — `range == null` = **엔진 기본 구간**(주기마다 엔진이 고른다).
  ///    무엇이 골라졌는지는 `PerformanceSeries.periodLabel` 이 말한다.
  /// 🔴 `granularity: weekly` 는 v1.3 에서 화면이 부르지 않는다(01 §8 미결 54 — 주 경계).
  Future<PerformanceSeries> series({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,
    DateRange? range,
  });

  /// 기본 창구.
  Future<MonthlyReport> monthlyReport(String yyyyMm);

  /// 🆕 P 회차 — 세후 사다리(§2-4). 기존 2종에 **추가**되는 세 번째 창구다.
  /// 🔴 갈래는 인자가 아니라 **계좌 매핑에서 파생**한다 — 화면이 갈래를 고르지 못한다.
  /// 🔴 인자는 **연도 하나**다. 임의 구간(`DateRange`)을 받지 않는다 — 세후는 연 1회
  ///    산출이고, 구간을 화면이 고르면 «어느 창의 세후가 진짜인가»를 화면이 판정하게 된다.
  /// 🔴 보정판 산식 확정 전에는 `isReferenceOnly == true` 인 골든 참고 사다리만 돌아온다(§8-18).
  /// 🆕 v1.6 무변경 — R12 소비자 0(`S7-7` 세후는 `AnnualReviewVm.afterTax`).
  Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear});

  // ───── 🆕 G-41 — M7 뷰모델 창구 5종(여섯째 = `RebalanceRepository.watchNext`) ─────

  /// `S7-1b` — 🔴 수치 필드가 없는 월 목록이다.
  /// 🆕 v1.3 — `rows` 는 엔진이 **최신 달부터** 정렬해서 준다. 화면은 재정렬·묶기를 하지 않는다.
  Future<ReportArchiveVm> reportArchive();

  /// `S7-2G` 열람 게이트. 🔴 이번 달 열람 횟수는 **명령 테이블(append-only)의 집계**이며
  ///    화면이 세지 않는다(G-42). 화면이 「n회」를 숫자로 조립하지 않는다.
  Stream<DisclosureGateVm> watchDisclosureGate();

  /// `S7-3` 드로다운 맥락.
  /// 🆕 v1.1(C4 R2-Gem Q1) — `range == null` = **엔진 기본 구간**. 그 결과가 무엇인지는
  ///    `DrawdownContextVm.periodLabel` 이 말한다 — 화면은 기본 구간을 알 필요가 없다.
  Future<DrawdownContextVm> drawdownContext({DateRange? range});

  /// `S7-3b` 슬리브 기여 분해.
  /// 🔴 월 납입 설정과 무관한 타입이다 — `MonthlyContributionVm` 과 이름을 공유하지 않는다(§2-6).
  Future<ContributionVm> contribution({required DateRange range});

  /// `S7-7` — 🆕 v1.6 [year] == null = **엔진 기본 연도**(06 M1-20b · K24 — 권고: 12월 창 열림 = 그해 ·
  /// 그 밖 = 마지막 완결 연도 · 완결 연도가 없으면(운용 첫 해) 그해). 고른 연도는 `vm.yearLabel` 이 말한다.
  /// 🔴 `S7-7` 은 **이 창구 하나만** 쓴다 · `OpsStatusRepository.watchAnnualReview` 는 M9 `S12` 몫 —
  ///    🆕 v1.24 **다른 타입** `AnnualReviewIndexVm`(세후·수치 칸 0 · 01 §33 K118).
  /// 🔴 세후는 VM 의 `afterTax`·`afterTaxCounterfactual` 이 싣는다 — `S7-7` 은 [afterTaxLadder] 를 부르지 않는다.
  Future<AnnualReviewVm> annualReview({String? year});

  // ───── 🆕 v1.4 — S7-9 목표 경로(01 §14-9) ─────

  /// `S7-9` 목표 경로 — [yyyyMm] 은 `MonthlyReport.goalDeepLink`(`AppRoutes.reportGoalPath`)가
  /// 준 그 달이다. 화면은 받은 달 그대로 넘긴다(달을 고르거나 바꾸지 않는다).
  /// 🔴 null 링크(과거 달·가림·미생성)면 화면은 이 메서드에 닿지 않는다.
  /// 🔴 숫자 가림(무결성 등)은 엔진 읽기 경로가 한다 — 화면은 배너만 그린다(03 §1-4).
  Future<GoalPathVm> goalPath({required String yyyyMm});
}
```

---

## `packages/domain_contracts/lib/src/repositories/pledge_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.21(01 §30 · K6) — 서약 읽기 창구(M5-8 · `O-04` ② 슬롯 위젯 · 재생처).
//
// 🔴 J-3 의 `JournalDraftFormSpec.pledgeLines` 는 그대로(엔진이 같은 원문을 싣는다 — 원문은 한 번만).
// 🔴 상태를 바꾸는 경로 0(C-7) — 쓰기 = `SafetyActions.runPledge`.

import '../dto/safety_gate.dart';

/// 서약 지금 판.
abstract interface class PledgeRepository {
  Stream<PledgeVm> watchPledge();
}
```

---

## `packages/domain_contracts/lib/src/repositories/postmortem_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.39(01 §48 · K345 · 01 §8 미결 188 · 13 §8 R243 P3 ⓑ) — `M5-4` postmortem 읽기 창구(`ui_safety` 만 · 폰 전용).
//
// 🔴 기존 `IncidentRepository`(D-01 배너 · 셸 주입 · 뷰어) 무변경 — 배너는 0/1건, 이 창구는 써야 할 사건 목록(`BlockBoardRepository` 선례).
// 🔴 쓰기 = `SafetyActions.runPostmortem` 하나(상태를 바꾸는 경로 0 — C-7).

import '../dto/postmortem.dart';

/// `M5-4` 한 화면.
abstract interface class PostmortemRepository {
  Stream<PostmortemListVm> watchPostmortems();
}
```

---

## `packages/domain_contracts/lib/src/repositories/rebalance_repository.dart`

```dart
// 01 §4-1 — 리밸런싱(M7) 읽기 창구.

import '../dto/rebalance.dart';
import '../primitives/date_range.dart';
import '../primitives/list_result.dart';

/// 리밸런싱 회차 목록 · 회차 1건 · 다음 회차 예상.
abstract interface class RebalanceRepository {
  /// `S7-6a` 회차 타임라인 — 봉투(`ListResult`) · 빈 상태 문장 = 봉투 `emptyLabel`(v1.5).
  /// 🆕 v1.6(01 §15-4 · 발주자 결정 ① · §8 미결 88 의 «범위 고르기» 몫 · K26) — [range] == null =
  ///    **전체 기간**(첫 회차부터 · 기간으로 자르지 않는다). 이름 인자 꼴은 v1.3 `series(range:)` 선례지만
  ///    뜻은 다르다 — `series` 의 null 은 «엔진이 고른 구간»이라 `periodLabel` 이 말하고, 여기의 null 은
  ///    **고르지 않음**이라 말할 기간이 없다(그래서 봉투에 기간 글자를 두지 않는다 · 비평 #10).
  ///    어느 모드(LIVE·SIM)의 행이 오는지는 §8 미결 89. 🔴 R12 화면은 **인자 없이** 부른다 — 화면이
  ///    `DateRange` 를 만들지 않는다. `ListResult.hasMore` 는 전체 기간·`limit` 없음이라 늘 false — 화면 미사용.
  /// 🔴 `rows` 는 엔진이 **시간 역순**으로 정렬해서 준다(03 §11-a) · 화면은 재정렬·거르기·세기 0.
  Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range});

  /// 🆕 v1.5(01 §15-3 ★ⓐ) — `S7-6b` 회차 1건. `S7-6b`(`RebalanceEventScreen`)는 파라미터 라우트
  /// `rebalanceEvent` 의 `:rebalanceEventId`(셸 → 생성자 인자 → 키)로 **이 창구 하나만** 구독한다.
  /// 🔴 [watchEvents] 행을 id 로 고르면 반려(거르기도 판정이다).
  /// 모르는·지난 id = 스트림 에러(**잠정** — `JournalRepository.watchDecisionDetail` 과 같은 묶음 ·
  /// §8 미결 50 ③ 확정 때 함께 고친다).
  Stream<RebalanceEvent> watchEvent(String rebalanceEventId);

  /// 🆕 G-41 — 다음 회차 예상(`S7-6c` · `H-02` D-7 예고 행).
  /// 무변경 — 단 v1.6 에서 [NextRebalanceVm] 의 두 글자가 nullable 이 되고 `asOf` 가 생겼다.
  /// 🔴 `dDayText`·`expectedDateText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
  /// 🔴 **nullable 이 아니다**(N-4) — 「예정 없음」도 **값으로** 오며 그 상태의 유일한
  ///    문구가 `emptyLabel` 이다. null 을 허용하면 화면이 「예정된 회차 없음」을 스스로
  ///    쓰게 되어 계약 3조 ③(빈 상태 문구도 엔진 생성)이 깨진다.
  Stream<NextRebalanceVm> watchNext();
}
```

---

## `packages/domain_contracts/lib/src/repositories/repair_wizard_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.32(01 §41 · K249 · E16j-a) — X5 정정 마법사 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 [targetId] null = 허브(열린 대상 고르기 · `x5RepairWizard`) · 값 = 대상 화면(`x5RepairTarget/:targetId` · `ld-…` diff id 또는 `li-…`
//    무결성 합성 id — 라우트 인자 그대로 · 화면은 해석하지 않는다).
// 🔴 모르는 · 닫힌 대상 = 엔진 문장 VM(스트림 에러가 아니다 · `doneLabel` 또는 `headline`).
// 🔴 쓰기 = `SafetyActions`(행 · VM 의 동작 그대로 · 제출 DTO 3).

import '../dto/repair.dart';

/// X5 정정 마법사 한 화면.
abstract interface class RepairWizardRepository {
  Stream<RepairWizardVm> watchRepair({String? targetId});
}
```

---

## `packages/domain_contracts/lib/src/repositories/resume_gate_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.22(01 §31 · K6 · K64) — X2 재개 게이트 읽기 창구(`x2ResumeGate` · `ui_safety` 만).
// 🆕 v1.25(01 §34 · K156) — X2 재개 화면 읽기 창구로 넓힘(게이트 + 리포트 감싸개 · 구현 = 받침대뿐 — 실측).
//
// 🔴 기존 `ResumeRepository`(`watchLatest` · `watchPlannedWork`)는 무변경 — ds `SqliteResumeRepository` 가 implements(실측).
// 🔴 쓰기 = `SafetyActions.run(seasonalWindowChoice, …)`(행의 `actions` 그대로).

import '../dto/resume.dart';

/// 재개 게이트 한 화면.
abstract interface class ResumeGateRepository {
  Stream<ResumeGateVm> watchGate();

  /// 🆕 v1.25(01 §34 · K156) — X2 재개 리포트 한 화면(감싸개 · 🔴 `ResumeRepository` 무변경 — ds 가 implements).
  Stream<ResumeReportVm> watchReport();
}
```

---

## `packages/domain_contracts/lib/src/repositories/resume_repository.dart`

```dart
// 01 §4-1 — X2 재개 읽기 창구.

import '../dto/resume.dart';

/// 최근 재개 리포트 · 계획된 작업 목록.
abstract interface class ResumeRepository {
  /// 🔴 `ResumeReport` 에는 손익 필드가 없다(01 §2-7).
  Stream<ResumeReport?> watchLatest();

  Stream<List<PlannedWorkSummary>> watchPlannedWork();
}
```

---

## `packages/domain_contracts/lib/src/repositories/rule_change_gate_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.26(01 §35 · K179) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판» 읽기 창구(폰 전용 · `ui_safety` 만).
//
// 🔴 냉각이 끝나면 새 VM(`approveLabel` 생김) — 화면 카운트다운 0.
// 🔴 쓰기 = `SafetyActions.runRuleChangeRequest`(요청) · `runRuleChangeApproval`(승인) · `run(ruleChangeCancel)`(행의 `cancel` 그대로).

import '../dto/safety_gate.dart';

/// 규칙 변경 게이트 한 화면.
abstract interface class RuleChangeGateRepository {
  Stream<RuleChangeGateVm> watchGate();
}
```

---

## `packages/domain_contracts/lib/src/repositories/runbook_repository.dart`

```dart
// 🆕 계약 v1.17(01 §26 · K12) — M8 `D-02` DR 런북 · `D-03` 오프라인 긴급정지 카드 읽기 창구.
// 🔴 원고 = M2 번들(03_실행 §10-5 · 04_안전장치 §5-5) — 뷰어도 같은 번들을 읽는다(폰이 죽어도 열린다 · 발주자 결정 ③).

import '../dto/incident.dart';

/// `D-02`·`D-03` 문서 창구(읽기 전용 · 쓰기 0).
abstract interface class RunbookRepository {
  /// `D-02` 목록.
  Stream<RunbookIndexVm> watchRunbookIndex();

  /// `D-02` 상세 — 모르는 id = `RunbookVm.missingLabel`(스트림 에러 아님).
  Stream<RunbookVm> watchRunbook(String runbookId);

  /// `D-03` 카드.
  Stream<EmergencyCardVm> watchEmergencyCard();
}
```

---

## `packages/domain_contracts/lib/src/repositories/safety_repository.dart`

```dart
// 01 §4-1 — 안전 상태(M5·M8) 읽기 창구.
//
// 🔴 소유 경계는 타입이 아니라 «무엇을 그리는가»다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**다. C-7 이 그 표대로 검사한다.

import '../dto/safety.dart';

/// 브레이커·차단 플래그·킬스위치 표시 상태.
abstract interface class SafetyRepository {
  Stream<SafetyState> watchState();
}
```

---

## `packages/domain_contracts/lib/src/repositories/self_audit_resolve_repository.dart`

```dart
// 01 §4-1 — 🆕 계약 v1.37(01 §46 · K318 · 01 §8 미결 224) — `M5-13` 원장 실사 해소 게이트 읽기 창구(`ui_safety` 만 · 상태를 바꾸는 경로 0 — C-7).
//
// 🔴 기존 `LedgerTrustRepository`(배지 · `L-3` 세션) · `LedgerRepository`(`L-1`) · `BlockBoardRepository`(`M5-5`) 무변경 —
//    해소 게이트는 플래그 · 두 카운터 · 열린 자가 보고 차이 · 보관 명령을 한 스트림으로 감싼다(v1.25 K154 결).
// 🔴 쓰기 = `SafetyActions.run(heldCommandsConfirm, {review_id})`(엔진 완성 `SelfAuditResolveVm.confirmHeld`) 하나 · 플래그 해제 동작 0.

import '../dto/self_audit.dart';

/// `M5-13` 한 화면.
abstract interface class SelfAuditResolveRepository {
  Stream<SelfAuditResolveVm> watchResolve();
}
```

---

## `packages/domain_contracts/lib/src/repositories/settings_repository.dart`

```dart
// 01 §4-1 · 🆕 계약 v1.18(01 §27 · K-c · K-v) — M9 설정 화면 읽기 창구.
//
// 🔴 뒤 카드가 **추가형**으로 늘린다(✅ v1.19 R6c `watchOperations` · ✅ v1.20 R7 `watchCredentials`·`watchAccountMapping` · ✅ v1.23 R8a `watchContribution` · ✅ v1.24 R9 `watchDiagnosticsScreen` · ✅ v1.28 S04 `watchAllocationEditor`(첫 판 보기 전용 · 01 §37) · S11 `watchGeneral` = ⏸ R9e 창(엔진 원천 뒤 — 01 §8 미결 197)) — 받침대 `UnimplementedSettingsRepository` 를 같은 커밋에서 고친다.
// 🔴 `S07` 은 이 창구가 아니라 [OpsStatusRepository.watchConnections] 다(v1.0 부터 · 두 벌 0).
// 🔴 `S06` 은 이 창구가 아니라 [OpsStatusRepository.watchDeviceAccess] 다(v1.0 부터 · 두 벌 0 · v1.20 K14).
// 🔴 `S13` 의 값은 `ConfigRepository.watchContributionSetting()` 과 **같은 값 하나**(엔진 `contributionSettingOf`)의 화면 투영이다 — 두 벌 0(🆕 v1.23 K78).
// 🔴 `S10` 의 보드는 `OpsStatusRepository.watchDiagnostics()`(H-01)와 **같은 값 하나**(엔진 `diagnosticsOf`)를 감싸개 칸으로 싣는다 — 두 벌 0(🆕 v1.24 K113).

import '../dto/accounts.dart';
import '../dto/allocation.dart'; // 🆕 v1.28
import '../dto/operations.dart';
import '../dto/ops.dart';
import '../dto/settings.dart';

abstract interface class SettingsRepository {
  /// `S01` 설정 홈 — 폰·뷰어 같은 DTO(뷰어 판 = 폰 전용 행을 엔진이 뺀 VM).
  Stream<SettingsHomeVm> watchHome();

  /// 🆕 v1.19(01 §28) — `S05` 운용 관리(🔴 폰 전용 · 뷰어 원천 0 · K20).
  Stream<OperationsVm> watchOperations();

  /// 🆕 v1.20(01 §29) — `S02` 증권사 키 관리(🔴 폰 전용 · 값·키 조각 0 · K7).
  Stream<CredentialListVm> watchCredentials();

  /// 🆕 v1.20(01 §29) — `S03` 계좌 연동·슬리브 매핑(🔴 폰 전용 · 계좌 전체번호 0).
  Stream<AccountMappingVm> watchAccountMapping();

  /// 🆕 v1.23(01 §32 · K78) — `S13` 월 납입 설정(🔴 폰 전용 · 뷰어 원천 0 · 값의 원천 = 엔진 `contributionSettingOf` 하나 —
  ///    S7-4·H-02 는 그대로 `ConfigRepository.watchContributionSetting()`).
  Stream<MonthlyContributionVm> watchContribution();

  /// 🆕 v1.24(01 §33 · K113) — `S10` 진단(🔴 폰 전용 · 뷰어 원천 0 · 감싸개 한 스트림 — 보드 = `OpsStatusRepository.watchDiagnostics()`
  ///    와 같은 값(엔진 `diagnosticsOf` 하나) · `watchDiagnostics` 는 무변경(H-01 몫)).
  Stream<DiagnosticsScreenVm> watchDiagnosticsScreen();

  /// 🆕 v1.28(01 §37 · K199) — `S04` 배분 화면 첫 판(보기 전용 · 🔴 폰 · 뷰어 공통 — 뷰어 원천 = `rm_config_view` 배분 7열 ·
  /// `AllocationReadModelColumns`). 🔴 운영 설정을 못 읽으면 스트림 오류(구현 · 엔진 기본값 대입 0 — K206).
  Stream<AllocationEditorVm> watchAllocationEditor();
}
```

---

## `packages/domain_contracts/lib/src/repositories/what_if_api.dart`

```dart
// 01 §4-1 — M3 미리보기.
//
// 🔴 리포지토리가 **아니라** 부작용 0의 로컬 재계산이다(결정 2 파생 · `core_engine/lib/src/whatif/`).
//    03(M7 명세) §1-5 의 `WhatIfApi` 가 이것이며 이름은 **여기가 정본**이다
//    (구 `PlannerRepository` 폐기). DB 를 건드리지 않는다.
// 🆕 v1.4(01 §14-8) — «부작용 0» = 원장·명령 테이블 쓰기 0 이다. 계획 스냅샷(`plan_snapshot`)은
//    등록 대조용 **엔진 로컬 캐시**라 이 조문과 모순되지 않는다(06 M3-1).
// 🔴 v1.4 호출 표(01 §14-8) — 플래너(S7-4)는 `simulateDeposit` 만 부른다(«미리보기 계산» 탭 ·
//    «다시 계산» 탭 · 에러 재시도). 늦게 온 이전 요청 결과는 버린다(마지막 요청만).
//    `estimateCosts`·`findPlan`·`previewRebalance` 는 플래너가 부르지 않는다.
// 🆕 v1.6 호출 표(01 §15-4) — `S7-6c` 는 `previewRebalance` 만 부른다(«지금 기준 초안 보기» 탭 뒤 ·
//    인자 없이 · 결과 캐시 0 · 마지막 요청만). `estimateCosts`·`findPlan`·`simulateDeposit` 은
//    `S7-6c` 가 부르지 않는다. 자세한 표는 [WhatIfApi.previewRebalance] 머리.

import 'package:decimal/decimal.dart';

import '../dto/plan.dart';
import '../primitives/money.dart';

/// 입금·인출·리밸런싱 미리보기.
abstract interface class WhatIfApi {
  /// 🆕 v1.4 — [amountInput] 은 **입력칸 글자 그대로**다(자르기·쉼표 제거·숫자 검사를 화면이
  /// 하지 않는다). 파싱·빈칸·0·음수·범위·차단(재개 미완·복구·원장 무결성·계좌 매핑 미완)
  /// 판정은 전부 구현체가 하고, 결과는 [DepositPreviewResult] 의 세 갈래(plan · 입력 거부 ·
  /// 차단) 중 하나로 돌려준다. 계좌 라우팅도 엔진 몫이다(구 `accountAlias` 인자 삭제).
  /// 🔴 `Future` 에러는 «계산을 못 했다»(인프라)만 뜻한다 — 화면은 공통 에러 뷰 + 입력 유지 +
  ///    같은 글자로 재시도이며 에러 내용으로 분기하지 않는다.
  Future<DepositPreviewResult> simulateDeposit({required String amountInput});

  /// ⏸ v1.4 무변경 — 인출 규칙 결정 뒤 첫 minor(S7-5 · 01 §14-15 «예정»)에서
  ///    `({required String amountInput}) → WithdrawalPreviewResult` 로 바뀐다.
  Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount});

  /// 🆕 v1.6(01 §15-4 · 결정 ②) — `S7-6c` «지금 기준 초안 보기». 호출 표:
  /// ① 그 버튼 **탭 뒤에만**, 인자 없이 부른다 — 진입·알림·`watchNext` 값만으로는 호출 0.
  /// ② 결과 캐시 0 · 늦게 온 이전 요청 결과는 버린다(마지막 요청만).
  /// ③ `Future` 에러 = «계산을 못 했다»(인프라)만 뜻한다 — 화면 = 초안 영역 에러 + 같은 버튼
  ///    재시도 · 에러 내용으로 분기 0.
  /// ④ [plannedDate] == null = 엔진이 `watchNext` 와 **같은 판정의 다음 예정 회차**를 지금 as-of
  ///    데이터로 미리 본다 — 그날은 `RebalancePreview.plannedDateText` 가 말한다. 인자는 엔진·테스트용.
  /// ⑤ 예정 회차가 없거나 계산이 막히면 `blockedText`(엔진 문장)로 온다 — 화면이 flagId 로 버튼을
  ///    끄지 않는다(D21 준용).
  /// 🔴 `estimateCosts`·`findPlan` 은 `S7-6c` 가 부르지 않는다.
  Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate});

  Future<CostEstimate> estimateCosts(String planId);

  /// 🆕 v1.4 — null = 그 planId 가 없다. 만료·등록 불가는 `DepositPlan.registerBlockedText` 로
  /// 온다 — 화면이 `expiresAt` 을 시계와 비교하지 않는다.
  Future<DepositPlan?> findPlan(String planId);
}
```

---

## `packages/domain_contracts/lib/src/schema/ledger_file.dart`

```dart
// 로컬 원장 두 파일과 SIM 판 파생 규칙 — 01 §6-0 · §9-2 · 설계 13 §8 R19 E9-2 · R20 Q1.
//
// 🔴 **파일이 경계다.** `ledger.sqlite`(LIVE)와 `ledger_sim.sqlite`(SIM 계열)는 같은 전체 스키마를 갖고,
//    다른 것은 `ddl/*.sql` 에서 줄 끝에 `-- @sim <종류>` 가 붙은 CHECK 뿐이다. 이 파일이 그 치환의
//    **코드 정본**이다(ddl/README «두 파일» 표와 같은 값 · C-15 가 대조한다).
// 🔴 열 때는 `PRAGMA application_id` 를 [LedgerFile.applicationId] 와 대조한다 — `mode` 칸이 없는
//    표까지 한 번에 덮는 파일 식별이다(R20 Q1). 대조는 로컬 러너(data_sync · E9c) 몫이다.
// 🔴 SQL 을 실행하지 않는다 — 문자열만 바꾼다(이 패키지는 DB 를 의존하지 않는다 · 01 §1-1).
// 🔵 열거형(enum)이 아니라 상수 클래스다 — 이 값들은 JSON 으로 오가지 않으므로 `@JsonValue`·`wire`
//    규약(C-12 · 01 §1-2)의 대상이 아니다.

import '../enums/mode.dart';

/// 로컬 원장 파일 — 01 §9-2(파일 분리 = 경계).
final class LedgerFile {
  const LedgerFile._(this.fileName, this.applicationId);

  /// 실계좌(`RunMode.live`). `application_id` = 'AAQL'.
  static const LedgerFile live = LedgerFile._('ledger.sqlite', 0x4141514C);

  /// 모의 계열(`RunMode.simInternal`·`RunMode.simBroker`). `application_id` = 'AAQS'.
  static const LedgerFile sim = LedgerFile._('ledger_sim.sqlite', 0x41415153);

  /// 두 파일 전부.
  static const List<LedgerFile> values = <LedgerFile>[live, sim];

  /// 기기 안 파일 이름.
  final String fileName;

  /// `PRAGMA application_id` 값 — 열 때 대조한다.
  final int applicationId;

  /// [mode] 가 쓰는 파일. 🔴 판정은 [RunModeIsSim.isSim] 하나로만 한다.
  static LedgerFile of(RunMode mode) => mode.isSim ? sim : live;

  @override
  String toString() => 'LedgerFile($fileName)';
}

/// `-- @sim <종류>` 태그의 종류 — LIVE 판 식과 SIM 판 식(ddl/README «두 파일»).
final class LedgerModeCheck {
  const LedgerModeCheck._(this.tag, this.liveExpr, this.simExpr);

  /// 결정 → 주문 → 체결 → 성과 사슬(`decision_log`·`order_intents`·`trades`·`equity_snapshot`·`rebalance_event`).
  static const LedgerModeCheck ledger = LedgerModeCheck._(
    'ledger',
    "mode = 'LIVE'",
    "mode IN ('SIM_INTERNAL','SIM_BROKER')",
  );

  /// 안내(`advice_batch`·`advice`) — `simBroker × advisory` 는 정의 모순이라 SIM 판도 `SIM_INTERNAL` 만.
  static const LedgerModeCheck advice = LedgerModeCheck._(
    'advice',
    "mode = 'LIVE'",
    "mode = 'SIM_INTERNAL'",
  );

  /// 캘린더 앵커(`calendar_link`·`calendar_sync_state`) — 계열 2값(G-32).
  static const LedgerModeCheck calendar = LedgerModeCheck._(
    'calendar',
    "mode = 'LIVE'",
    "mode = 'SIM'",
  );

  /// `order_intents.operating_mode` — SIM 판에서 `simBroker × advisory` 를 막는다(C8).
  static const LedgerModeCheck intentOperatingMode = LedgerModeCheck._(
    'intent-operating-mode',
    "operating_mode IN ('AUTO_TRADE','ADVISORY')",
    "operating_mode IN ('AUTO_TRADE','ADVISORY') AND "
        "(operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL')",
  );

  /// 🆕 v1.22(01 §31 · K61 · SPEC 02 :731 v2.44) — `executions.fill_origin`(배치 F) · 🔴 실계좌 파일은 `SIMULATED`(엔진 내부
  /// 가상 체결 · ds `order_ledger.dart:509-510`)를 받지 않는다. ⏸ `ddl/batch_f_x7_advisory.sql` 의 태그 줄 = **엔진 재생성 PR**
  /// (data_sync 배치 사본이 원문과 바이트 대조 — 같은 커밋에서만 움직인다 · v1 동결 12-21 전 · 01 §8 미결 189) · 그 전에는
  /// 두 파일이 같은 4값 CHECK 를 갖는다(C-56 ⑮ 두 상태 허용).
  static const LedgerModeCheck fillOrigin = LedgerModeCheck._(
    'fill-origin',
    "fill_origin IN ('BROKER','MANUAL','BROKER_RECOVERED')",
    "fill_origin IN ('BROKER','MANUAL','SIMULATED','BROKER_RECOVERED')",
  );

  /// 다섯 종류 전부(🆕 v1.22 +[fillOrigin]).
  static const List<LedgerModeCheck> values = <LedgerModeCheck>[
    ledger,
    advice,
    calendar,
    intentOperatingMode,
    fillOrigin,
  ];

  /// `-- @sim` 뒤에 오는 이름.
  final String tag;

  /// LIVE 판(`ddl/*.sql` 에 적힌 그대로)의 식.
  final String liveExpr;

  /// SIM 판의 식.
  final String simExpr;

  /// [file] 판의 식.
  String exprFor(LedgerFile file) =>
      identical(file, LedgerFile.sim) ? simExpr : liveExpr;

  @override
  String toString() => 'LedgerModeCheck($tag)';
}

/// 코드가 있는 줄의 **끝**에 붙은 태그만 태그다 — 설명 주석의 `@sim` 낱말을 태그로 읽지 않는다.
final RegExp _tagAtEnd = RegExp(r'^(.*\S.*?)\s*--\s*@sim\s+([A-Za-z-]+)\s*$');

/// LIVE 판 SQL [liveSql] 에서 [file] 판을 만든다.
///
/// 태그가 붙은 줄은 그 종류의 LIVE 식을 **정확히 한 번** 담아야 하고, SIM 판에서는 그것을 SIM 식으로
/// 바꾼다. 모르는 종류 · 식이 없거나 두 번 이상인 줄은 [FormatException] — 치환이 조용히 빠지면
/// 모의 파일이 LIVE 행만 받거나(전부 거부) 반대로 실계좌 파일이 SIM 행을 받는다.
String ledgerDdlFor(LedgerFile file, String liveSql) {
  final List<String> lines = liveSql.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final RegExpMatch? m = _tagAtEnd.firstMatch(lines[i]);
    if (m == null || m.group(1)!.trimLeft().startsWith('--')) continue;
    final String name = m.group(2)!;
    final LedgerModeCheck kind = LedgerModeCheck.values.firstWhere(
      (LedgerModeCheck k) => k.tag == name,
      orElse: () =>
          throw FormatException('모르는 @sim 종류 «$name»', lines[i], i + 1),
    );
    final int n = kind.liveExpr.allMatches(lines[i]).length;
    if (n != 1) {
      throw FormatException(
        '@sim ${kind.tag} 줄에 «${kind.liveExpr}» 가 $n번 있다(정확히 1번이어야 한다)',
        lines[i],
        i + 1,
      );
    }
    lines[i] = lines[i].replaceFirst(kind.liveExpr, kind.exprFor(file));
  }
  return lines.join('\n');
}
```

---

## `packages/domain_contracts/lib/src/schema/read_model_columns.dart`

```dart
// 영역 H — 🆕 계약 v1.28(01 §37 · §6-4 · K201) 읽기 모델 열 이름.
//
// 🔴 `rm_*` DDL 은 손으로 적지 않는다(파생 생성기 06 M4-1 · `ddl/batch_d_supabase.sql` §읽기 모델) — 여기는 **열 이름만** 둔다.
//    뷰어 «열 → VM» 함수(`read_model_client` · 계약만 의존 — 엔진 상수를 못 본다)와 엔진 push 가 같은 글자를 쓰게 하는 자리다.
// 🔴 G-22 — 읽기 모델 열 ⊇ DTO 필수 칸.

/// `rm_config_view` S04 배분 7열(엔진 `RmConfigViewAllocationColumns` 글자 1:1 · 🔴 타입 이름 ≠ 엔진).
/// 규칙 5조 4칸(`row_version` · `lease_epoch` · `pushed_at` · `mode`) · 버전 스탬프 3 = push 층.
abstract final class AllocationReadModelColumns {
  /// 카드 프로파일 글자(text) — `AllocationProfileCard.label`.
  static const String label = 'allocation_label';

  /// 카드 비중 한 줄(text) — `AllocationProfileCard.weightsText`.
  static const String weightsText = 'allocation_weights_text';

  /// 카드 백테스트 한 줄(text) — `AllocationProfileCard.backtestText`.
  static const String backtestText = 'allocation_backtest_text';

  /// 카드 정직 기대 줄(text) — `AllocationProfileCard.honestNoteText`.
  static const String honestNoteText = 'allocation_honest_note_text';

  /// 읽기 묶음(jsonb — `[AllocationReadOnlySection.toJson()]` · 받은 순서).
  static const String sections = 'allocation_sections';

  /// 바꾸는 길 안내(jsonb — 글자 목록 · 받은 순서).
  static const String changePathLines = 'allocation_change_path_lines';

  /// 기준 시각(jsonb — `AsOf.toJson()`).
  static const String asOf = 'allocation_as_of';

  /// 전부(이 차례).
  static const List<String> all = <String>[
    label,
    weightsText,
    backtestText,
    honestNoteText,
    sections,
    changePathLines,
    asOf,
  ];
}
```

---

## `packages/domain_contracts/lib/src/schema/read_model_tables.dart`

```dart
// 영역 H — 🆕 계약 v1.36(01 §45 · §6-4 · 지도 D15 · 13 R230 L2 · K303~K316) 읽기 모델 `rm_*` 표 22 — 열 · 키 · 형 · 결속 DTO.
//
// 🔴 이 파일이 `rm_*` DDL 의 정본이다 — 생성기(data_sync E11l1 · Dart 순수 함수) · 엔진 push(E11l2) · 뷰어(`read_model_client`)가
//    같은 글자를 쓴다. DDL 은 손으로 적지 않는다(`ddl/batch_d_supabase.sql` §읽기 모델 · 06 M4-1).
// 🔴 열 = 결속 DTO `toJson()` 최상위 키(접두 · 제외 · 펼침 한 겹) + DTO 밖 열 + 규칙 5조 4칸 — C-69 가 표본 인스턴스로 대조한다(G-22).
//    뷰어 = 행에서 접두를 떼고(펼친 키는 다시 묶고) 제외 키에 뷰어 판 값을 넣어 `X.fromJson` 한 번(C-69 ⑥ 왕복).
// 🔴 형 = 와이어 그대로(글자 → text · 정수 → bigint · 실수 → double precision · 참거짓 → boolean · 객체 · 목록 → jsonb) ·
//    규칙 5조 칸만 bigint · timestamptz · NOT NULL = 키 열 + 규칙 5조 4칸뿐(DTO 모양 판정 = 뷰어 `fromJson(row)` · 못 읽으면 던짐 — K206).
// 🔴 수치(돈 · 안전 문턱)를 이 파일에 적지 않는다 — 열 이름 · 형 · 사유 글자뿐.
// 🔵 v1.28 `AllocationReadModelColumns`(`read_model_columns.dart`) = `rm_config_view` 의 `allocation_*` 7열 그대로(C-69 ⑨).

/// 열 형(와이어 그대로 — K305).
/// 🔵 와이어 열거가 아니다(JSON 으로 나가지 않는다 — C-12 밖) — Postgres 형 글자를 담는 상수 다섯 + `timestamptz`.
final class ReadModelColumnType {
  const ReadModelColumnType._(this.sql);

  /// `text`.
  static const ReadModelColumnType text = ReadModelColumnType._('text');

  /// `bigint`.
  static const ReadModelColumnType bigint = ReadModelColumnType._('bigint');

  /// `double precision`.
  static const ReadModelColumnType doublePrecision = ReadModelColumnType._(
    'double precision',
  );

  /// `boolean`.
  static const ReadModelColumnType boolean = ReadModelColumnType._('boolean');

  /// `jsonb`.
  static const ReadModelColumnType jsonb = ReadModelColumnType._('jsonb');

  /// `timestamptz` — 규칙 5조 `pushed_at` 만.
  static const ReadModelColumnType timestamptz = ReadModelColumnType._(
    'timestamptz',
  );

  /// 전부(이 차례).
  static const List<ReadModelColumnType> values = <ReadModelColumnType>[
    text,
    bigint,
    doublePrecision,
    boolean,
    jsonb,
    timestamptz,
  ];

  /// Postgres 형 글자.
  final String sql;

  @override
  String toString() => sql;
}

/// 열 하나.
final class ReadModelColumn {
  const ReadModelColumn(
    this.name,
    this.type, {
    this.checkValues = const <String>[],
  });

  /// 열 이름(snake · DTO 와이어 키 그대로).
  final String name;

  /// 형.
  final ReadModelColumnType type;

  /// `check (… in (…))` 값 — 빈 = check 없음(`mode`(규칙 5조 ①) · `operating_mode`(§8-19)만).
  final List<String> checkValues;
}

/// 제외 키 — 열 0 · 뷰어가 `fromJson` 앞에 넣는 값(K307).
final class ReadModelExclusion {
  const ReadModelExclusion(this.key, this.reason, {this.viewerValue = 'null'});

  /// DTO 와이어 키(접두 없음).
  final String key;

  /// 사유(문서 글자).
  final String reason;

  /// 뷰어 판 값 — JSON 글자(`null` · `[]`) 또는 같은 행의 열 이름(그 열 값을 옮긴다).
  final String viewerValue;
}

/// DTO 결속 — 열 = [prefix] + `toJson()` 최상위 키(제외 뺌 · [flatten] 키는 그 객체의 키로 한 겹 펼침).
final class ReadModelBinding {
  const ReadModelBinding(
    this.dto, {
    this.prefix = '',
    this.flatten = const <String, String>{},
    this.excluded = const <ReadModelExclusion>[],
    this.feeds = const <String>[],
  });

  /// 계약 타입 이름.
  final String dto;

  /// 열 접두 — 빈 = 무접두(한 표에 DTO 여럿이면 둘째부터 — K306).
  final String prefix;

  /// 한 겹 펼칠 키 → 그 값의 타입 이름(v1.28 `allocation_*` = `current` 펼침 · K201).
  final Map<String, String> flatten;

  /// 제외 키.
  final List<ReadModelExclusion> excluded;

  /// 이 결속이 원천인 뷰어 창구(«저장소.메서드»).
  final List<String> feeds;
}

/// DTO 밖 열 — 출처 한 줄(K308).
final class ReadModelExtraColumn {
  const ReadModelExtraColumn(this.name, this.source);

  /// 열 이름.
  final String name;

  /// 출처(문서 글자).
  final String source;
}

/// 🆕 v1.39(01 §48 · K339~K341 · 미결 230 ⓐ ⓔ · 13 §8 R250 V3) 목록 열 — 행 표 목록의 엔진 차례 · 소속(+ 봉투 글자 · 기간 프리셋).
///
/// 🔴 차례 열 `<목록>_rank bigint` = 그 창구 **기본 호출**(필터 · 구간 인자 없음 — 엔진 기본)의 차례 · **상한(limit) 없이** 1부터 빈틈 없이 ·
///    null = 그 목록 밖 → 뷰어 `hasMore` = limit+1(v1.36 K310 그대로 · 봉투 `has_more` 열 0).
///    엔진 push = 목록 전부 + 목록에서 빠진 행(같은 키 · 큰 판 · rank null)을 다시 보낸다(삭제 0 · K335) — 시간이 지나 빠지는 행
///    (원장 차이 30일 · 알림 7일 · 안내 만료)도 깨어남마다 다시 판정한다. 직전 소속 = 엔진 로컬 push 상태가 안다(뷰어는 모른다).
/// 🔴 뷰어 = `rank is not null order by rank asc` · 인자 = 같은 행 열과 같음만(일지 `sleeve` · `symbol` · `status` · `fill_origin` ·
///    `rebalance_event_id`(= `routeParamKeyOf` 한 번) · 구간 = `trade_date` 양끝 포함 · 알림 `min` = `AlertLevel` 선언 차례 앞쪽까지) ·
///    그 밖 인자(안내 `status` · 안내 이력 구간 · 회차 `range` · 시리즈 구간) = `UnsupportedError`(엔진 의미 0 — 지어내지 않는다).
/// 🔴 push 빌더(`readModelRow`)는 목록 열을 요구하지 않는다 — 엔진이 채우기 전 = null(01 §8 미결 242) · 뷰어 목록 창구는 그때까지
///    `UnsupportedError` 그대로(뷰어 V3 카드 = 엔진 채움 뒤). 결속 열 아님(DTO `fromJson` 에 넘기지 않는다 — C-72 ②).
final class ReadModelListColumn {
  const ReadModelListColumn(this.name, this.window, this.rule);

  /// 열 이름(`ReadModelTable.columns` 안 · 표 맨 끝).
  final String name;

  /// 이 열이 섬기는 창구 «저장소.메서드» · 봉투 열 = [everyList].
  final String window;

  /// 규칙(문서 글자).
  final String rule;

  /// 봉투 열의 [window] — 모든 `list_code` 행.
  static const String everyList = '*';
}

/// 뷰어 판 열 — 열은 있다 · 엔진 push 가 뷰어 판 값을 싣는다(K309).
final class ReadModelViewerVariant {
  const ReadModelViewerVariant(this.keyPath, this.rule);

  /// 열 이름 또는 jsonb 안 경로(`rows[].deployed_text`).
  final String keyPath;

  /// 규칙(문서 글자).
  final String rule;
}

/// 읽기 모델 표 하나.
final class ReadModelTable {
  const ReadModelTable({
    required this.name,
    required this.keyColumns,
    required this.columns,
    this.bindings = const <ReadModelBinding>[],
    this.extraColumns = const <ReadModelExtraColumn>[],
    this.listColumns = const <ReadModelListColumn>[],
    this.viewerVariants = const <ReadModelViewerVariant>[],
    this.listCodes = const <String>[],
  });

  /// 표 이름(`rm_` 접두).
  final String name;

  /// 증분 키 = 기본 키(첫 칸 = `mode` — 규칙 5조 ①).
  final List<String> keyColumns;

  /// 열 — 규칙 5조 4칸 밖 · 이 차례(생성기 출력 차례 = 규칙 5조 4칸 뒤).
  final List<ReadModelColumn> columns;

  /// 결속 DTO.
  final List<ReadModelBinding> bindings;

  /// DTO 밖 열.
  final List<ReadModelExtraColumn> extraColumns;

  /// 🆕 v1.39 목록 열(K339) — 이름은 [columns] 맨 끝에도 있다(차례 그대로).
  final List<ReadModelListColumn> listColumns;

  /// 뷰어 판 열.
  final List<ReadModelViewerVariant> viewerVariants;

  /// 이 표가 행 원천인 목록 창구 — 봉투 = `rm_list_envelope` 그 `list_code` 행(K310).
  final List<String> listCodes;
}

/// 규칙 5조 ① push 4칸(전 `rm_*` · 열 차례 = 표 맨 앞 · 전부 NOT NULL).
abstract final class ReadModelPushColumns {
  /// `row_version bigint not null` — upsert 승자(규칙 5조 ②).
  static const ReadModelColumn rowVersion = ReadModelColumn(
    'row_version',
    ReadModelColumnType.bigint,
  );

  /// `lease_epoch bigint not null` — 낮은 epoch 쓰기 거부(push RPC · E11l2).
  static const ReadModelColumn leaseEpoch = ReadModelColumn(
    'lease_epoch',
    ReadModelColumnType.bigint,
  );

  /// `pushed_at timestamptz not null default now()`.
  static const ReadModelColumn pushedAt = ReadModelColumn(
    'pushed_at',
    ReadModelColumnType.timestamptz,
  );

  /// `mode text not null check (mode in (RunMode 3))` — 키 첫 칸(G-31).
  static const ReadModelColumn mode = ReadModelColumn(
    'mode',
    ReadModelColumnType.text,
    checkValues: <String>['LIVE', 'SIM_INTERNAL', 'SIM_BROKER'],
  );

  /// 전부(이 차례).
  static const List<ReadModelColumn> all = <ReadModelColumn>[
    rowVersion,
    leaseEpoch,
    pushedAt,
    mode,
  ];
}

/// RLS — 표마다 `enable row level security` + select 전용 정책 하나(규칙 5조 ④ · G-10 · K311).
/// 🔴 INSERT · UPDATE · DELETE 클라이언트 정책 0 — 쓰기 = operator 리스 epoch 를 검사하는 security definer RPC 1창구(E11l2).
abstract final class ReadModelRls {
  /// 정책 이름 = `<표>_select`.
  static String selectPolicyName(String table) => '${table}_select';

  /// select 정책 대상 역할.
  static const String selectRole = 'authenticated';

  /// select 정책 `using (…)` 본문 — 부른 사용자의 ACTIVE 기기 행이 있을 때(v1.34 `app_device` 조인 · JWT 클레임 0).
  static const String selectUsing =
      "exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE')";
}

/// 목록 창구 이름 — `rm_list_envelope.list_code` 값(«저장소.메서드» · K310).
abstract final class ReadModelListCodes {
  /// `JournalRepository.watchTimeline` — 행 = `rm_journal`.
  static const String journalWatchTimeline = 'JournalRepository.watchTimeline';

  /// `HoldingsRepository.watchHoldings` — 행 = `rm_holding`.
  static const String holdingsWatchHoldings =
      'HoldingsRepository.watchHoldings';

  /// `RebalanceRepository.watchEvents` — 행 = `rm_rebalance_event`.
  static const String rebalanceWatchEvents = 'RebalanceRepository.watchEvents';

  /// `AdviceRepository.watchInbox` — 행 = `rm_advice`.
  static const String adviceWatchInbox = 'AdviceRepository.watchInbox';

  /// `AdviceRepository.watchHistory` — 행 = `rm_advice`.
  static const String adviceWatchHistory = 'AdviceRepository.watchHistory';

  /// `LedgerRepository.watchOpenDiffs` — 행 = `rm_ledger_diff`.
  static const String ledgerWatchOpenDiffs = 'LedgerRepository.watchOpenDiffs';

  /// `OpsSummaryRepository.watchRhythm` — 행 = `rm_ops_summary`(🆕 v1.39 글자 정정 · 01 §48 K343 · 미결 230 ⓒ — 옛 값
  /// `OpsStatusRepository.watchRhythm` 은 그 메서드가 없는 저장소 이름이었다 · 첫 판 전이라 이주 0).
  static const String opsSummaryWatchRhythm =
      'OpsSummaryRepository.watchRhythm';

  /// 옛 이름(값 = [opsSummaryWatchRhythm]) — 부르는 곳(뷰어 `watchRhythm`)이 옮기면 지운다.
  static const String opsStatusWatchRhythm = opsSummaryWatchRhythm;

  /// `JournalRepository.watchBlindReviewQueue` — 행 = `rm_blind_review`.
  static const String journalWatchBlindReviewQueue =
      'JournalRepository.watchBlindReviewQueue';

  /// 전부(이 차례).
  static const List<String> all = <String>[
    journalWatchTimeline,
    holdingsWatchHoldings,
    rebalanceWatchEvents,
    adviceWatchInbox,
    adviceWatchHistory,
    ledgerWatchOpenDiffs,
    opsSummaryWatchRhythm,
    journalWatchBlindReviewQueue,
  ];
}

/// 읽기 모델 표 22(K303 · 01 §6-4 · 이 차례 = 부트스트랩 출력 차례).
abstract final class ReadModelTables {
  /// `rm_journal`.
  static const ReadModelTable journal = ReadModelTable(
    name: 'rm_journal',
    keyColumns: <String>['mode', 'trade_date', 'entry_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('entry_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('executed_at', ReadModelColumnType.text),
      ReadModelColumn('symbol', ReadModelColumnType.text),
      ReadModelColumn('symbol_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('side', ReadModelColumnType.text),
      ReadModelColumn('side_label', ReadModelColumnType.text),
      ReadModelColumn('quantity', ReadModelColumnType.bigint),
      ReadModelColumn('price', ReadModelColumnType.text),
      ReadModelColumn('commission', ReadModelColumnType.text),
      ReadModelColumn('tax', ReadModelColumnType.text),
      ReadModelColumn('quantity_text', ReadModelColumnType.text),
      ReadModelColumn('price_text', ReadModelColumnType.text),
      ReadModelColumn('commission_text', ReadModelColumnType.text),
      ReadModelColumn('tax_text', ReadModelColumnType.text),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('status_tone', ReadModelColumnType.text),
      ReadModelColumn('visibility', ReadModelColumnType.text),
      ReadModelColumn('visibility_label', ReadModelColumnType.text),
      ReadModelColumn('reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('decision', ReadModelColumnType.jsonb),
      ReadModelColumn('deviation', ReadModelColumnType.jsonb),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('fill_origin', ReadModelColumnType.text),
      ReadModelColumn('fill_kind', ReadModelColumnType.text),
      ReadModelColumn('advice_id', ReadModelColumnType.text),
      ReadModelColumn('backdate', ReadModelColumnType.jsonb),
      ReadModelColumn('cost_source', ReadModelColumnType.text),
      ReadModelColumn('cost_source_label', ReadModelColumnType.text),
      ReadModelColumn('origin_label', ReadModelColumnType.text),
      ReadModelColumn('rebalance_event_id', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('timeline_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'TradeJournalEntry',
        feeds: <String>[
          'JournalRepository.watchTimeline',
          'JournalRepository.findByDecisionId',
          'JournalRepository.chainOf',
          'JournalRepository.fillChain',
          'AdviceRepository.fillsOfAdvice',
        ],
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'timeline_rank',
        'JournalRepository.watchTimeline',
        '무필터 · 전 기간 타임라인 차례(엔진 = 거래일 ↓ · 의도 생성 시각 ↓ · 의도 id ↓) — 필터 = 열 같음 · 구간 = trade_date 양끝 포함',
      ),
    ],
    listCodes: <String>['JournalRepository.watchTimeline'],
  );

  /// `rm_holding`.
  static const ReadModelTable holding = ReadModelTable(
    name: 'rm_holding',
    keyColumns: <String>['mode', 'trade_date', 'holding_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('symbol', ReadModelColumnType.text),
      ReadModelColumn('symbol_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('quantity', ReadModelColumnType.bigint),
      ReadModelColumn('avg_price', ReadModelColumnType.text),
      ReadModelColumn('entry_date', ReadModelColumnType.text),
      ReadModelColumn('entry_decision', ReadModelColumnType.jsonb),
      ReadModelColumn('entry_reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('sma_tranches', ReadModelColumnType.jsonb),
      ReadModelColumn('gates', ReadModelColumnType.jsonb),
      ReadModelColumn('stop_line', ReadModelColumnType.jsonb),
      ReadModelColumn('momentum', ReadModelColumnType.jsonb),
      ReadModelColumn('scope', ReadModelColumnType.text),
      ReadModelColumn('scope_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('holding_id', ReadModelColumnType.text),
      ReadModelColumn('quantity_text', ReadModelColumnType.text),
      ReadModelColumn('avg_price_text', ReadModelColumnType.text),
      ReadModelColumn('weight_text', ReadModelColumnType.text),
      ReadModelColumn('pending_text', ReadModelColumnType.text),
      ReadModelColumn('sub_book_label', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('holdings_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'HoldingRow',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'pnl',
            '🔴 손익 원장 금지(규칙 5조 ⑤ · K15) — 뷰어 `pnlToggleLabel` null',
          ),
        ],
        feeds: <String>['HoldingsRepository.watchHoldings'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'trade_date',
        'push 스냅숏 거래일 — 그 행 `as_of.trade_date` 와 같은 값(엔진)',
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'holdings_rank',
        'HoldingsRepository.watchHoldings',
        '지금 보유(수량 > 0 · 마지막 스냅숏 거래일) 차례 = 엔진 · 옛 거래일 행 = null',
      ),
    ],
    listCodes: <String>['HoldingsRepository.watchHoldings'],
  );

  /// `rm_performance_point`.
  static const ReadModelTable performancePoint = ReadModelTable(
    name: 'rm_performance_point',
    keyColumns: <String>['mode', 'metric', 'granularity', 'cumulative', 'date'],
    columns: <ReadModelColumn>[
      ReadModelColumn('metric', ReadModelColumnType.text),
      ReadModelColumn('granularity', ReadModelColumnType.text),
      ReadModelColumn('cumulative', ReadModelColumnType.boolean),
      ReadModelColumn('date', ReadModelColumnType.text),
      ReadModelColumn('x_normalized', ReadModelColumnType.doublePrecision),
      ReadModelColumn('date_text', ReadModelColumnType.text),
      ReadModelColumn('value_text', ReadModelColumnType.text),
      ReadModelColumn('y_normalized', ReadModelColumnType.doublePrecision),
      ReadModelColumn('value', ReadModelColumnType.doublePrecision),
      ReadModelColumn('gap_reason_code', ReadModelColumnType.text),
      ReadModelColumn('series_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'PerfPoint',
        feeds: <String>['PerformanceRepository.series'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'metric',
        '부모 시리즈 `PerformanceSeries.metric` 와이어(같은 키 글자)',
      ),
      ReadModelExtraColumn(
        'granularity',
        '부모 시리즈 `PerformanceSeries.granularity` 와이어',
      ),
      ReadModelExtraColumn(
        'cumulative',
        '부모 시리즈 `PerformanceSeries.cumulative`',
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'series_rank',
        'PerformanceRepository.series',
        '그 시리즈 기본 구간(일별 = 이번 달 · 월별 · 연별 = 처음부터)의 점 차례(date 오름차순) — 구간 밖으로 밀려난 옛 점 = null(230 ⓔ · 13 R268 D7)',
      ),
    ],
  );

  /// `rm_performance_series`.
  static const ReadModelTable performanceSeries = ReadModelTable(
    name: 'rm_performance_series',
    keyColumns: <String>['mode', 'metric', 'granularity', 'cumulative'],
    columns: <ReadModelColumn>[
      ReadModelColumn('metric', ReadModelColumnType.text),
      ReadModelColumn('granularity', ReadModelColumnType.text),
      ReadModelColumn('cumulative', ReadModelColumnType.boolean),
      ReadModelColumn('segments', ReadModelColumnType.jsonb),
      ReadModelColumn('disclosure', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('series_label', ReadModelColumnType.text),
      ReadModelColumn('period_label', ReadModelColumnType.text),
      ReadModelColumn('y_ticks', ReadModelColumnType.jsonb),
      ReadModelColumn('unavailable_label', ReadModelColumnType.text),
      ReadModelColumn('benchmark', ReadModelColumnType.jsonb),
      ReadModelColumn('after_tax', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'PerformanceSeries',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'points',
            '점 = `rm_performance_point` 그 시리즈 행(`date` 오름차순 · 뷰어가 다시 정규화하지 않는다)',
            viewerValue: '[]',
          ),
        ],
        feeds: <String>['PerformanceRepository.series'],
      ),
    ],
  );

  /// `rm_rebalance_event`.
  static const ReadModelTable rebalanceEvent = ReadModelTable(
    name: 'rm_rebalance_event',
    keyColumns: <String>['mode', 'event_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('event_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('kind', ReadModelColumnType.text),
      ReadModelColumn('kind_label', ReadModelColumnType.text),
      ReadModelColumn('before', ReadModelColumnType.jsonb),
      ReadModelColumn('after', ReadModelColumnType.jsonb),
      ReadModelColumn('trigger', ReadModelColumnType.jsonb),
      ReadModelColumn('order_intent_ids', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('quality', ReadModelColumnType.jsonb),
      ReadModelColumn('thresholds', ReadModelColumnType.jsonb),
      ReadModelColumn('mode_label', ReadModelColumnType.text),
      ReadModelColumn('section_label', ReadModelColumnType.text),
      ReadModelColumn('journal_timeline_link', ReadModelColumnType.jsonb),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('scope_label', ReadModelColumnType.text),
      ReadModelColumn('scope_range', ReadModelColumnType.jsonb),
      ReadModelColumn('events_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'RebalanceEvent',
        feeds: <String>[
          'RebalanceRepository.watchEvents',
          'RebalanceRepository.watchEvent',
        ],
      ),
      ReadModelBinding(
        'JournalRebalanceScope',
        prefix: 'scope_',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'rebalance_event_id',
            '같은 값 = `event_id` 열',
            viewerValue: 'event_id',
          ),
        ],
        feeds: <String>['JournalRepository.watchRebalanceScope'],
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'events_rank',
        'RebalanceRepository.watchEvents',
        '회차 차례(엔진 = 거래일 ↓ · 생성 시각 ↓ · 회차 id ↓) — range 인자 = 엔진 의미 0(뷰어 UnsupportedError)',
      ),
    ],
    listCodes: <String>['RebalanceRepository.watchEvents'],
  );

  /// `rm_alert`.
  static const ReadModelTable alert = ReadModelTable(
    name: 'rm_alert',
    keyColumns: <String>['mode', 'alert_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('alert_id', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('raised_at', ReadModelColumnType.text),
      ReadModelColumn('code', ReadModelColumnType.text),
      ReadModelColumn('title', ReadModelColumnType.text),
      ReadModelColumn('body_text', ReadModelColumnType.text),
      ReadModelColumn('action_line', ReadModelColumnType.text),
      ReadModelColumn('grouped_count', ReadModelColumnType.bigint),
      ReadModelColumn('deep_link', ReadModelColumnType.text),
      ReadModelColumn('ack', ReadModelColumnType.jsonb),
      ReadModelColumn('raised_at_text', ReadModelColumnType.text),
      ReadModelColumn('grouped_text', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('inbox_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AlertItem',
        feeds: <String>['AlertRepository.watchInbox'],
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'inbox_rank',
        'AlertRepository.watchInbox',
        'min 없음 수신함 차례(엔진 = 확인 안 한 P0 → 확인한 P0 → P1 → P2 · 각 발생 시각 ↓) · 소속 = 안 확인 P0 늘 · 나머지 7일 — min = AlertLevel 선언 차례 앞쪽까지',
      ),
    ],
  );

  /// `rm_safety_state`.
  static const ReadModelTable safetyState = ReadModelTable(
    name: 'rm_safety_state',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('breaker_level', ReadModelColumnType.text),
      ReadModelColumn('breaker_label', ReadModelColumnType.text),
      ReadModelColumn('drawdown', ReadModelColumnType.doublePrecision),
      ReadModelColumn('active_flags', ReadModelColumnType.jsonb),
      ReadModelColumn('kill_switch', ReadModelColumnType.jsonb),
      ReadModelColumn('stopped_release_eligible', ReadModelColumnType.boolean),
      ReadModelColumn('release_progress', ReadModelColumnType.jsonb),
      ReadModelColumn('alert_block_sat_entry', ReadModelColumnType.boolean),
      ReadModelColumn('ramp_level', ReadModelColumnType.text),
      ReadModelColumn('holds', ReadModelColumnType.jsonb),
      ReadModelColumn('hold_labels', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'SafetyState',
        feeds: <String>['SafetyRepository.watchState'],
      ),
    ],
  );

  /// `rm_config_view`.
  static const ReadModelTable configView = ReadModelTable(
    name: 'rm_config_view',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('satellite_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('web_viewer_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('calendar_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('run_mode', ReadModelColumnType.text),
      ReadModelColumn(
        'operating_mode',
        ReadModelColumnType.text,
        checkValues: <String>['AUTO_TRADE', 'ADVISORY'],
      ),
      ReadModelColumn('config_hash', ReadModelColumnType.text),
      ReadModelColumn('contribution_amount', ReadModelColumnType.text),
      ReadModelColumn('contribution_amount_text', ReadModelColumnType.text),
      ReadModelColumn(
        'contribution_amount_input_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_equivalent_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_applies_from_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_last_changed_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'contribution_pension_limit_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('allocation_label', ReadModelColumnType.text),
      ReadModelColumn('allocation_weights_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_backtest_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_honest_note_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_sections', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'allocation_change_path_lines',
        ReadModelColumnType.jsonb,
      ),
      ReadModelColumn('allocation_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('sleeve_catalog', ReadModelColumnType.jsonb),
      ReadModelColumn('schema_version', ReadModelColumnType.bigint),
      ReadModelColumn('hash_format_version', ReadModelColumnType.bigint),
      ReadModelColumn('contract_version', ReadModelColumnType.text),
      ReadModelColumn('range_presets', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'FeatureFlags',
        feeds: <String>['ConfigRepository.watchFlags'],
      ),
      ReadModelBinding(
        'ContributionSetting',
        prefix: 'contribution_',
        feeds: <String>['ConfigRepository.watchContributionSetting'],
      ),
      ReadModelBinding(
        'AllocationEditorVm',
        prefix: 'allocation_',
        flatten: <String, String>{'current': 'AllocationProfileCard'},
        feeds: <String>['SettingsRepository.watchAllocationEditor'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'sleeve_catalog',
        '`ConfigRepository.watchSleeves` 목록 — `[SleeveCatalogEntry.toJson()]` 받은 순서(엔진)',
      ),
      ReadModelExtraColumn(
        'schema_version',
        '버전 스탬프(G-36) — 계약 `schemaVersion`(push 층 · 규칙 5조 ⑥)',
      ),
      ReadModelExtraColumn(
        'hash_format_version',
        '버전 스탬프(G-36) — 계약 `hashFormatVersion`(push 층)',
      ),
      ReadModelExtraColumn(
        'contract_version',
        '버전 스탬프(G-36) — 계약 `contractVersion`(push 층)',
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'range_presets',
        'ConfigRepository.watchRangePresets',
        '[DateRange.toJson()] 엔진 차례 그대로(지금 = 30일(기본) · 이번 달 · 올해 · 전체) — null = 아직 안 채움',
      ),
    ],
  );

  /// `rm_advice`.
  static const ReadModelTable advice = ReadModelTable(
    name: 'rm_advice',
    keyColumns: <String>['mode', 'trade_date', 'advice_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('advice_id', ReadModelColumnType.text),
      ReadModelColumn('batch_id', ReadModelColumnType.text),
      ReadModelColumn('kind', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('issued_at', ReadModelColumnType.text),
      ReadModelColumn('valid_until_date', ReadModelColumnType.text),
      ReadModelColumn('validity_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('sizing_label', ReadModelColumnType.text),
      ReadModelColumn('progress_label', ReadModelColumnType.text),
      ReadModelColumn('reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('effective_status', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('status_tone', ReadModelColumnType.text),
      ReadModelColumn('recorded_deviation_chips', ReadModelColumnType.jsonb),
      ReadModelColumn('is_urgent', ReadModelColumnType.boolean),
      ReadModelColumn('on_hold', ReadModelColumnType.boolean),
      ReadModelColumn('decision', ReadModelColumnType.jsonb),
      ReadModelColumn('suppressed', ReadModelColumnType.boolean),
      ReadModelColumn('defer_available', ReadModelColumnType.boolean),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('phone_only_label', ReadModelColumnType.text),
      ReadModelColumn('close_reason_code', ReadModelColumnType.text),
      ReadModelColumn('depends_on_advice_id', ReadModelColumnType.text),
      ReadModelColumn('hold_reason_label', ReadModelColumnType.text),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('suppressed_label', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('expired_confirm_label', ReadModelColumnType.text),
      ReadModelColumn('decision_link', ReadModelColumnType.jsonb),
      ReadModelColumn('close_reason_label', ReadModelColumnType.text),
      ReadModelColumn('inbox_rank', ReadModelColumnType.bigint),
      ReadModelColumn('history_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AdviceItem',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'symbol',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'symbol_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'side',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'side_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'quantity',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'price_band',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'recorded_quantity',
            '🔴 A6 — 뷰어 판 null(0 을 채우면 «0주 기록됨» 거짓 · §10-7)',
          ),
          ReadModelExclusion(
            'prefill_quantity_text',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice) — 수기 입력 미리 채움 = 폰 전용',
          ),
          ReadModelExclusion(
            'prefill_quantity_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice) — 수기 입력 미리 채움 = 폰 전용',
          ),
          ReadModelExclusion(
            'actions',
            '뷰어 판 = 빈 목록(«부재» · G-22 · v1.12)',
            viewerValue: '[]',
          ),
        ],
        feeds: <String>[
          'AdviceRepository.watchInbox',
          'AdviceRepository.watchHistory',
          'AdviceRepository.findById',
        ],
      ),
    ],
    viewerVariants: <ReadModelViewerVariant>[
      ReadModelViewerVariant('sizing_label', '뷰어 판 글자(수량 0 — A6 · v1.12)'),
      ReadModelViewerVariant('progress_label', '뷰어 판 글자(수량 0 — A6)'),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'inbox_rank',
        'AdviceRepository.watchInbox',
        '무인자 수신함 차례(엔진 = 확인 카드 → 급함 → 나머지) · 미분류 만료(확인 카드 밖) = null — status 인자 = 엔진 의미 0(뷰어 UnsupportedError)',
      ),
      ReadModelListColumn(
        'history_rank',
        'AdviceRepository.watchHistory',
        '엔진 기본 구간 이력 차례 — 다른 구간 = 엔진 의미 0(뷰어 UnsupportedError)',
      ),
    ],
    listCodes: <String>[
      'AdviceRepository.watchInbox',
      'AdviceRepository.watchHistory',
    ],
  );

  /// `rm_advice_summary`.
  static const ReadModelTable adviceSummary = ReadModelTable(
    name: 'rm_advice_summary',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('batch_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('open_count', ReadModelColumnType.bigint),
      ReadModelColumn('due_today_count', ReadModelColumnType.bigint),
      ReadModelColumn('has_suppressed_notice', ReadModelColumnType.boolean),
      ReadModelColumn('overdue_unrecorded_count', ReadModelColumnType.bigint),
      ReadModelColumn('headline', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('handover_cooling_active', ReadModelColumnType.boolean),
      ReadModelColumn('trust', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('due_soon_label', ReadModelColumnType.text),
      ReadModelColumn('stale_reason_code', ReadModelColumnType.text),
      ReadModelColumn('stale_label', ReadModelColumnType.text),
      ReadModelColumn('handover_cooling_label', ReadModelColumnType.text),
      ReadModelColumn('cash_notice', ReadModelColumnType.jsonb),
      ReadModelColumn('overdue_unrecorded_link', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AdviceInboxSummary',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'manual_entry_link',
            '수기 입력 = 폰 전용 — 뷰어 판 null(v1.12)',
          ),
          ReadModelExclusion(
            'manual_entry_notice_text',
            '수기 입력 = 폰 전용 — 뷰어 판 null(v1.12)',
          ),
        ],
        feeds: <String>['AdviceRepository.watchSummary'],
      ),
    ],
  );

  /// `rm_monthly_report`.
  static const ReadModelTable monthlyReport = ReadModelTable(
    name: 'rm_monthly_report',
    keyColumns: <String>['mode', 'yyyy_mm'],
    columns: <ReadModelColumn>[
      ReadModelColumn('yyyy_mm', ReadModelColumnType.text),
      ReadModelColumn('items', ReadModelColumnType.jsonb),
      ReadModelColumn('goal_line', ReadModelColumnType.text),
      ReadModelColumn('disclosure_view_count_text', ReadModelColumnType.text),
      ReadModelColumn('trust', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('after_tax', ReadModelColumnType.jsonb),
      ReadModelColumn('backdate_footnote', ReadModelColumnType.text),
      ReadModelColumn('pending_notice_text', ReadModelColumnType.text),
      ReadModelColumn('generated_at_text', ReadModelColumnType.text),
      ReadModelColumn('config_hash', ReadModelColumnType.text),
      ReadModelColumn('goal_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'MonthlyReport',
        feeds: <String>['PerformanceRepository.monthlyReport'],
      ),
    ],
  );

  /// `rm_report_archive`.
  static const ReadModelTable reportArchive = ReadModelTable(
    name: 'rm_report_archive',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'ReportArchiveVm',
        feeds: <String>['PerformanceRepository.reportArchive'],
      ),
    ],
  );

  /// `rm_ledger_diff`.
  static const ReadModelTable ledgerDiff = ReadModelTable(
    name: 'rm_ledger_diff',
    keyColumns: <String>['mode', 'diff_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('diff_id', ReadModelColumnType.text),
      ReadModelColumn('pair', ReadModelColumnType.text),
      ReadModelColumn('axis', ReadModelColumnType.text),
      ReadModelColumn('authored_date', ReadModelColumnType.text),
      ReadModelColumn('delta_label', ReadModelColumnType.text),
      ReadModelColumn('severity', ReadModelColumnType.text),
      ReadModelColumn('candidate_origin_codes', ReadModelColumnType.jsonb),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('route', ReadModelColumnType.text),
      ReadModelColumn('evidence_hash', ReadModelColumnType.text),
      ReadModelColumn('applicable', ReadModelColumnType.boolean),
      ReadModelColumn('pair_label', ReadModelColumnType.text),
      ReadModelColumn('axis_label', ReadModelColumnType.text),
      ReadModelColumn('severity_label', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('route_label', ReadModelColumnType.text),
      ReadModelColumn('candidate_origins', ReadModelColumnType.jsonb),
      ReadModelColumn('detected_at_text', ReadModelColumnType.text),
      ReadModelColumn('open_diffs_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'LedgerDiffRow',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'action_link',
            '정정 = 폰 전용 — 뷰어 판 null(v1.12 §21-5-4)',
          ),
        ],
        feeds: <String>['LedgerRepository.watchOpenDiffs'],
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'open_diffs_rank',
        'LedgerRepository.watchOpenDiffs',
        '열린 차단 → 열린 관측 → 닫힌 것(30일) 차례 = 엔진(상한 50 없이 전부) · 30일 지난 닫힌 차이 = null',
      ),
    ],
    listCodes: <String>['LedgerRepository.watchOpenDiffs'],
  );

  /// `rm_sleeve_allocation`.
  static const ReadModelTable sleeveAllocation = ReadModelTable(
    name: 'rm_sleeve_allocation',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('notice_text', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'SleeveAllocationVm',
        feeds: <String>['HoldingsRepository.watchAllocation'],
      ),
    ],
    viewerVariants: <ReadModelViewerVariant>[
      ReadModelViewerVariant(
        'rows[].deployed_text',
        '엔진 가림 글자(LEDGER_INTEGRITY «숨김»과 같은 글자 · 금액 0 — 04 §2-6 · DTO 칸은 non-null 그대로)',
      ),
      ReadModelViewerVariant('rows[].parking_text', '엔진 가림 글자(금액 0 — 04 §2-6)'),
    ],
  );

  /// `rm_perf_context`.
  static const ReadModelTable perfContext = ReadModelTable(
    name: 'rm_perf_context',
    keyColumns: <String>['mode', 'range_preset_code'],
    columns: <ReadModelColumn>[
      ReadModelColumn('range_preset_code', ReadModelColumnType.text),
      ReadModelColumn('drawdown_period_label', ReadModelColumnType.text),
      ReadModelColumn('drawdown_current_dd_text', ReadModelColumnType.text),
      ReadModelColumn('drawdown_max_dd_text', ReadModelColumnType.text),
      ReadModelColumn('drawdown_tuw_text', ReadModelColumnType.text),
      ReadModelColumn(
        'drawdown_dd_normalized',
        ReadModelColumnType.doublePrecision,
      ),
      ReadModelColumn('drawdown_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('drawdown_reference_band_text', ReadModelColumnType.text),
      ReadModelColumn(
        'drawdown_reference_band_caveat_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_period_label', ReadModelColumnType.text),
      ReadModelColumn('contribution_rows', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'contribution_method_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('contribution_fx_note_text', ReadModelColumnType.text),
      ReadModelColumn('is_default', ReadModelColumnType.boolean),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'DrawdownContextVm',
        prefix: 'drawdown_',
        feeds: <String>['PerformanceRepository.drawdownContext'],
      ),
      ReadModelBinding(
        'ContributionVm',
        prefix: 'contribution_',
        feeds: <String>['PerformanceRepository.contribution'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'range_preset_code',
        '구간 프리셋 코드 — `DateRange.presetCode`(`watchRangePresets` 의 프리셋 · 사용자 지정 구간 = 행 없음)',
      ),
      ReadModelExtraColumn(
        'is_default',
        '엔진 기본 구간 표식 — `drawdownContext(range: null)` 의 행(한 모드에 참 하나)',
      ),
    ],
  );

  /// `rm_disclosure_view`.
  static const ReadModelTable disclosureView = ReadModelTable(
    name: 'rm_disclosure_view',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('gate_open', ReadModelColumnType.boolean),
      ReadModelColumn('headline', ReadModelColumnType.text),
      ReadModelColumn('view_count_text', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('friction_line', ReadModelColumnType.text),
      ReadModelColumn('route', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'DisclosureGateVm',
        feeds: <String>['PerformanceRepository.watchDisclosureGate'],
      ),
    ],
  );

  /// `rm_ops_summary`.
  static const ReadModelTable opsSummary = ReadModelTable(
    name: 'rm_ops_summary',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('today_orders_text', ReadModelColumnType.text),
      ReadModelColumn('today_errors_text', ReadModelColumnType.text),
      ReadModelColumn('signal_match_text', ReadModelColumnType.text),
      ReadModelColumn('streak_text', ReadModelColumnType.text),
      ReadModelColumn('discretion_budget_text', ReadModelColumnType.text),
      ReadModelColumn('next_rebalance_d_day_text', ReadModelColumnType.text),
      ReadModelColumn('upcoming', ReadModelColumnType.jsonb),
      ReadModelColumn('resume_line', ReadModelColumnType.jsonb),
      ReadModelColumn('rhythm', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'OpsDailySummary',
        feeds: <String>['OpsSummaryRepository.watchToday'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'rhythm',
        '`OpsSummaryRepository.watchRhythm` 전체 목록 — `[OpsRhythmRow.toJson()]` 받은 순서(엔진 · v1.12 K29)',
      ),
    ],
    listCodes: <String>['OpsSummaryRepository.watchRhythm'],
  );

  /// `rm_ledger_trust`.
  static const ReadModelTable ledgerTrust = ReadModelTable(
    name: 'rm_ledger_trust',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('grade', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('label', ReadModelColumnType.text),
      ReadModelColumn('consequence_line', ReadModelColumnType.text),
      ReadModelColumn('upgrade_hint', ReadModelColumnType.text),
      ReadModelColumn('last_verified_on', ReadModelColumnType.text),
      ReadModelColumn('action_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'LedgerTrustBadge',
        feeds: <String>['LedgerTrustRepository.watchGrade'],
      ),
    ],
  );

  /// `rm_execution_gap`.
  static const ReadModelTable executionGap = ReadModelTable(
    name: 'rm_execution_gap',
    keyColumns: <String>['mode', 'yyyy_mm'],
    columns: <ReadModelColumn>[
      ReadModelColumn('yyyy_mm', ReadModelColumnType.text),
      ReadModelColumn('report', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_kind', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('is_default', ReadModelColumnType.boolean),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'ExecutionGapResult',
        feeds: <String>['ExecutionGapRepository.monthly'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'yyyy_mm',
        '그 달(`yyyy-MM` · `monthly(yyyyMm:)` 인자와 같은 꼴)',
      ),
      ReadModelExtraColumn(
        'is_default',
        '엔진 기본 달 표식 — `monthly(yyyyMm: null)` 의 행(한 모드에 참 하나 · 06 X7-4)',
      ),
    ],
  );

  /// `rm_blind_review`.
  static const ReadModelTable blindReview = ReadModelTable(
    name: 'rm_blind_review',
    keyColumns: <String>['mode', 'decision_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('decision_id', ReadModelColumnType.text),
      ReadModelColumn('title_text', ReadModelColumnType.text),
      ReadModelColumn('prompt_text', ReadModelColumnType.text),
      ReadModelColumn('context_chips', ReadModelColumnType.jsonb),
      ReadModelColumn('deviation', ReadModelColumnType.jsonb),
      ReadModelColumn('journal_state_label', ReadModelColumnType.text),
      ReadModelColumn('journal', ReadModelColumnType.jsonb),
      ReadModelColumn('questions', ReadModelColumnType.jsonb),
      ReadModelColumn('result', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('queue_rank', ReadModelColumnType.bigint),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'BlindReviewCard',
        feeds: <String>[
          'JournalRepository.watchBlindReviewQueue',
          'JournalRepository.watchBlindReviewCard',
        ],
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'queue_rank',
        'JournalRepository.watchBlindReviewQueue',
        '채점 대기 차례(엔진 = 결정 시각 ↑ · 결정 id ↑) · 채점한 카드 = null(카드 창구는 그 행 그대로)',
      ),
    ],
    listCodes: <String>['JournalRepository.watchBlindReviewQueue'],
  );

  /// `rm_watchdog`.
  static const ReadModelTable watchdog = ReadModelTable(
    name: 'rm_watchdog',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('holiday_notice', ReadModelColumnType.text),
      ReadModelColumn('limit_notice', ReadModelColumnType.text),
      ReadModelColumn('last_received_text', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'WatchdogBoardVm',
        feeds: <String>['OpsStatusRepository.watchWatchdog'],
      ),
    ],
  );

  /// `rm_list_envelope`.
  static const ReadModelTable listEnvelope = ReadModelTable(
    name: 'rm_list_envelope',
    keyColumns: <String>['mode', 'list_code'],
    columns: <ReadModelColumn>[
      ReadModelColumn('list_code', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_kind', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('filtered_empty_label', ReadModelColumnType.text),
      ReadModelColumn('scope_empty_label', ReadModelColumnType.text),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'list_code',
        '목록 창구 이름 — `ReadModelListCodes`(«저장소.메서드»)',
      ),
      ReadModelExtraColumn('as_of', '`ListResult.asOf`(엔진)'),
      ReadModelExtraColumn('empty_kind', '`ListResult.emptyKind` 와이어(엔진)'),
      ReadModelExtraColumn(
        'empty_label',
        '`ListResult.emptyLabel`(엔진 · 없으면 null)',
      ),
    ],
    listColumns: <ReadModelListColumn>[
      ReadModelListColumn(
        'filtered_empty_label',
        ReadModelListColumn.everyList,
        '필터를 건 조회가 빈 때 엔진 문장(일지 «조건에 맞는 기록이 없습니다») · null = 그 목록에 필터 문장 없음 — 차례: 회차 필터 → scope_empty_label · 목록 전체가 빔 → empty_label · 그 밖 → 이 열',
      ),
      ReadModelListColumn(
        'scope_empty_label',
        ReadModelListColumn.everyList,
        '일지 회차 필터(rebalance_event_id)가 빈 때 엔진 문장 · 목록 전체가 비어도 이 글자가 먼저',
      ),
    ],
  );

  /// 전부(이 차례 = 부트스트랩 출력 차례).
  static const List<ReadModelTable> all = <ReadModelTable>[
    journal,
    holding,
    performancePoint,
    performanceSeries,
    rebalanceEvent,
    alert,
    safetyState,
    configView,
    advice,
    adviceSummary,
    monthlyReport,
    reportArchive,
    ledgerDiff,
    sleeveAllocation,
    perfContext,
    disclosureView,
    opsSummary,
    ledgerTrust,
    executionGap,
    blindReview,
    watchdog,
    listEnvelope,
  ];
}
```

---

## `packages/domain_contracts/lib/src/schema/supabase_rpc.dart`

```dart
// 영역 H — 🆕 계약 v1.29(01 §39 · §6-4 · K228 · 지도 X18 · D15) operator 리스 RPC 표(이름 · 인자 · 반환 칸).
//
// 🔴 RPC 본문(SQL · security definer)은 여기 없다 — E11k-e 부트스트랩 SQL 묶음(E11l1 `rm_*` 생성기와 같은 판). 여기는 **글자만** 둔다:
//    data_sync 클라이언트와 SQL 이 같은 이름 · 인자 · 반환 칸을 쓰게 하는 자리다(엔진 · SQL 이 각자 짓지 않는다 — X18).
// 🔴 모든 RPC 의 반환 = 한 행(`code` · `epoch` · `expires_at`) — `code` = `LeaseRpcResultCodes` ∪ null(성공). 클라이언트는 HTTP 상태 ·
//    오류 문장으로 코드를 짓지 않는다. 시각 = 서버 `now()` 기준(🔴 `server_now` RPC 0 — 신뢰 시각 원천 = 게이트웨이 `Date` · T1).
// 🔴 리스 수명 T(30분) · 갱신 T/3 = 서버 상수 · 엔진 상수(`kLeaseTtl` · R43 D3) — 클라이언트 인자 0.

/// 리스 RPC 이름 3(06 M4-3 · 배치 D `operator_lease` 단일 행 · 조건부 쓰기(CAS)만).
abstract final class LeaseRpcNames {
  /// 클레임 — 빈 행(첫 클레임 · 🔴 복구 코드 해시 필수 · 같은 트랜잭션) · 같은 기기 → 이 기기 · 🆕 v1.39(01 §48 K349 ①) 다른 기기 보유 ∧ 만료 =
  /// 그 기기가 REVOKED · RETIRED 일 때만 이 기기(epoch+1 · 아니면 `LEASE_HELD_BY_OTHER`) · 첫 클레임 뒤 = 운영 사용자만(`recovery_secret.owner_uid`).
  static const String claim = 'lease_claim';

  /// 갱신 — 보유 ∧ epoch 같음 ∧ 만료 전 → `expires_at` = 서버 `now()` + T.
  static const String renew = 'lease_renew';

  /// 비상 회수(X1-3 ①) — 복구 코드 대조 → 같은 트랜잭션: epoch+1 · 옛 보유 기기 `REVOKED` · 즉시 만료 · 복구 코드 해시 교체.
  static const String revoke = 'lease_revoke';

  static const Set<String> values = <String>{claim, renew, revoke};
}

/// 리스 RPC 인자 이름(PostgREST `rpc/<이름>` 본문 키).
abstract final class LeaseRpcParams {
  /// 부르는 기기(`app_device.device_id` · 🔴 그 기기의 `auth_uid` = `auth.uid()` 여야 한다 — D5).
  static const String deviceId = 'p_device_id';

  /// 지금 보유 epoch(`lease_renew`).
  static const String epoch = 'p_epoch';

  /// 첫 클레임 때 복구 코드 해시(`lease_claim` · 평문 0 · 그 밖 클레임 = null).
  static const String recoveryCodeHash = 'p_recovery_code_hash';

  /// 복구 코드 평문(`lease_revoke` · 서버가 해시와 대조 · 🔴 저장 · 로그 0).
  static const String recoveryCode = 'p_recovery_code';

  /// 새 복구 코드 해시(`lease_revoke` · 같은 트랜잭션에서 교체).
  static const String newRecoveryCodeHash = 'p_new_recovery_code_hash';

  static const Set<String> values = <String>{
    deviceId,
    epoch,
    recoveryCodeHash,
    recoveryCode,
    newRecoveryCodeHash,
  };
}

/// 리스 RPC 반환 칸(한 행).
abstract final class LeaseRpcColumns {
  /// 거부 코드(`LeaseRpcResultCodes`) · 성공 = null.
  static const String code = 'code';

  /// 리스 epoch(성공 = 그 뒤 값 · 거부 = 지금 값 또는 null).
  static const String epoch = 'epoch';

  /// 리스 만료 시각(서버 `now()` 기준 · `lease_revoke` = 즉시 만료 시각).
  static const String expiresAt = 'expires_at';

  static const Set<String> values = <String>{code, epoch, expiresAt};
}

// ── 🆕 계약 v1.37(01 §46 · K324 · K325 · 01 §8 미결 218 ⓕ · 13 §8 R244 넘김 (가)(나)(다)) X1 계획 이전 리스 넘김 ──────────
// 🔴 **엔진 예고** — SQL 본문 · data_sync 클라이언트 · 부트스트랩 대조 시험 = 01 §8 미결 228. 위 세 표(`LeaseRpcNames` · `Params` ·
//    `Columns`)는 지금 SQL 이 쓰는 글자 그대로 둔다(부트스트랩 시험 «계약 밖 함수 0» · «거부 글자 = 사전 5» 가 깨지지 않게 · K291 결) —
//    엔진이 SQL 을 지을 때 두 표의 합집합으로 넓힌다.
// 🔴 반환 = 같은 한 행(`LeaseRpcColumns` 셋) · 거부 = `LeaseRpcResultCodes` ∪ `LeaseHandoverResultCodes` · 시각 = 서버 `now()`.
// 🔴 티켓 TTL 값 = 운영 설정 `migration.ticket_ttl_minutes`(SPEC 02 §4 · 잠정 값 · 발주자 확정 대기 — 서버 상수 0 · 계약 수치 0).

/// 계획 이전 리스 넘김 RPC 이름(06 X1-2 «RETIRED 서명» 단계).
abstract final class LeaseHandoverRpcNames {
  /// 옛 폰 은퇴 — **한 트랜잭션**: 그 기기 `app_device.status = 'RETIRED'` · 리스 즉시 만료(`expires_at = now()`) · 넘김 티켓
  /// 해시 · 만료 기록(`operator_lease.ticket_hash` · `ticket_expires_at`). 조건 = 부른 사용자 = 그 기기 `auth_uid` ∧ 리스 행 =
  /// 그 기기 ∧ epoch 같음(만료됐어도 그 뒤 다른 기기가 안 가져갔으면) · 거부 = 다른 기기 · epoch 다름 `LEASE_LOST` · 남의 기기 ·
  /// `REVOKED` `LEASE_DEVICE_NOT_ELIGIBLE` · 해시 없음 `LEASE_TICKET_REQUIRED`. 🔵 이미 `RETIRED` ∧ 같은 epoch ∧ 아직 아무도
  /// 클레임 안 함 = 티켓 교체(재발급 · 멱등 재시도). 반환 `expires_at` = **티켓 만료 시각**(리스는 이미 끝났다 · 엔진 티켓 `exp` 원천).
  /// 🔴 RETIRED 쓰기 · 리스 놓기를 둘로 나누지 않는다 — «RETIRED 인데 리스 보유» 중간 상태 0(K324).
  static const String retire = 'device_retire';

  static const Set<String> values = <String>{retire};
}

/// 계획 이전 리스 넘김 RPC 인자 이름.
abstract final class LeaseHandoverRpcParams {
  /// 넘김 티켓 논스의 sha256(16진 64 · `device_retire` · 평문 0 — 평문은 QR 페이로드에만(엔진 `TransferTicket.nonce`)).
  static const String ticketNonceHash = 'p_ticket_nonce_hash';

  /// 티켓 수명(분 · `device_retire` · 값 = 운영 설정 `migration.ticket_ttl_minutes` · 0 이하 = 서버가 받지 않는다).
  static const String ticketTtlMinutes = 'p_ticket_ttl_minutes';

  /// 넘김 티켓 논스 평문(`lease_claim` 셋째 인자 · `text default null` · 서버가 sha256 으로 대조 · 🔴 저장 · 로그 0).
  /// 대기 티켓이 있으면: 없음 `LEASE_TICKET_REQUIRED` · 다름 `LEASE_TICKET_INVALID` · 만료 `LEASE_TICKET_EXPIRED` · 맞음 = 클레임
  /// (epoch+1 · 그 기기 operator `ACTIVE` · 티켓 지움). 대기 티켓 없음 = 기존 규칙(논스 무시). `lease_revoke`(비상) = 대기 티켓도 지운다.
  static const String ticketNonce = 'p_ticket_nonce';

  static const Set<String> values = <String>{
    ticketNonceHash,
    ticketTtlMinutes,
    ticketNonce,
  };
}

// ── 🆕 계약 v1.38(01 §47 · K330~K337 · 01 §8 미결 222 ⓑ · 06 M4-1 · 13 §8 R251) 읽기 모델 push RPC ──────────────────────────
// 🔴 `rm_*` 쓰기 = 이 RPC 1창구(security definer · 리스 epoch 검사 · 클라이언트 upsert 0 — 01 §6-4 말미 · 규칙 5조 ④).
//    SQL 본문 · data_sync 클라이언트 · 부트스트랩 대조 시험 = 엔진(E11l2 · 미결 222 ⓑ). 여기는 **글자만**(지도 X18).
// 🔴 한 호출 = 한 표 · 한 트랜잭션 — 행 하나라도 못 넣으면 그 호출 전부 0행(`READ_MODEL_ROWS_INVALID`) · 삭제 0.
// 🔴 반환 = 한 행(`ReadModelPushRpcColumns` 넷) · 거부 = [LeaseRpcResultCodes] 의 `LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE` ∪
//    `ReadModelPushResultCodes` · 성공 = `code` null · 시각 = 서버 `now()`.

/// 읽기 모델 push RPC 이름(06 M4-1 «1개 창구»).
abstract final class ReadModelPushRpcNames {
  /// 한 표의 행 묶음을 올린다 — 조건 = 부른 사용자 = 그 기기 `auth_uid` = `owner_uid` ∧ role `operator` ∧ `ACTIVE` ∧
  /// 리스 행 = 그 기기 ∧ epoch 같음 ∧ 만료 전(아니면 `LEASE_LOST` · 남의 기기 · 뷰어 · `REVOKED` · `RETIRED` = `LEASE_DEVICE_NOT_ELIGIBLE`) ·
  /// 표 ∈ `ReadModelTables`(아니면 `READ_MODEL_TABLE_UNKNOWN`) · 행 = JSON 배열(열 이름 키 = `ReadModelTables` 열 · 규칙 5조
  /// `row_version` · `mode` · 키 · 🔴 `lease_epoch` · `pushed_at` 은 서버가 덮어쓴다 = 인자 epoch · `now()`) ·
  /// 기본 키 충돌 = `row_version` 이 **큰** 행만 반영(같거나 작으면 건너뜀 · 규칙 5조 ②).
  static const String push = 'rm_push';

  static const Set<String> values = <String>{push};
}

/// 읽기 모델 push RPC 인자 이름(PostgREST `rpc/rm_push` 본문 키).
abstract final class ReadModelPushRpcParams {
  /// 부르는 기기(= [LeaseRpcParams.deviceId] 와 같은 글자).
  static const String deviceId = LeaseRpcParams.deviceId;

  /// 지금 보유 리스 epoch(= [LeaseRpcParams.epoch] 와 같은 글자 · 행의 `lease_epoch` 원천).
  static const String epoch = LeaseRpcParams.epoch;

  /// 표 이름(`ReadModelTable.name` 그대로 · `rm_` 접두).
  static const String table = 'p_table';

  /// 행 묶음(JSON 배열 · 행 = 열 이름 → 와이어 값 · 빈 배열 = 0행 성공).
  static const String rows = 'p_rows';

  static const Set<String> values = <String>{deviceId, epoch, table, rows};
}

/// 읽기 모델 push RPC 반환 칸(한 행).
abstract final class ReadModelPushRpcColumns {
  /// 거부 코드 · 성공 = null.
  static const String code = 'code';

  /// 지금 리스 epoch(성공 = 인자 epoch · 거부 = 지금 값 또는 null).
  static const String epoch = 'epoch';

  /// 넣거나 바꾼 행 수(성공 · 거부 = 0).
  static const String accepted = 'accepted';

  /// `row_version` 이 크지 않아 건너뛴 행 수(성공 · 거부 = 0).
  static const String skipped = 'skipped';

  static const Set<String> values = <String>{code, epoch, accepted, skipped};
}

// ── 🆕 계약 v1.40(01 §49 · K353~ · 01 §8 미결 229 · 222 ⓕ · 06 M4-1 · 06 X2-7 · 13 §8 R270 W1~W8) 운영 폰 공유 표 push RPC ──────────────
// 🔴 `rm_*` 밖 배치 D 쓰기 표 다섯(`OpsPushTables`) = 이 RPC 1창구 — 쓰는 주체 = 다섯 다 운영 폰 엔진 · 리스 보유자(뷰어 · 서버 쓰기 0 ·
//    클라이언트 INSERT · UPDATE · DELETE 정책 0 그대로). `rm_push`(v1.38)로 받지 않는다 — 열 관례가 다르다(`row_version` 없는 표 2 ·
//    시각 칸 `acked_at` · `updated_at` · `stamped_at` · epoch 칸 `operator_epoch`) · `rm_push` 표 목록 = `ReadModelTables` 22 그대로(C-71).
//    SQL 본문 · 부트스트랩 다섯째 조각 · 대조 시험 = 엔진(data_sync `sql/supabase_ops_push_rpc.sql`). 여기는 **글자만**(지도 X18).
// 🔴 한 호출 = 한 표 · 한 트랜잭션 — 행 하나라도 못 넣으면 그 호출 전부 0행(`OPS_PUSH_ROWS_INVALID`) · 삭제 0 · 표마다 정적 SQL(동적 SQL 0).
// 🔴 반환 = 한 행(`OpsPushRpcColumns` 넷 = `ReadModelPushRpcColumns` 글자) · 거부 = [LeaseRpcResultCodes] 의 `LEASE_LOST` ·
//    `LEASE_DEVICE_NOT_ELIGIBLE` ∪ `OpsPushResultCodes` · 성공 = `code` null · 시각 = 서버 `now()`.

/// 운영 폰 공유 표 push RPC 이름(06 M4-1 «쓰기 = security definer RPC · 클라이언트 upsert 0»).
abstract final class OpsPushRpcNames {
  /// 한 표의 행 묶음을 올린다 — 기기 · 리스 판정 = [ReadModelPushRpcNames.push] 와 **같은 문장**(부른 사용자 = 그 기기 `auth_uid` =
  /// `owner_uid` ∧ role `operator` ∧ `ACTIVE`(아니면 `LEASE_DEVICE_NOT_ELIGIBLE`) ∧ 리스 행 = 그 기기 ∧ epoch 같음 ∧ 만료 전(아니면
  /// `LEASE_LOST`) · 같은 advisory 잠금 공유) · 표 ∈ [OpsPushTables.all](아니면 `OPS_PUSH_TABLE_UNKNOWN`) · 행 = JSON 배열(열 이름 키 =
  /// 배치 D 그 표 열 · 🔴 epoch 칸(`lease_epoch` · `operator_epoch`) = 인자 epoch · 시각 칸(`acked_at` · `updated_at` · `stamped_at`) =
  /// 서버 `now()` 로 덮어쓴다 — 행이 실은 값 무시). 표마다 충돌 규칙:
  /// `command_ack` = **append-only**(같은 `ack_id` = 건너뜀 · 바꾸지 않음 · `command_id` = 부른 사용자 소유 명령만 · 한 호출에 같은 명령 두 번 =
  /// `OPS_PUSH_ROWS_INVALID` — `acked_at` 이 트랜잭션 시각 하나라 뷰어가 차례를 못 가른다) · `planned_work_mirror` = `row_version` 이 **큰**
  /// 행만(같거나 작으면 건너뜀) · `resume_run_mirror` · `ledger_stamp`(재생성 = 같은 날 다시 씀) · `calendar_sync_status` = 덮는다.
  static const String push = 'op_push';

  static const Set<String> values = <String>{push};
}

/// 운영 폰 공유 표 push RPC 인자 이름(PostgREST `rpc/op_push` 본문 키 · [ReadModelPushRpcParams] 글자 그대로).
abstract final class OpsPushRpcParams {
  /// 부르는 기기(= [LeaseRpcParams.deviceId]).
  static const String deviceId = ReadModelPushRpcParams.deviceId;

  /// 지금 보유 리스 epoch(= [LeaseRpcParams.epoch] · 행의 epoch 칸 원천).
  static const String epoch = ReadModelPushRpcParams.epoch;

  /// 표 이름([OpsPushTables.all] 가운데 하나 · 배치 D 표 이름 그대로).
  static const String table = ReadModelPushRpcParams.table;

  /// 행 묶음(JSON 배열 · 행 = 열 이름 → 와이어 값 · 빈 배열 = 0행 성공).
  static const String rows = ReadModelPushRpcParams.rows;

  static const Set<String> values = <String>{deviceId, epoch, table, rows};
}

/// 운영 폰 공유 표 push RPC 반환 칸(한 행 · [ReadModelPushRpcColumns] 글자 그대로).
abstract final class OpsPushRpcColumns {
  /// 거부 코드 · 성공 = null.
  static const String code = ReadModelPushRpcColumns.code;

  /// 지금 리스 epoch(성공 = 인자 epoch · 거부 = 지금 값 또는 null).
  static const String epoch = ReadModelPushRpcColumns.epoch;

  /// 넣거나 바꾼 행 수(성공 · 거부 = 0).
  static const String accepted = ReadModelPushRpcColumns.accepted;

  /// 건너뛴 행 수(`command_ack` 같은 `ack_id` · `planned_work_mirror` `row_version` 이 크지 않음 · 거부 = 0).
  static const String skipped = ReadModelPushRpcColumns.skipped;

  static const Set<String> values = <String>{code, epoch, accepted, skipped};
}

/// `op_push` 가 받는 표 다섯(배치 D `ddl/batch_d_supabase.sql` 표 이름 · 차례 = 그 파일 차례 · `rm_*` 와 서로소).
abstract final class OpsPushTables {
  /// 명령 소비 ack(엔진 E11m) — append-only · 명령당 여러 행.
  static const String commandAck = 'command_ack';

  /// X2 작업 원장 미러(digest + 한 줄 · 원문 0) — `row_version` 큰 쪽.
  static const String plannedWorkMirror = 'planned_work_mirror';

  /// X2 재개 회차 미러 — 마지막 보낸 값.
  static const String resumeRunMirror = 'resume_run_mirror';

  /// X5 `canonSupabase` 파생 스탬프 — 같은 날 다시 씀 · `operator_epoch` = 쓴 기기 epoch(FORK 재료).
  static const String ledgerStamp = 'ledger_stamp';

  /// X4 캘린더 동기 상태(모드마다 한 행 · ⏸ 실전 뒤 K107).
  static const String calendarSyncStatus = 'calendar_sync_status';

  static const List<String> all = <String>[
    commandAck,
    plannedWorkMirror,
    resumeRunMirror,
    ledgerStamp,
    calendarSyncStatus,
  ];
}
```

---

## `packages/domain_contracts/lib/src/testing/deposit_register_rules.dart`

```dart
// 실입금 등록 접수증 판정 — C-38 ⑨. 01 §7 표 · §14-7 · §20.
//
// 왜 여기 있는가(설계 13 §8 R22 D14 · E7b0): 같은 판정을 **픽스처**(계약 테스트 c38)와 **실엔진 접수증**
//   (core_engine 등록 처리 시험 · E7b2)에 똑같이 건다 — `what_if_rules.dart` 와 같은 이유다.
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다(`testing.dart` 머리).
// 🔴 함수는 판정만 한다 — 위반 문장 목록을 돌려주고 빈 목록 = 통과.
// 🔴 픽스처 전용 단언(행 순서 · 상태 집합)은 계약 테스트에 남는다 — 실엔진 접수증 한 건은 한 상태다.

import '../../domain_contracts.dart';

/// C-38 ⑨ — 행이 있다 · 전 행 kind = `DEPOSIT_REGISTER` · 사유 코드가 필요한 상태(`rejected`)는
/// `deposit_register_reject` 사전의 코드를 싣고, 그 밖의 상태는 사유 코드를 싣지 않는다.
List<String> depositReceiptViolations(
  String where,
  List<CommandReceipt> rows,
) => <String>[
  if (rows.isEmpty) '$where — 행이 없다',
  for (final (int i, CommandReceipt r) in rows.indexed) ...<String>[
    if (r.kind != CommandKind.depositRegister)
      '$where rows[$i] — kind ${r.kind.wire} ≠ DEPOSIT_REGISTER',
    if (CommandStateMachine.requiresRejectReasonCode(r.state) &&
        !ContractCodes.isRegisteredIn(
          'deposit_register_reject',
          r.rejectReasonCode ?? '',
        ))
      '$where rows[$i] — 거부 사유 ${r.rejectReasonCode} 가 deposit_register_reject 사전에 없다',
    if (!CommandStateMachine.requiresRejectReasonCode(r.state) &&
        r.rejectReasonCode != null)
      '$where rows[$i] — ${r.state.wire} 인데 거부 사유 ${r.rejectReasonCode} 가 실렸다',
  ],
];
```

---

## `packages/domain_contracts/lib/src/testing/what_if_rules.dart`

```dart
// What-if 미리보기 표시 계약의 판정 함수 — C-38 ①~⑧(입금) · C-41 ①②(리밸런싱). 01 §7 표 · §14 · §15-4-12.
//
// 왜 여기 있는가(설계 13 §8 R18 D-12 · E7a0): 같은 판정을 **픽스처**(계약 테스트 c38 · c41)와 **실엔진 출력**
//   (core_engine 의 What-if 구현 시험)에 똑같이 걸어야 한다. 판정이 `test/` 안의 비공개 함수로만 있으면
//   엔진 쪽이 사본을 만들게 되고 두 판이 갈라진다 — 그래서 테스트 전용 배럴(`testing.dart`)로 낸다.
// 🔴 `lib/` 의 화면 코드에서 import 하지 않는다(받침대와 같은 규칙 · `testing.dart` 머리).
// 🔴 함수는 판정만 한다 — 위반 문장 목록을 돌려주고 빈 목록 = 통과. 값을 고치거나 지어내지 않는다.
// 🔴 픽스처 전용 단언(갈래 표본 수 · 행 순서 · 밴드 표본 정합)은 계약 테스트에 남는다 —
//    실엔진 출력에는 참이 아닐 수 있다(예: B 신호·C·POT 는 밴드 안에서도 초안을 만든다).
// 🆕 v1.11 — 접수증 ⑨ 의 판정은 `deposit_register_rules.dart`(행 순서·상태 집합만 계약 테스트에 남는다).

import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../domain_contracts.dart';

/// C-38 ③ · C-41 ② — 미리보기 고지 문장의 머리.
const String kPreviewNoticeHead = '미리보기입니다';

/// C-38 ① — 래퍼는 `plan` · `inputRejectedText` · `blockedText` 가운데 **정확히 하나** non-null ·
/// `blockedAction` 은 `blockedText` 가 있을 때만 · 실린 글자는 비지 않는다.
List<String> depositPreviewResultViolations(
  String where,
  DepositPreviewResult r,
) {
  final List<String> bad = <String>[];
  final int n = <Object?>[
    r.plan,
    r.inputRejectedText,
    r.blockedText,
  ].where((Object? x) => x != null).length;
  if (n != 1) {
    bad.add(
      '$where — plan·input_rejected_text·blocked_text 가 $n개 non-null(정확히 하나여야 한다)',
    );
  }
  if (r.blockedAction != null && r.blockedText == null) {
    bad.add('$where — blocked_text 없이 blocked_action 이 있다');
  }
  for (final (String key, String? text) in <(String, String?)>[
    ('input_rejected_text', r.inputRejectedText),
    ('blocked_text', r.blockedText),
    ('blocked_action.label', r.blockedAction?.label),
  ]) {
    if (text != null && text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  return bad;
}

/// C-38 ② — 표시 글자(`label` · `*_label` · `*_text` · 제목 · 고지 · 근거)가 비지 않는다 ·
/// `residualKrwCashText == null ⇔ residualKrwCash == 0` · `ordersEmptyText != null ⇔ 빈 초안` ·
/// `limitPriceText == null ⇔ limitPrice == null`.
List<String> depositPlanTextViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  _walkJson(jsonDecode(jsonEncode(p.toJson())), (
    String jsonPath,
    String key,
    Object? value,
  ) {
    final bool textKey =
        key == 'label' ||
        key.endsWith('_label') ||
        key.endsWith('_text') ||
        key == 'order_drafts_title' ||
        key == 'preview_notice' ||
        key == 'basis_note';
    if (textKey && value is String && value.trim().isEmpty) {
      bad.add('$where $jsonPath — 빈 글자다');
    }
  });
  for (int i = 0; i < p.warningLines.length; i++) {
    if (p.warningLines[i].trim().isEmpty) {
      bad.add('$where warning_lines[$i] — 빈 글자다');
    }
  }
  final bool zeroResidual = p.residualKrwCash == Decimal.zero;
  if ((p.residualKrwCashText == null) != zeroResidual) {
    bad.add(
      '$where — residual_krw_cash ${p.residualKrwCash} · residual_krw_cash_text '
      '${p.residualKrwCashText == null ? '없음' : '있음'}(null ⇔ 잔여 0)',
    );
  }
  bad.addAll(_draftListViolations(where, p.orderDrafts, p.ordersEmptyText));
  return bad;
}

/// C-38 ③ — 계획 **여럿**에 걸친다: 모든 `previewNotice` 가 «미리보기입니다»로 시작하고 같은 문자열이다
/// (고지 전용 — 경고·만료를 싣지 않는다 · 01 §14-5). 엔진 시험은 시나리오 출력 전부를 한 목록으로 넘긴다.
List<String> depositPreviewNoticeViolations(List<(String, DepositPlan)> plans) {
  final List<String> bad = <String>[];
  final Set<String> distinct = <String>{};
  for (final (String where, DepositPlan p) in plans) {
    distinct.add(p.previewNotice);
    if (!p.previewNotice.startsWith(kPreviewNoticeHead)) {
      bad.add(
        '$where — preview_notice 가 «$kPreviewNoticeHead»로 시작하지 않는다: ${p.previewNotice}',
      );
    }
  }
  if (distinct.length > 1) {
    bad.add('preview_notice 가 같은 문자열이 아니다(고지 전용 — 경고·만료를 싣지 않는다): $distinct');
  }
  return bad;
}

/// C-38 ④ — `fundingSteps` 는 null 이거나 비지 않는다 · `order` 1부터 연속 · `expectedProceeds > 0`.
List<String> depositFundingViolations(String where, DepositPlan p) {
  final List<FundingStep>? steps = p.fundingSteps;
  if (steps == null) {
    return const <String>[];
  }
  if (steps.isEmpty) {
    return <String>['$where — funding_steps 가 빈 목록이다(null 이거나 비지 않아야 한다)'];
  }
  final List<String> bad = <String>[];
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].order != i + 1) {
      bad.add(
        '$where funding_steps[$i] — order ${steps[i].order} ≠ ${i + 1}(1부터 연속)',
      );
    }
    if (steps[i].expectedProceeds <= Decimal.zero) {
      bad.add(
        '$where funding_steps[$i] — expected_proceeds ${steps[i].expectedProceeds} ≤ 0(0원 단계 금지)',
      );
    }
  }
  return bad;
}

/// C-38 ⑤ — Σ `allocations.amount` + `residualKrwCash` == `depositAmount`(Decimal 정확히).
List<String> depositSumViolations(String where, DepositPlan p) {
  final Decimal sum = p.allocations.fold(
    p.residualKrwCash,
    (Decimal acc, SleeveAllocation a) => acc + a.amount,
  );
  return <String>[
    if (sum != p.depositAmount)
      '$where — 충당 합 + 잔여 $sum ≠ 입금액 ${p.depositAmount}',
  ];
}

/// C-38 ⑥ — 슬리브별 Σ(지정가 × 수량, 매수 초안) ≤ 그 슬리브 충당액 · 지정가 없는 매수 초안 = 위반.
List<String> depositBuyWithinAllocationViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  final Map<SleeveId, Decimal> buys = <SleeveId, Decimal>{};
  for (int i = 0; i < p.orderDrafts.length; i++) {
    final OrderDraft o = p.orderDrafts[i];
    if (o.side != OrderSide.buy) {
      continue;
    }
    if (o.limitPrice == null) {
      bad.add(
        '$where order_drafts[$i] — 매수 초안에 지정가가 없다(슬리브 ${o.sleeve.wire} 합을 볼 수 없다)',
      );
      continue;
    }
    buys[o.sleeve] =
        (buys[o.sleeve] ?? Decimal.zero) +
        o.limitPrice! * Decimal.fromInt(o.quantity);
  }
  for (final MapEntry<SleeveId, Decimal> e in buys.entries) {
    final Decimal allocated = p.allocations
        .where((SleeveAllocation a) => a.sleeve == e.key)
        .fold(
          Decimal.zero,
          (Decimal acc, SleeveAllocation a) => acc + a.amount,
        );
    if (e.value > allocated) {
      bad.add('$where — 슬리브 ${e.key.wire} 매수 초안 합 ${e.value} > 충당액 $allocated');
    }
  }
  return bad;
}

/// C-38 ⑦ — 슬리브 B 행(충당·초안)의 별칭 ∈ [pensionAliases] · 모든 별칭 ∈ [allAliases].
/// 계약 테스트는 픽스처 별칭 표(`fixtures/README.md`)를, 엔진 시험은 계좌 매핑을 넘긴다.
List<String> depositAccountViolations(
  String where,
  DepositPlan p, {
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) {
  final List<String> bad = <String>[];
  final List<(String, SleeveId, String?)> aliases =
      <(String, SleeveId, String?)>[
        for (final (int i, SleeveAllocation a) in p.allocations.indexed)
          ('allocations[$i]', a.sleeve, a.accountAlias),
        for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
          ('order_drafts[$i]', o.sleeve, o.accountAlias),
      ];
  for (final (String at, SleeveId sleeve, String? alias) in aliases) {
    if (sleeve == SleeveId.b && !pensionAliases.contains(alias)) {
      bad.add('$where $at — 슬리브 B 가 연금 계좌가 아니다: $alias(SPEC v2.23 가드)');
    }
    if (alias != null && !allAliases.contains(alias)) {
      bad.add('$where $at — 계좌 별칭 표 밖 별칭: $alias');
    }
  }
  return bad;
}

/// C-38 ⑧ — 사유 칩 코드 ∈ `ContractCodes`.
List<String> depositReasonCodeViolations(String where, DepositPlan p) =>
    <String>[
      for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
        for (final ReasonChip c in o.reasons)
          if (!ContractCodes.isRegistered(c.code))
            '$where order_drafts[$i] — 사유 코드 ${c.code} 가 ContractCodes 에 없다',
    ];

/// C-38 ②④⑤⑥⑦⑧ 를 한 계획에 한꺼번에(③ 은 여럿에 걸쳐 [depositPreviewNoticeViolations] 로 따로).
List<String> depositPlanViolations(
  String where,
  DepositPlan p, {
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) => <String>[
  ...depositPlanTextViolations(where, p),
  ...depositFundingViolations(where, p),
  ...depositSumViolations(where, p),
  ...depositBuyWithinAllocationViolations(where, p),
  ...depositAccountViolations(
    where,
    p,
    pensionAliases: pensionAliases,
    allAliases: allAliases,
  ),
  ...depositReasonCodeViolations(where, p),
];

/// C-41 ① — `preview` · `blockedText` 정확히 하나 · `blockedAction` ⇒ `blockedText` · 실린 글자는 비지 않는다.
List<String> rebalancePreviewResultViolations(
  String where,
  RebalancePreviewResult r,
) {
  final List<String> bad = <String>[];
  if ((r.preview != null) == (r.blockedText != null)) {
    bad.add('$where — preview·blocked_text 가 둘 다 있거나 둘 다 없다(화면이 갈래를 고르게 된다)');
  }
  if (r.blockedAction != null && r.blockedText == null) {
    bad.add('$where — blocked_text 없이 blocked_action 이 있다(문장 없는 버튼)');
  }
  for (final (String key, String? text) in <(String, String?)>[
    ('blocked_text', r.blockedText),
    ('blocked_action.label', r.blockedAction?.label),
  ]) {
    if (text != null && text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  return bad;
}

/// C-41 ② — 초안이 스스로 갖출 것: `asOf` == [asOf](계약 테스트 = 봉투 · 엔진 = 계산에 쓴 as-of) ·
/// `plannedDateText`·`orderDraftsTitle` 비지 않음 · 고지 머리 · `ordersEmptyText != null ⇔ 빈 초안` ·
/// 지정가 짝 · `sideLabel`·`quantityText` 비지 않음 · 별칭 ∈ [allAliases] · 슬리브 B ∈ [pensionAliases].
/// 🔴 «초안이 있으면 before 에 밴드 밖 슬리브가 있다»는 픽스처 표본 정합이지 엔진 불변식이 아니다 — 넣지 않는다.
List<String> rebalancePreviewViolations(
  String where,
  RebalancePreview p, {
  required AsOf asOf,
  required Set<String> pensionAliases,
  required Set<String> allAliases,
}) {
  final List<String> bad = <String>[];
  if (p.asOf != asOf) {
    bad.add('$where — 초안 기준 시각(as_of)이 ${p.asOf.label} — 기대 ${asOf.label}');
  }
  for (final (String key, String text) in <(String, String)>[
    ('planned_date_text', p.plannedDateText),
    ('order_drafts_title', p.orderDraftsTitle),
  ]) {
    if (text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  if (!p.previewNotice.startsWith(kPreviewNoticeHead)) {
    bad.add(
      '$where — preview_notice 가 «$kPreviewNoticeHead»로 시작하지 않는다: ${p.previewNotice}',
    );
  }
  bad.addAll(_draftListViolations(where, p.orderDrafts, p.ordersEmptyText));
  for (final (int i, OrderDraft d) in p.orderDrafts.indexed) {
    for (final (String key, String text) in <(String, String)>[
      ('side_label', d.sideLabel),
      ('quantity_text', d.quantityText),
    ]) {
      if (text.trim().isEmpty) {
        bad.add('$where order_drafts[$i] — $key 가 빈 글자다');
      }
    }
    if (!allAliases.contains(d.accountAlias)) {
      bad.add('$where order_drafts[$i] — 계좌 별칭 표 밖 별칭: ${d.accountAlias}');
    }
    if (d.sleeve == SleeveId.b && !pensionAliases.contains(d.accountAlias)) {
      bad.add(
        '$where order_drafts[$i] — 슬리브 B 가 연금 계좌가 아니다: ${d.accountAlias}',
      );
    }
  }
  return bad;
}

/// 빈 초안 문장 ⇔ 빈 목록 · 지정가 글자 ⇔ 지정가(입금·리밸런싱 공통 — 인출 초안은 대상 아님).
List<String> _draftListViolations(
  String where,
  List<OrderDraft> drafts,
  String? ordersEmptyText,
) {
  final List<String> bad = <String>[];
  if ((ordersEmptyText != null) != drafts.isEmpty) {
    bad.add(
      '$where — order_drafts ${drafts.length}건 · orders_empty_text '
      '${ordersEmptyText == null ? '없음' : '있음'}(non-null ⇔ 빈 목록)',
    );
  }
  for (int i = 0; i < drafts.length; i++) {
    final OrderDraft o = drafts[i];
    if ((o.limitPriceText == null) != (o.limitPrice == null)) {
      bad.add(
        '$where order_drafts[$i] — limit_price ${o.limitPrice} · limit_price_text '
        '${o.limitPriceText}(둘은 함께 비거나 함께 온다)',
      );
    }
  }
  return bad;
}

/// JSON 트리를 훑으며 `(키 경로, 키, 값)` 을 넘긴다 — 계약 테스트 `c00_support.walkJson` 과 같은 순서.
void _walkJson(
  Object? node,
  void Function(String path, String key, Object? value) visit, {
  String path = '',
}) {
  if (node is Map<String, Object?>) {
    for (final MapEntry<String, Object?> e in node.entries) {
      final String childPath = path.isEmpty ? e.key : '$path.${e.key}';
      visit(childPath, e.key, e.value);
      _walkJson(e.value, visit, path: childPath);
    }
  } else if (node is List<Object?>) {
    for (int i = 0; i < node.length; i++) {
      _walkJson(node[i], visit, path: '$path[$i]');
    }
  }
}
```
