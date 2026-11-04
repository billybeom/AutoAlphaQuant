// lib/src/onboarding/onboarding_finish.dart
//
// OnboardingFinish — O-04 온보딩 마무리 (04 §9-5 · 그림 20 · 계약 v1.16).
//
// 6단계는 받은 차례 그대로 그린다. 제목 · 상태 · 게이트 · 글자 줄 · 기대치 · 링크 · 동작은
// 전부 엔진 글자와 null 여부이고, 시크릿 자리는 주입된 슬롯 빌더에 이름만 넘긴다.
// 단계 동작은 엔진이 완성한 호출 하나를 그대로 한 번 실행하고, 완료 체크는 서버 판정 그대로다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<OnboardingFinishVm> _finishProvider =
    StreamProvider<OnboardingFinishVm>(
      (Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchFinish(),
    );

/// O-04 온보딩 마무리.
class OnboardingFinish extends ConsumerStatefulWidget {
  const OnboardingFinish({super.key});

  @override
  ConsumerState<OnboardingFinish> createState() => _OnboardingFinishState();
}

class _OnboardingFinishState extends ConsumerState<OnboardingFinish> {
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
    final AsyncValue<OnboardingFinishVm> finish = ref.watch(_finishProvider);

    if (finish.hasError) {
      return ShellErrorView(
        key: const Key('o04-fail'),
        onRetry: () => ref.invalidate(_finishProvider),
      );
    }

    final OnboardingFinishVm? vm = finish.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('o04-loading'));
    }

    final String? done = vm.doneLabel;
    final ShellSlotBuilder? builder = ref.watch(
      shellOnboardingSlotBuilderProvider,
    );
    final SettingsActions? actions = ref.watch(shellOnboardingActionsProvider);
    final ActionResult? r = _result;
    final String? code = r?.reasonCode;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('o04-headline'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.headline),
        ),
        for (final (int i, OnboardingFinishStage st) in vm.stages.indexed)
          _StageBlock(
            index: i,
            stage: st,
            builder: builder,
            onOpen: (LinkAction l) {
              ref.read(shellLinkOpenerProvider).open(l.deepLink);
            },
            onRun: (actions == null || _busy)
                ? null
                : (OnboardingAction a) {
                    unawaited(_run(actions, a));
                  },
          ),
        if (_failed)
          const Padding(
            key: Key('o04-not-accepted'),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(ShellLabels.onboardingNotAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('o04-result'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(r.headline),
                if (code != null) Text(code),
              ],
            ),
          ),
        if (done != null)
          Padding(
            key: const Key('o04-done'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(done),
          ),
        for (final (int i, OnboardingFinishCheck c) in vm.checks.indexed)
          Padding(
            key: ValueKey<String>('o04-check-$i'),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: <Widget>[
                Icon(
                  _stepLook(cs, c.state).$1,
                  color: _stepLook(cs, c.state).$2,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(c.label)),
              ],
            ),
          ),
      ],
    );
  }
}

class _StageBlock extends StatelessWidget {
  const _StageBlock({
    required this.index,
    required this.stage,
    required this.builder,
    required this.onOpen,
    required this.onRun,
  });

  final int index;
  final OnboardingFinishStage stage;
  final ShellSlotBuilder? builder;
  final void Function(LinkAction l) onOpen;
  final void Function(OnboardingAction a)? onRun;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final (IconData, Color) look = _stepLook(cs, stage.state);
    final GateBadge? gate = stage.gate;
    final String? exp = stage.expectationLine;
    final String? slot = stage.slotId;
    final ShellSlotBuilder? place = builder;
    final LinkAction? link = stage.link;
    final OnboardingAction? action = stage.action;
    final void Function(OnboardingAction a)? run = onRun;

    return Padding(
      key: ValueKey<String>('o04-stage-$index'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(look.$1, color: look.$2, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(stage.title)),
            ],
          ),
          if (gate != null)
            Row(
              key: ValueKey<String>('o04-gate-$index'),
              children: <Widget>[
                Icon(
                  _gateLook(cs, gate.state).$1,
                  color: _gateLook(cs, gate.state).$2,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(child: Text(gate.label)),
              ],
            ),
          for (final String line in stage.lines) Text(line),
          if (exp != null) Text(exp),
          if (slot != null && place != null)
            Padding(
              key: ValueKey<String>('o04-slot-$index'),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: place(slot),
            ),
          if (link != null)
            FilledButton.tonal(
              key: ValueKey<String>('o04-link-$index'),
              onPressed: () {
                onOpen(link);
              },
              child: Text(link.label),
            ),
          if (action != null && run != null)
            FilledButton(
              key: ValueKey<String>('o04-action-$index'),
              onPressed: () {
                run(action);
              },
              child: Text(action.label),
            ),
        ],
      ),
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
