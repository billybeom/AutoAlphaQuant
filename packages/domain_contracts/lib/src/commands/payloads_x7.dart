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
