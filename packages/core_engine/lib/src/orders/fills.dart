// 체결 델타 — KIS 일별주문체결조회 행 → 체결 행(`executions`). 02 §3-2 v2.38 · 설계 13 §8 R31 (a) · R33 D3 · D4 · R34 U9.
//
// 🔴 KIS 체결조회는 **주문 한 건 = 한 행**이고 체결 순번이 없다(07 §6-3) — 누적 체결수량(`tot_ccld_qty`)이 직전
//    기록보다 늘었을 때만 늘어난 만큼 1행을 만든다. 체결 키 = `{broker_order_no}#{누적 체결수량}` — 같은 누적은 같은
//    키라 다시 조회해도 행이 늘지 않는다(멱등). 두 조회 사이 여러 체결은 한 행으로 합쳐진다(합계는 같다).
// 🔴 `broker_order_no` = `{주문일}:{ODNO}` — KIS 주문번호는 날마다 새로 매겨질 수 있어 원문 그대로면 단독 PK 가
//    날을 넘겨 겹친다.
// 🔴 취소 행(`cncl_yn = Y` — 취소도 새 주문번호를 받는다)은 거른다. 판정은 원주문 행으로 한다.
// 🔴 단가 = Δ누적 금액 ÷ Δ누적 수량. Δ수량 > 0 인데 Δ금액 ≤ 0 이면 단가 > 0 CHECK 를 어기는 행이라 만들지도
//    조용히 버리지도 않는다 — [StateError](호출자 = UNKNOWN · 대사 경로).
// 🔵 비용 추정 · `executed_at`(조회 시각) · `fill_origin` 은 기록 쪽(E10c) 몫이다. 이 파일은 값만 낸다.

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../decimal_rules.dart';

final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// `broker_orders.broker_order_no` = `{주문일}:{ODNO}`(02 §2-4 v2.38).
///
/// 주문번호가 비었거나 공백·구분자(`:` · `#` · `|`)가 있으면 [ArgumentError].
String brokerOrderNoOf(TradeDate orderDate, String odno) {
  if (!_isoDate.hasMatch(orderDate.yyyyMmDd)) {
    throw ArgumentError.value(
      orderDate.yyyyMmDd,
      'orderDate',
      'YYYY-MM-DD 가 아니다',
    );
  }
  if (odno.isEmpty || odno.contains(RegExp(r'[\s:#|]'))) {
    throw ArgumentError.value(odno, 'odno', '비었거나 공백·구분자가 들어 있다');
  }
  return '${orderDate.yyyyMmDd}:$odno';
}

/// `executions.execution_id` = `{broker_order_no}#{누적 체결수량}`(R31 (a)).
String executionIdOf(String brokerOrderNo, int cumulativeFilledQty) {
  if (cumulativeFilledQty < 1) {
    throw ArgumentError.value(
      cumulativeFilledQty,
      'cumulativeFilledQty',
      '1 이상이어야 한다',
    );
  }
  if (brokerOrderNo.isEmpty || brokerOrderNo.contains(RegExp(r'[\s#|]'))) {
    throw ArgumentError.value(
      brokerOrderNo,
      'brokerOrderNo',
      '비었거나 공백·#·| 가 들어 있다',
    );
  }
  return '$brokerOrderNo#$cumulativeFilledQty';
}

/// 일별주문체결조회 한 행(02 §3 `BrokerDailyFill` v2.38) — KIS 칸 해석은 broker_gateway(E10d) 몫.
class DailyFillRow {
  /// 행을 만든다.
  const DailyFillRow({
    required this.orderDate,
    required this.odno,
    required this.isCancelRow,
    required this.symbol,
    required this.side,
    required this.orderQty,
    required this.cumFilledQty,
    required this.cumFilledAmount,
    required this.remainingQty,
    this.originalOdno,
    this.orderPrice,
    this.orderTime,
    this.cancelConfirmedQty = 0,
  });

  /// 주문일(KR 거래일 · `ord_dt`).
  final TradeDate orderDate;

  /// 주문번호 원문(`odno`).
  final String odno;

  /// 취소 행인가(`cncl_yn == 'Y'`) — 🔴 판정은 원주문 행(false)으로.
  final bool isCancelRow;

  /// 취소 행의 원주문(`orgn_odno`).
  final String? originalOdno;

  /// 종목(`pdno`).
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// 주문 수량(`ord_qty`).
  final int orderQty;

  /// 주문 단가(`ord_unpr` · 시장가면 0 이 올 수 있다).
  final Decimal? orderPrice;

  /// 주문 시각(`ord_tmd` · HHMMSS).
  final String? orderTime;

  /// 누적 체결수량(`tot_ccld_qty`).
  final int cumFilledQty;

  /// 누적 체결금액(`tot_ccld_amt`).
  final Decimal cumFilledAmount;

  /// 잔여 수량(`rmn_qty`) — 🔴 주문일 = 오늘 행만 «미체결» · 지난 날 행의 잔여 = 마감 실효(R32 O4).
  final int remainingQty;

  /// 취소 확인 수량(`cncl_cfrm_qty`).
  final int cancelConfirmedQty;

  /// `{주문일}:{ODNO}`.
  String get brokerOrderNo => brokerOrderNoOf(orderDate, odno);
}

/// 그 주문에 대해 이미 기록한 누적(체결 행 합).
class RecordedFill {
  /// 기록 누적을 만든다.
  const RecordedFill(this.quantity, this.amount);

  /// 기록한 체결 수량 합.
  final int quantity;

  /// 기록한 체결 금액 합(Σ 수량 × 단가).
  final Decimal amount;
}

/// 새로 기록할 체결 한 행.
class FillDelta {
  /// 행을 만든다.
  const FillDelta({
    required this.executionId,
    required this.brokerOrderNo,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.cumulativeQuantity,
    required this.cumulativeAmount,
  });

  /// `{broker_order_no}#{누적 체결수량}`.
  final String executionId;

  /// `{주문일}:{ODNO}`.
  final String brokerOrderNo;

  /// 종목.
  final String symbol;

  /// 방향.
  final OrderSide side;

  /// Δ누적 체결수량(≥ 1).
  final int quantity;

  /// Δ누적 금액 ÷ Δ누적 수량(> 0).
  final Decimal price;

  /// 이 행까지의 누적 수량 — 다음 조회의 [RecordedFill.quantity].
  final int cumulativeQuantity;

  /// 이 행까지의 누적 금액 — 다음 조회의 [RecordedFill.amount].
  final Decimal cumulativeAmount;
}

/// 조회 행 + 직전 기록 → 새 체결 행(행 순서 그대로 · R34 U9).
///
/// [recorded] 키 = `broker_order_no` · 없으면 0 에서 시작한다. 취소 행은 거른다 · Δ수량 ≤ 0 이면 행 없음.
/// 한 조회에 같은 주문번호 원주문 행이 둘이거나 누적 값이 음수 · Δ수량 > 0 인데 Δ금액 ≤ 0 이면 [StateError].
List<FillDelta> fillDeltas(
  Iterable<DailyFillRow> rows,
  Map<String, RecordedFill> recorded,
) {
  final Set<String> seen = <String>{};
  final List<FillDelta> out = <FillDelta>[];
  for (final DailyFillRow r in rows) {
    if (r.isCancelRow) continue;
    final String no = r.brokerOrderNo;
    if (!seen.add(no)) throw StateError('같은 주문번호 원주문 행이 둘이다: $no');
    if (r.cumFilledQty < 0 || r.cumFilledAmount < Decimal.zero) {
      throw StateError('누적 값이 음수다: $no');
    }
    final RecordedFill before = recorded[no] ?? RecordedFill(0, Decimal.zero);
    final int dq = r.cumFilledQty - before.quantity;
    if (dq <= 0) continue;
    final Decimal da = r.cumFilledAmount - before.amount;
    if (da <= Decimal.zero) {
      throw StateError('체결 수량이 늘었는데 금액이 늘지 않았다: $no (Δ수량 $dq · Δ금액 $da)');
    }
    out.add(
      FillDelta(
        executionId: executionIdOf(no, r.cumFilledQty),
        brokerOrderNo: no,
        symbol: r.symbol,
        side: r.side,
        quantity: dq,
        price: divide(da, Decimal.fromInt(dq)),
        cumulativeQuantity: r.cumFilledQty,
        cumulativeAmount: r.cumFilledAmount,
      ),
    );
  }
  return out;
}

/// 🆕 E10e1 — 기록된 누적의 저장 꼴(`broker_orders.raw_response` · R38 Z4) — 마지막으로 본 원주문 행의 누적 칸.
///
/// 🔴 계좌 · 연락처 칸은 넣지 않는다. 누적 금액은 문자열(정확한 Decimal)이다 — 실행 행 단가는 REAL 이라
///    Σ 수량 × 단가로는 정확한 누적을 되살리지 못한다.
String recordedFillJson(DailyFillRow row, DateTime seenAtUtc) =>
    jsonEncode(<String, Object?>{
      'tot_ccld_qty': row.cumFilledQty,
      'tot_ccld_amt': row.cumFilledAmount.toString(),
      'rmn_qty': row.remainingQty,
      'cncl_cfrm_qty': row.cancelConfirmedQty,
      'seen_at': seenAtUtc.toUtc().toIso8601String(),
    });

/// [recordedFillJson] 의 역 — 꼴이 틀리면 FormatException.
RecordedFill parseRecordedFillJson(String raw) {
  final Object? j = jsonDecode(raw);
  if (j is! Map<String, Object?> ||
      j['tot_ccld_qty'] is! int ||
      j['tot_ccld_amt'] is! String) {
    throw const FormatException('기록된 누적의 꼴이 틀렸다');
  }
  return RecordedFill(
    j['tot_ccld_qty']! as int,
    Decimal.parse(j['tot_ccld_amt']! as String),
  );
}

/// 🆕 E10e2 — [recordedFillJson] 의 취소 확인 누적(이월 실효 수량 · R39 T2) — 꼴이 틀리면 FormatException.
int parseRecordedCancelJson(String raw) {
  final Object? j = jsonDecode(raw);
  if (j is! Map<String, Object?> || j['cncl_cfrm_qty'] is! int) {
    throw const FormatException('기록된 취소 확인의 꼴이 틀렸다');
  }
  return j['cncl_cfrm_qty']! as int;
}

/// 누적 평균 체결 단가(`broker_orders.avg_fill_price` · REAL 저장용) — 누적 0 이면 null.
double? averageFillPrice(DailyFillRow row) => row.cumFilledQty == 0
    ? null
    : demoteToDouble(
        divide(row.cumFilledAmount, Decimal.fromInt(row.cumFilledQty)),
      );

/// 매수 체결 뒤 평단(`positions.avg_price` · R38 Z6) — Decimal 로 셈한다(곱셈 먼저 · 나눗셈 나중 · 규약 ④).
double averagePriceAfterBuy({
  required int heldQty,
  required double heldAvg,
  required FillDelta buy,
}) {
  if (buy.side != OrderSide.buy) {
    throw ArgumentError.value(buy.side, 'buy', '매수 체결이 아니다');
  }
  final int q1 = heldQty + buy.quantity;
  if (heldQty < 0 || q1 <= 0) {
    throw ArgumentError.value(heldQty, 'heldQty', '보유 수량이 앞뒤가 안 맞는다');
  }
  return demoteToDouble(
    divide(
      multiply(Decimal.fromInt(heldQty), promoteRatio(heldAvg)) +
          multiply(Decimal.fromInt(buy.quantity), buy.price),
      Decimal.fromInt(q1),
    ),
  );
}
