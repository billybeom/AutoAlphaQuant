// 🆕 계약 v1.39(01 §48 · K350 · 01 §8 미결 238 · 리뷰 3차 A-3) — OS 생체 대화상자의 목적(무엇에 동의하는가).
//
// 🔴 생체 대화상자 하나(`biometricSign`)를 네 동작이 같이 쓰면서 모두 «서약에 생체로 서명»을 띄웠다 — 실전 집행 승격(실주문을 켜는
//    동작)에서도 «방금 쓴 서약 세 문장을 확인합니다»라고 알렸다. 목적을 인자로 받고 글자는 [BiometricPurpose] 마다 하나다
//    (`BiometricPromptText` · 플랫폼(Kotlin)은 문장을 짓지 않는다).
// 🔴 게이트 판정(생체 확인 결과 · 실패 = `BIOMETRIC_UNAVAILABLE`)은 목적과 무관하다 — 목적은 대화상자 글자만 고른다.
// 🔵 조립 배선(`biometricSign(purpose)` · 호출 넷) = 다음 카드(미결 238 남은 몫) — 그 전 = 늘 [pledgeSign] 글자(지금 그대로).
import 'package:freezed_annotation/freezed_annotation.dart';

/// 생체 대화상자 목적(차례 = 사람이 처음 만나는 차례).
enum BiometricPurpose {
  /// `O-04` ③ 서약에 생체로 서명(온보딩 · 지금 글자 그대로).
  @JsonValue('PLEDGE_SIGN')
  pledgeSign('PLEDGE_SIGN'),

  /// `M5-11` 6단계 — 실전 전환 시작(simToAuto 세션 열기 · 확정 = 냉각 뒤 · 실주문 0 = 관찰부터).
  @JsonValue('HANDOVER_START')
  handoverStart('HANDOVER_START'),

  /// `S05` 실전 집행 승격(관찰 → 실주문을 켠다 · 01 §10-2 G-43).
  @JsonValue('LIVE_PROMOTION')
  livePromotion('LIVE_PROMOTION'),

  /// X1 기기 이전 — 새 폰에서 실거래를 다시 연다(복구 마지막 단계 `biometricConfirmed`).
  @JsonValue('X1_MIGRATION')
  x1Migration('X1_MIGRATION');

  const BiometricPurpose(this.wire);

  /// 채널 · 로그 표기(대화상자 글자 아님).
  final String wire;
}
