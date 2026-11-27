// E11p3c-2 사람 값이 드는 잡 실물(설계 13 §8 R99) — 실 SQLite(시드 · 설정 등재 · 모의 개시) · 일봉 원천 = 가짜(네트워크 0).

import 'dart:io';

import 'package:app_operator_android/engine/data_job_runners.dart';
import 'package:app_operator_android/engine/fgs_status_source.dart'
    show UnknownTrustedClock;
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/ledger_job_runners.dart'
    show refreshSelfAuditOf;
import 'package:core_engine/core_engine.dart'
    show
        DailyQuoteFeed,
        JobRunStatus,
        Market,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        PriceAdjust,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind,
        TrustedClock,
        p0sRegimeConfigHash;
import 'package:data_sync/data_sync.dart'
    show
        DailyDataReport,
        EquitySnapshotReport,
        MonthlyRebalanceError,
        FredClient,
        OfrClient,
        OpsConfigCodes,
        OpsConfigUnavailable,
        SeasonalAReport,
        SeedFile,
        SqliteAlertSink,
        SqliteConfigVersionStore,
        SqliteJobRunLog,
        SqliteOnboardingStore,
        importSeedBundle,
        kSeedFiles;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        ExecPolicy,
        AlertCodes,
        CommandContext,
        FlagIds,
        MarketDataSource,
        OperatingMode,
        RunMode,
        SelfReportBalance,
        SelfReportLine,
        SelfReportPurpose,
        TradeDate;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Row;
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobCalendars,
        JobOccurrence,
        JobRun,
        JobStatus,
        jobSpecOf,
        kJobTable,
        occurrenceOn;

import 'support.dart';

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

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  final DateTime at;
  @override
  DateTime? trustedNowUtc() => at;
}

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

void main() {
  tearDownAll(deleteTempDirs);
  final JobCalendars cals = calendars();
  final http.Client down = MockClient(
    (http.Request r) async => http.Response('', 503),
  );
  final P0sOpsConfig cfg = P0sOpsConfig.of(
    P0sHumanInputs(aSymbol: '999990', accountByStrategy: _accounts),
  );

  late FakeClock clock;
  late LedgerFiles files;
  late RecordingHeartbeat hb;
  late SqliteJobRunLog log;
  late _DownFeed feed;
  late int feedsMade;

  JobParts parts({bool feedFails = false}) => JobParts(
    quoteFeed: (RunMode m) async {
      feedsMade++;
      if (feedFails) throw StateError('KIS 키 없음(시험)');
      return feed;
    },
    priceFetch: (RunMode m) async =>
        (String code) async => throw StateError('현재가 없음(시험)'),
    fred: FredClient(down, sleep: (Duration _) async {}),
    ofr: OfrClient(down, sleep: (Duration _) async {}),
    regimeConfigHash: p0sRegimeConfigHash(),
  );

  JobContext ctx({RunMode mode = RunMode.simInternal}) => JobContext(
    db: files.sim,
    runMode: mode,
    operatingMode: OperatingMode.autoTrade,
    execPolicy: ExecPolicy.execute,
    calendars: cals,
    heartbeat: hb,
    alerts: SqliteAlertSink(files.sim, clock: clock),
    runLog: log,
    clock: clock,
  );

  /// 설정 등재 + 모의 개시(가상 초기금 1,000만 원 · 계좌 둘).
  void openSim({Map<String, Object?>? content}) {
    final String hash = SqliteConfigVersionStore(
      files.sim,
      clock: clock,
    ).register(content ?? cfg.content());
    final SqliteOnboardingStore s = SqliteOnboardingStore(
      files.sim,
      clock: clock,
    );
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
    expect(
      s
          .declareSimOpening(
            SelfReportBalance(
              asOfTradeDate: const TradeDate('2026-12-21'),
              purpose: SelfReportPurpose.simOpening,
              sessionStartedAt: clock.now,
              lines: const <SelfReportLine>[],
              cashKrw: Decimal.parse('10000000'),
              accountAlias: 'general',
              declaredComplete: true,
              context: const CommandContext(
                runMode: RunMode.simInternal,
                operatingMode: OperatingMode.autoTrade,
                leaseEpoch: 0,
                deviceId: 'dev-1',
              ),
            ),
            accountByStrategy: _accounts,
            configHash: hash,
          )
          .ok,
      true,
    );
  }

  setUp(() {
    clock = FakeClock(kst(2026, 12, 21, 10, 0));
    files = openFiles(tempLedgerDir(), clock);
    importSeedBundle(files.sim, <String, List<int>>{
      for (final SeedFile f in kSeedFiles)
        f.fileName: File('../../packages/data_sync/assets/seed/${f.fileName}')
            .readAsBytesSync(),
    }, importedAt: '2026-12-21T00:00:00.000Z');
    hb = RecordingHeartbeat();
    log = SqliteJobRunLog(files.sim);
    feed = _DownFeed();
    feedsMade = 0;
  });
  tearDown(() => files.close());

  JobOccurrence occ(String job, String fireDay) =>
      occurrenceOn(jobSpecOf(job), TradeDate(fireDay), cals);

  Future<JobRun<Object?>> run(
    String job,
    String fireDay, {
    JobContext? c,
    JobParts? p,
  }) => composeJobRunners(c ?? ctx(), parts: p ?? parts())[job]!(
    occ(job, fireDay),
  );

  test('🔴 실물 칸 = 잡 표 전부(아홉) — 미조립 칸 0(부품이 있을 때)', () {
    expect(kAssembledRunners.keys.toSet(), kJobTable.map((s) => s.job).toSet());
  });

  test(
    '🔴 모의 개시 전 = 지금 설정 없음 → 회차 실패(OPS_CONFIG_NO_OPENING · 지어내지 않는다)',
    () async {
      clock.now = kst(2026, 12, 21, 20, 35);
      final JobRun<Object?> r = await run('equity_snapshot', '2026-12-21');
      expect(r.status, JobStatus.failed);
      expect((r.error! as OpsConfigUnavailable).code, OpsConfigCodes.noOpening);
      expect(
        log.entriesOf('equity_snapshot').single.status,
        JobRunStatus.failed,
      );
      expect(feedsMade, 0);
    },
  );

  test('🔴 설정 판이 바뀌면(DRIFT) 회차 실패', () async {
    openSim(content: cfg.content()..['spec'] = 'v2.43');
    clock.now = kst(2026, 12, 21, 20, 35);
    final JobRun<Object?> r = await run('equity_snapshot', '2026-12-21');
    expect((r.error! as OpsConfigUnavailable).code, OpsConfigCodes.drift);
  });

  test('🔴 equity_snapshot = 가상 초기금이 현금으로 잡힌다 · 봉 원천은 만들지 않는다', () async {
    openSim();
    clock.now = kst(2026, 12, 21, 20, 35);
    final JobRun<Object?> r = await run(
      'equity_snapshot',
      '2026-12-21',
      p: parts(feedFails: true),
    );
    expect(r.status, JobStatus.success, reason: '${r.error}');
    final EquitySnapshotReport rep = r.report! as EquitySnapshotReport;
    expect(rep.row.tradeDate, '2026-12-21');
    expect(rep.row.cashKrw, 10000000);
    expect(rep.row.positionsValue, 0);
    expect(rep.row.totalEquity, 10000000);
    expect(
      files.sim.select(
        'SELECT mode FROM equity_snapshot WHERE trade_date = ?',
        <Object?>['2026-12-21'],
      ).single['mode'],
      RunMode.simInternal.wire,
    );
    expect(feedsMade, 0);
    expect(
      log.entriesOf('equity_snapshot').single.status,
      JobRunStatus.success,
    );
  });

  test('🔴 simBroker · live 현금 = 아직 미조립(조용히 0원으로 돌지 않는다)', () async {
    openSim();
    clock.now = kst(2026, 12, 21, 20, 35);
    final JobRun<Object?> r = await run(
      'equity_snapshot',
      '2026-12-21',
      c: ctx(mode: RunMode.simBroker),
    );
    expect(r.status, JobStatus.failed);
    expect('${r.error}', 'UNASSEMBLED equity_snapshot: cash_broker_SIM_BROKER');
  });

  test(
    '🔴 daily_data = 계획 종목(설정 · A 종목 포함) 수집 · 실패는 회차 성공 + DATA_SOURCE_DOWN',
    () async {
      openSim();
      clock.now = kst(2026, 12, 21, 18, 35);
      final JobRun<Object?> r = await run('daily_data', '2026-12-21');
      expect(r.status, JobStatus.success, reason: '${r.error}');
      final DailyDataReport rep = r.report! as DailyDataReport;
      expect(rep.results.map((x) => x.key), containsAll(cfg.krSymbols));
      expect(r.alerts, contains(AlertCodes.dataSourceDown));
      expect(feedsMade, 1);
    },
  );

  test('🆕 E11q-q6c daily_data = 먼저 X7 실사 표식(투자 안내 · 신뢰 시각) — 시세 원천이 죽어도 · 신뢰 시각 모름 = 손대지 않음 · 자동 매매 = 내림', () async {
    openSim();
    files.sim.execute(
      'INSERT INTO self_report_balance (report_id, as_of_trade_date, account_alias, session_started_at, cash_krw, '
      "declared_complete, device_id, command_id, reported_at, cash_check) VALUES ('sr-1', '2026-10-30', 'pension', "
      "'2026-11-01T00:00:00Z', 0, 1, 'dev-1', 'c-1', '2026-11-01T00:00:00Z', 'NO_TOLERANCE')",
    );
    clock.now = kst(2026, 12, 21, 18, 35);
    JobContext of(OperatingMode m, TrustedClock t) => JobContext(
      db: files.sim,
      runMode: RunMode.simInternal,
      operatingMode: m,
      execPolicy: ExecPolicy.execute,
      calendars: cals,
      heartbeat: hb,
      alerts: SqliteAlertSink(files.sim, clock: clock),
      runLog: log,
      clock: clock,
      trusted: t,
    );
    Map<String, String> flags() => <String, String>{
      for (final Row r in files.sim.select(
        'SELECT flag_id, reason FROM trading_block WHERE cleared_at IS NULL',
      ))
        r['flag_id'] as String: r['reason'] as String,
    };
    expect(
      refreshSelfAuditOf(
        of(OperatingMode.advisory, const UnknownTrustedClock()),
        cfg,
      ),
      isFalse,
    );
    expect(flags(), isEmpty);
    // 10/30 실사 · 12/21 = 52일 · 닫힌 달 = 11월 → 재고지 구간 · 표식 + 알림 1 — 시세 원천이 죽어 회차는 실패해도.
    final JobRun<Object?> r = await run(
      'daily_data',
      '2026-12-21',
      c: of(OperatingMode.advisory, _Trusted(clock.now)),
      p: parts(feedFails: true),
    );
    expect(r.status, JobStatus.failed);
    expect(flags(), <String, String>{
      FlagIds.selfAuditDue: 'aaq://ledger/self-report/2026-11/pension',
    });
    expect(
      files.sim
          .select('SELECT source FROM alert_event WHERE code = ?', <Object?>[
            AlertCodes.selfAuditDue,
          ])
          .map((Row x) => x['source']),
      <Object?>['self_audit'],
    );
    expect(
      refreshSelfAuditOf(of(OperatingMode.autoTrade, _Trusted(clock.now)), cfg),
      isTrue,
    );
    expect(flags(), isEmpty);
  });

  test('seasonal_a = 설정의 A 종목으로 본체가 돈다(판정 날이 아니면 아무것도 쓰지 않음)', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 8, 5);
    final JobRun<Object?> r = await run('seasonal_a', '2026-12-22');
    expect(r.status, JobStatus.success, reason: '${r.error}');
    final SeasonalAReport rep = r.report! as SeasonalAReport;
    expect(rep.created, false);
  });

  test('monthly_rebalance = 세션일 월말로 본체까지 간다(시세 없음 = 본체가 쓰지 않고 멈춤)', () async {
    openSim();
    clock.now = kst(2027, 1, 4, 8, 5);
    final JobRun<Object?> r = await run('monthly_rebalance', '2027-01-04');
    // 시드(2026-08) 뒤 시세가 없다 — 본체가 «아무것도 쓰지 않고» 멈춘다(본체 규칙 · daily_data 가 먼저 채운다).
    // 여기서 보는 것 = 미조립 · 설정 없음이 아니라 본체까지 갔다(설정 · 현금 · 연금 계좌 · 세션일이 들어갔다).
    expect(r.status, JobStatus.failed);
    expect(r.error, isA<MonthlyRebalanceError>());
    expect(
      files.sim.select('SELECT COUNT(*) AS n FROM plan_snapshot').first['n'],
      0,
    );
    expect(
      log.entriesOf('monthly_rebalance').single.sessionDay,
      const TradeDate('2026-12-30'), // 12-31 = KRX 연말 휴장 → 월말 세션 = 12-30
    );
  });
}
