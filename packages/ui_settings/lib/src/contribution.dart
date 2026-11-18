// lib/src/contribution.dart
//
// Monthly contribution setting — M9 S13 (contract v1.23).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Input field (number input field) = exactly one, first value seeded once.
// 🔴 Write = SettingsActions.runContributionUpdate once per button tap. No link, no handoff.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<MonthlyContributionVm> _vmProvider =
    StreamProvider<MonthlyContributionVm>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchContribution(),
    );

// ── MonthlyContribution ────────────────────────────────────────────────────────

/// M9 S13 monthly contribution setting.
class MonthlyContribution extends ConsumerStatefulWidget {
  const MonthlyContribution({super.key});

  @override
  ConsumerState<MonthlyContribution> createState() =>
      _MonthlyContributionState();
}

class _MonthlyContributionState extends ConsumerState<MonthlyContribution> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;
  bool _seeded = false;

  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run(SettingsActions a) async {
    setState(() => _busy = true);
    try {
      final ActionResult r = await a.runContributionUpdate(
        ContributionUpdateSubmission(amountInput: _input.text),
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
    final AsyncValue<MonthlyContributionVm> data = ref.watch(_vmProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s13-fail'),
        onRetry: () {
          ref.invalidate(_vmProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final MonthlyContributionVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s13-loading'));
    }

    if (!_seeded) {
      _seeded = true;
      _input.text = vm.amountInputText;
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? locked = vm.lockedLabel;
    final String? change = vm.changeLabel;
    final ActionResult? r = _result;
    final String? reasonCode = r?.reasonCode;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s13-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s13-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        Padding(
          key: const Key('m9s13-setting'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(vm.amountText),
              Text(vm.appliesFromText),
              Text(vm.equivalentNoteText),
              if (vm.pensionLimitNoteText case final String limit) Text(limit),
              Text(vm.lastChangedText),
            ],
          ),
        ),
        if (actions != null && change != null)
          Padding(
            key: const Key('m9s13-edit'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  key: const Key('m9s13-input'),
                  controller: _input,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: SettingsLabels.contributionInputLabel,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('m9s13-change'),
                  onPressed: _busy
                      ? null
                      : () {
                          unawaited(_run(actions));
                        },
                  child: Text(change),
                ),
              ],
            ),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s13-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s13-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s13-result-level'),
                      size: 24,
                      color: settingsLevelLook(cs, r.level).$2,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(r.headline)),
                  ],
                ),
                if (reasonCode != null) Text(reasonCode),
              ],
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s13-asof'), asOf: vm.asOf),
      ],
    );
  }
}
