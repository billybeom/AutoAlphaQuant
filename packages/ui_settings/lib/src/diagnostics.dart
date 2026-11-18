// Diagnostics screen - M9 S10.
// Shows two self-test cards (golden vectors and ledger integrity), the
// reconciliation board exactly as received, and a diffs link. Each card
// has one run button only when the engine supplies its run call.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/settings_common.dart';
import 'settings_providers.dart';

final _vmProvider = StreamProvider<DiagnosticsScreenVm>(
  (ref) => ref.watch(settingsRepositoryProvider).watchDiagnosticsScreen(),
);

class _CardRun {
  bool busy = false;
  bool failed = false;
  ActionResult? result;
}

class Diagnostics extends ConsumerStatefulWidget {
  const Diagnostics({super.key});

  @override
  ConsumerState<Diagnostics> createState() => _DiagnosticsState();
}

class _DiagnosticsState extends ConsumerState<Diagnostics> {
  final _CardRun _golden = _CardRun();
  final _CardRun _integrity = _CardRun();

  Future<void> _run(
    SettingsActions a,
    SettingsActionCall call,
    _CardRun s,
  ) async {
    setState(() => s.busy = true);
    try {
      final ActionResult r = await a.run(call.id, args: call.args);
      if (!mounted) return;
      setState(() {
        s.busy = false;
        s.failed = false;
        s.result = r;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        s.busy = false;
        s.failed = true;
        s.result = null;
      });
    }
  }

  void _open(LinkAction link) {
    ref.read(settingsLinkOpenerProvider).open(link.deepLink);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DiagnosticsScreenVm> data = ref.watch(_vmProvider);
    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s10-fail'),
        onRetry: () {
          ref.invalidate(_vmProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }
    if (!data.hasValue) {
      return const SettingsSkeleton(key: Key('m9s10-loading'));
    }
    final DiagnosticsScreenVm vm = data.requireValue;
    final Clock clock = ref.watch(settingsClockProvider);
    final SettingsActions? actions = ref.watch(settingsActionsProvider);

    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? locked = vm.lockedLabel;
    final String? recommend = vm.recommendText;
    final SelfTestCard golden = vm.golden;
    final SelfTestCard integrity = vm.integrity;
    final SettingsActionCall? goldenRun = golden.runAction;
    final SettingsActionCall? integrityRun = integrity.runAction;
    final LinkAction? diffs = vm.diffsLink;
    final ActionResult? gr = _golden.result;
    final String? grCode = gr?.reasonCode;
    final ActionResult? ir = _integrity.result;
    final String? irCode = ir?.reasonCode;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s10-stale'), asOf: vm.asOf),
        if (locked != null)
          Padding(
            key: const Key('m9s10-locked'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(locked),
          ),
        if (recommend != null)
          Padding(
            key: const Key('m9s10-recommend'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(recommend),
          ),
        Padding(
          key: const Key('m9s10-golden'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, golden.level).$1,
                key: const Key('m9s10-golden-level'),
                size: 24,
                color: settingsLevelLook(cs, golden.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(golden.title),
                    Text(golden.statusLabel),
                    if (golden.lastRunText case final String last) Text(last),
                    if (golden.summaryText case final String summary)
                      Text(summary),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (actions != null && goldenRun != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('m9s10-golden-run'),
                onPressed: _golden.busy
                    ? null
                    : () {
                        unawaited(_run(actions, goldenRun, _golden));
                      },
                child: Text(goldenRun.label),
              ),
            ),
          ),
        if (_golden.failed)
          Padding(
            key: const Key('m9s10-golden-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (gr != null)
          Padding(
            key: const Key('m9s10-golden-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, gr.level).$1,
                      key: const Key('m9s10-golden-result-level'),
                      size: 24,
                      color: settingsLevelLook(cs, gr.level).$2,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(gr.headline)),
                  ],
                ),
                if (grCode != null) Text(grCode),
              ],
            ),
          ),
        Padding(
          key: const Key('m9s10-integrity'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, integrity.level).$1,
                key: const Key('m9s10-integrity-level'),
                size: 24,
                color: settingsLevelLook(cs, integrity.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(integrity.title),
                    Text(integrity.statusLabel),
                    if (integrity.lastRunText case final String last)
                      Text(last),
                    if (integrity.summaryText case final String summary)
                      Text(summary),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          key: const Key('m9s10-board'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final (int i, DiagnosticCell cell) in vm.board.cells.indexed)
                Padding(
                  key: ValueKey<String>('m9s10-cell-$i'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        settingsLevelLook(cs, cell.level).$1,
                        key: ValueKey<String>('m9s10-signal-$i'),
                        size: 24,
                        color: settingsLevelLook(cs, cell.level).$2,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(cell.label)),
                      Expanded(child: Text(cell.stateLabel)),
                    ],
                  ),
                ),
              Text(vm.board.headline),
            ],
          ),
        ),
        if (actions != null && integrityRun != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('m9s10-integrity-run'),
                onPressed: _integrity.busy
                    ? null
                    : () {
                        unawaited(_run(actions, integrityRun, _integrity));
                      },
                child: Text(integrityRun.label),
              ),
            ),
          ),
        if (_integrity.failed)
          Padding(
            key: const Key('m9s10-integrity-not-accepted'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(SettingsLabels.notAccepted),
          ),
        if (ir != null)
          Padding(
            key: const Key('m9s10-integrity-result'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      settingsLevelLook(cs, ir.level).$1,
                      key: const Key('m9s10-integrity-result-level'),
                      size: 24,
                      color: settingsLevelLook(cs, ir.level).$2,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ir.headline)),
                  ],
                ),
                if (irCode != null) Text(irCode),
              ],
            ),
          ),
        if (diffs != null)
          InkWell(
            key: const Key('m9s10-diffs'),
            onTap: () {
              _open(diffs);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(diffs.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s10-asof'), asOf: vm.asOf),
      ],
    );
  }
}
