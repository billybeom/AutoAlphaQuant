// packages/ui_analytics/lib/src/screens/drawdown_context_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-3 드로다운·TUW 컨텍스트 본문 뷰 (Scaffold·AppBar 는 셸 소유)
class DrawdownContextScreen extends ConsumerWidget {
  const DrawdownContextScreen({super.key, this.range});

  final DateRange? range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(drawdownContextProvider(range));
    final safetyAsync = ref.watch(safetyStateStreamProvider);
    final activeFlags =
        safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];

    return asyncValue.when(
      loading: _buildSkeletonLoader,
      error: (err, stack) =>
          _buildErrorState(ref, asyncValue.valueOrNull?.asOf.label),
      data: (vm) => _buildContent(context, vm, activeFlags),
    );
  }

  static Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 4,
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
              ref.invalidate(drawdownContextProvider(range));
            },
            child: const Text(AnalyticsLabels.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DrawdownContextVm vm,
    List<BlockFlag> activeFlags,
  ) {
    return Column(
      children: [
        StaleBanner(asOf: vm.asOf),
        SafetyBlockBanner(activeFlags: activeFlags),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(context, vm),
              const SizedBox(height: 16),
              _buildMetricCards(context, vm),
              const SizedBox(height: 16),
              _buildGaugeCard(context, vm),
              const SizedBox(height: 16),
              _buildFooter(context, vm),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, DrawdownContextVm vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vm.periodLabel,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          vm.asOf.label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildMetricCards(BuildContext context, DrawdownContextVm vm) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleMetricCard(
            context,
            AnalyticsLabels.currentDdTitle,
            vm.currentDdText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleMetricCard(
            context,
            AnalyticsLabels.maxDdTitle,
            vm.maxDdText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSingleMetricCard(
            context,
            AnalyticsLabels.tuwTitle,
            vm.tuwText,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleMetricCard(
    BuildContext context,
    String title,
    String valueText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeCard(BuildContext context, DrawdownContextVm vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.referenceBandText != null &&
                vm.referenceBandText!.isNotEmpty) ...[
              Text(
                vm.referenceBandText!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Container(
                height: 16.0,
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: vm.ddNormalized.clamp(0.0, 1.0),
                  child: Container(color: colorScheme.primary),
                ),
              ),
            ),
            if (vm.referenceBandCaveatText != null &&
                vm.referenceBandCaveatText!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                vm.referenceBandCaveatText!,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, DrawdownContextVm vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        vm.asOf.label,
        style: TextStyle(fontSize: 11, color: colorScheme.outline),
      ),
    );
  }
}
