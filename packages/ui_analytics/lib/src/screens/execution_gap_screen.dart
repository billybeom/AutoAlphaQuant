import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';
import '../widgets/trust_badge_view.dart';

class ExecutionGapScreen extends ConsumerWidget {
  const ExecutionGapScreen({super.key, this.yyyyMm});

  final String? yyyyMm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ExecutionGapResult> asyncValue = ref.watch(
      executionGapProvider(yyyyMm),
    );
    final List<BlockFlag> activeFlags =
        ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ??
        const <BlockFlag>[];

    return asyncValue.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[AnalyticsSkeleton()],
      ),
      error: (Object error, StackTrace? stack) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AnalyticsErrorView(
            onRetry: () => ref.invalidate(executionGapProvider(yyyyMm)),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (ExecutionGapResult result) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final ExecutionGapReport? report = result.report;

        return Column(
          key: const Key('s710-root'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StaleBanner(asOf: result.asOf),
            SafetyBlockBanner(
              activeFlags: activeFlags,
              onOpenLink: (String link) {
                ref.read(analyticsLinkOpenerProvider).open(link);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (report != null) ...<Widget>[
                    Text(report.periodLabel),
                    const SizedBox(height: 8),
                    TrustBadgeView(
                      trust: report.trust,
                      onOpenLink: (String link) {
                        ref.read(analyticsLinkOpenerProvider).open(link);
                      },
                    ),
                    if (report.complianceRateNormalized != null) ...<Widget>[
                      const SizedBox(height: 12),
                      SizedBox(
                        key: const Key('s710-gauge'),
                        height: 8,
                        child: ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: report.complianceRateNormalized!.clamp(
                              0.0,
                              1.0,
                            ),
                            child: ColoredBox(color: colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(report.complianceRateLabel),
                    const SizedBox(height: 8),
                    for (final (int i, String line)
                        in report.countLines.indexed)
                      Text(line, key: ValueKey<String>('s710-count-$i')),
                    const SizedBox(height: 8),
                    Text(report.medianDelayLabel),
                    const SizedBox(height: 8),
                    Text(report.priceGapLabel),
                    const SizedBox(height: 8),
                    for (final (int i, String line)
                        in report.correctionLines.indexed)
                      Text(line, key: ValueKey<String>('s710-correction-$i')),
                    const SizedBox(height: 8),
                    Text(report.amendChainMaxLabel),
                    if (report.skipReasonBuckets.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(AnalyticsLabels.executionGapSkipReasonsHeader),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: <Widget>[
                          for (final ReasonChip chip
                              in report.skipReasonBuckets)
                            Chip(
                              label: Text(chip.label),
                              backgroundColor: _toneColor(
                                colorScheme,
                                chip.tone,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (report.selectiveExecutionChips.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: <Widget>[
                          for (final ReasonChip chip
                              in report.selectiveExecutionChips)
                            Chip(
                              label: Text(chip.label),
                              backgroundColor: _toneColor(
                                colorScheme,
                                chip.tone,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (report.modeAdviceLine != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        report.modeAdviceLine!,
                        key: const Key('s710-advice'),
                      ),
                    ],
                  ] else ...<Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          result.emptyLabel!,
                          key: const Key('s710-empty'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(result.asOf.label, key: const Key('s710-asof')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _toneColor(ColorScheme scheme, ChipTone tone) => switch (tone) {
    ChipTone.neutral => scheme.surfaceContainerHighest,
    ChipTone.caution => scheme.errorContainer,
    ChipTone.blocked => scheme.error,
    ChipTone.prevented => scheme.surfaceContainerHighest,
  };
}
