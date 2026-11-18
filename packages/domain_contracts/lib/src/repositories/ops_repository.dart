// 01 §4-1 — 🆕 G-29 M8·M9 운영 상태 읽기 창구.
//
// 🔴 **읽기 전용**이고 조작은 §4-3 `SettingsActions` 다. 화면이 `SettingsActions.run()` 을
//    폴링해 상태를 만들면 경계 규칙 ① 위반이다 — 「버튼을 누르지 않았는데 값이 갱신되는
//    자리」는 전부 여기다.
// 🔴 폰 빌드는 로컬에서, viewer 는 `rm_*` 읽기 모델에서 **같은 DTO** 를 받는다(계약 3조 ①).

import '../dto/ops.dart';
import '../primitives/list_result.dart';

/// 워치독·연결·기기·백업·진단·연간 리뷰.
/// ✅ H-8 — 반환 타입 이름은 `m2-8_naming.md` G-3·G-7·G-8·G-9·G-10·F-6 이 확정한 그대로다 · 🆕 v1.24 — `watchAnnualReview` 반환 =
///    F-6 밖 새 타입 `AnnualReviewIndexVm`(K118).
abstract interface class OpsStatusRepository {
  /// `W-01` — 🆕 v1.15(01 §24 · K3) 반환 = [WatchdogBoardVm](구 `ListResult<WatchdogCheck>`).
  /// 🔴 목록 길이·이름·차례는 서버가 준다 · healthchecks 슬러그·ping URL·키는 이 창구에 오지 않는다(K4 · K17).
  Stream<WatchdogBoardVm> watchWatchdog();

  /// `S07`.
  Stream<ConnectionsVm> watchConnections();

  /// `S06` — 🔴 리스는 읽기 전용이다.
  Stream<DeviceAccessVm> watchDeviceAccess();

  /// `S09` — 🆕 v1.24(01 §33 · K110) 반환 = 교체된 [BackupVm](타입 이름 그대로 · 칸 교체 — 소비자 0 에서) · 🔴 폰 전용(뷰어 원천 0).
  Stream<BackupVm> watchBackup();

  /// `S10` — 🔴 칸 수 5 고정은 엔진이 준다(§2-9 `applicable`).
  /// 🆕 v1.13(01 §23) — `H-01` 블록 6(R13b)의 원천도 이 창구다(칸 색 = `DiagnosticCell.level` · `headline` 늘) ·
  ///    뷰어 원천 = 01 §8 미결 128.
  /// 🆕 v1.24(01 §33 · K113) — M9 `S10` 화면은 `SettingsRepository.watchDiagnosticsScreen()`(감싸개 · 같은 보드 값)을 읽는다 · 이 창구 무변경.
  Stream<DiagnosticsVm> watchDiagnostics();

  /// `S12` — 🔴 화면이 창을 «달»로 판정하지 않는다.
  /// 🆕 v1.24(01 §33 · K118 · §8 미결 95 (b)) — 반환 = **[AnnualReviewIndexVm]**(목차 전용 · 세후·수익률·`lines` 칸 0 — 타입으로 막는다) ·
  ///    ~~`AnnualReviewVm`(세후 두 필드 null 의무 · v1.6 K25)~~ · 이름 그대로(C-42 `_windowMethods` 가 쥔다) · M7 `S7-7` =
  ///    `PerformanceRepository.annualReview` 의 `AnnualReviewVm` 그대로.
  Stream<AnnualReviewIndexVm> watchAnnualReview();

  /// 🆕 v1.17(01 §26 · K17 · 01 §8 미결 123) — `H-03` 물리 리스크 점검(측정 = 플랫폼 · 판정·문구 = 엔진 · asOf 있음).
  /// 🔴 Android(operator) 화면이다 — 뷰어 빌드에는 본문이 등록되지 않는다(조립 앱 레지스트리 · 셸 가드 무변경).
  Stream<DeviceRiskVm> watchDeviceRisk();
}

/// 홈 블록 5·7 의 오늘 요약.
/// 🔴 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록 길이로 만들지 않는다
///    (double·int 산술이라 C-4 가 잡지 못한다 — 그래서 조문이 필요하다).
/// ✅ N-07(2026-10-22 · 발주자 결정) — 뷰어 원천 = `rm_ops_summary` v1 필수(01 §6-4 · 옛 열린 물음 §10-2 ⑤).
///    🆕 계약 v1.12 — 같은 표가 [watchRhythm] 의 전체 목록 열을 싣는다(열 이름 = 엔진 배치).
abstract interface class OpsSummaryRepository {
  Stream<OpsDailySummary> watchToday();

  /// 🆕 v1.12(01 §21 · §8 미결 113 · K29) — `H-02` 운영 리듬 표 전체(받은 순서 = 표 순서 · 화면이 거르거나 채우지 않는다).
  /// 🔴 [watchToday] 의 `upcoming` 은 이 목록의 **앞 ≤3 과 같은 값**이다(엔진 의무 · C-47 ⑤) · 뷰어 = `rm_ops_summary`
  ///    전체 목록 열(열 이름 = 엔진 배치).
  Stream<ListResult<OpsRhythmRow>> watchRhythm();
}
