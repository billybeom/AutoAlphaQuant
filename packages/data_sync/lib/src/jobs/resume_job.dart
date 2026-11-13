// 재개 실행기 뼈대 R0~R8(06 X2-1 · 04 §3-1 v2.42 ②③④ · 08M 그림 10-1 · 설계 13 §8 R70 · R72 · R75 N1~N9).
//
// 🔴 재개는 주문을 내지 않는다(«집행 위임») — 회차를 열 때 `RESUME_INCOMPLETE`(전 주문 차단)를 세우고, R6 까지 마치고
//    멈출 사유가 없을 때만 푼다. 실제 발주 = 다음 `kr_order` 회차가 NR-1 그대로.
// 🔴 크래시 멱등 — 단계가 끝날 때마다 `resume_run.phase` 커밋 · 열린 회차는 다음 단계부터 이어간다.
// 🔴 «어떤 입력에서도 DONE» — 리스 · 브로커 · 재판정이 실패해도 단계는 끝난다(결과는 멈출 사유 · 보고로 남는다).
// 🔴 잡 본체다 — 핑 · 휴장 · `job_run` = 조립 앱이 `runJob` 으로 감싼다.
// 🟡 E14d1 판 밖 = 재판정 실물 · child 대상 원천 · R5 수집 · 소급 불가 `data_gap` · 선행 가드(E14d2).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';

import '../local/job_run_store.dart' show SqliteJobRunLog;
import '../local/order_ledger.dart' show SqliteOrderLedger;
import '../local/planned_work_store.dart'
    show PlannedWorkRow, SqlitePlannedWorkStore;
import '../local/resume_store.dart' show ResumeRunRow, SqliteResumeStore;
import 'daily_jobs.dart' show DailyJobReport;
import 'resume_reevaluator.dart' show resumeChildDecisionIdOf;

/// 재개 회차 보고.
class ResumeJobReport implements DailyJobReport {
  /// 보고를 만든다.
  const ResumeJobReport({
    required this.resumeRunId,
    required this.continued,
    required this.mode,
    required this.gapTradingDays,
    required this.lease,
    required this.stopReasons,
    required this.items,
    required this.counts,
    required this.headline,
    required this.haltReason,
    required this.flagReleased,
    required this.reevaluationFailures,
    required this.alerts,
  });

  /// 할 일 없음(갭 0 · 플래그 없음 · 첫 가동).
  static const ResumeJobReport idle = ResumeJobReport(
    resumeRunId: null,
    continued: false,
    mode: null,
    gapTradingDays: null,
    lease: null,
    stopReasons: <String>[],
    items: <ResumeItem>[],
    counts: null,
    headline: null,
    haltReason: null,
    flagReleased: false,
    reevaluationFailures: 0,
    alerts: <String>{},
  );

  /// 회차 id(null = 할 일 없음).
  final String? resumeRunId;

  /// 열린 회차를 이어갔나(크래시 뒤).
  final bool continued;

  /// 재개 모드.
  final ResumeMode? mode;

  /// 갭(거래일).
  final int? gapTradingDays;

  /// R0 리스 판정(이번에 돌았을 때만).
  final LeaseVerdict? lease;

  /// R1 정지 사유(킬스위치 · 차단 플래그 · UNKNOWN · 잔류 — 회차를 멈추지 않는다).
  final List<String> stopReasons;

  /// R6 항목(우선순위 차례 · 이번에 돌았을 때만).
  final List<ResumeItem> items;

  /// 집계.
  final ResumeCounts? counts;

  /// 머리말.
  final String? headline;

  /// 매매를 멈춰 둔 사유(null = 풀었다).
  final String? haltReason;

  /// `RESUME_INCOMPLETE` 가 풀렸나.
  final bool flagReleased;

  /// 재판정 실패 수.
  final int reevaluationFailures;

  @override
  final Set<String> alerts;
}

/// 재개 실행기(R75 N1).
class ResumeJob {
  /// 실행기를 만든다 — [runMode] = 이 원장 파일의 실행 모드 · [operatingMode] = 운영 모드(원장에 없다 · 주입) ·
  /// [backupGapDays] = 복원 백업 나이(null = 축 빠짐).
  ResumeJob(
    this._db, {
    required this._runMode,
    required this._operatingMode,
    required this._kr,
    required this._clock,
    required this._ledger,
    required this._brokers,
    required this._accountByStrategy,
    required this._lease,
    required this._reevaluator,
    required this._ladder,
    this._backupGapDays,
    this._recheckDelay = kReconRecheckDelay,
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? Future<void>.delayed;

  final Database _db;
  final RunMode _runMode;
  final OperatingMode _operatingMode;
  final ExchangeCalendar _kr;
  final Clock _clock;
  final SqliteOrderLedger _ledger;
  final Map<String, AccountBroker> _brokers;
  final Map<String, String> _accountByStrategy;
  final LeaseGate _lease;
  final ResumeReevaluator _reevaluator;
  final ResumeLadder _ladder;
  final int? _backupGapDays;
  final Duration _recheckDelay;
  final Future<void> Function(Duration) _sleep;

  bool get _sim => _runMode == RunMode.simInternal;
  bool get _advisory => _operatingMode == OperatingMode.advisory;

  /// 한 번 돈다 — 열린 회차를 잇거나 새 회차를 연다(갭 > 0 ∨ 플래그) · 아니면 할 일 없음.
  Future<ResumeJobReport> run(TradeDate today) async {
    final SqliteResumeStore store = SqliteResumeStore(_db, clock: _clock);
    final SqlitePlannedWorkStore planned = SqlitePlannedWorkStore(
      _db,
      carry: _ledger,
      clock: _clock,
    );
    ResumeRunRow? r = store.openRun();
    final bool continued = r != null;
    LeaseVerdict? lease;
    if (r == null) {
      final int? gap = resumeGapSessions(
        calendar: _kr,
        lastSuccessSession: SqliteJobRunLog(_db)
            .lastSuccessSession('equity_snapshot'),
        today: today,
      );
      if ((gap ?? 0) == 0 && !store.flagActive()) return ResumeJobReport.idle;
      final ResumeMode mode = resumeModeOf(
        gapSessions: gap ?? 0,
        backupGapDays: _backupGapDays,
        ladder: _ladder,
      );
      // R0 — 회차 열기 · 플래그(한 트랜잭션) · 리스는 보고만(발주를 안 한다).
      r = store.startRun(today: today, gapTradingDays: gap ?? 0, mode: mode);
      lease = await readLease(_lease);
    }
    final String id = r.resumeRunId;
    final ResumeMode mode = r.mode;
    int done = r.phase.index;
    bool due(ResumePhase p) => p.index > done;
    void commit(ResumePhase p) {
      store.commitPhase(id, p);
      done = p.index;
    }

    // R1 — 정지 사유 수집만.
    final List<String> stops = <String>[];
    if (due(ResumePhase.r1)) {
      if (await _ledger.killSwitchActive()) stops.add('KILL_SWITCH');
      final Set<String> flags = (await _ledger.activeBlockFlags())
        ..remove(FlagIds.resumeIncomplete);
      stops.addAll(flags.toList()..sort());
      if (_ledger.unknownCount() > 0) stops.add('UNKNOWN_ORDERS');
      if (_ledger.residualCount() > 0) stops.add('RESIDUAL_ORDERS');
      commit(ResumePhase.r1);
    }
    // R2 — 갭 · 모드는 회차를 열 때 정했다(이어갈 때 다시 재지 않는다).
    if (due(ResumePhase.r2)) commit(ResumePhase.r2);
    // R3 · R4 — 대사 · UNKNOWN 해소(simInternal = 자동 충족 · 실패해도 단계는 끝난다).
    if (due(ResumePhase.r3)) {
      if (!_sim) {
        try {
          await runReconciliation(
            ledger: _ledger,
            brokers: _brokers,
            balances: _brokers,
            accountByStrategy: _accountByStrategy,
            tradeDate: today,
            nowUtc: _clock.nowUtc,
            recheckDelay: _recheckDelay,
            sleep: _sleep,
          );
        } on Object {
          // 결과는 R6 전제(대사 불일치 플래그)로 남는다.
        }
      }
      commit(ResumePhase.r3);
    }
    if (due(ResumePhase.r4)) {
      if (!_sim) {
        try {
          await resolveUnknownOrders(
            ledger: _ledger,
            brokers: _brokers,
            nowUtc: _clock.nowUtc(),
          );
        } on Object {
          // 남은 UNKNOWN 은 R6 전제로 다시 센다.
        }
      }
      commit(ResumePhase.r4);
    }
    // R5 — 증분 수집은 정기 잡이 갭을 메운다 · 소급 불가 기록 = E14d2.
    if (due(ResumePhase.r5)) commit(ResumePhase.r5);
    // R6 — 재판정.
    final ResumePreconditions pre = _sim
        ? ResumePreconditions(
            reconMismatches: 0,
            unknownOrders: 0,
            residualOrders: 0,
          )
        : ResumePreconditions(
            reconMismatches:
                (await _ledger.activeBlockFlags()).contains(
                  FlagIds.reconMismatch,
                )
                ? 1
                : 0,
            unknownOrders: _ledger.unknownCount(),
            residualOrders: _ledger.residualCount(),
          );
    final List<ResumeItem> items = <ResumeItem>[];
    final List<String> verdicts = <String>[];
    int failures = 0;
    final bool r6Now = due(ResumePhase.r6);
    if (r6Now) {
      final List<ResumeWorkItem> work = resumePriorityOrder(<ResumeWorkItem>[
        for (final PlannedWorkRow w in <PlannedWorkRow>[
          ...planned.rows(state: PlannedWorkState.planned),
          ...planned.rows(state: PlannedWorkState.blocked),
        ])
          ?_itemOf(w),
      ]);
      for (final ResumeWorkItem item in work) {
        final ResumeItemStep step = judgeResumeItem(
          item: item,
          today: today,
          mode: mode,
          advisory: _advisory,
          preconditions: pre,
        );
        ResumeItemJudgement? j;
        switch (step) {
          case ResumeItemUntouched():
            continue;
          case ResumeItemDecided(:final ResumeItemJudgement judgement):
            j = judgement;
          case ResumeItemNeedsReevaluation():
            try {
              j = reevaluatedJudgement(
                actionNeeded: await _reevaluator.actionNeeded(item, today),
              );
            } on Object {
              failures++;
              j = null;
            }
        }
        if (j == null) {
          verdicts.add(VerdictCodes.blocked);
          items.add(
            resumeItemOf(
              item: item,
              judgement: const ResumeItemJudgement(
                nextState: PlannedWorkState.blocked,
                verdictCode: VerdictCodes.blocked,
                reasonCode: ResumeReasonCodes.reevaluationFailed,
              ),
              today: today,
            ),
          );
          continue;
        }
        if (j.nextState != item.state) {
          planned.transition(
            item.workId,
            j.nextState,
            today: today,
            verdictCode: j.verdictCode,
            decisionId: j.delegates ? _childIdOf(item, today) : null,
            resumeRunId: id,
          );
        }
        if (j.delegates) _writeChild(item, today, id);
        verdicts.add(j.verdictCode);
        items.add(resumeItemOf(item: item, judgement: j, today: today));
      }
      commit(ResumePhase.r6);
    }
    // R7 — 집행 위임 · 멈출 사유가 없으면 플래그를 푼다.
    final String? halt =
        resumeHaltReason(mode: mode, advisory: _advisory, preconditions: pre) ??
        (failures > 0 ? ResumeReasonCodes.reevaluationFailed : null);
    if (due(ResumePhase.r7)) {
      if (halt == null) store.clearFlag();
      commit(ResumePhase.r7);
    }
    // R8 — 집계 · 머리말 · 끝 · 묶음 알림(이번에 R6 을 돌지 않았으면 이 회차의 전이에서 센다).
    final ResumeCounts counts = resumeCountsOf(
      verdictCodes: r6Now ? verdicts : store.roundVerdicts(id),
      unrecoverableGaps: 0,
    );
    final String headline = resumeHeadline(
      gapSessions: r.gapTradingDays,
      counts: counts,
      haltReason: halt,
    );
    store.finishRun(id, counts: counts, headline: headline);
    final bool released = !store.flagActive();
    return ResumeJobReport(
      resumeRunId: id,
      continued: continued,
      mode: mode,
      gapTradingDays: r.gapTradingDays,
      lease: lease,
      stopReasons: stops,
      items: items,
      counts: counts,
      headline: headline,
      haltReason: halt,
      flagReleased: released,
      reevaluationFailures: failures,
      alerts: resumeBundleAlerts(flagReleased: released, unrecoverableGaps: 0),
    );
  }

  /// child 결정 id(D15 — 원 결정의 RESUME 자식 · 같은 날 다시 = 같은 id).
  static String _childIdOf(ResumeWorkItem item, TradeDate today) =>
      resumeChildDecisionIdOf(item.workId, today);

  // child 결정 행(kind RESUME · parent = 원 계획 결정) — 같은 id 두 번 = 무시(크래시 멱등).
  void _writeChild(ResumeWorkItem item, TradeDate today, String runId) {
    final String? parent = _parentOf(item.workId);
    if (parent == null) return;
    _db.execute(
      'INSERT OR IGNORE INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, reason, '
      "reason_code, config_hash, parent_decision_id) SELECT ?, ?, ?, mode, 'RESUME', strategy_id, ?, "
      "'RESUME_CHILD', config_hash, decision_id FROM decision_log WHERE decision_id = ?",
      <Object?>[
        _childIdOf(item, today),
        _clock.nowUtc().toUtc().toIso8601String(),
        today.yyyyMmDd,
        '재개 $runId — ${item.oneLine} 재판정 값으로 다음 주문 회차에 위임',
        parent,
      ],
    );
  }

  String? _parentOf(String workId) {
    final ResultSet rs = _db.select(
      'SELECT decision_id FROM planned_work WHERE work_id = ?',
      <Object?>[workId],
    );
    return rs.isEmpty ? null : rs.first['decision_id'] as String?;
  }

  // `planned_work` 행 → 판정 입력(방향 · 매도 = kind · 원 계획에서 짓는다 · 모르는 kind = null).
  ResumeWorkItem? _itemOf(PlannedWorkRow w) {
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
