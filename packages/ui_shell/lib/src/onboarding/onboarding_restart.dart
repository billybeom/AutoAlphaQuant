// lib/src/onboarding/onboarding_restart.dart
//
// OnboardingRestart — R-01 기존 계정에서 다시 시작 (04 §9-6 · 계약 v1.16).
//
// 차례는 로그인 자리, 기기 원장 요약, 리스 게이트, 분기 링크, 승계 고지다.
// 모든 글자와 분기는 엔진이 준 그대로이고 화면은 null 여부만 본다.
// 로그인은 주입된 슬롯 빌더에 이름만 넘기고, 분기 탭은 받은 링크를 그대로 연다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<RestartVm> _restartProvider = StreamProvider<RestartVm>(
  (Ref ref) => ref.watch(shellOnboardingRepositoryProvider).watchRestart(),
);

/// R-01 기존 계정에서 다시 시작.
class OnboardingRestart extends ConsumerWidget {
  const OnboardingRestart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RestartVm> restart = ref.watch(_restartProvider);

    if (restart.hasError) {
      return ShellErrorView(
        key: const Key('r01-fail'),
        onRetry: () => ref.invalidate(_restartProvider),
      );
    }

    final RestartVm? vm = restart.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('r01-loading'));
    }

    final String? loginSlot = vm.loginSlotId;
    final List<String>? ledger = vm.ledgerLines;
    final GateBadge? gate = vm.leaseGate;
    final String? inherit = vm.inheritNotice;
    final ShellSlotBuilder? place = ref.watch(
      shellOnboardingSlotBuilderProvider,
    );
    final ColorScheme cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('r01-headline'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.headline),
        ),
        if (loginSlot != null && place != null)
          Padding(
            key: const Key('r01-login'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: place(loginSlot),
          ),
        if (ledger != null)
          Padding(
            key: const Key('r01-ledger'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[for (final String line in ledger) Text(line)],
            ),
          ),
        if (gate != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              key: const Key('r01-gate'),
              children: <Widget>[
                Icon(
                  _gateLook(cs, gate.state).$1,
                  color: _gateLook(cs, gate.state).$2,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(gate.label)),
              ],
            ),
          ),
        for (final (int i, LinkAction b) in vm.branches.indexed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FilledButton.tonal(
              key: ValueKey<String>('r01-branch-$i'),
              onPressed: () {
                ref.read(shellLinkOpenerProvider).open(b.deepLink);
              },
              child: Text(b.label),
            ),
          ),
        if (inherit != null)
          Padding(
            key: const Key('r01-inherit'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(inherit),
          ),
      ],
    );
  }
}

(IconData, Color) _gateLook(ColorScheme cs, GateState g) => switch (g) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};
