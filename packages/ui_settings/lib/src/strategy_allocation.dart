// Strategy allocation screen - M9 S04 (first board, view only).
// Renders the current allocation card, read-only sections, and change path
// exactly as received from the engine, in the received order.
// Nothing is written, opened or computed here.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/settings_common.dart';
import 'settings_providers.dart';

final _vmProvider = StreamProvider<AllocationEditorVm>(
  (ref) => ref.watch(settingsRepositoryProvider).watchAllocationEditor(),
);

class StrategyAllocation extends ConsumerWidget {
  const StrategyAllocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AllocationEditorVm> data = ref.watch(_vmProvider);
    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s04-fail'),
        onRetry: () {
          ref.invalidate(_vmProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }
    if (!data.hasValue) {
      return const SettingsSkeleton(key: Key('m9s04-loading'));
    }
    final AllocationEditorVm vm = data.requireValue;
    final Clock clock = ref.watch(settingsClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s04-stale'), asOf: vm.asOf),
        Padding(
          key: const Key('m9s04-current'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(vm.current.label),
              Text(vm.current.weightsText),
              Text(vm.current.backtestText),
              Text(vm.current.honestNoteText),
            ],
          ),
        ),
        Column(
          key: const Key('m9s04-sections'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (int i, AllocationReadOnlySection section)
                in vm.sections.indexed)
              Column(
                key: ValueKey<String>('m9s04-section-$i'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(section.title),
                  ),
                  for (final (int j, AllocationReadOnlyRow row)
                      in section.rows.indexed)
                    Padding(
                      key: ValueKey<String>('m9s04-row-$i-$j'),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(row.label),
                          Text(row.valueText),
                          if (row.noteText case final String note) Text(note),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
        Padding(
          key: const Key('m9s04-path'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final String line in vm.changePathLines) Text(line),
            ],
          ),
        ),
        SettingsAsOfLine(key: const Key('m9s04-asof'), asOf: vm.asOf),
      ],
    );
  }
}
