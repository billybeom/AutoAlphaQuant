// 01 §4-1 — 🆕 계약 v1.26(01 §35 · K179) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판» 읽기 창구(폰 전용 · `ui_safety` 만).
//
// 🔴 냉각이 끝나면 새 VM(`approveLabel` 생김) — 화면 카운트다운 0.
// 🔴 쓰기 = `SafetyActions.runRuleChangeRequest`(요청) · `runRuleChangeApproval`(승인) · `run(ruleChangeCancel)`(행의 `cancel` 그대로).

import '../dto/safety_gate.dart';

/// 규칙 변경 게이트 한 화면.
abstract interface class RuleChangeGateRepository {
  Stream<RuleChangeGateVm> watchGate();
}
