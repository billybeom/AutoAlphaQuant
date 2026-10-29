// KIS 일봉 → core_engine 일봉 원천 포트(설계 13 §8 R30 N2·N6·N7 · E8d2b).
//
// 🔴 저장 이름(`daily_prices` 의 market·symbol) → KIS 코드 대응은 여기만 안다(N2) — 표에 없는 이름은
//    [ArgumentError](지어내지 않는다). data_sync 는 KIS 를 모르고 이 패키지는 SQLite 를 모른다(01 §1-1).
// 🔴 실패는 모두 [QuoteFeedDown] 하나로 — 재시도 소진([KisUnavailable]) · 토큰([KisTokenError]) · 업무 거절([KisRejected]).
//    [KisGuardError](환경 불일치)는 그대로 던진다 — 설정 오류는 수집 실패가 아니다(N7).
// 🔴 사유 문장 = 각 오류의 엔진 문장 + 서버 메시지 — 주소·키·토큰·계좌가 없다.

import 'package:core_engine/core_engine.dart'
    show
        DailyQuoteFeed,
        Market,
        PriceAdjust,
        QuoteBar,
        QuoteFeedDown,
        QuoteFetch,
        QuoteKind;
import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;

import 'kis_quotes.dart';
import 'kis_rest_client.dart';

/// 미국 지수 — 저장 이름 → KIS 해외지수 코드(`FID_COND_MRKT_DIV_CODE=N` · 실험 5).
const Map<String, String> kKisUsIndexCodes = <String, String>{'^GSPC': 'SPX'};

/// 국내 지수 — 저장 이름 → KIS 업종 코드(실험 5).
const Map<String, String> kKisKrIndexCodes = <String, String>{'KQ11': '1001'};

/// 미국 종목 — 심볼 → KIS 거래소 코드(`EXCD` · 실험 5 = NYSE Arca `AMS`).
const Map<String, String> kKisUsExchanges = <String, String>{
  'SPY': 'AMS',
  'RSP': 'AMS',
};

final RegExp _krCode = RegExp(r'^[0-9A-Z]{6}$');

/// KIS 시세를 포트로.
class KisQuoteFeed implements DailyQuoteFeed {
  KisQuoteFeed(this._client);

  final KisRestClient _client;

  @override
  MarketDataSource get source => MarketDataSource.kis;

  @override
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  }) async {
    final List<String> bodies = <String>[];
    int attempts = 0;
    final KisQuotes q = KisQuotes(
      _client,
      onPage: (KisResponse r) {
        attempts += r.attempts;
        final String? t = r.text;
        if (t != null) bodies.add(t);
      },
    );
    final bool adj = adjust == PriceAdjust.adjusted;
    final Future<List<KisBar>> Function() call = switch ((market, kind)) {
      (Market.kr, QuoteKind.stock) => () => q.domesticDaily(
        _need(_krCode.hasMatch(symbol), symbol, symbol),
        from: from,
        to: to,
        adjusted: adj,
      ),
      (Market.kr, QuoteKind.stockIndex) => () => q.domesticIndexDaily(
        _need(!adj, kKisKrIndexCodes[symbol], symbol),
        from: from,
        to: to,
      ),
      (Market.us, QuoteKind.stock) => () => q.overseasDaily(
        _need(true, kKisUsExchanges[symbol], symbol),
        symbol,
        from: from,
        to: to,
        adjusted: adj,
      ),
      (Market.us, QuoteKind.stockIndex) => () => q.overseasIndexDaily(
        _need(!adj, kKisUsIndexCodes[symbol], symbol),
        from: from,
        to: to,
      ),
    };
    final List<KisBar> got;
    try {
      got = await call();
    } on KisUnavailable catch (e) {
      throw QuoteFeedDown(e.reason, attempts: attempts + e.attempts);
    } on KisRejected catch (e) {
      throw QuoteFeedDown(
        <String>['업무 거절 ${e.trId}', ?e.msgCd, ?e.msg1].join(' '),
        attempts: attempts,
      );
    } on KisTokenError catch (e) {
      throw QuoteFeedDown(
        <String>[
          '토큰 발급 실패',
          e.errorCode ?? 'HTTP ${e.status ?? '-'}',
          if (e.rateLimited) '1분 1회 제한',
        ].join(' · '),
        attempts: attempts,
      );
    }
    return QuoteFetch(
      bars: <QuoteBar>[
        for (final KisBar b in got)
          QuoteBar(
            date: b.date,
            close: b.close,
            open: b.open,
            high: b.high,
            low: b.low,
            volume: b.volume,
            tradeValue: b.tradeValue,
          ),
      ],
      pageBodies: bodies,
      attempts: attempts,
    );
  }
}

/// [ok] 이고 [code] 가 있으면 [code] — 아니면 [ArgumentError](대응표 밖 · 지수에 수정 꼴).
String _need(bool ok, String? code, String symbol) {
  if (!ok || code == null) {
    throw ArgumentError.value(symbol, 'symbol', 'KIS 대응표에 없다(또는 지수에 수정 꼴)');
  }
  return code;
}
