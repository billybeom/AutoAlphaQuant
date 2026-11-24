-- ════════════════════════════════════════════════════════════════════════════
-- 읽기 모델 push RPC 본문 — rm_push (Supabase · Postgres 전용)
-- 설계 13 §8 R254(E11l2) · 01 §47(계약 v1.38 K330~K337) · 01 §8 미결 222 ⓑ · 06 M4-1 «rm_* 쓰기 = 1개 창구» ·
-- 계약 `schema/supabase_rpc.dart` ReadModelPushRpc*(이름 · 인자 · 반환 칸) · `labels/supabase_codes.dart` ReadModelPushResultCodes(거부 2)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 이 파일은 o_07 ① 부트스트랩 묶음의 넷째 조각이다(① 배치 D · ② 리스 RPC · ③ rm_* 생성기 뒤 — 쓰는 표가 다 선 다음).
--    사본 = `supabase_bootstrap_sources.dart`(`python -I tool/make_supabase_bootstrap.py` · 시험이 바이트 대조).
-- 🔴 이름 · 인자 · 반환 칸 · 거부 글자 = 계약 그대로(지도 X18) — 본문만 여기서 정한다.
--
-- 규칙(01 §47 K332 ~ K335)
--   · 반환 = 언제나 한 행 (code text, epoch bigint, accepted integer, skipped integer) — code = 거부 ∪ null(성공).
--     거부 = LEASE_DEVICE_NOT_ELIGIBLE · LEASE_LOST(리스 사전 그대로) · READ_MODEL_TABLE_UNKNOWN · READ_MODEL_ROWS_INVALID.
--   · 기기 = 부른 사용자의 그 기기(auth_uid = owner_uid = auth.uid()) ∧ role 'operator' ∧ status 'ACTIVE' — 뷰어 · REVOKED · RETIRED = 거부.
--   · 리스 = operator_lease 단일 행이 그 기기 ∧ epoch = p_epoch ∧ 만료 전 — 아니면 LEASE_LOST(지금 epoch).
--     🔴 리스 RPC 와 같은 advisory 잠금을 «공유»로 잡는다 — push 끼리는 겹쳐도 되고, 리스가 넘어가는 동안(배타)에는 기다린다.
--   · 표 = 아래 22 이름(계약 `ReadModelTables` 차례 그대로 · 시험이 대조) 중 하나 — 동적 SQL 은 이 목록 안 이름만 · 열은 카탈로그에서.
--   · 행 = JSON 배열(빈 배열 = 0행 성공) · 열 이름 키 · lease_epoch = p_epoch · pushed_at = now() 로 덮어쓴다(행 값 무시).
--   · 한 호출 = 한 트랜잭션 — 행 하나라도 형 · 기본 키 · not null · check 위반(또는 같은 키 두 번) = READ_MODEL_ROWS_INVALID · 0행.
--   · 기본 키 충돌 = row_version 이 큰 행만 바꾼다(같거나 작으면 건너뜀 = skipped) · 삭제 0.
--   · security definer · search_path = '' · 실행 권한 = authenticated 만(anon · public 회수).

create or replace function public.rm_push(p_device_id text, p_epoch bigint, p_table text, p_rows jsonb)
returns table (code text, epoch bigint, accepted integer, skipped integer)
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_uid uuid := auth.uid();
  v_epoch bigint;
  v_rel regclass;
  v_keys text;
  v_cols text;
  v_sel text;
  v_set text;
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
      'rm_journal', 'rm_holding', 'rm_performance_point', 'rm_performance_series', 'rm_rebalance_event',
      'rm_alert', 'rm_safety_state', 'rm_config_view', 'rm_advice', 'rm_advice_summary', 'rm_monthly_report',
      'rm_report_archive', 'rm_ledger_diff', 'rm_sleeve_allocation', 'rm_perf_context', 'rm_disclosure_view',
      'rm_ops_summary', 'rm_ledger_trust', 'rm_execution_gap', 'rm_blind_review', 'rm_watchdog', 'rm_list_envelope'
    ])) then
    return query select 'READ_MODEL_TABLE_UNKNOWN'::text, v_epoch, 0, 0;
    return;
  end if;
  if p_rows is null or jsonb_typeof(p_rows) <> 'array' then
    return query select 'READ_MODEL_ROWS_INVALID'::text, v_epoch, 0, 0;
    return;
  end if;
  v_total := jsonb_array_length(p_rows);
  if v_total = 0 then
    return query select null::text, v_epoch, 0, 0;
    return;
  end if;
  v_rel := to_regclass('public.' || quote_ident(p_table));
  if v_rel is null then
    return query select 'READ_MODEL_TABLE_UNKNOWN'::text, v_epoch, 0, 0;
    return;
  end if;
  select string_agg(quote_ident(a.attname), ', ' order by array_position(i.indkey::int2[], a.attnum))
    into v_keys
    from pg_catalog.pg_index i
    join pg_catalog.pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey::int2[])
   where i.indrelid = v_rel and i.indisprimary;
  select string_agg(quote_ident(a.attname), ', ' order by a.attnum),
         string_agg(case a.attname
                      when 'lease_epoch' then '$2'
                      when 'pushed_at' then 'now()'
                      else 'r.' || quote_ident(a.attname)
                    end, ', ' order by a.attnum),
         string_agg(format('%1$I = excluded.%1$I', a.attname), ', ' order by a.attnum)
           filter (where not exists (select 1 from pg_catalog.pg_index i
                                      where i.indrelid = v_rel and i.indisprimary
                                        and a.attnum = any (i.indkey::int2[])))
    into v_cols, v_sel, v_set
    from pg_catalog.pg_attribute a
   where a.attrelid = v_rel and a.attnum > 0 and not a.attisdropped;
  begin
    execute format(
      'insert into public.%1$I as t (%2$s) select %3$s from pg_catalog.jsonb_populate_recordset(null::public.%1$I, $1) r '
      || 'on conflict (%4$s) do update set %5$s where t.row_version < excluded.row_version',
      p_table, v_cols, v_sel, v_keys, v_set)
    using p_rows, p_epoch;
    get diagnostics v_done = row_count;
  exception
    when data_exception or integrity_constraint_violation or cardinality_violation then
      return query select 'READ_MODEL_ROWS_INVALID'::text, v_epoch, 0, 0;
      return;
  end;
  return query select null::text, v_epoch, v_done, v_total - v_done;
end;
$fn$;

revoke all on function public.rm_push(text, bigint, text, jsonb) from public, anon;
grant execute on function public.rm_push(text, bigint, text, jsonb) to authenticated;
