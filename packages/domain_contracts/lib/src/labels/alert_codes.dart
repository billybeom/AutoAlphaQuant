// 알림 코드 36종 — 04 §5-1b(X7 9 + 전환 2) · §5-1c(자동 매매 11 + 유지보수 2) · §5-1d(운영 1)(🆕 v1.17 `STALE_ORDERS_HELD` · 엔진 D11) ·
// 🆕 v1.18 안전 3(E13 · 04 §5-3 v2.40·v2.41 제안) · 재개 3(E14 · 04 §5-3 v2.42 제안) ·
// 🆕 v1.27 SAF 경고 4(E3d · 04 §1 Level 3 · §5-3 v2.46 제안) · 파생 동기 1(E16 · 04 §5-3 v2.45 제안 · 01 §36).
// 인벤토리 §6-9 의 분류를 그대로 쓴다.
//
// 🔴 **등급(P0/P1/P2)을 이 파일에 사전으로 만들지 않는다.** 등급의 런타임 정본은
//    `AlertItem.level` 하나이고(01 §2-10 · 결정 7c 표시 계층의 사적 재분류 금지),
//    최종 정본은 엔진 `06_시스템설계/04_안전장치.md` 의 notify 등급이다.
//    아래 각 코드의 주석에 적은 등급은 04 의 **잠정 카탈로그 기록**이며,
//    «앱 알림 코드 ↔ 엔진 등급 대조 1회»(06 §4 ③)를 통과하기 전에는 유효하지 않다.
// 🔴 **등재 전에는 화면이 `code` 로 아이콘·색도 고르지 않는다**(픽스처 고정) — 04 §5-1b·§5-1c 말미.
// 🔴 **알림을 만들지 않는 것** — 키 미등록 · `ADVICE_SELECTIVE_EXECUTION` ·
//    `SELF_AUDIT_PATTERN_UNVERIFIED`(전부 상태 표식·월간 리포트로만).

/// 알림 코드(04 §5-1b·§5-1c·§5-1d).
abstract final class AlertCodes {
  // ── X7 안내 9 (04 §5-1b) ──────────────────────────────────────────────────
  /// 잠정 P1 · 🔴 **배치당 1건**(항목별 발송 금지).
  static const String adviceIssued = 'ADVICE_ISSUED';

  /// 잠정 P0 · 🔴 **ack 승급 사다리 미적용** — 대신 T-90분 [adviceDueSoon] 이 한 번 더 온다.
  /// 🆕 v1.15 — 이 코드의 `AlertItem.ack` = 늘 null(C-49 ⑥).
  static const String adviceExitUrgent = 'ADVICE_EXIT_URGENT';

  /// 잠정 P1 · 유효기한 당일 장 마감 T-90분, 미기록 잔존. 1건으로 묶음.
  static const String adviceDueSoon = 'ADVICE_DUE_SOON';

  /// 잠정 P2 · 만료 스윕 직후. 일 1건 묶음.
  static const String adviceExpired = 'ADVICE_EXPIRED';

  /// 잠정 P0 · 🔴 **독립 `AlertItem`** 이며 킬스위치 알림과 **엔진 순서로 인접**해 온다
  /// (`groupKey` 필드 없음 · 🆕 v1.15 · 화면은 받은 차례 그대로)
  /// («동봉»은 세 번째 발송 형태라 만들지 않는다 · C13).
  static const String adviceRevoked = 'ADVICE_REVOKED';

  /// 잠정 P0 · 골든벡터 재검증 실패 등으로 안내가 눌렸을 때.
  static const String adviceSuppressed = 'ADVICE_SUPPRESSED';

  /// 잠정 P1 · 신뢰 등급 하향 시 **1회**.
  static const String ledgerTrustDowngrade = 'LEDGER_TRUST_DOWNGRADE';

  /// 잠정 P2 · 월 1회 원장 실사 요구. 🔴 같은 이름의 `flag_id` 와 **다른 축**이다.
  static const String selfAuditDue = 'SELF_AUDIT_DUE';

  /// 잠정 P1 · 가격 범위·거래일 검증 거부. 즉시.
  static const String manualFillRejected = 'MANUAL_FILL_REJECTED';

  // ── 전환 2 (04 §5-1b) ─────────────────────────────────────────────────────
  /// 잠정 P1 · 전환 냉각 24h 동안 **1일 1건**. 🔴 조르지 않는다(경보 피로 규칙).
  static const String handoverCoolingActive = 'HANDOVER_COOLING_ACTIVE';

  /// 잠정 P1 · 전환 커밋 성공 직후 **1회** — 띠·탭이 바뀐 이유를 말하는 유일한 자리.
  static const String handoverCommitted = 'HANDOVER_COMMITTED';

  // ── 자동 매매 11 (04 §5-1c) ───────────────────────────────────────────────
  /// 잠정 P1 · 주문 거부. 배치당 묶음.
  static const String orderRejected = 'ORDER_REJECTED';

  /// 잠정 P0 · 결과 불명(UNKNOWN) 잔존. 🔴 배치당 1건으로 묶음.
  static const String orderOutcomeUnknown = 'ORDER_OUTCOME_UNKNOWN';

  /// 잠정 P0 · 재대사 후에도 잔존하는 불일치. 🔴 재대사 전에는 발행하지 않는다.
  /// 🔴 같은 이름의 `flag_id` 와 **다른 축**이다.
  static const String reconMismatch = 'RECON_MISMATCH';

  /// 잠정 P2 · 월말 리밸런싱 D-7 예고. 🔴 회차당 1건.
  static const String rebalanceD7 = 'REBALANCE_D7';

  /// 잠정 P1 · 월말 리밸런싱 D-1 통보. advisory 에서는 [adviceIssued] 에 **묶여** 온다.
  /// 🔴 묶는 주체는 엔진이며 화면이 두 알림을 발견해 합치지 않는다.
  static const String rebalanceD1 = 'REBALANCE_D1';

  /// 잠정 P1 · 워치독 유예 초과. 체크당 1건.
  static const String watchdogLate = 'WATCHDOG_LATE';

  /// 잠정 P0 · 브로커 인증 실패(토큰·앱키).
  static const String brokerAuthFailed = 'BROKER_AUTH_FAILED';

  /// 잠정 P1 · 시세·데이터 소스 장애. 소스당 1건.
  static const String dataSourceDown = 'DATA_SOURCE_DOWN';

  /// 잠정 P1 · 백업 나이 26h 초과. 일 1건.
  static const String backupStale = 'BACKUP_STALE';

  /// 잠정 P2 · 월 납입 리마인더(`H-02` 행과 같은 트리거). 일일 다이제스트.
  static const String depositReminder = 'DEPOSIT_REMINDER';

  /// 🆕 v1.17(01 §26 · 엔진 D11 · 13 §8 R33 D11 · R38 Z8) — 잠정 P1 · **다음 날 가드 보류**: 그날 계좌 첫 주문 앞 체결조회에
  /// 지난 거래일 원주문 행이 보이거나(`STALE_ORDERS`) 그 조회가 실패해(`STALE_GUARD_UNAVAILABLE` · fail-closed) **그 계좌의
  /// 그날 배치를 보류**했다(이중 매수 방지 · 04_안전장치 §3-1 ③ 5). 🔴 계좌·날 1건 · 등급 정본 등재(§5-3 표) = 엔진 다음 SPEC 판.
  static const String staleOrdersHeld = 'STALE_ORDERS_HELD';

  // ── 유지보수 창 2 (04 §5-1c · S7 재추적 N-2) ────────────────────────────────
  /// 잠정 P1 · X1 유지보수 창이 T시간을 넘겨 열려 있음. 🔴 창 1개당 1건.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String maintenanceWindowOverdue = 'MAINTENANCE_WINDOW_OVERDUE';

  /// 잠정 P0 · 부팅 시 미종료 창을 감지해 `/resume` 을 시도했으나 실패. 부팅 1회당 1건.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String maintenanceResumeFailed = 'MAINTENANCE_RESUME_FAILED';

  // ── 운영 파라미터 1 (04 §5-1d) ─────────────────────────────────────────────
  /// 잠정 P2 · 월 납입 운영값 변경 명령이 집행된 직후.
  /// 🔴 변경 1건당 1건(멱등 키 = `operating_param_log.row_id`) · **일일 다이제스트에만** 실린다.
  /// 🔴 앱이 은행을 대신 바꾸지 않으므로 «지금 변경» 버튼·딥링크를 만들지 않는다.
  /// ⚠️ 코드명 M2-3 확정 대기.
  static const String contributionChanged = 'CONTRIBUTION_CHANGED';

  // ── 🆕 v1.18 안전 3 (01 §27 · K-z · 엔진 E13d1·E13c1 상수 = 등재 · 등급 = 엔진 `kAlertLevels`) ──────────
  /// 잠정 P0 · 서킷브레이커 STOPPED 진입(신규 주문 전면 중단 · 보유 그대로 · postmortem 3일 · 엔진 `kBreakerStoppedAlertCode`).
  static const String breakerStopped = 'BREAKER_STOPPED';

  /// 잠정 P0 · 원장 자가 무결성 실패(지난 날 해시 불일치 → 전 신규 주문 차단 · 엔진 `kLedgerIntegrityAlertCode` · E13c1).
  static const String ledgerIntegrityBroken = 'LEDGER_INTEGRITY_BROKEN';

  /// 잠정 P1 · STOPPED 재개 자격 충족(v2.29 · 자동으로 풀리지 않는다 · 에피소드당 1회 · 엔진 `kStoppedReleaseEligibleAlertCode` ·
  /// 🔵 E11f1 `equity_snapshot` 보고 «재개 자격» 과 **같은 사건** — 한 코드).
  static const String stoppedReleaseEligible = 'STOPPED_RELEASE_ELIGIBLE';

  // ── 🆕 v1.18 재개 3 (01 §27 · K-z · 엔진 E14b `resume_alerts.dart` · 회차 끝 묶음 · 한국 날 ≤ 1) ──────────
  /// 잠정 P0 · 재개 뒤 매매 정지 유지(`RESUME_INCOMPLETE` 유지 · [resumeCompleted] 와 배타).
  static const String resumeTradingHalted = 'RESUME_TRADING_HALTED';

  /// 잠정 P1 · 재개 완료(해제 · 주문은 다음 `kr_order` 회차가 낸다).
  static const String resumeCompleted = 'RESUME_COMPLETED';

  /// 잠정 P2 · 되살릴 수 없는 기록 공백(복구 불가 갭이 있을 때 더한다).
  static const String resumeDataGap = 'RESUME_DATA_GAP';

  // ── 🆕 v1.27 SAF 경고 4 (01 §36 K189 · 04 §1 Level 3 · §5-3 v2.46 · 엔진 E3d `p0s_warn.dart` · 주문을 막지 않는다) ──────────
  /// 잠정 P1 · SAF-302 방어 자산(슬리브 C) 비중이 하한 밑 — 넘은 첫날 1건(엣지 · 머무는 동안 다시 내지 않는다 ·
  /// 엔진 `kDefensiveFloorAlertCode`).
  static const String defensiveFloorBreached = 'DEFENSIVE_FLOOR_BREACHED';

  /// 잠정 P1 · SAF-308 금 총비중이 감시선을 넘음 — 넘은 첫날 1건 · 강제 매도 0(엔진 `kGoldShareAlertCode`).
  static const String goldShareHigh = 'GOLD_SHARE_HIGH';

  /// 잠정 P1 · SAF-306 일반계좌 과세연도 금융소득 누계가 기준을 넘음 — 첫 초과 월 1건(월간 잡 · 엔진 `kFinancialIncomeAlertCode`).
  static const String financialIncomeCapExceeded =
      'FINANCIAL_INCOME_CAP_EXCEEDED';

  /// 잠정 P2 · SAF-307 부속 원화 유동성(원화 현금 + 파킹)이 하한 밑 — 넘은 첫날 1건(엔진 `kKrwLiquidityAlertCode`).
  /// 🔴 SAF-307 의 달러 노출 기준선 초과는 알림 코드가 없다 — 월간 리포트 `D2_ALLOCATION` 메모(01 §36 K192).
  static const String krwLiquidityLow = 'KRW_LIQUIDITY_LOW';

  // ── 🆕 v1.27 파생 동기 1 (01 §36 K188 · 04 §5-3 v2.45 · 엔진 E16 `derived_sync.dart` · E16i 의 알림 몫) ──────────
  /// 잠정 P0 · 사본(아카이브 등)이 원장과 갈라져 그 사본 쓰기를 멈춤 — 대상마다 1건(끈적) · 주문은 막지 않는다 ·
  /// 할 일 = X1 복원 또는 새 기준점(사람만 · 엔진 `kDerivedForkAlertCode`).
  static const String derivedFork = 'DERIVED_FORK';

  /// X7 안내 9종.
  static const Set<String> x7Advice = <String>{
    adviceIssued,
    adviceExitUrgent,
    adviceDueSoon,
    adviceExpired,
    adviceRevoked,
    adviceSuppressed,
    ledgerTrustDowngrade,
    selfAuditDue,
    manualFillRejected,
  };

  /// 집행 주체 전환 2종.
  static const Set<String> handover = <String>{
    handoverCoolingActive,
    handoverCommitted,
  };

  /// 자동 매매 11종.
  static const Set<String> autoTrade = <String>{
    orderRejected,
    orderOutcomeUnknown,
    reconMismatch,
    rebalanceD7,
    rebalanceD1,
    watchdogLate,
    brokerAuthFailed,
    dataSourceDown,
    backupStale,
    depositReminder,
    staleOrdersHeld,
  };

  /// 유지보수 창 2종.
  static const Set<String> maintenance = <String>{
    maintenanceWindowOverdue,
    maintenanceResumeFailed,
  };

  /// 운영 파라미터 1종.
  static const Set<String> operatingParam = <String>{contributionChanged};

  /// 🆕 v1.18 안전 3종.
  static const Set<String> safety = <String>{
    breakerStopped,
    ledgerIntegrityBroken,
    stoppedReleaseEligible,
  };

  /// 🆕 v1.18 재개 3종.
  static const Set<String> resume = <String>{
    resumeTradingHalted,
    resumeCompleted,
    resumeDataGap,
  };

  /// 🆕 v1.27 SAF 경고 4종.
  static const Set<String> safetyWarn = <String>{
    defensiveFloorBreached,
    goldShareHigh,
    financialIncomeCapExceeded,
    krwLiquidityLow,
  };

  /// 🆕 v1.27 파생 동기 1종.
  static const Set<String> derivedSync = <String>{derivedFork};

  /// 전량 36종.
  static const Set<String> values = <String>{
    ...x7Advice,
    ...handover,
    ...autoTrade,
    ...maintenance,
    ...operatingParam,
    ...safety,
    ...resume,
    ...safetyWarn,
    ...derivedSync,
  };
}
