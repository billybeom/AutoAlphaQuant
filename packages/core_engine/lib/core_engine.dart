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
export 'src/data/regime_inputs.dart'
    show
        RegimeComputation,
        RegimeFreshnessCaps,
        RegimeSources,
        SeriesCadence,
        applyFreshnessCaps,
        computeRegime,
        kP0sDirectionHysteresis,
        kP0sTrendHysteresis,
        kRegimeSourceCadence,
        regimeRawIndicators,
        regimeStaleDays,
        usCalendarLagSessions;
export 'src/decimal_rules.dart'
    show divide, kContextPrecision, mulDiv, multiply, oneMinus, promoteRatio;
export 'src/orders/idempotency.dart'
    show DecisionIds, idempotencyKey, idempotencyRaw;
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
export 'src/portfolio/sleeve_c.dart'
    show
        InflowCurrency,
        SleeveCInflow,
        SleeveCTargets,
        SleeveCWeights,
        sleeveCAllocateInflow,
        sleeveCUsdTargets;
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
        levelFromDrawdown,
        releaseStoppedToHalted,
        stepBreaker;
export 'src/risk/limits.dart'
    show
        LimitCheckResult,
        LimitConfig,
        LimitIntent,
        LimitSide,
        LimitState,
        LimitStatus,
        RiskCheckUnavailable,
        checkAllLimits;
export 'src/risk/position_sizing.dart'
    show SizingBinding, SizingResult, sizePosition;
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
export 'src/whatif/what_if_config.dart' show WhatIfConfig, p0sMonthEndConfig;
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
