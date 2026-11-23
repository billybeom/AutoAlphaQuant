// 🆕 E11l1(설계 13 §8 R246) PGlite 하네스 — 부트스트랩 완성 판(배치 D + 리스 RPC + rm_* 22)을 Postgres 16(WASM)에 실제로 붙여 넣고 RLS 를 잰다.
// 🔵 CI 밖 로컬 도구(node + @electric-sql/pglite) — 생성기 · RLS 본문이 바뀌는 PR 에서 손으로 돌린다(R221 · v1.34 하네스를 잇는다).
// 쓰는 법:
//   1) 빈 폴더 <pg> 에서: npm init -y && npm install --ignore-scripts @electric-sql/pglite@0.5.15
//   2) packages/data_sync 에서: dart run tool/gen_supabase_read_models.dart --dump <out>   (bootstrap_full.sql · bootstrap_incomplete.sql)
//   3) node tool/pglite/read_models_harness.mjs <pg> <out>/bootstrap_full.sql <out>/bootstrap_incomplete.sql
// 🔵 Supabase 흉내 = auth.users · auth.uid()(= request.jwt.claim.sub) · 역할 anon · authenticated · public 표 기본 권한 ALL(= RLS 가 유일한 벽).
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const [pgDir, fullPath, incPath] = process.argv.slice(2);
const { PGlite } = await import(pathToFileURL(`${pgDir}/node_modules/@electric-sql/pglite/dist/index.js`).href);
const full = readFileSync(fullPath, 'utf8');
const incomplete = readFileSync(incPath, 'utf8');

let pass = 0, fail = 0;
const ok = (c, m) => { if (c) { pass++; } else { fail++; console.log('FAIL', m); } };
const throws = async (f, re, m) => { try { await f(); ok(false, m + ' (안 던짐)'); } catch (e) { ok(re.test(String(e.message)), `${m} — ${e.message}`); } };

// Supabase 흉내 — auth 스키마 · auth.uid() · 역할 둘 · 기본 권한(Supabase 는 public 표에 anon · authenticated 권한을 준다 = RLS 가 유일한 벽)
async function fresh() {
  const db = new PGlite();
  await db.exec(`
    create schema auth;
    create table auth.users (id uuid primary key);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    create role anon nologin; create role authenticated nologin;
    grant usage on schema public, auth to anon, authenticated;
    grant execute on function auth.uid() to anon, authenticated;
    alter default privileges in schema public grant all on tables to anon, authenticated;
  `);
  return db;
}

// ① 미완 판 = 첫 문장에서 멈춘다 · 아무것도 안 바뀐다
{
  const db = await fresh();
  await throws(() => db.exec(incomplete), /미완/, '미완 판 멈춤');
  await db.exec('rollback'); // SQL Editor = 실패하면 되돌린다
  const r = await db.query(`select count(*)::int n from pg_tables where schemaname='public'`);
  ok(r.rows[0].n === 0, '미완 판 뒤 표 0');
}

const db = await fresh();
await db.exec(full);
const U = { op: '11111111-1111-1111-1111-111111111111', view: '22222222-2222-2222-2222-222222222222', none: '33333333-3333-3333-3333-333333333333', pend: '44444444-4444-4444-4444-444444444444', ret: '55555555-5555-5555-5555-555555555555' };

// ② 표 22 · RLS 켜짐 · 정책 = select 하나 · authenticated
const rmTables = (await db.query(`select c.relname n, c.relrowsecurity r from pg_class c join pg_namespace s on s.oid=c.relnamespace where s.nspname='public' and c.relkind='r' and c.relname like 'rm\\_%' order by 1`)).rows;
ok(rmTables.length === 22, `rm 표 22 (${rmTables.length})`);
ok(rmTables.every(t => t.r), 'rm 표 전부 RLS 켜짐');
const allPublic = (await db.query(`select c.relname n, c.relrowsecurity r from pg_class c join pg_namespace s on s.oid=c.relnamespace where s.nspname='public' and c.relkind='r'`)).rows;
ok(allPublic.every(t => t.r), `public 표 전부 RLS 켜짐(${allPublic.filter(t => !t.r).map(t => t.n).join(',')})`);
for (const t of rmTables) {
  const p = (await db.query(`select cmd, roles::text roles, qual from pg_policies where tablename=$1`, [t.n])).rows;
  ok(p.length === 1 && p[0].cmd === 'SELECT' && p[0].roles === '{authenticated}', `${t.n} 정책 = select 하나`);
  ok(/app_device/.test(p[0]?.qual ?? '') && /ACTIVE/.test(p[0]?.qual ?? ''), `${t.n} 정책 본문 = app_device ACTIVE`);
}

// 데이터 — 사용자 5 · 기기(운영 ACTIVE · 뷰어 ACTIVE · 뷰어 PENDING · 뷰어 RETIRED) · rm 표마다 한 행(키 + 5조만)
await db.exec(`insert into auth.users values ('${U.op}'),('${U.view}'),('${U.none}'),('${U.pend}'),('${U.ret}');
  insert into app_device(device_id,label,role,status,owner_uid,auth_uid) values
   ('d_op','폰','operator','ACTIVE','${U.op}','${U.op}'),
   ('d_v','랩탑','viewer','ACTIVE','${U.op}','${U.view}'),
   ('d_p','태블릿','viewer','PENDING','${U.op}','${U.pend}'),
   ('d_r','옛 폰','viewer','RETIRED','${U.op}','${U.ret}');`);
for (const t of rmTables) {
  const cols = (await db.query(`select column_name c, data_type d from information_schema.columns where table_name=$1 and is_nullable='NO' and column_default is null order by ordinal_position`, [t.n])).rows;
  const val = (c) => c.c === 'mode' ? `'LIVE'` : c.d === 'bigint' ? '1' : c.d === 'boolean' ? 'true' : `'k'`;
  await db.exec(`insert into ${t.n}(${cols.map(c => c.c).join(',')}) values (${cols.map(val).join(',')})`);
}

async function as(role, uid, f) {
  await db.exec(`set role ${role}; select set_config('request.jwt.claim.sub', '${uid ?? ''}', false);`);
  try { return await f(); } finally { await db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`); }
}

// ③ 읽기 — 운영 사용자 · ACTIVE 뷰어 = 1행 · 기기 없음 · PENDING · RETIRED · anon = 0행
for (const t of rmTables) {
  const n = async (role, uid) => (await as(role, uid, () => db.query(`select count(*)::int n from ${t.n}`))).rows[0].n;
  ok(await n('authenticated', U.op) === 1, `${t.n} 운영 사용자 = 1행`);
  ok(await n('authenticated', U.view) === 1, `${t.n} ACTIVE 뷰어 = 1행`);
  ok(await n('authenticated', U.none) === 0, `${t.n} 기기 없음 = 0행`);
  ok(await n('authenticated', U.pend) === 0, `${t.n} PENDING = 0행`);
  ok(await n('authenticated', U.ret) === 0, `${t.n} RETIRED = 0행`);
  ok(await n('anon', null) === 0, `${t.n} anon = 0행`);
}

// ④ 쓰기 — authenticated · anon INSERT = 거부 · UPDATE · DELETE = 0행(정책 0)
for (const t of rmTables) {
  for (const [role, uid] of [['authenticated', U.op], ['anon', null]]) {
    await throws(() => as(role, uid, () => db.exec(`insert into ${t.n}(row_version, lease_epoch, mode) values (2, 2, 'SIM_INTERNAL')`)), /row-level security|null value|violates/, `${t.n} ${role} INSERT 거부`);
    const u = await as(role, uid, () => db.query(`update ${t.n} set row_version = 9`));
    ok((u.affectedRows ?? 0) === 0, `${t.n} ${role} UPDATE 0행`);
    const d = await as(role, uid, () => db.query(`delete from ${t.n}`));
    ok((d.affectedRows ?? 0) === 0, `${t.n} ${role} DELETE 0행`);
  }
  const still = (await db.query(`select count(*)::int n, max(row_version)::int v from ${t.n}`)).rows[0];
  ok(still.n === 1 && still.v === 1, `${t.n} 행 그대로`);
}
// INSERT 거부가 NOT NULL 이 아니라 RLS 때문인지 — 키를 다 채워도 거부
await throws(() => as('authenticated', U.op, () => db.exec(`insert into rm_ops_summary(row_version, lease_epoch, mode) values (2, 2, 'SIM_INTERNAL')`)), /row-level security/, 'rm_ops_summary 키 다 채운 INSERT = RLS 거부');

// ⑤ 제약 — mode check · operating_mode check · 기본 키 · pushed_at 기본값
await throws(() => db.exec(`insert into rm_safety_state(row_version, lease_epoch, mode) values (1,1,'PAPER')`), /check/, 'mode check');
await throws(() => db.exec(`insert into rm_config_view(row_version, lease_epoch, mode, operating_mode) values (1,1,'SIM_BROKER','FOO')`), /check/, 'operating_mode check');
await throws(() => db.exec(`insert into rm_safety_state(row_version, lease_epoch, mode) values (1,1,'LIVE')`), /duplicate key|unique/, '기본 키 (mode)');
const pa = (await db.query(`select pushed_at is not null x from rm_safety_state`)).rows[0];
ok(pa.x, 'pushed_at default now()');
await db.exec(`insert into rm_config_view(row_version, lease_epoch, mode, operating_mode) values (1,1,'SIM_BROKER','ADVISORY')`);
ok(true, 'operating_mode ADVISORY 들어감');

// ⑥ 다시 붙여 넣기 = 가드가 멈춘다 · 아무것도 안 바뀐다
await throws(() => db.exec(full), /이미 적용된/, '두 번째 붙여 넣기 = 가드');
await db.exec('rollback');
const after = (await db.query(`select count(*)::int n from pg_tables where schemaname='public' and tablename like 'rm\\_%'`)).rows[0].n;
ok(after === 22, '가드 뒤 표 22 그대로');

console.log(`PGlite 하네스: ${pass} 통과 · ${fail} 실패`);
process.exit(fail ? 1 : 0);
