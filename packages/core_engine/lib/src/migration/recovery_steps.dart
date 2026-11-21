// X1-4 새 폰 복구 단계(순수 · 설계 13 §8 R137 N2 · 02 §2-6 `migration_step` — 단계 목록은 코드가 정본).
//
// 🔴 새 폰 저널 = 같은 `migration_run` · `migration_step`(role NEW_DEVICE) · 단계마다 DONE 1행.
// 🆕 E16h2 — 골든 자가검사 · 승인 2단계(체크리스트 → 생체) · 🟡 펜싱 · 재발급 기록 = E16t(복원 전 · R138 Q1).

import 'package:domain_contracts/domain_contracts.dart'
    show X1RecoveryStepCodes;

/// 새 폰 복구 단계(차례 = 정의 차례).
enum RecoveryStep {
  /// 검증된 스냅숏을 복원했다(detail = 매니페스트 정규 글자).
  restored(X1RecoveryStepCodes.restored),

  /// 갭 창 브로커 체결을 복구 행으로 승격했다.
  gapRebuilt(X1RecoveryStepCodes.gapRebuilt),

  /// 🆕 E16h2 — 골든 자가검사(DONE = 통과 · FAILED = 실패).
  goldenSelfTest(X1RecoveryStepCodes.goldenSelfTest),

  /// 🆕 E16h2 — 승인 1(체크리스트).
  checklistConfirmed(X1RecoveryStepCodes.checklistConfirmed),

  /// 🆕 E16h2 — 승인 2(생체 · 체크리스트 뒤).
  biometricConfirmed(X1RecoveryStepCodes.biometricConfirmed);

  const RecoveryStep(this.wire);

  /// 저장 글자.
  final String wire;
}
