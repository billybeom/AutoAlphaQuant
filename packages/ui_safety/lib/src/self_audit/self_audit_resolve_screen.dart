// 🆕 R280 — M5-13 원장 실사 «해소» 게이트(설계 13 §8 R280 · 01 §46 K318~K322 · 06 M5-13 · 표본 `m5/self_audit_resolve_*` ·
// `m5/held_review_results`).
//
// 🔴 머리 · 플래그 줄 · 해제 규칙 · 카운터 · 차이 행 · 실사 링크 · 보관 행 · 확정 버튼 · 막힘 문장 = 엔진 VM 그대로(받은 차례 ·
//    재정렬 · 재분류 0 · 화면이 원값으로 글자나 목적지를 고르지 않는다).
// 🔴 수동 해제 버튼 0 · 버림 버튼 0(해제 = 실사 0오차 통과를 본 엔진이 스스로 · 보관 명령 = 사람이 낸 사실).
// 🔴 차이 행 = 정정 마법사 대상 아님(K320) — 행 조치 = 엔진이 준 «다시 실사하기»(그 달 · 그 계좌 `L-3`)만.
// 🔴 확정 = 엔진 완성 `SafetyActionCall`(`heldCommandsConfirm` · `{review_id}`) 그대로 `SafetyActions.run` · 확인 대화 0 · 쓰기 주입
//    null(뷰어 · M5-13 부재) = 버튼 0 · 결과 = 엔진 `headline` + `reasonCode` 원문 · 제출 자체 실패 = 정적 문장.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// M5-13 읽기 창구(조립 앱이 주입).
final Provider<SelfAuditResolveRepository>
safetySelfAuditResolveRepositoryProvider = Provider<SelfAuditResolveRepository>(
  (Ref ref) => throw UnimplementedError(
    'safetySelfAuditResolveRepositoryProvider must be overridden',
  ),
);

final AutoDisposeStreamProvider<SelfAuditResolveVm> _resolveProvider =
    StreamProvider.autoDispose<SelfAuditResolveVm>(
      (Ref ref) =>
          ref.watch(safetySelfAuditResolveRepositoryProvider).watchResolve(),
    );

/// M5-13 원장 실사 해소 게이트 한 화면.
class SelfAuditResolveScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const SelfAuditResolveScreen({super.key});

  @override
  ConsumerState<SelfAuditResolveScreen> createState() =>
      _SelfAuditResolveScreenState();
}

class _SelfAuditResolveScreenState
    extends ConsumerState<SelfAuditResolveScreen> {
  bool _busy = false;
  bool _done = false;
  SafetyActionResult? _result;

  Future<void> _confirm(SafetyActions actions, SafetyActionCall call) async {
    setState(() => _busy = true);
    SafetyActionResult? r;
    try {
      r = await actions.run(call.id, args: call.args);
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = true;
      _result = r;
    });
  }

  Widget _resultLine() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: _result == null
        ? const Text(
            SafetyLabels.submitNotAccepted,
            key: Key('m513-result-failed'),
          )
        : Text(
            _result!.reasonCode == null
                ? _result!.headline
                : '${_result!.headline} (${_result!.reasonCode})',
            key: const Key('m513-result'),
          ),
  );

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SelfAuditResolveVm> data = ref.watch(_resolveProvider);
    final SelfAuditResolveVm? vm = data.valueOrNull;
    void open(String link) => ref.read(safetyLinkOpenerProvider).open(link);
    if (vm == null) {
      return Center(
        child: data.hasError
            ? const Text(
                SafetyLabels.selfAuditResolveReadFailed,
                key: Key('m513-read-failed'),
              )
            : const CircularProgressIndicator(key: Key('m513-loading')),
      );
    }
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final SafetyActions? actions = ref.watch(safetyActionsProvider);
    final SafetyActionCall? confirm = vm.confirmHeld;
    return ListView(
      key: const Key('m513-root'),
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
                key: const Key('m513-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(vm.flagLine, key: const Key('m513-flag')),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            vm.releaseRuleText,
            key: const Key('m513-release-rule'),
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (vm.counterLines.isNotEmpty) ...<Widget>[
          const _Section(SafetyLabels.selfAuditResolveCounters),
          for (int i = 0; i < vm.counterLines.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(vm.counterLines[i], key: Key('m513-counter-$i')),
            ),
        ],
        const _Section(SafetyLabels.selfAuditResolveDiffs),
        if (vm.diffsEmptyLabel != null)
          Text(vm.diffsEmptyLabel!, key: const Key('m513-diffs-empty')),
        for (final LedgerDiffRow r in vm.diffs) _DiffCard(row: r, onOpen: open),
        if (vm.auditLinks.isNotEmpty) ...<Widget>[
          const _Section(SafetyLabels.selfAuditResolveAudits),
          for (int i = 0; i < vm.auditLinks.length; i++)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: Key('m513-audit-$i'),
                onPressed: () => open(vm.auditLinks[i].deepLink),
                child: Text(vm.auditLinks[i].label),
              ),
            ),
        ],
        const _Section(SafetyLabels.selfAuditResolveHeld),
        if (vm.heldEmptyLabel != null)
          Text(vm.heldEmptyLabel!, key: const Key('m513-held-empty')),
        for (final HeldCommandRow h in vm.heldCommands) _HeldCard(row: h),
        if (vm.heldBlockedText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              vm.heldBlockedText!,
              key: const Key('m513-held-blocked'),
            ),
          ),
        if (confirm != null && actions != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                key: const Key('m513-confirm'),
                onPressed: _busy ? null : () => _confirm(actions, confirm),
                child: Text(confirm.label),
              ),
            ),
          ),
        if (_done) _resultLine(),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m513-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _DiffCard extends StatelessWidget {
  const _DiffCard({required this.row, required this.onOpen});

  final LedgerDiffRow row;
  final void Function(String link) onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LinkAction? link = row.actionLink;
    return Card(
      key: Key('m513-diff-${row.diffId}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
            if (link != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: Key('m513-diff-link-${row.diffId}'),
                  onPressed: () => onOpen(link.deepLink),
                  child: Text(link.label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeldCard extends StatelessWidget {
  const _HeldCard({required this.row});

  final HeldCommandRow row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      key: Key('m513-held-${row.commandId}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(row.kindLabel, style: theme.textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(row.summaryText),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${row.receivedAtText} · ${row.stateLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
