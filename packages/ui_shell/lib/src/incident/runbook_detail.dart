// lib/src/incident/runbook_detail.dart
//
// RunbookDetail — D-02 DR 런북 상세 (04 §6 · 계약 v1.17).
//
// 번호와 단계 글자는 받은 그대로다. 단계 앞 체크는 이 화면만 아는 표시이고
// 아무 곳에도 보내지 않는다 — 그 사실은 맨 아래 고지(받은 글자)가 말한다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../shell_providers.dart';

final StreamProviderFamily<RunbookVm, String> _runbookProvider =
    StreamProvider.family<RunbookVm, String>(
      (Ref ref, String runbookId) =>
          ref.watch(shellRunbookRepositoryProvider).watchRunbook(runbookId),
    );

/// D-02 DR 런북 상세.
class RunbookDetail extends ConsumerStatefulWidget {
  const RunbookDetail({super.key, required this.runbookId});

  final String runbookId;

  @override
  ConsumerState<RunbookDetail> createState() => _RunbookDetailState();
}

class _RunbookDetailState extends ConsumerState<RunbookDetail> {
  final Set<int> _checked = <int>{};

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RunbookVm> runbook = ref.watch(
      _runbookProvider(widget.runbookId),
    );

    if (runbook.hasError) {
      return ShellErrorView(
        key: const Key('d02-fail'),
        onRetry: () {
          ref.invalidate(_runbookProvider(widget.runbookId));
        },
      );
    }

    final RunbookVm? vm = runbook.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('d02-loading'));
    }

    final String? intro = vm.introText;
    final String? missing = vm.missingLabel;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('d02-title'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.title),
        ),
        if (intro != null)
          Padding(
            key: const Key('d02-intro'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(intro),
          ),
        for (final (int i, RunbookStep s) in vm.steps.indexed)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
            child: Row(
              key: ValueKey<String>('d02-step-$i'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  key: ValueKey<String>('d02-check-$i'),
                  value: _checked.contains(i),
                  onChanged: (bool? v) {
                    setState(() {
                      if (v ?? false) {
                        _checked.add(i);
                      } else {
                        _checked.remove(i);
                      }
                    });
                  },
                ),
                Text(s.orderText),
                const SizedBox(width: 8),
                Expanded(child: Text(s.text)),
              ],
            ),
          ),
        if (missing != null)
          Padding(
            key: const Key('d02-missing'),
            padding: const EdgeInsets.all(16),
            child: Text(missing),
          ),
        Padding(
          key: const Key('d02-notice'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.localCheckNotice),
        ),
      ],
    );
  }
}
