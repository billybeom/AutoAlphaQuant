// lib/src/settings_home.dart
//
// SettingsHome — M9 S01 설정 홈(계약 v1.18).
//
// 🔴 본문이다 — 부모 높이 안 ListView(padding: EdgeInsets.zero).
// 🔴 묶음·카드 차례·수 = 받은 그대로(정렬·세기·묶기 0).
// 🔴 쓰기 0 — 탭 = 받은 링크를 settingsLinkOpenerProvider 로 여는 것뿐.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/settings_common.dart';
import 'settings_providers.dart';

// ── Data provider ──────────────────────────────────────────────────────────────

final StreamProvider<SettingsHomeVm> _settingsHomeProvider =
    StreamProvider<SettingsHomeVm>(
      (Ref ref) => ref.watch(settingsRepositoryProvider).watchHome(),
    );

// ── SettingsHome ───────────────────────────────────────────────────────────────

/// M9 S01 설정 홈.
class SettingsHome extends ConsumerWidget {
  const SettingsHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SettingsHomeVm> home = ref.watch(_settingsHomeProvider);

    if (home.hasError) {
      return SettingsErrorView(
        key: const Key('m9s01-fail'),
        onRetry: () {
          ref.invalidate(_settingsHomeProvider);
        },
        lastAsOfLabel: home.valueOrNull?.asOf.label,
      );
    }

    final SettingsHomeVm? vm = home.valueOrNull;
    if (vm == null) {
      return const SettingsSkeleton(key: Key('m9s01-loading'));
    }

    final Clock clock = ref.watch(settingsClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (stale)
          SettingsStaleBanner(key: const Key('m9s01-stale'), asOf: vm.asOf),
        Padding(
          key: const Key('m9s01-chip'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                settingsLevelLook(cs, vm.statusChip.level).$1,
                key: const Key('m9s01-chip-level'),
                size: 24,
                color: settingsLevelLook(cs, vm.statusChip.level).$2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(vm.statusChip.label),
                    if (vm.statusChip.promotionLabel != null)
                      Text(vm.statusChip.promotionLabel!),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (vm.annualReviewLink != null)
          InkWell(
            key: const Key('m9s01-review'),
            onTap: () {
              ref.read(settingsLinkOpenerProvider).open(vm.annualReviewLink!.deepLink);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(vm.annualReviewLink!.label)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        for (final (int g, SettingsGroup group) in vm.groups.indexed) ...<Widget>[
          Padding(
            key: ValueKey<String>('m9s01-group-$g'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: <Widget>[
                Flexible(child: Text(group.label)),
                if (_tierLock(group.tier) != null)
                  Icon(
                    _tierLock(group.tier)!,
                    key: ValueKey<String>('m9s01-lock-$g'),
                  ),
              ],
            ),
          ),
          for (final (int c, SettingsCard card) in group.cards.indexed)
            _CardRow(
              key: ValueKey<String>('m9s01-card-$g-$c'),
              card: card,
              groupIndex: g,
              cardIndex: c,
              cs: cs,
              onTap: card.route == null
                  ? null
                  : () {
                      ref.read(settingsLinkOpenerProvider).open(card.route!);
                    },
            ),
        ],
        SettingsAsOfLine(key: const Key('m9s01-asof'), asOf: vm.asOf),
      ],
    );
  }
}

// ── _tierLock ──────────────────────────────────────────────────────────────────

IconData? _tierLock(SettingTier tier) => switch (tier) {
  SettingTier.general => null,
  SettingTier.operational => Icons.lock_outline,
  SettingTier.rule => Icons.lock_outline,
};

// ── _CardRow ───────────────────────────────────────────────────────────────────

class _CardRow extends StatelessWidget {
  const _CardRow({
    super.key,
    required this.card,
    required this.groupIndex,
    required this.cardIndex,
    required this.cs,
    required this.onTap,
  });

  final SettingsCard card;
  final int groupIndex;
  final int cardIndex;
  final ColorScheme cs;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? attention = card.attentionText;
    final String? route = card.route;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              settingsLevelLook(cs, card.level).$1,
              key: ValueKey<String>('m9s01-level-$groupIndex-$cardIndex'),
              size: 24,
              color: settingsLevelLook(cs, card.level).$2,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(card.title),
                  if (card.statusLabel != null) Text(card.statusLabel!),
                ],
              ),
            ),
            if (attention != null)
              Padding(
                key: ValueKey<String>(
                  'm9s01-attention-$groupIndex-$cardIndex',
                ),
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Badge(label: Text(attention)),
              ),
            if (route != null) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
