// 01 §2-1 — 주문 방향(인벤토리 §2-3 · `advice.side` CHECK).
import 'package:freezed_annotation/freezed_annotation.dart';

enum OrderSide {
  @JsonValue('BUY')
  buy('BUY'),
  @JsonValue('SELL')
  sell('SELL');

  const OrderSide(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}
