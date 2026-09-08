// 01 §2-6 — 미리보기 계획 스냅샷(M3·M7 요구 4 · Q-F)와 그 값 객체들.
//
// 🔴 **월 추가 납입 운영값을 화면·계약·픽스처에 상수로 적지 않는다**(01 §2-6 ·
//    C-32). 읽기 창구는 `ConfigRepository.watchContributionSetting()` 하나이고
//    변경 창구는 `SettingsActions`(운영 등급)다.
// 🔴 `fundingSteps` 가 null·빈 목록이면 화면은 그 절을 **통째로 숨긴다** —
//    0건을 「0원」으로 그리지 않는다(01 §2-6 v2.32 `PENSION_FUNDING`).
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/journal.dart';
import '../enums/order.dart';
import '../enums/sleeve.dart';
import '../primitives/money.dart';
import 'common.dart';
import 'performance.dart';
import 'rebalance.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

/// 01 §2-6 — 입금 미리보기 계획.
/// 🔴 `expiresAt` 이 지난 계획으로는 실입금 등록이 거부된다(`plan_snapshot`).
@freezed
abstract class DepositPlan with _$DepositPlan {
  const factory DepositPlan({
    /// 🔴 실입금 등록 시 바인딩(계획 대비 실제 대조).
    required String planId,
    required DateTime computedAt,
    @TradeDateConverter() required TradeDate asOfTradeDate,
    required DateTime expiresAt,
    required String configHash,
    @DecimalStringConverter() required Decimal depositAmount,

    /// 슬리브별 충당액 — m2-8 F-11.
    required List<SleeveAllocation> allocations,
    @DecimalStringConverter() required Decimal pensionLimitConsumed,

    /// D2 = 원화 현금 대기(결정 7b). 🔴 유휴 자금이 아니다.
    @DecimalStringConverter() required Decimal residualKrwCash,
    required List<OrderDraft> orderDrafts,
    required CostEstimate costs,

    /// "미리보기입니다" — 엔진 생성.
    required String previewNotice,

    /// 🆕 v2.32 연금 납입 조달 단계(§3-6 `PENSION_FUNDING`).
    /// 🔴 null·빈 목록 = 절을 통째로 숨긴다.
    List<FundingStep>? fundingSteps,
  }) = _DepositPlan;

  factory DepositPlan.fromJson(Map<String, dynamic> json) =>
      _$DepositPlanFromJson(json);
}

/// 01 §2-6 — 주문 초안 1행.
@freezed
abstract class OrderDraft with _$OrderDraft {
  const factory OrderDraft({
    required String symbol,
    required String symbolLabel,
    required SleeveId sleeve,

    /// 🔴 계좌 전체번호 금지 — 별칭만.
    required String accountAlias,
    required OrderSide side,
    required int quantity,
    required List<ReasonChip> reasons,
    @DecimalStringConverter() Decimal? limitPrice,
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
    @DecimalStringConverter() required Decimal amount,

    /// 🔴 표시의 정본 — 화면이 금액을 포맷하지 않는다.
    required String amountText,
    String? accountAlias,
  }) = _SleeveAllocation;

  factory SleeveAllocation.fromJson(Map<String, dynamic> json) =>
      _$SleeveAllocationFromJson(json);
}

/// 01 §2-6 · m2-8 F-12 — 비용 추정(C18).
/// 🔴 구 `costsOverridden`(bool)은 폐기됐고 출처는 `CostSource` 가 말한다.
@freezed
abstract class CostEstimate with _$CostEstimate {
  const factory CostEstimate({
    @DecimalStringConverter() required Decimal commission,
    @DecimalStringConverter() required Decimal tax,
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
    required SleeveId sourceSleeve,
    required int quantity,
    @DecimalStringConverter() required Decimal expectedProceeds,

    /// 근거 규칙 코드 — 🔴 엔진 제공 목록의 값이며 자유 입력이 아니다.
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
