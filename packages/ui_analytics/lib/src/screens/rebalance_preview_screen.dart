import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_error_view.dart';
import '../widgets/analytics_skeleton.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';

/// S7-6c 다음 리밸런싱 및 지금 기준 초안 화면.
class RebalancePreviewScreen extends ConsumerStatefulWidget {
  const RebalancePreviewScreen({super.key});

  @override
  ConsumerState<RebalancePreviewScreen> createState() =>
      _RebalancePreviewScreenState();
}

class _RebalancePreviewScreenState
    extends ConsumerState<RebalancePreviewScreen> {
  Future<RebalancePreviewResult>? _pending;
  RebalancePreviewResult? _result;
  bool _failed = false;

  void _requestPreview(WhatIfApi api) {
    final Future<RebalancePreviewResult> future = api.previewRebalance();
    setState(() {
      _pending = future;
      _result = null;
      _failed = false;
    });
    unawaited(
      future.then(
        (RebalancePreviewResult result) {
          if (!mounted || !identical(future, _pending)) return;
          setState(() {
            _pending = null;
            _result = result;
          });
        },
        onError: (Object error, StackTrace stack) {
          if (!mounted || !identical(future, _pending)) return;
          setState(() {
            _pending = null;
            _result = null;
            _failed = true;
          });
        },
      ),
    );
  }

  Color _toneColor(ChipTone tone, ColorScheme colorScheme) {
    switch (tone) {
      case ChipTone.caution:
        return colorScheme.errorContainer;
      case ChipTone.blocked:
        return colorScheme.error;
      case ChipTone.neutral:
        return colorScheme.surfaceContainerHighest;
      case ChipTone.prevented:
        return colorScheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NextRebalanceVm> asyncValue =
        ref.watch(nextRebalanceProvider);
    final List<BlockFlag> activeFlags =
        ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ??
        const <BlockFlag>[];
    final WhatIfApi? api = ref.watch(analyticsWhatIfApiProvider);

    return asyncValue.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[AnalyticsSkeleton()],
      ),
      error: (Object error, StackTrace stack) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AnalyticsErrorView(
            onRetry: () => ref.invalidate(nextRebalanceProvider),
            lastAsOfLabel: asyncValue.valueOrNull?.asOf.label,
          ),
        ],
      ),
      data: (NextRebalanceVm vm) =>
          _buildBody(context, ref, vm, activeFlags, api),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NextRebalanceVm vm,
    List<BlockFlag> activeFlags,
    WhatIfApi? api,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final RebalancePreview? preview = _result?.preview;

    return Column(
      key: const Key('s76c-root'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StaleBanner(asOf: vm.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onOpenLink: (String link) {
            ref.read(analyticsLinkOpenerProvider).open(link);
          },
        ),
        if (preview != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              preview.previewNotice,
              key: const Key('s76c-notice'),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (vm.emptyLabel != null)
                Text(vm.emptyLabel!, key: const Key('s76c-empty'))
              else
                Card(
                  key: const Key('s76c-countdown'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(vm.dDayText!),
                        Text(vm.expectedDateText!),
                        if (vm.kindLabel != null) Text(vm.kindLabel!),
                        if (vm.noticeText != null) Text(vm.noticeText!),
                      ],
                    ),
                  ),
                ),
              Text(vm.asOf.label, key: const Key('s76c-asof')),
              if (vm.emptyLabel == null && api != null) ...<Widget>[
                FilledButton(
                  key: const Key('s76c-preview-button'),
                  onPressed: () => _requestPreview(api),
                  child: const Text(AnalyticsLabels.rebalanceDraftButton),
                ),
                if (_pending != null)
                  const AnalyticsSkeleton()
                else if (_failed)
                  AnalyticsErrorView(
                    onRetry: () => _requestPreview(api),
                  )
                else if (preview != null)
                  Column(
                    key: const Key('s76c-draft'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(preview.plannedDateText),
                      Text(preview.orderDraftsTitle),
                      if (preview.ordersEmptyText != null)
                        Text(
                          preview.ordersEmptyText!,
                          key: const Key('s76c-draft-empty'),
                        )
                      else
                        for (final OrderDraft d in preview.orderDrafts)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(d.symbolLabel),
                              Text(d.accountAlias),
                              Wrap(
                                spacing: 8,
                                children: <Widget>[
                                  Text(d.sideLabel),
                                  Text(d.quantityText),
                                  if (d.limitPriceText != null)
                                    Text(d.limitPriceText!),
                                ],
                              ),
                              if (d.pendingNoteText != null)
                                Text(d.pendingNoteText!),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: <Widget>[
                                  for (final ReasonChip chip in d.reasons)
                                    Chip(
                                      label: Text(chip.label),
                                      backgroundColor: _toneColor(
                                        chip.tone,
                                        colorScheme,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                AnalyticsLabels.rebalanceDraftCostsHeader,
                              ),
                              Text(preview.costs.totalText),
                              Text(preview.costs.sourceLabel),
                              Text(preview.costs.basisNote),
                            ],
                          ),
                        ),
                      ),
                      for (final String line in preview.warningLines)
                        Text(line),
                      Text(
                        preview.asOf.label,
                        key: const Key('s76c-draft-asof'),
                      ),
                    ],
                  )
                else if (_result?.blockedText != null)
                  Card(
                    key: const Key('s76c-blocked'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_result!.blockedText!),
                          if (_result!.blockedAction != null)
                            OutlinedButton(
                              key: const Key('s76c-blocked-action'),
                              onPressed: () {
                                ref
                                    .read(analyticsLinkOpenerProvider)
                                    .open(_result!.blockedAction!.deepLink);
                              },
                              child: Text(_result!.blockedAction!.label),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
