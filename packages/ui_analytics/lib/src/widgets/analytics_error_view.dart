// packages/ui_analytics/lib/src/widgets/analytics_error_view.dart

import 'package:flutter/material.dart';

import '../../l10n/labels.dart';

/// 에러 상태 뷰 — (있으면) 마지막 성공 asOf 라벨 → 에러 아이콘 → 재시도 버튼.
/// 🔴 R10b·R10c 가 이 모양으로 부른다 — 생성자 모양을 바꾸지 않는다.
class AnalyticsErrorView extends StatelessWidget {
  const AnalyticsErrorView({
    super.key,
    required this.onRetry,
    this.lastAsOfLabel,
  });

  final VoidCallback onRetry;
  final String? lastAsOfLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (lastAsOfLabel != null) ...<Widget>[
            Text(
              lastAsOfLabel!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Icon(
            Icons.error_outline,
            size: 36,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text(AnalyticsLabels.retryButton),
          ),
        ],
      ),
    );
  }
}
