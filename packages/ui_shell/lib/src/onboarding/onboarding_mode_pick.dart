// lib/src/onboarding/onboarding_mode_pick.dart
//
// OnboardingModePick — O-00b 운영 방식 선택 (04 §9-1b · 그림 28 · 계약 v1.16).
//
// 기본값 없음: 고른 표시 · 다음 · 잠금은 전부 데이터이고 낙관 갱신이 없다.
// 카드 탭 = 쓰기 한 번(run). 이동은 엔진이 준 링크 하나뿐이다.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<OnboardingModeChoiceVm> _modeChoiceProvider =
    StreamProvider<OnboardingModeChoiceVm>(
      (Ref ref) =>
          ref.watch(shellOnboardingRepositoryProvider).watchModeChoice(),
    );

/// O-00b 운영 방식 선택.
class OnboardingModePick extends ConsumerStatefulWidget {
  const OnboardingModePick({super.key});

  @override
  ConsumerState<OnboardingModePick> createState() => _OnboardingModePickState();
}

class _OnboardingModePickState extends ConsumerState<OnboardingModePick> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;

  Future<void> _pick(SettingsActions a, OperatingMode m) async {
    setState(() => _busy = true);
    try {
      final ActionResult r = await a.run(
        SettingsActionId.onboardingOperatingModeSelect,
        args: <String, String>{'operating_mode': m.wire},
      );
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
    final AsyncValue<OnboardingModeChoiceVm> choice = ref.watch(
      _modeChoiceProvider,
    );

    if (choice.hasError) {
      return ShellErrorView(
        key: const Key('o00b-fail'),
        onRetry: () => ref.invalidate(_modeChoiceProvider),
      );
    }

    final OnboardingModeChoiceVm? vm = choice.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('o00b-loading'));
    }

    final OperatingMode? picked = vm.selected;
    final SettingsActions? actions = ref.watch(shellOnboardingActionsProvider);
    final String? locked = vm.lockedLabel;
    final Future<void> Function(OperatingMode m)? pick =
        (actions == null || locked != null || _busy)
        ? null
        : (OperatingMode m) => _pick(actions, m);
    final ActionResult? r = _result;
    final String? code = r?.reasonCode;
    final String? next = vm.nextDeepLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('o00b-headline'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(vm.headline),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final (int i, OperatingModeOption o) in vm.options.indexed)
                  Expanded(
                    child: _ModeCard(
                      index: i,
                      option: o,
                      picked: o.mode == picked,
                      onTap: pick == null
                          ? null
                          : () {
                              unawaited(pick(o.mode));
                            },
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (locked != null)
          Padding(
            key: const Key('o00b-locked'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(locked),
          ),
        if (_failed)
          const Padding(
            key: Key('o00b-not-accepted'),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(ShellLabels.onboardingNotAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('o00b-result'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(r.headline),
                if (code != null) Text(code),
              ],
            ),
          ),
        Padding(
          key: const Key('o00b-record-gap'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(vm.recordGapNotice),
        ),
        Padding(
          key: const Key('o00b-honesty'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(vm.honestyText),
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: FilledButton(
              key: const Key('o00b-next'),
              onPressed: () {
                ref.read(shellLinkOpenerProvider).open(next);
              },
              child: const Text(ShellLabels.onboardingNext),
            ),
          ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.index,
    required this.option,
    required this.picked,
    required this.onTap,
  });

  final int index;
  final OperatingModeOption option;
  final bool picked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      key: ValueKey<String>('o00b-card-$index'),
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: picked ? cs.primary : cs.outlineVariant,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(option.title)),
                  if (picked)
                    Icon(
                      Icons.check_circle,
                      key: ValueKey<String>('o00b-check-$index'),
                      color: cs.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(option.body),
              const SizedBox(height: 8),
              Text(option.prepLine),
              const SizedBox(height: 8),
              Text(option.honestyLine),
            ],
          ),
        ),
      ),
    );
  }
}
