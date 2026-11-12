// `kr_order` 2단계 배치 — 매도 → 예수금 → 매수(예수금 안으로 축소). 04 §3-4 v2.38 · 03 §5-4 v2.38 ·
// 설계 13 §8 R33 D10 · D18 · R35 V8.
//
// 🔴 계좌(= 앱키 = 브로커 한 벌)마다 따로 돈다 — 계좌 사이 이체(연금 납입)는 API 밖이라 그 계좌 예수금만 본다.
// 🔴 매수 축소 = **비례**(수량 × 예수금 ÷ 필요액 · 비용 포함 · 내림) — 한 종목을 통째로 빼지 않고 목표 비중을 지킨다.
//    0주가 된 매수는 내지 않고 부족분으로 보고한다(이월 = E10e · 03 §5-4 v2.38 최대 2세션 더).
// 🔴 한 의도의 결과 불명은 그 의도만 멈춘다 — 배치는 이어 가고, 같은 (시장 · 종목 · 전략)의 다음 의도는 2.5단계가
//    막는다. 알림 코드는 배치당 한 번(04 §5-3 — 발송은 E11).
// 🔴 예수금을 못 읽은 계좌의 매수는 내지 않는다(주문 0 · 원장 행 0 — 다음 배치가 다시 판정한다).
// 🔴 🆕 E10e1 — 계좌마다 첫 주문 앞에 오늘 체결조회로 다음 날 가드를 돈다(지난 날 원주문 = 그 계좌 보류 · 조회 실패도 보류).
// 🔵 체결 기록은 `runFillSync`(fill_sync.dart) · 이월 · 놓친 날(D27)은 E10e2 몫이다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../decimal_rules.dart';
import '../ops/lease_gate.dart' show LeaseGate;
import '../risk/limits.dart';
import 'execute_intent.dart';
import 'fill_sync.dart';
import 'order_draft.dart';
import 'order_ports.dart';

/// 잴 수 없었던 한도 입력 — 전부 null(기본값 금지 · NR-4).
const LimitState _unmeasured = LimitState(
  totalEquity: null,
  ordersToday: null,
  riskExposureAfter: null,
  leverageAfter: null,
  positionsAfter: null,
  satellitePositionsAfter: null,
  satelliteSectorCountAfter: null,
  satelliteAllocation: null,
  satelliteExposure: null,
  satelliteDeployedBefore: null,
  dailyPnlPct: null,
  fxRateUsdKrw: null,
  strategyRegistered: null,
  tradingBlocked: null,
  journalMissing: null,
  tierBUnjudged: null,
);

/// 예수금 맞춤으로 줄어든 매수 하나.
class CashShortfall {
  /// 부족분을 만든다.
  const CashShortfall(this.draft, {required this.fittedQuantity});

  /// 원래 초안.
  final OrderIntentDraft draft;

  /// 맞춘 수량(0 이면 내지 않았다).
  final int fittedQuantity;

  /// 못 낸 수량.
  int get missingQuantity => draft.quantity - fittedQuantity;
}

/// 예수금 맞춤 결과.
class CashFit {
  /// 결과를 만든다.
  const CashFit(this.fitted, this.shortfalls);

  /// 낼 매수(수량 ≥ 1).
  final List<OrderIntentDraft> fitted;

  /// 줄어든 매수(0주 포함).
  final List<CashShortfall> shortfalls;
}

/// 매수 초안을 예수금 안으로 비례 축소한다(R35 V8). 매도가 섞이면 [ArgumentError].
///
/// 필요액 = Σ 수량 × 잰 가격 × (1 + 매수 비용률). 필요액 ≤ 예수금이면 그대로다.
CashFit fitBuysToCash(
  List<OrderIntentDraft> buys,
  Decimal cashKrw,
  double buyCostRate,
) {
  if (buys.any((OrderIntentDraft d) => d.side != OrderSide.buy)) {
    throw ArgumentError.value(buys, 'buys', '매도가 섞였다');
  }
  final Decimal costFactor = Decimal.one + promoteRatio(buyCostRate);
  Decimal unit(OrderIntentDraft d) => multiply(d.sizingPrice, costFactor);
  final Decimal need = buys.fold(
    Decimal.zero,
    (Decimal s, OrderIntentDraft d) =>
        s + multiply(Decimal.fromInt(d.quantity), unit(d)),
  );
  if (need <= cashKrw) {
    return CashFit(List<OrderIntentDraft>.of(buys), const <CashShortfall>[]);
  }

  final List<OrderIntentDraft> fitted = <OrderIntentDraft>[];
  final List<CashShortfall> shortfalls = <CashShortfall>[];
  for (final OrderIntentDraft d in buys) {
    // 곱셈 먼저, 나눗셈 나중(규약 ④) — 수량 × 예수금 ÷ 필요액.
    final int q = cashKrw <= Decimal.zero
        ? 0
        : mulDiv(
            Decimal.fromInt(d.quantity),
            cashKrw,
            need,
          ).floor().toBigInt().toInt();
    if (q >= 1) fitted.add(d.withQuantity(q));
    if (q < d.quantity) shortfalls.add(CashShortfall(d, fittedQuantity: q));
  }
  return CashFit(fitted, shortfalls);
}

/// 배치 결과.
class BatchOutcome {
  /// 결과를 만든다.
  const BatchOutcome({
    required this.outcomes,
    required this.unknowns,
    required this.shortfalls,
    required this.held,
    required this.alertCodes,
  });

  /// 낸(또는 거부 · 건너뜀 · 차단된) 의도의 결과 — 실행 순서.
  final List<ExecutionOutcome> outcomes;

  /// 결과 불명 — 원장에 UNKNOWN(04 §3-3 · P0).
  final List<OrderOutcomeUnknown> unknowns;

  /// 예수금이 모자라 줄인 매수(이월 = E10e).
  final List<CashShortfall> shortfalls;

  /// 내지 않고 보류한 초안과 사유(`BROKER_UNMAPPED` · `CASH_UNAVAILABLE` · 🆕 `STALE_ORDERS` · `STALE_GUARD_UNAVAILABLE`).
  /// 🟡 다음 날 가드의 P1 알림 코드는 다음 계약 창(R33 D11) — 그때까지 이 사유로만 낸다.
  final List<(OrderIntentDraft, String)> held;

  /// 이 배치의 알림 코드(코드마다 한 번 · 발송은 E11).
  final Set<String> alertCodes;
}

/// `kr_order` 2단계(R33 D10 · R35 V8). [brokers] 키 = 계좌 별칭 · [limitStateFor] = 그 초안의 한도 입력(호출자).
Future<BatchOutcome> runOrderBatch(
  List<OrderIntentDraft> drafts, {
  required Map<String, OrderBroker> brokers,
  required OrderLedger ledger,
  required Future<LimitState> Function(OrderIntentDraft draft) limitStateFor,
  required LimitConfig limitConfig,
  required double buyCostRate,
  required ExecPolicy execPolicy,
  required OperatingMode operatingMode,
  required String configHash,
  required LeaseGate lease,
  AdviceSink? advice,
}) async {
  final List<ExecutionOutcome> outcomes = <ExecutionOutcome>[];
  final List<OrderOutcomeUnknown> unknowns = <OrderOutcomeUnknown>[];
  final List<CashShortfall> shortfalls = <CashShortfall>[];
  final List<(OrderIntentDraft, String)> held = <(OrderIntentDraft, String)>[];
  final Set<String> alerts = <String>{};

  final List<String> accounts = <String>{
    for (final OrderIntentDraft d in drafts) d.account,
  }.toList()..sort();
  for (final String account in accounts) {
    final List<OrderIntentDraft> mine = <OrderIntentDraft>[
      for (final OrderIntentDraft d in drafts)
        if (d.account == account) d,
    ];
    final OrderBroker? broker = brokers[account];
    if (broker == null) {
      held.addAll(<(OrderIntentDraft, String)>[
        for (final OrderIntentDraft d in mine) (d, 'BROKER_UNMAPPED'),
      ]);
      continue;
    }
    final ExecutionContext ctx = ExecutionContext(
      ledger: ledger,
      broker: broker,
      limitConfig: limitConfig,
      execPolicy: execPolicy,
      operatingMode: operatingMode,
      configHash: configHash,
      lease: lease,
      advice: advice,
    );
    Future<void> run(OrderIntentDraft d) async {
      // 한도 입력을 못 재면 빈 입력으로 탄다 — 4단계가 RISK_UNAVAILABLE 로 거부한다(fail-closed · 행이 남는다).
      LimitState state;
      try {
        state = await limitStateFor(d);
      } on Object {
        state = _unmeasured;
      }
      try {
        final ExecutionOutcome o = await executeIntent(d, state, ctx);
        outcomes.add(o);
        final String? code = o.alertCode;
        if (code != null) alerts.add(code);
      } on OrderOutcomeUnknown catch (e) {
        unknowns.add(e);
        alerts.add(AlertCodes.orderOutcomeUnknown);
      }
    }

    // 🆕 E10e1 다음 날 가드(04 §3-1 ③ ⑤ · R38 Z8) — 첫 주문 앞에 오늘 체결조회 한 번 · 지난 날 원주문이 보이면 보류.
    final TradeDate today = mine.first.executionDate;
    String? guard;
    try {
      if (staleOrderRows(await broker.dailyFills(today), today).isNotEmpty) {
        guard = 'STALE_ORDERS';
      }
    } on Object {
      guard = 'STALE_GUARD_UNAVAILABLE'; // fail-closed
    }
    if (guard != null) {
      held.addAll(<(OrderIntentDraft, String)>[
        for (final OrderIntentDraft d in mine) (d, guard),
      ]);
      continue;
    }

    // ① 매도 전부.
    for (final OrderIntentDraft d in mine) {
      if (d.side == OrderSide.sell) await run(d);
    }
    // ② 예수금 → ③ 매수(비례 축소).
    final List<OrderIntentDraft> buys = <OrderIntentDraft>[
      for (final OrderIntentDraft d in mine)
        if (d.side == OrderSide.buy) d,
    ];
    if (buys.isEmpty) continue;
    final Decimal cash;
    try {
      cash = await broker.orderableCashKrw();
    } on Object {
      held.addAll(<(OrderIntentDraft, String)>[
        for (final OrderIntentDraft d in buys) (d, 'CASH_UNAVAILABLE'),
      ]);
      continue;
    }
    final CashFit fit = fitBuysToCash(buys, cash, buyCostRate);
    shortfalls.addAll(fit.shortfalls);
    for (final OrderIntentDraft d in fit.fitted) {
      await run(d);
    }
  }
  return BatchOutcome(
    outcomes: outcomes,
    unknowns: unknowns,
    shortfalls: shortfalls,
    held: held,
    alertCodes: alerts,
  );
}
