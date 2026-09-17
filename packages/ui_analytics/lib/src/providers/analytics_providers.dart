// packages/ui_analytics/lib/src/providers/analytics_providers.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 주입 창구 — 조립 앱(apps/*)에서 ProviderScope overrides로 주입 (01 §1-3, §4-1)
final Provider<Clock> analyticsClockProvider = Provider<Clock>((ref) {
  throw UnimplementedError('analyticsClockProvider must be overridden');
});

final Provider<PerformanceRepository> performanceRepositoryProvider =
    Provider<PerformanceRepository>((ref) {
      throw UnimplementedError(
        'performanceRepositoryProvider must be overridden',
      );
    });

final Provider<SafetyRepository> safetyRepositoryProvider =
    Provider<SafetyRepository>((ref) {
      throw UnimplementedError('safetyRepositoryProvider must be overridden');
    });

/// 안전 상태 스트림 (차단 플래그 구독)
final StreamProvider<SafetyState> safetyStateStreamProvider =
    StreamProvider<SafetyState>((ref) {
      final repository = ref.watch(safetyRepositoryProvider);
      return repository.watchState();
    });

/// 월간 리포트 FutureProvider (family)
final FutureProviderFamily<MonthlyReport, String> monthlyReportProvider =
    FutureProvider.family<MonthlyReport, String>((ref, yyyyMm) async {
      final repository = ref.watch(performanceRepositoryProvider);
      return repository.monthlyReport(yyyyMm);
    });
