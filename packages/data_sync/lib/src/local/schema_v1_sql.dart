// 🔴 생성 파일 — 손으로 고치지 않는다. `python -I tool/make_local_schema.py <02 경로>` 로 다시 만든다.
//
// 로컬 원장 스키마 v1 자산(설계 13 §8 R19 E9-10 · R20 Q0·Q2 · E9c).
// ① 02 기본 — 설계 저장소 `06_시스템설계/02_데이터모델.md` sha256 `1f8ff77ec4a6c81d1972aef857b92aa2b59062d4436d1b605bb4193fad10faf2`
//    ```sql 블록 2~9(1번 PRAGMA 블록 제외 — 연결 설정은 `openLedgerDatabase` · §2-7 이후 배치 블록 제외) · 정정 0(02 v2.33 본문이 `executions.broker_order_no` NULL 허용 — R20 Q2)
// ② 배치 — `packages/domain_contracts/ddl/` LIVE 판 원문(SIM 판은 `ledgerDdlFor`):
//    batch_a_decision_mode.sql sha256 `8ffb88f7957cc9baf835935f3c253b5c297990a25e99226ce37a91d48d1e5004`
//    batch_b_plan_command.sql sha256 `f05a26c489df40de92c693b221696fb7fa7ce4c5657659e11bbc38a121009df3`
//    batch_c_x2_x5_local.sql sha256 `4d60e20b8246304359fadab187e484dfe2d2e151b088bb1e0e65bb10e05afa14`
//    batch_f_x7_advisory.sql sha256 `e6298ab4bb4f5b03dcd7a19f416ae4626ab1242d51db6b16cfd9ef68e207fac9`
//    batch_g_market_data.sql sha256 `0a7844b0398e722184b61629d80db18e20cbec4f56952e22f27e363a6210b90e`
// 🔴 배치 사본은 data_sync 시험이 `domain_contracts/ddl` 과 바이트 대조한다.

/// 02 기본 DDL(32표 · `schema_version` 포함) — 블록 2~9.
const String kBase02Sql = r'''
-- ── 02_데이터모델.md L21-25 ──
CREATE TABLE IF NOT EXISTS schema_version (
    version     INTEGER NOT NULL PRIMARY KEY,
    applied_at  TEXT    NOT NULL,          -- ISO8601
    description TEXT    NOT NULL
);

-- ── 02_데이터모델.md L40-126 ──
-- 일별 시세
CREATE TABLE IF NOT EXISTS daily_prices (
    trade_date   TEXT    NOT NULL,          -- 'YYYY-MM-DD', 해당 시장 현지 거래일
    market       TEXT    NOT NULL CHECK (market IN ('KR','US')),
    symbol       TEXT    NOT NULL,
    open         REAL    NOT NULL CHECK (open  > 0),
    high         REAL    NOT NULL CHECK (high  > 0),
    low          REAL    NOT NULL CHECK (low   > 0),
    close        REAL    NOT NULL CHECK (close > 0),   -- 수정주가
    close_unadj  REAL,                                  -- 미조정 종가 (KR 필수)
    volume       INTEGER NOT NULL CHECK (volume >= 0),
    trade_value  REAL,                                  -- 거래대금
    market_cap   REAL,
    PRIMARY KEY (trade_date, market, symbol)
);
CREATE INDEX IF NOT EXISTS ix_prices_symbol_date ON daily_prices(symbol, trade_date);

-- 🔴 일별 유니버스 스냅샷 — 소급 복원 불가. 매일 저장 필수
CREATE TABLE IF NOT EXISTS universe_snapshot (
    trade_date      TEXT    NOT NULL,
    market          TEXT    NOT NULL CHECK (market IN ('KR','US')),
    symbol          TEXT    NOT NULL,
    name            TEXT,
    board           TEXT,                    -- KOSPI / KOSDAQ / NYSE / NASDAQ
    is_admin_issue  INTEGER NOT NULL DEFAULT 0 CHECK (is_admin_issue IN (0,1)),
    is_halted       INTEGER NOT NULL DEFAULT 0 CHECK (is_halted      IN (0,1)),
    is_spac         INTEGER NOT NULL DEFAULT 0 CHECK (is_spac        IN (0,1)),
    is_preferred    INTEGER NOT NULL DEFAULT 0 CHECK (is_preferred   IN (0,1)),
    -- 🔴 v1.4 신설 — 03_알고리즘 §2-1 필터가 요구하는데 컬럼이 없었다
    is_holding      INTEGER NOT NULL DEFAULT 0 CHECK (is_holding     IN (0,1)),
    is_foreign_listed INTEGER NOT NULL DEFAULT 0 CHECK (is_foreign_listed IN (0,1)),
    sector          TEXT,                    -- 🔴 v1.4 신설. SAF-205/206 판정용
    PRIMARY KEY (trade_date, market, symbol)
);

-- 🔴 v2.0 신설 — ETF 일별 유니버스 스냅샷. **소급 복원 불가. 매일 저장 필수**
-- universe_snapshot 은 개별주용이라 ETF가 들어 있지 않았다.
-- 이 표가 없으면 동적 ETF 선택(03 §2-7-5)을 백테스트할 수 없다.
CREATE TABLE IF NOT EXISTS etf_universe_snapshot (
    trade_date       TEXT    NOT NULL,
    market           TEXT    NOT NULL CHECK (market IN ('KR','US')),
    ticker           TEXT    NOT NULL,
    name             TEXT,
    category         TEXT,                   -- 🔴 테마 쏠림 방지용. 화이트리스트가 제공
    close            REAL    CHECK (close > 0),
    adv20_krw        REAL,                   -- 🔴 거래량(주)이 아니라 거래대금(원)
    aum_krw          REAL,                   -- 순자산. 청산 위험 판정
    expense_ratio    REAL,                   -- 총보수 (03 §5-7)
    listed_date      TEXT,                   -- 상장일 → listed_months 파생
    is_leveraged     INTEGER NOT NULL DEFAULT 0 CHECK (is_leveraged IN (0,1)),
    is_inverse       INTEGER NOT NULL DEFAULT 0 CHECK (is_inverse   IN (0,1)),
    is_synthetic     INTEGER NOT NULL DEFAULT 0 CHECK (is_synthetic IN (0,1)),
    pension_eligible INTEGER,                -- 🔴 NULL = 미확인. 자동 판정 불가 — 사람이 채운다
    PRIMARY KEY (trade_date, market, ticker)
);
CREATE INDEX IF NOT EXISTS ix_etf_ticker_date ON etf_universe_snapshot(ticker, trade_date);

-- ETF 상장폐지(청산) 이벤트 — 생존편향 방어
CREATE TABLE IF NOT EXISTS etf_delisting_events (
    ticker      TEXT NOT NULL,
    market      TEXT NOT NULL,
    delist_date TEXT NOT NULL,
    reason      TEXT,                        -- LIQUIDATION / MERGER / OTHER
    PRIMARY KEY (ticker, delist_date)
);

-- 상장폐지 이벤트
CREATE TABLE IF NOT EXISTS delisting_events (
    symbol          TEXT NOT NULL,
    market          TEXT NOT NULL,
    delist_date     TEXT NOT NULL,
    last_trade_date TEXT,                    -- 정리매매 종료일
    reason          TEXT,
    reason_group    TEXT,                    -- MERGER / BANKRUPTCY / VOLUNTARY / CRITERIA
    successor_symbol TEXT,                   -- 합병 시 승계 종목
    PRIMARY KEY (symbol, delist_date)
);

-- 기업행위 (배당·분할·증자)
CREATE TABLE IF NOT EXISTS corporate_actions (
    symbol      TEXT NOT NULL,
    ex_date     TEXT NOT NULL,
    action_type TEXT NOT NULL CHECK (action_type IN
                 ('DIVIDEND','SPLIT','REVERSE_SPLIT','BONUS','RIGHTS')),
    value       REAL NOT NULL,               -- 배당금 또는 비율
    PRIMARY KEY (symbol, ex_date, action_type)
);

-- ── 02_데이터모델.md L132-177 ──
-- 🔴 DART 공시 접수 원장 — 소급 복원 불가. 매일 저장 필수
CREATE TABLE IF NOT EXISTS dart_filings (
    rcept_no    TEXT NOT NULL PRIMARY KEY,   -- 접수번호
    corp_code   TEXT NOT NULL,
    corp_name   TEXT,
    symbol      TEXT,
    report_nm   TEXT NOT NULL,
    report_type TEXT CHECK (report_type IN ('ANNUAL','SEMI','QUARTER','OTHER')),
    rcept_dt    TEXT NOT NULL,               -- 🔴 접수일. PIT 판정의 기준
    period_end  TEXT,                        -- 대상 결산기말
    is_amendment INTEGER NOT NULL DEFAULT 0  -- 정정공시 여부
);
CREATE INDEX IF NOT EXISTS ix_filings_corp_rcept ON dart_filings(corp_code, rcept_dt);

-- 재무제표 값
CREATE TABLE IF NOT EXISTS financials (
    rcept_no                TEXT NOT NULL,
    fs_div                  TEXT NOT NULL CHECK (fs_div IN ('CFS','OFS')),
    revenue                 REAL,
    cogs                    REAL,
    gross_profit            REAL,
    operating_income        REAL,
    net_income              REAL,
    net_income_controlling  REAL,            -- 지배주주 귀속
    equity                  REAL,
    equity_controlling      REAL,            -- 🔴 PBR·ROE에 사용
    total_assets            REAL,
    total_liabilities       REAL,
    current_assets          REAL,
    ocf                     REAL,            -- 영업현금흐름
    PRIMARY KEY (rcept_no, fs_div),
    FOREIGN KEY (rcept_no) REFERENCES dart_filings(rcept_no)
);

-- 팩터 패널 (계산 결과 캐시)
CREATE TABLE IF NOT EXISTS factor_panel (
    trade_date  TEXT NOT NULL,
    symbol      TEXT NOT NULL,
    pbr         REAL,
    psr         REAL,
    gp_a        REAL,
    vol_52w     REAL,
    f_score_3   INTEGER,
    source_rcept_no TEXT,                    -- 어느 공시를 썼는지 추적
    PRIMARY KEY (trade_date, symbol)
);

-- ── 02_데이터모델.md L183-212 ──
CREATE TABLE IF NOT EXISTS regime_score_daily (
    trade_date        TEXT NOT NULL PRIMARY KEY,
    status            TEXT NOT NULL CHECK (status IN ('OK','INSUFFICIENT_DATA')),
    direction_score   REAL,                  -- 0~100
    trendiness_score  REAL,                  -- 0~100
    direction_state   TEXT CHECK (direction_state IN
                       ('BULL','NEUTRAL','BEAR','UNKNOWN')),   -- 🔴 v1.4: UNKNOWN 추가
    bars_in_state     INTEGER NOT NULL DEFAULT 0,
    exposure          REAL CHECK (exposure BETWEEN 0.0 AND 1.0),
    cat_trend         REAL,                  -- 카테고리별 점수 (NULL = 제외됨)
    cat_breadth       REAL,
    cat_volatility    REAL,
    cat_credit        REAL,
    cat_macro         REAL,
    excluded_categories TEXT,                -- JSON 배열
    config_hash       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS signals (
    trade_date  TEXT NOT NULL,
    strategy_id TEXT NOT NULL,
    symbol      TEXT NOT NULL,
    action      TEXT NOT NULL CHECK (action IN ('BUY','SELL','HOLD')),
    target_weight REAL,
    rank        INTEGER,
    score       REAL,
    reason      TEXT,
    config_hash TEXT NOT NULL,
    PRIMARY KEY (trade_date, strategy_id, symbol)
);

-- ── 02_데이터모델.md L218-272 ──
-- 주문 의도 원장. 🔴 브로커 호출 전에 먼저 INSERT (NR-1)
CREATE TABLE IF NOT EXISTS order_intents (
    intent_id       TEXT NOT NULL PRIMARY KEY,        -- UUID
    idempotency_key TEXT NOT NULL UNIQUE,             -- 🔴 UNIQUE 필수
    created_at      TEXT NOT NULL,                    -- ISO8601 (UTC)
    trade_date      TEXT NOT NULL,                    -- 🔴 해당 시장 현지 거래일 (US는 ET)
    market          TEXT NOT NULL CHECK (market IN ('KR','US')),
    account         TEXT NOT NULL,                    -- 🆕 v2.38 계좌 **별칭**(cash_flow.account_alias 와 같은 축 · R33 D18)
    strategy_id     TEXT NOT NULL,                    -- 🆕 v2.38 P0S = 'P0S_A'·'P0S_B'·'P0S_C'·'P0S_POT' (입금 = 'P0S')
    decision_id     TEXT NOT NULL,                    -- 논리적 의사결정 단위 · 🆕 v2.38 주문 의도 = '{논리 id}@{집행일}'(04 §3-2)
    symbol          TEXT NOT NULL,
    side            TEXT NOT NULL CHECK (side IN ('BUY','SELL')),
    order_type      TEXT NOT NULL,                    -- 화이트리스트 검증 대상 · 🆕 v2.38 값 = 'LIMIT'·'MARKET'(KIS ORD_DVSN 대응은 broker_gateway · R33 D19)
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    limit_price     REAL,
    status          TEXT NOT NULL CHECK (status IN
                     ('RESERVED','SUBMITTING','SUBMITTED','FILLED','PARTIAL',
                      'CANCELLED','REJECTED','UNKNOWN','SKIPPED',
                      'EXPIRED')),                    -- 🆕 v2.38 EXPIRED = 일 마감 실효(취소 아님 · 04 §3-1 ③ · R32 O3 · R33 D5)
    sizing_binding  TEXT CHECK (sizing_binding IN ('RISK','NOTIONAL')),
    config_hash     TEXT NOT NULL,
    dry_run         INTEGER NOT NULL DEFAULT 1,       -- 🆕 v2.33 = `ExecPolicy`(1 ⇔ DRY_RUN · 0 ⇔ EXECUTE) ·
                                                      --    `mode`(배치 A — 어느 계좌)와 독립 · 강등은 이 값만 바꾼다
    error_message   TEXT,
    updated_at      TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_intents_date_status ON order_intents(trade_date, status);
CREATE INDEX IF NOT EXISTS ix_intents_unknown ON order_intents(status) WHERE status='UNKNOWN';

-- 브로커 주문 (의도 1개에 브로커 주문 여러 개 가능: 정정·재주문)
CREATE TABLE IF NOT EXISTS broker_orders (
    broker_order_no TEXT NOT NULL PRIMARY KEY,        -- 🆕 v2.38 = '{주문일}:{ODNO}'(주문일 = KR 거래일 ISO 날짜 · ODNO = KIS 주문번호 원문)
                                                      --    KIS 주문번호는 날마다 새로 매겨질 수 있어 단독 PK 가 날을 넘겨 겹친다(R31 · R33 D3)
    intent_id       TEXT NOT NULL,
    submitted_at    TEXT NOT NULL,
    status          TEXT NOT NULL,
    filled_qty      INTEGER NOT NULL DEFAULT 0,
    remaining_qty   INTEGER NOT NULL DEFAULT 0,
    avg_fill_price  REAL,
    raw_response    TEXT,                             -- JSON (시크릿 제거 후)
    FOREIGN KEY (intent_id) REFERENCES order_intents(intent_id)
);

-- 체결
CREATE TABLE IF NOT EXISTS executions (
    execution_id    TEXT NOT NULL PRIMARY KEY,        -- 🆕 v2.38 브로커 체결 = '{broker_order_no}#{누적 체결수량}'(R31 (a) · §3-2 v2.38)
    broker_order_no TEXT,                             -- 🆕 v2.33 NULL 허용 — 수기 체결(X7 `MANUAL`)은 브로커 주문이 없다.
                                                      --    배치 F 의 `fill_origin` CHECK 가 «MANUAL ⇔ NULL» 을 강제한다(R20 Q2)
    executed_at     TEXT NOT NULL,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    price           REAL NOT NULL CHECK (price > 0),
    commission      REAL NOT NULL DEFAULT 0,
    tax             REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (broker_order_no) REFERENCES broker_orders(broker_order_no)
);

-- ── 02_데이터모델.md L295-313 ──
CREATE TABLE IF NOT EXISTS positions (
    market          TEXT NOT NULL,
    symbol          TEXT NOT NULL,
    strategy_id     TEXT NOT NULL,
    quantity        INTEGER NOT NULL,
    avg_price       REAL NOT NULL,
    entry_date      TEXT NOT NULL,
    atr20_at_entry  REAL,                             -- 절대손절(2×ATR) + 트레일링(k×ATR) 기준
    atr20_current   REAL,                             -- 🔴 v0.3 신설. 매일 갱신. 사후 비교용
    high_water_mark REAL,                             -- 트레일링 기준 고점
    trail_stop      REAL,                             -- 🔴 v0.3 신설. 단조 비감소로 유지
    max_gain_pct    REAL NOT NULL DEFAULT 0,          -- 🔴 HWM에서 파생 (아래 정의)
    custom_stop     REAL,
    target_price    REAL,
    sector          TEXT,                             -- 🔴 v1.4 신설. SAF-205/206
    sma50           REAL,                             -- 🔴 v1.4 신설. TIER 1.5 판정 입력 캐시
    updated_at      TEXT NOT NULL,
    PRIMARY KEY (market, symbol, strategy_id)
);

-- ── 02_데이터모델.md L334-380 ──
-- (positions 계속)

-- 🔴 매일 저장. 소급 복원 불가
CREATE TABLE IF NOT EXISTS equity_snapshot (
    trade_date      TEXT NOT NULL PRIMARY KEY,
    total_equity    REAL NOT NULL,                    -- 원화 환산 총평가액
    cash_krw        REAL NOT NULL,
    cash_usd        REAL NOT NULL DEFAULT 0,
    fx_rate         REAL,                             -- USD/KRW
    positions_value REAL NOT NULL,
    high_water_mark REAL NOT NULL,
    drawdown        REAL NOT NULL,
    breaker_level   TEXT NOT NULL DEFAULT 'NORMAL'
);

-- 🔴 TWR 계산의 전제. 모든 입출금 기록
CREATE TABLE IF NOT EXISTS cash_flow (
    flow_id     TEXT NOT NULL PRIMARY KEY,
    trade_date  TEXT NOT NULL,
    amount      REAL NOT NULL,                        -- 입금 +, 출금 −
    currency    TEXT NOT NULL DEFAULT 'KRW',
    kind        TEXT NOT NULL CHECK (kind IN ('DEPOSIT','WITHDRAWAL')),
                                                      -- 🆕 v2.33 배치 F 가 5값으로 재작성한다(§2-11 ㊲ ·
                                                      --    DISTRIBUTION·TAX_WITHHELD·CASH_IN_LIEU · source_event_id)
    note        TEXT
);

-- 완료된 거래 (진입~청산 1건)
CREATE TABLE IF NOT EXISTS trades (
    trade_id        TEXT NOT NULL PRIMARY KEY,
    strategy_id     TEXT NOT NULL,
    market          TEXT NOT NULL,
    symbol          TEXT NOT NULL,
    entry_date      TEXT NOT NULL,
    exit_date       TEXT NOT NULL,
    quantity        INTEGER NOT NULL,
    entry_price     REAL NOT NULL,
    exit_price      REAL NOT NULL,
    gross_pnl       REAL NOT NULL,
    total_cost      REAL NOT NULL,                    -- 수수료+세금+슬리피지
    net_pnl         REAL NOT NULL,
    pnl_pct         REAL NOT NULL,
    exit_tier       TEXT,                             -- '0','1A','1B','1.5','2','3'
    exit_kind       TEXT CHECK (exit_kind IN
                     ('STOP','TREND_BREAK','TARGET','CORPORATE','RISK','REBALANCE')),
    holding_days    INTEGER NOT NULL
);

-- ── 02_데이터모델.md L386-714 ──
CREATE TABLE IF NOT EXISTS strategy_state_log (
    log_id               TEXT NOT NULL PRIMARY KEY,
    strategy_id          TEXT NOT NULL,
    changed_at           TEXT NOT NULL,
    from_state           TEXT,
    to_state             TEXT NOT NULL,
    trigger_value        REAL,                        -- 🔴 나란히 저장
    threshold_registered REAL,                        -- 🔴 사후 기준 변경 감사용
    reason               TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS strategy_state_current (
    strategy_id TEXT NOT NULL PRIMARY KEY,
    state       TEXT NOT NULL,
    since       TEXT NOT NULL,
    capital_cap REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS decision_journal (
    journal_id   TEXT NOT NULL PRIMARY KEY,
    trade_date   TEXT NOT NULL,
    strategy_id  TEXT NOT NULL,
    signal_value TEXT NOT NULL,                       -- JSON
    action_taken TEXT NOT NULL,                       -- JSON
    is_deviation INTEGER NOT NULL DEFAULT 0,
    -- 🔴 v2.15 (4차 파일럿 S-1) — SAF-408 '사전 필드' 3개. 04 §1 v2.11 의 판정 SQL 이 이 세 컬럼을
    --    참조하는데 v2.14 까지 DDL 에 없어 SAF-408 이 **구현 불가능**했다 (03_운영 카드 ① 저널 항목과 대응).
    rationale_before TEXT,                            -- 실행 전 근거
    expected_outcome TEXT,                            -- 기대 결과
    rule_cited       TEXT,                            -- 인용 규칙 (예: '03 §4-1 TIER 1B')
    kind             TEXT,                            -- 🔴 v2.15 — 🆕 v2.45 정정(앱 계약 v1.35 `DecisionJournalKinds` 8 · 앱 01 §44 K294) — 'KILL_SWITCH_CHECKLIST' | 'KILL_SWITCH_RESUME' | 'STOPPED_DECISION' | 'RECON_CLEAR' | 'RULE_CHANGE_REQUEST' | 'INTERVENTION_JOURNAL' | 'DISCRETION' | 'PLEDGE_EDIT' | NULL(옛 행 · 새 쓰기 0)
    note         TEXT,
    created_at   TEXT NOT NULL
);
-- 🔴 SAF-408 판정 (04 §1): is_deviation=1 이고 세 사전 필드 중 하나라도 NULL 인 행이 있으면 신규 진입 차단.
--    검증: 08_파일럿/파일럿4/impl/tests/test_safety_v211_v214.py::test_missing_deviation_journal_blocks / test_journal_filled_auto_clears_block

-- 🔴 v2.15 (4차 파일럿 S-2) — 킬스위치 활성 시각. 04 §3-6 v2.11 재개 게이트의 stopped_at 저장소가 없었다.
--    "파일을 지워도 대기 미경과면 차단" 은 이 행이 있어야 성립한다 (파일만 손으로 만든 경우 mtime 을 기록).
CREATE TABLE IF NOT EXISTS kill_switch_state (
    id            INTEGER PRIMARY KEY CHECK (id = 1),
    activated_at  TEXT,                               -- /stop·파일 감지 시각 (UTC ISO8601)
    activated_by  TEXT,                               -- 'telegram' | 'file' | ...
    cleared_at    TEXT,                               -- try_resume 통과 시각. NULL 이면 활성
    decision_id   TEXT                                -- 🔴 재개 저널 (필수)
);
-- 🆕 v2.40(04 §3-6 · 설계 13 §8 R55 D1 · D12 · D17) — 48h 기준 = 체크리스트 확인 시각 · 이력 · STOPPED 재개 기록
ALTER TABLE kill_switch_state ADD COLUMN checklist_confirmed_at TEXT;   -- 발동 뒤 기록 확인 시각(🔴 ≥ activated_at · 48h 기준)
CREATE TABLE IF NOT EXISTS kill_switch_event (                          -- append-only(연습 · 반복 횟수를 센다)
    event_id    TEXT NOT NULL PRIMARY KEY,
    occurred_at TEXT NOT NULL,                          -- 신뢰 시각(UTC ISO8601)
    kind        TEXT NOT NULL CHECK (kind IN ('ACTIVATED','CHECKLIST_CONFIRMED','CANCEL_REPORT','RESUMED')),
    channel     TEXT,                                   -- 'app' | 'viewer' | 'web' | 'messenger' | 'file'
    decision_id TEXT,                                   -- CHECKLIST_CONFIRMED · RESUMED = 필수
    summary     TEXT NOT NULL                           -- JSON(취소 건별 결과 · 응답 요약 — 🔴 금액 0)
);
CREATE TABLE IF NOT EXISTS breaker_release (                            -- 🔴 STOPPED → HALTED 의 유일한 입력(결정 B · 04 §2 v2.40)
    release_id  TEXT NOT NULL PRIMARY KEY,
    trade_date  TEXT NOT NULL,                          -- 이 날부터 HALTED(재생이 이 날 하강)
    decision_id TEXT NOT NULL,                          -- 🔴 결정 B 저널
    created_at  TEXT NOT NULL
);
-- 검증: test_kill_file_deleted_but_wait_not_elapsed_still_blocked · test_resume_before_min_wait_blocked

-- 🔴 v2.15 (4차 파일럿 S-9) — 램프 단계 (03_운영 §9-2 L1 5% ~ L5 100%). 04 §4-3 v2.14 DST 강제의 set_ramp_level 대상.
CREATE TABLE IF NOT EXISTS ramp_state (
    id             INTEGER PRIMARY KEY CHECK (id = 1),
    level          INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    pre_dst_level  INTEGER,                           -- DST 주간 진입 전 레벨. 주간 종료 시 여기로 자동 복귀(재승급 절차 없음)
    updated_at     TEXT NOT NULL
);
-- 검증: test_dst_week_forces_ramp_down · test_dst_week_auto_restores
-- 🔴 신규 DB 의 초기 레벨(행 없음)은 **L1** 이다(fail-closed). 참조 구현 get_ramp_level() 기본값 5 → 1 로 정정(4차 SF-05 후속)

CREATE TABLE IF NOT EXISTS config_versions (
    config_hash TEXT NOT NULL PRIMARY KEY,
    created_at  TEXT NOT NULL,
    content     TEXT NOT NULL,                        -- YAML 원문
    approved    INTEGER NOT NULL DEFAULT 0            -- 🔴 미승인 설정으로 주문 금지
);

CREATE TABLE IF NOT EXISTS reconciliation_log (
    recon_id    TEXT NOT NULL PRIMARY KEY,
    run_at      TEXT NOT NULL,
    matched     INTEGER NOT NULL,
    discrepancies TEXT,                               -- JSON
    action_taken TEXT
);

-- 🔴 v1.4 신설 — 주문 차단 플래그 (SAF-407)
--    v1.3까지 04 §3-5가 "주문 차단 플래그 설정 / 사람이 수동 해제"를 요구하는데
--    이를 저장할 곳이 스키마에 없었다. reconciliation_log는 추가만 되므로
--    "사람이 해제했다"를 표현할 수 없다.
CREATE TABLE IF NOT EXISTS trading_block (
    -- 🔴 v2.11 flag_id 열거형: 'RECON_MISMATCH' | 'JOURNAL_MISSING' | 'TIER_B_UNJUDGED'
    -- 🔴 v2.15 추가: 'DST_WEEK' (04 §4-3 v2.14 가 쓰는데 열거형에 없었다 — S-3).
    --    ⚠️ DST_WEEK 는 **주문을 차단하지 않는 상태 표식**이다 (04 §4-3 v2.15). 판정 SQL 로 주문을 막는 것은
    --       RECON_MISMATCH(전 주문) · JOURNAL_MISSING · TIER_B_UNJUDGED(신규 매수) 셋뿐.
    -- 🆕 v2.33 추가: 'RESUME_INCOMPLETE' · 'LEDGER_FIX' · 'LEDGER_INTEGRITY' + X7 5종 — 열거 정본 = 앱 계약 `FlagIds`.
    --    🔴 CHECK 가 없으므로 테이블 재생성 대상이 아니다(열거 주석 + 04 §3-1 판정 SQL 이 정본).
    flag_id     TEXT NOT NULL PRIMARY KEY,
    set_at      TEXT NOT NULL,
    reason      TEXT NOT NULL,
    origin_code TEXT,                        -- 🔴 v2.11 RECON_MISMATCH 전용:
                                             --    FILL_LAG|MANUAL_ORDER|DB_ERROR|BROKER_ERROR
                                             -- 🆕 v2.33 += EXTERNAL_CASHFLOW · CORPORATE_ACTION(X5 의 옛 CORP_ACTION 과 통합 · R19 E9-4)
                                             --    + 파생 7 + X7 6 — 열거 정본 = 앱 계약 `OriginCodes.writable`(19)
    cleared_at  TEXT,                        -- NULL이면 현재 차단 중
    cleared_by  TEXT,
    decision_id TEXT                         -- 🔴 v2.11 해제 시 저널 연결 필수
);
-- 판정: SELECT 1 FROM trading_block WHERE flag_id=? AND cleared_at IS NULL
-- 해제 경로 (v2.11 — 셋을 **분리**했습니다)
--   RECON_MISMATCH   : /clear_recon  (원인 코드 + decision_id 필수. /resume 으로 안 풀림)
--   JOURNAL_MISSING  : 🔴 **자동** — 저널 사전 필드가 채워지면 해제. 사람 경로 없음
--   TIER_B_UNJUDGED  : 🔴 **자동** — 계층 B 월간 판정이 기록되면 해제

-- 🔴 v2.11 신설 — 재량 예산 사용 원장 (SAF-409·FR-709)
--    연 4회 상한은 **세는 장치가 있어야 상한**이다. v2.10까지는 세는 주체·저장 위치·
--    5회째 거부 수단이 전부 없어 사람의 자기 신고에 의존했다 (리뷰[03]).
CREATE TABLE IF NOT EXISTS discretion_adjustment (
    adjustment_id TEXT NOT NULL PRIMARY KEY,
    applied_at    TEXT NOT NULL,
    delta_pct     REAL NOT NULL CHECK (delta_pct >= -0.10 AND delta_pct <= 0.10),
    decision_id   TEXT NOT NULL,             -- 🔴 저널 연결 필수
    reason        TEXT NOT NULL
);
-- 🆕 v2.40(설계 13 §8 R55 D6 · D7 · D20 · 03_운영 §6-4 · §6-5 · §6-8) — 서약 · 규칙 변경 · 개입. 🔴 전부 append-only(상태 = 뒤 행)
CREATE TABLE IF NOT EXISTS pledge (                     -- 본인 서약문 3문장(온보딩 · 12월 창에서만 새 판)
    pledge_id   TEXT NOT NULL PRIMARY KEY,
    version     INTEGER NOT NULL UNIQUE,                -- 1부터 · 편집 = 새 판
    sentence_1  TEXT NOT NULL,
    sentence_2  TEXT NOT NULL,
    sentence_3  TEXT NOT NULL,
    written_at  TEXT NOT NULL,                          -- 신뢰 시각
    decision_id TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS pledge_replay (              -- DD 임계 «최초 도달» 재생(임계 · 에피소드마다 1회)
    replay_id         TEXT NOT NULL PRIMARY KEY,
    threshold_dd      REAL NOT NULL,                    -- operations.pledge.replay_dd 의 값
    episode_peak_date TEXT NOT NULL,                    -- 이 하락의 고점 날(에피소드 키)
    shown_at          TEXT NOT NULL,
    UNIQUE (threshold_dd, episode_peak_date)
);
CREATE TABLE IF NOT EXISTS rule_change_request (        -- 요청은 언제든(큐) · 🔴 냉각 30일 시작점
    request_id         TEXT NOT NULL PRIMARY KEY,
    requested_at       TEXT NOT NULL,                   -- 신뢰 시각
    change_type        TEXT NOT NULL CHECK (change_type IN ('INFRA','STRATEGY_RULE','BUGFIX')),
    config_hash_before TEXT NOT NULL,
    config_hash_after  TEXT NOT NULL,
    reason             TEXT NOT NULL,
    rollback_method    TEXT NOT NULL,                   -- 롤백 방법(§6-8 · 🔴 칸 이름이 `rollback` 이면 스키마 적재기가 제어문으로 읽는다)
    decision_id        TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS rule_change_decision (       -- 취소 또는 승인 = CHANGELOG 행(03_운영 §6-8 **10칸**)
    request_id     TEXT NOT NULL PRIMARY KEY REFERENCES rule_change_request(request_id),
    decided_at     TEXT NOT NULL,                       -- 승인일(신뢰 시각)
    outcome        TEXT NOT NULL CHECK (outcome IN ('CANCELLED','APPROVED')),
    golden_changed INTEGER CHECK (golden_changed IN (0,1)),  -- 승인 = 필수(§6-3)
    approver       TEXT,                                -- 승인 = 필수(1인이면 본인)
    approval_dd    REAL,                                -- 🔴 승인 시점 DD(드로다운 락 감사) — 승인 = 필수
    third_party_notified INTEGER CHECK (third_party_notified IN (0,1)),   -- §6-5 ⑤(전송은 앱 밖 · 체크만)
    decision_id    TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS intervention_step (          -- 수동 개입 5단계(규칙 대비 표시 → 카드 → 저널 → 냉각 → 실행)
    session_id  TEXT NOT NULL,
    stage       INTEGER NOT NULL CHECK (stage BETWEEN 1 AND 5),
    occurred_at TEXT NOT NULL,                          -- 신뢰 시각 · 4단계 냉각 = operations.intervention.cooling_hours
    outcome     TEXT NOT NULL CHECK (outcome IN ('PASSED','ABANDONED','DO_NOTHING')),
    decision_id TEXT,                                   -- 3단계 · 5단계 = 필수
    PRIMARY KEY (session_id, stage)
);
-- 🆕 v2.41(설계 13 §8 R68 · 06 M5-15 · 04 §5-3 등급 · 앱 04 §5-4 P0 ack 사다리) — 운영 기기 알림 저장.
--    🔴 전부 append-only(상태 = 뒤 행) · 🔴 X5-1 해시 모집단 밖(원장 사실이 아니다 — 넣으면 hash_format_version 을 올린다)
CREATE TABLE IF NOT EXISTS alert_event (                -- 알림 1건 · 🔴 같은 사건(dedupe_key) = 1행(다시 와도 새 행 0)
    alert_id   TEXT NOT NULL PRIMARY KEY,
    raised_at  TEXT NOT NULL,                           -- 기기 시계(발생 기록 · 사다리 기준 — 마찰 시간이 아니다)
    code       TEXT NOT NULL,                           -- 엔진 알림 코드(앱 계약 AlertCodes + 등재 대기 제안 코드)
    level      TEXT NOT NULL CHECK (level IN ('P0','P1','P2')),   -- 🔴 엔진이 정한 등급(04 §5-3) · 화면 재분류 금지
    source     TEXT NOT NULL,                           -- 낸 곳(잡 체크 이름 등)
    dedupe_key TEXT NOT NULL UNIQUE                     -- 코드 · 낸 곳 · 한국 날(«배치당 · 체크당 · 일 1건» — 04 §5-3)
);
CREATE TABLE IF NOT EXISTS alert_ack (                  -- P0 수신 확인 — 🔴 효력 없음(사다리 정지만 · 앱 01 §4-2 `ALERT_ACK`)
    alert_id   TEXT NOT NULL PRIMARY KEY REFERENCES alert_event(alert_id),
    acked_at   TEXT NOT NULL,
    command_id TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS alert_escalation (           -- P0 ack 승급 사다리(1 = 15분 백업 채널 · 2 = 60분 반복 알람 + 워치독) · 🔴 건너뛰기 0
    alert_id     TEXT NOT NULL REFERENCES alert_event(alert_id),
    step         INTEGER NOT NULL CHECK (step IN (1,2)),
    escalated_at TEXT NOT NULL,
    PRIMARY KEY (alert_id, step)
);
-- 🆕 v2.42(설계 13 §8 R70 D4 · R73 K8 · 앱 E14) — 잡 실행 기록(엔진 로컬 운영 기록 — 배치 C 가 아니라 이 §2-6 기본 블록 · 앱 로컬 스키마 생성기가 읽는다). 갭 · 놓친 회차 · «마지막 성공 거래일»의 원천(04 §3-1 v2.42 ④).
--    🔴 append-only · 회차가 끝날 때 1행(끝나지 않은 회차 = 행 없음 = 성공 아님) · 🔴 X5-1 해시 모집단 밖(원장 사실이 아니다)
CREATE TABLE IF NOT EXISTS job_run (
    rid          TEXT    NOT NULL PRIMARY KEY,           -- 회차 id(시작 · 끝 핑과 같은 값)
    check_name   TEXT    NOT NULL,                       -- 잡 체크 이름(앱 잡 표)
    session_day  TEXT    NOT NULL,                       -- 그 잡의 세션일 YYYY-MM-DD
    started_at   TEXT    NOT NULL,
    finished_at  TEXT    NOT NULL,
    status       TEXT    NOT NULL CHECK (status IN ('SUCCESS','LATE','FAILED','HOLIDAY'))
);
CREATE INDEX IF NOT EXISTS ix_job_run_check ON job_run(check_name, session_day);
-- 🆕 v2.43(설계 13 §8 R78 · 발주자 결정 2026-11-13 · 앱 E14e) — 재개 리포트 항목(회차가 판정한 그대로 · 읽기 = 앱 01 `ResumeReport.items`).
--    🔴 append-only · 회차 · 항목마다 1행(같은 회차 다시 = 무시) · 🔴 X5-1 해시 모집단 밖 · 🔴 손익 칸 없음(앱 01 §2-7)
CREATE TABLE IF NOT EXISTS resume_item (
    resume_run_id    TEXT    NOT NULL,                   -- resume_run 의 회차
    work_id          TEXT    NOT NULL,                   -- planned_work 의 행
    seq              INTEGER NOT NULL,                   -- 집행 우선순위 차례(0부터 · 04 §3-1 v2.42 ②)
    one_line         TEXT    NOT NULL,                   -- 엔진 한 줄
    planned_line     TEXT    NOT NULL,                   -- 계획 시점 한 줄
    reevaluated_line TEXT    NOT NULL,                   -- 재판정 한 줄(사유별 엔진 문장)
    verdict_code     TEXT    NOT NULL,                   -- §3-3 재판정 결과 5종
    verdict_label    TEXT    NOT NULL,
    reason_code      TEXT    NOT NULL,                   -- 엔진 사유 코드(관찰 · 안전 정지 · 대사 불일치 … — 계약 등재 = 앱 계약 창)
    PRIMARY KEY (resume_run_id, work_id)
);
-- 🆕 v2.44(설계 13 §8 R80 D1 · 발주자 결정 2026-11-13 · 앱 E15b) — 실행 모드 정본(`RunMode` · `ExecPolicy` · 04 §3-1 v2.44 ①).
--    파일마다 있고, 기동이 «어느 파일 · 어느 조합»을 이 표로 정한다: live 파일에 RUN_MODE 행이 있으면 LIVE + 그 파일 최신 exec_policy ·
--    없으면 sim 파일 최신 행 · 둘 다 없으면 «온보딩 미완»(자동 매매가 아니다 — `onboarding_choice` 와 같은 규칙).
--    🔴 append-only · 🔴 거부된 조합(04 §3-1 v2.44 ②)은 쓰지 않는다 = 직전 유효 조합 유지 · 🔴 한 트랜잭션이 두 파일에 걸치지 않는다 —
--       simToAuto 커밋 = 2단(live 파일 RUN_MODE 행 먼저 → sim 파일 CLOSE 행 · 기동 때 «live 행 있음 ∧ sim CLOSE 없음» = CLOSE 마저)
--    🔴 X5-1 해시 모집단 밖(운영 상태) · `OperatingMode` 정본은 따로(§2-10 `operating_mode_transition`)
--    🔴 `mode` 줄 = §2-1~§2-6 기본 블록의 첫 @sim 태그 — 앱 로컬 스키마 생성기는 기본 블록에도 `ledgerDdlFor` 를 건다(앱 E15b · §2-7)
CREATE TABLE IF NOT EXISTS mode_transition (
    transition_id       TEXT    NOT NULL PRIMARY KEY,
    axis                TEXT    NOT NULL CHECK (axis IN ('RUN_MODE','EXEC_POLICY','CLOSE')),
                                                     -- RUN_MODE = 계좌·서버(온보딩 커밋 · simToAuto · 모의 폐기 후 새 개시)
                                                     -- EXEC_POLICY = 승격(관찰 뒤 생체 1회) · 강등(골든벡터 재검증 실패) · CLOSE = 이 파일을 닫음
    mode                TEXT    NOT NULL CHECK (mode = 'LIVE'),   -- @sim ledger
    exec_policy         TEXT    NOT NULL CHECK (exec_policy IN ('DRY_RUN','EXECUTE')),   -- 전이 뒤 조합 · 🔴 SIM 계열 = EXECUTE 만(가드)
    from_mode           TEXT    CHECK (from_mode IN ('LIVE','SIM_INTERNAL','SIM_BROKER')),   -- 전이 전(그 파일 첫 행 = NULL)
    from_exec_policy    TEXT    CHECK (from_exec_policy IN ('DRY_RUN','EXECUTE')),
    decision_id         TEXT    NOT NULL,                -- 그 전이의 결정(사람 = MANUAL · 강등 = 엔진 SAFETY)
    handover_session_id TEXT,                            -- simToAuto · 승격 = 그 세션 토큰(§2-11 `handover_session`)
    committed_at        TEXT    NOT NULL                 -- ISO8601 (UTC)
);
CREATE INDEX IF NOT EXISTS ix_mode_transition_at ON mode_transition(committed_at);
-- 🆕 v2.45(설계 13 §8 R114 Z2 · 발주자 위임 2026-11-14 · 앱 E16s) — 기기 이전(X1) 저널 3표(04 §3-1 v2.45 ①~③).
--    migration_run = 이전 한 번(옛 폰 · 새 폰이 각자 자기 파일에 자기 행) · migration_step = 단계 저널(단계마다 ENTERED → DONE | FAILED ·
--    크래시 뒤 «ENTERED 있고 DONE · FAILED 없음» 단계부터 멱등 재개 — 앱 06 X1-2) · maintenance_window = 감시 유지보수 창 사건(04 §5-2 v2.45).
--    🔴 셋 다 append-only(끝 = 마지막 단계 행 · 창 닫힘 = CLOSED 행 · 행 수정 0) · 🔴 X5-1 해시 모집단 밖(운영 상태 — 이전 · 정정의
--       원장 사실은 모집단 안 `decision_log` · `executions` 에 남는다) · 🔴 X1 = live 파일만(04 §3-1 v2.45 ⑦ — sim 파일은 행 0)
--    🔴 시크릿 0 · 금액 0 — `detail_json` · `checks_json` = 단계 코드 · 날 · 해시 앞 8 · 체크 이름만(핑 URL · 키 · 계좌 번호 0)
CREATE TABLE IF NOT EXISTS migration_run (
    run_id          TEXT    NOT NULL PRIMARY KEY,        -- 'mig-{시작 한국 날}-{순번}'
    kind            TEXT    NOT NULL CHECK (kind IN ('PLAN','EMERGENCY')),         -- 계획 교체(X1-2) · 비상(X1-3)
    role            TEXT    NOT NULL CHECK (role IN ('OLD_DEVICE','NEW_DEVICE')),  -- 이 파일 기기의 역할
    device_id       TEXT    NOT NULL,                    -- 이 기기
    operator_epoch  INTEGER NOT NULL CHECK (operator_epoch >= 0),   -- 시작 때 epoch(새 폰 = +1 뒤 값)
    decision_id     TEXT,                                -- 계획 = `D-03` 확인 결정 · 비상 = 선언 결정
    started_at      TEXT    NOT NULL                     -- ISO8601 (UTC)
);
CREATE TABLE IF NOT EXISTS migration_step (
    run_id          TEXT    NOT NULL REFERENCES migration_run(run_id),
    step            TEXT    NOT NULL,                    -- 단계 코드 = core 이전 상태기계 글자(앱 E16b — 목록은 코드가 정본)
    state           TEXT    NOT NULL CHECK (state IN ('ENTERED','DONE','FAILED')),
    detail_json     TEXT,                                -- 단계 근거(금액 · 시크릿 0)
    at              TEXT    NOT NULL,                    -- ISO8601 (UTC)
    PRIMARY KEY (run_id, step, state)                    -- 🔴 같은 단계 같은 상태 = 1행(재개 멱등)
);
CREATE INDEX IF NOT EXISTS ix_migration_step_at ON migration_step(run_id, at);
CREATE TABLE IF NOT EXISTS maintenance_window (
    event_id        TEXT    NOT NULL PRIMARY KEY,        -- '{window_id}:{event}' · RESUME_FAILED = '{window_id}:RESUME_FAILED:{부팅 id}'
    window_id       TEXT    NOT NULL,                    -- 'mw-{열린 한국 날}-{순번}'
    run_id          TEXT    REFERENCES migration_run(run_id),   -- 이전이 연 창(그 밖 = NULL)
    event           TEXT    NOT NULL CHECK (event IN ('OPENED','OVERDUE','CLOSED','RESUME_FAILED')),
                                                     -- OVERDUE = 창당 1건(P1 `MAINTENANCE_WINDOW_OVERDUE`) · RESUME_FAILED = 부팅당 1건(P0)
    checks_json     TEXT,                                -- OPENED = 멈춘 체크 이름 목록 · 🔴 `engine_alive` 는 들어가지 않는다
    at              TEXT    NOT NULL                     -- ISO8601 (UTC)
);
CREATE INDEX IF NOT EXISTS ix_maintenance_window_id ON maintenance_window(window_id, at);
-- 🆕 v2.45(설계 13 §8 R114 Z3 · R116 · 04 §3-1 v2.45 ④ · 앱 E16s) — 정정 상세(엔진 로컬 · `ledger_repair` 1:1).
--    `ledger_repair` 는 배치 C(앱 계약 `domain_contracts/ddl` 정본)라 칸을 더하지 않고 이 표에 둔다(계약 창과 v1 동결 시점을 묶지 않는다).
--    🔴 append-only · `ledger_repair` 행과 같은 트랜잭션에서 1행 · 🔴 X5-1 해시 모집단 밖(정정 사실은 모집단 안 표에 남는다)
CREATE TABLE IF NOT EXISTS ledger_repair_detail (
    repair_id       TEXT    NOT NULL PRIMARY KEY REFERENCES ledger_repair(repair_id),   -- 1:1
    recomputed_from TEXT,                                -- 다시 센 첫 날(새 기준점 = 첫 어긋난 날 · DERIVED_RESYNC = 재생성 시작 날)
    chain_hash      TEXT,                                -- 적용 직후 체인(그 날 `ledger_daily_hash.chain_hash`)
    target_json     TEXT,                                -- 대상(행 id · 종목 · 전후 수량 — 금액 0)
    evidence_json   TEXT                                 -- 🔴 로컬 전용(아카이브 · push 제외) — 옛 스탬프 · 브로커 근거 원문(해시 = ledger_repair.evidence_hash)
);
-- 롤링 12개월 횟수: SELECT COUNT(*) FROM discretion_adjustment
--                    WHERE applied_at >= date('now','-12 months')

-- 🔴 v2.11 신설 — 계층 B 월간 판정 기록 (SAF-410·FR-708)
--    "배치가 죽어 있는 것"과 "판정 결과가 이상 없음인 것"을 구별하기 위해,
--    판정을 돌렸다는 사실 자체를 행으로 남긴다.
CREATE TABLE IF NOT EXISTS tier_b_judgement (
    judged_month  TEXT NOT NULL,             -- 'YYYY-MM'
    strategy_id   TEXT NOT NULL,
    judged_at     TEXT NOT NULL,
    b1_breached   INTEGER NOT NULL CHECK (b1_breached IN (0,1)),
    b2_breached   INTEGER NOT NULL CHECK (b2_breached IN (0,1)),
    b3_breached   INTEGER NOT NULL CHECK (b3_breached IN (0,1)),
    transitioned  INTEGER NOT NULL CHECK (transitioned IN (0,1)),
    PRIMARY KEY (judged_month, strategy_id)
);

-- 🔴 v1.4 신설 — 환율 (SAF-402·SAF-307·미국 사이징에 필요)
CREATE TABLE IF NOT EXISTS fx_rates (
    trade_date  TEXT NOT NULL,
    pair        TEXT NOT NULL,               -- 'USDKRW'
    close       REAL NOT NULL CHECK (close > 0),
    PRIMARY KEY (trade_date, pair)
);

CREATE TABLE IF NOT EXISTS incidents (
    incident_id TEXT NOT NULL PRIMARY KEY,
    occurred_at TEXT NOT NULL,
    severity    TEXT NOT NULL CHECK (severity IN ('SEV1','SEV2','SEV3')),
    category    TEXT NOT NULL,
    description TEXT NOT NULL,
    resolved_at TEXT,
    postmortem  TEXT
);
ALTER TABLE incidents ADD COLUMN due_at TEXT;   -- 🆕 v2.40 postmortem 기한(SEV1 = 3일 · SEV2 = 7일 · 03_운영 카드 ⑤ 7)

-- 🔴 백테스트 시행 레지스트리 (DSR의 N 입력)
CREATE TABLE IF NOT EXISTS backtest_trials (
    trial_id    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    run_at      TEXT NOT NULL,
    strategy_id TEXT NOT NULL,
    params      TEXT NOT NULL,                        -- JSON
    metrics     TEXT NOT NULL,                        -- JSON
    git_sha     TEXT,
    data_hash   TEXT
);
''';

/// 적용 순서대로의 로컬 배치(새 설치 = A → B → C → F · `batch_e` 보관 · `batch_d` = Supabase).
const List<(String, String)> kLocalBatchSql = <(String, String)>[
  (
    'batch_a_decision_mode.sql',
    r'''
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
--    ✅ **1**(02 기본 + 배치 A·B·C·F 한 판 · SPEC 개정 번호와 다른 축 — 01 §6-0 · 설계 13 §8 R19 E9-10).
-- 🔴 아래는 `ledger.sqlite`(LIVE) 판이다. `-- @sim <종류>` 가 붙은 줄은 `ledger_sim.sqlite` 판에서
--    `LedgerModeCheck` 규칙대로 바뀐다(ddl/README «두 파일» · 01 §6-0 · 설계 13 §8 R20 Q1).
-- 🔴 **실전 첫 거래 전에 적용한다** — `decision_log` 가 없으면 청산 사유가 첫날부터 소실된다.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- 🔴 결정 사유의 정본. 지금껏 청산 사유는 DB 어디에도 저장되지 않았다(청사진 §6)
CREATE TABLE IF NOT EXISTS decision_log (
    decision_id     TEXT    NOT NULL PRIMARY KEY,
    created_at      TEXT    NOT NULL,                    -- ISO8601 (UTC) · 🔴 X5 authored 축
    trade_date      TEXT    NOT NULL,                    -- 해당 시장 현지 거래일
    mode            TEXT    NOT NULL                     -- 🆕 Q-E. 🔴 기본값 없음 — 명시 필수(fail-closed)
                            CHECK (mode = 'LIVE'),       -- @sim ledger
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
ALTER TABLE order_intents   ADD COLUMN mode TEXT NOT NULL CHECK (mode = 'LIVE');   -- @sim ledger
ALTER TABLE trades          ADD COLUMN mode TEXT NOT NULL CHECK (mode = 'LIVE');   -- @sim ledger
ALTER TABLE equity_snapshot ADD COLUMN mode TEXT NOT NULL CHECK (mode = 'LIVE');   -- @sim ledger
-- 🔴 기본값이 없는 NOT NULL 추가는 **빈 표에서만** 된다 — v1 은 새 설치 한 판이라 표가 비어 있다.
--    행이 있는 표에 이 ALTER 를 돌리면 실패한다(그것이 맞다 — 옛 행의 모드를 지어내지 않는다).
-- ✅ `mode` 축 = **3값 + 파일별 CHECK**(설계 13 §8 R19 E9-2 · 인벤토리 §10-2 ② 해소):
--        `ledger.sqlite`      → CHECK (mode = 'LIVE')
--        `ledger_sim.sqlite`  → CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER'))
--    🔴 구 `DEFAULT 'SIM'` 은 지웠다 — `'SIM'` 은 `RunMode` 값이 아니라 어느 파일의 CHECK 도
--       통과하지 못한다. 기본값 없이 **명시 필수**다.
--    🔴 `mode` 칸은 이 사슬(결정 → 주문 → 체결 → 성과 · 안내)에만 둔다 — 매 실행의 첫 쓰기라 잘못 연
--       파일에서 즉시 실패한다. 나머지 표는 **파일이 경계**이고 열 때 `PRAGMA application_id` 를
--       대조한다(설계 13 §8 R20 Q1 · 01 §6-0).
-- ✅ `order_intents.dry_run`(INTEGER) = **컬럼 유지 + `ExecPolicy` 로 이름만 승격**(§9-5 ① · R19 E9-5).
--    파생 규칙: `dry_run = 1` ⇔ `ExecPolicy.dryRun` · `dry_run = 0` ⇔ `ExecPolicy.execute`.
--    🔴 `mode`(어느 계좌)와 독립이다 — 강등은 `dry_run` 만 바꾸고 `mode`·`operating_mode` 는 건드리지 않는다.

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
    mode            TEXT    NOT NULL CHECK (mode = 'LIVE'),   -- @sim ledger
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
''',
  ),
  (
    'batch_b_plan_command.sql',
    r'''
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
                     'STALE_CONTEXT','HELD_FOR_INTEGRITY','PENDING_LEASE_CONFIRM','NO_OPERATOR')),
    state_label     TEXT    NOT NULL,                    -- 엔진 생성 문구
    reject_reason_code TEXT,
    decision_id     TEXT,                                -- 집행이 결정을 만들었으면 연결
    run_mode        TEXT,                                -- 🆕 G-30(X7 A10) — 발행 시점 맥락.
    operating_mode  TEXT,                                --    `command_queue` 와 **같은 값을 복사**한다.
    lease_epoch     INTEGER,                             --    없으면 `staleContext` 판정을 사후에 증명 못 한다
    payload_digest  TEXT    NOT NULL                     -- 🔴 원문 재저장 금지 — digest 만
);
-- ✅ **state 집합 = `CommandState` − `REQUESTED` 8값**(설계 13 §8 R19 E9-6 · R20 · 인벤토리 §10-2 ① 해소).
--    · 이 표와 batch_d 의 `command_ack.state` 가 **같은 8값**이다(G-30). `command_queue` 에는 state 칸이
--      없다(append-only 명령 행 — 상태는 ack 이 증언한다).
--    · `REQUESTED` 는 기기 쪽 내구 큐의 상태라 엔진 표에 오지 않는다. `NO_OPERATOR` 는 RPC 판정값이라
--      실제로 쓰일 일은 드물지만 «집합이 같다»가 G-30 의 요구다(§10-8 ⓑ).

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
''',
  ),
  (
    'batch_c_x2_x5_local.sql',
    r'''
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
    dataset         TEXT    NOT NULL,                    -- equity_snapshot|dart|etf_universe|prices|fx · 🆕 v1.14 macro|regime|calendar
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
''',
  ),
  (
    'batch_f_x7_advisory.sql',
    r'''
-- ════════════════════════════════════════════════════════════════════════════
-- 배치 F — X7 투자 안내(수동 매매) · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-6
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 §6-0 은 「실전 첫 거래 전에 적용」이라 못 박았는데 **안내 모드의 첫 거래도 실전 첫 거래다**
--    (실계좌·실돈). 온보딩 첫날에 «투자 안내»를 고를 수 있으므로 X7 스키마를 나중 창으로 미루면
--    「사유가 DB 어디에도 안 남는 첫날」이 그대로 재현된다.
--    **마이그레이션 창은 여전히 1회이고, 배치 F 는 그 창의 여섯 번째 묶음이다.**
-- 🔴 아래는 `ledger.sqlite` 판이다. `-- @sim <종류>` 줄은 `ledger_sim.sqlite` 판에서 바뀐다(맨 아래 참조).
-- ✅ `hash_format_version` = **1 에서 시작**(이 배치의 컬럼을 포함한 판 — 올릴 옛 값도, 다시 고정할
--    해시 골든도 없다 · 설계 13 §8 R19 E9-11).
-- 🔴 이 배치의 Supabase 몫(«배치 D 추가분»)은 `batch_d_supabase.sql` 에 있다.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS advice_batch (
    batch_id        TEXT    NOT NULL PRIMARY KEY,
    trade_date      TEXT    NOT NULL,
    mode            TEXT    NOT NULL CHECK (mode = 'LIVE'),   -- @sim advice
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
    mode            TEXT    NOT NULL CHECK (mode = 'LIVE'),   -- @sim advice
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
                        CHECK (fill_origin IN ('BROKER','MANUAL','SIMULATED','BROKER_RECOVERED')
                               AND ((fill_origin = 'MANUAL') = (broker_order_no IS NULL)));
-- ✅ 설계 13 §8 R20 Q2 — **수기 체결만 브로커 주문이 없다.** 02 §2-4 `executions.broker_order_no` 는
--    v1 에서 **NULL 허용**이다(02 기본 표의 예외 1 · 새 설치라 재생성 비용 0 · 02 개정 = E9b).
--    · `MANUAL` ⇔ `broker_order_no IS NULL` — 위 CHECK 가 양방향으로 강제한다.
--    · 수기 체결의 출처는 `advice_id`(안내 밖 수기 매매면 NULL) · 모의(`SIMULATED`)는 모의 브로커가
--      `broker_orders` 행을 만든다(`intent_id` 실재 — FK 그대로).
--    · 수기 `execution_id` 형식은 01 §10-3 이 정한다(브로커 `주문번호#순번` 과 접두가 겹치지 않는다).
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
                        CHECK (operating_mode IN ('AUTO_TRADE','ADVISORY'));   -- @sim intent-operating-mode
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

-- ── 🆕 v1.10 ㊲ 원장 사건 — 매매가 아닌데 원장을 바꾸는 사실 (§6-6 · 설계 13 §8 R21) ────────────
-- 🔴 사실 표 1개 + 현금 효과는 `cash_flow` 로 **투영**한다(같은 트랜잭션 · R21 L1). 현금 = Σ cash_flow +
--    Σ executions 두 갈래 — 이 표를 현금 합산에 UNION 하지 않는다.
-- 🔴 append-only · 정정 = `REVERSAL` 1행(+ 새 기록) · 되돌리기 없음(X5). `mode` 칸 없음 — 파일이 경계.
CREATE TABLE IF NOT EXISTS ledger_event (
    event_id        TEXT    NOT NULL PRIMARY KEY,
    kind            TEXT    NOT NULL CHECK (kind IN
                     ('WITHDRAWAL','DISTRIBUTION','CORPORATE_ACTION','TAX_WITHHELD')),
    entry_kind      TEXT    NOT NULL CHECK (entry_kind IN ('ORIGINAL','REVERSAL')
                            AND ((entry_kind = 'REVERSAL') = (reverses_event_id IS NOT NULL))),
    reverses_event_id TEXT,
    effective_date  TEXT    NOT NULL,                    -- 거래일(입출금일 · 지급일 · 권리락일)
    account_alias   TEXT    NOT NULL,
    symbol          TEXT,
    amount_krw      REAL    CHECK (amount_krw IS NULL OR amount_krw > 0),   -- 부호는 kind 가 정한다
    tax_withheld_krw REAL   CHECK (tax_withheld_krw IS NULL OR tax_withheld_krw >= 0),  -- DISTRIBUTION 만
    action_type     TEXT    CHECK (action_type IN ('SPLIT','REVERSE_SPLIT')),            -- CORPORATE_ACTION 만
    ratio_from      INTEGER CHECK (ratio_from IS NULL OR ratio_from > 0),
    ratio_to        INTEGER CHECK (ratio_to IS NULL OR ratio_to > 0),
    cash_in_lieu_krw REAL   CHECK (cash_in_lieu_krw IS NULL OR cash_in_lieu_krw > 0),  -- 병합 단주 대금
    decision_id     TEXT    NOT NULL,                    -- 🔴 사유 정본: 인출 = kind 'WITHDRAWAL' ·
                                                         --    그 밖 = kind 'MANUAL'(재량 예산 모집단 아님)
    command_id      TEXT    NOT NULL,
    authored_by_device_id TEXT NOT NULL,
    authored_at     TEXT    NOT NULL,                    -- 🔴 X5 authored 축 · day_hash · 아카이브 모집단
    note            TEXT
);
CREATE INDEX IF NOT EXISTS ix_ledger_event_date ON ledger_event(effective_date, kind);
-- 🔴 kind 별 칸 조합(인출에 종목 없음 · 기업행위에 비율 필수 …)은 **엔진 선행 가드**가 강제한다
--    (`LEDGER_EVENT_FIELDS_MISMATCH`) — 조건부 NOT NULL 을 CHECK 로 쓰면 CHECK 가 사양서가 된다(G-08 과 같은 판단).
-- 🔴 투영(엔진 · 한 트랜잭션): 인출 → cash_flow(WITHDRAWAL, −) · 분배금 → (DISTRIBUTION, +세전) +
--    (TAX_WITHHELD, −세금) · 단독 원천징수 → (TAX_WITHHELD, −) · 병합 단주 → (CASH_IN_LIEU, +) ·
--    기업행위 → positions 수량 × (to/from) · 평단 × (from/to) · 무효 → 원 행의 **상쇄 행**(부호 반대 · 역비율).
-- 🔴 positions 투영기는 executions 와 이 표의 CORPORATE_ACTION 을 **한 곳에서만** 합친다 —
--    DERIVED_RESYNC 가 같은 투영기를 다시 돈다. 그 밖의 파생은 positions 만 읽는다(D7).
-- 🔴 효력일이 오늘보다 앞이면 같은 트랜잭션에서 ledger_repair(DERIVED_RESYNC · origin_code =
--    EXTERNAL_CASHFLOW 또는 CORPORATE_ACTION · recomputed_from = 효력일) 1행(C-29 와 같은 경로).

-- ── 🆕 v1.10 `cash_flow.kind` CHECK 재작성 (02 §2-5 2값 → 5값 · `CashFlowKind`) ───────────────────
-- 🔴 SQLite 의 CHECK 는 ALTER 로 못 바꾸므로 **새 테이블 → 복사 → RENAME**(위 ledger_diff 와 같은 방식).
-- 🔴 02 기본 표는 그대로 두고 이 배치가 넓힌다(«기존 표 불변» 그대로 — 새 설치에서는 빈 표의 재작성이다).
-- 🔴 컬럼 = 02 기본 6 + 배치 C `recorded_at` + 🆕 `source_event_id`(ledger_event 에서 투영된 행이면 그 id)
--    + 🆕 v1.11 `account_alias`(계좌 축 · 설계 13 §8 R22 D6 — 입금은 **계좌별 행**: B 몫 → 연금 계좌 · 나머지 → 일반 계좌).
CREATE TABLE IF NOT EXISTS cash_flow__new (
    flow_id         TEXT    NOT NULL PRIMARY KEY,
    trade_date      TEXT    NOT NULL,
    amount          REAL    NOT NULL,                    -- 들어오면 + · 나가면 − · 상쇄 행은 원 행의 반대 부호
    currency        TEXT    NOT NULL DEFAULT 'KRW',
    kind            TEXT    NOT NULL CHECK (kind IN
                     ('DEPOSIT','WITHDRAWAL','DISTRIBUTION','TAX_WITHHELD','CASH_IN_LIEU')),
    note            TEXT,
    recorded_at     TEXT,                                -- 배치 C(X4·X5 authored 축)
    source_event_id TEXT,                                -- 🆕 ㊲ 투영 행의 원 사건
    account_alias   TEXT                                 -- 🆕 v1.11 계좌 별칭(계좌별 현금 대사 · 연금 납입 누계의 원천 · R22 D6·D7)
);
INSERT INTO cash_flow__new (flow_id, trade_date, amount, currency, kind, note, recorded_at)
SELECT flow_id, trade_date, amount, currency, kind, note, recorded_at
  FROM cash_flow;
DROP TABLE cash_flow;
ALTER TABLE cash_flow__new RENAME TO cash_flow;
-- 🔴 **TWR·MWR 의 외부 흐름은 `DEPOSIT`·`WITHDRAWAL` 뿐이다** — 판정은 `CashFlowKind.isExternal` 하나로만
--    한다(분배금·원천징수·단주 대금은 수익·비용). 이 술어를 빠뜨린 쿼리는 수익률을 틀리게 낸다.

COMMIT;
PRAGMA foreign_keys = ON;

-- ════════════════════════════════════════════════════════════════════════════
-- `ledger_sim.sqlite` 판 차이 (§6-6 머리 조문 · §9-5 ④ · C8)
-- ════════════════════════════════════════════════════════════════════════════
-- ✅ 위 SQL 은 `ledger.sqlite` 판이다. 모의 원장 파일 판은 `-- @sim <종류>` 줄만 바뀐다
--    (`LedgerModeCheck` · ddl/README «두 파일» · 설계 13 §8 R19 E9-2 · R20 Q1):
--   · `@sim advice` — `advice_batch.mode` · `advice.mode` → `CHECK (mode = 'SIM_INTERNAL')`.
--     🔴 `simBroker × advisory`(§10-2 #7·#8)는 **정의 모순으로 금지**이므로 DB 도 그 행을 받지 않는다.
--   · `@sim intent-operating-mode` — `order_intents.operating_mode` 에
--     `AND (operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL')` 가 붙는다(C8).
--   · 배치 A 의 `@sim ledger` 줄(`mode IN ('SIM_INTERNAL','SIM_BROKER')`)과 한 파일 안에서 축이 맞는다.
''',
  ),
  (
    'batch_g_market_data.sql',
    r'''
-- ════════════════════════════════════════════════════════════════════════════
-- 배치 G — 🆕 시세·지표 데이터(M1-7 데이터 어댑터) · 로컬 SQLite
-- 정본: 11_앱설계/01_M2_도메인계약_초안.md §6-8 · 설계 13 §8 R23 D7·D8 · R25 G1·G2
-- 스타일: 06_시스템설계/02_데이터모델.md (컬럼 정렬 · CHECK 인라인 · 🔴 주석 · 후행 CREATE INDEX)
-- ════════════════════════════════════════════════════════════════════════════
-- 🔴 스키마 v1 한 판에 넣는다(02 기본 + 배치 A·B·C·F·G) — v1 은 첫 실기기 설치 때 얼리고 그 전 수정은 번호 1 그대로
--    (설계 13 §8 R20 Q0 · R25 G1).
-- 🔴 `mode` 칸 없음 — 시세는 실계좌·모의가 같다. 파일이 경계다(R20 Q1 — 모의 파일은 모의 파일의 시세를 쓴다).
-- 🔴 원천(`source`) 값 = 계약 `MarketDataSource`(C-15 대조) · 수집 시각 = `fetched_at`(ISO8601 UTC).

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

-- 종가만 있는 계열(FRED · OFR · VIX 등 — R23 D8) — 🔴 결측은 «행 없음»이다(값 NULL 을 저장하지 않는다)
CREATE TABLE IF NOT EXISTS market_series (
    series_id       TEXT    NOT NULL,                    -- 'NFCI' · 'T10Y3M' · 'OFR_FSI' · 'VIXCLS' … (원천 계열 이름)
    obs_date        TEXT    NOT NULL,                    -- 관측일(원천 날짜 그대로 — 발표 지연은 읽을 때 엔진이 더한다)
    value           REAL    NOT NULL,
    source          TEXT    NOT NULL CHECK (source IN
                     ('SEED_BUNDLE','KIS','FRED','FRED_CSV','OFR','MANUAL')),
    fetched_at      TEXT    NOT NULL,
    PRIMARY KEY (series_id, obs_date)
);

-- 수집 기록(R23 D7 · D10) — 🔴 응답 원문은 저장하지 않는다(본문 sha256 만) · detail 은 엔진 문장(키·토큰 금지)
CREATE TABLE IF NOT EXISTS fetch_log (
    fetch_id        TEXT    NOT NULL PRIMARY KEY,
    source          TEXT    NOT NULL CHECK (source IN
                     ('SEED_BUNDLE','KIS','FRED','FRED_CSV','OFR','MANUAL')),
    request_kind    TEXT    NOT NULL,                    -- 'KR_DAILY' · 'US_DAILY' · 'SERIES' · 'HOLIDAYS' …
    as_of           TEXT,                                -- 요청한 기준일(없으면 NULL)
    row_count       INTEGER NOT NULL CHECK (row_count >= 0),
    body_sha256     TEXT,                                -- 실패면 NULL
    fetched_at      TEXT    NOT NULL,
    outcome         TEXT    NOT NULL CHECK (outcome IN ('OK','EMPTY','FAILED')),
    detail          TEXT
);
CREATE INDEX IF NOT EXISTS ix_fetch_log_at ON fetch_log(fetched_at);

-- 🔴 기존 표는 그대로 두고 칸만 더한다(NULL 허용 — 새 행은 엔진이 늘 채운다).
ALTER TABLE daily_prices ADD COLUMN source TEXT
    CHECK (source IN ('SEED_BUNDLE','KIS','FRED','FRED_CSV','OFR','MANUAL'));
ALTER TABLE daily_prices ADD COLUMN fetched_at TEXT;
-- 🔴 X2-4 — 갭일에 다시 계산한 국면 행은 BACKFILL(`holding_signal_daily.source` 와 같은 두 값).
ALTER TABLE regime_score_daily ADD COLUMN source TEXT NOT NULL DEFAULT 'LIVE'
    CHECK (source IN ('LIVE','BACKFILL'));

COMMIT;
PRAGMA foreign_keys = ON;
''',
  ),
];
