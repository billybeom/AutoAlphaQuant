// 브레이커 사다리 원천(M5-4 · SPEC 04 §2 사다리 표 · v2.31 새틀 0% · v2.40 STOPPED · 설계 13 §8 R63 V4).
//
// 🔴 수치는 설정에서만 — 문장 속 % · 일수는 [BreakerConfig] 값이다(리터럴 0 · 설정을 바꾸면 문장이 바뀐다).
// 🔴 새틀라이트가 없으면(P0S) 새틀 조치 뒤에 «(지금은 대상 없음)» — 조문 · 스위치는 남긴다(v2.31).
// 🔴 STOPPED = 자동 해제 없음 · 신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음(v2.40).

import '../ops/equity_snapshot.dart' show p0sBreakerConfig;
import '../risk/breaker.dart';
import 'safety_text.dart' show breakerLabelOf;

/// 사다리 한 단.
class BreakerLadderStep {
  /// 단을 만든다.
  const BreakerLadderStep({
    required this.level,
    required this.label,
    required this.triggerText,
    required this.releaseText,
    required this.actionText,
    required this.current,
  });

  /// 레벨 · 라벨.
  final BreakerLevel level;

  /// 라벨.
  final String label;

  /// 트리거 · 해제 조건 · 조치 문장.
  final String triggerText, releaseText, actionText;

  /// 지금 단인가.
  final bool current;
}

/// 낙폭 % 글자(소수 한 자리까지 · 정수면 정수).
String ladderPercent(double v) {
  final double tenths = (v * 1000).round() / 10;
  return tenths == tenths.roundToDouble()
      ? '${tenths.toInt()}%'
      : '${tenths.toStringAsFixed(1)}%';
}

/// 사다리 5 단(R63 V4) — [satelliteActive] = 새틀라이트 비중이 있는가(P0S = false).
List<BreakerLadderStep> breakerLadderOf({
  required BreakerLevel current,
  BreakerConfig? config,
  bool satelliteActive = false,
}) {
  final BreakerConfig c = config ?? p0sBreakerConfig();
  final String none = satelliteActive ? '' : '(지금은 대상 없음)';
  final String hold = '${c.recoverHoldBars}거래일 유지';
  String p(double v) => ladderPercent(v);
  final Map<BreakerLevel, (String, String, String)>
  rows = <BreakerLevel, (String, String, String)>{
    BreakerLevel.normal: ('dd > ${p(c.alertDd)}', '—', '정상 운용'),
    BreakerLevel.alert: (
      'dd ≤ ${p(c.alertDd)}',
      'dd > ${p(c.alertReleaseDd)} · $hold',
      '알림 · 새틀라이트 신규 진입 · 증액 중단$none',
    ),
    BreakerLevel.reduced: (
      'dd ≤ ${p(c.reduceDd)}',
      'dd ≥ ${p(c.reduceReleaseDd)} · 방향 점수 ${kReduceReleaseDirectionScore.toInt()} 이상 · $hold',
      '새틀라이트 × 0.5$none',
    ),
    BreakerLevel.halted: (
      'dd ≤ ${p(c.haltDd)}',
      'dd ≥ ${p(c.haltReleaseDd)} · BULL ${c.haltReleaseBullStreak}일 연속 · $hold',
      '새틀라이트 0%$none · 슬리브 A 신규 매수 정지',
    ),
    BreakerLevel.stopped: (
      'dd ≤ ${p(c.stopDd)}',
      '자동 해제 없음 — ${c.recoverHoldBars}거래일 · SEV1 postmortem · 가족 합의 · 결정 A/B/C',
      '신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음',
    ),
  };
  return <BreakerLadderStep>[
    for (final BreakerLevel l in BreakerLevel.values)
      BreakerLadderStep(
        level: l,
        label: breakerLabelOf(l),
        triggerText: rows[l]!.$1,
        releaseText: rows[l]!.$2,
        actionText: rows[l]!.$3,
        current: l == current,
      ),
  ];
}
