// packages/ui_analytics/lib/src/screens/report_archive_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-1b 리포트 아카이브 본문 뷰 (Scaffold·AppBar 는 셸 소유 — key 만 받는다)
class ReportArchiveScreen extends ConsumerWidget {
  const ReportArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(reportArchiveProvider);
    final safetyAsync = ref.watch(safetyStateStreamProvider);
    final activeFlags =
        safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];

    return asyncValue.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16.0),
        children: const <Widget>[AnalyticsSkeleton()],
      ),
      error: (Object err, StackTrace stack) => ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          AnalyticsErrorView(
            onRetry: () => ref.invalidate(reportArchiveProvider),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (ReportArchiveVm vm) =>
          _buildContent(context, ref, vm, activeFlags),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReportArchiveVm vm,
    List<BlockFlag> activeFlags,
  ) {
    return Column(
      children: <Widget>[
        StaleBanner(asOf: vm.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onOpenLink: (String link) {
            ref.read(analyticsLinkOpenerProvider).open(link);
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Text(vm.asOf.label, key: const Key('s71b-asof')),
              if (vm.emptyLabel != null)
                Text(vm.emptyLabel!, key: const Key('s71b-empty')),
              for (final ReportArchiveRow row in vm.rows) ...<Widget>[
                if (row.sectionLabel != null)
                  Text(
                    row.sectionLabel!,
                    key: Key('s71b-section-${row.yyyyMm}'),
                  ),
                _buildRow(context, ref, row),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, ReportArchiveRow row) {
    final colorScheme = Theme.of(context).colorScheme;
    final Widget card = Card(
      key: ValueKey<String>('s71b-row-${row.yyyyMm}'),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          Icon(
            row.generated
                ? Icons.description_outlined
                : Icons.remove_circle_outline,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.label),
                  if (row.reasonLabel != null)
                    Text(
                      row.reasonLabel!,
                      key: Key('s71b-reason-${row.yyyyMm}'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Chip(key: Key('s71b-mode-${row.yyyyMm}'), label: Text(row.modeLabel)),
          if (row.route != null) ...<Widget>[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );

    if (row.route != null) {
      return InkWell(
        onTap: () => ref.read(analyticsLinkOpenerProvider).open(row.route!),
        child: card,
      );
    }
    return card;
  }
}
