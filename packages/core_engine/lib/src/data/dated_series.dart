// M1-7 날짜 시리즈 — 외부 시계열(시세·지수·매크로)을 담는 한 꼴(설계 13 §8 R23 · R24 B2 · E8b1).
//
// 🔵 E6 재현 하네스(`test/replay/replay_market.dart`)에서 그대로 옮겼다 — 하네스도 이것을 부른다. 그래서 26년 재현이
//    비트로 같으면 이 꼴의 as-of·ffill·dropna 가 참조 엔진(pandas)과 같다는 회귀 시험이 된다.
// 🔴 pandas 의 연산 순서를 따른다(«더 맞게» 고치지 않는다) — 정답지가 비트로 본다.
// 🔴 날짜 = `YYYY-MM-DD` 문자열(오름차순 · 중복 없음) · 값 = double(NaN = 결측). 금액(원)이 아니라 지표·지수 값이라
//    Decimal 을 쓰지 않는다 — 돈의 계산은 이 꼴을 거치지 않는다.

/// 날짜(YYYY-MM-DD · 오름차순 · 중복 없음)와 값(NaN = 결측).
class DatedSeries {
  /// 시리즈를 만든다. 길이가 다르면 [ArgumentError].
  DatedSeries(this.dates, this.values) {
    if (dates.length != values.length) {
      throw ArgumentError('날짜 ${dates.length} · 값 ${values.length}');
    }
  }

  /// 날짜.
  final List<String> dates;

  /// 값.
  final List<double> values;

  /// 길이.
  int get length => dates.length;

  /// pandas `dropna()`.
  DatedSeries dropNa() {
    final List<String> d = <String>[];
    final List<double> v = <double>[];
    for (int i = 0; i < length; i++) {
      if (!values[i].isNaN) {
        d.add(dates[i]);
        v.add(values[i]);
      }
    }
    return DatedSeries(d, v);
  }

  /// [date] 이하 마지막 위치(없으면 −1) — `searchsorted(date, side="right") − 1`.
  int lastAtOrBefore(String date) {
    int lo = 0;
    int hi = length;
    while (lo < hi) {
      final int mid = (lo + hi) >> 1;
      if (dates[mid].compareTo(date) <= 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo - 1;
  }

  /// `reindex(idx ∪ target).sort_index().ffill().reindex(target)` — 결측 없는 시리즈에서 «그날 이하 마지막 값».
  /// 🔴 호출자는 [dropNa] 한 시리즈에만 쓴다(참조 엔진의 모든 as-of 호출이 그렇다).
  DatedSeries asOf(List<String> target) => DatedSeries(target, <double>[
    for (final String t in target)
      () {
        final int p = lastAtOrBefore(t);
        return p >= 0 ? values[p] : double.nan;
      }(),
  ]);

  /// `reindex(target).ffill()` — 날짜가 정확히 같은 값만 옮기고 그 뒤 앞으로 채운다.
  DatedSeries reindexFfill(List<String> target) {
    final Map<String, double> at = <String, double>{
      for (int i = 0; i < length; i++) dates[i]: values[i],
    };
    double last = double.nan;
    return DatedSeries(target, <double>[
      for (final String t in target)
        () {
          final double? v = at[t];
          if (v != null && !v.isNaN) last = v;
          return last;
        }(),
    ]);
  }

  /// `ffill()`.
  DatedSeries ffill() {
    double last = double.nan;
    return DatedSeries(dates, <double>[
      for (final double v in values)
        () {
          if (!v.isNaN) last = v;
          return last;
        }(),
    ]);
  }

  /// [date] 의 값(없으면 null).
  double? at(String date) {
    final int p = lastAtOrBefore(date);
    return p >= 0 && dates[p] == date ? values[p] : null;
  }
}

DateTime _utc(String d) => DateTime.parse('${d}T00:00:00Z');
String _ymd(DateTime t) => t.toIso8601String().substring(0, 10);

/// 두 날짜 사이 달력일(b − a).
int daysBetween(String a, String b) => _utc(b).difference(_utc(a)).inDays;

/// 하루 전 날짜.
String minusOneDay(String d) => _ymd(_utc(d).subtract(const Duration(days: 1)));

/// [d] + [n] 달력일.
String plusDays(String d, int n) => _ymd(_utc(d).add(Duration(days: n)));

/// 정렬된 두 날짜 목록의 합집합(오름차순).
List<String> unionSorted(List<String> a, List<String> b) =>
    (<String>{...a, ...b}.toList()..sort());
