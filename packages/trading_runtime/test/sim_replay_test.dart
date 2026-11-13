// 🆕 E15c2 — 가상 체결 리플레이(설계 13 §8 R84 Z1 · Z2 · SPEC v2.44 04 §3-1 v2.44 ③ · 앱 06 X6-3).
//
// 🔴 진짜 잡(`KrOrderJobs`) + 진짜 시뮬레이터(`SimInternalBroker`)를 2거래주(KR 10세션) 돌린다 — 07:00 대사 · 09:10 오전 · 15:45 마감.
//    원장 = core `FakeOrderLedger` · 시뮬레이터가 읽는 원장 = 그 위 시험용 `SimLedgerView`(SQLite 끝까지는 조립 · E11p).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

Decimal _d(String s) => Decimal.parse(s);

DateTime _kst(TradeDate day, int h, int m) =>
    DateTime.parse('${day.yyyyMmDd}T00:00:00Z')
        .add(Duration(hours: h - 9, minutes: m));

const String _sym = '133690';

final LimitConfig _limits = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: _d('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

final LimitState _ok = LimitState(
  totalEquity: _d('100000000'),
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

final DraftQuote _quote = DraftQuote(
  previousClose: _d('173315'),
  tickSize: _d('5'),
  upperLimit: _d('225305'),
  lowerLimit: _d('121325'),
);

OrderTarget _target(String logical, OrderSide side, int shares) => OrderTarget(
  logicalDecisionId: logical,
  strategyId: P0sStrategyIds.sleeveB,
  symbol: _sym,
  side: side,
  sizing: ShareSizing(shares),
  instrument: InstrumentKind.etf,
);

class _Targets implements TargetSource {
  final Map<String, List<OrderTarget>> byDay = <String, List<OrderTarget>>{};

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async =>
      byDay[today.yyyyMmDd] ?? const <OrderTarget>[];
}

class _Quotes implements DraftQuoteSource {
  @override
  Future<Map<String, DraftQuote>> quotesFor(Set<String> symbols) async =>
      <String, DraftQuote>{for (final String s in symbols) s: _quote};
}

class _Beat implements JobHeartbeat {
  final List<(String, PingStatus, String?)> pings =
      <(String, PingStatus, String?)>[];

  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async => pings.add((check, status, note));
}

class _Alerts implements AlertSink {
  final List<Set<String>> sent = <Set<String>>[];

  @override
  Future<void> emit(String check, Set<String> codes) async => sent.add(codes);
}

class _Bars implements DailyQuoteFeed {
  final Map<String, QuoteBar> byDay = <String, QuoteBar>{};
  final List<String> asked = <String>[];

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
  }) async {
    asked.add(from);
    return QuoteFetch(
      bars: <QuoteBar>[?byDay[from]],
      pageBodies: const <String>[],
      attempts: 1,
    );
  }
}

/// 시뮬레이터가 읽는 원장 — `FakeOrderLedger` 위(계좌 하나 · 수수료 0 설정).
class _View implements SimLedgerView {
  _View(this.ledger, this.account, this.strategies, this.opening);

  final FakeOrderLedger ledger;
  final String account;
  final Set<String> strategies;
  final double opening;
  final List<(String, String)> gaps = <(String, String)>[];

  Iterable<FakeIntentRecord> get _sim => ledger.records.values.where(
    (FakeIntentRecord r) =>
        r.row.account == account &&
        (r.brokerOrderNo?.contains(':$kSimOdnoPrefix') ?? false),
  );

  SimOrder _order(FakeIntentRecord r) {
    final String no = r.brokerOrderNo!;
    final int cut = no.indexOf(':');
    return SimOrder(
      orderDate: TradeDate(no.substring(0, cut)),
      odno: no.substring(cut + 1),
      symbol: r.row.symbol,
      side: r.row.side,
      quantity: r.row.quantity,
      orderType: r.row.orderType,
      limitPrice: r.row.limitPrice == null
          ? null
          : double.parse(r.row.limitPrice.toString()),
    );
  }

  @override
  Future<List<SimOrder>> ordersOf(TradeDate orderDate) async => <SimOrder>[
    for (final FakeIntentRecord r in _sim)
      if (r.brokerOrderNo!.startsWith('${orderDate.yyyyMmDd}:')) _order(r),
  ]..sort((SimOrder a, SimOrder b) => a.odno.compareTo(b.odno));

  @override
  Future<SimOrder?> orderNo(String brokerOrderNo) async {
    for (final FakeIntentRecord r in _sim) {
      if (r.brokerOrderNo == brokerOrderNo) return _order(r);
    }
    return null;
  }

  @override
  Future<int> maxSimSeq(TradeDate orderDate) async {
    int max = 0;
    for (final SimOrder o in await ordersOf(orderDate)) {
      final int n = int.parse(o.odno.substring(kSimOdnoPrefix.length));
      if (n > max) max = n;
    }
    return max;
  }

  @override
  Future<double> cashFlowSum() async => opening;

  @override
  Future<List<SimExecution>> executions() async => <SimExecution>[
    for (final FillDelta d in ledger.executions)
      SimExecution(
        side: d.side,
        quantity: d.quantity,
        price: double.parse(d.price.toString()),
        commission: 0,
        tax: 0,
      ),
  ];

  @override
  Future<List<SimOrder>> openBuys() async => <SimOrder>[
    for (final FakeIntentRecord r in _sim)
      if (r.row.side == OrderSide.buy && r.status == IntentStatus.submitted)
        _order(r),
  ];

  @override
  Future<Map<String, int>> holdings() async {
    final Map<String, int> out = <String, int>{};
    ledger.positions.forEach(((String, String) k, int q) {
      if (strategies.contains(k.$1) && q > 0) {
        out[k.$2] = (out[k.$2] ?? 0) + q;
      }
    });
    return out;
  }

  @override
  Future<void> recordBarGap(TradeDate date, String symbol) async =>
      gaps.add((date.yyyyMmDd, symbol));
}

void main() {
  test('🔴 2거래주(KR 10세션) — 미달 실효 → 이월 → 시가 체결 · 매도 지정가 체결 · 봉 없음 → 공백 → 이월 → 체결 · 매일 대사 MATCHED · UNKNOWN · 알림 0 · 끝 보유 = 원장 = 브로커', () async {
    final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);
    final List<TradeDate> days = <TradeDate>[
      for (
        TradeDate d = const TradeDate('2026-11-02');
        d.yyyyMmDd.compareTo('2026-11-13') <= 0;
        d = kr.nextSession(d)
      )
        d,
    ];
    expect(days, hasLength(10));
    late DateTime clock;
    final FakeOrderLedger ledger = FakeOrderLedger(
      registeredStrategies: <String>{P0sStrategyIds.sleeveB},
    )..clock = () => clock;
    final _View view = _View(ledger, 'pension', <String>{
      P0sStrategyIds.sleeveB,
    }, 10000000);
    final _Bars bars = _Bars();
    final SimInternalBroker broker = SimInternalBroker(
      ledger: view,
      bars: bars,
      nowUtc: () => clock,
    );
    final _Targets targets = _Targets();
    final _Beat beat = _Beat();
    final _Alerts alerts = _Alerts();
    final KrOrderJobs jobs = KrOrderJobs(
      ledger: ledger,
      brokers: <String, AccountBroker>{'pension': broker},
      kr: kr,
      config: KrOrderConfig(
        runMode: RunMode.simInternal,
        operatingMode: OperatingMode.autoTrade,
        execPolicy: ExecPolicy.execute,
        draft: DraftConfig(
          limitOffsetPct: 0.005,
          buyCostRate: 0.00015,
          accountByStrategy: const <String, String>{
            P0sStrategyIds.sleeveB: 'pension',
          },
        ),
        limits: _limits,
        buyCostRate: 0.00015,
        configHash: 'cfg-sim',
        fillCosts: const FillCostRates(commissionRate: 0, sellTaxRate: 0),
        instruments: const <String, InstrumentKind>{_sym: InstrumentKind.etf},
      ),
      targets: targets,
      quotes: _Quotes(),
      limitStateFor: (OrderIntentDraft d) async => _ok,
      heartbeat: beat,
      alerts: alerts,
      nowUtc: () => clock,
      lease: FakeLeaseGate(),
      runLog: FakeJobRunLog(),
      plannedWork: FakePlannedWorkLedger(),
      modeFacts: FakeModeFacts(),
      sleep: (Duration _) async {},
    );

    // 시나리오(R84 Z2) — 지정가: 매수 174,180 · 매도 172,450(직전 종가 173,315 ± 0.5%).
    targets.byDay
      ..['2026-11-02'] = <OrderTarget>[_target('B-BUY-1', OrderSide.buy, 10)]
      ..['2026-11-09'] = <OrderTarget>[_target('B-SELL-1', OrderSide.sell, 4)]
      ..['2026-11-12'] = <OrderTarget>[_target('B-BUY-2', OrderSide.buy, 2)];
    bars.byDay
      // 11-02 저가 174,500 > 매수 지정가 → 미체결 → 실효.
      ..['2026-11-02'] = const QuoteBar(
        date: '2026-11-02',
        close: 175500,
        open: 175000,
        high: 176000,
        low: 174500,
      )
      // 11-03 이월 10 → 시가 174,000 ≤ 지정가 → 시가 체결.
      ..['2026-11-03'] = const QuoteBar(
        date: '2026-11-03',
        close: 174200,
        open: 174000,
        high: 174800,
        low: 173500,
      )
      // 11-09 매도 4 → 시가 172,000 < 지정가 · 고가 173,000 ≥ 지정가 → 지정가 체결.
      ..['2026-11-09'] = const QuoteBar(
        date: '2026-11-09',
        close: 172800,
        open: 172000,
        high: 173000,
        low: 171500,
      )
      // 11-12 봉 없음 → 미체결 + 공백 → 실효 · 11-13 이월 2 → 저가 ≤ 지정가 → 지정가 체결.
      ..['2026-11-13'] = const QuoteBar(
        date: '2026-11-13',
        close: 174600,
        open: 174500,
        high: 175000,
        low: 174100,
      );

    final List<ReconAction> recon = <ReconAction>[];
    final List<JobStatus> statuses = <JobStatus>[];
    for (final TradeDate day in days) {
      clock = _kst(day, 7, 0);
      final JobRun<ReconReport> r = await jobs.runDailyReconcile();
      recon.add(r.report!.action);
      clock = _kst(day, 9, 10);
      final JobRun<KrOrderOpenReport> o = await jobs.runOpen();
      recon.add(o.report!.recon!.action);
      clock = _kst(day, 15, 45);
      final JobRun<KrOrderCloseReport> c = await jobs.runClose();
      statuses.addAll(<JobStatus>[r.status, o.status, c.status]);
    }

    expect(statuses.toSet(), <JobStatus>{JobStatus.success});
    expect(recon.toSet(), <ReconAction>{ReconAction.matched});
    expect(alerts.sent, isEmpty);
    expect(
      ledger.transitions.where(
        ((String, IntentStatus) t) => t.$2 == IntentStatus.unknown,
      ),
      isEmpty,
    );

    // 주문 · 결과(주문일 · 번호 · 방향 · 수량 · 상태).
    final List<(String, String, OrderSide, int, IntentStatus)> orders =
        <(String, String, OrderSide, int, IntentStatus)>[
          for (final FakeIntentRecord r in ledger.records.values)
            if (r.brokerOrderNo != null)
              (
                r.row.tradeDate.yyyyMmDd,
                r.brokerOrderNo!.split(':').last,
                r.row.side,
                r.row.quantity,
                r.status,
              ),
        ]..sort(
          (
            (String, String, OrderSide, int, IntentStatus) a,
            (String, String, OrderSide, int, IntentStatus) b,
          ) => a.$1.compareTo(b.$1),
        );
    expect(orders, <(String, String, OrderSide, int, IntentStatus)>[
      ('2026-11-02', 'SIM0000001', OrderSide.buy, 10, IntentStatus.expired),
      ('2026-11-03', 'SIM0000001', OrderSide.buy, 10, IntentStatus.filled),
      ('2026-11-09', 'SIM0000001', OrderSide.sell, 4, IntentStatus.filled),
      ('2026-11-12', 'SIM0000001', OrderSide.buy, 2, IntentStatus.expired),
      ('2026-11-13', 'SIM0000001', OrderSide.buy, 2, IntentStatus.filled),
    ]);
    expect(
      <(String, OrderSide, int, Decimal)>[
        for (final FillDelta d in ledger.executions)
          (d.brokerOrderNo, d.side, d.quantity, d.price),
      ],
      <(String, OrderSide, int, Decimal)>[
        ('2026-11-03:SIM0000001', OrderSide.buy, 10, _d('174000')),
        ('2026-11-09:SIM0000001', OrderSide.sell, 4, _d('172450')),
        ('2026-11-13:SIM0000001', OrderSide.buy, 2, _d('174180')),
      ],
    );
    expect(view.gaps, <(String, String)>[('2026-11-12', _sym)]);
    expect(ledger.positions[(P0sStrategyIds.sleeveB, _sym)], 8);
    final BrokerBalance b = await broker.balance();
    expect(b.holdings, <String, int>{_sym: 8});
    // 10,000,000 − 1,740,000 + 689,800 − 348,360
    expect(b.cashKrw, _d('8601440'));
    // 봉은 주문 있는 날만 묻는다(판정 = 15:40 뒤 한 번).
    expect(bars.asked, <String>[
      '2026-11-02',
      '2026-11-03',
      '2026-11-09',
      '2026-11-12',
      '2026-11-13',
    ]);
  });
}
