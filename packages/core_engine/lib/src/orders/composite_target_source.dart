// 여러 대상 출처를 하나로(설계 13 §8 R49 Q5) — 월말 계획 + 계절 A 를 `kr_order` 에 한 출처로 넘긴다.
//
// 🔴 순서 = 넘긴 차례 · 한 출처가 실패하면 그대로 던진다(지어내지 않는다 — `kr_order` 가 fail 핑).

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import 'order_draft.dart' show OrderTarget;
import 'target_source.dart';

/// 대상 출처 묶음.
class CompositeTargetSource implements TargetSource {
  /// 묶음을 만든다.
  CompositeTargetSource(List<TargetSource> sources)
    : _sources = List<TargetSource>.unmodifiable(sources);

  final List<TargetSource> _sources;

  @override
  Future<List<OrderTarget>> targetsFor(TradeDate today) async => <OrderTarget>[
    for (final TargetSource s in _sources) ...await s.targetsFor(today),
  ];
}
