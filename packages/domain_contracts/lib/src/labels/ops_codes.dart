// 01 §3 · 🆕 계약 v1.17(01 §26 · K19) — M8 운영 화면의 🔒/플랫폼 슬롯 이름.
//
// 🔴 «어떤 슬롯 이름이 오는가» 의 상수 목록이다 — 화면은 이름을 슬롯 빌더(`shellOpsSlotBuilderProvider`)에 그대로 넘기고
//    이름으로 분기·위젯을 고르지 않는다. 이름 → 위젯 = 조립 앱(06 M4-12 · v1.16 `OnboardingSlotIds` 꼴).

/// M8 운영 슬롯 이름.
abstract final class OpsSlotIds {
  /// `D-03` 긴급정지 카드 인쇄·PDF 저장 — 플랫폼(조립 앱 · 04 §2-1 금지 5 의 유일한 예외).
  static const String emergencyCardPrint = 'EMERGENCY_CARD_PRINT';

  /// 🆕 v1.25(01 §34 · K152) — 셸 킬스위치 자리(폰 앱바 · 웹 사이드바 `s02-kill-slot`) · 위젯 = `ui_safety` 발동 버튼(조립 앱 슬롯 빌더) ·
  /// 🔴 셸 = 자리만(확인 대화·핸들러 감싸기 0 — 04 §3-2) · 빌더 null = 자리 부재 · 잠금 오버레이가 덮지 않는다(05 §1).
  static const String killSwitch = 'KILL_SWITCH';

  static const Set<String> values = <String>{emergencyCardPrint, killSwitch};
}
