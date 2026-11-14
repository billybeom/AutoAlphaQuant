// 01 §3 · 🆕 계약 v1.19(01 §28 · K15 · K21) — X6 모의투자·관찰·기동 판정 코드 사전(엔진 E15 실물 글자 그대로).
//
// 🔴 «어떤 코드가 오는가» 의 상수 목록이지 코드 → 문구 매핑이 아니다 — 문구는 엔진이 함께 싣는다
//    (`SimTrialCheck.label`·`stateLabel` · `ActionResult.headline`). 화면은 코드로 분기·아이콘·색을 고르지 않는다.
// 🔴 출처(origin/main 175cbd5) — core_engine `sim/sim_trial.dart` `SimTrialItem`·`SimTrialItemState` ·
//    `mode/live_observation.dart` `LiveObservationBlock` · `mode/mode_guard.dart` `kCredentialEnvMismatch` ·
//    `safety/rule_change.dart` `kSaf405` · `sim/sim_opening.dart` `SimOpeningCodes` · `mode/live_promotion.dart`
//    `LivePromotionCodes`(E15e2 #161). 엔진 로컬 상수 → 이 사전 참조 = 엔진 다음 조각(01 §8 미결 177).

/// `SimTrialCheck.itemCode` — 자동 매매 갈래 체험 5항목(도메인 `sim_trial_item` · 차례 = 04 §9-5 = 엔진 `SimTrialItem`).
abstract final class SimTrialItemCodes {
  /// ① 연속 2거래주 정상 배치.
  static const String twoTradingWeeks = 'SIM_TRIAL_TWO_TRADING_WEEKS';

  /// ② 월말 정기 리밸런싱 1회(🔴 소프트 — 미경험 = 경고 후 진행 허용).
  static const String monthEndRebalance = 'SIM_TRIAL_MONTH_END_REBALANCE';

  /// ③ 대사 0오차(simBroker 만 · simInternal = 자동 통과).
  static const String reconciliation = 'SIM_TRIAL_RECONCILIATION';

  /// ④ X2 재개 1회 시연.
  static const String resume = 'SIM_TRIAL_RESUME';

  /// ⑤ 킬스위치 발동·재개 1회 연습.
  static const String killSwitch = 'SIM_TRIAL_KILL_SWITCH';

  static const Set<String> values = <String>{
    twoTradingWeeks,
    monthEndRebalance,
    reconciliation,
    resume,
    killSwitch,
  };
}

/// `SimTrialCheck.itemState` — 항목 상태(도메인 `sim_trial_state` · 엔진 `SimTrialItemState.wire`).
/// 🔴 `GateState` 가 아니다(K9) — 색 = `SimTrialCheck.level`(짝 = 01 §28 K9).
abstract final class SimTrialItemStateCodes {
  /// 채웠다.
  static const String passed = 'PASSED';

  /// 해당 없음 — 자동 통과(③ simInternal).
  static const String autoPassed = 'AUTO_PASSED';

  /// 아직(단단한 문).
  static const String open = 'OPEN';

  /// 아직 — 경고 후 진행 허용(② 소프트).
  static const String openWarn = 'OPEN_WARN';

  static const Set<String> values = <String>{
    passed,
    autoPassed,
    open,
    openWarn,
  };
}

/// 실전 관찰 판정이 승격을 막는 사유(도메인 `live_observation_block` · 차례 = 판정 차례 · 엔진 `LiveObservationBlock.code`) —
/// `runtimeLivePromotion` 결과 `ActionResult.reasonCode`(13 R91 AD4 재판정).
abstract final class LiveObservationBlockCodes {
  /// 킬스위치 켜짐.
  static const String killSwitch = 'LIVE_OBSERVATION_KILL_SWITCH';

  /// 주문 차단 플래그.
  static const String tradingBlock = 'LIVE_OBSERVATION_TRADING_BLOCK';

  /// 확인 안 된 주문.
  static const String unknownOrders = 'LIVE_OBSERVATION_UNKNOWN_ORDERS';

  /// 연속 무결 거래일 모자람.
  static const String notEnoughDays = 'LIVE_OBSERVATION_NOT_ENOUGH_DAYS';

  static const Set<String> values = <String>{
    killSwitch,
    tradingBlock,
    unknownOrders,
    notEnoughDays,
  };
}

/// 🆕 E15e2(#161) — 승격 커밋 거부·결과(도메인 `live_promotion_result` · 엔진 `LivePromotionCodes` 글자 그대로) —
/// `runtimeLivePromotion` 결과 `ActionResult.reasonCode`(사전 판정 차례 = 생체 → 세션 → 관찰 중 → 자동 매매 → 시각 → 재판정).
/// 🔴 생체 없음 = `SettingsResultCodes.biometricUnavailable`(한 벌 — 이 사전에 다시 싣지 않는다) · 재판정 막힘 = [LiveObservationBlockCodes].
abstract final class LivePromotionResultCodes {
  /// 준 세션이 없거나 닫혔거나 만료.
  static const String sessionInvalid = 'HANDOVER_SESSION_INVALID';

  /// 현재 행이 실전 관찰(live × dryRun)이 아니다.
  static const String notObserving = 'LIVE_PROMOTION_NOT_OBSERVING';

  /// 운영 방식이 자동 매매가 아니다(모름 포함).
  static const String notAutoTrade = 'LIVE_PROMOTION_NOT_AUTO_TRADE';

  /// 지금이 현재 행 커밋 시각보다 늦지 않다.
  static const String clockBehind = 'LIVE_PROMOTION_CLOCK_BEHIND';

  /// 저장 실패 — 전부 되돌렸다.
  static const String rolledBack = 'LIVE_PROMOTION_ROLLED_BACK';

  static const Set<String> values = <String>{
    sessionInvalid,
    notObserving,
    notAutoTrade,
    clockBehind,
    rolledBack,
  };
}

/// 엔진 기동 판정이 시작을 거부한 사유(도메인 `mode_startup` · 차례 = SAF-405 → 조합 → 자격증명 환경) —
/// `runtimeEngineStart` 결과 `ActionResult.reasonCode`.
/// 🔴 조합 금지 = `AdviceRejectCodes.modeCombinationDenied`(01 §10-2 · 같은 글자 한 벌 — 이 사전에 다시 싣지 않는다).
/// 🔴 hold(`SafetyHoldCodes` · 기동은 하되 배치를 멈춤)와 다르다.
abstract final class ModeStartupCodes {
  /// 승인되지 않은 규칙·설정 변경이 있다(엔진 `kSaf405`).
  static const String saf405 = 'SAF-405';

  /// 금고 자격증명의 환경 ≠ 실행 모드가 기대하는 환경(엔진 `kCredentialEnvMismatch`).
  static const String credentialEnvMismatch = 'CREDENTIAL_ENV_MISMATCH';

  static const Set<String> values = <String>{saf405, credentialEnvMismatch};
}

/// 모의 개시·온보딩 커밋 거부(도메인 `sim_opening_result` · 엔진 `SimOpeningCodes`) — `onboardingDryRunStart` 결과
/// `ActionResult.reasonCode` · `submitSelfReportBalance(purpose: simOpening)` 의 `CommandReceipt.rejectReasonCode`(M5-14).
abstract final class SimOpeningResultCodes {
  /// 금액이 0 이하.
  static const String notPositive = 'SIM_OPENING_NOT_POSITIVE';

  /// 금액에 원 미만 자리가 있다.
  static const String notWholeWon = 'SIM_OPENING_NOT_WHOLE_WON';

  /// 비중이 있는 전략의 계좌가 설정에 없다.
  static const String accountUnmapped = 'SIM_OPENING_ACCOUNT_UNMAPPED';

  /// 자동 매매 개시에 보유 줄이 왔다(금액 1칸만 받는다).
  static const String linesNotAllowed = 'SIM_OPENING_LINES_NOT_ALLOWED';

  /// 정기 실사 등 다른 목적의 제출.
  static const String wrongPurpose = 'SIM_OPENING_WRONG_PURPOSE';

  /// 이미 선언했다(append-only).
  static const String alreadyDeclared = 'SIM_OPENING_ALREADY_DECLARED';

  /// 커밋 전에 가상 초기금 선언이 없다.
  static const String notDeclared = 'SIM_OPENING_NOT_DECLARED';

  /// 운영 방식 선택(O-00b)이 없다.
  static const String choiceMissing = 'ONBOARDING_CHOICE_MISSING';

  /// 투자 안내 갈래의 모의 개시(보유 선언 · L-3 폼) = E18.
  static const String advisoryNotReady = 'SIM_OPENING_ADVISORY_NOT_READY';

  /// 계층 B 카드 미등록 — 체험 시작 금지.
  static const String tierBCardMissing = 'TIER_B_CARD_MISSING';

  static const Set<String> values = <String>{
    notPositive,
    notWholeWon,
    accountUnmapped,
    linesNotAllowed,
    wrongPurpose,
    alreadyDeclared,
    notDeclared,
    choiceMissing,
    advisoryNotReady,
    tierBCardMissing,
  };
}
