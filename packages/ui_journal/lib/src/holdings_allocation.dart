import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'holdings_overview.dart';
import 'timeline.dart';

/// H6-3 하단 다음 회차 창구 주입 — 조립 앱 3종이 override 한다(01 §17-8).
final journalRebalanceRepositoryProvider = Provider<RebalanceRepository>(
  (Ref ref) => throw UnimplementedError(
    'journalRebalanceRepositoryProvider must be overridden',
  ),
);

/// H6-3 배분 행 전부(회계 기준) — 인자 없이.
final _allocationProvider = StreamProvider<SleeveAllocationVm>(
  (Ref ref) =>
      ref.watch(journalHoldingsRepositoryProvider).watchAllocation(),
);

/// H6-3 하단 — 다음 회차(D-day · 예정 없음).
final _nextRebalanceProvider = StreamProvider<NextRebalanceVm>(
  (Ref ref) =>
      ref.watch(journalRebalanceRepositoryProvider).watchNext(),
);

/// H6-3 슬리브·비중.
class HoldingsAllocation extends ConsumerStatefulWidget {
  const HoldingsAllocation({super.key});

  @override
  ConsumerState<HoldingsAllocation> createState() =>
      _HoldingsAllocationState();
}

class _HoldingsAllocationState extends ConsumerState<HoldingsAllocation> {
  final Map<int, bool> _noteOpen = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<SleeveAllocationVm> alloc =
        ref.watch(_allocationProvider);
    final AsyncValue<NextRebalanceVm> next = ref.watch(_nextRebalanceProvider);
    return alloc.when(
      loading: () => const JournalSkeleton(key: Key('h63-loading')),
      error: (Object e, StackTrace s) => JournalErrorView(
        key: const Key('h63-fail'),
        lastAsOfLabel: alloc.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(_allocationProvider),
      ),
      data: (SleeveAllocationVm vm) => vm.rows.isEmpty
          ? _buildEmpty(vm, next, clock, safety)
          : _buildBody(vm, next, clock, safety),
    );
  }

  bool _isStale(SleeveAllocationVm vm, Clock clock) =>
      vm.asOf.observedAt.add(vm.asOf.staleAfter).isBefore(clock.nowUtc());

  // ── 빈 갈래 ─────────────────────────────────────────────────────────────

  Widget _buildEmpty(
    SleeveAllocationVm vm,
    AsyncValue<NextRebalanceVm> next,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? label = vm.emptyLabel;
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('h63-asof'), asOf: vm.asOf),
        if (_isStale(vm, clock)) JournalStaleBanner(asOf: vm.asOf),
        JournalSafetyBanners(safety: safety),
        if (label != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(label, key: const Key('h63-empty')),
          ),
        _buildNext(next),
      ],
    );
  }

  // ── 정상 갈래 ─────────────────────────────────────────────────────────────

  Widget _buildBody(
    SleeveAllocationVm vm,
    AsyncValue<NextRebalanceVm> next,
    Clock clock,
    SafetyState? safety,
  ) {
    final String? notice = vm.noticeText;
    return ListView(
      children: <Widget>[
        JournalAsOfHeader(key: const Key('h63-asof'), asOf: vm.asOf),
        if (_isStale(vm, clock)) JournalStaleBanner(asOf: vm.asOf),
        JournalSafetyBanners(safety: safety),
        if (notice != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(notice, key: const Key('h63-notice')),
          ),
        for (final (int i, SleeveAllocationRow r) in vm.rows.indexed)
          _buildRow(i, r),
        _buildNext(next),
      ],
    );
  }

  // ── 배분 행 ──────────────────────────────────────────────────────────────

  Widget _buildRow(int i, SleeveAllocationRow r) {
    final bool open = _noteOpen[i] ?? false;
    final SleeveWeight? w = r.sleeveWeight;
    final String? bandNote = r.bandNoteText;
    final SleeveBandState? state = r.bandState;
    final String? stateLabel = r.bandStateLabel;
    final SleeveBandGauge? g = r.gauge;
    final double? deployed = r.deployedRatio;
    final double? parked = r.parkingRatio;
    final String? note = r.engineColumnNote;
    final String? parkingNote = r.parkingNoteText;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      key: ValueKey<String>('h63-row-$i'),
      padding: EdgeInsets.fromLTRB(
        r.parentSleeve == null ? 16 : 40,
        8,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  r.sleeveLabel,
                  key: ValueKey<String>('h63-label-$i'),
                ),
              ),
              if (note != null)
                IconButton(
                  key: ValueKey<String>('h63-note-toggle-$i'),
                  onPressed: () {
                    setState(() {
                      _noteOpen[i] = !open;
                    });
                  },
                  icon: Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
            ],
          ),
          if (w != null)
            Text(
              w.label,
              key: ValueKey<String>('h63-weight-$i'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (bandNote != null)
            Text(bandNote, key: ValueKey<String>('h63-band-note-$i')),
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
                    key: ValueKey<String>('h63-state-$i'),
                  ),
                ),
              ],
            ),
          if (g != null && state != null)
            SizedBox(
              key: ValueKey<String>('h63-gauge-$i'),
              width: double.infinity,
              height: 16,
              child: CustomPaint(
                painter: _GaugePainter(
                  gauge: g,
                  colors: cs,
                  mark: _bandColor(context, state),
                ),
              ),
            ),
          if (deployed != null && parked != null)
            SizedBox(
              key: ValueKey<String>('h63-bar-$i'),
              height: 8,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) => Row(
                  children: <Widget>[
                    SizedBox(
                      width: c.maxWidth * deployed,
                      height: 8,
                      child: ColoredBox(color: cs.primary),
                    ),
                    SizedBox(
                      width: c.maxWidth * parked,
                      height: 8,
                      child: ColoredBox(color: cs.outlineVariant),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: <Widget>[
              const Text(JournalLabels.holdingsDeployed),
              const SizedBox(width: 6),
              Flexible(child: Text(r.deployedText)),
              const SizedBox(width: 6),
              Flexible(child: Text(r.deployedPctText)),
            ],
          ),
          Row(
            children: <Widget>[
              const Text(JournalLabels.holdingsParking),
              const SizedBox(width: 6),
              Flexible(child: Text(r.parkingText)),
              const SizedBox(width: 6),
              Flexible(child: Text(r.parkingPctText)),
            ],
          ),
          Text(r.trancheStateText),
          if (parkingNote != null) Text(parkingNote),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: <Widget>[
              for (final ReasonChip chip in r.stateChips)
                JournalReasonChip(chip: chip),
            ],
          ),
          if (open && note != null)
            Text(note, key: ValueKey<String>('h63-note-$i')),
        ],
      ),
    );
  }

  // ── 하단 다음 회차 ─────────────────────────────────────────────────────────

  Widget _buildNext(AsyncValue<NextRebalanceVm> next) {
    return next.when(
      loading: () => const SizedBox.shrink(),
      error: (Object e, StackTrace s) => const SizedBox.shrink(),
      data: (NextRebalanceVm n) {
        final String? empty = n.emptyLabel;
        final String? date = n.expectedDateText;
        final String? dDay = n.dDayText;
        final String? route = n.previewRoute;
        return Padding(
          key: const Key('h63-next'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: InkWell(
            onTap: route == null
                ? null
                : () {
                    ref.read(journalLinkOpenerProvider).open(route);
                  },
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                if (dDay != null) const Text(JournalLabels.holdingsNextRebalance),
                if (date != null) Text(date),
                if (dDay != null) Text(dDay),
                if (empty != null) Text(empty),
              ],
            ),
          ),
        );
      },
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

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.gauge,
    required this.colors,
    required this.mark,
  });

  final SleeveBandGauge gauge;
  final ColorScheme colors;
  final Color mark;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.surfaceContainerHighest,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        w * gauge.bandLowNormalized,
        0,
        w * gauge.bandHighNormalized,
        size.height,
      ),
      Paint()..color = colors.secondaryContainer,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * gauge.targetNormalized, 0, 2, size.height),
      Paint()..color = colors.outline,
    );
    canvas.drawCircle(
      Offset(w * gauge.actualNormalized, size.height / 2),
      6,
      Paint()..color = mark,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.gauge != gauge || old.mark != mark || old.colors != colors;
}
