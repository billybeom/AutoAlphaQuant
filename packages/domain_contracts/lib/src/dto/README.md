# `lib/src/dto/` — 뷰모델 DTO (G3 예정)

정본: 01_M2_도메인계약 **§2**

| 예정 파일 | 담을 것 | 명세 |
|---|---|---|
| `common.dart` | `DateRange` · `ListResult<T>` · `ReasonChip` · `DecisionRef` · `GateBadge` · `FeatureFlags` · `SleeveCatalogEntry` | §2-1 |
| `journal.dart` | `TradeJournalEntry` · `DeviationBadge` | §2-2 |
| `holdings.dart` | `HoldingRow` · `TrancheStep` · `StopLine` · `HoldingPnl` · 🆕 v1.8 `HoldingsOverviewVm` · `HoldingsSleeveCard` · `HoldingsExternalSection` · `HoldingDetailVm` | §2-3 · §17 |
| `performance.dart` | `PerformanceSeries` · `PerfPoint` · `PerfSegment` | §2-4 |
| `rebalance.dart` | `RebalanceEvent` · `SleeveWeight` · `TriggerSnapshot` · 🆕 v1.8 `SleeveAllocationRow` 밴드 축 · `SleeveBandGauge` · `SleeveAllocationVm` | §2-5 · §2-6 · §17 |
| `plan.dart` | `DepositPlan` · `OrderDraft` | §2-6 |
| `resume.dart` | `PlannedWorkSummary` · `ResumeReport` · 🆕 **v1.22** `ResumeGateVm`·`ResumeGateRow`(X2 재개 게이트 · `watchGate` · 행마다 계절 3택 `actions` = `SafetyActionCall` · `workId` = 시험·키 전용 · K64) | §2-7 · §31 · 🆕 **v1.25** `ResumeReportVm`(X2 리포트 감싸개 · `ResumeGateRepository.watchReport` · `ResumeReport` 무변경 · 01 §34 K156) |
| `calendar.dart` | `CalendarEventDto` | §2-8 |
| `ledger.dart` | `LedgerDiffRow` · `LedgerRepairRow` · 🆕 v1.12 표시 필드(+8 · +7 — `L-1`·`L-2`) | §2-9 · §21 |
| `advice.dart` | `AdviceItem` · `AdviceAction` · `AdviceInboxSummary` · `ManualFillFormSpec` · 선택지 `SymbolOption`·`AccountOption`·`ReasonOption` · 🆕 v1.12 `SideOption`·`TradeDateOption` + 표시·링크 필드(X7 `A-1`~`A-4`) | §2-11 · §21 |
| `ledger_trust.dart` | `LedgerTrustBadge` · `ExecutionGapResult`·`ExecutionGapReport` · `ExternalHoldingRow` · `CashEstimateNotice` · `SelfReportLine` · 🆕 v1.12 `SelfReportSession`·`SelfReportResult`(`L-3`) | §2-11 · §15-4 · §21 |
| 🆕 `onboarding.dart` | `OnboardingStartVm` · `OnboardingTrackCard` · `OnboardingModeChoiceVm` · `OnboardingStepsVm` · `OnboardingStepDetailVm` · `OnboardingAction` · `OnboardingFinishVm` · `OnboardingFinishStage` · `OnboardingFinishCheck` · `RestartVm` · `PairingVm` · `PairingResult` | §25 |
| 🆕 `incident.dart` | **v1.17** `IncidentBanner` · `IncidentBannerVm`(`D-01`) · `RunbookIndexVm` · `RunbookRow` · `RunbookVm` · `RunbookStep`(`D-02`) · `EmergencyCardVm`(`D-03`) — asOf 칸 0(문서·지속 상태 VM) | §26 |
| 🆕 `accounts.dart` | **v1.20** `AccountMappingVm`(`S03` · `watchAccountMapping`) · `AccountRow` · `SleeveMappingRow` · `AccountMappingOption`(🔵 v1.12 `advice.dart` `AccountOption` 과 이름 겹침 회피) — 계좌 종류 코드·별칭·전체번호 칸 0 · POT 행 0 | §29 |
| 🆕 `operations.dart` | **v1.19** `OperationsVm`(`S05` · 칸 11 · `scope`·`HandoverPlan`·`contribution` 칸 0) · `RunModeCard` · `SimTrialCard` · `SimTrialCheck` · `RampBoard` · `RampCondition` · `JobRow` · `EngineControl` · `UpdateGateCard` | §28 |
| `ops.dart` | `ShellVm` · `OpsRhythmRow` · `OpsDailySummary`(🆕 v1.12 `resumeLine`) · M9 VM · 🆕 v1.17 `DeviceRiskItem`·`DeviceRiskVm`(`H-03` · asOf 있음) · 🆕 v1.18 `ConnectionsVm.lockedLabel` · `ConnectionRow` += `detailLine`·`level`·`actions`·`channelPicker` − `actionAvailable` · `NotifyChannelCard`·`NotifyChannelOption`(`S07`) · 🆕 v1.20 `DeviceAccessVm` += `leaseLevel`·`leaseEpochText`·`migrationLink`·`pairing`·`emptyLabel`·`lockedLabel` · `DeviceRow` += `level`·`revokeAction`·`revokeConfirmText` · `PairingTicketCard`(`S06`) · 🆕 v1.24 `BackupVm` 교체(10 칸) · `RestorePointRow` · `DiagnosticsScreenVm` · `SelfTestCard` · `AnnualReviewIndexVm` | §2-6 · §4-1 · §21 · §26 · §27 · §29 · §33 |
| `handbook.dart` | `HandbookIndex` · `HandbookEntry` · `HandbookPage` · `HandbookBlock` · 🆕 v1.17 추가형(`state`·`stateLabel`·`deepLink`·`children` · `outdatedNotice` · `missingLabel` · `asOf?`) · `HandbookLiveValue` | §2-6 · §26 |
| `safety.dart` | `AlertItem` · `SafetyState`(🆕 v1.19 `holds` 추가형) · `BlockFlag` · `OnboardingStep` · `RampLevel`(🆕 v1.19 주석 — 엔진 발행 L1~L5) · 🆕 v1.21 `GaugeProgress.code` 사전 주석(`GaugeCodes`) | §2-10 · §28 · §30 |
| 🆕 `safety_gate.dart` | **v1.21** `KillResumeGateVm`(`M5-2` · `watchResumeGate`) · `KillResumeItemRow`(+ `replayText`) · `KillResumeChoice`(3·4번 선택지 · 칸 정확히 하나) · `PledgeVm`(`M5-8`·`O-04` ② · `watchPledge` · 0 또는 3줄) — 카운트다운 0 · 해제 버튼 0 · 7문항 글자 = SPEC v2.40 원문(K38) · 🆕 **v1.22** `BreakerLadderVm`·`BreakerLadderRow`(`M5-4` · `watchLadder` · 글자 = 엔진 `breakerLadderOf` · K65) | §30 · §31 · 🆕 **v1.25** `KillSwitchScreenVm`·`KillCancelRow`(`M5-1` · `watchKillSwitch`) · `KillActivationFormVm`·`KillActivationItemRow`·`KillActivationChoice`(발동 뒤 기록 폼 · 미결 186) · `BlockBoardVm`·`BlockBoardRow`(`M5-5` · `watchBoard` · 사다리·게이지 감싸기 · 01 §34) |
| `settings.dart` | `ContributionSetting` · `MonthlyContributionVm`(🆕 **v1.23** 추가형 `S13` — `asOf` · `lockedLabel` · `changeLabel` · `editable` = ui 미참조 표식) · `CredentialListVm` · `CredentialCardVm`(🆕 **v1.20** 추가형 `S02` — 색·동작·슬롯·잠김·asOf·봉인·런북·회전 링크 · 키 조각 칸 0 · 1단) · 🆕 **v1.18** `SettingsHomeVm` 교체(`statusChip`·`annualReviewLink`·`groups`·`asOf`) · `SettingsGroup` · `EngineStatusChip` · `SettingsCard`(+ `attentionText` − `actionAvailable`) · `typedef SettingsActionCall = OnboardingAction`(`S01`) | §2-6 · §4-1 · §27 · §32 |

## ⚠️ 아직 이름만 있고 필드가 없는 타입

01 §2-6 아래 표의 «이름만 있는 타입» 전부다 — `KillSwitchView` · `AckState` · `GaugeProgress` · `RampLevel` · `ResumeCounts` · `ResumeItem` · `DataGapRow` · `HandbookIndex` · `HandbookPage` · `MonthlyReport` · `BenchmarkSeries` · `PerfDisclosure` · `ExecutionQuality` · `SleeveAllocation` · `CostEstimate` · `WithdrawalPlan` · `RebalancePreview` · `MomentumPanel` · `CalendarSyncStatus`, 그리고 **명령 페이로드 3종**(`JournalDraft`·`BlindReviewScore`·`DisclosureViewEvent` — 이것이 없으면 명령 5종 중 3종이 호출 불가).

🔴 **화면 담당은 이 이름들의 필드를 상상해서 쓰지 않는다.** 해당 화면을 픽스처 고정 모드로 두고 요청 목록에 올린다.

## 이 폴더가 지는 규칙

- 🔴 **계산 getter 금지**(§1-4). 값과 그 값의 문자열 표기를 함께 싣는다.
- 🔴 **`ListResult<T>` 봉투**로 «없음»(`emptyKind`·`emptyLabel`)과 «모름»(`staleReasonCode`)을 타입으로 구별한다(계약 3조 ③).
- 🔴 **`HoldingPnl`은 기본 접힘이고 별도 요청 시에만 채운다**(결정 8). 홈·알림·위젯에 이 타입이 참조되면 C-6이 실패한다.
