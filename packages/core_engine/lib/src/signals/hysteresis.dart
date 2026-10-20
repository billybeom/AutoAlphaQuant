// 국면 히스테리시스 — `06_시스템설계/03_알고리즘.md` §1-7(방향) · §1-8(추세성) · 05 GV-4 계열.
//
// 참조 구현 = `09_백테스트/백테스트6/engine/regime.py` `apply_hysteresis` · `apply_trend_hysteresis`.
// 🔴 두 함수 모두 **봉 하나**를 처리한다 — 이번 봉까지의 시리즈를 받고, 돌려준 상태를 다음 봉의
//    직전 상태로 넘긴다(03 §1-7 «호출 규약»). GV-4 는 25봉이므로 25번 부른다.
// 🔴 `INSUFFICIENT_DATA` 인 봉에서는 이 함수를 부르지 않는다 — 그 봉의 처리(UNKNOWN 보고 ·
//    나이 유지 · 추세성 상태 유지)는 호출자 몫이다(03 §1-1 · §1-7 v1.4 표).

import 'regime_states.dart';

/// 방향 히스테리시스 설정(03 §1-7 상수 — 값은 config 에서 온다).
class DirectionHysteresis {
  /// 설정을 만든다. 규칙 밖이면 [ArgumentError].
  DirectionHysteresis({
    required this.up,
    required this.down,
    required this.confirmBars,
    required this.minHoldBars,
  }) {
    if (!(down < up)) {
      throw ArgumentError('down < up 이어야 한다: $down / $up');
    }
    if (confirmBars < 1) {
      throw ArgumentError.value(confirmBars, 'confirmBars', '1 이상이어야 한다');
    }
    if (minHoldBars < 0) {
      throw ArgumentError.value(minHoldBars, 'minHoldBars', '0 이상이어야 한다');
    }
  }

  /// 상방 임계(strict `>`).
  final double up;

  /// 하방 임계(strict `<`).
  final double down;

  /// 확인 봉 수.
  final int confirmBars;

  /// 최소 유지 기간 — 🔴 익스포저가 **늘어나는** 전이에만 적용한다.
  final int minHoldBars;
}

/// 추세성 히스테리시스 설정(03 §1-8 상수 — 값은 config 에서 온다).
class TrendHysteresis {
  /// 설정을 만든다. 규칙 밖이면 [ArgumentError].
  TrendHysteresis({
    required this.trendIn,
    required this.trendOut,
    required this.confirmBars,
  }) {
    if (!(trendIn < trendOut)) {
      throw ArgumentError('trendIn < trendOut 이어야 한다: $trendIn / $trendOut');
    }
    if (confirmBars < 1) {
      throw ArgumentError.value(confirmBars, 'confirmBars', '1 이상이어야 한다');
    }
  }

  /// 저추세 진입(strict `<`).
  final double trendIn;

  /// 저추세 해제(strict `>`).
  final double trendOut;

  /// 확인 봉 수.
  final int confirmBars;
}

/// 방향 히스테리시스 한 봉(03 §1-7 ①~⑤).
///
/// [directionSeries] 의 마지막 값이 이번 봉이다. null 은 결측이다.
({DirectionState state, int barsInState}) applyHysteresis(
  List<double?> directionSeries,
  DirectionState previousState,
  int barsInState,
  DirectionHysteresis config,
) {
  // ① 🔴 판정 «전»에 나이를 1 늘린다.
  final int newBars = barsInState + 1;
  ({DirectionState state, int barsInState}) stay() =>
      (state: previousState, barsInState: newBars);

  // ② 길이 가드 · ③ 결측 가드 — 둘 다 전환하지 않는다(fail-closed).
  final List<double>? window = _window(directionSeries, config.confirmBars);
  if (window == null) return stay();

  // ④ 세 구간은 겹치지 않는다 — above·below 는 strict, mid 는 양 끝 포함.
  final bool above = window.every((double v) => v > config.up);
  final bool below = window.every((double v) => v < config.down);
  final bool mid = window.every(
    (double v) => config.down <= v && v <= config.up,
  );

  // ⑤ 🔴 최소 유지 기간은 익스포저가 늘어나는 전이에만 — 축소(→BEAR · BULL→NEUTRAL)는 즉시.
  if (below && previousState != DirectionState.bear) {
    return (state: DirectionState.bear, barsInState: 0);
  }
  if (mid && previousState != DirectionState.neutral) {
    if (previousState == DirectionState.bull || newBars >= config.minHoldBars) {
      return (state: DirectionState.neutral, barsInState: 0);
    }
    return stay();
  }
  if (above && previousState != DirectionState.bull) {
    if (newBars >= config.minHoldBars) {
      return (state: DirectionState.bull, barsInState: 0);
    }
    return stay();
  }
  return stay(); // 혼재 · 이미 그 상태 — 같은 상태로의 «재전환»은 전환이 아니다
}

/// 추세성 히스테리시스 한 봉(03 §1-8 `apply_trend_hysteresis`). 초기 상태는 LOW(fail-closed).
TrendState applyTrendHysteresis(
  List<double?> trendinessSeries,
  TrendState previousTrend,
  TrendHysteresis config,
) {
  final List<double>? window = _window(trendinessSeries, config.confirmBars);
  if (window == null) return previousTrend;
  if (window.every((double v) => v < config.trendIn)) return TrendState.low;
  if (window.every((double v) => v > config.trendOut)) return TrendState.high;
  return previousTrend; // dead-band(양 끝 포함) · 혼재 — 직전 상태 유지
}

/// 마지막 [count] 개. 모자라거나 결측(null · NaN)이 섞이면 null — 판정하지 않는다.
///
/// 🔴 결측을 «버리고 남은 값으로» 판정하지 않는다 — 빈 창의 `every` 는 참이라
///    데이터가 하나도 없는데 전환된다(05 GV-4b n2).
List<double>? _window(List<double?> series, int count) {
  if (series.length < count) return null;
  final List<double> out = <double>[];
  for (final double? v in series.sublist(series.length - count)) {
    if (v == null || v.isNaN) return null;
    out.add(v);
  }
  return out;
}
