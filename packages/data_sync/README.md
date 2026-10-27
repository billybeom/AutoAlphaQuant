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

`domain_contracts` · `core_engine` · `sqlite3`(로컬 정본 · 순수 Dart FFI — 설계 13 §8 R19 E9-12 · ✅ 01 §1-1 v1.9) · (E11) `supabase_flutter`.

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

## 지금 상태 — 🟡 로컬 정본 연결 + 스키마 v1 (E9-0 · E9c)

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
- ⬜ 리포지토리 구현체(`LocalSqliteReader`) · 명령 인입(수송 · 명령 TTL) · Supabase(E11) = 그 뒤.
