// 계층 B 월간 판정 — TWR 지수 · 롤링 12M · DD · TUW · 카드 대조(설계 13 §8 R50 T2~T4 · 03_운영 §1-4 B1~B3 · 04 SAF-410 · 지도 D7).
//
// 🔴 판정 단위 = 포트폴리오 `equity_snapshot` 1 시리즈 · 결과는 전 전략에 같다(D7 ①).
// 🔴 시리즈 = TWR — 입금 · 출금(외부 흐름)은 수익이 아니다. 분배금 · 원천징수 · 단주 대금은 수익(외부 흐름 아님).
// 🔴 카드(임계)는 백테스트 부트스트랩 백분위로 **사전 등록**한다(03 §1-4) — 미등록이면 판정하지 않는다(D7 ③ · 부르는 쪽).

/// 계층 B 등록 카드(B1~B3 · 03 §1-4 · 카드 §4).
class TierBCard {
  /// 카드를 만든다.
  const TierBCard({
    required this.b1R12mFloor,
    required this.b2DdFloor,
    required this.b3TuwMonths,
  });

  /// B1 — 롤링 12개월 수익률 하한(부트스트랩 P1 · 예 −0.15).
  final double b1R12mFloor;

  /// B2 — DD 하한(부트스트랩 MDD P99 · 예 −0.34).
  final double b2DdFloor;

  /// B3 — TUW 상한(달 · 부트스트랩 P90 · 예 31).
  final double b3TuwMonths;
}

/// P0S 계층 B 카드 — 🔴 **미등록**(R50 T4 · 값 = Claude 가 백테스트6 부트스트랩으로 초안 → 발주자 확정 · E15 전).
/// 확정되면 이 함수가 값을 돌려준다(사전 등록 — 운영 중 바꾸지 않는다).
TierBCard? p0sTierBCard() => null;

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
