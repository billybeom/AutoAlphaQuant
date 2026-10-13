// packages/ui_analytics/lib/src/screens/rebalance_event_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-6b 리밸런싱 회차 상세 본문 뷰(공개 위젯 — 본문만).
///
/// 회차 id 는 구독 키로만 쓰고 화면에 그리지 않는다.
class RebalanceEventScreen extends ConsumerStatefulWidget {
  const RebalanceEventScreen({super.key, required this.rebalanceEventId});

  final String rebalanceEventId;

  @override
  ConsumerState<RebalanceEventScreen> createState() =>
      _RebalanceEventScreenState();
}

class _RebalanceEventScreenState extends ConsumerState<RebalanceEventScreen> {
  bool _snapshotOpen = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RebalanceEvent> asyncValue = ref.watch(
      rebalanceEventProvider(widget.rebalanceEventId),
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
            onRetry: () =>
                ref.invalidate(rebalanceEventProvider(widget.rebalanceEventId)),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (RebalanceEvent event) =>
          _buildContent(context, event, activeFlags),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RebalanceEvent event,
    List<BlockFlag> activeFlags,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ExecutionQuality? quality = event.quality;
    final LinkAction? link = event.journalTimelineLink;
    return Column(
      key: const Key('s76b-root'),
      children: <Widget>[
        StaleBanner(asOf: event.asOf),
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(event.tradeDate.yyyyMmDd),
                  Chip(label: Text(event.kindLabel)),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                key: const Key('s76b-before'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(AnalyticsLabels.rebalanceBeforeHeader),
                  for (final SleeveWeight w in event.before) Text(w.label),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                key: const Key('s76b-after'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(AnalyticsLabels.rebalanceAfterHeader),
                  for (final SleeveWeight w in event.after) Text(w.label),
                ],
              ),
              if (event.thresholds.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Column(
                  key: const Key('s76b-thresholds'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(AnalyticsLabels.rebalanceThresholdsHeader),
                    for (final ThresholdCompare t in event.thresholds)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(t.metricLabel)),
                            Expanded(child: Text(t.observedText)),
                            Expanded(child: Text(t.thresholdText)),
                            Expanded(child: Text(t.verdictLabel)),
                            if (t.passed)
                              const Icon(Icons.check, size: 16)
                            else
                              Icon(
                                Icons.remove,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                key: const Key('s76b-snapshot'),
                onPressed: () => setState(() => _snapshotOpen = !_snapshotOpen),
                child: const Text(AnalyticsLabels.rebalanceSnapshotHeader),
              ),
              if (_snapshotOpen) ...<Widget>[
                Text(event.trigger.summary),
                Text(
                  event.trigger.configHash,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (quality != null) ...<Widget>[
                const SizedBox(height: 12),
                Card(
                  key: const Key('s76b-quality'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(AnalyticsLabels.rebalanceQualityHeader),
                        Text(quality.slippageText),
                        Text(quality.assumedSlippageText),
                        Text(quality.unfilledRateText),
                        Text(quality.summary),
                      ],
                    ),
                  ),
                ),
              ],
              if (link != null)
                TextButton(
                  key: const Key('s76b-link-journalTimelineLink'),
                  onPressed: () {
                    ref.read(analyticsLinkOpenerProvider).open(link.deepLink);
                  },
                  child: Text(link.label),
                ),
              const SizedBox(height: 8),
              Text(event.asOf.label, key: const Key('s76b-asof')),
            ],
          ),
        ),
      ],
    );
  }
}
