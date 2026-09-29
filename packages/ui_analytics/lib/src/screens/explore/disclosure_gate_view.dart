// lib/src/screens/explore/disclosure_gate_view.dart
// S7-2G 열람 게이트 본문 — 내부 위젯 (PerformanceExploreScreen 에서만 쓴다)

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/labels.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/analytics_error_view.dart';
import '../../widgets/analytics_skeleton.dart';
import '../../widgets/safety_block_banner.dart';
import '../../widgets/stale_banner.dart';

/// S7-2G 열람 게이트 본문.
///
/// [onContinue] — 「그래도 보기」 탭 콜백 · [submitting] — 제출 중 플래그 ·
/// [notAccepted] — 접수 실패 플래그.
class DisclosureGateView extends ConsumerWidget {
  const DisclosureGateView({
    super.key,
    required this.onContinue,
    required this.submitting,
    required this.notAccepted,
  });

  final VoidCallback onContinue;
  final bool submitting;
  final bool notAccepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateAsync = ref.watch(disclosureGateProvider);
    final safetyAsync = ref.watch(safetyStateStreamProvider);
    final activeFlags =
        safetyAsync.valueOrNull?.activeFlags ?? const <BlockFlag>[];

    return gateAsync.when(
      loading: () => _buildLoadingLayout(context, ref),
      error: (_, __) =>
          _buildErrorLayout(context, ref, gateAsync.valueOrNull?.asOf.label),
      data: (vm) => _buildDataLayout(context, ref, vm, activeFlags),
    );
  }

  // ── 로딩 ─────────────────────────────────────────────────────────────────

  Widget _buildLoadingLayout(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const AnalyticsSkeleton(blocks: 2),
              const SizedBox(height: 12),
              _buildBackButton(context, ref, fullWidth: true),
            ],
          ),
        ),
      ],
    );
  }

  // ── 에러 ─────────────────────────────────────────────────────────────────

  Widget _buildErrorLayout(
    BuildContext context,
    WidgetRef ref,
    String? lastAsOfLabel,
  ) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AnalyticsErrorView(
                onRetry: () => ref.invalidate(disclosureGateProvider),
                lastAsOfLabel: lastAsOfLabel,
              ),
              const SizedBox(height: 12),
              _buildBackButton(context, ref, fullWidth: true),
            ],
          ),
        ),
      ],
    );
  }

  // ── 데이터 ────────────────────────────────────────────────────────────────

  Widget _buildDataLayout(
    BuildContext context,
    WidgetRef ref,
    DisclosureGateVm vm,
    List<BlockFlag> activeFlags,
  ) {
    return Column(
      children: <Widget>[
        StaleBanner(asOf: vm.asOf),
        SafetyBlockBanner(
          activeFlags: activeFlags,
          onOpenLink: (link) {
            ref.read(analyticsLinkOpenerProvider).open(link);
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _buildCard(context, vm),
              if (notAccepted) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  AnalyticsLabels.recordNotAccepted,
                  key: const Key('s72g-record-not-accepted'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildButtonRow(context, ref, vm),
            ],
          ),
        ),
      ],
    );
  }

  // ── 카드 ─────────────────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context, DisclosureGateVm vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('s72g-card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              vm.headline,
              key: const Key('s72g-headline'),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vm.viewCountText,
              key: const Key('s72g-count'),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (vm.frictionLine != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                vm.frictionLine!,
                key: const Key('s72g-friction'),
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              vm.asOf.label,
              key: const Key('s72g-asof'),
              style: TextStyle(fontSize: 11, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  // ── 버튼 줄 ───────────────────────────────────────────────────────────────

  Widget _buildButtonRow(
    BuildContext context,
    WidgetRef ref,
    DisclosureGateVm vm,
  ) {
    if (!vm.gateOpen) {
      // 닫힌 게이트: 「돌아가기」 하나가 줄 전체 폭
      return _buildBackButton(context, ref, fullWidth: true);
    }

    return Row(
      children: <Widget>[
        Expanded(child: _buildBackButton(context, ref, fullWidth: false)),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            key: const Key('s72g-continue'),
            onPressed: submitting ? null : onContinue,
            child: Text(AnalyticsLabels.gateContinueButton),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    WidgetRef ref, {
    required bool fullWidth,
  }) {
    final button = FilledButton(
      key: const Key('s72g-back'),
      onPressed: () {
        ref.read(analyticsLinkOpenerProvider).open(AppNavActions.back);
      },
      child: Text(AnalyticsLabels.gateBackButton),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
