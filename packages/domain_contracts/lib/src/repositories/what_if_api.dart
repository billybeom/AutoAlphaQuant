// 01 §4-1 — M3 미리보기.
//
// 🔴 리포지토리가 **아니라** 부작용 0의 로컬 재계산이다(결정 2 파생 · `core_engine/lib/src/whatif/`).
//    03(M7 명세) §1-5 의 `WhatIfApi` 가 이것이며 이름은 **여기가 정본**이다
//    (구 `PlannerRepository` 폐기). DB 를 건드리지 않는다.
// 🆕 v1.4(01 §14-8) — «부작용 0» = 원장·명령 테이블 쓰기 0 이다. 계획 스냅샷(`plan_snapshot`)은
//    등록 대조용 **엔진 로컬 캐시**라 이 조문과 모순되지 않는다(06 M3-1).
// 🔴 v1.4 호출 표(01 §14-8) — 플래너(S7-4)는 `simulateDeposit` 만 부른다(«미리보기 계산» 탭 ·
//    «다시 계산» 탭 · 에러 재시도). 늦게 온 이전 요청 결과는 버린다(마지막 요청만).
//    `estimateCosts`·`findPlan`·`previewRebalance` 는 플래너가 부르지 않는다.

import 'package:decimal/decimal.dart';

import '../dto/plan.dart';
import '../primitives/money.dart';

/// 입금·인출·리밸런싱 미리보기.
abstract interface class WhatIfApi {
  /// 🆕 v1.4 — [amountInput] 은 **입력칸 글자 그대로**다(자르기·쉼표 제거·숫자 검사를 화면이
  /// 하지 않는다). 파싱·빈칸·0·음수·범위·차단(재개 미완·복구·원장 무결성·계좌 매핑 미완)
  /// 판정은 전부 구현체가 하고, 결과는 [DepositPreviewResult] 의 세 갈래(plan · 입력 거부 ·
  /// 차단) 중 하나로 돌려준다. 계좌 라우팅도 엔진 몫이다(구 `accountAlias` 인자 삭제).
  /// 🔴 `Future` 에러는 «계산을 못 했다»(인프라)만 뜻한다 — 화면은 공통 에러 뷰 + 입력 유지 +
  ///    같은 글자로 재시도이며 에러 내용으로 분기하지 않는다.
  Future<DepositPreviewResult> simulateDeposit({required String amountInput});

  /// ⏸ v1.4 무변경 — 인출 규칙 결정 뒤 첫 minor(S7-5 · 01 §14-15 «예정»)에서
  ///    `({required String amountInput}) → WithdrawalPreviewResult` 로 바뀐다.
  Future<WithdrawalPlan> simulateWithdrawal({required Decimal amount});

  Future<RebalancePreview> previewRebalance({TradeDate? plannedDate});

  Future<CostEstimate> estimateCosts(String planId);

  /// 🆕 v1.4 — null = 그 planId 가 없다. 만료·등록 불가는 `DepositPlan.registerBlockedText` 로
  /// 온다 — 화면이 `expiresAt` 을 시계와 비교하지 않는다.
  Future<DepositPlan?> findPlan(String planId);
}
