// packages/domain_contracts/lib/src/dto/safety_gate.dart
//
// 🆕 계약 v1.21(01 §30) — M5-2 킬스위치 재개 게이트 · M5-8/`O-04` ② 서약 표시 VM.
// 🔴 M5 만 렌더한다(`ui_safety` · 01 §2-10 표 · C-7) · 상태를 바꾸는 경로 = `SafetyActions`(포트) 뿐.
// 🔴 화면은 받은 글자·차례 그대로 그린다 — 단계·남은 시간을 계산하지 않는다(카운트다운 0 · 새 VM 으로만).
// 🔴 7문항 글자 출처 = SPEC v2.40 04 §3-6 ③ «재개판» 원문(발주자 확정 2026-11-04 · 정규화 = 01 §30 K38) —
//    엔진이 같은 상수를 두고 계약 표본과 대조한다(엔진 숙제 · 06 변경 이력 «2026-11-15 · 계약 판 나눔»).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/safety.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';
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
