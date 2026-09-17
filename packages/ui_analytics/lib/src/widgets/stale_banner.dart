// packages/ui_analytics/lib/src/widgets/stale_banner.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';

class StaleBanner extends ConsumerWidget {
  const StaleBanner({
    super.key,
    required this.asOf,
  });

  final AsOf asOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(analyticsClockProvider);
    final isStale = asOf.observedAt.add(asOf.staleAfter).isBefore(clock.nowUtc());

    if (!isStale || asOf.staleLabel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AnalyticsLabels.staleBannerTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  asOf.staleLabel!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
