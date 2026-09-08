// 01 §4-2 · §5-4 · §10 — 🆕 X7 명령 인자 DTO 8종.
//
// 🔴 각 DTO 의 `deviceId` 는 `CommandContext` 로 **옮겨졌다** — payload 가 기기를 다시
//    말하지 않는다. 🔴 payload 에 `idempotencyKey` 를 두지 않는다(A9).
// 🔴 `context` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이다(G-19 · C-28).
// 🔴 X7 8종은 **전량 폰(operator) 전용**이며 뷰어 화이트리스트를 건드리지 않는다.
//
// (§5-4 표는 기존 5종 계열과 이 8종을 한 표로 적는다 — 파일만 크기 규약상 나눴다.)

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../dto/ledger_trust.dart';
import '../enums/advice.dart';
import '../enums/order.dart';
import '../primitives/money.dart';
import 'command_context.dart';

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
  }) = _KillChecklistAck;

  factory KillChecklistAck.fromJson(Map<String, dynamic> json) =>
      _$KillChecklistAckFromJson(json);
}

// ⏸ `LedgerEventRecord` — 🔴 **결정 ㊲ 채택 시에만** 신설한다(J-6 · A-15).
//    이름은 확정됐고 **코드는 만들지 않는다**. 채택되지 않으면 인출·분배금·기업행위·
//    원천징수가 원장 밖에 남아 현금 추정이 단조적으로 어긋나고 그 위에서 안내 수량이
//    계산된다 — 그 사실을 여기 주석으로 남겨 둔다.
