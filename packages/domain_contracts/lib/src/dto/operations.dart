// 01 §4-1 · 05 §3 S05 — M9 운용 관리 뷰모델(🆕 계약 v1.19 · 01 §28 · R6c 선행 · 발주자 위임 2026-11-14 · K2~K20).
//
// 🔴 전부 엔진(폰 로컬 VM 산출)이 완성한다 — 화면은 받은 차례·글자 그대로 그린다(정렬·세기·묶기·분기 0).
// 🔴 두 축(`mode` = RunMode · `operatingMode` = OperatingMode)은 **각각** 그린다 — 합성 라벨 0 · 토글 0(K4).
// 🔴 버튼은 엔진이 `id`·`args` 까지 완성한 [SettingsActionCall] 뿐이다(빈 목록·null = 부재 · 화면이 짓지 않는다 ·
//    화이트리스트 = `settings_actions.dart` 머리). 결과는 `ActionResult` — `handoffRoute` 가 있으면 그리로 넘기고 끝.
// 🔴 «DRY_RUN» 글자 0 · 손익 성격 글자 0(G-63 · 결정 8) · 킬스위치 칸 0(엔진 중지 ≠ 킬스위치 — 05:449).
// 🔴 `scope`·`HandoverPlan`·`contribution` 칸은 없다(K3 — P0S 범위 = 늘 null · 🔒 M5-11 · 월 납입 = 별도 화면).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'handover.dart'; // OperatingModeView
import 'onboarding.dart'; // SettingsActionCall 의 원형(freezed copyWith 가 `$OnboardingActionCopyWith` 를 본다 — ops.dart:14 선례)
import 'ops.dart'; // LiveDryRunObservationVm
import 'settings.dart'; // EngineStatusChip · SettingsActionCall

part 'operations.freezed.dart';
part 'operations.g.dart';

/// 🆕 v1.19(01 §28 · K3) — 운용 관리(05 `S05`). 칸 차례 = 화면 위 → 아래.
@freezed
abstract class OperationsVm with _$OperationsVm {
  const factory OperationsVm({
    /// 엔진 상태 칩 — `S01` 과 **같은 값**(생산 하나 · v1.18 K-o) · `promotionLabel` = 관찰 중일 때만.
    required EngineStatusChip statusChip,

    /// 모드 카드(runMode 축).
    required RunModeCard mode,

    /// 운영 방식 카드(operatingMode 축 · 🆕 v1.19 `switchActions`).
    required OperatingModeView operatingMode,

    /// 모의 체험 카드 — SIM 계열일 때만 non-null(엔진 의무 · live = null).
    SimTrialCard? trial,
    required RampBoard ramp,

    /// 잡 행 — 행 수·차례 = 엔진(잡 이름 상수 0).
    required List<JobRow> jobs,
    required EngineControl control,

    /// 엔진 버전 전환 게이트 — 대기 버전이 있을 때만 non-null.
    UpdateGateCard? updateGate,

    /// 지난 전환 요청이 M5 에서 나중에 미통과로 끝난 사유 한 줄(두 축 공용 · null = 줄 없음 · K18).
    String? lastRequestNotice,

    /// 운영 등급 생체 축소 글자(non-null = 보기만 · 🔴 엔진 의무 = 동작 칸 5 전부 비움 — K19).
    String? lockedLabel,
    required AsOf asOf,
  }) = _OperationsVm;

  factory OperationsVm.fromJson(Map<String, dynamic> json) =>
      _$OperationsVmFromJson(json);
}
// JSON 키: status_chip · mode · operating_mode · trial · ramp · jobs · control · update_gate · last_request_notice ·
//          locked_label · as_of

/// 🆕 v1.19(K5 · K6) — 모드 카드(runMode 축 칩 1).
@freezed
abstract class RunModeCard with _$RunModeCard {
  const factory RunModeCard({
    /// «모의 · 내부 가상 체결» · «실전 · 관찰 중» — 엔진(🔴 «DRY_RUN» 0 · 세 값 분기 0).
    required String label,
    required UiLevel level,

    /// hold 한 줄(`LIVE_AWAITING_KEYS` 등 · 🔴 «모의» 글자 0). null = 줄 없음.
    String? holdLabel,

    /// `live × autoTrade × dryRun` 관찰 중일 때만(엔진 #159 그대로). 🔴 화면은 `progressText`·`stateLabel` 만.
    LiveDryRunObservationVm? observation,

    /// 승격 버튼 — 관찰 중 ∧ 승격 가능일 때만(엔진 완성 `runtimeLivePromotion` · args `{}` · K6). null = 부재.
    SettingsActionCall? promotionAction,

    /// 전환 부작용 고지(«기존 계획이 무효화되고 …») — `switchActions` 가 비지 않을 때만.
    String? switchNoticeText,

    /// 전환 요청 버튼(엔진 완성 `runtimeModeSwitchRequest` · args `{run_mode}`). 빈 = 부재.
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> switchActions,
  }) = _RunModeCard;

  factory RunModeCard.fromJson(Map<String, dynamic> json) =>
      _$RunModeCardFromJson(json);
}
// JSON 키: label · level · hold_label · observation · promotion_action · switch_notice_text · switch_actions

/// 🆕 v1.19(K9 · K10 · 엔진 E15d2 `sim_trial.dart`) — 모의 체험 카드. 🔴 손익 0 · 화면은 개수·비율·잔여를 세지 않는다.
@freezed
abstract class SimTrialCard with _$SimTrialCard {
  const factory SimTrialCard({
    /// 엔진 머리말(`SimTrialReport.headline`).
    required String headline,

    /// 요약 카운터 문장(`SimTrialCounters.text` — «체험 N일 · 배치 n회 · 리밸런싱 r회 · 경보 k건 · 개입 m회»).
    required String summaryText,

    /// 체험 완료 기준 줄 — 차례·항목 수 = 엔진(정본 04 §9-5 · 1개 이상).
    required List<SimTrialCheck> checks,
  }) = _SimTrialCard;

  factory SimTrialCard.fromJson(Map<String, dynamic> json) =>
      _$SimTrialCardFromJson(json);
}
// JSON 키: headline · summary_text · checks

/// 🆕 v1.19(K9) — 체험 완료 기준 1줄. 🔴 `GateState` 아님 · `OnboardingFinishCheck`(X3 배관 점검) 아님.
/// 짝(엔진 의무 · C-53 ⑨): PASSED·AUTO_PASSED ⇒ ok · OPEN ⇒ watch · OPEN_WARN ⇒ info(🔴 act·blocked 0).
@freezed
abstract class SimTrialCheck with _$SimTrialCheck {
  const factory SimTrialCheck({
    /// `SimTrialItemCodes` 값 — 🔴 화면 미참조(Key = 순번).
    required String itemCode,

    /// 항목 이름(엔진 `SimTrialItem.label`).
    required String label,

    /// 진척·사유 문장(엔진 `SimTrialItemResult.detail`).
    required String detailText,

    /// `SimTrialItemStateCodes` 값 — 🔴 화면 미참조(엔진 4값 와이어).
    required String itemState,

    /// «통과» · «자동 통과» · «아직» · «아직 — 경고 후 진행» — 엔진.
    required String stateLabel,

    /// 🔴 아이콘·색의 유일한 근거.
    required UiLevel level,
  }) = _SimTrialCheck;

  factory SimTrialCheck.fromJson(Map<String, dynamic> json) =>
      _$SimTrialCheckFromJson(json);
}
// JSON 키: item_code · label · detail_text · item_state · state_label · level

/// 🆕 v1.19(K11) — 운영 램프 보드(OpsRamp). 🔴 레벨 열거 미사용(`levelLabel` 글자만) · 성과 조건 0.
@freezed
abstract class RampBoard with _$RampBoard {
  const factory RampBoard({
    /// «L1 · 5% · 최저 단계» — 엔진(발행 집합 L1~L5).
    required String levelLabel,
    required UiLevel level,

    /// 승급 조건 현황(받은 차례). 빈 ⇔ [emptyLabel] non-null.
    @Default(<RampCondition>[]) List<RampCondition> conditions,

    /// 조건 줄이 없는 까닭(«모의 계좌에서는 승급 조건을 세지 않습니다 …»).
    String? emptyLabel,

    /// DST 주간 1단계 하향 표식 — 🔴 주문 차단이 아니다(non-null ⇒ [level] ∉ {act, blocked}).
    String? dstNoticeText,
  }) = _RampBoard;

  factory RampBoard.fromJson(Map<String, dynamic> json) =>
      _$RampBoardFromJson(json);
}
// JSON 키: level_label · level · conditions · empty_label · dst_notice_text

/// 🆕 v1.19(K11) — 승급 조건 1줄(03 §9-3 «배관» 항목). 🔴 [level] ∈ {ok, info, watch}.
@freezed
abstract class RampCondition with _$RampCondition {
  const factory RampCondition({
    required String label,

    /// «충족» · «집계 중 — 기록 2건» — 엔진(🔴 화면이 n/m 을 조립하지 않는다).
    required String progressText,
    required UiLevel level,
  }) = _RampCondition;

  factory RampCondition.fromJson(Map<String, dynamic> json) =>
      _$RampConditionFromJson(json);
}
// JSON 키: label · progress_text · level

/// 🆕 v1.19(K12) — 잡 1행(성공 · 지연 · 실패 3분법 + 휴장 · 아직).
/// 짝(엔진 의무 · C-53 ⑩): SUCCESS ⇒ ok · LATE ⇒ watch · HOLIDAY ⇒ info · NONE ⇒ info · FAILED ⇒ act·blocked.
@freezed
abstract class JobRow with _$JobRow {
  const factory JobRow({
    /// «국내 주문» — 엔진(🔴 잡 이름 상수 0).
    required String label,

    /// «평일 09:10 · 유예 1시간» — 엔진.
    required String scheduleText,

    /// «오늘 10:31 끝남» — 엔진.
    required String lastRunText,

    /// `SUCCESS`·`LATE`·`FAILED`·`HOLIDAY`(엔진 `job_run.status`) · `NONE`(아직 회차 없음) — 🔴 화면 미참조.
    required String statusCode,

    /// «지연 — 성공» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 한 줄 상세(«유예를 21분 넘겨 끝났습니다 …»). null = 줄 없음.
    String? detailLine,
  }) = _JobRow;

  factory JobRow.fromJson(Map<String, dynamic> json) => _$JobRowFromJson(json);
}
// JSON 키: label · schedule_text · last_run_text · status_code · state_label · level · detail_line

/// 🆕 v1.19(K13) — 엔진 시작·중지. 🔴 킬스위치가 아니다(칸 0 · 다른 색·자리).
/// 잠김 밖 = [startAction] non-null xor [stopActions] 비지 않음 · [stopActions] 비지 않음 ⇔ [stopPromptText] non-null.
@freezed
abstract class EngineControl with _$EngineControl {
  const factory EngineControl({
    /// «돌고 있음 — 다음 잡: …» · «멈춤 — … 계획 점검으로 멈췄습니다» — 엔진.
    required String stateLabel,
    required UiLevel level,

    /// 엔진 완성 `runtimeEngineStart`(args `{}`) — 멈춰 있을 때만.
    SettingsActionCall? startAction,

    /// 사유 고르기 머리말 — [stopActions] 가 비지 않을 때만.
    String? stopPromptText,

    /// 사유마다 1 — 엔진 완성 `runtimeEngineStop`(args `{reason_code}` 서로 다름 · 라벨 = 사유 글자).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> stopActions,
  }) = _EngineControl;

  factory EngineControl.fromJson(Map<String, dynamic> json) =>
      _$EngineControlFromJson(json);
}
// JSON 키: state_label · level · start_action · stop_prompt_text · stop_actions

/// 🆕 v1.19(K17) — 엔진 버전 전환 게이트. 🔴 «지금 업데이트» 강행 칸 없음(구조로 막는다).
@freezed
abstract class UpdateGateCard with _$UpdateGateCard {
  const factory UpdateGateCard({
    /// «새 버전 대기 — 비거래 시간대에 바꿉니다» — 엔진.
    required String stateLabel,
    required String bodyText,
    required UiLevel level,
  }) = _UpdateGateCard;

  factory UpdateGateCard.fromJson(Map<String, dynamic> json) =>
      _$UpdateGateCardFromJson(json);
}
// JSON 키: state_label · body_text · level
