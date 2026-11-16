// E11p3d-2b — H-01 오늘 요약 · H-02 운영 리듬의 사실 모음(설계 13 §8 R133).
//
// 🔴 셈은 이미 있는 엔진 원천을 그대로 쓴다 — 주문 = SAF-401 `orders_today` 셈 · 재량 = `SqliteDiscretionStore.budget()` ·
//    X2 한 줄 = `SqliteResumeStatus` · 오류 = 오늘 세션의 실패한 잡 회차(이 모드 접두 · FAILED 만 · LATE 는 오류 아님).
// 🔵 «오늘» = 기기 시계의 한국 날(다른 화면과 같다) · 마지막 엔진 활동 = 이 모드 접두의 마지막 잡 기록 끝 시각.

import 'package:core_engine/core_engine.dart'
    show
        DiscretionBudget,
        ExchangeCalendar,
        JobRunStatus,
        OpsHomeFacts,
        TrustedClock,
        kstDateText,
        opsDailySummaryOf,
        opsRhythmOf,
        watchdogCheckPrefix;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        ListResult,
        OperatingMode,
        OpsDailySummary,
        OpsRhythmRow,
        RunMode,
        TradeDate;
import 'package:sqlite3/sqlite3.dart';

import 'discretion_store.dart' show SqliteDiscretionStore;
import 'order_ledger.dart' show SqliteOrderLedger;
import 'resume_status.dart' show SqliteResumeStatus;

/// 홈 · 리듬 원천(원장 파일 하나 · 한 모드).
class SqliteOpsHomeSource {
  /// 만든다 — [runMode] = 이 파일의 실행 모드 · [operatingMode] = 문장 갈래 · 잡 접두.
  SqliteOpsHomeSource(
    this._db, {
    required this._clock,
    required this._trusted,
    required this._kr,
    required RunMode runMode,
    required OperatingMode operatingMode,
  }) : _run = runMode,
       _op = operatingMode;

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final ExchangeCalendar _kr;
  final RunMode _run;
  final OperatingMode _op;

  /// 다시 읽을 표(주문 · 잡 · 재량 · 재개 대기 작업).
  static const Set<String> watchedTables = <String>{
    'order_intents',
    'job_run',
    'discretion_adjustment',
    'planned_work',
  };

  String get _prefix => '${watchdogCheckPrefix(_run, _op)}-';

  /// 오늘 세션의 실패한 잡 회차 수.
  int failedJobsOn(TradeDate day) =>
      _db.select(
            'SELECT COUNT(*) AS n FROM job_run WHERE session_day = ? AND status = ? '
            'AND substr(check_name, 1, ?) = ?',
            <Object?>[
              day.yyyyMmDd,
              JobRunStatus.failed.wire,
              _prefix.length,
              _prefix,
            ],
          ).single['n']
          as int;

  /// 마지막 엔진 활동(이 모드의 마지막 잡 기록 끝 시각 · 없음 = null).
  DateTime? lastActivityUtc() {
    final Object? v = _db.select(
      'SELECT MAX(finished_at) AS t FROM job_run WHERE substr(check_name, 1, ?) = ?',
      <Object?>[_prefix.length, _prefix],
    ).single['t'];
    return v == null ? null : DateTime.parse(v as String).toUtc();
  }

  /// 오늘의 사실.
  OpsHomeFacts facts() {
    final TradeDate today = TradeDate(kstDateText(_clock.nowUtc()));
    final DiscretionBudget? budget = SqliteDiscretionStore(
      _db,
      clock: _clock,
      trusted: _trusted,
    ).budget();
    return OpsHomeFacts(
      operatingMode: _op,
      ordersToday: SqliteOrderLedger(
        _db,
        mode: _run,
        clock: _clock,
        kr: _kr,
      ).ordersOn(today),
      failedJobsToday: failedJobsOn(today),
      discretion: budget,
      lastActivityUtc: lastActivityUtc(),
      resumeLine: SqliteResumeStatus(_db, kr: _kr).resumeLine(today),
    );
  }

  /// `H-01` 오늘 요약.
  OpsDailySummary today() =>
      opsDailySummaryOf(facts(), kr: _kr, nowUtc: _clock.nowUtc());

  /// `H-02` 운영 리듬 표.
  ListResult<OpsRhythmRow> rhythm() => opsRhythmOf(
    kr: _kr,
    nowUtc: _clock.nowUtc(),
    lastActivityUtc: lastActivityUtc(),
  );
}
