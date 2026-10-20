// 원화 조달의 상대 슬리브 — `06_시스템설계/03_알고리즘.md` §5-2 v2.19 · v2.21 단서 · §5-5b 준용 · 05 GV-36.
//
// 🔴 목표 배분비 대비 **잉여가 큰 슬리브부터** 뺀다 — C 원화 현금만 쓰는 구현은 금지(2013년 C 고갈 실측).
// 🔴 v2.21 — **연금계좌(슬리브 B)는 조달원이 아니다.** 55세 이전 인출은 기타소득세 16.5% 라 계좌 밖으로
//    꺼낼 수 없다. B 잉여는 코어 밴드의 계좌 안 재분류(GV-37)로만 처리된다. 그래서 B 를 넣을 인자가 없다.
// 🔴 한 슬리브에서는 **잉여까지만** 뺀다 — 잉여 합계보다 큰 요구는 다 채우지 못한 채로 돌려준다(05 GV-36-4).
//    모자라는 몫(`shortfall`)을 어떻게 할지는 호출자 몫이다.
// 🔵 잉여가 같으면 입력 순서대로(파이썬 `sorted` 는 안정 정렬 — 참조 생성기와 같은 답).
// ⚠️ 참조 엔진 P0S(`_raise_krw`)는 슬리브 C 방어자산을 IAU → IEI 순으로 **필요한 만큼** 팔고 C 잉여로
//    끊지 않는다. 여기는 03 문장(= 정답지)대로 끊는다 — 차이는 E6 대조에서 본다(설계 13 §8 R14 결정).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// 조달 한 건 — [sleeve] 에서 [amount] 원.
class FundingTake {
  /// 결과를 만든다.
  const FundingTake(this.sleeve, this.amount);

  /// 빼는 슬리브.
  final SleeveId sleeve;

  /// 금액(원).
  final Decimal amount;
}

/// 조달 계획.
class FundingPlan {
  /// 결과를 만든다.
  const FundingPlan({required this.takes, required this.shortfall});

  /// 빼는 순서대로.
  final List<FundingTake> takes;

  /// 비연금 잉여를 다 써도 모자란 금액(0 이면 다 채움).
  final Decimal shortfall;
}

/// 03 §5-2 v2.19 · v2.21 — [need] 원을 잉여 큰 슬리브부터(B 제외) 잉여까지만 뺀다.
///
/// [values] · [targets] 는 같은 슬리브 집합이어야 하고, 순서가 동률의 순서다.
FundingPlan fundingOrder({
  required Map<SleeveId, Decimal> values,
  required Map<SleeveId, Decimal> targets,
  required Decimal need,
}) {
  if (need < Decimal.zero) {
    throw ArgumentError.value(need, 'need', '0 이상이어야 한다');
  }
  if (values.length != targets.length ||
      !values.keys.every(targets.containsKey)) {
    throw ArgumentError('values 와 targets 의 슬리브가 다르다');
  }
  final List<(int, SleeveId, Decimal)> surplus = <(int, SleeveId, Decimal)>[];
  int order = 0;
  for (final MapEntry<SleeveId, Decimal> e in values.entries) {
    if (e.key == SleeveId.b) continue; // 🔴 연금계좌는 조달원이 아니다(v2.21)
    surplus.add((order++, e.key, e.value - targets[e.key]!));
  }
  surplus.sort(((int, SleeveId, Decimal) x, (int, SleeveId, Decimal) y) {
    final int bySurplus = y.$3.compareTo(x.$3);
    return bySurplus != 0 ? bySurplus : x.$1.compareTo(y.$1);
  });
  final List<FundingTake> takes = <FundingTake>[];
  Decimal remain = need;
  for (final (int _, SleeveId sleeve, Decimal sp) in surplus) {
    if (remain <= Decimal.zero || sp <= Decimal.zero) continue;
    final Decimal take = remain < sp ? remain : sp;
    takes.add(FundingTake(sleeve, take));
    remain -= take;
  }
  return FundingPlan(
    takes: List<FundingTake>.unmodifiable(takes),
    shortfall: remain,
  );
}
