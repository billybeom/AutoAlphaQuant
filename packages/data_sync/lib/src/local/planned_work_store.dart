// `planned_work` 등록 · 전이 · 평시 정리(06 X2-3 · 02 배치 C `planned_work` · `planned_work_transition` ·
// 설계 13 §8 R70 D6 · R72 J3 · R74 M1~M7).
//
// 🔴 등록 = 계획을 저장하는 **그 트랜잭션 안**(월말 · 계절 A) — 바깥 트랜잭션 없이 부르면 오류.
// 🔴 이월 의도(`CARRY_OVER`)는 등록하지 않는다 — 원장 파생(R74 M0).
// 🔴 전이 = core 상태기계(`plannedWorkTransitionRejectCode`)로 검사 · 현재값 UPDATE + 전이 append 를 한 트랜잭션에.
// 🔴 평시 정리 = 기한 지남 → EXPIRED · 끝남 → DONE(기한 지난 계획을 DONE 으로 보내지 않는다).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, OrderSide, PlannedWorkState, TradeDate, VerdictCodes;
import 'package:sqlite3/sqlite3.dart';

import '../jobs/monthly_rebalance_job.dart' show unissuedPlanTargets;
import '../market/market_store.dart' show inLedgerTransaction;

/// 등록 행 id(R74 M2).
String plannedWorkIdOf(String decisionId) => 'PW-$decisionId';

/// 전이 행 id — 그 전이 뒤의 `row_version`(등록 = 0).
String plannedWorkTransitionIdOf(String workId, int rowVersion) =>
    'PWT-$workId#$rowVersion';

/// 계획 JSON 의 digest(sha256 앞 12 · X2 원칙 ② «미러는 원문이 아니라 digest»).
String plannedWorkDigestOf(String payloadJson) =>
    sha256.convert(utf8.encode(payloadJson)).toString().substring(0, 12);

int _month(String ymd) => int.parse(ymd.substring(5, 7));

/// 월말 계획 한 줄.
String monthlyPlanOneLine(String monthEnd) => '${_month(monthEnd)}월말 정기 리밸런싱';

/// 계절 A 한 줄 — 매수 = 진입 · 매도 = 청산.
String seasonalPlanOneLine(String anchor, OrderSide side) =>
    '${_month(anchor)}월 계절 A ${side == OrderSide.buy ? '진입' : '청산'} 분할 집행';

/// 등록(R74 M1 · M2) — 🔴 바깥 트랜잭션 안에서만(계획 저장과 같은 트랜잭션). 같은 결정 두 번 = 오류(트랜잭션째 실패).
void registerPlannedWork(
  Database db, {
  required String kind,
  required String decisionId,
  required TradeDate dueBy,
  required String oneLine,
  required String payloadJson,
  required String createdAtUtc,
}) {
  if (db.autocommit) {
    throw StateError('planned_work 등록은 계획 저장 트랜잭션 안에서만');
  }
  final String workId = plannedWorkIdOf(decisionId);
  db.execute(
    'INSERT INTO planned_work (work_id, idempotency_key, kind, created_at, due_by, state, verdict_code, '
    "digest, one_line, parent_work_id, decision_id, origin, row_version) VALUES (?, ?, ?, ?, ?, 'PLANNED', NULL, "
    "?, ?, NULL, ?, 'LOCAL', 0)",
    <Object?>[
      workId,
      '$kind|$decisionId',
      kind,
      createdAtUtc,
      dueBy.yyyyMmDd,
      plannedWorkDigestOf(payloadJson),
      oneLine,
      decisionId,
    ],
  );
  db.execute(
    'INSERT INTO planned_work_transition (transition_id, work_id, from_state, to_state, verdict_code, '
    "resume_run_id, decision_id, occurred_at) VALUES (?, ?, NULL, 'PLANNED', NULL, NULL, ?, ?)",
    <Object?>[
      plannedWorkTransitionIdOf(workId, 0),
      workId,
      decisionId,
      createdAtUtc,
    ],
  );
}

/// `planned_work` 1행.
class PlannedWorkRow {
  /// 행을 만든다.
  const PlannedWorkRow({
    required this.workId,
    required this.kind,
    required this.decisionId,
    required this.dueBy,
    required this.state,
    required this.verdictCode,
    required this.oneLine,
    required this.digest,
    required this.rowVersion,
    required this.origin,
  });

  /// 행 id.
  final String workId;

  /// 종류.
  final String kind;

  /// 결정 id.
  final String? decisionId;

  /// 낼 수 있는 마지막 세션(포함).
  final TradeDate dueBy;

  /// 상태.
  final PlannedWorkState state;

  /// 재판정 결과 코드.
  final String? verdictCode;

  /// 엔진 한 줄.
  final String oneLine;

  /// 계획 digest.
  final String digest;

  /// 행 판.
  final int rowVersion;

  /// LOCAL · MIRROR.
  final String origin;
}

PlannedWorkState _state(String wire) =>
    PlannedWorkState.values.firstWhere((PlannedWorkState s) => s.wire == wire);

PlannedWorkRow _row(Row r) => PlannedWorkRow(
  workId: r['work_id'] as String,
  kind: r['kind'] as String,
  decisionId: r['decision_id'] as String?,
  dueBy: TradeDate(r['due_by'] as String),
  state: _state(r['state'] as String),
  verdictCode: r['verdict_code'] as String?,
  oneLine: r['one_line'] as String,
  digest: r['digest'] as String,
  rowVersion: r['row_version'] as int,
  origin: r['origin'] as String,
);

String _dayAfter(TradeDate d) =>
    DateTime.parse('${d.yyyyMmDd}T00:00:00Z')
        .add(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

/// `planned_work` 저장소(R74 M3 · M4 · M7).
class SqlitePlannedWorkStore implements PlannedWorkLedger {
  /// 저장소를 만든다 — [carry] = 계절 분할 진행(체결 누계) · [clock] = 전이 시각.
  SqlitePlannedWorkStore(
    this._db, {
    required this._carry,
    required this._clock,
  });

  final Database _db;
  final CarryLedger _carry;
  final Clock _clock;

  /// 행 — [state] 가 있으면 그 상태만 · `work_id` 차례.
  List<PlannedWorkRow> rows({PlannedWorkState? state}) => _db
      .select(
        state == null
            ? 'SELECT * FROM planned_work ORDER BY work_id'
            : 'SELECT * FROM planned_work WHERE state = ? ORDER BY work_id',
        <Object?>[?state?.wire],
      )
      .map(_row)
      .toList();

  /// 전이(R74 M3) — 거부 코드(쓰기 0) · null = 옮김(현재값 + 전이 1행 · 한 트랜잭션).
  String? transition(
    String workId,
    PlannedWorkState to, {
    required TradeDate today,
    String? verdictCode,
    String? decisionId,
    String? resumeRunId,
  }) => inLedgerTransaction(_db, () {
    final ResultSet rs = _db.select(
      'SELECT state, due_by, row_version FROM planned_work WHERE work_id = ?',
      <Object?>[workId],
    );
    if (rs.isEmpty) return PlannedWorkCodes.unknown;
    final PlannedWorkState from = _state(rs.first['state'] as String);
    final String? code = plannedWorkTransitionRejectCode(
      from: from,
      to: to,
      dueBy: TradeDate(rs.first['due_by'] as String),
      today: today,
    );
    if (code != null) return code;
    final int version = (rs.first['row_version'] as int) + 1;
    _db.execute(
      'UPDATE planned_work SET state = ?, verdict_code = ?, row_version = ? WHERE work_id = ?',
      <Object?>[to.wire, verdictCode, version, workId],
    );
    _db.execute(
      'INSERT INTO planned_work_transition (transition_id, work_id, from_state, to_state, verdict_code, '
      'resume_run_id, decision_id, occurred_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        plannedWorkTransitionIdOf(workId, version),
        workId,
        from.wire,
        to.wire,
        verdictCode,
        resumeRunId,
        decisionId,
        _clock.nowUtc().toUtc().toIso8601String(),
      ],
    );
    return null;
  });

  /// 평시 정리(R74 M4) — PLANNED 행마다 기한 지남 → EXPIRED · 끝남 → DONE. 옮긴 행 수.
  @override
  Future<int> settle(TradeDate today) async {
    int n = 0;
    for (final PlannedWorkRow r in rows(state: PlannedWorkState.planned)) {
      final PlannedWorkState? to =
          plannedWorkPastDue(dueBy: r.dueBy, today: today)
          ? PlannedWorkState.expired
          : await _finished(r, today)
          ? PlannedWorkState.done
          : null;
      if (to == null) continue;
      final String? code = transition(
        r.workId,
        to,
        today: today,
        verdictCode: to == PlannedWorkState.expired
            ? VerdictCodes.expired
            : null,
      );
      if (code == null) n++;
    }
    return n;
  }

  Future<bool> _finished(PlannedWorkRow r, TradeDate today) async {
    final String? id = r.decisionId;
    if (id == null) return false;
    if (r.kind == ResumeWorkKinds.monthlyPlan) {
      return _monthlyFinished(id, today);
    }
    if (r.kind == ResumeWorkKinds.seasonalWindow) {
      return _seasonalFinished(id, r.dueBy, today);
    }
    return false;
  }

  // 월말 = 집행일이 왔고 계획의 대상을 전부 낸 적이 있다(StoredPlanTargetSource 와 같은 축).
  bool _monthlyFinished(String decisionId, TradeDate today) {
    final ResultSet rs = _db.select(
      "SELECT p.outputs FROM decision_log d JOIN plan_snapshot p ON p.plan_id = 'REBAL-' || d.trade_date "
      "WHERE d.decision_id = ? AND p.kind = 'REBALANCE'",
      <Object?>[decisionId],
    );
    if (rs.isEmpty) return false;
    final Map<String, Object?> o =
        jsonDecode(rs.first['outputs'] as String) as Map<String, Object?>;
    final String exec = o['execution_day']! as String;
    if (today.yyyyMmDd.compareTo(exec) < 0) return false;
    return unissuedPlanTargets(_db, o).isEmpty;
  }

  // 계절 = 체결 누계 ≥ 목표 ∨ 기준 날(마지막 분할 날) 몫을 냈다(계절은 이월하지 않는다).
  Future<bool> _seasonalFinished(
    String decisionId,
    TradeDate anchor,
    TradeDate today,
  ) async {
    final ResultSet rs = _db.select(
      "SELECT trigger_snapshot FROM rebalance_event WHERE decision_id = ? AND kind = 'SEASONAL'",
      <Object?>[decisionId],
    );
    if (rs.isEmpty) return false;
    final Map<String, Object?> t = jsonDecode(
      rs.first['trigger_snapshot'] as String,
    ) as Map<String, Object?>;
    final String symbol = t['a_symbol']! as String;
    final String side = t['side']! as String;
    final int target = t['target_shares']! as int;
    final SplitProgress p = await _carry.splitProgress(
      decisionId,
      strategyId: P0sStrategyIds.sleeveA,
      symbol: symbol,
      before: TradeDate(_dayAfter(today)),
    );
    if (p.filled >= target) return true;
    return _db.select(
      'SELECT 1 FROM order_intents WHERE decision_id = ? AND symbol = ? AND side = ? LIMIT 1',
      <Object?>['$decisionId@${anchor.yyyyMmDd}', symbol, side],
    ).isNotEmpty;
  }
}
