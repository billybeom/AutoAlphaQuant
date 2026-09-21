// packages/ui_analytics/lib/src/widgets/trust_badge_view.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';

import '../../l10n/labels.dart';

class TrustBadgeView extends StatelessWidget {
  const TrustBadgeView({super.key, required this.trust, this.onOpenLink});

  final LedgerTrustBadge trust;
  final void Function(String link)? onOpenLink;

  Color _levelColor(BuildContext context, UiLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (level) {
      UiLevel.ok => isDark ? Colors.green.shade300 : Colors.green.shade700,
      UiLevel.info => isDark ? Colors.blue.shade300 : Colors.blue.shade700,
      UiLevel.watch => isDark ? Colors.orange.shade300 : Colors.orange.shade800,
      UiLevel.act =>
        isDark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade800,
      UiLevel.blocked => isDark ? Colors.red.shade300 : Colors.red.shade800,
    };
  }

  Color _levelBackgroundColor(BuildContext context, UiLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (level) {
      UiLevel.ok => isDark ? const Color(0x331B5E20) : Colors.green.shade50,
      UiLevel.info => isDark ? const Color(0x330D47A1) : Colors.blue.shade50,
      UiLevel.watch => isDark ? const Color(0x33E65100) : Colors.orange.shade50,
      UiLevel.act =>
        isDark ? const Color(0x33BF360C) : Colors.deepOrange.shade50,
      UiLevel.blocked => isDark ? const Color(0x33B71C1C) : Colors.red.shade50,
    };
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _levelColor(context, trust.level);
    final bgColor = _levelBackgroundColor(context, trust.level);

    return Container(
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
          Text(
            trust.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          if (trust.consequenceLine.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                trust.consequenceLine,
                style: TextStyle(fontSize: 11, color: borderColor),
              ),
            ),
          if (trust.upgradeHint != null && trust.upgradeHint!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                trust.upgradeHint!,
                style: TextStyle(fontSize: 11, color: borderColor),
              ),
            ),
          if (trust.actionDeepLink != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => onOpenLink?.call(trust.actionDeepLink!),
                child: Text(
                  AnalyticsLabels.actionViewButton,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
