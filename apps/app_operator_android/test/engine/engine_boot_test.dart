// E11p3a 기동 판정 조립 시험(설계 e11p-map Q3 · Q4) — 실 SQLite.

import 'dart:io';

import 'package:app_operator_android/engine/engine_boot.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/platform/bootstrap.dart'
    show kOperatorBootInputs;
import 'package:core_engine/core_engine.dart'
    show kCredentialEnvMismatch, kSaf405;
import 'package:data_sync/data_sync.dart'
    show SqliteModeStore, startupConfigApprovalOf;
import 'package:domain_contracts/domain_contracts.dart'
    show
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OperatingMode,
        RunMode,
        SafetyHoldCodes;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'support.dart';

void main() {
  tearDownAll(deleteTempDirs);
  final FakeClock clock = FakeClock(kst(2026, 11, 16, 9, 30));

  test('빈 기기 = 온보딩 미완 · 🔴 live 파일을 만들지 않는다', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    final EngineBoot b = await bootEngine(f, clock: clock);
    expect(b, isA<EngineOnboardingIncomplete>());
    expect(File('${dir.path}/${LedgerFile.live.fileName}').existsSync(), false);
    expect(File('${dir.path}/${LedgerFile.sim.fileName}').existsSync(), true);
  });

  test('모드 행은 있지만 운영 방식이 커밋 전 = 온보딩 미완', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock);
    expect(
      await bootEngine(f, clock: clock),
      isA<EngineOnboardingIncomplete>(),
    );
  });

  test('sim 모드 + 커밋된 운영 방식 = 준비(sim 원장 · 해석 값 그대로)', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final EngineBoot b = await bootEngine(f, clock: clock);
    final EngineReady r = b as EngineReady;
    expect(identical(r.db, f.sim), true);
    expect(r.file, LedgerFile.sim);
    expect(r.runMode, RunMode.simInternal);
    expect(r.operatingMode, OperatingMode.autoTrade);
    expect(r.execPolicy, ExecPolicy.execute);
    expect(r.holds, isEmpty);
    expect(r.repaired, false);
  });

  test('🔴 자격증명 환경이 어긋나면 거부(잡 0) — 사유 = 엔진 코드', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final EngineBoot b = await bootEngine(
      f,
      clock: clock,
      inputs: BootInputs(credentialEnvironmentOk: (RunMode _) => false),
    );
    expect((b as EngineRejected).triggered, <String>[kCredentialEnvMismatch]);
    expect(b.runMode, RunMode.simInternal);
  });

  test(
    '🔴 조립 앱 입력(R95) — sim 은 모의 세트라 환경이 맞아 준비 · live 는 여전히 SAF-405',
    () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      addTearDown(f.close);
      writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
      expect(
        await bootEngine(f, clock: clock, inputs: kOperatorBootInputs),
        isA<EngineReady>(),
      );
      final Directory dir = tempLedgerDir();
      final LedgerFiles g = openFiles(dir, clock);
      addTearDown(g.close);
      writeSimMode(g.sim, clock, committed: OperatingMode.autoTrade);
      final Database live = writeLiveMode(dir, clock);
      addTearDown(live.close);
      final EngineBoot b = await bootEngine(
        g,
        clock: clock,
        inputs: kOperatorBootInputs,
      );
      expect((b as EngineRejected).triggered, <String>[kSaf405]);
    },
  );

  test('🔴 live 는 승인 판이 없으면(기본 = 실물 · 개시 판 없음) SAF-405 로 거부', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    final EngineBoot b = await bootEngine(f, clock: clock);
    expect((b as EngineRejected).triggered, <String>[kSaf405]);
    expect(b.runMode, RunMode.live);
  });

  test('🆕 R189 기본 승인 원천 = 실전 파일 config_versions(개시 판) — 1 = 준비 · 0 = SAF-405 · 조립 앱 입력도 같다', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    // simToAuto 커밋이 남기는 꼴 — 옮긴 승인 판 + 실전 개시 결정(같은 지문).
    live.execute(
      "INSERT INTO config_versions (config_hash, created_at, content, approved) VALUES ('cfg-ok', 't', '{}', 1)",
    );
    live.execute(
      'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, reason_code, '
      "config_hash) VALUES ('LIVEOPEN-1', 't', '2026-11-16', 'LIVE', 'MANUAL', 'P0S', 'x', ?, 'cfg-ok')",
      <Object?>[DecisionReasonCodes.openingBalance],
    );
    expect(startupConfigApprovalOf(live, RunMode.live), 1);
    for (final BootInputs inputs in <BootInputs>[
      const BootInputs(),
      kOperatorBootInputs,
    ]) {
      final EngineReady r =
          await bootEngine(f, clock: clock, inputs: inputs) as EngineReady;
      expect(r.runMode, RunMode.live);
      expect(r.holds, <String>{SafetyHoldCodes.liveAwaitingKeys});
    }
    live.execute('UPDATE config_versions SET approved = 0');
    final EngineBoot b = await bootEngine(f, clock: clock);
    expect((b as EngineRejected).triggered, <String>[kSaf405]);
  });

  test('live 승인이 있으면 준비 — 실키 미검증 = LIVE_AWAITING_KEYS hold', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    final EngineBoot b = await bootEngine(
      f,
      clock: clock,
      inputs: BootInputs(approvedOf: (Database _, RunMode m) => 1),
    );
    final EngineReady r = b as EngineReady;
    expect(r.file, LedgerFile.live);
    expect(identical(r.db, f.liveIfExists()), true);
    expect(r.runMode, RunMode.live);
    expect(r.execPolicy, ExecPolicy.dryRun);
    expect(r.holds, <String>{SafetyHoldCodes.liveAwaitingKeys});
  });

  test('🔴 반쯤 끝난 2단 커밋(live 행 · sim 안 닫힘)을 고친다 — sim CLOSE 1행', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    final SqliteModeStore sim = SqliteModeStore(
      f.sim,
      LedgerFile.sim,
      clock: clock,
    );
    expect(sim.closed(), false);
    final EngineBoot b = await bootEngine(f, clock: clock);
    expect((b as EngineRejected).repaired, true);
    expect(sim.closed(), true);
    final EngineBoot again = await bootEngine(f, clock: clock);
    expect((again as EngineRejected).repaired, false);
  });

  test('🔴 깨어날 때마다 다시 판정 — 그사이 생긴 live 파일을 본다(Q4)', () async {
    final Directory dir = tempLedgerDir();
    final LedgerFiles f = openFiles(dir, clock);
    addTearDown(f.close);
    writeSimMode(f.sim, clock, committed: OperatingMode.autoTrade);
    expect(await bootEngine(f, clock: clock), isA<EngineReady>());
    final Database live = writeLiveMode(dir, clock);
    addTearDown(live.close);
    expect(
      ((await bootEngine(f, clock: clock)) as EngineRejected).runMode,
      RunMode.live,
    );
  });
}
