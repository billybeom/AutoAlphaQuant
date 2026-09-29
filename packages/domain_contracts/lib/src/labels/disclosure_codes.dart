// 🆕 계약 v1.3(2026-09-28 · R10 선행 M2 보강 · 01 §13-6) — 성과 열람 기록의 «어느 화면인가» 코드.
//
// 🔴 이 파일은 «어떤 **코드**가 오는가»의 목록이지 코드→문구 매핑이 아니다(labels.dart 머리 주석).
//    화면은 이 상수를 `DisclosureViewEvent.surfaceCode` 에 **그대로** 넘긴다 — 문자열을 짓지 않는다.
//    엔진(명령 수신)은 이 목록에 없는 값을 받지 않는다.

/// `DisclosureViewEvent.surfaceCode` 의 값(01 §2-6 · §13-6).
///
/// 🔴 목록은 M2 가 늘린다 — 열람 기록을 남기는 화면이 늘면 여기에 상수를 더한다.
abstract final class DisclosureSurfaceCodes {
  /// `S7-2` 수익률 탐색(게이트 `S7-2G` 의 「그래도 보기」).
  static const String performanceExplore = 'PERFORMANCE_EXPLORE';

  /// 전량 1종.
  static const Set<String> values = <String>{performanceExplore};
}
