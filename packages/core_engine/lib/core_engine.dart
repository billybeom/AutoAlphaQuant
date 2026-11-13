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
    show NextRebalance, nextRegularRebalance;
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
        JobHeartbeat,
        PauseReason,
        PingStatus,
        RemoteCheck,
        RemoteCheckStatus,
        WatchdogRemote,
        isNeverPauseSlug,
        kNeverPauseChecks;
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
// 🆕 E14b — 재개 판정 순수(06 X2-2 · X2-3 · X2-5 · X2-6 · SPEC v2.42 04 §3-1 ②③④ · §5-3 · 설계 13 §8 R72).
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
        reevaluatedJudgement,
        resumeAutoAllows,
        resumeHaltReason,
        resumePriorityOrder,
        resumeReleasesFlag,
        seasonalChoiceJudgement,
        seasonalChoiceRejectCode;
export 'src/resume/resume_text.dart'
    show
        resumeCountsOf,
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
export 'src/whatif/engine_what_if_api.dart' show EngineWhatIfApi;
export 'src/whatif/plan_inputs.dart' show PlanInputs;
export 'src/whatif/plan_store.dart'
    show InMemoryPlanSnapshotStore, PlanSnapshotStore, depositPlanId, kstDay;
export 'src/whatif/rebalance_preview.dart'
    show RebalancePreviewTexts, plannedRebalanceDate, previewRebalancePlan;
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
