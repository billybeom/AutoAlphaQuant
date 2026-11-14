// 주문 잡 실물(E11p3c-3 · 설계 13 §8 R101 · R42 S4~S6 · R71 · R74 · R77 · R81) — `kr_order` · `kr_order_close` · `daily_reconcile`.
//
// 🔴 본체 = trading_runtime `KrOrderJobs` 그대로 — 잡 규약(핑 · 휴장 · 모드 가드 · 잡 앞 재개 가드 · `job_run`)을 **본체가 감싼다**.
//    여기서 `runOccurrence` 로 다시 감싸지 않는다(기록 두 번 · 핑 두 번).
// 🔴 이번 조각 = simInternal × 자동 매매만 — 브로커 = 계좌마다 가상 체결(`SimInternalBroker`) · 리스 = 로컬 단독(R71 · simInternal 만 유효).
//    simBroker · live(KIS 계좌 · 원격 리스) · 투자 안내(안내 받는 쪽) = `JobNotAssembled`(조용히 다른 길로 돌지 않는다).
// 🔴 잡 앞 재개 가드 = `ResumeJob.run`(R77 S2) — 재판정은 월말 본체(c2 와 같은 조립)로.
// 🔴 본체는 «오늘(KST)» 로 돈다(R42) — 회차의 세션일이 오늘이 아니면 돌리지 않고 그 회차를 실패로 남긴다(지난 날 주문을 오늘 내지 않는다).
// 🔴 초안 시세 · 한도 현재가 = KIS 국내 현재가(모드 세트) — **쓸 때** 만든다(낼 주문이 없으면 KIS 키를 요구하지 않는다).

import 'package:broker_gateway/broker_gateway.dart'
    show KisPrice, KisPriceFetch, kisCurrentPrice;
import 'package:core_engine/core_engine.dart'
    show
        AccountBroker,
        CompositeTargetSource,
        LimitInputsCollector,
        P0sOpsConfig,
        ResumeLadder,
        TargetSource;
import 'package:data_sync/data_sync.dart'
    show
        ResumeJob,
        SeasonalTargetSource,
        SqliteLeaseGate,
        SqliteLimitLedgerFacts,
        SqliteModeFacts,
        SqliteOrderLedger,
        SqlitePlannedWorkStore,
        SqliteResumeReevaluator,
        StoredPlanTargetSource;
import 'package:domain_contracts/domain_contracts.dart'
    show OperatingMode, TradeDate;
import 'package:trading_runtime/trading_runtime.dart'
    show
        JobBody,
        JobOccurrence,
        JobRun,
        KisDraftQuotes,
        KrOrderConfig,
        KrOrderJobs,
        kstDateOf;

import 'data_job_runners.dart' show JobParts;
import 'job_runners.dart'
    show JobContext, JobNotAssembled, JobRunner, runOccurrence;
import 'ledger_job_runners.dart'
    show cashBrokersOf, monthlyRebalanceJobOf, opsConfigOf;

/// 회차 세션일이 오늘(KST)이 아니다 — 주문 잡은 오늘로만 돈다.
class OrderJobNotToday implements Exception {
  /// 만든다.
  const OrderJobNotToday(this.job, this.sessionDay, this.today);

  /// 잡.
  final String job;

  /// 회차 세션일 · 오늘.
  final TradeDate sessionDay, today;

  @override
  String toString() =>
      'OrderJobNotToday: $job 회차 ${sessionDay.yyyyMmDd} ≠ 오늘 ${today.yyyyMmDd}';
}

/// 🔴 주문 잡 묶음을 조립한다 — 설정(사람 값) · 모드 · 운영 방식이 맞지 않으면 던진다.
KrOrderJobs orderJobsOf(JobContext c, JobParts p, String job) {
  switch (c.operatingMode) {
    case OperatingMode.autoTrade:
      break;
    case OperatingMode.advisory:
      throw JobNotAssembled(job, const <String>['advice_sink']);
  }
  final P0sOpsConfig cfg = opsConfigOf(c);
  final Map<String, AccountBroker> brokers = cashBrokersOf(c, p, cfg, job);
  final SqliteOrderLedger ledger = SqliteOrderLedger(
    c.db,
    mode: c.runMode,
    clock: c.clock,
    kr: c.calendars.kr,
  );
  final SqliteLeaseGate lease = SqliteLeaseGate(
    c.db,
    mode: c.runMode,
    clock: c.clock,
  );
  // 현재가는 쓸 때 만든다 — 낼 주문이 없으면 KIS 키가 없어도 잡이 돈다.
  Future<KisPriceFetch>? fetch;
  Future<KisPrice> price(String code) async =>
      (await (fetch ??= p.priceFetch(c.runMode)))(code);
  final LimitInputsCollector limits = LimitInputsCollector(
    holdings: ledger.krHoldings,
    cash: brokers,
    price: kisCurrentPrice(price),
    riskSymbols: cfg.riskSymbols,
    ledger: SqliteLimitLedgerFacts(c.db),
  );
  final ResumeJob resume = ResumeJob(
    c.db,
    runMode: c.runMode,
    operatingMode: c.operatingMode,
    kr: c.calendars.kr,
    clock: c.clock,
    ledger: ledger,
    brokers: brokers,
    accountByStrategy: cfg.human.accountByStrategy,
    lease: lease,
    reevaluator: SqliteResumeReevaluator(
      c.db,
      monthly: monthlyRebalanceJobOf(c, cfg, brokers),
      carry: ledger,
    ),
    ladder: ResumeLadder.defaults,
  );
  return KrOrderJobs(
    ledger: ledger,
    brokers: brokers,
    kr: c.calendars.kr,
    config: KrOrderConfig(
      runMode: c.runMode,
      operatingMode: c.operatingMode,
      execPolicy: c.execPolicy,
      draft: cfg.draft,
      limits: cfg.limits,
      buyCostRate: cfg.buyCostRate,
      configHash: cfg.configHash,
      fillCosts: cfg.fillCosts,
      instruments: cfg.instruments,
    ),
    targets: CompositeTargetSource(<TargetSource>[
      StoredPlanTargetSource(c.db),
      SeasonalTargetSource(c.db, ledger: ledger),
    ]),
    quotes: KisDraftQuotes(price),
    limitStateFor: limits.stateFor,
    heartbeat: c.heartbeat,
    alerts: c.alerts,
    nowUtc: c.clock.nowUtc,
    lease: lease,
    runLog: c.runLog,
    plannedWork: SqlitePlannedWorkStore(c.db, carry: ledger, clock: c.clock),
    modeFacts: SqliteModeFacts(
      c.db,
      clock: c.clock,
      liveKeysVerified: () async => false,
    ),
    preGuard: (TradeDate day) async {
      await resume.run(day);
    },
  );
}

/// 🔴 회차 → 본체 하나 — 조립 실패 · 오늘 아님은 그 회차를 실패로 남긴다(같은 체크 이름 · `job_run`).
JobRunner _orderRunner(
  JobContext c,
  JobParts p,
  String job,
  Future<JobRun<Object?>> Function(KrOrderJobs jobs) body,
) => (JobOccurrence o) async {
  final TradeDate today = kstDateOf(c.clock.nowUtc());
  final KrOrderJobs jobs;
  try {
    if (o.sessionDay != today) throw OrderJobNotToday(job, o.sessionDay, today);
    jobs = orderJobsOf(c, p, job);
  } on Object catch (e, st) {
    return runOccurrence<Object?>(
      c,
      o,
      (TradeDate _) => Future<JobBody<Object?>>.error(e, st),
    );
  }
  return body(jobs);
};

/// `kr_order`(09:10 KST) — 오전 배치.
JobRunner krOrderRunner(JobContext c, JobParts p) =>
    _orderRunner(c, p, 'kr_order', (KrOrderJobs j) => j.runOpen());

/// `kr_order_close`(장 마감 뒤) — 마감 확인.
JobRunner krOrderCloseRunner(JobContext c, JobParts p) =>
    _orderRunner(c, p, 'kr_order_close', (KrOrderJobs j) => j.runClose());

/// `daily_reconcile`(07:05 KST) — 대사.
JobRunner dailyReconcileRunner(JobContext c, JobParts p) => _orderRunner(
  c,
  p,
  'daily_reconcile',
  (KrOrderJobs j) => j.runDailyReconcile(),
);
