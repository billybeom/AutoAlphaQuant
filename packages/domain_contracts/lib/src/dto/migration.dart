// 🆕 계약 v1.33(01 §42 · K264~K281 · E16j-b) — X1 기기 이전 화면(`X1-2`~`X1-6` · 🔒 `ui_safety`) VM.
//
// 옛 폰 계획 마법사(`x1Migration`) = [X1PlanWizardVm] · 새 폰 받기(`x1MigrationPlan`) · 새 폰 비상 복구(`x1MigrationEmergency`) =
// [X1RecoveryVm](같은 꼴 · 엔진이 갈래를 고른다). 창구 = `MigrationRepository`(폰 전용 · 라우트 인자 0 — 한 기기 한 이전 · 엔진이 마지막 run 을 안다).
// 🔴 문장 · 라벨 · 시각 · 해시 글자 = 엔진 · `code`/`reasonCode`/`blockCode`/`gateStateCode` 칸 = 화면 미참조(표본 · 사전 검사용) · 색 = `level` 하나.
// 🔴 동작 = 엔진이 완성한 `SafetyActionCall`(그대로 `SafetyActions.run` · args 의 `run_id` = 엔진) — 화면은 id · args 를 짓지 않는다.
// 🔴 발주자 수치(관찰 일수 · 넘김 시간 · 펜싱 마진 · 재생성 상한 · 티켓 TTL) = 엔진 글자로만(칸 0) · 카운트다운 0(절대 시각 글자).
// 🔴 시크릿(복구 코드 · 재발급 키 값) = 슬롯 ↔ 구현 사이만(동작 args 0 · v1.31 `supabaseSignIn` 선례) · 기기 id 원문 · sha256 전체 0.
// 🔴 VM 생산 · 단계 진행기 · 저장(REVOKED · 재발급) · 백업 바이트 원천 = 엔진 · 조립 숙제(01 §8 미결 218) — 그 전에는 엔진이 이 VM 을 내지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'incident.dart'; // EmergencyCardVm

part 'migration.freezed.dart';
part 'migration.g.dart';

/// 옛 폰 계획 교체 마법사(`x1Migration` · 06 X1-2 · 08 그림 9-1).
///
/// 🔴 시작 전 = [d03Card] 한 장(건너뛰기 0) + [startAction] «봤습니다 — 이전 시작» · 그때 [rows] 빈 목록.
/// 🔴 [lockedLabel] · [doneLabel] 가 non-null 이면 동작 0([startAction] · 행 동작) · 슬롯 0.
@freezed
abstract class X1PlanWizardVm with _$X1PlanWizardVm {
  const factory X1PlanWizardVm({
    /// 머리 문장(시작 전 · 단계 · 강등 뒤 · 끝) — 엔진.
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1StartResultCodes` ∪ `X1StepBlockCodes` ∪ `X1JournalResultCodes` ∪ `X1BootRefusalCodes` ∪ 공용.
    String? reasonCode,

    /// `D-03` 긴급정지 카드 한 장(기존 VM 재사용) — 시작 전만.
    EmergencyCardVm? d03Card,

    /// 엔진이 완성한 `x1PlanStart{}` — [d03Card] non-null ⇔ non-null(잠김 · 거부 제외).
    SafetyActionCall? startAction,

    /// 단계 9(`X1StepCodes.ordered` 차례) 또는 빈 목록(시작 전 · 거부).
    required List<X1StepRow> rows,

    /// 감시 유지보수 창 글자(열림 시각 · 넘김 — 엔진 글자 · 시간 칸 0).
    String? windowText,

    /// 보내지 않은 기록 · 초안 · 유예 경고 줄(D18 · D6) — 엔진(원천 = 미결 218 ⓐ).
    required List<String> warningLines,

    /// 티켓 QR 카드 — `TICKET_ISSUED` 뒤만.
    X1TicketCard? ticket,

    /// 끝난 뒤 문장. non-null ⇒ 동작 0.
    String? doneLabel,

    /// 생체 · 리스 · 뷰어 잠김. non-null ⇒ 동작 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _X1PlanWizardVm;

  factory X1PlanWizardVm.fromJson(Map<String, dynamic> json) =>
      _$X1PlanWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · d03_card · start_action · rows · window_text · warning_lines · ticket · done_label ·
//          locked_label · as_of

/// 단계 한 행 — 옛 폰 9 · 새 폰 5 공용.
@freezed
abstract class X1StepRow with _$X1StepRow {
  const factory X1StepRow({
    /// 🔴 화면 미참조 — ∈ `X1StepCodes` ∪ `X1RecoveryStepCodes`.
    required String code,
    required String title,

    /// 상태 글자(원천 = 저널 `X1StepStateCodes`) — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 막힘 이유 · DEMOTED «여기부터 되돌릴 수 없음» · 갭 위반 줄 — 엔진.
    required List<String> lines,

    /// 🔴 화면 미참조 — ∈ `X1StepBlockCodes` ∪ `X1GapViolationCodes` ∪ `X1GateReasonCodes`.
    String? blockCode,

    /// 엔진 완성 — 옛 폰 `x1PlanStep{run_id, step}` · `x1PlanAbort{run_id, step}`(DEMOTED 앞만) · 새 폰 `x1RecoveryStep{run_id, step}`.
    required List<SafetyActionCall> actions,
  }) = _X1StepRow;

  factory X1StepRow.fromJson(Map<String, dynamic> json) =>
      _$X1StepRowFromJson(json);
}
// JSON 키: code · title · state_label · level · lines · block_code · actions

/// 이전 티켓 QR 카드(옛 폰 · 강등 뒤). 🔴 페이로드 칸 0 — QR 은 슬롯 위젯이 구현에서 받아 그린다(`PairingTicketCard` 꼴).
@freezed
abstract class X1TicketCard with _$X1TicketCard {
  const factory X1TicketCard({
    required String headline,

    /// QR 표시 자리 이름(`X1SlotIds.ticketQrDisplay`). null = 자리 부재.
    String? ticketSlotId,

    /// «09:15 까지 유효» — 엔진 절대 시각 글자(🔴 남은 초를 세지 않는다).
    String? expiresText,

    /// 백업 날 · 체인 8자 등 — 엔진.
    required List<String> lines,
  }) = _X1TicketCard;

  factory X1TicketCard.fromJson(Map<String, dynamic> json) =>
      _$X1TicketCardFromJson(json);
}
// JSON 키: headline · ticket_slot_id · expires_text · lines

/// 새 폰 복구(받기 · 비상 공용 · 06 X1-3~X1-5 · 08 그림 9-2).
///
/// 🔴 받기 = [scanSlotId] · [startAction] null · [reissue] 빈 목록 / 비상 = [startAction] `x1EmergencyStart{}` · [recoveryCodeSlotId] ·
///    [fencing] · [reissue] 6행.
/// 🔴 [lockedLabel] · [doneLabel] 가 non-null 이면 동작 0 · 슬롯 0. [restartLink] non-null ⇔ `X1_RECOVERY_FULL`(그때 동작 0).
@freezed
abstract class X1RecoveryVm with _$X1RecoveryVm {
  const factory X1RecoveryVm({
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1RecoveryResultCodes` ∪ `X1RestoreResultCodes` ∪ `BackupResultCodes` ∪ `X1OrderSealCodes` ∪
    ///    `X1FencingResultCodes` ∪ `X1ReissueResultCodes` ∪ `X1StartResultCodes` ∪ `X1GateReasonCodes` ∪ 공용.
    String? reasonCode,

    /// «계획 이전» · «비상 이전» — 엔진.
    required String kindLabel,

    /// 비상 = 엔진 완성 `x1EmergencyStart{}`(선언 결정 + 복구 코드 슬롯 → epoch+1 = 구현) · 받기 = null.
    SafetyActionCall? startAction,

    /// 복구 코드 입력 자리(`X1SlotIds.recoveryCode` · 비상 시작 전만).
    String? recoveryCodeSlotId,

    /// 펜싱 대기(비상만).
    X1FencingCard? fencing,

    /// 재발급 6행(`X1ReissueItemCodes.ordered` 차례 · 비상만) 또는 빈 목록.
    required List<X1ReissueRow> reissue,

    /// 티켓 QR 스캔 자리(`X1SlotIds.ticketQrScan` · 받기 시작 전만).
    String? scanSlotId,

    /// 복원 판정 카드.
    X1RestoreCard? restore,

    /// 복구 단계 5(`X1RecoveryStepCodes.ordered` 차례) 또는 빈 목록.
    required List<X1StepRow> steps,

    /// LIVE 재개 게이트(GAP_REBUILT 뒤).
    X1GateCard? gate,

    /// RECOVERY_FULL → `onboardingRestart`(잔고 승계 새 시작 · 엔진 완성).
    LinkAction? restartLink,

    /// 감시 창 글자 — 엔진.
    String? windowText,

    /// «정정 · 재발급은 되돌리지 않습니다» 류 — 엔진.
    String? noticeText,
    String? doneLabel,
    String? lockedLabel,
    required AsOf asOf,
  }) = _X1RecoveryVm;

  factory X1RecoveryVm.fromJson(Map<String, dynamic> json) =>
      _$X1RecoveryVmFromJson(json);
}
// JSON 키: headline · level · reason_code · kind_label · start_action · recovery_code_slot_id · fencing · reissue · scan_slot_id ·
//          restore · steps · gate · restart_link · window_text · notice_text · done_label · locked_label · as_of

/// 펜싱 대기 카드(비상 · 옛 리스 만료까지).
@freezed
abstract class X1FencingCard with _$X1FencingCard {
  const factory X1FencingCard({
    required String headline,
    required UiLevel level,

    /// 대기 끝 절대 시각 글자(«11-22 09:15 부터») — 엔진(🔴 카운트다운 0 · 마진 칸 0).
    String? endsAtText,

    /// 🔴 화면 미참조 — ∈ `X1FencingResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`.
    String? code,
    required List<String> lines,
  }) = _X1FencingCard;

  factory X1FencingCard.fromJson(Map<String, dynamic> json) =>
      _$X1FencingCardFromJson(json);
}
// JSON 키: headline · level · ends_at_text · code · lines

/// 재발급 체크리스트 한 행(비상).
@freezed
abstract class X1ReissueRow with _$X1ReissueRow {
  const factory X1ReissueRow({
    /// 🔴 화면 미참조 — ∈ `X1ReissueItemCodes`.
    required String code,

    /// 항목 이름 — 엔진(`ReissueItem.label`).
    required String label,

    /// «받음» · «남음» · «해당 없음» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 새 값 입력 자리(`X1SlotIds.reissueSecret` · 시크릿 항목만). null = 자리 부재.
    String? reissueSlotId,

    /// 엔진 완성 `x1ReissueRecord{run_id, item}` — 값 = 슬롯 ↔ 구현 · 지문만 엔진. null = 끝 · 해당 없음.
    SafetyActionCall? recordAction,
  }) = _X1ReissueRow;

  factory X1ReissueRow.fromJson(Map<String, dynamic> json) =>
      _$X1ReissueRowFromJson(json);
}
// JSON 키: code · label · state_label · level · reissue_slot_id · record_action

/// 복원 판정 카드(매니페스트 요약 · 거부 사유).
@freezed
abstract class X1RestoreCard with _$X1RestoreCard {
  const factory X1RestoreCard({
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1RestoreResultCodes` ∪ `BackupResultCodes`.
    String? code,

    /// 매니페스트 날 · 스키마 · 해시 판 · epoch + 판정 사유 — 엔진 문장(🔴 sha256 전체 · 기기 id 0).
    required List<String> lines,

    /// 체인 해시 8자 — 엔진이 자른다(`RestorePointRow.chainHashText` 선례).
    String? chainHashText,
  }) = _X1RestoreCard;

  factory X1RestoreCard.fromJson(Map<String, dynamic> json) =>
      _$X1RestoreCardFromJson(json);
}
// JSON 키: headline · level · code · lines · chain_hash_text

/// LIVE 재개 게이트 카드(`X1-5` · 녹/황/적 · 왜 막혔는지 + 지금 할 조치).
@freezed
abstract class X1GateCard with _$X1GateCard {
  const factory X1GateCard({
    required String stateLabel,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `X1GateStateCodes`.
    required String gateStateCode,

    /// 🔴 화면 미참조 — ∈ `X1GateReasonCodes`.
    String? code,

    /// 관찰 «n/m 거래일» — 엔진 글자(🔴 일수 칸 0).
    String? observeText,
    required String whyLine,
    String? actionLine,

    /// 확인 항목 — 엔진(문안 = 발주자 · 원천 = 미결 218 ⓗ).
    required List<String> checklistLines,
  }) = _X1GateCard;

  factory X1GateCard.fromJson(Map<String, dynamic> json) =>
      _$X1GateCardFromJson(json);
}
// JSON 키: state_label · level · gate_state_code · code · observe_text · why_line · action_line · checklist_lines
