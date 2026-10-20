// 01 §3-1 — `exit_kind` 6종. `decision_log.exit_kind` CHECK 와 문자 그대로 일치한다.
//
// 🔴 이 파일은 «어떤 코드가 오는가»의 목록이다. 문구(«TIER 1B 절대손절 −7.0% 도달»)는
//    엔진이 만들어 DTO 의 label·reason 필드에 실어 준다 — 화면이 코드로 문구를 고르면 C-5 위반이다.
// 🔵 v2.31 P0S 에서는 대부분 비집행이지만 코드는 보존한다(01 §3-1 표제).
// 🆕 v1.8(01 §17) — 파일 끝 `StopTierCodes`(손절선 등급 · `byDomain 'stop_tier'`) — 배럴 import·export 무변경.

/// `exit_kind` — 청산 사유의 갈래(01 §3-1 · `decision_log.exit_kind` CHECK).
abstract final class ExitKindCodes {
  /// TIER 0 기업행위 청산 — 쿨다운 영구(재진입 불가).
  static const String corporate = 'CORPORATE';

  /// TIER 1A·1B 손절.
  static const String stop = 'STOP';

  /// TIER 1.5·2 추세 이탈.
  static const String trendBreak = 'TREND_BREAK';

  /// TIER 3 목표가 도달.
  static const String target = 'TARGET';

  /// 정기 교체.
  static const String rebalance = 'REBALANCE';

  /// 브레이커·한도·대사·킬스위치에 의한 시스템 게이트 청산.
  static const String risk = 'RISK';

  /// 전량 — 픽스처·C-15 대조용. 🔴 `decision_log.exit_kind` CHECK 와 같은 집합이어야 한다.
  static const Set<String> values = <String>{
    corporate,
    stop,
    trendBreak,
    target,
    rebalance,
    risk,
  };
}

/// 🆕 v1.8(01 §17) — `StopLineNormalized.tierCode` 의 값(m2-8 E-8 «코드 목록은 영역 E 의 사전»의 실물).
/// 🔴 키 전용 — 화면은 표시·분기하지 않는다(문구 = `tierLabel`).
abstract final class StopTierCodes {
  static const String tier1a = 'TIER_1A';
  static const String tier1b = 'TIER_1B';
  static const String tier2 = 'TIER_2';
  static const Set<String> values = <String>{tier1a, tier1b, tier2};
}
