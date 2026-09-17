// packages/ui_analytics/lib/l10n/labels.dart
//
// 🔴 정적 UI 라벨 단일 소스 (01 §1-5, C-5 규약)
// 데이터와 상태에 따라 바뀌지 않는 불변 문자열만 상수로 모읍니다.
// 사유 문구·판정·상태 라벨은 뷰모델/DTO 필드를 그대로 사용합니다.

abstract final class AnalyticsLabels {
  /// 헤더 및 네비게이션
  static const String reportArchiveButton = '지난 리포트';
  static const String detailsButton = '자세히';
  static const String retryButton = '다시 시도';
  static const String closeButton = '닫기';

  /// 신선도 배너 제목 (본문은 AsOf.staleLabel 사용)
  static const String staleBannerTitle = '오래된 데이터';

  /// 차단 상태 수치 가림 기호 (03 §1-4)
  static const String maskedIntegrity = '***';
  static const String maskedReconMismatch = '?';

  /// 빈 상태 기본 폴백 (emptyLabel 미제공 시)
  static const String emptyReportDefault = '리포트 없음';
}
