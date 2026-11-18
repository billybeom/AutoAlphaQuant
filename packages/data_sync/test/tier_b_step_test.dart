// E11g — 계층 B 판정 단계(설계 13 §8 R50 T1 · T2 · T5~T9).
//
// 🔵 잡는 것: ① 시리즈 = 스냅숏 + 입출금(DEPOSIT · WITHDRAWAL 만 · 앞 스냅숏 뒤 ~ 그날) ② 카드 없음 · 전략 없음 = 행 0 · 읽지 않음
//    ③ 전 전략 같은 판정 · ACTIVE 만 PROBATION(자금 × 0.5 · since = 한국 날짜) + 전이 기록 ④ 한 트랜잭션 · 멱등 · 늦게 든 전략
//    ⑤ 실패 = 아무것도 안 씀 ⑥ `tierBUnjudged`(SAF-410)와 맞물림.

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

// 2026-07-31 23:00 UTC = 한국 2026-08-01(토) 08:00.
final DateTime _t0 = DateTime.utc(2026, 7, 31, 23);
const TradeDate _me = TradeDate('2026-07-31');
const TierBCard _card = TierBCard(
  b1R12mFloor: -0.15,
  b2DdFloor: -0.25,
  b3TuwMonths: 31,
);

void _snap(Database db, String day, double equity) => db.execute(
  'INSERT INTO equity_snapshot(trade_date, total_equity, cash_krw, positions_value, high_water_mark, drawdown, mode) '
  "VALUES (?, ?, 0, ?, ?, 0, 'LIVE')",
  <Object?>[day, equity, equity, equity],
);

int _seq = 0;
void _flow(
  Database db,
  String day,
  double amount,
  String kind, {
  String currency = 'KRW',
}) => db.execute(
  'INSERT INTO cash_flow(flow_id, trade_date, amount, currency, kind) VALUES (?, ?, ?, ?, ?)',
  <Object?>['F-${_seq++}', day, amount, currency, kind],
);

void _strategy(Database db, String id, String state, {double cap = 1.0}) =>
    db.execute(
      'INSERT INTO strategy_state_current(strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
      <Object?>[id, state, '2026-01-02', cap],
    );

/// 2025-07-31 100 → 2025-12-30 150(최고) → 2026-03-31 220(03-15 입금 100 · −20%) → 2026-07-31 176(같은 날 출금 22 · −10%).
/// 지수 1 → 1.5 → 1.2 → 1.08 · r12 = +8% · DD = −28% · TUW = 213일.
void _history(Database db) {
  _flow(db, '2025-07-01', 999, 'DEPOSIT'); // 첫 스냅숏 앞 — 안 본다
  _snap(db, '2025-07-31', 100);
  _snap(db, '2025-12-30', 150);
  _flow(db, '2026-03-15', 100, 'DEPOSIT');
  _snap(db, '2026-03-31', 220);
  _flow(db, '2026-05-01', 5, 'DISTRIBUTION'); // 수익 — 외부 흐름 아님
  _flow(db, '2026-05-02', -1, 'TAX_WITHHELD');
  _flow(db, '2026-07-31', -22, 'WITHDRAWAL');
  _snap(db, '2026-07-31', 176);
  _flow(db, '2026-08-03', 500, 'DEPOSIT'); // 월말 뒤 — 안 본다
  _snap(db, '2026-08-03', 999);
}

int _count(Database db, String table) =>
    db.select('SELECT COUNT(*) AS n FROM $table').first['n'] as int;

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_tierb_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  TierBStep step({TierBCard? card = _card}) =>
      TierBStep(db, clock: clock, card: () => card);

  group('tierBSeries', () {
    test('입출금 = 앞 스냅숏 뒤 ~ 그날(같은 날 포함) · DEPOSIT · WITHDRAWAL 만 · 월말 뒤 안 봄', () {
      _history(db);
      final List<EquityPoint> s = tierBSeries(db, '2026-07-31');
      expect(
        <(String, double, double)>[
          for (final EquityPoint p in s) (p.date, p.equity, p.flow),
        ],
        <(String, double, double)>[
          ('2025-07-31', 100, 0),
          ('2025-12-30', 150, 0),
          ('2026-03-31', 220, 100),
          ('2026-07-31', 176, -22),
        ],
      );
    });

    test('월말 뒤 원화 아닌 입출금은 이번 판정과 무관', () {
      _snap(db, '2026-06-30', 100);
      _snap(db, '2026-07-31', 100);
      _flow(db, '2026-08-10', 10, 'DEPOSIT', currency: 'USD');
      expect(tierBSeries(db, '2026-07-31'), hasLength(2));
    });

    test('스냅숏 없음 = 빈 시리즈', () {
      _flow(db, '2026-07-01', 100, 'DEPOSIT');
      expect(tierBSeries(db, '2026-07-31'), isEmpty);
    });

    test('🔴 원화 아닌 입출금 = TierBError', () {
      _snap(db, '2026-06-30', 100);
      _flow(db, '2026-07-10', 10, 'DEPOSIT', currency: 'USD');
      _snap(db, '2026-07-31', 100);
      expect(
        () => tierBSeries(db, '2026-07-31'),
        throwsA(
          isA<TierBError>().having(
            (TierBError e) => e.reason,
            'reason',
            contains('2026-07-10'),
          ),
        ),
      );
    });
  });

  group('TierBStep', () {
    test('🔴 카드 미등록 = 판정 행 0 · 스냅숏도 읽지 않는다(없어도 실패 아님)', () {
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      final TierBStepReport r = step(card: null).run(_me);
      expect((r.judgedMonth, r.cardMissing), ('2026-07', true));
      expect(r.judged, isEmpty);
      expect(r.transitioned, isEmpty);
      expect(r.metrics, isNull);
      expect(r.verdict, isNull);
      expect(r.toString(), contains('카드 없음'));
      expect(_count(db, 'tier_b_judgement'), 0);
    });

    test('🆕 기본 카드 = P0S 확정 카드(R158) — 등록됨 = 판정한다', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      final TierBStepReport r = TierBStep(db, clock: clock).run(_me);
      expect(r.cardMissing, isFalse);
      expect(r.judged, <String>[P0sStrategyIds.sleeveB]);
      expect(_count(db, 'tier_b_judgement'), 1);
    });

    test('전략 없음 = 행 0 · 스냅숏 없어도 실패 아님', () {
      final TierBStepReport r = step().run(_me);
      expect(r.cardMissing, isFalse);
      expect(r.judged, isEmpty);
      expect(_count(db, 'tier_b_judgement'), 0);
    });

    test(
      '전 전략 같은 판정 · ACTIVE 만 PROBATION(자금 × 0.5 · since = 한국 날짜) + 전이 기록',
      () {
        _history(db);
        _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE', cap: 0.8);
        _strategy(db, P0sStrategyIds.sleeveC, 'PILOT');
        _strategy(db, P0sStrategyIds.deposit, 'PROBATION', cap: 0.5);
        final TierBStepReport r = step().run(_me);
        expect(r.metrics!.r12m, closeTo(0.08, 1e-12));
        expect(r.metrics!.dd, closeTo(-0.28, 1e-12));
        expect(r.metrics!.tuwMonths, closeTo(213 / 30.4375, 1e-12));
        expect(r.metrics!.peakDate, '2025-12-30');
        expect(
          (r.verdict!.b1, r.verdict!.b2, r.verdict!.b3),
          (false, true, false),
        );
        expect(
          r.judged,
          <String>[
            P0sStrategyIds.sleeveB,
            P0sStrategyIds.sleeveC,
            P0sStrategyIds.deposit,
          ]..sort(),
        );
        expect(r.transitioned, <String>[P0sStrategyIds.sleeveB]);
        expect(r.cardMissing, isFalse);
        expect(r.toString(), contains('판정 3 · 전이 1'));

        final List<Row> rows = db.select(
          'SELECT * FROM tier_b_judgement ORDER BY strategy_id',
        );
        expect(
          <Object?>[
            for (final Row j in rows)
              (
                j['judged_month'],
                j['strategy_id'],
                j['judged_at'],
                j['b1_breached'],
                j['b2_breached'],
                j['b3_breached'],
                j['transitioned'],
              ),
          ],
          <Object?>[
            for (final String id in r.judged)
              (
                '2026-07',
                id,
                _t0.toIso8601String(),
                0,
                1,
                0,
                id == P0sStrategyIds.sleeveB ? 1 : 0,
              ),
          ],
        );
        final Row b = db.select(
          'SELECT * FROM strategy_state_current WHERE strategy_id = ?',
          <Object?>[P0sStrategyIds.sleeveB],
        ).single;
        expect(
          (b['state'], b['since'], b['capital_cap']),
          ('PROBATION', '2026-08-01', 0.4),
        );
        for (final (String id, String state, String since, double cap)
            in <(String, String, String, double)>[
              (P0sStrategyIds.sleeveC, 'PILOT', '2026-01-02', 1.0),
              (P0sStrategyIds.deposit, 'PROBATION', '2026-01-02', 0.5),
            ]) {
          final Row s = db.select(
            'SELECT * FROM strategy_state_current WHERE strategy_id = ?',
            <Object?>[id],
          ).single;
          expect(
            (s['state'], s['since'], s['capital_cap']),
            (state, since, cap),
          );
        }
        final Row log = db.select('SELECT * FROM strategy_state_log').single;
        expect(
          (
            log['log_id'],
            log['strategy_id'],
            log['changed_at'],
            log['from_state'],
            log['to_state'],
            log['reason'],
            log['threshold_registered'],
          ),
          (
            tierBLogIdOf('2026-07', P0sStrategyIds.sleeveB),
            P0sStrategyIds.sleeveB,
            _t0.toIso8601String(),
            'ACTIVE',
            'PROBATION',
            'TIER_B_B2',
            -0.25,
          ),
        );
        expect(log['trigger_value'] as double, closeTo(-0.28, 1e-12));
      },
    );

    test('충족 없음 = 행은 쓰고(0 · 0 · 0) 전이 없음', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      final TierBStepReport r = step(
        card: const TierBCard(
          b1R12mFloor: -0.15,
          b2DdFloor: -0.30,
          b3TuwMonths: 31,
        ),
      ).run(_me);
      expect(r.verdict!.any, isFalse);
      expect(r.transitioned, isEmpty);
      final Row j = db.select('SELECT * FROM tier_b_judgement').single;
      expect(
        (
          j['b1_breached'],
          j['b2_breached'],
          j['b3_breached'],
          j['transitioned'],
        ),
        (0, 0, 0, 0),
      );
      expect(
        db.select('SELECT state FROM strategy_state_current').single['state'],
        'ACTIVE',
      );
      expect(_count(db, 'strategy_state_log'), 0);
    });

    test('B1 · B3 사유 코드 · 처음 충족 지표', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      step(
        card: const TierBCard(
          b1R12mFloor: 0.10,
          b2DdFloor: -0.5,
          b3TuwMonths: 6,
        ),
      ).run(_me);
      final Row log = db.select('SELECT * FROM strategy_state_log').single;
      expect((log['reason'], log['threshold_registered']), ('TIER_B_B1', 0.10));
      expect(log['trigger_value'] as double, closeTo(0.08, 1e-12));
      final Row j = db.select('SELECT * FROM tier_b_judgement').single;
      expect((j['b1_breached'], j['b2_breached'], j['b3_breached']), (1, 0, 1));
    });

    test('B3 만 = TIER_B_B3 · 값 = 달 수', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      step(
        card: const TierBCard(
          b1R12mFloor: -0.5,
          b2DdFloor: -0.5,
          b3TuwMonths: 6,
        ),
      ).run(_me);
      final Row log = db.select('SELECT * FROM strategy_state_log').single;
      expect((log['reason'], log['threshold_registered']), ('TIER_B_B3', 6.0));
      expect(log['trigger_value'] as double, closeTo(213 / 30.4375, 1e-12));
    });

    test('멱등 — 다시 돌리면 아무것도 안 바꾼다 · 늦게 든 전략만 판정', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      step().run(_me);
      clock.at = _t0.add(const Duration(days: 2));
      final TierBStepReport again = step().run(_me);
      expect(again.judged, isEmpty);
      expect(again.transitioned, isEmpty);
      expect(again.metrics, isNull);
      expect(_count(db, 'tier_b_judgement'), 1);
      expect(_count(db, 'strategy_state_log'), 1);
      expect(
        db
            .select('SELECT capital_cap FROM strategy_state_current')
            .single['capital_cap'],
        0.5,
      );

      _strategy(db, P0sStrategyIds.sleeveC, 'ACTIVE');
      final TierBStepReport late = step().run(_me);
      expect(late.judged, <String>[P0sStrategyIds.sleeveC]);
      expect(late.transitioned, <String>[P0sStrategyIds.sleeveC]);
      final Row j = db.select(
        'SELECT judged_at FROM tier_b_judgement WHERE strategy_id = ?',
        <Object?>[P0sStrategyIds.sleeveC],
      ).single;
      expect(j['judged_at'], clock.at.toIso8601String());
    });

    test('다른 달 판정 행은 이번 달 판정을 막지 않는다', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      db.execute(
        "INSERT INTO tier_b_judgement VALUES ('2026-06', ?, 't', 0, 0, 0, 0)",
        <Object?>[P0sStrategyIds.sleeveB],
      );
      expect(step().run(_me).judged, <String>[P0sStrategyIds.sleeveB]);
      expect(_count(db, 'tier_b_judgement'), 2);
    });

    test('🔴 실패 = 아무것도 안 씀 — 스냅숏 없음 · 그 달 스냅숏 없음', () {
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      expect(
        () => step().run(_me),
        throwsA(
          isA<TierBError>().having(
            (TierBError e) => e.reason,
            'reason',
            '2026-07 스냅숏 없음',
          ),
        ),
      );
      _snap(db, '2026-06-30', 100);
      expect(() => step().run(_me), throwsA(isA<TierBError>()));
      expect(_count(db, 'tier_b_judgement'), 0);
    });

    test('🔴 한 트랜잭션 — 전이 기록이 실패하면 판정 행 · 상태도 되돌린다', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      _strategy(db, P0sStrategyIds.sleeveC, 'ACTIVE');
      db.execute(
        'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, to_state, reason) VALUES (?, ?, ?, ?, ?)',
        <Object?>[
          tierBLogIdOf('2026-07', P0sStrategyIds.sleeveC),
          P0sStrategyIds.sleeveC,
          't',
          'ACTIVE',
          'seed',
        ],
      );
      expect(() => step().run(_me), throwsA(isA<SqliteException>()));
      expect(_count(db, 'tier_b_judgement'), 0);
      expect(
        db
            .select(
              "SELECT COUNT(*) AS n FROM strategy_state_current WHERE state = 'ACTIVE' AND capital_cap = 1.0",
            )
            .first['n'],
        2,
      );
      expect(_count(db, 'strategy_state_log'), 1);
    });
  });

  group('SAF-410 맞물림(test_tier_b_unjudged_blocks 꼴)', () {
    // 2026-08: 08-03 · 04 · 05 = 유예 · 08-06 = 넷째 세션.
    const TradeDate fourth = TradeDate('2026-08-06');
    SqliteOrderLedger ledger() => SqliteOrderLedger(
      db,
      mode: RunMode.live,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
    );

    test('판정하면 넷째 세션에도 막지 않는다', () async {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      _strategy(db, P0sStrategyIds.sleeveC, 'ACTIVE');
      step().run(_me);
      expect(await ledger().tierBUnjudged(fourth), isFalse);
    });

    test('🔴 카드 미등록 = 행 0 → 넷째 세션부터 신규 매수 차단(정답)', () async {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      step(card: null).run(_me);
      expect(
        await ledger().tierBUnjudged(const TradeDate('2026-08-05')),
        isFalse,
      );
      expect(await ledger().tierBUnjudged(fourth), isTrue);
    });
  });
}
