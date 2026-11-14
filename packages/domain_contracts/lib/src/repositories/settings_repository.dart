// 01 §4-1 · 🆕 계약 v1.18(01 §27 · K-c · K-v) — M9 설정 화면 읽기 창구.
//
// 🔴 뒤 카드가 **추가형**으로 늘린다(✅ v1.19 R6c `watchOperations` · R7 `watchCredentials`·`watchAccountMapping` ·
//    R8 `watchAllocationEditor` · S11 `watchGeneral`) — 받침대 `UnimplementedSettingsRepository` 를 같은 커밋에서 고친다.
// 🔴 `S07` 은 이 창구가 아니라 [OpsStatusRepository.watchConnections] 다(v1.0 부터 · 두 벌 0).

import '../dto/operations.dart';
import '../dto/settings.dart';

abstract interface class SettingsRepository {
  /// `S01` 설정 홈 — 폰·뷰어 같은 DTO(뷰어 판 = 폰 전용 행을 엔진이 뺀 VM).
  Stream<SettingsHomeVm> watchHome();

  /// 🆕 v1.19(01 §28) — `S05` 운용 관리(🔴 폰 전용 · 뷰어 원천 0 · K20).
  Stream<OperationsVm> watchOperations();
}
