// 🆕 계약 v1.1(2026-09-17) — 매매일지 상세(J-2)·UNKNOWN 보드(J-5)·타임라인 배지(J-1)의 코드 상수.
// 🆕 계약 v1.1 R2 준비(2026-09-23) — 사전 저널(J-3) 제출의 거부 사유 코드.
// 🆕 계약 v1.7(01 §16 · §8 미결 46) — 사후 blind 리뷰(J-4) 점수 제출의 거부 사유 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    문구는 짝이 되는 `*Label` 필드가 준다 — 화면이 이 상수로 문구·아이콘·색을 고르지 않는다.
//    쓰는 곳은 테스트(«6단계가 이 순서로 왔는가»)와 엔진 구현이다.

/// `J-2` 체인 타임라인의 단계(02 §3-2) — 자동 매매 6단계 + advisory 치환 2단계.
///
/// 🔴 한 체인은 **언제나 6칸**이다: `SIGNAL → INTENT → (BROKER_ORDER | ADVICE) →
///    (EXECUTION | MANUAL_RECORD) → TRADE → JOURNAL`. 어느 갈래인지는 엔진이 정한다.
abstract final class DecisionChainStageCodes {
  static const String signal = 'SIGNAL';
  static const String intent = 'INTENT';
  static const String brokerOrder = 'BROKER_ORDER';
  static const String execution = 'EXECUTION';
  static const String trade = 'TRADE';
  static const String journal = 'JOURNAL';

  /// X7 advisory — `BROKER_ORDER` 자리의 치환.
  static const String advice = 'ADVICE';

  /// X7 advisory — `EXECUTION` 자리의 치환.
  static const String manualRecord = 'MANUAL_RECORD';

  static const Set<String> values = <String>{
    signal,
    intent,
    brokerOrder,
    execution,
    trade,
    journal,
    advice,
    manualRecord,
  };
}

/// 주문 전 전수 검사의 층(04_안전장치 P2 — 검사 순서 Level 4 → 3 → 2 → 1).
/// `RejectTrace.stageCode` 의 값이다.
abstract final class SafetyCheckLevelCodes {
  /// Level 4 — 시스템.
  static const String level4System = 'LEVEL_4_SYSTEM';

  /// Level 3 — 포트폴리오.
  static const String level3Portfolio = 'LEVEL_3_PORTFOLIO';

  /// Level 2 — 슬리브.
  static const String level2Sleeve = 'LEVEL_2_SLEEVE';

  /// Level 1 — 종목.
  static const String level1Position = 'LEVEL_1_POSITION';

  static const Set<String> values = <String>{
    level4System,
    level3Portfolio,
    level2Sleeve,
    level1Position,
  };
}

/// `J-5` UNKNOWN 해소 단계 4칸(02 §3-5) — `UnknownResolutionStep.stepId` 의 값이다.
abstract final class UnknownResolutionStageCodes {
  static const String recorded = 'RECORDED';
  static const String queryPending = 'QUERY_PENDING';
  static const String brokerConfirmed = 'BROKER_CONFIRMED';
  static const String resolved = 'RESOLVED';

  static const Set<String> values = <String>{
    recorded,
    queryPending,
    brokerConfirmed,
    resolved,
  };
}

/// `J-1` 상단 배지의 종류 — `JournalTimelineBadge.badgeCode` 의 값이다.
abstract final class JournalBadgeCodes {
  /// 「확인 중 N건」 → `J-5`.
  static const String unknownOpen = 'UNKNOWN_OPEN';

  /// 「리뷰 대기 N건」 → `J-4`.
  static const String blindReviewPending = 'BLIND_REVIEW_PENDING';

  static const Set<String> values = <String>{unknownOpen, blindReviewPending};
}

/// 🆕 계약 v1.1 R2 준비(2026-09-23) — `J-3` 사전 저널 제출(`CommandKind.journalDraft`)의
/// 거부 사유. `CommandReceipt.rejectReasonCode` 의 값이다(`state == rejected` 일 때).
///
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다(advice_codes.dart 머리와 같은
///    규칙) — 화면은 이 코드로 문구를 고르지 않고, 코드를 표시하지도 않는다.
/// 🔴 거부는 초안을 지우지 않는다(C17) — 화면은 값을 채운 채 `stateLabel` 과 재제출 버튼을 보인다.
/// 🔴 X7 명령의 거부 사유(`AdviceRejectCodes`)와 **다른 도메인**이다 — 섞어 조회하지 않는다
///    (`ContractCodes.byDomain` 키 `journal_draft_reject`).
/// ⏸ 픽스처가 쓰는 1종에서 시작한다. 엔진(M1)이 새 사유를 내면 **여기와 픽스처를 함께** 넓힌다.
/// 🆕 v1.35(01 §44 · K296 ~ K298) — J-3 키 = **저널 id**(`decision_journal.journal_id` · 안전 동작의 `decision_id` 와 한 벌) ·
///    제출 갈래 = 엔진이 키로 가른다(ⓐ 채우기 = 사전 3칸이 빈 있는 행 · ⓑ 새 행 = 엔진이 J-3 링크에 실어 발급한 새 저널 id) ·
///    1종 → 3종(키 · 입력 거부). 🔴 화면은 이 코드로 분기 · 문구 · 표시를 하지 않는다(위 머리 그대로 — 문구 = `stateLabel`).
abstract final class JournalDraftRejectCodes {
  /// 이 키의 사전 저널이 이미 접수돼 있다 — 채우기 갈래의 행이 이미 세 칸 다 찼거나 새 행 갈래의 키로 이미 썼다.
  static const String journalAlreadyExists = 'JOURNAL_ALREADY_EXISTS';

  /// 🆕 v1.35(K298) — 키가 저널 대상이 아니다(모르는 id · 결정 id 를 넣었다 · 엔진이 발급하지 않은 새 키).
  static const String journalTargetUnknown = 'JOURNAL_TARGET_UNKNOWN';

  /// 🆕 v1.35(K298) — 입력이 폼 조건을 못 채운다(근거 앞뒤 공백 뺀 글자 < `rationaleMinChars` · 기대 결과 빈칸 ·
  /// 인용 규칙 ∉ 그 폼 `ruleCitedOptions` · `requiresNote` 인데 메모 빈칸) — 화면 «제출 가능 조건»과 같은 판정을 엔진이 다시 한다.
  static const String journalInputInvalid = 'JOURNAL_INPUT_INVALID';

  /// 전량(🆕 v1.35 3종).
  static const Set<String> values = <String>{
    journalAlreadyExists,
    journalTargetUnknown,
    journalInputInvalid,
  };
}

/// 🆕 v1.35(01 §44 · K300) — `J-3` 인용 규칙 선택지 코드(`JournalDraftFormSpec.ruleCitedOptions[].code` · `JournalDraft.ruleCited` ·
/// J-3 가 쓴 `decision_journal.rule_cited`) — 도메인 `journal_rule_cited` · 표본 3 = 엔진 첫 목록.
/// 🔴 다른 안전 동작의 `ruleCited`(재개 7번 · 개입 3단계 · RECON 해제 · 규칙 변경 요청)는 **원문**이다 — 이 사전과 축이 다르다(01 §8 미결 184 ③).
/// 🔴 선택지 글자(`label`) · 메모 필수(`requiresNote`) = 엔진 VM 칸 · 화면은 이 코드로 분기 · 문구를 고르지 않는다.
/// 엔진이 새 규칙을 내면 **여기와 픽스처를 함께** 넓힌다.
abstract final class JournalRuleCitedCodes {
  /// 재량 예산(롤링 12개월) 안에서 조정.
  static const String discretionBudget = 'RULE_DISCRETION_BUDGET';

  /// 대사 불일치 — 원인 코드 확인 뒤 해소.
  static const String reconCause = 'RULE_RECON_CAUSE';

  /// 그 밖의 규칙(메모 필수).
  static const String other = 'RULE_OTHER';

  static const Set<String> values = <String>{
    discretionBudget,
    reconCause,
    other,
  };
}

/// 🆕 v1.35(01 §44 · K294 · 미결 206 꼬리 · 217 ④) — 로컬 원장 `decision_journal.kind` 열의 값(도메인 `decision_journal_kind` ·
/// SPEC 02D `decision_journal` 주석과 한 벌). 🔴 표시 칸이 아니다 — 화면은 이 글자를 받지도 그리지도 않는다(배지 = `DeviationBadge.kindCode`).
/// 규칙: 글자 = 그 저널을 쓰는 안전 동작의 id 와이어(`SafetyActionId`) — 예외 둘([killSwitchChecklist] · [discretion] = 기존 엔진 · SPEC 글자).
/// 🔴 같은 글자 다른 축 셋 — [discretion] · [reconClear] · [killSwitchResume] = `DeviationKindCodes`(배지 종류 · C-5 문서 쌍).
/// 🔴 NULL = 옛 행(읽기 호환 · SAF-408 판정은 kind 를 보지 않는다) — 새로 쓰는 행은 이 사전 값만(엔진 숙제 = 01 §8 미결 220 ⓒ).
/// X1 D-03 · 비상 선언 결정(01 §8 미결 218 ⓖ) = 이전 저널 표 칸이라 이 사전 밖이다.
abstract final class DecisionJournalKinds {
  /// 킬스위치 발동 뒤 기록(M5-1 · `confirmKillChecklist` · ds `kill_switch_store` — 🔵 예외: 명령 와이어 `KILL_CHECKLIST_CONFIRM` 와 다르다).
  static const String killSwitchChecklist = 'KILL_SWITCH_CHECKLIST';

  /// 킬스위치 재개 7번(M5-2 · `SafetyActionId.killSwitchResume`).
  static const String killSwitchResume = 'KILL_SWITCH_RESUME';

  /// STOPPED 결정 A · B · C(M5-3 · `SafetyActionId.stoppedDecision`).
  static const String stoppedDecision = 'STOPPED_DECISION';

  /// 대사 불일치 해제(M5-5 · `SafetyActionId.reconClear`).
  static const String reconClear = 'RECON_CLEAR';

  /// 규칙 변경 요청(M5-9 · `SafetyActionId.ruleChangeRequest`).
  static const String ruleChangeRequest = 'RULE_CHANGE_REQUEST';

  /// 수동 개입 3단계 사전 저널(M5-6 · X5 마찰 · `SafetyActionId.interventionJournal` · 🔵 지금 엔진 = NULL → 미결 220 ⓒ).
  static const String interventionJournal = 'INTERVENTION_JOURNAL';

  /// 재량 조정의 사전 저널(M5-7 · J-3 새 행 갈래 · `DiscretionAdjustSubmission.decisionId` 가 가리킨다 · 🔵 예외: SPEC v2.15 ·
  /// 엔진 `kDiscretionJournalKind` 글자 — 동작 와이어 `DISCRETION_ADJUST` 와 다르다).
  static const String discretion = 'DISCRETION';

  /// 서약 편집의 사전 저널(M5-8 · J-3 새 행 갈래 · `SafetyActionId.pledgeEdit` · `PledgeSubmission.decisionId` 가 가리킨다).
  static const String pledgeEdit = 'PLEDGE_EDIT';

  /// 전량 8종.
  static const Set<String> values = <String>{
    killSwitchChecklist,
    killSwitchResume,
    stoppedDecision,
    reconClear,
    ruleChangeRequest,
    interventionJournal,
    discretion,
    pledgeEdit,
  };

  /// J-3 새 행 갈래의 목적(K297 ⓑ) — 저널을 먼저 쓰고 동작이 그 id 를 받는 둘.
  static const Set<String> draftPurposes = <String>{discretion, pledgeEdit};
}

/// 🆕 v1.7(01 §16) — `J-4` blind 리뷰 점수 제출(`CommandKind.blindReviewScore`)의 거부 사유.
/// `CommandReceipt.rejectReasonCode` 의 값(`state == rejected` 일 때) · `ContractCodes.byDomain` 키 `blind_review_reject`.
/// 🔴 사유의 **문구**는 `CommandReceipt.stateLabel` 에 실려 온다 — 화면은 이 코드를 표시·분기하지 않는다.
/// ⏸ 픽스처(`m6/blind_review_receipts_6`)가 두 사유를 다 싣는다. 엔진(M1)이 새 사유를 내면 **여기와 픽스처를 함께** 넓힌다.
abstract final class BlindReviewRejectCodes {
  /// 이 결정은 이미 채점됐다(먼저 집행된 채점이 이긴다 — K12).
  static const String alreadyScored = 'BLIND_REVIEW_ALREADY_SCORED';

  /// 답이 카드와 맞지 않는다(빠진 문항 · 모르는 문항 · 선택지에 없는 점수).
  static const String answersInvalid = 'BLIND_REVIEW_ANSWERS_INVALID';

  static const Set<String> values = <String>{alreadyScored, answersInvalid};
}

/// 🆕 계약 v1.17(01 §26 · 엔진 D11 · 13 §8 R33 D11·D24) — `TradeJournalEntry.reasons[].code` 중 **엔진이 정한 3종**
/// (D11 2 · 🆕 v1.18 E14a 1 — 01 §27 · K-n ⓕ).
///
/// 🔴 **전수 목록이 아니다** — 일지 사유 칩 코드 전수 등재 = 01 §8 미결 166. 화면은 이 코드로 분기·문구·아이콘을 고르지 않는다
///    (칩 `label`·`tone` 이 준다). 쓰는 곳 = 계약 테스트(C-51 ⑩⑪)와 엔진 구현.
abstract final class JournalReasonCodes {
  /// `status == prevented` 행의 근거 — 같은 멱등키의 의도가 이미 있어 새 의도 행을 만들지 않았다(NR-1 6.5 · R33 D24).
  /// 🔴 그 행의 `decision.intentId` = **이미 그 키를 가진 원 의도**.
  static const String duplicateOrderPrevented = 'DUPLICATE_ORDER_PREVENTED';

  /// `status == expired` 행의 근거 — 장 마감까지 체결되지 않은 잔량을 실효로 기록했다(취소 아님 · 04_안전장치 §3-1 ③ · R33 D5).
  static const String dayEndExpired = 'DAY_END_EXPIRED';

  /// 🆕 v1.18(01 §27 · K-n ⓕ · 엔진 E14a `kLeaseInvalidCode`) — `status == rejected`(NR-1 0단계) · `skipped`(6.9 직전 재확인) 행의 근거 —
  /// 이 기기에 발주권(리스)이 없거나 모른다(fail-closed · 그 키를 먹는다 = 그날 보류). 🔴 `AdviceRejectCodes.leaseExpired`
  /// (명령 접수 축 · 발행 epoch)와 **다른 축**이다.
  static const String leaseInvalid = 'LEASE_INVALID';

  static const Set<String> values = <String>{
    duplicateOrderPrevented,
    dayEndExpired,
    leaseInvalid,
  };
}
