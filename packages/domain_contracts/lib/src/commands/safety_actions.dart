// 01 §30 — 🆕 계약 v1.21 · M5 «안전 동작». ⚠️ `CommandApi` 가 아니다 · 넷째 쓰기 창구(C-7 · 🆕 v1.22 표면 여덟 — 01 §31 K52).
//
// 🔴 M5 의 재개·서약 쓰기는 Supabase 명령 테이블을 거치지 않는다 — **폰 로컬에서 operator 구현이 엔진(data_sync
//    `kill_switch_store` · `pledge_store`)을 직접 부른다**(뷰어에 경로가 있어서는 안 된다 · 01 §4-3 `SettingsActions` 와 같은 결).
// 🔴 **폰(operator) 빌드에만 구현체가 주입된다.** 뷰어 빌드 = `null` → 화면은 컨트롤을 **렌더하지 않는다**(부재 · 비활성 아님).
// 🔴 **`ui_safety` 만 참조한다**(C-55 ⑯ — `ui_settings`·`ui_shell`·`ui_journal`·`ui_analytics` 0 · 조립 앱 = 주입만).
// 🔴 **«동작»만이다**(G-29) — 상태 구독은 `KillSwitchGateRepository`·`PledgeRepository` 다. 화면이 `run…()` 을 폴링해
//    상태를 만들면 경계 규칙 ① 위반이다(어디까지 왔나 = `KillResumeGateVm.nextItemNo` 로만).
// 🔴 생체 = 구현(조립 앱 M5 가드 · 01 §8 미결 169) — 실패·미등록 = 결과 `reasonCode` `BIOMETRIC_UNAVAILABLE`(한 벌).
// 🔴 킬스위치 «해제» 버튼·명령은 여전히 없다 — 재개는 7문항을 한 문항씩 통과한 결과일 뿐이다(`command_api.dart` 머리).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/command.dart';
import '../enums/safety.dart';
import '../enums/ui.dart';

part 'safety_actions.freezed.dart';
part 'safety_actions.g.dart';

/// M5 안전 동작의 주입 콜백(폰 전용).
///
/// · `run(id, args)` — 엔진이 [SafetyActionCall] 에 완성한 호출(🔴 1.21.0 = 받는 id 0 · 부르면 구현 `ArgumentError`
///   `Future` 에러 · 화이트리스트 = 1.22.0 이 이 머리에 적는다).
/// · `runKillResumeItem` — 재개 게이트(M5-2) 한 문항. 🔴 구현 의무(K36): ① 재개 준비 확인(`ready` 아니면 엔진 `tryResume`
///   차례 그대로 `KILL_SWITCH_NOT_ACTIVE` · `RESUME_CHECKLIST_NOT_CONFIRMED` · `RESUME_TRUSTED_TIME_UNKNOWN` · `RESUME_TOO_SOON`)
///   ② 생체 ③ 엔진 `ResumeChecklist.accept`(순차 · 앞 번호 = `RESUME_ITEM_OUT_OF_ORDER` · 빈칸·범위 밖·파싱 실패 =
///   `RESUME_ITEM_MISSING` · 4번 미충족 뒤 = `RESUME_CONDITION_UNMET`) ④ 7번 통과 = 엔진 `resume()` 한 트랜잭션(해제 ·
///   `decision_id` = 구현이 짓는 새 저널 id — 겹치면 `JOURNAL_ID_TAKEN`) · **1번 제출 = 초안을 비우고 처음부터**(R56 K4
///   «뒤로 고치기 = 처음부터») · 초안 = 구현이 든다 · 결과 id = 늘 [SafetyActionId.killSwitchResume].
/// · `runPledge` — 서약 첫 판(`pledgeWrite` · `decisionId` null — 구현 = 명령 id · R67 Z1) / 편집(`pledgeEdit` · `decisionId`
///   = 사전 저널 id · R67 Z2). 그 밖 id = 구현 `ArgumentError`. 거부 = `PledgeResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`.
/// 🔴 화면은 [SafetyActionResult] 의 `headline` + `reasonCode` 원문만 그린다(분기 0 · `handoffRoute`·`retryable` 1.21.0 표본 null·false).
/// 🆕 v1.22(01 §31 · K52~K55) — `run(id, args)` 화이트리스트(엔진이 [SafetyActionCall] 에 완성 · 🔴 화면은 그대로 넘긴다 · 키 = snake_case):
///    · `interventionStep`     = `{session_id, stage /* '1'~'5' */, outcome ∈ InterventionStepOutcome.wire, decision_id?}`
///    · `ruleChangeCancel`     = `{request_id}`
///    · ~~`reconClear`~~ — 🆕 v1.26(01 §35 · K181) 화이트리스트에서 뺐다: `run(reconClear, …)` = 구현 `ArgumentError` ·
///                               해제 = [SafetyActions.runReconClear](사람 글 = 제출 DTO · K7) · `SafetyActionId.reconClear` = 결과 id 로 남는다.
///    · `seasonalWindowChoice` = `{work_id, choice ∈ SeasonalEntryChoice.wire}`(`decision_id` = 구현이 짓는다 — K54 · 거부 =
///                               `SeasonalChoiceResultCodes` ∪ `PlannedWorkRejectCodes` ∪ 멈춤 사유 7(`ResumeItemReasonCodes`))
///  그 밖 id 를 `run` 으로 부르면 구현 `ArgumentError`(`Future` 에러 · 결과 코드 0).
/// · `runStoppedDecision` — `M5-3` 결정(`decision_id` = 구현이 짓는 새 저널 id · 겹치면 `JOURNAL_ID_TAKEN`) · 거부 = `StoppedDecisionResultCodes`.
/// · `runPostmortem` — 사건 postmortem(거부 = `PostmortemResultCodes`).
/// · `runRuleChangeApproval` — 승인(거부 = `RuleChangeResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`).
/// · `runDiscretionAdjust` — 재량 조정(조정폭 원문 · 파싱 실패 = `DELTA_EXCEEDED` · 여러 사유 = 엔진 정렬 첫째 · 거부 =
///   `DiscretionResultCodes` ∪ `TRUSTED_TIME_UNKNOWN`).
/// 🔴 결과 id = 늘 그 동작의 id · 생체 = 구현(K11) · 화면은 `headline` + `reasonCode` 원문만 그린다(분기 0).
/// 🆕 v1.26(01 §35 · K178 · K180 · K181 · 표면 열 — C-7):
/// · `runRuleChangeRequest` — `M5-9` 규칙 변경 요청(첫 승인 포함 · 유형·`hashBefore`·`hashAfter` = 엔진 후보 행(`candidateId`) ·
///   자기 신고 0 · `decision_id` = 구현이 짓는 새 저널 id · 저널 + 요청 한 트랜잭션 · 거부 = `RuleChangeResultCodes` ∪
///   `TRUSTED_TIME_UNKNOWN` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.ruleChangeRequest].
/// · `runReconClear` — `M5-5` RECON 해제(`decision_id` = 구현 · `cleared_by` = 구현(기기 별칭) · 저널 `RECON_CLEAR` + 해제 한
///   트랜잭션 · 신뢰 시각 비의존 · 거부 = `ReconClearResultCodes` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.reconClear].
/// 🔴 사전 저널 꼴 ⓐ(K180) — 사람 글 3필드(`rationaleBefore` · `expectedOutcome` · `ruleCited` 원문)는 제출 DTO 에 · 저널 id 는
///    구현 · 저널 행과 동작은 한 트랜잭션(고아 저널 0 · 엔진 «저널 함께 쓰기» 판 = 01 §8 미결 206).
/// 🆕 v1.32(01 §41 · K251~K259 · E16j-a · X5 정정 마법사 `RepairWizardVm`):
/// · `run` 화이트리스트 +1(🆕 v1.33 에 표 꼴로 맞춤 — C-60 ⑮):
///    · `repairAccept`     = `{diff_id}`(아무것도 안 하기 · 구현 = 살아 있는 개입 세션 `DO_NOTHING` + diff ACCEPTED ·
///                           무결성 갈래 0 · 결과 id = [SafetyActionId.repairAccept]).
/// · `runRepairCorrect` — 정본 정정(diff 갈래 · 5단계 통과 뒤 · 원문 4칸 파싱 = 구현 · 직전 재대사 = 구현 · `decision_id` = 개입 세션 저널 ·
///   거부 = `RepairResultCodes` ∪ `AdviceRejectCodes` 정정 3 ∪ `InterventionResultCodes` ∪ `TRUSTED_TIME_UNKNOWN` ∪ 🆕 v1.35
///   `RepairInputResultCodes`(원문 파싱 · K291)). 결과 id = [SafetyActionId.repairCorrect].
///   🆕 v1.35(K292) — 정정 체인 상한 = 운영 설정 `operations.amend_chain_max`(SPEC 02 §4 · 값 = 01 §10-3 B6 · 계약 상수 0 · C-32).
/// · `runRepairBaseline` — 새 기준점(무결성 갈래 · 거부 = `BaselineResultCodes` ∪ `BaselineApplyResultCodes` ∪ `InterventionResultCodes` ∪
///   `TRUSTED_TIME_UNKNOWN`). 결과 id = [SafetyActionId.repairBaseline].
/// · `runInterventionJournal` — 개입 3단계 사전 저널(K180 꼴 3칸 · 구현 = 살아 있는 세션 하나에 붙인다 · 저널 + 3단계 한 트랜잭션 · M5-6 재사용 ·
///   거부 = `InterventionResultCodes` ∪ `JOURNAL_ID_TAKEN`). 결과 id = [SafetyActionId.interventionJournal].
///   🆕 v1.35(01 §44 · K294) — 그 저널 행 `kind` = `DecisionJournalKinds.interventionJournal`(`INTERVENTION_JOURNAL` · 지금 엔진 NULL → 미결 220 ⓒ).
/// 🆕 v1.35(01 §44 · K296) — 🔴 **저널 키 한 벌**: 이 표면의 `decision_id`(재개 7번 · STOPPED · RECON 해제 · 규칙 변경 요청 · 개입 3단계 ·
///    재량 조정 `DiscretionAdjustSubmission.decisionId` · 서약 편집 `PledgeSubmission.decisionId`) = `decision_journal.journal_id` 이고,
///    `J-3` 키(`AppRoutes.journalDraft` `:decisionId` · `JournalDraft.decisionId`)도 같은 저널 id 다. 재량 · 서약 편집은 저널을 J-3 가 먼저
///    쓰고(새 행 갈래 · kind = `DISCRETION` · `PLEDGE_EDIT`) 동작이 그 id 를 받는다 · 나머지는 동작이 저널 + 동작을 한 트랜잭션으로 쓴다(K180 ⓐ).
/// 🔴 정정 · 새 기준점 커밋이 개입 세션 5단계 · 실행 창 · `decision == journalId` 를 보게 하는 결속 = 엔진 숙제(01 §8 미결 217).
/// 🆕 v1.33(01 §42 · K273 · E16j-b · X1 기기 이전 `X1PlanWizardVm` · `X1RecoveryVm`) — `run` 화이트리스트 +6(표면 무변경 · 제출 DTO 0 ·
///    시크릿 = 슬롯 ↔ 구현 사이만 · `run_id` = 엔진이 args 에 싣는다):
///    · `x1PlanStart`      = `{}`(옛 폰 «봤습니다 — 이전 시작» · D-03 확인 결정 + 저널 시작 = 구현 · 거부 = `X1StartResultCodes` ∪ `X1JournalResultCodes` ∪ 공용)
///    · `x1PlanStep`       = `{run_id, step ∈ X1StepCodes}`(거부 = `X1StepBlockCodes` ∪ `X1JournalResultCodes` ∪ 공용)
///    · `x1PlanAbort`      = `{run_id, step}`(DEMOTED 앞만 · 거부 = `X1JournalResultCodes`)
///    · `x1EmergencyStart` = `{}`(비상 선언 결정 + 복구 코드 슬롯 → epoch+1 = 구현 · 거부 = `X1StartResultCodes` ∪ `X1RecoveryResultCodes` ∪ 공용)
///    · `x1ReissueRecord`  = `{run_id, item ∈ X1ReissueItemCodes}`(값 = 슬롯 · 지문만 엔진 · 거부 = `X1ReissueResultCodes`)
///    · `x1RecoveryStep`   = `{run_id, step ∈ X1RecoveryStepCodes}`(골든 · 체크리스트 · 생체 = 구현이 가른다 · 거부 = `X1GateReasonCodes` ∪
///                           `X1RestoreResultCodes` ∪ `BackupResultCodes` ∪ `X1OrderSealCodes` ∪ `X1RecoveryResultCodes` ∪ `BIOMETRIC_UNAVAILABLE`)
/// 🔴 VM 생산 · 단계 진행기 · REVOKED · 재발급 저장 · 백업 바이트 원천 = 엔진 · 조립 숙제(01 §8 미결 218) — 그 전 운영 앱 = 모르는 id 오류.
/// 🆕 v1.37(01 §46 · K319 · `M5-13` 원장 실사 해소 게이트) — `run` 화이트리스트 +1(표면 무변경 · 제출 DTO 0 · 운영 앱 받침 0):
///    · `heldCommandsConfirm` = `{review_id}`(엔진 완성 `SelfAuditResolveVm.confirmHeld` · 보관 묶음 스냅숏 id · 구현 = 그 묶음의
///                              `HELD_FOR_INTEGRITY` 전부 → `RECEIVED`(그 뒤 판정 = 보통 소비 규칙) · 버림 동작 0 · 거부 =
///                              `HeldReviewResultCodes` ∪ `BIOMETRIC_UNAVAILABLE` · 신뢰 시각 비의존 · 결과 id = 같은 id).
/// 🔴 `ADVICE_LEDGER_UNVERIFIED` 해제 동작은 없다(해제 = 실사 0오차를 본 엔진이 스스로 · 06 M5-13 · C-70 ③) — 생산 = 01 §8 미결 226.
abstract interface class SafetyActions {
  /// ⚠️ `SettingsActions.run` 과 같은 최소 보정 — non-nullable 선택 명명 인자에 `const {}` 기본값.
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  });

  Future<SafetyActionResult> runKillResumeItem(
    KillResumeItemSubmission submission,
  );

  Future<SafetyActionResult> runPledge(PledgeSubmission submission);

  Future<SafetyActionResult> runStoppedDecision(
    StoppedDecisionSubmission submission,
  );

  Future<SafetyActionResult> runPostmortem(PostmortemSubmission submission);

  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  );

  Future<SafetyActionResult> runDiscretionAdjust(
    DiscretionAdjustSubmission submission,
  );

  /// 🆕 v1.26(01 §35 · K178) — `M5-9` 규칙 변경 요청(첫 승인 포함).
  Future<SafetyActionResult> runRuleChangeRequest(
    RuleChangeRequestSubmission submission,
  );

  /// 🆕 v1.26(01 §35 · K181) — `M5-5` 차단 보드 RECON 해제.
  Future<SafetyActionResult> runReconClear(ReconClearSubmission submission);

  /// 🆕 v1.32(01 §41 · K255) — X5 정본 정정(diff 갈래).
  Future<SafetyActionResult> runRepairCorrect(
    RepairCorrectSubmission submission,
  );

  /// 🆕 v1.32(01 §41 · K256) — X5 새 기준점(무결성 갈래).
  Future<SafetyActionResult> runRepairBaseline(
    RepairBaselineSubmission submission,
  );

  /// 🆕 v1.32(01 §41 · K252) — 개입 3단계 사전 저널(X5 마찰 · M5-6 공용).
  Future<SafetyActionResult> runInterventionJournal(
    InterventionJournalSubmission submission,
  );

  Stream<SafetyActionResult> watch(String actionRunId);
}

/// 안전 동작 1회의 결과(`ActionResult` 꼴 · [id] 타입만 다르다 — `ActionResult.id` 는 `SettingsActionId` required).
@freezed
abstract class SafetyActionResult with _$SafetyActionResult {
  const factory SafetyActionResult({
    required String actionRunId,
    required SafetyActionId id,
    required UiLevel level,

    /// 결과 문구 — 🔴 엔진 생성(요약·의역 금지).
    required String headline,

    /// 값 ∈ `KillSwitchResultCodes` ∪ `SafetyCommonResultCodes` ∪ `PledgeResultCodes` ∪ 🆕 v1.22 `StoppedDecisionResultCodes` ∪
    /// `PostmortemResultCodes` ∪ `InterventionResultCodes` ∪ `RuleChangeResultCodes` ∪ `DiscretionResultCodes` ∪
    /// `SeasonalChoiceResultCodes` ∪ `PlannedWorkRejectCodes` ∪ `ResumeItemReasonCodes`(멈춤 사유 7) ∪ 🆕 v1.26
    /// `ReconClearResultCodes` ∪ 🆕 v1.32 `RepairResultCodes` ∪ `BaselineResultCodes` ∪ `BaselineApplyResultCodes` ∪ `AdviceRejectCodes` 정정 3 ∪
    /// 🆕 v1.35 `RepairInputResultCodes` ∪ 🆕 v1.37 `HeldReviewResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`}(C-55 ② · C-56 ② · C-60 ⑩ ·
    /// C-66 · C-68 · C-70 ④).
    String? reasonCode,

    /// ⏸ 1.21.0 · 1.22.0 표본 null(넘김 동작 = 화면 판 · 목적지 = M5·X 라우트 상수만).
    String? handoffRoute,
    required bool retryable,
  }) = _SafetyActionResult;

  factory SafetyActionResult.fromJson(Map<String, dynamic> json) =>
      _$SafetyActionResultFromJson(json);
}
// JSON 키: action_run_id · id · level · headline · reason_code · handoff_route · retryable

/// 엔진이 완성한 `SafetyActions.run` 호출 1개(`SettingsActionCall` 꼴). 🔴 화면은 [id]·[args] 를 그대로 넘긴다.
/// 🆕 v1.22 — 첫 사용처 = `ResumeGateRow.actions`(계절 3택 · 01 §31 K64).
@freezed
abstract class SafetyActionCall with _$SafetyActionCall {
  const factory SafetyActionCall({
    required SafetyActionId id,
    required Map<String, String> args,

    /// 버튼 글자 — 엔진.
    required String label,
  }) = _SafetyActionCall;

  factory SafetyActionCall.fromJson(Map<String, dynamic> json) =>
      _$SafetyActionCallFromJson(json);
}
// JSON 키: id · args · label

/// `M5-2` 재개 게이트 한 문항 제출(엔진 core `ResumeItemAnswer` 칸 − `decisionId`(구현이 짓는다 · K34) · 숫자 2 = 원문 · K35).
/// 🔴 그 번호에 맞는 칸만 채운다 — 1 `text` · 2 `emotion`·`intensity`·`sleepHours` · 3 `scenario` · 4 `condition` ·
///    5·6 `acknowledged` · 7 `rationaleBefore`·`expectedOutcome`·`ruleCited`. 3·4번 값 = 고른 `KillResumeChoice` 의 칸 그대로.
/// 🔴 화면은 검증·파싱하지 않는다(빈칸·범위 = 엔진 판정 · `RESUME_ITEM_MISSING`).
@freezed
abstract class KillResumeItemSubmission with _$KillResumeItemSubmission {
  const factory KillResumeItemSubmission({
    /// 지금 차례 = `KillResumeGateVm.nextItemNo`(1~7 · 1 = 처음부터).
    required int itemNo,
    String? text,
    String? emotion,

    /// 강도 원문(0~10 판정 = 엔진).
    String? intensity,

    /// 수면 시간 원문(0~24 판정 = 엔진).
    String? sleepHours,
    KillResumeScenario? scenario,
    KillResumeCondition? condition,
    @Default(false) bool acknowledged,
    String? rationaleBefore,
    String? expectedOutcome,

    /// 🔵 원문(엔진 = 비지 않음만 · J-3 의 «엔진 선택지 코드»와 다르다 — 01 §8 미결 184).
    String? ruleCited,
  }) = _KillResumeItemSubmission;

  factory KillResumeItemSubmission.fromJson(Map<String, dynamic> json) =>
      _$KillResumeItemSubmissionFromJson(json);
}
// JSON 키: item_no · text · emotion · intensity · sleep_hours · scenario · condition · acknowledged ·
//          rationale_before · expected_outcome · rule_cited

/// 서약 첫 판·편집 제출(엔진 `pledge_store.writeFirst` · `edit`). 🔴 문장 = 사람이 친 원문 그대로(프리필 0 · 다듬기 = 엔진).
@freezed
abstract class PledgeSubmission with _$PledgeSubmission {
  const factory PledgeSubmission({
    /// `pledgeWrite` · `pledgeEdit` 만(K32 · 그 밖 = 구현 `ArgumentError`).
    required SafetyActionId id,

    /// 세 문장(차례대로 · 셋 아님·빈칸 = 엔진 `PLEDGE_SENTENCES_MISSING`).
    required List<String> sentences,

    /// 첫 판 = null(구현 = 명령 id · R67 Z1) · 편집 = 사전 저널 id(R67 Z2 · 원천 = 01 §8 미결 185).
    String? decisionId,
  }) = _PledgeSubmission;

  factory PledgeSubmission.fromJson(Map<String, dynamic> json) =>
      _$PledgeSubmissionFromJson(json);
}
// JSON 키: id · sentences · decision_id

/// 🆕 v1.22(01 §31 · K53) — `M5-3` STOPPED 결정 제출(엔진 core `StoppedDecisionAnswers` 칸 − `decisionId`(구현이 짓는다)).
/// 🔴 [choice] = 누른 버튼(A·B·C — 선택지 글자·자격 = 엔진) · 사전 3필드 = 사람이 친 원문(빈칸 = 엔진 `JOURNAL_REQUIRED`).
@freezed
abstract class StoppedDecisionSubmission with _$StoppedDecisionSubmission {
  const factory StoppedDecisionSubmission({
    required StoppedDecisionChoice choice,

    /// 가족 합의서 당사자가 참석했다는 사람 선언(엔진은 선언만 받는다 · false = `FAMILY_AGREEMENT_MISSING`).
    @Default(false) bool familyAgreement,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _StoppedDecisionSubmission;

  factory StoppedDecisionSubmission.fromJson(Map<String, dynamic> json) =>
      _$StoppedDecisionSubmissionFromJson(json);
}
// JSON 키: choice · family_agreement · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.22 — 사건 postmortem 제출(ds `incident_store.dart:85` `recordPostmortem(incidentId, text)`).
/// 🔴 [incidentId] = 엔진이 VM 에 실은 값 그대로(원천 VM = 1.23.0+ · 01 §8 미결 188) · [text] = 원문(빈칸 = `POSTMORTEM_BLANK`).
@freezed
abstract class PostmortemSubmission with _$PostmortemSubmission {
  const factory PostmortemSubmission({
    required String incidentId,
    required String text,
  }) = _PostmortemSubmission;

  factory PostmortemSubmission.fromJson(Map<String, dynamic> json) =>
      _$PostmortemSubmissionFromJson(json);
}
// JSON 키: incident_id · text

/// 🆕 v1.22 — `M5-9` 규칙 변경 승인 제출(ds `rule_change_store.dart:364` `approve` 인자 1:1 · `requestId` = 엔진 값 그대로).
/// 🔴 [goldenChanged] null · [approver] 빈칸 = `RULE_CHANGE_APPROVAL_FIELDS_MISSING` · [thirdPartyNotified] false = `_THIRD_PARTY_MISSING`.
@freezed
abstract class RuleChangeApprovalSubmission
    with _$RuleChangeApprovalSubmission {
  const factory RuleChangeApprovalSubmission({
    required String requestId,
    bool? goldenChanged,
    required String approver,
    @Default(false) bool thirdPartyNotified,
  }) = _RuleChangeApprovalSubmission;

  factory RuleChangeApprovalSubmission.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeApprovalSubmissionFromJson(json);
}
// JSON 키: request_id · golden_changed · approver · third_party_notified

/// 🆕 v1.22 — `M5-6`·`M5-7` 재량 조정 제출(ds `discretion_store.dart:121` `requestAdjustment(deltaPct, decisionId)`).
/// 🔴 [deltaPct] = 원문(파싱 = 구현 · 실패·NaN = 엔진과 같은 `DELTA_EXCEEDED`) · [decisionId] = 사전 저널(`DISCRETION` ·
///    null = `JOURNAL_MISSING` · 원천 = 01 §8 미결 188).
@freezed
abstract class DiscretionAdjustSubmission with _$DiscretionAdjustSubmission {
  const factory DiscretionAdjustSubmission({
    required String deltaPct,
    String? decisionId,
  }) = _DiscretionAdjustSubmission;

  factory DiscretionAdjustSubmission.fromJson(Map<String, dynamic> json) =>
      _$DiscretionAdjustSubmissionFromJson(json);
}
// JSON 키: delta_pct · decision_id

/// 🆕 v1.26(01 §35 · K178 · K180) — `M5-9` 규칙 변경 요청 제출(ds `rule_change_store.dart` `request` 인자 − 유형·해시(엔진 후보) −
/// `decisionId`(구현)).
/// 🔴 사람 글 5칸 = 원문 그대로(빈칸 = 엔진 `RULE_CHANGE_FIELDS_MISSING` · 저널 3칸 빈칸 = `RULE_CHANGE_JOURNAL_MISSING`) ·
///    화면은 검증·파싱하지 않는다.
@freezed
abstract class RuleChangeRequestSubmission with _$RuleChangeRequestSubmission {
  const factory RuleChangeRequestSubmission({
    /// 엔진 후보 행 값 그대로(`RuleChangeCandidateRow.candidateId`).
    required String candidateId,
    required String reason,
    required String rollbackMethod,
    required String rationaleBefore,
    required String expectedOutcome,

    /// 근거 규칙(원문 · 01 §8 미결 184 ③ 결).
    required String ruleCited,
  }) = _RuleChangeRequestSubmission;

  factory RuleChangeRequestSubmission.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeRequestSubmissionFromJson(json);
}
// JSON 키: candidate_id · reason · rollback_method · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.26(01 §35 · K180 · K181) — `M5-5` RECON 해제 제출(ds `order_ledger.dart` `clearReconBlock` −
/// `clearedBy`·`decisionId`·시각(구현)).
/// 🔴 [originCode] = 고른 `ReconOriginChoice.originCode` 그대로 · 저널 3칸 = 원문(빈칸 = `RECON_JOURNAL_MISSING`).
@freezed
abstract class ReconClearSubmission with _$ReconClearSubmission {
  const factory ReconClearSubmission({
    required String originCode,
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _ReconClearSubmission;

  factory ReconClearSubmission.fromJson(Map<String, dynamic> json) =>
      _$ReconClearSubmissionFromJson(json);
}
// JSON 키: origin_code · rationale_before · expected_outcome · rule_cited

/// 🆕 v1.32(01 §41 · K255) — X5 정본 정정 제출(ds `correctFill` 칸 − 구현 몫(정정 id · 직전 재대사 diff · 결정 id · 체인 상한)).
/// 🔴 [targetId] · [fillRef] · [originCode] = VM 이 실은 값 그대로 · 수량 · 가격 · 수수료 · 세금 = 사람이 친 **원문**(파싱 = 구현 ·
///    거부 코드 = 엔진이 먼저 정한다 — 그 전 표본 0) · [voidFill] true = 무효(네 칸 무시).
@freezed
abstract class RepairCorrectSubmission with _$RepairCorrectSubmission {
  const factory RepairCorrectSubmission({
    required String targetId,
    required String fillRef,
    required String originCode,
    required bool voidFill,
    String? quantityText,
    String? priceText,
    String? commissionText,
    String? taxText,
  }) = _RepairCorrectSubmission;

  factory RepairCorrectSubmission.fromJson(Map<String, dynamic> json) =>
      _$RepairCorrectSubmissionFromJson(json);
}
// JSON 키: target_id · fill_ref · origin_code · void_fill · quantity_text · price_text · commission_text · tax_text

/// 🆕 v1.32(01 §41 · K256) — X5 새 기준점 제출(ds `applyBaseline` · [targetId] = 무결성 합성 id `li-…` · 원인 = 3종 ∩ 경계 후보).
@freezed
abstract class RepairBaselineSubmission with _$RepairBaselineSubmission {
  const factory RepairBaselineSubmission({
    required String targetId,
    required String originCode,
  }) = _RepairBaselineSubmission;

  factory RepairBaselineSubmission.fromJson(Map<String, dynamic> json) =>
      _$RepairBaselineSubmissionFromJson(json);
}
// JSON 키: target_id · origin_code

/// 🆕 v1.32(01 §41 · K252) — 개입 3단계 사전 저널 제출(K180 꼴 · 사람 글 3칸 원문 · 저널 id = 구현 · 세션 = 살아 있는 하나).
@freezed
abstract class InterventionJournalSubmission
    with _$InterventionJournalSubmission {
  const factory InterventionJournalSubmission({
    required String rationaleBefore,
    required String expectedOutcome,
    required String ruleCited,
  }) = _InterventionJournalSubmission;

  factory InterventionJournalSubmission.fromJson(Map<String, dynamic> json) =>
      _$InterventionJournalSubmissionFromJson(json);
}
// JSON 키: rationale_before · expected_outcome · rule_cited
