// 가상 체결가(SPEC v2.44 04 §3-1 v2.44 ③ · 앱 06 X6-3 · 설계 13 §8 R80 D4 · R83 Y2).
//
// 🔴 «주문 세션 당일 봉» 규칙 — 신호(T) → 주문 세션(T+1)이라 청사진 ⑰ «다음 거래일 시가»의 뜻과 같다.
//    매수 = 시가 ≤ 지정가면 시가 · 아니면 저가 ≤ 지정가면 지정가 · 아니면 미체결 / 매도 = 대칭(고가).
// 🔴 지정가보다 나쁜 체결을 만들지 않는다(보수 쪽) · 전량 또는 0(부분 체결 없음) · 봉 값이 빠지면 미체결(지어내지 않는다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show OrderSide;

/// 시가 주문 표기(order_intents.order_type).
const String kVirtualMarketOrder = 'MARKET';

/// 지정가 주문 표기.
const String kVirtualLimitOrder = 'LIMIT';

/// 🔴 그날 봉으로 본 가상 체결가 — 체결 안 됨 = null.
Decimal? virtualFillPrice({
  required OrderSide side,
  required String orderType,
  required Decimal? limitPrice,
  required Decimal? open,
  required Decimal? high,
  required Decimal? low,
}) {
  if (open == null) return null;
  if (orderType == kVirtualMarketOrder) return open;
  if (orderType != kVirtualLimitOrder || limitPrice == null) return null;
  return switch (side) {
    OrderSide.buy =>
      open <= limitPrice
          ? open
          : (low != null && low <= limitPrice ? limitPrice : null),
    OrderSide.sell =>
      open >= limitPrice
          ? open
          : (high != null && high >= limitPrice ? limitPrice : null),
  };
}
