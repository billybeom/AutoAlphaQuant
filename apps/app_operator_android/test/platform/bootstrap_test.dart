// E11p3a — 깨어남 → 엔진 배선(설계 e11p-map Q0 · Q1) · 채널은 흉내 · 원장은 실 SQLite(임시 폴더).

import 'dart:io';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/engine/kis_sessions.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:broker_gateway/broker_gateway.dart' show KisQuoteFeed;
import 'package:core_engine/core_engine.dart' show kSaf405, p0sRegimeConfigHash;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:domain_contracts/domain_contracts.dart'
    show LedgerFile, OperatingMode, RunMode, UiLevel;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart' show FgsStatus;

import '../engine/support.dart';

const MethodChannel _ch = MethodChannel(OperatorChannelNames.ops);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDownAll(deleteTempDirs);
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ch, null),
  );

  test(
    '🔴 처음 깨어날 때 조립 — 원장 = noBackup/engine · 폴더를 다시 묻지 않는다 · 실패하면 다음에 다시',
    () async {
      final Directory root = tempLedgerDir();
      int asked = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_ch, (MethodCall c) async {
            if (c.method != 'paths') return null;
            asked++;
            if (asked == 1) throw PlatformException(code: 'io');
            return <String, Object?>{
              'files': '${root.path}/files',
              'noBackup': '${root.path}/no_backup',
            };
          });
      final WakeHandler h = engineWakeHandler(
        ops: AndroidOps(),
        calendars: calendars(),
      );
      final WakeEvent e = WakeEvent.fromWire(<String, Object?>{
        'reason': 'start',
        'firedAtMs': 1,
      })!;
      await expectLater(h(e), throwsA(isA<PlatformException>()));
      await h(e);
      await h(e);
      expect(asked, 2);
      expect(
        File('${root.path}/no_backup/engine/${LedgerFile.sim.fileName}')
            .existsSync(),
        true,
      );
      expect(Directory('${root.path}/files').existsSync(), false);
    },
  );

  test(
    '🔴 깨어남 → FGS(R102) — 조립된 엔진이 상태를 넘긴다(기동 거부 = BLOCKED · 거부 코드)',
    () async {
      final Directory root = tempLedgerDir();
      final Directory engineDir = Directory('${root.path}/no_backup/engine')
        ..createSync(recursive: true);
      final FakeClock clock = FakeClock(DateTime.now().toUtc());
      final LedgerFiles f = openFiles(engineDir, clock);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      final Database live = writeLiveMode(engineDir, clock);
      live.close();
      f.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            _ch,
            (MethodCall c) async => c.method == 'paths'
                ? <String, Object?>{
                    'files': '${root.path}/files',
                    'noBackup': '${root.path}/no_backup',
                  }
                : null,
          );
      final List<FgsStatus> shown = <FgsStatus>[];
      final WakeHandler h = engineWakeHandler(
        ops: AndroidOps(),
        calendars: calendars(),
        fgs: (FgsStatus s) async => shown.add(s),
      );
      await h(
        WakeEvent.fromWire(<String, Object?>{
          'reason': 'start',
          'firedAtMs': 1,
        })!,
      );
      expect(shown, hasLength(1));
      expect(shown.single.level, UiLevel.blocked);
      expect(shown.single.headline, kSaf405);
    },
  );

  test('🔴 깨어남 → 화면 상태(R104) — 실행 묶음의 원장을 쓰고 보고로 화면 상태를 바꾼다', () async {
    final Directory root = tempLedgerDir();
    final FakeClock clock = FakeClock(DateTime.now().toUtc());
    final LedgerFiles f = openFiles(root, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(root, clock);
    live.close();
    final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
    final WakeHandler h = engineWakeHandler(
      ops: AndroidOps(),
      calendars: calendars(),
      runtime: rt,
    );
    expect(rt.view.value, isNull);
    await h(
      WakeEvent.fromWire(<String, Object?>{'reason': 'start', 'firedAtMs': 1})!,
    );
    expect(rt.view.value!.flags.runMode, RunMode.live);
    expect(identical(rt.view.value!.db, f.liveIfExists()), true);
  });

  test('🔴 조립 앱 부품(R97) — 일봉 원천 = 모드 세트의 KIS · 국면 지문 = 사람 값 없는 지문', () async {
    final http.Client net = MockClient(
      (http.Request r) async => http.Response('', 500),
    );
    final MemorySecretVault vault = MemorySecretVault(<String, String>{
      'kis.paper.app_key': 'fakePaperAppKey${'A' * 21}',
      'kis.paper.app_secret': 'fakePaperSecret${'Z' * 165}',
      'kis.paper.account_no': '50123456',
      'kis.paper.product_code': '01',
    });
    final p = operatorJobParts(KisSessions(vault: vault, http: net), net);
    expect(p.regimeConfigHash, p0sRegimeConfigHash());
    expect(await p.quoteFeed(RunMode.simInternal), isA<KisQuoteFeed>());
    await expectLater(
      p.quoteFeed(RunMode.live),
      throwsA(isA<KisSessionUnavailable>()),
    );
  });

  group('E16t2b — 이 기기 id → 엔진 기동 입력(R144)', () {
    const String uuid = '0f8fad5b-d9cb-469f-a165-70867728950e';

    /// live 원장에 옛 폰 이전(DEMOTED 들어감)을 적는다.
    void demoted(Database db, String device) {
      db.execute(
        'INSERT INTO migration_run (run_id, kind, role, device_id, operator_epoch, decision_id, started_at) '
        "VALUES ('mig-1', 'PLAN', 'OLD_DEVICE', ?, 1, 'd', '2026-11-15T01:00:00.000Z')",
        <Object?>[device],
      );
      int m = 0;
      void step(String s, String state) => db.execute(
        "INSERT INTO migration_step (run_id, step, state, detail_json, at) VALUES ('mig-1', ?, ?, NULL, ?)",
        <Object?>[
          s,
          state,
          '2026-11-15T01:${(m++).toString().padLeft(2, '0')}:00.000Z',
        ],
      );
      for (final String s in <String>[
        'FREEZE',
        'ORDERS_CLEARED',
        'RECON_ZERO',
        'BACKUP_CHECKSUM',
      ]) {
        step(s, 'ENTERED');
        step(s, 'DONE');
      }
      step('DEMOTED', 'ENTERED');
    }

    void channel(Directory root, {Object? deviceId}) =>
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_ch, (MethodCall c) async {
              switch (c.method) {
                case 'paths':
                  return <String, Object?>{
                    'files': '${root.path}/files',
                    'noBackup': '${root.path}/no_backup',
                  };
                case 'deviceId':
                  if (deviceId is Exception) throw deviceId;
                  return deviceId;
              }
              return null;
            });

    WakeEvent start() => WakeEvent.fromWire(<String, Object?>{
      'reason': 'start',
      'firedAtMs': 1,
    })!;

    test('operatorBootInputs — 기기 id 만 더한다(자격증명 환경 = 그대로)', () {
      expect(operatorBootInputs().deviceId, isNull);
      expect(operatorBootInputs(deviceId: uuid).deviceId, uuid);
      expect(kOperatorBootInputs.deviceId, isNull);
      for (final RunMode m in RunMode.values) {
        expect(
          operatorBootInputs(deviceId: uuid).credentialEnvironmentOk(m),
          kOperatorBootInputs.credentialEnvironmentOk(m),
          reason: m.wire,
        );
      }
    });

    test('deviceIdOrNull — 꼴이 맞으면 그 값 · 틀림 · 던짐 = null', () async {
      final Directory root = tempLedgerDir();
      channel(root, deviceId: uuid);
      expect(await deviceIdOrNull(AndroidOps()), uuid);
      channel(root, deviceId: 'not-a-uuid');
      expect(await deviceIdOrNull(AndroidOps()), isNull);
      channel(root, deviceId: PlatformException(code: 'X'));
      expect(await deviceIdOrNull(AndroidOps()), isNull);
    });

    test(
      '🔴 실행 묶음의 기기 id → 기동 입력 — 옛 폰 DEMOTED = 기동 거부(SAF-405 · X1_DEMOTED)',
      () async {
        final Directory root = tempLedgerDir();
        final FakeClock clock = FakeClock(DateTime.now().toUtc());
        final LedgerFiles f = openFiles(root, clock);
        addTearDown(f.close);
        writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
        final Database live = writeLiveMode(root, clock);
        demoted(live, uuid);
        live.close();
        final List<FgsStatus> shown = <FgsStatus>[];
        final WakeHandler h = engineWakeHandler(
          ops: AndroidOps(),
          calendars: calendars(),
          fgs: (FgsStatus s) async => shown.add(s),
          runtime: OperatorRuntime(files: f, clock: clock, deviceId: uuid),
        );
        await h(start());
        expect(shown.last.level, UiLevel.blocked);
        expect(shown.last.headline, '$kSaf405 · X1_DEMOTED');
      },
    );

    test('🔴 실행 묶음 없음 = 플랫폼 기기 id · 못 얻으면 X1 꺼짐(SAF-405 만)', () async {
      Future<String?> headline({Object? deviceId}) async {
        final Directory root = tempLedgerDir();
        final Directory engineDir = Directory('${root.path}/no_backup/engine')
          ..createSync(recursive: true);
        final FakeClock clock = FakeClock(DateTime.now().toUtc());
        final LedgerFiles f = openFiles(engineDir, clock);
        writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
        final Database live = writeLiveMode(engineDir, clock);
        demoted(live, uuid);
        live.close();
        f.close();
        channel(root, deviceId: deviceId);
        final List<FgsStatus> shown = <FgsStatus>[];
        final WakeHandler h = engineWakeHandler(
          ops: AndroidOps(),
          calendars: calendars(),
          fgs: (FgsStatus s) async => shown.add(s),
        );
        await h(start());
        return shown.last.headline;
      }

      expect(await headline(deviceId: uuid), '$kSaf405 · X1_DEMOTED');
      expect(await headline(), kSaf405);
      // 다른 기기의 옛 폰 행 = 이 기기 이전이 아니다.
      expect(
        await headline(deviceId: '1f8fad5b-d9cb-469f-a165-70867728950e'),
        kSaf405,
      );
    });
  });
}
