// X2 재개 리포트 · 게이트(설계 13 §8 R186) — 읽기 모델 = 계약 픽스처(`x2/resume_report_screen_*` · `x2/resume_gate_*`).
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 손익 0 · 계절 3택 = 행이 준 동작만(쓰기 주입이 없으면 버튼 0) · 결과 = 엔진 글자 ·
//    제출 실패 = 정적 문장 · 확인 대화 0.

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
                  File('../domain_contracts/fixtures/x2/$name.json')
                      .readAsStringSync(),
                ) as Map<String, dynamic>)['rows']
                as List<dynamic>)
            .first
        as Map<String, dynamic>;

class _Repo implements ResumeGateRepository {
  final StreamController<ResumeGateVm> gate = StreamController<ResumeGateVm>();
  final StreamController<ResumeReportVm> report =
      StreamController<ResumeReportVm>();

  @override
  Stream<ResumeGateVm> watchGate() => gate.stream;

  @override
  Stream<ResumeReportVm> watchReport() => report.stream;

  /// 🔴 기다리지 않는다 — 듣는 쪽이 없던 흐름의 close() 는 끝나지 않는다(시험 마무리가 멈춘다).
  void close() {
    unawaited(gate.close());
    unawaited(report.close());
  }
}

class _Links implements AppLinkOpener {
  final List<String> opened = <String>[];

  @override
  void open(String link) => opened.add(link);
}

class _Actions extends UnimplementedSafetyActions {
  _Actions({this.fail = false});

  final bool fail;
  final List<(SafetyActionId, Map<String, String>)> calls =
      <(SafetyActionId, Map<String, String>)>[];

  @override
  Future<SafetyActionResult> run(
    SafetyActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    calls.add((id, args));
    if (fail) throw StateError('제출 실패');
    return SafetyActionResult(
      actionRunId: 'run-1',
      id: id,
      level: UiLevel.info,
      headline: '엔진 결과 글자',
      reasonCode: 'SEASONAL_NOT_DUE',
      retryable: false,
    );
  }
}

Future<(_Repo, _Links)> _pump(
  WidgetTester t,
  Widget screen, {
  SafetyActions? actions,
}) async {
  t.view.physicalSize = const Size(800, 3000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final _Links links = _Links();
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyResumeGateRepositoryProvider.overrideWithValue(repo),
        safetyLinkOpenerProvider.overrideWithValue(links),
        safetyActionsProvider.overrideWithValue(actions),
      ],
      child: MaterialApp(home: Scaffold(body: screen)),
    ),
  );
  return (repo, links);
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump();
}

List<String> _cards(WidgetTester t) => <String>[
  for (final Element e in find.byType(Card).evaluate())
    (e.widget.key! as ValueKey<String>).value,
];

void main() {
  group('리포트', () {
    for (final String f in <String>[
      'resume_report_screen_normal',
      'resume_report_screen_recovery_full',
    ]) {
      testWidgets('$f — 글자 · 차례 = VM 그대로', (WidgetTester t) async {
        final (_Repo repo, _) = await _pump(t, const ResumeReportScreen());
        expect(find.byKey(const Key('x2r-loading')), findsOneWidget);
        final ResumeReportVm vm = ResumeReportVm.fromJson(_row(f));
        repo.report.add(vm);
        await _settle(t);
        expect(find.text(vm.asOf.label), findsOneWidget);
        final ResumeReport r = vm.report!;
        expect(find.byKey(const Key('x2r-empty')), findsNothing);
        for (final String s in <String>[
          r.headline,
          r.modeLabel,
          vm.periodText!,
          vm.phaseLabel!,
        ]) {
          expect(find.text(s), findsOneWidget, reason: s);
        }
        expect(_cards(t), <String>[
          for (final ResumeItem i in r.items) 'x2r-item-${i.workId}',
        ]);
        for (final ResumeItem i in r.items) {
          final Finder card = find.byKey(Key('x2r-item-${i.workId}'));
          for (final String s in <String>[
            i.oneLine,
            i.plannedLine,
            i.reevaluatedLine,
            i.verdictLabel,
          ]) {
            expect(
              find.descendant(of: card, matching: find.text(s)),
              findsOneWidget,
              reason: s,
            );
          }
        }
        for (final DataGapRow g in r.unrecoverableGaps) {
          expect(find.byKey(Key('x2r-gap-${g.gapId}')), findsOneWidget);
          expect(find.text(g.label), findsOneWidget);
        }
        expect(
          find.text(SafetyLabels.resumeReportGaps),
          r.unrecoverableGaps.isEmpty ? findsNothing : findsOneWidget,
        );
      });
    }

    testWidgets('resume_report_screen_empty — 빈 문장만(머리 · 항목 0)', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(t, const ResumeReportScreen());
      final ResumeReportVm vm = ResumeReportVm.fromJson(
        _row('resume_report_screen_empty'),
      );
      repo.report.add(vm);
      await _settle(t);
      expect(vm.report, isNull);
      expect(find.text(vm.emptyLabel!), findsOneWidget);
      expect(find.text(vm.asOf.label), findsOneWidget);
      expect(find.byKey(const Key('x2r-headline')), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('읽기 실패 = 실패 문장(«재개한 적 없음»과 다르다)', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(t, const ResumeReportScreen());
      repo.report.addError(StateError('읽기 실패'));
      await _settle(t);
      expect(find.byKey(const Key('x2r-read-failed')), findsOneWidget);
      expect(find.byKey(const Key('x2r-empty')), findsNothing);
    });
  });

  group('게이트', () {
    for (final String f in <String>[
      'resume_gate_seasonal_pending',
      'resume_gate_conservative_defer',
      'resume_gate_reevaluation_failed',
      'resume_gate_clear',
      'resume_gate_locked',
    ]) {
      testWidgets('$f — 글자 · 차례 · 버튼 = VM 그대로 · 리포트 링크', (
        WidgetTester t,
      ) async {
        final (_Repo repo, _Links links) = await _pump(
          t,
          const ResumeGateScreen(),
          actions: _Actions(),
        );
        final ResumeGateVm vm = ResumeGateVm.fromJson(_row(f));
        repo.gate.add(vm);
        await _settle(t);
        expect(find.text(vm.headline), findsOneWidget);
        expect(find.text(vm.modeLabel), findsOneWidget);
        expect(
          find.byKey(const Key('x2g-locked')),
          vm.lockedLabel == null ? findsNothing : findsOneWidget,
        );
        expect(_cards(t), <String>[
          for (final ResumeGateRow r in vm.rows) 'x2g-row-${r.workId}',
        ]);
        int buttons = 0;
        for (final ResumeGateRow r in vm.rows) {
          final Finder card = find.byKey(Key('x2g-row-${r.workId}'));
          for (final String s in <String>[r.oneLine, r.reasonLabel]) {
            expect(
              find.descendant(of: card, matching: find.text(s)),
              findsOneWidget,
            );
          }
          final List<String> shown = <String>[
            for (final Element e
                in find
                    .descendant(of: card, matching: find.byType(OutlinedButton))
                    .evaluate())
              ((e.widget as OutlinedButton).child! as Text).data!,
          ];
          expect(shown, <String>[
            for (final SafetyActionCall a in r.actions) a.label,
          ]);
          buttons += shown.length;
        }
        expect(find.byType(OutlinedButton), findsNWidgets(buttons));
        if (vm.reportLink == null) {
          expect(find.byKey(const Key('x2g-report')), findsNothing);
        } else {
          await t.tap(find.byKey(const Key('x2g-report')));
          expect(links.opened, <String>[vm.reportLink!.deepLink]);
        }
        expect(find.byType(Dialog), findsNothing);
      });
    }

    testWidgets('🔴 계절 3택 — 행이 준 동작 그대로 · 결과 = 엔진 글자 · 대화 0', (
      WidgetTester t,
    ) async {
      final _Actions actions = _Actions();
      final (_Repo repo, _) = await _pump(
        t,
        const ResumeGateScreen(),
        actions: actions,
      );
      final ResumeGateVm vm = ResumeGateVm.fromJson(
        _row('resume_gate_seasonal_pending'),
      );
      repo.gate.add(vm);
      await _settle(t);
      final ResumeGateRow r = vm.rows.first;
      final SafetyActionCall reduced = r.actions[1];
      await t.tap(find.byKey(Key('x2g-act-${r.workId}-REDUCED')));
      await _settle(t);
      expect(actions.calls, <(SafetyActionId, Map<String, String>)>[
        (reduced.id, reduced.args),
      ]);
      expect(find.text('엔진 결과 글자 (SEASONAL_NOT_DUE)'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('🔴 제출 자체 실패 = 정적 문장 · 쓰기 주입 없음 = 버튼 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(
        t,
        const ResumeGateScreen(),
        actions: _Actions(fail: true),
      );
      final ResumeGateVm vm = ResumeGateVm.fromJson(
        _row('resume_gate_seasonal_pending'),
      );
      repo.gate.add(vm);
      await _settle(t);
      await t.tap(find.byKey(Key('x2g-act-${vm.rows.first.workId}-SKIP')));
      await _settle(t);
      expect(
        find.byKey(Key('x2g-result-failed-${vm.rows.first.workId}')),
        findsOneWidget,
      );
      expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    });

    testWidgets('쓰기 주입 null(뷰어) = 동작이 있어도 버튼 0', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(t, const ResumeGateScreen());
      repo.gate.add(
        ResumeGateVm.fromJson(_row('resume_gate_seasonal_pending')),
      );
      await _settle(t);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('읽기 실패 = 실패 문장', (WidgetTester t) async {
      final (_Repo repo, _) = await _pump(t, const ResumeGateScreen());
      expect(find.byKey(const Key('x2g-loading')), findsOneWidget);
      repo.gate.addError(StateError('읽기 실패'));
      await _settle(t);
      expect(find.byKey(const Key('x2g-read-failed')), findsOneWidget);
    });
  });
}
