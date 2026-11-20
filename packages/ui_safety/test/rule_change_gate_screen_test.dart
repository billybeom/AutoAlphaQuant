// M5-9 규칙 변경 게이트(설계 13 §8 R188) — 읽기 모델 = 계약 픽스처(`m5/rule_change_gate_*`).
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 요청 = 후보 id 그대로 + 사람 글 원문 · 승인 = `approveLabel` 행만 · 취소 = 행의 `cancel`
//    그대로 · 잠김 · 쓰기 주입 null = 동작 0 · 결과 = 엔진 글자 · 제출 실패 = 정적 문장 · 확인 대화 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

RuleChangeGateVm _vm(String name) => RuleChangeGateVm.fromJson(
  ((jsonDecode(
                File(
                  '../domain_contracts/fixtures/m5/rule_change_gate_$name.json',
                ).readAsStringSync(),
              ) as Map<String, dynamic>)['rows']
              as List<dynamic>)
          .first
      as Map<String, dynamic>,
);

class _Repo implements RuleChangeGateRepository {
  final StreamController<RuleChangeGateVm> c =
      StreamController<RuleChangeGateVm>();

  @override
  Stream<RuleChangeGateVm> watchGate() => c.stream;

  void close() => unawaited(c.close());
}

SafetyActionResult _result(SafetyActionId id, String? code) =>
    SafetyActionResult(
      actionRunId: 'run-1',
      id: id,
      level: code == null ? UiLevel.ok : UiLevel.blocked,
      headline: '엔진 결과 ${id.wire}',
      reasonCode: code,
      retryable: false,
    );

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.fail = false});

  final bool fail;
  final List<RuleChangeRequestSubmission> requests =
      <RuleChangeRequestSubmission>[];
  final List<RuleChangeApprovalSubmission> approvals =
      <RuleChangeApprovalSubmission>[];
  final List<(SafetyActionId, Map<String, String>)> runs =
      <(SafetyActionId, Map<String, String>)>[];

  @override
  Future<SafetyActionResult> runRuleChangeRequest(
    RuleChangeRequestSubmission submission,
  ) async {
    requests.add(submission);
    if (fail) throw StateError('제출 실패');
    return _result(SafetyActionId.ruleChangeRequest, 'TRUSTED_TIME_UNKNOWN');
  }

  @override
  Future<SafetyActionResult> runRuleChangeApproval(
    RuleChangeApprovalSubmission submission,
  ) async {
    approvals.add(submission);
    return _result(SafetyActionId.ruleChangeApprove, null);
  }

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    runs.add((id, args));
    return _result(id, null);
  }
}

Future<_Repo> _pump(WidgetTester t, {SafetyActions? actions}) async {
  t.view.physicalSize = const Size(800, 3000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyRuleChangeGateRepositoryProvider.overrideWithValue(repo),
        safetyActionsProvider.overrideWithValue(actions),
      ],
      child: const MaterialApp(home: Scaffold(body: RuleChangeGateScreen())),
    ),
  );
  return repo;
}

Future<void> _show(WidgetTester t, _Repo repo, RuleChangeGateVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

List<String> _cards(WidgetTester t) => <String>[
  for (final Element e in find.byType(Card).evaluate())
    (e.widget.key! as ValueKey<String>).value,
];

void main() {
  for (final String f in <String>[
    'first_candidate',
    'cooling',
    'approvable',
    'empty',
    'locked',
  ]) {
    testWidgets('$f — 글자 · 차례 · 버튼 = VM 그대로', (WidgetTester t) async {
      final _Repo repo = await _pump(t, actions: _Actions());
      final RuleChangeGateVm vm = _vm(f);
      await _show(t, repo, vm);
      expect(find.text(vm.headline), findsOneWidget);
      expect(find.text(vm.asOf.label), findsOneWidget);
      for (final (String? s, String k) in <(String?, String)>[
        (vm.windowText, 'm59-window'),
        (vm.lockedLabel, 'm59-locked'),
        (vm.emptyLabel, 'm59-empty'),
      ]) {
        expect(find.byKey(Key(k)), s == null ? findsNothing : findsOneWidget);
      }
      expect(_cards(t), <String>[
        for (final RuleChangeCandidateRow c in vm.candidates)
          'm59-cand-${c.candidateId}',
        for (final RuleChangeQueueRow r in vm.rows) 'm59-row-${r.requestId}',
      ]);
      final bool act = vm.lockedLabel == null;
      for (final RuleChangeCandidateRow c in vm.candidates) {
        final Finder card = find.byKey(Key('m59-cand-${c.candidateId}'));
        expect(
          find.descendant(of: card, matching: find.text(c.label)),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('m59-req-open-${c.candidateId}')),
          act ? findsOneWidget : findsNothing,
        );
      }
      for (final RuleChangeQueueRow r in vm.rows) {
        final Finder card = find.byKey(Key('m59-row-${r.requestId}'));
        for (final String s in <String>[
          r.stateLabel,
          r.requestedText,
          r.coolingText,
        ]) {
          expect(
            find.descendant(of: card, matching: find.text(s)),
            findsOneWidget,
            reason: s,
          );
        }
        expect(
          find.byKey(Key('m59-approve-open-${r.requestId}')),
          act && r.approveLabel != null ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(Key('m59-cancel-${r.requestId}')),
          act && r.cancel != null ? findsOneWidget : findsNothing,
        );
      }
      expect(find.byType(Dialog), findsNothing);
    });
  }

  testWidgets('🔴 요청 — 후보 id 그대로 + 사람 글 원문 5칸 · 결과 = 엔진 글자(신뢰 시각 모름 원문)', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final _Repo repo = await _pump(t, actions: actions);
    final RuleChangeGateVm vm = _vm('first_candidate');
    await _show(t, repo, vm);
    final String id = vm.candidates.single.candidateId;
    expect(find.byKey(const Key('m59-reason')), findsNothing);
    await t.tap(find.byKey(Key('m59-req-open-$id')));
    await t.pump();
    for (final (String k, String v) in <(String, String)>[
      ('m59-reason', ' 첫 승인 '),
      ('m59-rollback', '이전 설정'),
      ('m59-rationale', '근거'),
      ('m59-expected', '기대'),
      ('m59-rule', '03 §6-4'),
    ]) {
      await t.enterText(find.byKey(Key(k)), v);
    }
    await t.tap(find.byKey(const Key('m59-req-submit')));
    await t.pump();
    await t.pump();
    expect(actions.requests, <RuleChangeRequestSubmission>[
      RuleChangeRequestSubmission(
        candidateId: id,
        reason: ' 첫 승인 ',
        rollbackMethod: '이전 설정',
        rationaleBefore: '근거',
        expectedOutcome: '기대',
        ruleCited: '03 §6-4',
      ),
    ]);
    expect(
      find.text('엔진 결과 RULE_CHANGE_REQUEST (TRUSTED_TIME_UNKNOWN)'),
      findsOneWidget,
    );
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('🔴 승인 — approveLabel 행만 · 골든 영향 · 승인자 · 제3자 → 요청 id 그대로', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final _Repo repo = await _pump(t, actions: actions);
    final RuleChangeGateVm vm = _vm('approvable');
    await _show(t, repo, vm);
    final String rid = vm.rows.single.requestId;
    await t.tap(find.byKey(Key('m59-approve-open-$rid')));
    await t.pump();
    await t.tap(find.byKey(const Key('m59-golden-no')));
    await t.enterText(find.byKey(const Key('m59-approver')), '발주자');
    await t.tap(find.byKey(const Key('m59-third')));
    await t.pump();
    await t.tap(find.byKey(const Key('m59-approve-submit')));
    await t.pump();
    await t.pump();
    expect(actions.approvals, <RuleChangeApprovalSubmission>[
      RuleChangeApprovalSubmission(
        requestId: rid,
        goldenChanged: false,
        approver: '발주자',
        thirdPartyNotified: true,
      ),
    ]);
    expect(find.text('엔진 결과 RULE_CHANGE_APPROVE'), findsOneWidget);
  });

  testWidgets('🔴 취소 — 행의 cancel 그대로(run id · args)', (WidgetTester t) async {
    final _Actions actions = _Actions();
    final _Repo repo = await _pump(t, actions: actions);
    final RuleChangeGateVm vm = _vm('cooling');
    await _show(t, repo, vm);
    final RuleChangeQueueRow r = vm.rows.single;
    await t.tap(find.byKey(Key('m59-cancel-${r.requestId}')));
    await t.pump();
    await t.pump();
    expect(actions.runs, <(SafetyActionId, Map<String, String>)>[
      (r.cancel!.id, r.cancel!.args),
    ]);
    expect(find.byKey(Key('m59-result-${r.requestId}')), findsOneWidget);
  });

  testWidgets('제출 자체 실패 = 정적 문장(접수증 아님)', (WidgetTester t) async {
    final _Repo repo = await _pump(t, actions: _Actions(fail: true));
    final RuleChangeGateVm vm = _vm('first_candidate');
    await _show(t, repo, vm);
    final String id = vm.candidates.single.candidateId;
    await t.tap(find.byKey(Key('m59-req-open-$id')));
    await t.pump();
    await t.tap(find.byKey(const Key('m59-req-submit')));
    await t.pump();
    await t.pump();
    expect(find.byKey(Key('m59-result-failed-$id')), findsOneWidget);
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
  });

  testWidgets('🔴 쓰기 주입 null(뷰어) = 요청 · 승인 · 취소 버튼 0', (WidgetTester t) async {
    final _Repo repo = await _pump(t);
    await _show(t, repo, _vm('first_candidate'));
    expect(find.byType(FilledButton), findsNothing);
    await _show(t, repo, _vm('approvable'));
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('🔴 잠김 = 동작이 실려 와도 화면은 동작 0(엔진이 비우는 것에 더한 이중 방어)', (
    WidgetTester t,
  ) async {
    final _Repo repo = await _pump(t, actions: _Actions());
    final RuleChangeGateVm first = _vm('first_candidate');
    final RuleChangeGateVm approvable = _vm('approvable');
    await _show(
      t,
      repo,
      first.copyWith(lockedLabel: '잠김', rows: approvable.rows),
    );
    expect(find.byKey(const Key('m59-locked')), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('읽기 실패 = 실패 문장 · 읽는 중 = 진행 표시', (WidgetTester t) async {
    final _Repo repo = await _pump(t, actions: _Actions());
    expect(find.byKey(const Key('m59-loading')), findsOneWidget);
    repo.c.addError(StateError('읽기 실패'));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('m59-read-failed')), findsOneWidget);
  });
}
