// 🆕 E11l1(설계 13 §8 R246) · E11l2(R254) · 미결 229(R270) · 🆕 미결 246(R272) PGlite 하네스 — 부트스트랩 완성 판(배치 D + 리스 RPC + rm_* 22 + rm_push + op_push +
//    페어링 · 명령 표 읽기)을 Postgres 16(WASM)에 실제로 붙여 넣고 RLS 를 잰다.
// 🔵 CI 밖 로컬 도구(node + @electric-sql/pglite) — 생성기 · RLS 본문이 바뀌는 PR 에서 손으로 돌린다(R221 · v1.34 하네스를 잇는다).
// 쓰는 법:
//   1) 빈 폴더 <pg> 에서: npm init -y && npm install --ignore-scripts @electric-sql/pglite@0.5.15
//   2) packages/data_sync 에서: dart run tool/gen_supabase_read_models.dart --dump <out>   (bootstrap_full.sql · bootstrap_incomplete.sql)
//   3) node tool/pglite/read_models_harness.mjs <pg> <out>/bootstrap_full.sql <out>/bootstrap_incomplete.sql [<rows.json>]
//      넷째(선택) = 빌더 22표 행 — packages/data_sync 에서 AAQ_DUMP_ROWS=<rows.json> dart test test/read_model_push_test.dart(E11l2b · R256)
// 🔵 Supabase 흉내 = auth.users · auth.uid()(= request.jwt.claim.sub) · 역할 anon · authenticated · public 표 기본 권한 ALL(= RLS 가 유일한 벽).
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const [pgDir, fullPath, incPath, rowsPath] = process.argv.slice(2);
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

// ⑦ 🆕 E11l2(R254) rm_push — 리스 판정 · 표 판정 · row_version 승자 · 덮는 칸 · 전부 또는 0 · 22표 동적 SQL · 권한
{
  const push = async (uid, dev, epoch, table, rows, role = 'authenticated') =>
    (await as(role, uid, () => db.query(`select * from rm_push($1, $2, $3, $4::jsonb)`, [dev, epoch, table, JSON.stringify(rows)]))).rows[0];
  const lease = async (dev, epoch, mins) => db.exec(`delete from operator_lease; insert into operator_lease(id, device_id, epoch, expires_at) values (1, '${dev}', ${epoch}, now() + interval '${mins} minutes')`);
  await lease('d_op', 3, 30);
  const ops = (rv, extra = {}) => ({ row_version: rv, mode: 'SIM_INTERNAL', lease_epoch: 999, pushed_at: '2000-01-01T00:00:00Z', ...extra });

  let r = await push(U.op, 'd_op', 3, 'rm_ops_summary', [ops(5, { today_orders_text: 'a' })]);
  ok(r.code === null && r.epoch === 3 && r.accepted === 1 && r.skipped === 0, `push 성공 1행 (${JSON.stringify(r)})`);
  let row = (await db.query(`select row_version::int rv, lease_epoch::int le, pushed_at > now() - interval '1 minute' fresh, today_orders_text t from rm_ops_summary where mode='SIM_INTERNAL'`)).rows[0];
  ok(row.rv === 5 && row.le === 3 && row.fresh && row.t === 'a', `덮는 칸 lease_epoch = 인자 · pushed_at = now() (${JSON.stringify(row)})`);
  r = await push(U.op, 'd_op', 3, 'rm_ops_summary', [ops(5, { today_orders_text: 'b' })]);
  ok(r.code === null && r.accepted === 0 && r.skipped === 1, '같은 row_version = 건너뜀');
  r = await push(U.op, 'd_op', 3, 'rm_ops_summary', [ops(4, { today_orders_text: 'c' })]);
  ok(r.accepted === 0 && r.skipped === 1, '작은 row_version = 건너뜀');
  ok((await db.query(`select today_orders_text t from rm_ops_summary where mode='SIM_INTERNAL'`)).rows[0].t === 'a', '건너뛴 행 = 값 그대로');
  r = await push(U.op, 'd_op', 3, 'rm_ops_summary', [ops(6, { today_orders_text: 'd' })]);
  ok(r.accepted === 1 && (await db.query(`select today_orders_text t from rm_ops_summary where mode='SIM_INTERNAL'`)).rows[0].t === 'd', '큰 row_version = 바꿈');

  // 전부 또는 0 — 좋은 행 + 키 없는 행 = 0행
  r = await push(U.op, 'd_op', 3, 'rm_alert', [{ row_version: 1, mode: 'SIM_BROKER', alert_id: 'a1' }, { row_version: 1, mode: 'SIM_BROKER' }]);
  ok(r.code === 'READ_MODEL_ROWS_INVALID' && r.accepted === 0, '키 없는 행 섞임 = ROWS_INVALID');
  ok((await db.query(`select count(*)::int n from rm_alert where mode='SIM_BROKER'`)).rows[0].n === 0, '부분 반영 0');
  r = await push(U.op, 'd_op', 3, 'rm_alert', [{ row_version: 1, mode: 'PAPER', alert_id: 'a1' }]);
  ok(r.code === 'READ_MODEL_ROWS_INVALID', 'mode check 위반 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'rm_alert', [{ row_version: 'x', mode: 'LIVE', alert_id: 'a1' }]);
  ok(r.code === 'READ_MODEL_ROWS_INVALID', '형 위반 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'rm_alert', [{ row_version: 1, mode: 'SIM_BROKER', alert_id: 'a1' }, { row_version: 2, mode: 'SIM_BROKER', alert_id: 'a1' }]);
  ok(r.code === 'READ_MODEL_ROWS_INVALID', '같은 키 두 번 = ROWS_INVALID');
  r = (await as('authenticated', U.op, () => db.query(`select * from rm_push('d_op', 3, 'rm_alert', '{"a":1}'::jsonb)`))).rows[0];
  ok(r.code === 'READ_MODEL_ROWS_INVALID', '배열 아님 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'rm_alert', []);
  ok(r.code === null && r.accepted === 0 && r.skipped === 0, '빈 배열 = 0행 성공');

  // 표 · 리스 · 기기 판정
  r = await push(U.op, 'd_op', 3, 'app_device', [{}]);
  ok(r.code === 'READ_MODEL_TABLE_UNKNOWN' && r.epoch === 3, '목록 밖 표 = TABLE_UNKNOWN');
  r = await push(U.op, 'd_op', 3, 'rm_journal; drop table rm_alert', [{}]);
  ok(r.code === 'READ_MODEL_TABLE_UNKNOWN', '이름 끼워 넣기 = TABLE_UNKNOWN');
  r = await push(U.op, 'd_op', 2, 'rm_alert', [{ row_version: 1, mode: 'LIVE', alert_id: 'z' }]);
  ok(r.code === 'LEASE_LOST' && r.epoch === 3 && r.accepted === 0, 'epoch 다름 = LEASE_LOST(지금 epoch)');
  r = await push(U.view, 'd_v', 3, 'rm_alert', [{ row_version: 1, mode: 'LIVE', alert_id: 'z' }]);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '뷰어 기기 = NOT_ELIGIBLE');
  r = await push(U.view, 'd_op', 3, 'rm_alert', [{ row_version: 1, mode: 'LIVE', alert_id: 'z' }]);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '남의 기기 이름 = NOT_ELIGIBLE');
  r = await push(null, 'd_op', 3, 'rm_alert', []);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '로그인 0 = NOT_ELIGIBLE');
  await throws(() => push(null, 'd_op', 3, 'rm_alert', [], 'anon'), /permission denied/, 'anon 실행 권한 0');
  await lease('d_op', 3, -1);
  r = await push(U.op, 'd_op', 3, 'rm_alert', [{ row_version: 1, mode: 'LIVE', alert_id: 'z' }]);
  ok(r.code === 'LEASE_LOST', '만료 = LEASE_LOST');
  await lease('d_v', 4, 30);
  r = await push(U.op, 'd_op', 4, 'rm_alert', [{ row_version: 1, mode: 'LIVE', alert_id: 'z' }]);
  ok(r.code === 'LEASE_LOST' && r.epoch === 4, '리스가 다른 기기 = LEASE_LOST');
  ok((await db.query(`select count(*)::int n from rm_alert where alert_id='z'`)).rows[0].n === 0, '거부 = 0행');
  await lease('d_op', 5, 30);

  // 22표 전부 — 키 + 5조 칸만 실은 행 하나씩(동적 SQL · 복합 키) → 운영 · 뷰어 읽힘
  for (const t of rmTables) {
    const cols = (await db.query(`select column_name c, data_type d from information_schema.columns where table_name=$1 and is_nullable='NO' and column_default is null order by ordinal_position`, [t.n])).rows;
    const v = {};
    for (const c of cols) v[c.c] = c.c === 'mode' ? 'SIM_BROKER' : c.c === 'row_version' ? 7 : c.c === 'lease_epoch' ? 0 : c.d === 'bigint' ? 1 : c.d === 'boolean' ? true : 'p';
    r = await push(U.op, 'd_op', 5, t.n, [v]);
    ok(r.code === null && r.accepted === 1, `${t.n} push 1행 (${JSON.stringify(r)})`);
    const seen = (await as('authenticated', U.view, () => db.query(`select count(*)::int n from ${t.n} where mode='SIM_BROKER'`))).rows[0].n;
    ok(seen === 1, `${t.n} 뷰어가 push 행을 읽는다`);
  }
}

// ⑧ 🆕 E11l2b(R256) 빌더 행 끝에서 끝까지 — data_sync `readModelRow` 가 계약 표본 DTO 로 만든 22표 행을 rm_push 로 넣고
//    저장된 값 = 보낸 값(키 차례 무관 깊은 비교 · 덮는 칸 2 제외) · 뷰어가 읽는다. 넷째 인자(AAQ_DUMP_ROWS 출력)가 있을 때만.
if (rowsPath) {
  const sample = JSON.parse(readFileSync(rowsPath, 'utf8'));
  const deq = (a, b) => {
    if (a === b) return true;
    if (typeof a === 'number' && typeof b === 'number') return Math.abs(a - b) < 1e-12;
    if (a === null || b === null || typeof a !== 'object' || typeof b !== 'object') return false;
    if (Array.isArray(a) !== Array.isArray(b)) return false;
    if (Array.isArray(a)) return a.length === b.length && a.every((x, i) => deq(x, b[i]));
    const ka = Object.keys(a), kb = Object.keys(b);
    return ka.length === kb.length && ka.every(k => Object.prototype.hasOwnProperty.call(b, k) && deq(a[k], b[k]));
  };
  await db.exec(`delete from operator_lease; insert into operator_lease(id, device_id, epoch, expires_at) values (1, 'd_op', 9, now() + interval '30 minutes')`);
  ok(Object.keys(sample).length === 22, `빌더 표본 22표 (${Object.keys(sample).length})`);
  for (const [table, rows0] of Object.entries(sample)) {
    // 앞 절이 (mode) 키 표마다 LIVE · row_version 1 행을 넣어 두었다 — 같은 판이면 서버가 건너뛴다(정상) → 판을 올려 보낸다.
    const rows = rows0.map(x => ({ ...x, row_version: 100 }));
    const r = (await as('authenticated', U.op, () => db.query(`select * from rm_push('d_op', 9, $1, $2::jsonb)`, [table, JSON.stringify(rows)]))).rows[0];
    ok(r.code === null && r.accepted === rows.length, `${table} 빌더 행 push (${JSON.stringify(r)})`);
    const keys = (await db.query(`select a.attname k from pg_index i join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any(i.indkey) where i.indrelid = $1::regclass and i.indisprimary`, [table])).rows.map(x => x.k);
    for (const row of rows) {
      const where = keys.map((k, n) => `${k} = $${n + 1}`).join(' and ');
      const got = (await db.query(`select to_jsonb(t) j from ${table} t where ${where}`, keys.map(k => row[k]))).rows;
      ok(got.length === 1, `${table} 저장 행 하나`);
      const stored = got[0]?.j ?? {};
      const bad = Object.keys(row).filter(k => !deq(row[k], stored[k]));
      ok(bad.length === 0, `${table} 저장 값 = 보낸 값 (다름: ${bad.join(',')})`);
      ok(stored.lease_epoch === 9, `${table} lease_epoch = 인자`);
    }
    const seen = (await as('authenticated', U.view, () => db.query(`select count(*)::int n from ${table} where lease_epoch = 9`))).rows[0].n;
    ok(seen === rows.length, `${table} 뷰어가 빌더 행을 읽는다`);
  }
  // 🆕 미결 242(R275 · K339) 목록에서 빠진 행 = 같은 키 · 큰 판 · 차례 null 로 다시 보냄 → 서버 차례 null · 나머지 칸 그대로 ·
  //    뷰어 목록(`rank is not null`)에서 빠진다 · 옛 판 = 건너뜀(차례가 되살아나지 않는다).
  const alert0 = { ...sample.rm_alert[0], row_version: 100 };
  ok(alert0.inbox_rank === 1, `표본 알림 차례 1 (${alert0.inbox_rank})`);
  const listed = async () => (await as('authenticated', U.view, () => db.query(`select count(*)::int n from rm_alert where inbox_rank is not null`))).rows[0].n;
  ok(await listed() === 1, '빠지기 전 = 뷰어 목록 1행');
  const gone = { ...alert0, row_version: 101, inbox_rank: null };
  const r1 = (await as('authenticated', U.op, () => db.query(`select * from rm_push('d_op', 9, 'rm_alert', $1::jsonb)`, [JSON.stringify([gone])]))).rows[0];
  ok(r1.code === null && r1.accepted === 1, `빠진 행 다시 보냄 (${JSON.stringify(r1)})`);
  const st = (await db.query(`select to_jsonb(t) j from rm_alert t where mode = $1 and alert_id = $2`, [gone.mode, gone.alert_id])).rows[0].j;
  ok(st.inbox_rank === null && st.row_version === 101, `서버 차례 null · 판 101 (${st.inbox_rank} · ${st.row_version})`);
  ok(Object.keys(gone).filter(k => k !== 'inbox_rank' && !deq(gone[k], st[k])).length === 0, '나머지 칸 = 마지막으로 보낸 꼴 그대로');
  ok(await listed() === 0, '빠진 뒤 = 뷰어 목록 0행');
  const r2 = (await as('authenticated', U.op, () => db.query(`select * from rm_push('d_op', 9, 'rm_alert', $1::jsonb)`, [JSON.stringify([alert0])]))).rows[0];
  ok(r2.code === null && r2.accepted === 0 && r2.skipped === 1, `옛 판(차례 1) = 건너뜀 (${JSON.stringify(r2)})`);
  ok(await listed() === 0, '옛 판이 차례를 되살리지 않는다');
}

// ⑨ 🆕 미결 229(R270) op_push — rm_* 밖 쓰기 표 다섯(command_ack · 미러 2 · ledger_stamp · calendar_sync_status) ·
//    리스 판정(rm_push 와 같은 축) · 표마다 충돌 규칙 · 덮는 칸 · 전부 또는 0 · 직접 쓰기 0 · 222 ⓕ 읽기(K311 본문).
{
  const UX = '66666666-6666-6666-6666-666666666666';
  await db.exec(`insert into auth.users values ('${UX}');
    insert into app_device(device_id,label,role,status,owner_uid,auth_uid) values ('d_x','남의 폰','operator','ACTIVE','${UX}','${UX}');`);
  const push = async (uid, dev, epoch, table, rows, role = 'authenticated') =>
    (await as(role, uid, () => db.query(`select * from op_push($1, $2, $3, $4::jsonb)`, [dev, epoch, table, JSON.stringify(rows)]))).rows[0];
  const lease = async (dev, epoch, mins) => db.exec(`delete from operator_lease; insert into operator_lease(id, device_id, epoch, expires_at) values (1, '${dev}', ${epoch}, now() + interval '${mins} minutes')`);
  const q1 = async (s, p = []) => (await db.query(s, p)).rows[0];

  const C1 = 'aaaaaaaa-0000-0000-0000-000000000001', C2 = 'aaaaaaaa-0000-0000-0000-000000000002', CX = 'aaaaaaaa-0000-0000-0000-00000000000f';
  await db.exec(`insert into command_queue(command_id, kind, payload, issued_by_device, nonce, expires_at, owner_uid, run_mode, operating_mode, lease_epoch) values
    ('${C1}','KILL_SWITCH_ACTIVATE','{}','d_v','n1', now() + interval '1 hour','${U.op}','LIVE','AUTO_TRADE',3),
    ('${C2}','JOURNAL_DRAFT','{}','d_v','n2', now() - interval '1 hour','${U.op}','LIVE','AUTO_TRADE',3),
    ('${CX}','JOURNAL_DRAFT','{}','d_x','n3', now() + interval '1 hour','${UX}','LIVE','AUTO_TRADE',3);`);
  await lease('d_op', 3, 30);
  const ack = (id, cmd, state, extra = {}) => ({ ack_id: id, command_id: cmd, state, state_label: '받음', lease_epoch: 999, acked_at: '2000-01-01T00:00:00Z', ...extra });
  const A = (n) => `bbbbbbbb-0000-0000-0000-00000000000${n}`;

  // command_ack — append-only · 소유자 명령만 · 한 호출 같은 명령 두 번 = 거부
  let r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(1), C1, 'RECEIVED'), ack(A(2), C2, 'EXPIRED')]);
  ok(r.code === null && r.epoch === 3 && r.accepted === 2 && r.skipped === 0, `op ack 2행 (${JSON.stringify(r)})`);
  let row = await q1(`select lease_epoch::int le, acked_at > now() - interval '1 minute' fresh from command_ack where ack_id = $1`, [A(1)]);
  ok(row.le === 3 && row.fresh, `op ack 덮는 칸 lease_epoch = 인자 · acked_at = now() (${JSON.stringify(row)})`);
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(1), C1, 'EXECUTED')]);
  ok(r.code === null && r.accepted === 0 && r.skipped === 1, 'op ack 같은 ack_id = 건너뜀');
  ok((await q1(`select state from command_ack where ack_id = $1`, [A(1)])).state === 'RECEIVED', 'op ack 원래 행 그대로(append-only)');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(3), C1, 'EXECUTED')]);
  ok(r.code === null && r.accepted === 1, 'op ack 새 상태 = 새 행');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(4), CX, 'RECEIVED')]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID' && r.accepted === 0, 'op ack 남의 명령 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(5), 'aaaaaaaa-0000-0000-0000-0000000000ee', 'RECEIVED')]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack 없는 명령 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(6), C1, 'RECEIVED'), ack(A(7), C1, 'EXECUTED')]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack 한 호출 같은 명령 두 번 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(8), C2, 'DONE')]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack state check = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack(A(8), C2, 'REJECTED', { state_label: null })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack not null = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [ack('not-a-uuid', C2, 'REJECTED')]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack 형 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'command_ack', [{ ack_id: A(9) }]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op ack command_id 없음 = ROWS_INVALID');
  ok((await q1(`select count(*)::int n from command_ack`)).n === 3, 'op ack 거부 = 0행(3 그대로)');
  const nAck = async (uid) => (await as('authenticated', uid, () => db.query(`select count(*)::int n from command_ack`))).rows[0].n;
  ok(await nAck(U.view) === 3 && await nAck(U.pend) === 0 && await nAck(U.none) === 0, 'op ack 읽기 = ACTIVE 뷰어 3 · PENDING · 기기 없음 0');
  await throws(() => as('authenticated', U.op, () => db.exec(`insert into command_ack(ack_id, command_id, state, state_label, lease_epoch) values ('${A(9)}','${C1}','EXECUTED','x',3)`)), /row-level security/, 'op ack 직접 INSERT = RLS 거부');

  // planned_work_mirror — row_version 큰 쪽
  const pw = (rv, extra = {}) => ({ work_id: 'w1', mode: 'LIVE', digest: 'd'.repeat(64), one_line: '월말 리밸런싱', due_by: '2026-11-28', state: 'PLANNED', row_version: rv, lease_epoch: 999, updated_at: '2000-01-01T00:00:00Z', ...extra });
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(2)]);
  ok(r.code === null && r.accepted === 1, `op pw 1행 (${JSON.stringify(r)})`);
  row = await q1(`select lease_epoch::int le, updated_at > now() - interval '1 minute' fresh from planned_work_mirror`);
  ok(row.le === 3 && row.fresh, 'op pw 덮는 칸 lease_epoch · updated_at');
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(2, { state: 'DONE' })]);
  ok(r.accepted === 0 && r.skipped === 1, 'op pw 같은 판 = 건너뜀');
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(1, { state: 'DONE' })]);
  ok(r.accepted === 0 && r.skipped === 1, 'op pw 작은 판 = 건너뜀');
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(3, { state: 'DONE' })]);
  ok(r.accepted === 1 && (await q1(`select state from planned_work_mirror`)).state === 'DONE', 'op pw 큰 판 = 바꿈');
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(4, { mode: 'PAPER' })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op pw mode check');
  r = await push(U.op, 'd_op', 3, 'planned_work_mirror', [pw(4, { work_id: 'w2' }), pw(5, { work_id: 'w2' })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op pw 같은 키 두 번');

  // resume_run_mirror — 덮음
  const rr = (extra = {}) => ({ resume_run_id: 'rr1', gap_trading_days: 4, mode: 'SIM_INTERNAL', resume_mode: 'CONSERVATIVE', phase: 'R3', headline: '4거래일 미실행', ...extra });
  r = await push(U.op, 'd_op', 3, 'resume_run_mirror', [rr()]);
  ok(r.code === null && r.accepted === 1, `op rr 1행 (${JSON.stringify(r)})`);
  r = await push(U.op, 'd_op', 3, 'resume_run_mirror', [rr({ phase: 'R8' })]);
  ok(r.code === null && r.accepted === 1 && (await q1(`select phase from resume_run_mirror`)).phase === 'R8', 'op rr 덮음');
  r = await push(U.op, 'd_op', 3, 'resume_run_mirror', [rr({ resume_mode: null })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op rr resume_mode 빠짐 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 3, 'resume_run_mirror', [rr({ resume_mode: 'FAST' })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op rr resume_mode check');

  // ledger_stamp — 모드 축 · 재생성(같은 날 다시 씀) · 낮은 epoch = LEASE_LOST
  const st = (date, hash, extra = {}) => ({ mode: 'LIVE', authored_date: date, chain_hash: hash, operator_epoch: 999, stamped_at: '2000-01-01T00:00:00Z', ...extra });
  r = await push(U.op, 'd_op', 3, 'ledger_stamp', [st('2026-11-24', 'a'.repeat(64)), st('2026-11-24', 'b'.repeat(64), { mode: 'SIM_BROKER' })]);
  ok(r.code === null && r.accepted === 2, `op stamp 2행(모드 축) (${JSON.stringify(r)})`);
  row = await q1(`select operator_epoch::int oe, stamped_at > now() - interval '1 minute' fresh from ledger_stamp where mode = 'LIVE'`);
  ok(row.oe === 3 && row.fresh, 'op stamp 덮는 칸 operator_epoch = 인자 · stamped_at = now()');
  await lease('d_op', 4, 30);
  r = await push(U.op, 'd_op', 4, 'ledger_stamp', [st('2026-11-24', 'c'.repeat(64))]);
  ok(r.code === null && r.accepted === 1, 'op stamp 재생성 = 같은 날 다시 씀');
  row = await q1(`select chain_hash, operator_epoch::int oe from ledger_stamp where mode = 'LIVE'`);
  ok(row.chain_hash === 'c'.repeat(64) && row.oe === 4, 'op stamp 새 체인 · 새 epoch');
  r = await push(U.op, 'd_op', 3, 'ledger_stamp', [st('2026-11-24', 'd'.repeat(64))]);
  ok(r.code === 'LEASE_LOST' && r.epoch === 4, 'op stamp 낮은 epoch = LEASE_LOST');
  ok((await q1(`select chain_hash from ledger_stamp where mode = 'LIVE'`)).chain_hash === 'c'.repeat(64), 'op stamp 낮은 epoch 쓰기 0');
  r = await push(U.op, 'd_op', 4, 'ledger_stamp', [st('2026-13-01', 'e'.repeat(64))]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op stamp 날 형');

  // calendar_sync_status — 모드 축(LIVE · SIM) · 덮음
  const cs = (extra = {}) => ({ mode: 'LIVE', last_ok_date: '2026-11-24', status: 'OK', quarantined_count: 0, ...extra });
  r = await push(U.op, 'd_op', 4, 'calendar_sync_status', [cs(), cs({ mode: 'SIM' })]);
  ok(r.code === null && r.accepted === 2, `op cal 2행 (${JSON.stringify(r)})`);
  r = await push(U.op, 'd_op', 4, 'calendar_sync_status', [cs({ status: 'LAGGED', quarantined_count: 2 })]);
  ok(r.accepted === 1 && (await q1(`select status from calendar_sync_status where mode='LIVE'`)).status === 'LAGGED', 'op cal 덮음');
  r = await push(U.op, 'd_op', 4, 'calendar_sync_status', [cs({ mode: 'SIM_INTERNAL' })]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op cal mode 축(LIVE·SIM) check');
  r = await push(U.op, 'd_op', 4, 'calendar_sync_status', [{ mode: 'LIVE', status: 'OK' }]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op cal quarantined_count 빠짐 = not null');

  // 공통 — 표 · 행 · 리스 · 기기 · 권한
  r = await push(U.op, 'd_op', 4, 'rm_alert', [{}]);
  ok(r.code === 'OPS_PUSH_TABLE_UNKNOWN' && r.epoch === 4, 'op rm 표 = TABLE_UNKNOWN(rm_push 몫)');
  r = await push(U.op, 'd_op', 4, 'command_queue', [{}]);
  ok(r.code === 'OPS_PUSH_TABLE_UNKNOWN', 'op command_queue = TABLE_UNKNOWN');
  r = await push(U.op, 'd_op', 4, 'ledger_stamp; drop table ledger_stamp', [{}]);
  ok(r.code === 'OPS_PUSH_TABLE_UNKNOWN', 'op 이름 끼워 넣기 = TABLE_UNKNOWN');
  r = (await as('authenticated', U.op, () => db.query(`select * from op_push('d_op', 4, 'ledger_stamp', '{"a":1}'::jsonb)`))).rows[0];
  ok(r.code === 'OPS_PUSH_ROWS_INVALID', 'op 배열 아님 = ROWS_INVALID');
  r = await push(U.op, 'd_op', 4, 'ledger_stamp', []);
  ok(r.code === null && r.accepted === 0 && r.skipped === 0, 'op 빈 배열 = 0행 성공');
  r = await push(U.view, 'd_v', 4, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', 'op 뷰어 기기 = NOT_ELIGIBLE');
  r = await push(U.view, 'd_op', 4, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', 'op 남의 기기 이름 = NOT_ELIGIBLE');
  r = await push(UX, 'd_x', 4, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_LOST' && r.epoch === 4, 'op 리스 없는 운영 기기 = LEASE_LOST');
  r = await push(null, 'd_op', 4, 'ledger_stamp', []);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', 'op 로그인 0 = NOT_ELIGIBLE');
  await throws(() => push(null, 'd_op', 4, 'ledger_stamp', [], 'anon'), /permission denied/, 'op anon 실행 권한 0');
  await lease('d_op', 4, -1);
  r = await push(U.op, 'd_op', 4, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_LOST', 'op 만료 = LEASE_LOST');
  await lease('d_v', 5, 30);
  r = await push(U.op, 'd_op', 5, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_LOST' && r.epoch === 5, 'op 리스가 다른 기기 = LEASE_LOST');
  // 소유자 본인의 뷰어 기기(auth_uid = owner_uid = 부른 사용자 · ACTIVE)가 리스 행을 쥐어도 role 'operator' 가 아니면 거부(rm_push 와 같은 판정).
  await db.exec(`insert into app_device(device_id,label,role,status,owner_uid,auth_uid) values ('d_ov','운영자 뷰어','viewer','ACTIVE','${U.op}','${U.op}')`);
  await lease('d_ov', 6, 30);
  r = await push(U.op, 'd_ov', 6, 'ledger_stamp', [st('2026-11-25', 'f'.repeat(64))]);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', 'op 소유자 본인 뷰어 기기(리스 쥠) = NOT_ELIGIBLE');
  await db.exec(`delete from operator_lease; delete from app_device where device_id = 'd_ov'`);
  await lease('d_v', 5, 30);
  ok((await q1(`select count(*)::int n from ledger_stamp where authored_date = '2026-11-25'`)).n === 0, 'op 거부 = 0행');

  // 직접 쓰기 = 정책 0 · 읽기 = 222 ⓕ K311 본문(ACTIVE 기기만)
  for (const [t, ins] of [
    ['planned_work_mirror', `insert into planned_work_mirror(work_id, mode, digest, one_line, due_by, state, row_version, lease_epoch) values ('wz','LIVE','d','x','2026-12-01','PLANNED',9,9)`],
    ['resume_run_mirror', `insert into resume_run_mirror(resume_run_id, gap_trading_days, mode, resume_mode, phase) values ('rz',1,'LIVE','NORMAL','R0')`],
    ['ledger_stamp', `insert into ledger_stamp(mode, authored_date, chain_hash, operator_epoch) values ('LIVE','2026-01-01','x',9)`],
    ['calendar_sync_status', `insert into calendar_sync_status(mode, status) values ('SIM','x')`],
  ]) {
    for (const [role, uid] of [['authenticated', U.op], ['anon', null]]) {
      await throws(() => as(role, uid, () => db.exec(ins)), /row-level security/, `op ${t} ${role} 직접 INSERT 거부`);
      const u = await as(role, uid, () => db.query(`update ${t} set mode = mode`));
      ok((u.affectedRows ?? 0) === 0, `op ${t} ${role} UPDATE 0행`);
      const d = await as(role, uid, () => db.query(`delete from ${t}`));
      ok((d.affectedRows ?? 0) === 0, `op ${t} ${role} DELETE 0행`);
    }
    const n = async (role, uid) => (await as(role, uid, () => db.query(`select count(*)::int n from ${t}`))).rows[0].n;
    const total = (await q1(`select count(*)::int n from ${t}`)).n;
    ok(total > 0 && await n('authenticated', U.op) === total && await n('authenticated', U.view) === total, `op ${t} 운영 · ACTIVE 뷰어 읽음(${total})`);
    ok(await n('authenticated', U.none) === 0 && await n('authenticated', U.pend) === 0 && await n('authenticated', U.ret) === 0 && await n('anon', null) === 0,
      `op ${t} 기기 없음 · PENDING · RETIRED · anon = 0행(222 ⓕ K311)`);
  }

  // 함수 = 계약 이름만 · 보안 꼴
  const fns = (await db.query(`select p.proname n from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public' order by 1`)).rows.map(x => x.n);
  ok(JSON.stringify(fns) === JSON.stringify(['command_open', 'command_status', 'lease_claim', 'lease_renew', 'lease_revoke', 'op_push', 'pairing_claim', 'pairing_revoke', 'pairing_ticket_issue', 'rm_push']), `public 함수 = ${fns.join(',')}`);
  const sec = await q1(`select prosecdef s, proconfig::text c from pg_proc where proname = 'op_push'`);
  ok(sec.s === true && sec.c.includes('search_path='), `op_push security definer · search_path (${sec.c})`);
}

// ⑩ 🆕 미결 246(R272 · 계약 v1.41) 뷰어 페어링 RPC 셋 · 명령 표 읽는 함수 둘 · 배치 D 명령 표 정정 · op_push 리스 없는 ack 거부 —
//    티켓(해시만 · 정책 0) · 발급(리스 판정 = op_push · 해시 꼴 · 수명 범위 · 바꿔 넣기) · 클레임(기기 행 0 · 해시 · 낸 기기 ACTIVE · 소유자 ≠ ·
//    만료 · 뷰어 ACTIVE + 티켓 지움) · 폐기(같은 소유자 뷰어 → REVOKED · 곧바로 차단) · command_open(종단 없는 것 · 킬스위치 먼저 · 상한) ·
//    command_status(최신 ack · 종단 우선 · 서버 now() 리스 = NO_OPERATOR · REQUESTED · 글자 null) · requested_at = now() · 맥락 not null.
{
  const sha = (s) => createHash('sha256').update(s, 'utf8').digest('hex');
  const q1 = async (s, p = []) => (await db.query(s, p)).rows[0];
  const rows = async (s, p = []) => (await db.query(s, p)).rows;
  const lease = async (dev, epoch, mins) => db.exec(`delete from operator_lease; insert into operator_lease(id, device_id, epoch, expires_at) values (1, '${dev}', ${epoch}, now() + interval '${mins} minutes')`);
  const issue = async (uid, dev, epoch, hash, ttl, role = 'authenticated') =>
    (await as(role, uid, () => db.query(`select * from pairing_ticket_issue($1, $2, $3, $4)`, [dev, epoch, hash, ttl]))).rows[0];
  const claim = async (uid, nonce, dev, label, platform = 'web', role = 'authenticated') =>
    (await as(role, uid, () => db.query(`select * from pairing_claim($1, $2, $3, $4)`, [nonce, dev, label, platform]))).rows[0];
  const revoke = async (uid, dev, epoch, target, role = 'authenticated') =>
    (await as(role, uid, () => db.query(`select * from pairing_revoke($1, $2, $3)`, [dev, epoch, target]))).rows[0];
  const UX = '66666666-6666-6666-6666-666666666666'; // ⑨ 가 넣은 남의 운영 사용자(d_x)
  const UV2 = '77777777-7777-7777-7777-777777777777', UV3 = '88888888-8888-8888-8888-888888888888';
  await db.exec(`insert into auth.users values ('${UV2}'), ('${UV3}');`);
  await lease('d_op', 7, 30);

  // 표 = RLS 켬 · 정책 0 · 클라이언트 읽기 · 쓰기 0
  const pt = await q1(`select c.relrowsecurity r, (select count(*)::int from pg_policies p where p.tablename = 'pairing_ticket') n from pg_class c where c.relname = 'pairing_ticket'`);
  ok(pt.r === true && pt.n === 0, `티켓 표 RLS 켬 · 정책 0 (${JSON.stringify(pt)})`);
  ok((await q1(`select count(*)::int n from pg_indexes where indexname = 'ix_command_ack_command_id'`)).n === 1, 'ack 색인 command_ack(command_id)');

  // 발급 — 리스 판정 · 해시 꼴 · 수명 범위 · 바꿔 넣기
  const N1 = 'nonce-one-0123456789abcdef', N2 = 'nonce-two-0123456789abcdef';
  let r = await issue(U.op, 'd_op', 7, sha(N1), 15);
  ok(r.code === null && r.epoch === 7 && r.expires_at instanceof Date, `발급 성공 (${JSON.stringify(r)})`);
  let t = await q1(`select owner_uid::text o, issued_by_device d, ticket_hash h, round(extract(epoch from (expires_at - now())) / 60)::int m from pairing_ticket`);
  ok(t.o === U.op && t.d === 'd_op' && t.h === sha(N1) && t.m === 15, `티켓 = 소유자 · 낸 기기 · 해시 · now()+15분 (${JSON.stringify(t)})`);
  ok(Math.abs(new Date(r.expires_at) - (await q1(`select expires_at e from pairing_ticket`)).e) < 1000, '반환 expires_at = 티켓 만료 시각');
  r = await issue(U.op, 'd_op', 7, sha(N2), 15);
  ok(r.code === null && (await q1(`select count(*)::int n, max(ticket_hash) h from pairing_ticket`)).h === sha(N2), '재발급 = 바꿔 넣기(소유자 한 행 · 옛 해시 무효)');
  ok((await q1(`select count(*)::int n from pairing_ticket`)).n === 1, '티켓 = 소유자당 1행');
  for (const [hash, ttl, m] of [[sha(N1).toUpperCase(), 15, '대문자 해시'], ['abc', 15, '짧은 해시'], [null, 15, '해시 없음'], [sha(N1), 0, '수명 0'], [sha(N1), 61, '수명 61'], [sha(N1), null, '수명 없음']]) {
    r = await issue(U.op, 'd_op', 7, hash, ttl);
    ok(r.code === 'PAIRING_TICKET_INVALID' && r.epoch === 7 && r.expires_at === null, `발급 ${m} = TICKET_INVALID (${JSON.stringify(r)})`);
  }
  ok((await q1(`select ticket_hash h from pairing_ticket`)).h === sha(N2), '발급 거부 = 티켓 그대로');
  for (const ttl of [1, 60]) {
    r = await issue(U.op, 'd_op', 7, sha(N2), ttl);
    ok(r.code === null, `발급 수명 경계 ${ttl}분 = 받음`);
  }
  r = await issue(U.op, 'd_op', 6, sha(N2), 15);
  ok(r.code === 'LEASE_LOST' && r.epoch === 7, '발급 epoch 다름 = LEASE_LOST(지금 epoch)');
  r = await issue(U.view, 'd_v', 7, sha(N2), 15);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '발급 뷰어 기기 = NOT_ELIGIBLE');
  r = await issue(U.view, 'd_op', 7, sha(N2), 15);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '발급 남의 기기 이름 = NOT_ELIGIBLE');
  r = await issue(UX, 'd_x', 7, sha(N2), 15);
  ok(r.code === 'LEASE_LOST' && r.epoch === 7, '발급 리스 없는 운영 기기 = LEASE_LOST');
  r = await issue(null, 'd_op', 7, sha(N2), 15);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '발급 로그인 0 = NOT_ELIGIBLE');
  await throws(() => issue(null, 'd_op', 7, sha(N2), 15, 'anon'), /permission denied/, '발급 anon 실행 권한 0');
  await db.exec(`insert into app_device(device_id,label,role,status,owner_uid,auth_uid) values ('d_ov2','운영자 뷰어','viewer','ACTIVE','${U.op}','${U.op}')`);
  await lease('d_ov2', 8, 30);
  r = await issue(U.op, 'd_ov2', 8, sha(N2), 15);
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '발급 소유자 본인 뷰어 기기(리스 쥠) = NOT_ELIGIBLE');
  await db.exec(`delete from operator_lease; delete from app_device where device_id = 'd_ov2'`);
  await lease('d_op', 7, -1);
  r = await issue(U.op, 'd_op', 7, sha(N2), 15);
  ok(r.code === 'LEASE_LOST', '발급 리스 만료 = LEASE_LOST');
  await lease('d_op', 7, 30);
  // 직접 읽기 · 쓰기 = 0
  for (const [role, uid] of [['authenticated', U.op], ['authenticated', U.view], ['anon', null]]) {
    ok((await as(role, uid, () => db.query(`select count(*)::int n from pairing_ticket`))).rows[0].n === 0, `티켓 ${role} ${uid ?? ''} 읽기 0행(해시 비공개)`);
    await throws(() => as(role, uid, () => db.exec(`insert into pairing_ticket(owner_uid, ticket_hash, issued_by_device, expires_at) values ('${U.op}', '${sha('x')}', 'd_op', now() + interval '1 hour')`)), /row-level security/, `티켓 ${role} 직접 INSERT 거부`);
    const u = await as(role, uid, () => db.query(`update pairing_ticket set expires_at = now() + interval '9 days'`));
    ok((u.affectedRows ?? 0) === 0, `티켓 ${role} UPDATE 0행`);
  }

  // 클레임 — 거부 갈래(바뀜 0)
  r = await issue(U.op, 'd_op', 7, sha(N1), 15);
  const nDev = async () => (await q1(`select count(*)::int n from app_device`)).n;
  const before = await nDev();
  r = await claim(UV2, 'wrong-nonce', 'd_v2', '랩탑 2');
  ok(r.code === 'PAIRING_TICKET_INVALID' && r.epoch === null && r.expires_at === null, `클레임 논스 다름 = TICKET_INVALID (${JSON.stringify(r)})`);
  for (const n of [null, '']) {
    r = await claim(UV2, n, 'd_v2', '랩탑 2');
    ok(r.code === 'PAIRING_TICKET_INVALID', `클레임 논스 없음(${JSON.stringify(n)}) = TICKET_INVALID`);
  }
  r = await claim(U.op, N1, 'd_v2', '랩탑 2');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '클레임 운영 사용자(기기 행 있음 · 소유자) = DEVICE_NOT_ELIGIBLE');
  r = await claim(U.view, N1, 'd_v9', '랩탑 9');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '클레임 이미 기기 행 있는 사용자 = DEVICE_NOT_ELIGIBLE');
  r = await claim(UV2, N1, 'd_v', '랩탑 2');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '클레임 이미 있는 기기 id = DEVICE_NOT_ELIGIBLE');
  for (const [dev, label, m] of [['d_v2', '  ', '라벨 빈칸'], ['d_v2', null, '라벨 없음'], ['', '랩탑', '기기 id 빈칸'], [null, '랩탑', '기기 id 없음']]) {
    r = await claim(UV2, N1, dev, label);
    ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', `클레임 ${m} = DEVICE_NOT_ELIGIBLE`);
  }
  r = await claim(null, N1, 'd_v2', '랩탑 2');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '클레임 로그인 0 = DEVICE_NOT_ELIGIBLE');
  await throws(() => claim(null, N1, 'd_v2', '랩탑 2', 'web', 'anon'), /permission denied/, '클레임 anon 실행 권한 0');
  // 낸 기기가 더는 operator ACTIVE 아님(비상 회수 뒤) = 옛 티켓 무효
  await db.exec(`update app_device set status = 'REVOKED' where device_id = 'd_op'`);
  r = await claim(UV2, N1, 'd_v2', '랩탑 2');
  ok(r.code === 'PAIRING_TICKET_INVALID', '클레임 낸 기기 REVOKED = TICKET_INVALID(비상 회수 뒤 옛 QR)');
  await db.exec(`update app_device set status = 'ACTIVE' where device_id = 'd_op'`);
  // 만료
  await db.exec(`update pairing_ticket set expires_at = now() - interval '1 second'`);
  r = await claim(UV2, N1, 'd_v2', '랩탑 2');
  ok(r.code === 'PAIRING_TICKET_EXPIRED' && r.epoch === null, `클레임 만료 = TICKET_EXPIRED (${JSON.stringify(r)})`);
  ok((await nDev()) === before && (await q1(`select count(*)::int n from pairing_ticket`)).n === 1, '클레임 거부 = 기기 행 · 티켓 그대로');

  // 클레임 성공 — 뷰어 ACTIVE(소유자 = 티켓 소유자 · 로그인 = 부른 사용자) + 티켓 지움 · 한 번만
  r = await issue(U.op, 'd_op', 7, sha(N1), 15);
  r = await claim(UV2, N1, 'd_v2', '  랩탑 2  ', 'web');
  ok(r.code === null && r.epoch === null && r.expires_at === null, `클레임 성공 (${JSON.stringify(r)})`);
  const dv = await q1(`select role, status, owner_uid::text o, auth_uid::text a, label, platform from app_device where device_id = 'd_v2'`);
  ok(dv.role === 'viewer' && dv.status === 'ACTIVE' && dv.o === U.op && dv.a === UV2 && dv.label === '랩탑 2' && dv.platform === 'web', `클레임 기기 행 (${JSON.stringify(dv)})`);
  ok((await q1(`select count(*)::int n from pairing_ticket`)).n === 0, '클레임 = 티켓 지움');
  r = await claim(UV3, N1, 'd_v3', '랩탑 3');
  ok(r.code === 'PAIRING_TICKET_INVALID', '쓴 티켓 다시 = TICKET_INVALID(한 번만)');
  r = await claim(UV2, N1, 'd_v2b', '랩탑 2b');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '클레임한 사용자 다시 = DEVICE_NOT_ELIGIBLE');
  const rmOne = rmTables[0].n;
  const rmN = async (uid) => (await as('authenticated', uid, () => db.query(`select count(*)::int n from ${rmOne}`))).rows[0].n;
  ok((await rmN(UV2)) > 0 && (await rmN(UV2)) === (await rmN(U.op)), `새 뷰어 = 읽기 모델 읽음(${rmOne} · 운영 사용자와 같은 행 수)`);

  // 명령 넣기 — 맥락 not null · check · requested_at = now() · 새 뷰어 = 4종
  const ins = (uid, id, kind, dev, owner, ctx = `'LIVE','AUTO_TRADE',7`, extra = '') => as('authenticated', uid, () => db.exec(
    `insert into command_queue(command_id, kind, payload, issued_by_device, nonce, expires_at, owner_uid, run_mode, operating_mode, lease_epoch${extra ? ', requested_at' : ''})
     values ('${id}', '${kind}', '{}', '${dev}', 'n-${id}', now() + interval '1 day', '${owner}', ${ctx}${extra ? ', ' + extra : ''})`));
  const CID = (n) => `cccccccc-0000-0000-0000-0000000000${String(n).padStart(2, '0')}`;
  await ins(UV2, CID(1), 'KILL_SWITCH_ACTIVATE', 'd_v2', U.op);
  ok((await q1(`select requested_at = now() x, run_mode from command_queue where command_id = $1`, [CID(1)])).run_mode === 'LIVE', '새 뷰어 킬스위치 넣기 = 됨(맥락 · 접수 시각 = 서버)');
  await throws(() => ins(UV2, CID(2), 'JOURNAL_DRAFT', 'd_v2', U.op, `'LIVE','AUTO_TRADE',7`, `'2000-01-01T00:00:00Z'`), /row-level security/, '뷰어 requested_at 덮기 = RLS 거부');
  await throws(() => ins(U.op, CID(3), 'DEPOSIT_REGISTER', 'd_op', U.op, `'LIVE','AUTO_TRADE',7`, `now() - interval '1 day'`), /row-level security/, '운영 requested_at 덮기 = RLS 거부');
  await throws(() => ins(UV2, CID(4), 'JOURNAL_DRAFT', 'd_v2', U.op, `null,'AUTO_TRADE',7`), /null value|not-null/, 'run_mode 없음 = not null');
  await throws(() => ins(UV2, CID(5), 'JOURNAL_DRAFT', 'd_v2', U.op, `'LIVE',null,7`), /null value|not-null/, 'operating_mode 없음 = not null');
  await throws(() => ins(UV2, CID(6), 'JOURNAL_DRAFT', 'd_v2', U.op, `'LIVE','AUTO_TRADE',null`), /null value|not-null/, 'lease_epoch 없음 = not null');
  await throws(() => ins(UV2, CID(7), 'JOURNAL_DRAFT', 'd_v2', U.op, `'PAPER','AUTO_TRADE',7`), /check/, 'run_mode check');
  await throws(() => ins(UV2, CID(8), 'JOURNAL_DRAFT', 'd_v2', U.op, `'LIVE','MANUAL',7`), /check/, 'operating_mode check');
  await throws(() => ins(UV2, CID(9), 'DEPOSIT_REGISTER', 'd_v2', U.op), /row-level security/, '뷰어 DEPOSIT_REGISTER = RLS 거부(4종 밖)');
  await ins(U.op, CID(10), 'DEPOSIT_REGISTER', 'd_op', U.op, `'SIM_INTERNAL','ADVISORY',7`);
  ok((await q1(`select count(*)::int n from command_queue where command_id = $1`, [CID(10)])).n === 1, '운영 폰 넣기 = 됨(맥락 SIM_INTERNAL · ADVISORY)');

  // 폐기 — 같은 소유자 뷰어 → REVOKED · 곧바로 차단 · 멱등 · 운영 폰 · 남의 기기 = 거부
  r = await revoke(U.op, 'd_op', 7, 'd_op');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE' && r.epoch === 7, '폐기 운영 폰 = DEVICE_NOT_ELIGIBLE');
  r = await revoke(U.op, 'd_op', 7, 'd_x');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '폐기 남의 기기 = DEVICE_NOT_ELIGIBLE');
  const UV4 = '99999999-9999-9999-9999-999999999999';
  await db.exec(`insert into auth.users values ('${UV4}'); insert into app_device(device_id,label,role,status,owner_uid,auth_uid) values ('d_xv','남의 뷰어','viewer','ACTIVE','${UX}','${UV4}')`);
  r = await revoke(U.op, 'd_op', 7, 'd_xv');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE' && (await q1(`select status from app_device where device_id = 'd_xv'`)).status === 'ACTIVE', '폐기 남의 소유자 뷰어 = DEVICE_NOT_ELIGIBLE · 그대로');
  r = await revoke(U.op, 'd_op', 7, 'nope');
  ok(r.code === 'PAIRING_DEVICE_NOT_ELIGIBLE', '폐기 없는 기기 = DEVICE_NOT_ELIGIBLE');
  r = await revoke(U.view, 'd_v', 7, 'd_v2');
  ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', '폐기 뷰어가 부름 = LEASE_DEVICE_NOT_ELIGIBLE');
  r = await revoke(U.op, 'd_op', 6, 'd_v2');
  ok(r.code === 'LEASE_LOST' && r.epoch === 7, '폐기 epoch 다름 = LEASE_LOST');
  await throws(() => revoke(null, 'd_op', 7, 'd_v2', 'anon'), /permission denied/, '폐기 anon 실행 권한 0');
  ok((await q1(`select status from app_device where device_id = 'd_v2'`)).status === 'ACTIVE', '폐기 거부 = 그대로');
  r = await revoke(U.op, 'd_op', 7, 'd_v2');
  ok(r.code === null && r.epoch === 7 && r.expires_at === null, `폐기 성공 (${JSON.stringify(r)})`);
  ok((await q1(`select status from app_device where device_id = 'd_v2'`)).status === 'REVOKED', '폐기 = REVOKED');
  r = await revoke(U.op, 'd_op', 7, 'd_v2');
  ok(r.code === null && (await q1(`select status from app_device where device_id = 'd_v2'`)).status === 'REVOKED', '폐기 다시 = 성공 · 바뀜 0(멱등)');
  ok((await rmN(UV2)) === 0 && (await rmN(U.op)) > 0, '폐기된 뷰어 = 읽기 모델 0행(곧바로 차단)');
  ok((await as('authenticated', UV2, () => db.query(`select count(*)::int n from command_queue`))).rows[0].n === 0, '폐기된 뷰어 = 명령 0행');
  await throws(() => ins(UV2, CID(11), 'KILL_SWITCH_ACTIVATE', 'd_v2', U.op), /row-level security/, '폐기된 뷰어 명령 넣기 = RLS 거부(PAIRING_TOKEN_REVOKED 경로)');
  r = await revoke(U.op, 'd_op', 7, 'd_p');
  ok(r.code === null && (await q1(`select status from app_device where device_id = 'd_p'`)).status === 'REVOKED', '폐기 PENDING 뷰어 = REVOKED');

  // command_open — 종단 ack 없는 것 · 킬스위치 먼저 → requested_at · 상한 · RLS · 리스 판정 0
  await db.exec(`delete from command_ack; delete from command_queue;`);
  const Q = (n) => `dddddddd-0000-0000-0000-0000000000${String(n).padStart(2, '0')}`;
  const put = async (id, kind, hoursAgo, owner = U.op, dev = 'd_v') => db.exec(`insert into command_queue(command_id, kind, payload, issued_by_device, nonce, requested_at, expires_at, owner_uid, run_mode, operating_mode, lease_epoch)
     values ('${id}', '${kind}', '{}', '${dev}', 'n-${id}', now() - interval '${hoursAgo} hours', now() + interval '1 day', '${owner}', 'LIVE', 'AUTO_TRADE', 7)`);
  await put(Q(1), 'JOURNAL_DRAFT', 3);          // 열림
  await put(Q(2), 'JOURNAL_DRAFT', 4);          // EXECUTED(종단)
  await put(Q(3), 'BLIND_REVIEW_SCORE', 2);     // RECEIVED(비종단)
  await put(Q(4), 'KILL_SWITCH_ACTIVATE', 1);   // 열림 · 킬스위치
  await put(Q(5), 'DISCLOSURE_VIEW', 5);        // REJECTED(종단)
  await put(Q(6), 'JOURNAL_DRAFT', 6);          // EXPIRED(종단)
  await put(Q(7), 'JOURNAL_DRAFT', 7);          // STALE_CONTEXT(보류 · 비종단)
  await put(Q(9), 'JOURNAL_DRAFT', 1, UX, 'd_x'); // 남의 명령
  const ackAt = async (cmd, state, secsAgo, id) => db.exec(`insert into command_ack(ack_id, command_id, state, state_label, reject_reason_code, lease_epoch, acked_at)
     values ('${id}', '${cmd}', '${state}', '엔진 ${state}', ${state === 'REJECTED' ? `'RUN_MODE_MISMATCH'` : 'null'}, 7, now() - interval '${secsAgo} seconds')`);
  const K = (n) => `eeeeeeee-0000-0000-0000-0000000000${String(n).padStart(2, '0')}`;
  await ackAt(Q(2), 'RECEIVED', 60, K(1)); await ackAt(Q(2), 'EXECUTED', 30, K(2));
  await ackAt(Q(3), 'RECEIVED', 30, K(3));
  await ackAt(Q(5), 'REJECTED', 30, K(4));
  await ackAt(Q(6), 'EXPIRED', 30, K(5));
  await ackAt(Q(7), 'STALE_CONTEXT', 30, K(6));
  const open = async (uid, lim, role = 'authenticated') => (await as(role, uid, () => db.query(`select command_id::text id from command_open($1)`, [lim]))).rows.map(x => x.id);
  const want = [Q(4), Q(7), Q(1), Q(3)];
  ok(JSON.stringify(await open(U.op, null)) === JSON.stringify(want), `open = 킬스위치 먼저 → 오래된 차례 · 종단 0 (${JSON.stringify(await open(U.op, null))})`);
  ok(JSON.stringify(await open(U.op, 2)) === JSON.stringify(want.slice(0, 2)), 'open 상한 2');
  for (const lim of [0, -5, 1000]) ok((await open(U.op, lim)).length === 4, `open 상한 ${lim} = 기본 상한(100)`);
  ok(JSON.stringify(await open(U.view, null)) === JSON.stringify(want), 'open ACTIVE 뷰어 = 소유자 명령(RLS)');
  ok(JSON.stringify(await open(UX, null)) === JSON.stringify([Q(9)]), 'open 남 = 자기 소유 명령만');
  ok((await open(U.none, null)).length === 0 && (await open(UV2, null)).length === 0, 'open 기기 없음 · 폐기된 뷰어 = 0');
  await throws(() => open(null, null, 'anon'), /permission denied/, 'open anon 실행 권한 0');
  await lease('d_op', 7, -1);
  ok((await open(U.op, null)).length === 4, 'open = 리스 판정 0(소비기가 원격 확인 뒤에만 부른다)');
  const cols = (await rows(`select a.attname from pg_attribute a where a.attrelid = 'command_queue'::regclass and a.attnum > 0 and not a.attisdropped order by a.attnum`)).map(x => x.attname);
  const got = Object.keys((await as('authenticated', U.op, () => db.query(`select * from command_open(1)`))).rows[0]);
  ok(JSON.stringify(got) === JSON.stringify(cols), `open 칸 = command_queue 열 차례 (${got.join(',')})`);

  // command_status — 최신 ack · 종단 우선 · 리스(서버 now()) = NO_OPERATOR · REQUESTED · 글자 null
  // 같은 acked_at(한 문장 = 한 트랜잭션 시각) — ack_id 차례로는 RECEIVED 가 이기게 두고 «종단 우선»이 EXECUTED 를 고르는지 본다.
  await db.exec(`insert into command_ack(ack_id, command_id, state, state_label, lease_epoch, acked_at) values
     ('${K(18)}', '${Q(1)}', 'RECEIVED', '엔진 RECEIVED', 7, now() - interval '10 seconds'),
     ('${K(17)}', '${Q(1)}', 'EXECUTED', '엔진 EXECUTED', 7, now() - interval '10 seconds')`);
  const arr = (ids) => ids === null ? null : `{${ids.join(',')}}`;
  const st = async (uid, ids, role = 'authenticated') => (await as(role, uid, () => db.query(`select * from command_status($1::uuid[])`, [arr(ids)]))).rows;
  const byId = (rs) => Object.fromEntries(rs.map(x => [x.command_id, x]));
  await lease('d_op', 7, 30);
  let s = await st(U.op, [Q(4), Q(3), Q(2), Q(1), Q(7), Q(5), 'ffffffff-0000-0000-0000-000000000000', Q(9)]);
  ok(JSON.stringify(s.map(x => x.command_id)) === JSON.stringify([Q(4), Q(3), Q(2), Q(1), Q(7), Q(5)]), `status = 보이는 명령만 · 인자 차례 (${s.map(x => x.command_id.slice(-2)).join(',')})`);
  let m = byId(s);
  ok(m[Q(4)].state === 'REQUESTED' && m[Q(4)].state_label === null && m[Q(4)].acked_at === null, `ack 없음 ∧ 리스 유효 = REQUESTED · 글자 null (${JSON.stringify(m[Q(4)])})`);
  ok(m[Q(3)].state === 'RECEIVED' && m[Q(3)].state_label === '엔진 RECEIVED' && m[Q(3)].acked_at instanceof Date, '비종단 ack ∧ 리스 유효 = 그 ack');
  ok(m[Q(2)].state === 'EXECUTED' && m[Q(2)].state_label === '엔진 EXECUTED', '최신 ack 종단 = 그 ack');
  ok(m[Q(1)].state === 'EXECUTED', '같은 acked_at = 종단 우선');
  ok(m[Q(7)].state === 'STALE_CONTEXT', '보류 ack ∧ 리스 유효 = 그 ack');
  ok(m[Q(5)].state === 'REJECTED' && m[Q(5)].reject_reason_code === 'RUN_MODE_MISMATCH', '거부 ack = 거부 코드 그대로');
  ok(JSON.stringify(byId(await st(U.view, [Q(4), Q(3)]))) === JSON.stringify(byId(await st(U.op, [Q(4), Q(3)]))), 'status ACTIVE 뷰어 = 운영 사용자와 같다');
  ok((await st(U.none, [Q(4)])).length === 0 && (await st(UV2, [Q(4)])).length === 0, 'status 기기 없음 · 폐기된 뷰어 = 0행');
  ok((await st(U.op, [])).length === 0 && (await st(U.op, null)).length === 0, 'status 빈 배열 · null = 0행');
  await throws(() => st(null, [Q(4)], 'anon'), /permission denied/, 'status anon 실행 권한 0');
  for (const [how, f] of [['만료', () => lease('d_op', 7, -1)], ['행 없음', () => db.exec('delete from operator_lease')]]) {
    await f();
    m = byId(await st(U.op, [Q(4), Q(3), Q(7), Q(2)]));
    ok(m[Q(4)].state === 'NO_OPERATOR' && m[Q(4)].state_label === null && m[Q(4)].acked_at === null, `리스 ${how} ∧ ack 없음 = NO_OPERATOR · 글자 null`);
    ok(m[Q(3)].state === 'NO_OPERATOR' && m[Q(3)].state_label === null, `리스 ${how} ∧ 비종단 ack = NO_OPERATOR`);
    ok(m[Q(7)].state === 'NO_OPERATOR', `리스 ${how} ∧ 보류 ack = NO_OPERATOR`);
    ok(m[Q(2)].state === 'EXECUTED' && m[Q(2)].state_label === '엔진 EXECUTED', `리스 ${how} ∧ 종단 ack = 그 ack`);
  }
  // 리스가 남의 기기 · 다른 epoch 여도 유효하면 «받을 기기 있음»(판정 = 유효 리스 존재)
  await lease('d_x', 9, 30);
  ok(byId(await st(U.op, [Q(4)]))[Q(4)].state === 'REQUESTED', '유효 리스 있음 = REQUESTED');

  // op_push — 리스 없는 상태 ack 2 = ROWS_INVALID · 0행
  await lease('d_op', 7, 30);
  const push = async (rs) => (await as('authenticated', U.op, () => db.query(`select * from op_push('d_op', 7, 'command_ack', $1::jsonb)`, [JSON.stringify(rs)]))).rows[0];
  const nAck = async () => (await q1(`select count(*)::int n from command_ack`)).n;
  const a0 = await nAck();
  for (const state of ['PENDING_LEASE_CONFIRM', 'NO_OPERATOR']) {
    r = await push([{ ack_id: K(20), command_id: Q(4), state, state_label: 'x' }]);
    ok(r.code === 'OPS_PUSH_ROWS_INVALID' && r.accepted === 0, `op_push ack ${state} = ROWS_INVALID`);
  }
  r = await push([{ ack_id: K(21), command_id: Q(4), state: 'RECEIVED', state_label: '받음' }, { ack_id: K(22), command_id: Q(1), state: 'NO_OPERATOR', state_label: 'x' }]);
  ok(r.code === 'OPS_PUSH_ROWS_INVALID' && (await nAck()) === a0, 'op_push 좋은 ack + NO_OPERATOR 섞임 = 0행');
  r = await push([{ ack_id: K(21), command_id: Q(4), state: 'RECEIVED', state_label: '받음' }]);
  ok(r.code === null && r.accepted === 1, 'op_push RECEIVED = 받음');
  ok(byId(await st(U.op, [Q(4)]))[Q(4)].state === 'RECEIVED', 'status = op_push 가 쓴 ack');

  // 함수 = 계약 이름만 · 보안 꼴
  const fns = (await rows(`select p.proname n, p.prosecdef d, p.provolatile v, p.proconfig::text c from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public' order by 1`));
  ok(JSON.stringify(fns.map(x => x.n)) === JSON.stringify(['command_open', 'command_status', 'lease_claim', 'lease_renew', 'lease_revoke', 'op_push', 'pairing_claim', 'pairing_revoke', 'pairing_ticket_issue', 'rm_push']), `public 함수 = ${fns.map(x => x.n).join(',')}`);
  for (const f of fns.filter(x => ['pairing_claim', 'pairing_revoke', 'pairing_ticket_issue'].includes(x.n))) ok(f.d === true && f.c.includes('search_path='), `${f.n} security definer · search_path`);
  for (const f of fns.filter(x => ['command_open', 'command_status'].includes(x.n))) ok(f.d === false && f.v === 's' && f.c.includes('search_path='), `${f.n} security invoker · stable · search_path`);
}

// ⑥ 다시 붙여 넣기 = 가드가 멈춘다 · 아무것도 안 바뀐다
await throws(() => db.exec(full), /이미 적용된/, '두 번째 붙여 넣기 = 가드');
await db.exec('rollback');
const after = (await db.query(`select count(*)::int n from pg_tables where schemaname='public' and tablename like 'rm\\_%'`)).rows[0].n;
ok(after === 22, '가드 뒤 표 22 그대로');

console.log(`PGlite 하네스: ${pass} 통과 · ${fail} 실패`);
process.exit(fail ? 1 : 0);
