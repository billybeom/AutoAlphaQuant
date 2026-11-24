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

/// 판정 행 하나(복귀 · 만료 시험의 이력).
void _judged(
  Database db,
  String month,
  String id, {
  bool transitioned = false,
}) => db.execute(
  'INSERT INTO tier_b_judgement(judged_month, strategy_id, judged_at, b1_breached, b2_breached, b3_breached, '
  'transitioned) VALUES (?, ?, ?, 0, 0, 0, ?)',
  <Object?>[month, id, '$month-28T00:00:00.000Z', transitioned ? 1 : 0],
);

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
        // 🆕 R247 — PROBATION 은 진입 판정 행이 있어야 한다(없으면 무결성 실패) · 이번 달 B2 충족 = 복귀 안 함.
        _judged(db, '2026-06', P0sStrategyIds.deposit, transitioned: true);
        final TierBStepReport r = step().run(_me);
        expect(r.returned, isEmpty);
        expect(r.retired, isEmpty);
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
          "SELECT * FROM tier_b_judgement WHERE judged_month = '2026-07' ORDER BY strategy_id",
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

  // ── 🆕 R247(R50 T10 · 03 §1-5 «P0S 등록») — PROBATION 효과 · 복귀 · 만료 ──
  group('🆕 R247 복귀 · 만료 · 회수처 C', () {
    // _history: r12 = +8% · DD = −28% · TUW 7달 — 이 카드면 하나도 안 걸림.
    const TierBCard quiet = TierBCard(
      b1R12mFloor: -0.15,
      b2DdFloor: -0.30,
      b3TuwMonths: 31,
    );
    TierBStep stepR({
      TierBCard card = quiet,
      TierBProbationRule rule = const TierBProbationRule(
        returnR12mFloor: 0.05,
        maxJudgements: 24,
      ),
    }) => TierBStep(db, clock: clock, card: () => card, rule: () => rule);

    Row state(String id) => db.select(
      'SELECT * FROM strategy_state_current WHERE strategy_id = ?',
      <Object?>[id],
    ).single;

    void probation(String id, {double cap = 0.5, String entry = '2026-06'}) {
      _strategy(db, id, 'PROBATION', cap: cap);
      _judged(db, entry, id, transitioned: true);
    }

    test('🔴 진입 = 위험 슬리브만 × 0.5 · 회수처 C 는 상한 그대로(라벨만 함께)', () {
      _history(db);
      for (final String id in <String>[
        P0sStrategyIds.sleeveA,
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
        P0sStrategyIds.pot,
      ]) {
        _strategy(db, id, 'ACTIVE');
      }
      final TierBStepReport r = step().run(_me); // _card = B2 −25% → 걸림
      expect(r.transitioned, hasLength(4));
      for (final (String id, double cap) in <(String, double)>[
        (P0sStrategyIds.sleeveA, 0.5),
        (P0sStrategyIds.sleeveB, 0.5),
        (P0sStrategyIds.sleeveC, 1.0),
        (P0sStrategyIds.pot, 0.5),
      ]) {
        expect(
          (state(id)['state'], state(id)['capital_cap']),
          ('PROBATION', cap),
        );
      }
      expect(p0sRiskCapsOf(db), const P0sRiskCaps(a: 0.5, b: 0.5, pot: 0.5));
    });

    test('복귀 = r12 ≥ +5% AND B1~B3 안 걸림 → ACTIVE · 상한 1 · 기록 · 판정 행 전이 1', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB);
      probation(P0sStrategyIds.sleeveC, cap: 1.0);
      final TierBStepReport r = stepR().run(_me);
      expect(r.returned, <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
      ]);
      expect(r.retired, isEmpty);
      expect(r.transitioned, isEmpty); // ACTIVE → PROBATION 만
      expect(r.toString(), contains('복귀 2'));
      for (final String id in <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
      ]) {
        expect(
          (state(id)['state'], state(id)['since'], state(id)['capital_cap']),
          ('ACTIVE', '2026-08-01', 1.0),
        );
        final Row j = db.select(
          "SELECT transitioned FROM tier_b_judgement WHERE judged_month = '2026-07' AND strategy_id = ?",
          <Object?>[id],
        ).single;
        expect(j['transitioned'], 1);
        final Row log = db.select(
          'SELECT * FROM strategy_state_log WHERE strategy_id = ?',
          <Object?>[id],
        ).single;
        expect(
          (
            log['log_id'],
            log['from_state'],
            log['to_state'],
            log['threshold_registered'],
            log['reason'],
          ),
          (
            tierBExitLogIdOf(TierBExitCodes.returned, '2026-07', id),
            'PROBATION',
            'ACTIVE',
            0.05,
            'TIER_B_RETURN',
          ),
        );
        expect(log['trigger_value'] as double, closeTo(0.08, 1e-12));
      }
      expect(p0sRiskCapsOf(db), P0sRiskCaps.full);
    });

    test('복귀 경계 — r12 가 문턱과 같으면 복귀(≥) · 문턱 위면 그대로', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB);
      final double r12 = stepR(
        rule: const TierBProbationRule(returnR12mFloor: 0.5, maxJudgements: 24),
      ).run(_me).metrics!.r12m!;
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
      db.execute(
        'DELETE FROM tier_b_judgement WHERE judged_month = ?',
        <Object?>['2026-07'],
      );
      final TierBStepReport r = stepR(
        rule: TierBProbationRule(returnR12mFloor: r12, maxJudgements: 24),
      ).run(_me);
      expect(r.returned, <String>[P0sStrategyIds.sleeveB]);
    });

    test('B1~B3 하나라도 걸리면 r12 가 넘어도 복귀 안 함(되튐 막기) · 전이 0 · 기록 0', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB);
      final TierBStepReport r = step().run(_me); // _card = B2 걸림 · r12 +8%
      expect(r.verdict!.any, isTrue);
      expect(r.returned, isEmpty);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
      expect(_count(db, 'strategy_state_log'), 0);
      expect(
        db
            .select(
              "SELECT transitioned FROM tier_b_judgement WHERE judged_month = '2026-07'",
            )
            .single['transitioned'],
        0,
      );
    });

    test('r12 없음(이력 12달 미만) = 복귀 안 함', () {
      _snap(db, '2026-03-31', 100);
      _snap(db, '2026-07-31', 130);
      probation(P0sStrategyIds.sleeveB);
      final TierBStepReport r = stepR().run(_me);
      expect(r.metrics!.r12m, isNull);
      expect(r.returned, isEmpty);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
    });

    test('🔴 만료 = 진입 뒤 N번째 판정까지 복귀 못 함 → RETIRED · 위험 = 0 · C 상한 그대로 · 기록', () {
      _history(db);
      const TierBProbationRule rule = TierBProbationRule(
        returnR12mFloor: 0.05,
        maxJudgements: 3,
      );
      for (final (String id, double cap) in <(String, double)>[
        (P0sStrategyIds.sleeveB, 0.5),
        (P0sStrategyIds.sleeveC, 1.0),
        (P0sStrategyIds.pot, 0.5),
      ]) {
        probation(id, cap: cap, entry: '2026-04');
        _judged(db, '2026-05', id);
        _judged(db, '2026-06', id);
      }
      final TierBStepReport r = stepR(card: _card, rule: rule).run(_me);
      expect(r.retired, <String>[
        P0sStrategyIds.sleeveB,
        P0sStrategyIds.sleeveC,
        P0sStrategyIds.pot,
      ]);
      expect(r.toString(), contains('은퇴 3'));
      for (final (String id, double cap) in <(String, double)>[
        (P0sStrategyIds.sleeveB, 0.0),
        (P0sStrategyIds.sleeveC, 1.0),
        (P0sStrategyIds.pot, 0.0),
      ]) {
        expect(
          (state(id)['state'], state(id)['capital_cap']),
          ('RETIRED', cap),
        );
        final Row log = db.select(
          'SELECT * FROM strategy_state_log WHERE strategy_id = ?',
          <Object?>[id],
        ).single;
        expect(
          (
            log['log_id'],
            log['to_state'],
            log['trigger_value'],
            log['threshold_registered'],
            log['reason'],
          ),
          (
            tierBExitLogIdOf(TierBExitCodes.expired, '2026-07', id),
            'RETIRED',
            3.0,
            3.0,
            'TIER_B_EXPIRED',
          ),
        );
      }
      expect(
        p0sRiskCapsOf(db),
        const P0sRiskCaps(a: 1.0, b: 0.0, pot: 0.0), // A 행 없음 = 1
      );
    });

    test('만료 한 달 전 = 그대로 · 빠진 달은 관측으로 세지 않는다(월말 판정 횟수)', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB, entry: '2026-03'); // 04 · 05 판정 없음
      _judged(db, '2026-06', P0sStrategyIds.sleeveB);
      final TierBStepReport r = stepR(
        card: _card,
        rule: const TierBProbationRule(returnR12mFloor: 0.05, maxJudgements: 3),
      ).run(_me);
      expect(r.retired, isEmpty);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
    });

    test('마지막 판정에서 복귀하면 만료가 아니다', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB, entry: '2026-05');
      _judged(db, '2026-06', P0sStrategyIds.sleeveB);
      final TierBStepReport r = stepR(
        rule: const TierBProbationRule(returnR12mFloor: 0.05, maxJudgements: 2),
      ).run(_me);
      expect(r.returned, <String>[P0sStrategyIds.sleeveB]);
      expect(r.retired, isEmpty);
    });

    test('🔴 진입 판정 없는 PROBATION = TierBError · 아무것도 안 씀', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'ACTIVE');
      _strategy(db, P0sStrategyIds.sleeveC, 'PROBATION', cap: 1.0);
      expect(
        () => stepR().run(_me),
        throwsA(
          isA<TierBError>().having(
            (TierBError e) => e.reason,
            'reason',
            'PROBATION 진입 판정 없음: ${P0sStrategyIds.sleeveC}',
          ),
        ),
      );
      expect(_count(db, 'tier_b_judgement'), 0);
      expect(_count(db, 'strategy_state_log'), 0);
    });

    test('RETIRED = 판정 행만 · 전이 없음 · 멱등(다시 돌리면 아무것도)', () {
      _history(db);
      _strategy(db, P0sStrategyIds.sleeveB, 'RETIRED', cap: 0);
      final TierBStepReport r = step().run(_me);
      expect(r.judged, <String>[P0sStrategyIds.sleeveB]);
      expect(r.transitioned, isEmpty);
      expect(r.returned, isEmpty);
      expect(r.retired, isEmpty);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'RETIRED');
      final TierBStepReport again = step().run(_me);
      expect(again.judged, isEmpty);
      expect(_count(db, 'tier_b_judgement'), 1);
    });

    test('복귀 다음 달 = 다시 ACTIVE 판정(진입과 같은 길) · 복귀 판정 행이 새 진입이 되지 않는다', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB);
      stepR().run(_me);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'ACTIVE');
      _snap(db, '2026-08-31', 100); // −43% · 새로 걸림
      final TierBStepReport r = stepR().run(const TradeDate('2026-08-31'));
      expect(r.transitioned, <String>[P0sStrategyIds.sleeveB]);
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
      expect(state(P0sStrategyIds.sleeveB)['capital_cap'], 0.5);
    });

    test('🔴 한 트랜잭션 — 복귀 기록이 실패하면 판정 행 · 상태도 되돌린다', () {
      _history(db);
      probation(P0sStrategyIds.sleeveB);
      db.execute(
        'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, from_state, to_state, reason) '
        "VALUES (?, 'X', 'x', NULL, 'ACTIVE', 'x')",
        <Object?>[
          tierBExitLogIdOf(
            TierBExitCodes.returned,
            '2026-07',
            P0sStrategyIds.sleeveB,
          ),
        ],
      );
      expect(() => stepR().run(_me), throwsA(isA<SqliteException>()));
      expect(state(P0sStrategyIds.sleeveB)['state'], 'PROBATION');
      expect(
        _count(db, 'tier_b_judgement'),
        1, // 진입 행만
      );
    });
  });

  group('🆕 R247 p0sRiskCapsOf · sleeveACapTrimDue', () {
    test(
      '상한 읽기 — 행 없음 · CANDIDATE(상한 0) = 1 · RETIRED = 0 · PROBATION = 값',
      () {
        expect(p0sRiskCapsOf(db), P0sRiskCaps.full);
        _strategy(db, P0sStrategyIds.sleeveA, 'CANDIDATE', cap: 0);
        _strategy(db, P0sStrategyIds.sleeveB, 'RETIRED', cap: 0.7);
        _strategy(db, P0sStrategyIds.pot, 'PROBATION', cap: 0.5);
        expect(p0sRiskCapsOf(db), const P0sRiskCaps(a: 1.0, b: 0.0, pot: 0.5));
      },
    );

    void log(String id, String to, String reason, String at) => db.execute(
      'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, from_state, to_state, reason) '
      'VALUES (?, ?, ?, NULL, ?, ?)',
      <Object?>['L-$at-$to', id, at, to, reason],
    );
    int n = 0;
    void intent(String strategy, String at) => db.execute(
      'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
      'decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) '
      "VALUES (?, ?, ?, '2026-08-03', 'KR', 'isa', ?, 'D@2026-08-03', '000000', 'SELL', 'LIMIT', 1, 'SUBMITTED', 'h', ?, 'LIVE')",
      <Object?>['I${n++}', 'K$n-$at', at, strategy, at],
    );

    test('A 축소 남음 = 마지막 A 기록이 계층 B 낮춤 전이 · 그 뒤 A 주문 0', () {
      expect(sleeveACapTrimDue(db), isFalse);
      log(
        P0sStrategyIds.sleeveA,
        'ACTIVE',
        'SIM_OPENING',
        '2026-01-02T00:00:00Z',
      );
      expect(sleeveACapTrimDue(db), isFalse);
      intent(P0sStrategyIds.sleeveA, '2026-07-01T00:00:00Z'); // 전이 앞 주문
      log(
        P0sStrategyIds.sleeveA,
        'PROBATION',
        'TIER_B_B2',
        '2026-07-31T23:00:00Z',
      );
      expect(sleeveACapTrimDue(db), isTrue);
      intent(P0sStrategyIds.sleeveB, '2026-08-03T00:00:00Z'); // 다른 전략 = 무관
      expect(sleeveACapTrimDue(db), isTrue);
      intent(P0sStrategyIds.sleeveA, '2026-08-03T00:00:00Z');
      expect(sleeveACapTrimDue(db), isFalse);
      log(
        P0sStrategyIds.sleeveA,
        'RETIRED',
        'TIER_B_EXPIRED',
        '2028-07-31T23:00:00Z',
      );
      expect(sleeveACapTrimDue(db), isTrue);
      log(
        P0sStrategyIds.sleeveA,
        'CANDIDATE',
        'STOPPED_DECISION_B · J',
        '2028-08-05T00:00:00Z',
      );
      expect(sleeveACapTrimDue(db), isFalse);
    });

    test('복귀 기록이 마지막이면 축소 없음', () {
      log(
        P0sStrategyIds.sleeveA,
        'PROBATION',
        'TIER_B_B3',
        '2026-07-31T23:00:00Z',
      );
      log(
        P0sStrategyIds.sleeveA,
        'ACTIVE',
        'TIER_B_RETURN',
        '2026-08-31T23:00:00Z',
      );
      expect(sleeveACapTrimDue(db), isFalse);
    });

    test('🆕 R259 G-1 🔴 «줄였다» = 나간 A 의도(접수 이후 · 결과 불명 · 체결 있음) — 거부 · 건너뜀 · 체결 0 실효 · 체결 0 취소 = 아직 남음', () {
      log(
        P0sStrategyIds.sleeveA,
        'PROBATION',
        'TIER_B_B2',
        '2026-07-31T23:00:00Z',
      );
      int k = 0;
      String at = '2026-08-03T00:10:00Z';
      void a(String status, {int? filled}) {
        final String id = 'G1-${k++}';
        db.execute(
          'INSERT INTO order_intents(intent_id, idempotency_key, created_at, trade_date, market, account, strategy_id, '
          'decision_id, symbol, side, order_type, quantity, status, config_hash, updated_at, mode) '
          "VALUES (?, ?, ?, '2026-08-03', 'KR', 'isa', ?, ?, "
          "'0085P0', 'SELL', 'LIMIT', 4, ?, 'h', 'x', 'LIVE')",
          <Object?>[
            id,
            'K-$id',
            at,
            P0sStrategyIds.sleeveA,
            'RISK-P0S_A-0085P0-2026-07-31@$id',
            status,
          ],
        );
        if (filled != null) {
          db.execute(
            'INSERT INTO broker_orders(broker_order_no, intent_id, submitted_at, status, filled_qty, remaining_qty) '
            "VALUES (?, ?, 'x', ?, ?, 0)",
            <Object?>['2026-08-03:$id', id, status, filled],
          );
        }
      }

      for (final String s in <String>['REJECTED', 'SKIPPED']) {
        a(s);
      }
      a('EXPIRED', filled: 0);
      a('CANCELLED', filled: 0);
      expect(sleeveACapTrimDue(db), isTrue);
      a('EXPIRED', filled: 1);
      expect(sleeveACapTrimDue(db), isFalse);
      int day = 10;
      for (final String s in <String>[
        'RESERVED',
        'SUBMITTING',
        'SUBMITTED',
        'PARTIAL',
        'FILLED',
        'UNKNOWN',
      ]) {
        // 새 낮춤 전이(그 뒤 의도만 본다) → 거부 = 남음 → 나간 의도 = 끝.
        day++;
        log(
          P0sStrategyIds.sleeveA,
          'PROBATION',
          'TIER_B_B2',
          '2026-09-${day}T00:00:00Z',
        );
        at = '2026-09-${day}T00:10:00Z';
        a('REJECTED');
        expect(sleeveACapTrimDue(db), isTrue, reason: s);
        a(s);
        expect(sleeveACapTrimDue(db), isFalse, reason: s);
      }
    });
  });
}
