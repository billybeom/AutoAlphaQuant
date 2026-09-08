-- ════════════════════════════════════════════════════════════════════════════
-- 배치 F — X7 투자 안내(수동 매매) · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-6
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 §6-0 은 「실전 첫 거래 전에 적용」이라 못 박았는데 **안내 모드의 첫 거래도 실전 첫 거래다**
--    (실계좌·실돈). 온보딩 첫날에 «투자 안내»를 고를 수 있으므로 X7 스키마를 나중 창으로 미루면
--    「사유가 DB 어디에도 안 남는 첫날」이 그대로 재현된다.
--    **마이그레이션 창은 여전히 1회이고, 배치 F 는 그 창의 여섯 번째 묶음이다.**
-- 🔴 아래는 `ledger.sqlite` 판이다. `ledger_sim.sqlite` 판은 파일 맨 아래 «SIM 판 차이» 참조.
-- 🔴 새 컬럼이 직렬화 규약에 들어가므로 **`hash_format_version` 을 올리고 골든벡터를 다시 고정**한다.
-- 🔴 이 배치의 Supabase 몫(«배치 D 추가분»)은 `batch_d_supabase.sql` 에 있다.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS advice_batch (
    batch_id        TEXT    NOT NULL PRIMARY KEY,
    trade_date      TEXT    NOT NULL,
    mode            TEXT    NOT NULL CHECK (mode = 'LIVE'),
    operating_mode  TEXT    NOT NULL CHECK (operating_mode = 'ADVISORY'),  -- 🔴 자동 모드엔 안내가 없다
                                                         -- 🔴 금지 조합은 CHECK 로도 막는다(§10-2 #7·#8)
    intent_batch_id TEXT    NOT NULL,                    -- 🆕 A11 — 🔴 `exec_policy` 컬럼을 두지 않는다.
                                                         --    「이 안내 묶음의 정책은 저 intent 묶음이 말한다」
                                                         --    (§8-7 해소를 되돌리지 않는다)
    handover_session_id TEXT,                            -- 🆕 B20 — 조건부 조합 #12(안내 리허설)의 유일한 근거
    issued_at       TEXT    NOT NULL,
    headline        TEXT    NOT NULL,                    -- 🔴 엔진 생성 문구
    resume_run_id   TEXT,                                -- X2 재개 회차가 낸 배치면 연결
    config_hash     TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_advice_batch_date ON advice_batch(trade_date);

CREATE TABLE IF NOT EXISTS advice (
    advice_id       TEXT    NOT NULL PRIMARY KEY,
    batch_id        TEXT    NOT NULL,
    intent_id       TEXT,                                -- 🔴 §10-4. order_intents 의 자식
                                                         --    🆕 G-08 — `NO_ACTION` 은 intent 가 없다
    decision_id     TEXT    NOT NULL,                    -- 🔴 사유의 정본은 decision_log(자동과 동일)
    mode            TEXT    NOT NULL CHECK (mode = 'LIVE'),
    trade_date      TEXT    NOT NULL,
    valid_until_date TEXT   NOT NULL,                    -- 🔴 거래일 달력(달력일 아님)
    kind            TEXT    NOT NULL CHECK (kind IN
                     ('ENTRY','EXIT','REBALANCE','DEPOSIT','WITHDRAWAL','FUNDING','NO_ACTION')),
    symbol          TEXT,
    sleeve          TEXT    NOT NULL CHECK (sleeve IN ('A','B','C','POT','CASH','SAT')),
    side            TEXT    CHECK (side IS NULL OR side IN ('BUY','SELL')),
    quantity        INTEGER CHECK (quantity IS NULL OR quantity > 0),
    price_low       REAL,
    price_high      REAL,
    price_ref       REAL,
    is_urgent       INTEGER NOT NULL DEFAULT 0 CHECK (is_urgent IN (0,1)),
    reason          TEXT    NOT NULL,                    -- 엔진 생성 문구
    reason_code     TEXT    NOT NULL,
    depends_on_advice_id TEXT,                           -- 🔴 조달 순서 의존(PENSION_FUNDING 등)
    account_alias   TEXT,
    status          TEXT    NOT NULL CHECK (status IN
                     ('OPEN','PARTIAL','FILLED','SKIPPED','EXPIRED','SUPERSEDED','REVOKED')),
    -- 🔴 A4 — 저장된 status 는 «스윕이 따라온 결과»다. 화면이 보는 만료 판정은
    --    `as_of` vs `valid_until_date` 의 **파생**(`effectiveStatus`)이며 이 컬럼이 아니다
    close_reason_code TEXT,                              -- 🆕 G-20 `HANDOVER_CLOSED` = 집행 주체 전환
                                                         --    커밋이 회수한 안내(사람의 미이행이 아니다)
    superseded_by   TEXT,
    suppressed      INTEGER NOT NULL DEFAULT 0 CHECK (suppressed IN (0,1)),
    suppressed_label TEXT,                               -- 🆕 G-08 — `NO_ACTION` 행에서 필수
    sizing_label    TEXT    NOT NULL,                    -- 🆕 G-08/G-85 — 수량이 NULL 인 행의 유일한 표현
    config_hash     TEXT    NOT NULL,
    created_at      TEXT    NOT NULL                     -- 🔴 X5 authored 축
);
-- 🔴 **G-08 — NULL 이 허용되는 조건은 둘뿐이다.**
--    ① `kind='NO_ACTION'` : symbol·quantity·side·intent_id 전부 NULL · `suppressed=1` ·
--       `suppressed_label` 필수. «오늘은 아무것도 하지 마십시오»가 이 행이다.
--    ② `unverifiable`·`drifting` 등급의 청산 안내 : quantity 만 NULL 이고 `sizing_label` 이
--       «보유 전량»/«보유의 절반»을 말한다(D17).
--    그 밖의 행은 네 컬럼이 **전부 NOT NULL** 이며 **엔진 선행 가드가 강제한다**
--    (CHECK 로는 조건부 NOT NULL 을 표현하지 않는다 — 표현하려다 CHECK 가 사양서가 된다).
-- 🔴 표현 불가를 더미 값으로 메우면 이행 갭의 분모가 오염되고, 이중 매수 방어 ①(종목당 1건)이
--    **유령 종목**에 걸린다.
CREATE INDEX IF NOT EXISTS ix_advice_status ON advice(status, valid_until_date);
CREATE INDEX IF NOT EXISTS ix_advice_intent ON advice(intent_id);
CREATE INDEX IF NOT EXISTS ix_advice_symbol ON advice(symbol, trade_date);

-- 🔴 현재값만 UPDATE 하면 «만료를 지나 FILLED 로 갔는가»를 증명할 수 없다
--    (X2 `planned_work_transition` 동형)
CREATE TABLE IF NOT EXISTS advice_transition (
    transition_id   TEXT    NOT NULL PRIMARY KEY,
    advice_id       TEXT    NOT NULL,
    from_status     TEXT,
    to_status       TEXT    NOT NULL,
    cause_code      TEXT    NOT NULL CHECK (cause_code IN
                     ('RECORD','SKIP','LAPSE','SUPERSEDE','REVOKE','AMEND','LATE_FILL',
                      'HANDOVER_CLOSE','DEFER_CONFIRM')),
                    -- 🆕 A4 `LATE_FILL` — 만료 뒤 기록은 **상태를 바꾸지 않고**
                    --    from='EXPIRED', to='EXPIRED' 행 1건으로 사실만 남긴다
                    -- 🆕 G-20 `HANDOVER_CLOSE` — 집행 주체 전환 커밋이 살아 있는 안내를 **회수**한 사실.
                    --    🔴 사람의 미이행이 아니므로 예산 미차감·이행률 분모 제외다
                    -- 🆕 G-86 `DEFER_CONFIRM` — 만료 확인 카드를 하루 미룬 사실. 🔴 상태는 바꾸지 않고
                    --    (from='EXPIRED', to='EXPIRED') **행의 존재 자체가 «이미 한 번 미뤘다»의 정본**이다.
                    --    기기 로컬에 두면 재설치·기기 이전으로 사라져 무한 연기가 된다
    command_id      TEXT,
    fill_id         TEXT,
    decision_id     TEXT,
    occurred_at     TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_advice_transition ON advice_transition(advice_id, occurred_at);

-- ── 수기 체결 = 기존 원장에 provenance 만 붙인다 (🔴 별도 표를 만들지 않는다 · §10-3) ──
ALTER TABLE executions ADD COLUMN fill_origin TEXT NOT NULL DEFAULT 'BROKER'
                        CHECK (fill_origin IN ('BROKER','MANUAL','SIMULATED','BROKER_RECOVERED'));
ALTER TABLE executions ADD COLUMN fill_kind   TEXT NOT NULL DEFAULT 'ORIGINAL'
                        CHECK (fill_kind IN ('ORIGINAL','REVERSAL','RESTATEMENT'));
ALTER TABLE executions ADD COLUMN advice_id             TEXT;
ALTER TABLE executions ADD COLUMN reverses_fill_id      TEXT;
ALTER TABLE executions ADD COLUMN restates_fill_id      TEXT;
ALTER TABLE executions ADD COLUMN authored_by_device_id TEXT;
ALTER TABLE executions ADD COLUMN backdate_trading_days INTEGER NOT NULL DEFAULT 0;
ALTER TABLE executions ADD COLUMN cost_source TEXT NOT NULL DEFAULT 'BROKER'   -- 🆕 C18
                        CHECK (cost_source IN ('BROKER','USER_ENTERED','ESTIMATED'));
                        -- 🔴 구 `costs_overridden`(bool) 폐기 — false 가 «브로커 확정»과 «엔진 추정»
                        --    둘 다를 뜻해 화면이 영원히 구별할 수 없었다
ALTER TABLE executions ADD COLUMN off_hour_trade   INTEGER NOT NULL DEFAULT 0 CHECK (off_hour_trade IN (0,1));
ALTER TABLE executions ADD COLUMN during_halt      INTEGER NOT NULL DEFAULT 0 CHECK (during_halt IN (0,1));
                        -- 🆕 B9 — 🔴 **사후 판정 불가**. 킬스위치·HALT 활성 구간에 authored 된 기록에
                        --    엔진이 **접수 시점에** 1을 찍는다. 재개 게이트는 이 행 전량의 저널 완료를 요구한다
ALTER TABLE executions ADD COLUMN price_range_source_date TEXT;   -- 🆕 B4 — 🔴 가격 검증의 근거일
ALTER TABLE trades     ADD COLUMN fill_origin TEXT NOT NULL DEFAULT 'BROKER';
ALTER TABLE trades     ADD COLUMN fill_kind   TEXT NOT NULL DEFAULT 'ORIGINAL';
ALTER TABLE order_intents ADD COLUMN operating_mode TEXT NOT NULL DEFAULT 'AUTO_TRADE'
                        CHECK (operating_mode IN ('AUTO_TRADE','ADVISORY'));
-- 🔴 X5 authored 축 매핑에 변화 없음(executions·trades = authored_at).

-- ── 시스템 밖 자산(대사 화이트리스트) ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS external_holding (
    external_id     TEXT    NOT NULL PRIMARY KEY,
    symbol          TEXT    NOT NULL,
    account_alias   TEXT    NOT NULL,
    quantity        INTEGER NOT NULL,
    decision_id     TEXT    NOT NULL,              -- 🔴 등록도 결정이다(kind='MANUAL')
    note            TEXT,
    registered_at   TEXT    NOT NULL,
    released_at     TEXT                           -- 편입(채택) 시 채우고 원장으로 옮긴다
);
-- 🔴 B11 — **유니버스 종목은 여기 등록할 수 없다**(앱 층 판정 +
--    `SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL`). 허용하면 같은 종목이 관리 대상과 «시스템 밖»에
--    동시에 있어 2배 노출이 된다.

-- ── 원장 실사(자가보고) ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS self_report_balance (
    report_id       TEXT    NOT NULL PRIMARY KEY,
    as_of_trade_date TEXT   NOT NULL,
    account_alias   TEXT    NOT NULL,
    session_started_at TEXT NOT NULL,               -- 🆕 B15 — 🔴 세션 밖 제출 거부의 근거
    cash_krw        REAL    NOT NULL,
    declared_complete INTEGER NOT NULL CHECK (declared_complete IN (0,1)),
    device_id       TEXT    NOT NULL,
    command_id      TEXT    NOT NULL,
    reported_at     TEXT    NOT NULL                -- 🔴 X5 authored 축
);
CREATE TABLE IF NOT EXISTS self_report_line (
    report_id       TEXT    NOT NULL,
    symbol          TEXT    NOT NULL,
    quantity        INTEGER NOT NULL,
    PRIMARY KEY (report_id, symbol)
);

-- ── 대사 전용 키 표기 ──────────────────────────────────────────────────────────
ALTER TABLE credential_registry ADD COLUMN usage TEXT NOT NULL DEFAULT 'FULL'
                                 CHECK (usage IN ('RECONCILE_ONLY','FULL'));
-- ⚠️ KIS 가 앱키 단위로 조회·주문 권한을 가르는지는 실측 대상(실험 6). 가르지 않는다면
--    RECONCILE_ONLY 는 «권한»이 아니라 **런타임 봉인 선언**이다 — §9-3 키 봉인과 동형.

-- ── 🆕 G-02 운영 방식 세션·전환 이력 (🔴 커밋이 쓸 자리) ──────────────────────────
CREATE TABLE IF NOT EXISTS handover_session (
    handover_session_id TEXT NOT NULL PRIMARY KEY,
    kind        TEXT NOT NULL CHECK (kind IN ('GATE_M5_10','WIZARD_M5_11')),
    path        TEXT CHECK (path IN ('SIM_TO_AUTO','ADOPT_LEDGER','FRESH_AUTO','HANDBACK_MANUAL')),
    device_id   TEXT NOT NULL,
    lease_epoch INTEGER NOT NULL,
    opened_at   TEXT NOT NULL,
    expires_at  TEXT NOT NULL,
    closed_at   TEXT,
    close_code  TEXT CHECK (close_code IN ('COMMITTED','CANCELLED','EXPIRED','ROLLED_BACK'))
);
CREATE TABLE IF NOT EXISTS operating_mode_transition (
    transition_id TEXT NOT NULL PRIMARY KEY,
    handover_session_id TEXT NOT NULL,
    from_mode   TEXT NOT NULL,
    to_mode     TEXT NOT NULL,
    decision_id TEXT NOT NULL,
    committed_at TEXT NOT NULL
);
-- 🔴 **현재 `OperatingMode` 의 정본은 `operating_mode_transition` 의 최신 행**이며
--    `FeatureFlags.operatingMode`·`rm_config_view.operating_mode` 는 그 파생이다(G-02).
-- 🔴 전이 행이 0건이면 정본은 `onboarding_choice.operating_mode`(`committed_at` 채워진 행)다.
--    두 표 어디에도 값이 없으면 그것은 «온보딩 미완»이지 «자동 매매»가 아니다.
-- 🔴 세션 토큰은 `handover_session` 에 열려 있고 `expires_at` 전일 때만 유효하다 —
--    조합 #12(§10-2)와 C-19 가 검사하는 대상이 이것이다.

-- ── 🆕 N-01 `ledger_diff.pair` CHECK 재작성 (§2-9 `LedgerPair` **5값**) ────────────
-- 🔴 SQLite 의 CHECK 는 ALTER 로 못 바꾸므로 **새 테이블 → 복사 → RENAME**(배치 E 와 같은 방식).
-- 🔴 이 재작성이 **없으면** 아래 «칸 수 5 고정»을 위해 넣는 `applicable=0` 의
--    `CANON_SELF_REPORT` 행이 **CHECK 위반으로 실패**하고 대조 보드가 조용히 **4칸으로 퇴화**한다.
-- 🔴 순서상 이 재작성이 아래 ALTER 보다 **먼저**다.
CREATE TABLE IF NOT EXISTS ledger_diff__new (
    diff_id         TEXT    NOT NULL PRIMARY KEY,
    pair            TEXT    NOT NULL CHECK (pair IN
                     ('CANON_BROKER','CANON_SUPABASE','CANON_GITHUB','CANON_CALENDAR',
                      'CANON_SELF_REPORT')),
    axis            TEXT    NOT NULL CHECK (axis IN ('QUANTITY','EXECUTION_ROW','CASH','CHAIN_HASH')),
    authored_date   TEXT    NOT NULL,
    delta           TEXT    NOT NULL,
    delta_label     TEXT    NOT NULL,
    severity        TEXT    NOT NULL CHECK (severity IN ('BLOCKING','OBSERVATIONAL')),
    origin_code     TEXT,
    status          TEXT    NOT NULL CHECK (status IN ('OPEN','RESOLVED','ACCEPTED')),
    detected_at     TEXT    NOT NULL
);
INSERT INTO ledger_diff__new
SELECT diff_id, pair, axis, authored_date, delta, delta_label, severity,
       origin_code, status, detected_at
  FROM ledger_diff;
DROP TABLE ledger_diff;
ALTER TABLE ledger_diff__new RENAME TO ledger_diff;
-- 🔴 `CANON_SELF_REPORT` 의 기본 심각도는 `OBSERVATIONAL` 이다(§6-5 X7 행).

-- ── 🆕 G-27 대조 보드 칸 고정 (§2-9 `LedgerDiffRow.applicable`) ──────────────────
ALTER TABLE ledger_diff ADD COLUMN applicable INTEGER NOT NULL DEFAULT 1 CHECK (applicable IN (0,1));
-- 🔴 «해당 없음»과 «일치»를 가르는 값이다. 대조 보드의 칸 수는 모드와 무관하게 **5 고정**이고,
--    이 값이 0 인 칸은 «점검 안 함»으로 그린다(빈칸·통과로 그리지 않는다 — 05 §3 S10).
--    자동 모드에서 `CANON_SELF_REPORT` 행은 `applicable=0` 으로 **행 자체는 생성한다** —
--    행이 없으면 화면이 칸 수를 상수로 알아야 하고, 그것이 05 §3 S10 이 금지한 구현이다.

COMMIT;
PRAGMA foreign_keys = ON;

-- ════════════════════════════════════════════════════════════════════════════
-- `ledger_sim.sqlite` 판 차이 (§6-6 머리 조문 · §9-5 ④ · C8)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 위 SQL 은 `ledger.sqlite` 판이다. 모의 원장 파일에 적용할 때 달라지는 것:
--   · `advice_batch.mode` · `advice.mode` → `CHECK (mode = 'SIM_INTERNAL')` 로 좁힌다.
--     🔴 `simBroker × advisory`(§10-2 #7·#8)는 **정의 모순으로 금지**이므로 DB 도 그 행을 받지 않는다.
--   · `order_intents` 판 권고: `CHECK (operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL')` (C8)
-- ⚠️🔴 그러나 배치 A·B 의 `mode` CHECK 는 아직 `('SIM','LIVE')` 2값이다
--    (인벤토리 §10-2 ② 열린 물음 · 01 §9-1 «확정 전에는 DDL 을 고치지 않는다»).
--    🔴 즉 **`SIM_INTERNAL` 이라는 값이 쓰일 수 있으려면 그 물음이 먼저 닫혀야 한다** —
--    두 곳을 따로 고치면 배치 A 표에는 못 넣는 값을 배치 F 표만 받게 되어 파일 안에서 축이 갈린다.
--    확정될 때 batch_a·batch_b·이 파일·픽스처 `meta.mode`·C-15 를 **한 커밋에서** 고친다.
