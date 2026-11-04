# data_sync — M4 동기화·보안 · X1 기기 이전 · X4 캘린더 · X5 정합·복구

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M4** sync-gateway · **X1** device-migration · **X4** calendar-journal · **X5** ledger-integrity
> **정본**: 01_M2_도메인계약 **§4-1 구현 대상** · **§6 스키마 DDL** · `06_시스템설계/02_데이터모델.md`

## 무엇을 담나

| 갈래 | 내용 |
|---|---|
| 리포지토리 구현체 | `LocalSqliteReader`(폰 · 정본 SQLite) · `SupabaseReadModel`(viewer · RLS + Realtime) |
| 명령 API 구현체 | Supabase **append-only** 명령 테이블 INSERT (`CommandApi`) |
| 키 금고 | KIS 앱키·Supabase 키·GitHub PAT 보관. 🔴 폰(operator) 전용 |
| 리스 원장 | `operator_lease` — 주문 자격이 있는 기기는 **정확히 1대**(X1) |
| 정합 검사 | 해시 체인·`LedgerDiffRow` 산출(X5) |
| 캘린더 어댑터 | 구글 캘린더 화이트리스트 직렬화(X4) |
| 🆕 기기 로컬 암호화 저장소 | 명령 내구 큐 ⓐ + `DraftStore`(입력 초안) 구현 — 06 M4-9 · 01 §12-1-6 구현 의무 10조(하드웨어 결속 키 암호화 · 반출 금지 · 모드 계열 분리 · `executed` 자동 삭제). 🔴 operator 조립에만 주입 |

## 의존 — 허용 (01 §1-1)

`domain_contracts` · `core_engine` · `sqlite3`(로컬 정본 · 순수 Dart FFI — 설계 13 §8 R19 E9-12 · ✅ 01 §1-1 v1.9) · `crypto`(수집 본문·시드 sha256) · 🆕 `http`(FRED·OFR — E8c · 01 §1-1 v1.14 · 시험은 `MockClient`) · (E11) `supabase_flutter`.

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety`.

## 이 패키지가 지는 규칙 4개

1. **DB 쓰기 주체는 엔진 하나다**(경계 규칙 ②). 앱은 명령 테이블에 INSERT할 뿐이고, 쓰기는 여기를 통해서만 일어난다. `command_queue`에 UPDATE·DELETE를 부르면 C-16이 실패한다.
2. **계약 3조**: 두 구현체가 같은 필드값을 낸다 / 모든 스트림이 `AsOf`를 싣는다 / 없으면 빈 리스트가 아니라 `ListResult`를 준다. **`emptyKind`를 채우지 않으면 컴파일되지 않는다.**
3. **리스가 끊기면 스스로 봉인한다.** 갱신이 T분(권고 30분) 실패하면 발주 경로가 자동으로 막힌다 — 사람이 누르는 버튼이 아니다.
4. **외부로 나가는 것은 해시·요약뿐이다.** 브로커 근거 원문은 로컬 전용(`evidenceHash`), 계획 원문 대신 digest, 캘린더에는 **손익·평가액·계좌 전체번호·시크릿이 타입에 아예 없다**.

## ⚠️ 착수 전 실측 2건

1. **KIS 앱키 재발급 후 기존 접근토큰(24h) 잔존 유효성** — X1 착수 전 필수. `07_검증원장.md` 기록.
2. **Google OAuth 동의화면 «테스트» 상태가 7일 만에 만료되는가** — 🔴 사실이면 **X4(캘린더) 자체를 접는다.**

## ⚠️ 미결 (임의 확정 금지)

- Supabase 스키마 소유·버전 — 읽기 모델 표를 로컬에서 자동 생성할지, 부트스트랩 SQL을 손으로 관리할지(01 §8-11).
- `role` 클레임 발급 위치 — 명령 INSERT 정책이 읽는 `app_metadata.role`을 QR 페어링 RPC가 세팅하는지 Auth 훅이 세팅하는지(01 §8-13). 확정 전에는 정책 2개 분리 상태를 유지한다.
- `SleeveCatalogEntry`·`FeatureFlags`의 원천 표 — 엔진 config 직독 vs 읽기 모델 push(01 §8-14). viewer도 같은 값을 봐야 한다(계약 3조 ①).

## 지금 상태 — 🟡 로컬 정본 연결 + 스키마 v1 (E9-0 · E9c) + 🆕 시세·지표 저장·시드·FRED·OFR (E8c)

- ✅ `openLedgerDatabase` — 02 §1 PRAGMA 5개(WAL · NORMAL · FK ON · busy 5000 · cache 64MB)를 연결마다 걸고 되읽는다. 하나라도 다르면 연결을 닫고 거부한다(`:memory:` 도 거부 — 원장은 파일이다).
- ✅ `openLocalLedger(directory, runMode)` — `LedgerFile.of` 가 고른 파일(`ledger.sqlite` · `ledger_sim.sqlite`)을 열고 **스키마 v1**(02 기본 + 배치 A·B·C·F·G 한 판 · 64표 — 🆕 G = 시세·지표 · 계약 v1.14)을 보장한다.
  - 새 파일 = 전 문장 + `application_id` + `schema_version` 행을 **한 트랜잭션**으로(중간 실패 = 표 0).
  - 이미 있는 파일 = 다시 적용하지 않고 **파일 식별·번호만 대조** — 다른 계열 · 식별 없음 · 더 새 판 · 번호 없음은 열지 않는다.
  - SIM 판 CHECK 는 `ledgerDdlFor`(계약) · 배치 파일의 `BEGIN`·`COMMIT`·`PRAGMA foreign_keys` 는 `stripControlStatements` 가 거른다 · `ATTACH` 0.
- 🔴 스키마 자산 `lib/src/local/schema_v1_sql.dart` 는 **생성 파일**이다 — 02(설계 저장소)·`domain_contracts/ddl` 이 바뀌면 `python -I tool/make_local_schema.py <02 경로>` 로 다시 만든다(배치 사본은 시험이 바이트 대조 · 02 는 sha256 머리 · R20 Q2 정정 1줄).
- 🔴 v1 은 첫 실기기 설치 때 얼린다(설계 13 §8 R20 Q0) — 그 전의 수정은 번호 1 그대로, 그 뒤 변경은 v2 마이그레이션.
- ✅ `SqlitePlanSnapshotStore`(E7b1) — 계획 스냅샷 `plan_snapshot`(outputs = `DepositPlan.toJson()` · inputs = `PlanInputs` JSON v1 · 순번 = 저장본 파생) · 🆕 `readSnapshot`(계획 · 입력 원값 · 바인딩 — 동기).
- ✅ `SqliteDepositRegistrar`(E7b2) — 실입금 등록 **한 트랜잭션**(`BEGIN IMMEDIATE`): `decision_log`(DEPOSIT · `DEPOSIT_REGISTERED`) + 계좌별 `cash_flow` + 바인딩 UPDATE(`… IS NULL`) + `command_inbox`. 거부 = 감사 1행만 · 원장 무결성 = 보류(쓰기 0) · 같은 명령 재전달 = 감사 기록의 결과 · 중간 실패 = 행 0. 판정은 core_engine `judgeDepositRegistration`. 🆕 E7b3 — 한도 재검사는 같은 트랜잭션 안에서 원장을 읽어 센다(연 한도 − `pensionUsedInYear` · 신고값 포트 · 처리 시점 KST 연도).
- ✅ `SqliteDepositLedger`(E7b3) — `cashRows(계좌)`(누계 입력 · 상태 공급자 E11 도 같은 셈) · `registeredCash(planId)`(계획 ↔ 결정 ↔ 현금 행 조인 = «계획 대비 실제»의 앵커).
- 🆕 **E8c — 시세·지표**(설계 13 §8 R23 · R26 · `lib/src/market/`):
  - `SqliteMarketStore` — `daily_prices`(OHLCV · ^GSPC·KOSDAQ 지수·국내 ETF) · `market_series`(종가만 9계열 — 이름 = `MarketSeriesIds`) **덧붙이기만**(있는 날은 고치지 않고 «같음/개정»만 센다) · CHECK 를 넘지 못하는 행은 쓰지 않고 돌려준다 · `regimeSources()` = 국면 원천 한 벌 · `krBars()` = `judgeKrPlanDay` 입력.
  - `SqliteRegimeStore`(`regime_score_daily` · 국면 달력 날짜 · LIVE/BACKFILL) · `SqliteGapStore`(`data_gap` · id = `{dataset}:{key}:{from}:{reason}` · 끝날짜만 늘어남) · `SqliteFetchLog`(`fetch_log` · 원문 0 · 본문 sha256).
  - `importSeedBundle` — 자산 `assets/seed/` 11파일(= core_engine 재현 번들 바이트 같음 · 1.35 MB) → 기준일 2026-08-14 **이하**만 · sha256 불일치·파일 없음 = 0행 · 한 트랜잭션 · 멱등. 🔴 시험이 «시드 → SQLite → 엔진» 국면을 참조 엔진 정답지(`regime_parity.json`)와 **비트로** 맞댄다(수 변환 = pandas `precise_xstrtod` — core_engine `pandasPreciseXstrtod`). 🆕 E8d1(R28 K6·K7) — `spy` 파일은 `SPY_ADJ` 계열 + `daily_prices` US `SPY` 일봉(원 OHLCV) 둘로 간다 · `regimeSources()` 기본 = 실전 P0S(`dist_days` = SPY 거래량) = V6a 정답지(`regime_parity_v6a.json`) 비트 일치 · 골든은 `regimeSources(distVolume: DistVolumeSource.gspcIndex)`.
  - `FredClient`(키 있으면 JSON → 실패면 키 없는 `fredgraph.csv` · 키 없으면 CSV 만) · `OfrClient`(`fsi.csv`) · `getWithRetry`(10s · 1→2→4s · 429·5xx·타임아웃·연결 실패만 다시) · `MacroCollector`(FRED 4 + OFR 1 · 마지막 저장일부터 하루 겹쳐 받기 = 백필·소급 · 끝내 실패 = FAILED + `data_gap(macro)` — P1 알림은 잡 E11).
  - 시험 픽스처 `test/fixtures/{fred,fred_csv,ofr}/` = 응답 본문만(🟡 손으로 씀 — 첫 실호출 때 실응답으로) · 실호출 시험 = `network` 태그(기본 건너뜀 · `dart_test.yaml`).
  - 🆕 **E8d2b** `QuoteCollector`(설계 13 §8 R30) — core_engine 포트(`DailyQuoteFeed`)만 부른다(KIS 구현은 잡 E11 이 넣는다 · 01 §1-1). 국면 대상 5(`^GSPC`·`SPY` 일봉 · `SPY_ADJ`·`RSP_ADJ` · `KQ11`) + KR 계획 종목(`close` = 수정 · `close_unadj` = 원). 🔴 **끝난 세션만**(KR 18:00 · US 다음 날 07:00 KST — 그 뒤 행은 버리고 센다) · 창 = 마지막 저장일(포함) ~ 끝난 세션 · 이미 최신이면 부르지 않는다 · 실패 = FAILED + `data_gap` · 빠진 세션 = 하루짜리 MISSING_ROW · 🔴 KIS ^GSPC 거래량은 늘 0 이라 실전 국면은 SPY 거래량을 읽는다(R27 I1). VIX·VIX3M = FRED 가 대신 받는다(`MacroCollector.standIns` · `collect(withStandIns: true)` — KIS 지수 코드 미실측).
- 🆕 **E10c — 주문 원장** `SqliteOrderLedger`(core `OrderLedger` 포트 구현 · 설계 13 §8 R36):
  - 🔴 `insertIntent` = **자동 커밋 한 문장**(돌아오면 둘째 연결에서 보인다 = NR-1 6.5 · AC-S04) — 연결에 열린 트랜잭션이 있으면 INSERT 하지 않고 StateError · UNIQUE · PK 충돌(확장 코드 2067 · 1555)만 false.
  - 상태 전이 = `WHERE status = 앞 상태` 만(아니면 StateError) · 접수 = SUBMITTED + `broker_orders`(`submitted_at` = SUBMITTING 시각) **한 트랜잭션** · 브로커 거절 = `error_message` 접두 `BROKER: `(orders_today 에 센다 · D22).
  - 판정 SQL — 킬스위치(`kill_switch_state`) · 묶음(04 §3-1 ①) · 미해소 UNKNOWN 3인자 · SAF-406(`strategy_state_current`) · SAF-408(04 §1 SQL → `JOURNAL_MISSING` 자동 설정 · 해제 `auto:SAF-408`) · SAF-410(집행일 전월 · 동결 XKRX 월말 뒤 3거래일 유예 → `TIER_B_UNJUDGED` 자동 설정 · 해제 `auto:SAF-410`).
  - 스키마 자산 재생성(02 v2.38 — `order_intents.status` += `EXPIRED` · 주석 · 정정 0).
  - 🆕 **E10e1 — 체결 원장**(core `FillLedger` · R38): `openIntents`(SUBMITTED · PARTIAL · 브로커 주문 있음) · `applyFill` **한 트랜잭션** = `executions`(R31 키 · 조회 시각 · BROKER · ESTIMATED 비용) + `broker_orders`(누적 · 평균 단가 · 🔴 누적 정본 = `raw_response` 의 누적 칸 JSON) + `positions`(매수 평단 · 매도 수량 · 🔴 보유를 넘는 매도 = StateError · 0 이면 지움) + 의도 상태(FILLED · PARTIAL · EXPIRED · CANCELLED) · `markUnresolved`(→ UNKNOWN)
  - 🆕 **E10e2 — 이월 · 해소 원장**(core `CarryLedger` · `UnknownLedger` · R39): `expiredIntents`(실효 = 주문 − 누적 체결 − 취소 확인 · 사용 세션 = 서로 다른 집행일 수) · `splitProgress`(앞 집행일 · 7단계를 지난 것) · 🔴 논리 id 비교 = `substr(decision_id, 1, n) = '{논리 id}@'`(`LIKE` 금지 — `_` 와일드카드) · `unknownIntents`(브로커 주문 없는 UNKNOWN) · `linkUnknown`(broker_orders + SUBMITTED 한 트랜잭션) · `rejectUnknown`(`UNKNOWN_NOT_FOUND: ` — orders_today 에 센다) · `noteUnknownMiss`(`error_message` 앞 `UNKNOWN_MISS@…`)
  - 🆕 **E10f — 대사 원장**(core `ReconLedger` · R40): `krHoldings`(KR) · `orderFills`(그날 브로커 주문별 체결 합) · `recordReconciliation` **한 트랜잭션** = `reconciliation_log`(id = 원장이 시각 + 일련으로) + `ledger_diff`(CANON_BROKER · BLOCKING · OPEN · 내용 해시 id — 같은 어긋남 = 한 행 · 해제 뒤 다시 보이면 다시 연다) + `trading_block(RECON_MISMATCH)`(세우기만) · `clearReconBlock`(플래그 해제 · OPEN → RESOLVED + 원인 코드 · 해제 로그) · `reconClearJournalExists`(`decision_journal.kind = 'RECON_CLEAR'`)
- 🆕 **E11f2 — `monthly_rebalance` 본체 · 계획 보관 · 오늘의 대상**(설계 13 §8 R48 · 🆕 06 M1-28): `MonthlyRebalanceJob`(월말 다음 KR 세션 08:00 · 국면 다시 계산 → 월말 미국 세션 값 없음 = 실패 · 원장 보유 → core `computeMonthEndRun` · POT 보유 = 실패(계절 A 전) · 🔴 한 트랜잭션 = `plan_snapshot` REBALANCE + `rebalance_event` MONTHLY_REGULAR + `decision_log` REBALANCE · 같은 월말 = 멱등) · `SqliteRebalancePlanStore` · `StoredPlanTargetSource`(core `TargetSource` 구현 — 최근 계획 · 집행 첫날 ≤ 오늘 < 만료 · 이미 낸 대상(논리 id@ · 종목 · 방향) 뺌)
- 🆕 **E11f1 — 아침 · 저녁 잡 본체 넷**(설계 13 §8 R47 F2~F9 · 🆕 06 M1-28 — 본체만 · 핑 · 휴장은 trading_runtime `runJob` · 조립 앱이 감싼다): `DailyDataJob`(18:30 · KR 대상만 = `KQ11` + 계획 종목 · KR 하루 판정 → `data_gap` · 실패 · 판정 멈춤 = P1 `DATA_SOURCE_DOWN`) · `UsDataJob`(07:30 · US 국면 대상 4 + 매크로 대체 계열) · `DailySignalJob`(20:00 · `computeRegime` + 신선도 상한 → `regime_score_daily` 덧붙이기) · `EquitySnapshotJob`(20:30 · core `computeEquitySnapshot` · 🔴 현금 = D+2 · 실패 = 쓰지 않음 · `SqliteEquitySnapshotStore` 같은 날 덮어쓰기 · 모드 칸) · `regimeAsOfLookup`(같은 날짜 포함 as-of)
- 🆕 **E11e — 기기 로컬 암호화 저장소**(설계 13 §8 R46 G1~G10 · 06 M4-9 순수 몫 · 01 §12-1-6 의무 10조 · §10-8): `DeviceLocal`(계열마다 SQLite 파일 `device_local_{sim|live}.sqlite` — 🔴 정본 원장 밖 · 값 = core `SealedBox` 봉함(aad = 판 · 계열 · 이름공간 · 키) · 평문 = 이름공간 · 키 · 계열 · 연결 명령 id · 순번 · 한 사슬 순서 · 🔴 동기 throw 0 · 에러 · 보고에 값 0) · `DeviceDraftStore`(= `DraftStore` 구현 · 꼴 검사 · 현재 계열만 · 해독 실패 = null + `DeviceStoreFault` 보고 · 모르는 `lastCommandId` = null · `discardSimDrafts` · LIVE 지우는 메서드 없음) · `LocalCommandQueue`(큐 ⓐ · «전송 대기» · 만료 없음 · `applyReceipt`(executed = 연결 초안 자동 삭제) · `recordLocalRejection` · `unsent` · `markSent` · `watchCommand` 의무 ①~④) · ⬜ 실물 봉함(Keystore DEK + AES-GCM) · `allowBackup=false` = E11p · 전송 ⓑ = E11m · `CommandApi` 명령 메서드 조립 = 그 조각
- 🆕 **E11c — healthchecks.io 어댑터**(`HealthchecksClient` = core `JobHeartbeat` · `WatchdogRemote` 구현 · 설계 13 §8 R45 C2~C6 · 06 M1-12): 슬러그 핑 `POST hc-ping.com/{핑 키}/{슬러그}[/start|/fail]` · `rid` = UUID 꼴일 때만 · 🔴 `create=1` 없음 · 메모 1,000자 · 자기 키 `<가림>` · 200 만 성공 · 재시도 = 망 · 시간 초과(10초) · 429 · 5xx 만 2번(1 → 2초) · 관리 API v3(`X-Api-Key` · `GET /api/v3/checks/` · pause · resume = 그때 `?slug=` 로 다시 찾아 uuid · 🔴 엔진 생존 체크 pause 거절 · 읽기 전용 키 = 읽기만) · 키 = 금고 `healthchecks.ping_key` · `healthchecks.api_key`(부를 때마다 읽음) · 🔴 오류 · 문자열에 URL · 키 · uuid 0 · 실호출 = `network` 태그(`test/network_healthchecks_test.dart` · 키 파일 · `AAQ_HC_SLUG` · 체크를 만들지 않는다)
- 🆕 **E11d — 시크릿 스캔 게이트**(`scanForSecrets` · 설계 13 §8 R44 E7 · 06 M4-6 · 지도 D16): ① 정확 값(금고의 값 전부 · 8자 이상 — 계좌 8자리는 여기서) ② 접두 `ya29.` · `1//` · `ghp_` · `github_pat_` · `Bearer` ③ 시크릿 필드 이름(SAF-904 · JSON · 키=값)에 가림 아닌 값 · 🔴 맨 8자리 숫자 패턴 없음(`ord_dt` · 주문번호 오탐 0) · 결과에 값 · 발췌 0(지문 · 줄 · 칸만) · 막히면 다시 시도 0 → 부르는 쪽(E11n · E11l2)이 P1 · 금고 포트 · 마스킹은 core_engine `security/`(01 §1-1 이 data_sync ↔ broker_gateway 를 막아서)
- ⬜ 리포지토리 구현체(`LocalSqliteReader`) · 명령 인입(수송 · 명령 TTL) · Supabase(E11) = 그 뒤.
