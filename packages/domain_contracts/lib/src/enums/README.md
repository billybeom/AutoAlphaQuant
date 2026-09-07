# `lib/src/enums/` — 열거형 (G3 예정)

정본: 01_M2_도메인계약 **§2-1·§2-2·§2-4·§2-5·§2-7~§2-10 · §4-2·§4-3**

`SleeveId` · `RunMode` · `OrderSide` · `ChipTone` · `GateState` · `UiLevel` · `EmptyKind` · `JournalStatus` · `FillVisibility` · `PerfMetric` · `PerfGranularity` · `SegmentKind` · `RebalanceKind` · `PlannedWorkState` · `ResumeMode` · `ResumePhase` · `CalendarOrigin` · `CalendarEventKind` · `LedgerPair` · `LedgerAxis` · `DiffSeverity` · `DiffStatus` · `RepairRoute` · `AlertLevel` · `BreakerLevel` · `ClearRoute` · `OnboardingTrack` · `StepRequirement` · `StepState` · `CommandKind` · `CommandState` · `SettingsActionId` · `AsOfSource`

## 이 폴더가 지는 규칙

- 🔴 **직렬화는 `@JsonValue`로 못 박는다** — Dart는 camelCase, JSON·DDL은 SCREAMING_SNAKE_CASE(`filled` ↔ `"FILLED"`, `SleeveId.a` ↔ `"A"`). 자동 변환에 맡기면 픽스처·DDL `CHECK`와 갈라지고 C-15가 실패한다.
- 🔴 **신규 열거값은 DDL `CHECK` → `@JsonValue` → 픽스처 순서로 같은 커밋에** 넣는다.
- 🔴 **모든 열거값에 짝이 되는 `*Label` 문자열 필드가 DTO에 있어야 한다**(§1-5). 없으면 화면이 문구를 분기로 고르게 된다 — 그것은 «생성»이고 C-5 위반이다.
- 🔴 **화면은 `default:` 없는 exhaustive switch로 분기한다**(C-12). 그래야 새 열거값이 조용히 무시되지 않는다.
- 🔵 `SleeveId.satellite`는 **열거값으로 보존하되 화면에 노출하지 않는다**(v2.31 P0S, `satellite_enabled=false`). 화면이 목록을 걸러내는 코드를 쓰지 않게 슬리브 목록은 `SleeveCatalogEntry`로 온다.
- ⚠️ `GateState.unknown`은 `notApplicable`과 의미가 다르다 — «모름»이며 **진행 차단**이다.
