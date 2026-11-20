// M5-5 차단 보드(설계 13 §8 R185) — 읽기 모델 = 계약 픽스처(`m5/block_board_*`).
//
// 🔴 화면은 받은 차례 · 글자 · 링크 그대로(재정렬 0) · 해제 버튼 0 · 확인 대화 0 · 킬스위치 진입 = 늘(읽기 실패에도 길 하나) ·
//    사다리 지금 단 = 글자 표지 하나.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

BlockBoardVm _vm(String name) => BlockBoardVm.fromJson(
  ((jsonDecode(
                File('../domain_contracts/fixtures/m5/$name.json')
                    .readAsStringSync(),
              ) as Map<String, dynamic>)['rows']
              as List<dynamic>)
          .first
      as Map<String, dynamic>,
);

const List<String> _fixtures = <String>[
  'block_board_clear',
  'block_board_kill_active',
  'block_board_resume_incomplete',
  'block_board_stopped',
];

class _Repo implements BlockBoardRepository {
  final StreamController<BlockBoardVm> c = StreamController<BlockBoardVm>();

  @override
  Stream<BlockBoardVm> watchBoard() => c.stream;

  Future<void> close() => c.close();
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

Future<(_Repo, _Links)> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final _Links links = _Links();
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyBlockBoardRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
      ],
      child: const MaterialApp(home: Scaffold(body: BlockBoardScreen())),
    ),
  );
  return (repo, links);
}

Future<void> _show(WidgetTester t, _Repo repo, BlockBoardVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

String? _text(WidgetTester t, Key k) => t.widget<Text>(find.byKey(k)).data;

void main() {
  for (final String f in _fixtures) {
    testWidgets('$f — 글자 · 차례 · 링크 = VM 그대로 · 대화 0 · 해제 버튼 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _Links links) = await _pump(t);
      final BlockBoardVm vm = _vm(f);
      await _show(t, repo, vm);
      expect(_text(t, const Key('m55-headline')), vm.headline);
      expect(_text(t, const Key('m55-breaker')), vm.breakerLabel);
      expect(_text(t, const Key('m55-asof')), vm.asOf.label);
      expect(
        find.byKey(const Key('m55-empty')),
        vm.emptyLabel == null ? findsNothing : findsOneWidget,
      );
      // 행 = 받은 차례.
      final List<String> shown = <String>[
        for (final Element e in find.byType(Card).evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      expect(shown, <String>[
        for (final BlockBoardRow r in vm.rows) 'm55-row-${r.rowId}',
      ]);
      for (final BlockBoardRow r in vm.rows) {
        final Finder card = find.byKey(Key('m55-row-${r.rowId}'));
        for (final String s in <String?>[
          r.label,
          r.setAtText,
          r.clearKindLabel,
          r.clearInstruction,
        ].whereType<String>()) {
          expect(
            find.descendant(of: card, matching: find.text(s)),
            findsOneWidget,
          );
        }
        final Finder link = find.byKey(Key('m55-row-link-${r.rowId}'));
        if (r.link == null) {
          expect(link, findsNothing);
        } else {
          await t.ensureVisible(link);
          await t.tap(link);
          expect(links.opened.last, r.link!.deepLink);
        }
      }
      // 게이지 = 받은 글자 · 폭.
      for (final GaugeProgress g in vm.gauges) {
        final Finder box = find.byKey(Key('m55-gauge-${g.code}'));
        expect(
          find.descendant(of: box, matching: find.text(g.valueText)),
          findsOneWidget,
        );
        expect(
          t
              .widget<LinearProgressIndicator>(
                find.descendant(
                  of: box,
                  matching: find.byType(LinearProgressIndicator),
                ),
              )
              .value,
          g.normalized,
        );
      }
      expect(
        find.byType(LinearProgressIndicator),
        findsNWidgets(vm.gauges.length),
      );
      // 사다리 = 받은 차례 · 지금 단 표지 하나(지금 단 안).
      final List<Key> steps = <Key>[
        for (final BreakerLadderRow s in vm.ladder.rows)
          Key('m55-ladder-${s.level.wire}'),
      ];
      double y = -1;
      for (final Key k in steps) {
        final double top = t.getTopLeft(find.byKey(k)).dy;
        expect(top, greaterThan(y));
        y = top;
      }
      final BreakerLadderRow now = vm.ladder.rows.singleWhere(
        (BreakerLadderRow s) => s.current,
      );
      expect(
        find.descendant(
          of: find.byKey(Key('m55-ladder-${now.level.wire}')),
          matching: find.byKey(const Key('m55-ladder-now')),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-ladder-now')), findsOneWidget);
      // 재개 결정 = 있을 때만.
      final Finder stopped = find.byKey(const Key('m55-stopped'));
      if (vm.stoppedDecisionLink == null) {
        expect(stopped, findsNothing);
      } else {
        await t.ensureVisible(stopped);
        await t.tap(stopped);
        expect(links.opened.last, vm.stoppedDecisionLink!.deepLink);
      }
      // 킬스위치 진입 = 늘.
      await t.ensureVisible(find.byKey(const Key('m55-kill')));
      await t.tap(find.byKey(const Key('m55-kill')));
      expect(links.opened.last, vm.killSwitchLink.deepLink);
      expect(find.text(vm.killSwitchLink.label), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(find.textContaining('해제하기'), findsNothing);
    });
  }

  testWidgets('🔴 차례 = VM 그대로(화면이 다시 줄 세우지 않는다)', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    final BlockBoardVm vm = _vm('block_board_resume_incomplete');
    await _show(t, repo, vm.copyWith(rows: vm.rows.reversed.toList()));
    final List<String> shown = <String>[
      for (final Element e in find.byType(Card).evaluate())
        (e.widget.key! as ValueKey<String>).value,
    ];
    expect(shown, <String>[
      'm55-row-${FlagIds.journalMissing}',
      'm55-row-${FlagIds.resumeIncomplete}',
    ]);
  });

  testWidgets('다시 내면 다시 그린다 · 읽는 중 = 진행 표시', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    expect(find.byKey(const Key('m55-loading')), findsOneWidget);
    await _show(t, repo, _vm('block_board_clear'));
    expect(find.byKey(const Key('m55-empty')), findsOneWidget);
    await _show(t, repo, _vm('block_board_kill_active'));
    expect(find.byKey(const Key('m55-empty')), findsNothing);
    expect(find.byKey(const Key('m55-row-KILL_SWITCH')), findsOneWidget);
  });

  testWidgets('🔴 읽기 실패 = 실패 문장 + 킬스위치 화면 길 하나(끄는 길은 언제나)', (
    WidgetTester t,
  ) async {
    final (_Repo repo, _Links links) = await _pump(t);
    repo.c.addError(StateError('읽기 실패'));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('m55-read-failed')), findsOneWidget);
    expect(find.byKey(const Key('m55-root')), findsNothing);
    await t.tap(find.byKey(const Key('m55-kill-fallback')));
    expect(links.opened, <String>[AppRoutes.m5KillSwitch]);
  });
}
