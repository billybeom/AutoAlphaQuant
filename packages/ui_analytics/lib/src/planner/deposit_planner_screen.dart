// lib/src/planner/deposit_planner_screen.dart

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
import 'planner_providers.dart';

enum _PlannerStep { input, allocation, result }

class DepositPlannerScreen extends ConsumerStatefulWidget {
  const DepositPlannerScreen({super.key});

  @override
  ConsumerState<DepositPlannerScreen> createState() =>
      _DepositPlannerScreenState();
}

class _DepositPlannerScreenState extends ConsumerState<DepositPlannerScreen> {
  _PlannerStep _step = _PlannerStep.input;
  final TextEditingController _amountController = TextEditingController();
  bool _seeded = false;
  bool _touched = false;
  Future<DepositPreviewResult>? _pending;
  String _lastInput = '';
  DepositPlan? _plan;
  String? _rejectedText;
  String? _blockedText;
  LinkAction? _blockedAction;
  bool _calcFailed = false;
  bool _submitting = false;
  bool _notAccepted = false;
  CommandReceipt? _receipt;
  StreamSubscription<CommandReceipt>? _subscription;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<ContributionSetting>>(
      plannerContributionSettingProvider,
      (previous, next) {
        final ContributionSetting? setting = next.valueOrNull;
        if (setting == null || _seeded || _touched) return;
        _seeded = true;
        _amountController.text = setting.amountInputText;
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _calculate(String input) {
    final Future<DepositPreviewResult> future = ref
        .read(plannerWhatIfApiProvider)
        .simulateDeposit(amountInput: input);
    setState(() {
      _pending = future;
      _lastInput = input;
      _rejectedText = null;
      _blockedText = null;
      _blockedAction = null;
      _calcFailed = false;
      _notAccepted = false;
    });

    unawaited(
      future.then(
        (DepositPreviewResult result) {
          if (!mounted || !identical(future, _pending)) return;
          final DepositPlan? plan = result.plan;
          setState(() {
            _pending = null;
            if (plan != null) {
              _plan = plan;
              if (_step == _PlannerStep.input) {
                _step = _PlannerStep.allocation;
              }
            } else {
              _plan = null;
              _step = _PlannerStep.input;
              _rejectedText = result.inputRejectedText;
              _blockedText = result.blockedText;
              _blockedAction = result.blockedAction;
            }
          });
        },
        onError: (Object error, StackTrace stack) {
          if (!mounted || !identical(future, _pending)) return;
          setState(() {
            _pending = null;
            _plan = null;
            _step = _PlannerStep.input;
            _calcFailed = true;
          });
        },
      ),
    );
  }

  Future<void> _register(DepositPlan plan) async {
    setState(() {
      _submitting = true;
      _notAccepted = false;
    });
    final CommandApi api = ref.read(plannerCommandApiProvider);
    try {
      final CommandReceipt receipt = await api.registerDeposit(
        DepositRegistration(planId: plan.planId),
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _receipt = receipt;
      });
      _subscription = api.watchCommand(receipt.commandId).listen(
        (CommandReceipt next) {
          if (mounted) setState(() => _receipt = next);
        },
        onError: (Object error, StackTrace stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'ui_analytics',
            ),
          );
        },
      );
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'ui_analytics',
        ),
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notAccepted = true;
      });
    }
  }

  Widget _buildSafetyBanner(List<BlockFlag> activeFlags) {
    if (activeFlags.isEmpty) return const SizedBox.shrink();
    return SafetyBlockBanner(
      activeFlags: activeFlags,
      onOpenLink:
          (link) => ref.read(analyticsLinkOpenerProvider).open(link),
    );
  }

  Color _chipToneColor(BuildContext context, ChipTone tone) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (tone) {
      case ChipTone.caution:
        return scheme.errorContainer;
      case ChipTone.blocked:
        return scheme.error;
      case ChipTone.neutral:
        return scheme.surfaceContainerHighest;
      case ChipTone.prevented:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BlockFlag> activeFlags =
        ref.watch(safetyStateStreamProvider).valueOrNull?.activeFlags ??
        const <BlockFlag>[];

    switch (_step) {
      case _PlannerStep.input:
        return _buildStepInput(context, activeFlags);
      case _PlannerStep.allocation:
        return _buildStepAllocation(context, activeFlags);
      case _PlannerStep.result:
        return _buildStepResult(context, activeFlags);
    }
  }

  Widget _buildStepInput(BuildContext context, List<BlockFlag> activeFlags) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AsyncValue<ContributionSetting> settingAsync = ref.watch(
      plannerContributionSettingProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSafetyBanner(activeFlags),
        Expanded(
          child: ListView(
            key: const Key('s74-list-input'),
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                AnalyticsLabels.plannerStepAmountTitle,
                key: Key('s74-step-title'),
              ),
              const SizedBox(height: 8),
              const Text(
                AnalyticsLabels.plannerIntroLine,
                key: Key('s74-intro'),
              ),
              const SizedBox(height: 16),
              const Text(
                AnalyticsLabels.plannerCurrentSettingHeader,
                key: Key('s74-setting-header'),
              ),
              const SizedBox(height: 8),
              ...settingAsync.when(
                data: (ContributionSetting setting) => [
                  Text(
                    setting.amountText,
                    key: const Key('s74-setting-amount'),
                  ),
                  Text(
                    setting.equivalentNoteText,
                    key: const Key('s74-setting-equivalent'),
                  ),
                  Text(
                    setting.appliesFromText,
                    key: const Key('s74-setting-applies'),
                  ),
                  if (setting.pensionLimitNoteText != null)
                    Text(
                      setting.pensionLimitNoteText!,
                      key: const Key('s74-setting-limit-note'),
                    ),
                  Text(
                    setting.asOf.label,
                    key: const Key('s74-setting-asof'),
                  ),
                ],
                loading: () => const [
                  AnalyticsSkeleton(
                    key: Key('s74-setting-loading'),
                    blocks: 2,
                  ),
                ],
                error: (error, stack) => [
                  AnalyticsErrorView(
                    key: const Key('s74-setting-error'),
                    onRetry: () => ref.invalidate(
                      plannerContributionSettingProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('s74-amount-field'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AnalyticsLabels.plannerAmountFieldLabel,
                ),
                onChanged: (_) => _touched = true,
              ),
              if (_rejectedText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _rejectedText!,
                  key: const Key('s74-input-rejected'),
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('s74-calculate'),
                onPressed: () => _calculate(_amountController.text),
                child: const Text(AnalyticsLabels.plannerCalculateButton),
              ),
              if (_pending != null) ...[
                const SizedBox(height: 16),
                const AnalyticsSkeleton(
                  key: Key('s74-result-loading'),
                  blocks: 3,
                ),
              ] else if (_calcFailed) ...[
                const SizedBox(height: 16),
                AnalyticsErrorView(
                  key: const Key('s74-result-error'),
                  onRetry: () => _calculate(_lastInput),
                ),
              ] else if (_blockedText != null) ...[
                const SizedBox(height: 16),
                Card(
                  key: const Key('s74-blocked-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_blockedText!),
                        if (_blockedAction != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton(
                            key: const Key('s74-blocked-action'),
                            onPressed: () => ref
                                .read(analyticsLinkOpenerProvider)
                                .open(_blockedAction!.deepLink),
                            child: Text(_blockedAction!.label),
                          ),
                        ],
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

  Widget _buildStepAllocation(
    BuildContext context,
    List<BlockFlag> activeFlags,
  ) {
    final DepositPlan plan = _plan!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            plan.previewNotice,
            key: const Key('s74-preview-notice'),
          ),
        ),
        StaleBanner(asOf: plan.asOf),
        _buildSafetyBanner(activeFlags),
        Expanded(
          child: ListView(
            key: const Key('s74-list-allocation'),
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                AnalyticsLabels.plannerStepAllocationTitle,
                key: Key('s74-step-title'),
              ),
              const SizedBox(height: 8),
              Text(plan.asOf.label, key: const Key('s74-asof')),
              const SizedBox(height: 8),
              for (int i = 0; i < plan.warningLines.length; i++)
                Text(
                  plan.warningLines[i],
                  key: Key('s74-warning-$i'),
                ),
              const SizedBox(height: 16),
              Text(
                plan.depositAmountText,
                key: const Key('s74-deposit-amount'),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < plan.allocations.length; i++) ...[
                Column(
                  key: Key('s74-allocation-$i'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        Text(plan.allocations[i].label),
                        Text(plan.allocations[i].amountText),
                      ],
                    ),
                    if (plan.allocations[i].accountAlias != null)
                      Text(
                        plan.allocations[i].accountAlias!,
                        key: Key('s74-allocation-$i-account'),
                      ),
                    if (plan.allocations[i].routingReasonText != null)
                      Text(
                        plan.allocations[i].routingReasonText!,
                        key: Key('s74-allocation-$i-reason'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (plan.residualKrwCashText != null) ...[
                Text(
                  plan.residualKrwCashText!,
                  key: const Key('s74-residual'),
                ),
                const SizedBox(height: 8),
              ],
              if (plan.pensionLimit != null) ...[
                Card(
                  key: const Key('s74-pension-limit'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AnalyticsLabels.plannerPensionLimitTitle,
                        ),
                        Text(plan.pensionLimit!.annualLimitText),
                        Text(plan.pensionLimit!.taxCreditText),
                        Text(plan.pensionLimit!.deadlineText),
                        if (plan.pensionLimit!.suggestionText != null)
                          Text(
                            plan.pensionLimit!.suggestionText!,
                            key: const Key('s74-pension-suggestion'),
                          ),
                        if (plan.pensionLimit!.fundingNoteText != null)
                          Text(
                            plan.pensionLimit!.fundingNoteText!,
                            key: const Key('s74-pension-funding-note'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('s74-next'),
                  onPressed: () => setState(() => _step = _PlannerStep.result),
                  child: const Text(AnalyticsLabels.plannerNextButton),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const Key('s74-back'),
                  onPressed: () => setState(() => _step = _PlannerStep.input),
                  child: const Text(AnalyticsLabels.plannerBackButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepResult(BuildContext context, List<BlockFlag> activeFlags) {
    final DepositPlan plan = _plan!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            plan.previewNotice,
            key: const Key('s74-preview-notice'),
          ),
        ),
        StaleBanner(asOf: plan.asOf),
        _buildSafetyBanner(activeFlags),
        Expanded(
          child: ListView(
            key: const Key('s74-list-result'),
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                AnalyticsLabels.plannerStepResultTitle,
                key: Key('s74-step-title'),
              ),
              const SizedBox(height: 8),
              Text(plan.asOf.label, key: const Key('s74-asof')),
              const SizedBox(height: 8),
              for (int i = 0; i < plan.warningLines.length; i++)
                Text(
                  plan.warningLines[i],
                  key: Key('s74-warning-$i'),
                ),
              if (_pending != null) ...[
                const SizedBox(height: 16),
                const AnalyticsSkeleton(
                  key: Key('s74-result-loading'),
                  blocks: 3,
                ),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  plan.orderDraftsTitle,
                  key: const Key('s74-orders-title'),
                ),
                const SizedBox(height: 8),
                if (plan.ordersEmptyText != null)
                  Text(
                    plan.ordersEmptyText!,
                    key: const Key('s74-orders-empty'),
                  )
                else
                  for (int i = 0; i < plan.orderDrafts.length; i++) ...[
                    Column(
                      key: Key('s74-order-$i'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(plan.orderDrafts[i].symbolLabel),
                        Text(plan.orderDrafts[i].accountAlias),
                        Wrap(
                          spacing: 8,
                          children: [
                            Text(plan.orderDrafts[i].sideLabel),
                            Text(plan.orderDrafts[i].quantityText),
                            if (plan.orderDrafts[i].limitPriceText != null)
                              Text(
                                plan.orderDrafts[i].limitPriceText!,
                                key: Key('s74-order-$i-limit'),
                              ),
                          ],
                        ),
                        if (plan.orderDrafts[i].pendingNoteText != null)
                          Text(
                            plan.orderDrafts[i].pendingNoteText!,
                            key: Key('s74-order-$i-pending'),
                          ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final chip in plan.orderDrafts[i].reasons)
                              Chip(
                                label: Text(chip.label),
                                backgroundColor: _chipToneColor(
                                  context,
                                  chip.tone,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 16),
                Card(
                  key: const Key('s74-costs'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(AnalyticsLabels.plannerCostsHeader),
                        Text(plan.costs.totalText),
                        Text(plan.costs.sourceLabel),
                        Text(plan.costs.basisNote),
                      ],
                    ),
                  ),
                ),
                if (plan.fundingSteps != null &&
                    plan.fundingSteps!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Column(
                    key: const Key('s74-funding'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(AnalyticsLabels.plannerFundingHeader),
                      for (int i = 0; i < plan.fundingSteps!.length; i++)
                        Text(
                          plan.fundingSteps![i].label,
                          key: Key('s74-funding-$i'),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (plan.registerBlockedText != null)
                  Text(
                    plan.registerBlockedText!,
                    key: const Key('s74-register-blocked'),
                  )
                else if (_receipt == null) ...[
                  if (_notAccepted) ...[
                    Text(
                      AnalyticsLabels.plannerRegisterNotAccepted,
                      key: const Key('s74-register-not-accepted'),
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('s74-register'),
                      onPressed: _submitting
                          ? null
                          : () => unawaited(_register(plan)),
                      child: const Text(AnalyticsLabels.plannerRegisterButton),
                    ),
                  ),
                ],
                if (_receipt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _receipt!.stateLabel,
                    key: const Key('s74-receipt'),
                  ),
                ],
                if (_receipt == null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const Key('s74-recalculate'),
                      onPressed: _submitting
                          ? null
                          : () => _calculate(_lastInput),
                      child: const Text(
                        AnalyticsLabels.plannerRecalculateButton,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('s74-back'),
                      onPressed: _submitting
                          ? null
                          : () => setState(
                              () => _step = _PlannerStep.allocation,
                            ),
                      child: const Text(AnalyticsLabels.plannerBackButton),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
