// core_engine — M1(신호·목표비중·한도)·M3(What-if)의 공개 진입점(배럴).
//
// 🔴 이 패키지는 **순수 Dart**다. Flutter·브로커 SDK·DB 클라이언트를 의존하지
//    않는다 — 그래야 골든벡터를 화면·플랫폼 없이 그대로 돌릴 수 있다.
// 🔴 ui_*는 이 패키지를 의존하지 않는다(C-3). 화면이 여기 계산을 부르는 순간
//    엔진과 다른 숫자가 화면에 뜬다.
//
// 계산 코드는 lib/src/ 아래(signals·portfolio·risk·whatif)로 들어오고 공개할
// 것만 여기에서 export 한다. 진척은 README «지금 상태»와 설계 저장소
// `11_앱설계/13_엔진레인_착수계획.md` §2 를 본다.

export 'src/calendar/exchange_calendar.dart' show ExchangeCalendar, Market;
export 'src/calendar/frozen_calendar.dart'
    show FrozenCalendarInfo, frozenCalendarInfo, frozenExchangeCalendar;
export 'src/calendar/next_rebalance.dart'
    show NextRebalance, nextRegularExecutionSession, nextRegularRebalance;
export 'src/costs/trade_costs.dart'
    show
        KrCostConfig,
        ParticipationCut,
        RoundTripPnl,
        SlippageTier,
        TradeCost,
        applyHoldingCost,
        participationCut,
        roundTripPnl,
        tradeCost,
        weightedExpenseRatio;
export 'src/data/data_checks.dart'
    show
        DataGapCause,
        DataIssue,
        KrBar,
        KrDayVerdict,
        judgeKrPlanDay,
        monthEndRegimeReady;
export 'src/data/dated_series.dart'
    show DatedSeries, daysBetween, minusOneDay, plusDays, unionSorted;
export 'src/data/pandas_number.dart' show pandasPreciseXstrtod;
export 'src/data/pit_align.dart'
    show alignAsOfInclusive, alignWithLag, kPublishLagDays, toKrCalendar;
export 'src/data/quote_feed.dart'
    show
        DailyQuoteFeed,
        PriceAdjust,
        QuoteBar,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind,
        kKrSessionFinalHourKst,
        kUsSessionFinalHourKst,
        lastFinishedSession,
        lastSessionAtOrBefore;
export 'src/data/regime_inputs.dart'
    show
        DistVolumeSource,
        RegimeComputation,
        RegimeFreshnessCaps,
        RegimeSources,
        SeriesCadence,
        applyFreshnessCaps,
        computeRegime,
        distVolumeOnCalendar,
        kP0sDirectionHysteresis,
        kP0sDistVolume,
        kP0sTrendHysteresis,
        kRegimeSourceCadence,
        regimeRawIndicators,
        regimeStaleDays,
        usCalendarLagSessions;
export 'src/decimal_rules.dart'
    show
        demoteToDouble,
        divide,
        kContextPrecision,
        mulDiv,
        multiply,
        oneMinus,
        promoteRatio;
// 🆕 E11o-a — 골든벡터 기기 실행기 뼈대 · GV-1~4(설계 13 §8 R161 · R162).
// 🆕 E11o-b — 실행기 목록 분리 · 비용 · 달력 · 주문 계열 · 골든 설정 받침(설계 13 §8 R163).
export 'src/golden/device_suite.dart' show kDeviceGoldenSuite;
// 🆕 E11o-c2 — 05 계열 처리 구분표(설계 13 §8 R165 · §7 P-2).
export 'src/golden/golden_coverage.dart'
    show
        GvCoverage,
        GvDisposition,
        goldenCoverageComplete,
        goldenCoverageGaps,
        goldenCoverageOfCase,
        kGoldenCoverage;
export 'src/golden/golden_fixtures.dart'
    show kGv19StaleTaxRate, kTradingDaysPerYear, krCostsFromSpec;
// 🆕 E11o-d — 기기 실행 기록 · 결과 문장 · S10 카드 · O-04 ④ 사실(설계 13 §8 R167).
export 'src/golden/golden_record.dart'
    show
        GoldenCardFacts,
        GoldenRecordView,
        GoldenSelfTestTexts,
        goldenCountText,
        goldenDiscrepanciesJson,
        goldenLastRunText,
        goldenRecordOf,
        goldenSelfTestCardOf,
        goldenSelftestFactOf,
        kGoldenFailed,
        kGoldenOk,
        kGoldenReconPrefix,
        selftestGoldenResultOf;
export 'src/golden/golden_runner.dart'
    show
        GoldenBundle,
        GoldenFamily,
        GoldenRunResult,
        GoldenSuite,
        GvCase,
        GvFailure,
        GvProbe,
        SuiteGoldenSelfTest,
        gvDecimal,
        gvDouble,
        gvInt,
        gvIntList,
        gvNumList,
        gvObject,
        gvObjectList,
        gvString,
        gvStringList;
// 🆕 E11o-c1 — 슬리브 · 배분 · 브레이커 · 한도 · 기동 · 재량 계열(설계 13 §8 R164).
export 'src/golden/gv_breaker.dart' show Gv31Breaker;
export 'src/golden/gv_costs_calendar.dart' show Gv11Costs, Gv12Calendar;
export 'src/golden/gv_gates.dart' show Gv40dStartup, Gv40eDiscretion;
export 'src/golden/gv_limits.dart' show Gv32Limits;
export 'src/golden/gv_orders.dart'
    show Gv13SubmitCount, Gv30SplitExecution, Gv8Sizing, Gv9Idempotency;
// 🆕 E11o-c2 — GV-16 pit_percentile 게이트(설계 13 §8 R165).
export 'src/golden/gv_pit.dart' show Gv16PitPercentile;
export 'src/golden/gv_regime.dart'
    show Gv1RegimeScore, Gv2Indicators, Gv3ExposureGate, Gv4Hysteresis;
export 'src/golden/gv_sleeves.dart'
    show Gv20SleeveSignals, Gv22SleeveC, Gv37CoreBandDeposit, Gv42Allocation;
// 🆕 E3c — GV-40a · b · c 경고 한도 골든 계열(설계 13 §8 R166).
export 'src/golden/gv_warn.dart'
    show Gv40aDailyWarn, Gv40bMonthlyWarn, Gv40cRebalanceWarn;
// 🆕 E16g2 — X1-2 백업 매니페스트 · 복원 판정 합성(순수 · 설계 13 §8 R135).
export 'src/migration/backup_manifest.dart'
    show
        BackupManifest,
        RestoreReason,
        RestoreVerdict,
        SnapshotCodes,
        SnapshotProbe,
        kBackupManifestKeys,
        restoreVerdictOf;
// 🆕 E16b — X1-2 계획 교체 상태기계 · 이전 티켓 · X1-6 감시 유지보수 창(순수 · 설계 13 §8 R117).
// 🆕 E16c — X1-3 비상 펜싱 대기 · 재발급 체크리스트 · X1-5 LIVE 재개 게이트(순수 · 설계 13 §8 R119).
export 'src/migration/fencing.dart'
    show
        FencingCodes,
        FencingConfig,
        FencingVerdict,
        fencingVerdictOf,
        fencingWaitEndOf,
        kBrokerTokenResidualAssumed;
// 🆕 E16e — X1-4 갭 재구성 계획(순수 · 설계 13 §8 R124).
export 'src/migration/gap_rebuild.dart'
    show
        GapRecompute,
        GapViolation,
        GapViolationKind,
        GapWindow,
        RecoveredFillPlan,
        RecoverySealCodes,
        backupGapDaysOf,
        conservativeBreakerLevel,
        gapFillsToRecover,
        gapResumeModeOf,
        gapSessionsOf,
        gapViolationsOf,
        gapWindowOf,
        kGapRecomputeOrder,
        kX1RecoveredReason,
        recoveredFillPlanOf,
        recoveredStatusOf,
        recoveryOrderSealCode;
// 🆕 E16h2 — X1-5 골든 자가검사 포트(설계 13 §8 R138).
export 'src/migration/golden_self_test.dart' show GoldenSelfTest;
export 'src/migration/maintenance_window.dart'
    show
        WindowAction,
        WindowEvent,
        WindowEventRow,
        WindowRaiseOverdue,
        WindowState,
        WindowTryResume,
        kWindowResumeFailedAlertCode,
        maintenanceWindowIdOf,
        pausableChecksOf,
        resumeFailedEventIdOf,
        windowActionsOf,
        windowEventIdOf,
        windowStateOf;
export 'src/migration/migration_gate.dart'
    show
        MigrationGateCodes,
        MigrationGateFacts,
        MigrationGateState,
        MigrationGateVerdict,
        MigrationObservationConfig,
        migrationGateOf;
export 'src/migration/migration_plan.dart'
    show
        MigrationKind,
        MigrationRole,
        MigrationStartCodes,
        MigrationStepRow,
        MigrationStepState,
        PlanAborted,
        PlanBlockCodes,
        PlanComplete,
        PlanEnter,
        PlanNext,
        PlanProgress,
        PlanResume,
        PlanStep,
        PlanStepFacts,
        migrationRunIdOf,
        migrationStartRejectCode,
        orderLeaseDuringMigration,
        planNextOf,
        planProgressOf,
        planStepBlockCode;
// 🆕 E16h1 — X1-4 새 폰 복구 단계(순수 · 설계 13 §8 R137).
export 'src/migration/recovery_steps.dart' show RecoveryStep;
export 'src/migration/reissue_checklist.dart'
    show ReissueChecklist, ReissueCodes, ReissueEntry, ReissueItem;
export 'src/migration/transfer_ticket.dart'
    show
        DemotionReceipt,
        TransferTicket,
        demotionReceiptOf,
        kTransferTicketKeys,
        transferTicketValid;
// 🆕 E15b — 기동 해석(어느 파일 · 어느 조합 · 반쯤 끝난 커밋 · SPEC v2.44 · 설계 13 §8 R82).
export 'src/mode/boot_mode.dart'
    show
        BootMode,
        BootModeOnboardingIncomplete,
        BootModeResolved,
        ModeRowFacts,
        resolveBootMode;
// 🆕 E15f2 — 전환 세션(종류 · 닫힘 코드 · 48h · 열기 사전 판정 · 냉각 알림 · 문구 · 설계 13 §8 R96).
export 'src/mode/handover_session.dart'
    show
        HandoverCloseCode,
        HandoverSessionCodes,
        HandoverSessionKind,
        HandoverSessionRecord,
        handoverCoolingAlertCodes,
        handoverSessionHeadline,
        handoverSessionIdOf,
        kHandoverCancelledHeadline,
        kHandoverCoolingCheck,
        kHandoverSessionTtl,
        simToAutoOpenReject;
// 🆕 E15f4a — 커밋 직전 계좌 조회 어댑터(브로커 포트 → LiveAccountProbe · 설계 13 §8 R103 AI6).
export 'src/mode/live_account_probe.dart' show probeLiveAccount;
// 🆕 E15e1 — M1-22 실전 드라이런 관찰 창(연속 무결 거래일 · 승격 가능 판정 · 설계 13 §8 R89).
export 'src/mode/live_observation.dart'
    show
        LiveObservationBlock,
        LiveObservationConfig,
        LiveObservationFacts,
        LiveObservationFactsSource,
        LiveObservationRecon,
        LiveObservationReport,
        LiveObservationRun,
        cleanTradingDayStreakOf,
        judgeLiveObservation,
        kLiveDryRunObservationKey,
        kLiveObservationBatchCheck;
// 🆕 E15e2 — M1-22 승격 커밋(사전 판정 차례 · 코드 · 결정 id · 문구 · 설계 13 §8 R91).
export 'src/mode/live_promotion.dart'
    show
        LivePromotionCodes,
        kLivePromotionReason,
        kLivePromotionReasonCode,
        livePromotionDecisionId,
        livePromotionHeadline,
        livePromotionReject;
// 🆕 E15a — 모드 조합 가드 · 기동 판정(X6-3 · X7-8 · X18 · SPEC v2.44 · 설계 13 §8 R81).
export 'src/mode/mode_guard.dart'
    show
        ModeCell,
        ModeFacts,
        ModeFactsSource,
        ModeGuardRejected,
        ModeStartupGate,
        kCredentialEnvMismatch,
        kModeCombinationDenied,
        liveAwaitingKeys,
        modeCombinationAllowed,
        modeCombinationCell,
        modeStartupGate,
        orderJobModeReject;
// 🆕 E15f3b — simToAuto 2단계 · 기동 복구 모의 파일 처리 판정(설계 13 §8 R100).
export 'src/mode/sim_ledger_finish.dart'
    show
        SimLedgerDeleteResult,
        SimLedgerFinish,
        SimLedgerFinishPlan,
        simLedgerFinishOf;
// 🆕 E15f1 — simToAuto 순수 판정(7단계 · 냉각 · 확정 기한 · 커밋 창 막기 · 화면 계획 · 설계 13 §8 R93).
export 'src/mode/sim_to_auto.dart'
    show
        SimLedgerFate,
        SimToAutoCodes,
        SimToAutoCommitWindow,
        SimToAutoFacts,
        SimToAutoReport,
        SimToAutoStep,
        SimToAutoStepResult,
        judgeSimToAuto,
        kHandoverCommitWindow,
        kHandoverCooling,
        kHandoverPlanStaleAfter,
        simToAutoCommitWindow,
        simToAutoPlan;
// 🆕 E15f3a — simToAuto 2단 커밋 1단계 순수 몫(게이트 · 개시 현금 · 결정 id · S5 고름 · 설계 13 §8 R98).
export 'src/mode/sim_to_auto_commit.dart'
    show
        LeaseSnapshot,
        LiveAccountProbe,
        SimToAutoCommitCodes,
        kHandoverCommitCheck,
        kLiveOpeningReason,
        kLiveOpeningSeedReason,
        kSimLedgerDiscardCode,
        kSimLedgerKeepCode,
        liveOpeningCash,
        liveOpeningDecisionId,
        simLedgerFateDecisionId,
        simLedgerFateOfReasonCode,
        simLedgerFateReasonCode,
        simToAutoCommitHeadline,
        simToAutoCommitReject,
        simToAutoConfigApprovalReject,
        simToAutoLeaseReject,
        simToAutoSessionUsable;
// 🆕 E15f4b2 — simToAuto 전환 오케스트레이션(새 체크 → 커밋 → 마감 → 옛 멈춤 · 보상 · 기동 보정 · 설계 13 §8 R106).
export 'src/mode/sim_to_auto_switch.dart'
    show
        SimToAutoSwitchCommit,
        SimToAutoSwitchResult,
        SimToAutoSwitchStage,
        kSimToAutoCommitUnknown,
        kSimToAutoWatchdogPrepareFailed,
        pendingOldModePauses,
        repairOldModePauses,
        runSimToAutoSwitch;
// 🆕 E11p4j — O-04 ③ 생체 서명(설계 13 §8 R159).
export 'src/onboarding/biometric_sign.dart'
    show
        BiometricOutcome,
        BiometricSignTexts,
        biometricOutcomeOfWire,
        biometricSignDigest,
        biometricSignResultText,
        kBiometricSignKind;
// 🆕 E11p3b-1 — 설정 지문(정규 JSON SHA-256 앞 16자 · 설계 13 §8 R90).
export 'src/onboarding/credential_list.dart'
    show PaperCredentialFacts, credentialListVmOf, kCredentialListStaleAfter;
export 'src/onboarding/onboarding_choice.dart'
    show
        kOnboardingModeCommittedText,
        kOnboardingModeSelectedText,
        onboardingModeChoiceVmOf,
        onboardingStartVmOf;
export 'src/onboarding/onboarding_finish.dart'
    show
        OnboardingFinishFacts,
        kOnboardingDryRunRolledBackText,
        kOnboardingDryRunStartedText,
        onboardingFinishVmOf;
export 'src/onboarding/onboarding_steps.dart'
    show
        OnboardingStepFact,
        kOnboardingFailureFallback,
        kOnboardingRecommendedWarning,
        kOnboardingStepMissingLabel,
        kOnboardingStepsEmptyLabel,
        onboardingStepDetailVmOf,
        onboardingStepIds,
        onboardingStepsVmOf;
// 🆕 E11p3d-5i — M9 S03 계좌 · 슬리브 매핑(설계 13 §8 R151).
export 'src/ops/account_mapping.dart'
    show
        AccountMappingFacts,
        PaperAccountFacts,
        accountMappingVmOf,
        kAccountMappingStaleAfter,
        kSleevePendingLine,
        kSleeveUnmappedLine;
// 🆕 E11p3d-4a — 알림 수신 확인(ack) 명령 봉투(설계 13 §8 R147).
export 'src/ops/alert_ack_command.dart'
    show AlertAckCommand, kAlertAckTtl, newCommandId;
// 🆕 미결 192 — M9 S04 배분 화면 첫 판(보기 전용) VM · `rm_config_view` S04 열(설계 13 §8 R190 · 계약 0 — S04 창 전).
export 'src/ops/allocation_view.dart'
    show
        AllocationView,
        AllocationViewCard,
        AllocationViewRow,
        AllocationViewRowCodes,
        AllocationViewSection,
        RmConfigViewAllocationColumns,
        allocationViewColumns,
        allocationViewOf,
        kP0sBacktestText,
        kP0sHonestExpectationLine;
// 🆕 E11p4l — M9 S12 연간 리뷰 목차 · 12월 창(설계 13 §8 R168 · 미결 202).
export 'src/ops/annual_review_index.dart'
    show
        AnnualReviewIndexFacts,
        AnnualReviewTexts,
        AnnualReviewWindow,
        annualReviewHomeLinkOf,
        annualReviewIndexVmOf,
        annualReviewWindowOf,
        kAnnualReviewEntries,
        kAnnualReviewStaleAfter;
export 'src/ops/config_fingerprint.dart'
    show canonicalConfigJson, configFingerprint, kConfigFingerprintLength;
// 🆕 E11p3d-5f — M9 S07 연결 관리(설계 13 §8 R140).
export 'src/ops/connections.dart'
    show
        ConnectionStatusCodes,
        ConnectionsFacts,
        HealthchecksReach,
        connectionAgoText,
        connectionHealthchecksRowOf,
        connectionKisRowOf,
        connectionsVmOf,
        kConnectionsStaleAfter;
// 🆕 E11j — 월 납입 운영값(M3-6 엔진 몫 · 설계 13 §8 R54).
export 'src/ops/contribution_setting.dart'
    show
        ContributionConfig,
        ContributionDecision,
        ContributionRejectCodes,
        ContributionParamRow,
        contributionEffectiveFrom,
        contributionEquivalentNoteText,
        contributionKstDay,
        contributionParamRowFromColumns,
        contributionPensionLimitNoteText,
        contributionSettingOf,
        decideContributionChange,
        firstKrSessionOfMonth,
        latestContributionRow,
        nextContributionDay,
        p0sContributionConfig,
        splitContributionRows;
// 🆕 E16a — X5-4 파생 관계 · 동기 조치 · 체인 diff(순수 · 설계 13 §8 R112).
export 'src/ops/derived_sync.dart'
    show
        CanonChain,
        ChainBaseline,
        DerivedChainDiff,
        DerivedForkStop,
        DerivedHold,
        DerivedHoldReason,
        DerivedNoop,
        DerivedRelation,
        DerivedResync,
        DerivedStamp,
        DerivedSyncAction,
        DerivedSyncStatus,
        DerivedTarget,
        derivedChainDiffOf,
        derivedRelationOf,
        derivedSyncActionOf,
        kDerivedForkAlertCode;
// 🆕 E11p3d-5h — M9 S06 기기 · 접근 관리(설계 13 §8 R146).
export 'src/ops/device_access.dart'
    show
        DeviceAccessFacts,
        deviceAccessVmOf,
        kDeviceAccessMigrationLabel,
        kDeviceAccessNoViewers,
        kDeviceAccessStaleAfter;
// 🆕 E11p3d-2c — H-03 물리 리스크 점검(측정 = 조립 앱 · 임계 · 판정 · 문구 = 엔진 · 설계 13 §8 R136).
export 'src/ops/device_risk.dart'
    show
        DeviceBatteryHealth,
        DeviceRiskFacts,
        deviceBytesText,
        deviceRiskVmOf,
        deviceTempText,
        kDeviceBatteryCyclesAct,
        kDeviceBatteryCyclesWatch,
        kDevicePatchActDays,
        kDevicePatchWatchDays,
        kDeviceRiskEmptyLabel,
        kDeviceRiskGuidance,
        kDeviceRiskNoAction,
        kDeviceRiskStaleAfter,
        kDeviceRiskStaleLabel,
        kDeviceStorageActBytes,
        kDeviceStorageBlockedBytes,
        kDeviceStorageWatchBytes,
        kDeviceTempActTenths,
        kDeviceTempWatchTenths;
// 🆕 E11p4k — M9 S10 진단 감싸개 · 무결성 자가진단 결과(설계 13 §8 R160).
export 'src/ops/diagnostics_screen.dart'
    show
        DiagnosticsScreenFacts,
        DiagnosticsScreenTexts,
        diagnosticsScreenVmOf,
        integrityReasonText,
        kDiagnosticsScreenStaleAfter,
        selftestIntegrityResultOf;
// 🆕 E11f1 — 일일 평가 스냅숏 계산(평가 · HWM · 드로다운 · 브레이커 재생 · P0S 브레이커 설정 · 설계 13 §8 R47 F6~F8).
export 'src/ops/equity_snapshot.dart'
    show
        BreakerDay,
        BreakerReplay,
        EquitySnapshotError,
        EquitySnapshotRow,
        EquitySnapshotStep,
        computeEquitySnapshot,
        kBreakerStoppedAlertCode,
        kStoppedPostmortemDue,
        kStoppedReleaseEligibleAlertCode,
        nextEquitySnapshot,
        p0sBreakerConfig,
        positionsValueKrw,
        replayBreaker,
        replayStoredBreaker,
        stoppedIncidentIdOf,
        stoppedIncidentOf;
// 🆕 E11q1 — M6 H6-1 보유 현황 VM(설계 13 §8 R171).
export 'src/ops/holdings_overview.dart'
    show
        HoldingPositionFact,
        HoldingsOverviewFacts,
        HoldingsTexts,
        bTrancheSignalsOf,
        holdingDetailVmOf,
        holdingIdOf,
        holdingsManwonText,
        holdingsOverviewVmOf,
        kHoldingsStaleAfter,
        sleeveAllocationVmOf;
// 🆕 E14c1 — 잡 실행 기록 포트 · 값 꼴(02 v2.42 `job_run` · 설계 13 §8 R73 K1).
export 'src/ops/job_run_log.dart'
    show JobRunEntry, JobRunLog, JobRunStatus, successStatusOf;
// 🆕 E14a — 리스 포트 · 3상 · 상수(SPEC v2.42 NR-1 0 · 6.9 · 설계 13 §8 R71).
export 'src/ops/lease_gate.dart'
    show
        LeaseGate,
        LeaseVerdict,
        kLeaseInvalidCode,
        kLeaseRenewEvery,
        kLeaseTtl,
        leaseStale,
        readLease;
// 🆕 E11h2 — 아카이브 레이아웃 · checkpoint.json · 백업 나이(설계 13 §8 R52).
export 'src/ops/ledger_archive.dart'
    show
        ArchiveCheckpoint,
        BackupAge,
        archiveCheckpointPath,
        archiveDayDir,
        archiveFileContent,
        archiveFileLines,
        archivePrefix,
        archiveTablePath,
        backupAgeOf,
        dayHashFromArchive,
        kBackupStaleAfter;
// 🆕 E16a — X5-5 X1 경계 판정(나쁜 쪽이 이긴다 · 안내까지만 · 설계 13 §8 R112).
export 'src/ops/ledger_boundary.dart'
    show
        BoundaryPath,
        BoundaryReason,
        LedgerBoundaryVerdict,
        kBoundaryX1Headline,
        ledgerBoundaryOf;
// 🆕 E11h1 — X5-1 정규 직렬화 · day_hash · 해시 체인(설계 13 §8 R51).
export 'src/ops/ledger_hash.dart'
    show
        LedgerHashError,
        LedgerHashTable,
        authoredKstDate,
        canonicalDouble,
        canonicalRow,
        canonicalString,
        canonicalValue,
        chainCarryText,
        chainHashOf,
        chainStampText,
        dayHashInput,
        dayHashOf,
        kChainGenesis,
        kLedgerHashPopulationV1,
        rowCountsJson,
        sortCanonicalLines;
// 🆕 E13c1 — 정본 자가 무결성(체인 자가 대조 · 설계 13 §8 R58 C2 · C3).
export 'src/ops/ledger_integrity.dart'
    show
        LedgerIntegrityReason,
        LedgerIntegrityVerdict,
        StoredDayStamp,
        kLedgerIntegrityAlertCode,
        verifyLedgerChain;
// 🆕 E13c2 — X5 읽기 쪽(L-1 최근 차이 · 5칸 대조 보드 · 설계 13 §8 R59).
export 'src/ops/ledger_views.dart'
    show
        BrokerReconSummary,
        DerivedPairSummary,
        DiagnosticStates,
        StoredLedgerDiff,
        axisLabelOf,
        brokerCellOf,
        candidatesOfDelta,
        derivedCellOf,
        diagnosticsHeadline,
        diagnosticsOf,
        emptyLedgerList,
        evidenceHashOf,
        kLagOriginCodes,
        kOriginLabels,
        kReconStaleAfter,
        kRecentDiffLimit,
        kRecentDiffWindow,
        kstDateText,
        kstMinuteText,
        ledgerDiffRowOf,
        originChipOf,
        pairLabelOf,
        reconAsOf,
        recentLedgerDiffsOf,
        routeLabelOf,
        routeOf,
        selfReportCellOf,
        severityLabelOf,
        statusLabelOf;
// 🆕 E15g — 모드 표지(OS 알림 제목 접두 · 표지 글자 · 설계 13 §8 R110 AO7).
export 'src/ops/mode_marker.dart'
    show alertOsTitlePrefix, kAdvisoryMarker, kSimMarker;
// 🆕 E11f2 — 월말 계획기 입력 조립(원장 보유 → MonthEndState · 월별 마지막 종가 · 슬리브 비중 · 설계 13 §8 R48 P4~P6).
export 'src/ops/month_end_inputs.dart'
    show
        MonthEndInputError,
        MonthEndRun,
        computeMonthEndRun,
        monthEndActionToJson,
        monthEndStateFromLedger,
        monthEndStateToJson,
        monthlyLastCloses,
        sleeveWeightsOf;
// 🆕 운영 설정 읽기(operations · 설계 13 §8 R148).
// 🆕 E11q1b — 다음 리밸런싱 회차 VM(설계 13 §8 R172).
export 'src/ops/monthly_contribution_view.dart'
    show
        MonthlyContributionTexts,
        contributionUpdateResultOf,
        monthlyContributionVmOf;
export 'src/ops/next_rebalance_view.dart'
    show NextRebalanceTexts, nextRebalanceVmOf;
export 'src/ops/operations_config.dart' show OperationsConfig;
// 🆕 E11p3d-2b — H-01 오늘 요약 · H-02 운영 리듬(설계 13 §8 R133).
export 'src/ops/ops_home.dart'
    show
        OpsHomeFacts,
        OpsHomePendingText,
        OpsRhythmCodes,
        kOpsHomeNoRebalanceText,
        kOpsHomeStaleAfter,
        kOpsRhythmEmptyLabel,
        opsDDayText,
        opsDailySummaryOf,
        opsHomeAsOf,
        opsRhythmOf,
        opsRhythmRowsOf;
// 🆕 E3d-3 — P0S 월간 SAF-306 과세연도 금융소득 누계 · 첫 초과 월 알림(04 §1 Level 3 v2.46 · 설계 13 §8 R181).
export 'src/ops/p0s_income_warn.dart'
    show
        P0sDistribution,
        P0sIncomeTally,
        P0sIncomeWarnSetup,
        P0sIncomeWarnStep,
        p0sFinancialIncomeCapKrw,
        p0sMonthlyIncomeWarnStep,
        positiveRealizedGainsOf;
// 🆕 E11p3b-1 — P0S 운영 설정 원천(SPEC 한도 · 비용 · 지정가 여유 + 사람 값 필수 입력 · 설계 13 §8 R90).
export 'src/ops/p0s_ops_config.dart'
    show
        P0sHumanInputs,
        P0sOpsConfig,
        kP0sBuyCostRate,
        kP0sConfigSpecVersion,
        kP0sFillCostRates,
        kP0sLimitOffsetPct,
        kP0sMappedStrategies,
        p0sLimitConfig,
        p0sRegimeConfigHash;
// 🆕 E11p3d-5e — M9 S01 설정 홈(설계 13 §8 R134).
// 🆕 E3d-1 — P0S 일간 경고(302 · 307 · 308 · 원화 유동성) · 넘은 첫날 알림(04 §1 Level 3 v2.46 · 설계 13 §8 R177).
// 🆕 E3d-4 — 월 잡 307 · 원화 유동성 월 집계(`p0sMonthlyExposureTally` · 앱 01 §36 K193 · 설계 13 §8 R187).
export 'src/ops/p0s_warn.dart'
    show
        P0sDailyWarn,
        P0sExposure,
        P0sExposureMap,
        P0sExposureTally,
        P0sTallyDay,
        P0sWarnConfig,
        P0sWarnInputs,
        P0sWarnSetup,
        P0sWarnStep,
        holdingsBeforeFills,
        judgeP0sDailyWarnings,
        kDefensiveFloorAlertCode,
        kFinancialIncomeAlertCode,
        kGoldShareAlertCode,
        kKrwLiquidityAlertCode,
        p0sDailyWarnStep,
        p0sExposureMap,
        p0sExposureOf,
        p0sMonthlyExposureTally,
        p0sWarnConfig,
        p0sWarnEdgeAlerts;
export 'src/ops/rebalance_events_view.dart'
    show
        RebalanceEventFact,
        RebalanceEventTexts,
        rebalanceEventVmOf,
        rebalanceEventsVmOf;
export 'src/ops/settings_home.dart'
    show
        SettingsCardCodes,
        SettingsHomeFacts,
        kSettingsAllocationLabel,
        kSettingsAllocationMissingLabel,
        kSettingsHomeStaleAfter,
        settingsCredentialsCardOf,
        settingsHomeVmOf,
        settingsOperationsLabelOf,
        settingsStatusChipOf;
// 🆕 E11p4f — 모의 개시 가상 초기금 제출 → 명령(설계 13 §8 R155 · 01 §21-3 · 06 M5-14).
export 'src/ops/sim_opening_command.dart'
    show
        SimOpeningCommand,
        SimOpeningInputInvalid,
        SimOpeningWireReady,
        SimOpeningWireResult,
        cashKrwOfText,
        kSimOpeningCashBlank,
        kSimOpeningCashMalformed,
        kSimOpeningLinesGiven,
        kSimOpeningTtl,
        simOpeningWireOf;
// 🆕 E11g — 계층 B 월간 판정(TWR · 롤링 12M · DD · TUW · 카드 대조 · 설계 13 §8 R50).
export 'src/ops/tier_b.dart'
    show
        EquityPoint,
        TierBCard,
        TierBError,
        TierBMetrics,
        TierBVerdict,
        judgeTierB,
        p0sTierBCard,
        tierBMetrics,
        tierBTrigger,
        twrIndex;
// 🆕 E11j — 신뢰 시각 포트(M1-13 · 실물 = E11k · 설계 13 §8 R54 J1).
export 'src/ops/trusted_clock.dart' show TrustedClock;
// 🆕 E11c — 워치독 포트 · 값 꼴(설계 13 §8 R45 C1 — 구현 = data_sync · 보드 = trading_runtime).
export 'src/ops/watchdog_ports.dart'
    show
        EnsureOutcome,
        EnsuredCheck,
        JobHeartbeat,
        PauseReason,
        PingStatus,
        RemoteCheck,
        RemoteCheckStatus,
        WatchdogCheckSpec,
        WatchdogRemote,
        isNeverPauseSlug,
        kNeverPauseChecks,
        kWatchdogPrefixes,
        pausePermitted,
        watchdogCheckName,
        watchdogCheckPrefix,
        watchdogPrefixOf;
export 'src/orders/block_bundles.dart' show BlockBundles, blockingFlagsFor;
export 'src/orders/carry_over.dart'
    show
        CarryLedger,
        CarryPlan,
        ExpiredIntent,
        SplitProgress,
        kCarrySessionLimit,
        logicalIdOf,
        planCarryOver,
        seasonalShareToday;
// 🆕 E11f3 — 대상 출처 묶음(월말 + 계절 A · 설계 13 §8 R49 Q5).
export 'src/orders/composite_target_source.dart' show CompositeTargetSource;
export 'src/orders/execute_intent.dart'
    show ExecutionContext, ExecutionOutcome, ExecutionStatus, executeIntent;
export 'src/orders/fill_sync.dart'
    show
        FillApplication,
        FillCostRates,
        FillLedger,
        FillSyncReport,
        FillVerdict,
        OpenIntent,
        estimateFillCost,
        kDayEndCheckAfterKst,
        reconcileFills,
        runFillSync,
        staleOrderRows;
export 'src/orders/fills.dart'
    show
        DailyFillRow,
        FillDelta,
        RecordedFill,
        averageFillPrice,
        averagePriceAfterBuy,
        brokerOrderNoOf,
        executionIdOf,
        fillDeltas,
        parseRecordedCancelJson,
        parseRecordedFillJson,
        recordedFillJson;
export 'src/orders/idempotency.dart'
    show DecisionIds, idempotencyKey, idempotencyRaw;
// 🆕 E13c1 — 쌍 · 축 심각도 · 원인 코드 쓰기 화이트리스트(설계 13 §8 R58 C7 · C8).
export 'src/orders/ledger_pairs.dart'
    show diffSeverityFor, writableOriginCodesFor;
// 🆕 E11p3b-2 — 한도 판정 입력(총자산 · 오늘 손익률 · 위험자산 · 레버리지 · 보유 수 · 설계 13 §8 R91).
export 'src/orders/limit_inputs.dart'
    show
        LimitCurrentPrice,
        LimitInputs,
        LimitInputsCollector,
        LimitInputsUnavailable,
        LimitLedgerFacts,
        LimitLedgerFactsSource,
        limitStateOf;
export 'src/orders/order_batch.dart'
    show BatchOutcome, CashFit, CashShortfall, fitBuysToCash, runOrderBatch;
export 'src/orders/order_draft.dart'
    show
        AllHeldSizing,
        AmountSizing,
        DraftConfig,
        DraftIssue,
        DraftIssueCode,
        DraftQuote,
        DraftResult,
        OrderIntentDraft,
        OrderSizing,
        OrderTarget,
        OrderTypes,
        P0sStrategyIds,
        ShareSizing,
        draftOrders,
        limitPriceFor,
        targetsFromMonthEnd;
export 'src/orders/order_path_ports.dart' show AccountBroker, OrderPathLedger;
export 'src/orders/order_ports.dart'
    show
        AdviceSink,
        BrokerAccepted,
        BrokerOrderRequest,
        BrokerRejected,
        BrokerSubmitResult,
        IntentRow,
        IntentStatus,
        OrderBroker,
        OrderLedger,
        OrderOutcomeUnknown,
        intentIdFor;
export 'src/orders/reconcile.dart'
    show
        BrokerBalance,
        BrokerBalanceSource,
        JournalRequired,
        LedgerHolding,
        LedgerOrderFill,
        RecheckRequired,
        ReconAction,
        ReconClearOutcome,
        ReconClearance,
        ReconDiff,
        ReconKind,
        ReconLedger,
        ReconRecord,
        ReconReport,
        clearRecon,
        kReconClearOriginCodes,
        kReconRecheckDelay,
        ledgerDiffIdOf,
        reconcileAccount,
        runReconciliation;
export 'src/orders/split_execution.dart'
    show SplitDay, seasonalExecutionDays, splitDay;
// 🆕 E11f2 — 오늘의 주문 대상 포트(trading_runtime 에서 옮김) · 대상 직렬화(설계 13 §8 R48 P2 · P9).
export 'src/orders/target_source.dart'
    show TargetSource, orderTargetFromJson, orderTargetToJson;
export 'src/orders/unknown_resolution.dart'
    show
        UnknownAmbiguous,
        UnknownIntent,
        UnknownLedger,
        UnknownLinked,
        UnknownMissed,
        UnknownNotFound,
        UnknownResolution,
        UnknownResolutionReport,
        kUnknownMissGap,
        kUnknownMissPrefix,
        kUnknownNotFoundPrefix,
        kUnknownTimeMargin,
        resolveUnknown,
        resolveUnknownOrders,
        unknownMissAt,
        withUnknownMiss;
export 'src/portfolio/allocation.dart'
    show AllocationTargets, kAllocationProfiles, resolveAllocation;
export 'src/portfolio/core_band.dart'
    show CoreBandDirection, CoreBandMove, coreBandMove;
export 'src/portfolio/deposit.dart'
    show DepositAllocation, DepositFill, allocateDeposit;
export 'src/portfolio/funding.dart' show FundingPlan, FundingTake, fundingOrder;
export 'src/portfolio/month_end_plan.dart'
    show
        MonthEndAction,
        MonthEndActionKind,
        MonthEndConfig,
        MonthEndPlan,
        MonthEndState,
        planMonthEnd;
// 🆕 E11f3 — 슬리브 A 계절 판정 · POT 현금 재계산(설계 13 §8 R49 Q2 · Q3 · Q6).
export 'src/portfolio/seasonal_a.dart'
    show
        PotCashFlow,
        PotCashFlowKind,
        SeasonalAConfig,
        SeasonalADecision,
        SeasonalAInput,
        SeasonalAInputError,
        SeasonalAOutcome,
        decideSeasonalA,
        kP0sAllocA,
        kSeasonalMinDeltaFraction,
        potCashOf,
        seasonalAInputFromLedger;
export 'src/portfolio/sleeve_c.dart'
    show
        InflowCurrency,
        SleeveCInflow,
        SleeveCTargets,
        SleeveCWeights,
        sleeveCAllocateInflow,
        sleeveCUsdTargets;
// 🆕 E11q1 — 슬리브 비중 줄 · 밴드 상태 · 목표 막대(미리보기 · 보유 한 생산 · R171).
export 'src/portfolio/sleeve_weight_view.dart'
    show
        kNearEdgeFraction,
        sleeveBandGaugeOf,
        sleeveBandStateOf,
        sleeveWeightOf;
// 🆕 E16d1 — X5-3 정정 계획 · 역분개 · 새 기준점(순수 · 설계 13 §8 R121).
export 'src/repair/baseline_plan.dart'
    show
        BaselineCodes,
        baselinePlanOf,
        baselineRejectCode,
        integrityDiffIdOf,
        oldStampsEvidenceJson;
// 🆕 E16f2 — 체결 재생 · 포지션 다시 세기(순수 · 설계 13 §8 R128 K7 · K12).
export 'src/repair/fill_replay.dart'
    show
        LedgerFillRow,
        ReplayedPosition,
        effectiveFillsOf,
        fillChainDepthOf,
        kReplayAvgTolerance,
        orderFillTotalsOf,
        positionReplayMatches,
        replayPositionOf,
        reversedFillIdsOf;
export 'src/repair/repair_plan.dart'
    show
        LedgerRepairPlanRow,
        RepairChoice,
        RepairCodes,
        RepairDirection,
        defaultRepairChoiceOf,
        kBaselineOriginCodes,
        kRepairableTables,
        kResyncCanonOriginCodes,
        repairDeltaRejectCode,
        repairOriginCodesFor,
        repairOriginRejectCode,
        repairTargetRejectCode;
// 🆕 E16d2 — X5 정정 이력 표시 행 빌더(설계 13 §8 R123).
export 'src/repair/repair_rows.dart'
    show
        RepairTargetKind,
        StoredLedgerRepair,
        kRepairDecisionLinkLabel,
        kRepairReasonPhrases,
        kRepairSupersededLabel,
        ledgerRepairRowOf,
        ledgerRepairRowsOf,
        repairLabelOf,
        repairTargetTextOf;
export 'src/repair/reversal_plan.dart'
    show
        FillSnapshot,
        PlannedFillRow,
        amendFillPlan,
        amendFillRejectCode,
        signedFillQuantity,
        voidFillPlan;
// 🆕 E14b — 재개 판정 순수(06 X2-2 · X2-3 · X2-5 · X2-6 · SPEC v2.42 04 §3-1 ②③④ · §5-3 · 설계 13 §8 R72).
// 🆕 E14c2 — 평시 정리 포트(설계 13 §8 R74 M5).
export 'src/resume/planned_work_ledger.dart' show PlannedWorkLedger;
export 'src/resume/planned_work_machine.dart'
    show
        PlannedWorkCodes,
        kPlannedWorkTerminal,
        plannedWorkPastDue,
        plannedWorkTransitionRejectCode;
export 'src/resume/resume_alerts.dart'
    show
        kResumeAlertSource,
        kResumeCompletedAlertCode,
        kResumeDataGapAlertCode,
        kResumeTradingHaltedAlertCode,
        kResumeUnfoldedAlertCodes,
        resumeBundleAlerts,
        resumeFoldsAlert;
export 'src/resume/resume_gap.dart'
    show ResumeLadder, resumeGapSessions, resumeModeOf;
export 'src/resume/resume_judge.dart'
    show
        ResumeDirection,
        ResumeItemDecided,
        ResumeItemJudgement,
        ResumeItemNeedsReevaluation,
        ResumeItemStep,
        ResumeItemUntouched,
        ResumePreconditions,
        ResumeReasonCodes,
        ResumeWorkItem,
        ResumeWorkKinds,
        SeasonalChoiceCodes,
        SeasonalWindowChoice,
        judgeResumeItem,
        kSeasonalReducedEntryRatio,
        reevaluatedJudgement,
        resumeAutoAllows,
        resumeHaltReason,
        resumePriorityOrder,
        resumeReleasesFlag,
        seasonalChoiceJudgement,
        seasonalChoiceRejectCode,
        seasonalReducedShares;
// 🆕 E14d1 — 재판정 포트(설계 13 §8 R75 N7 · 실물 = E14d2).
export 'src/resume/resume_reevaluator.dart' show ResumeReevaluator;
// 🆕 E11q-b2a — X2 재개 화면 VM 두 장(리포트 · 게이트 — 설계 13 §8 R186 · 01 §31 K64 · §34 K156).
export 'src/resume/resume_screens.dart'
    show
        ResumeGateItem,
        ResumeGateRun,
        ResumeScreenTexts,
        kResumeScreenStaleAfter,
        resumeGateRowLevel,
        resumeGateVmOf,
        resumePeriodText,
        resumeReportVmOf,
        resumeScreenAsOf,
        seasonalChoiceResultOf;
export 'src/resume/resume_text.dart'
    show
        plannedWorkStateLabel,
        resumeCountsOf,
        resumeGapLabel,
        resumeHeadline,
        resumeItemOf,
        resumeLineText,
        resumeModeLabel,
        resumeModeName,
        resumePlannedLine,
        resumeReevaluatedLine,
        resumeVerdictLabel;
export 'src/risk/breaker.dart'
    show
        BreakerConfig,
        BreakerLevel,
        BreakerState,
        BreakerStep,
        SleeveMultipliers,
        evaluateBreaker,
        exposureMultiplier,
        isStoppedReleaseEligible,
        kReduceReleaseDirectionScore,
        levelFromDrawdown,
        releaseStoppedToHalted,
        stepBreaker;
export 'src/risk/limits.dart'
    show
        LimitCheckResult,
        LimitConfig,
        InstrumentKind,
        LimitIntent,
        LimitSide,
        LimitState,
        LimitStatus,
        RiskCheckUnavailable,
        checkAllLimits;
export 'src/risk/position_sizing.dart'
    show SizingBinding, SizingResult, sizePosition;
// 🆕 E3c — SAF 경고 한도 판정(일간 202 · 208 · 302 · 305 · 307 · 월간 201 · 306 · 리밸런싱 204 · 205 · 설계 13 §8 R166).
export 'src/risk/warn_limits.dart'
    show
        DailyWarnResult,
        MonthlyWarnResult,
        SleeveACandidate,
        SleeveASelection,
        WarnAction,
        WarnHolding,
        WarnLimitConfig,
        WarnLimitIds,
        financialIncomeCapExceeded,
        judgeDailyWarnLimits,
        judgeMonthlyWarnLimits,
        judgeRebalanceWarnLimits,
        kUnknownSectorBucket,
        kWarnActions;
// 🆕 E13h1 — 알림 등급 · 묶음 · P0 ack 사다리 · 알림 포트(06 M5-15 · 설계 13 §8 R68).
export 'src/safety/alert_rules.dart'
    show
        AlertEscalationChannel,
        AlertSink,
        alertAckRejectCode,
        alertDedupeKey,
        alertHasLadder,
        alertIdOf,
        alertLevelOf,
        dueEscalationSteps,
        kAckLadder,
        kAlertLevels;
// 🆕 E13h2 — 알림 문구 사전 · AckState 글자 · 인박스 · 센터 · 상세 VM(설계 13 §8 R69).
export 'src/safety/alert_text.dart'
    show
        AlertText,
        StoredAlert,
        ackStateOf,
        alertAsOf,
        alertCenterOf,
        alertDetailOf,
        alertInboxOf,
        alertItemOf,
        alertTextOf,
        kAlertEmptyLabel,
        kAlertMissingLabel,
        kAlertTexts,
        kAlertWindowDays;
// 🆕 E11q-b3 — M5-5 차단 보드 VM(설계 13 §8 R185 · 01 §34 K154 · K155).
export 'src/safety/block_board.dart'
    show BlockBoardTexts, blockBoardVmOf, breakerLadderVmOf, routePatternOf;
// 🆕 E13e2 — 브레이커 사다리 원천(M5-4 · 설계 13 §8 R63 V4).
export 'src/safety/breaker_ladder.dart'
    show BreakerLadderStep, breakerLadderOf, ladderPercent;
// 🆕 E13f1 — 재량 예산 SAF-409 판정 · 예산 셈 · 게이지 문장(설계 13 §8 R64).
export 'src/safety/discretion.dart'
    show
        DiscretionBudget,
        DiscretionCodes,
        DiscretionJournalFacts,
        DiscretionJudgement,
        discretionBudgetOf,
        discretionBudgetText,
        discretionJournalLinked,
        discretionRecoveryDate,
        discretionWindowStart,
        judgeDiscretion,
        kDiscretionJournalKind,
        kDiscretionMaxDelta,
        kDiscretionMaxUses,
        rollingDiscretionUses;
// 🆕 E13e2 — 안전 사건 꼴 · MANUAL_ORDER SEV2 · postmortem 판정(설계 13 §8 R63).
export 'src/safety/incident.dart'
    show
        PostmortemCodes,
        SafetyIncident,
        StoppedIncident,
        kManualOrderPostmortemDue,
        manualOrderIncidentOf,
        postmortemClosesIncident,
        postmortemOverdue,
        postmortemRejectCode;
// 🆕 E13f2 — 수동 개입 5단계 상태기계(M5-6 · 설계 13 §8 R65).
export 'src/safety/intervention.dart'
    show
        InterventionCodes,
        InterventionJournalFacts,
        InterventionOutcome,
        InterventionState,
        InterventionStep,
        interventionExecutable,
        interventionJournalLinked,
        interventionRejectCode,
        interventionStateOf,
        kCoolingStage,
        kExecuteStage,
        kInterventionCooling,
        kInterventionExecuteWindow,
        kInterventionStages,
        kJournalStage;
// 🆕 E13a — 킬스위치 발동 순서기 · 저장 포트(SPEC v2.40 04 §3-6 · 설계 13 §8 R56 K6).
export 'src/safety/kill_activation.dart'
    show
        KillActivationResult,
        KillCancelCandidate,
        KillCancelItem,
        KillCancelOutcome,
        KillCancelReport,
        KillSwitchStore,
        activateKillSwitch,
        planKillCancels;
// 🆕 E13a — 킬스위치 체크리스트 두 벌 · 재개판 · tryResume(설계 13 §8 R56 K3~K5).
export 'src/safety/kill_checklist.dart'
    show
        KillAckAnswers,
        KillActivationAnswers,
        KillChecklistVerdict,
        KillReasonKind,
        KillScope,
        ResumeChecklist,
        ResumeConditionStatus,
        ResumeDecision,
        ResumeItemAnswer,
        ScenarioStatus,
        activationChecklistVerdict,
        tryResume;
// 🆕 E13a — 킬스위치 활성 판정 · 재개 준비 · 화면 문장(설계 13 §8 R56 K1 · K2).
export 'src/safety/kill_resume_gate.dart'
    show
        KillActivationReplay,
        KillResumeGateTexts,
        killResumeGateVmOf,
        killResumeItemAnswerOf,
        killResumeResultOf;
export 'src/safety/kill_switch.dart'
    show
        KillSwitchConfig,
        KillSwitchRecord,
        ResumeReadiness,
        ResumeReadinessKind,
        effectiveChecklistConfirmedAt,
        kP0sKillSwitchConfig,
        killSwitchActive,
        killSwitchViewOf,
        resumeReadinessOf;
// 🆕 E13g2 — 본인 서약문 · 12월 편집 창 · DD 최초 도달 재생(M5-8 · 설계 13 §8 R67).
export 'src/safety/kill_switch_screen.dart'
    show
        KillCommandTexts,
        KillSwitchScreenTexts,
        issueKillCommand,
        kKillCommandTtl,
        kKillSwitchStaleAfter,
        killCommandReceiptOf,
        killActivationFormVm,
        killCancelHeadline,
        killChecklistAnswersOf,
        killSwitchScreenVmOf;
export 'src/safety/pledge.dart'
    show
        DrawdownEpisode,
        DrawdownPoint,
        Pledge,
        PledgeCodes,
        PledgeReplayDue,
        currentEpisodeOf,
        kPledgeReplayDd,
        kPledgeSentences,
        pledgeEditRejectCode,
        pledgeReplayDueOf,
        pledgeSentencesOf,
        pledgeWriteRejectCode;
// 🆕 E11p4h — 서약 읽기 모델 · 동작 결과(설계 13 §8 R157 · 01 §30 K16).
export 'src/safety/pledge_view.dart'
    show
        PledgeResultTexts,
        kPledgeStaleAfter,
        pledgeActionResultOf,
        pledgeAsOf,
        pledgeSubmissionDigest,
        pledgeVmOf;
// 🆕 E13g1 — 규칙 변경 게이트 · SAF-405 기동 통제(M5-9 · 설계 13 §8 R66).
export 'src/safety/rule_change.dart'
    show
        RuleChangeCodes,
        RuleChangeRequestFacts,
        RuleChangeType,
        StartupGate,
        isFirstApproval,
        kNoApprovedConfig,
        kRuleChangeCooling,
        kRuleChangeDrawdownLock,
        kRuleChangeWindowMonth,
        kSaf405,
        ruleChangeApproveRejectCode,
        ruleChangeCancelRejectCode,
        ruleChangeJournalLinked,
        ruleChangeRequestRejectCode,
        startupConfigGate;
// 🆕 E11q-c0 — M5-9 규칙 변경 게이트 «첫 승인 최소판» VM · 후보 · 결과(설계 13 §8 R188 · 01 §35 K177~K180).
export 'src/safety/rule_change_gate.dart'
    show
        RuleChangeCandidate,
        RuleChangeGateItem,
        RuleChangeGateTexts,
        kBiometricUnavailable,
        kJournalIdTaken,
        kRuleChangeGateStaleAfter,
        ruleChangeActionResultOf,
        ruleChangeApprovable,
        ruleChangeCandidateOf,
        ruleChangeGateAsOf,
        ruleChangeGateVmOf;
// 🆕 E13e1 — 안전 상태 조립(플래그 12 사전 · 정렬 · 게이지 · 램프 · 설계 13 §8 R62).
export 'src/safety/safety_text.dart'
    show
        FlagEntry,
        GaugeCodes,
        StoredBlockFlag,
        blockFlagsOf,
        breakerLabelOf,
        checkpointLabelOf,
        contractBreakerLevelOf,
        kFlagDictionary,
        rampLevelOf,
        releaseProgressOf,
        safetyAsOf,
        safetyStateOf;
// 🆕 E13d2 — STOPPED 결정 A/B/C 판정(SPEC v2.40 04 §2 · 03_운영 §6-4b · 설계 13 §8 R61).
export 'src/safety/stopped_decision.dart'
    show
        StoppedDecisionAnswers,
        StoppedDecisionCodes,
        StoppedDecisionKind,
        StoppedDecisionVerdict,
        judgeStoppedDecision;
// 🆕 E11d — 키 금고 포트 · 마스킹 · 지문 · 회전 · 봉함(설계 13 §8 R44 · 06 M4-4 순수 몫).
export 'src/security/key_rotation.dart'
    show
        KeyRotation,
        KeyRotationStage,
        RotationOutcome,
        rotateSecret,
        stagedSecretId;
export 'src/security/sealed_box.dart' show SealedBox;
export 'src/security/secret_mask.dart'
    show
        kMinRedactLength,
        kRedacted,
        maskAccount,
        maskSecret,
        redactSecrets,
        secretFingerprint;
export 'src/security/secret_vault.dart'
    show SecretId, SecretVault, SecretVaultError, readAllSecretValues;
export 'src/signals/exposure_gate.dart'
    show directionFactor, exposureGate, trendFactor;
export 'src/signals/hysteresis.dart'
    show
        DirectionHysteresis,
        TrendHysteresis,
        applyHysteresis,
        applyTrendHysteresis;
export 'src/signals/indicators.dart'
    show adx, atr, bbw, chop, rma, rmaStep, sma, trueRange;
export 'src/signals/percentile.dart' show pitPercentile, rollingPercentile;
export 'src/signals/regime_pipeline.dart'
    show
        IndicatorSign,
        RegimeDay,
        RegimeIndicatorMeta,
        directionScores,
        distributionDays,
        kRegimeCategories,
        kRegimeIndicatorMeta,
        maskVolumeGaps,
        meanOfAvailable,
        momentum12Minus1,
        normalizeIndicators,
        runRegimeFsm,
        trendIndicators,
        trendScoreKr,
        trendinessParts;
export 'src/signals/regime_score.dart'
    show
        CategoryInput,
        DirectionScore,
        IndicatorScore,
        RegimeCategory,
        RegimeStatus,
        aggregateDirection,
        categoryScore,
        directionFromCategoryScores;
export 'src/signals/regime_states.dart' show DirectionState, TrendState;
export 'src/signals/seasonal_exit.dart' show seasonalExitFraction;
export 'src/signals/sleeve_b_tranche.dart'
    show SleeveBAssist, sleeveBTargetRatioP0, sleeveBTargetWeight;
// 🆕 E15c1 — 엔진 내부 가상 체결 브로커(같은 포트 · 원장 주문 · 15:40 뒤 판정 · 설계 13 §8 R83 Y3~Y7).
export 'src/sim/sim_internal_broker.dart'
    show
        SimExecution,
        SimInternalBroker,
        SimLedgerView,
        SimOrder,
        kSimCancelTooLate,
        kSimInvalidOrder,
        kSimOdnoPrefix,
        kSimOrderNotFound,
        simOrderableCashOf;
// 🆕 E15d1 — 모의 개시(가상 초기금 나눔 · 시딩 전략 · 체험 시작 문 · 설계 13 §8 R85 AA3 · AA4).
export 'src/sim/sim_opening.dart'
    show
        SimOpeningCodes,
        SimOpeningSplit,
        kP0sSeedStrategies,
        kSeedCapitalCap,
        kSeedStrategyState,
        p0sStrategyOfSleeve,
        simOpeningDecisionId,
        simOpeningSplit,
        simTrialStartReject;
// 🆕 E15d2 — 체험 5항목 판정 · 요약 카운터(설계 13 §8 R87 AB1~AB11).
export 'src/sim/sim_trial.dart'
    show
        SimTrialCounters,
        SimTrialFacts,
        SimTrialFactsSource,
        SimTrialItem,
        SimTrialItemResult,
        SimTrialItemState,
        SimTrialKillEvent,
        SimTrialRebalance,
        SimTrialRecon,
        SimTrialReport,
        SimTrialResumeRun,
        judgeSimTrial,
        kSimTrialBatchJob,
        kSimTrialMonthlyKind,
        kSimTrialRequiredSessions;
// 🆕 E15c1 — 가상 체결가(주문 세션 당일 봉 · SPEC v2.44 · 설계 13 §8 R83 Y2).
export 'src/sim/virtual_fill.dart'
    show kVirtualLimitOrder, kVirtualMarketOrder, virtualFillPrice;
export 'src/whatif/after_tax.dart'
    show
        AfterTaxBranch,
        AfterTaxFull,
        AfterTaxFullInputs,
        AfterTaxInputs,
        AfterTaxPoint,
        TaxLedgerRow,
        afterTaxFull,
        applyDailyTax,
        comprehensiveExtra,
        kAfterTaxPointKeys,
        kDividendTaxRate,
        kFinancialIncomeThreshold,
        kPensionCreditCap,
        kPensionCreditRate,
        kPensionWithdrawalTaxes,
        kTaxLadderBranchRates,
        kTaxLadderGoldenKeys,
        realizedGains;
export 'src/whatif/after_tax_ladder.dart'
    show buildAfterTaxLadder, kHonestHaircutPctPoints;
export 'src/whatif/amount_input.dart'
    show
        AmountInput,
        kAmountBlankText,
        kAmountNotNumberText,
        kAmountNotPositiveText,
        parseAmountInput;
export 'src/whatif/deposit_plan.dart'
    show DepositPlanTexts, buildDepositPlan, simulateDepositPreview;
export 'src/whatif/deposit_register.dart'
    show
        DepositAccountAmount,
        DepositAccountGap,
        DepositAccountRole,
        DepositCashRow,
        DepositLedgerEntry,
        DepositPlanSnapshot,
        DepositRegisterCommand,
        DepositRegisterExecuted,
        DepositRegisterHeld,
        DepositRegisterOutcome,
        DepositRegisterRejected,
        DepositRegisterTexts,
        LedgerCashRow,
        NoPensionDeclaration,
        PensionDeclarationSource,
        depositAccountSplit,
        depositDecisionId,
        depositLedgerEntry,
        depositPensionShare,
        depositPlanVsActual,
        depositReceipt,
        depositTradeDate,
        judgeDepositRegistration,
        kDepositStrategyId,
        kstYear,
        pensionUsedInYear;
export 'src/whatif/deposit_register_issue.dart'
    show
        DepositIssueTexts,
        depositTrustedTimeUnknownReceipt,
        issueDepositRegister,
        kDepositRegisterTtl;
export 'src/whatif/engine_what_if_api.dart' show EngineWhatIfApi;
export 'src/whatif/ledger_what_if_state.dart' show whatIfStateFromLedger;
export 'src/whatif/plan_inputs.dart' show PlanInputs;
export 'src/whatif/plan_store.dart'
    show InMemoryPlanSnapshotStore, PlanSnapshotStore, depositPlanId, kstDay;
export 'src/whatif/rebalance_preview.dart'
    show
        RebalancePreviewTexts,
        accountingSleeveValuesOf,
        plannedRebalanceDate,
        previewRebalancePlan;
export 'src/whatif/what_if_config.dart'
    show WhatIfConfig, kP0sParkingSymbol, p0sKrPlanSymbols, p0sMonthEndConfig;
export 'src/whatif/what_if_gates.dart'
    show
        DepositGateTexts,
        DepositPreflight,
        RebalanceGateTexts,
        WhatIfGate,
        depositGate,
        depositPreflight,
        depositRegisterBlockedText,
        kGateButtonLabels,
        rebalanceGate,
        rebalancePreflight;
export 'src/whatif/what_if_state.dart'
    show WhatIfAccounts, WhatIfState, WhatIfStateSource;
export 'src/whatif/what_if_text.dart'
    show commaWonText, daysToYearEnd, koreanDateText, sharesText, wonText;
