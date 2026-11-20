// 01 §37 — 🆕 계약 v1.28 · M9 `S04` 배분 화면 첫 판(보기 전용 · 2026-11-19 발주자 결정 193 ⓐ 프리셋 부재 · 194 ⓐ 앱 첫 판 custom 0).
//
// 🔴 쓰기 0 · 판정 0 · 화면은 받은 글자·차례 그대로(묶음·행 재정렬 0) — 색(`level`) · 잠김 · 빈 상태 칸 0(K198).
// 🔴 폰 · 뷰어 같은 값(창구 = `SettingsRepository.watchAllocationEditor()` · 뷰어 원천 = `rm_config_view` 배분 7열 ·
//    `AllocationReadModelColumns` · 01 §6-4).
// 🔴 엔진 원천 = core `ops/allocation_view.dart`(PR #276 · 엔진 지역 꼴 `AllocationView` — 🔴 이 파일의 이름은 엔진과 다르다 ·
//    `ambiguous_import` 회피 K80). 편집 칸(초안 · 슬라이더 · 미리보기 · 적용 · 프리셋) = 편집기 판 추가형(01 §8 미결 190 · 191 · 194).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../primitives/as_of.dart';

part 'allocation.freezed.dart';
part 'allocation.g.dart';

/// 🆕 v1.28(01 §37 · K197) — `S04` 한 화면. 이름 = M2-8 예약(`AllocationEditorVm`) · 첫 판 = 보기 칸만.
@freezed
abstract class AllocationEditorVm with _$AllocationEditorVm {
  const factory AllocationEditorVm({
    /// 지금 배분(정본 하나 — 193 ⓐ 프리셋 부재).
    required AllocationProfileCard current,

    /// 읽기 묶음(엔진 차례 · 첫 판 = 리밸런싱 밴드 · 리스크 한도 · 금 상한).
    @Default(<AllocationReadOnlySection>[])
    List<AllocationReadOnlySection> sections,

    /// «바꾸는 길» 안내(엔진 차례 · 🔴 링크 0).
    @Default(<String>[]) List<String> changePathLines,
    required AsOf asOf,
  }) = _AllocationEditorVm;

  factory AllocationEditorVm.fromJson(Map<String, dynamic> json) =>
      _$AllocationEditorVmFromJson(json);
}
// JSON 키: current · sections · change_path_lines · as_of

/// 🆕 v1.28(K197) — 지금 배분 카드(엔진 글자 · 백테스트 줄 = M9 손익 금지의 유일한 예외(05 원칙 3) · 🔴 정직 기대 줄과 함께만).
@freezed
abstract class AllocationProfileCard with _$AllocationProfileCard {
  const factory AllocationProfileCard({
    /// 프로파일 글자(S01 카드 상태 줄과 같은 글자 — 엔진).
    required String label,

    /// 비중 한 줄(엔진 · 잔여 C 표기 포함).
    required String weightsText,

    /// 백테스트 근거 한 줄(엔진 · 세금 전 점추정).
    required String backtestText,

    /// 정직 기대 줄(엔진 · 온보딩과 같은 글자).
    required String honestNoteText,
  }) = _AllocationProfileCard;

  factory AllocationProfileCard.fromJson(Map<String, dynamic> json) =>
      _$AllocationProfileCardFromJson(json);
}
// JSON 키: label · weights_text · backtest_text · honest_note_text

/// 🆕 v1.28(K197) — 읽기 묶음(묶음 = 엔진이 짓는다 · 화면이 묶지 않는다).
@freezed
abstract class AllocationReadOnlySection with _$AllocationReadOnlySection {
  const factory AllocationReadOnlySection({
    required String title,
    @Default(<AllocationReadOnlyRow>[]) List<AllocationReadOnlyRow> rows,
  }) = _AllocationReadOnlySection;

  factory AllocationReadOnlySection.fromJson(Map<String, dynamic> json) =>
      _$AllocationReadOnlySectionFromJson(json);
}
// JSON 키: title · rows

/// 🆕 v1.28(K197 · K200) — 읽기 행 하나.
@freezed
abstract class AllocationReadOnlyRow with _$AllocationReadOnlyRow {
  const factory AllocationReadOnlyRow({
    /// 🔴 화면 미참조(시험 · 열 대조) — ∈ `AllocationRowCodes.values` · Key = 순번.
    required String code,
    required String label,
    required String valueText,

    /// 덧붙임 한 줄(엔진). null = 부재.
    String? noteText,
  }) = _AllocationReadOnlyRow;

  factory AllocationReadOnlyRow.fromJson(Map<String, dynamic> json) =>
      _$AllocationReadOnlyRowFromJson(json);
}
// JSON 키: code · label · value_text · note_text (= `rm_config_view.allocation_sections` 행 키 · K201)
