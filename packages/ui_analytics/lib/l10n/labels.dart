// packages/ui_analytics/lib/l10n/labels.dart

abstract final class AnalyticsLabels {
  static const String retryButton = '다시 시도';
  static const String staleBannerTitle = '오래된 데이터';
  static const String detailButton = '자세히';
  static const String actionViewButton = '조치 보기';
  static const String pastReportsButton = '지난 리포트';

  // ── 🆕 R10b — S7-2G ───────────────────────────────────────────────────────
  static const String gateBackButton = '돌아가기';
  static const String gateContinueButton = '그래도 보기';
  static const String recordNotAccepted = '열람 기록이 접수되지 않았습니다. 화면은 열리지 않았습니다.';

  // ── 🆕 R10c — S7-2 ──
  static const String metricTwr = '시간가중';
  static const String metricMwr = '금액가중';
  static const String granularityDaily = '일';
  static const String granularityMonthly = '월';
  static const String granularityYearly = '년';
  static const String cumulativeOn = '누적';
  static const String cumulativeOff = '기간별';
  static const String valuesShowButton = '값 보기';
  static const String valuesHideButton = '값 접기';
  static const String valuesColumnMain = '내 계좌';
  static const String valuesColumnBenchmark = '비교 기준';
  static const String drawdownLinkButton = '낙폭 맥락 보기';
  static const String contributionLinkButton = '슬리브 기여 보기';
}
