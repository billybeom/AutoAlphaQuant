// X1 · X5 기동 합성 원천(설계 13 §8 R139 U2 · U3 · SPEC v2.45 04 §3-1 ②⑥ · 지도 e16-map E16t).
//
// 🔴 거부(나쁜 쪽 먼저) = 경계 X1 비상(원장 파일을 믿을 수 없다 — 자동 기동 0) → 옛 폰 DEMOTED · 저널 깨짐.
// 🔴 X5 정정 길 = 거부 아님(정정 마법사는 기동해야 연다 · 주문은 `LEDGER_INTEGRITY` 가 막는다).
// 🔴 주문 봉인 = 새 폰 복구가 있고 갭 재구성 전 = `X1_RECOVERY_IN_PROGRESS`(RECOVERY_FULL = 재개 E14 가 이미 건다) ·
//    복구 저널이 깨졌으면 = 거부 `X1_JOURNAL_BROKEN` + 봉인(닫힌 쪽).
// 🟡 앱 배선(`bootEngine` 거부 · 주문 잡 preGuard) = E16t2 · 경계 재료(무결성 · 아카이브 관계)는 부르는 쪽.

import 'package:core_engine/core_engine.dart'
    show BoundaryPath, LedgerBoundaryVerdict, RecoverySealCodes;
import 'package:sqlite3/sqlite3.dart';

import 'migration_journal_store.dart' show SqliteMigrationJournal;
import 'migration_lease_gate.dart'
    show MigrationBootCodes, migrationBootRefusalOf;
import 'recovery_journal_store.dart' show gapRebuildDoneOf;

/// 기동 합성 결과.
class X1Startup {
  /// 만든다.
  const X1Startup({required this.refusals, required this.orderSeal});

  /// 기동 거부 코드(나쁜 쪽 먼저 · 겹침 없음 · 비면 기동 가능).
  final List<String> refusals;

  /// 주문 봉인 코드(없음 = null) — 주문 잡 앞에서 거부한다.
  final String? orderSeal;

  /// 기동해도 되나.
  bool get mayStart => refusals.isEmpty;
}

/// 🔴 기동 합성 — [journal] = 이 기기 이전 저널(옛 폰 쪽 · 기기 id 도 여기서) · [boundary] = 경계 판정(없음 = 모름 → 보지 않는다).
X1Startup x1StartupOf(
  Database db,
  SqliteMigrationJournal journal, {
  LedgerBoundaryVerdict? boundary,
}) {
  final Set<String> refusals = <String>{
    if (boundary != null && boundary.path == BoundaryPath.x1Emergency)
      boundary.reason.wire,
  };
  final String? migration = migrationBootRefusalOf(journal);
  if (migration != null) refusals.add(migration);
  bool rebuilt;
  try {
    rebuilt = gapRebuildDoneOf(db, journal.deviceId);
  } on StateError {
    refusals.add(MigrationBootCodes.journalBroken);
    rebuilt = false;
  }
  return X1Startup(
    refusals: List<String>.unmodifiable(refusals),
    orderSeal: rebuilt ? null : RecoverySealCodes.inProgress,
  );
}
