// 01 §3-6 — 원장 이벤트 코드 1종(납입 조달) · §6-2 `operating_param_log.param_key` 1종.
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
