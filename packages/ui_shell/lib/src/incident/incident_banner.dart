// lib/src/incident/incident_banner.dart
//
// IncidentBannerSlot — D-01 장애 배너 (04 §6 · 계약 v1.17).
//
// 엔진이 고른 배너 한 건을 셸 탭 본문 위에 그린다. 종류는 아이콘에만, 등급은 색에만 쓴다.
// 제목 · 본문 · 조치 글자와 조치 링크는 받은 그대로다. 배너가 없으면 아무것도 그리지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/shell_common.dart';
import '../routing/shell_router.dart';
import '../shell_providers.dart';

final StreamProvider<IncidentBannerVm> _incidentProvider =
    StreamProvider<IncidentBannerVm>(
      (Ref ref) => ref.watch(shellIncidentRepositoryProvider)!.watchIncident(),
    );

/// D-01 장애 배너 자리 — 셸 탭 본문 위.
class IncidentBannerSlot extends ConsumerWidget {
  const IncidentBannerSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shellIncidentRepositoryProvider) == null) {
      return const SizedBox.shrink();
    }

    final AsyncValue<IncidentBannerVm> incident = ref.watch(_incidentProvider);

    if (incident.hasError) {
      return ShellErrorView(
        key: const Key('d01-fail'),
        onRetry: () {
          ref.invalidate(_incidentProvider);
        },
      );
    }

    final IncidentBanner? b = incident.valueOrNull?.banner;
    if (b == null) {
      return const SizedBox.shrink();
    }

    final LinkAction? a = b.actionLink;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Material(
      key: const Key('d01-banner'),
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              _kindIcon(b.kind),
              key: const Key('d01-icon'),
              size: 24,
              color: _levelColor(cs, b.level),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(b.title),
                  Text(b.bodyText),
                  if (a != null)
                    TextButton(
                      key: const Key('d01-action'),
                      onPressed: () {
                        ref.read(shellLinkOpenerProvider).open(a.deepLink);
                      },
                      child: Text(a.label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _kindIcon(IncidentKind k) => switch (k) {
  IncidentKind.phoneDown => Icons.phonelink_erase,
  IncidentKind.networkDown => Icons.wifi_off,
  IncidentKind.tokenExpired => Icons.vpn_key_off,
  IncidentKind.orderRejected => Icons.assignment_late_outlined,
  IncidentKind.other => Icons.info_outline,
};

Color _levelColor(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => cs.primary,
  UiLevel.info => cs.onSurfaceVariant,
  UiLevel.watch => cs.tertiary,
  UiLevel.act => cs.secondary,
  UiLevel.blocked => cs.error,
};
