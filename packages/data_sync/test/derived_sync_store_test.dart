// E16f3a — X5-4 파생 FORK 기록 · 아카이브 관계 · 잡 배선(설계 13 §8 R130 L2~L11).
//
// 🔵 잡는 것: ① 정본 체인 = 스탬프 + 새 기준점(CANON_CORRECT · LEDGER_INTEGRITY 만 · 날 차례 · 빈 칸 = 오류)
//    ② 상태 = 행 없음 OK ③ 아카이브 관계(EMPTY · IN_SYNC · EPOCH_AHEAD · AHEAD) ④ 🔴 FORK 기록 = 바뀐 때만 true ·
//    SEALED 안 덮음 · OK 행의 last_ok_at · epoch 그대로 · diff 관측 한 번 · FORK 아님 = 오류 · 쓰기 0
//    ⑤ REBASED 관측 diff ⑥ 잡 = FORK 건너뜀 + P0 한 번(끈적) · 봉인 건너뜀 · 새 기준점 뒤 REBASED 건너뜀(던지지 않음).
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ledger_golden.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

void main() {
  late Directory dir;
  late Directory root;
  late Database db;
  late _Clock clock;
  late SqliteDerivedSyncStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_dfs_');
    root = Directory('${dir.path}/repo')..createSync();
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    store = SqliteDerivedSyncStore(db);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  LedgerArchiveWriter writer({int epoch = 0}) => LedgerArchiveWriter(
    db,
    root: root.path,
    mode: RunMode.live,
    clock: clock,
    writerDeviceId: 'dev-1',
    operatorEpoch: epoch,
  );

  void stamp(String through) =>
      LedgerHashStamper(db, clock: clock).stampThrough(through);

  List<String> tree() => <String>[
    for (final FileSystemEntity e in root.listSync(recursive: true))
      if (e is File)
        e.path.substring(root.path.length + 1).replaceAll(r'\', '/'),
  ]..sort();

  List<Map<String, Object?>> rows(String sql) => <Map<String, Object?>>[
    for (final Row r in db.select(sql))
      <String, Object?>{for (final String k in r.keys) k: r[k]},
  ];

  void repairRow(
    String id, {
    String direction = 'CANON_CORRECT',
    String kind = 'LEDGER_INTEGRITY',
    String? from = '2026-11-03',
    String? decision = 'dec',
  }) {
    db.execute(
      'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
      "evidence_hash, supersedes, applied_at) VALUES (?, 'li-x', ?, 'CHAIN_BROKEN', ?, 'ev_x', NULL, "
      "'2026-11-05T00:00:00.000Z')",
      <Object?>[id, direction, decision],
    );
    db.execute(
      'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
      'VALUES (?, ?, ?, ?, NULL)',
      <Object?>[id, from, kChainGenesis, '{"kind":"$kind"}'],
    );
  }

  group('정본 체인', () {
    test(
      '스탬프 차례 · 새 기준점 = CANON_CORRECT × LEDGER_INTEGRITY 만 · 날 차례(id 차례 아님)',
      () {
        loadLedgerGolden(db);
        stamp('2026-11-04');
        repairRow('rp-a', from: '2026-11-04', decision: 'dec-a');
        repairRow('rp-b', from: '2026-11-03', decision: 'dec-b');
        repairRow('rp-q', kind: 'QUANTITY');
        repairRow('rp-r', direction: 'DERIVED_RESYNC');
        final CanonChain c = canonChainOf(db, operatorEpoch: 4);
        expect(c.stamps.map((StoredDayStamp s) => s.authoredDate), <String>[
          '2026-11-02',
          '2026-11-03',
          '2026-11-04',
        ]);
        expect(c.operatorEpoch, 4);
        expect(
          c.baselines.map((ChainBaseline b) => (b.fromDate, b.decisionId)),
          <(String, String)>[('2026-11-03', 'dec-b'), ('2026-11-04', 'dec-a')],
        );
        expect(storedDayStampsOf(db).length, 3);
      },
    );

    test('🔴 새 기준점에 다시 센 첫 날 · 결정이 없으면 오류(지어내지 않는다)', () {
      repairRow('rp-1', from: null);
      expect(() => canonChainOf(db, operatorEpoch: 0), throwsStateError);
      db.execute('DELETE FROM ledger_repair_detail');
      db.execute('DELETE FROM ledger_repair');
      repairRow('rp-2', decision: null);
      expect(() => canonChainOf(db, operatorEpoch: 0), throwsStateError);
    });
  });

  test('상태 = 행 없음 OK · 있으면 그 값', () {
    expect(store.statusOf(DerivedTarget.github), DerivedSyncStatus.ok);
    db.execute(
      "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', NULL, 'PUSH_FAILED', 0, 'x')",
    );
    expect(store.statusOf(DerivedTarget.github), DerivedSyncStatus.pushFailed);
    expect(store.statusOf(DerivedTarget.supabase), DerivedSyncStatus.ok);
  });

  group('아카이브 관계', () {
    setUp(() {
      loadLedgerGolden(db);
      stamp('2026-11-04');
    });
    test('체크포인트 없음 = EMPTY · 아카이브 뒤 = IN_SYNC', () {
      final DerivedView e = store.archiveView(writer(), operatorEpoch: 0);
      expect((e.relation, e.derived), (DerivedRelation.empty, null));
      writer().archiveStamped();
      final DerivedView s = store.archiveView(writer(), operatorEpoch: 0);
      expect(s.relation, DerivedRelation.inSync);
      expect(s.derived!.authoredDate, '2026-11-04');
      expect(s.canon.lastDate, '2026-11-04');
    });
    test('🔴 쓴 epoch > 정본 epoch = EPOCH_AHEAD · 정본이 짧으면 AHEAD', () {
      writer(epoch: 3).archiveStamped();
      expect(
        store.archiveView(writer(), operatorEpoch: 2).relation,
        DerivedRelation.epochAhead,
      );
      expect(
        store.archiveView(writer(), operatorEpoch: 3).relation,
        DerivedRelation.inSync,
      );
      db.execute(
        "DELETE FROM ledger_daily_hash WHERE authored_date = '2026-11-04'",
      );
      expect(
        store.archiveView(writer(), operatorEpoch: 3).relation,
        DerivedRelation.ahead,
      );
    });
  });

  group('🔴 FORK 기록', () {
    late DerivedView fork;
    setUp(() {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      writer(epoch: 3).archiveStamped();
      fork = store.archiveView(writer(), operatorEpoch: 1);
      expect(fork.relation, DerivedRelation.epochAhead);
    });

    test(
      '없으면 넣는다(epoch = 정본 · last_ok_at 없음) · diff 관측 OPEN 한 번 · 두 번째 = 바뀜 없음',
      () {
        final DateTime at = _t0.add(const Duration(minutes: 1));
        expect(store.recordFork(DerivedTarget.github, fork, at), isTrue);
        expect(rows('SELECT * FROM sync_state'), <Map<String, Object?>>[
          <String, Object?>{
            'target': 'GITHUB',
            'last_ok_at': null,
            'status': 'FORK',
            'operator_epoch': 1,
            'updated_at': at.toIso8601String(),
          },
        ]);
        final DerivedChainDiff d = derivedChainDiffOf(
          DerivedTarget.github,
          fork.relation,
          fork.canon,
          fork.derived,
        )!;
        final List<Map<String, Object?>> diffs = rows(
          'SELECT diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, '
          'status, detected_at, applicable FROM ledger_diff',
        );
        expect(diffs, <Map<String, Object?>>[
          <String, Object?>{
            'diff_id': d.diffId,
            'pair': 'CANON_GITHUB',
            'axis': 'CHAIN_HASH',
            'authored_date': '2026-11-04',
            'delta': d.deltaJson,
            'delta_label': d.label,
            'severity': 'OBSERVATIONAL',
            'origin_code': null,
            'status': 'OPEN',
            'detected_at': at.toIso8601String(),
            'applicable': 1,
          },
        ]);
        // 끈적 — 다시 = 바뀜 없음 · diff 그대로 한 건 · 갱신 시각 그대로.
        expect(
          store.recordFork(
            DerivedTarget.github,
            fork,
            at.add(const Duration(hours: 1)),
          ),
          isFalse,
        );
        expect(
          rows('SELECT updated_at FROM sync_state').single['updated_at'],
          at.toIso8601String(),
        );
        expect(rows('SELECT * FROM ledger_diff'), hasLength(1));
      },
    );

    test('OK 행이면 FORK 로 바꾼다 — last_ok_at · epoch 그대로', () {
      db.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', 'ok-at', 'OK', 7, 'u0')",
      );
      expect(store.recordFork(DerivedTarget.github, fork, _t0), isTrue);
      expect(
        rows(
          'SELECT last_ok_at, status, operator_epoch, updated_at FROM sync_state',
        ).single,
        <String, Object?>{
          'last_ok_at': 'ok-at',
          'status': 'FORK',
          'operator_epoch': 7,
          'updated_at': _t0.toIso8601String(),
        },
      );
    });

    test('🔴 SEALED 는 덮지 않는다(봉인이 풀린다) — 바뀜 없음 · diff 는 남긴다', () {
      db.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'SEALED', 2, 'u0')",
      );
      expect(store.recordFork(DerivedTarget.supabase, fork, _t0), isFalse);
      expect(
        rows('SELECT status, updated_at FROM sync_state').single,
        <String, Object?>{'status': 'SEALED', 'updated_at': 'u0'},
      );
      expect(
        rows('SELECT pair FROM ledger_diff').single['pair'],
        'CANON_SUPABASE',
      );
    });

    test(
      'FORK 도 아니고 지금 FORK 도 아님 = ArgumentError · 쓰기 0 · 지금 FORK 면 관계 같아도 바뀜 없음',
      () {
        final DerivedView ok = store.archiveView(writer(), operatorEpoch: 3);
        expect(ok.relation, DerivedRelation.inSync);
        expect(
          () => store.recordFork(DerivedTarget.github, ok, _t0),
          throwsArgumentError,
        );
        expect(rows('SELECT * FROM sync_state'), isEmpty);
        expect(rows('SELECT * FROM ledger_diff'), isEmpty);
        expect(store.recordFork(DerivedTarget.github, fork, _t0), isTrue);
        expect(store.recordFork(DerivedTarget.github, ok, _t0), isFalse);
        expect(rows('SELECT * FROM ledger_diff'), hasLength(1));
      },
    );
  });

  test('REBASED 관측 diff — 한 번 · REBASED 아님 = ArgumentError', () {
    loadLedgerGolden(db);
    stamp('2026-11-04');
    final DerivedView empty = store.archiveView(writer(), operatorEpoch: 0);
    expect(
      () => store.recordRebased(DerivedTarget.github, empty, _t0),
      throwsArgumentError,
    );
    final DerivedView rebased = (
      canon: CanonChain(
        stamps: storedDayStampsOf(db),
        operatorEpoch: 0,
        baselines: const <ChainBaseline>[
          ChainBaseline(fromDate: '2026-11-03', decisionId: 'dec'),
        ],
      ),
      derived: DerivedStamp(
        authoredDate: '2026-11-04',
        chainHash: 'a' * 64,
        operatorEpoch: 0,
      ),
      relation: DerivedRelation.rebased,
    );
    expect(store.recordRebased(DerivedTarget.github, rebased, _t0), isTrue);
    expect(store.recordRebased(DerivedTarget.github, rebased, _t0), isFalse);
    final Map<String, Object?> d = rows(
      'SELECT pair, axis, severity, status FROM ledger_diff',
    ).single;
    expect(d, <String, Object?>{
      'pair': 'CANON_GITHUB',
      'axis': 'CHAIN_HASH',
      'severity': 'OBSERVATIONAL',
      'status': 'OPEN',
    });
    expect(rows('SELECT * FROM sync_state'), isEmpty);
  });

  group('잡 배선(DailyArchiveJob)', () {
    DailyArchiveJob job({int epoch = 0}) => DailyArchiveJob(
      db,
      clock: clock,
      root: root.path,
      mode: RunMode.live,
      writerDeviceId: 'dev-1',
      operatorEpoch: epoch,
    );

    test('평시 = 관계 보고 · 아카이브 · 건너뜀 없음', () {
      loadLedgerGolden(db);
      final DailyArchiveReport r = job().run();
      expect(
        (r.skipped, r.relation, r.forkRaised),
        (null, DerivedRelation.empty, false),
      );
      expect(r.archived, hasLength(3));
      expect(r.toString(), contains('아카이브 3'));
      clock.at = _t0.add(const Duration(days: 1));
      final DailyArchiveReport n = job().run();
      expect((n.skipped, n.relation), (null, DerivedRelation.behind));
      expect(n.archived, <String>['2026-11-05']);
    });

    test('🔴 FORK = 건너뜀 · P0 한 번 · 끈적(다음 날 · 체크포인트를 지워도)', () {
      loadLedgerGolden(db);
      stamp('2026-11-04');
      writer(epoch: 3).archiveStamped();
      final List<String> before = tree();
      final DailyArchiveReport r = job().run();
      expect(
        (r.skipped, r.relation, r.forkRaised),
        (ArchiveSkip.fork, DerivedRelation.epochAhead, true),
      );
      expect(r.archived, isEmpty);
      expect(r.alerts, contains(kDerivedForkAlertCode));
      expect(alertLevelOf(kDerivedForkAlertCode), AlertLevel.p0);
      expect(r.toString(), contains('건너뜀 FORK'));
      expect(tree(), before);
      clock.at = _t0.add(const Duration(days: 1));
      final DailyArchiveReport again = job().run();
      expect((again.skipped, again.forkRaised), (ArchiveSkip.fork, false));
      expect(again.alerts, isNot(contains(kDerivedForkAlertCode)));
      expect(again.archived, isEmpty);
      File('${root.path}/${archiveCheckpointPath(archivePrefix(sim: false))}')
          .deleteSync();
      final DailyArchiveReport sticky = job().run();
      expect(
        (sticky.skipped, sticky.relation, sticky.forkRaised),
        (ArchiveSkip.fork, DerivedRelation.empty, false),
      );
      expect(store.statusOf(DerivedTarget.github), DerivedSyncStatus.fork);
    });

    test('봉인 = 건너뜀(아카이브 0)', () {
      loadLedgerGolden(db);
      db.execute(
        "INSERT INTO sync_state(target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', NULL, 'SEALED', 0, 'u0')",
      );
      final DailyArchiveReport r = job().run();
      expect(r.skipped, ArchiveSkip.sealed);
      expect(r.archived, isEmpty);
      expect(r.toString(), contains('건너뜀 봉인'));
      expect(tree(), isEmpty);
    });

    test('🔴 새 기준점 뒤 = REBASED 건너뜀(던지지 않음) + 관측 diff · FORK 아님', () {
      loadLedgerGolden(db);
      job().run();
      final List<String> before = tree();
      db.execute(
        "UPDATE decision_log SET reason = reason || '.' WHERE decision_id = 'D-1'",
      );
      clock.at = _t0.add(const Duration(days: 1));
      final DailyArchiveReport bad = job().run();
      expect((bad.skipped, bad.relation), (ArchiveSkip.integrity, null));
      expect(bad.toString(), contains('건너뜀 무결성'));
      final BaselineResult b =
          SqliteLedgerRepairStore(
            db,
            trusted: _Trusted(clock.at),
          ).applyBaseline(
            repairId: 'rp-1',
            decisionId: 'dec-x5',
            originCode: OriginCodes.chainBroken,
            clearedBy: 'operator',
          );
      expect(b.applied, isTrue);
      final DailyArchiveReport r = job().run();
      expect(
        (r.skipped, r.relation, r.forkRaised),
        (ArchiveSkip.rebased, DerivedRelation.rebased, false),
      );
      expect(r.alerts, isNot(contains(kDerivedForkAlertCode)));
      expect(r.toString(), contains('건너뜀 REBASED 대기'));
      expect(tree(), before);
      expect(store.statusOf(DerivedTarget.github), DerivedSyncStatus.ok);
      expect(
        rows('SELECT pair, delta FROM ledger_diff').single['delta'] as String,
        contains('"relation":"REBASED"'),
      );
    });
  });
}
