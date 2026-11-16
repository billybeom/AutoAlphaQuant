// lib/src/devices.dart
//
// Devices — M9 S06 device and access management (contract v1.20).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Row count and order = received as-is. No sorting, filtering, counting.
// 🔴 Received strings are drawn as-is. The slot name goes only to the injected builder.
// 🔴 Write = SettingsActions action called once per tap (_run). The link opens once (_open).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<DeviceAccessVm> _deviceAccessProvider =
    StreamProvider<DeviceAccessVm>(
      (Ref ref) =>
          ref.watch(settingsOpsStatusRepositoryProvider).watchDeviceAccess(),
    );

// ── Devices ────────────────────────────────────────────────────────────────────

/// M9 S06 device and access management.
class Devices extends ConsumerStatefulWidget {
  const Devices({super.key});

  @override
  ConsumerState<Devices> createState() => _DevicesState();
}

class _DevicesState extends ConsumerState<Devices> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;
  int? _expanded;

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

  void _expand(int i) {
    setState(() => _expanded = i);
  }

  void _collapse() {
    setState(() => _expanded = null);
  }

  void _open(LinkAction link) {
    ref.read(settingsLinkOpenerProvider).open(link.deepLink);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DeviceAccessVm> data = ref.watch(_deviceAccessProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s06-fail'),
        onRetry: () {
          ref.invalidate(_deviceAccessProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final DeviceAccessVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s06-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);
    final SettingsSlotBuilder? slot = ref.watch(settingsSlotBuilderProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? locked = vm.lockedLabel;
    final ActionResult? r = _result;
    final String? reasonCode = r?.reasonCode;
    final PairingTicketCard? p = vm.pairing;
    final SettingsActionCall? issue = p?.issueAction;
    final String? qrSlotId = p?.qrSlotId;
    final String? expires = p?.expiresText;
    final String? empty = vm.emptyLabel;
    final String? eta = vm.leaseEtaText;
    final String? epoch = vm.leaseEpochText;
    final LinkAction? link = vm.migrationLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s06-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s06-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s06-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s06-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s06-result-level'),
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
        if (p != null)
          Padding(
            key: const Key('m9s06-pairing'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(p.headline),
                if (actions != null && issue != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton(
                      key: const Key('m9s06-issue'),
                      onPressed: _busy
                          ? null
                          : () {
                              unawaited(_run(actions, issue));
                            },
                      child: Text(issue.label),
                    ),
                  ),
                if (slot != null && qrSlotId != null)
                  Padding(
                    key: const Key('m9s06-qr'),
                    padding: const EdgeInsets.only(top: 8),
                    child: slot(qrSlotId),
                  ),
                if (expires != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(expires),
                  ),
              ],
            ),
          ),
        for (final (int i, DeviceRow row) in vm.devices.indexed)
          _DeviceTile(
            key: ValueKey<String>('m9s06-row-$i'),
            index: i,
            row: row,
            cs: cs,
            actions: actions,
            busy: _busy,
            open: _expanded == i,
            onExpand: _expand,
            onCollapse: _collapse,
            onRun: _run,
          ),
        if (empty != null)
          Padding(
            key: const Key('m9s06-empty'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(empty),
          ),
        Padding(
          key: const Key('m9s06-lease'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, vm.leaseLevel).$1,
                key: const Key('m9s06-lease-level'),
                size: 24,
                color: settingsLevelLook(cs, vm.leaseLevel).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(vm.leaseHolderLabel),
                    Text(vm.leaseStateLabel),
                    if (eta != null) Text(eta),
                    if (epoch != null) Text(epoch),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (link != null)
          InkWell(
            key: const Key('m9s06-migration'),
            onTap: () {
              _open(link);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(link.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s06-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── Row ────────────────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    super.key,
    required this.index,
    required this.row,
    required this.cs,
    required this.actions,
    required this.busy,
    required this.open,
    required this.onExpand,
    required this.onCollapse,
    required this.onRun,
  });

  final int index;
  final DeviceRow row;
  final ColorScheme cs;
  final SettingsActions? actions;
  final bool busy;
  final bool open;
  final void Function(int i) onExpand;
  final VoidCallback onCollapse;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final SettingsActions? a = actions;
    final SettingsActionCall? revoke = row.revokeAction;
    final String? confirm = row.revokeConfirmText;

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
                key: ValueKey<String>('m9s06-level-$index'),
                size: 24,
                color: settingsLevelLook(cs, row.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(row.label),
                    Text(row.roleLabel),
                    Text(row.statusLabel),
                    Text(row.lastSeenText),
                  ],
                ),
              ),
            ],
          ),
          if (a != null && revoke != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: OutlinedButton(
                key: ValueKey<String>('m9s06-revoke-$index'),
                onPressed: busy
                    ? null
                    : () {
                        onExpand(index);
                      },
                child: Text(revoke.label),
              ),
            ),
          if (open && a != null && revoke != null && confirm != null)
            Padding(
              key: ValueKey<String>('m9s06-confirm-$index'),
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(confirm),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: <Widget>[
                        OutlinedButton(
                          key: ValueKey<String>('m9s06-confirm-yes-$index'),
                          onPressed: busy
                              ? null
                              : () {
                                  unawaited(onRun(a, revoke));
                                },
                          child: Text(SettingsLabels.confirm),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          key: ValueKey<String>('m9s06-confirm-no-$index'),
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
