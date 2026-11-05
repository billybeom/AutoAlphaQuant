// lib/src/incident/emergency_stop_card.dart
//
// EmergencyStopCard — D-03 오프라인 긴급정지 카드 (04 §6 · 계약 v1.17).
//
// 가족이 종이로 들고 있을 한 장이다. 제목 · 단계 · 연락처 · 보관 고지는 받은 그대로이고,
// 종이로 내는 자리는 주입된 슬롯 빌더에 이름만 넘긴다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../shell_providers.dart';

final StreamProvider<EmergencyCardVm> _emergencyCardProvider =
    StreamProvider<EmergencyCardVm>(
      (Ref ref) =>
          ref.watch(shellRunbookRepositoryProvider).watchEmergencyCard(),
    );

/// D-03 오프라인 긴급정지 카드.
class EmergencyStopCard extends ConsumerWidget {
  const EmergencyStopCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EmergencyCardVm> card = ref.watch(_emergencyCardProvider);

    if (card.hasError) {
      return ShellErrorView(
        key: const Key('d03-fail'),
        onRetry: () {
          ref.invalidate(_emergencyCardProvider);
        },
      );
    }

    final EmergencyCardVm? vm = card.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('d03-loading'));
    }

    final String? printId = vm.printSlotId;
    final ShellSlotBuilder? place = ref.watch(shellOpsSlotBuilderProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('d03-title'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.title),
        ),
        for (final (int i, RunbookStep s) in vm.steps.indexed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              key: ValueKey<String>('d03-step-$i'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.orderText),
                const SizedBox(width: 8),
                Expanded(child: Text(s.text)),
              ],
            ),
          ),
        Padding(
          key: const Key('d03-contact'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.contactLine),
        ),
        Padding(
          key: const Key('d03-notice'),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(vm.keepOnPaperNotice),
        ),
        if (printId != null && place != null)
          Padding(
            key: const Key('d03-print'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: place(printId),
          ),
      ],
    );
  }
}
