# `ddl/` — 스키마 개정 배치 A~F (+ Z)

> **정본**: `11_앱설계/01_M2_도메인계약_초안.md` **§6**
> **스타일**: `06_시스템설계/02_데이터모델.md` 그대로 — 컬럼 정렬 · `CHECK` 인라인 · 🔴 주석 · 후행 `CREATE INDEX`
> 🔴 **이 폴더의 SQL 은 «계약의 사본»이다.** 01 §6 과 다르면 **01 이 이긴다**.

## 파일

| 파일 | 무엇 | 대상 |
|---|---|---|
| `batch_a_decision_mode.sql` | 결정 7 승인 4건 + `mode`(Q-E) — `decision_log`·`holding_signal_daily`·`rebalance_event` 신설, `positions`·`order_intents`·`trades`·`equity_snapshot` ALTER | 로컬 SQLite |
| `batch_b_plan_command.sql` | Q-F 계획 스냅샷·명령 인입·운영 파라미터·push 상태 | 로컬 SQLite |
| `batch_c_x2_x5_local.sql` | X2 재개 · X3 온보딩·자격 · X4 캘린더 · X5 정합 | 로컬 SQLite |
| `batch_d_supabase.sql` | 기기·리스·복구·명령·미러·스탬프 + RLS + `rm_*` 18표 **계약**(개별 DDL 은 파생 생성기 몫) — 🔵 실적용 **E11**(Supabase 첫 부트스트랩 · 같은 번호 · R19 E9-13) | Supabase(Postgres) |
| `batch_e_enum_widen.sql` | 기존 CHECK 재작성 = **테이블 재생성** (기존 설치 전용 경로) — ⛔ **보관 · 구현하지 않는다**(설치 0 · 설계 13 §8 R19 E9-10) | 로컬 SQLite |
| `batch_f_x7_advisory.sql` | X7 투자 안내 — `advice*` 신설 · `executions` 11컬럼 · `ledger_diff` 5값 재작성 + `applicable` | 로컬 SQLite |
| `batch_z_archive_layout.md` | GitHub 아카이브 레이아웃 — 🔴 **스키마가 아니라 출력 포맷 계약** | GitHub |

## 마이그레이션 규약 (§6-0 · §6-5 말미)

1. 🔴 **마이그레이션 창은 1회**다. 배치 A~F 를 한 창에 전부 넣는다(창을 세 번 열지 않는다).
2. 🔴 **적용 순서** — ① 신설 표 → ② CHECK 재작성(테이블 재생성) → ③ ALTER
   → ④ Supabase RLS → ⑤ Supabase `mode` 키 + **전량 재push**.
3. 🔴 `schema_version` 번호는 창 전체에 **하나만** 배정한다(부분 반영 상태를 남기지 않는다).
   ✅ **`schema_version` = 1** — 02 기본 + 배치 A·B·C·F 를 **한 판**으로 만든 첫 스키마
   (`schemaVersion` 상수 · SPEC 개정 번호 v2.33 과 **다른 축** · 설계 13 §8 R19 E9-10).
   🔴 v1 은 **첫 실기기 설치**(E11 운영 폰 · 늦어도 E15 모의 체험) 때 얼린다 — 그 전의 v1 수정은
   «창 1회» 안이고 번호는 1 그대로다. 그 뒤 변경은 v2(R20 Q0).
   🔴 부트스트랩 SQL 과 로컬 마이그레이션이 서로 다른 순서로 적용되면 뷰어의 버전 게이트(G-36)가
   `incompatible` 로 잠긴다.
4. 🔴 **실전 첫 거래 전에 적용한다.** 안내 모드(X7)의 첫 거래도 실전 첫 거래이므로
   배치 F 를 나중 창으로 미루지 않는다(§6-6 머리 조문).
5. 🔴 SQLite 는 `CHECK` 를 `ALTER` 로 바꿀 수 없다 — **새 테이블 → 복사 → RENAME**,
   `PRAGMA foreign_keys=OFF` 창을 스크립트에 명시한다. Postgres 는 `DROP/ADD CONSTRAINT` 로 된다.
6. ✅ **`hash_format_version` = 1 에서 시작**한다(`hashFormatVersion` 상수) — 배치 F 의 새 컬럼을
   포함한 판이 첫 판이다. 해시 체인 구현·해시 든 골든이 아직 없어 올릴 옛 값도 다시 고정할 것도 없다
   (설계 13 §8 R19 E9-11).
7. 🔴 배치 파일 안의 `PRAGMA foreign_keys`·`BEGIN`·`COMMIT` 은 **파일을 따로 돌릴 때의 표기**다.
   로컬 러너(E9c)는 이 제어문을 걸러 **v1 전체 + `schema_version` 행을 한 트랜잭션**으로 적용한다
   (파일마다 COMMIT 하면 F 에서 실패할 때 A~C 만 반영된 부분 상태가 남는다).

### 새 설치 vs 기존 설치

- **새 설치** — 02 기본 → `batch_a` → `batch_b` → `batch_c` → `batch_f`(로컬 · v1) · `batch_d` 는 E11.
  🔴 `batch_e` 는 **돌리지 않는다**(a~c 가 이미 넓힌 형태로 만든다).
- ~~**기존 설치**~~ — ⛔ 없다(설치 0 · 설계 13 §8 R19 E9-10). `batch_e`·§D-add 는 기록으로만 남긴다.

## 두 파일 — `ledger.sqlite`(LIVE) · `ledger_sim.sqlite`(SIM) (01 §6-0 · §9-2 · 설계 13 §8 R19 E9-2 · R20 Q1)

- 🔴 **파일이 경계다.** 두 파일은 **같은 전체 스키마**를 갖고 다른 것은 `@sim` 줄뿐이다.
  한 트랜잭션이 두 파일에 걸치지 않는다(`ATTACH` 를 쓰지 않는다).
- 🔴 **열 때 파일 식별을 대조한다** — `PRAGMA application_id` 를 파일마다 다르게 둔다
  (`LedgerFile.live` = `0x4141514C` «AAQL» · `LedgerFile.sim` = `0x41415153` «AAQS»).
  `RunMode` → 파일은 `LedgerFile.of`(SIM 계열 = `ledger_sim.sqlite`) 하나로만 정한다.
- 🔴 이 폴더의 SQL 은 **LIVE 판**이다. 코드가 있는 줄의 **끝**에 붙은 `-- @sim <종류>` 는 SIM 판에서
  그 줄의 LIVE 식을 SIM 식으로 바꾼다(`ledgerDdlFor` · `LedgerModeCheck` — 규칙의 코드 정본):

  | 종류 | LIVE 판 | SIM 판 | 자리 |
  |---|---|---|---|
  | `ledger` | `mode = 'LIVE'` | `mode IN ('SIM_INTERNAL','SIM_BROKER')` | `decision_log`·`order_intents`·`trades`·`equity_snapshot`·`rebalance_event` |
  | `advice` | `mode = 'LIVE'` | `mode = 'SIM_INTERNAL'` | `advice_batch`·`advice` — `simBroker × advisory` 금지(§10-2 #7·#8) |
  | `calendar` | `mode = 'LIVE'` | `mode = 'SIM'` | `calendar_link`·`calendar_sync_state` — 캘린더 계열 2값(G-32) |
  | `intent-operating-mode` | `operating_mode IN ('AUTO_TRADE','ADVISORY')` | 같은 식 `AND (operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL')` | `order_intents.operating_mode`(C8) |

- 🔴 `mode` 칸은 위 **10표(캘린더 2 포함)에만** 있다 — 결정 → 주문 → 체결 → 성과 · 안내 사슬은 매 실행의
  첫 쓰기라 잘못 연 파일에서 즉시 실패한다. 나머지 표는 파일 식별이 덮는다(R20 Q1).
  `resume_run.mode` 는 이름만 같은 **재개 모드**(`ResumeMode`)이며 이 축이 아니다.
- 🔴 기본값 `'SIM'` 은 없다 — 3값 체계에서 어느 파일의 CHECK 도 통과하지 못한다. `mode` 는 **명시 필수**다.

## 인벤토리 §10-2 열린 물음 — DDL 에 걸린 것의 상태 (✅ 계약 v1.9.0 · 2026-10-21)

| # | 무엇 | 상태 |
|---|---|---|
| ① | `CommandState.noOperator`(`NO_OPERATOR`)의 DDL 자리 | ✅ `command_inbox.state` = `command_ack.state` = `CommandState` − `REQUESTED` **8값**(R19 E9-6 · R20) — `command_queue` 에는 state 칸이 없다 |
| ② | `mode` CHECK 2값 vs 3값 | ✅ **3값 + 파일별 CHECK**(위 «두 파일» · R19 E9-2 · R20 Q1) |
| ③ | `CORPORATE_ACTION` vs `CORP_ACTION` | ✅ **`CORPORATE_ACTION` 으로 통합**(R19 E9-4) — `CORP_ACTION` 은 `OriginCodes.corpActionLegacy` 상수로만 남고 픽스처·신규 코드에 쓰지 않는다 |
| ④ | `order_intents.dry_run` ↔ `ExecPolicy` | ✅ 컬럼 유지 + 이름만 승격 · `dry_run = 1` ⇔ `ExecPolicy.dryRun`(R19 E9-5 · batch_a 주석) |
| ⑤ | `rm_ops_summary` 표 존폐 | ⬜ **E11 전**(배치 D 실적용과 함께 · 설계 13 §5-4) — `batch_d` 에 ⬜ 표기 |
| — | `decision_journal`·`order_intents` 의 authored 축 컬럼명 | ✅ 둘 다 `created_at`(02 기본 표 실측) |
| 🆕 | 수기 체결의 `broker_orders` FK | ✅ 02 `executions.broker_order_no` NULL 허용 + `fill_origin` CHECK «`MANUAL` ⇔ NULL»(R20 Q2 · batch_f) — 02 본문 개정은 E9b |
| 🆕 | ㊲ `recordLedgerEvent` 의 저장 자리 | ⬜ **E9a2**(설계안 → 발주자 확인 · v1 동결 전 · R20 Q3) |

**실측 정정 1건** — `06_시스템설계/02_데이터모델.md` §2-6 의 `trading_block` 은 `flag_id`·
`origin_code` 에 **CHECK 제약이 없다**(열거는 주석 + 04 §3-1 판정 SQL). 그래서 §6-5 표의
「`trading_block.flag_id` 확장」 2행은 **테이블 재생성 대상이 아니며** 고칠 것은 열거 주석과
판정 SQL 이다 — `batch_e` 말미 ⓐ·ⓑ 참조.
