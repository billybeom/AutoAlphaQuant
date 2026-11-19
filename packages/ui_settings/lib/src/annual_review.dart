// Annual review entry screen - M9 S12.
// Shows the received year line, window state line, contents rows and
// pledge link exactly as received; only opens the received link on tap.
// Nothing is written and nothing is computed here.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/settings_common.dart';
import 'settings_providers.dart';

final _vmProvider = StreamProvider<AnnualReviewIndexVm>(
  (ref) => ref.watch(settingsOpsStatusRepositoryProvider).watchAnnualReview(),
);

class AnnualReviewEntry extends ConsumerWidget {
  const AnnualReviewEntry({super.key});

  void _open(WidgetRef ref, LinkAction link) {
    ref.read(settingsLinkOpenerProvider).open(link.deepLink);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AnnualReviewIndexVm> data = ref.watch(_vmProvider);
    if (data.hasError) {
      return SettingsErrorView(
        key: const Key('m9s12-fail'),
        onRetry: () {
          ref.invalidate(_vmProvider);
        },
        lastAsOfLabel: data.valueOrNull?.asOf.label,
      );
    }
    if (!data.hasValue) {
      return const SettingsSkeleton(key: Key('m9s12-loading'));
    }
    final AnnualReviewIndexVm vm = data.requireValue;
    final Clock clock = ref.watch(settingsClockProvider);

    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final LinkAction? pledge = vm.pledgeLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s12-stale'), asOf: vm.asOf),
        Padding(
          key: const Key('m9s12-head'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[Text(vm.yearLabel), Text(vm.windowStateLabel)],
          ),
        ),
        Column(
          key: const Key('m9s12-entries'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (int i, LinkAction entry) in vm.entries.indexed)
              InkWell(
                key: ValueKey<String>('m9s12-entry-$i'),
                onTap: () {
                  _open(ref, entry);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(entry.label)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (pledge != null)
          InkWell(
            key: const Key('m9s12-pledge'),
            onTap: () {
              _open(ref, pledge);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(pledge.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        SettingsAsOfLine(key: const Key('m9s12-asof'), asOf: vm.asOf),
      ],
    );
  }
}
