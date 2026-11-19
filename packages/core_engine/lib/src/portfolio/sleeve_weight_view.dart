// 슬리브 비중 줄 · 밴드 상태 · 목표 막대(E11q1 · 설계 13 §8 R171) — What-if 리밸런싱 미리보기 · H6-1 보유 현황 · (H6-3 배분)이 한 생산을 쓴다.
//
// 🔴 «B 42.6% (목표 42.0%, 편차 +0.6%p, 밴드 여유 2.4%p)» 꼴 = 미리보기에서 옮긴 그대로(값 · 글자 무변경).
// 🔴 경계 근접 · 막대 정규 위치 = 표시 분류(판정 아님 · 주문을 바꾸지 않는다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AllocationBasis,
        SleeveBandGauge,
        SleeveBandState,
        SleeveId,
        SleeveWeight;

String _pct(double x) => '${(x * 100).toStringAsFixed(1)}%';

/// 🔴 경계 근접 = 밴드 반폭의 20% 안(표시 분류 · 판정 아님 — R171 · 발주자 위임).
const double kNearEdgeFraction = 0.2;

/// 🔴 비중 줄 한 줄(What-if 미리보기와 같은 꼴 · 밴드 없으면 0~1).
SleeveWeight sleeveWeightOf(
  SleeveId sleeve,
  Decimal value,
  Decimal total,
  Decimal target,
  Decimal? band,
) {
  final double w = total > Decimal.zero
      ? (value / total).toDecimal(scaleOnInfinitePrecision: 12).toDouble()
      : 0.0;
  final double t = target.toDouble();
  final double lo = band == null ? 0.0 : (target - band).toDouble();
  final double hi = band == null ? 1.0 : (target + band).toDouble();
  String pp(double x) {
    final String v = (x.abs() * 100).toStringAsFixed(1);
    if (v == '0.0') return '0.0%p';
    return '${x > 0 ? '+' : '−'}$v%p';
  }

  final String bandText = band == null
      ? ''
      : w > hi
      ? ', 밴드 상단 ${((w - hi) * 100).toStringAsFixed(1)}%p 초과'
      : w < lo
      ? ', 밴드 하단 ${((lo - w) * 100).toStringAsFixed(1)}%p 미달'
      : ', 밴드 여유 ${((w - lo < hi - w ? w - lo : hi - w) * 100).toStringAsFixed(1)}%p';
  return SleeveWeight(
    sleeve: sleeve,
    weight: w,
    targetWeight: t,
    bandLow: lo,
    bandHigh: hi,
    label:
        '${sleeve.wire} ${_pct(w)} (목표 ${_pct(t)}, 편차 ${pp(w - t)}$bandText)',
    basis: AllocationBasis.accounting,
  );
}

/// 밴드 상태(밴드가 있는 줄만).
SleeveBandState sleeveBandStateOf(SleeveWeight s) {
  final double w = s.weight;
  if (w < s.bandLow || w > s.bandHigh) return SleeveBandState.outOfBand;
  final double half = (s.bandHigh - s.bandLow) / 2;
  final double margin = (w - s.bandLow) < (s.bandHigh - w)
      ? w - s.bandLow
      : s.bandHigh - w;
  return half > 0 && margin < half * kNearEdgeFraction
      ? SleeveBandState.nearEdge
      : SleeveBandState.inBand;
}

/// 목표 막대 정규 위치 — 밴드 = 0.25~0.75 · 목표 = 0.5 · 실제 = 같은 눈금(0~1 로 자름).
SleeveBandGauge sleeveBandGaugeOf(SleeveWeight s) {
  final double half = (s.bandHigh - s.bandLow) / 2;
  final double raw = half <= 0
      ? 0.5
      : 0.5 + (s.weight - s.targetWeight) / half * 0.25;
  return SleeveBandGauge(
    actualNormalized: raw < 0 ? 0.0 : (raw > 1 ? 1.0 : raw),
    targetNormalized: 0.5,
    bandLowNormalized: 0.25,
    bandHighNormalized: 0.75,
  );
}
