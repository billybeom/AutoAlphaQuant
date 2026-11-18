// Backup and restore screen — M9 S09.
// Shows last backup status, restore points (display only), and a
// backup action button when the engine supplies one.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

final _vmProvider = StreamProvider<BackupVm>(
  (ref) => ref.watch(settingsOpsStatusRepositoryProvider).watchBackup(),
);

class BackupRestore extends ConsumerStatefulWidget {
  const BackupRestore({super.key});

  @override
  ConsumerState<BackupRestore> createState() => _BackupRestoreState();
}

class _BackupRestoreState extends ConsumerState<BackupRestore> {
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

  void _open(LinkAction link) {
    ref.read(settingsLinkOpenerProvider).open(link.deepLink);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BackupVm> data = ref.watch(_vmProvider);
    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s09-fail'),
        onRetry: () {
          ref.invalidate(_vmProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }
    if (!data.hasValue) {
      return const SettingsSkeleton(key: Key('m9s09-loading'));
    }
    final BackupVm vm = data.requireValue;
    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);

    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? locked = vm.lockedLabel;
    final SettingsActionCall? run = vm.runAction;
    final String? notice = vm.noticeText;
    final LinkAction? migration = vm.migrationLink;
    final ActionResult? r = _result;
    final String? reasonCode = r?.reasonCode;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s09-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s09-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        Padding(
          key: const Key('m9s09-last'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, vm.level).$1,
                key: const Key('m9s09-level'),
                size: 24,
                color: settingsLevelLook(cs, vm.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(vm.lastBackupText),
                    if (vm.ageBadgeText case final String badge) Text(badge),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (actions != null && run != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('m9s09-run'),
                onPressed: _busy
                    ? null
                    : () {
                        unawaited(_run(actions, run));
                      },
                child: Text(run.label),
              ),
            ),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s09-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s09-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s09-result-level'),
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
        if (notice != null)
          Padding(
            key: const Key('m9s09-notice'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(notice),
          ),
        Padding(
          key: const Key('m9s09-points'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final (int i, RestorePointRow p) in vm.points.indexed)
                Padding(
                  key: ValueKey<String>('m9s09-point-$i'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(p.label),
                      Text(p.chainHashText),
                      if (p.stateLabel case final String state) Text(state),
                    ],
                  ),
                ),
              if (vm.pointsEmptyLabel case final String empty) Text(empty),
            ],
          ),
        ),
        if (migration != null)
          InkWell(
            key: const Key('m9s09-migration'),
            onTap: () {
              _open(migration);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(migration.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s09-asof'), asOf: vm.asOf),
      ],
    );
  }
}
