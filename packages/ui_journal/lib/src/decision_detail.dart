// lib/src/decision_detail.dart
//
// J-2 거래 상세 화면 — 계약 v1.1 DecisionDetailVm (02 §3-2).
//
// 🔴 entry.asOf 아님 — 신선도 판정은 vm.asOf 로 한다(entry.asOf 는 체결 당시).
// 🔴 chainOf·findByDecisionId·fillChain·rawValues·triggerPrice 금지.
// 🔴 배럴(ui_journal.dart)에 export — journal_draft 에는 import 없음.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/journal_common.dart';
import 'timeline.dart';

// ── Data provider ─────────────────────────────────────────────────────────────

/// `J-2` 거래 상세 — `JournalRepository.watchDecisionDetail(decisionId)`.
///
/// 🔴 데이터 프로바이더: throw 기본값 금지(주입 프로바이더만 throw).
final journalDecisionDetailProvider =
    StreamProvider.family<DecisionDetailVm, String>(
      (Ref ref, String decisionId) => ref
          .watch(journalTimelineRepositoryProvider)
          .watchDecisionDetail(decisionId),
    );

// ── Public widget ─────────────────────────────────────────────────────────────

/// J-2 거래 상세 화면 본문 — Scaffold·AppBar·SafeArea 없음(01 §9).
///
/// [decisionId] 는 셸이 라우트 파라미터에서 꺼내 생성자로 넘긴다 — 화면이 직접 파싱하지 않음.
class JournalDecisionDetail extends ConsumerWidget {
  const JournalDecisionDetail({super.key, required this.decisionId});

  final String decisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safety state — blocking flags / marker chips.
    final AsyncValue<SafetyState> safetyAsync = ref.watch(
      journalSafetyStateProvider,
    );
    final SafetyState? safety = safetyAsync.valueOrNull;

    // Decision detail stream.
    final AsyncValue<DecisionDetailVm> detailAsync = ref.watch(
      journalDecisionDetailProvider(decisionId),
    );

    return detailAsync.when(
      loading: () => const JournalSkeleton(),
      error: (Object e, _) => JournalErrorView(
        lastAsOfLabel: detailAsync.valueOrNull?.asOf.label,
        onRetry: () =>
            ref.invalidate(journalDecisionDetailProvider(decisionId)),
      ),
      data: (DecisionDetailVm vm) {
        final Clock clock = ref.watch(journalClockProvider);
        final bool isStale = vm.asOf.observedAt
            .add(vm.asOf.staleAfter)
            .isBefore(clock.nowUtc());

        // Safety split (same rule as J-1 _TimelineContent).
        final List<BlockFlag> blockingFlags =
            safety?.activeFlags
                .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
                .toList() ??
            <BlockFlag>[];
        final List<BlockFlag> markerFlags =
            safety?.activeFlags
                .where((BlockFlag f) => FlagIds.markerOnly.contains(f.flagId))
                .toList() ??
            <BlockFlag>[];

        return _DecisionDetailContent(
          vm: vm,
          isStale: isStale,
          blockingFlags: blockingFlags,
          markerFlags: markerFlags,
        );
      },
    );
  }
}

// ── Internal content ──────────────────────────────────────────────────────────

class _DecisionDetailContent extends ConsumerWidget {
  const _DecisionDetailContent({
    required this.vm,
    required this.isStale,
    required this.blockingFlags,
    required this.markerFlags,
  });

  final DecisionDetailVm vm;
  final bool isStale;
  final List<BlockFlag> blockingFlags;
  final List<BlockFlag> markerFlags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TradeJournalEntry entry = vm.entry;

    return ListView(
      children: <Widget>[
        // ── As-of header ────────────────────────────────────────────────────
        JournalAsOfHeader(asOf: vm.asOf),
        if (isStale) JournalStaleBanner(asOf: vm.asOf),

        // ── Safety flags ─────────────────────────────────────────────────────
        if (blockingFlags.isNotEmpty)
          JournalBlockingFlags(flags: blockingFlags),
        if (markerFlags.isNotEmpty) JournalMarkerChips(flags: markerFlags),

        // ── Top summary ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(entry.symbolLabel),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Expanded(child: Text(entry.sideLabel)),
                  Expanded(child: Text(entry.quantityText)),
                ],
              ),
              _StatusChip(
                statusLabel: entry.statusLabel,
                tone: entry.statusTone,
              ),
            ],
          ),
        ),

        // ── Link buttons (rebalance · parent · amend — position is discretionary) ──
        if (vm.rebalanceLink != null)
          _LinkButton(
            key: const ValueKey<String>('j2-link-rebalanceLink'),
            link: vm.rebalanceLink!,
          ),
        if (vm.parentLink != null)
          _LinkButton(
            key: const ValueKey<String>('j2-link-parentLink'),
            link: vm.parentLink!,
          ),
        if (vm.amendLink != null)
          _LinkButton(
            key: const ValueKey<String>('j2-link-amendLink'),
            link: vm.amendLink!,
          ),

        // ── pendingNoticeText ─────────────────────────────────────────────────
        if (vm.pendingNoticeText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(vm.pendingNoticeText!),
          ),

        // ── Decision chain ────────────────────────────────────────────────────
        Column(
          key: const Key('j2-chain'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < vm.steps.length; i++)
              _ChainStepRow(
                key: ValueKey<String>('j2-step-$i'),
                step: vm.steps[i],
              ),
          ],
        ),

        // ── Fills ─────────────────────────────────────────────────────────────
        for (final TradeJournalEntry f in vm.fills)
          JournalEntryCard(entry: f, tappable: false),
        if (vm.remainingText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(vm.remainingText!),
          ),

        // ── Decision snapshot (collapsible) ───────────────────────────────────
        if (vm.snapshot != null)
          _SnapshotSection(snapshot: vm.snapshot!)
        else if (vm.snapshotMissingLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(vm.snapshotMissingLabel!),
          ),

        // ── Threshold compare table ───────────────────────────────────────────
        if (vm.thresholds.isNotEmpty) _ThresholdTable(rows: vm.thresholds),

        // ── Reject trace (collapsible) ────────────────────────────────────────
        if (vm.rejectTraces.isNotEmpty)
          _RejectTraceSection(traces: vm.rejectTraces),

        // ── journalStateLabel + journalLink (02 §3-2 ⓖ «하단») ────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(vm.journalStateLabel),
        ),
        if (vm.journalLink != null)
          _LinkButton(
            key: const ValueKey<String>('j2-link-journalLink'),
            link: vm.journalLink!,
          ),
      ],
    );
  }
}

// ── Status chip with paired foreground color (G9 — J-2 only) ─────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statusLabel, required this.tone});

  final String statusLabel;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = journalToneColor(context, tone);
    final Color fg = switch (tone) {
      ChipTone.blocked => cs.onError,
      ChipTone.caution => cs.onErrorContainer,
      ChipTone.neutral => cs.onSurface,
      ChipTone.prevented => cs.onSurface,
    };
    return Chip(
      label: Text(statusLabel, style: TextStyle(color: fg)),
      backgroundColor: bg,
    );
  }
}

// ── Chain step row ────────────────────────────────────────────────────────────

class _ChainStepRow extends ConsumerWidget {
  const _ChainStepRow({super.key, required this.step});

  final DecisionChainStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = step.deepLink;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = journalToneColor(context, step.tone);
    final Color fg = switch (step.tone) {
      ChipTone.blocked => cs.onError,
      ChipTone.caution => cs.onErrorContainer,
      ChipTone.neutral => cs.onSurface,
      ChipTone.prevented => cs.onSurface,
    };

    // R-1: Chip was maxLines:1 softWrap:false → long stateLabel overflowed Row.
    // Fix: Wrap the stage row so the state badge wraps to next line when needed.
    // Badge = DecoratedBox+Padding+Text (same colour pair, no Chip fade/ellipsis).
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(step.stageLabel),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(step.stateLabel, style: TextStyle(color: fg)),
                ),
              ),
              if (step.occurredAtText != null)
                Text(
                  step.occurredAtText!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          for (final String line in step.detailLines)
            Text(line, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );

    if (link != null) {
      return InkWell(
        onTap: () => ref.read(journalLinkOpenerProvider).open(link),
        child: content,
      );
    }
    return content;
  }
}

// ── Link button ───────────────────────────────────────────────────────────────

class _LinkButton extends ConsumerWidget {
  const _LinkButton({super.key, required this.link});

  final LinkAction link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: OutlinedButton(
        onPressed: () =>
            ref.read(journalLinkOpenerProvider).open(link.deepLink),
        child: Text(link.label),
      ),
    );
  }
}

// ── Decision snapshot (collapsible) ──────────────────────────────────────────

class _SnapshotSection extends ConsumerStatefulWidget {
  const _SnapshotSection({required this.snapshot});

  final DecisionSnapshot snapshot;

  @override
  ConsumerState<_SnapshotSection> createState() => _SnapshotSectionState();
}

class _SnapshotSectionState extends ConsumerState<_SnapshotSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final DecisionSnapshot snap = widget.snapshot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Collapsible header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(JournalLabels.decisionSnapshot)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_expanded) ...<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(snap.kindLabel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(snap.trigger.summary),
          ),
          // configHash — monospace, 1 line, ellipsis; long-press copies
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onLongPress: () async {
                await Clipboard.setData(
                  ClipboardData(text: snap.ref.configHash),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(JournalLabels.copied)),
                  );
                }
              },
              child: Text(
                snap.ref.configHash,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(snap.summary),
          ),
          // Snapshot reasons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: snap.reasons
                  .map((ReasonChip r) => JournalReasonChip(chip: r))
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Threshold compare table ───────────────────────────────────────────────────

class _ThresholdTable extends StatelessWidget {
  const _ThresholdTable({required this.rows});

  final List<ThresholdCompare> rows;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(JournalLabels.thresholdCompare),
          const SizedBox(height: 4),
          for (int i = 0; i < rows.length; i++)
            Padding(
              key: ValueKey<String>('j2-thr-$i'),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(rows[i].metricLabel)),
                  Expanded(child: Text(rows[i].observedText)),
                  Expanded(child: Text(rows[i].thresholdText)),
                  Flexible(child: Text(rows[i].verdictLabel)),
                  if (rows[i].passed)
                    const Icon(Icons.check, size: 16)
                  else
                    Icon(Icons.remove, size: 16, color: cs.onSurfaceVariant),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Reject trace (collapsible) ────────────────────────────────────────────────

class _RejectTraceSection extends StatefulWidget {
  const _RejectTraceSection({required this.traces});

  final List<RejectTrace> traces;

  @override
  State<_RejectTraceSection> createState() => _RejectTraceSectionState();
}

class _RejectTraceSectionState extends State<_RejectTraceSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(JournalLabels.rejectTrace)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final RejectTrace trace in widget.traces)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(trace.stageLabel),
                  Text(trace.reasonLabel),
                  // SAF 원문 — 받은 그대로(01 §11-10 «SAF 원문 = 명시적 예외» · 02 §3-2 ⓔ)
                  Text(
                    trace.reasonCode,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  if (trace.occurredAtText != null)
                    Text(
                      trace.occurredAtText!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
      ],
    );
  }
}
