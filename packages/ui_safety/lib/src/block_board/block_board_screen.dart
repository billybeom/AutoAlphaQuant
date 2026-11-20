// 🆕 E11q-b3 — M5-5 차단 보드(설계 13 §8 R185 · 01 §34 K154 · K155 · 06 M5-5 · 표본 `m5/block_board_*`).
//
// 🔴 머리 · 행 · 게이지 · 사다리 · 링크 = 엔진 VM 그대로(받은 차례 · 재정렬 · 재분류 0 · 화면이 flagId 로 글자나 목적지를 고르지 않는다).
// 🔴 해제 버튼 0 · 카운트다운 0(게이지 = `valueText` 표시 · `normalized` = 폭만) · 행 링크 = 엔진이 준 것만.
// 🔴 킬스위치 진입 = 늘(VM `killSwitchLink` · 보드가 긴급 진입점 둘째 길) — 읽기 실패에도 같은 화면으로 가는 길 하나는 남긴다.
// 🔴 사다리 지금 단 = 색 + «지금 단계» 글자(색만으로 말하지 않는다).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;

/// M5-5 읽기 창구(조립 앱이 주입).
final Provider<BlockBoardRepository> safetyBlockBoardRepositoryProvider =
    Provider<BlockBoardRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyBlockBoardRepositoryProvider must be overridden',
      ),
    );

final AutoDisposeStreamProvider<BlockBoardVm> _boardProvider =
    StreamProvider.autoDispose<BlockBoardVm>(
      (Ref ref) => ref.watch(safetyBlockBoardRepositoryProvider).watchBoard(),
    );

/// M5-5 차단 보드 한 화면.
class BlockBoardScreen extends ConsumerWidget {
  /// 만든다.
  const BlockBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BlockBoardVm> data = ref.watch(_boardProvider);
    final BlockBoardVm? vm = data.valueOrNull;
    void open(String link) => ref.read(safetyLinkOpenerProvider).open(link);
    if (vm == null) {
      if (!data.hasError) {
        return const Center(
          child: CircularProgressIndicator(key: Key('m55-loading')),
        );
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              SafetyLabels.blockBoardReadFailed,
              key: Key('m55-read-failed'),
            ),
            TextButton(
              key: const Key('m55-kill-fallback'),
              onPressed: () => open(AppRoutes.m5KillSwitch),
              child: const Text(SafetyLabels.blockBoardKillFallback),
            ),
          ],
        ),
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final (IconData icon, Color tone) = safetyLevelLook(cs, vm.level);
    return ListView(
      key: const Key('m55-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
              child: Icon(icon, color: tone),
            ),
            Expanded(
              child: Text(
                vm.headline,
                key: const Key('m55-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              key: const Key('m55-kill'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error),
              ),
              onPressed: () => open(vm.killSwitchLink.deepLink),
              icon: const Icon(Icons.power_settings_new),
              label: Text(vm.killSwitchLink.label),
            ),
          ),
        ),
        if (vm.emptyLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(vm.emptyLabel!, key: const Key('m55-empty')),
          ),
        for (final BlockBoardRow r in vm.rows) _RowCard(row: r, onOpen: open),
        if (vm.gauges.isNotEmpty) ...<Widget>[
          _Section(SafetyLabels.blockBoardGauges),
          for (final GaugeProgress g in vm.gauges) _Gauge(gauge: g),
        ],
        if (vm.stoppedDecisionLink != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonal(
                key: const Key('m55-stopped'),
                onPressed: () => open(vm.stoppedDecisionLink!.deepLink),
                child: Text(vm.stoppedDecisionLink!.label),
              ),
            ),
          ),
        _Section(
          SafetyLabels.blockBoardLadder,
          trailing: Text(
            vm.breakerLabel,
            key: const Key('m55-breaker'),
            style: theme.textTheme.labelLarge,
          ),
        ),
        for (final BreakerLadderRow s in vm.ladder.rows) _LadderStep(step: s),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m55-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 4),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.row, required this.onOpen});

  final BlockBoardRow row;
  final void Function(String link) onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      row.level,
    );
    return Card(
      key: Key('m55-row-${row.rowId}'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(icon, color: tone, size: 20),
                ),
                Expanded(
                  child: Text(row.label, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            if (row.setAtText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(row.setAtText!, style: theme.textTheme.bodySmall),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                row.clearKindLabel,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Text(row.clearInstruction),
            ),
            if (row.link != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: Key('m55-row-link-${row.rowId}'),
                  onPressed: () => onOpen(row.link!.deepLink),
                  child: Text(row.link!.label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.gauge});

  final GaugeProgress gauge;

  @override
  Widget build(BuildContext context) => Padding(
    key: Key('m55-gauge-${gauge.code}'),
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(gauge.label)),
            Text(gauge.valueText),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: LinearProgressIndicator(
            value: gauge.normalized.clamp(0.0, 1.0),
          ),
        ),
      ],
    ),
  );
}

class _LadderStep extends StatelessWidget {
  const _LadderStep({required this.step});

  final BreakerLadderRow step;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    Widget line(String name, String value) => Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$name  ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
    return Semantics(
      selected: step.current,
      child: Container(
        key: Key('m55-ladder-${step.level.wire}'),
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: step.current ? cs.secondaryContainer : null,
          border: Border.all(
            color: step.current ? cs.secondary : cs.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(step.label, style: theme.textTheme.titleSmall),
                ),
                if (step.current)
                  Text(
                    SafetyLabels.blockBoardLadderNow,
                    key: const Key('m55-ladder-now'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSecondaryContainer,
                    ),
                  ),
              ],
            ),
            line(SafetyLabels.blockBoardLadderTrigger, step.triggerText),
            line(SafetyLabels.blockBoardLadderRelease, step.releaseText),
            line(SafetyLabels.blockBoardLadderAction, step.actionText),
          ],
        ),
      ),
    );
  }
}
