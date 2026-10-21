import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

/// H6-1·H6-2 보유 읽기 창구 주입 — 조립 앱 3종이 override 한다(01 §17-8).
final journalHoldingsRepositoryProvider = Provider<HoldingsRepository>(
  (Ref ref) => throw UnimplementedError(
    'journalHoldingsRepositoryProvider must be overridden',
  ),
);

/// H6-1 한 화면 — 열쇠 = 손익 펼침 여부(펼침 = 같은 창구 재구독).
final _holdingsOverviewProvider =
    StreamProvider.family<HoldingsOverviewVm, bool>(
      (Ref ref, bool includePnl) => ref
          .watch(journalHoldingsRepositoryProvider)
          .watchHoldingsOverview(includePnl: includePnl),
    );

/// H6-1 보유현황 본문 — 엔진이 준 카드·행·섹션을 받은 순서 그대로 그린다.
class HoldingsOverview extends ConsumerStatefulWidget {
  const HoldingsOverview({super.key});

  @override
  ConsumerState<HoldingsOverview> createState() => _HoldingsOverviewState();
}

class _HoldingsOverviewState extends ConsumerState<HoldingsOverview> {
  bool _pnlOpen = false;
  bool _externalOpen = false;
  final Map<int, bool> _cardOpen = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final bool expanded = _pnlOpen;
    final AsyncValue<HoldingsOverviewVm> overview = ref.watch(
      _holdingsOverviewProvider(expanded),
    );
    return overview.when(
      loading: () => const JournalSkeleton(key: Key('h61-loading')),
      error: (Object error, StackTrace stackTrace) => JournalErrorView(
        key: const Key('h61-fail'),
        lastAsOfLabel: overview.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(_holdingsOverviewProvider(expanded)),
      ),
      data: (HoldingsOverviewVm vm) => vm.cards.isEmpty
          ? _buildEmpty(vm, clock, safety)
          : _buildBody(vm, clock, safety),
    );
  }

  bool _isStale(HoldingsOverviewVm vm, Clock clock) =>
      vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc());

  // ── 빈 갈래 ───────────────────────────────────────────────────────────────

  Widget _buildEmpty(HoldingsOverviewVm vm, Clock clock, SafetyState? safety) {
    final String? label = vm.emptyLabel;
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('h61-asof'), asOf: vm.asOf),
        if (_isStale(vm, clock)) JournalStaleBanner(asOf: vm.asOf),
        JournalSafetyBanners(safety: safety),
        if (label != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(label, key: const Key('h61-empty')),
          ),
      ],
    );
  }

  // ── 정상 갈래 ─────────────────────────────────────────────────────────────

  Widget _buildBody(HoldingsOverviewVm vm, Clock clock, SafetyState? safety) {
    final LinkAction? allocation = vm.allocationLink;
    final String? toggleLabel = vm.pnlToggleLabel;
    final HoldingsExternalSection? ext = vm.external;
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('h61-asof'), asOf: vm.asOf),
        if (_isStale(vm, clock)) JournalStaleBanner(asOf: vm.asOf),
        JournalSafetyBanners(safety: safety),
        if (allocation != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const Key('h61-alloc-link'),
                onPressed: () {
                  ref.read(journalLinkOpenerProvider).open(allocation.deepLink);
                },
                child: Text(allocation.label),
              ),
            ),
          ),
        if (toggleLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('h61-pnl-toggle'),
                onPressed: () {
                  setState(() {
                    _pnlOpen = !_pnlOpen;
                  });
                },
                icon: Icon(_pnlOpen ? Icons.expand_less : Icons.expand_more),
                label: Text(toggleLabel),
              ),
            ),
          ),
        for (final (int c, HoldingsSleeveCard card) in vm.cards.indexed)
          _buildCard(c, card),
        if (ext != null) _buildExternal(ext),
      ],
    );
  }

  // ── 슬리브 카드 ───────────────────────────────────────────────────────────

  Widget _buildCard(int c, HoldingsSleeveCard card) {
    final bool open = _cardOpen[c] ?? false;
    final SleeveWeight? w = card.allocation.sleeveWeight;
    final String? note = card.allocation.bandNoteText;
    final SleeveBandState? state = card.allocation.bandState;
    final String? stateLabel = card.allocation.bandStateLabel;
    final String? rowsEmpty = card.rowsEmptyText;
    return Card(
      key: ValueKey<String>('h61-card-$c'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: ValueKey<String>('h61-card-toggle-$c'),
            onTap: () {
              setState(() {
                _cardOpen[c] = !open;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          card.titleText,
                          key: ValueKey<String>('h61-card-title-$c'),
                        ),
                        if (w != null)
                          Text(
                            w.label,
                            key: ValueKey<String>('h61-card-weight-$c'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        if (note != null)
                          Text(note, key: ValueKey<String>('h61-card-note-$c')),
                        if (state != null && stateLabel != null)
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: _bandColor(context, state),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  stateLabel,
                                  key: ValueKey<String>('h61-card-state-$c'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Icon(open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (open)
            for (final (int r, HoldingRow row) in card.rows.indexed)
              _buildRow(c, r, row),
          if (open && rowsEmpty != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                rowsEmpty,
                key: ValueKey<String>('h61-rows-empty-$c'),
              ),
            ),
        ],
      ),
    );
  }

  // ── 종목 행 ───────────────────────────────────────────────────────────────

  Widget _buildRow(int c, int r, HoldingRow row) {
    final String? pending = row.pendingText;
    final String? subBook = row.subBookLabel;
    final String? link = row.detailDeepLink;
    final HoldingPnl? gain = row.pnl;
    return InkWell(
      key: ValueKey<String>('h61-row-$c-$r'),
      onTap: link == null
          ? null
          : () {
              ref.read(journalLinkOpenerProvider).open(link);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(row.symbolLabel),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(row.quantityText),
                if (pending != null)
                  Chip(
                    key: ValueKey<String>('h61-pending-$c-$r'),
                    label: Text(pending),
                  ),
                if (subBook != null)
                  Chip(
                    key: ValueKey<String>('h61-subbook-$c-$r'),
                    label: Text(subBook),
                  ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text(JournalLabels.holdingsAvgPrice),
                const SizedBox(width: 6),
                Flexible(child: Text(row.avgPriceText)),
              ],
            ),
            Row(
              children: <Widget>[
                const Text(JournalLabels.holdingsEntryDate),
                const SizedBox(width: 6),
                Flexible(child: Text(row.entryDate.yyyyMmDd)),
              ],
            ),
            Text(row.weightText),
            if (row.entryReasons.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final ReasonChip chip in row.entryReasons)
                    JournalReasonChip(chip: chip),
                ],
              ),
            if (row.smaTranches.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final TrancheStep step in row.smaTranches)
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
            if (row.gates.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final GateBadge gate in row.gates)
                    Chip(
                      avatar: Icon(_gateIcon(gate.state), size: 16),
                      label: Text(gate.label),
                    ),
                ],
              ),
            if (gain != null)
              Padding(
                key: ValueKey<String>('h61-pnl-$c-$r'),
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(gain.pnlText),
                    Text(gain.pnlPctText),
                    Text(gain.disclosureNote),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 시스템 밖 자산 섹션 ───────────────────────────────────────────────────

  Widget _buildExternal(HoldingsExternalSection ext) {
    final bool open = _externalOpen;
    final String? banner = ext.bannerText;
    return Card(
      key: const Key('h61-ext'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            key: const Key('h61-ext-toggle'),
            onTap: () {
              setState(() {
                _externalOpen = !open;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(ext.titleText)),
                  Icon(open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(ext.noticeText, key: const Key('h61-ext-notice')),
          ),
          if (banner != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(banner, key: const Key('h61-ext-banner')),
            ),
          if (open)
            for (final (int k, ExternalHoldingRow x) in ext.rows.indexed)
              Padding(
                key: ValueKey<String>('h61-ext-row-$k'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(x.symbolLabel),
                    Text(x.quantityText),
                    Row(
                      children: <Widget>[
                        const Text(JournalLabels.holdingsRegisteredOn),
                        const SizedBox(width: 6),
                        Flexible(child: Text(x.registeredOn.yyyyMmDd)),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// 밴드 상태 점의 색 — 상태 하나에 색 하나(전수 switch).
Color _bandColor(BuildContext context, SleeveBandState s) {
  final ColorScheme cs = Theme.of(context).colorScheme;
  return switch (s) {
    SleeveBandState.inBand => cs.primary,
    SleeveBandState.nearEdge => cs.tertiary,
    SleeveBandState.outOfBand => cs.error,
  };
}

/// 배지 아이콘 — 게이트 상태 하나에 아이콘 하나(전수 switch).
IconData _gateIcon(GateState s) => switch (s) {
  GateState.pass => Icons.check_circle_outline,
  GateState.block => Icons.cancel_outlined,
  GateState.notApplicable => Icons.radio_button_unchecked,
  GateState.unknown => Icons.help_outline,
};
