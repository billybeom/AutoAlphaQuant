// 🆕 미결 244 ⓐ — op_push 클라이언트 · 한 표 보내기 · X2 미러 push 일 · 행 꼴 ↔ 배치 D 시험(설계 13 §8 R271 O1~O4 · 계약 v1.40 §49).
//
// ① 클라이언트 = 계약 인자 4 · 경로 rpc/op_push · 한 행 파싱 · 거부 4 = 그 코드 · 꼴 = badResponse · 401 새 토큰 한 번 · 5xx · 시크릿 관문(망 0) ·
//    연결 칸 없음 · 🔴 표 = OpsPushTables 밖 = 망 0 · ArgumentError
// ② 한 표 보내기 = 차례대로 나눠 · 빈 행 = 호출 0 · 첫 거부에서 멈춤 · 갈래(사람이 볼 실패 = OPS_PUSH_* · 시크릿 · 응답 꼴 / 그 밖 = LAG)
// ③ 🔴 행 꼴 ↔ 배치 D(바이트 사본) — 행 키 ⊆ 그 표 열 · not null ∧ 기본값 없음 ∧ 서버가 덮지 않는 칸 ⊆ 행 키(`resume_mode` 결함 꼴을 막는다)
// ④ 미러 push 일 = 리스 없음 0 · 계획 → 재개 회차 차례 · 리스 거부 = 뒤 표 notTried · 실패 = 그 표만.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show Market, frozenExchangeCalendar;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show kSupabaseBatchDSql;
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

// ── 클라이언트 받침 ─────────────────────────────────────────────────────────
final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
String _access(int n) => 'acc-${'A' * 10}-$n';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

class _Rig {
  _Rig()
    : vault = MemorySecretVault(<String, String>{
        'supabase.project_url': _url,
        'supabase.publishable_key': _pub,
        'supabase.refresh_token': 'ref-${'R' * 12}',
      });

  final MemorySecretVault vault;
  final List<http.Request> rpc = <http.Request>[];
  int tokenN = 0;
  late http.Response Function(int i) reply;

  late final http.Client net = MockClient((http.Request r) async {
    if (r.url.path.startsWith('/auth/')) {
      return http.Response(
        jsonEncode(<String, Object?>{
          'access_token': _access(++tokenN),
          'expires_in': 3600,
          'refresh_token': 'ref-${'R' * 12}-$tokenN',
          'user': <String, Object?>{'id': 'uid-1'},
        }),
        200,
      );
    }
    rpc.add(r);
    return reply(rpc.length - 1);
  });
  late final SupabaseOpsPush client = SupabaseOpsPush(
    net,
    vault,
    SupabaseAuth(net, vault, clock: _Clock(DateTime.utc(2026, 12, 8, 9))),
  );
}

http.Response _answer(Object? code, Object? epoch, Object? a, Object? s) =>
    http.Response(
      jsonEncode(<Object>[
        <String, Object?>{
          'code': code,
          'epoch': epoch,
          'accepted': a,
          'skipped': s,
        },
      ]),
      200,
    );

/// 대본대로 답하는 포트.
class _Pusher implements OpsPusher {
  _Pusher([this.script]);

  /// (표 · 몇 번째 호출) → 답 · 없음 = 성공(전부 받아들임).
  final OpsPushResult? Function(String table, int i)? script;
  final List<(String, List<Map<String, Object?>>)> calls =
      <(String, List<Map<String, Object?>>)>[];

  @override
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  }) async {
    calls.add((table, rows));
    return script?.call(table, calls.length - 1) ??
        OpsPushResult.answered(
          code: null,
          epoch: epoch,
          accepted: rows.length,
          skipped: 0,
        );
  }
}

// ── 배치 D 열 ─────────────────────────────────────────────────────────────────
/// 배치 D 사본에서 표 하나의 열 → (not null ∧ 기본값 없음).
Map<String, bool> _ddlColumns(String table) {
  final String sql = kSupabaseBatchDSql.replaceAll(RegExp(r'--[^\n]*'), '');
  final int at = sql.indexOf('create table if not exists $table (');
  expect(at, greaterThanOrEqualTo(0), reason: '배치 D 에 $table 없음');
  final int open = sql.indexOf('(', at);
  int depth = 0;
  int end = open;
  for (int i = open; i < sql.length; i++) {
    if (sql[i] == '(') depth++;
    if (sql[i] == ')') depth--;
    if (depth == 0) {
      end = i;
      break;
    }
  }
  final String body = sql.substring(open + 1, end);
  // 최상위 쉼표로 나눈다(check (... in (...)) 안 쉼표 = 건너뜀).
  final List<String> parts = <String>[];
  depth = 0;
  int from = 0;
  for (int i = 0; i < body.length; i++) {
    if (body[i] == '(') depth++;
    if (body[i] == ')') depth--;
    if (body[i] == ',' && depth == 0) {
      parts.add(body.substring(from, i));
      from = i + 1;
    }
  }
  parts.add(body.substring(from));
  final Map<String, bool> out = <String, bool>{};
  for (final String raw in parts) {
    final String p = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (p.isEmpty || p.startsWith('primary key')) continue;
    final String name = p.split(' ').first;
    final bool required =
        (p.contains('not null') || p.contains('primary key')) &&
        !p.contains(' default ');
    out[name] = required;
  }
  return out;
}

/// 서버가 덮는 칸(K356 — 행 값 무시).
const Set<String> _serverFilled = <String>{
  'lease_epoch',
  'operator_epoch',
  'acked_at',
  'updated_at',
  'stamped_at',
};

void _expectRowsFit(String table, List<Map<String, Object?>> rows) {
  final Map<String, bool> cols = _ddlColumns(table);
  final Set<String> need = <String>{
    for (final MapEntry<String, bool> e in cols.entries)
      if (e.value && !_serverFilled.contains(e.key)) e.key,
  };
  expect(rows, isNotEmpty, reason: '$table 행이 있어야 대조한다');
  for (final Map<String, Object?> r in rows) {
    expect(
      cols.keys.toSet().containsAll(r.keys),
      isTrue,
      reason: '$table 행 키 ⊆ 열: ${r.keys.toSet().difference(cols.keys.toSet())}',
    );
    expect(
      r.keys.toSet().containsAll(need),
      isTrue,
      reason: '$table 빠진 not null 칸: ${need.difference(r.keys.toSet())}',
    );
    for (final String k in need) {
      expect(r[k], isNotNull, reason: '$table.$k');
    }
  }
}

final DateTime _t0 = DateTime.utc(2026, 11, 13, 9);

void main() {
  group('① 클라이언트', () {
    test('인자 4 = 계약 · 성공 한 행 · 경로 rpc/op_push · 토큰 문자열 0', () async {
      final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 1, 2);
      final OpsPushResult r = await rig.client.push(
        deviceId: 'dev-a',
        epoch: 7,
        table: OpsPushTables.plannedWorkMirror,
        rows: const <Map<String, Object?>>[
          <String, Object?>{'work_id': 'PW-1'},
        ],
      );
      expect(r.ok, isTrue);
      expect((r.epoch, r.accepted, r.skipped), (7, 1, 2));
      expect(rig.rpc.single.url.path, '/rest/v1/rpc/${OpsPushRpcNames.push}');
      final Map<String, Object?> body =
          jsonDecode(rig.rpc.single.body) as Map<String, Object?>;
      expect(body.keys.toSet(), OpsPushRpcParams.values);
      expect(body[OpsPushRpcParams.table], 'planned_work_mirror');
      expect(body[OpsPushRpcParams.epoch], 7);
      expect(body[OpsPushRpcParams.deviceId], 'dev-a');
      expect(rig.rpc.single.headers['apikey'], _pub);
      expect(rig.rpc.single.headers['authorization'], startsWith('Bearer '));
      expect(r.toString(), isNot(contains('acc-')));
    });

    test('거부 4 = 그 코드 · 0/0 · 모르는 코드 · 꼴 = badResponse', () async {
      expect(kOpsPushCodes, <String>{
        'LEASE_LOST',
        'LEASE_DEVICE_NOT_ELIGIBLE',
        'OPS_PUSH_TABLE_UNKNOWN',
        'OPS_PUSH_ROWS_INVALID',
      });
      for (final String code in kOpsPushCodes) {
        final _Rig rig = _Rig()..reply = (int i) => _answer(code, 7, 0, 0);
        final OpsPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: OpsPushTables.ledgerStamp,
          rows: const <Map<String, Object?>>[],
        );
        expect((r.code, r.ok, r.failure), (code, false, null));
      }
      for (final http.Response bad in <http.Response>[
        _answer('READ_MODEL_ROWS_INVALID', 7, 0, 0), // 다른 RPC 의 글자
        _answer('LEASE_HELD_BY_OTHER', 7, 0, 0),
        _answer(null, null, 1, 0),
        _answer('LEASE_LOST', 7, 1, 0),
        _answer(null, 7, -1, 0),
        _answer(null, '7', 1, 0),
        http.Response('[]', 200),
        http.Response('[{},{}]', 200),
        http.Response('nope', 200),
      ]) {
        final _Rig rig = _Rig()..reply = (int i) => bad;
        final OpsPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: OpsPushTables.ledgerStamp,
          rows: const <Map<String, Object?>>[],
        );
        expect(r.failure, OpsPushFailure.badResponse, reason: bad.body);
      }
      // 객체 하나로 와도 받는다.
      final _Rig obj = _Rig()
        ..reply = (int i) => http.Response(
          jsonEncode(<String, Object?>{
            'code': null,
            'epoch': 3,
            'accepted': 0,
            'skipped': 0,
          }),
          200,
        );
      expect(
        (await obj.client.push(
          deviceId: 'd',
          epoch: 3,
          table: OpsPushTables.resumeRunMirror,
          rows: const <Map<String, Object?>>[],
        )).ok,
        isTrue,
      );
    });

    test('401 → 토큰 새로 받아 한 번 더 · 두 번 401 = unauthorized · 5xx = server · 404 = badResponse · 🔴 HTTP 로 코드 0', () async {
      final _Rig rig = _Rig()
        ..reply = (int i) =>
            i == 0 ? http.Response('', 401) : _answer(null, 7, 0, 1);
      final OpsPushResult r = await rig.client.push(
        deviceId: 'd',
        epoch: 7,
        table: OpsPushTables.resumeRunMirror,
        rows: const <Map<String, Object?>>[],
      );
      expect(r.ok, isTrue);
      expect(rig.rpc, hasLength(2));
      expect(
        rig.rpc.last.headers['authorization'],
        isNot(rig.rpc.first.headers['authorization']),
      );
      Future<OpsPushResult> one(http.Response res) async {
        final _Rig x = _Rig()..reply = (int i) => res;
        return x.client.push(
          deviceId: 'd',
          epoch: 7,
          table: OpsPushTables.resumeRunMirror,
          rows: const <Map<String, Object?>>[],
        );
      }

      final OpsPushResult u = await one(http.Response('', 403));
      expect(
        (u.failure, u.statusCode, u.code),
        (OpsPushFailure.unauthorized, 403, null),
      );
      final OpsPushResult s = await one(
        http.Response('{"code":"OPS_PUSH_ROWS_INVALID"}', 503),
      );
      expect((s.failure, s.code), (OpsPushFailure.server, null));
      final OpsPushResult n = await one(
        http.Response('{"code":"LEASE_LOST"}', 404),
      );
      expect((n.failure, n.code), (OpsPushFailure.badResponse, null));
    });

    test(
      '시크릿 관문 — 금고 값 · 토큰 꼴이 행에 있으면 망 0 · 찾은 수만 · 연결 칸 없음 = config',
      () async {
        final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
        final OpsPushResult r = await rig.client.push(
          deviceId: 'd',
          epoch: 7,
          table: OpsPushTables.resumeRunMirror,
          rows: <Map<String, Object?>>[
            <String, Object?>{'headline': '복사 실수 $_pub'},
          ],
        );
        expect(r.failure, OpsPushFailure.secretBlocked);
        expect(r.secretFindings, greaterThan(0));
        expect(rig.rpc, isEmpty);
        expect(r.toString(), isNot(contains(_pub)));
        final _Rig bearer = _Rig()..reply = (int i) => _answer(null, 7, 1, 0);
        expect(
          (await bearer.client.push(
            deviceId: 'd',
            epoch: 7,
            table: OpsPushTables.plannedWorkMirror,
            rows: <Map<String, Object?>>[
              <String, Object?>{'one_line': 'Bearer ${'x' * 30}'},
            ],
          )).failure,
          OpsPushFailure.secretBlocked,
        );
        expect(bearer.rpc, isEmpty);
        final _Rig empty = _Rig();
        await empty.vault.delete(SupabaseSecretIds.projectUrl);
        empty.reply = (int i) => _answer(null, 7, 1, 0);
        expect(
          (await empty.client.push(
            deviceId: 'd',
            epoch: 7,
            table: OpsPushTables.ledgerStamp,
            rows: const <Map<String, Object?>>[],
          )).failure,
          OpsPushFailure.config,
        );
        expect(empty.rpc, isEmpty);
      },
    );

    test(
      '🔴 표 = OpsPushTables 밖(rm_* · 모르는 이름) = 망 0 · ArgumentError',
      () async {
        for (final String t in <String>[
          'rm_alert',
          'app_device',
          'command_queue',
          '',
        ]) {
          final _Rig rig = _Rig()..reply = (int i) => _answer(null, 7, 0, 0);
          await expectLater(
            rig.client.push(
              deviceId: 'd',
              epoch: 7,
              table: t,
              rows: const <Map<String, Object?>>[],
            ),
            throwsArgumentError,
          );
          expect(rig.rpc, isEmpty);
        }
      },
    );
  });

  group('② 한 표 보내기', () {
    List<Map<String, Object?>> rows(int n) => <Map<String, Object?>>[
      for (int i = 0; i < n; i++) <String, Object?>{'i': i},
    ];

    test('차례대로 나눠 · 합 · 빈 행 = 호출 0 · OK · 나눔 1 미만 = 오류', () async {
      final _Pusher p = _Pusher();
      final OpsTablePush r = await sendOpsRows(
        p,
        deviceId: 'd',
        epoch: 2,
        table: OpsPushTables.ledgerStamp,
        rows: rows(5),
        chunk: 2,
      );
      expect(
        (r.outcome, r.rows, r.accepted, r.skipped),
        (OpsPushOutcome.ok, 5, 5, 0),
      );
      expect(
        p.calls.map((c) => c.$2.map((m) => m['i']).toList()).toList(),
        <List<Object?>>[
          <Object?>[0, 1],
          <Object?>[2, 3],
          <Object?>[4],
        ],
      );
      final _Pusher none = _Pusher();
      final OpsTablePush e = await sendOpsRows(
        none,
        deviceId: 'd',
        epoch: 2,
        table: OpsPushTables.ledgerStamp,
        rows: const <Map<String, Object?>>[],
      );
      expect((e.outcome, none.calls.length), (OpsPushOutcome.ok, 0));
      expect(kOpsPushChunk, 200);
      await expectLater(
        sendOpsRows(
          none,
          deviceId: 'd',
          epoch: 2,
          table: OpsPushTables.ledgerStamp,
          rows: rows(1),
          chunk: 0,
        ),
        throwsArgumentError,
      );
    });

    test('첫 거부에서 멈춤(앞 묶음 합은 남김) · 갈래 = 사람이 볼 실패 / LAG · 리스 거부 표식', () async {
      Future<OpsTablePush> at1(OpsPushResult second) => sendOpsRows(
        _Pusher((String t, int i) => i == 1 ? second : null),
        deviceId: 'd',
        epoch: 2,
        table: OpsPushTables.plannedWorkMirror,
        rows: rows(5),
        chunk: 2,
      );
      final Map<OpsPushResult, (OpsPushOutcome, String, bool)> want =
          <OpsPushResult, (OpsPushOutcome, String, bool)>{
            const OpsPushResult.answered(
              code: 'OPS_PUSH_ROWS_INVALID',
              epoch: 2,
              accepted: 0,
              skipped: 0,
            ): (
              OpsPushOutcome.failed,
              'OPS_PUSH_ROWS_INVALID',
              false,
            ),
            const OpsPushResult.answered(
              code: 'OPS_PUSH_TABLE_UNKNOWN',
              epoch: 2,
              accepted: 0,
              skipped: 0,
            ): (
              OpsPushOutcome.failed,
              'OPS_PUSH_TABLE_UNKNOWN',
              false,
            ),
            const OpsPushResult.failed(
              OpsPushFailure.secretBlocked,
              secretFindings: 1,
            ): (
              OpsPushOutcome.failed,
              'secretBlocked',
              false,
            ),
            const OpsPushResult.failed(OpsPushFailure.badResponse): (
              OpsPushOutcome.failed,
              'badResponse',
              false,
            ),
            const OpsPushResult.answered(
              code: 'LEASE_LOST',
              epoch: 3,
              accepted: 0,
              skipped: 0,
            ): (
              OpsPushOutcome.lag,
              'LEASE_LOST',
              true,
            ),
            const OpsPushResult.answered(
              code: 'LEASE_DEVICE_NOT_ELIGIBLE',
              epoch: null,
              accepted: 0,
              skipped: 0,
            ): (
              OpsPushOutcome.lag,
              'LEASE_DEVICE_NOT_ELIGIBLE',
              true,
            ),
            const OpsPushResult.failed(OpsPushFailure.network): (
              OpsPushOutcome.lag,
              'network',
              false,
            ),
            const OpsPushResult.failed(OpsPushFailure.server, statusCode: 503):
                (OpsPushOutcome.lag, 'server', false),
            const OpsPushResult.failed(OpsPushFailure.notSignedIn): (
              OpsPushOutcome.lag,
              'notSignedIn',
              false,
            ),
            const OpsPushResult.failed(OpsPushFailure.config): (
              OpsPushOutcome.lag,
              'config',
              false,
            ),
            const OpsPushResult.failed(
              OpsPushFailure.unauthorized,
              statusCode: 401,
            ): (
              OpsPushOutcome.lag,
              'unauthorized',
              false,
            ),
          };
      for (final MapEntry<OpsPushResult, (OpsPushOutcome, String, bool)> e
          in want.entries) {
        final OpsTablePush r = await at1(e.key);
        expect(
          (r.outcome, r.reason, r.leaseRejected, r.accepted, r.rows),
          (e.value.$1, e.value.$2, e.value.$3, 2, 5),
          reason: '${e.key}',
        );
      }
      expect(
        OpsPushFailure.values,
        hasLength(7),
        reason: '새 실패 갈래 = 위 표에 갈래를 정한다',
      );
    });
  });

  group('③ 행 꼴 ↔ 배치 D · ④ 미러 push 일', () {
    late Directory dir;
    late Database db;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aaq_opsp_');
      db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    });
    tearDown(() {
      db.close();
      dir.deleteSync(recursive: true);
    });

    SqliteResumeStatus status() =>
        SqliteResumeStatus(db, kr: frozenExchangeCalendar(Market.kr));

    void seed() {
      db.execute(
        'INSERT INTO planned_work (work_id, idempotency_key, kind, created_at, due_by, state, digest, one_line, row_version) '
        "VALUES ('PW-1', 'k1', 'SEASONAL_WINDOW', '2026-11-01T00:00:00.000Z', '2026-11-27', 'PLANNED', 'dg1', '한 줄 1', 3), "
        "('PW-2', 'k2', 'DEFER_COUNT', '2026-11-02T00:00:00.000Z', '2026-12-01', 'BLOCKED', 'dg2', '한 줄 2', 1)",
      );
      db.execute(
        'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
        "VALUES ('RR-1', '2026-11-12T00:00:00.000Z', NULL, 2, 'RECOVERY_DRY', 'R5', '{}', NULL), "
        "('RR-0', '2026-11-01T00:00:00.000Z', '2026-11-01T01:00:00.000Z', 0, 'NORMAL', 'R8', '{}', '머리말')",
      );
    }

    test('🔴 미러 2표 행 = 배치 D 열 · not null 칸 전부(resume_mode = 로컬 재개 모드 · mode = 실행 모드)', () {
      seed();
      final ResumeMirrorPayload p = status().mirrorPayload(
        mode: RunMode.simBroker,
        leaseEpoch: 4,
        remoteEpoch: null,
      );
      _expectRowsFit(OpsPushTables.plannedWorkMirror, p.plannedWork);
      _expectRowsFit(OpsPushTables.resumeRunMirror, p.resumeRuns);
      expect(
        <(Object?, Object?, Object?)>[
          for (final Map<String, Object?> r in p.resumeRuns)
            (r['resume_run_id'], r['mode'], r['resume_mode']),
        ],
        <(Object?, Object?, Object?)>[
          ('RR-0', 'SIM_BROKER', 'NORMAL'),
          ('RR-1', 'SIM_BROKER', 'RECOVERY_DRY'),
        ],
      );
      expect(_ddlColumns('resume_run_mirror')['resume_mode'], isTrue);
    });

    test('미러 push 일 — 리스 없음 = 호출 0 · 계획 → 재개 회차 차례 · 행 그대로', () async {
      seed();
      final _Pusher p = _Pusher();
      final OpsMirrorPushJob job = OpsMirrorPushJob(
        pusher: p,
        status: status(),
      );
      for (final (String?, int) lease in <(String?, int)>[
        (null, 4),
        ('', 4),
        ('dev-a', 0),
      ]) {
        final OpsPushReport r = await job.run(
          deviceId: lease.$1,
          epoch: lease.$2,
          mode: RunMode.live,
        );
        expect(r.noLease, isTrue);
        expect(r.tables, isEmpty);
      }
      expect(p.calls, isEmpty);
      final OpsPushReport r = await job.run(
        deviceId: 'dev-a',
        epoch: 4,
        mode: RunMode.live,
      );
      expect(r.noLease, isFalse);
      expect(r.failed, isEmpty);
      expect(p.calls.map((c) => c.$1).toList(), <String>[
        'planned_work_mirror',
        'resume_run_mirror',
      ]);
      expect(p.calls.first.$2.map((m) => m['work_id']).toList(), <String>[
        'PW-1',
        'PW-2',
      ]);
      expect(p.calls.last.$2.map((m) => m['resume_mode']).toList(), <String>[
        'NORMAL',
        'RECOVERY_DRY',
      ]);
      expect(
        r.tables.map((t) => (t.table, t.outcome, t.accepted)).toList(),
        <(String, OpsPushOutcome, int)>[
          ('planned_work_mirror', OpsPushOutcome.ok, 2),
          ('resume_run_mirror', OpsPushOutcome.ok, 2),
        ],
      );
      expect(r.toString(), isNot(contains('한 줄')));
    });

    test('미러 push 일 — 리스 거부 = 뒤 표 notTried · 행 틀림 = 그 표만 failed(뒤 표는 간다) · 빈 원장 = 호출 0', () async {
      seed();
      final _Pusher lost = _Pusher(
        (String t, int i) => const OpsPushResult.answered(
          code: 'LEASE_LOST',
          epoch: 9,
          accepted: 0,
          skipped: 0,
        ),
      );
      final OpsPushReport a = await OpsMirrorPushJob(
        pusher: lost,
        status: status(),
      ).run(deviceId: 'dev-a', epoch: 4, mode: RunMode.live);
      expect(a.tables.map((t) => t.outcome).toList(), <OpsPushOutcome>[
        OpsPushOutcome.lag,
        OpsPushOutcome.notTried,
      ]);
      expect(lost.calls, hasLength(1));
      expect(a.failed, isEmpty, reason: '리스 = 경보 0');
      final _Pusher bad = _Pusher(
        (String t, int i) => t == OpsPushTables.plannedWorkMirror
            ? const OpsPushResult.answered(
                code: 'OPS_PUSH_ROWS_INVALID',
                epoch: 4,
                accepted: 0,
                skipped: 0,
              )
            : null,
      );
      final OpsPushReport b = await OpsMirrorPushJob(
        pusher: bad,
        status: status(),
      ).run(deviceId: 'dev-a', epoch: 4, mode: RunMode.live);
      expect(
        b.failed.map((t) => (t.table, t.reason)).toList(),
        <(String, String?)>[('planned_work_mirror', 'OPS_PUSH_ROWS_INVALID')],
      );
      expect(bad.calls.map((c) => c.$1), contains('resume_run_mirror'));
      db.execute('DELETE FROM planned_work');
      db.execute('DELETE FROM resume_run');
      final _Pusher empty = _Pusher();
      final OpsPushReport c = await OpsMirrorPushJob(
        pusher: empty,
        status: status(),
      ).run(deviceId: 'dev-a', epoch: 4, mode: RunMode.live);
      expect(
        (
          empty.calls.length,
          c.tables.every((t) => t.outcome == OpsPushOutcome.ok),
        ),
        (0, true),
      );
    });
  });
}
