// E16s — 로컬 스키마 v1 의 SPEC v2.45 표(이전 저널 3표 · 정정 상세 · 설계 13 §8 R116 · 04 §3-1 v2.45).
//
// 🔵 잡는 것: ① 두 파일(live · sim) 모두 4표가 선다 ② CHECK(`kind` · `role` · `state` · `event` · epoch ≥ 0)가
//    실제 DB 에서 막는다 ③ `migration_step` 은 (run · step · state) 한 행(크래시 뒤 재개 멱등)
//    ④ FK — 없는 이전 · 없는 정정 = 거부 ⑤ `maintenance_window` 사건 id 한 행(넘김 창당 1 · 재개 실패 부팅당 1)
//    ⑥ `ledger_repair_detail` = `ledger_repair` 1:1 ⑦ 🔴 4표 모두 X5-1 해시 모집단 밖(16표 · 판 1 그대로).
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show LedgerHashTable, kLedgerHashPopulationV1;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

DateTime _clock() => DateTime.utc(2026, 12, 1, 9);

const List<String> _newTables = <String>[
  'ledger_repair_detail',
  'maintenance_window',
  'migration_run',
  'migration_step',
];

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('aaq_e16s_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Database open(RunMode mode) {
    final Database db = openLocalLedger(dir.path, mode, clock: _clock);
    addTearDown(db.close);
    return db;
  }

  bool accepts(
    Database db,
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) {
    try {
      db.execute(sql, args);
      return true;
    } on SqliteException {
      return false;
    }
  }

  const String insRun =
      'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)';
  const String insStep =
      'INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, ?, ?)';
  const String insWin =
      'INSERT INTO maintenance_window (event_id, window_id, run_id, event, checks_json, at) VALUES (?, ?, ?, ?, ?, ?)';
  const String insRepair =
      'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, evidence_hash, supersedes, applied_at) '
      "VALUES (?, 'ld-1', 'CANON_CORRECT', 'CHAIN_BROKEN', 'dec-9', 'h', NULL, '2026-12-01T09:00:00Z')";
  const String insDetail =
      'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) VALUES (?, ?, ?, ?, ?)';

  List<Object?> run(
    String id, {
    String kind = 'PLAN',
    String role = 'OLD_DEVICE',
    int epoch = 1,
  }) => <Object?>[
    id,
    kind,
    role,
    'dev-a',
    epoch,
    'dec-1',
    '2026-12-01T00:00:00Z',
  ];

  for (final RunMode mode in <RunMode>[RunMode.live, RunMode.simInternal]) {
    test('${mode.name} — 4표가 선다(sim 파일도 표는 있다 · 행 = live 만)', () {
      final Database db = open(mode);
      expect(
        db
            .select(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN "
              "('ledger_repair_detail', 'maintenance_window', 'migration_run', 'migration_step') ORDER BY name",
            )
            .map((Row r) => r['name'])
            .toList(),
        _newTables,
      );
      expect(
        db
            .select(
              "SELECT name FROM sqlite_master WHERE type = 'index' AND name IN "
              "('ix_migration_step_at', 'ix_maintenance_window_id') ORDER BY name",
            )
            .map((Row r) => r['name'])
            .toList(),
        <String>['ix_maintenance_window_id', 'ix_migration_step_at'],
      );
    });
  }

  test('migration_run — CHECK(kind · role · epoch ≥ 0) · run_id 한 행', () {
    final Database db = open(RunMode.live);
    expect(accepts(db, insRun, run('mig-2026-12-01-1')), isTrue);
    expect(
      accepts(
        db,
        insRun,
        run(
          'mig-2026-12-01-2',
          kind: 'EMERGENCY',
          role: 'NEW_DEVICE',
          epoch: 2,
        ),
      ),
      isTrue,
    );
    expect(
      accepts(db, insRun, run('mig-2026-12-01-1')),
      isFalse,
      reason: '같은 run_id',
    );
    expect(accepts(db, insRun, run('x1', kind: 'MANUAL')), isFalse);
    expect(accepts(db, insRun, run('x2', role: 'PHONE')), isFalse);
    expect(accepts(db, insRun, run('x3', epoch: -1)), isFalse);
    expect(
      accepts(db, insRun, <Object?>[
        'x4',
        'PLAN',
        'OLD_DEVICE',
        null,
        1,
        null,
        't',
      ]),
      isFalse,
      reason: 'device_id 없음',
    );
  });

  test('🔴 migration_step — (run · step · state) 한 행 · state CHECK · 없는 이전 = FK 거부', () {
    final Database db = open(RunMode.live);
    db.execute(insRun, run('mig-1'));
    expect(
      accepts(db, insStep, <Object?>['mig-1', 'FREEZE', 'ENTERED', null, 't1']),
      isTrue,
    );
    expect(
      accepts(db, insStep, <Object?>['mig-1', 'FREEZE', 'DONE', '{}', 't2']),
      isTrue,
    );
    expect(
      accepts(db, insStep, <Object?>['mig-1', 'FREEZE', 'ENTERED', null, 't3']),
      isFalse,
      reason: '크래시 뒤 다시 들어가도 같은 행 = 하나',
    );
    expect(
      accepts(db, insStep, <Object?>['mig-1', 'BACKUP', 'SKIPPED', null, 't']),
      isFalse,
    );
    expect(
      accepts(db, insStep, <Object?>[
        'mig-none',
        'FREEZE',
        'ENTERED',
        null,
        't',
      ]),
      isFalse,
    );
    expect(db.select('SELECT count(*) AS n FROM migration_step').first['n'], 2);
  });

  test('🔴 maintenance_window — 사건 CHECK · 사건 id 한 행(넘김 창당 1 · 재개 실패 부팅당 1) · 이전 밖 창 = run 없음', () {
    final Database db = open(RunMode.live);
    db.execute(insRun, run('mig-1'));
    expect(
      accepts(db, insWin, <Object?>[
        'mw-1:OPENED',
        'mw-1',
        'mig-1',
        'OPENED',
        '["kr_order"]',
        't',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-1:OVERDUE',
        'mw-1',
        'mig-1',
        'OVERDUE',
        null,
        't',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-1:OVERDUE',
        'mw-1',
        'mig-1',
        'OVERDUE',
        null,
        't2',
      ]),
      isFalse,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-1:RESUME_FAILED:b1',
        'mw-1',
        'mig-1',
        'RESUME_FAILED',
        null,
        't',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-1:RESUME_FAILED:b2',
        'mw-1',
        'mig-1',
        'RESUME_FAILED',
        null,
        't',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-2:OPENED',
        'mw-2',
        null,
        'OPENED',
        null,
        't',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-3:PAUSED',
        'mw-3',
        null,
        'PAUSED',
        null,
        't',
      ]),
      isFalse,
    );
    expect(
      accepts(db, insWin, <Object?>[
        'mw-4:OPENED',
        'mw-4',
        'mig-none',
        'OPENED',
        null,
        't',
      ]),
      isFalse,
    );
  });

  test('🔴 ledger_repair_detail — ledger_repair 1:1 · 없는 정정 = FK 거부', () {
    final Database db = open(RunMode.live);
    db.execute(insRepair, <Object?>['rp-1']);
    expect(
      accepts(db, insDetail, <Object?>[
        'rp-1',
        '2026-11-28',
        'ab' * 32,
        '{"rows":["ex-1"]}',
        '{"old":"x"}',
      ]),
      isTrue,
    );
    expect(
      accepts(db, insDetail, <Object?>['rp-1', null, null, null, null]),
      isFalse,
      reason: '1:1',
    );
    expect(
      accepts(db, insDetail, <Object?>['rp-none', null, null, null, null]),
      isFalse,
    );
  });

  test('🔴 4표 모두 X5-1 해시 모집단 밖 — 16표 · 판 1 그대로', () {
    final Set<String> population = <String>{
      for (final LedgerHashTable t in kLedgerHashPopulationV1) t.table,
    };
    expect(population, hasLength(16));
    for (final String t in _newTables) {
      expect(population.contains(t), isFalse, reason: t);
    }
    expect(population.contains('ledger_repair'), isFalse);
  });
}
