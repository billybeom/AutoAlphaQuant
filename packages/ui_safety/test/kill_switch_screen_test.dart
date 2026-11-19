// M5-1 킬스위치 화면(설계 13 §8 R178) — 읽기 모델 = 계약 픽스처(`m5/kill_switch_*`) · 접수증 = 픽스처 행.
//
// 🔴 골든 README 세 검사 중 둘을 위젯 시험으로 지킨다: 발동에 확인 대화가 없다 · 시각 글자는 VM 그대로(화면 계산 0).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

Map<String, dynamic> _row(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/m5/$name')
                      .readAsStringSync(),
                ) as Map<String, dynamic>)['rows']
                as List<dynamic>)
            .first
        as Map<String, dynamic>;

KillSwitchScreenVm _vm(String name) => KillSwitchScreenVm.fromJson(_row(name));

CommandReceipt _receipt(String name, CommandState s) =>
    ((jsonDecode(
              File('../domain_contracts/fixtures/m5/$name').readAsStringSync(),
            ) as Map<String, dynamic>)['rows']
            as List<dynamic>)
        .map((dynamic r) => CommandReceipt.fromJson(r as Map<String, dynamic>))
        .firstWhere((CommandReceipt r) => r.state == s);

class _Repo implements KillSwitchGateRepository {
  final StreamController<KillSwitchScreenVm> c =
      StreamController<KillSwitchScreenVm>();

  @override
  Stream<KillSwitchScreenVm> watchKillSwitch() => c.stream;

  @override
  Stream<KillResumeGateVm> watchResumeGate() => const Stream.empty();

  Future<void> close() => c.close();
}

class _Api extends UnimplementedCommandApi {
  int activations = 0;
  final List<KillChecklistSubmission> sent = <KillChecklistSubmission>[];

  @override
  Future<CommandReceipt> activateKillSwitch() async {
    activations++;
    return _receipt(
      'kill_switch_activate_receipts.json',
      CommandState.executed,
    );
  }

  @override
  Future<CommandReceipt> confirmKillChecklist(
    KillChecklistSubmission submission,
  ) async {
    sent.add(submission);
    return _receipt('kill_checklist_receipts.json', CommandState.executed);
  }
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

Future<(_Repo, _Links)> _pump(WidgetTester tester, CommandApi? api) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final _Repo repo = _Repo();
  final _Links links = _Links();
  addTearDown(repo.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyKillSwitchGateRepositoryProvider.overrideWithValue(repo),
        safetyKillCommandApiProvider.overrideWithValue(api),
        safetyLinkOpenerProvider.overrideWithValue(links),
      ],
      child: const MaterialApp(home: Scaffold(body: KillSwitchScreen())),
    ),
  );
  return (repo, links);
}

Future<void> _show(
  WidgetTester tester,
  _Repo repo,
  KillSwitchScreenVm vm,
) async {
  repo.c.add(vm);
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('꺼짐 — 버튼 한 번 = 발동 한 번 · 확인 대화 0 · 접수증 글자 그대로 · 경로 3 · 폼 0', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api();
    final (_Repo repo, _) = await _pump(tester, api);
    final KillSwitchScreenVm vm = _vm('kill_switch_off.json');
    await _show(tester, repo, vm);
    expect(find.text(vm.stateLabel), findsOneWidget);
    for (final String l in vm.pathLines) {
      expect(find.text(l), findsOneWidget);
    }
    expect(find.byKey(const Key('m51-form')), findsNothing);
    await tester.tap(find.byKey(const Key('m51-activate')));
    await tester.pump();
    await tester.pump();
    expect(api.activations, 1);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text(
        _receipt(
          'kill_switch_activate_receipts.json',
          CommandState.executed,
        ).stateLabel,
      ),
      findsOneWidget,
    );
  });

  testWidgets('명령 창구 없음(기기 id 없음) = 발동 버튼 · 제출 부재', (
    WidgetTester tester,
  ) async {
    final (_Repo repo, _) = await _pump(tester, null);
    await _show(tester, repo, _vm('kill_switch_off.json'));
    expect(find.byKey(const Key('m51-activate')), findsNothing);
    await _show(tester, repo, _vm('kill_switch_active_unrecorded.json'));
    expect(find.byKey(const Key('m51-form')), findsOneWidget);
    expect(find.byKey(const Key('m51-record-submit')), findsNothing);
  });

  testWidgets('켜짐 · 기록 전 — 취소 보고 · 폼 칸 → 제출 꼴 그대로(카드 정적 대응) · 접수증 · 버튼 부재', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api();
    final (_Repo repo, _) = await _pump(tester, api);
    final KillSwitchScreenVm vm = _vm('kill_switch_active_unrecorded.json');
    await _show(tester, repo, vm);
    expect(find.byKey(const Key('m51-activate')), findsNothing);
    expect(find.text(vm.cancelHeadline!), findsOneWidget);
    expect(find.text(vm.checklistStateLabel!), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('m51-rule-action')),
      '신규 진입 멈춤',
    );
    await tester.tap(find.byKey(const Key('m51-choice-2-감정')));
    await tester.enterText(find.byKey(const Key('m51-emotion')), '불안');
    await tester.enterText(find.byKey(const Key('m51-intensity')), '7');
    await tester.enterText(find.byKey(const Key('m51-sleep')), '4');
    await tester.ensureVisible(find.byKey(const Key('m51-scenario-none')));
    await tester.tap(find.byKey(const Key('m51-scenario-none')));
    await tester.enterText(
      find.byKey(const Key('m51-resume-condition')),
      '뉴스 정리',
    );
    await tester.ensureVisible(find.byKey(const Key('m51-choice-5-전량 청산')));
    await tester.tap(find.byKey(const Key('m51-choice-5-전량 청산')));
    for (final String k in <String>[
      'm51-ack-queried',
      'm51-ack-cancelled',
      'm51-ack-zero',
    ]) {
      await tester.ensureVisible(find.byKey(Key(k)));
      await tester.tap(find.byKey(Key(k)));
    }
    await tester.enterText(find.byKey(const Key('m51-note')), '한 줄');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('m51-record-submit')));
    await tester.tap(find.byKey(const Key('m51-record-submit')));
    await tester.pump();
    await tester.pump();
    final KillChecklistSubmission s = api.sent.single;
    expect(s.ruleAction, '신규 진입 멈춤');
    expect(s.reasonKind, KillActivationReason.emotion);
    expect((s.emotion, s.intensity, s.sleepHours), ('불안', '7', '4'));
    expect(s.scenarioNone, isTrue);
    expect(s.resumeCondition, '뉴스 정리');
    expect(s.scope, KillActivationScope.liquidateAll);
    expect(
      (s.openOrdersQueried, s.openOrdersCancelled, s.remainingCountZero),
      (true, true, true),
    );
    expect(s.note, '한 줄');
    expect(
      find.text(
        _receipt(
          'kill_checklist_receipts.json',
          CommandState.executed,
        ).stateLabel,
      ),
      findsOneWidget,
    );
    final FilledButton submit = tester.widget<FilledButton>(
      find.byKey(const Key('m51-record-submit')),
    );
    expect(submit.onPressed, isNull, reason: '실행됨 = 다시 내지 않는다');
  });

  testWidgets('기록 뒤 — 해제 시각 줄 · 게이트 링크 = 셸 링크 · 폼 0 · 해제 버튼 0', (
    WidgetTester tester,
  ) async {
    final (_Repo repo, _Links links) = await _pump(tester, _Api());
    final KillSwitchScreenVm vm = _vm('kill_switch_recorded_waiting.json');
    await _show(tester, repo, vm);
    expect(find.text(vm.etaText!), findsOneWidget);
    expect(find.byKey(const Key('m51-form')), findsNothing);
    expect(find.byKey(const Key('m51-activate')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('m51-gate')));
    await tester.tap(find.byKey(const Key('m51-gate')));
    expect(links.opened, <String>[AppRoutes.m5ReleaseGate]);
  });

  testWidgets('잠김 = 잠김 줄 · 읽기 실패 = 전용 문장(꺼짐으로 그리지 않는다)', (
    WidgetTester tester,
  ) async {
    final (_Repo repo, _) = await _pump(tester, _Api());
    final KillSwitchScreenVm locked = _vm('kill_switch_locked.json');
    await _show(tester, repo, locked);
    expect(find.text(locked.lockedLabel!), findsOneWidget);
    expect(
      find.byKey(const Key('m51-activate')),
      findsOneWidget,
      reason: 'K150',
    );
    repo.c.addError(StateError('x'));
    await tester.pump();
    await tester.pump();
    expect(find.text(locked.lockedLabel!), findsOneWidget, reason: '마지막 값 유지');
  });

  testWidgets('첫 값 전 오류 = 읽기 실패 문장', (WidgetTester tester) async {
    final (_Repo repo, _) = await _pump(tester, _Api());
    repo.c.addError(StateError('x'));
    await tester.pump();
    await tester.pump();
    expect(find.text(SafetyLabels.killSwitchReadFailed), findsOneWidget);
  });
}
