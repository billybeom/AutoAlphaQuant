// 슬리브 B 3-트랜치 SMA — `06_시스템설계/03_알고리즘.md` §2-7-2 · §2-7-3 · v2.27 블록(P0 조각 ④) · 05 GV-20.
//
// 🔴 다수결이 아니다 — 룩백마다 1/3 씩 들고 있는다(2:1 이면 2/3, 1:2 면 1/3).
// 🔴 «월간 SMA» = 각 달 마지막 거래일 종가만 모은 시계열의 평균이고 **판정월 종가를 포함**한다.
//    일봉 `SMA(close, n × 21)` 로 만들지 않는다(03 §2-7-3). 월봉을 만드는 일은 호출자 몫이다.
// 🔴 워밍업(월봉 < 가장 긴 룩백)이면 0.0 — null 이 아니다(fail-closed). P0S 하한도 그때는 걸지 않는다.
// 🔴 P0S(v2.27): 하한 1/3 을 **먼저**, BEAR 차감 2/3 을 **나중에** — 차감은 승수가 아니다
//    (BEAR 에서 1 → 1/3 · 2/3 → 0 · 1/3 → 0). 하한·차감은 B 본책에만 — POT 서브북은 기본 비율만 쓴다.
// ⚠️ 참조 엔진(백테스트6 `_sleeve_b_signal`)의 평균은 `np.mean`(짝 합산)이다. 여기는 왼쪽부터 더한다 —
//    월봉 종가가 SMA 와 마지막 자리까지 같은 날에만 판정이 갈린다(E6 에서 잰다 · 설계 13 §8 R2).

import 'regime_states.dart';

/// 03 §2-7-2 `sleeve_b_target_weight` — 이 자산의 «목표 비중 대비 보유 배율» 0 / ⅓ / ⅔ / 1.
///
/// [monthlyCloses] 는 오래된 것부터, 마지막 값이 판정월 종가다.
double sleeveBTargetWeight(
  List<double> monthlyCloses, {
  required List<int> lookbackMonths,
}) {
  _checkLookbacks(lookbackMonths);
  if (monthlyCloses.length < _maxOf(lookbackMonths)) return 0.0;
  final double last = monthlyCloses.last;
  int held = 0;
  for (final int n in lookbackMonths) {
    if (last > _meanOfLast(monthlyCloses, n)) held++;
  }
  return held / lookbackMonths.length;
}

/// 03 v2.27 `sleeve_b_target_ratio_p0` 의 설정 — 02 §4 `sleeve_b.b_sma_floor` · `b_sma_regime_assist`.
class SleeveBAssist {
  /// 설정을 만든다. [floor]·[cut] 은 0~1.
  SleeveBAssist({required this.floor, this.cutState, required this.cut}) {
    if (floor.isNaN || floor < 0 || floor > 1) {
      throw ArgumentError.value(floor, 'floor', '0~1 이어야 한다');
    }
    if (cut.isNaN || cut < 0 || cut > 1) {
      throw ArgumentError.value(cut, 'cut', '0~1 이어야 한다');
    }
  }

  /// 상시 하한(P0S 1/3).
  final double floor;

  /// 차감을 거는 방향 상태(P0S BEAR) — null 이면 차감 없음.
  final DirectionState? cutState;

  /// 차감량(P0S 2/3) — 🔴 승수가 아니다.
  final double cut;
}

/// 03 v2.27 `sleeve_b_target_ratio_p0` — 기본 비율 → 하한(먼저) → 방향 상태 차감(나중).
///
/// [regimeState] 는 히스테리시스를 거친 방향 상태(03 §1-7).
double sleeveBTargetRatioP0(
  List<double> monthlyCloses, {
  required List<int> lookbackMonths,
  required SleeveBAssist assist,
  required DirectionState regimeState,
}) {
  double ratio = sleeveBTargetWeight(
    monthlyCloses,
    lookbackMonths: lookbackMonths,
  );
  if (monthlyCloses.length < _maxOf(lookbackMonths)) return 0.0;
  if (ratio < assist.floor) ratio = assist.floor;
  if (assist.cutState != null && regimeState == assist.cutState) {
    ratio = ratio - assist.cut;
    if (ratio < 0.0) ratio = 0.0;
  }
  return ratio;
}

void _checkLookbacks(List<int> lookbacks) {
  if (lookbacks.isEmpty || lookbacks.any((int n) => n < 1)) {
    throw ArgumentError.value(
      lookbacks,
      'lookbackMonths',
      '1 이상 룩백이 하나 이상 있어야 한다',
    );
  }
}

int _maxOf(List<int> xs) => xs.reduce((int a, int b) => a > b ? a : b);

double _meanOfLast(List<double> xs, int n) {
  double sum = 0;
  for (int i = xs.length - n; i < xs.length; i++) {
    sum += xs[i];
  }
  return sum / n;
}
