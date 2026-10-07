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

    /// 사유 칩. 🔴 플래너(S7-4)는 `label`·`tone` 만 그린다 — `detailDeepLink` 는 읽지 않는다(D20).
    required List<ReasonChip> reasons,

    /// 🔴 ui 미참조(C-38 ⑩). 표시는 [limitPriceText].
    @DecimalStringConverter() Decimal? limitPrice,

    /// 🆕 v1.4 — 지정가 글자. non-null ⇔ [limitPrice] != null(C-38 ② · **`DepositPlan` 한정** —
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

/// 01 §2-6 · m2-8 F-14 — 리밸런싱 미리보기.
/// 🔴 `DepositPlan` 과 **같은** `fundingSteps` 를 싣는다(v2.32).
@freezed
abstract class RebalancePreview with _$RebalancePreview {
  const factory RebalancePreview({
    required String planId,
    @TradeDateConverter() required TradeDate plannedDate,
    required List<SleeveWeight> before,
    required List<SleeveWeight> after,
    required List<OrderDraft> orderDrafts,
    required CostEstimate costs,
    required String previewNotice,

    /// 🔴 null·빈 목록 = 조달 절을 통째로 숨긴다.
    List<FundingStep>? fundingSteps,
  }) = _RebalancePreview;

  factory RebalancePreview.fromJson(Map<String, dynamic> json) =>
      _$RebalancePreviewFromJson(json);
}
