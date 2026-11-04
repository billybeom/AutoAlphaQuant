// 계층 B 월간 판정 단계 — `monthly_rebalance` 안 · 계획 저장 뒤(설계 13 §8 R50 T1 · T5~T9 · SPEC v2.39 · 04 SAF-410 · FR-708).
//
// 🔴 시리즈 = 포트폴리오 `equity_snapshot` 1 개 · 외부 흐름 = `cash_flow` 의 DEPOSIT · WITHDRAWAL 만(T2).
// 🔴 카드 미등록 = 판정 행을 쓰지 않는다(보고 «카드 없음») — `tierBUnjudged` 가 월말 뒤 3세션부터 신규 매수를 막는 것이 정답(D7 ③).
// 🔴 판정 행 = `strategy_state_current` 의 전 전략에 같은 판정(D7 ①) · ACTIVE → PROBATION 전이와 **한 트랜잭션**(T6).
// 🔴 멱등 = 그 달 판정 행이 이미 있는 전략은 건너뛴다(T7) · 실패 = 아무것도 쓰지 않고 [TierBError](T8).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// 전이 사유 코드(`strategy_state_log.reason`).
String tierBReasonOf(String code) => 'TIER_B_$code';

/// 전이 기록 id.
String tierBLogIdOf(String month, String strategyId) =>
    'TIERB-$month-$strategyId';

/// 단계 보고.
class TierBStepReport {
  /// 보고를 만든다.
  const TierBStepReport({
    required this.judgedMonth,
    required this.cardMissing,
    required this.judged,
    required this.transitioned,
    this.metrics,
    this.verdict,
  });

  /// 판정 달(`YYYY-MM`).
  final String judgedMonth;

  /// 카드 미등록(🔴 판정 행 0 · 알림 코드 = 계약 창 X12).
  final bool cardMissing;

  /// 이번에 판정 행을 쓴 전략.
  final List<String> judged;

  /// 이번에 PROBATION 으로 옮긴 전략.
  final List<String> transitioned;

  /// 지표(이번에 판정하지 않았으면 null).
  final TierBMetrics? metrics;

  /// 판정(이번에 판정하지 않았으면 null).
  final TierBVerdict? verdict;

  @override
  String toString() =>
      'TierBStepReport($judgedMonth · ${cardMissing ? '카드 없음' : '판정 ${judged.length} · 전이 ${transitioned.length}'})';
}

String _kstYmd(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

/// [monthEnd] 까지의 시리즈 — 스냅숏 날짜 순 · 점마다 (앞 스냅숏 날 뒤 ~ 그날) 입출금 합.
List<EquityPoint> tierBSeries(Database db, String monthEnd) {
  final List<(String, double)> snaps = <(String, double)>[
    for (final Row r in db.select(
      'SELECT trade_date, total_equity FROM equity_snapshot WHERE trade_date <= ? ORDER BY trade_date',
      <Object?>[monthEnd],
    ))
      (r['trade_date'] as String, (r['total_equity'] as num).toDouble()),
  ];
  if (snaps.isEmpty) return const <EquityPoint>[];
  final List<(String, double)> flows = <(String, double)>[];
  for (final Row r in db.select(
    'SELECT trade_date, amount, currency FROM cash_flow '
    "WHERE kind IN ('DEPOSIT','WITHDRAWAL') AND trade_date > ? AND trade_date <= ? ORDER BY trade_date",
    <Object?>[snaps.first.$1, snaps.last.$1],
  )) {
    if (r['currency'] != 'KRW') {
      throw TierBError('원화 아닌 입출금: ${r['trade_date']}');
    }
    flows.add((r['trade_date'] as String, (r['amount'] as num).toDouble()));
  }
  final List<EquityPoint> out = <EquityPoint>[
    EquityPoint(snaps.first.$1, snaps.first.$2),
  ];
  int f = 0;
  for (int k = 1; k < snaps.length; k++) {
    double sum = 0;
    while (f < flows.length && flows[f].$1.compareTo(snaps[k].$1) <= 0) {
      sum += flows[f].$2;
      f++;
    }
    out.add(EquityPoint(snaps[k].$1, snaps[k].$2, flow: sum));
  }
  return out;
}

/// 계층 B 판정 단계(R50 T1).
class TierBStep {
  /// 단계를 만든다 — [card] = 등록 카드(기본 P0S · 미등록 = null).
  TierBStep(this._db, {required this._clock, this._card = p0sTierBCard});

  final Database _db;
  final Clock _clock;
  final TierBCard? Function() _card;

  /// [monthEnd](월 마지막 KR 세션)의 판정 — 실패면 [TierBError](아무것도 쓰지 않음).
  TierBStepReport run(TradeDate monthEnd) {
    final String d = monthEnd.yyyyMmDd;
    final String month = d.substring(0, 7);
    final TierBCard? card = _card();
    final List<(String, String, double)> pending = <(String, String, double)>[
      for (final Row r in _db.select(
        'SELECT s.strategy_id, s.state, s.capital_cap FROM strategy_state_current s '
        'WHERE NOT EXISTS (SELECT 1 FROM tier_b_judgement j '
        'WHERE j.judged_month = ? AND j.strategy_id = s.strategy_id) '
        'ORDER BY s.strategy_id',
        <Object?>[month],
      ))
        (
          r['strategy_id'] as String,
          r['state'] as String,
          (r['capital_cap'] as num).toDouble(),
        ),
    ];
    if (card == null || pending.isEmpty) {
      return TierBStepReport(
        judgedMonth: month,
        cardMissing: card == null,
        judged: const <String>[],
        transitioned: const <String>[],
      );
    }
    // 스냅숏 없음 · 그 달 스냅숏 없음 = tierBMetrics 가 TierBError.
    final TierBMetrics m = tierBMetrics(tierBSeries(_db, d), d);
    final TierBVerdict v = judgeTierB(m, card);
    final (double, double)? trigger = tierBTrigger(m, card, v);
    final DateTime now = _clock.nowUtc();
    final String at = now.toIso8601String();
    final String since = _kstYmd(now);
    final List<String> moved = <String>[];
    inLedgerTransaction(_db, () {
      for (final (String id, String state, double cap) in pending) {
        final bool move = v.any && state == 'ACTIVE';
        _db.execute(
          'INSERT INTO tier_b_judgement(judged_month, strategy_id, judged_at, b1_breached, b2_breached, '
          'b3_breached, transitioned) VALUES (?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            month,
            id,
            at,
            v.b1 ? 1 : 0,
            v.b2 ? 1 : 0,
            v.b3 ? 1 : 0,
            move ? 1 : 0,
          ],
        );
        if (!move) continue;
        _db.execute(
          "UPDATE strategy_state_current SET state = 'PROBATION', since = ?, capital_cap = ? WHERE strategy_id = ?",
          <Object?>[since, cap * 0.5, id],
        );
        _db.execute(
          'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, from_state, to_state, trigger_value, '
          "threshold_registered, reason) VALUES (?, ?, ?, 'ACTIVE', 'PROBATION', ?, ?, ?)",
          <Object?>[
            tierBLogIdOf(month, id),
            id,
            at,
            trigger!.$1,
            trigger.$2,
            tierBReasonOf(v.firstCode!),
          ],
        );
        moved.add(id);
      }
    });
    return TierBStepReport(
      judgedMonth: month,
      cardMissing: false,
      judged: <String>[for (final (String id, _, _) in pending) id],
      transitioned: moved,
      metrics: m,
      verdict: v,
    );
  }
}
