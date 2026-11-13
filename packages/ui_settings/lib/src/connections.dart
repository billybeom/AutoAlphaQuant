// lib/src/connections.dart
//
// Connections — M9 S07 (contract v1.18).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Row count/order = received as-is. No sorting, filtering, counting.
// 🔴 Write = SettingsActions.run(call.id, args: call.args) once per tap.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<ConnectionsVm> _connectionsProvider =
    StreamProvider<ConnectionsVm>(
      (Ref ref) =>
          ref.watch(settingsOpsStatusRepositoryProvider).watchConnections(),
    );

// ── Connections ────────────────────────────────────────────────────────────────

/// M9 S07 connections management.
class Connections extends ConsumerStatefulWidget {
  const Connections({super.key});

  @override
  ConsumerState<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends ConsumerState<Connections> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;

  Future<void> _run(SettingsActions a, SettingsActionCall call) async {
    setState(() => _busy = true);
    try {
      final ActionResult r = await a.run(call.id, args: call.args);
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
    final AsyncValue<ConnectionsVm> data = ref.watch(_connectionsProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s07-fail'),
        onRetry: () {
          ref.invalidate(_connectionsProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final ConnectionsVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s07-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ActionResult? r = _result;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s07-stale'), asOf: vm.asOf),
        if (vm.lockedLabel != null)
          Padding(
            key: const Key('m9s07-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(vm.lockedLabel!),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s07-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s07-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s07-result-level'),
                      size: 24,
                      color: settingsLevelLook(cs, r.level).$2,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(r.headline)),
                  ],
                ),
                if (r.reasonCode != null) Text(r.reasonCode!),
              ],
            ),
          ),
        for (final (int i, ConnectionRow row) in vm.rows.indexed) ...<Widget>[
          _RowHead(
            key: ValueKey<String>('m9s07-row-$i'),
            rowIndex: i,
            row: row,
            cs: cs,
            onTap: row.route == null
                ? null
                : () {
                    ref.read(settingsLinkOpenerProvider).open(row.route!);
                  },
          ),
          if (actions != null && row.actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 16),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final (int a, SettingsActionCall call)
                      in row.actions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        key: ValueKey<String>('m9s07-action-$i-$a'),
                        onPressed: _busy
                            ? null
                            : () {
                                unawaited(_run(actions, call));
                              },
                        child: Text(call.label),
                      ),
                    ),
                ],
              ),
            ),
          if (row.channelPicker != null)
            _ChannelPicker(
              key: ValueKey<String>('m9s07-picker-$i'),
              rowIndex: i,
              picker: row.channelPicker!,
              actions: actions,
              busy: _busy,
              onRun: _run,
            ),
        ],
        SettingsAsOfLine(key: const Key('m9s07-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── _RowHead ───────────────────────────────────────────────────────────────────

class _RowHead extends StatelessWidget {
  const _RowHead({
    super.key,
    required this.rowIndex,
    required this.row,
    required this.cs,
    required this.onTap,
  });

  final int rowIndex;
  final ConnectionRow row;
  final ColorScheme cs;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              settingsLevelLook(cs, row.level).$1,
              key: ValueKey<String>('m9s07-level-$rowIndex'),
              size: 24,
              color: settingsLevelLook(cs, row.level).$2,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.label),
                  Text(row.statusLabel),
                  Text(row.lastOkText),
                  if (row.detailLine != null) Text(row.detailLine!),
                ],
              ),
            ),
            if (row.route != null) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ── _ChannelPicker ─────────────────────────────────────────────────────────────

class _ChannelPicker extends StatelessWidget {
  const _ChannelPicker({
    super.key,
    required this.rowIndex,
    required this.picker,
    required this.actions,
    required this.busy,
    required this.onRun,
  });

  final int rowIndex;
  final NotifyChannelCard picker;
  final SettingsActions? actions;
  final bool busy;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(picker.label),
          for (final (int o, NotifyChannelOption option)
              in picker.options.indexed)
            if (option.selected)
              Padding(
                key: ValueKey<String>('m9s07-option-$rowIndex-$o'),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.radio_button_checked, size: 24),
                    const SizedBox(width: 8),
                    Flexible(child: Text(option.label)),
                  ],
                ),
              )
            else if (option.selectAction != null && actions != null)
              OutlinedButton(
                key: ValueKey<String>('m9s07-select-$rowIndex-$o'),
                onPressed: busy
                    ? null
                    : () {
                        unawaited(onRun(actions!, option.selectAction!));
                      },
                child: Text(option.selectAction!.label),
              ),
          Text(picker.capabilityNotice),
          if (picker.tokenBadgeText != null)
            Padding(
              key: ValueKey<String>('m9s07-token-$rowIndex'),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(picker.tokenBadgeText!),
            ),
          Text(picker.watchdogChannelLine),
        ],
      ),
    );
  }
}
