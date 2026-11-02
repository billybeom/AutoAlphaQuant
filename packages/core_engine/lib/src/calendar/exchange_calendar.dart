// 거래소 캘린더 — 세션 판정 · 월 마지막 세션 · n번째 세션 뒤 · 앞(06 M1-6 · 05 GV-12 · GV-12c · 03 §4-3).
//
// 🔴 세션은 «데이터»로 받는다. KRX 휴장일은 음력 명절·임시공휴일이라 규칙으로 계산할 수 없고,
//    05 §GV-12 는 «exchange_calendars 기준 · 하드코딩 금지»다. 이 클래스는 받은 세션 목록 위에서
//    판정만 한다 — 목록의 출처(동결 표 · KIS 휴장일 API · 임시휴장 덮어쓰기)는 호출자 몫이다.
// 🔴 범위 밖 날짜는 판정하지 않는다(fail-closed) — 모르는 날을 «휴장»으로 답하면 월 마지막 세션이
//    조용히 틀린다(05 GV-12c: 2026-12-31 평일 휴장 같은 날).
// 🔵 미국 주문의 ET 거래일(GV-12b)은 P0S 에 미국 주문이 없어 보류했다(설계 13 §7 P-2).

import 'package:domain_contracts/domain_contracts.dart';

/// 시장 — `code` 는 01 §1 `market`, `mic` 는 거래소 코드(01 §1 `MIC` 상수 · 05 GV-12 v1.5).
enum Market {
  /// 한국거래소.
  kr('KR', 'XKRX'),

  /// 뉴욕증권거래소.
  us('US', 'XNYS');

  const Market(this.code, this.mic);

  /// 01 §1 의 market 값.
  final String code;

  /// MIC 코드.
  final String mic;

  /// MIC 에서 되돌린다. 모르는 값이면 [ArgumentError].
  static Market fromMic(String mic) => Market.values.firstWhere(
    (Market m) => m.mic == mic,
    orElse: () => throw ArgumentError.value(mic, 'mic', 'Market 이 아니다'),
  );
}

final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// 받은 세션 목록 위의 거래일 판정.
class ExchangeCalendar {
  ExchangeCalendar._(
    this.market,
    this._sorted,
    this._set,
    this.coverageStart,
    this.coverageEnd,
  );

  /// 캘린더를 만든다.
  ///
  /// [coverageStart]~[coverageEnd] 는 이 목록이 **빠짐없이 덮는** 날짜 범위다(양 끝 포함). 그 안에서
  /// 목록에 없는 날은 휴장으로, 밖의 날은 «모름»으로 다룬다. 형식이 틀리거나 범위 밖 세션이 있으면
  /// [ArgumentError].
  factory ExchangeCalendar({
    required Market market,
    required Iterable<TradeDate> sessions,
    required TradeDate coverageStart,
    required TradeDate coverageEnd,
  }) {
    _checkDate(coverageStart);
    _checkDate(coverageEnd);
    if (coverageStart.yyyyMmDd.compareTo(coverageEnd.yyyyMmDd) > 0) {
      throw ArgumentError('범위가 뒤집혔다: $coverageStart > $coverageEnd');
    }
    final List<String> sorted = <String>[];
    for (final TradeDate d in sessions) {
      _checkDate(d);
      if (d.yyyyMmDd.compareTo(coverageStart.yyyyMmDd) < 0 ||
          d.yyyyMmDd.compareTo(coverageEnd.yyyyMmDd) > 0) {
        throw ArgumentError('세션이 범위 밖이다: $d');
      }
      sorted.add(d.yyyyMmDd);
    }
    sorted.sort();
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1]) {
        throw ArgumentError('세션이 겹친다: ${sorted[i]}');
      }
    }
    return ExchangeCalendar._(
      market,
      List<String>.unmodifiable(sorted),
      sorted.toSet(),
      coverageStart,
      coverageEnd,
    );
  }

  /// 시장.
  final Market market;

  /// 목록이 덮는 첫날(포함).
  final TradeDate coverageStart;

  /// 목록이 덮는 마지막 날(포함).
  final TradeDate coverageEnd;

  final List<String> _sorted;
  final Set<String> _set;

  /// 거래일인가. 범위 밖이면 [StateError](모르는 날을 휴장으로 답하지 않는다).
  bool isSession(TradeDate date) {
    _checkCovered(date);
    return _set.contains(date.yyyyMmDd);
  }

  /// 그 달의 마지막 세션인가 — 달력 말일이 아니라 **거래소 기준**(05 GV-12c).
  ///
  /// 세션이 아니면 false. 그 달의 끝까지 범위가 닿지 않아 판정할 수 없으면 [StateError].
  bool isLastSessionOfMonth(TradeDate date) {
    if (!isSession(date)) return false;
    final String month = date.yyyyMmDd.substring(0, 7);
    final String? next = _nextAfter(date.yyyyMmDd);
    if (next != null) return next.substring(0, 7) != month;
    // 목록의 마지막 세션 — 그 달 끝까지 범위가 덮여 있어야 «마지막»이라고 말할 수 있다.
    if (coverageEnd.yyyyMmDd.compareTo(_lastDayOfMonth(date.yyyyMmDd)) < 0) {
      throw StateError('${market.mic} 범위가 $month 말일까지 닿지 않는다(끝 $coverageEnd)');
    }
    return true;
  }

  /// [date] 다음의 첫 세션(같은 날 제외). 범위 안에 없으면 [StateError].
  TradeDate nextSession(TradeDate date) => nthSessionAfter(date, 1);

  /// [date] 뒤 n번째 세션(03 §4-3 `nth_session_after` — 같은 날은 세지 않는다).
  TradeDate nthSessionAfter(TradeDate date, int n) {
    if (n < 1) throw ArgumentError.value(n, 'n', '1 이상이어야 한다');
    _checkCovered(date);
    int index = _upperBound(date.yyyyMmDd);
    index += n - 1;
    if (index >= _sorted.length) {
      throw StateError('${market.mic} 범위 안에 $date 뒤 $n번째 세션이 없다');
    }
    return TradeDate(_sorted[index]);
  }

  /// [date] 앞 n번째 세션(같은 날은 세지 않는다 — [nthSessionAfter] 의 거울 · 03 §5-3-1 분할 집행일).
  /// 범위 안에 없으면 [StateError].
  TradeDate nthSessionBefore(TradeDate date, int n) {
    if (n < 1) throw ArgumentError.value(n, 'n', '1 이상이어야 한다');
    _checkCovered(date);
    final int index = _lowerBound(date.yyyyMmDd) - n;
    if (index < 0) {
      throw StateError('${market.mic} 범위 안에 $date 앞 $n번째 세션이 없다');
    }
    return TradeDate(_sorted[index]);
  }

  String? _nextAfter(String day) {
    final int index = _upperBound(day);
    return index < _sorted.length ? _sorted[index] : null;
  }

  /// [day] 보다 큰 첫 원소의 위치.
  int _upperBound(String day) {
    int lo = 0;
    int hi = _sorted.length;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (_sorted[mid].compareTo(day) <= 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  /// [day] 이상인 첫 원소의 위치.
  int _lowerBound(String day) {
    int lo = 0;
    int hi = _sorted.length;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (_sorted[mid].compareTo(day) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  void _checkCovered(TradeDate date) {
    _checkDate(date);
    if (date.yyyyMmDd.compareTo(coverageStart.yyyyMmDd) < 0 ||
        date.yyyyMmDd.compareTo(coverageEnd.yyyyMmDd) > 0) {
      throw StateError(
        '${market.mic} 캘린더 범위($coverageStart~$coverageEnd) 밖이다: $date',
      );
    }
  }
}

void _checkDate(TradeDate d) {
  final String s = d.yyyyMmDd;
  if (!_isoDate.hasMatch(s)) {
    throw ArgumentError.value(s, 'date', 'YYYY-MM-DD 가 아니다');
  }
  final DateTime parsed = DateTime.utc(
    int.parse(s.substring(0, 4)),
    int.parse(s.substring(5, 7)),
    int.parse(s.substring(8, 10)),
  );
  if (parsed.toIso8601String().substring(0, 10) != s) {
    throw ArgumentError.value(s, 'date', '없는 날짜다');
  }
}

String _lastDayOfMonth(String day) {
  final int y = int.parse(day.substring(0, 4));
  final int m = int.parse(day.substring(5, 7));
  final DateTime last = DateTime.utc(y, m + 1, 0);
  return last.toIso8601String().substring(0, 10);
}
