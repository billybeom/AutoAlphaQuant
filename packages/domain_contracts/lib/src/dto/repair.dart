// 🆕 계약 v1.32(01 §41 · K247~K263 · E16j-a) — X5 정정 마법사(`X5-3` · 🔒 `ui_safety`) 한 화면.
//
// 허브(`x5RepairWizard` · 열린 대상 고르기)와 대상 화면(`x5RepairTarget/:targetId` · 시작 → 원인 → 마찰 1~5 → 실행 / 아무것도 안 하기)이
// 같은 VM 을 쓴다(창구 = `RepairWizardRepository.watchRepair({targetId})` · 폰 전용).
// 🔴 문장 · 라벨 · 시각 글자 = 엔진 · `code`/`reasonCode` 칸 = 화면 미참조(표본 · 사전 검사용) · 색 = `level` 하나.
// 🔴 동작 = 엔진이 완성한 `SafetyActionCall`(그대로 `SafetyActions.run`) 또는 제출 DTO(`runRepairCorrect` · `runRepairBaseline` ·
//    `runInterventionJournal`) — 화면은 id · args 를 짓지 않는다.
// 🔴 발주자 수치(냉각 24h · 정정 체인 상한 · 실행 창) = 엔진 글자로만(칸 0) · 정정은 되돌리지 않는다(정정의 정정만 · 엔진 문장).
// 🔴 정정 커밋 ↔ 개입 세션 5단계 결속 · 체결 후보 목록 · 직전 재대사 = 엔진 숙제(01 §8 미결 217) — 그 전에는 엔진이 이 VM 을 내지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'ledger.dart'; // LedgerDiffRow

part 'repair.freezed.dart';
part 'repair.g.dart';

/// X5 정정 마법사 한 화면(허브 · 대상 공용).
///
/// 🔴 허브 = [targetLinks] 비지 않음 · 그때 [diff] · [stages] · [origins] · 동작 0.
/// 🔴 [lockedLabel] · [doneLabel] · [x1GuideLink] 가 non-null 이면 동작 0([doNothingAction] · [correction] · [baselineLabel] · [stages] 의 동작).
/// 🔴 [correction](정본 정정 · diff 갈래)과 [baselineLabel](새 기준점 · 무결성 갈래)은 동시에 non-null 이 아니다.
@freezed
abstract class RepairWizardVm with _$RepairWizardVm {
  const factory RepairWizardVm({
    /// 허브 문장 · diff 요약 · 경계 문장 — 엔진.
    required String headline,
    required UiLevel level,

    /// 🔴 화면 미참조 — ∈ `LedgerBoundaryReasonCodes` ∪ `RepairResultCodes` ∪ `BaselineResultCodes` ∪ `BaselineApplyResultCodes`.
    String? reasonCode,

    /// 허브만 — 열린 대상마다 하나(→ `x5RepairTarget` · 엔진이 인자를 완성). 대상 화면 = 빈 목록.
    required List<LinkAction> targetLinks,

    /// 탐지 시점 근거(L-1 행 재사용 · 🔴 그 안의 `actionLink` = null). 무결성 갈래 · 허브 = null.
    LedgerDiffRow? diff,

    /// 대상 요약 — 무결성 첫 어긋난 날 · 사유 · 대상 체결 요약(엔진 글자).
    required List<String> targetLines,

    /// 처음 고른 칸이 «아무것도 안 하기»인가(FILL_LAG · 현금 축 — 엔진 `defaultRepairChoiceOf`). 🔴 글자를 고르는 데 쓰지 않는다.
    required bool doNothingDefault,

    /// 고를 수 있는 원인 — 정정 = 쌍 쓰기 목록 · 새 기준점 = 3종 ∩ 경계 후보(엔진). 🔴 자유 서술 0.
    required List<RepairOriginChoice> origins,

    /// 마찰 1~5(개입 세션 · 길이 ∈ {0, 5}).
    required List<RepairStageRow> stages,

    /// 아무것도 안 하기(`repairAccept{diff_id}` · 엔진 완성). 무결성 갈래 · 허브 = null.
    SafetyActionCall? doNothingAction,

    /// 정본 정정 폼 — non-null ⇔ 5단계 실행 가능(diff 갈래). 제출 = `runRepairCorrect`.
    RepairCorrectionForm? correction,

    /// 새 기준점 버튼 글자 — non-null ⇔ 실행 가능(무결성 갈래). 제출 = `runRepairBaseline`.
    String? baselineLabel,

    /// «정정은 되돌리지 않습니다 — 정정의 정정만» 류 — 엔진.
    String? noticeText,

    /// 끝난 뒤 문장. non-null ⇒ 동작 0.
    String? doneLabel,

    /// 정정 이력(→ `ledgerRepairs`).
    LinkAction? historyLink,

    /// 경계 X1(원장을 믿을 수 없음 → `x1MigrationEmergency`). non-null ⇒ 동작 0.
    LinkAction? x1GuideLink,

    /// 생체 · 리스 · 뷰어 잠김 — non-null ⇒ 동작 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _RepairWizardVm;

  factory RepairWizardVm.fromJson(Map<String, dynamic> json) =>
      _$RepairWizardVmFromJson(json);
}
// JSON 키: headline · level · reason_code · target_links · diff · target_lines · do_nothing_default · origins · stages ·
//          do_nothing_action · correction · baseline_label · notice_text · done_label · history_link · x1_guide_link ·
//          locked_label · as_of

/// 원인 한 칸(`ReconOriginChoice` 와 같은 꼴 · 정정 · 새 기준점 공용).
@freezed
abstract class RepairOriginChoice with _$RepairOriginChoice {
  const factory RepairOriginChoice({
    /// ∈ `OriginCodes` — 제출 DTO 의 `originCode` 로 그대로.
    required String originCode,

    /// 칩 글자 — 엔진.
    required String label,
  }) = _RepairOriginChoice;

  factory RepairOriginChoice.fromJson(Map<String, dynamic> json) =>
      _$RepairOriginChoiceFromJson(json);
}
// JSON 키: origin_code · label

/// 마찰 한 단계(개입 세션 재사용 — 1 규칙 대비 · 2 카드 + 서약 재생 · 3 저널 · 4 냉각 · 5 실행 창).
@freezed
abstract class RepairStageRow with _$RepairStageRow {
  const factory RepairStageRow({
    required String title,
    required String stateLabel,
    required UiLevel level,

    /// 규칙 대비 · 서약 3문장 재생 · 냉각 끝 «MM-DD HH:mm 부터» — 엔진 글자.
    required List<String> lines,

    /// 기존 `interventionStep{session_id, stage, outcome, decision_id?}` — 엔진 완성 · 그대로 `run`.
    required List<SafetyActionCall> actions,

    /// 3단계만 true — 저널 3칸 폼(제출 = `runInterventionJournal`).
    required bool journalForm,
  }) = _RepairStageRow;

  factory RepairStageRow.fromJson(Map<String, dynamic> json) =>
      _$RepairStageRowFromJson(json);
}
// JSON 키: title · state_label · level · lines · actions · journal_form

/// 정본 정정 폼(diff 갈래 · 5단계 통과 뒤).
@freezed
abstract class RepairCorrectionForm with _$RepairCorrectionForm {
  const factory RepairCorrectionForm({
    /// 정정할 브로커 체결 후보(빈 목록 금지 — 엔진 숙제 미결 217).
    required List<RepairFillChoice> fills,

    /// 수량 · 가격 재기재가 허용되나(아니면 무효만).
    required bool amendAllowed,

    /// 폼 머리 문장 — 엔진.
    String? noticeText,
  }) = _RepairCorrectionForm;

  factory RepairCorrectionForm.fromJson(Map<String, dynamic> json) =>
      _$RepairCorrectionFormFromJson(json);
}
// JSON 키: fills · amend_allowed · notice_text

/// 정정 대상 체결 한 칸.
@freezed
abstract class RepairFillChoice with _$RepairFillChoice {
  const factory RepairFillChoice({
    /// 🔴 화면 미참조 — 체결 id(제출 DTO 의 `fillRef` 로 그대로).
    required String fillRef,

    /// 체결 요약 — 엔진(날 · 종목 · 수량 · 가격 글자).
    required String label,
  }) = _RepairFillChoice;

  factory RepairFillChoice.fromJson(Map<String, dynamic> json) =>
      _$RepairFillChoiceFromJson(json);
}
// JSON 키: fill_ref · label
