// `monthly_rebalance` 본체 · 계획 보관 · StoredPlanTargetSource(설계 13 §8 R48 P1~P10).
//
// 🔵 잡는 것: ① 한 트랜잭션 저장(plan_snapshot REBALANCE · rebalance_event · decision_log) · 집행 첫날 · 만료 · 램프 달
//    ② 멱등(다시 = 아무것도 안 바꿈) ③ 🔴 국면 준비 안 됨 · 귀속 불가 · 현금 실패 = 쓰지 않고 실패 · 🆕 POT 현금 = 체결 재계산
//    ④ 보유 → 상태(원가 종가) ⑤ TargetSource = 집행 첫날 ≤ 오늘 < 만료 · 낸 대상 걸러냄.
// 🔵 국면 = 시드 묶음(기준일 2026-08-14) — 월말 2026-07-31(금 · 미국 세션 있음 · 시드 안) · 다음 KR 세션 08-03(월).

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
  DateTime nowUtc() => DateTime.utc(2026, 7, 31, 23);
}

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final ExchangeCalendar _us = frozenExchangeCalendar(Market.us);
const String _seedAt = '2026-08-15T00:00:00.000Z';
const TradeDate _me = TradeDate('2026-07-31');

void _bar(Database db, String symbol, String day, double close) => db.execute(
  'INSERT OR REPLACE INTO daily_prices(trade_date, market, symbol, open, high, low, close, close_unadj, volume) '
  "VALUES (?, 'KR', ?, ?, ?, ?, ?, ?, 1)",
  <Object?>[day, symbol, close, close, close, close * 0.95, close],
);

void _prices(Database db) {
  final Map<String, double> base = <String, double>{
    '133690': 100000,
    '411060': 15000,
    '0085P0': 10000,
    '214980': 100000,
  };
  for (final MapEntry<String, double> e in base.entries) {
    for (int k = 0; k < 18; k++) {
      final DateTime m = DateTime.utc(2025, 2 + k, 20);
      final String d = m.toIso8601String().substring(0, 10);
      if (d.compareTo('2026-07-01') >= 0) continue;
      _bar(db, e.key, d, e.value * (1 + 0.01 * k));
    }
    _bar(db, e.key, '2026-07-31', e.value * 1.2);
  }
}

void _snapshot(
  Database db,
  String day,
  String level, {
  double hwm = 100,
  double dd = -0.4,
}) => db.execute(
  'INSERT OR REPLACE INTO equity_snapshot(trade_date, total_equity, cash_krw, cash_usd, fx_rate, positions_value, '
  "high_water_mark, drawdown, breaker_level, mode) VALUES (?, ?, ?, 0, NULL, 0, ?, ?, ?, 'LIVE')",
  <Object?>[day, hwm * (1 + dd), hwm * (1 + dd), hwm, dd, level],
);

int _count(Database db, String table) =>
    db.select('SELECT COUNT(*) AS n FROM $table').first['n'] as int;

void main() {
  late Directory template;

  setUpAll(() async {
    template = Directory.systemTemp.createTempSync('aaq_me_tpl_');
    final Database db = openLocalLedger(template.path, RunMode.live);
    importSeedBundle(db, <String, List<int>>{
      for (final SeedFile f in kSeedFiles)
        f.fileName: File('assets/seed/${f.fileName}').readAsBytesSync(),
    }, importedAt: _seedAt);
    await DailySignalJob(db, configHash: 'cfg_regime').run(_me);
    _prices(db);
    db.close();
  });
  tearDownAll(() => template.deleteSync(recursive: true));

  late Directory dir;
  late Database db;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_me_');
    for (final FileSystemEntity f in template.listSync()) {
      if (f is File) {
        f.copySync('${dir.path}/${f.uri.pathSegments.last}');
      }
    }
    db = openLocalLedger(dir.path, RunMode.live);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  MonthlyRebalanceJob job({
    List<LedgerHolding> held = const <LedgerHolding>[],
    Map<String, OrderBroker>? cash,
    TierBCard? Function() tierBCard = p0sTierBCard,
  }) => MonthlyRebalanceJob(
    db,
    mode: RunMode.live,
    kr: _kr,
    us: _us,
    clock: _Clock(),
    cash:
        cash ??
        <String, OrderBroker>{
          'main': FakeOrderBroker(cashKrw: Decimal.parse('10000000')),
        },
    holdings: () async => held,
    pensionAlias: 'pension',
    regimeConfigHash: 'cfg_regime',
    configHash: 'cfg_plan',
    tierBCard: tierBCard,
  );

  test(
    '한 트랜잭션 저장 · 집행 첫날 08-03 · 만료 = 다음 판정 날 09-01 · 램프 달 1 · 대상 왕복',
    () async {
      final MonthlyRebalanceReport r = await job().run(_me);
      expect(
        (r.created, r.planId, r.monthEnd, r.executionDay, r.monthIndex),
        (true, 'REBAL-2026-07-31', '2026-07-31', '2026-08-03', 1),
      );
      expect(r.targets, isNotEmpty);
      expect(r.alerts, isEmpty);
      final Row p = db
          .select("SELECT * FROM plan_snapshot WHERE kind = 'REBALANCE'")
          .single;
      expect(
        (
          p['plan_id'],
          p['as_of_trade_date'],
          p['expires_at'],
          p['config_hash'],
        ),
        ('REBAL-2026-07-31', '2026-07-31', '2026-09-01', 'cfg_plan'),
      );
      final Map<String, Object?> out =
          jsonDecode(p['outputs'] as String) as Map<String, Object?>;
      expect(
        (out['targets']! as List<Object?>)
            .map((Object? t) => orderTargetFromJson(t! as Map<String, Object?>))
            .map(orderTargetToJson)
            .toList(),
        r.targets.map(orderTargetToJson).toList(),
      );
      expect((out['weights_before']! as List<Object?>).length, 4);
      final Map<String, Object?> inputs =
          jsonDecode(p['inputs'] as String) as Map<String, Object?>;
      expect(inputs['krw_cash'], '10000000');
      final Row e = db.select('SELECT * FROM rebalance_event').single;
      expect(
        (e['event_id'], e['kind'], e['mode'], e['decision_id']),
        (
          'REB-MONTHLY-2026-07-31',
          'MONTHLY_REGULAR',
          'LIVE',
          'MONTH-END-2026-07-31',
        ),
      );
      final Map<String, Object?> trig =
          jsonDecode(e['trigger_snapshot'] as String) as Map<String, Object?>;
      expect(trig['regime_ref'], '2026-07-31');
      expect(trig['month_index'], 1);
      final Row l = db.select('SELECT * FROM decision_log').single;
      expect(
        (
          l['decision_id'],
          l['kind'],
          l['reason_code'],
          l['regime_ref'],
          l['strategy_id'],
        ),
        (
          'MONTH-END-2026-07-31',
          'REBALANCE',
          'MONTHLY_REGULAR',
          '2026-07-31',
          'P0S',
        ),
      );
    },
  );

  test('멱등 — 다시 돌리면 아무것도 안 바꾸고 같은 대상을 보고', () async {
    final MonthlyRebalanceReport a = await job().run(_me);
    final MonthlyRebalanceReport b = await job(
      cash: <String, OrderBroker>{
        'main': FakeOrderBroker(cashKrw: Decimal.parse('1')),
      },
    ).run(_me);
    expect(b.created, isFalse);
    expect(
      b.targets.map(orderTargetToJson).toList(),
      a.targets.map(orderTargetToJson).toList(),
    );
    for (final String t in <String>[
      'plan_snapshot',
      'rebalance_event',
      'decision_log',
    ]) {
      expect(_count(db, t), 1, reason: t);
    }
  });

  test('🆕 E13d1 🔴 월말 이하 마지막 스냅숏 = STOPPED → 계획 행 0 · 대상 0 · 계층 B 는 판정 · HALTED = 계획(R60 B2)', () async {
    _snapshot(db, '2026-07-30', 'STOPPED');
    _snapshot(db, '2026-08-03', 'NORMAL'); // 월말 뒤 = 보지 않는다
    final MonthlyRebalanceReport r = await job().run(_me);
    expect(
      (
        r.created,
        r.skippedReason,
        r.planId,
        r.executionDay,
        r.monthIndex,
        r.sleeveBHeld,
      ),
      (false, 'BREAKER_STOPPED', 'REBAL-2026-07-31', '2026-08-03', 0, false),
    );
    expect(r.targets, isEmpty);
    expect(r.tierB, isNotNull);
    for (final String t in <String>[
      'plan_snapshot',
      'rebalance_event',
      'decision_log',
    ]) {
      expect(_count(db, t), 0, reason: t);
    }
    _snapshot(db, '2026-07-31', 'HALTED');
    final MonthlyRebalanceReport made = await job().run(_me);
    expect(
      (made.created, made.skippedReason, made.monthIndex),
      (true, null, 1),
    );
    expect(_count(db, 'plan_snapshot'), 1);
  });

  test('앞 계획이 있으면 램프 달 = 앞 + 1', () async {
    db.execute(
      'INSERT INTO plan_snapshot(plan_id, kind, computed_at, as_of_trade_date, expires_at, inputs, outputs, config_hash) '
      "VALUES ('REBAL-2026-06-30', 'REBALANCE', 'x', '2026-06-30', '2026-08-03', '{}', ?, 'c')",
      <Object?>[
        jsonEncode(<String, Object?>{
          'month_index': 3,
          'targets': <Object?>[],
          'execution_day': '2026-07-01',
        }),
      ],
    );
    expect((await job().run(_me)).monthIndex, 4);
  });

  test('보유 → 상태(원가 종가 × 수량 · C 재분류 파킹)', () async {
    await job(
      held: const <LedgerHolding>[
        LedgerHolding('P0S_B', '133690', 10),
        LedgerHolding('P0S_C', '214980', 2),
      ],
    ).run(_me);
    final Map<String, Object?> inputs = jsonDecode(
      db.select('SELECT inputs FROM plan_snapshot').single['inputs'] as String,
    ) as Map<String, Object?>;
    expect((inputs['b_assets']! as Map<String, Object?>)['133690'], '1200000');
    expect(inputs['b_parking_reclassified'], '240000');
    // 월별 종가 = 수정 종가(close · 시험 데이터 = 원가 × 0.95)의 달마다 마지막 값 — 17달 + 7월(감사용으로 inputs 에 남는다).
    final List<Object?> mc =
        (inputs['monthly_closes']! as Map<String, Object?>)['133690']!
            as List<Object?>;
    expect(mc, hasLength(18));
    expect(mc.last, 114000.0);
    expect(mc.first, 95000.0);
  });

  test('🔴 국면 준비 안 됨(08-31 · 시드 끝 08-14) = 실패 · 아무것도 안 씀', () async {
    await expectLater(
      job().run(const TradeDate('2026-08-31')),
      throwsA(
        isA<MonthlyRebalanceError>().having(
          (MonthlyRebalanceError e) => e.reason,
          'r',
          '월말 국면 준비 안 됨: 2026-08-31',
        ),
      ),
    );
    expect(_count(db, 'plan_snapshot'), 0);
  });

  test(
    '🆕 POT 보유 = POT 자산 · POT 현금 = 체결에서 다시 셈(E11f3 · R49 Q6) · C 원화 = 현금 − POT',
    () async {
      // 계절 A 청산 판정이 없으니 처음부터 센다 — SEAS-A-OUT 매도 순대금 1,000,000 − 30.
      db.execute(
        'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
        "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES ('i1', 'k1', 'x', "
        "'2026-04-28', 'KR', 'main', 'P0S_A', 'SEAS-A-OUT-2026-04-30@2026-04-28', '229200', 'SELL', 'LIMIT', 100, 'FILLED', 'c', 'x', 'LIVE')",
      );
      db.execute(
        "INSERT INTO broker_orders(broker_order_no, intent_id, submitted_at, status) VALUES ('b1', 'i1', 'x', 'FILLED')",
      );
      db.execute(
        'INSERT INTO executions(execution_id, broker_order_no, executed_at, quantity, price, commission, tax) '
        "VALUES ('e1', 'b1', '2026-04-28T01:00:00Z', 100, 10000, 30, 0)",
      );
      await job(
        held: const <LedgerHolding>[LedgerHolding('P0S_POT', '133690', 1)],
      ).run(_me);
      final Map<String, Object?> inputs = jsonDecode(
        db.select('SELECT inputs FROM plan_snapshot').single['inputs']
            as String,
      ) as Map<String, Object?>;
      expect(inputs['pot_cash'], '999970');
      expect(
        (inputs['pot_assets']! as Map<String, Object?>)['133690'],
        '120000',
      );
      expect(inputs['krw_cash'], '9000030');
    },
  );

  test('🔴 귀속 불가 · 현금 실패 = 실패 · 아무것도 안 씀 · 월말 아님 = ArgumentError', () async {
    for (final (MonthlyRebalanceJob j, String why)
        in <(MonthlyRebalanceJob, String)>[
          (
            job(
              held: const <LedgerHolding>[LedgerHolding('P0S_X', '133690', 1)],
            ),
            '귀속 불가 보유: P0S_X 133690',
          ),
          (
            job(
              cash: <String, OrderBroker>{
                'isa': FakeOrderBroker(cashError: StateError('끊김')),
              },
            ),
            '현금 조회 실패: isa',
          ),
        ]) {
      await expectLater(
        j.run(_me),
        throwsA(
          isA<MonthlyRebalanceError>().having(
            (MonthlyRebalanceError e) => e.reason,
            'r',
            why,
          ),
        ),
      );
    }
    for (final String t in <String>[
      'plan_snapshot',
      'rebalance_event',
      'decision_log',
    ]) {
      expect(_count(db, t), 0, reason: t);
    }
    await expectLater(
      job().run(const TradeDate('2026-07-30')),
      throwsArgumentError,
    );
  });

  group('StoredPlanTargetSource(P8)', () {
    test('계획 없음 · 집행 첫날 전 · 만료 = 빈 목록 · 집행 첫날 ~ 만료 전 = 대상', () async {
      final StoredPlanTargetSource src = StoredPlanTargetSource(db);
      expect(await src.targetsFor(const TradeDate('2026-08-03')), isEmpty);
      final MonthlyRebalanceReport r = await job().run(_me);
      expect(await src.targetsFor(const TradeDate('2026-07-31')), isEmpty);
      expect(
        (await src.targetsFor(const TradeDate('2026-08-03')))
            .map(orderTargetToJson)
            .toList(),
        r.targets.map(orderTargetToJson).toList(),
      );
      expect(
        await src.targetsFor(const TradeDate('2026-08-31')),
        hasLength(r.targets.length),
      );
      expect(await src.targetsFor(const TradeDate('2026-09-01')), isEmpty);
    });

    test('🔴 이미 낸 대상 = 빠진다(논리 id@집행일 · 종목 · 방향) · 같은 논리 id 의 다른 종목 · 앞이 같은 다른 id = 남는다', () async {
      final MonthlyRebalanceReport r = await job().run(_me);
      final Map<String, List<OrderTarget>> byId = <String, List<OrderTarget>>{};
      for (final OrderTarget t in r.targets) {
        byId.putIfAbsent(t.logicalDecisionId, () => <OrderTarget>[]).add(t);
      }
      final List<OrderTarget> shared = byId.values.firstWhere(
        (List<OrderTarget> l) => l.length > 1,
      );
      final OrderTarget gone = shared.first;
      void intent(String id, String decision, String symbol, String side) =>
          db.execute(
            'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
            "decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) VALUES (?, ?, 'x', "
            "'2026-08-03', 'KR', 'main', ?, ?, ?, ?, 'LIMIT', 1, 'SUBMITTED', 'c', 'x', 'LIVE')",
            <Object?>[id, 'k$id', gone.strategyId, decision, symbol, side],
          );
      intent(
        'i1',
        '${gone.logicalDecisionId}@2026-08-03',
        gone.symbol,
        gone.side.wire,
      );
      intent(
        'i2',
        '${gone.logicalDecisionId}X@2026-08-03',
        shared[1].symbol,
        shared[1].side.wire,
      );
      final List<OrderTarget> left = await StoredPlanTargetSource(db)
          .targetsFor(const TradeDate('2026-08-04'));
      expect(left, hasLength(r.targets.length - 1));
      expect(
        left.any(
          (OrderTarget t) =>
              t.logicalDecisionId == gone.logicalDecisionId &&
              t.symbol == gone.symbol,
        ),
        isFalse,
      );
      expect(
        left.any(
          (OrderTarget t) =>
              t.logicalDecisionId == gone.logicalDecisionId &&
              t.symbol == shared[1].symbol,
        ),
        isTrue,
      );
    });
  });

  group('🆕 E11g — 계층 B 단계(R50 T1 · T8)', () {
    const TierBCard card = TierBCard(
      b1R12mFloor: -0.15,
      b2DdFloor: -0.05,
      b3TuwMonths: 31,
    );
    void strategies() {
      for (final String id in <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
      ]) {
        db.execute(
          'INSERT INTO strategy_state_current(strategy_id, state, since, capital_cap) VALUES (?, ?, ?, 1.0)',
          <Object?>[id, 'ACTIVE', '2026-01-02'],
        );
      }
    }

    void snap(String day, double equity) => db.execute(
      'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
      "VALUES (?, ?, 0, ?, ?, 0, 'LIVE')",
      <Object?>[day, equity, equity, equity],
    );

    test('기본 = P0S 카드 미등록 → 계획은 만들고 판정 행 0 · 보고 «카드 없음»', () async {
      strategies();
      final MonthlyRebalanceReport r = await job().run(_me);
      expect(r.created, isTrue);
      expect(r.tierB!.cardMissing, isTrue);
      expect(r.tierB!.judgedMonth, '2026-07');
      expect(r.toString(), contains('카드 없음'));
      expect(_count(db, 'tier_b_judgement'), 0);
    });

    test('카드 등록 → 저장 뒤 판정 · 전 전략 행 · ACTIVE → PROBATION', () async {
      strategies();
      snap('2026-06-30', 100);
      snap('2026-07-31', 90);
      final MonthlyRebalanceReport r = await job(tierBCard: () => card)
          .run(_me);
      expect(r.created, isTrue);
      expect(r.tierB!.judged, <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
      ]);
      expect(r.tierB!.transitioned, r.tierB!.judged);
      expect(_count(db, 'tier_b_judgement'), 2);
      expect(_count(db, 'plan_snapshot'), 1);
    });

    test('🔴 판정 실패 = 월말 잡 실패 · 계획은 남는다 → 다시 돌리면 판정만', () async {
      strategies();
      snap('2026-06-30', 100);
      await expectLater(
        job(tierBCard: () => card).run(_me),
        throwsA(
          isA<MonthlyRebalanceError>().having(
            (MonthlyRebalanceError e) => e.reason,
            'reason',
            '계층 B: 2026-07 스냅숏 없음',
          ),
        ),
      );
      expect(_count(db, 'plan_snapshot'), 1);
      expect(_count(db, 'rebalance_event'), 1);
      expect(_count(db, 'tier_b_judgement'), 0);

      snap('2026-07-31', 99);
      final MonthlyRebalanceReport again = await job(tierBCard: () => card)
          .run(_me);
      expect(again.created, isFalse);
      expect(again.tierB!.judged, hasLength(2));
      expect(again.tierB!.transitioned, isEmpty);
      expect(_count(db, 'plan_snapshot'), 1);
      expect(_count(db, 'tier_b_judgement'), 2);

      final MonthlyRebalanceReport third = await job(tierBCard: () => card)
          .run(_me);
      expect(third.tierB!.judged, isEmpty);
      expect(_count(db, 'tier_b_judgement'), 2);
    });
  });

  test('🆕 E11j — 🔴 월 납입 운영값은 config_hash 밖: 기록이 있어도 월말 계획 바이트 불변(06 M3-6 ⓕ · R54 J7)', () async {
    // 같은 시작 원장 사본 둘 — 하나에만 월 납입 변경 2건.
    final Directory other = Directory.systemTemp.createTempSync('aaq_me_b_');
    for (final FileSystemEntity f in template.listSync()) {
      if (f is File) f.copySync('${other.path}/${f.uri.pathSegments.last}');
    }
    final Database db2 = openLocalLedger(other.path, RunMode.live);
    try {
      for (final (int n, String amount) in <(int, String)>[
        (1, '150000'),
        (2, '0'),
      ]) {
        db.execute(
          'INSERT INTO operating_param_log(param_key, value_text, changed_at, effective_from, action_run_id, device_id) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[
            OperatingParamKeys.monthlyContribution,
            amount,
            '2026-07-0${n}T00:00:00.000Z',
            '2026-07-01',
            'run-$n',
            'dev-1',
          ],
        );
      }
      await job().run(_me);
      await MonthlyRebalanceJob(
        db2,
        mode: RunMode.live,
        kr: _kr,
        us: _us,
        clock: _Clock(),
        cash: <String, OrderBroker>{
          'main': FakeOrderBroker(cashKrw: Decimal.parse('10000000')),
        },
        holdings: () async => const <LedgerHolding>[],
        pensionAlias: 'pension',
        regimeConfigHash: 'cfg_regime',
        configHash: 'cfg_plan',
      ).run(_me);
      String plan(Database d) {
        final Row p = d
            .select(
              "SELECT inputs, outputs, config_hash, expires_at FROM plan_snapshot WHERE kind = 'REBALANCE'",
            )
            .single;
        return '${p['inputs']}|${p['outputs']}|${p['config_hash']}|${p['expires_at']}';
      }

      String event(Database d) {
        final Row e = d
            .select(
              'SELECT weights_before, weights_after, trigger_snapshot, config_hash FROM rebalance_event',
            )
            .single;
        return '${e['weights_before']}|${e['weights_after']}|${e['trigger_snapshot']}|${e['config_hash']}';
      }

      expect(plan(db), plan(db2));
      expect(event(db), event(db2));
      expect(_count(db, 'operating_param_log'), 2);
      expect(_count(db2, 'operating_param_log'), 0);
    } finally {
      db2.close();
      other.deleteSync(recursive: true);
    }
  });
}
