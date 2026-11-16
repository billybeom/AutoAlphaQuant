// X5-3 체결 재생(순수 · 설계 13 §8 R128 K7 · K12 · R121 F6).
//
// 🔴 살아 있는 체결 = REVERSAL 아님 · 되돌려지지 않음 — 차례 = 체인 뿌리(ORIGINAL)의 입력 차례.
// 🔴 포지션 = `applyFill` 의 증분 `_position` 과 같은 셈(매수 = 평단 갱신 · 매도 = 수량만 · 0 = 비움).
// 🔵 E16h(갭 복구 뒤 포지션 다시 세기)도 이것을 쓴다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show FillKind, OrderSide;

import '../decimal_rules.dart';

/// 원장 체결 한 행(재생 입력 · 호출자가 의도에서 방향 · 거래일 · 결정을 붙인다).
class LedgerFillRow {
  /// 만든다 — 수량 · 가격 0 이하 · 종류와 링크가 맞지 않으면 [ArgumentError].
  LedgerFillRow({
    required this.executionId,
    required this.kind,
    required this.side,
    required this.quantity,
    required this.price,
    required this.brokerOrderNo,
    required this.tradeDate,
    required this.decisionId,
    this.reversesFillId,
    this.restatesFillId,
  }) {
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', '양수');
    if (price <= 0) throw ArgumentError.value(price, 'price', '양수');
    final bool linksOk = switch (kind) {
      FillKind.original => reversesFillId == null && restatesFillId == null,
      FillKind.reversal => reversesFillId != null && restatesFillId == null,
      FillKind.restatement => restatesFillId != null && reversesFillId == null,
    };
    if (!linksOk) {
      throw ArgumentError('${kind.wire} 링크가 맞지 않다: $executionId');
    }
  }

  /// 체결 id.
  final String executionId;

  /// 종류.
  final FillKind kind;

  /// 방향(의도).
  final OrderSide side;

  /// 저장 수량(늘 양수).
  final int quantity;

  /// 가격.
  final double price;

  /// 브로커 주문 번호.
  final String brokerOrderNo;

  /// 의도 거래일(`YYYY-MM-DD`).
  final String tradeDate;

  /// 의도 결정.
  final String decisionId;

  /// 되돌리는 체결(REVERSAL).
  final String? reversesFillId;

  /// 다시 적는 체결(RESTATEMENT).
  final String? restatesFillId;
}

Map<String, int> _indexOf(List<LedgerFillRow> rows) {
  final Map<String, int> at = <String, int>{};
  for (int i = 0; i < rows.length; i++) {
    if (at.containsKey(rows[i].executionId)) {
      throw ArgumentError('체결 id 가 겹친다: ${rows[i].executionId}');
    }
    at[rows[i].executionId] = i;
  }
  return at;
}

/// 되돌려진 체결 id 들 — 없는 대상 · REVERSAL 대상 · 두 번 되돌림 = [StateError].
Set<String> reversedFillIdsOf(List<LedgerFillRow> rows) {
  final Map<String, int> at = _indexOf(rows);
  final Set<String> out = <String>{};
  for (final LedgerFillRow r in rows) {
    if (r.kind != FillKind.reversal) continue;
    final String t = r.reversesFillId!;
    final int? i = at[t];
    if (i == null) throw StateError('없는 체결을 되돌린다: $t');
    if (rows[i].kind == FillKind.reversal) {
      throw StateError('되돌림을 되돌린다: $t');
    }
    if (!out.add(t)) throw StateError('두 번 되돌렸다: $t');
  }
  return out;
}

int _rootIndex(String id, List<LedgerFillRow> rows, Map<String, int> at) {
  int? i = at[id];
  for (int hops = 0; hops <= rows.length; hops++) {
    if (i == null) throw StateError('없는 체결을 다시 적었다: $id');
    final String? up = rows[i].restatesFillId;
    if (up == null) return i;
    i = at[up];
  }
  throw StateError('정정 체인이 돈다: $id');
}

/// 🔴 살아 있는 체결 — REVERSAL 아님 · 되돌려지지 않음 · 차례 = 체인 뿌리의 입력 차례([rows] = 입력 차례).
List<LedgerFillRow> effectiveFillsOf(List<LedgerFillRow> rows) {
  final Map<String, int> at = _indexOf(rows);
  final Set<String> reversed = reversedFillIdsOf(rows);
  final List<(int, int, LedgerFillRow)> live = <(int, int, LedgerFillRow)>[
    for (int i = 0; i < rows.length; i++)
      if (rows[i].kind != FillKind.reversal &&
          !reversed.contains(rows[i].executionId))
        (_rootIndex(rows[i].executionId, rows, at), i, rows[i]),
  ];
  live.sort(((int, int, LedgerFillRow) a, (int, int, LedgerFillRow) b) {
    final int c = a.$1.compareTo(b.$1);
    return c != 0 ? c : a.$2.compareTo(b.$2);
  });
  return <LedgerFillRow>[for (final (int, int, LedgerFillRow) e in live) e.$3];
}

/// 정정 체인 깊이(원본 = 0 · RESTATEMENT 하나마다 +1) — 없는 id = [StateError].
int fillChainDepthOf(String fillId, List<LedgerFillRow> rows) {
  final Map<String, int> at = _indexOf(rows);
  int depth = 0;
  int? i = at[fillId];
  for (int hops = 0; hops <= rows.length; hops++) {
    if (i == null) throw StateError('없는 체결: $fillId');
    final String? up = rows[i].restatesFillId;
    if (up == null) return depth;
    depth++;
    i = at[up];
  }
  throw StateError('정정 체인이 돈다: $fillId');
}

/// 다시 센 포지션(수량 0 = 비움 · 평단 · 진입 = null).
class ReplayedPosition {
  /// 만든다.
  const ReplayedPosition({
    required this.quantity,
    this.avgPrice,
    this.entryDate,
    this.entryDecisionId,
  });

  /// 수량.
  final int quantity;

  /// 평단.
  final double? avgPrice;

  /// 진입일(0 뒤 첫 매수의 거래일).
  final String? entryDate;

  /// 진입 결정(0 뒤 첫 매수의 결정).
  final String? entryDecisionId;
}

/// 🔴 포지션 재생 — [effective] 차례대로 · 중간에 음수가 되면 null.
ReplayedPosition? replayPositionOf(List<LedgerFillRow> effective) {
  int q = 0;
  double? avg;
  String? entryDate;
  String? entryDecision;
  for (final LedgerFillRow f in effective) {
    if (f.kind == FillKind.reversal) {
      throw ArgumentError('살아 있는 체결이 아니다: ${f.executionId}');
    }
    if (f.side == OrderSide.buy) {
      if (q == 0) {
        avg = f.price;
        entryDate = f.tradeDate;
        entryDecision = f.decisionId;
      } else {
        avg = demoteToDouble(
          divide(
            multiply(Decimal.fromInt(q), promoteRatio(avg!)) +
                multiply(Decimal.fromInt(f.quantity), promoteRatio(f.price)),
            Decimal.fromInt(q + f.quantity),
          ),
        );
      }
      q += f.quantity;
      continue;
    }
    q -= f.quantity;
    if (q < 0) return null;
    if (q == 0) {
      avg = null;
      entryDate = null;
      entryDecision = null;
    }
  }
  return ReplayedPosition(
    quantity: q,
    avgPrice: avg,
    entryDate: entryDate,
    entryDecisionId: entryDecision,
  );
}

/// 평단 비교 허용(상대) — 저장 평단은 Decimal 을 double 로 내린 값이라 끝자리가 어긋날 수 있다.
const double kReplayAvgTolerance = 1e-9;

/// 🔴 재생이 저장 행과 맞나 — 수량 같음 · 평단 상대 [kReplayAvgTolerance] 안(수량 0 = 행 없음).
bool positionReplayMatches(
  ReplayedPosition replay, {
  required int storedQuantity,
  required double? storedAvgPrice,
}) {
  if (replay.quantity != storedQuantity) return false;
  if (storedQuantity == 0) return storedAvgPrice == null;
  if (storedAvgPrice == null) return false;
  final double scale = storedAvgPrice.abs() > 1 ? storedAvgPrice.abs() : 1;
  return (replay.avgPrice! - storedAvgPrice).abs() <=
      kReplayAvgTolerance * scale;
}

/// 주문 하나의 살아 있는 체결 합(`broker_orders.filled_qty` · `avg_fill_price`) — 0 = 평단 null.
({int quantity, double? avgPrice}) orderFillTotalsOf(
  Iterable<LedgerFillRow> effective,
) {
  int q = 0;
  Decimal amount = Decimal.zero;
  for (final LedgerFillRow f in effective) {
    if (f.kind == FillKind.reversal) {
      throw ArgumentError('살아 있는 체결이 아니다: ${f.executionId}');
    }
    q += f.quantity;
    amount += multiply(Decimal.fromInt(f.quantity), promoteRatio(f.price));
  }
  return (
    quantity: q,
    avgPrice: q == 0
        ? null
        : demoteToDouble(divide(amount, Decimal.fromInt(q))),
  );
}
