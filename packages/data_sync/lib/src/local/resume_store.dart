// 재개 회차 저장 · `RESUME_INCOMPLETE` 세우기 · 풀기(02 배치 C `resume_run` · 04 §3-1 v2.42 ② · 설계 13 §8 R75 N1~N3 · N8).
//
// 🔴 회차 1행 = 한 회차 · 끝 = `finished_at`(R70 D10) · `phase` = 마지막으로 끝난 단계(단계 커밋 → 크래시 뒤 다음 단계부터).
// 🔴 회차를 여는 트랜잭션에 `RESUME_INCOMPLETE` 를 세운다(전 주문 차단) · 풀기 = 자동(`auto:RESUME`).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart'
    show Clock, FlagIds, ResumeCounts, ResumeMode, ResumePhase, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// 자동 해제 표시(R75 N8 — 기존 자동 해제 `auto:SAF-40x` 와 같은 꼴).
const String kResumeClearedBy = 'auto:RESUME';

/// `resume_run` 1행.
class ResumeRunRow {
  /// 행을 만든다.
  const ResumeRunRow({
    required this.resumeRunId,
    required this.startedAtUtc,
    required this.finishedAtUtc,
    required this.gapTradingDays,
    required this.mode,
    required this.phase,
  });

  /// 회차 id.
  final String resumeRunId;

  /// 시작.
  final String startedAtUtc;

  /// 끝(null = 열린 회차).
  final String? finishedAtUtc;

  /// 갭(거래일).
  final int gapTradingDays;

  /// 재개 모드.
  final ResumeMode mode;

  /// 마지막으로 끝난 단계.
  final ResumePhase phase;
}

ResumeRunRow _row(Row r) => ResumeRunRow(
  resumeRunId: r['resume_run_id'] as String,
  startedAtUtc: r['started_at'] as String,
  finishedAtUtc: r['finished_at'] as String?,
  gapTradingDays: r['gap_trading_days'] as int,
  mode: ResumeMode.values.firstWhere((ResumeMode m) => m.wire == r['mode']),
  phase: ResumePhase.values.firstWhere((ResumePhase p) => p.wire == r['phase']),
);

/// 재개 회차 저장소(R75 N1).
class SqliteResumeStore {
  /// 저장소를 만든다.
  SqliteResumeStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  String _now() => _clock.nowUtc().toUtc().toIso8601String();

  /// 열린 회차(가장 늦게 연 것) — 없으면 null.
  ResumeRunRow? openRun() {
    final ResultSet rs = _db.select(
      'SELECT * FROM resume_run WHERE finished_at IS NULL '
      'ORDER BY started_at DESC, resume_run_id DESC LIMIT 1',
    );
    return rs.isEmpty ? null : _row(rs.first);
  }

  /// 회차 하나.
  ResumeRunRow? run(String resumeRunId) {
    final ResultSet rs = _db.select(
      'SELECT * FROM resume_run WHERE resume_run_id = ?',
      <Object?>[resumeRunId],
    );
    return rs.isEmpty ? null : _row(rs.first);
  }

  /// `RESUME_INCOMPLETE` 가 서 있나.
  bool flagActive() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.resumeIncomplete],
  ).isNotEmpty;

  /// 회차 열기(R75 N2) — `RR-{오늘}-{n}` · phase R0 · `RESUME_INCOMPLETE` 세움 · 한 트랜잭션.
  ResumeRunRow startRun({
    required TradeDate today,
    required int gapTradingDays,
    required ResumeMode mode,
  }) => inLedgerTransaction(_db, () {
    final String prefix = 'RR-${today.yyyyMmDd}-';
    final int n =
        (_db.select(
              'SELECT COUNT(*) AS n FROM resume_run WHERE substr(resume_run_id, 1, ?) = ?',
              <Object?>[prefix.length, prefix],
            ).first['n']!
            as int) +
        1;
    final String id = '$prefix$n';
    final String now = _now();
    _db.execute(
      'INSERT INTO resume_run (resume_run_id, started_at, finished_at, gap_trading_days, mode, phase, counts, headline) '
      'VALUES (?, ?, NULL, ?, ?, ?, ?, NULL)',
      <Object?>[
        id,
        now,
        gapTradingDays,
        mode.wire,
        ResumePhase.r0.wire,
        jsonEncode(
          const ResumeCounts(
            executed: 0,
            expired: 0,
            superseded: 0,
            blocked: 0,
            unrecoverable: 0,
          ).toJson(),
        ),
      ],
    );
    _db.execute(
      'INSERT INTO trading_block (flag_id, set_at, reason, origin_code, cleared_at, cleared_by, decision_id) '
      'VALUES (?, ?, ?, NULL, NULL, NULL, NULL) '
      'ON CONFLICT (flag_id) DO UPDATE SET set_at = excluded.set_at, reason = excluded.reason, '
      'origin_code = NULL, cleared_at = NULL, cleared_by = NULL, decision_id = NULL',
      <Object?>[FlagIds.resumeIncomplete, now, '재개 회차 $id'],
    );
    return run(id)!;
  });

  /// 단계 커밋(R75 N3) — 그 단계가 끝났다.
  void commitPhase(String resumeRunId, ResumePhase phase) => _db.execute(
    'UPDATE resume_run SET phase = ? WHERE resume_run_id = ? AND finished_at IS NULL',
    <Object?>[phase.wire, resumeRunId],
  );

  /// `RESUME_INCOMPLETE` 풀기(R75 N8) — 서 있을 때만 · 풀었으면 true.
  bool clearFlag() {
    _db.execute(
      'UPDATE trading_block SET cleared_at = ?, cleared_by = ? WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[_now(), kResumeClearedBy, FlagIds.resumeIncomplete],
    );
    return _db.updatedRows > 0;
  }

  /// 이 회차가 옮긴 항목의 verdict(전이 행 · R8 집계 원천 — 크래시 뒤에도 같은 값).
  List<String> roundVerdicts(String resumeRunId) => <String>[
    for (final Row r in _db.select(
      'SELECT verdict_code FROM planned_work_transition WHERE resume_run_id = ? AND verdict_code IS NOT NULL '
      'ORDER BY transition_id',
      <Object?>[resumeRunId],
    ))
      r['verdict_code'] as String,
  ];

  /// 회차 끝(R75 N9) — 집계 · 머리말 · phase R8 · `finished_at`.
  void finishRun(
    String resumeRunId, {
    required ResumeCounts counts,
    required String headline,
  }) => _db.execute(
    'UPDATE resume_run SET finished_at = ?, phase = ?, counts = ?, headline = ? '
    'WHERE resume_run_id = ? AND finished_at IS NULL',
    <Object?>[
      _now(),
      ResumePhase.r8.wire,
      jsonEncode(counts.toJson()),
      headline,
      resumeRunId,
    ],
  );
}
