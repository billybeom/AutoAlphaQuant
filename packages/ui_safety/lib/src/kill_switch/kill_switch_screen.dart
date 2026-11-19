// M5-1 킬스위치 한 화면 + 발동 버튼(라우트 `AppRoutes.m5KillSwitch` · 06 M5-1 · 01 §34 K146~K151 · 설계 13 §8 R178).
//
// 🔴 읽기 = `KillSwitchGateRepository.watchKillSwitch()` · 받은 글자 · 차례 그대로(카운트다운 · 남은 시간 계산 0).
// 🔴 발동 = 버튼 한 번 → `CommandApi.activateKillSwitch()`(인자 0) — 확인 대화 · 지연 · 두 번 누르기 0(06 M5-1).
//    결과 = 접수증 `stateLabel` 원문만. 명령 API 주입이 null 이면(기기 id 없음) 버튼 · 제출 부재(셸 규약).
// 🔴 해제 칸 · 버튼 0 — 해제 = 재개 게이트(`gateLink`) 7문항뿐.
// 🔴 기록 폼(켜짐 ∧ 기록 전) — 칸 대응 = 카드 정적(1 행동 · 2 규칙/감정 + 감정 · 강도 · 수면 · 3 시나리오 / 해당 없음 · 4 재개 조건 ·
//    5 범위 · 확인 3 · 1줄) · 예시 · 프리필 0 · 화면 검증 0(파싱 · 판정 = 명령 구현 · 엔진) · 결과 = 접수증 `stateLabel` 원문.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';

/// 킬스위치 화면 읽기 창구 — 조립 앱이 공급한다(🔴 throw 기본값 · 규칙 10).
final Provider<KillSwitchGateRepository>
safetyKillSwitchGateRepositoryProvider = Provider<KillSwitchGateRepository>(
  (Ref ref) => throw UnimplementedError(
    'safetyKillSwitchGateRepositoryProvider must be overridden',
  ),
);

/// 발동 · 기록 명령 창구 — 조립 앱이 공급한다(null = 버튼 · 제출 부재 · throw 기본값).
final Provider<CommandApi?> safetyKillCommandApiProvider =
    Provider<CommandApi?>(
      (Ref ref) => throw UnimplementedError(
        'safetyKillCommandApiProvider must be overridden',
      ),
    );

/// 링크 열기 — 조립 앱이 공급한다(게이트 링크 · throw 기본값).
final Provider<AppLinkOpener> safetyLinkOpenerProvider =
    Provider<AppLinkOpener>(
      (Ref ref) => throw UnimplementedError(
        'safetyLinkOpenerProvider must be overridden',
      ),
    );

final AutoDisposeStreamProvider<KillSwitchScreenVm> _screenProvider =
    StreamProvider.autoDispose<KillSwitchScreenVm>(
      (Ref ref) =>
          ref.watch(safetyKillSwitchGateRepositoryProvider).watchKillSwitch(),
    );

/// 발동 버튼(화면 · 셸 슬롯 공용) — [label] = 엔진 글자 · 누르면 바로 발동(확인 대화 0) · 접수증은 [onReceipt].
class KillSwitchActivateButton extends ConsumerStatefulWidget {
  /// 만든다.
  const KillSwitchActivateButton({
    super.key,
    required this.label,
    this.onReceipt,
  });

  /// 버튼 글자(엔진 `activateLabel`).
  final String label;

  /// 접수증(또는 접수 실패 = null).
  final void Function(CommandReceipt? receipt)? onReceipt;

  @override
  ConsumerState<KillSwitchActivateButton> createState() =>
      _KillSwitchActivateButtonState();
}

class _KillSwitchActivateButtonState
    extends ConsumerState<KillSwitchActivateButton> {
  Future<void> _activate(CommandApi api) async {
    CommandReceipt? r;
    try {
      r = await api.activateKillSwitch();
    } on Object {
      r = null;
    }
    if (!mounted) return;
    widget.onReceipt?.call(r);
  }

  @override
  Widget build(BuildContext context) {
    final CommandApi? api = ref.watch(safetyKillCommandApiProvider);
    if (api == null) return const SizedBox.shrink();
    return FilledButton(
      key: const Key('m51-activate'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      onPressed: () => unawaited(_activate(api)),
      child: Text(widget.label),
    );
  }
}

/// M5-1 킬스위치 화면 본문.
class KillSwitchScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const KillSwitchScreen({super.key});

  @override
  ConsumerState<KillSwitchScreen> createState() => _KillSwitchScreenState();
}

class _KillSwitchScreenState extends ConsumerState<KillSwitchScreen> {
  final TextEditingController _ruleAction = TextEditingController();
  final TextEditingController _emotion = TextEditingController();
  final TextEditingController _intensity = TextEditingController();
  final TextEditingController _sleep = TextEditingController();
  final TextEditingController _scenario = TextEditingController();
  final TextEditingController _resume = TextEditingController();
  final TextEditingController _note = TextEditingController();
  KillActivationReason? _reason;
  KillActivationScope? _scope;
  bool _scenarioNone = false;
  bool _queried = false;
  bool _cancelled = false;
  bool _zero = false;
  CommandReceipt? _activation;
  bool _activationFailed = false;
  CommandReceipt? _record;
  bool _recordFailed = false;
  bool _submitting = false;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _ruleAction,
      _emotion,
      _intensity,
      _sleep,
      _scenario,
      _resume,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(CommandApi api) async {
    setState(() {
      _submitting = true;
      _recordFailed = false;
    });
    CommandReceipt? r;
    try {
      r = await api.confirmKillChecklist(
        KillChecklistSubmission(
          ruleAction: _ruleAction.text,
          reasonKind: _reason,
          emotion: _emotion.text,
          intensity: _intensity.text,
          sleepHours: _sleep.text,
          scenarioId: _scenario.text,
          scenarioNone: _scenarioNone,
          resumeCondition: _resume.text,
          scope: _scope,
          openOrdersQueried: _queried,
          openOrdersCancelled: _cancelled,
          remainingCountZero: _zero,
          note: _note.text,
        ),
      );
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _record = r;
      _recordFailed = r == null;
    });
  }

  Widget _field(String key, String label, TextEditingController c) => TextField(
    key: Key(key),
    controller: c,
    decoration: InputDecoration(labelText: label),
  );

  List<Widget> _inputsFor(KillActivationItemRow row) {
    final int n = row.itemNo;
    if (n == 1) {
      return <Widget>[_field('m51-rule-action', row.label, _ruleAction)];
    }
    if (n == 2) {
      return <Widget>[
        _field('m51-emotion', SafetyLabels.killEmotion, _emotion),
        _field('m51-intensity', SafetyLabels.killIntensity, _intensity),
        _field('m51-sleep', SafetyLabels.killSleepHours, _sleep),
      ];
    }
    if (n == 3) {
      return <Widget>[
        _field('m51-scenario', row.label, _scenario),
        CheckboxListTile(
          key: const Key('m51-scenario-none'),
          title: const Text(SafetyLabels.killScenarioNone),
          value: _scenarioNone,
          onChanged: (bool? v) => setState(() => _scenarioNone = v ?? false),
        ),
      ];
    }
    if (n == 4) {
      return <Widget>[_field('m51-resume-condition', row.label, _resume)];
    }
    return const <Widget>[];
  }

  Widget _item(KillActivationItemRow row) {
    final List<Widget> body = <Widget>[
      Text('${row.itemNo}. ${row.label}'),
      if (row.hintText != null)
        Text(row.hintText!, style: Theme.of(context).textTheme.bodySmall),
      if (row.fixedText != null) Text(row.fixedText!),
      if (row.choices.isNotEmpty)
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (final KillActivationChoice c in row.choices)
              ChoiceChip(
                key: Key('m51-choice-${row.itemNo}-${c.label}'),
                label: Text(c.label),
                selected: c.reasonKind != null
                    ? _reason == c.reasonKind
                    : _scope == c.scope,
                onSelected: (_) => setState(() {
                  if (c.reasonKind != null) _reason = c.reasonKind;
                  if (c.scope != null) _scope = c.scope;
                }),
              ),
          ],
        ),
      // 칸 대응 = 카드 정적(01 §34 — 1 행동 · 2 감정 · 강도 · 수면 · 3 시나리오 · 4 재개 조건) · 5 = 선택 · 6 · 7 = 고정 글자.
      ..._inputsFor(row),
    ];
    return Padding(
      key: Key('m51-item-${row.itemNo}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: body,
      ),
    );
  }

  Widget _form(KillActivationFormVm f, CommandApi? api) {
    final bool done =
        _record != null &&
        (_record!.state == CommandState.executed ||
            _record!.state == CommandState.requested ||
            _record!.state == CommandState.received);
    return Card(
      key: const Key('m51-form'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (f.noticeText != null)
              Text(f.noticeText!, key: const Key('m51-form-notice')),
            for (final KillActivationItemRow r in f.items) _item(r),
            CheckboxListTile(
              key: const Key('m51-ack-queried'),
              title: Text(f.ackQueriedLabel),
              value: _queried,
              onChanged: (bool? v) => setState(() => _queried = v ?? false),
            ),
            CheckboxListTile(
              key: const Key('m51-ack-cancelled'),
              title: Text(f.ackCancelledLabel),
              value: _cancelled,
              onChanged: (bool? v) => setState(() => _cancelled = v ?? false),
            ),
            CheckboxListTile(
              key: const Key('m51-ack-zero'),
              title: Text(f.ackRemainingZeroLabel),
              value: _zero,
              onChanged: (bool? v) => setState(() => _zero = v ?? false),
            ),
            _field('m51-note', f.noteLabel, _note),
            if (api != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  key: const Key('m51-record-submit'),
                  onPressed: _submitting || done
                      ? null
                      : () => unawaited(_submit(api)),
                  child: const Text(SafetyLabels.killRecordSubmit),
                ),
              ),
            if (_record != null)
              Text(_record!.stateLabel, key: const Key('m51-record-receipt')),
            if (_recordFailed)
              const Text(
                SafetyLabels.submitNotAccepted,
                key: Key('m51-record-failed'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<KillSwitchScreenVm> data = ref.watch(_screenProvider);
    final CommandApi? api = ref.watch(safetyKillCommandApiProvider);
    final KillSwitchScreenVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.killSwitchReadFailed,
                key: Key('m51-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('m51-loading')),
            );
    }
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListView(
      key: const Key('m51-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          vm.stateLabel,
          key: const Key('m51-state'),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: vm.level == UiLevel.ok ? null : cs.error),
        ),
        if (vm.activatedText != null)
          Text(vm.activatedText!, key: const Key('m51-activated')),
        if (vm.activateLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: KillSwitchActivateButton(
              label: vm.activateLabel!,
              onReceipt: (CommandReceipt? r) => setState(() {
                _activation = r;
                _activationFailed = r == null;
              }),
            ),
          ),
        if (_activation != null)
          Text(_activation!.stateLabel, key: const Key('m51-activate-receipt')),
        if (_activationFailed)
          const Text(
            SafetyLabels.submitNotAccepted,
            key: Key('m51-activate-failed'),
          ),
        for (final String line in vm.pathLines)
          Text(line, key: Key('m51-path-${vm.pathLines.indexOf(line)}')),
        if (vm.cancelHeadline != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(vm.cancelHeadline!, key: const Key('m51-cancel')),
          ),
        for (final KillCancelRow r in vm.cancelRows)
          ListTile(
            key: Key('m51-cancel-${r.outcomeCode}-${r.symbolText}'),
            dense: true,
            title: Text(r.symbolText),
            subtitle: Text(r.outcomeLabel),
          ),
        if (vm.checklistStateLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              vm.checklistStateLabel!,
              key: const Key('m51-checklist'),
            ),
          ),
        if (vm.form != null) _form(vm.form!, api),
        if (vm.etaText != null) Text(vm.etaText!, key: const Key('m51-eta')),
        if (vm.gateLink != null)
          TextButton(
            key: const Key('m51-gate'),
            onPressed: () =>
                ref.read(safetyLinkOpenerProvider).open(vm.gateLink!.deepLink),
            child: Text(vm.gateLink!.label),
          ),
        if (vm.lockedLabel != null)
          Text(vm.lockedLabel!, key: const Key('m51-locked')),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m51-asof'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
