// 4월 말 계절 청산 비율 — `06_시스템설계/03_알고리즘.md` §5-3-2 · 05 GV-23 · GV-38(v2.19).
//
// 🔴 v2.19 기본값 = 전량(`seasonality.partial.enabled: false`) — 점수와 무관하게 1.0(05 GV-38).
//    P0S 는 이 경로다(참조 원장 4월 청산 78건 전부 `partial_off`).
// 🔴 enabled 경로(GV-23 · A13 비교용): 추세가 강할수록 **덜 판다** — `1 − score/100`.
//    점수 없음(워밍업·결측) · min_score 미만이면 전량(fail-closed). 40 에서 의도된 불연속.
// 🔵 `trend_score_kr` 은 KOSDAQ TREND 4지표 점수다(미국 방향 스코어가 아니다) — 계산은 호출자 몫.
// 🔵 비율을 종목에 나누는 일(§5-3-2 v2.9 보유수량 비례 · floor)은 주문 산출의 몫이다. P0S 의 A 는 ETF 하나다.
// ⚠️ 참조 엔진의 변형 키(`seasonal_partial_max_keep` · `seasonal_keep_strong_score`)는 명세(02 §4)에 없고
//    P0S 에서 꺼져 있어 옮기지 않았다.

/// 03 §5-3-2 `seasonal_exit_fraction` — 4월 말에 **매도할** 비중 0~1.
double seasonalExitFraction(
  double? trendScoreKr, {
  required bool partialEnabled,
  required double minScore,
}) {
  if (!partialEnabled) return 1.0;
  if (trendScoreKr == null || trendScoreKr.isNaN) return 1.0;
  if (trendScoreKr > 100.0) {
    // 백분위 평균이라 100 을 넘을 수 없다 — 넘으면 매도 비율이 음수가 된다.
    throw ArgumentError.value(trendScoreKr, 'trendScoreKr', '0~100 이어야 한다');
  }
  if (trendScoreKr < minScore) return 1.0;
  return 1.0 - trendScoreKr / 100.0;
}
