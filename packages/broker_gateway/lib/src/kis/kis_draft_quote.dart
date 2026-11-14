// KIS 현재가 → 초안 시세 · 현재가(E11p3b-2 · 설계 13 §8 R91 · 03 §5-3 · R34 U3 · R37 Y1).
//
// 🔴 지정가 = 직전 세션 원 종가 × (1 ± 여유) → 호가 단위 · 오늘 상 · 하한 안(03 §5-3). 재료 = KIS 현재가 한 번:
//    기준가 `stck_sdpr` → 직전 종가 · `aspr_unit` → 호가 단위 · `stck_mxpr` / `stck_llam` → 상 · 하한(R37 Y1).
//    R91: 기준가를 쓴다 — 거래소 상 · 하한이 기준가에서 나오므로 초안이 오늘 가격 띠 안에 남는다(권리락 날에도).
// 🔴 거래정지 = 시세 없음 · 정지 여부를 모르면(칸 없음) 역시 없음(fail-closed) · 칸 하나라도 없으면 없음.
//    값이 앞뒤가 안 맞으면 그대로 넘긴다(초안기가 QUOTE_INVALID 로 가른다).

import 'package:core_engine/core_engine.dart' show DraftQuote;
import 'package:decimal/decimal.dart';

import 'kis_quotes.dart' show KisPrice;

/// 현재가 한 종목 조회(`KisQuotes.domesticPrice` · 시험이 가짜를 넣는다).
typedef KisPriceFetch = Future<KisPrice> Function(String code);

/// KIS 현재가 → 초안 시세(정지 · 정지 모름 · 칸 없음 = null).
DraftQuote? draftQuoteOf(KisPrice p) {
  final Decimal? base = p.basePrice;
  final Decimal? tick = p.tickSize;
  final Decimal? up = p.upperLimit;
  final Decimal? low = p.lowerLimit;
  if (p.halted != false ||
      base == null ||
      tick == null ||
      up == null ||
      low == null) {
    return null;
  }
  return DraftQuote(
    previousClose: base,
    tickSize: tick,
    upperLimit: up,
    lowerLimit: low,
  );
}

/// 한도 입력의 현재가(R91) — 정지 · 0 이하 · 유한하지 않음 = null(잴 수 없음 → 한도 입력이 던진다).
Future<Decimal?> Function(String symbol) kisCurrentPrice(KisPriceFetch fetch) =>
    (String symbol) async {
      final KisPrice p = await fetch(symbol);
      if (p.halted ?? false) return null;
      if (!p.price.isFinite || p.price <= 0) return null;
      return Decimal.parse(p.price.toString());
    };
