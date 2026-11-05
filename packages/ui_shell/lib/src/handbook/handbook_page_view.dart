// lib/src/handbook/handbook_page_view.dart
//
// HandbookPageView — B-02 핸드북 페이지 (04 §8 · 계약 v1.17).
//
// 블록은 받은 차례대로 글자 그대로 그린다. 라이브 값 등급은 아이콘과 색에만 쓴다.
// asOf 가 있는 페이지(라이브 값이 든 쪽)만 머리와 오래됨 배너를 그린다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProviderFamily<HandbookPage, String> _handbookPageProvider =
    StreamProvider.family<HandbookPage, String>(
      (Ref ref, String anchor) =>
          ref.watch(shellHandbookRepositoryProvider)!.watchPage(anchor),
    );

/// B-02 핸드북 페이지.
class HandbookPageView extends ConsumerWidget {
  const HandbookPageView({super.key, required this.anchor});

  final String anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shellHandbookRepositoryProvider) == null) {
      return const ShellPlaceholder();
    }

    final AsyncValue<HandbookPage> page = ref.watch(
      _handbookPageProvider(anchor),
    );

    if (page.hasError) {
      return ShellErrorView(
        key: const Key('b02-fail'),
        onRetry: () {
          ref.invalidate(_handbookPageProvider(anchor));
        },
        lastAsOfLabel: page.valueOrNull?.asOf?.label,
      );
    }

    final HandbookPage? v = page.valueOrNull;
    if (v == null) {
      return const ShellSkeleton(key: Key('b02-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final AsOf? asOf = v.asOf;
    final bool stale =
        asOf != null &&
        asOf.observedAt.add(asOf.staleAfter).isBefore(clock.nowUtc());
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? notice = v.outdatedNotice;
    final String? missing = v.missingLabel;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (asOf != null)
          ShellAsOfHeader(key: const Key('b02-asof'), asOf: asOf),
        if (asOf != null && stale)
          ShellStaleBanner(key: const Key('b02-stale'), asOf: asOf),
        if (notice != null)
          Padding(
            key: const Key('b02-outdated'),
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
        Padding(
          key: const Key('b02-title'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(v.title),
        ),
        if (missing != null)
          Padding(
            key: const Key('b02-missing'),
            padding: const EdgeInsets.all(16),
            child: Text(missing),
          ),
        for (final (int i, HandbookBlock blk) in v.blocks.indexed)
          _blockView(ref, cs, i, blk),
      ],
    );
  }
}

Widget _blockView(WidgetRef ref, ColorScheme cs, int i, HandbookBlock blk) {
  final HandbookLiveValue? live = blk.live;
  final String? link = blk.deepLink;
  return InkWell(
    key: ValueKey<String>('b02-block-$i'),
    onTap: link == null
        ? null
        : () {
            ref.read(shellLinkOpenerProvider).open(link);
          },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (live != null)
            Row(
              key: ValueKey<String>('b02-live-$i'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  _liveLook(cs, live.level).$1,
                  size: 24,
                  color: _liveLook(cs, live.level).$2,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(live.label)),
              ],
            ),
          Text(blk.text),
        ],
      ),
    ),
  );
}

(IconData, Color) _liveLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.pending_actions_outlined, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
