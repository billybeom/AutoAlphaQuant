import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';

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
/// Test and golden injection point only — a rebalance entry passes its id to
/// the [JournalTimeline] constructor instead.
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
      return _defaultQuery(ref.watch(_journalRangePresetsProvider));
    });

/// Resolves the `isDefault` range preset into a query (optionally carrying a
/// rebalance event id).
AsyncValue<JournalTimelineQuery> _defaultQuery(
  AsyncValue<List<DateRange>> presetsAsync, {
  String? rebalanceEventId,
}) {
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
        JournalTimelineQuery(range: def, rebalanceEventId: rebalanceEventId),
      );
    },
  );
}

final journalTimelineLimitProvider = StateProvider<int>((Ref ref) => 100);

// ── Rebalance entry state (one per JournalTimeline instance) ──────────────────

/// Identity of one rebalance entry: the widget instance token plus the seed id.
@immutable
class _EntryKey {
  const _EntryKey(this.token, this.seedId);

  final Object token;
  final String seedId;

  @override
  bool operator ==(Object other) =>
      other is _EntryKey && other.token == token && other.seedId == seedId;

  @override
  int get hashCode => Object.hash(token, seedId);
}

/// Explicit query of one entry plus «the seed has been used up».
@immutable
class _EntryState {
  const _EntryState({this.explicit, this.seedConsumed = false});

  final JournalTimelineQuery? explicit;
  final bool seedConsumed;
}

final _journalEntryStateProvider = StateProvider.family<_EntryState, _EntryKey>(
  (Ref ref, _EntryKey key) => const _EntryState(),
);

/// Range of the rebalance event; `null` value = unknown event.
final _journalRebalanceScopeProvider =
    StreamProvider.family<JournalRebalanceScope?, String>(
      (Ref ref, String rebalanceEventId) => ref
          .watch(journalTimelineRepositoryProvider)
          .watchRebalanceScope(rebalanceEventId),
    );

/// Entry query: explicit choice > seed (once) > default preset.
final _journalEntryEffectiveProvider =
    Provider.family<AsyncValue<JournalTimelineQuery>, _EntryKey>((
      Ref ref,
      _EntryKey key,
    ) {
      final _EntryState state = ref.watch(_journalEntryStateProvider(key));
      final JournalTimelineQuery? explicit = state.explicit;
      if (explicit != null) {
        return AsyncValue<JournalTimelineQuery>.data(explicit);
      }
      final AsyncValue<List<DateRange>> presetsAsync = ref.watch(
        _journalRangePresetsProvider,
      );
      if (state.seedConsumed) {
        return _defaultQuery(presetsAsync);
      }
      return ref
          .watch(_journalRebalanceScopeProvider(key.seedId))
          .when(
            loading: () => const AsyncValue<JournalTimelineQuery>.loading(),
            // ignore: unnecessary_lambdas
            error: (Object e, StackTrace st) =>
                AsyncValue<JournalTimelineQuery>.error(e, st),
            data: (JournalRebalanceScope? scope) => scope == null
                ? _defaultQuery(presetsAsync, rebalanceEventId: key.seedId)
                : AsyncValue<JournalTimelineQuery>.data(
                    JournalTimelineQuery(
                      range: scope.range,
                      rebalanceEventId: key.seedId,
                    ),
                  ),
          );
    });

// ── Derived stream providers ──────────────────────────────────────────────────

Stream<ListResult<TradeJournalEntry>> _watchTimelineFor(
  Ref ref,
  AsyncValue<JournalTimelineQuery> effectiveAsync,
) {
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
}

final journalTimelineProvider = StreamProvider<ListResult<TradeJournalEntry>>(
  (Ref ref) => _watchTimelineFor(ref, ref.watch(journalEffectiveQueryProvider)),
);

final _journalEntryTimelineProvider =
    StreamProvider.family<ListResult<TradeJournalEntry>, _EntryKey>(
      (Ref ref, _EntryKey key) => _watchTimelineFor(
        ref,
        ref.watch(_journalEntryEffectiveProvider(key)),
      ),
    );

/// Where one JournalTimeline instance keeps its query: the shared state
/// (no rebalance id) or its own entry state (constructor id).
@immutable
class _QuerySource {
  const _QuerySource.shared() : _key = null;
  const _QuerySource.entry(_EntryKey this._key);

  final _EntryKey? _key;

  AsyncValue<JournalTimelineQuery> watchEffective(WidgetRef ref) {
    final _EntryKey? key = _key;
    return key == null
        ? ref.watch(journalEffectiveQueryProvider)
        : ref.watch(_journalEntryEffectiveProvider(key));
  }

  AsyncValue<ListResult<TradeJournalEntry>> watchTimeline(WidgetRef ref) {
    final _EntryKey? key = _key;
    return key == null
        ? ref.watch(journalTimelineProvider)
        : ref.watch(_journalEntryTimelineProvider(key));
  }

  /// Writes a user choice; `null` = «reset» (default preset, no rebalance id).
  void write(WidgetRef ref, JournalTimelineQuery? query) {
    final _EntryKey? key = _key;
    if (key == null) {
      ref.read(journalTimelineQueryProvider.notifier).state = query;
    } else {
      ref.read(_journalEntryStateProvider(key).notifier).state = _EntryState(
        explicit: query,
        seedConsumed: true,
      );
    }
  }

  void invalidateEffective(WidgetRef ref) {
    final _EntryKey? key = _key;
    if (key == null) {
      ref.invalidate(journalEffectiveQueryProvider);
    } else {
      ref.invalidate(_journalEntryEffectiveProvider(key));
    }
    ref.invalidate(_journalRangePresetsProvider);
  }

  void invalidateTimeline(WidgetRef ref) {
    final _EntryKey? key = _key;
    if (key == null) {
      ref.invalidate(journalTimelineProvider);
    } else {
      ref.invalidate(_journalEntryTimelineProvider(key));
    }
  }
}

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
///
/// [rebalanceEventId] — entry from a rebalance event: the first query is the
/// engine range of that event plus the id. The id is only passed on to the
/// repository; it is never turned into text or dates here.
class JournalTimeline extends ConsumerStatefulWidget {
  const JournalTimeline({super.key, this.rebalanceEventId});

  final String? rebalanceEventId;

  @override
  ConsumerState<JournalTimeline> createState() => _JournalTimelineState();
}

class _JournalTimelineState extends ConsumerState<JournalTimeline> {
  /// Identity of this instance — keeps the entry state apart from other
  /// JournalTimeline instances sharing the same ProviderScope.
  Object _token = Object();

  @override
  void didUpdateWidget(JournalTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rebalanceEventId != widget.rebalanceEventId) {
      _token = Object();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? entryId = widget.rebalanceEventId;
    final _QuerySource source = entryId == null
        ? const _QuerySource.shared()
        : _QuerySource.entry(_EntryKey(_token, entryId));

    // G1: use the effective query (auto-selects isDefault preset when state==null)
    final AsyncValue<JournalTimelineQuery> effectiveQuery = source
        .watchEffective(ref);

    // While effective query is loading/error, show skeleton or error.
    if (!effectiveQuery.hasValue) {
      if (effectiveQuery.hasError) {
        return JournalErrorView(
          lastAsOfLabel: null,
          onRetry: () {
            source.invalidateEffective(ref);
            final String? id = widget.rebalanceEventId;
            if (id != null) {
              ref.invalidate(_journalRebalanceScopeProvider(id));
            }
          },
        );
      }
      return const JournalSkeleton();
    }

    // A rebalance condition is never hidden: wait for / fail with its scope.
    final String? conditionId = effectiveQuery.valueOrNull?.rebalanceEventId;
    if (conditionId != null) {
      final AsyncValue<JournalRebalanceScope?> scopeAsync = ref.watch(
        _journalRebalanceScopeProvider(conditionId),
      );
      if (!scopeAsync.hasValue) {
        if (scopeAsync.hasError) {
          return JournalErrorView(
            lastAsOfLabel: null,
            onRetry: () =>
                ref.invalidate(_journalRebalanceScopeProvider(conditionId)),
          );
        }
        return const JournalSkeleton();
      }
    }

    final AsyncValue<ListResult<TradeJournalEntry>> timeline = source
        .watchTimeline(ref);
    final AsyncValue<SafetyState> safety = ref.watch(
      journalSafetyStateProvider,
    );
    final AsyncValue<List<JournalTimelineBadge>> badges = ref.watch(
      _journalBadgesProvider,
    );
    final Clock clock = ref.watch(journalClockProvider);

    return timeline.when(
      loading: () => const JournalSkeleton(),
      error: (Object error, StackTrace stackTrace) => JournalErrorView(
        lastAsOfLabel: timeline.valueOrNull?.asOf.label,
        onRetry: () => source.invalidateTimeline(ref),
      ),
      data: (ListResult<TradeJournalEntry> result) => _TimelineContent(
        result: result,
        safety: safety.valueOrNull,
        badges: badges.valueOrNull ?? <JournalTimelineBadge>[],
        clock: clock,
        source: source,
        onLoadMore: result.hasMore ? _loadMore : null,
      ),
    );
  }

  void _loadMore() {
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
    required this.source,
    required this.onLoadMore,
  });

  final ListResult<TradeJournalEntry> result;
  final SafetyState? safety;
  final List<JournalTimelineBadge> badges;
  final Clock clock;
  final _QuerySource source;
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
          SliverToBoxAdapter(child: JournalAsOfHeader(asOf: result.asOf)),
          if (stale)
            SliverToBoxAdapter(child: JournalStaleBanner(asOf: result.asOf)),
          if (blockingFlags.isNotEmpty)
            SliverToBoxAdapter(
              child: JournalBlockingFlags(flags: blockingFlags),
            ),
          if (markerFlags.isNotEmpty)
            SliverToBoxAdapter(child: JournalMarkerChips(flags: markerFlags)),
          // ⓓ badge row — absent when empty
          if (badges.isNotEmpty)
            SliverToBoxAdapter(child: _BadgeRow(badges: badges)),
          // ⓒ filter bar
          SliverToBoxAdapter(child: _FilterBar(source: source)),
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
      backgroundColor: journalToneColor(context, badge.tone),
      // null deepLink → no tap reaction
      onPressed: link != null
          ? () => ref.read(journalLinkOpenerProvider).open(link)
          : null,
    );
  }
}

// ─── ⓒ Filter bar — horizontally scrollable chip row + bottom sheet ──────────

/// Filter bar rendered above the journal list.  All catalog data comes from the
/// repository stream providers; no selection or filtering is done here.
/// Writing selections goes to [journalTimelineQueryProvider].
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.source});

  final _QuerySource source;

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
    final JournalTimelineQuery? query = source.watchEffective(ref).valueOrNull;
    if (query == null) return const SizedBox.shrink();
    // Rebalance chip: only while the effective query carries an event id and
    // the engine knows that event (scope value non-null). Text = scope label.
    final String? rebalanceId = query.rebalanceEventId;
    final String? rebalanceChipLabel = rebalanceId == null
        ? null
        : ref
              .watch(_journalRebalanceScopeProvider(rebalanceId))
              .valueOrNull
              ?.label;

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
          // Rebalance chip — right after the range chip; ✕ clears only the id.
          if (rebalanceChipLabel != null)
            _ActiveFilterChip(
              key: const Key('j1-chip-rebalance'),
              label: rebalanceChipLabel,
              onRemove: () => source.write(ref, _clearRebalance(query)),
            ),
          // G2: active sleeve chip — absent when label is null (catalog loading).
          if (sleeveChipLabel != null)
            _ActiveFilterChip(
              label: sleeveChipLabel,
              onRemove: () => source.write(ref, _clearSleeve(query)),
            ),
          // G2: active symbol chip — absent when label is null (catalog loading).
          if (symbolChipLabel != null)
            _ActiveFilterChip(
              label: symbolChipLabel,
              onRemove: () => source.write(ref, _clearSymbol(query)),
            ),
          // G2: active status chip — absent when label is null (catalog loading).
          if (statusChipLabel != null)
            _ActiveFilterChip(
              label: statusChipLabel,
              onRemove: () => source.write(ref, _clearStatus(query)),
            ),
          // G2: active origin chip — absent when label is null (catalog loading).
          if (originChipLabel != null)
            _ActiveFilterChip(
              label: originChipLabel,
              onRemove: () => source.write(ref, _clearOrigin(query)),
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

  static JournalTimelineQuery _clearRebalance(JournalTimelineQuery q) =>
      JournalTimelineQuery(
        range: q.range,
        sleeve: q.sleeve,
        symbol: q.symbol,
        status: q.status,
        origin: q.origin,
      );

  void _showFilterSheet(
    BuildContext context, {
    required JournalTimelineQuery query,
    required List<DateRange> ranges,
    required List<SleeveCatalogEntry> sleeves,
    JournalFilterCatalog? catalog,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetCtx) => _FilterSheet(
        source: source,
        initialQuery: query,
        ranges: ranges,
        sleeves: sleeves,
        catalog: catalog,
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

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
    required this.source,
    required this.initialQuery,
    required this.ranges,
    required this.sleeves,
    required this.catalog,
  });

  final _QuerySource source;
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
    widget.source.write(
      ref,
      JournalTimelineQuery(
        range: _range,
        sleeve: _sleeve,
        symbol: _symbol,
        status: _status,
        origin: _origin,
        rebalanceEventId: widget.initialQuery.rebalanceEventId,
      ),
    );
    Navigator.of(context).pop();
  }

  void _reset() {
    // G1: «초기화» = write null → effective query reverts to the isDefault
    // preset without any rebalance id. Close sheet so the screen reflects reset.
    widget.source.write(ref, null);
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
      children.add(JournalEntryCard(entry: entry));
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
