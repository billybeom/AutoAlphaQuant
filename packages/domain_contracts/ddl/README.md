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
| `batch_d_supabase.sql` | 기기·리스·복구·명령·미러·스탬프 + RLS + `rm_*` 18표 **계약**(개별 DDL 은 파생 생성기 몫) | Supabase(Postgres) |
| `batch_e_enum_widen.sql` | 기존 CHECK 재작성 = **테이블 재생성** (기존 설치 전용 경로) | 로컬 SQLite |
| `batch_f_x7_advisory.sql` | X7 투자 안내 — `advice*` 신설 · `executions` 11컬럼 · `ledger_diff` 5값 재작성 + `applicable` | 로컬 SQLite |
| `batch_z_archive_layout.md` | GitHub 아카이브 레이아웃 — 🔴 **스키마가 아니라 출력 포맷 계약** | GitHub |

## 마이그레이션 규약 (§6-0 · §6-5 말미)

1. 🔴 **마이그레이션 창은 1회**다. 배치 A~F 를 한 창에 전부 넣는다(창을 세 번 열지 않는다).
2. 🔴 **적용 순서** — ① 신설 표 → ② CHECK 재작성(테이블 재생성) → ③ ALTER
   → ④ Supabase RLS → ⑤ Supabase `mode` 키 + **전량 재push**.
3. 🔴 `schema_version` 번호는 창 전체에 **하나만** 배정한다(부분 반영 상태를 남기지 않는다).
   ⛔ 번호는 **아직 배정 전**이다 — §6-0 은 「`00_SPEC §9` 최신값 +1 을 쓰되 v2.31(P0S) 소비
   여부를 먼저 확인」이라고만 정했다. 🔴 부트스트랩 SQL 과 로컬 마이그레이션이 서로 다른
   순서로 적용되면 뷰어의 버전 게이트(G-36)가 `incompatible` 로 잠긴다.
4. 🔴 **실전 첫 거래 전에 적용한다.** 안내 모드(X7)의 첫 거래도 실전 첫 거래이므로
   배치 F 를 나중 창으로 미루지 않는다(§6-6 머리 조문).
5. 🔴 SQLite 는 `CHECK` 를 `ALTER` 로 바꿀 수 없다 — **새 테이블 → 복사 → RENAME**,
   `PRAGMA foreign_keys=OFF` 창을 스크립트에 명시한다. Postgres 는 `DROP/ADD CONSTRAINT` 로 된다.
6. 🔴 배치 F 의 새 컬럼이 직렬화 규약에 들어가므로 **`hash_format_version` 을 올리고
   골든벡터를 다시 고정한다**.

### 새 설치 vs 기존 설치

- **새 설치** — `batch_a` → `batch_b` → `batch_c` → `batch_f` → `batch_d`.
  🔴 `batch_e` 는 **돌리지 않는다**(a~c 가 이미 넓힌 형태로 만든다).
- **기존 설치** — `batch_a`(신설분) → `batch_e`(CHECK 재작성) → `batch_b`·`batch_c` 신설분
  → `batch_f` → `batch_d`(+ §D-add).

## ⚠️🔴 이 폴더가 확정하지 **않은** 것 — 임의 확정 금지

인벤토리 `docs/contracts_inventory.md` §10-2 의 열린 물음 중 DDL 에 걸린 것:

| # | 무엇 | 지금 파일의 상태 |
|---|---|---|
| ① | `CommandState.noOperator`(`NO_OPERATOR`)의 DDL 자리 — `command_inbox.state`·`command_ack.state` 어디까지 넓히는가 | **넣지 않았다**. `batch_b`·`batch_d` 에 ⚠️ 주석 |
| ② | `mode` CHECK 2값(`SIM`·`LIVE`) vs 3값(`SIM_INTERNAL`·`SIM_BROKER`·`LIVE`) | **2값 유지**(01 §9-1 «확정 전에는 DDL 을 고치지 않는다»). `batch_a`·`batch_f` 에 ⚠️ 주석. 🔴 확정되면 `batch_a`·`batch_b`·`batch_f`·픽스처 `meta.mode`·C-15 를 **한 커밋에서** 고친다 |
| ③ | `CORPORATE_ACTION` vs `CORP_ACTION` 통합 | 코드 목록은 `labels/origin_codes.dart` 가 **둘 다** 갖고, 픽스처·신규 코드는 `CORPORATE_ACTION` 만 쓴다 |
| ⑤ | `rm_ops_summary` 표 존폐 | `batch_d` 에 ⬜ 로 표기(개별 DDL 은 파생 생성기 몫이라 어느 쪽이든 이 파일은 안 바뀐다) |
| — | `decision_journal`·`order_intents` 의 authored 축 **실제 컬럼명** | `batch_c` 에 ⚠️ 주석. `02_데이터모델.md` 확인 후 확정 |

**실측 정정 1건** — `06_시스템설계/02_데이터모델.md` §2-6 의 `trading_block` 은 `flag_id`·
`origin_code` 에 **CHECK 제약이 없다**(열거는 주석 + 04 §3-1 판정 SQL). 그래서 §6-5 표의
「`trading_block.flag_id` 확장」 2행은 **테이블 재생성 대상이 아니며** 고칠 것은 열거 주석과
판정 SQL 이다 — `batch_e` 말미 ⓐ·ⓑ 참조.
