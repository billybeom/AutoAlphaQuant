// 🆕 E11l1 — 읽기 모델 rm_* DDL + RLS 생성기 시험(설계 13 §8 R246 · 01 §6-4 · §45 · 미결 222 ⓐ · 06 M4-1 ① 검증 게이트).
//
// ① 골든 = 생성기 출력(바이트) ② 표 = 계약 22 · 차례 ③ 열 = 규칙 5조 4칸 → 상수 열(형 · NOT NULL · check) · 기본 키
// ④ RLS = 표마다 켜짐 · select 정책 하나 · 쓰기 정책 · grant 0 · 본문 = 계약 ⑤ 결정적 · 판 글자 0 · 비밀 글자 0
// ⑥ 묶음 = 완성 판(가드 → 배치 D → 리스 RPC → rm_*) — 노출(o_07 ①)은 E11l2 뒤.

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show kSupabaseLeaseRpcSql;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ReadModelColumn,
        ReadModelPushColumns,
        ReadModelRls,
        ReadModelTable,
        ReadModelTables,
        contractVersion;
import 'package:test/test.dart';

final String _sql = supabaseReadModelsSql();

/// 표 하나의 조각(`-- <표> — 키` 머리부터 다음 머리 앞까지).
String _block(String table) {
  final int a = _sql.indexOf('-- $table — 키 (');
  expect(a, greaterThanOrEqualTo(0), reason: table);
  final int b = _sql.indexOf('\n-- rm_', a + 1);
  return _sql.substring(a, b < 0 ? _sql.length : b);
}

/// `create table` 괄호 안 줄(쉼표 뗌).
List<String> _bodyLines(String block) {
  final int a = block.indexOf('(\n') + 2;
  final int b = block.indexOf('\n);');
  return block
      .substring(a, b)
      .split('\n')
      .map((String l) => l.trim().replaceAll(RegExp(r',$'), ''))
      .toList();
}

void main() {
  group('① 골든', () {
    test('sql/supabase_read_models.sql = 생성기 출력(바이트) — 다르면 tool/gen_supabase_read_models.dart', () {
      final String golden = File('sql/supabase_read_models.sql')
          .readAsStringSync();
      expect(
        golden,
        _sql,
        reason: 'dart run tool/gen_supabase_read_models.dart 로 다시 뽑는다',
      );
    });
  });

  group('② 표', () {
    test('계약 22표 · 차례 그대로 · create table 22 · 표 밖 문장 0', () {
      final List<String> names = RegExp(
        r'^create table if not exists (\w+) \(',
        multiLine: true,
      ).allMatches(_sql).map((RegExpMatch m) => m.group(1)!).toList();
      expect(
        names,
        ReadModelTables.all.map((ReadModelTable t) => t.name).toList(),
      );
      expect(names, hasLength(22));
      final List<String> statements = RegExp(
        r'^(create|alter|drop|grant|revoke|insert|update|delete|do)\b',
        multiLine: true,
      ).allMatches(_sql).map((RegExpMatch m) => m.group(1)!).toList();
      expect(statements.toSet(), <String>{'create', 'alter'});
    });
  });

  group('③ 열', () {
    test('규칙 5조 4칸 → 상수 열 차례 · 형 · NOT NULL = 5조 + 키 · check · 기본 키', () {
      for (final ReadModelTable t in ReadModelTables.all) {
        final List<String> lines = _bodyLines(_block(t.name));
        final List<ReadModelColumn> cols = <ReadModelColumn>[
          ...ReadModelPushColumns.all,
          ...t.columns,
        ];
        expect(lines, hasLength(cols.length + 1), reason: t.name);
        for (int i = 0; i < cols.length; i++) {
          final ReadModelColumn c = cols[i];
          final bool push = i < ReadModelPushColumns.all.length;
          final bool notNull = push || t.keyColumns.contains(c.name);
          expect(
            lines[i],
            startsWith('${c.name} ${c.type.sql}'),
            reason: '${t.name}.${c.name}',
          );
          expect(
            lines[i].contains(' not null'),
            notNull,
            reason: '${t.name}.${c.name} NOT NULL',
          );
          expect(
            lines[i].contains('default now()'),
            c.name == 'pushed_at',
            reason: '${t.name}.${c.name}',
          );
          expect(
            lines[i].contains(' check ('),
            c.checkValues.isNotEmpty,
            reason: '${t.name}.${c.name}',
          );
        }
        expect(
          lines.last,
          'primary key (${t.keyColumns.join(', ')})',
          reason: t.name,
        );
        expect(
          lines[3],
          "mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER'))",
        );
      }
      expect(
        _block('rm_config_view'),
        contains(
          "operating_mode text check (operating_mode in ('AUTO_TRADE', 'ADVISORY'))",
        ),
      );
    });
  });

  group('④ RLS', () {
    test('표마다 켜짐 · select 정책 하나(본문 = 계약) · 쓰기 정책 · grant · using (true) 0', () {
      for (final ReadModelTable t in ReadModelTables.all) {
        final String block = _block(t.name);
        expect(
          block,
          contains('alter table ${t.name} enable row level security;'),
        );
        expect('create policy'.allMatches(block), hasLength(1), reason: t.name);
        expect(
          block,
          contains(
            'create policy ${ReadModelRls.selectPolicyName(t.name)} on ${t.name} for select to authenticated\n'
            '  using (${ReadModelRls.selectUsing});',
          ),
        );
      }
      expect('enable row level security'.allMatches(_sql), hasLength(22));
      expect('create policy'.allMatches(_sql), hasLength(22));
      expect(
        RegExp(r'for (insert|update|delete|all)\b').hasMatch(_sql),
        isFalse,
      );
      expect(_sql, isNot(contains('using (true)')));
      expect(_sql.toLowerCase(), isNot(contains('auth.jwt')));
      expect(_sql, isNot(contains('to anon')));
    });
  });

  group('⑤ 결정 · 글자', () {
    test('결정적 · 판 글자 0 · 주소 · 키 글자 0', () {
      expect(supabaseReadModelsSql(), _sql);
      expect(_sql, isNot(contains(contractVersion)));
      for (final String w in <String>[
        'supabase.co',
        'service_role',
        'http://',
        'https://',
        'apikey',
      ]) {
        expect(_sql, isNot(contains(w)), reason: w);
      }
    });
  });

  group('⑥ 묶음', () {
    test('생성기 출력 = ③ 조각 → 완성 판 · 차례 가드 → 배치 D → 리스 RPC → rm_*', () {
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble(
        readModelsSql: _sql,
      );
      expect(s.complete, isTrue);
      final String t = s.text;
      expect(t, isNot(contains(r'$incomplete$')));
      expect(t.indexOf(kSupabaseLeaseRpcSql), lessThan(t.indexOf(_sql)));
      expect(t.indexOf(_sql), lessThan(t.lastIndexOf('commit;')));
      expect('create table if not exists rm_'.allMatches(t), hasLength(22));
      expect(s.edition, isNot(SupabaseBootstrapSql.assemble().edition));
    });
  });
}
