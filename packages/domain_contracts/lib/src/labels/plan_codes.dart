// 🆕 계약 v1.4(2026-09-30 · R11 선행 M2 보강 · 01 §14) — 플래너(S7-4) 사유 칩 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    칩의 글자는 `ReasonChip.label`(엔진 문장)이고, 화면은 이 상수를 보고 문구를 고르지 않는다.
// 🔵 까닭: 입금 계획 픽스처(`deposit_plan_*`·`m7_deposit_plan_*`)와 `journal_30`·`advice_12` 가
//    `DEPOSIT_ROUTING` 을 쓰는데 사전에 없었다(미등록 코드 조기 실패의 빈틈 · 설계 D9 ⑦).
// ⏸ `DEPOSIT_REGISTER` 거부 코드 사전은 여기 없다(01 §8 미결 74).

/// 플래너 주문 초안의 사유 칩 코드(`OrderDraft.reasons[].code` · 01 §2-6).
///
/// 🔴 목록은 M2 가 늘린다.
abstract final class PlannerReasonCodes {
  /// 월 납입 배분(입금액을 슬리브·계좌로 나눈 결과의 초안).
  static const String depositRouting = 'DEPOSIT_ROUTING';

  /// 전량 1종.
  static const Set<String> values = <String>{depositRouting};
}
