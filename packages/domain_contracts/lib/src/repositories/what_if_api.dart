// 01 §4-1 — M3 미리보기.
//
// 🔴 리포지토리가 **아니라** 부작용 0의 로컬 재계산이다(결정 2 파생 · `core_engine/lib/whatif/`).
//    03(M7 명세) §1-5 의 `WhatIfApi` 가 이것이며 이름은 **여기가 정본**이다
//    (구 `PlannerRepository` 폐기). DB 를 건드리지 않는다.

import 'package:decimal/decimal.dart';

import '../dto/plan.dart';
import '../primitives/money.dart';

/// 입금·인출·리밸런싱 미리보기.
abstract interface class WhatIfApi {
  Future<DepositPlan> simulateDeposit({
    required Decimal amount,
    required String accountAlias,
  });

  Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount});

  Future<RebalancePreview> previewRebalance({TradeDate? plannedDate});

  Future<CostEstimate> estimateCosts(String planId);

  /// 🔴 만료 판정도 결과의 상태값으로 온다 — 화면이 `expiresAt` 을 시계와 비교하지 않는다.
  Future<DepositPlan?> findPlan(String planId);
}
