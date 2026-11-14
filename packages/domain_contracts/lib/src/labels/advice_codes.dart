// 01 §3-8 X7 명령 거부 사유 18종(🆕 v1.12 +3) · §6-6 `advice_transition.cause_code` 9종
// · `decision_log.reason_code` 특수값 3종 · §3-7 슬리브 A 계절 진입 게이트 사유 3종
// · 🆕 v1.12(01 §21) 재제출 선택지 2종(`AdviceRetryCodes`) · 수량 채우기 필드 1종(`ManualFillPrefillFields`).
//
// 🔴 전부 «어떤 코드가 오는가»의 목록이다. 거부 사유의 문구는 `ActionResult.headline`·
//    `CommandReceipt.stateLabel` 에, 게이트 사유의 문구는 `ReasonChip.label` 에 실려 온다.
// 🔴 **거부는 초안을 지우지 않는다**(C17) — 어떤 거부 코드로 돌아와도 화면은 값을 채운 채
//    사유와 재제출 버튼을 보인다. 초안 삭제는 `CommandReceipt.state == executed` 수신 시에만.

/// X7 명령 거부 사유 코드 18종(01 §3-8 · 🆕 v1.12 +3 — `INPUT_INVALID`·`SELF_REPORT_OUTSIDE_SESSION`·
/// `DEFER_ALREADY_USED`).
///
/// 🔴 **폐기** — `LEDGER_INTEGRITY_BLOCKED`(B18). 무결성 차단 중에도 기록 명령은 거부하지 않고
///    `CommandState.heldForIntegrity` 로 **보관**한다. 이 상수를 되살리지 않는다.
abstract final class AdviceRejectCodes {
  /// 금지 조합(01 §10-2) 진입 시도. 🔴 조건부 칸 #12 는 `handover_session_id` 가 없으면 여기로.
  static const String modeCombinationDenied = 'MODE_COMBINATION_DENIED';

  /// `autoTrade` 에 수기 기록 명령이 도착.
  static const String operatingModeMismatch = 'OPERATING_MODE_MISMATCH';

  /// 🔴 `SKIPPED`·`REVOKED`·`SUPERSEDED` **3종에만** 적용한다 — `EXPIRED` 는 **제외**(A4).
  /// 만료 뒤 도착한 기록은 «지연 이행»이며 받는다.
  static const String adviceNotOpen = 'ADVICE_NOT_OPEN';

  /// 거래일자가 휴장일·미래일·모드 개시 이전. 🔴 판정은 거래소 캘린더를 아는 엔진만.
  static const String fillDateNotTradingDay = 'FILL_DATE_NOT_TRADING_DAY';

  /// 🔴 B4 — 기록의 `tradeDate` 가 [안내 발행 거래일, `validUntilDate`] 창 밖.
  static const String fillDateOutsideAdviceWindow =
      'FILL_DATE_OUTSIDE_ADVICE_WINDOW';

  /// 그날 그 종목의 [저가, 고가] 밖. 🔴 B5 — **완화는 사용자가 고르지 않는다**:
  /// 엔진이 「시간외·단주 신고로 재제출」 옵션을 실을지 판정해 담고 화면은 준 옵션만 그린다.
  static const String priceOutOfRange = 'PRICE_OUT_OF_RANGE';

  /// 슬리브 매핑 밖 종목. 🔴 «시스템 밖 자산 등록» 경로를 함께 제시한다.
  static const String symbolNotMapped = 'SYMBOL_NOT_MAPPED';

  /// 🔴 B11 — 유니버스 종목을 `external_holding` 으로 등록하려는 시도(«2배 노출» 방어).
  static const String symbolInUniverseCannotBeExternal =
      'SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL';

  /// 이미 상쇄·재기재된 행을 다시 정정.
  static const String amendTargetNotActive = 'AMEND_TARGET_NOT_ACTIVE';

  /// 🔴 A13 — `amend` 에 종목·방향 변경이 실림. 그 변경은 `void` + 새 `record` **2명령**이다.
  static const String amendSymbolOrSideChange = 'AMEND_SYMBOL_OR_SIDE_CHANGE';

  /// 🔴 B6 — 정정 체인 길이 상한(엔진 config · 권고 2회) 초과 → `L-3` 실사로 유도.
  static const String amendLimitExceeded = 'AMEND_LIMIT_EXCEEDED';

  /// 안내의 종목과 다른 체결이 그 `advice_id` 로 들어옴.
  static const String adviceFillSymbolMismatch = 'ADVICE_FILL_SYMBOL_MISMATCH';

  /// 🔴 예산 코드 2종(`intentionalPause`·`priceUnacceptable`)에만 — 나머지 사유는 1탭으로 끝난다.
  static const String skipNoteRequired = 'SKIP_NOTE_REQUIRED';

  /// 🔴 B19 — `amend`·`void`·`skip`·`selfReport`(원장 재해석 계열)에만 남는다.
  /// `recordManualFill`(사실 추가)은 거부가 아니라 `pendingLeaseConfirm` 강등 접수다.
  static const String leaseExpired = 'LEASE_EXPIRED';

  /// 🔴 A9 — 24h 내 유사 기록(같은 `advice_id`·거래일·수량·가격).
  /// 재제출은 `duplicateAck = true`.
  static const String duplicateSuspected = 'DUPLICATE_SUSPECTED';

  /// 🆕 v1.12(01 §21 · K4) — 원문 파싱·필수 칸·상한 실패(수량·가격·현금·사유·계좌 · 어느 칸인지는
  /// `CommandReceipt.stateLabel`). 🔴 `CommandApi` 구현이 **큐 적재 없이** 낸 로컬 거부다(그 id 도
  /// `watchCommand` 가 다시 낸다 — 구현 의무 ④ · K42).
  static const String inputInvalid = 'INPUT_INVALID';

  /// 🆕 v1.12(K9 · 01 §4-2 «세션 밖 제출 거부») — 열린 실사 세션이 없다(`SettingsActionId.selfReportSessionStart`
  /// 뒤가 아니다). 🔴 큐 적재 0(로컬 거부 · 구현 의무 ④).
  static const String selfReportOutsideSession = 'SELF_REPORT_OUTSIDE_SESSION';

  /// 🆕 v1.12(K14 ⓐ) — 「내일 다시」를 이미 쓴 안내(G-86 «안내 1건당 1회» · 두 기기·두 번 탭 경합).
  /// 🔴 `ADVICE_NOT_OPEN` 은 `EXPIRED` 를 제외하는 코드라 재사용하지 않는다.
  static const String deferAlreadyUsed = 'DEFER_ALREADY_USED';

  /// 전량 18종.
  static const Set<String> values = <String>{
    modeCombinationDenied,
    operatingModeMismatch,
    adviceNotOpen,
    fillDateNotTradingDay,
    fillDateOutsideAdviceWindow,
    priceOutOfRange,
    symbolNotMapped,
    symbolInUniverseCannotBeExternal,
    amendTargetNotActive,
    amendSymbolOrSideChange,
    amendLimitExceeded,
    adviceFillSymbolMismatch,
    skipNoteRequired,
    leaseExpired,
    duplicateSuspected,
    inputInvalid,
    selfReportOutsideSession,
    deferAlreadyUsed,
  };
}

/// 🆕 v1.12(01 §21 · K20) — 재제출 선택지 코드(`CommandReceipt.retryCode` · X7 기록 명령 전용).
///
/// 🔴 화면은 이 코드로 분기하지 않는다 — `CommandReceipt.retryLabel` 버튼을 누르면 그 `retryCode` 를 제출 DTO
///    `retryCodes` 에 **더할** 뿐이다(누적 · B5 → A9 연쇄 거부 뒤 셋째 제출은 둘 다 싣는다). 와이어
///    `ManualFillRecord.offHourTrade`·`duplicateAck` 로 옮기는 것은 `CommandApi` 구현이다.
abstract final class AdviceRetryCodes {
  /// B5 — `PRICE_OUT_OF_RANGE` 뒤 «시간외·단주 신고로 다시 제출»(엔진이 실을지 판정한다).
  static const String offHourTrade = 'OFF_HOUR_TRADE';

  /// A9 — `DUPLICATE_SUSPECTED` 뒤 «같은 체결이 아닙니다 — 다시 제출».
  static const String duplicateAck = 'DUPLICATE_ACK';

  /// 전량 2종.
  static const Set<String> values = <String>{offHourTrade, duplicateAck};
}

/// 🆕 v1.12(01 §21 · K19) — `ManualFillInput.prefilledFields` 의 값(A1 — `A-3` 의 「채우기」 버튼은 수량 1개뿐 ·
/// 가격·거래일 버튼 없음 · 02 §3-8).
abstract final class ManualFillPrefillFields {
  /// 「안내 수량 채우기」(`AdviceItem.prefillQuantityText` 를 입력칸에 넣었다).
  static const String quantity = 'quantity';

  /// 전량 1종.
  static const Set<String> values = <String>{quantity};
}

/// `advice_transition.cause_code` 9종(01 §6-6 CHECK).
abstract final class AdviceTransitionCauseCodes {
  /// 수기 체결 기록.
  static const String record = 'RECORD';

  /// 미이행 선언.
  static const String skip = 'SKIP';

  /// 유효기한 경과(엔진 스윕).
  static const String lapse = 'LAPSE';

  /// 새 안내가 자리를 대체.
  static const String supersede = 'SUPERSEDE';

  /// 회수(킬스위치·차단·억제).
  static const String revoke = 'REVOKE';

  /// 기록 정정.
  static const String amend = 'AMEND';

  /// 🔴 A4 — 만료 뒤 기록. **상태를 바꾸지 않고** `EXPIRED → EXPIRED` 1행으로 사실만 남긴다.
  static const String lateFill = 'LATE_FILL';

  /// 🔴 G-20 — 집행 주체 전환 커밋이 살아 있는 안내를 **회수**한 사실.
  /// 사람의 미이행이 아니므로 **예산 미차감·이행률 분모 제외**다.
  static const String handoverClose = 'HANDOVER_CLOSE';

  /// 🔴 G-86 — 만료 확인 카드를 하루 미룬 사실. 상태는 바꾸지 않고
  /// (`EXPIRED → EXPIRED`) **행의 존재 자체가 «이미 한 번 미뤘다»의 정본**이다.
  static const String deferConfirm = 'DEFER_CONFIRM';

  /// 전량 9종.
  static const Set<String> values = <String>{
    record,
    skip,
    lapse,
    supersede,
    revoke,
    amend,
    lateFill,
    handoverClose,
    deferConfirm,
  };
}

/// `decision_log.reason_code` 의 특수값 3종(인벤토리 §6-12) + 🆕 v1.10 ㊲ 원장 사건 5종 + 🆕 v1.11 실입금 등록 1종.
///
/// 🔴 `decision_log.kind='MANUAL'` 인 **세 갈래**(정정 · `external_holding` 등록 · 경로 b 귀속)는
///    재량 예산·이탈 집계의 **모집단이 아니다**(C7).
abstract final class DecisionReasonCodes {
  /// G-04 — 실전 개시 원장(`kind='MANUAL'` 1행 공유).
  static const String openingBalance = 'OPENING_BALANCE';

  /// N-2 — 모의 개시 원장.
  static const String simOpeningBalance = 'SIM_OPENING_BALANCE';

  /// G-20 — `advice.close_reason_code` 에 실리는 전환 커밋 회수 사유.
  static const String handoverClosed = 'HANDOVER_CLOSED';

  /// 🆕 v1.10 ㊲ — 인출(`decision_log.kind='WITHDRAWAL'`).
  static const String ledgerEventWithdrawal = 'LEDGER_EVENT_WITHDRAWAL';

  /// 🆕 v1.10 ㊲ — 분배금(`kind='MANUAL'` — 재량 예산·이탈 모집단 아님).
  static const String ledgerEventDistribution = 'LEDGER_EVENT_DISTRIBUTION';

  /// 🆕 v1.10 ㊲ — 원천징수(`kind='MANUAL'`).
  static const String ledgerEventTaxWithheld = 'LEDGER_EVENT_TAX_WITHHELD';

  /// 🆕 v1.10 ㊲ — 분할·병합(`kind='MANUAL'`).
  static const String ledgerEventCorporateAction =
      'LEDGER_EVENT_CORPORATE_ACTION';

  /// 🆕 v1.10 ㊲ — 원장 사건의 무효(상쇄만 · `kind='MANUAL'`).
  static const String ledgerEventVoid = 'LEDGER_EVENT_VOID';

  /// 🆕 v1.11(E7b0 · 설계 13 §8 R22 D5) — 실입금 등록(`decision_log.kind='DEPOSIT'` · 계획 바인딩과 한 트랜잭션).
  /// 칩 코드 `DEPOSIT_ROUTING`(플래너 사전)과 다른 도메인이다 — 결정 사유는 이 사전만 쓴다.
  static const String depositRegistered = 'DEPOSIT_REGISTERED';

  /// 🆕 v1.19(01 §28 · K21 · 엔진 E15e2 #161 `kLivePromotionReasonCode`) — 첫 실전 주문 승격
  /// (`decision_log.kind='MANUAL'` · 전략 `P0S` · `OPENING_BALANCE`·`SIM_OPENING_BALANCE` 와 같은 축).
  static const String livePromotion = 'LIVE_EXECUTE_PROMOTION';

  /// 전량 10종.
  static const Set<String> values = <String>{
    openingBalance,
    simOpeningBalance,
    handoverClosed,
    ledgerEventWithdrawal,
    ledgerEventDistribution,
    ledgerEventTaxWithheld,
    ledgerEventCorporateAction,
    ledgerEventVoid,
    depositRegistered,
    livePromotion,
  };
}

/// 슬리브 A 계절 진입 게이트 사유 코드 3종(01 §3-7).
///
/// 🔴 **상태 5값 ↔ 코드 3종의 비대칭을 화면이 분기로 메우지 않는다** —
///    `octPassed`→[entryOk] · `deferredToNov`·`deferredToDec`→[entryDefer] ·
///    `enteredInNov`·`forcedEntryDec`→[entryLate]. 화면은 상태값으로 색·배지만 고르고
///    문구는 전부 `ReasonChip.label` 을 쓴다.
/// 🔴 임계값·보류 상한(`seasonality.f1_entry_gate_score`·`f1_entry_defer_max`)을
///    **상수로 적지 않는다** — 값이 화면에 박히면 조문과 화면이 각자 정본이 된다.
/// 🔴 **보류에 안내를 만들지 않는다**(G-25) — 매달 오는 «안 함»의 통보는 경보 피로다.
abstract final class SeasonalEntryGateCodes {
  /// ⏸ 정상 통과. ⚠️ **엔진 코드명 M2-3 확정 대기**(M2-8 A-9) —
  /// 03_알고리즘에 통과 케이스용 이벤트 이름이 아직 없다.
  /// 🔴 등재 전에는 픽스처 봉투의 `ENTRY_GATE_OCT` 를 **고치지 않는다**
  ///    (정상 통과가 «보류·지연»으로 오표기되는 것을 막는다).
  static const String entryOk = 'F1_ENTRY_OK';

  /// 임계 미만(또는 결측 = fail-closed) → 이번 달 보류.
  static const String entryDefer = 'F1_ENTRY_DEFER';

  /// 보류 뒤 실제 진입(11월말 재판정 통과 / 12월말 강제).
  static const String entryLate = 'F1_ENTRY_LATE';

  /// 전량 3종.
  static const Set<String> values = <String>{entryOk, entryDefer, entryLate};

  /// ⏸ 코드명 확정 전까지 픽스처 봉투가 «통과»에 쓰는 값(01 §3-7 · §5 봉투 예시).
  ///
  /// 🔴 [entryOk] 로 갈아치우지 않는다 — M2-3 등재가 끝난 창에서만 옮긴다.
  static const String fixtureEntryGatePass = 'ENTRY_GATE_OCT';
}
