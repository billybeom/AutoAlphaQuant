-- ════════════════════════════════════════════════════════════════════════════
-- 배치 C — X2(재개) · X3(온보딩·자격) · X4(캘린더) · X5(정합) · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-3 (핸드오프 §4-②-7-0)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 `calendar_link`·`calendar_sync_state` 는 §6-5 G-32(단일 행 → `mode` PK)를 이미 반영한
--    **신규 생성** 형태다. 기존 표가 있는 설치는 batch_e 의 재생성 절차를 따른다.
-- 🔴 `calendar_event_log.origin` 도 §6-5 G-28(`MANUAL_ENTRY` 추가)을 반영한 형태다.
-- 🔴 `ledger_diff.pair` 는 여기서 **4값**으로 만든다 — 5값 재작성은 배치 F(N-01)가 한다.
--    순서는 「pair 재작성 → applicable ALTER」이며 뒤집으면 CHECK 위반으로 보드가 4칸으로 퇴화한다.
-- ⏸ X4 계열 전체는 **이름·타입을 등재하되 구현하지 않는다**(m2-8_naming J-5) —
--    OAuth 동의화면 «테스트» 상태 7일 만료가 사실이면 X4 문안이 통째로 사문화된다(§8-5).
--    🔴 그래도 표는 만든다: 표가 없으면 `canonCalendar` 축이 대조에서 조용히 빠진다.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- X2 ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS planned_work (
    work_id         TEXT    NOT NULL PRIMARY KEY,
    idempotency_key TEXT    NOT NULL UNIQUE,             -- 🔴 UNIQ
    kind            TEXT    NOT NULL,                    -- SEASONAL_WINDOW|DEFER_COUNT|SPLIT_LEG
    created_at      TEXT    NOT NULL,
    due_by          TEXT    NOT NULL,                    -- 🔴 초과 행은 코드 경로상 DONE 불가
    state           TEXT    NOT NULL CHECK (state IN
                     ('PLANNED','REEVALUATED','SUPERSEDED','EXPIRED','DONE','BLOCKED')),
    verdict_code    TEXT,                                -- §3-3
    digest          TEXT    NOT NULL,
    one_line        TEXT    NOT NULL,                    -- 엔진 생성 요약
    parent_work_id  TEXT,
    decision_id     TEXT,
    origin          TEXT    NOT NULL DEFAULT 'LOCAL' CHECK (origin IN ('LOCAL','MIRROR')),
    row_version     INTEGER NOT NULL DEFAULT 0           -- 🔴 미러 upsert 의 승자 판정(§6-4 규칙 5조 ②)
);
-- 🆕 청사진 X2 데이터 «전이는 append 병행» — 위 표의 state 는 현재값이고, 이력은 여기 남는다.
--    🔴 상태를 UPDATE 만 하면 "만료를 지나 DONE 으로 갔는가"를 사후에 증명할 수 없다(X2 원칙 ①).
CREATE TABLE IF NOT EXISTS planned_work_transition (
    transition_id   TEXT    NOT NULL PRIMARY KEY,
    work_id         TEXT    NOT NULL,
    from_state      TEXT,                                -- 최초 등록이면 NULL
    to_state        TEXT    NOT NULL,
    verdict_code    TEXT,                                -- §3-3
    resume_run_id   TEXT,                                -- 어느 재개 회차가 옮겼는가
    decision_id     TEXT,
    occurred_at     TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_pw_transition ON planned_work_transition(work_id, occurred_at);

CREATE TABLE IF NOT EXISTS resume_run (
    resume_run_id   TEXT    NOT NULL PRIMARY KEY,
    started_at      TEXT    NOT NULL,
    finished_at     TEXT,
    gap_trading_days INTEGER NOT NULL,
    mode            TEXT    NOT NULL CHECK (mode IN
                     ('NORMAL','CONSERVATIVE','RECOVERY_DRY','RECOVERY_FULL')),
    phase           TEXT    NOT NULL,                    -- R0..R8 (단계마다 커밋 → 멱등 재개)
                                                         -- 🔴 CHECK 없음 — 값 도메인의 정본은
                                                         --    `ResumePhase` 열거형이다(인벤토리 §2-7)
    counts          TEXT    NOT NULL,                    -- JSON executed/expired/superseded/blocked/unrecoverable
    headline        TEXT                                 -- 엔진 생성
);

CREATE TABLE IF NOT EXISTS data_gap (
    gap_id          TEXT    NOT NULL PRIMARY KEY,
    dataset         TEXT    NOT NULL,                    -- equity_snapshot|dart|etf_universe|prices|fx
    from_date       TEXT    NOT NULL,
    to_date         TEXT    NOT NULL,
    recoverable     INTEGER NOT NULL CHECK (recoverable IN (0,1)),
    reason_code     TEXT    NOT NULL,
    detected_at     TEXT    NOT NULL
);

-- X3 ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS onboarding_progress (
    step_id         TEXT    NOT NULL,
    track           TEXT    NOT NULL CHECK (track IN ('FRESH','RECONNECT','VIEWER_PAIRING')),
    state           TEXT    NOT NULL CHECK (state IN
                     ('NOT_STARTED','IN_PROGRESS','VERIFIED','FAILED','EXPIRED')),
    verified_at     TEXT,
    verified_until  TEXT,                                -- KIS 접근토큰 24h · PAT 만료일 등
    failure_reason_code TEXT,
    updated_at      TEXT    NOT NULL,
    PRIMARY KEY (step_id, track)
);
-- 🆕 G-01 — 온보딩 `O-00b` 「운영 방식 선택」의 저장처. 🔴 `onboarding_progress` 에는 컬럼이 없다.
CREATE TABLE IF NOT EXISTS onboarding_choice (
    id             INTEGER PRIMARY KEY CHECK (id = 1),
    operating_mode TEXT NOT NULL CHECK (operating_mode IN ('AUTO_TRADE','ADVISORY')),
    chosen_at      TEXT NOT NULL,
    committed_at   TEXT
);
-- 🔴 `committed_at` 이 채워지면(`O-04` 완료 — m2-8_naming I-6 ⏸) 이 표는 **읽기 전용**이 된다.
--    이후 변경은 `runtimeOperatingModeSwitchRequest` → `M5-11` 위저드 경로뿐이다(§4-3 · C-20).
-- 🔴 이 표는 «최초 선택»의 정본이고 «현재 운영 방식»의 정본은 `operating_mode_transition`(§6-6)이다.
--    전이 행이 0건이면 정본은 이 표이며, 두 표 어디에도 값이 없으면 그것은
--    «온보딩 미완»이지 «자동 매매»가 아니다(G-01·G-02).

-- 🔴 값은 저장하지 않는다. Keystore 별칭과 만료 메타만
CREATE TABLE IF NOT EXISTS credential_registry (
    alias           TEXT    NOT NULL PRIMARY KEY,        -- 'kis_live'|'github_pat'|'google_oauth'
    kind            TEXT    NOT NULL,
    keystore_ref    TEXT    NOT NULL,                    -- 🔴 별칭만. 시크릿 반입 금지
    expires_at      TEXT,
    last_verified_at TEXT,
    health          TEXT    NOT NULL DEFAULT 'UNKNOWN'
                            CHECK (health IN ('OK','EXPIRING','EXPIRED','INVALID','UNKNOWN'))
);
-- 🔴 `usage` 컬럼은 배치 F 가 ALTER 로 더한다(대사 전용 키 표기).

-- X4 ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS calendar_link (
    -- ~~id INTEGER PRIMARY KEY CHECK (id = 1)~~ 🆕 G-32 — 단일 행이면 모의 캘린더를 표현할 수 없다
    mode            TEXT    NOT NULL PRIMARY KEY CHECK (mode = 'LIVE'),   -- @sim calendar
    google_calendar_id TEXT NOT NULL,
    created_at      TEXT    NOT NULL,
    account_label   TEXT,                                -- 🔴 이메일 전체 저장 금지 — 마스킹 라벨
    scope           TEXT    NOT NULL DEFAULT 'calendar.app.created'
);
-- 🔴 **캘린더 앵커의 축은 «계열» 2값이다**(G-32) — `simInternal`·`simBroker` 는 모의 캘린더 1개를
--    공유한다. ✅ 파일별 CHECK(설계 13 §8 R20 Q1): `ledger.sqlite` = `'LIVE'` · `ledger_sim.sqlite` = `'SIM'`. `RunMode` 3값 → 계열 2값 매핑은 §9-2 의 **단일 매핑 함수**를 쓰며(G-31)
--    화면·매퍼가 각자 분기하지 않는다.
-- 🔵 **v1 에서는 `mode='LIVE'` 행 하나만 만든다**(06 X4-5). 컬럼은 later 확장을 위한 자리이고
--    **행이 없는 모드는 «미설정»으로 읽는다**(빈 상태를 오류로 그리지 않는다).

CREATE TABLE IF NOT EXISTS calendar_sync_state (
    mode            TEXT    NOT NULL PRIMARY KEY CHECK (mode = 'LIVE'),   -- @sim calendar
    last_ok_date    TEXT,                                -- 🔴 단조 전진 확정선
    recheck_days    INTEGER NOT NULL DEFAULT 7,          -- last_ok_date−7 재스캔 창
    cursor          TEXT,
    status          TEXT    NOT NULL DEFAULT 'OK'
                            CHECK (status IN ('OK','RECONNECT_REQUIRED','DEGRADED','STANDBY')),
    updated_at      TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS calendar_event_log (
    source_table    TEXT    NOT NULL,                    -- 🔴 PK 가 "원장 1행 = 이벤트 1건"을 강제
    source_id       TEXT    NOT NULL,
    aaq_key         TEXT    NOT NULL UNIQUE,
    google_event_id TEXT,
    content_hash    TEXT    NOT NULL,
    calendar_id     TEXT    NOT NULL,                    -- 🔴 캐시는 calendar_id 종속
    origin          TEXT    NOT NULL CHECK (origin IN
                     ('LIVE','ARCHIVE','BROKER_RECOVERED','INFERRED',
                      'MANUAL_ENTRY')),                  -- 🆕 G-28/X7 — §2-8 `CalendarOrigin.manualEntry` 와 1:1.
                                                         -- 🔴 없으면 수기 체결 이벤트가 CHECK 위반으로
                                                         --    QUARANTINED 에 빠지고 canonCalendar 가 매일
                                                         --    불일치하며 C-15 도 동시에 실패한다
    attempt_count   INTEGER NOT NULL DEFAULT 0,
    state           TEXT    NOT NULL DEFAULT 'PENDING'
                            CHECK (state IN ('PENDING','SYNCED','QUARANTINED','SKIPPED')),
    updated_at      TEXT    NOT NULL,
    PRIMARY KEY (source_table, source_id)
);
ALTER TABLE cash_flow ADD COLUMN recorded_at TEXT;       -- 🆕 지연 도착 흡수(X4 재검사 창)

-- X5 ────────────────────────────────────────────────────────────────
ALTER TABLE executions ADD COLUMN authored_at TEXT;      -- 🆕 기록된 날 귀속. FILL_LAG 가 과거 해시를 안 바꾸게
ALTER TABLE trades     ADD COLUMN authored_at TEXT;
-- 🔴 day_hash 대상 스트림의 **authored 축 컬럼 매핑**(청사진 X5 "예방"). 축이 표마다 다르면
--    Dart 재구현이 조용히 다른 스트림을 해싱한다 — X5-1 정규 직렬화 골든벡터의 입력이다.
--      executions·trades            → authored_at      (이번 배치 신설)
--      cash_flow                    → recorded_at      (위 X4 절에서 신설 — 이름이 다를 뿐 같은 축)
--      decision_log·rebalance_event → created_at       (배치 A 컬럼 재사용)
--      decision_journal·order_intents → created_at   (02 기본 표의 생성 시각 — 실측 확인 2026-10-21)
--    🔴 equity_snapshot 은 **제외**(횡단면 재계산 산출물). positions·ramp 도 제외.
-- 🔴 해시 체인 모집단 = 아카이브 대상(§6-7)이어야 한다. 어긋나면 canonGithub·canonCalendar 대조가
--    «불일치 아님»을 증명하지 못한다.

CREATE TABLE IF NOT EXISTS ledger_daily_hash (
    authored_date   TEXT    NOT NULL PRIMARY KEY,        -- 🔴 trade_date 가 아니라 authored_date
    day_hash        TEXT    NOT NULL,
    chain_hash      TEXT    NOT NULL,                    -- H(chain(D−1) ‖ day_hash(D))
    hash_format_version INTEGER NOT NULL,                -- 🔴 직렬화 규약 버전(✅ 1 에서 시작 · R19 E9-11)
    row_counts      TEXT    NOT NULL,                    -- JSON 테이블별 행 수
    created_at      TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS ledger_diff (
    diff_id         TEXT    NOT NULL PRIMARY KEY,
    pair            TEXT    NOT NULL CHECK (pair IN
                     ('CANON_BROKER','CANON_SUPABASE','CANON_GITHUB','CANON_CALENDAR')),
                                                         -- 🔴 배치 F(N-01)가 `CANON_SELF_REPORT` 를
                                                         --    더해 **5값으로 재작성**한다
    axis            TEXT    NOT NULL CHECK (axis IN ('QUANTITY','EXECUTION_ROW','CASH','CHAIN_HASH')),
    authored_date   TEXT    NOT NULL,
    delta           TEXT    NOT NULL,                    -- JSON
    delta_label     TEXT    NOT NULL,                    -- 엔진 생성
    severity        TEXT    NOT NULL CHECK (severity IN ('BLOCKING','OBSERVATIONAL')),
    origin_code     TEXT,                                -- §3-4 열거형(labels/origin_codes.dart)
    status          TEXT    NOT NULL CHECK (status IN ('OPEN','RESOLVED','ACCEPTED')),
    detected_at     TEXT    NOT NULL
);
-- 🔴 `applicable` 컬럼은 배치 F 가 ALTER 로 더한다(G-27) — **pair 재작성 뒤**여야 한다.

CREATE TABLE IF NOT EXISTS ledger_repair (
    repair_id       TEXT    NOT NULL PRIMARY KEY,        -- 🔴 append-only. 원본 행 수정 금지
    diff_id         TEXT    NOT NULL,
    direction       TEXT    NOT NULL CHECK (direction IN ('DERIVED_RESYNC','CANON_CORRECT')),
    origin_code     TEXT    NOT NULL,
    decision_id     TEXT,                                -- CANON_CORRECT 면 필수
    evidence_hash   TEXT    NOT NULL,                    -- 🔴 브로커 근거 원문은 로컬 전용
    supersedes      TEXT,                                -- 되돌리기 없음 = 정정의 정정
    applied_at      TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS sync_state (
    target          TEXT    NOT NULL PRIMARY KEY,        -- SUPABASE|GITHUB|CALENDAR
    last_ok_at      TEXT,
    status          TEXT    NOT NULL CHECK (status IN
                     ('OK','PUSH_LAG','PUSH_FAILED','FORK','SEALED')),
    operator_epoch  INTEGER NOT NULL DEFAULT 0,          -- 🔴 낮은 epoch 의 파생 쓰기 거부
    updated_at      TEXT    NOT NULL
);

COMMIT;
PRAGMA foreign_keys = ON;
