-- ════════════════════════════════════════════════════════════════════════════
-- 운영 폰 공유 표 push RPC 본문 — op_push (Supabase · Postgres 전용)
-- 설계 13 §8 R270(01 §8 미결 229 · 222 ⓕ) · 06 M4-1 «쓰기 = security definer RPC · 클라이언트 upsert 0» · 06 X2-7 ·
-- 계약 v1.40(01 §49) `schema/supabase_rpc.dart` OpsPushRpc* · OpsPushTables(이름 · 인자 · 반환 칸 · 표 5) ·
-- `labels/supabase_codes.dart` OpsPushResultCodes(거부 2) · 배치 D 다섯 표 select 본문 · 머리 주석
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 이 파일은 o_07 ① 부트스트랩 묶음의 다섯째 조각이다(④ rm_push 뒤). o_07 ① 뒤에 함수를 더하면 «판 올림 = 이주 SQL» 이라
--    배치 D 의 rm_* 밖 쓰기 표 다섯의 길을 첫 판에 함께 싣는다. 사본 = `supabase_bootstrap_sources.dart`
--    (`python -I tool/make_supabase_bootstrap.py` · 시험이 바이트 대조).
-- 🔴 이름 · 인자 · 반환 칸 · 거부 글자 = 계약 그대로(지도 X18) — 본문만 여기서 정한다.
--
-- 판독(R270) — 다섯 표 모두 «운영 폰 엔진 · 리스 보유자»만 쓴다(뷰어 · 서버 쓰기 0):
--   command_ack          = 명령 소비(E11m) — 상태가 바뀔 때마다 한 행 · append-only(ack_id 키 · 명령당 여러 행)
--   planned_work_mirror  = X2 작업 원장 미러(digest + 한 줄 · 원문 0) — row_version 큰 쪽
--   resume_run_mirror    = X2 재개 회차 미러 — 마지막 보낸 값(판 칸 없음 · 쓰는 기기 하나)
--   ledger_stamp         = X5 canonSupabase 파생 스탬프 — 같은 날 다시 씀(재생성) · operator_epoch = 쓴 기기 epoch(FORK 재료)
--   calendar_sync_status = X4 캘린더 동기 상태(모드마다 한 행)
--   rm_push(④)로 받지 않는 까닭 = 열 관례가 다르다(row_version 없는 표 2 · 시각 칸 updated_at/stamped_at/acked_at · epoch 칸
--   operator_epoch) · rm_push 표 목록 = 계약 ReadModelTables 22 그대로(C-71) · 거부 글자 READ_MODEL_*.
--
-- 규칙
--   · 반환 = 언제나 한 행 (code text, epoch bigint, accepted integer, skipped integer) — code = 거부 ∪ null(성공).
--     거부 = LEASE_DEVICE_NOT_ELIGIBLE · LEASE_LOST(리스 사전 그대로) · OPS_PUSH_TABLE_UNKNOWN · OPS_PUSH_ROWS_INVALID.
--   · 기기 · 리스 판정 = rm_push 와 같다 — 부른 사용자의 그 기기(auth_uid = owner_uid = auth.uid()) ∧ role 'operator' ∧
--     status 'ACTIVE' · operator_lease 단일 행이 그 기기 ∧ epoch = p_epoch ∧ 만료 전(lease_renew 축) · 같은 advisory 잠금을 «공유»로.
--   · 표 = 아래 다섯(계약 표 목록 차례 그대로 · 시험이 대조) — 🔴 표마다 정적 SQL(동적 SQL 0 · 열 = 이 파일에 이름으로).
--   · 행 = JSON 배열(빈 배열 = 0행 성공) · 열 이름 키 · 🔴 서버가 덮는 칸(행 값 무시): epoch 칸(lease_epoch · operator_epoch) = p_epoch ·
--     시각 칸(acked_at · updated_at · stamped_at) = now().
--   · 한 호출 = 한 트랜잭션 — 행 하나라도 형 · 기본 키 · not null · check · 참조 위반(또는 같은 키 두 번) = OPS_PUSH_ROWS_INVALID · 0행.
--   · 표마다 충돌 규칙:
--       command_ack          = 🔴 append-only — 같은 ack_id = 건너뜀(skipped · 바꾸지 않는다) · command_id = 부른 사용자의 명령만
--                              (command_queue.owner_uid = auth.uid() · 아니면 ROWS_INVALID) · 한 호출에 같은 command_id 두 번 = ROWS_INVALID
--                              (acked_at = 트랜잭션 시각 하나 — 한 명령의 두 상태가 같은 시각이면 뷰어가 차례를 못 가른다).
--       planned_work_mirror  = row_version 이 큰 행만 바꾼다(같거나 작으면 skipped · 규칙 5조 ②).
--       resume_run_mirror    = 덮는다(마지막 보낸 값).
--       ledger_stamp         = 덮는다(재생성 = 같은 날 다시 씀 · 판정 = 엔진 derivedSyncActionOf · 리스 판정이 낮은 epoch 쓰기를 막는다).
--       calendar_sync_status = 덮는다.
--   · 삭제 0 · security definer · search_path = '' · 실행 권한 = authenticated 만(anon · public 회수).

create or replace function public.op_push(p_device_id text, p_epoch bigint, p_table text, p_rows jsonb)
returns table (code text, epoch bigint, accepted integer, skipped integer)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_epoch bigint;
  v_total integer;
  v_done integer;
begin
  if v_uid is null then
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, 0, 0;
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
    return query select 'LEASE_DEVICE_NOT_ELIGIBLE'::text, null::bigint, 0, 0;
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
    return query select 'LEASE_LOST'::text, v_epoch, 0, 0;
    return;
  end if;
  if p_table is null or not (p_table = any (array[
      'command_ack', 'planned_work_mirror', 'resume_run_mirror', 'ledger_stamp', 'calendar_sync_status'
    ])) then
    return query select 'OPS_PUSH_TABLE_UNKNOWN'::text, v_epoch, 0, 0;
    return;
  end if;
  if p_rows is null or jsonb_typeof(p_rows) <> 'array' then
    return query select 'OPS_PUSH_ROWS_INVALID'::text, v_epoch, 0, 0;
    return;
  end if;
  v_total := jsonb_array_length(p_rows);
  if v_total = 0 then
    return query select null::text, v_epoch, 0, 0;
    return;
  end if;
  begin
    if p_table = 'command_ack' then
      if exists (
        select 1
          from pg_catalog.jsonb_populate_recordset(null::public.command_ack, p_rows) r
         where not exists (select 1 from public.command_queue q
                            where q.command_id = r.command_id and q.owner_uid = v_uid)
      ) or exists (
        select 1
          from pg_catalog.jsonb_populate_recordset(null::public.command_ack, p_rows) r
         group by r.command_id
        having count(*) > 1
      ) then
        return query select 'OPS_PUSH_ROWS_INVALID'::text, v_epoch, 0, 0;
        return;
      end if;
      insert into public.command_ack as t
             (ack_id, command_id, state, state_label, reject_reason_code, decision_id, lease_epoch, acked_at)
      select r.ack_id, r.command_id, r.state, r.state_label, r.reject_reason_code, r.decision_id, p_epoch, now()
        from pg_catalog.jsonb_populate_recordset(null::public.command_ack, p_rows) r
      on conflict (ack_id) do nothing;
    elsif p_table = 'planned_work_mirror' then
      insert into public.planned_work_mirror as t
             (work_id, mode, digest, one_line, due_by, state, row_version, lease_epoch, updated_at)
      select r.work_id, r.mode, r.digest, r.one_line, r.due_by, r.state, r.row_version, p_epoch, now()
        from pg_catalog.jsonb_populate_recordset(null::public.planned_work_mirror, p_rows) r
      on conflict (work_id) do update
         set mode = excluded.mode, digest = excluded.digest, one_line = excluded.one_line, due_by = excluded.due_by,
             state = excluded.state, row_version = excluded.row_version, lease_epoch = excluded.lease_epoch,
             updated_at = excluded.updated_at
       where t.row_version < excluded.row_version;
    elsif p_table = 'resume_run_mirror' then
      insert into public.resume_run_mirror as t
             (resume_run_id, gap_trading_days, mode, resume_mode, phase, headline, updated_at)
      select r.resume_run_id, r.gap_trading_days, r.mode, r.resume_mode, r.phase, r.headline, now()
        from pg_catalog.jsonb_populate_recordset(null::public.resume_run_mirror, p_rows) r
      on conflict (resume_run_id) do update
         set gap_trading_days = excluded.gap_trading_days, mode = excluded.mode, resume_mode = excluded.resume_mode,
             phase = excluded.phase, headline = excluded.headline, updated_at = excluded.updated_at;
    elsif p_table = 'ledger_stamp' then
      insert into public.ledger_stamp as t
             (mode, authored_date, chain_hash, operator_epoch, stamped_at)
      select r.mode, r.authored_date, r.chain_hash, p_epoch, now()
        from pg_catalog.jsonb_populate_recordset(null::public.ledger_stamp, p_rows) r
      on conflict (mode, authored_date) do update
         set chain_hash = excluded.chain_hash, operator_epoch = excluded.operator_epoch, stamped_at = excluded.stamped_at;
    else
      insert into public.calendar_sync_status as t
             (mode, last_ok_date, status, quarantined_count, updated_at)
      select r.mode, r.last_ok_date, r.status, r.quarantined_count, now()
        from pg_catalog.jsonb_populate_recordset(null::public.calendar_sync_status, p_rows) r
      on conflict (mode) do update
         set last_ok_date = excluded.last_ok_date, status = excluded.status,
             quarantined_count = excluded.quarantined_count, updated_at = excluded.updated_at;
    end if;
    get diagnostics v_done = row_count;
  exception
    when data_exception or integrity_constraint_violation or cardinality_violation then
      return query select 'OPS_PUSH_ROWS_INVALID'::text, v_epoch, 0, 0;
      return;
  end;
  return query select null::text, v_epoch, v_done, v_total - v_done;
end;
$fn$;

revoke all on function public.op_push(text, bigint, text, jsonb) from public, anon;
grant execute on function public.op_push(text, bigint, text, jsonb) to authenticated;
