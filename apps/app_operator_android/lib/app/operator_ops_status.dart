// 운영 상태 원천 operator 판(E11p3d-2 · 설계 13 §8 R109 · 06 M1-12 · 앱 04 §7 `W-01`).
//
// 🔴 감시 보드 = 엔진 로컬 판정(잡 표 × `job_run` · 마지막 회차) + 바깥 대조(healthchecks 체크 목록) → `buildWatchdogBoard`.
//    바깥을 못 읽으면(키 없음 · 네트워크) 행은 로컬 그대로 · 머리 문구만 «바깥을 읽지 못했습니다»(R45).
// 🔴 다시 낸다 = 들을 때 · `job_run` 이 바뀔 때(같은 연결) · 1분마다(유예가 지나 «대기 → 실패»로 넘어가는 것) · 화면 상태가 바뀔 때.
//    바깥 목록은 5분 동안 다시 묻지 않는다(호출 아끼기).
// 🔴 화면 상태가 없으면(온보딩 전) 체크도 없다 — 빈 보드(«등록된 워치독 체크가 아직 없습니다»).
// 🔵 진단 = 원장 진단 원천(E13c2) · 연결 · 기기 접근 · 백업 · 연간 = 원천 없음(R109 — 지어내지 않는다).
// 🆕 E11p3d-2c(R136) — 기기 리스크(H-03) = 플랫폼 측정(`OperatorRuntime.deviceProbe`) → 엔진 `deviceRiskVmOf` ·
//    들을 때 · [riskTick] 마다 다시 잰다 · 바뀐 값만 · 측정 실패 = 오류 한 번(다음 주기에 다시 잰다) · 측정기 없음(플랫폼 밖) = 원천 없음.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show DeviceRiskFacts, RemoteCheck, WatchdogRemote, deviceRiskVmOf;
import 'package:data_sync/data_sync.dart'
    show
        LedgerDiagnosticsSource,
        SqliteJobRunLog,
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
        TradeDate,
        WatchdogBoardVm;
import 'package:trading_runtime/trading_runtime.dart'
    show buildWatchdogBoard, kstDateOf, watchdogBoardInputsFor;

import 'operator_runtime.dart';
import 'operator_view.dart';

/// 운영 상태 원천(operator).
class OperatorOpsStatusRepository implements OpsStatusRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 내는 주기 · [remoteTtl] = 바깥 목록 재사용 시간 · [riskTick] = 기기 다시 재는 주기.
  OperatorOpsStatusRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
    this.remoteTtl = const Duration(minutes: 5),
    this.riskTick = const Duration(minutes: 5),
  });

  final OperatorRuntime _rt;

  /// 다시 내는 주기.
  final Duration tick;

  /// 바깥 목록 재사용 시간.
  final Duration remoteTtl;

  /// 🆕 R136 — 기기 다시 재는 주기(측정 = 채널 한 번 · 가볍다).
  final Duration riskTick;

  List<RemoteCheck>? _remote;
  DateTime? _remoteAt;

  /// 🔴 바깥 체크 목록(없음 · 실패 = null — 보드가 «읽지 못했습니다»).
  Future<List<RemoteCheck>?> _remoteChecks(DateTime now) async {
    final WatchdogRemote? r = _rt.watchdogRemote;
    if (r == null) return null;
    final DateTime? at = _remoteAt;
    if (at != null && now.difference(at) < remoteTtl) return _remote;
    List<RemoteCheck>? got;
    try {
      got = await r.checks();
    } on Object {
      got = null;
    }
    _remote = got;
    _remoteAt = now;
    return got;
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

  @override
  Stream<ConnectionsVm> watchConnections() => _none('watchConnections');

  @override
  Stream<DeviceAccessVm> watchDeviceAccess() => _none('watchDeviceAccess');

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
