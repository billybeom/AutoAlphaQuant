// 운영 상태 원천 operator 판(E11p3d-2 · 설계 13 §8 R109 · 06 M1-12 · 앱 04 §7 `W-01`).
//
// 🔴 감시 보드 = 엔진 로컬 판정(잡 표 × `job_run` · 마지막 회차) + 바깥 대조(healthchecks 체크 목록) → `buildWatchdogBoard`.
//    바깥을 못 읽으면(키 없음 · 네트워크) 행은 로컬 그대로 · 머리 문구만 «바깥을 읽지 못했습니다»(R45).
// 🔴 다시 낸다 = 들을 때 · `job_run` 이 바뀔 때(같은 연결) · 1분마다(유예가 지나 «대기 → 실패»로 넘어가는 것) · 화면 상태가 바뀔 때.
//    바깥 목록은 5분 동안 다시 묻지 않는다(호출 아끼기).
// 🔴 화면 상태가 없으면(온보딩 전) 체크도 없다 — 빈 보드(«등록된 워치독 체크가 아직 없습니다»).
// 🔵 진단 = 원장 진단 원천(E13c2) · 연결 · 기기 접근 · 백업 · 연간 = 원천 없음(R109 — 지어내지 않는다).
// 🆕 E11p3d-5h(R146) — 기기 · 접근(S06) = 엔진 `deviceAccessVmOf` · 사실 = 이 기기 id(실행 묶음 · R142) · 화면 상태 원장의 리스 판정
//    (`SqliteLeaseGate.check` — 주문을 막는 그 판정) · 다시 냄 = 들을 때 · 1분 · 리스 표(`sync_state`) · 화면 상태 변경(새 원장으로 감시를 옮긴다) ·
//    바뀐 값만 · 화면 상태 없음 · 기기 id 없음 = 오류(지어내지 않는다).
// 🆕 E11p3d-5f(R140) — 연결(S07) = 엔진 `connectionsVmOf` · 사실 = 키 검증 기록(S02 와 같은 원천) · healthchecks 목록(감시 보드와
//    같은 5분 캐시 · 키 없음 = «연결 안 됨» · 그 밖 실패 = «읽지 못했습니다») · 링크 = 셸 레지스트리에 본문이 있을 때만([hasBody]) ·
//    다시 냄 = 들을 때 · 1분 · sim 진척 표(키 검증) · 화면 상태 변경 · 바뀐 값만.
// 🆕 E11p3d-2c(R136) — 기기 리스크(H-03) = 플랫폼 측정(`OperatorRuntime.deviceProbe`) → 엔진 `deviceRiskVmOf` ·
//    들을 때 · [riskTick] 마다 다시 잰다 · 바뀐 값만 · 측정 실패 = 오류 한 번(다음 주기에 다시 잰다) · 측정기 없음(플랫폼 밖) = 원천 없음.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        ConnectionsFacts,
        DeviceAccessFacts,
        DeviceRiskFacts,
        HealthchecksReach,
        LeaseVerdict,
        RemoteCheck,
        WatchdogRemote,
        connectionsVmOf,
        deviceAccessVmOf,
        deviceRiskVmOf;
import 'package:data_sync/data_sync.dart'
    show
        HealthchecksError,
        HealthchecksErrorKind,
        LedgerDiagnosticsSource,
        SqliteJobRunLog,
        SqliteLeaseGate,
        modeStartedAtUtc,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AnnualReviewVm,
        BackupVm,
        ConnectionsVm,
        DeviceAccessVm,
        DeviceRiskVm,
        DiagnosticsVm,
        OpsStatusRepository,
        RunMode,
        TradeDate,
        WatchdogBoardVm;
import 'package:trading_runtime/trading_runtime.dart'
    show buildWatchdogBoard, kstDateOf, watchdogBoardInputsFor;

import 'operator_runtime.dart';
import 'operator_settings_repository.dart';
import 'operator_view.dart';

bool _noBody(String _) => false;

/// 운영 상태 원천(operator).
class OperatorOpsStatusRepository implements OpsStatusRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 내는 주기 · [remoteTtl] = 바깥 목록 재사용 시간 · [riskTick] = 기기 다시 재는 주기.
  OperatorOpsStatusRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
    this.remoteTtl = const Duration(minutes: 5),
    this.riskTick = const Duration(minutes: 5),
    this.hasBody = _noBody,
  });

  final OperatorRuntime _rt;

  /// 다시 내는 주기.
  final Duration tick;

  /// 바깥 목록 재사용 시간.
  final Duration remoteTtl;

  /// 🆕 R136 — 기기 다시 재는 주기(측정 = 채널 한 번 · 가볍다).
  final Duration riskTick;

  /// 🆕 R140 — 라우트 본문 유무(없으면 연결 행에 링크를 싣지 않는다).
  final bool Function(String route) hasBody;

  List<RemoteCheck>? _remote;
  DateTime? _remoteAt;
  Object? _remoteError;

  /// 🔴 바깥 체크 목록(없음 · 실패 = null — 보드가 «읽지 못했습니다»).
  Future<List<RemoteCheck>?> _remoteChecks(DateTime now) async {
    final WatchdogRemote? r = _rt.watchdogRemote;
    if (r == null) return null;
    final DateTime? at = _remoteAt;
    if (at != null && now.difference(at) < remoteTtl) return _remote;
    List<RemoteCheck>? got;
    Object? error;
    try {
      got = await r.checks();
    } on Object catch (e) {
      got = null;
      error = e;
    }
    _remote = got;
    _remoteError = error;
    _remoteAt = now;
    return got;
  }

  /// 🆕 R140 — healthchecks 에 닿았나(클라이언트 없음 · 읽기 키 없음 = 연결 전 · 그 밖 실패 = 읽지 못함).
  Future<(HealthchecksReach, List<RemoteCheck>)> _reach(DateTime now) async {
    if (_rt.watchdogRemote == null) {
      return (HealthchecksReach.notSet, const <RemoteCheck>[]);
    }
    final List<RemoteCheck>? got = await _remoteChecks(now);
    if (got != null) return (HealthchecksReach.read, got);
    final Object? e = _remoteError;
    return e is HealthchecksError && e.kind == HealthchecksErrorKind.missingKey
        ? (HealthchecksReach.notSet, const <RemoteCheck>[])
        : (HealthchecksReach.unreadable, const <RemoteCheck>[]);
  }

  /// 🆕 R140 — 지금 연결 화면(화면 상태 없음 = 모의로 본다 — 키 목록과 같은 축).
  Future<ConnectionsVm> connections() async {
    final DateTime now = _rt.clock.nowUtc();
    final (HealthchecksReach reach, List<RemoteCheck> checks) = await _reach(
      now,
    );
    return connectionsVmOf(
      ConnectionsFacts(
        runMode: _rt.view.value?.flags.runMode ?? RunMode.simInternal,
        kis: await OperatorSettingsRepository(_rt).paperFacts(),
        healthchecks: reach,
        checks: checks,
        hasBody: hasBody,
      ),
      nowUtc: now,
    );
  }

  bool _holiday(TradeDate today) {
    try {
      return !_rt.calendars.kr.isSession(today);
    } on StateError {
      return false;
    }
  }

  /// 지금 보드.
  Future<WatchdogBoardVm> board() async {
    final DateTime now = _rt.clock.nowUtc();
    final OperatorView? v = _rt.view.value;
    final List<RemoteCheck>? remote = await _remoteChecks(now);
    final bool holiday = _holiday(kstDateOf(now));
    if (v == null) {
      return buildWatchdogBoard(
        rows: const [],
        nowUtc: now,
        holiday: holiday,
        remote: remote,
      );
    }
    final SqliteJobRunLog log = SqliteJobRunLog(v.db);
    return buildWatchdogBoard(
      rows: watchdogBoardInputsFor(
        run: v.flags.runMode,
        op: v.flags.operatingMode,
        calendars: _rt.calendars,
        nowUtc: now,
        entriesOf: log.entriesOf,
        notBeforeUtc: modeStartedAtUtc(v.db),
      ),
      nowUtc: now,
      holiday: holiday,
      remote: remote,
    );
  }

  @override
  Stream<WatchdogBoardVm> watchWatchdog() {
    late final StreamController<WatchdogBoardVm> c;
    StreamSubscription<String>? dbSub;
    Timer? timer;
    bool busy = false;
    bool again = false;

    Future<void> emit() async {
      if (busy) {
        again = true;
        return;
      }
      busy = true;
      try {
        do {
          again = false;
          final WatchdogBoardVm vm = await board();
          if (!c.isClosed) c.add(vm);
        } while (again);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      } finally {
        busy = false;
      }
    }

    void watchDb() {
      unawaited(dbSub?.cancel());
      final OperatorView? v = _rt.view.value;
      dbSub = v == null
          ? null
          : watchLedgerQuery<String>(
              v.db,
              const <String>{'job_run'},
              // 바뀐 값만 내보내는 감시라 «job_run 지문»(행 수 · 마지막 끝 시각)을 읽는다.
              () {
                final r = v.db
                    .select(
                      'SELECT COUNT(*) AS n, MAX(finished_at) AS f FROM job_run',
                    )
                    .first;
                return '${r['n']}|${r['f']}';
              },
            ).skip(1).listen((_) => unawaited(emit()));
    }

    void onView() {
      watchDb();
      unawaited(emit());
    }

    c = StreamController<WatchdogBoardVm>(
      onListen: () {
        watchDb();
        _rt.view.addListener(onView);
        timer = Timer.periodic(tick, (_) => unawaited(emit()));
        unawaited(emit());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
        timer?.cancel();
        await dbSub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<DiagnosticsVm> watchDiagnostics() {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      return Stream<DiagnosticsVm>.error(StateError('진단: 화면 상태 없음(온보딩 전)'));
    }
    return LedgerDiagnosticsSource(
      v.db,
      clock: _rt.clock,
      operatingMode: () => (_rt.view.value ?? v).flags.operatingMode,
    ).watchDiagnostics();
  }

  static Stream<T> _none<T>(String what) =>
      Stream<T>.error(UnsupportedError('$what: 원천 없음(R109)'));

  /// 🆕 R140 — S07 연결.
  @override
  Stream<ConnectionsVm> watchConnections() {
    late final StreamController<ConnectionsVm> c;
    StreamSubscription<Object>? progress;
    Timer? timer;
    ConnectionsVm? last;

    Future<void> refresh() async {
      try {
        final ConnectionsVm v = await connections();
        if (c.isClosed || v == last) return;
        last = v;
        c.add(v);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    void onView() => unawaited(refresh());

    c = StreamController<ConnectionsVm>(
      onListen: () {
        // 키 검증 = sim 진척 표 기록 — 표가 바뀔 때마다(값 = 매번 새 표지).
        progress = watchLedgerQuery<Object>(_rt.files.sim, const <String>{
          'onboarding_progress',
        }, Object.new).skip(1).listen((_) => unawaited(refresh()));
        _rt.view.addListener(onView);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
        timer?.cancel();
        await progress?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  /// 🆕 R146 — 지금 기기 화면(화면 상태 없음 · 기기 id 없음 = 오류).
  Future<DeviceAccessVm> deviceAccess() async {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      throw StateError('기기: 화면 상태 없음(온보딩 전)');
    }
    final String? id = _rt.deviceId;
    if (id == null) {
      throw StateError('기기: 기기 id 없음');
    }
    final LeaseVerdict lease = await SqliteLeaseGate(
      v.db,
      mode: v.flags.runMode,
      clock: _rt.clock,
    ).check();
    return deviceAccessVmOf(
      DeviceAccessFacts(
        deviceId: id,
        runMode: v.flags.runMode,
        lease: lease,
        hasBody: hasBody,
      ),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  /// 🆕 R146 — S06 기기 · 접근.
  @override
  Stream<DeviceAccessVm> watchDeviceAccess() =>
      _followView(deviceAccess, const <String>{'sync_state'});

  /// 읽기 하나를 따라간다 — 들을 때 · [tick] · 화면 상태 원장의 [tables](화면 상태가 바뀌면 새 원장으로 옮긴다) ·
  /// 화면 상태 변경 · 바뀐 값만 · 읽기 실패 = 오류 한 번(다음 계기에 다시 읽는다).
  Stream<T> _followView<T>(Future<T> Function() read, Set<String> tables) {
    late final StreamController<T> c;
    StreamSubscription<Object>? ledger;
    Timer? timer;
    T? last;
    bool has = false;

    Future<void> refresh() async {
      try {
        final T v = await read();
        if (c.isClosed || (has && v == last)) return;
        has = true;
        last = v;
        c.add(v);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    void followLedger() {
      unawaited(ledger?.cancel());
      ledger = null;
      final OperatorView? v = _rt.view.value;
      if (v == null) return;
      // 값 = 매번 새 표지 — 표가 바뀔 때마다 한 번(«바뀐 값만» 감시라 같은 값을 내지 않게).
      ledger = watchLedgerQuery<Object>(
        v.db,
        tables,
        Object.new,
      ).skip(1).listen((_) => unawaited(refresh()));
    }

    void onView() {
      followLedger();
      unawaited(refresh());
    }

    c = StreamController<T>(
      onListen: () {
        followLedger();
        _rt.view.addListener(onView);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
        timer?.cancel();
        await ledger?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<BackupVm> watchBackup() => _none('watchBackup');

  @override
  Stream<AnnualReviewVm> watchAnnualReview() => _none('watchAnnualReview');

  /// 🆕 R136 — H-03 기기 리스크(화면 상태와 무관 — 온보딩 전에도 잰다).
  @override
  Stream<DeviceRiskVm> watchDeviceRisk() {
    final Future<DeviceRiskFacts> Function()? probe = _rt.deviceProbe;
    if (probe == null) return _none('watchDeviceRisk');
    late final StreamController<DeviceRiskVm> c;
    Timer? timer;
    DeviceRiskVm? last;

    Future<void> measure() async {
      try {
        final DeviceRiskVm v = deviceRiskVmOf(
          await probe(),
          nowUtc: _rt.clock.nowUtc(),
        );
        if (c.isClosed || v == last) return;
        last = v;
        c.add(v);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    c = StreamController<DeviceRiskVm>(
      onListen: () {
        timer = Timer.periodic(riskTick, (_) => unawaited(measure()));
        unawaited(measure());
      },
      onCancel: () async {
        timer?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }
}
