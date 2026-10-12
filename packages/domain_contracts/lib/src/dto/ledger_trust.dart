// 01 §2-11 — X7 원장 신뢰 등급 · 이행 갭 · 시스템 밖 자산 · 현금 추정 고지.
//
// 🔴 `LedgerTrustGrade.selfReported` 는 **실패가 아니라 정상 운영 상태**다.
// 🔴 이행 갭에 원화 손익 필드가 없다 — 가격 갭은 **bp** 로만 온다(C-25).
// 🔴 «추천·권유·자문·시그널» 금지어 규약이 `modeAdviceLine` 에도 적용된다(§10-1).
// 🆕 v1.6(01 §15-4 · R12 선행) — 월간 결과 래퍼 `ExecutionGapResult`(리포트 | 빈·해당없음 문장) ·
//    `ExecutionGapReport.countLines`·`correctionLines` · `complianceRateNormalized`·`modeAdviceLine` nullable.
//    `S7-10` 의 «읽지 않는 필드»는 `// 🔴 ui 미참조(C-42)` 표식이다.
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
