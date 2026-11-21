-- ════════════════════════════════════════════════════════════════════════════
-- operator 리스 RPC 본문 — lease_claim · lease_renew · lease_revoke (Supabase · Postgres 전용)
-- 설계 13 §8 R221(E11k-e2) · 06 M4-3 · 01 §6-4 «리스 RPC 표»(계약 v1.29 §39 K228 · K229) ·
-- 계약 `schema/supabase_rpc.dart`(이름 · 인자 · 반환 칸) · `labels/supabase_codes.dart` `LeaseRpcResultCodes`(거부 5)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 이 파일은 o_07 ① 부트스트랩 묶음의 둘째 조각이다(첫째 = 계약 사본 `batch_d_supabase.sql` 원문 ·
--    셋째 = E11l1 `rm_*` 생성기). 묶음 = data_sync `supabase_bootstrap.dart` · 사본 = `supabase_bootstrap_sources.dart`
--    (`python -I tool/make_supabase_bootstrap.py` 로 다시 만든다 — 시험이 이 파일과 바이트 대조한다).
-- 🔴 이름 · 인자 · 반환 칸 · 거부 글자는 계약 그대로다(엔진 · SQL 이 각자 짓지 않는다 — 지도 X18). 본문만 여기서 정한다.
--
-- 공통 규칙
--   · 반환 = 언제나 한 행 (code text, epoch bigint, expires_at timestamptz) — code = 거부 코드 ∪ null(성공).
--     🔴 거부는 이 한 행의 code 로만 알린다(예외 · HTTP 상태로 알리지 않는다 — 클라이언트는 HTTP 상태로 코드를 짓지 않는다).
--   · 시각 = 서버 now()(트랜잭션 시작 시각) · T = 30분(서버 상수 · 엔진 `kLeaseTtl` · R43 D3) · 🔴 server_now RPC 0(T1).
--   · 🔴 조건부 쓰기(CAS)만 — 모든 갱신은 «읽은 epoch · 보유 기기» 를 WHERE 에 걸고 바뀐 행 수 1 을 확인한다.
--     + 세 RPC 가 같은 트랜잭션 잠금(pg_advisory_xact_lock)을 먼저 잡는다 — 빈 표(첫 클레임)에는 잠글 행이 없어서다.
--     → 동시 클레임 2건 = 하나가 끝난 뒤 다른 하나가 그 결과를 읽는다(2건 중 1건만 성공 · 실 프로젝트 실측 = E11k-f).
--   · 부르는 기기 판정(D5) = app_device 행의 auth_uid = auth.uid() ∧ owner_uid = auth.uid()(운영 사용자의 기기) ∧
--     status ∉ {REVOKED, RETIRED} — 아니면 LEASE_DEVICE_NOT_ELIGIBLE(epoch · expires_at = null).
--     🔴 JWT app_metadata 에 기대지 않는다 · 뷰어 기기(auth_uid ≠ owner_uid)는 리스를 쥘 수 없다.
--   · security definer · search_path = '' (모든 이름을 스키마로 적는다) · 실행 권한 = authenticated 만(anon · public 회수).
--
-- 복구 코드 해시(R221 — 이 판이 정한다 · 클라이언트 = data_sync `supabase_recovery_code.dart` · 발급 = E11k-e3)
--   · 꼴 = 'sha256:<소금 16진 32>:<요약 16진 64>' · 요약 = sha256(UTF-8(<소금 16진> || ':' || <정규화 코드>))
--   · 정규화 = 영숫자만 남기고 대문자(종이에 옮겨 적은 띄어쓰기 · 하이픈을 지운다).
--   · 🔴 Postgres 내장 sha256() 만 쓴다(확장 0 — pgsodium = Supabase 폐기 예정 · pgcrypto 에는 argon2 가 없다).
--     빠른 해시로 충분한 까닭 = 복구 코드는 사람이 고른 낱말이 아니라 기기가 뽑는 무작위 ≥ 100비트(E11k-e3 몫)이고
--     recovery_secret 에는 SELECT 정책이 없다(검증은 이 RPC 안에서만).
--   · recovery_secret.algo = 'sha256' 을 RPC 가 적는다(DDL 기본값 'argon2id' 는 쓰이지 않는다 — 계약 창 정리 제안).

-- ── lease_claim ──────────────────────────────────────────────────────────────
-- 빈 행 = 첫 클레임 → p_recovery_code_hash 필수(없음 · 꼴 아님 = RECOVERY_CODE_REQUIRED) · 리스 행 + recovery_secret 를
-- 같은 트랜잭션에 · epoch 1. 행 있음 → 보유 기기 = 이 기기 ∨ 만료 → 이 기기(다른 기기에서 넘어옴 = epoch+1 · 같은 기기 = 그대로) ·
-- 다른 기기 유효 = LEASE_HELD_BY_OTHER(지금 epoch · expires_at). 성공 = 이 기기 role='operator' · status='ACTIVE'.
-- 🔴 첫 클레임이 아니면 p_recovery_code_hash 는 읽지 않는다(복구 코드를 클레임으로 갈아 끼울 수 없다 — 교체 = lease_revoke 만).
create or replace function public.lease_claim(p_device_id text, p_recovery_code_hash text default null)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
  v_holder text;
  v_epoch bigint;
  v_exp timestamptz;
  v_new_epoch bigint;
  v_new_exp timestamptz := now() + interval '30 minutes';
  v_rows int;
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform pg_advisory_xact_lock(1094799692);  -- 0x4141514C «AAQL» — 리스 RPC 셋이 같이 쓴다
  select d.owner_uid into v_owner
    from public.app_device d
   where d.device_id = p_device_id
     and d.auth_uid = v_uid
     and d.owner_uid = v_uid
     and d.status not in ('REVOKED', 'RETIRED');
  if not found then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select l.device_id, l.epoch, l.expires_at into v_holder, v_epoch, v_exp
    from public.operator_lease l
   where l.id = 1
     for update;
  if not found then
    -- 첫 클레임 — 🔴 복구 코드 해시가 같은 트랜잭션에 들어가야 리스가 선다.
    if p_recovery_code_hash is null
       or p_recovery_code_hash !~ '^sha256:[0-9a-f]{32}:[0-9a-f]{64}$' then
      return query select 'RECOVERY_CODE_REQUIRED'::text, null::bigint, null::timestamptz;
      return;
    end if;
    insert into public.operator_lease (id, device_id, epoch, expires_at, updated_at)
    values (1, p_device_id, 1, v_new_exp, now())
    on conflict (id) do nothing;
    get diagnostics v_rows = row_count;
    if v_rows <> 1 then
      -- CAS 실패(잠금을 쥔 채로는 생기지 않는다 · 생기면 거부 쪽).
      return query select 'LEASE_HELD_BY_OTHER'::text, null::bigint, null::timestamptz;
      return;
    end if;
    insert into public.recovery_secret (owner_uid, code_hash, algo, created_at, used_at)
    values (v_owner, p_recovery_code_hash, 'sha256', now(), null)
    on conflict (owner_uid) do update
      set code_hash = excluded.code_hash, algo = excluded.algo, created_at = excluded.created_at, used_at = null;
    v_new_epoch := 1;
  elsif v_holder = p_device_id or v_exp <= now() then
    v_new_epoch := case when v_holder = p_device_id then v_epoch else v_epoch + 1 end;
    update public.operator_lease l
       set device_id = p_device_id, epoch = v_new_epoch, expires_at = v_new_exp, updated_at = now()
     where l.id = 1 and l.epoch = v_epoch and l.device_id = v_holder;
    get diagnostics v_rows = row_count;
    if v_rows <> 1 then
      return query select 'LEASE_HELD_BY_OTHER'::text, v_epoch, v_exp;
      return;
    end if;
  else
    return query select 'LEASE_HELD_BY_OTHER'::text, v_epoch, v_exp;
    return;
  end if;
  update public.app_device d
     set role = 'operator', status = 'ACTIVE', last_seen_at = now()
   where d.device_id = p_device_id;
  return query select null::text, v_new_epoch, v_new_exp;
end;
$fn$;

-- ── lease_renew ──────────────────────────────────────────────────────────────
-- 보유 기기 = 이 기기 ∧ epoch = p_epoch ∧ 만료 전 → expires_at = now() + T(epoch 그대로) · 아니면 LEASE_LOST
-- (지금 epoch · expires_at — 행이 없으면 null). 🔴 만료 뒤 되찾기 = 클라이언트가 lease_claim 을 한 번 더(E11k-e1 · R215 E5).
create or replace function public.lease_renew(p_device_id text, p_epoch bigint)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_epoch bigint;
  v_exp timestamptz;
  v_new_exp timestamptz := now() + interval '30 minutes';
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform pg_advisory_xact_lock(1094799692);
  perform 1
     from public.app_device d
    where d.device_id = p_device_id
      and d.auth_uid = v_uid
      and d.owner_uid = v_uid
      and d.status not in ('REVOKED', 'RETIRED');
  if not found then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  update public.operator_lease l
     set expires_at = v_new_exp, updated_at = now()
   where l.id = 1
     and l.device_id = p_device_id
     and l.epoch = p_epoch
     and l.expires_at > now()
  returning l.epoch into v_epoch;
  if not found then
    select l.epoch, l.expires_at into v_epoch, v_exp from public.operator_lease l where l.id = 1;
    return query select 'LEASE_LOST'::text, v_epoch, v_exp;
    return;
  end if;
  update public.app_device d set last_seen_at = now() where d.device_id = p_device_id;
  return query select null::text, v_epoch, v_new_exp;
end;
$fn$;

-- ── lease_revoke ─────────────────────────────────────────────────────────────
-- 비상(X1-3 ①) — 부르는 기기(새 폰)가 복구 코드를 낸다. 대조(틀림 · 쓴 코드 · 해시 없음 · 리스 행 없음 = RECOVERY_CODE_INVALID) →
-- 같은 트랜잭션: epoch+1 · device_id = 부른 기기 · expires_at = now()(즉시 만료 — 새 폰은 펜싱 대기 뒤 lease_claim) ·
-- 옛 보유 기기 status='REVOKED'(부른 기기 자신이면 그대로) · recovery_secret 해시 = p_new_recovery_code_hash(쓴 코드 = 그 뒤 «틀림»).
-- 🔴 p_new_recovery_code_hash 꼴 아님 = RECOVERY_CODE_REQUIRED(대조 전 · 아무것도 바꾸지 않는다).
-- 🔴 p_recovery_code(평문)는 대조에만 쓴다 — 저장 · 기록 0.
create or replace function public.lease_revoke(p_device_id text, p_recovery_code text, p_new_recovery_code_hash text)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
  v_hash text;
  v_norm text;
  v_holder text;
  v_epoch bigint;
  v_rows int;
  v_now timestamptz := now();
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform pg_advisory_xact_lock(1094799692);
  select d.owner_uid into v_owner
    from public.app_device d
   where d.device_id = p_device_id
     and d.auth_uid = v_uid
     and d.owner_uid = v_uid
     and d.status not in ('REVOKED', 'RETIRED');
  if not found then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  if p_new_recovery_code_hash is null
     or p_new_recovery_code_hash !~ '^sha256:[0-9a-f]{32}:[0-9a-f]{64}$' then
    return query select 'RECOVERY_CODE_REQUIRED'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select r.code_hash into v_hash
    from public.recovery_secret r
   where r.owner_uid = v_owner
     for update;
  v_norm := upper(regexp_replace(coalesce(p_recovery_code, ''), '[^0-9A-Za-z]', '', 'g'));
  if v_hash is null
     or v_norm = ''
     or v_hash !~ '^sha256:[0-9a-f]{32}:[0-9a-f]{64}$'
     or encode(sha256(convert_to(split_part(v_hash, ':', 2) || ':' || v_norm, 'UTF8')), 'hex')
        <> split_part(v_hash, ':', 3) then
    return query select 'RECOVERY_CODE_INVALID'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select l.device_id, l.epoch into v_holder, v_epoch
    from public.operator_lease l
   where l.id = 1
     for update;
  if not found then
    return query select 'RECOVERY_CODE_INVALID'::text, null::bigint, null::timestamptz;
    return;
  end if;
  update public.operator_lease l
     set device_id = p_device_id, epoch = v_epoch + 1, expires_at = v_now, updated_at = v_now
   where l.id = 1 and l.epoch = v_epoch and l.device_id = v_holder;
  get diagnostics v_rows = row_count;
  if v_rows <> 1 then
    return query select 'LEASE_HELD_BY_OTHER'::text, v_epoch, null::timestamptz;
    return;
  end if;
  update public.app_device d
     set status = 'REVOKED'
   where d.device_id = v_holder
     and d.device_id <> p_device_id;
  update public.recovery_secret r
     set code_hash = p_new_recovery_code_hash, algo = 'sha256', created_at = v_now, used_at = null
   where r.owner_uid = v_owner;
  return query select null::text, v_epoch + 1, v_now;
end;
$fn$;

-- ── 실행 권한 — 🔴 로그인한 사용자만(anon · public 회수 · Supabase 기본 권한이 anon 에도 준다) ──────────
revoke all on function public.lease_claim(text, text) from public, anon;
revoke all on function public.lease_renew(text, bigint) from public, anon;
revoke all on function public.lease_revoke(text, text, text) from public, anon;
grant execute on function public.lease_claim(text, text) to authenticated;
grant execute on function public.lease_renew(text, bigint) to authenticated;
grant execute on function public.lease_revoke(text, text, text) to authenticated;
