// X1 동결 리스 래퍼 · 기동 거부 원천(설계 13 §8 R132 N6~N8 · SPEC v2.45 04 §3-1 ①②).
//
// 🔴 주문 리스만 = core `orderLeaseDuringMigration`(동결 중 = INVALID) · 아카이브 · 파생 쓰기는 바탕 리스 그대로.
// 🔴 저널이 깨졌으면 닫힌 쪽(리스 = INVALID · 기동 = 거부).
// 🔴 「마지막 이전」 = 이 기기 · OLD_DEVICE 만(저널 저장소가 거른다).
// 🟡 기동 합성 = E16t.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show X1BootRefusalCodes;

import 'migration_journal_store.dart' show SqliteMigrationJournal;

/// 기동 거부 코드(글자 = 계약 `X1BootRefusalCodes` 참조 · 미결 212).
abstract final class MigrationBootCodes {
  /// DEMOTED 에 들어갔다 — 이 기기 엔진은 다시 서지 않는다.
  static const String demoted = X1BootRefusalCodes.demoted;

  /// 이전 저널이 깨졌다.
  static const String journalBroken = X1BootRefusalCodes.journalBroken;
}

/// 🔴 기동 거부 원천 — DEMOTED 들어감 = `X1_DEMOTED` · 저널 깨짐 = `X1_JOURNAL_BROKEN` · 그 밖 = null.
///
/// 잡만 막는다 — 이전 마법사는 끝까지 간다(R132 N8).
String? migrationBootRefusalOf(SqliteMigrationJournal journal) {
  final PlanProgress? p;
  try {
    p = journal.latestProgress();
  } on Object {
    return MigrationBootCodes.journalBroken;
  }
  return p != null && p.pastNoReturn ? MigrationBootCodes.demoted : null;
}

/// 🔴 주문용 리스 — 동결 중이면 INVALID · 저널 깨짐 = INVALID · 그 밖 = 바탕 리스.
class MigrationAwareLeaseGate implements LeaseGate {
  /// 만든다.
  MigrationAwareLeaseGate(this._base, this._journal);

  final LeaseGate _base;
  final SqliteMigrationJournal _journal;

  @override
  Future<LeaseVerdict> check() async {
    final LeaseVerdict base = await readLease(_base);
    final PlanProgress? p;
    try {
      p = _journal.latestProgress();
    } on Object {
      return LeaseVerdict.invalid;
    }
    return orderLeaseDuringMigration(base, p);
  }
}
