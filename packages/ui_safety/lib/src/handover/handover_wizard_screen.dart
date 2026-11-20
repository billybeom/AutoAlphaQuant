// 🆕 E11q-c1 — M5-11 simToAuto 위저드 한 화면(`AppRoutes.m5HandoverWizard` · `handoverStatus` 같은 본문 — K173 ·
//    설계 13 §8 R191 · 01 §35 K167~K176 · 표본 `m5/handover_wizard_*`).
//
// 🔴 머리 · 경로 · 고지 · 잠김 · 확정됨 · 시각 글자 3 · 체험 카드 · 단계 제목 · 왜 · 상태 · 링크 · 버튼 글자 = 엔진 VM 그대로
//    (받은 차례 · 카운트다운 0 — 시각이 지나면 엔진이 새 VM) · 색 · 아이콘 = `UiLevel` 하나(`step.state` 미참조 — UNKNOWN ≠ 빨강 · K172).
// 🔴 `reasonCode` · `blockedReasonCode` · 세션 id 를 읽지도 그리지도 않는다(분기 0).
// 🔴 동작 = 행의 `actions` 그대로 `SettingsActions.run(id, args)` 1회(화면이 args 를 짓지 않는다 · K169) · 도는 동안 모든 버튼 비활성 ·
//    결과 = 엔진 `headline` 원문 · `handoffRoute` 가 오면 그대로 연다(K175) · 제출 자체 실패 = 정적 문장 · 확인 대화 0.
// 🔴 쓰기 주입 null(뷰어) · 잠김 · 확정됨 = 버튼 부재(엔진이 비워 주는 것에 더한 이중 방어 · c0 꼴) · 링크는 그대로.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;

/// M5-11 위저드 읽기 창구(조립 앱이 주입 · 🔴 throw 기본값).
final Provider<HandoverRepository> safetyHandoverRepositoryProvider =
    Provider<HandoverRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyHandoverRepositoryProvider must be overridden',
      ),
    );

/// M5-11 위저드 동작 창구(폰 로컬 · 조립 앱이 주입) — null = 뷰어 · 쓰기 경로 없음 → 버튼 부재(05 §5-2).
final Provider<SettingsActions?> safetySettingsActionsProvider =
    Provider<SettingsActions?>((Ref ref) => null);

final AutoDisposeStreamProvider<HandoverWizardVm> _wizardProvider =
    StreamProvider.autoDispose<HandoverWizardVm>(
      (Ref ref) => ref.watch(safetyHandoverRepositoryProvider).watchWizard(),
    );

/// M5-11 simToAuto 위저드 한 화면(`handoverStatus` 같은 본문).
class HandoverWizardScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const HandoverWizardScreen({super.key});

  @override
  ConsumerState<HandoverWizardScreen> createState() =>
      _HandoverWizardScreenState();
}

class _HandoverWizardScreenState extends ConsumerState<HandoverWizardScreen> {
  /// 마지막 결과가 있는가(제출 자체 실패 = 있음 + [_result] null).
  bool _hasResult = false;
  ActionResult? _result;
  bool _busy = false;

  Future<void> _run(SettingsActionCall call) async {
    final SettingsActions? actions = ref.read(safetySettingsActionsProvider);
    if (actions == null || _busy) return;
    setState(() => _busy = true);
    ActionResult? r;
    try {
      r = await actions.run(call.id, args: call.args);
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _hasResult = true;
      _result = r;
    });
    final String? route = r?.handoffRoute;
    if (route != null) ref.read(safetyLinkOpenerProvider).open(route);
  }

  Widget _line(String? text, String key, {TextStyle? style}) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(text, key: Key(key), style: style),
        );

  Widget _resultLine() {
    if (!_hasResult) return const SizedBox.shrink();
    final ActionResult? r = _result;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: r == null
          ? const Text(
              SafetyLabels.submitNotAccepted,
              key: Key('m511-result-failed'),
            )
          : Text(r.headline, key: const Key('m511-result')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<HandoverWizardVm> data = ref.watch(_wizardProvider);
    final HandoverWizardVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.handoverWizardReadFailed,
                key: Key('m511-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('m511-loading')),
            );
    }
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final bool canRun =
        ref.watch(safetySettingsActionsProvider) != null &&
        vm.lockedLabel == null &&
        vm.doneLabel == null;
    final SimTrialCard? trial = vm.trial;
    return ListView(
      key: const Key('m511-root'),
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
                key: const Key('m511-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        _line(vm.pathLabel, 'm511-path', style: theme.textTheme.bodySmall),
        _resultLine(),
        _line(vm.noticeText, 'm511-notice'),
        _line(vm.lockedLabel, 'm511-locked'),
        _line(vm.doneLabel, 'm511-done'),
        _line(vm.coolingText, 'm511-cooling'),
        _line(vm.deadlineText, 'm511-deadline'),
        _line(vm.windowText, 'm511-window'),
        if (trial != null) _TrialCard(trial: trial),
        for (final (int i, HandoverWizardStepRow r) in vm.rows.indexed)
          _StepRow(
            index: i,
            row: r,
            canRun: canRun,
            busy: _busy,
            onRun: _run,
            onLink: (String link) =>
                ref.read(safetyLinkOpenerProvider).open(link),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m511-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// S1 상세(체험 항목 · 엔진 차례 · Key = 순번).
class _TrialCard extends StatelessWidget {
  const _TrialCard({required this.trial});

  final SimTrialCard trial;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      key: const Key('m511-trial'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(trial.headline, style: theme.textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(trial.summaryText, style: theme.textTheme.bodySmall),
            ),
            for (final (int i, SimTrialCheck c) in trial.checks.indexed)
              _CheckLine(index: i, check: c),
          ],
        ),
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.index, required this.check});

  final int index;
  final SimTrialCheck check;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      check.level,
    );
    return Padding(
      key: Key('m511-check-$index'),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Icon(icon, color: tone, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(check.label),
                Text(check.stateLabel, style: theme.textTheme.labelLarge),
                Text(check.detailText, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 단계 한 행(엔진 차례 · Key = 순번).
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.row,
    required this.canRun,
    required this.busy,
    required this.onRun,
    required this.onLink,
  });

  final int index;
  final HandoverWizardStepRow row;
  final bool canRun;
  final bool busy;
  final void Function(SettingsActionCall call) onRun;
  final void Function(String link) onLink;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      row.level,
    );
    final HandoverStep step = row.step;
    final LinkAction? link = row.link;
    return Card(
      key: Key('m511-step-$index'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  child: Text(step.title, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(step.stateLabel),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(step.whyLine, style: theme.textTheme.bodySmall),
            ),
            if (link != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  key: Key('m511-link-$index'),
                  onPressed: () => onLink(link.deepLink),
                  child: Text(link.label),
                ),
              ),
            if (canRun && row.actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final (int j, SettingsActionCall a)
                        in row.actions.indexed)
                      OutlinedButton(
                        key: Key('m511-act-$index-$j'),
                        onPressed: busy ? null : () => onRun(a),
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
