// E11p3a 조립 실기 시험(에뮬레이터 · 폰 — 로컬만) — 원장 폴더 · SQLite(Android 빌드 훅) · 기동 판정 · 깨어남 배선.
//
// 실행: flutter test integration_test/engine_test.dart -d <기기>

import 'dart:io';

import 'package:app_operator_android/engine/engine.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart' show LedgerFile;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final JobCalendars cals = JobCalendars(
    kr: frozenExchangeCalendar(Market.kr),
    us: frozenExchangeCalendar(Market.us),
  );

  test('paths = 앱 전용 폴더 · 엔진 원장 = no_backup/engine', () async {
    final OperatorPaths p = await AndroidOps().paths();
    expect(p.files, endsWith('/files'));
    expect(p.noBackup, endsWith('/no_backup'));
    expect(p.engineDir, '${p.noBackup}/engine');
  });

  test('🔴 SQLite 원장이 기기에서 열린다 · 빈 기기 = 온보딩 미완 · live 파일을 만들지 않는다', () async {
    final String dir = '${(await AndroidOps().paths()).noBackup}/e11p3a_it';
    final LedgerFiles f = LedgerFiles.open(dir, clock: const SystemClock());
    try {
      expect(
        await bootEngine(f, clock: const SystemClock()),
        isA<EngineOnboardingIncomplete>(),
      );
      expect(File('$dir/${LedgerFile.sim.fileName}').existsSync(), true);
      expect(File('$dir/${LedgerFile.live.fileName}').existsSync(), false);
    } finally {
      f.close();
      Directory(dir).deleteSync(recursive: true);
    }
  });

  test('🔴 깨어남 배선 — 처음 깨어날 때 조립 · 원장 = no_backup/engine', () async {
    final AndroidOps ops = AndroidOps();
    final WakeHandler h = engineWakeHandler(ops: ops, calendars: cals);
    await h(
      WakeEvent.fromWire(<String, Object?>{
        'reason': 'start',
        'firedAtMs': DateTime.now().millisecondsSinceEpoch,
      })!,
    );
    final String dir = (await ops.paths()).engineDir;
    expect(File('$dir/${LedgerFile.sim.fileName}').existsSync(), true);
  });
}
