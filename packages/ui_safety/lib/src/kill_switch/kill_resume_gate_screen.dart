// M5-2 킬스위치 재개 게이트(라우트 `AppRoutes.m5ReleaseGate` · 06 M5-2 · 01 §30 K36 · K38 · §34 K153 · 미결 184 · 설계 13 §8 R180).
//
// 🔴 읽기 = `KillSwitchGateRepository.watchResumeGate()` · 받은 글자 · 차례 그대로(남은 시간 · 단계 계산 0 · 게이지 = 엔진 값 × 폭).
// 🔴 7문항 순차 — 입력 칸은 **지금 받을 문항(`nextItemNo`) 하나**에만 · 일괄 체크 · 건너뛰기 0 · 받을 문항이 없으면 칸 0.
// 🔴 쓰기 = `SafetyActions.runKillResumeItem`(문항 하나씩) · 결과 = `headline` 원문만(분기 0) · 주입 null = 컨트롤 부재.
// 🔴 서약 재생 = `PledgeRepository.watchPledge()` 의 원문 줄(편집 0).
// 🔴 칸 머리 · «확인» = 카드 정적(01 §30 K37) · 칸 대응 = 카드 정적(1 지금 규칙 · 2 감정 · 강도 · 수면 · 3 · 4 고르기 · 5 · 6 확인 ·
//    7 사전 필드 3).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../pledge/pledge_panel.dart'
    show safetyActionsProvider, safetyPledgeRepositoryProvider;
import 'kill_switch_screen.dart' show safetyKillSwitchGateRepositoryProvider;

final AutoDisposeStreamProvider<KillResumeGateVm> _gateProvider =
    StreamProvider.autoDispose<KillResumeGateVm>(
      (Ref ref) =>
          ref.watch(safetyKillSwitchGateRepositoryProvider).watchResumeGate(),
    );

final AutoDisposeStreamProvider<PledgeVm> _pledgeProvider =
    StreamProvider.autoDispose<PledgeVm>(
      (Ref ref) => ref.watch(safetyPledgeRepositoryProvider).watchPledge(),
    );

/// M5-2 재개 게이트 본문.
class KillResumeGateScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const KillResumeGateScreen({super.key});

  @override
  ConsumerState<KillResumeGateScreen> createState() =>
      _KillResumeGateScreenState();
}

class _KillResumeGateScreenState extends ConsumerState<KillResumeGateScreen> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _emotion = TextEditingController();
  final TextEditingController _intensity = TextEditingController();
  final TextEditingController _sleep = TextEditingController();
  final TextEditingController _rationale = TextEditingController();
  final TextEditingController _expected = TextEditingController();
  final TextEditingController _rule = TextEditingController();
  KillResumeScenario? _scenario;
  KillResumeCondition? _condition;
  SafetyActionResult? _result;
  bool _failed = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _text,
      _emotion,
      _intensity,
      _sleep,
      _rationale,
      _expected,
      _rule,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clear() {
    for (final TextEditingController c in <TextEditingController>[
      _text,
      _emotion,
      _intensity,
      _sleep,
      _rationale,
      _expected,
      _rule,
    ]) {
      c.clear();
    }
    _scenario = null;
    _condition = null;
  }

  Future<void> _submit(SafetyActions a, int itemNo) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    SafetyActionResult? r;
    try {
      r = await a.runKillResumeItem(
        KillResumeItemSubmission(
          itemNo: itemNo,
          text: _text.text,
          emotion: _emotion.text,
          intensity: _intensity.text,
          sleepHours: _sleep.text,
          scenario: _scenario,
          condition: _condition,
          acknowledged: itemNo == 5 || itemNo == 6,
          rationaleBefore: _rationale.text,
          expectedOutcome: _expected.text,
          ruleCited: _rule.text,
        ),
      );
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = r;
      _failed = r == null;
      if (r != null && r.reasonCode == null) _clear();
    });
  }

  Widget _field(String key, String label, TextEditingController c) => TextField(
    key: Key(key),
    controller: c,
    decoration: InputDecoration(labelText: label),
  );

  List<Widget> _inputs(KillResumeItemRow row) {
    final int n = row.itemNo;
    if (n == 1) {
      return <Widget>[_field('m52-text', SafetyLabels.resumeNowRule, _text)];
    }
    if (n == 2) {
      return <Widget>[
        _field('m52-emotion', SafetyLabels.killEmotion, _emotion),
        _field('m52-intensity', SafetyLabels.killIntensity, _intensity),
        _field('m52-sleep', SafetyLabels.killSleepHours, _sleep),
      ];
    }
    if (n == 7) {
      return <Widget>[
        _field('m52-rationale', SafetyLabels.resumeRationale, _rationale),
        _field('m52-expected', SafetyLabels.resumeExpected, _expected),
        _field('m52-rule', SafetyLabels.resumeRuleCited, _rule),
      ];
    }
    return const <Widget>[];
  }

  Widget _row(KillResumeItemRow row, int? next, SafetyActions? actions) {
    final bool current = next == row.itemNo;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      key: Key('m52-item-${row.itemNo}'),
      color: current ? cs.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${row.itemNo}. ${row.label}'),
            if (row.replayText != null)
              Text(
                row.replayText!,
                key: Key('m52-replay-${row.itemNo}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (row.answeredText != null)
              Text(
                row.answeredText!,
                key: Key('m52-answered-${row.itemNo}'),
                style: TextStyle(
                  color: row.level == UiLevel.blocked ? cs.error : null,
                ),
              ),
            if (current && actions != null) ...<Widget>[
              if (row.choices.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    for (final KillResumeChoice c in row.choices)
                      ChoiceChip(
                        key: Key('m52-choice-${row.itemNo}-${c.label}'),
                        label: Text(c.label),
                        selected: c.scenario != null
                            ? _scenario == c.scenario
                            : _condition == c.condition,
                        onSelected: (_) => setState(() {
                          if (c.scenario != null) _scenario = c.scenario;
                          if (c.condition != null) _condition = c.condition;
                        }),
                      ),
                  ],
                ),
              ..._inputs(row),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  key: const Key('m52-confirm'),
                  onPressed: _busy
                      ? null
                      : () => unawaited(_submit(actions, row.itemNo)),
                  child: const Text(SafetyLabels.resumeConfirm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<KillResumeGateVm> data = ref.watch(_gateProvider);
    final SafetyActions? actions = ref.watch(safetyActionsProvider);
    final PledgeVm? pledge = ref.watch(_pledgeProvider).valueOrNull;
    final KillResumeGateVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.resumeGateReadFailed,
                key: Key('m52-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('m52-loading')),
            );
    }
    final GaugeProgress? cd = vm.cooldown;
    return ListView(
      key: const Key('m52-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          vm.readinessLabel,
          key: const Key('m52-readiness'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (vm.etaText != null) Text(vm.etaText!, key: const Key('m52-eta')),
        if (cd != null)
          Padding(
            key: const Key('m52-cooldown'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(cd.label),
                LinearProgressIndicator(value: cd.normalized),
                Text(cd.valueText),
              ],
            ),
          ),
        if (pledge != null && pledge.lines.isNotEmpty)
          Card(
            key: const Key('m52-pledge'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(SafetyLabels.resumePledgeTitle),
                  for (final String l in pledge.lines) Text(l),
                ],
              ),
            ),
          ),
        if (vm.blockedText != null)
          Text(
            vm.blockedText!,
            key: const Key('m52-blocked'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (vm.lockedLabel != null)
          Text(vm.lockedLabel!, key: const Key('m52-locked')),
        for (final KillResumeItemRow r in vm.items)
          _row(r, vm.nextItemNo, actions),
        if (_result != null)
          Text(_result!.headline, key: const Key('m52-result')),
        if (_failed)
          const Text(SafetyLabels.submitNotAccepted, key: Key('m52-failed')),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m52-asof'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
