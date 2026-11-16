// 🆕 계약 v1.22(01 §31 · K67) — 모드 표지 글자. 🔴 표지 글자 상수라 C-5 사전 대상(`lib/src/labels/`) 밖에 둔다(C-5 예외 0).

/// 모드 표지 글자(엔진 core `ops/mode_marker.dart:11-20` · 셸 `ui_shell/lib/l10n/labels.dart:31-32`
/// 두 벌 → 한 벌). 🔴 «코드 → 문구» 사전이 아니다 — 표지 글자 상수(사전 도메인 0 · byDomain 0).
/// 소비 이전 = 엔진 다음 조각 · 셸 = 다음 test-only/PNG 창.
abstract final class ModeMarkerText {
  /// 모의 표지.
  static const String sim = '모의투자';

  /// 투자 안내(X7) 표지.
  static const String advisory = '투자 안내';

  /// OS 알림·다이제스트 제목 접두 — 모의(앱 안 화면은 셸 띠가 덮는다 — 이중 표지 0).
  static const String osSimPrefix = '[모의]';

  /// OS 알림·다이제스트 제목 접두 — 투자 안내.
  static const String osAdvisoryPrefix = '[안내]';
}
