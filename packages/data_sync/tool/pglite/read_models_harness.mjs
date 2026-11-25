// 🆕 E11l1(설계 13 §8 R246) · E11l2(R254) · 미결 229(R270) PGlite 하네스 — 부트스트랩 완성 판(배치 D + 리스 RPC + rm_* 22 + rm_push + op_push)을 Postgres 16(WASM)에 실제로 붙여 넣고 RLS 를 잰다.
// 🔵 CI 밖 로컬 도구(node + @electric-sql/pglite) — 생성기 · RLS 본문이 바뀌는 PR 에서 손으로 돌린다(R221 · v1.34 하네스를 잇는다).
// 쓰는 법:
//   1) 빈 폴더 <pg> 에서: npm init -y && npm install --ignore-scripts @electric-sql/pglite@0.5.15
//   2) packages/data_sync 에서: dart run tool/gen_supabase_read_models.dart --dump <out>   (bootstrap_full.sql · bootstrap_incomplete.sql)
//   3) node tool/pglite/read_models_harness.mjs <pg> <out>/bootstrap_full.sql <out>/bootstrap_incomplete.sql [<rows.json>]
//      넷째(선택) = 빌더 22표 행 — packages/data_sync 에서 AAQ_DUMP_ROWS=<rows.json> dart test test/read_model_push_test.dart(E11l2b · R256)
// 🔵 Supabase 흉내 = auth.users · auth.uid()(= request.jwt.claim.sub) · 역할 anon · authenticated · public 표 기본 권한 ALL(= RLS 가 유일한 벽).
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
  await db.exec(`insert into command_queue(command_id, kind, payload, issued_by_device, nonce, expires_at, owner_uid) values
    ('${C1}','KILL_SWITCH_ACTIVATE','{}','d_v','n1', now() + interval '1 hour','${U.op}'),
    ('${C2}','JOURNAL_DRAFT','{}','d_v','n2', now() - interval '1 hour','${U.op}'),
    ('${CX}','JOURNAL_DRAFT','{}','d_x','n3', now() + interval '1 hour','${UX}');`);
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
  ok(JSON.stringify(fns) === JSON.stringify(['lease_claim', 'lease_renew', 'lease_revoke', 'op_push', 'rm_push']), `public 함수 = ${fns.join(',')}`);
  const sec = await q1(`select prosecdef s, proconfig::text c from pg_proc where proname = 'op_push'`);
  ok(sec.s === true && sec.c.includes('search_path='), `op_push security definer · search_path (${sec.c})`);
}

// ⑥ 다시 붙여 넣기 = 가드가 멈춘다 · 아무것도 안 바뀐다
await throws(() => db.exec(full), /이미 적용된/, '두 번째 붙여 넣기 = 가드');
await db.exec('rollback');
const after = (await db.query(`select count(*)::int n from pg_tables where schemaname='public' and tablename like 'rm\\_%'`)).rows[0].n;
ok(after === 22, '가드 뒤 표 22 그대로');

console.log(`PGlite 하네스: ${pass} 통과 · ${fail} 실패`);
process.exit(fail ? 1 : 0);
