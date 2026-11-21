// 01 §4-1 — 🆕 계약 v1.33(01 §42 · K266 · E16j-b) — X1 기기 이전 읽기 창구(폰 전용 · `ui_safety` 만 · 구현 = 조립 앱 — 엔진 VM 생산).
//
// 🔴 라우트 인자 0 — 한 기기 한 이전 · 열린 창 하나(엔진이 마지막 run 을 안다 · 동작 args 의 `run_id` = 엔진).
// 🔴 시작 전 · 끝난 뒤 · 거부 = 엔진 문장 VM(스트림 에러가 아니다).
// 🔴 쓰기 = `SafetyActions.run`(VM · 행의 동작 그대로 · X1 id 6 · 제출 DTO 0).

import '../dto/migration.dart';

/// X1 기기 이전 화면 셋.
abstract interface class MigrationRepository {
  /// 옛 폰 계획 교체 마법사(`x1Migration`).
  Stream<X1PlanWizardVm> watchPlanWizard();

  /// 새 폰 받기(`x1MigrationPlan` · QR 스캔 → 복원 → 복구 단계 → 게이트).
  Stream<X1RecoveryVm> watchPlanRecovery();

  /// 새 폰 비상 복구(`x1MigrationEmergency` · 복구 코드 → 펜싱 → 재발급 → 복원 → 이하 받기와 같음).
  Stream<X1RecoveryVm> watchEmergencyRecovery();
}
