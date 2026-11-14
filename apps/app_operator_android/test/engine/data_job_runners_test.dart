// E11p3c-1 데이터 잡 실물(설계 13 §8 R97) — 실 SQLite(시드 적재) · 일봉 원천 · FRED · OFR = 가짜(네트워크 0).

import 'dart:io';

import 'package:app_operator_android/engine/data_job_runners.dart';
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/kis_sessions.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        DailyQuoteFeed,
        JobRunStatus,
        Market,
        PingStatus,
        PriceAdjust,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind,
        p0sRegimeConfigHash;
import 'package:data_sync/data_sync.dart'
    show
        DailySignalReport,
        FredClient,
        OfrClient,
        SeedFile,
        SqliteAlertSink,
        SqliteJobRunLog,
        UsDataReport,
        importSeedBundle,
        kSeedFiles;
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, MarketDataSource, OperatingMode, RunMode, TradeDate;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobCalendars,
        JobOccurrence,
        JobRun,
        JobStatus,
        jobSpecOf,
        occurrenceOn;

import 'support.dart';

/// 늘 «받지 못함» — 수집 실패는 회차를 실패시키지 않는다(본체 규칙).
class _DownFeed implements DailyQuoteFeed {
  int calls = 0;

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async {
    calls++;
    throw const QuoteFeedDown('시험', attempts: 1);
  }
}

void main() {
  tearDownAll(deleteTempDirs);
  final JobCalendars cals = calendars();
  final http.Client down = MockClient(
    (http.Request r) async => http.Response('', 503),
  );

  late FakeClock clock;
  late LedgerFiles files;
  late RecordingHeartbeat hb;
  late SqliteJobRunLog log;
  late JobContext ctx;
  late _DownFeed feed;
  late List<RunMode> asked;

  JobParts parts({Future<DailyQuoteFeed> Function(RunMode)? quoteFeed}) =>
      JobParts(
        quoteFeed:
            quoteFeed ??
            (RunMode m) async {
              asked.add(m);
              return feed;
            },
        fred: FredClient(down, sleep: (Duration _) async {}),
        ofr: OfrClient(down, sleep: (Duration _) async {}),
        regimeConfigHash: p0sRegimeConfigHash(),
      );

  setUp(() {
    clock = FakeClock(kst(2026, 12, 1, 8, 30));
    files = openFiles(tempLedgerDir(), clock);
    importSeedBundle(files.sim, <String, List<int>>{
      for (final SeedFile f in kSeedFiles)
        f.fileName: File('../../packages/data_sync/assets/seed/${f.fileName}')
            .readAsBytesSync(),
    }, importedAt: '2026-12-01T00:00:00.000Z');
    hb = RecordingHeartbeat();
    log = SqliteJobRunLog(files.sim);
    feed = _DownFeed();
    asked = <RunMode>[];
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

  int regimeRows() =>
      files.sim
              .select('SELECT COUNT(*) AS n FROM regime_score_daily')
              .first['n']
          as int;

  test('🔴 부품이 있으면 실물 칸에 daily_signal · us_data · 주문 셋은 미조립 그대로', () async {
    final Map<String, JobRunner> t = composeJobRunners(ctx, parts: parts());
    expect(
      kAssembledRunners.keys.toSet(),
      containsAll(<String>{'daily_signal', 'us_data'}),
    );
    final JobRun<Object?> r = await t['daily_reconcile']!(
      occ('daily_reconcile', '2026-12-01'),
    );
    expect(r.error, isA<JobNotAssembled>());
  });

  test('부품이 없으면 = p3a 그대로(전부 미조립)', () async {
    clock.now = kst(2026, 11, 30, 20, 5);
    final JobRun<Object?> r = await composeJobRunners(ctx)['daily_signal']!(
      occ('daily_signal', '2026-11-30'),
    );
    expect(r.error, isA<JobNotAssembled>());
  });

  test(
    '🔴 daily_signal = 시드 위에 국면 행을 쌓는다 · 성공 핑 · job_run SUCCEEDED',
    () async {
      clock.now = kst(2026, 11, 30, 20, 5);
      expect(regimeRows(), 0);
      final JobRun<Object?> r = await composeJobRunners(
        ctx,
        parts: parts(),
      )['daily_signal']!(occ('daily_signal', '2026-11-30'));
      expect(r.status, JobStatus.success, reason: '${r.error}');
      expect(r.report, isA<DailySignalReport>());
      expect((r.report! as DailySignalReport).written, greaterThan(0));
      expect(regimeRows(), greaterThan(0));
      expect(
        files.sim
            .select('SELECT DISTINCT config_hash AS h FROM regime_score_daily')
            .map((r) => r['h']),
        <Object?>[p0sRegimeConfigHash()],
      );
      expect(hb.pings.map((Ping p) => p.status), <PingStatus>[
        PingStatus.start,
        PingStatus.success,
      ]);
      expect(hb.pings.first.check, 'sim-auto-daily_signal');
      expect(log.entriesOf('daily_signal').single.status, JobRunStatus.success);
      expect(asked, isEmpty); // 네트워크 원천을 만들지 않는다.
    },
  );

  test('🔴 us_data = 모드의 원천을 묻는다 · 수집 실패는 회차 성공 + DATA_SOURCE_DOWN', () async {
    final JobRun<Object?> r = await composeJobRunners(
      ctx,
      parts: parts(),
    )['us_data']!(occ('us_data', '2026-12-01'));
    expect(r.status, JobStatus.success, reason: '${r.error}');
    expect(asked, <RunMode>[RunMode.simInternal]);
    expect(feed.calls, greaterThan(0));
    final UsDataReport rep = r.report! as UsDataReport;
    expect(rep.quotes.every((q) => q.failed), true);
    expect(r.alerts, contains(AlertCodes.dataSourceDown));
    expect(
      log.entriesOf('us_data').single.sessionDay,
      const TradeDate('2026-11-30'),
    );
  });

  test('🔴 원천을 못 만들면(KIS 키 없음) = 회차 실패 · fail 핑 · 사유 그대로', () async {
    final JobRun<Object?> r = await composeJobRunners(
      ctx,
      parts: parts(
        quoteFeed: (RunMode m) async => throw const KisSessionUnavailable(
          'KIS_PAPER: 칸 없음 kis.paper.app_key',
        ),
      ),
    )['us_data']!(occ('us_data', '2026-12-01'));
    expect(r.status, JobStatus.failed);
    expect(r.error, isA<KisSessionUnavailable>());
    expect(hb.pings.last.status, PingStatus.fail);
    expect(log.entriesOf('us_data').single.status, JobRunStatus.failed);
  });
}
