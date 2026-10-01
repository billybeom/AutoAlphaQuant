// packages/ui_analytics/lib/src/screens/goal_path_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../goal_path/goal_path_chart.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-9 목표 금액 경로 본문 뷰(공개 위젯 — 본문만).
class GoalPathScreen extends ConsumerStatefulWidget {
  const GoalPathScreen({super.key, required this.yyyyMm});

  final String yyyyMm;

  @override
  ConsumerState<GoalPathScreen> createState() => _GoalPathScreenState();
}

class _GoalPathScreenState extends ConsumerState<GoalPathScreen> {
  bool _valuesOpen = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<GoalPathVm> asyncValue = ref.watch(
      goalPathProvider(widget.yyyyMm),
    );
    final List<BlockFlag> activeFlags =
        ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ??
        const <BlockFlag>[];

    return asyncValue.when(
      loading:
          () => ListView(
            padding: const EdgeInsets.all(16),
            children: const <Widget>[AnalyticsSkeleton()],
          ),
      error:
          (Object error, StackTrace stack) => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AnalyticsErrorView(
                onRetry: () => ref.invalidate(goalPathProvider(widget.yyyyMm)),
                lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
              ),
            ],
          ),
      data: (GoalPathVm vm) => _buildContent(context, vm, activeFlags),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GoalPathVm vm,
    List<BlockFlag> activeFlags,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: ValueKey<String>('s79-${vm.yyyyMm}'),
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
              Text(vm.asOf.label, key: const Key('s79-asof')),
              const SizedBox(height: 8),
              Text(vm.judgementText, key: const Key('s79-judgement')),
              const SizedBox(height: 4),
              Text(vm.basisText, key: const Key('s79-basis')),
              const SizedBox(height: 4),
              if (vm.deviationText != null)
                Text(vm.deviationText!, key: const Key('s79-deviation')),
              const SizedBox(height: 8),
              Text(vm.periodLabel, key: const Key('s79-period')),
              const SizedBox(height: 8),
              if (vm.chartUnavailableLabel == null) ...<Widget>[
                GoalPathChart(path: vm),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: GoalPathChart.plotInsetLeft),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          vm.actual.first.dateText,
                          key: const Key('s79-x-first'),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          vm.actual.last.dateText,
                          key: const Key('s79-x-last'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 24,
                      height: 3,
                      child: ColoredBox(color: colorScheme.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.actualLabel,
                        key: const Key('s79-legend-actual'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 6,
                      height: 2,
                      child: ColoredBox(color: colorScheme.tertiary),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 6,
                      height: 2,
                      child: ColoredBox(color: colorScheme.tertiary),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 6,
                      height: 2,
                      child: ColoredBox(color: colorScheme.tertiary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.plannedLabel,
                        key: const Key('s79-legend-planned'),
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < vm.segments.length; i++)
                  if (vm.segments[i].kind != SegmentKind.measured)
                    Text(
                      vm.segments[i].label,
                      key: ValueKey<String>('s79-segment-caption-$i'),
                    ),
                const SizedBox(height: 8),
                _buildValuesSection(vm),
              ] else ...<Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      vm.chartUnavailableLabel!,
                      key: const Key('s79-unavailable'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AnalyticsLabels.goalPathAssumptionHeader,
                        key: const Key('s79-assumption-header'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vm.backtestBasisText,
                        key: const Key('s79-backtest-basis'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vm.startingCapitalAssumptionText,
                        key: const Key('s79-starting-capital'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vm.honestExpectationText,
                key: const Key('s79-honest'),
              ),
              const SizedBox(height: 4),
              Text(
                vm.honestExpectationWorstText,
                key: const Key('s79-honest-worst'),
              ),
              const SizedBox(height: 4),
              Text(
                vm.disclaimerText,
                key: const Key('s79-disclaimer'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValuesSection(GoalPathVm vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton(
          key: const Key('s79-values-toggle'),
          onPressed: () => setState(() => _valuesOpen = !_valuesOpen),
          child: Text(
            _valuesOpen
                ? AnalyticsLabels.valuesHideButton
                : AnalyticsLabels.goalPathValuesButton,
          ),
        ),
        if (_valuesOpen) _buildValuesTable(vm),
      ],
    );
  }

  Widget _buildValuesTable(GoalPathVm vm) {
    return Column(
      key: const Key('s79-values-table'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          key: const Key('s79-values-header'),
          children: <Widget>[
            Expanded(
              child: Text(AnalyticsLabels.goalPathColumnDate),
            ),
            SizedBox(
              width: 104,
              child: Text(
                vm.plannedLabel,
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 104,
              child: Text(
                vm.actualLabel,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        for (int i = 0; i < vm.planned.length; i++)
          Row(
            key: ValueKey<String>('s79-value-row-$i'),
            children: <Widget>[
              Expanded(child: Text(vm.planned[i].dateText)),
              SizedBox(
                width: 104,
                child: Text(
                  vm.planned[i].valueText,
                  textAlign: TextAlign.end,
                ),
              ),
              SizedBox(
                width: 104,
                child: Text(
                  vm.actual[i].valueText,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
