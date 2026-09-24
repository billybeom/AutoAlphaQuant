// 🆕 계약 v1.1(2026-09-17) — 매매일지 상세(J-2)·UNKNOWN 보드(J-5)·타임라인 배지(J-1)의 코드 상수.
// 🆕 계약 v1.1 R2 준비(2026-09-23) — 사전 저널(J-3) 제출의 거부 사유 코드.
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
abstract final class JournalDraftRejectCodes {
  /// 이 결정(`decisionId`)의 사전 저널이 이미 접수돼 있다 — 같은 결정에 두 번째 사전 저널.
  static const String journalAlreadyExists = 'JOURNAL_ALREADY_EXISTS';

  /// 전량(⏸ 1종).
  static const Set<String> values = <String>{journalAlreadyExists};
}
