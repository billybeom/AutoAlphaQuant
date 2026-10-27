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
