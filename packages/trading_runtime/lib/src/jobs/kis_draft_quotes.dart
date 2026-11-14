// 초안 시세 — KIS 현재가 어댑터(E11p3b-2 · 설계 13 §8 R91 · 변환 = broker_gateway `draftQuoteOf`).
//
// 🔴 조회 자체가 실패하면(네트워크 · KIS 오류) **던진다** — 일부 종목만 빠진 채 매수 · 매도가 갈라져 나가지 않게
//    배치 전체가 실패하고 늦은 끝 안에서 다음 깨어남에 다시 돈다. 정지 · 칸 없음 종목만 빠진다(초안기가 사유로 남긴다).
// 🔵 차례대로 한 종목씩 부른다(KIS 초당 호출 한도 · P0S 는 여섯 종목 안팎).

import 'package:broker_gateway/broker_gateway.dart'
    show KisPriceFetch, KisQuotes, draftQuoteOf;
import 'package:core_engine/core_engine.dart' show DraftQuote;

import 'kr_order_jobs.dart' show DraftQuoteSource;

/// KIS 초안 시세.
class KisDraftQuotes implements DraftQuoteSource {
  /// 만든다.
  KisDraftQuotes(this._fetch);

  /// [quotes] 의 국내 현재가로 만든다.
  factory KisDraftQuotes.of(KisQuotes quotes) =>
      KisDraftQuotes(quotes.domesticPrice);

  final KisPriceFetch _fetch;

  @override
  Future<Map<String, DraftQuote>> quotesFor(Set<String> symbols) async {
    final Map<String, DraftQuote> out = <String, DraftQuote>{};
    for (final String s in symbols.toList()..sort()) {
      final DraftQuote? q = draftQuoteOf(await _fetch(s));
      if (q != null) out[s] = q;
    }
    return out;
  }
}
