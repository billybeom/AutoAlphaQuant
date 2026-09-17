// packages/ui_analytics/lib/src/screens/monthly_report_screen.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/labels.dart';
import '../providers/analytics_providers.dart';
import '../widgets/safety_block_banner.dart';
import '../widgets/stale_banner.dart';
import '../widgets/trust_badge_view.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({
    super.key,
    required this.yyyyMm,
    this.onOpenArchive,
    this.onOpenGoalPath,
    this.onOpenExecutionGap,
    this.onOpenDrawdownDetail,
    this.onOpenContributionDetail,
    this.onOpenSafetyRoute,
  });

  final String yyyyMm;
  final VoidCallback? onOpenArchive;
  final VoidCallback? onOpenGoalPath;
  final VoidCallback? onOpenExecutionGap;
  final VoidCallback? onOpenDrawdownDetail;
  final VoidCallback? onOpenContributionDetail;
  final void Function(ClearRoute route, String flagId)? onOpenSafetyRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider(yyyyMm));
    final safetyAsync = ref.watch(safetyStateStreamProvider);

    final activeFlags = safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];
    final isLedgerIntegrityBlocked = activeFlags.any((f) => f.flagId == FlagIds.ledgerIntegrity);
    final isReconMismatchBlocked = activeFlags.any((f) => f.flagId == FlagIds.reconMismatch);

    return Scaffold(
      appBar: AppBar(
        title: Text(yyyyMm),
        actions: [
          if (onOpenArchive != null)
            TextButton(
              onPressed: onOpenArchive,
              child: const Text(AnalyticsLabels.reportArchiveButton),
            ),
        ],
      ),
      body: SafeArea(
        child: reportAsync.when(
          loading: () => _buildSkeletonLoader(),
          error: (err, stack) => _buildErrorState(ref),
          data: (report) => _buildContent(
            context,
            report,
            activeFlags,
            isLedgerIntegrityBlocked: isLedgerIntegrityBlocked,
            isReconMismatchBlocked: isReconMismatchBlocked,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 7,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 36, color: Colors.grey),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.refresh(monthlyReportProvider(yyyyMm)),
            child: const Text(AnalyticsLabels.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MonthlyReport report,
    List<BlockFlag> activeFlags, {
    required bool isLedgerIntegrityBlocked,
    required bool isReconMismatchBlocked,
  }) {
    return Column(
      children: [
        StaleBanner(asOf: report.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onClearRouteTap: onOpenSafetyRoute,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(context, report),
              const SizedBox(height: 16),
              ..._buildReportItems(
                report.items,
                isLedgerIntegrityBlocked: isLedgerIntegrityBlocked,
                isReconMismatchBlocked: isReconMismatchBlocked,
              ),
              const SizedBox(height: 20),
              _buildFooter(context, report),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, MonthlyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.yyyyMm,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.asOf.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            TrustBadgeView(trust: report.trust),
          ],
        ),
        if (report.backdateFootnote != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              report.backdateFootnote!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildReportItems(
    List<ReportItem> items, {
    required bool isLedgerIntegrityBlocked,
    required bool isReconMismatchBlocked,
  }) {
    // 03 §3: 13항목 고정 배열을 전달받은 순서대로 렌더링
    return items.map((item) {
      final displayValue = _resolveDisplayValue(
        item.valueText,
        isLedgerIntegrityBlocked: isLedgerIntegrityBlocked,
        isReconMismatchBlocked: isReconMismatchBlocked,
      );

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.noteText != null && item.noteText!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              item.noteText!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              if (_hasItemDetailAction(item.order))
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _handleItemDetailTap(item.order),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(AnalyticsLabels.detailsButton),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _resolveDisplayValue(
    String originalValueText, {
    required bool isLedgerIntegrityBlocked,
    required bool isReconMismatchBlocked,
  }) {
    if (isLedgerIntegrityBlocked) {
      return AnalyticsLabels.maskedIntegrity;
    }
    if (isReconMismatchBlocked) {
      return AnalyticsLabels.maskedReconMismatch;
    }
    return originalValueText;
  }

  bool _hasItemDetailAction(int order) {
    // 03 §3: ⑤ 드로다운(S7-3), 슬리브 기여(S7-3b), ⑧ 이탈률/이행갭(S7-10)에 상세 진입 버튼 제공
    return order == 5 || order == 8;
  }

  void _handleItemDetailTap(int order) {
    if (order == 5 && onOpenDrawdownDetail != null) {
      onOpenDrawdownDetail!();
    } else if (order == 8 && onOpenExecutionGap != null) {
      onOpenExecutionGap!();
    }
  }

  Widget _buildFooter(BuildContext context, MonthlyReport report) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 목표 금액 경로 1줄 (03 §3, §14)
          Row(
            children: [
              Expanded(
                child: Text(
                  report.goalLine,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              if (onOpenGoalPath != null)
                TextButton(
                  onPressed: onOpenGoalPath,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(AnalyticsLabels.detailsButton),
                ),
            ],
          ),
          const Divider(height: 16),
          // 이번 달 탐색 열람 횟수 고지
          Text(
            report.disclosureViewCountText,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            report.asOf.label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
