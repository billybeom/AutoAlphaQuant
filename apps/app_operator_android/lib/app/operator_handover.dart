// 🆕 E11q-c1 — M5-11 simToAuto 위저드 operator 판(설계 13 §8 R191 · 01 §35 K167~K176 · 06 `M4-12` ⑪ · 미결 207).
//
// 🔴 읽기 = 모의 파일 + 실전 파일(있을 때만) → data_sync 원천 → 엔진 VM(`handoverWizardVmOf`) · 원장 변경 · 동작 뒤 · 주기마다
//    다시 낸다(냉각 끝 · 확정 기한 = 새 VM — 화면 카운트다운 0) · 같은 값 = 다시 내지 않음 · `handoverStatus` = 같은 흐름(K173).
// 🔴 바깥 사실 — 골든 = 지금 지문과 같은 마지막 기록(없음 = 아직) · 실전 키 = 아직(이 빌드에 실전 키 조회 검증 경로 0 · 미결 207 ⓑ) ·
//    계좌 별칭 · 설정 지문 = 모의 개시 판(`currentP0sOpsConfig`) · 관찰 일수 = 운영 설정(`live_dry_run_observation_trading_days`).
// 🔴 쓰기(`SettingsActions.run` 의 handover 4 · args = 엔진이 행에 완성한 그대로 — 꼴이 틀리면 [ArgumentError]):
//    · S5 고름 = 모의 파일(엔진 저장 · 세션 전).
//    · 세션 시작 = 생체 1회(런타임 · 없음 = 할 수 없음) → 엔진 사전 판정(생체 → 신뢰 시각 → 전제 → S1~S5 → 이미 세션) →
//      통과 뒤에만 실전 파일을 연다(없으면 만든다 · 미결 207 ⓒ) → 엔진 저장이 신뢰 시각으로 다시 판정해 연다.
//    · 취소 = 실전 파일(없음 = `HANDOVER_SESSION_INVALID`).
//    · 확정 = 엔진 1단계 관문(시각 → 세션 → 리스 → 이미 → 승인 config(R192) → 재판정 → 계좌 조회) — 🔴 실전 계좌 조회 포트 · 오케스트레이터
//      `runSimToAutoSwitch` 배선 = 207 ⓖ 다음 조각 → 지금 확정은 관문의 거부 원문으로 끝난다(조회 0 = `…_ACCOUNT_PROBE_MISSING` · 쓰기 0).
// 🔴 신뢰 시각 = 런타임 시계(E11k 전 = 모름 → 시작 · 확정 = `SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE` 원문 · 우회 0 · K176).

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        GoldenRecordView,
        HandoverSessionCodes,
        HandoverSessionRecord,
        LeaseSnapshot,
        LiveAccountProbe,
        SimLedgerFate,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimToAutoReport,
        handoverActionResultOf,
        handoverSessionHeadline,
        judgeSimToAuto,
        kDeviceGoldenSuite,
        simLedgerFateResultText,
        simToAutoCommitHeadline,
        simToAutoCommitReject,
        simToAutoOpenReject;
import 'package:data_sync/data_sync.dart'
    show
        HandoverSessionOutcome,
        OpsConfigRead,
        OpsConfigReady,
        SqliteHandoverSessionStore,
        SqliteHandoverWizardSource,
        SqliteLeaseGate,
        SqliteSimLedgerFateStore,
        currentP0sOpsConfig,
        readSimToAutoCarry,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        HandoverPath,
        HandoverRepository,
        HandoverWizardVm,
        RunMode,
        SettingsActionId;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_golden.dart' show OperatorGolden;
import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 위저드 동작 id(이 판이 받는 넷).
const Set<SettingsActionId> kOperatorHandoverActions = <SettingsActionId>{
  SettingsActionId.handoverSimLedgerFate,
  SettingsActionId.handoverSessionStart,
  SettingsActionId.handoverSessionCancel,
  SettingsActionId.handoverCommit,
};

/// 🔴 골든 사실(207 ⓓ) — 실행기 «전량» 전 · 자산 전 · 지금 지문과 다른 기록 · 기록 없음 = null(아직) · 같은 지문 = 전량 통과인가.
bool? operatorGoldenPassedOf(OperatorGolden? golden, Database db) {
  if (!kDeviceGoldenSuite.complete) return null;
  final String? digest = golden?.prepared?.digest;
  if (digest == null) return null;
  final GoldenRecordView? last = OperatorGolden.lastRecord(db);
  if (last == null || last.digest != digest) return null;
  return last.ok;
}

/// M5-11 위저드 operator 판(읽기 원천 + handover 동작 4).
class OperatorHandover {
  /// 만든다 — [goldenPassed] · [liveKeysVerified] = 바깥 사실 원천(기본 = 런타임 골든 기록 · 실전 키 «아직» — 이 빌드에 실전 키
  /// 조회 검증 경로 0 · 미결 207 ⓑ — 그 조각이 여기에 넣는다).
  OperatorHandover(
    this._rt, {
    this._goldenPassed,
    bool? Function()? liveKeysVerified,
  }) : _liveKeys = liveKeysVerified;

  final OperatorRuntime _rt;
  final bool? Function()? _goldenPassed;
  final bool? Function()? _liveKeys;
  final StreamController<void> _bump = StreamController<void>.broadcast();
  int _seq = 0;

  /// 동작 · 골든 준비 뒤 다시 읽으라는 신호.
  Stream<void> get bumps => _bump.stream;

  String _runId() =>
      'ar_op_hs_${_rt.clock.nowUtc().microsecondsSinceEpoch}_${++_seq}';

  /// 원천([canAct] = 쓰기 창구 유무) — 관찰 설정이 없으면 [StateError](지어내지 않는다).
  SqliteHandoverWizardSource source({required bool canAct}) {
    final observation = _rt.liveObservation;
    if (observation == null) {
      throw StateError('위저드: 운영 설정(관찰 일수) 없음');
    }
    final Database sim = _rt.files.sim;
    final OpsConfigRead cfg = currentP0sOpsConfig(sim);
    return SqliteHandoverWizardSource(
      sim: sim,
      live: _rt.files.liveIfExists(),
      clock: _rt.clock,
      trusted: _rt.trusted,
      kr: _rt.calendars.kr,
      observation: observation,
      goldenVectorPassed:
          _goldenPassed?.call() ?? operatorGoldenPassedOf(_rt.golden, sim),
      liveKeysVerified: _liveKeys?.call(),
      accountByStrategy: cfg is OpsConfigReady
          ? cfg.config.human.accountByStrategy
          : const <String, String>{},
      currentConfigHash: cfg is OpsConfigReady ? cfg.configHash : null,
      canAct: canAct,
    );
  }

  /// 골든 자산 지문을 한 번 준비한다(못 읽으면 원천 없음 그대로 · 준비되면 다시 읽기).
  Future<void> prepareGolden() async {
    try {
      await _rt.golden?.prepare();
    } on Object {
      return;
    }
    if (!_bump.isClosed) _bump.add(null);
  }

  ActionResult _done(SettingsActionId id, String? code, String headline) {
    final ActionResult r = handoverActionResultOf(
      id: id,
      actionRunId: _runId(),
      code: code,
      headline: headline,
    );
    if (!_bump.isClosed) _bump.add(null);
    return r;
  }

  void _args(Map<String, String> args, String key, SettingsActionId id) {
    if (args.length != 1 || !args.containsKey(key)) {
      throw ArgumentError('${id.name} args = {$key} 하나');
    }
  }

  /// 🔴 handover 동작 4(그 밖 id = [ArgumentError] · 앱 = 전부 받기 switch 0 — C-12).
  Future<ActionResult> run(
    SettingsActionId id,
    Map<String, String> args,
  ) async {
    if (id == SettingsActionId.handoverSimLedgerFate) return _fate(args);
    if (id == SettingsActionId.handoverSessionStart) return _start(args);
    if (id == SettingsActionId.handoverSessionCancel) return _cancel(args);
    if (id == SettingsActionId.handoverCommit) return _commit(args);
    throw ArgumentError.value(id, 'id', '위저드 동작이 아니다');
  }

  ActionResult _fate(Map<String, String> args) {
    const SettingsActionId id = SettingsActionId.handoverSimLedgerFate;
    _args(args, 'fate', id);
    SimLedgerFate? fate;
    for (final SimLedgerFate f in SimLedgerFate.values) {
      if (f.wire == args['fate']) fate = f;
    }
    if (fate == null) {
      throw ArgumentError.value(args['fate'], 'fate', 'KEEP · DISCARD');
    }
    final Database sim = _rt.files.sim;
    final OpsConfigRead cfg = currentP0sOpsConfig(sim);
    final String? code = SqliteSimLedgerFateStore(
      sim,
      clock: _rt.clock,
    ).choose(fate, configHash: cfg is OpsConfigReady ? cfg.configHash : '');
    return _done(id, code, simLedgerFateResultText(fate, code));
  }

  SimToAutoReport _judge(SimToAutoFacts f) => judgeSimToAuto(
    f,
    kr: _rt.calendars.kr,
    observation: _rt.liveObservation!,
  );

  Future<ActionResult> _start(Map<String, String> args) async {
    const SettingsActionId id = SettingsActionId.handoverSessionStart;
    _args(args, 'path', id);
    if (args['path'] != HandoverPath.simToAuto.wire) {
      throw ArgumentError.value(args['path'], 'path', 'SIM_TO_AUTO 하나');
    }
    final SqliteHandoverWizardSource src = source(canAct: true);
    final Future<BiometricOutcome> Function()? ask = _rt.biometricSign;
    final bool confirmed = ask != null && (await ask()) == BiometricOutcome.ok;
    final DateTime? now = _rt.trusted.trustedNowUtc()?.toUtc();
    final SimToAutoFacts f = src.facts(trustedNowUtc: now, session: null);
    // 엔진 사전 판정(세션 칸 = 없음 · 저장과 같은 차례) — 거부면 실전 파일을 만들지 않는다.
    final String? pre = simToAutoOpenReject(
      biometricConfirmed: confirmed,
      trustedNowUtc: now,
      report: _judge(f),
    );
    if (pre != null) return _done(id, pre, handoverSessionHeadline(pre));
    final String? device = _rt.deviceId;
    if (device == null) throw StateError('전환 시작: 이 기기 id 없음');
    // 사전 판정 통과 = 모의 자동 매매 현재 행 있음(전제).
    final RunMode mode = f.simRunMode!;
    final HandoverSessionOutcome o =
        SqliteHandoverSessionStore(
          _rt.files.openLive(),
          clock: _rt.clock,
          trusted: _rt.trusted,
        ).openSimToAuto(
          biometricConfirmed: confirmed,
          facts: f,
          kr: _rt.calendars.kr,
          observation: _rt.liveObservation!,
          deviceId: device,
          leaseEpoch: SqliteLeaseGate(
            _rt.files.sim,
            mode: mode,
            clock: _rt.clock,
          ).epoch(),
        );
    return _done(id, o.reasonCode, o.headline);
  }

  ActionResult _cancel(Map<String, String> args) {
    const SettingsActionId id = SettingsActionId.handoverSessionCancel;
    _args(args, 'handover_session_id', id);
    final Database? live = _rt.files.liveIfExists();
    if (live == null) {
      return _done(
        id,
        HandoverSessionCodes.sessionInvalid,
        handoverSessionHeadline(HandoverSessionCodes.sessionInvalid),
      );
    }
    final HandoverSessionOutcome o = SqliteHandoverSessionStore(
      live,
      clock: _rt.clock,
      trusted: _rt.trusted,
    ).cancel(args['handover_session_id']!);
    return _done(id, o.reasonCode, o.headline);
  }

  Future<ActionResult> _commit(Map<String, String> args) async {
    const SettingsActionId id = SettingsActionId.handoverCommit;
    _args(args, 'handover_session_id', id);
    final SqliteHandoverWizardSource src = source(canAct: true);
    final DateTime? now = _rt.trusted.trustedNowUtc()?.toUtc();
    final Database? live = _rt.files.liveIfExists();
    final HandoverSessionRecord? session = live == null
        ? null
        : SqliteHandoverSessionStore(
            live,
            clock: _rt.clock,
            trusted: _rt.trusted,
          ).session(args['handover_session_id']!);
    final SimToAutoFacts f = src.facts(trustedNowUtc: now, session: session);
    // 리스 = 운영 중인 파일(모의) — 모드 행이 없으면 관문이 시각 · 세션 · 재판정에서 먼저 거부한다.
    final SqliteLeaseGate gate = SqliteLeaseGate(
      _rt.files.sim,
      mode: f.simRunMode ?? RunMode.simInternal,
      clock: _rt.clock,
    );
    final OpsConfigRead cfg = currentP0sOpsConfig(_rt.files.sim);
    final int liveRows = live == null
        ? 0
        : live.select('SELECT COUNT(*) AS n FROM mode_transition').first['n']!
              as int;
    final String code =
        simToAutoCommitReject(
          trustedNowUtc: now,
          session: session,
          lease: LeaseSnapshot(
            verdict: await gate.check(),
            epoch: gate.epoch(),
            deviceId: _rt.deviceId ?? '',
          ),
          liveModeRows: liveRows,
          // 🆕 R192 — 승인 판(승인 기록과 맞는 것만) = 지금 설정이어야 한다(SAF-405 · 없음 = `…_CONFIG_NOT_APPROVED`).
          approvedConfigHash: readSimToAutoCarry(_rt.files.sim)
              .approvedConfigHash,
          configHash: cfg is OpsConfigReady ? cfg.configHash : '',
          report: now == null || session == null ? null : _judge(f),
          aliases: f.accountByStrategy.values.toSet(),
          // 🔴 실전 계좌 조회 포트 = 207 ⓖ 다음 조각 — 그 전 = 조회 0(관문이 `…_ACCOUNT_PROBE_MISSING` 로 거부 · 쓰기 0).
          probes: const <LiveAccountProbe>[],
        ) ??
        SimToAutoCommitCodes.probeMissing;
    return _done(id, code, simToAutoCommitHeadline(code));
  }

  /// 닫는다(시험).
  Future<void> close() => _bump.close();
}

Stream<T> _merge<T>(List<Stream<T>> streams) {
  late final StreamController<T> c;
  final List<StreamSubscription<T>> subs = <StreamSubscription<T>>[];
  c = StreamController<T>(
    onListen: () {
      for (final Stream<T> s in streams) {
        subs.add(s.listen(c.add, onError: c.addError));
      }
    },
    onCancel: () async {
      for (final StreamSubscription<T> s in subs) {
        await s.cancel();
      }
      await c.close();
    },
  );
  return c.stream;
}

/// 위저드 읽기(operator · `m5HandoverWizard` · `handoverStatus` 같은 흐름 — K173).
class OperatorHandoverRepository implements HandoverRepository {
  /// 만든다 — [canAct] = 위저드 쓰기 창구(설정 동작 인스턴스)가 있나 · [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorHandoverRepository(
    this._rt,
    this._handover, {
    required this.canAct,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;
  final OperatorHandover _handover;

  /// 쓰기 창구가 있나(없으면 행 동작 0).
  final bool canAct;

  /// 다시 읽는 주기.
  final Duration tick;

  HandoverWizardVm _read(OperatorView _) =>
      _handover.source(canAct: canAct).wizard();

  @override
  Stream<HandoverWizardVm> watchWizard() {
    unawaited(_handover.prepareGolden());
    return followView<HandoverWizardVm>(
      view: _rt.view,
      changes: (OperatorView v) =>
          _merge<HandoverWizardVm>(<Stream<HandoverWizardVm>>[
            watchLedgerQuery<HandoverWizardVm>(
              _rt.files.sim,
              SqliteHandoverWizardSource.simTables,
              () => _read(v),
            ),
            if (_rt.files.liveIfExists() case final Database live)
              watchLedgerQuery<HandoverWizardVm>(
                live,
                SqliteHandoverWizardSource.liveTables,
                () => _read(v),
              ),
            _handover.bumps.map((_) => _read(v)),
          ]),
      now: _read,
      tick: tick,
      noView: () => StateError('위저드: 화면 상태 없음(온보딩 전)'),
    );
  }
}
