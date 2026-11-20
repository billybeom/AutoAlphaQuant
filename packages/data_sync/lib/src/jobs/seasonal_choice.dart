// 🆕 E11q-b2b — 계절 A 진입 사람 선택(3택) 적용을 재개 실행기에서 뽑은 것(설계 13 §8 R194 · 01 §31 K54 · R77 S3 그대로).
//
// 🔴 판정 · 쓰기 = 옛 `ResumeJob.applySeasonalChoice` 그대로(한 줄도 바꾸지 않고 옮김 — 재개 실행기는 이 클래스에 맡긴다) ·
//    조립 앱의 안전 동작(`SafetyActions.run(seasonalWindowChoice)`)이 주문 잡 조립(브로커 · 리스 · 재판정기 · 사다리) 없이 부를 수 있게.
// 🔴 전제 = 재개 R6 과 같은 셈(simInternal = 자동 충족 · 그 밖 = 대사 불일치 플래그 · UNKNOWN · 잔류).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/order_ledger.dart' show SqliteOrderLedger;
import '../local/planned_work_store.dart'
    show PlannedWorkRow, SqlitePlannedWorkStore;

/// 계절 A 진입 사람 선택 적용(재개 실행기와 같은 판정).
class SqliteSeasonalChoice {
  /// 만든다 — [runMode] = 이 원장 파일의 실행 모드 · [operatingMode] = 운영 모드(원장에 없다 · 주입).
  SqliteSeasonalChoice(
    this._db, {
    required this._runMode,
    required this._operatingMode,
    required this._clock,
    required this._ledger,
  });

  final Database _db;
  final RunMode _runMode;
  final OperatingMode _operatingMode;
  final Clock _clock;
  final SqliteOrderLedger _ledger;

  bool get _sim => _runMode == RunMode.simInternal;
  bool get _advisory => _operatingMode == OperatingMode.advisory;

  /// child 전제(R3 · R4 결과 · simInternal = 자동 충족) — 재개 실행기 R6 과 같은 셈.
  Future<ResumePreconditions> preconditions() async => _sim
      ? ResumePreconditions(
          reconMismatches: 0,
          unknownOrders: 0,
          residualOrders: 0,
        )
      : ResumePreconditions(
          reconMismatches:
              (await _ledger.activeBlockFlags()).contains(FlagIds.reconMismatch)
              ? 1
              : 0,
          unknownOrders: _ledger.unknownCount(),
          residualOrders: _ledger.residualCount(),
        );

  /// 🆕 E14d2b(R77 S3) — 계절 A 진입 사람 선택 적용 — 거부 코드(쓰기 0) · null = 적용.
  ///
  /// 모드 = 마지막 재개 회차의 모드(없으면 NORMAL) · 전제 = R6 과 같은 셈. 허용이면 결정 행(kind ENTRY ·
  /// reason_code = HUMAN_* · parent = 계절 판정)을 먼저 남기고(같은 id 두 번 = 무시) 전이(사람 결정 id)를 한다.
  Future<String?> apply({
    required String workId,
    required SeasonalWindowChoice choice,
    required String decisionId,
    required TradeDate today,
  }) async {
    final SqlitePlannedWorkStore planned = SqlitePlannedWorkStore(
      _db,
      carry: _ledger,
      clock: _clock,
    );
    final PlannedWorkRow? row = planned
        .rows()
        .where((PlannedWorkRow w) => w.workId == workId)
        .firstOrNull;
    if (row == null) return PlannedWorkCodes.unknown;
    final ResumeWorkItem? item = itemOf(row);
    if (item == null) {
      return SeasonalChoiceCodes.notSeasonalEntry;
    }
    final ResultSet last = _db.select(
      'SELECT mode FROM resume_run ORDER BY started_at DESC, resume_run_id DESC LIMIT 1',
    );
    final ResumeMode mode = last.isEmpty
        ? ResumeMode.normal
        : ResumeMode.values.firstWhere(
            (ResumeMode m) => m.wire == last.first['mode'],
          );
    final String? code = seasonalChoiceRejectCode(
      item: item,
      choice: choice,
      decisionId: decisionId,
      today: today,
      mode: mode,
      advisory: _advisory,
      preconditions: await preconditions(),
    );
    if (code != null) return code;
    final ResumeItemJudgement j = seasonalChoiceJudgement(choice);
    _db.execute(
      'INSERT OR IGNORE INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
      "reason_code, config_hash, parent_decision_id) SELECT ?, ?, ?, mode, 'ENTRY', strategy_id, ?, ?, "
      'config_hash, decision_id FROM decision_log WHERE decision_id = ?',
      <Object?>[
        decisionId,
        _clock.nowUtc().toUtc().toIso8601String(),
        today.yyyyMmDd,
        '계절 A 진입 사람 선택 — ${choice.name}',
        j.reasonCode,
        row.decisionId,
      ],
    );
    return planned.transition(
      workId,
      j.nextState,
      today: today,
      verdictCode: j.verdictCode,
      decisionId: decisionId,
    );
  }

  /// `planned_work` 행 → 판정 입력(방향 · 매도 = kind · 원 계획에서 짓는다 · 모르는 kind = null).
  ResumeWorkItem? itemOf(PlannedWorkRow w) {
    final (ResumeDirection, bool)? dir = switch (w.kind) {
      ResumeWorkKinds.monthlyPlan => (ResumeDirection.rebalance, false),
      ResumeWorkKinds.seasonalWindow => _seasonalDirection(w.decisionId),
      _ => null,
    };
    if (dir == null) return null;
    final ResultSet rs = _db.select(
      'SELECT created_at FROM planned_work WHERE work_id = ?',
      <Object?>[w.workId],
    );
    return ResumeWorkItem(
      workId: w.workId,
      kind: w.kind,
      oneLine: w.oneLine,
      state: w.state,
      plannedOn: TradeDate(
        kstDateText(DateTime.parse(rs.first['created_at'] as String)),
      ),
      dueBy: w.dueBy,
      direction: dir.$1,
      sell: dir.$2,
    );
  }

  (ResumeDirection, bool)? _seasonalDirection(String? decisionId) {
    if (decisionId == null) return null;
    final ResultSet rs = _db.select(
      "SELECT json_extract(trigger_snapshot, '\$.side') AS side FROM rebalance_event "
      "WHERE decision_id = ? AND kind = 'SEASONAL'",
      <Object?>[decisionId],
    );
    if (rs.isEmpty) return null;
    return switch (rs.first['side']) {
      'BUY' => (ResumeDirection.entry, false),
      'SELL' => (ResumeDirection.defensive, true),
      _ => null,
    };
  }
}
