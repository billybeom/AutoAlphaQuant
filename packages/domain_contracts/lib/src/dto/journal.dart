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
    required OrderSide side,
    required int quantity,
    @DecimalStringConverter() required Decimal price,
    @DecimalStringConverter() required Decimal commission,
    @DecimalStringConverter() required Decimal tax,
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
@freezed
abstract class RejectTrace with _$RejectTrace {
  const factory RejectTrace({
    required String stageCode,
    required String stageLabel,
    required String reasonCode,
    required String reasonLabel,
    required DateTime occurredAt,
  }) = _RejectTrace;

  factory RejectTrace.fromJson(Map<String, dynamic> json) =>
      _$RejectTraceFromJson(json);
}

/// 사전 저널(`J-3`) 폼 스펙(02 §8-1 · m2-8 E-4).
///
/// 🔴 `ruleCitedOptions` 는 **엔진 제공 목록**이며 자유 입력을 허용하지 않는다.
/// ⏸ `ReasonOption` 재사용은 m2-8 H-5(선행 미결 §8-20 · D19) — 통합 권고를 따랐다.
@freezed
abstract class JournalDraftFormSpec with _$JournalDraftFormSpec {
  const factory JournalDraftFormSpec({
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
