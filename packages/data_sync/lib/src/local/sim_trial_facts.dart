// 모의 체험 판정 입력 — 모의 파일의 원 기록 읽기(설계 13 §8 R87 AB1 · AB2 · core `judgeSimTrial`).
//
// 🔴 모의 파일만(live 파일 = [StateError] — `SqliteModeStore` 의 식별 검사).
// 🔴 읽기만 · 거르기 · 판정은 core 하나(시작점 비교 = 시각을 파싱해서 — ISO 글자 비교는 소수 자리가 다르면 틀린다).
// 🔴 시각에 시차가 없으면 [FormatException](모르는 시각을 한국 날로 바꾸지 않는다).

import 'package:core_engine/core_engine.dart'
    show
        JobRunEntry,
        SimTrialFacts,
        SimTrialFactsSource,
        SimTrialKillEvent,
        SimTrialRebalance,
        SimTrialRecon,
        SimTrialResumeRun,
        kSimTrialBatchJob;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, LedgerFile, RunMode;
import 'package:sqlite3/sqlite3.dart';

import 'job_run_store.dart' show SqliteJobRunLog;
import 'mode_store.dart' show SqliteModeStore;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _at(Object? v, String table) {
  if (v is! String || !_offset.hasMatch(v)) {
    throw FormatException('$table 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}

/// 모의 체험 판정 입력(R87 AB1).
class SqliteSimTrialFacts implements SimTrialFactsSource {
  /// 입력을 만든다 — 🔴 [db] 가 모의 파일이 아니면 [StateError].
  SqliteSimTrialFacts(this._db, {required Clock clock})
    : _clock = clock,
      _mode = SqliteModeStore(_db, LedgerFile.sim, clock: clock);

  final Database _db;
  final Clock _clock;
  final SqliteModeStore _mode;

  /// 체험 시작점 — 첫 RUN_MODE 커밋(O-04 ⑥) · 없으면 null.
  DateTime? anchorUtc() {
    final ResultSet rs = _db.select(
      "SELECT committed_at FROM mode_transition WHERE axis = 'RUN_MODE' "
      'ORDER BY transition_id LIMIT 1',
    );
    return rs.isEmpty ? null : _at(rs.first['committed_at'], 'mode_transition');
  }

  /// 지금 읽은 입력(동기).
  SimTrialFacts read() {
    final DateTime? anchor = anchorUtc();
    final RunMode? mode = _mode.current()?.runMode;
    return SimTrialFacts(
      asOfUtc: _clock.nowUtc().toUtc(),
      anchorUtc: anchor,
      runMode: mode,
      batchOkDays: <String>{
        for (final JobRunEntry e in SqliteJobRunLog(
          _db,
        ).entriesOf(kSimTrialBatchJob))
          if (e.status.succeeded) e.sessionDay.yyyyMmDd,
      },
      rebalances: <SimTrialRebalance>[
        for (final Row r in _db.select(
          'SELECT kind, created_at FROM rebalance_event',
        ))
          SimTrialRebalance(
            r['kind'] as String,
            _at(r['created_at'], 'rebalance_event'),
          ),
      ],
      recons: <SimTrialRecon>[
        for (final Row r in _db.select(
          'SELECT run_at, matched FROM reconciliation_log '
          "WHERE recon_id GLOB 'rc-*' AND recon_id NOT GLOB 'rc-clear-*'",
        ))
          SimTrialRecon(
            _at(r['run_at'], 'reconciliation_log'),
            matched: r['matched'] == 1,
          ),
      ],
      openLedgerDiffs:
          _db
                  .select(
                    "SELECT COUNT(*) AS n FROM ledger_diff WHERE status = 'OPEN'",
                  )
                  .first['n']!
              as int,
      resumeRuns: <SimTrialResumeRun>[
        for (final Row r in _db.select(
          'SELECT started_at, finished_at, gap_trading_days FROM resume_run',
        ))
          SimTrialResumeRun(
            _at(r['started_at'], 'resume_run'),
            finished: r['finished_at'] != null,
            gapTradingDays: r['gap_trading_days'] as int,
          ),
      ],
      killEvents: <SimTrialKillEvent>[
        for (final Row r in _db.select(
          'SELECT kind, occurred_at FROM kill_switch_event',
        ))
          SimTrialKillEvent(
            r['kind'] as String,
            _at(r['occurred_at'], 'kill_switch_event'),
          ),
      ],
      alertRaisedUtc: <DateTime>[
        for (final Row r in _db.select('SELECT raised_at FROM alert_event'))
          _at(r['raised_at'], 'alert_event'),
      ],
      interventionStartedUtc: <DateTime>[
        for (final Row r in _db.select(
          'SELECT occurred_at FROM intervention_step WHERE stage = 1',
        ))
          _at(r['occurred_at'], 'intervention_step'),
      ],
    );
  }

  @override
  Future<SimTrialFacts> facts() async => read();
}
