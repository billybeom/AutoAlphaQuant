# `lib/src/repositories/` — 읽기 전용 리포지토리 인터페이스 (G3 예정)

정본: 01_M2_도메인계약 **§4-1**

`JournalRepository` · `HoldingsRepository` · `PerformanceRepository` · `RebalanceRepository` · `SafetyRepository` · `AlertRepository` · `ResumeRepository` · `LedgerRepository` · `OnboardingRepository` · 🆕 v1.16 `PairingRepository`(뷰어 `V-01`) · 🆕 v1.17 `IncidentRepository`(`D-01`) · `RunbookRepository`(`D-02`·`D-03`) · `HandbookRepository`(`B-01`·`B-02`) · `OpsStatusRepository.watchDeviceRisk`(`H-03` · 추가형) · 🆕 v1.18 `SettingsRepository.watchHome`(`S01` · 뒤 카드 추가형 · `S07` = `OpsStatusRepository.watchConnections` 그대로) · 🆕 v1.19 `SettingsRepository.watchOperations`(`S05` · 폰 전용) · 🆕 v1.20 `SettingsRepository.watchCredentials`(`S02`)·`watchAccountMapping`(`S03`) · `S06` = `OpsStatusRepository.watchDeviceAccess` 추가형 · 🆕 v1.23 `SettingsRepository.watchContribution`(`S13` 월 납입 투영 · 폰 전용 · 값의 원천 = `ConfigRepository.watchContributionSetting` 과 하나) · 🆕 v1.21 `KillSwitchGateRepository.watchResumeGate`(`M5-2` · 폰 전용 · `ui_safety` 만)·`PledgeRepository.watchPledge`(`M5-8`·`O-04` ② · 기존 `SafetyRepository`·`ResumeRepository` 무변경) · 🆕 v1.22 `BreakerLadderRepository.watchLadder`(`M5-4`)·`ResumeGateRepository.watchGate`(X2 재개 게이트 · 계절 3택 · 기존 창구 무변경 · 01 §31 K6) · `CalendarRepository` · `ConfigRepository` · `WhatIfApi`

## 이 폴더가 지는 규칙

- 🔴 **여기에는 인터페이스만 있다.** 구현체는 `data_sync`(`LocalSqliteReader` = 폰 정본 SQLite / `SupabaseReadModel` = viewer RLS + Realtime) 몫이다.
- **계약 3조**(§4-1)
  1. 두 구현체는 **같은 필드값**을 낸다 — viewer 전용 필드를 만들지 않는다.
  2. 모든 스트림은 `AsOf`를 싣고, viewer의 «엔진 정지» 판정은 push된 상태값이 아니라 `observedAt` **신선도에서 파생**한다. 죽은 엔진은 «나 죽었다»를 보내주지 않는다.
  3. 데이터가 없으면 «빈 리스트»가 아니라 `ListResult`를 준다 — 구현체가 `emptyKind`를 채우지 않으면 **컴파일되지 않는다**.
- 🔴 **정렬·페이징은 엔진 몫이다.** rows는 이미 정렬되어 오고, 페이징은 커서가 아니라 `limit` 증가 재구독 하나뿐이다(1인 사용자·연 ~934건 — 오버엔지니어링 금지).
- 🔴 `watchHoldings(includePnl: false)`가 **기본**이다(결정 8). 화면이 값을 받아 놓고 접기만 하면 결정 8이 렌더 구현 디테일에 의존하게 된다.
- ⚠️ `WhatIfApi`는 리포지토리가 아니라 **부작용 0의 로컬 재계산**이다(M3, `core_engine`의 whatif). 03(M7 명세)의 `WhatIfApi`가 이것이며 **이름은 여기가 정본**이다(구 `PlannerRepository` 폐기). 목록에 함께 두되 DB를 건드리지 않는다.
