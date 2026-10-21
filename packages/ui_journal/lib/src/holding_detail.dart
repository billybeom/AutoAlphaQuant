import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'holdings_overview.dart';
import 'timeline.dart';

/// H6-2 보유 1건 — 열쇠 = (보유 id, 손익 펼침 여부).
final _holdingDetailProvider =
    StreamProvider.family<HoldingDetailVm, (String, bool)>(
      (Ref ref, (String, bool) key) => ref
          .watch(journalHoldingsRepositoryProvider)
          .watchHoldingDetail(key.$1, includePnl: key.$2),
    );

/// H6-2 종목 상세.
class HoldingDetail extends ConsumerStatefulWidget {
  const HoldingDetail({super.key, required this.holdingId});

  final String holdingId;

  @override
  ConsumerState<HoldingDetail> createState() => _HoldingDetailState();
}

class _HoldingDetailState extends ConsumerState<HoldingDetail> {
  bool _pnlOpen = false;

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final bool pnlOpen = _pnlOpen;
    final AsyncValue<HoldingDetailVm> detail = ref.watch(
      _holdingDetailProvider((widget.holdingId, pnlOpen)),
    );
    return detail.when(
      loading: () => const JournalSkeleton(key: Key('h62-loading')),
      error: (Object e, StackTrace s) => JournalErrorView(
        key: const Key('h62-fail'),
        lastAsOfLabel: detail.valueOrNull?.asOf.label,
        onRetry: () =>
            ref.invalidate(_holdingDetailProvider((widget.holdingId, pnlOpen))),
      ),
      data: (HoldingDetailVm vm) => _buildBody(vm, clock, safety),
    );
  }

  bool _isStale(HoldingDetailVm vm, Clock clock) =>
      vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc());

  Widget _buildBody(HoldingDetailVm vm, Clock clock, SafetyState? safety) {
    final HoldingRow h = vm.holding;
    final String? pending = h.pendingText;
    final String? subBook = h.subBookLabel;
    final String? toggleLabel = vm.pnlToggleLabel;
    final HoldingPnl? pnl = h.pnl;
    final String? noStop = vm.noStopLineText;
    final String? recentEmpty = vm.recentEmptyLabel;
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('h62-asof'), asOf: vm.asOf),
        if (_isStale(vm, clock)) JournalStaleBanner(asOf: vm.asOf),
        JournalSafetyBanners(safety: safety),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(vm.sleeveLabel, key: const Key('h62-sleeve')),
        ),
        Padding(
          key: const Key('h62-summary'),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(h.symbolLabel),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  Text(h.quantityText),
                  if (pending != null)
                    Chip(key: const Key('h62-pending'), label: Text(pending)),
                  if (subBook != null)
                    Chip(key: const Key('h62-subbook'), label: Text(subBook)),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text(JournalLabels.holdingsAvgPrice),
                  const SizedBox(width: 6),
                  Flexible(child: Text(h.avgPriceText)),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text(JournalLabels.holdingsEntryDate),
                  const SizedBox(width: 6),
                  Flexible(child: Text(h.entryDate.yyyyMmDd)),
                ],
              ),
              Text(h.weightText),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final ReasonChip chip in h.entryReasons)
                    JournalReasonChip(chip: chip),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final TrancheStep step in h.smaTranches)
                    Chip(
                      avatar: Icon(
                        step.filled
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                      ),
                      label: Text(step.label),
                    ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final GateBadge gate in h.gates)
                    Chip(
                      avatar: Icon(_gateIcon(gate.state), size: 16),
                      label: Text(gate.label),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (toggleLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              key: const Key('h62-pnl-toggle'),
              onPressed: () {
                setState(() {
                  _pnlOpen = !_pnlOpen;
                });
              },
              icon: Icon(_pnlOpen ? Icons.expand_less : Icons.expand_more),
              label: Text(toggleLabel),
            ),
          ),
        if (pnl != null)
          Padding(
            key: const Key('h62-pnl'),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(pnl.pnlText),
                Text(pnl.pnlPctText),
                Text(pnl.disclosureNote),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: OutlinedButton(
            key: const Key('h62-entry-link'),
            onPressed: () {
              ref
                  .read(journalLinkOpenerProvider)
                  .open(vm.entryDecisionLink.deepLink);
            },
            child: Text(vm.entryDecisionLink.label),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(JournalLabels.holdingsStopLines),
        ),
        for (final (int i, StopLineNormalized s) in vm.stopLines.indexed)
          Padding(
            key: ValueKey<String>('h62-stop-$i'),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  s.tierLabel,
                  style: TextStyle(
                    fontWeight: s.isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(s.levelText),
                Text(s.basisLabel),
              ],
            ),
          ),
        if (noStop != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(noStop, key: const Key('h62-no-stop')),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(JournalLabels.holdingsRecentEntries),
        ),
        for (final (int k, TradeJournalEntry e) in vm.recentEntries.indexed)
          JournalEntryCard(key: ValueKey<String>('h62-entry-$k'), entry: e),
        if (recentEmpty != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(recentEmpty, key: const Key('h62-recent-empty')),
          ),
      ],
    );
  }
}

/// 배지 아이콘 — 게이트 상태 하나에 아이콘 하나(전수 switch).
IconData _gateIcon(GateState s) => switch (s) {
  GateState.pass => Icons.check_circle_outline,
  GateState.block => Icons.cancel_outlined,
  GateState.notApplicable => Icons.radio_button_unchecked,
  GateState.unknown => Icons.help_outline,
};
