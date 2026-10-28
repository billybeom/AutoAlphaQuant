import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

// ── Injection providers ───────────────────────────────────────────────────────

/// L-1·L-2 원장 읽기 창구 — 조립 앱이 override 한다(01 §21-8).
final journalLedgerRepositoryProvider = Provider<LedgerRepository>(
  (Ref ref) => throw UnimplementedError('journalLedgerRepositoryProvider'),
);

/// 원장 신뢰 창구 — L-3(R5e)가 import 한다(이 카드는 선언만 · 부르는 곳 0).
final journalLedgerTrustRepositoryProvider = Provider<LedgerTrustRepository>(
  (Ref ref) => throw UnimplementedError('journalLedgerTrustRepositoryProvider'),
);

// ── Data provider ─────────────────────────────────────────────────────────────

final _ledgerDiffsProvider = StreamProvider<ListResult<LedgerDiffRow>>(
  (Ref ref) => ref.watch(journalLedgerRepositoryProvider).watchOpenDiffs(),
);

// ── Severity icon/color helper ────────────────────────────────────────────────

(IconData, Color) _severityLook(ColorScheme cs, DiffSeverity s) => switch (s) {
  DiffSeverity.blocking => (Icons.block, cs.error),
  DiffSeverity.observational => (
    Icons.visibility_outlined,
    cs.onSurfaceVariant,
  ),
};

// ── Public tile ───────────────────────────────────────────────────────────────

/// L-1 차이 1행 조각 — L-3(R5e) 가 재사용한다.
class LedgerDiffTile extends ConsumerWidget {
  const LedgerDiffTile({super.key, required this.row});

  final LedgerDiffRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (IconData, Color) look = _severityLook(
      Theme.of(context).colorScheme,
      row.severity,
    );
    final LinkAction? action = row.actionLink;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(look.$1, color: look.$2, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(row.pairLabel)),
              ],
            ),
            Text(row.axisLabel),
            Text(row.severityLabel),
            Text(row.deltaLabel),
            Text(row.statusLabel),
            Text(row.routeLabel),
            const Text(JournalLabels.ledgerCandidateOrigins),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                for (final ReasonChip c in row.candidateOrigins)
                  JournalReasonChip(chip: c),
              ],
            ),
            Text(row.detectedAtText),
            Row(
              children: <Widget>[
                const Text(JournalLabels.ledgerEvidence),
                const SizedBox(width: 6),
                Flexible(child: Text(row.evidenceHash)),
              ],
            ),
            if (action != null)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: () {
                    ref.read(journalLinkOpenerProvider).open(action.deepLink);
                  },
                  child: Text(action.label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// L-1 원장 차이 상세.
class LedgerDiffs extends ConsumerWidget {
  const LedgerDiffs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<ListResult<LedgerDiffRow>> list = ref.watch(
      _ledgerDiffsProvider,
    );
    return list.when(
      loading: () => const JournalSkeleton(key: Key('l1-loading')),
      error: (Object e, StackTrace s) => JournalErrorView(
        key: const Key('l1-fail'),
        lastAsOfLabel: list.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(_ledgerDiffsProvider),
      ),
      data: (ListResult<LedgerDiffRow> v) =>
          _buildBody(context, ref, v, clock, safety),
    );
  }

  bool _isStale(ListResult<LedgerDiffRow> v, Clock clock) =>
      v.asOf.observedAt.add(v.asOf.staleAfter).isBefore(clock.nowUtc());

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ListResult<LedgerDiffRow> list,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? empty = list.emptyLabel;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('l1-asof'), asOf: list.asOf),
        if (_isStale(list, clock)) JournalStaleBanner(asOf: list.asOf),
        JournalSafetyBanners(safety: safety),
        for (final (int i, LedgerDiffRow r) in list.rows.indexed)
          LedgerDiffTile(key: ValueKey<String>('l1-row-$i'), row: r),
        if (list.rows.isEmpty && empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('l1-empty')),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('l1-repairs-link'),
              onPressed: () {
                ref
                    .read(journalLinkOpenerProvider)
                    .open(AppRoutes.ledgerRepairs);
              },
              child: const Text(JournalLabels.ledgerRepairsLink),
            ),
          ),
        ),
      ],
    );
  }
}
