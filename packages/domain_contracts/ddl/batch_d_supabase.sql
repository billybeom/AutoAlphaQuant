-- ════════════════════════════════════════════════════════════════════════════
-- 배치 D — Supabase(Postgres) 공유 계층
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-4 (+ §6-6 말미 «배치 D 추가분»)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 **여기가 정본이 아니다.** 정본은 폰의 로컬 SQLite 이고, Supabase 는
--    ① 읽기 모델 사본 ② 기기·리스 원장 ③ **뷰어 쓰기의 유일한 경로**(명령 표)를 담는다.
-- 🔴 스키마 부트스트랩은 앱이 이 SQL 텍스트를 표시하고 발주자가 SQL 에디터에 붙여넣는 방식이다
--    (X3 권고 ⑨ — `service_role` 키 미보관). 🔴 **이 SQL 이 그대로 운영 DB 다.**
-- 🔴 적용 순서(§6-5) = ④ Supabase RLS → ⑤ Supabase `mode` 키 + 전량 재push. 창의 마지막이다.
-- 🔴 이 파일은 **Postgres 전용**이다. 로컬 SQLite 는 batch_a~c·f 를 쓴다.

-- ── 기기 원장 (X3) ───────────────────────────────────────────────────────────
create table if not exists app_device (
  device_id     text primary key,
  label         text not null,                    -- 기기 표시 라벨(엔진·사람이 지은 별칭)
  role          text not null check (role in ('operator','viewer')),
  status        text not null check (status in ('PENDING','ACTIVE','RETIRED','REVOKED')),
  platform      text,
  paired_at     timestamptz not null default now(),
  last_seen_at  timestamptz,
  owner_uid     uuid not null references auth.users(id)
);
-- 🔴 최초 INSERT 는 role='viewer' · status='PENDING' 강제. operator 승격은 리스 RPC(서버)만
alter table app_device enable row level security;
create policy device_insert_viewer_only on app_device for insert to authenticated
  with check (owner_uid = auth.uid() and role = 'viewer' and status = 'PENDING');
create policy device_select_own on app_device for select to authenticated
  using (owner_uid = auth.uid());

-- ── operator 리스 (X1·X3) — 🔴 단일 행. 쓰기는 RPC(CAS)만, 직접 UPDATE 정책 없음 ─────
create table if not exists operator_lease (
  id            int primary key default 1 check (id = 1),
  device_id     text not null references app_device(device_id),
  epoch         bigint not null,                  -- 🔴 세대번호. 비상 펜싱 시 강제 +1
  expires_at    timestamptz not null,             -- TTL (Q-B 권고 T=30분)
  updated_at    timestamptz not null default now()
);
alter table operator_lease enable row level security;
create policy lease_select on operator_lease for select to authenticated using (true);
-- 🔴 claim/renew/revoke 는 security definer RPC. 클라이언트 UPDATE·DELETE 정책은 만들지 않는다

-- ── 복구 코드 (X3) — 🔴 해시만. 평문은 종이(복구 카드)에만 존재 ─────────────────────
create table if not exists recovery_secret (
  owner_uid     uuid primary key references auth.users(id),
  code_hash     text not null,
  algo          text not null default 'argon2id',
  created_at    timestamptz not null default now(),
  used_at       timestamptz
);
alter table recovery_secret enable row level security;
-- 🔴 SELECT 정책 없음 — 검증은 RPC 안에서만 수행한다

-- ── 명령·이벤트 테이블 (Q-C 권고 a) — 🔴 뷰어 쓰기의 유일한 경로. append-only ────────
-- 🔴 `kind` CHECK 는 §6-6 말미 «배치 D 추가분»의 X7 7종을 **이미 반영**한 형태다
--    (신규 생성이므로 재작성이 필요 없다 — 기존 표가 있는 설치는 이 파일 맨 아래 §D-add 를 쓴다).
-- 🔴 **명령 표의 모드 축은 `run_mode` 하나다**(N-02) — 규칙 5조 ①의 `mode` 컬럼은 `rm_*` 전용이며
--    `command_queue`·`command_ack` 에는 **붙이지 않는다**. 같은 축의 컬럼을 둘 두면 둘이 갈리는 날
--    SIM 명령이 LIVE 엔진에 소비된다.
create table if not exists command_queue (
  command_id        uuid primary key,             -- 클라이언트 생성(멱등키)
  kind              text not null check (kind in
                     ('KILL_SWITCH_ACTIVATE','JOURNAL_DRAFT','BLIND_REVIEW_SCORE',
                      'DISCLOSURE_VIEW','DEPOSIT_REGISTER',
                      -- 🆕 X7 7종 — 🔴 Dart 이름과 **어순이 뒤집혀 있다**
                      --    (`manualFillRecord` ↔ 'RECORD_MANUAL_FILL' · m2-8_naming B-3)
                      'RECORD_MANUAL_FILL','AMEND_MANUAL_FILL','VOID_MANUAL_FILL',
                      'SKIP_ADVICE','SELF_REPORT_BALANCE','ALERT_ACK',
                      'KILL_CHECKLIST_CONFIRM',
                      -- 🆕 v1.10 ㊲ 원장 사건(X7 8번째 · operator 전용 · 설계 13 §8 R21)
                      'LEDGER_EVENT_RECORD')),
  payload           jsonb not null,               -- 🔴 시크릿·계좌 전체번호 금지(CI 스캔 대상)
  issued_by_device  text not null references app_device(device_id),
  nonce             text not null,
  requested_at      timestamptz not null default now(),
  expires_at        timestamptz not null,
  owner_uid         uuid not null references auth.users(id),
  run_mode          text,                         -- 🆕 A10 — 🔴 발행 시점 맥락
  operating_mode    text,
  lease_epoch       bigint,
  unique (kind, nonce)
);
alter table command_queue enable row level security;
-- 🔴 RLS 는 **소유자가 아니라 `role` 클레임 기준**이다(청사진 X3 보강). owner_uid 만 보면 뷰어가
--    승인된 4종(Q-C: 킬스위치·저널 초안·blind 리뷰·열람 이벤트) 밖인 DEPOSIT_REGISTER 까지 넣을 수 있다.
--    🔴 DEPOSIT_REGISTER 는 **폰(operator) 전용**이다 — 입금 등록은 계획 스냅샷 바인딩이라 뷰어 경로가 없다.
-- 🔴 신규 X7 7종 + 🆕 v1.10 `LEDGER_EVENT_RECORD`(㉕ 폰 전용)는 **`command_insert_operator` 정책에만** 들어간다.
--    `command_insert_viewer` 의 4종 화이트리스트는 **그대로 둔다**
--    (⚠️ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이며 m2-8_naming J-3 은 «허용하지 않는다» ⏸ 권고).
create policy command_insert_viewer on command_queue for insert to authenticated
  with check (
    owner_uid = auth.uid() and expires_at > now()
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'viewer'
    and kind in ('KILL_SWITCH_ACTIVATE','JOURNAL_DRAFT','BLIND_REVIEW_SCORE','DISCLOSURE_VIEW')
  );
create policy command_insert_operator on command_queue for insert to authenticated
  with check (
    owner_uid = auth.uid() and expires_at > now()
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'operator'
  );
create policy command_select_own on command_queue for select to authenticated
  using (owner_uid = auth.uid());
-- 🔴 UPDATE·DELETE 정책 없음 = append-only 가 DB 로 강제된다
-- ⚠️ `role` 클레임을 어디에 싣는가(app_metadata vs 커스텀 클레임 RPC)는 M4-2 에서 확정한다.
--    확정 전까지 이 두 정책의 **분리 자체**가 계약이며, 하나로 합치면 Q-C 범위가 무너진다.

create table if not exists command_ack (           -- 엔진(operator)만 INSERT
  ack_id            uuid primary key,
  command_id        uuid not null references command_queue(command_id),
  state             text not null check (state in ('RECEIVED','EXECUTED','REJECTED','EXPIRED',
                    'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM','NO_OPERATOR')),
  state_label       text not null,                -- 엔진 생성 문구
  reject_reason_code text,
  decision_id       text,
  lease_epoch       bigint not null,              -- 🔴 낮은 epoch 의 ack 거부
  acked_at          timestamptz not null default now()
);
-- ✅ **`command_ack.state` = batch_b `command_inbox.state` 와 같은 8값**(`CommandState` − `REQUESTED` ·
--    설계 13 §8 R19 E9-6 · R20 · 인벤토리 §10-2 ① 해소 · G-30). `command_queue` 에는 state 칸이 없다.
-- 🔵 이 배치의 실적용은 **E11**(Supabase 첫 부트스트랩 · 같은 `schema_version` — R19 E9-13).
-- 🆕 G-10 — 🔴 `command_ack` 위조는 「집행됨」을 조작한다. RLS 없이 부트스트랩 SQL 을 붙여넣으면
--    그 구멍이 그대로 운영 DB 가 된다.
alter table command_ack enable row level security;
create policy command_ack_select on command_ack for select to authenticated
  using (exists (select 1 from command_queue q
                 where q.command_id = command_ack.command_id and q.owner_uid = auth.uid()));

-- ── 작업 원장 미러 (X2) — 🔴 계획 원문 금지. digest + 한 줄 요약만 ────────────────────
create table if not exists planned_work_mirror (
  work_id     text primary key,
  -- 🆕 N-03 모드 축은 Supabase **전 표**에 걸린다 — §9-2 격리표
  mode        text not null check (mode in ('LIVE','SIM_INTERNAL','SIM_BROKER')),
  digest      text not null,
  one_line    text not null,
  due_by      date not null,
  state       text not null,
  row_version bigint not null,
  lease_epoch bigint not null,
  updated_at  timestamptz not null default now()
);
create table if not exists resume_run_mirror (
  resume_run_id text primary key,
  gap_trading_days int not null,
  -- 🆕 N-03 — `mode` 컬럼은 이미 있었으나 **값 도메인을 여기서 못 박는다**(RunMode 3값).
  mode text not null check (mode in ('LIVE','SIM_INTERNAL','SIM_BROKER')),
  phase text not null,
  headline text,
  updated_at timestamptz not null default now()
);
-- 🆕 G-10 — 미러 2표도 RLS 대상이다(단일 소유자 표라 `using (true)` 로 충분하되 **문장은 있어야 한다**)
alter table planned_work_mirror enable row level security;
create policy planned_work_mirror_select on planned_work_mirror for select to authenticated using (true);
alter table resume_run_mirror enable row level security;
create policy resume_run_mirror_select on resume_run_mirror for select to authenticated using (true);

-- ── 정합 스탬프 (X5) · 캘린더 상태 (X4) ──────────────────────────────────────────
create table if not exists ledger_stamp (
  -- ~~authored_date date primary key~~ 🆕 N-03 정정
  mode           text not null check (mode in ('LIVE','SIM_INTERNAL','SIM_BROKER')),
  authored_date  date not null,
  chain_hash     text not null,
  operator_epoch bigint not null,
  stamped_at     timestamptz not null default now(),
  primary key (mode, authored_date)
);
-- 🆕 🔴 `mode` 가 없으면 SIM 스탬프가 **같은 날짜의 LIVE 스탬프를 덮어** `canonSupabase` 가 매일
--    불일치한다. 반대로 SIM 이 스탬프를 아예 쓰지 않으면 모의 기간 X5 대조가 조용히 한 축을 잃는다 —
--    둘 다 결함이므로 축을 나눠 **양쪽 다 쓴다**.
create table if not exists calendar_sync_status (
  -- ~~id int primary key default 1 check (id = 1)~~ 🆕 G-32 — 로컬 `calendar_link.mode` 와 같은 축
  mode text primary key check (mode in ('LIVE','SIM')),
  last_ok_date date,
  status text not null,
  quarantined_count int not null default 0,
  updated_at timestamptz not null default now()
);
-- 🆕 G-10 — 🔴 `ledger_stamp` 위조는 X5 대조를 무력화한다. 두 표 모두 select 전용 정책만 둔다.
alter table ledger_stamp enable row level security;
create policy ledger_stamp_select on ledger_stamp for select to authenticated using (true);
alter table calendar_sync_status enable row level security;
create policy calendar_sync_status_select on calendar_sync_status for select to authenticated using (true);

-- ════════════════════════════════════════════════════════════════════════════
-- 읽기 모델 `rm_*` 18표 — 🔴 이 파일에 손으로 적지 않는다
-- ════════════════════════════════════════════════════════════════════════════
-- 01 §6-4 는 「개별 DDL 은 아래 **규칙을 따라 로컬 표에서 기계적으로 파생**한다」고 정했고,
-- 18표 중 컬럼 목록이 문서에 실린 것은 `rm_config_view`·`rm_advice`·`rm_advice_summary` 뿐이다.
-- 🔴 나머지를 손으로 적으면 **문서에 없는 컬럼을 지어내는 것**이 되고, 그 순간 이 파일이
--    두 번째 정본이 된다. 파생 생성기(06 M4-1)가 만들 때까지 여기는 **계약만** 적는다.
--
-- 표 18: rm_journal · rm_holding · rm_performance_point · rm_rebalance_event · rm_alert ·
--        rm_safety_state · rm_config_view · rm_advice · rm_advice_summary · rm_monthly_report ·
--        rm_report_archive · rm_ledger_diff · rm_sleeve_allocation · rm_perf_context ·
--        rm_disclosure_view · rm_ops_summary · rm_ledger_trust · rm_execution_gap
-- 🔵 v1 필수 4표 = rm_monthly_report · rm_report_archive · rm_ledger_diff · rm_advice_summary.
--    rm_sleeve_allocation·rm_perf_context 는 조건부.
--    ⬜ rm_ops_summary 는 **택일 미결**(홈 블록 5·7 의 소유) — 정하지 않은 상태가 가장 나쁘다
--       (뷰어가 값을 지어낸다). m2-8_naming J-4 는 «표를 만든다» ⏸ 권고.
--
-- **규칙 5조(+⑥)** — 파생 생성기가 표마다 반드시 지키는 것:
--   ① 전 `rm_*` 에 `row_version bigint` · `lease_epoch bigint` · `pushed_at timestamptz`
--      **+ `mode text not null check (mode in ('LIVE','SIM_INTERNAL','SIM_BROKER'))`**(G-31).
--      🔴 **증분 키에도 `mode` 가 들어간다**(예 rm_journal = (mode, trade_date, entry_id)).
--      🔴 viewer 쿼리는 `FeatureFlags.runMode` 가 아니라 **행의 `mode`** 로 거른다.
--      🔴 `rm_config_view` 는 **모드별 1행**이다.
--   ② upsert 는 (pk) 충돌 시 `row_version` 큰 쪽만 반영 — **정정은 새 행**(원본 수정 금지).
--      🔴 G-37 — `REVERSAL`·`RESTATEMENT` 는 **각자 고유한 `entry_id`** 를 가지므로 정정은
--      언제나 «새 행 추가»로 나타나고, 원본 행은 `superseded_by` 갱신 때만 row_version 이 오른다.
--   ③ 오프라인 후 백필은 증분 키 오름차순 재전송, 부분 동기는 `read_model_push.status` 로 표시.
--   ④ 🔴 RLS: 인증 사용자 `select` 전용, insert/update 는 operator 리스 epoch 보유자만(RPC).
--      🆕 **`rm_*` 도 예외가 아니다**(G-10) — 생성기는 표마다 `enable row level security` +
--      select 전용 정책을 **함께** 낸다. **RLS 미적용 표가 하나라도 있으면 부트스트랩 검수는 실패**다.
--   ⑤ 🔴 **시크릿·계좌 전체번호·손익 원장 금지** — push 전 시크릿 스캔 게이트 통과.
--      🔵 예외(rm_monthly_report·rm_perf_context)의 성립 조건 4가지: 월 마감 스냅샷만 ·
--      종목 단위 행 0건 · 뷰어도 `S7-2G` 게이트를 그대로 통과 · 시크릿 스캔 통과.
--      🔴 넷 중 하나라도 깨지면 push 하지 않는다.
--   ⑥ 🔴 **버전 스탬프 동시 갱신**(G-36) — push 시 `rm_config_view` 의 세 값
--      (`schema_version`·`hash_format_version`·`contract_version`)을 **매번 함께** 갱신한다.
--      읽기 모델만 새 스키마로 가고 버전이 옛 값이면 뷰어가 **구 렌더러로 새 데이터를 그린다**.
--
-- 🔴 **읽기 모델 컬럼 목록은 DTO 필수 필드의 상위집합이어야 한다**(G-22). 필수 필드에 대응 컬럼이
--    없으면 viewer 구현체가 컴파일되지 않고, 그때 구현자는 축약 타입을 만들어 계약 3조 ①을 우회한다.
-- 🔴 `rm_advice` 는 **A6 마스킹** — `symbol`·`quantity`·`price_low/high/ref`·`recorded_quantity`·
--    `actions` 를 **싣지 않는다**(C-27).
-- 🔴 **이 정책은 push 경로 변경을 동반한다**(§6-4 말미) — `rm_*`·명령 표 쓰기는 전량
--    security definer RPC(operator lease epoch 검사) **1개 창구**이고 클라이언트 upsert 0건이다.
--    정책만 넣고 push 를 RPC 로 바꾸지 않으면 부트스트랩 직후 동기화가 **전면 실패**한다.

-- ════════════════════════════════════════════════════════════════════════════
-- §D-add — «배치 D 추가분» (01 §6-6 말미) · **기존 표가 이미 있는 설치용**
-- ════════════════════════════════════════════════════════════════════════════
-- 위 `create table` 은 X7 7종·컬럼 3개를 이미 포함한다. 아래는 **구 스키마를 넓히는** 경로다.
-- 🔴 Postgres 는 CHECK 를 DROP/ADD 로 바꿀 수 있다(SQLite 와 다르다 — 테이블 재생성 불요).
--
-- alter table command_queue drop constraint command_queue_kind_check;
-- alter table command_queue add  constraint command_queue_kind_check check (kind in
--   ('KILL_SWITCH_ACTIVATE','JOURNAL_DRAFT','BLIND_REVIEW_SCORE','DISCLOSURE_VIEW',
--    'DEPOSIT_REGISTER','RECORD_MANUAL_FILL','AMEND_MANUAL_FILL','VOID_MANUAL_FILL',
--    'SKIP_ADVICE','SELF_REPORT_BALANCE','ALERT_ACK','KILL_CHECKLIST_CONFIRM',
--    'LEDGER_EVENT_RECORD'));
-- alter table command_queue add column if not exists run_mode       text;
-- alter table command_queue add column if not exists operating_mode text;
-- alter table command_queue add column if not exists lease_epoch    bigint;
--
-- alter table command_ack drop constraint command_ack_state_check;
-- alter table command_ack add  constraint command_ack_state_check check (state in
--   ('RECEIVED','EXECUTED','REJECTED','EXPIRED',
--    'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM','NO_OPERATOR'));
-- 🔵 기존 설치가 없으므로(설계 13 §8 R19 E9-10 전제) 이 절은 **기록용**이다.
