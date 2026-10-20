// 코어 밴드 — 슬리브 B 지분이 목표 ±band 를 벗어나면 이탈분 **전액** 자동 이체 —
// `06_시스템설계/03_알고리즘.md` §5-2 v2.20 · v2.21 계좌 규약 · v2.32 단서 · 05 GV-37.
//
// 🔴 사람의 판단 지점이 없다 — 부분 자동·결정 대기는 v2.19 안이고 대체됐다(전액 자동 · 2026-08-19).
// 🔴 경계는 strict — 정확히 목표 ± band 면 이체하지 않는다(05 GV-37-2).
// 🔴 B → C 는 현금 인출이 아니라 **같은 연금계좌 안 파킹으로 재분류**(인출 과세 0 · v2.21).
// 🔴 C → B 는 ① 재분류분 환원(같은 계좌 — 연 한도 **무관**) → ② 부족분만 신규 납입(연 1,800만 공용 한도 ·
//    슬리브 A 재진입 재원 `reservedKrw` 는 침범하지 않는다).
// 🔵 v2.32: ② 의 납입 필요액(한도 안)이 쓸 수 있는 원화보다 크면 그 차이를 §5-5b 조달 순서(연금계좌 제외 ·
//    `fundingOrder`)로 **먼저** 마련한다 — 여기는 그 금액([CoreBandMove.prefundNeeded])만 알려 준다.
//    원화 범위 안에서만 납입하고 나머지를 버리는 구현은 금지(그해 한도 소실).
// 🔵 지분 판정은 Decimal 로 한다(`b > 총자산 × (목표 + band)`). 참조 엔진(float)과는 경계와 마지막 자리까지
//    같은 날에만 갈린다(E6 · 설계 13 §8 R1).

import 'package:decimal/decimal.dart';

import '../decimal_rules.dart';

/// 이체 방향.
enum CoreBandDirection {
  /// 밴드 안 — 이체 없음.
  none,

  /// B 초과 — B 를 파킹으로 재분류해 C 현금성으로 집계.
  bToC,

  /// B 미달 — 재분류 환원 + 신규 납입.
  cToB,
}

/// 코어 밴드 판정 결과(원).
class CoreBandMove {
  /// 결과를 만든다.
  const CoreBandMove({
    required this.direction,
    required this.reclassified,
    required this.contribution,
    required this.prefundNeeded,
  });

  /// 방향.
  final CoreBandDirection direction;

  /// 계좌 안 재분류 금액 — B→C 면 B 초과분, C→B 면 환원분.
  final Decimal reclassified;

  /// 신규 연금 납입 — C→B 에서만(연 한도 · 재진입 재원 보호 안).
  final Decimal contribution;

  /// v2.32 — 납입 전에 조달 순서로 마련해야 할 원화(0 이면 없음).
  final Decimal prefundNeeded;

  /// 이번 달 이체 합계(재분류 + 납입).
  Decimal get total => reclassified + contribution;
}

/// 03 §5-2 v2.20 코어 밴드 판정 — 월 마지막 KR 거래일 1회.
///
/// [bValue] · [totalEquity] 는 **회계 기준** 금액이다(POT → A · B 파킹 중 재분류분 → C).
CoreBandMove coreBandMove({
  required Decimal bValue,
  required Decimal totalEquity,
  required double targetWeight,
  required double band,
  required Decimal krwCash,
  required Decimal reservedKrw,
  required Decimal reclassifiedPark,
  required Decimal annualQuota,
  required Decimal pensionUsedThisYear,
}) {
  if (totalEquity <= Decimal.zero) {
    throw ArgumentError.value(totalEquity, 'totalEquity', '0 보다 커야 한다');
  }
  for (final (String name, Decimal v) in <(String, Decimal)>[
    ('bValue', bValue),
    ('krwCash', krwCash),
    ('reservedKrw', reservedKrw),
    ('reclassifiedPark', reclassifiedPark),
    ('annualQuota', annualQuota),
    ('pensionUsedThisYear', pensionUsedThisYear),
  ]) {
    if (v < Decimal.zero) throw ArgumentError.value(v, name, '0 이상이어야 한다');
  }
  for (final (String name, double v) in <(String, double)>[
    ('targetWeight', targetWeight),
    ('band', band),
  ]) {
    if (v.isNaN || v < 0 || v > 1) {
      throw ArgumentError.value(v, name, '0~1 이어야 한다');
    }
  }
  final Decimal t = promoteRatio(targetWeight);
  final Decimal w = promoteRatio(band);
  final Decimal target = multiply(totalEquity, t);
  if (bValue > multiply(totalEquity, t + w)) {
    return CoreBandMove(
      direction: CoreBandDirection.bToC,
      reclassified: bValue - target,
      contribution: Decimal.zero,
      prefundNeeded: Decimal.zero,
    );
  }
  if (bValue < multiply(totalEquity, t - w)) {
    final Decimal need = target - bValue;
    final Decimal reclaim = _min(need, reclassifiedPark); // ① 한도 무관
    final Decimal quotaLeft = _max(
      Decimal.zero,
      annualQuota - pensionUsedThisYear,
    );
    final Decimal want = _min(need - reclaim, quotaLeft); // ② 한도 안 필요액
    final Decimal available = _max(Decimal.zero, krwCash - reservedKrw);
    return CoreBandMove(
      direction: CoreBandDirection.cToB,
      reclassified: reclaim,
      contribution: _min(want, available),
      prefundNeeded: _max(Decimal.zero, want - available),
    );
  }
  return CoreBandMove(
    direction: CoreBandDirection.none,
    reclassified: Decimal.zero,
    contribution: Decimal.zero,
    prefundNeeded: Decimal.zero,
  );
}

Decimal _min(Decimal a, Decimal b) => a < b ? a : b;
Decimal _max(Decimal a, Decimal b) => a > b ? a : b;
