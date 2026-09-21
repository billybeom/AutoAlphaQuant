// packages/ui_analytics/lib/src/widgets/safety_block_banner.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

class SafetyBlockBanner extends StatelessWidget {
  const SafetyBlockBanner({
    super.key,
    required this.activeFlags,
    this.onOpenLink,
  });

  final List<BlockFlag> activeFlags;
  final void Function(String link)? onOpenLink;

  @override
  Widget build(BuildContext context) {
    if (activeFlags.isEmpty) {
      return const SizedBox.shrink();
    }

    final markerFlags = <BlockFlag>[];
    final blockingFlags = <BlockFlag>[];
    for (final flag in activeFlags) {
      if (FlagIds.markerOnly.contains(flag.flagId)) {
        markerFlags.add(flag);
      } else {
        blockingFlags.add(flag);
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    final displayBlocking = blockingFlags.take(2).toList();
    final remainingCount = blockingFlags.length - displayBlocking.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (markerFlags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: [
                for (final flag in markerFlags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      flag.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (blockingFlags.isNotEmpty)
          Container(
            width: double.infinity,
            color: colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final flag in displayBlocking)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.block,
                          color: colorScheme.onErrorContainer,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                flag.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                flag.clearInstruction,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                              if (flag.checkpointLabel != null &&
                                  flag.checkpointLabel!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    flag.checkpointLabel!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (flag.clearDeepLink != null)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            onPressed: () =>
                                onOpenLink?.call(flag.clearDeepLink!),
                          ),
                      ],
                    ),
                  ),
                if (remainingCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
