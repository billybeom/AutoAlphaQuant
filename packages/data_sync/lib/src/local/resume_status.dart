// 재개 상태 원천 — 홈 «X2 한 줄» · M3 미리보기 `recovery` · Supabase 미러 행
// (06 X2-6 · X2-7 · 앱 04 §4-2 · 01 `OpsDailySummary.resumeLine` · 설계 13 §8 R79 U1~U4).
//
// 🔴 홈 한 줄 = 엔진 완성 문장(화면이 D+n 을 세지 않는다) · 실행 기록 없음 = null(블록 부재).
// 🔴 `recovery` = `RESUME_INCOMPLETE` 활성 ∧ 가장 최근 회차가 복구 모드(관찰 · 안전 정지 회차는 끝나도 플래그가 남는다).
// 🔴 미러 = digest · 한 줄뿐(원문 0 · X2 원칙 ②) · 원격 epoch 이 더 높으면 빈 묶음(낮은 epoch 행은 만들지 않는다 · D16).
// 🆕 미결 244 ⓐ(설계 13 §8 R271 O2) — `resume_run_mirror.resume_mode`(NOT NULL · v1.22 K62) = 로컬 `resume_run.mode`(`ResumeMode`)
//    · 위 `mode` = 화면 상태의 `RunMode`(이름만 비슷한 두 축) — 빠지면 `op_push` 가 `OPS_PUSH_ROWS_INVALID` 로 통째 거부한다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AppRoutes, FlagIds, LinkAction, ResumeMode, RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'job_run_store.dart' show SqliteJobRunLog;

/// Supabase 미러 묶음(push = 🆕 `OpsMirrorPushJob` · `op_push` · R271).
class ResumeMirrorPayload {
  /// 묶음을 만든다.
  const ResumeMirrorPayload({
    required this.plannedWork,
    required this.resumeRuns,
  });

  /// `planned_work_mirror` 행.
  final List<Map<String, Object?>> plannedWork;

  /// `resume_run_mirror` 행.
  final List<Map<String, Object?>> resumeRuns;

  /// 빈 묶음.
  static const ResumeMirrorPayload empty = ResumeMirrorPayload(
    plannedWork: <Map<String, Object?>>[],
    resumeRuns: <Map<String, Object?>>[],
  );
}

/// 재개 상태 원천(R79).
class SqliteResumeStatus {
  /// 원천을 만든다 — [kr] = 갭을 세는 KR 달력.
  SqliteResumeStatus(this._db, {required this._kr});

  final Database _db;
  final ExchangeCalendar _kr;

  /// 홈 «X2 한 줄»(U1) — 실행 기록 없음 = null.
  LinkAction? resumeLine(TradeDate today) {
    final int? gap = resumeGapSessions(
      calendar: _kr,
      lastSuccessSession: SqliteJobRunLog(_db)
          .lastSuccessSession('equity_snapshot'),
      today: today,
    );
    final int pending =
        _db
                .select(
                  "SELECT COUNT(*) AS n FROM planned_work WHERE state IN ('PLANNED', 'BLOCKED')",
                )
                .first['n']!
            as int;
    final String? label = resumeLineText(
      gapSessions: gap,
      pendingWork: pending,
    );
    return label == null
        ? null
        : LinkAction(label: label, deepLink: AppRoutes.x2ResumeReport);
  }

  /// M3 미리보기 `recovery`(U2).
  bool recoveryActive() {
    final bool flag = _db.select(
      'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[FlagIds.resumeIncomplete],
    ).isNotEmpty;
    if (!flag) return false;
    final ResultSet rs = _db.select(
      'SELECT mode FROM resume_run ORDER BY started_at DESC, resume_run_id DESC LIMIT 1',
    );
    if (rs.isEmpty) return false;
    final Object? mode = rs.first['mode'];
    return mode == ResumeMode.recoveryDry.wire ||
        mode == ResumeMode.recoveryFull.wire;
  }

  /// 미러 묶음(U3) — [remoteEpoch] 가 [leaseEpoch] 보다 크면 빈 묶음.
  ResumeMirrorPayload mirrorPayload({
    required RunMode mode,
    required int leaseEpoch,
    required int? remoteEpoch,
  }) {
    if (remoteEpoch != null && remoteEpoch > leaseEpoch) {
      return ResumeMirrorPayload.empty;
    }
    return ResumeMirrorPayload(
      plannedWork: <Map<String, Object?>>[
        for (final Row w in _db.select(
          'SELECT work_id, digest, one_line, due_by, state, row_version FROM planned_work ORDER BY work_id',
        ))
          <String, Object?>{
            'work_id': w['work_id'],
            'mode': mode.wire,
            'digest': w['digest'],
            'one_line': w['one_line'],
            'due_by': w['due_by'],
            'state': w['state'],
            'row_version': w['row_version'],
            'lease_epoch': leaseEpoch,
          },
      ],
      resumeRuns: <Map<String, Object?>>[
        for (final Row r in _db.select(
          'SELECT resume_run_id, gap_trading_days, mode, phase, headline FROM resume_run ORDER BY resume_run_id',
        ))
          <String, Object?>{
            'resume_run_id': r['resume_run_id'],
            'gap_trading_days': r['gap_trading_days'],
            'mode': mode.wire,
            'resume_mode': r['mode'],
            'phase': r['phase'],
            'headline': r['headline'],
          },
      ],
    );
  }
}
