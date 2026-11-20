// 🆕 E11q-b2a — X2 재개 화면 원천(operator · 설계 13 §8 R186 · 01 §31 K64 · §34 K156).
//
// 🔴 셈 · 문장 = 엔진(`resumeReportVmOf` · `resumeGateVmOf`) · 여기는 원장 원문만 모은다: 가장 최근 끝난 회차(리포트 =
//    `SqliteResumeRepository.latest()` 그대로) · 가장 최근 회차(게이트 — 열린 회차 포함)와 그 항목(`resume_item` 차례) ·
//    `RESUME_INCOMPLETE` 활성.
// 🔴 다시 판정 0 · 손익 0 · 관측 시각 = 기기 시계.

import 'package:core_engine/core_engine.dart'
    show ResumeGateItem, ResumeGateRun, resumeGateVmOf, resumeReportVmOf;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, FlagIds, ResumeGateVm, ResumeMode, ResumeReportVm;
import 'package:sqlite3/sqlite3.dart';

import 'resume_read_model.dart' show SqliteResumeRepository;

/// X2 재개 화면 원천.
class SqliteResumeScreenSource {
  /// 원천을 만든다 — [canChoose] = 계절 선택을 낼 창구가 있나 · [hasBody] = 조립 앱 레지스트리에 본문이 있나 ·
  /// [lockedLabel] = 운영 등급 생체 축소(지금 조립 = null).
  SqliteResumeScreenSource(
    this._db, {
    required this._clock,
    required this._canChoose,
    required this._hasBody,
    this._lockedLabel,
  });

  final Database _db;
  final Clock _clock;
  final bool _canChoose;
  final bool Function(String route) _hasBody;
  final String? _lockedLabel;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    ...SqliteResumeRepository.watchedTables,
    'trading_block',
  };

  /// X2 리포트 한 화면.
  ResumeReportVm report() => resumeReportVmOf(
    report: SqliteResumeRepository(_db).latest(),
    nowUtc: _clock.nowUtc(),
  );

  /// X2 재개 게이트 한 화면.
  ResumeGateVm gate() => resumeGateVmOf(
    run: _lastRun(),
    incomplete: _db.select(
      'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
      <Object?>[FlagIds.resumeIncomplete],
    ).isNotEmpty,
    canChoose: _canChoose,
    hasBody: _hasBody,
    nowUtc: _clock.nowUtc(),
    lockedLabel: _lockedLabel,
  );

  ResumeGateRun? _lastRun() {
    final ResultSet rs = _db.select(
      'SELECT resume_run_id, finished_at, gap_trading_days, mode, headline FROM resume_run '
      'ORDER BY started_at DESC, resume_run_id DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    return ResumeGateRun(
      gapTradingDays: r['gap_trading_days'] as int,
      mode: ResumeMode.values.firstWhere((ResumeMode m) => m.wire == r['mode']),
      finished: r['finished_at'] != null,
      headline: r['headline'] as String?,
      items: <ResumeGateItem>[
        for (final Row i in _db.select(
          'SELECT work_id, one_line, reason_code, reevaluated_line, verdict_code FROM resume_item '
          'WHERE resume_run_id = ? ORDER BY seq',
          <Object?>[r['resume_run_id']],
        ))
          ResumeGateItem(
            workId: i['work_id'] as String,
            oneLine: i['one_line'] as String,
            reasonCode: i['reason_code'] as String,
            reasonLine: i['reevaluated_line'] as String,
            verdictCode: i['verdict_code'] as String,
          ),
      ],
    );
  }
}
