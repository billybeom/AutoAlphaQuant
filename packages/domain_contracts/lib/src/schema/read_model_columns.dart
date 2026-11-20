// 영역 H — 🆕 계약 v1.28(01 §37 · §6-4 · K201) 읽기 모델 열 이름.
//
// 🔴 `rm_*` DDL 은 손으로 적지 않는다(파생 생성기 06 M4-1 · `ddl/batch_d_supabase.sql` §읽기 모델) — 여기는 **열 이름만** 둔다.
//    뷰어 «열 → VM» 함수(`read_model_client` · 계약만 의존 — 엔진 상수를 못 본다)와 엔진 push 가 같은 글자를 쓰게 하는 자리다.
// 🔴 G-22 — 읽기 모델 열 ⊇ DTO 필수 칸.

/// `rm_config_view` S04 배분 7열(엔진 `RmConfigViewAllocationColumns` 글자 1:1 · 🔴 타입 이름 ≠ 엔진).
/// 규칙 5조 4칸(`row_version` · `lease_epoch` · `pushed_at` · `mode`) · 버전 스탬프 3 = push 층.
abstract final class AllocationReadModelColumns {
  /// 카드 프로파일 글자(text) — `AllocationProfileCard.label`.
  static const String label = 'allocation_label';

  /// 카드 비중 한 줄(text) — `AllocationProfileCard.weightsText`.
  static const String weightsText = 'allocation_weights_text';

  /// 카드 백테스트 한 줄(text) — `AllocationProfileCard.backtestText`.
  static const String backtestText = 'allocation_backtest_text';

  /// 카드 정직 기대 줄(text) — `AllocationProfileCard.honestNoteText`.
  static const String honestNoteText = 'allocation_honest_note_text';

  /// 읽기 묶음(jsonb — `[AllocationReadOnlySection.toJson()]` · 받은 순서).
  static const String sections = 'allocation_sections';

  /// 바꾸는 길 안내(jsonb — 글자 목록 · 받은 순서).
  static const String changePathLines = 'allocation_change_path_lines';

  /// 기준 시각(jsonb — `AsOf.toJson()`).
  static const String asOf = 'allocation_as_of';

  /// 전부(이 차례).
  static const List<String> all = <String>[
    label,
    weightsText,
    backtestText,
    honestNoteText,
    sections,
    changePathLines,
    asOf,
  ];
}
