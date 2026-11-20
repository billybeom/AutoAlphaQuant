// 🆕 E11q-c0 — M5-9 규칙 변경 게이트 «첫 승인 최소판»(설계 13 §8 R188 · 01 §35 K177~K180 · 표본 `m5/rule_change_gate_*`).
//
// 🔴 머리 · 창 · 후보 · 큐 · 냉각 · 상태 · 버튼 글자 = 엔진 VM 그대로(받은 차례 · 카운트다운 0 — 냉각이 끝나면 엔진이 새 VM).
// 🔴 요청 = 후보 행의 `candidateId` 그대로 + 사람 글 5칸 원문(유형 · 해시를 화면이 고르지 않는다 · 화면 검증 · 파싱 0) ·
//    승인 = `approveLabel` 이 있는 행만(골든 영향 두 버튼 · 승인자 · 제3자 통지) · 취소 = 행의 `cancel` 그대로.
// 🔴 잠김 · 쓰기 주입 null = 동작 0(엔진이 비워서 준다 · 뷰어 = 주입 null) · 결과 = 엔진 `headline` + `reasonCode` 원문 ·
//    제출 자체 실패 = 정적 문장 · 확인 대화 0 · 신뢰 시각 모름 = 결과 원문으로 거부(우회 0).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// M5-9 읽기 창구(조립 앱이 주입).
final Provider<RuleChangeGateRepository>
safetyRuleChangeGateRepositoryProvider = Provider<RuleChangeGateRepository>(
  (Ref ref) => throw UnimplementedError(
    'safetyRuleChangeGateRepositoryProvider must be overridden',
  ),
);

final AutoDisposeStreamProvider<RuleChangeGateVm> _gateProvider =
    StreamProvider.autoDispose<RuleChangeGateVm>(
      (Ref ref) =>
          ref.watch(safetyRuleChangeGateRepositoryProvider).watchGate(),
    );

/// M5-9 규칙 변경 게이트 한 화면.
class RuleChangeGateScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const RuleChangeGateScreen({super.key});

  @override
  ConsumerState<RuleChangeGateScreen> createState() =>
      _RuleChangeGateScreenState();
}

class _RuleChangeGateScreenState extends ConsumerState<RuleChangeGateScreen> {
  /// 열린 폼(후보 id 또는 요청 id · 한 번에 하나).
  String? _open;

  /// 결과(키 = 후보 id 또는 요청 id) · 제출 자체 실패 = null 값.
  final Map<String, SafetyActionResult?> _results =
      <String, SafetyActionResult?>{};
  bool _busy = false;

  final TextEditingController _reason = TextEditingController();
  final TextEditingController _rollback = TextEditingController();
  final TextEditingController _rationale = TextEditingController();
  final TextEditingController _expected = TextEditingController();
  final TextEditingController _rule = TextEditingController();
  final TextEditingController _approver = TextEditingController();
  bool? _golden;
  bool _third = false;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _reason,
      _rollback,
      _rationale,
      _expected,
      _rule,
      _approver,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(
    String key,
    Future<SafetyActionResult> Function(SafetyActions a) call,
  ) async {
    final SafetyActions? actions = ref.read(safetyActionsProvider);
    if (actions == null || _busy) return;
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
      _results[key] = r;
    });
  }

  void _toggle(String key) => setState(() {
    _open = _open == key ? null : key;
    _golden = null;
    _third = false;
  });

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

  Widget _result(String key) {
    if (!_results.containsKey(key)) return const SizedBox.shrink();
    final SafetyActionResult? r = _results[key];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: r == null
          ? Text(
              SafetyLabels.submitNotAccepted,
              key: Key('m59-result-failed-$key'),
            )
          : Text(
              r.reasonCode == null
                  ? r.headline
                  : '${r.headline} (${r.reasonCode})',
              key: Key('m59-result-$key'),
            ),
    );
  }

  Widget _candidate(RuleChangeCandidateRow c, bool canRun) {
    final ThemeData theme = Theme.of(context);
    final bool open = _open == c.candidateId;
    return Card(
      key: Key('m59-cand-${c.candidateId}'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(c.label, style: theme.textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${c.categoryLabel} · ${c.hashText}'),
            ),
            if (c.noticeText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(c.noticeText!, style: theme.textTheme.bodySmall),
              ),
            if (canRun)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.tonal(
                  key: Key('m59-req-open-${c.candidateId}'),
                  onPressed: () => _toggle(c.candidateId),
                  child: Text(c.requestLabel),
                ),
              ),
            if (canRun && open) ...<Widget>[
              _field(_reason, SafetyLabels.ruleChangeReason, 'm59-reason'),
              _field(
                _rollback,
                SafetyLabels.ruleChangeRollback,
                'm59-rollback',
              ),
              _field(
                _rationale,
                SafetyLabels.ruleChangeRationale,
                'm59-rationale',
              ),
              _field(
                _expected,
                SafetyLabels.ruleChangeExpected,
                'm59-expected',
              ),
              _field(_rule, SafetyLabels.ruleChangeRuleCited, 'm59-rule'),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  key: const Key('m59-req-submit'),
                  onPressed: _busy
                      ? null
                      : () => _submit(
                          c.candidateId,
                          (SafetyActions a) => a.runRuleChangeRequest(
                            RuleChangeRequestSubmission(
                              candidateId: c.candidateId,
                              reason: _reason.text,
                              rollbackMethod: _rollback.text,
                              rationaleBefore: _rationale.text,
                              expectedOutcome: _expected.text,
                              ruleCited: _rule.text,
                            ),
                          ),
                        ),
                  child: const Text(SafetyLabels.ruleChangeConfirm),
                ),
              ),
            ],
            _result(c.candidateId),
          ],
        ),
      ),
    );
  }

  Widget _row(RuleChangeQueueRow r, bool canRun) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      r.level,
    );
    final bool open = _open == r.requestId;
    return Card(
      key: Key('m59-row-${r.requestId}'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(icon, color: tone, size: 20),
                ),
                Expanded(
                  child: Text(r.stateLabel, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${r.categoryLabel} · ${r.hashText}'),
            ),
            Text(r.requestedText, style: theme.textTheme.bodySmall),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(r.coolingText),
            ),
            if (canRun && (r.approveLabel != null || r.cancel != null))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    if (r.approveLabel != null)
                      FilledButton.tonal(
                        key: Key('m59-approve-open-${r.requestId}'),
                        onPressed: () => _toggle(r.requestId),
                        child: Text(r.approveLabel!),
                      ),
                    if (r.cancel != null)
                      TextButton(
                        key: Key('m59-cancel-${r.requestId}'),
                        onPressed: _busy
                            ? null
                            : () => _submit(
                                r.requestId,
                                (SafetyActions a) =>
                                    a.run(r.cancel!.id, args: r.cancel!.args),
                              ),
                        child: Text(r.cancel!.label),
                      ),
                  ],
                ),
              ),
            if (canRun && open && r.approveLabel != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  SafetyLabels.ruleChangeGolden,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    key: const Key('m59-golden-yes'),
                    label: const Text(SafetyLabels.ruleChangeGoldenYes),
                    selected: _golden == true,
                    onSelected: (_) => setState(() => _golden = true),
                  ),
                  ChoiceChip(
                    key: const Key('m59-golden-no'),
                    label: const Text(SafetyLabels.ruleChangeGoldenNo),
                    selected: _golden == false,
                    onSelected: (_) => setState(() => _golden = false),
                  ),
                ],
              ),
              _field(
                _approver,
                SafetyLabels.ruleChangeApprover,
                'm59-approver',
              ),
              CheckboxListTile(
                key: const Key('m59-third'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _third,
                onChanged: (bool? v) => setState(() => _third = v ?? false),
                title: const Text(SafetyLabels.ruleChangeThirdParty),
              ),
              FilledButton(
                key: const Key('m59-approve-submit'),
                onPressed: _busy
                    ? null
                    : () => _submit(
                        r.requestId,
                        (SafetyActions a) => a.runRuleChangeApproval(
                          RuleChangeApprovalSubmission(
                            requestId: r.requestId,
                            goldenChanged: _golden,
                            approver: _approver.text,
                            thirdPartyNotified: _third,
                          ),
                        ),
                      ),
                child: const Text(SafetyLabels.ruleChangeConfirm),
              ),
            ],
            _result(r.requestId),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RuleChangeGateVm> data = ref.watch(_gateProvider);
    final RuleChangeGateVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.ruleChangeReadFailed,
                key: Key('m59-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('m59-loading')),
            );
    }
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final bool canRun =
        ref.watch(safetyActionsProvider) != null && vm.lockedLabel == null;
    return ListView(
      key: const Key('m59-root'),
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
                key: const Key('m59-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (vm.windowText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.windowText!, key: const Key('m59-window')),
          ),
        if (vm.lockedLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.lockedLabel!, key: const Key('m59-locked')),
          ),
        if (vm.emptyLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(vm.emptyLabel!, key: const Key('m59-empty')),
          ),
        for (final RuleChangeCandidateRow c in vm.candidates)
          _candidate(c, canRun),
        for (final RuleChangeQueueRow r in vm.rows) _row(r, canRun),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m59-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
