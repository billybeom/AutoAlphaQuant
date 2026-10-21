# 배치 Z — GitHub 아카이브 레이아웃 (`canonGithub` 대조의 계약)

> **정본**: `11_앱설계/01_M2_도메인계약_초안.md` §6-7 (G-33)
> 🔴 **스키마가 아니라 «출력 포맷 계약»이다.** 그래서 `.sql` 이 아니라 `.md` 이고, 마이그레이션 창
> 밖이지만 `hash_format_version` 을 통해 **같은 창에 묶인다**(§6-0).
> 🔴 06 M4-5 산출물 칸에는 「레이아웃·`checkpoint.json` 스키마는 **01 §6-7 이 정본**」을 병기한다 —
> 두 곳에 적으면 두 정본이 된다.

🔴 **아카이브는 «정본의 사진첩»이며 재생성 원천이다**(X4 가 캘린더 JSONL 을 따로 두지 않는 근거).

## 계약

| 항목 | 계약 |
|---|---|
| 경로(실전) | `archive/{yyyy}/{yyyy-mm-dd}/{table}.jsonl` |
| 경로(모의) | `sim/{yyyy}/{yyyy-mm-dd}/{table}.jsonl` — §9-2 격리(실전 아카이브에 모의 체결이 섞이면 해시 체인의 의미가 사라진다) |
| 한 줄 | **한 원장 행**. 컬럼 순·수치 표기·NULL 규칙은 🔴 **X5-1 정규 직렬화와 같은 골든벡터**를 쓴다 — 둘이 다르면 `canonGithub` 이 매일 불일치한다 |
| 대상 표 | `ledger_daily_hash` day_hash 대상 스트림 **전량** + 배치 F 신설 6표(`advice`·`advice_transition`·`external_holding`·`self_report_balance`·`self_report_line`·`handover_session`·`operating_mode_transition`) + `operating_param_log`(§6-2) + 🆕 v1.10 `ledger_event`(㊲ · 01 §19 · day_hash 모집단과 같아야 한다 · SPEC 02 §2-13 v2.33) |
| 체크포인트 | `archive/checkpoint.json` = `{ schema_version, hash_format_version, authored_date, chain_hash, operator_epoch, writer_device_id, committed_at }` **단일 객체**이며 매 커밋마다 덮어쓴다(이력은 git 이 갖는다) |
| 금지 | 🔴 **force push 금지**. 커밋 실패는 **매매를 막지 않고** 24h 적체 시 P1(06 M4-5) |

## 조문

- 🔴 **해시 체인 모집단과 아카이브 대상은 같아야 한다** — 「아카이브에는 있는데 `day_hash` 산출
  모집단에는 없는 표」가 생기면 `canonGithub`·`canonCalendar` 대조가 «불일치 아님»을
  **증명하지 못한다**(대조가 통과한 것이 아니라 **볼 것이 없었던 것**이다).
- 🔴 위 «대상 표» 목록은 `batch_c_x2_x5_local.sql` 의 **authored 축 매핑과 한 목록**이며,
  표를 늘릴 때 두 곳을 함께 고친다.
- 🔴 신설 표를 모집단에 넣으면 **`hash_format_version` 을 올리고 골든벡터를 다시 고정한다**.
- 🔴 `operating_param_log` 가 아카이브 대상인 이유(§6-2) — 아카이브에 없으면
  「이력이 남는다」는 폰 재설치로 깨진다.

## ⛔ 이 파일이 확정하지 **못한** 것

- `checkpoint.json` 의 `schema_version`·`hash_format_version` **값**. 전자는 마이그레이션 창
  전체에 하나만 배정되는 번호이고(§6-0 — 아직 배정 전), 후자는 배치 F 의 `executions` 11컬럼
  추가로 **올려야 하는** 값이다(새 값도 골든도 아직 없다).
  🔴 `lib/src/contract_version.dart` 가 같은 이유로 두 상수를 두지 않는다.
- `decision_journal`·`order_intents` 의 authored 축 **실제 컬럼명**(§6-3 말미 ⚠️) —
  `06_시스템설계/02_데이터모델.md` 확인 후 확정한다. 미확정이면 정규 직렬화 골든의 입력이
  표마다 달라진다.
