// 01 §4-1 · 🆕 계약 v1.18(01 §27 · K-c · K-v) — M9 설정 화면 읽기 창구.
//
// 🔴 뒤 카드가 **추가형**으로 늘린다(✅ v1.19 R6c `watchOperations` · ✅ v1.20 R7 `watchCredentials`·`watchAccountMapping` · ✅ v1.23 R8a `watchContribution` · S04 창 `watchAllocationEditor`(엔진 결정 대기 — 01 §8 미결 190~194) · S11 `watchGeneral`) — 받침대 `UnimplementedSettingsRepository` 를 같은 커밋에서 고친다.
// 🔴 `S07` 은 이 창구가 아니라 [OpsStatusRepository.watchConnections] 다(v1.0 부터 · 두 벌 0).
// 🔴 `S06` 은 이 창구가 아니라 [OpsStatusRepository.watchDeviceAccess] 다(v1.0 부터 · 두 벌 0 · v1.20 K14).
// 🔴 `S13` 의 값은 `ConfigRepository.watchContributionSetting()` 과 **같은 값 하나**(엔진 `contributionSettingOf`)의 화면 투영이다 — 두 벌 0(🆕 v1.23 K78).

import '../dto/accounts.dart';
import '../dto/operations.dart';
import '../dto/settings.dart';

abstract interface class SettingsRepository {
  /// `S01` 설정 홈 — 폰·뷰어 같은 DTO(뷰어 판 = 폰 전용 행을 엔진이 뺀 VM).
  Stream<SettingsHomeVm> watchHome();

  /// 🆕 v1.19(01 §28) — `S05` 운용 관리(🔴 폰 전용 · 뷰어 원천 0 · K20).
  Stream<OperationsVm> watchOperations();

  /// 🆕 v1.20(01 §29) — `S02` 증권사 키 관리(🔴 폰 전용 · 값·키 조각 0 · K7).
  Stream<CredentialListVm> watchCredentials();

  /// 🆕 v1.20(01 §29) — `S03` 계좌 연동·슬리브 매핑(🔴 폰 전용 · 계좌 전체번호 0).
  Stream<AccountMappingVm> watchAccountMapping();

  /// 🆕 v1.23(01 §32 · K78) — `S13` 월 납입 설정(🔴 폰 전용 · 뷰어 원천 0 · 값의 원천 = 엔진 `contributionSettingOf` 하나 —
  ///    S7-4·H-02 는 그대로 `ConfigRepository.watchContributionSetting()`).
  Stream<MonthlyContributionVm> watchContribution();
}
