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
| A-13 | 01 §2-6 G-45 «⚠️ 열거값 이름 M2-8 확정 대기(후보 `settingsContributionUpdate`)» | 월 납입 운영값 변경 동작 | ~~⏸~~ ✅ `SettingsActionId.settingsContributionUpdate` | 01 §2-6 후보 그대로. 🔴 **«운영 등급»이며 `settingsGeneralUpdate` 로 태우지 않는다** — 일반 등급이면 «즉시 반영»이 되어 「다음 납입 주기부터 적용」이 깨지고 생체 재인증도 건너뛴다. ⏸ 사유 = 05 §1 등급표에 «운영 등급» 행이 신설되어야 성립 · 🆕 **v1.23(01 §32 · ✅ 병합 PR #227 squash `e3e8f7a` · 2026-11-17)** — ✅ 화면 = 05 `S13`(운영 등급 · K75) · 제출 경로 = `SettingsActions.runContributionUpdate(ContributionUpdateSubmission{amountInput 원문})`(`run` 화이트리스트 밖 · K77) · §AB |
| A-14 | 01 §4-3 «⚠️ 미등재 — 캘린더 재연결(G-64)» | 캘린더 재연결 동작 | ⏸ `SettingsActionId.calendarReconnect` | `calendarSyncNow`·`calendarRebackfill` 과 같은 `calendar*` 접두 관례. ⏸ 사유 = X4 채택 자체가 미결(§8-5 OAuth 동의화면 7일 만료 스모크) |
| A-15 | 01 §2-1 · X7 ③ 3-1 | `LedgerEventKind` | ✅ **신설(계약 v1.10 · 2026-10-21 · 설계 13 §8 R21)** — 4값 그대로 + `CorporateActionType`·`CashFlowKind` 동반 · 구 ⏸ `LedgerEventKind { withdrawal, distribution, corporateAction, taxWithheld }` | 🔴 **결정 ㊲ 채택 시에만 신설.** 지금은 `enums/ledger.dart` 에 **주석으로만** 남기고 코드로 만들지 않는다 |
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
| C-2 | 01 §2-1 «⚠️ 하위호환 기본값 부여 여부는 M2-8(§8-19)» | `FeatureFlags.operatingMode` 의 `@Default` | ✅ **기본값을 주지 않는다**(`required OperatingMode operatingMode` · 2026-10-22 발주자 확정 — 01 §8-19) | 🔴 «기본이 자동»이 조용한 전제가 되는 쪽이, 뷰어가 명시적으로 죽는 쪽보다 나쁘다 — «온보딩 미완»은 «자동 매매»가 아니다(G-02). ~~⏸ 사유 = `rm_config_view.operating_mode` 컬럼이 **같은 창에서** 들어가야 성립(§8-14 와 한 사안)~~ ✅ 컬럼 = NOT NULL · 엔진 M4-1 이 월 납입 5컬럼과 같은 창에 넣는다 · 뷰어가 못 읽으면 «모름» 없이 `incompatible`(01 §6-4 G-36) |
| C-3 | 01 §2-6 «⚠️ `FundingStep` 필드는 상세 설계 확정» | 납입 조달 단계 | ✅ `FundingStep { int order; SleeveId sourceSleeve; String? symbol; String? symbolLabel; int quantity; @D Decimal expectedProceeds; String ruleCited; String label }` | 01 §2-6 «최소 축: 순서·매도 대상 슬리브/티커·수량·예상 조달액·근거 규칙 `03 §5-5b`» + 라벨 규약(§1-5) |
| C-4 | 01 §2-6 «⚠️ `basisText` 확장 vs 신설 = M2-8 택일» | `GoalPathVm` 백테스트 근거 줄 | ✅ **신설** `GoalPathVm.backtestBasisText`(기존 `basisText` 는 그대로 둔다) | 확장하면 한 필드가 두 뜻을 갖는다. 🆕 **v1.4 — 역할 고정 · 동시 금지 폐기(01 §14-10 · §O O-9)**: `basisText` = 판정 근거 줄 · `backtestBasisText` = 가정 카드 1줄(«백테스트 기준 실행») · `startingCapitalAssumptionText` = 가정 카드 2줄 — 03 §14 가정 카드가 **두 줄**을 요구하므로 v1.0 의 «화면이 두 필드를 동시에 그리지 않는다» 조문(과 그것을 검사하려던 까닭)은 **폐기**됐다. 두 필드를 둔다는 이름 결정은 그대로다 |
| C-5 | 01 §2-6 «🆕 요청 후보 — 확정 아님, M2-8» | 초기 진입 램프 진행 | ✅ `EntryRampProgress { List<EntryRampSleeveState> sleeves }` · `EntryRampSleeveState { SleeveId sleeve; String stateCode; String stepLabel }` · `stateCode ∈ {MONTHLY_SPLIT, COMPLETED_IMMEDIATELY, AWAITING_SEASONAL_GATE}` | 01 §2-6 «최소 축: `sleeve`·`stateCode`·`stepLabel`». 🔴 **«n/6» 단일 게이지가 아니라 슬리브별 상태 목록**이다 — A·C 에 n/6 을 그리면 거짓 진행률 |
| C-6 | 01 §2-6 · §2-10 | `RampLevel`(OpsRamp) | ✅ `enum RampLevel { l0, l1, l2, l3, l4, l5 }` → `'L0'`…`'L5'` | 03_실행 §9 자금 투입 단계 · `ramp_state` 단일 행. 🔴 **EntryRamp 와 다른 것**이며 하나의 위젯으로 합치지 않는다 |
| C-7 | 01 §2-6 «P 회차 요청 필드» | `SleeveAllocationRow` | ✅ `{ SleeveId sleeve; AllocationBasis basis; SleeveId? parentSleeve; String? engineColumnNote; String deployedText; String parkingText; double deployedRatio; double parkingRatio; String? parkingNoteText; String trancheStateText; String deployedPctText; String parkingPctText }` | 01 §2-6 원문 그대로. 🔴 `deployedRatio`·`parkingRatio` **둘 다 준다**(화면이 `1 − x` 를 계산하지 않게) · 두 비율은 **막대 기하 전용** · 홈 재사용은 **`*PctText` 별도 필드**(금액 문자열이 홈으로 새면 04 §2-6 금지) · 🆕 **v1.8(01 §17)** 밴드 축 +7(`sleeveLabel` · `sleeveWeight?` · `bandState?` · `bandStateLabel?` · `gauge?`(`SleeveBandGauge`) · `bandNoteText?` · `stateChips`) · 두 비율 nullable(가림 = 둘 다 null) · 창구 `watchAllocation()` → `SleeveAllocationVm` |
| C-8 | 01 §2-6 «🆕 요청 후보 — 채택 여부는 06 §6 미결 13» | `rejectedCandidates`(기각 등록부) | ⛔ **만들지 않는다** | 🔴 핸드북 원고 HB-3 확정 전에는 **구현 대상이 아니다**. 이름만 예약하고 필드를 만들지 않는다 |
| C-9 | 01 §2-11 «⚠️ M2-8 확정 대기» | `AdviceRepository.fillsOfAdvice` | ✅ `Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId)` | G-23. 🔴 `JournalRepository.fillChain(entryId)` 와 **다른 것**이다 — 02 §3-7 의 `fillChain(adviceId)` 인용은 **오기**이며 01 이 이긴다 |
| C-10 | 01 §4-1 «⚠️ 소속 리포지토리는 M2-8 택일» | `watchContributionSetting()` | ✅ `ConfigRepository.watchContributionSetting()`(별도 리포지토리를 만들지 않는다) | 소비처(`S05`·`S7-4`·`H-02`)가 **같은 값 하나**를 읽는 것이 요구이고, 창구가 둘이면 화면이 두 경로를 동시에 쓴다. 🆕 **v1.4 — 4곳 → 3곳**: `S7-9` 는 `ConfigRepository` 를 읽지 않는다(03 §17-17 이 이긴다 · 가정 카드 2줄 = 엔진 문장 `GoalPathVm.startingCapitalAssumptionText` · 01 §14-10 · C-39 ⑨) · 🆕 **v1.23(01 §32 K78)** — «창구 하나» → «값의 원천 하나(엔진 `contributionSettingOf`)» · 설정 화면 `S13` = 투영 창구 `SettingsRepository.watchContribution()`(AB-2) · `S7-4`·`H-02` = 이 창구 그대로 |
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
| E-2 | `ThresholdCompare` | ✅ 그대로 · `{ String metricKey; String metricLabel; String observedText; String thresholdText; bool passed; String verdictLabel }` — 🔴 **수치는 전부 엔진 포맷 문자열**(화면이 비교식을 만들지 않는다) | B ~~`dto/journal.dart`~~ 🆕 v1.6 `dto/common.dart`(이름·필드·JSON·배럴 무변경 · §Q Q-8) |
| E-3 | `RejectTrace` | ✅ 그대로 · `{ String stageCode; String stageLabel; String reasonCode; String reasonLabel; DateTime occurredAt }` | B `dto/journal.dart` |
| E-4 | `JournalDraftFormSpec` | ✅ 그대로 · `{ List<ReasonOption> ruleCitedOptions; int rationaleMinChars; String noticeLine; AsOf asOf }` — 🔴 `ruleCited` 선택지는 **엔진 제공 목록**(자유 입력 금지) | B `dto/journal.dart` |
| E-5 | `BlindReviewCard` | ✅ 그대로 · ~~`{ String decisionId; String promptText; List<BlindReviewQuestion> questions }` · `BlindReviewQuestion { String questionId; String text; List<ReasonOption> choices }`~~ 🆕 **v1.7(01 §16 · §R)** `{ decisionId; titleText; promptText; contextChips; deviation; journalStateLabel; DecisionJournalBody? journal; questions; BlindReviewResult? result; asOf }` · `BlindReviewQuestion { questionId; text; String? evidenceText; List<BlindReviewChoice> choices }` · `BlindReviewChoice { int score; String label }` — 🔴 문항·선택지 문구와 점수도 엔진 | B `dto/journal.dart` |
| E-6 | UNKNOWN 단계 | → **D-10 `UnknownResolutionStep`** | B |
| E-7 | `SleeveAllocationRow` | → **C-7** | C `dto/rebalance.dart`(🔴 **M6 가 아니라 C 영역** — `SleeveWeight`·`AllocationBasis` 와 한 파일에 두어야 C-31 이 한 트리에서 검사된다) |
| E-8 | «손절선 정규값» | ✅ `StopLineNormalized { String tierCode; String tierLabel; @D Decimal? level; String levelText; bool isActive; String basisLabel }` — 🔴 `StopLine`(§2-3)의 **표시 정규화판**이며 `StopLine` 을 대체하지 않는다 | B `dto/holdings.dart` · ✅ **v1.8(01 §17 · R4 선행)** — `HoldingDetailVm.stopLines`(`H6-2` 손절선 **글자 행** · `levelText`·`tierLabel`·`basisLabel` 만 그린다 · 코드 = `StopTierCodes`(`stop_tier`) · 게이지 정규값 = 01 §8 미결 104 · 픽스처 `m6/holding_detail_with_stops`·`_integrity`) |
| E-9 | `LedgerRepairRow` | ✅ 그대로 · `{ String repairId; String diffId; String directionCode; String directionLabel; String originCode; String? decisionId; String evidenceHash; String? supersedes; TradeDate? recomputedFrom; DateTime appliedAt; String label }` — 🔴 `recomputedFrom` 이 C-29(소급 정정 시계열 재계산)의 표시 축이다 | B `dto/ledger.dart` |

---

## F. M7 뷰모델 · 플래너 — 16행

| # | 문서 위치 | 임시 이름 | **확정 이름·최소 축** | 근거 |
|---|---|---|---|---|
| F-1 | 01 §2-6 G-41 | `ReportArchiveVm` | ✅ `{ List<ReportArchiveRow> rows; String? emptyLabel; AsOf asOf }` · `ReportArchiveRow { String yyyyMm; String label; bool generated; String? reasonLabel; String modeLabel; String? route }` — 🔴 **수치 필드 0건** | `S7-1b` · `rm_report_archive`(수치 컬럼 없음) |
| F-2 | 01 §4-1 G-41·G-42 | `DisclosureGateVm` | ✅ `{ bool gateOpen; String headline; String viewCountText; String? frictionLine; String? route; AsOf asOf }` — 🔴 **`viewCountThisMonth` 숫자 필드를 두지 않는다**(화면이 「n회」를 조립하지 않게) | `S7-2G` · `rm_disclosure_view`(월 단위 카운트만 push) |
| F-3 | 01 §2-6 G-41 | `DrawdownContextVm` | ✅ `{ String periodLabel; String currentDdText; String maxDdText; String tuwText; double ddNormalized; String? referenceBandText; String? referenceBandCaveatText; AsOf asOf }` | 01 §2-6. 🔴 `referenceBandCaveatText` 가 **null 이면 줄을 그리지 않는다**(«최대낙폭은 하한»의 단서) |
| F-4 | 01 §2-6 G-41 · 03 §10 | `ContributionVm`(**슬리브 기여 분해**) | ✅ `{ String periodLabel; List<ContributionRow> rows; String? fxNoteText; String methodNoteText; AsOf asOf }` · `ContributionRow { SleeveId sleeve; String label; String contributionText; double normalized }` — 🔴 **종목 단위 행 없음** | 03 §10 `S7-3b`. 🔴 **`MonthlyContributionVm` 과 다른 타입**이며 이름을 공유하지 않는다 |
| F-5 | 01 §2-6 G-41 · §8-27 | `NextRebalanceVm` | ✅ `{ String? emptyLabel; String expectedDateText; String dDayText; RebalanceKind? expectedKind; String? kindLabel; String? previewRoute; String? noticeText }` — 🔴 **리포지토리 반환은 nullable 이 아니다** · `emptyLabel` 이 non-null 이면 **카운트다운 카드를 그리지 않고 이 문장만** 그린다 · 🆕 **v1.6 개정**(§Q Q-5) `expectedDateText`·`dDayText` → `String?`(null ⇔ `emptyLabel` non-null) · +`AsOf asOf` | 03 §11-c · N-4 |
| F-6 | 01 §2-6 G-41 | `AnnualReviewVm` | ✅ `{ String year; String windowStateCode; String windowStateLabel; List<AnnualReviewSection> sections; AsOf asOf }` · `AnnualReviewSection { String code; String title; List<String> lines; String? route }` — 🔴 **묶음이지 재집계가 아니다** · 화면이 `windowState` 를 «달»로 판정하지 않는다 · 🆕 **v1.6 개정**(§Q Q-9) +`String yearLabel` · `AfterTaxLadder? afterTax` · `AfterTaxLadder? afterTaxCounterfactual` | `S7-7` · 06 M1-20b(⬜ later — **이름은 지금 등재**) · 🆕 **v1.24(01 §33 K118)** — M9 `S12` = **별 타입** `AnnualReviewIndexVm`(`OpsStatusRepository.watchAnnualReview` 반환 교체 · 세후·수치 칸 0) · 이 타입의 소비자 = M7 `S7-7` 하나 |
| F-7 | 01 §2-6 | `MonthlyReport` | ✅ `{ String yyyyMm; List<ReportItem> items(**13항목 고정 배열**); String goalLine; String disclosureViewCountText; AfterTaxLadder? afterTax; LedgerTrustBadge trust; String? backdateFootnote; AsOf asOf }` — 🔴 **단일 `afterTaxPct` 필드를 만들지 않는다** · 반사실 항목을 14번째로 늘리지 않는다(C-25) | 01 §2-6 · G-97 |
| F-8 | 01 §2-6 | `PerfDisclosure` | ✅ `{ String sampleSizeLine; String interstitialText; int viewCountThisMonth; String honestExpectationLine; String? drawdownCaveatLine }` — 🔴 **M7 화면 한정**. M8 온보딩·핸드북은 같은 문자열을 **각자의 뷰모델 필드**로 받는다(타입 의존을 건너오지 않는 것이 C-3 규약) | 01 §2-6 |
| F-9 | 01 §2-6 | `BenchmarkSeries` | ✅ `{ String label; List<PerfPoint> points; String compositionNote }`(KOSPI 50% + S&P500(KRW) 50%) | 01 §2-4 |
| F-10 | 01 §2-6 | `ExecutionQuality` | ✅ `{ String slippageText; String assumedSlippageText; String unfilledRateText; String summary }` — 🔴 실측 vs 가정치 비교 문장도 엔진 | 01 §2-5 |
| F-11 | 01 §2-6 | `SleeveAllocation`(`DepositPlan` 충당액) | ✅ `{ SleeveId sleeve; String label; @D Decimal amount; String amountText; String? accountAlias }` — 🔴 `SleeveAllocationRow`(C-7)와 **다른 타입**이다(전자는 플래너 충당액, 후자는 배분 현황 행) | 01 §2-6 |
| F-12 | 01 §2-6 | `CostEstimate` | ✅ `{ @D Decimal commission; @D Decimal tax; @D Decimal total; String totalText; CostSource source; String sourceLabel; String basisNote }` | 01 §2-6 · C18 |
| F-13 | 01 §2-6 | `WithdrawalPlan` | ✅ `{ String planId; DateTime computedAt; DateTime expiresAt; @D Decimal amount; List<OrderDraft> orderDrafts; CostEstimate costs; AfterTaxLadder? afterTax; String previewNotice; String configHash }` | `DepositPlan` 대칭 |
| F-14 | 01 §2-6 | `RebalancePreview` | ✅ `{ String planId; TradeDate plannedDate; List<SleeveWeight> before; List<SleeveWeight> after; List<OrderDraft> orderDrafts; CostEstimate costs; List<FundingStep>? fundingSteps; String previewNotice }` — 🔴 `DepositPlan` 과 **같은** `fundingSteps` · 🆕 **v1.6 개정**(§Q Q-1·Q-2) +`String plannedDateText` · `AsOf asOf` · `String orderDraftsTitle` · `String? ordersEmptyText` · `List<String> warningLines` · 반환은 래퍼 `RebalancePreviewResult` | 01 §2-6 v2.32 |
| F-15 | 01 §2-6 · 🆕 §14-10 | `GoalPathVm` | ✅ 🆕 **v1.4 재설계** `{ String yyyyMm; String judgementText; String basisText; String? deviationText; String periodLabel; String plannedLabel; String actualLabel; List<PerfPoint> planned; List<PerfPoint> actual; List<PerfAxisTick> yTicks; List<PerfSegment> segments; String? chartUnavailableLabel; String backtestBasisText; String startingCapitalAssumptionText; String honestExpectationText; String honestExpectationWorstText; String disclaimerText; AsOf asOf }` — 🔴 구 `List<GoalPathPoint> points` 와 타입 **`GoalPathPoint` 는 폐기**(C-39 ⑧ · `seriesCode` 없음) · 필드 → 자리 대응표 = 01 §14-10 | 01 §2-6 + C-4(v1.4 역할 고정) · §O O-8·O-9 |
| F-16 | 01 §2-4 | `AfterTaxLadder`·`AfterTaxStep` | ✅ 01 §2-4 원문 그대로(⚠️ «이름·필드 M2-8» 해제) · 🔴 `isReferenceOnly` 는 **§8-18 확정 전 항상 true** · 🆕 **v1.6 개정**(§Q Q-10) +`String? referenceOnlyLabel` | 01 §2-4 · §8-18 |

---

## G. M8 · M9 운영 · 설정 뷰모델 — 13행

> 01 §2-6 «M8·M9 뷰모델군 — **이름까지 잠정**이므로 04·05 의 필드명을 그대로 코드에 굳히지 않는다». 🔴 여기서 이름을 확정한다.

| # | 임시 이름 | **확정 이름·최소 축** | 근거 |
|---|---|---|---|
| G-1 | `ShellVm` | ✅ `{ String? runModePrefix; String? operatingModePrefix; List<ShellChip> bandChips; String? bandToneCode }` — 🔴 **띠는 하나**, 칩 2개. 접두 순서 «모의투자 · 투자 안내 · 제목» | 01 §10-1 · C-17·C-18 |
| G-2 | `OpsRhythmRow` | ✅ `{ String code; String title; String whenText; String? dDayText; String? route }` | 04 §4-7 `H-02` |
| G-3 | `WatchdogCheck` | ✅ ~~`{ String slug; String label; String stateCode; String stateLabel; String lastPingText; String? graceText; String? route }`~~ 🆕 **v1.15(01 §24 · K4·K16·K17)** `{ String checkId; String label; String stateCode; String stateLabel; UiLevel level; String lastPingText; String? graceText; String? route }` · 창구 반환 = `WatchdogBoardVm{ rows, asOf, emptyLabel?, holidayNotice?, limitNotice?, lastReceivedText? }` — 🔴 슬러그(**2축 합성** `{sim\|live}-{auto\|advisory}-{체크명}`)는 엔진·healthchecks 설정의 이름이라 **DTO 에 오지 않는다**(`checkId` = 엔진이 짓는 불투명 id · 화면은 그리지·Key·비교 0) · 목록 길이·이름은 **서버가 준다** | 04 §7 `W-01` · §9-5 ⑦ · C20 |
| G-4 | `OpsDailySummary` | ✅ `{ AsOf asOf; String todayOrdersText; String todayErrorsText; String signalMatchText; String streakText; String discretionBudgetText; String nextRebalanceDDayText; List<OpsRhythmRow> upcoming }` — 🔴 **전부 엔진 완성 문자열 · 수치 필드 0건** | 01 §4-1 주석 그대로 · G-29 |
| G-5 | `SettingsHomeVm` | ✅ `{ List<SettingsCard> cards }` · `SettingsCard { String code; String title; String? statusLabel; UiLevel level; bool actionAvailable; String? route }` — 🔴 `actionAvailable == false` 는 «비활성»이 아니라 **카드 부재**로 그린다 | 05 §5-2 |
| G-6 | `CredentialListVm` | ✅ `{ List<CredentialCardVm> cards }` · `CredentialCardVm { String alias; String kind; String kindLabel; String healthCode; String healthLabel; CredentialUse usage; String usageLabel; String? expiresText }` — 🔴 `kind` 에 `KIS_RECONCILE` 추가(X7 ③ 3-2 · **05 §5-2 가 정본**) | 05 §5-2 |
| G-7 | `ConnectionsVm` | ✅ `{ List<ConnectionRow> rows; AsOf asOf }` · `ConnectionRow { String target; String label; String statusCode; String statusLabel; String lastOkText; bool actionAvailable; String? route }` | 05 `S07` · G-29 |
| G-8 | `DeviceAccessVm` | ✅ `{ List<DeviceRow> devices; String leaseHolderLabel; String leaseStateLabel; String? leaseEtaText; AsOf asOf }` · `DeviceRow { String deviceId; String label; String roleLabel; String statusLabel; String lastSeenText }` — 🔴 **리스는 읽기 전용** | 05 `S06` |
| G-9 | `BackupVm` | ~~✅ `{ String lastOkText; String statusCode; String statusLabel; String? sizeText; bool actionAvailable; String? route; AsOf asOf }`~~ → 🆕 v1.24 `{ String lastBackupText; String? ageBadgeText; UiLevel level; String? noticeText; SettingsActionCall? runAction; String? lockedLabel; List<RestorePointRow> points; String? pointsEmptyLabel; LinkAction? migrationLink; AsOf asOf }` | 05 `S09` · 🆕 **v1.24 교체(01 §33 K110 · ✅ 병합 PR #235 squash `bbed5ef` · 2026-11-18 · R8a 병합 뒤)** — `{ lastBackupText · ageBadgeText? · level · noticeText? · runAction? · lockedLabel? · points · pointsEmptyLabel? · migrationLink? · asOf }` + `RestorePointRow` · 옛 7 칸 중 6 칸 삭제(`asOf` 유지 · 소비자 0) · 복원 버튼 0 |
| G-10 | `DiagnosticsVm` | ✅ `{ List<DiagnosticCell> cells; String headline; AsOf asOf }` · `DiagnosticCell { LedgerPair pair; String label; bool applicable; String stateCode; String stateLabel; UiLevel level }`(🆕 v1.13 `level` · 01 §23 K2) — 🔴 **칸 수 5 고정은 엔진이 준다** · `applicable == false` 는 ~~«점검 안 함»~~ 🔵 엔진 `stateLabel` 그대로(«해당 없음»·«점검하지 않음» 등 · 그 칸 `level` = `info`) · 🆕 v1.13 칸 색·아이콘 = `level` 하나(`stateCode` ui 미참조) · `headline` = 늘 엔진 문장(K4) | 05 `S10` · 🆕 `H-01` 블록 6(R13b) · §2-9 · C15 · 🆕 **v1.24(01 §33 K113)** — M9 `S10` 화면 = 감싸개 **별 타입** `DiagnosticsScreenVm{golden · integrity: SelfTestCard · board: DiagnosticsVm · …}`(`SettingsRepository.watchDiagnosticsScreen()`) · 이 타입·`watchDiagnostics` 무변경(H-01) |
| G-11 | `MonthlyContributionVm` | ✅ `{ String amountText; String equivalentNoteText; String appliesFromText; String lastChangedText; String? pensionLimitNoteText; bool editable }` — 🔴 `ContributionSetting` 의 **1:1 투영** · `editable` 만 런타임 값(`SettingsActions` 주입 여부) · 🔴 **필드를 이어 붙여 문장을 만들지 않는다**(투영을 늘리는 것은 허용) · 🆕 **v1.23(01 §32 K79)** += `asOf` · `lockedLabel?` · `changeLabel?` · `editable` = ui 미참조 표식(AB-1) | 01 §2-6 · §8-31 · N-S4-03 |
| G-12 | `OperatingModeView`·`OperatingModeOption` | ✅ 01 §2-11 원문 그대로 | 01 §2-11 |
| G-13 | `HandoverPlan`·`HandoverStep`·`AdoptionPreviewRow` | ✅ 01 §2-11 원문 그대로 (`adoptionId`·`disposition`·`dispositionLabel` 포함 — G-03) | 01 §2-11 |

---

## H. 명령 · 리포지토리 · 설정 동작 — 10행

| # | 문서 위치 | 임시 이름 | **확정** | 근거 |
|---|---|---|---|---|
| H-1 | 01 §2-6 «M2-8 최우선» | `JournalDraft` | ✅ `{ String decisionId; String rationaleBefore; String expectedOutcome; String ruleCited; String? note }` — 🔴 `ruleCited` 는 **엔진 제공 목록의 코드**(자유 입력 금지) | 01 §2-6 «최소 축» 그대로 |
| H-2 | 01 §2-6 | `BlindReviewScore` | ✅ `{ String decisionId; Map<String, int> answers }` — 문항 id → 점수. 🔴 문항·선택지 문구는 `BlindReviewCard`(E-5)가 준다 · 🆕 v1.7(01 §16 · 필드 무변경) 점수 = 고른 `BlindReviewChoice.score` 를 **그대로 옮긴 값** · 전 문항(K10) | 01 §2-6 |
| H-3 | 01 §2-6 · G-42 | `DisclosureViewEvent` | ✅ `{ String surfaceCode; DateTime viewedAt; int durationSec }` — 🔴 **집계 키 `yyyy_mm` 을 화면이 넣지 않는다**(엔진이 `viewedAt` 에서 파생) | 01 §2-6 |
| H-4 | 01 §2-11 · §8-20 | `SymbolOption`·`AccountOption`·`ReasonOption` | ✅ `SymbolOption { String symbol; String label; SleeveId sleeve }` · `AccountOption { String alias; String label }` · `ReasonOption { String code; String label; bool requiresNote }` | 01 §2-11 «폼 선택지 3형제» |
| H-5 | 01 §8-20 · D19 «🔴 선행 미결» | `ReasonOption` ↔ `J-3` `rule_cited` 통합 | ⏸ **통합한다** — `JournalDraftFormSpec.ruleCitedOptions` 의 타입도 `List<ReasonOption>` | 「사유를 고르는 목록이 두 벌이 되어 한쪽만 갱신되는 사고」를 막는 것이 미결의 이유다(06 §6 미결 15). ⏸ 사유 = **06 `X7-2` 착수 전에 발주자·엔진 확인**이 붙은 항목 |
| H-6 | 01 §8-21 | `CommandContext` 를 기존 5종에도 붙일지 | ⏸ **붙인다**(전 명령이 `required CommandContext context`) | 「어느 맥락에 적용할 명령인가」의 답이 명령 종류마다 다르면 소비 규칙이 두 벌이 된다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로 **배치 D 와 같은 창**이어야 성립 |
| H-7 | 01 §4-3 · §8-24 | 위저드 쓰기 3종 args 필드명 | ✅ `handoverAdoptionSet` = `{handover_session_id, symbol, disposition}` · `handoverExternalRegister` = `{handover_session_id, symbol, quantity, account_alias, action}` · `handoverCommit` = `{handover_session_id}` — 🔴 args 키는 **snake_case**(`Map<String,String>` 이므로 Dart 관례가 아니라 전송 규약을 따른다) | 01 §4-3 화이트리스트. 🔴 `handover_session_id` 는 세 동작 모두 **필수** |
| H-8 | 01 §4-1 G-29 «⚠️ 반환 타입 이름은 M2-8» | `OpsStatusRepository` 반환 6종 | ✅ G-3·G-7·G-8·G-9·G-10·F-6 의 이름 그대로 | 04 §1-2·05 §2 의 잠정명을 이 표가 확정한다 · 🆕 v1.24 — `watchAnnualReview` 반환 = F-6 밖 `AnnualReviewIndexVm`(K118) |
| H-9 | 06 §3-7 G-77 «⚠️ 이름은 M2-8 확정 대기» | M5·X1·X2·X5 라우트 이름 | ⏸ `m5/resume-report` · `m5/kill-switch` · `m5/ledger-repair-wizard` · `m5/advisory-start-gate`(`M5-10`) · `m5/handover-wizard`(`M5-11`) · `m5/manual-fill-amend`(`M5-12`) · `m5/self-audit-resolve`(`M5-13`) · `x1/device-transfer` · `x1/maintenance-window` | 🔴 `ActionResult.handoffRoute` 는 **이 목록에 있는 이름만** 반환하고 화면이 이름을 지어 쓰지 않는다. ⏸ 사유 = M5 화면 소유자(Claude) 확정 대기이며, 이름이 없으면 `C-17`·`C-18` 의 «전 라우트 전수»가 M5 를 통째로 빠뜨린 채 통과한다 |
| H-10 | 01 §7 · 06 M2-6 «⚠️ 번호 M2-6 확정» | 운영 파라미터 리터럴 탐지 테스트 번호 | ✅ **`C-32`** | 01 §7 표가 이미 C-32 행으로 실었고 C-30·C-31 이 P 회차로 소진됐다 |

---

## I. 엔진 config 키 · 스키마 축 — 6행

| # | 문서 위치 | 임시 이름 | **확정** | 근거 |
|---|---|---|---|---|
| I-1 | 01 §2-6 · §8-22 | 납입 주기 config 키 | ✅ **확정(계약 v1.9.0 · 2026-10-21 · 설계 13 §8 R19 E9-8)** = 매월 첫 거래일(휴장이면 다음 거래일 · 당일 접수는 다음 달) — 값은 SPEC 02 §4 config 키(E9b) · 구 ⏸ `contribution_day`(기본 = **매월 첫 거래일** · 당일 접수는 다음 달 적용) | 01 §2-6 후보 그대로. 🔴 **엔진 config 신설 키**이므로 06 §4 SPEC 개정 배치 계획 ④ 에 1행으로 등재되어야 값이 존재한다. ⏸ 사유 = 발주자가 자동이체 실행일에 맞추기를 원하면 **날짜만** 바뀐다 |
| I-2 | 01 §2-6 · §6-2 | 운영 파라미터 키 | ✅ `operating_param_log.param_key = 'monthly_contribution'`(화이트리스트 1값) | §6-2 주석 그대로. 🔴 `fx_overlay` 계열 키를 넣지 않는다 |
| I-3 | 01 §9-1 · §9-5 ④ | 로컬 `mode` CHECK 의 값 도메인 | ✅ **확정(계약 v1.9.0 · R19 E9-2 · R20 Q1)** — 3값 + 파일별 CHECK(`-- @sim` 태그 · `ledgerDdlFor`) · 구 ⏸ **3값 + 파일별 CHECK**(`ledger.sqlite` = `CHECK (mode = 'LIVE')` · `ledger_sim.sqlite` = `CHECK (mode IN ('SIM_INTERNAL','SIM_BROKER'))`, 배치 F 판은 `= 'SIM_INTERNAL'` 로 좁힌다) | §9-5 ④ 권고(첫 거래 전이라 테이블 재생성 비용 0). ⏸ 사유 = 01 §9-1 이 «확정 전에는 DDL 을 고치지 않는다»를 명시했고, 넓히면 배치 A·B 가 재작성 대상이 된다 |
| I-4 | 01 §8-6 | `CORPORATE_ACTION` vs `CORP_ACTION` | ✅ **확정(계약 v1.9.0 · R19 E9-4)** · 구 ⏸ **`CORPORATE_ACTION` 으로 통합**(`CORP_ACTION` 은 상수로만 남기고 픽스처·신규 코드에 쓰지 않는다) | X2 계열이 먼저 등재됐고 `CalendarEventKind`·`LedgerEventKind` 도 `corporateAction` 을 쓴다. ⏸ 사유 = **마이그레이션 창 안에서만** 고칠 수 있다(06 M2-1 착수 전 정리 2건) |
| I-5 | 01 §8-7 · §9-5 ① | `mode` ↔ `order_intents.dry_run` 이중 정본 | ✅ **확정(계약 v1.9.0 · R19 E9-5)** — 파생 규칙 `dry_run = 1` ⇔ `ExecPolicy.dryRun` · 구 ⏸ **`dry_run` 컬럼 유지 + `ExecPolicy` 로 이름만 승격**(폐지하지 않는다) | §9-5 ① 채택 계약. ⏸ 사유 = 파생 규칙 명문화가 M2-1 창 |
| I-6 | 01 §8-23 G-01 | `onboarding_choice.committed_at` 을 무엇이 채우는가 | ✅ **`O-04` 완료가 채운다**(첫 배치 성공이 아니다 · 2026-10-22 발주자 확정 — 6단계 «DRY_RUN 시작» 명령과 같은 트랜잭션) | 「선택 후 되돌리기」의 경계가 사용자가 보는 단계와 일치해야 한다. 첫 배치 성공을 기준으로 하면 배치가 실패하는 동안 선택이 무한히 열려 있다. ~~⏸ 사유 = 발주자 확인~~ ✅ 확인됨(01 §8-23) · 🔵 `ddl/batch_c_x2_x5_local.sql` 주석의 «I-6 ⏸» 는 DDL sha256 고정이라 다음 DDL 개정 때 정리 |

---

## J. ⏸ 발주자 몫 — 권고 이름으로 확정하되 기능은 대기 — 6행

| # | 문서 위치 | 무엇 | **권고 확정** | 왜 ⏸ 인가 |
|---|---|---|---|---|
| J-1 | 01 §8-19 · §8-14 | `FeatureFlags.operatingMode` 하위호환 | → **C-2**(기본값 없음) | ✅ 2026-10-22 확정(01 §8-19) — 컬럼 NOT NULL · M4-1 같은 창 · 못 읽으면 `incompatible` |
| J-2 | 01 §8-28 G-43 | `live × dryRun` 관찰 기간 · 승격 확인 DTO | ⏸ `LiveDryRunObservationVm { int observedTradingDays; int requiredTradingDays; String progressText; bool promotionAvailable; String stateLabel }` · 관찰 거래일 수 = **잠정 2** | 🔴 관찰 일수는 **발주자 확정 대기**이며 엔진 config 신설 키다. 🔴 **승격에 새 화면·새 라우트를 만들지 않는다** — `S05` 엔진 상태 칩 + 기존 M5 게이트 다이얼로그(생체 1회) |
| J-3 | 01 §8-10 · C2 기각 | `ALERT_ACK` 의 뷰어 허용 | ⏸ **허용하지 않는다**(현행 `command_insert_viewer` 4종 화이트리스트 유지) | X7 이 대신 답하지 않는 미결이다. ack 가 2종으로 갈린 뒤에는 **효력이 0인 명령**이고, 48h 개시가 폰을 요구하는 것은 결함이 아니라 결정 6 의 계약이다 |
| J-4 | 01 §6-4 · 10 §3-2 | `rm_ops_summary` 표 존폐(홈 블록 5·7 소유) | ~~⏸~~ ✅ **표를 만든다**(홈을 전 플랫폼으로 유지 · 2026-10-22 · 발주자 · 권고대로 · 설계 10 N-07 — `rm_ops_summary` v1 필수 · 컬럼 = 01 §6-4) | ~~🔴 **정하지 않은 상태가 가장 나쁘다** — 뷰어가 값을 지어낸다. 대안(홈 블록 5·7 을 폰 전용으로 명시)도 유효하며 발주자 택일~~ ✅ 택일 끝 — 뷰어는 `rm_ops_summary` 행을 그대로 그리고 값을 지어내지 않는다(`notLoaded` 는 첫 동기 전에만) · ⬜ DDL·코드 주석 = 다음 계약 PR |
| J-5 | 01 §8-5 | X4 캘린더 계열 전체 | ⏸ **이름·타입은 등재하되 구현하지 않는다** | OAuth 동의화면 «테스트» 상태 7일 만료가 사실이면 X4 계열 문안(§2-8 `chainHash`·이벤트↔원천 표 · `calendar_link.mode` · `calendar_sync_status.mode` · §9-2 캘린더 행)이 **통째로 사문화**되고 `canonCalendar` 축이 대조에서 빠진다 |
| J-6 | 01 §8-6 · X7 ㊲ | `LedgerEventKind`·`recordLedgerEvent`·`LedgerEventRecord` | ✅ **신설(계약 v1.10 · R21)** — `CommandKind.ledgerEventRecord`('LEDGER_EVENT_RECORD') · `CommandApi.recordLedgerEvent` · `LedgerEventRecord` · 거부 `LedgerEventRejectCodes` 8 · 구 ⏸ 이름 확정(A-15) · **코드 미생성** | 결정 ㊲ 채택 시에만 신설. 🔴 채택되지 않으면 인출·분배금·기업행위·원천징수가 원장 밖에 남아 **현금 추정이 단조적으로 어긋나고 그 위에서 안내 수량이 계산된다** |

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
~~🆕 미결 46(`J-4` blind 리뷰: 읽기 창구·픽스처 + `BlindReviewScore.answers: Map<String,int>` ↔ `BlindReviewQuestion.choices: List<ReasonOption>` 축 불일치).~~ ✅ v1.7 해소(2026-10-20 · 01 §16 · 아래 §R — 축 = `BlindReviewChoice{score, label}`).

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
~~🆕 52(X7 초안 소비 경로 — `adviceFill` 파라미터 · `A-4` 라우트 · 원문→인자 변환 주체 · `L-3` 세션 VM · operator 공용 주입 파일 · `M5-12`)~~
✅ 52 = 계약 v1.12(⬜ 로컬 커밋 — PR 대기 · 아래 «S» 절 · ⑥ `M5-12` 만 M5 창) ·
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
🔴 `S7-5`(`WithdrawalPlan`) 는 v1.4 범위 밖이다 — 인출 픽스처 3벌은 `OrderDraft` 새 required 키만 기계적으로 더했다(01 §14-15 · 인출 규칙 결정 뒤 첫 minor).

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
| O-11 | `AppRoutes.planDeposit`(주석 개정) | operator 전용 화면(`package:ui_analytics/planner.dart` · 배럴 밖 · TARGETS T-4) — viewer 셸도 `all` 대로 등록하되 목적지 = «폰에서만 쓸 수 있습니다» 부재 안내(셸 몫 · 선례 J-3 `journalDraft` 의 iOS 셸 가드) · ⏸ `planWithdrawal` 은 인출 규칙 결정 뒤 첫 minor |
| O-12 | 🆕 `PlannerReasonCodes.depositRouting`(`'DEPOSIT_ROUTING'`) · `.values` | 🆕 `labels/plan_codes.dart` · 사전 키 `planner_reason`(`ContractCodes.byDomain`) — 플래너 사유 칩 코드 · 거부 코드 사전은 01 §8 미결 74 · 🔴 플래너 사유 칩은 `label`·`tone` 만 · 탭 0(D20 · 미결 81) |
| O-13 | 받침대(`lib/testing.dart`) | 🆕 `UnimplementedWhatIfApi`(5메서드 · 전부 `Future` 에러) · `UnimplementedPerformanceRepository.goalPath`(그 클래스 관행대로 동기 throw) · `UnimplementedCommandApi.registerDeposit`(시그니처 무변경 · 새 인자 주석) |
| O-14 | 픽스처 7 · `FixturePaths` 상수 7 | `m7M7DepositPlanBlocked`·`m7M7DepositPlanInputRejected`·`m7M7DepositPlanFunding` · `m7M7DepositRegisterReceipts4` · `m7M7GoalPathOff` · `m9ContributionSettingDefault`·`m9ContributionSettingNoLimitNote` · `FixturePaths.all` **122** · 개정 16(입금 계획 3벌 행 타입 `DepositPlan` → `DepositPreviewResult` · `deposit_plan_1`·`deposit_plan_funding_1` · 목표 경로 3벌 · `m7_monthly_*` 5벌 · 인출 3벌 기계적) · 생성 = `packages/domain_contracts/tool/gen_r11_fixtures.py` · `m9/` 는 접두 없음 · 계좌 별칭 표 = `fixtures/README.md`(+ `test/contracts/support/fixture_accounts.dart`) |
| O-15 | C-38 · C-39 · 경계 검사 | 플래너 표시 계약 — `test/contracts/c38_planner_display_test.dart`(픽스처 면 ①~⑨ + ui 스캔 ⑩⑪⑫) / 목표 경로 표시·기하 계약 — `test/contracts/c39_goal_path_display_test.dart`(①~⑦ + ⑧ 폐기 이름 0 + ⑨ ui 스캔) · 헬퍼 `support/perf_line_rules.dart`(C-36 과 공유) · C-35 ⑥ 확장(planner 는 `planner.dart`·`src/planner/**` 밖에서 import 0) · `tool/check_boundaries.sh` **[7]**(viewer 앱의 `package:ui_analytics/planner.dart` 0 · [6] = T-3 예약) · C-15 봉투 최상위 키 화이트리스트(01 §14-12) |
| O-16 | 골든 하네스 | `chart_probe.dart` 에 `expectGoalPathMatches` **추가만**(기존 4종 불변) · 자체 검증 `test/golden/goal_path_probe_test.dart`(나쁜 painter 2종 — 보간 · 층 바꿈) · 본보기 `test/golden/reference/goal_path/`(`goal_path_chart_painter.dart`·`goal_path_chart.dart` — 화면 담당은 `lib/src/goal_path/` 로 diff 0 복사) · 함수 이름은 실물이 정본 |
| O-17 | 권고(화면 쪽 · 카드가 확정) | 플래너 공개 위젯 `DepositPlannerScreen`(`planner.dart` export = 화면 · 프로바이더 파일) · 프로바이더 `plannerWhatIfApiProvider`·`plannerConfigRepositoryProvider`·`plannerCommandApiProvider`(throw 기본)·`plannerContributionSettingProvider` · 목표 경로 공개 위젯 `GoalPathScreen({required String yyyyMm})` · `S7-1` 버튼 `Key('s71-goal-link')` + 라벨 `goalPathDetailButton`(R11b 부록 커밋) · 키 접두 `s74-`·`s79-` · 골든 접두 `s74_`·`s79_` |

🔴 **만들지 않은 이름**(재론 방지): `expiredText`(등록 차단은 `registerBlockedText` 하나) · `PlannerEntryVm`(플래너 진입 판정 창구 — D21 대안 기각 · 차단은 결과의 `blockedText`) · 입력 `DecimalStringConverter` 공인 · `GoalPathPoint`·`seriesCode` · `WithdrawalPreviewResult`·`WithdrawalStep`·`PensionPenaltyVm`·`AppRoutes.planWithdrawal`(인출 규칙 결정 뒤 첫 minor 예정 모양 — 지금은 선언하지 않는다 · 01 §14-15) · 뷰어 골든 `s74_viewer`.

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 66(스텝 ④ 즉시/대기 비교) · 67(시나리오 로컬 저장) · 68(등록 뒤 M5 핸드오프) · 69(워터폴·배분비·슬리피지) ·
70(비용 내역 문자열) · 71(advisory 표 제목 표본) · 72(M9 계좌 매핑 목적지) · 73(뷰어 플래너 미리보기) · 74(`DEPOSIT_REGISTER` 거부 코드 사전) ·
75(금액이 든 실문장과 C-32 ⑥) · 76(핸드북 «기대치의 한계» 연결) · 77(`aftertax_ladder_1` 층 밀림 — R12 선행 → ✅ 2026-10-06 01 §15-1) · 78(C-32 ui 면·`check_labels` CI 편입) ·
79(인출 규칙 정본 → 인출 규칙 결정 뒤 첫 minor) · 80(목표 금액 입력 설정 키) · 81(플래너 사유 칩의 핸드북 연결).

---

## P. 🆕 계약 v1.5 (2026-10-07 · R12 선행 M2 보강) — 회차→일지 링크 · J-1 회차 범위

R12-Bob-S76(`S7-6a` 회차 타임라인 · `S7-6b` 회차 상세 등) 발송 전에 01 §8 미결 49(회차→일지 링크 경로 · `J-1` 회차 칩)를 닫았다.
`contractVersion` = **`1.5.0`** · 픽스처 **126건**(122 + 신설 4 · 개정 2 — 기존 122 가운데 120 은 봉투 `contract_version` 한 줄만) · 라우트 42 → **43** · 조문 = 01 §15-3 · 발주자 결정 ①~⑥(2026-10-07).
🔴 `S7-5`(`WithdrawalPlan`) 는 이 번호를 쓰지 않는다 — 인출 규칙 결정(01 §8 미결 79) 뒤 첫 minor(번호는 그때 · 결정 ①).
★ = 미결 49 밖이지만 R12 를 막는 공백이라 같은 v1.5 창에 넣은 것(결정 ② ⓐⓑⓒ).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| P-1 | 🆕 `AppRoutes.journalRebalance = 'aaq://journal/rebalance/:rebalanceEventId'` | `J-1` 을 **회차 조건으로** 여는 파라미터 라우트 · `navigation/app_links.dart` · `all` 에서 `journalRead` 다음(42 → **43**) · 이름 = 세그먼트 camelCase(`journalDecision`·`journalRead` 선례) · 파라미터 이름 = 역방향 `rebalanceEvent` 의 `:rebalanceEventId` 와 같다 · `journal/decision`·`draft`·`read` 와 세그먼트 수가 같고 둘째 고정 세그먼트로 갈린다 · 셸 본문 = `JournalTimeline(key: ValueKey(id), rebalanceEventId: id)`(`journalTimeline` 과 한 위젯) · 등록 = 전 플랫폼 · 웹 가드 = `journalTimeline` 과 같다 · 🔴 쿼리 운반(`…/timeline?re=…`) 없음(C-33 ④) |
| P-2 | 🆕 `RebalanceEvent.journalTimelineLink`(`LinkAction?` · JSON `journal_timeline_link`) | `S7-6b` 하단 «이 회차의 … N건» 버튼 **하나** · `dto/rebalance.dart` · 이름 = «목적지 + Link»(`DecisionDetailVm.rebalanceLink`·`amendLink`·`parentLink` 선례) · `label` = 엔진 문장 · N = 그 회차에 묶인 일지 행 **전체** 수(정정 행 포함 · 기간 무관 — 결정 ④) · 낱말 = 자동 갈래 «주문» · advisory 갈래는 행을 가리키는 말(픽스처 «기록») · 🔴 null = 버튼 **부재**(묶인 일지 행 0) · 🔴 화면이 `orderIntentIds.length` 로 N 을 세거나 `eventId` 로 링크를 조립하면 반려 · `_linkKeys` 무변경(안쪽 `deep_link` 로 C-33) |
| P-3 ★ⓑ | 🆕 `RebalanceEvent.detailDeepLink`(`String?` · JSON `detail_deep_link`) | `S7-6a` 행 탭 → `S7-6b`(`AppRoutes.rebalanceEvent` 를 엔진이 완성) · 이름·규약 = `TradeJournalEntry.detailDeepLink` 와 같다 · null = 행 탭 무반응 · `S7-6b` 안에서는 쓰지 않는다(자기 자신) · 기존 링크 키 |
| P-4 | 🆕 타입 `JournalRebalanceScope`(`rebalanceEventId`·`label`·`range`) | `J-1` 회차 조건의 **범위 설명**(회차 칩 글자 + 씨앗 기간) · `dto/journal.dart`(`JournalFilterCatalog` 뒤) · 이름 = `Journal` 접두(`JournalFilterCatalog`·`JournalTimelineBadge`) + «범위» · 🔴 시트 선택지가 아니라 `*Option` 꼴이 아니다(회차 조건은 링크로만 들어온다 · 시트 상태 필드 신설 금지 — A14) · `label` 에 식별자 없음 · `range` = 그 회차에 묶인 일지 행 **전부**를 덮는 구간(프리셋 아님 — `presetCode` null · `isDefault` false · 결정 ⑥) · 화면은 첫 쿼리의 `range` 로 그대로 쓴다(날짜 산술 0) |
| P-5 | 🆕 `JournalRepository.watchRebalanceScope(String rebalanceEventId)` → `Stream<JournalRebalanceScope?>` | 11번째 메서드 · 꼴 = 위치 인자 키드 읽기(`watchDecisionDetail(String)`) + «watch + 반환 타입»(`watchFilterCatalog`) · 키 = 셸이 라우트 파라미터에서 꺼내 `JournalTimeline(rebalanceEventId:)` 로 준 값 · null = 엔진이 그 회차를 모른다 → 칩 **부재** · 엔진 규칙 «null ⇒ 같은 id 의 `watchTimeline` 0행 + `emptyLabel`» · `journalTimelineLink` 가 non-null 인 회차에는 null 을 주지 않는다 · 인자에 `RunMode` 없음(키드 읽기 선례 · 회차 id 모드 간 유일성 = 미결 90) · 🔴 화면이 `RebalanceRepository` 를 구독해 글자를 조립하지 않는다(C-40 ⑧) |
| P-6 ★ⓐ | 🆕 `RebalanceRepository.watchEvent(String rebalanceEventId)` → `Stream<RebalanceEvent>` | `S7-6b` 회차 1건 — `RebalanceEventScreen` 이 이 창구 **하나만** 구독(셸 → 생성자 인자 → 키) · 이름 = `watchEvents` 의 단수형 · 모르는·지난 id = 스트림 에러(**잠정** — `watchDecisionDetail` 과 같은 묶음 · 미결 50 ③) · 🔴 `watchEvents` 행을 id 로 고르면 반려(거르기도 판정) |
| P-6b ★ⓒ | `RebalanceRepository.watchEvents(DateRange r)` **바뀐 반환형** → `Stream<ListResult<RebalanceEvent>>` | 이름 불변 · `S7-6a` 빈 상태 문장 = 봉투 `emptyLabel`(화면이 빈 상태 문구를 쓰지 않는다 · 계약 3조 ③) · 바꿀 때 `ui_*`·`apps` lib 의 소비자 0 · 유형 필터·`DateRange` 고르기는 R12 범위 밖(미결 88) |
| P-7 | 받침대(`lib/testing.dart`) | 🆕 `UnimplementedRebalanceRepository`(`watchEvents`·`watchEvent`·`watchNext` · 동기 throw — 그전까지 이 받침대가 없어 R12 가짜에 `implements` 가 강요됐다) · `UnimplementedJournalRepository.watchRebalanceScope` |
| P-8 | 픽스처 4 · `FixturePaths` 상수 4 | `m6JournalRebalanceScope1` · `m6JournalRebalanceUnknown` · `m7M7RebalanceDetailAdvisory` · `m7M7RebalanceEmpty` · `FixturePaths.all` **126** · 개정 2(`rebalance6` — 6행 `detail_deep_link` · as_of 이전 5행 `journal_timeline_link` · `re_20261030_01` 은 버튼 없음 / `m7M7RebalanceDetailBand` — 같은 두 필드) · 이름 선례 `m6JournalFilterCatalog`·`m7M7RebalanceDetailBand` · 등록부 코덱 +1(`JournalRebalanceScope`) · 생성 = `packages/domain_contracts/tool/gen_r12_fixtures.py`(기준 `dbbd3ae` 원문에서 멱등) · 상세 = `fixtures/README.md` «계약 v1.5» |
| P-9 | C-33 ③④⑦ · 🆕 C-40 · 경계 검사 [5b][5c] | C-33 ③ `hasLength(43)` · ④ +4 예시 · ⑦ 선언 순서 = 첫 일치 / 회차↔일지 링크 정합 — `test/contracts/c40_rebalance_journal_link_test.dart`(①~⑩) / `tool/check_boundaries.sh` [5b] 화면 패키지(`ui_shell` 제외) lib 코드 줄의 파라미터 라우트 상수·`AppLinkSchemes` 참조 0(목록은 `app_links.dart` 에서 추출 · 견본 `rebalanceEvent`·`journalRebalance`) · [5c] 화면 패키지 test Dart 코드 줄의 링크 리터럴 0 |
| P-10 | **M2 이름** `RebalanceEventScreen({required String rebalanceEventId})` | `S7-6b` 본문 위젯 — 셸(R13)이 `rebalanceEvent` 라우트에 `RebalanceEventScreen(key: ValueKey(id), rebalanceEventId: id)` 로 배선할 이름이라 M2 가 정한다(카드가 짓지 않는다) · 선례 = 01 §11-10 의 `MonthlyReportScreen(yyyyMm: …)` · `ui_analytics` 공개 위젯 `*Screen` 관례(`GoalPathScreen`·`ReportArchiveScreen`) |
| P-11 | 권고(화면 쪽 · 카드가 확정) | `J-1` 생성자 `JournalTimeline({String? rebalanceEventId})`(null = 회차 조건 없음) · 회차 칩 `Key('j1-chip-rebalance')` · `S7-6b` 버튼 `Key('s76b-link-journalTimelineLink')` · 골든 `j1_rebalance_chip`·`j1_rebalance_unknown` |

🔴 **만들지 않은 이름**(재론 방지): `JournalRebalanceOption`·`watchRebalanceOption`(시트 선택지 계열 이름 — 회차 조건은 시트에 없다) · `JournalTimelineScope`(non-null 범위 설명 안 — 미결 50 ③ 과 규약이 갈려 기각 · «범위» 낱말만 P-4 에 접목) · `RebalanceEvent.journalLink`(`DecisionDetailVm.journalLink` = 사전 저널 목적지와 동명이의) · `RebalanceEvent.ordersLink`(advisory 갈래에서 틀린 말) · `AppRoutes.journalTimelineRebalance`(6요소 라우트 — 5요소로 겹침 없이 갈린다) · `JournalFilterCatalog.rebalanceEventOptions`(카탈로그 «나머지 셋 · 같은 목록 두 벌 금지»를 구부린다) · `TradeJournalEntry.rebalanceEventLabel`(기본 기간 밖·빈 결과면 칩이 사라진다).

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 83(`S7-6a` «주문 건수» 글자 출처 — R12 는 자리 없음) · 84(픽스처 교차 정합 `journal_30`↔`rebalance_6`) · 85(`fixture_version` 조문) ·
86(advisory 수기 체결 회차 태깅 — 엔진 숙제 06 X7-1) · 87(`S7-6b` 상태 3종 · 골든 `s76b_missing_snapshot` 입력) · 88(`S7-6a` 유형 필터 · `DateRange` 고르기) · 89(SIM 회차 링크) ·
90(회차 id 모드 간 유일성) · 91([5b][5c] 셸 제외 범위 좁히기) · 이전부터의 50 ③(모르는 id = 스트림 에러 잠정 — `watchEvent` 도 같은 묶음).
화면 몫 — `J-1` 생성자 인자·회차 칩 = 다음 ui_journal 카드(R12 뒤 · R13 앞 — 결정 ⑤) · `S7-6b` 버튼·`S7-6a` 행 탭·빈 상태 = R12 카드 · 두 라우트 → 한 위젯·`RebalanceEventScreen` 배선 = 셸 R13.

---

## Q. 🆕 계약 v1.6 (2026-10-08 · R12 선행 M2 보강) — R12 표시 계약(S7-6a/b/c · S7-7 · S7-10)

R12 화면 카드 발송 전에 «Bob 이 추측해야 하는 자리»(DTO 필드·API 인자·반환형·라우트·픽스처)를 닫았다. R12 다섯 화면은 **엔진이 완성한 글자와 null 여부만 보고 그린다**.
`contractVersion` = **`1.6.0`** · 픽스처 **135건**(126 + 신설 9 · 개정 14(개명 1 포함) — 기존 126 가운데 112 는 봉투 `contract_version` 한 줄만) · 라우트 43 → **45** · 조문 = 01 §15-4.
상태 = ~~⬜ 로컬 커밋 — PR 대기~~ ✅ 병합 PR #25 squash `995c1f4`(앱 브랜치 `m2/contract-v1.6-r12` · `2612684`·`f922002`·`edde72b` + 문서 커밋).
결정 = 발주자 2026-10-07 ①(`watchEvents` 범위 nullable) · ②(`RebalancePreviewResult` 래퍼) · ③(X7 전제 ㉒(a)·㉓(b)·㉔(a)·㊶(a)) · ④(`S7-6a` «주문 건수» 자리 없음 · 유형 필터 R12 밖) + 이 창의 **K1~K26 = 권고 선반영**(발주자 «권고하는 대로» 위임 · 00_README §8-4 관행). 🔴 되돌림 비용이 높은 **8건(K1·K5·K6·K8·K10·K11·K22·K24)은 «권고 선반영 · ~~확인 대기(🔴)~~»** — ~~「푸시해」 전 발주자 확인.~~ ✅ 2026-10-13 발주자 확정(K1~K26 전부 권고대로 · 01 §15-4-16). 아래 표의 🔴 표식이 그 8건에 걸린 이름이다(~~확인되면 01 §15-4-16 에 날짜와 함께 옮긴다 · 거절되면 이 절을 고친다~~ ✅ 2026-10-13 옮김 · 거절 0).
🔴 `S7-5`(인출)는 이 번호도 쓰지 않는다 · `S7-8` 은 R12 밖(2026-10-07 결정).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| Q-1 | 🆕 타입 `RebalancePreviewResult`(`preview`·`blockedText`·`blockedAction`) | `WhatIfApi.previewRebalance` 의 반환 · `dto/plan.dart` · 이름 = 발주자 결정 ②(v1.4 `DepositPreviewResult` 꼴) · 🔴 `preview`·`blockedText` 중 **정확히 하나** non-null · `blockedAction`(`LinkAction?`)은 `blockedText` 가 있을 때만(C-41 ① · C-38 ① 준용) · 입력 거부 갈래 없음(입력이 없다) |
| Q-2 | `RebalancePreview` +5 — `plannedDateText` · `asOf` · `orderDraftsTitle` · `ordersEmptyText?` · `warningLines`(`@Default` 빈 목록) | F-14 개정 · `ordersEmptyText` non-null ⇔ `orderDrafts` 빈 목록(C-41 ②) · `previewNotice` = «미리보기입니다…» 고지 전용 · 🔴 ui 미참조(C-42) = `planId`·`plannedDate`·`before`·`after`·`fundingSteps`(R12 는 전후 비중·조달 절을 그리지 않는다 — 미결 92) · `OrderDraft.limitPriceText` 짝 = `DepositPlan`·`RebalancePreview`(인출 초안 제외) |
| Q-3 | `WhatIfApi.previewRebalance({TradeDate? plannedDate})` **바뀐 반환형** → `Future<RebalancePreviewResult>` | 이름·인자 불변(인자는 엔진·테스트용 · null = `watchNext` 와 같은 판정의 다음 예정 회차) · `S7-6c` 호출 표 = 탭 뒤에만 · 인자 없이 · 캐시 0 · 마지막 요청만 · `Future` 에러 = 인프라만 · 예정 없음·계산 막힘 = `blockedText` · `estimateCosts`·`findPlan`·`simulateDeposit` 은 `S7-6c` 가 부르지 않는다 |
| Q-4 | `RebalanceRepository.watchEvents({DateRange? range})` **바뀐 시그니처**(위치 `DateRange r` → 이름 인자 nullable) | 결정 ① · K26 — `range == null` = **전체 기간**(기간으로 자르지 않는다 · 봉투에 기간 글자 없음 · `hasMore` 늘 false) · 이름 인자 꼴 = v1.3 `series(range:)`·`drawdownContext({DateRange? range})` 선례(뜻은 다르다 — `series` 의 null 은 «엔진이 고른 구간») · 🔴 R12 화면은 인자 없이 부른다 · `rows` = 엔진 시간 역순 · 모드 범위 = 미결 89 |
| Q-5 | `NextRebalanceVm` — `expectedDateText`·`dDayText` → **`String?`** · 🆕 `asOf`(R) | F-5 개정 · `dto/rebalance.dart` · null ⇔ `emptyLabel` non-null(C-41 ③ · 센티널 `''` 대신 nullable — 소비자 0 인 지금이 바꾸는 비용 0 의 마지막 창) · `asOf` = 봉투 as_of 를 행으로(`DepositPlan.asOf` 선례 · `H-02` 도 같은 필드) · `watchNext()` 시그니처 무변경(nullable 아님 — N-4) · 🔴 ui 미참조 = `expectedKind` · `previewRoute` 는 `S7-6c` 안에서 쓰지 않는다 |
| Q-6 | `RebalanceEvent` +3 — `thresholds`(`List<ThresholdCompare>` · R) · `modeLabel?` · `sectionLabel?` · 🔴 `asOf` **뜻 고정** = 읽기 모델의 관측 시각(K10 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) | `thresholds` = J-2 `DecisionDetailVm.thresholds` 와 같은 타입 · 비어 있지 않음 ⇔ `trigger.thresholdRegistered != null`(C-41 ④) · `modeLabel` = «모의» 배지 글자(non-null ⇔ `mode != LIVE` · K7) · `sectionLabel` = 행 위 머리글(`ReportArchiveRow.sectionLabel` 선례 — 단 `modeLabel` 은 그 선례와 달리 nullable · LIVE = 배지 부재) · `asOf` = 목록 봉투 `as_of` 와 같은 값(회차 시각 아님 — 회차 일자는 `tradeDate`) · 🔴 ui 미참조(C-42) = `mode`·`kind`·`orderIntentIds` · `eventId` = Key 전용 · 표시 일자 = `tradeDate.yyyyMmDd`(예외 1개) |
| Q-7 | `SleeveWeight.label` **뜻 고정** — 이 행의 완성 문장(K11 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) | 필드 신설 0 · 요소 = 현재·목표·편차·밴드 여유(밴드 밖이면 여유 자리에 초과폭) · 정본 = 이 타입 머리 «목표 대비 편차·밴드 여유» + 기존 예시 · 🔴 기존 주석 예시는 바꾸지 않았다(홈 블록 4 가 같은 타입 — R13 재검토) · 🔴 R12 ui 미참조(C-42) = `sleeve`·`weight`·`targetWeight`·`bandLow`·`bandHigh` |
| Q-8 | `ThresholdCompare` **이동** `dto/journal.dart` → `dto/common.dart` | E-2 배정 개정 · 이름·필드·JSON·배럴 export 무변경(`ui_journal` 소비 무변경) · 까닭 = `journal.dart` 가 이미 `rebalance.dart` 를 import 한다(순환 회피) |
| Q-9 | `AnnualReviewVm` +3 — `yearLabel`(R · K24 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · `afterTax?` · `afterTaxCounterfactual?`(K12) / `PerformanceRepository.annualReview({String? year})` **바뀐 시그니처**(`required String year` → nullable · K13) | F-6 개정 · `dto/performance.dart` · `yearLabel` = «2026년 연간 리뷰» · 기본 연도를 엔진이 고르므로 어느 해인지 말하는 **유일한 글자**(C-41 ⑥ — 비지 않음 ∧ `year` 를 품는다) · `year == null` = 엔진 기본 연도(권고: 12월 창 열림 = 그해 · 그 밖 = 마지막 완결 연도 · 완결 연도가 없으면 그해) · 세후 2필드 이름 = `WithdrawalPlan.afterTax` 선례 · VM 최상위(섹션 `code` 로 자리를 고르지 않게) · `afterTaxCounterfactual` ⇒ `afterTax`(C-41 ⑥) · 화면 = 반사실 늘 기본 접힘 · 🔴 ui 미참조(C-42) = `year`·`windowStateCode`·`AnnualReviewSection.code` · `S7-7` 은 `afterTaxLadder` 를 부르지 않는다 |
| Q-10 | `AfterTaxLadder.referenceOnlyLabel`(`String?`) | F-16 개정 · K9 · «골든 참고치입니다…» 엔진 문장 · non-null ⇔ `isReferenceOnly`(C-41 ⑦ · 예외 고정 목록 = `m7_withdrawal_pension_penalty` — 미결 79) · `isReferenceOnly` 는 화면 미참조(C-42) |
| Q-11 | `OpsStatusRepository.watchAnnualReview()` **주석 의무**(시그니처 무변경) | K25 · `S12` 창구의 `AnnualReviewVm` 은 `afterTax`·`afterTaxCounterfactual` 을 **null** 로 준다(엔진 의무 · 결정 8) · 소비 쪽 = C-42 ⑫(`ui_analytics` 밖 `ui_*`·`apps` lib 의 세후 필드 참조 0) · `S12` 표시 범위 = 미결 95 |
| Q-12 | 🆕 타입 `ExecutionGapResult`(`report?`·`emptyKind?`·`emptyLabel?`·`asOf`) / `ExecutionGapRepository.monthly({String? yyyyMm})` **바뀐 시그니처·반환형**(위치 `String yyyyMm` → 이름 인자 nullable · → `Future<ExecutionGapResult>`) | `dto/ledger_trust.dart` · K8(래퍼 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · K1(달 인자 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) · 🔴 `report`·`emptyLabel` 중 정확히 하나 · `emptyKind` ⇔ `emptyLabel` · `asOf == report.asOf`(C-41 ⑧) · 안내 0건 = `noData` · autoTrade 구간 = `notApplicable` · `yyyyMm == null` = 엔진 기본 달(권고: 월간 리포트가 발행된 가장 최근 달) · `watchRolling()` 무변경(🔴 R12 화면 미사용) |
| Q-13 | `ExecutionGapReport` +2 — `countLines`·`correctionLines`(`List<String>` · R) · nullable 2 — `complianceRateNormalized?`(K8) · `modeAdviceLine?`(K6 · 권고 선반영 · ~~확인 대기 🔴~~ ✅ 확정(2026-10-13)) | 01 §2-11 개정 · 건수는 엔진 완성 문장 목록(«세는 수는 엔진 문자열» G-42 · 가림이면 줄 안 «?») · `correctionLines` 빈 목록 = 절 부재 · `complianceRateNormalized` null = 게이지 부재(가림) · `modeAdviceLine` null = 줄 부재(ⓒ 갈리지 않음·정상 달 · 03 §14-b 수용 (b) 정정) · 🔴 ui 미참조(C-42) = `range`·int 9종 |
| Q-14 | 🆕 `AppRoutes.ledgerExecutionGapMonth = 'aaq://ledger/execution-gap/:yyyyMm'`(K1 🔴) · 🆕 `AppRoutes.rebalanceHistory = 'aaq://rebalance/history'`(K5 🔴) | `navigation/app_links.dart` · `all` 43 → **45**(`ledgerExecutionGapMonth` = `ledgerExecutionGap` 다음 · `rebalanceHistory` = `rebalancePreview` 앞) · 이름 = 세그먼트 camelCase · 파라미터 이름 = `reportGoalPath` 의 `:yyyyMm` 과 같다 · 세그먼트 수가 달라 `ledgerExecutionGap` 과 겹치지 않는다 · **두 라우트 · 한 위젯**(`journalRebalance` 다음 두 번째 사례) · `_linkKeys` 무변경 |
| Q-15 | 받침대(`lib/testing.dart`) | 🆕 `UnimplementedExecutionGapRepository`(`monthly`·`watchRolling` · 동기 throw) · `UnimplementedRebalanceRepository.watchEvents({DateRange? range})` · `UnimplementedWhatIfApi.previewRebalance` → `Future<RebalancePreviewResult>` 에러 · `UnimplementedPerformanceRepository.annualReview({String? year})` |
| Q-16 | 픽스처 9 · `FixturePaths` 상수 9 · 개명 1 | `m7M7RebalancePreviewDefault`·`m7M7RebalancePreviewInBand`·`m7M7RebalancePreviewBlocked` · `m7M7NextRebalanceNone` · `m7M7RebalanceSim` · `m7M7AnnualOffwindow` · `m7ExecutionGapEmpty`·`m7ExecutionGapNotApplicable`·`m7ExecutionGapMaskedRecon` · 개명 `m7M7NextRebalanceD6` → **`m7M7NextRebalanceCountdown`**(파일 `m7_next_rebalance_countdown` — 이름에서 값(«d6»)을 뺐다 · 03 §15) · `FixturePaths.all` **135** · 등록부 코덱 +2 · 생성 = `packages/domain_contracts/tool/gen_r12_v16_fixtures.py`(기준 `542d13c` 원문에서 멱등) · 상세 = `fixtures/README.md` «계약 v1.6» |
| Q-17 | 🆕 C-41 · 🆕 C-42 · 경계 검사 | R12 표시 계약 — `test/contracts/c41_r12_view_models_test.dart`(①~⑩) / R12 화면 소스 스캔 — `test/contracts/c42_r12_screen_scan_test.dart`(①~⑬ · ③') + 헬퍼 `test/contracts/support/r12_targets.dart`(역할 표) · C-25 ⑤·C-30 ⓕ·C-31 ⓓ skip 유지 · 제목만 «(R12 밖)» · `tool/check_boundaries.sh` [5b] 견본 +`ledgerExecutionGapMonth` |
| Q-18 | **M2 이름** — 공개 위젯 5(생성자 = key + 셸 파라미터만) | `S7-6a` `RebalanceTimelineScreen()`(라우트 `rebalanceHistory` · `lib/src/screens/rebalance_timeline_screen.dart` · 내부 `lib/src/rebalance/timeline/**`) · `S7-6b` `RebalanceEventScreen({required String rebalanceEventId})`(v1.5 P-10 · `rebalance_event_screen.dart` · `lib/src/rebalance/event/**`) · `S7-6c` `RebalancePreviewScreen()`(`rebalancePreview` · `rebalance_preview_screen.dart` · `lib/src/rebalance/preview/**`) · `S7-7` `AnnualReviewScreen()`(`reportAnnual` · `annual_review_screen.dart` · `lib/src/annual_review/**`) · `S7-10` `ExecutionGapScreen({String? yyyyMm})`(`ledgerExecutionGap`(null)·`ledgerExecutionGapMonth`(m) · `execution_gap_screen.dart` · `lib/src/execution_gap/**`) — 셸(R13)이 배선할 이름이라 M2 가 정한다(카드가 짓지 않는다 · 선례 P-10) · 이 표의 파일 = C-42 의 역할 대상 · 파라미터는 루트 `ValueKey`·프로바이더 키·호출 인자에만(표시 0) |
| Q-19 | 권고(화면 쪽 · R12 카드 규칙이 글자로 고정) | 주입 `rebalanceRepositoryProvider`(R12a) · `analyticsWhatIfApiProvider = Provider<WhatIfApi?>`(R12b · 배럴 쪽 `analytics_providers.dart` · 뷰어 셸 = null → 초안 버튼·영역 부재 · K2 권고 선반영 · TARGETS T-4) · `executionGapRepositoryProvider`(R12d) · 기존 `performanceRepositoryProvider` 재사용 / 결과 `rebalanceEventsProvider` · `rebalanceEventProvider`(family) · `nextRebalanceProvider` · `annualReviewProvider` · `executionGapProvider`(family · 키 = 생성자 `yyyyMm`) — `S7-6c` 미리보기 결과는 프로바이더가 아니라 State · 키 접두 `s76a-`·`s76b-`·`s76c-`·`s77-`·`s710-` · 골든 접두 `s76a_`·`s76b_`·`s76c_`·`s77_`·`s710_` · 질문 파일 4(K21 — `inbox/S7-6ab_questions.md`·`S7-6c_questions.md`·`S7-7_questions.md`·`S7-10_questions.md`) · 카드 4장(K3) `R12a-Bob-S76ab` → `R12b-Bob-S76c` → `R12c-Bob-S77` → `R12d-Bob-S710` |

🔴 **만들지 않은 이름**(재론 방지): `RebalanceEventDetailVm`(`watchEvent` 반환을 `{event, thresholds, asOf}` VM 으로 — v1.5 에서 막 정한 반환형을 바꾼다 · `thresholds` 는 행에, `asOf` 는 뜻 고정으로 충분) · `RebalanceDraftResult`(결정 ② 가 `RebalancePreviewResult` 로 정했다) · `RebalanceEvent.tradeDateText`(`yyyyMmDd` 예외 1개로 충분 · 다음 창 승격 후보) · `SleeveWeight` 의 표시 글자 4~5 필드(+ `label` = 슬리브 이름 — 코드 주석의 뜻을 뒤집는다) · `AnnualReviewSection.afterTax`(섹션 자리를 `code` 로 고르는 길) · `AnnualReviewEntryVm` 류 `S12` 전용 VM(K25 대안 (b) — 미결 95) · `AnnualReviewVm.pledgeLines`·`ruleChangeDeepLink`(K4 — 미결 93 · M9 계약을 앞질러 짓지 않는다) · `GapCountCell{code,label,valueText}`(`code` 가 판정을 부른다 · 다음 창 승격 후보) · `ExecutionGapReport.amendFootnoteText`(㉞·㊳ 확정 뒤 — 미결 96) · `watchEntryAvailability()`(「계획」 탭 ⑤ 존재 판정 창구 — 미결 97) · `RebalanceEvent` 의 회차별 상태 글자(`dimmed`·`pendingBadgeText` 류 — K22 · 미결 87) · 코드 사전 `m7_codes`(창 상태·섹션 — 화면 미참조 · 미결 94) · 라우트 `aaq://report/annual/:year`(연도 = `annualReview({String? year})` · K13) · `watchEvents([DateRange? r])` 위치 인자(이름 인자 선례) · `NextRebalanceVm` 두 글자 `''` 센티널 · `UnimplementedOpsStatusRepository`(Ops 받침대 — `S7-7` = `PerformanceRepository` 하나) · 픽스처 `execution_gap_masked_integrity`(골든 없는 표본 — 미결 96) · 계약 테스트 C-43(2파일 + 역할 표 헬퍼로 같은 범위) · `AppRoutes.planWithdrawal`·`S7-5` 번호(인출 규칙 결정 뒤 첫 minor). 03 구 초안 이름 `ReviewSectionVm`·`changeWindowNoticeText`·`oathText`·`figures`·`AsOfStamp`·`KeyValueVm` 은 코드에 쓰지 않는다.

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 92(`S7-6c` 표시 잔여 — `fundingSteps` 조달 절 · 전후 비중 · advisory 미리보기와 실제 안내의 차이 고지(㉘·㉙·㉝)) · 93(`S7-7` 서약·«규칙 변경은 설정에서» M9 링크 — K4) · 94(`S7-7` 표본·코드 잔여 — 창 축 ↔ «첫 해» 축 분리 · 코드 사전 · 12월 OPEN 표본의 `as_of` 정합 · 섹션 8개 표본 · 섹션별 «산출 불가» · SIM 표본 · `reportAfterTax` 단독 화면) · 95(`S7-7` 연간 수치 노출 자리 ↔ 결정 8 — 남은 것 = `S12` 표시 범위 · `S12` 전용 VM 분리 여부) ·
96(`S7-10` 잔여 — 소급 정정 각주 · LEDGER_INTEGRITY 가림 표본·골든 · 뷰어 판 `trust.actionDeepLink` · RECON_MISMATCH 이행 지표 가림 범위(`S7-1` ⑧ «이행률 88%» ↔ `S7-10` «?») · 가림 표본의 원값 운반 여부) · 97(「계획」 탭 ⑤ 존재 판정 창구 · 탭 허브 소유(M7 위젯 vs M8 셸)).
기존 미결 확장 — 50 ①(국면 배지·`rawValues` 라벨 필드 — S7-6b 까지) · 71(advisory 주문 초안 표 제목 — `RebalancePreview.orderDraftsTitle` 포함) · 73(뷰어 플래너 미리보기 — S7-6c 초안 포함 · 엔진 발행 읽기 모델) · 79(`m7_withdrawal_pension_penalty` 의 `referenceOnlyLabel` 예외) · 81(사유 칩 핸드북 연결 — S7-6c 칩 포함) · 84(`rebalance_6` 순서 ✅ v1.6 · 남은 것 = as_of 뒤 회차 · REGIME 표본 · 종류별 `raw_values` · m8 «D-6» ↔ S7-6c «D-1») · 87(S7-6b 상태 3종 + S7-6a 회차별 흐리게·「미확정」·배지 · RESUME_INCOMPLETE·RECOVERY·LEDGER_FIX 안전 표본 — K22) · 88(«범위 고르기» ✅ v1.6 결정 ① · 남은 것 = 유형 필터) · 89(SIM 회차 링크 · `watchEvents(null)` 의 모드 범위 · LIVE·SIM 섞인 목록의 정렬 키).
엔진(06) 숙제(카드를 막지 않는다) — 차단 갈래표 · 다음 회차 예고 산출 · 정정 행 회차 승계 · advisory 실행 품질 뜻 · 기본 범위·연도·달 · `yearLabel` 생성 · `S12` 세후 null · D-day 기준(K23 — 권고: 달력일) · `rm_*` 운반.
화면 몫 — R12 카드 4장(앞 카드 병합 뒤 다음 · 전부 v1.6 PR 병합 뒤) · 두 라우트 → 한 위젯·공개 위젯 5 배선·`analyticsWhatIfApiProvider` 주입(operator = 실구현 · viewer = null) = 셸 R13.

---

## R. 🆕 계약 v1.7 (2026-10-20 · J-4 선행 M2 보강) — 사후 blind 리뷰(01 §8 미결 46)

`R3-Bob-J4` 카드 발송 전에 «Bob 이 추측해야 하는 자리»(점수 축·읽기 창구·결과 자리·픽스처)를 닫았다. `J-4` 는 **엔진이 고른 대기 카드 한 장을 고정해 그 카드 스트림만 보고 그린다**.
`contractVersion` = **`1.7.0`** · 픽스처 **141건**(135 + 신설 6 · 개정 0 — 기존 135 는 봉투 `contract_version` 한 줄만) · 라우트 **45 그대로** · 조문 = 01 §16.
상태 = ⬜ 로컬 커밋 — PR 대기(앱 브랜치 `m2/v17-blind-review` · 기준 origin/main `76c2404`).
결정 = 발주자 2026-10-20 — **K1~K24 전부 권고대로**(🔴 7건 K3 ⓐ~ⓓ · K6 · K7 · K8 · K18 · K23 · K24 포함 · 정본 = 설계 `10_리뷰/2026-10-19_미결46_계약v1.7_설계서.md` §9).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| R-1 | 🆕 타입 `BlindReviewChoice{int score, String label}` | `dto/journal.dart` · K1 — 선택지가 점수를 싣는다(구 `BlindReviewQuestion.choices: List<ReasonOption>` 의 코드 축 폐기) · 문항 O/X × 0/1(03_실행 §8-3) · 1~5 매핑·«좋은 결정» 판정 = 엔진 · 🔴 한 문항 안 `score` 유일(C-43 ①) · 화면은 고른 `score` 를 `answers[questionId]` 에 **옮길 뿐**(표시·합산·비교 0 — C-43 ⑫) |
| R-2 | 🆕 타입 `BlindReviewResult{processScoreText, outcomeText, detailLines, decisionLink?}` | `dto/journal.dart` · K5(전부 또는 없음 래퍼) · K6 확정(금액(원) 0 · 수익률·보유기간 문장 · `rm_blind_review` 결과 열은 채점 집행 뒤에만 push · 01 §6-4 5조 ⑤ 예외 1줄 · `S7-2G` 게이트·`recordDisclosureView` 없음 · X7 미이행 결정의 반사실 금액 0) · K8(앱 안 링크 = `decisionLink` 하나) |
| R-3 | `BlindReviewCard` +7 — `titleText` · `contextChips` · `deviation` · `journalStateLabel` · `journal?`(`DecisionJournalBody`) · `result?` · `asOf` | E-5 개정 · K9 · 🔴 `result == null` = 채점 전(대기 행은 늘 null) · `result`·`asOf` 밖 필드는 채점 전·후 같다(C-43 ④ · K18) · `journal`·`journalStateLabel` 은 큐에 들어온 뒤 바뀌지 않는다(K3 ⓓ) · `DecisionRef` 는 싣지 않는다(id 표시 길) |
| R-4 | `BlindReviewQuestion` +1 — `evidenceText?` · `choices` 형 교체 | E-5 개정 · 판단 근거 한 줄(03_실행 §8-3 «판정 근거» · null = 줄 부재) |
| R-5 | `JournalRepository.watchBlindReviewQueue({RunMode mode = RunMode.live})` → `Stream<ListResult<BlindReviewCard>>` · `watchBlindReviewCard(String decisionId)` → `Stream<BlindReviewCard>` | K2 · K16 · 대기 목록(봉투 · 빈 상태 = `emptyLabel` · 오래된 결정부터 — K4 · 같은 갱신에서 큐 이탈 = 엔진 의무 · 행 수 = 배지 n) + 고정 카드 1건(채점 집행 뒤 같은 스트림에 결과) · `J-4` 는 인자 없이(K24 — v1.7 = LIVE 만 · DRY_RUN 기간 = 빈 문장 · SIM = 미결 99) |
| R-6 | `BlindReviewScore` **주석만**(필드·JSON 무변경) | H-2 · «고른 `BlindReviewChoice.score` 를 그대로 옮긴 값» · 전 문항(K10 · 부분 제출 없음) |
| R-7 | 🆕 코드 `BlindReviewRejectCodes{alreadyScored = 'BLIND_REVIEW_ALREADY_SCORED', answersInvalid = 'BLIND_REVIEW_ANSWERS_INVALID'}` · 사전 키 `blind_review_reject` | `labels/journal_codes.dart` · K11 · K12(먼저 집행된 채점이 이긴다) · C-16 `domainByKind` +`blindReviewScore` · 문구 = `CommandReceipt.stateLabel` 하나 |
| R-8 | 받침대(`lib/testing.dart`) | `UnimplementedJournalRepository.watchBlindReviewQueue`·`watchBlindReviewCard`(동기 throw) — ui 테스트 0파일(가짜는 전부 `extends`) |
| R-9 | 픽스처 6 · `FixturePaths` 상수 6 | `m6BlindReviewQueue3` · `m6BlindReviewQueueEmpty` · `m6BlindReviewCardBefore` · `m6BlindReviewCardRevealed` · `m6BlindReviewCardRevealedOpen` · `m6BlindReviewReceipts6` · `FixturePaths.all` **141** · 등록부 코덱 +1(`BlindReviewCard`) · 생성 = `packages/domain_contracts/tool/gen_j4_v17_fixtures.py`(기준 `76c2404` 원문에서 멱등) · 🔴 K3 ⓓ — `JOURNAL_MISSING` 대상 `d_20260810_b_27`(설계서 초안 행 0)은 큐에 없다 · 큐 = `d_20260811_c_28` → `d_mf_0002` → `d_mf_0004`(설계서 §3-0 확정 표본) · 상세 = `fixtures/README.md` «계약 v1.7» |
| R-10 | 🆕 C-43 | `test/contracts/c43_blind_review_test.dart` — A 픽스처·DTO 불변식 ①~⑨ + B 화면 소스 스캔 ⑩~⑰(대상 = `packages/ui_journal/lib/src/blind_review.dart` + `lib/src/blind_review/**` · 대상 0 = 공허 통과) · C-16 «J-4 blind 리뷰 접수증» 1건 · C-8 `_knownUncovered` −2 |
| R-11 | **M2 이름**(카드가 짓지 않는다 · 셸 R13 이 배선) | 공개 위젯 `JournalBlindReview({super.key})`(인자 없음 · 본문만) · 파일 `packages/ui_journal/lib/src/blind_review.dart`(배럴 export 1줄) · 내부 `lib/src/blind_review/**` · 🆕 명령 주입 `journalBlindReviewCommandApiProvider = Provider<CommandApi>`(**`blind_review.dart` 안** — 배럴 쪽 · K13 · operator `journalCommandApiProvider` 무변경 · override 자리 = 조립 앱 `apps/app_*/lib`) · 데이터 `journalBlindReviewQueueProvider`(StreamProvider) · `journalBlindReviewCardProvider`(StreamProvider.family) · 재사용 `journalTimelineRepositoryProvider`·`journalSafetyStateProvider`·`journalLinkOpenerProvider`·`journalClockProvider` · 공통 조각 `JournalSafetyBanners({required SafetyState? safety})`(`journal_common.dart` 추가 · K17) · 라우트 `journalBlindReview` 그대로(단건 라우트 0 — K14) |

🔴 **만들지 않은 이름**(재론 방지): `answers: Map<String,String>`(선택지 코드 — H-2 페이로드 변경) · `BlindReviewQueueVm`(봉투 없는 큐 VM — «없음/모름» 구별 상실) · `BlindReviewRepository`(주입 1개 더 · 배지와 축이 갈린다) · `BlindReviewCard.decisionRef`·`tradeEntry`(id·가격·수량 글자가 따라온다) · `DecisionJournalBody` 의 결과 필드(C-34 ⑧) · `BlindReviewResult.answerLines`(경합 뒤 «기록된 답» — 미결 101) · `nextLink`(«다음 건» = 정적 라벨 · K15) · `noticeText`(고정 고지 = 정적 라벨) · 라우트 `aaq://journal/blind-review/:decisionId`(K14 · 재열람 = 미결 100) · outcome_score 입력 명령(K7 · 미결 98).

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 98(outcome_score 입력 · 2×2 배치 — 월간 F 의 기준 달 = 전월 리뷰분 · K3 ⓑ) · 99(SIM 결정의 blind 리뷰 — K24) · 100(공개 결과 재열람 · 미청산 카드의 뒤늦은 결과) · 101(경합 거부 뒤 선택 표시) · 102(X7 미이행 결정의 리뷰 표본 — K3 ⓒ 포함 확정 · v1.7 픽스처 0). 기존 확장 — 50 ③(`watchBlindReviewCard` 도 같은 잠정 규칙) · 59(`BLIND_REVIEW_SCORE` 는 사전을 먼저 만든 사례) · Q-D(웹 `J-4` = «부재» 가드).
엔진(06) 숙제(카드를 막지 않는다) — `rm_blind_review` 산출·push · 대상·진입 시점(K3 ⓐ~ⓓ) · 정렬(K4) · `processScoreText` 매핑 · 거부 코드 판정 · `LEDGER_INTEGRITY` 가림·결과 금액 0 · 큐에 든 카드의 본문·문맥 불변 · P2 알림 목적지(K23 — 리뷰 대기 ≥ 1 이면 `journalBlindReview` · 0 이면 `S7-1` · 엔진이 `deep_link` 로 고른다).

---

## S. 🆕 계약 v1.12 (2026-10-22 · R5·R13 선행 M2 보강) — X7 제출·세션 · X5 읽기 · 운영 리듬 · 알림 등급(01 §8 미결 52·113·114)

`R5a`~`R5e`(`L-1`·`L-2` · `A-1`·「지난 안내」 · `A-2`·`A-4` · `A-3` · `L-3`)·`R13a/b`(`S-01`·`S-02`·`H-02` · `H-01`) 카드 조립 전에 «Bob 이 추측해야
하는 자리»를 닫았다. `contractVersion` = **`1.12.0`** · 픽스처 **174건**(159 + 신설 15 · 개정 22 · 버전 줄만 137 — 🆕 검증 반영 · 설계서 목록 23 중 cooling 1 = 결과 버전 줄만) · 라우트 **48 → 52** · 조문 = 01 §21.
상태 = ⬜ 로컬 커밋 — PR 대기(앱 브랜치 `m2/v112-r5r13` · 기준 origin/main `f54f602`).
결정 = 발주자 2026-10-22 — 🔴 8건 K9·K14·K18·K30·K35·K36·K46·K47 **권고대로** · 나머지 K 40건 권고대로(정본 = 설계 `10_리뷰/2026-10-22_R5R13선행_계약v1.12_설계서.md` §3).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| S-1 | 라우트 교체 2 — `adviceFill = 'aaq://advice/fill/:adviceId'` · `ledgerSelfReport = 'aaq://ledger/self-report/:yyyyMm/:accountAlias'` | K2 · K7 · K36 ⓐ(한 실사 = 그 달 · 그 계좌 · 와이어 무변경) · 옛 꼴 = 미등록(픽스처 7곳 정정) |
| S-2 | 라우트 신설 4 — `adviceSkip`(`advice/skip/:adviceId`) · `ledgerDiffs`(`ledger/diffs`) · `ledgerRepairs`(`ledger/repairs` · 본문 Android 만) · `opsRhythm`(`ops/rhythm`) | K3 · K27 · K43 · `AppRoutes.all` **52** |
| S-3 | «화면 제출» DTO 3 — `ManualFillSubmission{adviceId?, input, retryCodes}` · `AdviceSkipSubmission{adviceId, input}` · `SelfReportSubmission{purpose, yyyyMm?, input, declaredComplete}` | `commands/payloads_x7.dart` · K4 · 셋 다 `fromJson` · 파싱·맥락·세션 시각 = `CommandApi` 구현 · 실패 = `INPUT_INVALID` 로컬 접수증 |
| S-4 | 와이어 `AdviceDeferConfirm{adviceId, context}` · `CommandKind.adviceDeferConfirm`(`DEFER_ADVICE_CONFIRM`) · `CommandApi.deferAdviceConfirm(String adviceId)` | K14 ⓐ · 만료 확인 카드 「내일 다시」 · 02:947 예외 1건 · 초안 영구 제외 7종 |
| S-5 | `CommandReceipt.retryCode`·`retryLabel` · 코드 `AdviceRetryCodes{offHourTrade, duplicateAck}`(`advice_retry`) | K20 · 재제출 선택지 · 제출 DTO `retryCodes` 누적 |
| S-6 | `AdviceRejectCodes` +3 — `inputInvalid`(`INPUT_INVALID`) · `selfReportOutsideSession`(`SELF_REPORT_OUTSIDE_SESSION`) · `deferAlreadyUsed`(`DEFER_ALREADY_USED`) = **18종** | K4 · K9 · K14 |
| S-7 | `watchCommand` 구현 의무 ④(서명 무변경) | K42 · 로컬 거부 id 도 종단 `rejected` 1값 |
| S-8 | `SettingsActionId.selfReportSessionStart`·`selfReportSessionStop`(`SELF_REPORT_SESSION_START`·`_STOP`) | K9 · `args` = `{yyyy_mm, account_alias}` · 가림 = 그 폰 한 대 · `L-3` `initState` start / `dispose` stop(잡아 둔 인스턴스) |
| S-9 | `SelfReportSession`(12키) · `SelfReportResult`(4키) · `LedgerTrustRepository.watchSelfReportSession(yyyyMm, accountAlias)` | `dto/ledger_trust.dart` · K8 · 🔴 `asOfTradeDate` 원값 VM 0 · 원장 현재값 0(앵커링) |
| S-10 | `AdviceItem` +7 — `detailDeepLink` · `sideLabel` · `expiredConfirmLabel` · `decisionLink` · `prefillQuantityText`·`prefillQuantityLabel` · `closeReasonLabel` | K5 · K13 · K16 · K18 · K19 · K39 |
| S-11 | `AdviceAction.deepLink` · `AdviceInboxSummary` +4(`cashNotice` · `overdueUnrecordedLink` · `manualEntryLink` · `manualEntryNoticeText`) | K5 · K13 · K15 · K17 · 🔴 엔진 액션 = RECORD·SKIP 만 · 뷰어 `actions` = [] |
| S-12 | `ManualFillFormSpec` +5(`sides` · `tradeDateOptions` · `skipNoticeText` · `blockedText` · `bannerText`) · 🆕 `SideOption{side, label}` · `TradeDateOption{date, label}` · `ReasonOption.deepLink` | K12 · K21 · K22 · K37 · 🔴 새 이름 쓰기 동사 접두 0(C-7 · G57 — `submitBlockedText` 아님) |
| S-13 | `ManualFillPrefillFields{quantity}`(`manual_fill_prefill`) · `AdviceSkipInput.fromReasonCode(String code)` | K19 · K12(이름 붙은 팩토리 = `fromJson` 과 같은 해독) |
| S-14 | `LedgerDiffRow` +8(`pairLabel` · `axisLabel` · `severityLabel` · `statusLabel` · `routeLabel` · `candidateOrigins` · `detectedAtText` · `actionLink`) · `LedgerRepairRow` +7(`appliedAtText` · `directionTone` · `originLabel` · `targetText` · `decisionLink` · `supersededLabel` · `chainStampText`) · `LedgerRepository.watchRepairs({limit})` | K24 · K25 · K26 · `watchOpenDiffs` 이름 유지 + 뜻 주석 |
| S-15 | `OpsSummaryRepository.watchRhythm()` · `OpsDailySummary.resumeLine` | K29 · K44 · 미결 113 ✅ · `H-02` «조치» 열 없음(K30) |
| S-16 | 받침대 +5 — `UnimplementedLedgerRepository` · `UnimplementedAdviceRepository` · `UnimplementedLedgerTrustRepository` · `UnimplementedOpsSummaryRepository` · `UnimplementedSettingsActions` | K28 · `testing.dart` |
| S-17 | 픽스처 신설 15 · `FixturePaths` +15 | `m6LedgerRepairs4`·`Empty` · `m6LedgerDiffsCashObserve` · `m6SelfReportDiffResult`·`SessionClosed`·`Receipts5` · `m6ManualFillReceipts7` · `m6AdviceSkipReceipts5`·`DeferReceipts3` · `m6FillFormSpecBlocked` · `m6SafetyAdviceBlocked` · `m6AdviceStale` · `m6AdviceFillsAd0005` · `m7LedgerTrustSelfAuditDue` · `m8OpsRhythmEmpty` · 생성 = `tool/gen_r5r13_v112_fixtures.py` |
| S-18 | 🆕 C-46 · C-47 | `test/contracts/c46_advice_x7_test.dart`(27) · `c47_ledger_ops_test.dart`(9) — 픽스처 불변식 + 화면 소스 스캔(대상 0 = 공허 통과) · 알림 등급 표(test-only · 정본 04_안전장치 §5-3) |
| S-19 | 골든 도우미(K48) | `ui_journal/test/golden/golden_support.dart` `extraFixture(relPath, key, fromJson)` · 🆕 `ui_shell/test/golden/golden_support.dart`(ui_journal 판 복사) |
| S-20 | **M2 이름 권고**(카드가 글자 그대로 싣고 Bob 이 만든다 · 설계서 §8-2) | 위젯 `LedgerDiffs()`·`LedgerDiffTile(row:)`·`LedgerRepairs()`·`AdviceInbox()`·`AdviceCard(item:)`·`AdviceHistory()`·`AdviceDetail(adviceId:)`·`ManualFillForm(adviceId:)`·`AdviceSkipForm(adviceId:)`·`SelfReportForm(yyyyMm:, accountAlias:)`·`OpsRhythm()` · 주입 `journalLedgerRepositoryProvider`·`journalLedgerTrustRepositoryProvider`·`journalAdviceRepositoryProvider`·`journalAdviceCommandApiProvider`(배럴 쪽)·`journalSettingsActionsProvider`(`self_report_form.dart`) · Key 접두 `l1-`·`l2-`·`a1-`·`ah-`·`a2-`·`a3-`·`a4-`·`l3-`·`s01-`·`h01-`·`h02-` |

🔴 **만들지 않은 이름**(재론 방지): `submitBlockedText`(C-7 쓰기 동사 접두) · `SelfReportSession.asOfTradeDate`(쓰지 않는 원값 = 미끼) · `accounts`(세션 계좌 = 라우트 고정 → `accountLabel`) · `OpsRhythmRow.actionText`(K30 열 삭제) · `Provider<CommandApi?>`(«주입 null 여부»로 버튼 판정 = 둘째 판정) · `rm_ops_rhythm`(19번째 표 — `rm_ops_summary` 확장) · `ledgerSelfReport` 의 `:purpose`(값 1개 · 계좌 축 미해소).

⏸ **이 창이 닫지 않은 것** — 01 §8 🆕 미결 115(`A-2` 정정 체인 접기·행 「정정」) · 116(`M5-6` 진입 맥락) · 117(`L-2` 필터 · 뷰어 원천 `rm_ledger_repair`) · 118(실사 주기 월/분기) · 119(X7 옛 라벨 · 미결 108 확장) · 120(`O-04` 의 `L-3` 폼 재사용) · 121(`J-2` 배지 → `L-2` · 저널 링크) · 122(`H-01` 블록 2 «항상») · 123(블록 9 물리 리스크) · 124(`L-1` 착지 단위) · 미결 52 ⑥(`M5-12` — M5 창).
엔진(06) 숙제(카드를 막지 않는다 · 설계서 §9-3 ①~⑩) — X7 제출 파싱·맥락·`INPUT_INVALID` · `watchCommand` ④ · 세션 start/stop·그 폰 가림 · 안내 VM(확인 카드 ≤3 · 엔진 정렬 · RECORD·SKIP · 뷰어 [] · 배치 결측 RECORD 만 · 링크·문장) · 폼 사양 선택지 · `ledger_diff`·`ledger_repair` 표시 필드 · `watchRhythm`·`resumeLine` · `SELF_AUDIT_*` 배지 링크 · 알림 등급 = 04_안전장치 §5-3 · 뷰어 `fillsOfAdvice` = [].

## T. 🆕 계약 v1.13 (2026-10-26 · R13b 선행 2 M2 보강) — 대조 보드 칸 레벨 · 전부 일치 표본 · 홈 참고 표본

R13b(`H-01` 운영 홈) 카드의 선행 2 를 닫았다. `contractVersion` = **`1.13.0`**(🔴 K1 — 이 보강이 먼저 병합 · 엔진 레인 E8a 는 1.14.0) · 픽스처 **176건**(174 + 신설 2 · 개정 1 · 버전 줄만 173) · 조문 = 01 §23.
상태 = ⬜ 로컬 커밋 — PR 대기(앱 브랜치 `m2/r13b-recon-ok` · 기준 origin/main `fc25f77` · 병합 = R13a 병합 뒤).
결정 = 발주자 2026-10-26 — R13b 확인 ①·⑭ · 🔴 K1·K2·K7 **권고대로** · 나머지 K 권고대로(정본 = 설계 `10_리뷰/2026-10-26_R13b선행_M2보강_설계메모.md` §3).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| T-1 | `DiagnosticCell.level`(`required UiLevel` · JSON `level` · 마지막 필드) | K2 · 칸 신호등 색·아이콘의 유일한 근거 · 새 열거 0(`AdviceInboxSummary.level`·`LedgerTrustBadge.level` 선례) · 엔진 의무 K3(해당 없음 ⇒ `info` · `blocked` = `canonBroker`·`canonSelfReport` 만) |
| T-2 | `DiagnosticsVm.headline` 규약 «늘 엔진 문장»(꼴 무변경 · 주석) | K4 · 전부 일치 날 = 일치를 말하는 문장 · 화면은 늘 그린다 |
| T-3 | `FixturePaths.m8ReconBoardOk`(`m8/recon_board_ok.json` · 한 줄 상수) · `FixturePaths.m8OpsHomeAdviceSuppressedDue`(`m8/ops_home_advice_suppressed_due.json`) | K5 · K7 ⓑ · R13b 카드 `__RECON_OK__` = `m8ReconBoardOk` · `__RECON_OK_GREP__` = `static const String m8ReconBoardOk =` |
| T-4 | 등록부 `opsHomeAdviceSummaryKey = 'advice_summary'`(test) · 🆕 `envelopeKeys` · `unboundSiblingKeys` · `unboundSiblingsOf`(test · 검증 반영) | K9 · m8 `ops_home_advice_*` 3벌 extras — C-1·C-8 이 요약을 연다 · C-1 형제 키 완전성(extras ∨ 사유 13키) |
| T-5 | C-47 ⑩ · ⑪ | K10 · 대조 보드(칸 키 6 · 레벨 원천 · `headline` 늘 · 전부 일치 · 🆕 칸 레벨 표본째 · state ⇔ level K3 ⓒ · `ledger_diffs_4` 대응) · R13b 홈 참고 표본(억제 + 기한 · 배분 notice 두 갈래 · 🆕 `dueTodayCount` 셈 · `headline` 고정 K8) |
| T-6 | 생성기 `tool/gen_r13b_v113_fixtures.py` | K11 · 기준 `fc25f77` 원문에서 멱등 |

🔴 **만들지 않은 이름**(재론 방지): `DiagnosticLevel`(새 열거 — `UiLevel` 재사용) · `String? headline`(nullable — 존재 판정이 화면으로 온다 · K4 대안 기각) · `m6/allocation_no_pot`(재사용 `m6/allocation_empty` 로 충분 · K7 ⓐ' 기각) · C-48(새 번호 — C-47 확장 · 같은 번호는 엔진 레인 E8a 가 쓴다).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 128(뷰어 홈 블록 6 원천 · 열린 채 · 05 `S10` VM 꼴 어긋남 함께) · 125·129·130·131 · 억제 + 기한 공존의 엔진 빈도(X7) · `UiLevel` → 아이콘 공용 사전(R13b 밖).

## U. 🆕 계약 v1.16 (2026-11-03 · R15 선행 M2 보강) — 온보딩 한 화면 VM 7 · 라우트 64 · args·결과 표본 · 슬롯 이름 · 페어링 창구 · X1 두 라우트

R15(`O-00`~`O-04` · `R-01` · `V-01`) 네 카드의 선행을 닫았다. `contractVersion` = **`1.16.0`**(엔진 다음 = 1.17.0) · 픽스처 **219건**(187 + 신설 32 · 개정 6 · 버전 줄만 181) · 조문 = 01 §25.
상태 = ✅ 병합 PR #96 squash `dd9e162`(2026-11-03 · CI 3/3 · 병합 전 `origin/main` `12f1aa4` 위로 rebase).
결정 = 발주자 2026-11-03 ①~④ 모두 권고대로(정본 = 설계 `10_리뷰/2026-11-03_R15선행_계약v1.16_설계서.md` §3 K1~K35).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| U-1 | `OnboardingStartVm{headline, tracks, viewerTrack?}` · `OnboardingTrackCard{track, title, estimatedText, deepLink?}` | `O-00` · 🆕 `dto/onboarding.dart` · 조회 갈래 = `viewerTrack`(null = 부재 · 분리 위젯) · 갈래 탭 = `deepLink` |
| U-2 | `OnboardingModeChoiceVm{headline, options, selected?, recordGapNotice, honestyText, nextDeepLink?, lockedLabel?}` | `O-00b` · K12 · 🔴 `selected` null = 안 고름(기본값 없음) · 카드 = 기존 `OperatingModeOption`(G-12 «같은 타입» 유지) · `OperatingModeView` 는 읽지 않는다 |
| U-3 | `OnboardingStepsVm{progressText, rows, emptyLabel?, finishDeepLink?}` · `OnboardingStepDetailVm{step?, missingLabel?, whereText?, howText?, verify?, secretSlotId?}` · `OnboardingAction{id, args, label}` | `O-01`·`O-02`·`O-03` · «어디서 받나» = `whereText` 글자만(결정 ②) · 검증 = `OnboardingAction` 이 id·args 를 완성 |
| U-4 | `OnboardingFinishVm{headline, stages, doneLabel?, checks}` · `OnboardingFinishStage{title, state, gate?, lines, expectationLine?, slotId?, link?, action?}` · `OnboardingFinishCheck{label, state}` | `O-04` 6단계 · ⑥ 시작 상태 선언 = `link`(`LinkAction` 재사용 · 결정 ③) |
| U-5 | `RestartVm{headline, loginSlotId?, ledgerLines?, leaseGate?, branches, inheritNotice?}` · `PairingVm{headline, scannerSlotId?, result?}` · `PairingResult{level, headline, reasonCode?, nextLink?}` | `R-01` · `V-01` · `PairingRepository.watchPairing()`(🆕 `repositories/pairing_repository.dart` · 뷰어 주입) |
| U-6 | `OnboardingRepository` += `watchStart` · `watchModeChoice` · `watchStepList` · `watchStep(String stepId)` · `watchFinish` · `watchRestart` | K29 · 추가형(`watchSteps` 무변경 · R15 미호출 · 01 §8 미결 149) |
| U-7 | `OnboardingStep` += `requirementLabel` · `warningLabel?` · `verifiedUntilText?` · `failureText?` · `gate?` · `detailDeepLink?` | K15 · 표시 칸 6 · `whereDeepLink` = 화면 미참조(K16 · 미결 150) |
| U-8 | `SettingsActionId.onboardingDryRunStart`(`ONBOARDING_DRY_RUN_START`) | K24 · `O-04` ⑥ 전용 · args `{}` · 첫 `committed_at` 과 같은 트랜잭션 · A-12 와 같은 «05 §7 밖» 값 |
| U-9 | 사전 `OnboardingResultCodes`(`onboarding_result`) · `BrokerRawCodes`(`broker_raw`) · `OnboardingSlotIds`(`onboarding_slot`) | K21 · 🆕 `labels/onboarding_codes.dart` · 코드 목록이지 문구 매핑이 아니다 |
| U-10 | 라우트 `onboardingStart` · `onboardingModePick` · `onboardingSteps` · `onboardingFinish` · `onboardingRestart` · `onboardingPairing` · `ledgerSimOpening` · `m5SimOpeningCash` · `x1MigrationPlan` · `x1MigrationEmergency` | K28·K3 · `AppRoutes.all` 54 → 64 · 온보딩 고정 6 = `onboardingStep` 앞 |
| U-11 | 받침대 `UnimplementedOnboardingRepository` · `UnimplementedPairingRepository`(`lib/testing.dart`) · 계약 테스트 C-50(`c50_onboarding_test.dart`) · 생성기 `tool/gen_r15_v116_fixtures.py` | K30(받침대) · K32(픽스처 · 기준 `267e867` 원문에서 멱등) |

🔴 **만들지 않은 이름**(재론 방지): `OperatingModeView.current` nullable(S05·표본 연쇄 · K12 대안 기각) · `OnboardingLinkAction`(새 타입 — `LinkAction` 재사용 · K9) · `link`·`next_link`(흉내 글자 — 실물 = `deepLink`·`nextDeepLink`) · `PairingResult.nextDeepLink`(실물 = `nextLink: LinkAction?`).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 149~158(`watchSteps` 존폐 · `whereDeepLink` 옛 뜻 · 검증 args 값 사전 · 슬롯 이름 확장 · `L-3` simOpening · M5 가상 초기금 · VM 산출 원천 · 뷰어 쪽 원천 · 브로커 원문 코드 범위 · 첫 실행 판정) · 플랫폼 몫(06 `M4-10`·`M4-11`·`M5-14`).

## V. 🆕 계약 v1.17 (2026-11-04 · R16 선행 M2 보강 + 엔진 E10 D11) — 장애 배너 · DR 런북 · 긴급정지 카드 · 핸드북 목차·페이지 · 기기 리스크 · 라우트 69

R16(`D-01`~`D-03` · `B-01` · `B-02` · `H-03`) 세 카드의 선행과 엔진 D11 4건(13 §8 R33 D11 · `contract_version.dart` 예약 몫)을 한 판으로 닫았다. `contractVersion` = **`1.17.0`**(엔진 다음 = 1.18.0) · 픽스처 **240건**(219 + 신설 21 · 개정 3 · 버전 줄만 216) · 조문 = 01 §26.
상태 = ✅ 병합 PR #123 squash `0249f61`(2026-11-05 · CI 3/3 · 밑동 `6eefc8a` · 병합 직전 `main` = 엔진 E13d1 `fea72c8` · 겹침 0 · 합친 트리 확인 뒤 squash).
결정 = 발주자 2026-11-04 ①~④ 모두 권고 + R16b ⑨ `HandbookPage.asOf?` 붙임(정본 = 설계 `10_리뷰/2026-11-04_R16선행_계약v1.17_설계서.md` §3 K1~K33).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| V-1 | `IncidentBanner{kind, level, title, bodyText, actionLink?}` · `IncidentBannerVm{banner?}` · enum `IncidentKind{phoneDown, networkDown, tokenExpired, orderRejected, other}` | `D-01` · 🆕 `dto/incident.dart` · `enums/incident.dart` · 최대 1건(고르기 = 엔진) · 종류 = 아이콘만 · 등급 = 색만(`ok` 없음) · 조치 = `actionLink`(JSON `action_link` — `action` 은 C-50 ⑨ walker 와 충돌) · 모르는 wire = `other` |
| V-2 | `RunbookIndexVm{rows, emptyLabel?}` · `RunbookRow{title, summaryText?, deepLink}` · `RunbookVm{title, introText?, steps, localCheckNotice, missingLabel?}` · `RunbookStep{orderText, text}` | `D-02` · 번호 = `orderText` 글자(비순번 «2-1.» 표본) · «확인» 체크 = 화면 로컬(고지 = `localCheckNotice`) · ⑥ 행 링크 = `opsEmergencyCard` |
| V-3 | `EmergencyCardVm{title, steps, contactLine, keepOnPaperNotice, printSlotId?}` · 사전 `OpsSlotIds.emergencyCardPrint`(`EMERGENCY_CARD_PRINT` · `ops_slot`) | `D-03` · 🆕 `labels/ops_codes.dart` · 인쇄·PDF = 플랫폼 슬롯(04 §2-1 금지 5 의 유일한 예외) · 계좌번호·앱키 0(C-14 · C-51 ⑤) |
| V-4 | `IncidentRepository{watchIncident()}` · `RunbookRepository{watchRunbookIndex() · watchRunbook(runbookId) · watchEmergencyCard()}` | 🆕 `repositories/incident_repository.dart` · 🆕 별 파일 `repositories/runbook_repository.dart`(K7) · 늘 값을 낸다(없음 = null · 모르는 id = `missingLabel`) |
| V-5 | 핸드북 추가형 — `HandbookIndex` += `outdatedNotice?` · `HandbookEntry` += `state` · `stateLabel?` · `deepLink?` · `children` · `HandbookPage` += `outdatedNotice?` · `missingLabel?` · `asOf?` · `HandbookBlock` += `live?` · 🆕 `HandbookLiveValue{label, level}` · enum `HandbookEntryState{ready, preparing, archived}` | `B-01`·`B-02` · K13~K15 · 뒤처짐 판정 = 엔진 글자(C-13 ⓐ · 04 §8 그림 16 정정) · `asOf` = live 블록이 있으면 non-null(결정 ④ ⑨) |
| V-6 | `HandbookRepository{watchIndex() · watchPage(anchor)}` | 🆕 `repositories/handbook_repository.dart` · K16 · 앵커 = `handbook://` 뒤 전부 · 별칭 해석 = 엔진 |
| V-7 | `DeviceRiskItem{label, currentText, thresholdText, actionText, lastCheckedText, level}` · `DeviceRiskVm{rows, guidanceText, emptyLabel?, asOf}` · `OpsStatusRepository` += `watchDeviceRisk()` | `H-03` · `dto/ops.dart` · K17 · 추가형(받침대 6 → 7) · 측정 = 플랫폼 · 판정 = 엔진 · 버튼 칸 0 |
| V-8 | 라우트 `opsRunbooks` · `opsRunbook`(`:runbookId`) · `opsEmergencyCard` · `opsDeviceRisk` · `handbookIndex`(`aaq://handbook`) | K18 · `AppRoutes.all` 64 → 69 · 전부 `opsRhythm` 뒤 · 셸 가드 기본 open(결정 ③) |
| V-9 | 엔진 D11 — `DecisionRef.brokerOrderNo`·`executionId` R31 주석 · `JournalStatus.expired`(`EXPIRED`) · `AlertCodes.staleOrdersHeld`(`STALE_ORDERS_HELD` · 잠정 P1) · `JournalReasonCodes{duplicateOrderPrevented, dayEndExpired}`(`journal_reason`) | K25~K28 · 01 §26-8 · 🔴 `JournalReasonCodes` 는 전수 아님(01 §8 미결 166) · 엔진 소비 = 06 변경 이력 «2026-11-04 · 계약 v1.17» |
| V-10 | 받침대 `UnimplementedIncidentRepository` · `UnimplementedRunbookRepository` · `UnimplementedHandbookRepository`(`lib/testing.dart`) · 계약 테스트 C-51(`c51_r16_incident_handbook_device_test.dart` · 14항) · 생성기 `tool/gen_r16_v117_fixtures.py` | K23 · K29(기준 `ea06df2` 원문에서 멱등) · K30 |
| V-11 | 셸 주입 이름(카드 몫 · 계약 밖) `shellIncidentRepositoryProvider`(기본 null) · `shellRunbookRepositoryProvider`(throw) · `shellOpsSlotBuilderProvider`(기본 null) · `shellHandbookRepositoryProvider`(기본 null) | K24 · 조립 앱 override 의무 = 06 `M4-12` |

🔴 **만들지 않은 이름**(재론 방지): `IncidentBanner.action`(C-50 ⑨ 충돌 — 실물 = `actionLink`) · 런북 창구를 `incident_repository.dart` 에 같이 두기(별 파일 — K7) · 화면이 `handbook://$anchor` 를 짓는 것(링크 = 데이터) · `RunbookStep` 실행 링크·슬롯 칸(01 §8 미결 161) · 1.17.0 을 엔진 단독 판으로 쓰기(D11 = 이 판 · D11 밖 «1.17.0 창» 몫 = 1.18.0).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 159~166(밀어 넣은 화면 위 배너 · 전역 슬롯 ① 게이트 · 단계별 실행 자리 · 핸드북 하위 앵커·접힘 · 뒤처짐 P1 코드 · R16 VM 산출 원천 · `incident_token_expired` 바인딩 · 일지 칩 사전 전수) · 123(H-01 블록 9 렌더) · 엔진 숙제(06 변경 이력 · 번호 1.18.0) · 조립 앱 몫(06 `M4-12`).

## W. 🆕 계약 v1.18 (2026-11-13 · R6 선행 M2 보강 + 엔진 등재형 7) — M9 설정 홈 · 연결 관리 · 라우트 80 · `ui_settings` 골든 받침 · 셸 «더보기»

R6a(`S01`)·R6b(`S07`) 두 카드의 선행과 엔진 등재형 7코드(13 §8 R55·R70 · `contract_version.dart` 예약 몫)를 한 판으로 닫았다. `contractVersion` = **`1.18.0`**(엔진 다음 = 1.19.0 · R6c `S05` `OperationsVm` 도 1.19.0) · 픽스처 **248건**(240 + 신설 8 · 개정 1 · 버전 줄만 239) · 조문 = 01 §27.
상태 = ✅ 병합 PR #142 squash `b582c49`(2026-11-13 · CI 3/3 · head `58eeed7` · 커밋 7 · 밑동 `47f8198`(E14c2) · 원격 가지 삭제).
결정 = 발주자 2026-11-13 Q1~Q4 모두 권고(정본 = 설계 `10_리뷰/2026-11-13_R6선행_계약v1.18_설계서.md` §3 · 통합 담당 기본값 K-a~K-l · 갈림 결론 K-m~K-z).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| W-1 | enum `SettingTier{general, operational, rule}` | 🆕 `enums/settings.dart` · `GENERAL`·`OPERATIONAL`·`RULE` · 자물쇠 아이콘·묶음 머리에만 · 등급 = 엔진 |
| W-2 | `SettingsHomeVm{statusChip, annualReviewLink?, groups, asOf}`(교체) · 🆕 `SettingsGroup{tier, label, cards}` · 🆕 `EngineStatusChip{label, level, promotionLabel?}` | `S01` · `dto/settings.dart` · 묶음 차례 = 엔진 · 연간 링크 = OPEN 만 · 칩 = DRY_RUN 글자 0 · 손익 0 · `isViewer` 칸 0(뷰어 판 = 엔진이 폰 전용 행을 뺀다) · K-o |
| W-3 | `SettingsCard` += `attentionText?` · − `actionAvailable` | 주의 = 글자(int 아님) · 카테고리 아이콘 사전 0(행 아이콘 = `level` — K-p) · 부재 = 목록에 없음(K-q) |
| W-4 | `SettingsRepository{watchHome()}` · 받침대 `UnimplementedSettingsRepository` | 🆕 `repositories/settings_repository.dart` · K-c · K-v · 뒤 카드가 추가형으로 늘린다 · `S07` = `OpsStatusRepository.watchConnections()` 그대로 |
| W-5 | `typedef SettingsActionCall = OnboardingAction` | `dto/settings.dart` · 엔진 완성 호출(`id` · `args` · `label`) · K-d |
| W-6 | `ConnectionsVm` += `lockedLabel?` · `ConnectionRow` += `detailLine?` · `level` · `actions`(기본 []) · `channelPicker?` · − `actionAvailable` | `S07` · `dto/ops.dart` · 짝 규칙(OK ⇔ ok · NOT_SET ⇒ info · FAILED ⇒ act/blocked · LAGGED ⇒ watch/act) · 잠기면 엔진이 동작 칸을 비운다(화면은 거르지 않는다) · K-r · K-t |
| W-7 | 🆕 `NotifyChannelCard{label, options, capabilityNotice, tokenBadgeText?, watchdogChannelLine}` · 🆕 `NotifyChannelOption{code, label, selected, selectAction?}` · `SettingsActionId.notifyChannelSelect`(`NOTIFY_CHANNEL_SELECT`) | 알림 채널 행에 붙음(`ConnectionRow.channelPicker` — 메모 권고 `ConnectionsVm.notifyChannel` 에서 바꿈 · K-n ⓐ) · args `{channel}` · 01 §8 미결 140 `S07` 몫 |
| W-8 | 사전 `ConnectionTargetCodes`(6 · `connection_target`) · `NotifyChannelCodes`(2 · `notify_channel`) · `SettingsResultCodes`(3 · `settings_result`) | 🆕 `labels/settings_codes.dart` · args `connectionTest`·`connectionSyncNow` = `{target}` · 01 §8 미결 151 `target` 몫 · K-u |
| W-9 | 라우트 11 `settingsHome`(`aaq://settings`) · `settingsAccounts` · `settingsAllocation` · `settingsOperations` · `settingsDevices` · `settingsConnections` · `settingsCalendar` · `settingsBackup` · `settingsDiagnostics` · `settingsGeneral` · `settingsAnnualReview`(`aaq://settings/annual-review`) | K-w · `AppRoutes.all` 69 → 80 · `settingsCredentials` 뒤 · 셸 가드 기본 open · 폰 전용 = 조립 앱 레지스트리(06 `M4-12` ⑤) |
| W-10 | 엔진 등재형 — `AlertCodes.safety`{`breakerStopped` · `ledgerIntegrityBroken` · `stoppedReleaseEligible`} · `AlertCodes.resume`{`resumeTradingHalted` · `resumeCompleted` · `resumeDataGap`}(25 → 31) · `JournalReasonCodes.leaseInvalid`(`LEASE_INVALID`) | K-z · 01 §27-8 · 엔진 lib 0줄 · `core_engine` test 1 hunk · 🔴 `leaseInvalid` ≠ `AdviceRejectCodes.leaseExpired`(다른 축) · 엔진 소비 = 01 §8 미결 171 |
| W-11 | 계약 테스트 C-52(`c52_r6_settings_connections_test.dart` · 13항) · 생성기 `tool/gen_r6_v118_fixtures.py` · 계약 밖 `ui_settings/test/golden/golden_support.dart`(`ui_shell` 판 복사) · 셸 «더보기» = `KeyedSubtree(s01-more-slot, ShellRouteBody(settingsHome))`(TS-10 2) | K-x · K-y · `ui_settings` 주입 이름(카드 몫) `settingsRepositoryProvider` · `settingsOpsStatusRepositoryProvider` · `settingsClockProvider` · `settingsLinkOpenerProvider` · `settingsActionsProvider`(`SettingsActions?` 기본 null = 뷰어) |

🔴 **만들지 않은 이름**(재론 방지): `ConnectionsVm.notifyChannel`(실물 = 행에 붙는 `ConnectionRow.channelPicker`) · `SettingsCard.actionAvailable`·`ConnectionRow.actionAvailable`(삭제 — 부재 = 목록에 없음 / 동작 목록 빔) · `SettingsHomeVm.isViewer`(뷰어 판 = 엔진이 행을 뺀다) · 카테고리 아이콘 사전(코드로 아이콘을 고르면 «코드로 분기 0» 위반) · `OperationsVm`(R6c · 1.19.0).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 167~171(S05 계약 = v1.19 · S01·S07 VM 산출 원천 · 운영 등급 생체 주체·세션 · S11·S12 카드 배정 · 엔진 등재형 소비) · 16 · 95 · 127 · 140(N-01 첫 진입 쪽) · 151(`credentialVerify.kind` = R7) · 엔진 숙제(06 변경 이력 «2026-11-13 · 계약 v1.18» · 번호 1.19.0) · 조립 앱 몫(06 `M4-12` ⑤).

## X. 🆕 계약 v1.19 (2026-11-14 · R6c 선행 M2 보강 + 엔진 E15i 굳은 몫) — M9 운용 관리 `OperationsVm` · 체험 카드 · 승격 동작 · E15i 등재형

R6c(`S05`) 카드의 선행과 엔진 E15i 가운데 엔진 lib 에 글자가 굳은 몫을 한 판으로 닫았다. `contractVersion` = **`1.19.0`**(엔진 다음 = **1.20.0** — E13i1 · E13i2 · E14i · fill-origin · F1~F8 · 알림 · 01 §8 미결 176) · 픽스처 **256건**(248 + 신설 8 · 개정 0 · 버전 줄만 248) · 라우트 80 그대로 · 조문 = 01 §28.
상태 = ✅ 병합 PR #163 squash `6b8ed02`(2026-11-14 · CI 3/3 · head `5f86e54` · 커밋 7 · 밑동 `175cbd5`(E15e2 #161) · 원격 가지 삭제).
결정 = 발주자 위임 2026-11-14 «v1.19 진행해줘» — K1~K27 권고대로(정본 = 설계 `10_리뷰/2026-11-14_R6c선행_계약v1.19_설계서.md` §3 · 이름표 정본 §4-11 #1~#21).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| X-1 | 🆕 `OperationsVm{statusChip, mode, operatingMode, trial?, ramp, jobs, control, updateGate?, lastRequestNotice?, lockedLabel?, asOf}` | `S05` · 🆕 `dto/operations.dart`(`dto.dart` export `onboarding` 뒤 · `ops` 앞) · `scope`·`HandoverPlan`·`contribution` 칸 0(K3) · 폰 전용 |
| X-2 | 🆕 `RunModeCard{label, level, holdLabel?, observation?, promotionAction?, switchNoticeText?, switchActions = []}` | runMode 축만 · 관찰 = `LiveDryRunObservationVm` 재사용 · 승격 버튼 = 관찰 중 ∧ 승격 가능일 때만 · hold «모의» 0 · K4 · K5 |
| X-3 | `OperatingModeView` += `switchActions`(기본 []) | `dto/handover.dart` · 운영 방식 전환 요청 버튼 · `options` 카드엔 버튼 0 · K8 |
| X-4 | 🆕 `SimTrialCard{headline, summaryText, checks}` · 🆕 `SimTrialCheck{itemCode, label, detailText, itemState, stateLabel, level}` | 체험 요약·5항목 · 짝 PASSED·AUTO_PASSED ⇒ ok · OPEN ⇒ watch · OPEN_WARN ⇒ info · `GateState`·`OnboardingFinishCheck` 안 씀 · K9 · K10 |
| X-5 | 🆕 `RampBoard{levelLabel, level, conditions = [], emptyLabel?, dstNoticeText?}` · 🆕 `RampCondition{label, progressText, level}` | 레벨 = 글자 · `RampLevel` 열거 미사용 · 엔진 발행 L1~L5 · `RampLevel.l0` 유지 + 주석 · K11 |
| X-6 | 🆕 `JobRow{label, scheduleText, lastRunText, statusCode, stateLabel, level, detailLine?}` | `statusCode` 화면 미참조 · `job_run.status` 4 + `NONE` · K12 |
| X-7 | 🆕 `EngineControl{stateLabel, level, startAction?, stopPromptText?, stopActions = []}` · 🆕 `UpdateGateCard{stateLabel, bodyText, level}` | 시작 xor 중지 · 킬스위치 칸 0 · 게이트 강행 칸 0 · K13 · K17 · 🔴 C-7 `updateGate` = 파일별 읽기 칸 허용(K27) |
| X-8 | `SettingsRepository` += `watchOperations()` | 받침대 같은 커밋 · 뷰어 원천 0(K20) |
| X-9 | 🆕 `SettingsActionId.runtimeLivePromotion`(`RUNTIME_LIVE_PROMOTION`) · S05 args 5 | `runtimeModeSwitchRequest = {run_mode}` · `runtimeOperatingModeSwitchRequest = {operating_mode}` · `runtimeEngineStart = {}` · `runtimeEngineStop = {reason_code}` · `runtimeLivePromotion = {}` · 🔴 키 `target` 금지 · K6 · K7 |
| X-10 | 🆕 `EngineStopReasonCodes`(2 잠정 · `engine_stop_reason`) · `SettingsResultCodes` += `ENGINE_ALREADY_RUNNING` · `ENGINE_ALREADY_STOPPED` | `labels/settings_codes.dart` · K14 · K16 · 값 확정 = 미결 173 |
| X-11 | 🆕 `labels/sim_codes.dart` — `SimTrialItemCodes`(5) · `SimTrialItemStateCodes`(4) · `LiveObservationBlockCodes`(4) · `LivePromotionResultCodes`(5) · `ModeStartupCodes`(2) · `SimOpeningResultCodes`(10) · `DecisionReasonCodes.livePromotion`(`LIVE_EXECUTE_PROMOTION`) | 엔진 E15i · E15e2 #161 글자 1:1 · `byDomain` +7 · K15 · K21 · 엔진 소비 = 미결 177 |
| X-12 | `SafetyState` += `holds`(기본 [] · ⊆ `SafetyHoldCodes`) | 엔진 `ModeStartupGate.holds` 파생 · 기동 거부 ≠ hold · K21 |
| X-13 | 계약 테스트 C-53(`c53_r6c_operations_test.dart` · 15항) · 생성기 `tool/gen_r6c_v119_fixtures.py` · 표본 `m9/operations_*` 8 | C-52 ⑨ 좁힘 · c08 `_knownUncovered` − `LiveDryRunObservationVm` · docs 사본 = PR 커밋(K24) |

🔴 **만들지 않은 이름**(재론 방지): `OperationsVm.contribution`(R6 Q4 «칸만» → 칸 0 · 월 납입 = R8 별도 화면) · `OperationsVm.scope`·`HandoverPlan` 칸 · 체험 카드용 `GateState` 짝(R87 AB11 · `unknown` = 진행 차단과 충돌) · 승격 `LinkAction`(위저드 7단계 종착 = 관찰 — 승격은 위저드 안에 없다) · `EngineControl` 킬스위치 칸 · `UpdateGateCard` 강행 칸 · 단일 모드 토글(→ 칩 2 + 전환 «요청» 버튼).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 168(넓힘 — `OperationsVm` 산출 원천) · 169 · 172(램프 조건 원천) · 173(엔진 시작·중지 원천 · 중지 사유 값) · 174(업데이트 게이트 · 지난 요청 원천) · 175 · 176(계약 1.20.0 창) · 177(E15i 등재형 소비) · 28(관찰 일수 값 = 발주자) · 엔진 숙제(06 변경 이력 «2026-11-14 · 계약 v1.19» · 번호 1.20.0) · 조립 앱 몫(06 `M4-12` ⑥).

## Y. 🆕 계약 v1.20 (2026-11-15 · R7 선행 M2 보강 + 엔진 겹침 몫) — M9 증권사 키 `S02` · 기기·접근 `S06` · 계좌 매핑 `S03` · 라우트 81

R7a(`S02`)·R7b(`S06`)·R7c(`S03`) 세 카드의 선행과 엔진 겹침 몫(`CredentialKindCodes` · 온보딩 표본 `KIS_PAPER`)을 한 판으로 닫았다. `contractVersion` = **`1.20.0`**(엔진 다음 = **1.21.0** — E15i 코드 등재 모음 · E13i1 · E13i2 · E14i · E16i · F1~F8 · 알림 · 01 §8 미결 176 · 창 = R7a 병합 뒤 · R7b 발송 전) · 픽스처 **271건**(256 + 신설 15 · 개정 1 · 버전 줄만 255) · 라우트 80 → **81** · 조문 = 01 §29.
상태 = ✅ 병합 PR #187 squash `52f2fc9`(2026-11-15 · CI 3/3 · head `7ecfb64` · 커밋 8 · 밑동 `7320c92` · 원격 가지 삭제).
결정 = 발주자 위임 2026-11-14 — K1~K39 권고대로(정본 = 설계 `10_리뷰/2026-11-15_R7선행_계약v1.20_설계서.md` §3 · 이름표 정본 §4-11 #1~#20 · #21 = 1.21.0 예약).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| Y-1 | `CredentialListVm` += `modeNotice?` · `leakRunbookLink?` · `lockedLabel?` · `asOf` | `S02` · `dto/settings.dart` 추가형 · cards ≥ 1 · `emptyLabel` 칸 0(K29) |
| Y-2 | `CredentialCardVm` += `level` · `lastVerifiedText?` · `requirementLabel?` · `whyLine?` · `sealLabel?` · `credentialSlotId?` · `verifyAction?` · `rotateLink?` | 키 조각 칸 0(K7) · `registerAction` 칸 0(검증 1단 — K6) · `alias`·`kind`·`healthCode`·`usage` 화면 미참조(K11 · K30) |
| Y-3 | `DeviceAccessVm` += `leaseLevel` · `leaseEpochText?` · `migrationLink?` · `pairing?` · `emptyLabel?` · `lockedLabel?` · `DeviceRow` += `level` · `revokeAction?` · `revokeConfirmText?` | `S06` · `dto/ops.dart` 추가형 · 창구 = 기존 `OpsStatusRepository.watchDeviceAccess()`(K14) · 리스 편집 칸 0 · 폐기 확인 = 화면 안 펼침(K18) · `deviceId` 화면 미참조 |
| Y-4 | 🆕 `PairingTicketCard{headline, issueAction?, qrSlotId?, expiresText?}` | `dto/ops.dart` · 잠김 밖 발급 XOR QR · QR ⇔ 유효 시각 · 카운트다운·페이로드 0 · QR = 슬롯 `PAIRING_QR_DISPLAY`(K15) |
| Y-5 | 🆕 `AccountMappingVm{accounts, mappings, verifyAction?, lockedLabel?, asOf}` · 🆕 `AccountRow{label, kindLabel, maskedNumberText, checkText?, badgeText?, level}` · 🆕 `SleeveMappingRow{sleeveLabel, accountLabel?, subbookLine?, statusLine?, level, options}` | `S03` · 🆕 `dto/accounts.dart`(`dto.dart` export 맨 앞) · 칸 수 = 받은 `mappings`(POT 행 0 — K20) · 번호 = 엔진 마스킹 글자 · 종류 코드·별칭·전체번호 칸 0(K19 · K21) |
| Y-6 | 🆕 `AccountMappingOption{label, selected, impacts = [], blockedText?, selectAction?}` | 🔵 **K39** — 이름표 초안 «`AccountOption`» 은 v1.12 `dto/advice.dart` `AccountOption{alias, label}`(`ManualFillFormSpec`)과 배럴 export 가 겹친다(`ambiguous_export`) → `AccountMappingOption`(칸·JSON 키 그대로 · freezed 내부 이름 `_AccountMappingOption`) · 미리 판정(SAF-309 = `blockedText`) · 원자 저장 |
| Y-7 | `SettingsRepository` += `watchCredentials()` · `watchAccountMapping()` | 받침대 `UnimplementedSettingsRepository` 같은 커밋 · 폰 전용 |
| Y-8 | 🆕 `CredentialKindCodes`(`credential_kind` · `KIS_LIVE` · `KIS_ISA` · `KIS_PAPER` · `KIS_RECONCILE`) | `labels/settings_codes.dart` · 엔진 `KisKeySet.wire` 와 같은 글자 · **엔진 겹침 몫**(K8) · 온보딩 표본 `KIS_MOCK` → `KIS_PAPER`(슬롯 이름 `SECRET_KIS_MOCK` 그대로) |
| Y-9 | 🆕 `SettingsSlotIds`(`settings_slot` · `SECRET_KIS_LIVE` · `SECRET_KIS_ISA` · `SECRET_KIS_RECONCILE` · `PAIRING_QR_DISPLAY`) | 모의 = `OnboardingSlotIds.secretKisMock` 재사용 · JSON 키 `credential_slot_id` · `qr_slot_id`(K9 · K31 — `secret_slot_id` 는 C-5 · C-50 ⑮ 가 온보딩 사전으로 고정) |
| Y-10 | `SettingsResultCodes` += `WRONG_KEY_SET` · `MAPPING_VERIFY_FAILED` · `DEVICE_ALREADY_REVOKED` | K13 · `S02` 거절 = `OnboardingResultCodes.credentialRejected`(`CREDENTIAL_REJECTED` 한 벌 — K32) · 결과 `handoffRoute`·`retryable` 0(K33) |
| Y-11 | R7 args 5 | `credentialVerify = {kind}` · `devicePairingTicketCreate = {}` · `deviceTokenRevoke = {device_id}` · `accountMapSleeve = {sleeve, account_alias}` · `accountVerifyMapping = {}` · `credentialRegister` 화면 미호출 · 시크릿 값 args 0 · `SettingsActionId` 값 0 추가 |
| Y-12 | 🆕 `AppRoutes.m4KeyRotation` = `aaq://m4/key-rotation` | 🔒 06 `M4-4` 키 회전 마법사 · `AppRoutes.all` 81 · Claude 소유 묶음 머리(`handoverStatus` 뒤) · 파라미터 0 · 본문 = 조립 앱 빈 자리(K12 · K37) |
| Y-13 | 계약 테스트 C-54(`c54_r7_credentials_devices_accounts_test.dart` · 19항) · 생성기 `tool/gen_r7_v120_fixtures.py` · 표본 `m9/credential*` 5 · `m9/device*` 6 · `m9/account_mapping*` 4 | 등록부 코덱 3 · 바인딩 15 · C-5 · C-6 · C-8 `_knownUncovered` − 4 · C-33 ③ 81 · docs 사본 = PR 커밋(K38 ⓑ) |

🔴 **만들지 않은 이름**(재론 방지): `CredentialListVm.emptyLabel`·`AccountMappingVm.emptyLabel`(K29 — 카드·행 ≥ 1) · 키 조각 칸(«앞4…뒤4» = 조립 앱 `SecretField` 안 — K7) · `CredentialCardVm.registerAction`(검증 통과 = 저장 — K6) · `CREDENTIAL_VERIFY_FAILED`(→ `CREDENTIAL_REJECTED` 한 벌 — K32) · 앱 잠금 on/off 칸·`SettingsActionId`(K17 · 미결 179) · S03 선택지 이름 `AccountOption`(→ `AccountMappingOption` — K39) · M9 슬롯 JSON 키 `secret_slot_id`(→ `credential_slot_id` · `qr_slot_id` — K31) · QR 페이로드·카운트다운 칸(K15).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 178(S02·S03·S06 VM 산출 원천 · `KisKeySet` += 3 · POT 같이 쓰기) · 179(앱 잠금) · 180(증권사 밖 시크릿) · 181(매핑 = 지문 파급) · 182(QR TTL — 발주자) · 176(계약 1.21.0 창) · 13 · 152 · 168 · 169 · 엔진 숙제(06 변경 이력 «2026-11-15 · 계약 v1.20» · 13 의 «1.20.0» 줄 → 1.21.0) · 조립 앱 몫(06 `M4-12` ⑦ · 슬롯 빌더 override · `m4KeyRotation` 빈 자리).

## Z. 🆕 계약 v1.21 (2026-11-15 · 엔진 예고 1/2 — M5 안전 쓰기 포트 + 체험 길) — `SafetyActions` 넷째 창구 · 킬스위치 기록·재개 · 서약 · 게이지 · 라우트 84

엔진 예고 덩어리의 첫 절반(12-18 소비 몫 — 체험 ⑤ 킬스위치 연습 M5-1/M5-2 · `O-04` ② 서약 + 그것이 서는 포트)을 한 판으로 닫았다. `contractVersion` = **`1.21.0`**(다음 = **1.22.0** — E13 나머지 · 사다리 · E14i · E15i 남은 몫 · fill-origin · `resume_mode` · F8 · 창 = R7b 병합 뒤 · R7c 발송 전 · **1.23.0+** = 굳는 대로).
상태 = ✅ 병합 PR #189 squash `81bf79c`(2026-11-16 · CI 3/3 · head `735470fc` · 커밋 8 · R7a 병합 PR #197 `18d241b` 뒤 rebase · 원격 가지 삭제).
결정 = 발주자 위임 2026-11-14 — K1~K47 권고대로(정본 = 설계 `10_리뷰/2026-11-15_계약v1.21_설계서.md` §3 · 이름표 정본 §4-13 #1~#16 · #17 = 1.22.0 예약 · #18 = 1.23.0+).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| Z-1 | 🆕 `SafetyActions{run(SafetyActionId, {args}) · runKillResumeItem(KillResumeItemSubmission) · runPledge(PledgeSubmission) · watch(actionRunId)}` | `commands/safety_actions.dart` · 넷째 쓰기 창구 · 폰 전용 · 뷰어 null = 부재 · `ui_safety` 만 참조(C-55 ⑯) · 생체 = 구현 · 표면 넷 = C-7 · 이름 `run…`(K31) |
| Z-2 | 🆕 `SafetyActionId{killSwitchResume, pledgeWrite, pledgeEdit}` | `enums/command.dart` · 와이어 `KILL_SWITCH_RESUME` · `PLEDGE_WRITE` · `PLEDGE_EDIT`(엔진 명령 kind 글자) · `run` 화이트리스트 0(1.22.0 · K39) · 같은 글자 다른 축 주석 2 |
| Z-3 | 🆕 `SafetyActionResult{actionRunId, id, level, headline, reasonCode?, handoffRoute?, retryable}` · 🆕 `SafetyActionCall{id, args, label}` | `ActionResult` 꼴(`id` 타입만 다름) · 호출 = 1.21.0 사용처 0(C-8 `_knownUncovered` · K47) |
| Z-4 | 🆕 `KillResumeItemSubmission{itemNo, text?, emotion?, intensity?, sleepHours?, scenario?, condition?, acknowledged, rationaleBefore?, expectedOutcome?, ruleCited?}` · 🆕 `PledgeSubmission{SafetyActionId id, sentences, decisionId?}` | 엔진 `ResumeItemAnswer` − `decisionId`(K34) · 숫자 2 = 원문 String(K35) · 한 문항씩 · 7번 통과 = 해제 확정(K36) · `PledgeSubmitKind` 0(K32) |
| Z-5 | 🆕 `KillActivationRecord{ruleAction, reasonKind, emotion?, intensity?, sleepHours?, scenarioId?, scenarioNone, resumeCondition, scope, journalDecisionId}` · `KillChecklistAck += activation` | `commands/payloads_x7.dart` · 추가형 · 기본 null · 한 명령 `KILL_CHECKLIST_CONFIRM` · 경로 = 기존 `confirmKillChecklist`(인자 교체 = 미결 183 · K9 · K43) |
| Z-6 | 🆕 `KillActivationReason` · `KillActivationScope` · `KillResumeScenario` · `KillResumeCondition` | `enums/safety.dart` · 값 이름 = 엔진 1:1 · 와이어 = SCREAMING_SNAKE · 🔵 타입 이름 ≠ 엔진(`KillReasonKind` 등 — 같으면 엔진 시험 2파일 `ambiguous_import` · K33) |
| Z-7 | 🆕 `KillSwitchResultCodes`(12) · `SafetyCommonResultCodes`(2) · `PledgeResultCodes`(6) · `GaugeCodes`(4) | `labels/safety_codes.dart` · 도메인 `kill_switch_result` · `safety_common_result` · `pledge_result` · `gauge` · 엔진 글자 1:1 · 새 글자 24 · 중복 0(K12 · K13 · K45) · 게이지 검사 = C-55 ⑭(K41) |
| Z-8 | 🆕 `KillResumeGateVm{readinessLabel, level, etaText?, cooldown?, items, nextItemNo?, blockedText?, lockedLabel?, asOf}` · `KillResumeItemRow{itemNo, label, replayText?, answeredText?, level, choices}` · 🆕 `KillResumeChoice{label, scenario?, condition?}` | `dto/safety_gate.dart` · 문항 글자 = SPEC v2.40 04 §3-6 «재개판»(K38) · `replayText` = 발동 때 답(K37) · 카운트다운 0 · 해제 버튼 0 |
| Z-9 | 🆕 `PledgeVm{lines, statusLine?, replayNotice?, editable, lockedLabel?, asOf}` | `dto/safety_gate.dart` · `lines` 0 또는 3 · 엔진 글자 없는 칸 = 표본 null(K16 · 미결 185) |
| Z-10 | 🆕 `KillSwitchGateRepository.watchResumeGate()` · 🆕 `PledgeRepository.watchPledge()` | 받침대 3(`UnimplementedKillSwitchGateRepository` · `UnimplementedPledgeRepository` · `UnimplementedSafetyActions`) · 기존 `SafetyRepository` · `ResumeRepository` 무변경(K6) |
| Z-11 | 🆕 `AppRoutes.m5StoppedDecision` · `m5Pledge` · `m5RuleChangeGate` | `aaq://m5/stopped-decision`(M5-3) · `aaq://m5/pledge`(M5-8) · `aaq://m5/rule-change-gate`(M5-9 · R8 `S04` «적용» 목적지) · `AppRoutes.all` 81 → **84** · `ownedByClaude` 17 · 본문 = 레지스트리 빈 자리(K14 · K44) |
| Z-12 | 계약 테스트 C-55(`c55_safety_actions_kill_pledge_test.dart` · 19항) · C-7 +1 · C-16 정정 · 생성기 `tool/gen_v121_fixtures.py` · 표본 `m5/` 12 + F3 | 271 → **283** · 등록부 코덱 3 · 바인딩 12 · C-6 +12 · C-8 `_knownUncovered` +4 · C-33 84 · `domain_contracts` +485 → +505 ~30 |

🔴 **만들지 않은 이름**(재론 방지): `submitKillResumeItem` · `submitPledge`(C-7 쓰기 이름 검사 — K31) · `PledgeSubmitKind`(값 `write(` 가 C-7 맨 쓰기 동사 검사에 걸림 — K32) · 엔진과 같은 열거 타입 이름(K33) · `KillResumeItemSubmission.decisionId`(K34) · 기존 `SafetyRepository`·`ResumeRepository` 넓히기(K6) · `CommandApi` 해제 명령 · 카운트다운 칸 · 해제 버튼 칸.

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 183(M5-1 발동 뒤 기록 화면 입력 원천 — 1.22.0 판단) · 184(재개 게이트 세부 · 7문항 엔진 상수화) · 185(서약 편집 저널 id · 서약 VM 엔진 글자) · 93(남은 것 `S7-7` 링크) · 169 · 176(1.22.0 / 1.23.0+) · 엔진 숙제(`GaugeCodes` 지역 선언 지움 = 병합 뒤 첫 단계 · SPEC ⑦ 대조 1 · 7문항 상수화).

## AA. 🆕 계약 v1.22 (2026-11-17 · 엔진 예고 2/2 — M5 나머지 + X2 재개 + simToAuto + DDL 글자) — `SafetyActions` 표면 8 · 사다리 · 재개 게이트 · simToAuto 사전 · fill-origin 계약 글자 · 미결 183 ⓐ

엔진 예고 덩어리의 둘째 절반(E13 나머지 · 사다리 · E14i 재개 게이트 · E15i 남은 굳은 몫 · fill-origin 계약 글자 · `resume_mode` · F8 · 미결 183 ⓐ)을 한 판으로 닫았다. `contractVersion` = **`1.22.0`**(다음 = **1.23.0+** — E16i · VM 3 · 이름 없는 알림 · 승격 세션 종류 · PNG 묶음 · 미결 186~188 · `RuleChangeCategory` · 굳는 대로).
상태 = ✅ 병합 PR #214 squash `67630bc`(2026-11-17 · CI 3/3 · head `7b145703` · 커밋 10 = 구현 8 + 감사 반영 2 · 가지 `m2/v122-rest` · R7b 병합 뒤 · R7c 발송 전 · 원격 가지 삭제).
결정 = 발주자 위임 2026-11-14 — K48~K73 권고대로(정본 = 설계 `10_리뷰/2026-11-17_계약v1.22_설계서.md` §3 · 이름표 정본 §4-15 #1~#24 · #24 = 1.23.0+ 예약 · K72 · K73 = 구현 감사 §10).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AA-1 | `SafetyActionId` += `stoppedDecision` · `postmortemRecord` · `reconClear` · `interventionStep` · `discretionAdjust` · `ruleChangeCancel` · `ruleChangeApprove` · `seasonalWindowChoice` | `enums/command.dart` · 와이어 = 엔진 명령·저널 kind 글자(`postmortemRecord` = `INCIDENT_POSTMORTEM`) · `RECON_CLEAR` ≠ `DeviationKindCodes.reconClear`(축 다름 주석) |
| AA-2 | `SafetyActions` += `runStoppedDecision` · `runPostmortem` · `runRuleChangeApproval` · `runDiscretionAdjust` | 표면 **8**(C-7) · 이름 `run…`(쓰기 동사 0 · v1.21 K31 결) · K7 이 v1.21 K39 를 이김(K52) |
| AA-3 | 🆕 `StoppedDecisionSubmission` · `PostmortemSubmission` · `RuleChangeApprovalSubmission` · `DiscretionAdjustSubmission` | `commands/safety_actions.dart` · 엔진 Answers 1:1 − 구현이 짓는 id(K53) · `deltaPct` = 원문 String |
| AA-4 | 🆕 `StoppedDecisionChoice` · `InterventionStepOutcome` · `SeasonalEntryChoice` | 🔵 **K49 이름 나눔** — 엔진 `StoppedDecisionKind` · `InterventionOutcome` · `SeasonalWindowChoice` 와 **다른 타입 이름**(같으면 ds lib `resume_job` · `seasonal_a_job` + 시험 5 `ambiguous_import`) · 값 이름·와이어 = 엔진 1:1 · 엔진이 계약 참조로 옮길 때 자기 선언을 지운다 |
| AA-5 | 🆕 `ResumeItemReasonCodes`(`resume_reason` 15) | 🔵 K49 — 엔진 `ResumeReasonCodes` 와 이름 다름 · `labels/verdict_codes.dart` · 같은 곳 `SeasonalChoiceResultCodes` 4 · `PlannedWorkRejectCodes` 6 |
| AA-6 | 🆕 `StoppedDecisionResultCodes` 7 · `PostmortemResultCodes` 3 · `InterventionResultCodes` 6 · `RuleChangeResultCodes` 11 · `DiscretionResultCodes` 3 | `labels/safety_codes.dart` · RECON 해제 = 사전 0(K55) |
| AA-7 | 🆕 `SimToAutoResultCodes.windowBlocked` · `SimToAutoCommitResultCodes.outcomeUnknown` | 🔵 **K51** — 상수 이름 = C-7 쓰기 이름 검사 회피(`commitWindow` 이면 `sim_codes.dart` 가 «쓰기 이름 파일») · 값 `SIM_TO_AUTO_COMMIT_WINDOW` · `SIM_TO_AUTO_COMMIT_UNKNOWN` · 그 밖 상수 = 엔진 이름 · 같은 파일 `HandoverSessionResultCodes` 2 · `SimToAutoStepIds` 7 |
| AA-8 | 🆕 `BreakerLadderVm` · `BreakerLadderRow` · `BreakerLadderRepository.watchLadder()` | `dto/safety_gate.dart` · `repositories/breaker_ladder_repository.dart` · 글자 = 엔진 `breakerLadderOf` 출력 그대로(K65) |
| AA-9 | 🆕 `ResumeGateVm` · `ResumeGateRow` · `ResumeGateRepository.watchGate()` | `dto/resume.dart` · `repositories/resume_gate_repository.dart` · 계절 3택 = 행마다(K64) · 기존 `ResumeRepository` 무변경 |
| AA-10 | `SettingsActionId` += `handoverSessionStart` · `handoverSessionCancel` · `handoverSimLedgerFate` | M5-11 handover 가족(K56) · `OPEN` 이름 0(거부 코드 `HANDOVER_SESSION_OPEN` 과 겹침 회피) · 🔴 `SimLedgerFate` 계약 열거 0(K49 걸림 · 값 = 엔진 `wire` 2) |
| AA-11 | 🆕 `ModeMarkerText{sim, advisory, osSimPrefix, osAdvisoryPrefix}` | 🔵 **K73** — 자리 = `lib/src/mode_marker_text.dart`(labels 밖 단독 파일 · 배럴 export 한 줄 · 사전 아님 → C-5 예외 0 · 선례 `contract_version.dart`) · K67 의 `labels/sim_codes.dart` 정정 · 이름·글자 무변경 |
| AA-12 | 🆕 `KillChecklistSubmission` · `CommandApi.confirmKillChecklist(KillChecklistSubmission)` | `commands/payloads_x7.dart` · 13칸 원문 · 인자 교체(미결 183 ⓐ · K60 · v1.15 K12 선례) |
| AA-13 | 🆕 `LedgerModeCheck.fillOrigin` · 추가형 `PlannedWorkKindCodes.monthlyPlan`·`carryOver` · `DecisionReasonCodes.simLedgerKeep`·`simLedgerDiscard` · `BrokerRawCodes.simInvalidOrder`·`simOrderNotFound`·`simCancelTooLate` · `GapReasonCodes.simBarMissing` | fill-origin 태그 줄 = 엔진 재생성 PR(K61 · 미결 189) · DDL `resume_run_mirror.resume_mode`(K62) |
| AA-14 | 계약 테스트 C-56(`c56_e13_resume_sim_test.dart` · 18항) · C-7 표면 8 · C-15 축 +2 · 생성기 `tool/gen_v122_fixtures.py` · 표본 `m5/` 8 · `x2/` 6 · `m6/` 1 + 개정 2 | 283 → **298** · `domain_contracts` +505 → +524 ~30 · 손글 lib 코드 543(K72 — 크기 선 판정 = 코드 줄 · 덜어 낸 것 0) |

🔴 **만들지 않은 이름**(재론 방지): 엔진과 같은 타입 이름 4(`StoppedDecisionKind` · `InterventionOutcome` · `SeasonalWindowChoice` · `ResumeReasonCodes` — K49) · `RuleChangeType`(K50 — 들일 때 `RuleChangeCategory`) · `SimLedgerFate` 계약 열거(K56) · `commitWindow` · `commitUnknown` 꼴 상수 이름(K51) · `HandoverSessionOpen` 동작 이름(K56) · RECON 해제 결과 사전(K55) · 계절 args `decision_id`(K54) · `LIVE_OPENING` 결정 사유(K57) · `labels/` 안 `ModeMarkerText` · C-5 예외 집합 `_textConstantClasses`(K73).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 186(M5-1 폼 문항 글자 · 🔴 12-04 전 창) · 187(M5-11 위저드 읽기 창구) · 188(E13 제출 DTO 의 엔진 값 원천 VM) · 189(fill-origin 태그 줄 = 엔진 재생성 PR · 🔴 v1 동결 12-21 전) · 184 · 185 · 176(1.23.0+) · 엔진 숙제(06 변경 이력 «2026-11-17 · 계약 v1.22 병합» — 로컬 상수 → 계약 참조 · operator `SafetyActions` 표면 8 · `confirmKillChecklist` 인자 교체 소비).

## AB. 🆕 계약 v1.23 (2026-11-17 · R8a 선행 — M9 `S13` 월 납입 설정 + v1.21 K45) — 투영 창구 `watchContribution` · 원문 제출 `ContributionUpdateSubmission` · 결과 사전 `ContributionResultCodes` · 표본 7

R8 🔀 2분할(K74)의 첫 장 R8a(`S13`)가 읽는 이름만 한 판으로 닫았다(`S04` = 엔진·발주자 결정 대기 — 01 §8 미결 190~194). `contractVersion` = **`1.23.0`**(다음 = **1.24.0** — S04 창 또는 엔진 예약(E16i · VM 3 · 이름 없는 알림 · 승격 세션 종류 · PNG 묶음 · 미결 186~188 · `RuleChangeCategory`) 중 먼저 굳는 쪽).
상태 = ✅ 병합 PR #227 squash `e3e8f7a`(2026-11-17 · CI 3/3 · head `b8f92037` · 커밋 6 = 구현 5 + 감사 보강 1 · 가지 `m2/v123-r8a` · 🏁 R7 뒤 · R8a 발송 전 · 원격 가지 삭제).
결정 = 발주자 위임 2026-11-14 — K74~K103 권고대로(정본 = 설계 `10_리뷰/2026-11-17_R8선행_계약v1.23_설계서.md` §3 · 이름표 정본 §4-11 #1~#10).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AB-1 | `MonthlyContributionVm` += `asOf` · `lockedLabel?` · `changeLabel?` | `dto/settings.dart` · 추가형(기존 7 칸 뒤 · K79) · `changeLabel` null = 입력칸·버튼 부재 · 잠김 ⇒ `changeLabel` null · `editable` = 🔴 ui 미참조 표식(== `changeLabel != null` · 지우지 않음) · G-11 |
| AB-2 | `SettingsRepository.watchContribution()` | `repositories/settings_repository.dart` · `S13` 투영 창구 · 값의 원천 = 엔진 `contributionSettingOf` 하나 · `ConfigRepository.watchContributionSetting()`(S7-4·H-02) 그대로 · 주입 +0(K78) · C-10 |
| AB-3 | 🆕 `ContributionUpdateSubmission{amountInput}` | `commands/settings_actions.dart` 끝(K103) · JSON `amount_input` · 사람이 친 원문 그대로(파싱·범위 판정 = 엔진 · K77) |
| AB-4 | `SettingsActions.runContributionUpdate(ContributionUpdateSubmission)` | 표면 **3**(`run` · `runContributionUpdate` · `watch` — C-7 · v1.22 K52 선례) · 이름 `run…`(쓰기 동사 0) · `run(settingsContributionUpdate)` = 구현 `ArgumentError` · 결과 id = `settingsContributionUpdate` · `handoffRoute` null · `retryable` false · A-13 |
| AB-5 | 🆕 `ContributionResultCodes`(`contribution_result` 6) | `labels/settings_codes.dart` 끝(K103) · `blank` · `negative` · `notNumber` · `overMax` · `clockNotAdvanced` · `unchanged` · 🔵 **K80 이름 나눔** — 엔진 `ContributionRejectCodes` 와 **다른 타입 이름**(같으면 엔진 시험 2가 두 배럴을 함께 import → `ambiguous_import`) · 값 = 엔진 1:1 − 공용 `TRUSTED_TIME_UNKNOWN`(`SafetyCommonResultCodes` 한 벌 · v1.21 K45) · 결과 `reasonCode` 전집 = 6 ∪ {`TRUSTED_TIME_UNKNOWN`, `BIOMETRIC_UNAVAILABLE`} ∪ null |
| AB-6 | 받침대 `UnimplementedSettingsRepository.watchContribution`(동기 throw) · `UnimplementedSettingsActions.runContributionUpdate`(`Future` 에러) | `lib/testing.dart` +2 · 🔴 lib import 금지 |
| AB-7 | 🔴 apps stub 2 — `OperatorSettingsRepository.watchContribution` = `_none` · `OperatorSettingsActions.runContributionUpdate` = `UnsupportedError` | 🔵 **K100** — apps 0줄 꼴 없음(op 가 `implements` → 메서드 추가 = 컴파일 깨짐 · 기본 몸통 · `extends Unimplemented…` · 새 인터페이스 · mixin 넷 다 기각) · 행동 0(`S13` = operator 레지스트리에 아직 없음) · 바인딩 = 06 `M4-12` ⑧(미결 195 · E11p 레인) |
| AB-8 | 계약 테스트 C-57(`c57_r8a_monthly_contribution_test.dart` · 13항) · C-7 SettingsActions 표면 셋 · C-8 · C-6 +7 · 생성기 `tool/gen_r8_v123_fixtures.py` · 표본 `m9/` 7 | 298 → **305** · 금액 글자 = 10만원 · 0원 · 10억원만(K99 · «9만» = C-32 ⑥ 폐기값) · `domain_contracts` +524 → +537 ~30 · 변이 23/23 + 감사 3 |

🔴 **만들지 않은 이름**(재론 방지): 엔진과 같은 타입 이름 `ContributionRejectCodes`(K80) · `save…`·`submit…` 꼴 메서드(C-7 · K79) · 새 인터페이스 `ContributionRepository`·`ContributionActions`(K100) · 원값·범위·회차 VM 칸(C-57 ①) · `run` 화이트리스트 금액 args(«화면이 args 키를 짓는» 예외 0 · K77) · S04 이름 전부(`Allocation…` 잠정 — 설계서 §9-2 · 확정 = S04 창).

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 190~194(S04 · 엔진·발주자 결정) · 195(`S13` 쓰기 바인딩 · 조립 E11p · 06 `M4-12` ⑧ · 🔴 E11k 전 = 형식 맞는 입력 전부 `TRUSTED_TIME_UNKNOWN`) · 186~188 · 176(1.24.0+) · 엔진 숙제(06 변경 이력 «2026-11-17 · 계약 v1.23 병합» — 지역 `ContributionRejectCodes` → 계약 참조 · 접수 문장·레벨 · VM 글자 정본 대조 시험 · 낡은 주석 2).

## AC. 🆕 계약 v1.24 (2026-11-18 · R9 선행 — M9 `S09` 백업·복원 · `S10` 진단 · `S12` 연간 리뷰 목차 + E16i 중 R9 결과 무리 · 무결성 사유 7) — `BackupVm` 교체 · 감싸개 · 목차 · 결과 사전 2 · 표본 17

R9 🔀 3분할(K104)의 세 장(R9a `S09` · R9b `S10` · R9c `S12`)이 읽는 이름을 한 판으로 닫았다(`S08` = ⏸ R9d · E17 · `S11` = ⏸ R9e · 엔진 원천 뒤). `contractVersion` = **`1.24.0`**(다음 = **1.25.0** — E16i 나머지 + E16j · S04 창 · E13i2 · 이름 없는 알림 · 승격 · PNG F1~F7 · 미결 186~188 · `RuleChangeCategory` 중 먼저 굳는 쪽).
상태 = ✅ 병합 PR #235 squash `bbed5ef`(2026-11-18 · CI 3/3 · head `e164769d` · 커밋 6 · 가지 `m2/v124-r9`(원격 삭제) · R8a 병합 PR #236 `9af1e8a` 뒤 rebase(충돌 0 · 옛 head `6990e311` · K109)).
결정 = 발주자 위임 2026-11-14 — K104~K143 권고대로(정본 = 설계 `10_리뷰/2026-11-18_R9선행_계약v1.24_설계서.md` §3 · 이름표 정본 §4-9 #1~#12).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AC-1 | `BackupVm` 교체(10 칸) · 🆕 `RestorePointRow` | `dto/ops.dart` · 소비자 0 에서 교체(v1.18 선례) · 복원 버튼 0 · 크기·경로 칸 0 · G-9 |
| AC-2 | 🆕 `DiagnosticsScreenVm` · `SelfTestCard` | `dto/ops.dart` · 감싸개 한 스트림 · `board` = `DiagnosticsVm` 무변경(H-01 과 같은 값) · G-10 |
| AC-3 | 🆕 `AnnualReviewIndexVm` | `dto/ops.dart` · 목차 전용 · 세후·수치·`lines` 칸 0 · `AnnualReviewVm` 무변경(S7-7) · F-6 |
| AC-4 | 🆕 `SettingsRepository.watchDiagnosticsScreen()` · `OpsStatusRepository.watchAnnualReview()` 반환 교체 | 이름 그대로(C-42 `_windowMethods`) · `watchBackup` 타입 이름 그대로 · H-8 |
| AC-5 | 🆕 `BackupResultCodes`(`backup_result` 8) · `LedgerIntegrityResultCodes`(`ledger_integrity_result` 7) | `labels/settings_codes.dart` 끝 · 🔵 이름 ≠ 엔진(`SnapshotCodes` · `RestoreReason` · `LedgerIntegrityReason` — `ambiguous_import` 회피) · `take` 경로 전수(K132) |
| AC-6 | 받침대 `UnimplementedSettingsRepository.watchDiagnosticsScreen`(동기 throw) · `UnimplementedOpsStatusRepository.watchAnnualReview` 반환 교체 | `lib/testing.dart` |
| AC-7 | 🔴 apps stub — `OperatorSettingsRepository.watchDiagnosticsScreen` = `_none` · `OperatorOpsStatusRepository.watchAnnualReview` 타입 2줄 | 행동 0 · 바인딩 = 06 `M4-12` ⑨(E11p 레인) |
| AC-8 | 계약 테스트 C-58(16항) · C-42 ⑫ 주석·사유 · C-5 중복 +2 · C-8 − `BackupVm` · C-6 +17 · 생성기 `tool/gen_r9_v124_fixtures.py` · 표본 `m9/` 17 | 305 → **322** · `domain_contracts` 537 → 553 ~30 |

🔴 **만들지 않은 이름**(재론 방지): 엔진과 같은 타입 이름 `SnapshotCodes` · `RestoreReason` · `LedgerIntegrityReason` · `SelfTestVm`(05 옛 잠정명과 뜻이 달라 grep 이 섞임 — K113) · `IntegrityVm` · `blocking` · `entriesEmptyLabel`(K139) · 복원 지점 행 동작 칸.

⏸ **이 창이 닫지 않은 것** — 01 §8 미결 196(S08 · E17) · 197(S11 원천) · 198(골든 실행기 결과 꼴 · E11o) · 199(백업 원천 묶음·바인딩 · 아카이브 IN_SYNC) · 200(무결성 실행 바인딩) · 201(O-04 ④ 슬롯 위젯) · 202(S12 엔진 생산).

## AD. 🆕 계약 v1.25 (2026-11-19 · 트랙 B 선행 — 모의 체험 ④ X2 재개 · ⑤ 킬스위치 필수 화면) — M5-1 화면·폼 VM · M5-5 보드 · X2 리포트 감싸개 · 발동 인자 0 · 슬롯 1 · 표본 17

다섯 경로(`m5KillSwitch` · `m5ReleaseGate` · `m5BlockBoard` · `x2ResumeReport` · `x2ResumeGate`)가 읽는 이름을 한 판으로 닫았다(재개 게이트 둘 = v1.21 · v1.22 그대로). `contractVersion` = **`1.25.0`**(다음 = 1.26.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #256 squash `233adda8`(2026-11-19 · CI 3/3 · head `fe4cd71f` · 커밋 4 · 가지 `m2/v125-trackb`(원격 삭제) · #255·#257 뒤 rebase 없이 — 겹침 0). 결정 = 발주자 위임 2026-11-14 — K144~K165 권고대로(정본 = 설계 `10_리뷰/2026-11-19_트랙B선행_계약v1.25_설계서.md` §3 · §4).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AD-1 | 🆕 `KillSwitchScreenVm` · `KillCancelRow` | `dto/safety_gate.dart` · `M5-1` 한 화면 · 발동 버튼 = 꺼짐만 · 🔴 잠김에도 발동 · 취소 보고 = 엔진 wire 코드 + 글자 |
| AD-2 | 🆕 `KillActivationFormVm` · `KillActivationItemRow` · `KillActivationChoice` | `dto/safety_gate.dart` · 발동 뒤 기록 폼(미결 186) · SPEC 카드 ④ (가) 원문 7 · 2·5 선택지 · 6·7 고정 글자 · 확인 라벨 4 |
| AD-3 | 🆕 `BlockBoardVm` · `BlockBoardRow` | `dto/safety_gate.dart` · `M5-5` 보드 · 사다리(M5-4)·게이지(M5-7) 감싸기 · 킬스위치 진입 늘 |
| AD-4 | 🆕 `ResumeReportVm` | `dto/resume.dart` · X2 리포트 감싸개(원판 + 시각·단계·빈 문장) |
| AD-5 | `KillSwitchGateRepository.watchKillSwitch()` · 🆕 `BlockBoardRepository.watchBoard()` · `ResumeGateRepository.watchReport()` | 받침대만 구현 — 기존 `SafetyRepository`·`BreakerLadderRepository`·`ResumeRepository` 무변경 |
| AD-6 | `CommandApi.activateKillSwitch()` | 인자 0(구 `{reasonFreeText, deviceId}`) · 기기·채널 = 구현 `CommandContext` |
| AD-7 | 🆕 `KillCancelOutcomeCodes`(`kill_cancel_outcome` 5) · `OpsSlotIds.killSwitch` | `labels/safety_codes.dart` 끝 · `labels/ops_codes.dart` |

## AE. 🆕 계약 v1.26 (2026-11-20 · 트랙 C 선행 — 실전 커밋 필수 3묶음) — M5-11 위저드 VM · M5-9 SAF-405 첫 승인 최소판 · M5-5 RECON 해제 · 사전 저널 꼴 · 표본 20

세 경로(`m5HandoverWizard`(+ `handoverStatus` 같은 본문) · `m5RuleChangeGate` · `m5BlockBoard` RECON 행)가 읽고 쓰는 이름을 한 판으로 닫았다. `contractVersion` = **`1.26.0`**(다음 = 1.27.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #270 squash `09d3580d`(2026-11-20 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K166~K186 권고대로(정본 = 설계 `10_리뷰/2026-11-20_트랙C선행_계약v1.26_설계서.md` · 01 §35). 🔴 엔진 이름과 겹치지 않는다(`SimToAutoReport` · `RuleChangeQueueItem` · `ReconClearance` 등 피함 — `ambiguous_import` · K49 결).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AE-1 | 🆕 `HandoverWizardVm` · `HandoverWizardStepRow` | `dto/handover.dart` · `M5-11` 한 화면 · 엔진 7단계(`HandoverStep` 무변경) 감싸기 · 행 `level` = 색의 유일한 근거 · 동작 = 기존 `SettingsActionId`(단계별 허용 표 K169) · 세션 id = 엔진이 args 에 |
| AE-2 | 🆕 `HandoverRepository.watchWizard()` | `repositories/handover_repository.dart` · 폰 전용 · `ui_safety` 만 · `handoverStatus` = 같은 스트림 |
| AE-3 | 🆕 `RuleChangeGateVm` · `RuleChangeCandidateRow` · `RuleChangeQueueRow` | `dto/safety_gate.dart` · `M5-9` 첫 승인 최소판(후보 = 엔진 · 유형·해시 자기 신고 0 · 큐 취소 = `run(ruleChangeCancel)`) |
| AE-4 | 🆕 `RuleChangeGateRepository.watchGate()` | `repositories/rule_change_gate_repository.dart` · 냉각이 끝나면 새 VM(카운트다운 0) |
| AE-5 | 🆕 `RuleChangeRequestSubmission` · `SafetyActions.runRuleChangeRequest` · `SafetyActionId.ruleChangeRequest` | `commands/safety_actions.dart` · `enums/command.dart` · 사람 글 5칸 원문 · `decision_id` = 구현 |
| AE-6 | 🆕 `ReconClearForm` · `ReconOriginChoice` · `BlockBoardRow.reconClear` | `dto/safety_gate.dart` · RECON 행만 · 선택지 ⊆ `OriginCodes.writable` |
| AE-7 | 🆕 `ReconClearSubmission` · `SafetyActions.runReconClear` · 🆕 `ReconClearResultCodes`(`recon_clear_result` 3) | `commands/safety_actions.dart` · `labels/safety_codes.dart` 끝 · `run(reconClear)` = 화이트리스트 밖 · 사전 = 엔진 예고 |


## AF. 🆕 계약 v1.27 (2026-11-20 · E3d 계약 창) — 엔진 등재 대기 알림 5 등재 · 표본 1

엔진이 이미 내던 «등재 대기 제안» 알림 다섯의 이름을 계약에 닫았다(`kAlertLevels` 표 밖 0). `contractVersion` = **`1.27.0`**(다음 = 1.28.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #274 squash `551282e0`(2026-11-20 · CI 3/3). 정본 = 01 §36 · 설계서 `10_리뷰/2026-11-20_E3d계약창_계약v1.27_설계서.md`.

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AF-1 | 🆕 `AlertCodes.safetyWarn`{`defensiveFloorBreached` · `goldShareHigh` · `financialIncomeCapExceeded` · `krwLiquidityLow`} | `labels/alert_codes.dart` · SAF-302 · 308 · 306 · 307 부속(04 §1 Level 3 · §5-3 v2.46) · 등급 = 주석 «잠정»만 · 엔진 상수 글자 = 계약 글자 |
| AF-2 | 🆕 `AlertCodes.derivedSync`{`derivedFork`} | `labels/alert_codes.dart` · 파생 FORK(04 §5-3 v2.45) · E16i 의 알림 몫 |
| AF-3 | 🆕 `FixturePaths.m8AlertsEngineProposalsV127` | `fixtures/m8/alerts_engine_proposals_v127.json` · 알림 목록 봉투 5행 |

## AG. 🆕 계약 v1.28 (2026-11-20 · S04 첫 판 — M9 배분 화면 보기 전용) — VM 4 · 창구 1 · 행 코드 사전 · 뷰어 열 이름 · 표본 2

`settingsAllocation`(S04) 첫 판이 읽는 이름을 닫았다. `contractVersion` = **`1.28.0`**(다음 = 1.29.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #282 squash `9c7ff349`(2026-11-20 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K196~K207 권고대로(정본 = 설계 `10_리뷰/2026-11-20_S04첫판_계약v1.28_설계서.md` · 01 §37). 🔴 엔진 이름(`AllocationView` · `AllocationViewCard` · `AllocationViewRow` · `AllocationViewSection` · `AllocationViewRowCodes` · `RmConfigViewAllocationColumns`)과 겹치지 않는다(`ambiguous_import` · K80).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AG-1 | 🆕 `AllocationEditorVm` | `dto/allocation.dart` · S04 한 화면(M2-8 예약 이름 · 첫 판 = 보기 칸만 · 편집 칸 = 편집기 판 추가형) |
| AG-2 | 🆕 `AllocationProfileCard` · `AllocationReadOnlySection` · `AllocationReadOnlyRow` | 같은 파일 · 카드 4칸 · 묶음 · 행(`code` = 화면 미참조 · Key = 순번) |
| AG-3 | `SettingsRepository.watchAllocationEditor()` | 폰 · 뷰어 공통 · 못 읽으면 스트림 오류(K206) |
| AG-4 | 🆕 `AllocationRowCodes`(`allocation_row` 10) | `labels/allocation_codes.dart` · 엔진 글자 1:1 |
| AG-5 | 🆕 `AllocationReadModelColumns`(7) | `schema/read_model_columns.dart` · `rm_config_view` 배분 열 · 01 §6-4 |
| AG-6 | 🆕 `FixturePaths.m9AllocationEditor` · `m9AllocationEditorStale` | `fixtures/m9/allocation_editor*.json` |

## AH. 🆕 계약 v1.29 (2026-11-20 · E11k-b 계약 창 — o_07 Supabase 연결 · 신뢰 시각 · operator 리스) — 슬롯 1 · 사전 3 · RPC 이름 3무리 · 표본 2

`contractVersion` = **`1.29.0`**(다음 = 1.30.0 · E16i 사전). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #288 squash `b979ae33`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K223~K236 권고대로(정본 = 설계 `10_리뷰/2026-11-20_E11k계약창_계약v1.29_설계서.md` · 01 §39). 🔴 엔진 이름(data_sync `SupabaseInputProblem` · `SupabaseTimeFailure` · core `kLeaseInvalidCode`)과 겹치지 않는다(`ambiguous_import` · K80).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AH-1 | 🆕 `OnboardingSlotIds.supabaseConnect`(`SECRET_SUPABASE_CONNECT`) | `labels/onboarding_codes.dart` · o_07 ② 주소 + 공개 키 슬롯(조립 앱 · `secretSlotId` 자리) |
| AH-2 | 🆕 `SupabaseInputResultCodes`(`supabase_input_result` 6) · `SupabaseTimeResultCodes`(`supabase_time_result` 8) | `labels/supabase_codes.dart` · `connectionTest{SUPABASE}` 결과 · 기준점 실패 |
| AH-3 | 🆕 `LeaseRpcResultCodes`(`lease_rpc_result` 5) | 같은 파일 · 리스 RPC 거부 |
| AH-4 | 🆕 `LeaseRpcNames` · `LeaseRpcParams` · `LeaseRpcColumns` | `schema/supabase_rpc.dart` · 01 §6-4 리스 RPC 표 |
| AH-5 | 🆕 `FixturePaths.m8OnboardingStepDetailSupabase` · `m8OnboardingSupabaseConnectResults` | `fixtures/m8/onboarding_*supabase*.json` |
## AI. 🆕 계약 v1.30 (2026-11-20 · E16i 계약 창 — X1 기기 이전 · X5 정정) — 엔진 글자 사전 25무리 · 103 · 표시 hold 1

엔진(E16b~E16t3a)이 «계약 등재 = E16i 전 문자열»로 쓰던 글자를 사전에 올렸다. `contractVersion` = **`1.30.0`**(다음 = 1.31.0 · 첫 후보 = E16j 화면 계약). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #293 squash `2fdfefb5`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K209~K222 권고대로(정본 = 설계 `10_리뷰/2026-11-20_E16i계약창_계약v1.30_설계서.md` · 01 §38). 🔴 엔진 이름 26(core `MigrationStartCodes` · `PlanBlockCodes` · `SnapshotCodes` · `RestoreReason` · `FencingCodes` · `ReissueCodes` · `ReissueItem` · `RecoverySealCodes` · `MigrationGateCodes` · `PlanStep` · `MigrationStepState` · `MigrationKind` · `MigrationRole` · `RecoveryStep` · `MigrationGateState` · `GapViolationKind` · `WindowEvent` · `RepairCodes` · `BaselineCodes` · `BoundaryReason` · `DerivedRelation` · ds `MigrationStoreCodes` · `MigrationBootCodes` · `RecoveryCodes` · `WindowStoreCodes` · `LedgerRestoreCodes`)과 겹치지 않는다(`ambiguous_import` · K80).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AI-1 | 🆕 `X1StartResultCodes` · `X1StepBlockCodes` · `X1JournalResultCodes` · `X1BootRefusalCodes` | `labels/migration_codes.dart` · 이전 시작 · 단계 막음 · 저널 · 기동 거부 |
| AI-2 | 🆕 `X1RestoreResultCodes` | 새 폰 복원 거부 중 v1.24 에 없던 3(전집 = ∪ `BackupResultCodes` 여섯) |
| AI-3 | 🆕 `X1FencingResultCodes` · `X1ReissueResultCodes` · `X1ReissueItemCodes` | 비상 펜싱 · 재발급 거부 · 재발급 항목 6(`ordered`) |
| AI-4 | 🆕 `X1RecoveryResultCodes` · `X1OrderSealCodes` · `X1GateReasonCodes` · `X1IntentReasonCodes` | 새 폰 복구 · 주문 봉인 · 재개 게이트 막음 · 복구 의도 표지 |
| AI-5 | 🆕 `MaintenanceWindowResultCodes` · `MaintenanceWindowEventCodes` | 감시 유지보수 창 거부 · 사건 |
| AI-6 | 🆕 `X1StepCodes`(`ordered` 9) · `X1StepStateCodes` · `X1KindCodes` · `X1RoleCodes` · `X1RecoveryStepCodes`(`ordered` 5) · `X1GateStateCodes` · `X1GapViolationCodes` | X1 열거 글자(저장 값) |
| AI-7 | 🆕 `RepairResultCodes` · `BaselineResultCodes` · `LedgerBoundaryReasonCodes` · `DerivedRelationCodes` | `labels/repair_codes.dart` · X5 정정 · 새 기준점 · 경계 사유 · 파생 관계 |
| AI-8 | 🆕 `SafetyHoldCodes.migrationInProgress` | `labels/flag_ids.dart` · `MIGRATION_IN_PROGRESS` 표시 hold(막는 정본 = 리스) |

## AJ. 🆕 계약 v1.31 (2026-11-21 · E11k-d2 계약 창 — o_07 ③ Supabase 로그인) — 슬롯 1 · 동작 1 · 인증 사전 1 · 표본 2

`contractVersion` = **`1.31.0`**(다음 = 1.32.0 · 첫 후보 = E16j 화면 계약). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #298 squash `922df462`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K237~K246 권고대로(정본 = 설계 `10_리뷰/2026-11-21_E11k-d2계약창_계약v1.31_설계서.md` · 01 §40). 🔴 엔진 이름(data_sync `SupabaseAuth` · `SupabaseAuthFailure`)과 겹치지 않는다(K80).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AJ-1 | 🆕 `OnboardingSlotIds.supabaseLogin`(`SECRET_SUPABASE_LOGIN`) | `labels/onboarding_codes.dart` · o_07 ③ 이메일 + 비밀번호 슬롯(조립 앱 · ② 통과 뒤 같은 단계) |
| AJ-2 | 🆕 `SettingsActionId.supabaseSignIn`(`SUPABASE_SIGN_IN`) | `enums/command.dart` · args `{}` · 1단 |
| AJ-3 | 🆕 `SupabaseAuthResultCodes`(`supabase_auth_result` 6) | `labels/supabase_codes.dart` · 인증 고유 실패 · 전송 = `SupabaseTimeResultCodes` |
| AJ-4 | 🆕 `FixturePaths.m8OnboardingStepDetailSupabaseLogin` · `m8OnboardingSupabaseSigninResults` | `fixtures/m8/onboarding_*supabase*.json` |

## AK. 🆕 계약 v1.32 (2026-11-21 · E16j-a 계약 창 — X5 정정 마법사) — VM 5 · 창구 1 · 제출 3 · 동작 4 · 라우트 1 · 사전 1 · 표본 8

`contractVersion` = **`1.32.0`**(다음 = 1.33.0 · 첫 후보 = E16j-b X1). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #299 squash `268d6bff`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K247~K263 권고대로(정본 = 설계 `10_리뷰/2026-11-21_E16j-a계약창_계약v1.32_설계서.md` · 01 §41). 🔴 엔진 이름(core `RepairChoice` · `RepairCodes` · `BaselineCodes` · `InterventionStep` · `InterventionOutcome` · ds `BaselineStoreCodes` · `BaselineResult` · `FillRestatement`)과 겹치지 않는다(K80 · C-66 ⑪ · data_sync 대조 시험).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AK-1 | 🆕 `RepairWizardVm` · `RepairOriginChoice` · `RepairStageRow` · `RepairCorrectionForm` · `RepairFillChoice` | `dto/repair.dart` · X5 정정 마법사 허브 · 대상 공용 |
| AK-2 | 🆕 `RepairWizardRepository.watchRepair({targetId})` | `repositories/repair_wizard_repository.dart` · 폰 전용 · `ui_safety` 만 |
| AK-3 | 🆕 `SafetyActions.runRepairCorrect` · `runRepairBaseline` · `runInterventionJournal` + `RepairCorrectSubmission` · `RepairBaselineSubmission` · `InterventionJournalSubmission` | `commands/safety_actions.dart` · 사람 수 · 글 = 제출 DTO(K7) |
| AK-4 | 🆕 `SafetyActionId.repairAccept`(`REPAIR_ACCEPT` · `run{diff_id}`) · `repairCorrect` · `repairBaseline` · `interventionJournal` | `enums/command.dart` |
| AK-5 | 🆕 `AppRoutes.x5RepairTarget`(`aaq://x5/repair-wizard/:targetId`) | `navigation/app_links.dart` · `all` 85 |
| AK-6 | 🆕 `BaselineApplyResultCodes`(`baseline_apply_result` 1) | `labels/repair_codes.dart` · ds `BaselineStoreCodes` 와 다른 이름 |
| AK-7 | 🆕 `FixturePaths.x5Repair*` 8 | `fixtures/x5/repair_*.json` |

## AL. 🆕 계약 v1.33 (2026-11-21 · E16j-b 계약 창 — X1 기기 이전 화면) — VM 2 · 행 1 · 카드 5 · 창구 1 · 동작 6 · 슬롯 사전 1 · 표본 15

`contractVersion` = **`1.33.0`**(다음 = 1.34.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #305 squash `ec203163`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K264~K281 권고대로(정본 = 설계 `10_리뷰/2026-11-21_E16j-b계약창_계약v1.33_설계서.md` · 01 §42). 🔴 엔진 이름(core `PlanStep` · `RecoveryStep` · `ReissueItem` · `ReissueChecklist` · `TransferTicket` · `FencingVerdict` · `RestoreVerdict` · `MigrationGateVerdict` · `MigrationStepRow` · `PlanProgress` · ds `RecoveryRun`)과 겹치지 않는다(K80 · C-67 ⑭ · core 대조 시험).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AL-1 | 🆕 `X1PlanWizardVm` · `X1RecoveryVm` · `X1StepRow` | `dto/migration.dart` · 옛 폰 마법사 · 새 폰 받기 · 비상 공용 · 행(9 · 5) |
| AL-2 | 🆕 `X1TicketCard` · `X1FencingCard` · `X1ReissueRow` · `X1RestoreCard` · `X1GateCard` | `dto/migration.dart` · 카드 |
| AL-3 | 🆕 `MigrationRepository`(`watchPlanWizard` · `watchPlanRecovery` · `watchEmergencyRecovery`) | `repositories/migration_repository.dart` · 폰 전용 · `ui_safety` 만 |
| AL-4 | 🆕 `SafetyActionId.x1PlanStart` · `x1PlanStep` · `x1PlanAbort` · `x1EmergencyStart` · `x1ReissueRecord` · `x1RecoveryStep` | `enums/command.dart` · 전부 `run` 화이트리스트 |
| AL-5 | 🆕 `X1SlotIds`(`x1_slot` 4) | `labels/migration_codes.dart` · 시크릿 = `SECRET_` 접두 |
| AL-6 | 🆕 `FixturePaths.x1*` 15 | `fixtures/x1/*.json` |

## AM. 🆕 계약 v1.34 (2026-11-21 · 미결 214 작은 계약 창 — Supabase 신원 모델 DDL) — Dart 이름 0 · SQL 이름 1

`contractVersion` = **`1.34.0`**(다음 = 1.35.0). 상태 = ~~⬜ PR 대기~~ ✅ 병합 PR #311 squash `3dfe0dad`(2026-11-21 · CI 3/3). 결정 = 발주자 위임 2026-11-14 — K282~K289 권고대로(정본 = 설계 01 §43 · 13 §8 R224). 정책 이름 6(`device_insert_viewer_only` · `device_select_own` · `command_insert_viewer` · `command_insert_operator` · `command_select_own` · `command_ack_select`)은 **그대로** — 본문만 «`app_device` 조인»으로 바뀐다.

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AM-1 | 🆕 `ix_app_device_auth_uid` | `ddl/batch_d_supabase.sql` · `app_device(auth_uid)` 색인(unique 아님 — X1 새 폰 = 같은 운영 사용자) |

## AN. 🆕 계약 v1.35 (2026-11-21 · 쌓인 계약 숙제 창) — Dart 이름 4 · 칸 1

`contractVersion` = **`1.35.0`**(다음 = 1.36.0 · D15 읽기 모델 열 표). 상태 = ⬜ PR 대기. 결정 = 발주자 위임 2026-11-14 — K290~K302 권고대로(정본 = 설계 01 §44 · 13 §8 R232). 🔴 `JournalDraft.decisionId` · `AppRoutes.journalDraft` `:decisionId` 이름은 **그대로** — 값의 뜻만 «저널 id» 로 고정(K296).

| # | 이름 | 뜻 · 위치 |
|---|---|---|
| AN-1 | 🆕 `RepairInputResultCodes`(`repair_input_result` 1) | `labels/repair_codes.dart` · X5 정정 원문 파싱 거부 · 엔진 `RepairInputCodes` 1:1(이름 ≠ 엔진) |
| AN-2 | 🆕 `DecisionJournalKinds`(`decision_journal_kind` 8 · `draftPurposes` 2) | `labels/journal_codes.dart` · 원장 `decision_journal.kind` · 글자 = 쓰는 동작 id(예외 둘) |
| AN-3 | 🆕 `JournalRuleCitedCodes`(`journal_rule_cited` 3) | `labels/journal_codes.dart` · J-3 인용 규칙 선택지 코드 |
| AN-4 | 🆕 `JournalDraftRejectCodes.journalTargetUnknown` · `journalInputInvalid` | `labels/journal_codes.dart` · J-3 거부 1 → 3 |
| AN-5 | 🆕 `SafetyState.holdLabels`(JSON `hold_labels`) | `dto/safety.dart` · hold 짝 문장(같은 차례 · 같은 길이) |
| AN-6 | 🆕 `FixturePaths.safetyStatesHolds` · `m6JournalDraftReceiptsReject2` · `x5RepairInputResults` | `fixtures/` 신설 3 |
