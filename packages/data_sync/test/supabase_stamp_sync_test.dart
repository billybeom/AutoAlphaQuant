// 🆕 미결 244 ⓑ — X5 원격 사본(Supabase `ledger_stamp`) 대조 읽기 · 스탬프 실행기 시험(설계 13 §8 R271 O5~O7 · R112 D4 · R130 · R131).
//
// ① 읽기 = 그 모드 마지막 한 행(select · mode · order · limit) · 0행 = 비었다 · 꼴 틀림 = badResponse(FORK 아님) · 401 새 토큰 · 연결 칸 없음 = 망 0
// ② 실행기 차례 — 리스 없음 · 무결성 깃발 · FORK · SEALED = 망 0 · 읽기 실패 = 건너뜀(FORK 아님)
// ③ EMPTY · BEHIND = 이어 쓰기(날 오름차순 · 열 = mode · authored_date · chain_hash · 정정 행 0) · IN_SYNC = 리스 묻지 않음 · 호출 0
// ④ 리스 유효가 아니면 미룸(LEASE_NOT_VALID) · 🔴 REBASED = 관측 diff → 다시 씀(같은 날 덮음) → 정정 행 `LEDGER_STAMPS` + diff 해소 ·
//    하루 상한 = 미룸 DAILY_CAP · push 실패 = 정정 행 0 · 부분 성공 = 앞쪽만
// ⑤ 🔴 FORK(EPOCH_AHEAD · AHEAD · DIVERGED) = `sync_state` SUPABASE FORK + P0 `DERIVED_FORK` 바뀐 때만 · 리스 칸(epoch · last_ok_at) 그대로 ·
//    SEALED 를 덮지 않음 · 다음 번 = 망 0.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'support/ledger_golden.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

// 2026-11-04T21:30Z = 한국 11-05 06:30 — 11-04 까지 끝났다.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 21, 30);

// ── 읽기 받침 ─────────────────────────────────────────────────────────────────
final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';

class _Rig {
  _Rig()
    : vault = MemorySecretVault(<String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': _pub,
        'supabase.refresh_token': 'ref-${'R' * 12}',
      });

  final MemorySecretVault vault;
  final List<http.Request> gets = <http.Request>[];
  int tokenN = 0;
  late http.Response Function(int i) reply;

  late final http.Client net = MockClient((http.Request r) async {
    if (r.url.path.startsWith('/auth/')) {
      return http.Response(
        jsonEncode(<String, Object?>{
          'access_token': 'acc-${'A' * 10}-${++tokenN}',
          'expires_in': 3600,
          'refresh_token': 'ref-${'R' * 12}-$tokenN',
          'user': <String, Object?>{'id': 'uid-1'},
        }),
        200,
      );
    }
    gets.add(r);
    return reply(gets.length - 1);
  });
  late final SupabaseLedgerStampRead reader = SupabaseLedgerStampRead(
    net,
    vault,
    SupabaseAuth(net, vault, clock: _Clock(DateTime.utc(2026, 12, 8, 9))),
  );
}

http.Response _rows(List<Map<String, Object?>> rows) =>
    http.Response(jsonEncode(rows), 200);

// ── 실행기 받침 ───────────────────────────────────────────────────────────────
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

class _Pusher implements OpsPusher {
  _Pusher([this.script]);
  final OpsPushResult? Function(int i)? script;
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
    return script?.call(calls.length - 1) ??
        OpsPushResult.answered(
          code: null,
          epoch: epoch,
          accepted: rows.length,
          skipped: 0,
        );
  }
}

void main() {
  group('① 대조 읽기', () {
    test(
      '그 모드 마지막 한 행 · 질의 = select · mode · order · limit · 머리 · 0행 = 비었다',
      () async {
        final String chain = 'ab' * 32;
        final _Rig rig = _Rig()
          ..reply = (int i) => _rows(<Map<String, Object?>>[
            <String, Object?>{
              'authored_date': '2026-11-03',
              'chain_hash': chain,
              'operator_epoch': 4,
            },
          ]);
        final LedgerStampRead r = await rig.reader.lastStamp(RunMode.simBroker);
        expect(r.failure, isNull);
        expect(
          (r.stamp!.authoredDate, r.stamp!.chainHash, r.stamp!.operatorEpoch),
          ('2026-11-03', chain, 4),
        );
        final Uri u = rig.gets.single.url;
        expect(u.path, '/rest/v1/ledger_stamp');
        expect(u.queryParameters, <String, String>{
          'select': 'authored_date,chain_hash,operator_epoch',
          'mode': 'eq.SIM_BROKER',
          'order': 'authored_date.desc',
          'limit': '1',
        });
        expect(rig.gets.single.method, 'GET');
        expect(rig.gets.single.headers['apikey'], _pub);
        expect(r.toString(), isNot(contains(chain)));
        final _Rig none = _Rig()
          ..reply = (int i) => _rows(const <Map<String, Object?>>[]);
        final LedgerStampRead e = await none.reader.lastStamp(RunMode.live);
        expect((e.failure, e.stamp), (null, null));
      },
    );

    test('🔴 꼴 틀림 = badResponse(FORK 로 읽지 않는다) · 401 새 토큰 한 번 · 5xx · 연결 칸 없음 = 망 0', () async {
      for (final http.Response bad in <http.Response>[
        _rows(<Map<String, Object?>>[
          <String, Object?>{
            'authored_date': '2026-11-03',
            'chain_hash': 'zz',
            'operator_epoch': 1,
          },
        ]),
        _rows(<Map<String, Object?>>[
          <String, Object?>{
            'authored_date': '11/03',
            'chain_hash': 'ab' * 32,
            'operator_epoch': 1,
          },
        ]),
        _rows(<Map<String, Object?>>[
          <String, Object?>{
            'authored_date': '2026-11-03',
            'chain_hash': 'ab' * 32,
            'operator_epoch': -1,
          },
        ]),
        _rows(<Map<String, Object?>>[
          <String, Object?>{
            'authored_date': '2026-11-03',
            'chain_hash': 'ab' * 32,
            'operator_epoch': '4',
          },
        ]),
        _rows(<Map<String, Object?>>[
          <String, Object?>{
            'authored_date': '2026-11-03',
            'chain_hash': 'ab' * 32,
            'operator_epoch': 1,
          },
          <String, Object?>{
            'authored_date': '2026-11-02',
            'chain_hash': 'ab' * 32,
            'operator_epoch': 1,
          },
        ]),
        http.Response('{}', 200),
        http.Response('nope', 200),
        http.Response('[]', 404),
      ]) {
        final _Rig rig = _Rig()..reply = (int i) => bad;
        expect(
          (await rig.reader.lastStamp(RunMode.live)).failure,
          LedgerStampReadFailure.badResponse,
          reason: bad.body,
        );
      }
      final _Rig again = _Rig()
        ..reply = (int i) => i == 0
            ? http.Response('', 401)
            : _rows(const <Map<String, Object?>>[]);
      expect((await again.reader.lastStamp(RunMode.live)).failure, isNull);
      expect(again.gets, hasLength(2));
      final _Rig twice = _Rig()..reply = (int i) => http.Response('', 403);
      expect(
        (await twice.reader.lastStamp(RunMode.live)).failure,
        LedgerStampReadFailure.unauthorized,
      );
      final _Rig down = _Rig()..reply = (int i) => http.Response('', 502);
      expect(
        (await down.reader.lastStamp(RunMode.live)).failure,
        LedgerStampReadFailure.server,
      );
      final _Rig empty = _Rig();
      await empty.vault.delete(SupabaseSecretIds.publishableKey);
      empty.reply = (int i) => _rows(const <Map<String, Object?>>[]);
      expect(
        (await empty.reader.lastStamp(RunMode.live)).failure,
        LedgerStampReadFailure.config,
      );
      expect(empty.gets, isEmpty);
    });
  });

  group('② ~ ⑤ 실행기', () {
    late Directory dir;
    late Database db;
    late _Clock clock;
    late List<StoredDayStamp> canon;
    int leaseAsks = 0;
    setUp(() {
      leaseAsks = 0;
      dir = Directory.systemTemp.createTempSync('aaq_sbst_');
      clock = _Clock(_t0);
      db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
      loadLedgerGolden(db);
      LedgerHashStamper(db, clock: clock).stampThrough('2026-11-04');
      canon = storedDayStampsOf(db);
    });
    tearDown(() {
      db.close();
      dir.deleteSync(recursive: true);
    });

    const int epoch = 4;

    void leaseRow({String status = 'OK'}) => db.execute(
      'INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) '
      "VALUES ('SUPABASE', '2026-11-04T21:00:00.000Z', ?, ?, '2026-11-04T21:00:00.000Z')",
      <Object?>[status, epoch],
    );

    void baseline(String from) {
      db.execute(
        'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
        "evidence_hash, supersedes, applied_at) VALUES ('rp-base', 'li-x', 'CANON_CORRECT', 'CHAIN_BROKEN', 'dec', "
        "'ev_x', NULL, '2026-11-04T00:00:00.000Z')",
      );
      db.execute(
        'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
        "VALUES ('rp-base', ?, ?, '{\"kind\":\"LEDGER_INTEGRITY\"}', NULL)",
        <Object?>[from, kChainGenesis],
      );
    }

    DerivedStamp remote(String date, {String? chain, int e = epoch}) =>
        DerivedStamp(
          authoredDate: date,
          chainHash:
              chain ??
              canon
                  .firstWhere((StoredDayStamp s) => s.authoredDate == date)
                  .chainHash,
          operatorEpoch: e,
        );

    Future<LeaseVerdict> Function() leaseIs(LeaseVerdict v) => () async {
      leaseAsks++;
      return v;
    };

    SupabaseStampSyncJob job(
      _Reader r,
      _Pusher p, {
      int cap = 3,
      int chunk = kOpsPushChunk,
    }) => SupabaseStampSyncJob(
      db,
      clock: clock,
      reader: r,
      pusher: p,
      derivedResyncDailyCap: cap,
      chunk: chunk,
    );

    Future<SupabaseStampReport> runOnce(
      _Reader r,
      _Pusher p, {
      LeaseVerdict lease = LeaseVerdict.valid,
      String? device = 'dev-a',
      int e = epoch,
      int cap = 3,
      int chunk = kOpsPushChunk,
    }) => job(r, p, cap: cap, chunk: chunk).run(
      deviceId: device,
      epoch: e,
      mode: RunMode.live,
      lease: leaseIs(lease),
    );

    List<Map<String, Object?>> repairs() => <Map<String, Object?>>[
      for (final Row x in db.select(
        'SELECT r.direction, r.origin_code, r.decision_id, d.recomputed_from, d.target_json, d.chain_hash '
        "FROM ledger_repair r JOIN ledger_repair_detail d ON d.repair_id = r.repair_id WHERE r.direction = 'DERIVED_RESYNC'",
      ))
        <String, Object?>{for (final String k in x.keys) k: x[k]},
    ];

    List<String> diffs() => <String>[
      for (final Row x in db.select(
        "SELECT pair, status FROM ledger_diff WHERE axis = 'CHAIN_HASH' ORDER BY diff_id",
      ))
        '${x['pair']}:${x['status']}',
    ];

    String? syncStatus() {
      final ResultSet r = db.select(
        "SELECT status FROM sync_state WHERE target = 'SUPABASE'",
      );
      return r.isEmpty ? null : r.single['status'] as String;
    }

    test('하루 상한 1 미만 = 오류 · 리스 없음(기기 id · epoch 0) = 읽기 · 호출 0', () async {
      expect(
        () => job(_Reader(const LedgerStampRead.ok(null)), _Pusher(), cap: 0),
        throwsArgumentError,
      );
      final _Reader r = _Reader(const LedgerStampRead.ok(null));
      final _Pusher p = _Pusher();
      for (final (String?, int) l in <(String?, int)>[
        (null, 4),
        ('', 4),
        ('dev-a', 0),
      ]) {
        final SupabaseStampReport rep = await runOnce(
          r,
          p,
          device: l.$1,
          e: l.$2,
        );
        expect(rep.noLease, isTrue);
      }
      expect((r.calls.length, p.calls.length, leaseAsks), (0, 0, 0));
    });

    test('③ EMPTY = 처음부터 날 오름차순 · 열 셋 · 정정 행 0 · 🔴 epoch = 리스 epoch · BEHIND = 다음 날부터', () async {
      final _Pusher p = _Pusher();
      final SupabaseStampReport a = await runOnce(
        _Reader(const LedgerStampRead.ok(null)),
        p,
      );
      expect(a.relation, DerivedRelation.empty);
      expect(a.pushedDays, <String>['2026-11-02', '2026-11-03', '2026-11-04']);
      expect(p.calls.single.$1, 'ledger_stamp');
      expect(p.calls.single.$2, epoch);
      expect(p.calls.single.$3, <Map<String, Object?>>[
        for (final StoredDayStamp s in canon)
          <String, Object?>{
            'mode': 'LIVE',
            'authored_date': s.authoredDate,
            'chain_hash': s.chainHash,
          },
      ]);
      expect(repairs(), isEmpty);
      expect(diffs(), isEmpty, reason: 'EMPTY · BEHIND = 일상 이어 쓰기(관측 diff 0)');
      expect(a.alerts, isEmpty);
      final _Pusher q = _Pusher();
      final SupabaseStampReport b = await runOnce(
        _Reader(LedgerStampRead.ok(remote('2026-11-02'))),
        q,
      );
      expect(b.relation, DerivedRelation.behind);
      expect(b.pushedDays, <String>['2026-11-03', '2026-11-04']);
      expect(b.toString(), isNot(contains(canon.last.chainHash)));
    });

    test(
      '③ IN_SYNC = 리스 묻지 않음 · 호출 0 · ④ 리스 유효 아님 = 미룸(LEASE_NOT_VALID) · 호출 0',
      () async {
        final _Pusher p = _Pusher();
        final SupabaseStampReport a = await runOnce(
          _Reader(LedgerStampRead.ok(remote('2026-11-04'))),
          p,
        );
        expect((a.relation, a.hold), (DerivedRelation.inSync, null));
        expect(a.pushedDays, isEmpty);
        expect((leaseAsks, p.calls.length), (0, 0));
        for (final LeaseVerdict v in <LeaseVerdict>[
          LeaseVerdict.unknown,
          LeaseVerdict.invalid,
        ]) {
          final SupabaseStampReport b = await runOnce(
            _Reader(LedgerStampRead.ok(remote('2026-11-02'))),
            p,
            lease: v,
          );
          expect(
            (b.relation, b.hold),
            (DerivedRelation.behind, DerivedHoldReason.leaseNotValid),
          );
        }
        expect(p.calls, isEmpty);
        expect(leaseAsks, 2);
      },
    );

    test('🔴 ④ REBASED = 관측 diff → 기준점부터 다시 씀(같은 날 덮음) → 정정 행 LEDGER_STAMPS · diff 해소 · 다시 돌려도 한 행', () async {
      baseline('2026-11-03');
      final DerivedStamp old = remote('2026-11-04', chain: 'cd' * 32);
      final _Pusher p = _Pusher();
      final SupabaseStampReport a = await runOnce(
        _Reader(LedgerStampRead.ok(old)),
        p,
      );
      expect(a.relation, DerivedRelation.rebased);
      expect(a.pushedDays, <String>['2026-11-03', '2026-11-04']);
      expect(
        p.calls.single.$3.map((m) => m['authored_date']).toList(),
        <String>['2026-11-03', '2026-11-04'],
      );
      final List<Map<String, Object?>> rs = repairs();
      expect(rs, hasLength(1));
      expect(
        (
          rs.single['origin_code'],
          rs.single['decision_id'],
          rs.single['recomputed_from'],
          rs.single['chain_hash'],
        ),
        ('CHAIN_BROKEN', null, '2026-11-03', canon.last.chainHash),
      );
      expect(jsonDecode(rs.single['target_json']! as String), <String, Object?>{
        'kind': 'LEDGER_STAMPS',
        'count': 2,
      });
      expect(
        a.resync!.repairId,
        archiveResyncRepairIdOf(
          DerivedTarget.supabase,
          '2026-11-03',
          canon.last.chainHash,
        ),
      );
      expect(diffs(), <String>['CANON_SUPABASE:RESOLVED']);
      expect(
        SqliteDerivedSyncStore(db)
            .resyncsOn(DerivedTarget.supabase, '2026-11-05'),
        1,
      );
      expect(
        SqliteDerivedSyncStore(db)
            .resyncsOn(DerivedTarget.github, '2026-11-05'),
        0,
        reason: '대상마다 센다',
      );
      expect(syncStatus(), isNull, reason: 'FORK 가 아니면 sync_state 쓰기 0');
      await runOnce(_Reader(LedgerStampRead.ok(old)), _Pusher());
      expect(repairs(), hasLength(1), reason: '같은 첫 날 · 체인 = 같은 id');
      // 정정 이력 표시 = 엔진 문장.
      final Row s = db
          .select(
            "SELECT * FROM ledger_repair r JOIN ledger_repair_detail d ON d.repair_id = r.repair_id WHERE r.direction = 'DERIVED_RESYNC'",
          )
          .single;
      expect(
        repairLabelOf(
          StoredLedgerRepair(
            repairId: s['repair_id'] as String,
            diffId: s['diff_id'] as String,
            direction: s['direction'] as String,
            originCode: s['origin_code'] as String,
            evidenceHash: s['evidence_hash'] as String,
            appliedAtUtc: DateTime.parse(s['applied_at'] as String),
            chainHash: s['chain_hash'] as String,
            targetJson: s['target_json'] as String,
            decisionId: null,
            supersedes: null,
            recomputedFrom: s['recomputed_from'] as String?,
          ),
        ),
        '원격 사본에 스탬프 2일을 다시 보냈습니다 · 2026-11-03부터 재계산',
      );
    });

    test('④ REBASED — 리스 아님 · 하루 상한 = 미룸(diff 열린 채 · 정정 행 0) · push 실패 · 부분 성공 = 정정 행 0', () async {
      baseline('2026-11-03');
      final _Reader r = _Reader(
        LedgerStampRead.ok(remote('2026-11-04', chain: 'cd' * 32)),
      );
      final _Pusher p = _Pusher();
      final SupabaseStampReport a = await runOnce(
        r,
        p,
        lease: LeaseVerdict.unknown,
      );
      expect(
        (a.relation, a.hold),
        (DerivedRelation.rebased, DerivedHoldReason.leaseNotValid),
      );
      expect(diffs(), <String>['CANON_SUPABASE:OPEN']);
      final _Pusher bad = _Pusher(
        (int i) => const OpsPushResult.answered(
          code: 'OPS_PUSH_ROWS_INVALID',
          epoch: epoch,
          accepted: 0,
          skipped: 0,
        ),
      );
      final SupabaseStampReport b = await runOnce(r, bad);
      expect(
        (b.push!.outcome, b.push!.reason, b.resync),
        (OpsPushOutcome.failed, 'OPS_PUSH_ROWS_INVALID', null),
      );
      expect(b.pushedDays, isEmpty);
      expect(b.failed, hasLength(1));
      final _Pusher half = _Pusher(
        (int i) =>
            i == 1 ? const OpsPushResult.failed(OpsPushFailure.network) : null,
      );
      final SupabaseStampReport c = await runOnce(r, half, chunk: 1);
      expect(
        (c.push!.outcome, c.push!.accepted, c.resync),
        (OpsPushOutcome.lag, 1, null),
      );
      expect(c.pushedDays, isEmpty);
      expect(c.failed, isEmpty, reason: '망 = 경보 0');
      expect(
        half.calls.first.$3.single['authored_date'],
        '2026-11-03',
        reason: '앞쪽부터',
      );
      expect(repairs(), isEmpty);
      expect(diffs(), <String>['CANON_SUPABASE:OPEN']);
      // 상한 1 · 오늘 한 번 다시 씀 → 다음 REBASED = DAILY_CAP.
      await runOnce(r, _Pusher(), cap: 1);
      expect(repairs(), hasLength(1));
      final SupabaseStampReport d = await runOnce(
        _Reader(LedgerStampRead.ok(remote('2026-11-03', chain: 'ef' * 32))),
        _Pusher(),
        cap: 1,
      );
      expect(
        (d.relation, d.hold),
        (DerivedRelation.rebased, DerivedHoldReason.dailyCap),
      );
    });

    test('🔴 ⑤ FORK(EPOCH_AHEAD · AHEAD · DIVERGED) = sync_state FORK + P0 바뀐 때만 · 리스 칸 그대로 · 다음 번 = 망 0', () async {
      leaseRow();
      final _Pusher p = _Pusher();
      final _Reader ahead = _Reader(
        LedgerStampRead.ok(remote('2026-11-04', e: epoch + 1)),
      );
      final SupabaseStampReport a = await runOnce(ahead, p);
      expect(
        (a.skipped, a.relation, a.forkRaised),
        (SupabaseStampSkip.fork, DerivedRelation.epochAhead, true),
      );
      expect(a.alerts, <String>{AlertCodes.derivedFork});
      expect(syncStatus(), 'FORK');
      final Row lease = db
          .select(
            "SELECT operator_epoch, last_ok_at FROM sync_state WHERE target = 'SUPABASE'",
          )
          .single;
      expect(
        (lease['operator_epoch'], lease['last_ok_at']),
        (epoch, '2026-11-04T21:00:00.000Z'),
        reason: '리스 칸 = 리스 몫',
      );
      expect(diffs(), <String>['CANON_SUPABASE:OPEN']);
      final SupabaseStampReport b = await runOnce(ahead, p);
      expect((b.skipped, b.forkRaised), (SupabaseStampSkip.fork, false));
      expect(b.alerts, isEmpty);
      expect(
        (ahead.calls.length, p.calls.length, leaseAsks),
        (1, 0, 0),
        reason: '끈적 = 다음 번 망 0',
      );
      // 다른 원장 · 다른 FORK 꼴.
      for (final DerivedStamp s in <DerivedStamp>[
        DerivedStamp(
          authoredDate: '2026-11-05',
          chainHash: 'ab' * 32,
          operatorEpoch: epoch,
        ), // AHEAD
        DerivedStamp(
          authoredDate: '2026-11-03',
          chainHash: 'ab' * 32,
          operatorEpoch: epoch,
        ), // DIVERGED(기준점 0)
      ]) {
        db.execute("DELETE FROM sync_state WHERE target = 'SUPABASE'");
        final SupabaseStampReport c = await runOnce(
          _Reader(LedgerStampRead.ok(s)),
          p,
        );
        expect(
          (c.skipped, c.forkRaised, c.relation!.forks),
          (SupabaseStampSkip.fork, true, true),
        );
        expect(syncStatus(), 'FORK');
      }
      expect(p.calls, isEmpty);
    });

    test('② 무결성 깃발 · SEALED · 읽기 실패 = 건너뜀(망 0 · FORK 0) · 🔴 봉인 행을 FORK 로 덮지 않는다', () async {
      final _Pusher p = _Pusher();
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.ledgerIntegrity, '2026-11-04T00:00:00.000Z', 'x'],
      );
      final _Reader r = _Reader(const LedgerStampRead.ok(null));
      expect((await runOnce(r, p)).skipped, SupabaseStampSkip.integrity);
      db.execute(
        "UPDATE trading_block SET cleared_at = '2026-11-04T01:00:00.000Z'",
      );
      leaseRow(status: 'SEALED');
      expect((await runOnce(r, p)).skipped, SupabaseStampSkip.sealed);
      expect(r.calls, isEmpty);
      db.execute("UPDATE sync_state SET status = 'OK'");
      final SupabaseStampReport f = await runOnce(
        _Reader(const LedgerStampRead.failed(LedgerStampReadFailure.network)),
        p,
      );
      expect(
        (f.skipped, f.readFailure, f.relation, f.forkRaised),
        (SupabaseStampSkip.read, LedgerStampReadFailure.network, null, false),
      );
      expect(syncStatus(), 'OK');
      expect((p.calls.length, leaseAsks), (0, 0));
      // 봉인 뒤 FORK 기록 = 상태 그대로(SqliteDerivedSyncStore.recordFork 규칙).
      db.execute("UPDATE sync_state SET status = 'SEALED'");
      final DerivedView v = SqliteDerivedSyncStore(db)
          .supabaseView(remote('2026-11-04', e: 9), operatorEpoch: epoch);
      expect(
        SqliteDerivedSyncStore(db).recordFork(DerivedTarget.supabase, v, _t0),
        isFalse,
      );
      expect(syncStatus(), 'SEALED');
    });
  });
}
