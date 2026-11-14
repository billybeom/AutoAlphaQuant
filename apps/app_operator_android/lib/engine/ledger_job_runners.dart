// 사람 값이 드는 잡 실물(E11p3c-2 · 설계 13 §8 R99 · 06 M1-28 · R47 F3 · F6~F9 · R48 · R49) —
// `daily_data` · `equity_snapshot` · `seasonal_a` · `monthly_rebalance`.
//
// 🔴 사람 값(A 종목 · 계좌 넷) = 지금 설정(`currentP0sOpsConfig` — 모의 개시 판 · 다시 지은 지문 대조). 못 얻으면 회차 실패
//    (`OpsConfigUnavailable` · FAILED + fail 핑) — 지어내지 않는다.
// 🔴 현금 = 계좌 별칭마다 브로커 하나. simInternal = 엔진 내부 가상 체결(`SimInternalBroker` · 그 계좌 `cash_flow` 합 · R83).
//    simBroker · live 의 현금(KIS 계좌)은 주문 셋과 함께 E11p3c-3 — 그 전에는 `JobNotAssembled`(조용히 0원으로 돌지 않는다).
// 🔴 가상 체결의 봉 원천은 **쓸 때** 만든다(현금만 읽는 잡이 KIS 키를 요구하지 않게 · `_LazyFeed`).
// 🔴 본체는 data_sync 그대로 — 여기는 부품을 넣고 `runOccurrence` 로 감싸기만 한다.

import 'package:core_engine/core_engine.dart'
    show
        AccountBroker,
        DailyQuoteFeed,
        LedgerHolding,
        Market,
        OrderBroker,
        P0sOpsConfig,
        PriceAdjust,
        QuoteFetch,
        QuoteKind,
        SimInternalBroker;
import 'package:data_sync/data_sync.dart'
    show
        DailyDataJob,
        DailyDataReport,
        EquitySnapshotJob,
        EquitySnapshotReport,
        MonthlyRebalanceJob,
        MonthlyRebalanceReport,
        OpsConfigRead,
        OpsConfigReady,
        OpsConfigUnavailable,
        QuoteCollector,
        SeasonalAJob,
        SeasonalAReport,
        SqliteOrderLedger,
        SqliteSimLedgerView,
        currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart'
    show MarketDataSource, RunMode, TradeDate;
import 'package:trading_runtime/trading_runtime.dart'
    show JobBody, JobOccurrence;

import 'data_job_runners.dart' show JobParts;
import 'job_runners.dart'
    show JobContext, JobNotAssembled, JobRunner, runOccurrence;

/// 🔴 지금 설정 — 못 얻으면 그 사유를 던진다(회차 실패).
P0sOpsConfig opsConfigOf(JobContext c) {
  final OpsConfigRead r = currentP0sOpsConfig(c.db);
  switch (r) {
    case OpsConfigReady(config: final P0sOpsConfig cfg):
      return cfg;
    case OpsConfigUnavailable():
      throw r;
  }
}

/// 봉 원천을 처음 쓸 때 만든다.
class _LazyFeed implements DailyQuoteFeed {
  _LazyFeed(this._make);

  final Future<DailyQuoteFeed> Function() _make;
  Future<DailyQuoteFeed>? _feed;

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async => (await (_feed ??= _make())).daily(
    market: market,
    symbol: symbol,
    kind: kind,
    adjust: adjust,
    from: from,
    to: to,
  );
}

/// 🔴 계좌 별칭 → 브로커(설정의 전략 → 계좌를 뒤집어 계좌마다 전략 묶음 · 현금 · 🆕 c3 주문 · 대사가 같이 쓴다).
Map<String, AccountBroker> cashBrokersOf(
  JobContext c,
  JobParts p,
  P0sOpsConfig cfg,
  String job,
) {
  switch (c.runMode) {
    case RunMode.simInternal:
      break;
    case RunMode.simBroker:
    case RunMode.live:
      throw JobNotAssembled(job, <String>['cash_broker_${c.runMode.wire}']);
  }
  final Map<String, Set<String>> strategiesOf = <String, Set<String>>{};
  cfg.human.accountByStrategy.forEach((String strategy, String alias) {
    (strategiesOf[alias] ??= <String>{}).add(strategy);
  });
  final DailyQuoteFeed bars = _LazyFeed(() => p.quoteFeed(c.runMode));
  final List<String> aliases = strategiesOf.keys.toList()..sort();
  return <String, AccountBroker>{
    for (final String alias in aliases)
      alias: SimInternalBroker(
        ledger: SqliteSimLedgerView(
          c.db,
          account: alias,
          strategies: strategiesOf[alias]!,
          clock: c.clock,
        ),
        bars: bars,
        nowUtc: c.clock.nowUtc,
      ),
  };
}

/// 원장 보유(KR · 전략 · 종목 · 수량).
Future<List<LedgerHolding>> Function() holdingsOf(JobContext c) =>
    SqliteOrderLedger(
      c.db,
      mode: c.runMode,
      clock: c.clock,
      kr: c.calendars.kr,
    ).krHoldings;

/// `daily_data`(18:30 KST) — KR 국면 대상 + 계획 종목(설정) 일봉 → KR 하루 판정 → `data_gap`.
JobRunner dailyDataRunner(JobContext c, JobParts p) =>
    (JobOccurrence o) =>
        runOccurrence<DailyDataReport>(c, o, (TradeDate day) async {
          final P0sOpsConfig cfg = opsConfigOf(c);
          final DailyQuoteFeed feed = await p.quoteFeed(c.runMode);
          final DailyDataReport r = await DailyDataJob(
            c.db,
            collector: QuoteCollector(
              c.db,
              feed: feed,
              clock: c.clock,
              kr: c.calendars.kr,
              us: c.calendars.us,
            ),
            kr: c.calendars.kr,
            clock: c.clock,
            krSymbols: cfg.krSymbols,
          ).run(day);
          return JobBody<DailyDataReport>(r, alerts: r.alerts);
        });

/// `equity_snapshot`(20:30 KST · 늦은 끝 23:59) — 종가 × 보유 + 현금 → 스냅숏 · 브레이커(설정 값).
JobRunner equitySnapshotRunner(JobContext c, JobParts p) =>
    (JobOccurrence o) =>
        runOccurrence<EquitySnapshotReport>(c, o, (TradeDate day) async {
          final P0sOpsConfig cfg = opsConfigOf(c);
          final EquitySnapshotReport r = await EquitySnapshotJob(
            c.db,
            cash: cashBrokersOf(c, p, cfg, 'equity_snapshot'),
            mode: c.runMode,
            holdings: holdingsOf(c),
            clock: c.clock,
            config: cfg.breaker,
          ).run(day);
          return JobBody<EquitySnapshotReport>(r, alerts: r.alerts);
        });

/// `seasonal_a`(KR 평일 08:00 · 판정 날에만) — A 종목 = 설정 값.
JobRunner seasonalARunner(JobContext c, JobParts p) =>
    (JobOccurrence o) =>
        runOccurrence<SeasonalAReport>(c, o, (TradeDate day) async {
          final P0sOpsConfig cfg = opsConfigOf(c);
          final SeasonalAReport r = await SeasonalAJob(
            c.db,
            mode: c.runMode,
            kr: c.calendars.kr,
            clock: c.clock,
            cash: cashBrokersOf(c, p, cfg, 'seasonal_a'),
            holdings: holdingsOf(c),
            aSymbol: cfg.aSymbol,
            configHash: cfg.configHash,
            config: cfg.seasonalA,
          ).run(day);
          return JobBody<SeasonalAReport>(r, alerts: r.alerts);
        });

/// `monthly_rebalance`(월말 다음 KR 세션 08:00 · 세션일 = 월말) — 연금 계좌 = B 전략의 계좌.
JobRunner monthlyRebalanceRunner(JobContext c, JobParts p) =>
    (JobOccurrence o) =>
        runOccurrence<MonthlyRebalanceReport>(c, o, (TradeDate monthEnd) async {
          final P0sOpsConfig cfg = opsConfigOf(c);
          final MonthlyRebalanceReport r = await monthlyRebalanceJobOf(
            c,
            cfg,
            cashBrokersOf(c, p, cfg, 'monthly_rebalance'),
          ).run(monthEnd);
          return JobBody<MonthlyRebalanceReport>(r, alerts: r.alerts);
        });

/// 월말 계획 본체 — 🆕 c3 재개 재판정(`SqliteResumeReevaluator`)도 같은 본체를 쓴다.
MonthlyRebalanceJob monthlyRebalanceJobOf(
  JobContext c,
  P0sOpsConfig cfg,
  Map<String, OrderBroker> cash,
) => MonthlyRebalanceJob(
  c.db,
  mode: c.runMode,
  kr: c.calendars.kr,
  us: c.calendars.us,
  clock: c.clock,
  cash: cash,
  holdings: holdingsOf(c),
  pensionAlias: cfg.pensionAlias,
  regimeConfigHash: cfg.regimeConfigHash,
  configHash: cfg.configHash,
  config: cfg.monthEnd,
);
