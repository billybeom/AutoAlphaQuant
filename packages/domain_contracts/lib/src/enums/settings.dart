// 01 §4-1 · 05 §1 — M9 설정 3등급(🆕 계약 v1.18 · 01 §27 · K-o).
//
// 🔴 등급은 엔진(M2·M4)이 정한다 — 화면은 이 값으로 **자물쇠 아이콘·묶음 머리**만 고른다(`general` = 자물쇠 0).
//    등급별 마찰(즉시 반영 · 진입 생체 · 냉각 30일·12월 창)은 화면이 아니라 엔진·M5 게이트의 일이다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 05 §1 — 설정 등급.
enum SettingTier {
  @JsonValue('GENERAL')
  general('GENERAL'),
  @JsonValue('OPERATIONAL')
  operational('OPERATIONAL'),
  @JsonValue('RULE')
  rule('RULE');

  const SettingTier(this.wire);

  /// JSON 표기(DDL 대응 컬럼 없음 — 뷰모델 전용).
  final String wire;
}
