// 🆕 계약 v1.4(2026-09-30 · R11 선행 M2 보강 · 01 §14) — 플래너(S7-4) 사유 칩 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    칩의 글자는 `ReasonChip.label`(엔진 문장)이고, 화면은 이 상수를 보고 문구를 고르지 않는다.
// 🔵 까닭: 입금 계획 픽스처(`deposit_plan_*`·`m7_deposit_plan_*`)와 `journal_30`·`advice_12` 가
//    `DEPOSIT_ROUTING` 을 쓰는데 사전에 없었다(미등록 코드 조기 실패의 빈틈 · 설계 D9 ⑦).
// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D4 · 01 §8 미결 74 ✅) — `DEPOSIT_REGISTER` 거부 코드 사전([DepositRegisterRejectCodes]).

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

/// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D4·D13 · 01 §20) — 실입금 등록(`CommandKind.depositRegister`)의 거부 사유.
/// `CommandReceipt.rejectReasonCode` 의 값(`state == rejected` 일 때) · `ContractCodes.byDomain` 키 `deposit_register_reject`.
///
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다 — 화면은 이 코드를 표시·분기하지 않는다(01 §14-7).
/// 🔴 거부는 **계획 바인딩의 거부**이지 입금 사실의 거부가 아니다 — 돈은 계좌에 남고, 새 계획(planId)으로 다시 등록한다.
/// 🔴 원장 무결성 점검 중(`LEDGER_INTEGRITY` 플래그)이면 거부가 아니라 **보류**다(`CommandState.heldForIntegrity` · 사유 코드 없음).
/// 🔴 판정 순서 = [precedence](구조 → 보류 → 대조·정정·만료 → 한도) — `DepositPlan.registerBlockedText` 와 같은 순서라
///    화면 문장과 거부 코드가 엇갈리지 않는다. 만료는 명령의 서버 `requested_at` 으로 잰다(R22 D9).
abstract final class DepositRegisterRejectCodes {
  /// 그런 계획이 없다(저장된 적 없는 planId · 다른 파일(모의/실계좌)의 planId).
  static const String planNotFound = 'DEPOSIT_PLAN_NOT_FOUND';

  /// 이 계획은 이미 등록됐다 — 계획 하나에 등록 하나(`plan_snapshot.consumed_by_decision_id`).
  static const String planAlreadyRegistered = 'DEPOSIT_PLAN_ALREADY_REGISTERED';

  /// 브로커 잔고 대조가 끝나지 않았다(`RECON_MISMATCH` 플래그).
  static const String reconPending = 'DEPOSIT_RECON_PENDING';

  /// 원장 정정이 끝나지 않았다(`LEDGER_FIX` 플래그).
  static const String ledgerFixPending = 'DEPOSIT_LEDGER_FIX_PENDING';

  /// 계획이 만료됐다(명령 `requested_at` ≥ `expiresAt`).
  static const String planExpired = 'DEPOSIT_PLAN_EXPIRED';

  /// 지금 남은 연금 납입 한도 < 계획의 B 몫(해 넘김 포함 · R22 D13) — 세금 사고를 막는다.
  static const String pensionQuotaChanged = 'DEPOSIT_PENSION_QUOTA_CHANGED';

  /// 판정 순서(앞이 먼저 · 보류 `heldForIntegrity` 는 «이미 등록» 다음 · «대조» 앞에 끼인다).
  static const List<String> precedence = <String>[
    planNotFound,
    planAlreadyRegistered,
    reconPending,
    ledgerFixPending,
    planExpired,
    pensionQuotaChanged,
  ];

  /// 전량 6종.
  static const Set<String> values = <String>{
    planNotFound,
    planAlreadyRegistered,
    reconPending,
    ledgerFixPending,
    planExpired,
    pensionQuotaChanged,
  };
}
