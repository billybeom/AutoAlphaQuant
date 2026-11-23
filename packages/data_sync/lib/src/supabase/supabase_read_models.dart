// 🆕 E11l1 — 읽기 모델 `rm_*` DDL + RLS 생성기(설계 13 §8 R246 · R230 L3 · L4 · 01 §6-4 · §45 · §8 미결 222 ⓐ · 06 M4-1 ①).
//
// 🔵 입력 = 계약 상수뿐 — `ReadModelTables`(표 · 키 · 열 · 형) · `ReadModelPushColumns`(규칙 5조 ①) · `ReadModelRls`(정책 본문).
//    이 파일은 표 · 열 · 형을 하나도 짓지 않는다(13 R230 L1 «문서에 없는 열을 지어내지 않는다»).
// 🔵 출력 = 부트스트랩 묶음 ③ 조각(`SupabaseBootstrapSql.assemble(readModelsSql:)`) · 골든 `packages/data_sync/sql/supabase_read_models.sql`
//    (바이트 대조 시험 · 다시 뽑기 = `dart run tool/gen_supabase_read_models.dart`).
// 🔴 표마다 `enable row level security` + select 전용 정책 하나(규칙 5조 ④ · G-10) — INSERT · UPDATE · DELETE 정책 · grant 0
//    (쓰기 = E11l2 push RPC 1창구 · 미결 222 ⓑ).
// 🔴 NOT NULL = 규칙 5조 4칸 + 키 열뿐(01 §45 K305) · check = `mode` + 상수가 준 값(`operating_mode`)뿐.
// 🔴 판 글자(`contractVersion`)를 싣지 않는다 — 표가 같으면 묶음 판(sha256)도 같다.

import 'package:domain_contracts/domain_contracts.dart'
    show
        ReadModelBinding,
        ReadModelColumn,
        ReadModelPushColumns,
        ReadModelRls,
        ReadModelTable,
        ReadModelTables;

/// 읽기 모델 22표 DDL + RLS 전문(결정적 · 같은 계약 = 같은 글자).
String supabaseReadModelsSql() {
  final StringBuffer b = StringBuffer()
    ..writeln(
      '-- 읽기 모델 rm_* ${ReadModelTables.all.length}표 — 계약 `ReadModelTables`(packages/domain_contracts/lib/src/schema/read_model_tables.dart)에서 생성.',
    )
    ..writeln(
      '-- 🔴 손으로 고치지 않는다 — 다시 뽑기 = packages/data_sync: dart run tool/gen_supabase_read_models.dart',
    )
    ..writeln(
      '-- 🔴 쓰기 정책 0(select 전용) — 쓰기 = operator 리스 epoch 를 검사하는 push RPC 1창구(E11l2).',
    );
  for (final ReadModelTable t in ReadModelTables.all) {
    b
      ..writeln()
      ..write(readModelTableSql(t));
  }
  return b.toString();
}

/// 표 하나의 DDL + RLS(차례 = 규칙 5조 4칸 → 상수 열 차례 → 기본 키).
String readModelTableSql(ReadModelTable t) {
  final Set<String> keys = t.keyColumns.toSet();
  final List<String> lines = <String>[
    for (final ReadModelColumn c in ReadModelPushColumns.all)
      _columnSql(
        c,
        notNull: true,
        defaultNow: c == ReadModelPushColumns.pushedAt,
      ),
    for (final ReadModelColumn c in t.columns)
      _columnSql(c, notNull: keys.contains(c.name)),
    'primary key (${t.keyColumns.join(', ')})',
  ];
  final String policy = ReadModelRls.selectPolicyName(t.name);
  final StringBuffer b = StringBuffer()
    ..writeln(
      '-- ${t.name} — 키 (${t.keyColumns.join(', ')})'
      '${t.bindings.isEmpty ? '' : ' · 결속 ${t.bindings.map(_bindingLabel).join(' + ')}'}',
    )
    ..writeln('create table if not exists ${t.name} (');
  for (int i = 0; i < lines.length; i++) {
    b.writeln('  ${lines[i]}${i == lines.length - 1 ? '' : ','}');
  }
  b
    ..writeln(');')
    ..writeln('alter table ${t.name} enable row level security;')
    ..writeln(
      'create policy $policy on ${t.name} for select to ${ReadModelRls.selectRole}',
    )
    ..writeln('  using (${ReadModelRls.selectUsing});');
  return b.toString();
}

String _columnSql(
  ReadModelColumn c, {
  required bool notNull,
  bool defaultNow = false,
}) {
  final StringBuffer b = StringBuffer('${c.name} ${c.type.sql}');
  if (notNull) b.write(' not null');
  if (defaultNow) b.write(' default now()');
  if (c.checkValues.isNotEmpty) {
    b.write(
      ' check (${c.name} in (${c.checkValues.map((String v) => "'$v'").join(', ')}))',
    );
  }
  return b.toString();
}

/// 결속 이름 글자(주석 한 줄 — 접두가 있으면 «DTO(접두_)»).
String _bindingLabel(ReadModelBinding b) =>
    b.prefix.isEmpty ? b.dto : '${b.dto}(${b.prefix})';
