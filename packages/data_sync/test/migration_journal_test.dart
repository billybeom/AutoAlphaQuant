// E16g1 — X1 이전 저널 · 동결 리스 래퍼 · 기동 거부 원천 · 유지보수 창 기록(설계 13 §8 R132 N1~N11).
//
// 🔵 잡는 것: ① 시작 거부 = core 차례(live → 안내 → 결정 → 신뢰 시각) · 중단 안 된 이전 있음 · id 순번 · 행 칸
//    ② 단계 차례 · 다시 들어가기 = 쓰기 0 · 막는 사실 코드 · 🔴 DEMOTED 끝 = 리스 봉인 · 실패 = DEMOTED 앞만 + 창 닫기
//    ③ 🔴 기기 필터(복원 스냅샷의 옛 폰 행 · 새 폰 역할) · 마지막 = 시작 시각 차례 ④ 리스 래퍼(동결 = INVALID · 깨짐 = INVALID)
//    ⑤ 기동 거부(DEMOTED · 깨짐) ⑥ 창 열기(engine_alive 0 · 하나만) · 넘김 P1 한 번 · 재개 실패 P0 부팅당 · 닫기 시각 아래 고정.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
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

class _Lease implements LeaseGate {
  _Lease(this.v);
  LeaseVerdict v;
  bool boom = false;
  @override
  Future<LeaseVerdict> check() async {
    if (boom) throw StateError('x');
    return v;
  }
}

// 한국 11-17 10:00.
final DateTime _t0 = DateTime.utc(2026, 11, 17, 1);
const String _dev = 'dev-old';

const PlanStepFacts _clean = PlanStepFacts(
  openOrders: 0,
  unknownOrders: 0,
  reconMismatches: 0,
  currentChainHash: 'c1',
  backupChainHash: 'c1',
);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late SqliteMigrationJournal journal;
  late SqliteMaintenanceWindowStore windows;

  SqliteMigrationJournal journalOn(Database on, {String device = _dev}) =>
      SqliteMigrationJournal(
        on,
        deviceId: device,
        trusted: trusted,
        lease: SqliteLeaseGate(on, mode: RunMode.live, clock: clock),
      );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_mig_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    journal = journalOn(db);
    windows = SqliteMaintenanceWindowStore(
      db,
      trusted: trusted,
      alerts: SqliteAlertSink(db, clock: clock),
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  int count(String table) =>
      db.select('SELECT COUNT(*) AS n FROM $table').single['n'] as int;

  ({String? runId, String? rejectCode}) start({
    MigrationKind kind = MigrationKind.plan,
    OperatingMode op = OperatingMode.autoTrade,
    String? decision = 'D-03-ok',
    SqliteMigrationJournal? on,
  }) => (on ?? journal).start(
    kind: kind,
    operatingMode: op,
    decisionId: decision,
    operatorEpoch: 2,
  );

  /// [runId] 을 [through] 단계까지 끝낸다.
  void walk(String runId, PlanStep through) {
    for (final PlanStep s in PlanStep.values) {
      expect(journal.enter(runId, s), isNull, reason: s.wire);
      expect(journal.done(runId, s, _clean), isNull, reason: s.wire);
      if (s == through) return;
    }
  }

  group('시작', () {
    test('🔴 거부 = core 차례(live → 안내 → 결정 → 신뢰 시각) · 쓰기 0', () {
      final Database sim = openLocalLedger(
        dir.path,
        RunMode.simInternal,
        clock: () => _t0,
      );
      addTearDown(sim.close);
      expect(journalOn(sim).isLive, isFalse);
      expect(journal.isLive, isTrue);
      expect(
        start(on: journalOn(sim), op: OperatingMode.advisory).rejectCode,
        MigrationStartCodes.liveOnly,
      );
      expect(
        start(op: OperatingMode.advisory).rejectCode,
        MigrationStartCodes.advisoryPending,
      );
      expect(
        start(decision: ' ').rejectCode,
        MigrationStartCodes.d03NotConfirmed,
      );
      expect(
        start(kind: MigrationKind.emergency, decision: null).rejectCode,
        MigrationStartCodes.emergencyNotDeclared,
      );
      trusted.at = null;
      expect(start().rejectCode, MigrationStartCodes.trustedTimeUnknown);
      expect(count('migration_run'), 0);
    });

    test('통과 = 이전 id(한국 날 순번) · 행 칸', () {
      final ({String? runId, String? rejectCode}) r = start();
      expect((r.runId, r.rejectCode), ('mig-2026-11-17-1', null));
      final Row row = db.select('SELECT * FROM migration_run').single;
      expect(
        <Object?>[
          row['kind'],
          row['role'],
          row['device_id'],
          row['operator_epoch'],
          row['decision_id'],
          row['started_at'],
        ],
        <Object?>[
          'PLAN',
          'OLD_DEVICE',
          _dev,
          2,
          'D-03-ok',
          _t0.toIso8601String(),
        ],
      );
    });

    test('🔴 중단 안 된 이전(진행 · 끝남)이 있으면 거부 · 중단 뒤 = 다음 순번', () {
      final String a = start().runId!;
      expect(start().rejectCode, MigrationStoreCodes.runExists);
      journal.enter(a, PlanStep.freeze);
      expect(journal.fail(a, PlanStep.freeze, reasonCode: 'X'), isNull);
      trusted.at = _t0.add(const Duration(minutes: 1));
      final String b = start().runId!;
      expect(b, 'mig-2026-11-17-2');
      walk(b, PlanStep.ticketIssued);
      expect(journal.progressOf(b).complete, isTrue);
      expect(start().rejectCode, MigrationStoreCodes.runExists);
    });
  });

  group('단계', () {
    late String run;
    setUp(() => run = start().runId!);

    test('차례 · 다시 들어가기 = 쓰기 0 · 시각 = 신뢰 시각 · 상세', () {
      expect(
        journal.enter(run, PlanStep.reconZero),
        MigrationStoreCodes.stepOutOfOrder,
      );
      expect(
        journal.enter(run, PlanStep.freeze, detail: <String, Object?>{'k': 1}),
        isNull,
      );
      expect(journal.enter(run, PlanStep.freeze), isNull);
      expect(count('migration_step'), 1);
      final Row r = db.select('SELECT * FROM migration_step').single;
      expect(
        (r['step'], r['state'], r['detail_json'], r['at']),
        ('FREEZE', 'ENTERED', '{"k":1}', _t0.toIso8601String()),
      );
      expect(
        journal.done(run, PlanStep.ordersCleared, _clean),
        MigrationStoreCodes.stepOutOfOrder,
      );
      expect(journal.done(run, PlanStep.freeze, _clean), isNull);
      expect(journal.progressOf(run).isDone(PlanStep.freeze), isTrue);
      expect(
        journal.enter(run, PlanStep.freeze),
        MigrationStoreCodes.stepOutOfOrder,
      );
    });

    test('막는 사실 = core 코드 · 쓰기 0', () {
      walk(run, PlanStep.freeze);
      journal.enter(run, PlanStep.ordersCleared);
      const PlanStepFacts open = PlanStepFacts(
        openOrders: 1,
        unknownOrders: 0,
        reconMismatches: 0,
        currentChainHash: 'c1',
      );
      expect(
        journal.done(run, PlanStep.ordersCleared, open),
        PlanBlockCodes.openOrders,
      );
      expect(journal.progressOf(run).inFlight, PlanStep.ordersCleared);
      expect(journal.done(run, PlanStep.ordersCleared, _clean), isNull);
      journal.enter(run, PlanStep.reconZero);
      journal.done(run, PlanStep.reconZero, _clean);
      journal.enter(run, PlanStep.backupChecksum);
      const PlanStepFacts noBackup = PlanStepFacts(
        openOrders: 0,
        unknownOrders: 0,
        reconMismatches: 0,
        currentChainHash: 'c1',
      );
      expect(
        journal.done(run, PlanStep.backupChecksum, noBackup),
        PlanBlockCodes.backupMissing,
      );
    });

    test('🔴 DEMOTED 끝 = 같은 트랜잭션에 리스 봉인(행 있을 때) · 뒤엔 실패 못 적음', () {
      db.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'OK', 2, 'u0')",
      );
      walk(run, PlanStep.backupChecksum);
      expect(
        db
            .select("SELECT status FROM sync_state WHERE target = 'SUPABASE'")
            .single['status'],
        'OK',
      );
      journal.enter(run, PlanStep.demoted);
      expect(
        journal.fail(run, PlanStep.demoted, reasonCode: 'X'),
        MigrationStoreCodes.pastNoReturn,
      );
      expect(journal.done(run, PlanStep.demoted, _clean), isNull);
      expect(
        db
            .select("SELECT status FROM sync_state WHERE target = 'SUPABASE'")
            .single['status'],
        'SEALED',
      );
      expect(journal.progressOf(run).pastNoReturn, isTrue);
    });

    test('리스 행이 없으면 DEMOTED = 저널만', () {
      walk(run, PlanStep.demoted);
      expect(count('sync_state'), 0);
      expect(journal.progressOf(run).isDone(PlanStep.demoted), isTrue);
    });

    test('🔴 실패 = 진행 중인 그 단계만 · 사유 · 이 이전이 연 창 닫기(다른 창은 그대로)', () {
      journal.enter(run, PlanStep.freeze);
      final String w = windows
          .open(
            checkSlugs: const <String>[],
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
            runId: run,
          )
          .windowId!;
      expect(
        journal.fail(run, PlanStep.ordersCleared, reasonCode: 'X'),
        MigrationStoreCodes.stepOutOfOrder,
      );
      trusted.at = _t0.add(const Duration(minutes: 3));
      expect(
        journal.fail(run, PlanStep.freeze, reasonCode: 'USER_ABORT'),
        isNull,
      );
      final Row f = db
          .select("SELECT * FROM migration_step WHERE state = 'FAILED'")
          .single;
      expect(
        (f['step'], f['detail_json']),
        ('FREEZE', '{"reason":"USER_ABORT"}'),
      );
      expect(journal.progressOf(run).failed, PlanStep.freeze);
      expect(windows.stateOf(w).closed, isTrue);
      expect(windows.openWindowId(), isNull);
    });

    test('신뢰 시각 모름 = 거부 · 다른 기기 이전 = ArgumentError', () {
      trusted.at = null;
      expect(
        journal.enter(run, PlanStep.freeze),
        MigrationStartCodes.trustedTimeUnknown,
      );
      expect(
        journal.done(run, PlanStep.freeze, _clean),
        MigrationStartCodes.trustedTimeUnknown,
      );
      expect(
        journal.fail(run, PlanStep.freeze, reasonCode: 'X'),
        MigrationStartCodes.trustedTimeUnknown,
      );
      trusted.at = _t0;
      expect(
        () => journalOn(db, device: 'dev-other').enter(run, PlanStep.freeze),
        throwsArgumentError,
      );
    });
  });

  group('🔴 기기 필터 · 마지막 이전', () {
    void rawRun(String id, String device, String role, String startedAt) =>
        db.execute(
          'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
          "VALUES (?, 'PLAN', ?, ?, 0, 'd', ?)",
          <Object?>[id, role, device, startedAt],
        );
    void rawStep(String id, String step, String state) => db.execute(
      'INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, ?, ?, NULL, ?)',
      <Object?>[id, step, state, _t0.toIso8601String()],
    );

    test('다른 기기 · 새 폰 역할 행은 읽지 않는다(복원 스냅샷의 옛 폰 행)', () {
      rawRun(
        'mig-2026-11-16-1',
        'dev-other',
        'OLD_DEVICE',
        '2026-11-16T01:00:00.000Z',
      );
      rawStep('mig-2026-11-16-1', 'FREEZE', 'ENTERED');
      rawRun(
        'mig-2026-11-16-2',
        _dev,
        'NEW_DEVICE',
        '2026-11-16T02:00:00.000Z',
      );
      expect(journal.latestRunId(), isNull);
      expect(journal.latestProgress(), isNull);
      expect(
        journalOn(db, device: 'dev-other').latestProgress()!.frozen,
        isTrue,
      );
    });

    test('마지막 = 시작 시각 차례(글자 차례 아님)', () {
      rawRun(
        'mig-2026-11-17-9',
        _dev,
        'OLD_DEVICE',
        '2026-11-17T01:00:00.000Z',
      );
      rawRun(
        'mig-2026-11-17-10',
        _dev,
        'OLD_DEVICE',
        '2026-11-17T02:00:00.000Z',
      );
      expect(journal.latestRunId(), 'mig-2026-11-17-10');
    });
  });

  group('리스 래퍼 · 기동 거부', () {
    late _Lease base;
    late MigrationAwareLeaseGate gate;
    setUp(() {
      base = _Lease(LeaseVerdict.valid);
      gate = MigrationAwareLeaseGate(base, journal);
    });

    test('이전 없음 = 바탕 그대로 · 거부 없음', () async {
      expect(await gate.check(), LeaseVerdict.valid);
      base.v = LeaseVerdict.unknown;
      expect(await gate.check(), LeaseVerdict.unknown);
      expect(migrationBootRefusalOf(journal), isNull);
    });

    test(
      '🔴 동결(FREEZE 들어감) = INVALID · 기동은 막지 않음 · 중단 = 바탕 · DEMOTED = 기동 거부',
      () async {
        final String run = start().runId!;
        journal.enter(run, PlanStep.freeze);
        expect(await gate.check(), LeaseVerdict.invalid);
        expect(migrationBootRefusalOf(journal), isNull);
        journal.fail(run, PlanStep.freeze, reasonCode: 'X');
        expect(await gate.check(), LeaseVerdict.valid);
        final String b = start().runId!;
        walk(b, PlanStep.backupChecksum);
        expect(migrationBootRefusalOf(journal), isNull);
        journal.enter(b, PlanStep.demoted);
        expect(migrationBootRefusalOf(journal), MigrationBootCodes.demoted);
        expect(await gate.check(), LeaseVerdict.invalid);
      },
    );

    test(
      '🔴 저널이 깨짐 = INVALID · 기동 거부 X1_JOURNAL_BROKEN · 바탕이 던짐 = UNKNOWN',
      () async {
        final String run = start().runId!;
        db.execute(
          "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES (?, 'ORDERS_CLEARED', 'DONE', NULL, 'x')",
          <Object?>[run],
        );
        expect(await gate.check(), LeaseVerdict.invalid);
        expect(
          migrationBootRefusalOf(journal),
          MigrationBootCodes.journalBroken,
        );
        db.execute('DELETE FROM migration_step');
        base.boom = true;
        expect(await gate.check(), LeaseVerdict.unknown);
      },
    );
  });

  group('유지보수 창', () {
    final List<String> slugs = <String>[
      watchdogCheckName(RunMode.live, OperatingMode.autoTrade, 'engine_alive'),
      watchdogCheckName(RunMode.live, OperatingMode.autoTrade, 'kr_order'),
      watchdogCheckName(
        RunMode.live,
        OperatingMode.autoTrade,
        'daily_reconcile',
      ),
      watchdogCheckName(
        RunMode.simInternal,
        OperatingMode.autoTrade,
        'kr_order',
      ),
    ];

    test('🔴 열기 = 멈출 체크(engine_alive 0 · 같은 접두만) · 한 번에 하나 · 한국 날 순번', () {
      final ({String? windowId, String? rejectCode}) r = windows.open(
        checkSlugs: slugs,
        runMode: RunMode.live,
        operatingMode: OperatingMode.autoTrade,
      );
      expect((r.windowId, r.rejectCode), ('mw-2026-11-17-1', null));
      final Row o = db.select('SELECT * FROM maintenance_window').single;
      expect(
        (o['event_id'], o['event'], o['run_id'], o['at']),
        ('mw-2026-11-17-1:OPENED', 'OPENED', null, _t0.toIso8601String()),
      );
      expect(
        o['checks_json'],
        '["live-auto-daily_reconcile","live-auto-kr_order"]',
      );
      expect(
        windows
            .open(
              checkSlugs: slugs,
              runMode: RunMode.live,
              operatingMode: OperatingMode.autoTrade,
            )
            .rejectCode,
        WindowStoreCodes.alreadyOpen,
      );
      expect(windows.close(r.windowId!), isNull);
      expect(
        windows
            .open(
              checkSlugs: slugs,
              runMode: RunMode.live,
              operatingMode: OperatingMode.autoTrade,
            )
            .windowId,
        'mw-2026-11-17-2',
      );
      trusted.at = null;
      expect(
        windows
            .open(
              checkSlugs: slugs,
              runMode: RunMode.live,
              operatingMode: OperatingMode.autoTrade,
            )
            .rejectCode,
        WindowStoreCodes.trustedTimeUnknown,
      );
    });

    test('🔴 넘김 = OVERDUE + P1 창당 한 번 · 부팅 = 재개 시도 · 열린 창 없음 = 빈 목록', () {
      expect(
        windows.tick(overdueAfter: const Duration(hours: 72), booting: true),
        isEmpty,
      );
      final String w = windows
          .open(
            checkSlugs: slugs,
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
          )
          .windowId!;
      expect(
        windows.tick(overdueAfter: const Duration(hours: 72), booting: false),
        isEmpty,
      );
      trusted.at = _t0.add(const Duration(hours: 72));
      final List<WindowAction> a = windows.tick(
        overdueAfter: const Duration(hours: 72),
        booting: true,
      );
      expect(a.map((WindowAction x) => x.runtimeType), <Type>[
        WindowRaiseOverdue,
        WindowTryResume,
      ]);
      expect(windows.stateOf(w).overdueRaised, isTrue);
      expect(
        db
            .select('SELECT code, level, source FROM alert_event')
            .map((Row r) => (r['code'], r['level'], r['source'])),
        <(Object?, Object?, Object?)>[
          ('MAINTENANCE_WINDOW_OVERDUE', 'P1', 'maintenance_window'),
        ],
      );
      trusted.at = _t0.add(const Duration(hours: 80));
      expect(
        windows.tick(overdueAfter: const Duration(hours: 72), booting: false),
        isEmpty,
      );
      expect(count('alert_event'), 1);
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM maintenance_window WHERE event = 'OVERDUE'",
            )
            .single['n'],
        1,
      );
    });

    test('🔴 재개 실패 = RESUME_FAILED + P0 부팅당 한 번 · 못 켠 체크 0 = 쓰기 0 · 신뢰 시각 모름 = 열린 시각 · 닫힌 창 = 오류', () {
      final String w = windows
          .open(
            checkSlugs: slugs,
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
          )
          .windowId!;
      expect(
        windows.recordResumeFailed(
          windowId: w,
          bootId: 'b1',
          notResumed: const <String>[],
        ),
        isFalse,
      );
      expect(count('alert_event'), 0);
      trusted.at = null;
      expect(
        windows.recordResumeFailed(
          windowId: w,
          bootId: 'b1',
          notResumed: const <String>['x'],
        ),
        isTrue,
      );
      final Row rf = db
          .select(
            "SELECT * FROM maintenance_window WHERE event = 'RESUME_FAILED'",
          )
          .single;
      expect(
        (rf['event_id'], rf['at']),
        ('$w:RESUME_FAILED:b1', _t0.toIso8601String()),
      );
      expect(
        windows.recordResumeFailed(
          windowId: w,
          bootId: 'b1',
          notResumed: const <String>['x'],
        ),
        isFalse,
      );
      trusted.at = _t0.add(const Duration(hours: 1));
      expect(
        windows.recordResumeFailed(
          windowId: w,
          bootId: 'b2',
          notResumed: const <String>['x'],
        ),
        isTrue,
      );
      expect(
        db
            .select('SELECT code, level FROM alert_event')
            .map((Row r) => (r['code'], r['level']))
            .toSet(),
        <(Object?, Object?)>{('MAINTENANCE_RESUME_FAILED', 'P0')},
      );
      windows.close(w);
      expect(
        () => windows.recordResumeFailed(
          windowId: w,
          bootId: 'b3',
          notResumed: const <String>['x'],
        ),
        throwsStateError,
      );
    });

    test('🔴 닫기 = 시각이 열린 시각보다 앞이면 열린 시각 · 두 번 = 쓰기 0 · 신뢰 시각 모름 = 거부', () {
      final String w = windows
          .open(
            checkSlugs: slugs,
            runMode: RunMode.live,
            operatingMode: OperatingMode.autoTrade,
          )
          .windowId!;
      trusted.at = null;
      expect(windows.close(w), WindowStoreCodes.trustedTimeUnknown);
      trusted.at = _t0.subtract(const Duration(hours: 2));
      expect(windows.close(w), isNull);
      final Row c = db
          .select("SELECT * FROM maintenance_window WHERE event = 'CLOSED'")
          .single;
      expect((c['event_id'], c['at']), ('$w:CLOSED', _t0.toIso8601String()));
      expect(windows.stateOf(w).closed, isTrue);
      expect(windows.close(w), isNull);
      expect(count('maintenance_window'), 2);
    });

    test('열린 창이 둘이면 오류 · 이전 닫기는 트랜잭션 안에서만', () {
      for (final String id in <String>['mw-a', 'mw-b']) {
        db.execute(
          "INSERT INTO maintenance_window (event_id, window_id, run_id, event, checks_json, at) VALUES (?, ?, NULL, 'OPENED', '[]', ?)",
          <Object?>['$id:OPENED', id, _t0.toIso8601String()],
        );
      }
      expect(windows.openWindowId, throwsStateError);
      expect(() => closeOpenWindowsOfRun(db, 'r', _t0), throwsStateError);
    });
  });
}
