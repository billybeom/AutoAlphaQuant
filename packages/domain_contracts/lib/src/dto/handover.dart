// 01 §2-11 — X7 운영 방식 표시와 전환 위저드(`M5-10` 게이트 · `M5-11` 위저드).
//
// 🔴 `OperatingMode` 전환은 `CommandApi` 에 없다 — `SettingsActions` 의
//    `runtimeOperatingModeSwitchRequest` 1종이며 반환 `handoffRoute` 로 위저드에
//    넘긴다(01 §4-3).
// 🔴 엔진의 어떤 안전 강등도 `OperatingMode` 를 건드리지 않는다(§10-1 · C-20).
// 🔒 전환 위저드는 M5 소유 화면이다 — 다른 화면은 읽을 수는 있으나 렌더하지 않는다.
// 🆕 v1.19(01 §28 · K8) — `S05` 는 `OperationsVm.operatingMode` 로 이 타입을 받는다(창구 = `SettingsRepository.watchOperations`) ·
//    전환 버튼 = [OperatingModeView.switchActions].
// 🆕 v1.26(01 §35 · K167~K175) — `M5-11` simToAuto 위저드 한 화면 [HandoverWizardVm] · 단계 행 [HandoverWizardStepRow]
//    (창구 = `HandoverRepository.watchWizard()` · `handoverStatus` = 같은 본문 · 🔒 `ui_safety`) · [HandoverPlan]·[HandoverStep] 무변경.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/mode.dart';
import '../enums/sleeve.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart';
import 'ledger_trust.dart';
import 'operations.dart'; // 🆕 v1.26 — SimTrialCard(S1 상세 · K171)
import 'settings.dart'; // 🆕 v1.19 — SettingsActionCall

part 'handover.freezed.dart';
part 'handover.g.dart';

/// 01 §2-11 — M9 `S05` 표시(지금 운영 방식 · `current` 늘 값). 🆕 v1.16(01 §25 · K12) — `O-00b` 는
/// 이 타입을 읽지 않는다(`OnboardingModeChoiceVm` — «아직 안 고름» = `selected` null) · 카드 1장 =
/// **같은 타입** [OperatingModeOption](S05·O-00b 공용).
@freezed
abstract class OperatingModeView with _$OperatingModeView {
  const factory OperatingModeView({
    required OperatingMode current,

    /// "투자 안내(수동 매매)" — 엔진 생성.
    required String label,
    required String explainLine,

    /// S05 의 카드 묶음(🔵 v1.16 — O-00b 는 `OnboardingModeChoiceVm.options`) — 🔴 **기본 선택 없음**
    /// («온보딩 미완»은 «자동 매매»가 아니다 · G-02).
    required List<OperatingModeOption> options,
    required LedgerTrustBadge trust,

    /// 전환 사전 점검 결과.
    required List<GateBadge> switchGates,

    /// 🆕 v1.19(01 §28 · K8) — `S05` 운영 방식 전환 요청 버튼(엔진 완성 `runtimeOperatingModeSwitchRequest` ·
    /// args `{operating_mode}` · 값 ≠ [current]). 빈 = 부재 · 🔴 [options] 카드에 버튼을 붙이지 않는다(O-00b 공용 · 기본 선택 0).
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> switchActions,
  }) = _OperatingModeView;

  factory OperatingModeView.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeViewFromJson(json);
}
// JSON 키: current · label · explain_line · options · trust · switch_gates · switch_actions

/// 01 §2-11 — 선택 카드 1장. 🔴 전부 엔진 문구다.
@freezed
abstract class OperatingModeOption with _$OperatingModeOption {
  const factory OperatingModeOption({
    required OperatingMode mode,
    required String title,
    required String body,
    required String prepLine,
    required String honestyLine,
  }) = _OperatingModeOption;

  factory OperatingModeOption.fromJson(Map<String, dynamic> json) =>
      _$OperatingModeOptionFromJson(json);
}

/// 01 §2-11 — 전환 계획(`M5-11`).
/// 🔴 B13 — `asOf` 는 스냅샷 신선도다. 낡으면 커밋 직전에 되돌린다.
@freezed
abstract class HandoverPlan with _$HandoverPlan {
  const factory HandoverPlan({
    required HandoverPath path,
    required String pathLabel,
    required List<HandoverStep> steps,
    required List<AdoptionPreviewRow> adoptionPreview,
    required AsOf asOf,

    /// 🔴 B12 — **엔진이 갈래를 판정한다**(사고 대응 / 자발적 전환).
    ///    화면은 준 갈래만 표시하고 자체 판정하지 않는다.
    String? handbackBranch,
    String? branchReasonLabel,
  }) = _HandoverPlan;

  factory HandoverPlan.fromJson(Map<String, dynamic> json) =>
      _$HandoverPlanFromJson(json);
}

/// 01 §2-11 — 전환 단계 1행(`OnboardingStep`·`UnknownResolutionStep` 과 같은 모양).
@freezed
abstract class HandoverStep with _$HandoverStep {
  const factory HandoverStep({
    required String stepId,
    required int order,
    required String title,
    required String whyLine,
    required GateState state,
    required String stateLabel,
    String? blockedReasonCode,
  }) = _HandoverStep;

  factory HandoverStep.fromJson(Map<String, dynamic> json) =>
      _$HandoverStepFromJson(json);
}

/// 01 §2-11 — 편입 미리보기 1행.
/// 🔴 G-03 — `disposition` 은 엔진이 준 **현재** 처분(`'ADOPT'`|`'EXTERNAL'`)이며,
///    바꿀 때는 `handoverAdoptionSet` 를 호출한 뒤 **되돌아온 값**을 다시 그린다
///    (낙관 갱신 금지 — 커밋 전 상태를 화면이 소유하지 않는다).
@freezed
abstract class AdoptionPreviewRow with _$AdoptionPreviewRow {
  const factory AdoptionPreviewRow({
    required String symbol,
    required String symbolLabel,
    required int quantity,
    required SleeveId sleeve,

    /// 🔴 처분 제출의 대상 식별자. 티커 문자열로 지목하면 같은 종목이 두 계좌에
    ///    있을 때 조용히 한쪽만 반영된다.
    required String adoptionId,
    required String disposition,

    /// "편입" / "제외(시스템 밖 자산)" — 엔진 생성.
    required String dispositionLabel,
  }) = _AdoptionPreviewRow;

  factory AdoptionPreviewRow.fromJson(Map<String, dynamic> json) =>
      _$AdoptionPreviewRowFromJson(json);
}

/// 🆕 v1.26(01 §35 · K168) — `M5-11` simToAuto 위저드 한 화면(`AppRoutes.m5HandoverWizard` · `handoverStatus` 같은 본문 — K173).
/// 🔴 머리·단계·시각 글자 = 엔진(`judgeSimToAuto` · `simToAutoPlan` 감싸기) · 화면은 분기 0 · 카운트다운 0(시각이 지나면 새 VM).
/// 🔴 1.26.0 = `HandoverPath.simToAuto` 하나(다른 경로 = 추가형 나중).
/// 🔴 불변식(C-60 ②~⑥) — [rows] 길이 ∈ {0, 7}(0 ⇔ 전제 밖) · 7 이면 `step.stepId` 차례 = `SimToAutoStepIds.ordered` ·
///    [lockedLabel] 또는 [doneLabel] non-null ⇒ 모든 행 `actions` 빈 목록.
@freezed
abstract class HandoverWizardVm with _$HandoverWizardVm {
  const factory HandoverWizardVm({
    /// 판정 머리(엔진 `SimToAutoReport.headline` · 전제 밖 = 엔진 전제 문장).
    required String headline,

    /// 머리 색(엔진 짝 — 확정 가능 = OK · 막힘 = BLOCKED · 냉각·시각 모름 = WATCH · 진행 중 = INFO).
    required UiLevel level,

    /// 🔴 화면 미참조(시험·로그) — 엔진 `SimToAutoReport.code`(∈ `SimToAutoResultCodes`) · null = 막힘 0.
    String? reasonCode,

    /// 경로 글자(엔진 · «모의투자 → 실전 자동 매매(관찰부터)»).
    required String pathLabel,

    /// 7단계(엔진 차례 = `SimToAutoStepIds.ordered`) · 🔴 전제 밖 = 0.
    @Default(<HandoverWizardStepRow>[]) List<HandoverWizardStepRow> rows,

    /// S1 상세(체험 5항목 · 04 :1222 같은 그릇 · K171). null = 부재.
    SimTrialCard? trial,

    /// 냉각 끝 글자(엔진 · 세션 열린 뒤만). null = 부재.
    String? coolingText,

    /// 확정 기한 글자(엔진 · 세션 열린 뒤만). null = 부재.
    String? deadlineText,

    /// 커밋 창 글자(엔진 `SimToAutoCommitWindow.label` — 허용 때도 · K170). null = 부재.
    String? windowText,

    /// 고지 한 줄(엔진 · 예: 경고 후 진행 · 승인 config 없음). null = 부재.
    String? noticeText,

    /// 확정됨 상태 문장(엔진 · non-null ⇔ 확정 뒤 — 그때 `rows` 는 그대로 · 동작 0 · K175).
    String? doneLabel,

    /// 잠김(운영 등급 생체 · 다른 기기 리스 — 01 §8 미결 169) · non-null ⇒ 모든 행 `actions` 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _HandoverWizardVm;

  factory HandoverWizardVm.fromJson(Map<String, dynamic> json) =>
      _$HandoverWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · path_label · rows · trial · cooling_text · deadline_text · window_text ·
//          notice_text · done_label · locked_label · as_of

/// 🆕 v1.26(01 §35 · K168 · K169 · K172) — 위저드 한 단계(기존 [HandoverStep] 무변경 감싸기).
/// 🔴 단계별 허용 동작(K169 · C-60 ③) — S2 ⊆ {`selftestGoldenRun`} · S5 ⊆ {`handoverSimLedgerFate`} ·
///    S6 ⊆ {`handoverSessionStart`} · S7 ⊆ {`handoverSessionCancel`, `handoverCommit`} · 그 밖 단계 = 0 ·
///    세션 id = 엔진이 `handover_session_id` args 에 넣는다(화면 읽기 0) · `handoverCommit` = S7 PASS 일 때만.
@freezed
abstract class HandoverWizardStepRow with _$HandoverWizardStepRow {
  const factory HandoverWizardStepRow({
    /// 엔진 `simToAutoPlan` 단계 그대로(제목 · 왜 · 상태 · 상태 글자 · 막힘 코드).
    required HandoverStep step,

    /// 🔴 색의 유일한 근거(K172) — `step.state` 가 UNKNOWN 이어도 «아직»은 INFO · 시각 모름 = WATCH.
    required UiLevel level,

    /// 다른 화면으로(엔진 · S2 → `settingsDiagnostics` · S3 → `settingsCredentials` · S4 → `settingsAccounts`). null = 이동 0.
    LinkAction? link,

    /// 단계 안 엔진 완성 호출(`SettingsActions.run` · 허용 id = 위 표). 빈 목록 = 버튼 0.
    @Default(<SettingsActionCall>[]) List<SettingsActionCall> actions,
  }) = _HandoverWizardStepRow;

  factory HandoverWizardStepRow.fromJson(Map<String, dynamic> json) =>
      _$HandoverWizardStepRowFromJson(json);
}
// JSON 키: step · level · link · actions
