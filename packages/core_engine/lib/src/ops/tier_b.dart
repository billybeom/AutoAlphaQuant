// 계층 B 월간 판정 — TWR 지수 · 롤링 12M · DD · TUW · 카드 대조(설계 13 §8 R50 T2~T4 · 03_운영 §1-4 B1~B3 · 04 SAF-410 · 지도 D7).
//
// 🔴 판정 단위 = 포트폴리오 `equity_snapshot` 1 시리즈 · 결과는 전 전략에 같다(D7 ①).
// 🔴 시리즈 = TWR — 입금 · 출금(외부 흐름)은 수익이 아니다. 분배금 · 원천징수 · 단주 대금은 수익(외부 흐름 아님).
// 🔴 카드(임계)는 백테스트 부트스트랩 백분위로 **사전 등록**한다(03 §1-4) — 미등록이면 판정하지 않는다(D7 ③ · 부르는 쪽).
// 🆕 R247(R50 T10) — PROBATION 복귀 · 만료 판정 · 자금 상한(위험 슬리브 A · B · POT 만 · C = 회수처) · A 축소 매도.

import 'package:domain_contracts/domain_contracts.dart'
    show OrderSide, TradeDate;

import '../orders/idempotency.dart' show DecisionIds;
import '../orders/order_draft.dart'
    show AllHeldSizing, OrderTarget, P0sStrategyIds, ShareSizing;
import '../risk/limits.dart' show InstrumentKind;

/// 계층 B 등록 카드(B1~B3 · 03 §1-4 · 카드 §4).
class TierBCard {
  /// 카드를 만든다.
  const TierBCard({
    required this.b1R12mFloor,
    required this.b2DdFloor,
    required this.b3TuwMonths,
  });

  /// B1 — 롤링 12개월 수익률 하한(경로별 «가장 나쁜 롤링 12M» 분포의 부트스트랩 P1 — 월말 롤링 값을 모은 분포의
  /// P1 이 아니다 · 설계 13 §8 R158).
  final double b1R12mFloor;

  /// B2 — DD 하한(경로별 MDD 분포의 나쁜 쪽 1% · 부트스트랩 P99).
  final double b2DdFloor;

  /// B3 — TUW 상한(달 · 경로별 «가장 긴 물속 기간» 분포의 부트스트랩 P90).
  final double b3TuwMonths;
}

/// P0S 계층 B 카드 — ✅ **발주자 확정 2026-11-19**(설계 13 §8 R158 · R50 T4 · R80 D8 · 근거 = 백테스트6
/// `계층B_카드_초안_Q1.md` — 정본 P0S v2.32 곡선 26.6년 · 정상 블록 부트스트랩 평균 19일 · 10,000회 · 시드 20261119).
/// 원값 B1 −18.68% · B2 −23.94% · B3 37.6달 → 헛경보가 줄어드는 바깥쪽으로 1%p · 1달 반올림.
/// 🔴 사전 등록 — 운영 중 바꾸지 않는다(바꾸려면 새 백테스트 · 발주자 재확정 · 새 R 행).
TierBCard? p0sTierBCard() =>
    const TierBCard(b1R12mFloor: -0.19, b2DdFloor: -0.24, b3TuwMonths: 38);

/// 시리즈 한 점 — 그날 평가 · 앞 점 뒤 ~ 그날의 외부 흐름 합(입금 + · 출금 −).
class EquityPoint {
  /// 점을 만든다.
  const EquityPoint(this.date, this.equity, {this.flow = 0});

  /// KR 날 `YYYY-MM-DD`.
  final String date;

  /// 총평가.
  final double equity;

  /// 외부 흐름.
  final double flow;
}

/// TWR 지수(첫 점 = 1) — r_t = (E_t − F_t) ÷ E_{t−1} − 1 · 앞 평가가 0 이하면 그날 수익 0.
List<double> twrIndex(List<EquityPoint> pts) {
  final List<double> out = <double>[];
  for (int k = 0; k < pts.length; k++) {
    if (k == 0) {
      out.add(1);
      continue;
    }
    final double prev = pts[k - 1].equity;
    final double r = prev <= 0 ? 0 : (pts[k].equity - pts[k].flow) / prev - 1;
    out.add(out[k - 1] * (1 + r));
  }
  return out;
}

/// 판정 실패 — 사유만(금액 0).
class TierBError implements Exception {
  /// 실패를 만든다.
  const TierBError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'TierBError($reason)';
}

/// 지표(R50 T3).
class TierBMetrics {
  /// 지표를 만든다.
  const TierBMetrics({
    required this.asOf,
    required this.r12m,
    required this.dd,
    required this.tuwMonths,
    required this.peakDate,
  });

  /// 기준 점(월말 달의 마지막 스냅숏).
  final String asOf;

  /// 롤링 12개월 TWR(이력 12달 없음 = null).
  final double? r12m;

  /// DD(≤ 0).
  final double dd;

  /// 최고점부터의 달 수.
  final double tuwMonths;

  /// 최고점 날.
  final String peakDate;
}

/// 12달 전 같은 날(문자열) — 2월 29일은 앞 해에 없는 날이 되지만 «그 날 이하 마지막 점» 비교라 2월 28일과 같다.
String _minusYear(String ymd) =>
    '${(int.parse(ymd.substring(0, 4)) - 1).toString().padLeft(4, '0')}${ymd.substring(4)}';

const double _kPeakTolerance = 1e-9;

/// [monthEnd] 달의 지표 — 점은 날짜 순 · 그 달 점이 없으면 [TierBError].
TierBMetrics tierBMetrics(List<EquityPoint> pts, String monthEnd) {
  for (int k = 1; k < pts.length; k++) {
    if (pts[k - 1].date.compareTo(pts[k].date) >= 0) {
      throw ArgumentError('점이 날짜 순이 아니다');
    }
  }
  int last = -1;
  for (int k = 0; k < pts.length; k++) {
    if (pts[k].date.compareTo(monthEnd) <= 0) last = k;
  }
  if (last < 0 || pts[last].date.substring(0, 7) != monthEnd.substring(0, 7)) {
    throw TierBError('${monthEnd.substring(0, 7)} 스냅숏 없음');
  }
  final List<double> idx = twrIndex(pts.sublist(0, last + 1));
  // 🔴 최고점 = 같은 높이면 뒤 점 — 지수는 곱셈 누적이라 같은 평가로 회복해도 1e-16 쯤 어긋난다(그러면 TUW 가 옛 최고점부터
  //    세어져 B3 가 거짓 충족). 상대 오차 [_kPeakTolerance] 안이면 같은 높이로 본다.
  int peak = 0;
  for (int k = 1; k < idx.length; k++) {
    if (idx[k] >= idx[peak] * (1 - _kPeakTolerance)) peak = k;
  }
  final String base = _minusYear(pts[last].date);
  int b = -1;
  for (int k = 0; k <= last; k++) {
    if (pts[k].date.compareTo(base) <= 0) b = k;
  }
  final double cur = idx[last];
  final int days = DateTime.parse('${pts[last].date}T00:00:00Z')
      .difference(DateTime.parse('${pts[peak].date}T00:00:00Z'))
      .inDays;
  return TierBMetrics(
    asOf: pts[last].date,
    r12m: b < 0 ? null : cur / idx[b] - 1,
    dd: cur / idx[peak] - 1, // 최고점 ≥ 첫 점(1) 근처라 0 이 아니다
    tuwMonths: days / 30.4375,
    peakDate: pts[peak].date,
  );
}

/// 판정 결과.
class TierBVerdict {
  /// 결과를 만든다.
  const TierBVerdict({required this.b1, required this.b2, required this.b3});

  /// B1 · B2 · B3 충족.
  final bool b1, b2, b3;

  /// 하나라도 충족.
  bool get any => b1 || b2 || b3;

  /// 처음 충족한 것의 코드(`B1` · `B2` · `B3` · 없으면 null).
  String? get firstCode => b1
      ? 'B1'
      : b2
      ? 'B2'
      : b3
      ? 'B3'
      : null;

  @override
  String toString() => 'TierBVerdict(B1 $b1 · B2 $b2 · B3 $b3)';
}

/// 카드 대조(R50 T4) — B1 = r12 < 하한(r12 없음 = 미충족) · B2 = DD ≤ 하한 · B3 = TUW > 상한.
TierBVerdict judgeTierB(TierBMetrics m, TierBCard card) => TierBVerdict(
  b1: m.r12m != null && m.r12m! < card.b1R12mFloor,
  b2: m.dd <= card.b2DdFloor,
  b3: m.tuwMonths > card.b3TuwMonths,
);

/// 🆕 R247 — PROBATION 복귀 · 최대 관찰 기간(03 §1-5 «P0S 등록» · 카드 §8 · R50 T10).
class TierBProbationRule {
  /// 규칙을 만든다.
  const TierBProbationRule({
    required this.returnR12mFloor,
    required this.maxJudgements,
  });

  /// 복귀 ① — 롤링 12개월 수익률 하한(이상이면 충족 · 이력 12달 없음 = 미충족).
  final double returnR12mFloor;

  /// 최대 관찰 기간 — 진입 판정 뒤 월말 판정 횟수(이 횟수째 판정에서도 복귀 못 하면 만료).
  final int maxJudgements;
}

/// P0S PROBATION 규칙 — ✅ **발주자 위임 — 권고대로 2026-11-23**(03 §1-5 «P0S 등록» · 근거 = 백테스트6
/// `PROBATION_복귀조건_Q2.md` · 실험대장 Q2): 복귀 = 월말 롤링 12M ≥ +5%(부트스트랩 «월말 전부 모음» 25%ile +5.38% 를
/// 1%p 내림) **AND** 그 달 B1~B3 안 걸림 · 진입 다음 달 월말부터 · 24회 판정 안에 복귀 못 하면 자동 RETIRED.
/// 🔴 신호 일치(B5)는 판정이 «보류»라 조건 밖 — 판정이 생기면 «그 달 불일치 0건»을 더한다(사전 등록).
/// 🔴 사전 등록 — 운영 중 바꾸지 않는다(PROBATION 중 규칙 변경 금지 · 03 §1-5).
TierBProbationRule p0sProbationRule() =>
    const TierBProbationRule(returnR12mFloor: 0.05, maxJudgements: 24);

/// PROBATION 월말 판정 결과.
enum TierBProbationOutcome {
  /// 그대로 PROBATION.
  stay,

  /// 복귀 → ACTIVE(상한 100%).
  returned,

  /// 기간 만료 → 자동 RETIRED(재량 연장 금지).
  expired,
}

/// PROBATION 판정 — [observations] = 진입 판정 뒤 월말 판정 횟수(이번 판정 포함 · 1 부터).
/// 복귀가 먼저다(마지막 판정에서 복귀하면 만료가 아니다).
TierBProbationOutcome judgeProbation(
  TierBMetrics m,
  TierBVerdict v, {
  required int observations,
  required TierBProbationRule rule,
}) {
  if (observations < 1) {
    throw ArgumentError.value(observations, 'observations', '1 이상');
  }
  if (m.r12m != null && m.r12m! >= rule.returnR12mFloor && !v.any) {
    return TierBProbationOutcome.returned;
  }
  return observations >= rule.maxJudgements
      ? TierBProbationOutcome.expired
      : TierBProbationOutcome.stay;
}

/// 🆕 R247 — 자금 상한(03 §1-5 «목표 배분 대비») · 계층 B 가 쓰는 값.
abstract final class TierBCaps {
  /// ACTIVE(복귀 포함).
  static const double active = 1.0;

  /// PROBATION 진입 = 지금 상한 × 이 값.
  static const double probationFactor = 0.5;

  /// RETIRED.
  static const double retired = 0.0;
}

/// 🆕 R247 🔴 회수처 — 방어 슬리브 C 는 상한을 받지 않는다(03 §1-5 «회수 → C» · §1-3 «C 는 알파를 주장하지 않음»).
/// 포트폴리오 카드(D7)라 상태 라벨(PROBATION · RETIRED)은 네 전략이 함께 옮기지만 C 의 `capital_cap` 은 그대로 둔다 —
/// C 를 줄여 C 로 보내는 것은 순환이고, 줄인 돈이 갈 방어 자리가 C 다.
bool tierBCapReceiver(String strategyId) =>
    strategyId == P0sStrategyIds.sleeveC;

/// 🆕 R247 — 계획기가 쓰는 상한: ACTIVE · PROBATION = `capital_cap`(0~1 로 자름) · RETIRED = 0 ·
/// 행 없음 · CANDIDATE · PAPER · PILOT = 1(이 판 밖 — 램프 · STOPPED 결정 B 의 몫 · 지금 동작 그대로).
double plannerCapOf(String? state, double? capitalCap) => switch (state) {
  'ACTIVE' || 'PROBATION' => (capitalCap ?? 1.0).clamp(0.0, 1.0),
  'RETIRED' => TierBCaps.retired,
  _ => 1.0,
};

/// 🆕 R247 — P0S 위험 슬리브 상한(A · B · POT · C = 회수처라 없음).
class P0sRiskCaps {
  /// 상한을 만든다(0~1).
  const P0sRiskCaps({this.a = 1.0, this.b = 1.0, this.pot = 1.0})
    : assert(a >= 0 && a <= 1 && b >= 0 && b <= 1 && pot >= 0 && pot <= 1);

  /// 상한 없음(전부 1).
  static const P0sRiskCaps full = P0sRiskCaps();

  /// 슬리브 A · B · POT.
  final double a, b, pot;

  /// 전부 1 인가.
  bool get isFull => a == 1.0 && b == 1.0 && pot == 1.0;

  /// `plan_snapshot.outputs.risk_caps`(상한이 걸렸을 때만 싣는다 — 평시 계획 바이트 불변).
  Map<String, Object?> toJson() => <String, Object?>{
    'A': a,
    'B': b,
    'POT': pot,
  };

  /// [toJson] 의 역(없으면 [full]).
  static P0sRiskCaps fromJson(Object? j) {
    if (j == null) return full;
    final Map<String, Object?> m = j as Map<String, Object?>;
    double v(String k) => (m[k]! as num).toDouble();
    return P0sRiskCaps(a: v('A'), b: v('B'), pot: v('POT'));
  }

  @override
  bool operator ==(Object other) =>
      other is P0sRiskCaps && other.a == a && other.b == b && other.pot == pot;

  @override
  int get hashCode => Object.hash(a, b, pot);

  @override
  String toString() => 'P0sRiskCaps(A $a · B $b · POT $pot)';
}

/// 🆕 R247 — 슬리브 A 축소 매도(PROBATION · RETIRED 전이 뒤 A 를 아직 줄이지 않았을 때 한 번) — 상한 0 = 전량 ·
/// 그 밖 = 보유 − ⌊보유 × 상한⌋(남는 주식이 상한을 넘지 않게). 줄일 것이 없으면 null.
/// 논리 id = `RISK-P0S_A-{종목}-{판정일}`(04 §3-2 «한도 청산» 형식 그대로) · 판 돈 = 원화 = 회수처 C.
OrderTarget? sleeveACapTrim({
  required String symbol,
  required int heldShares,
  required double capA,
  required TradeDate judgmentDate,
}) {
  if (heldShares <= 0 || capA >= 1.0) return null;
  final int sell = capA <= 0
      ? heldShares
      : heldShares - (heldShares * capA).floor();
  if (sell <= 0) return null;
  return OrderTarget(
    logicalDecisionId: DecisionIds.risk(
      P0sStrategyIds.sleeveA,
      symbol,
      judgmentDate,
    ),
    strategyId: P0sStrategyIds.sleeveA,
    symbol: symbol,
    side: OrderSide.sell,
    sizing: capA <= 0 ? const AllHeldSizing() : ShareSizing(sell),
    instrument: InstrumentKind.etf,
  );
}

/// 처음 충족한 지표의 (값 · 임계) — `strategy_state_log` 용.
(double, double)? tierBTrigger(
  TierBMetrics m,
  TierBCard card,
  TierBVerdict v,
) => switch (v.firstCode) {
  'B1' => (m.r12m!, card.b1R12mFloor),
  'B2' => (m.dd, card.b2DdFloor),
  'B3' => (m.tuwMonths, card.b3TuwMonths),
  _ => null,
};
