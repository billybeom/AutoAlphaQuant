// M1-7 실전 거래소 캘린더의 출발점 — 동결 세션 표(lib 자산 · 설계 13 §8 R23 D14 · R24 B2 · E8b1).
//
// 🔴 세션은 «데이터»다 — 규칙으로 계산하지 않는다(음력 명절·임시공휴일 · 05 GV-12). 원천 = exchange_calendars 판 +
//    근거 있는 덮어쓰기(설계 13 §8 R15 · `frozen_sessions.dart` 머리 · 생성기 `tool/make_frozen_calendars.py`).
// 🔴 범위 밖은 «모름»이다(`ExchangeCalendar` 가 StateError) — 표는 2027-12-31 까지라 **연 1회 재생성**한다.
// ⏸ KIS 휴장일 API 대조(어긋나면 알림 + 덮어쓰기 목록 PR · 표 자동 수정 금지)는 E8d.

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import 'exchange_calendar.dart';
import 'frozen_sessions.dart';

/// 동결 표의 출처·범위.
class FrozenCalendarInfo {
  const FrozenCalendarInfo({
    required this.source,
    required this.coverageStart,
    required this.coverageEnd,
    required this.sessionCount,
    required this.closedOverrides,
  });

  /// 라이브러리 판(예 `exchange_calendars 4.13.2`).
  final String source;
  final TradeDate coverageStart;
  final TradeDate coverageEnd;
  final int sessionCount;

  /// 라이브러리 판에 없어 덮어쓴 휴장일(날짜 → 근거).
  final Map<String, String> closedOverrides;
}

final Map<Market, ExchangeCalendar> _cache = <Market, ExchangeCalendar>{};

(String, List<String>, String, Map<String, String>) _table(Market m) =>
    switch (m) {
      Market.kr => (
        kXkrxSessionsPacked,
        kXkrxCoverage,
        kXkrxSource,
        kXkrxClosedOverrides,
      ),
      Market.us => (
        kXnysSessionsPacked,
        kXnysCoverage,
        kXnysSource,
        kXnysClosedOverrides,
      ),
    };

List<TradeDate> _unpack(String packed) => <TradeDate>[
  for (int i = 0; i < packed.length; i += 8)
    TradeDate(
      '${packed.substring(i, i + 4)}-${packed.substring(i + 4, i + 6)}-'
      '${packed.substring(i + 6, i + 8)}',
    ),
];

/// [market] 의 동결 세션 표로 만든 캘린더(한 번 만들어 둔다).
ExchangeCalendar frozenExchangeCalendar(Market market) =>
    _cache.putIfAbsent(market, () {
      final (String packed, List<String> range, _, _) = _table(market);
      return ExchangeCalendar(
        market: market,
        sessions: _unpack(packed),
        coverageStart: TradeDate(range[0]),
        coverageEnd: TradeDate(range[1]),
      );
    });

/// [market] 동결 표의 출처·범위·덮어쓰기.
FrozenCalendarInfo frozenCalendarInfo(Market market) {
  final (
    String packed,
    List<String> range,
    String source,
    Map<String, String> overrides,
  ) = _table(
    market,
  );
  return FrozenCalendarInfo(
    source: source,
    coverageStart: TradeDate(range[0]),
    coverageEnd: TradeDate(range[1]),
    sessionCount: packed.length ~/ 8,
    closedOverrides: overrides,
  );
}
