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

  // ── 🆕 R11a — S7-4 ──
  static const String plannerIntroLine = '입력한 금액으로 미리보기를 계산합니다';
  static const String plannerCurrentSettingHeader = '현재 설정';
  static const String plannerAmountFieldLabel = '이번에 넣을 금액(원)';
  static const String plannerCalculateButton = '미리보기 계산';
  static const String plannerNextButton = '다음';
  static const String plannerBackButton = '이전';
  static const String plannerStepAmountTitle = '금액';
  static const String plannerStepAllocationTitle = '배분·계좌';
  static const String plannerStepResultTitle = '결과';
  static const String plannerPensionLimitTitle = '연금 납입 한도';
  static const String plannerCostsHeader = '예상 비용';
  static const String plannerFundingHeader = '연금 납입 조달 순서';
  static const String plannerRecalculateButton = '다시 계산';
  static const String plannerRegisterButton = '이 계획으로 입금 등록';
  static const String plannerRegisterNotAccepted =
      '등록 요청이 접수되지 않았습니다. 계획은 그대로 있습니다.';

  // ── 🆕 R11b — S7-9 ──
  static const String goalPathDetailButton = '목표 경로 보기';
  static const String goalPathAssumptionHeader = '가정';
  static const String goalPathValuesButton = '숫자로 보기';
  static const String goalPathColumnDate = '날짜';

  // ── 🆕 R12a — S7-6a·S7-6b ──
  static const String rebalanceNextPreviewButton = '다음 예상';
  static const String rebalanceBeforeHeader = '리밸런싱 전';
  static const String rebalanceAfterHeader = '리밸런싱 후';
  static const String rebalanceThresholdsHeader = '임계 대조';
  static const String rebalanceSnapshotHeader = '당시 스냅샷';
  static const String rebalanceQualityHeader = '실행 품질';
}
