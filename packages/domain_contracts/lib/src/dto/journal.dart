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

    /// 🆕 G-40 — 이 체결이 속한 리밸런싱 회차. null = 회차 밖(수기·입금 배분 등).
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

/// 임계값 대조 1행(02 §8-1 · m2-8 E-2).
///
/// 🔴 수치는 전부 **엔진 포맷 문자열**이다 — 화면이 비교식을 만들지 않는다.
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

/// 블라인드 리뷰 카드(`J-4`)(02 §8-1 · m2-8 E-5).
///
/// 🔴 문항·선택지 문구도 엔진이 준다.
@freezed
abstract class BlindReviewCard with _$BlindReviewCard {
  const factory BlindReviewCard({
    required String decisionId,
    required String promptText,
    required List<BlindReviewQuestion> questions,
  }) = _BlindReviewCard;

  factory BlindReviewCard.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewCardFromJson(json);
}

/// 블라인드 리뷰 문항 1건(m2-8 E-5).
@freezed
abstract class BlindReviewQuestion with _$BlindReviewQuestion {
  const factory BlindReviewQuestion({
    required String questionId,
    required String text,
    required List<ReasonOption> choices,
  }) = _BlindReviewQuestion;

  factory BlindReviewQuestion.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewQuestionFromJson(json);
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
///    «작성 중 손익 노출 금지»를 물려받고, `J-4` blind 리뷰(미결 46)가 [DecisionJournalBody] 를
///    재사용한다. C-34 ⑧ 이 허용 키 목록으로 막는다(필드 추가 = 01 개정이 먼저).
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

/// 🆕 v1.2 — 사전 저널 본문. ⏸ `J-4`(미결 46)의 `BlindReviewCard` 가 같은 타입을 싣는 것이 1순위 후보.
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
