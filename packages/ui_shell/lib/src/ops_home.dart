// lib/src/ops_home.dart
//
// OpsHome — H-01 운영 홈(04 §4-1 · K44 · K45).
//
// 🔴 래퍼 없음(화면 규칙 · 부모 높이 안 ListView).
// 🔴 구독 6: watchState · watchToday · watchSummary · watchAllocation · watchDiagnostics · watchGrade.
// 🔴 블록 순서 고정(1→2→3→3b→4→5→6→7→8→9b) · 블록 9 부재.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/shell_common.dart';
import 'routing/shell_router.dart';
import 'shell_providers.dart';

// ── Data providers ─────────────────────────────────────────────────────────────

final StreamProvider<SafetyState> _homeSafetyProvider =
    StreamProvider<SafetyState>(
      (Ref ref) => ref.watch(shellSafetyRepositoryProvider).watchState(),
    );

final StreamProvider<OpsDailySummary> _homeTodayProvider =
    StreamProvider<OpsDailySummary>(
      (Ref ref) => ref.watch(shellOpsSummaryRepositoryProvider).watchToday(),
    );

final StreamProvider<AdviceInboxSummary> _homeAdviceProvider =
    StreamProvider<AdviceInboxSummary>(
      (Ref ref) => ref.watch(shellAdviceRepositoryProvider).watchSummary(),
    );

final StreamProvider<SleeveAllocationVm> _homeAllocationProvider =
    StreamProvider<SleeveAllocationVm>(
      (Ref ref) => ref.watch(shellHoldingsRepositoryProvider).watchAllocation(),
    );

final StreamProvider<DiagnosticsVm> _homeDiagnosticsProvider =
    StreamProvider<DiagnosticsVm>(
      (Ref ref) =>
          ref.watch(shellOpsStatusRepositoryProvider).watchDiagnostics(),
    );

final StreamProvider<LedgerTrustBadge> _homeTrustProvider =
    StreamProvider<LedgerTrustBadge>(
      (Ref ref) => ref.watch(shellLedgerTrustRepositoryProvider).watchGrade(),
    );

// ── OpsHome ────────────────────────────────────────────────────────────────────

/// H-01 운영 홈.
class OpsHome extends ConsumerStatefulWidget {
  const OpsHome({super.key});

  @override
  ConsumerState<OpsHome> createState() => _OpsHomeState();
}

class _OpsHomeState extends ConsumerState<OpsHome> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.resumed:
        ref.invalidate(_homeSafetyProvider);
        ref.invalidate(_homeTodayProvider);
        ref.invalidate(_homeAdviceProvider);
        ref.invalidate(_homeAllocationProvider);
        ref.invalidate(_homeDiagnosticsProvider);
        ref.invalidate(_homeTrustProvider);
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<OpsDailySummary> todayAv = ref.watch(_homeTodayProvider);

    if (todayAv.hasError && todayAv.valueOrNull == null) {
      return ShellErrorView(
        key: const Key('h01-fail'),
        onRetry: () => ref.invalidate(_homeTodayProvider),
      );
    }

    final OpsDailySummary? today = todayAv.valueOrNull;
    if (today == null) {
      return const ShellSkeleton(key: Key('h01-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = today.asOf.observedAt
        .add(today.asOf.staleAfter)
        .isBefore(clock.nowUtc());

    final AsyncValue<SafetyState> safetyAv = ref.watch(_homeSafetyProvider);
    final AsyncValue<AdviceInboxSummary> adviceAv = ref.watch(
      _homeAdviceProvider,
    );
    final AsyncValue<SleeveAllocationVm> allocAv = ref.watch(
      _homeAllocationProvider,
    );
    final AsyncValue<DiagnosticsVm> diagAv = ref.watch(
      _homeDiagnosticsProvider,
    );
    final AsyncValue<LedgerTrustBadge> trustAv = ref.watch(_homeTrustProvider);

    final SafetyState? safety = safetyAv.valueOrNull;
    final AdviceInboxSummary? advice = adviceAv.valueOrNull;
    final SleeveAllocationVm? alloc = allocAv.valueOrNull;
    final DiagnosticsVm? diag = diagAv.valueOrNull;
    final LedgerTrustBadge? trust = trustAv.valueOrNull;

    final ColorScheme cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        // 머리
        ShellAsOfHeader(key: const Key('h01-asof'), asOf: today.asOf),
        if (stale) ShellStaleBanner(asOf: today.asOf),

        // 블록 1 — 안전 상태
        if (safetyAv.hasError && safety == null)
          _BlockRetry(
            key: const Key('h01-status-fail'),
            onRetry: () => ref.invalidate(_homeSafetyProvider),
          )
        else if (safety != null)
          _Block1Status(safety: safety),

        // 블록 2 — 재개 한 줄
        _Block2Resume(today: today),

        // 블록 3 — 차단 플래그
        if (safety != null) _Block3Blocked(safety: safety),

        // 블록 3b — 안내 요약
        if (advice != null) _Block3bAdvice(summary: advice),

        // 블록 4 — 슬리브 비중
        if (allocAv.hasError && alloc == null)
          _BlockRetry(
            key: const Key('h01-alloc-fail'),
            onRetry: () => ref.invalidate(_homeAllocationProvider),
          )
        else if (alloc != null)
          _Block4Alloc(vm: alloc),

        // 블록 5 — 과정 지표 3
        _Block5Process(today: today),

        // 블록 6 — 기록 대조
        if (diagAv.hasError && diag == null)
          _BlockRetry(
            key: const Key('h01-recon-fail'),
            onRetry: () => ref.invalidate(_homeDiagnosticsProvider),
          )
        else if (diag != null)
          _Block6Recon(vm: diag),

        // 블록 7 — 오늘 3 문자열
        _Block7Today(today: today),

        // 블록 8 — 다음 예정
        _Block8Upcoming(today: today),

        // 블록 9 — 부재(미결 123)
        // later: X4 calendar chip

        // 블록 9b — 원장 실사 카드
        if (safety != null && trust != null)
          _Block9bAudit(safety: safety, trust: trust, cs: cs),
      ],
    );
  }
}

// ── Block 1 ────────────────────────────────────────────────────────────────────

class _Block1Status extends ConsumerWidget {
  const _Block1Status({required this.safety});

  final SafetyState safety;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      key: const Key('h01-status'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.m5BlockBoard);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(safety.breakerLabel),
      ),
    );
  }
}

// ── Block 2 ────────────────────────────────────────────────────────────────────

class _Block2Resume extends ConsumerWidget {
  const _Block2Resume({required this.today});

  final OpsDailySummary today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LinkAction? line = today.resumeLine;
    if (line == null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      key: const Key('h01-resume'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(line.deepLink);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(line.label),
      ),
    );
  }
}

// ── Block 3 ────────────────────────────────────────────────────────────────────

class _Block3Blocked extends ConsumerWidget {
  const _Block3Blocked({required this.safety});

  final SafetyState safety;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BlockFlag> blocking = safety.activeFlags
        .where((BlockFlag f) => !FlagIds.markerOnly.contains(f.flagId))
        .toList();
    if (blocking.isEmpty) {
      return const SizedBox.shrink();
    }
    return InkWell(
      key: const Key('h01-blocked'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.m5BlockBoard);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[for (final BlockFlag f in blocking) Text(f.label)],
        ),
      ),
    );
  }
}

// ── Block 3b ───────────────────────────────────────────────────────────────────

class _Block3bAdvice extends ConsumerWidget {
  const _Block3bAdvice({required this.summary});

  final AdviceInboxSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AdviceInboxSummary s = summary;
    if (s.openCount == 0 && !s.hasSuppressedNotice) {
      return const SizedBox.shrink();
    }
    return InkWell(
      key: const Key('h01-advice'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.adviceInbox);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.headline),
            if (!s.hasSuppressedNotice) ...<Widget>[
              if (s.dueSoonLabel != null) Text(s.dueSoonLabel!),
              Text(s.trust.label),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Block 4 ────────────────────────────────────────────────────────────────────

class _Block4Alloc extends ConsumerWidget {
  const _Block4Alloc({required this.vm});

  final SleeveAllocationVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SleeveAllocationRow> top = vm.rows
        .where((SleeveAllocationRow r) => r.parentSleeve == null)
        .toList();
    return InkWell(
      key: const Key('h01-alloc'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.holdingsAllocation);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (int i, SleeveAllocationRow row) in top.indexed)
              _AllocRow(index: i, row: row),
            if (vm.noticeText != null) Text(vm.noticeText!),
            if (vm.emptyLabel != null) Text(vm.emptyLabel!),
          ],
        ),
      ),
    );
  }
}

class _AllocRow extends StatelessWidget {
  const _AllocRow({required this.index, required this.row});

  final int index;
  final SleeveAllocationRow row;

  @override
  Widget build(BuildContext context) {
    final SleeveWeight? w = row.sleeveWeight;
    return Padding(
      key: ValueKey<String>('h01-sleeve-$index'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(row.sleeveLabel),
          if (w != null) Text(w.label),
          if (row.bandStateLabel != null) Text(row.bandStateLabel!),
          if (row.bandNoteText != null) Text(row.bandNoteText!),
          Row(
            children: <Widget>[
              Text(ShellLabels.homeDeployed),
              Expanded(child: Text(row.deployedPctText)),
              Text(ShellLabels.homeParking),
              Expanded(child: Text(row.parkingPctText)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Block 5 ────────────────────────────────────────────────────────────────────

class _Block5Process extends StatelessWidget {
  const _Block5Process({required this.today});

  final OpsDailySummary today;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('h01-process'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(today.streakText)),
          Expanded(child: Text(today.discretionBudgetText)),
          Expanded(child: Text(today.nextRebalanceDDayText)),
        ],
      ),
    );
  }
}

// ── Block 6 ────────────────────────────────────────────────────────────────────

class _Block6Recon extends ConsumerWidget {
  const _Block6Recon({required this.vm});

  final DiagnosticsVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return InkWell(
      key: const Key('h01-recon'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.ledgerDiffs);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(ShellLabels.homeReconTitle),
            for (final (int i, DiagnosticCell cell) in vm.cells.indexed)
              _CellLine(index: i, cell: cell, cs: cs),
            Text(vm.headline),
          ],
        ),
      ),
    );
  }
}

class _CellLine extends StatelessWidget {
  const _CellLine({required this.index, required this.cell, required this.cs});

  final int index;
  final DiagnosticCell cell;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final (IconData, Color) look = _cellLook(cs, cell.level);
    return Padding(
      key: ValueKey<String>('h01-cell-$index'),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(look.$1, color: look.$2, size: 20),
          Expanded(child: Text(cell.label)),
          Expanded(child: Text(cell.stateLabel)),
        ],
      ),
    );
  }
}

// ── Block 7 ────────────────────────────────────────────────────────────────────

class _Block7Today extends ConsumerWidget {
  const _Block7Today({required this.today});

  final OpsDailySummary today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      key: const Key('h01-today'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.opsRhythm);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 12,
          children: <Widget>[
            Text(today.todayOrdersText),
            Text(today.todayErrorsText),
            Text(today.signalMatchText),
          ],
        ),
      ),
    );
  }
}

// ── Block 8 ────────────────────────────────────────────────────────────────────

class _Block8Upcoming extends ConsumerWidget {
  const _Block8Upcoming({required this.today});

  final OpsDailySummary today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      key: const Key('h01-upcoming'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(ShellLabels.homeUpcomingTitle),
          for (final (int i, OpsRhythmRow r) in today.upcoming.indexed)
            _UpcomingRow(index: i, row: r),
          TextButton(
            key: const Key('h01-more'),
            onPressed: () {
              ref.read(shellLinkOpenerProvider).open(AppRoutes.opsRhythm);
            },
            child: const Text(ShellLabels.homeMore),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends ConsumerWidget {
  const _UpcomingRow({required this.index, required this.row});

  final int index;
  final OpsRhythmRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? dDay = row.dDayText;
    return InkWell(
      key: ValueKey<String>('h01-up-$index'),
      onTap: () {
        ref.read(shellLinkOpenerProvider).open(AppRoutes.opsRhythm);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(row.title),
            Text(row.whenText),
            if (dDay != null) Text(dDay),
          ],
        ),
      ),
    );
  }
}

// ── Block 9b ───────────────────────────────────────────────────────────────────

class _Block9bAudit extends ConsumerWidget {
  const _Block9bAudit({
    required this.safety,
    required this.trust,
    required this.cs,
  });

  final SafetyState safety;
  final LedgerTrustBadge trust;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool show = safety.activeFlags.any(
      (BlockFlag f) =>
          f.flagId == FlagIds.selfAuditDue ||
          f.flagId == FlagIds.selfAuditOverdue,
    );
    if (!show) {
      return const SizedBox.shrink();
    }
    final String? link = trust.actionDeepLink;
    return Card(
      key: const Key('h01-audit'),
      color: _levelColor(cs, trust.level),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(trust.label),
            Text(trust.consequenceLine),
            if (link != null)
              FilledButton(
                key: const Key('h01-audit-action'),
                onPressed: () {
                  ref.read(shellLinkOpenerProvider).open(link);
                },
                child: const Text(ShellLabels.homeSelfAuditAction),
              ),
          ],
        ),
      ),
    );
  }
}

// ── _BlockRetry ────────────────────────────────────────────────────────────────

class _BlockRetry extends StatelessWidget {
  const _BlockRetry({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: onRetry,
          child: const Text(ShellLabels.retry),
        ),
      ),
    );
  }
}

// ── Color & icon helpers ────────────────────────────────────────────────────────

Color _levelColor(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => cs.surfaceContainerHighest,
  UiLevel.info => cs.surfaceContainerHighest,
  UiLevel.watch => cs.tertiaryContainer,
  UiLevel.act => cs.secondaryContainer,
  UiLevel.blocked => cs.errorContainer,
};

(IconData, Color) _cellLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
