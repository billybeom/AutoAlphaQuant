# `lib/src/enums/` — 열거형

정본: 01_M2_도메인계약 **§2-1·§2-2·§2-4·§2-5·§2-7~§2-10 · §3-7 · §4-2·§4-3 · §9·§10** · `docs/contracts_inventory.md` §2 · `docs/m2-8_naming.md` A·B

| 파일 | 담는 것 |
|---|---|
| `sleeve.dart` | `SleeveId` · `AllocationBasis` |
| `mode.dart` | `RunMode`(+ `isSim` 확장 게터) · `ExecPolicy` · `OperatingMode` — 🔴 직교하는 3축 |
| `order.dart` | `OrderSide` |
| `ui.dart` | `ChipTone` · `GateState` · `UiLevel` · `EmptyKind` |
| `journal.dart` | `JournalStatus` · `FillVisibility` · `FillOrigin` · `FillKind` · `CostSource` |
| `performance.dart` | `PerfMetric` · `PerfGranularity` · `SegmentKind` · `TaxLadderBranch` |
| `rebalance.dart` | `RebalanceKind` · 🆕 v1.8 `SleeveBandState`(01 §17) |
| `resume.dart` | `PlannedWorkState` · `ResumeMode` · `ResumePhase` |
| `calendar.dart` | `CalendarOrigin` · `CalendarEventKind` |
| `ledger.dart` | `LedgerPair` · `LedgerAxis` · `DiffSeverity` · `DiffStatus` · `RepairRoute` · `LedgerTrustGrade`(+ ⏸ `LedgerEventKind` 주석) |
| `safety.dart` | `AlertLevel` · `BreakerLevel` · `ClearRoute` |
| `onboarding.dart` | `OnboardingTrack` · `StepRequirement` · `StepState` |
| `advice.dart` | `AdviceStatus` · `AdviceKind` · `AdviceSkipReason` · `AdviceActionId` · `HoldingScope` · `HandoverPath` · `CredentialUse` · `SelfReportPurpose` · `SeasonalEntryGateState` |
| 🆕 `market_data.dart` | **v1.14** `MarketDataSource`(시세·지표 원천 6값 — 배치 G `source` CHECK · C-15 · 01 §22 · 화면 미사용) |
| `command.dart` | `CommandKind` · `CommandState` · `SettingsActionId` — 🔴 **A가 소유하고 `commands/`(D)는 import만** |

> 🔵 `RampLevel`(OpsRamp L0~L5)은 이 폴더가 아니라 **영역 B `dto/safety.dart`** 소유다(인벤토리 §3-14). 전략 §12-⑫의 `EntryRamp`(초기 진입 6개월 분할)와 **다른 것**이며 하나의 위젯으로 합치지 않는다.

## 이 폴더가 지는 규칙

- 🔴 **직렬화는 `@JsonValue`로 못 박는다** — Dart는 camelCase, JSON·DDL은 SCREAMING_SNAKE_CASE(`filled` ↔ `"FILLED"`, `SleeveId.a` ↔ `"A"`). 자동 변환에 맡기면 픽스처·DDL `CHECK`와 갈라지고 C-15가 실패한다. **자동 변환 0건**이 규약이다.
- 🔴 **같은 문자열을 `wire` 필드로도 싣는다.** enhanced enum의 `final String wire` 는 `@JsonValue`와 **같은 문자열**이며(둘은 붙어 있다) 한쪽만 고치지 않는다. `@JsonValue`는 생성기용이라 런타임에서 읽을 수 없어, DB·CHECK 대조가 필요한 곳은 `wire`를 쓴다.
- 🔴 **기계 변환이 틀리는 자리 3곳**(`m2-8_naming.md` B) — `SleeveId.satellite` ↔ `'SAT'` · `StepRequirement.required_` ↔ `'REQUIRED'` · `CommandKind.manualFillRecord`·`manualFillAmend`·`manualFillVoid`·`adviceSkip` ↔ `'RECORD_MANUAL_FILL'`·`'AMEND_MANUAL_FILL'`·`'VOID_MANUAL_FILL'`·`'SKIP_ADVICE'`(**어순이 뒤집혀 있다**).
- 🔴 **신규 열거값은 DDL `CHECK` → `@JsonValue` → 픽스처 순서로 같은 커밋에** 넣는다.
- 🔴 **모든 열거값에 짝이 되는 `*Label` 문자열 필드가 DTO에 있어야 한다**(§1-5). 없으면 화면이 문구를 분기로 고르게 된다 — 그것은 «생성»이고 C-5 위반이다.
- 🔴 **화면은 `default:` 없는 exhaustive switch로 분기한다**(C-12). 그래야 새 열거값이 조용히 무시되지 않는다.
- 🔵 `SleeveId.satellite`는 **열거값으로 보존하되 화면에 노출하지 않는다**(v2.31 P0S, `satellite_enabled=false`). 화면이 목록을 걸러내는 코드를 쓰지 않게 슬리브 목록은 `SleeveCatalogEntry`로 온다.
- ⚠️ `GateState.unknown`은 `notApplicable`과 의미가 다르다 — «모름»이며 **진행 차단**이다.
- ⏸ `LedgerEventKind`(결정 ㊲) · `SettingsActionId.settingsContributionUpdate`·`calendarReconnect` — **이름만 등재하고 기능은 만들지 않는다**.
