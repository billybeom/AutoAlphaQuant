import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'advice/advice_card.dart';
import 'advice_inbox.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

final _adviceRangePresetsProvider = StreamProvider<List<DateRange>>(
  (Ref ref) => ref.watch(journalConfigRepositoryProvider).watchRangePresets(),
);

final _adviceHistoryProvider =
    StreamProvider.family<ListResult<AdviceItem>, DateRange>(
      (Ref ref, DateRange range) =>
          ref.watch(journalAdviceRepositoryProvider).watchHistory(range: range),
    );

const JournalSkeleton _historySkeleton = JournalSkeleton(
  key: Key('ah-loading'),
);

Widget _historyFail(VoidCallback onRetry, String? lastAsOf) => JournalErrorView(
  key: const Key('ah-fail'),
  lastAsOfLabel: lastAsOf,
  onRetry: onRetry,
);

/// 지난 안내 — 엔진 기본 범위 한 건의 안내를 받은 순서 그대로 그린다.
class AdviceHistory extends ConsumerWidget {
  const AdviceHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<List<DateRange>> presets = ref.watch(
      _adviceRangePresetsProvider,
    );
    return presets.when(
      loading: () => _historySkeleton,
      error: (Object e, StackTrace s) =>
          _historyFail(() => ref.invalidate(_adviceRangePresetsProvider), null),
      data: (List<DateRange> list) => _buildPicked(ref, list, clock, safety),
    );
  }

  Widget _buildPicked(
    WidgetRef ref,
    List<DateRange> presets,
    Clock clock,
    SafetyState? safety,
  ) {
    DateRange? picked;
    for (final DateRange r in presets) {
      if (picked == null && r.isDefault) {
        picked = r;
      }
    }
    if (picked == null) {
      return _historySkeleton;
    }
    final DateRange range = picked;
    final AsyncValue<ListResult<AdviceItem>> history = ref.watch(
      _adviceHistoryProvider(range),
    );
    return history.when(
      loading: () => _historySkeleton,
      error: (Object e, StackTrace s) => _historyFail(
        () => ref.invalidate(_adviceHistoryProvider(range)),
        history.valueOrNull?.asOf.label,
      ),
      data: (ListResult<AdviceItem> v) =>
          _buildBody(ref, v, range, clock, safety),
    );
  }

  bool _isStale(ListResult<AdviceItem> list, Clock clock) =>
      list.asOf.observedAt.add(list.asOf.staleAfter).isBefore(clock.nowUtc());

  Widget _buildBody(
    WidgetRef ref,
    ListResult<AdviceItem> list,
    DateRange range,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? rangeLabel = range.label;
    final String? empty = list.emptyLabel;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('ah-asof'), asOf: list.asOf),
        if (_isStale(list, clock)) JournalStaleBanner(asOf: list.asOf),
        JournalSafetyBanners(safety: safety),
        if (rangeLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(rangeLabel, key: const Key('ah-range')),
          ),
        for (final (int i, AdviceItem item) in list.rows.indexed)
          InkWell(
            key: ValueKey<String>('ah-row-$i'),
            onTap: () {
              ref.read(journalLinkOpenerProvider).open(item.detailDeepLink);
            },
            child: AdviceCard(item: item),
          ),
        if (list.rows.isEmpty && empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('ah-empty')),
          ),
      ],
    );
  }
}
