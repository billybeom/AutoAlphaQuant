// packages/ui_analytics/lib/src/widgets/safety_block_banner.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

class SafetyBlockBanner extends StatelessWidget {
  const SafetyBlockBanner({
    super.key,
    required this.activeFlags,
    this.onClearRouteTap,
  });

  final List<BlockFlag> activeFlags;
  final void Function(ClearRoute route, String flagId)? onClearRouteTap;

  @override
  Widget build(BuildContext context) {
    if (activeFlags.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayFlags = activeFlags.take(2).toList();
    final remainingCount = activeFlags.length - displayFlags.length;

    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final flag in displayFlags) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red.shade800, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${flag.label} · ${flag.clearInstruction}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (flag.clearRoute == ClearRoute.wizardOnly && onClearRouteTap != null)
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 16),
                      onPressed: () => onClearRouteTap!(flag.clearRoute, flag.flagId),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ],
          if (remainingCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '+$remainingCount',
                style: TextStyle(fontSize: 11, color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
}
