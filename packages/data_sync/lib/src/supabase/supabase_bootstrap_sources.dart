// 🔴 생성 파일 — 손으로 고치지 않는다. `python -I tool/make_supabase_bootstrap.py` 로 다시 만든다.
//
// o_07 ① Supabase 부트스트랩 묶음의 원문 조각(설계 13 §8 R221 · E11k-e2) — 묶음 = `supabase_bootstrap.dart`.
//    packages/domain_contracts/ddl/batch_d_supabase.sql sha256 `d4656fa2c0b5b7148ed3beca79a3ae39d5318ecf5c2075717a9641e7896c369b`
//    packages/data_sync/sql/supabase_lease_rpc.sql sha256 `330f2c821ef2f0bdeaab131bb8d12e03573c1c763a3b2d6411a29a5f332234cf`
//    packages/data_sync/sql/supabase_read_model_push_rpc.sql sha256 `eb14b5a43387cac1daed214921c35f09659dc69879ed03fe455772f2d9f738bb`
//    packages/data_sync/sql/supabase_ops_push_rpc.sql sha256 `a91708ff24da0f407e9696c403099151c5cce7ce1be61c13209f9ed4cfabef6b`
// 🔴 data_sync 시험이 원문 4 개와 바이트 대조한다(갈라지면 시험이 실패).

/// ① 배치 D — 계약 사본(01 §6-4) 원문 그대로 — `packages/domain_contracts/ddl/batch_d_supabase.sql`.
const String kSupabaseBatchDSql = r'''
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
  owner_uid     uuid not null references auth.users(id),
  -- 🆕 v1.29(01 §39 · 지도 D5) 기기마다 Auth 사용자 1명 — 이 기기의 로그인 사용자(`owner_uid` = 소유자 = operator 사용자).
  --    리스 · 페어링 RPC 는 `auth_uid = auth.uid()` 로 부르는 기기를 판정한다(JWT `app_metadata` 에 기대지 않음).
  -- 🆕 v1.34(01 §43 · 미결 214 닫음) not null · 🔴 **unique 아님** — X1 새 폰은 같은 운영 사용자로 로그인한다(설계 13 R197 T8 ·
  --    이메일 + 비밀번호) → 옛 폰 · 새 폰 두 행의 `auth_uid` 가 같다(unique 면 새 폰 행을 못 넣는다 · PGlite 실증 13 R221).
  --    기기 하나 = 행 하나는 `device_id` 가 지킨다. 뷰어 기기(`auth_uid` ≠ `owner_uid`) 행 = 페어링 RPC(E11m · 서버)만 넣는다.
  auth_uid      uuid not null references auth.users(id)
);
-- 🆕 v1.34 — RLS · 리스 RPC 가 `auth_uid = auth.uid()` 로 기기 행을 찾는다(unique 를 뺀 자리의 색인).
create index if not exists ix_app_device_auth_uid on app_device(auth_uid);
-- 🔴 최초 INSERT 는 role='viewer' · status='PENDING' 강제. operator 승격은 리스 RPC(서버)만
-- 🆕 v1.34 — 클라이언트가 넣는 행 = 운영 사용자 자기 기기(`auth_uid` = `owner_uid` = 부른 사용자)뿐이다.
--    뷰어 기기 행(소유자 ≠ 로그인 사용자)은 클라이언트가 못 넣는다 — 페어링 RPC(서버 · E11m) 몫.
-- 🆕 v1.39(01 §48 K349 ② · 13 R267 L4 · 리뷰 3차 C-2 = I-U2) — 첫 클레임 뒤(리스 행 있음)에는 운영 사용자만 넣는다:
--    리스를 쥔 기기 행이 부른 사용자 소유(`owner_uid = auth.uid()` — `device_select_own` 으로 보인다)일 때만 · 리스 행 없음(첫 클레임 전) =
--    아무 인증 사용자(그 틈 = 17 §3-7 공개 가입 끄기 · o_07 확인 `SUPABASE_SIGNUP_OPEN`). 공개 가입 사용자 = 자기 PENDING 행도 못 넣는다.
alter table app_device enable row level security;
-- 🆕 v1.39 — 정책 `device_insert_viewer_only` 는 `operator_lease` 를 읽어 그 표 뒤(아래 리스 절)에서 만든다.
-- 🆕 v1.34 — 소유자 = 자기 기기 전부 · 뷰어 = 자기 행만.
create policy device_select_own on app_device for select to authenticated
  using (owner_uid = auth.uid() or auth_uid = auth.uid());

-- ── operator 리스 (X1·X3) — 🔴 단일 행. 쓰기는 RPC(CAS)만, 직접 UPDATE 정책 없음 ─────
create table if not exists operator_lease (
  id            int primary key default 1 check (id = 1),
  device_id     text not null references app_device(device_id),
  epoch         bigint not null,                  -- 🔴 세대번호. 비상 펜싱 시 강제 +1
  expires_at    timestamptz not null,             -- TTL (Q-B 권고 T=30분)
  updated_at    timestamptz not null default now(),
  -- 🆕 v1.37(01 §46 · K324 · K325 · 미결 218 ⓕ) X1 계획 이전 넘김 티켓 — `device_retire` 가 쓰고 `lease_claim`(논스 대조) · `lease_revoke` 가 지운다.
  --    해시 = 티켓 논스 sha256(16진 64 · 평문 0) · 만료 = 서버 now() + 운영 설정 `migration.ticket_ttl_minutes`(잠정 값 · 서버 상수 0).
  ticket_hash        text,
  ticket_expires_at  timestamptz,
  check ((ticket_hash is null) = (ticket_expires_at is null))
);
alter table operator_lease enable row level security;
create policy lease_select on operator_lease for select to authenticated using (true);
-- 🆕 v1.39(01 §48 K349 ②) — `app_device` 넣기 정책(위 기기 원장 절 주석) — 리스 표를 읽으니 여기서 만든다.
create policy device_insert_viewer_only on app_device for insert to authenticated
  with check (auth_uid = auth.uid() and owner_uid = auth.uid() and role = 'viewer' and status = 'PENDING'
              and (not exists (select 1 from operator_lease)
                   or exists (select 1 from operator_lease l join app_device h on h.device_id = l.device_id
                              where h.owner_uid = auth.uid())));
-- 🔴 claim/renew/revoke 는 security definer RPC. 클라이언트 UPDATE·DELETE 정책은 만들지 않는다
-- 🆕 v1.29(01 §39 · §6-4 RPC 표 · 지도 X18) — 이름 · 인자 · 반환 칸 = 계약 `schema/supabase_rpc.dart` · 거부 = `LeaseRpcResultCodes`.
--    본문(SQL)은 E11k-e 부트스트랩 묶음이 이 자리에 넣는다(지금 = 서명만 · 🔴 `server_now` 0 — 신뢰 시각 = 게이트웨이 `Date`).
--    반환 = 한 행 (code text, epoch bigint, expires_at timestamptz) · code = 거부 코드 또는 null · T = 30분(서버 상수 · R43 D3).
--    lease_claim (p_device_id text, p_recovery_code_hash text default null)
--      · 빈 행 = 첫 클레임 → 🔴 p_recovery_code_hash 필수(없으면 RECOVERY_CODE_REQUIRED) · recovery_secret 같은 트랜잭션 · epoch 1
--      · 같은 기기 → 이 기기(epoch 그대로) · 🆕 v1.39(01 §48 K349 ① · 13 R267 L1 · 리뷰 3차 C-1 = D-01) 다른 기기 보유 ∧ 만료 →
--        그 기기가 REVOKED · RETIRED 일 때만 이 기기(epoch+1) · 아직 자격 = LEASE_HELD_BY_OTHER(지금 epoch · 만료 시각) — 옛 «만료 ∨ 같은 기기»
--        정정(다른 기기 인계 = 첫 클레임 · 비상 회수 `lease_revoke` · 계획 이전 은퇴 `device_retire` 뒤에만) · 다른 기기 유효 = LEASE_HELD_BY_OTHER
--      · 성공 = 그 기기 role='operator' · status='ACTIVE' · 부른 사용자 ≠ 그 기기 auth_uid ∨ REVOKED · RETIRED = LEASE_DEVICE_NOT_ELIGIBLE
--      · 🆕 v1.39(13 R267 L4 · 리뷰 3차 C-2) 첫 클레임 뒤 세 RPC = 부른 사용자 ≠ `recovery_secret.owner_uid` = LEASE_DEVICE_NOT_ELIGIBLE(운영 사용자 고정)
--    lease_renew (p_device_id text, p_epoch bigint) — 보유 ∧ epoch 같음 ∧ 만료 전 → expires_at = now() + T · 아니면 LEASE_LOST
--    lease_revoke (p_device_id text, p_recovery_code text, p_new_recovery_code_hash text) — 비상(X1-3 ①)
--      · 복구 코드 대조(틀림 = RECOVERY_CODE_INVALID) → 같은 트랜잭션: epoch+1 · device_id = 부른 기기 · expires_at = now()(즉시 만료 —
--        새 폰은 펜싱 대기 뒤 lease_claim) · 옛 보유 기기 status='REVOKED' · recovery_secret 해시 교체(쓴 코드 = 그 뒤 «틀림»)
-- 🆕 v1.37(01 §46 · K324 · K325 · 13 §8 R244 넘김 (가)(나)(다)) X1 계획 이전 리스 넘김 — 🔵 엔진 예고(본문 = 01 §8 미결 228) ·
--    이름 · 인자 = 계약 `LeaseHandoverRpcNames` · `LeaseHandoverRpcParams` · 거부 += `LeaseHandoverResultCodes` · 반환 꼴 = 위와 같은 한 행.
--    device_retire (p_device_id text, p_epoch bigint, p_ticket_nonce_hash text, p_ticket_ttl_minutes int) — 옛 폰 «RETIRED 서명» 단계
--      · 부른 사용자 = 그 기기 auth_uid ∧ 리스 행 = 그 기기 ∧ epoch 같음(만료됐어도 그 뒤 아무도 안 가져갔으면) → 한 트랜잭션:
--        app_device.status='RETIRED' · operator_lease.expires_at = now()(즉시 만료) · ticket_hash · ticket_expires_at = now() + ttl
--      · 반환 expires_at = 티켓 만료 시각 · 다른 기기 · epoch 다름 = LEASE_LOST · 남의 기기 · REVOKED = LEASE_DEVICE_NOT_ELIGIBLE ·
--        해시 없음 = LEASE_TICKET_REQUIRED · 이미 RETIRED ∧ 같은 epoch ∧ 아직 클레임 없음 = 티켓 교체(재발급 · 멱등 재시도)
--    lease_claim 셋째 인자 p_ticket_nonce text default null — ticket_hash 가 있으면: 없음 = LEASE_TICKET_REQUIRED ·
--      sha256 다름 = LEASE_TICKET_INVALID · 만료 = LEASE_TICKET_EXPIRED · 맞음 = 클레임(epoch+1 · 티켓 지움) · 티켓 없음 = 위 규칙 그대로
--    lease_revoke — 같은 트랜잭션에서 ticket_hash · ticket_expires_at 도 지운다(비상이 넘김 대기를 이긴다)

-- ── 복구 코드 (X3) — 🔴 해시만. 평문은 종이(복구 카드)에만 존재 ─────────────────────
create table if not exists recovery_secret (
  owner_uid     uuid primary key references auth.users(id),
  code_hash     text not null,
  -- 🆕 v1.34(01 §43) 기본값 = 리스 RPC 가 적는 값(해시 꼴 `sha256:<소금>:<요약>` · 설계 13 R221 S6 · 확장 0) · 옛 기본값 argon2id 폐기.
  algo          text not null default 'sha256',
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
                      'LEDGER_EVENT_RECORD',
                      -- 🆕 계약 v1.12(01 §21 · K14 ⓐ) 만료 확인 카드 「내일 다시」(operator 전용 · 초안 영구 제외)
                      'DEFER_ADVICE_CONFIRM')),
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
-- 🔴 RLS 는 **소유자가 아니라 `role` 기준**이다(청사진 X3 보강). owner_uid 만 보면 뷰어가
--    승인된 4종(Q-C: 킬스위치·저널 초안·blind 리뷰·열람 이벤트) 밖인 DEPOSIT_REGISTER 까지 넣을 수 있다.
-- 🆕 v1.34(01 §43 · 미결 214 · 13 닫음) `role` 자리 = **`app_device` 행**(JWT `app_metadata` 클레임 0) — 명령을 낸 기기
--    (`issued_by_device`)가 부른 사용자의 기기(`auth_uid = auth.uid()`) · 명령 `owner_uid` 의 기기 · ACTIVE 여야 한다.
--    뷰어 기기 = 소유자 ≠ 로그인 사용자라 `owner_uid = auth.uid()` 를 쓸 수 없다(기기마다 Auth 사용자 · 지도 D5).
--    행의 role = 페어링 RPC(뷰어 · E11m) · 리스 RPC(operator 승격)만 정한다 — 클라이언트 쓰기는 viewer · PENDING 뿐.
--    🔴 DEPOSIT_REGISTER 는 **폰(operator) 전용**이다 — 입금 등록은 계획 스냅샷 바인딩이라 뷰어 경로가 없다.
-- 🔴 신규 X7 7종 + 🆕 v1.10 `LEDGER_EVENT_RECORD`(㉕ 폰 전용) + 🆕 v1.12 `DEFER_ADVICE_CONFIRM`(K14 ⓐ 폰 전용)은
--    **`command_insert_operator` 정책에만** 들어간다.
--    `command_insert_viewer` 의 4종 화이트리스트는 **그대로 둔다**
--    (⚠️ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결이며 m2-8_naming J-3 은 «허용하지 않는다» ⏸ 권고).
create policy command_insert_viewer on command_queue for insert to authenticated
  with check (
    expires_at > now()
    and kind in ('KILL_SWITCH_ACTIVATE','JOURNAL_DRAFT','BLIND_REVIEW_SCORE','DISCLOSURE_VIEW')
    and exists (select 1 from app_device d
                 where d.device_id = command_queue.issued_by_device
                   and d.auth_uid = auth.uid() and d.owner_uid = command_queue.owner_uid
                   and d.role = 'viewer' and d.status = 'ACTIVE')
  );
create policy command_insert_operator on command_queue for insert to authenticated
  with check (
    expires_at > now()
    and exists (select 1 from app_device d
                 where d.device_id = command_queue.issued_by_device
                   and d.auth_uid = auth.uid() and d.owner_uid = command_queue.owner_uid
                   and d.role = 'operator' and d.status = 'ACTIVE')
  );
-- 🆕 v1.34 — 읽기 = 부른 사용자의 ACTIVE 기기가 그 명령 소유자의 기기일 때(뷰어 = 소유자의 명령 · PENDING 폰 = 0).
create policy command_select_own on command_queue for select to authenticated
  using (exists (select 1 from app_device d
                  where d.auth_uid = auth.uid() and d.owner_uid = command_queue.owner_uid
                    and d.status = 'ACTIVE'));
-- 🔴 UPDATE·DELETE 정책 없음 = append-only 가 DB 로 강제된다
-- 🔴 두 INSERT 정책의 **분리 자체**가 계약이다 — 하나로 합치면 Q-C 범위(뷰어 4종)가 무너진다.
--    ~~⚠️ `role` 클레임을 어디에 싣는가(app_metadata vs 커스텀 클레임 RPC)는 M4-2 에서 확정한다.~~
--    ✅ v1.34 = `app_device` 행(위 · 01 §8 미결 13 닫음).

create table if not exists command_ack (           -- 🆕 v1.40 쓰기 = op_push 만 · append-only(리스 보유 운영 폰 엔진)
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
-- 🆕 v1.34 — 보이는 명령(위 `command_select_own` 이 걸린 `command_queue`)의 ack 만 — 뷰어 = 소유자 명령의 ack.
-- 🆕 v1.40(01 §49 · 미결 229 · 13 R270 W4) — 쓰기 = RPC `op_push`(`OpsPushRpcNames` · security definer · 리스 epoch 검사) 만:
--    같은 `ack_id` = 건너뜀(바꾸지 않음) · `command_id` = 부른 사용자 소유 명령만 · `lease_epoch` = 인자 epoch · `acked_at` = 서버 now().
--    🔴 INSERT · UPDATE · DELETE 정책 0 = 클라이언트 직접 쓰기 0(append-only 가 DB 로 강제된다).
create policy command_ack_select on command_ack for select to authenticated
  using (exists (select 1 from command_queue q where q.command_id = command_ack.command_id));

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
  -- 🆕 v1.22(01 §31 · K62) — 재개 모드(로컬 `resume_run.mode` = `ResumeMode` 4값 · 위 `mode` = `RunMode` · 이름만 비슷한 두 축).
  --    엔진 미러 칸 = 숙제(ds `resume_status.dart` `mirrorPayload` · E11l2) · Supabase 부트스트랩 = E11k.
  resume_mode text not null check (resume_mode in ('NORMAL','CONSERVATIVE','RECOVERY_DRY','RECOVERY_FULL')),
  phase text not null,
  headline text,
  updated_at timestamptz not null default now()
);
-- 🆕 G-10 — 미러 2표도 RLS 대상이다. ~~단일 소유자 표라 `using (true)` 로 충분~~ 🆕 v1.40(01 §49 · 222 ⓕ · 13 R270 W5) select 본문 =
--    `rm_*` 와 같은 K311(부른 사용자의 ACTIVE 기기 · `ReadModelRls.selectUsing`) — `using (true)` 면 기기 없는 인증 사용자(공개 가입)가
--    미러를 읽는다(PGlite 재현). 읽는 쪽 = 운영 폰 · ACTIVE 뷰어 · 클레임 뒤 새 폰뿐이라 잃는 것 0.
-- 🆕 v1.40 쓰기 = RPC `op_push` 만(`planned_work_mirror` = `row_version` 큰 쪽 · `resume_run_mirror` = 덮음 · epoch · 시각 칸 = 서버) ·
--    클라이언트 쓰기 정책 0.
alter table planned_work_mirror enable row level security;
create policy planned_work_mirror_select on planned_work_mirror for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));
alter table resume_run_mirror enable row level security;
create policy resume_run_mirror_select on resume_run_mirror for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

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
-- 🆕 v1.40(01 §49 · 222 ⓕ · 13 R270 W5) select 본문 = K311(`ReadModelRls.selectUsing` · ~~`using (true)`~~) · 쓰기 = RPC `op_push` 만
--    (덮음 · `ledger_stamp` = 같은 날 다시 씀 · `operator_epoch` = 인자 epoch · 시각 칸 = 서버) · 클라이언트 쓰기 정책 0.
alter table ledger_stamp enable row level security;
create policy ledger_stamp_select on ledger_stamp for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));
alter table calendar_sync_status enable row level security;
create policy calendar_sync_status_select on calendar_sync_status for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- ════════════════════════════════════════════════════════════════════════════
-- 읽기 모델 `rm_*` 22표 — 🔴 이 파일에 손으로 적지 않는다
-- ════════════════════════════════════════════════════════════════════════════
-- 01 §6-4 는 「개별 DDL 은 아래 **규칙을 따라 로컬 표에서 기계적으로 파생**한다」고 정했다.
-- ✅ v1.36(01 §45 · K303 · 지도 D15 · 13 R230 L2) — 열 표의 정본 = 계약 Dart 상수
--    `lib/src/schema/read_model_tables.dart` `ReadModelTables`(표 · 키 · 열 · 형 · 결속 DTO · 제외 키 · RLS 본문).
--    열 = 결속 DTO `toJson()` 최상위 키(접두 · 제외 · 펼침 한 겹) + DTO 밖 열 + 아래 규칙 5조 4칸 — C-69 가 표본으로 대조한다.
-- 🔴 DDL 문장은 생성기(data_sync E11l1 · Dart 순수 함수 · 골든 `packages/data_sync/sql/supabase_read_models.sql`)가
--    그 상수에서 낸다 — 여기에 손으로 적으면 **두 번째 정본**이 된다.
--
-- 표 22: rm_journal · rm_holding · rm_performance_point · rm_performance_series · rm_rebalance_event ·
--        rm_alert · rm_safety_state · rm_config_view · rm_advice · rm_advice_summary · rm_monthly_report ·
--        rm_report_archive · rm_ledger_diff · rm_sleeve_allocation · rm_perf_context · rm_disclosure_view ·
--        rm_ops_summary · rm_ledger_trust · rm_execution_gap · rm_blind_review · rm_watchdog · rm_list_envelope
--   (~~18~~ · 06 M4-1 «19» · 01 §6-4 20 + `rm_watchdog`(미결 142) + 🆕 `rm_list_envelope`(ListResult 봉투 — K310))
-- 🔵 v1 필수(push 우선) = rm_monthly_report · rm_report_archive · rm_ledger_diff · rm_advice_summary ·
--    rm_sleeve_allocation(v1.8) · rm_ops_summary(N-07) · rm_list_envelope(목록 봉투) — 🔴 부트스트랩은 22표 **전부**(K314).
--    ✅ rm_ops_summary = 홈 블록 5·7 과 계약 v1.12 `H-02` 전체 리듬 목록(`OpsSummaryRepository.watchRhythm` · K29 → 열 `rhythm`)·
--       `resume_line`(K44)의 뷰어 원천.
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
--      ✅ v1.36(K311) select 본문 = 부른 사용자의 ACTIVE 기기 행(`app_device` 조인 · JWT 클레임 0 — `ReadModelRls`).
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
--    `actions` 를 **싣지 않는다**(C-27). ✅ v1.36(K307) — 종목 · 방향 · 수량 · 가격 칸 10 = 열 0(뷰어 판 null · `actions` = []).
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
--    'LEDGER_EVENT_RECORD','DEFER_ADVICE_CONFIRM'));
-- alter table command_queue add column if not exists run_mode       text;
-- alter table command_queue add column if not exists operating_mode text;
-- alter table command_queue add column if not exists lease_epoch    bigint;
--
-- alter table command_ack drop constraint command_ack_state_check;
-- alter table command_ack add  constraint command_ack_state_check check (state in
--   ('RECEIVED','EXECUTED','REJECTED','EXPIRED',
--    'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM','NO_OPERATOR'));
-- 🔵 기존 설치가 없으므로(설계 13 §8 R19 E9-10 전제) 이 절은 **기록용**이다.
''';

/// ② operator 리스 RPC 본문(06 M4-3 · 01 §6-4 리스 RPC 표 · R221) — `packages/data_sync/sql/supabase_lease_rpc.sql`.
const String kSupabaseLeaseRpcSql = r'''
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
--   · 🆕 운영 사용자 고정(리뷰 3차 C-2 · I-U2 · 01 §8 미결 236 ⓑ · 설계 13 §8 R267) — 첫 클레임 뒤에는 recovery_secret 의 소유자
--     (= 첫 클레임을 한 운영 사용자)만 세 RPC 를 쓸 수 있다. 다른 Auth 사용자(공개 가입 · 뷰어 사용자)가 insert 정책으로 자기 기기
--     행을 넣어도 LEASE_DEVICE_NOT_ELIGIBLE(operator · ACTIVE 로 오르지 않는다 → rm_* 0행 · 운영 폰 리스를 못 막는다).
--     첫 클레임 전(리스 · 해시 0)에는 묶을 신원이 없다 — 그 틈 = 17 절차서 §3-7 «공개 가입 끄기»(필수).
--   · security definer · search_path = '' (모든 이름을 스키마로 적는다) · 실행 권한 = authenticated 만(anon · public 회수).
--
-- 복구 코드 해시(R221 — 이 판이 정한다 · 클라이언트 = data_sync `supabase_recovery_code.dart` · 발급 = E11k-e3)
--   · 꼴 = 'sha256:<소금 16진 32>:<요약 16진 64>' · 요약 = sha256(UTF-8(<소금 16진> || ':' || <정규화 코드>))
--   · 정규화 = 영숫자만 남기고 대문자(종이에 옮겨 적은 띄어쓰기 · 하이픈을 지운다).
--   · 🔴 Postgres 내장 sha256() 만 쓴다(확장 0 — pgsodium = Supabase 폐기 예정 · pgcrypto 에는 argon2 가 없다).
--     빠른 해시로 충분한 까닭 = 복구 코드는 사람이 고른 낱말이 아니라 기기가 뽑는 무작위 ≥ 100비트(E11k-e3 몫)이고
--     recovery_secret 에는 SELECT 정책이 없다(검증은 이 RPC 안에서만).
--   · recovery_secret.algo = 'sha256' 을 RPC 가 적는다(DDL 기본값도 'sha256' — 계약 v1.34 · 01 §43 · 미결 214).

-- ── lease_claim ──────────────────────────────────────────────────────────────
-- 빈 행 = 첫 클레임 → p_recovery_code_hash 필수(없음 · 꼴 아님 = RECOVERY_CODE_REQUIRED) · 리스 행 + recovery_secret 를
-- 같은 트랜잭션에 · epoch 1. 행 있음 → 보유 기기 = 이 기기 → 그대로(만료여도 되찾음 · epoch 그대로) ·
-- 🆕 다른 기기 보유 ∧ 만료 ∧ 그 기기가 REVOKED · RETIRED → 이 기기(epoch+1) · 다른 기기 보유 ∧ (유효 ∨ 그 기기가 아직 자격) =
-- LEASE_HELD_BY_OTHER(지금 epoch · expires_at). 성공 = 이 기기 role='operator' · status='ACTIVE'.
-- 🆕 리뷰 3차 C-1 · D-01(01 §8 미결 236 ⓐ · R267) — 만료만으로는 다른 기기로 넘기지 않는다: 새 폰이 R-01 을 거치지 않고
--    («처음 시작하기» ⑤) 만료 리스를 가져가고 옛 폰이 다시 켜지면 되찾아 두 기기가 번갈아 발주하던 길을 막는다.
--    다른 기기 인계 = 첫 클레임 · 비상 회수(lease_revoke — 옛 보유 기기 REVOKED · device_id = 부른 기기) · 계획 이전 은퇴(device_retire
--    — 옛 보유 기기 RETIRED · 01 §8 미결 228) 뒤에만. 🔵 01 §6-4 리스 RPC 표 «만료 ∨ 같은 기기» 문언 정정 = 계약 창 대기.
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
  -- 🆕 운영 사용자 고정(리뷰 3차 C-2 · 미결 236 ⓑ) — 첫 클레임을 한 사용자가 아니면 거부(첫 클레임 전 = 해시 0 = 통과).
  perform 1 from public.recovery_secret r where r.owner_uid <> v_uid;
  if found then
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
  elsif v_holder = p_device_id
     or (v_exp <= now()
         and not exists (
           select 1
             from public.app_device h
            where h.device_id = v_holder
              and h.status not in ('REVOKED', 'RETIRED'))) then
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
  -- 🆕 운영 사용자 고정(리뷰 3차 C-2 · 미결 236 ⓑ) — 첫 클레임을 한 사용자가 아니면 거부(첫 클레임 전 = 해시 0 = 통과).
  perform 1 from public.recovery_secret r where r.owner_uid <> v_uid;
  if found then
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
  -- 🆕 운영 사용자 고정(리뷰 3차 C-2 · 미결 236 ⓑ) — 첫 클레임을 한 사용자가 아니면 거부(첫 클레임 전 = 해시 0 = 통과).
  perform 1 from public.recovery_secret r where r.owner_uid <> v_uid;
  if found then
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
''';

/// ④ 읽기 모델 push RPC 본문(06 M4-1 · 01 §47 push RPC 표 · R254) — `packages/data_sync/sql/supabase_read_model_push_rpc.sql`.
const String kSupabaseReadModelPushRpcSql = r'''
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
''';

/// ⑤ 운영 폰 공유 표 push RPC 본문(06 M4-1 · 01 §8 미결 229 · R270) — `packages/data_sync/sql/supabase_ops_push_rpc.sql`.
const String kSupabaseOpsPushRpcSql = r'''
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
''';
