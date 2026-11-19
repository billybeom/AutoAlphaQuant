// 골든벡터 GV-11 · 11e · 11d · 19 · 24(비용) · GV-12 · 12c(거래일) 판정(E11o-b · 설계 13 §8 R163).
//
// 🔴 옛 시험(`test/golden/gv11_costs_test.dart` · `gv12_calendar_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다.
// 🔴 비용 설정 = 02 §4 `costs.kr`([krCostsFromSpec] · 05 GV-11 설정은 산문이라 정답지 파일이 아니다).
// 🔴 05 GV-11 의 a·b 는 «소형주»라 개별주 세율(ETF 아님)로 계산한다. P0S 의 ETF 매도세 0 은 단위 시험 몫.
// 🔴 GV-19 기대값은 증권거래세 0.18% 시절 값이다(05 검산 «18,000»). 통합 경로는 그 설정으로 정답지와 맞추고,
//    현행 0.20% 로는 매도 비용이 GV-11b 와 같아야 함을 따로 본다(설계 13 §8 R13).
// 🔴 거래일 = 앱이 싣는 lib 동결 달력(`frozenExchangeCalendar`) — 원천 세션 JSON 대조는 시험 몫(frozen_calendar_test ·
//    gv12 머리말 시험).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar, Market;
import '../calendar/frozen_calendar.dart' show frozenExchangeCalendar;
import '../costs/trade_costs.dart'
    show
        KrCostConfig,
        ParticipationCut,
        RoundTripPnl,
        TradeCost,
        applyHoldingCost,
        participationCut,
        roundTripPnl,
        tradeCost,
        weightedExpenseRatio;
import '../risk/limits.dart' show LimitSide;
import 'golden_fixtures.dart'
    show kGv19StaleTaxRate, kTradingDaysPerYear, krCostsFromSpec;
import 'golden_runner.dart';

Market _market(Object? code) => switch (gvString(code)) {
  'KR' => Market.kr,
  'US' => Market.us,
  final String other => throw FormatException('정답지 시장 코드가 낯설다: $other'),
};

LimitSide _side(Object? code) => switch (gvString(code)) {
  'BUY' => LimitSide.buy,
  'SELL' => LimitSide.sell,
  final String other => throw FormatException('정답지 매매 방향이 낯설다: $other'),
};

TradeCost _cost(Map<String, Object?> c, {String? market}) => tradeCost(
  market: _market(market ?? c['market']),
  side: _side(c['side']),
  orderValue: gvDecimal(c['order_value']),
  adv20: gvDecimal(c['adv20']),
  sigmaDaily: gvDouble(c['sigma_daily']),
  isEtf: false,
  config: krCostsFromSpec(),
);

/// 금액 근사(시험 `_expectAmount` 와 같은 규칙 — double 로 바꿔 허용오차 안).
void _amount(
  GvProbe p,
  Decimal actual,
  Object? expected,
  double tol,
  String what,
) => p.close(actual.toDouble(), gvDouble(expected), tol, '$what $actual');

/// GV-11 거래비용 · 11e 구간 경계 · 미국 fail-closed · 11d 참여율 절단 · GV-19 비용의 손익 반영 · GV-24 보유비용
/// (05 §GV-11 · 11d · 11e · 19 · 24 · 03 §5-6 · §5-7).
class Gv11Costs implements GoldenFamily {
  /// 만든다.
  const Gv11Costs();

  @override
  String get id => 'GV-11';

  @override
  Set<String> get files => const <String>{
    'gv11_trade_cost.json',
    'gv11e_tier_boundary_us.json',
    'gv11d_participation.json',
    'gv19_cost_in_pnl.json',
    'gv24_holding_cost.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    // ── GV-11 ──
    final Map<String, Object?> v = b.json('gv11_trade_cost.json');
    final Map<String, Object?> tol = gvObject(v['tolerance']);
    final double amounts = gvDouble(tol['amounts']);
    final double ratios = gvDouble(tol['ratios']);
    final List<Map<String, Object?>> cases = gvObjectList(v['cases']);

    // ── GV-11e ──
    final Map<String, Object?> v11e = b.json('gv11e_tier_boundary_us.json');
    final double amounts11e = gvDouble(gvObject(v11e['tolerance'])['amounts']);

    // ── GV-19 ──
    final Map<String, Object?> v19 = b.json('gv19_cost_in_pnl.json');
    final Map<String, Object?> in19 = gvObject(v19['input']);
    final Map<String, Object?> trade = gvObjectList(in19['trades']).single;
    final Map<String, Object?> e19 = gvObject(v19['expected']);
    final double amounts19 = gvDouble(gvObject(v19['tolerance'])['amounts']);
    RoundTripPnl run19(GvProbe p, KrCostConfig config) {
      p.same(gvString(trade['market']), 'KR', 'market');
      return roundTripPnl(
        entryPrice: gvDecimal(trade['entry_price']),
        exitPrice: gvDecimal(trade['exit_price']),
        quantity: gvInt(trade['quantity']),
        adv20: gvDecimal(trade['adv20']),
        sigmaDaily: gvDouble(trade['sigma_daily']),
        isEtf: false,
        config: config,
      );
    }

    // ── GV-24 ──
    final Map<String, Object?> v24 = b.json('gv24_holding_cost.json');
    final Map<String, Object?> tol24 = gvObject(v24['tolerance']);
    final double amounts24 = gvDouble(tol24['amounts']);
    final double ratios24 = gvDouble(tol24['ratios']);

    return <GvCase>[
      GvCase(
        'GV-11 허용오차가 필드별로 나뉘어 있다(v1.5)',
        () =>
            (GvProbe()
                  ..same(amounts, 0.01, 'amounts')
                  ..same(ratios, 1e-8, 'ratios'))
                .failure,
      ),
      for (int i = 0; i < cases.length; i++)
        GvCase(
          'GV-11${'abc'[i]} ${cases[i]['side']} adv20=${cases[i]['adv20']} σ=${cases[i]['sigma_daily']}',
          () {
            final Map<String, Object?> c = cases[i];
            final Map<String, Object?> e = gvObject(c['expected']);
            final TradeCost r = _cost(c, market: gvString(v['market']));
            final GvProbe p = GvProbe();
            _amount(p, r.commission, e['commission'], amounts, 'commission');
            _amount(p, r.tax, e['tax'], amounts, 'tax');
            _amount(p, r.slippage, e['slippage'], amounts, 'slippage');
            _amount(p, r.marketImpact, e['market_impact'], amounts, 'impact');
            _amount(p, r.total, e['total'], amounts, 'total');
            if (e.containsKey('impact_pct')) {
              p.close(
                r.impactPct,
                gvDouble(e['impact_pct']),
                ratios,
                'impact_pct',
              );
            }
            // 02 §3 불변식 — total = 네 항목의 합.
            p.same(
              r.total,
              r.commission + r.tax + r.slippage + r.marketImpact,
              'total = 네 항목의 합',
            );
            return p.failure;
          },
        ),
      GvCase('GV-11 왕복 a + b = 143,000원(05 «왕복 = 1.43%»)', () {
        final TradeCost buy = _cost(cases[0], market: 'KR');
        final TradeCost sell = _cost(cases[1], market: 'KR');
        return (GvProbe()
              ..same(buy.total + sell.total, Decimal.fromInt(143000), '왕복'))
            .failure;
      }),
      for (final Map<String, Object?> c in gvObjectList(v11e['cases']))
        GvCase('GV-11e ${c['id']} ${c['market']} adv20=${c['adv20']}', () {
          final Map<String, Object?> e = gvObject(c['expected']);
          if (e.containsKey('raises')) {
            return (GvProbe()
                  ..same(gvString(e['raises']), 'NotImplementedError', 'raises')
                  ..throws(
                    () => _cost(c),
                    (Object x) => x is UnimplementedError,
                    'UnimplementedError',
                  ))
                .failure;
          }
          final TradeCost r = _cost(c);
          final GvProbe p = GvProbe();
          _amount(p, r.slippage, e['slippage'], amounts11e, 'slippage');
          _amount(p, r.commission, e['commission'], amounts11e, 'commission');
          _amount(p, r.total, e['total'], amounts11e, 'total');
          return (p
                ..same(r.tax, Decimal.zero, '매수는 거래세 없음')
                ..same(r.marketImpact, Decimal.zero, 'σ = 0'))
              .failure;
        }),
      GvCase('GV-11d 참여율 절단 — 오늘 1,500만 · 나머지 이월', () {
        final Map<String, Object?> v11d = b.json('gv11d_participation.json');
        final Map<String, Object?> input = gvObject(v11d['input']);
        final Map<String, Object?> e = gvObject(v11d['expected']);
        final ParticipationCut r = participationCut(
          desiredValue: gvDecimal(input['desired_value']),
          adv20: gvDecimal(input['adv20']),
          participationRate: gvDouble(input['participation_rate']),
        );
        return (GvProbe()
              ..same(r.allowedValue, gvDecimal(e['allowed_value']), 'allowed')
              ..same(
                r.deferredValue,
                gvDecimal(e['deferred_value']),
                'deferred',
              ))
            .failure;
      }),
      GvCase(
        'GV-19 설정은 GV-11 과 같다(02 §4 costs.kr)',
        () =>
            (GvProbe()..same(gvString(in19['costs']), 'GV-11 설정과 동일', 'costs'))
                .failure,
      ),
      GvCase('GV-19 정답지 원문(0.18% 시절) — net = −비용', () {
        final GvProbe p = GvProbe();
        final RoundTripPnl r = run19(
          p,
          krCostsFromSpec(taxRateSell: kGv19StaleTaxRate),
        );
        _amount(p, r.grossPnl, e19['gross_pnl'], amounts19, 'gross');
        _amount(p, r.buyCost, e19['buy_cost'], amounts19, 'buy');
        _amount(p, r.sellCost, e19['sell_cost'], amounts19, 'sell');
        _amount(p, r.totalCost, e19['total_cost'], amounts19, 'total');
        _amount(p, r.netPnl, e19['net_pnl'], amounts19, 'net');
        return p.failure;
      }),
      GvCase('GV-19 현행 0.20% — 매도 비용 = GV-11b · net −143,000(R13)', () {
        final GvProbe p = GvProbe();
        final RoundTripPnl r = run19(p, krCostsFromSpec());
        final Map<String, Object?> gv11b = gvObject(cases[1]['expected']);
        return (p
              ..same(r.buyCost, Decimal.fromInt(61500), 'buy')
              ..same(r.sellCost, gvDecimal(gv11b['total']), 'sell = GV-11b')
              ..same(r.netPnl, Decimal.fromInt(-143000), 'net'))
            .failure;
      }),
      GvCase(
        'GV-24 마크업 1.15 는 정답지 er 에 이미 곱해져 있다',
        () =>
            (GvProbe()..same(
                  gvDouble(gvObject(v24['config'])['expense_ratio_markup']),
                  1.15,
                  'markup',
                ))
                .failure,
      ),
      for (final Map<String, Object?> c in gvObjectList(v24['cases']))
        GvCase(
          'GV-24 ${c['id']} er=${c['expense_ratio']} days=${c['trading_days']}',
          () {
            final Decimal start = gvDecimal(c['position_value']);
            final Decimal r = applyHoldingCost(
              positionValue: start,
              expenseRatio: gvDouble(c['expense_ratio']),
              tradingDays: gvInt(c['trading_days']),
              tradingDaysPerYear: kTradingDaysPerYear,
            );
            final GvProbe p = GvProbe();
            _amount(p, r, c['expected_value'], amounts24, 'value');
            if (c.containsKey('expected_cost')) {
              _amount(p, start - r, c['expected_cost'], amounts24, 'cost');
            }
            return p.failure;
          },
        ),
      GvCase('GV-24 sleeve_b_weighted — 0.0019205(v2.4 정정값)', () {
        final Map<String, Object?> w = gvObject(v24['sleeve_b_weighted']);
        final double er = weightedExpenseRatio(<({double er, double weight})>[
          for (final Map<String, Object?> a in gvObjectList(w['assets']))
            (er: gvDouble(a['er']), weight: gvDouble(a['w'])),
        ]);
        return (GvProbe()..close(
              er,
              gvDouble(w['expected_weighted_er']),
              ratios24,
              'weighted_er',
            ))
            .failure;
      }),
    ];
  }
}

/// GV-12 거래일 판정 · GV-12c 월 마지막 세션 음성 케이스(05 §GV-12 · AC-B12 중 12 · 12c) · 03 §4-3.
///
/// 🔴 MIC(XKRX · XNYS) → market(KR · US) 변환은 01 §1 `MIC` 상수 그대로(05 §GV-12 v1.5).
/// 🔵 GV-12b(미국 주문의 ET 거래일)는 P0S 에 미국 주문이 없어 보류(설계 13 §7 P-2).
class Gv12Calendar implements GoldenFamily {
  /// 만든다.
  const Gv12Calendar();

  @override
  String get id => 'GV-12';

  @override
  Set<String> get files => const <String>{
    'gv12_trading_day.json',
    'gv12c_last_session_negative.json',
  };

  @override
  List<GvCase> cases(GoldenBundle b) {
    final Map<Market, ExchangeCalendar> calendars = <Market, ExchangeCalendar>{
      for (final Market m in Market.values) m: frozenExchangeCalendar(m),
    };
    final Map<String, Object?> v12c = b.json(
      'gv12c_last_session_negative.json',
    );
    return <GvCase>[
      for (final Map<String, Object?> c in gvObjectList(
        b.json('gv12_trading_day.json')['cases'],
      ))
        GvCase('GV-12 ${gvString(c['calendar'])} ${gvString(c['date'])}', () {
          final TradeDate date = TradeDate(gvString(c['date']));
          final ExchangeCalendar cal =
              calendars[Market.fromMic(gvString(c['calendar']))]!;
          final Map<String, Object?> e = gvObject(c['expected']);
          final GvProbe p = GvProbe()
            ..same(cal.isSession(date), e['is_session'], 'is_session');
          if (e.containsKey('is_last_session_of_month')) {
            p.same(
              cal.isLastSessionOfMonth(date),
              e['is_last_session_of_month'],
              'is_last_session_of_month',
            );
          }
          return p.failure;
        }),
      for (final Map<String, Object?> c in gvObjectList(v12c['cases']))
        GvCase('GV-12c ${gvString(c['date'])}', () {
          final ExchangeCalendar cal =
              calendars[Market.values.firstWhere(
                (Market m) => m.code == gvString(v12c['market']),
              )]!;
          final TradeDate date = TradeDate(gvString(c['date']));
          final Map<String, Object?> e = gvObject(c['expected']);
          return (GvProbe()
                ..same(cal.isSession(date), e['is_session'], 'is_session')
                ..same(
                  cal.isLastSessionOfMonth(date),
                  e['is_last_session_of_month'],
                  'is_last_session_of_month',
                ))
              .failure;
        }),
    ];
  }
}
