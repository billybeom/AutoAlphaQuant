// `seasonal_a` 본체 · 계절 대상 · POT 현금 흐름(설계 13 §8 R49 Q1~Q9 · 🆕 06 M1-28 셋째 몫 · 발주자 결정 2026-11-04).
//
// 🔴 판정 날 = 그 달 마지막 3 KR 세션의 첫날 08:00 — 그 밖의 날은 할 일 없음(성공). 입력 = 직전 세션 값.
// 🔴 판정 1건 = `rebalance_event`(SEASONAL) + `decision_log` 한 트랜잭션 · 같은 기준 월말 판정이 있으면 아무것도 안 함(멱등).
// 🔴 연기 계수 = 이번 시즌(10월 1일부터) 마지막 SEASONAL 판정의 «판정 뒤 연기 횟수» · 새 표 0.
// 🔴 POT 현금 = 체결에서 다시 센다(마지막 POT 청산 판정 날부터 · `SEAS-A-OUT` 매도 순대금 + POT 매도 순대금 − POT 매수 대금) —
//    월말 계획기의 POT 입력. 예약 원화 = 0(S7).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/planned_work_store.dart'
    show plannedWorkIdOf, registerPlannedWork, seasonalPlanOneLine;
import '../market/market_ids.dart' show MarketSymbols;
import '../market/market_store.dart';
import 'daily_jobs.dart';

/// 판정 실패 — 🔴 사유 = 종목 · 계좌 별칭 · 날짜만(금액 0). 아무것도 쓰지 않았다.
class SeasonalAError implements Exception {
  /// 실패를 만든다.
  const SeasonalAError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'SeasonalAError($reason)';
}

/// 계절 판정 행 id.
String seasonalEventIdOf(String anchor) => 'REB-SEAS-$anchor';

/// 판정 종류 → 논리 결정 id.
String seasonalDecisionIdOf(SeasonalAOutcome o, TradeDate anchor) =>
    switch (o) {
      SeasonalAOutcome.enter ||
      SeasonalAOutcome.lateEnter => DecisionIds.seasonalAEntry(anchor),
      SeasonalAOutcome.exit => DecisionIds.seasonalAExit(anchor),
      SeasonalAOutcome.defer ||
      SeasonalAOutcome.breakerSkip ||
      SeasonalAOutcome.nothing => 'SEAS-A-GATE-${anchor.yyyyMmDd}',
    };

/// `seasonal_a` 보고.
class SeasonalAReport implements DailyJobReport {
  /// 보고를 만든다.
  const SeasonalAReport({
    required this.decisionDay,
    this.anchor,
    this.outcome,
    this.created = false,
    this.targetShares = 0,
    this.liquidatePot = false,
  });

  /// 판정 날이었나.
  final bool decisionDay;

  /// 기준 월말.
  final String? anchor;

  /// 판정 종류(할 일 없음 = null 또는 nothing).
  final SeasonalAOutcome? outcome;

  /// 이번에 썼나.
  final bool created;

  /// A 목표 주수.
  final int targetShares;

  /// POT 청산.
  final bool liquidatePot;

  @override
  Set<String> get alerts => const <String>{};

  @override
  String toString() =>
      'SeasonalAReport(${decisionDay ? '판정 날 $anchor · ${outcome?.reasonCode ?? 'NONE'}${created ? ' · 새로' : ''}' : '할 일 없음'})';
}

String? _anchorIfDecisionDay(ExchangeCalendar kr, TradeDate today, int days) {
  if (!kr.isSession(today)) return null;
  TradeDate d = today;
  final String month = today.yyyyMmDd.substring(0, 7);
  while (!kr.isLastSessionOfMonth(d)) {
    d = kr.nextSession(d);
    if (d.yyyyMmDd.substring(0, 7) != month) return null;
  }
  final List<TradeDate> exec = seasonalExecutionDays(kr, d, days);
  return exec.first == today ? d.yyyyMmDd : null;
}

Map<String, Object?>? _latestSeasonal(
  Database db, {
  String? before,
  String? from,
}) {
  final ResultSet rs = db.select(
    "SELECT trigger_snapshot FROM rebalance_event WHERE kind = 'SEASONAL' "
    'AND trade_date < ? AND trade_date >= ? ORDER BY trade_date DESC LIMIT 1',
    <Object?>[before ?? '9999-12-31', from ?? '0000-01-01'],
  );
  return rs.isEmpty
      ? null
      : jsonDecode(rs.first['trigger_snapshot'] as String)
            as Map<String, Object?>;
}

/// `seasonal_a`(매 KR 평일 08:00 · 판정 날에만 · R49).
class SeasonalAJob {
  /// 잡을 만든다 — [aSymbol] = 슬리브 A 종목(설정 값 · R49 Q7) · [cash] = 계좌 별칭 → 브로커(D+2).
  SeasonalAJob(
    this._db, {
    required this._mode,
    required this._kr,
    required this._clock,
    required Map<String, OrderBroker> cash,
    required this._holdings,
    required this._aSymbol,
    required this._configHash,
    this._config = const SeasonalAConfig(),
  }) : _cash = Map<String, OrderBroker>.unmodifiable(cash) {
    if (cash.isEmpty) throw ArgumentError('현금 계좌가 없다');
    if (_aSymbol.isEmpty) throw ArgumentError('슬리브 A 종목이 비었다');
  }

  final Database _db;
  final RunMode _mode;
  final ExchangeCalendar _kr;
  final Clock _clock;
  final Map<String, OrderBroker> _cash;
  final Future<List<LedgerHolding>> Function() _holdings;
  final String _aSymbol;
  final String _configHash;
  final SeasonalAConfig _config;

  /// 이번 시즌(10월 1일부터) 연기 횟수.
  int deferCountBefore(TradeDate today) {
    final int y = int.parse(today.yyyyMmDd.substring(0, 4));
    final int m = int.parse(today.yyyyMmDd.substring(5, 7));
    final int seasonYear = m >= _config.entryMonth ? y : y - 1;
    final Map<String, Object?>? last = _latestSeasonal(
      _db,
      before: today.yyyyMmDd,
      from: '$seasonYear-${_config.entryMonth.toString().padLeft(2, '0')}-01',
    );
    return last == null ? 0 : (last['defer_after'] as int? ?? 0);
  }

  Map<String, String> _closeTexts(String day, Iterable<String> symbols) {
    final Map<String, String> out = <String, String>{};
    for (final String s in symbols) {
      final ResultSet rs = _db.select(
        "SELECT close_unadj FROM daily_prices WHERE market = 'KR' AND symbol = ? AND trade_date = ?",
        <Object?>[s, day],
      );
      final Object? v = rs.isEmpty ? null : rs.first['close_unadj'];
      if (v is num && v > 0) out[s] = v.toString();
    }
    return out;
  }

  double? _score(String prev) {
    final List<double?> closes = <double?>[
      for (final PriceBar b in SqliteMarketStore(
        _db,
      ).readBars('KR', MarketSymbols.kosdaq))
        if (b.tradeDate.compareTo(prev) <= 0) b.close,
    ];
    if (closes.isEmpty) return null;
    return trendScoreKr(closes).last;
  }

  BreakerLevel _breaker(String today) {
    final ResultSet rs = _db.select(
      'SELECT breaker_level FROM equity_snapshot WHERE trade_date < ? ORDER BY trade_date DESC LIMIT 1',
      <Object?>[today],
    );
    return rs.isEmpty
        ? BreakerLevel.normal
        : BreakerLevel.fromCode(rs.first['breaker_level'] as String);
  }

  int _monthCount(String today) {
    final ResultSet rs = _db.select(
      "SELECT outputs FROM plan_snapshot WHERE kind = 'REBALANCE' AND as_of_trade_date < ? "
      'ORDER BY as_of_trade_date DESC LIMIT 1',
      <Object?>[today],
    );
    if (rs.isEmpty) return 0;
    final Object? mi = (jsonDecode(
      rs.first['outputs'] as String,
    ) as Map<String, Object?>)['month_index'];
    return mi is int ? mi : 0;
  }

  /// [today] 의 판정 — 판정 날이 아니면 할 일 없음 · 실패면 [SeasonalAError](아무것도 쓰지 않음).
  Future<SeasonalAReport> run(TradeDate today) async {
    final String? anchorText = _anchorIfDecisionDay(
      _kr,
      today,
      _config.splitDays,
    );
    if (anchorText == null) {
      return const SeasonalAReport(decisionDay: false);
    }
    final TradeDate anchor = TradeDate(anchorText);
    final ResultSet existing = _db.select(
      'SELECT trigger_snapshot FROM rebalance_event WHERE event_id = ?',
      <Object?>[seasonalEventIdOf(anchorText)],
    );
    if (existing.isNotEmpty) {
      final Map<String, Object?> t = jsonDecode(
        existing.first['trigger_snapshot'] as String,
      ) as Map<String, Object?>;
      return SeasonalAReport(
        decisionDay: true,
        anchor: anchorText,
        outcome: SeasonalAOutcome.values.byName(t['outcome']! as String),
        targetShares: t['target_shares']! as int,
        liquidatePot: t['liquidate_pot'] == true,
      );
    }
    final int month = int.parse(today.yyyyMmDd.substring(5, 7));
    final int deferBefore = deferCountBefore(today);
    if (month != _config.entryMonth &&
        month != _config.exitMonth &&
        deferBefore == 0) {
      return SeasonalAReport(
        decisionDay: true,
        anchor: anchorText,
        outcome: SeasonalAOutcome.nothing,
      );
    }
    final String prev = _kr.nthSessionBefore(today, 1).yyyyMmDd;
    final List<LedgerHolding> held = await _holdings();
    final SeasonalAInput input;
    try {
      input = await seasonalAInputFromLedger(
        month: month,
        deferCount: deferBefore,
        score: _score(prev),
        breaker: _breaker(today.yyyyMmDd),
        holdings: held,
        closeTexts: _closeTexts(prev, <String>{
          _aSymbol,
          for (final LedgerHolding h in held) h.symbol,
        }),
        cashAccounts: _cash,
        aSymbol: _aSymbol,
        monthCount: _monthCount(today.yyyyMmDd),
      );
    } on SeasonalAInputError catch (e) {
      throw SeasonalAError(e.reason);
    }
    final SeasonalADecision dec = decideSeasonalA(input, config: _config);
    if (dec.outcome == SeasonalAOutcome.nothing) {
      return SeasonalAReport(
        decisionDay: true,
        anchor: anchorText,
        outcome: dec.outcome,
      );
    }
    final List<String> days = <String>[
      for (final TradeDate d in seasonalExecutionDays(
        _kr,
        anchor,
        _config.splitDays,
      ))
        d.yyyyMmDd,
    ];
    final String decisionId = seasonalDecisionIdOf(dec.outcome, anchor);
    final String now = _clock.nowUtc().toIso8601String();
    final Map<String, Object?> trigger = <String, Object?>{
      'outcome': dec.outcome.name,
      'reason_code': dec.outcome.reasonCode,
      'anchor': anchorText,
      'execution_days': days,
      'a_symbol': _aSymbol,
      'side': dec.side?.wire,
      'target_shares': dec.targetShares,
      'liquidate_pot': dec.liquidatePot,
      'defer_before': deferBefore,
      'defer_after': dec.deferCountAfter,
      'score': input.score,
      'gate_score': _config.gateScore,
      'breaker': input.breaker.code,
      'prev_session': prev,
      'prev_equity': input.prevEquity.toString(),
      'a_value': input.aValue.toString(),
      'a_prev_close': input.aPrevClose.toString(),
      'delta_krw': dec.deltaKrw.toString(),
      'month_count': input.monthCount,
    };
    final String kind = switch (dec.outcome) {
      SeasonalAOutcome.enter || SeasonalAOutcome.lateEnter => 'ENTRY',
      SeasonalAOutcome.exit => 'EXIT',
      _ => 'SAFETY',
    };
    final String triggerJson = jsonEncode(trigger);
    final OrderSide? side = dec.side;
    inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO rebalance_event(event_id, trade_date, mode, kind, decision_id, trigger_snapshot, '
        "weights_before, weights_after, config_hash, created_at) VALUES (?, ?, ?, 'SEASONAL', ?, ?, '[]', '[]', ?, ?)",
        <Object?>[
          seasonalEventIdOf(anchorText),
          today.yyyyMmDd,
          _mode.wire,
          decisionId,
          triggerJson,
          _configHash,
          now,
        ],
      );
      // 🆕 E14c2(R74 M1 · M2) — 분할 집행이 있는 판정만 `planned_work` 1행(보류 · 건너뜀 · 할 일 없음 = 0) ·
      //    낼 수 있는 마지막 세션 = 기준(마지막 분할 날).
      if (side != null && dec.targetShares > 0) {
        registerPlannedWork(
          _db,
          kind: ResumeWorkKinds.seasonalWindow,
          decisionId: decisionId,
          dueBy: TradeDate(anchorText),
          oneLine: seasonalPlanOneLine(anchorText, side),
          payloadJson: triggerJson,
          createdAtUtc: now,
        );
      }
      _db.execute(
        'INSERT INTO decision_log(decision_id, created_at, trade_date, mode, kind, strategy_id, sleeve, symbol, '
        "reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, 'A', ?, ?, ?, ?)",
        <Object?>[
          decisionId,
          now,
          today.yyyyMmDd,
          _mode.wire,
          kind,
          P0sStrategyIds.sleeveA,
          _aSymbol,
          '계절 A ${dec.outcome.reasonCode} — ${dec.side?.wire ?? '주문 없음'} ${dec.targetShares}주${dec.liquidatePot ? ' · POT 청산' : ''}',
          dec.outcome.reasonCode,
          _configHash,
        ],
      );
    });
    return SeasonalAReport(
      decisionDay: true,
      anchor: anchorText,
      outcome: dec.outcome,
      created: true,
      targetShares: dec.targetShares,
      liquidatePot: dec.liquidatePot,
    );
  }
}

/// 계절 대상 출처(R49 Q5) — 최근 SEASONAL 판정의 집행일에만 · A 몫(분할) · 진입 첫날 POT 청산.
class SeasonalTargetSource implements TargetSource {
  /// 출처를 만든다.
  SeasonalTargetSource(this._db, {required this._ledger});

  final Database _db;
  final CarryLedger _ledger;

  // 🆕 E14d2a(R76 Q3) — 🔴 낡은 판정 차단: 그 판정의 `planned_work` 가 PLANNED · (REEVALUATED ∧ 재판정 집행)일 때만
  // A 몫을 낸다(없으면 = 옛 판정 · 지금처럼 · 사람 결정 대기 BLOCKED = 0).
  bool _legAllowed(String decisionId) {
    final ResultSet w = _db.select(
      'SELECT state, verdict_code FROM planned_work WHERE work_id = ?',
      <Object?>[plannedWorkIdOf(decisionId)],
    );
    if (w.isEmpty) return true;
    final Object? state = w.first['state'];
    return state == 'PLANNED' ||
        (state == 'REEVALUATED' &&
            w.first['verdict_code'] == VerdictCodes.executedAsReevaluated);
  }

  bool _issuedToday(String id, String today, String symbol, OrderSide side) =>
      _db.select(
        'SELECT 1 FROM order_intents WHERE decision_id = ? AND symbol = ? AND side = ? LIMIT 1',
        <Object?>['$id@$today', symbol, side.wire],
      ).isNotEmpty;

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async {
    final String t = today.yyyyMmDd;
    final Map<String, Object?>? s = _latestSeasonal(_db, before: '${t}z');
    if (s == null) return const <OrderTarget>[];
    final List<String> days = <String>[
      for (final Object? d in s['execution_days']! as List<Object?>)
        d! as String,
    ];
    if (!days.contains(t)) return const <OrderTarget>[];
    final TradeDate anchor = TradeDate(s['anchor']! as String);
    final SeasonalAOutcome outcome = SeasonalAOutcome.values.byName(
      s['outcome']! as String,
    );
    final List<OrderTarget> out = <OrderTarget>[];
    if (s['liquidate_pot'] == true && t == days.first) {
      final String id = DecisionIds.potLiquidation(anchor);
      for (final Row r in _db.select(
        "SELECT symbol, SUM(quantity) AS q FROM positions WHERE market = 'KR' AND strategy_id = ? "
        'GROUP BY symbol ORDER BY symbol',
        <Object?>[P0sStrategyIds.pot],
      )) {
        final String sym = r['symbol'] as String;
        if ((r['q'] as int) <= 0 || _issuedToday(id, t, sym, OrderSide.sell)) {
          continue;
        }
        out.add(
          OrderTarget(
            logicalDecisionId: id,
            strategyId: P0sStrategyIds.pot,
            symbol: sym,
            side: OrderSide.sell,
            sizing: const AllHeldSizing(),
            instrument: InstrumentKind.etf,
          ),
        );
      }
    }
    final String? sideWire = s['side'] as String?;
    final int shares = s['target_shares'] as int? ?? 0;
    if (sideWire != null &&
        shares > 0 &&
        _legAllowed(seasonalDecisionIdOf(outcome, anchor))) {
      final OrderSide side = OrderSide.values.firstWhere(
        (OrderSide x) => x.wire == sideWire,
      );
      final String id = seasonalDecisionIdOf(outcome, anchor);
      final String sym = s['a_symbol']! as String;
      final SplitDay split = await seasonalShareToday(
        _ledger,
        logicalDecisionId: id,
        strategyId: P0sStrategyIds.sleeveA,
        symbol: sym,
        target: shares,
        executionDays: <TradeDate>[for (final String d in days) TradeDate(d)],
        today: today,
      );
      if (split.quantity > 0 && !_issuedToday(id, t, sym, side)) {
        out.add(
          OrderTarget(
            logicalDecisionId: id,
            strategyId: P0sStrategyIds.sleeveA,
            symbol: sym,
            side: side,
            sizing: ShareSizing(split.quantity),
            instrument: InstrumentKind.etf,
            marketOrder: split.marketOrder,
          ),
        );
      }
    }
    return out;
  }
}

/// POT 현금 흐름(R49 Q6) — 마지막 POT 청산 판정 날부터의 체결(`SEAS-A-OUT` 매도 · POT 매수 · 매도 · `POT-LIQ` 제외).
List<PotCashFlow> potCashFlowsSinceLiquidation(Database db) {
  String since = '0000-01-01';
  for (final Row r in db.select(
    "SELECT trade_date, trigger_snapshot FROM rebalance_event WHERE kind = 'SEASONAL' ORDER BY trade_date DESC",
  )) {
    final Map<String, Object?> t =
        jsonDecode(r['trigger_snapshot'] as String) as Map<String, Object?>;
    if (t['liquidate_pot'] == true) {
      since = r['trade_date'] as String;
      break;
    }
  }
  return <PotCashFlow>[
    for (final Row r in db.select(
      'SELECT i.strategy_id, i.side, i.decision_id, e.quantity, e.price, e.commission, e.tax '
      'FROM executions e JOIN broker_orders b ON e.broker_order_no = b.broker_order_no '
      'JOIN order_intents i ON b.intent_id = i.intent_id '
      "WHERE i.trade_date >= ? AND ((i.strategy_id = ? AND i.side = 'SELL' AND i.decision_id LIKE 'SEAS-A-OUT-%') "
      "OR (i.strategy_id = ? AND i.decision_id NOT LIKE 'POT-LIQ-%')) ORDER BY e.executed_at",
      <Object?>[since, P0sStrategyIds.sleeveA, P0sStrategyIds.pot],
    ))
      PotCashFlow(
        r['strategy_id'] == P0sStrategyIds.sleeveA
            ? PotCashFlowKind.aExitSell
            : (r['side'] == 'SELL'
                  ? PotCashFlowKind.potSell
                  : PotCashFlowKind.potBuy),
        quantity: r['quantity'] as int,
        priceText: (r['price'] as num).toString(),
        commissionText: (r['commission'] as num).toString(),
        taxText: (r['tax'] as num).toString(),
      ),
  ];
}
