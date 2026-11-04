// 킬스위치 발동 순서기(SPEC v2.40 04 §3-6 · v2.14 · 설계 13 §8 R56 K6).
//
// 🔴 순서 = ① 차단 기록 먼저 ② 미체결 취소 시도 ③ 건별 보고 — ②③ 이 실패해도 ① 은 그대로다(fail-closed).
// 🔴 취소 = 오늘의 `SUBMITTED` · `PARTIAL` 중 잔량 > 0 ∧ 주문번호 있음 · `UNKNOWN` 은 취소하지 않는다(결과 불명에 새 호출 금지 — NR-2).
// 🔴 재시도 0 · 결과 불명 = «불명»으로 보고 · 보고에 금액을 싣지 않는다.

import 'dart:convert';

import '../orders/order_ports.dart'
    show
        BrokerAccepted,
        BrokerRejected,
        BrokerSubmitResult,
        IntentStatus,
        OrderBroker,
        OrderOutcomeUnknown;
import 'kill_switch.dart';

/// 취소 후보 — 오늘의 의도 한 건과 브로커 원주문 잔량.
class KillCancelCandidate {
  /// 후보를 만든다.
  const KillCancelCandidate({
    required this.intentId,
    required this.account,
    required this.symbol,
    required this.status,
    required this.brokerOrderNo,
    required this.remainingQty,
  });

  /// 의도 id.
  final String intentId;

  /// 계좌 별칭.
  final String account;

  /// 종목.
  final String symbol;

  /// 의도 상태.
  final IntentStatus status;

  /// 브로커 주문번호(`{주문일}:{ODNO}` · 없으면 null).
  final String? brokerOrderNo;

  /// 원주문 잔량.
  final int remainingQty;
}

/// 건별 결과.
enum KillCancelOutcome {
  /// 취소 접수.
  cancelled('CANCELLED'),

  /// 분명한 거절 · 브로커 없음 · 오류.
  failed('FAILED'),

  /// 취소 결과 불명.
  unknown('UNKNOWN'),

  /// 의도가 `UNKNOWN` 이라 취소하지 않았다(보고만).
  notCancelledUnknownIntent('NOT_CANCELLED_UNKNOWN_INTENT'),

  /// 제출 중(`RESERVED` · `SUBMITTING`) — 브로커에 닿지 않았거나 닿는 중(보고만).
  inFlight('IN_FLIGHT');

  const KillCancelOutcome(this.wire);

  /// 기록 글자.
  final String wire;
}

/// 건별 보고 한 줄(금액 0).
class KillCancelItem {
  /// 줄을 만든다.
  const KillCancelItem(this.intentId, this.symbol, this.outcome, {this.code});

  /// 의도 id.
  final String intentId;

  /// 종목.
  final String symbol;

  /// 결과.
  final KillCancelOutcome outcome;

  /// 브로커 코드 · 사유(있으면).
  final String? code;
}

/// 취소 보고.
class KillCancelReport {
  /// 보고를 만든다.
  const KillCancelReport(this.items, {this.candidatesError});

  /// 건별.
  final List<KillCancelItem> items;

  /// 후보를 못 읽었으면 그 사유(그래도 차단은 유지).
  final String? candidatesError;

  /// 그 결과의 건수.
  int count(KillCancelOutcome o) =>
      items.where((KillCancelItem i) => i.outcome == o).length;

  /// 🔴 전부 깨끗한가(실패 · 불명 · 보고만 · 읽기 실패 0).
  bool get clean =>
      candidatesError == null &&
      items.every(
        (KillCancelItem i) => i.outcome == KillCancelOutcome.cancelled,
      );

  /// `kill_switch_event.summary` JSON(금액 0).
  String summaryJson() => jsonEncode(<String, Object?>{
    if (candidatesError != null) 'candidates_error': candidatesError,
    'items': <Object?>[
      for (final KillCancelItem i in items)
        <String, Object?>{
          'intent_id': i.intentId,
          'symbol': i.symbol,
          'outcome': i.outcome.wire,
          if (i.code != null) 'code': i.code,
        },
    ],
  });
}

/// 후보 → (취소할 것 · 보고만 할 것)(K6).
(List<KillCancelCandidate>, List<KillCancelItem>) planKillCancels(
  List<KillCancelCandidate> candidates,
) {
  final List<KillCancelCandidate> cancel = <KillCancelCandidate>[];
  final List<KillCancelItem> reportOnly = <KillCancelItem>[];
  for (final KillCancelCandidate c in candidates) {
    switch (c.status) {
      case IntentStatus.submitted || IntentStatus.partial:
        if (c.remainingQty > 0 && c.brokerOrderNo != null) cancel.add(c);
      case IntentStatus.unknown:
        reportOnly.add(
          KillCancelItem(
            c.intentId,
            c.symbol,
            KillCancelOutcome.notCancelledUnknownIntent,
          ),
        );
      case IntentStatus.reserved || IntentStatus.submitting:
        reportOnly.add(
          KillCancelItem(c.intentId, c.symbol, KillCancelOutcome.inFlight),
        );
      case _:
        break;
    }
  }
  return (cancel, reportOnly);
}

/// 킬스위치 저장 포트(구현 = data_sync E13b).
abstract interface class KillSwitchStore {
  /// 지금 행.
  Future<KillSwitchRecord> read();

  /// 발동 기록 — 🔴 이미 활성이면 첫 발동 시각을 유지한다(멱등) · 돌려줌 = 기록 뒤 행.
  Future<KillSwitchRecord> activate({
    required DateTime atUtc,
    required String channel,
    String? deviceLabel,
  });

  /// 취소 보고 기록(`kill_switch_event` CANCEL_REPORT).
  Future<void> recordCancelReport(KillCancelReport report, DateTime atUtc);
}

/// 발동 결과.
class KillActivationResult {
  /// 결과를 만든다.
  const KillActivationResult({
    required this.record,
    required this.report,
    required this.reportRecorded,
  });

  /// 기록 뒤 행(🔴 활성).
  final KillSwitchRecord record;

  /// 취소 보고.
  final KillCancelReport report;

  /// 보고를 저장했나(못 했어도 차단은 유지).
  final bool reportRecorded;
}

/// 발동(K6) — ① 차단 기록 ② 취소 시도 ③ 보고. [brokers] = 계좌 별칭 → 브로커.
Future<KillActivationResult> activateKillSwitch({
  required KillSwitchStore store,
  required Map<String, OrderBroker> brokers,
  required Future<List<KillCancelCandidate>> Function() candidates,
  required DateTime nowUtc,
  required String channel,
  String? deviceLabel,
}) async {
  // ① 🔴 차단이 먼저 — 여기서 실패하면 발동이 안 된 것이니 던진다(부르는 쪽이 다시 누른다).
  final KillSwitchRecord record = await store.activate(
    atUtc: nowUtc,
    channel: channel,
    deviceLabel: deviceLabel,
  );
  // ② 취소 시도 — 실패는 보고로만.
  List<KillCancelCandidate> all;
  try {
    all = await candidates();
  } on Object catch (e) {
    final KillCancelReport r = KillCancelReport(
      const <KillCancelItem>[],
      candidatesError: e.runtimeType.toString(),
    );
    return KillActivationResult(
      record: record,
      report: r,
      reportRecorded: await _record(store, r, nowUtc),
    );
  }
  final (List<KillCancelCandidate> toCancel, List<KillCancelItem> reportOnly) =
      planKillCancels(all);
  final List<KillCancelItem> items = <KillCancelItem>[];
  for (final KillCancelCandidate c in toCancel) {
    final OrderBroker? b = brokers[c.account];
    if (b == null) {
      items.add(
        KillCancelItem(
          c.intentId,
          c.symbol,
          KillCancelOutcome.failed,
          code: 'NO_BROKER',
        ),
      );
      continue;
    }
    try {
      final BrokerSubmitResult res = await b.cancel(c.brokerOrderNo!);
      items.add(switch (res) {
        BrokerAccepted() => KillCancelItem(
          c.intentId,
          c.symbol,
          KillCancelOutcome.cancelled,
        ),
        BrokerRejected(:final String code) => KillCancelItem(
          c.intentId,
          c.symbol,
          KillCancelOutcome.failed,
          code: code,
        ),
      });
    } on OrderOutcomeUnknown {
      items.add(
        KillCancelItem(c.intentId, c.symbol, KillCancelOutcome.unknown),
      );
    } on Object catch (e) {
      items.add(
        KillCancelItem(
          c.intentId,
          c.symbol,
          KillCancelOutcome.failed,
          code: e.runtimeType.toString(),
        ),
      );
    }
  }
  // ③ 보고.
  final KillCancelReport report = KillCancelReport(<KillCancelItem>[
    ...items,
    ...reportOnly,
  ]);
  return KillActivationResult(
    record: record,
    report: report,
    reportRecorded: await _record(store, report, nowUtc),
  );
}

Future<bool> _record(KillSwitchStore s, KillCancelReport r, DateTime at) async {
  try {
    await s.recordCancelReport(r, at);
    return true;
  } on Object {
    return false;
  }
}
