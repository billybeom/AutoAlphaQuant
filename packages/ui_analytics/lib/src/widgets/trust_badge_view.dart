// packages/ui_analytics/lib/src/widgets/trust_badge_view.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

class TrustBadgeView extends StatelessWidget {
  const TrustBadgeView({
    super.key,
    required this.trust,
    this.onTap,
  });

  final LedgerTrustBadge trust;
  final VoidCallback? onTap;

  Color _levelColor(UiLevel level) {
    return switch (level) {
      UiLevel.ok => Colors.green.shade700,
      UiLevel.info => Colors.blue.shade700,
      UiLevel.watch => Colors.orange.shade800,
      UiLevel.act => Colors.deepOrange.shade800,
      UiLevel.blocked => Colors.red.shade800,
    };
  }

  Color _levelBackgroundColor(UiLevel level) {
    return switch (level) {
      UiLevel.ok => Colors.green.shade50,
      UiLevel.info => Colors.blue.shade50,
      UiLevel.watch => Colors.orange.shade50,
      UiLevel.act => Colors.deepOrange.shade50,
      UiLevel.blocked => Colors.red.shade50,
    };
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _levelColor(trust.level);
    final bgColor = _levelBackgroundColor(trust.level);

    return InkWell(
      onTap: trust.actionDeepLink != null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.0),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trust.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
                if (trust.actionDeepLink != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 14, color: borderColor),
                ],
              ],
            ),
            if (trust.consequenceLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  trust.consequenceLine,
                  style: TextStyle(fontSize: 11, color: borderColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
