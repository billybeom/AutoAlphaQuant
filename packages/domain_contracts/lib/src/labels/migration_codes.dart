// 🆕 계약 v1.30(01 §38 · K209~ · E16i 계약 창) — X1 기기 이전 · 새 폰 복구 · 감시 유지보수 창의 **엔진 글자 사전**.
//
// 엔진(E16b~E16t3a)이 «계약 등재 = E16i 전 문자열»로 이미 쓰는 거부 · 막음 · 단계 · 상태 글자를 1:1 로 등재한다.
// 🔴 타입 이름 ≠ 엔진(core `MigrationStartCodes` · `PlanBlockCodes` · `FencingCodes` · `ReissueCodes` · `ReissueItem` ·
//    `RecoverySealCodes` · `MigrationGateCodes` · `PlanStep` · `MigrationStepState` · `MigrationKind` · `MigrationRole` ·
//    `RecoveryStep` · `MigrationGateState` · `GapViolationKind` · `WindowEvent` · data_sync `MigrationStoreCodes` ·
//    `MigrationBootCodes` · `RecoveryCodes` · `WindowStoreCodes` · `LedgerRestoreCodes` — 같으면 엔진 시험이 두 배럴을 함께
//    import 해 `ambiguous_import` · v1.21 K33 · v1.23 K80 결). 엔진이 계약 참조로 옮길 때 지역 선언을 지운다(엔진 숙제).
// 🔴 공용 `TRUSTED_TIME_UNKNOWN` 은 싣지 않는다 — `SafetyCommonResultCodes` 한 벌(K45). 이전 시작 · 펜싱 · 재발급 · 유지보수 창
//    거부 전집 = 이 사전 ∪ 공용.
// 🔴 이 글자로 화면이 분기 · 아이콘 · 색 · 문구를 고르지 않는다 — 문구 · 레벨 · 단계 표시는 엔진이 VM 에 실어 준다(E16j 화면 계약 =
//    다음 판 · 01 §8 미결 211). 이 사전의 쓰임 = 픽스처 · 엔진 대조(C-63) · 미등록 코드 조기 실패.
// 🔴 수치 0 — 관찰 일수 · 넘김 시간 · 펜싱 마진 · 재생성 상한 = 엔진 운영 설정 `operations.migration`(⬜ 발주자 수치 · 잠정) 그대로.

/// 이전 시작 거부(도메인 `x1_start_result` · 엔진 core `migration/migration_plan.dart:112-127` 5 − 공용 1).
/// 🔴 [liveOnly] = `BackupResultCodes.liveOnly` 와 같은 글자 다른 축(C-5 문서 쌍 · v1.24 K140 예고 실현).
abstract final class X1StartResultCodes {
  /// live 파일이 아니다(체험 중 폰 교체 = 모의 폐기 + 새 개시).
  static const String liveOnly = 'X1_LIVE_ONLY';

  /// 안내 모드 기기 이전 = 조건 결정 대기.
  static const String advisoryPending = 'X1_ADVISORY_PENDING';

  /// 계획 교체인데 `D-03` 확인 결정이 없다.
  static const String d03NotConfirmed = 'D03_NOT_CONFIRMED';

  /// 비상인데 선언 결정이 없다.
  static const String emergencyNotDeclared = 'EMERGENCY_NOT_DECLARED';

  static const Set<String> values = <String>{
    liveOnly,
    advisoryPending,
    d03NotConfirmed,
    emergencyNotDeclared,
  };
}

/// 계획 교체 단계 막음(도메인 `x1_step_block` · 엔진 core `migration_plan.dart:348-363` 5).
/// 🔴 [unknownOrders] = `ResumeItemReasonCodes.unknownOrders` 와 같은 글자 다른 축(C-5 문서 쌍).
abstract final class X1StepBlockCodes {
  /// 미체결 주문이 남았다.
  static const String openOrders = 'OPEN_ORDERS_REMAIN';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'UNKNOWN_ORDERS_REMAIN';

  /// 최종 대사가 0오차가 아니다.
  static const String reconNotZero = 'RECON_NOT_ZERO';

  /// 체크섬 백업이 없다.
  static const String backupMissing = 'BACKUP_MISSING';

  /// 백업 매니페스트 체인이 지금 체인과 다르다.
  static const String backupChainMismatch = 'BACKUP_CHAIN_MISMATCH';

  static const Set<String> values = <String>{
    openOrders,
    unknownOrders,
    reconNotZero,
    backupMissing,
    backupChainMismatch,
  };
}

/// 이전 저널 저장 거부(도메인 `x1_journal_result` · 엔진 data_sync `migration/migration_journal_store.dart:22-31` 3).
abstract final class X1JournalResultCodes {
  /// 이 파일에 진행 중인 이전이 이미 있다.
  static const String runExists = 'X1_RUN_EXISTS';

  /// 단계 차례가 어긋났다.
  static const String stepOutOfOrder = 'X1_STEP_OUT_OF_ORDER';

  /// 되돌릴 수 없는 점(DEMOTED)을 지났다.
  static const String pastNoReturn = 'X1_PAST_NO_RETURN';

  static const Set<String> values = <String>{
    runExists,
    stepOutOfOrder,
    pastNoReturn,
  };
}

/// 이전 기동 거부(도메인 `x1_boot_refusal` · 엔진 data_sync `migration/migration_lease_gate.dart:13-19` 2).
/// 🔴 기동 거부 전집(data_sync `migration/x1_startup.dart:39-49`) = 이 사전 ∪ X1 길 경계 사유([LedgerBoundaryReasonCodes] 가운데
///    `DB_OPEN_FAILED` · `SQLITE_INTEGRITY` · `STAMP_CHAIN_BROKEN` · `RESTORE_ROLLBACK` · `ARCHIVE_DIVERGED`).
abstract final class X1BootRefusalCodes {
  /// 이 기기는 강등됐다(DEMOTED 들어감).
  static const String demoted = 'X1_DEMOTED';

  /// 이전 저널을 읽을 수 없다.
  static const String journalBroken = 'X1_JOURNAL_BROKEN';

  static const Set<String> values = <String>{demoted, journalBroken};
}

/// 새 폰 복원 검증 · 적용 거부 중 v1.24 에 없던 몫(도메인 `x1_restore_result` · 엔진 core `migration/backup_manifest.dart:137-160`
/// `RestoreReason` 7 가운데 2 + data_sync `migration/ledger_restore.dart:21-24` 1).
/// 🔴 복원 거부 전집 = 이 사전 ∪ `BackupResultCodes` 의 `liveOnly` · `unreadable` · `schemaSkew` · `sqliteIntegrity` ·
///    `chainInvalid` · `rollback`(같은 엔진 상수 = 한 벌 · v1.24 K132 나눔을 잇는다 — 두 번 등재하지 않는다).
abstract final class X1RestoreResultCodes {
  /// 사본 sha256 이 매니페스트와 다르다.
  static const String shaMismatch = 'RESTORE_SHA_MISMATCH';

  /// 사본 머리가 매니페스트와 다르다.
  static const String manifestMismatch = 'RESTORE_MANIFEST_MISMATCH';

  /// 이 폰에 live 원장이 이미 있다(같은 폰 복원 금지 · 덮지 않는다).
  static const String liveExists = 'X1_LIVE_EXISTS';

  static const Set<String> values = <String>{
    shaMismatch,
    manifestMismatch,
    liveExists,
  };
}

/// 비상 펜싱 대기(도메인 `x1_fencing_result` · 엔진 core `migration/fencing.dart:44-53` 3 − 공용 1).
abstract final class X1FencingResultCodes {
  /// REVOKED 가 아직 없다(대기 시작 전).
  static const String notStarted = 'FENCING_NOT_STARTED';

  /// 펜싱 대기 중(끝 시각 = 엔진 · 마진 = ⬜ 발주자 수치).
  static const String waiting = 'FENCING_WAIT';

  static const Set<String> values = <String>{notStarted, waiting};
}

/// 비상 재발급 거부(도메인 `x1_reissue_result` · 엔진 core `migration/reissue_checklist.dart:43-61` 6 − 공용 1).
abstract final class X1ReissueResultCodes {
  /// 새 값의 지문이 옛 지문 가운데 하나다(보관한 옛 문자열 재입력 0).
  static const String keyReused = 'KEY_REUSED';

  /// 이 항목은 «해당 없음»으로 둘 수 없다(KIS 앱키 = 늘 필수).
  static const String notApplicable = 'REISSUE_NOT_APPLICABLE';

  /// 이미 기록한 항목이다.
  static const String duplicate = 'REISSUE_DUPLICATE';

  /// 값이 있는 항목인데 새 지문이 없다.
  static const String fingerprintRequired = 'REISSUE_FINGERPRINT_REQUIRED';

  /// 값이 없는 항목(철회 · 재로그인 확인)인데 지문이 왔다.
  static const String fingerprintUnexpected = 'REISSUE_FINGERPRINT_UNEXPECTED';

  static const Set<String> values = <String>{
    keyReused,
    notApplicable,
    duplicate,
    fingerprintRequired,
    fingerprintUnexpected,
  };
}

/// 비상 재발급 항목(도메인 `x1_reissue_item` · 엔진 core `reissue_checklist.dart:11-29` `ReissueItem.wire` 6 · 차례 = 06 X1-3).
/// 🔴 항목 문구(«증권사 앱키» 등)는 엔진 글자 — 계약은 싣지 않는다(VM = 다음 판).
abstract final class X1ReissueItemCodes {
  /// KIS 앱키(새 키 지문 · 늘 필수).
  static const String kisAppKey = 'KIS_APP_KEY';

  /// 메신저 토큰.
  static const String messengerToken = 'MESSENGER_TOKEN';

  /// 워치독 핑 키.
  static const String watchdogPingKey = 'WATCHDOG_PING_KEY';

  /// GitHub PAT.
  static const String githubPat = 'GITHUB_PAT';

  /// 원격 세션 철회(값 없음 — 확인만).
  static const String supabaseSession = 'SUPABASE_SESSION';

  /// 옛 기기 Google 액세스 철회(값 없음 — 확인만).
  static const String googleAccess = 'GOOGLE_ACCESS';

  /// 차례 = 엔진 선언 차례(06 X1-3).
  static const List<String> ordered = <String>[
    kisAppKey,
    messengerToken,
    watchdogPingKey,
    githubPat,
    supabaseSession,
    googleAccess,
  ];

  static const Set<String> values = <String>{
    kisAppKey,
    messengerToken,
    watchdogPingKey,
    githubPat,
    supabaseSession,
    googleAccess,
  };
}

/// 새 폰 복구 저널 거부(도메인 `x1_recovery_result` · 엔진 data_sync `migration/recovery_journal_store.dart:21-27` 2).
abstract final class X1RecoveryResultCodes {
  /// 아직 복원(RESTORED)하지 않았다.
  static const String notRestored = 'X1_NOT_RESTORED';

  /// 리스 epoch 가 매니페스트보다 앞서지 않았다.
  static const String epochNotAdvanced = 'X1_EPOCH_NOT_ADVANCED';

  static const Set<String> values = <String>{notRestored, epochNotAdvanced};
}

/// 새 폰 복구 주문 봉인(도메인 `x1_order_seal` · 엔진 core `migration/gap_rebuild.dart:393-399` 2 ·
/// 앱 `engine/x1_wiring.dart:20` `X1OrderSealed(code)` 의 code).
abstract final class X1OrderSealCodes {
  /// 갭 재구성이 끝나지 않았다 — 주문 봉인.
  static const String inProgress = 'X1_RECOVERY_IN_PROGRESS';

  /// RECOVERY_FULL — 사람의 R-01 «잔고 승계 새 시작»까지 안전 정지.
  static const String full = 'X1_RECOVERY_FULL';

  static const Set<String> values = <String>{inProgress, full};
}

/// X1-5 LIVE 재개 게이트 막음(도메인 `x1_gate_reason` · 엔진 core `migration/migration_gate.dart:62-86` 8).
abstract final class X1GateReasonCodes {
  /// 골든 자가검사 아직.
  static const String goldenNotRun = 'X1_GOLDEN_NOT_RUN';

  /// 골든 자가검사 실패.
  static const String goldenFailed = 'X1_GOLDEN_FAILED';

  /// 대사가 0오차가 아니다.
  static const String reconNotZero = 'X1_RECON_NOT_ZERO';

  /// 결과 모름(UNKNOWN) 주문이 남았다.
  static const String unknownOrders = 'X1_UNKNOWN_ORDERS_REMAIN';

  /// 미체결 주문이 남았다.
  static const String openOrders = 'X1_OPEN_ORDERS_REMAIN';

  /// 관찰 중(n/m · 관찰 일수 = ⬜ 발주자 수치).
  static const String observing = 'X1_OBSERVING';

  /// 체크리스트 확인 대기.
  static const String checklistPending = 'X1_CHECKLIST_PENDING';

  /// 생체 확인 대기.
  static const String biometricPending = 'X1_BIOMETRIC_PENDING';

  static const Set<String> values = <String>{
    goldenNotRun,
    goldenFailed,
    reconNotZero,
    unknownOrders,
    openOrders,
    observing,
    checklistPending,
    biometricPending,
  };
}

/// 감시 유지보수 창 열기 거부(도메인 `maintenance_window_result` · 엔진 data_sync
/// `migration/maintenance_window_store.dart:19-25` 2 − 공용 1).
abstract final class MaintenanceWindowResultCodes {
  /// 이미 열린 창이 있다.
  static const String alreadyOpen = 'MW_ALREADY_OPEN';

  static const Set<String> values = <String>{alreadyOpen};
}

/// 복구 주문 의도 표지(도메인 `x1_intent_reason` · 엔진 core `migration/gap_rebuild.dart:40` `kX1RecoveredReason` ·
/// `order_intents.error_message` — 갭 재구성이 지은 의도 · authored = 복구).
abstract final class X1IntentReasonCodes {
  /// 새 폰 복구가 지은 의도.
  static const String recovered = 'X1_RECOVERED';

  static const Set<String> values = <String>{recovered};
}

// ── 열거 글자(와이어 · 저장 값) ─────────────────────────────────────────────

/// 옛 폰 계획 교체 단계(도메인 `x1_plan_step` · 엔진 core `migration_plan.dart:68-95` `PlanStep.wire` 9 · `migration_step.step`).
abstract final class X1StepCodes {
  /// 신규 주문 동결.
  static const String freeze = 'FREEZE';

  /// 미체결 0 ∧ UNKNOWN 0.
  static const String ordersCleared = 'ORDERS_CLEARED';

  /// 최종 대사 0오차.
  static const String reconZero = 'RECON_ZERO';

  /// 체크섬 백업.
  static const String backupChecksum = 'BACKUP_CHECKSUM';

  /// 🔴 로컬 강등 표시 — 되돌릴 수 없는 점.
  static const String demoted = 'DEMOTED';

  /// 키 삭제.
  static const String keysDeleted = 'KEYS_DELETED';

  /// RETIRED 서명.
  static const String retired = 'RETIRED';

  /// 서비스 종료.
  static const String serviceStopped = 'SERVICE_STOPPED';

  /// 이전 티켓 발급(강등 끝난 뒤에만).
  static const String ticketIssued = 'TICKET_ISSUED';

  /// 차례 = 엔진 선언 차례(R117 B3).
  static const List<String> ordered = <String>[
    freeze,
    ordersCleared,
    reconZero,
    backupChecksum,
    demoted,
    keysDeleted,
    retired,
    serviceStopped,
    ticketIssued,
  ];

  static const Set<String> values = <String>{
    freeze,
    ordersCleared,
    reconZero,
    backupChecksum,
    demoted,
    keysDeleted,
    retired,
    serviceStopped,
    ticketIssued,
  };
}

/// 이전 단계 행 상태(도메인 `x1_step_state` · 엔진 core `migration_plan.dart:45-54` `MigrationStepState.wire` 3 ·
/// `migration_step.state`).
/// 🔴 [failed] = `KillCancelOutcomeCodes.failed` 와 같은 글자 다른 축(C-5 문서 쌍).
abstract final class X1StepStateCodes {
  /// 들어감.
  static const String entered = 'ENTERED';

  /// 끝남.
  static const String done = 'DONE';

  /// 실패(DEMOTED 앞에서만).
  static const String failed = 'FAILED';

  static const Set<String> values = <String>{entered, done, failed};
}

/// 이전 갈래(도메인 `x1_kind` · 엔진 core `migration_plan.dart:17-23` `MigrationKind.wire` 2 · `migration_run.kind`).
abstract final class X1KindCodes {
  /// 계획 교체(옛 폰이 옆에 있다).
  static const String plan = 'PLAN';

  /// 비상(옛 폰을 잃었다).
  static const String emergency = 'EMERGENCY';

  static const Set<String> values = <String>{plan, emergency};
}

/// 이 파일 기기의 이전 역할(도메인 `x1_role` · 엔진 core `migration_plan.dart:31-37` `MigrationRole.wire` 2 ·
/// `migration_run.role`).
abstract final class X1RoleCodes {
  /// 옛 폰.
  static const String oldDevice = 'OLD_DEVICE';

  /// 새 폰.
  static const String newDevice = 'NEW_DEVICE';

  static const Set<String> values = <String>{oldDevice, newDevice};
}

/// 새 폰 복구 단계(도메인 `x1_recovery_step` · 엔진 core `migration/recovery_steps.dart:7-22` `RecoveryStep.wire` 5).
abstract final class X1RecoveryStepCodes {
  /// 백업 복원.
  static const String restored = 'RESTORED';

  /// 갭 재구성 끝.
  static const String gapRebuilt = 'GAP_REBUILT';

  /// 골든 자가 시험.
  static const String goldenSelfTest = 'GOLDEN_SELF_TEST';

  /// 체크리스트 확인.
  static const String checklistConfirmed = 'CHECKLIST_CONFIRMED';

  /// 생체 확인.
  static const String biometricConfirmed = 'BIOMETRIC_CONFIRMED';

  /// 차례 = 엔진 선언 차례.
  static const List<String> ordered = <String>[
    restored,
    gapRebuilt,
    goldenSelfTest,
    checklistConfirmed,
    biometricConfirmed,
  ];

  static const Set<String> values = <String>{
    restored,
    gapRebuilt,
    goldenSelfTest,
    checklistConfirmed,
    biometricConfirmed,
  };
}

/// X1-5 LIVE 재개 게이트 상태(도메인 `x1_gate_state` · 엔진 core `migration_gate.dart:42-54` `MigrationGateState.wire` 4).
/// 🔴 [blocked] = `VerdictCodes.blocked` · [observing] = `ResumeItemReasonCodes.observing` · [passed] =
///    `SimTrialItemStateCodes.passed` 와 같은 글자 다른 축(C-5 문서 쌍 셋). 관찰 n/m = 엔진 글자(다음 판 VM).
abstract final class X1GateStateCodes {
  /// 막힘(매매 없는 안전 정지 그대로 · 막음 코드 = [X1GateReasonCodes]).
  static const String blocked = 'BLOCKED';

  /// 관찰 중(dryRun).
  static const String observing = 'OBSERVING';

  /// 승인 대기(체크리스트 → 생체).
  static const String awaitingApproval = 'AWAITING_APPROVAL';

  /// 통과(LIVE 재개 가능).
  static const String passed = 'PASSED';

  static const Set<String> values = <String>{
    blocked,
    observing,
    awaitingApproval,
    passed,
  };
}

/// 갭 재구성 위반(도메인 `x1_gap_violation` · 엔진 core `migration/gap_rebuild.dart:275-284` `GapViolationKind.wire` 3 ·
/// 위반 = 대사 차단 · «봇 전용 계좌» 위반).
abstract final class X1GapViolationCodes {
  /// 복원 보유 + 갭 체결 ≠ 브로커 보유.
  static const String holdingMismatch = 'GAP_HOLDING_MISMATCH';

  /// 보유보다 많이 팔았다(중간 음수).
  static const String oversold = 'GAP_OVERSOLD';

  /// 전략 대응이 없다(복구 의도를 지을 수 없다).
  static const String unmappedStrategy = 'GAP_UNMAPPED_STRATEGY';

  static const Set<String> values = <String>{
    holdingMismatch,
    oversold,
    unmappedStrategy,
  };
}

/// 감시 유지보수 창 사건(도메인 `maintenance_window_event` · 엔진 core `migration/maintenance_window.dart:15-27`
/// `WindowEvent.wire` 4). 알림 = `AlertCodes.maintenanceWindowOverdue` · `maintenanceResumeFailed`(다른 글자 · 겹침 0).
abstract final class MaintenanceWindowEventCodes {
  /// 열림(감시 일시정지).
  static const String opened = 'OPENED';

  /// 넘김(P1 · 창당 1건 · 넘김 시간 = ⬜ 발주자 수치).
  static const String overdue = 'OVERDUE';

  /// 닫힘(감시 재개).
  static const String closed = 'CLOSED';

  /// 부팅 때 재개 실패(P0 · 부팅당 1건).
  static const String resumeFailed = 'RESUME_FAILED';

  static const Set<String> values = <String>{
    opened,
    overdue,
    closed,
    resumeFailed,
  };
}
