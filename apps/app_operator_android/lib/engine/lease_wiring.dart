// 리스 판정 조립 자리 하나(E11k-e3 · 설계 13 §8 R229 F8 · R215 ④ · R70 D8 · R71 L3).
//
// 🔴 실전(live) · 브로커 모의(simBroker)만 원격 리스(Supabase RPC — `SupabaseLeaseGate`) · `simInternal` = 로컬 단독 리스 그대로
//    (remote 0 · 망 0). 원격 원천이 없으면(기기 id · 조립 없음 · 시험) 지금과 같다 — live · simBroker = 모름(막는다).
// 🔴 판정 차례는 `SqliteLeaseGate` 가 지킨다 — 봉인 먼저 → 원격.
// 🔴 `epoch()` 만 읽는 자리(명령 맥락 · 백업 · 전환 세션)는 원격과 같은 `sync_state` SUPABASE 행을 읽으므로 이 함수를 거치지 않아도 된다.

import 'package:core_engine/core_engine.dart' show LeaseGate;
import 'package:data_sync/data_sync.dart' show SqliteLeaseGate;
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

/// 원장 하나 → 원격 리스 판정(없음 = null).
typedef LeaseRemoteOf = LeaseGate? Function(Database db);

/// 🔴 원격을 끼우는 모드인가(망라 — 값이 늘면 컴파일이 깨진다).
bool leaseRemoteApplies(RunMode mode) => switch (mode) {
  RunMode.simInternal => false,
  RunMode.simBroker || RunMode.live => true,
};

/// 🔴 리스 판정 하나 — [remote] = 조립 앱의 원격 원천(없음 = 실물 전과 같다).
SqliteLeaseGate operatorLeaseGate(
  Database db, {
  required RunMode mode,
  required Clock clock,
  LeaseRemoteOf? remote,
}) => SqliteLeaseGate(
  db,
  mode: mode,
  clock: clock,
  remote: remote != null && leaseRemoteApplies(mode) ? remote(db) : null,
);
