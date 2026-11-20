// 엔진 조립 뿌리(E11p3a · 설계 e11p-map Q0~Q8).
//
// 깨어날 때마다: 원장 열기(처음 한 번) → 기동 판정 → (준비면) 회차 판정 → runNow 회차를 예정 차례대로 하나씩.
// 🔴 깨어남은 플랫폼 호스트가 이미 한 줄로 세운다(`OperatorEngineHost` · 원장 단일 쓰기) — 여기서도 겹쳐 부르지 않는다.
// 🔴 원장을 못 열면 그 깨어남은 실패한다(호스트가 받아 재무장 · 다음 깨어남에 다시 연다) — 호스트 기동은 막지 않는다.
// 🔴 판정 · 문구는 엔진 몫 — 여기는 차례만 잇는다.
// 🆕 E11p3c-4(R102) — 깨어남 끝에 FGS 상태를 넘긴다(준비 = 엔진 재료 · 거부 = BLOCKED + 거부 코드 · 온보딩 미완 = 넘기지 않음).

import 'package:core_engine/core_engine.dart'
    show JobHeartbeat, OperationsConfig, WatchdogRemote;
import 'package:data_sync/data_sync.dart'
    show
        MaintenanceWindowRunner,
        SqliteAlertSink,
        SqliteJobRunLog,
        SqliteMaintenanceWindowStore,
        WindowWakeReport,
        importSeedBundle,
        modeStartedAtUtc,
        seedBundleImported;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, LedgerFile, TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show FgsStatus, JobCalendars, JobOccurrence, JobRun, JobSpec, kJobTable;

import 'engine_boot.dart';
import 'fgs_status_source.dart' show fgsStatusForReady, fgsStatusForRejected;
import 'job_runners.dart';
import 'ledger_files.dart';
import 'system_clock.dart';
import 'wake_plan.dart';

/// 원장 묶음을 연다(처음 깨어날 때 한 번).
typedef LedgerFilesOpener = LedgerFiles Function();

/// 시드 자산 바이트(파일 이름 → gz 바이트 · 조립 = `rootBundle`).
typedef SeedAssets = Future<Map<String, List<int>>> Function();

/// FGS 상태를 받는 쪽(조립 = 호스트 `FgsPresenter.show` · 전이 때만 다시 띄운다).
typedef FgsSink = Future<void> Function(FgsStatus status);

/// 깨어남 한 번의 결과(시험 · 진단 — 정본 기록은 `job_run`).
class EngineWakeReport {
  /// 만든다.
  const EngineWakeReport({
    required this.boot,
    this.plan,
    this.runs = const [],
    this.window,
    this.windowError,
  });

  /// 기동 판정.
  final EngineBoot boot;

  /// 회차 계획(준비가 아니면 null).
  final WakePlan? plan;

  /// 돌린 회차 결과(차례대로).
  final List<JobRun<Object?>> runs;

  /// 🆕 E16t3b(R149 AA3) — 감시 유지보수 창 깨어남(건너뜀 = null).
  final WindowWakeReport? window;

  /// 🆕 E16t3b(R149 AA4) — 창 깨어남이 던진 것(회차는 막지 않는다 · 없음 = null).
  final Object? windowError;
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
    this._seed,
    this._fgs,
    this._watchdog,
    this._operations,
  }) : _cals = calendars;

  final LedgerFilesOpener _openFiles;
  final JobCalendars _cals;
  final JobHeartbeat _heartbeat;
  final Clock _clock;
  final BootInputs _bootInputs;
  final JobRunnerFactory _runners;
  final List<JobSpec> _specs;
  final SeedAssets? _seed;
  final FgsSink? _fgs;

  /// 🆕 E16t3b(R149 AA1) — 바깥 감시(창 재개 · 없음 = 창 깨어남 건너뜀).
  final WatchdogRemote? _watchdog;

  /// 🆕 E16t3b(R149 AA1) — 운영 설정(넘김 시간 · 없음 = 창 깨어남 건너뜀).
  final OperationsConfig? _operations;
  LedgerFiles? _files;

  static Map<String, JobRunner> _defaultRunners(JobContext c) =>
      composeJobRunners(c);

  /// 열린 원장(시험).
  LedgerFiles? get files => _files;

  /// 🔴 깨어남 한 건(플랫폼 `WakeHandler` 자리 — 깨어남 까닭은 판정에 쓰지 않는다: 늘 전 구간을 본다).
  Future<EngineWakeReport> wake({bool booting = false, String? bootId}) async {
    if (booting && bootId == null) {
      throw ArgumentError.notNull('bootId');
    }
    final LedgerFiles files = _files ??= _openFiles();
    await _ensureSeed(<Database?>[files.sim, files.liveIfExists()]);
    final EngineBoot boot = await bootEngine(
      files,
      clock: _clock,
      inputs: _bootInputs,
    );
    final EngineReady ready;
    switch (boot) {
      case EngineOnboardingIncomplete():
        return EngineWakeReport(boot: boot);
      case EngineRejected():
        await _fgs?.call(fgsStatusForRejected(boot));
        return EngineWakeReport(boot: boot);
      case EngineReady():
        ready = boot;
    }
    // 🆕 E16t3b(R149 AA2 · AA4) — 감시 유지보수 창 깨어남(live · 감시 · 넘김 시간 있을 때만 · 실패 = 회차를 막지 않는다).
    WindowWakeReport? window;
    Object? windowError;
    final WatchdogRemote? watchdog = _watchdog;
    final Duration? overdue = _operations?.maintenanceOverdue;
    if (ready.file == LedgerFile.live && watchdog != null && overdue != null) {
      try {
        window = await MaintenanceWindowRunner(
          SqliteMaintenanceWindowStore(
            ready.db,
            trusted: _bootInputs.trusted,
            alerts: SqliteAlertSink(ready.db, clock: _clock),
          ),
          remote: watchdog,
        ).onWake(overdueAfter: overdue, booting: booting, bootId: bootId ?? '');
      } on Object catch (e) {
        windowError = e;
      }
    }
    final SqliteJobRunLog log = SqliteJobRunLog(ready.db);
    final JobContext ctx = JobContext(
      db: ready.db,
      runMode: ready.runMode,
      operatingMode: ready.operatingMode,
      execPolicy: ready.execPolicy,
      calendars: _cals,
      heartbeat: _heartbeat,
      alerts: SqliteAlertSink(ready.db, clock: _clock),
      runLog: log,
      clock: _clock,
      deviceId: _bootInputs.deviceId,
      trusted: _bootInputs.trusted,
      operations: _operations,
    );
    final Map<String, JobRunner> table = _runners(ctx);
    final WakePlan plan = planWake(
      nowUtc: _clock.nowUtc(),
      cals: _cals,
      specs: _specs,
      doneSessions: (String job, TradeDate from) =>
          log.doneSessions(job, from: from),
      notBeforeUtc: modeStartedAtUtc(ready.db),
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
    // 🔴 회차가 끝난 뒤의 상태 — 상태를 못 만들면 이 깨어남이 실패한다(앞 문구를 «정상»으로 남겨 두지 않게 크게 드러낸다).
    await _fgs?.call(
      fgsStatusForReady(
        ready,
        calendars: _cals,
        clock: _clock,
        trusted: _bootInputs.trusted,
      ),
    );
    return EngineWakeReport(
      boot: boot,
      plan: plan,
      runs: runs,
      window: window,
      windowError: windowError,
    );
  }

  /// 🆕 E11p3b-3(R93) — 시드 번들을 아직 안 실은 원장에 싣는다(멱등 · 자산은 필요할 때만 읽는다 · 실패 = 이 깨어남 실패).
  Future<void> _ensureSeed(List<Database?> dbs) async {
    final SeedAssets? seed = _seed;
    if (seed == null) return;
    Map<String, List<int>>? bytes;
    for (final Database? db in dbs) {
      if (db == null || seedBundleImported(db)) continue;
      bytes ??= await seed();
      importSeedBundle(
        db,
        bytes,
        importedAt: _clock.nowUtc().toUtc().toIso8601String(),
      );
    }
  }
}
