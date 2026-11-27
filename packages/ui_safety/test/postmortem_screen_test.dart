// 🆕 미결 243 ⓐ — `M5-4` postmortem 한 화면(설계 13 §8 R282 · 계약 v1.39 K345) — 읽기 모델 = 계약 픽스처(`m5/postmortem_list_*`).
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 쓰기 = 행의 `form` 이 있을 때만 · 제출 = 행 incidentId 그대로 + 칸 원문 · 결과 = 엔진 글자 ·
//    제출 실패 = 정적 문장 · 쓰기 주입 null = 칸 0 · 쓴 행 = 읽기 전용 · 링크 = 셸 링크 열기 · 확인 대화 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

PostmortemListVm _vm(String name) => PostmortemListVm.fromJson(
  ((jsonDecode(
                File(
                  '../domain_contracts/fixtures/m5/postmortem_list_$name.json',
                ).readAsStringSync(),
              ) as Map<String, dynamic>)['rows']
              as List<dynamic>)
          .first
      as Map<String, dynamic>,
);

class _Repo implements PostmortemRepository {
  final StreamController<PostmortemListVm> c =
      StreamController<PostmortemListVm>();

  @override
  Stream<PostmortemListVm> watchPostmortems() => c.stream;

  void close() => unawaited(c.close());
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.fail = false});

  final bool fail;
  final List<PostmortemSubmission> sent = <PostmortemSubmission>[];

  @override
  Future<SafetyActionResult> runPostmortem(
    PostmortemSubmission submission,
  ) async {
    sent.add(submission);
    if (fail) throw StateError('제출 실패');
    return SafetyActionResult(
      actionRunId: 'run-1',
      id: SafetyActionId.postmortemRecord,
      level: UiLevel.act,
      headline: '엔진 결과 글',
      reasonCode: 'POSTMORTEM_BLANK',
      retryable: false,
    );
  }
}

Future<(_Repo, _Links)> _pump(WidgetTester t, {SafetyActions? actions}) async {
  t.view.physicalSize = const Size(800, 3000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  final _Links links = _Links();
  addTearDown(repo.close);
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyPostmortemRepositoryProvider.overrideWithValue(repo),
        safetyActionsProvider.overrideWithValue(actions),
        safetyLinkOpenerProvider.overrideWithValue(links),
      ],
      child: const MaterialApp(home: Scaffold(body: PostmortemScreen())),
    ),
  );
  return (repo, links);
}

Future<void> _show(WidgetTester t, _Repo repo, PostmortemListVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

List<String> _cards(WidgetTester t) => <String>[
  for (final Element e in find.byType(Card).evaluate())
    (e.widget.key! as ValueKey<String>).value,
];

void main() {
  for (final String f in <String>['empty', 'due', 'written_overdue']) {
    testWidgets('$f — 머리 · 행 차례 · 글자 · 칸 = VM 그대로 · 확인 대화 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _Links _) = await _pump(t, actions: _Actions());
      final PostmortemListVm vm = _vm(f);
      await _show(t, repo, vm);
      expect(find.text(vm.headline), findsOneWidget);
      expect(find.text(vm.asOf.label), findsOneWidget);
      expect(
        find.byKey(const Key('m54-empty')),
        vm.emptyLabel == null ? findsNothing : findsOneWidget,
      );
      expect(_cards(t), <String>[
        for (final PostmortemRow r in vm.rows) 'm54-row-${r.incidentId}',
      ]);
      for (final PostmortemRow r in vm.rows) {
        final String id = r.incidentId;
        expect(find.text('${r.severityLabel} · ${r.title}'), findsOneWidget);
        expect(find.text(r.occurredText), findsOneWidget);
        expect(find.text(r.stateLabel), findsOneWidget);
        expect(
          find.byKey(Key('m54-due-$id')),
          r.dueText == null ? findsNothing : findsOneWidget,
        );
        expect(
          find.byKey(Key('m54-written-$id')),
          r.writtenText == null ? findsNothing : findsOneWidget,
        );
        expect(
          find.byKey(Key('m54-text-$id')),
          r.form == null ? findsNothing : findsOneWidget,
        );
        expect(
          find.byKey(Key('m54-next-$id')),
          r.nextLink == null ? findsNothing : findsOneWidget,
        );
      }
      expect(find.byType(Dialog), findsNothing);
    });
  }

  testWidgets('🔴 제출 = 행 incidentId 그대로 + 칸 원문(손질 0) · 결과 = 엔진 글자 + 코드 원문', (
    WidgetTester t,
  ) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _Links _) = await _pump(t, actions: actions);
    final PostmortemRow row = _vm('due').rows.single;
    await _show(t, repo, _vm('due'));
    expect(find.text(row.form!.promptText), findsOneWidget);
    expect(find.text(row.form!.noticeText!), findsOneWidget);
    await t.enterText(
      find.byKey(Key('m54-text-${row.incidentId}')),
      '  원인 · 영향 ',
    );
    await t.tap(find.text(row.form!.buttonLabel));
    await t.pump();
    expect(actions.sent, <PostmortemSubmission>[
      PostmortemSubmission(incidentId: row.incidentId, text: '  원인 · 영향 '),
    ]);
    expect(find.text('엔진 결과 글 (POSTMORTEM_BLANK)'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('제출 자체 실패 = 정적 문장(지어낸 결과 0)', (WidgetTester t) async {
    final (_Repo repo, _Links _) = await _pump(
      t,
      actions: _Actions(fail: true),
    );
    final PostmortemRow row = _vm('due').rows.single;
    await _show(t, repo, _vm('due'));
    await t.tap(find.byKey(Key('m54-submit-${row.incidentId}')));
    await t.pump();
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(Key('m54-result-${row.incidentId}')), findsNothing);
  });

  testWidgets('🔴 쓰기 주입 null = 칸 · 버튼 0 · 글자 · 행은 그대로', (WidgetTester t) async {
    final (_Repo repo, _Links _) = await _pump(t);
    final PostmortemRow row = _vm('due').rows.single;
    await _show(t, repo, _vm('due'));
    expect(find.byKey(Key('m54-row-${row.incidentId}')), findsOneWidget);
    expect(find.byKey(Key('m54-text-${row.incidentId}')), findsNothing);
    expect(find.byKey(Key('m54-submit-${row.incidentId}')), findsNothing);
    expect(find.text(row.stateLabel), findsOneWidget);
  });

  testWidgets('🔴 쓴 SEV1 = 읽기 전용 · «STOPPED 결정으로» = 셸 링크 열기 · 기한 넘김 행만 칸', (
    WidgetTester t,
  ) async {
    final (_Repo repo, _Links links) = await _pump(t, actions: _Actions());
    final PostmortemListVm vm = _vm('written_overdue');
    final PostmortemRow sev1 = vm.rows.first;
    final PostmortemRow late = vm.rows.last;
    await _show(t, repo, vm);
    expect(find.text(sev1.writtenText!), findsOneWidget);
    expect(find.byKey(Key('m54-text-${sev1.incidentId}')), findsNothing);
    expect(find.byKey(Key('m54-text-${late.incidentId}')), findsOneWidget);
    expect(find.text(late.dueText!), findsOneWidget);
    await t.tap(find.text(sev1.nextLink!.label));
    await t.pump();
    expect(links.opened, <String>[sev1.nextLink!.deepLink]);
  });

  testWidgets('읽기 전 = 기다림 · 원천 오류 = 정적 문장', (WidgetTester t) async {
    final (_Repo repo, _Links _) = await _pump(t, actions: _Actions());
    expect(find.byKey(const Key('m54-loading')), findsOneWidget);
    repo.c.addError(StateError('원장 없음'));
    await t.pump();
    await t.pump();
    expect(find.text(SafetyLabels.postmortemReadFailed), findsOneWidget);
  });
}
