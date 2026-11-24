// 🆕 리뷰 3차 카드 ⑥(01 §8 미결 236 · 설계 13 §8 R267) PGlite 하네스 — 부트스트랩 완성 판(배치 D + 리스 RPC + rm_* 22 + rm_push)을
// Postgres 16(WASM)에 실제로 붙여 넣고 리스 RPC 셋(lease_claim · lease_renew · lease_revoke)의 인계 · 자격 규칙을 잰다.
// 🔵 CI 밖 로컬 도구(node + @electric-sql/pglite) — 리스 RPC 본문이 바뀌는 PR 에서 손으로 돌린다(R221 · read_models_harness.mjs 와 같은 꼴).
// 쓰는 법:
//   1) 빈 폴더 <pg> 에서: npm init -y && npm install --ignore-scripts @electric-sql/pglite@0.5.15
//   2) packages/data_sync 에서: dart run tool/gen_supabase_read_models.dart --dump <out>
//   3) node tool/pglite/lease_harness.mjs <pg> <out>/bootstrap_full.sql
// 🔵 Supabase 흉내 = auth.users · auth.uid()(= request.jwt.claim.sub) · 역할 anon · authenticated · public 표 기본 권한 ALL(= RLS 가 유일한 벽).
// 🔴 잡는 것(미결 236):
//   ⓐ C-1 · D-01 — 남이 쥐었던 리스는 만료여도 그 기기가 자격(REVOKED · RETIRED 아님)이면 넘기지 않는다(LEASE_HELD_BY_OTHER · 지금 epoch) ·
//      같은 기기 = 만료 뒤 되찾음(epoch 그대로) · 옛 기기 회수(lease_revoke) · RETIRED 뒤에만 다른 기기로(epoch+1).
//   ⓑ C-2 · I-U2 — 첫 클레임 뒤 리스 자격 = 운영 사용자(recovery_secret.owner_uid)의 기기만 — 다른 Auth 사용자가 insert 정책으로
//      자기 기기 행을 넣어도 claim · renew · revoke = LEASE_DEVICE_NOT_ELIGIBLE · operator · ACTIVE 로 오르지 않는다 · rm_* 0행.
import { readFileSync } from 'node:fs';
import { createHash, randomBytes } from 'node:crypto';
import { pathToFileURL } from 'node:url';

const [pgDir, fullPath] = process.argv.slice(2);
const { PGlite } = await import(pathToFileURL(`${pgDir}/node_modules/@electric-sql/pglite/dist/index.js`).href);
const full = readFileSync(fullPath, 'utf8');

let pass = 0, fail = 0;
const ok = (c, m) => { if (c) { pass++; } else { fail++; console.log('FAIL', m); } };

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
await db.exec(full);

// 사용자 — 운영자(옛 폰 · 새 폰 · 셋째 폰이 같은 운영 사용자로 로그인 — 13 R197 T8) · 공개 가입 사용자 X · 뷰어 사용자 V
const U = { op: '11111111-1111-1111-1111-111111111111', x: '99999999-9999-9999-9999-999999999999', v: '22222222-2222-2222-2222-222222222222' };
await db.exec(`insert into auth.users values ('${U.op}'),('${U.x}'),('${U.v}')`);

async function as(uid, f) {
  await db.exec(`set role authenticated; select set_config('request.jwt.claim.sub', '${uid}', false);`);
  try { return await f(); } finally { await db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`); }
}
const rpc = async (uid, sql, args) => (await as(uid, () => db.query(sql, args))).rows[0];
const claim = (uid, dev, hash = null) => rpc(uid, `select code, epoch::int epoch, expires_at from lease_claim($1, $2)`, [dev, hash]);
const renew = (uid, dev, epoch) => rpc(uid, `select code, epoch::int epoch, expires_at from lease_renew($1, $2)`, [dev, epoch]);
const revoke = (uid, dev, code, newHash) => rpc(uid, `select code, epoch::int epoch, expires_at from lease_revoke($1, $2, $3)`, [dev, code, newHash]);
// 클라이언트 등록 = insert 정책 그대로(자기 uid · viewer · PENDING — supabase_lease.dart registerDevice).
const register = (uid, dev) => as(uid, () => db.query(
  `insert into app_device(device_id, label, role, status, platform, owner_uid, auth_uid) values ($1, '폰', 'viewer', 'PENDING', 'android', $2, $2)`, [dev, uid]));
const expire = () => db.exec(`update operator_lease set expires_at = now() - interval '1 minute'`);
const lease = async () => (await db.query(`select device_id, epoch::int epoch, expires_at <= now() expired from operator_lease`)).rows[0];
const device = async (dev) => (await db.query(`select role, status from app_device where device_id = $1`, [dev])).rows[0];
// 복구 코드 해시 — 'sha256:<소금 16진 32>:<sha256(소금 || ':' || 정규화 코드)>'(supabase_recovery_code.dart 와 같은 꼴)
const norm = (c) => c.replace(/[^0-9A-Za-z]/g, '').toUpperCase();
const hashOf = (code) => { const salt = randomBytes(16).toString('hex'); return `sha256:${salt}:${createHash('sha256').update(`${salt}:${norm(code)}`).digest('hex')}`; };

// ① 운영 폰 A 첫 클레임 — epoch 1 · operator ACTIVE · recovery_secret.owner_uid = 운영자
const codeA = 'AAAA-BBBB-CCCC-DDDD';
await register(U.op, 'd_a');
let r = await claim(U.op, 'd_a', hashOf(codeA));
ok(r.code === null && r.epoch === 1, `A 첫 클레임 epoch 1 (${JSON.stringify(r)})`);
ok((await device('d_a')).status === 'ACTIVE', 'A ACTIVE');
ok((await db.query(`select owner_uid::text u from recovery_secret`)).rows[0].u === U.op, 'recovery_secret 소유 = 운영자');

// ② ⓑ 공개 가입 사용자 X — 🆕 계약 v1.39(앱 01 §48 K349 ②) 첫 클레임 뒤 insert 정책 = 운영 사용자만 → X 자기 기기 행도 못 넣는다.
//    리스 자격 판정(RPC)은 그 전에 넣어 둔 행(첫 클레임 전 틈 · 옛 정책 시절)으로 그대로 잰다 — 행은 관리자 권한으로 넣는다.
let xInsert = null;
try { await register(U.x, 'd_x'); } catch (e) { xInsert = e; }
ok(xInsert !== null && /row-level security/.test(String(xInsert.message)), `ⓑ X 기기 행 insert = RLS 거부(첫 클레임 뒤) (${xInsert?.message})`);
ok((await device('d_x')) === undefined, 'ⓑ X 기기 행 0');
await db.query(`insert into app_device(device_id, label, role, status, platform, owner_uid, auth_uid) values ('d_x', '폰', 'viewer', 'PENDING', 'android', $1, $1)`, [U.x]);
ok((await device('d_x'))?.status === 'PENDING', 'X 기기 행(첫 클레임 전 틈에 넣은 셈) = PENDING');
r = await claim(U.x, 'd_x', hashOf('XXXX'));
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `ⓑ X claim(리스 유효) = NOT_ELIGIBLE (${r.code})`);
await expire();
r = await claim(U.x, 'd_x');
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE' && r.epoch === null, `ⓑ X claim(만료 틈) = NOT_ELIGIBLE (${r.code})`);
r = await renew(U.x, 'd_x', 1);
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `ⓑ X renew = NOT_ELIGIBLE (${r.code})`);
r = await revoke(U.x, 'd_x', codeA, hashOf('YYYY'));
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `ⓑ X revoke(맞는 코드여도) = NOT_ELIGIBLE (${r.code})`);
ok((await device('d_x')).status === 'PENDING' && (await device('d_x')).role === 'viewer', 'ⓑ X 기기 = viewer · PENDING 그대로');
ok((await lease()).device_id === 'd_a' && (await lease()).epoch === 1, 'ⓑ 리스 = A · epoch 1 그대로');
const rmSeen = (await as(U.x, () => db.query(`select count(*)::int n from rm_ops_summary`))).rows[0].n;
ok(rmSeen === 0, 'ⓑ X rm_* = 0행');

// ③ ⓐ 새 폰 B(같은 운영자) — O-00 «처음 시작하기» ⑤ 첫 클레임 · A 리스 만료 · A 회수 · 은퇴 전 = 넘기지 않는다
await register(U.op, 'd_b');
r = await claim(U.op, 'd_b', hashOf('BBBB-NEW'));
ok(r.code === 'LEASE_HELD_BY_OTHER' && r.epoch === 1, `ⓐ B claim(A 만료 · ACTIVE) = HELD_BY_OTHER · 지금 epoch 1 (${JSON.stringify(r)})`);
ok((await lease()).device_id === 'd_a' && (await lease()).epoch === 1, 'ⓐ 리스 = A · epoch 1 그대로');
ok((await device('d_b')).status === 'PENDING', 'ⓐ B = PENDING 그대로(operator 로 안 오름)');
ok((await db.query(`select count(*)::int n from recovery_secret`)).rows[0].n === 1, 'ⓐ 첫 클레임 아님 = 해시 안 읽음(행 하나 그대로)');
// 다른 기기 유효 리스 = 거부(전과 같음)
r = await renew(U.op, 'd_a', 1);
ok(r.code === 'LEASE_LOST' && r.epoch === 1, `A renew(만료) = LOST · epoch 1(= 쥔 epoch) (${JSON.stringify(r)})`);
r = await claim(U.op, 'd_a');
ok(r.code === null && r.epoch === 1, `A 같은 기기 되찾음 = epoch 그대로 1 (${JSON.stringify(r)})`);
r = await claim(U.op, 'd_b');
ok(r.code === 'LEASE_HELD_BY_OTHER' && r.epoch === 1, `B claim(A 유효) = HELD_BY_OTHER (${r.code})`);
r = await renew(U.op, 'd_a', 1);
ok(r.code === null && r.epoch === 1, 'A renew(유효) = 성공');

// ④ ⓐ 비상 회수(lease_revoke · 종이 코드) 뒤에만 B 로 — A REVOKED · epoch+1 · B 가 펜싱 뒤 claim = 그 epoch
const codeB = 'NEWB-CODE-2222';
r = await revoke(U.op, 'd_b', 'aaaa bbbb cccc dddd', hashOf(codeB));
ok(r.code === null && r.epoch === 2, `B revoke = epoch 2 (${JSON.stringify(r)})`);
ok((await device('d_a')).status === 'REVOKED', 'A = REVOKED');
r = await renew(U.op, 'd_a', 1);
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `회수된 A renew = NOT_ELIGIBLE (${r.code})`);
r = await claim(U.op, 'd_a');
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `회수된 A claim = NOT_ELIGIBLE (${r.code})`);
r = await claim(U.op, 'd_b');
ok(r.code === null && r.epoch === 2, `B claim(회수 뒤 · 보유 = B) = epoch 2 (${JSON.stringify(r)})`);
ok((await device('d_b')).status === 'ACTIVE' && (await device('d_b')).role === 'operator', 'B = operator ACTIVE');
// 응답 잃은 재시도(같은 기기 재회수) = epoch+1 · 해시 = 새 것(옛 코드 = 그 뒤 틀림)
r = await revoke(U.op, 'd_b', codeA, hashOf('ZZZZ'));
ok(r.code === 'RECOVERY_CODE_INVALID', `쓴 옛 코드 = INVALID (${r.code})`);

// ⑤ ⓐ 은퇴(RETIRED — 계획 이전 device_retire 자리 · 미결 228) 뒤 만료 = 다른 기기로 넘김(epoch+1)
await register(U.op, 'd_c');
await db.exec(`update app_device set status = 'RETIRED' where device_id = 'd_b'`);
await expire();
r = await claim(U.op, 'd_c');
ok(r.code === null && r.epoch === 3, `C claim(B RETIRED · 만료) = epoch 3 (${JSON.stringify(r)})`);
ok((await lease()).device_id === 'd_c', '리스 = C');
// 은퇴했지만 아직 유효 = 넘기지 않음(만료 전)
await register(U.op, 'd_d');
await db.exec(`update app_device set status = 'RETIRED' where device_id = 'd_c'`);
r = await claim(U.op, 'd_d');
ok(r.code === 'LEASE_HELD_BY_OTHER', `D claim(C RETIRED · 유효) = HELD_BY_OTHER (${r.code})`);

// ⑥ ⓑ 뷰어 사용자 V(기기마다 Auth 사용자 — 소유자 = 운영자 · 페어링 행)도 리스를 못 쥔다
await db.exec(`insert into app_device(device_id, label, role, status, owner_uid, auth_uid) values ('d_v', '랩탑', 'viewer', 'ACTIVE', '${U.op}', '${U.v}')`);
await expire();
r = await claim(U.v, 'd_v');
ok(r.code === 'LEASE_DEVICE_NOT_ELIGIBLE', `뷰어 V claim = NOT_ELIGIBLE (${r.code})`);

// ⑦ 로그인 없음 · anon = 거부(전과 같음)
const anonClaim = await (async () => { try { await db.exec(`set role anon`); return (await db.query(`select code from lease_claim('d_a', null)`)).rows[0]; } catch (e) { return { err: e.message }; } finally { await db.exec('reset role'); } })();
ok(anonClaim.err !== undefined, `anon 실행 권한 없음 (${JSON.stringify(anonClaim)})`);

console.log(`PGlite 리스 하네스: ${pass} 통과 · ${fail} 실패`);
process.exit(fail ? 1 : 0);
