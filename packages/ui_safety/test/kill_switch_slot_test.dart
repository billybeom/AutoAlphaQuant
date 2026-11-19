// 셸 킬스위치 자리 위젯(설계 13 §8 R182 · 01 §34 K152) — 읽기 모델 = 계약 픽스처(`m5/kill_switch_*`).
//
// 🔴 지키는 것: 꺼짐 = 발동 버튼(화면과 같은 위젯 · 확인 대화 0 · 글자 = 엔진 그대로 · 한 줄 말줄임 + 전체 글자 툴팁) ·
//    켜짐 = 상태 칩 → M5-1 화면 · 잠김이어도 버튼은 남는다 · 읽는 중 · 읽기 실패 · 명령 주입 없음 = 그리지 않음 ·
//    좁은 앱바(390)에서 넘침 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('../domain_contracts/fixtures/m5/$name').readAsStringSync())
        as Map<String, dynamic>;

KillSwitchScreenVm _vm(String name) => KillSwitchScreenVm.fromJson(
  (_fixture(name)['rows'] as List<dynamic>).first as Map<String, dynamic>,
);

CommandReceipt _receipt(CommandState s) =>
    (_fixture('kill_switch_activate_receipts.json')['rows'] as List<dynamic>)
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
  _Api({this.fail = false});

  final bool fail;
  int activations = 0;

  @override
  Future<CommandReceipt> activateKillSwitch() async {
    activations++;
    if (fail) throw StateError('offline');
    return _receipt(CommandState.requested);
  }
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

/// 좁은 폰(390) 앱바 끝에 자리를 둔다 — 셸(`s01-kill-slot`)과 같은 꼴.
Future<(_Repo, _Links)> _pump(WidgetTester tester, CommandApi? api) async {
  tester.view.physicalSize = const Size(390, 844);
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
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('홈 · 운영 화면 제목'),
            actions: const <Widget>[KillSwitchSlot()],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    ),
  );
  return (repo, links);
}

Future<void> _emit(WidgetTester tester, _Repo repo, String name) async {
  repo.c.add(_vm(name));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('꺼짐 = 발동 버튼(엔진 글자 · 툴팁 전체) · 한 번 = 발동 · 확인 대화 0 · 접수증 = 스낵바', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api();
    final (_Repo repo, _Links links) = await _pump(tester, api);
    expect(find.byKey(const Key('ks-slot-none')), findsOneWidget);
    await _emit(tester, repo, 'kill_switch_off.json');

    final KillSwitchScreenVm off = _vm('kill_switch_off.json');
    final Finder button = find.byKey(const Key('ks-slot-activate'));
    expect(button, findsOneWidget);
    expect(find.byKey(const Key('m51-activate')), findsNothing);
    expect(
      find.descendant(of: button, matching: find.text(off.activateLabel!)),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is Tooltip && w.message == off.activateLabel,
      ),
      findsOneWidget,
    );
    final Text label = tester.widget<Text>(
      find.descendant(of: button, matching: find.byType(Text)),
    );
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(button).width, lessThanOrEqualTo(176));
    // 끝 여백 8 — 앱바 끝(화면 가장자리)에 붙지 않는다.
    expect(tester.getTopRight(button).dx, lessThanOrEqualTo(390 - 8));
    expect(tester.takeException(), isNull);

    await tester.tap(button);
    await tester.pump();
    await tester.pump();
    expect(api.activations, 1);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byKey(const Key('ks-slot-receipt')), findsOneWidget);
    expect(
      find.text(_receipt(CommandState.requested).stateLabel),
      findsOneWidget,
    );
    expect(links.opened, isEmpty);
  });

  testWidgets('접수 실패 = 스낵바 «접수되지 않았습니다» 꼴 · 버튼은 그대로', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api(fail: true);
    final (_Repo repo, _) = await _pump(tester, api);
    await _emit(tester, repo, 'kill_switch_off.json');
    await tester.tap(find.byKey(const Key('ks-slot-activate')));
    await tester.pump();
    await tester.pump();
    expect(api.activations, 1);
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(const Key('ks-slot-activate')), findsOneWidget);
  });

  testWidgets('켜짐 = 상태 칩(엔진 글자) → M5-1 화면 링크 · 발동 버튼 0', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api();
    final (_Repo repo, _Links links) = await _pump(tester, api);
    for (final String f in <String>[
      'kill_switch_active_unrecorded.json',
      'kill_switch_recorded_waiting.json',
      'kill_switch_recorded_ready.json',
      'kill_switch_active_locked.json',
    ]) {
      await _emit(tester, repo, f);
      final KillSwitchScreenVm vm = _vm(f);
      expect(vm.activateLabel, isNull, reason: f);
      final Finder chip = find.byKey(const Key('ks-slot-active'));
      expect(chip, findsOneWidget, reason: f);
      expect(
        find.descendant(of: chip, matching: find.text(vm.stateLabel)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ks-slot-activate')), findsNothing);
      expect(tester.getSize(chip).width, lessThanOrEqualTo(176));
      expect(tester.getTopRight(chip).dx, lessThanOrEqualTo(390 - 8));
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byKey(const Key('ks-slot-active')));
    await tester.pump();
    expect(links.opened, <String>[AppRoutes.m5KillSwitch]);
    expect(api.activations, 0);
  });

  testWidgets('잠김(운영 등급 생체)이어도 꺼짐이면 발동 버튼은 남는다', (WidgetTester tester) async {
    final (_Repo repo, _) = await _pump(tester, _Api());
    final KillSwitchScreenVm locked = _vm('kill_switch_locked.json');
    expect(locked.lockedLabel, isNotNull);
    expect(locked.activateLabel, isNotNull);
    await _emit(tester, repo, 'kill_switch_locked.json');
    expect(find.byKey(const Key('ks-slot-activate')), findsOneWidget);
  });

  testWidgets('명령 주입 없음(기기 id 없음) = 버튼 부재', (WidgetTester tester) async {
    final (_Repo repo, _) = await _pump(tester, null);
    await _emit(tester, repo, 'kill_switch_off.json');
    expect(find.byKey(const Key('ks-slot-activate')), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('첫 읽기 실패 = 그리지 않음(실패 문장 = M5-1 화면 몫)', (
    WidgetTester tester,
  ) async {
    final (_Repo repo, _) = await _pump(tester, _Api());
    repo.c.addError(StateError('read failed'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('ks-slot-none')), findsOneWidget);
    expect(find.byKey(const Key('ks-slot-activate')), findsNothing);
    expect(find.byKey(const Key('ks-slot-active')), findsNothing);
  });
}
