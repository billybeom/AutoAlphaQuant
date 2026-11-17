// E16t3b — 감시 유지보수 창 깨어남 배선(설계 13 §8 R149 AA1~AA7).
//
// 🔵 잡는 것: ① 부팅 깨어남 = 멈춘 체크 재개 → 창 닫음 · 부팅 아님 = 재개 0 ② 건너뜀 = 감시 없음 · 넘김 시간 없음 · 모의 파일
//    ③ 부팅인데 bootId 없음 = ArgumentError ④ 창 깨어남 실패 = 보고에 싣고 회차는 막지 않는다 ⑤ wakeBootOf.
import 'dart:io';

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/operator_engine.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart' show FakeWatchdogRemote;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'support.dart';

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late _Trusted trusted;
  late FakeWatchdogRemote remote;
  late LedgerFiles f;
  late Database live;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 16, 3, 0));
    trusted = _Trusted(clock.now);
    remote = FakeWatchdogRemote(
      initial: <RemoteCheck>[
        for (final String s in <String>['live-auto-kr_order', 'engine_alive'])
          RemoteCheck(slug: s, status: RemoteCheckStatus.up),
      ],
    );
    final Directory dir = tempLedgerDir();
    f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    live = writeLiveMode(dir, clock);
    addTearDown(live.close);
  });

  SqliteMaintenanceWindowStore store() => SqliteMaintenanceWindowStore(
    live,
    trusted: trusted,
    alerts: SqliteAlertSink(live, clock: clock),
  );

  Future<String> openWindow() async {
    final WindowOpenReport r = await MaintenanceWindowRunner(
      store(),
      remote: remote,
    ).open(runMode: RunMode.live, operatingMode: OperatingMode.autoTrade);
    return r.windowId!;
  }

  OperatorEngine engine({
    bool withWatchdog = true,
    Object? operations = const <String, Object?>{
      'migration': <String, Object?>{'maintenance_overdue_hours': 72},
    },
    LedgerFiles? files,
  }) => OperatorEngine(
    openFiles: () => files ?? f,
    calendars: calendars(),
    heartbeat: RecordingHeartbeat(),
    clock: clock,
    bootInputs: BootInputs(
      approvedOf: (Database _, RunMode m) => 1,
      trusted: trusted,
    ),
    runners: (JobContext c) => <String, JobRunner>{},
    watchdog: withWatchdog ? remote : null,
    operations: operations == null
        ? null
        : OperationsConfig.fromJson(operations),
  );

  test('🔴 부팅 깨어남 = 멈춘 체크 재개 → 창 닫음(engine_alive 는 멈춘 적 없음)', () async {
    final String id = await openWindow();
    expect(
      remote.store['live-auto-kr_order']!.status,
      RemoteCheckStatus.paused,
    );
    final EngineWakeReport r = await engine().wake(booting: true, bootId: 'b1');
    expect(r.boot, isA<EngineReady>());
    expect(r.windowError, isNull);
    expect(r.window!.windowId, id);
    expect(r.window!.resumed, <String>['live-auto-kr_order']);
    expect(r.window!.closed, isTrue);
    expect(store().openWindowId(), isNull);
    expect(remote.store['live-auto-kr_order']!.status, RemoteCheckStatus.fresh);
  });

  test('부팅 아님 = 재개 0 · 창 열린 채', () async {
    final String id = await openWindow();
    final EngineWakeReport r = await engine().wake();
    expect(r.window, isNotNull);
    expect(r.window!.resumed, isEmpty);
    expect(r.window!.closed, isFalse);
    expect(store().openWindowId(), id);
    expect(remote.calls.where((String c) => c.startsWith('resume:')), isEmpty);
  });

  test('건너뜀 — 감시 없음 · 넘김 시간 없음(운영 설정 없음 · 키 없음)', () async {
    await openWindow();
    for (final OperatorEngine e in <OperatorEngine>[
      engine(withWatchdog: false),
      engine(operations: null),
      engine(operations: const <String, Object?>{}),
    ]) {
      final EngineWakeReport r = await e.wake(booting: true, bootId: 'b1');
      expect(r.boot, isA<EngineReady>());
      expect(r.window, isNull);
      expect(r.windowError, isNull);
    }
    expect(store().openWindowId(), isNotNull);
  });

  test('모의 파일 = X1 밖(창 깨어남 0)', () async {
    final Directory simDir = tempLedgerDir();
    final LedgerFiles sim = openFiles(simDir, clock);
    addTearDown(sim.close);
    writeSimMode(sim.sim, clock, committed: OperatingMode.autoTrade);
    final EngineWakeReport r = await engine(files: sim)
        .wake(booting: true, bootId: 'b1');
    expect(r.boot, isA<EngineReady>());
    expect((r.boot as EngineReady).file, LedgerFile.sim);
    expect(r.window, isNull);
    expect(r.windowError, isNull);
  });

  test('부팅인데 bootId 없음 = ArgumentError', () async {
    await expectLater(engine().wake(booting: true), throwsArgumentError);
  });

  test('🔴 창 깨어남 실패 = 보고에 싣고 회차는 막지 않는다', () async {
    for (final String w in <String>['mw-a', 'mw-b']) {
      live.execute(
        'INSERT INTO maintenance_window (event_id, window_id, run_id, event, checks_json, at) '
        "VALUES (?, ?, NULL, 'OPENED', '[]', ?)",
        <Object?>['$w:OPENED', w, clock.now.toIso8601String()],
      );
    }
    final EngineWakeReport r = await engine().wake(booting: true, bootId: 'b1');
    expect(r.boot, isA<EngineReady>());
    expect(r.window, isNull);
    expect(r.windowError, isA<StateError>());
    expect(r.plan, isNotNull);
  });

  test('wakeBootOf — 부팅만 booting · id = boot-{울린 ms}', () {
    final DateTime at = DateTime.utc(2026, 11, 16, 1);
    expect(wakeBootOf(WakeEvent(reason: WakeReason.boot, firedAtUtc: at)), (
      booting: true,
      bootId: 'boot-${at.millisecondsSinceEpoch}',
    ));
    for (final WakeReason r in WakeReason.values) {
      if (r == WakeReason.boot) continue;
      expect(wakeBootOf(WakeEvent(reason: r, firedAtUtc: at)), (
        booting: false,
        bootId: null,
      ), reason: r.name);
    }
  });
}
