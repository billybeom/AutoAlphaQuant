# trading_runtime — M1 실행 런타임 · X2 장기 미실행 재개

> **owner(사양·결정)**: Claude · **코드 담당**: Claude
> **청사진 카드**: **M1** engine-runtime(실행부) · **X2** catch-up-ledger
> **정본**: `06_시스템설계/04_안전장치.md` · 01_M2_도메인계약 **§2-7**(`PlannedWorkSummary`·`ResumeReport`) · **§6-3**(`planned_work`·`resume_run`·`data_gap`)

## 무엇을 담나

FGS(포그라운드 서비스) 수명 · 정확 알람 · 일 1회 배치 잡 스케줄 · 워치독 · **장기 미실행 재개(catch-up)** 절차 R0~R8.

## 의존 — 허용

`domain_contracts` · `core_engine` · `broker_gateway`.

## 의존 — 🔴 금지

`ui_journal` · `ui_analytics` · `ui_shell` · `ui_settings` · `ui_safety`.

> 재개 리포트를 **그리는** 화면은 `ui_safety`(M5 소유)다. 런타임은 상태를 만들고, 화면은 받는다.

## 이 패키지가 지는 규칙 3개

1. **재개는 «밀린 일을 몰아서 실행»이 아니라 «재판정»이다.** 계획은 만료(`EXPIRED`)·대체(`SUPERSEDED`)·차단(`BLOCKED`)·복구 불가(`UNRECOVERABLE`)로 갈릴 수 있고, 그 판정 결과가 사용자에게 보이는 전부다.
2. **Supabase 미러에는 계획 원문이 아니라 digest + 한 줄 요약만 올린다**(X2 원칙 ②).
3. **재개 리포트에 손익 필드가 없다**(결정 8 · 청사진 X2 화면). 헤드라인은 «7거래일 미실행: 실행 4 / 만료 3 / 대체 2 / 차단 1 / 복구 불가 2» 형태의 **과정 지표**다.

## ⚠️ 구현 시 판단할 것 — 플랫폼 경계

FGS·정확 알람은 Android 기능이라 Flutter 플러그인이 필요해질 수 있다. 그러면 이 패키지가 순수 Dart를 벗어나고 재개 로직을 폰 없이 테스트할 수 없게 된다. **플랫폼 호출을 `app_operator_android` 쪽 얇은 어댑터로 밀어낼 수 있는지 먼저 검토할 것.**

## 지금 상태 — 🟡 스캐폴드

배럴만 있다. **⚠️ 이 PC에는 Flutter·Dart·melos가 없다**(2026-09-06).
