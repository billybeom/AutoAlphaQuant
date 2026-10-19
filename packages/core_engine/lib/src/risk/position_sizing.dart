// 종목 사이징 — 이중 상한(`06_시스템설계/03_알고리즘.md` §3-4 · 05 GV-8).
//
// 🔵 v2.31 P0S 에서는 새틀라이트가 0% 라 집행 대상이 아니다(03 §3-4 비활성 배너).
//    그래도 여기 있는 이유는 GV-8 이 **Decimal 규약(M1-1)의 검증 게이트**이기
//    때문이다(06 §3-2 M1-1 · 05 §GV-8f). 새틀라이트를 되살리면 그대로 쓴다.

import 'package:decimal/decimal.dart';

import '../decimal_rules.dart';

/// 어느 상한이 수량을 정했나. `code` 는 로그·DB·골든에 적히는 값이다.
enum SizingBinding {
  /// 리스크 상한(손절까지의 손실 = 총자산 × `riskPct`).
  risk('RISK'),

  /// 명목 상한(종목당 금액 = 총자산 × `notionalCapPct`).
  notional('NOTIONAL');

  const SizingBinding(this.code);

  /// 03 §3-4 의 `binding` 문자열.
  final String code;
}

/// [sizePosition] 의 결과.
class SizingResult {
  /// 결과를 만든다 — 직접 부르지 말고 [sizePosition] 을 쓴다.
  const SizingResult({
    required this.quantity,
    required this.binding,
    required this.notionalValue,
    required this.qtyByRisk,
    required this.qtyByNotional,
  });

  /// lot 단위로 내린 주문 수량.
  final int quantity;

  /// 수량을 정한 상한. 두 후보가 같으면 [SizingBinding.risk](판정이 `<=`).
  final SizingBinding binding;

  /// `quantity × entryPrice` — 🔴 lot 내림 **후** 수량 기준(03 §3-4).
  final Decimal notionalValue;

  /// 리스크 상한 수량(내림 전).
  final Decimal qtyByRisk;

  /// 명목 상한 수량(내림 전).
  final Decimal qtyByNotional;
}

/// 이중 상한 사이징(03 §3-4).
///
/// - [accountEquity] 는 🔴 **총자산**이다. 슬리브 배정액이 아니다 — 두 상한이 같은
///   분모를 쓴다(03 §3-4 v2.8).
/// - 비율 두 개는 config 에서 온다. 🔴 기본값을 두지 않는다 — 상수가 코드에
///   숨으면 config 와 갈라진다.
/// - 입력이 규칙 밖이면 [ArgumentError](파이썬 `ValueError` 대응 · GV-8e).
SizingResult sizePosition({
  required Decimal accountEquity,
  required Decimal entryPrice,
  required Decimal stopPrice,
  required double riskPct,
  required double notionalCapPct,
  required int lotSize,
}) {
  if (entryPrice <= Decimal.zero || stopPrice <= Decimal.zero) {
    throw ArgumentError('진입가·손절가는 0 보다 커야 한다: $entryPrice / $stopPrice');
  }
  if (stopPrice >= entryPrice) {
    throw ArgumentError('손절가가 진입가 이상이다: $stopPrice >= $entryPrice');
  }
  if (lotSize <= 0) {
    throw ArgumentError.value(lotSize, 'lotSize', '1 이상이어야 한다');
  }

  final Decimal riskPerShare = entryPrice - stopPrice;

  // 🔴 곱셈 먼저, 나눗셈 나중(규약 ④) — 순서를 바꾸면 GV-8a 가 뒤집힌다.
  final Decimal qtyByRisk = mulDiv(
    accountEquity,
    promoteRatio(riskPct),
    riskPerShare,
  );
  final Decimal qtyByNotional = mulDiv(
    accountEquity,
    promoteRatio(notionalCapPct),
    entryPrice,
  );

  // 🔴 판정은 `<=` 다 — 두 값이 같으면 RISK(GV-8a).
  final SizingBinding binding = qtyByRisk <= qtyByNotional
      ? SizingBinding.risk
      : SizingBinding.notional;
  final Decimal raw = binding == SizingBinding.risk ? qtyByRisk : qtyByNotional;

  final Decimal lot = Decimal.fromInt(lotSize);
  final int quantity = divide(raw, lot).floor().toBigInt().toInt() * lotSize;

  return SizingResult(
    quantity: quantity,
    binding: binding,
    notionalValue: Decimal.fromInt(quantity) * entryPrice,
    qtyByRisk: qtyByRisk,
    qtyByNotional: qtyByNotional,
  );
}
