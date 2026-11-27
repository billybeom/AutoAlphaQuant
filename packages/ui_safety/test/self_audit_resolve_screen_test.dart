// 🆕 M5-13 원장 실사 해소 게이트(설계 13 §8 R280 · 01 §46 K318 · K319) — 읽기 모델 = 계약 픽스처(`m5/self_audit_resolve_*` ·
// `m5/held_review_results`).
//
// 🔴 화면은 받은 차례 · 글자 · 링크 그대로(재정렬 0) · 수동 해제 · 버림 버튼 0 · 확인 대화 0 · 확정 = 엔진 완성 호출 그대로 ·
//    결과 = 엔진 글자 + 사유 원문 · 제출 실패 = 정적 문장 · 쓰기 주입 null = 확정 버튼 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

List<Map<String, dynamic>> _rows(String name) => <Map<String, dynamic>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/m5/$name.json')
                .readAsStringSync(),
          ) as Map<String, dynamic>)['rows']
          as List<dynamic>)
    r! as Map<String, dynamic>,
];

SelfAuditResolveVm _vm(String name) =>
    SelfAuditResolveVm.fromJson(_rows(name).single);

const List<String> _fixtures = <String>[
  'self_audit_resolve_open',
  'self_audit_resolve_held_blocked',
  'self_audit_resolve_clear',
];

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.next, this.fail = false});

  SafetyActionResult? next;
  final bool fail;
  final List<(SafetyActionId, Map<String, String>)> got =
      <(SafetyActionId, Map<String, String>)>[];

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    got.add((id, args));
    if (fail) throw StateError('제출 실패');
    return next!;
  }
}

class _Repo implements SelfAuditResolveRepository {
  final StreamController<SelfAuditResolveVm> c =
      StreamController<SelfAuditResolveVm>();

  @override
  Stream<SelfAuditResolveVm> watchResolve() => c.stream;

  Future<void> close() => c.close();
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

Future<(_Repo, _Links)> _pump(
  WidgetTester tester, {
  SafetyActions? actions,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final _Links links = _Links();
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetySelfAuditResolveRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
        safetyActionsProvider.overrideWithValue(actions),
      ],
      child: const MaterialApp(home: Scaffold(body: SelfAuditResolveScreen())),
    ),
  );
  return (repo, links);
}

Future<void> _show(WidgetTester t, _Repo repo, SelfAuditResolveVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

String? _text(WidgetTester t, Key k) => t.widget<Text>(find.byKey(k)).data;

void main() {
  for (final String f in _fixtures) {
    testWidgets('$f — 글자 · 차례 · 링크 = VM 그대로 · 대화 0 · 수동 해제 · 버림 버튼 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(t, actions: _Actions());
      final SelfAuditResolveVm vm = _vm(f);
      await _show(t, repo, vm);
      expect(_text(t, const Key('m513-headline')), vm.headline);
      expect(_text(t, const Key('m513-flag')), vm.flagLine);
      expect(_text(t, const Key('m513-release-rule')), vm.releaseRuleText);
      expect(_text(t, const Key('m513-asof')), vm.asOf.label);
      for (int i = 0; i < vm.counterLines.length; i++) {
        expect(_text(t, Key('m513-counter-$i')), vm.counterLines[i]);
      }
      expect(
        find.byKey(Key('m513-counter-${vm.counterLines.length}')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('m513-diffs-empty')),
        vm.diffs.isEmpty ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('m513-held-empty')),
        vm.heldCommands.isEmpty ? findsOneWidget : findsNothing,
      );
      for (final LedgerDiffRow r in vm.diffs) {
        expect(find.byKey(Key('m513-diff-${r.diffId}')), findsOneWidget);
        expect(find.text(r.deltaLabel), findsOneWidget);
        expect(find.textContaining(r.routeLabel), findsWidgets);
        expect(
          find.byKey(Key('m513-diff-link-${r.diffId}')),
          r.actionLink == null ? findsNothing : findsOneWidget,
        );
      }
      for (final HeldCommandRow h in vm.heldCommands) {
        expect(find.byKey(Key('m513-held-${h.commandId}')), findsOneWidget);
        expect(find.text(h.summaryText), findsOneWidget);
      }
      expect(
        find.byKey(const Key('m513-held-blocked')),
        vm.heldBlockedText == null ? findsNothing : findsOneWidget,
      );
      expect(
        find.byKey(const Key('m513-confirm')),
        vm.confirmHeld == null ? findsNothing : findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('해제하기'), findsNothing);
      expect(find.textContaining('버리'), findsNothing);
      expect(find.textContaining('삭제'), findsNothing);
    });
  }

  testWidgets('차례 = 받은 차례(차이 · 보관 — 위 → 아래 · 재정렬 0)', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    final SelfAuditResolveVm open = _vm('self_audit_resolve_open');
    expect(open.diffs, hasLength(2));
    await _show(t, repo, open);
    double y(String key) => t.getTopLeft(find.byKey(Key(key))).dy;
    expect(
      y('m513-diff-${open.diffs[0].diffId}'),
      lessThan(y('m513-diff-${open.diffs[1].diffId}')),
    );
    final SelfAuditResolveVm held = _vm('self_audit_resolve_held_blocked');
    expect(held.heldCommands, hasLength(2));
    await _show(t, repo, held);
    expect(
      y('m513-held-${held.heldCommands[0].commandId}'),
      lessThan(y('m513-held-${held.heldCommands[1].commandId}')),
    );
  });

  testWidgets('링크 = 행 «다시 실사하기» · 실사 링크 목적지 그대로', (WidgetTester t) async {
    final (_Repo repo, _Links links) = await _pump(t);
    final SelfAuditResolveVm vm = _vm('self_audit_resolve_open');
    await _show(t, repo, vm);
    final LedgerDiffRow r = vm.diffs.first;
    await t.tap(find.byKey(Key('m513-diff-link-${r.diffId}')));
    await t.tap(find.byKey(const Key('m513-audit-0')));
    expect(links.opened, <String>[
      r.actionLink!.deepLink,
      vm.auditLinks.first.deepLink,
    ]);
    expect(find.text(vm.auditLinks.first.label), findsOneWidget);
  });

  testWidgets('확정 = 엔진 완성 호출 그대로 · 결과 = 엔진 글자(확정 · 거부 = 사유 원문)', (
    WidgetTester t,
  ) async {
    final List<SafetyActionResult> results = <SafetyActionResult>[
      for (final Map<String, dynamic> r in _rows('held_review_results'))
        SafetyActionResult.fromJson(r),
    ];
    final _Actions actions = _Actions(next: results.first);
    final (_Repo repo, _) = await _pump(t, actions: actions);
    final SelfAuditResolveVm vm = _vm('self_audit_resolve_open');
    await _show(t, repo, vm);
    expect(find.text(vm.confirmHeld!.label), findsOneWidget);
    await t.tap(find.byKey(const Key('m513-confirm')));
    await t.pump();
    expect(actions.got, <(SafetyActionId, Map<String, String>)>[
      (vm.confirmHeld!.id, vm.confirmHeld!.args),
    ]);
    expect(_text(t, const Key('m513-result')), results.first.headline);
    actions.next = results[1];
    await t.tap(find.byKey(const Key('m513-confirm')));
    await t.pump();
    expect(
      _text(t, const Key('m513-result')),
      '${results[1].headline} (${results[1].reasonCode})',
    );
  });

  testWidgets('제출 실패 = 정적 문장 · 쓰기 주입 null = 확정 버튼 0', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions(fail: true));
    await _show(t, repo, _vm('self_audit_resolve_open'));
    await t.tap(find.byKey(const Key('m513-confirm')));
    await t.pump();
    expect(find.byKey(const Key('m513-result-failed')), findsOneWidget);
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
  });

  testWidgets('쓰기 주입 null(뷰어) = 확정 버튼 0', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    await _show(t, repo, _vm('self_audit_resolve_open'));
    expect(find.byKey(const Key('m513-confirm')), findsNothing);
    expect(find.byKey(const Key('m513-headline')), findsOneWidget);
  });

  testWidgets('읽기 전 = 기다림 · 읽기 실패 = 정적 문장', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    expect(find.byKey(const Key('m513-loading')), findsOneWidget);
    repo.c.addError(StateError('x'));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('m513-read-failed')), findsOneWidget);
    expect(find.text(SafetyLabels.selfAuditResolveReadFailed), findsOneWidget);
  });
}
