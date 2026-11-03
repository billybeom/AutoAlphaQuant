// FakeOrderLedger — 메모리 주문 원장(설계 13 §8 R35 V9). 순서기 시험의 짝.
//
// 🔴 시험 전용이다. INSERT 가 돌아오면 곧 «커밋»으로 본다(포트 계약 6.5) — 진짜 커밋 증명(파일 SQLite + 둘째 연결)은
//    data_sync `SqliteOrderLedger` 시험(E10c)이 한다.
// 🔴 상태 전이를 엄격히 본다 — 순서기가 RESERVED 를 건너뛰거나 거꾸로 가면 StateError 가 난다(SQLite 구현도 같은 규칙).

import 'package:domain_contracts/domain_contracts.dart';

import '../orders/fill_sync.dart';
import '../orders/fills.dart';
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
class FakeOrderLedger implements OrderLedger, FillLedger {
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

  /// 🆕 E10e1 — 주문번호 → 기록한 누적(체결 원장 · R38 Z4).
  final Map<String, RecordedFill> recordedFills = <String, RecordedFill>{};

  /// 🆕 E10e1 — 쓴 체결 행(실행 순서).
  final List<FillDelta> executions = <FillDelta>[];

  /// 🆕 E10e1 — (strategy_id, 종목) → 보유 수량(0 이면 지운다 · 매도가 넘으면 StateError).
  final Map<(String, String), int> positions = <(String, String), int>{};

  static const Set<IntentStatus> _open = <IntentStatus>{
    IntentStatus.submitted,
    IntentStatus.partial,
  };

  @override
  Future<List<OpenIntent>> openIntents(TradeDate tradeDate) async {
    _enter('openIntents');
    return <OpenIntent>[
      for (final FakeIntentRecord r in records.values)
        if (r.row.tradeDate == tradeDate &&
            _open.contains(r.status) &&
            r.brokerOrderNo != null)
          OpenIntent(
            intentId: r.row.intentId,
            brokerOrderNo: r.brokerOrderNo!,
            tradeDate: r.row.tradeDate,
            market: r.row.market,
            account: r.row.account,
            strategyId: r.row.strategyId,
            symbol: r.row.symbol,
            side: r.row.side,
            quantity: r.row.quantity,
            decisionId: r.row.decisionId,
            status: r.status,
          ),
    ];
  }

  @override
  Future<RecordedFill?> recordedFill(String brokerOrderNo) async {
    _enter('recordedFill');
    return recordedFills[brokerOrderNo];
  }

  @override
  Future<void> applyFill(FillApplication application) async {
    _enter('applyFill');
    final FillVerdict v = application.verdict;
    final OpenIntent it = v.intent;
    final FakeIntentRecord? rec = records[it.intentId];
    if (rec == null || !_open.contains(rec.status)) {
      throw StateError('${it.intentId}: 열린 의도가 아니다');
    }
    if (!const <IntentStatus>{
      IntentStatus.partial,
      IntentStatus.filled,
      IntentStatus.expired,
      IntentStatus.cancelled,
      IntentStatus.submitted,
    }.contains(v.status)) {
      throw StateError('${it.intentId}: 체결 적용 상태가 아니다 — ${v.status.code}');
    }
    // 포지션을 먼저 검사한다(한 트랜잭션 — 실패하면 아무것도 쓰지 않는다).
    final (String, String) key = (it.strategyId, it.symbol);
    int held = positions[key] ?? 0;
    for (final FillDelta d in v.deltas) {
      held += d.side == OrderSide.buy ? d.quantity : -d.quantity;
      if (held < 0) throw StateError('${it.symbol}: 매도가 보유를 넘는다');
    }
    executions.addAll(v.deltas);
    if (held == 0) {
      positions.remove(key);
    } else {
      positions[key] = held;
    }
    final DailyFillRow row = v.row!;
    recordedFills[it.brokerOrderNo] = RecordedFill(
      row.cumFilledQty,
      row.cumFilledAmount,
    );
    rec
      ..status = v.status
      ..errorMessage = v.message;
    transitions.add((it.intentId, v.status));
  }

  @override
  Future<void> markUnresolved(String intentId, String message) async {
    _enter('markUnresolved');
    _move(intentId, _open, IntentStatus.unknown, message);
  }

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

  /// 판정이 플래그를 세우고 지운다(SQLite 원장과 같은 꼴 — 자동 해제 · R36 W9).
  bool _refresh(String flag, bool judged) {
    if (judged) {
      flags.add(flag);
    } else {
      flags.remove(flag);
    }
    return judged;
  }

  @override
  Future<bool> journalMissing() async {
    _enter('journalMissing');
    return _refresh(FlagIds.journalMissing, journalMissingValue);
  }

  /// 마지막 [tierBUnjudged] 의 집행일.
  TradeDate? lastTierBDate;

  @override
  Future<bool> tierBUnjudged(TradeDate tradeDate) async {
    _enter('tierBUnjudged');
    lastTierBDate = tradeDate;
    return _refresh(FlagIds.tierBUnjudged, tierBUnjudgedValue);
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
