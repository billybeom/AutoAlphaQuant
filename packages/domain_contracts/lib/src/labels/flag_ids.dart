// 01 §3-5 — 차단 플래그 `flag_id` 12종 · §9-5 ③ `SafetyState` hold 사유 1종.
//
// 🔴 «차단 범위»와 «해제 경로»는 주석으로만 적는다 — 런타임 값은 `BlockFlag.clearRoute` 와
//    `BlockFlag.clearInstruction`(플래그마다 다른 문구)로 온다. 화면이 flag_id 로 문구·경로를
//    고르는 사전을 만들면 C-5 위반이다.
// 🔴 저장 위치는 `trading_block`(06 §2-6 02_데이터모델)이며 **그 표에는 `flag_id` CHECK 가 없다** —
//    열거는 이 목록과 그 표의 주석, 그리고 04 §3-1 2단계 판정 SQL 이 함께 갖는다(배치 E 참조).

/// 주문 차단·상태 표식 플래그(01 §3-5 · `trading_block.flag_id`).
abstract final class FlagIds {
  /// 대사 불일치 — **전 주문** 차단. 해제 = `causeCodeRequired`(원인 코드 + `decision_id`).
  /// 🔴 `/resume` 으로 풀리지 않는다.
  static const String reconMismatch = 'RECON_MISMATCH';

  /// 이탈 저널 미작성 — **신규 매수** 차단. 해제 = `automatic`.
  /// 🔴 수동 해제 버튼이 **존재하지 않는다**.
  static const String journalMissing = 'JOURNAL_MISSING';

  /// 계층 B 월간 미판정 — **신규 매수** 차단. 해제 = `automatic`.
  static const String tierBUnjudged = 'TIER_B_UNJUDGED';

  /// DST 전환 주간. ⚠️ **차단이 아니라 상태 표식**(램프 하향으로 통과). 해제 = `automatic`(주간 종료).
  static const String dstWeek = 'DST_WEEK';

  /// X2 재개 미완 — **전 주문** 차단. 해제 = `automatic`(재개 완료 시).
  static const String resumeIncomplete = 'RESUME_INCOMPLETE';

  /// X5 정정 트랜잭션 뮤텍스. 🔴 자동·사람 해제가 **둘 다 없다**(트랜잭션 종료 시 소멸).
  static const String ledgerFix = 'LEDGER_FIX';

  /// X5 원장 무결성 — **전 주문** 차단. 해제 = `wizardOnly`(원인 코드 + `decision_id` + 체인 재스탬프).
  static const String ledgerIntegrity = 'LEDGER_INTEGRITY';

  /// X7 원장 미검증 — **신규 진입 안내**만 중단(청산·방어 안내는 유지 · 비대칭 원칙).
  /// 해제 = `wizardOnly` → `M5-13`.
  static const String adviceLedgerUnverified = 'ADVICE_LEDGER_UNVERIFIED';

  /// X7 실사 기한 초과 — **신규 진입 안내** 중단. 해제 = `automatic`(실사 1회 통과).
  /// 🔴 차단은 **차이의 크기가 아니라 실사의 부재**에만 건다(A12).
  static const String selfAuditOverdue = 'SELF_AUDIT_OVERDUE';

  /// X7 실사 예정. ⚠️ **차단 아님** — 상태 표식(D-15 재고지 → D-0 `SELF_AUDIT_OVERDUE`).
  static const String selfAuditDue = 'SELF_AUDIT_DUE';

  /// X7 실사 패턴 미검증. ⚠️ **차단 아님** — 상태 표식.
  static const String selfAuditPatternUnverified =
      'SELF_AUDIT_PATTERN_UNVERIFIED';

  /// X7 선택적 이행(진입/청산 이행률 비대칭). ⚠️ **차단 아님** — 상태 표식.
  /// 🔴 **알림을 만들지 않는다** — 월간 리포트에만 실린다.
  static const String adviceSelectiveExecution = 'ADVICE_SELECTIVE_EXECUTION';

  /// 전량 12종.
  static const Set<String> values = <String>{
    reconMismatch,
    journalMissing,
    tierBUnjudged,
    dstWeek,
    resumeIncomplete,
    ledgerFix,
    ledgerIntegrity,
    adviceLedgerUnverified,
    selfAuditOverdue,
    selfAuditDue,
    selfAuditPatternUnverified,
    adviceSelectiveExecution,
  };

  /// 주문을 실제로 막는 것 — 04 §3-1 2단계 판정 SQL 이 읽어야 하는 집합.
  ///
  /// 🔴 배치 E 는 이 넷을 판정 SQL 에 **실제로 추가**할 것을 요구한다(01 §6-5) —
  ///    플래그만 읽고 SQL 을 안 고친 구현은 실격이다.
  static const Set<String> blocking = <String>{
    reconMismatch,
    journalMissing,
    tierBUnjudged,
    resumeIncomplete,
    ledgerIntegrity,
    adviceLedgerUnverified,
    selfAuditOverdue,
  };

  /// 차단하지 않는 상태 표식 4종.
  static const Set<String> markerOnly = <String>{
    dstWeek,
    selfAuditDue,
    selfAuditPatternUnverified,
    adviceSelectiveExecution,
  };
}

/// `SafetyState` 의 배치 보류 사유 코드(01 §9-5 ③ · M2-8 A-17).
///
/// 🔴 `trading_block.flag_id` 가 **아니다** — 안전 상태의 hold 사유다.
/// 🆕 v1.35(01 §44 · K295 · 미결 219 닫음) — 짝 문장 = `SafetyState.holdLabels`(같은 차례 · 같은 길이) · 화면은 이 코드를 보지 않는다.
///    엔진 생산: `MIGRATION_IN_PROGRESS` = ds 안전 읽기 모델(미결 212 ② ✅) · `LIVE_AWAITING_KEYS` = 기동 게이트 → `SafetyState` 싣기 +
///    짝 문장 = 미결 220 ⓓ.
abstract final class SafetyHoldCodes {
  /// 실키 검증 전 보류.
  ///
  /// 🔴 **`operatingMode == autoTrade` 에서만 배치를 중단한다**(C9). `live × advisory` 에서는
  ///    키가 없는 것이 **정상 상태**이므로 hold 를 걸지 않는다 —
  ///    걸면 배치가 무기한 중단되고 안내가 영영 나오지 않는다(«침묵이 안전으로 위장되는» 상태).
  static const String liveAwaitingKeys = 'LIVE_AWAITING_KEYS';

  /// 🆕 v1.30(01 §38 · SPEC v2.45 04 §3-1 ① · E16i) — 기기 이전 진행 중(**표시** hold).
  ///
  /// 🔴 막는 정본은 이 글자가 아니라 엔진 리스 판정이다 — 이전 세션이 «신규 주문 동결»에 들어서면 NR-1 0단계 리스 = 무효
  ///    (`LEASE_INVALID` · 막는 것은 주문뿐 · 백업 커밋 · 아카이브는 원래 리스 판정 그대로). 이 hold 는 그 상태를 보여 줄 뿐이다.
  ///    엔진 생산(`SafetyState.holds` 에 싣기) = 엔진 숙제(01 §8 미결 212 ② — ✅ R225 #312).
  static const String migrationInProgress = 'MIGRATION_IN_PROGRESS';

  /// 전량 2종.
  static const Set<String> values = <String>{
    liveAwaitingKeys,
    migrationInProgress,
  };
}
