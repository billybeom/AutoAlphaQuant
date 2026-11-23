// 🆕 계약 v1.30(01 §38 · E16i 계약 창) — X5 정합 복구 · 새 기준점 · X1/X5 경계 · 파생 관계의 **엔진 글자 사전**.
//
// 🔴 타입 이름 ≠ 엔진(core `RepairCodes` · `BaselineCodes` · `BoundaryReason` · `DerivedRelation` — `ambiguous_import` 회피 K80).
// 🔴 화면은 이 글자로 분기 · 색 · 문구를 고르지 않는다 — 정정 마법사 VM · 경계 안내 = 다음 판(01 §8 미결 211).
// 🔴 같은 글자 다른 축(C-5 문서 쌍): [LedgerBoundaryReasonCodes.sqliteIntegrity] · [LedgerBoundaryReasonCodes.formatVersion] =
//    `LedgerIntegrityResultCodes` · [LedgerBoundaryReasonCodes.restoreRollback] = `OriginCodes.restoreRollback` ·
//    `BackupResultCodes.rollback`(v1.24 K140 예고 실현).

/// X5 정정 거부(도메인 `repair_result` · 엔진 core `repair/repair_plan.dart:49-79` 10).
abstract final class RepairResultCodes {
  /// 탐지 때 차이(diff)가 재대사에 없다(delta 가 바뀌었다).
  static const String deltaChanged = 'REPAIR_DELTA_CHANGED';

  /// 불변 스트림이 아닌 표.
  static const String targetNotImmutable = 'REPAIR_TARGET_NOT_IMMUTABLE';

  /// 이 방향 · 쌍에 쓸 수 없는 원인 코드.
  static const String originNotAllowed = 'REPAIR_ORIGIN_NOT_ALLOWED';

  /// 정본 정정인데 결정이 없다.
  static const String decisionRequired = 'REPAIR_DECISION_REQUIRED';

  /// 바뀌는 게 없다.
  static const String noChange = 'REPAIR_NO_CHANGE';

  /// 고를 차이가 OPEN `CANON_BROKER` 가 아니다.
  static const String diffNotOpen = 'REPAIR_DIFF_NOT_OPEN';

  /// 브로커 체결이 아니거나 없다.
  static const String fillNotBroker = 'REPAIR_FILL_NOT_BROKER';

  /// 주문이 아직 열려 있다(체결 동기가 누적을 다시 센다).
  static const String orderOpen = 'REPAIR_ORDER_OPEN';

  /// 정정 전 재생이 저장 포지션과 다르다.
  static const String positionDrift = 'REPAIR_POSITION_DRIFT';

  /// 정정 뒤 포지션이 중간에 음수가 된다.
  static const String positionNegative = 'REPAIR_POSITION_NEGATIVE';

  static const Set<String> values = <String>{
    deltaChanged,
    targetNotImmutable,
    originNotAllowed,
    decisionRequired,
    noChange,
    diffNotOpen,
    fillNotBroker,
    orderOpen,
    positionDrift,
    positionNegative,
  };
}

/// X5 새 기준점 거부(도메인 `baseline_result` · 엔진 core `repair/baseline_plan.dart:23-29` 2).
abstract final class BaselineResultCodes {
  /// 경계가 X5 가 아니다(X1 비상 경로 · 또는 깨끗함).
  static const String notX5 = 'BASELINE_NOT_X5';

  /// 첫 어긋난 날을 모른다.
  static const String firstBadDateUnknown = 'BASELINE_FIRST_BAD_DATE_UNKNOWN';

  static const Set<String> values = <String>{notX5, firstBadDateUnknown};
}

/// 🆕 v1.32(01 §41 · K257 · E16j-a) — 새 기준점 저장 쪽 거부(도메인 `baseline_apply_result` · data_sync `local/ledger_repair_store.dart:33-40`
/// `BaselineStoreCodes` 2 − 공용 `TRUSTED_TIME_UNKNOWN` · 🔴 타입 이름 ≠ 엔진). 정정 중 겹침(`LedgerFixBusy`)은 코드 0 — 구현이 «잠시 뒤 다시» 결과.
abstract final class BaselineApplyResultCodes {
  /// `LEDGER_INTEGRITY` 가 서 있지 않다.
  static const String flagNotSet = 'BASELINE_FLAG_NOT_SET';

  static const Set<String> values = <String>{flagNotSet};
}

/// 🆕 v1.35(01 §44 · K291 · 미결 217 ①) — X5 정정 원문 4칸(수량 · 가격 · 수수료 · 세금) 파싱 거부(도메인 `repair_input_result` ·
/// 엔진 core `repair/repair_wizard.dart` `RepairInputCodes` 1:1 · 🔴 타입 이름 ≠ 엔진 K80).
/// 🔴 [RepairResultCodes](엔진 `repair_plan` 판정 10 의 거울)에 넣지 않는다 — 축이 다르다(계획 판정 ↔ 원문 파싱 · 대조 한 벌씩).
/// 결과 `SafetyActionResult.reasonCode`(id = `REPAIR_CORRECT`)로만 나간다 · 화면은 분기 · 표시 0(`headline` 만).
abstract final class RepairInputResultCodes {
  /// 원문을 읽을 수 없다(빈칸 · 숫자 아님 · 범위 밖).
  static const String amountInvalid = 'REPAIR_AMOUNT_INVALID';

  static const Set<String> values = <String>{amountInvalid};
}

/// X1/X5 경계 사유(도메인 `ledger_boundary_reason` · 엔진 core `ops/ledger_boundary.dart:17-41` `BoundaryReason.wire` 8 ·
/// 나쁜 쪽이 이긴다 — 파일 → PRAGMA → 스탬프 사슬 → 아카이브 → 내용 → 형식 판 → 깨끗).
/// 🔴 X1 길 다섯([dbOpenFailed] · [sqliteIntegrity] · [stampChainBroken] · [restoreRollback] · [archiveDiverged])은 기동 거부 글자로도
///    나간다(data_sync `migration/x1_startup.dart:39-41` → FGS 머리말) · X5 길 = [contentMismatch] · [formatVersion] · 할 일 없음 = [clean].
abstract final class LedgerBoundaryReasonCodes {
  /// 원장 파일이 열리지 않았다.
  static const String dbOpenFailed = 'DB_OPEN_FAILED';

  /// `PRAGMA integrity_check` 가 ok 가 아니다.
  static const String sqliteIntegrity = 'SQLITE_INTEGRITY';

  /// 스탬프 사슬이 끊겼다.
  static const String stampChainBroken = 'STAMP_CHAIN_BROKEN';

  /// 정본이 아카이브보다 과거(아카이브 AHEAD).
  static const String restoreRollback = 'RESTORE_ROLLBACK';

  /// 아카이브와 갈라졌다.
  static const String archiveDiverged = 'ARCHIVE_DIVERGED';

  /// 지난 기록이 스탬프와 다르다.
  static const String contentMismatch = 'CONTENT_MISMATCH';

  /// 스탬프 형식 판이 다르다.
  static const String formatVersion = 'FORMAT_VERSION';

  /// 깨끗하다.
  static const String clean = 'CLEAN';

  static const Set<String> values = <String>{
    dbOpenFailed,
    sqliteIntegrity,
    stampChainBroken,
    restoreRollback,
    archiveDiverged,
    contentMismatch,
    formatVersion,
    clean,
  };
}

/// 파생(아카이브 · 뷰어) 관계(도메인 `derived_relation` · 엔진 core `ops/derived_sync.dart:210-231` `DerivedRelation.wire` 7 ·
/// FORK 알림 = `AlertCodes.derivedFork`).
abstract final class DerivedRelationCodes {
  /// 같다.
  static const String inSync = 'IN_SYNC';

  /// 파생이 비었다.
  static const String empty = 'EMPTY';

  /// 파생이 뒤처졌다(같은 사슬).
  static const String behind = 'BEHIND';

  /// 새 기준점 전 기록(재생성).
  static const String rebased = 'REBASED';

  /// 파생이 정본보다 앞섰다(FORK · RESTORE_ROLLBACK).
  static const String ahead = 'AHEAD';

  /// 갈라졌다(FORK).
  static const String diverged = 'DIVERGED';

  /// 더 새 기기의 기록(FORK).
  static const String epochAhead = 'EPOCH_AHEAD';

  static const Set<String> values = <String>{
    inSync,
    empty,
    behind,
    rebased,
    ahead,
    diverged,
    epochAhead,
  };
}
