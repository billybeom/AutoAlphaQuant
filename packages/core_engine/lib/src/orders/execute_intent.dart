// NR-1 순서기 — 주문 실행의 유일한 진입점. `06_시스템설계/04_안전장치.md` §3-1 · §3-3 · §1(상태 표) ·
// 01 §6 `execute_intent` · 설계 13 §8 R33 D21 · D22 · D24 · D25 · R35 V5~V7.
//
// 🔴 순서의 정본은 04 §3-1 이다:
//    1 킬스위치 → 2 차단 묶음(매수면 SAF-408 · 410 판정을 먼저 갱신) → 2.5 미해소 UNKNOWN → 3 전략 상태 → 4 리스크 한도 → 5 주문유형 화이트리스트 →
//    6 INSERT(RESERVED) → 6.5 COMMIT(INSERT 가 돌아오면 커밋됨 — 포트 계약) → [안내 모드 = 여기서 안내로 · DRY_RUN = SKIPPED] →
//    7 SUBMITTING → 8 제출 → 9 SUBMITTED | REJECTED | UNKNOWN(+ OrderOutcomeUnknown 다시 던짐).
// 🔴 1~5단계 거부도 그 멱등키로 REJECTED 행을 남긴다(D21 — 감사 · 같은 날 같은 결정은 다시 낼 수 없다).
// 🔴 fail-closed — 원장을 읽지 못하면 RISK_UNAVAILABLE 로 거부한다. 기본값을 채우지 않는다(NR-4).
// 🔴 결과 불명 뒤에는 브로커를 다시 부르지 않는다(NR-2). 브로커가 응답한 뒤 기록이 실패해도 UNKNOWN 이다
//    (04 §3-3 «DB 기록 실패» — DB 쓰기 재시도는 허용 · 브로커 재호출은 금지).

import 'package:domain_contracts/domain_contracts.dart';

import '../risk/limits.dart';
import 'block_bundles.dart';
import 'fills.dart';
import 'order_draft.dart';
import 'order_ports.dart';

/// 실행 결과 상태(결과 불명은 [OrderOutcomeUnknown] 예외).
enum ExecutionStatus {
  /// 접수(9단계).
  submitted('SUBMITTED'),

  /// 거부(1~5단계 · 브로커 거절).
  rejected('REJECTED'),

  /// DRY_RUN · 축소 0주.
  skipped('SKIPPED'),

  /// 같은 멱등키가 이미 있다 — 🔴 실패가 아니라 이중 발주 차단(NR-1 이 작동한 것 · D24 — 행 없음).
  prevented('PREVENTED'),

  /// 안내 모드 — 안내로 넘겼다(브로커 호출 0).
  advised('ADVISED');

  const ExecutionStatus(this.code);

  /// 기록 표기.
  final String code;
}

/// 실행 결과(R35 V7). 알림 발송은 E11 — 여기는 제안 코드만 싣는다.
class ExecutionOutcome {
  /// 결과를 만든다.
  const ExecutionOutcome(
    this.status, {
    required this.intentId,
    required this.message,
    this.quantity,
    this.brokerOrderNo,
    this.alertCode,
    this.alert = false,
  });

  /// 상태.
  final ExecutionStatus status;

  /// 의도 id.
  final String intentId;

  /// 사유(04 §1 v1.5 표 꼴 — 접수면 `SUBMITTED`).
  final String message;

  /// 원장에 쓴 수량(축소 반영 · PREVENTED 면 null).
  final int? quantity;

  /// 접수면 `{주문일}:{ODNO}`.
  final String? brokerOrderNo;

  /// 제안 알림 코드(`AlertCodes`) — 거절 = `ORDER_REJECTED`(P1).
  final String? alertCode;

  /// 🔴 ALERT 를 동반해야 하는 거부(SAF-207 게이트 닫힘 — 04 §1-5 v2.23).
  final bool alert;

  @override
  String toString() => '${status.code} $intentId $message';
}

/// 순서기 문맥 — 원장 · 브로커 · 설정 · 모드.
class ExecutionContext {
  /// 문맥을 만든다.
  const ExecutionContext({
    required this.ledger,
    required this.broker,
    required this.limitConfig,
    required this.execPolicy,
    required this.operatingMode,
    required this.configHash,
    this.advice,
  });

  /// 원장.
  final OrderLedger ledger;

  /// 그 초안 계좌의 브로커.
  final OrderBroker broker;

  /// 한도 설정.
  final LimitConfig limitConfig;

  /// DRY_RUN · EXECUTE(🔴 DRY_RUN 이면 브로커 호출 0).
  final ExecPolicy execPolicy;

  /// 자동 · 안내.
  final OperatingMode operatingMode;

  /// config_hash.
  final String configHash;

  /// 안내 모드의 받는 쪽(안내 모드면 필수).
  final AdviceSink? advice;
}

/// 원장 읽기 실패 — 거부로 바꾼다(fail-closed).
class _LedgerUnavailable implements Exception {
  const _LedgerUnavailable(this.cause);
  final Object cause;
}

Future<T> _read<T>(Future<T> Function() read) async {
  try {
    return await read();
  } on Object catch (e) {
    throw _LedgerUnavailable(e);
  }
}

/// NR-1 1~9(04 §3-1). [portfolio] = 호출자가 잰 그 초안의 한도 입력 — 원장 값(orders_today · 전략 등록 ·
/// 매수의 408 · 410 SQL)은 여기서 덮는다. [steps] 를 넘기면 들어선 단계를 순서대로 덧붙인다(시험 관측면).
Future<ExecutionOutcome> executeIntent(
  OrderIntentDraft draft,
  LimitState portfolio,
  ExecutionContext ctx, {
  List<String>? steps,
}) async {
  final List<String> trail = steps ?? <String>[];
  final OrderLedger ledger = ctx.ledger;
  final bool isBuy = draft.side == OrderSide.buy;
  final bool advisory = ctx.operatingMode == OperatingMode.advisory;
  final String intentId = intentIdFor(draft.idempotencyKey);
  if (advisory && ctx.advice == null) {
    throw ArgumentError.value(ctx.advice, 'advice', '안내 모드인데 받는 쪽이 없다');
  }

  IntentRow row(IntentStatus status, {String? message, int? quantity}) =>
      IntentRow.fromDraft(
        draft,
        status: status,
        configHash: ctx.configHash,
        execPolicy: ctx.execPolicy,
        operatingMode: ctx.operatingMode,
        errorMessage: message,
        quantity: quantity,
      );

  ExecutionOutcome prevented() => ExecutionOutcome(
    ExecutionStatus.prevented,
    intentId: intentId,
    message: 'PREVENTED: 같은 멱등키가 이미 있다',
  );

  // 1~5단계 거부 — 그 키로 REJECTED 행(D21). 이미 행이 있으면 그 행이 이긴다(PREVENTED).
  Future<ExecutionOutcome> reject(String message, {bool alert = false}) async {
    if (!await ledger.insertIntent(
      row(IntentStatus.rejected, message: message),
    )) {
      return prevented();
    }
    return ExecutionOutcome(
      ExecutionStatus.rejected,
      intentId: intentId,
      message: message,
      quantity: draft.quantity,
      alertCode: AlertCodes.orderRejected,
      alert: alert,
    );
  }

  final int quantity;
  try {
    trail.add('1');
    if (await _read(ledger.killSwitchActive)) {
      return await reject('KILL_SWITCH');
    }

    trail.add('2');
    // 🔴 04 §1 v2.15 SF-01 — 매수면 SAF-408 · 410 판정 SQL 을 **먼저** 돌린다(플래그 자동 설정 · 해제 → 반환값).
    //    플래그를 먼저 읽으면 한 번 선 JOURNAL_MISSING · TIER_B_UNJUDGED 가 해제에 닿지 못한다(설계 13 §8 R36 W9).
    final bool? journalMissing = isBuy
        ? await _read(ledger.journalMissing)
        : null;
    final bool? tierBUnjudged = isBuy
        ? await _read(() => ledger.tierBUnjudged(draft.executionDate))
        : null;
    final List<String> blocked = blockingFlagsFor(
      await _read(ledger.activeBlockFlags),
      isBuy: isBuy,
      advisory: advisory,
    );
    if (blocked.isNotEmpty) {
      return await reject('SAF-407: ${blocked.join(',')}');
    }

    trail.add('2.5');
    if (await _read(
      () => ledger.hasUnresolvedUnknown(
        draft.market,
        draft.symbol,
        draft.strategyId,
      ),
    )) {
      return await reject('UNKNOWN_UNRESOLVED: 미해소 UNKNOWN 의도가 있다');
    }

    trail.add('3');
    if (!await _read(() => ledger.strategyRegistered(draft.strategyId))) {
      return await reject('SAF-406: 전략 상태가 등록돼 있지 않다');
    }

    trail.add('4');
    final LimitState state = LimitState(
      totalEquity: portfolio.totalEquity,
      ordersToday: await _read(() => ledger.ordersToday(draft.executionDate)),
      riskExposureAfter: portfolio.riskExposureAfter,
      leverageAfter: portfolio.leverageAfter,
      positionsAfter: portfolio.positionsAfter,
      satellitePositionsAfter: portfolio.satellitePositionsAfter,
      satelliteSectorCountAfter: portfolio.satelliteSectorCountAfter,
      satelliteAllocation: portfolio.satelliteAllocation,
      satelliteExposure: portfolio.satelliteExposure,
      satelliteDeployedBefore: portfolio.satelliteDeployedBefore,
      dailyPnlPct: portfolio.dailyPnlPct,
      fxRateUsdKrw: portfolio.fxRateUsdKrw,
      strategyRegistered: true, // 3단계를 지났다
      tradingBlocked: false, // 2단계가 전 주문 차단 묶음을 이미 걸렀다
      journalMissing: journalMissing, // 2단계 앞 판정의 반환값(매수만)
      tierBUnjudged: tierBUnjudged,
    );
    final LimitCheckResult limit;
    try {
      limit = checkAllLimits(draft.toLimitIntent(), state, ctx.limitConfig);
    } on RiskCheckUnavailable catch (e) {
      return await reject('RISK_UNAVAILABLE: ${e.message}');
    }
    switch (limit.status) {
      case LimitStatus.rejected:
        return await reject(
          '${limit.violated.join(',')}: 한도 위반',
          alert: limit.alert,
        );
      case LimitStatus.skipped:
        // P5 — 축소 후 0주(04 §1 표 «수량 0 등 사전 검증 탈락» = SKIPPED).
        final String message = 'SAF-104: 축소 후 0주(${limit.violated.join(',')})';
        if (!await ledger.insertIntent(
          row(IntentStatus.skipped, message: message),
        )) {
          return prevented();
        }
        return ExecutionOutcome(
          ExecutionStatus.skipped,
          intentId: intentId,
          message: message,
          quantity: draft.quantity,
        );
      case LimitStatus.allow:
        quantity = limit.adjustedQuantity!;
    }

    trail.add('5');
    if (!ctx.limitConfig.orderTypeWhitelist.contains(draft.orderType)) {
      return await reject('SAF-404: 화이트리스트 밖 주문유형 ${draft.orderType}');
    }
  } on _LedgerUnavailable catch (e) {
    return reject('RISK_UNAVAILABLE: 원장 확인 불가 — ${e.cause}');
  }

  trail.add('6');
  final IntentRow reserved = row(IntentStatus.reserved, quantity: quantity);
  if (!await ledger.insertIntent(reserved)) return prevented();
  trail.add('6.5'); // 포트 계약 — INSERT 가 돌아오면 커밋됐다.

  if (advisory) {
    // 04 §3-1 ② — 안내는 자동 모드가 냈을 주문 그대로(1~6 을 다 지난 뒤).
    await ctx.advice!.publish(reserved);
    return ExecutionOutcome(
      ExecutionStatus.advised,
      intentId: intentId,
      message: 'ADVISED',
      quantity: quantity,
    );
  }
  if (ctx.execPolicy == ExecPolicy.dryRun) {
    await ledger.markSkipped(intentId, 'DRY_RUN');
    return ExecutionOutcome(
      ExecutionStatus.skipped,
      intentId: intentId,
      message: 'DRY_RUN',
      quantity: quantity,
    );
  }

  trail.add('7');
  await ledger.markSubmitting(intentId);

  trail.add('8');
  final BrokerSubmitResult result;
  try {
    result = await ctx.broker.submit(
      BrokerOrderRequest(
        symbol: draft.symbol,
        side: draft.side,
        quantity: quantity,
        orderType: draft.orderType,
        limitPrice: draft.limitPrice,
      ),
    );
  } on Object catch (e) {
    // 🔴 OrderOutcomeUnknown 이든 그 밖의 예외든 나갔는지 모른다 — 다시 보내지 않는다.
    throw await _unknown(ledger, intentId, '제출 결과 불명 — $e');
  }

  trail.add('9');
  switch (result) {
    case BrokerAccepted(:final String odno, :final TradeDate orderDate):
      final String brokerOrderNo;
      try {
        brokerOrderNo = brokerOrderNoOf(orderDate, odno);
        await ledger.markSubmitted(intentId, brokerOrderNo);
      } on Object catch (e) {
        throw await _unknown(ledger, intentId, '접수 응답 기록 실패 — $e');
      }
      return ExecutionOutcome(
        ExecutionStatus.submitted,
        intentId: intentId,
        message: 'SUBMITTED',
        quantity: quantity,
        brokerOrderNo: brokerOrderNo,
      );
    case BrokerRejected(:final String code, :final String message):
      final String text = '$code: $message';
      try {
        await ledger.markBrokerRejected(intentId, text);
      } on Object catch (e) {
        throw await _unknown(ledger, intentId, '거절 응답 기록 실패($text) — $e');
      }
      return ExecutionOutcome(
        ExecutionStatus.rejected,
        intentId: intentId,
        message: text,
        quantity: quantity,
        alertCode: AlertCodes.orderRejected,
      );
  }
}

/// UNKNOWN 으로 기록한다(실패하면 한 번 더 — 04 §3-3 «DB 쓰기 재시도는 허용») · 브로커는 다시 부르지 않는다.
Future<OrderOutcomeUnknown> _unknown(
  OrderLedger ledger,
  String intentId,
  String message,
) async {
  Object? last;
  for (int attempt = 0; attempt < 2; attempt++) {
    try {
      await ledger.markUnknown(intentId, message);
      return OrderOutcomeUnknown(message, intentId: intentId);
    } on Object catch (e) {
      last = e;
    }
  }
  return OrderOutcomeUnknown(
    '$message · 🔴 UNKNOWN 기록도 실패 — $last',
    intentId: intentId,
  );
}
