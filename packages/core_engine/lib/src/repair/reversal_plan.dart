// X5-3 · M5-12 역분개 계획(순수 · 설계 13 §8 R121 F6 · F7 · 01 §10-3 · 08 그림 13-2 :748).
//
// 🔴 원본 행은 고치지 않는다 — 정정 = REVERSAL 1 + RESTATEMENT 1 · 무효 = REVERSAL 1(한 트랜잭션 · 한 결정).
// 🔴 종목 · 방향은 고칠 수 없다(무효 + 새 기록) · 정정 체인 상한 = 인자(기본값 없음).
// 🔴 부호 = 저장은 늘 양수(`executions.quantity CHECK > 0`) · `fill_kind` 가 부호를 정한다 — 합산은 [signedFillQuantity].

import 'package:domain_contracts/domain_contracts.dart'
    show AdviceRejectCodes, FillKind;

import 'repair_plan.dart' show RepairCodes;

/// 🔴 부호 있는 수량 — REVERSAL = 음수 · 그 밖 = 양수(저장 수량은 양수여야 한다).
int signedFillQuantity(FillKind kind, int storedQuantity) {
  if (storedQuantity <= 0) {
    throw ArgumentError.value(storedQuantity, 'storedQuantity', '양수');
  }
  return kind == FillKind.reversal ? -storedQuantity : storedQuantity;
}

/// 정정 전 체결(호출자가 `order_intents` 에서 종목 · 방향을 붙인다).
class FillSnapshot {
  /// 만든다 — 수량 · 가격 0 이하 · 체인 깊이 음수 = [ArgumentError].
  FillSnapshot({
    required this.fillId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.chainDepth,
  }) {
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity');
    if (price <= 0) throw ArgumentError.value(price, 'price');
    if (chainDepth < 0) throw ArgumentError.value(chainDepth, 'chainDepth');
  }

  /// 체결 id(지금 살아 있는 판).
  final String fillId;

  /// 종목.
  final String symbol;

  /// 방향(BUY · SELL).
  final String side;

  /// 수량(양수).
  final int quantity;

  /// 가격.
  final double price;

  /// 지금까지 정정 횟수(원본 = 0).
  final int chainDepth;
}

/// 계획된 역분개 행 하나.
class PlannedFillRow {
  const PlannedFillRow._(
    this.kind,
    this.quantity,
    this.price, {
    this.reversesFillId,
    this.restatesFillId,
  });

  /// 행 종류.
  final FillKind kind;

  /// 저장 수량(늘 양수).
  final int quantity;

  /// 가격.
  final double price;

  /// 되돌리는 원 체결(REVERSAL).
  final String? reversesFillId;

  /// 다시 적는 원 체결(RESTATEMENT).
  final String? restatesFillId;

  /// 부호 있는 수량.
  int get signedQuantity => signedFillQuantity(kind, quantity);
}

/// 🔴 무효 = REVERSAL 하나(원 수량 · 원 가격).
List<PlannedFillRow> voidFillPlan(FillSnapshot f) => <PlannedFillRow>[
  PlannedFillRow._(
    FillKind.reversal,
    f.quantity,
    f.price,
    reversesFillId: f.fillId,
  ),
];

/// 🔴 정정 판정 — 거부면 코드(종목 · 방향 바뀜 → 체인 상한 → 바뀌는 것 없음 차례) · 통과 = null.
///
/// [chainLimit] = 정정 체인 상한(값 = config · 1 미만 = [ArgumentError]).
String? amendFillRejectCode(
  FillSnapshot f, {
  required String symbol,
  required String side,
  required int quantity,
  required double price,
  required int chainLimit,
}) {
  if (chainLimit < 1) throw ArgumentError.value(chainLimit, 'chainLimit');
  if (symbol != f.symbol || side != f.side) {
    return AdviceRejectCodes.amendSymbolOrSideChange;
  }
  if (f.chainDepth >= chainLimit) return AdviceRejectCodes.amendLimitExceeded;
  if (quantity == f.quantity && price == f.price) return RepairCodes.noChange;
  return null;
}

/// 🔴 정정 계획 — REVERSAL(원 수량) + RESTATEMENT(새 수량) · 판정이 거부면 [StateError].
List<PlannedFillRow> amendFillPlan(
  FillSnapshot f, {
  required String symbol,
  required String side,
  required int quantity,
  required double price,
  required int chainLimit,
}) {
  if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', '양수');
  if (price <= 0) throw ArgumentError.value(price, 'price', '양수');
  final String? reject = amendFillRejectCode(
    f,
    symbol: symbol,
    side: side,
    quantity: quantity,
    price: price,
    chainLimit: chainLimit,
  );
  if (reject != null) throw StateError('정정할 수 없다: $reject');
  return <PlannedFillRow>[
    PlannedFillRow._(
      FillKind.reversal,
      f.quantity,
      f.price,
      reversesFillId: f.fillId,
    ),
    PlannedFillRow._(
      FillKind.restatement,
      quantity,
      price,
      restatesFillId: f.fillId,
    ),
  ];
}
