// lib/src/common/journal_common.dart
//
// 공통 위젯 — J-1·J-2·J-3·J-5 에서 재사용되는 부품.
//
// 🔴 이 파일은 배럴(lib/ui_journal.dart)에 export 하지 않는다(02 §주입 구조).
// 🔴 렌더 불변 «순수 이동» — 패딩·순서·위젯 종류·조건은 timeline.dart 원본 그대로.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../timeline.dart';

// ── Tone color helper ─────────────────────────────────────────────────────────

/// 사유 칩·상태 칩의 배경색 — [ChipTone] → [colorScheme] 매핑.
///
/// 🔴 값이 아닌 [colorScheme] 기반이라 색 리터럴을 쓰지 않는다.
Color journalToneColor(BuildContext context, ChipTone tone) {
  final ColorScheme cs = Theme.of(context).colorScheme;
  return switch (tone) {
    ChipTone.caution => cs.errorContainer,
    ChipTone.blocked => cs.error,
    ChipTone.neutral => cs.surfaceContainerHighest,
    ChipTone.prevented => cs.surfaceContainerHighest,
  };
}

// ── As-of header ──────────────────────────────────────────────────────────────

class JournalAsOfHeader extends StatelessWidget {
  const JournalAsOfHeader({super.key, required this.asOf});

  final AsOf asOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(asOf.label),
    );
  }
}

// ── Stale banner (F3 / A4) ────────────────────────────────────────────────────

class JournalStaleBanner extends StatelessWidget {
  const JournalStaleBanner({super.key, required this.asOf});

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

// ── Blocking flags — top-2 cards + overflow count (F4 / A5) ──────────────────

class JournalBlockingFlags extends StatelessWidget {
  const JournalBlockingFlags({super.key, required this.flags});

  /// Already filtered to blocking-only (not markerOnly). Engine-sorted order.
  final List<BlockFlag> flags;

  @override
  Widget build(BuildContext context) {
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

// ── Marker-only flags — grey info chip row (F4b / A5) ─────────────────────────

class JournalMarkerChips extends StatelessWidget {
  const JournalMarkerChips({super.key, required this.flags});

  /// Already filtered to markerOnly flags.
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
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

// ── Reason chip with optional tap ─────────────────────────────────────────────

class JournalReasonChip extends ConsumerWidget {
  const JournalReasonChip({super.key, required this.chip});

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

// ── Journal entry card ────────────────────────────────────────────────────────

/// ⓐ Renders display strings (*Text · sideLabel) — never raw values.
/// ⓑ No screen-side hiding — *Text already contains "숨김" / "120주?" from engine.
/// ⓔ [tappable] = true: row tap opens entry.detailDeepLink; null → no reaction.
///    [tappable] = false: InkWell is absent (e.g. fill rows in J-2).
class JournalEntryCard extends ConsumerWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    this.tappable = true,
  });

  final TradeJournalEntry entry;
  final bool tappable;

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
                    .map((ReasonChip r) => JournalReasonChip(chip: r)),
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

    // ⓔ Row tap — present only when tappable == true AND detailDeepLink is non-null.
    if (tappable && detailLink != null) {
      return InkWell(
        onTap: () => ref.read(journalLinkOpenerProvider).open(detailLink),
        child: card,
      );
    }
    return card;
  }
}

// ── Skeleton (loading state) ──────────────────────────────────────────────────

class JournalSkeleton extends StatelessWidget {
  const JournalSkeleton({super.key});

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

// ── Error state ───────────────────────────────────────────────────────────────

class JournalErrorView extends StatelessWidget {
  const JournalErrorView({
    super.key,
    required this.onRetry,
    this.lastAsOfLabel,
  });

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
