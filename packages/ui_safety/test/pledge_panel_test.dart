// M5-8 서약 칸(설계 13 §8 R157) — 읽기 모델 · 결과 = 계약 픽스처(`m5/pledge_*` · `m5/safety_action_results`)의 행.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

List<Map<String, dynamic>> _rows(String name) {
  final Map<String, dynamic> j = jsonDecode(
    File('../domain_contracts/fixtures/m5/$name').readAsStringSync(),
  ) as Map<String, dynamic>;
  return <Map<String, dynamic>>[
    for (final Object? r in j['rows'] as List<Object?>)
      r! as Map<String, dynamic>,
  ];
}

PledgeVm _vm(String name) => PledgeVm.fromJson(_rows(name).single);

SafetyActionResult _result(SafetyActionId id, String? code) =>
    _rows('safety_action_results.json')
        .map(SafetyActionResult.fromJson)
        .firstWhere(
          (SafetyActionResult r) => r.id == id && r.reasonCode == code,
        );

class _Repo implements PledgeRepository {
  final StreamController<PledgeVm> c = StreamController<PledgeVm>();

  @override
  Stream<PledgeVm> watchPledge() => c.stream;

  Future<void> close() => c.close();
}

class _Actions extends UnimplementedSafetyActions {
  _Actions(this.reply);

  final Future<SafetyActionResult> Function() reply;
  final List<PledgeSubmission> sent = <PledgeSubmission>[];

  @override
  Future<SafetyActionResult> runPledge(PledgeSubmission submission) {
    sent.add(submission);
    return reply();
  }
}

Future<_Repo> _pump(WidgetTester tester, SafetyActions? actions) async {
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyPledgeRepositoryProvider.overrideWithValue(repo),
        safetyActionsProvider.overrideWithValue(actions),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: PledgePanel())),
      ),
    ),
  );
  return repo;
}

Future<void> _emit(WidgetTester tester, _Repo repo, PledgeVm vm) async {
  repo.c.add(vm);
  await tester.pump();
  await tester.pump();
}

TextField _field(WidgetTester tester, int i) =>
    tester.widget<TextField>(find.byKey(ValueKey<String>('m5-8-input-$i')));

FilledButton _save(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const Key('m5-8-save')));

void main() {
  testWidgets('🔴 읽는 중 = 진행 막대 · 읽기 실패 = 정적 글자(빈 서약과 다르다)', (
    WidgetTester tester,
  ) async {
    final _Repo repo = await _pump(
      tester,
      _Actions(() async => throw StateError('x')),
    );
    expect(find.byKey(const Key('m5-8-loading')), findsOneWidget);
    repo.c.addError(StateError('읽기 실패'));
    await tester.pump();
    await tester.pump();
    expect(find.text(SafetyLabels.pledgeReadFailed), findsOneWidget);
    expect(find.byKey(const Key('m5-8-form')), findsNothing);
  });

  testWidgets('🔴 첫 판 없음 = 빈 세 칸(예시 · 힌트 · 프리필 0) · 정적 칸 이름 · 저장 버튼', (
    WidgetTester tester,
  ) async {
    final _Repo repo = await _pump(
      tester,
      _Actions(() async => throw StateError('x')),
    );
    await _emit(tester, repo, _vm('pledge_not_written.json'));
    for (int i = 0; i < 3; i++) {
      final TextField f = _field(tester, i);
      expect(f.controller!.text, '', reason: '$i');
      expect(f.decoration!.hintText, isNull, reason: '$i');
      expect(f.enabled, isTrue);
    }
    expect(find.text(SafetyLabels.pledgeSentence1), findsOneWidget);
    expect(find.text(SafetyLabels.pledgeSentence2), findsOneWidget);
    expect(find.text(SafetyLabels.pledgeSentence3), findsOneWidget);
    expect(_save(tester).onPressed, isNotNull);
    expect(find.byKey(const Key('m5-8-written')), findsNothing);
  });

  testWidgets(
    '🔴 저장 = 첫 판 동작 · 친 원문 그대로 · 저널 id 없음 · 결과 = 엔진 글자 · 저장되면 세 줄로 바뀐다',
    (WidgetTester tester) async {
      final SafetyActionResult ok = _result(SafetyActionId.pledgeWrite, null);
      final _Actions actions = _Actions(() async => ok);
      final _Repo repo = await _pump(tester, actions);
      await _emit(tester, repo, _vm('pledge_not_written.json'));
      await tester.enterText(
        find.byKey(const ValueKey<String>('m5-8-input-0')),
        ' 하나 ',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('m5-8-input-1')),
        '둘',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('m5-8-input-2')),
        '셋',
      );
      await tester.tap(find.byKey(const Key('m5-8-save')));
      await tester.pump();
      await tester.pump();
      expect(actions.sent, hasLength(1));
      expect(
        actions.sent.single,
        const PledgeSubmission(
          id: SafetyActionId.pledgeWrite,
          sentences: <String>[' 하나 ', '둘', '셋'],
        ),
      );
      expect(find.text(ok.headline), findsOneWidget);
      final PledgeVm written = _vm('pledge_written.json');
      await _emit(tester, repo, written);
      expect(find.byKey(const Key('m5-8-form')), findsNothing);
      for (final (int i, String s) in written.lines.indexed) {
        expect(
          tester
              .widget<Text>(find.byKey(ValueKey<String>('m5-8-line-$i')))
              .data,
          s,
        );
      }
    },
  );

  testWidgets('🔴 화면 검증 0 — 빈칸도 그대로 낸다 · 거부 = 엔진 글자 · 다시 낼 수 있다', (
    WidgetTester tester,
  ) async {
    final SafetyActionResult no = _result(
      SafetyActionId.pledgeWrite,
      PledgeResultCodes.sentencesMissing,
    );
    final _Actions actions = _Actions(() async => no);
    final _Repo repo = await _pump(tester, actions);
    await _emit(tester, repo, _vm('pledge_not_written.json'));
    await tester.tap(find.byKey(const Key('m5-8-save')));
    await tester.pump();
    await tester.pump();
    expect(actions.sent.single.sentences, <String>['', '', '']);
    expect(actions.sent.single.decisionId, isNull);
    expect(
      tester.widget<Text>(find.byKey(const Key('m5-8-result'))).data,
      no.headline,
    );
    expect(_field(tester, 0).enabled, isTrue);
    expect(_save(tester).onPressed, isNotNull);
  });

  testWidgets('🔴 저장 중 = 칸 · 버튼 잠금 · 제출 자체 실패 = 정적 글자 · 다시 가능', (
    WidgetTester tester,
  ) async {
    final Completer<SafetyActionResult> wait = Completer<SafetyActionResult>();
    final _Repo repo = await _pump(tester, _Actions(() => wait.future));
    await _emit(tester, repo, _vm('pledge_not_written.json'));
    await tester.tap(find.byKey(const Key('m5-8-save')));
    await tester.pump();
    expect(_field(tester, 1).enabled, isFalse);
    expect(_save(tester).onPressed, isNull);
    wait.completeError(StateError('끊김'));
    await tester.pump();
    await tester.pump();
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(const Key('m5-8-result')), findsNothing);
    expect(_save(tester).onPressed, isNotNull);
    expect(_field(tester, 1).enabled, isTrue);
  });

  testWidgets('🔴 판 있음 = 원문 세 줄만 · 엔진 글자 칸은 있을 때만 · 편집 컨트롤 0(편집 가능 판정이어도)', (
    WidgetTester tester,
  ) async {
    final _Repo repo = await _pump(
      tester,
      _Actions(() async => throw StateError('x')),
    );
    final PledgeVm edit = _vm('pledge_edit_window.json');
    await _emit(tester, repo, edit);
    expect(find.byKey(const Key('m5-8-line-2')), findsOneWidget);
    expect(find.byKey(const Key('m5-8-status')), findsNothing);
    expect(find.byKey(const Key('m5-8-replay')), findsNothing);
    expect(find.byKey(const Key('m5-8-locked')), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    await _emit(
      tester,
      repo,
      edit.copyWith(
        editable: false,
        statusLine: '판 1',
        replayNotice: '재생',
        lockedLabel: '잠김',
      ),
    );
    expect(find.text('판 1'), findsOneWidget);
    expect(find.text('재생'), findsOneWidget);
    expect(find.text('잠김'), findsOneWidget);
  });

  testWidgets('🔴 쓰기 주입 null(뷰어) = 첫 판 없음이면 자리 부재 · 판 있으면 세 줄만', (
    WidgetTester tester,
  ) async {
    final _Repo repo = await _pump(tester, null);
    await _emit(tester, repo, _vm('pledge_not_written.json'));
    expect(find.byKey(const Key('m5-8-absent')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await _emit(tester, repo, _vm('pledge_written.json'));
    expect(find.byKey(const Key('m5-8-line-0')), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
