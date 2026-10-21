// M3-1 · M3-2 — 엔진의 `WhatIfApi` 구현(01 §4-1 · §14-3 · §14-5 · §14-8 · 06 M3-1 · M3-2).
//
// 🔴 부작용 0 = 원장·명령 테이블 쓰기 0 — 이 구현이 쓰는 곳은 계획 스냅샷 저장소([PlanSnapshotStore]) 하나다.
//    상태는 [WhatIfStateSource] 에서 읽기만 한다.
// 🔴 `Future` 에러는 «계산을 못 했다»(인프라 — 상태 읽기 실패 · 가격 없음 등)만 뜻한다. 입력 거부·차단은 결과 갈래다.
// 🔵 호출마다 새 planId(06 M3-1 ⓓ) — 계획이 생길 때만 순번을 쓴다(차단·거부는 순번을 먹지 않는다).
// 🔵 `findPlan` 은 저장본에 **지금** 상태와 신뢰 시각으로 등록 불가 문장을 다시 판정해 싣는다 — RECON > LEDGER_FIX > 만료
//    (D-3 · 화면은 `expiresAt` 을 시계와 비교하지 않는다 · 만료 = 신뢰 시각 ≥ 만료 시각).
// ⏸ `simulateWithdrawal` 은 인출 규칙 결정 뒤 첫 minor 에서 시그니처가 바뀐다(01 §14-15) — 지금은 에러.
// 🟢 `previewRebalance`(E7a3-2) — 월말 계획기 + H64 관문 · 결과 캐시 0.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'deposit_plan.dart';
import 'plan_store.dart';
import 'rebalance_preview.dart';
import 'what_if_config.dart';
import 'what_if_gates.dart';
import 'what_if_state.dart';

/// 엔진 What-if 창구.
class EngineWhatIfApi implements WhatIfApi {
  EngineWhatIfApi({
    required this.source,
    required this.store,
    required this.clock,
    WhatIfConfig? config,
  }) : config = config ?? WhatIfConfig.defaults;

  final WhatIfStateSource source;
  final PlanSnapshotStore store;

  /// 신뢰 시각(M1-13 — 서버 시각).
  final Clock clock;
  final WhatIfConfig config;

  @override
  Future<DepositPreviewResult> simulateDeposit({
    required String amountInput,
  }) async {
    final WhatIfState s = await source.load();
    final DepositPreflight pre = depositPreflight(s, amountInput, config);
    if (pre.stop != null) return pre.stop!;
    final DateTime now = clock.nowUtc().toUtc();
    final int seq = await store.nextSequence(kstDay(now));
    final DepositPlan plan = buildDepositPlan(
      s,
      pre.amount!,
      config,
      gate: pre.gate,
      planId: depositPlanId(now, seq),
      computedAt: now,
    );
    await store.save(plan);
    return DepositPreviewResult(plan: plan);
  }

  @override
  Future<DepositPlan?> findPlan(String planId) async {
    final DepositPlan? saved = await store.find(planId);
    if (saved == null) return null;
    final WhatIfState s = await source.load();
    final bool expired = !clock.nowUtc().toUtc().isBefore(saved.expiresAt);
    return saved.copyWith(
      registerBlockedText: depositRegisterBlockedText(s, expired: expired),
    );
  }

  /// 🔴 호출자는 엔진뿐이다(플래너 · `S7-6c` 는 부르지 않는다 — 01 §14-8 · §15-4) · 없는 planId = 에러(D-13).
  @override
  Future<CostEstimate> estimateCosts(String planId) async {
    final DepositPlan? saved = await store.find(planId);
    if (saved == null) {
      throw StateError('계획 스냅샷이 없다: $planId');
    }
    return saved.costs;
  }

  @override
  Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount}) =>
      Future<WithdrawalPlan>.error(
        UnimplementedError('simulateWithdrawal — 인출 규칙 결정 뒤(01 §14-15)'),
      );

  /// 🔴 결과 캐시 0(01 §15-4 ②) — 저장하지 않는다 · 계획 id 는 순번만(`pv_re_<회차 yyyyMMdd>_<순번 두 자리>` · 픽스처 꼴).
  @override
  Future<RebalancePreviewResult> previewRebalance({
    TradeDate? plannedDate,
  }) async {
    final WhatIfState s = await source.load();
    final TradeDate? planned = plannedRebalanceDate(s, plannedDate);
    final RebalancePreviewResult? stop = rebalancePreflight(
      s,
      hasPlannedDate: planned != null,
    );
    if (stop != null) return stop;
    final String day = planned!.yyyyMmDd.replaceAll('-', '');
    final int seq = await store.nextSequence('re_$day');
    return previewRebalancePlan(
      s,
      config,
      planned: planned,
      planId: 'pv_re_${day}_${seq.toString().padLeft(2, '0')}',
    );
  }
}
