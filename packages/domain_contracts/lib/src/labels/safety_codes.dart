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
  /// 신뢰 시각 모름(발동 기록 확인 · 서약 · 1.22.0 개입·규칙 변경·재량).
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
