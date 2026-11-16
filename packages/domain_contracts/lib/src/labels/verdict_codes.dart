// 01 §3-3 — X2 재판정 `verdict_code` 5종.
// + `planned_work.kind` 3종(01 §6-3 DDL 주석) · 결측 사유 코드 2종(01 §2-4 `PerfPoint.gapReasonCode`).
//
// 🔴 세 묶음을 한 파일에 두는 이유: 전부 X2(재개·계획 작업·결측 복원)의 코드 축이고,
//    `contracts_inventory.md` §6 의 `labels/` 파일 배치가 X2 전용 파일을 하나만 둔다.
// 🔴 문구는 엔진이 만든다 — `ResumeItem.verdictLabel`·`DataGapRow.label` 에 실려 온다.

/// X2 재판정 결과 코드(01 §3-3 · `planned_work.verdict_code`·`planned_work_transition.verdict_code`).
abstract final class VerdictCodes {
  /// 재판정 후 실행(수량·가격이 재개일 기준으로 바뀔 수 있다).
  static const String executedAsReevaluated = 'EXECUTED_AS_REEVALUATED';

  /// 창을 지나 만료.
  static const String expired = 'EXPIRED';

  /// 보수 모드 등으로 다음 정기 회차에 자리를 넘김.
  static const String superseded = 'SUPERSEDED';

  /// 차단 플래그로 진행 불가.
  static const String blocked = 'BLOCKED';

  /// 소급 복원 불가.
  static const String unrecoverable = 'UNRECOVERABLE';

  /// 전량 5종.
  static const Set<String> values = <String>{
    executedAsReevaluated,
    expired,
    superseded,
    blocked,
    unrecoverable,
  };
}

/// `planned_work.kind`(01 §6-3 DDL) — 🆕 v1.22(01 §31 · K18) 5종: P0S 판 = `MONTHLY_PLAN` · `SEASONAL_WINDOW` · `CARRY_OVER`
/// (엔진 `ResumeWorkKinds` · `resume/resume_judge.dart:39` · 🔴 `CARRY_OVER` = 행 등록 0 · 원장 파생 — 재개 판정 항목의 kind 로만 ·
/// ds `planned_work_store.dart:5`) · 옛 `DEFER_COUNT` · `SPLIT_LEG` = P0S 미사용(지우지 않는다 · v1.19 K22 ⓕ) ·
/// DDL 주석 = 엔진 재생성 PR(01 §31 K61).
///
/// 🔴 `SPLIT_LEG` 는 이름만 있고 **분할 집행 진도 필드는 계약에 없다**(01 §2-2 · M2-8 C-11) —
///    화면이 「n일차」·「이월 n주」를 만들지 않는다.
abstract final class PlannedWorkKindCodes {
  /// 계절 진입 창(슬리브 A).
  static const String seasonalWindow = 'SEASONAL_WINDOW';

  /// 보류 회차 카운트.
  static const String deferCount = 'DEFER_COUNT';

  /// 분할 집행 leg.
  static const String splitLeg = 'SPLIT_LEG';

  /// 🆕 v1.22 — 월말 계획(P0S).
  static const String monthlyPlan = 'MONTHLY_PLAN';

  /// 🆕 v1.22 — 이월 의도(P0S · 행 등록 0 · 재개 판정 항목의 kind 로만).
  static const String carryOver = 'CARRY_OVER';

  /// 전량 5종(🆕 v1.22 +2).
  static const Set<String> values = <String>{
    seasonalWindow,
    deferCount,
    splitLeg,
    monthlyPlan,
    carryOver,
  };
}

/// 성과 시계열의 결측 사유 코드 3종(01 §2-4 · §13-3 `PerfPoint.gapReasonCode`).
///
/// 🔴 `PerfPoint.value == null` 은 **결측이며 보간하지 않는다**(C-10). 이 코드는 «왜 비었는가»다.
abstract final class GapReasonCodes {
  /// `equity_snapshot` 결측.
  static const String equitySnapshotMissing = 'EQUITY_SNAPSHOT_MISSING';

  /// 재개 갭 구간.
  static const String resumeGap = 'RESUME_GAP';

  /// 🆕 v1.3 — 모의 구간(`SegmentKind.simExcluded`) 안의 점. 합산하지 않아 값이 없다.
  static const String simExcluded = 'SIM_EXCLUDED';

  /// 🆕 v1.14(E8a · 설계 13 §8 R23 D4 · R25 G4) — `data_gap.reason_code` 의 시세 결측 5종(엔진 `DataGapCause` 와 같은
  /// 글자 · core 시험이 맞댄다). 세션인데 행이 없다.
  static const String missingRow = 'MISSING_ROW';

  /// 🆕 v1.14 — 종가 ≤ 0.
  static const String nonPositivePrice = 'NON_POSITIVE_PRICE';

  /// 🆕 v1.14 — 거래량 < 0.
  static const String negativeVolume = 'NEGATIVE_VOLUME';

  /// 🆕 v1.14 — 전 세션 대비 |변동| ≥ 60%(FR-112).
  static const String priceJump = 'PRICE_JUMP';

  /// 🆕 v1.14 — 전 종목이 같은 날 함께 비었다(캘린더 의심 · 표 자동 수정 금지).
  static const String calendarSuspect = 'CALENDAR_SUSPECT';

  /// 🆕 v1.22(01 §31 · K66) — 모의 가상 체결 봉 없음(`data_gap.reason_code` · ds `local/sim_ledger_view.dart:19` ·
  /// dataset `sim_fill_bar` — DDL 주석 = 엔진 재생성 PR).
  static const String simBarMissing = 'SIM_BAR_MISSING';

  /// 전량 9종(🆕 v1.22 +1).
  static const Set<String> values = <String>{
    equitySnapshotMissing,
    resumeGap,
    simExcluded,
    missingRow,
    nonPositivePrice,
    negativeVolume,
    priceJump,
    calendarSuspect,
    simBarMissing,
  };
}

/// 🆕 v1.22(01 §31 · K49) — 재개 항목 판정 사유 · 매매 멈춤 사유(도메인 `resume_reason` · core `ResumeReasonCodes` ·
/// `resume/resume_judge.dart:51-95` 15 · 문구 = `resume_text.dart` · 🔴 타입 이름 ≠ 엔진 — `ambiguous_import`).
/// 축 = `ResumeGateRow.reasonCode` · 계절 선택 거부 `SafetyActionResult.reasonCode`(멈춤 사유 7).
abstract final class ResumeItemReasonCodes {
  /// 기한을 넘겼다.
  static const String duePassed = 'DUE_PASSED';

  /// 안내 모드 재개 조건 결정 대기.
  static const String advisoryPending = 'ADVISORY_PENDING';

  /// RECOVERY_FULL — 매매 없는 안전 정지.
  static const String safetyStop = 'SAFETY_STOP';

  /// RECOVERY_DRY — 관찰 회차.
  static const String observing = 'OBSERVING';

  /// 대사 불일치가 남았다.
  static const String reconMismatch = 'RECON_MISMATCH_REMAINS';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'UNKNOWN_ORDERS_REMAIN';

  /// RESERVED · SUBMITTING 잔류.
  static const String residualOrders = 'RESIDUAL_ORDERS_REMAIN';

  /// 계절 A 진입 — 사람 결정 대기.
  static const String humanDecision = 'HUMAN_DECISION';

  /// 보수 모드 — 다음 정기 회차.
  static const String conservativeDefer = 'CONSERVATIVE_DEFER';

  /// 재판정 결과 할 일 없음.
  static const String reevaluatedEmpty = 'REEVALUATED_EMPTY';

  /// 재판정 값으로 다음 주문 회차에 위임.
  static const String reevaluated = 'REEVALUATED';

  /// 사람이 건너뜀.
  static const String humanSkip = 'HUMAN_SKIP';

  /// 사람이 축소 진입을 고름.
  static const String humanReduced = 'HUMAN_REDUCED';

  /// 사람이 그대로를 고름.
  static const String humanAsIs = 'HUMAN_AS_IS';

  /// 재판정 포트가 실패했다(항목 그대로 · 플래그 유지).
  static const String reevaluationFailed = 'REEVALUATION_FAILED';

  static const Set<String> values = <String>{
    duePassed,
    advisoryPending,
    safetyStop,
    observing,
    reconMismatch,
    unknownOrders,
    residualOrders,
    humanDecision,
    conservativeDefer,
    reevaluatedEmpty,
    reevaluated,
    humanSkip,
    humanReduced,
    humanAsIs,
    reevaluationFailed,
  };
}

/// 🆕 v1.22 — 계절 선택 거부(도메인 `seasonal_choice_result` · core `SeasonalChoiceCodes` · `resume_judge.dart:99` 4).
abstract final class SeasonalChoiceResultCodes {
  /// `decision_id` 없음(구현이 짓는다 — 화면 경로에서는 나오지 않아야 한다).
  static const String decisionMissing = 'SEASONAL_DECISION_MISSING';

  /// 계절 A 진입 항목이 아님.
  static const String notSeasonalEntry = 'SEASONAL_NOT_ENTRY';

  /// 사람 결정을 기다리는 상태가 아님(종단 등).
  static const String notPending = 'SEASONAL_NOT_PENDING';

  /// 기한을 넘겼다(1월 판정 날 자동 만료).
  static const String pastDue = 'SEASONAL_PAST_DUE';

  static const Set<String> values = <String>{
    decisionMissing,
    notSeasonalEntry,
    notPending,
    pastDue,
  };
}

/// 🆕 v1.22 — `planned_work` 전이 거부(도메인 `planned_work_reject` · core `PlannedWorkCodes` ·
/// `resume/planned_work_machine.dart:20` 6 · 계약 이름 = 축을 드러낸다).
abstract final class PlannedWorkRejectCodes {
  /// 같은 상태로의 전이.
  static const String unchanged = 'PLANNED_WORK_UNCHANGED';

  /// 종단 상태에서의 전이.
  static const String terminal = 'PLANNED_WORK_TERMINAL';

  /// 기한이 지났다.
  static const String pastDue = 'PLANNED_WORK_PAST_DUE';

  /// 아직 때가 아니다.
  static const String notDue = 'PLANNED_WORK_NOT_DUE';

  /// 허용되지 않는 전이.
  static const String illegal = 'PLANNED_WORK_ILLEGAL';

  /// 그런 작업이 없다.
  static const String unknown = 'PLANNED_WORK_UNKNOWN';

  static const Set<String> values = <String>{
    unchanged,
    terminal,
    pastDue,
    notDue,
    illegal,
    unknown,
  };
}
