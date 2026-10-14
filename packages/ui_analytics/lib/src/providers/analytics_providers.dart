// packages/ui_analytics/lib/src/providers/analytics_providers.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 주입 창구 — 조립 앱(apps/*)에서 ProviderScope overrides로 주입 (01 §1-3, §4-1, §4-4)
final Provider<Clock> analyticsClockProvider = Provider<Clock>((ref) {
  throw UnimplementedError('analyticsClockProvider must be overridden');
});

final Provider<AppLinkOpener> analyticsLinkOpenerProvider =
    Provider<AppLinkOpener>((ref) {
      throw UnimplementedError(
        'analyticsLinkOpenerProvider must be overridden',
      );
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

/// S7-3 드로다운 맥락 FutureProvider (family)
final FutureProviderFamily<DrawdownContextVm, DateRange?>
drawdownContextProvider = FutureProvider.family<DrawdownContextVm, DateRange?>((
  ref,
  range,
) async {
  final repository = ref.watch(performanceRepositoryProvider);
  return repository.drawdownContext(range: range);
});

/// S7-3b 슬리브 기여 분해 FutureProvider (family)
final FutureProviderFamily<ContributionVm, DateRange> contributionProvider =
    FutureProvider.family<ContributionVm, DateRange>((ref, range) async {
      final repository = ref.watch(performanceRepositoryProvider);
      return repository.contribution(range: range);
    });

/// S7-1b 리포트 아카이브 — 01 §4-1
final AutoDisposeFutureProvider<ReportArchiveVm> reportArchiveProvider =
    FutureProvider.autoDispose<ReportArchiveVm>((ref) {
      return ref.watch(performanceRepositoryProvider).reportArchive();
    });

// ── 🆕 R10b — S7-2G ────────────────────────────────────────────────────────

/// S7-2G 열람 게이트 — CommandApi 주입 창구(뷰어 허용 4종만 부르는 화면 · 01 §13-9 · 🆕 v1.4 §14-2 정정 5→4)
final Provider<CommandApi> analyticsCommandApiProvider = Provider<CommandApi>((
  ref,
) {
  throw UnimplementedError('analyticsCommandApiProvider must be overridden');
});

/// S7-2G 열람 게이트 스트림 (월→일→월 전환에서 호출 0 방지)
final AutoDisposeStreamProvider<DisclosureGateVm> disclosureGateProvider =
    StreamProvider.autoDispose<DisclosureGateVm>((ref) {
      return ref.watch(performanceRepositoryProvider).watchDisclosureGate();
    });

/// S7-2 성과 시리즈 쿼리 키
typedef PerfSeriesQuery = ({
  PerfMetric metric,
  PerfGranularity granularity,
  bool cumulative,
});

/// S7-2 성과 시리즈 (월→일→월 전환에서 호출 0 방지)
final AutoDisposeFutureProviderFamily<PerformanceSeries, PerfSeriesQuery>
performanceSeriesProvider = FutureProvider.autoDispose
    .family<PerformanceSeries, PerfSeriesQuery>((ref, query) {
      return ref
          .watch(performanceRepositoryProvider)
          .series(
            metric: query.metric,
            granularity: query.granularity,
            cumulative: query.cumulative,
          );
    });

// ── 🆕 R11b — S7-9 ──
/// S7-9 목표 경로 — 받은 달 그대로(01 §14-9)
final AutoDisposeFutureProviderFamily<GoalPathVm, String> goalPathProvider =
    FutureProvider.autoDispose.family<GoalPathVm, String>((ref, yyyyMm) {
      return ref.watch(performanceRepositoryProvider).goalPath(yyyyMm: yyyyMm);
    });

// ── 🆕 R12a — S7-6a·S7-6b ──
/// S7-6a·S7-6b 리밸런싱 읽기 창구 — 조립 앱이 주입한다(01 §15-4)
final Provider<RebalanceRepository> rebalanceRepositoryProvider =
    Provider<RebalanceRepository>((ref) {
      throw UnimplementedError(
        'rebalanceRepositoryProvider must be overridden',
      );
    });

/// S7-6a 회차 타임라인 — 인자 없이 부른다(전체 기간 · 01 §15-4)
final AutoDisposeStreamProvider<ListResult<RebalanceEvent>>
rebalanceEventsProvider =
    StreamProvider.autoDispose<ListResult<RebalanceEvent>>((ref) {
      return ref.watch(rebalanceRepositoryProvider).watchEvents();
    });

/// S7-6b 회차 1건 — 받은 id 그대로(01 §15-4)
final AutoDisposeStreamProviderFamily<RebalanceEvent, String>
rebalanceEventProvider = StreamProvider.autoDispose
    .family<RebalanceEvent, String>((ref, rebalanceEventId) {
      return ref
          .watch(rebalanceRepositoryProvider)
          .watchEvent(rebalanceEventId);
    });

// ── 🆕 R12b — S7-6c ──
/// S7-6c 지금 기준 초안 — 미리보기 계산 주입 창구(뷰어 셸 = null = 카운트다운만 · 01 §15-4)
final Provider<WhatIfApi?> analyticsWhatIfApiProvider = Provider<WhatIfApi?>((
  ref,
) {
  throw UnimplementedError('analyticsWhatIfApiProvider must be overridden');
});

/// S7-6c 다음 리밸런싱 예고 — 인자 없이(01 §15-4)
final AutoDisposeStreamProvider<NextRebalanceVm> nextRebalanceProvider =
    StreamProvider.autoDispose<NextRebalanceVm>((ref) {
      return ref.watch(rebalanceRepositoryProvider).watchNext();
    });
