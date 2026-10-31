// lib/src/watchdog_board.dart
//
// WatchdogBoard — W-01 워치독 상태(04 §7 · K3 · K4 · K15~K17 · 계약 v1.15).
//
// 🔴 래퍼 없음(화면 규칙 · 부모 높이 안 ListView).
// 🔴 구독 하나(watchWatchdog).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/shell_common.dart';
import 'routing/shell_router.dart';
import 'shell_providers.dart';

// ── Watchdog provider ──────────────────────────────────────────────────────────

final StreamProvider<WatchdogBoardVm> _watchdogProvider =
    StreamProvider<WatchdogBoardVm>(
      (Ref ref) => ref.watch(shellOpsStatusRepositoryProvider).watchWatchdog(),
    );

// ── WatchdogBoard ──────────────────────────────────────────────────────────────

/// W-01 워치독 상태.
class WatchdogBoard extends ConsumerWidget {
  const WatchdogBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WatchdogBoardVm> watchdog = ref.watch(_watchdogProvider);

    if (watchdog.hasError) {
      return ShellErrorView(
        key: const Key('w01-fail'),
        onRetry: () => ref.invalidate(_watchdogProvider),
        lastAsOfLabel: watchdog.valueOrNull?.asOf.label,
      );
    }

    final WatchdogBoardVm? vm = watchdog.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('w01-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());

    final String? received = vm.lastReceivedText;
    final String? empty = vm.emptyLabel;
    final String? holiday = vm.holidayNotice;
    final String? limit = vm.limitNotice;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ShellAsOfHeader(key: const Key('w01-asof'), asOf: vm.asOf),
        if (stale) ShellStaleBanner(asOf: vm.asOf),
        if (received != null)
          Padding(
            key: const Key('w01-received'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(received),
          ),
        for (final (int i, WatchdogCheck c) in vm.rows.indexed) _CheckRow(i, c),
        if (empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('w01-empty')),
          ),
        if (holiday != null)
          Padding(
            key: const Key('w01-holiday'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(holiday),
          ),
        if (limit != null)
          Padding(
            key: const Key('w01-limit'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(limit),
          ),
      ],
    );
  }
}

// ── _CheckRow ──────────────────────────────────────────────────────────────────

class _CheckRow extends ConsumerWidget {
  const _CheckRow(this.index, this.check);

  final int index;
  final WatchdogCheck check;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? route = check.route;
    final String? grace = check.graceText;
    final (IconData, Color) look = _checkLook(
      Theme.of(context).colorScheme,
      check.level,
    );
    return InkWell(
      key: ValueKey<String>('w01-row-$index'),
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
            Icon(look.$1, color: look.$2, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(check.label)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(check.stateLabel),
                  Text(check.lastPingText),
                  if (grace != null) Text(grace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _checkLook ─────────────────────────────────────────────────────────────────

(IconData, Color) _checkLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
