-- ════════════════════════════════════════════════════════════════════════════
-- 배치 A — 결정 7 승인 4건 + `mode`(Q-E) · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-1
-- 스타일: 06_시스템설계/02_데이터모델.md (컬럼 정렬 · CHECK 인라인 · 🔴 주석 · 후행 CREATE INDEX)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 마이그레이션 창은 **1회**이고 배치 A~F 는 그 창의 여섯 묶음이다(§6-0).
-- 🔴 적용 순서(§6-5 말미) = ① 신설 표 → ② CHECK 재작성(테이블 재생성) → ③ ALTER
--    → ④ Supabase RLS → ⑤ Supabase `mode` 키 + 전량 재push.
--    이 파일은 ①·③ 에 해당한다.
-- 🔴 `schema_version` 번호는 창 전체에 **하나만** 배정한다(부분 반영 상태를 남기지 않는다).
--    ⛔ 번호는 아직 배정되지 않았다 — 01 §6-0 «§9 최신값 +1, v2.31 소비 여부 먼저 확인».
-- 🔴 **실전 첫 거래 전에 적용한다** — `decision_log` 가 없으면 청산 사유가 첫날부터 소실된다.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- 🔴 결정 사유의 정본. 지금껏 청산 사유는 DB 어디에도 저장되지 않았다(청사진 §6)
CREATE TABLE IF NOT EXISTS decision_log (
    decision_id     TEXT    NOT NULL PRIMARY KEY,
    created_at      TEXT    NOT NULL,                    -- ISO8601 (UTC) · 🔴 X5 authored 축
    trade_date      TEXT    NOT NULL,                    -- 해당 시장 현지 거래일
    mode            TEXT    NOT NULL DEFAULT 'SIM'       -- 🆕 Q-E. 🔴 fail-closed 기본 SIM
                            CHECK (mode IN ('SIM','LIVE')),
    kind            TEXT    NOT NULL CHECK (kind IN
                     ('ENTRY','EXIT','REBALANCE','DEPOSIT','WITHDRAWAL',
                      'SAFETY','RESUME','LEDGER_FIX','MANUAL')),
    strategy_id     TEXT    NOT NULL,
    sleeve          TEXT    CHECK (sleeve IN ('A','B','C','POT','CASH','SAT')),  -- 🔵 SAT 보존
    symbol          TEXT,
    reason          TEXT    NOT NULL,                    -- 🔴 엔진 생성 문구. 화면은 그대로 표시
    reason_code     TEXT    NOT NULL,                    -- §3 매핑의 code
    tier            TEXT,                                -- '0','1A','1B','1.5','2','3'
    exit_kind       TEXT    CHECK (exit_kind IN
                     ('STOP','TREND_BREAK','TARGET','CORPORATE','RISK','REBALANCE')),
    trigger_price   REAL,                                -- 🔴 발동 근거가 된 기준선(체결가 아님)
    threshold_registered REAL,                           -- 🔴 사전 등록 임계값. 사후 변경 감사용
    rule_cited      TEXT,                                -- '03 §4-1 TIER 1B'
    regime_ref      TEXT,                                -- regime_score_daily(trade_date) 참조
    config_hash     TEXT    NOT NULL,
    parent_decision_id TEXT,                             -- 🆕 X2 재판정 child → 원행
    journal_id      TEXT                                 -- decision_journal (이탈 시 필수)
);
CREATE INDEX IF NOT EXISTS ix_decision_date_kind ON decision_log(trade_date, kind);
CREATE INDEX IF NOT EXISTS ix_decision_parent    ON decision_log(parent_decision_id);

ALTER TABLE positions       ADD COLUMN entry_decision_id TEXT;   -- 🔴 매수 사유 역추적
ALTER TABLE order_intents   ADD COLUMN mode TEXT NOT NULL DEFAULT 'SIM' CHECK (mode IN ('SIM','LIVE'));
ALTER TABLE trades          ADD COLUMN mode TEXT NOT NULL DEFAULT 'SIM' CHECK (mode IN ('SIM','LIVE'));
ALTER TABLE equity_snapshot ADD COLUMN mode TEXT NOT NULL DEFAULT 'SIM' CHECK (mode IN ('SIM','LIVE'));
-- ⚠️ 기존 order_intents.dry_run(INTEGER)과의 관계: mode 가 상위 축, dry_run 은 잡 단위 플래그.
--    🔴 §9-5 ① 채택 계약 = **`dry_run` 컬럼을 폐지하지 않고 `ExecPolicy` 로 이름만 승격**한다.
--    파생 규칙 명문화는 M2-1 창(§8-7 · m2-8_naming I-5).

-- ⚠️🔴 **열린 물음 — `mode` CHECK 를 2값으로 둘 것인가 3값으로 넓힐 것인가**
--    (인벤토리 §10-2 ②. 🔴 임의 확정 금지)
--    · 위 CHECK 는 01 §6-1 원문 그대로의 **2값**(`SIM`·`LIVE`)이다.
--    · §9-5 ④ 의 **권고**는 «3값 + 파일별 CHECK» 다:
--        `ledger.sqlite`      → CHECK (mode = 'LIVE')
--        `ledger_sim.sqlite`  → CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER'))
--                               (배치 F 판은 `= 'SIM_INTERNAL'` 로 좁힌다 — C8)
--    · 🔴 그러나 01 §9-1 은 «**확정 전에는 DDL 을 고치지 않는다**» 이고
--      §9-5 ④ 도 «⚠️ M2-8 확정 전 DDL 불변» 을 병기한다. m2-8_naming I-3 은 ⏸(권고 확정)이다.
--    · 🔴 그래서 이 파일은 **2값을 유지한다**. 3값으로 넓히면 배치 A·B 가 CHECK 재작성
--      (= 테이블 재생성) 대상이 되고 픽스처 `meta.mode`("LIVE")·C-15 도 함께 움직인다.
--      확정이 오면 **이 파일과 batch_b, 그리고 픽스처를 같은 커밋에서** 고친다.

-- 보유 종목 일별 신호 상태. 🔵 v2.31 P0S: 개별주 소멸로 화면은 축소되나 스키마는 유지(부록 N 조치 2)
CREATE TABLE IF NOT EXISTS holding_signal_daily (
    trade_date      TEXT    NOT NULL,
    symbol          TEXT    NOT NULL,
    strategy_id     TEXT    NOT NULL,
    sleeve          TEXT    NOT NULL,
    momentum_12_1   REAL,
    rs_rank         INTEGER,
    template_passed INTEGER CHECK (template_passed IN (0,1)),
    failed_conditions TEXT,                              -- JSON 배열 (조건 코드)
    sma_tranche_step  INTEGER,                           -- ETF 슬리브 진입 트랜치 단계
    gate_states     TEXT,                                -- JSON {code: PASS|BLOCK|NA}
    source          TEXT    NOT NULL DEFAULT 'LIVE'      -- 🆕 X2: BACKFILL 은 집행 근거가 아니다
                            CHECK (source IN ('LIVE','BACKFILL')),
    PRIMARY KEY (trade_date, symbol, strategy_id)
);

-- 리밸런싱 회차를 1급 엔터티로 (로그 파싱 재구성 금지)
CREATE TABLE IF NOT EXISTS rebalance_event (
    event_id        TEXT    NOT NULL PRIMARY KEY,
    trade_date      TEXT    NOT NULL,
    mode            TEXT    NOT NULL DEFAULT 'SIM' CHECK (mode IN ('SIM','LIVE')),
    kind            TEXT    NOT NULL CHECK (kind IN
                     ('MONTHLY_REGULAR','SEASONAL','BAND','REGIME','DEPOSIT')),
    decision_id     TEXT    NOT NULL,
    trigger_snapshot TEXT   NOT NULL,                    -- JSON 국면·신호 원값·밴드 여유·임계값
    weights_before  TEXT    NOT NULL,                    -- JSON [{sleeve,weight,target,band_lo,band_hi}]
    weights_after   TEXT    NOT NULL,
    config_hash     TEXT    NOT NULL,
    created_at      TEXT    NOT NULL                     -- 🔴 X5 authored 축
);
CREATE INDEX IF NOT EXISTS ix_rebal_date ON rebalance_event(trade_date);

COMMIT;
PRAGMA foreign_keys = ON;
