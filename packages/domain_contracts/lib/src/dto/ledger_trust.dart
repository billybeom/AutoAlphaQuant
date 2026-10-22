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
