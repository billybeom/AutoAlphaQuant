// 계층 B 월간 판정 단계 — `monthly_rebalance` 안 · 계획 저장 뒤(설계 13 §8 R50 T1 · T5~T9 · SPEC v2.39 · 04 SAF-410 · FR-708).
//
// 🔴 시리즈 = 포트폴리오 `equity_snapshot` 1 개 · 외부 흐름 = `cash_flow` 의 DEPOSIT · WITHDRAWAL 만(T2).
// 🔴 카드 미등록 = 판정 행을 쓰지 않는다(보고 «카드 없음») — `tierBUnjudged` 가 월말 뒤 3세션부터 신규 매수를 막는 것이 정답(D7 ③).
// 🔴 판정 행 = `strategy_state_current` 의 전 전략에 같은 판정(D7 ①) · ACTIVE → PROBATION 전이와 **한 트랜잭션**(T6).
// 🔴 멱등 = 그 달 판정 행이 이미 있는 전략은 건너뛴다(T7) · 실패 = 아무것도 쓰지 않고 [TierBError](T8).
// 🆕 R247(R50 T10 · 03 §1-5 «P0S 등록») — PROBATION 전략은 진입 다음 달 월말부터 복귀 판정(롤링 12M ≥ +5% AND B1~B3 안 걸림 →
//    ACTIVE · 상한 1) · 진입 판정 뒤 24번째 판정까지 복귀 못 하면 자동 RETIRED(상한 0) · 신호 일치(B5) = 판정 보류라 조건 밖.
//    🔴 회수처 C(`tierBCapReceiver`)는 상태 라벨만 함께 옮기고 `capital_cap` 은 그대로 · 전이 = 판정 행과 한 트랜잭션.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/deposit_ledger.dart' show openingCashTradeDate;
import '../market/market_store.dart' show inLedgerTransaction;

/// 전이 사유 코드(`strategy_state_log.reason`).
String tierBReasonOf(String code) => 'TIER_B_$code';

/// 전이 기록 id.
String tierBLogIdOf(String month, String strategyId) =>
    'TIERB-$month-$strategyId';

/// 🆕 R247 — 복귀 · 만료 사유 코드(`strategy_state_log.reason` = `TIER_B_RETURN` · `TIER_B_EXPIRED`).
abstract final class TierBExitCodes {
  /// 복귀.
  static const String returned = 'RETURN';

  /// 기간 만료 → RETIRED.
  static const String expired = 'EXPIRED';
}

/// 🆕 R247 — 복귀 · 만료 기록 id(`TIERB-RETURN-{달}-{전략}` · `TIERB-EXPIRED-{달}-{전략}`).
String tierBExitLogIdOf(String code, String month, String strategyId) =>
    'TIERB-$code-$month-$strategyId';

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
    this.returned = const <String>[],
    this.retired = const <String>[],
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

  /// 🆕 R247 — 이번에 PROBATION → ACTIVE 로 돌아온 전략.
  final List<String> returned;

  /// 🆕 R247 — 이번에 PROBATION 기간 만료로 RETIRED 가 된 전략.
  final List<String> retired;

  String get _exitsText =>
      '${returned.isEmpty ? '' : ' · 복귀 ${returned.length}'}'
      '${retired.isEmpty ? '' : ' · 은퇴 ${retired.length}'}';

  @override
  String toString() =>
      'TierBStepReport($judgedMonth · ${cardMissing ? '카드 없음' : '판정 ${judged.length} · 전이 ${transitioned.length}$_exitsText'})';
}

/// 🆕 R247 — 계획기 상한(P0S_A · P0S_B · P0S_POT 의 상태 · `capital_cap` → [plannerCapOf] · C = 회수처라 없음).
P0sRiskCaps p0sRiskCapsOf(Database db) {
  double capOf(String id) {
    final ResultSet rs = db.select(
      'SELECT state, capital_cap FROM strategy_state_current WHERE strategy_id = ?',
      <Object?>[id],
    );
    return rs.isEmpty
        ? plannerCapOf(null, null)
        : plannerCapOf(
            rs.first['state'] as String,
            (rs.first['capital_cap'] as num).toDouble(),
          );
  }

  return P0sRiskCaps(
    a: capOf(P0sStrategyIds.sleeveA),
    b: capOf(P0sStrategyIds.sleeveB),
    pot: capOf(P0sStrategyIds.pot),
  );
}

/// 🆕 R247 — 슬리브 A 축소 매도가 아직 남았나: P0S_A 의 마지막 상태 기록이 계층 B 의 낮춤 전이(→ PROBATION · → RETIRED)
/// 이고 그 뒤 P0S_A 주문 의도가 하나도 없다(축소 · 계절 진입 · 청산 어느 것이든 나갔으면 지금 보유는 이미 상한 뒤 크기).
bool sleeveACapTrimDue(Database db) {
  final ResultSet rs = db.select(
    'SELECT to_state, changed_at, reason FROM strategy_state_log WHERE strategy_id = ? '
    'ORDER BY changed_at DESC, rowid DESC LIMIT 1',
    <Object?>[P0sStrategyIds.sleeveA],
  );
  if (rs.isEmpty) return false;
  final String to = rs.first['to_state'] as String;
  final String reason = rs.first['reason'] as String;
  if (!reason.startsWith(tierBReasonOf('')) ||
      (to != 'PROBATION' && to != 'RETIRED')) {
    return false;
  }
  return db.select(
    'SELECT 1 FROM order_intents WHERE strategy_id = ? AND created_at > ? LIMIT 1',
    <Object?>[P0sStrategyIds.sleeveA, rs.first['changed_at'] as String],
  ).isEmpty;
}

String _kstYmd(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

/// [monthEnd] 까지의 시리즈 — 스냅숏 날짜 순 · 점마다 (앞 스냅숏 날 뒤 ~ 그날) 입출금 합.
///
/// 🆕 E15d1(R85 AA5 · SPEC v2.44 02 §2-7) — 🔴 지수 첫날 = 개시 날 이후 첫 스냅숏(개시 이전 구간은 성과 밖).
/// 그래서 개시 입금 행(`kOpeningCashNotes` · 개시 날 ≤ 첫 스냅숏 날)은 어느 구간(앞 스냅숏 날 뒤 ~ 그날)에도
/// 들지 않는다 = 외부 흐름이 아니다. 🔴 흐름에서 따로 빼지 않는다 — 시작점을 옮기지 않고 흐름만 빼면, 개시 앞
/// 스냅숏이 있을 때 개시 금액이 수익으로 잡힌다.
List<EquityPoint> tierBSeries(Database db, String monthEnd) {
  final String? opening = openingCashTradeDate(db);
  final List<(String, double)> snaps = <(String, double)>[
    for (final Row r in db.select(
      'SELECT trade_date, total_equity FROM equity_snapshot WHERE trade_date <= ? AND trade_date >= ? '
      'ORDER BY trade_date',
      <Object?>[monthEnd, opening ?? ''],
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
  TierBStep(
    this._db, {
    required this._clock,
    this._card = p0sTierBCard,
    this._rule = p0sProbationRule,
  });

  final Database _db;
  final Clock _clock;
  final TierBCard? Function() _card;
  final TierBProbationRule Function() _rule;

  /// 🆕 R247 — PROBATION 진입 판정 달(그 전략의 [month] 앞 마지막 전이 판정 — PROBATION 중이면 그것이 진입).
  String? _entryMonth(String id, String month) {
    final ResultSet rs = _db.select(
      'SELECT judged_month FROM tier_b_judgement WHERE strategy_id = ? AND transitioned = 1 '
      'AND judged_month < ? ORDER BY judged_month DESC LIMIT 1',
      <Object?>[id, month],
    );
    return rs.isEmpty ? null : rs.first['judged_month'] as String;
  }

  /// 🆕 R247 — 진입 판정 뒤 판정 횟수(이번 판정 포함 · 빠진 달은 세지 않는다 = «월말 판정 24회»).
  int _observations(String id, String entry, String month) =>
      (_db.select(
            'SELECT COUNT(*) AS n FROM tier_b_judgement WHERE strategy_id = ? '
            'AND judged_month > ? AND judged_month < ?',
            <Object?>[id, entry, month],
          ).first['n']
          as int) +
      1;

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
    // 🆕 R247 — PROBATION 전략의 복귀 · 만료(쓰기 전에 다 읽는다 · 진입 판정이 없으면 = 무결성 실패 · 아무것도 안 씀).
    final TierBProbationRule rule = _rule();
    final Map<String, (TierBProbationOutcome, int)> exits =
        <String, (TierBProbationOutcome, int)>{};
    for (final (String id, String state, double _) in pending) {
      if (state != 'PROBATION') continue;
      final String? entry = _entryMonth(id, month);
      if (entry == null) throw TierBError('PROBATION 진입 판정 없음: $id');
      final int n = _observations(id, entry, month);
      exits[id] = (judgeProbation(m, v, observations: n, rule: rule), n);
    }
    final DateTime now = _clock.nowUtc();
    final String at = now.toIso8601String();
    final String since = _kstYmd(now);
    final List<String> moved = <String>[];
    final List<String> back = <String>[];
    final List<String> gone = <String>[];
    inLedgerTransaction(_db, () {
      for (final (String id, String state, double cap) in pending) {
        final bool move = v.any && state == 'ACTIVE';
        final (TierBProbationOutcome, int)? exit = exits[id];
        final TierBProbationOutcome po = exit?.$1 ?? TierBProbationOutcome.stay;
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
            move || po != TierBProbationOutcome.stay ? 1 : 0,
          ],
        );
        if (po == TierBProbationOutcome.returned) {
          _exit(
            id,
            to: 'ACTIVE',
            cap: TierBCaps.active,
            since: since,
            at: at,
            logId: tierBExitLogIdOf(TierBExitCodes.returned, month, id),
            value: m.r12m!,
            threshold: rule.returnR12mFloor,
            reason: tierBReasonOf(TierBExitCodes.returned),
          );
          back.add(id);
          continue;
        }
        if (po == TierBProbationOutcome.expired) {
          _exit(
            id,
            to: 'RETIRED',
            cap: tierBCapReceiver(id) ? cap : TierBCaps.retired,
            since: since,
            at: at,
            logId: tierBExitLogIdOf(TierBExitCodes.expired, month, id),
            value: exit!.$2.toDouble(),
            threshold: rule.maxJudgements.toDouble(),
            reason: tierBReasonOf(TierBExitCodes.expired),
          );
          gone.add(id);
          continue;
        }
        if (!move) continue;
        _db.execute(
          "UPDATE strategy_state_current SET state = 'PROBATION', since = ?, capital_cap = ? WHERE strategy_id = ?",
          <Object?>[
            since,
            tierBCapReceiver(id) ? cap : cap * TierBCaps.probationFactor,
            id,
          ],
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
      returned: back,
      retired: gone,
    );
  }

  /// 🆕 R247 — PROBATION 에서 나가는 전이 한 건(상태 · 상한 · 기록 — 부르는 쪽 트랜잭션 안).
  void _exit(
    String id, {
    required String to,
    required double cap,
    required String since,
    required String at,
    required String logId,
    required double value,
    required double threshold,
    required String reason,
  }) {
    _db.execute(
      'UPDATE strategy_state_current SET state = ?, since = ?, capital_cap = ? WHERE strategy_id = ?',
      <Object?>[to, since, cap, id],
    );
    _db.execute(
      'INSERT INTO strategy_state_log(log_id, strategy_id, changed_at, from_state, to_state, trigger_value, '
      "threshold_registered, reason) VALUES (?, ?, ?, 'PROBATION', ?, ?, ?, ?)",
      <Object?>[logId, id, at, to, value, threshold, reason],
    );
  }
}
