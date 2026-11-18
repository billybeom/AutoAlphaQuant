// domain_contracts — M2 도메인 계약의 공개 진입점(배럴).
//
// 🔴 화면(ui_*)이 import 하는 파일은 이것 하나다. lib/src/ 아래를 직접 import
//    하지 않는다 — 내부 구조를 바꿀 때 화면이 조용히 깨진다(인벤토리 §0).
// 🔴 **이 파일은 통합 담당만 편집한다.** 영역 구현자는 자기 폴더에 파일을
//    더하고, 그 폴더의 재수출 창구(`src/<영역>.dart`)에 통합 단계가 줄을 넣는다.
//
// 창구 10개 — 영역 A(primitives·enums) · B·C(dto) · D(repositories·commands) ·
// E(labels·contract_version) · F(fixtures) · G(navigation — 🆕 v1.1) ·
// H(schema — 🆕 v1.9 로컬 원장 두 파일 · SIM 판 파생). 어느 창구에 무엇이 있는지는
// 각 `src/<영역>.dart` 머리 주석과 `docs/contracts_inventory.md` 가 정본이다.
//
// ⚠️ 아직 여기에 없는 것(= 계약에 아직 존재하지 않는 것)은 각 영역의 인계
//    사항에 사유와 함께 적혀 있다. 대표적으로 `LedgerEventKind`/
//    `LedgerEventRecord`(결정 ㊲ 대기 · M2-8 A-15·J-6) · `SplitExecutionLeg`
//    (M2-8 C-11) · `AllocationEditorVm`
//    (M2-8 §G 표 미등재 · S04 창 — 엔진 결정 대기 · 01 §8 미결 190~194)이다. 🆕 v1.17(01 §26) — `IncidentBanner`·`Runbook`·긴급정지 카드는 이름이 확정돼
//    들어왔다(`dto/incident.dart`).
//    🆕 v1.18(01 §27) — `S01`·`S07` 계약 확정(`SettingsHomeVm` 교체 · `SettingsRepository`).
//    🆕 v1.19(01 §28) — `S05` 계약 확정(`OperationsVm` · 부품 8 · `watchOperations`).
//    🆕 v1.20(01 §29) — `S02`·`S06`·`S03` 계약 확정(`CredentialListVm` 추가형 · `DeviceAccessVm` 추가형 + `PairingTicketCard` ·
//    🆕 `AccountMappingVm` · `watchCredentials`·`watchAccountMapping`).
//    🆕 v1.23(01 §32) — `S13` 월 납입 계약 확정(`MonthlyContributionVm` 추가형 · `watchContribution` · `ContributionUpdateSubmission` · `runContributionUpdate` · `ContributionResultCodes`).
//    🆕 v1.24(01 §33) — `S09`·`S10`·`S12` 계약(`BackupVm` 교체 · `RestorePointRow` · `DiagnosticsScreenVm` · `SelfTestCard` · `AnnualReviewIndexVm` ·
//    `watchDiagnosticsScreen` · `BackupResultCodes` · `LedgerIntegrityResultCodes`).
//    🔴 화면이 대신 지어내지 않는다 — 이름이 확정된 뒤 계약에 들어온다.

export 'src/commands.dart';
export 'src/contract_version.dart';
export 'src/dto.dart';
export 'src/enums.dart';
export 'src/fixtures.dart';
export 'src/labels/labels.dart';
export 'src/mode_marker_text.dart'; // 🆕 v1.22 영역 E — 표지 글자(사전 아님 · 01 §31 K67)
export 'src/navigation.dart';
export 'src/primitives.dart';
export 'src/repositories.dart';
export 'src/schema/ledger_file.dart';
