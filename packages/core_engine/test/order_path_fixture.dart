// 주문 경로 시험의 공용 받침 — 초안 · 통과하는 한도 입력 · 한도 설정 · 순서기 문맥.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// 집행일.
const TradeDate kExec = TradeDate('2026-11-02');

/// 한도 설정(02 §4 기본값 — limits_test 와 같다).
final LimitConfig kLimitConfig = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: Decimal.parse('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

/// 초안 하나(ETF · 지정가 기본).
OrderIntentDraft draftOf({
  String symbol = '133690',
  OrderSide side = OrderSide.buy,
  int quantity = 5,
  String strategyId = P0sStrategyIds.sleeveB,
  String account = 'pension',
  String logical = 'B-SMA-2026-10-30',
  String orderType = OrderTypes.limit,
  String price = '174180',
  InstrumentKind instrument = InstrumentKind.etf,
  TradeDate executionDate = kExec,
}) => OrderIntentDraft(
  executionDate: executionDate,
  account: account,
  strategyId: strategyId,
  symbol: symbol,
  side: side,
  quantity: quantity,
  orderType: orderType,
  limitPrice: orderType == OrderTypes.market ? null : Decimal.parse(price),
  sizingPrice: Decimal.parse(price),
  logicalDecisionId: logical,
  decisionId: DecisionIds.forExecution(logical, executionDate),
  instrument: instrument,
);

/// 통과하는 포트폴리오 한도 입력(원장 값 칸은 순서기가 덮는다).
LimitState portfolioOk({Decimal? totalEquity, bool equityKnown = true}) =>
    LimitState(
      totalEquity: equityKnown
          ? (totalEquity ?? Decimal.parse('100000000'))
          : null,
      ordersToday: null,
      riskExposureAfter: 0.5,
      leverageAfter: 0.9,
      positionsAfter: 5,
      satellitePositionsAfter: null,
      satelliteSectorCountAfter: null,
      satelliteAllocation: null,
      satelliteExposure: null,
      satelliteDeployedBefore: null,
      dailyPnlPct: 0,
      fxRateUsdKrw: null,
      strategyRegistered: null,
      tradingBlocked: null,
      journalMissing: null,
      tierBUnjudged: null,
    );

/// 등록된 전략이 든 원장.
FakeOrderLedger ledgerOf({Set<String>? strategies}) => FakeOrderLedger(
  registeredStrategies:
      strategies ??
      <String>{
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
        P0sStrategyIds.pot,
        'satellite_kr',
        'sleeve_a_kr',
      },
);

/// 순서기 문맥.
ExecutionContext ctxOf(
  OrderLedger ledger,
  OrderBroker broker, {
  ExecPolicy execPolicy = ExecPolicy.execute,
  OperatingMode mode = OperatingMode.autoTrade,
  AdviceSink? advice,
  LimitConfig? limitConfig,
}) => ExecutionContext(
  ledger: ledger,
  broker: broker,
  limitConfig: limitConfig ?? kLimitConfig,
  execPolicy: execPolicy,
  operatingMode: mode,
  configHash: 'cfg-test',
  advice: advice,
);
