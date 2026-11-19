// 🆕 계약 v1.21(01 §30 · K12 · K13 · K45) — M5 안전 동작 결과 코드 · 게이지 코드. 엔진 글자 1:1(core·ds 실물 · 01 §30-8).
//
// 🔴 «어떤 코드가 오는가» 의 목록이지 코드 → 문구 사전이 아니다(labels.dart 머리) — 화면은 `headline`·`stateLabel`
//    원문을 그린다. 코드로 분기·아이콘·색을 고르지 않는다.
// 🔴 공용 두 글자(`TRUSTED_TIME_UNKNOWN` · `JOURNAL_ID_TAKEN`)는 [SafetyCommonResultCodes] 한 벌이다 — 도메인 사전
//    (킬스위치 · 서약 · 1.22.0 개입 · 규칙 변경 · 재량 · STOPPED)에 다시 적지 않는다(C-5 «같은 글자 두 사전 0»).

/// 킬스위치 발동 기록·재개 거부(도메인 `kill_switch_result` · 엔진 core `kill_checklist.dart` 리터럴 12 — 상수 클래스 0 →
/// 엔진이 이 사전을 참조로 바꾼다). 축 = `SafetyActionResult.reasonCode`(재개) · `CommandReceipt.rejectReasonCode`(발동 기록).
abstract final class KillSwitchResultCodes {
  /// 확인 3 중 빈 것(발동 기록).
  static const String ackIncomplete = 'KILL_ACK_INCOMPLETE';

  /// «잔여 0» 인데 엔진이 본 미체결 > 0 — 🔴 P0 를 다시 올린다(발동 기록).
  static const String ackMismatch = 'KILL_ACK_MISMATCH';

  /// 카드 ④ 7 중 빈 것(1 · 2 감정 · 3 · 4 · 7 · 발동 기록 · `activation` null 포함).
  static const String checklistItemMissing = 'KILL_CHECKLIST_ITEM_MISSING';

  /// 꺼져 있다(발동 기록 · 재개).
  static const String notActive = 'KILL_SWITCH_NOT_ACTIVE';

  /// 7문항을 이미 마쳤다.
  static const String resumeChecklistDone = 'RESUME_CHECKLIST_DONE';

  /// 7문항 미완(해제 시도).
  static const String resumeChecklistIncomplete = 'RESUME_CHECKLIST_INCOMPLETE';

  /// 발동 뒤 기록 확인 전(카운트다운 없음).
  static const String resumeChecklistNotConfirmed =
      'RESUME_CHECKLIST_NOT_CONFIRMED';

  /// 4번 미충족 — 재개하지 않는다.
  static const String resumeConditionUnmet = 'RESUME_CONDITION_UNMET';

  /// 그 번호 칸이 비었다(범위 밖·파싱 실패 포함).
  static const String resumeItemMissing = 'RESUME_ITEM_MISSING';

  /// 차례가 아니다(앞 항목 통과 전 · 일괄 0).
  static const String resumeItemOutOfOrder = 'RESUME_ITEM_OUT_OF_ORDER';

  /// 48h 미경과.
  static const String resumeTooSoon = 'RESUME_TOO_SOON';

  /// 신뢰 시각 모름(재개). 🔴 공용 `TRUSTED_TIME_UNKNOWN` 과 글자가 다르다 — 엔진 이력(명령 행 저장 값 · 바꾸지 않는다).
  static const String resumeTrustedTimeUnknown = 'RESUME_TRUSTED_TIME_UNKNOWN';

  static const Set<String> values = <String>{
    ackIncomplete,
    ackMismatch,
    checklistItemMissing,
    notActive,
    resumeChecklistDone,
    resumeChecklistIncomplete,
    resumeChecklistNotConfirmed,
    resumeConditionUnmet,
    resumeItemMissing,
    resumeItemOutOfOrder,
    resumeTooSoon,
    resumeTrustedTimeUnknown,
  };
}

/// M5 공용 거부(도메인 `safety_common_result` · 엔진 core `discretion`·`intervention`·`pledge`·`rule_change`·
/// `ops/contribution_setting` 다섯 사전 + ds 킬스위치·STOPPED 저장이 같은 글자를 품는다 → 한 벌 · K12 · K45).
abstract final class SafetyCommonResultCodes {
  /// 신뢰 시각 모름(발동 기록 확인 · 서약 · 1.22.0 개입·규칙 변경·재량 · 🆕 1.23.0 월 납입 `runContributionUpdate` — `ContributionResultCodes` 의 짝 · K45).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';

  /// 저널 id 가 이미 있다(발동 기록 · 재개 · 1.22.0 STOPPED).
  static const String journalIdTaken = 'JOURNAL_ID_TAKEN';

  static const Set<String> values = <String>{
    trustedTimeUnknown,
    journalIdTaken,
  };
}

/// 서약 거부(도메인 `pledge_result` · 엔진 core `pledge.dart:18` `PledgeCodes` 7 − 공용 1).
abstract final class PledgeResultCodes {
  /// 이미 첫 판이 있다(원문은 한 번만).
  static const String alreadyWritten = 'PLEDGE_ALREADY_WRITTEN';

  /// 편집 저널 미연결.
  static const String journalMissing = 'PLEDGE_JOURNAL_MISSING';

  /// 첫 판이 없다(편집할 것이 없다).
  static const String notWritten = 'PLEDGE_NOT_WRITTEN';

  /// 12월 창 밖.
  static const String outOfWindow = 'PLEDGE_OUT_OF_WINDOW';

  /// 문장 빈칸 · 셋이 아님.
  static const String sentencesMissing = 'PLEDGE_SENTENCES_MISSING';

  /// 지금 판과 같다.
  static const String unchanged = 'PLEDGE_UNCHANGED';

  static const Set<String> values = <String>{
    alreadyWritten,
    journalMissing,
    notWritten,
    outOfWindow,
    sentencesMissing,
    unchanged,
  };
}

/// 해제 진행 게이지 코드(도메인 `gauge` · 엔진 core `safety_text.dart:192` · `GaugeProgress.code` 의 값 · 검사 = C-55 ⑭).
/// 🔴 화면은 코드로 글자·색을 고르지 않는다 — `label`·`valueText`·`normalized`(폭) 를 그린다.
abstract final class GaugeCodes {
  /// 드로다운 회복.
  static const String ddRecovery = 'DD_RECOVERY';

  /// 유지 기간.
  static const String hold = 'HOLD';

  /// BULL 연속.
  static const String bullStreak = 'BULL_STREAK';

  /// 킬스위치 48h 냉각.
  static const String cooldown = 'COOLDOWN';

  static const Set<String> values = <String>{
    ddRecovery,
    hold,
    bullStreak,
    cooldown,
  };
}

// 🆕 v1.22(01 §31 · K12) — E13 나머지 거부 사전 5(엔진 글자 1:1 · 공용 `TRUSTED_TIME_UNKNOWN` 은 뺀다 — 한 벌).

/// 🆕 v1.22 — STOPPED 결정 거부(도메인 `stopped_decision_result` · core `safety/stopped_decision.dart:28` 7).
abstract final class StoppedDecisionResultCodes {
  /// 지금 STOPPED 가 아니다.
  static const String notActive = 'STOPPED_NOT_ACTIVE';

  /// 기다릴 거래일이 아직이다(일수 = 엔진 설정).
  static const String wait20d = 'STOPPED_WAIT_20D';

  /// 이 에피소드에 결정이 이미 있다.
  static const String alreadyMade = 'DECISION_ALREADY_MADE';

  /// SEV1 postmortem 이 비었다.
  static const String postmortemMissing = 'POSTMORTEM_MISSING';

  /// 가족 합의 선언이 없다.
  static const String familyAgreementMissing = 'FAMILY_AGREEMENT_MISSING';

  /// 사전 필드 3 이 비었다.
  static const String journalRequired = 'JOURNAL_REQUIRED';

  /// B 인데 재개 자격이 없다.
  static const String notEligible = 'STOPPED_NOT_ELIGIBLE';

  static const Set<String> values = <String>{
    notActive,
    wait20d,
    alreadyMade,
    postmortemMissing,
    familyAgreementMissing,
    journalRequired,
    notEligible,
  };
}

/// 🆕 v1.22 — postmortem 거부(도메인 `postmortem_result` · core `safety/incident.dart:61` 3).
abstract final class PostmortemResultCodes {
  /// 건이 없다.
  static const String notFound = 'INCIDENT_NOT_FOUND';

  /// 글이 비었다.
  static const String blank = 'POSTMORTEM_BLANK';

  /// 이미 썼다.
  static const String alreadyRecorded = 'POSTMORTEM_ALREADY_RECORDED';

  static const Set<String> values = <String>{notFound, blank, alreadyRecorded};
}

/// 🆕 v1.22 — 개입 거부(도메인 `intervention_result` · core `safety/intervention.dart:47` 7 − 공용 1).
abstract final class InterventionResultCodes {
  /// 이미 닫힌 세션.
  static const String closed = 'INTERVENTION_CLOSED';

  /// 냉각 중.
  static const String cooling = 'INTERVENTION_COOLING';

  /// 실행 창이 지났다.
  static const String expired = 'INTERVENTION_EXPIRED';

  /// 저널 미연결.
  static const String journalMissing = 'INTERVENTION_JOURNAL_MISSING';

  /// 차례가 아닌 단계(건너뛰기 · 되풀이).
  static const String outOfOrder = 'INTERVENTION_STAGE_OUT_OF_ORDER';

  /// 다른 세션이 살아 있다.
  static const String sessionOpen = 'INTERVENTION_SESSION_OPEN';

  static const Set<String> values = <String>{
    closed,
    cooling,
    expired,
    journalMissing,
    outOfOrder,
    sessionOpen,
  };
}

/// 🆕 v1.22 — 규칙 변경 취소·승인 거부(도메인 `rule_change_result` · core `safety/rule_change.dart:56` 12 − 공용 1).
abstract final class RuleChangeResultCodes {
  /// 승인 칸(골든 영향 · 승인자) 빈칸.
  static const String approvalFieldsMissing =
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING';

  /// 전 hash 가 지금 승인된 것이 아니다.
  static const String baseStale = 'RULE_CHANGE_BASE_STALE';

  /// 후 hash 가 `config_versions` 에 없다.
  static const String configUnknown = 'RULE_CHANGE_CONFIG_UNKNOWN';

  /// 냉각 전.
  static const String cooling = 'RULE_CHANGE_COOLING';

  /// 드로다운 락.
  static const String ddLocked = 'RULE_CHANGE_DD_LOCKED';

  /// 이미 결정됐다(취소 · 승인).
  static const String decided = 'RULE_CHANGE_DECIDED';

  /// 요청 칸 빈칸 · 전후 같음.
  static const String fieldsMissing = 'RULE_CHANGE_FIELDS_MISSING';

  /// 저널 미연결.
  static const String journalMissing = 'RULE_CHANGE_JOURNAL_MISSING';

  /// 요청 없음.
  static const String notFound = 'RULE_CHANGE_NOT_FOUND';

  /// 12월 창 밖.
  static const String outOfWindow = 'RULE_CHANGE_OUT_OF_WINDOW';

  /// 제3자 통지 없음.
  static const String thirdPartyMissing = 'RULE_CHANGE_THIRD_PARTY_MISSING';

  static const Set<String> values = <String>{
    approvalFieldsMissing,
    baseStale,
    configUnknown,
    cooling,
    ddLocked,
    decided,
    fieldsMissing,
    journalMissing,
    notFound,
    outOfWindow,
    thirdPartyMissing,
  };
}

/// 🆕 v1.22 — 재량 조정 거부(도메인 `discretion_result` · core `safety/discretion.dart:19` 4 − 공용 1).
/// 🔴 `JOURNAL_MISSING` = `FlagIds.journalMissing` 와 같은 글자 — 축 다름(재량 저널 미연결 ↔ 차단 플래그) · C-5 문서화 중복 다섯째 쌍.
abstract final class DiscretionResultCodes {
  /// 롤링 12개월 사용이 이미 상한.
  static const String countExceeded = 'COUNT_EXCEEDED';

  /// 조정폭이 상한 밖(파싱 실패·NaN 포함 — fail-closed).
  static const String deltaExceeded = 'DELTA_EXCEEDED';

  /// 저널 미연결.
  static const String journalMissing = 'JOURNAL_MISSING';

  static const Set<String> values = <String>{
    countExceeded,
    deltaExceeded,
    journalMissing,
  };
}

/// 🆕 v1.25(01 §34 · K151) — 킬스위치 미체결 취소 결과(도메인 `kill_cancel_outcome` · 엔진 core `KillCancelOutcome` wire 1:1 ·
/// `safety/kill_activation.dart:50-70` · 🔴 타입 이름 ≠ 엔진 — `ambiguous_import` 회피). 화면 분기 0(`KillCancelRow.outcomeCode` = 시험·Key).
abstract final class KillCancelOutcomeCodes {
  /// 취소 접수.
  static const String cancelled = 'CANCELLED';

  /// 분명한 거절 · 브로커 없음 · 오류.
  static const String failed = 'FAILED';

  /// 취소 결과 불명(🔴 다시 부르지 않는다 — NR-2).
  static const String unknown = 'UNKNOWN';

  /// 주문 결과가 불명이라 취소하지 않고 보고만.
  static const String notCancelledUnknownIntent =
      'NOT_CANCELLED_UNKNOWN_INTENT';

  /// 제출 중(브로커에 닿지 않았거나 닿는 중) — 보고만.
  static const String inFlight = 'IN_FLIGHT';

  static const Set<String> values = <String>{
    cancelled,
    failed,
    unknown,
    notCancelledUnknownIntent,
    inFlight,
  };
}
