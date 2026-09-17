import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';

/// J-1 timeline repository — supplied by the application composition root.
final journalTimelineRepositoryProvider = Provider<JournalRepository>(
  (Ref ref) => throw UnimplementedError('journalTimelineRepositoryProvider'),
);

/// J-1 safety repository — supplied by the application composition root.
final journalSafetyRepositoryProvider = Provider<SafetyRepository>(
  (Ref ref) => throw UnimplementedError('journalSafetyRepositoryProvider'),
);

/// J-1 clock — supplied by the application composition root (or test override).
/// Used only for stale-data detection (01 §1-3 · A4 · F3).
/// 🔴 DateTime.now() is forbidden — always inject this Clock.
final journalClockProvider = Provider<Clock>(
  (Ref ref) => throw UnimplementedError('journalClockProvider'),
);

/// The range and filters used by the J-1 timeline query.
/// limit/withLimit removed (F8) — limit comes from journalTimelineLimitProvider.
@immutable
class JournalTimelineQuery {
  const JournalTimelineQuery({
    required this.range,
    this.sleeve,
    this.symbol,
    this.status,
    this.origin,
    this.rebalanceEventId,
  });

  final DateRange range;
  final SleeveId? sleeve;
  final String? symbol;
  final JournalStatus? status;
  final FillOrigin? origin;
  final String? rebalanceEventId;
}

final journalTimelineQueryProvider = Provider<JournalTimelineQuery>(
  (Ref ref) => throw UnimplementedError('journalTimelineQueryProvider'),
);

final journalTimelineLimitProvider = StateProvider<int>((Ref ref) => 100);

final journalTimelineProvider = StreamProvider<ListResult<TradeJournalEntry>>((
  Ref ref,
) {
  final JournalTimelineQuery query = ref.watch(journalTimelineQueryProvider);
  final int limit = ref.watch(journalTimelineLimitProvider);
  return ref
      .watch(journalTimelineRepositoryProvider)
      .watchTimeline(
        range: query.range,
        sleeve: query.sleeve,
        symbol: query.symbol,
        status: query.status,
        origin: query.origin,
        rebalanceEventId: query.rebalanceEventId,
        limit: limit,
      );
});

final journalSafetyStateProvider = StreamProvider<SafetyState>(
  (Ref ref) => ref.watch(journalSafetyRepositoryProvider).watchState(),
);

/// J-1 매매일지 타임라인.
///
/// Renders repository output verbatim — does not derive display values.
/// Fills the height given by its parent (no fixed top padding — the shell (M8)
/// stacks the simulation banner outside this widget).
class JournalTimeline extends ConsumerWidget {
  const JournalTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ListResult<TradeJournalEntry>> timeline = ref.watch(
      journalTimelineProvider,
    );
    final AsyncValue<SafetyState> safety = ref.watch(
      journalSafetyStateProvider,
    );
    final Clock clock = ref.watch(journalClockProvider);

    return timeline.when(
      loading: () => const _TimelineSkeleton(),
      error: (Object error, StackTrace stackTrace) => _TimelineError(
        lastAsOfLabel: timeline.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(journalTimelineProvider),
      ),
      data: (ListResult<TradeJournalEntry> result) => _TimelineContent(
        result: result,
        safety: safety.valueOrNull,
        clock: clock,
        onLoadMore: result.hasMore ? () => _loadMore(ref) : null,
      ),
    );
  }

  void _loadMore(WidgetRef ref) {
    ref.read(journalTimelineLimitProvider.notifier).state += 100;
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({
    required this.result,
    required this.safety,
    required this.clock,
    required this.onLoadMore,
  });

  final ListResult<TradeJournalEntry> result;
  final SafetyState? safety;
  final Clock clock;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final List<BlockFlag> flags = safety?.activeFlags ?? <BlockFlag>[];

    // Separate marker-only flags (info chips) from blocking flags (warning cards).
    final List<BlockFlag> blockingFlags = flags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    final List<BlockFlag> markerFlags = flags
        .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
        .toList();

    // LEDGER_INTEGRITY hides engine-computed values (quantity/price/commission/tax).
    final bool integrityBlocked = blockingFlags.any(
      (BlockFlag f) => f.flagId == FlagIds.ledgerIntegrity,
    );

    // Stale detection: observedAt + staleAfter < now (A4 · F3).
    final bool stale = result.asOf.observedAt
        .add(result.asOf.staleAfter)
        .isBefore(clock.nowUtc());

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter == 0) {
          onLoadMore?.call();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _AsOfHeader(asOf: result.asOf)),
          if (stale) SliverToBoxAdapter(child: _StaleBanner(asOf: result.asOf)),
          if (blockingFlags.isNotEmpty)
            SliverToBoxAdapter(child: _BlockingFlags(flags: blockingFlags)),
          if (markerFlags.isNotEmpty)
            SliverToBoxAdapter(child: _MarkerChips(flags: markerFlags)),
          if (result.rows.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(result: result),
            )
          else
            _JournalRows(
              rows: result.rows,
              integrityBlocked: integrityBlocked,
              onLoadMore: onLoadMore,
            ),
        ],
      ),
    );
  }
}

// ─── Stale banner (F3 / A4) ───────────────────────────────────────────────────

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(JournalLabels.staleBannerTitle),
          if (asOf.staleLabel != null) Text(asOf.staleLabel!),
        ],
      ),
    );
  }
}

// ─── As-of header ─────────────────────────────────────────────────────────────

class _AsOfHeader extends StatelessWidget {
  const _AsOfHeader({required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(asOf.label),
    );
  }
}

// ─── Blocking flags — top-2 cards + overflow count (F4 / A5) ─────────────────

class _BlockingFlags extends StatelessWidget {
  const _BlockingFlags({required this.flags});

  final List<BlockFlag> flags;

  @override
  Widget build(BuildContext context) {
    // Engine-sorted order — do NOT re-sort (A5 rule).
    final int overflowCount = flags.length > 2 ? flags.length - 2 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...flags.take(2).map(_BlockFlagCard.new),
        if (overflowCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('+$overflowCount'),
          ),
      ],
    );
  }
}

class _BlockFlagCard extends StatelessWidget {
  const _BlockFlagCard(this.flag);

  final BlockFlag flag;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: Text(flag.label),
        subtitle: Text(flag.clearInstruction),
      ),
    );
  }
}

// ─── Marker-only flags — grey info chip row (F4b / A5) ────────────────────────

class _MarkerChips extends StatelessWidget {
  const _MarkerChips({required this.flags});

  final List<BlockFlag> flags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: flags
            .map(
              (BlockFlag f) => Chip(
                label: Text(f.label),
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

// ─── Journal rows ─────────────────────────────────────────────────────────────

class _JournalRows extends StatelessWidget {
  const _JournalRows({
    required this.rows,
    required this.integrityBlocked,
    required this.onLoadMore,
  });

  final List<TradeJournalEntry> rows;
  final bool integrityBlocked;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    String? previousTradeDate;
    for (final TradeJournalEntry entry in rows) {
      if (entry.tradeDate.yyyyMmDd != previousTradeDate) {
        children.add(_DateHeader(label: entry.tradeDate.yyyyMmDd));
        previousTradeDate = entry.tradeDate.yyyyMmDd;
      }
      children.add(
        _JournalRow(entry: entry, integrityBlocked: integrityBlocked),
      );
    }
    return SliverList(delegate: SliverChildListDelegate(children));
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.entry, required this.integrityBlocked});

  final TradeJournalEntry entry;
  final bool integrityBlocked;

  @override
  Widget build(BuildContext context) {
    final bool isPrevented = entry.statusTone == ChipTone.prevented;

    // SIM rows rendered in greyscale (F5 / A6).
    Widget card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header row: chips ──────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                if (entry.mode.isSim)
                  const Chip(label: Text(JournalLabels.simulation)),
                Chip(label: Text(entry.statusLabel)),
                if (entry.deviation.isDeviation)
                  Chip(label: Text(entry.deviation.label)),
                if (isPrevented) const Icon(Icons.lock_outline, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            // ── Symbol + account alias ─────────────────────────────────────
            Text(entry.symbolLabel),
            if (entry.accountAlias != null) Text(entry.accountAlias!),
            const SizedBox(height: 6),
            // ── Trade values (hidden when LEDGER_INTEGRITY blocks) ─────────
            // side.wire and visibilityLabel are always visible (A5 rule).
            Text(entry.side.wire),
            if (!integrityBlocked) ...<Widget>[
              Text(entry.quantity.toString()),
              Text(entry.price.toString()),
              Text('${JournalLabels.commission}: ${entry.commission}'),
              Text('${JournalLabels.tax}: ${entry.tax}'),
            ],
            Text(entry.visibilityLabel),
            // ── Metadata ───────────────────────────────────────────────────
            Text(entry.originLabel),
            if (entry.backdate.isBackdated) Text(entry.backdate.label),
            Text(entry.costSourceLabel),
            // ── Reason chips ───────────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                ...entry.reasons
                    .take(3)
                    .map((ReasonChip r) => Chip(label: Text(r.label))),
                if (entry.reasons.length > 3)
                  Text('+${entry.reasons.length - 3}'),
              ],
            ),
          ],
        ),
      ),
    );

    // Greyscale filter for SIM rows (F5 / A6).
    if (entry.mode.isSim) {
      card = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: card,
      );
    }

    return card;
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.result});

  final ListResult<TradeJournalEntry> result;

  @override
  Widget build(BuildContext context) {
    final String? label = switch (result.emptyKind) {
      EmptyKind.noData => result.emptyLabel,
      EmptyKind.notApplicable => result.emptyLabel,
      EmptyKind.notLoaded => result.asOf.staleLabel,
    };
    return label == null ? const SizedBox.shrink() : Center(child: Text(label));
  }
}

// ─── Skeleton (loading state) ─────────────────────────────────────────────────

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => const Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SizedBox(height: 132),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.onRetry, this.lastAsOfLabel});

  final VoidCallback onRetry;
  final String? lastAsOfLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (lastAsOfLabel != null) Text(lastAsOfLabel!),
          FilledButton(
            onPressed: onRetry,
            child: const Text(JournalLabels.retry),
          ),
        ],
      ),
    );
  }
}
