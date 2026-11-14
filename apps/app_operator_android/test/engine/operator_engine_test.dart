// E11p3a 엔진 조립 뿌리 시험(설계 e11p-map Q0 · Q4 · Q5 · Q7) — 실 SQLite · 가짜 핑.

import 'dart:io';

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart';
import 'package:core_engine/core_engine.dart' show JobRunStatus, kSaf405;
import 'package:data_sync/data_sync.dart' show SqliteJobRunLog;
import 'package:domain_contracts/domain_contracts.dart' show OperatingMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show JobOccurrence, JobRun, JobStatus;

import 'support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late Directory dir;
  late RecordingHeartbeat hb;
  late int opened;
  late List<LedgerFiles> toClose;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 8, 30));
    dir = tempLedgerDir();
    hb = RecordingHeartbeat();
    opened = 0;
    toClose = <LedgerFiles>[];
  });
  tearDown(() {
    for (final LedgerFiles f in toClose) {
      f.close();
    }
  });

  LedgerFiles open() {
    opened++;
    final LedgerFiles f = openFiles(dir, clock);
    toClose.add(f);
    return f;
  }

  OperatorEngine engine({JobRunnerFactory? runners}) => OperatorEngine(
    openFiles: open,
    calendars: calendars(),
    heartbeat: hb,
    clock: clock,
    runners: runners ?? composeJobRunners,
  );

  test('온보딩 전 = 잡 0 · 핑 0 · job_run 0(실측 폰이 경보를 내지 않는다)', () async {
    final OperatorEngine e = engine();
    final EngineWakeReport r = await e.wake();
    expect(r.boot, isA<EngineOnboardingIncomplete>());
    expect(r.plan, isNull);
    expect(r.runs, isEmpty);
    expect(hb.pings, isEmpty);
    expect(
      e.files!.sim.select('SELECT COUNT(*) AS n FROM job_run').first['n'],
      0,
    );
  });

  test('🔴 준비 = runNow 회차를 예정 차례대로 하나씩 · p3a 는 전부 미조립 FAILED', () async {
    final OperatorEngine e = engine();
    await e.wake(); // 원장을 연다.
    writeSimMode(e.files!.sim, clock, committed: OperatingMode.autoTrade);
    final EngineWakeReport r = await e.wake();
    expect(r.boot, isA<EngineReady>());
    final List<JobOccurrence> want = r.plan!.runNow;
    expect(want, isNotEmpty);
    expect(r.runs.map((JobRun<Object?> x) => x.check), <String>[
      for (final JobOccurrence o in want) 'sim-auto-${o.spec.job}',
    ]);
    for (final JobRun<Object?> x in r.runs) {
      expect(x.status, JobStatus.failed, reason: x.check);
      expect(x.error, isA<JobNotAssembled>());
    }
    final SqliteJobRunLog log = SqliteJobRunLog(e.files!.sim);
    for (final JobOccurrence o in want) {
      expect(
        log.entriesOf(o.spec.job).single.status,
        JobRunStatus.failed,
        reason: o.spec.job,
      );
    }
  });

  test('실패 회차는 «돈» 이 아니다 — 늦은 끝 안이면 다음 깨어남에 다시(엔진 규칙)', () async {
    final OperatorEngine e = engine();
    await e.wake();
    writeSimMode(e.files!.sim, clock, committed: OperatingMode.autoTrade);
    final int first = (await e.wake()).runs.length;
    clock.now = clock.now.add(const Duration(minutes: 10));
    final EngineWakeReport again = await e.wake();
    expect(again.runs.length, first);
  });

  test('🔴 원장은 처음 한 번만 연다 · 열기 실패 = 그 깨어남 실패 → 다음에 다시', () async {
    int calls = 0;
    final OperatorEngine e = OperatorEngine(
      openFiles: () {
        calls++;
        if (calls == 1) throw const FileSystemException('잠김');
        return open();
      },
      calendars: calendars(),
      heartbeat: hb,
      clock: clock,
    );
    await expectLater(e.wake(), throwsA(isA<FileSystemException>()));
    await e.wake();
    await e.wake();
    expect(calls, 2);
    expect(opened, 1);
  });

  test('🔴 표에 칸이 없는 잡 = StateError(조용히 건너뛰지 않는다)', () async {
    final OperatorEngine e = engine(
      runners: (JobContext c) => <String, JobRunner>{},
    );
    await e.wake();
    writeSimMode(e.files!.sim, clock, committed: OperatingMode.autoTrade);
    await expectLater(e.wake(), throwsA(isA<StateError>()));
  });

  test('🔴 기동 거부(live · 승인 원천 없음) = 잡 0 · 핑 0', () async {
    final OperatorEngine e = engine();
    await e.wake();
    writeSimMode(e.files!.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    final EngineWakeReport r = await e.wake();
    expect((r.boot as EngineRejected).triggered, <String>[kSaf405]);
    expect(r.runs, isEmpty);
    expect(hb.pings, isEmpty);
  });
}
