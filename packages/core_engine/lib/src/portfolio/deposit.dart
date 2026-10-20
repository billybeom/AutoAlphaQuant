// 납입 배분 — `06_시스템설계/03_알고리즘.md` §5-5b DEPOSIT · v2.23 · 05 GV-28d(AC-B21 일부).
//
// 🔴 목표 대비 **부족분이 큰 슬리브 순**으로 채운다(잉여 슬리브는 목록에 없다).
// 🔴 연금 한도가 남아 있으면 슬리브 B 를 **맨 앞으로** 올리고 남은 한도까지만 채운다(promote · cap).
//    B 가 부족분 목록에 없으면 올릴 것이 없다(D3 — 목표 초과 B 에 한도 소진용 납입을 하지 않는다).
// 🔴 한도가 0 이면 B 를 **목록에서 뺀다**(v2.23 — 빼지 않으면 B 가 한도 없이 채워진다 · 05 GV-28 d3).
// 🔴 납입은 밴드 리밸런싱을 부르지 않는다 — 부족분만 채우고 끝(§5-5b 표).
// ⏸ 부족분 합계보다 많이 들어오면 남는 금액만 돌려준다 — 목적지는 발주자 대기(D2 · 참조 엔진 = 원화 현금 대기).
// 🔵 부족분이 같으면 입력 순서대로. 생성기(D4)는 이름순으로 정했지만 «결정적이기만 하면 되는 세부»이고
//    정답지에 동률이 없다.
// ⚠️ 참조 엔진 P0S(`_process_deposits`)는 이 정렬이 아니라 «B → 새틀 → 잔여 원화» 고정 순서다 —
//    골든 경로에는 납입이 없어(deposits = ()) 차이가 드러나지 않는다. 실전 월 납입이 이 경로를 탄다.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// 납입 한 건 — [sleeve] 에 [amount] 원.
class DepositFill {
  /// 결과를 만든다.
  const DepositFill(this.sleeve, this.amount);

  /// 채우는 슬리브.
  final SleeveId sleeve;

  /// 금액(원).
  final Decimal amount;
}

/// 납입 배분 결과.
class DepositAllocation {
  /// 결과를 만든다.
  const DepositAllocation({required this.filled, required this.residual});

  /// 채우는 순서대로.
  final List<DepositFill> filled;

  /// 부족분을 다 채우고 남은 금액(목적지 = 발주자 대기 D2).
  final Decimal residual;
}

/// 03 §5-5b DEPOSIT — [amount] 원을 부족분 큰 순으로(연금 한도가 남으면 B 먼저 · 한도까지만) 나눈다.
///
/// [currents] · [targets] 는 같은 슬리브 집합이어야 한다(회계 기준 금액).
DepositAllocation allocateDeposit({
  required Decimal amount,
  required Map<SleeveId, Decimal> currents,
  required Map<SleeveId, Decimal> targets,
  required Decimal remainingPensionQuota,
}) {
  if (amount < Decimal.zero) {
    throw ArgumentError.value(amount, 'amount', '0 이상이어야 한다');
  }
  if (remainingPensionQuota < Decimal.zero) {
    throw ArgumentError.value(
      remainingPensionQuota,
      'remainingPensionQuota',
      '0 이상이어야 한다',
    );
  }
  if (currents.length != targets.length ||
      !currents.keys.every(targets.containsKey)) {
    throw ArgumentError('currents 와 targets 의 슬리브가 다르다');
  }
  final List<(int, SleeveId, Decimal)> gaps = <(int, SleeveId, Decimal)>[];
  int order = 0;
  for (final MapEntry<SleeveId, Decimal> e in currents.entries) {
    final Decimal gap = targets[e.key]! - e.value;
    if (gap > Decimal.zero) gaps.add((order++, e.key, gap));
  }
  gaps.sort(((int, SleeveId, Decimal) x, (int, SleeveId, Decimal) y) {
    final int byGap = y.$3.compareTo(x.$3);
    return byGap != 0 ? byGap : x.$1.compareTo(y.$1);
  });
  final List<(SleeveId, Decimal)> queue = <(SleeveId, Decimal)>[];
  if (remainingPensionQuota > Decimal.zero) {
    for (final (int _, SleeveId s, Decimal g) in gaps) {
      if (s == SleeveId.b) {
        queue.add((s, g < remainingPensionQuota ? g : remainingPensionQuota));
      }
    }
  }
  for (final (int _, SleeveId s, Decimal g) in gaps) {
    if (s != SleeveId.b) queue.add((s, g));
  }
  final List<DepositFill> filled = <DepositFill>[];
  Decimal remain = amount;
  for (final (SleeveId s, Decimal g) in queue) {
    if (remain <= Decimal.zero) break;
    final Decimal take = g < remain ? g : remain;
    filled.add(DepositFill(s, take));
    remain -= take;
  }
  return DepositAllocation(
    filled: List<DepositFill>.unmodifiable(filled),
    residual: remain,
  );
}
