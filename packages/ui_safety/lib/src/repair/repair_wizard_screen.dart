// 🆕 E16j-a — X5 정정 마법사(허브 · 대상) 한 화면(설계 13 §8 R227 · 01 §41 K247~K263 · 06 X5-3 · 표본 `x5/repair_*`).
//
// 🔴 머리 · 줄 · 링크 · 근거 행 · 원인 칩 · 단계 · 후보 · 버튼 글자 = 엔진 VM 그대로(받은 차례 · 화면이 단계 · 시각 · 원인을 짓지 않는다).
// 🔴 동작 = 엔진이 준 것만 — 단계 버튼 = `run(id, args)` 그대로 · 아무것도 안 하기 = `doNothingAction` 그대로 ·
//    저널 세 칸 = `runInterventionJournal` · 정정 = `runRepairCorrect`(원문 네 칸 그대로 · 화면 검증 0) · 새 기준점 = `runRepairBaseline`.
//    쓰기 주입 null(뷰어) = 컨트롤 부재 · 확인 대화 0 · 결과 = 엔진 `headline` + `reasonCode` 원문(머리 아래 · 맨 위로 스크롤) ·
//    제출 자체 실패 = 정적 문장(접수증 아님).
// 🔴 `doNothingDefault` = 처음 고른 칸(아무것도 안 하기 버튼을 채운 버튼으로)만 정한다 — 글자를 고르지 않는다.
// 🔴 원인 = 실행 칸(고르기 전 = 정정 · 새 기준점 확인 꺼짐) · 체결 후보 = 받은 차례 · `fillRef` = 제출 · 고른 칸 기억에만(해석 0 —
//    VM 이 다시 와 차례가 바뀌어도 고른 체결이 바뀌지 않게 · 사라지면 고름 풀림).
// 🔴 대상 id = 라우트 인자 그대로(엔진이 완성한 링크) — 화면은 해석하지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// X5 정정 마법사 읽기 창구(조립 앱이 주입 · 폰 전용).
final Provider<RepairWizardRepository> safetyRepairWizardRepositoryProvider =
    Provider<RepairWizardRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyRepairWizardRepositoryProvider must be overridden',
      ),
    );

final AutoDisposeStreamProviderFamily<RepairWizardVm, String?> _repairProvider =
    StreamProvider.autoDispose.family<RepairWizardVm, String?>(
      (Ref ref, String? targetId) => ref
          .watch(safetyRepairWizardRepositoryProvider)
          .watchRepair(targetId: targetId),
    );

/// X5 정정 마법사 한 화면 — [targetId] null = 허브 · 값 = 대상 화면.
class RepairWizardScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const RepairWizardScreen({super.key, this.targetId});

  /// 대상 id(라우트 인자 그대로 · 허브 = null).
  final String? targetId;

  @override
  ConsumerState<RepairWizardScreen> createState() => _RepairWizardScreenState();
}

class _RepairWizardScreenState extends ConsumerState<RepairWizardScreen> {
  final ScrollController _scroll = ScrollController();
  bool _busy = false;
  bool _hasResult = false;
  SafetyActionResult? _result;
  String? _origin;
  String? _fillRef;
  bool _void = false;
  final TextEditingController _rationale = TextEditingController();
  final TextEditingController _expected = TextEditingController();
  final TextEditingController _rule = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _commission = TextEditingController();
  final TextEditingController _tax = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    for (final TextEditingController c in <TextEditingController>[
      _rationale,
      _expected,
      _rule,
      _quantity,
      _price,
      _commission,
      _tax,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(
    SafetyActions actions,
    Future<SafetyActionResult> Function(SafetyActions a) call,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    SafetyActionResult? r;
    try {
      r = await call(actions);
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _hasResult = true;
      _result = r;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _open(String link) => ref.read(safetyLinkOpenerProvider).open(link);

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _field(TextEditingController c, String label, String key) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: TextField(
      key: Key(key),
      controller: c,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _resultLine() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: _result == null
        ? const Text(
            SafetyLabels.submitNotAccepted,
            key: Key('x5-result-failed'),
          )
        : Text(
            _result!.reasonCode == null
                ? _result!.headline
                : '${_result!.headline} (${_result!.reasonCode})',
            key: const Key('x5-result'),
          ),
  );

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepairWizardVm> data = ref.watch(
      _repairProvider(widget.targetId),
    );
    final RepairWizardVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.repairReadFailed,
                key: Key('x5-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('x5-loading')),
            );
    }
    final SafetyActions? actions = ref.watch(safetyActionsProvider);
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final String? origin =
        vm.origins.any((RepairOriginChoice o) => o.originCode == _origin)
        ? _origin
        : null;
    return ListView(
      key: const Key('x5-root'),
      controller: _scroll,
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
                key: const Key('x5-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (_hasResult) _resultLine(),
        if (vm.lockedLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.lockedLabel!, key: const Key('x5-locked')),
          ),
        if (vm.doneLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.doneLabel!, key: const Key('x5-done')),
          ),
        for (int i = 0; i < vm.targetLines.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(vm.targetLines[i], key: Key('x5-line-$i')),
          ),
        for (int i = 0; i < vm.targetLinks.length; i++)
          Card(
            key: Key('x5-target-$i'),
            margin: const EdgeInsets.only(top: 12),
            child: ListTile(
              title: Text(vm.targetLinks[i].label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(vm.targetLinks[i].deepLink),
            ),
          ),
        if (vm.x1GuideLink != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonal(
                key: const Key('x5-x1-guide'),
                onPressed: () => _open(vm.x1GuideLink!.deepLink),
                child: Text(vm.x1GuideLink!.label),
              ),
            ),
          ),
        if (vm.diff != null) ...<Widget>[
          _section(context, SafetyLabels.repairDiff),
          _DiffCard(row: vm.diff!),
        ],
        if (vm.noticeText != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              vm.noticeText!,
              key: const Key('x5-notice'),
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (actions != null && vm.doNothingAction != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: vm.doNothingDefault
                  ? FilledButton(
                      key: const Key('x5-do-nothing'),
                      onPressed: _busy
                          ? null
                          : () => _run(
                              actions,
                              (SafetyActions a) => a.run(
                                vm.doNothingAction!.id,
                                args: vm.doNothingAction!.args,
                              ),
                            ),
                      child: Text(vm.doNothingAction!.label),
                    )
                  : OutlinedButton(
                      key: const Key('x5-do-nothing'),
                      onPressed: _busy
                          ? null
                          : () => _run(
                              actions,
                              (SafetyActions a) => a.run(
                                vm.doNothingAction!.id,
                                args: vm.doNothingAction!.args,
                              ),
                            ),
                      child: Text(vm.doNothingAction!.label),
                    ),
            ),
          ),
        if (vm.stages.isNotEmpty) ...<Widget>[
          _section(context, SafetyLabels.repairStages),
          for (int k = 0; k < vm.stages.length; k++)
            _StageRow(
              index: k,
              row: vm.stages[k],
              canRun: actions != null,
              busy: _busy,
              onRun: (SafetyActionCall c) => _run(
                actions!,
                (SafetyActions a) => a.run(c.id, args: c.args),
              ),
              journal: actions != null && vm.stages[k].journalForm
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _field(
                          _rationale,
                          SafetyLabels.repairJournalRationale,
                          'x5-journal-rationale',
                        ),
                        _field(
                          _expected,
                          SafetyLabels.repairJournalExpected,
                          'x5-journal-expected',
                        ),
                        _field(
                          _rule,
                          SafetyLabels.repairJournalRuleCited,
                          'x5-journal-rule',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: FilledButton(
                            key: const Key('x5-journal-submit'),
                            onPressed: _busy
                                ? null
                                : () => _run(
                                    actions,
                                    (SafetyActions a) =>
                                        a.runInterventionJournal(
                                          InterventionJournalSubmission(
                                            rationaleBefore: _rationale.text,
                                            expectedOutcome: _expected.text,
                                            ruleCited: _rule.text,
                                          ),
                                        ),
                                  ),
                            child: const Text(SafetyLabels.repairJournalSubmit),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
        ],
        if (actions != null && vm.origins.isNotEmpty) ...<Widget>[
          _section(context, SafetyLabels.repairOrigin),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (int i = 0; i < vm.origins.length; i++)
                ChoiceChip(
                  key: Key('x5-origin-$i'),
                  label: Text(vm.origins[i].label),
                  selected: origin == vm.origins[i].originCode,
                  onSelected: (bool on) => setState(
                    () => _origin = on ? vm.origins[i].originCode : null,
                  ),
                ),
            ],
          ),
        ],
        if (actions != null && vm.correction != null)
          _correction(context, actions, vm, vm.correction!, origin),
        if (actions != null && vm.baselineLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                key: const Key('x5-baseline-submit'),
                onPressed: _busy || origin == null || widget.targetId == null
                    ? null
                    : () => _run(
                        actions,
                        (SafetyActions a) => a.runRepairBaseline(
                          RepairBaselineSubmission(
                            targetId: widget.targetId!,
                            originCode: origin,
                          ),
                        ),
                      ),
                child: Text(vm.baselineLabel!),
              ),
            ),
          ),
        if (vm.historyLink != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('x5-history'),
                onPressed: () => _open(vm.historyLink!.deepLink),
                child: Text(vm.historyLink!.label),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('x5-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _correction(
    BuildContext context,
    SafetyActions actions,
    RepairWizardVm vm,
    RepairCorrectionForm form,
    String? origin,
  ) {
    final ThemeData theme = Theme.of(context);
    final int fill = _fillRef == null
        ? -1
        : form.fills.indexWhere((RepairFillChoice f) => f.fillRef == _fillRef);
    final int? chosen = fill < 0 ? null : fill;
    final bool voidFill = !form.amendAllowed || _void;
    final String? target = widget.targetId ?? vm.diff?.diffId;
    return Column(
      key: const Key('x5-correction'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _section(context, SafetyLabels.repairCorrection),
        if (form.noticeText != null)
          Text(
            form.noticeText!,
            key: const Key('x5-correction-notice'),
            style: theme.textTheme.bodySmall,
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            SafetyLabels.repairFill,
            style: theme.textTheme.labelLarge,
          ),
        ),
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (int i = 0; i < form.fills.length; i++)
              ChoiceChip(
                key: Key('x5-fill-$i'),
                label: Text(form.fills[i].label),
                selected: chosen == i,
                onSelected: (bool on) => setState(
                  () => _fillRef = on ? form.fills[i].fillRef : null,
                ),
              ),
          ],
        ),
        if (form.amendAllowed)
          SwitchListTile(
            key: const Key('x5-void'),
            contentPadding: EdgeInsets.zero,
            title: const Text(SafetyLabels.repairVoid),
            value: _void,
            onChanged: (bool on) => setState(() => _void = on),
          ),
        if (!voidFill) ...<Widget>[
          _field(_quantity, SafetyLabels.repairQuantity, 'x5-quantity'),
          _field(_price, SafetyLabels.repairPrice, 'x5-price'),
          _field(_commission, SafetyLabels.repairCommission, 'x5-commission'),
          _field(_tax, SafetyLabels.repairTax, 'x5-tax'),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: FilledButton(
            key: const Key('x5-correct-submit'),
            onPressed:
                _busy || origin == null || chosen == null || target == null
                ? null
                : () => _run(
                    actions,
                    (SafetyActions a) => a.runRepairCorrect(
                      RepairCorrectSubmission(
                        targetId: target,
                        fillRef: form.fills[chosen].fillRef,
                        originCode: origin,
                        voidFill: voidFill,
                        quantityText: voidFill ? null : _quantity.text,
                        priceText: voidFill ? null : _price.text,
                        commissionText: voidFill ? null : _commission.text,
                        taxText: voidFill ? null : _tax.text,
                      ),
                    ),
                  ),
            child: const Text(SafetyLabels.repairCorrectSubmit),
          ),
        ),
      ],
    );
  }
}

class _DiffCard extends StatelessWidget {
  const _DiffCard({required this.row});

  final LedgerDiffRow row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      key: const Key('x5-diff'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${row.pairLabel} · ${row.axisLabel}',
              style: theme.textTheme.labelLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(row.deltaLabel, style: theme.textTheme.titleSmall),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${row.severityLabel} · ${row.statusLabel} · ${row.routeLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(row.detectedAtText, style: theme.textTheme.bodySmall),
            if (row.candidateOrigins.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final ReasonChip c in row.candidateOrigins)
                      Chip(
                        label: Text(c.label),
                        visualDensity: VisualDensity.compact,
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

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.index,
    required this.row,
    required this.canRun,
    required this.busy,
    required this.onRun,
    this.journal,
  });

  final int index;
  final RepairStageRow row;
  final bool canRun;
  final bool busy;
  final void Function(SafetyActionCall c) onRun;

  /// 3단계 저널 폼(쓰기 창구 ∧ `journalForm`).
  final Widget? journal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final (IconData icon, Color tone) = safetyLevelLook(cs, row.level);
    return Container(
      key: Key('x5-stage-$index'),
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Icon(icon, color: tone, size: 18),
              ),
              Expanded(
                child: Text(row.title, style: theme.textTheme.titleSmall),
              ),
              Text(
                row.stateLabel,
                key: Key('x5-stage-$index-state'),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          for (final String l in row.lines)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(l)),
          if (canRun && row.actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  for (int i = 0; i < row.actions.length; i++)
                    OutlinedButton(
                      key: Key('x5-stage-$index-act-$i'),
                      onPressed: busy ? null : () => onRun(row.actions[i]),
                      child: Text(row.actions[i].label),
                    ),
                ],
              ),
            ),
          ?journal,
        ],
      ),
    );
  }
}
