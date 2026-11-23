// packages/domain_contracts/lib/src/dto/self_audit.dart
//
// 🆕 계약 v1.37(01 §46 · K318~K323 · 01 §8 미결 224) — `M5-13` 원장 실사 «해소» 게이트 한 화면
//    (창구 = `SelfAuditResolveRepository.watchResolve()` · 라우트 = `AppRoutes.m5SelfAuditResolve`(파라미터 0) · 🔒 `ui_safety`).
// 🔴 해제 경로 = **실사 0오차 통과 하나**(06 M5-13 · D8) — 수동 해제 버튼 · 필드 · 동작 0(M5-5 꼴 · C-70 ③).
//    플래그 `ADVICE_LEDGER_UNVERIFIED` 는 엔진이 0오차 실사를 본 순간 스스로 내린다(화면이 부르는 동작 없음).
// 🔴 `CANON_SELF_REPORT` 차이는 X5 정정 마법사 대상이 아니다(K320) — 행 조치 = «다시 실사하기»(그 달 · 그 계좌 `L-3`) ·
//    차이를 없애는 길 = 기록(`A-3` · `M5-6`) · 정정(`M5-12`) 뒤 다시 실사 · 닫힘 = RESOLVED(ACCEPTED 갈래 0).
// 🔴 보관 명령(`CommandState.heldForIntegrity` · B18) 검토 = **일괄 확정** 하나(K319) — 버림 동작 0(«명령은 사실을 잃지 않는다» 01 §10-8) ·
//    확정 = 엔진 완성 `SafetyActionCall`(`heldCommandsConfirm` · `{review_id}`) 을 화면이 그대로 넘긴다.
// 🔴 폰 전용 · 읽기 모델 열 0(v1.36 `ReadModelTables` 무변경 · K321 ⑤) · 화면은 받은 글자 · 차례 그대로(분기 0).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../commands/safety_actions.dart'; // SafetyActionCall
import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart'; // LinkAction
import 'ledger.dart'; // LedgerDiffRow

part 'self_audit.freezed.dart';
part 'self_audit.g.dart';

/// `M5-13` 원장 실사 해소 게이트 한 화면.
/// 🔴 불변식(엔진 의무 · C-70 ②) — [diffsEmptyLabel] non-null ⇔ [diffs] 빈 · [heldEmptyLabel] non-null ⇔ [heldCommands] 빈 ·
///    [confirmHeld] non-null ⇒ [heldCommands] 비지 않음 ∧ [heldBlockedText] null ∧ id = `heldCommandsConfirm` ∧ args 키 = {`review_id`} ·
///    [heldBlockedText] non-null ⇒ [confirmHeld] null ∧ [heldCommands] 비지 않음 · [counterLines] 길이 ∈ {0, 2}(투자 안내 모드 = 2 ·
///    미처리 갭 → 실사 갭 차례 · 그 밖 = 0) · [diffs] 행 = `CANON_SELF_REPORT` ∧ 열림 · [auditLinks] 목적지 = `L-3`(그 달 · 그 계좌).
@freezed
abstract class SelfAuditResolveVm with _$SelfAuditResolveVm {
  const factory SelfAuditResolveVm({
    /// 머리(엔진 — «신규 진입 안내가 멈춰 있습니다» · «원장 미검증 표식이 없습니다»).
    required String headline,
    required UiLevel level,

    /// 플래그 상태 한 줄(엔진 — 언제부터 · 무엇을 막는지 · 청산 · 방어 안내는 그대로라는 사실).
    required String flagLine,

    /// 해제 규칙 문장(엔진 — «대응 계좌의 실사가 0오차로 통과하면 풀립니다 · 수동 해제는 없습니다»).
    required String releaseRuleText,

    /// 두 카운터(B22 · X7-3) — 받은 차례 = [미처리 갭, 실사 갭] · 엔진 완성 문장 · 투자 안내 모드가 아니면 빈 목록.
    @Default(<String>[]) List<String> counterLines,

    /// 열린 `CANON_SELF_REPORT` 차이(`L-1` 과 같은 엔진 사전 · 받은 차례) — 행 `actionLink` = «다시 실사하기»(폰 · 그 달 · 그 계좌 `L-3`).
    @Default(<LedgerDiffRow>[]) List<LedgerDiffRow> diffs,

    /// «열린 차이가 없습니다»(엔진) — non-null ⇔ [diffs] 빈.
    String? diffsEmptyLabel,

    /// 0오차 실사가 아직 필요한 계좌(엔진 차례) — «연금저축 계좌 실사 하기» → `aaq://ledger/self-report/<yyyy-MM>/<별칭>`.
    @Default(<LinkAction>[]) List<LinkAction> auditLinks,

    /// 보관 명령(`HELD_FOR_INTEGRITY` · 받은 차례 = 접수 차례).
    @Default(<HeldCommandRow>[]) List<HeldCommandRow> heldCommands,

    /// «보관된 명령이 없습니다»(엔진) — non-null ⇔ [heldCommands] 빈.
    String? heldEmptyLabel,

    /// 일괄 확정(엔진 완성 · `SafetyActionId.heldCommandsConfirm` · `{review_id}`) — null = 확정할 것 없음 또는 무결성 점검 중.
    SafetyActionCall? confirmHeld,

    /// «원장 무결성 점검이 끝나야 확정할 수 있습니다»(엔진) — non-null ⇒ [confirmHeld] null.
    String? heldBlockedText,
    required AsOf asOf,
  }) = _SelfAuditResolveVm;

  factory SelfAuditResolveVm.fromJson(Map<String, dynamic> json) =>
      _$SelfAuditResolveVmFromJson(json);
}
// JSON 키: headline · level · flag_line · release_rule_text · counter_lines · diffs · diffs_empty_label · audit_links ·
//         held_commands · held_empty_label · confirm_held · held_blocked_text · as_of

/// 🆕 v1.37(K318) — 보관 명령 한 행(사람이 낸 사실 — 엔진이 계산한 값이 아니라 가림 대상 아님 · 01 §10-8 B18).
@freezed
abstract class HeldCommandRow with _$HeldCommandRow {
  const factory HeldCommandRow({
    /// 🔴 화면 미참조(시험 · Key) — `command_inbox.command_id`.
    required String commandId,

    /// «수기 체결 기록» · «실입금 등록» · «정기 실사 제출»(엔진 — 명령 종류 글자).
    required String kindLabel,

    /// 한 줄 요약(엔진 — «069500 매수 3주 · 2026-09-02 체결» 꼴).
    required String summaryText,

    /// «2026-09-02 10:14 접수»(엔진).
    required String receivedAtText,

    /// «보관 — 무결성 점검 뒤 확정»(엔진 · `CommandState` 짝 글자).
    required String stateLabel,
  }) = _HeldCommandRow;

  factory HeldCommandRow.fromJson(Map<String, dynamic> json) =>
      _$HeldCommandRowFromJson(json);
}
// JSON 키: command_id · kind_label · summary_text · received_at_text · state_label
