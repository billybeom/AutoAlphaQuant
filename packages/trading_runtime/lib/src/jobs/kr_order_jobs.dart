// 주문 잡 — `kr_order`(오전 09:10 · 마감 15:40 뒤) · `daily_reconcile`(07:00)(설계 13 §8 R42 S4~S7 · 00_SPEC 잡 표 v2.38 ·
// 01 §10 · 04 §4-2 · §3-5).
//
// 🔴 오전 순서 = 09:05~15:00 안에서만 · UNKNOWN 해소 → 앞 세션 실효 이월 + 오늘 대상 → 초안 → 배치 → 배치 직후 대사.
//    15:00 뒤면 내지 않고 «다음 거래일»(00_SPEC v2.38) · 09:05 앞이면 실패(알람 설정 오류 — LP 호가 공백).
// 🔴 마감 = UNKNOWN 해소 → 일 마감 체결 동기화(15:40 뒤 — core 가 막는다). 이월은 다음 오전이 앞 세션 EXPIRED 로 정한다.
// 🔴 대사 · 순서기의 안전 판정은 core 가 한다 — 잡은 순서와 시각과 보고만 정한다(규칙을 다시 만들지 않는다).
// 🔵 대상 생성(월말 계획 → 대상 · 계절 분할 몫)은 [TargetSource] 너머다(이 판 밖 · R42 S9).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'job_contract.dart';

/// 잡 이름(01 §10 · 04 §5-2).
abstract final class KrJobs {
  /// 오전 배치.
  static const String order = 'kr_order';

  /// 일 마감 확인(🟡 04 §5-2 표의 행 = 다음 SPEC 창 · R42 S5).
  static const String orderClose = 'kr_order_close';

  /// 장 시작 전 대사.
  static const String reconcile = 'daily_reconcile';
}

/// 발주 창 시작(KST) — 09:05 앞은 LP 호가 공백(03 §5-5 · 00_SPEC v2.38 09:10 시작).
const Duration kKrOrderEarliestKst = Duration(hours: 9, minutes: 5);

/// 발주 상한(KST) — 이 뒤면 그날은 내지 않는다(00_SPEC v2.38).
const Duration kKrOrderCutoffKst = Duration(hours: 15);

/// 오늘의 주문 대상(월말 계획 · 계절 분할 몫) — 이월은 잡이 더한다.
abstract interface class TargetSource {
  /// [today] 집행 대상.
  Future<List<OrderTarget>> targetsFor(TradeDate today);
}

/// 초안 시세(기준가 · 호가 · 상하한).
abstract interface class DraftQuoteSource {
  /// [symbols] 의 시세 — 없는 종목은 초안기가 사유로 남긴다.
  Future<Map<String, DraftQuote>> quotesFor(Set<String> symbols);
}

/// 주문 잡 설정.
class KrOrderConfig {
  /// 설정을 만든다.
  const KrOrderConfig({
    required this.runMode,
    required this.operatingMode,
    required this.execPolicy,
    required this.draft,
    required this.limits,
    required this.buyCostRate,
    required this.configHash,
    required this.fillCosts,
    this.instruments = const <String, InstrumentKind>{},
    this.recheckDelay = kReconRecheckDelay,
  });

  /// 체크 이름 접두 축.
  final RunMode runMode;

  /// 체크 이름 접두 축 · 순서기 분기.
  final OperatingMode operatingMode;

  /// DRY_RUN · 집행.
  final ExecPolicy execPolicy;

  /// 지정가 오프셋 · 매수 비용 · 전략 → 계좌.
  final DraftConfig draft;

  /// 02 §4 한도.
  final LimitConfig limits;

  /// 예수금 축소의 매수 비용률.
  final double buyCostRate;

  /// config_hash.
  final String configHash;

  /// 체결 비용 추정.
  final FillCostRates fillCosts;

  /// 이월 대상의 상품 구분(없으면 개별주 — fail-closed).
  final Map<String, InstrumentKind> instruments;

  /// 재대사 전 기다림.
  final Duration recheckDelay;
}

/// 오전 배치 보고.
class KrOrderOpenReport {
  /// 보고를 만든다.
  const KrOrderOpenReport({
    required this.skippedReason,
    this.unknowns,
    this.carry,
    this.targets = const <OrderTarget>[],
    this.draftIssues = const <DraftIssue>[],
    this.batch,
    this.recon,
  });

  /// 발주하지 않은 까닭(15:00 뒤) — 냈으면 null.
  final String? skippedReason;

  /// UNKNOWN 해소.
  final UnknownResolutionReport? unknowns;

  /// 앞 세션 실효의 이월 계획.
  final CarryPlan? carry;

  /// 초안기에 넣은 대상(오늘 대상 + 이월).
  final List<OrderTarget> targets;

  /// 초안 사유.
  final List<DraftIssue> draftIssues;

  /// 배치 결과.
  final BatchOutcome? batch;

  /// 배치 직후 대사.
  final ReconReport? recon;
}

/// 마감 확인 보고.
class KrOrderCloseReport {
  /// 보고를 만든다.
  const KrOrderCloseReport({required this.unknowns, required this.fills});

  /// UNKNOWN 해소.
  final UnknownResolutionReport unknowns;

  /// 일 마감 체결 동기화.
  final FillSyncReport fills;
}

/// 주문 잡 묶음(R42 S4~S6) — 조립 앱이 원장 · 브로커 · 포트를 넣는다.
class KrOrderJobs {
  /// 잡을 만든다. [brokers] = 계좌 별칭 → 브로커(바꿔 끼울 수 있게 그대로 쓴다).
  KrOrderJobs({
    required this.ledger,
    required this.brokers,
    required this.kr,
    required this.config,
    required this.targets,
    required this.quotes,
    required this.limitStateFor,
    required this.heartbeat,
    required this.alerts,
    required this.nowUtc,
    Future<void> Function(Duration)? sleep,
    this.advice,
  }) : sleep = sleep ?? Future<void>.delayed;

  /// 주문 경로 원장.
  final OrderPathLedger ledger;

  /// 계좌 → 브로커.
  final Map<String, AccountBroker> brokers;

  /// KR 거래소 달력(동결 XKRX).
  final ExchangeCalendar kr;

  /// 설정.
  final KrOrderConfig config;

  /// 오늘 대상.
  final TargetSource targets;

  /// 초안 시세.
  final DraftQuoteSource quotes;

  /// 4단계 한도 입력.
  final Future<LimitState> Function(OrderIntentDraft draft) limitStateFor;

  /// 하트비트.
  final JobHeartbeat heartbeat;

  /// 알림.
  final AlertSink alerts;

  /// 시계.
  final DateTime Function() nowUtc;

  /// 재대사 잠.
  final Future<void> Function(Duration) sleep;

  /// 안내 모드 받는 쪽.
  final AdviceSink? advice;

  /// [job] 의 체크 이름.
  String checkOf(String job) =>
      watchdogCheckName(config.runMode, config.operatingMode, job);

  Future<JobRun<T>> _run<T>(
    String job,
    Future<JobBody<T>> Function(TradeDate today) body,
  ) => runJob<T>(
    check: checkOf(job),
    heartbeat: heartbeat,
    alerts: alerts,
    calendar: kr,
    nowUtc: nowUtc(),
    body: body,
  );

  Future<ReconReport> _reconcile(TradeDate today) => runReconciliation(
    ledger: ledger,
    brokers: brokers,
    balances: brokers,
    accountByStrategy: config.draft.accountByStrategy,
    tradeDate: today,
    nowUtc: nowUtc,
    recheckDelay: config.recheckDelay,
    sleep: sleep,
  );

  /// 오전 배치(09:10 · R42 S4).
  Future<JobRun<KrOrderOpenReport>>
  runOpen() => _run<KrOrderOpenReport>(KrJobs.order, (TradeDate today) async {
    final DateTime now = nowUtc();
    final Duration at = kstTimeOfDay(now);
    if (at < kKrOrderEarliestKst) {
      throw StateError('kr_order 는 09:05 KST 앞에 내지 않는다(LP 호가 공백) — 알람 설정을 본다');
    }
    if (at >= kKrOrderCutoffKst) {
      const String why = '발주 상한 15:00 지남 — 오늘은 내지 않고 다음 거래일';
      return const JobBody<KrOrderOpenReport>(
        KrOrderOpenReport(skippedReason: why),
        note: why,
      );
    }
    final UnknownResolutionReport unknowns = await resolveUnknownOrders(
      ledger: ledger,
      brokers: brokers,
      nowUtc: now,
    );
    final CarryPlan carry = planCarryOver(
      await ledger.expiredIntents(kr.nthSessionBefore(today, 1)),
      instruments: config.instruments,
    );
    final List<OrderTarget> all = <OrderTarget>[
      ...await targets.targetsFor(today),
      ...carry.targets,
    ];
    final Map<(String, String), int> holdings = <(String, String), int>{
      for (final LedgerHolding h in await ledger.krHoldings())
        (h.strategyId, h.symbol): h.quantity,
    };
    final Set<String> symbols = <String>{
      for (final OrderTarget t in all) t.symbol,
    };
    final DraftResult draft = draftOrders(
      all,
      executionDate: today,
      quotes: symbols.isEmpty
          ? const <String, DraftQuote>{}
          : await quotes.quotesFor(symbols),
      holdings: holdings,
      config: config.draft,
    );
    final BatchOutcome batch = await runOrderBatch(
      draft.drafts,
      brokers: brokers,
      ledger: ledger,
      limitStateFor: limitStateFor,
      limitConfig: config.limits,
      buyCostRate: config.buyCostRate,
      execPolicy: config.execPolicy,
      operatingMode: config.operatingMode,
      configHash: config.configHash,
      advice: advice,
    );
    final ReconReport recon = await _reconcile(today);
    return JobBody<KrOrderOpenReport>(
      KrOrderOpenReport(
        skippedReason: null,
        unknowns: unknowns,
        carry: carry,
        targets: all,
        draftIssues: draft.issues,
        batch: batch,
        recon: recon,
      ),
      alerts: <String>{
        ...batch.alertCodes,
        ...recon.alertCodes,
        if (unknowns.ambiguous.isNotEmpty) AlertCodes.orderOutcomeUnknown,
      },
      note:
          '초안 ${draft.drafts.length} · 이월 ${carry.targets.length} · 버림 ${carry.dropped.length} · 대사 ${recon.action.code}',
    );
  });

  /// 일 마감 확인(15:40 뒤 · R42 S5).
  Future<JobRun<KrOrderCloseReport>>
  runClose() => _run<KrOrderCloseReport>(KrJobs.orderClose, (
    TradeDate today,
  ) async {
    final DateTime now = nowUtc();
    final UnknownResolutionReport unknowns = await resolveUnknownOrders(
      ledger: ledger,
      brokers: brokers,
      nowUtc: now,
    );
    final FillSyncReport fills = await runFillSync(
      ledger: ledger,
      brokers: brokers,
      tradeDate: today,
      nowUtc: now,
      dayEnd: true,
      costs: config.fillCosts,
    );
    return JobBody<KrOrderCloseReport>(
      KrOrderCloseReport(unknowns: unknowns, fills: fills),
      alerts: <String>{
        if (fills.unresolved.isNotEmpty || unknowns.ambiguous.isNotEmpty)
          AlertCodes.orderOutcomeUnknown,
      },
      note:
          '체결 반영 ${fills.applied.length} · 실효 ${fills.expired.length} · 미해소 ${fills.unresolved.length}',
    );
  });

  /// 장 시작 전 대사(07:00 · R42 S6).
  Future<JobRun<ReconReport>> runDailyReconcile() =>
      _run<ReconReport>(KrJobs.reconcile, (TradeDate today) async {
        final ReconReport r = await _reconcile(today);
        return JobBody<ReconReport>(
          r,
          alerts: r.alertCodes,
          note: '대사 ${r.action.code}',
        );
      });
}
