// packages/ui_analytics/lib/l10n/labels.dart
//
// 🔴 정적 UI 라벨 단일 소스 (01 §1-5, C-5 규약)
// 데이터와 상태에 따라 바뀌지 않는 정적 텍스트만 상수로 모읍니다.
// 사유 문구·판정·상태 라벨은 뷰모델/DTO 필드를 그대로 렌더링합니다.

abstract final class AnalyticsLabels {
  /// 신선도 배너 제목 (본문은 AsOf.staleLabel 사용)
  static const String staleBannerTitle = '오래된 데이터';

  /// 에러 상태 재시도 버튼
  static const String retryButton = '다시 시도';
}
