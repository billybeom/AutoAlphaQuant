> **사본 · 정본은 `packages/domain_contracts/fixtures/README.md`.** 부록의 파일 목록은 조립 시점 실측입니다.

# `fixtures/` — 모의 데이터 픽스처 (**계약 v1.6 · 135파일** — G4 77 + `m6/journal_empty.json` + 🆕 v1.1 신규 18 · 2026-09-17 + 🆕 R2 준비 1(`m6/journal_draft_receipts_5.json`) · 2026-09-23 + 🆕 v1.2 R2b 선행 7 · 2026-09-25 + 🆕 v1.3 R10 선행 11 · 2026-09-28 + 🆕 v1.4 R11 선행 7 · 2026-09-30 + 🆕 v1.5 R12 선행 4 · 2026-10-07 + 🆕 v1.6 R12 선행 9 · 2026-10-08 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`)

정본: `11_앱설계/01_M2_도메인계약_초안.md` **§5** · `docs/contracts_inventory.md` **§8** ·
화면 명세 02 «모의 데이터» · 03 §15 · 04 §10.

화면은 **네트워크 없이 이 파일만으로** 그려진다. 파일이 없으면 화면 담당 AI가 가짜 데이터를 만들고,
그 값이 스크린샷에 남는다 — 그것이 G4가 하드 게이트인 이유다(00_README §0-1).

## 🔴 대원칙 — 실키 금지

- 실키·계좌 전체번호·비밀번호 **0건**. 계좌는 **별칭만**(`"연금저축"`·`"일반"`) — 🆕 v1.4 쓸 수 있는 별칭은
  아래 «픽스처 계좌 별칭 표»가 정본이다.
- 티커는 실제 국내 ETF를 쓰되 **수량·가격은 가공값**이다. **가짜 데이터만** 넣는다.
- 위반은 §7 **C-14**가 잡는다. 판정부는 `lib/src/fixtures/fixture_loader.dart` 의
  `scanForSecrets` 이며 현재 135파일(🆕 2026-10-08 v1.6) 전량 **적발 0건**이다.
- 어떤 AI에게도 실키를 붙여넣지 않는다. 실키는 완성된 M9 화면에서 발주자가 직접 입력한다.

## 🔴 누가 고치나

**픽스처 갱신은 계약 소유자(M2)만 한다.** 화면 AI가 「테스트가 안 맞아서」 픽스처를 고치는 것은
**반려 사유**다. 픽스처는 골든 스냅샷의 입력이기도 해서, 값을 바꾸면 스냅샷이 깨진다 —
**그것이 의도된 게이트**다. 화면 명세가 나열한 파일명은 **요청 목록**이지 자기 소유 선언이 아니다.

---

## 봉투 형식

전 픽스처가 `meta` + `as_of` + `empty_kind` + `empty_label` + `has_more` + `rows` 형태를 쓴다.
뒤 네 값은 `ListResult<T>`(01 §2-1)에 그대로 대응하며 **빈 목록 픽스처도 싣는다** — 그래야
「없음」(`NO_DATA` + 문구)과 「모름」(`NOT_LOADED` + `stale_reason_code`)이 화면에서 갈린다.
예시 JSON은 01 §5에 있다.

```json
{
  "meta": { "fixture_version": "0.1.0-draft", "contract_version": "1.6.0",
            "generated_at": "2026-09-06T09:00:00Z", "mode": "LIVE",
            "config_hash": "cfg_fake_0000000000000000", "seed": 20260906,
            "notice": "합성 데이터. 실계좌·실키 없음." },
  "as_of": { "observed_at": "2026-08-31T09:00:00Z", "trade_date": "2026-08-31",
             "source": "LOCAL_SQLITE", "stale_after_seconds": 93600,
             "label": "잔고 기준 2026-08-31 종가" },
  "empty_kind": "NO_DATA", "empty_label": null, "has_more": false,
  "rows": [ … ]
}
```

읽는 창구는 `lib/src/fixtures/fixture_loader.dart` 하나다 —
`decodeEnvelope(json)` · `decodeList<T>(json, T Function(Map) rowFrom)` ·
`decodeSingle<T>(…)`. 🔴 로더는 **순수 Dart**이고 파일을 읽지 않는다(§8-5). 경로 상수는
`lib/src/fixtures/fixture_paths.dart` 의 `FixturePaths` 이며 `FixturePaths.all` 이 전량 목록이다.

### 🔴 세 가지 표기 규약 (어기면 계약 테스트가 깨진다)

1. **금액은 문자열이되 `decimal` 정규형으로 적는다** — `"38250"` 이지 `"38250.00"` 이 **아니다**.
   `decimal` 3.x 는 값을 정규화하므로(`Decimal.parse('38250.00').toString() == '38250'`)
   `.00` 을 남기면 「픽스처 → DTO → 다시 JSON」 문자열 비교가 **내용이 같은데도** 어긋난다
   (`docs/toolchain_notes.md` §4-1). ⚠️ 01 §5 봉투 예시의 `"38250.00"` 은 「문자열이다」가 요점이며
   자릿수 규약이 아니다. 숫자 리터럴로 쓰면 C-8이 실패한다.
2. **`meta.contract_version` 은 `lib/src/contract_version.dart` 상수와 같은 축**이다.
   ✅ **지금 값은 `1.6.0`**(2026-10-08 R12 선행 M2 보강 · 01 §15-4 · 브랜치 `m2/contract-v1.6-r12` · ~~⬜ 로컬 커밋 —
   PR 대기~~ ✅ 병합 PR #25 squash `995c1f4` — 상수와 기존 126개 + 신규 9개 = **135개**를 **함께** 올렸다. 🔴 기존 126개 가운데 112개는
   `"contract_version"` **한 줄만** 바뀌었고, 14개는 본문도 개정됐다(그중 1개는 개명 `m7_next_rebalance_d6` →
   `m7_next_rebalance_countdown`) — 아래 «계약 v1.6» 절).
   ~~`1.5.0`~~(2026-10-07 R12 선행 M2 보강 · 01 §15-3 — 상수와 기존 122개 + 신규 4개 = **126개**를
   **함께** 올렸다. 🔴 기존 122개 가운데 120개는 `"contract_version"` **한 줄만** 바뀌었고, 2개는 본문도
   개정됐다 — 아래 «계약 v1.5» 절).
   ~~`1.4.0`~~(2026-09-30 R11 선행 M2 보강 · 01 §14 — 상수와 기존 115개 + 신규 7개 = **122개**를
   **함께** 올렸다. 🔴 기존 115개 가운데 99개는 `"contract_version"` **한 줄만** 바뀌었고, 16개는 본문도
   개정됐다 — 아래 «계약 v1.4» 절).
   ~~`1.3.0`~~(2026-09-28 R10 선행 M2 보강 · 01 §13 — 상수와 기존 104개 + 신규 11개 = **115개**를
   **함께** 올렸다. 🔴 기존 104개 가운데 100개는 `"contract_version"` **한 줄만** 바뀌었고, 4개는 본문도
   개정됐다 — 아래 «계약 v1.3» 절).
   ~~`1.2.0`~~(2026-09-25 R2b 선행 M2 보강 · 01 §12 — 상수와 기존 97개 + 신규 7개 = **104개**를
   **함께** 올렸다. 🔴 기존 97개는 `"contract_version"` **한 줄만** 바뀌었다 — 본문 무수정).
   ~~`1.1.0`~~(2026-09-17 M2 보강 — 상수와 그때의 96개 픽스처를 **함께** 올렸다 ·
   2026-09-23 R2 준비의 `m6/journal_draft_receipts_5.json` 도 `1.1.0` 으로 태어났다 — DTO 무변경 추가라
   버전을 올리지 않았다). ~~`1.0.0`~~(2026-09-08 G3 확정 — 01 문서가 «상태: 확정 v1.0» 줄을 받은 커밋에서
   상수와 77개 픽스처를 함께 올렸다). 한쪽만 올리지 않는다. ~~⚠️ 01 §5 예시의 `"M2-0.1"` 은
   코드 상수와 형식이 다르다~~ ✅ **해소** — 01 §5 봉투 예시도 같은 커밋에서 `"1.0.0"` 으로 맞췄다.
   🔴 `fixture_version`(`0.1.0-draft`)은 **다른 축**이며 계약 확정이 올리는 값이 아니다 — 픽스처
   내용이 개정될 때 M2 가 올린다(C-15 는 이 값이 비어 있지 않은지만 본다).
3. **JSON 키는 snake_case**(패키지 `build.yaml` 의 `field_rename: snake`), **열거값은
   SCREAMING_SNAKE**(`@JsonValue` 로 못 박은 값 그대로). 🔴 기계 변환이 틀리는 자리가 있다 —
   `SleeveId.satellite → "SAT"` · `StepRequirement.required_ → "REQUIRED"` ·
   `CommandKind.manualFillRecord → "RECORD_MANUAL_FILL"` · `AdviceActionId → "RECORD"/"SKIP"/"DETAIL"`.

### 봉투 확장 — 부속 블록 (봉투 형제 키 표)

한 화면이 「목록 + 그 목록의 요약」을 함께 받는 갈래가 있어(`A-1` 안내함이 대표) 봉투에
**형제 키**를 하나 더 싣는다. 봉투 필수 6키는 그대로이고 로더는 이 키를 무시한다.

🔴 🆕 v1.4 — **이 표가 봉투 최상위 키의 화이트리스트다**(01 §14-12 · 미결 40 과 같은 뿌리).
봉투 필수 6키(`meta`·`as_of`·`empty_kind`·`empty_label`·`has_more`·`rows`)와 아래 표의 키 밖의
최상위 키는 계약 검사가 실패시킨다(`lag_notice` 류 고아 키 재발 방지 — v1.4 에서 `m7_goal_path_hold`
의 `lag_notice` 를 지우고 그 문장을 `m7_goal_path_off` 의 행 필드 `deviation_text` 로 올렸다).
키를 늘리려면 **이 표를 먼저** 고친다. 한 행에 키 하나씩 적는다(표 = 기계가 읽는 목록).

| 키 | 타입 | 쓰는 파일 |
|---|---|---|
| `summary` | `AdviceInboxSummary` | `m6/advice_*.json` 9벌 |
| `advice_summary` | `AdviceInboxSummary` | `m8/ops_home_advice_open.json` · `m8/ops_home_advice_zero.json` |
| `counterfactual` | `AfterTaxLadder` | `m7/aftertax_ladder_1.json` — 🆕 v1.6 **C-30 골든 대조 전용**(화면 경로는 `AnnualReviewVm.afterTaxCounterfactual` · `m7_annual_*` 3벌이 이 블록의 사본을 싣는다) |
| `counterfactual_collapsed` | bool | `m7/aftertax_ladder_1.json` — 🆕 v1.6 C-30 대조 전용(접힘 값은 DTO 에 두지 않는다 · `S7-7` 반사실 카드는 늘 기본 접힘) |
| `trust` | `LedgerTrustBadge` | `m6/self_report_1.json` |
| `index` | `HandbookIndex` | `m8/handbook_page_sleeve_b.json` |
| `incident_alert` | `AlertItem` | `m8/incident_token_expired.json` |
| `preserved_input` | 원시(`ManualFillRecord` 모양 · `context` 없음) | `m6/fill_rejected_price.json` |
| `reject_reason` | `ReasonChip` | `m6/fill_rejected_price.json` |
| `price_range_source_date` | `TradeDate` | `m6/fill_rejected_price.json` |
| `active_flags` | `BlockFlag` 목록 | `m6/advice_blocked.json` · `m8/ops_home_blocked.json` · `m8/ops_home_resume_gap7.json` |
| `resume_headline` | 문장 | `m8/ops_home_resume_gap7.json` |
| `resume_route` | 링크 | `m8/ops_home_resume_gap7.json` |
| `credential_use` | 원시 | `m8/onboarding_fresh_advisory.json` |
| `operating_mode` | 원시 | `m8/onboarding_fresh_advisory.json` |
| `finish_headline` | 문장 | `m8/onboarding_finish.json` |
| `holiday_notice` | 문장 | `m8/watchdog_holiday.json` |
| `lease_notice` | 문장 | `m8/restart_lost_phone.json` |

🔵 v1.4 정정 — 옛 표의 «`pending_notice` 계열 · `m7/m7_monthly_pending.json`»은 지웠다(그 파일의 형제 키
`pending_d_day_text` 는 v1.1 에서 폐기됐고 지금 형제 키가 없다). `credential_use`·`operating_mode`·
`finish_headline`·`holiday_notice`·`lease_notice` 5키는 실물에 있었는데 옛 표에 빠져 있던 것을 실측으로 더했다.

---

## 파일 목록 (135)

### 계약 코어 14 — `fixtures/` 바로 아래 (01 §5 · 인벤토리 §8-2·§8-3)

| 파일 | 건수 | 내용 |
|---|---|---|
| `journal_30.json` | 30 | 체결 22 · 부분 3 · 거부 2 · UNKNOWN 1 · prevented 1 · SIM 1 |
| `holdings_6.json` | 6 | 069500(A) · 379810·132030(B) · 0085P0·411060(C) · POT 1종 — `pnl` 은 3건만 |
| `performance_24m.json` | 2계열 | 월간 TWR·MWR 각 24점 + 결측 구간 1(`UNAVAILABLE`) + 벤치마크 · 🆕 v1.3 표시 필드(정규 자리·글자·눈금 — 값·구간·문장은 그대로) |
| `rebalance_6.json` | 6 | monthlyRegular 3 · seasonal 1 · band 1 · deposit 1 · 🆕 v1.5 행 링크 `detail_deep_link` 6 · 버튼 `journal_timeline_link` 5(`re_20261030_01` 은 버튼 없음 = 부재 표본) · 🆕 v1.6 행 순서 = **거래일 내림차순** · 행 `as_of` = 봉투(관측 시각) · `thresholds`(band·seasonal 1행씩 · 나머지 `[]`) · `SleeveWeight.label` 완성 문장 |
| `resume_report_1.json` | 1 | 7거래일 갭 · `RECOVERY_DRY` · 4/3/2/1/2 |
| `safety_states.json` | 5 | normal · alert · reduced · halted · stopped(자격 충족 1) |
| `alerts_12.json` | 12 | P0 2 · P1 4 · P2 6(묶임 2) |
| `ledger_diffs_4.json` | 4 | `CANON_BROKER` 1(blocking) · 파생 3(observational) |
| `onboarding_fresh.json` | 14 | 처음 시작하기(verified/failed/expired 각 1) |
| `onboarding_reconnect.json` | 9 | 재연결 갈래 |
| `deposit_plan_1.json` | 1 | 🔵 v1.4 **코어 전용(행 = `DepositPlan` · 화면 미사용)** · 월 납입 = 엔진 설정값 예시 · 잔여 = 원화 현금 대기(D2) · 주문 초안 4 · `funding_steps` **null** |
| `deposit_plan_funding_1.json` | 1 | 🔵 v1.4 **코어 전용** · 납입 조달 발동 · C 방어 자산 매도 초안 + 조달 칩 `PENSION_FUNDING` · `funding_steps` **1단**(0원 단계 삭제) · 잔여 0 |
| 🆕 `range_presets_4.json` | 4 | **v1.1** `ConfigRepository.watchRangePresets()` — 최근 30일(**`is_default`**)·이번 달·올해·전체 기간. 🔴 `is_default` 는 정확히 1건(C-34 ①) |
| 🆕 `sleeve_catalog_4.json` | 4 | **v1.1** `ConfigRepository.watchSleeves()` — A·B·C·POT(`rolls_up_to: A`). P0S 라 새틀라이트 행 없음 |

### `m6/` 41 — 매매일지·보유·X7 안내·수기 체결 (02 «모의 데이터»)

🆕 **계약 v1.5(2026-10-07 · R12 선행 M2 보강 · 01 §15-3) 2건** —
`journal_rebalance_scope_1`(`J-1` 회차 조건의 범위 설명 `JournalRebalanceScope` 1행 — `re_20260803_01` · 칩 글자 «2026-08-03 월 납입 배분 회차»(식별자 없음 · C-40 ④) · 씨앗 기간 2026-08-03 ~ 2026-08-17(`preset_code` null · `is_default` false) = `journal_30` 에서 그 회차에 묶인 3행을 덮는다(C-40 ⑨)) ·
`journal_rebalance_unknown`(모르는 회차로 연 `J-1` 봉투 — 0행 + `NO_DATA` + 엔진 문장 · 🔴 `journal_empty` 의 문장과 **다르다**(C-40 ⑦)).
자세한 것은 아래 «계약 v1.5» 절.

🆕 **계약 v1.2(2026-09-25 · R2b 선행 M2 보강 · 01 §12) 7건** —
`draft_records_j3`(`J-3` 기기 로컬 초안 `DraftRecord` 5행 — 🔴 **행 순서가 의미**다, 아래 표 · 테스트는 **한 행씩** 시드한다) ·
`draft_records_x7`(X7 초안 모양 고정 3행 — `RECORD_MANUAL_FILL`/`ad_0002`(세금 `""` = 모름) · `SKIP_ADVICE`/`ad_0001` · `SELF_REPORT_BALANCE`/`PERIODIC_AUDIT`(수량 `""` = 아직 안 적음 ≠ 0) · 화면 미사용 — X7 카드가 쓴다) ·
`journal_read_written`(`J-3R` 사전 저널 읽기 `DecisionJournalVm` — `d_20260901_a_31` · 본문 원문 **여러 줄 긴 글**(잘림 회귀 탐지) · 메모 있음 · 「이 결정 보기」 링크 · 🔵 본문은 **읽기 레이아웃 표본**이다 — `draft_records_j3` 행 2 가 제출된 뒤의 저장본이 아니다(초안 원문 ↔ 읽기 본문 대조 테스트 금지 · 읽기 본문은 엔진 저장본)) ·
`journal_read_no_note`(`d_mf_0002` · 메모 `null` · 결정 링크 `null` — 부재 두 갈래) ·
`journal_read_not_written`(2행 — 0 `d_20260810_b_27` · 1 `d_20260901_a_31`(🆕 검증 반영 · `journal_read_written` 과 **같은 결정의 «미작성»** = `J-3` executed 직후 «미작성 → 본문» 전환 표본 · C-34 ⑧ 이 짝을 지킨다) · 「저널 미작성」 · `body` **null** — «미작성»도 값이다) ·
`decision_detail_journal_written`·`decision_detail_journal_draft_link`(`decision_detail_amended` **사본**에서 두 키만 — `journal_state_label` + `journal_link` → `aaq://journal/read/d_mf_0002`(작성됨) / `aaq://journal/draft/d_mf_0002`(미작성) · 🔴 목적지는 엔진이 고른다 — C-34 ⑨ · 🔵 원본 `decision_detail_amended` 의 «규칙대로 — 저널 대상이 아닙니다»는 v1.1 표본값으로 이탈과 무관하게 남긴 것이다(기존 픽스처 무수정 원칙) — **저널 대상 갈래의 정본은 이 두 사본**이다(같은 결정의 다른 시점 스냅샷으로 읽는다)).
🔴 초안 행에는 모드·맥락·기기·시각 키가 없다(C-35 ⑤) · 확인값(`duplicate_ack`·`off_hour_trade`·`declared_complete`)·세션값도 없다(C-35 ④).

| `draft_records_j3` 행 | 이름 | 키(`kind`/`target_id`) | 본문 | `last_command_id` | 쓰는 곳 |
|---|---|---|---|---|---|
| 0 | `J3_PARTIAL` | `JOURNAL_DRAFT`/`d_20260901_a_31` | 근거 < 40자 · 기대 결과 `""` · `rule_cited` null · 메모 `""` | null | 복원 · 버튼 비활성 |
| 1 | `J3_COMPLETE` | 같은 키 | 근거 ≥ 40자(trim 기준) · 기대 결과 있음 · `RULE_DISCRETION_BUDGET` · 메모 `""` | null | 복원 · 버튼 활성 |
| 2 | `J3_SUBMITTED` | 같은 키 | 행 1 과 같음 | `cmd_20260831_0031`(= `journal_draft_receipts_5` 의 명령) | 재구독 · 거부/집행 복원 |
| 3 | `J3_RETIRED_RULE` | `JOURNAL_DRAFT`/`d_20260810_b_27` | 완성 본문 · `rule_cited` = `RULE_RETIRED_SAMPLE` | null | 사라진 code = 미선택 · 다른 키 비노출 |
| 4 | `J3_OTHER_NOTE` (🆕 검증 반영) | `JOURNAL_DRAFT`/`d_20260901_a_31` | 근거 ≥ 40자 · 기대 결과 있음 · `RULE_OTHER`(두 스펙 모두 `requires_note: true`) · **메모 비어 있지 않음**(한국어 원문) | null | 메모 복원 · 메모 필수 규칙의 버튼 활성(메모를 지우면 비활성) |

🔵 `RULE_RETIRED_SAMPLE` 은 **문서화된 폐기 표본**이다 — 두 폼 스펙(`journal_draft_spec_*`)의 `rule_cited_options` 어디에도 없는 code 를 일부러 실었다(복원 때 code 대조 실패 = 미선택 · 문구 없음).

🆕 **계약 v1.1(2026-09-17 · M2 보강) 13건** —
`journal_filter_catalog`(`J-1` 필터: 상태 7 · 출처 3 · 종목 6 — 기간·슬리브는 코어의 `range_presets_4`·`sleeve_catalog_4`) ·
`journal_badges_2`(`J-1` 상단 배지: 「확인 중 2건」→`J-5` · 「리뷰 대기 3건」→`J-4` — 🔴 건수는 문구 안에 있다) ·
`journal_masked_integrity`(`LEDGER_INTEGRITY` 중의 일지 6행 — `*_text` 4종이 「숨김」. 🔴 **가림은 엔진 읽기 경로가 끝낸다**(01 §2-10) · C-34 ③ 이 숫자 누출을 잡는다) ·
`decision_detail_full`(`J-2` 정상 6단계 · 「이 회차」 링크) · `decision_detail_partial`(부분 체결 3행 + 「잔여 40주 미체결」) ·
`decision_detail_rejected_saf309`(거부 — SAF 코드 **원문 그대로** + 거부 추적 1행 `LEVEL_3_PORTFOLIO`) ·
`decision_detail_unknown`(체결 「확인 중」 + `pending_notice_text`) · `decision_detail_reevaluated_child`(X2 재판정 child — 「원행 보기」) ·
`decision_detail_amended`(advisory 체인 `ADVICE`·`MANUAL_RECORD` · 원본→역분개→재기재 3행 · 「정정」 링크 · 🔴 스냅샷 없음 문구) ·
`journal_draft_spec_discretion`(`J-3` 재량 개입 — 서약문 3줄 **[합성]**) · `journal_draft_spec_recon_clear`(서약문 0줄 · 원인 코드 문맥 칩) ·
`unknown_board_2`(`J-5` 장기 1(강조·M5 안내 링크) + 신규 1 · 단계 4칸) · `unknown_board_empty`(「미해소 건이 없습니다」).
🔵 같은 창에서 `journal_30`·`manual_fills_8` 전 행에 `side_label`·`quantity_text`·`price_text`·`commission_text`·`tax_text`·`detail_deep_link` 가 들어갔다(§8 미결 34·35·36).

🆕 **R2 준비(2026-09-23) 1건** — `journal_draft_receipts_5`(`J-3` 제출 결과 `CommandReceipt` 5행 · kind `JOURNAL_DRAFT` ·
state `REQUESTED`·`EXECUTED`·`REJECTED`·`EXPIRED`·`HELD_FOR_INTEGRITY` — **한 명령(같은 `command_id`)의 갈래**라 테스트는 `state` 로 골라 쓴다.
🔴 거부 사유까지 실린 문구는 `state_label` 하나다 — 거부 행의 `reject_reason_code` = `JOURNAL_ALREADY_EXISTS`(`JournalDraftRejectCodes` · 사전 키 `journal_draft_reject`)는 표시·분기 대상이 아니다.
거부·만료 행은 «입력값은 그대로 남아 있습니다»(C17) · 짝이 되는 폼 스펙 = `journal_draft_spec_discretion`(`d_20260901_a_31`) · 봉투 형제 키 없음).

🆕 `journal_empty`(2026-09-17 · C4 R1-Bob-J1 — `J-1` 골든 `j1_empty` 의 입력. 0행 + `empty_label` 실림. `journal_30` 의 0행 슬라이스는 `empty_label` 이 null 이라 화면이 그릴 것이 없다 — 「없음」은 문구를 실어야 한다(계약 3조 ③)) ·
`advice_12`(open 4·partial 1·filled 3·skipped 1·expired 2·revoked 1) · `advice_empty`(🔴 `open_count == 0`) ·
`advice_blocked`(`ADVICE_LEDGER_UNVERIFIED`) · `advice_expired_confirm` ·
`advice_no_action`(🔴 **C-26의 입력** — `kind='NO_ACTION'` · `suppressed` · `actions` 빈 목록 ·
요약은 `open_count == 0` **이면서** `has_suppressed_notice == true`) ·
`advice_handover_cooling`(🔴 C14 예외 둘째 — `handover_cooling_active == true` + `open_count == 0`) ·
`advice_detail_partial` · `advice_detail_onhold` ·
`advice_viewer_4`(🔴 **A6 마스킹판 · C-27의 입력** — `symbol`·`quantity`·`price_band` null + `phone_only_label`) ·
`fill_form_spec` · `fill_form_spec_stale`(A16 — 폼을 열지 않는 갈래) ·
`manual_fills_8`(original 5 · 상쇄+재기재 한 쌍 · backdated 1) ·
`fill_rejected_price`(🔴 **입력값 보존** — C17) · `advice_skip_reasons` · `self_report_1` ·
`external_holdings_2` · `entry_gate_nov_pass_1`(🔵 11월 재판정 통과 — 실데이터로는 검증 불가한 경로).

### `m7/` 59 — 성과·리밸런싱·플래너·세후·이행 갭 (03 §15)

🆕 **계약 v1.6(2026-10-08 · R12 선행 M2 보강 · 01 §15-4 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`) 9건** —
`m7_rebalance_preview_default`(`S7-6c` 초안 — `RebalancePreviewResult` `{preview}` · 2026년 9월 1일 회차 · 초안 2행 · 골든 `s76c_preview`) ·
`m7_rebalance_preview_in_band`(빈 초안 — `order_drafts: []` + `orders_empty_text` · 경고 1줄 · 골든 `s76c_draft_empty`) ·
`m7_rebalance_preview_blocked`(차단 2행 — 0 `blocked_text` 만(버튼 부재 · 골든 `s76c_blocked`) · 1 `blocked_text` + `blocked_action` → `aaq://x2/resume-report`(위젯 테스트 전용)) ·
`m7_next_rebalance_none`(«예정 없음» — `empty_label` 만 · 골든 `s76c_none`) ·
`m7_rebalance_sim`(SIM 회차 2행 — 봉투 `meta.mode` LIVE · 행 `mode` `SIM_INTERNAL` · `mode_label` 두 행 · `section_label` 행 0 만 · 골든 `s76a_sim`) ·
`m7_annual_offwindow`(창 밖 연간 리뷰 — `year` 2025 · `CLOSED` · 골든 `s77_offwindow`) ·
`execution_gap_empty`(`NO_DATA` 문장) · `execution_gap_not_applicable`(`NOT_APPLICABLE` 문장) · `execution_gap_masked_recon`(RECON_MISMATCH 가림 «?» · 게이지 키 없음) — 골든 `s710_empty`·`s710_not_applicable`·`s710_masked_recon`.
🔵 같은 창에서 14건의 본문이 개정됐다(개명 `m7_next_rebalance_d6` → `m7_next_rebalance_countdown` 포함) — 아래 «계약 v1.6» 절.

🆕 **계약 v1.5(2026-10-07 · R12 선행 M2 보강 · 01 §15-3) 2건** —
`m7_rebalance_detail_advisory`(`m7_rebalance_detail_band` 의 **거울** — 같은 회차 `re_20260601_01` · 버튼 글자만 advisory 갈래 낱말 · 골든 `s76b_advisory` 의 입력 · C-40 ⑥) ·
`m7_rebalance_empty`(`S7-6a` 빈 타임라인 — 0행 + `NO_DATA` + 엔진 문장 · 골든 `s76a_empty` 의 입력).
🔵 같은 창에서 `rebalance_6`·`m7_rebalance_detail_band` 의 본문이 개정됐다 — 아래 «계약 v1.5» 절.

🆕 **계약 v1.4(2026-09-30 · R11 선행 M2 보강 · 01 §14) 5건** —
`m7_deposit_plan_blocked`(`S7-4` 미리보기 차단 2행 — 0 `blocked_text` 만(버튼 부재) · 1 `blocked_text` + `blocked_action` → `aaq://x2/resume-report`) ·
`m7_deposit_plan_input_rejected`(입력 거부 — `input_rejected_text` 만) ·
`m7_deposit_plan_funding`(`deposit_plan_funding_1` 과 같은 계획을 감싼 래퍼 + `register_blocked_text`(브로커 대조 미완 — 등록만 불가) 동시 표본) ·
`m7_deposit_register_receipts_4`(실입금 등록 `CommandReceipt` 4행 · kind `DEPOSIT_REGISTER` — **한 명령(같은 `command_id`)의 갈래**이고 🔴 **행 순서가 뜻**이다: 0 `REQUESTED` · 1 `EXECUTED` · 2 `EXPIRED` · 3 `HELD_FOR_INTEGRITY`. 거부(`REJECTED`) 행은 없다 — 거부 코드 사전이 아직 없다(01 §8 미결 74)) ·
`m7_goal_path_off`(`S7-9` 이탈 — `deviation_text` 있음).
🔵 같은 창에서 16건의 본문이 개정됐다 — 아래 «계약 v1.4» 절.

🆕 **계약 v1.3(2026-09-28 · R10 선행 M2 보강 · 01 §13) 11건** —
`m7_report_archive_empty`(`S7-1b` 빈 아카이브 — `rows` 0 + VM `empty_label`) ·
`m7_disclosure_gate_first`(`S7-2G` 이번 달 첫 열람 — `gate_open: true` · 🔴 `friction_line` **키 없음** = 그 줄이 없다) ·
`m7_disclosure_gate_frequent`(잦은 열람 — `friction_line` 있음) ·
`m7_disclosure_gate_closed`(닫힌 게이트 — `gate_open: false` · `route`·`friction_line` 키 없음 · `headline` 이 **닫힌 까닭**을 말한다) ·
`m7_disclosure_view_receipts_4`(열람 기록 `CommandReceipt` 4행 · kind `DISCLOSURE_VIEW` — **한 명령(같은 `command_id`)의 갈래**이고 🔴 **행 순서가 뜻**이다: 0 `REQUESTED` · 1 `EXECUTED` · 2 `EXPIRED` · 3 `HELD_FOR_INTEGRITY`. 거부(`REJECTED`) 행은 없다 — 거부 코드 사전이 아직 없다) ·
`m7_perf_monthly_sim_split`(월간 누적 18점 — 앞 3점 `SIM_EXCLUDED`(값 없음 · 「합산 제외」) + 실전 15점 · 구간 `SIM_EXCLUDED` 1 + `MEASURED` 1 · 벤치마크 없음) ·
`m7_perf_daily_manual`(일간 누적 21점 · **결측 0** · 구간 `MANUAL_EXECUTED` 1 — 구간 안에서도 선이 이어진다) ·
`m7_perf_monthly_period`(월간 **비누적**(월별) 24점 · 음수 있음 · 기준선이 가운데 · 결측 2점 · 벤치마크 있음) ·
`m7_perf_yearly`(연간 누적 3점 — 마지막 해는 8월까지) ·
`m7_perf_unavailable_gap`(불가 — `points`·`segments`·`y_ticks` 빈 목록 · `benchmark` null · `unavailable_label` 있음) ·
`m7_perf_masked_integrity`(차단 가림 — 같은 모양 · 문장만 다르다 · `safety_states` 행 4 와 짝).
🔵 같은 창에서 기존 4건의 본문이 개정됐다 — `performance_24m`·`m7_perf_daily_gap`(표시 필드 더함) · `m7_disclosure_gate`(`gate_open: true`) · `m7_report_archive_18`(최신 달부터 · `section_label` · 모의 달은 `route` 없음). 자세한 것은 아래 «계약 v1.3» 절.

🆕 **계약 v1.1 3건** — `m7_monthly_masked_integrity`(13항목 전부 「숨김 — 원장 무결성 점검 중」 · 상세 링크 0 · 13칸 유지) · `m7_monthly_masked_recon`(⑦ 비중만 `?` 미확정 표기 — 02 §2-2 표) · `m7_contrib_partial`(§8 미결 45 — C 슬리브 「산출 불가」 · `normalized: 0.0` · `unavailable_label`).
🔵 같은 창에서 `m7_monthly_2026_08`·`_gap` 에 `generated_at_text`·`config_hash`·항목 `detail_deep_link`(④⑤→`S7-3` · ⑧→`S7-10`)가, `m7_monthly_pending` 에 `pending_notice_text` 가 들어갔다(봉투 형제 키 `pending_d_day_text` 는 **폐기** — §8 미결 40·41·43).

`aftertax_ladder_1`(정본 갈래 **6단**(사전 6층 전부) + 반사실 1(`CF_POT_TAXABLE_COMP38` 6단 · 접힘) · `is_reference_only: true` · 🆕 2026-10-06 01 §8 미결 77 정정 — 층 값은 골든 `aftertax_full_S7` 4자리 그대로(C-30 ⓙ 가 **골든 사본** `test/contracts/support/golden/aftertax_full_S7.json` 과 대조) · «정직 기대» 층만 `cagr_pct`·`end_mult` 없음 · 🆕 v1.6 두 블록에 `reference_only_label`) ·
`realized_alloc_S7`(🔴 **C-31의 입력** — 회계 열 대조) · `ledger_trust_4` ·
`execution_gap_cant`·`_wont`·`_mixed`(🔴 **B21 3갈래** — ~~`mode_advice_line` 이 각각 다르다~~ 🆕 v1.6 cant·wont 문장이 서로 다르고 mixed 는 **키 없음**(null = 줄 부재 · 03 §14-b ⓒ) · 행 = `ExecutionGapResult` 래퍼 `{report, as_of}`) · `execution_gap_1`(🆕 v1.6 래퍼 · `mode_advice_line` 키 없음 = 정상 달) ·
`m7_deposit_plan_default`·`_limit`·`_expired`(🔴 이름에 금액 금지 · 🆕 v1.4 행 = `DepositPreviewResult` 래퍼) ·
`m7_withdrawal_general`·`_pension_penalty`·`_shortfall` ·
`m7_monthly_2026_08`·`_gap`·`_pending`(13항목 고정 배열) · `m7_report_archive_18` · `m7_disclosure_gate` ·
`m7_perf_daily_gap` · `m7_dd_context_normal`·`_deep` · `m7_contrib_3sleeve` ·
~~`m7_next_rebalance_d6`~~ 🆕 v1.6 개명 `m7_next_rebalance_countdown`(«2026년 9월 1일 · D-1») · `m7_rebalance_detail_band`(🆕 v1.5 버튼·행 링크 · 🆕 v1.6 대조 행·관측 시각) · `m7_annual_2026`·`_first_year`(🆕 v1.6 `year_label` · 세후 사본 2블록) ·
`m7_goal_path_on`·`_hold`·`_realworld`(🆕 v1.4 `GoalPathVm` 재설계 — 생성 스크립트).

### `m8/` 18 — 셸·운영 홈·알림·온보딩 (04 §10)

`ops_home_normal`·`_blocked`·`_resume_gap7`·`_advice_open`·`_advice_zero` · `ops_rhythm_rows` ·
`recon_board_diff`(🔴 칸 수 **5 고정** · `CANON_SELF_REPORT` 는 `applicable: false` = 「점검 안 함」) ·
`alerts_p0_ack` · `alerts_digest` · `alerts_advice_9codes`(X7 알림 9종) ·
`watchdog_delayed` · `watchdog_holiday`(🔴 휴장의 쉼은 결측이 아니다) · `incident_token_expired` ·
`onboarding_finish` · `restart_lost_phone` · `onboarding_fresh_advisory` ·
`onboarding_mode_pick`(🔴 **기본 선택 없음 · 「권장」 배지 없음**) · `handbook_page_sleeve_b`.

> ⚠️ 04 §10 목록의 `onboarding_fresh.json` 은 **코어의 같은 이름 파일이 정본**이라
> `m8/` 에 다시 두지 않았다(같은 데이터가 두 벌이 되면 한쪽만 갱신된다).

### `m9/` 3 — 설정·운영 모드 전환 (05)

`handover_states`(경로 4 × 성공/실패 — `SIM_TO_AUTO` 통과 · `FRESH_AUTO` 차단 ·
`ADOPT_LEDGER` 모름 · `HANDBACK_MANUAL` 차단 + `handback_branch`).

🆕 **계약 v1.4 2건** — `contribution_setting_default`(`ConfigRepository.watchContributionSetting()` 의 한 값 ·
`amount "100000"` · `amount_input_text "100000"` · `pension_limit_note_text` 있음) ·
`contribution_setting_no_limit_note`(같은 값 · `pension_limit_note_text` **키 없음** = 그 줄이 없다).
🔴 `equivalent_note_text` 는 **금액 없이** 서술한다(12%-등가 납입액을 금액으로 적으면 C-32 ⑥ 폐기값에 걸린다 · 01 §8 미결 75).

🔴 **`m9/` 이름 규약** — 폴더마다 기존 관례를 따른다. `m7/` 은 `m7_` 접두(`m7/m7_deposit_plan_default` →
`FixturePaths.m7M7DepositPlanDefault`), `m9/` 는 **접두 없음**(`m9/handover_states` → `FixturePaths.m9HandoverStates` ·
`m9/contribution_setting_default` → `FixturePaths.m9ContributionSettingDefault`).

---

## 값을 고를 때 지킨 것

- **티커는 전부 자리표시자**다(01 §5 말미). `069500` 은 KOSPI200 ETF라 P0S 슬리브 A(KOSDAQ 지수)와
  맞지 않지만 **실전 종목 확정 전까지 고치지 않는다** — 화면은 티커를 슬리브의 정의로 읽지 않는다
  (A/B/C 라벨은 `SleeveCatalogEntry.label`). 🔴 POT 자리의 `357870` 은 03 §15 가 열거한 5종 밖이라
  **이 회차가 새로 고른 자리표시자**이며, 실전 종목이 확정되면 함께 교체된다.
- **월 납입 예시값은 `100000`**(01 §5 · 04 §10) **하나**다. 🔴 **파일명에 금액을 넣지 않는다**
  (`_default`·`_limit`·`_expired`). 값은 파일 **안**에만 있고 운영값의 창구는
  `ConfigRepository.watchContributionSetting()` 하나다. C-32는 `ui_*` 소스만 보며 `fixtures/` 는 대상이 아니다.
  🆕 v1.4 문구 통일(01 §14-13) — **픽스처는 폐기값만 금지**(`fixture_conventions_test.dart` 의 정규식)이고
  예시값 `100000` 은 허용한다. 🔴 **운영값이 든 실문장**(목표 경로의 «월 납입 얼마» 기록 문장 · 12%-등가 한 줄)은
  픽스처에서 **금액 없이** 서술한다(01 §8 미결 75).
- **세후 사다리 4자리 수치를 인용해도 되는 자리는 `m7/aftertax_ladder_1.json` 과 골든뿐**이다
  (01 §2-4). 코드·라벨·주석에 옮기지 않는다.
- **`ENTRY_GATE_OCT`** 은 「10월말 진입 게이트 통과」 = 정상 통과 사유다. 🔴 `F1_ENTRY_DEFER`·
  `F1_ENTRY_LATE` 로 바꾸지 않는다(01 §5 말미 — 코드명 확정 전까지 픽스처를 고치지 않는다).
- 정정 픽스처(`m6/manual_fills_8.json`)의 상쇄 행은 **수량·수수료의 부호를 뒤집어** 담는다 —
  🔴 C-22(「필터 없는 단순 SUM 이 최종 수량·금액과 일치」)가 성립하려면 그래야 한다.
- **`m6/entry_gate_nov_pass_1.json` 의 `F1_ENTRY_GATE`** 는 `GateBadge.code` 자리에 놓인
  **자리표시자**다. 01 §3-7 은 계절 게이트의 **사유 코드 3종**(⚠️ `F1_ENTRY_OK`·`F1_ENTRY_DEFER`·
  `F1_ENTRY_LATE`)만 등재했고 **게이트 배지 코드는 문서 어디에도 없다**. 🔴 `ENTRY_GATE_OCT` 와
  같은 취급이다 — M2-3 이 이름을 등재하기 전에는 **고치지 않는다**. 같은 파일의 다른 배지
  (`SAF-401`)는 §3-2 에 있는 코드다.

---

## 계약 v1.3 (2026-09-28 · R10 선행 M2 보강 · 01 §13)

화면 카드 `R10-Bob-S7x`(`S7-1b` 아카이브 · `S7-2G` 열람 게이트 · `S7-2` 수익률 탐색)를 보내기 전에 한 보강이다.

### 개정 4건 (파일 이름·`FixturePaths` 상수 그대로)

| 파일 | 무엇이 바뀌었나 |
|---|---|
| `performance_24m.json`(2행) · `m7/m7_perf_daily_gap.json` | 새 표시 필드만 **더했다** — 점 `x_normalized`·`y_normalized`·`date_text`·`value_text` · 구간 `start_normalized`·`end_normalized` · 시리즈 `series_label`·`period_label`·`y_ticks`. 🔴 기존 `value`·구간 날짜·문장은 한 글자도 바뀌지 않았다 |
| `m7/m7_disclosure_gate.json` | `gate_open: false → true`(뜻 = 엔진이 지금 진입을 허용하는가 · `route` 가 있는 게이트는 열린 게이트다) |
| `m7/m7_report_archive_18.json` | ① 행 순서 = **최신 달부터**(2026-08 → 2025-03) ② 2026-08 = 생성됨 + `route` · 미생성 2행 = 2026-07·2026-06 ③ 모의 3행(2025-05·04·03)은 `route` 없음 + `reason_label` ④ `section_label` 3곳(2026-08 · 2025-12 · 2025-05 행 — 묶음의 첫 행에만) |

### 신설 11건

위 «`m7/` 43» 절의 v1.3 목록. 상수는 `FixturePaths.m7M7…` 11개다.

### 🔴 성과 시리즈의 표시 필드는 **생성 스크립트**가 만든다 (손 계산 금지)

정규 자리와 글자를 손으로 고치지 않는다. 값을 바꿔야 하면 M2 가 생성 스크립트(`packages/domain_contracts/tool/gen_r10_fixtures.py`)를 고쳐 다시 돌린다. 스크립트는 분수로 계산하고 마지막에만 반올림한다. 규칙은 엔진(06 M1-17)이 지킬 규칙과 같다.

```
# 저장소 루트에서 — 몇 번을 돌려도 결과가 같다. 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다
PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r10_fixtures.py
```

- 개정 4건은 기준 커밋(계약 1.2.0 · `c4c8819`)의 원문에서 다시 만든다 — git 과 그 커밋이 있어야 한다.
- 기대 표(점 수 · 결측 순번 · 축 · 눈금 · 구간)는 화면에 찍는다. 파일로도 받으려면 `--table <경로>`(저장소 밖).

| 필드 | 규칙 |
|---|---|
| `x_normalized` | 순번 ÷ (점 수 − 1) · 소수 넷째 자리 반올림 · 첫 점 0.0 · 끝 점 1.0 · 점이 1개면 0.5 |
| 세로축 | 본선과 벤치마크의 값 전체 + 0 을 덮는다. 눈금 간격은 1·2·5 × 10ⁿ 가운데 «눈금 수(양 끝 포함)가 5 이하가 되는 가장 작은 간격» · 아래 끝 = 최솟값 이하인 첫 눈금 · 위 끝 = 최댓값 이상인 첫 눈금 |
| `y_normalized` | (값 − 아래 끝) ÷ (위 끝 − 아래 끝) · 소수 넷째 자리 · 결측이면 `null`(`value: null` 과 늘 함께). 벤치마크도 **같은 축** |
| `y_ticks` | 아래 → 위 · `{ normalized, label, is_baseline }` · 글자는 백분율(간격이 1% 이상이면 정수 `"5%"` · 그보다 작으면 소수 한 자리 `"0.5%"`) · 값이 0 인 눈금만 `is_baseline: true` · 음수는 빼기표 `−`(U+2212) |
| `value_text` | 백분율 소수 둘째 자리(`"11.94%"` · `"0.00%"` · `"−1.10%"`) · 결측 점 = `"산출 불가"` · 모의 구간의 점 = `"합산 제외"` |
| `date_text` | 일간 `"2026-08-31"` · 월간 `"2026년 8월"` · 연간 `"2026년"`(마지막 해가 12월 전이면 `"2026년(8월까지)"`) |
| 구간 `start_normalized`·`end_normalized` | «`from` ≤ 날짜 ≤ `to` 인 점»의 첫·끝 자리에서 반 칸(0.5 ÷ (점 수 − 1))씩 넓히고 0.0~1.0 으로 자른다. 모든 구간(측정 구간 포함)에 싣는다 · 구간끼리 겹치지 않는다 |
| `m7_perf_monthly_sim_split` 의 값 | `performance_24m` 행 0 에서 계산 — 다시 누적 = (1 + 누적(t)) ÷ (1 + 누적(2025-06-30)) − 1 |
| `m7_perf_monthly_period` 의 값 | 같은 행(과 그 벤치마크)에서 계산 — 월별 = (1 + 누적(t)) ÷ (1 + 누적(t−1)) − 1 · 첫 점 0.0 · 앞 달이 결측이면 그 달도 결측 |

### 표기 — 키를 빼는 것과 `null` 로 적는 것

- 점의 `y_normalized` 는 결측일 때 **`null` 로 적는다**(`"value": null` 과 같은 모양 — 빈 자리도 값이다).
- `unavailable_label` 은 차트를 그릴 수 있는 시리즈에는 **키가 없다**. 있는 것은 `m7_perf_unavailable_gap`·`m7_perf_masked_integrity` 둘뿐이다.
- 게이트의 `friction_line`·`route`, 아카이브 행의 `reason_label`·`route`·`section_label` 도 없을 때는 **키가 없다**.

---

## 계약 v1.4 (2026-09-30 · R11 선행 M2 보강 · 01 §14)

화면 카드 `R11a-Bob-S74`(`S7-4` 플래너 · 폰 전용)·`R11b-Bob-S79`(`S7-9` 목표 경로 + `S7-1` 진입 버튼)를 보내기 전에 한 보강이다.
🔴 `S7-5`(인출)는 인출 규칙 결정 뒤 첫 minor 다 — 인출 3벌은 새 필수 키만 기계적으로 더했다.

### 개정 16건 (파일 이름·`FixturePaths` 상수 그대로)

| 파일 | 무엇이 바뀌었나 |
|---|---|
| `m7/m7_deposit_plan_default`·`_limit`·`_expired` | 행이 `DepositPlan` → **`DepositPreviewResult` 래퍼**(`{ "plan": { … } }`)로 바뀌었다(등록부 재바인딩). 새 표시 필드(`as_of`·`deposit_amount_text`·`pension_limit`·`residual_krw_cash_text`·`order_drafts_title`·`orders_empty_text`·`warning_lines`·`register_blocked_text` · 초안 `side_label`·`quantity_text`·`limit_price_text`·`pending_note_text` · 충당 `routing_reason_text`). 종목 라벨 SPEC 정합(`133690` TIGER 미국나스닥100·`411060` ACE KRX금현물 = B · `0085P0` ACE 미국10년국채액티브 = C · `379810` 제거) · 슬리브별 매수 초안 합 ≤ 충당액 · `preview_notice` = «미리보기입니다…» 고지 **전용** |
| ↳ `_limit` | 🔴 **B 행 없음**(0원 행도 없음 · SPEC v2.23 — B 는 연금 계좌에만) · A·C 를 일반 계좌로 · `order_drafts: []` + `orders_empty_text` · `pension_limit`(`suggestion_text`·`funding_note_text` 있음) · `warning_lines` 1. 🔵 **1,800만 합산 납입한도 소진의 형태 표본**이다 — 이 앱이 실제로 설 조건(시작 2,000만 + 월 납입 운영값)에서는 한도 구속이 0/25년이다(03 §9 금지 ⑤) |
| ↳ `_expired` | 만료 = `register_blocked_text`(등록 부재) · 봉투와 행의 기준일 = 계획 기준일 2026-08-28 · 옛 봉투 신호(`empty_kind: NOT_APPLICABLE` + `empty_label`)는 행 필드로 옮기고 봉투는 `NO_DATA`/`null` |
| `deposit_plan_1`·`deposit_plan_funding_1` | 행 = `DepositPlan` 그대로(**코어 전용** · 화면 미사용). 새 필수 키 · 종목 라벨 · `funding_1` 은 0원 조달 단계 삭제 · C 방어 자산 **매도** 초안(`PENSION_FUNDING` 칩 · 지정가 없음 · `pending_note_text`) · 충당 합 + 잔여 = 입금액 · 봉투·행 기준일 2026-09-30 로 정합 |
| `m7/m7_goal_path_on`·`_hold`·`_realworld` | `GoalPathVm` v1.4 — `planned`·`actual`(`PerfPoint` · 같은 길이·날짜·가로 자리 · 계획선 결측 없음) · `y_ticks` · `segments` · 역할 고정 문장(판정 근거 `basis_text` / 가정 카드 1줄 `backtest_basis_text` / 2줄 `starting_capital_assumption_text`) · `honest_expectation_text`·`_worst_text`(인용 문장) · `disclaimer_text`. `_hold` = `chart_unavailable_label` + 네 목록 빈 목록 · 봉투 **`lag_notice` 삭제**(문장은 `m7_goal_path_off` 의 `deviation_text` 로 올렸다). `_realworld` = 실전 조건 문장(금액 없이) + 갭 1(`UNAVAILABLE` 띠 · 실제선 결측 2점) |
| `m7/m7_monthly_2026_08`·`_gap` | `goal_deep_link` = `aaq://report/goal/2026-08`(그 행의 `yyyy_mm`) 한 줄 |
| `m7/m7_monthly_masked_integrity`·`_masked_recon`·`_pending` | `goal_deep_link` **키 없음**(가림·미생성 달 = 버튼 부재) — 버전 줄만 바뀌었다 |
| `m7/m7_withdrawal_*` 3벌 | 초안 행에 `side_label`·`quantity_text` 두 줄만(기계적 · 내용은 인출 규칙 결정 뒤 첫 minor 에서 다시 만든다) — 🔴 그래서 `limit_price` 는 있는데 `limit_price_text` 가 없는 행이 있다(C-38 ② 짝은 `DepositPlan` 한정 · 01 §14-4) |

⚠️ **종목 라벨 SPEC 정합은 입금 픽스처(`m7_deposit_plan_*`·`deposit_plan_*`) 한정이다.** `holdings_6`·`journal_30`·`m6/*`(18벌)·
`m7/m7_withdrawal_*` 3벌·`m9/handover_states` 는 옛 라벨 그대로다 — 같은 티커가 두 뜻이다(`411060` = 입금 «ACE KRX금현물»(B) /
나머지 «ACE 미국30년국채» · `0085P0` = 입금 «ACE 미국10년국채액티브» / 나머지 «KODEX 국고채30년» · `379810` 은 입금 밖에 남아 있다).
R11a 골든(`s74_*`)과 M6 골든이 같은 티커를 다른 종목명으로 찍는 것은 이 때문이다. 정정은 별도 창(인출은 인출 규칙 결정 뒤 첫 minor · 나머지는 01 §8 미결 82).

### 신설 7건

위 «`m7/` 48» · «`m9/` 3» 절의 v1.4 목록. 상수는 `FixturePaths.m7M7DepositPlanBlocked`·`…InputRejected`·`…Funding`·
`m7M7DepositRegisterReceipts4`·`m7M7GoalPathOff`·`m9ContributionSettingDefault`·`m9ContributionSettingNoLimitNote` 7개다.

### 🆕 정정 1건 (2026-10-06 · 01 §8 미결 77 · §15-1 · 계약 1.4.0 유지)

| 파일 | 무엇이 바뀌었나 |
|---|---|
| `m7/aftertax_ladder_1.json` | 본문 `SPEC_POT_TAX_FREE` 5층(한 칸 밀림 · `WD_16P5` 없음) → **6층**(골든 `aftertax_full_S7.spec_pot_taxfree` 그대로 · `cagr_pct`·`end_mult` 4자리 · «정직 기대» 층은 두 필드 없음) · 반사실 `CF_POT_TAXABLE_FLAT` 2층 → **`CF_POT_TAXABLE_COMP38` 6층**(02_전략 ㉒ 의 «최악») · 인출 층 `note_line` 에 환급(명목·재투자) 문장 · `meta` 불변(선례) |

🔴 **골든 사본** `test/contracts/support/golden/aftertax_full_S7.json` 이 함께 들어왔다 — 설계 저장소 `09_백테스트/백테스트6/runs/N2_golden/golden_p0s.json` 의 같은 이름 블록을 글자 그대로 복사한 데이터 파일이고, C-30 ⓙ 가 픽스처의 대조 값을 이 사본과 맞댄다. 정본이 바뀌면 사본을 다시 복사한다(01 §15-1). 픽스처·골든 밖(코드·라벨·주석)에 4자리 수치를 옮기지 않는 규칙은 그대로다.

### 🔴 픽스처 계좌 별칭 표 (정본 · 설계 D9 ⑧)

| 축 | 별칭 |
|---|---|
| 연금 계좌 | `연금저축` · `IRP` |
| 과세 계좌 | `일반` |

- 슬리브 B 의 충당·초안은 **연금 계좌**에만 선다(SPEC v2.23). 계획 픽스처의 `account_alias` 는 이 표 안에서만 고른다(표 밖 = 실패 · C-38 ⑦).
- 같은 집합을 `test/contracts/support/fixture_accounts.dart`(`kFixturePensionAccountAliases`·`kFixtureAccountAliases`)가 코드로 싣는다 — 🔴 **두 곳은 같은 커밋에서 바꾼다**.
- 🔵 `sleeve_catalog_4.json` 은 계좌 축이 없어(sleeve·label·order 뿐) 정본이 될 수 없다.

### 🔴 개정·신설은 **생성 스크립트**가 만든다 (손 계산 금지)

```
# 저장소 루트에서 — 몇 번을 돌려도 결과가 같다. 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다
PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r11_fixtures.py
```

- 개정 16건은 기준 커밋(계약 1.3.0 · `5207195`)의 원문에서 다시 만든다 — git 과 그 커밋이 있어야 한다.
- 스크립트가 규약을 먼저 확인하고 어기면 멈춘다: 폐기 운영값 0 · Σ 충당 + 잔여 == 입금액(예시값 `100000`) · 슬리브별 매수 초안 합 ≤ 충당액 · 슬리브 B = 연금 계좌 · `preview_notice` 는 «미리보기입니다»로 시작 · 목표 경로의 «날짜로 덮는 점» == «자리로 덮는 점» · 값 크기 순서 == 세로 자리 순서 · `value_text` 에 `%` 없음 · `최악의 해` 없음 · `_realworld` 에 `1억` 없음.

| 목표 경로 필드 | 규칙 |
|---|---|
| `x_normalized` | 순번 ÷ (점 수 − 1) · 소수 넷째 자리 반올림(성과 시리즈와 같다 — 아래 «계약 v1.3» 표) |
| 세로축 | 계획선과 실제선의 값 전체를 덮는다 · 🔴 **금액 축이라 0 을 넣지 않는다**(기준선 없음 · `is_baseline` 전부 false) · 눈금 간격 = {1,2,5}×10ⁿ 만원 가운데 «눈금 수(양 끝 포함) ≤ 5»가 되는 가장 작은 간격 |
| `y_normalized` | (값 − 아래 끝) ÷ (위 끝 − 아래 끝) · 결측이면 `null`(`value: null`·`gap_reason_code` 와 함께) · 계획선은 결측 없음 |
| `value_text` · 눈금 `label` | 금액 글자(`"2,560만원"`) · 🔴 `%`(달성률) 금지 · 결측 점 = `"산출 불가"` |
| `value` | 원 단위 금액(double) — 골든 대조 전용 · `ui_*` 참조 금지(C-36 ⑦ 준용) |
| `segments` | 갭 띠만(`UNAVAILABLE`) — 덮는 점의 앞뒤 반 칸까지 · 유지·이탈 표본은 빈 목록 |

### 표기 — 래퍼·빈 키

- `DepositPreviewResult` 래퍼는 `plan`·`input_rejected_text`·`blocked_text` 가운데 **있는 키 하나만** 싣는다(나머지는 키 없음 · C-38 ①). `blocked_action` 은 `blocked_text` 가 있는 행에만 온다.
- `DepositPlan` 의 선택 표시 필드(`pension_limit`·`residual_krw_cash_text`·`orders_empty_text`·`register_blocked_text` · 초안 `limit_price`·`limit_price_text`·`pending_note_text` · 충당 `routing_reason_text` · 한도 카드 `suggestion_text`·`funding_note_text`)는 없을 때 **키가 없다**. `warning_lines` 는 비어도 `[]` 로 싣는다. `funding_steps` 는 조달이 없으면 `null` 로 적는다(v1.3 까지와 같다).

---

## 계약 v1.5 (2026-10-07 · R12 선행 M2 보강 · 01 §15-3)

화면 카드 `R12-Bob-S76`(`S7-6a` 회차 타임라인 · `S7-6b` 회차 상세 등)을 보내기 전에 한 보강이다 — 01 §8 미결 49(회차→일지 링크 경로 · `J-1` 회차 칩).
🔴 `S7-5`(인출)는 이 번호를 쓰지 않는다 — 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor(번호는 그때 · 발주자 결정 ① 2026-10-07).

### 개정 2건 (파일 이름·`FixturePaths` 상수 그대로)

| 파일 | 무엇이 바뀌었나 |
|---|---|
| `rebalance_6.json` | 행 필드 두 개만 **더했다**(봉투 최상위 키 0 · 링크 키 추가 0) — ① 6행 전부 `detail_deep_link` = `aaq://rebalance/event/<그 행 event_id>`(`S7-6a` 행 탭 → `S7-6b`) ② 봉투 `as_of`(2026-08-31) 이전 5행에 `journal_timeline_link` = `{ "label", "deep_link": "aaq://journal/rebalance/<그 행 event_id>" }`(`S7-6b` 하단 버튼 → `J-1` 회차 조건). 🔴 `re_20261030_01`(as_of 뒤 회차 · 묶인 일지 행 0)은 버튼 **키 없음** = 버튼 부재 표본(C-40 ⑤ · 골든 `s76b_seasonal` 의 입력) · 버튼 글자 «이 회차의 주문 N건» 의 N 은 `re_20260803_01` 만 3(`journal_30` 에서 센 값 · C-40 ③)이고 나머지 4행의 2 는 일지 표본 밖 회차의 합성값이다 |
| `m7/m7_rebalance_detail_band.json` | 같은 두 필드(`re_20260601_01` · 버튼 «이 회차의 주문 2건») — 골든 `s76b_band`(버튼 있음)의 입력 · `RebalanceRepository.watchEvent` 가짜의 1행 입력 |

### 신설 4건

| 파일 | 행 타입(등록부 코덱) | 내용 · 쓰는 곳 |
|---|---|---|
| `m6/journal_rebalance_scope_1.json` | `JournalRebalanceScope` 1행(🆕 코덱) | `re_20260803_01` · `label` «2026-08-03 월 납입 배분 회차»(식별자 없음) · `range` 2026-08-03 ~ 2026-08-17(`preset_code` null · `is_default` false = 프리셋이 아니다) — `J-1` 회차 칩 글자 + 씨앗 기간 · `JournalRepository.watchRebalanceScope` 가짜의 입력 · C-40 ③④⑨⑩ |
| `m6/journal_rebalance_unknown.json` | `TradeJournalEntry` 0행 | `NO_DATA` + `empty_label` «이 회차에 묶인 기록이 없습니다» — 모르는 회차(scope null)로 연 `J-1` 의 봉투 · 🔴 `journal_empty` 의 문장과 다르다(C-40 ⑦ — 화면이 일반 빈 문구로 때우면 골든이 가른다) |
| `m7/m7_rebalance_detail_advisory.json` | `RebalanceEvent` 1행 | band 의 **거울**(같은 `event_id` · 행 필드 전부 같다) · 버튼 글자만 «이 회차의 기록 2건» — 03 §11-d 치환 표본 · 골든 `s76b_advisory` 의 입력 · C-40 ⑥ |
| `m7/m7_rebalance_empty.json` | `RebalanceEvent` 0행 | `NO_DATA` + `empty_label` «아직 리밸런싱 회차가 없습니다» — `RebalanceRepository.watchEvents` 봉투(🆕 v1.5 `ListResult`)의 빈 상태 · 골든 `s76a_empty` 의 입력 · C-40 ⑦ |

상수는 `FixturePaths.m6JournalRebalanceScope1`·`m6JournalRebalanceUnknown`·`m7M7RebalanceDetailAdvisory`·`m7M7RebalanceEmpty` 4개다 · 등록부 바인딩 4(새 코덱은 `JournalRebalanceScope` 하나 · 나머지는 `TradeJournalEntry`·`RebalanceEvent` 코덱 재사용).
신설 4건의 `meta.generated_at`·`seed` 는 생성일(2026-10-07) 값이다 — 그래서 advisory 와 band 는 `meta` 와 버튼 글자만 다르다.

### 🔴 N 과 짝 정합 — 사실만 적는다 (01 §8 미결 84)

- **N = 그 회차에 묶인 일지 행 전체 수**(정정 행 포함 · 기간 무관 · 발주자 결정 ④ 2026-10-07). 정수는 엔진 문장 안에 있고, 계약 테스트는 숫자를 코드에 적지 않고 두 픽스처를 맞댄다(C-40 ③ — `re_20260803_01` 버튼의 3 == `journal_30` 에서 그 회차에 묶인 행 수: je_0001 08-03 · je_0025 08-06 · je_0011 08-17).
- `journal_30` 과 `rebalance_6` 은 **의도 수준에서 짝이 아니다** — 그 3행의 의도(`i_0001`·`i_0025`·`i_0011`)는 `rebalance_6` 의 `order_intent_ids`(`i_re_20260803_01_1`·`_2`)에 없다. 버튼의 3 과 `order_intent_ids` 의 2 가 다른 것은 분할 체결이 아니라 합성 데이터가 짝이 아니기 때문이다. 🔴 화면은 `orderIntentIds.length` 로 N 을 세지 않는다.
- `journal_30` 은 **시간 역순이 아니다** — 오름차순 덩어리 둘(je_0001~je_0021 = 08-03→08-31 · je_0022~je_0030 = 08-03→08-13). LIVE 봉투(`meta.mode` LIVE)에 `SIM_INTERNAL` 행 1(je_0030)이 섞여 있다. `rebalance_6` 의 `re_20261030_01` 은 봉투 `as_of`(2026-08-31) 뒤 날짜다.
- 이 창은 위 사실을 **고치지 않는다**(`journal_30` 은 골든 다수의 입력) — 교차 정합은 01 §8 미결 84.

### 🔵 advisory 표본의 표지 = 라벨 글자뿐

뷰모델에 모드를 싣지 않으므로 `m7_rebalance_detail_advisory` 가 X7 advisory 세계의 흉내임을 말하는 것은 **버튼 글자뿐**이다 — `meta.mode`(LIVE)·`quality` 까지 band 와 같다(C-40 ⑥ 이 «글자 밖 필드 동일»을 본다). 03 §11-d «데이터가 말한다»의 데이터가 이 글자다.
같은 회차 id 가 픽스처(세계)마다 다른 글자를 갖는다 — C-40 ③ 의 짝 정합은 LIVE 세계(`rebalance_6`·`journal_30`·scope)만 묶는다.
advisory 회차에서 나온 수기 체결도 그 회차에 묶인다는 것이 전제다(발주자 결정 ④-2 · 엔진 숙제 06 X7-1 · 01 §8 미결 86).

### 표기 — 키를 빼는 것

- `journal_timeline_link` 는 버튼이 없을 때 **키가 없다**(`null` 로 적지 않는다). `detail_deep_link` 는 `RebalanceEvent` 를 싣는 픽스처의 전 행에 있다(C-40 ①).
- 두 0행 봉투는 `NO_DATA` + `empty_label`(엔진 문장)이다 — 「없음」은 문장을 실어야 한다(계약 3조 ③ · `journal_empty` 선례).

### 🔴 개정·신설은 **생성 스크립트**가 만든다 (손 계산 금지)

```
# 저장소 루트에서 — 몇 번을 돌려도 결과가 같다. 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다
PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r12_fixtures.py
```

- 봉투 한 줄 치환(122건)과 개정 2건은 기준 커밋(계약 1.4.0 · `dbbd3ae`)의 원문에서 다시 만든다 — git 과 그 커밋이 있어야 한다.
- scope 회차의 N 과 씨앗 기간은 기준 `journal_30` 에서 계산한다(그 회차에 묶인 행 수 · 그 행들의 가장 이른~늦은 날짜) · 링크는 그 행 `event_id` 로 채운다.
- 스크립트가 규약을 먼저 확인하고 어기면 쓰기 전에 멈춘다: 버전 줄 정확히 1 · 폐기 운영값 0(`meta` 블록 밖) · 신설 4건의 금액 꼴 0(`meta` 블록 밖) · scope 글자에 회차 id 없음 · 모르는 회차 문장 ≠ `journal_empty` 문장 · 쓴 파일 수 == 126 == 디스크.
- 🆕 v1.6 — 이 스크립트는 **v1.5 재현용으로 그대로 둔다**(v1.6 은 아래 `gen_r12_v16_fixtures.py`).

---

## 계약 v1.6 (2026-10-08 · R12 선행 · 01 §15-4)

화면 카드 R12(`S7-6a`·`S7-6b` 회차 타임라인·상세 · `S7-6c` 다음 리밸런싱·지금 기준 초안 · `S7-7` 12월 연간 리뷰 · `S7-10` 안내 이행 리포트)를 보내기 전에 한 보강이다 — R12 다섯 화면은 **엔진이 완성한 글자와 null 여부만 보고 그린다**.
상태 = ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`(브랜치 `m2/contract-v1.6-r12` · `2612684` 검사·받침대 선행 · `f922002` 계약 코드·버전·픽스처 · `edde72b` 검증 반영 + 이 문서 커밋).
카드 = 4장 · 권고 선반영(K3): `R12a-Bob-S76ab`(`S7-6a`+`S7-6b`) → `R12b-Bob-S76c` → `R12c-Bob-S77` → `R12d-Bob-S710` · 앞 카드 병합 뒤 다음 카드 · 전부 v1.6 PR 병합 뒤. `S7-8` 은 R12 밖(2026-10-07 결정).
🔴 이 창의 결정 K1~K26 은 **권고 선반영**이다(발주자 2026-10-07 «권고하는 대로» 위임 · 00_README §8-4 관행). 되돌림 비용이 높은 8건(K1·K5·K6·K8·K10·K11·K22·K24)은 **권고 선반영 · ~~확인 대기(🔴)~~** — ~~「푸시해」 전에 발주자가 확인한다. 아래 표본 가운데 그 결정에 걸린 것(달 라우트 링크 = K1 · 제안 줄 null = K6 · 이행 갭 래퍼 = K8 · 행 `as_of` 뜻 = K10 · `SleeveWeight.label` 문장 = K11 · `year_label` = K24)은 확인 결과에 따라 스크립트를 고쳐 다시 만든다.~~ ✅ 2026-10-13 발주자 확정(K1~K26 전부 권고대로 · 01 §15-4-16) — 표본 재생성 0.
🔴 `S7-5`(인출)는 이 번호도 쓰지 않는다 — 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor(v1.5 결정 ① 그대로).

### 신설 9건

| 파일(`FixturePaths` 상수) | 행 타입(등록부 코덱) · 행 수 | 내용 · 쓰는 곳 |
|---|---|---|
| `m7/m7_rebalance_preview_default.json`(`m7M7RebalancePreviewDefault`) | `RebalancePreviewResult` 1(🆕 코덱) · `{preview}` | `plan_id` `pv_re_20260901_01` · `planned_date_text` «2026년 9월 1일 회차» · 행 `as_of` = 봉투(«초안 기준 2026-08-31 종가») · `before` = B 밴드 상단 이탈(`m7_rebalance_detail_band` 와 같은 비중) · `after` = 초안 방향(B 매도 · A 매수 · 차액 현금 · C·POT 불변 · 전부 밴드 안) · `order_drafts_title` «주문 초안» · 초안 2행(133690 TIGER 미국나스닥100 · B · 매도 / 069500 KODEX 200 · A · 매수 — 둘 다 연금저축 · 지정가 글자 있음 · 칩 `REBALANCE_BAND`) · 비용 «약 128원»(추정치) · `warning_lines` `[]` · `orders_empty_text`·`funding_steps` **키 없음** — 골든 `s76c_preview` |
| `m7/m7_rebalance_preview_in_band.json`(`m7M7RebalancePreviewInBand`) | 〃 · 1 `{preview}` | 같은 머리 · `before` 전부 밴드 안 · `order_drafts` `[]` + `orders_empty_text` «모든 슬리브가 밴드 안이라 이번 회차에 낼 초안이 없습니다.» · 비용 «예상 비용 없음» · `warning_lines` 1 — 골든 `s76c_draft_empty` |
| `m7/m7_rebalance_preview_blocked.json`(`m7M7RebalancePreviewBlocked`) | 〃 · **2** | 🔴 **행 순서가 뜻**이다: 0 `blocked_text` 만(버튼 부재 · **골든 입력** — 안전 입력 `safety_states` 행 4 LEDGER_INTEGRITY 와 짝) · 1 `blocked_text` + `blocked_action` → `aaq://x2/resume-report`(버튼 표본 · **위젯 테스트 전용** — RESUME_INCOMPLETE 안전 표본이 없어 골든으로 찍지 않는다 · 01 §8 미결 87) · `m7_deposit_plan_blocked` 의 거울 — 골든 `s76c_blocked`(행 0) |
| `m7/m7_next_rebalance_none.json`(`m7M7NextRebalanceNone`) | `NextRebalanceVm` 1 | `empty_label` «예정된 리밸런싱 회차가 아직 없습니다.» · 날짜·D-day·종류·예고 링크·고지 **키 없음** · 행 `as_of` = 봉투(«리밸런싱 예정 기준 2026-08-31») — 골든 `s76c_none` |
| `m7/m7_rebalance_sim.json`(`m7M7RebalanceSim`) | `RebalanceEvent` 2 | 내림차순 `re_sim_20260803_01`·`re_sim_20260701_01` · 월간 정기 · 봉투 `meta.mode` **LIVE**(C-15 «봉투 전량 LIVE» · SIM 은 행 `mode` `SIM_INTERNAL` 로만 — `journal_30` 선례) · `mode_label` «모의»(두 행) · `section_label` «모의투자 회차»(**행 0 만**) · `detail_deep_link` 있음 · `journal_timeline_link` 키 없음(01 §8 미결 89) · `thresholds` `[]` — 골든 `s76a_sim` |
| `m7/m7_annual_offwindow.json`(`m7M7AnnualOffwindow`) | `AnnualReviewVm` 1 | `year` **2025**(기본 연도 표본 — 2026-08-31 은 12월이 아니므로 마지막 완결 연도 · K24) · `year_label` «2025년 연간 리뷰» · `window_state_code` `CLOSED` · 섹션 4개 = `m7_annual_2026` 과 같은 구성(같은 route 규칙) · 세후 2블록 = 사다리 사본 — 골든 `s77_offwindow` |
| `m7/execution_gap_empty.json`(`m7ExecutionGapEmpty`) | `ExecutionGapResult` 1(🆕 코덱) | `{empty_kind: NO_DATA, empty_label, as_of}` — 안내 0건 · 골든 `s710_empty` |
| `m7/execution_gap_not_applicable.json`(`m7ExecutionGapNotApplicable`) | 〃 · 1 | `{empty_kind: NOT_APPLICABLE, empty_label, as_of}` — 자동 매매 구간 · 골든 `s710_not_applicable` |
| `m7/execution_gap_masked_recon.json`(`m7ExecutionGapMaskedRecon`) | 〃 · 1 `{report, as_of}` | RECON_MISMATCH 가림 — `count_lines`·`correction_lines`·이행률·중앙값·가격 갭·정정 체인 글자 = «?» · `compliance_rate_normalized` **키 없음**(null = 게이지 부재) · 칩 `[]` · `mode_advice_line` 키 없음 · `trust` = `ledger_trust_4` 의 DRIFTING 행 사본 · `period_label` «2026년 8월» — 골든 `s710_masked_recon`(안전 입력 `safety_states` 행 3) |

상수는 `FixturePaths.m7M7RebalancePreviewDefault`·`…InBand`·`…Blocked`·`m7M7NextRebalanceNone`·`m7M7RebalanceSim`·`m7M7AnnualOffwindow`·`m7ExecutionGapEmpty`·`m7ExecutionGapNotApplicable`·`m7ExecutionGapMaskedRecon` 9개다 · 등록부 코덱 +2(`RebalancePreviewResult`·`ExecutionGapResult` · `NextRebalanceVm` 코덱은 countdown 과 공유) · 바인딩 +9 · 재바인딩 4(이행 갭 4벌 → `ExecutionGapResult`).
신설 9건의 `meta.generated_at`·`seed` 는 생성일(2026-10-08) 값이다.

### 개정 14건 (개명 1 포함)

| 파일 | 무엇이 바뀌었나 |
|---|---|
| `rebalance_6.json` | ① 행 순서 = **거래일 내림차순**(03 §11-a «시간 역순» — C-40 은 id 로 고르고 위치에 기대지 않는다) ② 행 `as_of` = 봉투 `as_of`(관측 시각 · 라벨 «자료 기준 2026-08-31» — 봉투 라벨도 같이 · K10) ③ `SleeveWeight.label` 완성 문장(아래 규칙) ④ `thresholds` — band `re_20260601_01` 1행(`band_breach_width` · «B 목표 대비 이탈폭» · «5.8%p» · «5.0%p 초과» · 발동) · seasonal `re_20261030_01` 1행(`trend_score_kr` · 진입 게이트 통과) · 나머지 4행 `[]` + `threshold_registered` 키 삭제 ⑤ `mode_label`·`section_label` 키 없음(LIVE) ⑥ 링크·`order_intent_ids` 무변경(C-40 불변) |
| `m7/m7_rebalance_detail_band.json` | 봉투·행 `as_of` → 관측 시각(«자료 기준 2026-08-31») · 라벨 규칙 · `trigger.summary` 오기 정정(«슬리브 B 가 목표에서 5.8%p 벗어나 밴드 상단(47.0%)을 넘어 …» — 5.8%p 는 **목표 대비 이탈폭**, 밴드 상단 초과는 0.8%p) · 대조 행 · 🔴 `rebalance_6` 의 같은 id 행과 **JSON 동일**(C-41 ⑤) — 골든 `s76b_band` |
| `m7/m7_rebalance_detail_advisory.json` | band 의 거울 — `journal_timeline_link.label` «이 회차의 기록 2건» 밖 JSON 동일(C-40 ⑥) — 골든 `s76b_advisory` |
| `m7/m7_next_rebalance_d6.json` → **`m7/m7_next_rebalance_countdown.json`**(개명 · `FixturePaths.m7M7NextRebalanceD6` → `m7M7NextRebalanceCountdown`) | 행 `as_of` = 봉투 · `expected_date_text` «2026년 9월 1일» 유지 · `d_day_text` «D-6» → «**D-1**»(월간 정기 = 매월 첫 거래일 = 2026-09-01 · 2026-08-31 기준 달력일·거래일 모두 1일 — D-day 기준(K23)과 무관하게 맞는다) · `notice_text` → «예정일은 거래일 달력으로 정해집니다.»(개발자 메모 제거) · `preview_route` 유지 — `S7-6c` 골든 4이름(`s76c_countdown`·`_preview`·`_draft_empty`·`_blocked`)의 카운트다운 입력 |
| `m7/m7_annual_2026.json` | `year_label` «2026년 연간 리뷰» · `after_tax` = `aftertax_ladder_1` 행 0 사본 · `after_tax_counterfactual` = 봉투 `counterfactual` 사본(스크립트가 복사 · 원천 하나) · `B_AFTERTAX`·`C_EXECUTION` 의 `route` **키 삭제**(갈 곳 없는 버튼 · S7-7 → S7-10 제3 진입을 만들지 않는다 — ㉟ 권고 선반영 · K16) · `B_AFTERTAX` 둘째 줄 → «월간 리포트에는 세후를 싣지 않습니다.» · 섹션 4개·`window_state_code`·`as_of` 무변경(01 §8 미결 94) — 골든 `s77_december`·`s77_aftertax_ladder_spec`·`s77_aftertax_ladder_cf` |
| `m7/m7_annual_first_year.json` | `year_label` «2026년 연간 리뷰»(첫 해 = 그해) · 세후 사본 2블록 · 같은 route 규칙 · `FIRST_YEAR` 유지(축 분리 = 미결 94) — 골든 `s77_first_year` |
| `m7/aftertax_ladder_1.json` | 행 0·`counterfactual` 에 `reference_only_label` «골든 참고치입니다. 실계좌로 산출한 값이 아닙니다.» · `basis_note` 의 개발자 메모 제거(본문 «세율 가정과 계좌 배치는 엔진 설정에서 옵니다.» · 반사실 «계좌 배치가 갈래를 정합니다.») · 층 값·`note_line`·형제 키 `counterfactual`·`counterfactual_collapsed` 의 대조 값 무변경(C-30 ⓖ~ⓚ 불변) |
| `m7/execution_gap_1`·`_cant`·`_wont`·`_mixed`(4) | 행 = **`ExecutionGapResult` 래퍼** `{report: {…}, as_of}`(`as_of` = report 의 `as_of` · 등록부 재바인딩) · `count_lines` 3줄·`correction_lines`(둘 다 0 이면 `[]`)를 int 에서 생성 · `compliance_rate_label` 에 금액 가중 값(합성 · 스크립트 고정) · `price_gap_label` «권장가 대비 …» → «안내 대비 중앙값 +nbp(불리)»(권유로 읽히는 낱말 제거) · `mode_advice_line`: cant 유지 · wont → ⓑ 문장(이관을 제안하지 않고 사후 blind 리뷰·연간 반증 조건 점검을 **문장 안에서** 가리킨다) · mixed·`_1` → **키 삭제**(null = 줄 부재 · ⓒ·정상 달 · K6) · `trust`·칩 무변경 — 골든 `s710_cant`·`_wont`·`_mixed`(`_1` = 위젯 테스트 입력) |
| `m7/m7_monthly_2026_08`·`_gap`·`_masked_recon`(3) | ⑧ `D3_EXECUTION.detail_deep_link` `aaq://ledger/execution-gap` → `aaq://ledger/execution-gap/2026-08`(그 리포트 달 · `AppRoutes.ledgerExecutionGapMonth` · K1) · `S7-1` 은 링크 글자를 그리지 않으므로 PNG 변화 0 |

🔵 `m7_monthly_masked_integrity`·`_pending` 은 ⑧ 링크가 원래 없어 버전 줄만 바뀌었다. 나머지 112건(`m7_rebalance_empty`·`m7_withdrawal_*`·`ledger_trust_4`·`safety_states` 등)은 `"contract_version"` 한 줄만.

### 🔴 개정·신설은 **생성 스크립트**가 만든다 (손 계산 금지)

```
# 저장소 루트에서 — 몇 번을 돌려도 결과가 같다. 돌린 뒤 `git status` 에 fixtures 변경이 없어야 한다
PYTHONDONTWRITEBYTECODE=1 python packages/domain_contracts/tool/gen_r12_v16_fixtures.py
```

- 버전 줄 치환(112건)·개정 14건·개명은 기준 커밋(계약 1.5.0 · `542d13c`)의 원문에서 다시 만든다 — git 과 그 커밋이 있어야 한다. 개명은 옛 이름 파일을 지운다.
- 스크립트가 규약을 먼저 확인하고 어기면 쓰기 전에 멈춘다: 버전 줄 정확히 1 · 봉투 `meta.mode` LIVE · 폐기 운영값 0(`meta` 블록 밖) · 봉투 최상위 키 = 기준과 같음(신설은 필수 6키뿐) · 새 파일 이름에 숫자 0 · 행이 있으면 `NO_DATA`/`null` · 금지어(추천·권유·자문·시그널) 0 · 사용자 문장 자리의 개발자 메모 0 · `preview_notice` «미리보기입니다» 시작 · 계좌 별칭 ∈ 별칭 표(슬리브 B = 연금 계좌) · 금액 = decimal 정규형 · 지정가 짝 · 래퍼에는 있는 키만 · `SleeveWeight` `basis` = `ACCOUNTING` 과 라벨 규칙 · 미리보기 2벌 밖 신설의 금액 꼴 0 · `rebalance_6` 내림차순·band 행 동일·행 `as_of` = 봉투 · 연간 3벌 세후 = 사다리 사본 · `year` ⊂ `year_label` · 미리보기 밴드 표본 정합(초안 표본 `before` 에 밴드 밖 ≥ 1 · 빈 초안 표본 `before` 전부 안 · 두 벌 `after` 전부 안) · 쓴 파일 수 == 135 == 디스크.
- 실행하면 한 줄로 수를 찍는다 — 파일 135 · 버전 줄만 112 · 개정 14(개명 1 포함) · 신설 9 · `SleeveWeight` 라벨 120(커밋 `f922002`·`edde72b` 본문의 실측 · 두 번 돌려 diff 0).

### 🔴 `SleeveWeight.label` 생성 규칙 (K11 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13))

- 밴드 안 = «{슬리브} {현재%} (목표 {목표%}, 편차 {±n.n%p}, 밴드 여유 {n.n%p})» · 밴드 밖 = 여유 자리에 «밴드 {상단|하단} {n.n%p} 초과» — 예 «B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 0.8%p 초과)». 밴드 여유 = 가까운 밴드 끝까지의 거리(스크립트 계산). 음수 편차의 빼기표는 `−`(U+2212).
- 정본 = 코드 `dto/rebalance.dart` 의 `SleeveWeight` 머리 «목표 대비 편차·밴드 여유» + 기존 예시(«B 42.0% (목표 42.0%, 밴드 여유 1.8%p)»)의 요소 — 🔴 그 예시 주석은 **바꾸지 않았다**(홈 블록 4 가 같은 타입이다 · 그 문장을 홈이 통째로 쓸지는 R13 재검토).
- 대상 = `SleeveWeight` 를 싣는 R12 픽스처 전부(`rebalance_6` · detail_band · detail_advisory · sim · preview default·in_band 의 `before`/`after` = 120개) · `basis` 전부 `ACCOUNTING`(C-31 ⓐ 확장).

### 🔵 표본 사실 — 고치지 않고 적어 둔다

- **as_of 뒤 회차** — `rebalance_6` 의 `re_20261030_01` 은 봉투 `as_of`(2026-08-31) 뒤 날짜인 채 남았다(내림차순이라 이제 첫 행이다 · 01 §8 미결 84).
- **S7-1 ⑧ 과 S7-10 의 가림 범위가 다르다** — 같은 2026-08 · 같은 RECON_MISMATCH 에서 `m7_monthly_masked_recon` ⑧ 은 «이행률 88%»를 보이고 `execution_gap_masked_recon` 은 «?»로 가린다. 03 §14-b «수치 ? 가림»이 `S7-10` 정본이다 · `S7-1` 을 맞출지는 01 §8 미결 96.
- **가림 표본의 원값** — `execution_gap_masked_recon` 은 글자가 «?»인데 int 9종은 `execution_gap_1` 의 실값을 그대로 싣는다(화면 미참조 · M6 가림 선례 `journal_masked_integrity` 도 «숨김» + 원값을 싣는다). 원값 운반 여부 = 미결 96.
- **D-day 교차 불일치** — `S7-6c` 표본은 «2026년 9월 1일 · D-1» 인데 m8 `ops_home_*` 5벌(`normal`·`advice_open`·`advice_zero`·`blocked`·`resume_gap7`)·`ops_rhythm_rows` 는 «매월 첫 거래일 · D-6» 을 싣는다(`next_rebalance_d_day_text` · upcoming `MONTHLY_REBALANCE`·`MONTHLY_CONTRIBUTION` 행 · m8 쪽 모순 · 미결 84 · R13 전).
- **사유 칩 `REBALANCE_BAND`** — `ContractCodes` 에 등재되지 않은 코드지만 기존 9파일(`journal_30`·`m6/advice_12` 등)이 이미 같은 코드를 쓴다 · 재사용했다 · 화면은 칩 `label`·`tone` 만(`detail_deep_link` 는 읽지 않는다 · 미결 81).
- **참고치 표지 예외** — `m7_withdrawal_pension_penalty` 의 사다리는 `is_reference_only: true` 인데 `reference_only_label` 이 없다(인출 규칙 결정 뒤 재생성 · 미결 79) · C-41 ⑦ 의 고정 예외 목록 1벌.
- **`detail_band` 의 «밴드 상단을 5.8%p 넘어» 는 오기였다** — 정정했다(위 개정 표). 5.8%p 는 목표 42.0% 대비 이탈폭이고 등록 임계 0.05(5.0%p)와 맞대는 값이다.
- **날짜·건수·id·금액 가중 값은 합성 데이터**다(실계좌 아님).

### 표기 — 래퍼·빈 키

- `RebalancePreviewResult` 래퍼는 `preview`·`blocked_text` 가운데 **있는 키 하나만** 싣는다 · `blocked_action` 은 `blocked_text` 가 있는 행에만(C-41 ① · v1.4 `DepositPreviewResult` 와 같은 꼴).
- `ExecutionGapResult` 래퍼는 `report` 또는 `empty_kind`+`empty_label` 가운데 한쪽만 싣고 `as_of` 는 늘 싣는다(C-41 ⑧).
- 선택 표시 필드(`orders_empty_text`·`mode_label`·`section_label`·`reference_only_label`·`mode_advice_line`·`compliance_rate_normalized` · `m7_next_rebalance_none` 의 날짜·D-day·종류·예고·고지)는 없을 때 **키가 없다**(🔵 countdown 의 `"empty_label": null` 은 기준 원문 그대로 남은 것이다). `warning_lines`·`thresholds`·`correction_lines` 는 비어도 `[]` 로 싣는다. `funding_steps` 는 R12 미리보기 2벌에서 **키 없음**(R12 는 조달 절을 그리지 않는다 · 미결 92).

## 역직렬화 실측 (2026-09-08 · 233행 → 2026-09-23 · 94파일 267행 → 2026-09-25 v1.2 · 101파일 281행 → 2026-09-28 v1.3 · 112파일 295행 → 2026-09-30 v1.4 · 119파일 306행 + 봉투 형제 키 9 · 실패 0 → 2026-10-07 v1.5 · 126파일(매핑 123파일 308행) · C-1·C-8 통과 → 🆕 2026-10-08 v1.6 · 135파일(매핑 132파일 319행) · C-1·C-8 통과)

🔵 **집계 정의**(🆕 2026-09-25 검증 반영 — 판마다 세는 법이 적혀 있지 않아 267·268·270·280 이 섞였다): «파일» = 등록부(`c00_fixture_registry.dart`)가 행 타입을 매핑한 파일(매핑 없는 3건 `unmappedFixtures` 제외 · 0행 봉투 ~~3건~~ 5건 포함 — 🆕 v1.5 `m6/journal_rebalance_unknown`·`m7/m7_rebalance_empty`) · «행» = 그 파일들의 봉투 `rows` 원소 합. 원시 합(전 135파일 `rows`)은 🆕 v1.6 322 = 319 + 매핑 없는 3건 각 1행(v1.5 판은 126파일 311 = 308 + 3 · 🆕 v1.6 신규 9파일이 11행을 더했다 — 개정 14건은 행 수 불변 · v1.4 판은 122파일 309 = 306 + 3 · v1.2 판은 104파일 284 = 281 + 3 · v1.3 신규 11파일이 14행을 더했다 · v1.4 신규 7파일이 11행을 더했다 — 개정 16건은 행 수 불변 · 🆕 v1.5 신규 4파일이 2행을 더했다(0행 봉투 2 포함) — 개정 2건은 행 수 불변). 2026-09-23 판 267 도 같은 정의(원시 270 − 3)이며, v1.2 첫 판의 «280»은 1행 틀린 값이었다(정의대로 279 → 검증 반영 +2행 = 281).

135파일 전량이 봉투 검사를 통과하고(`m6/journal_empty.json`·`m6/journal_rebalance_unknown.json`·`m7/m7_rebalance_empty.json` 은 0행 봉투 · 🆕 v1.6 신설 9건은 전부 행이 있다), 그중 **132파일**(v1.1 실측 2026-09-17 93 + R2 준비 2026-09-23 +1 + v1.2 2026-09-25 +7 + v1.3 2026-09-28 +11 + v1.4 2026-09-30 +7 + v1.5 2026-10-07 +4 + 🆕 v1.6 2026-10-08 +9)이 실제 DTO 의 `fromJson` 을 지나
`fromJson(toJson(x)) == x`(**C-8**)를 만족한다. 🔴 열거값은 `@JsonValue` 로 못 박혀 있어 모르는
값이면 `fromJson` 이 **던진다** — 이 실측이 통과했다는 것은 픽스처의 열거값 전량이 영역 A 의 표기와
일치한다는 뜻이다(**C-15 의 절반**. 나머지 절반인 «`@JsonValue` ↔ DDL `CHECK`» 대조는 영역 E 몫이다).

### 🔴 DTO 로 열리지 **않는** 픽스처 2건 — 설계이지 결함이 아니다

| 파일 | 왜 DTO 가 없나 | 화면이 할 일 |
|---|---|---|
| `m6/self_report_1.json` | 행 모양은 `SelfReportBalance`(§5-4)이되 **`context` 가 없다**. `CommandContext` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이고(G-19) 화면 계층이 그것을 만드는 코드는 **C-28** 이 0건으로 검사한다 — 픽스처가 `context` 를 실으면 그 규약을 픽스처가 먼저 어긴다 | 폼 값으로만 읽고 `SelfReportBalance.fromJson` 을 **부르지 않는다**. 봉투 형제 키 `trust` 는 `LedgerTrustBadge` 로 연다 |
| `m6/entry_gate_nov_pass_1.json` | 계절 진입 게이트에 **이름 붙은 DTO 가 문서에 없다**(01 §3-7 은 상태 5·코드 3 만 정한다) | 🔴 타입을 지어내지 않는다. `SeasonalEntryGateState`·`ReasonChip`·`GateBadge`·`TriggerSnapshot` 은 있으니 그 부분만 연다 |

> 같은 이유로 `m6/fill_rejected_price.json` 의 형제 키 `preserved_input`(= `ManualFillRecord` 모양)도
> `context` 가 없다. 행 자체는 `CommandReceipt` 로 열린다.
> 🔴 **명령 인자 픽스처에 `context` 를 넣지 않는다**가 이 묶음의 규약이다.

### ⚠️ 골든(`*.golden.json`)을 만들 사람에게

`DateTime` 은 `toJson` 에서 `toIso8601String()` 을 타므로 픽스처의 `"…T09:00:00Z"` 가
**`"…T09:00:00.000Z"`** 로 되돌아온다. 값은 같고 C-8 도 통과하지만 **문자열 비교로 골든을 뜨면
어긋난다** — 🔴 골든은 픽스처 원문이 아니라 **`toJson` 출력**으로 뜬다. 같은 이유로 `toJson` 은
픽스처가 생략한 선택 키를 `null` 로 **명시해** 내보낸다(둘 다 계약 위반이 아니다).

## 링크 규약 (🆕 v1.1 · 01 §4-4)

픽스처의 링크 필드(`deep_link`·`detail_deep_link`·`action_deep_link`·`where_deep_link`·`clear_deep_link`·`route`·`preview_route`·`handoff_route`·`resume_route` · 🆕 v1.4 `goal_deep_link` — `blocked_action.deep_link` 는 `deep_link` 로 덮인다 · 🆕 v1.5 `journal_timeline_link`(`RebalanceEvent` 의 `LinkAction` — 안쪽 `deep_link` 로 C-33 이 검사한다 · 링크 키 추가 0) · `RebalanceEvent.detail_deep_link` 는 기존 `detail_deep_link` 키)에는 `aaq://…`(앱 화면)와 `handbook://…`(핸드북 앵커) **두 스킴만** 온다. `aaq://` 는 전부 `AppRoutes.all`(`lib/src/navigation/app_links.dart`)의 패턴과 일치해야 하며 **C-33** 이 전수 검사한다. 🔴 화면은 이 문자열을 만들지도 해석하지도 않는다 — `AppLinkOpener.open(link)` 에 그대로 넘긴다.

🆕 **v1.6(01 §15-4 · `AppRoutes.all` 43 → 45 · 링크 키 추가 0)** — 새 라우트 2:
- `AppRoutes.ledgerExecutionGapMonth` = `aaq://ledger/execution-gap/:yyyyMm`(`S7-10` 의 **그 달** · K1 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) — 픽스처에서는 `m7_monthly_2026_08`·`_gap`·`_masked_recon` 의 ⑧ `D3_EXECUTION.detail_deep_link`(기존 키)가 `aaq://ledger/execution-gap/2026-08` 을 싣는다. 인자 없는 `aaq://ledger/execution-gap` = 엔진 기본 달(「계획」 탭 ⑤). 두 라우트 · 한 위젯(`ExecutionGapScreen`).
- `AppRoutes.rebalanceHistory` = `aaq://rebalance/history`(`S7-6a` 회차 타임라인 · K5 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) — **싣는 픽스처 없음**(셸·진입점이 쓰는 상수).
- 그 밖에 새로 실린 링크 = `m7_rebalance_preview_blocked` 행 1 의 `blocked_action.deep_link` `aaq://x2/resume-report`(`deep_link` 로 덮인다) · `m7_rebalance_sim` 의 `detail_deep_link`(기존 `rebalanceEvent` 패턴). 🔴 `S7-6a` 빈 상태의 «다음 예상» 버튼만 고정 상수 `AppRoutes.rebalancePreview` 를 쓴다(화면 쪽 예외 1개 — 픽스처와 무관).

## 아직 없는 것

- **`m9/` 화면별 픽스처** — 05 에 «모의 데이터» 절이 없어 파일명이 문서에 **하나도 없다**.
  🔴 구현자가 이름을 지어내지 않는다(인벤토리 §0 규칙) — M2가 05 에 목록을 등재한 뒤 만든다.
  🔵 v1.4 의 `m9/contribution_setting_*` 2벌은 `S7-4` 스텝 ① 의 입력(`ContributionSetting`)이라 M2 가 먼저 만들었다 —
  05 화면(`MonthlyContributionVm` 카드 등)의 픽스처는 여전히 없다.
- **`J-4` blind 리뷰 픽스처** — `BlindReviewCard`·`BlindReviewQuestion` 은 타입만 있고 읽기 창구·픽스처가 없다(01 §8 미결 46 — `BlindReviewScore.answers` 가 `Map<String,int>` 인데 선택지가 `ReasonOption{code}` 라 축이 어긋나 있다). 🆕 v1.2 — 본문 단위는 `DecisionJournalBody`(`journal_read_*` 가 그 모양)로 정했고 점수 축은 여전히 미결이다.
- `test/` 의 계약 회귀 ~~C-1~C-37~~ ~~C-1~C-40(🆕 v1.5 C-40 회차↔일지 링크 정합)~~ C-1~C-42(🆕 v1.6 C-41 R12 표시 계약 — 이 절의 픽스처끼리 맞대는 불변식 · C-42 R12 화면 소스 스캔) — 영역 F 의 다른 몫이며 이 README 의 범위가 아니다.
  C-1 골든(`*.golden.json`)도 아직 없다.

## 부록 — 실제 픽스처 파일 목록 (135개, 2026-10-13 실측)

경로 기준 `packages/domain_contracts/fixtures/`. 이 목록은 조립 시점의 실물이며, 명세가 부르는 파일명과 다르면 **실물이 맞습니다**.

### (루트) — 14개

| 파일 | 바이트 |
|---|---:|
| `alerts_12.json` | 5,713 |
| `deposit_plan_1.json` | 4,817 |
| `deposit_plan_funding_1.json` | 5,197 |
| `holdings_6.json` | 8,211 |
| `journal_30.json` | 54,406 |
| `ledger_diffs_4.json` | 2,200 |
| `onboarding_fresh.json` | 6,028 |
| `onboarding_reconnect.json` | 4,087 |
| `performance_24m.json` | 19,092 |
| `range_presets_4.json` | 1,197 |
| `rebalance_6.json` | 18,960 |
| `resume_report_1.json` | 2,808 |
| `safety_states.json` | 5,515 |
| `sleeve_catalog_4.json` | 971 |

### m6 — 41개

| 파일 | 바이트 |
|---|---:|
| `m6/advice_12.json` | 22,338 |
| `m6/advice_blocked.json` | 3,487 |
| `m6/advice_detail_onhold.json` | 3,163 |
| `m6/advice_detail_partial.json` | 3,141 |
| `m6/advice_empty.json` | 1,284 |
| `m6/advice_expired_confirm.json` | 4,955 |
| `m6/advice_handover_cooling.json` | 1,408 |
| `m6/advice_no_action.json` | 2,655 |
| `m6/advice_skip_reasons.json` | 1,146 |
| `m6/advice_viewer_4.json` | 7,731 |
| `m6/decision_detail_amended.json` | 12,014 |
| `m6/decision_detail_full.json` | 8,824 |
| `m6/decision_detail_journal_draft_link.json` | 12,104 |
| `m6/decision_detail_journal_written.json` | 12,103 |
| `m6/decision_detail_partial.json` | 13,029 |
| `m6/decision_detail_reevaluated_child.json` | 8,402 |
| `m6/decision_detail_rejected_saf309.json` | 6,014 |
| `m6/decision_detail_unknown.json` | 5,743 |
| `m6/draft_records_j3.json` | 3,107 |
| `m6/draft_records_x7.json` | 1,740 |
| `m6/entry_gate_nov_pass_1.json` | 1,832 |
| `m6/external_holdings_2.json` | 1,265 |
| `m6/fill_form_spec.json` | 2,463 |
| `m6/fill_form_spec_stale.json` | 2,843 |
| `m6/fill_rejected_price.json` | 1,564 |
| `m6/journal_badges_2.json` | 893 |
| `m6/journal_draft_receipts_5.json` | 2,590 |
| `m6/journal_draft_spec_discretion.json` | 2,148 |
| `m6/journal_draft_spec_recon_clear.json` | 2,074 |
| `m6/journal_empty.json` | 665 |
| `m6/journal_filter_catalog.json` | 2,520 |
| `m6/journal_masked_integrity.json` | 12,720 |
| `m6/journal_read_no_note.json` | 1,336 |
| `m6/journal_read_not_written.json` | 1,424 |
| `m6/journal_read_written.json` | 1,956 |
| `m6/journal_rebalance_scope_1.json` | 783 |
| `m6/journal_rebalance_unknown.json` | 593 |
| `m6/manual_fills_8.json` | 15,189 |
| `m6/self_report_1.json` | 1,459 |
| `m6/unknown_board_2.json` | 8,716 |
| `m6/unknown_board_empty.json` | 879 |

### m7 — 59개

| 파일 | 바이트 |
|---|---:|
| `m7/aftertax_ladder_1.json` | 4,647 |
| `m7/execution_gap_1.json` | 2,204 |
| `m7/execution_gap_cant.json` | 2,623 |
| `m7/execution_gap_empty.json` | 852 |
| `m7/execution_gap_masked_recon.json` | 2,223 |
| `m7/execution_gap_mixed.json` | 2,701 |
| `m7/execution_gap_not_applicable.json` | 937 |
| `m7/execution_gap_wont.json` | 2,665 |
| `m7/ledger_trust_4.json` | 1,810 |
| `m7/m7_annual_2026.json` | 5,915 |
| `m7/m7_annual_first_year.json` | 5,825 |
| `m7/m7_annual_offwindow.json` | 5,949 |
| `m7/m7_contrib_3sleeve.json` | 1,395 |
| `m7/m7_contrib_partial.json` | 1,723 |
| `m7/m7_dd_context_deep.json` | 1,171 |
| `m7/m7_dd_context_normal.json` | 1,053 |
| `m7/m7_deposit_plan_blocked.json` | 932 |
| `m7/m7_deposit_plan_default.json` | 5,017 |
| `m7/m7_deposit_plan_expired.json` | 5,170 |
| `m7/m7_deposit_plan_funding.json` | 5,537 |
| `m7/m7_deposit_plan_input_rejected.json` | 649 |
| `m7/m7_deposit_plan_limit.json` | 3,191 |
| `m7/m7_deposit_register_receipts_4.json` | 2,019 |
| `m7/m7_disclosure_gate.json` | 1,032 |
| `m7/m7_disclosure_gate_closed.json` | 934 |
| `m7/m7_disclosure_gate_first.json` | 969 |
| `m7/m7_disclosure_gate_frequent.json` | 1,083 |
| `m7/m7_disclosure_view_receipts_4.json` | 2,005 |
| `m7/m7_goal_path_hold.json` | 1,888 |
| `m7/m7_goal_path_off.json` | 4,734 |
| `m7/m7_goal_path_on.json` | 4,620 |
| `m7/m7_goal_path_realworld.json` | 4,859 |
| `m7/m7_monthly_2026_08.json` | 3,478 |
| `m7/m7_monthly_gap.json` | 3,849 |
| `m7/m7_monthly_masked_integrity.json` | 4,245 |
| `m7/m7_monthly_masked_recon.json` | 4,460 |
| `m7/m7_monthly_pending.json` | 3,606 |
| `m7/m7_next_rebalance_countdown.json` | 1,073 |
| `m7/m7_next_rebalance_none.json` | 842 |
| `m7/m7_perf_daily_gap.json` | 5,494 |
| `m7/m7_perf_daily_manual.json` | 5,389 |
| `m7/m7_perf_masked_integrity.json` | 1,680 |
| `m7/m7_perf_monthly_period.json` | 9,944 |
| `m7/m7_perf_monthly_sim_split.json` | 5,064 |
| `m7/m7_perf_unavailable_gap.json` | 1,658 |
| `m7/m7_perf_yearly.json` | 2,432 |
| `m7/m7_rebalance_detail_advisory.json` | 4,021 |
| `m7/m7_rebalance_detail_band.json` | 4,021 |
| `m7/m7_rebalance_empty.json` | 598 |
| `m7/m7_rebalance_preview_blocked.json` | 934 |
| `m7/m7_rebalance_preview_default.json` | 4,668 |
| `m7/m7_rebalance_preview_in_band.json` | 3,662 |
| `m7/m7_rebalance_sim.json` | 6,377 |
| `m7/m7_report_archive_18.json` | 3,610 |
| `m7/m7_report_archive_empty.json` | 892 |
| `m7/m7_withdrawal_general.json` | 2,191 |
| `m7/m7_withdrawal_pension_penalty.json` | 2,722 |
| `m7/m7_withdrawal_shortfall.json` | 2,303 |
| `m7/realized_alloc_S7.json` | 2,611 |

### m8 — 18개

| 파일 | 바이트 |
|---|---:|
| `m8/alerts_advice_9codes.json` | 4,364 |
| `m8/alerts_digest.json` | 1,755 |
| `m8/alerts_p0_ack.json` | 2,075 |
| `m8/handbook_page_sleeve_b.json` | 1,828 |
| `m8/incident_token_expired.json` | 2,140 |
| `m8/onboarding_finish.json` | 3,847 |
| `m8/onboarding_fresh_advisory.json` | 4,197 |
| `m8/onboarding_mode_pick.json` | 1,862 |
| `m8/ops_home_advice_open.json` | 2,347 |
| `m8/ops_home_advice_zero.json` | 2,297 |
| `m8/ops_home_blocked.json` | 1,947 |
| `m8/ops_home_normal.json` | 1,580 |
| `m8/ops_home_resume_gap7.json` | 1,980 |
| `m8/ops_rhythm_rows.json` | 1,334 |
| `m8/recon_board_diff.json` | 1,609 |
| `m8/restart_lost_phone.json` | 2,957 |
| `m8/watchdog_delayed.json` | 1,493 |
| `m8/watchdog_holiday.json` | 1,481 |

### m9 — 3개

| 파일 | 바이트 |
|---|---:|
| `m9/contribution_setting_default.json` | 1,175 |
| `m9/contribution_setting_no_limit_note.json` | 1,068 |
| `m9/handover_states.json` | 5,203 |

**합계 135개 · 568,197 바이트.** `fixtures/README.md` 1부는 이 표에 세지 않습니다 (JSON 픽스처만 셉니다).
