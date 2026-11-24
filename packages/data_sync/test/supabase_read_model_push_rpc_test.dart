// 🆕 E11l2 — 읽기 모델 push RPC 본문(`rm_push`) 대조 시험(설계 13 §8 R254 · 01 §47 · 미결 222 ⓑ · 지도 X18).
//
// ① 원문 = sql/ 파일(바이트) ② 이름 · 인자 · 반환 = 계약 표 ③ 거부 글자 = 계약 사전(리스 공용 2 ∪ 고유 2) · 넷 다 쓴다
// ④ 표 목록 = 계약 `ReadModelTables` 차례 그대로 ⑤ 보안 꼴(security definer · search_path '' · 실행 = authenticated · 리스 잠금 공유)
// ⑥ 쓰기 꼴(덮는 칸 · row_version 승자 · 삭제 0 · 부분 반영 0) ⑦ 묶음 = 넷째 조각(rm_* 뒤 · commit 앞).
// 🔵 실제 Postgres 동작 = PGlite 하네스(tool/pglite/read_models_harness.mjs · CI 밖).

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show kSupabaseBatchDSql, kSupabaseLeaseRpcSql, kSupabaseReadModelPushRpcSql;
import 'package:domain_contracts/domain_contracts.dart'
    show
        LeaseRpcResultCodes,
        ReadModelPushResultCodes,
        ReadModelPushRpcColumns,
        ReadModelPushRpcNames,
        ReadModelPushRpcParams,
        ReadModelTable,
        ReadModelTables;
import 'package:test/test.dart';

/// 주석을 뺀 SQL.
final String _sql = kSupabaseReadModelPushRpcSql.replaceAll(
  RegExp(r'--[^\n]*'),
  '',
);

void main() {
  group('① 원문', () {
    test('사본 = sql/supabase_read_model_push_rpc.sql(바이트) — 다르면 tool/make_supabase_bootstrap.py', () {
      expect(
        kSupabaseReadModelPushRpcSql,
        File('sql/supabase_read_model_push_rpc.sql').readAsStringSync(),
      );
    });
  });

  group('② 계약 표', () {
    test('함수 = rm_push 하나 · 인자 차례 = 계약 4 · 반환 = 한 행 4', () {
      expect(
        RegExp(r'create or replace function public\.(\w+)\(')
            .allMatches(_sql)
            .map((RegExpMatch m) => m.group(1))
            .toSet(),
        ReadModelPushRpcNames.values,
        reason: '계약 밖 함수 0',
      );
      final RegExpMatch m = RegExp(
        r'create or replace function public\.rm_push\(([^)]*)\)',
      ).firstMatch(_sql)!;
      expect(
        m
            .group(1)!
            .split(',')
            .map((String p) => p.trim().split(' ').first)
            .toList(),
        <String>[
          ReadModelPushRpcParams.deviceId,
          ReadModelPushRpcParams.epoch,
          ReadModelPushRpcParams.table,
          ReadModelPushRpcParams.rows,
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
        ReadModelPushRpcColumns.values,
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
        ...ReadModelPushResultCodes.values,
      });
    });
  });

  group('④ 표 목록', () {
    test('array[…] = 계약 ReadModelTables 이름 · 차례 그대로', () {
      final RegExpMatch m = RegExp(r'p_table = any \(array\[([^\]]*)\]\)')
          .firstMatch(_sql)!;
      expect(
        RegExp(r"'(rm_\w+)'")
            .allMatches(m.group(1)!)
            .map((RegExpMatch x) => x.group(1))
            .toList(),
        ReadModelTables.all.map((ReadModelTable t) => t.name).toList(),
      );
    });
  });

  group('⑤ 보안 꼴', () {
    test(
      'security definer · search_path · 권한 · 리스 잠금 = 리스 RPC 와 같은 열쇠(공유)',
      () {
        expect(_sql, contains('security definer'));
        expect(_sql, contains("set search_path = ''"));
        expect(
          _sql,
          contains(
            'revoke all on function public.rm_push(text, bigint, text, jsonb) from public, anon;',
          ),
        );
        expect(
          _sql,
          contains(
            'grant execute on function public.rm_push(text, bigint, text, jsonb) to authenticated;',
          ),
        );
        final String key = RegExp(r'pg_advisory_xact_lock\((\d+)\)')
            .firstMatch(kSupabaseLeaseRpcSql)!
            .group(1)!;
        expect(_sql, contains('pg_advisory_xact_lock_shared($key)'));
        expect(_sql, contains("d.role = 'operator'"));
        expect(_sql, contains("d.status = 'ACTIVE'"));
        expect(_sql, isNot(contains('auth.jwt')));
      },
    );
  });

  group('⑥ 쓰기 꼴', () {
    test('lease_epoch = 인자 · pushed_at = now() · row_version 큰 쪽만 · 삭제 0 · 데이터 오류 = ROWS_INVALID', () {
      expect(_sql, contains("when 'lease_epoch' then '\$2'"));
      expect(_sql, contains("when 'pushed_at' then 'now()'"));
      expect(_sql, contains('where t.row_version < excluded.row_version'));
      expect(_sql, contains('using p_rows, p_epoch'));
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
    test('넷째 조각 = rm_* 뒤 · commit 앞 · 판에 들어간다', () {
      final String rm = supabaseReadModelsSql();
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble(
        readModelsSql: rm,
      );
      final String t = s.text;
      expect(
        t.indexOf(kSupabaseBatchDSql),
        lessThan(t.indexOf(kSupabaseLeaseRpcSql)),
      );
      expect(t.indexOf(kSupabaseLeaseRpcSql), lessThan(t.indexOf(rm)));
      expect(t.indexOf(rm), lessThan(t.indexOf(kSupabaseReadModelPushRpcSql)));
      expect(
        t.indexOf(kSupabaseReadModelPushRpcSql),
        lessThan(t.lastIndexOf('commit;')),
      );
      expect(
        'create or replace function public.rm_push('.allMatches(t),
        hasLength(1),
      );
      expect(
        SupabaseBootstrapSql.assemble().text,
        contains(kSupabaseReadModelPushRpcSql),
      );
    });
  });
}
