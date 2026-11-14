// 엔진 조립 뿌리(E11p3a · 설계 e11p-map Q0~Q8).
//
// 깨어날 때마다: 원장 열기(처음 한 번) → 기동 판정 → (준비면) 회차 판정 → runNow 회차를 예정 차례대로 하나씩.
// 🔴 깨어남은 플랫폼 호스트가 이미 한 줄로 세운다(`OperatorEngineHost` · 원장 단일 쓰기) — 여기서도 겹쳐 부르지 않는다.
// 🔴 원장을 못 열면 그 깨어남은 실패한다(호스트가 받아 재무장 · 다음 깨어남에 다시 연다) — 호스트 기동은 막지 않는다.
// 🔴 판정 · 문구는 엔진 몫 — 여기는 차례만 잇는다. FGS 문구는 p3b(상태 함수) 뒤.

import 'package:core_engine/core_engine.dart' show JobHeartbeat;
import 'package:data_sync/data_sync.dart' show SqliteAlertSink, SqliteJobRunLog;
import 'package:domain_contracts/domain_contracts.dart' show Clock, TradeDate;
import 'package:trading_runtime/trading_runtime.dart'
    show JobCalendars, JobOccurrence, JobRun, JobSpec, kJobTable;

import 'engine_boot.dart';
import 'job_runners.dart';
import 'ledger_files.dart';
import 'system_clock.dart';
import 'wake_plan.dart';

/// 원장 묶음을 연다(처음 깨어날 때 한 번).
typedef LedgerFilesOpener = LedgerFiles Function();

/// 깨어남 한 번의 결과(시험 · 진단 — 정본 기록은 `job_run`).
class EngineWakeReport {
  /// 만든다.
  const EngineWakeReport({required this.boot, this.plan, this.runs = const []});

  /// 기동 판정.
  final EngineBoot boot;

  /// 회차 계획(준비가 아니면 null).
  final WakePlan? plan;

  /// 돌린 회차 결과(차례대로).
  final List<JobRun<Object?>> runs;
}

/// operator 엔진.
class OperatorEngine {
  /// 만든다.
  OperatorEngine({
    required this._openFiles,
    required JobCalendars calendars,
    required this._heartbeat,
    this._clock = const SystemClock(),
    this._bootInputs = const BootInputs(),
    this._runners = _defaultRunners,
    this._specs = kJobTable,
  }) : _cals = calendars;

  final LedgerFilesOpener _openFiles;
  final JobCalendars _cals;
  final JobHeartbeat _heartbeat;
  final Clock _clock;
  final BootInputs _bootInputs;
  final JobRunnerFactory _runners;
  final List<JobSpec> _specs;
  LedgerFiles? _files;

  static Map<String, JobRunner> _defaultRunners(JobContext c) =>
      composeJobRunners(c);

  /// 열린 원장(시험).
  LedgerFiles? get files => _files;

  /// 🔴 깨어남 한 건(플랫폼 `WakeHandler` 자리 — 깨어남 까닭은 판정에 쓰지 않는다: 늘 전 구간을 본다).
  Future<EngineWakeReport> wake() async {
    final LedgerFiles files = _files ??= _openFiles();
    final EngineBoot boot = await bootEngine(
      files,
      clock: _clock,
      inputs: _bootInputs,
    );
    final EngineReady ready;
    switch (boot) {
      case EngineOnboardingIncomplete():
      case EngineRejected():
        return EngineWakeReport(boot: boot);
      case EngineReady():
        ready = boot;
    }
    final SqliteJobRunLog log = SqliteJobRunLog(ready.db);
    final JobContext ctx = JobContext(
      runMode: ready.runMode,
      operatingMode: ready.operatingMode,
      calendars: _cals,
      heartbeat: _heartbeat,
      alerts: SqliteAlertSink(ready.db, clock: _clock),
      runLog: log,
      clock: _clock,
    );
    final Map<String, JobRunner> table = _runners(ctx);
    final WakePlan plan = planWake(
      nowUtc: _clock.nowUtc(),
      cals: _cals,
      specs: _specs,
      doneSessions: (String job, TradeDate from) =>
          log.doneSessions(job, from: from),
    );
    final List<JobRun<Object?>> runs = <JobRun<Object?>>[];
    for (final JobOccurrence o in plan.runNow) {
      final JobRunner? run = table[o.spec.job];
      if (run == null) {
        // 표 대조 시험이 막는 자리 — 칸 없는 잡을 조용히 건너뛰지 않는다.
        throw StateError('실행기 표에 ${o.spec.job} 칸이 없다');
      }
      runs.add(await run(o));
    }
    return EngineWakeReport(boot: boot, plan: plan, runs: runs);
  }
}
