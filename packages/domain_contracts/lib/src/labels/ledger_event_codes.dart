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
