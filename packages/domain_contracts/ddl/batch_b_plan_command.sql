-- ════════════════════════════════════════════════════════════════════════════
-- 배치 B — Q-F 계획 스냅샷 · 명령 인입 · 운영 파라미터 · push 상태 · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-2
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 적용 순서상 «① 신설 표» 묶음이다(배치 A 와 같은 창).
-- 🔴 `command_inbox.state` 는 §6-5 배치 E 가 **CHECK 재작성**으로 넓힌 결과를 이미 반영한 형태다
--    (신규 생성이므로 재작성 절차가 필요 없다 — 기존 표가 있는 설치는 batch_e 를 따른다).

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- 미리보기 계획 스냅샷 — "계획 대비 실제" 대조의 앵커(요구 4)
CREATE TABLE IF NOT EXISTS plan_snapshot (
    plan_id         TEXT    NOT NULL PRIMARY KEY,
    kind            TEXT    NOT NULL CHECK (kind IN ('DEPOSIT','WITHDRAWAL','REBALANCE')),
    computed_at     TEXT    NOT NULL,
    as_of_trade_date TEXT   NOT NULL,
    expires_at      TEXT    NOT NULL,                    -- 🔴 만료 계획으로 실입금 등록 거부
    inputs          TEXT    NOT NULL,                    -- JSON 가격·환율·config_hash·계좌 매핑
    outputs         TEXT    NOT NULL,                    -- JSON 충당액·주문 초안·비용
    config_hash     TEXT    NOT NULL,
    consumed_by_decision_id TEXT                         -- 실입금 등록 시 바인딩
);

-- 🔴 명령의 정본은 Supabase(§6-4)다. 이 표는 엔진이 인입·집행한 사실의 로컬 감사 기록이다
-- 🔴 G-30 — 이 표의 state 집합은 `command_queue` 의 state 집합과 **항상 같다**.
--    한쪽만 넓히면 보류된 명령이 로컬 감사에서 사라지고, canonSupabase 대조의 명령 축이
--    한쪽 증언만 갖는다.
CREATE TABLE IF NOT EXISTS command_inbox (
    command_id      TEXT    NOT NULL PRIMARY KEY,        -- Supabase command_queue.command_id
    kind            TEXT    NOT NULL,
    ingested_at     TEXT    NOT NULL,
    state           TEXT    NOT NULL CHECK (state IN ('RECEIVED','EXECUTED','REJECTED','EXPIRED',
                     'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM')),
    state_label     TEXT    NOT NULL,                    -- 엔진 생성 문구
    reject_reason_code TEXT,
    decision_id     TEXT,                                -- 집행이 결정을 만들었으면 연결
    run_mode        TEXT,                                -- 🆕 G-30(X7 A10) — 발행 시점 맥락.
    operating_mode  TEXT,                                --    `command_queue` 와 **같은 값을 복사**한다.
    lease_epoch     INTEGER,                             --    없으면 `staleContext` 판정을 사후에 증명 못 한다
    payload_digest  TEXT    NOT NULL                     -- 🔴 원문 재저장 금지 — digest 만
);
-- ⚠️🔴 **열린 물음 — `NO_OPERATOR` 의 DDL 자리**(인벤토리 §10-2 ① · m2-8_naming K-1. 임의 확정 금지)
--    · `CommandState.noOperator` 는 M2-8 A-11 이 **이름을 확정**했다(`NO_OPERATOR`).
--      「요청됨」이 «껐다»로 읽히는 것을 막는 유일한 값이다(§10-8 ⓑ).
--    · 그런데 `command_inbox.state`·`command_ack.state`·`command_queue.state` **어느 CHECK 에도
--      `NO_OPERATOR` 가 없다**. G-30 은 「`command_inbox` state 집합 = `command_queue` state 집합」을
--      요구하는데 `command_ack.state` CHECK 는 여전히 4값이다.
--    · 🔴 **세 표 중 어디까지 넓히는가는 이름 문제가 아니라 스키마 결정**이므로 여기서 정하지 않는다.
--      확정되면 이 CHECK · batch_d 의 `command_queue`·`command_ack` · C-15 를 같은 커밋에서 고친다.

-- 🆕 G-06 운영 파라미터(전략 config_hash **밖**) — 🔴 정정은 새 행, UPDATE 금지
CREATE TABLE IF NOT EXISTS operating_param_log (
    row_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    param_key      TEXT    NOT NULL,   -- 🔴 화이트리스트 (labels/ledger_event_codes.dart)
    value_text     TEXT    NOT NULL,   -- Decimal 문자열
    changed_at     TEXT    NOT NULL,   -- 🔴 신뢰 시각(M1-13, Supabase 서버 시각) — 폰 로컬 시계 아님
    effective_from TEXT    NOT NULL,   -- 적용 개시일 = 다음 납입 주기(§2-6 `contribution_day`)
    action_run_id  TEXT    NOT NULL,   -- SettingsActions.run 의 actionRunId
    device_id      TEXT    NOT NULL,
    superseded_by  INTEGER,            -- 뒤 행이 이 행을 대체(정정 = 새 행)
    UNIQUE(param_key, changed_at)
);
-- 🔴 **현재 유효값 조회 규약**(N-S4-01) — `param_key` 별 `effective_from <= 신뢰 시각 오늘` 인 행 중
--    `changed_at` 최대 행이다. `effective_from` 이 미래인 행은 **예정값**이며 현재값 조회에
--    **섞이지 않는다**(뷰가 아니라 **조회 규약**).
-- 🔴 이 단서가 없으면 저장 즉시 새 값이 현재값이 되어 «다음 납입 주기부터 적용»(§2-6)이 무효가 되고,
--    이번 달 입금의 플래너 스텝 ① 기본값이 **다음 달 금액**으로 채워진다.
-- 🔴 이 표는 전략 `config_hash` 에 들어가지 않는다(골든벡터 불변).
-- 🔴 `param_key` 는 화이트리스트이며 `fx_overlay` 계열 키를 넣지 않는다(§4-3 — 기각된 규칙의 부활 경로).
-- 🔴 GitHub 아카이브 대상이다(§6-7) — 아카이브에 없으면 「이력이 남는다」는 폰 재설치로 깨진다.
-- 🔴 C-32 — 금액 리터럴을 이 파일·화면·라벨 어디에도 적지 않는다.

-- Supabase 읽기 모델 push 상태(로컬 측 기록)
CREATE TABLE IF NOT EXISTS read_model_push (
    table_name      TEXT    NOT NULL PRIMARY KEY,
    last_pushed_key TEXT    NOT NULL,                    -- 증분 키(trade_date 또는 rowid)
    last_ok_at      TEXT,
    row_version     INTEGER NOT NULL DEFAULT 0,
    status          TEXT    NOT NULL CHECK (status IN ('OK','PUSH_LAG','PUSH_FAILED'))
);

COMMIT;
PRAGMA foreign_keys = ON;
