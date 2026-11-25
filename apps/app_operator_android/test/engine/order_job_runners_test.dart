// E11p3c-3 주문 잡 실물(설계 13 §8 R101) — 실 SQLite(시드 · 설정 등재 · 모의 개시 · DRY_RUN 커밋) · KIS = 가짜(네트워크 0).

import 'dart:convert';
import 'dart:io';

import 'package:app_operator_android/engine/data_job_runners.dart';
import 'package:app_operator_android/engine/job_runners.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/engine/order_job_runners.dart';
import 'package:broker_gateway/broker_gateway.dart' show KisPrice;
import 'package:core_engine/core_engine.dart'
    show
        AccountBroker,
        AmountSizing,
        DailyQuoteFeed,
        InstrumentKind,
        JobRunEntry,
        JobRunStatus,
        Market,
        ModeGuardRejected,
        OperationsConfig,
        OrderTarget,
        P0sHumanInputs,
        P0sOpsConfig,
        P0sStrategyIds,
        PingStatus,
        PriceAdjust,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind,
        ReconReport,
        TierBCard,
        orderTargetToJson,
        p0sRegimeConfigHash;
import 'package:core_engine/testing.dart' show FakeOrderBroker;
import 'package:data_sync/data_sync.dart'
    show
        FredClient,
        OfrClient,
        OpsConfigCodes,
        OpsConfigUnavailable,
        SeedFile,
        SqliteAlertSink,
        SqliteConfigVersionStore,
        SqliteCredentialRegistry,
        SqliteJobRunLog,
        SqliteOnboardingStore,
        importSeedBundle,
        kSeedFiles;
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        CommandContext,
        ExecPolicy,
        OrderSide,
        MarketDataSource,
        OperatingMode,
        RunMode,
        SafetyHoldCodes,
        SelfReportBalance,
        SelfReportLine,
        SelfReportPurpose,
        TradeDate;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobCalendars,
        JobOccurrence,
        JobRun,
        JobStatus,
        KrOrderOpenReport,
        jobSpecOf,
        occurrenceOn;

import 'support.dart';

class _DownFeed implements DailyQuoteFeed {
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
  }) async => throw const QuoteFeedDown('시험', attempts: 1);
}

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

/// 🆕 R150 — 운영 설정의 재개 사다리(SPEC 02 §4 `operations.resume`).
final OperationsConfig _ops = OperationsConfig.fromJson(<String, Object?>{
  'resume': <String, Object?>{
    'gap_ladder_trading_days': <int>[2, 5, 10],
    'backup_gap_days': 7,
  },
});

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
  late int pricesAsked;
  KisPrice? price;

  JobParts parts({Future<AccountBroker> Function(String alias)? live}) =>
      JobParts(
        quoteFeed: (RunMode m) async => _DownFeed(),
        priceFetch: (RunMode m) async {
          pricesAsked++;
          return (String code) async =>
              price ?? (throw StateError('현재가 없음(시험)'));
        },
        fred: FredClient(down, sleep: (Duration _) async {}),
        ofr: OfrClient(down, sleep: (Duration _) async {}),
        regimeConfigHash: p0sRegimeConfigHash(),
        liveAccountBroker: live,
      );

  JobContext ctx({
    RunMode mode = RunMode.simInternal,
    OperatingMode operating = OperatingMode.autoTrade,
    bool withOperations = true,
    bool commandsBlocked = false,
  }) => JobContext(
    db: files.sim,
    runMode: mode,
    operatingMode: operating,
    execPolicy: ExecPolicy.execute,
    calendars: cals,
    heartbeat: hb,
    alerts: SqliteAlertSink(files.sim, clock: clock),
    runLog: log,
    clock: clock,
    operations: withOperations ? _ops : null,
    commandsBlocked: commandsBlocked,
  );

  /// 설정 등재 + 모의 개시(1,000만 원) + DRY_RUN 커밋(simInternal × 자동 매매 × 집행).
  void openSim() {
    final String hash = SqliteConfigVersionStore(
      files.sim,
      clock: clock,
    ).register(cfg.content());
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
    expect(
      s
          .dryRunStart(
            card: const TierBCard(
              b1R12mFloor: -0.15,
              b2DdFloor: -0.34,
              b3TuwMonths: 31,
            ),
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
    pricesAsked = 0;
    price = null;
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

  /// 12월 월말(12-30 · 12-31 = KRX 휴장) 계획 · 집행 첫날 2027-01-04 — B 전략 매수 40만 원 하나.
  /// 월말 본체가 쓰는 꼴 그대로. 집행 첫날은 월초 3거래일 유예 안이라 SAF-410(전월 계층 B 판정)을 아직 묻지 않는다.
  void seedPlan(String symbol) {
    final Map<String, Object?> outputs = <String, Object?>{
      'execution_day': '2027-01-04',
      'decision_id': 'MONTH-END-2026-12-30',
      'targets': <Object?>[
        orderTargetToJson(
          OrderTarget(
            logicalDecisionId: 'B-REBAL-2026-12-30',
            strategyId: P0sStrategyIds.sleeveB,
            symbol: symbol,
            side: OrderSide.buy,
            sizing: AmountSizing(Decimal.parse('400000')),
            instrument: InstrumentKind.etf,
          ),
        ),
      ],
    };
    files.sim.execute(
      'INSERT INTO plan_snapshot (plan_id, kind, computed_at, as_of_trade_date, expires_at, '
      "inputs, outputs, config_hash) VALUES (?, 'REBALANCE', ?, ?, ?, '{}', ?, ?)",
      <Object?>[
        'REBAL-2026-12-30',
        '2027-01-03T23:00:00.000Z',
        '2026-12-30',
        '2027-01-31',
        jsonEncode(outputs),
        cfg.configHash,
      ],
    );
  }

  int brokerOrders() =>
      files.sim.select('SELECT COUNT(*) AS n FROM broker_orders').first['n']
          as int;

  test('🔴 daily_reconcile = 가상 체결 브로커 · 원장 대사 성공 · 체크 이름 = 모드 2축', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 7, 10);
    final JobRun<Object?> r = await run('daily_reconcile', '2026-12-22');
    expect(r.status, JobStatus.success, reason: '${r.error}');
    expect(r.report, isA<ReconReport>());
    expect(r.check, 'sim-auto-daily_reconcile');
    expect(
      log.entriesOf('daily_reconcile').single.status,
      JobRunStatus.success,
    );
    expect(pricesAsked, 0);
  });

  test('🔴 kr_order = 계획 없음 → 주문 0 · 성공 · 낼 주문이 없으면 KIS 현재가를 묻지 않는다', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 9, 15);
    final JobRun<Object?> r = await run('kr_order', '2026-12-22');
    expect(r.status, JobStatus.success, reason: '${r.error}');
    expect(brokerOrders(), 0);
    expect(pricesAsked, 0);
    expect(log.entriesOf('kr_order').single.status, JobRunStatus.success);
    // 본체가 잡 규약을 감싼다 — 핑 시작 · 성공 한 쌍(두 번 감싸지 않는다).
    expect(hb.pings.map((Ping p) => p.status), <PingStatus>[
      PingStatus.start,
      PingStatus.success,
    ]);
  });

  test(
    '🔴 계획이 있으면 = 초안(KIS 현재가 · 기준가) → 한도 → 가상 체결 브로커에 지정가 접수(연금 계좌)',
    () async {
      openSim();
      final String b = cfg.krSymbols.firstWhere((String s) => s != cfg.aSymbol);
      seedPlan(b);
      price = KisPrice(
        price: 10000,
        basePrice: Decimal.parse('10000'),
        tickSize: Decimal.parse('5'),
        upperLimit: Decimal.parse('13000'),
        lowerLimit: Decimal.parse('7000'),
        halted: false,
      );
      clock.now = kst(2027, 1, 4, 9, 15);
      final JobRun<Object?> r = await run('kr_order', '2027-01-04');
      expect(r.status, JobStatus.success, reason: '${r.error}');
      expect(pricesAsked, 1);
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[
        for (final row in files.sim.select(
          'SELECT b.broker_order_no, i.account, i.symbol, i.side, i.order_type '
          'FROM broker_orders b JOIN order_intents i ON i.intent_id = b.intent_id',
        ))
          <String, Object?>{for (final String k in row.keys) k: row[k]},
      ];
      expect(
        rows,
        hasLength(1),
        reason: '$rows · ${(r.report! as KrOrderOpenReport).batch?.outcomes}',
      );
      expect(rows.single['account'], 'pension');
      expect(rows.single['symbol'], b);
      expect('${rows.single['broker_order_no']}', contains('SIM'));
    },
  );

  test(
    '🔴 잡 앞 재개 가드(R77) — 마지막 성공 스냅숏 뒤 갭이 있으면 kr_order 가 재개 회차를 먼저 연다',
    () async {
      openSim();
      // 마지막 성공 equity_snapshot = 12-14 → 12-22 까지 갭(거래일) > 0.
      await log.record(
        JobRunEntry(
          rid: 'rid-snap-1214',
          checkName: 'sim-auto-equity_snapshot',
          sessionDay: const TradeDate('2026-12-14'),
          startedAtUtc: DateTime.utc(2026, 12, 14, 11, 30),
          finishedAtUtc: DateTime.utc(2026, 12, 14, 11, 31),
          status: JobRunStatus.success,
        ),
      );
      int resumeRuns() =>
          files.sim.select('SELECT COUNT(*) AS n FROM resume_run').first['n']
              as int;
      expect(resumeRuns(), 0);
      clock.now = kst(2026, 12, 22, 9, 15);
      await run('kr_order', '2026-12-22');
      expect(resumeRuns(), 1);
    },
  );

  test('kr_order_close = 마감 확인 성공', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 15, 50);
    final JobRun<Object?> r = await run('kr_order_close', '2026-12-22');
    expect(r.status, JobStatus.success, reason: '${r.error}');
    expect(log.entriesOf('kr_order_close').single.status, JobRunStatus.success);
  });

  test('🆕 E11m-a(R274 A5) — 뷰어 명령 확인 못 함 = kr_order · kr_order_close 실패(기록 · 주문 0 · 현재가 0) · daily_reconcile 그대로 · 풀리면 다시 돈다', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 7, 10);
    final JobRun<Object?> recon = await run(
      'daily_reconcile',
      '2026-12-22',
      c: ctx(commandsBlocked: true),
    );
    expect(recon.status, JobStatus.success, reason: '${recon.error}');
    clock.now = kst(2026, 12, 22, 9, 15);
    final JobRun<Object?> r = await run(
      'kr_order',
      '2026-12-22',
      c: ctx(commandsBlocked: true),
    );
    expect(r.status, JobStatus.failed);
    expect(r.error, isA<OrderJobCommandsUnconfirmed>());
    expect(r.error.toString(), contains('kr_order'));
    expect(log.entriesOf('kr_order').single.status, JobRunStatus.failed);
    expect((brokerOrders(), pricesAsked), (0, 0));
    expect(hb.pings.last.status, PingStatus.fail);
    final JobRun<Object?> again = await run('kr_order', '2026-12-22');
    expect(again.status, JobStatus.success, reason: '${again.error}');
    clock.now = kst(2026, 12, 22, 15, 50);
    final JobRun<Object?> close = await run(
      'kr_order_close',
      '2026-12-22',
      c: ctx(commandsBlocked: true),
    );
    expect(close.error, isA<OrderJobCommandsUnconfirmed>());
    expect(kCommandGatedOrderJobs, <String>{'kr_order', 'kr_order_close'});
  });

  test('🔴 회차 세션일 ≠ 오늘 = 돌리지 않고 그 회차 실패(지난 날 주문을 오늘 내지 않는다)', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 9, 15);
    final JobRun<Object?> r = await run('kr_order', '2026-12-21');
    expect(r.status, JobStatus.failed);
    expect(r.error, isA<OrderJobNotToday>());
    expect(
      log.entriesOf('kr_order').single.sessionDay,
      const TradeDate('2026-12-21'),
    );
    expect(brokerOrders(), 0);
  });

  test('🔴 투자 안내 = 안내 받는 쪽이 아직 없다 → 미조립', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 9, 15);
    final JobRun<Object?> r = await run(
      'kr_order',
      '2026-12-22',
      c: ctx(operating: OperatingMode.advisory),
    );
    expect('${r.error}', 'UNASSEMBLED kr_order: advice_sink');
    expect(log.entriesOf('kr_order').single.status, JobRunStatus.failed);
  });

  test('🔴 simBroker = KIS 계좌 · 원격 리스가 아직 없다 → 미조립', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 7, 10);
    final JobRun<Object?> r = await run(
      'daily_reconcile',
      '2026-12-22',
      c: ctx(mode: RunMode.simBroker),
    );
    expect('${r.error}', 'UNASSEMBLED daily_reconcile: cash_broker_SIM_BROKER');
  });

  group('🆕 R207 실전 개시 — live 주문 잡 = 계좌마다 KIS 브로커 · 실키 사실 = 원장 키 검증 기록', () {
    late List<String> made;
    late Database live;

    JobParts liveParts() => parts(
      live: (String alias) async {
        made.add(alias);
        return FakeOrderBroker();
      },
    );

    // 🆕 리뷰 3차 A-1(R265) — 실전 잡 = 실전 원장(커밋의 live 몫: 모드 행 · 실전 개시 판 · 키 검증 기록) · dryRun.
    //    (옛 시험은 모의 원장을 실전 모드로 돌려 «모의 개시 판»을 빌렸다 — 실물 커밋 → 잡 = `operator_handover_test` A-1.)
    JobContext liveCtx() => JobContext(
      db: live,
      runMode: RunMode.live,
      operatingMode: OperatingMode.autoTrade,
      execPolicy: ExecPolicy.dryRun,
      calendars: cals,
      heartbeat: hb,
      alerts: SqliteAlertSink(live, clock: clock),
      runLog: SqliteJobRunLog(live),
      clock: clock,
      operations: _ops,
    );

    void verify(String kind, String ref) =>
        SqliteCredentialRegistry(live, clock: clock).recordVerification(
          alias: ref.replaceAll('.', '_'),
          kind: kind,
          keystoreRef: ref,
          passed: true,
        );

    setUp(() {
      made = <String>[];
      live = writeLiveMode(Directory(files.directory), clock);
      writeLiveOpening(live, clock, cfg);
    });
    tearDown(() => live.close());

    test('🔴 실전 계좌 브로커 자리가 없으면 = 미조립(조용히 다른 길로 돌지 않는다)', () async {
      clock.now = kst(2026, 12, 22, 7, 10);
      final JobRun<Object?> r = await run(
        'daily_reconcile',
        '2026-12-22',
        c: liveCtx(),
      );
      expect(
        r.error.toString(),
        'UNASSEMBLED daily_reconcile: cash_broker_LIVE',
      );
    });

    test('🔴 키 검증 기록 없음 = LIVE_AWAITING_KEYS 로 막힌다 · 실전 브로커 0', () async {
      verify('KIS_LIVE', 'kis.live');
      clock.now = kst(2026, 12, 22, 7, 10);
      final JobRun<Object?> r = await run(
        'daily_reconcile',
        '2026-12-22',
        c: liveCtx(),
        p: liveParts(),
      );
      expect(r.status, JobStatus.failed);
      expect(r.error, isA<ModeGuardRejected>());
      expect(r.error.toString(), contains(SafetyHoldCodes.liveAwaitingKeys));
      expect(made, isEmpty);
    });

    test('🔴 실전 세트 둘 다 검증 = 가드 통과 → 계좌 별칭마다 실전 브로커(처음 쓸 때 · 한 번)', () async {
      verify('KIS_LIVE', 'kis.live');
      verify('KIS_ISA', 'kis.isa');
      clock.now = kst(2026, 12, 22, 7, 10);
      final JobRun<Object?> r = await run(
        'daily_reconcile',
        '2026-12-22',
        c: liveCtx(),
        p: liveParts(),
      );
      expect(r.status, JobStatus.success, reason: '${r.error}');
      expect(made.toSet(), <String>{'general', 'pension'});
      expect(made, hasLength(2));
    });

    test('🆕 리뷰 3차 A-1(R265) — 실전 모드 잡은 실전 개시 판만 — 모의 원장(모의 개시 판만)을 실전 모드로 = 개시 없음 · 회차 실패', () async {
      openSim();
      clock.now = kst(2026, 12, 22, 7, 10);
      final JobRun<Object?> r = await run(
        'daily_reconcile',
        '2026-12-22',
        c: ctx(mode: RunMode.live),
        p: liveParts(),
      );
      expect(r.status, JobStatus.failed);
      expect(
        r.error,
        isA<OpsConfigUnavailable>().having(
          (OpsConfigUnavailable u) => u.code,
          'code',
          OpsConfigCodes.noOpening,
        ),
      );
      expect(made, isEmpty);
    });
  });

  test('🔴 운영 설정(재개 사다리) 없음 = 미조립 — core 기본값으로 조용히 돌지 않는다', () async {
    openSim();
    clock.now = kst(2026, 12, 22, 9, 15);
    final JobRun<Object?> r = await run(
      'kr_order',
      '2026-12-22',
      c: ctx(withOperations: false),
    );
    expect('${r.error}', 'UNASSEMBLED kr_order: operations.resume');
    expect(log.entriesOf('kr_order').single.status, JobRunStatus.failed);
  });

  test('모의 개시 전 = 설정 없음 → 회차 실패(기록 남김)', () async {
    clock.now = kst(2026, 12, 22, 7, 10);
    final JobRun<Object?> r = await run('daily_reconcile', '2026-12-22');
    expect(r.error, isA<OpsConfigUnavailable>());
    expect(log.entriesOf('daily_reconcile').single.status, JobRunStatus.failed);
  });
}
