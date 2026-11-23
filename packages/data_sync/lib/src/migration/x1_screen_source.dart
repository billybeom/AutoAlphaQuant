// X1 기기 이전 화면 원천 · 옛 폰 단계 진행기 · 표시 hold(E16j-b · 01 §42 · 미결 218 ⓐ ⓑ · 212 ② · SPEC v2.45 04 §3-1 ①).
//
// 🔴 읽기 = 이 기기 저널(OLD_DEVICE · NEW_DEVICE) · 단계 사실 · 감시 창 → core `x1PlanWizardVmOf` · `x1RecoveryVmOf`(글자 = 엔진).
// 🔴 진행기 = 단계마다 «들어감 → 할 일 → 끝» · 차례 · 막음 = core · 저장 = `SqliteMigrationJournal` 그대로 · 열린 단계(`kX1PlanOpenThrough`)만
//    (닫힌 단계 = [UnsupportedError] — 지어내지 않는다). 동결 = 감시 유지보수 창 열기(바깥 체크 = 부르는 쪽 · 없거나 못 읽으면 창 기록만 ·
//    멈춘 체크 0). 미체결 · 대사 = 사실 확인만(주문을 건드리지 않는다).
// 🔴 그만두기 = 그 단계에 들어가 있지 않으면 들어간 뒤 FAILED(DEMOTED 앞만 · 저널 R117 B4) · 같은 트랜잭션에 이 이전의 창 닫기(저널).
// 🔴 강등 뒤 기동 거부와 독립 — 엔진 깨어남(`bootEngine`)을 거치지 않고 원장에 바로 쓴다(미결 218 ⓑ).
// 🔴 hold `MIGRATION_IN_PROGRESS` = 표시만(막는 정본 = 리스 · 동결 합성) — 옛 폰 동결 ~ 끝 전 · 새 폰 복구 ~ 생체 승인 전 · 저널 깨짐 = 켬.
// 🆕 E16t3c(R244) — 새 폰 비상 앞쪽(복원 전) 재료 = sim 원장 `command_inbox` 회수 · 재발급 기록(`SqliteX1EmergencyStore`) · 펜싱 설정
//    (운영 설정 잠정 값) · 신뢰 시각 — 복구 저널(live)이 있으면 그쪽이 이긴다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        OperatingMode,
        RunMode,
        SafetyActionId,
        X1JournalResultCodes,
        X1PlanWizardVm,
        X1RecoveryVm;
import 'package:sqlite3/sqlite3.dart';

import '../local/alert_store.dart' show SqliteAlertSink;
import '../local/lease_store.dart' show SqliteLeaseGate;
import 'maintenance_window_runner.dart' show MaintenanceWindowRunner;
import 'maintenance_window_store.dart' show SqliteMaintenanceWindowStore;
import 'migration_facts.dart' show migrationPlanFactsOf;
import 'migration_journal_store.dart' show SqliteMigrationJournal;
import 'recovery_gate_store.dart' show RecoveryGateView, SqliteRecoveryGate;
import 'recovery_journal_store.dart' show RecoveryRun, latestRecoveryOf;
import 'x1_emergency_store.dart' show SqliteX1EmergencyStore;

/// 화면을 다시 낼 표(저널 · 창 · 단계 사실 · 관찰 원천).
const Set<String> kX1WatchedTables = <String>{
  'migration_run',
  'migration_step',
  'maintenance_window',
  'order_intents',
  'trading_block',
  'ledger_daily_hash',
  'reconciliation_log',
  'job_run',
};

/// 🔴 표시 hold — 이 기기 옛 폰 이전이 동결됐고 끝나지 않았다 ∨ 새 폰 복구가 생체 승인 전이다 · 저널 깨짐 = true.
bool migrationInProgressOf(Database db, String deviceId) {
  try {
    final ResultSet old = db.select(
      "SELECT run_id FROM migration_run WHERE device_id = ? AND role = 'OLD_DEVICE' "
      'ORDER BY started_at DESC, rowid DESC LIMIT 1',
      <Object?>[deviceId],
    );
    if (old.isNotEmpty) {
      final String id = old.single['run_id'] as String;
      final PlanProgress p = planProgressOf(id, _stepRows(db, id));
      if (p.frozen && !p.complete) return true;
    }
    final RecoveryRun? r = latestRecoveryOf(db, deviceId);
    if (r == null) return false;
    return db.select(
      "SELECT 1 FROM migration_step WHERE run_id = ? AND step = ? AND state = 'DONE'",
      <Object?>[r.runId, RecoveryStep.biometricConfirmed.wire],
    ).isEmpty;
  } on StateError {
    return true;
  } on FormatException {
    return true;
  }
}

List<MigrationStepRow> _stepRows(Database db, String runId) =>
    <MigrationStepRow>[
      for (final Row r in db.select(
        'SELECT run_id, step, state, at FROM migration_step WHERE run_id = ? ORDER BY at, rowid',
        <Object?>[runId],
      ))
        MigrationStepRow(
          runId: r['run_id'] as String,
          step: r['step'] as String,
          state: r['state'] as String,
          atUtc: DateTime.parse(r['at'] as String).toUtc(),
        ),
    ];

/// 이 이전이 연 열린 창의 열린 시각(없음 = null).
DateTime? _openWindowAt(Database db, String runId) {
  final ResultSet r = db.select(
    "SELECT at FROM maintenance_window WHERE run_id = ? AND event = 'OPENED' "
    "AND window_id NOT IN (SELECT window_id FROM maintenance_window WHERE event = 'CLOSED') "
    'ORDER BY at DESC LIMIT 1',
    <Object?>[runId],
  );
  return r.isEmpty ? null : DateTime.parse(r.single['at'] as String).toUtc();
}

/// X1 화면 원천(이 기기 · 한 원장).
class SqliteX1Screens {
  /// 만든다 — [db] = 옛 폰 = 지금 화면 원장 · 새 폰 = live 원장(없으면 null).
  SqliteX1Screens(
    this._db, {
    required this.deviceId,
    required this._runMode,
    required this._operatingMode,
    required this._trusted,
    required this._clock,
  });

  final Database? _db;
  final RunMode _runMode;
  final OperatingMode _operatingMode;
  final TrustedClock _trusted;
  final Clock _clock;

  /// 이 기기(모름 = null = X1 꺼짐).
  final String? deviceId;

  SqliteMigrationJournal _journal(Database db, String id) =>
      SqliteMigrationJournal(
        db,
        deviceId: id,
        trusted: _trusted,
        lease: SqliteLeaseGate(db, mode: _runMode, clock: _clock),
      );

  /// 🔴 옛 폰 마법사(`x1Migration`).
  X1PlanWizardVm planWizard({String? lockedLabel}) {
    final Database? db = _db;
    final String? id = deviceId;
    final DateTime now = _clock.nowUtc();
    if (db == null || id == null || _runMode != RunMode.live) {
      return x1PlanWizardVmOf(
        X1PlanWizardFacts(
          // 원장 없음 = live 원장이 아니다(X1 = live 만).
          runMode: db == null ? RunMode.simInternal : _runMode,
          operatingMode: _operatingMode,
          deviceKnown: id != null,
          nowUtc: now,
          lockedLabel: lockedLabel,
        ),
      );
    }
    String? runId;
    PlanProgress? progress;
    bool broken = false;
    try {
      final SqliteMigrationJournal j = _journal(db, id);
      runId = j.latestRunId();
      progress = runId == null ? null : j.progressOf(runId);
    } on StateError {
      broken = true;
    } on FormatException {
      broken = true;
    }
    final bool active = progress != null && progress.failed == null;
    return x1PlanWizardVmOf(
      X1PlanWizardFacts(
        runMode: _runMode,
        operatingMode: _operatingMode,
        deviceKnown: true,
        nowUtc: now,
        journalBroken: broken,
        runId: runId,
        progress: progress,
        stepFacts: active ? migrationPlanFactsOf(db) : null,
        windowOpenedAtUtc: active ? _openWindowAt(db, runId!) : null,
        lockedLabel: lockedLabel,
      ),
    );
  }

  /// 🔴 새 폰 복구(`x1MigrationPlan` · `x1MigrationEmergency`) — [observation] · [ladder] = 운영 설정(없음 = 게이트 · RECOVERY_FULL 판정 0) ·
  /// 🆕 E16t3c [sim] = 비상 앞쪽 기록 원장(없음 = 기록 0) · [fencing] = 펜싱 설정(없음 = 끝 시각을 셀 수 없다) ·
  /// [emergencyRunnable] = 비상 시작 흐름 조립 있음.
  X1RecoveryVm recovery(
    MigrationKind routeKind, {
    required ExchangeCalendar kr,
    MigrationObservationConfig? observation,
    ResumeLadder? ladder,
    bool goldenRunnable = false,
    bool biometricRunnable = false,
    String? lockedLabel,
    Database? sim,
    FencingConfig? fencing,
    bool emergencyRunnable = false,
  }) {
    final Database? db = _db;
    final String? id = deviceId;
    final DateTime now = _clock.nowUtc();
    RecoveryRun? run;
    bool broken = false;
    if (db != null && id != null) {
      try {
        run = latestRecoveryOf(db, id);
      } on StateError {
        broken = true;
      } on FormatException {
        broken = true;
      }
    }
    X1EmergencyFacts? emergency;
    if (!broken && run == null && routeKind == MigrationKind.emergency) {
      try {
        emergency = sim == null ? null : SqliteX1EmergencyStore(sim).facts();
      } on StateError {
        broken = true;
      } on FormatException {
        broken = true;
      }
    }
    MigrationGateVerdict? gate;
    Set<String> golden = const <String>{};
    if (db != null && id != null && run != null) {
      golden = <String>{
        for (final Row r in db.select(
          'SELECT state FROM migration_step WHERE run_id = ? AND step = ?',
          <Object?>[run.runId, RecoveryStep.goldenSelfTest.wire],
        ))
          r['state'] as String,
      };
      if (observation != null && run.gapRebuilt) {
        final RecoveryGateView v = SqliteRecoveryGate(
          db,
          deviceId: id,
          trusted: _trusted,
          clock: _clock,
          kr: kr,
        ).view(config: observation);
        gate = v.gate;
      }
    }
    return x1RecoveryVmOf(
      X1RecoveryFacts(
        routeKind: routeKind,
        nowUtc: now,
        journalBroken: broken,
        run: run == null
            ? null
            : X1RecoveryRunFacts(
                runId: run.runId,
                kind: run.kind,
                manifest: run.manifest,
                gapRebuilt: run.gapRebuilt,
              ),
        recoveryFull:
            run != null &&
            ladder != null &&
            run.backupGapDays >= ladder.backupGapDays,
        goldenStates: golden,
        gate: gate,
        goldenRunnable: goldenRunnable,
        biometricRunnable: biometricRunnable,
        lockedLabel: lockedLabel,
        emergency: emergency,
        emergencyRunnable: emergencyRunnable,
        liveExists: db != null,
        fencing: fencing,
        trustedNowUtc: _trusted.trustedNowUtc(),
      ),
    );
  }
}

/// 🔴 옛 폰 단계 진행기(`X1_PLAN_START` · `X1_PLAN_STEP` · `X1_PLAN_ABORT` 의 원장 몫).
class SqliteX1PlanStepper {
  /// 만든다 — [watchdog] = 바깥 감시(없음 = 창 기록만 · 멈춘 체크 0).
  SqliteX1PlanStepper(
    this._db, {
    required this.deviceId,
    required this._runMode,
    required this._trusted,
    required this._clock,
    this._watchdog,
  });

  final Database _db;
  final RunMode _runMode;
  final TrustedClock _trusted;
  final Clock _clock;
  final WatchdogRemote? _watchdog;

  /// 이 기기.
  final String deviceId;

  SqliteLeaseGate get _lease =>
      SqliteLeaseGate(_db, mode: _runMode, clock: _clock);

  SqliteMigrationJournal get _journal => SqliteMigrationJournal(
    _db,
    deviceId: deviceId,
    trusted: _trusted,
    lease: _lease,
  );

  /// 🔴 시작 — [decisionId] = `D-03` 확인 결정(비울 수 없다) · epoch = 지금 리스 세대 · 거부 = 저널 차례 그대로.
  ({String? runId, String? code}) start({
    required OperatingMode operatingMode,
    required String decisionId,
  }) {
    if (decisionId.trim().isEmpty) {
      throw ArgumentError.value(decisionId, 'decisionId', '비울 수 없다');
    }
    final ({String? runId, String? rejectCode}) r = _journal.start(
      kind: MigrationKind.plan,
      operatingMode: operatingMode,
      decisionId: decisionId,
      operatorEpoch: _lease.epoch(),
    );
    return (runId: r.runId, code: r.rejectCode);
  }

  /// 🔴 단계 진행 — 열린 단계만 · 들어감 → 할 일(동결 = 창 열기) → 끝(사실이 막으면 그 코드 · 단계는 들어간 채) · 통과 = null.
  Future<String?> step(
    String runId,
    PlanStep step, {
    required OperatingMode operatingMode,
  }) async {
    if (!x1PlanStepOpen(step)) {
      throw UnsupportedError('X1 ${step.wire}: 이 앱에서 아직 열리지 않은 단계');
    }
    final SqliteMigrationJournal j = _journal;
    final String? entered = j.enter(runId, step);
    if (entered != null) return entered;
    if (step == PlanStep.freeze) await _openWindow(runId, operatingMode);
    return j.done(runId, step, migrationPlanFactsOf(_db));
  }

  /// 🔴 그만두기 — DEMOTED 앞만 · 차례인 단계에 들어가 있지 않으면 들어간 뒤 FAILED(사유 = 동작 id).
  String? abort(String runId, PlanStep step) {
    if (!step.mayFail) return X1JournalResultCodes.pastNoReturn;
    final SqliteMigrationJournal j = _journal;
    final String? entered = j.enter(runId, step);
    if (entered != null) return entered;
    return j.fail(runId, step, reasonCode: SafetyActionId.x1PlanAbort.wire);
  }

  Future<void> _openWindow(String runId, OperatingMode operatingMode) async {
    final SqliteMaintenanceWindowStore store = SqliteMaintenanceWindowStore(
      _db,
      trusted: _trusted,
      alerts: SqliteAlertSink(_db, clock: _clock),
    );
    final WatchdogRemote? remote = _watchdog;
    if (remote != null) {
      try {
        await MaintenanceWindowRunner(
          store,
          remote: remote,
        ).open(runMode: _runMode, operatingMode: operatingMode, runId: runId);
        return;
      } on Object {
        // 바깥 체크 목록을 못 읽음 = 창 기록만(멈춘 체크 0 — 감시가 더 울리는 쪽이 안전).
      }
    }
    store.open(
      checkSlugs: const <String>[],
      runMode: _runMode,
      operatingMode: operatingMode,
      runId: runId,
    );
  }
}
