// packages/ui_analytics/lib/src/screens/contribution_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-3b 슬리브 기여 분해 본문 뷰 (Scaffold·AppBar 는 셸 소유)
class ContributionScreen extends ConsumerWidget {
  const ContributionScreen({super.key, required this.range});

  final DateRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(contributionProvider(range));
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
              ref.invalidate(contributionProvider(range));
            },
            child: const Text(AnalyticsLabels.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ContributionVm vm,
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
              ..._buildRows(context, vm.rows),
              const SizedBox(height: 16),
              _buildNotes(context, vm),
              const SizedBox(height: 16),
              _buildFooter(context, vm),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ContributionVm vm) {
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

  List<Widget> _buildRows(BuildContext context, List<ContributionRow> rows) {
    final colorScheme = Theme.of(context).colorScheme;
    return rows.map((row) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    row.contributionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  height: 12.0,
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: row.normalized.clamp(0.0, 1.0),
                    child: Container(color: colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNotes(BuildContext context, ContributionVm vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vm.methodNoteText,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        if (vm.fxNoteText != null && vm.fxNoteText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            vm.fxNoteText!,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ContributionVm vm) {
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
