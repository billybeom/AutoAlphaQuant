// lib/src/onboarding/onboarding_step_list.dart
//
// OnboardingStepList — O-01 단계 목록 (04 §9-2 · 그림 18 · 계약 v1.16).
//
// 받은 차례 그대로 그린다. 진행률 · 등급 · 경고 · 만료 · 실패 문장 · 게이트는 전부
// 엔진 글자와 null 여부이고, 이동은 엔진이 준 링크 둘(행 탭 · 다음)뿐이다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<OnboardingStepsVm> _stepsProvider =
    StreamProvider<OnboardingStepsVm>(
      (Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchStepList(),
    );

/// O-01 단계 목록.
class OnboardingStepList extends ConsumerWidget {
  const OnboardingStepList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OnboardingStepsVm> steps = ref.watch(_stepsProvider);

    if (steps.hasError) {
      return ShellErrorView(
        key: const Key('o01-fail'),
        onRetry: () => ref.invalidate(_stepsProvider),
      );
    }

    final OnboardingStepsVm? vm = steps.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('o01-loading'));
    }

    final String? empty = vm.emptyLabel;
    final String? finish = vm.finishDeepLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('o01-progress'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(vm.progressText),
        ),
        for (final (int i, OnboardingStep s) in vm.rows.indexed)
          _StepRow(index: i, step: s),
        if (empty != null)
          Padding(
            key: const Key('o01-empty'),
            padding: const EdgeInsets.all(16),
            child: Text(empty),
          ),
        if (finish != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: FilledButton(
              key: const Key('o01-finish'),
              onPressed: () {
                ref.read(shellLinkOpenerProvider).open(finish);
              },
              child: const Text(ShellLabels.onboardingNext),
            ),
          ),
      ],
    );
  }
}

class _StepRow extends ConsumerWidget {
  const _StepRow({required this.index, required this.step});

  final int index;
  final OnboardingStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final (IconData, Color) look = _stepLook(cs, step.state);
    final String? link = step.detailDeepLink;
    final String? warn = step.warningLabel;
    final String? vlabel = step.verificationLabel;
    final String? until = step.verifiedUntilText;
    final String? fail = step.failureText;
    final String? code = step.failureReasonCode;
    final GateBadge? gate = step.gate;

    return InkWell(
      key: ValueKey<String>('o01-row-$index'),
      onTap: link == null
          ? null
          : () {
              ref.read(shellLinkOpenerProvider).open(link);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(look.$1, color: look.$2, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(step.title),
                  Text(step.whyLine),
                  Text(step.estimatedText),
                  Text(step.requirementLabel),
                  if (warn != null) Text(warn),
                  if (vlabel != null) Text(vlabel),
                  if (until != null) Text(until),
                  if (fail != null) Text(fail),
                  if (code != null) Text(code),
                  if (gate != null) _GateMark(index: index, gate: gate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GateMark extends StatelessWidget {
  const _GateMark({required this.index, required this.gate});

  final int index;
  final GateBadge gate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final (IconData, Color) g = _gateLook(cs, gate.state);
    return Row(
      key: ValueKey<String>('o01-gate-$index'),
      children: <Widget>[
        Icon(g.$1, color: g.$2, size: 16),
        const SizedBox(width: 4),
        Flexible(child: Text(gate.label)),
      ],
    );
  }
}

(IconData, Color) _stepLook(ColorScheme cs, StepState s) => switch (s) {
  StepState.notStarted => (Icons.radio_button_unchecked, cs.onSurfaceVariant),
  StepState.inProgress => (Icons.timelapse, cs.tertiary),
  StepState.verified => (Icons.check_circle_outline, cs.primary),
  StepState.failed => (Icons.error_outline, cs.error),
  StepState.expired => (Icons.update, cs.secondary),
};

(IconData, Color) _gateLook(ColorScheme cs, GateState g) => switch (g) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};
