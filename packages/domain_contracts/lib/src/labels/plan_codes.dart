// 🆕 계약 v1.4(2026-09-30 · R11 선행 M2 보강 · 01 §14) — 플래너(S7-4) 사유 칩 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    칩의 글자는 `ReasonChip.label`(엔진 문장)이고, 화면은 이 상수를 보고 문구를 고르지 않는다.
// 🔵 까닭: 입금 계획 픽스처(`deposit_plan_*`·`m7_deposit_plan_*`)와 `journal_30`·`advice_12` 가
//    `DEPOSIT_ROUTING` 을 쓰는데 사전에 없었다(미등록 코드 조기 실패의 빈틈 · 설계 D9 ⑦).
// ⏸ `DEPOSIT_REGISTER` 거부 코드 사전은 여기 없다(01 §8 미결 74).

/// 플래너 주문 초안의 사유 칩 코드(`OrderDraft.reasons[].code` · 01 §2-6).
///
/// ⚠️ 플래너 초안 칩에는 `PENSION_FUNDING`(원장 이벤트 사전 · `ledger_event_codes.dart`)도 온다
///    (`m7_deposit_plan_funding` 매도 초안 · C-38 ⑧ 은 그래서 전 도메인 isRegistered 로 본다).
///    이 사전은 플래너 **전용** 코드만 싣는다.
///
/// 🔴 목록은 M2 가 늘린다.
abstract final class PlannerReasonCodes {
  /// 월 납입 배분(입금액을 슬리브·계좌로 나눈 결과의 초안).
  static const String depositRouting = 'DEPOSIT_ROUTING';

  /// 플래너 전용 코드 전량 1종(`PENSION_FUNDING` 은 원장 이벤트 사전 몫).
  static const Set<String> values = <String>{depositRouting};
}

/// 🆕 E7a3-2(2026-10-21 · 설계 13 §8 R18 D-11 · 계약 버전 불변 — 코드 사전 추가만) — 리밸런싱 미리보기
/// 초안의 사유 칩 코드(`RebalancePreview.orderDrafts[].reasons[].code` · 01 §15-4).
///
/// 🔵 까닭: 픽스처 `m7_rebalance_preview_default` 가 `REBALANCE_BAND` 를 쓰는데 사전에 없었다 · 엔진 월말 계획기
///    (`core_engine` `planMonthEnd`)의 매매 갈래마다 하나씩 둔다. 원화 조달 매도는 `PENSION_FUNDING`(원장 이벤트 사전).
/// 🔴 목록은 M2 가 늘린다.
abstract final class RebalanceReasonCodes {
  /// 코어 밴드 — B 지분 목표 ± band 이탈(재원 매도 포함).
  static const String rebalanceBand = 'REBALANCE_BAND';

  /// 슬리브 B 3-트랜치 신호(하한 · BEAR 차감 포함).
  static const String sleeveBSignal = 'SLEEVE_B_SIGNAL';

  /// 슬리브 C 채권 · 금 비중 조정.
  static const String sleeveCRebalance = 'SLEEVE_C_REBALANCE';

  /// POT 서브북 3-트랜치 신호.
  static const String potSignal = 'POT_SIGNAL';

  /// 전량 4종.
  static const Set<String> values = <String>{
    rebalanceBand,
    sleeveBSignal,
    sleeveCRebalance,
    potSignal,
  };
}
