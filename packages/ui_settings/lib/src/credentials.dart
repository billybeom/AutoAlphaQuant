// lib/src/credentials.dart
//
// Credentials — M9 S02 broker credential management (contract v1.20).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Card count and order = received as-is. No sorting, filtering, counting.
// 🔴 Received strings are drawn as-is. Slot name goes only to the injected builder.
// 🔴 Write = SettingsActions action called once per tap (_run). Links open once (_open).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<CredentialListVm> _credentialsProvider =
    StreamProvider<CredentialListVm>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchCredentials(),
    );

// ── Credentials ────────────────────────────────────────────────────────────────

/// M9 S02 broker credential management.
class Credentials extends ConsumerStatefulWidget {
  const Credentials({super.key});

  @override
  ConsumerState<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends ConsumerState<Credentials> {
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
    final AsyncValue<CredentialListVm> data = ref.watch(_credentialsProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s02-fail'),
        onRetry: () {
          ref.invalidate(_credentialsProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final CredentialListVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s02-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);
    final SettingsSlotBuilder? slot = ref.watch(settingsSlotBuilderProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ActionResult? r = _result;
    final LinkAction? runbook = vm.leakRunbookLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s02-stale'), asOf: vm.asOf),
        if (vm.lockedLabel != null)
          Padding(
            key: const Key('m9s02-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(vm.lockedLabel!),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s02-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s02-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s02-result-level'),
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
        if (vm.modeNotice != null)
          Padding(
            key: const Key('m9s02-notice'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(vm.modeNotice!),
          ),
        for (final (int i, CredentialCardVm card) in vm.cards.indexed)
          _CredentialCard(
            key: ValueKey<String>('m9s02-card-$i'),
            index: i,
            card: card,
            cs: cs,
            actions: actions,
            slot: slot,
            busy: _busy,
            onRun: _run,
            onOpen: _open,
          ),
        if (runbook != null)
          InkWell(
            key: const Key('m9s02-runbook'),
            onTap: () {
              _open(runbook);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(runbook.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s02-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── _CredentialCard ────────────────────────────────────────────────────────────

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({
    super.key,
    required this.index,
    required this.card,
    required this.cs,
    required this.actions,
    required this.slot,
    required this.busy,
    required this.onRun,
    required this.onOpen,
  });

  final int index;
  final CredentialCardVm card;
  final ColorScheme cs;
  final SettingsActions? actions;
  final SettingsSlotBuilder? slot;
  final bool busy;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;
  final void Function(LinkAction link) onOpen;

  @override
  Widget build(BuildContext context) {
    final String? sealLabel = card.sealLabel;
    final String? slotId = card.credentialSlotId;
    final SettingsSlotBuilder? place = slot;
    final SettingsActions? a = actions;
    final SettingsActionCall? verify = card.verifyAction;
    final LinkAction? rotate = card.rotateLink;
    final String? expires = card.expiresText;
    final String? verified = card.lastVerifiedText;
    final String? requirement = card.requirementLabel;
    final String? why = card.whyLine;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, card.level).$1,
                key: ValueKey<String>('m9s02-level-$index'),
                size: 24,
                color: settingsLevelLook(cs, card.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(card.kindLabel),
                    Text(card.healthLabel),
                    Text(card.usageLabel),
                    if (expires != null) Text(expires),
                    if (verified != null) Text(verified),
                    if (requirement != null) Text(requirement),
                    if (why != null) Text(why),
                  ],
                ),
              ),
            ],
          ),
          if (sealLabel != null)
            Padding(
              key: ValueKey<String>('m9s02-seal-$index'),
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Text(sealLabel),
            ),
          if (place != null && slotId != null)
            Padding(
              key: ValueKey<String>('m9s02-slot-$index'),
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: place(slotId),
            ),
          if (a != null && verify != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: OutlinedButton(
                key: ValueKey<String>('m9s02-verify-$index'),
                onPressed: busy
                    ? null
                    : () {
                        unawaited(onRun(a, verify));
                      },
                child: Text(verify.label),
              ),
            ),
          if (rotate != null)
            InkWell(
              key: ValueKey<String>('m9s02-rotate-$index'),
              onTap: () {
                onOpen(rotate);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 36, top: 8, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(rotate.label)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
