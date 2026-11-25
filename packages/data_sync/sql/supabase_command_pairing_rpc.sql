-- ════════════════════════════════════════════════════════════════════════════
-- 뷰어 페어링 RPC · 명령 표 읽는 함수 본문 — pairing_ticket_issue · pairing_claim · pairing_revoke · command_open · command_status
-- (Supabase · Postgres 전용)
-- 설계 13 §8 R272 Y1~Y4(01 §8 미결 246 · 178 · 156 · 182) · 01 §10-8 G-26 · 06 M4-2 · M4-3 · 04 §9-7 ·
-- 계약 v1.41(01 §50) `schema/supabase_rpc.dart` PairingRpc* · CommandReadRpc*(이름 · 인자 · 반환 칸 · 상한) ·
-- `labels/supabase_codes.dart` PairingRpcResultCodes(거부 3) · 배치 D `pairing_ticket` · 명령 표 주석
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 이 파일은 o_07 ① 부트스트랩 묶음의 여섯째 조각이다(⑤ op_push 뒤). 묶음은 적용 뒤 첫 문장에서 멈추고 이주 장치가 없어서
--    뷰어 페어링 · NO_OPERATOR 서버 판정 함수를 첫 판에 함께 싣는다(R272 Y1). 사본 = `supabase_bootstrap_sources.dart`
--    (`python -I tool/make_supabase_bootstrap.py` · 시험이 바이트 대조).
-- 🔴 이름 · 인자 · 반환 칸 · 거부 글자 · 상한 = 계약 그대로(지도 X18) — 본문만 여기서 정한다.
--
-- 쓰는 RPC 셋(security definer · search_path = '' · 실행 = authenticated 만)
--   · 반환 = 언제나 한 행 (code text, epoch bigint, expires_at timestamptz) — 리스 반환 글자 · code = 거부 ∪ null(성공).
--     거부 = LEASE_DEVICE_NOT_ELIGIBLE · LEASE_LOST(발급 · 폐기의 부르는 기기 · 리스 사전 그대로) ·
--            PAIRING_TICKET_INVALID · PAIRING_TICKET_EXPIRED · PAIRING_DEVICE_NOT_ELIGIBLE.
--   · 발급 · 폐기의 기기 · 리스 판정 = op_push 와 같은 문장(부른 사용자의 operator ACTIVE 기기 ∧ 리스 행 = 그 기기 ∧ epoch 같음 ∧
--     만료 전 · 같은 advisory 잠금을 «공유»로 — 리스 RPC 셋이 «배타»로 잡는다).
--   · 발급 = 해시 꼴(16진 64 소문자) ∧ 수명 1~60분(계약 PairingTicketLimits) → 소유자 한 행 바꿔 넣기(쓰지 않은 옛 티켓 무효) ·
--     반환 expires_at = 티켓 만료 시각(서버 now() + 수명).
--   · 클레임 = 부른 사용자(뷰어 Auth 사용자 · D5)의 기기 행 0 ∧ 새 기기 id ∧ 라벨 → 논스 sha256 = 대기 티켓 ∧ 낸 기기 = 아직 operator
--     ACTIVE(비상 회수 · 은퇴 뒤 옛 티켓 무효) → 부른 사용자 ≠ 티켓 소유자 → 만료 전 → 한 트랜잭션: app_device(viewer · ACTIVE ·
--     owner_uid = 티켓 소유자 · auth_uid = 부른 사용자) + 티켓 지움. 같은 티켓 두 클레임 = 티켓 행 잠금으로 하나만.
--   · 폐기 = 대상 = 같은 소유자 viewer 행 → REVOKED(이미 REVOKED = 성공 · 바뀜 0) · 운영 폰 행은 못 바꾼다.
--
-- 읽는 함수 둘(security invoker · stable · RLS 그대로 · 권한 상승 0 · 실행 = authenticated 만)
--   · command_open(p_limit) = 보이는 명령(command_select_own) 가운데 종단 ack(EXECUTED · REJECTED · EXPIRED) 없는 것 ·
--     킬스위치 먼저 → requested_at → command_id · 상한 100(계약 CommandReadLimits · null · 1 미만 · 넘침 = 상한).
--     🔴 리스 보유 판정 0 — 소비기는 리스 원격 확인 뒤에만 부른다(R272 Y5).
--   · command_status(p_command_ids) = 보이는 명령마다 한 행 · 최신 ack(acked_at 내림 · 같으면 종단 먼저 · 그다음 ack_id) 종단 = 그 ack ·
--     아니면 유효 리스(서버 now()) 없음 = NO_OPERATOR · ack 없음 ∧ 유효 리스 = REQUESTED · 비종단 ack ∧ 유효 리스 = 그 ack ·
--     서버가 지은 두 상태의 state_label · ack 칸 = null(글자 = 계약 CommandStatusText · 🔴 SQL 글자 0 — G-26 ⓑ «앱이 두 사실을 조합하지 않는다»).
--     G-26 «security definer» = «서버가 판정한다»의 뜻 — 재료 셋(명령 · ack · 리스)이 부른 사용자에게 다 보여 invoker 로 충분하다(K364).

-- ── pairing_ticket_issue ─────────────────────────────────────────────────────
create or replace function public.pairing_ticket_issue(p_device_id text, p_epoch bigint, p_ticket_nonce_hash text, p_ticket_ttl_minutes int)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_epoch bigint;
  v_exp timestamptz;
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform pg_advisory_xact_lock_shared(1094799692);
  perform 1
     from public.app_device d
    where d.device_id = p_device_id
      and d.auth_uid = v_uid
      and d.owner_uid = v_uid
      and d.role = 'operator'
      and d.status = 'ACTIVE';
  if not found then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select l.epoch into v_epoch
    from public.operator_lease l
   where l.id = 1
     and l.device_id = p_device_id
     and l.epoch = p_epoch
     and l.expires_at > now();
  if not found then
    select l.epoch into v_epoch from public.operator_lease l where l.id = 1;
    return query select 'LEASE_LOST'::text, v_epoch, null::timestamptz;
    return;
  end if;
  if p_ticket_nonce_hash is null or p_ticket_nonce_hash !~ '^[0-9a-f]{64}$'
     or p_ticket_ttl_minutes is null or p_ticket_ttl_minutes < 1 or p_ticket_ttl_minutes > 60 then
    return query select 'PAIRING_TICKET_INVALID'::text, v_epoch, null::timestamptz;
    return;
  end if;
  v_exp := now() + make_interval(mins => p_ticket_ttl_minutes);
  insert into public.pairing_ticket as t (owner_uid, ticket_hash, issued_by_device, issued_at, expires_at)
  values (v_uid, p_ticket_nonce_hash, p_device_id, now(), v_exp)
  on conflict (owner_uid) do update
     set ticket_hash = excluded.ticket_hash, issued_by_device = excluded.issued_by_device,
         issued_at = excluded.issued_at, expires_at = excluded.expires_at;
  return query select null::text, v_epoch, v_exp;
end;
$fn$;

-- ── pairing_claim ────────────────────────────────────────────────────────────
-- 🔴 거부 = 바뀜 0(티켓 · 기기 행 그대로) · 논스 평문은 저장 · 로그 0(해시로만 대조).
create or replace function public.pairing_claim(p_ticket_nonce text, p_device_id text, p_label text, p_platform text)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
  v_exp timestamptz;
begin
  if v_uid is null
     or p_device_id is null or btrim(p_device_id) = ''
     or p_label is null or btrim(p_label) = '' then
    return query select 'PAIRING_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform 1
     from public.app_device d
    where d.auth_uid = v_uid
       or d.device_id = p_device_id;
  if found then
    return query select 'PAIRING_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  if p_ticket_nonce is null or p_ticket_nonce = '' then
    return query select 'PAIRING_TICKET_INVALID'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select t.owner_uid, t.expires_at into v_owner, v_exp
    from public.pairing_ticket t
    join public.app_device i
      on i.device_id = t.issued_by_device
     and i.owner_uid = t.owner_uid
     and i.role = 'operator'
     and i.status = 'ACTIVE'
   where t.ticket_hash = encode(sha256(convert_to(p_ticket_nonce, 'UTF8')), 'hex')
     for update of t;
  if not found then
    return query select 'PAIRING_TICKET_INVALID'::text, null::bigint, null::timestamptz;
    return;
  end if;
  if v_owner = v_uid then
    return query select 'PAIRING_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  if v_exp <= now() then
    return query select 'PAIRING_TICKET_EXPIRED'::text, null::bigint, null::timestamptz;
    return;
  end if;
  begin
    insert into public.app_device (device_id, label, role, status, platform, owner_uid, auth_uid)
    values (p_device_id, btrim(p_label), 'viewer', 'ACTIVE', p_platform, v_owner, v_uid);
  exception
    when unique_violation then
      return query select 'PAIRING_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
      return;
  end;
  delete from public.pairing_ticket t where t.owner_uid = v_owner;
  return query select null::text, null::bigint, null::timestamptz;
end;
$fn$;

-- ── pairing_revoke ───────────────────────────────────────────────────────────
create or replace function public.pairing_revoke(p_device_id text, p_epoch bigint, p_target_device_id text)
returns table (code text, epoch bigint, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_epoch bigint;
  v_status text;
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  perform pg_advisory_xact_lock_shared(1094799692);
  perform 1
     from public.app_device d
    where d.device_id = p_device_id
      and d.auth_uid = v_uid
      and d.owner_uid = v_uid
      and d.role = 'operator'
      and d.status = 'ACTIVE';
  if not found then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, null::timestamptz;
    return;
  end if;
  select l.epoch into v_epoch
    from public.operator_lease l
   where l.id = 1
     and l.device_id = p_device_id
     and l.epoch = p_epoch
     and l.expires_at > now();
  if not found then
    select l.epoch into v_epoch from public.operator_lease l where l.id = 1;
    return query select 'LEASE_LOST'::text, v_epoch, null::timestamptz;
    return;
  end if;
  select d.status into v_status
    from public.app_device d
   where d.device_id = p_target_device_id
     and d.owner_uid = v_uid
     and d.role = 'viewer'
     for update;
  if not found then
    return query select 'PAIRING_DEVICE_NOT_ELIGIBLE'::text, v_epoch, null::timestamptz;
    return;
  end if;
  if v_status <> 'REVOKED' then
    update public.app_device d
       set status = 'REVOKED'
     where d.device_id = p_target_device_id
       and d.owner_uid = v_uid
       and d.role = 'viewer';
  end if;
  return query select null::text, v_epoch, null::timestamptz;
end;
$fn$;

-- ── command_open ─────────────────────────────────────────────────────────────
create or replace function public.command_open(p_limit int)
returns setof public.command_queue
language sql
stable
security invoker
set search_path = ''
as $fn$
  select q.*
    from public.command_queue q
   where not exists (select 1
                       from public.command_ack a
                      where a.command_id = q.command_id
                        and a.state in ('EXECUTED', 'REJECTED', 'EXPIRED'))
   order by (q.kind = 'KILL_SWITCH_ACTIVATE') desc, q.requested_at, q.command_id
   limit (case when p_limit is null or p_limit < 1 or p_limit > 100 then 100 else p_limit end);
$fn$;

-- ── command_status ───────────────────────────────────────────────────────────
create or replace function public.command_status(p_command_ids uuid[])
returns table (command_id uuid, state text, state_label text, reject_reason_code text, decision_id text, acked_at timestamptz)
language sql
stable
security invoker
set search_path = ''
as $fn$
  select q.command_id,
         case when a.terminal then a.state
              when not v.live then 'NO_OPERATOR'
              when a.ack_id is null then 'REQUESTED'
              else a.state end,
         case when a.terminal or v.live then a.state_label end,
         case when a.terminal or v.live then a.reject_reason_code end,
         case when a.terminal or v.live then a.decision_id end,
         case when a.terminal or v.live then a.acked_at end
    from public.command_queue q
   cross join (select exists (select 1 from public.operator_lease l where l.expires_at > now()) as live) v
    left join lateral (
      select k.ack_id, k.state, k.state_label, k.reject_reason_code, k.decision_id, k.acked_at,
             k.state in ('EXECUTED', 'REJECTED', 'EXPIRED') as terminal
        from public.command_ack k
       where k.command_id = q.command_id
       order by k.acked_at desc, (k.state in ('EXECUTED', 'REJECTED', 'EXPIRED')) desc, k.ack_id desc
       limit 1
    ) a on true
   where q.command_id = any (p_command_ids)
   order by array_position(p_command_ids, q.command_id);
$fn$;

revoke all on function public.pairing_ticket_issue(text, bigint, text, int) from public, anon;
revoke all on function public.pairing_claim(text, text, text, text) from public, anon;
revoke all on function public.pairing_revoke(text, bigint, text) from public, anon;
revoke all on function public.command_open(int) from public, anon;
revoke all on function public.command_status(uuid[]) from public, anon;
grant execute on function public.pairing_ticket_issue(text, bigint, text, int) to authenticated;
grant execute on function public.pairing_claim(text, text, text, text) to authenticated;
grant execute on function public.pairing_revoke(text, bigint, text) to authenticated;
grant execute on function public.command_open(int) to authenticated;
grant execute on function public.command_status(uuid[]) to authenticated;
