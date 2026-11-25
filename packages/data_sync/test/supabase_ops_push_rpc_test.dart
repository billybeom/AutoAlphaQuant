// 🆕 미결 229 — 운영 폰 공유 표 push RPC 본문(`op_push`) 대조 시험(계약 v1.40 · 설계 01 §49 · 13 §8 R270 · 01 §8 미결 229 · 222 ⓕ · 지도 X18).
//
// ① 원문 = sql/ 파일(바이트) ② 이름 · 인자 · 반환 = 계약 표 ③ 거부 글자 = 계약 사전(리스 공용 2 ∪ 고유 2) · 넷 다 쓴다
// ④ 표 목록 = 계약 `OpsPushTables` 차례 그대로 · rm_* 와 서로소 ⑤ 보안 꼴(security definer · search_path '' · 실행 = authenticated ·
// 리스 잠금 공유 · 동적 SQL 0) ⑥ 쓰기 꼴(덮는 칸 · 표마다 충돌 규칙 · 삭제 0 · 부분 반영 0) ⑦ 묶음 = 다섯째 조각(rm_push 뒤 · commit 앞).
// 🔵 실제 Postgres 동작 = PGlite 하네스(tool/pglite/read_models_harness.mjs ⑨ · CI 밖).

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show
        kSupabaseLeaseRpcSql,
        kSupabaseOpsPushRpcSql,
        kSupabaseReadModelPushRpcSql;
import 'package:domain_contracts/domain_contracts.dart'
    show
        LeaseRpcResultCodes,
        OpsPushResultCodes,
        OpsPushRpcColumns,
        OpsPushRpcNames,
        OpsPushRpcParams,
        OpsPushTables,
        ReadModelTable,
        ReadModelTables;
import 'package:test/test.dart';

/// 주석을 뺀 SQL.
final String _sql = kSupabaseOpsPushRpcSql.replaceAll(RegExp(r'--[^\n]*'), '');

/// 표 하나의 갈래(`p_table = '<표>' then` … 다음 `elsif` · `else` 앞).
String _branch(String table) {
  final int at = _sql.indexOf("p_table = '$table' then");
  if (at < 0) {
    // 마지막 표 = `else` 갈래.
    final int e = _sql.lastIndexOf('    else\n');
    return _sql.substring(e, _sql.indexOf('end if;', e));
  }
  final int end = _sql.indexOf(RegExp(r'\n    (elsif|else)\b'), at);
  return _sql.substring(at, end);
}

void main() {
  group('① 원문', () {
    test('사본 = sql/supabase_ops_push_rpc.sql(바이트) — 다르면 tool/make_supabase_bootstrap.py', () {
      expect(
        kSupabaseOpsPushRpcSql,
        File('sql/supabase_ops_push_rpc.sql').readAsStringSync(),
      );
    });
  });

  group('② 계약 표', () {
    test('함수 = op_push 하나 · 인자 차례 = 계약 4 · 반환 = 한 행 4', () {
      expect(
        RegExp(r'create or replace function public\.(\w+)\(')
            .allMatches(_sql)
            .map((RegExpMatch m) => m.group(1))
            .toSet(),
        OpsPushRpcNames.values,
        reason: '계약 밖 함수 0',
      );
      final RegExpMatch m = RegExp(
        'create or replace function public\\.${OpsPushRpcNames.push}\\(([^)]*)\\)',
      ).firstMatch(_sql)!;
      expect(
        m
            .group(1)!
            .split(',')
            .map((String p) => p.trim().split(' ').first)
            .toList(),
        <String>[
          OpsPushRpcParams.deviceId,
          OpsPushRpcParams.epoch,
          OpsPushRpcParams.table,
          OpsPushRpcParams.rows,
        ],
      );
      expect(
        m.group(1),
        'p_device_id text, p_epoch bigint, p_table text, p_rows jsonb',
      );
      final RegExpMatch r = RegExp(r'returns table \(([^)]*)\)')
          .firstMatch(_sql)!;
      expect(
        r
            .group(1)!
            .split(',')
            .map((String c) => c.trim().split(' ').first)
            .toSet(),
        OpsPushRpcColumns.values,
      );
    });
  });

  group('③ 거부 글자', () {
    test('돌려주는 코드 = 리스 공용 2 ∪ 고유 2 · 넷 다 쓴다 · 그 밖 0', () {
      final Set<String> used = RegExp(r"'([A-Z][A-Z_]+)'::text")
          .allMatches(_sql)
          .map((RegExpMatch m) => m.group(1)!)
          .toSet();
      expect(used, <String>{
        LeaseRpcResultCodes.deviceNotEligible,
        LeaseRpcResultCodes.lost,
        ...OpsPushResultCodes.values,
      });
      expect(_sql, isNot(contains('raise ')));
    });
  });

  group('④ 표 목록', () {
    test('array[…] = 계약 OpsPushTables 차례 그대로 · 갈래 = 표마다 하나 · rm_* 와 서로소', () {
      final RegExpMatch m = RegExp(r'p_table = any \(array\[([^\]]*)\]\)')
          .firstMatch(_sql)!;
      final List<String> listed = RegExp(r"'(\w+)'")
          .allMatches(m.group(1)!)
          .map((RegExpMatch x) => x.group(1)!)
          .toList();
      expect(listed, OpsPushTables.all);
      for (final String t in OpsPushTables.all) {
        expect(
          'insert into public.$t as t'.allMatches(_sql),
          hasLength(1),
          reason: t,
        );
      }
      expect(
        listed.toSet().intersection(
          ReadModelTables.all.map((ReadModelTable t) => t.name).toSet(),
        ),
        isEmpty,
      );
      // 배치 D 에 실제로 있는 표.
      for (final String t in OpsPushTables.all) {
        expect(
          File('../domain_contracts/ddl/batch_d_supabase.sql')
              .readAsStringSync(),
          contains('create table if not exists $t ('),
          reason: t,
        );
      }
    });
  });

  group('⑤ 보안 꼴', () {
    test('security definer · search_path · 권한 · 리스 잠금 공유 · 기기 판정 = rm_push 와 같은 글자 · 동적 SQL 0', () {
      expect(_sql, contains('security definer'));
      expect(_sql, contains("set search_path = ''"));
      expect(
        _sql,
        contains(
          'revoke all on function public.op_push(text, bigint, text, jsonb) from public, anon;',
        ),
      );
      expect(
        _sql,
        contains(
          'grant execute on function public.op_push(text, bigint, text, jsonb) to authenticated;',
        ),
      );
      final String key = RegExp(r'pg_advisory_xact_lock\((\d+)\)')
          .firstMatch(kSupabaseLeaseRpcSql)!
          .group(1)!;
      expect(_sql, contains('pg_advisory_xact_lock_shared($key)'));
      // 기기 · 리스 판정 = rm_push 와 같은 문장(한쪽만 고치면 갈라진다).
      String gate(String s) {
        final String c = s.replaceAll(RegExp(r'--[^\n]*'), '');
        return c.substring(
          c.indexOf('perform pg_advisory_xact_lock_shared'),
          c.indexOf('if p_table is null'),
        );
      }

      expect(gate(kSupabaseOpsPushRpcSql), gate(kSupabaseReadModelPushRpcSql));
      // 동적 SQL 0 — 표 이름 · 열은 이 파일에 글자로(rm_push 의 카탈로그 동적 SQL 과 다르다).
      expect(RegExp(r'\bexecute\s+(format|\x27)').hasMatch(_sql), isFalse);
      expect(_sql, isNot(contains('format(')));
      expect(_sql, isNot(contains('pg_catalog.pg_attribute')));
      expect(_sql, isNot(contains('auth.jwt')));
    });
  });

  group('⑥ 쓰기 꼴', () {
    test('덮는 칸 = 서버(epoch = 인자 · 시각 = now()) · 표마다 충돌 규칙 · 삭제 0 · 데이터 오류 = ROWS_INVALID', () {
      final String ack = _branch('command_ack');
      expect(ack, contains('on conflict (ack_id) do nothing'));
      expect(ack, isNot(contains('do update')));
      expect(ack, contains('q.owner_uid = v_uid'));
      expect(ack, contains('having count(*) > 1'));
      expect(ack, contains('r.decision_id, p_epoch, now()'));

      final String pw = _branch('planned_work_mirror');
      expect(pw, contains('where t.row_version < excluded.row_version'));
      expect(pw, contains('r.row_version, p_epoch, now()'));

      final String rr = _branch('resume_run_mirror');
      expect(rr, contains('on conflict (resume_run_id) do update'));
      expect(rr, contains('r.headline, now()'));

      final String st = _branch('ledger_stamp');
      expect(st, contains('on conflict (mode, authored_date) do update'));
      expect(st, contains('r.chain_hash, p_epoch, now()'));
      expect(st, contains('operator_epoch = excluded.operator_epoch'));

      final String cs = _branch('calendar_sync_status');
      expect(cs, contains('on conflict (mode) do update'));
      expect(cs, contains('r.quarantined_count, now()'));

      // 행이 실은 epoch · 시각 칸은 읽지 않는다.
      for (final String c in <String>[
        'r.lease_epoch',
        'r.operator_epoch',
        'r.acked_at',
        'r.updated_at',
        'r.stamped_at',
      ]) {
        expect(_sql, isNot(contains(c)), reason: c);
      }
      expect(
        RegExp(r'\bdelete\b|\btruncate\b|\bdrop\b').hasMatch(_sql),
        isFalse,
      );
      expect(
        _sql,
        contains(
          'when data_exception or integrity_constraint_violation or cardinality_violation then',
        ),
      );
      expect(_sql, isNot(contains('when others')));
    });
  });

  group('⑦ 묶음', () {
    test('다섯째 조각 = rm_push 뒤 · commit 앞 · 판에 들어간다', () {
      final String rm = supabaseReadModelsSql();
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble(
        readModelsSql: rm,
      );
      final String t = s.text;
      expect(
        t.indexOf(kSupabaseReadModelPushRpcSql),
        lessThan(t.indexOf(kSupabaseOpsPushRpcSql)),
      );
      expect(
        t.indexOf(kSupabaseOpsPushRpcSql),
        lessThan(t.lastIndexOf('commit;')),
      );
      expect(
        'create or replace function public.op_push('.allMatches(t),
        hasLength(1),
      );
      expect(
        SupabaseBootstrapSql.assemble().text,
        contains(kSupabaseOpsPushRpcSql),
      );
    });
  });
}
