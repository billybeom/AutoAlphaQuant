// lib/src/onboarding/viewer_pairing.dart
//
// ViewerPairing — V-01 조회 전용 QR 페어링 (04 §9-7 · 계약 v1.16).
//
// 스캔 자리는 주입된 슬롯 빌더에 이름만 넘기고, 연결 시도의 판정은 플랫폼과 엔진이 한다.
// 결과는 받은 등급 · 문구 · 원문 코드 그대로 그리고, 다음 링크가 있으면 받은 링크를 그대로 연다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<PairingVm> _pairingProvider = StreamProvider<PairingVm>(
  (Ref ref) => ref.watch(shellPairingRepositoryProvider).watchPairing(),
);

/// V-01 조회 전용 QR 페어링.
class ViewerPairing extends ConsumerWidget {
  const ViewerPairing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PairingVm> pairing = ref.watch(_pairingProvider);

    if (pairing.hasError) {
      return ShellErrorView(
        key: const Key('v01-fail'),
        onRetry: () => ref.invalidate(_pairingProvider),
      );
    }

    final PairingVm? vm = pairing.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('v01-loading'));
    }

    final String? scannerSlot = vm.scannerSlotId;
    final PairingResult? r = vm.result;
    final String? code = r?.reasonCode;
    final LinkAction? next = r?.nextLink;
    final ShellSlotBuilder? place = ref.watch(
      shellOnboardingSlotBuilderProvider,
    );
    final ColorScheme cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          key: const Key('v01-headline'),
          padding: const EdgeInsets.all(16),
          child: Text(vm.headline),
        ),
        if (scannerSlot != null && place != null)
          Padding(
            key: const Key('v01-scanner'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: place(scannerSlot),
          ),
        if (r != null)
          Padding(
            key: const Key('v01-result'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      _resultLook(cs, r.level).$1,
                      color: _resultLook(cs, r.level).$2,
                      key: const Key('v01-level'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r.headline)),
                  ],
                ),
                if (code != null) Text(code),
              ],
            ),
          ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FilledButton(
              key: const Key('v01-next'),
              onPressed: () {
                ref.read(shellLinkOpenerProvider).open(next.deepLink);
              },
              child: Text(next.label),
            ),
          ),
      ],
    );
  }
}

(IconData, Color) _resultLook(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};
