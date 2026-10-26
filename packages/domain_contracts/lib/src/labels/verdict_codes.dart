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

/// `planned_work.kind` 3종(01 §6-3 DDL).
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

  /// 전량 3종.
  static const Set<String> values = <String>{
    seasonalWindow,
    deferCount,
    splitLeg,
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

  /// 전량 8종.
  static const Set<String> values = <String>{
    equitySnapshotMissing,
    resumeGap,
    simExcluded,
    missingRow,
    nonPositivePrice,
    negativeVolume,
    priceJump,
    calendarSuspect,
  };
}
