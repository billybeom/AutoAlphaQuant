// lib/src/accounts.dart
//
// Accounts — M9 S03 account link and sleeve mapping (contract v1.20).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Row, slot and option counts and order = received as-is. No sorting, filtering, counting.
// 🔴 Received strings are drawn as-is. The masked number is never cut or masked again.
// 🔴 Write = SettingsActions action called once per confirmed tap (_run). No link, no handoff.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<AccountMappingVm> _mappingProvider =
    StreamProvider<AccountMappingVm>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchAccountMapping(),
    );

// ── Accounts ───────────────────────────────────────────────────────────────────

/// M9 S03 account link and sleeve mapping.
class Accounts extends ConsumerStatefulWidget {
  const Accounts({super.key});

  @override
  ConsumerState<Accounts> createState() => _AccountsState();
}

class _AccountsState extends ConsumerState<Accounts> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;
  (int, int)? _expanded;

  Future<void> _run(SettingsActions a, SettingsActionCall call) async {
    setState(() => _busy = true);
    try {
      final ActionResult r = await a.run(call.id, args: call.args);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = false;
        _result = r;
        _expanded = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
        _result = null;
        _expanded = null;
      });
    }
  }

  void _expand(int i, int o) {
    setState(() => _expanded = (i, o));
  }

  void _collapse() {
    setState(() => _expanded = null);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AccountMappingVm> data = ref.watch(_mappingProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s03-fail'),
        onRetry: () {
          ref.invalidate(_mappingProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final AccountMappingVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s03-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? locked = vm.lockedLabel;
    final ActionResult? r = _result;
    final String? reasonCode = r?.reasonCode;
    final SettingsActionCall? verify = vm.verifyAction;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s03-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s03-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s03-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s03-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s03-result-level'),
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
        for (final (int i, AccountRow a) in vm.accounts.indexed)
          Padding(
            key: ValueKey<String>('m9s03-account-$i'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  settingsLevelLook(cs, a.level).$1,
                  key: ValueKey<String>('m9s03-account-level-$i'),
                  size: 24,
                  color: settingsLevelLook(cs, a.level).$2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(a.label),
                      Text(a.kindLabel),
                      Text(a.maskedNumberText),
                      if (a.checkText case final String check) Text(check),
                      if (a.badgeText case final String badge) Text(badge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        for (final (int i, SleeveMappingRow row) in vm.mappings.indexed)
          _SleeveTile(
            key: ValueKey<String>('m9s03-sleeve-$i'),
            index: i,
            row: row,
            cs: cs,
            actions: actions,
            busy: _busy,
            expanded: _expanded,
            onExpand: _expand,
            onCollapse: _collapse,
            onRun: _run,
          ),
        if (actions != null && verify != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: OutlinedButton(
              key: const Key('m9s03-verify'),
              onPressed: _busy
                  ? null
                  : () {
                      unawaited(_run(actions, verify));
                    },
              child: Text(verify.label),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s03-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── Slot ───────────────────────────────────────────────────────────────────────

class _SleeveTile extends StatelessWidget {
  const _SleeveTile({
    super.key,
    required this.index,
    required this.row,
    required this.cs,
    required this.actions,
    required this.busy,
    required this.expanded,
    required this.onExpand,
    required this.onCollapse,
    required this.onRun,
  });

  final int index;
  final SleeveMappingRow row;
  final ColorScheme cs;
  final SettingsActions? actions;
  final bool busy;
  final (int, int)? expanded;
  final void Function(int i, int o) onExpand;
  final VoidCallback onCollapse;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final String? accountLabel = row.accountLabel;
    final String? subbook = row.subbookLine;
    final String? status = row.statusLine;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, row.level).$1,
                key: ValueKey<String>('m9s03-sleeve-level-$index'),
                size: 24,
                color: settingsLevelLook(cs, row.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(row.sleeveLabel),
                    if (accountLabel != null) Text(accountLabel),
                    if (subbook != null) Text(subbook),
                    if (status != null) Text(status),
                  ],
                ),
              ),
            ],
          ),
          for (final (int o, AccountMappingOption option)
              in row.options.indexed)
            _OptionTile(
              key: ValueKey<String>('m9s03-option-$index-$o'),
              row: index,
              slot: o,
              option: option,
              actions: actions,
              busy: busy,
              open: expanded == (index, o),
              onExpand: onExpand,
              onCollapse: onCollapse,
              onRun: onRun,
            ),
        ],
      ),
    );
  }
}

// ── Option ─────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.row,
    required this.slot,
    required this.option,
    required this.actions,
    required this.busy,
    required this.open,
    required this.onExpand,
    required this.onCollapse,
    required this.onRun,
  });

  final int row;
  final int slot;
  final AccountMappingOption option;
  final SettingsActions? actions;
  final bool busy;
  final bool open;
  final void Function(int i, int o) onExpand;
  final VoidCallback onCollapse;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final SettingsActions? a = actions;
    final SettingsActionCall? select = option.selectAction;
    final String? blocked = option.blockedText;

    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                option.selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                key: ValueKey<String>('m9s03-mark-$row-$slot'),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(option.label),
                    if (blocked != null) Text(blocked),
                  ],
                ),
              ),
            ],
          ),
          if (a != null && select != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: OutlinedButton(
                key: ValueKey<String>('m9s03-pick-$row-$slot'),
                onPressed: busy
                    ? null
                    : () {
                        onExpand(row, slot);
                      },
                child: Text(select.label),
              ),
            ),
          if (open && a != null && select != null)
            Padding(
              key: ValueKey<String>('m9s03-confirm-$row-$slot'),
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final String line in option.impacts) Text(line),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: <Widget>[
                        OutlinedButton(
                          key: ValueKey<String>('m9s03-confirm-yes-$row-$slot'),
                          onPressed: busy
                              ? null
                              : () {
                                  unawaited(onRun(a, select));
                                },
                          child: Text(SettingsLabels.confirm),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          key: ValueKey<String>('m9s03-confirm-no-$row-$slot'),
                          onPressed: busy ? null : onCollapse,
                          child: Text(SettingsLabels.cancel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
