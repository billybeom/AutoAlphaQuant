// 🆕 미결 249(설계 13 §8 R279) · 243 ⓓ(R276) — 닫힌 원장 판정 한 곳(계약 v1.39 K347 · 13 R261 H5).
//
// 🔴 뜻 = [db] 가 닫힌(CLOSE) 원장인가 — simToAuto 커밋으로 CLOSE 된 모의 원장(커밋 ~ 깨어남 끝 몇 초 틈 · CLOSE 행 = 모의 파일만).
// 🔴 판정 = 엔진 정본 `SqliteModeStore.closed()`(파일 = 원장의 `application_id` — 모의 · 실전 둘 중 하나) · 명령 창구 · 안전 동작 ·
//    설정 동작이 같이 쓴다(글자 · 결과 = 엔진 `ledger_write_gate.dart`).

import 'package:data_sync/data_sync.dart' show SqliteModeStore;
import 'package:domain_contracts/domain_contracts.dart' show Clock, LedgerFile;
import 'package:sqlite3/sqlite3.dart' show Database;

/// 🔴 [db] 가 닫힌(CLOSE) 원장인가.
bool operatorLedgerClosed(Database db, {required Clock clock}) {
  final Object? appId = db.select('PRAGMA application_id').first.values.first;
  final LedgerFile file = appId == LedgerFile.sim.applicationId
      ? LedgerFile.sim
      : LedgerFile.live;
  return SqliteModeStore(db, file, clock: clock).closed();
}
