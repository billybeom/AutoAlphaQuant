// packages/ui_analytics/lib/src/screens/annual_review_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-7 12월 연간 리뷰 본문 뷰(공개 위젯 — 본문만).
class AnnualReviewScreen extends ConsumerStatefulWidget {
  const AnnualReviewScreen({super.key});

  @override
  ConsumerState<AnnualReviewScreen> createState() => _AnnualReviewScreenState();
}

class _AnnualReviewScreenState extends ConsumerState<AnnualReviewScreen> {
  bool _cfOpen = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AnnualReviewVm> asyncValue = ref.watch(
      annualReviewProvider,
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
            onRetry: () => ref.invalidate(annualReviewProvider),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (AnnualReviewVm vm) {
        return Column(
          key: const Key('s77-root'),
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
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(vm.yearLabel, key: const Key('s77-year')),
                  const SizedBox(height: 4),
                  Text(vm.windowStateLabel, key: const Key('s77-window')),
                  const SizedBox(height: 8),
                  if (vm.afterTax != null) _buildAfterTaxBlock(vm),
                  for (final (int i, AnnualReviewSection section)
                      in vm.sections.indexed)
                    _buildSection(i, section),
                  const SizedBox(height: 8),
                  Text(vm.asOf.label, key: const Key('s77-asof')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAfterTaxBlock(AnnualReviewVm vm) {
    final AfterTaxLadder ladder = vm.afterTax!;
    return Card(
      key: const Key('s77-aftertax'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(ladder.branchLabel),
            const SizedBox(height: 4),
            for (final (int i, AfterTaxStep step) in ladder.steps.indexed)
              _buildStep(i, step),
            Text(ladder.honestExpectationLine),
            Text(ladder.basisNote),
            if (ladder.referenceOnlyLabel != null)
              Text(ladder.referenceOnlyLabel!),
            if (vm.afterTaxCounterfactual != null)
              _buildCounterfactual(vm.afterTaxCounterfactual!),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int i, AfterTaxStep step) {
    return Column(
      key: ValueKey<String>('s77-step-$i'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(step.label),
        Text(step.valueText),
        if (step.noteLine != null) Text(step.noteLine!),
      ],
    );
  }

  Widget _buildCounterfactual(AfterTaxLadder cf) {
    return Card(
      key: const Key('s77-cf'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: const Key('s77-cf-toggle'),
            onTap: () => setState(() => _cfOpen = !_cfOpen),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(cf.branchLabel)),
                  Icon(_cfOpen ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_cfOpen)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (int i, AfterTaxStep step) in cf.steps.indexed)
                    _buildStep(i, step),
                  Text(cf.honestExpectationLine),
                  Text(cf.basisNote),
                  if (cf.referenceOnlyLabel != null)
                    Text(cf.referenceOnlyLabel!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(int i, AnnualReviewSection section) {
    final String? route = section.route;
    return Card(
      key: ValueKey<String>('s77-section-$i'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(section.title),
            for (final String line in section.lines) Text(line),
            if (route != null)
              TextButton(
                onPressed: () {
                  ref.read(analyticsLinkOpenerProvider).open(route);
                },
                child: const Text(AnalyticsLabels.detailButton),
              ),
          ],
        ),
      ),
    );
  }
}
