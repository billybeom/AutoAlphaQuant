// 🆕 E15f3b — simToAuto 2단계 · 기동 복구(모의 CLOSE · 고름대로 · 닫힌 모의 파일 지우기 · 설계 13 §8 R100).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeOnboardingIncomplete,
        BootModeResolved,
        SimLedgerDeleteResult,
        SimLedgerFate,
        SimLedgerFinish;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ops_config_seed.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2027, 1, 13, 2);

void main() {
  late Directory dir;
  late Database live;
  late Database? sim;
  late _Clock clock;

  SqliteModeStore liveModes() =>
      SqliteModeStore(live, LedgerFile.live, clock: clock);
  SqliteModeStore simModes() =>
      SqliteModeStore(sim!, LedgerFile.sim, clock: clock);

  void simStarted() => simModes().record(
    axis: ModeAxis.runMode,
    runMode: RunMode.simInternal,
    execPolicy: ExecPolicy.execute,
    operatingMode: OperatingMode.autoTrade,
    handoverSessionValid: false,
    decisionId: 'D-SIM',
  );

  void liveCommitted() => liveModes().record(
    axis: ModeAxis.runMode,
    runMode: RunMode.live,
    execPolicy: ExecPolicy.dryRun,
    operatingMode: OperatingMode.autoTrade,
    handoverSessionValid: false,
    decisionId: 'LIVEOPEN-20270113-110000',
  );

  void choose(SimLedgerFate f) {
    // 🆕 R265 — S5 고름은 모의 파일의 지금 설정(모의 개시 판)을 읽어 붙인다(못 읽음 = 거부).
    if (openingConfigHashOf(sim!, RunMode.simInternal) == null) {
      seedOpening(sim!, RunMode.simInternal, clock: clock);
    }
    expect(SqliteSimLedgerFateStore(sim!, clock: clock).choose(f), isNull);
  }

  SimToAutoFinishResult finish() =>
      finishSimToAuto(liveDb: live, simDb: sim, clock: clock);

  String simPath() => '${dir.path}/${LedgerFile.sim.fileName}';

  void closeSim() {
    sim?.close();
    sim = null;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15f3b_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    live.close();
    sim?.close();
    dir.deleteSync(recursive: true);
  });

  test('실전 커밋 없음 = 아무것도 안 함(모의 그대로)', () {
    simStarted();
    choose(SimLedgerFate.discard);
    final SimToAutoFinishResult r = finish();
    expect(r.closeWritten, isFalse);
    expect(r.finish, SimLedgerFinish.none);
    expect(r.deleteSimFile, isFalse);
    expect(simModes().closed(), isFalse);
  });

  test('커밋 직후 — 모의 CLOSE(결정 = 실전 현재 행) · 보관 = 남김 · 다시 불러도 같은 끝(멱등)', () {
    simStarted();
    choose(SimLedgerFate.keep);
    liveCommitted();
    final SimToAutoFinishResult r = finish();
    expect(r.closeWritten, isTrue);
    expect(r.finish, SimLedgerFinish.keep);
    expect(r.deleteSimFile, isFalse);
    final Row c = sim!
        .select("SELECT * FROM mode_transition WHERE axis = 'CLOSE'")
        .single;
    expect(c['decision_id'], 'LIVEOPEN-20270113-110000');
    final SimToAutoFinishResult again = finish();
    expect(again.closeWritten, isFalse);
    expect(again.finish, SimLedgerFinish.keep);
    expect(
      sim!
          .select(
            "SELECT COUNT(*) AS n FROM mode_transition WHERE axis = 'CLOSE'",
          )
          .first['n'],
      1,
    );
    // 기동 = 실전 · 복구 할 일 없음.
    final BootMode m = bootModeOf(live: liveModes(), sim: simModes());
    expect((m as BootModeResolved).file, LedgerFile.live);
    expect(m.repairSimClose, isFalse);
  });

  test('고름 없음 = 남김(지우지 않는 쪽) · 지우기도 거부', () {
    simStarted();
    liveCommitted();
    final SimToAutoFinishResult r = finish();
    expect(r.closeWritten, isTrue);
    expect(r.finish, SimLedgerFinish.keep);
    closeSim();
    expect(
      deleteClosedSimLedger(dir.path, clock: clock),
      SimLedgerDeleteResult.notDiscard,
    );
    expect(File(simPath()).existsSync(), isTrue);
  });

  test(
    '지움 — 연결 닫고 지우기 · 본체 · -wal · -shm 사라짐 · 지운 뒤 기동 = 실전 · 복구 = 할 일 없음',
    () {
      simStarted();
      choose(SimLedgerFate.discard);
      liveCommitted();
      final SimToAutoFinishResult r = finish();
      expect(r.closeWritten, isTrue);
      expect(r.deleteSimFile, isTrue);
      closeSim();
      // 남아 있을 수 있는 짝 파일도 지운다.
      File('${simPath()}-shm').writeAsStringSync('');
      expect(
        deleteClosedSimLedger(dir.path, clock: clock),
        SimLedgerDeleteResult.deleted,
      );
      for (final String s in <String>['', '-wal', '-shm']) {
        expect(File('${simPath()}$s').existsSync(), isFalse, reason: s);
      }
      expect(
        File('${dir.path}/${LedgerFile.live.fileName}').existsSync(),
        isTrue,
      );
      expect(
        deleteClosedSimLedger(dir.path, clock: clock),
        SimLedgerDeleteResult.missing,
      );
      final BootMode m = bootModeOf(live: liveModes(), sim: null);
      expect((m as BootModeResolved).file, LedgerFile.live);
      expect(repairHalfCommit(m, null), isFalse);
      expect(finish().finish, SimLedgerFinish.none);
    },
  );

  test('지우기는 스스로 다시 확인 — 안 닫힘 · 보관 = 지우지 않음(파일 그대로)', () {
    simStarted();
    choose(SimLedgerFate.discard);
    closeSim();
    expect(
      deleteClosedSimLedger(dir.path, clock: clock),
      SimLedgerDeleteResult.notClosed,
    );
    expect(File(simPath()).existsSync(), isTrue);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    choose(SimLedgerFate.keep);
    liveCommitted();
    expect(finish().closeWritten, isTrue);
    closeSim();
    expect(
      deleteClosedSimLedger(dir.path, clock: clock),
      SimLedgerDeleteResult.notDiscard,
    );
    expect(File(simPath()).existsSync(), isTrue);
  });

  test('반쯤 끝난 커밋 복구 — 실전 커밋 뒤 모의 CLOSE 전에 끊김 → 기동이 CLOSE · 고름대로', () {
    simStarted();
    choose(SimLedgerFate.discard);
    liveCommitted();
    final BootMode m = bootModeOf(live: liveModes(), sim: simModes());
    expect((m as BootModeResolved).repairSimClose, isTrue);
    final SimToAutoFinishResult r = finish();
    expect(r.closeWritten, isTrue);
    expect(r.deleteSimFile, isTrue);
    expect(
      (bootModeOf(
        live: liveModes(),
        sim: simModes(),
      ) as BootModeResolved).repairSimClose,
      isFalse,
    );
  });

  test('모의 파일 없음 · 빈 모의 파일 = 아무것도 안 함', () {
    liveCommitted();
    expect(
      finishSimToAuto(liveDb: live, simDb: null, clock: clock).finish,
      SimLedgerFinish.none,
    );
    // 빈 파일(앱이 다시 만든 꼴) — 모드 행 없음.
    final SimToAutoFinishResult r = finish();
    expect(r.closeWritten, isFalse);
    expect(r.finish, SimLedgerFinish.none);
    expect(simModes().closed(), isFalse);
  });

  test('둘 다 없음 = 온보딩 미완(모의 없음도 받는다)', () {
    expect(
      bootModeOf(live: null, sim: null),
      isA<BootModeOnboardingIncomplete>(),
    );
  });
}
