// 🆕 E11q-b3 — M5-5 차단 보드(설계 13 §8 R185 · 01 §34 K154 · K155 · 06 M5-5 · 표본 `m5/block_board_*`).
//
// 🔴 머리 · 행 · 게이지 · 사다리 · 링크 = 엔진 VM 그대로(받은 차례 · 재정렬 · 재분류 0 · 화면이 flagId 로 글자나 목적지를 고르지 않는다).
// 🔴 해제 버튼 0 · 카운트다운 0(게이지 = `valueText` 표시 · `normalized` = 폭만) · 행 링크 = 엔진이 준 것만.
// 🆕 E11q-c4(R189 · 01 §35 K181) 하나 예외 — 엔진이 행에 `reconClear` 를 준 RECON 행만 해제 폼(행 안 버튼으로 연다 — 보드는 한눈에):
//    원인 코드(엔진 선택지 · 받은 차례 · 고르기 전 = 확인 꺼짐) · 사전 저널 세 칸(원문 · 화면 검증 0) · 확인 → `runReconClear` ·
//    확인 대화 0 · 쓰기 주입 null(뷰어) = 폼 0 ·
//    결과 = 엔진 `headline` + `reasonCode` 원문(폼이 있으면 확인 아래 · 풀려 행이 사라지면 맨 위로 옮겨 남고 성공 = 맨 위로 스크롤) ·
//    제출 자체 실패 = 정적 문장.
// 🔴 킬스위치 진입 = 늘(VM `killSwitchLink` · 보드가 긴급 진입점 둘째 길) — 읽기 실패에도 같은 화면으로 가는 길 하나는 남긴다.
// 🔴 사다리 지금 단 = 색 + «지금 단계» 글자(색만으로 말하지 않는다).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

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
class BlockBoardScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const BlockBoardScreen({super.key});

  @override
  ConsumerState<BlockBoardScreen> createState() => _BlockBoardScreenState();
}

class _BlockBoardScreenState extends ConsumerState<BlockBoardScreen> {
  /// RECON 해제 결과를 받았나 · 결과(제출 자체 실패 = null).
  bool _reconDone = false;
  SafetyActionResult? _reconResult;
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onReconResult(SafetyActionResult? r) {
    setState(() {
      _reconDone = true;
      _reconResult = r;
    });
    // 풀었다 = 행이 곧 사라진다 → 맨 위(머리 · 결과 줄)로.
    if (r != null && r.reasonCode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  /// 결과 한 줄(엔진 글자 원문 · 제출 자체 실패 = 정적 문장).
  Widget _reconResultLine() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: _reconResult == null
        ? const Text(
            SafetyLabels.submitNotAccepted,
            key: Key('m55-recon-result-failed'),
          )
        : Text(
            _reconResult!.reasonCode == null
                ? _reconResult!.headline
                : '${_reconResult!.headline} (${_reconResult!.reasonCode})',
            key: const Key('m55-recon-result'),
          ),
  );

  @override
  Widget build(BuildContext context) {
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
    // 결과 자리 — 폼이 있으면 그 안(확인 아래) · 없으면(풀려 행이 빠짐) 맨 위.
    //    (폼이 없는 보드 = 쓰기 주입을 읽지 않는다.)
    final bool formShown =
        vm.rows.any((BlockBoardRow r) => r.reconClear != null) &&
        ref.watch(
          safetyActionsProvider.select((SafetyActions? a) => a != null),
        );
    return ListView(
      key: const Key('m55-root'),
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
        if (_reconDone && !formShown) _reconResultLine(),
        for (final BlockBoardRow r in vm.rows)
          _RowCard(
            // 행 id 열쇠 — 결과 줄 · 위 행이 끼어도 RECON 폼 입력이 날아가지 않게.
            key: ValueKey<String>('m55-rowcard-${r.rowId}'),
            row: r,
            onOpen: open,
            onReconResult: _onReconResult,
            reconResult: _reconDone && formShown ? _reconResultLine() : null,
          ),
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
  const _RowCard({
    super.key,
    required this.row,
    required this.onOpen,
    required this.onReconResult,
    this.reconResult,
  });

  final BlockBoardRow row;
  final void Function(String link) onOpen;
  final void Function(SafetyActionResult? r) onReconResult;

  /// RECON 해제 결과 줄(폼이 있을 때 · 확인 아래).
  final Widget? reconResult;

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
            if (row.reconClear != null)
              _ReconClearPanel(
                form: row.reconClear!,
                onResult: onReconResult,
                result: reconResult,
              ),
          ],
        ),
      ),
    );
  }
}

/// RECON 행 해제 폼(엔진이 `reconClear` 를 준 행만 · 쓰기 주입 null = 부재).
class _ReconClearPanel extends ConsumerStatefulWidget {
  const _ReconClearPanel({
    required this.form,
    required this.onResult,
    this.result,
  });

  final ReconClearForm form;
  final void Function(SafetyActionResult? r) onResult;
  final Widget? result;

  @override
  ConsumerState<_ReconClearPanel> createState() => _ReconClearPanelState();
}

class _ReconClearPanelState extends ConsumerState<_ReconClearPanel> {
  bool _open = false;
  String? _origin;
  bool _busy = false;
  final TextEditingController _rationale = TextEditingController();
  final TextEditingController _expected = TextEditingController();
  final TextEditingController _rule = TextEditingController();

  @override
  void dispose() {
    _rationale.dispose();
    _expected.dispose();
    _rule.dispose();
    super.dispose();
  }

  Future<void> _submit(SafetyActions actions, String origin) async {
    setState(() => _busy = true);
    SafetyActionResult? r;
    try {
      r = await actions.runReconClear(
        ReconClearSubmission(
          originCode: origin,
          rationaleBefore: _rationale.text,
          expectedOutcome: _expected.text,
          ruleCited: _rule.text,
        ),
      );
    } on Object {
      r = null;
    }
    if (mounted) setState(() => _busy = false);
    widget.onResult(r);
  }

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

  @override
  Widget build(BuildContext context) {
    final SafetyActions? actions = ref.watch(safetyActionsProvider);
    if (actions == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final String? origin = _origin;
    return Padding(
      key: const Key('m55-recon-form'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.form.noticeText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.form.noticeText!,
                key: const Key('m55-recon-notice'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          // 폼은 버튼으로 연다(보드 = 한눈에 — 다른 행 · 사다리를 밀어내지 않는다 · c0 요청 폼 결).
          FilledButton.tonal(
            key: const Key('m55-recon-open'),
            onPressed: () => setState(() => _open = !_open),
            child: const Text(SafetyLabels.reconClearOpen),
          ),
          if (_open) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                SafetyLabels.reconClearOrigin,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final ReconOriginChoice c in widget.form.choices)
                  ChoiceChip(
                    key: Key('m55-recon-origin-${c.originCode}'),
                    label: Text(c.label),
                    selected: origin == c.originCode,
                    onSelected: (bool v) =>
                        setState(() => _origin = v ? c.originCode : null),
                  ),
              ],
            ),
            _field(
              _rationale,
              SafetyLabels.reconClearRationale,
              'm55-recon-rationale',
            ),
            _field(
              _expected,
              SafetyLabels.reconClearExpected,
              'm55-recon-expected',
            ),
            _field(_rule, SafetyLabels.reconClearRuleCited, 'm55-recon-rule'),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton(
                key: const Key('m55-recon-submit'),
                onPressed: _busy || origin == null
                    ? null
                    : () => _submit(actions, origin),
                child: const Text(SafetyLabels.reconClearConfirm),
              ),
            ),
          ],
          if (widget.result != null) widget.result!,
        ],
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
