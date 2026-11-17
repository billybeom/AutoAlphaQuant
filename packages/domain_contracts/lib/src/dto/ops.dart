// 01 §2-6 · §4-1 — M8·M9 운영 상태 뷰모델(m2-8 G-1~G-4 · G-7~G-10 · J-2).
//
// 🔴 **읽기 전용**이다. 조작은 §4-3 `SettingsActions` 이며, 뷰어 빌드에서는 그
//    구현체가 주입되지 않으므로 컨트롤은 «비활성»이 아니라 **부재**다.
// 🔴 홈 블록 5·7 의 «세는 수»는 전부 엔진이 세어 **문자열로** 준다 — 화면이 목록
//    길이로 만들지 않는다(01 §4-1 · G-29). int·double 산술이라 C-4 가 잡지 못한다.
// 🔴 🆕 v1.24 — 이 파일에 `actionAvailable` 칸 0(v1.18 `ConnectionRow` · v1.24 `BackupVm` 삭제) · 버튼 유무 =
//    `SettingsActionCall?`/`LinkAction?` null = **부재**(«비활성» 0).
// 🆕 v1.20(01 §29) — `S06` `DeviceAccessVm`·`DeviceRow` 추가형 · 🆕 `PairingTicketCard`.
// 🆕 v1.24(01 §33 · K110 · K113 · K118) — `S09` `BackupVm` 교체(소비자 0) + `RestorePointRow` · `S10` 감싸개 `DiagnosticsScreenVm` +
//    `SelfTestCard`(`DiagnosticsVm` 무변경 — H-01 과 같은 값) · `S12` 전용 목차 `AnnualReviewIndexVm`(세후·수치 칸 0 — `AnnualReviewVm` 무변경).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ledger.dart';
import '../enums/ui.dart'; // 🆕 v1.13 — DiagnosticCell.level
import '../primitives/as_of.dart';
import 'common.dart';
import 'onboarding.dart'; // 🆕 v1.18 — SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다)
import 'settings.dart'; // 🆕 v1.18 — SettingsActionCall

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

/// m2-8 G-7 — 연결 관리(05 `S07`). 🆕 v1.18(01 §27 · K-r · K-t) — [lockedLabel] 추가.
/// 🔴 행 수·차례 = 엔진(«5장 고정» 아님 · `calendarEnabled == false` 면 캘린더 행 0).
@freezed
abstract class ConnectionsVm with _$ConnectionsVm {
  const factory ConnectionsVm({
    required List<ConnectionRow> rows,
    required AsOf asOf,

    /// 🆕 v1.18 — 운영 등급 생체 축소 글자(non-null = 보기만). 🔴 엔진 의무 = 이때 모든 행 `actions` 빈 ·
    /// `selectAction` 전부 null — 화면은 이 칸으로 컨트롤을 거르지 않는다(받은 대로 + 머리 글자 한 줄).
    String? lockedLabel,
  }) = _ConnectionsVm;

  factory ConnectionsVm.fromJson(Map<String, dynamic> json) =>
      _$ConnectionsVmFromJson(json);
}
// JSON 키: rows · as_of · locked_label

/// m2-8 G-7 — 연결 1행. 🆕 v1.18(K-q · K-r · K-s) — `actionAvailable` 삭제 · [detailLine] · [level] · [actions] · [channelPicker].
/// 🔴 토큰·키·전체 URL 은 어떤 칸에도 오지 않는다(PAT = 만료일만 · C-14).
@freezed
abstract class ConnectionRow with _$ConnectionRow {
  const factory ConnectionRow({
    /// `ConnectionTargetCodes` 값 — 🔴 화면 미참조(Key = 순번 · 행 찾기 0).
    required String target,
    required String label,

    /// 🔴 화면 미참조(색 근거 아님 — [level]). 사전 밖 상태 축(C-5 `_fieldsOutsideDictionary`).
    required String statusCode,
    required String statusLabel,
    required String lastOkText,

    /// 🆕 v1.18 — 한 줄 상세(부분 동기 «9개 표 중 1개 지연 — 보유현황» · GitHub 커밋 줄). null = 줄 없음.
    String? detailLine,

    /// 🆕 v1.18 — 상태 점의 유일한 근거(짝 규칙 = 01 §27 K-r · C-52 ⑤).
    required UiLevel level,

    /// 🆕 v1.18 — 엔진이 완성한 호출(«연결 테스트» · «지금 동기화» · «시험 발송»). 빈 = 버튼 부재(뷰어는 화면이 그리지 않는다).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> actions,

    /// 상세 화면 링크(`settingsCalendar` · `opsWatchdog` · `settingsCredentials`). null = 탭 부재.
    String? route,

    /// 🆕 v1.18 — 알림 채널 행에만 non-null(엔진 의무 · 화면은 `target` 으로 행을 찾지 않는다).
    NotifyChannelCard? channelPicker,
  }) = _ConnectionRow;

  factory ConnectionRow.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRowFromJson(json);
}
// JSON 키: target · label · status_code · status_label · last_ok_text · detail_line · level · actions · route · channel_picker

/// 🆕 v1.18(01 §27 · K-s · 01 §8 미결 140) — `S07` 알림 채널 선택 블록(텔레그램 / 카카오톡).
@freezed
abstract class NotifyChannelCard with _$NotifyChannelCard {
  const factory NotifyChannelCard({
    /// «받을 채널» — 엔진.
    required String label,

    /// 받은 차례 · `selected` 정확히 1(엔진 의무).
    required List<NotifyChannelOption> options,

    /// 능력 차이 고지문 — 엔진(늘 · 04 §5-5 와 같은 글자 원천).
    required String capabilityNotice,

    /// 카카오 리프레시·만료 임박 배지 — 엔진. null = 배지 부재.
    String? tokenBadgeText,

    /// «생존 신호 경보는 따로 텔레그램이나 이메일로» — 엔진(늘 · 🔴 «중복»으로 숨기지 않는다).
    required String watchdogChannelLine,
  }) = _NotifyChannelCard;

  factory NotifyChannelCard.fromJson(Map<String, dynamic> json) =>
      _$NotifyChannelCardFromJson(json);
}
// JSON 키: label · options · capability_notice · token_badge_text · watchdog_channel_line

/// 🆕 v1.18 — 채널 선택지 1개. 🔴 선택된 옵션 = [selectAction] null · 기본 선택을 화면이 정하지 않는다.
@freezed
abstract class NotifyChannelOption with _$NotifyChannelOption {
  const factory NotifyChannelOption({
    /// `NotifyChannelCodes` 값 — 🔴 화면 미참조.
    required String code,
    required String label,
    required bool selected,

    /// 엔진이 완성한 `notifyChannelSelect` 호출(`{channel}`). null = 그 선택지로 바꾸는 컨트롤 부재.
    SettingsActionCall? selectAction,
  }) = _NotifyChannelOption;

  factory NotifyChannelOption.fromJson(Map<String, dynamic> json) =>
      _$NotifyChannelOptionFromJson(json);
}
// JSON 키: code · label · selected · select_action

/// m2-8 G-8 · 🆕 v1.20 추가형(01 §29 · K14~K16 · K18 · K35) — 기기·접근 관리(05 `S06` · 폰 전용 · 운영 등급). 🔴 **리스는 읽기 전용**이다.
/// 🔴 이 폰(operator)·조회 전용 기기(viewer)는 **한 목록**([devices] · 차례 = 엔진 · 역할 = [DeviceRow.roleLabel] 글자).
/// 🔴 QR 은 결과가 아니라 이 VM 의 [pairing] 으로 온다(`ActionResult` 페이로드 칸 0 · 그리기 = 슬롯) · 이전·강등·비상 = [migrationLink] 하나.
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

    /// 🆕 v1.20 — 리스 카드 색의 유일한 근거(짝 = 엔진 · 유효 ⇒ ok · 늦음 ⇒ watch/act · 무효·대기 ⇒ blocked).
    required UiLevel leaseLevel,

    /// 🆕 v1.20 — «세대 3» 류 epoch 글자(Supabase `operator_lease.epoch` · E11k 전 null).
    String? leaseEpochText,

    /// 🆕 v1.20 — X1 기기 이전·강등·비상 복구 진입(`AppRoutes.x1Migration` · 🔒 X1 · 리스 편집 칸 0). null = 링크 부재(잠김 포함).
    LinkAction? migrationLink,

    /// 🆕 v1.20 — viewer QR 페어링 티켓 카드(발급 쪽 · 🔴 X1 이전 QR 아님 — K16). null = 카드 부재.
    PairingTicketCard? pairing,

    /// 🆕 v1.20 — 조회 전용 기기가 0대일 때만 한 줄(«연결된 조회 전용 기기가 없습니다.» · K29). null = 줄 없음.
    String? emptyLabel,

    /// 🆕 v1.20 — 운영 등급 생체 축소(non-null = 보기만). 🔴 엔진 의무 = 모든 행 `revokeAction`·`revokeConfirmText` null ·
    /// [pairing] 의 `issueAction`·`qrSlotId`·`expiresText` null · [migrationLink] null — 화면은 거르지 않는다(K35).
    String? lockedLabel,
  }) = _DeviceAccessVm;

  factory DeviceAccessVm.fromJson(Map<String, dynamic> json) =>
      _$DeviceAccessVmFromJson(json);
}
// JSON 키: devices · lease_holder_label · lease_state_label · as_of · lease_eta_text · lease_level · lease_epoch_text ·
//          migration_link · pairing · empty_label · locked_label

/// m2-8 G-8 · 🆕 v1.20 추가형 — 기기 1행. 🔴 기기 전체 식별자를 화면 문구로 만들지 않는다.
@freezed
abstract class DeviceRow with _$DeviceRow {
  const factory DeviceRow({
    /// 🔴 화면 미참조(글자·Key 0 — Key = 순번 · K10). 폐기 호출 args 는 엔진이 [revokeAction] 에 완성한다.
    required String deviceId,
    required String label,
    required String roleLabel,
    required String statusLabel,
    required String lastSeenText,

    /// 🆕 v1.20 — 행 색의 유일한 근거.
    required UiLevel level,

    /// 🆕 v1.20 — 엔진이 완성한 `deviceTokenRevoke{device_id}`(viewer 행만 · 이 폰 행·폐기된 행·잠김 = null).
    SettingsActionCall? revokeAction,

    /// 🆕 v1.20 — 펼침 확인 글자(«즉시 조회가 차단됩니다 …» · 엔진 · K18). 🔴 [revokeAction] non-null ⇔ non-null.
    String? revokeConfirmText,
  }) = _DeviceRow;

  factory DeviceRow.fromJson(Map<String, dynamic> json) =>
      _$DeviceRowFromJson(json);
}
// JSON 키: device_id · label · role_label · status_label · last_seen_text · level · revoke_action · revoke_confirm_text

/// 🆕 v1.20(01 §29 · K15 · K16) — `S06` viewer QR 페어링 티켓 카드(발급 쪽 · 스캔 = M8 `V-01` `VIEWER_QR_SCAN`).
/// 🔴 잠김 밖에서는 [issueAction] XOR [qrSlotId](티켓 없음 = 발급 버튼 · 유효 티켓 = QR 자리) · [qrSlotId] ⇔ [expiresText].
/// 🔴 페이로드·토큰 칸 0(QR 은 슬롯 위젯 안에서만 — 조립 앱 · 06 `M4-12` ⑦) · 카운트다운 0(만료 = 엔진이 카드를 닫은 새 VM).
@freezed
abstract class PairingTicketCard with _$PairingTicketCard {
  const factory PairingTicketCard({
    /// 카드 머리 한 줄 — 엔진.
    required String headline,

    /// 엔진이 완성한 `devicePairingTicketCreate{}`(«QR 만들기»). null = 버튼 부재.
    SettingsActionCall? issueAction,

    /// QR 표시 자리 이름(`SettingsSlotIds.pairingQrDisplay`). null = 자리 부재.
    String? qrSlotId,

    /// «09:15 까지 유효» — 엔진 절대 시각 글자(🔴 남은 초를 세지 않는다).
    String? expiresText,
  }) = _PairingTicketCard;

  factory PairingTicketCard.fromJson(Map<String, dynamic> json) =>
      _$PairingTicketCardFromJson(json);
}
// JSON 키: headline · issue_action · qr_slot_id · expires_text

/// m2-8 G-9 · 🆕 v1.24 교체(01 §33 · K110) — 백업·복원(05 `S09`) 화면 VM. 🔴 소비자 0 에서 바꿨다(v1.18 `SettingsHomeVm` 교체 선례) —
///    옛 칸 `lastOkText`·`statusCode`·`statusLabel`·`actionAvailable`·`sizeText`·`route` 는 **삭제**(«부재 = 목록에 없음» K-q · 뜻 불명).
/// 🔴 글자·시각·해시 = 엔진(화면은 자르기·잇기·세기 0 — `substring` 0) · 파일 경로·파일 이름·크기 칸 0(05 S09 «노출 금지») ·
///    나이 판정·임계 = 엔진(`BACKUP_STALE` 와 같은 원천 · 화면 `DateTime.now()` 0).
/// 🔴 **복원 버튼 0**(K111) — 복원 = 새 폰 X1 마법사(`R-01`) 몫 · 이 화면은 [migrationLink] 하나 · `backupRestoreStart` 화면 미호출.
/// 🔴 [runAction] null = 버튼 **부재**(모의 원장 · 스탬프 0 · 아카이브 미일치 · 잠김 · 실행 중 — 판정 = 엔진 · K133) ·
///    [lockedLabel] non-null ⇒ [runAction] null(K-t · C-58 ②).
@freezed
abstract class BackupVm with _$BackupVm {
  const factory BackupVm({
    /// «마지막 백업 11-17 21:40» — 엔진이 아카이브 나이와 스냅숏을 묶은 글자(K112 · 화면 분기 0).
    required String lastBackupText,

    /// 나이 배지(문구·임계 = 엔진). null = 배지 부재.
    String? ageBadgeText,

    /// [lastBackupText]·[ageBadgeText] 줄의 색·아이콘 근거.
    required UiLevel level,

    /// 고지 한 줄(«백업은 이 폰 안에만 있습니다 …» · 모의 «… 실전 원장에서만 …» — 엔진). null = 줄 부재.
    String? noticeText,

    /// 엔진이 완성한 `backupRunNow{}`(«지금 백업»). 🔴 null = 버튼 부재 — 화면은 그대로 `SettingsActions.run` 1회.
    SettingsActionCall? runAction,

    /// 운영 등급 생체 축소 등 «보기만» 한 줄(엔진·조립). non-null ⇒ [runAction] null.
    String? lockedLabel,

    /// 복원 지점(받은 차례 · 행 동작 0 — K111).
    required List<RestorePointRow> points,

    /// [points] 가 비었을 때의 엔진 한 줄. 🔴 [points] 빈 ⇔ non-null(C-58 ③).
    String? pointsEmptyLabel,

    /// «폰을 바꾸시나요?» + X1 기기 이전 링크(글자·목적지 = 엔진 · `x1Migration`). null = 부재(잠김 · 원천 없음).
    LinkAction? migrationLink,
    required AsOf asOf,
  }) = _BackupVm;

  factory BackupVm.fromJson(Map<String, dynamic> json) =>
      _$BackupVmFromJson(json);
}
// JSON 키: last_backup_text · age_badge_text · level · notice_text · run_action · locked_label · points · points_empty_label ·
//          migration_link · as_of

/// 🆕 v1.24(01 §33 · K110 · K111) — `S09` 복원 지점 1행(원천 = X1 스냅숏 매니페스트 목록 — 목록 함수 = 엔진 숙제 · 01 §8 미결 199).
/// 🔴 **행 동작 칸 0**(복원 = X1 마법사 · K111) · 크기·파일 이름·경로 칸 0.
@freezed
abstract class RestorePointRow with _$RestorePointRow {
  const factory RestorePointRow({
    /// 🔴 ui 미참조(Key = 받은 차례 순번 — C4r7c-4).
    required String code,

    /// 시각·장부 날 글자(엔진 · 스냅숏 이름 = 시각 + 매니페스트 `authored_date`).
    required String label,

    /// 체인 해시 앞 8자 — 🔴 **엔진이 자른다**(화면 `substring` 0 · C-58 ④ `^[0-9a-f]{8}$`).
    required String chainHashText,

    /// 검증 상태 한 줄(엔진). null = 줄 부재.
    String? stateLabel,
  }) = _RestorePointRow;

  factory RestorePointRow.fromJson(Map<String, dynamic> json) =>
      _$RestorePointRowFromJson(json);
}
// JSON 키: code · label · chain_hash_text · state_label

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

/// 🆕 v1.24(01 §33 · K113) — 진단(05 `S10`) 화면 VM = **감싸개**(원천 1 스트림 · `SettingsRepository.watchDiagnosticsScreen`).
/// 🔴 [board] = `H-01` 블록 6 과 **같은 값**(엔진 `diagnosticsOf` 하나 · 두 벌 0) · `board.asOf` 는 ui 미참조(오래됨 = [asOf]) ·
///    무결성 칸 요약 문장 = `board.headline`(카드가 따로 짓지 않는다 · K137).
/// 🔴 [lockedLabel] non-null ⇒ 두 카드 `runAction` null(C-58 ②) · [diffsLink] = 조회 링크(잠김에도 남을 수 있다 — K138).
/// 🔴 05 옛 꼴 `{SelfTestVm golden, IntegrityVm integrity}`·`blocking` 은 쓰지 않는다(01 §8 미결 128 «05 꼴» 몫 닫음 · 차단 = `DiagnosticCell.level`).
@freezed
abstract class DiagnosticsScreenVm with _$DiagnosticsScreenVm {
  const factory DiagnosticsScreenVm({
    /// 골든벡터 셀프테스트 카드(E11o 전 = «판정 보류» · `runAction` null — K114).
    required SelfTestCard golden,

    /// 무결성 자가진단 카드(`statusLabel` = «마지막 검증 …» · 실행 = 정본 자가 대조 — K115 · K137).
    required SelfTestCard integrity,

    /// 5칸 대조 보드(`DiagnosticsVm` 무변경).
    required DiagnosticsVm board,

    /// 차이 상세 링크(글자·목적지 = 엔진 · `ledgerDiffs` · 🔴 정정 마법사 링크·렌더 0 — K116). null = 부재.
    LinkAction? diffsLink,

    /// 진입 권장 배너(«앱 업데이트 후 · 기기 이전 후 · 실전 전환 직전» — 엔진). null = 부재.
    String? recommendText,

    /// 운영 등급 생체 축소 등 «보기만» 한 줄. non-null ⇒ 두 카드 `runAction` null.
    String? lockedLabel,
    required AsOf asOf,
  }) = _DiagnosticsScreenVm;

  factory DiagnosticsScreenVm.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticsScreenVmFromJson(json);
}
// JSON 키: golden · integrity · board · diffs_link · recommend_text · locked_label · as_of

/// 🆕 v1.24(01 §33 · K113 · K114 · K137) — `S10` 실행 카드 1장(골든 · 무결성 같은 꼴).
/// 🔴 총계·비율·«n/m» 은 [summaryText] 엔진 글자 안에서만(화면 상수·조립 0 · 05 §8-1) · 실패 행 칸 = 이번 판 0(E11o 뒤 추가형 · 미결 198).
/// 🔴 [runAction] null = 버튼 부재(실행기 없음 · 실행 중 · 잠김 — 판정 = 엔진) · 화면은 그대로 `SettingsActions.run` 1회.
@freezed
abstract class SelfTestCard with _$SelfTestCard {
  const factory SelfTestCard({
    /// 카드 제목(엔진 · 정적 라벨 0 — K137).
    required String title,

    /// 상태 한 줄(«골든벡터 판정 보류» · «실행 중» · «통과» · «마지막 검증 11-18 03:10» — 엔진).
    required String statusLabel,

    /// 카드 색·아이콘 근거.
    required UiLevel level,

    /// 마지막 실행 줄(엔진). null = 줄 부재.
    String? lastRunText,

    /// 요약 줄(엔진 · 총계 상수 0). null = 줄 부재.
    String? summaryText,

    /// 엔진이 완성한 `selftestGoldenRun{}` / `selftestIntegrityRun{}`. null = 버튼 부재.
    SettingsActionCall? runAction,
  }) = _SelfTestCard;

  factory SelfTestCard.fromJson(Map<String, dynamic> json) =>
      _$SelfTestCardFromJson(json);
}
// JSON 키: title · status_label · level · last_run_text · summary_text · run_action

/// 🆕 v1.24(01 §33 · K118 · 01 §8 미결 95 (b)) — M9 `S12` 12월 연간 리뷰 **목차** VM(`OpsStatusRepository.watchAnnualReview` 반환).
/// 🔴 세후·수익률·평가액·`lines`·연도 원값·창 상태 원값 칸 **0** — 타입에 없으면 나갈 수 없다(결정 8 · 01 §2-8 화이트리스트 원칙) ·
///    M7 `S7-7` 의 `AnnualReviewVm` 은 무변경(다른 타입).
/// 🔴 [entries] = 받은 차례 · M7 화면 링크만(기각 등록부 행 = HB-3 채택 전 0) · 화면이 행을 더하지 않는다 · 0 이면 행 0(K139) ·
///    [pledgeLink] = 창 OPEN 일 때만 엔진이 채운다(목적지 `m5Pledge` · 편집 = M5-8) · 화면은 달·창을 판정하지 않는다.
@freezed
abstract class AnnualReviewIndexVm with _$AnnualReviewIndexVm {
  const factory AnnualReviewIndexVm({
    /// «2026년 연간 리뷰» — 엔진(`AnnualReviewVm.yearLabel` 과 같은 말).
    required String yearLabel,

    /// 창 상태 한 줄(엔진 · 원값 칸 0).
    required String windowStateLabel,

    /// 목차 행(M7 링크 · 받은 차례).
    required List<LinkAction> entries,

    /// 서약 편집 진입(M5-8 · OPEN 때만). null = 부재.
    LinkAction? pledgeLink,
    required AsOf asOf,
  }) = _AnnualReviewIndexVm;

  factory AnnualReviewIndexVm.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewIndexVmFromJson(json);
}
// JSON 키: year_label · window_state_label · entries · pledge_link · as_of

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
