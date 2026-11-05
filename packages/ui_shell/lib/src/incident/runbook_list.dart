// lib/src/incident/runbook_list.dart
//
// RunbookList — D-02 DR 런북 목록 (04 §6 · 계약 v1.17).
//
// 행 제목 · 요약 · 빈 목록 문장은 받은 그대로다. 행을 누르면 그 행이 가진 링크를 연다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<RunbookIndexVm> _runbookIndexProvider =
    StreamProvider<RunbookIndexVm>(
      (Ref ref) =>
          ref.watch(shellRunbookRepositoryProvider).watchRunbookIndex(),
    );

/// D-02 DR 런북 목록.
class RunbookList extends ConsumerWidget {
  const RunbookList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RunbookIndexVm> index = ref.watch(_runbookIndexProvider);

    if (index.hasError) {
      return ShellErrorView(
        key: const Key('d02-list-fail'),
        onRetry: () {
          ref.invalidate(_runbookIndexProvider);
        },
      );
    }

    final RunbookIndexVm? vm = index.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('d02-list-loading'));
    }

    final String? emptyLabel = vm.emptyLabel;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        for (final (int i, RunbookRow r) in vm.rows.indexed)
          ListTile(
            key: ValueKey<String>('d02-list-row-$i'),
            title: Text(r.title),
            subtitle: r.summaryText == null ? null : Text(r.summaryText!),
            onTap: () {
              ref.read(shellLinkOpenerProvider).open(r.deepLink);
            },
          ),
        if (emptyLabel != null)
          Padding(
            key: const Key('d02-list-empty'),
            padding: const EdgeInsets.all(16),
            child: Text(emptyLabel),
          ),
      ],
    );
  }
}
