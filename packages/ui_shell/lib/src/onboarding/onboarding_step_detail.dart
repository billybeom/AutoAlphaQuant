// lib/src/onboarding/onboarding_step_detail.dart
//
// OnboardingStepDetail — O-02 단계 상세 + O-03 검증 결과 (04 §9-3 · §9-4 · 그림 19 · 계약 v1.16).
//
// 상세 글자는 엔진 글자 그대로이고, 시크릿 자리는 주입된 슬롯 빌더에 이름만 넘긴다.
// 검증 버튼 = 엔진이 완성한 동작 하나를 그대로 한 번 실행한다. 결과는 3상(성공 · 거절 · 실패)뿐이다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../shell_providers.dart';

final StreamProviderFamily<OnboardingStepDetailVm, String> _stepDetailProvider =
    StreamProvider.family<OnboardingStepDetailVm, String>(
      (Ref ref, String stepId) =>
          ref.watch(shellOnboardingRepositoryProvider).watchStep(stepId),
    );

/// O-02 단계 상세 + O-03 검증 결과.
class OnboardingStepDetail extends ConsumerStatefulWidget {
  const OnboardingStepDetail({super.key, required this.stepId});

  final String stepId;

  @override
  ConsumerState<OnboardingStepDetail> createState() =>
      _OnboardingStepDetailState();
}

class _OnboardingStepDetailState extends ConsumerState<OnboardingStepDetail> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;

  Future<void> _run(SettingsActions a, OnboardingAction v) async {
    setState(() => _busy = true);
    try {
      final ActionResult r = await a.run(v.id, args: v.args);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = false;
        _result = r;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<OnboardingStepDetailVm> detail = ref.watch(
      _stepDetailProvider(widget.stepId),
    );

    if (detail.hasError) {
      return ShellErrorView(
        key: const Key('o02-fail'),
        onRetry: () => ref.invalidate(_stepDetailProvider(widget.stepId)),
      );
    }

    final OnboardingStepDetailVm? vm = detail.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('o02-loading'));
    }

    final String? missing = vm.missingLabel;
    final OnboardingStep? s = vm.step;
    final String? until = s?.verifiedUntilText;
    final String? where = vm.whereText;
    final String? how = vm.howText;
    final ShellSlotBuilder? builder = ref.watch(
      shellOnboardingSlotBuilderProvider,
    );
    final String? slotId = vm.secretSlotId;
    final OnboardingAction? verify = vm.verify;
    final SettingsActions? actions = ref.watch(shellOnboardingActionsProvider);
    final ActionResult? r = _result;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (missing != null)
          Padding(
            key: const Key('o02-missing'),
            padding: const EdgeInsets.all(16),
            child: Text(missing),
          ),
        if (s != null)
          Padding(
            key: const Key('o02-head'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.title),
                Text(s.whyLine),
                Text(s.estimatedText),
                if (until != null) Text(until),
              ],
            ),
          ),
        if (where != null)
          Padding(
            key: const Key('o02-where'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(where),
          ),
        if (how != null)
          Padding(
            key: const Key('o02-how'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(how),
          ),
        if (slotId != null && builder != null)
          Padding(
            key: const Key('o02-secret'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: builder(slotId),
          ),
        if (verify != null && actions != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton(
              key: const Key('o03-run'),
              onPressed: _busy
                  ? null
                  : () {
                      unawaited(_run(actions, verify));
                    },
              child: Text(verify.label),
            ),
          ),
        if (_failed)
          const Padding(
            key: Key('o03-not-accepted'),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(ShellLabels.onboardingNotAccepted),
          ),
        if (r != null)
          _VerifyResult(
            result: r,
            onRetry:
                (r.retryable && verify != null && actions != null && !_busy)
                ? () {
                    unawaited(_run(actions, verify));
                  }
                : null,
          ),
      ],
    );
  }
}

class _VerifyResult extends StatelessWidget {
  const _VerifyResult({required this.result, required this.onRetry});

  final ActionResult result;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final (IconData, Color) look = _resultLook(cs, result.level);
    final String? code = result.reasonCode;
    final VoidCallback? retry = onRetry;

    return Padding(
      key: const Key('o03-result'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(look.$1, color: look.$2, key: const Key('o03-level')),
              const SizedBox(width: 8),
              Expanded(child: Text(result.headline)),
            ],
          ),
          if (code != null) Text(code),
          if (retry != null)
            TextButton(
              key: const Key('o03-retry'),
              onPressed: retry,
              child: const Text(ShellLabels.retry),
            ),
        ],
      ),
    );
  }
}

(IconData, Color) _resultLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
