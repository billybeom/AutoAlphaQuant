-- ════════════════════════════════════════════════════════════════════════════
-- 배치 E — 열거형 확장 (기존 CHECK 재작성 = 테이블 재생성) · 로컬 SQLite
-- ⛔ **보관 — 구현하지 않는다**(설계 13 §8 R19 E9-10 · 2026-10-21). 기존 설치가 하나도 없으므로
--    v1 은 새 설치 한 판(02 기본 + A·B·C·F)이다. 이 파일은 «기존 설치였다면» 의 기록이며
--    로컬 마이그레이션 러너(E9c)는 이 파일을 읽지 않는다.
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-5
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 **이 파일은 «기존 표가 이미 있는 설치»의 경로다.** 새로 만드는 설치는 batch_a~c 가
--    넓힌 형태로 곧장 만들므로 이 파일을 돌릴 필요가 없다.
-- 🔴 SQLite 는 `CHECK` 를 `ALTER` 로 바꿀 수 없다 — **새 테이블 → 복사 → RENAME**.
--    `PRAGMA foreign_keys=OFF` 창을 스크립트에 명시한다(§6-5 말미).
-- 🔴 적용 순서(§6-5) = ① 신설 표 → ② **CHECK 재작성(이 파일)** → ③ ALTER → ④ RLS → ⑤ mode 키.
--
-- 이 창의 CHECK 재작성은 **4건**이다(§6-5 말미 · S8 재추적 N-01):
--   G-28 `calendar_event_log.origin`            ← 이 파일
--   G-30 `command_inbox.state`                  ← 이 파일
--   G-32 `calendar_link`·`calendar_sync_state`  ← 이 파일 (PK 변경)
--   N-01 `ledger_diff.pair`                     ← **batch_f**(배치 F 창 안에서 · applicable ALTER 보다 먼저)

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- ── G-30 `command_inbox.state` — 보류 3값 + 컬럼 3개 ────────────────────────────
-- 구 CHECK: ('RECEIVED','EXECUTED','REJECTED','EXPIRED')
-- 🔴 이 표의 state 집합은 `command_queue` 의 state 집합과 **항상 같게** 유지한다.
CREATE TABLE IF NOT EXISTS command_inbox__new (
    command_id      TEXT    NOT NULL PRIMARY KEY,
    kind            TEXT    NOT NULL,
    ingested_at     TEXT    NOT NULL,
    state           TEXT    NOT NULL CHECK (state IN ('RECEIVED','EXECUTED','REJECTED','EXPIRED',
                     'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM')),
    state_label     TEXT    NOT NULL,
    reject_reason_code TEXT,
    decision_id     TEXT,
    run_mode        TEXT,                                -- 🆕 G-30(X7 A10) 발행 시점 맥락
    operating_mode  TEXT,
    lease_epoch     INTEGER,
    payload_digest  TEXT    NOT NULL
);
INSERT INTO command_inbox__new
    (command_id, kind, ingested_at, state, state_label, reject_reason_code,
     decision_id, run_mode, operating_mode, lease_epoch, payload_digest)
SELECT command_id, kind, ingested_at, state, state_label, reject_reason_code,
       decision_id, NULL, NULL, NULL, payload_digest
  FROM command_inbox;
DROP TABLE command_inbox;
ALTER TABLE command_inbox__new RENAME TO command_inbox;
-- ⚠️🔴 `NO_OPERATOR` 는 여기 넣지 않았다 — 인벤토리 §10-2 ①(열린 물음). batch_b 주석 참조.

-- ── G-28 `calendar_event_log.origin` — `MANUAL_ENTRY` 추가 ──────────────────────
-- 🔴 PK `(source_table, source_id)` 와 `aaq_key` UNIQUE 를 **함께 옮긴다**.
-- 🔴 없으면 수기 체결 이벤트가 CHECK 위반으로 QUARANTINED 에 빠지고 canonCalendar 가
--    매일 불일치하며 C-15 도 동시에 실패한다.
CREATE TABLE IF NOT EXISTS calendar_event_log__new (
    source_table    TEXT    NOT NULL,
    source_id       TEXT    NOT NULL,
    aaq_key         TEXT    NOT NULL UNIQUE,
    google_event_id TEXT,
    content_hash    TEXT    NOT NULL,
    calendar_id     TEXT    NOT NULL,
    origin          TEXT    NOT NULL CHECK (origin IN
                     ('LIVE','ARCHIVE','BROKER_RECOVERED','INFERRED','MANUAL_ENTRY')),
    attempt_count   INTEGER NOT NULL DEFAULT 0,
    state           TEXT    NOT NULL DEFAULT 'PENDING'
                            CHECK (state IN ('PENDING','SYNCED','QUARANTINED','SKIPPED')),
    updated_at      TEXT    NOT NULL,
    PRIMARY KEY (source_table, source_id)
);
INSERT INTO calendar_event_log__new
SELECT source_table, source_id, aaq_key, google_event_id, content_hash, calendar_id,
       origin, attempt_count, state, updated_at
  FROM calendar_event_log;
DROP TABLE calendar_event_log;
ALTER TABLE calendar_event_log__new RENAME TO calendar_event_log;

-- ── G-32 `calendar_link` — `CHECK (id = 1)` → `mode` PK (PK 변경이므로 재생성) ────
-- 🔵 v1 은 `mode='LIVE'` 행 하나다 — 구 단일 행을 그 값으로 옮긴다.
CREATE TABLE IF NOT EXISTS calendar_link__new (
    mode            TEXT    NOT NULL PRIMARY KEY CHECK (mode IN ('LIVE','SIM')),
    google_calendar_id TEXT NOT NULL,
    created_at      TEXT    NOT NULL,
    account_label   TEXT,
    scope           TEXT    NOT NULL DEFAULT 'calendar.app.created'
);
INSERT INTO calendar_link__new (mode, google_calendar_id, created_at, account_label, scope)
SELECT 'LIVE', google_calendar_id, created_at, account_label, scope
  FROM calendar_link;
DROP TABLE calendar_link;
ALTER TABLE calendar_link__new RENAME TO calendar_link;

-- ── G-32 `calendar_sync_state` — 같은 방식 ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS calendar_sync_state__new (
    mode            TEXT    NOT NULL PRIMARY KEY CHECK (mode IN ('LIVE','SIM')),
    last_ok_date    TEXT,
    recheck_days    INTEGER NOT NULL DEFAULT 7,
    cursor          TEXT,
    status          TEXT    NOT NULL DEFAULT 'OK'
                            CHECK (status IN ('OK','RECONNECT_REQUIRED','DEGRADED','STANDBY')),
    updated_at      TEXT    NOT NULL
);
INSERT INTO calendar_sync_state__new (mode, last_ok_date, recheck_days, cursor, status, updated_at)
SELECT 'LIVE', last_ok_date, recheck_days, cursor, status, updated_at
  FROM calendar_sync_state;
DROP TABLE calendar_sync_state;
ALTER TABLE calendar_sync_state__new RENAME TO calendar_sync_state;

COMMIT;
PRAGMA foreign_keys = ON;

-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 DDL 이 **아닌** 배치 E 항목 — 코드가 있어야 완결된다
-- ════════════════════════════════════════════════════════════════════════════
--
-- ⓐ `trading_block.flag_id` · `origin_code` 확장 (§6-5 1·2행 · X7 5종)
--    🔴 **실측 정정** — `06_시스템설계/02_데이터모델.md` §2-6 의 `trading_block` 은
--       `flag_id TEXT NOT NULL PRIMARY KEY` · `origin_code TEXT` 이고 **CHECK 제약이 없다**.
--       열거는 그 표의 **주석**과 04 §3-1 2단계 판정 SQL 이 함께 갖는다.
--       따라서 이 두 행은 **테이블 재생성 대상이 아니다** — 고칠 것은
--         · 02 §2-6 의 열거 주석(추가: RESUME_INCOMPLETE · LEDGER_FIX · LEDGER_INTEGRITY
--           + X7 5종 ADVICE_LEDGER_UNVERIFIED · SELF_AUDIT_OVERDUE · SELF_AUDIT_DUE ·
--           SELF_AUDIT_PATTERN_UNVERIFIED · ADVICE_SELECTIVE_EXECUTION)
--         · `origin_code` 주석(추가: EXTERNAL_CASHFLOW · CORPORATE_ACTION + 파생 7종)
--         · 아래 ⓑ 의 판정 SQL
--       🔴 목록의 코드 정본은 `lib/src/labels/flag_ids.dart`·`origin_codes.dart` 다.
--
-- ⓑ 04 §3-1 2단계 판정 SQL — 🔴 **플래그만 읽고 SQL 을 안 고친 구현은 실격**(§6-5 3·7행)
--    전 주문 차단에 추가: RESUME_INCOMPLETE · LEDGER_INTEGRITY
--    신규 진입 안내 중단에 추가: ADVICE_LEDGER_UNVERIFIED · SELF_AUDIT_OVERDUE
--    판정형:
--      SELECT 1 FROM trading_block
--       WHERE cleared_at IS NULL
--         AND flag_id IN ('RECON_MISMATCH','RESUME_INCOMPLETE','LEDGER_INTEGRITY')  -- 전 주문
--       LIMIT 1;
--      SELECT 1 FROM trading_block
--       WHERE cleared_at IS NULL
--         AND flag_id IN ('JOURNAL_MISSING','TIER_B_UNJUDGED',
--                         'ADVICE_LEDGER_UNVERIFIED','SELF_AUDIT_OVERDUE')          -- 신규 진입
--       LIMIT 1;
--    🔴 `DST_WEEK`·`SELF_AUDIT_DUE`·`SELF_AUDIT_PATTERN_UNVERIFIED`·
--       `ADVICE_SELECTIVE_EXECUTION` 은 **상태 표식이며 이 SQL 이 보지 않는다**.
--    🔴 v2.15 SF-01 — 판정 SQL 은 **주문 경로에서 직접 실행**하고 그 반환값으로 차단한다
--       (배치가 세운 플래그만 읽는 구현은 사람이 행을 지우면 다음 배치까지 통과한다).
--
-- ⓒ 04 §5-3 알림 등급 개편 — `INFO`/`ALERT`/`DIGEST` → **P0/P1/P2** + 매핑표 동봉(결정 7c)
--    🔴 스키마가 아니라 **엔진 notify 설정**이다. 앱 측 코드 목록은
--       `lib/src/labels/alert_codes.dart` 이고, 🔴 **등급의 최종 정본은 엔진 04_안전장치 notify** 다.
--    🔴 «앱 알림 코드 ↔ 엔진 등급 대조 1회»(06 §4 ③) 전에는 화면이 등급별 표현을 상수로 박지 않는다.
--
-- ⓓ `decision_log.kind` — 🔴 **추가 없음**(§6-5 8행). 정정 2행 · `external_holding` 등록 ·
--    경로 b 귀속은 전부 기존 `MANUAL` 재사용이다(C7). `PENSION_FUNDING` 도 `kind` 가 아니라
--    `reason_code` 로 온다(§3-6 · labels/ledger_event_codes.dart).
