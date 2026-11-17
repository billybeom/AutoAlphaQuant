// E16t2a — X1 끼울 자리(설계 13 §8 R141 V2~V6).
//
// 🔵 잡는 것: ① 꺼짐(기기 id null · live 아님) = 지금과 같다(거부 0 · 감싸기 0 · 갭 null · 봉인 0)
//    ② 켜짐 — 옛 폰 DEMOTED = 기동 거부 + 주문 리스 INVALID · 새 폰 재구성 전 = 주문 봉인 · 백업 갭 = 복원 시각 기준
//    ③ `bootEngine` — X1 거부를 기동 판정 뒤에 겹침 없이 이어 붙인다 · 기기 id 없음 = 그대로 · 모의 = X1 밖.
import 'dart:io';

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/x1_wiring.dart';
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart' show FakeLeaseGate;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'support.dart';

class _Trusted implements TrustedClock {
  @override
  DateTime? trustedNowUtc() => null;
}

void main() {
  final FakeClock clock = FakeClock(kst(2026, 11, 16, 9, 30));

  void run(Database db, String id, String role, String at) => db.execute(
    'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
    "VALUES (?, 'PLAN', ?, 'dev-1', 1, 'd', ?)",
    <Object?>[id, role, at],
  );

  void step(Database db, String id, String s, String state, String at) =>
      db.execute(
        'INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, NULL, ?)',
        <Object?>[id, s, state, at],
      );

  void demoted(Database db) {
    run(db, 'mig-1', 'OLD_DEVICE', '2026-11-15T01:00:00.000Z');
    int m = 0;
    String at() => '2026-11-15T01:${(m++).toString().padLeft(2, '0')}:00.000Z';
    for (final String s in <String>[
      'FREEZE',
      'ORDERS_CLEARED',
      'RECON_ZERO',
      'BACKUP_CHECKSUM',
    ]) {
      step(db, 'mig-1', s, 'ENTERED', at());
      step(db, 'mig-1', s, 'DONE', at());
    }
    step(db, 'mig-1', 'DEMOTED', 'ENTERED', at());
  }

  void restored(Database db) {
    run(db, 'mig-2', 'NEW_DEVICE', '2026-11-16T01:00:00.000Z');
    db.execute(
      "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES ('mig-2', 'RESTORED', 'DONE', ?, ?)",
      <Object?>[
        BackupManifest(
          sha256: 'a' * 64,
          chainHash: 'b' * 64,
          authoredDate: '2026-11-12',
          schemaVersion: 1,
          hashFormatVersion: 1,
          operatorEpoch: 0,
          writerDeviceId: 'dev-0',
        ).toCanonicalJson(),
        '2026-11-16T01:00:00.000Z',
      ],
    );
  }

  group('X1Wiring', () {
    late Directory dir;
    late Database live;
    setUp(() {
      dir = tempLedgerDir();
      live = openLocalLedger(dir.path, RunMode.live, clock: clock.nowUtc);
      addTearDown(live.close);
    });

    X1Wiring wiring({
      String? device = 'dev-1',
      RunMode mode = RunMode.live,
      Database? db,
    }) => X1Wiring.of(
      db ?? live,
      runMode: mode,
      deviceId: device,
      trusted: _Trusted(),
      lease: SqliteLeaseGate(db ?? live, mode: mode, clock: clock),
    );

    test('🔴 꺼짐(기기 id 없음 · live 아님) = 지금과 같다', () async {
      demoted(live);
      restored(live);
      final LeaseGate base = FakeLeaseGate();
      for (final X1Wiring w in <X1Wiring>[
        wiring(device: null),
        wiring(mode: RunMode.simInternal),
      ]) {
        expect(w.on, isFalse);
        expect(w.journal, isNull);
        expect(w.bootRefusals(), isEmpty);
        expect(identical(w.orderLease(base), base), isTrue);
        expect(w.backupGapDays(), isNull);
        w.checkOrderSeal();
      }
    });

    test('켜짐 · 깨끗함 = 거부 0 · 갭 null · 봉인 0 · 리스 = 바탕 판정', () async {
      final X1Wiring w = wiring();
      expect(w.on, isTrue);
      expect(w.journal!.deviceId, 'dev-1');
      expect(w.bootRefusals(), isEmpty);
      expect(w.backupGapDays(), isNull);
      w.checkOrderSeal();
      final LeaseGate wrapped = w.orderLease(FakeLeaseGate());
      expect(wrapped, isA<MigrationAwareLeaseGate>());
      expect(await wrapped.check(), LeaseVerdict.valid);
    });

    test('🔴 옛 폰 DEMOTED = 기동 거부 X1_DEMOTED · 주문 리스 INVALID', () async {
      demoted(live);
      final X1Wiring w = wiring();
      expect(w.bootRefusals(), <String>['X1_DEMOTED']);
      expect(await w.orderLease(FakeLeaseGate()).check(), LeaseVerdict.invalid);
    });

    test('🔴 새 폰 재구성 전 = 주문 봉인(던짐) · 백업 갭 = 복원 시각 − 매니페스트 날', () {
      restored(live);
      final X1Wiring w = wiring();
      expect(w.bootRefusals(), isEmpty);
      expect(w.backupGapDays(), 4);
      expect(
        w.checkOrderSeal,
        throwsA(
          isA<X1OrderSealed>()
              .having(
                (X1OrderSealed e) => e.code,
                'code',
                'X1_RECOVERY_IN_PROGRESS',
              )
              .having(
                (X1OrderSealed e) => e.toString(),
                'text',
                'X1OrderSealed: X1_RECOVERY_IN_PROGRESS',
              ),
        ),
      );
      step(live, 'mig-2', 'GAP_REBUILT', 'DONE', '2026-11-16T02:00:00.000Z');
      wiring().checkOrderSeal();
    });
  });

  group('bootEngine — X1 거부 이어 붙이기', () {
    test(
      '🔴 live · 기기 id · DEMOTED = SAF-405 뒤에 X1_DEMOTED(승인 있어도 거부)',
      () async {
        final Directory dir = tempLedgerDir();
        final LedgerFiles f = openFiles(dir, clock);
        addTearDown(f.close);
        writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
        final Database live = writeLiveMode(dir, clock);
        addTearDown(live.close);
        demoted(f.liveIfExists()!);
        final EngineBoot a = await bootEngine(
          f,
          clock: clock,
          inputs: const BootInputs(deviceId: 'dev-1'),
        );
        expect((a as EngineRejected).triggered, <String>[
          kSaf405,
          'X1_DEMOTED',
        ]);
        final EngineBoot b = await bootEngine(
          f,
          clock: clock,
          inputs: BootInputs(
            approvedOf: (Database _, RunMode m) => 1,
            deviceId: 'dev-1',
          ),
        );
        expect((b as EngineRejected).triggered, <String>['X1_DEMOTED']);
        expect(b.runMode, RunMode.live);
        // 기기 id 없음 = 지금과 같다(준비).
        final EngineBoot c = await bootEngine(
          f,
          clock: clock,
          inputs: BootInputs(approvedOf: (Database _, RunMode m) => 1),
        );
        expect(c, isA<EngineReady>());
      },
    );

    test('모의 파일 = X1 밖(기기 id 가 있어도 준비)', () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      final EngineBoot b = await bootEngine(
        f,
        clock: clock,
        inputs: const BootInputs(deviceId: 'dev-1'),
      );
      expect(b, isA<EngineReady>());
    });
  });
}
