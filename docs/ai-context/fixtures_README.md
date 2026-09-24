> **사본 · 정본은 `packages/domain_contracts/fixtures/README.md`.** 부록의 파일 목록은 조립 시점 실측입니다.

# `fixtures/` — 모의 데이터 픽스처 (**계약 v1.1 · 97파일** — G4 77 + `m6/journal_empty.json` + 🆕 v1.1 신규 18 · 2026-09-17 + 🆕 R2 준비 1(`m6/journal_draft_receipts_5.json`) · 2026-09-23)

정본: `11_앱설계/01_M2_도메인계약_초안.md` **§5** · `docs/contracts_inventory.md` **§8** ·
화면 명세 02 «모의 데이터» · 03 §15 · 04 §10.

화면은 **네트워크 없이 이 파일만으로** 그려진다. 파일이 없으면 화면 담당 AI가 가짜 데이터를 만들고,
그 값이 스크린샷에 남는다 — 그것이 G4가 하드 게이트인 이유다(00_README §0-1).

## 🔴 대원칙 — 실키 금지

- 실키·계좌 전체번호·비밀번호 **0건**. 계좌는 **별칭만**(`"연금저축"`·`"일반"`).
- 티커는 실제 국내 ETF를 쓰되 **수량·가격은 가공값**이다. **가짜 데이터만** 넣는다.
- 위반은 §7 **C-14**가 잡는다. 판정부는 `lib/src/fixtures/fixture_loader.dart` 의
  `scanForSecrets` 이며 현재 97파일 전량 **적발 0건**이다.
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
  "meta": { "fixture_version": "0.1.0-draft", "contract_version": "1.1.0",
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
   ✅ **지금 값은 `1.1.0`**(2026-09-17 M2 보강 — 상수와 그때의 96개 픽스처를 **함께** 올렸다 ·
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

### 봉투 확장 — 부속 블록

한 화면이 「목록 + 그 목록의 요약」을 함께 받는 갈래가 있어(`A-1` 안내함이 대표) 봉투에
**형제 키**를 하나 더 싣는다. 봉투 필수 6키는 그대로이고 로더는 이 키를 무시한다.

| 키 | 타입 | 쓰는 파일 |
|---|---|---|
| `summary` | `AdviceInboxSummary` | `m6/advice_*.json` 9벌 |
| `advice_summary` | `AdviceInboxSummary` | `m8/ops_home_advice_*.json` |
| `counterfactual` · `counterfactual_collapsed` | `AfterTaxLadder` · bool | `m7/aftertax_ladder_1.json` |
| `trust` | `LedgerTrustBadge` | `m6/self_report_1.json` |
| `index` | `HandbookIndex` | `m8/handbook_page_sleeve_b.json` |
| `incident_alert` | `AlertItem` | `m8/incident_token_expired.json` |
| `preserved_input` · `reject_reason` · `price_range_source_date` | 원시 · `ReasonChip` · `TradeDate` | `m6/fill_rejected_price.json` |
| `active_flags` · `resume_headline` · `resume_route` · `pending_notice` 계열 | `BlockFlag` 등 | `m8/ops_home_*.json` · `m7/m7_monthly_pending.json` |

---

## 파일 목록 (97)

### 계약 코어 14 — `fixtures/` 바로 아래 (01 §5 · 인벤토리 §8-2·§8-3)

| 파일 | 건수 | 내용 |
|---|---|---|
| `journal_30.json` | 30 | 체결 22 · 부분 3 · 거부 2 · UNKNOWN 1 · prevented 1 · SIM 1 |
| `holdings_6.json` | 6 | 069500(A) · 379810·132030(B) · 0085P0·411060(C) · POT 1종 — `pnl` 은 3건만 |
| `performance_24m.json` | 2계열 | 월간 TWR·MWR 각 24점 + 결측 구간 1(`UNAVAILABLE`) + 벤치마크 |
| `rebalance_6.json` | 6 | monthlyRegular 3 · seasonal 1 · band 1 · deposit 1 |
| `resume_report_1.json` | 1 | 7거래일 갭 · `RECOVERY_DRY` · 4/3/2/1/2 |
| `safety_states.json` | 5 | normal · alert · reduced · halted · stopped(자격 충족 1) |
| `alerts_12.json` | 12 | P0 2 · P1 4 · P2 6(묶임 2) |
| `ledger_diffs_4.json` | 4 | `CANON_BROKER` 1(blocking) · 파생 3(observational) |
| `onboarding_fresh.json` | 14 | 처음 시작하기(verified/failed/expired 각 1) |
| `onboarding_reconnect.json` | 9 | 재연결 갈래 |
| `deposit_plan_1.json` | 1 | 월 납입 = 엔진 설정값 예시 · 잔여 = 원화 현금 대기(D2) · 주문 초안 3 · `funding_steps` **null** |
| `deposit_plan_funding_1.json` | 1 | 납입 조달 발동 · `funding_steps` 2단(파킹 잉여 0 → C 방어자산 매각) |
| 🆕 `range_presets_4.json` | 4 | **v1.1** `ConfigRepository.watchRangePresets()` — 최근 30일(**`is_default`**)·이번 달·올해·전체 기간. 🔴 `is_default` 는 정확히 1건(C-34 ①) |
| 🆕 `sleeve_catalog_4.json` | 4 | **v1.1** `ConfigRepository.watchSleeves()` — A·B·C·POT(`rolls_up_to: A`). P0S 라 새틀라이트 행 없음 |

### `m6/` 32 — 매매일지·보유·X7 안내·수기 체결 (02 «모의 데이터»)

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

### `m7/` 32 — 성과·리밸런싱·플래너·세후·이행 갭 (03 §15)

🆕 **계약 v1.1 3건** — `m7_monthly_masked_integrity`(13항목 전부 「숨김 — 원장 무결성 점검 중」 · 상세 링크 0 · 13칸 유지) · `m7_monthly_masked_recon`(⑦ 비중만 `?` 미확정 표기 — 02 §2-2 표) · `m7_contrib_partial`(§8 미결 45 — C 슬리브 「산출 불가」 · `normalized: 0.0` · `unavailable_label`).
🔵 같은 창에서 `m7_monthly_2026_08`·`_gap` 에 `generated_at_text`·`config_hash`·항목 `detail_deep_link`(④⑤→`S7-3` · ⑧→`S7-10`)가, `m7_monthly_pending` 에 `pending_notice_text` 가 들어갔다(봉투 형제 키 `pending_d_day_text` 는 **폐기** — §8 미결 40·41·43).

`aftertax_ladder_1`(정본 갈래 5단 + 반사실 1 접힘 · `is_reference_only: true`) ·
`realized_alloc_S7`(🔴 **C-31의 입력** — 회계 열 대조) · `ledger_trust_4` ·
`execution_gap_cant`·`_wont`·`_mixed`(🔴 **B21 3갈래** — `mode_advice_line` 이 각각 다르다) · `execution_gap_1` ·
`m7_deposit_plan_default`·`_limit`·`_expired`(🔴 이름에 금액 금지) ·
`m7_withdrawal_general`·`_pension_penalty`·`_shortfall` ·
`m7_monthly_2026_08`·`_gap`·`_pending`(13항목 고정 배열) · `m7_report_archive_18` · `m7_disclosure_gate` ·
`m7_perf_daily_gap` · `m7_dd_context_normal`·`_deep` · `m7_contrib_3sleeve` ·
`m7_next_rebalance_d6` · `m7_rebalance_detail_band` · `m7_annual_2026`·`_first_year` ·
`m7_goal_path_on`·`_hold`·`_realworld`.

### `m8/` 18 — 셸·운영 홈·알림·온보딩 (04 §10)

`ops_home_normal`·`_blocked`·`_resume_gap7`·`_advice_open`·`_advice_zero` · `ops_rhythm_rows` ·
`recon_board_diff`(🔴 칸 수 **5 고정** · `CANON_SELF_REPORT` 는 `applicable: false` = 「점검 안 함」) ·
`alerts_p0_ack` · `alerts_digest` · `alerts_advice_9codes`(X7 알림 9종) ·
`watchdog_delayed` · `watchdog_holiday`(🔴 휴장의 쉼은 결측이 아니다) · `incident_token_expired` ·
`onboarding_finish` · `restart_lost_phone` · `onboarding_fresh_advisory` ·
`onboarding_mode_pick`(🔴 **기본 선택 없음 · 「권장」 배지 없음**) · `handbook_page_sleeve_b`.

> ⚠️ 04 §10 목록의 `onboarding_fresh.json` 은 **코어의 같은 이름 파일이 정본**이라
> `m8/` 에 다시 두지 않았다(같은 데이터가 두 벌이 되면 한쪽만 갱신된다).

### `m9/` 1 — 설정·운영 모드 전환 (05)

`handover_states`(경로 4 × 성공/실패 — `SIM_TO_AUTO` 통과 · `FRESH_AUTO` 차단 ·
`ADOPT_LEDGER` 모름 · `HANDBACK_MANUAL` 차단 + `handback_branch`).

---

## 값을 고를 때 지킨 것

- **티커는 전부 자리표시자**다(01 §5 말미). `069500` 은 KOSPI200 ETF라 P0S 슬리브 A(KOSDAQ 지수)와
  맞지 않지만 **실전 종목 확정 전까지 고치지 않는다** — 화면은 티커를 슬리브의 정의로 읽지 않는다
  (A/B/C 라벨은 `SleeveCatalogEntry.label`). 🔴 POT 자리의 `357870` 은 03 §15 가 열거한 5종 밖이라
  **이 회차가 새로 고른 자리표시자**이며, 실전 종목이 확정되면 함께 교체된다.
- **월 납입 예시값은 `100000`**(01 §5 · 04 §10). 🔴 **파일명에 금액을 넣지 않는다**
  (`_default`·`_limit`·`_expired`). 값은 파일 **안**에만 있고 운영값의 창구는
  `ConfigRepository.watchContributionSetting()` 하나다. C-32는 `ui_*` 소스만 보며 `fixtures/` 는 대상이 아니다.
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

## 역직렬화 실측 (2026-09-08 · 233행 → 🆕 2026-09-23 · 94파일 267행 + 봉투 형제 키 9 · 실패 0)

97파일 전량이 봉투 검사를 통과하고(`m6/journal_empty.json` 은 0행 봉투), 그중 **94파일**(v1.1 실측 2026-09-17 93 + R2 준비 2026-09-23 +1)이 실제 DTO 의 `fromJson` 을 지나
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

픽스처의 링크 필드(`deep_link`·`detail_deep_link`·`action_deep_link`·`where_deep_link`·`clear_deep_link`·`route`·`preview_route`·`handoff_route`·`resume_route`)에는 `aaq://…`(앱 화면)와 `handbook://…`(핸드북 앵커) **두 스킴만** 온다. `aaq://` 는 전부 `AppRoutes.all`(`lib/src/navigation/app_links.dart`)의 패턴과 일치해야 하며 **C-33** 이 전수 검사한다. 🔴 화면은 이 문자열을 만들지도 해석하지도 않는다 — `AppLinkOpener.open(link)` 에 그대로 넘긴다.

## 아직 없는 것

- **`m9/` 화면별 픽스처** — 05 에 «모의 데이터» 절이 없어 파일명이 문서에 **하나도 없다**.
  🔴 구현자가 이름을 지어내지 않는다(인벤토리 §0 규칙) — M2가 05 에 목록을 등재한 뒤 만든다.
- **`J-4` blind 리뷰 픽스처** — `BlindReviewCard`·`BlindReviewQuestion` 은 타입만 있고 읽기 창구·픽스처가 없다(01 §8 미결 46 — `BlindReviewScore.answers` 가 `Map<String,int>` 인데 선택지가 `ReasonOption{code}` 라 축이 어긋나 있다).
- `test/` 의 계약 회귀 C-1~C-34 — 영역 F 의 다른 몫이며 이 README 의 범위가 아니다.
  C-1 골든(`*.golden.json`)도 아직 없다.

## 부록 — 실제 픽스처 파일 목록 (97개, 2026-09-23 실측)

경로 기준 `packages/domain_contracts/fixtures/`. 이 목록은 조립 시점의 실물이며, 명세가 부르는 파일명과 다르면 **실물이 맞습니다**.

### (루트) — 14개

| 파일 | 바이트 |
|---|---:|
| `alerts_12.json` | 5,713 |
| `deposit_plan_1.json` | 3,056 |
| `deposit_plan_funding_1.json` | 3,590 |
| `holdings_6.json` | 8,211 |
| `journal_30.json` | 54,406 |
| `ledger_diffs_4.json` | 2,200 |
| `onboarding_fresh.json` | 6,028 |
| `onboarding_reconnect.json` | 4,087 |
| `performance_24m.json` | 8,358 |
| `range_presets_4.json` | 1,197 |
| `rebalance_6.json` | 15,293 |
| `resume_report_1.json` | 2,808 |
| `safety_states.json` | 5,515 |
| `sleeve_catalog_4.json` | 971 |

### m6 — 32개

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
| `m6/decision_detail_partial.json` | 13,029 |
| `m6/decision_detail_reevaluated_child.json` | 8,402 |
| `m6/decision_detail_rejected_saf309.json` | 6,014 |
| `m6/decision_detail_unknown.json` | 5,743 |
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
| `m6/manual_fills_8.json` | 15,189 |
| `m6/self_report_1.json` | 1,459 |
| `m6/unknown_board_2.json` | 8,716 |
| `m6/unknown_board_empty.json` | 879 |

### m7 — 32개

| 파일 | 바이트 |
|---|---:|
| `m7/aftertax_ladder_1.json` | 2,965 |
| `m7/execution_gap_1.json` | 1,801 |
| `m7/execution_gap_cant.json` | 2,062 |
| `m7/execution_gap_mixed.json` | 2,343 |
| `m7/execution_gap_wont.json` | 2,125 |
| `m7/ledger_trust_4.json` | 1,810 |
| `m7/m7_annual_2026.json` | 1,767 |
| `m7/m7_annual_first_year.json` | 1,639 |
| `m7/m7_contrib_3sleeve.json` | 1,395 |
| `m7/m7_contrib_partial.json` | 1,723 |
| `m7/m7_dd_context_deep.json` | 1,171 |
| `m7/m7_dd_context_normal.json` | 1,053 |
| `m7/m7_deposit_plan_default.json` | 3,056 |
| `m7/m7_deposit_plan_expired.json` | 3,159 |
| `m7/m7_deposit_plan_limit.json` | 3,066 |
| `m7/m7_disclosure_gate.json` | 1,033 |
| `m7/m7_goal_path_hold.json` | 3,005 |
| `m7/m7_goal_path_on.json` | 2,904 |
| `m7/m7_goal_path_realworld.json` | 2,928 |
| `m7/m7_monthly_2026_08.json` | 3,417 |
| `m7/m7_monthly_gap.json` | 3,788 |
| `m7/m7_monthly_masked_integrity.json` | 4,245 |
| `m7/m7_monthly_masked_recon.json` | 4,452 |
| `m7/m7_monthly_pending.json` | 3,606 |
| `m7/m7_next_rebalance_d6.json` | 925 |
| `m7/m7_perf_daily_gap.json` | 2,921 |
| `m7/m7_rebalance_detail_band.json` | 3,206 |
| `m7/m7_report_archive_18.json` | 3,366 |
| `m7/m7_withdrawal_general.json` | 2,050 |
| `m7/m7_withdrawal_pension_penalty.json` | 2,651 |
| `m7/m7_withdrawal_shortfall.json` | 2,161 |
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

### m9 — 1개

| 파일 | 바이트 |
|---|---:|
| `m9/handover_states.json` | 5,203 |

**합계 97개 · 413,287 바이트.** `fixtures/README.md` 1부는 이 표에 세지 않습니다 (JSON 픽스처만 셉니다).
