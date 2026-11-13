// 🆕 E15c1 — 가상 체결가(주문 세션 당일 봉 · 설계 13 §8 R83 Y2 · SPEC v2.44 04 §3-1 v2.44 ③).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String v) => Decimal.parse(v);

Decimal? _fill(
  OrderSide side, {
  String type = kVirtualLimitOrder,
  String? limit = '100',
  String? open = '100',
  String? high = '110',
  String? low = '90',
}) => virtualFillPrice(
  side: side,
  orderType: type,
  limitPrice: limit == null ? null : _d(limit),
  open: open == null ? null : _d(open),
  high: high == null ? null : _d(high),
  low: low == null ? null : _d(low),
);

void main() {
  test('매수 — 시가 ≤ 지정가 = 시가(같음 포함) · 저가 ≤ 지정가 = 지정가(같음 포함) · 아니면 미체결', () {
    expect(_fill(OrderSide.buy, open: '95'), _d('95'));
    expect(_fill(OrderSide.buy, open: '100'), _d('100'));
    expect(_fill(OrderSide.buy, open: '105', low: '99'), _d('100'));
    expect(_fill(OrderSide.buy, open: '105', low: '100'), _d('100'));
    expect(_fill(OrderSide.buy, open: '105', low: '101'), isNull);
    expect(_fill(OrderSide.buy, open: '105', low: null), isNull);
  });

  test('매도 — 시가 ≥ 지정가 = 시가(같음 포함) · 고가 ≥ 지정가 = 지정가(같음 포함) · 아니면 미체결', () {
    expect(_fill(OrderSide.sell, open: '105'), _d('105'));
    expect(_fill(OrderSide.sell, open: '100'), _d('100'));
    expect(_fill(OrderSide.sell, open: '95', high: '101'), _d('100'));
    expect(_fill(OrderSide.sell, open: '95', high: '100'), _d('100'));
    expect(_fill(OrderSide.sell, open: '95', high: '99'), isNull);
    expect(_fill(OrderSide.sell, open: '95', high: null), isNull);
  });

  test('시가 주문 = 시가 · 시가 없음 = 미체결 · 지정가 없는 지정가 주문 · 모르는 꼴 = 미체결', () {
    expect(
      _fill(OrderSide.buy, type: kVirtualMarketOrder, limit: null, open: '123'),
      _d('123'),
    );
    expect(
      _fill(OrderSide.sell, type: kVirtualMarketOrder, limit: null, open: '77'),
      _d('77'),
    );
    expect(_fill(OrderSide.buy, open: null), isNull);
    expect(_fill(OrderSide.buy, type: kVirtualMarketOrder, open: null), isNull);
    expect(_fill(OrderSide.buy, limit: null), isNull);
    expect(_fill(OrderSide.buy, type: 'STOP'), isNull);
    expect((kVirtualLimitOrder, kVirtualMarketOrder), ('LIMIT', 'MARKET'));
  });
}
