// lib/src/handbook/handbook_contents.dart
//
// HandbookContents — B-01 전략 핸드북 목차 (04 §8 · 계약 v1.17).
//
// 항목 수·차례·자식은 받은 그대로 그린다. 상태는 아이콘과 색에만 쓰고, 탭 목적지는
// 항목이 가져온 링크뿐이다. 준비 중 항목은 링크가 없어 눌리지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<HandbookIndex> _handbookIndexProvider =
    StreamProvider<HandbookIndex>(
      (Ref ref) => ref.watch(shellHandbookRepositoryProvider)!.watchIndex(),
    );

/// B-01 전략 핸드북 목차.
class HandbookContents extends ConsumerWidget {
  const HandbookContents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shellHandbookRepositoryProvider) == null) {
      return const ShellPlaceholder();
    }

    final AsyncValue<HandbookIndex> index = ref.watch(_handbookIndexProvider);

    if (index.hasError) {
      return ShellErrorView(
        key: const Key('b01-fail'),
        onRetry: () {
          ref.invalidate(_handbookIndexProvider);
        },
      );
    }

    final HandbookIndex? v = index.valueOrNull;
    if (v == null) {
      return const ShellSkeleton(key: Key('b01-loading'));
    }

    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? notice = v.outdatedNotice;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (notice != null)
          Padding(
            key: const Key('b01-outdated'),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.warning_amber_outlined, size: 24, color: cs.error),
                const SizedBox(width: 12),
                Expanded(child: Text(notice)),
              ],
            ),
          ),
        for (final (int i, HandbookEntry e) in v.entries.indexed) ...<Widget>[
          ListTile(
            key: ValueKey<String>('b01-entry-$i'),
            leading: Icon(
              _stateLook(cs, e.state).$1,
              key: ValueKey<String>('b01-state-$i'),
              size: 24,
              color: _stateLook(cs, e.state).$2,
            ),
            title: Text(e.title),
            subtitle: e.stateLabel == null ? null : Text(e.stateLabel!),
            onTap: e.deepLink == null
                ? null
                : () {
                    ref.read(shellLinkOpenerProvider).open(e.deepLink!);
                  },
          ),
          for (final (int j, HandbookEntry c) in e.children.indexed)
            ListTile(
              key: ValueKey<String>('b01-entry-$i-$j'),
              contentPadding: const EdgeInsets.only(left: 40, right: 16),
              leading: Icon(
                _stateLook(cs, c.state).$1,
                key: ValueKey<String>('b01-state-$i-$j'),
                size: 24,
                color: _stateLook(cs, c.state).$2,
              ),
              title: Text(c.title),
              subtitle: c.stateLabel == null ? null : Text(c.stateLabel!),
              onTap: c.deepLink == null
                  ? null
                  : () {
                      ref.read(shellLinkOpenerProvider).open(c.deepLink!);
                    },
            ),
        ],
      ],
    );
  }
}

(IconData, Color) _stateLook(ColorScheme cs, HandbookEntryState s) =>
    switch (s) {
      HandbookEntryState.ready => (Icons.menu_book_outlined, cs.primary),
      HandbookEntryState.preparing => (
        Icons.hourglass_empty,
        cs.onSurfaceVariant,
      ),
      HandbookEntryState.archived => (Icons.inventory_2_outlined, cs.outline),
    };
