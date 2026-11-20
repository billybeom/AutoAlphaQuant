// 01 §4-1 · 🆕 계약 v1.18(01 §27 · K-c · K-v) — M9 설정 화면 읽기 창구.
//
// 🔴 뒤 카드가 **추가형**으로 늘린다(✅ v1.19 R6c `watchOperations` · ✅ v1.20 R7 `watchCredentials`·`watchAccountMapping` · ✅ v1.23 R8a `watchContribution` · ✅ v1.24 R9 `watchDiagnosticsScreen` · ✅ v1.28 S04 `watchAllocationEditor`(첫 판 보기 전용 · 01 §37) · S11 `watchGeneral` = ⏸ R9e 창(엔진 원천 뒤 — 01 §8 미결 197)) — 받침대 `UnimplementedSettingsRepository` 를 같은 커밋에서 고친다.
// 🔴 `S07` 은 이 창구가 아니라 [OpsStatusRepository.watchConnections] 다(v1.0 부터 · 두 벌 0).
// 🔴 `S06` 은 이 창구가 아니라 [OpsStatusRepository.watchDeviceAccess] 다(v1.0 부터 · 두 벌 0 · v1.20 K14).
// 🔴 `S13` 의 값은 `ConfigRepository.watchContributionSetting()` 과 **같은 값 하나**(엔진 `contributionSettingOf`)의 화면 투영이다 — 두 벌 0(🆕 v1.23 K78).
// 🔴 `S10` 의 보드는 `OpsStatusRepository.watchDiagnostics()`(H-01)와 **같은 값 하나**(엔진 `diagnosticsOf`)를 감싸개 칸으로 싣는다 — 두 벌 0(🆕 v1.24 K113).

import '../dto/accounts.dart';
import '../dto/allocation.dart'; // 🆕 v1.28
import '../dto/operations.dart';
import '../dto/ops.dart';
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

  /// 🆕 v1.24(01 §33 · K113) — `S10` 진단(🔴 폰 전용 · 뷰어 원천 0 · 감싸개 한 스트림 — 보드 = `OpsStatusRepository.watchDiagnostics()`
  ///    와 같은 값(엔진 `diagnosticsOf` 하나) · `watchDiagnostics` 는 무변경(H-01 몫)).
  Stream<DiagnosticsScreenVm> watchDiagnosticsScreen();

  /// 🆕 v1.28(01 §37 · K199) — `S04` 배분 화면 첫 판(보기 전용 · 🔴 폰 · 뷰어 공통 — 뷰어 원천 = `rm_config_view` 배분 7열 ·
  /// `AllocationReadModelColumns`). 🔴 운영 설정을 못 읽으면 스트림 오류(구현 · 엔진 기본값 대입 0 — K206).
  Stream<AllocationEditorVm> watchAllocationEditor();
}
