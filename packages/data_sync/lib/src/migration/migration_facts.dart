// X1-2 이전 단계 사실(설계 13 §8 R135 P7 · core `PlanStepFacts` · `planStepBlockCode` · SPEC v2.45 04 §3-1 ②).
//
// 🔴 미체결 = 의도 RESERVED · SUBMITTING · SUBMITTED · PARTIAL(날 무관) · UNKNOWN = 따로 센다.
// 🔴 대사 = `RECON_MISMATCH` 활성이면 1(재개 child 전제와 같은 원천) · 지금 체인 = 마지막 스탬프(없으면 null).
// 🔴 백업 체인 = 넘긴 매니페스트만 — `SqliteLedgerSnapshotter.take` 를 통과한 스냅숏(검증 4중)의 것.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show FlagIds;
import 'package:sqlite3/sqlite3.dart';

int _count(Database db, String sql, [List<Object?> args = const <Object?>[]]) =>
    db.select(sql, args).single['n'] as int;

/// 🔴 이전 단계 사실 — [backup] = 검증된 스냅숏의 매니페스트(없음 = `BACKUP_MISSING`).
PlanStepFacts migrationPlanFactsOf(Database db, {BackupManifest? backup}) {
  final ResultSet head = db.select(
    'SELECT chain_hash FROM ledger_daily_hash ORDER BY authored_date DESC LIMIT 1',
  );
  return PlanStepFacts(
    openOrders: _count(
      db,
      'SELECT COUNT(*) AS n FROM order_intents '
      "WHERE status IN ('RESERVED', 'SUBMITTING', 'SUBMITTED', 'PARTIAL')",
    ),
    unknownOrders: _count(
      db,
      "SELECT COUNT(*) AS n FROM order_intents WHERE status = 'UNKNOWN'",
    ),
    reconMismatches: _count(
      db,
      'SELECT COUNT(*) AS n FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[FlagIds.reconMismatch],
    ),
    currentChainHash: head.isEmpty ? null : head.single['chain_hash'] as String,
    backupChainHash: backup?.chainHash,
  );
}
