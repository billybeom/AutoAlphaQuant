// X5 정정 마법사(설계 13 §8 R227 · 01 §41 K247~K263) — 읽기 모델 = 계약 픽스처(`x5/repair_*`).
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 동작 = 엔진이 준 것만(단계 · 아무것도 안 하기 = `run` 그대로 · 저널 · 정정 · 새 기준점 = 제출
//    DTO 3) · 쓰기 주입이 없으면 컨트롤 0 · 결과 = 엔진 글자 · 제출 실패 = 정적 문장 · 확인 대화 0 · 대상 id = 라우트 인자 그대로.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

RepairWizardVm _vm(String name) => RepairWizardVm.fromJson(
  ((jsonDecode(
                File('../domain_contracts/fixtures/x5/$name.json')
                    .readAsStringSync(),
              ) as Map<String, dynamic>)['rows']
              as List<dynamic>)
          .single
      as Map<String, dynamic>,
);

class _Repo implements RepairWizardRepository {
  final StreamController<RepairWizardVm> vm =
      StreamController<RepairWizardVm>();
  final List<String?> asked = <String?>[];

  @override
  Stream<RepairWizardVm> watchRepair({String? targetId}) {
    asked.add(targetId);
    return vm.stream;
  }

  /// 🔴 기다리지 않는다 — 듣는 쪽이 없던 흐름의 close() 는 끝나지 않는다.
  void close() => unawaited(vm.close());
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.fail = false});

  final bool fail;
  final List<Object> calls = <Object>[];

  SafetyActionResult _ok(SafetyActionId id) {
    if (fail) throw StateError('submit failed');
    return SafetyActionResult(
      actionRunId: 'run-1',
      id: id,
      level: UiLevel.blocked,
      headline: 'engine headline',
      reasonCode: 'REPAIR_DELTA_CHANGED',
      retryable: false,
    );
  }

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    calls.add((id, args));
    return _ok(id);
  }

  @override
  Future<SafetyActionResult> runInterventionJournal(
    InterventionJournalSubmission submission,
  ) async {
    calls.add(submission);
    return _ok(SafetyActionId.interventionJournal);
  }

  @override
  Future<SafetyActionResult> runRepairCorrect(
    RepairCorrectSubmission submission,
  ) async {
    calls.add(submission);
    return _ok(SafetyActionId.repairCorrect);
  }

  @override
  Future<SafetyActionResult> runRepairBaseline(
    RepairBaselineSubmission submission,
  ) async {
    calls.add(submission);
    return _ok(SafetyActionId.repairBaseline);
  }
}

Future<(_Repo, _Links)> _pump(
  WidgetTester t, {
  String? targetId,
  SafetyActions? actions,
}) async {
  t.view.physicalSize = const Size(800, 4000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final _Links links = _Links();
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyRepairWizardRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
        safetyActionsProvider.overrideWithValue(actions),
      ],
      child: MaterialApp(
        home: Scaffold(body: RepairWizardScreen(targetId: targetId)),
      ),
    ),
  );
  return (repo, links);
}

Future<void> _show(WidgetTester t, _Repo repo, String name) async {
  repo.vm.add(_vm(name));
  await t.pump();
  await t.pump();
}

String _text(WidgetTester t, String key) =>
    (t.widget(find.byKey(Key(key))) as Text).data!;

bool _enabled(WidgetTester t, String key) =>
    (t.widget(find.byKey(Key(key))) as ButtonStyleButton).onPressed != null;

void main() {
  testWidgets('읽는 중 · 읽기 실패 = 정적 문장 · 대상 id = 라우트 인자 그대로', (
    WidgetTester t,
  ) async {
    final (_Repo repo, _) = await _pump(t, targetId: 'ld-abc');
    expect(repo.asked, <String?>['ld-abc']);
    expect(find.byKey(const Key('x5-loading')), findsOneWidget);
    repo.vm.addError(StateError('x'));
    await t.pump();
    await t.pump();
    expect(find.text(SafetyLabels.repairReadFailed), findsOneWidget);
  });

  testWidgets('허브 — 대상 링크 = 받은 차례 · 누르면 엔진 링크 그대로 · 이력 링크 · 동작 0', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _Links links) = await _pump(t, actions: actions);
    expect(repo.asked, <String?>[null]);
    await _show(t, repo, 'repair_hub_targets');
    final RepairWizardVm vm = _vm('repair_hub_targets');
    expect(_text(t, 'x5-headline'), vm.headline);
    expect(find.byKey(const Key('x5-target-0')), findsOneWidget);
    expect(find.byKey(const Key('x5-target-1')), findsOneWidget);
    expect(find.byKey(const Key('x5-target-2')), findsNothing);
    await t.tap(find.byKey(const Key('x5-target-1')));
    await t.tap(find.byKey(const Key('x5-history')));
    expect(links.opened, <String>[
      vm.targetLinks[1].deepLink,
      vm.historyLink!.deepLink,
    ]);
    expect(find.byKey(const Key('x5-do-nothing')), findsNothing);
    expect(find.byKey(const Key('x5-stage-0')), findsNothing);
    expect(find.byKey(const Key('x5-origin-0')), findsNothing);
    expect(actions.calls, isEmpty);
  });

  testWidgets('빈 허브 = 끝 문장 · 대상 0', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    await _show(t, repo, 'repair_hub_empty');
    expect(_text(t, 'x5-done'), _vm('repair_hub_empty').doneLabel);
    expect(find.byKey(const Key('x5-target-0')), findsNothing);
  });

  testWidgets(
    'diff 기본 — 근거 행 · 아무것도 안 하기 = 채운 버튼 · 누르면 run(엔진 id · args) · 결과 = 엔진 글자 + 코드',
    (WidgetTester t) async {
      final _Actions actions = _Actions();
      final (_Repo repo, _) = await _pump(
        t,
        targetId: 'ld_0001',
        actions: actions,
      );
      await _show(t, repo, 'repair_diff_default');
      final RepairWizardVm vm = _vm('repair_diff_default');
      expect(find.byKey(const Key('x5-diff')), findsOneWidget);
      expect(find.text(vm.diff!.deltaLabel), findsOneWidget);
      expect(_text(t, 'x5-line-0'), vm.targetLines.single);
      expect(_text(t, 'x5-notice'), vm.noticeText);
      expect(
        t.widget(find.byKey(const Key('x5-do-nothing'))),
        isA<FilledButton>(),
        reason: 'doNothingDefault = 처음 고른 칸',
      );
      // 단계 다섯 · 1단계 동작 하나 · 나머지 0.
      expect(find.byKey(const Key('x5-stage-4')), findsOneWidget);
      expect(find.byKey(const Key('x5-stage-0-act-0')), findsOneWidget);
      expect(find.byKey(const Key('x5-stage-1-act-0')), findsNothing);
      expect(_text(t, 'x5-stage-0-state'), vm.stages.first.stateLabel);
      // 원인 칩 = 받은 차례(정정 폼 없음 = 확인 없음).
      for (int i = 0; i < vm.origins.length; i++) {
        expect(
          (t.widget(find.byKey(Key('x5-origin-$i'))) as ChoiceChip).label,
          isA<Text>().having((Text x) => x.data, 'data', vm.origins[i].label),
        );
      }
      expect(find.byKey(const Key('x5-correct-submit')), findsNothing);
      expect(find.byKey(const Key('x5-baseline-submit')), findsNothing);
      await t.tap(find.byKey(const Key('x5-do-nothing')));
      await t.pump();
      await t.pump();
      // 🔴 record 안에 Map 을 넣으면 == 가 동일성이라 칸마다 따로 본다.
      final (SafetyActionId id, Map<String, String> args) =
          actions.calls.single as (SafetyActionId, Map<String, String>);
      expect(id, SafetyActionId.repairAccept);
      expect(args, <String, String>{'diff_id': 'ld_0001'});
      expect(_text(t, 'x5-result'), 'engine headline (REPAIR_DELTA_CHANGED)');
      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets('단계 버튼 = 엔진이 준 SafetyActionCall 그대로 run', (WidgetTester t) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: actions,
    );
    await _show(t, repo, 'repair_diff_default');
    final SafetyActionCall c = _vm('repair_diff_default')
        .stages
        .first
        .actions
        .single;
    expect(
      (t.widget(
        find.byKey(const Key('x5-stage-0-act-0')),
      ) as OutlinedButton).child,
      isA<Text>().having((Text x) => x.data, 'data', c.label),
    );
    await t.tap(find.byKey(const Key('x5-stage-0-act-0')));
    await t.pump();
    final (SafetyActionId id, Map<String, String> args) =
        actions.calls.single as (SafetyActionId, Map<String, String>);
    expect(id, c.id);
    expect(args, c.args);
  });

  testWidgets('3단계 — 저널 세 칸 원문 그대로 runInterventionJournal · 기본 칸 아님 = 테두리 버튼', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: actions,
    );
    await _show(t, repo, 'repair_diff_stage3');
    expect(
      t.widget(find.byKey(const Key('x5-do-nothing'))),
      isA<OutlinedButton>(),
    );
    await t.enterText(find.byKey(const Key('x5-journal-rationale')), ' a ');
    await t.enterText(find.byKey(const Key('x5-journal-expected')), 'b');
    await t.enterText(find.byKey(const Key('x5-journal-rule')), '');
    await t.tap(find.byKey(const Key('x5-journal-submit')));
    await t.pump();
    expect(actions.calls, <Object>[
      const InterventionJournalSubmission(
        rationaleBefore: ' a ',
        expectedOutcome: 'b',
        ruleCited: '',
      ),
    ]);
  });

  testWidgets('실행 창 — 원인 · 체결 고르기 전 = 정정 꺼짐 · 다시 적기 원문 네 칸 · 무효 = 네 칸 비움', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: actions,
    );
    await _show(t, repo, 'repair_diff_ready');
    final RepairWizardVm vm = _vm('repair_diff_ready');
    expect(_text(t, 'x5-correction-notice'), vm.correction!.noticeText);
    expect(_enabled(t, 'x5-correct-submit'), isFalse);
    await t.tap(find.byKey(const Key('x5-origin-1')));
    await t.pump();
    expect(_enabled(t, 'x5-correct-submit'), isFalse, reason: '체결 미선택');
    await t.tap(find.byKey(const Key('x5-fill-0')));
    await t.pump();
    expect(_enabled(t, 'x5-correct-submit'), isTrue);
    await t.enterText(find.byKey(const Key('x5-quantity')), '9');
    await t.enterText(find.byKey(const Key('x5-price')), '9,850');
    await t.enterText(find.byKey(const Key('x5-commission')), 'x');
    await t.enterText(find.byKey(const Key('x5-tax')), '0');
    await t.tap(find.byKey(const Key('x5-correct-submit')));
    await t.pump();
    await t.tap(find.byKey(const Key('x5-void')));
    await t.pump();
    expect(find.byKey(const Key('x5-quantity')), findsNothing);
    await t.tap(find.byKey(const Key('x5-correct-submit')));
    await t.pump();
    expect(actions.calls, <Object>[
      RepairCorrectSubmission(
        targetId: 'ld_0001',
        fillRef: vm.correction!.fills.single.fillRef,
        originCode: vm.origins[1].originCode,
        voidFill: false,
        quantityText: '9',
        priceText: '9,850',
        commissionText: 'x',
        taxText: '0',
      ),
      RepairCorrectSubmission(
        targetId: 'ld_0001',
        fillRef: vm.correction!.fills.single.fillRef,
        originCode: vm.origins[1].originCode,
        voidFill: true,
      ),
    ]);
  });

  testWidgets('🔴 고른 체결 = VM 이 다시 와 차례가 바뀌어도 그 체결 · 사라지면 꺼짐', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: actions,
    );
    final RepairWizardVm vm = _vm('repair_diff_ready');
    const RepairFillChoice older = RepairFillChoice(
      fillRef: 'ex_old',
      label: 'old',
    );
    final RepairFillChoice mine = vm.correction!.fills.single;
    repo.vm.add(
      vm.copyWith(
        correction: vm.correction!.copyWith(
          fills: <RepairFillChoice>[mine, older],
        ),
      ),
    );
    await t.pump();
    await t.pump();
    await t.tap(find.byKey(const Key('x5-origin-0')));
    await t.tap(find.byKey(const Key('x5-fill-0')));
    await t.tap(find.byKey(const Key('x5-void')));
    await t.pump();
    // 새 체결이 앞에 끼어 차례가 바뀐다.
    repo.vm.add(
      vm.copyWith(
        correction: vm.correction!.copyWith(
          fills: <RepairFillChoice>[older, mine],
        ),
      ),
    );
    await t.pump();
    await t.pump();
    await t.tap(find.byKey(const Key('x5-correct-submit')));
    await t.pump();
    expect(
      (actions.calls.single as RepairCorrectSubmission).fillRef,
      mine.fillRef,
    );
    // 고른 체결이 사라지면 고름이 풀린다.
    repo.vm.add(
      vm.copyWith(
        correction: vm.correction!.copyWith(fills: <RepairFillChoice>[older]),
      ),
    );
    await t.pump();
    await t.pump();
    expect(_enabled(t, 'x5-correct-submit'), isFalse);
  });

  testWidgets('새 기준점 — 원인 고르기 전 꺼짐 · 대상 id = 라우트 인자 · 아무것도 안 하기 0', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'li-route',
      actions: actions,
    );
    await _show(t, repo, 'repair_integrity_ready');
    expect(find.byKey(const Key('x5-do-nothing')), findsNothing);
    expect(find.byKey(const Key('x5-diff')), findsNothing);
    expect(_enabled(t, 'x5-baseline-submit'), isFalse);
    await t.tap(find.byKey(const Key('x5-origin-0')));
    await t.pump();
    await t.tap(find.byKey(const Key('x5-baseline-submit')));
    await t.pump();
    expect(actions.calls, <Object>[
      RepairBaselineSubmission(
        targetId: 'li-route',
        originCode: _vm('repair_integrity_ready').origins.first.originCode,
      ),
    ]);
  });

  testWidgets('경계 X1 = 안내 링크만(동작 · 폼 0)', (WidgetTester t) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _Links links) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: actions,
    );
    await _show(t, repo, 'repair_boundary_x1');
    expect(find.byKey(const Key('x5-do-nothing')), findsNothing);
    expect(find.byKey(const Key('x5-stage-0')), findsNothing);
    expect(find.byKey(const Key('x5-origin-0')), findsNothing);
    await t.tap(find.byKey(const Key('x5-x1-guide')));
    expect(links.opened, <String>[
      _vm('repair_boundary_x1').x1GuideLink!.deepLink,
    ]);
  });

  testWidgets('🔴 쓰기 주입 null(뷰어) = 버튼 · 폼 · 칩 0(글자 · 단계 줄만)', (
    WidgetTester t,
  ) async {
    final (_Repo repo, _) = await _pump(t, targetId: 'ld_0001');
    await _show(t, repo, 'repair_diff_ready');
    expect(find.byKey(const Key('x5-stage-4')), findsOneWidget);
    for (final String k in <String>[
      'x5-do-nothing',
      'x5-origin-0',
      'x5-correction',
      'x5-correct-submit',
      'x5-stage-0-act-0',
    ]) {
      expect(find.byKey(Key(k)), findsNothing, reason: k);
    }
    repo.vm.add(_vm('repair_diff_stage3'));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('x5-journal-submit')), findsNothing);
  });

  testWidgets('제출 자체 실패 = 정적 문장(접수증 아님)', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(
      t,
      targetId: 'ld_0001',
      actions: _Actions(fail: true),
    );
    await _show(t, repo, 'repair_diff_default');
    await t.tap(find.byKey(const Key('x5-do-nothing')));
    await t.pump();
    await t.pump();
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(const Key('x5-result')), findsNothing);
  });
}
