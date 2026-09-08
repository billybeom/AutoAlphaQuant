// 01 §2-11 — X7 원장 신뢰 등급 · 이행 갭 · 시스템 밖 자산 · 현금 추정 고지.
//
// 🔴 `LedgerTrustGrade.selfReported` 는 **실패가 아니라 정상 운영 상태**다.
// 🔴 이행 갭에 원화 손익 필드가 없다 — 가격 갭은 **bp** 로만 온다(C-25).
// 🔴 «추천·권유·자문·시그널» 금지어 규약이 `modeAdviceLine` 에도 적용된다(§10-1).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import '../primitives/date_range.dart';
import '../primitives/money.dart';
import 'common.dart';

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

/// 01 §2-11 — 이행 갭. M7 이 그리는 유일한 X7 지표 묶음(`S7-10`).
/// 🔴 `lateFilled`(지연 이행)는 분자에 **별도 계상**하고 라벨에 "(지연 이행 n건
///    포함)"을 엔진이 붙인다 — 지표는 정직하게, 벌점은 없다(A4).
@freezed
abstract class ExecutionGapReport with _$ExecutionGapReport {
  const factory ExecutionGapReport({
    required DateRange range,
    required String periodLabel,
    required int issued,
    required int filled,
    required int partial,
    required int skipped,
    required int lapsed,
    required int revoked,
    required int lateFilled,

    /// 0.0~1.0 — 🔴 게이지 폭 계산용 정규값만. 표시는 `complianceRateLabel`.
    required double complianceRateNormalized,

    /// "이행률 82%(건수) · 76%(금액 가중)" — 엔진 생성.
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
    required int backdatedCount,
    required int selfReportCorrectionCount,
    required LedgerTrustBadge trust,

    /// 🔴 B21 — **3갈래로 갈라 생성**된다: ⓐ「못 함」 우세 → 자동 이관 제안 /
    ///    ⓑ「안 함」 우세 → 이관을 제안하지 않는다 / ⓒ 갈리지 않음 → 아무 제안도
    ///    하지 않는다. 화면은 준 문장을 그대로 그린다.
    required String modeAdviceLine,
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
