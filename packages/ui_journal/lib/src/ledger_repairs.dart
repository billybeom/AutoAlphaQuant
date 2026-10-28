import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/journal_common.dart';
import 'ledger_diffs.dart';
import 'timeline.dart';

// ── Data provider ─────────────────────────────────────────────────────────────

final _ledgerRepairsProvider = StreamProvider<ListResult<LedgerRepairRow>>(
  (Ref ref) => ref.watch(journalLedgerRepositoryProvider).watchRepairs(),
);

// ── Screen ────────────────────────────────────────────────────────────────────

/// L-2 정정 이력·감사.
class LedgerRepairs extends ConsumerWidget {
  const LedgerRepairs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<ListResult<LedgerRepairRow>> list = ref.watch(
      _ledgerRepairsProvider,
    );
    return list.when(
      loading: () => const JournalSkeleton(key: Key('l2-loading')),
      error: (Object e, StackTrace s) => JournalErrorView(
        key: const Key('l2-fail'),
        lastAsOfLabel: list.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(_ledgerRepairsProvider),
      ),
      data: (ListResult<LedgerRepairRow> v) =>
          _buildBody(context, ref, v, clock, safety),
    );
  }

  bool _isStale(ListResult<LedgerRepairRow> v, Clock clock) =>
      v.asOf.observedAt.add(v.asOf.staleAfter).isBefore(clock.nowUtc());

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ListResult<LedgerRepairRow> list,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? empty = list.emptyLabel;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('l2-asof'), asOf: list.asOf),
        if (_isStale(list, clock)) JournalStaleBanner(asOf: list.asOf),
        JournalSafetyBanners(safety: safety),
        for (final (int i, LedgerRepairRow r) in list.rows.indexed)
          _RepairRow(key: ValueKey<String>('l2-row-$i'), row: r),
        if (list.rows.isEmpty && empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('l2-empty')),
          ),
      ],
    );
  }
}

// ── Private repair row ────────────────────────────────────────────────────────

class _RepairRow extends ConsumerWidget {
  const _RepairRow({super.key, required this.row});

  final LedgerRepairRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? superseded = row.supersededLabel;
    final LinkAction? link = row.decisionLink;
    return Padding(
      padding: EdgeInsets.fromLTRB(row.supersedes == null ? 16 : 40, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Chip(
            label: Text(row.directionLabel),
            backgroundColor: journalToneColor(context, row.directionTone),
          ),
          Text(row.label),
          Text(row.originLabel),
          Text(row.targetText),
          Text(row.appliedAtText),
          if (superseded != null) Text(superseded),
          Row(
            children: <Widget>[
              Flexible(child: Text(row.chainStampText)),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  unawaited(
                    Clipboard.setData(ClipboardData(text: row.chainStampText)),
                  );
                },
              ),
            ],
          ),
          if (link != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  ref.read(journalLinkOpenerProvider).open(link.deepLink);
                },
                child: Text(link.label),
              ),
            ),
        ],
      ),
    );
  }
}
