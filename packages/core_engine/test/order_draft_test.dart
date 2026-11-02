// 주문 초안기 — 지정가(호가 · 상하한) · 수량(D9) · 순매매(D17) · fail-closed 사유 · 월말 계획 대응
// (04 §3-2 v2.38 · 03 §5-3-1 v2.38 · 설계 13 §8 R33 D2 · D9 · D17 · D18 · R34 U3~U7).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _td = TradeDate('2026-10-30'); // 판정일(월 마지막 KR 세션)
const TradeDate _exec = TradeDate('2026-11-02'); // 집행일(다음 KR 세션)

// 133690 류 ETF — 호가 5원 · 상하한 ±30%.
final DraftQuote _etf = DraftQuote(
  previousClose: _d('173315'),
  tickSize: _d('5'),
  upperLimit: _d('225305'),
  lowerLimit: _d('121325'),
);

final DraftConfig _cfg = DraftConfig(
  limitOffsetPct: 0.005,
  buyCostRate: 0.00015,
  accountByStrategy: const <String, String>{
    P0sStrategyIds.sleeveB: 'pension',
    P0sStrategyIds.sleeveC: 'general',
  },
);

OrderTarget _t(
  String logical,
  String strategy,
  OrderSide side,
  OrderSizing sizing, {
  String symbol = '133690',
  InstrumentKind instrument = InstrumentKind.etf,
  bool market = false,
}) => OrderTarget(
  logicalDecisionId: logical,
  strategyId: strategy,
  symbol: symbol,
  side: side,
  sizing: sizing,
  instrument: instrument,
  marketOrder: market,
);

DraftResult _draft(
  List<OrderTarget> targets, {
  Map<String, DraftQuote>? quotes,
  Map<(String, String), int> holdings = const <(String, String), int>{},
  DraftConfig? config,
}) => draftOrders(
  targets,
  executionDate: _exec,
  quotes: quotes ?? <String, DraftQuote>{'133690': _etf, '411060': _etf},
  holdings: holdings,
  config: config ?? _cfg,
);

final String _bSma = DecisionIds.sleeveBSma(_td);
final String _bBand = DecisionIds.band('B', _td);

void main() {
  group('지정가(D9 · U3)', () {
    test('매수 = 종가 × 1.005 를 호가 내림 · 매도 = 종가 × 0.995 를 호가 올림', () {
      // 173315 × 1.005 = 174181.575 → 174180 · 173315 × 0.995 = 172448.425 → 172450.
      expect(limitPriceFor(OrderSide.buy, _etf, 0.005), _d('174180'));
      expect(limitPriceFor(OrderSide.sell, _etf, 0.005), _d('172450'));
    });

    test('호가 배수에 떨어지면 그대로(안쪽 맞춤이 한 호가를 더 깎지 않는다)', () {
      final DraftQuote q = DraftQuote(
        previousClose: _d('10000'),
        tickSize: _d('10'),
        upperLimit: _d('13000'),
        lowerLimit: _d('7000'),
      );
      expect(limitPriceFor(OrderSide.buy, q, 0.005), _d('10050'));
      expect(limitPriceFor(OrderSide.sell, q, 0.005), _d('9950'));
      expect(limitPriceFor(OrderSide.buy, q, 0), _d('10000'));
    });

    test('상 · 하한 밖이면 안으로 — 상하한도 호가 배수로 맞춘다', () {
      final DraftQuote q = DraftQuote(
        previousClose: _d('10000'),
        tickSize: _d('10'),
        upperLimit: _d('13005'),
        lowerLimit: _d('6995'),
      );
      expect(limitPriceFor(OrderSide.buy, q, 0.5), _d('13000'));
      expect(limitPriceFor(OrderSide.sell, q, 0.5), _d('7000'));
    });

    test('시세 · offset 이 앞뒤가 안 맞으면 거절', () {
      final DraftQuote bad = DraftQuote(
        previousClose: _d('10000'),
        tickSize: Decimal.zero,
        upperLimit: _d('13000'),
        lowerLimit: _d('7000'),
      );
      expect(bad.isValid, isFalse);
      expect(
        () => limitPriceFor(OrderSide.buy, bad, 0.005),
        throwsArgumentError,
      );
      expect(
        () => limitPriceFor(OrderSide.buy, _etf, 1.0),
        throwsArgumentError,
      );
      expect(
        () => limitPriceFor(OrderSide.buy, _etf, -0.01),
        throwsArgumentError,
      );
    });
  });

  group('수량(D9 · U5)', () {
    test('매수 금액 → floor(금액 ÷ (지정가 × (1 + 비용률))) · 지정가 · 결정 id · 멱등키', () {
      // 1,000,000 ÷ (174180 × 1.00015) = 5.74… → 5.
      final DraftResult r = _draft(<OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
      ]);
      expect(r.issues, isEmpty);
      final OrderIntentDraft d = r.drafts.single;
      expect(d.quantity, 5);
      expect(d.side, OrderSide.buy);
      expect(d.orderType, OrderTypes.limit);
      expect(d.limitPrice, _d('174180'));
      expect(d.sizingPrice, _d('174180'));
      expect(d.account, 'pension');
      expect(d.strategyId, 'P0S_B');
      expect(d.market, 'KR');
      expect(d.instrument, InstrumentKind.etf);
      expect(d.logicalDecisionId, 'B-SMA-2026-10-30');
      expect(d.decisionId, 'B-SMA-2026-10-30@2026-11-02');
      expect(
        d.idempotencyKey,
        idempotencyKey(
          market: 'KR',
          account: 'pension',
          symbol: '133690',
          side: 'BUY',
          decisionId: 'B-SMA-2026-10-30@2026-11-02',
        ),
      );
    });

    test('비용률이 주수를 가른다 — 정확히 5주어치 금액은 비용 때문에 4주', () {
      final Decimal five = _d('870900'); // 174180 × 5
      final DraftResult r = _draft(<OrderTarget>[
        _t(_bSma, P0sStrategyIds.sleeveB, OrderSide.buy, AmountSizing(five)),
      ]);
      expect(r.drafts.single.quantity, 4);
      final DraftResult noCost = _draft(
        <OrderTarget>[
          _t(_bSma, P0sStrategyIds.sleeveB, OrderSide.buy, AmountSizing(five)),
        ],
        config: DraftConfig(
          limitOffsetPct: 0.005,
          buyCostRate: 0,
          accountByStrategy: _cfg.accountByStrategy,
        ),
      );
      expect(noCost.drafts.single.quantity, 5);
    });

    test('매도 금액 → floor(금액 ÷ 지정가) · 보유를 넘지 않는다', () {
      // 500,000 ÷ 172450 = 2.89… → 2.
      DraftResult r = _draft(
        <OrderTarget>[
          _t(
            _bBand,
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            AmountSizing(_d('500000')),
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 10},
      );
      expect(r.drafts.single.quantity, 2);
      expect(r.drafts.single.limitPrice, _d('172450'));
      r = _draft(
        <OrderTarget>[
          _t(
            _bBand,
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            AmountSizing(_d('5000000')),
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 10},
      );
      expect(r.drafts.single.quantity, 10);
    });

    test('전량 = 보유 수량 · 주수 = 그대로', () {
      final DraftResult r = _draft(
        <OrderTarget>[
          _t(
            'SEAS-A-OUT-2026-10-30',
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            const AllHeldSizing(),
          ),
          _t(
            'X-1',
            P0sStrategyIds.sleeveC,
            OrderSide.buy,
            const ShareSizing(3),
            symbol: '411060',
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 7},
      );
      expect(r.issues, isEmpty);
      expect(
        r.drafts.map((OrderIntentDraft d) => (d.symbol, d.side, d.quantity)),
        <(String, OrderSide, int)>[
          ('133690', OrderSide.sell, 7),
          ('411060', OrderSide.buy, 3),
        ],
      );
    });

    test('0주 = 초안 없음(ZERO_QUANTITY)', () {
      final DraftResult r = _draft(<OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('100')),
        ),
      ]);
      expect(r.drafts, isEmpty);
      expect(r.issues.single.code, DraftIssueCode.zeroQuantity);
      expect(r.issues.single.code.code, 'ZERO_QUANTITY');
    });
  });

  group('순매매(D17 · U6)', () {
    test('같은 전략 매수 5 · 매도 2 → 순매수 3 · 논리 id 정렬 결합', () {
      final DraftResult r = _draft(
        <OrderTarget>[
          _t(
            _bSma,
            P0sStrategyIds.sleeveB,
            OrderSide.buy,
            AmountSizing(_d('1000000')),
          ),
          _t(
            _bBand,
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            AmountSizing(_d('500000')),
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 10},
      );
      final OrderIntentDraft d = r.drafts.single;
      expect(d.side, OrderSide.buy);
      expect(d.quantity, 3);
      expect(d.limitPrice, _d('174180'));
      expect(d.logicalDecisionId, 'B-SMA-2026-10-30+BAND-B-2026-10-30');
      expect(d.decisionId, 'B-SMA-2026-10-30+BAND-B-2026-10-30@2026-11-02');
    });

    test('입력 순서가 달라도 같은 키(같은 날 재실행 = 같은 멱등키)', () {
      final List<OrderTarget> a = <OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
        _t(
          _bBand,
          P0sStrategyIds.sleeveB,
          OrderSide.sell,
          AmountSizing(_d('500000')),
        ),
      ];
      const Map<(String, String), int> h = <(String, String), int>{
        ('P0S_B', '133690'): 10,
      };
      expect(
        _draft(a.reversed.toList(), holdings: h).drafts.single.idempotencyKey,
        _draft(a, holdings: h).drafts.single.idempotencyKey,
      );
    });

    test('순 0 = 주문 없음(NETTED_OUT)', () {
      final DraftResult r = _draft(
        <OrderTarget>[
          _t(
            _bSma,
            P0sStrategyIds.sleeveB,
            OrderSide.buy,
            const ShareSizing(3),
          ),
          _t(
            _bBand,
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            const ShareSizing(3),
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 10},
      );
      expect(r.drafts, isEmpty);
      expect(r.issues.single.code, DraftIssueCode.nettedOut);
      expect(r.issues.single.logicalDecisionIds, <String>[
        'B-SMA-2026-10-30',
        'BAND-B-2026-10-30',
      ]);
    });

    test('매도 합은 보유를 넘지 않는다(6 + 6, 보유 10 → 10)', () {
      final DraftResult r = _draft(
        <OrderTarget>[
          _t(
            'A-1',
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            const ShareSizing(6),
          ),
          _t(
            'B-1',
            P0sStrategyIds.sleeveB,
            OrderSide.sell,
            const ShareSizing(6),
          ),
        ],
        holdings: const <(String, String), int>{('P0S_B', '133690'): 10},
      );
      expect(r.drafts.single.quantity, 10);
      expect(r.drafts.single.side, OrderSide.sell);
    });

    test('🔴 다른 전략이 같은 (계좌 · 종목)에 오면 그 종목만 내지 않는다(STRATEGY_CONFLICT)', () {
      final DraftResult r = _draft(
        <OrderTarget>[
          _t(
            _bSma,
            P0sStrategyIds.sleeveB,
            OrderSide.buy,
            AmountSizing(_d('1000000')),
          ),
          _t(
            'POT-SMA-2026-10-30',
            P0sStrategyIds.pot,
            OrderSide.buy,
            AmountSizing(_d('1000000')),
          ),
          _t(
            _bSma,
            P0sStrategyIds.sleeveB,
            OrderSide.buy,
            AmountSizing(_d('1000000')),
            symbol: '411060',
          ),
        ],
        config: DraftConfig(
          limitOffsetPct: 0.005,
          buyCostRate: 0.00015,
          accountByStrategy: const <String, String>{
            P0sStrategyIds.sleeveB: 'pension',
            P0sStrategyIds.pot: 'pension',
          },
        ),
      );
      expect(r.drafts.single.symbol, '411060');
      final DraftIssue i = r.issues.single;
      expect(i.code, DraftIssueCode.strategyConflict);
      expect(i.symbol, '133690');
      expect(i.account, 'pension');
      expect(i.strategyIds, <String>['P0S_B', 'P0S_POT']);
    });

    test('다른 전략이라도 계좌가 다르면 따로 묶인다(충돌 아님)', () {
      final DraftResult r = _draft(<OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
        _t(
          'C-REBAL-2026-10-30',
          P0sStrategyIds.sleeveC,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
      ]);
      expect(r.issues, isEmpty);
      expect(r.drafts.map((OrderIntentDraft d) => d.account), <String>[
        'general',
        'pension',
      ]);
    });

    test('시장가가 하나라도 있으면 시장가 · 주문 가격 칸은 비우고 잰 가격은 남긴다', () {
      final DraftResult r = _draft(<OrderTarget>[
        _t(
          'SEAS-A-IN-2026-10-30',
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          const ShareSizing(8),
          market: true,
        ),
      ]);
      final OrderIntentDraft d = r.drafts.single;
      expect(d.orderType, OrderTypes.market);
      expect(d.limitPrice, isNull);
      expect(d.sizingPrice, _d('174180'));
      expect(d.toLimitIntent().entryPrice, _d('174180'));
    });

    test('상품 구분이 갈리면 개별주(L1 을 거는 쪽)', () {
      DraftResult r = _draft(<OrderTarget>[
        _t('A-1', P0sStrategyIds.sleeveB, OrderSide.buy, const ShareSizing(1)),
        _t(
          'B-1',
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          const ShareSizing(1),
          instrument: InstrumentKind.stock,
        ),
      ]);
      expect(r.drafts.single.instrument, InstrumentKind.stock);
      r = _draft(<OrderTarget>[
        _t('A-1', P0sStrategyIds.sleeveB, OrderSide.buy, const ShareSizing(1)),
      ]);
      expect(r.drafts.single.instrument, InstrumentKind.etf);
    });
  });

  group('fail-closed 사유(U3 · U5 · U7)', () {
    test('계좌가 설정에 없으면 그 전략만 내지 않는다(ACCOUNT_UNMAPPED)', () {
      final DraftResult r = _draft(<OrderTarget>[
        _t(
          'POT-SMA-2026-10-30',
          P0sStrategyIds.pot,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
      ]);
      expect(r.drafts.single.strategyId, 'P0S_B');
      expect(r.issues.single.code, DraftIssueCode.accountUnmapped);
      expect(r.issues.single.account, isNull);
      expect(r.issues.single.strategyIds, <String>['P0S_POT']);
    });

    test('사유 순서는 입력 순서와 무관하다(같은 종목 · 계좌 모름 둘 = 전략으로 가른다)', () {
      List<String> order(List<OrderTarget> ts) =>
          _draft(ts).issues
              .map((DraftIssue i) => i.strategyIds.join(','))
              .toList();
      final List<OrderTarget> ts = <OrderTarget>[
        _t('X-1', 'S_Z', OrderSide.buy, const ShareSizing(1)),
        _t('X-2', 'S_A', OrderSide.buy, const ShareSizing(1)),
        _t('X-3', 'S_M', OrderSide.buy, const ShareSizing(1)),
      ];
      expect(order(ts), <String>['S_A', 'S_M', 'S_Z']);
      expect(order(ts.reversed.toList()), <String>['S_A', 'S_M', 'S_Z']);
    });

    test('시세가 없거나 앞뒤가 안 맞으면 내지 않는다', () {
      DraftResult r = _draft(<OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
      ], quotes: const <String, DraftQuote>{});
      expect(r.issues.single.code, DraftIssueCode.quoteMissing);
      r = _draft(
        <OrderTarget>[
          _t(
            _bSma,
            P0sStrategyIds.sleeveB,
            OrderSide.buy,
            AmountSizing(_d('1000000')),
          ),
        ],
        quotes: <String, DraftQuote>{
          '133690': DraftQuote(
            previousClose: _d('10000'),
            tickSize: _d('5'),
            upperLimit: _d('7000'),
            lowerLimit: _d('13000'),
          ),
        },
      );
      expect(r.issues.single.code, DraftIssueCode.quoteInvalid);
      expect(r.drafts, isEmpty);
    });

    test('매도인데 보유를 모르면 내지 않는다 · 매수만이면 보유를 묻지 않는다', () {
      DraftResult r = _draft(<OrderTarget>[
        _t(
          _bBand,
          P0sStrategyIds.sleeveB,
          OrderSide.sell,
          AmountSizing(_d('500000')),
        ),
      ]);
      expect(r.issues.single.code, DraftIssueCode.holdingUnknown);
      r = _draft(<OrderTarget>[
        _t(
          _bSma,
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          AmountSizing(_d('1000000')),
        ),
      ]);
      expect(r.issues, isEmpty);
    });

    test('대상 생성자 — 매수 전량 · 금액 ≤ 0 · 음수 주수는 거절', () {
      expect(
        () => _t('A-1', 'P0S_B', OrderSide.buy, const AllHeldSizing()),
        throwsArgumentError,
      );
      expect(
        () => _t('A-1', 'P0S_B', OrderSide.buy, AmountSizing(Decimal.zero)),
        throwsArgumentError,
      );
      expect(
        () => _t('A-1', 'P0S_B', OrderSide.sell, const ShareSizing(-1)),
        throwsArgumentError,
      );
    });
  });

  test('정렬 = 매도 먼저(kr_order 2단계 D10) · 그다음 계좌 · 종목', () {
    final DraftResult r = _draft(
      <OrderTarget>[
        _t(
          'B-1',
          P0sStrategyIds.sleeveB,
          OrderSide.buy,
          const ShareSizing(1),
          symbol: '411060',
        ),
        _t('C-1', P0sStrategyIds.sleeveC, OrderSide.buy, const ShareSizing(1)),
        _t('B-2', P0sStrategyIds.sleeveB, OrderSide.sell, const ShareSizing(1)),
      ],
      holdings: const <(String, String), int>{('P0S_B', '133690'): 5},
    );
    expect(
      r.drafts.map(
        (OrderIntentDraft d) => '${d.side.wire} ${d.account} ${d.symbol}',
      ),
      <String>[
        'SELL pension 133690',
        'BUY general 133690',
        'BUY pension 411060',
      ],
    );
  });

  test('한도 판정 입력 — ETF 매수는 손절가 없이 통과한다(L1 건너뜀 · GV-39 g15)', () {
    final OrderIntentDraft d = _draft(<OrderTarget>[
      _t(
        _bSma,
        P0sStrategyIds.sleeveB,
        OrderSide.buy,
        AmountSizing(_d('1000000')),
      ),
    ]).drafts.single;
    final LimitIntent it = d.toLimitIntent();
    expect(it.stopPrice, isNull);
    expect(it.instrument, InstrumentKind.etf);
    final LimitCheckResult res = checkAllLimits(
      it,
      LimitState(
        totalEquity: _d('100000000'),
        ordersToday: 0,
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
        strategyRegistered: true,
        tradingBlocked: false,
        journalMissing: false,
        tierBUnjudged: false,
      ),
      LimitConfig(
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
      ),
    );
    expect(res.allowed, isTrue);
    expect(res.adjustedQuantity, 5);
  });

  group('월말 계획 → 주문 대상(U4)', () {
    final MonthEndState after = MonthEndState(
      totalEquity: Decimal.zero,
      bAssets: const <String, Decimal?>{},
      bParking: Decimal.zero,
      bParkingReclassified: Decimal.zero,
      krwCash: Decimal.zero,
      reservedKrw: Decimal.zero,
      cBond: Decimal.zero,
      cGold: Decimal.zero,
      potCash: Decimal.zero,
      potAssets: const <String, Decimal?>{},
      pensionUsedThisYear: Decimal.zero,
      monthIndex: 7,
      regimeState: null,
      monthlyCloses: const <String, List<double>>{},
      hasNextKrSession: true,
      hasNextUsSession: true,
    );

    test('매매 5종 → 논리 id · strategy_id · 방향 · 금액 · 이체 4종은 건너뛴다', () {
      final MonthEndPlan plan = MonthEndPlan(<MonthEndAction>[
        MonthEndAction(MonthEndActionKind.rampContribution, _d('1000')),
        MonthEndAction(MonthEndActionKind.coreBandReclassify, _d('1000')),
        MonthEndAction(MonthEndActionKind.coreBandReclaim, _d('1000')),
        MonthEndAction(MonthEndActionKind.coreBandContribution, _d('1000')),
        MonthEndAction(
          MonthEndActionKind.raiseKrw,
          _d('200'),
          symbol: 'GOLD',
          isBuy: false,
        ),
        MonthEndAction(
          MonthEndActionKind.sleeveBFundingSell,
          _d('300'),
          symbol: '133690',
          isBuy: false,
        ),
        MonthEndAction(
          MonthEndActionKind.potTrade,
          _d('400'),
          symbol: '411060',
          isBuy: true,
        ),
        MonthEndAction(
          MonthEndActionKind.sleeveBOrder,
          _d('500'),
          symbol: '133690',
          isBuy: true,
        ),
        MonthEndAction(
          MonthEndActionKind.sleeveCOrder,
          _d('600'),
          symbol: 'BOND',
          isBuy: false,
        ),
      ], after);
      final List<OrderTarget> ts = targetsFromMonthEnd(
        plan,
        judgmentDate: _td,
        instruments: const <String, InstrumentKind>{
          '133690': InstrumentKind.etf,
          '411060': InstrumentKind.etf,
          'GOLD': InstrumentKind.etf,
        },
      );
      expect(
        ts.map(
          (OrderTarget t) =>
              '${t.logicalDecisionId} ${t.strategyId} ${t.symbol} '
              '${t.side.wire} ${(t.sizing as AmountSizing).krw} ${t.instrument.code}',
        ),
        <String>[
          'FUND-2026-10-30 P0S_C GOLD SELL 200 ETF',
          'BAND-B-2026-10-30 P0S_B 133690 SELL 300 ETF',
          'POT-SMA-2026-10-30 P0S_POT 411060 BUY 400 ETF',
          'B-SMA-2026-10-30 P0S_B 133690 BUY 500 ETF',
          // 상품 맵에 없는 종목 = 개별주(fail-closed).
          'C-REBAL-2026-10-30 P0S_C BOND SELL 600 STOCK',
        ],
      );
      expect(ts.every((OrderTarget t) => !t.marketOrder), isTrue);
    });

    test('매매 행동에 종목 · 방향이 없으면 StateError(계획기 결함)', () {
      final MonthEndPlan plan = MonthEndPlan(<MonthEndAction>[
        MonthEndAction(MonthEndActionKind.sleeveBOrder, _d('500')),
      ], after);
      expect(
        () => targetsFromMonthEnd(plan, judgmentDate: _td),
        throwsStateError,
      );
    });
  });
}
