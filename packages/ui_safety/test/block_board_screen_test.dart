// M5-5 차단 보드(설계 13 §8 R185) — 읽기 모델 = 계약 픽스처(`m5/block_board_*`).
//
// 🔴 화면은 받은 차례 · 글자 · 링크 그대로(재정렬 0) · 해제 버튼 0 · 확인 대화 0 · 킬스위치 진입 = 늘(읽기 실패에도 길 하나) ·
//    사다리 지금 단 = 글자 표지 하나.
// 🆕 R189 — RECON 행만 해제 폼(엔진 `reconClear` · 선택지 받은 차례 · 고르기 전 확인 꺼짐 · 저널 세 칸 원문 · 결과 = 엔진 글자 ·
//    행이 사라져도 결과는 남음 · 제출 실패 = 정적 문장 · 쓰기 주입 null = 폼 0).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
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
  'block_board_recon_mismatch',
];

List<SafetyActionResult> _results() => <SafetyActionResult>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/m5/recon_clear_results.json')
                .readAsStringSync(),
          ) as Map<String, dynamic>)['rows']
          as List<dynamic>)
    SafetyActionResult.fromJson(r! as Map<String, dynamic>),
];

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.next, this.fail = false});

  SafetyActionResult? next;
  final bool fail;
  final List<ReconClearSubmission> got = <ReconClearSubmission>[];

  @override
  Future<SafetyActionResult> runReconClear(
    ReconClearSubmission submission,
  ) async {
    got.add(submission);
    if (fail) throw StateError('제출 실패');
    return next!;
  }
}

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
        safetyBlockBoardRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
        safetyActionsProvider.overrideWithValue(actions),
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
      // 쓰기 주입 null(뷰어) = 해제 폼 0(VM 에 폼이 있어도).
      expect(find.byKey(const Key('m55-recon-form')), findsNothing);
    });
  }

  group('🆕 R189 RECON 해제 폼', () {
    BlockBoardVm recon() => _vm('block_board_recon_mismatch');

    Future<void> open(WidgetTester t) async {
      final Finder b = find.byKey(const Key('m55-recon-open'));
      await t.ensureVisible(b);
      await t.tap(b);
      await t.pump();
    }

    Future<void> fill(WidgetTester t, String code) async {
      await open(t);
      final Finder chip = find.byKey(Key('m55-recon-origin-$code'));
      await t.ensureVisible(chip);
      await t.tap(chip);
      await t.pump();
      await t.enterText(
        find.byKey(const Key('m55-recon-rationale')),
        ' 체결 보고가 늦게 왔다 ',
      );
      await t.enterText(
        find.byKey(const Key('m55-recon-expected')),
        '다음 대사에서 맞는다',
      );
      await t.enterText(find.byKey(const Key('m55-recon-rule')), '04 §3-5 ②');
      await t.pump();
    }

    Future<void> submit(WidgetTester t) async {
      final Finder b = find.byKey(const Key('m55-recon-submit'));
      await t.ensureVisible(b);
      await t.tap(b);
      await t.pump();
      await t.pump();
    }

    testWidgets('RECON 행만 · 선택지 = 받은 차례 · 고지 · 고르기 전 확인 꺼짐 · 대화 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(t, actions: _Actions());
      final BlockBoardVm vm = recon();
      await _show(t, repo, vm);
      final BlockBoardRow row = vm.rows.singleWhere(
        (BlockBoardRow r) => r.reconClear != null,
      );
      expect(row.rowId, FlagIds.reconMismatch);
      final Finder form = find.byKey(const Key('m55-recon-form'));
      expect(form, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(Key('m55-row-${row.rowId}')),
          matching: form,
        ),
        findsOneWidget,
      );
      expect(
        _text(t, const Key('m55-recon-notice')),
        row.reconClear!.noticeText,
      );
      // 닫힌 채 = 여는 버튼 · 고지만(보드를 밀어내지 않는다) → 열면 선택지 · 세 칸 · 확인.
      expect(find.byKey(const Key('m55-recon-open')), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byKey(const Key('m55-recon-submit')), findsNothing);
      await open(t);
      expect(find.byKey(const Key('m55-recon-rationale')), findsOneWidget);
      final List<String> chips = <String>[
        for (final Element e in find.byType(ChoiceChip).evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      expect(chips, <String>[
        for (final ReconOriginChoice c in row.reconClear!.choices)
          'm55-recon-origin-${c.originCode}',
      ]);
      for (final ReconOriginChoice c in row.reconClear!.choices) {
        expect(
          find.descendant(
            of: find.byKey(Key('m55-recon-origin-${c.originCode}')),
            matching: find.text(c.label),
          ),
          findsOneWidget,
        );
      }
      expect(
        t
            .widget<FilledButton>(find.byKey(const Key('m55-recon-submit')))
            .onPressed,
        isNull,
      );
      expect(find.byKey(const Key('m55-recon-result')), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets(
      '🔴 제출 = 고른 코드 그대로 + 세 칸 원문 · 결과 = 엔진 글자 · 행이 풀려 사라져도 결과는 남는다',
      (WidgetTester t) async {
        final List<SafetyActionResult> rs = _results();
        final _Actions a = _Actions(next: rs.first);
        final (_Repo repo, _) = await _pump(t, actions: a);
        final BlockBoardVm vm = recon();
        await _show(t, repo, vm);
        final String code = vm.rows.first.reconClear!.choices[2].originCode;
        await fill(t, code);
        // 다시 누르면 고르기 해제 → 확인 꺼짐 → 다시 고른다.
        await t.tap(find.byKey(Key('m55-recon-origin-$code')));
        await t.pump();
        expect(
          t
              .widget<FilledButton>(find.byKey(const Key('m55-recon-submit')))
              .onPressed,
          isNull,
        );
        await t.tap(find.byKey(Key('m55-recon-origin-$code')));
        await t.pump();
        await submit(t);
        expect(a.got, <ReconClearSubmission>[
          ReconClearSubmission(
            originCode: code,
            rationaleBefore: ' 체결 보고가 늦게 왔다 ',
            expectedOutcome: '다음 대사에서 맞는다',
            ruleCited: '04 §3-5 ②',
          ),
        ]);
        expect(_text(t, const Key('m55-recon-result')), rs.first.headline);
        // 폼이 있는 동안 = 행 안(확인 아래).
        expect(
          find.descendant(
            of: find.byKey(Key('m55-row-${FlagIds.reconMismatch}')),
            matching: find.byKey(const Key('m55-recon-result')),
          ),
          findsOneWidget,
        );
        expect(find.byType(Dialog), findsNothing);
        // 엔진이 풀어 새 VM(RECON 행 0) — 결과 글자는 남는다(맨 위 · 행 밖).
        await _show(
          t,
          repo,
          vm.copyWith(
            rows: vm.rows
                .where((BlockBoardRow r) => r.rowId != FlagIds.reconMismatch)
                .toList(),
          ),
        );
        expect(find.byKey(const Key('m55-recon-form')), findsNothing);
        expect(_text(t, const Key('m55-recon-result')), rs.first.headline);
        expect(
          find.descendant(
            of: find.byType(Card),
            matching: find.byKey(const Key('m55-recon-result')),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('거부 = 엔진 글자 (코드) 원문 — 표본 결과 6 · 입력은 남는다', (
      WidgetTester t,
    ) async {
      final _Actions a = _Actions();
      final (_Repo repo, _) = await _pump(t, actions: a);
      await _show(t, repo, recon());
      await fill(t, OriginCodes.fillLag);
      for (final SafetyActionResult r in _results()) {
        a.next = r;
        await submit(t);
        expect(
          _text(t, const Key('m55-recon-result')),
          r.reasonCode == null ? r.headline : '${r.headline} (${r.reasonCode})',
        );
      }
      expect(a.got, hasLength(6));
      expect(a.got.toSet(), hasLength(1));
      expect(
        t
            .widget<TextField>(find.byKey(const Key('m55-recon-expected')))
            .controller!
            .text,
        '다음 대사에서 맞는다',
      );
    });

    testWidgets('🔴 쓰는 중에 위에 행이 끼어도(킬스위치 발동) 고른 코드 · 세 칸이 남는다', (
      WidgetTester t,
    ) async {
      final _Actions a = _Actions(next: _results().first);
      final (_Repo repo, _) = await _pump(t, actions: a);
      final BlockBoardVm vm = recon();
      await _show(t, repo, vm);
      await fill(t, OriginCodes.dbError);
      await _show(
        t,
        repo,
        vm.copyWith(
          rows: <BlockBoardRow>[
            vm.rows.last.copyWith(rowId: 'KILL_SWITCH', link: null),
            ...vm.rows,
          ],
        ),
      );
      expect(find.byKey(const Key('m55-row-KILL_SWITCH')), findsOneWidget);
      expect(
        t
            .widget<ChoiceChip>(
              find.byKey(Key('m55-recon-origin-${OriginCodes.dbError}')),
            )
            .selected,
        isTrue,
      );
      await submit(t);
      expect(a.got.single.originCode, OriginCodes.dbError);
      expect(a.got.single.rationaleBefore, ' 체결 보고가 늦게 왔다 ');
    });

    testWidgets('제출 자체 실패 = 정적 문장(엔진 글자를 지어내지 않는다)', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(t, actions: _Actions(fail: true));
      await _show(t, repo, recon());
      await fill(t, OriginCodes.manualOrder);
      await submit(t);
      expect(
        _text(t, const Key('m55-recon-result-failed')),
        SafetyLabels.submitNotAccepted,
      );
      expect(find.byKey(const Key('m55-recon-result')), findsNothing);
    });

    testWidgets('🔴 엔진이 폼을 안 주면(쓰기 창구 없음 · 잠김) 폼 0 — 화면이 flagId 로 만들지 않는다', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(t, actions: _Actions());
      final BlockBoardVm vm = recon();
      await _show(
        t,
        repo,
        vm.copyWith(
          rows: <BlockBoardRow>[
            for (final BlockBoardRow r in vm.rows) r.copyWith(reconClear: null),
          ],
        ),
      );
      expect(
        find.byKey(Key('m55-row-${FlagIds.reconMismatch}')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m55-recon-form')), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
    });
  });

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
