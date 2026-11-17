// E11p3d-2 운영 상태 원천 operator 판(설계 13 §8 R109) — 실 SQLite(job_run) · 바깥 = 가짜.

import 'dart:async';

import 'package:app_operator_android/app/operator_ops_status.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        DeviceRiskFacts,
        JobRunEntry,
        JobRunStatus,
        RemoteCheck,
        RemoteCheckStatus,
        watchdogCheckName;
import 'package:core_engine/testing.dart' show FakeWatchdogRemote;
import 'package:data_sync/data_sync.dart'
    show
        HealthchecksError,
        HealthchecksErrorKind,
        SqliteJobRunLog,
        SqliteOnboardingProgressStore;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        ConnectionRow,
        ConnectionTargetCodes,
        ConnectionsVm,
        DeviceRiskItem,
        DeviceRiskVm,
        StepState,
        OperatingMode,
        RunMode,
        TradeDate,
        UiLevel,
        WatchdogBoardVm,
        WatchdogCheck;
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart'
    show kJobWatchdogLabels, watchdogCheckSpecsFor;

import '../engine/support.dart';

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;
  late FakeWatchdogRemote remote;
  late OperatorRuntime rt;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 22, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
    remote = FakeWatchdogRemote();
    rt = OperatorRuntime(files: files, clock: clock, watchdogRemote: remote);
  });
  tearDown(() => files.close());

  /// 모드를 열흘 앞서 커밋하고 화면 상태를 세운다.
  Future<void> ready() async {
    final DateTime now = clock.now;
    clock.now = now.subtract(const Duration(days: 10));
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    clock.now = now;
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
  }

  Future<void> record(String job, String day, JobRunStatus st, DateTime at) =>
      SqliteJobRunLog(files.sim).record(
        JobRunEntry(
          rid: '$job-$day-${st.name}',
          checkName: watchdogCheckName(
            RunMode.simInternal,
            OperatingMode.autoTrade,
            job,
          ),
          sessionDay: TradeDate(day),
          startedAtUtc: at.subtract(const Duration(minutes: 1)),
          finishedAtUtc: at,
          status: st,
        ),
      );

  void seedRemote() {
    for (final s in watchdogCheckSpecsFor(
      RunMode.simInternal,
      OperatingMode.autoTrade,
    )) {
      remote.store[s.slug] = RemoteCheck(
        slug: s.slug,
        status: RemoteCheckStatus.up,
        lastPingUtc: kst(2026, 12, 22, 7, 6),
      );
    }
  }

  WatchdogCheck rowOf(WatchdogBoardVm vm, String job) => vm.rows.singleWhere(
    (WatchdogCheck r) => r.label == kJobWatchdogLabels[job],
  );

  test('🔴 화면 상태 없음(온보딩 전) = 빈 보드 · 체크를 지어내지 않는다', () async {
    final WatchdogBoardVm vm = await OperatorOpsStatusRepository(rt).board();
    expect(vm.rows, isEmpty);
    expect(vm.emptyLabel, isNotNull);
  });

  test('🔴 준비 = 로컬 판정 행(잡 표 순) · 바깥 대조 · 성공 = OK', () async {
    await ready();
    await record(
      'daily_reconcile',
      '2026-12-22',
      JobRunStatus.success,
      kst(2026, 12, 22, 7, 6),
    );
    for (final s in watchdogCheckSpecsFor(
      RunMode.simInternal,
      OperatingMode.autoTrade,
    )) {
      remote.store[s.slug] = RemoteCheck(
        slug: s.slug,
        status: RemoteCheckStatus.up,
        lastPingUtc: kst(2026, 12, 22, 7, 6),
      );
    }
    final WatchdogBoardVm vm = await OperatorOpsStatusRepository(rt).board();
    expect(vm.rows, isNotEmpty);
    expect(rowOf(vm, 'daily_reconcile').level, UiLevel.ok);
    expect(vm.lastReceivedText, isNot(contains('읽지 못했습니다')));
  });

  test('🔴 바깥을 못 읽으면 행은 로컬 그대로 · 머리 문구만', () async {
    await ready();
    remote.failOn[('checks', '*')] = Exception('키 없음');
    final WatchdogBoardVm vm = await OperatorOpsStatusRepository(rt).board();
    expect(vm.rows, isNotEmpty);
    expect(vm.lastReceivedText, contains('읽지 못했습니다'));
  });

  test('바깥 목록은 정해진 시간 안에 다시 묻지 않는다', () async {
    await ready();
    final OperatorOpsStatusRepository r = OperatorOpsStatusRepository(rt);
    await r.board();
    await r.board();
    expect(remote.calls.where((String c) => c == 'checks'), hasLength(1));
    clock.now = clock.now.add(const Duration(minutes: 6));
    await r.board();
    expect(remote.calls.where((String c) => c == 'checks'), hasLength(2));
  });

  test('🔴 듣자마자 · job_run 이 바뀌면 다시 낸다', () async {
    await ready();
    seedRemote();
    final List<WatchdogBoardVm> got = <WatchdogBoardVm>[];
    final StreamSubscription<WatchdogBoardVm> sub = OperatorOpsStatusRepository(
      rt,
    ).watchWatchdog().listen(got.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(got, hasLength(1));
    await record(
      'daily_reconcile',
      '2026-12-22',
      JobRunStatus.success,
      kst(2026, 12, 22, 7, 6),
    );
    await pumpEventQueue();
    expect(got.length, greaterThanOrEqualTo(2));
    expect(rowOf(got.last, 'daily_reconcile').level, UiLevel.ok);
  });

  test('🔴 모드 시작 앞 회차는 보드에 없다(방금 온보딩 = 실패로 그리지 않는다)', () async {
    clock.now = kst(2026, 12, 22, 8, 25);
    writeSimMode(files.sim, clock, committed: OperatingMode.autoTrade);
    clock.now = kst(2026, 12, 22, 8, 30);
    rt.view.value = operatorViewOf(
      await bootEngine(files, clock: clock),
      files,
    );
    final WatchdogBoardVm vm = await OperatorOpsStatusRepository(rt).board();
    expect(vm.rows, isEmpty);
  });

  test('휴장일 = 휴장 고지 · 거래일 = 없음', () async {
    await ready();
    expect(
      (await OperatorOpsStatusRepository(rt).board()).holidayNotice,
      isNull,
    );
    clock.now = kst(2026, 12, 25, 12, 0);
    expect(
      (await OperatorOpsStatusRepository(rt).board()).holidayNotice,
      isNotNull,
    );
  });

  test('진단 = 화면 상태가 있을 때 원장 진단 · 없으면 오류', () async {
    await expectLater(
      OperatorOpsStatusRepository(rt).watchDiagnostics(),
      emitsError(isA<StateError>()),
    );
    await ready();
    await expectLater(
      OperatorOpsStatusRepository(rt).watchDiagnostics(),
      emits(anything),
    );
  });

  // ── 🆕 R136 — H-03 기기 리스크 ─────────────────────────────────────────

  Future<void> until(bool Function() ok) async {
    final Stopwatch w = Stopwatch()..start();
    while (!ok() && w.elapsed < const Duration(seconds: 5)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('🔴 기기 리스크 = 측정 → 엔진 VM · 화면 상태 없어도(온보딩 전) 잰다 · 잰 것만 행', () async {
    int n = 0;
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceProbe: () async {
        n++;
        return DeviceRiskFacts(
          measuredAtUtc: clock.nowUtc(),
          storageFreeBytes: 1500000000,
          securityPatch: '2026-10-05',
        );
      },
    );
    expect(r.view.value, isNull);
    final DeviceRiskVm vm = await OperatorOpsStatusRepository(r)
        .watchDeviceRisk()
        .first;
    expect(n, 1);
    expect(
      vm.rows.map((DeviceRiskItem x) => (x.label, x.level)).toList(),
      <(String, UiLevel)>[('저장공간', UiLevel.act), ('OS 보안 패치', UiLevel.ok)],
    );
    expect(vm.rows.first.currentText, '남은 공간 1.5GB');
    expect(vm.emptyLabel, isNull);
  });

  test(
    '🔴 기기 리스크 — 주기마다 다시 잰다 · 바뀐 값만 낸다 · 측정 실패 = 오류 한 번 뒤 다음 주기에 복구',
    () async {
      int calls = 0;
      int free = 5000000000;
      bool fail = false;
      final OperatorRuntime r = OperatorRuntime(
        files: files,
        clock: clock,
        deviceProbe: () async {
          calls++;
          if (fail) throw StateError('채널 끊김');
          return DeviceRiskFacts(
            measuredAtUtc: clock.nowUtc(),
            storageFreeBytes: free,
          );
        },
      );
      final List<DeviceRiskVm> got = <DeviceRiskVm>[];
      final List<Object> errors = <Object>[];
      final StreamSubscription<DeviceRiskVm> sub = OperatorOpsStatusRepository(
        r,
        riskTick: const Duration(milliseconds: 20),
      ).watchDeviceRisk().listen(got.add, onError: errors.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(got.single.rows.single.level, UiLevel.ok);
      // 같은 값(같은 시각 · 같은 측정) = 다시 내지 않는다.
      await until(() => calls >= 4);
      expect(got, hasLength(1));
      free = 3000000000;
      await until(() => got.length == 2);
      expect(got.last.rows.single.level, UiLevel.watch);
      fail = true;
      await until(() => errors.isNotEmpty);
      expect(errors.first, isA<StateError>());
      fail = false;
      free = 400000000;
      await until(() => got.length == 3);
      expect(got.last.rows.single.level, UiLevel.blocked);
    },
  );

  test('🔴 기기 리스크 — 0행(아무것도 못 잼) = 빈 줄(엔진 문장)', () async {
    final OperatorRuntime r = OperatorRuntime(
      files: files,
      clock: clock,
      deviceProbe: () async => DeviceRiskFacts(measuredAtUtc: clock.nowUtc()),
    );
    final DeviceRiskVm vm = await OperatorOpsStatusRepository(r)
        .watchDeviceRisk()
        .first;
    expect(vm.rows, isEmpty);
    expect(vm.emptyLabel, '점검할 기기 항목을 아직 받지 못했습니다. 폰에서 앱을 열면 다시 잽니다.');
  });

  // ── 🆕 R140 — S07 연결 ─────────────────────────────────────────────

  ConnectionRow conn(ConnectionsVm vm, String target) =>
      vm.rows.singleWhere((ConnectionRow r) => r.target == target);

  test('🔴 연결 = 증권사 · Supabase · GitHub · 생존 신호 · 금고 없음 = 증권사 연결 안 됨(모의 = 할 일) · 링크 = 본문 있을 때만', () async {
    remote.store['kr_order'] = RemoteCheck(
      slug: 'kr_order',
      status: RemoteCheckStatus.up,
      lastPingUtc: clock.nowUtc().subtract(const Duration(minutes: 2)),
    );
    final ConnectionsVm vm = await OperatorOpsStatusRepository(
      rt,
      hasBody: (String r) =>
          r == AppRoutes.settingsCredentials || r == AppRoutes.opsWatchdog,
    ).connections();
    expect(vm.rows.map((ConnectionRow r) => r.target).toList(), <String>[
      ConnectionTargetCodes.brokerKis,
      ConnectionTargetCodes.supabase,
      ConnectionTargetCodes.githubArchive,
      ConnectionTargetCodes.healthchecks,
    ]);
    final ConnectionRow kis = conn(vm, ConnectionTargetCodes.brokerKis);
    expect(
      (kis.statusLabel, kis.level, kis.route),
      ('연결 안 됨', UiLevel.act, AppRoutes.settingsCredentials),
    );
    final ConnectionRow hc = conn(vm, ConnectionTargetCodes.healthchecks);
    expect(
      (hc.statusLabel, hc.level, hc.lastOkText, hc.detailLine, hc.route),
      ('정상', UiLevel.ok, '2분 전에 수신', '체크 1개 모두 정상', AppRoutes.opsWatchdog),
    );
    expect(vm.asOf.label, '연결 기준 2026-12-22 09:30');
    // 기본 조립 = 링크 0.
    final ConnectionsVm bare = await OperatorOpsStatusRepository(rt)
        .connections();
    expect(bare.rows.map((ConnectionRow r) => r.route), everyElement(isNull));
  });

  test(
    '🔴 생존 신호 — 클라이언트 없음 · 읽기 키 없음 = 연결 안 됨(INFO) · 그 밖 실패 = 읽지 못했습니다(WATCH)',
    () async {
      final ConnectionsVm none = await OperatorOpsStatusRepository(
        OperatorRuntime(files: files, clock: clock),
      ).connections();
      expect(
        conn(none, ConnectionTargetCodes.healthchecks).statusCode,
        'NOT_SET',
      );
      remote.failOn[('checks', '*')] = const HealthchecksError(
        HealthchecksErrorKind.missingKey,
      );
      final ConnectionsVm noKey = await OperatorOpsStatusRepository(rt)
          .connections();
      expect(
        (
          conn(noKey, ConnectionTargetCodes.healthchecks).statusCode,
          conn(noKey, ConnectionTargetCodes.healthchecks).level,
        ),
        ('NOT_SET', UiLevel.info),
      );
      remote.failOn[('checks', '*')] = const HealthchecksError(
        HealthchecksErrorKind.network,
      );
      final ConnectionsVm net = await OperatorOpsStatusRepository(rt)
          .connections();
      expect(
        (
          conn(net, ConnectionTargetCodes.healthchecks).statusCode,
          conn(net, ConnectionTargetCodes.healthchecks).level,
        ),
        ('UNREADABLE', UiLevel.watch),
      );
    },
  );

  test('🔴 생존 신호 — 바깥 목록 5분 재사용(감시 보드와 같은 캐시 · 호출 아끼기)', () async {
    final OperatorOpsStatusRepository r = OperatorOpsStatusRepository(rt);
    await r.connections();
    await r.connections();
    expect(remote.calls.where((String c) => c == 'checks'), hasLength(1));
    clock.now = clock.now.add(const Duration(minutes: 5));
    await r.connections();
    expect(remote.calls.where((String c) => c == 'checks'), hasLength(2));
  });

  test(
    '🔴 연결 — 키 검증 기록이 바뀌면 다시 낸다(sim 진척 표 · 실제 갱신 훅) · 같은 값은 다시 내지 않는다',
    () async {
      final List<ConnectionsVm> got = <ConnectionsVm>[];
      final StreamSubscription<ConnectionsVm> sub = OperatorOpsStatusRepository(
        rt,
      ).watchConnections().listen(got.add);
      addTearDown(sub.cancel);
      await until(() => got.isNotEmpty);
      expect(
        conn(got.last, ConnectionTargetCodes.brokerKis).statusCode,
        'NOT_SET',
      );
      SqliteOnboardingProgressStore(files.sim, clock: clock).record(
        'o_02',
        StepState.failed,
        failureReasonCode: 'CREDENTIAL_REJECTED',
      );
      await until(
        () =>
            conn(got.last, ConnectionTargetCodes.brokerKis).statusCode ==
            'FAILED',
      );
      expect(
        conn(got.last, ConnectionTargetCodes.brokerKis).detailLine,
        '12-22 09:30 검증 거절(CREDENTIAL_REJECTED)',
      );
      final int n = got.length;
      SqliteOnboardingProgressStore(files.sim, clock: clock).record(
        'o_02',
        StepState.failed,
        failureReasonCode: 'CREDENTIAL_REJECTED',
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(got.length, n);
    },
  );

  test(
    '🔴 원천 없는 흐름 = 오류(지어내지 않는다) · 기기 측정기 없음(플랫폼 밖) = 기기 리스크도 원천 없음',
    () async {
      final OperatorOpsStatusRepository r = OperatorOpsStatusRepository(rt);
      for (final Stream<Object?> s in <Stream<Object?>>[
        r.watchDeviceAccess(),
        r.watchBackup(),
        r.watchAnnualReview(),
        r.watchDeviceRisk(),
      ]) {
        await expectLater(s, emitsError(isA<UnsupportedError>()));
      }
    },
  );
}
