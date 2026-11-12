// E14a — 운영 기기 리스 판정 · 봉인 · 파생 쓰기(설계 13 §8 R71 L3~L5).
//
// 🔵 잡는 것: ① 실물 전 = simInternal 유효 · live · simBroker 모름 ② 🔴 봉인이 먼저(실물이 유효여도 무효)
//    ③ 실물 있으면 그 판정(예외 = 모름) ④ 읽기 실패 = 모름 ⑤ 봉인 = 있는 행만 · 🔴 행을 만들지 않는다 · 한 번만
//    ⑥ 갱신 끊김 30분 경계 봉인 · 행 없음 · 갱신 기록 없음 = 아무것도 안 함 ⑦ 파생 쓰기 = 유효일 때만 ⑧ 오프셋 없는 시각.
import 'dart:io';

import 'package:core_engine/core_engine.dart' show LeaseVerdict;
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 13, 1);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_lease_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteLeaseGate gate(RunMode mode, {FakeLeaseGate? remote}) =>
      SqliteLeaseGate(db, mode: mode, clock: clock, remote: remote);

  void row(String status, {String? lastOk}) => db.execute(
    "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', ?, ?, 3, '2026-11-13T00:00:00.000Z')",
    <Object?>[lastOk, status],
  );

  List<Object?> supabase() => db
      .select(
        "SELECT status, updated_at, operator_epoch FROM sync_state WHERE target = 'SUPABASE'",
      )
      .single
      .values;

  test('실물 전 — simInternal = 유효(로컬 단독 리스) · live · simBroker = 모름', () async {
    expect(await gate(RunMode.simInternal).check(), LeaseVerdict.valid);
    expect(await gate(RunMode.live).check(), LeaseVerdict.unknown);
    expect(await gate(RunMode.simBroker).check(), LeaseVerdict.unknown);
  });

  test('🔴 봉인이 먼저 — 실물이 유효여도 · 로컬 단독 리스여도 무효', () async {
    row('SEALED');
    expect(await gate(RunMode.simInternal).check(), LeaseVerdict.invalid);
    expect(
      await gate(RunMode.live, remote: FakeLeaseGate()).check(),
      LeaseVerdict.invalid,
    );
  });

  test('실물 있으면 그 판정 · 예외 = 모름 · 봉인 아닌 행은 판정을 바꾸지 않는다', () async {
    row('OK', lastOk: '2026-11-13T00:50:00.000Z');
    expect(
      await gate(RunMode.live, remote: FakeLeaseGate()).check(),
      LeaseVerdict.valid,
    );
    expect(
      await gate(
        RunMode.simInternal,
        remote: FakeLeaseGate(LeaseVerdict.invalid),
      ).check(),
      LeaseVerdict.invalid,
    );
    expect(
      await gate(
        RunMode.live,
        remote: FakeLeaseGate()..throwing = Exception('x'),
      ).check(),
      LeaseVerdict.unknown,
    );
  });

  test('읽기 실패 = 모름', () async {
    db.execute('DROP TABLE sync_state');
    expect(await gate(RunMode.simInternal).check(), LeaseVerdict.unknown);
  });

  test('🔴 봉인 = 있는 행만(행을 만들지 않는다) · 한 번만 · 시각 = 기기 시계', () {
    final SqliteLeaseGate g = gate(RunMode.live);
    expect(g.seal(), isFalse);
    expect(db.select('SELECT 1 FROM sync_state'), isEmpty);
    row('OK', lastOk: '2026-11-13T00:50:00.000Z');
    expect(g.sealed(), isFalse);
    expect(g.seal(), isTrue);
    expect(supabase(), <Object?>['SEALED', _t0.toIso8601String(), 3]);
    expect(g.sealed(), isTrue);
    expect(g.seal(), isFalse);
  });

  test('갱신 끊김 — 29:59 = 그대로 · 30:00 = 봉인 · 행 없음 · 기록 없음 = 아무것도 안 함', () {
    final SqliteLeaseGate g = gate(RunMode.live);
    expect(g.sealIfStale(), isFalse);
    expect(db.select('SELECT 1 FROM sync_state'), isEmpty);
    row('OK');
    expect(g.sealIfStale(), isFalse);
    db.execute('DELETE FROM sync_state');
    row('OK', lastOk: '2026-11-13T00:30:01.000Z');
    expect(g.sealIfStale(), isFalse);
    expect(g.sealed(), isFalse);
    clock.at = DateTime.utc(2026, 11, 13, 1, 0, 1);
    expect(g.sealIfStale(), isTrue);
    expect(g.sealed(), isTrue);
  });

  test('파생 쓰기 = 리스 유효일 때만', () async {
    expect(await gate(RunMode.simInternal).derivedWritesAllowed(), isTrue);
    expect(await gate(RunMode.live).derivedWritesAllowed(), isFalse);
    row('SEALED');
    expect(await gate(RunMode.simInternal).derivedWritesAllowed(), isFalse);
  });

  test('오프셋 없는 시각 = 형식 오류', () {
    row('OK', lastOk: '2026-11-13T00:00:00');
    expect(gate(RunMode.live).sealIfStale, throwsFormatException);
  });
}
