# core_engine — M1(신호·목표비중·한도) · M3(What-if)

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(계산부) · **M3** whatif-service
> **정본**: 전략·규칙은 `06_시스템설계/00_SPEC.md` **v2.32 P0S**(🆕 v1.4 정정 — 구 «v2.31» · v2.32 = 연금 납입 조달 경로 `PENSION_FUNDING`), 등가성 게이트는 `06_시스템설계/05_수용기준_골든벡터.md` · 계약은 `domain_contracts` **v1.4.0**(`WhatIfApi` = 01 §4-1 · §14)

## 무엇을 담나

| 폴더 | 담을 것 |
|---|---|
| `lib/src/signals/` | 국면 판정·진입 게이트·추세/모멘텀 신호 |
| `lib/src/portfolio/` | 슬리브 목표비중·밴드·리밸런싱 수량 산출 |
| `lib/src/risk/` | 청산 티어(TIER 0~3)·손절선·SAF 한도 게이트 |
| `lib/src/whatif/` | M3 — 부작용 0의 입금·인출·리밸런싱 미리보기(`WhatIfApi` 구현) |

> ⚠️ 01 §4-1의 주석은 `core_engine/lib/whatif/`로 적혀 있으나 여기서는 `lib/src/whatif/`를 쓴다. 공개 API는 배럴 `lib/core_engine.dart`로만 노출한다 — 경로 차이일 뿐 소유·성격은 같다.

## 의존 — 허용 (01 §1-1)

`domain_contracts` · `decimal`. **순수 Dart**다.

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety` · Flutter SDK · 브로커 SDK · DB 클라이언트(`sqflite`·`supabase_flutter`).

> 순수 Dart를 유지하는 이유는 취향이 아니다 — 골든벡터를 화면·플랫폼·기기 없이 그대로 돌릴 수 있어야 등가성 게이트가 성립한다.

## 이 패키지가 지는 규칙 3개

1. **Decimal 규약 5조**(01 §1-2 · `01_모듈_인터페이스 §0`)
   ① 금액 × 비율은 비율을 `Decimal.parse(r.toString())`로 승격한 뒤 곱한다
   ② 중간값은 `Decimal`로 계산하고 DTO의 `double` 필드에 담을 때만 `.toDouble()`
   ③ 금액 필드는 끝까지 `Decimal`
   ④ 🔴 **곱셈 먼저, 나눗셈 나중** — `(equity * riskPct) / riskPerShare`
   ⑤ 🔴 `(1 − 비율)`은 Decimal 안에서 — `entry * (Decimal.one - Decimal.parse('0.07'))`
   > **GV-8a는 1 ULP 차이로 판정이 뒤집힌 실측 사례다.** 규약을 어기면 골든이 깨진다.
2. **골든벡터 전량 통과 전에는 DRY_RUN을 벗어나지 않는다**(결정 2). 이 패키지의 Dart 재현이 그 게이트다.
3. **사유 문구는 여기서 만들어진다.** 화면은 만들지 않는다 — 엔진이 `label`·`actionLine` 필드에 실어 보낸다.

## 지금 상태 — 🟢 E1 · E2a · E2b · 나머지는 🟡

실행 계획(블록 E1~E18)은 설계 저장소 `11_앱설계/13_엔진레인_착수계획.md` 가 정본이다.

| 들어온 것 | 06 항목 | 골든·검사 |
|---|---|---|
| `lib/src/decimal_rules.dart` — 규약 ①④⑤ 실행체 + 환원 규칙 | M1-1 | `test/decimal_rules_test.dart` |
| `lib/src/risk/position_sizing.dart` — 이중 상한 사이징 | M1-1 게이트(GV-8 · 새틀 비활성이라 채점 외) | GV-8a~8e · 8f · `test/position_sizing_test.dart` |
| `lib/src/signals/regime_states.dart` · `exposure_gate.dart` — 방향·추세성 상태와 익스포저 곱셈 | M1-2 일부 | GV-3(6) · GV-3c(2) |
| `lib/src/signals/indicators.dart` — SMA · TR · Wilder rma · ATR · ADX(150봉 게이트) · CHOP · BBW(ddof 0) | M1-2 일부(E2a) | GV-2a~2f(10) · `test/indicators_test.dart`(결측·±DM 동률) |
| `lib/src/signals/regime_score.dart` · `hysteresis.dart` — 카테고리 가중 평균·재정규화 · 방향/추세성 히스테리시스(봉 하나씩) | M1-2 일부(E2b) | GV-1(7) · GV-4 계열(13) · `test/regime_test.dart`(UNKNOWN 직전 · 경계 strict · 설정 거부) |

**환원 규칙(E1 에서 정함)** — 나눗셈·곱셈 결과는 파이썬 `decimal` 기본 문맥과 같은 **유효숫자 28 · ROUND_HALF_EVEN** 으로 끊는다(`divide` · `multiply` · `mulDiv`). Dart 의 `Rational.toDecimal(scaleOnInfinitePrecision:)` 은 **버림**이라 파이썬과 반대 방향으로 갈 수 있다 — 05 §GV-8f 의 «나눗셈 선행» 값 `500.0000000000000000000000002` 를 그대로 재현하는 것이 그 확인이다. 기대값은 파이썬 `decimal` 로 뽑았다.

**지표의 기준 구현**은 `09_백테스트/백테스트6/engine/indicators.py`(전략 골든을 만든 엔진)다. 합·평균은 창마다 왼쪽부터 더하므로 pandas·numpy 와 마지막 자리가 다를 수 있다 — 26년 경로의 경계 판정 영향은 E6 에서 잰다.

아직 없는 것: 지표 원값 → 백분위(`pit_percentile`)·부호 정렬·추세성 스코어 조립 · 팩터·월중 전이(E2c) · 슬리브별 승수 GV-18(E3 — 서킷브레이커 소속) · 위험 기여·한도(E3) · 거래일·멱등키(E4) · 슬리브·P0S(E5) · 전략 4자리 대조(E6) · What-if(E7).

✅ SDK 는 설치돼 있다(2026-09-07 · Dart 3.13.2 · Flutter 3.47.2 · melos — `docs/toolchain_notes.md` §1). 이 패키지는 순수 Dart 라 `dart test` 로 돈다(🆕 v1.4 정정 — 구 «이 PC에는 Flutter·Dart·melos가 없다(2026-09-06)»). v1.4 `WhatIfApi` 새 시그니처(`simulateDeposit({required String amountInput})` · `findPlan`)의 구현은 06 M3-1 몫이다(`lib/src/whatif/README.md`).
