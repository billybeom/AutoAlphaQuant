// lib/src/operations.dart
//
// Operations — M9 S05 parts 1–2 (R6c1 · R6c2) (contract v1.19).
//
// 🔴 Body only — parent height ListView(padding: EdgeInsets.zero).
// 🔴 Chip, mode card, operating way card, trial card = received as-is.
//    No sorting, filtering, counting, merging of the two axes.
// 🔴 Write = one action call per tap (_run) + one open of the received route.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<OperationsVm> _operationsProvider =
    StreamProvider<OperationsVm>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchOperations(),
    );

// ── Gate look ──────────────────────────────────────────────────────────────────

(IconData, Color) _gateLook(ColorScheme cs, GateState s) => switch (s) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};

// ── Operations ─────────────────────────────────────────────────────────────────

/// M9 S05 operations management, parts 1–2 (R6c1 · R6c2).
class Operations extends ConsumerStatefulWidget {
  const Operations({super.key});

  @override
  ConsumerState<Operations> createState() => _OperationsState();
}

class _OperationsState extends ConsumerState<Operations> {
  bool _busy = false;
  bool _failed = false;
  ActionResult? _result;

  Future<void> _run(SettingsActions a, SettingsActionCall call) async {
    setState(() => _busy = true);
    final ActionResult r;
    try {
      r = await a.run(call.id, args: call.args);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
        _result = null;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = false;
      _result = r;
    });
    final String? route = r.handoffRoute;
    if (route != null) {
      ref.read(settingsLinkOpenerProvider).open(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<OperationsVm> data = ref.watch(_operationsProvider);

    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s05-fail'),
        onRetry: () {
          ref.invalidate(_operationsProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }

    final OperationsVm? vm = data.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s05-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ActionResult? r = _result;
    final String? locked = vm.lockedLabel;
    final String? promotionLabel = vm.statusChip.promotionLabel;
    final SimTrialCard? trial = vm.trial;
    final String? lastRequest = vm.lastRequestNotice;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s05-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s05-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        if (_failed)
          Padding(
            key: const Key('m9s05-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (r != null)
          Padding(
            key: const Key('m9s05-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, r.level).$1,
                      key: const Key('m9s05-result-level'),
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
        Padding(
          key: const Key('m9s05-chip'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, vm.statusChip.level).$1,
                key: const Key('m9s05-chip-level'),
                size: 24,
                color: settingsLevelLook(cs, vm.statusChip.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(vm.statusChip.label),
                    if (promotionLabel != null) Text(promotionLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ModeCard(
          key: const Key('m9s05-mode'),
          mode: vm.mode,
          cs: cs,
          actions: actions,
          busy: _busy,
          onRun: _run,
        ),
        _OperatingModeCard(
          key: const Key('m9s05-opmode'),
          view: vm.operatingMode,
          cs: cs,
          actions: actions,
          busy: _busy,
          onRun: _run,
        ),
        if (trial != null)
          _TrialCard(key: const Key('m9s05-trial'), trial: trial, cs: cs),
        _RampView(key: const Key('m9s05-ramp'), ramp: vm.ramp, cs: cs),
        for (final (int j, JobRow job) in vm.jobs.indexed)
          _JobView(
            key: ValueKey<String>('m9s05-job-$j'),
            index: j,
            job: job,
            cs: cs,
          ),
        _ControlView(
          key: const Key('m9s05-control'),
          control: vm.control,
          cs: cs,
          actions: actions,
          busy: _busy,
          onRun: _run,
        ),
        if (vm.updateGate != null)
          _UpdateView(
            key: const Key('m9s05-update'),
            gate: vm.updateGate!,
            cs: cs,
          ),
        if (lastRequest != null)
          Padding(
            key: const Key('m9s05-last-request'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(lastRequest),
          ),
        SettingsAsOfLine(key: const Key('m9s05-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── _ModeCard ──────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.mode,
    required this.cs,
    required this.actions,
    required this.busy,
    required this.onRun,
  });

  final RunModeCard mode;
  final ColorScheme cs;
  final SettingsActions? actions;
  final bool busy;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final SettingsActions? a = actions;
    final String? hold = mode.holdLabel;
    final LiveDryRunObservationVm? o = mode.observation;
    final SettingsActionCall? promotion = mode.promotionAction;
    final String? notice = mode.switchNoticeText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, mode.level).$1,
                key: const Key('m9s05-mode-level'),
                size: 24,
                color: settingsLevelLook(cs, mode.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(mode.label)),
            ],
          ),
          if (hold != null)
            Padding(
              key: const Key('m9s05-hold'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(hold),
            ),
          if (o != null)
            Padding(
              key: const Key('m9s05-observation'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Text(o.progressText), Text(o.stateLabel)],
              ),
            ),
          if (a != null && promotion != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: OutlinedButton(
                key: const Key('m9s05-promote'),
                onPressed: busy
                    ? null
                    : () {
                        unawaited(onRun(a, promotion));
                      },
                child: Text(promotion.label),
              ),
            ),
          if (notice != null)
            Padding(
              key: const Key('m9s05-notice'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(notice),
            ),
          if (a != null)
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final (int i, SettingsActionCall call)
                      in mode.switchActions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        key: ValueKey<String>('m9s05-switch-$i'),
                        onPressed: busy
                            ? null
                            : () {
                                unawaited(onRun(a, call));
                              },
                        child: Text(call.label),
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

// ── _OperatingModeCard ─────────────────────────────────────────────────────────

class _OperatingModeCard extends StatelessWidget {
  const _OperatingModeCard({
    super.key,
    required this.view,
    required this.cs,
    required this.actions,
    required this.busy,
    required this.onRun,
  });

  final OperatingModeView view;
  final ColorScheme cs;
  final SettingsActions? actions;
  final bool busy;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final SettingsActions? a = actions;
    final String? hint = view.trust.upgradeHint;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(view.label),
          Text(view.explainLine),
          for (final (int o, OperatingModeOption option)
              in view.options.indexed)
            Padding(
              key: ValueKey<String>('m9s05-option-$o'),
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(option.title),
                  Text(option.body),
                  Text(option.prepLine),
                  Text(option.honestyLine),
                ],
              ),
            ),
          Padding(
            key: const Key('m9s05-trust'),
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  settingsLevelLook(cs, view.trust.level).$1,
                  key: const Key('m9s05-trust-level'),
                  size: 24,
                  color: settingsLevelLook(cs, view.trust.level).$2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(view.trust.label),
                      Text(view.trust.consequenceLine),
                      if (hint != null) Text(hint),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final (int g, GateBadge gate) in view.switchGates.indexed)
            Padding(
              key: ValueKey<String>('m9s05-gate-$g'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    _gateLook(cs, gate.state).$1,
                    key: ValueKey<String>('m9s05-gate-level-$g'),
                    size: 24,
                    color: _gateLook(cs, gate.state).$2,
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: Text(gate.label)),
                ],
              ),
            ),
          if (a != null)
            Padding(
              padding: EdgeInsets.zero,
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final (int i, SettingsActionCall call)
                      in view.switchActions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        key: ValueKey<String>('m9s05-opswitch-$i'),
                        onPressed: busy
                            ? null
                            : () {
                                unawaited(onRun(a, call));
                              },
                        child: Text(call.label),
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

// ── _TrialCard ─────────────────────────────────────────────────────────────────

class _TrialCard extends StatelessWidget {
  const _TrialCard({super.key, required this.trial, required this.cs});

  final SimTrialCard trial;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(trial.headline),
          Text(trial.summaryText),
          for (final (int i, SimTrialCheck check) in trial.checks.indexed)
            Padding(
              key: ValueKey<String>('m9s05-check-$i'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    settingsLevelLook(cs, check.level).$1,
                    key: ValueKey<String>('m9s05-check-level-$i'),
                    size: 24,
                    color: settingsLevelLook(cs, check.level).$2,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(check.label),
                        Text(check.stateLabel),
                        Text(check.detailText),
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

// ── R6c2 — board ──────────────────────────────────────────────────────────────

class _RampView extends StatelessWidget {
  const _RampView({super.key, required this.ramp, required this.cs});

  final RampBoard ramp;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final String? dst = ramp.dstNoticeText;
    final String? empty = ramp.emptyLabel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, ramp.level).$1,
                key: const Key('m9s05-ramp-level'),
                size: 24,
                color: settingsLevelLook(cs, ramp.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(ramp.levelLabel)),
            ],
          ),
          if (dst != null)
            Padding(
              key: const Key('m9s05-dst'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(dst),
            ),
          if (empty != null)
            Padding(
              key: const Key('m9s05-ramp-empty'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(empty),
            ),
          for (final (int k, RampCondition condition)
              in ramp.conditions.indexed)
            Padding(
              key: ValueKey<String>('m9s05-cond-$k'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    settingsLevelLook(cs, condition.level).$1,
                    key: ValueKey<String>('m9s05-cond-level-$k'),
                    size: 24,
                    color: settingsLevelLook(cs, condition.level).$2,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(condition.label),
                        Text(condition.progressText),
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

// ──

class _JobView extends StatelessWidget {
  const _JobView({
    super.key,
    required this.index,
    required this.job,
    required this.cs,
  });

  final int index;
  final JobRow job;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final String? detail = job.detailLine;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            settingsLevelLook(cs, job.level).$1,
            key: ValueKey<String>('m9s05-job-level-$index'),
            size: 24,
            color: settingsLevelLook(cs, job.level).$2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(job.label),
                Text(job.stateLabel),
                Text(job.scheduleText),
                Text(job.lastRunText),
                if (detail != null) Text(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──

class _ControlView extends StatelessWidget {
  const _ControlView({
    super.key,
    required this.control,
    required this.cs,
    required this.actions,
    required this.busy,
    required this.onRun,
  });

  final EngineControl control;
  final ColorScheme cs;
  final SettingsActions? actions;
  final bool busy;
  final Future<void> Function(SettingsActions a, SettingsActionCall call) onRun;

  @override
  Widget build(BuildContext context) {
    final SettingsActions? a = actions;
    final SettingsActionCall? startAction = control.startAction;
    final String? prompt = control.stopPromptText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, control.level).$1,
                key: const Key('m9s05-control-level'),
                size: 24,
                color: settingsLevelLook(cs, control.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(control.stateLabel)),
            ],
          ),
          if (a != null && startAction != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: OutlinedButton(
                key: const Key('m9s05-start'),
                onPressed: busy
                    ? null
                    : () {
                        unawaited(onRun(a, startAction));
                      },
                child: Text(startAction.label),
              ),
            ),
          if (prompt != null)
            Padding(
              key: const Key('m9s05-reason-prompt'),
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(prompt),
            ),
          if (a != null)
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final (int i, SettingsActionCall call)
                      in control.stopActions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        key: ValueKey<String>('m9s05-stop-$i'),
                        onPressed: busy
                            ? null
                            : () {
                                unawaited(onRun(a, call));
                              },
                        child: Text(call.label),
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

// ──

class _UpdateView extends StatelessWidget {
  const _UpdateView({super.key, required this.gate, required this.cs});

  final UpdateGateCard gate;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            settingsLevelLook(cs, gate.level).$1,
            key: const Key('m9s05-update-level'),
            size: 24,
            color: settingsLevelLook(cs, gate.level).$2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[Text(gate.stateLabel), Text(gate.bodyText)],
            ),
          ),
        ],
      ),
    );
  }
}
