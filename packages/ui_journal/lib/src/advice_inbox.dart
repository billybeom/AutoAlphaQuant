import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'advice/advice_card.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

/// A-1·A-2·A-3·A-4·지난 안내의 안내 읽기 창구 — 조립 앱이 override 한다(01 §21-8).
final journalAdviceRepositoryProvider = Provider<AdviceRepository>(
  (Ref ref) => throw UnimplementedError('journalAdviceRepositoryProvider'),
);

/// 만료 확인 카드의 명령 하나 — 조립 앱이 override 한다(K14 ⓐ · 탭 콜백 안 ref.read 만).
final journalAdviceCommandApiProvider = Provider<CommandApi>(
  (Ref ref) => throw UnimplementedError('journalAdviceCommandApiProvider'),
);

final _adviceInboxProvider = StreamProvider<ListResult<AdviceItem>>(
  (Ref ref) => ref.watch(journalAdviceRepositoryProvider).watchInbox(),
);

final _adviceSummaryProvider = StreamProvider<AdviceInboxSummary>(
  (Ref ref) => ref.watch(journalAdviceRepositoryProvider).watchSummary(),
);

/// A-1 오늘의 매매 안내 — 받은 순서 그대로 그리는 인박스(주문 화면이 아니다).
class AdviceInbox extends ConsumerStatefulWidget {
  const AdviceInbox({super.key});

  @override
  ConsumerState<AdviceInbox> createState() => _AdviceInboxState();
}

class _AdviceInboxState extends ConsumerState<AdviceInbox> {
  final Map<AdviceItem, String> _deferLabel = <AdviceItem, String>{};
  final Map<AdviceItem, bool> _deferBusy = <AdviceItem, bool>{};
  final Map<AdviceItem, bool> _deferFailed = <AdviceItem, bool>{};

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AdviceInboxSummary? summary = ref
        .watch(_adviceSummaryProvider)
        .valueOrNull;
    final AsyncValue<ListResult<AdviceItem>> inbox = ref.watch(
      _adviceInboxProvider,
    );
    return inbox.when(
      loading: () => const JournalSkeleton(key: Key('a1-loading')),
      error: (Object e, StackTrace s) =>
          _buildFail(summary, inbox.valueOrNull?.asOf.label),
      data: (ListResult<AdviceItem> v) => _buildBody(v, summary, clock, safety),
    );
  }

  Widget _buildFail(AdviceInboxSummary? summary, String? lastAsOf) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (summary != null) _SummaryBlock(summary: summary),
        JournalErrorView(
          key: const Key('a1-fail'),
          lastAsOfLabel: lastAsOf,
          onRetry: () => ref.invalidate(_adviceInboxProvider),
        ),
      ],
    );
  }

  bool _isStale(ListResult<AdviceItem> list, Clock clock) =>
      list.asOf.observedAt.add(list.asOf.staleAfter).isBefore(clock.nowUtc());

  Widget _buildBody(
    ListResult<AdviceItem> list,
    AdviceInboxSummary? summary,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? empty = list.emptyLabel;
    final LinkAction? overdue = summary?.overdueUnrecordedLink;
    final String? notice = summary?.manualEntryNoticeText;
    final LinkAction? manual = summary?.manualEntryLink;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('a1-asof'), asOf: list.asOf),
        if (_isStale(list, clock)) JournalStaleBanner(asOf: list.asOf),
        JournalSafetyBanners(safety: safety),
        if (summary != null) _SummaryBlock(summary: summary),
        for (final (int i, AdviceItem item) in list.rows.indexed)
          _buildRow(i, item),
        if (list.rows.isEmpty && empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('a1-empty')),
          ),
        if (overdue != null)
          _linkPadding(
            TextButton(
              key: const Key('a1-overdue'),
              onPressed: () {
                ref.read(journalLinkOpenerProvider).open(overdue.deepLink);
              },
              child: Text(overdue.label),
            ),
          ),
        if (notice != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(notice, key: const Key('a1-manual-notice')),
          ),
        if (manual != null)
          _linkPadding(
            TextButton(
              key: const Key('a1-manual-entry'),
              onPressed: () {
                ref.read(journalLinkOpenerProvider).open(manual.deepLink);
              },
              child: Text(manual.label),
            ),
          ),
        _linkPadding(
          TextButton(
            key: const Key('a1-history-link'),
            onPressed: () {
              ref.read(journalLinkOpenerProvider).open(AppRoutes.adviceHistory);
            },
            child: const Text(JournalLabels.adviceHistoryLink),
          ),
        ),
      ],
    );
  }

  Widget _linkPadding(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Align(alignment: Alignment.centerLeft, child: child),
  );

  Widget _buildRow(int i, AdviceItem item) {
    final String? label = _deferLabel[item];
    final bool busy = _deferBusy[item] ?? false;
    final bool failed = _deferFailed[item] ?? false;
    return Column(
      key: ValueKey<String>('a1-row-$i'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            ref.read(journalLinkOpenerProvider).open(item.detailDeepLink);
          },
          child: AdviceCard(item: item),
        ),
        if (item.deferAvailable)
          _linkPadding(
            TextButton(
              key: ValueKey<String>('a1-defer-$i'),
              onPressed: busy
                  ? null
                  : () {
                      unawaited(_defer(item));
                    },
              child: const Text(JournalLabels.adviceDeferConfirm),
            ),
          ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(label, key: ValueKey<String>('a1-defer-receipt-$i')),
          ),
        if (failed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              JournalLabels.submitNotAccepted,
              key: ValueKey<String>('a1-defer-fail-$i'),
            ),
          ),
      ],
    );
  }

  Future<void> _defer(AdviceItem item) async {
    setState(() {
      _deferBusy[item] = true;
    });
    final CommandApi api = ref.read(journalAdviceCommandApiProvider);
    try {
      final CommandReceipt receipt = await api.deferAdviceConfirm(
        item.adviceId,
      );
      if (!mounted) return;
      setState(() {
        _deferBusy[item] = false;
        _deferFailed[item] = false;
        _deferLabel[item] = receipt.stateLabel;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deferBusy[item] = false;
        _deferFailed[item] = true;
        _deferLabel.remove(item);
      });
    }
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.summary});

  final AdviceInboxSummary summary;

  @override
  Widget build(BuildContext context) {
    final AdviceInboxSummary s = summary;
    final String? dueSoon = s.dueSoonLabel;
    final String? stale = s.staleLabel;
    final String? cooling = s.handoverCoolingLabel;
    final CashEstimateNotice? cash = s.cashNotice;
    final String? hint = s.trust.upgradeHint;
    return Padding(
      key: const Key('a1-summary'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.headline),
          if (dueSoon != null) Text(dueSoon),
          if (stale != null) Text(stale),
          if (cooling != null) Text(cooling),
          if (cash != null) Text(cash.label),
          Text(s.trust.label),
          Text(s.trust.consequenceLine),
          if (hint != null) Text(hint),
        ],
      ),
    );
  }
}
