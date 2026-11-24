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
/// `runtimeLivePromotion` 결과 `ActionResult.reasonCode`.
/// 🆕 v1.39(01 §48 · K346) 사전 판정 차례 = 생체 → 세션 → 관찰 중 → 자동 매매 → 시각 → **리스 → 설정 → 재판정**
/// (core `livePromotionReject` · 리스 = E15f5 R108 · 설정 = 리뷰 3차 H2-02 · 13 §8 R265 — 설정을 못 읽으면 잡이 실패해 무결일이 0 이라
/// «일수 부족»이 진짜 사유를 가린다 → 재판정보다 먼저).
/// 🔴 생체 없음 = `SettingsResultCodes.biometricUnavailable` · 리스 무효 = `JournalReasonCodes.leaseInvalid`(`LEASE_INVALID` · core
///    `kLeaseInvalidCode`) — 둘 다 한 벌(이 사전에 다시 싣지 않는다) · 재판정 막힘 = [LiveObservationBlockCodes].
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

  /// 🆕 v1.39(01 §48 · K346 · 13 §8 R265 S3) — 실전 파일의 지금 설정(실전 개시 판)을 못 읽었다(빈 지문으로 실주문을 켜지 않는다 ·
  /// 쓰기 0 · 다시 시도 0 · 화면 = headline 그대로).
  static const String configUnavailable = 'LIVE_PROMOTION_CONFIG_UNAVAILABLE';

  static const Set<String> values = <String>{
    sessionInvalid,
    notObserving,
    notAutoTrade,
    clockBehind,
    rolledBack,
    configUnavailable,
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

// 🆕 v1.22(01 §31 · K21 · K51 · K58 · K67) — simToAuto 판정·확정·세션·단계 · 모드 표지(엔진 E15 실물 글자 그대로 ·
// origin/main 4f85259 · 엔진 로컬 상수 → 이 사전 참조 = 엔진 다음 조각).

/// 🆕 v1.22 — simToAuto 판정·막힘(도메인 `sim_to_auto_result` · core `SimToAutoCodes` · `mode/sim_to_auto.dart:92-123` 10).
/// 축 = `HandoverStep.blockedReasonCode`(simToAuto) · `ActionResult.reasonCode`(위저드 동작).
abstract final class SimToAutoResultCodes {
  /// 모의 자동 매매가 아니다(모의 파일 현재 행 · 닫힘 · 운영 방식).
  static const String notSimAuto = 'SIM_TO_AUTO_NOT_SIM_AUTO';

  /// 킬스위치 · 주문 차단 플래그.
  static const String safetyBlock = 'SIM_TO_AUTO_SAFETY_BLOCK';

  /// 체험 미완.
  static const String trialIncomplete = 'SIM_TO_AUTO_TRIAL_INCOMPLETE';

  /// 골든 벡터 실패.
  static const String goldenVectorFailed = 'SIM_TO_AUTO_GOLDEN_VECTOR_FAILED';

  /// 실전 키 검증 실패.
  static const String liveKeysFailed = 'SIM_TO_AUTO_LIVE_KEYS_FAILED';

  /// 계좌 없는 전략.
  static const String accountUnmapped = 'SIM_TO_AUTO_ACCOUNT_UNMAPPED';

  /// 냉각 중.
  static const String cooling = 'SIM_TO_AUTO_COOLING';

  /// 확정 기한 지남(세션 만료).
  static const String sessionExpired = 'SIM_TO_AUTO_SESSION_EXPIRED';

  /// 신뢰 시각 없음 — 🔴 공용 `TRUSTED_TIME_UNKNOWN` 과 다른 글자(엔진 이력 · K12).
  static const String trustedTimeUnavailable =
      'SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE';

  /// 다음 정기 집행 전에 관찰을 채울 수 없다(🔴 상수 이름 ≠ 엔진 `commitWindow` — C-7 `_writeVerb` · K51).
  static const String windowBlocked = 'SIM_TO_AUTO_COMMIT_WINDOW';

  static const Set<String> values = <String>{
    notSimAuto,
    safetyBlock,
    trialIncomplete,
    goldenVectorFailed,
    liveKeysFailed,
    accountUnmapped,
    cooling,
    sessionExpired,
    trustedTimeUnavailable,
    windowBlocked,
  };
}

/// 🆕 v1.22(K58) — simToAuto 확정 1단계 · 오케스트레이터 결과(도메인 `sim_to_auto_commit_result` ·
/// core `SimToAutoCommitCodes`(`mode/sim_to_auto_commit.dart`) 전부 + `mode/sim_to_auto_switch.dart` 2).
/// 🆕 v1.39(01 §48 · K346) 엔진 안 예약 3 등재 — [fateConfigUnavailable](13 R265 S4) · [configNotApproved](13 R192 AA4) ·
/// [accountDuplicate](13 R262 D3) · 🔴 엔진 `SimToAutoCommitCodes` ⊆ 이 사전(C-72 ⑧ 원천 대조 — 리뷰 3차 I-2).
/// 판정 차례(core `simToAutoCommitReject` · 13 R192 · R262) = 신뢰 시각 → 세션 → 리스 → 이미 커밋 → **승인 config** → 재판정(냉각) →
/// 계좌 조회 없음 → **별칭 중복** → 신선도 → 보유 → 활동 → 예수금(모름 · 0원).
abstract final class SimToAutoCommitResultCodes {
  /// 실전 파일에 이미 모드 행이 있다.
  static const String alreadyCommitted = 'SIM_TO_AUTO_ALREADY_COMMITTED';

  /// 대응 계좌 가운데 조회가 없는 곳이 있다.
  static const String probeMissing = 'SIM_TO_AUTO_ACCOUNT_PROBE_MISSING';

  /// 조회가 오래됐거나 미래 시각이다.
  static const String snapshotStale = 'SIM_TO_AUTO_SNAPSHOT_STALE';

  /// 실전 계좌에 보유 종목이 있다.
  static const String holdingsNotZero = 'SIM_TO_AUTO_HOLDINGS_NOT_ZERO';

  /// 오늘 브로커 주문 · 체결이 있다.
  static const String brokerActivityToday = 'SIM_TO_AUTO_BROKER_ACTIVITY_TODAY';

  /// 예수금을 알 수 없다.
  static const String cashUnknown = 'SIM_TO_AUTO_CASH_UNKNOWN';

  /// 예수금 합계가 없다.
  static const String zeroCash = 'SIM_TO_AUTO_ZERO_CASH';

  /// 쓰기 실패 — 전부 되돌리고 세션을 닫았다.
  static const String rolledBack = 'SIM_TO_AUTO_COMMIT_ROLLED_BACK';

  /// 세션을 연 기기 · 리스 세대가 지금과 다르다.
  static const String leaseMismatch = 'SIM_TO_AUTO_LEASE_MISMATCH';

  /// 닫힌 모의 파일에는 5단계 고름을 적지 않는다.
  static const String simClosed = 'SIM_LEDGER_FATE_SIM_CLOSED';

  /// 오케스트레이터 — 새 감시 체크 준비 실패(전환하지 않았다).
  static const String watchdogPrepareFailed =
      'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED';

  /// 오케스트레이터 — 커밋 콜백 결과 모름(보상 0 · 🔴 상수 이름 ≠ 엔진 `kSimToAutoCommitUnknown` — C-7 · K51).
  static const String outcomeUnknown = 'SIM_TO_AUTO_COMMIT_UNKNOWN';

  /// 🆕 v1.39(13 R265 S4 · 리뷰 3차 H2-02) — 모의 파일의 지금 설정(모의 개시 판)을 못 읽어 5단계 고름을 적지 않았다(쓰기 0 · 빈 지문 결정 0) ·
  /// 축 = `handoverSimLedgerFate` 결과(S5 · [simClosed] 와 같은 자리).
  static const String fateConfigUnavailable =
      'SIM_LEDGER_FATE_CONFIG_UNAVAILABLE';

  /// 🆕 v1.39(13 R192 AA4 · 미결 205 ⓓ) — 지금 설정(실전 개시에 붙일 판)이 규칙 변경 승인을 받지 않았다(승인 config 0 · 승인 기록 없음 ·
  /// 다른 판 승인) — 쓰기 0 · 세션 그대로(SAF-405 · 실전 기동 = 승인 config 필수).
  static const String configNotApproved = 'SIM_TO_AUTO_CONFIG_NOT_APPROVED';

  /// 🆕 v1.39(13 R262 D3 · 리뷰 3차 A-2) — 서로 다른 별칭이 같은 실전 계좌(종합계좌 · 상품코드)를 가리킨다 — 쓰기 0 · 세션 그대로
  /// (한 계좌 예수금을 두 번 개시 현금으로 적지 않는다).
  static const String accountDuplicate = 'SIM_TO_AUTO_ACCOUNT_DUPLICATE';

  static const Set<String> values = <String>{
    alreadyCommitted,
    probeMissing,
    snapshotStale,
    holdingsNotZero,
    brokerActivityToday,
    cashUnknown,
    zeroCash,
    rolledBack,
    leaseMismatch,
    simClosed,
    watchdogPrepareFailed,
    outcomeUnknown,
    fateConfigUnavailable,
    configNotApproved,
    accountDuplicate,
  };
}

/// 🆕 v1.39(01 §48 · K347 · 13 §8 R261 H5 · 리뷰 3차 H1-2) — 닫힌 원장 쓰기 거부(도메인 `ledger_write_gate`).
/// 축 = `CommandReceipt.rejectReasonCode`(모든 명령 종류) · `ActionResult.reasonCode` · `SafetyActionResult.reasonCode`(원장에 쓰는 동작).
/// 🔴 뜻 = 화면 상태가 가리키는 원장이 닫혔다(simToAuto 커밋으로 CLOSE 된 모의 원장 · 커밋 ~ 깨어남 끝 몇 초 틈) → 쓰기 0 · 접수증 = rejected ·
///    다시 누르면 깨어남 뒤 새 원장에 적힌다(`retryable` true · 글자 = 엔진 headline · `stateLabel`).
/// 🔴 `runMode` 불일치 거부(01 §5-3 · 파일 경계)와 다른 축 — 같은 모드라도 원장 행이 CLOSE 면 이 글자.
abstract final class LedgerWriteGateCodes {
  /// 닫힌(CLOSE) 원장에는 쓰지 않는다.
  static const String ledgerClosed = 'LEDGER_CLOSED';

  static const Set<String> values = <String>{ledgerClosed};
}

/// 🆕 v1.22(K21) — 전환 세션 결과(도메인 `handover_session_result` · core `HandoverSessionCodes` `mode/handover_session.dart:75-88`
/// − `INVALID`(v1.19 `LivePromotionResultCodes.sessionInvalid` 한 벌 — simToAuto 도 그 글자) − 생체(`SettingsResultCodes`)).
abstract final class HandoverSessionResultCodes {
  /// 이미 열린 세션이 있다.
  static const String sessionOpen = 'HANDOVER_SESSION_OPEN';

  /// 저장 실패 — 전부 되돌렸다.
  static const String rolledBack = 'HANDOVER_SESSION_ROLLED_BACK';

  static const Set<String> values = <String>{sessionOpen, rolledBack};
}

/// 🆕 v1.22 — simToAuto 7단계 id(도메인 `sim_to_auto_step` · core `SimToAutoStep.stepId` `mode/sim_to_auto.dart:53-77` ·
/// 축 = `HandoverStep.stepId`(simToAuto) · 막힘 코드 없는 첫 열린 단계의 거부 `reasonCode` · `UnknownResolutionStep.stepId` 선례).
/// 🔴 [cooling] ↔ `SimToAutoResultCodes.cooling` = 다른 클래스 · 다른 글자(`SIM_TO_AUTO_S7` ↔ `SIM_TO_AUTO_COOLING`).
abstract final class SimToAutoStepIds {
  /// 1 모의 체험 확인.
  static const String trial = 'SIM_TO_AUTO_S1';

  /// 2 골든 벡터 자가검사.
  static const String goldenVector = 'SIM_TO_AUTO_S2';

  /// 3 실전 키 등록 · 조회 검증.
  static const String liveKeys = 'SIM_TO_AUTO_S3';

  /// 4 계좌 연결.
  static const String accounts = 'SIM_TO_AUTO_S4';

  /// 5 모의 기록 보관 · 지움.
  static const String simLedger = 'SIM_TO_AUTO_S5';

  /// 6 생체 확인.
  static const String biometric = 'SIM_TO_AUTO_S6';

  /// 7 냉각.
  static const String cooling = 'SIM_TO_AUTO_S7';

  /// 차례 = 단계 차례(C-56 ④).
  static const List<String> ordered = <String>[
    trial,
    goldenVector,
    liveKeys,
    accounts,
    simLedger,
    biometric,
    cooling,
  ];

  static const Set<String> values = <String>{
    trial,
    goldenVector,
    liveKeys,
    accounts,
    simLedger,
    biometric,
    cooling,
  };
}
