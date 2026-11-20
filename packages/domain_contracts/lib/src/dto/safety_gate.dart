// packages/domain_contracts/lib/src/dto/safety_gate.dart
//
// 🆕 계약 v1.21(01 §30) — M5-2 킬스위치 재개 게이트 · M5-8/`O-04` ② 서약 표시 VM.
// 🆕 v1.22(01 §31 · K65) — `M5-4` 브레이커 사다리(문장 = 엔진 `breakerLadderOf` 글자 그대로).
// 🆕 v1.25(01 §34 · K146 · K147 · K154) — `M5-1` 킬스위치 화면 · 발동 뒤 기록 폼(01 §8 미결 186) ·
//    `M5-5` 차단 보드(사다리 `M5-4` · 게이지 `M5-7` 감싸기).
// 🆕 v1.26(01 §35 · K179 · K181) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판»(후보 · 큐) · `M5-5` RECON 행 해제 폼
//    (`BlockBoardRow.reconClear` 추가형).
// 🔴 M5 만 렌더한다(`ui_safety` · 01 §2-10 표 · C-7) · 상태를 바꾸는 경로 = `SafetyActions`(포트) 뿐.
// 🔴 화면은 받은 글자·차례 그대로 그린다 — 단계·남은 시간을 계산하지 않는다(카운트다운 0 · 새 VM 으로만).
// 🔴 7문항 글자 출처 = SPEC v2.40 04 §3-6 ③ «재개판» 원문(발주자 확정 2026-11-04 · 정규화 = 01 §30 K38) —
//    엔진이 같은 상수를 두고 계약 표본과 대조한다(엔진 숙제 · 06 변경 이력 «2026-11-15 · 계약 판 나눔»).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall(🆕 v1.26 — 규칙 변경 큐 행 취소 · resume.dart 선례)
import '../enums/safety.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction(🆕 v1.25)
import 'safety.dart';

part 'safety_gate.freezed.dart';
part 'safety_gate.g.dart';

/// `M5-2` 재개 게이트 한 화면(창구 = `KillSwitchGateRepository.watchResumeGate()`).
/// 🔴 불변식(엔진 의무 · C-55 ④~⑨) — [items] = 7(받은 길이 · 엔진 config `resumeChecklistItems`) · [nextItemNo] non-null ⇒
///    준비됨 ∧ [blockedText]·[lockedLabel] null · 답한 행 = 앞에서부터 이어짐 · [lockedLabel] non-null ⇒ [nextItemNo] null.
@freezed
abstract class KillResumeGateVm with _$KillResumeGateVm {
  const factory KillResumeGateVm({
    /// 머리 줄 — 엔진 `killSwitchViewOf.stateLabel` 글자 그대로.
    required String readinessLabel,
    required UiLevel level,

    /// 해제 시각 줄 — 엔진 `releaseEtaText`(«해제 가능 예정 11-18 14:00» · 시각 모름 · 해제 가능). null = 부재(확인 전).
    String? etaText,

    /// 48h 냉각 게이지 — `code` = `GaugeCodes.cooldown` · 표시 = `valueText`(엔진 «남은 n시간»). null = 확인 전.
    GaugeProgress? cooldown,

    /// 재개판 7문항(엔진 차례 · 🔴 화면이 7 을 박지 않는다 — 받은 길이).
    required List<KillResumeItemRow> items,

    /// 지금 받을 문항 번호(1~7). null = 받을 문항 없음(대기 · 확인 전 · 시각 모름 · 4번 미충족 · 잠김 · 꺼짐).
    int? nextItemNo,

    /// 막힌 까닭 한 줄 — 확인 전 = 엔진 «체크리스트를 먼저 마치십시오 — …» · 4번 미충족 = SPEC «미충족이면 재개하지 않는다».
    String? blockedText,

    /// 운영 등급 생체 축소(보기만) — non-null ⇒ [nextItemNo] null(01 §8 미결 169).
    String? lockedLabel,
    required AsOf asOf,
  }) = _KillResumeGateVm;

  factory KillResumeGateVm.fromJson(Map<String, dynamic> json) =>
      _$KillResumeGateVmFromJson(json);
}
// JSON 키: readiness_label · level · eta_text · cooldown · items · next_item_no · blocked_text · locked_label · as_of

/// 재개판 한 문항.
@freezed
abstract class KillResumeItemRow with _$KillResumeItemRow {
  const factory KillResumeItemRow({
    /// 1~7 — 🔴 화면은 이 번호로 글자·칸을 고르지 않는다(제출 `itemNo` 에 그대로).
    required int itemNo,

    /// 문항 글자(SPEC 원문 · K38).
    required String label,

    /// 발동 때 답(카드 ④ 같은 번호 · 엔진이 발동 기록에서 재생 · 6번 = «체크리스트 확인 …» · 7번 = null · 확인 전 = 전부 null).
    String? replayText,

    /// 지금 받은 답(통과한 문항만 · 엔진 글자).
    String? answeredText,
    required UiLevel level,

    /// 고를 것(3번 3 · 4번 2 · 그 밖 빈) — 글자·값 = 엔진. 비면 = 글 입력(1·2·7) 또는 확인(5·6) 문항.
    @Default(<KillResumeChoice>[]) List<KillResumeChoice> choices,
  }) = _KillResumeItemRow;

  factory KillResumeItemRow.fromJson(Map<String, dynamic> json) =>
      _$KillResumeItemRowFromJson(json);
}
// JSON 키: item_no · label · replay_text · answered_text · level · choices

/// 3·4번 선택지 1개 — 🔴 [scenario]·[condition] 중 **정확히 하나** non-null · 화면은 그 칸을 제출 DTO 에 그대로 옮긴다.
@freezed
abstract class KillResumeChoice with _$KillResumeChoice {
  const factory KillResumeChoice({
    /// «해소됨» · «진행 중» · «해당 없었음» · «충족» · «미충족»(SPEC 원문).
    required String label,
    KillResumeScenario? scenario,
    KillResumeCondition? condition,
  }) = _KillResumeChoice;

  factory KillResumeChoice.fromJson(Map<String, dynamic> json) =>
      _$KillResumeChoiceFromJson(json);
}
// JSON 키: label · scenario · condition

/// `M5-8` · `O-04` ② 서약(창구 = `PledgeRepository.watchPledge()` · 재생처도 이 줄만 읽는다 — 원문은 한 번만).
/// 🔴 [lines] = 0(첫 판 없음 = 쓰기 자리) 또는 3 · [editable] ⇒ 3 줄 ∧ 12월 창(엔진 판정) · [lockedLabel] ⇒ [editable] false.
/// 🔴 엔진 글자가 없는 칸([statusLine] · [replayNotice])은 null 이다(K16 · 표본 null — 화면이 글자를 짓지 않는다).
@freezed
abstract class PledgeVm with _$PledgeVm {
  const factory PledgeVm({
    /// 사용자 원문(지금 판 · 차례대로).
    @Default(<String>[]) List<String> lines,

    /// 판·작성 시각 줄 — ⏸ 엔진 글자 0(표본 null).
    String? statusLine,

    /// DD 최초 도달 재생 까닭 — ⏸ 엔진 글자 0(표본 null · 재생 대상 판정 = 엔진 `replayDue`).
    String? replayNotice,

    /// 편집 가능(12월 창 · 판 있음 — 엔진 판정). 🔴 화면이 달력으로 판정하지 않는다.
    @Default(false) bool editable,
    String? lockedLabel,
    required AsOf asOf,
  }) = _PledgeVm;

  factory PledgeVm.fromJson(Map<String, dynamic> json) =>
      _$PledgeVmFromJson(json);
}
// JSON 키: lines · status_line · replay_notice · editable · locked_label · as_of

/// 🆕 v1.22(01 §31 · K65) — `M5-4` 브레이커 사다리 한 화면(창구 = `BreakerLadderRepository.watchLadder()`).
/// 🔴 문장 = 엔진 `breakerLadderOf` 글자 그대로(% · 거래일 = 엔진 설정 값 · 화면이 짓지 않는다) · [rows] = 받은 길이(엔진 5).
@freezed
abstract class BreakerLadderVm with _$BreakerLadderVm {
  const factory BreakerLadderVm({
    required List<BreakerLadderRow> rows,
    required AsOf asOf,
  }) = _BreakerLadderVm;

  factory BreakerLadderVm.fromJson(Map<String, dynamic> json) =>
      _$BreakerLadderVmFromJson(json);
}
// JSON 키: rows · as_of

/// 사다리 한 단(엔진 core `BreakerLadderStep` · `safety/breaker_ladder.dart:12` 칸 1:1).
@freezed
abstract class BreakerLadderRow with _$BreakerLadderRow {
  const factory BreakerLadderRow({
    required BreakerLevel level,

    /// «정상» · «경보» · «축소 운용» · «중지» · «정지»(엔진 `breakerLabelOf`).
    required String label,
    required String triggerText,
    required String releaseText,
    required String actionText,

    /// 지금 단(정확히 한 행 — C-56 ⑤).
    required bool current,
  }) = _BreakerLadderRow;

  factory BreakerLadderRow.fromJson(Map<String, dynamic> json) =>
      _$BreakerLadderRowFromJson(json);
}
// JSON 키: level · label · trigger_text · release_text · action_text · current

/// 🆕 v1.25(01 §34 · K146) — `M5-1` 킬스위치 한 화면(창구 = `KillSwitchGateRepository.watchKillSwitch()` · 🔒 `ui_safety`).
/// 🔴 불변식(엔진 의무 · C-59 ②~⑦) — [activateLabel] non-null ⇔ 꺼짐 · 꺼짐 ⇒ [activatedText]·[cancelHeadline]·[checklistStateLabel]·
///    [form]·[etaText]·[gateLink] null ∧ [cancelRows] 빈 · [pathLines] non-empty ⇒ 꺼짐 · [form] non-null ⇒ 켜짐 ∧ 기록 전 ∧
///    [lockedLabel] null · [gateLink]·[etaText] non-null ⇒ 기록 뒤 · [lockedLabel] 은 [activateLabel] 을 지우지 않는다(끄기는 등급 밖 · K150).
/// 🔴 버튼을 누르면 확인 대화 없이 `CommandApi.activateKillSwitch()` — 화면이 대화·지연·두 번 누르기를 더하지 않는다(06 M5-1).
/// 🔴 카운트다운 0 · 해제 칸·버튼 0(해제 = `m5ReleaseGate` 7번 통과뿐).
@freezed
abstract class KillSwitchScreenVm with _$KillSwitchScreenVm {
  const factory KillSwitchScreenVm({
    /// 머리 — 엔진 `killSwitchViewOf.stateLabel`(«킬스위치 꺼짐» · «킬스위치 작동 중 — 신규 주문을 막고 있습니다»).
    required String stateLabel,
    required UiLevel level,

    /// 발동 줄(켜짐만 · 엔진 — 시각 «MM-DD HH:mm» + 기기 별칭 · 🔴 기기 id 원문 0).
    String? activatedText,

    /// 발동 버튼 글자(꺼짐만 · 엔진). null = 버튼 부재(이미 켜짐).
    String? activateLabel,

    /// 3중 경로 안내(꺼짐만 · 엔진 글자 · 받은 차례).
    @Default(<String>[]) List<String> pathLines,

    /// 미체결 취소 보고 머리(켜짐만 · 엔진 — 건수 문장 · 후보 읽기 실패 문장). null = 보고 부재.
    String? cancelHeadline,

    /// 건별(엔진 차례 · 금액·수량·주문번호·intent id 0).
    @Default(<KillCancelRow>[]) List<KillCancelRow> cancelRows,

    /// 기록 상태 — 엔진 `checklistStateLabel`(«체크리스트를 먼저 마치십시오 — …» · «체크리스트 확인 MM-DD HH:mm»). 꺼짐 = null.
    String? checklistStateLabel,

    /// 발동 뒤 기록 폼(켜짐 ∧ 기록 전 ∧ 잠김 아님 · 폰). 제출 = `CommandApi.confirmKillChecklist(KillChecklistSubmission)`.
    KillActivationFormVm? form,

    /// 해제 시각 줄 — 엔진 `releaseEtaText`(기록 뒤만).
    String? etaText,

    /// 재개 게이트로(엔진 완성 · 목적지 `AppRoutes.m5ReleaseGate` · 기록 뒤만).
    LinkAction? gateLink,

    /// 운영 등급 생체 축소(폼 0 · 🔴 발동 버튼은 남는다).
    String? lockedLabel,
    required AsOf asOf,
  }) = _KillSwitchScreenVm;

  factory KillSwitchScreenVm.fromJson(Map<String, dynamic> json) =>
      _$KillSwitchScreenVmFromJson(json);
}
// JSON 키: state_label · level · activated_text · activate_label · path_lines · cancel_headline · cancel_rows ·
//          checklist_state_label · form · eta_text · gate_link · locked_label · as_of

/// 🆕 v1.25(01 §34 · K151) — 미체결 취소 한 건(엔진 `KillCancelItem` − intent id · 코드 · 🔴 금액·수량·주문번호 0).
@freezed
abstract class KillCancelRow with _$KillCancelRow {
  const factory KillCancelRow({
    /// 종목 표시(엔진).
    required String symbolText,

    /// ∈ `KillCancelOutcomeCodes`(🔴 화면 분기 0 — 시험·Key 전용).
    required String outcomeCode,

    /// 결과 글자(엔진 · «불명»은 다시 부르지 않았다는 뜻까지).
    required String outcomeLabel,
    required UiLevel level,
  }) = _KillCancelRow;

  factory KillCancelRow.fromJson(Map<String, dynamic> json) =>
      _$KillCancelRowFromJson(json);
}
// JSON 키: symbol_text · outcome_code · outcome_label · level

/// 🆕 v1.25(01 §34 · K147 · 01 §8 미결 186) — `M5-1` 발동 뒤 기록 폼(카드 ④ (가) 7 + 확인 3 + 1줄).
/// 🔴 차단은 이미 걸려 있다(SPEC v2.40 §3-6 ③) — 이 폼은 발동을 늦추지 않는다 · 마친 시각 = 48h 기준(엔진).
/// 🔴 [items] = 받은 길이(엔진 7) · 입력 칸 꼴(번호별 글·선택·숫자 원문) · 칸 머리 · 제출 버튼 = 카드 정적 라벨(v1.21 K37 결).
/// 🔴 예시·프리필 0 — 사람이 친 원문이 `KillChecklistSubmission` 에 그대로 간다(파싱 = 구현).
@freezed
abstract class KillActivationFormVm with _$KillActivationFormVm {
  const factory KillActivationFormVm({
    required List<KillActivationItemRow> items,

    /// 확인 3 · 1줄 — 제출 칸 `openOrdersQueried` · `openOrdersCancelled` · `remainingCountZero` · `note` 와 1:1(엔진 글자).
    required String ackQueriedLabel,
    required String ackCancelledLabel,
    required String ackRemainingZeroLabel,
    required String noteLabel,

    /// 폼 고지(엔진 — «이 기록은 주문을 내지 않는다 · 전량 청산 = 기록만»). null = 부재.
    String? noticeText,
  }) = _KillActivationFormVm;

  factory KillActivationFormVm.fromJson(Map<String, dynamic> json) =>
      _$KillActivationFormVmFromJson(json);
}
// JSON 키: items · ack_queried_label · ack_cancelled_label · ack_remaining_zero_label · note_label · notice_text

/// 🆕 v1.25(01 §34 · K147 · K148) — 카드 ④ (가) 한 문항.
/// 🔴 [choices] non-empty ⇔ 2번(2) · 5번(2) · [fixedText] non-null ⇔ 6 · 7번(입력 0) · 둘 다 non-null 0.
@freezed
abstract class KillActivationItemRow with _$KillActivationItemRow {
  const factory KillActivationItemRow({
    /// 1~7 — 🔴 제출 칸 대응은 카드 정적(1 ruleAction · 2 reasonKind·emotion·intensity·sleepHours · 3 scenarioId·scenarioNone ·
    ///    4 resumeCondition · 5 scope).
    required int itemNo,

    /// 문항(SPEC 04 §3-6 «카드 ④(발동 뒤 기록)» 원문 · 01 §30 K38 정규화).
    required String label,

    /// 종이 카드 원문 보탬 줄(03 §7-4 · 3·5번만 — K148). null = 부재.
    String? hintText,

    /// 입력 없는 문항의 글자(6 = 시작 시각은 엔진이 적는다 · 7 = 저널은 구현이 만든다 — 엔진). null = 입력 문항.
    String? fixedText,

    /// 고를 것(2번 규칙/감정 · 5번 범위 — 글자·값 = 엔진).
    @Default(<KillActivationChoice>[]) List<KillActivationChoice> choices,
  }) = _KillActivationItemRow;

  factory KillActivationItemRow.fromJson(Map<String, dynamic> json) =>
      _$KillActivationItemRowFromJson(json);
}
// JSON 키: item_no · label · hint_text · fixed_text · choices

/// 🆕 v1.25(01 §34 · K147) — 2·5번 선택지 1개 — 🔴 [reasonKind]·[scope] 중 **정확히 하나** non-null ·
/// 화면은 그 칸을 제출 DTO 에 그대로 옮긴다.
@freezed
abstract class KillActivationChoice with _$KillActivationChoice {
  const factory KillActivationChoice({
    /// «규칙» · «감정» · «신규 진입 차단만» · «전량 청산»(SPEC 원문).
    required String label,
    KillActivationReason? reasonKind,
    KillActivationScope? scope,
  }) = _KillActivationChoice;

  factory KillActivationChoice.fromJson(Map<String, dynamic> json) =>
      _$KillActivationChoiceFromJson(json);
}
// JSON 키: label · reason_kind · scope

/// 🆕 v1.25(01 §34 · K154 · 01 §8 미결 188 M5-5 읽기 몫) — `M5-5` 차단 보드 한 화면
/// (창구 = `BlockBoardRepository.watchBoard()` · 🔒 `ui_safety`).
/// 🔴 불변식(C-59 ⑩~⑫) — [killSwitchLink] 늘 non-null(목적지 `AppRoutes.m5KillSwitch` · 끄기는 언제나) ·
///    [emptyLabel] non-null ⇒ [rows] 빈 · [ladder] 의 current 행 라벨 == [breakerLabel] ·
///    [stoppedDecisionLink] non-null ⇒ 목적지 `AppRoutes.m5StoppedDecision`.
/// 🔴 화면은 받은 차례 그대로(재정렬·재분류 0) · 행 링크 = 엔진 · 🆕 v1.26 — RECON 행만 해제 폼(`BlockBoardRow.reconClear` ·
///    01 §35 K181) · 그 밖 해제 = 링크.
@freezed
abstract class BlockBoardVm with _$BlockBoardVm {
  const factory BlockBoardVm({
    /// 머리(엔진 — 막힌 것 요약 한 줄).
    required String headline,
    required UiLevel level,

    /// 지금 단(엔진 `breakerLabelOf` — `SafetyState.breakerLabel` 과 같은 글자).
    required String breakerLabel,

    /// 막힌 것(켜진 킬스위치 먼저 + 차단 플래그 · 엔진 차례).
    @Default(<BlockBoardRow>[]) List<BlockBoardRow> rows,

    /// 해제 진행 게이지(M5-7 · `SafetyState.releaseProgress` 와 같은 값 · code ∈ `GaugeCodes`).
    @Default(<GaugeProgress>[]) List<GaugeProgress> gauges,

    /// 서킷브레이커 사다리(M5-4 · 엔진 `breakerLadderOf` 글자 그대로 — `BreakerLadderVm` 감싸기).
    required BreakerLadderVm ladder,

    /// STOPPED 재개 결정(엔진 · 자격 때만 · 목적지 `AppRoutes.m5StoppedDecision`).
    LinkAction? stoppedDecisionLink,

    /// 킬스위치 진입(엔진 · 늘 · 목적지 `AppRoutes.m5KillSwitch`).
    required LinkAction killSwitchLink,

    /// «막힌 것 없음» 문장(엔진 · 행 0 ∧ 브레이커 정상일 때만).
    String? emptyLabel,
    required AsOf asOf,
  }) = _BlockBoardVm;

  factory BlockBoardVm.fromJson(Map<String, dynamic> json) =>
      _$BlockBoardVmFromJson(json);
}
// JSON 키: headline · level · breaker_label · rows · gauges · ladder · stopped_decision_link · kill_switch_link · empty_label · as_of

/// 🆕 v1.25(01 §34 · K155) — 보드 한 행(막힌 것 하나 · 해제 성격과 경로가 행마다 다르다 — 06 M5-5).
@freezed
abstract class BlockBoardRow with _$BlockBoardRow {
  const factory BlockBoardRow({
    /// 🔴 화면 미참조(시험·Key) — ∈ `FlagIds.values` ∪ {`KILL_SWITCH`}.
    required String rowId,

    /// 플래그 = 엔진 플래그 사전 라벨 · 킬스위치 = `killSwitchViewOf.stateLabel`.
    required String label,

    /// «MM-DD HH:mm부터»(엔진). null = 부재.
    String? setAtText,

    /// 해제 성격(`ClearRoute` 짝 글자 · 엔진 — 킬스위치 = «재개 게이트로만»).
    required String clearKindLabel,

    /// 할 일(플래그 = 엔진 사전 해제 문장 · 킬스위치 = 엔진 기록 상태·ETA 문장).
    required String clearInstruction,
    required UiLevel level,

    /// 조치 진입(엔진 · 플래그 = `clearDeepLink` · 킬스위치 = `m5KillSwitch`). null = 이동 0.
    LinkAction? link,

    /// 🆕 v1.26(01 §35 · K181) — `RECON_MISMATCH` 행만 · 해제 폼(엔진). null = 해제 동작 0(그 밖 행 · 막힘 없음 · 잠김).
    ReconClearForm? reconClear,
  }) = _BlockBoardRow;

  factory BlockBoardRow.fromJson(Map<String, dynamic> json) =>
      _$BlockBoardRowFromJson(json);
}
// JSON 키: row_id · label · set_at_text · clear_kind_label · clear_instruction · level · link · recon_clear(🆕 v1.26)

/// 🆕 v1.26(01 §35 · K181) — 차단 보드 RECON 행의 해제 폼(`BlockBoardRow.reconClear`).
/// 🔴 제출 = `SafetyActions.runReconClear(ReconClearSubmission)` — `run(reconClear, …)` 은 받지 않는다(구현 `ArgumentError`).
@freezed
abstract class ReconClearForm with _$ReconClearForm {
  const factory ReconClearForm({
    /// 원인 코드 선택지(엔진 쓰기 화이트리스트 ∩ 자동 갈래 · 차례 = 엔진). 🔴 빈 목록 금지(C-60 ⑨).
    required List<ReconOriginChoice> choices,

    /// 고지(엔진 · 예: «해제는 저널과 함께 기록됩니다 — 주문을 내지 않습니다»). null = 부재.
    String? noticeText,
  }) = _ReconClearForm;

  factory ReconClearForm.fromJson(Map<String, dynamic> json) =>
      _$ReconClearFormFromJson(json);
}
// JSON 키: choices · notice_text

/// 🆕 v1.26(01 §35 · K181) — RECON 원인 코드 선택지 하나.
@freezed
abstract class ReconOriginChoice with _$ReconOriginChoice {
  const factory ReconOriginChoice({
    /// ∈ `OriginCodes.writable` — 제출 `ReconClearSubmission.originCode` 로 그대로.
    required String originCode,

    /// 엔진 글자.
    required String label,
  }) = _ReconOriginChoice;

  factory ReconOriginChoice.fromJson(Map<String, dynamic> json) =>
      _$ReconOriginChoiceFromJson(json);
}
// JSON 키: origin_code · label

/// 🆕 v1.26(01 §35 · K177 · K179) — `M5-9` 규칙 변경 게이트 «첫 승인 최소판»(`AppRoutes.m5RuleChangeGate` ·
/// 창구 = `RuleChangeGateRepository.watchGate()` · 🔒 `ui_safety`).
/// 🔴 1.26.0 = 후보(첫 승인할 지금 config) + 큐(요청 · 냉각 · 승인 · 취소). CHANGELOG · 창 밖 안내 · DD 락 글자 = 1.27.0+.
/// 🔴 냉각 30일 · SAF-405 · 12월 창 면제 규칙 = SPEC·엔진 그대로(글자로만 싣는다 — 새 수치 0).
/// 🔴 불변식(C-60 ⑦) — [lockedLabel] non-null ⇒ [candidates] 빈 ∧ 모든 행 `cancel`·`approveLabel` null.
@freezed
abstract class RuleChangeGateVm with _$RuleChangeGateVm {
  const factory RuleChangeGateVm({
    /// 엔진 머리(예: «승인된 설정이 없습니다 — 실전 기동 전에 첫 승인이 필요합니다»).
    required String headline,
    required UiLevel level,

    /// 창 글자(엔진 · 첫 승인 = 창 면제 문장 · 둘째부터 = 12월 창). null = 부재.
    String? windowText,

    /// 요청할 수 있는 후보(엔진 · v1 = 0 또는 1). 빈 목록 = 요청 버튼 0.
    @Default(<RuleChangeCandidateRow>[])
    List<RuleChangeCandidateRow> candidates,

    /// 열린 요청(엔진 `queue()` 차례).
    @Default(<RuleChangeQueueRow>[]) List<RuleChangeQueueRow> rows,

    /// 후보 0 ∧ 큐 0 일 때 문장(엔진). null = 부재.
    String? emptyLabel,

    /// 잠김(01 §8 미결 169) · non-null ⇒ 요청·승인·취소 0.
    String? lockedLabel,
    required AsOf asOf,
  }) = _RuleChangeGateVm;

  factory RuleChangeGateVm.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeGateVmFromJson(json);
}
// JSON 키: headline · level · window_text · candidates · rows · empty_label · locked_label · as_of

/// 🆕 v1.26(01 §35 · K178 · K179) — 요청할 수 있는 config 후보 한 행(유형·해시 = 엔진 · 자기 신고 0 — 03운 §6-3).
@freezed
abstract class RuleChangeCandidateRow with _$RuleChangeCandidateRow {
  const factory RuleChangeCandidateRow({
    /// 🔴 화면 미참조(제출용) — `RuleChangeRequestSubmission.candidateId` 로 그대로 되돌린다.
    required String candidateId,

    /// 후보 이름(엔진 · 예: «지금 쓰는 설정 — 첫 승인»).
    required String label,

    /// 변경 유형 글자(엔진 분류).
    required String categoryLabel,

    /// 해시 글자(엔진 · 앞 8자).
    required String hashText,

    /// 요청 버튼 글자(엔진).
    required String requestLabel,

    /// 고지(엔진 · 예: «요청 뒤 30일 냉각이 끝나야 승인할 수 있습니다»). null = 부재.
    String? noticeText,
  }) = _RuleChangeCandidateRow;

  factory RuleChangeCandidateRow.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeCandidateRowFromJson(json);
}
// JSON 키: candidate_id · label · category_label · hash_text · request_label · notice_text

/// 🆕 v1.26(01 §35 · K179) — 열린 규칙 변경 요청 한 행(엔진 `rule_change_store.queue()`).
@freezed
abstract class RuleChangeQueueRow with _$RuleChangeQueueRow {
  const factory RuleChangeQueueRow({
    /// 🔴 화면 미참조(제출용) — `RuleChangeApprovalSubmission.requestId` 로 그대로.
    required String requestId,
    required String categoryLabel,
    required String hashText,

    /// «MM-DD HH:mm 요청»(엔진).
    required String requestedText,

    /// 냉각 글자(엔진 · «냉각 중 — MM-DD HH:mm 이후 승인» · «냉각 끝»).
    required String coolingText,

    /// 상태 글자(엔진).
    required String stateLabel,
    required UiLevel level,

    /// 승인 폼 버튼 글자(엔진 · non-null ⇔ 지금 승인 판정이 냉각·창·DD 에 걸리지 않음). null = 승인 폼 0.
    String? approveLabel,

    /// 취소(엔진 완성 `run(ruleChangeCancel{request_id})`). null = 취소 0.
    SafetyActionCall? cancel,
  }) = _RuleChangeQueueRow;

  factory RuleChangeQueueRow.fromJson(Map<String, dynamic> json) =>
      _$RuleChangeQueueRowFromJson(json);
}
// JSON 키: request_id · category_label · hash_text · requested_text · cooling_text · state_label · level · approve_label · cancel
