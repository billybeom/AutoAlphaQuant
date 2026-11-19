// E11p4j — O-04 ③ 생체 서명 기록(설계 13 §8 R159) — 실 SQLite(sim 원장 · `command_inbox`).

import 'dart:io';

import 'package:core_engine/core_engine.dart' show kBiometricSignKind;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock, RunMode;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 19, 1);

void main() {
  late Directory dir;
  late Database sim;
  late SqliteBiometricSignStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11p4j_');
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    store = SqliteBiometricSignStore(sim, clock: _Clock(_t0));
  });

  tearDown(() {
    sim.close();
    dir.deleteSync(recursive: true);
  });

  test('🔴 처음 = 서명 없음 · 적으면 그 지문만 서명됨 · 실행 행 1(종류 · 저널 id · 지문 · 기기 시각)', () {
    expect(store.signed('d1'), isFalse);
    expect(
      store.record(commandId: 'c1', digest: 'd1', pledgeId: 'PL-1'),
      isTrue,
    );
    expect(store.signed('d1'), isTrue);
    expect(store.signed('d2'), isFalse);
    final Row r = sim.select(
      'SELECT * FROM command_inbox WHERE command_id = ?',
      <Object?>['c1'],
    ).single;
    expect(r['kind'], kBiometricSignKind);
    expect(r['state'], 'EXECUTED');
    expect(r['decision_id'], 'PL-1');
    expect(r['payload_digest'], 'd1');
    expect(r['ingested_at'], _t0.toIso8601String());
    expect(r['reject_reason_code'], isNull);
  });

  test('🔴 같은 지문 두 번 = 효과 0(false · 행 그대로)', () {
    store.record(commandId: 'c1', digest: 'd1', pledgeId: 'PL-1');
    expect(
      store.record(commandId: 'c2', digest: 'd1', pledgeId: 'PL-1'),
      isFalse,
    );
    expect(sim.select('SELECT COUNT(*) AS n FROM command_inbox').first['n'], 1);
  });

  test('🔴 다른 종류 · 거부 행은 서명이 아니다', () {
    sim.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, payload_digest) '
      "VALUES ('x', 'PLEDGE_WRITE', ?, 'EXECUTED', '실행됨', 'd1')",
      <Object?>[_t0.toIso8601String()],
    );
    sim.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, payload_digest) '
      "VALUES ('y', ?, ?, 'REJECTED', '거부됨', 'X', 'd2')",
      <Object?>[kBiometricSignKind, _t0.toIso8601String()],
    );
    expect(store.signed('d1'), isFalse);
    expect(store.signed('d2'), isFalse);
  });
}
