# `fixtures/` — 모의 데이터 픽스처 (**G4 예정 — 아직 비어 있다**)

정본: 01_M2_도메인계약 **§5**

화면은 **네트워크 없이 이 파일만으로** 그려진다. 파일이 없으면 화면 담당 AI가 가짜 데이터를 만들고, 그 값이 스크린샷에 남는다 — 그것이 G4가 하드 게이트인 이유다(00_README §0-1).

## 🔴 대원칙 — 실키 금지

- 실키·계좌 전체번호·비밀번호 **0건**. 계좌는 **별칭만**(`"연금저축"`·`"일반"`).
- 티커는 실제 국내 ETF를 쓰되 **수량·가격은 가공값**이다. **가짜 데이터만** 넣는다.
- 위반은 §7 **C-14**(KIS 앱키·`ya29.`·`1//`·8자리 계좌 패턴 스캔)가 잡는다.
- 어떤 AI에게도 실키를 붙여넣지 않는다. 실키는 완성된 M9 화면에서 발주자가 직접 입력한다.

## 예정 파일 — 계약 코어 (`fixtures/` 바로 아래)

| 파일 | 건수 | 내용 |
|---|---|---|
| `journal_30.json` | 30 | 체결 22 · 부분 3 · 거부 2 · UNKNOWN 1 · prevented 1 · SIM 1 |
| `holdings_6.json` | 6 | A 1 · B 2 · C 2 · POT 1 — `pnl`은 3건만 |
| `performance_24m.json` | 24 | 월간 TWR/MWR + 결측 구간 1개(`unavailable`) + 벤치마크 |
| `rebalance_6.json` | 6 | monthlyRegular 3 · seasonal 1 · band 1 · deposit 1 |
| `resume_report_1.json` | 1 | 7거래일 갭 · `recoveryDry` · 실행 4/만료 3/대체 2/차단 1/복구불가 2 |
| `safety_states.json` | 5 | normal · alert · reduced · halted · stopped(자격 충족 1건) |
| `alerts_12.json` | 12 | P0 2 · P1 4 · P2 6 (묶임 사례 2건) |
| `ledger_diffs_4.json` | 4 | canonBroker 1(blocking) · 파생 3(observational) |
| `onboarding_fresh.json` | 14 | 처음 시작하기 (verified/failed/expired 각 1건) |
| `onboarding_reconnect.json` | 9 | 기존 계정에서 다시 시작하기 — `OnboardingTrack.reconnect` |
| `deposit_plan_1.json` | 1 | 월 9만원 납입 · 잔여 = 원화 현금 대기(D2) · 주문 초안 3건 |

> ⚠️ **건수 불일치 — 임의로 정하지 말 것.** 01 §5 본문과 00_README §0-1(G4)은 「10건」이라고 적었는데 위 표는 **11행**이다(`onboarding_reconnect.json`이 🆕로 나중에 추가되면서 총계가 갱신되지 않은 것으로 보인다). G4 착수 전에 M2가 문서 쪽 총계를 고칠 것.

화면 그룹 전용 상태 조합(04 §10의 `ops_home_*`·`watchdog_*`·`handbook_page_*`, 05의 설정 화면 픽스처)은 `fixtures/m6/`·`m7/`·`m8/`·`m9/`에 둔다. **생성·소유는 똑같이 M2다** — 화면 명세가 나열한 파일명은 요청 목록이지 자기 소유 선언이 아니다.

## 봉투 형식

전 픽스처가 `meta` + `as_of` + `empty_kind` + `empty_label` + `has_more` + `rows` 형태를 쓴다. 이 네 값은 `ListResult<T>`(§2-1)에 그대로 대응하며 **빈 목록 픽스처도 싣는다** — 그래야 «없음»(`NO_DATA` + 문구)과 «모름»(`NOT_LOADED` + `stale_reason_code`)이 화면에서 갈린다. 예시 JSON은 01 §5에 있다.

- 🔴 금액은 **문자열**이다(`"38250.00"`). 숫자 리터럴로 쓰면 C-8이 실패한다.
- 🔴 `meta.contract_version`은 `lib/src/contract_version.dart`의 상수와 같은 축이다. 한쪽만 올리지 않는다.

## 🔴 누가 고치나

**픽스처 갱신은 계약 소유자(Claude)만 한다.** 화면 AI가 「테스트가 안 맞아서」 픽스처를 고치는 것은 **반려 사유**다. 픽스처는 골든 스냅샷의 입력이기도 해서, 값을 바꾸면 스냅샷이 깨진다 — **그것이 의도된 게이트**다.
