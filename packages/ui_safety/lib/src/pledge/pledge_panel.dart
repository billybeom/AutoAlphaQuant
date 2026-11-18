// M5-8 본인 서약 3문장 — O-04 ② 슬롯(`OnboardingSlotIds.pledgeWrite`)에 조립 앱이 끼운다(06 M5-8 · 04 §9-5 ② ·
// 01 §30 K6 · K16 · K31 · K32 · 설계 13 §8 R157).
//
// 🔴 읽기 = `PledgeRepository.watchPledge()` · 쓰기 = `SafetyActions.runPledge`(폰 전용 — 뷰어 = null → 컨트롤 부재).
// 🔴 첫 판 없음 = 빈 세 칸(예시 · 힌트 · 프리필 0) · 화면 검증 0 — 빈칸 · 셋 아님 = 엔진 `PLEDGE_SENTENCES_MISSING`.
//    결과 = `headline` 원문만(분기 0 · 01 §30) · 저장되면 읽기 모델이 세 줄을 내고 칸은 사라진다.
// 🔴 판 있음 = 원문 세 줄만(엔진 글자가 있는 칸만 덧붙인다) · 편집 컨트롤 0 — 편집 = 12월 창 + 사전 저널
//    (01 §8 미결 185 · 원천 전).
// 🔴 건너뛰기 없음 — 다음 단계 판정 = 엔진(마무리 VM 의 서약 사실).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';

/// 서약 읽기 창구 주입 — 조립 앱이 공급한다(🔴 throw 기본값 · 규칙 10).
final Provider<PledgeRepository> safetyPledgeRepositoryProvider =
    Provider<PledgeRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyPledgeRepositoryProvider must be overridden',
      ),
    );

/// 안전 동작 주입 — 조립 앱이 공급한다(폰 전용 · 🔴 null = 컨트롤 부재(뷰어) · throw 기본값).
final Provider<SafetyActions?> safetyActionsProvider = Provider<SafetyActions?>(
  (Ref ref) =>
      throw UnimplementedError('safetyActionsProvider must be overridden'),
);

final AutoDisposeStreamProvider<PledgeVm> _pledgeProvider =
    StreamProvider.autoDispose<PledgeVm>(
      (Ref ref) => ref.watch(safetyPledgeRepositoryProvider).watchPledge(),
    );

const List<String> _fieldLabels = <String>[
  SafetyLabels.pledgeSentence1,
  SafetyLabels.pledgeSentence2,
  SafetyLabels.pledgeSentence3,
];

/// M5-8 서약 칸(온보딩 슬롯 본문 · 스크롤은 품은 화면이 한다).
class PledgePanel extends ConsumerStatefulWidget {
  /// 만든다.
  const PledgePanel({super.key});

  @override
  ConsumerState<PledgePanel> createState() => _PledgePanelState();
}

class _PledgePanelState extends ConsumerState<PledgePanel> {
  final List<TextEditingController> _lines = <TextEditingController>[
    for (int i = 0; i < _fieldLabels.length; i++) TextEditingController(),
  ];
  SafetyActionResult? _result;
  bool _saving = false;
  bool _notAccepted = false;

  @override
  void dispose() {
    for (final TextEditingController c in _lines) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final SafetyActions? actions = ref.read(safetyActionsProvider);
    if (actions == null) return;
    setState(() {
      _saving = true;
      _notAccepted = false;
    });
    final SafetyActionResult r;
    try {
      r = await actions.runPledge(
        PledgeSubmission(
          id: SafetyActionId.pledgeWrite,
          sentences: <String>[
            for (final TextEditingController c in _lines) c.text,
          ],
        ),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _notAccepted = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _result = r;
    });
  }

  Widget _line(String text, Key key) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(text, key: key),
  );

  Widget _written(PledgeVm vm) => Column(
    key: const Key('m5-8-written'),
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      for (final (int i, String s) in vm.lines.indexed)
        _line(s, ValueKey<String>('m5-8-line-$i')),
      if (vm.statusLine case final String s) _line(s, const Key('m5-8-status')),
      if (vm.replayNotice case final String s)
        _line(s, const Key('m5-8-replay')),
      if (vm.lockedLabel case final String s)
        _line(s, const Key('m5-8-locked')),
    ],
  );

  Widget _form(BuildContext context) {
    final SafetyActionResult? r = _result;
    return Column(
      key: const Key('m5-8-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final (int i, String label) in _fieldLabels.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              key: ValueKey<String>('m5-8-input-$i'),
              controller: _lines[i],
              enabled: !_saving,
              maxLines: null,
              decoration: InputDecoration(labelText: label),
            ),
          ),
        if (r != null) _line(r.headline, const Key('m5-8-result')),
        if (_notAccepted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              SafetyLabels.submitNotAccepted,
              key: const Key('m5-8-not-accepted'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: FilledButton(
            key: const Key('m5-8-save'),
            onPressed: _saving ? null : () => unawaited(_save()),
            child: const Text(SafetyLabels.pledgeSave),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SafetyActions? actions = ref.watch(safetyActionsProvider);
    return ref
        .watch(_pledgeProvider)
        .when(
          data: (PledgeVm value) => value.lines.isNotEmpty
              ? _written(value)
              : actions == null
              ? const SizedBox.shrink(key: Key('m5-8-absent'))
              : _form(context),
          error: (Object _, StackTrace _) =>
              const Text(SafetyLabels.pledgeReadFailed, key: Key('m5-8-error')),
          loading: () =>
              const LinearProgressIndicator(key: Key('m5-8-loading')),
        );
  }
}
