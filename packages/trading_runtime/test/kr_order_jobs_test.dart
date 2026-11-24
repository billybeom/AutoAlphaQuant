// 잡 규약 · 주문 잡(설계 13 §8 R42 S3~S10 · 01 §10 · 00_SPEC 잡 표 v2.38 · 04 §4-2 · §3-5 · §5-2).

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

Decimal _d(String s) => Decimal.parse(s);

const TradeDate _d1 = TradeDate('2026-11-04'); // 수
const TradeDate _d2 = TradeDate('2026-11-05'); // 목
const TradeDate _sat = TradeDate('2026-11-07');

/// [day] 의 KST 시각(UTC 값).
DateTime _kst(TradeDate day, int h, int m) =>
    DateTime.parse('${day.yyyyMmDd}T00:00:00Z')
        .add(Duration(hours: h - 9, minutes: m));

final LimitConfig _limits = LimitConfig(
  maxNotionalPct: 0.05,
  riskBudgetPct: 0.0035,
  satelliteMaxPositions: 8,
  satelliteMaxPerSector: 3,
  maxRiskExposure: 0.85,
  maxLeverage: 1.0,
  maxPositions: 30,
  maxOrdersPerDay: 60,
  maxOrderValueKrw: _d('20000000'),
  maxDailyLossPct: 0.03,
  orderTypeWhitelist: const <String>{OrderTypes.limit, OrderTypes.market},
);

final LimitState _ok = LimitState(
  totalEquity: _d('100000000'),
  ordersToday: null,
  riskExposureAfter: 0.5,
  leverageAfter: 0.9,
  positionsAfter: 5,
  satellitePositionsAfter: null,
  satelliteSectorCountAfter: null,
  satelliteAllocation: null,
  satelliteExposure: null,
  satelliteDeployedBefore: null,
  dailyPnlPct: 0,
  fxRateUsdKrw: null,
  strategyRegistered: null,
  tradingBlocked: null,
  journalMissing: null,
  tierBUnjudged: null,
);

final DraftQuote _quote = DraftQuote(
  previousClose: _d('173315'),
  tickSize: _d('5'),
  upperLimit: _d('225305'),
  lowerLimit: _d('121325'),
);

KrOrderConfig _config({
  RunMode run = RunMode.live,
  OperatingMode op = OperatingMode.autoTrade,
  ExecPolicy exec = ExecPolicy.execute,
}) => KrOrderConfig(
  runMode: run,
  operatingMode: op,
  execPolicy: exec,
  draft: DraftConfig(
    limitOffsetPct: 0.005,
    buyCostRate: 0.00015,
    accountByStrategy: const <String, String>{
      P0sStrategyIds.sleeveB: 'pension',
    },
  ),
  limits: _limits,
  buyCostRate: 0.00015,
  configHash: 'cfg-test',
  fillCosts: const FillCostRates(commissionRate: 0.00015, sellTaxRate: 0),
  instruments: const <String, InstrumentKind>{'133690': InstrumentKind.etf},
);

OrderTarget _target(int shares) => OrderTarget(
  logicalDecisionId: 'B-SMA-2026-10-30',
  strategyId: P0sStrategyIds.sleeveB,
  symbol: '133690',
  side: OrderSide.buy,
  sizing: ShareSizing(shares),
  instrument: InstrumentKind.etf,
);

DailyFillRow _row(
  TradeDate day, {
  required int qty,
  required int cum,
  String odno = '0000000001',
  Decimal? price,
}) => DailyFillRow(
  orderDate: day,
  odno: odno,
  isCancelRow: false,
  symbol: '133690',
  side: OrderSide.buy,
  orderQty: qty,
  orderPrice: price ?? _d('174185'),
  orderTime: '091005',
  cumFilledQty: cum,
  cumFilledAmount: Decimal.fromInt(174185 * cum),
  remainingQty: qty - cum,
);

class _Targets implements TargetSource {
  final Map<String, List<OrderTarget>> byDay = <String, List<OrderTarget>>{};
  Error? error;

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async {
    final Error? e = error;
    if (e != null) throw e;
    return byDay[today.yyyyMmDd] ?? const <OrderTarget>[];
  }
}

class _Quotes implements DraftQuoteSource {
  final List<Set<String>> asked = <Set<String>>[];

  @override
  Future<Map<String, DraftQuote>> quotesFor(Set<String> symbols) async {
    asked.add(symbols);
    return <String, DraftQuote>{for (final String s in symbols) s: _quote};
  }
}

class _Beat implements JobHeartbeat {
  final List<(String, PingStatus, String?)> pings =
      <(String, PingStatus, String?)>[];
  bool failing = false;

  final List<String?> rids = <String?>[];

  @override
  Future<void> ping(
    String check,
    PingStatus status, {
    String? note,
    String? rid,
  }) async {
    pings.add((check, status, note));
    rids.add(rid);
    if (failing) throw StateError('핑 실패');
  }

  List<PingStatus> get statuses => <PingStatus>[
    for (final (String _, PingStatus s, String? _) in pings) s,
  ];
}

class _Alerts implements AlertSink {
  final List<(String, Set<String>)> sent = <(String, Set<String>)>[];
  bool failing = false;

  @override
  Future<void> emit(String check, Set<String> codes) async {
    if (failing) throw StateError('발송 실패');
    sent.add((check, codes));
  }
}

class _Rig {
  _Rig({
    DateTime? now,
    KrOrderConfig? config,
    Future<void> Function(TradeDate)? preGuard,
  }) {
    clock = now ?? _kst(_d1, 9, 10);
    jobs = KrOrderJobs(
      ledger: ledger,
      brokers: brokers,
      kr: frozenExchangeCalendar(Market.kr),
      config: config ?? _config(),
      targets: targets,
      quotes: quotes,
      limitStateFor: (OrderIntentDraft d) async => _ok,
      heartbeat: beat,
      alerts: alerts,
      nowUtc: () => clock,
      lease: lease,
      runLog: runLog,
      plannedWork: plannedWork,
      modeFacts: modeFacts,
      preGuard: preGuard,
      sleep: (Duration d) async => sleeps.add(d),
    );
  }

  final FakePlannedWorkLedger plannedWork = FakePlannedWorkLedger();

  final FakeLeaseGate lease = FakeLeaseGate();
  final FakeModeFacts modeFacts = FakeModeFacts();
  final FakeJobRunLog runLog = FakeJobRunLog();

  final FakeOrderLedger ledger = FakeOrderLedger(
    registeredStrategies: <String>{P0sStrategyIds.sleeveB},
  );
  final Map<String, AccountBroker> brokers = <String, AccountBroker>{
    'pension': FakeOrderBroker(orderDate: _d1),
  };
  final _Targets targets = _Targets();
  final _Quotes quotes = _Quotes();
  final _Beat beat = _Beat();
  final _Alerts alerts = _Alerts();
  final List<Duration> sleeps = <Duration>[];
  late DateTime clock;
  late final KrOrderJobs jobs;

  FakeOrderBroker get broker => brokers['pension']! as FakeOrderBroker;

  void at(TradeDate day, int h, int m) {
    clock = _kst(day, h, m);
    ledger.clock = () => clock;
  }
}

void main() {
  group('잡 규약(runJob · 01 §10 · R42 S3)', () {
    test('체크 이름 = {sim|live}-{auto|advisory}-{잡}(04 §5-2 2축 접두)', () {
      expect(
        watchdogCheckName(RunMode.live, OperatingMode.autoTrade, 'kr_order'),
        'live-auto-kr_order',
      );
      expect(
        watchdogCheckName(
          RunMode.simBroker,
          OperatingMode.advisory,
          'kr_order',
        ),
        'sim-advisory-kr_order',
      );
      expect(
        watchdogCheckName(RunMode.simInternal, OperatingMode.autoTrade, 'x'),
        'sim-auto-x',
      );
      expect(
        _Rig(config: _config(run: RunMode.simBroker)).jobs
            .checkOf(KrJobs.order),
        'sim-auto-kr_order',
      );
    });

    test('휴장(토요일) = 성공 핑 «휴장» 하나 · 본체를 돌리지 않는다', () async {
      final _Rig rig = _Rig(now: _kst(_sat, 9, 10));
      final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
      expect(r.status, JobStatus.holiday);
      expect(r.report, isNull);
      expect(rig.beat.pings, <(String, PingStatus, String?)>[
        ('live-auto-kr_order', PingStatus.success, '휴장'),
      ]);
      expect(rig.ledger.calls, isEmpty);
      expect(rig.broker.fillReads, 0);
    });

    test('본체 예외 = start → fail 핑 · 결과에 오류 · 다시 던지지 않는다 · 주문 0', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 9, 10);
      rig.targets.error = StateError('계획을 못 읽었다');
      final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
      expect(r.status, JobStatus.failed);
      expect(r.error, isA<StateError>());
      expect(r.note, contains('계획을 못 읽었다'));
      expect(rig.beat.statuses, <PingStatus>[
        PingStatus.start,
        PingStatus.fail,
      ]);
      expect(rig.broker.submitCount, 0);
    });

    test('🔴 핑 실패는 잡 결과를 바꾸지 않는다(센다)', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 7, 0);
      rig.beat.failing = true;
      final JobRun<ReconReport> r = await rig.jobs.runDailyReconcile();
      expect(r.status, JobStatus.success);
      expect(r.pingFailures, 2);
      expect(r.report!.action, ReconAction.matched);
    });

    test('🔴 알림 발송 실패 = fail 핑 · 결과는 남긴다', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 7, 0);
      rig.ledger.positions[(P0sStrategyIds.sleeveB, '133690')] = 5;
      rig.alerts.failing = true;
      final JobRun<ReconReport> r = await rig.jobs.runDailyReconcile();
      expect(r.status, JobStatus.failed);
      expect(r.report!.action, ReconAction.blocked);
      expect(r.alerts, <String>{AlertCodes.reconMismatch});
      expect(rig.beat.statuses, <PingStatus>[
        PingStatus.start,
        PingStatus.fail,
      ]);
      expect(rig.beat.pings.last.$3, startsWith('알림 발송 실패'));
    });

    test('달력 범위 밖 = start → fail(무엇도 판정하지 않는다)', () async {
      final _Rig rig = _Rig(now: DateTime.utc(2099, 1, 5, 1));
      final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
      expect(r.status, JobStatus.failed);
      expect(rig.beat.statuses, <PingStatus>[
        PingStatus.start,
        PingStatus.fail,
      ]);
      expect(rig.ledger.calls, isEmpty);
    });
  });

  group('kr_order 시각 창(R42 S4 · S5 · 00_SPEC v2.38)', () {
    test('09:05 앞 = 실패(알람 설정 오류) · 주문 0', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 9, 4);
      rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];
      final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
      expect(r.status, JobStatus.failed);
      expect(r.note, contains('09:05'));
      expect(rig.broker.submitCount, 0);
      expect(kKrOrderEarliestKst, const Duration(hours: 9, minutes: 5));
    });

    test(
      '15:00 뒤 = 내지 않고 성공 «발주 상한 지남 — 다음 거래일» · 원장 · 브로커를 건드리지 않는다',
      () async {
        final _Rig rig = _Rig();
        rig.at(_d1, 15, 0);
        rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];
        final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
        expect(r.status, JobStatus.success);
        expect(r.report!.skippedReason, contains('15:00'));
        expect(r.report!.batch, isNull);
        expect(rig.beat.pings.last.$3, contains('다음 거래일'));
        expect(rig.broker.submitCount, 0);
        expect(rig.ledger.calls, isEmpty);
        expect(kKrOrderCutoffKst, const Duration(hours: 15));
      },
    );

    test('마감 확인은 15:40 뒤에만 — 15:39 = 실패(core 가 막는다)', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 15, 39);
      final JobRun<KrOrderCloseReport> r = await rig.jobs.runClose();
      expect(r.status, JobStatus.failed);
      expect(r.check, 'live-auto-kr_order_close');
      expect(rig.beat.statuses, <PingStatus>[
        PingStatus.start,
        PingStatus.fail,
      ]);
    });
  });

  test(
    '🔴 E14a 리스 무효 = 배치 의도 REJECTED LEASE_INVALID · 브로커 제출 0(NR-1 0 · R71)',
    () async {
      final _Rig rig = _Rig();
      rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];
      rig.lease.verdict = LeaseVerdict.invalid;
      rig.at(_d1, 9, 10);
      final JobRun<KrOrderOpenReport> open = await rig.jobs.runOpen();
      expect(open.status, JobStatus.success);
      final ExecutionOutcome o = open.report!.batch!.outcomes.single;
      expect(
        (o.status, o.message),
        (ExecutionStatus.rejected, 'LEASE_INVALID'),
      );
      expect(rig.broker.submitted, isEmpty);
      expect(rig.lease.calls, greaterThan(0));
    },
  );

  test('🆕 E14c1 job_run — 잡마다 1행(체크 · 세션일 · 시작) · 유예 끝(09:10 + 60분) 안 = SUCCESS · 넘김 = LATE · 휴장 = HOLIDAY(R73 K2 · K4)', () async {
    final _Rig rig = _Rig();
    rig.at(_d1, 9, 10);
    await rig.jobs.runOpen();
    rig.at(_d1, 10, 11);
    await rig.jobs.runOpen();
    final _Rig sat = _Rig(now: _kst(_sat, 9, 10));
    await sat.jobs.runOpen();
    expect(
      rig.runLog.entries
          .map(
            (JobRunEntry e) =>
                (e.checkName, e.sessionDay, e.startedAtUtc, e.status),
          )
          .toList(),
      <(String, TradeDate, DateTime, JobRunStatus)>[
        ('live-auto-kr_order', _d1, _kst(_d1, 9, 10), JobRunStatus.success),
        ('live-auto-kr_order', _d1, _kst(_d1, 10, 11), JobRunStatus.late),
      ],
    );
    expect(jobDeadlineUtc(jobSpecOf(KrJobs.order), _d1), _kst(_d1, 10, 10));
    expect(sat.runLog.entries.single.status, JobRunStatus.holiday);
  });

  test('🆕 E14c2 마감 끝 = planned_work 평시 정리 1번(그날) · 보고 · 정리 실패 = 마감 FAILED · 15:39 실패 = 정리 0(R74 M5)', () async {
    final _Rig rig = _Rig();
    rig.plannedWork.settled = 2;
    rig.at(_d1, 15, 45);
    final JobRun<KrOrderCloseReport> r = await rig.jobs.runClose();
    expect(r.status, JobStatus.success);
    expect(r.report!.plannedSettled, 2);
    expect(r.note, endsWith('계획 정리 2'));
    expect(rig.plannedWork.calls, <TradeDate>[_d1]);
    final _Rig bad = _Rig();
    bad.plannedWork.throwing = Exception('정리 실패');
    bad.at(_d1, 15, 45);
    final JobRun<KrOrderCloseReport> f = await bad.jobs.runClose();
    expect(f.status, JobStatus.failed);
    expect(f.error, isA<Exception>());
    final _Rig early = _Rig();
    early.at(_d1, 15, 39);
    await early.jobs.runClose();
    expect(early.plannedWork.calls, isEmpty);
  });

  test('🆕 E14d2b KrOrderJobs 가드 = 잡마다 그 세션일로 한 번(R77 S2)', () async {
    final List<TradeDate> calls = <TradeDate>[];
    final _Rig rig = _Rig(preGuard: (TradeDate d) async => calls.add(d));
    rig.at(_d1, 9, 10);
    await rig.jobs.runOpen();
    rig.at(_d1, 15, 45);
    await rig.jobs.runClose();
    expect(calls, <TradeDate>[_d1, _d1]);
  });

  group('🆕 E15a 모드 가드 — 세 잡 본체 앞 · 재개 가드보다 먼저(R81 V4 · C-19 ⑦ 실엔진)', () {
    // 01 §10-2 #1~#12 · bool = 세션 없이 허용되나.
    const List<(RunMode, OperatingMode, ExecPolicy, bool)>
    cells = <(RunMode, OperatingMode, ExecPolicy, bool)>[
      (RunMode.simInternal, OperatingMode.autoTrade, ExecPolicy.execute, true),
      (RunMode.simInternal, OperatingMode.autoTrade, ExecPolicy.dryRun, false),
      (RunMode.simInternal, OperatingMode.advisory, ExecPolicy.execute, true),
      (RunMode.simInternal, OperatingMode.advisory, ExecPolicy.dryRun, false),
      (RunMode.simBroker, OperatingMode.autoTrade, ExecPolicy.execute, true),
      (RunMode.simBroker, OperatingMode.autoTrade, ExecPolicy.dryRun, false),
      (RunMode.simBroker, OperatingMode.advisory, ExecPolicy.execute, false),
      (RunMode.simBroker, OperatingMode.advisory, ExecPolicy.dryRun, false),
      (RunMode.live, OperatingMode.autoTrade, ExecPolicy.dryRun, true),
      (RunMode.live, OperatingMode.autoTrade, ExecPolicy.execute, true),
      (RunMode.live, OperatingMode.advisory, ExecPolicy.execute, true),
      (RunMode.live, OperatingMode.advisory, ExecPolicy.dryRun, false),
    ];

    // 세 잡을 그 시각에 한 번씩.
    Future<List<JobRun<Object?>>> runAll(_Rig rig) async {
      rig.at(_d1, 7, 0);
      final JobRun<Object?> a = await rig.jobs.runDailyReconcile();
      rig.at(_d1, 9, 10);
      final JobRun<Object?> b = await rig.jobs.runOpen();
      rig.at(_d1, 15, 45);
      final JobRun<Object?> c = await rig.jobs.runClose();
      return <JobRun<Object?>>[a, b, c];
    }

    int brokerTouches(_Rig rig) =>
        rig.broker.submitCount +
        rig.broker.fillReads +
        rig.broker.cashReads +
        rig.broker.balanceReads +
        rig.broker.cancelled.length;

    test('C-19 ⑦ 금지 5칸 + 세션 없는 #12 = 세 잡 전부 FAILED · 거부 코드 · 핑 «모드 가드 거부» · 원장 · 브로커 · 재개 가드 0', () async {
      int denied = 0;
      for (final (RunMode r, OperatingMode o, ExecPolicy e, bool ok) in cells) {
        if (ok) continue;
        denied++;
        final List<TradeDate> guards = <TradeDate>[];
        final _Rig rig = _Rig(
          config: _config(run: r, op: o, exec: e),
          preGuard: (TradeDate d) async => guards.add(d),
        );
        final String cell = '${r.wire}×${o.wire}×${e.wire}';
        for (final JobRun<Object?> res in await runAll(rig)) {
          expect(res.status, JobStatus.failed, reason: cell);
          expect(
            (res.error! as ModeGuardRejected).code,
            kModeCombinationDenied,
            reason: cell,
          );
          expect(res.report, isNull, reason: cell);
        }
        final List<String?> failNotes = <String?>[
          for (final (String _, PingStatus s, String? n) in rig.beat.pings)
            if (s == PingStatus.fail) n,
        ];
        expect(failNotes, hasLength(3), reason: cell);
        for (final String? n in failNotes) {
          expect(n, startsWith('모드 가드 거부 — '), reason: cell);
          expect(n, contains(kModeCombinationDenied), reason: cell);
        }
        expect(
          rig.runLog.entries.map((JobRunEntry x) => x.status).toSet(),
          <JobRunStatus>{JobRunStatus.failed},
          reason: cell,
        );
        expect(guards, isEmpty, reason: cell);
        expect(rig.ledger.calls, isEmpty, reason: cell);
        expect(brokerTouches(rig), 0, reason: cell);
        expect(rig.lease.calls, 0, reason: cell);
        expect(rig.modeFacts.calls, 3, reason: cell);
      }
      expect(denied, 6);
    });

    test('허용 6칸 = 가드 통과(재개 가드까지 감 · 거부 아님) · #12 + 유효 세션 = 통과', () async {
      for (final (RunMode r, OperatingMode o, ExecPolicy e, bool ok) in cells) {
        final bool conditional =
            r == RunMode.live &&
            o == OperatingMode.advisory &&
            e == ExecPolicy.dryRun;
        if (!ok && !conditional) continue;
        final List<TradeDate> guards = <TradeDate>[];
        final _Rig rig = _Rig(
          config: _config(run: r, op: o, exec: e),
          preGuard: (TradeDate d) async => guards.add(d),
        );
        rig.modeFacts.handoverSessionValid = conditional;
        rig.at(_d1, 7, 0);
        final JobRun<Object?> res = await rig.jobs.runDailyReconcile();
        final String cell = '${r.wire}×${o.wire}×${e.wire}';
        expect(res.error, isNot(isA<ModeGuardRejected>()), reason: cell);
        expect(guards, <TradeDate>[_d1], reason: cell);
        expect(rig.modeFacts.calls, 1, reason: cell);
      }
    });

    test('🔴 실키 대기(live × 자동 매매 · 미검증) = 세 잡 FAILED · LIVE_AWAITING_KEYS · 브로커 0 · 안내 모드 = 통과', () async {
      final _Rig rig = _Rig();
      rig.modeFacts.liveKeysVerified = false;
      for (final JobRun<Object?> res in await runAll(rig)) {
        expect(res.status, JobStatus.failed);
        expect(
          (res.error! as ModeGuardRejected).code,
          SafetyHoldCodes.liveAwaitingKeys,
        );
      }
      expect(brokerTouches(rig), 0);
      expect(rig.ledger.calls, isEmpty);
      final _Rig adv = _Rig(config: _config(op: OperatingMode.advisory));
      adv.modeFacts.liveKeysVerified = false;
      adv.at(_d1, 7, 0);
      final JobRun<Object?> ok = await adv.jobs.runDailyReconcile();
      expect(ok.error, isNot(isA<ModeGuardRejected>()));
    });

    test(
      '🔴 입력 포트 예외 = FAILED(fail-closed) · 재개 가드 · 브로커 0 · 휴장 = 가드 안 부름',
      () async {
        final List<TradeDate> guards = <TradeDate>[];
        final _Rig rig = _Rig(preGuard: (TradeDate d) async => guards.add(d));
        rig.modeFacts.throwing = Exception('정본을 못 읽었다');
        rig.at(_d1, 9, 10);
        final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
        expect(r.status, JobStatus.failed);
        expect(r.error.toString(), contains('정본을 못 읽었다'));
        expect(rig.beat.pings.last.$3, startsWith('모드 가드 거부 — '));
        expect(guards, isEmpty);
        expect(brokerTouches(rig), 0);
        final _Rig hol = _Rig(now: _kst(_sat, 9, 10));
        await hol.jobs.runOpen();
        expect(hol.modeFacts.calls, 0);
      },
    );
  });

  group('하루 — 07:00 대사 → 09:10 배치 → 15:40 마감 실효 → 다음 날 이월(R42 S10)', () {
    test('목표 10 → 1일 6 체결 · 4 실효 → 2일 이월 4 발주 · 대사 일치 · 핑 · 알림 없음', () async {
      final _Rig rig = _Rig();
      rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];

      rig.at(_d1, 7, 0);
      final JobRun<ReconReport> pre = await rig.jobs.runDailyReconcile();
      expect(pre.status, JobStatus.success);
      expect(pre.check, 'live-auto-daily_reconcile');
      expect(pre.report!.action, ReconAction.matched);

      rig.at(_d1, 9, 10);
      final JobRun<KrOrderOpenReport> open1 = await rig.jobs.runOpen();
      expect(open1.status, JobStatus.success);
      final KrOrderOpenReport o1 = open1.report!;
      expect(o1.batch!.outcomes.single.status, ExecutionStatus.submitted);
      expect(o1.carry!.targets, isEmpty);
      expect(o1.recon!.action, ReconAction.matched);
      expect(rig.quotes.asked.single, <String>{'133690'});
      expect(rig.broker.submitted.single.quantity, 10);
      expect(open1.alerts, isEmpty);
      expect(rig.alerts.sent, isEmpty);

      rig.broker.fills[_d1.yyyyMmDd] = <DailyFillRow>[
        _row(_d1, qty: 10, cum: 6),
      ];
      rig.broker.holdings['133690'] = 6;
      rig.at(_d1, 15, 45);
      final JobRun<KrOrderCloseReport> close1 = await rig.jobs.runClose();
      expect(close1.status, JobStatus.success);
      expect(close1.report!.fills.expired.single.expiredQty, 4);
      expect(rig.ledger.positions[(P0sStrategyIds.sleeveB, '133690')], 6);

      rig.brokers['pension'] = FakeOrderBroker(orderDate: _d2)
        ..holdings['133690'] = 6;
      rig.at(_d2, 9, 10);
      final JobRun<KrOrderOpenReport> open2 = await rig.jobs.runOpen();
      expect(open2.status, JobStatus.success);
      final KrOrderOpenReport o2 = open2.report!;
      expect(o2.carry!.targets.single.logicalDecisionId, 'B-SMA-2026-10-30');
      expect(rig.broker.submitted.single.quantity, 4);
      expect(o2.batch!.outcomes.single.status, ExecutionStatus.submitted);
      expect(o2.recon!.action, ReconAction.matched);
      expect(open2.note, contains('이월 1'));

      expect(rig.beat.statuses, <PingStatus>[
        for (int i = 0; i < 4; i++) ...<PingStatus>[
          PingStatus.start,
          PingStatus.success,
        ],
      ]);
      expect(
        rig.beat.pings.map(((String, PingStatus, String?) p) => p.$1).toSet(),
        <String>{
          'live-auto-daily_reconcile',
          'live-auto-kr_order',
          'live-auto-kr_order_close',
        },
      );
    });

    test(
      '결과 불명 = P0 ORDER_OUTCOME_UNKNOWN 알림(배치) · 마감에 원주문이 없으면 다시 P0',
      () async {
        final _Rig rig = _Rig();
        rig.brokers['pension'] = FakeOrderBroker(
          orderDate: _d1,
          script: <FakeSubmitStep>[const FakeUnknown()],
        );
        rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];
        rig.at(_d1, 9, 10);
        final JobRun<KrOrderOpenReport> open = await rig.jobs.runOpen();
        expect(open.status, JobStatus.success);
        expect(open.alerts, contains(AlertCodes.orderOutcomeUnknown));
        expect(rig.alerts.sent.single, ('live-auto-kr_order', open.alerts));

        // 해소 2행 이상 = P0 그대로(사람이 본다).
        // 행 단가 = 실제로 보낸 지정가(초안기가 호가에 맞춘 값).
        final Decimal sent = rig.broker.submitted.single.limitPrice!;
        rig.broker.fills[_d1.yyyyMmDd] = <DailyFillRow>[
          _row(_d1, qty: 10, cum: 0, price: sent),
          _row(_d1, qty: 10, cum: 0, price: sent, odno: '0000000002'),
        ];
        rig.at(_d1, 15, 45);
        final JobRun<KrOrderCloseReport> close = await rig.jobs.runClose();
        expect(close.report!.unknowns.ambiguous.single.candidates, 2);
        expect(close.alerts, <String>{AlertCodes.orderOutcomeUnknown});

        // 다음 날 오전도 앞날 UNKNOWN 을 먼저 맞춘다 — 여전히 2행 = 오전 배치도 P0.
        final List<DailyFillRow> prevRows = rig.broker.fills[_d1.yyyyMmDd]!;
        rig.brokers['pension'] = FakeOrderBroker(orderDate: _d2)
          ..fills[_d1.yyyyMmDd] = prevRows;
        rig.at(_d2, 9, 10);
        final JobRun<KrOrderOpenReport> next = await rig.jobs.runOpen();
        expect(next.report!.unknowns!.ambiguous, hasLength(1));
        expect(next.alerts, contains(AlertCodes.orderOutcomeUnknown));
      },
    );

    test('마감 조회 실패 = 열린 의도 UNKNOWN(DAY_END_UNAVAILABLE) · P0', () async {
      final _Rig rig = _Rig();
      rig.targets.byDay[_d1.yyyyMmDd] = <OrderTarget>[_target(10)];
      rig.at(_d1, 9, 10);
      await rig.jobs.runOpen();
      rig.broker.fillsError = StateError('조회 실패');
      rig.at(_d1, 15, 45);
      final JobRun<KrOrderCloseReport> close = await rig.jobs.runClose();
      expect(close.status, JobStatus.success);
      expect(close.report!.fills.unresolved, hasLength(1));
      expect(close.alerts, <String>{AlertCodes.orderOutcomeUnknown});
    });

    test(
      '배치 직후 대사가 어긋나면 재대사 뒤 P0 RECON_MISMATCH · 다음 오전 배치는 SAF-407 로 막힌다',
      () async {
        final _Rig rig = _Rig();
        rig.broker.holdings['133690'] = 3; // 원장에 없는 보유(수동 매매 등)
        rig.at(_d1, 9, 10);
        final JobRun<KrOrderOpenReport> open = await rig.jobs.runOpen();
        expect(open.report!.recon!.action, ReconAction.blocked);
        expect(rig.sleeps, <Duration>[kReconRecheckDelay]);
        expect(open.alerts, <String>{AlertCodes.reconMismatch});

        rig.targets.byDay[_d2.yyyyMmDd] = <OrderTarget>[_target(1)];
        rig.brokers['pension'] = FakeOrderBroker(orderDate: _d2)
          ..holdings['133690'] = 3;
        rig.at(_d2, 9, 10);
        final JobRun<KrOrderOpenReport> next = await rig.jobs.runOpen();
        expect(
          next.report!.batch!.outcomes.single.status,
          ExecutionStatus.rejected,
        );
        expect(
          next.report!.batch!.outcomes.single.message,
          startsWith('SAF-407'),
        );
        expect(rig.broker.submitCount, 0);
      },
    );

    test('대상 없는 날 = 초안 0 · 시세 묻지 않음 · 대사만', () async {
      final _Rig rig = _Rig();
      rig.at(_d1, 9, 10);
      final JobRun<KrOrderOpenReport> r = await rig.jobs.runOpen();
      expect(r.status, JobStatus.success);
      expect(r.report!.batch!.outcomes, isEmpty);
      expect(rig.quotes.asked, isEmpty);
      expect(r.report!.recon!.action, ReconAction.matched);
      expect(r.note, startsWith('초안 0'));
    });
  });

  test('🆕 E15e1 «승격 전 브로커 주문 0» — live × auto × dryRun 이틀 · 목표 있음 = 제출 0 · 회차 SUCCESS · 대사 일치(06 M1-22 · R89 AC9)', () async {
    final _Rig rig = _Rig(config: _config(exec: ExecPolicy.dryRun));
    for (final TradeDate d in <TradeDate>[_d1, _d2]) {
      rig.targets.byDay[d.yyyyMmDd] = <OrderTarget>[_target(10)];
      rig.at(d, 9, 10);
      final JobRun<KrOrderOpenReport> open = await rig.jobs.runOpen();
      expect(open.status, JobStatus.success, reason: d.yyyyMmDd);
      expect(open.check, 'live-auto-kr_order');
      expect(open.report!.recon!.action, ReconAction.matched);
      final List<ExecutionOutcome> outs = open.report!.batch!.outcomes;
      expect(outs, isNotEmpty, reason: d.yyyyMmDd);
      for (final ExecutionOutcome o in outs) {
        expect(o.status, ExecutionStatus.skipped, reason: d.yyyyMmDd);
      }
    }
    expect(rig.broker.submitCount, 0);
    expect(rig.broker.submitted, isEmpty);
    expect(
      <(String, JobRunStatus)>[
        for (final JobRunEntry e in rig.runLog.entries) (e.checkName, e.status),
      ],
      <(String, JobRunStatus)>[
        ('live-auto-kr_order', JobRunStatus.success),
        ('live-auto-kr_order', JobRunStatus.success),
      ],
    );
  });

  group('🆕 E15f5 전환 구간 재생(설계 13 §8 R108 AM5 · SPEC 04 :400 ① «실계좌 첫 주문 = 승격 뒤 첫 배치»)', () {
    test('위저드 조회 → 전환(감시 체크 바꿈) → live dryRun 이틀(리스 유효 = SKIPPED · 모름 = LEASE_INVALID) → 관찰 2일 = 승격 가능 · 승격 판정 = 리스 모름이면 막힘 · 실계좌 제출 내내 0', () async {
      final _Rig rig = _Rig(config: _config(exec: ExecPolicy.dryRun));

      // ① 위저드 S3 · 커밋 직전 조회 = 조회만.
      final LiveAccountProbe p = (await probeLiveAccount(
        alias: 'pension',
        accountMark: 'mark-pension',
        broker: rig.broker,
        today: _d1,
        fetchedAtUtc: _kst(_d1, 8, 0),
      ))!;
      expect((p.holdingsCount, p.activityToday), (0, 0));
      expect(rig.broker.balanceReads, 1);
      expect(rig.broker.submitCount, 0);

      // ② 전환 — 새 live-auto 체크 생성 → 커밋 → 마감 → 옛 sim-auto 체크 멈춤.
      final FakeWatchdogRemote remote = FakeWatchdogRemote(
        initial: <RemoteCheck>[
          for (final WatchdogCheckSpec s in watchdogCheckSpecsFor(
            RunMode.simInternal,
            OperatingMode.autoTrade,
          ))
            RemoteCheck(slug: s.slug, status: RemoteCheckStatus.up),
        ],
      );
      final SimToAutoSwitchResult sw = await runSimToAutoSwitch(
        remote: remote,
        newSpecs: watchdogCheckSpecsFor(RunMode.live, OperatingMode.autoTrade),
        newPrefix: 'live-auto',
        oldPrefix: 'sim-auto',
        commit: () async =>
            const SimToAutoSwitchCommit.ok('LIVEOPEN-1', '옮겼습니다.'),
        finish: () async {},
      );
      expect(sw.committed, isTrue);
      final Iterable<RemoteCheck> sims = remote.store.values.where(
        (RemoteCheck c) => c.slug.startsWith('sim-auto-'),
      );
      final Iterable<RemoteCheck> lives = remote.store.values.where(
        (RemoteCheck c) => c.slug.startsWith('live-auto-'),
      );
      expect(sims, hasLength(8));
      expect(
        sims.every((RemoteCheck c) => c.status == RemoteCheckStatus.paused),
        isTrue,
      );
      expect(lives, hasLength(8));
      expect(
        lives.every((RemoteCheck c) => c.status == RemoteCheckStatus.fresh),
        isTrue,
      );
      expect(rig.broker.submitCount, 0);

      // ③ live × auto × dryRun 이틀 — 첫날 리스 유효 · 둘째 날 모름(E11k 전).
      final Map<TradeDate, (LeaseVerdict, ExecutionStatus, String?)> days =
          <TradeDate, (LeaseVerdict, ExecutionStatus, String?)>{
            _d1: (LeaseVerdict.valid, ExecutionStatus.skipped, null),
            _d2: (
              LeaseVerdict.unknown,
              ExecutionStatus.rejected,
              'LEASE_INVALID',
            ),
          };
      for (final MapEntry<TradeDate, (LeaseVerdict, ExecutionStatus, String?)> e
          in days.entries) {
        rig.lease.verdict = e.value.$1;
        rig.targets.byDay[e.key.yyyyMmDd] = <OrderTarget>[_target(10)];
        rig.at(e.key, 9, 10);
        final JobRun<KrOrderOpenReport> open = await rig.jobs.runOpen();
        expect(open.status, JobStatus.success, reason: e.key.yyyyMmDd);
        expect(open.check, 'live-auto-kr_order');
        final List<ExecutionOutcome> outs = open.report!.batch!.outcomes;
        expect(outs, isNotEmpty);
        for (final ExecutionOutcome o in outs) {
          expect(o.status, e.value.$2, reason: e.key.yyyyMmDd);
          if (e.value.$3 != null) expect(o.message, e.value.$3);
        }
      }
      expect(rig.broker.submitCount, 0);
      expect(rig.broker.submitted, isEmpty);

      // ④ 관찰 판정 — 회차(잡 기록 그대로) + 그날 대사(일치).
      final DateTime since = _kst(_d1, 8, 0);
      final LiveObservationFacts facts = LiveObservationFacts(
        asOfUtc: _kst(_d2, 18, 0),
        runMode: RunMode.live,
        execPolicy: ExecPolicy.dryRun,
        currentSinceUtc: since,
        runs: <LiveObservationRun>[
          for (final JobRunEntry r in rig.runLog.entries)
            LiveObservationRun(
              r.sessionDay.yyyyMmDd,
              r.startedAtUtc,
              succeeded: r.status == JobRunStatus.success,
            ),
        ],
        recons: <LiveObservationRecon>[
          LiveObservationRecon(_kst(_d1, 9, 11), matched: true),
          LiveObservationRecon(_kst(_d2, 9, 11), matched: true),
        ],
        unknownOrders: 0,
        killSwitchActive: false,
        blockingFlags: const <String>[],
      );
      final LiveObservationReport report = judgeLiveObservation(
        facts,
        kr: frozenExchangeCalendar(Market.kr),
        config: LiveObservationConfig(requiredTradingDays: 2),
      );
      expect(report.observedTradingDays, 2);
      expect(report.promotionAvailable, isTrue);

      // ⑤ 승격 판정 — 실전 리스 모름(E11k 전) = 막힘 · 유효 = 통과.
      String? promote(LeaseVerdict lease) => livePromotionReject(
        biometricConfirmed: true,
        sessionValid: null,
        runMode: RunMode.live,
        execPolicy: ExecPolicy.dryRun,
        operatingMode: OperatingMode.autoTrade,
        currentSinceUtc: since,
        nowUtc: _kst(_d2, 18, 0),
        lease: lease,
        report: report,
      );
      expect(promote(LeaseVerdict.unknown), 'LEASE_INVALID');
      expect(promote(LeaseVerdict.valid), isNull);
      expect(rig.broker.submitCount, 0);
    });
  });
}
