// lib/src/device_risk_board.dart
//
// DeviceRiskBoard — H-03 물리 리스크 점검 상세(계약 v1.17).
//
// 🔴 래퍼 없음(화면 규칙 · 부모 높이 안 ListView).
// 🔴 구독 하나. 항목 목록·순서·수·글자는 받은 그대로이고 등급은 아이콘·색으로만 쓴다.
// 🔴 이동·조작 자리 없음.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/shell_common.dart';
import 'shell_providers.dart';

// ── Device risk provider ───────────────────────────────────────────────────────

final StreamProvider<DeviceRiskVm> _deviceRiskProvider =
    StreamProvider<DeviceRiskVm>(
      (Ref ref) =>
          ref.watch(shellOpsStatusRepositoryProvider).watchDeviceRisk(),
    );

// ── DeviceRiskBoard ────────────────────────────────────────────────────────────

/// H-03 물리 리스크 점검 상세.
class DeviceRiskBoard extends ConsumerWidget {
  const DeviceRiskBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DeviceRiskVm> risk = ref.watch(_deviceRiskProvider);

    if (risk.hasError) {
      return ShellErrorView(
        key: const Key('h03-fail'),
        onRetry: () {
          ref.invalidate(_deviceRiskProvider);
        },
        lastAsOfLabel: risk.valueOrNull?.asOf.label,
      );
    }

    final DeviceRiskVm? vm = risk.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('h03-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? empty = vm.emptyLabel;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ShellAsOfHeader(key: const Key('h03-asof'), asOf: vm.asOf),
        if (stale) ShellStaleBanner(key: const Key('h03-stale'), asOf: vm.asOf),
        for (final (int i, DeviceRiskItem r) in vm.rows.indexed)
          Padding(
            key: ValueKey<String>('h03-row-$i'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  _levelLook(cs, r.level).$1,
                  key: ValueKey<String>('h03-level-$i'),
                  size: 24,
                  color: _levelLook(cs, r.level).$2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(r.label),
                      Text(r.currentText),
                      Text(r.thresholdText),
                      Text(r.actionText),
                      Text(r.lastCheckedText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (empty != null)
          Padding(
            key: const Key('h03-empty'),
            padding: const EdgeInsets.all(16),
            child: Text(empty),
          ),
        Padding(
          key: const Key('h03-guidance'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.guidanceText),
        ),
      ],
    );
  }
}

// ── _levelLook ─────────────────────────────────────────────────────────────────

(IconData, Color) _levelLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
