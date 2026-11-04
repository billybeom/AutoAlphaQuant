// 오늘의 주문 대상 포트 · 대상 직렬화(설계 13 §8 R48 P2 · P9).
//
// 🔴 여기에 두는 까닭 — 구현(저장된 월말 계획 → 오늘 대상)은 data_sync 에 있고 소비(`kr_order`)는 trading_runtime 에 있다.
//    data_sync ↛ trading_runtime(01 §1-1)이라 둘 다 의존하는 core_engine 에 둔다(E11c `JobHeartbeat` 와 같은 수).
//    trading_runtime 은 같은 이름으로 다시 내보낸다(E11a 코드 · 시험 그대로).
// 🔴 직렬화는 왕복이 같아야 한다 — 금액(Decimal)은 글자로 · 모르는 값은 FormatException(지어내지 않는다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;

import '../risk/limits.dart' show InstrumentKind;
import 'order_draft.dart';

/// 오늘의 주문 대상(월말 계획 · 계절 분할 몫) — 이월은 잡이 더한다.
abstract interface class TargetSource {
  /// [today] 집행 대상.
  Future<List<OrderTarget>> targetsFor(TradeDate today);
}

/// 대상 → JSON.
Map<String, Object?> orderTargetToJson(OrderTarget t) => <String, Object?>{
  'logical_decision_id': t.logicalDecisionId,
  'strategy_id': t.strategyId,
  'symbol': t.symbol,
  'side': t.side.wire,
  'sizing': switch (t.sizing) {
    AmountSizing(:final Decimal krw) => <String, Object?>{
      'kind': 'AMOUNT',
      'krw': krw.toString(),
    },
    ShareSizing(:final int shares) => <String, Object?>{
      'kind': 'SHARES',
      'shares': shares,
    },
    AllHeldSizing() => <String, Object?>{'kind': 'ALL_HELD'},
  },
  'instrument': t.instrument.code,
  'market_order': t.marketOrder,
};

/// JSON → 대상 — 꼴이 틀리면 FormatException.
OrderTarget orderTargetFromJson(Map<String, Object?> j) {
  String str(String k) {
    final Object? v = j[k];
    if (v is String && v.isNotEmpty) return v;
    throw FormatException('대상 칸 $k 가 없다');
  }

  final Object? sz = j['sizing'];
  if (sz is! Map<String, Object?>) {
    throw const FormatException('대상 칸 sizing 이 없다');
  }
  final OrderSizing sizing = switch (sz['kind']) {
    'AMOUNT' => AmountSizing(
      Decimal.tryParse('${sz['krw']}') ??
          (throw const FormatException('sizing.krw 가 숫자가 아니다')),
    ),
    'SHARES' => switch (sz['shares']) {
      final int n => ShareSizing(n),
      _ => throw const FormatException('sizing.shares 가 정수가 아니다'),
    },
    'ALL_HELD' => const AllHeldSizing(),
    _ => throw const FormatException('sizing.kind 를 모른다'),
  };
  final String sideWire = str('side');
  final OrderSide side = OrderSide.values.firstWhere(
    (OrderSide s) => s.wire == sideWire,
    orElse: () => throw const FormatException('side 를 모른다'),
  );
  final String inst = str('instrument');
  final InstrumentKind instrument = InstrumentKind.values.firstWhere(
    (InstrumentKind k) => k.code == inst,
    orElse: () => throw const FormatException('instrument 를 모른다'),
  );
  final Object? mo = j['market_order'];
  if (mo is! bool) throw const FormatException('market_order 가 참거짓이 아니다');
  try {
    return OrderTarget(
      logicalDecisionId: str('logical_decision_id'),
      strategyId: str('strategy_id'),
      symbol: str('symbol'),
      side: side,
      sizing: sizing,
      instrument: instrument,
      marketOrder: mo,
    );
  } on ArgumentError catch (e) {
    throw FormatException('대상이 규칙에 어긋난다: ${e.message}');
  }
}
