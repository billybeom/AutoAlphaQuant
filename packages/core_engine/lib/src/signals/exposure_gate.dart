// 익스포저 게이트 — 곱셈 구조(`06_시스템설계/03_알고리즘.md` §1-8 · 05 GV-3·GV-3c).
//
// 🔴 더하기나 조건 분기가 아니라 **곱셈**이다. 방향이 BEAR 면 추세성과 무관하게
//    0 이어야 한다(«저추세면 무조건 50%»는 완만한 하락장에서 절반을 들고 간다).
// 🔴 UNKNOWN 은 0 이다(fail-closed). 조회표에 기본값 1.0 을 두는 구현은 GV-3 기본
//    6건을 다 통과하고도 장애일에 100% 를 연다 — GV-3c 가 그것을 잡는다.
// 🔵 슬리브별 승수(`exposure_multiplier` dict · GV-18)와 추세성 히스테리시스(GV-4f)는
//    E2(M1-2) 몫이다.

import 'regime_states.dart';

/// 익스포저 = f(방향) × g(추세성). 비율이라 double 이다(01 §0 «비율·스코어 = float»).
double exposureGate(DirectionState direction, TrendState trend) =>
    _directionFactor(direction) * _trendFactor(trend);

double _directionFactor(DirectionState direction) => switch (direction) {
  DirectionState.bull => 1.0,
  DirectionState.neutral => 0.5,
  DirectionState.bear => 0.0,
  DirectionState.unknown => 0.0,
};

double _trendFactor(TrendState trend) => switch (trend) {
  TrendState.high => 1.0,
  TrendState.low => 0.5,
};
