# `lib/src/whatif/` — M3 What-if 시뮬레이션 (예정)

정본: 01_M2_도메인계약 **§4-1 `WhatIfApi`** · **§2-6 `DepositPlan`**

담을 것: `WhatIfApi` 구현 — `simulateDeposit` · `simulateWithdrawal` · `previewRebalance` · `estimateCosts` · `findPlan`.

- 🔴 **부작용 0의 로컬 재계산이다.** DB를 건드리지 않는다(결정 2 파생). 그래서 리포지토리 목록과 분리돼 있다.
- 🔴 계획에는 **유효기한**(`expiresAt`)이 있고, **만료된 계획으로 실입금을 등록하면 엔진이 거부**한다. `planId`가 «계획 대비 실제» 대조의 앵커다.
- 🔴 미리보기 고지 문구(`previewNotice`)도 **엔진이 만든다** — 화면이 「미리보기입니다」를 적지 않는다.
- ⚠️ 이름은 `WhatIfApi`가 정본이다. 구 `PlannerRepository`는 폐기됐다(01 §4-1).
