// 잡 실행기 표(E11p3a · 설계 e11p-map Q6 · Q7 · 정본 = 01 §10 잡 규약 · R42 · R73).
//
// 🔴 `kJobTable` 의 잡마다 한 칸 — 빠지면 시험이 실패한다(표 대조). 이름 → 본체를 잇는 곳은 앱뿐이다
//    (trading_runtime ↛ data_sync).
// 🔴 감싸기 = `runJob` — 체크 이름 = `watchdogCheckName` · 달력 = 회차의 시장 · **세션일 · 마감 = 회차 값 고정**
//    (`runJob` 기본 `sessionDayOf` = KST 날 → us_data(앞 날) · monthly_rebalance(월말)가 어긋나는 함정 · R73).
// 🔴 미조립 칸(설계 Q7) = 돌리되 본체가 곧바로 실패 → `job_run` FAILED + fail 핑. 조용히 건너뛰면 갭 · 재개가
//    «놓침»으로 오판한다. 기동 판정이 «준비»일 때만 돌므로 온보딩 전 기기에서는 0건이다.
// 🔵 p3a 는 아홉 칸 전부 미조립 — 빈 부품(운영 설정 · 시세 · 한도 · 브로커)은 p3b · 실물 조립은 p3c.
// 🆕 E11p3c-1(설계 13 §8 R97) — 부품([JobParts])을 받으면 실물 칸(`kAssembledRunners`)을 쓴다: `daily_signal` · `us_data`.
//    부품이 없으면(시험 · p3a) 전부 미조립 그대로.

import 'package:core_engine/core_engine.dart'
    show AlertSink, JobHeartbeat, JobRunLog;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, OperatingMode, RunMode, TradeDate;
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobBody,
        JobCalendars,
        JobOccurrence,
        JobRun,
        JobSpec,
        kJobTable,
        runJob,
        watchdogCheckName;

import 'data_job_runners.dart' show JobParts, kAssembledRunners;

/// 회차 하나를 돌린다.
typedef JobRunner = Future<JobRun<Object?>> Function(JobOccurrence occurrence);

/// 실행기 표를 만든다(p3c 가 실물로 바꾼다 · 시험이 가짜를 넣는다).
typedef JobRunnerFactory = Map<String, JobRunner> Function(JobContext context);

/// 회차를 돌리는 데 쓰는 공통 부품(모드 파일 하나).
class JobContext {
  /// 만든다.
  const JobContext({
    required this.db,
    required this.runMode,
    required this.operatingMode,
    required this.calendars,
    required this.heartbeat,
    required this.alerts,
    required this.runLog,
    required this.clock,
  });

  /// 🆕 E11p3c-1 — 이 모드의 원장(기동 판정이 고른 파일).
  final Database db;

  /// 실행 모드.
  final RunMode runMode;

  /// 운영 방식.
  final OperatingMode operatingMode;

  /// 시장 달력.
  final JobCalendars calendars;

  /// 핑.
  final JobHeartbeat heartbeat;

  /// 알림 저장.
  final AlertSink alerts;

  /// `job_run` 기록.
  final JobRunLog runLog;

  /// 기기 시계.
  final Clock clock;
}

/// 🔴 회차를 잡 규약으로 감싼다 — 세션일 · 달력 · 마감 = 회차 값.
Future<JobRun<T>> runOccurrence<T>(
  JobContext c,
  JobOccurrence o,
  Future<JobBody<T>> Function(TradeDate sessionDay) body,
) => runJob<T>(
  check: watchdogCheckName(c.runMode, c.operatingMode, o.spec.job),
  heartbeat: c.heartbeat,
  alerts: c.alerts,
  calendar: c.calendars.of(o.spec),
  nowUtc: c.clock.nowUtc(),
  body: body,
  runLog: c.runLog,
  clockUtc: c.clock.nowUtc,
  deadlineUtc: o.deadlineUtc,
  sessionDayOf: (DateTime _) => o.sessionDay,
);

/// 미조립 — 본체가 곧바로 던진다(설계 Q7).
class JobNotAssembled implements Exception {
  /// 만든다.
  const JobNotAssembled(this.job, this.missing);

  /// 잡.
  final String job;

  /// 빠진 부품(부품 이름 — 문장이 아니다).
  final List<String> missing;

  @override
  String toString() => 'UNASSEMBLED $job: ${missing.join(', ')}';
}

/// 미조립 실행기.
JobRunner unassembledRunner(JobContext c, String job, List<String> missing) =>
    (JobOccurrence o) => runOccurrence<Object?>(
      c,
      o,
      (TradeDate _) async => throw JobNotAssembled(job, missing),
    );

/// 잡마다 빠진 부품(p3b · p3c 가 채우면 칸이 실물로 바뀐다 · 06 M1-28 · e11p-map §3 조사).
const Map<String, List<String>> kMissingParts = <String, List<String>>{
  'daily_reconcile': <String>['broker', 'order_ledger_wiring'],
  'kr_order': <String>[
    'ops_config',
    'draft_quotes',
    'limit_state',
    'broker',
    'resume_guard',
  ],
  'kr_order_close': <String>['ops_config', 'broker'],
  'daily_data': <String>['quote_feed', 'seed_bundle'],
  'daily_signal': <String>['regime_config_hash'],
  'equity_snapshot': <String>['broker_cash'],
  'seasonal_a': <String>['ops_config', 'broker_cash'],
  'monthly_rebalance': <String>['ops_config', 'broker_cash'],
  'us_data': <String>['quote_feed', 'macro_keys'],
};

/// 🔴 실행기 표 — `kJobTable` 의 잡마다 한 칸. [parts] 가 있으면 실물 칸(`kAssembledRunners`) · 나머지 = 미조립.
Map<String, JobRunner> composeJobRunners(
  JobContext c, {
  List<JobSpec> specs = kJobTable,
  JobParts? parts,
}) => <String, JobRunner>{
  for (final JobSpec s in specs) s.job: _runnerOf(c, s.job, parts),
};

JobRunner _runnerOf(JobContext c, String job, JobParts? parts) {
  final JobRunner Function(JobContext, JobParts)? make = kAssembledRunners[job];
  if (parts != null && make != null) return make(c, parts);
  return unassembledRunner(
    c,
    job,
    kMissingParts[job] ?? const <String>['unknown_job'],
  );
}
