// 일봉 시세 원천 포트 · 끝난 세션(설계 13 §8 R30 N2·N3 · R29 L11 · E8d2b).
//
// 🔴 broker_gateway(KIS)와 data_sync(저장)는 서로를 모른다(01 §1-1) — 둘 다 이 포트만 안다. 원천이 포트를 구현하고
//    (broker_gateway `KisQuoteFeed`) 수집기가 포트를 부른다(data_sync `QuoteCollector`). 둘을 잇는 것은 잡(E11)이다.
// 🔴 포트는 **저장 이름**(`daily_prices` 의 market·symbol)으로 말한다 — 원천 코드(KIS `SPX`·`1001`)는 원천 몫(N2).
// 🔴 장중에 받은 마지막 행은 확정 종가가 아니다(L11 실측) — 수집기는 [lastFinishedSession] 까지만 저장한다(N3).

import 'package:domain_contracts/domain_contracts.dart'
    show MarketDataSource, TradeDate;

import '../calendar/exchange_calendar.dart';
import 'dated_series.dart' show minusOneDay;

/// 무엇의 일봉인가.
enum QuoteKind {
  /// 종목(ETF 포함).
  stock,

  /// 주가지수(`index` 는 열거의 예약 이름이다).
  stockIndex,
}

/// 가격 꼴 — 지수는 [raw] 하나다.
enum PriceAdjust {
  /// 원(분배·분할 반영 전).
  raw,

  /// 수정(분배금·분할 반영).
  adjusted,
}

/// 원천이 준 일봉 한 행(판정 전 · 모르면 null).
class QuoteBar {
  const QuoteBar({
    required this.date,
    required this.close,
    this.open,
    this.high,
    this.low,
    this.volume,
    this.tradeValue,
  });

  /// `YYYY-MM-DD`(그 시장의 현지 거래일).
  final String date;
  final double close;
  final double? open, high, low, volume, tradeValue;
}

/// 한 번 받은 결과.
class QuoteFetch {
  const QuoteFetch({
    required this.bars,
    required this.pageBodies,
    required this.attempts,
  });

  /// 요청 범위의 일봉(날짜 오름차순 · 같은 날 하나).
  final List<QuoteBar> bars;

  /// 받은 쪽 본문(받은 순서 · 원문) — 원장에는 sha256 만 남긴다(N6).
  final List<String> pageBodies;

  /// 보낸 횟수(재시도 포함).
  final int attempts;
}

/// 끝내 받지 못했다(재시도 소진 · 토큰 · 업무 거절 — N7).
class QuoteFeedDown implements Exception {
  const QuoteFeedDown(this.reason, {required this.attempts});

  /// 엔진 문장(주소·키·토큰·계좌 없음).
  final String reason;
  final int attempts;

  @override
  String toString() => 'QuoteFeedDown($reason · 시도 $attempts)';
}

/// 일봉 원천 포트.
abstract interface class DailyQuoteFeed {
  /// 이 원천(`fetch_log.source` · 행 `source`).
  MarketDataSource get source;

  /// [market]·[symbol] 의 [from]~[to](ISO · 둘 다 포함) 일봉.
  ///
  /// 받지 못하면 [QuoteFeedDown] · 원천이 모르는 이름이면 [ArgumentError](지어내지 않는다).
  Future<QuoteFetch> daily({
    required Market market,
    required String symbol,
    required QuoteKind kind,
    PriceAdjust adjust = PriceAdjust.raw,
    required String from,
    required String to,
  });
}

/// KR 세션 d 의 값이 확정되는 시각 = **d 18:00 KST**(정규장 15:30 · 시간외 단일가 18:00 · N3).
const int kKrSessionFinalHourKst = 18;

/// US 세션 d 의 값이 확정되는 시각 = **d+1 07:00 KST**(16:00 EDT = 05:00 · EST = 06:00 + 여유 1h · N3).
const int kUsSessionFinalHourKst = 7;

/// [cal] 의 세션 중 [nowUtc] 에 값이 확정된 마지막 날(`YYYY-MM-DD`).
///
/// 동결 달력 범위 밖이면 [StateError](모르는 날을 지어내지 않는다).
String lastFinishedSession(ExchangeCalendar cal, DateTime nowUtc) {
  final DateTime kst = nowUtc.toUtc().add(const Duration(hours: 9));
  final String today = kst.toIso8601String().substring(0, 10);
  final String cap = switch (cal.market) {
    Market.kr =>
      kst.hour >= kKrSessionFinalHourKst ? today : minusOneDay(today),
    Market.us =>
      kst.hour >= kUsSessionFinalHourKst
          ? minusOneDay(today)
          : minusOneDay(minusOneDay(today)),
  };
  return lastSessionAtOrBefore(cal, cap);
}

/// [day] 이하의 마지막 세션 — 40일 안에 없으면 [StateError].
String lastSessionAtOrBefore(ExchangeCalendar cal, String day) {
  String d = day;
  for (int i = 0; i < 40; i++) {
    if (cal.isSession(TradeDate(d))) return d;
    d = minusOneDay(d);
  }
  throw StateError('${cal.market.mic} — $day 앞 40일 안에 세션이 없다');
}
