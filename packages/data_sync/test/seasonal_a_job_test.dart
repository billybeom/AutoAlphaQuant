// `seasonal_a` 본체 · SeasonalTargetSource · POT 현금 흐름(설계 13 §8 R49 Q1~Q9).
//
// 🔵 잡는 것: ① 판정 날 = 마지막 3 KR 세션의 첫날만 ② 10월 오름세 = 진입(한 트랜잭션 · 멱등) · 내림세 = 연기 → 11월 재시도
//    ③ HALTED = POT 청산만 ④ 4월 = A 전량 ⑤ 대상 = 첫날 POT 청산 + A 분할 몫(마지막 날 시장가) · 이미 낸 것 뺌
//    ⑥ POT 현금 = 체결에서 다시 셈(POT-LIQ 제외 · 청산 판정 날부터).
// 🔵 KR 달력 2025-10: 마지막 3세션 = 10-29 · 30 · 31(금) — 판정 날 = 10-29 · 직전 세션 = 10-28.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2025, 10, 28, 23);
}

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
const String _a = '229200';

/// KQ11 수정 종가 800개(달력 날 · [end] 까지) — [up] = 오름세(점수 높음) · 아니면 내림세.
void _kq(Database db, String end, {required bool up}) {
  final DateTime e = DateTime.parse('${end}T00:00:00Z');
  db.execute("DELETE FROM daily_prices WHERE symbol = 'KQ11'");
  for (int k = 0; k < 800; k++) {
    final String d = e
        .subtract(Duration(days: 799 - k))
        .toIso8601String()
        .substring(0, 10);
    final double c = (up ? 500 + k : 1300 - k).toDouble();
    db.execute(
      'INSERT INTO daily_prices(trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
      "VALUES (?, 'KR', 'KQ11', ?, ?, ?, ?, ?, 1)",
      <Object?>[d, c, c, c, c, c],
    );
  }
}

void _price(Database db, String symbol, String day, double c) => db.execute(
  'INSERT OR REPLACE INTO daily_prices(trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
  "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 1)",
  <Object?>[day, symbol, c, c, c, c, c],
);

void _position(Database db, String strategy, String symbol, int q) =>
    db.execute(
      'INSERT OR REPLACE INTO positions(market, symbol, strategy_id, quantity, avg_price, entry_date, updated_at) '
      "VALUES ('KR', ?, ?, ?, 1, '2025-01-01', 'x')",
      <Object?>[symbol, strategy, q],
    );

int _count(Database db, String table) =>
    db.select('SELECT COUNT(*) AS n FROM $table').first['n'] as int;

void main() {
  late Directory dir;
  late Database db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_seas_');
    db = openLocalLedger(dir.path, RunMode.live);
    _price(db, _a, '2025-10-28', 10000);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SeasonalAJob job({
    List<LedgerHolding> held = const <LedgerHolding>[],
    String cash = '10000000',
  }) => SeasonalAJob(
    db,
    mode: RunMode.live,
    kr: _kr,
    clock: _Clock(),
    cash: <String, OrderBroker>{
      'main': FakeOrderBroker(cashKrw: Decimal.parse(cash)),
    },
    holdings: () async => held,
    aSymbol: _a,
    configHash: 'cfg_seas',
  );

  test('판정 날 = 마지막 3 KR 세션의 첫날만 · 그 밖 = 할 일 없음(성공 · 쓰지 않음)', () async {
    for (final String d in <String>[
      '2025-10-28',
      '2025-10-30',
      '2025-10-31',
      '2025-10-25',
    ]) {
      final SeasonalAReport r = await job().run(TradeDate(d));
      expect(r.decisionDay, isFalse, reason: d);
    }
    expect(_count(db, 'rebalance_event'), 0);
  });

  test(
    '10월 오름세 = 진입 · 한 트랜잭션(rebalance_event SEASONAL + decision_log ENTRY) · 멱등',
    () async {
      _kq(db, '2025-10-28', up: true);
      final SeasonalAReport r = await job().run(const TradeDate('2025-10-29'));
      expect(
        (r.decisionDay, r.anchor, r.outcome, r.created, r.liquidatePot),
        (true, '2025-10-31', SeasonalAOutcome.enter, true, true),
      );
      // 램프 = 앞 월말 계획 없음 → 0 → 사지 않는다.
      expect(r.targetShares, 0);
      final Row e = db.select('SELECT * FROM rebalance_event').single;
      expect(
        (e['event_id'], e['kind'], e['decision_id'], e['mode']),
        ('REB-SEAS-2025-10-31', 'SEASONAL', 'SEAS-A-IN-2025-10-31', 'LIVE'),
      );
      final Map<String, Object?> t =
          jsonDecode(e['trigger_snapshot'] as String) as Map<String, Object?>;
      expect(t['execution_days'], <String>[
        '2025-10-29',
        '2025-10-30',
        '2025-10-31',
      ]);
      expect(
        (t['prev_session'], t['breaker'], t['a_symbol']),
        ('2025-10-28', 'NORMAL', _a),
      );
      expect((t['score']! as double) >= 60, isTrue);
      final Row l = db.select('SELECT * FROM decision_log').single;
      expect(
        (
          l['kind'],
          l['reason_code'],
          l['sleeve'],
          l['strategy_id'],
          l['symbol'],
        ),
        ('ENTRY', 'SEASONAL_ENTRY', 'A', 'P0S_A', _a),
      );
      final SeasonalAReport again = await job(cash: '1')
          .run(const TradeDate('2025-10-29'));
      expect((again.created, again.outcome), (false, SeasonalAOutcome.enter));
      expect(_count(db, 'rebalance_event'), 1);
    },
  );

  test('램프 다 찬 뒤 = 목표 주수 = ⌊평가 × 0.2 ÷ 직전 종가⌋', () async {
    _kq(db, '2025-10-28', up: true);
    db.execute(
      'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
      "VALUES ('REBAL-2025-09-30', 'REBALANCE', 'x', '2025-09-30', '2025-11-03', '{}', ?, 'c')",
      <Object?>[
        jsonEncode(<String, Object?>{
          'month_index': 6,
          'targets': <Object?>[],
          'execution_day': '2025-10-01',
        }),
      ],
    );
    final SeasonalAReport r = await job().run(const TradeDate('2025-10-29'));
    expect(r.targetShares, 200);
  });

  test('10월 내림세 = 연기 · 11월 판정 날 재시도(연기 계수 1 → 내림세면 2)', () async {
    _kq(db, '2025-10-28', up: false);
    final SeasonalAReport oct = await job().run(const TradeDate('2025-10-29'));
    expect((oct.outcome, oct.liquidatePot), (SeasonalAOutcome.defer, false));
    expect(
      db
          .select('SELECT kind, reason_code FROM decision_log')
          .single['reason_code'],
      'F1_ENTRY_DEFER',
    );
    // 11월 마지막 3세션 = 11-26 · 27 · 28 → 판정 날 11-26 · 직전 11-25.
    _price(db, _a, '2025-11-25', 10000);
    _kq(db, '2025-11-25', up: false);
    final SeasonalAJob j = job();
    expect(j.deferCountBefore(const TradeDate('2025-11-26')), 1);
    final SeasonalAReport nov = await j.run(const TradeDate('2025-11-26'));
    expect(nov.outcome, SeasonalAOutcome.defer);
    expect(j.deferCountBefore(const TradeDate('2025-12-26')), 2);
  });

  test('HALTED(최신 equity_snapshot) = POT 청산만 · 사지 않음 · 4월 = A 전량 매도', () async {
    _kq(db, '2025-10-28', up: true);
    db.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, breaker_level, mode) '
      "VALUES ('2025-10-28', 70, 70, 0, 100, -0.3, 'HALTED', 'LIVE')",
    );
    final SeasonalAReport h = await job().run(const TradeDate('2025-10-29'));
    expect(
      (h.outcome, h.liquidatePot, h.targetShares),
      (SeasonalAOutcome.breakerSkip, true, 0),
    );
    expect(db.select('SELECT kind FROM decision_log').single['kind'], 'SAFETY');
    // 2026-04 마지막 3세션 = 04-28 · 29 · 30 → 판정 날 04-28 · 직전 04-27.
    _price(db, _a, '2026-04-27', 12000);
    final SeasonalAReport x = await job(
      held: const <LedgerHolding>[LedgerHolding('P0S_A', _a, 37)],
    ).run(const TradeDate('2026-04-28'));
    expect((x.outcome, x.targetShares), (SeasonalAOutcome.exit, 37));
    expect(
      db
          .select(
            "SELECT decision_id FROM rebalance_event WHERE event_id = 'REB-SEAS-2026-04-30'",
          )
          .single['decision_id'],
      'SEAS-A-OUT-2026-04-30',
    );
  });

  test('브레이커 = 오늘 앞 **가장 최근** 행(옛 HALTED · 최근 NORMAL = 진입)', () async {
    _kq(db, '2025-10-28', up: true);
    db.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, breaker_level, mode) '
      "VALUES ('2025-09-01', 70, 70, 0, 100, -0.3, 'HALTED', 'LIVE'), "
      "('2025-10-28', 100, 100, 0, 100, 0, 'NORMAL', 'LIVE'), "
      "('2025-10-29', 60, 60, 0, 100, -0.4, 'STOPPED', 'LIVE')",
    );
    expect(
      (await job().run(const TradeDate('2025-10-29'))).outcome,
      SeasonalAOutcome.enter,
    );
  });

  test('점수 = 직전 세션까지의 KQ11 만(그 뒤 행은 보지 않는다)', () async {
    _kq(db, '2025-10-28', up: true);
    // 직전 세션 뒤 날짜에 급락 행을 300개 — 보면 점수가 무너져 연기된다.
    for (int k = 1; k <= 300; k++) {
      final String d = DateTime.utc(
        2025,
        10,
        28,
      ).add(Duration(days: k)).toIso8601String().substring(0, 10);
      db.execute(
        'INSERT INTO daily_prices(trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
        "VALUES (?, 'KR', 'KQ11', 1, 1, 1, 1, 1, 1)",
        <Object?>[d],
      );
    }
    expect(
      (await job().run(const TradeDate('2025-10-29'))).outcome,
      SeasonalAOutcome.enter,
    );
  });

  test('4 · 10월이 아니고 연기도 없으면 = 자료를 보지 않고 할 일 없음(A 종가 없어도)', () async {
    db.execute("DELETE FROM daily_prices WHERE symbol = '$_a'");
    // 2026-06 마지막 3세션 = 06-26(금) · 29 · 30 → 판정 날 06-26.
    final SeasonalAReport r = await job().run(const TradeDate('2026-06-26'));
    expect(
      (r.decisionDay, r.outcome, r.created),
      (true, SeasonalAOutcome.nothing, false),
    );
    expect(_count(db, 'rebalance_event'), 0);
  });

  test('🔴 A 직전 종가 없음 · 현금 실패 = SeasonalAError · 아무것도 안 씀', () async {
    db.execute("DELETE FROM daily_prices WHERE symbol = '$_a'");
    await expectLater(
      job().run(const TradeDate('2025-10-29')),
      throwsA(
        isA<SeasonalAError>().having(
          (SeasonalAError e) => e.reason,
          'r',
          'A 종가 없음: $_a',
        ),
      ),
    );
    expect(_count(db, 'rebalance_event'), 0);
  });

  group('SeasonalTargetSource · POT 현금(Q5 · Q6)', () {
    Future<void> enter() async {
      _kq(db, '2025-10-28', up: true);
      db.execute(
        'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
        "VALUES ('REBAL-2025-09-30', 'REBALANCE', 'x', '2025-09-30', '2025-11-03', '{}', ?, 'c')",
        <Object?>[
          jsonEncode(<String, Object?>{
            'month_index': 6,
            'targets': <Object?>[],
            'execution_day': '2025-10-01',
          }),
        ],
      );
      await job().run(const TradeDate('2025-10-29'));
    }

    SeasonalTargetSource src() => SeasonalTargetSource(
      db,
      ledger: SqliteOrderLedger(
        db,
        mode: RunMode.live,
        clock: _Clock(),
        kr: _kr,
      ),
    );

    test('첫날 = POT 청산(전량 · POT 보유 종목마다) + A 몫 ⌈200 ÷ 3⌉ · 둘째 날 = A 몫만 · 마지막 날 = 시장가 · 집행일 밖 = 0', () async {
      _position(db, 'P0S_POT', '133690', 4);
      _position(db, 'P0S_POT', '411060', 0);
      await enter();
      final List<OrderTarget> d1 = await src().targetsFor(
        const TradeDate('2025-10-29'),
      );
      expect(
        d1.map(
          (OrderTarget t) =>
              (t.logicalDecisionId, t.strategyId, t.symbol, t.side),
        ),
        <(String, String, String, OrderSide)>[
          ('POT-LIQ-2025-10-31', 'P0S_POT', '133690', OrderSide.sell),
          ('SEAS-A-IN-2025-10-31', 'P0S_A', _a, OrderSide.buy),
        ],
      );
      expect(d1.first.sizing, isA<AllHeldSizing>());
      expect((d1.last.sizing as ShareSizing).shares, 67);
      expect(d1.last.marketOrder, isFalse);
      final List<OrderTarget> d3 = await src().targetsFor(
        const TradeDate('2025-10-31'),
      );
      expect(d3.single.marketOrder, isTrue);
      expect(await src().targetsFor(const TradeDate('2025-11-03')), isEmpty);
      expect(await src().targetsFor(const TradeDate('2025-10-28')), isEmpty);
    });

    test('🔴 그날 이미 낸 몫(논리 id@그날 · 종목 · 방향)은 뺀다', () async {
      await enter();
      db.execute(
        'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
        "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES ('i1', 'k1', 'x', "
        "'2025-10-29', 'KR', 'main', 'P0S_A', 'SEAS-A-IN-2025-10-31@2025-10-29', ?, 'BUY', 'LIMIT', 67, 'SUBMITTED', 'c', 'x', 'LIVE')",
        <Object?>[_a],
      );
      expect(await src().targetsFor(const TradeDate('2025-10-29')), isEmpty);
    });

    test('POT 현금 = 청산 판정 날부터 SEAS-A-OUT 매도 + POT 매도 − POT 매수 · POT-LIQ · 청산 전 체결 제외', () async {
      await enter();
      int n = 0;
      void fill(
        String date,
        String strategy,
        String decision,
        String side,
        int q,
        double px,
        double comm,
        double tax,
      ) {
        n++;
        db.execute(
          'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
          "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', ?, 'KR', "
          "'main', ?, ?, 'S', ?, 'LIMIT', ?, 'FILLED', 'c', 'x', 'LIVE')",
          <Object?>['i$n', 'k$n', date, strategy, decision, side, q],
        );
        db.execute(
          "INSERT INTO broker_orders(broker_order_no, intent_id, submitted_at, status) VALUES (?, ?, 'x', 'FILLED')",
          <Object?>['b$n', 'i$n'],
        );
        db.execute(
          'INSERT INTO executions(execution_id, broker_order_no, executed_at, quantity, price, commission, tax) '
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
          <Object?>['e$n', 'b$n', '${date}T01:00:00Z', q, px, comm, tax],
        );
      }

      fill(
        '2025-10-01',
        'P0S_POT',
        'POT-SMA-2025-09-30@2025-10-01',
        'BUY',
        9,
        1000,
        1,
        0,
      );
      fill(
        '2025-10-29',
        'P0S_POT',
        'POT-LIQ-2025-10-31@2025-10-29',
        'SELL',
        4,
        150000,
        90,
        0,
      );
      fill(
        '2026-04-28',
        'P0S_A',
        'SEAS-A-OUT-2026-04-30@2026-04-28',
        'SELL',
        10,
        12000,
        18,
        0,
      );
      fill(
        '2026-05-04',
        'P0S_POT',
        'POT-SMA-2026-04-30@2026-05-04',
        'BUY',
        1,
        100000,
        15,
        0,
      );
      fill(
        '2026-05-06',
        'P0S_POT',
        'POT-SMA-2026-04-30@2026-05-06',
        'SELL',
        0 + 1,
        1000,
        1,
        2,
      );
      // 계절 청산이 아닌 A 매도는 POT 로 가지 않는다.
      fill(
        '2026-05-07',
        'P0S_A',
        'A-REBAL-2026-05-07@2026-05-07',
        'SELL',
        5,
        12000,
        9,
        0,
      );
      final List<PotCashFlow> f = potCashFlowsSinceLiquidation(db);
      expect(f.map((PotCashFlow x) => x.kind), <PotCashFlowKind>[
        PotCashFlowKind.aExitSell,
        PotCashFlowKind.potBuy,
        PotCashFlowKind.potSell,
      ]);
      expect(
        potCashOf(f),
        Decimal.parse('119982') -
            Decimal.parse('100015') +
            Decimal.parse('997'),
      );
    });
  });
}
