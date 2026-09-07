# core_engine — M1(신호·목표비중·한도) · M3(What-if)

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(계산부) · **M3** whatif-service
> **정본**: 전략·규칙은 `06_시스템설계/00_SPEC.md` **v2.31 P0S**, 등가성 게이트는 `06_시스템설계/05_수용기준_골든벡터.md`

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

## 지금 상태 — 🟡 스캐폴드

`lib/src/`의 네 폴더는 **자리만 있고 비어 있다**. 배럴도 비어 있다.

**⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06) — 테스트·분석은 SDK 설치 후 처음 돈다.
