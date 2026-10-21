# `lib/src/whatif/` — M3 What-if 시뮬레이션

> 🟢 **들어온 것(E7a1)** — `after_tax.dart`(세후 산식 · 정본 `09_백테스트/백테스트6/exp/tax_lib.py` · 무납입 전용) · `after_tax_ladder.dart`(`AfterTaxLadder` 조립 · §8 미결 18 확정 전에는 늘 골든 참고치). 🟢 **E7a2-1** — 입력 포트(`what_if_state.dart` · `WhatIfStateSource`) · 설정(`what_if_config.dart`) · 표시 글자(`what_if_text.dart`) · 금액 입력 판정(`amount_input.dart`) · 차단 표(`what_if_gates.dart` · D21 · H64 — 설계 13 §8 R18). 🟢 **E7a2-2** — 입금 미리보기 계산(`deposit_plan.dart` · D-1 «대기 자리» 초안). 🟢 **E7a2-3** — `EngineWhatIfApi`(`engine_what_if_api.dart` · `simulateDeposit` · `findPlan`(등록 불가·만료 다시 판정) · `estimateCosts`) · 계획 스냅샷 저장소(`plan_store.dart` · 메모리 · planId `pl_<한국 날짜>_<순번>`). 🟡 `previewRebalance` 는 E7a3 · `simulateWithdrawal` 은 인출 규칙 결정 뒤 · SQLite 스냅샷은 E7b.

정본: 01_M2_도메인계약 **§4-1 `WhatIfApi`** · **§2-6 `DepositPlan`** · 🆕 **§14 계약 v1.4**(R11 선행) · 전략 `06_시스템설계/00_SPEC.md` **v2.32**

담을 것: `WhatIfApi` 구현 — 시그니처(계약 v1.4 · `domain_contracts/lib/src/repositories/what_if_api.dart` 가 정본)

```dart
Future<DepositPreviewResult> simulateDeposit({required String amountInput}); // 🆕 v1.4
Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount});         // ⏸ 인출 규칙 결정 뒤 첫 minor 에서 바뀐다
Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate}); // 🆕 v1.6 — 초안 | 차단
Future<CostEstimate> estimateCosts(String planId);
Future<DepositPlan?> findPlan(String planId);
```

- 🔴 **부작용 0의 로컬 재계산이다.** 원장·명령 테이블에 쓰지 않는다(결정 2 파생). 그래서 리포지토리 목록과 분리돼 있다. 계획 스냅샷(`plan_snapshot`)은 등록 대조용 **엔진 로컬 캐시**이며 이 조문과 모순되지 않는다(01 §14-8 · 06 M3-1).
- 🆕 v1.4 — `simulateDeposit` 은 **입력칸 글자 그대로**(`amountInput`)를 받는다. 파싱·빈칸·0·음수·범위 판정과 차단(재개 미완·복구·원장 무결성·계좌 매핑 미완) 판정, 계좌 라우팅은 전부 이 구현이 한다. 결과는 `DepositPreviewResult` 의 세 갈래 중 **정확히 하나**다 — `plan` · `inputRejectedText`(입력 거부 문장) · `blockedText`(+ 선택 `blockedAction`). `Future` 에러는 «계산을 못 했다»(인프라)만 뜻한다.
- 🔴 계획에는 **유효기한**(`expiresAt`)이 있다. 이 계획으로 등록할 수 없으면(만료·정합 불일치·원장 정정 중·금액 범위 등) 엔진이 `DepositPlan.registerBlockedText` 문장으로 미리 말하고, 그래도 오면 등록을 거부한다. 등록 인자는 `DepositRegistration(planId:)` **하나**이고 금액·기준일은 이 스냅샷에서 가져온다(06 M3-2). `planId` 가 «계획 대비 실제» 대조의 앵커다.
- 🔴 미리보기 고지 문구(`previewNotice`)도 **엔진이 만든다** — 화면이 「미리보기입니다」를 적지 않는다. v1.4 부터 이 필드는 **고지 전용**이며 경고는 `warningLines` 로 싣는다.
- 🔴 표시 글자(`depositAmountText`·`residualKrwCashText`·`sideLabel`·`quantityText`·`limitPriceText` · 한도 카드 `PensionLimitVm` 등)는 전부 여기서 만든다 — 화면은 원값 필드를 읽지 않는다(C-38 ⑩).
- 🆕 **SPEC v2.32 `PENSION_FUNDING`** — C 원화현금이 연금 납입액에 모자라면 C 방어자산 매도로 조달하고, 그 단계를 `DepositPlan.fundingSteps` 에 실행 순서대로 싣는다(0원 단계는 만들지 않는다 · 조달이 없으면 null). `RebalancePreview.fundingSteps` 도 같은 규칙이다.
- ⚠️ 이름은 `WhatIfApi`가 정본이다. 구 `PlannerRepository`는 폐기됐다(01 §4-1).
