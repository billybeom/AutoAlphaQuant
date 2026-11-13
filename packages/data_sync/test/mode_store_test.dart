// 🆕 E15b — 모드 정본 · 기동 해석 · 반쯤 끝난 커밋 복구 · 판정 입력(설계 13 §8 R82 W1~W6 · SPEC v2.44).

import 'dart:async';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeOnboardingIncomplete,
        BootModeResolved,
        ModeFacts,
        ModeRowFacts,
        kModeCombinationDenied;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 13, 1);

void main() {
  late Directory dir;
  late Database live;
  late Database sim;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e15b_');
    live = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    live.close();
    sim.close();
    dir.deleteSync(recursive: true);
  });

  SqliteModeStore liveStore() =>
      SqliteModeStore(live, LedgerFile.live, clock: clock);
  SqliteModeStore simStore() =>
      SqliteModeStore(sim, LedgerFile.sim, clock: clock);

  String? rec(
    SqliteModeStore s,
    RunMode run,
    ExecPolicy exec, {
    ModeAxis axis = ModeAxis.runMode,
    OperatingMode op = OperatingMode.autoTrade,
    bool session = false,
    String decision = 'D1',
    String? sessionId,
  }) => s.record(
    axis: axis,
    runMode: run,
    execPolicy: exec,
    operatingMode: op,
    handoverSessionValid: session,
    decisionId: decision,
    handoverSessionId: sessionId,
  );

  int rows(Database db) =>
      db.select('SELECT COUNT(*) AS n FROM mode_transition').first['n']! as int;

  void rawInsert(Database db, String mode) => db.execute(
    'INSERT INTO mode_transition (transition_id, axis, mode, exec_policy, decision_id, committed_at) '
    "VALUES ('RAW', 'RUN_MODE', ?, 'EXECUTE', 'D', 'x')",
    <Object?>[mode],
  );

  group('W1 스키마 — 기본 블록에도 @sim 치환', () {
    test('sim 파일 = SIM 두 값만 · live 파일 = LIVE 만', () {
      rawInsert(sim, 'SIM_INTERNAL');
      sim.execute("DELETE FROM mode_transition WHERE transition_id = 'RAW'");
      rawInsert(sim, 'SIM_BROKER');
      expect(() => rawInsert(sim, 'LIVE'), throwsA(isA<SqliteException>()));
      rawInsert(live, 'LIVE');
      expect(
        () => live.execute(
          'INSERT INTO mode_transition (transition_id, axis, mode, exec_policy, decision_id, committed_at) '
          "VALUES ('RAW2', 'RUN_MODE', 'SIM_INTERNAL', 'EXECUTE', 'D', 'x')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('기본 블록 스크립트 = 파일마다 다르다(sim 판 = 치환) · 배치 스크립트는 그대로', () {
      final List<String> l = ledgerSchemaV1Scripts(LedgerFile.live);
      final List<String> s = ledgerSchemaV1Scripts(LedgerFile.sim);
      expect(l.first, contains("CHECK (mode = 'LIVE'),"));
      expect(
        s.first,
        contains("CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER')),"),
      );
      expect(l.first == s.first, isFalse);
      expect(l.length, s.length);
    });
  });

  group('W2 기록 · 현재 행', () {
    test('🔴 식별이 다른 파일 = 열지 않는다', () {
      expect(
        () => SqliteModeStore(sim, LedgerFile.live, clock: clock),
        throwsA(isA<StateError>()),
      );
      expect(
        () => SqliteModeStore(live, LedgerFile.sim, clock: clock),
        throwsA(isA<StateError>()),
      );
    });

    test('첫 행 · 둘째 행 = from 직전 · id 순번 · 시각 · 세션 · 현재 = 최신', () {
      final SqliteModeStore s = simStore();
      expect(s.current(), isNull);
      expect(rec(s, RunMode.simInternal, ExecPolicy.execute), isNull);
      clock.at = _t0.add(const Duration(hours: 1));
      expect(
        rec(
          s,
          RunMode.simBroker,
          ExecPolicy.execute,
          decision: 'D2',
          sessionId: 'HS-1',
        ),
        isNull,
      );
      final List<Row> r = sim
          .select('SELECT * FROM mode_transition ORDER BY transition_id')
          .toList();
      expect(r.map((Row x) => x['transition_id']), <String>[
        'MT-000001',
        'MT-000002',
      ]);
      expect(
        (
          r[0]['axis'],
          r[0]['mode'],
          r[0]['from_mode'],
          r[0]['from_exec_policy'],
          r[0]['committed_at'],
        ),
        ('RUN_MODE', 'SIM_INTERNAL', null, null, '2026-11-13T01:00:00.000Z'),
      );
      expect(
        (
          r[1]['mode'],
          r[1]['from_mode'],
          r[1]['from_exec_policy'],
          r[1]['decision_id'],
          r[1]['handover_session_id'],
        ),
        ('SIM_BROKER', 'SIM_INTERNAL', 'EXECUTE', 'D2', 'HS-1'),
      );
      final ModeRowFacts c = s.current()!;
      expect(
        (c.runMode, c.execPolicy, c.decisionId),
        (RunMode.simBroker, ExecPolicy.execute, 'D2'),
      );
    });

    test('같은 시각 두 행 = 큰 id 가 현재 · 승격 행(EXEC_POLICY)도 현재', () {
      final SqliteModeStore s = liveStore();
      rec(s, RunMode.live, ExecPolicy.dryRun);
      rec(
        s,
        RunMode.live,
        ExecPolicy.execute,
        axis: ModeAxis.execPolicy,
        decision: 'D-PROMOTE',
      );
      expect(s.current()!.execPolicy, ExecPolicy.execute);
      expect(
        live
            .select(
              "SELECT axis FROM mode_transition WHERE transition_id = 'MT-000002'",
            )
            .first['axis'],
        'EXEC_POLICY',
      );
    });

    test('🔴 금지 조합 = 쓰지 않고 거부 코드 · 직전 유효 유지 · #12 = 세션 있을 때만', () {
      final SqliteModeStore s = simStore();
      rec(s, RunMode.simInternal, ExecPolicy.execute);
      expect(
        rec(s, RunMode.simInternal, ExecPolicy.dryRun),
        kModeCombinationDenied,
      );
      expect(
        rec(
          s,
          RunMode.simBroker,
          ExecPolicy.execute,
          op: OperatingMode.advisory,
        ),
        kModeCombinationDenied,
      );
      expect(rows(sim), 1);
      expect(s.current()!.execPolicy, ExecPolicy.execute);
      final SqliteModeStore l = liveStore();
      expect(
        rec(l, RunMode.live, ExecPolicy.dryRun, op: OperatingMode.advisory),
        kModeCombinationDenied,
      );
      expect(rows(live), 0);
      expect(
        rec(
          l,
          RunMode.live,
          ExecPolicy.dryRun,
          op: OperatingMode.advisory,
          session: true,
        ),
        isNull,
      );
      expect(rows(live), 1);
    });

    test('🔴 다른 계열 모드 · CLOSE 축 = ArgumentError(쓰지 않음)', () {
      expect(
        () => rec(liveStore(), RunMode.simInternal, ExecPolicy.execute),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => rec(simStore(), RunMode.live, ExecPolicy.execute),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => rec(
          simStore(),
          RunMode.simInternal,
          ExecPolicy.execute,
          axis: ModeAxis.close,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect((rows(live), rows(sim)), (0, 0));
    });
  });

  group('CLOSE', () {
    test('sim 만 · 현재 값으로 1행 · 다시 닫기 = 그대로 · 닫힌 뒤 기록 = StateError · 현재는 CLOSE 를 건너뜀', () {
      final SqliteModeStore s = simStore();
      expect(() => s.close(decisionId: 'D'), throwsA(isA<StateError>()));
      rec(s, RunMode.simBroker, ExecPolicy.execute);
      expect(s.closed(), isFalse);
      s.close(decisionId: 'D-CLOSE', handoverSessionId: 'HS-9');
      expect(s.closed(), isTrue);
      s.close(decisionId: 'D-AGAIN');
      expect(rows(sim), 2);
      final Row c = sim
          .select("SELECT * FROM mode_transition WHERE axis = 'CLOSE'")
          .first;
      expect(
        (
          c['mode'],
          c['exec_policy'],
          c['decision_id'],
          c['handover_session_id'],
          c['from_mode'],
        ),
        ('SIM_BROKER', 'EXECUTE', 'D-CLOSE', 'HS-9', 'SIM_BROKER'),
      );
      expect(s.current()!.decisionId, 'D1');
      expect(
        () => rec(s, RunMode.simInternal, ExecPolicy.execute),
        throwsA(isA<StateError>()),
      );
      final SqliteModeStore l = liveStore();
      rec(l, RunMode.live, ExecPolicy.dryRun);
      expect(() => l.close(decisionId: 'D'), throwsA(isA<StateError>()));
      expect(rows(live), 1);
    });
  });

  group('W3 운영 방식 원천', () {
    test(
      '둘 다 없음 = null · 미커밋 온보딩 = null · 커밋 = 그 값 · 전이 최신이 이긴다(같은 시각 = 큰 id)',
      () {
        final SqliteModeStore s = simStore();
        expect(s.operatingMode(), isNull);
        sim.execute(
          "INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, 'ADVISORY', 'x', NULL)",
        );
        expect(s.operatingMode(), isNull);
        sim.execute("UPDATE onboarding_choice SET committed_at = 'y'");
        expect(s.operatingMode(), OperatingMode.advisory);
        sim.execute(
          'INSERT INTO operating_mode_transition (transition_id, handover_session_id, from_mode, to_mode, decision_id, committed_at) '
          "VALUES ('OT-2', 'HS', 'ADVISORY', 'AUTO_TRADE', 'D', '2026-11-13T02:00:00.000Z'), "
          "('OT-1', 'HS', 'AUTO_TRADE', 'ADVISORY', 'D', '2026-11-13T02:00:00.000Z'), "
          "('OT-0', 'HS', 'ADVISORY', 'ADVISORY', 'D', '2026-11-13T03:00:00.000Z')",
        );
        expect(s.operatingMode(), OperatingMode.advisory);
        sim.execute(
          "DELETE FROM operating_mode_transition WHERE transition_id = 'OT-0'",
        );
        expect(s.operatingMode(), OperatingMode.autoTrade);
      },
    );

    test('스냅숏 = 행 없음 null · 있으면 모드 · 집행 · 운영 방식 · 구독 = 즉시 + 바뀔 때', () async {
      final SqliteModeStore s = simStore();
      expect(s.snapshot(), isNull);
      final List<ModeSnapshot?> got = <ModeSnapshot?>[];
      final StreamSubscription<ModeSnapshot?> sub = s.watchCurrent().listen(
        got.add,
      );
      await pumpEventQueue();
      rec(s, RunMode.simInternal, ExecPolicy.execute);
      await pumpEventQueue();
      await sub.cancel();
      expect(got.first, isNull);
      expect(got.last!.runMode, RunMode.simInternal);
      expect(got.last!.execPolicy, ExecPolicy.execute);
      expect(got.last!.operatingMode, isNull);
    });
  });

  group('W4 기동 해석 · 반쯤 끝난 커밋 복구(두 파일 따로)', () {
    test('sim 만 = sim · live 없음(null) = sim · 둘 다 없음 = 온보딩 미완', () {
      expect(
        bootModeOf(live: liveStore(), sim: simStore()),
        isA<BootModeOnboardingIncomplete>(),
      );
      rec(simStore(), RunMode.simInternal, ExecPolicy.execute);
      final BootMode a = bootModeOf(live: null, sim: simStore());
      expect(identical((a as BootModeResolved).file, LedgerFile.sim), isTrue);
      expect(a.runMode, RunMode.simInternal);
      expect(repairHalfCommit(a, simStore()), isFalse);
      expect(rows(sim), 1);
    });

    test(
      '🔴 live 행 먼저 · sim 안 닫힘 = live 로 열고 sim 에만 CLOSE 1행 · 다음 기동 = 고칠 것 없음',
      () {
        rec(simStore(), RunMode.simInternal, ExecPolicy.execute);
        rec(liveStore(), RunMode.live, ExecPolicy.dryRun, decision: 'D-S2A');
        final BootMode m = bootModeOf(live: liveStore(), sim: simStore());
        final BootModeResolved r = m as BootModeResolved;
        expect(
          (
            identical(r.file, LedgerFile.live),
            r.runMode,
            r.execPolicy,
            r.repairSimClose,
          ),
          (true, RunMode.live, ExecPolicy.dryRun, true),
        );
        expect(repairHalfCommit(m, simStore()), isTrue);
        expect(rows(live), 1);
        expect(
          sim
              .select(
                "SELECT decision_id FROM mode_transition WHERE axis = 'CLOSE'",
              )
              .first['decision_id'],
          'D-S2A',
        );
        final BootMode again = bootModeOf(live: liveStore(), sim: simStore());
        expect((again as BootModeResolved).repairSimClose, isFalse);
        expect(repairHalfCommit(again, simStore()), isFalse);
        expect(rows(sim), 2);
        expect(
          repairHalfCommit(const BootModeOnboardingIncomplete(), simStore()),
          isFalse,
        );
      },
    );
  });

  group('W5 판정 입력 실물', () {
    void session(String id, String expires, {String? closedAt}) => sim.execute(
      'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, opened_at, expires_at, closed_at) '
      "VALUES (?, 'WIZARD_M5_11', 'SIM_TO_AUTO', 'dev', 0, 'x', ?, ?)",
      <Object?>[id, expires, closedAt],
    );

    test('#12 세션 = 열림 ∧ 만료 전만 · 실키 = 주입 그대로', () async {
      bool keys = false;
      final SqliteModeFacts f = SqliteModeFacts(
        sim,
        clock: clock,
        liveKeysVerified: () async => keys,
      );
      ModeFacts x = await f.facts();
      expect((x.handoverSessionValid, x.liveKeysVerified), (false, false));
      session('HS-OLD', '2026-11-13T00:59:59.000Z');
      session('HS-CLOSED', '2026-11-14T00:00:00.000Z', closedAt: 'x');
      x = await f.facts();
      expect(x.handoverSessionValid, isFalse);
      session('HS-OPEN', '2026-11-13T01:00:01.000Z');
      keys = true;
      x = await f.facts();
      expect((x.handoverSessionValid, x.liveKeysVerified), (true, true));
      clock.at = DateTime.utc(2026, 11, 13, 1, 0, 1);
      expect((await f.facts()).handoverSessionValid, isFalse);
    });
  });
}
