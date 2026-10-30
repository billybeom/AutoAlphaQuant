// lib/src/alerts/alert_detail.dart
//
// AlertDetail — N-02 알림 상세(04 §5-3).
//
// 🔴 본문 위젯이다(부모 높이 안 ListView).
// 🔴 블록 순서 고정(머리 → 제목 → 시각 → 무슨 일 → 조치 → 근거 → 확인).
// 🔴 모르는 id = missingLabel 한 줄(에러 화면 아님).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';
import 'alert_ack.dart';

// ── Data providers ─────────────────────────────────────────────────────────────

final StreamProviderFamily<AlertDetailVm, String> _alertDetailProvider =
    StreamProvider.family<AlertDetailVm, String>(
      (Ref ref, String alertId) =>
          ref.watch(shellAlertRepositoryProvider).watchAlert(alertId),
    );

// ── AlertDetail ────────────────────────────────────────────────────────────────

/// N-02 알림 상세.
class AlertDetail extends ConsumerWidget {
  const AlertDetail({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AlertDetailVm> detail = ref.watch(
      _alertDetailProvider(alertId),
    );

    if (detail.hasError) {
      return ShellErrorView(
        key: const Key('n02-fail'),
        onRetry: () => ref.invalidate(_alertDetailProvider(alertId)),
        lastAsOfLabel: detail.valueOrNull?.asOf.label,
      );
    }

    final AlertDetailVm? vm = detail.valueOrNull;
    if (vm == null) {
      return const ShellSkeleton(key: Key('n02-loading'));
    }

    final Clock clock = ref.watch(shellClockProvider);
    final bool stale = vm.asOf.observedAt
        .add(vm.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    final String? missing = vm.missingLabel;
    final AlertItem? item = vm.item;
    final String? when = item?.raisedAtText;
    final String? link = item?.deepLink;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ShellAsOfHeader(key: const Key('n02-asof'), asOf: vm.asOf),
        if (stale) ShellStaleBanner(asOf: vm.asOf),
        if (missing != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(missing, key: const Key('n02-missing')),
          ),
        if (item != null) ...<Widget>[
          Padding(
            key: const Key('n02-title'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (when != null)
            Padding(
              key: const Key('n02-time'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(when),
            ),
          Padding(
            key: const Key('n02-body'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(item.bodyText),
          ),
          Padding(
            key: const Key('n02-action'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(item.actionLine),
          ),
          if (link != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: const Key('n02-link'),
                  onPressed: () {
                    ref.read(shellLinkOpenerProvider).open(link);
                  },
                  child: const Text(ShellLabels.alertsEvidence),
                ),
              ),
            ),
          AlertAckBlock(keyBase: 'n02', alertId: item.alertId, ack: item.ack),
        ],
      ],
    );
  }
}
