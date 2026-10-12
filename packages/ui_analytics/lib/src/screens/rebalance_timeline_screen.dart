// packages/ui_analytics/lib/src/screens/rebalance_timeline_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-6a 리밸런싱 회차 타임라인 본문 뷰(공개 위젯 — 본문만).
///
/// 행은 받은 순서 그대로 그린다. 기간은 고르지 않는다(전체 기간).
class RebalanceTimelineScreen extends ConsumerWidget {
  const RebalanceTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ListResult<RebalanceEvent>> asyncValue = ref.watch(
      rebalanceEventsProvider,
    );
    final List<BlockFlag> activeFlags =
        ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ??
        const <BlockFlag>[];

    return asyncValue.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[AnalyticsSkeleton()],
      ),
      error: (Object error, StackTrace stack) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AnalyticsErrorView(
            onRetry: () => ref.invalidate(rebalanceEventsProvider),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (ListResult<RebalanceEvent> page) =>
          _buildContent(context, ref, page, activeFlags),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ListResult<RebalanceEvent> page,
    List<BlockFlag> activeFlags,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const Key('s76a-root'),
      children: <Widget>[
        StaleBanner(asOf: page.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onOpenLink: (String flagLink) {
            ref.read(analyticsLinkOpenerProvider).open(flagLink);
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (page.rows.isEmpty) ...<Widget>[
                if (page.emptyLabel != null) Text(page.emptyLabel!),
                TextButton(
                  key: const Key('s76a-empty-next'),
                  onPressed: () {
                    ref
                        .read(analyticsLinkOpenerProvider)
                        .open(AppRoutes.rebalancePreview);
                  },
                  child: const Text(AnalyticsLabels.rebalanceNextPreviewButton),
                ),
              ],
              for (final RebalanceEvent e in page.rows) ...<Widget>[
                if (e.sectionLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      e.sectionLabel!,
                      key: ValueKey<String>('s76a-section-${e.eventId}'),
                    ),
                  ),
                _buildRow(ref, colorScheme, e),
              ],
              const SizedBox(height: 8),
              Text(page.asOf.label),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(WidgetRef ref, ColorScheme colorScheme, RebalanceEvent e) {
    final Widget body = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(e.tradeDate.yyyyMmDd),
              Chip(label: Text(e.kindLabel)),
              if (e.modeLabel != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      e.modeLabel!,
                      key: ValueKey<String>('s76a-mode-${e.eventId}'),
                      style: TextStyle(color: colorScheme.onTertiaryContainer),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(e.trigger.summary),
        ],
      ),
    );
    return Card(
      key: ValueKey<String>('s76a-row-${e.eventId}'),
      clipBehavior: Clip.antiAlias,
      child: e.detailDeepLink != null
          ? InkWell(
              onTap: () {
                ref.read(analyticsLinkOpenerProvider).open(e.detailDeepLink!);
              },
              child: body,
            )
          : body,
    );
  }
}
