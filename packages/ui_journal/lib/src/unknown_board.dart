// lib/src/unknown_board.dart
//
// J-5 UNKNOWN 해소 보드.
//
// 🔴 CommandApi import 0 · stepId 로 문구·아이콘 금지 · 경과·건수 계산 금지.
// 🔴 「재조회」·「강제 해소」 없음.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/journal_common.dart';
import 'timeline.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final journalUnknownBoardProvider = StreamProvider<UnknownBoardVm>(
  (Ref ref) => ref.watch(journalTimelineRepositoryProvider).watchUnknownBoard(),
);

// ── Root widget ───────────────────────────────────────────────────────────────

/// J-5 UNKNOWN 해소 보드.
///
/// 공개 위젯은 본문만(Scaffold·AppBar·SafeArea 금지).
class JournalUnknownBoard extends ConsumerWidget {
  const JournalUnknownBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UnknownBoardVm> boardAsync = ref.watch(
      journalUnknownBoardProvider,
    );
    final AsyncValue<SafetyState> safetyAsync = ref.watch(
      journalSafetyStateProvider,
    );
    final Clock clock = ref.watch(journalClockProvider);

    return boardAsync.when(
      loading: () => const JournalSkeleton(),
      error: (Object error, StackTrace stackTrace) => JournalErrorView(
        lastAsOfLabel: boardAsync.valueOrNull?.asOf.label,
        onRetry: () => ref.invalidate(journalUnknownBoardProvider),
      ),
      data: (UnknownBoardVm vm) => _UnknownBoardContent(
        vm: vm,
        safety: safetyAsync.valueOrNull,
        clock: clock,
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _UnknownBoardContent extends StatelessWidget {
  const _UnknownBoardContent({
    required this.vm,
    required this.safety,
    required this.clock,
  });

  final UnknownBoardVm vm;
  final SafetyState? safety;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final List<BlockFlag> flags = safety?.activeFlags ?? <BlockFlag>[];
    final List<BlockFlag> blockingFlags = flags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    final List<BlockFlag> markerFlags = flags
        .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
        .toList();

    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalAsOfHeader(asOf: vm.asOf),
          if (stale) JournalStaleBanner(asOf: vm.asOf),
          if (blockingFlags.isNotEmpty)
            JournalBlockingFlags(flags: blockingFlags),
          if (markerFlags.isNotEmpty) JournalMarkerChips(flags: markerFlags),
          if (vm.items.isEmpty && vm.emptyLabel != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(vm.emptyLabel!),
            )
          else
            ...vm.items.asMap().entries.map(
              (MapEntry<int, UnknownResolutionItem> e) =>
                  _UnknownCard(index: e.key, item: e.value),
            ),
          if (vm.nextBatchNoticeText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(vm.nextBatchNoticeText!),
            ),
        ],
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _UnknownCard extends ConsumerWidget {
  const _UnknownCard({required this.index, required this.item});

  final int index;
  final UnknownResolutionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? detailLink = item.entry.detailDeepLink;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // G3: emphasized == true → border highlight (02 §3-5 ⓒ · independent of escalationLink)
    final ShapeBorder shape = item.emphasized
        ? RoundedRectangleBorder(
            side: BorderSide(color: cs.error, width: 2),
            borderRadius: BorderRadius.circular(12),
          )
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          );

    final Widget cardBody = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: shape,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Entry summary ─────────────────────────────────────────────
            Row(
              children: <Widget>[
                Expanded(child: Text(item.entry.symbolLabel)),
                Flexible(child: Text(item.entry.sideLabel)),
              ],
            ),
            Text(item.entry.quantityText),
            Text(item.entry.statusLabel),
            const SizedBox(height: 4),
            // ── Elapsed & effect ──────────────────────────────────────────
            Text(item.elapsedText),
            Text(item.effectLine),
            const SizedBox(height: 8),
            // ── Steps 4 칸 — exhaustive GateState switch ──────────────────
            ...item.steps.map(
              (UnknownResolutionStep step) => _StepRow(step: step),
            ),
            // ── Escalation link — absent when null ────────────────────────
            if (item.escalationLink != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _EscalationButton(link: item.escalationLink!),
              ),
          ],
        ),
      ),
    );

    return InkWell(
      key: ValueKey<String>('j5-card-$index'),
      onTap: detailLink != null
          ? () => ref.read(journalLinkOpenerProvider).open(detailLink)
          : null,
      child: cardBody,
    );
  }
}

// ── Step row ──────────────────────────────────────────────────────────────────

class _StepRow extends ConsumerWidget {
  const _StepRow({required this.step});

  final UnknownResolutionStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? deepLink = step.deepLink;

    // GateState exhaustive switch — unknown ≠ notApplicable (04 §9-8).
    final IconData stateIcon = switch (step.state) {
      GateState.pass => Icons.check_circle_outline,
      GateState.block => Icons.cancel_outlined,
      GateState.notApplicable => Icons.radio_button_unchecked,
      GateState.unknown => Icons.help_outline,
    };

    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(stateIcon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(step.title),
                Text(step.stateLabel),
                Text(step.whyLine),
              ],
            ),
          ),
        ],
      ),
    );

    if (deepLink != null) {
      return InkWell(
        onTap: () => ref.read(journalLinkOpenerProvider).open(deepLink),
        child: row,
      );
    }
    return row;
  }
}

// ── Escalation button ─────────────────────────────────────────────────────────

class _EscalationButton extends ConsumerWidget {
  const _EscalationButton({required this.link});

  final LinkAction link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () => ref.read(journalLinkOpenerProvider).open(link.deepLink),
      child: Text(link.label),
    );
  }
}
