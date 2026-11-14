// E11p3a 잡 실행기 표 시험(설계 e11p-map Q6 · Q7) — 실 SQLite `job_run` · 핑 기록기.

import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show JobRunEntry, JobRunStatus, PingStatus;
import 'package:data_sync/data_sync.dart' show SqliteAlertSink, SqliteJobRunLog;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, RunMode, TradeDate;
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobBody,
        JobCalendars,
        JobOccurrence,
        JobRun,
        JobStatus,
        jobSpecOf,
        kJobTable,
        occurrenceOn;

import 'support.dart';

void main() {
  tearDownAll(deleteTempDirs);
  final JobCalendars cals = calendars();

  late FakeClock clock;
  late LedgerFiles files;
  late RecordingHeartbeat hb;
  late SqliteJobRunLog log;
  late JobContext ctx;

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 8, 30));
    files = openFiles(tempLedgerDir(), clock);
    hb = RecordingHeartbeat();
    log = SqliteJobRunLog(files.sim);
    ctx = JobContext(
      db: files.sim,
      runMode: RunMode.simInternal,
      operatingMode: OperatingMode.autoTrade,
      calendars: cals,
      heartbeat: hb,
      alerts: SqliteAlertSink(files.sim, clock: clock),
      runLog: log,
      clock: clock,
    );
  });
  tearDown(() => files.close());

  JobOccurrence occ(String job, String fireDay) =>
      occurrenceOn(jobSpecOf(job), TradeDate(fireDay), cals);

  test('🔴 표 = 잡 표 전부(빠짐 · 남는 칸 0) · 빠진 부품 목록도 같은 잡', () {
    final Set<String> jobs = kJobTable.map((s) => s.job).toSet();
    expect(composeJobRunners(ctx).keys.toSet(), jobs);
    expect(kMissingParts.keys.toSet(), jobs);
    for (final List<String> parts in kMissingParts.values) {
      expect(parts, isNotEmpty);
    }
  });

  test('🔴 미조립 칸 = FAILED 기록 + start · fail 핑(조용히 건너뛰지 않는다)', () async {
    final JobRun<Object?> r = await composeJobRunners(ctx)['daily_reconcile']!(
      occ('daily_reconcile', '2026-12-01'),
    );
    expect(r.status, JobStatus.failed);
    expect(r.error, isA<JobNotAssembled>());
    expect('${r.error}', startsWith('UNASSEMBLED daily_reconcile: '));
    expect(hb.pings.map((p) => p.status), <PingStatus>[
      PingStatus.start,
      PingStatus.fail,
    ]);
    expect(hb.pings.map((p) => p.check).toSet(), <String>{
      'sim-auto-daily_reconcile',
    });
    final List<JobRunEntry> rows = log.entriesOf('daily_reconcile');
    expect(rows.single.status, JobRunStatus.failed);
    expect(rows.single.sessionDay, const TradeDate('2026-12-01'));
  });

  test('🔴 세션일 = 회차 값 — us_data 는 앞 날 · 월말 잡은 월말(KST 날이 아니다)', () async {
    final Map<String, JobRunner> t = composeJobRunners(ctx);
    await t['us_data']!(occ('us_data', '2026-12-01'));
    await t['monthly_rebalance']!(occ('monthly_rebalance', '2026-12-01'));
    expect(
      log.entriesOf('us_data').single.sessionDay,
      const TradeDate('2026-11-30'),
    );
    expect(
      log.entriesOf('monthly_rebalance').single.sessionDay,
      const TradeDate('2026-11-30'),
    );
  });

  test('휴장 회차 = 본체를 부르지 않고 HOLIDAY · 성공 핑(미조립이어도)', () async {
    // 2026-12-25(금) = KR 휴장 · krWeekday 잡은 휴장 회차를 낸다.
    final JobOccurrence o = occ('daily_reconcile', '2026-12-25');
    expect(o.holiday, true);
    clock.now = kst(2026, 12, 25, 7, 5);
    final JobRun<Object?> r = await composeJobRunners(ctx)['daily_reconcile']!(
      o,
    );
    expect(r.status, JobStatus.holiday);
    expect(hb.pings.last.status, PingStatus.success);
    expect(
      log.entriesOf('daily_reconcile').single.status,
      JobRunStatus.holiday,
    );
  });

  test('체크 이름 = 모드 2축(live · 안내 모드)', () async {
    final JobContext live = JobContext(
      db: files.sim,
      runMode: RunMode.live,
      operatingMode: OperatingMode.advisory,
      calendars: cals,
      heartbeat: hb,
      alerts: ctx.alerts,
      runLog: log,
      clock: clock,
    );
    await composeJobRunners(live)['daily_signal']!(
      occ('daily_signal', '2026-11-30'),
    );
    expect(hb.pings.first.check, 'live-advisory-daily_signal');
  });

  test('🔴 마감 = 회차 유예 끝 — 안이면 SUCCESS · 지나면 LATE', () async {
    final JobOccurrence o = occ('daily_reconcile', '2026-12-01');
    Future<JobRunStatus> runAt(DateTime t) async {
      clock.now = t;
      await runOccurrence<int>(
        ctx,
        o,
        (TradeDate _) async => const JobBody<int>(1),
      );
      return log.entriesOf('daily_reconcile').last.status;
    }

    expect(
      await runAt(o.deadlineUtc.subtract(const Duration(minutes: 1))),
      JobRunStatus.success,
    );
    expect(
      await runAt(o.deadlineUtc.add(const Duration(minutes: 1))),
      JobRunStatus.late,
    );
  });

  test('🔴 달력 = 회차의 시장 — us_data 는 US 휴장(추수감사절)을 HOLIDAY 로', () async {
    // 2026-11-26(목) = XNYS 휴장 · XKRX 세션 → us_data 11-27 발화 회차의 세션 = 11-26.
    final JobOccurrence o = occ('us_data', '2026-11-27');
    expect(o.sessionDay, const TradeDate('2026-11-26'));
    clock.now = kst(2026, 11, 27, 7, 35);
    final JobRun<Object?> r = await composeJobRunners(ctx)['us_data']!(o);
    expect(r.status, JobStatus.holiday);
  });
}
