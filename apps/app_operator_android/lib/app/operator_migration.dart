// 🆕 E16j-b — X1 기기 이전 operator 판: 읽기 창구(`MigrationRepository`) · 안전 동작 X1 id 6(`run` 화이트리스트 · 01 §42 K273 ·
// 미결 218 ⓐ ⓑ ⓘ).
//
// 🔴 옛 폰 = 화면 상태 원장(X1 = live 만 — 모의 = 엔진 `X1_LIVE_ONLY` 문장) · 새 폰 = live 원장(없으면 = 복구 없음 → 막힘 문장).
// 🔴 VM · 결과 글자 = 엔진(`x1PlanWizardVmOf` · `x1RecoveryVmOf` · `x1ActionResultOf`) — 앱은 잇기만.
// 🔴 진행기 = data_sync `SqliteX1PlanStepper`(엔진 깨어남 · `bootEngine` 밖 — 강등 뒤 기동 거부와 독립) · 열린 단계만 ·
//    `D-03` 확인 결정 id = `D03-<명령 id>`(이전 저널 `decision_id` · 🔴 `decision_log` 1행 = kind 결정 뒤 · 미결 218 ⓖ).
// 🆕 E16t3c(R244) — 비상 앞쪽이 열렸다: 비상 시작 = data_sync `SupabaseX1Emergency`(새 복구 카드 · 종이 확인 · 기기 행 ·
//    `lease_revoke` · sim `command_inbox` 회수 행 · 비상 선언 결정 id = `X1EMG-<명령 id>`) · 재발급 기록 = 값 → 지문만 · 옛 지문 =
//    이 폰 금고(KIS 앱키 셋 · 감시 핑 키 — 🔴 옛 폰 금고는 새 폰에 없다) · 판정 = core 체크리스트. 이 폰에 live 원장이 있으면 시작 0.
// 🔴 막힘(지어내지 않는다 — 오류): 새 폰 복원 · 갭 재구성(백업 바이트 D9 · 브로커 체결 연결) · 옛 폰 4단계 이후(core `kX1PlanOpenThrough`) ·
//    비상 흐름 조립 없음(기기 id · Supabase 없음).
// 🔴 생체 = 플랫폼(`biometricSign`) · 없음 = `BIOMETRIC_UNAVAILABLE` · 취소 = 쓰기 0(오류) · 골든 = E11o 실행기(없음 = 행 동작 부재).

import 'dart:async';
import 'dart:math' show Random;

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentialSlots, KisKeySet;

import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        GoldenRunResult,
        GoldenSelfTest,
        MigrationGateCodes,
        MigrationKind,
        MigrationObservationConfig,
        MigrationStartCodes,
        PlanStep,
        RecoveryStep,
        ReissueItem,
        SecretId,
        SecretVault,
        issueKillCommand,
        secretFingerprint,
        x1ActionResultOf,
        x1PlanStepOpen;
import 'package:data_sync/data_sync.dart'
    show
        HealthchecksClient,
        SqliteRecoveryGate,
        SqliteX1EmergencyStore,
        SqliteX1PlanStepper,
        SqliteX1Screens,
        SupabaseX1Emergency,
        kX1WatchedTables,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        MigrationRepository,
        OperatingMode,
        RunMode,
        SafetyActionId,
        SafetyActionResult,
        SettingsResultCodes,
        X1PlanWizardVm,
        X1RecoveryVm,
        X1RestoreResultCodes;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 🆕 E16t3c — 새 폰 비상 앞쪽 화면을 다시 낼 sim 표(회수 · 재발급 기록).
const Set<String> kX1EmergencyWatchedTables = <String>{'command_inbox'};

/// X1 동작 id 6(K273).
const Set<SafetyActionId> kX1ActionIds = <SafetyActionId>{
  SafetyActionId.x1PlanStart,
  SafetyActionId.x1PlanStep,
  SafetyActionId.x1PlanAbort,
  SafetyActionId.x1EmergencyStart,
  SafetyActionId.x1ReissueRecord,
  SafetyActionId.x1RecoveryStep,
};

/// X1 화면 읽기(operator).
class OperatorMigrationRepository implements MigrationRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorMigrationRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteX1Screens _screens(Database? db, OperatorView? v) => SqliteX1Screens(
    db,
    deviceId: _rt.deviceId,
    runMode: db == null ? RunMode.live : v?.flags.runMode ?? RunMode.live,
    operatingMode: v?.flags.operatingMode ?? OperatingMode.autoTrade,
    trusted: _rt.trusted,
    clock: _rt.clock,
  );

  @override
  Stream<X1PlanWizardVm> watchPlanWizard() => followView<X1PlanWizardVm>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<X1PlanWizardVm>(
      v.db,
      kX1WatchedTables,
      () => _screens(v.db, v).planWizard(),
    ),
    now: (OperatorView v) => _screens(v.db, v).planWizard(),
    tick: tick,
    noView: () => StateError('기기 이전: 화면 상태 없음(온보딩 전)'),
  );

  Stream<X1RecoveryVm> _recovery(MigrationKind kind) {
    final Database? live = _rt.files.liveIfExists();
    X1RecoveryVm read() =>
        SqliteX1Screens(
          live,
          deviceId: _rt.deviceId,
          runMode: RunMode.live,
          operatingMode:
              _rt.view.value?.flags.operatingMode ?? OperatingMode.autoTrade,
          trusted: _rt.trusted,
          clock: _rt.clock,
        ).recovery(
          kind,
          kr: _rt.calendars.kr,
          observation: _rt.operations?.migrationObservation,
          ladder: _rt.operations?.resumeLadder,
          goldenRunnable: _rt.golden != null,
          biometricRunnable: _rt.biometricSign != null,
          // 🆕 E16t3c — 비상 앞쪽 기록(sim) · 펜싱 설정(운영 설정 잠정 값).
          sim: _rt.files.sim,
          fencing: _rt.operations?.fencing,
          emergencyRunnable: _rt.x1Emergency != null,
        );
    // 🆕 E16t3c — 복원 전 = sim 회수 · 재발급 기록이 바뀔 때 + [tick](펜싱 대기 끝은 시간만 흘러도 온다).
    return _ticking(
      live == null
          ? watchLedgerQuery<X1RecoveryVm>(
              _rt.files.sim,
              kX1EmergencyWatchedTables,
              read,
            )
          : watchLedgerQuery<X1RecoveryVm>(live, kX1WatchedTables, read),
      read,
    );
  }

  /// 바뀐 값 + [tick] 마다 다시 읽기(같은 값은 한 번만).
  Stream<X1RecoveryVm> _ticking(
    Stream<X1RecoveryVm> changes,
    X1RecoveryVm Function() read,
  ) {
    late final StreamController<X1RecoveryVm> c;
    StreamSubscription<X1RecoveryVm>? sub;
    Timer? timer;
    X1RecoveryVm? last;
    void put(X1RecoveryVm v) {
      if (c.isClosed || v == last) return;
      last = v;
      c.add(v);
    }

    c = StreamController<X1RecoveryVm>(
      onListen: () {
        sub = changes.listen(put, onError: c.addError);
        timer = Timer.periodic(tick, (_) {
          try {
            put(read());
          } on Object catch (e, st) {
            if (!c.isClosed) c.addError(e, st);
          }
        });
      },
      onCancel: () async {
        timer?.cancel();
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<X1RecoveryVm> watchPlanRecovery() => _recovery(MigrationKind.plan);

  @override
  Stream<X1RecoveryVm> watchEmergencyRecovery() =>
      _recovery(MigrationKind.emergency);
}

/// 골든 자가검사 포트(E11o 기기 실행기 → X1-5 · 전량 통과 = true · 돌릴 수 없으면 던진다).
class _OperatorGoldenSelfTest implements GoldenSelfTest {
  _OperatorGoldenSelfTest(this._rt, this._db);

  final OperatorRuntime _rt;
  final Database _db;

  @override
  Future<bool> run() async {
    final GoldenRunResult r = await _rt.golden!.run(_db);
    return r.failures.isEmpty && r.passed == r.total;
  }
}

/// X1 안전 동작(operator · `OperatorSafetyActions.run` 이 X1 id 를 넘긴다).
class OperatorMigrationActions {
  /// 만든다 — [random] = 명령 id 원천(안전 동작과 같은 것).
  OperatorMigrationActions(this._rt, this._random);

  final OperatorRuntime _rt;
  final Random _random;

  static Future<SafetyActionResult> _closed(String what) =>
      Future<SafetyActionResult>.error(
        UnsupportedError('$what: 이 앱에서 아직 열리지 않았다(미결 218)'),
      );

  String _commandId(Map<String, String> args) =>
      issueKillCommand(payload: args, random: _random).commandId;

  SafetyActionResult _result(SafetyActionId id, String run, String? code) =>
      x1ActionResultOf(id: id, actionRunId: run, code: code);

  /// 🔴 X1 동작 하나 — 결과 글자 = 엔진 · 막힌 동작 = 오류.
  Future<SafetyActionResult> run(
    SafetyActionId id,
    Map<String, String> args,
  ) async {
    if (id == SafetyActionId.x1PlanStart ||
        id == SafetyActionId.x1PlanStep ||
        id == SafetyActionId.x1PlanAbort) {
      return _plan(id, args);
    }
    if (id == SafetyActionId.x1RecoveryStep) return _recoveryStep(args);
    if (id == SafetyActionId.x1EmergencyStart) return _emergencyStart(args);
    if (id == SafetyActionId.x1ReissueRecord) return _reissueRecord(args);
    throw ArgumentError.value(id, 'id', 'X1 동작이 아니다');
  }

  /// 🆕 E16t3c — 비상 시작(옛 종이 코드 = 슬롯 칸 · 한 번 쓰고 비운다 · 새 카드 = 흐름 객체 · 결정 id = `X1EMG-<명령 id>`).
  Future<SafetyActionResult> _emergencyStart(Map<String, String> args) async {
    const SafetyActionId id = SafetyActionId.x1EmergencyStart;
    final SupabaseX1Emergency? flow = _rt.x1Emergency;
    if (flow == null) {
      return _closed('X1 비상 시작(기기 id · Supabase 조립 없음)');
    }
    final String run = _commandId(args);
    final String? code = _rt.secrets.x1RecoveryCodeDraft();
    // 🔴 평문은 이 한 번에만 — 통과 · 거부 모두 칸을 비운다.
    _rt.secrets.clearX1RecoveryCode();
    if (_rt.files.liveIfExists() != null) {
      return _result(id, run, X1RestoreResultCodes.liveExists);
    }
    return _result(
      id,
      run,
      await flow.start(recoveryCode: code ?? '', decisionId: 'X1EMG-$run'),
    );
  }

  /// 🆕 E16t3c — 재발급 항목 하나(값 = 슬롯 칸 → 지문만 · 칸 비움 · 옛 지문 = 이 폰 금고 · 판정 = core 체크리스트).
  Future<SafetyActionResult> _reissueRecord(Map<String, String> args) async {
    const SafetyActionId id = SafetyActionId.x1ReissueRecord;
    final String? runId = args['run_id'];
    final ReissueItem? item = ReissueItem.values
        .where((ReissueItem i) => i.wire == args['item'])
        .firstOrNull;
    if (runId == null || runId.trim().isEmpty || item == null) {
      throw ArgumentError.value(args, 'args', 'run_id · item 필요');
    }
    final String run = _commandId(args);
    final String? value = item.hasSecret ? _rt.secrets.x1ReissueDraft() : null;
    _rt.secrets.clearX1Reissue();
    final String? fp = value == null ? null : secretFingerprint(value);
    final Set<String> prior = await _priorFingerprints(item);
    return _result(
      id,
      run,
      SqliteX1EmergencyStore(_rt.files.sim).recordReissue(
        runId: runId,
        item: item,
        fingerprint: fp,
        priorFingerprints: prior,
        trustedNowUtc: _rt.trusted.trustedNowUtc(),
      ),
    );
  }

  /// 🔴 옛 값 지문 — 이 폰 금고의 같은 서비스 칸(KIS = 세 세트 앱키 · 감시 = 핑 키) · 금고 없음 = 빈 집합 ·
  /// 못 읽음 = 던진다(대조 없이 받지 않는다).
  Future<Set<String>> _priorFingerprints(ReissueItem item) async {
    final List<SecretId> ids = switch (item) {
      ReissueItem.kisAppKey => <SecretId>[
        for (final KisKeySet s in KisKeySet.values)
          KisCredentialSlots.of(s).appKey,
      ],
      ReissueItem.watchdogPingKey => <SecretId>[HealthchecksClient.pingKeyId],
      ReissueItem.messengerToken ||
      ReissueItem.githubPat ||
      ReissueItem.supabaseSession ||
      ReissueItem.googleAccess => const <SecretId>[],
    };
    final SecretVault? vault = _rt.vault;
    if (vault == null) return const <String>{};
    final Set<String> out = <String>{};
    for (final SecretId i in ids) {
      final String? v = await vault.read(i);
      if (v != null && v.trim().isNotEmpty) {
        out.add(secretFingerprint(v.trim()));
      }
    }
    return out;
  }

  Future<SafetyActionResult> _plan(
    SafetyActionId id,
    Map<String, String> args,
  ) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('기기 이전: 화면 상태 없음(온보딩 전)');
    final String? device = _rt.deviceId;
    if (device == null) throw StateError('기기 이전: 이 기기 id 없음');
    final String run = _commandId(args);
    final SqliteX1PlanStepper s = SqliteX1PlanStepper(
      v.db,
      deviceId: device,
      runMode: v.flags.runMode,
      trusted: _rt.trusted,
      clock: _rt.clock,
      watchdog: _rt.watchdogRemote,
    );
    if (id == SafetyActionId.x1PlanStart) {
      if (v.flags.runMode != RunMode.live) {
        return _result(id, run, MigrationStartCodes.liveOnly);
      }
      final ({String? runId, String? code}) r = s.start(
        operatingMode: v.flags.operatingMode,
        decisionId: 'D03-$run',
      );
      return _result(id, run, r.code);
    }
    final String? runId = args['run_id'];
    final PlanStep? step = PlanStep.values
        .where((PlanStep p) => p.wire == args['step'])
        .firstOrNull;
    if (runId == null || runId.trim().isEmpty || step == null) {
      throw ArgumentError.value(args, 'args', 'run_id · step 필요');
    }
    if (id == SafetyActionId.x1PlanAbort) {
      return _result(id, run, s.abort(runId, step));
    }
    if (!x1PlanStepOpen(step)) return _closed('X1 ${step.wire}');
    return _result(
      id,
      run,
      await s.step(runId, step, operatingMode: v.flags.operatingMode),
    );
  }

  Future<SafetyActionResult> _recoveryStep(Map<String, String> args) async {
    const SafetyActionId id = SafetyActionId.x1RecoveryStep;
    final String? device = _rt.deviceId;
    final Database? live = _rt.files.liveIfExists();
    if (device == null || live == null) {
      throw StateError('X1 복구: 이 기기 id · live 원장 없음');
    }
    final RecoveryStep? step = RecoveryStep.values
        .where((RecoveryStep s) => s.wire == args['step'])
        .firstOrNull;
    if (step == null) throw ArgumentError.value(args, 'args', 'step 필요');
    final String run = _commandId(args);
    final SqliteRecoveryGate gate = SqliteRecoveryGate(
      live,
      deviceId: device,
      trusted: _rt.trusted,
      clock: _rt.clock,
      kr: _rt.calendars.kr,
    );
    final MigrationObservationConfig? obs =
        _rt.operations?.migrationObservation;
    switch (step) {
      case RecoveryStep.restored:
      case RecoveryStep.gapRebuilt:
        return _closed('X1 ${step.wire}(백업 바이트 D9 · 브로커 체결 연결)');
      case RecoveryStep.goldenSelfTest:
        if (_rt.golden == null) return _closed('X1 골든(실행기 없음)');
        final ({bool? passed, String? rejectCode}) g = await gate
            .runGoldenSelfTest(_OperatorGoldenSelfTest(_rt, live));
        return _result(
          id,
          run,
          g.rejectCode ??
              (g.passed == false ? MigrationGateCodes.goldenFailed : null),
        );
      case RecoveryStep.checklistConfirmed:
        if (obs == null) return _closed('X1 확인 목록(운영 설정 없음)');
        return _result(
          id,
          run,
          gate.confirmChecklist(decisionId: 'X1CL-$run', config: obs),
        );
      case RecoveryStep.biometricConfirmed:
        if (obs == null) return _closed('X1 생체(운영 설정 없음)');
        final Future<BiometricOutcome> Function()? sign = _rt.biometricSign;
        if (sign == null) {
          return _result(id, run, SettingsResultCodes.biometricUnavailable);
        }
        final BiometricOutcome o = await sign();
        if (o == BiometricOutcome.unavailable) {
          return _result(id, run, SettingsResultCodes.biometricUnavailable);
        }
        if (o != BiometricOutcome.ok) {
          throw StateError('X1 생체: 사람이 취소했다(쓰기 0)');
        }
        return _result(
          id,
          run,
          gate.confirmBiometric(decisionId: 'X1BIO-$run', config: obs),
        );
    }
  }
}
