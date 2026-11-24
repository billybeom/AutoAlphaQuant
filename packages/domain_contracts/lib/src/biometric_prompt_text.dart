// 🆕 계약 v1.39(01 §48 · K350 · 01 §8 미결 238 · 리뷰 3차 A-3) — OS 생체 대화상자 글자(목적마다 한 벌).
// 🔴 표지 글자 상수라 C-5 사전 대상(`lib/src/labels/`) 밖에 둔다(`ModeMarkerText` 선례 · byDomain 0).
// 🔴 무엇에 동의하는지 그대로 말한다 — 서약 글자는 [BiometricPurpose.pledgeSign] 에만 · 실주문을 켜는 동작은 «실제 주문»을 말한다.
// 🔴 금액 · 계좌 · 종목 · 수치 0(대화상자는 잠금 화면 위에도 뜬다).
// 🔵 서약 글자 = 엔진 core `BiometricSignTexts.promptTitle` · `promptSubtitle`(R159) 와 같은 글자 — 조립 배선 카드가 엔진을 이 상수로 옮긴다.

import 'enums/biometric.dart';

/// 생체 대화상자 한 벌(제목 · 설명).
final class BiometricPrompt {
  const BiometricPrompt(this.title, this.subtitle);

  /// 대화상자 제목.
  final String title;

  /// 대화상자 설명(한 문장).
  final String subtitle;
}

/// 목적 → 대화상자 글자.
abstract final class BiometricPromptText {
  /// 취소 버튼(목적 공통).
  static const String cancel = '취소';

  /// `O-04` ③ 서약 서명.
  static const BiometricPrompt pledgeSign = BiometricPrompt(
    '서약에 생체로 서명',
    '방금 쓴 서약 세 문장을 이 폰의 생체 인증으로 확인합니다.',
  );

  /// `M5-11` 실전 전환 시작.
  static const BiometricPrompt handoverStart = BiometricPrompt(
    '실전 전환 시작',
    '모의 운영을 마치고 실전 계좌로 옮기는 전환을 시작합니다. 확정 전까지 실제 주문은 나가지 않습니다.',
  );

  /// `S05` 실전 집행 승격.
  static const BiometricPrompt livePromotion = BiometricPrompt(
    '실제 주문 켜기',
    '관찰을 마치고 다음 회차부터 실전 계좌에 실제 주문을 내기 시작합니다.',
  );

  /// X1 기기 이전 — 새 폰에서 실거래 다시 열기.
  static const BiometricPrompt x1Migration = BiometricPrompt(
    '이 폰에서 운영 이어받기',
    '기기 이전을 마치고 이 폰에서 실거래를 다시 엽니다.',
  );

  /// 목적 → 글자(빠짐 0 — 새 목적 = 컴파일 실패).
  static BiometricPrompt of(BiometricPurpose p) => switch (p) {
    BiometricPurpose.pledgeSign => pledgeSign,
    BiometricPurpose.handoverStart => handoverStart,
    BiometricPurpose.livePromotion => livePromotion,
    BiometricPurpose.x1Migration => x1Migration,
  };
}
