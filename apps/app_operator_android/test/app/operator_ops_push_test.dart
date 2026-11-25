// 🆕 미결 244 ⓐ ⓑ — 운영 폰 공유 표 push 배선 · 깨어남 뒤 실행 시험(설계 13 §8 R271 O4 · O8).
//
// ① 실행 = 포트 · 화면 상태가 다 있을 때만(없으면 null) · epoch 0 = 미러 · 스탬프 noLease · 호출 0
// ② 원장 = 화면 상태의 원장 · 행 mode = 화면 상태의 실행 모드 · 미러 2표 → 스탬프 차례
// ③ 스탬프 = 읽기 포트 · 운영 설정(하루 상한)이 없으면 0(지어내지 않는다) · FORK = P0 `DERIVED_FORK` 알림 행(출처 derived_supabase)
// ④ 재생성 리스 = 할 일이 있을 때만 `operatorLeaseGate` 판정 — 원격 없음 live = 모름 → 미룸(호출 0)
// ⑤ 깨어남 뒤 칸 = 읽기 모델 → 운영 표 차례 · 앞이 던져도 다음은 간다 · 겹침 0.

import 'dart:async';

import 'package:app_operator_android/app/operator_ops_push.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show DerivedHoldReason, DerivedRelation, DerivedStamp, OperationsConfig;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../engine/support.dart';

class _Pusher implements OpsPusher {
  _Pusher([this.answer]);

  /// 🆕 R273 — 표 이름 → 답(없음 · null = 성공).
  final OpsPushResult? Function(String table)? answer;
  final List<(String, int, List<Map<String, Object?>>)> calls =
      <(String, int, List<Map<String, Object?>>)>[];
  @override
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  }) async {
    calls.add((table, epoch, rows));
    final OpsPushResult? a = answer?.call(table);
    if (a != null) return a;
    return OpsPushResult.answered(
      code: null,
      epoch: epoch,
      accepted: rows.length,
      skipped: 0,
    );
  }
}

class _Reader implements LedgerStampReader {
  _Reader(this.answer);
  LedgerStampRead answer;
  final List<RunMode> calls = <RunMode>[];
  @override
  Future<LedgerStampRead> lastStamp(RunMode mode) async {
    calls.add(mode);
    return answer;
  }
}

final OperationsConfig _ops = OperationsConfig.fromJson(<String, Object?>{
  'migration': <String, Object?>{'derived_resync_daily_cap': 3},
});

void main() {
  late FakeClock clock;
  setUp(() => clock = FakeClock(kst(2026, 12, 22, 9, 30)));

  void claim(Database db, int epoch) => db.execute(
    'INSERT INTO sync_state(target, status, operator_epoch, updated_at) VALUES (?, ?, ?, ?)',
    <Object?>[kLeaseSyncTarget, 'OK', epoch, clock.nowUtc().toIso8601String()],
  );

  OperatorView viewOf(Database db, RunMode mode) => OperatorView(
    db: db,
    flags: FeatureFlags(
      satelliteEnabled: false,
      webViewerEnabled: false,
      calendarEnabled: false,
      runMode: mode,
      operatingMode: OperatingMode.autoTrade,
      configHash: 'cfg_test',
    ),
  );

  void seedMirrors(Database db) {
    db.execute(
      'INSERT INTO planned_work (work_id, idempotency_key, kind, created_at, due_by, state, digest, one_line, row_version) '
      "VALUES ('PW-1', 'k1', 'SEASONAL_WINDOW', '2026-12-01T00:00:00.000Z', '2026-12-30', 'PLANNED', 'dg', '한 줄', 2)",
    );
    db.execute(
      'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
      "VALUES ('RR-1', '2026-12-21T00:00:00.000Z', NULL, 1, 'CONSERVATIVE', 'R8', '{}', NULL)",
    );
  }

  void seedStamp(Database db) => db.execute(
    'INSERT INTO ledger_daily_hash (authored_date, day_hash, chain_hash, hash_format_version, row_counts, created_at) '
    "VALUES ('2026-12-19', ?, ?, 1, '{}', '2026-12-20T00:00:00.000Z')",
    <Object?>['11' * 32, '22' * 32],
  );

  test('① 실행 = 포트 · 화면 상태가 다 있을 때만 · epoch 0 = noLease · 호출 0', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final _Reader r = _Reader(const LedgerStampRead.ok(null));
    expect(
      await runOperatorOpsPush(
        rt: OperatorRuntime(files: f, clock: clock),
      ),
      isNull,
      reason: '포트 · 화면 상태 없음',
    );
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: clock,
      opsPusher: p,
      ledgerStampReader: r,
      operations: _ops,
      deviceId: 'dev-a',
    );
    expect(await runOperatorOpsPush(rt: rt), isNull, reason: '화면 상태 없음');
    rt.view.value = viewOf(f.sim, RunMode.simBroker);
    seedMirrors(f.sim);
    final OperatorOpsPushReport? rep = await runOperatorOpsPush(rt: rt);
    expect(rep!.mirrors.noLease, isTrue);
    expect(rep.stamps!.noLease, isTrue);
    expect((p.calls.length, r.calls.length), (0, 0));
  });

  test(
    '② 원장 = 화면 상태 · 행 mode = 실행 모드 · 미러 2표 → 스탬프 · epoch = 그 원장 SUPABASE epoch',
    () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      final _Pusher p = _Pusher();
      final _Reader r = _Reader(const LedgerStampRead.ok(null));
      final OperatorRuntime rt = OperatorRuntime(
        files: f,
        clock: clock,
        opsPusher: p,
        ledgerStampReader: r,
        operations: _ops,
        deviceId: 'dev-a',
      );
      rt.view.value = viewOf(f.sim, RunMode.simBroker);
      seedMirrors(f.sim);
      claim(f.sim, 5);
      final OperatorOpsPushReport? rep = await runOperatorOpsPush(rt: rt);
      expect(rep!.failed, isEmpty);
      expect(p.calls.map((c) => (c.$1, c.$2)).toList(), <(String, int)>[
        ('planned_work_mirror', 5),
        ('resume_run_mirror', 5),
      ]);
      expect(p.calls.first.$3.single['mode'], 'SIM_BROKER');
      expect(p.calls.last.$3.single['resume_mode'], 'CONSERVATIVE');
      expect(r.calls, <RunMode>[RunMode.simBroker]);
      expect(
        rep.stamps!.relation,
        DerivedRelation.inSync,
        reason: '정본 0 · 원격 0',
      );
    },
  );

  test(
    '③ 운영 설정 · 읽기 포트가 없으면 스탬프 0 · FORK = P0 알림 행(derived_supabase) 한 번',
    () async {
      final LedgerFiles f = openFiles(tempLedgerDir(), clock);
      final _Pusher p = _Pusher();
      final _Reader r = _Reader(
        LedgerStampRead.ok(
          DerivedStamp(
            authoredDate: '2026-12-19',
            chainHash: '22' * 32,
            operatorEpoch: 9, // 더 새 기기
          ),
        ),
      );
      OperatorRuntime rtWith({
        OperationsConfig? ops,
        LedgerStampReader? reader,
      }) => OperatorRuntime(
        files: f,
        clock: clock,
        opsPusher: p,
        ledgerStampReader: reader,
        operations: ops,
        deviceId: 'dev-a',
      )..view.value = viewOf(f.sim, RunMode.live);
      claim(f.sim, 5);
      seedStamp(f.sim);
      expect((await runOperatorOpsPush(rt: rtWith(reader: r)))!.stamps, isNull);
      expect((await runOperatorOpsPush(rt: rtWith(ops: _ops)))!.stamps, isNull);
      expect(r.calls, isEmpty);
      final OperatorOpsPushReport? a = await runOperatorOpsPush(
        rt: rtWith(ops: _ops, reader: r),
      );
      expect(a!.stamps!.forkRaised, isTrue);
      List<(Object?, Object?, Object?)> alerts() =>
          <(Object?, Object?, Object?)>[
            for (final row in f.sim.select(
              'SELECT code, level, source FROM alert_event ORDER BY raised_at',
            ))
              (row['code'], row['level'], row['source']),
          ];
      expect(alerts(), <(Object?, Object?, Object?)>[
        (AlertCodes.derivedFork, 'P0', kSupabaseStampCheck),
      ]);
      await runOperatorOpsPush(
        rt: rtWith(ops: _ops, reader: r),
      );
      expect(alerts(), hasLength(1), reason: '끈적 — 다시 알리지 않는다');
      expect(r.calls, hasLength(1), reason: 'FORK 뒤 = 망 0');
      expect(p.calls.where((c) => c.$1 == 'ledger_stamp'), isEmpty);
    },
  );

  test('④ 재생성 리스 = 할 일이 있을 때만 · 원격 원천 없는 live = 모름 → 미룸(스탬프 호출 0)', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final _Pusher p = _Pusher();
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: clock,
      opsPusher: p,
      ledgerStampReader: _Reader(const LedgerStampRead.ok(null)),
      operations: _ops,
      deviceId: 'dev-a',
    )..view.value = viewOf(f.sim, RunMode.live);
    claim(f.sim, 5);
    seedStamp(f.sim);
    final OperatorOpsPushReport? rep = await runOperatorOpsPush(rt: rt);
    expect(
      (rep!.stamps!.relation, rep.stamps!.hold),
      (DerivedRelation.empty, DerivedHoldReason.leaseNotValid),
    );
    expect(p.calls.where((c) => c.$1 == 'ledger_stamp'), isEmpty);
  });

  test('🆕 ⑥ R273 사람이 볼 실패 = K344 P1(낸 곳 shared_push) · 리스 · 망 = 0 · 스탬프 읽기 포트 없어도 미러 실패는 낸다', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    OperatorRuntime rtOf(OpsPusher p) =>
        OperatorRuntime(files: f, clock: clock, opsPusher: p, deviceId: 'dev-a')
          ..view.value = viewOf(f.sim, RunMode.simBroker);
    seedMirrors(f.sim);
    claim(f.sim, 5);
    List<(Object?, Object?, Object?)> alerts() => <(Object?, Object?, Object?)>[
      for (final row in f.sim.select(
        'SELECT code, level, source FROM alert_event ORDER BY code',
      ))
        (row['code'], row['level'], row['source']),
    ];
    // 리스 거부 · 망 = 알림 0.
    for (final OpsPushResult quiet in <OpsPushResult>[
      const OpsPushResult.answered(
        code: 'LEASE_LOST',
        epoch: 6,
        accepted: 0,
        skipped: 0,
      ),
      const OpsPushResult.failed(OpsPushFailure.network),
    ]) {
      final OperatorOpsPushReport? r = await runOperatorOpsPush(
        rt: rtOf(_Pusher((String t) => quiet)),
      );
      expect(r!.failed, isEmpty);
    }
    expect(alerts(), isEmpty);
    final OperatorOpsPushReport? r = await runOperatorOpsPush(
      rt: rtOf(
        _Pusher(
          (String t) => t == 'resume_run_mirror'
              ? const OpsPushResult.answered(
                  code: 'OPS_PUSH_ROWS_INVALID',
                  epoch: 5,
                  accepted: 0,
                  skipped: 0,
                )
              : null,
        ),
      ),
    );
    expect(r!.stamps, isNull, reason: '읽기 포트 없음');
    expect(alerts(), <(Object?, Object?, Object?)>[
      (AlertCodes.readModelPushRejected, 'P1', kSharedPushAlertSource),
    ]);
    // 같은 날 시크릿 차단 = 다른 코드 한 건 더 · 다시 거부 = 새 행 0.
    await runOperatorOpsPush(
      rt: rtOf(
        _Pusher(
          (String t) => const OpsPushResult.failed(
            OpsPushFailure.secretBlocked,
            secretFindings: 1,
          ),
        ),
      ),
    );
    expect(alerts(), <(Object?, Object?, Object?)>[
      (AlertCodes.readModelPushRejected, 'P1', kSharedPushAlertSource),
      (AlertCodes.readModelPushSecretBlocked, 'P1', kSharedPushAlertSource),
    ]);
  });

  test('⑤ 깨어남 뒤 칸 = 읽기 모델 → 운영 표 차례 · 앞이 던져도 다음 · 겹침 0', () async {
    final LedgerFiles f = openFiles(tempLedgerDir(), clock);
    final OperatorRuntime rt = OperatorRuntime(files: f, clock: clock);
    final List<String> seen = <String>[];
    final Completer<void> gate = Completer<void>();
    rt.attachOpsPush(() async => seen.add('ops'));
    await rt.pushReadModelsOnce();
    expect(seen, <String>['ops'], reason: '읽기 모델을 안 달아도 운영 표는 간다');
    rt.attachReadModelPush(() async {
      seen.add('rm');
      await gate.future;
      throw StateError('망');
    });
    final Future<void> a = rt.pushReadModelsOnce();
    await rt.pushReadModelsOnce(); // 도는 중 = 건너뜀
    gate.complete();
    await a;
    expect(seen, <String>['ops', 'rm', 'ops']);
  });
}
