// 🆕 E11q-c1 — M5-11 simToAuto 위저드 operator 판(설계 13 §8 R191 · 01 §35 K167~K176 · 06 `M4-12` ⑪ · 미결 207).
//
// 🔴 읽기 = 모의 파일 + 실전 파일(있을 때만) → data_sync 원천 → 엔진 VM(`handoverWizardVmOf`) · 원장 변경 · 동작 뒤 · 주기마다
//    다시 낸다(냉각 끝 · 확정 기한 = 새 VM — 화면 카운트다운 0) · 같은 값 = 다시 내지 않음 · `handoverStatus` = 같은 흐름(K173).
// 🔴 바깥 사실 — 골든 = 지금 지문과 같은 마지막 기록(없음 = 아직) · 🆕 R196 실전 키 = 대응표 세트의 조회 검증 기록(207 ⓑ) ·
//    계좌 별칭 · 설정 지문 = 모의 개시 판(`currentP0sOpsConfig`) · 관찰 일수 = 운영 설정(`live_dry_run_observation_trading_days`).
// 🔴 쓰기(`SettingsActions.run` 의 handover 4 · args = 엔진이 행에 완성한 그대로 — 꼴이 틀리면 [ArgumentError]):
//    · S5 고름 = 모의 파일(엔진 저장 · 세션 전).
//    · 세션 시작 = 생체 1회(런타임 · 없음 = 할 수 없음) → 엔진 사전 판정(생체 → 신뢰 시각 → 전제 → S1~S5 → 이미 세션) →
//      통과 뒤에만 실전 파일을 연다(없으면 만든다 · 미결 207 ⓒ) → 엔진 저장이 신뢰 시각으로 다시 판정해 연다.
//    · 취소 = 실전 파일(없음 = `HANDOVER_SESSION_INVALID`).
//    · 확정 = 🆕 R202(207 ⓖ) ① 엔진 1단계 관문(시각 → 세션 → 리스 → 이미 → 승인 config(R192) → 재판정 → 계좌 조회)을 조회 0 으로 먼저 본다
//      (다른 사유 = 그 원문 · 네트워크 · 바깥 감시 0) → ② 대응표 계좌마다 실전 조회(조회 TR 만 · 주문 0) → ③ 관문 다시 →
//      ④ 통과 때만 엔진 오케스트레이터 `runSimToAutoSwitch`(새 감시 체크 → 실전 커밋 → 모의 마감 → 옛 체크 멈춤) · 감시 원격 없음 = 준비 실패 원문.
//      🆕 R207 커밋 뒤 실전 잡 = 같은 «별칭 → 세트»(`liveAccountKeyOf`)의 KIS 계좌 브로커 · 실주문은 운영 리스(E11k) · dryRun 이 막는다.
// 🔴 신뢰 시각 = 런타임 시계(E11k 전 = 모름 → 시작 · 확정 = `SIM_TO_AUTO_TRUSTED_TIME_UNAVAILABLE` 원문 · 우회 0 · K176).

import 'dart:async';

import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentialRead,
        KisCredentials,
        KisCredentialsStored,
        KisOrderBroker,
        KisRestClient,
        KisTokenStore,
        MemoryKisTokenStore,
        readKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        BiometricOutcome,
        GoldenRecordView,
        HandoverSessionCodes,
        HandoverSessionRecord,
        LeaseSnapshot,
        LiveAccountProbe,
        SecretVault,
        SimLedgerFate,
        SimToAutoCommitCodes,
        SimToAutoFacts,
        SimToAutoReport,
        SimToAutoSwitchCommit,
        SimToAutoSwitchResult,
        WatchdogRemote,
        handoverActionResultOf,
        handoverSessionHeadline,
        judgeSimToAuto,
        kDeviceGoldenSuite,
        kSimToAutoWatchdogPrepareFailed,
        kSimToAutoWatchdogPrepareFailedHeadline,
        kstDateText,
        liveKeysVerifiedOf,
        probeLiveAccount,
        requiredLiveKeyKindsOf,
        simLedgerFateResultText,
        simToAutoCommitHeadline,
        simToAutoCommitReject,
        simToAutoOpenReject,
        runSimToAutoSwitch,
        watchdogCheckPrefix;
import 'package:data_sync/data_sync.dart'
    show
        HandoverSessionOutcome,
        OpsConfigRead,
        OpsConfigReady,
        SimToAutoCarry,
        SimToAutoCommitOutcome,
        SqliteHandoverSessionStore,
        SqliteHandoverWizardSource,
        SqliteLeaseGate,
        SqliteSimLedgerFateStore,
        SqliteSimToAutoCommitStore,
        credentialRecordsOf,
        currentP0sOpsConfig,
        finishSimToAuto,
        readSimToAutoCarry,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        HandoverPath,
        HandoverRepository,
        HandoverWizardVm,
        OperatingMode,
        RunMode,
        SettingsActionId,
        TradeDate;
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show watchdogCheckSpecsFor;

import '../engine/kis_sessions.dart'
    show LiveAccountKey, kisCredentialsWithProduct, liveAccountKeyOf;
import '../engine/lease_wiring.dart' show operatorLeaseGate;
import 'operator_golden.dart' show OperatorGolden;
import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 🆕 R202 — 실전 조회 클라이언트(세트 자격증명 · 공유 토큰 저장소 — 시험 = 가짜 HTTP).
typedef KisProbeClientOf = KisRestClient Function(
  KisCredentials credentials,
  KisTokenStore tokens,
);

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
  /// 만든다 — [goldenPassed] · [liveKeysVerified] = 바깥 사실 원천을 갈음하는 자리(시험) · 기본 = 런타임 골든 기록 ·
  /// 🆕 R196 실전 키 = 대응표 세트의 조회 검증 기록(모의 파일 `credential_registry` · 207 ⓑ).
  OperatorHandover(
    this._rt, {
    this._goldenPassed,
    bool? Function()? liveKeysVerified,
    this._clientOf,
  }) : _liveKeys = liveKeysVerified;

  final OperatorRuntime _rt;
  final bool? Function()? _goldenPassed;
  final bool? Function()? _liveKeys;
  final KisProbeClientOf? _clientOf;
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
    final Map<String, String> accounts = cfg is OpsConfigReady
        ? cfg.config.human.accountByStrategy
        : const <String, String>{};
    return SqliteHandoverWizardSource(
      sim: sim,
      live: _rt.files.liveIfExists(),
      clock: _rt.clock,
      trusted: _rt.trusted,
      kr: _rt.calendars.kr,
      observation: observation,
      goldenVectorPassed:
          _goldenPassed?.call() ?? operatorGoldenPassedOf(_rt.golden, sim),
      // 🆕 R196(207 ⓑ) — 대응표가 쓰는 실전 세트가 모두 조회 검증 통과(모의 파일 `credential_registry`).
      liveKeysVerified: _liveKeys != null
          ? _liveKeys()
          : liveKeysVerifiedOf(
              required: requiredLiveKeyKindsOf(accounts),
              records: credentialRecordsOf(sim),
            ),
      accountByStrategy: accounts,
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
    final Database sim = _rt.files.sim;
    final Database? live = _rt.files.liveIfExists();
    final String sessionId = args['handover_session_id']!;
    final HandoverSessionRecord? session = live == null
        ? null
        : SqliteHandoverSessionStore(
            live,
            clock: _rt.clock,
            trusted: _rt.trusted,
          ).session(sessionId);
    final SimToAutoFacts f = src.facts(trustedNowUtc: now, session: session);
    // 리스 = 운영 중인 파일(모의) — 모드 행이 없으면 관문이 시각 · 세션 · 재판정에서 먼저 거부한다.
    // 🆕 R229 — 원격 = simBroker 원장일 때만(simInternal = 로컬 단독 그대로).
    final SqliteLeaseGate leaseGate = operatorLeaseGate(
      sim,
      mode: f.simRunMode ?? RunMode.simInternal,
      clock: _rt.clock,
      remote: _rt.leaseRemote,
    );
    final LeaseSnapshot lease = LeaseSnapshot(
      verdict: await leaseGate.check(),
      epoch: leaseGate.epoch(),
      deviceId: _rt.deviceId ?? '',
    );
    final OpsConfigRead cfg = currentP0sOpsConfig(sim);
    final String configHash = cfg is OpsConfigReady ? cfg.configHash : '';
    // 🆕 R192 — 승인 판(승인 기록과 맞는 것만) = 지금 설정이어야 한다(SAF-405 · 없음 = `…_CONFIG_NOT_APPROVED`).
    final SimToAutoCarry carry = readSimToAutoCarry(sim);
    final int liveRows = live == null
        ? 0
        : live.select('SELECT COUNT(*) AS n FROM mode_transition').first['n']!
              as int;
    String? gate(List<LiveAccountProbe> probes) => simToAutoCommitReject(
      trustedNowUtc: now,
      session: session,
      lease: lease,
      liveModeRows: liveRows,
      approvedConfigHash: carry.approvedConfigHash,
      configHash: configHash,
      report: now == null || session == null ? null : _judge(f),
      aliases: f.accountByStrategy.values.toSet(),
      probes: probes,
    );
    // 🆕 R202(207 ⓖ) ① 엔진 관문(조회 0) — 계좌 조회 말고 다른 사유로 막히면 네트워크 · 바깥 감시를 건드리지 않는다.
    final String? before = gate(const <LiveAccountProbe>[]);
    if (before != SimToAutoCommitCodes.probeMissing) {
      final String code = before ?? SimToAutoCommitCodes.probeMissing;
      return _done(id, code, simToAutoCommitHeadline(code));
    }
    // ② 실전 계좌 조회(조회만 · 신뢰 시각 = 조회 시각 · 5분 신선도) → ③ 관문 다시.
    final List<LiveAccountProbe> probes = await _probes(
      f.accountByStrategy,
      at: now!,
    );
    final String? after = gate(probes);
    if (after != null) return _done(id, after, simToAutoCommitHeadline(after));
    // ④ 통과 = 엔진 오케스트레이터(새 감시 체크 → 실전 커밋(저장이 트랜잭션 안에서 관문을 다시 본다) → 모의 마감 → 옛 체크 멈춤).
    final WatchdogRemote? remote = _rt.watchdogRemote;
    if (remote == null) {
      return _done(
        id,
        kSimToAutoWatchdogPrepareFailed,
        kSimToAutoWatchdogPrepareFailedHeadline,
      );
    }
    final SimToAutoSwitchResult r = await runSimToAutoSwitch(
      remote: remote,
      newSpecs: watchdogCheckSpecsFor(RunMode.live, OperatingMode.autoTrade),
      newPrefix: watchdogCheckPrefix(RunMode.live, OperatingMode.autoTrade),
      oldPrefix: watchdogCheckPrefix(
        f.simRunMode ?? RunMode.simInternal,
        OperatingMode.autoTrade,
      ),
      commit: () async {
        final SimToAutoCommitOutcome c =
            SqliteSimToAutoCommitStore(
              live!,
              clock: _rt.clock,
              trusted: _rt.trusted,
            ).commit(
              sessionId: sessionId,
              simFacts: f,
              kr: _rt.calendars.kr,
              observation: _rt.liveObservation!,
              probes: probes,
              configHash: configHash,
              lease: lease,
              carry: carry,
            );
        return c.ok
            ? SimToAutoSwitchCommit.ok(c.decisionId!, c.headline)
            : SimToAutoSwitchCommit.no(c.reasonCode!, c.headline);
      },
      // 🔴 모의 마감 = CLOSE 행 · 지움(S5 DISCARD)은 모의 파일 연결을 닫은 뒤 = 기동 복구 몫(`deleteClosedSimLedger` · 다음 조각).
      finish: () async {
        finishSimToAuto(liveDb: live!, simDb: sim, clock: _rt.clock);
      },
    );
    return _done(id, r.committed ? null : r.code, r.headline);
  }

  /// 🆕 R202(207 ⓖ) — 대응표 계좌마다 실전 조회(별칭 → 세트 · 연금저축 = 상품코드 22 · 같은 앱키 = 같은 토큰 저장소 — 1분 1회 발급) ·
  /// 금고 · 검증 HTTP 없음 · 키 없음 · 조회 실패 = 그 계좌 조회 0(관문 `PROBE_MISSING` · fail-closed) · 🔴 조회 TR 만(주문 0).
  Future<List<LiveAccountProbe>> _probes(
    Map<String, String> accounts, {
    required DateTime at,
  }) async {
    final SecretVault? vault = _rt.vault;
    final KisProbeClientOf? clientOf = _clientOf ?? _defaultClientOf();
    if (vault == null || clientOf == null) return const <LiveAccountProbe>[];
    final KisTokenStore tokens = MemoryKisTokenStore();
    final List<String> aliases =
        accounts.values.map((String a) => a.trim()).toSet().toList()..sort();
    final List<LiveAccountProbe> out = <LiveAccountProbe>[];
    for (final String alias in aliases) {
      // 🆕 R207 — 별칭 → 세트 · 상품코드 = 실전 잡과 같은 함수(`liveAccountKeyOf`).
      final LiveAccountKey? key = liveAccountKeyOf(alias);
      if (key == null) continue;
      KisCredentials? creds;
      try {
        final KisCredentialRead read = await readKisCredentials(vault, key.set);
        if (read is KisCredentialsStored) creds = read.credentials;
      } on Object {
        creds = null;
      }
      if (creds == null) continue;
      final KisCredentials use = kisCredentialsWithProduct(
        creds,
        key.productCode,
      );
      final LiveAccountProbe? p = await probeLiveAccount(
        alias: alias,
        broker: KisOrderBroker(clientOf(use, tokens)),
        today: TradeDate(kstDateText(at)),
        fetchedAtUtc: at,
      );
      if (p != null) out.add(p);
    }
    return out;
  }

  KisProbeClientOf? _defaultClientOf() {
    final http.Client? net = _rt.kisHttp;
    if (net == null) return null;
    return (KisCredentials c, KisTokenStore tokens) =>
        KisRestClient(net, c, environment: c.environment, tokens: tokens);
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
