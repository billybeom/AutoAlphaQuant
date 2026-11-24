// 🆕 계약 v1.39(01 §48 · K345 · 01 §8 미결 188 · 230 ⓑ · 13 §8 R243 P3) — `M5-4` 안전 사건 postmortem 목록 + 쓰기 한 화면.
//
// 🔴 쓰기 = 기존 `SafetyActions.runPostmortem(PostmortemSubmission{incidentId, text})`(v1.22 · 결과 `PostmortemResultCodes` 3 · C-7 표면
//    무변경) — 이 VM 은 «무엇을 · 언제까지 써야 하는가»와 제출에 넘길 [PostmortemRow.incidentId] 원천이다.
// 🔴 행 = 열린 사건 가운데 postmortem 칸이 있는 것(SEV1 STOPPED · SEV2 수동 주문 — 엔진 `openIncidentsOf` + postmortem 칸) · 차례 = 엔진
//    (`compareIncidentUrgency` — 심각도 → 기한 → 연 시각 → id) · 화면은 재정렬 · 거르기 · 세기 0.
// 🔴 한 번만 쓴다(`POSTMORTEM_ALREADY_RECORDED`) — 쓴 행 = [PostmortemRow.writtenText] 읽기 전용 · [PostmortemRow.form] null.
//    SEV1 은 써도 열린 채(닫기 = `M5-3` STOPPED 결정) → [PostmortemRow.nextLink] = `m5StoppedDecision`(본문 있을 때만).
// 🔴 기한 = 엔진 상수(SEV1 3일 · SEV2 7일 — 03_운영 §4-6) · 이 계약에 수치 0 · 글자만(«기한 11-27 18:00» · «기한이 지났습니다»).
// 🔴 뷰어 = 부재(폰 전용 · 읽기 모델 열 0 · `ui_safety` 만).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import '../primitives/as_of.dart';
import 'common.dart';

part 'postmortem.freezed.dart';
part 'postmortem.g.dart';

/// 쓰기 칸 하나(쓸 차례인 행만).
@freezed
abstract class PostmortemForm with _$PostmortemForm {
  const factory PostmortemForm({
    /// «무슨 일이 있었고, 무엇을 바꾸겠습니까?» — 엔진.
    required String promptText,

    /// 입력 칸 안내(엔진) · null = 없음.
    String? hintText,

    /// «한 번만 씁니다 — 고칠 일은 새 저널로» — 엔진 · null = 없음.
    String? noticeText,

    /// 저장 버튼 글자 «postmortem 저장» — 엔진(🔴 칸 이름에 쓰기 동사 0 — C-7).
    required String buttonLabel,
  }) = _PostmortemForm;

  factory PostmortemForm.fromJson(Map<String, dynamic> json) =>
      _$PostmortemFormFromJson(json);
}
// JSON 키: prompt_text · hint_text · notice_text · button_label

/// 사건 한 건.
/// 🔴 불변식(C-72 ⑥): [form] non-null ⇒ [writtenText] null · [incidentId] 빈칸 금지 · [nextLink] 목적지 = `AppRoutes.m5StoppedDecision`.
@freezed
abstract class PostmortemRow with _$PostmortemRow {
  const factory PostmortemRow({
    /// 제출 DTO `PostmortemSubmission.incidentId` 로 그대로 넘긴다 — 🔴 화면 미표시 · 해석 0.
    required String incidentId,

    /// «서킷브레이커 STOPPED» · «수동 주문 1건» — 엔진(금액 0).
    required String title,

    /// «SEV1» · «SEV2» — 엔진 글자(화면은 분기 0).
    required String severityLabel,

    /// 색에만(`blocked` · `act` · `info`).
    required UiLevel level,

    /// «11-20 10:12 발생» — 엔진.
    required String occurredText,

    /// «기한 11-23 10:12» · «기한이 지났습니다» — 엔진 · null = 기한 없음(쓴 행).
    String? dueText,

    /// 기한이 지났다(색 · 정렬 아님 — 정렬은 엔진).
    required bool overdue,

    /// «쓸 차례» · «썼습니다 — STOPPED 결정이 닫습니다» — 엔진.
    required String stateLabel,

    /// 쓴 글(읽기 전용 · 원문 그대로) · null = 아직 안 씀.
    String? writtenText,

    /// 쓰기 칸 · null = 이미 썼다(또는 쓸 수 없는 자리).
    PostmortemForm? form,

    /// SEV1 을 쓴 뒤 «STOPPED 결정으로» — 엔진(목적지 본문 있을 때만) · null = 부재.
    LinkAction? nextLink,
  }) = _PostmortemRow;

  factory PostmortemRow.fromJson(Map<String, dynamic> json) =>
      _$PostmortemRowFromJson(json);
}
// JSON 키: incident_id · title · severity_label · level · occurred_text · due_text · overdue · state_label · written_text · form · next_link

/// `M5-4` 한 화면(목록 + 쓰기).
/// 🔴 불변식(C-72 ⑥): [rows] 빔 ⇔ [emptyLabel] non-null.
@freezed
abstract class PostmortemListVm with _$PostmortemListVm {
  const factory PostmortemListVm({
    /// «써야 할 postmortem 1건» · «써야 할 postmortem 이 없습니다» — 엔진.
    required String headline,
    required UiLevel level,

    /// 차례 = 엔진(심각도 → 기한 → 연 시각 → id).
    required List<PostmortemRow> rows,

    /// 행 0 일 때만 — 엔진.
    String? emptyLabel,
    required AsOf asOf,
  }) = _PostmortemListVm;

  factory PostmortemListVm.fromJson(Map<String, dynamic> json) =>
      _$PostmortemListVmFromJson(json);
}
// JSON 키: headline · level · rows · empty_label · as_of
