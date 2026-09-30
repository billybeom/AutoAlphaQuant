# M2-8 이름 확정표 — «이름 확정 1회 배치»

> **무엇**: `11_앱설계/01_M2_도메인계약_초안.md` 이 ⚠️(이름 미확정 · M2-8 확정 대기)로 남긴 타입·필드·열거값 **전량**을 확정한 표다.
> **왜 필요한가**: ⚠️ 가 붙은 화면은 전부 «픽스처 고정 모드»에 묶인다. 개폐 시점이 없으면 v1 화면 다수가 **영구히 픽스처 상태**로 남는다(06 M2-8).
> **누가 쓰나**: G3 병렬 구현자 6명. 🔴 **구현자가 즉석에서 새 이름을 만들지 않는다.** 이 표에 없는 이름이 필요하면 **멈추고 보고한다**(이름을 지어내는 것보다 낫다).
>
> **확정 규칙 4조**
> 1. 01 의 기존 명명 관례를 따른다 — **열거값 camelCase** · **뷰모델 `Vm` 접미** · **표시 문자열 `Text` 접미** · **라벨 `Label` 접미**.
> 2. **X7 확정 식별자 목록(③)의 이름은 그대로 쓴다** — 「편집자 9명의 정본. 이후 바꾸지 않는다」.
> 3. 두 문서가 다른 이름을 쓰면 **01 §10 이 이긴다**.
> 4. 결정이 «발주자 몫»으로 문서에 명시된 것은 **권고 이름으로 확정하되 ⏸ 를 붙인다** — ⏸ 는 «이름은 쓰되 그 이름이 걸린 기능을 구현하지 않는다»는 뜻이다.
>
> **상태 표기**: ✅ 확정(즉시 구현) · ⏸ 권고 확정(이름만 확정 · 기능은 발주자·실측 대기) · ⛔ 만들지 않음.
> **총 104행**(A 17 · B 5 · C 12 · D 10 · E 9 · F 16 · G 13 · H 10 · I 6 · J 6). 이 중 3행(E-6·E-7·J-1)은 다른 행으로의 상호참조이므로 **확정 이름은 101건**이다.

---

## A. 열거형 · 열거값 — 17행

| # | 문서 위치 | 임시 이름 / 상태 | **확정 이름** | 근거 |
|---|---|---|---|---|
| A-1 | 01 §2-2 · §8-8 | `FillVisibility` 값 «⚠️ 초안» | ✅ `FillVisibility { settled, pendingBatch, awaitingConfirm }` → `SETTLED`·`PENDING_BATCH`·`AWAITING_CONFIRM` | 01 §2-2 원문 3값 그대로. 「체결→표시 as-of 계약」의 3상태이고 §8-8 이 요구한 것은 **값의 확정**이지 새 값이 아니다 |
| A-2 | 01 §1-3 · §8-8 | `AsOf.staleReasonCode` 값 «⚠️ 초안» | ⏸ **최소 카탈로그 4값** `ENGINE_DOWN`·`PUSH_LAG`·`BATCH_MISSING`·`CLOCK_SKEW` | 문서 전체를 통틀어 `staleReasonCode` 의 값이 한 번도 열거되지 않았다. 🔴 **자유 문자열로 두면 화면이 코드→문구 매핑을 만든다**(C-5 위반의 입구). 4값은 §1-3·§2-11 `staleLabel` 용례에서 역산한 것이며 **엔진(M1) 확정 대기** |
| A-3 | 01 §2-1 «값·필드명은 M2-8 확정 전까지만 유동» | `RunMode` | ✅ `RunMode { simInternal, simBroker, live }` → `SIM_INTERNAL`·`SIM_BROKER`·`LIVE` | 01 §9-1 표 · §9-5 ④. 적대 검증 완료로 초안 지위가 해제됐다 |
| A-4 | 01 §9-5 ① «§2-1 열거형 추가(⚠️ M2-8)» | `ExecPolicy` | ✅ `ExecPolicy { dryRun, execute }` → `DRY_RUN`·`EXECUTE` | §9-5 ① 이 이미 값을 확정했다. 🔴 **3값으로 넓히지 않는다**(강등이 발주자 선택을 덮어쓴다 — §10-1) |
| A-5 | 01 §2-1 «X7 신규 열거형 13종 — ⚠️ 전부 M2-8 확정 대기» | X7 13종 | ✅ **X7 ③ 3-1 표 그대로**: `OperatingMode`·`AdviceStatus`·`AdviceKind`·`AdviceSkipReason`·`AdviceActionId`·`FillOrigin`·`FillKind`·`CostSource`·`LedgerTrustGrade`·`HoldingScope`·`HandoverPath`·`CredentialUse`·`LedgerEventKind`(⏸) | 확정 규칙 2 — 「이후 바꾸지 않는다」 |
| A-6 | 01 §2-1 G-08 «⚠️ M2-8 확정 대기 — `'NO_ACTION'`» | `AdviceKind.noAction` | ✅ `noAction` → `NO_ACTION` | `advice.kind` CHECK 가 이미 `'NO_ACTION'` 을 싣는다. 열거값 camelCase 관례 |
| A-7 | 01 §2-4 «⚠️ 이름·필드는 M2-8 확정 대기» | `TaxLadderBranch` | ✅ `TaxLadderBranch { specPotTaxFree, cfPotTaxableComp26, cfPotTaxableComp38, cfPotTaxableFlat }` | 01 §2-4 원문 그대로. `AfterTaxStep.stepCode` 6값(`PRETAX`·`AFTER_POT`·`AFTER_POT_C`·`WD_5P5`·`WD_16P5`·`HONEST`)도 원문 그대로 확정 |
| A-8 | 01 §3-7 «⚠️ M2-8 확정 대기» | `SeasonalEntryGateState` | ✅ `SeasonalEntryGateState { octPassed, deferredToNov, enteredInNov, deferredToDec, forcedEntryDec }` | 01 §3-7 원문. 🔴 상태 5 : 코드 3 의 비대칭을 화면이 분기로 메우지 않는다 |
| A-9 | 01 §3-7 «⚠️ 엔진 코드명 M2-3 확정 대기» | 계절 게이트 **통과** 사유 코드 | ⏸ `F1_ENTRY_OK` | 01 §3-7 표의 후보 그대로. 🔴 **엔진 `03_알고리즘` 에 통과 케이스 이벤트가 아직 없다** — 등재 전에는 픽스처 봉투의 `ENTRY_GATE_OCT` 를 **고치지 않는다**(정상 통과가 «보류·지연»으로 오표기되는 것을 막는다) |
| A-10 | 01 §4-2 «⚠️ 이름 M2-8 확정 대기»(N-2) | `SelfReportPurpose` | ✅ `SelfReportPurpose { periodicAudit, simOpening }` → `PERIODIC_AUDIT`·`SIM_OPENING` | 01 §4-2 원문. 🔴 **기본값을 두지 않는다** — 목적이 없으면 엔진이 세 규약(세션 밖 제출 거부·`lines` 전 종목 필수·`ledger_diff` 개시)을 어디에 걸지 모른다 |
| A-11 | 01 §4-2 G-26 «⚠️ M2-8 신설 후보» | `CommandState.noOperator` | ✅ `noOperator` → `NO_OPERATOR` | 01 §10-8 ⓑ. 🔴 **「요청됨」이 «껐다»로 읽히는 것을 막는 유일한 값**이다. ⚠️ DDL 자리는 열린 물음(`contracts_inventory.md` §10-2 ①) |
| A-12 | 01 §4-3 G-01 «⚠️ M2-8» | `SettingsActionId.onboardingOperatingModeSelect` | ✅ 그대로 | 01 §4-3 원문. 🔴 05 §7 표에 없는 것이 **설계상 정상**이다(온보딩 `O-00b` 전용) |
| A-13 | 01 §2-6 G-45 «⚠️ 열거값 이름 M2-8 확정 대기(후보 `settingsContributionUpdate`)» | 월 납입 운영값 변경 동작 | ⏸ `SettingsActionId.settingsContributionUpdate` | 01 §2-6 후보 그대로. 🔴 **«운영 등급»이며 `settingsGeneralUpdate` 로 태우지 않는다** — 일반 등급이면 «즉시 반영»이 되어 「다음 납입 주기부터 적용」이 깨지고 생체 재인증도 건너뛴다. ⏸ 사유 = 05 §1 등급표에 «운영 등급» 행이 신설되어야 성립 |
| A-14 | 01 §4-3 «⚠️ 미등재 — 캘린더 재연결(G-64)» | 캘린더 재연결 동작 | ⏸ `SettingsActionId.calendarReconnect` | `calendarSyncNow`·`calendarRebackfill` 과 같은 `calendar*` 접두 관례. ⏸ 사유 = X4 채택 자체가 미결(§8-5 OAuth 동의화면 7일 만료 스모크) |
| A-15 | 01 §2-1 · X7 ③ 3-1 | `LedgerEventKind` | ⏸ `LedgerEventKind { withdrawal, distribution, corporateAction, taxWithheld }` | 🔴 **결정 ㊲ 채택 시에만 신설.** 지금은 `enums/ledger.dart` 에 **주석으로만** 남기고 코드로 만들지 않는다 |
| A-16 | 01 §8-30 «`deferAvailable` 의 자리 — 필드 vs `actions` 흡수» | 만료 확인 「내일 다시」 | ✅ **필드 유지** `AdviceItem.deferAvailable`(bool) · `AdviceActionId` 는 `{record, skip, detail}` **3값 그대로** | `AdviceActionId` 에 흡수하면 「버튼의 유일한 근거는 `actions`」(A8)와 「미룸 횟수는 엔진 판정」(G-86)이 한 목록에서 섞인다. 🔴 어느 쪽이든 **저장 정본은 `advice_transition(cause_code='DEFER_CONFIRM')` 행의 존재 자체**다 |
| A-17 | 01 §9-5 ③ «`SafetyState` hold 사유 코드(⚠️ M2-8)» | 키 검증 전 보류 사유 | ✅ 문자열 상수 `LIVE_AWAITING_KEYS`(`labels/flag_ids.dart` 등재) | §9-5 ③ 원문 그대로. 🔴 **`operatingMode == autoTrade` 에서만 배치를 중단**한다(C9) — advisory 는 키가 없는 것이 정상 상태다 |

---

## B. 열거값의 JSON·DDL 표기 — 기계 변환이 **틀리는** 5행

> 🔴 이 5행이 이 표에서 가장 사고가 잦은 자리다. `@JsonValue` 로 못 박지 않으면 **런타임 CHECK 위반**으로 터지고 C-15 가 그것을 빌드 시점으로 끌어온다.

| # | 문서 위치 | Dart 이름 | **확정 JSON·DDL 표기** | 근거 |
|---|---|---|---|---|
| B-1 | 01 §1-2 · §6-1 CHECK | `SleeveId.satellite` | ✅ `'SAT'`(❌ `SATELLITE` 아님) | `decision_log.sleeve`·`advice.sleeve` CHECK 가 `'SAT'` 다 |
| B-2 | 01 §2-10 | `StepRequirement.required_` | ✅ `'REQUIRED'`(❌ `REQUIRED_` 아님) | 트레일링 언더스코어는 **Dart 예약어 회피**이며 표기에 새지 않는다 |
| B-3 | 01 §4-2 · §6-6 배치 D 추가분 | `CommandKind.manualFillRecord`·`manualFillAmend`·`manualFillVoid`·`adviceSkip` | ✅ `'RECORD_MANUAL_FILL'`·`'AMEND_MANUAL_FILL'`·`'VOID_MANUAL_FILL'`·`'SKIP_ADVICE'` | 🔴 **Dart 이름과 DB 값의 어순이 뒤집혀 있다.** `command_queue.kind` CHECK 가 정본이고 Dart 이름은 §4-2 열거형이 정본이다 — 둘 다 문서에 있고 둘 다 바꾸지 않는다 |
| B-4 | 01 §4-2 · §6-6 | `CommandKind.selfReportBalance`·`alertAck`·`killChecklistConfirm` | ✅ `'SELF_REPORT_BALANCE'`·`'ALERT_ACK'`·`'KILL_CHECKLIST_CONFIRM'` | 이 3종은 기계 변환과 일치한다(그래서 B-3 와 섞이면 더 위험하다) |
| B-5 | 01 §2-9 | `RepairRoute.x1Emergency` | ✅ `'X1_EMERGENCY'` | 숫자를 낀 camelCase 의 표기 규약을 여기서 한 번 못 박는다(`x1Emergency` → `X1_EMERGENCY`, `X_1_EMERGENCY` 아님) |

---

## C. 기존 DTO 의 신설 필드 — 12행

| # | 문서 위치 | 임시 이름 | **확정 이름·타입** | 근거 |
|---|---|---|---|---|
| C-1 | 01 §2-11 «⚠️ 이름 M2-8 확정 대기»(N-1) | 전환 냉각 배너 | ✅ `AdviceInboxSummary.handoverCoolingActive`(R bool) · `handoverCoolingLabel`(? String) | `Label` 접미 관례. 🔴 화면이 위저드 상태·`handover_session` 을 직접 읽어 배너를 만들지 않는다 |
| C-2 | 01 §2-1 «⚠️ 하위호환 기본값 부여 여부는 M2-8(§8-19)» | `FeatureFlags.operatingMode` 의 `@Default` | ⏸ **기본값을 주지 않는다**(`required OperatingMode operatingMode`) | 🔴 «기본이 자동»이 조용한 전제가 되는 쪽이, 뷰어가 명시적으로 죽는 쪽보다 나쁘다 — «온보딩 미완»은 «자동 매매»가 아니다(G-02). ⏸ 사유 = `rm_config_view.operating_mode` 컬럼이 **같은 창에서** 들어가야 성립(§8-14 와 한 사안) |
| C-3 | 01 §2-6 «⚠️ `FundingStep` 필드는 상세 설계 확정» | 납입 조달 단계 | ✅ `FundingStep { int order; SleeveId sourceSleeve; String? symbol; String? symbolLabel; int quantity; @D Decimal expectedProceeds; String ruleCited; String label }` | 01 §2-6 «최소 축: 순서·매도 대상 슬리브/티커·수량·예상 조달액·근거 규칙 `03 §5-5b`» + 라벨 규약(§1-5) |
| C-4 | 01 §2-6 «⚠️ `basisText` 확장 vs 신설 = M2-8 택일» | `GoalPathVm` 백테스트 근거 줄 | ✅ **신설** `GoalPathVm.backtestBasisText`(기존 `basisText` 는 그대로 둔다) | 확장하면 한 필드가 두 뜻을 갖는다. 🆕 **v1.4 — 역할 고정 · 동시 금지 폐기(01 §14-10 · §O O-9)**: `basisText` = 판정 근거 줄 · `backtestBasisText` = 가정 카드 1줄(«백테스트 기준 실행») · `startingCapitalAssumptionText` = 가정 카드 2줄 — 03 §14 가정 카드가 **두 줄**을 요구하므로 v1.0 의 «화면이 두 필드를 동시에 그리지 않는다» 조문(과 그것을 검사하려던 까닭)은 **폐기**됐다. 두 필드를 둔다는 이름 결정은 그대로다 |
| C-5 | 01 §2-6 «🆕 요청 후보 — 확정 아님, M2-8» | 초기 진입 램프 진행 | ✅ `EntryRampProgress { List<EntryRampSleeveState> sleeves }` · `EntryRampSleeveState { SleeveId sleeve; String stateCode; String stepLabel }` · `stateCode ∈ {MONTHLY_SPLIT, COMPLETED_IMMEDIATELY, AWAITING_SEASONAL_GATE}` | 01 §2-6 «최소 축: `sleeve`·`stateCode`·`stepLabel`». 🔴 **«n/6» 단일 게이지가 아니라 슬리브별 상태 목록**이다 — A·C 에 n/6 을 그리면 거짓 진행률 |
| C-6 | 01 §2-6 · §2-10 | `RampLevel`(OpsRamp) | ✅ `enum RampLevel { l0, l1, l2, l3, l4, l5 }` → `'L0'`…`'L5'` | 03_실행 §9 자금 투입 단계 · `ramp_state` 단일 행. 🔴 **EntryRamp 와 다른 것**이며 하나의 위젯으로 합치지 않는다 |
| C-7 | 01 §2-6 «P 회차 요청 필드» | `SleeveAllocationRow` | ✅ `{ SleeveId sleeve; AllocationBasis basis; SleeveId? parentSleeve; String? engineColumnNote; String deployedText; String parkingText; double deployedRatio; double parkingRatio; String? parkingNoteText; String trancheStateText; String deployedPctText; String parkingPctText }` | 01 §2-6 원문 그대로. 🔴 `deployedRatio`·`parkingRatio` **둘 다 준다**(화면이 `1 − x` 를 계산하지 않게) · 두 비율은 **막대 기하 전용** · 홈 재사용은 **`*PctText` 별도 필드**(금액 문자열이 홈으로 새면 04 §2-6 금지) |
| C-8 | 01 §2-6 «🆕 요청 후보 — 채택 여부는 06 §6 미결 13» | `rejectedCandidates`(기각 등록부) | ⛔ **만들지 않는다** | 🔴 핸드북 원고 HB-3 확정 전에는 **구현 대상이 아니다**. 이름만 예약하고 필드를 만들지 않는다 |
| C-9 | 01 §2-11 «⚠️ M2-8 확정 대기» | `AdviceRepository.fillsOfAdvice` | ✅ `Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId)` | G-23. 🔴 `JournalRepository.fillChain(entryId)` 와 **다른 것**이다 — 02 §3-7 의 `fillChain(adviceId)` 인용은 **오기**이며 01 이 이긴다 |
| C-10 | 01 §4-1 «⚠️ 소속 리포지토리는 M2-8 택일» | `watchContributionSetting()` | ✅ `ConfigRepository.watchContributionSetting()`(별도 리포지토리를 만들지 않는다) | 소비처(`S05`·`S7-4`·`H-02`)가 **같은 값 하나**를 읽는 것이 요구이고, 창구가 둘이면 화면이 두 경로를 동시에 쓴다. 🆕 **v1.4 — 4곳 → 3곳**: `S7-9` 는 `ConfigRepository` 를 읽지 않는다(03 §17-17 이 이긴다 · 가정 카드 2줄 = 엔진 문장 `GoalPathVm.startingCapitalAssumptionText` · 01 §14-10 · C-39 ⑨) |
| C-11 | 01 §8-29 «분할 집행 leg 표현» | 3거래일 분할 진도 | ⏸ **별도 뷰모델** `SplitExecutionLeg { int legIndex; int legTotal; int todayQuantity; int carriedQuantity; String stepLabel }` — `TradeJournalEntry` 에 **붙이지 않는다** | 01 §2-2 가 「이 타입에 아직 없다」를 조문화했고, 붙이면 전 픽스처·골든이 다시 깨진다. ⏸ 사유 = 엔진 `M1-9b` 분할 집행 이식과 **같은 창**. 🔴 확정 전 화면은 「n일차」·「이월 n주」를 **만들지 않는다** |
| C-12 | 01 §8-32 · 04 §12 미결 20 | 온보딩 `O-04` «가상 초기금 1칸» 위젯 소유 | ⏸ **M5 가 삽입한다**(M8 온보딩은 슬롯만 비운다) | `L-3` 실사 폼은 M5(안전) 소유이고, 온보딩이 같은 폼을 두 벌 만들면 「금액 1칸」의 검증 규칙이 두 곳에 생긴다. ⏸ 사유 = 04 §12 미결 20 과 **한 항목**이며 한쪽만 닫으면 두 문서가 갈린다 |

---

## D. 이름만 있던 값 객체 · 안전 계열 — 10행

> 전부 01 §2-6 «이름만 있고 필드는 상세 설계에서 확정» 표. **이름은 이미 문서에 있으므로 확정은 «필드의 최소 축»이다.**

| # | 타입 | **확정 최소 축** | 배정 | 근거 |
|---|---|---|---|---|
| D-1 | `KillSwitchView` | ✅ `{ bool active; String stateLabel; DateTime? activatedAt; String? activatedByDeviceLabel; String? checklistStateLabel; String? releaseEtaText }` | B `dto/safety.dart` | 🔒 **M5 만 렌더**(결정 6). 🔴 «해제» 필드·버튼을 만들지 않는다 |
| D-2 | `AckState` | ✅ `{ bool acked; DateTime? ackedAt; String stateLabel; int escalationStep }` | B `dto/safety.dart` | ⚠️ **쓰기 경로는 §8-10 미결** — `alertAck` 명령의 뷰어 허용 여부가 열려 있다 |
| D-3 | `GaugeProgress` | ✅ `{ String code; String label; double normalized; String valueText }` | B `dto/safety.dart` | 🔴 `normalized` 는 **게이지 폭 전용**이고 표시는 `valueText`(§2-11 `complianceRateNormalized` 와 같은 형식) |
| D-4 | `ResumeCounts` | ✅ `{ int executed; int expired; int superseded; int blocked; int unrecoverable }` | B `dto/resume.dart` | `resume_run.counts` JSON 키 그대로(§6-3) |
| D-5 | `ResumeItem` | ✅ `{ String workId; String oneLine; String plannedLine; String reevaluatedLine; String verdictCode; String verdictLabel }` | B `dto/resume.dart` | 01 §2-7 «항목별 계획 vs 재판정 vs 사유» |
| D-6 | `DataGapRow` | ✅ `{ String gapId; String dataset; TradeDate from; TradeDate to; bool recoverable; String reasonCode; String label }` | B `dto/resume.dart` | `data_gap` 표 컬럼 1:1 + `label` |
| D-7 | `MomentumPanel` | ✅ `{ double? momentum121; int? rsRank; bool? templatePassed; List<ReasonChip> failedConditions; String label }` | B `dto/holdings.dart` | `holding_signal_daily` 컬럼 1:1. 🔵 v2.31 에서 **거의 항상 null** |
| D-8 | `CalendarSyncStatus` | ✅ `{ String modeCode; TradeDate? lastOkDate; String statusCode; String statusLabel; int quarantinedCount; int userDeletedCount; String? actionDeepLink }` | B `dto/calendar.dart` | `calendar_sync_status` 컬럼 + G-34 «사용자 삭제 n건»의 **별도 수치** |
| D-9 | `HandbookIndex` · `HandbookPage` | ✅ `HandbookIndex { List<HandbookEntry> entries; String configHash }` · `HandbookEntry { String anchor; String title; int order }` · `HandbookPage { String anchor; String title; List<HandbookBlock> blocks; String configHash }` · `HandbookBlock { String kind; String text; String? deepLink }` | C `dto/handbook.dart` | `ReasonChip.detailDeepLink`(`handbook://…`)의 **도착지**이며 **C-13 `config_hash` 메타를 싣는 주체**다 |
| D-10 | M6 «UNKNOWN 단계» | ✅ `UnknownResolutionStep { String stepId; int order; String title; String whyLine; GateState state; String stateLabel; String? deepLink }` | B `dto/journal.dart` | 02 §8-1. `OnboardingStep`·`HandoverStep` 과 같은 «단계» 형태를 따른다(같은 모양을 세 번째로 만드는 것이 새 모양을 만드는 것보다 낫다) |

---

## E. M6 미정의 9건 — 9행 (02 §8-1 표)

| # | 임시 이름 | **확정 이름·최소 축** | 배정 |
|---|---|---|---|
| E-1 | `DecisionSnapshot` | ✅ 그대로 · `{ DecisionRef ref; TradeDate tradeDate; String kindLabel; List<ReasonChip> reasons; TriggerSnapshot trigger; String? ruleCited; String summary }` | B `dto/journal.dart` |
| E-2 | `ThresholdCompare` | ✅ 그대로 · `{ String metricKey; String metricLabel; String observedText; String thresholdText; bool passed; String verdictLabel }` — 🔴 **수치는 전부 엔진 포맷 문자열**(화면이 비교식을 만들지 않는다) | B `dto/journal.dart` |
| E-3 | `RejectTrace` | ✅ 그대로 · `{ String stageCode; String stageLabel; String reasonCode; String reasonLabel; DateTime occurredAt }` | B `dto/journal.dart` |
| E-4 | `JournalDraftFormSpec` | ✅ 그대로 · `{ List<ReasonOption> ruleCitedOptions; int rationaleMinChars; String noticeLine; AsOf asOf }` — 🔴 `ruleCited` 선택지는 **엔진 제공 목록**(자유 입력 금지) | B `dto/journal.dart` |
| E-5 | `BlindReviewCard` | ✅ 그대로 · `{ String decisionId; String promptText; List<BlindReviewQuestion> questions }` · `BlindReviewQuestion { String questionId; String text; List<ReasonOption> choices }` — 🔴 문항·선택지 문구도 엔진 | B `dto/journal.dart` |
| E-6 | UNKNOWN 단계 | → **D-10 `UnknownResolutionStep`** | B |
| E-7 | `SleeveAllocationRow` | → **C-7** | C `dto/rebalance.dart`(🔴 **M6 가 아니라 C 영역** — `SleeveWeight`·`AllocationBasis` 와 한 파일에 두어야 C-31 이 한 트리에서 검사된다) |
| E-8 | «손절선 정규값» | ✅ `StopLineNormalized { String tierCode; String tierLabel; @D Decimal? level; String levelText; bool isActive; String basisLabel }` — 🔴 `StopLine`(§2-3)의 **표시 정규화판**이며 `StopLine` 을 대체하지 않는다 | B `dto/holdings.dart` |
| E-9 | `LedgerRepairRow` | ✅ 그대로 · `{ String repairId; String diffId; String directionCode; String directionLabel; String originCode; String? decisionId; String evidenceHash; String? supersedes; TradeDate? recomputedFrom; DateTime appliedAt; String label }` — 🔴 `recomputedFrom` 이 C-29(소급 정정 시계열 재계산)의 표시 축이다 | B `dto/ledger.dart` |

---

## F. M7 뷰모델 · 플래너 — 16행

| # | 문서 위치 | 임시 이름 | **확정 이름·최소 축** | 근거 |
|---|---|---|---|---|
| F-1 | 01 §2-6 G-41 | `ReportArchiveVm` | ✅ `{ List<ReportArchiveRow> rows; String? emptyLabel; AsOf asOf }` · `ReportArchiveRow { String yyyyMm; String label; bool generated; String? reasonLabel; String modeLabel; String? route }` — 🔴 **수치 필드 0건** | `S7-1b` · `rm_report_archive`(수치 컬럼 없음) |
| F-2 | 01 §4-1 G-41·G-42 | `DisclosureGateVm` | ✅ `{ bool gateOpen; String headline; String viewCountText; String? frictionLine; String? route; AsOf asOf }` — 🔴 **`viewCountThisMonth` 숫자 필드를 두지 않는다**(화면이 「n회」를 조립하지 않게) | `S7-2G` · `rm_disclosure_view`(월 단위 카운트만 push) |
| F-3 | 01 §2-6 G-41 | `DrawdownContextVm` | ✅ `{ String periodLabel; String currentDdText; String maxDdText; String tuwText; double ddNormalized; String? referenceBandText; String? referenceBandCaveatText; AsOf asOf }` | 01 §2-6. 🔴 `referenceBandCaveatText` 가 **null 이면 줄을 그리지 않는다**(«최대낙폭은 하한»의 단서) |
| F-4 | 01 §2-6 G-41 · 03 §10 | `ContributionVm`(**슬리브 기여 분해**) | ✅ `{ String periodLabel; List<ContributionRow> rows; String? fxNoteText; String methodNoteText; AsOf asOf }` · `ContributionRow { SleeveId sleeve; String label; String contributionText; double normalized }` — 🔴 **종목 단위 행 없음** | 03 §10 `S7-3b`. 🔴 **`MonthlyContributionVm` 과 다른 타입**이며 이름을 공유하지 않는다 |
| F-5 | 01 §2-6 G-41 · §8-27 | `NextRebalanceVm` | ✅ `{ String? emptyLabel; String expectedDateText; String dDayText; RebalanceKind? expectedKind; String? kindLabel; String? previewRoute; String? noticeText }` — 🔴 **리포지토리 반환은 nullable 이 아니다** · `emptyLabel` 이 non-null 이면 **카운트다운 카드를 그리지 않고 이 문장만** 그린다 | 03 §11-c · N-4 |
| F-6 | 01 §2-6 G-41 | `AnnualReviewVm` | ✅ `{ String year; String windowStateCode; String windowStateLabel; List<AnnualReviewSection> sections; AsOf asOf }` · `AnnualReviewSection { String code; String title; List<String> lines; String? route }` — 🔴 **묶음이지 재집계가 아니다** · 화면이 `windowState` 를 «달»로 판정하지 않는다 | `S7-7` · 06 M1-20b(⬜ later — **이름은 지금 등재**) |
| F-7 | 01 §2-6 | `MonthlyReport` | ✅ `{ String yyyyMm; List<ReportItem> items(**13항목 고정 배열**); String goalLine; String disclosureViewCountText; AfterTaxLadder? afterTax; LedgerTrustBadge trust; String? backdateFootnote; AsOf asOf }` — 🔴 **단일 `afterTaxPct` 필드를 만들지 않는다** · 반사실 항목을 14번째로 늘리지 않는다(C-25) | 01 §2-6 · G-97 |
| F-8 | 01 §2-6 | `PerfDisclosure` | ✅ `{ String sampleSizeLine; String interstitialText; int viewCountThisMonth; String honestExpectationLine; String? drawdownCaveatLine }` — 🔴 **M7 화면 한정**. M8 온보딩·핸드북은 같은 문자열을 **각자의 뷰모델 필드**로 받는다(타입 의존을 건너오지 않는 것이 C-3 규약) | 01 §2-6 |
| F-9 | 01 §2-6 | `BenchmarkSeries` | ✅ `{ String label; List<PerfPoint> points; String compositionNote }`(KOSPI 50% + S&P500(KRW) 50%) | 01 §2-4 |
| F-10 | 01 §2-6 | `ExecutionQuality` | ✅ `{ String slippageText; String assumedSlippageText; String unfilledRateText; String summary }` — 🔴 실측 vs 가정치 비교 문장도 엔진 | 01 §2-5 |
| F-11 | 01 §2-6 | `SleeveAllocation`(`DepositPlan` 충당액) | ✅ `{ SleeveId sleeve; String label; @D Decimal amount; String amountText; String? accountAlias }` — 🔴 `SleeveAllocationRow`(C-7)와 **다른 타입**이다(전자는 플래너 충당액, 후자는 배분 현황 행) | 01 §2-6 |
| F-12 | 01 §2-6 | `CostEstimate` | ✅ `{ @D Decimal commission; @D Decimal tax; @D Decimal total; String totalText; CostSource source; String sourceLabel; String basisNote }` | 01 §2-6 · C18 |
| F-13 | 01 §2-6 | `WithdrawalPlan` | ✅ `{ String planId; DateTime computedAt; DateTime expiresAt; @D Decimal amount; List<OrderDraft> orderDrafts; CostEstimate costs; AfterTaxLadder? afterTax; String previewNotice; String configHash }` | `DepositPlan` 대칭 |
| F-14 | 01 §2-6 | `RebalancePreview` | ✅ `{ String planId; TradeDate plannedDate; List<SleeveWeight> before; List<SleeveWeight> after; List<OrderDraft> orderDrafts; CostEstimate costs; List<FundingStep>? fundingSteps; String previewNotice }` — 🔴 `DepositPlan` 과 **같은** `fundingSteps` | 01 §2-6 v2.32 |
| F-15 | 01 §2-6 · 🆕 §14-10 | `GoalPathVm` | ✅ 🆕 **v1.4 재설계** `{ String yyyyMm; String judgementText; String basisText; String? deviationText; String periodLabel; String plannedLabel; String actualLabel; List<PerfPoint> planned; List<PerfPoint> actual; List<PerfAxisTick> yTicks; List<PerfSegment> segments; String? chartUnavailableLabel; String backtestBasisText; String startingCapitalAssumptionText; String honestExpectationText; String honestExpectationWorstText; String disclaimerText; AsOf asOf }` — 🔴 구 `List<GoalPathPoint> points` 와 타입 **`GoalPathPoint` 는 폐기**(C-39 ⑧ · `seriesCode` 없음) · 필드 → 자리 대응표 = 01 §14-10 | 01 §2-6 + C-4(v1.4 역할 고정) · §O O-8·O-9 |
| F-16 | 01 §2-4 | `AfterTaxLadder`·`AfterTaxStep` | ✅ 01 §2-4 원문 그대로(⚠️ «이름·필드 M2-8» 해제) · 🔴 `isReferenceOnly` 는 **§8-18 확정 전 항상 true** | 01 §2-4 · §8-18 |

---

## G. M8 · M9 운영 · 설정 뷰모델 — 13행

> 01 §2-6 «M8·M9 뷰모델군 — **이름까지 잠정**이므로 04·05 의 필드명을 그대로 코드에 굳히지 않는다». 🔴 여기서 이름을 확정한다.

| # | 임시 이름 | **확정 이름·최소 축** | 근거 |
|---|---|---|---|
| G-1 | `ShellVm` | ✅ `{ String? runModePrefix; String? operatingModePrefix; List<ShellChip> bandChips; String? bandToneCode }` — 🔴 **띠는 하나**, 칩 2개. 접두 순서 «모의투자 · 투자 안내 · 제목» | 01 §10-1 · C-17·C-18 |
| G-2 | `OpsRhythmRow` | ✅ `{ String code; String title; String whenText; String? dDayText; String? route }` | 04 §4-7 `H-02` |
| G-3 | `WatchdogCheck` | ✅ `{ String slug; String label; String stateCode; String stateLabel; String lastPingText; String? graceText; String? route }` — 🔴 슬러그는 **2축 합성** `{sim\|live}-{auto\|advisory}-{체크명}` · 목록 길이·이름은 **서버가 준다** | 04 §7 `W-01` · §9-5 ⑦ · C20 |
| G-4 | `OpsDailySummary` | ✅ `{ AsOf asOf; String todayOrdersText; String todayErrorsText; String signalMatchText; String streakText; String discretionBudgetText; String nextRebalanceDDayText; List<OpsRhythmRow> upcoming }` — 🔴 **전부 엔진 완성 문자열 · 수치 필드 0건** | 01 §4-1 주석 그대로 · G-29 |
| G-5 | `SettingsHomeVm` | ✅ `{ List<SettingsCard> cards }` · `SettingsCard { String code; String title; String? statusLabel; UiLevel level; bool actionAvailable; String? route }` — 🔴 `actionAvailable == false` 는 «비활성»이 아니라 **카드 부재**로 그린다 | 05 §5-2 |
| G-6 | `CredentialListVm` | ✅ `{ List<CredentialCardVm> cards }` · `CredentialCardVm { String alias; String kind; String kindLabel; String healthCode; String healthLabel; CredentialUse usage; String usageLabel; String? expiresText }` — 🔴 `kind` 에 `KIS_RECONCILE` 추가(X7 ③ 3-2 · **05 §5-2 가 정본**) | 05 §5-2 |
| G-7 | `ConnectionsVm` | ✅ `{ List<ConnectionRow> rows; AsOf asOf }` · `ConnectionRow { String target; String label; String statusCode; String statusLabel; String lastOkText; bool actionAvailable; String? route }` | 05 `S07` · G-29 |
| G-8 | `DeviceAccessVm` | ✅ `{ List<DeviceRow> devices; String leaseHolderLabel; String leaseStateLabel; String? leaseEtaText; AsOf asOf }` · `DeviceRow { String deviceId; String label; String roleLabel; String statusLabel; String lastSeenText }` — 🔴 **리스는 읽기 전용** | 05 `S06` |
| G-9 | `BackupVm` | ✅ `{ String lastOkText; String statusCode; String statusLabel; String? sizeText; bool actionAvailable; String? route; AsOf asOf }` | 05 `S09` |
| G-10 | `DiagnosticsVm` | ✅ `{ List<DiagnosticCell> cells; String headline; AsOf asOf }` · `DiagnosticCell { LedgerPair pair; String label; bool applicable; String stateCode; String stateLabel }` — 🔴 **칸 수 5 고정은 엔진이 준다** · `applicable == false` 는 «점검 안 함» | 05 `S10` · §2-9 · C15 |
| G-11 | `MonthlyContributionVm` | ✅ `{ String amountText; String equivalentNoteText; String appliesFromText; String lastChangedText; String? pensionLimitNoteText; bool editable }` — 🔴 `ContributionSetting` 의 **1:1 투영** · `editable` 만 런타임 값(`SettingsActions` 주입 여부) · 🔴 **필드를 이어 붙여 문장을 만들지 않는다**(투영을 늘리는 것은 허용) | 01 §2-6 · §8-31 · N-S4-03 |
| G-12 | `OperatingModeView`·`OperatingModeOption` | ✅ 01 §2-11 원문 그대로 | 01 §2-11 |
| G-13 | `HandoverPlan`·`HandoverStep`·`AdoptionPreviewRow` | ✅ 01 §2-11 원문 그대로 (`adoptionId`·`disposition`·`dispositionLabel` 포함 — G-03) | 01 §2-11 |

---

## H. 명령 · 리포지토리 · 설정 동작 — 10행

| # | 문서 위치 | 임시 이름 | **확정** | 근거 |
|---|---|---|---|---|
| H-1 | 01 §2-6 «M2-8 최우선» | `JournalDraft` | ✅ `{ String decisionId; String rationaleBefore; String expectedOutcome; String ruleCited; String? note }` — 🔴 `ruleCited` 는 **엔진 제공 목록의 코드**(자유 입력 금지) | 01 §2-6 «최소 축» 그대로 |
| H-2 | 01 §2-6 | `BlindReviewScore` | ✅ `{ String decisionId; Map<String, int> answers }` — 문항 id → 점수. 🔴 문항·선택지 문구는 `BlindReviewCard`(E-5)가 준다 | 01 §2-6 |
| H-3 | 01 §2-6 · G-42 | `DisclosureViewEvent` | ✅ `{ String surfaceCode; DateTime viewedAt; int durationSec }` — 🔴 **집계 키 `yyyy_mm` 을 화면이 넣지 않는다**(엔진이 `viewedAt` 에서 파생) | 01 §2-6 |
| H-4 | 01 §2-11 · §8-20 | `SymbolOption`·`AccountOption`·`ReasonOption` | ✅ `SymbolOption { String symbol; String label; SleeveId sleeve }` · `AccountOption { String alias; String label }` · `ReasonOption { String code; String label; bool requiresNote }` | 01 §2-11 «폼 선택지 3형제» |
| H-5 | 01 §8-20 · D19 «🔴 선행 미결» | `ReasonOption` ↔ `J-3` `rule_cited` 통합 | ⏸ **통합한다** — `JournalDraftFormSpec.ruleCitedOptions` 의 타입도 `List<ReasonOption>` | 「사유를 고르는 목록이 두 벌이 되어 한쪽만 갱신되는 사고」를 막는 것이 미결의 이유다(06 §6 미결 15). ⏸ 사유 = **06 `X7-2` 착수 전에 발주자·엔진 확인**이 붙은 항목 |
| H-6 | 01 §8-21 | `CommandContext` 를 기존 5종에도 붙일지 | ⏸ **붙인다**(전 명령이 `required CommandContext context`) | 「어느 맥락에 적용할 명령인가」의 답이 명령 종류마다 다르면 소비 규칙이 두 벌이 된다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로 **배치 D 와 같은 창**이어야 성립 |
| H-7 | 01 §4-3 · §8-24 | 위저드 쓰기 3종 args 필드명 | ✅ `handoverAdoptionSet` = `{handover_session_id, symbol, disposition}` · `handoverExternalRegister` = `{handover_session_id, symbol, quantity, account_alias, action}` · `handoverCommit` = `{handover_session_id}` — 🔴 args 키는 **snake_case**(`Map<String,String>` 이므로 Dart 관례가 아니라 전송 규약을 따른다) | 01 §4-3 화이트리스트. 🔴 `handover_session_id` 는 세 동작 모두 **필수** |
| H-8 | 01 §4-1 G-29 «⚠️ 반환 타입 이름은 M2-8» | `OpsStatusRepository` 반환 6종 | ✅ G-3·G-7·G-8·G-9·G-10·F-6 의 이름 그대로 | 04 §1-2·05 §2 의 잠정명을 이 표가 확정한다 |
| H-9 | 06 §3-7 G-77 «⚠️ 이름은 M2-8 확정 대기» | M5·X1·X2·X5 라우트 이름 | ⏸ `m5/resume-report` · `m5/kill-switch` · `m5/ledger-repair-wizard` · `m5/advisory-start-gate`(`M5-10`) · `m5/handover-wizard`(`M5-11`) · `m5/manual-fill-amend`(`M5-12`) · `m5/self-audit-resolve`(`M5-13`) · `x1/device-transfer` · `x1/maintenance-window` | 🔴 `ActionResult.handoffRoute` 는 **이 목록에 있는 이름만** 반환하고 화면이 이름을 지어 쓰지 않는다. ⏸ 사유 = M5 화면 소유자(Claude) 확정 대기이며, 이름이 없으면 `C-17`·`C-18` 의 «전 라우트 전수»가 M5 를 통째로 빠뜨린 채 통과한다 |
| H-10 | 01 §7 · 06 M2-6 «⚠️ 번호 M2-6 확정» | 운영 파라미터 리터럴 탐지 테스트 번호 | ✅ **`C-32`** | 01 §7 표가 이미 C-32 행으로 실었고 C-30·C-31 이 P 회차로 소진됐다 |

---

## I. 엔진 config 키 · 스키마 축 — 6행

| # | 문서 위치 | 임시 이름 | **확정** | 근거 |
|---|---|---|---|---|
| I-1 | 01 §2-6 · §8-22 | 납입 주기 config 키 | ⏸ `contribution_day`(기본 = **매월 첫 거래일** · 당일 접수는 다음 달 적용) | 01 §2-6 후보 그대로. 🔴 **엔진 config 신설 키**이므로 06 §4 SPEC 개정 배치 계획 ④ 에 1행으로 등재되어야 값이 존재한다. ⏸ 사유 = 발주자가 자동이체 실행일에 맞추기를 원하면 **날짜만** 바뀐다 |
| I-2 | 01 §2-6 · §6-2 | 운영 파라미터 키 | ✅ `operating_param_log.param_key = 'monthly_contribution'`(화이트리스트 1값) | §6-2 주석 그대로. 🔴 `fx_overlay` 계열 키를 넣지 않는다 |
| I-3 | 01 §9-1 · §9-5 ④ | 로컬 `mode` CHECK 의 값 도메인 | ⏸ **3값 + 파일별 CHECK**(`ledger.sqlite` = `CHECK (mode = 'LIVE')` · `ledger_sim.sqlite` = `CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER'))`, 배치 F 판은 `= 'SIM_INTERNAL'` 로 좁힌다) | §9-5 ④ 권고(첫 거래 전이라 테이블 재생성 비용 0). ⏸ 사유 = 01 §9-1 이 «확정 전에는 DDL 을 고치지 않는다»를 명시했고, 넓히면 배치 A·B 가 재작성 대상이 된다 |
| I-4 | 01 §8-6 | `CORPORATE_ACTION` vs `CORP_ACTION` | ⏸ **`CORPORATE_ACTION` 으로 통합**(`CORP_ACTION` 은 상수로만 남기고 픽스처·신규 코드에 쓰지 않는다) | X2 계열이 먼저 등재됐고 `CalendarEventKind`·`LedgerEventKind` 도 `corporateAction` 을 쓴다. ⏸ 사유 = **마이그레이션 창 안에서만** 고칠 수 있다(06 M2-1 착수 전 정리 2건) |
| I-5 | 01 §8-7 · §9-5 ① | `mode` ↔ `order_intents.dry_run` 이중 정본 | ⏸ **`dry_run` 컬럼 유지 + `ExecPolicy` 로 이름만 승격**(폐지하지 않는다) | §9-5 ① 채택 계약. ⏸ 사유 = 파생 규칙 명문화가 M2-1 창 |
| I-6 | 01 §8-23 G-01 | `onboarding_choice.committed_at` 을 무엇이 채우는가 | ⏸ **`O-04` 완료가 채운다**(첫 배치 성공이 아니다) | 「선택 후 되돌리기」의 경계가 사용자가 보는 단계와 일치해야 한다. 첫 배치 성공을 기준으로 하면 배치가 실패하는 동안 선택이 무한히 열려 있다. ⏸ 사유 = 발주자 확인 |

---

## J. ⏸ 발주자 몫 — 권고 이름으로 확정하되 기능은 대기 — 6행

| # | 문서 위치 | 무엇 | **권고 확정** | 왜 ⏸ 인가 |
|---|---|---|---|---|
| J-1 | 01 §8-19 · §8-14 | `FeatureFlags.operatingMode` 하위호환 | → **C-2**(기본값 없음) | `rm_config_view.operating_mode` 컬럼이 같은 창에 들어가야 성립 |
| J-2 | 01 §8-28 G-43 | `live × dryRun` 관찰 기간 · 승격 확인 DTO | ⏸ `LiveDryRunObservationVm { int observedTradingDays; int requiredTradingDays; String progressText; bool promotionAvailable; String stateLabel }` · 관찰 거래일 수 = **잠정 2** | 🔴 관찰 일수는 **발주자 확정 대기**이며 엔진 config 신설 키다. 🔴 **승격에 새 화면·새 라우트를 만들지 않는다** — `S05` 엔진 상태 칩 + 기존 M5 게이트 다이얼로그(생체 1회) |
| J-3 | 01 §8-10 · C2 기각 | `ALERT_ACK` 의 뷰어 허용 | ⏸ **허용하지 않는다**(현행 `command_insert_viewer` 4종 화이트리스트 유지) | X7 이 대신 답하지 않는 미결이다. ack 가 2종으로 갈린 뒤에는 **효력이 0인 명령**이고, 48h 개시가 폰을 요구하는 것은 결함이 아니라 결정 6 의 계약이다 |
| J-4 | 01 §6-4 · 10 §3-2 | `rm_ops_summary` 표 존폐(홈 블록 5·7 소유) | ⏸ **표를 만든다**(홈을 전 플랫폼으로 유지) | 🔴 **정하지 않은 상태가 가장 나쁘다** — 뷰어가 값을 지어낸다. 대안(홈 블록 5·7 을 폰 전용으로 명시)도 유효하며 발주자 택일 |
| J-5 | 01 §8-5 | X4 캘린더 계열 전체 | ⏸ **이름·타입은 등재하되 구현하지 않는다** | OAuth 동의화면 «테스트» 상태 7일 만료가 사실이면 X4 계열 문안(§2-8 `chainHash`·이벤트↔원천 표 · `calendar_link.mode` · `calendar_sync_status.mode` · §9-2 캘린더 행)이 **통째로 사문화**되고 `canonCalendar` 축이 대조에서 빠진다 |
| J-6 | 01 §8-6 · X7 ㊲ | `LedgerEventKind`·`recordLedgerEvent`·`LedgerEventRecord` | ⏸ 이름 확정(A-15) · **코드 미생성** | 결정 ㊲ 채택 시에만 신설. 🔴 채택되지 않으면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 **현금 추정이 단조적으로 어긋나고 그 위에서 안내 수량이 계산된다** |

---

## K. 이 표가 닫지 **못한** 것 — 구현 중 부딪히면 멈추고 보고한다

1. **`CommandState.noOperator` 의 DDL 자리** — `command_inbox.state`·`command_ack.state` CHECK 어디에도 `NO_OPERATOR` 가 없다. G-30 은 「`command_inbox` state 집합 = `command_queue` state 집합」을 요구하는데 `command_ack.state` CHECK 는 여전히 4값이다. **세 표 중 어디까지 넓히는가**는 이름 문제가 아니라 스키마 결정이다.
2. **`AsOf.staleReasonCode` 의 값 목록**(A-2) — 문서 어디에도 열거가 없다. 권고 4값은 **역산**이며 엔진(M1) 확정이 필요하다.
3. **자동 매매 알림 10종의 개별 코드 이름** — 04 §5-1c 가 «카탈로그로 나열»한다고만 되어 있고 01 §3 에 등재되지 않았다. 🔴 등재 전에는 화면이 `code` 로 아이콘·색도 고르지 않는다(픽스처 고정).
4. **M2-8 창을 닫는 시점** — 06 M2-8 은 「단계 1 마이그레이션 창과 같은 창에서 열고 그 창이 닫힐 때 함께 닫는다」고 정했다. 🔴 **창이 닫힌 뒤 발견된 이름은 다음 창까지 ⚠️ 로 남기고 그 화면을 만들지 않는다.**

---

## L. 🆕 계약 v1.1 (2026-09-17 · M2 보강 회차) — 창이 닫힌 뒤의 «다음 창» 1회

K-4 가 말한 「창이 닫힌 뒤 발견된 이름은 다음 창」이 이것이다. C4(병합 검사) R1-Bob-J1 · R1-Gem-S71 · R2-Gem-S73 이
찾아낸 계약 공백 13건(01 §8 미결 33~45)과 J-2·J-3·J-5 의 읽기 창구 부재를 **한 번에** 닫았다.
`contractVersion` = **`1.1.0`** · 픽스처 96건 봉투 동시 상향.

| # | 01 §8 | **확정 이름** | 자리 | 한 줄 규칙 |
|---|---|---|---|---|
| L-1 | 36 | `AppLinkOpener` · `AppLinkSchemes` · `AppRoutes`(40 라우트 · `isRegistered`) | `lib/src/navigation/app_links.dart` | **링크는 데이터로 온다** — 화면은 만들지도 해석하지도 않고 `open(link)` 에 그대로 넘긴다. `aaq://`·`handbook://` 두 스킴. C-33 |
| L-2 | 36 | `LinkAction { label, deepLink }` | `dto/common.dart` | 엔진이 준 이동 버튼 1개. null = 버튼 **부재** |
| L-3 | 33 | `DateRange.isDefault`(`@Default(false)`) | `primitives/date_range.dart` | 프리셋 목록에서 true 는 정확히 1건(C-34 ①) |
| L-4 | 34·35·36 | `TradeJournalEntry.sideLabel` · `quantityText`·`priceText`·`commissionText`·`taxText` · `detailDeepLink?` | `dto/journal.dart` | 원값 4종은 **표시용이 아니다**. 가림도 `*Text` 안에서 끝난다 |
| L-5 | 37 | `JournalFilterCatalog { statusOptions, originOptions, symbolOptions, asOf }` · `JournalStatusOption` · `FillOriginOption` | `dto/journal.dart` · `JournalRepository.watchFilterCatalog()` | 기간·슬리브는 `ConfigRepository` 가 준다(두 벌 금지). 「전체」= 인자 null |
| L-6 | 38 | `JournalTimelineBadge { badgeCode, label, tone, deepLink? }` · `JournalBadgeCodes` | `JournalRepository.watchTimelineBadges()` | 건수는 문구 안에 있다 — 화면이 세지 않는다 |
| L-7 | 39·36 | `BlockFlag.checkpointLabel?` · `clearDeepLink?` | `dto/safety.dart` | `clearRoute`(열거) = 해제의 **성격**, 목적지는 `clearDeepLink` |
| L-8 | 40·43 | `MonthlyReport.pendingNoticeText?` · `generatedAtText?` · `configHash?` | `dto/performance.dart` | 봉투 형제 키 `pending_d_day_text` **폐기** |
| L-9 | 41 | `ReportItem.detailDeepLink?` | `dto/performance.dart` | non-null 인 항목에만 「자세히」 — 항목을 한정하지 않는다 |
| L-10 | 45 | `ContributionRow.unavailableLabel?` | `dto/performance.dart` | non-null 이면 막대 없음 · `normalized == 0.0` · 재정규화 금지 |
| L-11 | — (J-2) | `DecisionDetailVm` · `DecisionChainStep` · `DecisionChainStageCodes`(8) · `SafetyCheckLevelCodes`(4) · `RejectTrace.occurredAtText?` | `JournalRepository.watchDecisionDetail(decisionId)` | 체인은 **언제나 6칸**. 화면이 `chainOf`·`findByDecisionId`·`fillChain` 을 조립하지 않는다 |
| L-12 | — (J-3) | `JournalDraftFormSpec` + `decisionId`·`pledgeLines`·`contextChips`·`deviation` | `JournalRepository.draftFormSpec(decisionId)` | 서약문 0줄이면 서약 블록 자체가 없다 |
| L-13 | — (J-5) | `UnknownBoardVm` · `UnknownResolutionItem` · `UnknownResolutionStageCodes`(4) | `JournalRepository.watchUnknownBoard()` | 재조회·강제 해소 링크는 오지 않는다 |
| L-14 | — | `package:domain_contracts/testing.dart` — `UnimplementedJournalRepository`·`…PerformanceRepository`·`…ConfigRepository` · `RecordingLinkOpener` | `lib/testing.dart`(배럴 밖 · test 전용) | 화면 테스트의 가짜는 `extends` 한다 — 창구가 늘어도 깨지지 않는다 |
| 🆕 L-15 | — (J-3 · R2 준비 2026-09-23 · 01 §11-10) | `JournalDraftRejectCodes`(1 — `journalAlreadyExists = 'JOURNAL_ALREADY_EXISTS'`) · 사전 키 `journal_draft_reject` · 받침대 `UnimplementedCommandApi`(13) · `UnimplementedSafetyRepository`(1) · 픽스처 `m6/journal_draft_receipts_5.json`(`FixturePaths.m6JournalDraftReceipts5`) | `labels/journal_codes.dart` · `lib/testing.dart` | 거부 사유 문구는 `CommandReceipt.stateLabel` 하나 — 코드는 표시·분기 대상이 아니다. 버전 불변(`1.1.0` · DTO 무변경 추가) · 계약 테스트 C-7 쓰기 이름 파일 허용 목록 +1(`lib/testing.dart` — 쓰기 이름 ⊆ `CommandApi` 거울 검사) · C-16 «사유 코드 사전은 `kind` 가 정한다» |

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 44(`S7-3` 초안 필드: 에피소드 표·백분위·회복 필요 수익률 — 엔진 분석 산출물 정의가 선행) ·
🆕 미결 46(`J-4` blind 리뷰: 읽기 창구·픽스처 + `BlindReviewScore.answers: Map<String,int>` ↔ `BlindReviewQuestion.choices: List<ReasonOption>` 축 불일치).

---

## M. 🆕 계약 v1.2 (2026-09-25 · R2b 선행 M2 보강) — 미결 47·48·51④

R2b-Bob-J3(사전 저널 영속화·읽기 뷰) 발송 전에 계약 면을 닫았다. `contractVersion` = **`1.2.0`** · 픽스처 104건
(기존 97 봉투 한 줄 + 신규 7) · 라우트 41 · 조문 = 01 §12.

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| M-1 | `DraftStore` · `load` · `save` · `clear` | 셋째 쓰기 창구(기기 로컬 초안 · 원장·명령 쓰기가 아니다 — 01 §1-4 예외 1) · `commands/draft_store.dart` · 동사 = 01 §8 47 원문. C-7 ⑤⑥ |
| M-2 | `DraftKind`(`journalDraft`·`manualFillRecord`·`adviceSkip`·`selfReportBalance`) | `enums/draft.dart` · Dart 이름·표기 = `CommandKind` 의 같은 값(어순 비대칭 포함) · 영구 제외 6종(C-35 ②) |
| M-3 | `DraftKey`(`kind`·`targetId`) | 초안 자리 — `targetId` = 위젯 생성자 인자 그대로(링크 조립 아님) · 모드는 키에 없다 |
| M-4 | `DraftRecord`(`key`·`journal`·`manualFill`·`adviceSkip`·`selfReport`·`lastCommandId`) | 봉투 — 본문 칸은 `key.kind` 의 칸 정확히 1개(C-35 ①) · `lastCommandId` = 재시작 뒤 이중 제출 차단 |
| M-5 | `…Input` 접미 규칙 | «사람이 친 원문 — 초안 본문» · 필드 이름 = 명령 인자 · 원문 = `<인자>Text` · 확인값·세션값·맥락 제외 · 추가형으로만 진화(C-35 ④) |
| M-6 | `JournalDraftInput`·`ManualFillInput`·`AdviceSkipInput`·`SelfReportInput`·`SelfReportLineInput` | `commands/drafts.dart` |
| M-7 | `DecisionJournalVm`(`journalStateLabel`·`body`·`decisionLink`) · `DecisionJournalBody`(`writtenAtText`·`ruleCitedLabel`·`rationaleBefore`·`expectedOutcome`·`note`) | `dto/journal.dart` · 결과·손익 필드 추가 금지(C-34 ⑧ 허용 키 목록) |
| M-8 | `JournalRepository.watchDecisionJournal` | 10번째 메서드 · «미작성» = `body == null` 인 값 · 결정 부재 = 스트림 에러 |
| M-9 | `AppRoutes.journalRead` | `aaq://journal/read/:decisionId` · 41번째 · `DecisionDetailVm.journalLink`(작성됨)의 목적지(C-34 ⑨) |
| M-10 | 화면 ID `J-3R` | `J-3` 읽기 뷰(골든 접두 `j3r_`) |
| M-11 | `UnimplementedDraftStore` · `RecordingDraftStore`(`loaded`·`saved`·`cleared`·`current`) | `testing.dart` · 받침대 자체 검증 C-35 ⑦ |
| M-12 | 픽스처 7 · `FixturePaths` 상수 7 | `m6DraftRecordsJ3`·`m6DraftRecordsX7`·`m6JournalReadWritten`·`m6JournalReadNoNote`·`m6JournalReadNotWritten`·`m6DecisionDetailJournalWritten`·`m6DecisionDetailJournalDraftLink` |
| M-13 | C-35 | 초안 포트 경계(7건) — `test/contracts/c35_draft_store_test.dart` |
| M-14 | 권고(화면 쪽 · 카드가 확정) | `journalDraftStoreProvider` · `journalReadProvider` · `JournalReadView` · `JournalReadContent` · `JournalLabels.submitNotAccepted` · 키 `j3-submit-not-accepted`·`j3-resubscribe`·`j3r-state`·`j3r-body`·`j3r-written-at`·`j3r-link-decision` |

🔵 같은 PR 의 커밋 1 — C-12 가 `ui_*/lib`·`apps/*/lib` 의 switch «전부 받기» 6형태(`default:`·`_ =>`·`case _:`·`T _`·`final x =>`·`case final x:`)를
대상 타입 불문으로 금지한다(정규식 5 · 자체 검증 · 문서화 예외 맵 = 빈 맵 · 양방향). C-3 금지 의존 +7(저장 패키지).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 44(`S7-3` 초안 필드) · 46(`J-4` 점수 축·읽기 창구·픽스처 — 본문 단위만 `DecisionJournalBody` 로 정함) ·
🆕 52(X7 초안 소비 경로 — `adviceFill` 파라미터 · `A-4` 라우트 · 원문→인자 변환 주체 · `L-3` 세션 VM · operator 공용 주입 파일 · `M5-12`) ·
🆕 53(기기 로컬 암호화 저장소 구현 06 M4-9 · X1 «초안 불이동» 게이트 · 모드 전환 때 초안 처리).

---

## N. 🆕 계약 v1.3 (2026-09-28 · R10 선행 M2 보강) — 성과 시리즈 표시 · 열람 게이트·기록 · 아카이브

R10-Bob-S7x(`S7-1b` 아카이브 · `S7-2G` 열람 게이트 · `S7-2` 수익률 탐색) 발송 전에 계약 면을 닫았다. `contractVersion` = **`1.3.0`** · 픽스처 115건
(기존 104 가운데 100 은 봉투 한 줄 · 4 는 본문 개정 + 신규 11) · 라우트 41 그대로(+ 동작 링크 1) · 조문 = 01 §13.

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| N-1 | `PerfPoint.xNormalized` · `yNormalized` | 점의 가로·세로 자리(0.0~1.0 · 🔴 그래프 기하 전용) · `dto/performance.dart` · `xNormalized` 는 required(엄격히 증가 · 점 1개면 0.5) · `yNormalized` 는 nullable(null = 결측 — 선을 끊는다 · `value == null` 과 늘 함께). 본선과 벤치마크는 같은 축. C-36 ①② · C-10 ⑤ |
| N-2 | `PerfPoint.dateText` · `valueText` | 점의 글자(둘 다 required · 엔진 생성) — 값 표의 재료 · 결측 점에도 온다(«산출 불가» · «합산 제외»). 🔴 `PerfPoint.value` 는 골든 대조·회귀 전용 — `ui_*` 참조 금지(C-36 ⑦) |
| N-3 | `PerfSegment.startNormalized` · `endNormalized` | 띠의 가로 범위(그림 영역 폭에 대한 비율 · 둘 다 required) — 엔진이 덮는 점의 앞뒤 반 칸까지 넓혀서 준다 · 화면은 `from`·`to` 를 점의 날짜와 비교하지 않는다. C-36 ④b ⑥ |
| N-4 | 🆕 타입 `PerfAxisTick`(`normalized`·`label`·`isBaseline`) | 세로축 눈금 1개 · `dto/performance.dart` · `isBaseline` 은 `@Default(false)` · 한 시리즈에 기준선은 많아야 하나 · 눈금 수 ≤ 5(C-36 ④) |
| N-5 | `PerformanceSeries.seriesLabel` · `periodLabel` · `yTicks` · `unavailableLabel` | 본선 이름(범례) · 덮는 기간 · 눈금 목록(`@Default` 빈 목록) · 불가 문장. 🔴 `unavailableLabel != null ⇔ points 가 비어 있다`(그때 `segments`·`yTicks` 도 비고 `benchmark` 는 null — C-36 ⑤) |
| N-6 | `GapReasonCodes.simExcluded` | `'SIM_EXCLUDED'` · `labels/verdict_codes.dart` · `values` 3종 — 모의 구간(`SegmentKind.simExcluded`) 안의 점(C-10 ⑦) |
| N-7 | `PerformanceRepository.series({… DateRange? range})` | **바뀐 시그니처**(required → nullable) · null = 엔진 기본 구간(무엇이 골라졌는지는 `periodLabel`) · v1.3 의 `S7-2` 는 언제나 null · `weekly` 로는 부르지 않는다(01 §8 미결 54). 받침대 `UnimplementedPerformanceRepository.series` 도 같은 커밋 |
| N-8 | `ReportArchiveRow.sectionLabel` | nullable · non-null 이면 **이 행 위에** 머리글 1줄 — 묶음의 첫 행에만 엔진이 싣는다 · 화면은 앞 행과 비교하지 않는다. `ReportArchiveVm.rows` = 엔진이 최신 달부터 정렬. C-34 ⑩(행 키 ⊆ 7) |
| N-9 | `DisclosureGateVm.gateOpen` · `frictionLine` · `route` | **뜻 확정**(필드 무변경 — dartdoc) — `gateOpen` = 엔진이 지금 진입을 허용하는가 · `frictionLine == null` = 그 줄이 없다 · `route` = 게이트 밖 진입점용(게이트 화면은 열지 않는다 · `gateOpen == (route != null)` — C-37 ①) |
| N-10 | `DisclosureViewEvent.durationSec` | **바뀐 기본값**(required → `@Default(0)`) · `commands/payloads.dart` · 진입 시점 기록은 0 — 화면은 적지 않는다(C-37 ④) |
| N-11 | 🆕 `DisclosureSurfaceCodes.performanceExplore` · `.values` | `'PERFORMANCE_EXPLORE'` · 🆕 `labels/disclosure_codes.dart` · 사전 키 `disclosure_surface`(`ContractCodes.byDomain`) — `DisclosureViewEvent.surfaceCode` 의 값(C-37 ⑤) |
| N-12 | 🆕 `AppNavActions.back` · `.all` | `'aaq://nav/back'` · `navigation/app_links.dart` · **동작 링크**(목적지가 아니다 — 「돌아가기」) · 🔴 `AppRoutes.all` 밖 · DTO·픽스처에 실리지 않는다(C-33 +2단언) · 동작 링크는 `back` 하나 — 추가는 계약 버전 사안 |
| N-13 | `Clock` 의 둘째 자리 | 이름 무변경 · dartdoc 개정(`primitives/money.dart`) — ① 신선도 비교 ② 명령 페이로드의 관측 시각(`DisclosureViewEvent.viewedAt`) |
| N-14 | 픽스처 11 · `FixturePaths` 상수 11 | `m7M7ReportArchiveEmpty` · `m7M7DisclosureGateFirst`·`m7M7DisclosureGateFrequent`·`m7M7DisclosureGateClosed` · `m7M7DisclosureViewReceipts4` · `m7M7PerfMonthlySimSplit`·`m7M7PerfDailyManual`·`m7M7PerfMonthlyPeriod`·`m7M7PerfYearly`·`m7M7PerfUnavailableGap`·`m7M7PerfMaskedIntegrity` · `FixturePaths.all` 115 · 개정 4(`performance24m`·`m7M7PerfDailyGap`·`m7M7DisclosureGate`·`m7M7ReportArchive18` — 상수 이름 그대로) |
| N-15 | C-36 · C-37 | 성과 시리즈 표시·기하 계약 — `test/contracts/c36_perf_series_display_test.dart` / 열람 게이트·기록 계약 — `test/contracts/c37_disclosure_gate_test.dart` |
| N-16 | 골든 하네스 `chart_probe` | `packages/ui_analytics/test/golden/chart_probe.dart`(+ 자체 검증 `chart_probe_test.dart`) — «선이 끊겼다»·«띠가 있다»의 주 증명 · 함수 이름은 실물이 정본 |
| N-17 | 권고(화면 쪽 · 카드가 확정) | 공개 위젯 `ReportArchiveScreen` · `PerformanceExploreScreen` · 주입 `analyticsCommandApiProvider`(배럴 쪽) · 데이터 `reportArchiveProvider`·`disclosureGateProvider`·`performanceSeriesProvider`(열쇠 `PerfSeriesQuery`) · 공용 위젯 `AnalyticsSkeleton`·`AnalyticsErrorView` · 정적 라벨 `AnalyticsLabels.gateBackButton`·`gateContinueButton`·`recordNotAccepted`·`metricTwr`·`metricMwr`·`granularityDaily`·`granularityMonthly`·`granularityYearly`·`cumulativeOn`·`cumulativeOff`·`valuesShowButton`·`valuesHideButton`·`valuesColumnMain`·`valuesColumnBenchmark`·`drawdownLinkButton`·`contributionLinkButton` · 키 접두 `s71b-`·`s72g-`·`s72-` · 골든 접두 `s71b_`·`s72g_`·`s72_` |

🔵 같은 PR 의 커밋 ① — `ui_analytics` 구 테스트 3파일의 가짜를 `implements PerformanceRepository` → `extends UnimplementedPerformanceRepository` 로(버전 무관 · 골든 불변).
🔴 **만들지 않은 이름**(재론 방지): `nearestIndex`·`chartTapHint`(탭 읽기 줄 기각 — 값 표로 대체) · `ReportArchiveRow.statusLabel` · 아카이브 그룹 DTO · 토글 카탈로그 DTO · 픽스처 `m7_perf_empty`·`m7_perf_all_gap`(불가의 모양은 하나 — `m7_perf_unavailable_gap`).

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 54(주 경계·주간 선택지) · 55(기간 선택 UI) · 56(「월 1회 권장」 문구 필드) · 57(열람 시각을 큐가 채우는 안) ·
58(절단선·`manualExecuted` 신뢰 배지) · 59(`DISCLOSURE_VIEW` 거부 코드 사전·거부 접수증) · 60(열람 길이 기록) · 61(웹 2열·통계 패널·`afterTax`·토글 카탈로그) ·
62(셸 몫 — 라우터 가드 테스트·`AppNavActions.back` 구현) · 63(`S7-1` A13 → R11 부록 후보) · 64(CI Flutter 버전 고정·선 그림 골든 실측) · 이전부터의 44·49.

---

## O. 🆕 계약 v1.4 (2026-09-30 · R11 선행 M2 보강) — 입금 플래너 · 실입금 등록 · 목표 경로

R11(`S7-4` 투자금 플래너 → 카드 R11a · `S7-9` 목표 금액 경로 → R11b · `S7-5` 인출 안내 → R11c ⏸ 보류) 발송 전에 계약 면을 닫았다.
`contractVersion` = **`1.4.0`** · 픽스처 **122건**(115 + 신설 7 · 개정 16 — 전 봉투 `contract_version` 한 줄 포함) · 라우트 41 → **42** · 조문 = 01 §14.
🔴 `S7-5`(`WithdrawalPlan`) 는 v1.4 범위 밖이다 — 인출 픽스처 3벌은 `OrderDraft` 새 required 키만 기계적으로 더했다(01 §14-15 · v1.5).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| O-1 | 🆕 타입 `DepositPreviewResult`(`plan`·`inputRejectedText`·`blockedText`·`blockedAction`) | `WhatIfApi.simulateDeposit` 의 반환 · `dto/plan.dart` · 🔴 앞 셋 중 **정확히 하나** non-null · `blockedAction`(`LinkAction?`)은 `blockedText` 가 있을 때만(C-38 ①) · 세 갈래는 그리는 자리가 다르다(01 §14-3) |
| O-2 | 🆕 타입 `PensionLimitVm`(`annualLimitText`·`taxCreditText`·`deadlineText`·`suggestionText?`·`fundingNoteText?`) | 스텝 ② 한도 카드 — 모든 줄이 완성 문장 · `dto/plan.dart`(01 §14-4) |
| O-3 | `DepositPlan` +8 — `asOf` · `depositAmountText` · `pensionLimit`(`PensionLimitVm?`) · `residualKrwCashText?` · `orderDraftsTitle` · `ordersEmptyText?` · `warningLines`(`@Default` 빈 목록) · `registerBlockedText?` | null 규칙 표 = 01 §14-4 · 🔴 `expiredText` 는 **없다**(만료·정합 불일치·원장 정정 중은 `registerBlockedText` 하나 — 01 §14-5) · `previewNotice` = «미리보기입니다…» 고지 전용(C-38 ③) |
| O-4 | `OrderDraft` +4 — `sideLabel` · `quantityText` · `limitPriceText?` · `pendingNoteText?` / `SleeveAllocation` +`routingReasonText?` | 화면은 원값(`side`·`quantity`·`limitPrice`·`amount`)을 읽지 않는다 — «읽지 않는 필드» 목록 = 01 §14-4 = C-38 ⑩ 정규식(코드 주석 `/// 🔴 ui 미참조(C-38 ⑩)`) |
| O-5 | `ContributionSetting.amountInputText` · `MonthlyContributionVm.amountInputText` | 플래너 스텝 ① 입력칸의 **초기 글자 전용**(엔진이 만든 숫자 글자 · 스트림의 첫 값만 채운다) · `dto/settings.dart` · 투영은 같은 이름(N-S4-03) · `amount` 는 ui 미참조(01 §14-5) |
| O-6 | `WhatIfApi.simulateDeposit({required String amountInput})` · 🆕 `findPlan(String planId)` → `Future<DepositPlan?>` | **바뀐 시그니처** — 입력칸 글자 그대로(파싱·범위·차단 판정 = 구현체 · 구 `accountAlias` 삭제) · `findPlan` null = 그 planId 가 없다 · 플래너는 `estimateCosts`·`findPlan`·`previewRebalance` 를 부르지 않는다(01 §14-8 · C-38 ⑪) · `simulateWithdrawal` ⏸ v1.4 무변경 |
| O-7 | `DepositRegistration({required String planId})` · `CommandKind.depositRegister` | **줄어든 페이로드**(구 `amount`·`valueDate` 삭제 · `commands/payloads.dart`) · 🔴 `DEPOSIT_REGISTER` = **폰(operator) 전용** — 뷰어 화이트리스트 5종 → **4종**(01 §14-2 · §4-2 · RLS 와 일치) |
| O-8 | `GoalPathVm` 재설계 · 🆕 `PerformanceRepository.goalPath({required String yyyyMm})` | 필드 = F-15 행 · `planned`·`actual` = `List<PerfPoint>`(같은 길이·`date`·`xNormalized` · 계획선 결측 0) · ❌ **`GoalPathPoint` 폐기**(`seriesCode` 도 없다 · C-39 ⑧) · 봉투 `lag_notice` → `deviationText` 승격 · `honestExpectationText`·`honestExpectationWorstText` = 세후 사다리 마지막 층을 인용하는 완성 문장(«`PerfDisclosure` 유일 운반처» 조문의 명시 예외 · 01 §14-10) · 🔴 `S7-9` 는 `ConfigRepository` 를 읽지 않는다(C-10 행) |
| O-9 | C-4 **결정 뒤집기** | v1.0 «두 필드 · 화면이 동시에 그리지 않는다» → v1.4 **역할 고정**(`basisText` = 판정 근거 줄 · `backtestBasisText` = 가정 카드 1줄 · `startingCapitalAssumptionText` = 가정 카드 2줄) · 동시 금지 조문 **폐기**(03 §14 가정 카드 두 줄 요구가 이긴다 · 01 §14-10). 03 의 `contributionAssumptionText` 는 `startingCapitalAssumptionText` 로 읽는다(필드 신설 없음) |
| O-10 | 🆕 `MonthlyReport.goalDeepLink`(`String?` · JSON `goal_deep_link`) · 🆕 `AppRoutes.reportGoalPath = 'aaq://report/goal/:yyyyMm'` | «목표 경로 보기» 버튼의 목적지 — null = 버튼 부재(과거 달·가림·미생성 달은 null 일 수 있다) · 화면은 해석·조립하지 않고 `AppLinkOpener.open` 에 그대로 · C-33 `_linkKeys` +`goal_deep_link` · `AppRoutes.all` **42**(01 §14-9) |
| O-11 | `AppRoutes.planDeposit`(주석 개정) | operator 전용 화면(`package:ui_analytics/planner.dart` · 배럴 밖 · TARGETS T-4) — viewer 셸도 `all` 대로 등록하되 목적지 = «폰에서만 쓸 수 있습니다» 부재 안내(셸 몫 · 선례 J-3 `journalDraft` 의 iOS 셸 가드) · ⏸ `planWithdrawal` 은 v1.5 |
| O-12 | 🆕 `PlannerReasonCodes.depositRouting`(`'DEPOSIT_ROUTING'`) · `.values` | 🆕 `labels/plan_codes.dart` · 사전 키 `planner_reason`(`ContractCodes.byDomain`) — 플래너 사유 칩 코드 · 거부 코드 사전은 01 §8 미결 74 · 🔴 플래너 사유 칩은 `label`·`tone` 만 · 탭 0(D20 · 미결 81) |
| O-13 | 받침대(`lib/testing.dart`) | 🆕 `UnimplementedWhatIfApi`(5메서드 · 전부 `Future` 에러) · `UnimplementedPerformanceRepository.goalPath`(그 클래스 관행대로 동기 throw) · `UnimplementedCommandApi.registerDeposit`(시그니처 무변경 · 새 인자 주석) |
| O-14 | 픽스처 7 · `FixturePaths` 상수 7 | `m7M7DepositPlanBlocked`·`m7M7DepositPlanInputRejected`·`m7M7DepositPlanFunding` · `m7M7DepositRegisterReceipts4` · `m7M7GoalPathOff` · `m9ContributionSettingDefault`·`m9ContributionSettingNoLimitNote` · `FixturePaths.all` **122** · 개정 16(입금 계획 3벌 행 타입 `DepositPlan` → `DepositPreviewResult` · `deposit_plan_1`·`deposit_plan_funding_1` · 목표 경로 3벌 · `m7_monthly_*` 5벌 · 인출 3벌 기계적) · 생성 = `packages/domain_contracts/tool/gen_r11_fixtures.py` · `m9/` 는 접두 없음 · 계좌 별칭 표 = `fixtures/README.md`(+ `test/contracts/support/fixture_accounts.dart`) |
| O-15 | C-38 · C-39 · 경계 검사 | 플래너 표시 계약 — `test/contracts/c38_planner_display_test.dart`(픽스처 면 ①~⑨ + ui 스캔 ⑩⑪⑫) / 목표 경로 표시·기하 계약 — `test/contracts/c39_goal_path_display_test.dart`(①~⑦ + ⑧ 폐기 이름 0 + ⑨ ui 스캔) · 헬퍼 `support/perf_line_rules.dart`(C-36 과 공유) · C-35 ⑥ 확장(planner 는 `planner.dart`·`src/planner/**` 밖에서 import 0) · `tool/check_boundaries.sh` **[7]**(viewer 앱의 `package:ui_analytics/planner.dart` 0 · [6] = T-3 예약) · C-15 봉투 최상위 키 화이트리스트(01 §14-12) |
| O-16 | 골든 하네스 | `chart_probe.dart` 에 `expectGoalPathMatches` **추가만**(기존 4종 불변) · 자체 검증 `test/golden/goal_path_probe_test.dart`(나쁜 painter 2종 — 보간 · 층 바꿈) · 본보기 `test/golden/reference/goal_path/`(`goal_path_chart_painter.dart`·`goal_path_chart.dart` — 화면 담당은 `lib/src/goal_path/` 로 diff 0 복사) · 함수 이름은 실물이 정본 |
| O-17 | 권고(화면 쪽 · 카드가 확정) | 플래너 공개 위젯 `DepositPlannerScreen`(`planner.dart` export = 화면 · 프로바이더 파일) · 프로바이더 `plannerWhatIfApiProvider`·`plannerConfigRepositoryProvider`·`plannerCommandApiProvider`(throw 기본)·`plannerContributionSettingProvider` · 목표 경로 공개 위젯 `GoalPathScreen({required String yyyyMm})` · `S7-1` 버튼 `Key('s71-goal-link')` + 라벨 `goalPathDetailButton`(R11b 부록 커밋) · 키 접두 `s74-`·`s79-` · 골든 접두 `s74_`·`s79_` |

🔴 **만들지 않은 이름**(재론 방지): `expiredText`(등록 차단은 `registerBlockedText` 하나) · `PlannerEntryVm`(플래너 진입 판정 창구 — D21 대안 기각 · 차단은 결과의 `blockedText`) · 입력 `DecimalStringConverter` 공인 · `GoalPathPoint`·`seriesCode` · `WithdrawalPreviewResult`·`WithdrawalStep`·`PensionPenaltyVm`·`AppRoutes.planWithdrawal`(v1.5 예정 모양 — 지금은 선언하지 않는다 · 01 §14-15) · 뷰어 골든 `s74_viewer`.

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 66(스텝 ④ 즉시/대기 비교) · 67(시나리오 로컬 저장) · 68(등록 뒤 M5 핸드오프) · 69(워터폴·배분비·슬리피지) ·
70(비용 내역 문자열) · 71(advisory 표 제목 표본) · 72(M9 계좌 매핑 목적지) · 73(뷰어 플래너 미리보기) · 74(`DEPOSIT_REGISTER` 거부 코드 사전) ·
75(금액이 든 실문장과 C-32 ⑥) · 76(핸드북 «기대치의 한계» 연결) · 77(`aftertax_ladder_1` 층 밀림 — R12 선행) · 78(C-32 ui 면·`check_labels` CI 편입) ·
79(인출 규칙 정본 → v1.5) · 80(목표 금액 입력 설정 키) · 81(플래너 사유 칩의 핸드북 연결).
