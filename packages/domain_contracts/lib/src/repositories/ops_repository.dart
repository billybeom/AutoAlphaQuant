// 01 §4-1 — 🆕 G-29 M8·M9 운영 상태 읽기 창구.
//
// 🔴 **읽기 전용**이고 조작은 §4-3 `SettingsActions` 다. 화면이 `SettingsActions.run()` 을
//    폴링해 상태를 만들면 경계 규칙 ① 위반이다 — 「버튼을 누르지 않았는데 값이 갱신되는
//    자리」는 전부 여기다.
// 🔴 폰 빌드는 로컬에서, viewer 는 `rm_*` 읽기 모델에서 **같은 DTO** 를 받는다(계약 3조 ①).

import '../dto/ops.dart';
import '../dto/performance.dart';
import '../primitives/list_result.dart';

/// 워치독·연결·기기·백업·진단·연간 리뷰.
/// ✅ H-8 — 반환 타입 이름은 `m2-8_naming.md` G-3·G-7·G-8·G-9·G-10·F-6 이 확정한 그대로다.
abstract interface class OpsStatusRepository {
  /// `W-01` — 🔴 목록 길이·슬러그 이름은 **서버가 준다**(2축 합성 `{sim|live}-{auto|advisory}-{체크명}`).
  Stream<ListResult<WatchdogCheck>> watchWatchdog();

  /// `S07`.
  Stream<ConnectionsVm> watchConnections();

  /// `S06` — 🔴 리스는 읽기 전용이다.
  Stream<DeviceAccessVm> watchDeviceAccess();

  /// `S09`.
  Stream<BackupVm> watchBackup();

  /// `S10` — 🔴 칸 수 5 고정은 엔진이 준다(§2-9 `applicable`).
  Stream<DiagnosticsVm> watchDiagnostics();

  /// `S12` — 🔴 화면이 `windowState` 를 «달»로 판정하지 않는다.
  /// 🆕 v1.6(01 §15-4 · K25 · 결정 8 · §8 미결 95) — 이 창구의 `AnnualReviewVm` 은 `afterTax`·
  ///    `afterTaxCounterfactual` 을 **null** 로 준다(엔진 의무 · 06 M1-20b) — 세후 수치는 M7 `S7-7`
  ///    (`PerformanceRepository.annualReview`) 한 자리에만 간다. `S12` 의 표시 범위는 미결 95.
  Stream<AnnualReviewVm> watchAnnualReview();
}

/// 홈 블록 5·7 의 오늘 요약.
/// 🔴 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록 길이로 만들지 않는다
///    (double·int 산술이라 C-4 가 잡지 못한다 — 그래서 조문이 필요하다).
/// ✅ N-07(2026-10-22 · 발주자 결정) — 뷰어 원천 = `rm_ops_summary` v1 필수(01 §6-4 · 옛 열린 물음 §10-2 ⑤).
///    🆕 계약 v1.12 — 같은 표가 `watchRhythm` 의 전체 목록 열을 싣는다(열 이름 = 엔진 배치).
abstract interface class OpsSummaryRepository {
  Stream<OpsDailySummary> watchToday();
}
