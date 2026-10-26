// lib/src/ops_rhythm.dart
//
// OpsRhythm — H-02 운영 리듬 표(04 §4-7 · K29 · K30 · K43).
//
// 🔴 Scaffold·AppBar·SafeArea 없음(화면 규칙 · 부모 높이 안 ListView).
// 🔴 OpsSummaryRepository.watchRhythm() 하나만 구독.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/labels.dart';
import 'common/shell_common.dart';
import 'routing/shell_router.dart';
import 'shell_providers.dart';

// ── Rhythm provider ────────────────────────────────────────────────────────────

final StreamProvider<ListResult<OpsRhythmRow>> _rhythmProvider =
    StreamProvider<ListResult<OpsRhythmRow>>(
      (Ref ref) => ref.watch(shellOpsSummaryRepositoryProvider).watchRhythm(),
    );

// ── OpsRhythm ──────────────────────────────────────────────────────────────────

/// H-02 운영 리듬 표.
class OpsRhythm extends ConsumerWidget {
  const OpsRhythm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ListResult<OpsRhythmRow>> rhythm = ref.watch(
      _rhythmProvider,
    );

    if (rhythm.hasError) {
      return ShellErrorView(
        key: const Key('h02-fail'),
        onRetry: () => ref.invalidate(_rhythmProvider),
        lastAsOfLabel: rhythm.valueOrNull?.asOf.label,
      );
    }

    final ListResult<OpsRhythmRow>? r = rhythm.valueOrNull;
    if (r == null) {
      return const ShellSkeleton(key: Key('h02-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = r.asOf.observedAt
        .add(r.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? empty = r.emptyLabel;

    if (r.rows.isEmpty) {
      // 빈 갈래
      return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ShellAsOfHeader(key: const Key('h02-asof'), asOf: r.asOf),
          if (stale) ShellStaleBanner(asOf: r.asOf),
          if (empty != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(empty, key: const Key('h02-empty')),
            ),
        ],
      );
    }

    // 정상 갈래
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ShellAsOfHeader(key: const Key('h02-asof'), asOf: r.asOf),
        if (stale) ShellStaleBanner(asOf: r.asOf),
        Padding(
          key: const Key('h02-head'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(ShellLabels.rhythmColumnItem)),
              Expanded(child: Text(ShellLabels.rhythmColumnNext)),
            ],
          ),
        ),
        for (final (int i, OpsRhythmRow row) in r.rows.indexed)
          _RhythmRow(i, row),
      ],
    );
  }
}

// ── _RhythmRow ─────────────────────────────────────────────────────────────────

class _RhythmRow extends ConsumerWidget {
  const _RhythmRow(this.index, this.row);

  final int index;
  final OpsRhythmRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? route = row.route;
    final String? dDay = row.dDayText;
    return InkWell(
      key: ValueKey<String>('h02-row-$index'),
      onTap: route == null
          ? null
          : () {
              ref.read(shellLinkOpenerProvider).open(route);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(row.title, key: ValueKey<String>('h02-title-$index')),
            ),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  Text(row.whenText, key: ValueKey<String>('h02-when-$index')),
                  if (dDay != null)
                    Text(dDay, key: ValueKey<String>('h02-dday-$index')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
