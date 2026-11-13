// 재개 재판정 실물(06 X2-3 · 04 §3-1 v2.42 ③ · 설계 13 §8 R76 Q1 · Q3 · 🔴 발주자 결정 2026-11-13).
//
// 🔴 월말 = «M 의 판정 + T 의 금액» — `MonthlyRebalanceJob.replanAsOf` 가 child 계획을 남기고 대상 수를 돌려준다.
// 🔴 계절 = 남은 주수(목표 − 체결 누계) > 0 이면 할 일 있음 · child 계획 없음(분할 창 안이면 기존 원천이 남은 몫을 낸다).
// 🔴 모르는 kind · 원 계획 없음 · 입력 부족 = 예외 — 실행기가 «재판정 실패»로 세고 플래그를 풀지 않는다.

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'monthly_rebalance_job.dart' show MonthlyRebalanceJob;

/// 재개 child 결정 id(R70 D15 — 실행기 `ResumeJob` 과 같은 꼴).
String resumeChildDecisionIdOf(String workId, TradeDate today) =>
    '$workId#RESUME-${today.yyyyMmDd}';

/// 재판정 실물(R76).
class SqliteResumeReevaluator implements ResumeReevaluator {
  /// 재판정을 만든다 — [monthly] = 월말 계획기 · [carry] = 계절 분할 진행.
  SqliteResumeReevaluator(
    this._db, {
    required this._monthly,
    required this._carry,
  });

  final Database _db;
  final MonthlyRebalanceJob _monthly;
  final CarryLedger _carry;

  @override
  Future<bool> actionNeeded(ResumeWorkItem item, TradeDate today) async {
    final ResultSet rs = _db.select(
      'SELECT decision_id FROM planned_work WHERE work_id = ?',
      <Object?>[item.workId],
    );
    final String? decision = rs.isEmpty
        ? null
        : rs.first['decision_id'] as String?;
    if (decision == null) {
      throw StateError('결정 없는 계획 행: ${item.workId}');
    }
    return switch (item.kind) {
      ResumeWorkKinds.monthlyPlan => await _monthlyNeeded(
        item,
        decision,
        today,
      ),
      ResumeWorkKinds.seasonalWindow => await _seasonalNeeded(decision, today),
      _ => throw ArgumentError.value(item.kind, 'kind', '재판정 못 하는 종류'),
    };
  }

  Future<bool> _monthlyNeeded(
    ResumeWorkItem item,
    String decision,
    TradeDate today,
  ) async {
    final String monthEnd = _monthEndOf(decision);
    final int n = await _monthly.replanAsOf(
      TradeDate(monthEnd),
      today,
      parentWorkId: item.workId,
      childDecisionId: resumeChildDecisionIdOf(item.workId, today),
      dueBy: item.dueBy,
    );
    return n > 0;
  }

  // `MONTH-END-{M}` · `PW-MONTH-END-{M}#RESUME-{T}`(child 의 child) → M.
  static String _monthEndOf(String decision) {
    final RegExpMatch? m = RegExp(r'MONTH-END-(\d{4}-\d{2}-\d{2})')
        .firstMatch(decision);
    if (m == null) {
      throw ArgumentError.value(decision, 'decision', '월말 결정이 아니다');
    }
    return m.group(1)!;
  }

  Future<bool> _seasonalNeeded(String decision, TradeDate today) async {
    final ResultSet rs = _db.select(
      "SELECT trigger_snapshot FROM rebalance_event WHERE decision_id = ? AND kind = 'SEASONAL'",
      <Object?>[decision],
    );
    if (rs.isEmpty) throw StateError('계절 판정 행 없음: $decision');
    final Map<String, Object?> t = jsonDecode(
      rs.first['trigger_snapshot'] as String,
    ) as Map<String, Object?>;
    final int target = t['target_shares']! as int;
    final SplitProgress p = await _carry.splitProgress(
      decision,
      strategyId: P0sStrategyIds.sleeveA,
      symbol: t['a_symbol']! as String,
      before: today,
    );
    return target - p.filled > 0;
  }
}
