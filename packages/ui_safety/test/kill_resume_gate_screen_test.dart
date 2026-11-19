// M5-2 재개 게이트 화면(설계 13 §8 R179) — 읽기 모델 = 계약 픽스처(`m5/kill_resume_gate_*`).
//
// 🔴 골든 README 검사 ① — 단계가 실제로 순차다: 입력 칸 · 확인 버튼은 지금 받을 문항 하나에만 있고, 받을 문항이 없으면 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

KillResumeGateVm _vm(String name) => KillResumeGateVm.fromJson(
  ((jsonDecode(File('../domain_contracts/fixtures/m5/$name').readAsStringSync())
                  as Map<String, dynamic>)['rows']
              as List<dynamic>)
          .first
      as Map<String, dynamic>,
);

class _Repo implements KillSwitchGateRepository {
  final StreamController<KillResumeGateVm> c =
      StreamController<KillResumeGateVm>();

  @override
  Stream<KillSwitchScreenVm> watchKillSwitch() => const Stream.empty();

  @override
  Stream<KillResumeGateVm> watchResumeGate() => c.stream;

  Future<void> close() => c.close();
}

class _Pledge implements PledgeRepository {
  _Pledge(this.vm);

  final PledgeVm vm;

  @override
  Stream<PledgeVm> watchPledge() => Stream<PledgeVm>.value(vm);
}

class _Actions extends UnimplementedSafetyActions {
  final List<KillResumeItemSubmission> sent = <KillResumeItemSubmission>[];

  @override
  Future<SafetyActionResult> runKillResumeItem(
    KillResumeItemSubmission submission,
  ) async {
    sent.add(submission);
    return SafetyActionResult(
      actionRunId: 'a',
      id: SafetyActionId.killSwitchResume,
      level: UiLevel.info,
      headline: '${submission.itemNo}번 답을 받았습니다',
      retryable: false,
    );
  }
}

Future<_Repo> _pump(
  WidgetTester tester,
  SafetyActions? actions, {
  List<String> pledge = const <String>[],
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyKillSwitchGateRepositoryProvider.overrideWithValue(repo),
        safetyActionsProvider.overrideWithValue(actions),
        safetyPledgeRepositoryProvider.overrideWithValue(
          _Pledge(
            PledgeVm(
              lines: pledge,
              asOf: _vm('kill_resume_gate_ready.json').asOf,
            ),
          ),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: KillResumeGateScreen())),
    ),
  );
  return repo;
}

Future<void> _show(WidgetTester t, _Repo repo, KillResumeGateVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

void main() {
  testWidgets('준비 — 1번에만 칸 · 확인 하나 · 제출 = 1번 원문 · 결과 글자 그대로 · 서약 재생', (
    WidgetTester tester,
  ) async {
    final _Actions acts = _Actions();
    final _Repo repo = await _pump(
      tester,
      acts,
      pledge: const <String>['정한 날에만 산다', '하락에도 규칙을 지킨다', '멈춘 뒤엔 점검부터'],
    );
    final KillResumeGateVm vm = _vm('kill_resume_gate_ready.json');
    await _show(tester, repo, vm);
    expect(find.text(vm.readinessLabel), findsOneWidget);
    expect(find.text(vm.cooldown!.valueText), findsOneWidget);
    expect(find.byKey(const Key('m52-confirm')), findsOneWidget);
    expect(find.byKey(const Key('m52-text')), findsOneWidget);
    expect(find.byKey(const Key('m52-emotion')), findsNothing);
    expect(find.text('정한 날에만 산다'), findsOneWidget);
    for (final KillResumeItemRow r in vm.items) {
      if (r.replayText != null) {
        expect(find.text(r.replayText!), findsOneWidget);
      }
    }
    await tester.enterText(find.byKey(const Key('m52-text')), '지금도 멈춤');
    await tester.tap(find.byKey(const Key('m52-confirm')));
    await tester.pump();
    await tester.pump();
    expect(acts.sent.single.itemNo, 1);
    expect(acts.sent.single.text, '지금도 멈춤');
    expect(acts.sent.single.acknowledged, isFalse, reason: '확인 문항 = 5 · 6번만');
    expect(find.text('1번 답을 받았습니다'), findsOneWidget);
  });

  testWidgets('진행 중(4번 차례) — 고르기만 · 앞 문항 칸 0 · 제출 = 고른 값', (
    WidgetTester tester,
  ) async {
    final _Actions acts = _Actions();
    final _Repo repo = await _pump(tester, acts);
    final KillResumeGateVm vm = _vm('kill_resume_gate_in_progress.json');
    await _show(tester, repo, vm);
    expect(find.byKey(const Key('m52-text')), findsNothing);
    expect(find.byKey(const Key('m52-confirm')), findsOneWidget);
    expect(find.text(vm.items[0].answeredText!), findsOneWidget);
    await tester.tap(find.byKey(const Key('m52-choice-4-충족')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m52-confirm')));
    await tester.pump();
    expect(acts.sent.single.itemNo, 4);
    expect(acts.sent.single.condition, KillResumeCondition.met);
  });

  testWidgets('받을 문항 없음(대기 · 미충족 · 확인 전 · 잠김 · 꺼짐) = 칸 · 확인 0 · 막힘 글자 그대로', (
    WidgetTester tester,
  ) async {
    final _Repo repo = await _pump(tester, _Actions());
    for (final String f in <String>[
      'kill_resume_gate_waiting.json',
      'kill_resume_gate_condition_unmet.json',
      'kill_resume_gate_not_confirmed.json',
      'kill_resume_gate_locked.json',
      'kill_resume_gate_off.json',
      'kill_resume_gate_time_unknown.json',
    ]) {
      final KillResumeGateVm vm = _vm(f);
      await _show(tester, repo, vm);
      expect(find.byKey(const Key('m52-confirm')), findsNothing, reason: f);
      if (vm.blockedText != null) {
        expect(find.text(vm.blockedText!), findsOneWidget, reason: f);
      }
      if (vm.lockedLabel != null) {
        expect(find.text(vm.lockedLabel!), findsOneWidget, reason: f);
      }
    }
  });

  testWidgets('안전 동작 없음 = 확인 0', (WidgetTester tester) async {
    final _Repo repo = await _pump(tester, null);
    await _show(tester, repo, _vm('kill_resume_gate_ready.json'));
    expect(find.byKey(const Key('m52-confirm')), findsNothing);
  });

  testWidgets('첫 값 전 오류 = 읽기 실패 문장', (WidgetTester tester) async {
    final _Repo repo2 = await _pump(tester, _Actions());
    repo2.c.addError(StateError('x'));
    await tester.pump();
    await tester.pump();
    expect(find.text(SafetyLabels.resumeGateReadFailed), findsOneWidget);
  });
}
