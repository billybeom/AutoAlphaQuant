// M1-7 시점 정렬(PIT) — 발표 지연 · as-of · 미국 → 한국 날짜 매핑(설계 13 §8 R23 D13 · R24 B2 · E8b1).
//
// 🔵 E6 재현 하네스(`test/replay/replay_regime.dart` · `replay_market.dart` · `replay_engine.dart`)에서 옮겼다 —
//    하네스가 이 함수들을 부르므로 26년 재현 비트 일치가 회귀 시험이다(참조 엔진 백테스트6 `regime._align` ·
//    `market._to_kr_calendar` · `Backtest._prep` 국면 정렬).
// 🔴 미국 값을 한국 날짜에 붙이는 방법은 **둘**이고, 어느 쪽을 쓰는지가 룩어헤드를 가른다(07_검증원장 §6-1):
//    ① [toKrCalendar] — 한국 세션 d 에 «d 보다 엄격히 앞선 날짜»의 미국 값(국내상장 미국 ETF 가격 · 새틀라이트).
//       미국장은 한국장 마감 뒤에 열리므로 같은 날짜를 쓰면 미래를 본다.
//    ② [alignAsOfInclusive] — «d 이하(같은 날짜 포함)»의 마지막 값(참조 엔진의 **국면** 정렬). KR 월말 d 의 판정에
//       미국 d 종가(KST d+1 새벽)가 들어간다 → 실전은 R23 D13 (c) 대로 **월말 판정을 다음 날 아침(미국 종가 뒤)**에
//       하고 집행은 그대로 다음 세션(같은 정보 · 같은 세션 — 잡 시각은 E11). 오늘 저녁(KST 20:00) 판정은 ①을 쓴다.
// 🔴 발표 지연(달력일)은 매크로·신용 계열이 «그 날짜에 실제로 알 수 있었던» 값만 쓰게 한다 — 지연을 빼면 백테스트가
//    미래 발표치를 본다(03 §1-1 · 참조 엔진 `PUBLISH_LAG`).

import 'dated_series.dart';

/// 참조 엔진 `PUBLISH_LAG`(달력일) — 지표 이름 → 지연.
const Map<String, int> kPublishLagDays = <String, int>{
  'nfci': 7,
  'ofr_fsi': 1,
  'yield_curve': 1,
  'cfnai_ma3': 55,
  'sahm': 40,
};

/// 참조 엔진 `_align(s, cal, lag)` — 결측 제거 → 날짜 + [lag] 달력일 → 중복은 뒤쪽 → as-of 로 [calendar] 에.
DatedSeries alignWithLag(DatedSeries s, List<String> calendar, {int lag = 0}) {
  final DatedSeries x = s.dropNa();
  final Map<String, double> byDate = <String, double>{};
  for (int i = 0; i < x.length; i++) {
    byDate[lag == 0 ? x.dates[i] : plusDays(x.dates[i], lag)] = x.values[i];
  }
  final List<String> dates = byDate.keys.toList()..sort();
  return DatedSeries(dates, <double>[
    for (final String d in dates) byDate[d]!,
  ]).asOf(calendar);
}

/// ① `_to_kr_calendar` + `ffill` — 한국 세션 d 마다 «d − 1 달력일 이하» 마지막 미국 값(엄격히 앞선 날).
DatedSeries toKrCalendar(DatedSeries us, List<String> krSessions) =>
    DatedSeries(krSessions, <double>[
      for (final String d in krSessions)
        () {
          final int p = us.lastAtOrBefore(minusOneDay(d));
          return p >= 0 ? us.values[p] : double.nan;
        }(),
    ]).ffill();

/// ② 같은 날짜 포함 as-of — [days] 의 날마다 «그날 이하» [s] 의 마지막 값(결측은 먼저 버린다 · 없으면 NaN).
/// 참조 엔진의 국면 정렬(`fsm.reindex(fsm.index ∪ all_days).ffill().reindex(all_days)`)과 같다.
DatedSeries alignAsOfInclusive(DatedSeries s, List<String> days) =>
    s.dropNa().asOf(days);
