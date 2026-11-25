// 🆕 미결 246 — 뷰어 페어링 RPC · 명령 표 읽는 함수 본문 대조 시험(계약 v1.41 · 설계 01 §50 · 13 §8 R272 Y1~Y4 · 01 §10-8 G-26 · 지도 X18).
//
// ① 원문 = sql/ 파일(바이트) ② 이름 · 인자 · 반환 = 계약 표 ③ 거부 글자 = 계약 사전(함수마다) ④ 보안 꼴(쓰는 셋 definer · 읽는 둘 invoker ·
// search_path '' · 실행 = authenticated · 리스 잠금 공유 · 기기 · 리스 판정 = op_push 와 같은 글자 · 동적 SQL 0) ⑤ 상한 = 계약 상수
// ⑥ 판정 꼴(클레임 · 폐기 · 당김 · 상태 — 서버 판정 상태 글자 0) ⑦ 묶음 = 여섯째 조각(op_push 뒤 · commit 앞) ⑧ op_push = 리스 없는 ack 2상태 거부.
// 🔵 실제 Postgres 동작 = PGlite 하네스(tool/pglite/read_models_harness.mjs ⑩ · CI 밖).

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show
        kSupabaseCommandPairingRpcSql,
        kSupabaseLeaseRpcSql,
        kSupabaseOpsPushRpcSql;
import 'package:domain_contracts/domain_contracts.dart'
    show
        CommandOpenColumns,
        CommandReadLimits,
        CommandReadRpcNames,
        CommandReadRpcParams,
        CommandState,
        CommandStateMachine,
        CommandStatusColumns,
        CommandStatusText,
        LeaseRpcResultCodes,
        PairingRpcColumns,
        PairingRpcNames,
        PairingRpcParams,
        PairingRpcResultCodes,
        PairingTicketLimits;
import 'package:test/test.dart';

/// 주석을 뺀 SQL.
String _code(String s) => s.replaceAll(RegExp(r'--[^\n]*'), '');

final String _sql = _code(kSupabaseCommandPairingRpcSql);

/// 함수 하나의 본문(`create or replace function public.<이름>(` … 다음 `$fn$;`).
String _fn(String name) {
  final int at = _sql.indexOf('create or replace function public.$name(');
  expect(at, greaterThanOrEqualTo(0), reason: name);
  return _sql.substring(at, _sql.indexOf(r'$fn$;', at));
}

/// 인자 이름 차례.
List<String> _params(String name) =>
    RegExp('create or replace function public\\.$name\\(([^)]*)\\)')
        .firstMatch(_sql)!
        .group(1)!
        .split(',')
        .map((String p) => p.trim().split(' ').first)
        .toList();

/// 반환 칸 이름 차례(`returns table (…)`).
List<String> _returns(String name) =>
    RegExp(r'returns table \(([^)]*)\)')
        .firstMatch(_fn(name))!
        .group(1)!
        .split(',')
        .map((String c) => c.trim().split(' ').first)
        .toList();

/// 거부 글자(`'…'::text`).
Set<String> _codes(String body) =>
    RegExp(r"'([A-Z][A-Z_]+)'::text")
        .allMatches(body)
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();

/// 기기 판정 문장 · 리스 판정 문장(op_push 와 같은 글자여야 한다).
List<String> _gate(String body) => <String>[
  RegExp(r'perform pg_advisory_xact_lock_shared\(\d+\);')
      .firstMatch(body)!
      .group(0)!,
  RegExp(
    r'perform 1\s+from public\.app_device d\s+where d\.device_id = p_device_id[^;]*;',
  ).firstMatch(body)!.group(0)!,
  RegExp(
    r'select l\.epoch into v_epoch\s+from public\.operator_lease l\s+where l\.id = 1[^;]*;',
  ).firstMatch(body)!.group(0)!,
];

void main() {
  group('① 원문', () {
    test('사본 = sql/supabase_command_pairing_rpc.sql(바이트) — 다르면 tool/make_supabase_bootstrap.py', () {
      expect(
        kSupabaseCommandPairingRpcSql,
        File('sql/supabase_command_pairing_rpc.sql').readAsStringSync(),
      );
    });
  });

  group('② 계약 표', () {
    test('함수 = 페어링 3 ∪ 읽기 2 · 계약 밖 함수 0 · 인자 차례 = 계약 글자', () {
      expect(
        RegExp(r'create or replace function public\.(\w+)\(')
            .allMatches(_sql)
            .map((RegExpMatch m) => m.group(1))
            .toSet(),
        <String>{...PairingRpcNames.values, ...CommandReadRpcNames.values},
        reason: '계약 밖 함수 0(PostgREST 에 그대로 드러난다)',
      );
      expect(_params(PairingRpcNames.ticketIssue), <String>[
        PairingRpcParams.deviceId,
        PairingRpcParams.epoch,
        PairingRpcParams.ticketNonceHash,
        PairingRpcParams.ticketTtlMinutes,
      ]);
      expect(_params(PairingRpcNames.claim), <String>[
        PairingRpcParams.ticketNonce,
        PairingRpcParams.deviceId,
        PairingRpcParams.label,
        PairingRpcParams.platform,
      ]);
      expect(_params(PairingRpcNames.revoke), <String>[
        PairingRpcParams.deviceId,
        PairingRpcParams.epoch,
        PairingRpcParams.targetDeviceId,
      ]);
      expect(_params(CommandReadRpcNames.open), <String>[
        CommandReadRpcParams.limit,
      ]);
      expect(_params(CommandReadRpcNames.status), <String>[
        CommandReadRpcParams.commandIds,
      ]);
    });

    test('반환 — 쓰는 셋 = 리스 반환 글자 한 행 · command_open = command_queue 행 · command_status = 계약 6칸 차례', () {
      for (final String n in PairingRpcNames.values) {
        expect(_returns(n).toSet(), PairingRpcColumns.values, reason: n);
        expect(
          _fn(n),
          contains(
            'returns table (code text, epoch bigint, expires_at timestamptz)',
          ),
          reason: n,
        );
      }
      expect(
        _fn(CommandReadRpcNames.open),
        contains('returns setof public.command_queue'),
      );
      expect(_fn(CommandReadRpcNames.open), contains('select q.*'));
      expect(CommandOpenColumns.all.first, 'command_id');
      expect(_returns(CommandReadRpcNames.status), CommandStatusColumns.all);
    });
  });

  group('③ 거부 글자', () {
    test('함수마다 = 계약 사전 · 전부 쓴다 · 그 밖 0 · 예외로 알리지 않는다', () {
      expect(_codes(_fn(PairingRpcNames.ticketIssue)), <String>{
        LeaseRpcResultCodes.deviceNotEligible,
        LeaseRpcResultCodes.lost,
        PairingRpcResultCodes.ticketInvalid,
      });
      expect(_codes(_fn(PairingRpcNames.claim)), PairingRpcResultCodes.values);
      expect(_codes(_fn(PairingRpcNames.revoke)), <String>{
        LeaseRpcResultCodes.deviceNotEligible,
        LeaseRpcResultCodes.lost,
        PairingRpcResultCodes.deviceNotEligible,
      });
      expect(_codes(_sql), <String>{
        LeaseRpcResultCodes.deviceNotEligible,
        LeaseRpcResultCodes.lost,
        ...PairingRpcResultCodes.values,
      });
      expect(_sql, isNot(contains('raise ')));
    });
  });

  group('④ 보안 꼴', () {
    test('쓰는 셋 = security definer · 읽는 둘 = security invoker · stable · search_path · 권한', () {
      for (final String n in PairingRpcNames.values) {
        expect(_fn(n), contains('security definer'), reason: n);
        expect(_fn(n), isNot(contains('security invoker')), reason: n);
      }
      for (final String n in CommandReadRpcNames.values) {
        expect(_fn(n), contains('security invoker'), reason: n);
        expect(_fn(n), contains('\nstable\n'), reason: n);
        expect(_fn(n), isNot(contains('security definer')), reason: n);
        expect(_fn(n), contains('language sql'), reason: n);
      }
      for (final String n in <String>{
        ...PairingRpcNames.values,
        ...CommandReadRpcNames.values,
      }) {
        expect(_fn(n), contains("set search_path = ''"), reason: n);
      }
      for (final String sig in <String>[
        'pairing_ticket_issue(text, bigint, text, int)',
        'pairing_claim(text, text, text, text)',
        'pairing_revoke(text, bigint, text)',
        'command_open(int)',
        'command_status(uuid[])',
      ]) {
        expect(
          _sql,
          contains('revoke all on function public.$sig from public, anon;'),
        );
        expect(
          _sql,
          contains('grant execute on function public.$sig to authenticated;'),
        );
      }
    });

    test(
      '발급 · 폐기 기기 · 리스 판정 = op_push 와 같은 글자 · 같은 잠금(공유) · 클레임 = 리스 판정 0',
      () {
        final String key = RegExp(r'pg_advisory_xact_lock\((\d+)\)')
            .firstMatch(kSupabaseLeaseRpcSql)!
            .group(1)!;
        final List<String> op = _gate(_code(kSupabaseOpsPushRpcSql));
        expect(op.first, 'perform pg_advisory_xact_lock_shared($key);');
        expect(_gate(_fn(PairingRpcNames.ticketIssue)), op);
        expect(_gate(_fn(PairingRpcNames.revoke)), op);
        expect(_fn(PairingRpcNames.claim), isNot(contains('operator_lease')));
        expect(_fn(PairingRpcNames.claim), isNot(contains('pg_advisory')));
      },
    );

    test('동적 SQL 0 · JWT 0 · 지우기 = 클레임의 티켓 하나뿐 · 읽는 둘 = 쓰기 0', () {
      expect(RegExp(r'\bexecute\s+(format|\x27)').hasMatch(_sql), isFalse);
      expect(_sql, isNot(contains('format(')));
      expect(_sql, isNot(contains('auth.jwt')));
      expect(RegExp(r'\btruncate\b|\bdrop\b').hasMatch(_sql), isFalse);
      expect(
        RegExp(r'\bdelete from ([\w.]+)')
            .allMatches(_sql)
            .map((RegExpMatch m) => m.group(1))
            .toList(),
        <String>['public.pairing_ticket'],
      );
      expect(
        _fn(PairingRpcNames.claim),
        contains(
          'delete from public.pairing_ticket t where t.owner_uid = v_owner;',
        ),
      );
      for (final String n in CommandReadRpcNames.values) {
        expect(
          RegExp(r'\b(insert|update|delete)\b').hasMatch(_fn(n)),
          isFalse,
          reason: n,
        );
      }
    });
  });

  group('⑤ 상한 = 계약 상수', () {
    test('티켓 수명 범위 · 해시 꼴 = 배치 D check · 당김 상한', () {
      expect(
        _fn(PairingRpcNames.ticketIssue),
        contains(
          'p_ticket_ttl_minutes < ${PairingTicketLimits.ttlMinutesMin} or p_ticket_ttl_minutes > ${PairingTicketLimits.ttlMinutesMax} then',
        ),
      );
      final String hashRe = RegExp(r"ticket_hash ~ '([^']+)'")
          .firstMatch(
            File('../domain_contracts/ddl/batch_d_supabase.sql')
                .readAsStringSync(),
          )!
          .group(1)!;
      expect(
        _fn(PairingRpcNames.ticketIssue),
        contains("p_ticket_nonce_hash !~ '$hashRe'"),
      );
      expect(
        _fn(CommandReadRpcNames.open),
        contains(
          'limit (case when p_limit is null or p_limit < 1 or p_limit > ${CommandReadLimits.openMax} then ${CommandReadLimits.openMax} else p_limit end);',
        ),
      );
    });
  });

  group('⑥ 판정 꼴', () {
    test('발급 = 소유자 한 행 바꿔 넣기 · 만료 = 서버 now() + 수명', () {
      final String f = _fn(PairingRpcNames.ticketIssue);
      expect(
        f,
        contains(
          'v_exp := now() + make_interval(mins => p_ticket_ttl_minutes);',
        ),
      );
      expect(f, contains('on conflict (owner_uid) do update'));
      expect(f, contains('return query select null::text, v_epoch, v_exp;'));
    });

    test('클레임 = 기기 행 0 · 해시 대조 · 낸 기기 operator ACTIVE · 소유자 ≠ 부른 사용자 · 만료 · 뷰어 ACTIVE 한 트랜잭션 · 티켓 행 잠금', () {
      final String f = _fn(PairingRpcNames.claim);
      expect(
        f,
        contains(
          'where d.auth_uid = v_uid\n       or d.device_id = p_device_id;',
        ),
      );
      expect(
        f,
        contains("encode(sha256(convert_to(p_ticket_nonce, 'UTF8')), 'hex')"),
      );
      expect(
        f,
        contains("and i.role = 'operator'\n     and i.status = 'ACTIVE'"),
      );
      expect(f, contains('for update of t;'));
      expect(f, contains('if v_owner = v_uid then'));
      expect(f, contains('if v_exp <= now() then'));
      expect(
        f,
        contains(
          "values (p_device_id, btrim(p_label), 'viewer', 'ACTIVE', p_platform, v_owner, v_uid);",
        ),
      );
      expect(f, contains('when unique_violation then'));
      expect(f, isNot(contains('when others')));
      // 차례: 기기 판정 → 티켓 → 소유자 → 만료 → 넣기 → 지움.
      final List<int> at = <int>[
        f.indexOf('or d.device_id = p_device_id'),
        f.indexOf('from public.pairing_ticket t'),
        f.indexOf('if v_owner = v_uid'),
        f.indexOf('if v_exp <= now()'),
        f.indexOf('insert into public.app_device'),
        f.indexOf('delete from public.pairing_ticket'),
      ];
      for (int i = 1; i < at.length; i++) {
        expect(at[i], greaterThan(at[i - 1]), reason: '차례 $i');
      }
    });

    test('폐기 = 같은 소유자 viewer 행만 → REVOKED · 이미 REVOKED = 바뀜 0', () {
      final String f = _fn(PairingRpcNames.revoke);
      expect(
        f,
        contains(
          "and d.owner_uid = v_uid\n     and d.role = 'viewer'\n     for update;",
        ),
      );
      expect(f, contains("if v_status <> 'REVOKED' then"));
      expect(f, contains("set status = 'REVOKED'"));
      expect(f, isNot(contains("role = 'operator'\n     for update")));
    });

    test('당김 = 종단 ack 없는 명령 · 킬스위치 먼저 · 종단 = 계약 상태기계 종단', () {
      final String f = _fn(CommandReadRpcNames.open);
      final Set<String> terminal = CommandStateMachine.terminal
          .map((CommandState s) => s.wire)
          .toSet();
      final String inList = RegExp(r'a\.state in \(([^)]*)\)')
          .firstMatch(f)!
          .group(1)!;
      expect(
        RegExp(r"'([A-Z_]+)'")
            .allMatches(inList)
            .map((RegExpMatch m) => m.group(1))
            .toSet(),
        terminal,
      );
      expect(
        f,
        contains(
          "order by (q.kind = 'KILL_SWITCH_ACTIVATE') desc, q.requested_at, q.command_id",
        ),
      );
    });

    test('상태 = 최신 ack · 종단 우선 · 유효 리스(서버 now()) 없음 = NO_OPERATOR · ack 없음 = REQUESTED · 서버 판정 글자 0', () {
      final String f = _fn(CommandReadRpcNames.status);
      expect(
        f,
        contains('from public.operator_lease l where l.expires_at > now()'),
      );
      expect(
        f,
        contains("when not v.live then '${CommandState.noOperator.wire}'"),
      );
      expect(
        f,
        contains("when a.ack_id is null then '${CommandState.requested.wire}'"),
      );
      expect(
        f,
        contains(
          "order by k.acked_at desc, (k.state in ('EXECUTED', 'REJECTED', 'EXPIRED')) desc, k.ack_id desc",
        ),
      );
      expect(
        f,
        contains('case when a.terminal or v.live then a.state_label end'),
      );
      expect(
        f,
        contains('order by array_position(p_command_ids, q.command_id)'),
      );
      // 🔴 G-26 ⓑ — 서버 판정 상태의 글자는 계약 카탈로그 하나(SQL 글자 0 · 한글 0).
      expect(
        kSupabaseCommandPairingRpcSql,
        isNot(contains(CommandStatusText.requested)),
      );
      expect(
        kSupabaseCommandPairingRpcSql,
        isNot(contains(CommandStatusText.noOperator)),
      );
      expect(RegExp('[가-힣]').hasMatch(_sql), isFalse);
    });
  });

  group('⑦ 묶음', () {
    test('여섯째 조각 = op_push 뒤 · commit 앞 · 판에 들어간다 · 함수 하나씩', () {
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble(
        readModelsSql: supabaseReadModelsSql(),
      );
      final String t = s.text;
      expect(
        t.indexOf(kSupabaseOpsPushRpcSql),
        lessThan(t.indexOf(kSupabaseCommandPairingRpcSql)),
      );
      expect(
        t.indexOf(kSupabaseCommandPairingRpcSql),
        lessThan(t.lastIndexOf('commit;')),
      );
      for (final String n in <String>{
        ...PairingRpcNames.values,
        ...CommandReadRpcNames.values,
      }) {
        expect(
          'create or replace function public.$n('.allMatches(t),
          hasLength(1),
          reason: n,
        );
      }
      expect(t, contains('6/6 뷰어 페어링 RPC'));
      expect(t, isNot(contains('/5 ')));
      expect(
        SupabaseBootstrapSql.assemble().text,
        contains(kSupabaseCommandPairingRpcSql),
      );
    });
  });

  group('⑧ op_push', () {
    test('ack = 리스 없는 상태 2(PENDING_LEASE_CONFIRM · NO_OPERATOR) 거부 — 리스 보유자가 적을 수 없다', () {
      final String op = _code(kSupabaseOpsPushRpcSql);
      expect(
        op,
        contains(
          "where r.state in ('${CommandState.pendingLeaseConfirm.wire}', '${CommandState.noOperator.wire}')",
        ),
      );
      final int at = op.indexOf("p_table = 'command_ack' then");
      final int rej = op.indexOf("where r.state in ('PENDING_LEASE_CONFIRM'");
      final int ins = op.indexOf('insert into public.command_ack as t');
      expect(at, lessThan(rej));
      expect(rej, lessThan(ins), reason: '거부 판정이 넣기 앞');
    });
  });
}
