// 재개 읽기 창구(앱 01 §4-1 `ResumeRepository` · 06 X2-6 · 설계 13 §8 R78 T0~T3 · SPEC v2.43 `resume_item`).
//
// 🔴 리포트 = 가장 최근 **끝난** 회차를 회차가 남긴 그대로 읽는다(`resume_run` · `resume_item` · 그 회차 `data_gap`) —
//    다시 판정하지 않는다 · 손익 0.
// 🔴 계획 목록 = `planned_work` → `PlannedWorkSummary`(원문 아님 · digest · 한 줄) · 리스 epoch = 0(E11k 전).

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        DataGapRow,
        PlannedWorkState,
        PlannedWorkSummary,
        ResumeCounts,
        ResumeItem,
        ResumeMode,
        ResumePhase,
        ResumeReport,
        ResumeRepository,
        TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_read_model.dart' show watchLedgerQuery;

/// 재개 읽기(R78).
class SqliteResumeRepository implements ResumeRepository {
  /// 창구를 만든다.
  SqliteResumeRepository(this._db);

  final Database _db;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'resume_run',
    'resume_item',
    'data_gap',
    'planned_work',
  };

  @override
  Stream<ResumeReport?> watchLatest() =>
      watchLedgerQuery(_db, watchedTables, latest);

  @override
  Stream<List<PlannedWorkSummary>> watchPlannedWork() =>
      watchLedgerQuery(_db, watchedTables, plannedWork);

  /// 가장 최근 끝난 회차의 리포트(없으면 null · T1).
  ResumeReport? latest() {
    final ResultSet rs = _db.select(
      'SELECT * FROM resume_run WHERE finished_at IS NOT NULL '
      'ORDER BY finished_at DESC, resume_run_id DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    final String id = r['resume_run_id'] as String;
    final ResumeMode mode = ResumeMode.values.firstWhere(
      (ResumeMode m) => m.wire == r['mode'],
    );
    final int gap = r['gap_trading_days'] as int;
    return ResumeReport(
      resumeRunId: id,
      startedAt: DateTime.parse(r['started_at'] as String).toUtc(),
      finishedAt: DateTime.parse(r['finished_at'] as String).toUtc(),
      gapTradingDays: gap,
      mode: mode,
      modeLabel: resumeModeLabel(gapSessions: gap, mode: mode),
      phase: ResumePhase.values.firstWhere(
        (ResumePhase p) => p.wire == r['phase'],
      ),
      counts: ResumeCounts.fromJson(
        jsonDecode(r['counts'] as String) as Map<String, dynamic>,
      ),
      items: <ResumeItem>[
        for (final Row i in _db.select(
          'SELECT * FROM resume_item WHERE resume_run_id = ? ORDER BY seq',
          <Object?>[id],
        ))
          ResumeItem(
            workId: i['work_id'] as String,
            oneLine: i['one_line'] as String,
            plannedLine: i['planned_line'] as String,
            reevaluatedLine: i['reevaluated_line'] as String,
            verdictCode: i['verdict_code'] as String,
            verdictLabel: i['verdict_label'] as String,
          ),
      ],
      unrecoverableGaps: <DataGapRow>[
        for (final Row g in _db.select(
          'SELECT * FROM data_gap WHERE substr(gap_id, 1, ?) = ? AND recoverable = 0 ORDER BY gap_id',
          <Object?>['GAP-$id-'.length, 'GAP-$id-'],
        ))
          DataGapRow(
            gapId: g['gap_id'] as String,
            dataset: g['dataset'] as String,
            from: TradeDate(g['from_date'] as String),
            to: TradeDate(g['to_date'] as String),
            recoverable: false,
            reasonCode: g['reason_code'] as String,
            label: resumeGapLabel(
              dataset: g['dataset'] as String,
              from: TradeDate(g['from_date'] as String),
              to: TradeDate(g['to_date'] as String),
            ),
          ),
      ],
      headline: r['headline'] as String,
    );
  }

  /// 계획 목록(`work_id` 차례 · T3).
  List<PlannedWorkSummary> plannedWork() => <PlannedWorkSummary>[
    for (final Row w in _db.select(
      'SELECT work_id, digest, one_line, due_by, state, row_version FROM planned_work ORDER BY work_id',
    ))
      () {
        final PlannedWorkState state = PlannedWorkState.values.firstWhere(
          (PlannedWorkState s) => s.wire == w['state'],
        );
        return PlannedWorkSummary(
          workId: w['work_id'] as String,
          digest: w['digest'] as String,
          oneLine: w['one_line'] as String,
          dueBy: TradeDate(w['due_by'] as String),
          state: state,
          stateLabel: plannedWorkStateLabel(state),
          rowVersion: w['row_version'] as int,
          leaseEpoch: 0,
        );
      }(),
  ];
}
