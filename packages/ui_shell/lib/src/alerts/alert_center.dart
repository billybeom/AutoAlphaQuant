// lib/src/alerts/alert_center.dart
//
// AlertCenter — N-01 알림 센터(04 §5-2).
//
// 🔴 본문 위젯이다(부모 높이 안 ListView).
// 🔴 받은 차례 그대로 그린다(재분류·재정렬·재그룹 0).
// 🔴 level 은 아이콘·색 switch 에만.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';
import 'alert_ack.dart';

// ── Data providers ─────────────────────────────────────────────────────────────

final StreamProviderFamily<AlertCenterVm, bool> _centerProvider =
    StreamProvider.family<AlertCenterVm, bool>(
      (Ref ref, bool p0Only) =>
          ref.watch(shellAlertRepositoryProvider).watchCenter(p0Only: p0Only),
    );

// ── AlertCenter ────────────────────────────────────────────────────────────────

/// N-01 알림 센터.
class AlertCenter extends ConsumerStatefulWidget {
  const AlertCenter({super.key});

  @override
  ConsumerState<AlertCenter> createState() => _AlertCenterState();
}

class _AlertCenterState extends ConsumerState<AlertCenter> {
  bool _p0Only = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AlertCenterVm> center = ref.watch(
      _centerProvider(_p0Only),
    );

    if (center.hasError) {
      return ShellErrorView(
        key: const Key('n01-fail'),
        onRetry: () => ref.invalidate(_centerProvider(_p0Only)),
        lastAsOfLabel: center.valueOrNull?.asOf.label,
      );
    }

    final AlertCenterVm? vm = center.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('n01-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? empty = vm.emptyLabel;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ShellAsOfHeader(key: const Key('n01-asof'), asOf: vm.asOf),
        if (stale) ShellStaleBanner(asOf: vm.asOf),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              key: const Key('n01-p0-only'),
              label: const Text(ShellLabels.alertsP0Only),
              selected: _p0Only,
              onSelected: (bool v) => setState(() => _p0Only = v),
            ),
          ),
        ),
        for (final (int i, AlertItem a) in vm.pinned.indexed)
          _AlertTile(keyBase: 'n01-pin-$i', item: a),
        for (final (int s, AlertSection sec) in vm.sections.indexed)
          _SectionBlock(index: s, section: sec),
        if (empty != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(empty, key: const Key('n01-empty')),
          ),
      ],
    );
  }
}

// ── _SectionBlock ──────────────────────────────────────────────────────────────

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.index, required this.section});

  final int index;
  final AlertSection section;

  @override
  Widget build(BuildContext context) {
    final int s = index;
    final String? digest = section.digestLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          key: ValueKey<String>('n01-sec-$s'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(section.headerText),
        ),
        for (final (int i, AlertItem a) in section.rows.indexed)
          _AlertTile(keyBase: 'n01-row-$s-$i', item: a),
        if (digest != null)
          _DigestBlock(index: s, label: digest, rows: section.digestRows),
      ],
    );
  }
}

// ── _DigestBlock ───────────────────────────────────────────────────────────────

class _DigestBlock extends StatefulWidget {
  const _DigestBlock({
    required this.index,
    required this.label,
    required this.rows,
  });

  final int index;
  final String label;
  final List<AlertItem> rows;

  @override
  State<_DigestBlock> createState() => _DigestBlockState();
}

class _DigestBlockState extends State<_DigestBlock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final int s = widget.index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          key: ValueKey<String>('n01-digest-$s'),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(widget.label)),
                Icon(_open ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_open)
          for (final (int i, AlertItem a) in widget.rows.indexed)
            _AlertTile(keyBase: 'n01-drow-$s-$i', item: a),
      ],
    );
  }
}

// ── _AlertTile ─────────────────────────────────────────────────────────────────

class _AlertTile extends ConsumerWidget {
  const _AlertTile({required this.keyBase, required this.item});

  final String keyBase;
  final AlertItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? link = item.detailDeepLink;
    final String? grouped = item.groupedText;
    final String? when = item.raisedAtText;
    final (IconData, Color) look = _levelLook(
      Theme.of(context).colorScheme,
      item.level,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          key: ValueKey<String>(keyBase),
          onTap: link == null
              ? null
              : () {
                  ref.read(shellLinkOpenerProvider).open(link);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Icon(look.$1, color: look.$2, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(item.title)),
                if (grouped != null) Badge(label: Text(grouped)),
                if (when != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(when),
                  ),
              ],
            ),
          ),
        ),
        AlertAckBlock(keyBase: keyBase, alertId: item.alertId, ack: item.ack),
      ],
    );
  }
}

// ── _levelLook ─────────────────────────────────────────────────────────────────

(IconData, Color) _levelLook(ColorScheme cs, AlertLevel l) => switch (l) {
  AlertLevel.p0 => (Icons.error_outline, cs.error),
  AlertLevel.p1 => (Icons.warning_amber_outlined, cs.tertiary),
  AlertLevel.p2 => (Icons.info_outline, cs.onSurfaceVariant),
};
