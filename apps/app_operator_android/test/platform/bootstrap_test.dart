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
}
