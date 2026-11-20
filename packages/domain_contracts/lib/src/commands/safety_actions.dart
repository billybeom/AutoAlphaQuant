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
    /// `ReconClearResultCodes` ∪ {`BIOMETRIC_UNAVAILABLE`}(C-55 ② · C-56 ② · C-60 ⑩).
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
