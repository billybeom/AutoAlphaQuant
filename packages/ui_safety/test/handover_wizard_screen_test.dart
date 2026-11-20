// M5-11 simToAuto 위저드(설계 13 §8 R191) — 읽기 모델 = 계약 픽스처(`m5/handover_wizard_*`) · 결과 = `m5/handover_sim_to_auto_action_results`.
//
// 🔴 화면은 받은 글자 · 차례 그대로 · 동작 = 행의 `actions` 그대로 `run(id, args)` 1회 · 도는 동안 버튼 비활성 · 결과 = 엔진 headline ·
//    `handoffRoute` = 그대로 연다 · 쓰기 주입 null · 잠김 · 확정됨 = 버튼 0 · 링크 = `deep_link` 그대로 · 제출 실패 = 정적 문장 · 확인 대화 0.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/ui_safety.dart';

List<Map<String, dynamic>> _rows(String relPath) =>
    ((jsonDecode(
              File('../domain_contracts/fixtures/$relPath').readAsStringSync(),
            ) as Map<String, dynamic>)['rows']
            as List<dynamic>)
        .cast<Map<String, dynamic>>();

HandoverWizardVm _vm(String relPath) =>
    HandoverWizardVm.fromJson(_rows(relPath).single);

/// 표본 12 — 화면 이름 → 픽스처.
const Map<String, String> _all = <String, String>{
  'commit_ready': FixturePaths.m5HandoverWizardCommitReady,
  'committed': FixturePaths.m5HandoverWizardCommitted,
  'cooling': FixturePaths.m5HandoverWizardCooling,
  'expired': FixturePaths.m5HandoverWizardExpired,
  'fate_pending': FixturePaths.m5HandoverWizardFatePending,
  'locked': FixturePaths.m5HandoverWizardLocked,
  'not_applicable': FixturePaths.m5HandoverWizardNotApplicable,
  's3_blocked': FixturePaths.m5HandoverWizardS3Blocked,
  'start_ready': FixturePaths.m5HandoverWizardStartReady,
  'time_unknown': FixturePaths.m5HandoverWizardTimeUnknown,
  'trial_incomplete': FixturePaths.m5HandoverWizardTrialIncomplete,
  'window_blocked': FixturePaths.m5HandoverWizardWindowBlocked,
};

/// 엔진 결과 표본(20행) — 결과는 지어내지 않는다.
List<ActionResult> _results() => <ActionResult>[
  for (final Map<String, dynamic> r in _rows(
    FixturePaths.m5HandoverSimToAutoActionResults,
  ))
    ActionResult.fromJson(r),
];

ActionResult _resultFor(SettingsActionId id) =>
    _results().firstWhere((ActionResult r) => r.id == id);

class _Repo extends UnimplementedHandoverRepository {
  final StreamController<HandoverWizardVm> c =
      StreamController<HandoverWizardVm>();

  @override
  Stream<HandoverWizardVm> watchWizard() => c.stream;

  void close() => unawaited(c.close());
}

class _Actions extends UnimplementedSettingsActions {
  _Actions({this.fail = false, this.hold, this.route});

  final bool fail;

  /// non-null = 이 완료자가 끝날 때까지 결과를 쥐고 있는다(도는 동안 확인).
  final Completer<void>? hold;

  /// non-null = 결과에 `handoffRoute` 를 싣는다(확정 성공 표본 0 — K175).
  final String? route;

  final List<(SettingsActionId, Map<String, String>)> runs =
      <(SettingsActionId, Map<String, String>)>[];

  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) async {
    runs.add((id, args));
    if (hold != null) await hold!.future;
    if (fail) throw StateError('run failed');
    final ActionResult r = _resultFor(id);
    return route == null ? r : r.copyWith(handoffRoute: route);
  }
}

Future<(_Repo, RecordingLinkOpener)> _pump(
  WidgetTester t, {
  SettingsActions? actions,
}) async {
  t.view.physicalSize = const Size(800, 3000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final _Repo repo = _Repo();
  addTearDown(repo.close);
  final RecordingLinkOpener opener = RecordingLinkOpener();
  await t.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        safetyHandoverRepositoryProvider.overrideWithValue(repo),
        safetySettingsActionsProvider.overrideWithValue(actions),
        safetyLinkOpenerProvider.overrideWithValue(opener),
      ],
      child: const MaterialApp(home: Scaffold(body: HandoverWizardScreen())),
    ),
  );
  return (repo, opener);
}

Future<void> _show(WidgetTester t, _Repo repo, HandoverWizardVm vm) async {
  repo.c.add(vm);
  await t.pump();
  await t.pump();
}

List<String> _cards(WidgetTester t) => <String>[
  for (final Element e in find.byType(Card).evaluate())
    (e.widget.key! as ValueKey<String>).value,
];

Finder _actButtons() => find.byType(OutlinedButton);

/// 픽스처에서 `actions` 가 있는 첫 행의 (행 번호, 동작).
(int, List<SettingsActionCall>) _firstActionRow(HandoverWizardVm vm) {
  for (final (int i, HandoverWizardStepRow r) in vm.rows.indexed) {
    if (r.actions.isNotEmpty) return (i, r.actions);
  }
  throw StateError('no action row');
}

void main() {
  for (final MapEntry<String, String> f in _all.entries) {
    testWidgets('${f.key} — 글자 · 차례 · 버튼 = VM 그대로 · 넘침 0', (
      WidgetTester t,
    ) async {
      final (_Repo repo, _) = await _pump(t, actions: _Actions());
      final HandoverWizardVm vm = _vm(f.value);
      await _show(t, repo, vm);
      expect(t.takeException(), isNull);
      expect(find.text(vm.headline), findsWidgets);
      expect(find.text(vm.pathLabel), findsOneWidget);
      expect(find.text(vm.asOf.label), findsOneWidget);
      for (final (String? s, String k) in <(String?, String)>[
        (vm.noticeText, 'm511-notice'),
        (vm.lockedLabel, 'm511-locked'),
        (vm.doneLabel, 'm511-done'),
        (vm.coolingText, 'm511-cooling'),
        (vm.deadlineText, 'm511-deadline'),
        (vm.windowText, 'm511-window'),
      ]) {
        expect(find.byKey(Key(k)), s == null ? findsNothing : findsOneWidget);
      }
      expect(_cards(t), <String>[
        ?(vm.trial == null ? null : 'm511-trial'),
        for (int i = 0; i < vm.rows.length; i++) 'm511-step-$i',
      ]);
      for (final (int i, HandoverWizardStepRow r) in vm.rows.indexed) {
        final Finder card = find.byKey(Key('m511-step-$i'));
        for (final String s in <String>[
          r.step.title,
          r.step.whyLine,
          r.step.stateLabel,
        ]) {
          expect(
            find.descendant(of: card, matching: find.text(s)),
            findsOneWidget,
            reason: s,
          );
        }
        expect(
          find.byKey(Key('m511-link-$i')),
          r.link == null ? findsNothing : findsOneWidget,
        );
        for (final (int j, SettingsActionCall a) in r.actions.indexed) {
          final Finder b = find.byKey(Key('m511-act-$i-$j'));
          expect(b, findsOneWidget);
          expect(
            find.descendant(of: b, matching: find.text(a.label)),
            findsOneWidget,
          );
        }
      }
      expect(
        _actButtons(),
        findsNWidgets(
          vm.rows.fold<int>(
            0,
            (int n, HandoverWizardStepRow r) => n + r.actions.length,
          ),
        ),
      );
      final SimTrialCard? trial = vm.trial;
      if (trial != null) {
        final Finder card = find.byKey(const Key('m511-trial'));
        for (final String s in <String>[trial.headline, trial.summaryText]) {
          expect(
            find.descendant(of: card, matching: find.text(s)),
            findsOneWidget,
          );
        }
        for (final (int i, SimTrialCheck c) in trial.checks.indexed) {
          final Finder line = find.byKey(Key('m511-check-$i'));
          for (final String s in <String>[
            c.label,
            c.detailText,
            c.stateLabel,
          ]) {
            expect(
              find.descendant(of: line, matching: find.text(s)),
              findsOneWidget,
              reason: s,
            );
          }
        }
      } else {
        expect(find.byKey(const Key('m511-trial')), findsNothing);
      }
      // 🔴 코드 · 세션 id 를 그리지 않는다.
      for (final String s in <String>[
        ?vm.reasonCode,
        for (final HandoverWizardStepRow r in vm.rows) ...<String>[
          ?r.step.blockedReasonCode,
          r.step.stepId,
          for (final SettingsActionCall a in r.actions) ...a.args.values,
        ],
      ]) {
        expect(find.textContaining(s), findsNothing, reason: s);
      }
      expect(find.byType(Dialog), findsNothing);
    });
  }

  testWidgets('7단계 제목이 엔진 차례 그대로 보인다', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardS3Blocked);
    expect(vm.rows, hasLength(7));
    await _show(t, repo, vm);
    final List<double> ys = <double>[
      for (final HandoverWizardStepRow r in vm.rows)
        t.getTopLeft(find.text(r.step.title)).dy,
    ];
    expect(ys, orderedEquals(<double>[...ys]..sort()));
    expect(ys.toSet(), hasLength(7));
  });

  testWidgets('전제 밖(행 0) = 머리만 · 단계 카드 0', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardNotApplicable);
    expect(vm.rows, isEmpty);
    await _show(t, repo, vm);
    expect(find.byKey(const Key('m511-headline')), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  for (final (String name, String path, List<Map<String, String>> argsWant)
      in <(String, String, List<Map<String, String>>)>[
        (
          'S5 보관(KEEP)',
          FixturePaths.m5HandoverWizardFatePending,
          <Map<String, String>>[
            <String, String>{'fate': 'KEEP'},
          ],
        ),
        (
          'S6 시작',
          FixturePaths.m5HandoverWizardStartReady,
          <Map<String, String>>[
            <String, String>{'path': 'SIM_TO_AUTO'},
          ],
        ),
        (
          'S7 확정',
          FixturePaths.m5HandoverWizardCommitReady,
          <Map<String, String>>[
            <String, String>{'handover_session_id': 'hs_s2a_0111'},
          ],
        ),
        (
          'S7 취소(냉각)',
          FixturePaths.m5HandoverWizardCooling,
          <Map<String, String>>[
            <String, String>{'handover_session_id': 'hs_s2a_0111'},
          ],
        ),
      ]) {
    testWidgets('🔴 $name — 행의 id · args 그대로 run 1회 · 결과 = 엔진 headline', (
      WidgetTester t,
    ) async {
      final _Actions actions = _Actions();
      final (_Repo repo, RecordingLinkOpener opener) = await _pump(
        t,
        actions: actions,
      );
      final HandoverWizardVm vm = _vm(path);
      await _show(t, repo, vm);
      final (int i, List<SettingsActionCall> calls) = _firstActionRow(vm);
      await t.tap(find.byKey(Key('m511-act-$i-0')));
      await t.pump();
      await t.pump();
      expect(actions.runs, <(SettingsActionId, Map<String, String>)>[
        (calls.first.id, calls.first.args),
      ]);
      expect(<Map<String, String>>[
        for (final (SettingsActionId _, Map<String, String> a) in actions.runs)
          a,
      ], argsWant);
      final ActionResult r = _resultFor(calls.first.id);
      expect(find.byKey(const Key('m511-result')), findsOneWidget);
      expect(find.text(r.headline), findsOneWidget);
      final String? code = r.reasonCode;
      if (code != null) {
        expect(find.textContaining(code), findsNothing);
      } else {
        expect(r.level, UiLevel.ok);
      }
      expect(opener.opened, isEmpty);
      expect(find.byType(Dialog), findsNothing);
    });
  }

  testWidgets('🔴 S5 지우기(DISCARD) — 둘째 버튼 = 둘째 호출 그대로', (WidgetTester t) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(t, actions: actions);
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardFatePending);
    await _show(t, repo, vm);
    final (int i, List<SettingsActionCall> calls) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-1')));
    await t.pump();
    await t.pump();
    expect(actions.runs, hasLength(1));
    expect(actions.runs.single.$1, SettingsActionId.handoverSimLedgerFate);
    expect(actions.runs.single.$2, <String, String>{'fate': 'DISCARD'});
    expect(actions.runs, <(SettingsActionId, Map<String, String>)>[
      (calls[1].id, calls[1].args),
    ]);
  });

  testWidgets('🔴 S7 확정 버튼 둘(확정 · 취소) — 각자 자기 호출', (WidgetTester t) async {
    final _Actions actions = _Actions();
    final (_Repo repo, _) = await _pump(t, actions: actions);
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardCommitReady);
    await _show(t, repo, vm);
    final (int i, List<SettingsActionCall> calls) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-1')));
    await t.pump();
    await t.pump();
    expect(actions.runs, <(SettingsActionId, Map<String, String>)>[
      (calls[1].id, calls[1].args),
    ]);
    expect(actions.runs.single.$1, SettingsActionId.handoverSessionCancel);
  });

  testWidgets('🔴 도는 동안 모든 버튼 비활성 · 두 번 눌러도 run 1회', (WidgetTester t) async {
    final Completer<void> hold = Completer<void>();
    final _Actions actions = _Actions(hold: hold);
    final (_Repo repo, _) = await _pump(t, actions: actions);
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardFatePending);
    await _show(t, repo, vm);
    final (int i, _) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-0')));
    await t.pump();
    final List<OutlinedButton> buttons = t
        .widgetList<OutlinedButton>(_actButtons())
        .toList();
    expect(buttons, hasLength(2));
    expect(buttons.where((OutlinedButton b) => b.onPressed != null), isEmpty);
    await t.tap(find.byKey(Key('m511-act-$i-0')), warnIfMissed: false);
    await t.tap(find.byKey(Key('m511-act-$i-1')), warnIfMissed: false);
    await t.pump();
    expect(actions.runs, hasLength(1));
    hold.complete();
    await t.pump();
    await t.pump();
    expect(actions.runs, hasLength(1));
    expect(
      t
          .widgetList<OutlinedButton>(_actButtons())
          .where((OutlinedButton b) => b.onPressed == null),
      isEmpty,
    );
  });

  testWidgets('🔴 같은 프레임에 두 번 눌러도(다시 그리기 전) run 1회', (WidgetTester t) async {
    final Completer<void> hold = Completer<void>();
    final _Actions actions = _Actions(hold: hold);
    final (_Repo repo, _) = await _pump(t, actions: actions);
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardFatePending);
    await _show(t, repo, vm);
    final (int i, _) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-0')));
    await t.tap(find.byKey(Key('m511-act-$i-1')));
    await t.pump();
    expect(actions.runs, hasLength(1));
    hold.complete();
    await t.pump();
  });

  testWidgets('🔴 handoffRoute 가 오면 그대로 연다(K175)', (WidgetTester t) async {
    final _Actions actions = _Actions(route: AppRoutes.settingsOperations);
    final (_Repo repo, RecordingLinkOpener opener) = await _pump(
      t,
      actions: actions,
    );
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardCommitReady);
    await _show(t, repo, vm);
    final (int i, _) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-0')));
    await t.pump();
    await t.pump();
    expect(actions.runs, hasLength(1));
    expect(opener.opened, <String>[AppRoutes.settingsOperations]);
  });

  testWidgets('제출 자체 실패 = 정적 문장(접수증 아님)', (WidgetTester t) async {
    final (_Repo repo, RecordingLinkOpener opener) = await _pump(
      t,
      actions: _Actions(fail: true),
    );
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardStartReady);
    await _show(t, repo, vm);
    final (int i, _) = _firstActionRow(vm);
    await t.tap(find.byKey(Key('m511-act-$i-0')));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('m511-result-failed')), findsOneWidget);
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(const Key('m511-result')), findsNothing);
    expect(opener.opened, isEmpty);
  });

  testWidgets('🔴 링크 = deep_link 그대로 연다', (WidgetTester t) async {
    final (_Repo repo, RecordingLinkOpener opener) = await _pump(
      t,
      actions: _Actions(),
    );
    final HandoverWizardVm vm = _vm(FixturePaths.m5HandoverWizardS3Blocked);
    await _show(t, repo, vm);
    final List<String> want = <String>[];
    final List<(int, LinkAction)> links = <(int, LinkAction)>[
      for (final (int i, HandoverWizardStepRow r) in vm.rows.indexed)
        ?(r.link == null ? null : (i, r.link!)),
    ];
    expect(links, hasLength(3));
    for (final (int i, LinkAction l) in links) {
      await t.tap(find.byKey(Key('m511-link-$i')));
      await t.pump();
      want.add(l.deepLink);
    }
    expect(want, hasLength(links.length));
    expect(opener.opened, want);
  });

  testWidgets('🔴 쓰기 주입 null(뷰어) = 동작 버튼 0 · 링크는 그대로', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t);
    for (final String p in <String>[
      FixturePaths.m5HandoverWizardFatePending,
      FixturePaths.m5HandoverWizardStartReady,
      FixturePaths.m5HandoverWizardCommitReady,
      FixturePaths.m5HandoverWizardCooling,
    ]) {
      await _show(t, repo, _vm(p));
      expect(_actButtons(), findsNothing, reason: p);
    }
    await _show(t, repo, _vm(FixturePaths.m5HandoverWizardS3Blocked));
    expect(find.byType(TextButton), findsNWidgets(3));
  });

  testWidgets('🔴 잠김 · 확정됨 = 동작 버튼 0', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    for (final (String p, String k) in <(String, String)>[
      (FixturePaths.m5HandoverWizardLocked, 'm511-locked'),
      (FixturePaths.m5HandoverWizardCommitted, 'm511-done'),
    ]) {
      await _show(t, repo, _vm(p));
      expect(find.byKey(Key(k)), findsOneWidget);
      expect(_actButtons(), findsNothing, reason: p);
    }
  });

  testWidgets('잠김 = 동작이 실려 와도 화면은 동작 0(엔진이 비우는 것에 더한 이중 방어)', (
    WidgetTester t,
  ) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    final HandoverWizardVm ready = _vm(
      FixturePaths.m5HandoverWizardCommitReady,
    );
    await _show(t, repo, ready.copyWith(lockedLabel: '잠김'));
    expect(_actButtons(), findsNothing);
    await _show(t, repo, ready.copyWith(doneLabel: '확정됨'));
    expect(_actButtons(), findsNothing);
  });

  testWidgets('읽기 실패 = 실패 문장 · 읽는 중 = 진행 표시', (WidgetTester t) async {
    final (_Repo repo, _) = await _pump(t, actions: _Actions());
    expect(find.byKey(const Key('m511-loading')), findsOneWidget);
    repo.c.addError(StateError('read failed'));
    await t.pump();
    await t.pump();
    expect(find.byKey(const Key('m511-read-failed')), findsOneWidget);
    expect(find.text(SafetyLabels.handoverWizardReadFailed), findsOneWidget);
  });
}
