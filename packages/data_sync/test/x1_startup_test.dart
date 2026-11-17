// E16t1 — X1 · X5 기동 합성 원천 · 유지보수 창 실행기(설계 13 §8 R139 U2~U6).
//
// 🔵 잡는 것: ① 거부 = 경계 X1 비상(사유 글자) → DEMOTED · 저널 깨짐 차례 · X5 정정 길 = 거부 아님 · 겹침 없음
//    ② 주문 봉인 = 복원 뒤 재구성 전만 · 복구 저널 깨짐 = 거부 + 봉인 ③ 창 열기 = 체크 목록 → engine_alive · 다른 갈래 빼고 멈춤 ·
//    멈춤 실패 = 돌려줌(창 열린 채) · 목록 실패 = 던짐(창 0) · 신뢰 시각 모름 · 이미 열림 = 거부(멈춤 0)
//    ④ 깨어남 = 재개 성공 = 닫음 · 실패(거짓 · 던짐) = RESUME_FAILED 부팅당 1건 · 창 열린 채 · 넘김 · 닫기 거부.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
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

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 16, 1);

void main() {
  late Directory dir;
  late Database db;
  late _Trusted trusted;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_x1s_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    trusted = _Trusted(_t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteMigrationJournal journal() => SqliteMigrationJournal(
    db,
    deviceId: 'dev-1',
    trusted: trusted,
    lease: SqliteLeaseGate(db, mode: RunMode.live, clock: _Clock(_t0)),
  );

  void run(String id, String role, String at) => db.execute(
    'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
    "VALUES (?, 'PLAN', ?, 'dev-1', 1, 'd', ?)",
    <Object?>[id, role, at],
  );

  void step(String id, String step, String state, String at) => db.execute(
    'INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, NULL, ?)',
    <Object?>[id, step, state, at],
  );

  /// 옛 폰 이전 — DEMOTED 에 들어감.
  void demoted() {
    run('mig-1', 'OLD_DEVICE', '2026-11-15T01:00:00.000Z');
    int m = 0;
    for (final String s in <String>[
      'FREEZE',
      'ORDERS_CLEARED',
      'RECON_ZERO',
      'BACKUP_CHECKSUM',
    ]) {
      step(
        'mig-1',
        s,
        'ENTERED',
        '2026-11-15T01:${(m++).toString().padLeft(2, '0')}:00.000Z',
      );
      step(
        'mig-1',
        s,
        'DONE',
        '2026-11-15T01:${(m++).toString().padLeft(2, '0')}:00.000Z',
      );
    }
    step('mig-1', 'DEMOTED', 'ENTERED', '2026-11-15T01:30:00.000Z');
  }

  /// 새 폰 복구(RESTORED 만).
  void restored() {
    run('mig-2', 'NEW_DEVICE', '2026-11-16T01:00:00.000Z');
    db.execute(
      "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES ('mig-2', 'RESTORED', 'DONE', ?, ?)",
      <Object?>[
        BackupManifest(
          sha256: 'a' * 64,
          chainHash: 'b' * 64,
          authoredDate: '2026-11-16',
          schemaVersion: 1,
          hashFormatVersion: 1,
          operatorEpoch: 0,
          writerDeviceId: 'dev-0',
        ).toCanonicalJson(),
        '2026-11-16T01:00:00.000Z',
      ],
    );
  }

  group('x1StartupOf — 기동 합성', () {
    test('깨끗함 = 거부 0 · 봉인 0', () {
      final X1Startup s = x1StartupOf(db, journal());
      expect(s.refusals, isEmpty);
      expect(s.orderSeal, isNull);
      expect(s.mayStart, isTrue);
    });

    test('🔴 경계 X1 비상 = 그 사유 글자 · X5 정정 길 = 거부 아님 · CLEAN = 거부 아님', () {
      final X1Startup a = x1StartupOf(
        db,
        journal(),
        boundary: ledgerBoundaryOf(dbOpened: false),
      );
      expect(a.refusals, <String>['DB_OPEN_FAILED']);
      expect(a.mayStart, isFalse);
      final X1Startup b = x1StartupOf(
        db,
        journal(),
        boundary: ledgerBoundaryOf(
          dbOpened: true,
          integrity: const LedgerIntegrityVerdict.failed(
            LedgerIntegrityReason.dayHashMismatch,
            firstBadDate: '2026-11-10',
            daysChecked: 3,
          ),
        ),
      );
      expect(b.refusals, isEmpty);
      final X1Startup c = x1StartupOf(
        db,
        journal(),
        boundary: ledgerBoundaryOf(
          dbOpened: true,
          integrity: const LedgerIntegrityVerdict.ok(
            daysChecked: 0,
            checkedThrough: null,
          ),
          archiveRelation: DerivedRelation.ahead,
        ),
      );
      expect(c.refusals, <String>['RESTORE_ROLLBACK']);
    });

    test('🔴 옛 폰 DEMOTED = X1_DEMOTED · 경계가 먼저', () {
      demoted();
      expect(x1StartupOf(db, journal()).refusals, <String>['X1_DEMOTED']);
      expect(
        x1StartupOf(
          db,
          journal(),
          boundary: ledgerBoundaryOf(dbOpened: false),
        ).refusals,
        <String>['DB_OPEN_FAILED', 'X1_DEMOTED'],
      );
    });

    test('🔴 새 폰 복구 저널만 깨짐(RESTORED 없음) = X1_JOURNAL_BROKEN + 봉인', () {
      run('mig-2', 'NEW_DEVICE', '2026-11-16T01:00:00.000Z');
      final X1Startup s = x1StartupOf(db, journal());
      expect(s.refusals, <String>['X1_JOURNAL_BROKEN']);
      expect(s.orderSeal, 'X1_RECOVERY_IN_PROGRESS');
      expect(s.mayStart, isFalse);
    });

    test('옛 폰 저널 깨짐 = X1_JOURNAL_BROKEN · 새 폰 저널도 깨지면 한 번만 · 봉인', () {
      demoted();
      step('mig-1', 'DEMOTED', 'FAILED', '2026-11-15T01:40:00.000Z');
      final X1Startup a = x1StartupOf(db, journal());
      expect(a.refusals, <String>['X1_JOURNAL_BROKEN']);
      expect(a.orderSeal, isNull);
      run('mig-2', 'NEW_DEVICE', '2026-11-16T01:00:00.000Z');
      final X1Startup b = x1StartupOf(db, journal());
      expect(b.refusals, <String>['X1_JOURNAL_BROKEN']);
      expect(b.orderSeal, 'X1_RECOVERY_IN_PROGRESS');
    });

    test('🔴 새 폰 복원 뒤 재구성 전 = 기동 가능 + 주문 봉인 · 재구성 뒤 = 봉인 없음', () {
      restored();
      final X1Startup a = x1StartupOf(db, journal());
      expect(a.mayStart, isTrue);
      expect(a.orderSeal, 'X1_RECOVERY_IN_PROGRESS');
      step('mig-2', 'GAP_REBUILT', 'DONE', '2026-11-16T01:30:00.000Z');
      expect(x1StartupOf(db, journal()).orderSeal, isNull);
    });

    test('거부 목록은 고칠 수 없다', () {
      expect(
        () => x1StartupOf(db, journal()).refusals.add('X'),
        throwsUnsupportedError,
      );
    });
  });

  group('MaintenanceWindowRunner — 창 실행기', () {
    late FakeWatchdogRemote remote;
    late SqliteMaintenanceWindowStore store;
    setUp(() {
      remote = FakeWatchdogRemote(
        initial: <RemoteCheck>[
          for (final String s in <String>[
            'live-auto-kr_order',
            'live-auto-daily_data',
            'engine_alive',
            'sim-auto-kr_order',
          ])
            RemoteCheck(slug: s, status: RemoteCheckStatus.up),
        ],
      );
      store = SqliteMaintenanceWindowStore(
        db,
        trusted: trusted,
        alerts: SqliteAlertSink(db, clock: _Clock(_t0)),
      );
    });

    MaintenanceWindowRunner runner() =>
        MaintenanceWindowRunner(store, remote: remote);

    Future<WindowOpenReport> open() => runner().open(
      runMode: RunMode.live,
      operatingMode: OperatingMode.autoTrade,
    );

    test(
      '🔴 열기 = 이 갈래 체크만 멈춤(engine_alive · 다른 갈래 0) · 멈춘 목록 = 창 기록',
      () async {
        final WindowOpenReport r = await open();
        expect(r.rejectCode, isNull);
        expect(r.windowId, isNotNull);
        expect(r.pauseFailed, isEmpty);
        final List<String> paused = store.pausedChecksOf(r.windowId!);
        expect(paused.toSet(), <String>{
          'live-auto-kr_order',
          'live-auto-daily_data',
        });
        expect(
          remote.calls.where((String c) => c.startsWith('pause:')).toSet(),
          <String>{
            'pause:live-auto-kr_order:maintenanceWindow',
            'pause:live-auto-daily_data:maintenanceWindow',
          },
        );
        expect(remote.store['engine_alive']!.status, RemoteCheckStatus.up);
        expect(remote.store['sim-auto-kr_order']!.status, RemoteCheckStatus.up);
        expect(
          remote.store['live-auto-kr_order']!.status,
          RemoteCheckStatus.paused,
        );
        expect(store.pausedChecksOf('mw-none'), isEmpty);
      },
    );

    test('멈춤 실패 = 돌려줌 · 창은 열린 채 · 나머지는 멈춤', () async {
      remote.failOn[('pause', 'live-auto-daily_data')] = Exception('망');
      final WindowOpenReport r = await open();
      expect(r.pauseFailed, <String>['live-auto-daily_data']);
      expect(store.openWindowId(), r.windowId);
      expect(
        remote.store['live-auto-kr_order']!.status,
        RemoteCheckStatus.paused,
      );
    });

    test('체크 목록 실패 = 던짐 · 창 0 · 신뢰 시각 모름 · 이미 열림 = 거부 · 멈춤 0', () async {
      remote.failOn[('checks', '*')] = Exception('망');
      await expectLater(open(), throwsA(isA<Exception>()));
      expect(store.openWindowId(), isNull);
      remote.failOn.clear();
      trusted.at = null;
      final WindowOpenReport a = await open();
      expect(a.rejectCode, 'TRUSTED_TIME_UNKNOWN');
      expect(a.windowId, isNull);
      trusted.at = _t0;
      await open();
      remote.calls.clear();
      final WindowOpenReport b = await open();
      expect(b.rejectCode, 'MW_ALREADY_OPEN');
      expect(remote.calls.where((String c) => c.startsWith('pause:')), isEmpty);
    });

    test('창 없음 = 빈 깨어남', () async {
      final WindowWakeReport w = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b1',
      );
      expect(w.windowId, isNull);
      expect(w.overdue, isFalse);
      expect(w.resumed, isEmpty);
      expect(w.closed, isFalse);
      expect(w.resumeFailedRecorded, isFalse);
    });

    test('🔴 부팅 깨어남 = 전부 재개 → 닫음', () async {
      final String id = (await open()).windowId!;
      trusted.at = _t0.add(const Duration(hours: 1));
      final WindowWakeReport w = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b1',
      );
      expect(w.windowId, id);
      expect(w.resumed.toSet(), <String>{
        'live-auto-kr_order',
        'live-auto-daily_data',
      });
      expect(w.notResumed, isEmpty);
      expect(w.closed, isTrue);
      expect(w.closeRejectCode, isNull);
      expect(store.stateOf(id).closed, isTrue);
      expect(store.openWindowId(), isNull);
      expect(
        remote.store['live-auto-kr_order']!.status,
        RemoteCheckStatus.fresh,
      );
    });

    test('🔴 재개 실패(던짐 · 거짓) = RESUME_FAILED 부팅당 1건 · 창 열린 채', () async {
      final String id = (await open()).windowId!;
      remote.failOn[('resume', 'live-auto-kr_order')] = Exception('망');
      // 멈추지 않은 체크 = resume 거짓.
      remote.store['live-auto-daily_data'] = const RemoteCheck(
        slug: 'live-auto-daily_data',
        status: RemoteCheckStatus.up,
      );
      final WindowWakeReport w = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b1',
      );
      expect(w.notResumed.toSet(), <String>{
        'live-auto-kr_order',
        'live-auto-daily_data',
      });
      expect(w.resumeFailedRecorded, isTrue);
      expect(w.closed, isFalse);
      expect(store.stateOf(id).closed, isFalse);
      final WindowWakeReport again = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b1',
      );
      expect(again.resumeFailedRecorded, isFalse);
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM maintenance_window WHERE event = 'RESUME_FAILED'",
            )
            .single['n'],
        1,
      );
      // 다른 부팅 = 다시 1건(사건 id 에 부팅 id).
      final WindowWakeReport next = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b2',
      );
      expect(next.resumeFailedRecorded, isTrue);
      expect(
        <String>[
          for (final Row r in db.select(
            "SELECT event_id FROM maintenance_window WHERE event = 'RESUME_FAILED' ORDER BY event_id",
          ))
            r['event_id'] as String,
        ],
        <String>['$id:RESUME_FAILED:b1', '$id:RESUME_FAILED:b2'],
      );
    });

    test('넘김 = 부팅 아님에도 overdue · 재개 시도 0 · 닫기 거부(신뢰 시각 모름)', () async {
      await open();
      trusted.at = _t0.add(const Duration(hours: 73));
      final WindowWakeReport w = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: false,
        bootId: 'b1',
      );
      expect(w.overdue, isTrue);
      expect(w.resumed, isEmpty);
      expect(
        remote.calls.where((String c) => c.startsWith('resume:')),
        isEmpty,
      );
      trusted.at = null;
      final WindowWakeReport b = await runner().onWake(
        overdueAfter: const Duration(hours: 72),
        booting: true,
        bootId: 'b2',
      );
      expect(b.overdue, isFalse);
      expect(b.resumed, hasLength(2));
      expect(b.closed, isFalse);
      expect(b.closeRejectCode, 'TRUSTED_TIME_UNKNOWN');
    });
  });
}
