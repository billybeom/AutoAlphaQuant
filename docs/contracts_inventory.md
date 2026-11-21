# `domain_contracts` 구현 인벤토리 — G3·G4 병렬 구현자의 단일 참조

> **무엇**: `11_앱설계/01_M2_도메인계약_초안.md`(§1~§10) + `06 M2-1~M2-10` + `10 §3` + X7 확정 식별자 목록 ③ 을 **구현 가능한 목록**으로 옮긴 것. 여기 있는 이름·필드·경로만 만든다.
> **누가 읽나**: 영역 A~F 를 병렬로 맡은 구현자 6명. 🔴 **자기 영역 밖의 Dart 파일을 고치지 않는다** — 남의 영역 타입은 이 문서의 경로대로 `import` 하고, 아직 없으면 «그 영역이 만들 것»을 전제로 쓴 뒤 통합 단계에 맡긴다.
> **정본 우선순위**: 01 문서 > 이 문서 > 06·10·X7 목록. 01 과 X7 목록이 다르면 **01 §10 이 이긴다**(01 §0 · X7 ③ 서문).
> **이름 미확정(⚠️ M2-8)** 은 `docs/m2-8_naming.md` 가 확정한 이름을 쓴다. 🔴 **구현자가 즉석에서 새 이름을 만들지 않는다.**

---

## §0. 영역 6분할 — 누가 어느 파일을 쓰는가

| 영역 | 무엇 | 소유 경로 | 다른 영역이 이 영역에서 가져다 쓰는 것 |
|---|---|---|---|
| **A** | 원시타입 · 열거형 **전량** | `lib/src/primitives/**` · `lib/src/enums/**` | 전 영역이 의존한다. **A 가 먼저 서야 B~F 가 컴파일된다** |
| **B** | DTO 1조 — M6(일지·보유) · M8(알림·안전·온보딩) · X5(정합) · X2(재개) · X3 · 공통 봉투 DTO | `lib/src/dto/common.dart` · `journal.dart` · `holdings.dart` · `resume.dart` · `calendar.dart` · `ledger.dart` · `safety.dart` | `ReasonChip`·`DecisionRef`·`GateBadge`·`FeatureFlags`·`SleeveCatalogEntry`(→ C·D) · `TradeJournalEntry`(→ D 리포지토리 시그니처) |
| **C** | DTO 2조 — M7(성과·리밸런싱·플래너·세후) · M9(설정·운영) · X6 · X7(안내·신뢰·전환) | `lib/src/dto/performance.dart` · `rebalance.dart` · `plan.dart` · `advice.dart` · `ledger_trust.dart` · `handover.dart` · `ops.dart` · `settings.dart` | `ContributionSetting`·`AdviceItem`·`ManualFillFormSpec`·`SelfReportLine`·`ExecutionGapReport`(→ D) |
| **D** | 리포지토리 인터페이스 · `CommandApi` · 명령 인자 · `SettingsActions` | `lib/src/repositories/**` · `lib/src/commands/**` | 없음(최종 소비자) |
| **E** | 코드→문구 매핑 사전 · `contract_version` · DDL 배치 A~F | `lib/src/labels/**` · `lib/src/contract_version.dart` · `ddl/*.sql` | `contractVersion`(→ F 봉투 검증) · 코드 상수(→ F 픽스처 값) |
| **F** | 픽스처 JSON + 로더 + 계약 테스트 | `fixtures/**` · `lib/src/fixtures/**` · `test/**` | 없음(최종 소비자) |

> 🔴 **배럴 `lib/domain_contracts.dart` 는 통합 담당만 편집한다.** 영역 구현자는 `export` 를 추가하지 않는다.
> 🔴 **`lib/src/` 아래를 화면이 직접 import 하지 않는다** — 공개 진입점은 배럴 하나다.

### 0-1. 영역 간 컴파일 순서 (선행 의존)

```
A(primitives·enums)
 ├─▶ B(DTO 1조)  ─┬─▶ D(리포지토리·명령)
 ├─▶ C(DTO 2조)  ─┘        │
 ├─▶ E(라벨·DDL·버전)       │
 └───────────────────────────┴─▶ F(픽스처·로더·테스트)
```

- A 는 **다른 어떤 영역도 기다리지 않는다.** 먼저 끝낸다.
- B·C 는 서로를 참조하지 않는다 — 단 하나의 예외가 `BackdateStamp`(B 소유, C 의 X7 문맥에서 정의됨)와 `LedgerDiffRow.applicable`(B 소유 DTO 의 X7 신설 필드)이며, **둘 다 B 가 만든다**(01 §2-11 말미 조문).
- D 는 B·C 의 타입 이름만 알면 되므로 **선언이 없어도 import 문을 먼저 쓰고 통합 단계에 맡긴다.**

### 0-2. 전 영역 공통 규약 5조 (어기면 계약 테스트가 빌드를 깨뜨린다)

1. **금액은 `Decimal` + `@DecimalStringConverter()`**, JSON 은 문자열(`"38250.00"`). 숫자 리터럴은 C-8 이 잡는다(01 §1-2).
2. **비율·스코어는 `double`**, 거래일은 `TradeDate`(`extension type`), 시각은 **UTC `DateTime`**. `DateTime.now()` 직접 호출 0건(01 §1-3).
3. **계산 getter 0건 · `save_`/`write_`/`submit_`/`send_` 함수 0건**(01 §1-4). 값과 «그 값의 완성 문자열»을 함께 싣는다.
4. **열거값에는 짝이 되는 `*Label` 문자열 필드가 붙는다**(01 §1-5). 짝이 없으면 계약 결함으로 보고하고 화면이 문구를 짓지 않는다.
5. **enum 직렬화는 `@JsonValue` 로 못 박는다** — Dart camelCase ↔ JSON·DDL SCREAMING_SNAKE_CASE. 신규 열거값은 **DDL `CHECK` → `@JsonValue` → 픽스처** 순서로 같은 커밋(01 §1-2 · C-15).

### 0-3. 코드 스타일 (루트 `analysis_options.yaml`)

- `dart analyze --fatal-infos` 통과 필수 · `pubspec` 의존 알파벳 순 · 파일 EOL = **LF**.
- 한국어 주석은 **문서 절 번호를 인용**한다(예 `// 01 §2-11 A8 — 버튼의 유일한 근거`).
- 빌드 생성물(`*.freezed.dart`·`*.g.dart`)은 커밋하지 않고 `melos.bat run build:gen` 으로 만든다.

---

## §1. ① 원시타입 — 영역 **A** · `lib/src/primitives/`

> 근거: 01 §1-2(금액) · §1-3(시각·날짜·신선도) · §2-1(봉투·구간).

| 파일 | 타입 | 표현 | 연산 금지 규약 |
|---|---|---|---|
| `money.dart` | `enum Currency { krw, usd }` | `'KRW'`·`'USD'` | — |
| `money.dart` | `@freezed class Money { Decimal amount; Currency currency }` + `Money.krw(String)`·`Money.usd(String)` | 🔴 **예약 타입 — 1차 릴리스 DTO 에서 쓰지 않는다**(P0S 는 전 금액 KRW). 통화는 상위 DTO 의 `currency` 축으로 표현 | 🔴 유일한 생성 경로는 **문자열**. `Decimal.fromDouble` / `Decimal.parse(d.toString())` 우회 금지 |
| `money.dart` | `extension type const Ratio(double value) {}` | 비율·스코어 | 🔴 산술 연산자를 정의하지 않는다 |
| `money.dart` | `extension type const TradeDate(String yyyyMmDd) {}` | 시장 **현지** 거래일 `'YYYY-MM-DD'`(US 는 ET · KST 환산 금지) | 🔴 **날짜 산술 없음** — «다음 거래일»·«D-6» 은 거래소 캘린더를 아는 엔진만 판정(M1-6) |
| `money.dart` | `abstract interface class Clock { DateTime nowUtc(); }` | 구현체 주입은 `data_sync` | 🔴 화면이 이 값을 쓰는 자리는 **전 앱에서 하나** — `observedAt + staleAfter < clock.nowUtc()`(신선도 배너). 카운트다운·경과·D-day·TTL 잔여는 엔진 문자열 |
| `money.dart` | `class DecimalStringConverter implements JsonConverter<Decimal, String>` | `fromJson` = `Decimal.parse` · `toJson` = `d.toString()` | 🔴 **필드 어노테이션이다** — 메서드 인자에 붙여도 아무 일도 하지 않는다(§4-2 조문) |
| `money.dart` | `class DurationSecondsConverter implements JsonConverter<Duration, int>` | JSON 키는 `*_seconds` | — |
| `as_of.dart` | `enum AsOfSource { localSqlite, supabaseMirror, archive }` | `'LOCAL_SQLITE'`·`'SUPABASE_MIRROR'`·`'ARCHIVE'` | — |
| `as_of.dart` | `@freezed class AsOf` | 필드 = `observedAt`(UTC, required) · `tradeDate`(`TradeDate`, required) · `source`(required) · `staleAfter`(`Duration` + `@DurationSecondsConverter()`, required) · `label`(String, required — 「잔고 기준 2026-09-05 종가」) · `staleReasonCode`(String?) · `staleLabel`(String?) | 🔴 **UTC `DateTime` 필드는 정렬·비교용이지 표시용이 아니다.** 화면이 시각을 포맷하는 자리는 `TzInstant` 가 실린 필드뿐 |
| `as_of.dart` | `@freezed class TzInstant { DateTime utc; String tzName }` | `tzName` 기본 `'Asia/Seoul'` | 화면은 `tzName` 으로만 포맷한다 |
| `list_result.dart` | `@freezed class ListResult<T>` | `rows`(List\<T\>, **엔진이 이미 정렬**) · `asOf` · `emptyKind` · `emptyLabel`(String?) · `hasMore`(bool) | 🔴 화면 재정렬 금지. 빈 목록에도 네 값이 실린다(계약 3조 ③) |
| `date_range.dart` | `@freezed class DateRange` | `from`·`to`(`TradeDate`) · `presetCode`(String?) · `label`(String?) | 🔴 화면이 날짜 산술로 만들지 않는다 — 프리셋 창구는 `ConfigRepository.watchRangePresets()` **하나**(G-38) |

> 🔴 **`AsOfStamp` 라는 타입은 실재하지 않는다.** 화면 명세들의 «기준일 고지»는 전부 `AsOf` 하나이며 표시 문구는 `label` 이다(01 §1-3).
> 🔴 **신뢰 시각**(리스 TTL·킬스위치 48h·냉각 30일)은 **Supabase 서버 시각**이다. 로컬 시계로 마찰 카운트다운을 만들지 않는다.
> ⚠️ `Money` 는 정의하되 **§2·§4 의 어떤 DTO 필드에도 쓰지 않는다**. 산술 차단은 `Money` 유무가 아니라 C-4(`Decimal` 필드까지 탐지)가 한다.

---

## §2. ② 열거형 전량 — 영역 **A** · `lib/src/enums/`

> 🔴 **52종 전부 A 가 만든다.** `CommandKind`·`CommandState`·`SettingsActionId` 도 여기다(D 는 import 만 한다) — 열거형이 두 영역에 흩어지면 `@JsonValue` 규약의 소유자가 둘이 된다.
> 🔴 표의 «DB» 열이 비어 있으면 **DDL `CHECK` 에 대응 컬럼이 없다**(뷰모델 전용). 값이 있으면 §7 DDL 의 `CHECK` 와 **문자 그대로 일치**해야 하며 불일치는 C-15 가 잡는다.

### 2-1. `sleeve.dart` — 슬리브·기준 축

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `SleeveId` | `a, b, c, pot, cash, satellite` | `A`·`B`·`C`·`POT`·`CASH`·**`SAT`** | 01 §2-1 · §6-1 CHECK. 🔴 `satellite` ↔ `'SAT'` 은 **기계적 대문자 변환이 아니다** — `@JsonValue('SAT')` 로 못 박는다. 🔵 v2.31 P0S 에서 `satellite` 는 **열거값 보존·화면 미노출**(목록은 `SleeveCatalogEntry` 가 준다) |
| `AllocationBasis` | `engineColumn, accounting` | `ENGINE_COLUMN`·`ACCOUNTING` | 01 §2-1 P 회차. 🔴 `SleeveWeight.basis` 는 **`accounting` 외 값을 갖지 않는다**(엔진 쪽 계약). `engineColumn` 은 진단 전용 별도 창구로만 |

### 2-2. `mode.dart` — 3축(직교)

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `RunMode` | `simInternal, simBroker, live` | `SIM_INTERNAL`·`SIM_BROKER`·`LIVE` | 01 §2-1·§9-1. 🔴 «어느 계좌·어느 서버인가». ⚠️ **배치 A·B 의 기존 `CHECK (mode IN ('SIM','LIVE'))` 는 3값으로 넓힌다**(§9-5 ④ 권고 = 3값 + 파일별 CHECK) — 확정 사항은 `m2-8_naming.md` D-2 |
| `ExecPolicy` | `dryRun, execute` | `DRY_RUN`·`EXECUTE` | 01 §9-5 ① · §10-1. 🔴 **`FeatureFlags` 에 넣지 않는다** — 화면이 3축을 곱해 분기한다. 구 `order_intents.dry_run` 의 «이름만 바꾼 것»이며 컬럼은 그대로 |
| `OperatingMode` | `autoTrade, advisory` | `AUTO_TRADE`·`ADVISORY` | 01 §2-1·§10-1 · X7 ③ 3-1. 🔴 «누가 집행하는가». 🔴 **엔진의 어떤 안전 강등도 이 값을 건드리지 않는다**(강등은 `ExecPolicy` 전용) |

### 2-3. `order.dart` · `ui.dart` — 주문·표시 공통

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `OrderSide` | `buy, sell` | `BUY`·`SELL` | 01 §2-1 · `advice.side` CHECK |
| `ChipTone` | `neutral, caution, blocked, prevented` | `NEUTRAL`·`CAUTION`·`BLOCKED`·`PREVENTED` | 01 §2-1. 🔴 `prevented` 는 **실패가 아니라 방어**다 |
| `GateState` | `pass, block, notApplicable, unknown` | `PASS`·`BLOCK`·`NOT_APPLICABLE`·`UNKNOWN` | 01 §2-1. 🔴 `unknown` ≠ `notApplicable` — X3 리스·기기 원장의 «모름»이며 **진행 차단**(04 §9-8) |
| `UiLevel` | `ok, info, watch, act, blocked` | `OK`·`INFO`·`WATCH`·`ACT`·`BLOCKED` | 01 §2-1. 🔴 **값의 부호로 색을 고르지 않는다** |
| `EmptyKind` | `noData, notLoaded, notApplicable` | `NO_DATA`·`NOT_LOADED`·`NOT_APPLICABLE` | 01 §2-1. «없는 것»·«못 받은 것»·«해당 없음»(계약 3조 ③) |

### 2-4. `journal.dart` — 일지·체결

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `JournalStatus` | `filled, partial, cancelled, rejected, unknown, skipped, prevented, reversed, restated` | `FILLED`·`PARTIAL`·`CANCELLED`·`REJECTED`·`UNKNOWN`·`SKIPPED`·`PREVENTED`·`REVERSED`·`RESTATED` | 01 §2-2. 🔴 `reversed`·`restated` = X7 §10-3 정정 규약. 🔴 C-12(default 없는 exhaustive switch)가 전 화면을 동시에 깨뜨리는 것이 **의도된 게이트** · 🆕 **v1.17(01 §26-8 · 엔진 D11 ② · ✅ 병합 PR #123 squash `0249f61`)** `expired`(`EXPIRED` · `cancelled` 뒤 · 일 마감 실효 = 취소 아님 · 잔량 이월 · 근거 칩 `JournalReasonCodes.dayEndExpired` · 표본 `m6/journal_expired_1` · 전 패키지 전수 switch 0 실측) |
| `FillVisibility` | `settled, pendingBatch, awaitingConfirm` | `SETTLED`·`PENDING_BATCH`·`AWAITING_CONFIRM` | 01 §2-2 · ⚠️ **초안값**(§8-8) — `m2-8_naming.md` A-1 확정 |
| `FillOrigin` | `broker, manual, simulated, brokerRecovered` | `BROKER`·`MANUAL`·`SIMULATED`·`BROKER_RECOVERED` | 01 §2-1 X7 · `executions.fill_origin` CHECK |
| `FillKind` | `original, reversal, restatement` | `ORIGINAL`·`REVERSAL`·`RESTATEMENT` | 01 §2-1 X7 · `executions.fill_kind` CHECK |
| `CostSource` | `broker, userEntered, estimated` | `BROKER`·`USER_ENTERED`·`ESTIMATED` | 01 §2-1 X7(C18) · `executions.cost_source` CHECK. 🔴 구 `costsOverridden`(bool) **폐기** |

### 2-5. `performance.dart` — 성과·세후

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `PerfMetric` | `twr, mwr` | `TWR`·`MWR` | 01 §2-4 · `rm_performance_point.metric`. 🔴 `twr` 은 **외부 현금흐름 보정판**이다(P 회차 실측 1.79%p 차) |
| `PerfGranularity` | `daily, weekly, monthly, yearly` | `DAILY`·`WEEKLY`·`MONTHLY`·`YEARLY` | 01 §2-4 |
| `SegmentKind` | `measured, unavailable, simExcluded, manualExecuted` | `MEASURED`·`UNAVAILABLE`·`SIM_EXCLUDED`·`MANUAL_EXECUTED` | 01 §2-4. 🔴 `manualExecuted` 는 `simExcluded` 와 달리 **합산에 포함**되고 경계는 실선(D6). 겹치면 `freshAuto` 절단선이 이긴다 |
| `TaxLadderBranch` | `specPotTaxFree, cfPotTaxableComp26, cfPotTaxableComp38, cfPotTaxableFlat` | `SPEC_POT_TAX_FREE`·`CF_POT_TAXABLE_COMP26`·`CF_POT_TAXABLE_COMP38`·`CF_POT_TAXABLE_FLAT` | 01 §2-4 · ⚠️ M2-8. 🔴 **갈래는 계좌 배치가 정한다**(SAF-309) — 화면·인자로 고르는 경로를 만들지 않는다 |

### 2-6. `rebalance.dart`

| 이름 | Dart 값 | JSON / DB | 근거 |
|---|---|---|---|
| `RebalanceKind` | `monthlyRegular, seasonal, band, regime, deposit` | `MONTHLY_REGULAR`·`SEASONAL`·`BAND`·`REGIME`·`DEPOSIT` | 01 §2-5 · `rebalance_event.kind` CHECK |
| `SleeveBandState` 🆕 v1.8 | `inBand, nearEdge, outOfBand` | `IN_BAND`·`NEAR_EDGE`·`OUT_OF_BAND` | 01 §17 · `SleeveAllocationRow.bandState`(색의 유일한 원천 · 🔴 판정 = 엔진 · 파킹은 상태가 아니다) |

### 2-7. `resume.dart` — X2 재개

| 이름 | Dart 값 | JSON / DB | 근거 |
|---|---|---|---|
| `PlannedWorkState` | `planned, reevaluated, superseded, expired, done, blocked` | `PLANNED`·`REEVALUATED`·`SUPERSEDED`·`EXPIRED`·`DONE`·`BLOCKED` | 01 §2-7 · `planned_work.state` CHECK |
| `ResumeMode` | `normal, conservative, recoveryDry, recoveryFull` | `NORMAL`·`CONSERVATIVE`·`RECOVERY_DRY`·`RECOVERY_FULL` | 01 §2-7 · `resume_run.mode` CHECK |
| `ResumePhase` | `r0 … r8`(9값) | `R0` … `R8` | 01 §2-7 · `resume_run.phase`(CHECK 없음 — 값 도메인은 이 열거형이 정본) |

### 2-8. `calendar.dart` — X4

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `CalendarOrigin` | `live, archive, brokerRecovered, inferred, manualEntry` | `LIVE`·`ARCHIVE`·`BROKER_RECOVERED`·`INFERRED`·`MANUAL_ENTRY` | 01 §2-8 · `calendar_event_log.origin` CHECK(G-28 배치 E 재작성). 🔴 `MANUAL_ENTRY` 가 없으면 수기 체결 이벤트가 `QUARANTINED` 로 빠지고 `canonCalendar` 가 매일 불일치 |
| `CalendarEventKind` | `execution, orderAccepted, orderRejected, orderCancelled, rebalance, cashFlow, safety, system, dailySummary, engineDown, executionCorrection` | `EXECUTION`·`ORDER_ACCEPTED`·`ORDER_REJECTED`·`ORDER_CANCELLED`·`REBALANCE`·`CASH_FLOW`·`SAFETY`·`SYSTEM`·`DAILY_SUMMARY`·`ENGINE_DOWN`·`EXECUTION_CORRECTION` | 01 §2-8(C11). 🔴 정정 2행을 «체결» 3건으로 그리지 않는다 |

### 2-9. `ledger.dart` — X5 정합 · 신뢰

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `LedgerPair` | `canonBroker, canonSupabase, canonGithub, canonCalendar, canonSelfReport` | `CANON_BROKER`·`CANON_SUPABASE`·`CANON_GITHUB`·`CANON_CALENDAR`·`CANON_SELF_REPORT` | 01 §2-9 · `ledger_diff.pair` CHECK **재작성 N-01**(4값→5값). 🔴 재작성 없이 `applicable=0` 의 `CANON_SELF_REPORT` 행을 넣으면 CHECK 위반으로 보드가 4칸으로 퇴화 |
| `LedgerAxis` | `quantity, executionRow, cash, chainHash` | `QUANTITY`·`EXECUTION_ROW`·`CASH`·`CHAIN_HASH` | 01 §2-9 · `ledger_diff.axis` CHECK |
| `DiffSeverity` | `blocking, observational` | `BLOCKING`·`OBSERVATIONAL` | 01 §2-9 · CHECK |
| `DiffStatus` | `open, resolved, accepted` | `OPEN`·`RESOLVED`·`ACCEPTED` | 01 §2-9 · CHECK |
| `RepairRoute` | `auto, approval, x1Emergency` | `AUTO`·`APPROVAL`·`X1_EMERGENCY` | 01 §2-9 (DDL 대응 컬럼 없음 — 뷰모델 파생) |
| `LedgerTrustGrade` | `reconciled, selfReported, drifting, unverifiable` | `RECONCILED`·`SELF_REPORTED`·`DRIFTING`·`UNVERIFIABLE` | 01 §2-1 X7. 🔴 `selfReported` 는 **실패가 아니라 정상 운영 상태**다 |
| `LedgerEventKind` ✅ v1.10(설계 13 §8 R21 · 구 ⏸) | `withdrawal, distribution, corporateAction, taxWithheld` | `WITHDRAWAL`·`DISTRIBUTION`·`CORPORATE_ACTION`·`TAX_WITHHELD` | 01 §2-1 · X7 ③ 3-1. ⏸ 🔴 **결정 ㊲ 채택 시에만 신설** — 지금은 파일에 **주석으로만** 남기고 코드로 만들지 않는다 |
| 🆕 `CorporateActionType` | `split, reverseSplit` | `SPLIT`·`REVERSE_SPLIT` | 01 §19 · `ledger_event.action_type` CHECK(v1 = 분할·병합만 · R21 L5) |
| 🆕 `MarketDataSource` v1.14 | `seedBundle, kis, fred, fredCsv, ofr, manual` | `SEED_BUNDLE`·`KIS`·`FRED`·`FRED_CSV`·`OFR`·`MANUAL` | 01 §22 · 배치 G `market_series`·`fetch_log`·`daily_prices` `source` CHECK(C-15) · 화면 미사용 |
| 🆕 `CashFlowKind` | `deposit, withdrawal, distribution, taxWithheld, cashInLieu` | `DEPOSIT`·`WITHDRAWAL`·`DISTRIBUTION`·`TAX_WITHHELD`·`CASH_IN_LIEU` | 01 §19 · `cash_flow.kind` CHECK(배치 F 재작성) · 🔴 TWR 외부 흐름 = `isExternal`(입금·출금만) |

### 2-10. `safety.dart` — 알림·브레이커

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `AlertLevel` | `p0, p1, p2` | `P0`·`P1`·`P2` | 01 §2-10. 🔴 **표시 계층의 사적 재분류 금지**(결정 7c) · 배치 E 가 구 `INFO`/`ALERT`/`DIGEST` 를 이 3값으로 개편 |
| `BreakerLevel` | `normal, alert, reduced, halted, stopped` | `NORMAL`·`ALERT`·`REDUCED`·`HALTED`·`STOPPED` | 01 §2-10 |
| `ClearRoute` | `automatic, causeCodeRequired, noManualPath, wizardOnly` | `AUTOMATIC`·`CAUSE_CODE_REQUIRED`·`NO_MANUAL_PATH`·`WIZARD_ONLY` | 01 §2-10·§3-5 |

### 2-11. `onboarding.dart` — X3

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `OnboardingTrack` | `fresh, reconnect, viewerPairing` | `FRESH`·`RECONNECT`·`VIEWER_PAIRING` | 01 §2-10 · `onboarding_progress.track` CHECK |
| `StepRequirement` | `required_, recommended, optional` | `REQUIRED`·`RECOMMENDED`·`OPTIONAL` | 01 §2-10. 🔴 `required_` 의 트레일링 언더스코어는 **Dart 예약어 회피**이며 `@JsonValue('REQUIRED')` 로 못 박는다(기계 변환하면 `REQUIRED_` 가 되어 픽스처와 갈린다) |
| `StepState` | `notStarted, inProgress, verified, failed, expired` | `NOT_STARTED`·`IN_PROGRESS`·`VERIFIED`·`FAILED`·`EXPIRED` | 01 §2-10 · `onboarding_progress.state` CHECK |

### 2-12. `advice.dart` — X7 안내·기록·전환

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `AdviceStatus` | `open, partial, filled, skipped, expired, superseded, revoked` | `OPEN`·`PARTIAL`·`FILLED`·`SKIPPED`·`EXPIRED`·`SUPERSEDED`·`REVOKED` | 01 §2-1 · `advice.status` CHECK. 🔴 terminal 4종은 어떤 경로로도 되살아나지 않는다 |
| `AdviceKind` | `entry, exit, rebalance, deposit, withdrawal, funding, noAction` | `ENTRY`·`EXIT`·`REBALANCE`·`DEPOSIT`·`WITHDRAWAL`·`FUNDING`·`NO_ACTION` | 01 §2-1(G-08) · `advice.kind` CHECK. 🔴 `noAction` 행의 NULL 허용 범위는 §6-6 조문이 정한다(둘뿐) |
| `AdviceSkipReason` | `priceUnacceptable, cashShort, intentionalPause, brokerIssue, misissued, other` | `PRICE_UNACCEPTABLE`·`CASH_SHORT`·`INTENTIONAL_PAUSE`·`BROKER_ISSUE`·`MISISSUED`·`OTHER` | 01 §2-1. 🔴 «유효기한 방치»는 **여기 없다**(사람이 고르는 값이 아니라 엔진 전이). `other` 는 1줄 필수 |
| `AdviceActionId` | `record, skip, detail` | — (**뷰모델 전용 · JSON 표기 없음**) | 01 §2-1(A8) · X7 ③ 3-1. ⚠️ `deferConfirm` 흡수 여부는 M2-8(§8 미결 30) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** — `detail` 은 남되 엔진이 싣지 않는다(K5 · 상세 = `AdviceItem.detailDeepLink`) · 「내일 다시」 = 열거값이 아니라 명령 `deferAdviceConfirm`(K14 ⓐ) · `actionId` = ui 미참조(버튼 = `label` + `deepLink`) |
| `HoldingScope` | `managed, external` | `MANAGED`·`EXTERNAL` | 01 §2-1 · `rm_holding.scope` |
| `HandoverPath` | `simToAuto, freshAuto, adoptLedger, handbackManual` | `SIM_TO_AUTO`·`FRESH_AUTO`·`ADOPT_LEDGER`·`HANDBACK_MANUAL` | 01 §2-1 · `handover_session.path` CHECK. 🔴 «안내 개시»는 여기 없다(별도 게이트 `M5-10`) |
| `CredentialUse` | `reconcileOnly, full` | `RECONCILE_ONLY`·`FULL` | 01 §2-1 · `credential_registry.usage` CHECK. 🔴 브로커 속성이 아니라 **앱 측 런타임 봉인 선언** |
| `SelfReportPurpose` | `periodicAudit, simOpening` | `PERIODIC_AUDIT`·`SIM_OPENING` | 01 §4-2(N-2) · ⚠️ 이름 M2-8(§8 미결 32). 🔴 **기본값을 두지 않는다** |
| `SeasonalEntryGateState` | `octPassed, deferredToNov, enteredInNov, deferredToDec, forcedEntryDec` | `OCT_PASSED`·`DEFERRED_TO_NOV`·`ENTERED_IN_NOV`·`DEFERRED_TO_DEC`·`FORCED_ENTRY_DEC` | 01 §3-7 · ⚠️ M2-8. 🔴 상태 5 : 사유 코드 3 의 비대칭을 화면이 분기로 메우지 않는다 |

### 2-13. `command.dart` — 명령·설정 동작 (🔴 A 가 소유 · D 가 import)

| 이름 | Dart 값 | JSON / DB | 근거 · 주의 |
|---|---|---|---|
| `CommandKind` | `killSwitchActivate, journalDraft, blindReviewScore, disclosureView, depositRegister, manualFillRecord, manualFillAmend, manualFillVoid, adviceSkip, selfReportBalance, alertAck, killChecklistConfirm, ledgerEventRecord`(🆕 v1.10 · ㊲) · `adviceDeferConfirm`(🆕 v1.12 · K14 ⓐ · 폰 전용 · 초안 영구 제외) | `KILL_SWITCH_ACTIVATE`·`JOURNAL_DRAFT`·`BLIND_REVIEW_SCORE`·`DISCLOSURE_VIEW`·`DEPOSIT_REGISTER`·**`RECORD_MANUAL_FILL`**·**`AMEND_MANUAL_FILL`**·**`VOID_MANUAL_FILL`**·**`SKIP_ADVICE`**·`SELF_REPORT_BALANCE`·`ALERT_ACK`·`KILL_CHECKLIST_CONFIRM`·`LEDGER_EVENT_RECORD`·`DEFER_ADVICE_CONFIRM`(`batch_d` CHECK +1) | 01 §4-2 · §6-6 배치 D 추가분 · 🆕 §19. 🔴 **X7 4종은 Dart 이름과 DB 값의 어순이 뒤집혀 있다**(`manualFillRecord` ↔ `RECORD_MANUAL_FILL`) — 기계 변환에 맡기면 `command_queue.kind` CHECK 위반이 런타임에 터진다. `@JsonValue` 로 못 박고 C-15 가 검사한다 |
| `CommandState` | `requested, received, executed, rejected, expired, staleContext, heldForIntegrity, pendingLeaseConfirm, noOperator` | `REQUESTED`·`RECEIVED`·`EXECUTED`·`REJECTED`·`EXPIRED`·`STALE_CONTEXT`·`HELD_FOR_INTEGRITY`·`PENDING_LEASE_CONFIRM`·`NO_OPERATOR` | 01 §4-2 · §6-2 `command_inbox.state` CHECK(G-30). ⚠️ `noOperator` 는 **M2-8 신설 후보**이며 현행 DDL CHECK 에 없다 → 열린 물음(§10-2) |
| `SettingsActionId` | `settingsGeneralUpdate, credentialVerify, credentialRegister, accountVerifyMapping, accountMapSleeve, strategyPreview, strategyApplyRequest, onboardingOperatingModeSelect, runtimeModeSwitchRequest, runtimeOperatingModeSwitchRequest, handoverAdoptionSet, handoverExternalRegister, handoverCommit, runtimeEngineStart, runtimeEngineStop, devicePairingTicketCreate, deviceTokenRevoke, connectionTest, connectionSyncNow, calendarSyncNow, calendarRebackfill, backupRunNow, backupRestoreStart, selftestGoldenRun, selftestIntegrityRun` + ⚠️ **M2-8 신설 2종** `settingsContributionUpdate`·`calendarReconnect` + 🆕 **v1.12(K9)** `selfReportSessionStart`·`selfReportSessionStop`(`L-3` 실사 세션 · `args` = `{yyyy_mm, account_alias}` · 가림 = 그 폰 한 대) + 🆕 **v1.16(01 §25 · K24 · ✅ 병합 PR #96 squash `dd9e162`)** `onboardingDryRunStart`(`ONBOARDING_DRY_RUN_START` · `O-04` ⑥ 전용 · `args` = `{}` · 첫 `committed_at` 과 같은 트랜잭션 · `runtimeEngineStart` 와 다르다 · M5·M8 전용 5값) + 🆕 **v1.18(01 §27 · K-s · ✅ 병합 PR #142 squash `b582c49`)** `notifyChannelSelect`(`NOTIFY_CHANNEL_SELECT` · M9 `S07` 알림 채널 선택 · `args` = `{channel ∈ NotifyChannelCodes}` · 05 §7 C22 · 🔴 `settingsGeneralUpdate` 로 태우지 않는다 — 채널은 안전장치의 일부) + 🆕 **v1.19(01 §28 · K6 · ✅ 병합 PR #163 squash `6b8ed02`)** `runtimeLivePromotion`(`RUNTIME_LIVE_PROMOTION` · M9 `S05` 첫 실전 주문 승격 `live × autoTrade × dryRun` → `execute` · `args` = `{}` · `RunModeCard.promotionAction` 에 엔진이 완성(관찰 중 ∧ 승격 가능일 때만) · 생체 1회 = operator 구현(기존 M5 게이트 다이얼로그 · 새 라우트 0) · `handoffRoute` null · 자동 승격 0) | SCREAMING_SNAKE(DDL CHECK 없음) | 01 §4-3. 🔴 **개수를 숫자로 적지 않는다**(G-91). `M9` 가 부르는 값은 05 §7 이 정본이고, **`M5`·`M8` 전용 4값**(`onboardingOperatingModeSelect`·`handover*` 3종)은 **이 파일이 정본**이다 — 05 §7 에 없다는 이유로 지우지 않는다 |

> 🆕 **v1.21(01 §30 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16)** — `SafetyActionId` `killSwitchResume, pledgeWrite, pledgeEdit` → `KILL_SWITCH_RESUME`·`PLEDGE_WRITE`·`PLEDGE_EDIT`(엔진 data_sync 명령 kind 글자 · 같은 글자 다른 축 주석 2 · `run` 화이트리스트 0 — 1.22.0 · K5 · K39) · `safety.dart` += `KillActivationReason{RULE, EMOTION}` · `KillActivationScope{NEW_ENTRIES_ONLY, LIQUIDATE_ALL}` · `KillResumeScenario{RESOLVED, ONGOING, NOT_APPLICABLE}` · `KillResumeCondition{MET, UNMET}`(값 이름 = 엔진 1:1 · 타입 이름 ≠ 엔진 · K10 · K33) — §5-6.

> 🆕 **v1.22(01 §31 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17)** — `SafetyActionId` +8 `stoppedDecision, postmortemRecord, reconClear, interventionStep, discretionAdjust, ruleChangeCancel, ruleChangeApprove, seasonalWindowChoice` → `STOPPED_DECISION`·`INCIDENT_POSTMORTEM`·`RECON_CLEAR`·`INTERVENTION_STEP`·`DISCRETION_ADJUST`·`RULE_CHANGE_CANCEL`·`RULE_CHANGE_APPROVE`·`SEASONAL_WINDOW_CHOICE`(사람 글·수 넷 = 제출 DTO 메서드 · 엔진 완성 넷 = `run` 화이트리스트 · K52) · `SettingsActionId` +3 `handoverSessionStart, handoverSessionCancel, handoverSimLedgerFate` → `HANDOVER_SESSION_START`·`HANDOVER_SESSION_CANCEL`·`HANDOVER_SIM_LEDGER_FATE`(M5-11 simToAuto 위저드 · 🔴 fate = 세션 전 · 확정 = 기존 `handoverCommit` · K56 — 이 파일이 정본인 M5 전용 값) · 열거 3 `StoppedDecisionChoice{a, b, c}`(`A`·`B`·`C`) · `InterventionStepOutcome{passed, doNothing, abandoned}`(`PASSED`·`DO_NOTHING`·`ABANDONED`)(둘 다 `enums/safety.dart`) · `SeasonalEntryChoice{skip, reduced, asIs}`(`SKIP`·`REDUCED`·`AS_IS` · `enums/resume.dart`)(값 이름·와이어 = 엔진 1:1 · 🔵 타입 이름 ≠ 엔진 — `ambiguous_import` · K49) · `RuleChangeType` 미등재(K50 — 들일 때 `RuleChangeCategory`) — §5-7.

> 🆕 **v1.23(01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — `SettingsActionId` 값 0 추가 · 기존 `settingsContributionUpdate`(`SETTINGS_CONTRIBUTION_UPDATE` · 운영 등급 · 05 `S13`) = 제출 경로 `SettingsActions.runContributionUpdate` 전용(`run` 화이트리스트 밖 · `run(settingsContributionUpdate)` = 구현 `ArgumentError` · K77) — §5-8.

> 🆕 **v1.25(01 §34 · ~~⬜ PR 대기~~ ✅ 병합 PR #256 squash `233adda8`(2026-11-19 · CI 3/3))** — `CommandApi.activateKillSwitch()` 인자 0(구 `{reasonFreeText, deviceId}` · K149) · 창구 `KillSwitchGateRepository.watchKillSwitch()` · 🆕 `BlockBoardRepository.watchBoard()` · `ResumeGateRepository.watchReport()` · `SettingsActionId`·`SafetyActionId` 값 0 추가.
>
> 🆕 **v1.26(01 §35 · ~~⬜ PR 대기~~ ✅ 병합 PR #270 squash `09d3580d`(2026-11-20 · CI 3/3))** — 🆕 `HandoverRepository.watchWizard()`(`M5-11` · `handoverStatus` 같은 본문) · 🆕 `RuleChangeGateRepository.watchGate()`(`M5-9` 첫 승인 최소판) · `SafetyActions` 표면 8 → 10(`runRuleChangeRequest` · `runReconClear`) · `run` 화이트리스트 4 → 3(`reconClear` 뺌) · `BlockBoardRow` += `reconClear` · 사전 저널 꼴(제출 DTO 3필드 + 구현이 id).
>
> 🆕 **v1.27(01 §36 · ~~⬜ PR 대기~~ ✅ 병합 PR #274 squash `551282e0`(2026-11-20 · CI 3/3))** — 계약 창구 · DTO 0 · 🆕 `AlertCodes.safetyWarn` 4 · `derivedSync` 1(엔진 등재형 · `values` 31 → 36 · 아래 §6-9 알림 절) · 픽스처 359 → 360(신설 1 `m8/alerts_engine_proposals_v127`) · 🆕 C-61 · SAF-307 «초과 일수» = 계약 칸 0(월간 리포트 `D2_ALLOCATION` 메모 · 01 §8 미결 209).
>
> 🆕 **v1.28(01 §37 · ~~⬜ PR 대기~~ ✅ 병합 PR #282 squash `9c7ff349`(2026-11-20 · CI 3/3))** — `SettingsRepository.watchAllocationEditor()`(S04 첫 판 · 폰 · 뷰어 공통 · 받침대 동기 throw) · 🆕 DTO 4(`AllocationEditorVm` · `AllocationProfileCard` · `AllocationReadOnlySection` · `AllocationReadOnlyRow` · `dto/allocation.dart`) · 쓰기 0.
>
> 🆕 **v1.29(01 §39 · E11k-b 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #288 squash `b979ae33`(2026-11-21 · CI 3/3))** — 창구 · DTO · 동작 0 · o_07 ② = 슬롯 🆕 `SECRET_SUPABASE_CONNECT` + 기존 `connectionTest{target: SUPABASE}`(1단 · 결과 `reasonCode` ∈ `SupabaseInputResultCodes` ∪ `SupabaseTimeResultCodes` 망 5 ∪ null) · 🔴 o_07 VERIFIED = 쓰기-읽기 왕복 뒤 · 🆕 `schema/supabase_rpc.dart` 리스 RPC 표 · DDL `app_device.auth_uid`.
>
> 🆕 **v1.30(01 §38 · E16i 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #293 squash `2fdfefb5`(2026-11-21 · CI 3/3))** — 창구 · DTO · 동작 · 라우트 0 · 🆕 사전 25무리 · 상수 103(아래 §6-9 코드 절) · 🆕 `SafetyHoldCodes.migrationInProgress`(표시 hold) · E16j VM = 다음 판(01 §8 미결 211).
>
> 🆕 **v1.31(01 §40 · E11k-d2 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #298 squash `922df462`(2026-11-21 · CI 3/3))** — 창구 · DTO 0 · 🆕 `SettingsActionId.supabaseSignIn`(args `{}` · o_07 ③ · 1단 · 결과 `reasonCode` ∈ `SupabaseAuthResultCodes` ∪ `SupabaseTimeResultCodes` 전송 6 ∪ null) · 🆕 슬롯 `SECRET_SUPABASE_LOGIN`(② 통과 뒤 같은 단계에서 ② 슬롯 대신 · VM 칸 0) · 🔴 로그인 통과 = `IN_PROGRESS`(VERIFIED = 왕복 뒤).
>
> 🆕 **v1.32(01 §41 · E16j-a 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #299 squash `268d6bff`(2026-11-21 · CI 3/3))** — 🆕 `RepairWizardRepository.watchRepair({targetId})`(X5 정정 마법사 · 허브 = null · 폰 전용 · `ui_safety` 만) · 🆕 DTO 5(`RepairWizardVm` · `RepairOriginChoice` · `RepairStageRow` · `RepairCorrectionForm` · `RepairFillChoice` · 탐지 근거 = `LedgerDiffRow` 재사용) · `SafetyActions` 표면 10 → 13(`runRepairCorrect` · `runRepairBaseline` · `runInterventionJournal` · 제출 DTO 3) · `SafetyActionId` +4 · `run` 화이트리스트 3 → 4(`repairAccept{diff_id}`) · 🆕 라우트 `x5RepairTarget`(`all` 85) · 🔴 엔진 결속 · VM 생산 = 01 §8 미결 217.
>
> 🆕 **v1.33(01 §42 · E16j-b 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #305 squash `ec203163`(2026-11-21 · CI 3/3))** — 🆕 `MigrationRepository`(`watchPlanWizard` · `watchPlanRecovery` · `watchEmergencyRecovery` · 폰 전용 · `ui_safety` 만) · 🆕 DTO 8(`X1PlanWizardVm` · `X1RecoveryVm` · `X1StepRow` · `X1TicketCard` · `X1FencingCard` · `X1ReissueRow` · `X1RestoreCard` · `X1GateCard` · D-03 = `EmergencyCardVm` 재사용) · `SafetyActionId` +6 · `run` 화이트리스트 4 → 10(`x1PlanStart{}` · `x1PlanStep` · `x1PlanAbort` · `x1EmergencyStart{}` · `x1ReissueRecord` · `x1RecoveryStep`) · `SafetyActions` 표면 무변경 · 라우트 · 인자 신설 0(X1 셋 주석 정정) · 🔴 VM 생산 · 진행기 · 저장 · 백업 원천 = 01 §8 미결 218.

> 🆕 **v1.24(01 §33 · ✅ 병합 PR #235 squash `bbed5ef` · 2026-11-18 · R8a 병합 뒤)** — `SettingsActionId` 값 0 추가 · args 화이트리스트 `backupRunNow`·`selftestGoldenRun`·`selftestIntegrityRun` = `{}` · `backupRestoreStart` = 화면 미호출(args 미정 유지) · calendar 3 = ⏸ R9d · `settingsGeneralUpdate` = ⏸ R9e(K120).

> 🔴 **`SettingsActionId` 는 「05 §7 에 없는 값 4개」를 포함한 상태가 정상이다.** 지우면 G-01·G-03 이 닫은 구멍(위저드·온보딩의 쓰기 경로 부재)이 되살아난다.
---

### 2-14. 🆕 v1.17 `incident.dart` · `handbook.dart` (01 §26 · ✅ 병합 PR #123 squash `0249f61`)

| 이름 | Dart 값 | JSON | 근거 · 주의 |
|---|---|---|---|
| `IncidentKind` | `phoneDown, networkDown, tokenExpired, orderRejected, other` | `PHONE_DOWN`·`NETWORK_DOWN`·`TOKEN_EXPIRED`·`ORDER_REJECTED`·`OTHER` | `D-01` 배너 · 🔴 **아이콘 선택에만**(문구·조치 = 데이터) · 모르는 wire = `other`(`@JsonKey(unknownEnumValue: IncidentKind.other)` · C-51) |
| `HandbookEntryState` | `ready, preparing, archived` | `READY`·`PREPARING`·`ARCHIVED` | `B-01` 목차 항목 상태 · 기본 `ready`(`@Default`) · 글자 = `stateLabel`(엔진) |

### 2-15. 🆕 v1.18 `settings.dart` (01 §27 · ✅ 병합 PR #142 squash `b582c49`)

| 이름 | Dart 값 | JSON | 근거 · 주의 |
|---|---|---|---|
| `SettingTier` | `general, operational, rule` | `GENERAL`·`OPERATIONAL`·`RULE` | M9 설정 3등급(05 §1 · K-o) · `SettingsGroup.tier` · 🔴 **자물쇠 아이콘·묶음 머리에만**(`general` = 자물쇠 0) · 등급별 마찰(진입 생체 · 냉각 · 12월 창) = 엔진·M5 게이트 · 묶음 차례 = 엔진 |

## §3. ③ DTO 전량

> 표기: **R** = required · **?** = nullable · `@D` = `@DecimalStringConverter()` · `@Def(x)` = `@Default(x)`.
> 🔴 전부 `@freezed` 불변이며 **계산 getter 0건**. 🔴 «필드 근거» 열이 비어 있으면 01 의 해당 절 본문이 근거다.

### 3-1. 영역 **B** — `lib/src/dto/common.dart` (01 §2-1)

| 타입 | 필드 |
|---|---|
| `ReasonChip` | `code` R String(`'TIER_1B'`·`'SAF309_ACCOUNT_UNVERIFIED'`·`'REBALANCE_BAND'`) · `label` R String(**엔진 생성**) · `tone` R `ChipTone` · `detailDeepLink` ? String(`'handbook://exit/tier1b'`) |
| `DecisionRef` | `decisionId` R String · `parentDecisionId` ? String(X2 재판정 child) · `intentId` ? String · `brokerOrderNo` ? String · `executionId` ? String · `configHash` R String |
| `GateBadge` | `code` R String · `label` R String · `state` R `GateState` · `blockedReasonCode` ? String |
| `FeatureFlags` | `satelliteEnabled` R bool · `webViewerEnabled` R bool(Q-D 미결) · `calendarEnabled` R bool(X4 채택 미결) · `runMode` R `RunMode` · `operatingMode` R `OperatingMode`(⚠️ `@Def(OperatingMode.autoTrade)` 부여 여부 = M2-8 §8-19) · `configHash` R String. 🔴 **`ExecPolicy` 를 넣지 않는다**(§10-1) |
| `SleeveCatalogEntry` | `sleeve` R `SleeveId` · `label` R String(「A · KOSDAQ 지수 ETF」) · `rollsUpTo` ? `SleeveId`(POT → A, 회계 소속 03 §2-9-3) · `order` R int |
| `ThresholdCompare` 🆕 v1.6 이동 | `metricKey` R · `metricLabel` R · `observedText` R · `thresholdText` R String · `passed` R bool · `verdictLabel` R String(m2-8 E-2 · 🔴 수치는 전부 엔진 포맷 문자열) — 🆕 **v1.6(01 §15-4)** `dto/journal.dart` → `dto/common.dart` 로 옮겼다(이름·필드·JSON·배럴 export 무변경 · J-2 `DecisionDetailVm.thresholds` 와 `S7-6b` `RebalanceEvent.thresholds` 가 같은 타입 — `journal.dart` 가 이미 `rebalance.dart` 를 import 하므로 순환을 피한다) |

> 🔴 **슬리브 목록은 플래그가 아니라 `SleeveCatalogEntry` 목록으로 온다** — 화면이 `SleeveId` 를 순회하며 `satellite` 를 걸러내는 코드를 쓰지 않게(거르는 규칙이 화면에 생기면 그것이 판정이다).

### 3-2. 영역 **B** — `lib/src/dto/journal.dart` (01 §2-2 · §2-11 일부)

| 타입 | 필드 |
|---|---|
| `TradeJournalEntry` | `entryId` R String · `mode` R `RunMode` · `tradeDate` R `TradeDate` · `executedAt` ? DateTime(UTC · null = 미체결) · `symbol` R String · `symbolLabel` R String · `sleeve` R `SleeveId` · `side` R `OrderSide` · `quantity` R int · `price` R `@D Decimal` · `commission` R `@D Decimal` · `tax` R `@D Decimal` · `status` R `JournalStatus` · `statusLabel` R String · `statusTone` R `ChipTone` · `visibility` R `FillVisibility` · `visibilityLabel` R String · `reasons` R `List<ReasonChip>`(**최소 1개**) · `decision` R `DecisionRef` · `deviation` R `DeviationBadge` · `accountAlias` ? String(🔴 계좌 전체번호 금지) · **X7 신설 6** `fillOrigin` R `FillOrigin` · `fillKind` R `FillKind` · `adviceId` ? String · `backdate` R `BackdateStamp` · `costSource` R `CostSource` · `costSourceLabel` R String · `originLabel` R String · `rebalanceEventId` ? String(G-40 · null = 회차 밖 · 🆕 v1.5 주석(01 §15-3) — deposit 회차의 체결은 그 회차에 묶인다 · advisory 수기 체결도 그 회차에 묶인다(결정 ④-2 · 엔진 숙제 06 X7-1)) · `asOf` R `AsOf` |
| `DeviationBadge` | `isDeviation` R bool · `kindCode` ? String · `label` R String · `journalId` ? String |
| `BackdateStamp` 🆕X7 | `tradeDate` R `TradeDate` · `authoredAt` R DateTime · `backdateTradingDays` R int · `isBackdated` R bool · `label` R String · `priceRangeSourceDate` R `TradeDate`(B4 — 검증의 근거일) · `crossesClosedPeriod` R bool · `closedPeriodNote` ? String |
| `JournalRebalanceScope` 🆕 v1.5 | `rebalanceEventId` R String(키 용 · 🔴 표시 금지) · `label` R String(회차 칩 글자 · 엔진 생성 · 🔴 식별자를 담지 않는다) · `range` R `DateRange`(씨앗 기간 = 그 회차에 묶인 일지 행 **전부**를 덮는 구간 · 프리셋이 아니다 — `presetCode` null · `isDefault` false · 🔴 화면은 첫 쿼리의 `range` 로 그대로 쓴다 · 날짜 산술 0)(01 §15-3 · 발주자 결정 ⑥) — `J-1` 회차 조건의 **범위 설명** · 창구 = `JournalRepository.watchRebalanceScope` · 🔴 시트 선택지가 아니다(그래서 `*Option` 꼴이 아니다 · 시트 상태 필드 신설 금지 — A14) · 🔴 화면이 `rebalanceEventId`·`RebalanceEvent.kindLabel`·`tradeDate` 로 글자를 만들지 않는다 |
| `BlindReviewCard` 🆕 v1.7 개정 | `decisionId` R String(키 · 🔴 표시 금지 · 제출 `BlindReviewScore.decisionId` 에 그대로) · 🆕 `titleText` R String(«2026-08-11 · 0085P0 KODEX 국고채30년 · 매수 결정» · 엔진 생성 · 🔴 금액·수량·가격·수익률·손익 없음) · `promptText` R String · 🆕 `contextChips` R `List<ReasonChip>`(`JournalDraftFormSpec.contextChips` 와 같은 사전 · 🔴 칩 링크 = `handbook://` 이거나 null) · 🆕 `deviation` R `DeviationBadge`(표시만) · 🆕 `journalStateLabel` R String · 🆕 `journal` ? `DecisionJournalBody`(null = 본문 블록 부재) · `questions` R `List<BlindReviewQuestion>`(받은 순서 · 3~5) · 🆕 `result` ? `BlindReviewResult`(🔴 null = 채점 전 — 대기 목록의 행은 늘 null · 엔진은 채점 집행 **뒤에만** 싣는다) · 🆕 `asOf` R `AsOf`(관측 시각 · v1.6 뜻)(01 §16 · §8 미결 46) — 창구 = `watchBlindReviewQueue`(대기 목록) · `watchBlindReviewCard`(1건) · 🔴 화면은 `result` 의 null 여부 **하나로만** 결과 섹션을 그린다(접수증 상태로 공개 판정 0) · 🔴 `result`·`asOf` 밖 필드는 채점 전·후 같다(C-43 ④) · 🔴 앱 안 링크는 `result` 안에만(K8) |
| `BlindReviewQuestion` 🆕 v1.7 개정 | `questionId` R String(키 · `BlindReviewScore.answers` 의 키) · `text` R String · 🆕 `evidenceText` ? String(판단 근거 한 줄 · null = 줄 부재 · 🔴 결과·손익 없음) · `choices` R ~~`List<ReasonOption>`~~ 🆕 `List<BlindReviewChoice>`(점수를 싣는 선택지 · 받은 순서) |
| `BlindReviewChoice` 🆕 v1.7 | `score` R int(🔴 엔진이 정한 값 — 화면은 고른 선택지의 `score` 를 `answers[questionId]` 에 **그대로 옮길 뿐** · 표시·합산·비교·변환 0 · 한 문항 안에서 서로 다르다 — C-43 ① ⑫) · `label` R String(«예»·«아니오» · 엔진 생성) |
| `BlindReviewResult` 🆕 v1.7 | `processScoreText` R String(«과정 점수 4점 — 좋은 결정(4점 이상)» · 엔진이 제출된 답에서 셈 · 🔴 화면 집계 0) · `outcomeText` R String(«결과: 수익률 +0.6% · 보유 12거래일» / «미청산 — 결과 미확정» · 🔴 금액(원) 0 — K6 확정 2026-10-20) · `detailLines` `List<String>`(`@Default` 빈 목록 · 0줄 = 블록 부재) · `decisionLink` ? `LinkAction`(「이 결정 보기」 → `J-2`) — 🔴 `LEDGER_INTEGRITY` 중에는 글자가 엔진 쪽에서 가려져 온다 |

- `DeviationBadge.kindCode` 의 값 목록(**문자열 상수 · 영역 E 의 사전이 정본**): 기존 4 = `DISCRETION`·`MANUAL_ORDER`·`RECON_CLEAR`·`KILL_SWITCH_RESUME` / X7 9 = `ADVICE_LAPSE`·`ADVICE_SKIP`·`ADVICE_LATE_FILL`·`MANUAL_ENTRY`·`ADVICE_PRICE_DEVIATION`·`ADVICE_QTY_DEVIATION`·`ADVICE_EXIT_AVOIDED`·`FILL_AMENDED`·`BACKDATED_FILL`.
- 🔴 **분할 집행 진도는 이 타입에 없다**(G-46 · §8 미결 29) — 「n일차」·「이월 n주」 필드를 만들지 않는다.
- 🔴 `status = prevented` 는 «이중 발주 차단 작동»이며 **성공으로 렌더**한다. `status = unknown` 은 UNKNOWN 해소 보드로 딥링크.

### 3-3. 영역 **B** — `lib/src/dto/holdings.dart` (01 §2-3)

| 타입 | 필드 |
|---|---|
| `HoldingRow` | `symbol` R · `symbolLabel` R · `sleeve` R `SleeveId` · `accountAlias` R String · `quantity` R int · `avgPrice` R `@D Decimal` · `entryDate` R `TradeDate` · `entryDecision` R `DecisionRef` · `entryReasons` R `List<ReasonChip>` · `smaTranches` R `List<TrancheStep>` · `gates` R `List<GateBadge>` · `stopLine` ? `StopLine` · `momentum` ? `MomentumPanel`(⚠️ M2-8 · v2.31 거의 항상 null) · `pnl` `@Def(null) HoldingPnl?` · **X7** `scope` R `HoldingScope` · `scopeLabel` R String · `asOf` R `AsOf` · 🆕 **v1.8(01 §17)** `holdingId` R String(불투명 · 🔴 표시·Key 금지 · 라우트 파라미터 전용 — B·POT 같은 종목) · `quantityText` R · `avgPriceText` R · `weightText` R String(가림 = 엔진 «?»·«숨김») · `pendingText` ? · `subBookLabel` ? · `detailDeepLink` ? String — 🔴 원값·키는 `H6-*` ui 미참조(C-44 ⑮) |
| `TrancheStep` | `stepNo` R int · `filled` R bool · `label` R String · `filledOn` ? `TradeDate` |
| `StopLine` | `absoluteStop` ? `@D Decimal`(TIER 1B) · `trailStop` ? `@D Decimal`(TIER 2) · `customStop` ? `@D Decimal`(TIER 1A · ⚠️ 1차 릴리스 항상 null) · `highWaterMark` ? `@D Decimal` · `label` R String |
| `HoldingPnl` | `unrealizedPnl` R `@D Decimal` · `pnlPct` R double · `disclosureNote` R String · 🆕 **v1.8(01 §17)** `pnlText` R String · `pnlPctText` R String(INTEGRITY «숨김» · 원값 2 는 ui 미참조 · `disclosureNote` 에 «열람 기록» 문구 금지 — 발주자 결정 ⑤) |
| `HoldingsOverviewVm` 🆕 v1.8 | `cards` R `List<HoldingsSleeveCard>`(🔴 카드 수 = 목록 길이 · 받은 순서) · `external` ? `HoldingsExternalSection`(null = 섹션 부재) · `allocationLink` ? `LinkAction`(→ `H6-3`) · `pnlToggleLabel` ? String(null = 토글 부재 · 뷰어 · K15) · `emptyLabel` ? String(non-null ⇔ `cards` 빈 · «없음» 전용 · K26) · `asOf` R `AsOf` — `H6-1` 한 화면 |
| `HoldingsSleeveCard` 🆕 v1.8 | `sleeve` R `SleeveId`(🔴 ui 미참조) · `titleText` R String · `allocation` R `SleeveAllocationRow`(카드 머리 = 같은 화면 `H6-3` 행과 같은 값) · `rows` R `List<HoldingRow>`(POT 행 = A 카드 맨 끝 · K17) · `rowsEmptyText` ? String |
| `HoldingsExternalSection` 🆕 v1.8 | `titleText` R · `noticeText` R String(접혀도 늘) · `bannerText` ? String · `rows` R `List<ExternalHoldingRow>`(비지 않는다 · K14) |
| `HoldingDetailVm` 🆕 v1.8 | `holding` R `HoldingRow` · `sleeveLabel` R String · `entryDecisionLink` R `LinkAction`(늘 있다 · K16 ⓔ) · `stopLines` R `List<StopLineNormalized>`(글자 행 · K3) · `noStopLineText` ? · `recentEntries` R `List<TradeJournalEntry>`(같은 보유 · 시간 역순 · K19) · `recentEmptyLabel` ? · `pnlToggleLabel` ? String · `asOf` R `AsOf` — `H6-2` 한 화면 |

- 🔴 **결정 8** — `HoldingPnl` 은 `watchHoldings(includePnl: true)` 일 때만 채워진다. 홈·알림·위젯·일지 타임라인에 이 타입을 렌더하면 **C-6 실패**.
- 🔴 **X7 D7** — 파생은 `positions` 만 읽는다. `external_holding`(= `scope == external`)의 표시 UNION 은 `HoldingsRepository` **한 곳**에서만 만든다(C-23).
- 🆕 **v1.8(01 §17 · R4 선행)** — 보유 화면 셋은 VM 하나씩만 그린다(`HoldingsOverviewVm` · `HoldingDetailVm` · `SleeveAllocationVm`) · 손절선 = 기존 `StopLineNormalized`(표시 정규화판 · `levelText` 정본) 글자 행(게이지 정규값 = 01 §8 미결 104) · 시스템 밖 행 = `ExternalHoldingRow`(`HoldingRow` 가 아니다 — 매수가·진입일·슬리브 원천 없음 · K14) · 계약 회귀 = **C-44**.

### 3-4. 영역 **B** — `lib/src/dto/resume.dart` (01 §2-7)

| 타입 | 필드 |
|---|---|
| `PlannedWorkSummary` | `workId` R · `digest` R String(sha256 앞 12자) · `oneLine` R String · `dueBy` R `TradeDate` · `state` R `PlannedWorkState` · `stateLabel` R String · `rowVersion` R int · `leaseEpoch` R int |
| `ResumeReport` | `resumeRunId` R · `startedAt` R DateTime · `finishedAt` ? DateTime · `gapTradingDays` R int · `mode` R `ResumeMode` · `modeLabel` R String · `phase` R `ResumePhase` · `counts` R `ResumeCounts`(⚠️ M2-8) · `items` R `List<ResumeItem>`(⚠️ M2-8) · `unrecoverableGaps` R `List<DataGapRow>`(⚠️ M2-8) · `headline` R String. 🔴 **손익 필드 없음** |

### 3-5. 영역 **B** — `lib/src/dto/calendar.dart` (01 §2-8)

| 타입 | 필드 |
|---|---|
| `CalendarEventDto` | `aaqKey` R String(멱등 원문 키) · `kind` R `CalendarEventKind` · `startUtc` R DateTime · `endUtc` ? DateTime · `allDay` R bool · `title` R String · `body` R String · `origin` R `CalendarOrigin` · `decisionId` ? String · `configHash` R String · `chainHash` ? String(G-09 — 🔴 `dailySummary` 에만) |

- 🔴 **화이트리스트 직렬화**: 타입에 아예 없음 = 손익·수익률·평가액·잔고·계좌 전체번호·시크릿.
- 🔴 **미래 시각 이벤트를 만들지 않는다**(예정 리밸런싱·월 납입 예정 금지). extendedProperties 는 **6키**(`aaq_key`·`kind`·`decision_id`·`origin`·`config_hash` + `chain_hash`).
- `kind ↔ source_table ↔ aaq_key` 매핑 9행은 01 §2-8 표를 그대로 쓴다(픽스처·매퍼의 입력). `advice`·`advice_batch`·`self_report_balance` 는 **캘린더에 내지 않는다**.

### 3-6. 영역 **B** — `lib/src/dto/ledger.dart` (01 §2-9)

| 타입 | 필드 |
|---|---|
| `LedgerDiffRow` | `diffId` R · `pair` R `LedgerPair` · `axis` R `LedgerAxis` · `authoredDate` R `TradeDate` · `deltaLabel` R String · `severity` R `DiffSeverity` · `candidateOriginCodes` R `List<String>`(§3-4 코드) · `status` R `DiffStatus` · `route` R `RepairRoute` · `evidenceHash` R String · **X7** `applicable` R bool(C15·G-27) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** +8 `pairLabel` R · `axisLabel` R · `severityLabel` R · `statusLabel` R · `routeLabel` R String · `candidateOrigins` R `List<ReasonChip>`(== 코드 순서) · `detectedAtText` R String · `actionLink` ? `LinkAction`(엔진이 고른다 — `route == approval` ∧ 폰 → `x5/repair-wizard` · `canonSelfReport` ∧ 폰 → `L-3` · 결과 안·뷰어 = null · K26) — 🔴 원값 = 색·아이콘 switch 에만 · `candidateOriginCodes`·`diffId` ui 미참조(C-47 ⑦) |
| `LedgerRepairRow` | `repairId` R · `diffId` R · `directionCode` R · `directionLabel` R · `originCode` R String · `decisionId` ? · `evidenceHash` R · `supersedes` ? String · `recomputedFrom` ? `TradeDate` · `appliedAt` R DateTime · `label` R String(재계산 고지 · C-29) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** +7 `appliedAtText` R · `directionTone` R `ChipTone` · `originLabel` R · `targetText` R String(가림 «숨김») · `decisionLink` ? `LinkAction`(→ `J-2`) · `supersededLabel` ? String(«이후 정정됨») · `chainStampText` R String(≠ `evidenceHash`) — 🔴 순서 = 엔진(정정의 정정 = 원본 바로 뒤) · 들여쓰기 = `supersedes != null` 만 · 원값 ui 미참조(K25) |

- 🔴 파생 불일치(`canonSupabase`·`canonGithub`·`canonCalendar`)는 **어떤 심각도에서도 주문을 막지 않는다**.
- 🔴 `applicable == false` 인 칸은 «점검 안 함»으로 그린다(빈칸·통과로 그리지 않는다). 보드 칸 수는 모드와 무관하게 **5 고정**.

### 3-7. 영역 **B** — `lib/src/dto/safety.dart` (01 §2-10)

| 타입 | 필드 |
|---|---|
| `AlertItem` | `alertId` R · `level` R `AlertLevel` · `raisedAt` R DateTime · `code` R String · `title` R String · `bodyText` R String(「무슨 일인가」) · `actionLine` R String(「지금 할 일」) · `groupedCount` R int · `deepLink` ? String · `ack` ? `AckState`(⚠️ M2-8 · 쓰기 경로 §8-10). 🔴 **손익 필드 없음** |
| `SafetyState` | `breakerLevel` R `BreakerLevel` · `breakerLabel` R String · `drawdown` R double · `activeFlags` R `List<BlockFlag>` · `killSwitch` R `KillSwitchView`(⚠️ M2-8) · `stoppedReleaseEligible` R bool · `releaseProgress` R `List<GaugeProgress>`(⚠️ M2-8) · `alertBlockSatEntry` R bool · `rampLevel` R `RampLevel`(⚠️ M2-8 · 🔵 **OpsRamp** L0~L5) · `mode` R `RunMode` · `asOf` R `AsOf` · 🆕 v1.19 `holds` R `List<String>`(기본 [] · ⊆ `SafetyHoldCodes` · 엔진 `ModeStartupGate.holds` 파생 · 🔴 기동 거부 `ModeStartupCodes` 는 여기 오지 않는다 · 01 §28 K21 · ✅ 병합 PR #163 squash `6b8ed02`) |
| `BlockFlag` | `flagId` R String(§3-5) · `label` R String · `setAt` R DateTime · `clearRoute` R `ClearRoute` · `clearInstruction` R String(🔴 플래그마다 다른 문구) · `originCode` ? String |
| `OnboardingStep` | `stepId` R · `track` R `OnboardingTrack` · `order` R int · `title` R String · `whyLine` R String · `whereDeepLink` ? String · `estimated` R `Duration`(`@DurationSecondsConverter()`) · `estimatedText` R String · `requirement` R `StepRequirement` · `state` R `StepState` · `verificationLabel` ? String · `verifiedUntil` ? DateTime · `failureReasonCode` ? String · 🆕 **v1.16(01 §25 · K15 · 표시 칸 6)** `requirementLabel` R String · `warningLabel` ? String · `verifiedUntilText` ? String · `failureText` ? String · `gate` ? `GateBadge` · `detailDeepLink` ? String(🔴 화면 미참조 = `stepId`·`track`·`order`·`estimated`·`requirement`·`verifiedUntil`·`whereDeepLink`(K16 · 01 §8 미결 150)) |

- 🔴 **소유 경계는 타입이 아니라 «무엇을 그리는가»** 다(01 §2-10 표) — 상태 표시는 허용, **상태를 바꾸는 경로를 만드는 것은 금지**. C-7 이 이 표대로 검사한다.
- 🔴 `RampLevel` = **OpsRamp**(운영 램프 L0~L5)이며 전략 §12-⑫ 의 **EntryRamp**(초기 진입 6개월 분할)와 **다른 것**이다. 하나의 «램프 진행» 위젯으로 합치지 않는다.
- 🆕 v1.19(01 §28 K11 · ✅ 병합 PR #163 squash `6b8ed02`) — 🔴 v1 엔진은 **L0 을 내지 않는다**(발행 집합 L1~L5 · `ramp_state.level` CHECK 1..5 · 행 없음 = L1 fail-closed) · `RampLevel.l0` 은 지우지 않는다(major) · `S05` 는 이 열거를 쓰지 않는다(`RampBoard.levelLabel` 글자).

### 3-8. 영역 **C** — `lib/src/dto/performance.dart` (01 §2-4)

| 타입 | 필드 |
|---|---|
| `PerformanceSeries` | `metric` R `PerfMetric` · `granularity` R `PerfGranularity` · `cumulative` R bool · `segments` R `List<PerfSegment>` · `points` R `List<PerfPoint>` · `benchmark` ? `BenchmarkSeries`(⚠️ M2-8) · `disclosure` R `PerfDisclosure`(⚠️ M2-8) · `afterTax` ? `AfterTaxLadder` · `asOf` R `AsOf` · 🆕 **v1.3(01 §13-1)** `seriesLabel` R String(본선 이름) · `periodLabel` R String(덮는 기간) · `yTicks` `List<PerfAxisTick>`(기본 빈 목록 · 많아야 5) · `unavailableLabel` ? String(🔴 non-null ⇔ `points` 가 비어 있다 — C-36 ⑤) |
| `PerfPoint` | `date` R `TradeDate` · `value` ? double(🔴 **null = 결측 · 보간 금지** · 🆕 v1.3 — 골든 대조·회귀 전용 · `ui_*` 참조 금지 — C-36 ⑦) · `gapReasonCode` ? String(`EQUITY_SNAPSHOT_MISSING`·`RESUME_GAP`·🆕 v1.3 `SIM_EXCLUDED`) · 🆕 **v1.3(01 §13-1)** `xNormalized` R double(가로 자리 0.0~1.0 · 엄격히 증가 · 점 1개면 0.5) · `dateText` R String · `valueText` R String(🔴 **표시의 정본** · 결측 점에도 온다) · `yNormalized` ? double(세로 자리 · null = 결측 — `value == null` 과 늘 함께) |
| `PerfSegment` | `from` R · `to` R `TradeDate` · `kind` R `SegmentKind` · `label` R String · 🆕 **v1.3(01 §13-3)** `startNormalized` R double · `endNormalized` R double(띠의 가로 범위 · start ≤ end · 🔴 화면은 `from`·`to` 를 점의 날짜와 비교하지 않는다) |
| `PerfAxisTick` 🆕 v1.3 | `normalized` R double(세로 자리 0.0~1.0) · `label` R String(엔진 생성) · `isBaseline` bool(기본 false · 한 시리즈에 많아야 하나 — C-36 ④) |
| `ReportArchiveRow` 🆕 v1.3 기재 | `yyyyMm` R String · `label` R String · `generated` R bool · `modeLabel` R String · `reasonLabel` ? String · `route` ? String · 🆕 **v1.3(01 §13-8)** `sectionLabel` ? String(non-null 이면 **이 행 위에** 머리글 1줄 · 묶음의 첫 행에만). `ReportArchiveVm.rows` 는 엔진이 최신 달부터 정렬(C-34 ⑩) |
| `DisclosureGateVm` 🆕 v1.3 기재 | `gateOpen` R bool(🆕 뜻 확정 — 엔진이 지금 진입을 허용하는가) · `headline` R String · `viewCountText` R String · `asOf` R `AsOf` · `frictionLine` ? String(null = 그 줄이 없다) · `route` ? String(게이트 밖 진입점용 · `gateOpen == (route != null)` — C-37 ①). 필드 무변경(01 §13-5) |
| `GoalPathVm` 🆕 v1.4 재설계 | `yyyyMm` R(Key 용 · 🔴 표시 금지) · `judgementText` R · `basisText` R · `deviationText` ? · `periodLabel` R · `plannedLabel` R · `actualLabel` R String · `planned` R · `actual` R `List<PerfPoint>`(🔴 같은 길이·`date`·`xNormalized` · `planned` 결측 0 — C-39 ②) · `yTicks` R `List<PerfAxisTick>`(많아야 5) · `segments` R `List<PerfSegment>` · `chartUnavailableLabel` ? String(non-null ⇔ 네 목록 빈 목록 — C-39 ③) · `backtestBasisText` R · `startingCapitalAssumptionText` R · `honestExpectationText` R · `honestExpectationWorstText` R · `disclaimerText` R String · `asOf` R `AsOf`(01 §14-10) — 🔴 ~~`GoalPathPoint`·`seriesCode`~~ 폐기(C-39 ⑧) · 🔴 S7-9 는 `ConfigRepository` 를 읽지 않는다 · 세후 사다리 없음(인용 문장 한 줄씩) |
| `MonthlyReport` 🆕 v1.4 기재 | (기존 필드 무변경) + 🆕 **v1.4(01 §14-9)** `goalDeepLink` ? String(`AppRoutes.reportGoalPath` = `aaq://report/goal/:yyyyMm` · 그 행의 달 · null = 버튼 부재 · 과거 달·가림·미생성 달은 null 가능 — C-39 ⑦) |
| `AfterTaxStep` | `stepCode` R String(`PRETAX`·`AFTER_POT`·`AFTER_POT_C`·`WD_5P5`·`WD_16P5`·`HONEST`) · `label` R String · `valueText` R String(🔴 **표시의 정본**) · `cagrPct` ? double(🔴 골든 대조 전용 · `ui_*` 참조 금지 — C-30) · `endMult` ? double(같음) · `noteLine` ? String |
| `AfterTaxLadder` | `branch` R `TaxLadderBranch` · `branchLabel` R String · `steps` R `List<AfterTaxStep>`(순서 그대로 · 층을 합치거나 건너뛰지 않는다) · `honestExpectationLine` R String · `basisNote` R String · `isReferenceOnly` R bool(🔴 **§8-18 확정 전 항상 true** · 🆕 v1.6 화면 미참조 — C-42) · `configHash` R String · `asOf` R `AsOf` · 🆕 **v1.6(01 §15-4 · K9 권고 선반영)** `referenceOnlyLabel` ? String(«골든 참고치입니다…» 엔진 문장 · 🔴 non-null ⇔ `isReferenceOnly` — C-41 ⑦ · 예외 고정 목록 = `m7_withdrawal_pension_penalty`(미결 79) · SIM 에서도 같다 · 화면 = `basisNote` 다음 줄 그대로) |
| `AnnualReviewVm` 🆕 v1.6 기재 | `year` R String(🔴 ui 미참조 — C-42 · 표시는 `yearLabel`) · 🆕 **v1.6** `yearLabel` R String(«2026년 연간 리뷰» · 엔진 생성 · 상단 첫 줄 · 기본 연도를 엔진이 고르므로 어느 해인지 말하는 유일한 글자 — C-41 ⑥ «비지 않음 ∧ `year` 를 품는다» · K24 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · `windowStateCode` R String(🔴 ui 미참조) · `windowStateLabel` R String(상단 고정 1줄) · `sections` R `List<AnnualReviewSection>` · `asOf` R `AsOf` · 🆕 **v1.6(K12 권고 선반영)** `afterTax` ? `AfterTaxLadder`(세후 본문 갈래 · null = 블록 부재) · `afterTaxCounterfactual` ? `AfterTaxLadder`(반사실 · 🔴 non-null ⇒ `afterTax` non-null — C-41 ⑥ · 화면 = 늘 기본 접힘 카드 · 접힘 값은 DTO 에 두지 않는다) — 🔴 같은 타입을 받는 M9 `S12`(`OpsStatusRepository.watchAnnualReview`) 창구는 세후 두 필드를 **null** 로 준다(K25 · 결정 8 · 미결 95) · `AnnualReviewSection` = `code` R(🔴 ui 미참조) · `title` R · `lines` R `List<String>` · `route` ? String(null = 버튼 부재 · v1.6 픽스처의 `B_AFTERTAX`·`C_EXECUTION` 은 route 없음 — K16 · ㉟ 권고 선반영) |

- 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간 차액도 금지 — **C-30** 이 검사한다.
- 🔴 «정직 기대»·«10.4%»·사다리 4자리 수치를 **코드·라벨·주석에 옮기지 않는다**. 인용처는 픽스처 `aftertax_ladder_1.json` 과 골든 `aftertax_full_S7` 뿐.

### 3-9. 영역 **C** — `lib/src/dto/rebalance.dart` (01 §2-5)

| 타입 | 필드 |
|---|---|
| `RebalanceEvent` | `eventId` R · `mode` R `RunMode` · `tradeDate` R `TradeDate` · `kind` R `RebalanceKind` · `kindLabel` R String · `before` R `List<SleeveWeight>` · `after` R `List<SleeveWeight>` · `trigger` R `TriggerSnapshot` · `orderIntentIds` R `List<String>` · `quality` ? `ExecutionQuality`(⚠️ M2-8) · `asOf` R `AsOf` · 🆕 **v1.5(01 §15-3 · §8 미결 49)** `journalTimelineLink` ? `LinkAction`(JSON `journal_timeline_link` · `S7-6b` 하단 «이 회차의 … N건» 버튼 하나 · 목적지 `AppRoutes.journalRebalance` 를 엔진이 완성 · `label` = 엔진 문장 · N = 그 회차에 묶인 일지 행 **전체** 수(정정 행 포함 · 기간 무관 — 발주자 결정 ④) · 🔴 null = 버튼 **부재**(묶인 일지 행 0 이면 null) · 🔴 화면이 `orderIntentIds.length` 로 N 을 세거나 `eventId` 로 링크를 조립하면 반려) · `detailDeepLink` ? String(JSON `detail_deep_link` · `S7-6a` 행 탭 → `S7-6b` · `AppRoutes.rebalanceEvent` 를 엔진이 완성 · null = 행 탭 무반응 · `S7-6b` 안에서는 쓰지 않는다) · 🆕 **v1.6(01 §15-4)** `thresholds` R `List<ThresholdCompare>`(사전 등록 임계 ↔ 실제값 대조 · 엔진 포맷 행 · 0건 = 표 부재 · 🔴 비어 있지 않음 ⇔ `trigger.thresholdRegistered != null` — C-41 ④) · `modeLabel` ? String(«모의» 배지 글자 · 🔴 non-null ⇔ `mode != LIVE` — C-41 ④ · 화면이 `mode` 로 고르지 않는다 · K7) · `sectionLabel` ? String(non-null 이면 이 행 위에 머리글 1줄 · 같은 모드 묶음의 첫 행에만 · `ReportArchiveRow.sectionLabel` 선례 · LIVE·SIM 섞인 목록의 정렬 키 = 미결 89) · 🆕 **v1.6 뜻 고정** `asOf` = **읽기 모델의 관측 시각**(마지막 배치 · 목록 봉투 `as_of` 와 같은 값 · 회차 시각 아님 — K10 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · 🔴 ui 미참조(C-42) = `eventId`(Key 전용)·`mode`·`kind`·`orderIntentIds` · 표시 일자 = `tradeDate.yyyyMmDd` 그대로(예외 1개) |
| `SleeveWeight` | `sleeve` R `SleeveId` · `basis` ? `AllocationBasis`(🔴 **M2-2 배치 전 nullable** · null = 미표기 → 목표·밴드 비교 금지 · 배치 후 required 승격) · `weight` R double · `targetWeight` R double · `bandLow` R double · `bandHigh` R double · `label` R String · 🆕 **v1.6 뜻 고정(K11 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13))** `label` = 이 행의 **완성 문장**(현재·목표·편차·밴드 여유 · 밴드 밖이면 여유 자리에 초과폭 — «B 47.8% (목표 42.0%, 편차 +5.8%p, 밴드 상단 0.8%p 초과)» · 🔴 이름만 싣지 않는다 — C-41 ④ `%` · 기존 주석 예시는 그대로) · 🔴 R12 ui 미참조(C-42) = `sleeve`·`weight`·`targetWeight`·`bandLow`·`bandHigh` |
| `TriggerSnapshot` | `configHash` R String · `rawValues` R `Map<String, String>`(지표명 → 엔진 포맷 문자열 · 계절 게이트 키는 **`trend_score_kr`**) · `triggerPrice` ? `@D Decimal` · `thresholdRegistered` ? double · `summary` R String · 🆕 v1.6 ui 미참조(C-42 · J-2 ⓒ) = `rawValues`·`triggerPrice`·`thresholdRegistered`(표시는 `RebalanceEvent.thresholds`) |
| `NextRebalanceVm` 🆕 v1.6 기재 | 🆕 **v1.6 nullable** `expectedDateText` ? · `dDayText` ? String(🔴 null ⇔ `emptyLabel` non-null — C-41 ③ · 엔진 생성 · 화면이 날짜를 빼지 않는다) · `emptyLabel` ? String(non-null = «예정 없음» — 이 문장**만** 그린다) · `expectedKind` ? `RebalanceKind`(🔴 ui 미참조) · `kindLabel` ? String · `previewRoute` ? String(🔴 `S7-6c` 안에서 쓰지 않는다 — `H-02`·알림 행 몫) · `noticeText` ? String · 🆕 **v1.6** `asOf` R `AsOf`(봉투 as_of 를 행으로 · `DepositPlan.asOf` 선례 · `H-02` 도 같은 필드) — 창구 `RebalanceRepository.watchNext()` 는 v1.6 에서도 **nullable 이 아니다**(N-4) |

| `SleeveAllocationRow` 🆕 v1.8 개정 | `sleeve` R · `basis` R `AllocationBasis` · `deployedText` R · `parkingText` R String · ~~`deployedRatio` R · `parkingRatio` R double~~ 🆕 **v1.8 nullable** `deployedRatio` ? · `parkingRatio` ? double(둘 다 null ⇔ 막대 부재 = INTEGRITY 가림 · RECON 은 유지) · `trancheStateText` R · `deployedPctText` R · `parkingPctText` R String · `parentSleeve` ? `SleeveId` · `engineColumnNote` ? · `parkingNoteText` ? String · 🆕 **v1.8(01 §17)** `sleeveLabel` R String · `sleeveWeight` ? `SleeveWeight`(밴드 행 = B 만 · K27 · `basis` = ACCOUNTING) · `bandState` ? `SleeveBandState` · `bandStateLabel` ? String · `gauge` ? `SleeveBandGauge` · `bandNoteText` ? String(non-null ⇔ `sleeveWeight` null — 그 행의 현재 비중 글자의 유일한 출구) · `stateChips` `@Def([]) List<ReasonChip>` — `H6-1` 카드 머리 · `H6-3` 행 · 홈 블록 4(R13)는 `sleeveWeight`·`*PctText` 만 |
| `SleeveBandGauge` 🆕 v1.8 | `actualNormalized` · `targetNormalized` · `bandLowNormalized` · `bandHighNormalized` R double(0~1 · `× 폭` 전용 · low ≤ target ≤ high · 계좌 잔고 막대와 다른 막대) |
| `SleeveAllocationVm` 🆕 v1.8 | `rows` R `List<SleeveAllocationRow>`(A → POT → B → C → CASH · 전부 회계 기준) · `noticeText` ? · `emptyLabel` ? String · `asOf` R `AsOf` — `H6-3` 한 화면 |

- 🔴 **`SleeveWeight.basis` 는 `accounting` 외 값을 갖지 않는다.** 엔진 원장 열은 `SleeveAllocationRow.engineColumnNote`(문자열) 또는 진단 전용 타입으로만 흐른다. **C-31** 이 basis 혼합·`A + POT` 산술을 탐지한다.
- 🔴 `basis` 를 required 로 올리면 `SleeveWeight` 를 싣는 **모든 픽스처·C-1 골든이 동시에 깨진다** — 갱신 주체는 M2 하나다.

### 3-10. 영역 **C** — `lib/src/dto/plan.dart` (01 §2-6)

| 타입 | 필드 |
|---|---|
| `DepositPlan` | `planId` R · `computedAt` R DateTime · `asOfTradeDate` R `TradeDate` · `expiresAt` R DateTime(🔴 만료 계획은 등록 거부) · `configHash` R String · `depositAmount` R `@D Decimal` · `allocations` R `List<SleeveAllocation>`(⚠️ M2-8) · `pensionLimitConsumed` R `@D Decimal` · `residualKrwCash` R `@D Decimal`(D2 원화 현금 대기) · `orderDrafts` R `List<OrderDraft>` · `costs` R `CostEstimate`(⚠️ M2-8) · `fundingSteps` ? `List<FundingStep>`(⚠️ M2-8 · v2.32 `PENSION_FUNDING`. **null·빈 목록 = 절을 통째로 숨긴다** — 0건을 「0원」으로 그리지 않는다) · `previewNotice` R String · 🆕 **v1.4(01 §14-4 · §14-5)** `asOf` R `AsOf` · `depositAmountText` R String · `pensionLimit` ? `PensionLimitVm`(null = 카드 부재) · `residualKrwCashText` ? String(null ⇔ 잔여 0 — C-38 ②) · `orderDraftsTitle` R String · `ordersEmptyText` ? String(non-null ⇔ `orderDrafts` 빈 목록) · `warningLines` `List<String>`(기본 빈 목록 · 받은 순서) · `registerBlockedText` ? String(non-null = 등록 불가 · 🔴 화면이 `expiresAt` 을 시계와 비교하지 않는다) · 🔴 `previewNotice` = «미리보기입니다…» 고지 **전용** · 🔴 ui 미참조(C-38 ⑩) = `computedAt`·`asOfTradeDate`·`expiresAt`·`depositAmount`·`pensionLimitConsumed`·`residualKrwCash` |
| `OrderDraft` | `symbol` R · `symbolLabel` R · `sleeve` R `SleeveId` · `accountAlias` R String · `side` R `OrderSide` · `quantity` R int · `limitPrice` ? `@D Decimal` · `reasons` R `List<ReasonChip>` · 🆕 **v1.4(01 §14-4)** `sideLabel` R String · `quantityText` R String · `limitPriceText` ? String(non-null ⇔ `limitPrice != null` — C-38 ② · ~~**`DepositPlan` 한정**~~ 🆕 v1.6 `DepositPlan`·`RebalancePreview`(C-41 ②) · 인출 초안은 인출 규칙 결정 뒤 첫 minor 전까지 이 짝을 지키지 않는다) · `pendingNoteText` ? String · 🔴 ui 미참조(C-38 ⑩ · 🆕 v1.6 `S7-6c` = C-42 ③) = `side`·`quantity`·`limitPrice` · 플래너·🆕 `S7-6c` 의 사유 칩은 `label`·`tone` 만(D20 · `detailDeepLink` 읽지 않음 · 미결 81) |
| `DepositPreviewResult` 🆕 v1.4 | `plan` ? `DepositPlan` · `inputRejectedText` ? String · `blockedText` ? String · `blockedAction` ? `LinkAction`(01 §14-3) — 🔴 앞 셋 중 **정확히 하나** non-null · `blockedAction` 은 `blockedText` 가 있을 때만(C-38 ①) · 화면은 무엇이 non-null 인가로만 갈린다(D21) |
| `PensionLimitVm` 🆕 v1.4 | `annualLimitText` R · `taxCreditText` R · `deadlineText` R String · `suggestionText` ? · `fundingNoteText` ? String(01 §14-4 · 한도 카드 · 전부 완성 문장) |
| `SleeveAllocation` 🆕 v1.4 기재 | `sleeve` R `SleeveId` · `label` R String · `amount` R `@D Decimal`(🔴 ui 미참조 — C-38 ⑩) · `amountText` R String · `accountAlias` ? String · 🆕 **v1.4** `routingReasonText` ? String(null = 줄 부재) |
| `RebalancePreviewResult` 🆕 v1.6 | `preview` ? `RebalancePreview` · `blockedText` ? String(초안을 계산하지 않은 까닭 — 엔진 문장 · 화면 = 문장 카드 1장) · `blockedAction` ? `LinkAction`(차단 카드의 이동 버튼)(01 §15-4 · 발주자 결정 ② 2026-10-07) — 🔴 `preview`·`blockedText` 중 **정확히 하나** non-null · `blockedAction` 은 `blockedText` 가 있을 때만(C-41 ① · C-38 ① 준용) · 입력 거부 갈래 없음(입력이 없다) · 화면은 무엇이 non-null 인가로만 갈린다 |
| `RebalancePreview` 🆕 v1.6 표시 필드 | `planId` R(🔴 ui 미참조) · `plannedDate` R `TradeDate`(🔴 ui 미참조 — 표시는 `plannedDateText`) · `before` R · `after` R `List<SleeveWeight>`(🔴 R12 미표시 — 미결 92) · `orderDrafts` R `List<OrderDraft>` · `costs` R `CostEstimate` · `previewNotice` R String(«미리보기입니다…» 고지 **전용**) · `fundingSteps` ? `List<FundingStep>`(🔴 R12 미표시 — 미결 92 · null·빈 목록 규약 그대로) · 🆕 **v1.6(01 §15-4)** `plannedDateText` R String(«2026년 9월 1일 회차» · 초안 머리 1줄) · `asOf` R `AsOf`(초안 기준 · `DepositPlan.asOf` 선례) · `orderDraftsTitle` R String(«주문 초안» / advisory 이름 · 미결 71) · `ordersEmptyText` ? String(non-null ⇔ `orderDrafts` 빈 목록 — C-41 ②) · `warningLines` `List<String>`(기본 빈 목록 · 받은 순서) |

- 🔴 **월 추가 납입 운영값(현행 10만원)을 화면·계약·픽스처에 상수로 적지 않는다.** 읽기 창구는 `ConfigRepository.watchContributionSetting()` 하나이고 변경 창구는 `SettingsActions`(운영 등급)다. **C-32** 가 `100000`·`90000`·`97000`·`124000`·`100_000`·`'10만'`·`'9.7만'` 리터럴을 탐지한다(🔴 `labels.dart` 도 예외 아님). 🆕 **v1.23(01 §32 K78 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — «읽기 창구 하나» → «값의 원천 하나(엔진 `contributionSettingOf`)» · 설정 화면 `S13` = 투영 창구 `SettingsRepository.watchContribution()` · `S7-4`·`H-02` = `ConfigRepository` 그대로 · 변경 = `SettingsActions.runContributionUpdate`(원문 제출).

### 3-11. 영역 **C** — `lib/src/dto/advice.dart` (01 §2-11 X7)

| 타입 | 필드 |
|---|---|
| `AdviceItem` | `adviceId` R · `batchId` R · `kind` R `AdviceKind` · `tradeDate` R `TradeDate` · `issuedAt` R DateTime · `validUntilDate` R `TradeDate` · `validityLabel` R String · `symbol` ? · `symbolLabel` ? · `phoneOnlyLabel` ? String · `sleeve` R `SleeveId`(viewer 도 본다) · `side` ? `OrderSide` · `quantity` ? int · `priceBand` ? `AdvicePriceBand` · `sizingLabel` R String · `recordedQuantity` ? int(🔴 **viewer 판 null · 폰 판 non-null**) · `progressLabel` R String · `reasons` R `List<ReasonChip>`(최소 1개) · `status` R `AdviceStatus`(🔴 저장값 — 배지·정렬에 쓰지 않는다) · `effectiveStatus` R `AdviceStatus`(🔴 **화면이 쓰는 유일한 값**) · `statusLabel` R String · `statusTone` R `ChipTone` · `actions` R `List<AdviceAction>` · `recordedDeviationChips` R `List<ReasonChip>` · `closeReasonCode` ? String · `isUrgent` R bool · `dependsOnAdviceId` ? String · `onHold` R bool · `holdReasonLabel` ? String · `decision` R `DecisionRef` · `accountAlias` ? String · `suppressed` R bool · `suppressedLabel` ? String · `deferAvailable` R bool(⚠️ M2-8 §8-30) · `asOf` R `AsOf`. 🔴 **`mode`·`operatingMode` 필드를 두지 않는다**(A7) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** +7 `detailDeepLink` R String(카드 탭 → `A-2` · 전 플랫폼) · `sideLabel` ? · `expiredConfirmLabel` ?(non-null ⇔ 만료 확인 카드 · 엔진이 ≤3 · 맨 앞 · K13) · `decisionLink` ? `LinkAction`(→ `J-2` · 뷰어 non-null · K18) · `prefillQuantityText` ? · `prefillQuantityLabel` ?(짝 · 열린 안내 · K19) · `closeReasonLabel` ?(⇔ `closeReasonCode` · K39) — `status`·`closeReasonCode` ui 미참조 · 정렬 = 엔진(확인 카드 → `isUrgent` → 나머지) |
| `AdviceAction` | `actionId` R `AdviceActionId` · `label` R String · `enabled` R bool · `disabledReasonLabel` ? String(enabled == false 일 때만) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** `deepLink` R String(RECORD → `advice/fill/<id>` · SKIP → `advice/skip/<id>` · K5) — 🔴 엔진은 RECORD·SKIP 만 · 뷰어 `actions` = 빈 목록(K6) · 배치 결측 = RECORD 만(K41) |
| `AdvicePriceBand` | `low` R `@D Decimal` · `high` R `@D Decimal` · `reference` R `@D Decimal` · `label` R String |
| `AdviceInboxSummary` | `batchId` R · `tradeDate` R `TradeDate` · `openCount` R int · `dueTodayCount` R int · `hasSuppressedNotice` R bool · `overdueUnrecordedCount` R int · `headline` R String · `level` R `UiLevel` · `dueSoonLabel` ? String · `staleReasonCode` ? String · `staleLabel` ? String · `handoverCoolingActive` R bool(⚠️ 이름 M2-8 · N-1) · `handoverCoolingLabel` ? String · `trust` R `LedgerTrustBadge` · `asOf` R `AsOf` · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** +4 `cashNotice` ? `CashEstimateNotice`(K15) · `overdueUnrecordedLink` ? `LinkAction`(«미확인 만료 n건» → `advice/history` · ⇔ 확인 카드로 다 못 보인 만료 · K13) · `manualEntryLink` ? `LinkAction`(→ `m5/intervention` · 뷰어·autoTrade null · K17) · `manualEntryNoticeText` ? |
| `ManualFillFormSpec` | `symbols` R `List<SymbolOption>` · `accounts` R `List<AccountOption>` · `skipReasons` R `List<ReasonOption>` · `minTradeDate` R · `maxTradeDate` R `TradeDate` · `nonTradingDates` R `List<TradeDate>` · `priceHintLabel` R String · `quantityMax` R int · `appendOnlyNotice` R String · `asOf` R `AsOf`(A16). 🔴 `amendReasons`·`voidReasons` **없음**(→ `M5-12`) · 시간외·단주 힌트 **없음**(B5) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** +5 `sides` R `List<SideOption>` · `tradeDateOptions` R `List<TradeDateOption>`(min~max − 휴장 · K37) · `skipNoticeText` R String(`A-4` 제출 전 1줄) · `blockedText` ?(제출 **부재** + 문장 · K21) · `bannerText` ?(폼 고유 배너) — 날짜 3·`quantityMax` = ui 미참조 |
| `SideOption` 🆕 v1.12 | `side` R `OrderSide` · `label` R String(«매수»·«매도» · 선택 = `side` 그대로) |
| `TradeDateOption` 🆕 v1.12 | `date` R `TradeDate` · `label` R String(«8/28(금)» · 🔴 화면은 날짜를 만들거나 비교하지 않는다) |
| `SymbolOption` · `AccountOption` · `ReasonOption` | ⚠️ **필드 M2-8** — 최소 축 `code`·`label`(+`ReasonOption` 은 `requiresNote` bool). 🔴 `ReasonOption` ↔ `J-3` `rule_cited` 통합 여부는 **선행 미결**(§8-20 · D19) · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** `ReasonOption.deepLink` ?(non-null = 명령 없이 push — `A-4` 예산 코드 2종 → `m5/intervention` · K12) · `requiresNote` 정본 = 02 §3-9 표(예산 2종만 true · K22) |

- **`openCount` 의 정의**(G-08 · 🔴 화면이 재구현하지 않는다): `effectiveStatus ∈ {open, partial}` 이고 `suppressed == false` 인 안내의 수. `onHold == true` 는 **센다** · `suppressed == true` 는 **세지 않는다** · `EXPIRED` 미확인은 `overdueUnrecordedCount` 가 따로 센다.
- 🔴 **C14 의 예외 2가지** — `openCount == 0` 이어도 `hasSuppressedNotice == true` 또는 `handoverCoolingActive == true` 면 홈 블록 3b·`J-1` 배지를 **렌더한다**.
- 🔴 `kind == noAction` 이면 폰 판에서도 `symbol`·`quantity`·`side` 가 null 이고 `suppressed == true`·`suppressedLabel` 필수·`actions` 빈 목록이다.

### 3-12. 영역 **C** — `lib/src/dto/ledger_trust.dart` · `handover.dart` · `ops.dart` (01 §2-11)

| 파일 | 타입 | 필드 |
|---|---|---|
| `ledger_trust.dart` | `LedgerTrustBadge` | `grade` R `LedgerTrustGrade` · `level` R `UiLevel` · `label` R String · `consequenceLine` R String(🔴 **어느 카운터 때문인지**를 말한다 — B22) · `upgradeHint` ? String · `lastVerifiedOn` ? `TradeDate` · `actionDeepLink` ? String |
| `ledger_trust.dart` | `ExecutionGapReport` | `range` R `DateRange` · `periodLabel` R String · `issued`·`filled`·`partial`·`skipped`·`lapsed`·`revoked`·`lateFilled` R int · ~~`complianceRateNormalized` R double~~ 🆕 **v1.6** `complianceRateNormalized` ? double(0.0~1.0 · **게이지 폭 전용** · null = 게이지 부재 = 가림(RECON_MISMATCH 등) — K8) · `complianceRateLabel` R String(가림이면 엔진이 «?» 로 가린 글자) · `medianDelayLabel` R String · `priceGapLabel` R String(🔴 **bp, 금액 아님**) · `amendChainMaxLabel` R String · `skipReasonBuckets` R `List<ReasonChip>` · `selectiveExecutionChips` R `List<ReasonChip>` · `backdatedCount` R int · `selfReportCorrectionCount` R int · `trust` R `LedgerTrustBadge` · ~~`modeAdviceLine` R String~~ 🆕 **v1.6** `modeAdviceLine` ? String(🔴 **3갈래로 갈라 생성** — B21: ⓐ «못 함» 우세 = 이관 제안 / ⓑ «안 함» 우세 = 이관을 제안하지 않고 `J-4`·연간 반증 조건 점검을 문장 안에서 가리킨다(버튼·링크 0) / ⓒ 갈리지 않음·정상 달 = **null = 줄 부재** — K6 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13) · 03 §14-b 수용 (b) 정정) · `asOf` R `AsOf` · 🆕 **v1.6(01 §15-4)** `countLines` R `List<String>`(건수 묶음 · 줄마다 엔진 완성 문장 · 받은 순서 · 가림이면 줄 안 «?») · `correctionLines` R `List<String>`(소급·자가 보고 정정 · 둘 다 0 이면 빈 목록 = 절 부재) · 🔴 R12 ui 미참조(C-42) = `range`·int 9종 |
| `ledger_trust.dart` | `ExecutionGapResult` 🆕 v1.6 | `report` ? `ExecutionGapReport` · `emptyKind` ? `EmptyKind` · `emptyLabel` ? String · `asOf` R `AsOf`(01 §15-4 · K8 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) — `ExecutionGapRepository.monthly` 의 반환 · 🔴 `report`·`emptyLabel` 중 **정확히 하나** non-null · `emptyKind` ⇔ `emptyLabel` · `report` 가 있으면 `asOf == report.asOf`(C-41 ⑧) · 안내 0건 = `noData` · autoTrade 구간 = `notApplicable` — 화면은 `emptyLabel` 문장 카드 하나만(`issued == 0`·`operatingMode` 로 고르지 않는다) |
| `ledger_trust.dart` | `ExternalHoldingRow` | `externalId` R · `symbol` R · `symbolLabel` R · `accountAlias` R String · `quantity` R int · `registeredOn` R `TradeDate` · `scopeLabel` R String · `decision` R `DecisionRef`(🔴 등록도 결정이다) · 🆕 **v1.8** `quantityText` R String(사람이 등록한 값 — INTEGRITY 가림 대상 아님 · K14 · `HoldingsExternalSection.rows` 의 행) |
| `ledger_trust.dart` | `CashEstimateNotice` | `isEstimate` R bool · `label` R String · `lastConfirmedOn` ? `TradeDate` |
| `ledger_trust.dart` | `SelfReportLine` | `symbol` R · `symbolLabel` R · `quantity` R int(🔵 v1.12 — 와이어 `SelfReportBalance.lines` 하위 행 · 화면 VM 은 싣지 않는다) |
| `ledger_trust.dart` | `SelfReportSession` 🆕 v1.12 | `titleText` R · `noticeText` R · `asOfTradeDateText` R String(🔴 기준일 원값 없음 · K8) · `symbols` R `List<SymbolOption>`(유니버스 전 종목 · 0 포함 필수) · `accountLabel` R · `cashHintLabel` R · `declareCompleteLabel` R String · `sessionClosedText` ? · `blockedText` ? String · `result` ? `SelfReportResult` · `trust` R `LedgerTrustBadge` · `asOf` R `AsOf` — `L-3` 한 실사 = 그 달 · 그 계좌(K36 ⓐ) · 🔴 원장 현재값 0(앵커링) |
| `ledger_trust.dart` | `SelfReportResult` 🆕 v1.12 | `diffs` R `List<LedgerDiffRow>`(canonSelfReport · 각 `actionLink` null) · `emptyLabel` ?(⇔ 빈) · `resolveLink` ? `LinkAction`(→ `M5-13`) · `nextAccountLink` ? `LinkAction`(→ 다음 계좌 `L-3`) |
| `handover.dart` | `OperatingModeView` | `current` R `OperatingMode` · `label` R String · `explainLine` R String · `options` R `List<OperatingModeOption>`(🔴 **기본 선택 없음**) · `trust` R `LedgerTrustBadge` · `switchGates` R `List<GateBadge>` · 🆕 v1.19 `switchActions` R `List<SettingsActionCall>`(기본 [] = 버튼 부재 · 엔진 완성 `runtimeOperatingModeSwitchRequest` `{operating_mode}` · 값 ≠ `current` · 🔴 `options` 카드엔 버튼 0 · `S05` = `OperationsVm.operatingMode` · 01 §28 K8 · ✅ 병합 PR #163 squash `6b8ed02`) |
| `handover.dart` | `OperatingModeOption` | `mode` R `OperatingMode` · `title`·`body`·`prepLine`·`honestyLine` R String(🔴 전부 엔진 문구) |
| `handover.dart` | `HandoverPlan` | `path` R `HandoverPath` · `pathLabel` R String · `steps` R `List<HandoverStep>` · `adoptionPreview` R `List<AdoptionPreviewRow>` · `handbackBranch` ? String(🔴 엔진이 판정 — B12) · `branchReasonLabel` ? String · `asOf` R `AsOf`(B13 스냅샷 신선도) |
| `handover.dart` | `HandoverStep` | `stepId` R · `order` R int · `title` R String · `whyLine` R String · `state` R `GateState` · `stateLabel` R String · `blockedReasonCode` ? String |
| `handover.dart` | `AdoptionPreviewRow` | `symbol` R · `symbolLabel` R · `quantity` R int · `sleeve` R `SleeveId` · `adoptionId` R String(G-03) · `disposition` R String(`'ADOPT'`\|`'EXTERNAL'` — 🔴 **낙관 갱신 금지**, 되돌아온 값을 다시 그린다) · `dispositionLabel` R String |
| `ops.dart` | 🆕 v1.24 `BackupVm` 교체 · `RestorePointRow` · `DiagnosticsScreenVm` · `SelfTestCard` · `AnnualReviewIndexVm` | `BackupVm{lastBackupText R · ageBadgeText ? · level R · noticeText ? · runAction ? · lockedLabel ? · points R List<RestorePointRow> · pointsEmptyLabel ? · migrationLink ? LinkAction · asOf R}`(옛 7 칸 중 6 칸 삭제 · `asOf` 유지 · 복원 버튼 0 · K110 · K111) · `RestorePointRow{code R(ui 미참조) · label R · chainHashText R(앞 8 · 엔진이 자름) · stateLabel ?}` · `DiagnosticsScreenVm{golden R · integrity R SelfTestCard · board R DiagnosticsVm(무변경) · diffsLink ? · recommendText ? · lockedLabel ? · asOf R}` · `SelfTestCard{title · statusLabel R · level R · lastRunText ? · summaryText ? · runAction ?}` · `AnnualReviewIndexVm{yearLabel · windowStateLabel R · entries R List<LinkAction> · pledgeLink ? · asOf R}`(세후·수치 칸 0 · K118) · 01 §33 · ✅ 병합 PR #235 squash `bbed5ef` · 2026-11-18 · R8a 병합 뒤 |

### 3-13. 영역 **C** — `lib/src/dto/settings.dart` (01 §4-1 · §2-6)

| 타입 | 필드 |
|---|---|
| `ContributionSetting` | `amount` R `@D Decimal`(🔴 «지금 유효한 값» — 예정 금액을 넣지 않는다) · `amountText` R String · `equivalentNoteText` R String · `appliesFromText` R String · `lastChangedText` R String · `pensionLimitNoteText` ? String(G-102 · null 이면 줄을 그리지 않는다) · `asOf` R `AsOf` · 🆕 **v1.4(01 §14-3)** `amountInputText` R String(플래너 스텝 ① 입력칸 **초기 글자 전용** · 스트림의 첫 값만 채운다 · `MonthlyContributionVm` 도 같은 이름으로 투영) · 🔴 `amount` 는 ui 미참조(C-38 ⑩) |

- 🔴 **최소·최대·0 허용 여부를 필드로 내려보내지 않는다** — 범위 판정은 저장 명령의 `ActionResult.headline`·`reasonCode` 로만 돌아온다.
- 🔴 `MonthlyContributionVm`(⚠️ M2-8 → ✅ G-11)은 이 타입의 **1:1 투영**이며 `editable` 하나만 런타임 값이다. 🔴 **`ContributionVm` 이라는 이름을 재사용하지 않는다**(03 §10 `S7-3b` 슬리브 기여 분해가 이미 그 이름을 쓴다).
- 🆕 **v1.23(01 §32 K79 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — `MonthlyContributionVm` += `asOf` R `AsOf` · `lockedLabel` ? String · `changeLabel` ? String(null = 입력칸·버튼 **부재** · `lockedLabel` non-null ⇒ null) · `editable` = 🔴 ui 미참조 표식(== `changeLabel != null` · 지우지 않음 — 파괴 변경 0) · 칸 차례 = 기존 7 칸 뒤(추가형) · 원값·범위·회차 칸 0(C-57 ①) · `save…`·`submit…` 이름 0(C-7).

### 3-14. ⚠️ 이름만 있고 필드가 M2-8 확정 대기인 타입 (01 §2-6 표)

> 🔴 **구현자는 이 타입들의 필드를 상상해서 쓰지 않는다.** `docs/m2-8_naming.md` 가 확정한 «최소 축»만 만들고, 축이 없는 것은 **선언만 두거나 만들지 않는다**.

| 갈래 | 타입 | 배정 영역 · 파일 |
|---|---|---|
| 공통·안전 | `KillSwitchView` · `AckState` · 🆕 v1.15 `AlertCenterVm` · `AlertSection` · `AlertDetailVm`(01 §24 · `AlertItem` += `raisedAtText` · `groupedText` · `detailDeepLink`) · `GaugeProgress` · `RampLevel` · `EntryRampProgress` · `ResumeCounts` · `ResumeItem` · `DataGapRow` | **B** `dto/safety.dart`(앞 8 — 🆕 v1.15 3종 `AlertCenterVm`·`AlertSection`·`AlertDetailVm` 포함 · ~~앞 4~~ = v1.15 전에도 5였다) · `dto/resume.dart`(뒤 3) |
| 명령 페이로드 3종 | `JournalDraft` · `BlindReviewScore` · `DisclosureViewEvent` | **D** `commands/payloads.dart` — ~~🔴 **M2-8 최우선**(명령 5종 중 3종이 호출 불가)~~ ✅ H-1~H-3 확정(m2-8) · 🆕 v1.7 `BlindReviewScore.answers` = 고른 `BlindReviewChoice.score` 그대로(필드 무변경 · 01 §16) |
| 핸드북 | `HandbookIndex` · `HandbookPage` · 🆕 v1.17 추가형(01 §26 K13~K16 · ✅ 병합 PR #123 squash `0249f61`) `HandbookIndex` += `outdatedNotice?` · `HandbookEntry` += `state`(기본 ready) · `stateLabel?` · `deepLink?` · `children`(기본 []) · `HandbookPage` += `outdatedNotice?` · `missingLabel?` · `asOf?`(live 블록 ⇔ non-null) · `HandbookBlock` += `live?` · 🆕 `HandbookLiveValue{label, level}` | **C** `dto/handbook.dart` |
| M7 | `MonthlyReport` · `BenchmarkSeries` · `PerfDisclosure` · `ExecutionQuality` · `SleeveAllocation` · `CostEstimate` · `WithdrawalPlan` · `RebalancePreview` · `FundingStep` · `DrawdownContextVm` · `GoalPathVm` · `ReportArchiveVm` · `DisclosureGateVm` · `ContributionVm` · `NextRebalanceVm` · `AnnualReviewVm` | **C** `dto/performance.dart`·`plan.dart`·`ops.dart` |
| M6 미정의 9건 | `DecisionSnapshot` · `ThresholdCompare` · `RejectTrace` · `JournalDraftFormSpec` · `BlindReviewCard` · UNKNOWN 단계 · `SleeveAllocationRow` · 손절선 정규값 · `LedgerRepairRow` | **B** `dto/journal.dart`·`ledger.dart`(🆕 v1.6 `ThresholdCompare` 는 `dto/common.dart` — §3-1 · 🆕 v1.7 `BlindReviewCard` 필드 확정 + `BlindReviewChoice`·`BlindReviewResult` 신설 — §3-2 · 01 §16 · 🆕 v1.8 `SleeveAllocationRow` 밴드 축 + `SleeveAllocationVm` — §3-9 · 손절선 정규값 = `StopLineNormalized` 글자 행(`HoldingDetailVm.stopLines` — §3-3 · 게이지 정규값 = 01 §8 미결 104) · 01 §17) |
| M8·M9 | `ShellVm` · `OpsRhythmRow` · `WatchdogCheck`(🆕 v1.15 − `slug` + `checkId` + `level: UiLevel` · 01 §24) · 🆕 v1.15 `WatchdogBoardVm` · `SettingsHomeVm` · `CredentialListVm` · `ConnectionsVm` · `DeviceAccessVm` · `BackupVm` · `DiagnosticsVm`(🆕 v1.13 `DiagnosticCell.level` R `UiLevel` · `headline` 늘 엔진 문장 · 01 §23) · `OpsDailySummary` · `MonthlyContributionVm` | **C** `dto/ops.dart`·`settings.dart` |
| 🆕 v1.16 온보딩·페어링 | `OnboardingStartVm` · `OnboardingTrackCard` · `OnboardingModeChoiceVm`(`selected: OperatingMode?` — null = 안 고름 · 카드 = `OperatingModeOption`) · `OnboardingStepsVm` · `OnboardingStepDetailVm` · `OnboardingAction` · `OnboardingFinishVm` · `OnboardingFinishStage` · `OnboardingFinishCheck` · `RestartVm` · `PairingVm` · `PairingResult`(01 §25 · 링크 = `deepLink`·`nextDeepLink`·`finishDeepLink` · `LinkAction` 재사용) | **C** 🆕 `dto/onboarding.dart`(✅ 병합 PR #96 squash `dd9e162` · `OperatingModeView` 는 `O-00b` 가 읽지 않는다 — K12) |
| 🆕 v1.17 장애·런북·긴급 카드 | `IncidentBanner{kind, level, title, bodyText, actionLink?}`(JSON `action_link` — `action` 은 C-50 ⑨ 와 충돌) · `IncidentBannerVm{banner?}`(최대 1건 · 고르기 = 엔진) · `RunbookIndexVm{rows, emptyLabel?}` · `RunbookRow{title, summaryText?, deepLink}` · `RunbookVm{title, introText?, steps, localCheckNotice, missingLabel?}` · `RunbookStep{orderText, text}`(번호 = 글자 · `i + 1` 금지) · `EmergencyCardVm{title, steps, contactLine, keepOnPaperNotice, printSlotId?}`(🔴 asOf 칸 0 — 문서 VM · K20) | **C** 🆕 `dto/incident.dart`(✅ 병합 PR #123 squash `0249f61` · 01 §26) |
| 🆕 v1.17 기기 리스크 | `DeviceRiskItem{label, currentText, thresholdText, actionText, lastCheckedText, level}` · `DeviceRiskVm{rows, guidanceText, emptyLabel?, asOf}`(측정값 — asOf 있음) | **C** `dto/ops.dart`(✅ 병합 PR #123 squash `0249f61` · `H-03` · 01 §8 미결 123 계약 몫) |
| 🆕 v1.18 설정 홈·연결 관리 | `SettingsHomeVm{statusChip, annualReviewLink?, groups, asOf}`(교체 · 묶음 차례 = 엔진 · 연간 링크 = OPEN 만 · `isViewer` 칸 0 — 뷰어 판 = 엔진이 폰 전용 행을 뺀다) · 🆕 `SettingsGroup{tier, label, cards}` · 🆕 `EngineStatusChip{label, level, promotionLabel?}`(DRY_RUN 글자 0 · 손익 0) · `SettingsCard` += `attentionText?`(🔴 int 아님) · − `actionAvailable`(카테고리 아이콘 사전 0 — 행 아이콘 = `level`) · 🆕 `typedef SettingsActionCall = OnboardingAction` · `ConnectionsVm` += `lockedLabel?`(잠기면 엔진이 동작 칸을 비운다) · `ConnectionRow` += `detailLine?` · `level` · `actions`(기본 [] = 버튼 부재) · `channelPicker?`(알림 채널 행만) · − `actionAvailable` · 🆕 `NotifyChannelCard{label, options, capabilityNotice, tokenBadgeText?, watchdogChannelLine}` · 🆕 `NotifyChannelOption{code, label, selected, selectAction?}` | **C** `dto/settings.dart`(앞 4 · typedef) · `dto/ops.dart`(뒤 4)(✅ 병합 PR #142 squash `b582c49` · 01 §27 K-o~K-t · `S01`·`S07`) |
| 🆕 v1.19 운용 관리 | `OperationsVm{statusChip, mode, operatingMode, trial?, ramp, jobs, control, updateGate?, lastRequestNotice?, lockedLabel?, asOf}`(🔴 `scope`·`HandoverPlan`·`contribution` 칸 0 — K3 · 폰 전용 = 뷰어 판 0 · 잠기면 엔진이 동작 칸 5 를 비운다) · 🆕 `RunModeCard{label, level, holdLabel?, observation?(LiveDryRunObservationVm), promotionAction?, switchNoticeText?, switchActions = []}`(runMode 축만 · hold «모의» 0) · 🆕 `SimTrialCard{headline, summaryText, checks}` · 🆕 `SimTrialCheck{itemCode, label, detailText, itemState, stateLabel, level}`(짝 PASSED·AUTO_PASSED ⇒ ok · OPEN ⇒ watch · OPEN_WARN ⇒ info · 🔴 `GateState`·`OnboardingFinishCheck` 안 씀) · 🆕 `RampBoard{levelLabel, level, conditions = [], emptyLabel?, dstNoticeText?}` · 🆕 `RampCondition{label, progressText, level}` · 🆕 `JobRow{label, scheduleText, lastRunText, statusCode, stateLabel, level, detailLine?}`(`statusCode` 화면 미참조 · `job_run.status` 4 + `NONE`) · 🆕 `EngineControl{stateLabel, level, startAction?, stopPromptText?, stopActions = []}`(시작 xor 중지 · 킬스위치 칸 0) · 🆕 `UpdateGateCard{stateLabel, bodyText, level}`(강행 칸 0) | **C** 🆕 `dto/operations.dart`(✅ 병합 PR #163 squash `6b8ed02` · 01 §28 K2~K20 · `S05` · `EngineStatusChip`·`LiveDryRunObservationVm`·`SettingsActionCall`·`OperatingModeView` 재사용) |
| 🆕 v1.20 증권사 키·기기·계좌 매핑 | `CredentialListVm` += `modeNotice?` · `leakRunbookLink?` · `lockedLabel?` · `asOf`(cards ≥ 1 · 🔴 `emptyLabel` 칸 0 — K29) · `CredentialCardVm` += `level` · `lastVerifiedText?` · `requirementLabel?` · `whyLine?` · `sealLabel?` · `credentialSlotId?` · `verifyAction?` · `rotateLink?`(🔴 키 조각 칸 0 — K7 · `registerAction` 칸 0 — K6 · `alias`·`kind`·`healthCode`·`usage` 화면 미참조 — K11 · K30) · `DeviceAccessVm` += `leaseLevel` · `leaseEpochText?` · `migrationLink?` · `pairing?` · `emptyLabel?`(viewer 0대) · `lockedLabel?`(리스 편집 칸 0) · `DeviceRow` += `level` · `revokeAction?` · `revokeConfirmText?`(`deviceId` 화면 미참조) · 🆕 `PairingTicketCard{headline, issueAction?, qrSlotId?, expiresText?}`(잠김 밖 발급 XOR QR · QR ⇔ 유효 시각 · 카운트다운·페이로드 0 · K15) · 🆕 `AccountMappingVm{accounts, mappings, verifyAction?, lockedLabel?, asOf}` · 🆕 `AccountRow{label, kindLabel, maskedNumberText, checkText?, badgeText?, level}`(번호 = 엔진 마스킹 글자 · 종류 코드·별칭 칸 0) · 🆕 `SleeveMappingRow{sleeveLabel, accountLabel?, subbookLine?, statusLine?, level, options}`(칸 수 = 받은 `mappings` · POT 행 0 — K20) · 🆕 `AccountMappingOption{label, selected, impacts = [], blockedText?, selectAction?}`(미리 판정 · SAF-309 = `blockedText` · 🔵 K39 — v1.12 `AccountOption`(`ManualFillFormSpec`)과 이름 겹침 회피) · 잠김 = `lockedLabel` + 화면별 비우는 칸(K35) | **C** `dto/settings.dart`·`ops.dart` 추가형 · 🆕 `dto/accounts.dart`(✅ 병합 PR #187 squash `52f2fc9` · 01 §29 K5~K21 · K29~K35 · K39 · `S02`·`S06`·`S03` · `dto.dart` export 맨 앞) |
| 🆕 v1.21 킬스위치 재개 게이트 · 서약 | 🆕 `dto/safety_gate.dart` — `KillResumeGateVm{readinessLabel, level, etaText?, cooldown?, items, nextItemNo?, blockedText?, lockedLabel?, asOf}` · `KillResumeItemRow{itemNo, label, replayText?, answeredText?, level, choices}`(`replayText` = SPEC «발동 때 답을 위에» · K37) · `KillResumeChoice{label, scenario?, condition?}`(3·4번 선택지 · 칸 정확히 하나) · `PledgeVm{lines /* 0 또는 3 */, statusLine?, replayNotice?, editable, lockedLabel?, asOf}`(엔진 글자 없는 칸 = null · K16) · 🔴 카운트다운 0 · 해제 버튼 0 · 7문항 글자 = SPEC v2.40 04 §3-6 «재개판»(K38) · 01 §30 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16 | **B** `dto/safety_gate.dart` |
| 🆕 v1.22 사다리 · 재개 게이트 · E13 제출 | `dto/safety_gate.dart` += `BreakerLadderVm{rows, asOf}` · `BreakerLadderRow{level, label, triggerText, releaseText, actionText, current}`(행 5 = `BreakerLevel` 차례 · `current` 정확히 하나 · 글자 = 엔진 `breakerLadderOf` 출력 그대로 · K65) · `dto/resume.dart` += `ResumeGateVm{headline, modeLabel, level, rows, reportLink?, lockedLabel?, asOf}` · `ResumeGateRow{workId, oneLine, reasonCode, reasonLabel, level, actions}`(계절 3택 = 행마다 `actions` · `workId` 화면 미참조 · 잠김 ⇒ 모든 행 `actions` 빈 · K64) · 제출 DTO 4(`commands/safety_actions.dart`) `StoppedDecisionSubmission{choice, familyAgreement, rationaleBefore, expectedOutcome, ruleCited}` · `PostmortemSubmission{incidentId, text}` · `RuleChangeApprovalSubmission{requestId, goldenChanged?, approver, thirdPartyNotified}` · `DiscretionAdjustSubmission{deltaPct /*원문*/, decisionId?}`(구현이 짓는 id 칸 0 · K53) · `KillChecklistSubmission`(`commands/payloads_x7.dart` · 13칸 원문 · K60) · 🔴 카운트다운 0 · 해제 버튼 0 · 01 §31 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17 | **B** `dto/safety_gate.dart` · `dto/resume.dart` · **D** 제출 DTO |
| 🆕 v1.23 월 납입 설정 | `MonthlyContributionVm` += `asOf` · `lockedLabel?` · `changeLabel?`(`editable` = ui 미참조 표식 · K79) · 제출 DTO `ContributionUpdateSubmission{amountInput /*원문*/}`(JSON `amount_input` · 손질 0 · 파싱·범위 판정 = 엔진 · K77 · K103) · 🔴 금액 리터럴 0(C-32) · 01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17 | **C** `dto/settings.dart` · **D** `commands/settings_actions.dart` |
| 기타 | `MomentumPanel` · `CalendarSyncStatus` | **B** `dto/holdings.dart`·`calendar.dart` |

---

## §4. ④ 리포지토리 인터페이스 — 영역 **D** · `lib/src/repositories/`

> 🔴 **인터페이스만 둔다.** 구현체는 `data_sync` 의 `LocalSqliteReader`(폰 정본 SQLite) / `SupabaseReadModel`(viewer RLS + Realtime) 둘이다.
> **계약 3조** ① 두 구현체는 **같은 필드값**을 낸다(viewer 전용 필드 금지 — 유일한 예외가 §10-7 «값 비움») ② 모든 스트림은 `AsOf` 를 싣고 viewer 의 «엔진 정지»는 `observedAt` 신선도에서 **파생** ③ 데이터가 없으면 빈 리스트가 아니라 `ListResult` 를 준다.

| 파일 | 인터페이스 · 시그니처 |
|---|---|
| `journal_repository.dart` | `JournalRepository`<br>`Stream<ListResult<TradeJournalEntry>> watchTimeline({required DateRange range, SleeveId? sleeve, String? symbol, JournalStatus? status, FillOrigin? origin, String? rebalanceEventId, RunMode mode = RunMode.live, int limit = 100})`<br>`Future<TradeJournalEntry?> findByDecisionId(String decisionId)`<br>`Future<List<TradeJournalEntry>> chainOf(String decisionId)`<br>`Future<List<TradeJournalEntry>> fillChain(String entryId)` 🆕X7 — ORIGINAL→REVERSAL→RESTATEMENT<br>🆕 **v1.5(01 §15-3 · §8 미결 49 · 11번째 창구)** `Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId)` — 키 = 셸이 라우트 `journalRebalance` 의 파라미터에서 꺼내 `JournalTimeline(rebalanceEventId:)` 로 준 값 · null = 엔진이 그 회차를 모른다 → 칩 **부재** · 🔴 엔진 규칙: null 이면 같은 id 의 `watchTimeline` 은 0행이고 «없음»의 문장은 그 봉투의 `emptyLabel`(봉투 없는 VM 의 «스트림 에러» 잠정 규칙 — 미결 50 ③ — 과 다른 축) · 🔴 `journalTimelineLink` 가 non-null 인 회차에는 null 을 주지 않는다 · 🔴 화면이 `RebalanceRepository` 를 구독해 글자를 조립하지 않는다. `watchTimeline` 시그니처 무변경(회차 조건 = `rebalanceEventId` 인자 · 씨앗 기간 = 이 창구의 `range`)<br>🆕 **v1.7(01 §16 · §8 미결 46 · 12·13번째 창구)** `Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({RunMode mode = RunMode.live})` — `J-4` 채점 **대기** 목록(봉투 · 빈 상태 = `emptyLabel`) · 🔴 행 `result` 늘 null · 엔진 정렬(오래된 결정부터 — K4) · 🔴 채점 집행으로 `result` 가 실리는 **같은 갱신에서** 그 결정은 목록에서 빠진다 · 🔴 행 수 = 같은 mode 배지 «리뷰 대기 n건»의 n · 큐가 비면 배지 행 부재(«0건» 금지) · `J-4` 는 인자 없이(v1.7 = LIVE 만 · K24 · SIM = 미결 99)<br>🆕 **v1.7** `Stream<BlindReviewCard> watchBlindReviewCard(String decisionId)` — 고정 카드 1건 · 채점 집행 뒤 **같은 스트림에** `result` 가 실린 값(02 M6-13 «재조회») · 모르는 id = 스트림 에러(미결 50 ③ 잠정 규칙) · 🔴 `watchDecisionDetail`·`watchDecisionJournal`·`watchTimeline` 으로 카드를 조립하지 않는다 |
| `holdings_repository.dart` | `HoldingsRepository`<br>`Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false})` — 🔴 기본 false(결정 8) · `external_holding` 표시 UNION 은 **여기 한 곳**(C-23)<br>🆕 **v1.8(01 §17)** `Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false})`(`H6-1` · 뷰어 = `pnl` 미적재 · K15) · `Stream<HoldingDetailVm> watchHoldingDetail(String holdingId, {bool includePnl = false})`(`H6-2` · 모르는 id = 스트림 에러 · 잠정 — 01 §8 미결 50 ③) · `Stream<SleeveAllocationVm> watchAllocation()`(`H6-3` · 홈 블록 4 도 이 창구) — 🔵 `watchHoldings` 는 남는다(`H6-*` 미사용 · C-44 ⑬) |
| `performance_repository.dart` | `PerformanceRepository`<br>~~`Future<PerformanceSeries> series({required PerfMetric metric, required PerfGranularity granularity, required bool cumulative, required DateRange range})`~~ 🆕 **v1.3(01 §13-4)** `Future<PerformanceSeries> series({required PerfMetric metric, required PerfGranularity granularity, required bool cumulative, DateRange? range})` — `range == null` = 엔진 기본 구간(무엇이 골라졌는지는 `periodLabel`) · 🔴 `weekly` 로는 화면이 부르지 않는다(01 §8 미결 54)<br>`Future<MonthlyReport> monthlyReport(String yyyyMm)`<br>`Future<AfterTaxLadder> afterTaxLadder({required String fiscalYear})` — 🔴 **인자는 연도 하나** · 갈래는 계좌 매핑에서 파생<br>`Future<ReportArchiveVm> reportArchive()`<br>`Stream<DisclosureGateVm> watchDisclosureGate()`<br>`Future<DrawdownContextVm> drawdownContext({DateRange? range})`<br>`Future<ContributionVm> contribution({required DateRange range})`<br>~~`Future<AnnualReviewVm> annualReview({required String year})`~~ 🆕 **v1.6(01 §15-4 · K24 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13))** `Future<AnnualReviewVm> annualReview({String? year})` — `year == null` = **엔진 기본 연도**(권고: 12월 창 열림 = 그해 · 그 밖 = 마지막 완결 연도 · 완결 연도가 없으면 그해 · 고른 연도는 `vm.yearLabel`) · 🔴 `S7-7` 은 이 창구 **하나만**(인자 없이) · 세후는 VM 의 `afterTax`·`afterTaxCounterfactual` — `S7-7` 은 `afterTaxLadder` 를 부르지 않는다(`afterTaxLadder` 무변경 · R12 소비자 0)<br>🆕 **v1.4(01 §14-9)** `Future<GoalPathVm> goalPath({required String yyyyMm})` — 받은 달 그대로(`MonthlyReport.goalDeepLink` 의 달) · 숫자 가림은 엔진 읽기 경로 |
| `rebalance_repository.dart` | `RebalanceRepository`<br>~~`Stream<List<RebalanceEvent>> watchEvents(DateRange r)`~~ ~~🆕 **v1.5(01 §15-3 ★ⓒ)** `Stream<ListResult<RebalanceEvent>> watchEvents(DateRange r)`~~ 🆕 **v1.6(01 §15-4 · 발주자 결정 ① 2026-10-07 · K26)** `Stream<ListResult<RebalanceEvent>> watchEvents({DateRange? range})` — `S7-6a` 회차 타임라인 · `range == null` = **전체 기간**(첫 회차부터 · 기간으로 자르지 않는다 — `series` 의 null(«엔진이 고른 구간»)과 뜻이 다르다 · 그래서 봉투에 기간 글자를 두지 않는다 · `hasMore` 늘 false) · 🔴 R12 화면은 **인자 없이** 부른다(화면이 `DateRange` 를 만들지 않는다) · 어느 모드의 행이 오는지 = 미결 89 · 빈 상태 문장은 봉투 `emptyLabel`(v1.5 · 계약 3조 ③) · 🔴 `rows` 는 엔진이 **시간 역순**으로 정렬(03 §11-a) · 화면은 재정렬·거르기·세기 0<br>🆕 **v1.5(★ⓐ)** `Stream<RebalanceEvent> watchEvent(String rebalanceEventId)` — `S7-6b`(`RebalanceEventScreen`)가 파라미터 라우트 `rebalanceEvent` 의 `:rebalanceEventId`(셸 → 생성자 인자 → 키)로 **이 창구 하나만** 구독 · 🔴 `watchEvents` 행을 id 로 고르면 반려(거르기도 판정) · 모르는·지난 id = 스트림 에러(**잠정** — `watchDecisionDetail` 과 같은 묶음 · 미결 50 ③)<br>`Stream<NextRebalanceVm> watchNext()`(v1.5 · 🆕 v1.6 시그니처 무변경 — 단 VM 의 두 글자가 nullable · `asOf` 신설 · §3-9) — 🔴 **nullable 이 아니다**(N-4). 「예정 없음」도 값으로 오며 문구는 `emptyLabel` |
| `safety_repository.dart` | `SafetyRepository` — `Stream<SafetyState> watchState()` |
| `alert_repository.dart` | `AlertRepository` — `Stream<List<AlertItem>> watchInbox({AlertLevel? min})`(S-01 P0 점 · 🆕 v1.15 차례 = 엔진 순서 · 등급 순) · 🆕 **v1.15(01 §24 · R14 선행)** `Stream<AlertCenterVm> watchCenter({required bool p0Only})`(`N-01`) · `Stream<AlertDetailVm> watchAlert(String alertId)`(`N-02` · 모르는 id = `missingLabel` 값) |
| `resume_repository.dart` | `ResumeRepository` — `Stream<ResumeReport?> watchLatest()` · `Stream<List<PlannedWorkSummary>> watchPlannedWork()` |
| `ledger_repository.dart` | `LedgerRepository` — `Stream<ListResult<LedgerDiffRow>> watchOpenDiffs()`(🆕 v1.12 뜻 주석 — 최근의 해소·수용 차이도 온다 · G32) · `Stream<ListResult<ExternalHoldingRow>> watchExternalHoldings()` 🆕X7 · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** `Stream<ListResult<LedgerRepairRow>> watchRepairs({int limit = 50})`(`L-2` · 순서 = 엔진 · 뷰어 원천 0 = 미결 117) |
| `onboarding_repository.dart` | `OnboardingRepository` — `Stream<List<OnboardingStep>> watchSteps(OnboardingTrack t)`. 🔴 **`OperatingMode` 를 인자로 넘기지 않는다**(G-01) — 갈래별 준비물의 근거는 `onboarding_choice` · 🆕 **v1.16(01 §25 · K29 · 추가형 · ✅ 병합 PR #96 squash `dd9e162`)** `Stream<OnboardingStartVm> watchStart()`(`O-00`) · `Stream<OnboardingModeChoiceVm> watchModeChoice()`(`O-00b` · 기본값 없음 = `selected` null) · `Stream<OnboardingStepsVm> watchStepList()`(`O-01` · 갈래 인자 0) · `Stream<OnboardingStepDetailVm> watchStep(String stepId)`(`O-02`·`O-03` · 모르는 id = `step` null + `missingLabel`) · `Stream<OnboardingFinishVm> watchFinish()`(`O-04`) · `Stream<RestartVm> watchRestart()`(`R-01`) · `watchSteps` = R15 미호출(존폐 = 01 §8 미결 149) |
| 🆕 `pairing_repository.dart` v1.16 | `PairingRepository` — `Stream<PairingVm> watchPairing()`(`V-01` · 🔴 **뷰어(iOS) 빌드에 주입** · 스캔·토큰 클레임 = 플랫폼(01 §8 미결 13) · 쓰기 0 · 01 §25 K4·K27) |
| 🆕 `incident_repository.dart` v1.17 | `IncidentRepository` — `Stream<IncidentBannerVm> watchIncident()`(`D-01` · 늘 값을 낸다 — 배너 없음 = `banner` null · 스트림 에러 아님 · 셸 주입 `IncidentRepository?` 기본 null = 배너 부재 · 🔴 조립 앱 override 의무 = 06 `M4-12` · ✅ 병합 PR #123 squash `0249f61`) |
| 🆕 `runbook_repository.dart` v1.17 | `RunbookRepository` — `Stream<RunbookIndexVm> watchRunbookIndex()` · `Stream<RunbookVm> watchRunbook(String runbookId)`(모르는 id = `missingLabel` 값) · `Stream<EmergencyCardVm> watchEmergencyCard()`(`D-02`·`D-03` · 원고 번들 · 뷰어 같은 번들 · 별 파일 — K7 · ✅ 병합 PR #123 squash `0249f61`) |
| 🆕 `handbook_repository.dart` v1.17 | `HandbookRepository` — `Stream<HandbookIndex> watchIndex()` · `Stream<HandbookPage> watchPage(String anchor)`(`B-01`·`B-02` · 앵커 = `handbook://` 뒤 전부 · 모르는 앵커 = `missingLabel` · 셸 주입 `HandbookRepository?` 기본 null · 🔴 override 의무 · ✅ 병합 PR #123 squash `0249f61`) |
| 🆕 `settings_repository.dart` v1.18 | `SettingsRepository` — `Stream<SettingsHomeVm> watchHome()`(`S01` · 폰·뷰어 같은 DTO — 뷰어 판 = 폰 전용 행을 엔진이 뺀 VM · 받침대 `UnimplementedSettingsRepository`(동기 throw) · 뒤 카드가 추가형으로 늘린다(R6c `watchOperations` · R7 · R8 · S11) · 🔴 `S07` = 이 창구가 아니라 `OpsStatusRepository.watchConnections()` 그대로 · ✅ 병합 PR #142 squash `b582c49` · 01 §27 K-c·K-v) · 🆕 **v1.19(01 §28 · ✅ 병합 PR #163 squash `6b8ed02`)** `Stream<OperationsVm> watchOperations()`(`S05` · 🔴 폰 전용 — 뷰어 원천 0 · K20 · 받침대 같은 커밋) · 🆕 **v1.20(01 §29 · ✅ 병합 PR #187 squash `52f2fc9`)** `Stream<CredentialListVm> watchCredentials()`(`S02`) · `Stream<AccountMappingVm> watchAccountMapping()`(`S03`)(받침대 같은 커밋 · 🔴 `S06` = 이 창구가 아니라 `OpsStatusRepository.watchDeviceAccess()` 그대로 — K14) · 🆕 **v1.23(01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** `Stream<MonthlyContributionVm> watchContribution()`(`S13` 투영 창구 · 값의 원천 = 엔진 `contributionSettingOf` 하나 · `ConfigRepository.watchContributionSetting()` 그대로 · 주입 +0 · 받침대 동기 throw · K78) |
| 🆕 `kill_switch_gate_repository.dart` · `pledge_repository.dart` v1.21 | `KillSwitchGateRepository` — `Stream<KillResumeGateVm> watchResumeGate()`(M5-2 재개 게이트) · `PledgeRepository` — `Stream<PledgeVm> watchPledge()`(M5-8 서약 · `O-04` ②) · 받침대 `UnimplementedKillSwitchGateRepository` · `UnimplementedPledgeRepository`(동기 throw) · 🔴 기존 `SafetyRepository` · `ResumeRepository` 무변경(넓히면 UI 가짜 7 · ds 구현 2 가 깨진다 — K6) · 01 §30 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16 |
| 🆕 `breaker_ladder_repository.dart` · `resume_gate_repository.dart` v1.22 | `BreakerLadderRepository` — `Stream<BreakerLadderVm> watchLadder()`(M5-4 사다리) · `ResumeGateRepository` — `Stream<ResumeGateVm> watchGate()`(X2 재개 게이트 · E14j) · 받침대 `UnimplementedBreakerLadderRepository` · `UnimplementedResumeGateRepository` · `UnimplementedResumeRepository`(동기 throw) · 🔴 기존 `ResumeRepository` 무변경(K6) · 01 §31 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17 |
| `calendar_repository.dart` | `CalendarRepository` — `Future<CalendarSyncStatus> status()` |
| `config_repository.dart` | `ConfigRepository`<br>`Stream<FeatureFlags> watchFlags()`<br>`Stream<List<SleeveCatalogEntry>> watchSleeves()`<br>`Stream<List<DateRange>> watchRangePresets()` 🆕G-38 — 🔴 목록 길이·순서도 엔진이 정한다<br>`Stream<ContributionSetting> watchContributionSetting()` 🆕G-07 — ⚠️ 소속 리포지토리는 M2-8 택일 |
| `advice_repository.dart` 🆕X7 | `AdviceRepository`<br>`Stream<ListResult<AdviceItem>> watchInbox({AdviceStatus? status, int limit = 50})`<br>`Stream<AdviceInboxSummary> watchSummary()`<br>`Future<AdviceItem?> findById(String adviceId)`<br>`Stream<ListResult<AdviceItem>> watchHistory({required DateRange range})`<br>`Stream<ManualFillFormSpec> watchManualFillFormSpec()` — 🔴 **Future 가 아니라 Stream**(A16)<br>`Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId)` ⚠️ M2-8 — 🔴 `fillChain(entryId)` 와 **다른 것**(G-23) |
| `ledger_trust_repository.dart` 🆕X7 | `LedgerTrustRepository` — `Stream<LedgerTrustBadge> watchGrade()` · 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** `Stream<SelfReportSession> watchSelfReportSession(String yyyyMm, String accountAlias)`(키 = 라우트 두 값 · 세션을 여닫지 않는다 — `SettingsActions` · K9) |
| `execution_gap_repository.dart` 🆕X7 | `ExecutionGapRepository` — ~~`Future<ExecutionGapReport> monthly(String yyyyMm)`~~ 🆕 **v1.6(01 §15-4 · K1·K8 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13))** `Future<ExecutionGapResult> monthly({String? yyyyMm})` — `yyyyMm`(`yyyy-MM`) == null = **엔진 기본 달**(권고: 월간 리포트가 발행된 가장 최근 달 · 기간은 `report.periodLabel`) · 「계획」 탭 ⑤ = null · `S7-1` ⑧ = 그 달(`AppRoutes.ledgerExecutionGapMonth` → 셸 → `ExecutionGapScreen(yyyyMm:)` → 이 인자) · `Stream<ExecutionGapReport> watchRolling()`(무변경 · 🔴 R12 화면 미사용 — 롤링 창 정의 = 06 X7-4) |
| `ops_repository.dart` 🆕G-29 | `OpsStatusRepository` — 🆕 **v1.18(01 §27 K-r~K-t · ✅ 병합 PR #142 squash `b582c49`)** `watchConnections()` 시그니처·받침대 7 무변경 · 반환 `ConnectionsVm` 칸 개정(§3-14 v1.18 행 · `S07`) · 🆕 **v1.20(01 §29 K14~K18 · ✅ 병합 PR #187 squash `52f2fc9`)** `watchDeviceAccess()` 시그니처·받침대 무변경 · 반환 `DeviceAccessVm`·`DeviceRow` 추가형 칸 + 🆕 `PairingTicketCard`(§3-14 v1.20 행 · `S06`) · 🆕 **v1.17(01 §26 K17 · 추가형 · ✅ 병합 PR #123 squash `0249f61`)** `Stream<DeviceRiskVm> watchDeviceRisk()`(`H-03` · 받침대 6 → 7) · ~~`Stream<ListResult<WatchdogCheck>> watchWatchdog()`~~ 🆕 **v1.15(01 §24 · K3)** `Stream<WatchdogBoardVm> watchWatchdog()` · `Stream<ConnectionsVm> watchConnections()` · `Stream<DeviceAccessVm> watchDeviceAccess()` · `Stream<BackupVm> watchBackup()` · `Stream<DiagnosticsVm> watchDiagnostics()`(🆕 **v1.13 주석만(01 §23 · ⬜ 로컬 커밋 — PR 대기)** — `H-01` 블록 6(R13b)의 원천도 이 창구 · 칸 색 = `DiagnosticCell.level` · 뷰어 = 01 §8 미결 128) · `Stream<AnnualReviewVm> watchAnnualReview()`(`S12` · 🆕 **v1.6 주석만(K25 권고 선반영)** — 이 창구의 `AnnualReviewVm` 은 `afterTax`·`afterTaxCounterfactual` 을 **null** 로 준다(엔진 의무 · 세후 수치는 M7 `S7-7` 한 자리에만 · `S12` 표시 범위 = 미결 95 · 소비 쪽 참조 0 = C-42 ⑫))<br>`OpsSummaryRepository` — `Stream<OpsDailySummary> watchToday()` |
| `what_if_api.dart` | `WhatIfApi` — 🔴 **리포지토리가 아니라 부작용 0의 로컬 재계산**(구 `PlannerRepository` 폐기)<br>~~`Future<DepositPlan> simulateDeposit({required Decimal amount, required String accountAlias})`~~ 🆕 **v1.4(01 §14-3)** `Future<DepositPreviewResult> simulateDeposit({required String amountInput})` — 입력칸 글자 그대로 · 파싱·범위·차단·계좌 라우팅은 엔진 · `Future` 에러 = 인프라만<br>`Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount})`(⏸ 인출 규칙 결정 뒤 첫 minor 에서 바뀐다 · 01 §14-15)<br>~~`Future<RebalancePreview> previewRebalance({TradeDate? plannedDate})`~~ 🆕 **v1.6(01 §15-4 · 결정 ②)** `Future<RebalancePreviewResult> previewRebalance({TradeDate? plannedDate})` — `S7-6c` «지금 기준 초안 보기» **탭 뒤에만 · 인자 없이** 부른다(진입·알림·`watchNext` 값만으로는 호출 0) · 결과 캐시 0 · 마지막 요청만 · `Future` 에러 = 인프라만(초안 영역 에러 + 같은 버튼 재시도) · `plannedDate == null` = `watchNext` 와 같은 판정의 다음 예정 회차(그날은 `plannedDateText`) · 예정 회차 없음·계산 막힘 = `blockedText`(화면이 flagId 로 버튼을 끄지 않는다 — D21 준용) · 🔴 `S7-6c` 는 `estimateCosts`·`findPlan`·`simulateDeposit` 을 부르지 않는다<br>`Future<CostEstimate> estimateCosts(String planId)`<br>`Future<DepositPlan?> findPlan(String planId)` 🆕 v1.4 — null = 그 planId 가 없다 · 🔴 플래너(S7-4)는 `simulateDeposit` 만 부른다(`estimateCosts`·`findPlan`·`previewRebalance` 0 — C-38 ⑪ · 01 §14-8) |

- 🔴 **정렬·페이징은 엔진 몫**이다. 페이징은 커서가 아니라 `limit` 증가 재구독 하나(1인 사용자·연 ~934건).
- 🔴 **거르기도 판정이다** — `origin`·`rebalanceEventId` 필터를 화면이 `rows` 위에서 재현하면 반려.
- 🔴 홈 블록 5·7 의 «세는 수»는 전부 엔진이 세어 **문자열로** 준다(`OpsDailySummary`). 화면이 목록 길이로 만들지 않는다.
- 🆕 **v1.6 호출 표(01 §15-4 · R12 화면)** — `S7-6a` = `watchEvents()`(인자 없음) · `S7-6b` = `watchEvent(rebalanceEventId)` · `S7-6c` = `watchNext()` 구독 + 탭 뒤 `previewRebalance()` 1회 · `S7-7` = `annualReview()`(인자 없음) · `S7-10` = `monthly(yyyyMm: <생성자 값>)`(null 가능). 부르지 않는 것 = `estimateCosts`·`findPlan`·`simulateDeposit`·`afterTaxLadder`·`OpsStatusRepository`·`watchRolling`·`LedgerTrustRepository.watchGrade`·`CommandApi` — C-42 ④⑬ 이 소스로 본다.
- 🆕 **v1.6 받침대(`lib/testing.dart`)** — 🆕 `UnimplementedExecutionGapRepository`(`monthly`·`watchRolling` · 리포지토리 받침대 관행대로 동기 throw) · `UnimplementedRebalanceRepository.watchEvents({DateRange? range})` · `UnimplementedWhatIfApi.previewRebalance` → `Future<RebalancePreviewResult>` 에러(그 클래스 관행) · `UnimplementedPerformanceRepository.annualReview({String? year})`. Ops 받침대는 만들지 않는다(`S7-7` = `PerformanceRepository` 하나).
- 🆕 **v1.7 호출 표(01 §16 · `J-4`)** — `watchBlindReviewQueue()`(인자 없음 · 고정 카드가 없을 때) · `watchBlindReviewCard(pinnedId)`(`pinnedId` = 큐 `rows[0].decisionId` · 잡는 순간의 값) · `submitBlindReviewScore(BlindReviewScore(...))` 탭 1회 · `watchCommand(receipt.commandId)` · `AppLinkOpener.open` · 안전 상태 = 기존 `journalSafetyStateProvider` 재사용. 부르지 않는 것 = J-4 2개 밖 `JournalRepository` 11개 · `.watchState(` · `HoldingsRepository`·`PerformanceRepository` · `DraftStore` · `journalCommandApiProvider`(operator) · 다른 명령 전부(`recordDisclosureView` 포함 — K6 확정: 결과 공개 = 결정 8 열람 기록 없음 · `S7-2G` 게이트 없음) — C-43 ⑪ 이 소스로 본다.
- 🆕 **v1.7 받침대(`lib/testing.dart`)** — `UnimplementedJournalRepository.watchBlindReviewQueue({RunMode mode = RunMode.live})` · `watchBlindReviewCard(String)`(동기 throw) · 명령 받침대 무변경(`UnimplementedCommandApi.submitBlindReviewScore` 는 v1.1 부터).
- 🆕 **v1.8 호출 표(01 §17-8 · `H6-*`)** — `H6-1` = `watchHoldingsOverview(includePnl: <State 변수>)`(진입 false · 펼침 1회 = true 재구독 · 🔴 리터럴 `true` 금지 — C-44 ⑭) · `H6-2` = `watchHoldingDetail(<생성자 holdingId>, includePnl: …)` · `H6-3` = `watchAllocation()` + `RebalanceRepository.watchNext()`(하단 D-day) · 안전 = `journalSafetyStateProvider` · 🔴 부르지 않는 것 = `watchHoldings` · `ConfigRepository` · `JournalRepository` 전부 · `LedgerRepository` · `CommandApi` 전부(`recordDisclosureView` 0 = 결정 ⑤) · `SafetyRepository.watchState` 직접.
- 🆕 **v1.8 받침대(`lib/testing.dart`)** — 🆕 `UnimplementedHoldingsRepository`(`watchHoldings`·`watchHoldingsOverview`·`watchHoldingDetail`·`watchAllocation` · 동기 throw · 그전까지 받침대가 없어 `implements` 가 강요됐다).
- 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** **창구** — `OpsSummaryRepository.watchRhythm()` → `Stream<ListResult<OpsRhythmRow>>`(`H-02` 전체 리듬 · `watchToday().upcoming` = 이 목록의 앞 ≤3 · 뷰어 = `rm_ops_summary` · K29) · `OpsDailySummary.resumeLine` ? `LinkAction`(`H-01` 블록 2 · K44) · `AdviceRepository.fillsOfAdvice` 주석 «받은 순서 그대로 · 접기 = 미결 115 · 뷰어 빈 목록»(K18·K40) · `watchInbox` 인자 없이(`A-1`) · `watchHistory` 범위 = `watchRangePresets()` 의 `isDefault`(K38).
- 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** **호출 표**(01 §21-8) — `L-1` `watchOpenDiffs()` · `L-2` `watchRepairs()` · `A-1` `watchInbox()`·`watchSummary()`·`deferAdviceConfirm(id)`(확인 카드 「내일 다시」 · 예외 1) · 「지난 안내」 `watchRangePresets()` → `watchHistory(range:)` · `A-2` `findById`·`fillsOfAdvice` · `A-3` `findById`·`watchManualFillFormSpec`·`DraftStore`·`recordManualFill(ManualFillSubmission)`·`watchCommand` · `A-4` `skipAdvice(AdviceSkipSubmission)` · `L-3` `initState` 에서 잡은 `SettingsActions` 로 start · `dispose` 에서 같은 인스턴스로 stop · `watchSelfReportSession` · `submitSelfReportBalance(SelfReportSubmission)`.
- 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** **받침대(`lib/testing.dart` · K28)** — 🆕 `UnimplementedLedgerRepository`(3) · `UnimplementedAdviceRepository`(6) · `UnimplementedLedgerTrustRepository`(2) · `UnimplementedOpsSummaryRepository`(2 · v1.6 «Ops 받침대 0» 은 `S7-7` 한정이었다) · `UnimplementedSettingsActions`(`Future` 에러 / 에러 스트림 — `dispose` 경로에서도 동기 throw 0) · `UnimplementedCommandApi` X7 3 서명 교체 + `deferAdviceConfirm`.

---

## §5. ⑤ 명령 API · 명령 인자 · `CommandReceipt` 상태기계 · `CommandContext` · `SettingsActions` — 영역 **D** · `lib/src/commands/`

### 5-1. `command_api.dart` — `CommandApi`(앱이 호출할 수 있는 **전부**)

```
Future<CommandReceipt> activateKillSwitch({required String reasonFreeText, required String deviceId})
Future<CommandReceipt> submitJournalDraft(JournalDraft draft)
Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score)
Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event)
Future<CommandReceipt> registerDeposit(DepositRegistration registration)   // 🆕 v1.4(01 §14-2) — 폰(operator) 전용 · 뷰어 화이트리스트 밖
Stream<CommandReceipt>  watchCommand(String commandId)
// ── X7 7종 · 🔴 전량 폰(operator) 전용 ──
Future<CommandReceipt> recordManualFill(ManualFillSubmission submission)    // 🆕 v1.12 인자 교체(구 ManualFillRecord · K4)
Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment)
Future<CommandReceipt> voidManualFill(ManualFillVoid v)
Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission)          // 🆕 v1.12 인자 교체(구 AdviceSkip)
Future<CommandReceipt> submitSelfReportBalance(SelfReportSubmission submission) // 🆕 v1.12 인자 교체(구 SelfReportBalance)
Future<CommandReceipt> acknowledgeAlert(String alertId)                     // 🆕 v1.15(01 §24 · K12) 인자 교체(구 AlertAck · 와이어 무변경 · alertId 단위 멱등)
Future<CommandReceipt> confirmKillChecklist(KillChecklistAck ack)
Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record)          // 🆕 v1.10 ㊲
Future<CommandReceipt> deferAdviceConfirm(String adviceId)                  // 🆕 v1.12(K14 ⓐ) 만료 확인 카드 「내일 다시」
```

- 🆕 **v1.12(01 §21 · ⬜ 로컬 커밋 — PR 대기)** — 🔴 X7 기록 3종의 인자 = «화면 제출» DTO(`payloads_x7.dart` · 초안 본문 원문 + 키 + 확인값 · 셋 다 `fromJson`) · 파싱(`int`·`Decimal`)·`CommandContext`·`sessionStartedAt`·`asOfTradeDate` 부착 = 구현 · 실패 = 큐 적재 없는 `rejected` 접수증(`INPUT_INVALID` · 세션 밖 = `SELF_REPORT_OUTSIDE_SESSION`) · `watchCommand` 구현 의무 ④(로컬 거부 id 도 종단 `rejected` 1값 · K42) · `CommandReceipt` +`retryCode`·`retryLabel`(재제출 선택지 · `rejected` 만 · 제출 DTO `retryCodes` 누적 · K20) · 와이어 `AdviceDeferConfirm{adviceId, context}`.

- 🔴 **킬스위치 «해제» 명령은 없다**(결정 6). `deactivate` 제안은 거절이 기본값.
- 🔴 ~~**뷰어가 쓸 수 있는 것은 앞 5종**~~ 🆕 **v1.4(01 §14-2) — 뷰어가 쓸 수 있는 것은 앞 4종**(킬스위치 발동 · 저널 초안 · blind 리뷰 점수 · 열람 기록 · `registerDeposit` = `DEPOSIT_REGISTER` 는 폰 전용)이며 X7 7종은 뷰어 화이트리스트를 건드리지 않는다. ⚠️ `ALERT_ACK` 의 뷰어 허용만 §8-10 미결.
- 🔴 **화면이 `state` 를 낙관 갱신하지 않는다** — 「요청됨」과 「집행됨」의 구별이 이 계약의 목적이다.
- 🔴 **인자가 2개를 넘는 명령은 전부 DTO 로 받는다**(`@DecimalStringConverter()` 는 필드 어노테이션이라 메서드 인자에서 무효).

### 5-2. `CommandReceipt` 상태기계

| 필드 | 타입 |
|---|---|
| `commandId` R String · `kind` R `CommandKind` · `state` R `CommandState` · `stateLabel` R String(엔진 생성) · `requestedAt` R DateTime · `expiresAt` R DateTime(TTL) · `nonce` R String · `issuedByDeviceId` R String · `rejectReasonCode` ? String |

```
requested ──▶ received ──┬──▶ executed        (종단)
                         ├──▶ rejected        (종단 · rejectReasonCode 필수)
                         └──▶ expired         (종단 · 서버 expires_at)
requested/received ──┬──▶ staleContext        ┐
                     ├──▶ heldForIntegrity    ├ 🔴 보류 3(+1)상태 — TTL 을 소비하지 않는다
                     ├──▶ pendingLeaseConfirm ┘   재확인·인수·복구 후 received 로 되돌아온다
                     └──▶ noOperator (⚠️ M2-8) — 소비할 엔진이 없는 창(X1 이전·비상 TTL 대기)
```

- 🔴 **보류는 거부가 아니다.** 무결성 차단·리스 만료·오프라인·맥락 불일치에서 기록 명령을 **거부하지 않고 보류**한다 — 명령은 ⓐ 기기 로컬 내구 큐(암호화·재부팅 생존·**만료 없음**)에 먼저 쌓이고 ⓑ 네트워크가 되면 `command_queue` 에 INSERT.
- 🔴 **거부는 초안을 지우지 않는다**(C17). 초안 삭제는 `state == executed` 수신 시에만.
- 🔴 **멱등은 봉투가 보장한다** — payload 에 `idempotencyKey` 를 **두지 않는다**(`command_id` + `unique(kind, nonce)`). 중복은 `DUPLICATE_SUSPECTED` 거부 + `duplicateAck = true` 재제출.
- 🔴 `noOperator` 의 표시 문구는 **M2 가 사전 공급한 고정 카탈로그**에서 고른다(앱이 상태를 조합해 문장을 만들지 않는다 — §10-8).

### 5-3. `command_context.dart` — `CommandContext`

| 필드 | 타입 |
|---|---|
| `runMode` R `RunMode`(발행 시점) · `operatingMode` R `OperatingMode`(발행 시점) · `leaseEpoch` R int(발행 시점 X1 리스 epoch) · `deviceId` R String |

- 🔴 **`context` 를 채우는 것은 화면이 아니라 `CommandApi` 구현이다**(G-19). 뷰모델·화면 계층에서 `CommandContext` 를 **생성하는 코드 0건**을 **C-28** 이 검사한다.
- 🔴 소비 규칙 — 발행 시점 맥락으로 판정하고, 소비 시점 런타임과 다르면 **거부하지 않고 `staleContext`**. 단 **`runMode` 불일치는 예외 없이 거부**한다(파일 경계는 협상 대상이 아니다).
- ⏸ 기존 5종에도 붙일지는 M2-8(§8-21).

### 5-4. `payloads.dart` — 명령 인자 DTO

| 타입 | 필드 |
|---|---|
| `DepositRegistration` | ~~`planId` R String · `amount` R `@D Decimal`(🔴 **예시값** — 금액은 설정값에서 온다) · `valueDate` R `TradeDate`~~ 🆕 **v1.4(01 §14-7)** `planId` R String **하나** — 금액·기준일은 엔진이 계획 스냅샷에서 가져온다(화면이 보내지 않는다 · 실입금 대조 = 원장 · 06 M3-2) |
| `JournalDraft` ⚠️M2-8 | 최소 축 = `decisionId` · `rationaleBefore` · `expectedOutcome` · `ruleCited`(🔴 **엔진 제공 목록** · 자유 입력 금지) · `note` |
| `BlindReviewScore` ~~⚠️M2-8~~ ✅ m2-8 H-2 | `decisionId` R String(그려진 카드의 `BlindReviewCard.decisionId` 그대로) · `answers` R `Map<String, int>`(문항 id → 점수) — 🆕 **v1.7(01 §16 · 필드 무변경)** 점수 = 고른 `BlindReviewChoice.score` 를 **그대로 옮긴 값**(코드→점수 변환 0) · 🔴 카드의 **전 문항**을 싣는다(부분 제출 없음 — K10) · 최종 판정 = 엔진(거부 사유 = `BlindReviewRejectCodes` — `BLIND_REVIEW_ALREADY_SCORED`·`BLIND_REVIEW_ANSWERS_INVALID` · 사전 키 `blind_review_reject`) |
| `DisclosureViewEvent` ⚠️M2-8 | 최소 축 = `surfaceCode` · `viewedAt` · `durationSec`. ~~🔴 **집계 키 `yyyy_mm` 은 엔진이 `viewedAt` 에서 파생**한다(G-42)~~ · 🆕 **v1.3(01 §13-6)** — 🔴 집계 키 `yyyy_mm` 은 화면이 넣지 않는다(G-42 그대로) · `surfaceCode` R String(값의 정본 = `DisclosureSurfaceCodes`) · `viewedAt` R DateTime(「그래도 보기」를 누른 순간의 주입 시계 값 · 관측 시각 — 집계 월은 엔진이 접수·서버 시각으로 확정) · `durationSec` int(**기본 0** — required 에서 바뀜 · 화면은 적지 않는다 · C-37 ④) |
| `ManualFillRecord` | `adviceId` ? String(null = 안내 무관 수기 신규 → `MANUAL_ENTRY`·예산 차감) · `tradeDate` R `TradeDate` · `symbol` R String(🔴 **`sleeve` 를 보내지 않는다** — 엔진이 판정) · `side` R `OrderSide` · `quantity` R int · `price` R `@D Decimal` · `commission` ? `@D Decimal`(null = 미입력 ≠ 0) · `tax` ? `@D Decimal` · `accountAlias` R String · `offHourTrade` R bool(🔴 폼 체크박스가 **아니다** — 거부 뒤 엔진이 준 옵션으로만 true) · `duplicateAck` R bool(기본 false) · `prefilledFields` R `List<String>`(기본 빈 목록) · `deviationNote` ? String · `context` R `CommandContext` |
| `ManualFillPatchable` | `tradeDate` R · `quantity` R int · `price` R `@D Decimal` · `commission` ? · `tax` ? · `accountAlias` R String · `offHourTrade` R bool · `deviationNote` ? String. 🔴 **`symbol`·`side` 는 여기 없다**(A13) |
| `ManualFillAmendment` | `targetFillId` R String · `replacement` R `ManualFillPatchable`(🔴 부분 패치가 아니라 **전체 값**) · `reasonCode` R String · `note` R String(1줄 필수) · `context` R |
| `ManualFillVoid` | `targetFillId` R · `reasonCode` R · `note` R · `context` R |
| `AdviceSkip` | `adviceId` R · `reason` R `AdviceSkipReason` · `note` ? String(🔴 **예산 코드 2종에만 필수**) · `context` R |
| `SelfReportBalance` | `asOfTradeDate` R `TradeDate` · `purpose` R `SelfReportPurpose`(🔴 **기본값 없음**) · `sessionStartedAt` R DateTime(B15) · `lines` R `List<SelfReportLine>` · `cashKrw` R `@D Decimal` · `accountAlias` R String · `declaredComplete` R bool · `context` R |
| `AlertAck` | `alertId` R String · `context` R. 🔴 **`SafetyState` 에 아무 효력이 없다**(A5 — P0 승급 사다리 정지만) |
| `KillChecklistAck` | `safetyEventId` R · `openOrdersQueried` R bool · `openOrdersCancelled` R bool · `remainingCountZero` R bool · `queriedAt` R DateTime · `note` R String(1줄 필수) · `context` R. 🔴 **이것만이 48h 해제 카운트다운을 개시**한다 |
| `LedgerEventRecord` ⏸ | 🔴 결정 ㊲ 채택 시에만 |

- 🔴 `purpose == simOpening` 의 완화 3가지(세션 밖 제출 거부 미적용 · autoTrade 갈래는 `lines` 빈 배열 + `cashKrw` 1칸 · `ledger_sim.sqlite` 만 쓰고 `ledger_diff` 를 열지 않음)는 `periodicAudit` 에 **하나도** 적용되지 않는다.

### 5-5. `settings_actions.dart` — `SettingsActions`(⚠️ `CommandApi` 가 아니다)

```
abstract interface class SettingsActions {
  Future<ActionResult> run(SettingsActionId id, {Map<String, String> args});
  Stream<ActionResult>  watch(String actionRunId);
}
```

| 타입 | 필드 |
|---|---|
| `ActionResult` | `actionRunId` R String · `id` R `SettingsActionId` · `level` R `UiLevel` · `headline` R String(요약·의역 금지) · `reasonCode` ? String(원문 코드 `'EGW00133'` 등) · `handoffRoute` ? String(게이트 필요 동작은 여기로 — M5) · `retryable` R bool |

- 🔴 **폰(operator) 빌드에만 구현체가 주입된다.** 뷰어에서는 `null` 이고 그때 화면은 컨트롤을 **렌더하지 않는다**(«비활성»이 아니라 **부재**).
- 🔴 **`SettingsActions` 는 «동작»만**이다(G-29) — 상태 구독은 `OpsStatusRepository`·`OpsSummaryRepository` 다.
- 🔴 **args 는 화이트리스트**다. 확정분: `handoverAdoptionSet` = `{handover_session_id, symbol, disposition ∈ {ADOPT, EXTERNAL}}` · `handoverExternalRegister` = `{handover_session_id, symbol, quantity, accountAlias, action ∈ {REGISTER, RELEASE}}` · `handoverCommit` = `{handover_session_id}`. 🔴 `handover_session_id` 는 세 동작 모두 **필수**.
- 🆕 **v1.16 온보딩 args(01 §25 · K13·K19·K24 · ✅ 병합 PR #96 squash `dd9e162`)** — `onboardingOperatingModeSelect` = `{operating_mode ∈ {AUTO_TRADE, ADVISORY}}`(값 = `OperatingMode.wire` · 결과 = 접수 / 거부 `ONBOARDING_CHOICE_COMMITTED` · 같은 값 재선택 = 접수) · `onboardingDryRunStart` = `{}`(실패 = 둘 다 되돌림 `DRY_RUN_START_ROLLED_BACK`) · 검증 동작(`credentialVerify` `{kind}` · `connectionTest` `{target}` · `accountVerifyMapping` `{}`) = `OnboardingAction` 이 완성해 싣는다(화면은 그대로 넘긴다) · 🔴 `O-00b`·`O-03`·`O-04` 는 `ActionResult` 의 `headline` + `reasonCode` 원문을 읽는다(`O-03` 만 + `retryable`) · 결과 표본 = `m8/onboarding_mode_select_results` · `_verify_results` · `_finish_results`.
- 🆕 **v1.18 M9 `S07` args(01 §27 · K-r · K-s · K-u · ✅ 병합 PR #142 squash `b582c49`)** — `connectionTest`·`connectionSyncNow` = `{target ∈ ConnectionTargetCodes}` · `notifyChannelSelect` = `{channel ∈ NotifyChannelCodes}`(엔진이 `ConnectionRow.actions`·`NotifyChannelOption.selectAction` 에 완성 — 화면은 그대로 넘긴다 · 01 §8 미결 151 의 `target` 몫 해소) · 🔴 `S07` 은 `ActionResult` 의 `headline` + `reasonCode` 원문(`SettingsResultCodes`)을 읽는다 · `retryable` 전부 false(버튼 = 행 `actions` 뿐) · `handoffRoute` null(표본 `m9/settings_action_results`) · ~~⏸ S05 4동작(`runtimeModeSwitchRequest` · `runtimeOperatingModeSwitchRequest` · `runtimeEngineStart` · `runtimeEngineStop`) args = 계약 v1.19~~(→ 아래 v1.19) · ~~`settingsContributionUpdate` = R8 창~~ 🆕 → v1.23 제출 경로(§5-8).
- 🆕 **v1.19 M9 `S05` args(01 §28 · K6 · K7 · K16 · ✅ 병합 PR #163 squash `6b8ed02`)** — `runtimeModeSwitchRequest` = `{run_mode ∈ RunMode.wire}`(`RunModeCard.switchActions` · 실전 전환 목적지 = 엔진 `handoffRoute`) · `runtimeOperatingModeSwitchRequest` = `{operating_mode ∈ OperatingMode.wire}`(`OperatingModeView.switchActions`) · `runtimeEngineStart` = `{}`(`EngineControl.startAction` · 기동 거부 `reasonCode` ∈ `ModeStartupCodes` ∪ `AdviceRejectCodes.modeCombinationDenied`) · `runtimeEngineStop` = `{reason_code ∈ EngineStopReasonCodes}`(`EngineControl.stopActions` — 사유마다 1) · 🆕 `runtimeLivePromotion` = `{}`(결과 `reasonCode` ∈ `LiveObservationBlockCodes` ∪ `LivePromotionResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`}) · 🔴 키 `target` 금지(C-5 `connection_target` 사전 키) · `S05` 는 `ActionResult` 의 `headline` + `reasonCode` 원문 · `handoffRoute` 가 있으면 열고 끝 · `retryable` 전부 false(표본 `m9/operations_action_results`).
- 🆕 **v1.20 M9 R7 args(01 §29 · K5 · K6 · K19 · ✅ 병합 PR #187 squash `52f2fc9`)** — `credentialVerify` = `{kind ∈ CredentialKindCodes}`(`CredentialCardVm.verifyAction` · 검증 통과 = 구현이 저장 — 1단 · K6) · `devicePairingTicketCreate` = `{}`(`PairingTicketCard.issueAction`) · `deviceTokenRevoke` = `{device_id}`(`DeviceRow.revokeAction` · 확인 = 화면 안 펼침 `revokeConfirmText` · K18) · `accountMapSleeve` = `{sleeve ∈ {A, B, C}, account_alias}`(`AccountMappingOption.selectAction` · 미리 판정 · 원자 저장 · K19) · `accountVerifyMapping` = `{}`(`AccountMappingVm.verifyAction` · v1.16 그대로) · `credentialRegister` = 화면 미호출(args 미정 유지) · 🔴 시크릿 값 args 0(슬롯 위젯 ↔ operator 구현 사이 = 조립 앱) · `SettingsActionId` 값 0 추가 · `S02`·`S06`·`S03` 은 `ActionResult` 의 `headline` + `reasonCode` 원문(`SettingsResultCodes` · `CREDENTIAL_REJECTED` · `Saf309Codes`)을 읽는다 · `handoffRoute`·`retryable` 0(K33 · 표본 `m9/credential_action_results` · `m9/device_action_results` · `m9/account_mapping_action_results`).
- 🔴 **`Config.fx_overlay` 계열 키를 `strategyPreview`·`strategyApplyRequest` 의 args 에 넣지 않는다**(영구 기각된 규칙의 부활 경로).
- 🔴 **`OperatingMode` 전환은 `CommandApi` 에 없다** — `runtimeOperatingModeSwitchRequest` 1종이며 반환 `handoffRoute` 로 위저드에 넘긴다.

### 5-6. 🆕 v1.21 `safety_actions.dart` — `SafetyActions`(넷째 쓰기 창구 · 01 §30 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16)

```
abstract interface class SafetyActions {
  Future<SafetyActionResult> run(SafetyActionId id, {Map<String, String> args});
  Future<SafetyActionResult> runKillResumeItem(KillResumeItemSubmission submission);
  Future<SafetyActionResult> runPledge(PledgeSubmission submission);
  Stream<SafetyActionResult> watch(String actionRunId);
}
```

- 🔴 **폰(operator) 빌드에만 주입 · 뷰어 null = 컨트롤 부재 · `ui_safety` 만 참조**(C-55 ⑯) · 생체 = 구현(계약 포트 0 · K11) · 표면 넷 고정(C-7 새 항) · 메서드 이름 `run…`(`submit…` 은 C-7 쓰기 이름 검사에 걸린다 · K31).
- `SafetyActionId`(`enums/command.dart`) 3 = `killSwitchResume` `KILL_SWITCH_RESUME` · `pledgeWrite` `PLEDGE_WRITE` · `pledgeEdit` `PLEDGE_EDIT`(엔진 data_sync 명령 kind 글자) · 🔴 1.21.0 의 세 값은 전부 제출 DTO 경로 — `run(id, args)` 화이트리스트 0(1.22.0 이 연다 · K39) · `SafetyActionResult` = `ActionResult` 꼴(`id` 타입만 다름) · `SafetyActionCall` = 1.21.0 사용처 0(K47).
- 제출 DTO: `KillResumeItemSubmission`(엔진 `ResumeItemAnswer` − `decisionId` · 숫자 2 = 원문 String · 한 문항씩 · 7번 통과 = 해제 확정 = 엔진 `resume()` · 1번 제출 = 처음부터 · K8 · K34~K36) · `PledgeSubmission{SafetyActionId id /* pledgeWrite · pledgeEdit */, sentences, decisionId?}`(`PledgeSubmitKind` 0 — K32) · 🔴 `CommandApi` 에 해제 명령 0 유지.
- `payloads_x7.dart` `KillChecklistAck` += `KillActivationRecord? activation`(추가형 · 기본 null · 한 명령 `KILL_CHECKLIST_CONFIRM` · 엔진 `KillActivationAnswers` 칸 1:1 · 경로 = 기존 `CommandApi.confirmKillChecklist` · 인자 교체 = 01 §8 미결 183 · K9 · K43) · 열거 4(`enums/safety.dart`) = `KillActivationReason` · `KillActivationScope` · `KillResumeScenario` · `KillResumeCondition`(값 이름 = 엔진 1:1 · 타입 이름은 엔진과 다름 — ambiguous_import 방지 · K10 · K33).
- 받침대(`testing.dart`) `UnimplementedSafetyActions`(`Future` 에러 · 에러 스트림 — `UnimplementedSettingsActions` 꼴).

### 5-7. 🆕 v1.22 `SafetyActions` 표면 8 · E13 제출 · `confirmKillChecklist` 인자 교체 · simToAuto 동작(01 §31 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17)

```
abstract interface class SafetyActions {
  Future<SafetyActionResult> run(SafetyActionId id, {Map<String, String> args});
  Future<SafetyActionResult> runKillResumeItem(KillResumeItemSubmission submission);
  Future<SafetyActionResult> runPledge(PledgeSubmission submission);
  Future<SafetyActionResult> runStoppedDecision(StoppedDecisionSubmission submission);
  Future<SafetyActionResult> runPostmortem(PostmortemSubmission submission);
  Future<SafetyActionResult> runRuleChangeApproval(RuleChangeApprovalSubmission submission);
  Future<SafetyActionResult> runDiscretionAdjust(DiscretionAdjustSubmission submission);
  Stream<SafetyActionResult> watch(String actionRunId);
}
```

- 표면 **8**(C-7 «넷째 쓰기 창구» 개정 · K52) — 사람이 글·수를 치는 넷(STOPPED 결정 · postmortem · 규칙 변경 승인 · 재량 조정) = 제출 DTO 메서드 · 엔진이 완성하는 넷 = `run(id, args)` 화이트리스트 `interventionStep{session_id, stage, outcome, decision_id?}` · `ruleChangeCancel{request_id}` · `reconClear{origin_code, decision_id}` · `seasonalWindowChoice{work_id, choice}`(계절 `decision_id` = 구현 · K54) · 제출 id 를 `run` 으로 부르면 구현 `ArgumentError`(결과 코드 0) · RECON 해제 결과 사전 0(엔진 = 예외 · K55).
- `CommandApi.confirmKillChecklist(KillChecklistSubmission submission)` **인자 교체**(미결 183 ⓐ · K60) — 화면 = 원문 13칸 · 와이어 `KillChecklistAck(+activation)` · 저널 id · 사건 id · 조회 시각 · `CommandContext` = 구현 · 파싱 실패·빈 선택 = `KILL_CHECKLIST_ITEM_MISSING`(큐 적재 없는 rejected 접수증) · 폼 문항 글자 = 1.23.0(미결 186).
- `SettingsActions.run` 화이트리스트 += `handoverSessionStart{path}`(1.22.0 = `SIM_TO_AUTO` 하나) · `handoverSessionCancel{handover_session_id}` · `handoverSimLedgerFate{fate ∈ KEEP|DISCARD}`(🔴 세션 전 · 결정 사유 `SIM_LEDGER_KEEP`·`SIM_LEDGER_DISCARD`) · 확정 = 기존 `handoverCommit{handover_session_id}`(결과 `reasonCode` ∈ `SimToAutoCommitResultCodes` ∪ `SimToAutoResultCodes` ∪ `SimToAutoStepIds` ∪ {`HANDOVER_SESSION_INVALID` · `LEASE_INVALID`} · K58) · 위저드 읽기 VM = 1.23.0(미결 187).
- 받침대(`testing.dart`) `UnimplementedSafetyActions` 표면 8 · 🔴 `ui_safety` 만 참조 · 뷰어 null = 컨트롤 부재(v1.21 그대로).

### 5-8. 🆕 v1.23 `SettingsActions` 표면 3 · 월 납입 원문 제출(01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)

```
abstract interface class SettingsActions {
  Future<ActionResult> run(SettingsActionId id, {Map<String, String> args});
  Future<ActionResult> runContributionUpdate(ContributionUpdateSubmission submission);
  Stream<ActionResult>  watch(String actionRunId);
}
```

- 표면 **3**(C-7 «둘째 쓰기 창구» 개정 · K7 이 표면 고정을 이김 · v1.22 K52 선례 · K77) — 사람이 친 금액 = `ContributionUpdateSubmission{amountInput}` **원문 그대로**(콤마·공백·빈칸·음수·글자 포함 가능 · 파싱·범위 판정 = 엔진 `decideContributionChange`) · `run(settingsContributionUpdate)` = 구현 `ArgumentError` · 결과 id = `settingsContributionUpdate` · `handoffRoute` null · `retryable` false · «화면이 args 키를 짓는» 새 예외 0.
- 결과 `reasonCode` 전집 = `ContributionResultCodes` 6 ∪ {`TRUSTED_TIME_UNKNOWN`, `BIOMETRIC_UNAVAILABLE`} ∪ null(접수) · 🔴 E11k(신뢰 시각) 전 = 형식이 맞는 입력 전부 `TRUSTED_TIME_UNKNOWN`(형식 오류 4종은 그 코드 그대로 · K98) · 표본 `m9/contribution_action_results`(9행).
- 받침대(`testing.dart`) `UnimplementedSettingsActions.runContributionUpdate`(`Future` 에러) · 🔴 apps op stub(`OperatorSettingsActions.runContributionUpdate` = `UnsupportedError` · 행동 0 · K100) · 바인딩 = 06 `M4-12` ⑧(미결 195).
---

## §6. ⑥ 코드 → 문구 매핑 사전 — 영역 **E** · `lib/src/labels/`

> 🔴 **오해 금지**: 문구는 **엔진 소유**이며 런타임에 DTO 의 `label`·`actionLine`·`clearInstruction`·`headline`·`stateLabel` 에 실려 온다. 여기 두는 것은 «어떤 **코드**가 오는가»의 **상수 목록**이지 화면이 코드를 보고 문자열을 고르라는 사전이 아니다. 화면이 매핑을 만들면 **C-5** 가 빌드를 실패시킨다.
> **파일 배치**: `labels/exit_kind.dart` · `saf_codes.dart` · `verdict_codes.dart` · `origin_codes.dart` · `flag_ids.dart` · `advice_codes.dart` · `alert_codes.dart` · `deviation_kind_codes.dart` · `ledger_event_codes.dart` · `labels.dart`(§1-5 조문 주석 + 전 목록 배럴).
> **총 137 코드.** 각 파일은 `abstract final class XxxCodes { static const ... }` 형태의 상수 묶음 + `Set<String>` 전량 목록(픽스처·C-15 대조용)을 낸다.

### 6-1. `exit_kind` — 6종 (01 §3-1)

`CORPORATE`(TIER 0 · 쿨다운 영구) · `STOP`(1A·1B) · `TREND_BREAK`(1.5·2) · `TARGET`(3) · `REBALANCE` · `RISK`. 🔵 v2.31 P0S 에서는 대부분 비집행.

🆕 **v1.8(01 §17)** — 같은 파일 끝 `StopTierCodes` 3종(`TIER_1A`·`TIER_1B`·`TIER_2` · `byDomain 'stop_tier'` · `StopLineNormalized.tierCode` 의 값 — m2-8 E-8 «코드 목록은 영역 E 의 사전»의 실물) · 🔴 키 전용(문구 = `tierLabel`) · C-5 `_fixtureCodeFields` `tier_code` · C-44 ⑦ 이 픽스처와 맞댄다.

### 6-2. SAF 코드 — 접두 7대역 + `SAF309_` 상세 6 (01 §3-2)

접두 = `SAF-1xx`(포지션 리스크 한도) · `SAF-2xx`(슬리브 한도·종목 필터) · `SAF-3xx`(포트폴리오·세금 게이트) · `SAF-4xx`(시스템·주문 게이트) · `SAF-5xx`(드로다운 서킷브레이커) · `SAF-7xx`(타임존·스케줄) · `SAF-8xx`·`SAF-9xx`(장애·보안).
`SAF309_` 상세 6 = `OK_TAX_ADVANTAGED` · `DENY_TAXABLE_ACCOUNT` · `DENY_UNVERIFIED_FAIL_CLOSED` · `WARN_TAXABLE_ACCOUNT` · `WARN_UNVERIFIED` · `NA_QUERY_NOT_AN_ORDER`. 🔴 화면은 배지로만 쓴다(진리표는 주문 게이트의 사양 벡터).

### 6-3. `verdict_code` — 5종 (01 §3-3 · X2 재판정)

`EXECUTED_AS_REEVALUATED` · `EXPIRED` · `SUPERSEDED` · `BLOCKED` · `UNRECOVERABLE`.

### 6-4. 원인 코드 — 20종 (01 §3-4 · X5 대사·정합 · 🔴 자유 서술 거부)

- 브로커 계열 7 — `FILL_LAG` · `MANUAL_ORDER` · `DB_ERROR` · `BROKER_ERROR` · `EXTERNAL_CASHFLOW` · `CORPORATE_ACTION` · `CORP_ACTION`(⚠️ 뒤 둘은 **중복 후보** §8-6 — 통합 전까지 **둘 다 상수로 둔다**)
- 파생 계열 7 — `PUSH_LAG` · `PUSH_FAILED` · `ARCHIVE_LAG` · `CAL_WRITE_FAILED` · `SCHEMA_SKEW` · `CHAIN_BROKEN` · `RESTORE_ROLLBACK`
- X7 계열 6 — `ADVISORY_FILL`(🔴 **안내 모드의 정상 수기 체결** — 없으면 모든 체결이 `MANUAL_ORDER` 로 들어가 매일 SEV2 를 연다) · `UNRECORDED_FILL` · `MISRECORDED_FILL`(→ `ledger_repair(DERIVED_RESYNC)` 1행, C-29) · `SELF_REPORT_CORRECTION` · `EXTERNAL_HOLDING` · `ACCOUNT_MISDECLARED`

### 6-5. 차단 플래그 `flag_id` — 12종 (01 §3-5)

| flag_id | 차단 범위 | `ClearRoute` |
|---|---|---|
| `RECON_MISMATCH` | 전 주문 | `causeCodeRequired`(🔴 `/resume` 으로 안 풀림) |
| `JOURNAL_MISSING` | 신규 매수 | `automatic`(🔴 수동 해제 버튼 **부재**) |
| `TIER_B_UNJUDGED` | 신규 매수 | `automatic` |
| `DST_WEEK` | ⚠️ 차단 아님 — 상태 표식 | `automatic` |
| `RESUME_INCOMPLETE` X2 | 전 주문 | `automatic` |
| `LEDGER_FIX` X5 | 정정 트랜잭션 뮤텍스 | 자동·사람 해제 **둘 다 없음** |
| `LEDGER_INTEGRITY` X5 | 전 주문 | `wizardOnly` |
| `ADVICE_LEDGER_UNVERIFIED` X7 | **신규 진입 안내** 중단(청산·방어는 유지) | `wizardOnly` → `M5-13` |
| `SELF_AUDIT_OVERDUE` X7 | 신규 진입 안내 | `automatic` — 🔴 차단은 **차이의 크기가 아니라 실사의 부재**에만 |
| `SELF_AUDIT_DUE` X7 | ⚠️ 표식 | `automatic` |
| `SELF_AUDIT_PATTERN_UNVERIFIED` X7 | ⚠️ 표식 | `automatic` |
| `ADVICE_SELECTIVE_EXECUTION` X7 | ⚠️ 표식 · 🔴 **알림을 만들지 않는다**(월간 리포트에만) | `automatic` |

### 6-6. 원장 이벤트 코드 — 1종 (01 §3-6)

`PENSION_FUNDING`(v2.32 · 엔진 플래그 `pension_funding=true`). ⚠️ `decision_log.reason_code` 로만 올지 `kind` 값을 신설할지는 **배치 E 판단** — 확정 전까지 화면은 `reason_code` 문자열로만 분기.

### 6-7. 슬리브 A 계절 진입 게이트 — 3종 (01 §3-7)

`F1_ENTRY_OK`(⚠️ 이름 M2-3 확정 — 통과) · `F1_ENTRY_DEFER`(보류) · `F1_ENTRY_LATE`(지연 진입).
🔴 상태 5값 ↔ 코드 3종 매핑: `octPassed`→`F1_ENTRY_OK` / `deferredToNov`·`deferredToDec`→`F1_ENTRY_DEFER` / `enteredInNov`·`forcedEntryDec`→`F1_ENTRY_LATE`.
🔴 임계값·보류 상한(`seasonality.f1_entry_gate_score`·`f1_entry_defer_max`)을 **상수로 적지 않는다**. 🔴 픽스처 봉투 예시의 `ENTRY_GATE_OCT` 는 «통과» 사유이며 **코드명 확정 전까지 픽스처를 고치지 않는다**.

### 6-8. X7 명령 거부 사유 코드 — ~~15종~~ 🆕 18종 (01 §3-8 · v1.12 +3 `INPUT_INVALID`·`SELF_REPORT_OUTSIDE_SESSION`·`DEFER_ALREADY_USED` · 🆕 `AdviceRetryCodes` 2(`advice_retry`) · `ManualFillPrefillFields` 1(`manual_fill_prefill`))

`MODE_COMBINATION_DENIED` · `OPERATING_MODE_MISMATCH` · `ADVICE_NOT_OPEN`(🔴 `SKIPPED`·`REVOKED`·`SUPERSEDED` **3종에만** — `EXPIRED` 제외) · `FILL_DATE_NOT_TRADING_DAY` · `FILL_DATE_OUTSIDE_ADVICE_WINDOW` · `PRICE_OUT_OF_RANGE` · `SYMBOL_NOT_MAPPED` · `SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL` · `AMEND_TARGET_NOT_ACTIVE` · `AMEND_SYMBOL_OR_SIDE_CHANGE` · `AMEND_LIMIT_EXCEEDED` · `ADVICE_FILL_SYMBOL_MISMATCH` · `SKIP_NOTE_REQUIRED`(🔴 예산 코드 2종에만) · `LEASE_EXPIRED`(🔴 `amend`·`void`·`skip`·`selfReport` 에만) · `DUPLICATE_SUSPECTED`.
🔴 **폐기** — `LEDGER_INTEGRITY_BLOCKED`(B18 → `heldForIntegrity` 보관).

### 6-9. 알림 코드 — ~~24종~~ ~~🆕 v1.17 25종~~ 🆕 v1.18 31종 (01 §3-7 X7 목록 + M2-3 추가 등재 · 🆕 v1.17 엔진 D11 ③ `STALE_ORDERS_HELD` · 🆕 v1.18 엔진 등재형 안전 3 · 재개 3)

- **X7 9** — `ADVICE_ISSUED`(P1·배치당 1) · `ADVICE_EXIT_URGENT`(P0 · 🔴 ack 사다리 미적용) · `ADVICE_DUE_SOON`(P1) · `ADVICE_EXPIRED`(P2·일 1건 묶음) · `ADVICE_REVOKED`(🔴 독립 P0 · 킬스위치와 같은 `groupKey`) · `ADVICE_SUPPRESSED`(P0) · `LEDGER_TRUST_DOWNGRADE`(P1·1회) · `SELF_AUDIT_DUE`(P2) · `MANUAL_FILL_REJECTED`(P1·즉시)
- **자동 매매 ~~10~~ 🆕 v1.17 11** — 🆕 `STALE_ORDERS_HELD`(`AlertCodes.staleOrdersHeld` · 잠정 P1 · 지난 날 주문 잔존 → 다음 날 배치 보류 · 계좌·날 1건 · 01 §26-8 ③ · C-47 ⑥ P1 13 · 표본 `m8/alerts_stale_orders_held` · ✅ 병합 PR #123 squash `0249f61`) · 04 §5-1c 카탈로그(⚠️ 코드 이름·등급은 **이 사전이 정본** · 등재 전에는 화면이 `code` 로 아이콘·색도 고르지 않는다)
- **전환 2** — `HANDOVER_COOLING_ACTIVE` · `HANDOVER_COMMITTED`
- **운영 파라미터 1** — `CONTRIBUTION_CHANGED`(P2 · 변경 1건당 1회 · 멱등 키 = `operating_param_log.row_id`)
- **유지보수 창 2** — `MAINTENANCE_WINDOW_OVERDUE`(P1) · `MAINTENANCE_RESUME_FAILED`(P0)
- 🆕 **v1.18 안전 3**(`AlertCodes.safety` · 01 §27-8 ① · K-z · 엔진 E13 상수 = 등재 · ✅ 병합 PR #142 squash `b582c49`) — `BREAKER_STOPPED`(잠정 P0 · 서킷브레이커 STOPPED 진입 · 신규 주문 전면 중단) · `LEDGER_INTEGRITY_BROKEN`(잠정 P0 · 원장 자가 무결성 실패 → 전 신규 주문 차단) · `STOPPED_RELEASE_ELIGIBLE`(잠정 P1 · STOPPED 재개 자격 충족 · 자동 해제 0 · 🔵 E11f1 «재개 자격» 보고와 같은 사건 — 한 코드)
- 🆕 **v1.18 재개 3**(`AlertCodes.resume` · 01 §27-8 ② · 엔진 E14b · 회차 끝 묶음 · 한국 날 ≤ 1) — `RESUME_TRADING_HALTED`(잠정 P0 · `RESUME_COMPLETED` 와 배타) · `RESUME_COMPLETED`(잠정 P1) · `RESUME_DATA_GAP`(잠정 P2) · C-47 ⑥ `_engineLevel` += 6(P0 10 · P1 15 · P2 6) · 표본 `m8/alerts_safety_resume` · 🔴 `core_engine/test/alert_rules_test.dart` «표 밖 = 제안 6» → 표 밖 0(같은 PR · 엔진 lib 0줄) · SPEC 04 §5-3 등급표 «제안 → 정본» = 엔진 다음 SPEC 판(01 §8 미결 171)
- 🆕 **v1.27 SAF 경고 4**(`AlertCodes.safetyWarn` · 01 §36 K188~K190 · 엔진 E3d 상수 = 등재 · 04 §1 Level 3 · §5-3 v2.46 · 주문을 막지 않는다) — `DEFENSIVE_FLOOR_BREACHED`(잠정 P1 · SAF-302 · 넘은 첫날) · `GOLD_SHARE_HIGH`(잠정 P1 · SAF-308 · 넘은 첫날 · 강제 매도 0) · `FINANCIAL_INCOME_CAP_EXCEEDED`(잠정 P1 · SAF-306 · 과세연도 첫 초과 월) · `KRW_LIQUIDITY_LOW`(잠정 P2 · SAF-307 부속 · 넘은 첫날) · 🔴 SAF-307 달러 노출 기준선 초과 = 코드 0(월간 리포트 «초과 일수» 메모 · K192) · C-61 · 표본 `m8/alerts_engine_proposals_v127`.
- 🆕 **v1.27 파생 동기 1**(`AlertCodes.derivedSync` · 01 §36 K188 · 엔진 E16 상수 = 등재 · 04 §5-3 v2.45 · E16i 의 알림 몫만) — `DERIVED_FORK`(잠정 P0 · 사본이 원장과 갈라져 그 사본 쓰기 멈춤 · 대상마다 1건 · 끈적 · 할 일 = X1 복원 또는 새 기준점(사람만)).
- 🆕 **v1.28 S04 행 코드 10**(✅ 병합 #282)(`AllocationRowCodes` · 도메인 `allocation_row` · 01 §37 K200 · 엔진 `AllocationViewRowCodes` 글자 1:1 · 타입 이름 ≠ 엔진 · 화면 미참조) · 🆕 `AllocationReadModelColumns` 7(`lib/src/schema/read_model_columns.dart` · `rm_config_view` 배분 열 · 01 §6-4 · K201).
- 🆕 **v1.29 E11k-b 사전 3**(✅ 병합 #288)(01 §39 K227 · K229 · 🔴 타입 이름 ≠ 엔진) — `labels/supabase_codes.dart` `SupabaseInputResultCodes` 6(`supabase_input_result` · data_sync `SupabaseInputProblem` 1:1) · `SupabaseTimeResultCodes` 8(`supabase_time_result` · `SupabaseTimeFailure` 1:1) · `LeaseRpcResultCodes` 5(`lease_rpc_result` · RPC 표 거부) · `OnboardingSlotIds` +1 `SECRET_SUPABASE_CONNECT` · `LEASE_INVALID` = v1.18 `JournalReasonCodes` 한 벌(새 0) · 🆕 `schema/supabase_rpc.dart` `LeaseRpcNames` 3 · `LeaseRpcParams` 5 · `LeaseRpcColumns` 3 · C-64.
- 🆕 **v1.30 E16i X1 · X5 엔진 글자 사전 25무리 · 103**(✅ 병합 #293)(01 §38 K209~K214 · 🔴 타입 이름 ≠ 엔진 26 · 공용 `TRUSTED_TIME_UNKNOWN` · `BackupResultCodes` 한 벌 몫 뺌) — `labels/migration_codes.dart`(X1 21) · `labels/repair_codes.dart`(X5 4) · `byDomain` 76 → 101 · C-5 문서 중복 7 → 15 · 🆕 `SafetyHoldCodes` `MIGRATION_IN_PROGRESS` · C-63.
- 🆕 **v1.31 E11k-d2 인증 사전 1**(✅ 병합 #298)(01 §40 K240 · 🔴 타입 이름 ≠ 엔진 `SupabaseAuthFailure`) — `labels/supabase_codes.dart` `SupabaseAuthResultCodes` 6(`supabase_auth_result` · 엔진 12 가운데 고유 6 · 전송 6 = `supabase_time_result` 한 벌 · 금고 = `SUPABASE_AUTH_VAULT_FAILED` — 읽기 또는 쓰기) · `OnboardingSlotIds` +1 `SECRET_SUPABASE_LOGIN` · C-65.
- 🆕 **v1.32 E16j-a 새 기준점 저장 거부 사전 1**(✅ 병합 #299)(01 §41 K257 · 🔴 타입 이름 ≠ 엔진 `BaselineStoreCodes`) — `labels/repair_codes.dart` `BaselineApplyResultCodes` 1(`baseline_apply_result` · `BASELINE_FLAG_NOT_SET` · ds 2 − 공용 `TRUSTED_TIME_UNKNOWN`) · `LedgerFixBusy` = 코드 0 · C-63 ⑩ 103 → 104 · C-66.
- 🆕 **v1.33 E16j-b 슬롯 사전 1**(✅ 병합 #305)(01 §42 K274) — `labels/migration_codes.dart` `X1SlotIds` 4(`x1_slot` · `X1_TICKET_QR_DISPLAY` · `X1_TICKET_QR_SCAN` · `SECRET_X1_RECOVERY_CODE` · `SECRET_X1_REISSUE`) · C-5 필드 규칙 +4(`ticket_slot_id` · `scan_slot_id` · `recovery_code_slot_id` · `reissue_slot_id`) · C-63 ⑩ 104 → 108 · C-67.

🔴 **알림을 만들지 않는 것** — 키 미등록 · `ADVICE_SELECTIVE_EXECUTION` · `SELF_AUDIT_PATTERN_UNVERIFIED`(전부 상태 표식·월간 리포트로만).
🔴 **등급의 최종 정본은 엔진 `04_안전장치` notify 등급**이며 «앱 알림 코드 ↔ 엔진 등급 대조 1회» 를 통과한 값만 유효하다.

### 6-10. `DeviationBadge.kindCode` — 13종 (01 §2-2)

기존 4 = `DISCRETION`·`MANUAL_ORDER`·`RECON_CLEAR`·`KILL_SWITCH_RESUME` / X7 9 = `ADVICE_LAPSE`(예산 미차감) · `ADVICE_SKIP` · `ADVICE_LATE_FILL`(🔴 예산 미차감·정식 저널 불요) · `MANUAL_ENTRY`(🔴 예산 차감·M5-6) · `ADVICE_PRICE_DEVIATION` · `ADVICE_QTY_DEVIATION` · `ADVICE_EXIT_AVOIDED` · `FILL_AMENDED` · `BACKDATED_FILL`.

### 6-11. `advice_transition.cause_code` — 9종 (01 §6-6)

`RECORD` · `SKIP` · `LAPSE` · `SUPERSEDE` · `REVOKE` · `AMEND` · `LATE_FILL`(🔴 상태 불변 · `EXPIRED→EXPIRED` 1행) · `HANDOVER_CLOSE`(🔴 사람의 미이행이 아니다 — 예산 미차감·분모 제외) · `DEFER_CONFIRM`(🔴 **행의 존재 자체가 「이미 한 번 미뤘다」의 정본**).

### 6-12. `decision_log.reason_code` 특수값 — ~~3종~~ ~~🆕 9종(v1.10 ㊲ +5 · v1.11 +1)~~ 🆕 v1.19 10종(+ `LIVE_EXECUTE_PROMOTION`)

`OPENING_BALANCE`(G-04 실전 개시 원장 · `kind='MANUAL'` 1행 공유) · `SIM_OPENING_BALANCE`(N-2 모의 개시 원장) · `HANDOVER_CLOSED`(G-20 `advice.close_reason_code`).
🆕 v1.10(01 §19 · ㊲) `LEDGER_EVENT_WITHDRAWAL`(`kind='WITHDRAWAL'`) · `LEDGER_EVENT_DISTRIBUTION` · `LEDGER_EVENT_TAX_WITHHELD` · `LEDGER_EVENT_CORPORATE_ACTION` · `LEDGER_EVENT_VOID`(이상 `kind='MANUAL'`).
🆕 v1.11(01 §20 · E7b0) `DEPOSIT_REGISTERED`(`kind='DEPOSIT'` · 실입금 등록 — 계획 바인딩과 한 트랜잭션). 거부 사유는 따로 `DepositRegisterRejectCodes`(`deposit_register_reject` 6 · `CommandReceipt.rejectReasonCode`).
🆕 v1.19(01 §28 · K21 · 엔진 E15e2 #161 · ✅ 병합 PR #163 squash `6b8ed02`) `LIVE_EXECUTE_PROMOTION`(`DecisionReasonCodes.livePromotion` · `kind='MANUAL'` · 첫 실전 주문 승격).
🔴 `decision_log.kind='MANUAL'` 인 **세 갈래**(정정 · `external_holding` 등록 · 경로 b 귀속)는 **재량 예산·이탈 집계의 모집단이 아니다**(C7).

### 6-13. 기타 코드 상수 — 7종

- `AfterTaxStep.stepCode` 6 = `PRETAX`·`AFTER_POT`·`AFTER_POT_C`·`WD_5P5`·`WD_16P5`·`HONEST`
- `SafetyState` hold 사유 1 = `LIVE_AWAITING_KEYS`(⚠️ M2-8 · 🔴 `autoTrade` 에서만 배치 중단 — C9)

### 6-14. `PerfPoint.gapReasonCode` — 2종 · `planned_work.kind` — 3종 · `operating_param_log.param_key` — 1종

`EQUITY_SNAPSHOT_MISSING`·`RESUME_GAP` / `SEASONAL_WINDOW`·`DEFER_COUNT`·`SPLIT_LEG` / `monthly_contribution`(🔴 화이트리스트 · `fx_overlay` 계열 키 금지).

🆕 **v1.14(2026-10-26 · 01 §22 · E8a)** — 같은 사전 `GapReasonCodes`(`gap_reason_code`) 에 `data_gap.reason_code` 시세 결측 5종 = `MISSING_ROW`·`NON_POSITIVE_PRICE`·`NEGATIVE_VOLUME`·`PRICE_JUMP`·`CALENDAR_SUSPECT`(전량 8 · 성과 점에는 오지 않는다 · 엔진 `DataGapCause` 와 같은 글자).

🆕 **v1.3(2026-09-28 · 01 §13-3·§13-6)** — `PerfPoint.gapReasonCode` = **3종**(+ `SIM_EXCLUDED` — `GapReasonCodes.simExcluded` · 모의 구간 안의 점) · 🆕 `DisclosureViewEvent.surfaceCode` = 1종 `PERFORMANCE_EXPLORE`(`DisclosureSurfaceCodes.performanceExplore` · 🆕 `labels/disclosure_codes.dart` · 사전 키 `disclosure_surface`) · 🆕 동작 링크 1종 `aaq://nav/back`(`AppNavActions.back` — `navigation/app_links.dart` · 🔴 코드 사전이 아니라 링크 상수이며 `AppRoutes.all` 밖 · DTO·픽스처에 실리지 않는다).

🆕 **v1.4(2026-09-30 · 01 §14)** — 🆕 `PlannerReasonCodes`(`labels/plan_codes.dart`) = 1종 `DEPOSIT_ROUTING`(플래너 **전용** · 초안 칩에는 원장 이벤트 사전의 `PENSION_FUNDING` 도 온다) · 🆕 라우트 `AppRoutes.reportGoalPath` = `aaq://report/goal/:yyyyMm`(`AppRoutes.all` **42**) · ⏸ `DEPOSIT_REGISTER` 거부 코드 사전 없음(01 §8 미결 74).

🆕 **v1.5(2026-10-07 · 01 §15-3 · §8 미결 49)** — 🆕 라우트 `AppRoutes.journalRebalance` = `aaq://journal/rebalance/:rebalanceEventId`(`AppRoutes.all` **43** · `all` 에서 `journalRead` 다음 · `J-1` 을 회차 조건으로 연다 · 링크는 `RebalanceEvent.journalTimelineLink` 가 완성해서 준다 · 셸 본문 = `JournalTimeline(key: ValueKey(id), rebalanceEventId: id)` · 웹 가드 = `journalTimeline` 과 같다) · 코드 사전·`labels/` 추가 0 · ⏸ `planWithdrawal`(S7-5)은 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor(번호는 그때).

🆕 **v1.6(2026-10-08 · 01 §15-4 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`)** — 🆕 라우트 2(`AppRoutes.all` **45**): `AppRoutes.ledgerExecutionGapMonth` = `aaq://ledger/execution-gap/:yyyyMm`(`S7-10` 의 그 달 · `all` 에서 `ledgerExecutionGap` 다음 · `MonthlyReport` ⑧ `D3_EXECUTION.detailDeepLink` 를 엔진이 완성 · 셸 본문 = `ExecutionGapScreen(key: ValueKey(m), yyyyMm: m)` — 인자 없는 `ledgerExecutionGap` 과 **두 라우트 · 한 위젯** · K1 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · `AppRoutes.rebalanceHistory` = `aaq://rebalance/history`(`S7-6a` 회차 타임라인 · `all` 에서 `rebalancePreview` 앞 · 셸 본문 = `RebalanceTimelineScreen()` · K5 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · 주석만: `ledgerExecutionGap`(`S7-10` 은 M7 화면 · 묶음 표기는 역사적 · 셸 본문 = `ExecutionGapScreen()`) · `reportAfterTax`(03 에 화면 없음 · R12 밖) · `reportAnnual`(셸 본문 = `AnnualReviewScreen()`) · `rebalancePreview`(셸 본문 = `RebalancePreviewScreen()`) · `isRegistered`·일치 규칙·`_linkKeys` 무변경 · 코드 사전·`labels/` 추가 0(사유 칩 `REBALANCE_BAND` 은 미등재인 채 기존 픽스처와 같이 재사용).

🆕 **v1.16(2026-11-03 · 01 §25 · R15 선행 · ✅ 병합 PR #96 squash `dd9e162`)** — 🆕 사전 3축(`labels/onboarding_codes.dart` · 도메인 등록 = `labels.dart`): `OnboardingResultCodes`(`onboarding_result`) 4종 `ONBOARDING_CHOICE_COMMITTED` · `CREDENTIAL_REJECTED` · `DRY_RUN_START_ROLLED_BACK` · `PAIRING_TOKEN_REVOKED` · `BrokerRawCodes`(`broker_raw`) 1종 `EGW00133`(표본 · 전수 아님 · 01 §8 미결 157) · `OnboardingSlotIds`(`onboarding_slot`) 7종 `SECRET_KIS_MOCK` · `PLEDGE_WRITE` · `BIOMETRIC_SIGN` · `SELFTEST_RUN` · `RECOVERY_CHECKSUM` · `RECOVERY_LOGIN` · `VIEWER_QR_SCAN`(🔒 슬롯 이름 · `ui_shell` 은 해석하지 않고 주입된 슬롯 빌더에 넘긴다 · 01 §8 미결 152) / 🆕 라우트 10(`AppRoutes.all` 54 → **64**): `ledgerSimOpening` = `aaq://ledger/sim-opening/:accountAlias`(`O-04` ⑥ 투자 안내 갈래 · `L-3` simOpening · 01 §8 미결 153) · 온보딩 고정 6 `onboardingStart` `aaq://onboarding/start` · `onboardingModePick` `…/mode` · `onboardingSteps` `…/steps` · `onboardingFinish` `…/finish` · `onboardingRestart` `…/restart` · `onboardingPairing` `…/pairing`(🔴 `all` 에서 `onboardingStep` = `aaq://onboarding/:stepId` **앞** — 고정 조각이 먼저 일치 · C-33 ⑦) · `m5SimOpeningCash` = `aaq://m5/sim-opening-cash`(M5 가상 초기금 1칸 · 01 §8 미결 154) · X1 `x1MigrationPlan` = `aaq://x1/migration/plan` · `x1MigrationEmergency` = `aaq://x1/migration/emergency`(결정 ③).

🆕 **v1.17(2026-11-04 · 01 §26 · R16 선행 + 엔진 D11 · ✅ 병합 PR #123 squash `0249f61` · 2026-11-05)** — 🆕 사전 2축: `OpsSlotIds`(`ops_slot` · 🆕 `labels/ops_codes.dart` · 1종 `EMERGENCY_CARD_PRINT` — `D-03` 인쇄·PDF 플랫폼 슬롯 이름 · 셸 주입 `shellOpsSlotBuilderProvider` 기본 null = 인쇄 자리 부재 · K19·K24) · `JournalReasonCodes`(`journal_reason` · `labels/journal_codes.dart` · 2종 `DUPLICATE_ORDER_PREVENTED` · `DAY_END_EXPIRED` · 🔴 전수 아님 — 사유 칩 전수 사전 = 01 §8 미결 166 · 엔진 D11 ④) · 알림 코드 +1 `STALE_ORDERS_HELD`(§6-9) / 🆕 라우트 5(`AppRoutes.all` 64 → **69** · 전부 `opsRhythm` 뒤 · 셸 가드 기본 open · 본문 등록 = 조립 앱 레지스트리): `opsRunbooks` = `aaq://ops/runbooks`(`D-02` 목록) · `opsRunbook` = `aaq://ops/runbooks/:runbookId`(`D-02` 상세 · id 꼴 `^[a-z][a-z0-9-]*$` = 엔진 의무) · `opsEmergencyCard` = `aaq://ops/emergency-card`(`D-03`) · `opsDeviceRisk` = `aaq://ops/device-risk`(`H-03` · Android 전용 = 조립 앱 레지스트리) · `handbookIndex` = `aaq://handbook`(`B-01` · 페이지 = `handbook://<앵커>` 스킴).

🆕 **v1.18(2026-11-13 · 01 §27 · R6 선행 + 엔진 등재형 7 · ✅ 병합 PR #142 squash `b582c49` · 2026-11-13)** — 🆕 사전 3축(🆕 `labels/settings_codes.dart` · 도메인 등록 = `labels.dart`): `ConnectionTargetCodes`(`connection_target`) 6종 `SUPABASE` · `GITHUB_ARCHIVE` · `NOTIFY_CHANNEL` · `HEALTHCHECKS` · `CALENDAR` · `BROKER_KIS`(`ConnectionRow.target` · `connectionTest`·`connectionSyncNow` args · 01 §8 미결 151 의 `target` 몫) · `NotifyChannelCodes`(`notify_channel`) 2종 `TELEGRAM` · `KAKAO` · `SettingsResultCodes`(`settings_result`) 3종 `BIOMETRIC_UNAVAILABLE` · `CONNECTION_TEST_FAILED` · `SYNC_ALREADY_RUNNING`(🔴 전수 아님 — 뒤 카드 R6c~R9 가 늘린다) · C-5 `_fixtureCodeFields` += `target` · `channel` · `JournalReasonCodes` +1 `LEASE_INVALID`(`leaseInvalid` · 3종 · 엔진 E14a `kLeaseInvalidCode` · REJECTED(NR-1 0단계) · SKIPPED(6.9 직전 재확인) 근거 · 🔴 `AdviceRejectCodes.leaseExpired` 와 다른 축 · 표본 0 = 01 §8 미결 166 축) · 알림 코드 +6(§6-9) / 🆕 라우트 11(`AppRoutes.all` 69 → **80** · 전부 `settingsCredentials` 뒤 · S 번호 차례 · 고정 조각 · 파라미터 0 · 셸 가드 기본 open · 폰 전용 = 조립 앱 레지스트리 06 `M4-12` ⑤): `settingsHome` = `aaq://settings`(`S01` · 셸 «더보기» 몸통) · `settingsAccounts` `…/accounts`(`S03`) · `settingsAllocation` `…/allocation`(`S04`) · `settingsOperations` `…/operations`(`S05` · 계약 = v1.19) · `settingsDevices` `…/devices`(`S06`) · `settingsConnections` `…/connections`(`S07`) · `settingsCalendar` `…/calendar`(`S08`) · `settingsBackup` `…/backup`(`S09`) · `settingsDiagnostics` `…/diagnostics`(`S10`) · `settingsGeneral` `…/general`(`S11`) · `settingsAnnualReview` `…/annual-review`(`S12` · M9 목차 — M7 `reportAnnual` 과 다름) · `S02` = 기존 `settingsCredentials` · 월 납입 = 기존 `settingsContribution`(R8 · 결정 Q4).

🆕 **v1.19(2026-11-14 · 01 §28 · R6c 선행 + 엔진 E15i 굳은 몫 · ✅ 병합 PR #163 squash `6b8ed02` · 2026-11-14)** — `labels/settings_codes.dart` += 🆕 `EngineStopReasonCodes`(`engine_stop_reason`) 2종 `PLANNED_MAINTENANCE` · `TROUBLESHOOTING`(🔵 잠정 — 값 확정 = 01 §8 미결 173 · 시장 판단·기기 이전 사유 0) · `SettingsResultCodes` +2 `ENGINE_ALREADY_RUNNING` · `ENGINE_ALREADY_STOPPED`(멱등 접수 · `info`) · 🆕 `labels/sim_codes.dart`(엔진 글자 1:1 · 도메인 등록 = `labels.dart`): `SimTrialItemCodes`(`sim_trial_item`) 5 `SIM_TRIAL_TWO_TRADING_WEEKS` · `_MONTH_END_REBALANCE` · `_RECONCILIATION` · `_RESUME` · `_KILL_SWITCH` · `SimTrialItemStateCodes`(`sim_trial_state`) 4 `PASSED` · `AUTO_PASSED` · `OPEN` · `OPEN_WARN` · `LiveObservationBlockCodes`(`live_observation_block`) 4 `LIVE_OBSERVATION_KILL_SWITCH` · `_TRADING_BLOCK` · `_UNKNOWN_ORDERS` · `_NOT_ENOUGH_DAYS` · `LivePromotionResultCodes`(`live_promotion_result`) 5 `HANDOVER_SESSION_INVALID` · `LIVE_PROMOTION_NOT_OBSERVING` · `_NOT_AUTO_TRADE` · `_CLOCK_BEHIND` · `_ROLLED_BACK`(엔진 E15e2 #161 · 생체 = `SettingsResultCodes.BIOMETRIC_UNAVAILABLE` 한 벌) · `ModeStartupCodes`(`mode_startup`) 2 `SAF-405` · `CREDENTIAL_ENV_MISMATCH`(조합 금지 = `AdviceRejectCodes.modeCombinationDenied` 한 벌 · hold ≠ 기동 거부) · `SimOpeningResultCodes`(`sim_opening_result`) 10(`onboardingDryRunStart` 결과) · `DecisionReasonCodes` += `LIVE_EXECUTE_PROMOTION`(§6-12) · `byDomain` +7 · C-5 `_fixtureCodeFields` += `item_code` · `item_state` · 라우트·열거 신설 0(`AppRoutes.all` 80 그대로) · 엔진 소비(로컬 상수 → 계약 참조) = 01 §8 미결 177.

🆕 **v1.20(2026-11-15 · 01 §29 · R7 선행 + 엔진 겹침 몫 · ✅ 병합 PR #187 squash `52f2fc9` · 2026-11-15)** — `labels/settings_codes.dart` += 🆕 `CredentialKindCodes`(`credential_kind`) 4종 `KIS_LIVE` · `KIS_ISA` · `KIS_PAPER` · `KIS_RECONCILE`(엔진 `broker_gateway` `KisKeySet.wire` 와 같은 글자 · 엔진 겹침 몫 · K8) · 🆕 `SettingsSlotIds`(`settings_slot`) 4종 `SECRET_KIS_LIVE` · `SECRET_KIS_ISA` · `SECRET_KIS_RECONCILE` · `PAIRING_QR_DISPLAY`(모의 = `OnboardingSlotIds.secretKisMock` 재사용 · JSON 키 `credential_slot_id` · `qr_slot_id` — `secret_slot_id` 는 온보딩 사전 고정 · K9 · K31) · `SettingsResultCodes` +3 `WRONG_KEY_SET` · `MAPPING_VERIFY_FAILED` · `DEVICE_ALREADY_REVOKED`(K13 · `S02` 거절 = `OnboardingResultCodes.credentialRejected` 한 벌 — K32) · `byDomain` +2(새 글자 7 · 도메인 간 중복 0) · C-5 `_fixtureCodeFields` += `credential_slot_id`(전역) · `qr_slot_id`(`settings_slot`) · `_fieldsOutsideDictionary` += `health_code` · 🆕 라우트 `AppRoutes.m4KeyRotation` = `aaq://m4/key-rotation`(🔒 06 `M4-4` 키 회전 마법사 · `AppRoutes.all` **81** · Claude 소유 묶음 머리 `handoverStatus` 뒤 · 파라미터 0 · 본문 = 조립 앱 빈 자리 · C-33 ③ 81 · `ownedByClaude` 14 · K12 · K37) · 열거 신설 0 · 엔진 소비(`KisKeySet` += `live`·`isa`·`reconcile` · 사전 참조) = 01 §8 미결 178.

🆕 **v1.21(2026-11-15 · 01 §30 · 엔진 예고 1/2 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16)** — 🆕 `labels/safety_codes.dart` 사전 4축(도메인 등록 = `labels.dart` `byDomain` +4 · 새 글자 24 · 도메인 간 중복 0 · 엔진 글자 1:1 · K12 · K13 · K45): `KillSwitchResultCodes`(`kill_switch_result`) 12 · `SafetyCommonResultCodes`(`safety_common_result`) 2 `TRUSTED_TIME_UNKNOWN` · `JOURNAL_ID_TAKEN`(엔진 다섯 사전이 같은 글자를 품는다 → 한 벌) · `PledgeResultCodes`(`pledge_result`) 6(엔진 `PledgeCodes` 7 − 공용 1) · `GaugeCodes`(`gauge`) 4(`GaugeProgress.code` 사전 · 엔진 지역 선언 지움 = 엔진 숙제) · 🆕 라우트 3 `AppRoutes.m5StoppedDecision` = `aaq://m5/stopped-decision`(🔒 M5-3) · `m5Pledge` = `aaq://m5/pledge`(🔒 M5-8) · `m5RuleChangeGate` = `aaq://m5/rule-change-gate`(🔒 M5-9 · R8 `S04` «적용» `handoffRoute` 목적지)(`AppRoutes.all` **84** · `m5SimOpeningCash` 뒤 · `x1Migration` 앞 · 파라미터 0 · 본문 = 레지스트리 빈 자리 · C-33 ③ 84 · `ownedByClaude` 14 → 17 · K14 · K44) · C-16 `killChecklistConfirm` 사전 = `kill_switch_result` ∪ `safety_common_result`(옛 `advice_reject` 정정 · K40).

🆕 **v1.22(2026-11-17 · 01 §31 · 엔진 예고 2/2 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17)** — 사전 12 도메인 신설(`labels.dart` `byDomain` +12 · 엔진 글자 1:1 · 상수 이름 C-7 회피 K51): `labels/safety_codes.dart` += `StoppedDecisionResultCodes`(`stopped_decision_result`) 7 · `PostmortemResultCodes`(`postmortem_result`) 3 · `InterventionResultCodes`(`intervention_result`) 6 · `RuleChangeResultCodes`(`rule_change_result`) 11 · `DiscretionResultCodes`(`discretion_result`) 3(`JOURNAL_MISSING` = 문서화된 도메인 간 중복 다섯째 · C-5 «다섯 쌍») · `labels/verdict_codes.dart` += `ResumeItemReasonCodes`(`resume_reason`) 15(엔진 `ResumeReasonCodes` — 이름 다름 · K49) · `SeasonalChoiceResultCodes`(`seasonal_choice_result`) 4 · `PlannedWorkRejectCodes`(`planned_work_reject`) 6 · `labels/sim_codes.dart` += `SimToAutoResultCodes`(`sim_to_auto_result`) 10(`windowBlocked` = `SIM_TO_AUTO_COMMIT_WINDOW`) · `SimToAutoCommitResultCodes`(`sim_to_auto_commit_result`) 12(엔진 10 + 오케스트레이터 2 · `outcomeUnknown` = `SIM_TO_AUTO_COMMIT_UNKNOWN`) · `HandoverSessionResultCodes`(`handover_session_result`) 2 · `SimToAutoStepIds`(`sim_to_auto_step`) 7(`SIM_TO_AUTO_S1`~`S7` · `ordered`) · 추가형 4 `PlannedWorkKindCodes` += `MONTHLY_PLAN` · `CARRY_OVER` · `DecisionReasonCodes` += `SIM_LEDGER_KEEP` · `SIM_LEDGER_DISCARD`(🔴 `LIVE_OPENING` 미등재 · K57) · `BrokerRawCodes` += `SIM_INVALID_ORDER` · `SIM_ORDER_NOT_FOUND` · `SIM_CANCEL_TOO_LATE` · `GapReasonCodes` += `SIM_BAR_MISSING`(K66) · 🆕 `ModeMarkerText` 4(`sim` «모의투자» · `advisory` «투자 안내» · `osSimPrefix` «[모의]» · `osAdvisoryPrefix` «[안내]» · 🔴 자리 = `lib/src/mode_marker_text.dart`(사전 아님 · labels 밖 · C-5 예외 0 · K73)) · 라우트 무변경(84).

🆕 **v1.23(2026-11-17 · 01 §32 · R8a 선행 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — `labels/settings_codes.dart` 끝 += 🆕 `ContributionResultCodes`(`contribution_result`) 6 — `blank` `CONTRIBUTION_INPUT_BLANK` · `negative` · `notNumber` · `overMax` · `clockNotAdvanced` · `unchanged`(`labels.dart` `byDomain` +1 · v1.22 행 뒤 · K103) · 엔진 `ContributionRejectCodes` 7 − 공용 `TRUSTED_TIME_UNKNOWN`(`SafetyCommonResultCodes` 한 벌 · 🆕 1.23.0 월 납입 짝 주석 · v1.21 K45) · 🔵 타입 이름 ≠ 엔진(`ambiguous_import` 방지 · K80) · 엔진 참조로 옮기기 = 엔진 숙제.

🆕 **v1.25(2026-11-19 · 01 §34 · 트랙 B 선행 · ~~⬜ PR 대기~~ ✅ 병합 PR #256 squash `233adda8`(2026-11-19 · CI 3/3))** — `labels/safety_codes.dart` 끝 += 🆕 `KillCancelOutcomeCodes`(`kill_cancel_outcome`) 5 = 엔진 `KillCancelOutcome` wire 1:1(타입 이름 ≠ 엔진) · `labels/ops_codes.dart` `OpsSlotIds` += `KILL_SWITCH` · C-5 도메인 간 중복 추가 0.

🆕 **v1.26(2026-11-20 · 01 §35 · 트랙 C 선행 · ~~⬜ PR 대기~~ ✅ 병합 PR #270 squash `09d3580d`(2026-11-20 · CI 3/3))** — `labels/safety_codes.dart` 끝 += 🆕 `ReconClearResultCodes`(`recon_clear_result`) 3 = 엔진 예고(«저널 함께 쓰기» 판이 예외를 코드로 · 공용 `JOURNAL_ID_TAKEN`·`BIOMETRIC_UNAVAILABLE` 따로) · `SafetyActionId` += `ruleChangeRequest`(`RULE_CHANGE_REQUEST` = ds `kRuleChangeRequestKind`) · C-5 도메인 간 중복 추가 0.

🆕 **v1.24(2026-11-18 · 01 §33 · R9 선행 · ✅ 병합 PR #235 squash `bbed5ef` · 2026-11-18 · R8a 병합 뒤)** — `labels/settings_codes.dart` 끝 += 🆕 `BackupResultCodes`(`backup_result`) 8 = ds `SqliteLedgerSnapshotter.take` 경로 전수(`X1_LIVE_ONLY` · `SNAPSHOT_*` 2 · `RESTORE_*` 5 — SHA·MANIFEST 제외 · K132) · 🆕 `LedgerIntegrityResultCodes`(`ledger_integrity_result`) 7 = core `LedgerIntegrityReason`(E13c1) · 🔴 타입 이름 ≠ 엔진 · C-5 문서 중복 +2(`CHAIN_BROKEN` · `RESTORE_ROLLBACK` ↔ `origin_code`).

---

## §7. ⑦ DDL 배치 A~F — 영역 **E** · `ddl/`

> **파일**: `ddl/batch_a_decision_mode.sql` · `batch_b_plan_command.sql` · `batch_c_x2_x5_local.sql` · `batch_d_supabase.sql` · `batch_e_enum_widen.sql` · `batch_f_x7_advisory.sql` · `batch_z_archive_layout.md`(§6-7 — 스키마가 아니라 출력 포맷 계약).
> 🔴 **마이그레이션 창은 1회**이고 `schema_version` 번호는 창 전체에 **하나만** 배정한다(부분 반영 상태를 남기지 않는다).
> 🔴 **적용 순서** — ① 신설 표 → ② CHECK 재작성(테이블 재생성) → ③ ALTER → ④ Supabase RLS → ⑤ Supabase `mode` 키 + 전량 재push.
> 🔴 SQLite 는 `CHECK` 를 `ALTER` 로 못 바꾼다 — **새 테이블 → 복사 → RENAME**, `PRAGMA foreign_keys=OFF` 창을 스크립트에 명시.
> 🔴 스타일은 `06_시스템설계/02_데이터모델.md` 그대로(컬럼 정렬 · `CHECK` 인라인 · 🔴 주석 · 후행 `CREATE INDEX`).

### 7-1. 배치 A — 결정 7 승인 4건 + `mode`(로컬 SQLite)

| 대상 | 무엇 |
|---|---|
| `decision_log` **신설** | `decision_id` PK · `created_at` · `trade_date` · `mode`(CHECK · fail-closed 기본 SIM) · `kind` CHECK(`ENTRY`·`EXIT`·`REBALANCE`·`DEPOSIT`·`WITHDRAWAL`·`SAFETY`·`RESUME`·`LEDGER_FIX`·`MANUAL`) · `strategy_id` · `sleeve` CHECK(`A`·`B`·`C`·`POT`·`CASH`·`SAT`) · `symbol` · `reason` · `reason_code` · `tier` · `exit_kind` CHECK(6종) · `trigger_price` · `threshold_registered` · `rule_cited` · `regime_ref` · `config_hash` · `parent_decision_id` · `journal_id` / IDX `(trade_date, kind)`·`(parent_decision_id)` |
| `positions` ALTER | `entry_decision_id TEXT` |
| `order_intents`·`trades`·`equity_snapshot` ALTER | `mode` + CHECK |
| `holding_signal_daily` **신설** | PK `(trade_date, symbol, strategy_id)` · `momentum_12_1`·`rs_rank`·`template_passed`·`failed_conditions`(JSON)·`sma_tranche_step`·`gate_states`(JSON)·`source` CHECK(`LIVE`·`BACKFILL`) |
| `rebalance_event` **신설** | `event_id` PK · `trade_date` · `mode` · `kind` CHECK(5종) · `decision_id` · `trigger_snapshot`·`weights_before`·`weights_after`(JSON) · `config_hash` · `created_at` / IDX `(trade_date)` |

⚠️ `mode` CHECK 는 `('SIM','LIVE')` 2값이 초안이나 §9-5 ④ 권고는 **3값 + 파일별 CHECK**다 → `m2-8_naming.md` D-2 확정을 따른다.

### 7-2. 배치 B — Q-F 계획 스냅샷·명령 인입(로컬)

| 대상 | 무엇 |
|---|---|
| `plan_snapshot` **신설** | `plan_id` PK · `kind` CHECK(`DEPOSIT`·`WITHDRAWAL`·`REBALANCE`) · `computed_at` · `as_of_trade_date` · `expires_at`(🔴 만료 계획으로 실입금 등록 거부) · `inputs`·`outputs`(JSON) · `config_hash` · `consumed_by_decision_id` |
| `command_inbox` **신설** | `command_id` PK · `kind` · `ingested_at` · `state` CHECK 7값(`RECEIVED`·`EXECUTED`·`REJECTED`·`EXPIRED`·`STALE_CONTEXT`·`HELD_FOR_INTEGRITY`·`PENDING_LEASE_CONFIRM`) · `state_label` · `reject_reason_code` · `decision_id` · `run_mode`·`operating_mode`·`lease_epoch`(G-30 발행 시점 맥락) · `payload_digest`(🔴 원문 재저장 금지) |
| `operating_param_log` **신설** G-06 | `row_id` AUTOINCREMENT PK · `param_key`(화이트리스트) · `value_text`(Decimal 문자열) · `changed_at`(🔴 **신뢰 시각**) · `effective_from` · `action_run_id` · `device_id` · `superseded_by` · `UNIQUE(param_key, changed_at)` |
| `read_model_push` **신설** | `table_name` PK · `last_pushed_key` · `last_ok_at` · `row_version` · `status` CHECK(`OK`·`PUSH_LAG`·`PUSH_FAILED`) |

🔴 **현재 유효값 조회 규약**(N-S4-01): `param_key` 별 `effective_from <= 신뢰 시각 오늘` 인 행 중 `changed_at` 최대 행. `effective_from` 이 미래인 행은 **예정값**이며 현재값 조회에 섞이지 않는다. 🔴 이 표는 전략 `config_hash` 에 들어가지 않는다.

### 7-3. 배치 C — X2~X5(로컬)

| 대상 | 무엇 |
|---|---|
| X2 | `planned_work`(`idempotency_key` UNIQUE · `state` CHECK 6값 · `origin` CHECK `LOCAL`·`MIRROR` · `row_version`) · `planned_work_transition`(append) · `resume_run`(`mode` CHECK 4값 · `phase` R0..R8 · `counts` JSON) · `data_gap` |
| X3 | `onboarding_progress`(PK `(step_id, track)` · `track`·`state` CHECK) · `onboarding_choice` **신설 G-01**(`id=1` · `operating_mode` CHECK `AUTO_TRADE`·`ADVISORY` · `chosen_at` · `committed_at` — 🔴 채워지면 읽기 전용) · `credential_registry`(🔴 **값 저장 금지** · `keystore_ref` 별칭만 · `health` CHECK 5값) |
| X4 | `calendar_link`(🔴 PK = `mode` CHECK `LIVE`·`SIM` — G-32 · 🔵 **v1 은 `LIVE` 행 하나**) · `calendar_sync_state`(PK = `mode` · `last_ok_date` 단조 전진 · `status` CHECK 4값) · `calendar_event_log`(PK `(source_table, source_id)` · `aaq_key` UNIQUE · `origin` CHECK 5값 · `state` CHECK `PENDING`·`SYNCED`·`QUARANTINED`·`SKIPPED`) · `cash_flow` ALTER `recorded_at` |
| X5 | `executions`·`trades` ALTER `authored_at` · `ledger_daily_hash`(PK `authored_date` · `chain_hash` · `hash_format_version` · `row_counts` JSON) · `ledger_diff`(`pair`·`axis`·`severity`·`status` CHECK) · `ledger_repair`(append-only · `direction` CHECK `DERIVED_RESYNC`·`CANON_CORRECT`) · `sync_state`(`status` CHECK 5값 · `operator_epoch`) |

🔴 **authored 축 컬럼 매핑**(X5-1 정규 직렬화 골든의 입력): `executions`·`trades`→`authored_at` / `cash_flow`→`recorded_at` / `decision_log`·`rebalance_event`→`created_at` / `decision_journal`·`order_intents`→기존 생성 시각(⚠️ 실제 컬럼명 확인 후 확정). 🔴 **`equity_snapshot`·`positions`·`ramp` 는 제외**.

### 7-4. 배치 D — Supabase(Postgres) 공유 계층

- **표**: `app_device`(`role` CHECK `operator`·`viewer` · `status` CHECK 4값 · 🔴 최초 INSERT 는 viewer/PENDING 강제) · `operator_lease`(단일 행 · `epoch` · TTL · 🔴 쓰기는 CAS RPC 만) · `recovery_secret`(🔴 해시만 · **SELECT 정책 없음**) · `command_queue`(append-only · `kind` CHECK · `unique(kind, nonce)` · **+ `run_mode`·`operating_mode`·`lease_epoch`**) · `command_ack` · `planned_work_mirror` · `resume_run_mirror` · `ledger_stamp`(🔴 PK `(mode, authored_date)`) · `calendar_sync_status`(PK `mode`).
- **RLS**: 🔴 **표마다 예외 없이** `enable row level security` + select 전용 정책. 🔴 **클라이언트 INSERT·UPDATE·DELETE 정책을 만들지 않는다** — 쓰기는 **operator 리스 epoch 를 검사하는 security definer RPC 하나**뿐(G-10). `command_queue` 만 예외적으로 두 INSERT 정책(viewer 4종 화이트리스트 / operator 전량)을 **분리한 채로** 유지한다.
- **읽기 모델 `rm_*` 18표**: `rm_journal` · `rm_holding` · `rm_performance_point` · `rm_rebalance_event` · `rm_alert` · `rm_safety_state` · `rm_config_view` · `rm_advice` · `rm_advice_summary` · `rm_monthly_report` · `rm_report_archive` · `rm_ledger_diff` · `rm_sleeve_allocation` · `rm_perf_context` · `rm_disclosure_view` · `rm_ops_summary` · `rm_ledger_trust` · `rm_execution_gap`.
- **규칙 5조** ① 전 `rm_*` 에 `row_version`·`lease_epoch`·`pushed_at` **+ `mode`**(RunMode 3값) — 🔴 **증분 키에도 `mode` 가 들어간다** ② upsert 는 `row_version` 큰 쪽만 · 정정은 새 행 ③ 백필은 증분 키 오름차순 ④ RLS 는 `rm_*` 도 예외 아님 ⑤ 🔴 시크릿·계좌 전체번호·손익 원장 금지 ⑥ push 시 `rm_config_view` 의 **버전 스탬프 3필드**(`schema_version`·`hash_format_version`·`contract_version`)를 **매번 함께** 갱신.
- 🔴 **명령 표의 모드 축은 `run_mode` 하나**다(N-02) — `command_queue`·`command_ack` 에는 `mode` 컬럼을 **붙이지 않는다**. `command_ack` 는 `command_id` 참조로 축을 따라온다.
- 🔴 **읽기 모델 컬럼 목록은 DTO 필수 필드의 상위집합**이어야 한다(G-22). 아니면 viewer 구현자가 축약 타입을 만들어 계약 3조 ① 을 우회한다.
- 🔴 `rm_advice` 는 **A6 마스킹** — `symbol`·`quantity`·`price_low/high/ref`·`recorded_quantity`·`actions` 를 **싣지 않는다**.
- 🔵 **v1 필수 신설 4표** = `rm_monthly_report`·`rm_report_archive`·`rm_ledger_diff`·`rm_advice_summary`. `rm_sleeve_allocation`·`rm_perf_context` 는 조건부, ~~`rm_ops_summary` 는 홈 블록 5·7 소유 결정에 종속(⬜ 택일 — 정하지 않은 상태가 가장 나쁘다).~~ ✅ `rm_ops_summary` = **v1 필수**(2026-10-22 · 발주자 · 권고대로 · 설계 10 N-07 · 컬럼 = 01 §6-4 · v1.8 `rm_sleeve_allocation` 승격과 합쳐 v1 필수 6표).

### 7-5. 배치 E — 열거형 확장(기존 CHECK 재작성 = 테이블 재생성)

| 대상 | 추가 |
|---|---|
| `trading_block.flag_id` | `RESUME_INCOMPLETE`·`LEDGER_FIX`·`LEDGER_INTEGRITY` + X7 5종 |
| `trading_block.origin_code` | `EXTERNAL_CASHFLOW`·`CORPORATE_ACTION` + 파생 7종 |
| `04 §3-1` 2단계 판정 SQL | `RESUME_INCOMPLETE`·`LEDGER_INTEGRITY`·`ADVICE_LEDGER_UNVERIFIED`·`SELF_AUDIT_OVERDUE` 를 **실제 추가** — 🔴 플래그만 읽고 SQL 을 안 고친 구현은 실격 |
| `04 §5-3` 알림 등급 | `INFO`/`ALERT`/`DIGEST` → **P0/P1/P2** 개편 + 매핑표 |
| `ledger_diff.pair`·`origin_code` | `CANON_SELF_REPORT` + 원인 코드 6종 |
| `decision_log.kind` | 🔴 **추가 없음** — 정정 2행·`external_holding` 등록·경로 b 귀속은 전부 기존 `MANUAL` 재사용(C7) |
| `calendar_event_log.origin` | `MANUAL_ENTRY`(G-28 — 재생성 · PK 와 `aaq_key` UNIQUE 를 함께 옮긴다) |
| `command_inbox.state` | 보류 3값 + 컬럼 3개(G-30) |
| `calendar_link`·`calendar_sync_state` | `CHECK (id = 1)` → `mode` PK(G-32 — PK 변경이므로 재생성) |
| `ledger_diff.applicable` | ALTER ADD COLUMN(G-27 — 🔴 **배치 F 창 안에서**) |

### 7-6. 배치 F — X7 투자 안내(로컬)

| 대상 | 무엇 |
|---|---|
| `advice_batch` **신설** | `batch_id` PK · `trade_date` · `mode` CHECK **= 'LIVE'** · `operating_mode` CHECK **= 'ADVISORY'** · `intent_batch_id` NOT NULL(🔴 `exec_policy` 컬럼을 **두지 않는다** — A11) · `handover_session_id`(B20 조건부 조합 #12 의 유일한 근거) · `issued_at` · `headline` · `resume_run_id` · `config_hash` / IDX `(trade_date)` |
| `advice` **신설** | `advice_id` PK · `batch_id` · `intent_id`(🔴 `NO_ACTION` 은 NULL) · `decision_id` NOT NULL · `mode` CHECK='LIVE' · `trade_date` · `valid_until_date`(🔴 **거래일 달력**) · `kind` CHECK 7값(+`NO_ACTION`) · `symbol`(NULL 허용) · `sleeve` CHECK 6값 · `side` CHECK(NULL 또는 BUY/SELL) · `quantity`(NULL 또는 >0) · `price_low`·`price_high`·`price_ref` · `is_urgent` · `reason`·`reason_code` · `depends_on_advice_id` · `account_alias` · `status` CHECK 7값 · `close_reason_code` · `superseded_by` · `suppressed` · `suppressed_label` · `sizing_label` NOT NULL · `config_hash` · `created_at` / IDX `(status, valid_until_date)`·`(intent_id)`·`(symbol, trade_date)` |
| `advice_transition` **신설** | `transition_id` PK · `advice_id` · `from_status`·`to_status` · `cause_code` CHECK 9값 · `command_id`·`fill_id`·`decision_id` · `occurred_at` / IDX `(advice_id, occurred_at)` |
| `executions` ALTER **11컬럼** | `fill_origin` CHECK 4값 · `fill_kind` CHECK 3값 · `advice_id` · `reverses_fill_id` · `restates_fill_id` · `authored_by_device_id` · `backdate_trading_days` · `cost_source` CHECK 3값 · `off_hour_trade` · `during_halt`(🔴 **접수 시점 판정** — 사후 불가) · `price_range_source_date` |
| `trades` ALTER 2컬럼 | `fill_origin` · `fill_kind` |
| `order_intents` ALTER | `operating_mode` CHECK(`AUTO_TRADE`·`ADVISORY`) |
| `external_holding` **신설** | `external_id` PK · `symbol`·`account_alias`·`quantity` · `decision_id`(🔴 등록도 결정) · `note` · `registered_at` · `released_at`. 🔴 **유니버스 종목 등록 금지**(앱 층 판정 + `SYMBOL_IN_UNIVERSE_CANNOT_BE_EXTERNAL`) |
| `self_report_balance`·`self_report_line` **신설** | 전자 = `report_id` PK · `as_of_trade_date`·`account_alias`·`session_started_at`(B15)·`cash_krw`·`declared_complete`·`device_id`·`command_id`·`reported_at` / 후자 = PK `(report_id, symbol)`·`quantity` |
| `credential_registry` ALTER | `usage` CHECK(`RECONCILE_ONLY`·`FULL`) |
| `handover_session` **신설 G-02** | `handover_session_id` PK · `kind` CHECK(`GATE_M5_10`·`WIZARD_M5_11`) · `path` CHECK 4값 · `device_id`·`lease_epoch` · `opened_at`·`expires_at`·`closed_at` · `close_code` CHECK(`COMMITTED`·`CANCELLED`·`EXPIRED`·`ROLLED_BACK`) |
| `operating_mode_transition` **신설 G-02** | `transition_id` PK · `handover_session_id` · `from_mode`·`to_mode` · `decision_id` · `committed_at` |
| `ledger_diff.pair` **재작성 N-01** | 4값 → **5값**(`CANON_SELF_REPORT` 포함). 🔴 **`applicable` ALTER 보다 먼저** — 아니면 `applicable=0` 의 `CANON_SELF_REPORT` 행이 CHECK 위반으로 실패하고 보드가 4칸으로 퇴화 |
| `ledger_diff.applicable` ALTER G-27 | `INTEGER NOT NULL DEFAULT 1 CHECK (applicable IN (0,1))` |
| **배치 D 추가분** | `command_queue.kind` CHECK += **7종** · `state` CHECK += 3값 · 컬럼 3개. 🔴 신규 7종은 **`command_insert_operator` 정책에만** — viewer 4종 화이트리스트는 그대로 |

🔴 **`advice` 의 NULL 허용 조건은 둘뿐이다**: ① `kind='NO_ACTION'`(symbol·quantity·side·intent_id 전부 NULL · `suppressed=1` · `suppressed_label` 필수) ② `unverifiable`·`drifting` 등급의 청산 안내(quantity 만 NULL · `sizing_label` 이 말한다). **그 밖의 행은 네 컬럼이 전부 NOT NULL 이며 엔진 선행 가드가 강제한다**(CHECK 로 조건부 NOT NULL 을 표현하지 않는다).
🔴 `ledger_sim.sqlite` 판은 `CHECK (mode = 'SIM_INTERNAL')` 로 좁힌다(C8 — `simBroker × advisory` 는 정의 모순으로 금지).
🔴 새 컬럼이 직렬화 규약에 들어가므로 **`hash_format_version` 을 올리고 골든벡터를 다시 고정**한다.

🆕 **v1.22(01 §31 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17)** — `schema/ledger_file.dart` `LedgerModeCheck` += `fillOrigin`(tag `fill-origin` · LIVE 식 `BROKER`·`MANUAL`·`BROKER_RECOVERED` · SIM 식 + `SIMULATED` · `values` 4 → 5 · K61) · `ddl/README.md` «두 파일» 표 fill-origin 행(⏸ **태그 줄 + 로컬 스키마 재생성 = 엔진 재생성 PR** · data_sync 바이트 대조 · 🔴 v1 동결 12-21 전 · 미결 189) · C-15 `executions.fill_origin` 축 = 두 파일 합집합 · C-56 ⑮ 태그 전·후 두 상태 허용 · 배치 D `resume_run_mirror.resume_mode text not null check (NORMAL·CONSERVATIVE·RECOVERY_DRY·RECOVERY_FULL)`(`ResumeMode` 4 · `mode` = `RunMode` 와 다른 축 · K62 · 엔진 미러 칸 = 숙제) · 🔴 `ddl/batch_{a,b,c,f,g}` 0줄.

### 7-7. §6-7 GitHub 아카이브 레이아웃 (스키마 아님 — 출력 포맷 계약)

| 항목 | 계약 |
|---|---|
| 경로(실전) | `archive/{yyyy}/{yyyy-mm-dd}/{table}.jsonl` |
| 경로(모의) | `sim/{yyyy}/{yyyy-mm-dd}/{table}.jsonl` |
| 한 줄 | **한 원장 행** · 컬럼 순·수치 표기·NULL 규칙은 🔴 **X5-1 정규 직렬화와 같은 골든벡터** |
| 대상 표 | `day_hash` 대상 스트림 **전량** + 배치 F 신설 6표 + `operating_param_log` |
| 체크포인트 | `archive/checkpoint.json` = `{schema_version, hash_format_version, authored_date, chain_hash, operator_epoch, writer_device_id, committed_at}` 단일 객체 · 매 커밋 덮어쓰기 |
| 금지 | 🔴 **force push 금지**. 커밋 실패는 매매를 막지 않고 24h 적체 시 P1 |

🔴 **해시 체인 모집단 = 아카이브 대상**이어야 한다. 어긋나면 `canonGithub`·`canonCalendar` 대조가 «불일치 아님»을 **증명하지 못한다**.

---

## §8. ⑧ 픽스처 목록 — 영역 **F** · `fixtures/` + `lib/src/fixtures/`

> **위치 확정**: `packages/domain_contracts/fixtures/`(저장소 루트 기준 상대 경로). 🔴 코드·문서 어디에도 절대 경로를 적지 않는다.
> **원칙**: 실키·계좌 전체번호·비밀번호 **0건** · 계좌는 별칭만(`"연금저축"`·`"일반"`) · 티커는 실제 국내 ETF, **수량·가격은 가공값** · 금액은 **문자열**(`"38250.00"`).
> 🔴 **픽스처 갱신은 M2 만 한다.** 화면 담당이 「테스트가 안 맞아서」 고치는 것은 반려.
> 🔴 **월 납입 운영값 예시는 `100000`** 이며 **파일명에 금액을 넣지 않는다**(`_default`·`_limit`·`_expired`).

### 8-1. 봉투 형식 (전 픽스처 공통)

```json
{
  "meta": { "fixture_version": "0.1.0-draft", "contract_version": "M2-0.1",
            "generated_at": "…Z", "mode": "LIVE",
            "config_hash": "cfg_fake_…", "seed": 20260906,
            "notice": "합성 데이터. 실계좌·실키 없음." },
  "as_of": { "observed_at": "…Z", "trade_date": "YYYY-MM-DD",
             "source": "LOCAL_SQLITE", "stale_after_seconds": 93600, "label": "…" },
  "empty_kind": "NO_DATA", "empty_label": null, "has_more": false,
  "rows": [ … ]
}
```

🔴 `as_of`·`empty_kind`·`empty_label`·`has_more` 는 `ListResult<T>` 에 그대로 대응하며 **빈 목록 픽스처도 네 값을 싣는다**. 🔴 `meta.contract_version` 은 `lib/src/contract_version.dart` 상수와 **같은 축**이다(한쪽만 올리지 않는다).

### 8-2. 계약 코어 11건 — `fixtures/` 바로 아래

| 파일 | 건수 | 내용 |
|---|---|---|
| `journal_30.json` | 30 | 체결 22 · 부분 3 · 거부 2 · UNKNOWN 1 · prevented 1 · SIM 1 |
| `holdings_6.json` | 6 | ~~069500(A) · 379810·132030(B) · 0085P0·411060(C) · POT 1종~~ 🆕 v1.8(01 §8 미결 82 보유 몫 · K4) 069500(A) · 133690·411060(B) · 0085P0(C) · 133690·411060(POT) — `pnl` 은 3건만 · 행 == `m6/holdings_overview_pnl` 의 같은 `holding_id` 행(C-44 ④) |
| `performance_24m.json` | 24 | 월간 TWR/MWR + 결측 구간 1(`unavailable`) + 벤치마크 |
| `rebalance_6.json` | 6 | monthlyRegular 3 · seasonal 1 · band 1 · deposit 1 · 🆕 v1.5 행 링크 6 · 버튼 링크 5(01 §15-3) · 🆕 v1.6 거래일 내림차순 · 행 `as_of` = 봉투(관측 시각) · `thresholds` band·seasonal 회차 각 1행 · 나머지 4행 `[]` · 라벨 완성 문장(01 §15-4) |
| `resume_report_1.json` | 1 | 7거래일 갭 · `recoveryDry` · 4/3/2/1/2 |
| `safety_states.json` | 5 | normal · alert · reduced · halted · stopped(자격 충족 1) |
| `alerts_12.json` | 12 | ~~P0 2 · P1 4 · P2 6(묶임 2)~~ 🆕 v1.12(01 §8 미결 114 · K32) **P0 2 · P1 7 · P2 3(묶임 2)** — `al_0010`·`al_0011`·`al_0012` P2 → P1(엔진 정본 `04_안전장치.md` §5-3) · 옛 꼴 링크 2(`al_0005` → `advice/fill/ad_0002` · `al_0008` → `ledger/self-report/2026-08/연금저축`) · `al_0009` 딥링크 null |
| `ledger_diffs_4.json` | 4 | canonBroker 1(blocking) · 파생 3(observational) |
| `onboarding_fresh.json` | 14 | 처음 시작하기(verified/failed/expired 각 1) |
| `onboarding_reconnect.json` | 9 | 재연결 갈래 |
| `deposit_plan_1.json` | 1 | 월 납입 = 엔진 설정값 예시 · 잔여 = 원화 현금 대기(D2) · 주문 초안 ~~3~~ 🆕 v1.4 4 · `funding_steps` **null** · 🆕 v1.4 코어 전용(화면 미사용) · 새 표시 필드 · 종목 라벨 SPEC 정합 |

### 8-3. P 회차 3건 · S 회차 3건

| 파일 | 배치 | 내용 |
|---|---|---|
| `aftertax_ladder_1.json` | `m7/` | 정본 갈래(`SPEC_POT_TAX_FREE`) ~~5단~~ **6단**(사전 6층 전부 · 01 §8 미결 77 정정 · §15-1) + 반사실 1(`CF_POT_TAXABLE_COMP38` 6단 · 접힘) · `is_reference_only: true` · 층 값은 골든 4자리(«정직 기대» 층만 없음) |
| `deposit_plan_funding_1.json` | `fixtures/`(코어 옆) | 납입 조달 발동 · `funding_steps` ~~2단~~ 🆕 v1.4 **1단계**(0원 조달 단계 삭제 · C 방어 자산 매도 초안 = `PENSION_FUNDING` 칩). 🔵 정본 경로에서 **한 번도 발동하지 않으므로** 없으면 §3-6 표시 경로가 영영 미검증 |
| `entry_gate_nov_pass_1.json` | `m6/` | 계절 게이트 **11월 재판정 통과**(`enteredInNov`). 🔵 26시즌 실측 발동 0 — 실데이터로는 검증 불가한 유일한 경로 |
| `m7_deposit_plan_default.json`·`_limit.json`·`_expired.json` | `m7/` | `S7-4` 3벌: 기본 / 연 한도 소진 / 계획 만료. 🔴 **파일명에 금액 금지** · 🆕 v1.4 — 행 타입 `DepositPlan` → **`DepositPreviewResult` 래퍼**(`{ "plan": { … } }` · 등록부 재바인딩) |
| `realized_alloc_S7.json` | `m7/` | **C-31 의 입력** — 회계 열(`A_acct`·`C_acct`·`pot`) 대조 · 🆕 v1.8 +`sleeve_label` 만(밴드 축 키 없음 · 01 §8 미결 109) |

### 8-4. X7 22파일 — `m6/`·`m7/`·`m8/`·`m9/`

`advice_12` · `advice_empty` · `advice_blocked` · `advice_expired_confirm` · `advice_no_action`(🔴 **C-26 의 입력** — 없으면 「억제된 날의 침묵」 검사가 입력 없이 자동 통과) · `advice_handover_cooling`(`handoverCoolingActive == true` + `openCount == 0` 조합) · `advice_detail_partial` · `advice_detail_onhold` · `advice_viewer_4`(🔴 **A6 마스킹판** — C-27 의 입력) · `fill_form_spec` · `fill_form_spec_stale`(A16 폼을 열지 않는 갈래) · `manual_fills_8`(original 5 · 상쇄+재기재 2쌍 · backdated 1) · `fill_rejected_price`(🔴 **입력값 보존** — C17) · `advice_skip_reasons` · `self_report_1` · `execution_gap_cant`·`_wont`·`_mixed`(🔴 **B21 3갈래** — ~~`modeAdviceLine` 이 각각 달라야 한다~~ 🆕 v1.6 ⓐ cant·ⓑ wont 문장이 서로 다르고 ⓒ mixed 는 줄 부재(null) — K6 · 03 §14-b 수용 (b) 정정) · `ledger_trust_4` · `handover_states` · `external_holdings_2` · `onboarding_fresh_advisory`.

**총 40파일**(코어 11 + P 3 + S 3(+`realized_alloc_S7` 1) + X7 22).

🆕 **v1.4(2026-09-30 · 01 §14-16)** — 이 절의 «총 40» 은 G3 착수 당시 목록이다(현재 = 등록부 `FixturePaths` 정본). v1.4 = **개정 16 · 신설 7 → 122**: `m7/m7_deposit_plan_blocked`·`_input_rejected`·`_funding` · `m7/m7_deposit_register_receipts_4` · `m7/m7_goal_path_off` · `m9/contribution_setting_default`·`_no_limit_note`(상세 = `fixtures/README.md` «계약 v1.4» 절).

🆕 **v1.5(2026-10-07 · 01 §15-3)** — **개정 2 · 신설 4 → 126**(기존 122 가운데 120 은 봉투 `contract_version` 한 줄만): 개정 `rebalance_6`(6행 `detail_deep_link` · as_of 이전 5행 `journal_timeline_link` · `re_20261030_01` 은 버튼 없음 = 부재 표본) · `m7/m7_rebalance_detail_band`(같은 두 필드) / 신설 `m6/journal_rebalance_scope_1`(`JournalRebalanceScope` 1행) · `m6/journal_rebalance_unknown`(모르는 회차의 `J-1` 0행 봉투) · `m7/m7_rebalance_detail_advisory`(band 의 거울 · 버튼 글자만 다르다) · `m7/m7_rebalance_empty`(`S7-6a` 0행 봉투) · `FixturePaths` 상수 +4 · 생성 = `packages/domain_contracts/tool/gen_r12_fixtures.py`(기준 `dbbd3ae` 원문에서 멱등) · 상세 = `fixtures/README.md` «계약 v1.5» 절.

🆕 **v1.6(2026-10-08 · 01 §15-4 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`)** — **신설 9 · 개정 14(개명 1 포함) → 135**(기존 126 가운데 112 는 봉투 `contract_version` 한 줄만): 신설 `m7/m7_rebalance_preview_default`·`_in_band`·`_blocked`(`RebalancePreviewResult` — 초안 2행 / 빈 초안 / 차단 2행(버튼 부재·있음)) · `m7/m7_next_rebalance_none`(«예정 없음») · `m7/m7_rebalance_sim`(SIM 회차 2행 · 봉투 `meta.mode` LIVE · 행 `mode` SIM) · `m7/m7_annual_offwindow`(2025 · `CLOSED`) · `m7/execution_gap_empty`·`_not_applicable`·`_masked_recon`(`ExecutionGapResult` — 빈 / 해당없음 / RECON 가림) / 개정 `rebalance_6` · `m7/m7_rebalance_detail_band`·`_advisory` · `m7/m7_annual_2026`·`_first_year` · `m7/aftertax_ladder_1`(`reference_only_label`) · `m7/execution_gap_1`·`_cant`·`_wont`·`_mixed`(행 = 래퍼 `{report, as_of}` · 등록부 재바인딩) · `m7/m7_monthly_2026_08`·`_gap`·`_masked_recon`(⑧ 링크 = 그 달) / 개명 `m7/m7_next_rebalance_d6` → **`m7/m7_next_rebalance_countdown`**(`FixturePaths.m7M7NextRebalanceD6` → `m7M7NextRebalanceCountdown` · «D-6» → «D-1») · `FixturePaths` 상수 +9 · 개명 1 · `all` = **135** · 등록부 코덱 +2(`RebalancePreviewResult`·`ExecutionGapResult`) · 생성 = `packages/domain_contracts/tool/gen_r12_v16_fixtures.py`(기준 `542d13c` 원문에서 멱등 · v1.5 스크립트는 재현용으로 둔다) · 상세 = `fixtures/README.md` «계약 v1.6» 절.

🆕 **v1.7(2026-10-20 · 01 §16 · ⬜ 로컬 커밋 — PR 대기)** — **신설 6 → 141**(기존 135 는 봉투 `contract_version` 한 줄만 · 개정 0): `m6/blind_review_queue_3`(대기 목록 3행 — 오래된 결정부터 `d_20260811_c_28` → `d_mf_0002` → `d_mf_0004`(매도) · 🔴 `JOURNAL_MISSING` 대상 `d_20260810_b_27` 은 큐에 없다 — K3 ⓓ 확정) · `m6/blind_review_queue_empty`(빈 큐 문장 · DRY_RUN 장면 — K24) · `m6/blind_review_card_before`(행 0 그대로) · `m6/blind_review_card_revealed`(+ 청산 결과 · 금액 0 — K6) · `m6/blind_review_card_revealed_open`(행 1 `d_mf_0002` + «미청산 — 결과 미확정») · `m6/blind_review_receipts_6`(`BLIND_REVIEW_SCORE` 접수증 6행 · 거부 사유 2종) · `FixturePaths` 상수 +6 · 생성 = `packages/domain_contracts/tool/gen_j4_v17_fixtures.py`(기준 `76c2404` 원문에서 멱등) · 상세 = `fixtures/README.md` «계약 v1.7» 절.

🆕 **v1.8(2026-10-21 · 01 §17 · ⬜ 로컬 커밋 — PR 대기)** — **신설 18 · 개정 3 → 159**(기존 141 가운데 138 은 봉투 `contract_version` 한 줄만): 신설 `m6/holdings_overview_{normal,recon,integrity,empty,pnl,viewer}`(`H6-1` · `HoldingsOverviewVm`) · `m6/holding_detail_{with_stops,no_stop,pnl,recon,integrity}`(`H6-2` · `HoldingDetailVm` — `with_stops` = 보존 경로 표본 · K16 ⓓ) · `m6/allocation_{in_band,out_of_band,tranche_progress,parking_large,integrity,recon,empty}`(`H6-3` · `SleeveAllocationVm` — 밴드 행 = B 만 · K27) · 개정 `holdings_6`(행 교체 · 미결 82 보유 몫 · 라벨 = 입금 픽스처 이름 · 트랜치 B 만 · 손익 고지 정정) · `m6/external_holdings_2`(+`quantity_text`) · `m7/realized_alloc_S7`(+`sleeve_label`) · 생성 = `tool/gen_h6_v18_fixtures.py`(기준 `f46e72f` 원문 · 멱등) · 표 = `fixtures/README.md` «계약 v1.8».

🆕 **v1.12(2026-10-22 · 01 §21 · ⬜ 로컬 커밋 — PR 대기)** — **신설 15 · 개정 22 → 174**(기존 159 가운데 137 은 봉투 `contract_version` 한 줄만 · 🆕 검증 반영 — 설계서 목록 23 중 `m6/advice_handover_cooling` 은 결과가 버전 줄만): 신설 `m6/ledger_repairs_4`·`_empty`(`L-2` · `LedgerRepairRow`) · `m6/ledger_diffs_cash_observe`(`L-1` 현금 관측) · `m6/self_report_diff_result`·`_session_closed`(`L-3` · `SelfReportSession`) · 접수증 4(`m6/self_report_receipts_5` · `manual_fill_receipts_7` · `advice_skip_receipts_5` · `advice_defer_receipts_3`) · `m6/fill_form_spec_blocked`(K21) · `m6/safety_advice_blocked`(`a1_blocked` 배너) · `m6/advice_stale`(K41) · `m6/advice_fills_ad0005`(K40) · `m7/ledger_trust_self_audit_due`(K45) · `m8/ops_rhythm_empty`(K29) · 개정 `ledger_diffs_4`(+8 표시 키) · advice 인박스 7 + 상세 2(DETAIL 삭제 · 링크 · 확인 카드 · 순서 = 엔진) · `advice_skip_reasons`·`fill_form_spec(_stale)`(K22 · K37) · `fill_rejected_price`(재제출 선택지) · `self_report_1`(꼴 교체 → `SelfReportSession`) · `draft_records_x7`(L-3 키) · 알림·리듬·안전 상태·인시던트(옛 꼴 링크 7 · 등급 5행 — 미결 114) · `ops_home_resume_gap7`(`resume_line`) · 생성 = `tool/gen_r5r13_v112_fixtures.py`(기준 `f54f602` 원문 · 멱등) · 표 = `fixtures/README.md` «계약 v1.12».

🆕 **v1.13(2026-10-26 · 01 §23 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #72 squash `638fca4`)** — **신설 2 · 개정 1 → 176**(기존 174 가운데 173 은 봉투 `contract_version` 한 줄만): 신설 `m8/recon_board_ok`(`DiagnosticsVm` · 전부 일치 · 자가보고 «해당 없음» INFO · `headline` 엔진 일치 문장) · `m8/ops_home_advice_suppressed_due`(`OpsDailySummary` + `advice_summary` — 억제 + `due_soon_label`) · 개정 `m8/recon_board_diff`(칸 `level` BLOCKED·WATCH·OK·OK·INFO) · 재사용 `m6/allocation_empty`(배분 notice 없음 표본) · 생성기 `tool/gen_r13b_v113_fixtures.py`(기준 `fc25f77`) · 등록부 m8 `advice_summary` extras 3.

🆕 **v1.14(2026-10-27 · 01 §22 · E8a · ✅ 병합 PR #73 squash `ab78a15`)** — 신설·개정 0 · **176 그대로**(봉투 `contract_version` 한 줄만).

🆕 **v1.15(2026-10-30 · 01 §24 · R14 선행 · ✅ 병합 PR #86 squash `e9e71c8`)** — **신설 11 · 개정 5 → 187**(기존 176 가운데 171 은 봉투 `contract_version` 한 줄만): 신설 `m8/alert_center_p0_ack`·`_digest`·`_empty`·`_p0_only`·`_p0_ack_reordered`(`AlertCenterVm`) · `m8/alert_detail_full`·`_no_link`·`_missing`(`AlertDetailVm`) · `m8/alert_ack_receipts_3`(`ALERT_ACK` 3갈래) · `m8/watchdog_paused`·`_empty`(`WatchdogBoardVm`) / 개정 `alerts_12`(ack·등급 순 차례) · `m8/alerts_p0_ack` · `m8/alerts_advice_9codes`(차례만) · `m8/watchdog_delayed`·`_holiday`(`WatchdogBoardVm` 꼴 · `slug` → `check_id` · `level`) · 생성기 `tool/gen_r14_v115_fixtures.py`(기준 `1bb1a84` · 멱등) · 표 = `fixtures/README.md` «계약 v1.15» 절.

🆕 **v1.16(2026-11-03 · 01 §25 · R15 선행 · ✅ 병합 PR #96 squash `dd9e162`)** — **신설 32 · 개정 6 → 219**(기존 187 가운데 181 은 봉투 `contract_version` 한 줄만): 신설 R15a 7 `m8/onboarding_start`·`_start_no_viewer`(`OnboardingStartVm`) · `m8/onboarding_mode_unselected`·`_mode_auto`·`_mode_advisory`·`_mode_locked`(`OnboardingModeChoiceVm`) · `m8/onboarding_mode_select_results`(`ActionResult` 2행) / R15b 10 `m8/onboarding_steps_fresh`·`_advisory`·`_empty`·`_finish_ready`·`_finish_ready_warn`·`_all_verified_locked`(`OnboardingStepsVm`) · `m8/onboarding_step_detail_kis_mock`·`_missing`·`_no_verify`(`OnboardingStepDetailVm`) · `m8/onboarding_verify_results` / R15c 8 `m8/onboarding_finish_auto`·`_auto_ready`·`_auto_declared`·`_advisory`·`_advisory_declared`·`_done`·`_no_expectation`(`OnboardingFinishVm`) · `m8/onboarding_finish_results` / R15d 7 `m8/restart_vm_lost_phone`·`_gap7`·`_logged_out`·`_unknown`(`RestartVm`) · `m8/pairing_waiting`·`_ok`·`_fail`(`PairingVm`) / 개정 `onboarding_fresh`·`onboarding_reconnect`·`m8/onboarding_fresh_advisory`·`m8/onboarding_finish`·`m8/restart_lost_phone`(`OnboardingStep` 표시 칸 6) · `m8/onboarding_mode_pick`(«권장» 낱말) · 생성기 `tool/gen_r15_v116_fixtures.py`(기준 `267e867` · 멱등) · 표 = `fixtures/README.md` «계약 v1.16» 절.

🆕 **v1.17(2026-11-04 · 01 §26 · R16 선행 + 엔진 D11 · ✅ 병합 PR #123 squash `0249f61` · 2026-11-05)** — **신설 21 · 개정 3 → 240**(기존 219 가운데 216 은 봉투 `contract_version` 한 줄만): 신설 R16a 12 `m8/incident_banner_token_expired`·`_order_rejected`·`_network_down`·`_phone_down`·`_other`·`_none`(`IncidentBannerVm` · 종류 5 전수 · 등급 BLOCKED 2·ACT·WATCH·INFO · `OK` 0 · 조치 있음 2) · `m8/runbook_index`·`_index_empty`·`_host_lost`(비순번 «2-1.»)·`_missing`(`RunbookIndexVm`·`RunbookVm` · 03_실행 §10-5 ①~⑥ · ⑥ 행 = `aaq://ops/emergency-card`) · `m8/emergency_card`·`_no_print`(`EmergencyCardVm` · 04_안전장치 §5-5 + §10-5 ⑥ · 공개 고객센터 번호만) / R16b 5 `m8/handbook_index`·`_index_outdated`(8항목 · ② 자식 4) · `m8/handbook_page_outdated`·`_page_missing`·`_page_archived` / R16c 2 `m8/device_risk_items`(5행 · `UiLevel` 5값)·`_empty` / 엔진 D11 2 `m6/journal_expired_1`(EXPIRED · 칩 `DAY_END_EXPIRED`) · `m8/alerts_stale_orders_held`(P1) / 개정 `m8/handbook_page_sleeve_b`(live 블록 + `as_of` · 형제 키 `index` 삭제) · `m8/incident_token_expired`(형제 키 알림 `code` → `BROKER_AUTH_FAILED` · 미매핑 유지 · 01 §8 미결 165) · `journal_30`(`je_0018` 칩 `code` → `DUPLICATE_ORDER_PREVENTED` · `label` 무변경) · 생성기 `tool/gen_r16_v117_fixtures.py`(기준 `ea06df2` · 멱등) · 표 = `fixtures/README.md` «계약 v1.17» 절 · 계약 테스트 🆕 C-51(`c51_r16_incident_handbook_device_test.dart` · 14항) · `domain_contracts` +424 → **+438 ~30**.

🆕 **v1.18(2026-11-13 · 01 §27 · R6 선행 + 엔진 등재형 7 · ✅ 병합 PR #142 squash `b582c49` · 2026-11-13)** — **신설 8 · 개정 1 → 248**(기존 240 가운데 239 는 봉투 `contract_version` 한 줄만): 신설 R6a 3 `m9/settings_home`·`_no_review`·`_viewer`(`SettingsHomeVm` · 묶음 3 · 카드 11 · 레벨 5값 전수 · 연간 링크 있음/없음 · 뷰어 판 = 폰 전용 행 0) / R6b 4 `m9/connections`·`_telegram`·`_locked`(`ConnectionsVm` · 행 레벨 5값 · 부분 동기 `detailLine` · 잠김 = `lockedLabel` + 동작 칸 0) · `m9/settings_action_results`(`ActionResult` · 레벨 5값 · 코드 3 · `retryable` 0 · 넘김 0) / 엔진 등재형 1 `m8/alerts_safety_resume`(`AlertItem` 6 · P0 3 · P1 2 · P2 1) / 개정 `m8/incident_token_expired`(행 `level`·`actions` · `action_available` 삭제 · `HEALTHCHECKS` `route` = `opsWatchdog` · 등록부 `_connectionsVm` 바인딩 — 01 §8 미결 165 해소) · 생성기 `tool/gen_r6_v118_fixtures.py`(멱등) · 표 = `fixtures/README.md` «계약 v1.18» 절 · 계약 테스트 🆕 C-52(`c52_r6_settings_connections_test.dart` · 13항) · `domain_contracts` +438 → **+451 ~30**(PR 실측).

🆕 **v1.19(2026-11-14 · 01 §28 · R6c 선행 + 엔진 E15i 굳은 몫 · ✅ 병합 PR #163 squash `6b8ed02` · 2026-11-14)** — **신설 8 · 개정 0 → 256**(기존 248 전부 봉투 `contract_version` 한 줄만): 신설 VM 1행 봉투 7 `m9/operations_sim_auto` · `_sim_complete` · `_live_observe` · `_live_promotable` · `_live_hold_keys`(DST 표식 · 기준일 2026-11-02) · `_advisory`(`GateState.block` 표본 — C4r4b-8) · `_locked`(동작 칸 5 비움) · 목록 봉투 1 `m9/operations_action_results`(`ActionResult` 13행) · 레벨 5값 전수 · 체험 상태 4값 · 잡 상태 5값 · 생성기 `tool/gen_r6c_v119_fixtures.py`(기준 `175cbd5` · 멱등) · 표 = `fixtures/README.md` «계약 v1.19» 절 · 계약 테스트 🆕 C-53(`c53_r6c_operations_test.dart` · 15항) · C-52 ⑨ 좁힘 · C-7 파일별 읽기 칸 허용 `updateGate`(K27) · `domain_contracts` +451 → **+466 ~30**(PR 실측).

🆕 **v1.20(2026-11-15 · 01 §29 · R7 선행 + 엔진 겹침 몫 · ✅ 병합 PR #187 squash `52f2fc9` · 2026-11-15)** — **신설 15 · 개정 1 → 271**(나머지 255 봉투 `contract_version` 한 줄만): 신설 VM 1행 봉투 12 — S02 `m9/credentials` · `_sim_sealed` · `_advisory` · `_locked` · S06 `m9/device_access` · `_ticket` · `_no_viewers` · `_stale`(VM `as_of.stale_label`) · `_locked` · S03 `m9/account_mapping` · `_unmapped` · `_locked` · 목록 봉투 3 `m9/credential_action_results`(6행) · `m9/device_action_results`(6행) · `m9/account_mapping_action_results`(8행) · 🔧 개정 1 `m8/onboarding_step_detail_kis_mock` `verify.args.kind` `KIS_MOCK` → `KIS_PAPER`(슬롯 이름 `SECRET_KIS_MOCK` 그대로 · 엔진 겹침 · K8 · PNG 0) · 레벨 5값 = 화면별 합집합 + 결과 벌마다(K34) · POT 행 0 · 키 조각 0 · 생성기 `tool/gen_r7_v120_fixtures.py`(기준 `7320c92` · 멱등) · 표 = `fixtures/README.md` «계약 v1.20» 절 · 등록부 코덱 3 · 바인딩 15 · 계약 테스트 🆕 C-54(`c54_r7_credentials_devices_accounts_test.dart` · 19항) · C-5 · C-6 +15 · C-8 `_knownUncovered` − 4 · C-33 ③ 81 · `domain_contracts` +466 → **+485 ~30**(PR 실측).

🆕 **v1.21(2026-11-15 · 01 §30 · 엔진 예고 1/2 — M5 안전 쓰기 포트 + 체험 길 · ✅ 병합 PR #189 squash `81bf79c` · 2026-11-16)** — **신설 12 · 개정 1 → 283**(나머지 270 봉투 `contract_version` 한 줄만): 🆕 폴더 `m5/` — 재개 게이트 VM 1행 봉투 7(`not_confirmed` · `waiting` · `time_unknown` · `ready` · `in_progress` · `condition_unmet` · `locked`) · 서약 VM 1행 봉투 3(`written` · `not_written` · `edit_window`) · 목록 봉투 2 `m5/safety_action_results`(14행) · `m5/kill_checklist_receipts`(7행 · `KILL_CHECKLIST_CONFIRM` 접수증) · 🔧 개정 1 = F3 `safety_states` stopped 행 `ramp_level` `L0` → `L1`(화면 미표시 칸 · PNG 0 · K19) · 게이트 머리·ETA·막힘·냉각 게이지·6번 재생 = 엔진 `killSwitchViewOf` · `releaseProgressOf` 글자 그대로(냉각 `normalized` = 31/48 · 반올림 0) · 7문항 = SPEC v2.40 04 §3-6 «재개판»(K38) · 서약 줄 = 합성 · 생성기 `tool/gen_v121_fixtures.py`(기준 `83c3d44` · 멱등) · 표 = `fixtures/README.md` «계약 v1.21» 절 · `FixturePaths` m5 12 · 등록부 코덱 3 · 바인딩 12 · 계약 테스트 🆕 C-55(`c55_safety_actions_kill_pledge_test.dart` · 19항) · C-7 넷째 창구 · C-16 정정 · C-6 +12 · C-8 `_knownUncovered` +4 · C-33 ③ 84 · `domain_contracts` +485 → **+505 ~30**(PR 실측 · 병합본 재실측 같음).

🆕 **v1.22(2026-11-17 · 01 §31 · 엔진 예고 2/2 — E13 나머지 · 사다리 · X2 재개 · simToAuto · F8 · ✅ 병합 PR #214 squash `67630bc` · 2026-11-17)** — **신설 15 · 개정 2 → 298**(나머지 281 봉투 `contract_version` 한 줄만): `m5/` 8 — 사다리 VM 1행 봉투 2(`breaker_ladder_normal` · `_stopped` · 글자 = 엔진 `breakerLadderOf` 출력 · `current` 만 다름) · 목록 봉투 `safety_action_results_e13`(31행 · E13 동작 8) · simToAuto 계획 VM 1행 봉투 4(`handover_sim_to_auto_ready` · `_s3_blocked` · `_cooling` · `_fate_pending` · 단계 글자 = 엔진) · 목록 봉투 `handover_sim_to_auto_action_results`(20행) · 🆕 폴더 `x2/` 6 — 재개 게이트 VM 4(`resume_gate_seasonal_pending` · `_conservative_defer` · `_reevaluation_failed` · `_locked`) · 리포트 2(`resume_report_recovery_full` · `_normal`) · `m6/journal_sim_broker_reject`(J-1 행 1 · 칩 `SIM_INVALID_ORDER`) · 🔧 개정 2 = F8 `resume_report_1`(RECOVERY_DRY 정합 · 엔진 DRY 판정 꼴) · `m9/handover_states` SIM_TO_AUTO 행(3 → 7단계 · UI 소비 0) · 생성기 `tool/gen_v122_fixtures.py`(기준 `4f85259` · 멱등 · 두 번 = 같은 md5 298) · 표 = `fixtures/README.md` «계약 v1.22» 절 · 계약 테스트 🆕 C-56(`c56_e13_resume_sim_test.dart` · 18항) · C-7 표면 8 · C-15 축 +2(+ «fill_origin 합집합» 시험 1) · C-8 `_knownUncovered` += 제출 DTO 5 · C-5 중복 +1 · C-33 84 무수정 · 변이 18/18 · `domain_contracts` +505 → **+524 ~30**(PR 실측 · 설계 기대 +18 에 C-15 1 더함).

🆕 **v1.23(2026-11-17 · 01 §32 · R8a 선행 — M9 `S13` 월 납입 설정 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — **신설 7 · 개정 0 → 305**(나머지 298 봉투 `contract_version` 한 줄만): `m9/` VM 1행 봉투 6(`monthly_contribution` · `_pending` · `_no_record` · `_no_limit_note` · `_locked` · `_stale` · 글자 = 엔진 `contributionSettingOf` 출력) · 목록 봉투 `m9/contribution_action_results`(9행 · 거부 headline 7 = 엔진 `decideContributionChange` 출력 · 접수 = «(합성)») · 금액 글자 = 10만원 · 0원 · 10억원만(K99 · «9만» = C-32 ⑥ 폐기값) · 기존 `m9/contribution_setting_*` 무수정(S7-4 골든 입력 · PNG 0) · 생성기 `tool/gen_r8_v123_fixtures.py`(기준 `33fe351` · 멱등) · C-57 13항.

🆕 **v1.25(2026-11-19 · 01 §34 · 트랙 B 선행 · ~~⬜ PR 대기~~ ✅ 병합 PR #256 squash `233adda8`(2026-11-19 · CI 3/3))** — **신설 17 · 개정 0 → 339**(나머지 322 봉투 `contract_version` 한 줄만): `m5/` 13(킬스위치 화면 7 · 발동 접수증 1 · 게이트 꺼짐 1 · 차단 보드 4) · `x2/` 4(리포트 화면 감싸개 3 · 게이트 막힌 것 0 1) · 생성기 `tool/gen_trackb_v125_fixtures.py` · 🆕 C-59(17항).

🆕 **v1.26(2026-11-20 · 01 §35 · 트랙 C 선행 · ~~⬜ PR 대기~~ ✅ 병합 PR #270 squash `09d3580d`(2026-11-20 · CI 3/3))** — **신설 20 · 개정 2 → 359**(나머지 337 봉투 `contract_version` 한 줄만 · 개정 2 = `m5/block_board_kill_active` · `_resume_incomplete` 보드 행 끝 `"recon_clear": null`): `m5/` 20(위저드 12 · 규칙 변경 게이트 5 · 요청·해제 결과 2 · 보드 RECON 1) · 생성기 `tool/gen_trackc_v126_fixtures.py` · 🆕 C-60(17항).

🆕 **v1.27(2026-11-20 · 01 §36 · E3d 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #274 squash `551282e0`(2026-11-20 · CI 3/3))** — **신설 1 · 개정 0 → 360**(나머지 359 봉투 `contract_version` 한 줄만): `m8/alerts_engine_proposals_v127`(`AlertItem` 5행 · 글자 = 엔진 `kAlertTexts` · 등급 = 엔진 `kAlertLevels` · 등급 순) — 🆕 tool/gen_e3d_v127_fixtures.py.

🆕 **v1.28(2026-11-20 · 01 §37 · S04 첫 판 · ~~⬜ PR 대기~~ ✅ 병합 PR #282 squash `9c7ff349`(2026-11-20 · CI 3/3))** — **신설 2 · 개정 0 → 362**(나머지 360 봉투 `contract_version` 한 줄만): `m9/allocation_editor` · `_stale`(글자 = 엔진 시험 원문) · 생성기 `tool/gen_s04_v128_fixtures.py` · 🆕 C-62(12항) · C-57 ⑦ 주문 한도 행 예외 1.

🆕 **v1.29(2026-11-20 · 01 §39 · E11k-b 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #288 squash `b979ae33`(2026-11-21 · CI 3/3))** — **신설 2 · 개정 0 → 365**(나머지 363 봉투 `contract_version` 한 줄만): `m8/onboarding_step_detail_supabase` · `m8/onboarding_supabase_connect_results` · 생성기 `tool/gen_e11k_v129_fixtures.py` · 🆕 C-64(8항) · 엔진 대조 data_sync 1.

🆕 **v1.30(2026-11-21 · 01 §38 · E16i 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #293 squash `2fdfefb5`(2026-11-21 · CI 3/3))** — **신설 0 · 개정 0 → 365**(전 봉투 `contract_version` 한 줄만) · 생성기 `tool/gen_e16i_v130_fixtures.py` · 🆕 C-63(10항) · C-5 · C-58 ⑧ · C-56 ⑧ 개정 · 엔진 대조 시험 2(core · data_sync).

🆕 **v1.31(2026-11-21 · 01 §40 · E11k-d2 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #298 squash `922df462`(2026-11-21 · CI 3/3))** — **신설 2 · 개정 0 → 367**(나머지 365 봉투 `contract_version` 한 줄만): `m8/onboarding_step_detail_supabase_login` · `m8/onboarding_supabase_signin_results` · 생성기 `tool/gen_e11k_d2_v131_fixtures.py` · 🆕 C-65(8항) · C-50 허용 목록 +1.

🆕 **v1.32(2026-11-21 · 01 §41 · E16j-a 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #299 squash `268d6bff`(2026-11-21 · CI 3/3))** — **신설 8 · 개정 0 → 375**(나머지 367 봉투 `contract_version` 한 줄만): 🆕 폴더 `x5/` — `RepairWizardVm` 1행 봉투 7(`repair_hub_targets` · `repair_hub_empty` · `repair_diff_default` · `repair_diff_stage3` · `repair_diff_ready` · `repair_integrity_ready` · `repair_boundary_x1`) · 결과 `repair_action_results` 11행 · 생성기 `tool/gen_e16j_a_v132_fixtures.py` · 🆕 C-66(13항) · 개정 C-7 · C-8 · C-33 · C-63 ⑩ · 엔진 대조 data_sync 1.

🆕 **v1.33(2026-11-21 · 01 §42 · E16j-b 계약 창 · ~~⬜ PR 대기~~ ✅ 병합 PR #305 squash `ec203163`(2026-11-21 · CI 3/3))** — **신설 15 · 개정 0 → 390**(나머지 375 봉투 `contract_version` 한 줄만): 🆕 폴더 `x1/` — `X1PlanWizardVm` 1행 봉투 6 · `X1RecoveryVm` 1행 봉투 8 · 결과 `x1_action_results` 14행 · 생성기 `tool/gen_e16j_b_v133_fixtures.py` · 🆕 C-67(14항) · 개정 C-5 · C-60 ⑮ · C-63 ⑩ · 엔진 대조 core 1.

🆕 **v1.24(2026-11-18 · 01 §33 · R9 선행 — M9 `S09` · `S10` · `S12` · ✅ 병합 PR #235 squash `bbed5ef` · 2026-11-18 · R8a 병합 뒤)** — **신설 17 · 개정 0 → 322**(나머지 305 봉투 `contract_version` 한 줄만): `m9/` VM 1행 봉투 15(`backup*` 6 · `diagnostics_screen*` 5 · `annual_review_index*` 4) · 목록 봉투 2(`backup_action_results` 10행 · `selftest_action_results` 12행) · 생성기 `tool/gen_r9_v124_fixtures.py` · `board` = `m8/recon_board_*` `rows[0]` 복사.

### 8-5. 로더 — `lib/src/fixtures/fixture_loader.dart`

- 🔴 **순수 Dart**여야 한다(`dart:io` 를 쓰면 web viewer 빌드가 깨진다) → 파일 읽기는 호출자가 하고 로더는 **문자열 → DTO** 만 한다. 시그니처 축: `ListResult<T> decodeList<T>(String json, T Function(Map<String,Object?>) rowFrom)` · `FixtureEnvelope decodeEnvelope(String json)`.
- 🔴 봉투 필수 4값(`as_of`·`empty_kind`·`empty_label`·`has_more`)이 없으면 **예외를 던진다**(빈 값으로 넘기지 않는다).

### 8-6. 🔴 기존 픽스처 전량 개정 규약 (C10)

X7 은 `TradeJournalEntry` 에 required 6, `HoldingRow` 에 required 2, `FeatureFlags` 에 required 1 을 넣는다 — 세 타입은 거의 전 픽스처가 참조하므로 **통째로 역직렬화에 실패**하고 그 위 골든이 동시에 깨진다.
🔴 **«계약 변경 고지» 규약**(골든 규칙의 유일한 예외) — M2 가 개정 픽스처와 함께 고지 1건을 내고, **그 고지가 있는 PR 에서만** C-2 위젯 골든 재베이스라인을 허용한다. 고지가 없으면 「픽스처가 그대로인데 다시 찍었다」와 구별되지 않으므로 반려.

---

## §9. ⑨ 계약 회귀 테스트 C-1 ~ C-32 — 영역 **F** · `test/`

> `melos run test:contracts` 하나로 돈다. **위반은 «잘못된 화면»이 아니라 «빌드 실패»다.**
> «자동화» 열: 🟢 = 이 패키지 안에서 지금 자동화 가능 · 🟡 = `ui_*`·`data_sync` 가 있어야 실효(지금은 **스켈레톤 + skip**) · 🔵 = 골든 파일이 선행.

| # | 무엇을 어떻게 검사하나 | 자동화 |
|---|---|---|
| C-1 | 픽스처 → 뷰모델 변환 결과를 `*.golden.json` 과 비교 | 🔵 F 가 픽스처와 함께 만든다. 🔴 **골든은 M2 소유**이며 화면 담당은 읽기만 |
| C-2 | 대표 화면 9개를 픽스처로 렌더 → PNG 비교(light/dark) | 🟡 `ui_*` 선행. 최초 베이스라인은 그 화면 PR 에서만 «추가» 허용 |
| C-3 | `ui_*` 의 pubspec·import 그래프에서 `core_engine`·`decimal`·`sqflite`·`supabase_flutter` 금지 | 🟡(pubspec 파싱은 지금도 가능 — **부분 자동화**) |
| C-4 | `ui_*` 에서 `Money`/`Decimal` 필드에 `*`·`/`·`+` 적용 탐지(custom_lint). 🔴 **확장 대상** = `*Pct`·`*Ratio`·`cagr*` 이름의 double 필드 | 🟡 |
| C-5 | `ui_*` 전 파일(🔴 `lib/l10n/labels.dart` 제외)에서 **한글 리터럴 0건** + `'TIER '`·`'SAF-'` 리터럴 금지 | 🟡 |
| C-6 | 홈·알림·위젯 위젯트리에 `HoldingPnl`·`PerformanceSeries` 타입 참조 금지 | 🟡 |
| C-7 | `ui_*`(`ui_safety` 제외)에 ① `killSwitch`·`releaseProgress`·`ResumeReport` **원본** 렌더 ② 조작 위젯 ③ `CommandApi`·`SettingsActions` 밖의 쓰기 — 🔴 §2-10 표의 ✅ 항목(배너·읽기 목록·딥링크)은 **통과** | 🟡 |
| C-8 | 전 DTO `fromJson(toJson(x)) == x` · 금액은 **문자열 유지** | 🟢 |
| C-9 | Decimal 규약 벡터 GV-8a/8d/8f 를 Dart 로 재현(곱셈 선행 · `Decimal.one −`) | 🟢 |
| C-10 | `PerfPoint.value == null` 구간이 **보간되지 않고 공백**인지 | 🟡(뷰모델 층은 🟢) |
| C-11 | `staleAfter` 초과 픽스처에서 배너가 뜨는지 | 🟡 |
| C-12 | 모든 enum 을 `default:` 없이 exhaustive switch 로 분기 | 🟡 — 🔴 **파급이 의도된 게이트**다 |
| C-13 | 픽스처 `config_hash` vs 핸드북 메타 불일치 시 실패 | 🔵 핸드북 원고 선행 |
| C-14 | `fixtures/` 에 KIS 앱키·`ya29.`·`1//`·8자리 계좌 패턴 탐지 | 🟢 |
| C-15 | 픽스처의 **열거값·필드**가 §7 DDL 의 `CHECK`·컬럼과 일치 | 🟢 — 🔴 `SAT`·`REQUIRED`·`RECORD_MANUAL_FILL` 같은 **비기계적 매핑**을 잡는 것이 이 검사의 요점 |
| C-16 | `CommandApi` 구현이 `command_queue` 에 UPDATE/DELETE 를 부르지 않는지 | 🟡 `data_sync` 선행 |
| C-17 X6 | `runMode` = SIM 계열 픽스처로 **모든 라우트** 렌더 → 골든 텍스트에 «모의투자» 포함. **표본 아님·전수**(라우트 테이블에서 열거) | 🟡 |
| C-18 X7 | `advisory` 픽스처 전 라우트 렌더 · **띠 1개**(2줄 금지) · 접두 순서 «모의투자 · 투자 안내 · 제목» · 🔴 `A-1` 위젯 트리에 `AdviceStatus`·`onHold`·`suppressed` 조건 분기 **0건** · 🔴 `autoTrade` 픽스처에서 `A-3`·`A-4`·`L-3` **가드 리다이렉트** | 🟡 |
| C-19 X7 | 금지 6칸을 config·전환 명령으로 주입 → **기동 거부** · 🔴 세션 토큰 없는 **#12** 주입 → 거부 | 🟡 엔진 런타임 선행 |
| C-20 X7 | 브로커 주문 호출 0건 · 🔴 advisory 런타임에서 `ExecPolicy` **쓰기 0건** · 🔴 `operatingMode` 쓰기가 **M5 게이트·위저드 커밋 경로 밖에 0건** | 🟡 |
| C-21 X7 | 수기 기록 UPDATE/DELETE 0회 · amend 1회 = `REVERSAL`+`RESTATEMENT` **2행** · 🔴 두 행의 `symbol`·`side` 동일 · 🔴 체인 상한(2회) 초과 시 거부 | 🟡(픽스처 대조분은 🟢) |
| C-22 X7 | 정정 픽스처에서 **필터 없는 단순 SUM** 이 최종 수량·금액과 일치 | 🟢 |
| C-23 X7 | 파생 계산 경로가 `advice`·`external_holding` 을 참조하지 않음 + 캘린더 매퍼에 `AdviceItem` 타입 차단 | 🟡 |
| C-24 X7 | 🔴 `costSource == estimated` **배지 존재** · 🔴 `priceRangeSourceDate` **라벨 존재** | 🟡 |
| C-25 X7 | `S7-10` 골든에 **금액 리터럴 0건**(bp 만) + `S7-1` **13항목 불변** | 🔵 |
| C-26 X7 | 「냉각 중 신규 기록 → 커밋 거부 → 단계 5 복귀」 · 「커밋 직전 미체결 발견 → 단계 4 복귀」 · 🔴 `NO_ACTION` 픽스처에서 `A-1`·`A-2` 가 렌더되고(`openCount == 0` + `hasSuppressedNotice == true`) **이행 갭 분모(`issued`)에 계상되지 않는지** · 🔴 커밋이 회수한 안내가 `REVOKED`·`HANDOVER_CLOSED` 이고 예산·분모에서 빠지는지 | 🟡 |
| C-27 X7 | `advice_viewer_4.json` 으로 **`A-1`·`A-2` 2라우트만** 렌더 → 🔴 검사는 「**종목 코드 · 주(株) 단위 수량 · 원(₩) 단위 가격**」 **세 패턴 0건**(비율 %·건수는 허용 — 정규식으로 고정, 허용 목록을 넓히지 않는다) + `phoneOnlyLabel` 존재 | 🟡 |
| C-28 X7 | `simInternal × advisory` 발행 명령을 `live × advisory` 런타임이 소비 → ⓐ `ledger.sqlite` 쓰기 0건 ⓑ 상태가 `rejected` 가 아니라 **`staleContext`** · 🔴 **뷰모델·화면 계층에서 `CommandContext` 를 생성하는 코드 0건** | 🟡(정적 스캔분은 🟢) |
| C-29 X7 | 소급 amend 픽스처에서 `trade_date` 기준 재계산 후 `equity_snapshot` 시계열이 **정확히 정정분만큼** 다르고 대응 `ledger_repair` 행이 **정확히 1개** | 🟡 |
| C-30 P | `aftertax_ladder_1.json` 렌더 → ⓐ `ui_*` 위젯트리에 `cagrPct`·`endMult` 등 **double 값 필드 참조 0건** ⓑ 숫자 리터럴 0건 ⓒ 본문 갈래가 **정확히 1개** ⓓ `steps` 층 수를 코드로 고정하지 않음 · 🆕 계약 면 ⓖ 사전 층 순서·빠짐 ⓗ 정본 갈래 «세금 전 = 파킹 과세 뒤»·반사실 내림 ⓘ 층 내림 순서·필드 짝·같은 «세금 전» ⓙ **골든 사본 대조**(`test/contracts/support/golden/aftertax_full_S7.json`) ⓚ `valueText` = 대조 값 반올림(01 §15-1 · 코드에 숫자 없음) | 🟡(계약 면 10 통과·ui 스캔 1 skip) |
| C-31 P | ⓐ 한 위젯트리에서 서로 다른 `basis` 의 `SleeveWeight` 가 같은 합계·같은 목록에 들어가는지 ⓑ `ui_*` 에서 **A 와 POT 를 더하는 산술** — `realized_alloc_S7` 픽스처 | 🟡 |
| C-32 G-89 | `ui_*` 소스에 월 납입 금액으로 읽힐 숫자 리터럴(`100000`·`90000`·`97000`·`124000`·`100_000`)과 `'10만'`·`'9.7만'` 문자열 → 실패. 🔴 **`labels.dart` 도 예외 아님** · 🔵 `fixtures/`·명세 산문은 대상 아님 | 🟡(정적 스캔) |
| C-33 v1.1 | 내비게이션 계약(01 §4-4) — ① 픽스처의 모든 `aaq://` 링크가 `AppRoutes.all` 패턴 하나와 일치 ② 링크 꼴 문자열이 링크 키 밖에 숨지 않는다 ③ 라우트 목록 건강(중복 0 · M5·X 소유 10종) ④ 일치 규칙(파라미터는 비지 않고 쿼리·조각 거부) ⑤⑥ 동작 링크(v1.3). 🆕 **v1.5(01 §15-3)** ③ `hasLength(43)` + `contains(AppRoutes.journalRebalance)` · ④ +4 예시(`aaq://journal/rebalance/re_1` 일치 · 빈 파라미터·`?x=1` 거부 · `aaq://journal/timeline` 불변) · 🆕 ⑦ **선언 순서 = 첫 일치**(각 패턴의 표본이 `all` 선언 순서로 처음 일치하는 패턴 = 그 자신 · 고정 세그먼트가 파라미터보다 먼저 — 셸 디스패치 순서) · `_linkKeys` 무변경(`journal_timeline_link` 는 `LinkAction` 이라 안쪽 `deep_link` 로 덮인다) · 🆕 **v1.6(01 §15-4)** ③ `hasLength(45)` + `contains` 2(`ledgerExecutionGapMonth`·`rebalanceHistory`) · ④ +4 예시(`aaq://ledger/execution-gap/2026-08` 일치 · `…/execution-gap/` 거부 · `…/execution-gap/2026-08?x=1` 거부 · `aaq://rebalance/history` 일치) · ⑦ 은 새 패턴을 자동 포함 · ①② 가 새 링크(`…/execution-gap/2026-08` 3건 · `x2/resume-report` 1건)를 검사 · `_linkKeys` 무변경 — `test/contracts/c33_navigation_links_test.dart` | 🟢 |
| C-40 🆕 v1.5 | 회차↔일지 링크 정합(01 §15-3 · §8 미결 49) — ① 버튼(`journal_timeline_link`)·행 링크(`detail_deep_link`) 꼬리 == 그 행 `event_id` ② 버튼 글자는 비어 있지 않고 링크·회차 id 를 담지 않는다 ③ scope 회차의 버튼 N == `journal_30` 에서 그 회차에 묶인 행 수 ④ scope 글자는 id·`kindLabel`·`tradeDate` 를 그대로 쓰지 않는다 ⑤ 버튼 있는 행·없는 행(부재 표본)이 둘 다 있다 ⑥ advisory 거울 = band 와 같은 회차 · 버튼 글자만 다르다 ⑦ 모르는 회차의 봉투 문장 ≠ `journal_empty` 문장 · `S7-6a` 빈 봉투도 문장이 있다 ⑧ `ui_journal/lib` 코드에 `orderIntentIds`·`RebalanceRepository` 0(🆕 2026-10-21 — `RebalanceRepository` 만 H6 대상(C-44 ⑫ 와 같은 집합: `holdings_overview.dart`·`holding_detail.dart`·`holdings_allocation.dart` + `lib/src/holdings/**`)을 뺀다 · 01 §17-8 `H6-3` 의 `watchNext()` · `orderIntentIds` 는 H6 대상까지 어디서나 0 · 대상 집합 == C-44 ⑫ 맞대기 · 양성·음성 자기 검사) ⑨ scope 씨앗 기간이 그 회차 행 전부를 덮고 프리셋이 아니다 ⑩ `journal_30` 의 회차 id ⊆ scope 픽스처 id — 🔴 숫자를 코드에 적지 않고 두 픽스처를 맞댄다 · `test/contracts/c40_rebalance_journal_link_test.dart` · 🆕 v1.6 ① 대상에 `m7M7RebalanceSim` 추가 | 🟢(⑧ 은 소스 스캔) |
| C-41 🆕 v1.6 | R12 표시 계약 — v1.6 픽스처·DTO 불변식(01 §15-4 · 🔴 숫자 리터럴을 코드에 적지 않고 픽스처끼리 맞댄다) — ① 미리보기 결과 = 초안·차단 중 정확히 하나 · 버튼은 차단에만 · 차단 표본 = 버튼 있음 1 + 없음 1(행 0 = 없음) ② 초안 `asOf` == 봉투 · 머리 글자·고지 «미리보기입니다» · `ordersEmptyText` ⇔ 빈 초안 · 지정가 짝 · 계좌 별칭 · 초안 표본 `before` 밴드 밖 ≥ 1 · 빈 초안 표본 `before` 전부 안 ③ 다음 회차 — 카운트다운·예정 없음이 섞이지 않고 행 `asOf` == 봉투 · `previewRoute == AppRoutes.rebalancePreview` ④ 회차 — `thresholds` ⇔ `thresholdRegistered` · 행 `asOf` == 봉투(관측 시각) · 모든 `SleeveWeight.label` 에 `%` · `basis` ACCOUNTING · `modeLabel` ⇔ `mode != LIVE` · `sectionLabel` = SIM 단독 봉투 행 0 에만 ⑤ `rebalance_6` 거래일 엄격 내림차순 · band 행 == `detail_band` 행(JSON) ⑥ 연간 — 세후 = 사다리 사본(원천 하나) · `counterfactual ⇒ afterTax` · 섹션 route ∉ {`reportAfterTax`, `ledgerExecutionGap`·그 달 라우트} · `yearLabel` 비지 않음 ∧ `year` 를 품는다 · offwindow = 비 OPEN ∧ `as_of` 연도보다 앞 ⑦ `referenceOnlyLabel` ⇔ `isReferenceOnly`(예외 고정 목록 = `m7_withdrawal_pension_penalty`) ⑧ 이행 갭 결과 — 갈래 하나 · `emptyKind` ⇔ `emptyLabel` · noData/notApplicable · `asOf` == `report.asOf` · 게이지 [0,1] · 가림 = 게이지 null ∧ 글자에 숫자 0 ∧ «?» · int 9 ↔ «n건» 문장 ⑨ `_1`·mixed 제안 줄 null · R12 픽스처 금지어 0 ⑩ 월간 ⑧ 링크 == `ledgerExecutionGapMonth` 의 `:yyyyMm` 을 그 행 달로 바꾼 값 · 가림·미생성 달 = 링크 없음 — `test/contracts/c41_r12_view_models_test.dart`(10 테스트) | 🟢 |
| C-42 🆕 v1.6 | R12 화면 소스 스캔(01 §15-4) — 역할 표(헬퍼 `test/contracts/support/r12_targets.dart` · `S7-6a`·`6b`·`6c`·`7`·`10` 의 공개 파일 + 내부 폴더 + `analytics_providers.dart` 의 «R12 절»(첫 `// ── 🆕 R12` 표식 줄부터 파일 끝)) · 소스는 `stripComments` 뒤(문자열 리터럴은 남김) · 대상 0 = 공허 통과(역할별 대상 N파일·절 줄 수 출력) — ① 역할 표·대상 수 ② 공통 원값 0(비중·밴드·임계·`mode`·`kind`·`emptyKind`·`code`·`TradeDate` 재포맷) ③ 역할별 원값 0 ③' 패턴 분해로 읽는 원값 0 ④ 호출 역할 표(창구마다 부르는 역할 하나 · providers R12 절 = 읽기 창구 5종 허용 목록) ⑤ 분기·셸·포맷 낱말 0(`operatingMode`·`kIsWeb`·`DateTime.now`·`Scaffold`·`NumberFormat` 등) ⑥ 소수부 ≠ 0 소수 리터럴·`%` 문자열 0(구 C-30 ⓕ 의 R12 몫) ⑦ `S7-10` 금액 타입·금액 꼴 문자열 0(구 C-25 ⑤ 의 `S7-10` 몫) ⑧ `S7-6a·6b·6c` 슬리브 산술 0(구 C-31 ⓓ 의 R12 몫) ⑨ 문자열 가공·정렬·거르기 0 ⑩ 가드 — R12 전용 이름은 역할 대상과 providers R12 절에만(`ui_analytics/lib` · 늘 실행) ⑪ 자체 검증(양성은 걸리고 음성은 통과 · 걸린 조항 번호 출력) ⑫ 세후 유출 경로 가드 — `ui_analytics` 밖 `ui_*`·`apps` lib 에 `afterTax`·`afterTaxCounterfactual`·`cagrPct`·`endMult` 참조 0(K25 · 늘 실행) ⑬ providers R12 절 — 읽기 창구 인자 0 · `previewRebalance` 0 · 표식 위 R12 이름 0 — `test/contracts/c42_r12_screen_scan_test.dart`(14 테스트) | 🟢(소스 스캔 · 카드 전에는 역할 대상 0 = 공허 통과 · ⑩⑫ 는 지금도 실대상) |
| C-43 🆕 v1.7 | `J-4` 사후 blind 리뷰(01 §16 · `test/contracts/c43_blind_review_test.dart` · 17 테스트) — **A 픽스처·DTO 불변식** ① 문항 3~5 · id 유일 · 선택지 ≥ 2 · 한 문항 안 점수 유일 ② 허용 키 목록(카드·문항·선택지·결과 · 본문 = C-34 ⑧ 5키) ③ 채점 전 = `result` 부재 · 금액(만·억·천 원·`₩` 포함)·백분율·«손익/수익/평가액» 0 ④ before == 큐 행 0 · 공개 카드 − `result`·`as_of` == 짝 ⑤ 큐 행 수 == 배지 «리뷰 대기 n건» · 빈 큐 = 문장 ⑥ 채점 전·결과 밖 `aaq://` 0 · 결과 링크 = 그 카드의 `J-2` ⑦ 저널·문맥·이탈 정합(큐 행마다 일지 행 필수 · `J-3R` 짝 = `d_mf_0002` 1표본) + K3 ⓓ(`JOURNAL_MISSING` 대상 큐 0) ⑧ 결과 금액 0(K6) · 미청산 ≠ 청산 ⑨ `BlindReviewScore` 견본 왕복 / **B 화면 소스 스캔**(대상 = `ui_journal/lib/src/blind_review.dart` + `lib/src/blind_review/**` · 대상 0 = 공허 통과) ⑩ 가드(`ui_*/lib` · 셸 제외) ⑪ 호출 금지 목록 · 큐 인자 0 ⑫ 점수 = 맵 값 자리(`] =`·`:`)에만 · 별칭·`+=` 0 ⑬ id 표시(보간·`Text(`·연결·`toString`)·코드 분기·`.result!` 0 ⑭ 분기·셸·포맷·시계 직접(`DateTime.timestamp`·`clock.now()` 포함)·`journal_draft` 0 ⑮ 가공·정렬·거르기·행 고르기(`.last`·`.sublist` 류)·`maxLines`·말줄임·`trim` 0 ⑯ 소수 리터럴·`%`·`원` 문자열 0 ⑰ 자체 검증 | 🟢 A · 🟡 B(대상 = `R3-Bob-J4` 뒤 실효 · ⑩ 은 지금도 실대상) |
| C-44 🆕 v1.8 | 보유현황 `H6-1`~`H6-3`(01 §17 · `test/contracts/c44_holdings_test.dart` · 20 테스트) — **A 픽스처·DTO 불변식** ① 허용 키 목록 + DTO 필드 집합 == 목록 ② 손익 격리(기본 표본 손익 키 0 · 펼침 글자 · «열람 기록» 0) ③ 표시 문자열·가림(INTEGRITY «숨김» == `journal_masked_integrity` · 🆕 INTEGRITY·L-3 가림판 보유 행 트랜치 칩 `[]` + 정상판엔 칩(✅ K29) · 시스템 밖 수량 그대로 · RECON 대상만 «?» — 대상 = 상세 RECON 표본의 보유·그 슬리브 배분 행(픽스처끼리) · 대상 글자만 «?» 떼면 정상판) ④ 정체성·일치(holding_id 유일 · B·POT 같은 종목 · holdings_6 == 펼침판 · 상세 == 목록 · 링크) ⑤ 카드 구조(카탈로그 순 · POT = A 카드 맨 끝) ⑥ 배분(순서 · 회계 기준 · 밴드 행 = B 만 · 게이지 ⇔ 밴드 행 · 게이지 실측 위치 ↔ band_state · 가림 기하 · 카드 머리 == 배분 행) ⑦ 손절선 ⑧ 이력 ⑨ 미결 82 보유 몫 ⑩ 트랜치·배지 ⑪ 링크 — **B 화면 소스 스캔**(대상 = `ui_journal` `holdings_overview.dart`·`holding_detail.dart`·`holdings_allocation.dart` + `lib/src/holdings/**` · 지금 0파일 = 공허 통과) ⑫ 가드 ⑬ 호출 금지 ⑭ 구독 인자 ⑮ 원값·키 ⑯ 기하 산술 ⑰ 가공·거르기 ⑱ 분기 낱말 ⑲ 숫자 리터럴 ⑳ 자체 검증 | 🟢 |
| C-46 🆕 v1.12 | X7 안내·기록·실사 `A-1`~`A-4`·「지난 안내」·`L-3`(01 §21 · `test/contracts/c46_advice_x7_test.dart` · 27 테스트) — **A 픽스처·DTO 불변식** ① 허용 키 + DTO 필드 집합 == 목록 · 손익 키 0 ② 링크 = 그 행 id · DETAIL 0 ③ 뷰어 actions [] · 집행 정보 0 · 스냅샷·상세 링크 양성 ④ 만료 확인 카드(≤3 · 맨 앞 · [RECORD, SKIP] · 밖의 미분류 만료 = 인박스 0 · 요약 링크 ⇔ 넘침) ⑤ 엔진 정렬 ⑥ 사유(예산 2종만 · 네 벌 같음) ⑦ 수량 채우기 ⑧ 재제출 짝 ⑨ 거부 사전 18 ⑩ `L-3` 세션·결과·앵커링 키 0 ⑪ 초안 키 그 달/그 계좌 ⑫ 거래일 선택지 = min~max − 휴장 ⑬ 배치 결측 = RECORD 만 ⑭ 닫힌 사유 짝 ⑮ `L-3` 링크 꼴(전 픽스처) — **B 화면 소스 스캔**(대상 = `ui_journal` `advice_inbox`·`advice_history`·`advice_detail` + `lib/src/advice/**` · 폼 3 `journal_draft/{manual_fill_form, advice_skip_form, self_report_form}` · 지금 0파일 = 공허 통과) ⑯ 가드 ⑰ 원값·키(🔵 읽기 화면 `.adviceId` 예외 = **인자 자리**만 — `findById(…)`·`fillsOfAdvice(…)`·`deferAdviceConfirm(…)`·`…Provider(…)` family 첫 인자 · 🆕 검증 반영 = 객체 패턴 구조 분해 · 열거 `.name` · 🆕 2026-10-28 R5d 선행 = `.필드` 앞보기 예외 `ManualFillPrefillFields.quantity` 하나(02 §3-8 · K19 상수 · 앞 앵커 `(?<![\w$])` — 끝 글자가 같은 다른 이름·`$` 앞붙이는 그대로 잡음 · 음성 +1 · 양성 +2 · 폼·읽기 화면 공용 — 폼 한정 좁히기 = 설계 01 §8 미결 134 후보)) ⑱ 분기(🆕 점 축약 `== .expired` — 이름 = 열거 `.values`) ⑲ 파싱·산술(🆕 `BigInt.parse`·`floor`·`ceil`·`truncate`·`~/`) ⑳ 와이어·맥락 ㉑ 안전 상태 직접 ㉒ 링크 조립 ㉓ 초안 수명(🆕 갈래 판정 — else·`!=`·블록 밖 clear 를 잡는다) ㉔ `dispose` 안 `ref`(🆕 본문 = 메서드 끝까지) ㉕ 묶기(🆕 `firstWhere` 류) ㉖ 명령 범위 ㉗ 자체 검증(🆕 양성 +29 · 음성 +12) | 🟢 A · 🟡 B(대상 = R5b~R5e 뒤 실효 · ⑯ 은 지금도 실대상) |
| C-47 🆕 v1.12 | 원장 차이·정정 `L-1`·`L-2` · 운영 리듬 · 알림 등급(01 §21 · `test/contracts/c47_ledger_ops_test.dart` · 9 테스트) — ① 허용 키(LedgerDiffRow 19 · LedgerRepairRow 18 · `resume_line`) ② 라벨(보드와 같은 쌍 글자 · 후보 칩 = 코드 순서 · 관측 «주문을 막지 않습니다») ③ 조치 링크 ④ 정정 이력(계단 · 이후 정정됨 · 소속 · 결정 링크 · 방향 색 · 원인 · 재계산 고지) ⑤ 리듬(홈 upcoming == 표 앞 ≤3 · NOT_LOADED) ⑥ 알림 등급 test-only 표(P0 7 · P1 12 · P2 5 == `AlertCodes.values` · 정본 `06_시스템설계/04_안전장치.md` §5-3 · 전 픽스처 walk 28 객체 · 미결 114) ⑦ `L-1`·`L-2` 화면 스캔(대상 0 = 공허 통과 · 🆕 검증 반영 = `firstWhere` 류 · 객체 패턴 · 라우트 상수(예외 `AppRoutes.ledgerRepairs`) · 플랫폼 분기 `kIsWeb`·`defaultTargetPlatform`·`Platform.`) ⑧ 자체 검증(🆕 양성 +9 · 음성 +3) ⑨ R13 진입 링크 표본 · 🆕 v1.13(01 §23 · 11 테스트) ⑩ 대조 보드(칸 키 6 · 칸 5 = 쌍 전수 · 해당 없음 = info · `blocked` = canonBroker·canonSelfReport 만 · `headline` 늘 · 전부 일치 표본 · 쌍 글자 사전 한 벌 · 🆕 검증 반영 — 칸 레벨 표본째 고정(diff BLOCKED·WATCH·OK·OK·INFO · ok OK×4·INFO) · 점검 칸 `state_code` OK ⇔ `level` OK(K3 ⓒ) · `ledger_diffs_4` 대응(K6)) ⑪ R13b 홈 참고 표본(억제 + `dueSoonLabel` · 배분 `noticeText` 두 갈래 · 🆕 `dueTodayCount` > 0 ∧ ≤ `openCount` · `headline` 표본 글자 고정 ≠ zero(K8)) | 🟢 |

🆕 **v1.5 주(2026-10-07)** — 이 표는 G3 착수 때의 C-1~C-32 에 **C-33·C-40 두 행만** 더했다(C-34~C-39 는 01 §7 표가 정본이고 이 표에 아직 없다).
경계 검사 `tool/check_boundaries.sh`(계약 v1.5): 🆕 **[5b]** 화면 패키지(`ui_*` 중 `ui_shell` 제외) `lib` 코드 줄의 **파라미터 라우트 상수** 참조 0(목록은 `app_links.dart` 에서 두 줄 선언까지 이어 읽어 뽑는다 · 견본 `rebalanceEvent`·`journalRebalance` 가 뽑히지 않으면 실패) + `AppLinkSchemes` 참조 0 · 🆕 **[5c]** 화면 패키지 `test` 의 Dart 코드 줄 링크 리터럴 0. 셸을 빼는 까닭 = 라우트 테이블·파서가 그 상수를 쓰는 유일한 자리(남는 구멍 = 01 §8 미결 91).
실측(2026-10-07): `domain_contracts` `dart test` **273 통과 · 30 skip · 0 실패**(`dbbd3ae` 기준 262 → +11) · 경계 검사 통과.

🆕 **v1.6 주(2026-10-08 · 01 §15-4 · ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`)** — 이 표에 **C-41·C-42 두 행**을 더했다(C-34~C-39 는 여전히 01 §7 표가 정본). 기존 검사 개정: 스모크 리터럴 `'1.6.0'` · C-1·C-8 등록부 +9 · 새 타입 폐포(`RebalancePreviewResult`·`ExecutionGapResult`) · `_knownUncovered` 에서 `RebalancePreview` 삭제 · C-15 «봉투 `meta.mode` 전량 LIVE» **무변경**(신설 9벌 봉투 전부 LIVE · SIM 은 행 `mode`) · C-25 ① 대상 4 → 7벌 · ② 경로 `['report']['price_gap_label']` · ③ «cant·wont non-null·서로 다름 · mixed null» · C-31 ⓐ 대상 = `SleeveWeight` 를 싣는 R12 픽스처 전부 · C-33 ③④(위 행) · C-40 ① +`m7M7RebalanceSim`. 🔴 **skip 30 유지** — C-25 ⑤ · C-30 ⓕ · C-31 ⓓ 는 지우지 않고 제목만 «(R12 밖)»으로 좁혔다(R12 몫 = C-42 ⑦ · ③⑥⑫ · ⑧ — 지우면 홈 블록 4·S12·S7-1 몫이 대체 검사도 남은 할 일 표시도 없이 사라진다).
경계 검사 `tool/check_boundaries.sh`(계약 v1.6): [5b] 추출 견본에 `ledgerExecutionGapMonth` 추가(견본 = `rebalanceEvent`·`journalRebalance`·`ledgerExecutionGapMonth` — 두 줄로 접힌 선언도 추출되는지 확인).
ui 테스트(계약 변경 고지 · ui lib 0 · 골든 PNG 0): `ui_analytics/test/planner_fakes.dart` `previewRebalance` 반환형 1줄 · `goal_path_view_test.dart` T79-14 완화(R11b 8경로 각 1회 + 내부 폴더 export 0 · 정확한 집합 = R12d 새 테스트) · `performance_explore_gate_test.dart` G13 주석만.
실측(2026-10-08 · `edde72b` 위): `domain_contracts` `dart test` **297 통과 · 30 skip · 0 실패**(273 → +24 = C-42 14 · C-41 10) · `dart analyze --fatal-infos`·`dart format` 0 · 경계 검사 통과 · `ui_analytics` `flutter test` 304 · `ui_journal` 207(불변) · 골든 PNG 변화 0 · 변이(scratchpad 일회성 · 하나씩 넣고 원복) **39/39 잡힘 · 음성 3/3 통과**.

🆕 **v1.7 주(2026-10-20 · 01 §16 · ⬜ 로컬 커밋 — PR 대기)** — 이 표에 **C-43 한 행**을 더했다(C-34~C-39 는 여전히 01 §7 표가 정본). 기존 검사 개정: 스모크 `'1.7.0'` · C-8 `_knownUncovered` 에서 `BlindReviewCard`·`BlindReviewQuestion` 삭제(사유 상수 `_reasonJournalDetail` 은 `StopLineNormalized` 몫으로 문장 정정) · C-5 주석 «세 사전» · C-16 `domainByKind` +`blindReviewScore`(`blind_review_reject`) · 🆕 C-16 «J-4 blind 리뷰 접수증 — 6행 5상태 · 거부 사유 2종». 경계 검사·C-33(라우트 45)·C-34·C-35 무변경.
ui 테스트 0파일(가짜는 전부 `extends UnimplementedJournalRepository`) · ui lib 0 · 골든 PNG 0.
실측(2026-10-20 · `m2/v17-blind-review`): `domain_contracts` `dart test` **315 통과 · 30 skip · 0 실패**(297 → +18 = C-43 17 · C-16 1) · `dart analyze --fatal-infos`(13패키지)·`dart format` 0 · 경계 검사 통과 · `ui_journal` `flutter test` 207 · `ui_analytics` 514 · 골든 PNG 변화 0 · 변이(scratchpad 일회성 · 하나씩 넣고 원복) **28/28 잡힘 · 음성 2/2 통과**(설계서 확정판 V1~V25 + V12b·V12c·V15b). 🆕 검증 2회 반영(2026-10-20 · `c0e3316` — C-43 ③⑦⑫⑬⑭⑮ 우회 길 막기 · 테스트 수 불변 315/30/0 · ⑰ 양성 38 · 음성 22) 뒤 재실행 = **35/35 잡힘**(+ V26~V32) · **음성 4/4 통과** · 한계 1(⑦ⓑ `J-3R` 짝 1표본 — 기록만) · V17 = 스모크 · C-1 · C-15 ④.

🆕 **v1.8 주(2026-10-21 · 01 §17 · ⬜ 로컬 커밋 — PR 대기)** — 이 표에 **C-44 한 행**을 더했다(C-34~C-39 는 여전히 01 §7 표가 정본). 기존 검사 개정: 스모크 `'1.8.0'` · C-1·C-8 등록부 +18 · C-8 `_knownUncovered` 에서 `StopLineNormalized` 삭제 + 사유 상수 `_reasonJournalDetail` 삭제(쓰는 곳 0) · C-4 리터럴 `sleeve_label` + 비율 nullable(`!`) · C-5 `_fixtureCodeFields` +`tier_code` → `stop_tier` · C-31 ⓐⓑ 대상 = `realized_alloc_S7` + 배분 VM 7 + 카드 머리 · ⓓ skip 제목 · C-33 ③ 48 + `contains` 3 · ④ 예시 +5 · C-23 주석 1줄. C-6·C-15·C-34·C-35·C-43·경계 검사 무변경.
ui 테스트 0파일 · ui lib 0 · 골든 PNG 0(`HoldingRow`·`HoldingsRepository`·`SleeveAllocationRow`·`ExternalHoldingRow` 의 계약 밖 소비자 0).
실측(2026-10-21 · `m2/v18-holdings`): `domain_contracts` `dart test` **335 통과 · 30 skip · 0 실패**(315 → +20 = C-44 20) · `dart analyze --fatal-infos`·`dart format` 0 · 경계 검사 통과 · 변이(scratchpad 일회성 · 하나씩 넣고 원복) ~~**48/48 잡힘 · 음성 2/2 통과**~~ 🆕 앱 PR 검증 반영(커밋 (4) · C-44 ③⑥⑧⑪⑮⑯⑳ 보강) 뒤 **59/59 잡힘 · 음성 5/5 통과** · 🆕 K29(커밋 (5)) V60 «가림판 B 행 트랜치 되돌림» 잡힘(C-44 ③ 만) · 테스트 수 335 불변(③ 안 단언)(설계서 §4-3 V1~V59 · 음성 = 대상 파일의 허용 꼴 7줄(공개·내부 두 자리) · 펼침판 `as_of` 만 바꿈 · 행 `as_of` 라벨만 바꿈 · `(c.maxWidth - 32) * g.actualNormalized`·if-case 링크).

🆕 **v1.12 주(2026-10-22 · 01 §21 · ⬜ 로컬 커밋 — PR 대기)** — 이 표에 **C-46·C-47 두 행**을 더했다(C-34~C-39 는 여전히 01 §7 표가 정본). 기존 검사 개정: 스모크 `'1.12.0'` · C-1·C-8 등록부 +16(신설 15 + `self_report_1` 이동 · 미매핑 3 → 2) · C-8 `_knownUncovered` 에서 `LedgerRepairRow`·`CashEstimateNotice` 삭제(이제 덮인다) · `SelfReportLine` 사유 → 명령 인자 · 제출 DTO 3 + `AdviceDeferConfirm` 등재 · C-5 `_fixtureCodeFields` +`retry_code` → `advice_retry` · 사전 +`advice_retry`·`manual_fill_prefill` · C-15 `batch_d` CHECK +`DEFER_ADVICE_CONFIRM`(주석 ALTER 목록 함께) · C-16 `domainByKind` +`adviceDeferConfirm` · C-18 ⑥ skip 제목(«C-46 ⑰⑱ 가 맡는다») · C-28 ⑥ 9종 · ⑨ skip 제목(«C-46 ⑳») · C-33 ③ 52 + `contains` 4 · ④ 예시 +10 · ⑦ 표본 +3 · C-35 ② 영구 제외 7종 · C-43 `_forbiddenCalls` +`recordLedgerEvent`·`deferAdviceConfirm` · README «봉투 형제 키 표» −3(`trust`·`resume_headline`·`resume_route`). C-7(새 이름 쓰기 동사 접두 0 — G57)·C-6·C-21·C-22·C-24·C-26·C-27·C-29·C-34·C-44·C-45 무변경(C-26·C-18·C-27 은 `advice_12` 순서 변경에 무영향 — W12 실측).
ui 테스트 = 골든 도우미 2파일(`ui_journal` `extraFixture` +1 · `ui_shell` `golden_support.dart` 신설 — 테스트 수 불변) · ui lib 0 · 골든 PNG 0(계약 밖 소비자 = `CommandReceipt(` 2곳 · nullable named 추가라 무수정).
실측(2026-10-22 · `m2/v112-r5r13`): `domain_contracts` `dart test` **386 통과 · 30 skip · 0 실패**(350 → +36 = C-46 27 · C-47 9) · `dart analyze --fatal-infos`·`dart format` 0 · 변이(scratchpad 일회성 · 하나씩 넣고 원복) **V1~V55 55/55 잡힘 · 음성 5/5 통과**.

🆕 **v1.13 주(2026-10-26 · 01 §23 · ⬜ 로컬 커밋 — PR 대기)** — 새 행 0(C-47 확장 ⑩⑪ · 위 C-47 행). 기존 검사 개정: 스모크 `'1.13.0'` · C-1·C-8 등록부 +2 바인딩 · extras +3(m8 `advice_summary`) · C-47 ⑤ `_opsHomes` +1 · C-6 홈 목록 +1 · 🆕 검증 반영(2026-10-26) — C-1 +1 테스트 «형제 키는 extras 로 묶이거나 사유와 함께 남는다»(등록부 `envelopeKeys` · `unboundSiblingKeys` 13키 사유 · `unboundSiblingsOf` · K9) · C-47 ⑩⑪ 단언 보강(위 행). ui 테스트 0 · ui lib 0 · 골든 PNG 0(`DiagnosticCell`·`DiagnosticsVm` 의 계약 밖 소비자 0).
실측(2026-10-26 · `m2/r13b-recon-ok`): `domain_contracts` `dart test` **389 통과 · 30 skip · 0 실패**(386 → +2 = C-47 ⑩⑪ → 🆕 검증 반영 +1 = C-1 형제 키) · `dart analyze --fatal-infos` 13/13 · `dart format` 0 · 변이(scratchpad 일회성) ~~25꼴 — 24 잡힘 · 의도된 통과 1(K9 extras 를 뺀 대조)~~ 🆕 검증 반영 뒤 52꼴(기존 45 + 새 7) — 51 잡힘 · 생존 1(V16 `total_pnl` — C-6 접미 = 이 창 밖) · V23C 이제 잡힘(C-1 형제 키) · V22a·V22b = 컴파일 단계에서 잡힘 · 🔵 설계 메모 V16(`total_pnl`)은 통과(C-6 = 사전 키만) → V16b(`pnl`) 잡힘.

**추가 검사 1건(번호 없음 · M2-3 소유)** — 🔴 `lib/l10n/labels.dart` 의 키·문자열 **전수**와 재개 리포트 템플릿에서 «램프»가 접두(«운영 램프»/«초기 진입») 없이 단독으로 쓰인 항목 **0건**. C-5 는 `labels.dart` 를 예외로 두므로 C-5 로는 잡히지 않는다. 🔴 C-5 전역 경고로 만들지 않는다(개발 쪽 경보 피로).

🔴 **골든 스냅샷 폭발 회피** — 라우트 전수 검사는 **축당 1조합**(C-17 = SIM×auto · C-18 = live×advisory), 접두 합성 순서만 대표 라우트 3개, C-27 은 2라우트.

---

## §10. 착수 순서 · 열린 물음

### 10-1. 영역별 첫 커밋 체크리스트

| 영역 | 첫 커밋에 반드시 들어가는 것 |
|---|---|
| **A** | `primitives/` 5파일 + `enums/` 13파일 **전량**. 🔴 `@JsonValue` 를 **모든 값에** 붙인다(자동 변환 0건) |
| **B** | `dto/common.dart` 먼저(다른 영역이 기다린다) → journal → holdings → safety → ledger → calendar → resume |
| **C** | `dto/performance.dart`(`AfterTaxLadder` 포함) → rebalance → plan → advice → ledger_trust → handover → settings → ops |
| **D** | 리포지토리 15파일(선언만) → `commands/command_api.dart` → `command_context.dart` → `payloads.dart` → `settings_actions.dart` |
| **E** | `labels/` 10파일 + `contract_version.dart` **버전 상향 보류**(🔴 01 문서가 «확정 v1.0» 이 되는 커밋에서만 `1.0.0`) + `ddl/` 6+1파일 |
| **F** | 봉투 로더 → 코어 11 픽스처 → C-8·C-9·C-14·C-15·C-22 (🟢 5건) → 나머지는 스켈레톤 + `skip` 사유 주석 |

### 10-2. 🔴 열린 물음 — 임의 확정 금지 (구현 중 부딪히면 멈추고 보고한다)

1. ✅ **해소(계약 v1.9.0 · 2026-10-21 · 설계 13 §8 R19 E9-6 · R20)** — `command_inbox.state` = `command_ack.state` = `CommandState` − `REQUESTED` 8값 · `command_queue` 에는 state 칸 없음 · C-15 등식 검사. ~~**`CommandState.noOperator` 의 DDL 자리** — `command_inbox.state`·`command_ack.state` CHECK 어디에도 `NO_OPERATOR` 가 없다. G-30 은 「`command_inbox` 의 state 집합 = `command_queue` 의 state 집합」을 요구하는데 `command_ack.state` CHECK 는 여전히 4값이다. 셋 중 어디까지 넓히는가?~~
2. ✅ **해소(계약 v1.9.0 · R19 E9-2 · R20 Q1)** — 3값 + 파일별 CHECK(`ddl/*` `-- @sim` 태그 · `LedgerFile` · `ledgerDdlFor`) · `DEFAULT 'SIM'` 삭제 · `mode` 칸은 결정 사슬 9표(+ 이름만 같은 `resume_run`)에만 · 나머지는 `PRAGMA application_id` 파일 식별 · `journal_30` je_0030(`SIM_INTERNAL`)은 SIM 파일에 저장된다(값 무변경). ~~**`RunMode` 2값 vs 3값** — 배치 A·B 의 `CHECK (mode IN ('SIM','LIVE'))` 와 §9-5 ④ 의 3값 권고가 문서에 함께 남아 있다. 3값으로 넓히면 배치 A·B 도 재작성 대상이 된다(§9-1 은 «확정 전에는 DDL 을 고치지 않는다»).~~
   - 🔴 **G3 통합 실측(2026-09-08) — 이 물음은 «장차»가 아니라 «이미» 충돌한다.** 두 가지를 정정한다.
     - ⓐ 「픽스처 `meta.mode` 는 `"LIVE"` 다」는 **봉투에 한해서만** 참이다(77 픽스처 전량 `LIVE`). 그러나 **행 필드**는 다르다 — `fixtures/journal_30.json` 의 `je_0030` 이 `"mode": "SIM_INTERNAL"` 을 싣는다(X6 모의투자 갈래 시연 행). 봉투만 보고 «정합» 이라고 판정하면 안 된다.
     - ⓑ 더 중요한 것: **`'SIM'` 은 `RunMode` 의 `@JsonValue` 가 아니다.** `RunMode` 는 `SIM_INTERNAL`·`SIM_BROKER`·`LIVE` 3값이라 2값 CHECK 와 겹치는 값은 **`LIVE` 하나뿐**이다. 즉 2값 CHECK 는 「SIM 계열을 좁게 받는다」가 아니라 **SIM 계열 행을 하나도 표현하지 못한다**. 「2값 유지 = 보수적 선택」이 아니라는 뜻이다.
   - 🔴 그럼에도 **이번 통합에서 DDL·열거형·픽스처 중 무엇도 고치지 않았다** — §9-1·§9-5 ④ 가 «확정 전 DDL 불변» 이고 `m2-8_naming` I-3 이 ⏸ 이며, 위 ⓑ 는 어느 쪽으로 닫을지의 **근거**이지 결정이 아니다. 확정이 오면 `ddl/batch_a`·`batch_b`·`batch_f` + `fixtures/journal_30.json` + C-15 를 **한 커밋에서** 움직인다.
3. ✅ **해소(계약 v1.9.0 · R19 E9-4)** — `CORPORATE_ACTION` 으로 통합 · `CORP_ACTION` 은 옛 기록용 상수만. ~~**`CORPORATE_ACTION` vs `CORP_ACTION`** — 중복 후보(§8-6). 통합 전까지 **둘 다 상수로 두되** 픽스처에는 `CORPORATE_ACTION` 만 쓴다(X2 계열이 먼저 등재됐다).~~
4. ✅ **해소(계약 v1.9.0 · R19 E9-5)** — 컬럼 유지 + 이름만 승격 · `dry_run = 1` ⇔ `ExecPolicy.dryRun` · `RunMode` 와 독립(batch_a 주석 · `ExecPolicy` doc). ~~**`order_intents.dry_run` ↔ `ExecPolicy` 이중 정본**(§8-7) — `ExecPolicy` 를 열거형으로 만들되 `dry_run` 컬럼은 **그대로 둔다**(§9-5 ①). 파생 규칙 명문화는 M2-1 창.~~
5. ✅ **해소(2026-10-22 · 발주자 · 권고대로 · 설계 10 N-07) = 표를 만든다** — v1 필수 · `H-01` 전 플랫폼 · 컬럼 = 01 §6-4 · ~~⬜ DDL 실물·주석 = 다음 계약 PR~~ 🆕 v1.12(⬜ 로컬 커밋 — PR 대기) 주석 3곳 ✅(`ddl/batch_d_supabase.sql` · `ddl/README.md` ⑤ · `ops_repository.dart`) · 같은 표가 `watchRhythm` 전체 목록 열·`resume_line` 을 싣는다(K29 · K44). ~~**`rm_ops_summary` 표 존폐** — 만들거나, 홈 블록 5·7 을 폰 전용으로 명시하거나 **둘 중 하나**다. 정하지 않은 상태가 가장 나쁘다(뷰어가 값을 지어낸다).~~
6. **`ReasonOption` ↔ `J-3` `rule_cited` 통합**(§8-20 · D19) — 🔴 **선행 미결**. 닫히기 전에는 `A-4`·`M5-12` 폼 계약이 확정되지 않는다.
7. ~~**`FeatureFlags.operatingMode` 의 `@Default`**(§8-19) — 주면 «기본이 자동»이 조용한 전제가 되고, 안 주면 `rm_config_view` 미갱신 상태에서 뷰어가 죽는다.~~ ✅ **닫힘(2026-10-22 · 01 §8-19)** — 기본값 없음(required) · `rm_config_view.operating_mode` NOT NULL(엔진 M4-1) · 뷰어가 못 읽으면 `incompatible`.
8. **`AlertItem.ack` 의 쓰기 경로**(§8-10) — `alertAck` 명령은 생겼으나 **뷰어 허용 여부**는 여전히 열려 있다(X7 이 대신 답하지 않는다).
9. **픽스처 티커** — `069500` 은 **KOSPI200** ETF 라 P0S 의 슬리브 A(KOSDAQ 지수 ETF)와 맞지 않는다. 실전 종목 확정 전까지 **문법 예시**이며, 화면은 티커를 슬리브의 정의로 읽지 않는다(A/B/C 라벨은 `SleeveCatalogEntry.label`).
10. **`SettingsActionId` 신설 2종의 이름** — `settingsContributionUpdate`(G-45 · 🔴 «운영 등급») · `calendarReconnect`(G-64). `m2-8_naming.md` 가 권고 이름으로 확정했으나 **발주자 몫 표시(⏸)** 가 붙어 있다. 🆕 v1.23(01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17) — `settingsContributionUpdate` ⏸ → ✅(05 `S13` 운영 등급 · 제출 경로 `runContributionUpdate` · `m2-8_naming.md` A-13 · §AB).
