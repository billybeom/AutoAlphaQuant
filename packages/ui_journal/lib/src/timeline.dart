import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';

// ── Injection providers ───────────────────────────────────────────────────────

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

/// 🆕 v1.1 — ConfigRepository for range presets and sleeves (ⓒ 필터).
/// Supplied by the application composition root.
final journalConfigRepositoryProvider = Provider<ConfigRepository>(
  (Ref ref) => throw UnimplementedError('journalConfigRepositoryProvider'),
);

/// 🆕 v1.1 — AppLinkOpener for all navigation (ⓔ 이동). §11-1.
/// Supplied by the application composition root.
final journalLinkOpenerProvider = Provider<AppLinkOpener>(
  (Ref ref) => throw UnimplementedError('journalLinkOpenerProvider'),
);

// ── Filter state ──────────────────────────────────────────────────────────────

/// The range and filters representing the user's current J-1 selection.
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

/// Mutable filter state (G1 · §4-1 · §11-3).
///
/// Default value is `null` = «user has not chosen yet».
/// [journalEffectiveQueryProvider] resolves null to the `isDefault` preset.
/// Composition root may override with an initial query (e.g. rebalance event).
/// Filter «reset» writes null → screen reverts to default preset automatically.
final journalTimelineQueryProvider = StateProvider<JournalTimelineQuery?>(
  (Ref ref) => null,
);

/// Derived effective query (G1 · §11-3).
///
/// - state != null  → that value (user has made a selection or app injected one)
/// - state == null  → resolves to [_journalRangePresetsProvider] `isDefault` item
///   - presets loading  → `AsyncValue.loading()`
///   - presets loaded but no `isDefault` item (contract violation — C-34 guards)
///     → `AsyncValue.error(...)` (screen shows retry)
final journalEffectiveQueryProvider =
    Provider<AsyncValue<JournalTimelineQuery>>((Ref ref) {
      final JournalTimelineQuery? explicit = ref.watch(
        journalTimelineQueryProvider,
      );
      if (explicit != null) {
        return AsyncValue<JournalTimelineQuery>.data(explicit);
      }
      // Resolve from presets.
      final AsyncValue<List<DateRange>> presetsAsync = ref.watch(
        _journalRangePresetsProvider,
      );
      return presetsAsync.when(
        loading: () => const AsyncValue<JournalTimelineQuery>.loading(),
        // ignore: unnecessary_lambdas
        error: (Object e, StackTrace st) =>
            AsyncValue<JournalTimelineQuery>.error(e, st),
        data: (List<DateRange> presets) {
          final DateRange? def = presets.cast<DateRange?>().firstWhere(
            (DateRange? r) => r!.isDefault,
            orElse: () => null,
          );
          if (def == null) {
            return AsyncValue<JournalTimelineQuery>.error(
              StateError(
                'No isDefault preset in rangePresets — contract violation.',
              ),
              StackTrace.current,
            );
          }
          return AsyncValue<JournalTimelineQuery>.data(
            JournalTimelineQuery(range: def),
          );
        },
      );
    });

final journalTimelineLimitProvider = StateProvider<int>((Ref ref) => 100);

// ── Derived stream providers ──────────────────────────────────────────────────

final journalTimelineProvider = StreamProvider<ListResult<TradeJournalEntry>>((
  Ref ref,
) {
  final AsyncValue<JournalTimelineQuery> effectiveAsync = ref.watch(
    journalEffectiveQueryProvider,
  );
  final int limit = ref.watch(journalTimelineLimitProvider);
  // While loading/error, emit empty stream so the screen shows skeleton/error.
  final JournalTimelineQuery? query = effectiveAsync.valueOrNull;
  if (query == null) {
    return const Stream<ListResult<TradeJournalEntry>>.empty();
  }
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

/// 🆕 v1.1 — range presets from ConfigRepository (ⓒ).
final _journalRangePresetsProvider = StreamProvider<List<DateRange>>(
  (Ref ref) => ref.watch(journalConfigRepositoryProvider).watchRangePresets(),
);

/// 🆕 v1.1 — sleeve catalog from ConfigRepository (ⓒ).
final _journalSleeveCatalogProvider = StreamProvider<List<SleeveCatalogEntry>>(
  (Ref ref) => ref.watch(journalConfigRepositoryProvider).watchSleeves(),
);

/// 🆕 v1.1 — filter catalog from JournalRepository (ⓒ).
final _journalFilterCatalogProvider = StreamProvider<JournalFilterCatalog>(
  (Ref ref) =>
      ref.watch(journalTimelineRepositoryProvider).watchFilterCatalog(),
);

/// 🆕 v1.1 — timeline badges from JournalRepository (ⓓ).
final _journalBadgesProvider = StreamProvider<List<JournalTimelineBadge>>(
  (Ref ref) =>
      ref.watch(journalTimelineRepositoryProvider).watchTimelineBadges(),
);

// ── Root widget ───────────────────────────────────────────────────────────────

/// J-1 매매일지 타임라인.
///
/// Renders repository output verbatim — does not derive display values.
/// Fills the height given by its parent (no fixed top padding — the shell (M8)
/// stacks the simulation banner outside this widget).
class JournalTimeline extends ConsumerWidget {
  const JournalTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // G1: use the effective query (auto-selects isDefault preset when state==null)
    final AsyncValue<JournalTimelineQuery> effectiveQuery = ref.watch(
      journalEffectiveQueryProvider,
    );

    // While effective query is loading/error, show skeleton or error.
    if (!effectiveQuery.hasValue) {
      if (effectiveQuery.hasError) {
        return _TimelineError(
          lastAsOfLabel: null,
          onRetry: () {
            ref.invalidate(journalEffectiveQueryProvider);
            ref.invalidate(_journalRangePresetsProvider);
          },
        );
      }
      return const _TimelineSkeleton();
    }

    final AsyncValue<ListResult<TradeJournalEntry>> timeline = ref.watch(
      journalTimelineProvider,
    );
    final AsyncValue<SafetyState> safety = ref.watch(
      journalSafetyStateProvider,
    );
    final AsyncValue<List<JournalTimelineBadge>> badges = ref.watch(
      _journalBadgesProvider,
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
        badges: badges.valueOrNull ?? <JournalTimelineBadge>[],
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
    required this.badges,
    required this.clock,
    required this.onLoadMore,
  });

  final ListResult<TradeJournalEntry> result;
  final SafetyState? safety;
  final List<JournalTimelineBadge> badges;
  final Clock clock;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final List<BlockFlag> flags = safety?.activeFlags ?? <BlockFlag>[];

    // Separate marker-only flags (info chips) from blocking flags (warning cards).
    // markerOnly membership drives banner vs info-chip — no other logic here.
    final List<BlockFlag> blockingFlags = flags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    final List<BlockFlag> markerFlags = flags
        .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
        .toList();

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
          // ⓓ badge row — absent when empty
          if (badges.isNotEmpty)
            SliverToBoxAdapter(child: _BadgeRow(badges: badges)),
          // ⓒ filter bar
          const SliverToBoxAdapter(child: _FilterBar()),
          if (result.rows.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(result: result),
            )
          else
            _JournalRows(rows: result.rows, onLoadMore: onLoadMore),
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
        ...flags.take(2).map((BlockFlag f) => _BlockFlagCard(flag: f)),
        if (overflowCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('+$overflowCount'),
          ),
      ],
    );
  }
}

/// ⓔ Banner card — arrow present only when clearDeepLink is non-null (§11-4).
class _BlockFlagCard extends ConsumerWidget {
  const _BlockFlagCard({required this.flag});

  final BlockFlag flag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? clearLink = flag.clearDeepLink;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded),
                const SizedBox(width: 8),
                Expanded(child: Text(flag.label)),
                // ⓔ arrow ABSENT (not disabled) when clearDeepLink == null
                if (clearLink != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () =>
                        ref.read(journalLinkOpenerProvider).open(clearLink),
                  ),
              ],
            ),
            Text(flag.clearInstruction),
            // ⓔ checkpointLabel — rendered only when non-null
            if (flag.checkpointLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  flag.checkpointLabel!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
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

// ─── ⓓ Badge row — rendered only when non-empty ──────────────────────────────

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badges});

  final List<JournalTimelineBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: badges
            .map((JournalTimelineBadge b) => _BadgeChip(badge: b))
            .toList(growable: false),
      ),
    );
  }
}

class _BadgeChip extends ConsumerWidget {
  const _BadgeChip({required this.badge});

  final JournalTimelineBadge badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = badge.deepLink;
    return ActionChip(
      label: Text(badge.label),
      backgroundColor: _toneColor(context, badge.tone),
      // null deepLink → no tap reaction
      onPressed: link != null
          ? () => ref.read(journalLinkOpenerProvider).open(link)
          : null,
    );
  }

  static Color _toneColor(BuildContext context, ChipTone tone) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return switch (tone) {
      ChipTone.caution => cs.errorContainer,
      ChipTone.blocked => cs.error,
      ChipTone.neutral => cs.surfaceContainerHighest,
      ChipTone.prevented => cs.surfaceContainerHighest,
    };
  }
}

// ─── ⓒ Filter bar — horizontally scrollable chip row + bottom sheet ──────────

/// Filter bar rendered above the journal list.  All catalog data comes from the
/// repository stream providers; no selection or filtering is done here.
/// Writing selections goes to [journalTimelineQueryProvider].
class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DateRange>> rangesAsync = ref.watch(
      _journalRangePresetsProvider,
    );
    final AsyncValue<List<SleeveCatalogEntry>> sleevesAsync = ref.watch(
      _journalSleeveCatalogProvider,
    );
    final AsyncValue<JournalFilterCatalog> catalogAsync = ref.watch(
      _journalFilterCatalogProvider,
    );
    // G1: read the effective query (never null at this point — JournalTimeline
    // guards above, but valueOrNull is safe as a fallback).
    final JournalTimelineQuery? query = ref
        .watch(journalEffectiveQueryProvider)
        .valueOrNull;
    if (query == null) return const SizedBox.shrink();

    final List<SleeveCatalogEntry>? sleeves = sleevesAsync.valueOrNull;
    final JournalFilterCatalog? catalog = catalogAsync.valueOrNull;

    // G2: compute chip labels — null means catalog not yet loaded → hide chip.
    final String? sleeveChipLabel = query.sleeve != null
        ? _sleeveLabel(query.sleeve!, sleeves)
        : null;
    final String? symbolChipLabel = query.symbol != null
        ? _symbolLabel(query.symbol!, catalog)
        : null;
    final String? statusChipLabel = query.status != null
        ? _statusLabel(query.status!, catalog)
        : null;
    final String? originChipLabel = query.origin != null
        ? _originLabel(query.origin!, catalog)
        : null;

    // G3: range chip only shown when label is non-null.
    final String? rangeChipLabel = query.range.label;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          // "필터" trigger chip
          ActionChip(
            avatar: const Icon(Icons.tune, size: 16),
            label: const Text(JournalLabels.filter),
            onPressed: () => _showFilterSheet(
              context,
              ref,
              query: query,
              ranges: rangesAsync.valueOrNull ?? <DateRange>[],
              sleeves: sleeves ?? <SleeveCatalogEntry>[],
              catalog: catalog,
            ),
          ),
          const SizedBox(width: 6),
          // G3: range chip absent when label is null.
          if (rangeChipLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(label: Text(rangeChipLabel)),
            ),
          // G2: active sleeve chip — absent when label is null (catalog loading).
          if (sleeveChipLabel != null)
            _ActiveFilterChip(
              label: sleeveChipLabel,
              onRemove: () => _writeQuery(ref, _clearSleeve(query)),
            ),
          // G2: active symbol chip — absent when label is null (catalog loading).
          if (symbolChipLabel != null)
            _ActiveFilterChip(
              label: symbolChipLabel,
              onRemove: () => _writeQuery(ref, _clearSymbol(query)),
            ),
          // G2: active status chip — absent when label is null (catalog loading).
          if (statusChipLabel != null)
            _ActiveFilterChip(
              label: statusChipLabel,
              onRemove: () => _writeQuery(ref, _clearStatus(query)),
            ),
          // G2: active origin chip — absent when label is null (catalog loading).
          if (originChipLabel != null)
            _ActiveFilterChip(
              label: originChipLabel,
              onRemove: () => _writeQuery(ref, _clearOrigin(query)),
            ),
        ],
      ),
    );
  }

  // ── label helpers — return null when catalog is not yet loaded (G2) ─────────

  static String? _sleeveLabel(
    SleeveId sleeve,
    List<SleeveCatalogEntry>? entries,
  ) {
    if (entries == null) return null;
    for (final SleeveCatalogEntry e in entries) {
      if (e.sleeve == sleeve) return e.label;
    }
    return null;
  }

  static String? _symbolLabel(String symbol, JournalFilterCatalog? catalog) {
    if (catalog == null) return null;
    for (final SymbolOption s in catalog.symbolOptions) {
      if (s.symbol == symbol) return s.label;
    }
    return null;
  }

  static String? _statusLabel(
    JournalStatus status,
    JournalFilterCatalog? catalog,
  ) {
    if (catalog == null) return null;
    for (final JournalStatusOption o in catalog.statusOptions) {
      if (o.status == status) return o.label;
    }
    return null;
  }

  static String? _originLabel(
    FillOrigin origin,
    JournalFilterCatalog? catalog,
  ) {
    if (catalog == null) return null;
    for (final FillOriginOption o in catalog.originOptions) {
      if (o.origin == origin) return o.label;
    }
    return null;
  }

  // ── query mutation helpers — produce a new query, no row filtering ─────────

  static JournalTimelineQuery _clearSleeve(JournalTimelineQuery q) =>
      JournalTimelineQuery(
        range: q.range,
        symbol: q.symbol,
        status: q.status,
        origin: q.origin,
        rebalanceEventId: q.rebalanceEventId,
      );

  static JournalTimelineQuery _clearSymbol(JournalTimelineQuery q) =>
      JournalTimelineQuery(
        range: q.range,
        sleeve: q.sleeve,
        status: q.status,
        origin: q.origin,
        rebalanceEventId: q.rebalanceEventId,
      );

  static JournalTimelineQuery _clearStatus(JournalTimelineQuery q) =>
      JournalTimelineQuery(
        range: q.range,
        sleeve: q.sleeve,
        symbol: q.symbol,
        origin: q.origin,
        rebalanceEventId: q.rebalanceEventId,
      );

  static JournalTimelineQuery _clearOrigin(JournalTimelineQuery q) =>
      JournalTimelineQuery(
        range: q.range,
        sleeve: q.sleeve,
        symbol: q.symbol,
        status: q.status,
        rebalanceEventId: q.rebalanceEventId,
      );

  static void _writeQuery(WidgetRef ref, JournalTimelineQuery q) {
    ref.read(journalTimelineQueryProvider.notifier).state = q;
  }

  void _showFilterSheet(
    BuildContext context,
    WidgetRef ref, {
    required JournalTimelineQuery query,
    required List<DateRange> ranges,
    required List<SleeveCatalogEntry> sleeves,
    JournalFilterCatalog? catalog,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetCtx) => _FilterSheet(
        initialQuery: query,
        ranges: ranges,
        sleeves: sleeves,
        catalog: catalog,
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({
    required this.initialQuery,
    required this.ranges,
    required this.sleeves,
    required this.catalog,
  });

  final JournalTimelineQuery initialQuery;
  final List<DateRange> ranges;
  final List<SleeveCatalogEntry> sleeves;
  final JournalFilterCatalog? catalog;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late DateRange _range;
  SleeveId? _sleeve;
  String? _symbol;
  JournalStatus? _status;
  FillOrigin? _origin;

  @override
  void initState() {
    super.initState();
    _range = widget.initialQuery.range;
    _sleeve = widget.initialQuery.sleeve;
    _symbol = widget.initialQuery.symbol;
    _status = widget.initialQuery.status;
    _origin = widget.initialQuery.origin;
  }

  void _apply() {
    // ⓒ Passes selected values straight to watchTimeline args — no row filtering.
    // A14: rebalanceEventId is carried from the initial query unchanged — the
    // filter sheet has no field for it and must not drop it.
    ref
        .read(journalTimelineQueryProvider.notifier)
        .state = JournalTimelineQuery(
      range: _range,
      sleeve: _sleeve,
      symbol: _symbol,
      status: _status,
      origin: _origin,
      rebalanceEventId: widget.initialQuery.rebalanceEventId,
    );
    Navigator.of(context).pop();
  }

  void _reset() {
    // G1: «초기화» = write null to StateProvider → effective query reverts to
    // isDefault preset automatically. Close sheet so the screen reflects reset.
    ref.read(journalTimelineQueryProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final JournalFilterCatalog? catalog = widget.catalog;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext ctx, ScrollController sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                JournalLabels.filter,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: _reset,
                child: const Text(JournalLabels.filterReset),
              ),
            ],
          ),
          const Divider(),

          // ── 기간 ──
          Text(JournalLabels.filterRange),
          // G3: skip presets whose label is null (nothing to show).
          Wrap(
            spacing: 6,
            children: widget.ranges
                .where((DateRange r) => r.label != null)
                .map(
                  (DateRange r) => ChoiceChip(
                    label: Text(r.label!),
                    selected: _range.presetCode == r.presetCode,
                    onSelected: (_) => setState(() => _range = r),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 8),

          // ── 슬리브 ──
          Text(JournalLabels.filterSleeve),
          Wrap(
            spacing: 6,
            children: <Widget>[
              ChoiceChip(
                label: const Text(JournalLabels.filterAll),
                selected: _sleeve == null,
                onSelected: (_) => setState(() => _sleeve = null),
              ),
              ...widget.sleeves.map(
                (SleeveCatalogEntry s) => ChoiceChip(
                  label: Text(s.label),
                  selected: _sleeve == s.sleeve,
                  onSelected: (_) => setState(() => _sleeve = s.sleeve),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── 종목·상태·출처 (catalog may not be loaded yet) ──
          if (catalog != null) ...<Widget>[
            Text(JournalLabels.filterSymbol),
            Wrap(
              spacing: 6,
              children: <Widget>[
                ChoiceChip(
                  label: const Text(JournalLabels.filterAll),
                  selected: _symbol == null,
                  onSelected: (_) => setState(() => _symbol = null),
                ),
                ...catalog.symbolOptions.map(
                  (SymbolOption s) => ChoiceChip(
                    label: Text(s.label),
                    selected: _symbol == s.symbol,
                    onSelected: (_) => setState(() => _symbol = s.symbol),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(JournalLabels.filterStatus),
            Wrap(
              spacing: 6,
              children: <Widget>[
                ChoiceChip(
                  label: const Text(JournalLabels.filterAll),
                  selected: _status == null,
                  onSelected: (_) => setState(() => _status = null),
                ),
                ...catalog.statusOptions.map(
                  (JournalStatusOption o) => ChoiceChip(
                    label: Text(o.label),
                    selected: _status == o.status,
                    onSelected: (_) => setState(() => _status = o.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(JournalLabels.filterOrigin),
            Wrap(
              spacing: 6,
              children: <Widget>[
                ChoiceChip(
                  label: const Text(JournalLabels.filterAll),
                  selected: _origin == null,
                  onSelected: (_) => setState(() => _origin = null),
                ),
                ...catalog.originOptions.map(
                  (FillOriginOption o) => ChoiceChip(
                    label: Text(o.label),
                    selected: _origin == o.origin,
                    onSelected: (_) => setState(() => _origin = o.origin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _apply,
              child: const Text(JournalLabels.filterApply),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Journal rows ─────────────────────────────────────────────────────────────

class _JournalRows extends StatelessWidget {
  const _JournalRows({required this.rows, required this.onLoadMore});

  final List<TradeJournalEntry> rows;
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
      children.add(_JournalRow(entry: entry));
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

/// ⓐ Renders display strings (*Text · sideLabel) — never raw values.
/// ⓑ No screen-side hiding — *Text already contains "숨김" / "120주?" from engine.
/// ⓔ Row tap opens entry.detailDeepLink; null → no reaction.
class _JournalRow extends ConsumerWidget {
  const _JournalRow({required this.entry});

  final TradeJournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPrevented = entry.statusTone == ChipTone.prevented;
    final String? detailLink = entry.detailDeepLink;

    Widget card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Status / deviation / prevented chips ───────────────────────
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
            // ── ⓐ Direction and values — *Text only; raw values not shown ─
            Text(entry.sideLabel),
            Text(entry.quantityText),
            Text(entry.priceText),
            Text('${JournalLabels.commission}: ${entry.commissionText}'),
            Text('${JournalLabels.tax}: ${entry.taxText}'),
            Text(entry.visibilityLabel),
            // ── Metadata ───────────────────────────────────────────────────
            Text(entry.originLabel),
            if (entry.backdate.isBackdated) Text(entry.backdate.label),
            Text(entry.costSourceLabel),
            // ── ⓔ Reason chips — chip tap opens chip.detailDeepLink ───────
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                ...entry.reasons
                    .take(3)
                    .map((ReasonChip r) => _ReasonChipWidget(chip: r)),
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

    // ⓔ Row tap — present only when detailDeepLink is non-null.
    if (detailLink != null) {
      return InkWell(
        onTap: () => ref.read(journalLinkOpenerProvider).open(detailLink),
        child: card,
      );
    }
    return card;
  }
}

// ─── ⓔ Reason chip with optional tap ─────────────────────────────────────────

class _ReasonChipWidget extends ConsumerWidget {
  const _ReasonChipWidget({required this.chip});

  final ReasonChip chip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = chip.detailDeepLink;
    if (link != null) {
      return ActionChip(
        label: Text(chip.label),
        onPressed: () => ref.read(journalLinkOpenerProvider).open(link),
      );
    }
    return Chip(label: Text(chip.label));
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
