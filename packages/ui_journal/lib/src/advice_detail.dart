import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'advice/advice_card.dart';
import 'advice_inbox.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

final _adviceDetailProvider = FutureProvider.family<AdviceItem?, String>(
  (Ref ref, String id) =>
      ref.watch(journalAdviceRepositoryProvider).findById(id),
);

final _adviceFillsProvider =
    FutureProvider.family<List<TradeJournalEntry>, String>(
      (Ref ref, String id) =>
          ref.watch(journalAdviceRepositoryProvider).fillsOfAdvice(id),
    );

/// A-2 안내 상세 — 계획의 근거를 읽기만 한다. 수량·지정가 편집 0.
///
/// 스냅샷은 결정 링크 하나로 갈음하고, 체결은 받은 순서 그대로 그린다.
class AdviceDetail extends ConsumerWidget {
  const AdviceDetail({super.key, required String adviceId}) : _id = adviceId;

  final String _id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<AdviceItem?> detail = ref.watch(
      _adviceDetailProvider(_id),
    );
    return detail.when(
      loading: () => const JournalSkeleton(key: Key('a2-loading')),
      error: (Object e, StackTrace s) => JournalErrorView(
        key: const Key('a2-fail'),
        onRetry: () => ref.invalidate(_adviceDetailProvider(_id)),
      ),
      data: (AdviceItem? v) {
        if (v == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(JournalLabels.adviceNotFound, key: Key('a2-absent')),
          );
        }
        return _buildBody(ref, v, clock, safety);
      },
    );
  }

  Widget _buildBody(
    WidgetRef ref,
    AdviceItem item,
    Clock clock,
    SafetyState? safety,
  ) {
    final bool stale = item.asOf.observedAt
        .add(item.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? close = item.closeReasonLabel;
    final LinkAction? decision = item.decisionLink;
    final AsyncValue<List<TradeJournalEntry>> fills = ref.watch(
      _adviceFillsProvider(_id),
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('a2-asof'), asOf: item.asOf),
        if (stale) JournalStaleBanner(asOf: item.asOf),
        JournalSafetyBanners(safety: safety),
        AdviceCard(key: const Key('a2-card'), item: item),
        if (close != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(close, key: const Key('a2-close-reason')),
          ),
        Padding(
          key: const Key('a2-deviation'),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: <Widget>[
              for (final ReasonChip c in item.recordedDeviationChips)
                JournalReasonChip(chip: c),
            ],
          ),
        ),
        if (decision != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('a2-decision'),
                onPressed: () {
                  ref.read(journalLinkOpenerProvider).open(decision.deepLink);
                },
                child: Text(decision.label),
              ),
            ),
          ),
        ..._fillsBlock(ref, fills),
      ],
    );
  }

  List<Widget> _fillsBlock(
    WidgetRef ref,
    AsyncValue<List<TradeJournalEntry>> fills,
  ) => fills.when(
    loading: () => <Widget>[],
    error: (Object e, StackTrace s) => <Widget>[
      JournalErrorView(
        key: const Key('a2-fills-fail'),
        onRetry: () => ref.invalidate(_adviceFillsProvider(_id)),
      ),
    ],
    data: (List<TradeJournalEntry> rows) => rows.isEmpty
        ? <Widget>[]
        : <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                JournalLabels.adviceRecordedFills,
                key: Key('a2-fills-title'),
              ),
            ),
            for (final (int i, TradeJournalEntry e) in rows.indexed)
              JournalEntryCard(key: ValueKey<String>('a2-fill-$i'), entry: e),
          ],
  );
}
