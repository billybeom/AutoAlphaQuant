// 01 §2-6 · §4-1 — M8·M9 운영 상태 뷰모델(m2-8 G-1~G-4 · G-7~G-10 · J-2).
//
// 🔴 **읽기 전용**이다. 조작은 §4-3 `SettingsActions` 이며, 뷰어 빌드에서는 그
//    구현체가 주입되지 않으므로 컨트롤은 «비활성»이 아니라 **부재**다.
// 🔴 홈 블록 5·7 의 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록
//    길이로 만들지 않는다(01 §4-1 · G-29). int·double 산술이라 C-4 가 잡지 못한다.
// 🔴 `actionAvailable == false` 는 «비활성»이 아니라 **카드·버튼의 부재**로 그린다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart'; // 🆕 v1.13 — DiagnosticCell.level
import '../primitives/as_of.dart';
import 'common.dart';

part 'ops.freezed.dart';
part 'ops.g.dart';

/// m2-8 G-1 — 셸(`ui_shell`)이 주입하는 모드 접두와 상단 띠.
/// 🔴 **띠는 하나이고 칩이 2개**다(2줄로 만들지 않는다 · C-18).
/// 🔴 접두 순서는 «모의투자 · 투자 안내 · 제목» 이며 화면이 접두를 직접 쓰지
///    않는다(01 §9-3 · C-17 — 한 화면만 빠뜨려도 그 화면이 실전처럼 보인다).
@freezed
abstract class ShellVm with _$ShellVm {
  const factory ShellVm({
    required List<ShellChip> bandChips,

    /// null 이면 접두를 붙이지 않는다(`live` 는 접두가 없다).
    String? runModePrefix,

    /// null 이면 접두를 붙이지 않는다(`autoTrade` 는 접두가 없다).
    String? operatingModePrefix,

    /// 🔴 색의 근거는 이 코드다 — 값의 부호로 고르지 않는다.
    String? bandToneCode,
  }) = _ShellVm;

  factory ShellVm.fromJson(Map<String, dynamic> json) =>
      _$ShellVmFromJson(json);
}

/// ⚠️ **M2-8 미확정** — G-1 이 `List<ShellChip>` 이라는 **이름만** 확정했고 필드
/// 축은 문서에 없다. 아래는 `GateBadge`(§2-1)·`SettingsCard`(G-5)와 같은 모양으로
/// 둔 **임시 최소 축**이다. 🔴 문구는 엔진이 주고 화면이 조합하지 않는다.
@freezed
abstract class ShellChip with _$ShellChip {
  const factory ShellChip({
    required String code,
    required String label,
    String? toneCode,
  }) = _ShellChip;

  factory ShellChip.fromJson(Map<String, dynamic> json) =>
      _$ShellChipFromJson(json);
}

/// m2-8 G-2 — 운영 리듬 1행(04 §4-7 `H-02`).
/// 🔴 `dDayText` 는 엔진 생성 문자열이다 — 화면이 날짜를 빼지 않는다.
/// 🆕 v1.12(01 §21 · K29 · K30) — 전체 목록 = `OpsSummaryRepository.watchRhythm()` · 행 탭 = [route](null = 반응 없음) ·
///    `H-02` «조치» 열 = 없음(2026-10-22 삭제 — 할 일은 [title] 이 말한다).
///    필드 5개가 전부다 — 등급·선행·조치 칸 0(04 §4-7 · 2026-10-22 결정).
@freezed
abstract class OpsRhythmRow with _$OpsRhythmRow {
  const factory OpsRhythmRow({
    required String code,
    required String title,
    required String whenText,
    String? dDayText,
    String? route,
  }) = _OpsRhythmRow;

  factory OpsRhythmRow.fromJson(Map<String, dynamic> json) =>
      _$OpsRhythmRowFromJson(json);
}

/// m2-8 G-3 — 워치독 체크 1행(04 §7 `W-01`). 🆕 v1.15(01 §24 · K4 · K16 · K17) — `slug` 삭제 → [checkId] · [level].
///
/// 🔴 목록의 길이·이름·차례는 **서버가 준다** — 화면이 상수 배열을 갖지 않는다.
/// 🔴 healthchecks 슬러그(2축 합성 `{sim|live}-{auto|advisory}-{체크명}` · §9-5 ⑦ · C20)·ping URL·키는 이 DTO 에
///    **오지 않는다**(엔진·워치독 설정 몫 · 04 §7 «뷰모델에 그 필드가 없어야 정상» · C-49 ⑪).
@freezed
abstract class WatchdogCheck with _$WatchdogCheck {
  const factory WatchdogCheck({
    /// 🆕 v1.15(K17) — 엔진이 짓는 불투명 id(보드 안 유일). 🔴 슬러그·URL 에서 파생하지 않는다 ·
    /// 화면은 그리지도 · Key 로도 · 비교로도 쓰지 않는다(Key = 순번).
    required String checkId,
    required String label,

    /// 화면 미참조(사전 아님 — 엔진 몫).
    required String stateCode,
    required String stateLabel,

    /// 🆕 v1.15(K16) — 상태 모양의 유일한 근거(성공·휴장 성공 핑 = ok · 지연 = watch · 실패 = blocked ·
    /// 일시정지 = info). 🔴 화면은 [stateCode] 로 색·아이콘을 고르지 않는다(v1.13 `DiagnosticCell.level` 선례).
    required UiLevel level,
    required String lastPingText,
    String? graceText,
    String? route,
  }) = _WatchdogCheck;

  factory WatchdogCheck.fromJson(Map<String, dynamic> json) =>
      _$WatchdogCheckFromJson(json);
}

/// 🆕 v1.15(01 §24 · K3 · K15 · 발주자 결정 ②(b)) — `W-01` 워치독 보드 한 화면
/// (창구 [OpsStatusRepository.watchWatchdog] 의 반환 · 구 `ListResult<WatchdogCheck>`).
@freezed
abstract class WatchdogBoardVm with _$WatchdogBoardVm {
  const factory WatchdogBoardVm({
    /// 서버가 준 목록 그대로(개수·이름·차례 = 엔진).
    required List<WatchdogCheck> rows,
    required AsOf asOf,

    /// 행 0 일 때만 non-null(엔진 문장). 행이 있으면 null.
    String? emptyLabel,

    /// 휴장일 고지(구 봉투 형제 키 `holiday_notice`) — 휴장일만 non-null.
    String? holidayNotice,

    /// 하단 한계 고지(healthchecks.io 자체 장애 계열 · 04 §7 «한계·이력»).
    /// 엔진 의무 = 늘 싣는다(행 0 보드 포함). null = 부재.
    String? limitNotice,

    /// 머리 «마지막 수신 17:58»(엔진 글자). 받은 적이 없으면 null.
    String? lastReceivedText,
  }) = _WatchdogBoardVm;

  factory WatchdogBoardVm.fromJson(Map<String, dynamic> json) =>
      _$WatchdogBoardVmFromJson(json);
}

/// 01 §4-1 · m2-8 G-4 — 홈 블록 5·7 의 오늘 요약.
/// 🔴 **전부 엔진 완성 문자열이며 수치 필드가 0건**이다.
@freezed
abstract class OpsDailySummary with _$OpsDailySummary {
  const factory OpsDailySummary({
    required AsOf asOf,
    required String todayOrdersText,
    required String todayErrorsText,
    required String signalMatchText,
    required String streakText,
    required String discretionBudgetText,
    required String nextRebalanceDDayText,

    /// 🔴 `watchRhythm()` 목록의 **앞 ≤3 과 같은 값**이다(엔진 의무 · 🆕 v1.12 · C-47 ⑤).
    required List<OpsRhythmRow> upcoming,

    /// 🆕 v1.12(01 §21 · K44) — `H-01` 블록 2 «X2 한 줄»(엔진 한 문장 · → `aaq://x2/resume-report`). null = 블록 2 부재
    /// (평시 문장을 엔진이 늘 싣는지 = 01 §8 미결 122).
    LinkAction? resumeLine,
  }) = _OpsDailySummary;

  factory OpsDailySummary.fromJson(Map<String, dynamic> json) =>
      _$OpsDailySummaryFromJson(json);
}

/// m2-8 G-7 — 연결 관리(05 `S07`).
@freezed
abstract class ConnectionsVm with _$ConnectionsVm {
  const factory ConnectionsVm({
    required List<ConnectionRow> rows,
    required AsOf asOf,
  }) = _ConnectionsVm;

  factory ConnectionsVm.fromJson(Map<String, dynamic> json) =>
      _$ConnectionsVmFromJson(json);
}

/// m2-8 G-7 — 연결 1행.
@freezed
abstract class ConnectionRow with _$ConnectionRow {
  const factory ConnectionRow({
    required String target,
    required String label,
    required String statusCode,
    required String statusLabel,
    required String lastOkText,

    /// 🔴 false 면 버튼을 **만들지 않는다**(비활성이 아니다).
    required bool actionAvailable,
    String? route,
  }) = _ConnectionRow;

  factory ConnectionRow.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRowFromJson(json);
}

/// m2-8 G-8 — 기기·접근 관리(05 `S06`). 🔴 **리스는 읽기 전용**이다.
@freezed
abstract class DeviceAccessVm with _$DeviceAccessVm {
  const factory DeviceAccessVm({
    required List<DeviceRow> devices,
    required String leaseHolderLabel,
    required String leaseStateLabel,
    required AsOf asOf,

    /// 🔴 신뢰 시각(Supabase 서버 시각) 기반 엔진 문자열 — 폰 시계로 남은 시간을
    ///    계산하지 않는다.
    String? leaseEtaText,
  }) = _DeviceAccessVm;

  factory DeviceAccessVm.fromJson(Map<String, dynamic> json) =>
      _$DeviceAccessVmFromJson(json);
}

/// m2-8 G-8 — 기기 1행. 🔴 기기 전체 식별자를 화면 문구로 만들지 않는다.
@freezed
abstract class DeviceRow with _$DeviceRow {
  const factory DeviceRow({
    required String deviceId,
    required String label,
    required String roleLabel,
    required String statusLabel,
    required String lastSeenText,
  }) = _DeviceRow;

  factory DeviceRow.fromJson(Map<String, dynamic> json) =>
      _$DeviceRowFromJson(json);
}

/// m2-8 G-9 — 백업·복원(05 `S09`).
@freezed
abstract class BackupVm with _$BackupVm {
  const factory BackupVm({
    required String lastOkText,
    required String statusCode,
    required String statusLabel,
    required bool actionAvailable,
    required AsOf asOf,
    String? sizeText,
    String? route,
  }) = _BackupVm;

  factory BackupVm.fromJson(Map<String, dynamic> json) =>
      _$BackupVmFromJson(json);
}

/// m2-8 G-10 — 진단 보드(05 `S10`) · 🆕 v1.13 `H-01` 블록 6(R13b)도 이 VM 을 그린다(01 §23).
/// 🔴 **칸 수 5 고정은 엔진이 준다** — 모드와 무관하며 화면이 세지 않는다(§2-9).
/// 🆕 v1.13(01 §23 · K4) — [headline] 은 **늘 엔진 문장**이다(전부 일치 날 = 일치를 말하는 문장 · 빈 글자 0) ·
///    화면은 늘 그린다 — 칸 상태로 문장을 고르거나 숨기지 않는다.
@freezed
abstract class DiagnosticsVm with _$DiagnosticsVm {
  const factory DiagnosticsVm({
    required List<DiagnosticCell> cells,
    required String headline,
    required AsOf asOf,
  }) = _DiagnosticsVm;

  factory DiagnosticsVm.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticsVmFromJson(json);
}

/// m2-8 G-10 — 진단 1칸.
/// 🔴 `applicable == false` 칸도 빼지 않는다 — 엔진의 [stateLabel](«해당 없음»·«점검하지 않음» 등)을
///    그대로 그린다 · 빈칸·통과로 그리지 않는다(C15 · G-27).
/// 🆕 v1.13(01 §23 · K2 · K3) — [level] = 신호등 색·아이콘의 유일한 근거(04 §2-3 «색+아이콘+텍스트 3중») ·
///    [stateCode] 로 색을 고르지 않는다(ui 미참조) · 엔진 의무: `applicable == false` ⇒ `info` ·
///    `blocked` 는 `canonBroker`·`canonSelfReport` 만(파생 불일치는 주문을 막지 않는다) · 점검한 칸
///    (`applicable == true`)은 `stateCode == 'OK'` ⇔ `level == ok`(«어긋납니다» 를 초록으로 그리지 않는다 · K3 ⓒ) — C-47 ⑩.
@freezed
abstract class DiagnosticCell with _$DiagnosticCell {
  const factory DiagnosticCell({
    required LedgerPair pair,
    required String label,
    required bool applicable,
    required String stateCode,
    required String stateLabel,
    required UiLevel level,
  }) = _DiagnosticCell;

  factory DiagnosticCell.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticCellFromJson(json);
}

/// ⏸ m2-8 J-2 — `live × dryRun` 관찰 기간·승격 확인(§8-28 G-43).
/// 🔴 **이름만 확정이고 기능은 발주자 확정 대기**다: 관찰 거래일 수는 엔진 config
///    신설 키이며 화면·계약이 상수로 적지 않는다(`requiredTradingDays` 로 온다).
/// 🔴 **승격에 새 화면·새 라우트를 만들지 않는다** — `S05` 엔진 상태 칩 + 기존 M5
///    게이트 다이얼로그(생체 1회)다.
@freezed
abstract class LiveDryRunObservationVm with _$LiveDryRunObservationVm {
  const factory LiveDryRunObservationVm({
    required int observedTradingDays,
    required int requiredTradingDays,

    /// 🔴 표시의 정본 — 화면이 두 수치로 「n/m」을 조립하지 않는다.
    required String progressText,
    required bool promotionAvailable,
    required String stateLabel,
  }) = _LiveDryRunObservationVm;

  factory LiveDryRunObservationVm.fromJson(Map<String, dynamic> json) =>
      _$LiveDryRunObservationVmFromJson(json);
}

/// 🆕 계약 v1.17(01 §26 · K17 · 01 §8 미결 123) — `H-03` 물리 리스크 항목 1행.
/// 🔴 글자 전부 = 엔진(측정 = 플랫폼 API · 임계·판정·조치 문구 = 엔진) · 화면은 비교·남은 일수 계산을 하지 않는다 ·
///    [level] = 아이콘·색만.
@freezed
abstract class DeviceRiskItem with _$DeviceRiskItem {
  const factory DeviceRiskItem({
    /// «저장공간» — 엔진.
    required String label,

    /// «남은 공간 3.1GB» — 엔진.
    required String currentText,

    /// «임계 2GB 미만» — 엔진.
    required String thresholdText,

    /// «오래된 아카이브를 PC로 옮기세요» — 엔진.
    required String actionText,

    /// «마지막 점검 08-31 08:55» — 엔진(KST).
    required String lastCheckedText,
    required UiLevel level,
  }) = _DeviceRiskItem;

  factory DeviceRiskItem.fromJson(Map<String, dynamic> json) =>
      _$DeviceRiskItemFromJson(json);
}
// JSON 키: label · current_text · threshold_text · action_text · last_checked_text · level

/// 🆕 계약 v1.17 — `H-03` 물리 리스크 점검 상세(창구 [OpsStatusRepository.watchDeviceRisk] · 04 §4-6 그림 8).
/// 🔴 항목 목록·수·차례 = 받은 그대로(넷 하드코딩 0) · 조작 버튼(로그 정리·백업 실행) 칸 0 = 01 §8 미결 161 · asOf 있음(측정값).
@freezed
abstract class DeviceRiskVm with _$DeviceRiskVm {
  const factory DeviceRiskVm({
    required List<DeviceRiskItem> rows,

    /// «비상 복구가 아니라 계획 교체» 안내 — 엔진(늘 싣는다).
    required String guidanceText,

    /// 행 0 일 때만 non-null(엔진 문장).
    String? emptyLabel,
    required AsOf asOf,
  }) = _DeviceRiskVm;

  factory DeviceRiskVm.fromJson(Map<String, dynamic> json) =>
      _$DeviceRiskVmFromJson(json);
}
// JSON 키: rows · guidance_text · empty_label · as_of
