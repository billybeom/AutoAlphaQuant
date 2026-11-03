// FakeOrderLedger — 메모리 주문 원장(설계 13 §8 R35 V9). 순서기 시험의 짝.
//
// 🔴 시험 전용이다. INSERT 가 돌아오면 곧 «커밋»으로 본다(포트 계약 6.5) — 진짜 커밋 증명(파일 SQLite + 둘째 연결)은
//    data_sync `SqliteOrderLedger` 시험(E10c)이 한다.
// 🔴 상태 전이를 엄격히 본다 — 순서기가 RESERVED 를 건너뛰거나 거꾸로 가면 StateError 가 난다(SQLite 구현도 같은 규칙).

import 'package:domain_contracts/domain_contracts.dart';

import '../orders/order_ports.dart';

/// 원장 한 의도의 현재 값.
class FakeIntentRecord {
  FakeIntentRecord._(this.row)
    : status = row.status,
      errorMessage = row.errorMessage;

  /// INSERT 때 행.
  final IntentRow row;

  /// 지금 상태.
  IntentStatus status;

  /// 지금 사유.
  String? errorMessage;

  /// 접수면 `{주문일}:{ODNO}`.
  String? brokerOrderNo;

  /// 7단계를 지난 브로커 거절인가(orders_today 에 센다 — R33 D22).
  bool brokerRejected = false;
}

const Set<IntentStatus> _submittedOrLater = <IntentStatus>{
  IntentStatus.submitting,
  IntentStatus.submitted,
  IntentStatus.filled,
  IntentStatus.partial,
  IntentStatus.cancelled,
  IntentStatus.unknown,
  IntentStatus.expired,
};

/// 메모리 주문 원장.
class FakeOrderLedger implements OrderLedger {
  /// 원장을 만든다. [registeredStrategies] 에 없는 strategy_id 는 SAF-406 거부를 받는다.
  FakeOrderLedger({
    this.killSwitch = false,
    Set<String>? flags,
    Set<String>? registeredStrategies,
    this.journalMissingValue = false,
    this.tierBUnjudgedValue = false,
    this.failOn,
  }) : flags = flags ?? <String>{},
       registeredStrategies = registeredStrategies ?? <String>{};

  /// 킬스위치 활성.
  bool killSwitch;

  /// 활성 `trading_block` 플래그(묶음 밖 값도 넣을 수 있다 — 판정은 순서기 몫).
  final Set<String> flags;

  /// 등록된 전략.
  final Set<String> registeredStrategies;

  /// SAF-408 판정값.
  bool journalMissingValue;

  /// SAF-410 판정값.
  bool tierBUnjudgedValue;

  /// 실패 주입 — 메서드 이름(`insertIntent` 등)을 받아 던질 예외를 돌려준다(null = 정상).
  Object? Function(String method)? failOn;

  /// intent_id → 의도(INSERT 순서).
  final Map<String, FakeIntentRecord> records = <String, FakeIntentRecord>{};

  /// 상태 전이 기록(intent_id · 새 상태) — INSERT 포함.
  final List<(String, IntentStatus)> transitions = <(String, IntentStatus)>[];

  /// 불린 메서드 이름(순서대로).
  final List<String> calls = <String>[];

  void _enter(String method) {
    calls.add(method);
    final Object? error = failOn?.call(method);
    if (error != null) Error.throwWithStackTrace(error, StackTrace.current);
  }

  FakeIntentRecord _move(
    String intentId,
    Set<IntentStatus> from,
    IntentStatus to,
    String? message,
  ) {
    final FakeIntentRecord? r = records[intentId];
    if (r == null) throw StateError('없는 의도: $intentId');
    if (!from.contains(r.status)) {
      throw StateError('$intentId: ${r.status.code} → ${to.code} 전이는 없다');
    }
    r
      ..status = to
      ..errorMessage = message;
    transitions.add((intentId, to));
    return r;
  }

  @override
  Future<bool> killSwitchActive() async {
    _enter('killSwitchActive');
    return killSwitch;
  }

  @override
  Future<Set<String>> activeBlockFlags() async {
    _enter('activeBlockFlags');
    return Set<String>.of(flags);
  }

  @override
  Future<bool> hasUnresolvedUnknown(
    String market,
    String symbol,
    String strategyId,
  ) async {
    _enter('hasUnresolvedUnknown');
    return records.values.any(
      (FakeIntentRecord r) =>
          r.status == IntentStatus.unknown &&
          r.row.market == market &&
          r.row.symbol == symbol &&
          r.row.strategyId == strategyId,
    );
  }

  @override
  Future<bool> strategyRegistered(String strategyId) async {
    _enter('strategyRegistered');
    return registeredStrategies.contains(strategyId);
  }

  @override
  Future<int> ordersToday(TradeDate tradeDate) async {
    _enter('ordersToday');
    return records.values
        .where(
          (FakeIntentRecord r) =>
              r.row.tradeDate == tradeDate &&
              (_submittedOrLater.contains(r.status) || r.brokerRejected),
        )
        .length;
  }

  @override
  Future<bool> journalMissing() async {
    _enter('journalMissing');
    return journalMissingValue;
  }

  @override
  Future<bool> tierBUnjudged() async {
    _enter('tierBUnjudged');
    return tierBUnjudgedValue;
  }

  @override
  Future<bool> insertIntent(IntentRow row) async {
    _enter('insertIntent');
    if (!const <IntentStatus>{
      IntentStatus.reserved,
      IntentStatus.rejected,
      IntentStatus.skipped,
    }.contains(row.status)) {
      throw StateError(
        'INSERT 상태는 RESERVED · REJECTED · SKIPPED 뿐이다: ${row.status.code}',
      );
    }
    final bool duplicate = records.values.any(
      (FakeIntentRecord r) => r.row.idempotencyKey == row.idempotencyKey,
    );
    if (duplicate || records.containsKey(row.intentId)) return false;
    records[row.intentId] = FakeIntentRecord._(row);
    transitions.add((row.intentId, row.status));
    return true;
  }

  @override
  Future<void> markSubmitting(String intentId) async {
    _enter('markSubmitting');
    _move(
      intentId,
      <IntentStatus>{IntentStatus.reserved},
      IntentStatus.submitting,
      null,
    );
  }

  @override
  Future<void> markSubmitted(String intentId, String brokerOrderNo) async {
    _enter('markSubmitted');
    _move(
      intentId,
      <IntentStatus>{IntentStatus.submitting},
      IntentStatus.submitted,
      null,
    ).brokerOrderNo = brokerOrderNo;
  }

  @override
  Future<void> markBrokerRejected(String intentId, String message) async {
    _enter('markBrokerRejected');
    _move(
      intentId,
      <IntentStatus>{IntentStatus.submitting},
      IntentStatus.rejected,
      message,
    ).brokerRejected = true;
  }

  @override
  Future<void> markUnknown(String intentId, String message) async {
    _enter('markUnknown');
    _move(
      intentId,
      <IntentStatus>{IntentStatus.submitting},
      IntentStatus.unknown,
      message,
    );
  }

  @override
  Future<void> markSkipped(String intentId, String message) async {
    _enter('markSkipped');
    _move(
      intentId,
      <IntentStatus>{IntentStatus.reserved},
      IntentStatus.skipped,
      message,
    );
  }
}

/// 안내 받는 쪽 가짜 — 받은 행을 모은다.
class RecordingAdviceSink implements AdviceSink {
  /// 받은 의도.
  final List<IntentRow> published = <IntentRow>[];

  @override
  Future<void> publish(IntentRow row) async => published.add(row);
}
