// packages/ui_analytics/lib/src/screens/monthly_report_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';
import '../widgets/trust_badge_view.dart';

/// S7-1 월간 1페이지 리포트 본문 뷰 (Scaffold·AppBar 는 셸 소유)
class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key, required this.yyyyMm});

  final String yyyyMm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider(yyyyMm));
    final safetyAsync = ref.watch(safetyStateStreamProvider);

    final activeFlags =
        safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];

    return reportAsync.when(
      loading: _buildSkeletonLoader,
      error: (err, stack) =>
          _buildErrorState(ref, reportAsync.valueOrNull?.asOf.label),
      data: (report) => _buildContent(context, ref, report, activeFlags),
    );
  }

  static Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 7,
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, String? lastAsOfLabel) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastAsOfLabel != null) ...[
            Text(
              lastAsOfLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
          ],
          const Icon(Icons.error_outline, size: 36, color: Colors.grey),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(monthlyReportProvider(yyyyMm));
            },
            child: const Text(AnalyticsLabels.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MonthlyReport report,
    List<BlockFlag> activeFlags,
  ) {
    return Column(
      children: [
        StaleBanner(asOf: report.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onOpenLink: (link) {
            ref.read(analyticsLinkOpenerProvider).open(link);
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(context, ref, report),
              const SizedBox(height: 16),
              ..._buildReportItems(ref, report.items),
              const SizedBox(height: 20),
              _buildFooter(context, ref, report),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(analyticsLinkOpenerProvider)
                        .open(AppRoutes.reportArchive);
                  },
                  child: const Text(AnalyticsLabels.pastReportsButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    MonthlyReport report,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.yyyyMm,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.asOf.label,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (report.generatedAtText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      report.generatedAtText!,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (report.configHash != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      report.configHash!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TrustBadgeView(
                trust: report.trust,
                onOpenLink: (link) {
                  ref.read(analyticsLinkOpenerProvider).open(link);
                },
              ),
            ),
          ],
        ),
        if (report.pendingNoticeText != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              report.pendingNoticeText!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
        if (report.backdateFootnote != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              report.backdateFootnote!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildReportItems(WidgetRef ref, List<ReportItem> items) {
    return items.map((item) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.noteText != null && item.noteText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          item.noteText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.valueText,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (item.detailDeepLink != null) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          ref
                              .read(analyticsLinkOpenerProvider)
                              .open(item.detailDeepLink!);
                        },
                        child: const Text(
                          AnalyticsLabels.detailButton,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    MonthlyReport report,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.goalLine,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (report.goalDeepLink != null)
            TextButton(
              key: const Key('s71-goal-link'),
              onPressed: () {
                ref
                    .read(analyticsLinkOpenerProvider)
                    .open(report.goalDeepLink!);
              },
              child: const Text(AnalyticsLabels.goalPathDetailButton),
            ),
          const Divider(height: 16),
          Text(
            report.disclosureViewCountText,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            report.asOf.label,
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
