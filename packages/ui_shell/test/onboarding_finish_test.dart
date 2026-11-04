// test/onboarding_finish_test.dart - O04-01 ~ O04-13 (O-04 onboarding finish).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

ColorScheme csOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

(IconData, Color) wantStep(ColorScheme cs, StepState s) => switch (s) {
  StepState.notStarted => (Icons.radio_button_unchecked, cs.onSurfaceVariant),
  StepState.inProgress => (Icons.timelapse, cs.tertiary),
  StepState.verified => (Icons.check_circle_outline, cs.primary),
  StepState.failed => (Icons.error_outline, cs.error),
  StepState.expired => (Icons.update, cs.secondary),
};

(IconData, Color) wantGate(ColorScheme cs, GateState g) => switch (g) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};

Icon firstIconIn(WidgetTester tester, Key key) => tester.widget<Icon>(
  find.descendant(of: find.byKey(key), matching: find.byType(Icon)).first,
);

typedef _LineCase = ({String name, OnboardingFinishVm v});

typedef _SlotCase = ({
  String name,
  ShellSlotBuilder? Function(FakeShellSlotRecorder s) builder,
  bool shown,
});

typedef _ResultCase = ({String name, ActionResult r});

typedef _SwapCase = ({
  String name,
  Future<ActionResult> Function(int call) result,
  Key firstOn,
  Key firstOff,
  List<String?> firstTexts,
  Key secondOn,
  Key secondOff,
  List<String?> secondTexts,
});

typedef _DeclareCase = ({String name, OnboardingFinishVm v});

typedef _InjectCase = ({
  String name,
  SettingsActions? Function() actions,
  bool want,
});

typedef _StateCase = ({
  String name,
  Stream<OnboardingFinishVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _TextCase = ({String name, OnboardingFinishVm v});

void main() {
  final OnboardingFinishVm auto = singleFixture(
    FixturePaths.m8OnboardingFinishAuto,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm autoReady = singleFixture(
    FixturePaths.m8OnboardingFinishAutoReady,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm autoDeclared = singleFixture(
    FixturePaths.m8OnboardingFinishAutoDeclared,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm advisory = singleFixture(
    FixturePaths.m8OnboardingFinishAdvisory,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm declared = singleFixture(
    FixturePaths.m8OnboardingFinishAdvisoryDeclared,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm noExp = singleFixture(
    FixturePaths.m8OnboardingFinishNoExpectation,
    OnboardingFinishVm.fromJson,
  );
  final OnboardingFinishVm done = singleFixture(
    FixturePaths.m8OnboardingFinishDone,
    OnboardingFinishVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m8OnboardingFinishResults,
    ActionResult.fromJson,
  ).rows;

  FakeShellOnboardingActions operatorOk() => FakeShellOnboardingActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );

  FakeShellFinishRepository repoOf(OnboardingFinishVm v) =>
      FakeShellFinishRepository(finish: (int call) => one(v));

  // O04-01 six stages in received order, texts per stage, one subscription.
  testWidgets('O04-01 stages order texts', (WidgetTester tester) async {
    expect(auto.stages, hasLength(6));
    final FakeShellFinishRepository repo = repoOf(auto);
    await pumpFinish(
      tester,
      overrides: finishOverrides(
        repo: repo,
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(repo.finishCalls, 1);
    expect(shownTexts(tester, find.byKey(const Key('o04-headline'))), <String>[
      auto.headline,
    ]);
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('o04-headline')),
      for (final (int i, _) in auto.stages.indexed)
        find.byKey(ValueKey<String>('o04-stage-$i')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }
    for (final (int i, OnboardingFinishStage s) in auto.stages.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('o04-stage-$i'))),
        stageTexts(s),
      );
    }
    expect(find.byKey(const ValueKey<String>('o04-check-0')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O04-02 expectation line is data: present and absent sides.
  final List<_LineCase> lineCases = <_LineCase>[
    (name: 'with_line', v: auto),
    (name: 'no_line', v: noExp),
  ];

  for (final _LineCase c in lineCases) {
    testWidgets('O04-02 expectation line ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(auto.stages[0].expectationLine, isNotNull); // pre
      expect(noExp.stages[0].expectationLine, isNull); // pre
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(c.v),
          actions: operatorOk(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const ValueKey<String>('o04-stage-0'))),
        stageTexts(c.v.stages[0]),
      );
      final String? exp = c.v.stages[0].expectationLine;
      if (exp != null) {
        expect(find.text(exp), findsOneWidget);
      } else {
        expect(find.text(auto.stages[0].expectationLine!), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('o04-stage-0')),
          findsOneWidget,
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-03 secret places = slot builder only; closed stages have none.
  final List<_SlotCase> slotCases = <_SlotCase>[
    (
      name: 'builder',
      builder: (FakeShellSlotRecorder s) => s.build,
      shown: true,
    ),
    (
      name: 'no_builder',
      builder: (FakeShellSlotRecorder s) => null,
      shown: false,
    ),
  ];

  for (final _SlotCase c in slotCases) {
    testWidgets('O04-03 secret slot ${c.name}', (WidgetTester tester) async {
      expect(auto.stages[1].slotId, isNotNull); // pre
      expect(auto.stages[2].slotId, isNull); // pre
      final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(auto),
          actions: operatorOk(),
          slots: c.builder(slots),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        slots.slotIds,
        c.shown
            ? <String>[
                for (final OnboardingFinishStage s in auto.stages) ?s.slotId,
              ]
            : <String>[],
      );
      for (final (int i, OnboardingFinishStage s) in auto.stages.indexed) {
        expect(
          find.byKey(ValueKey<String>('o04-slot-$i')),
          c.shown && s.slotId != null ? findsOneWidget : findsNothing,
        );
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-04 gate three phases: unknown differs from not applicable.
  testWidgets('O04-04 gate phases', (WidgetTester tester) async {
    expect(auto.stages[3].gate?.state, GateState.unknown); // pre
    expect(auto.stages[4].gate?.state, GateState.notApplicable); // pre
    await pumpFinish(
      tester,
      overrides: finishOverrides(
        repo: repoOf(auto),
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    final ColorScheme cs = csOf(tester);
    for (final (int i, OnboardingFinishStage s) in auto.stages.indexed) {
      expect(
        find.byKey(ValueKey<String>('o04-gate-$i')),
        s.gate != null ? findsOneWidget : findsNothing,
      );
    }
    final Iterable<(int, OnboardingFinishStage)> gated = auto.stages.indexed
        .where(((int, OnboardingFinishStage) e) => e.$2.gate != null);
    for (final (int, OnboardingFinishStage) e in gated) {
      final Icon icon = firstIconIn(
        tester,
        ValueKey<String>('o04-gate-${e.$1}'),
      );
      final (IconData, Color) want = wantGate(cs, e.$2.gate!.state);
      expect(icon.icon, want.$1);
      expect(icon.color, want.$2);
    }
    expect(
      firstIconIn(tester, const ValueKey<String>('o04-gate-3')).icon,
      isNot(firstIconIn(tester, const ValueKey<String>('o04-gate-4')).icon),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O04-05 stage action = one run with the engine action as received.
  testWidgets('O04-05 stage action run once', (WidgetTester tester) async {
    expect(autoDeclared.stages[5].action, isNotNull); // pre
    final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    await pumpFinish(
      tester,
      overrides: finishOverrides(
        repo: repoOf(autoDeclared),
        actions: actions,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    for (final (int i, OnboardingFinishStage s)
        in autoDeclared.stages.indexed) {
      expect(
        find.byKey(ValueKey<String>('o04-action-$i')),
        s.action != null ? findsOneWidget : findsNothing,
      );
    }
    await tester.tap(find.byKey(const ValueKey<String>('o04-action-5')));
    await tester.pump();
    expect(actions.ids, <SettingsActionId>[?autoDeclared.stages[5].action?.id]);
    expect(actions.argsSeen, <Map<String, String>>[
      ?autoDeclared.stages[5].action?.args,
    ]);
    expect(find.byKey(const ValueKey<String>('o04-action-5')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O04-06 result line: headline and raw code, no code when null.
  final List<_ResultCase> resultCases = <_ResultCase>[
    (name: 'accepted', r: results[0]),
    (name: 'failed_code', r: results[1]),
  ];

  for (final _ResultCase c in resultCases) {
    testWidgets('O04-06 result texts ${c.name}', (WidgetTester tester) async {
      expect(results[0].reasonCode, isNull); // pre
      expect(results[1].reasonCode, isNotNull); // pre
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(autoDeclared),
          actions: FakeShellOnboardingActions(
            result: (int call) => Future<ActionResult>.value(c.r),
          ),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('o04-action-5')));
      await tester.pump();
      await tester.pump();
      expect(shownTexts(tester, find.byKey(const Key('o04-result'))), <String?>[
        c.r.headline,
        ?c.r.reasonCode,
      ]);
      expect(find.byKey(const Key('o04-not-accepted')), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-07 failure <-> success: both directions.
  final List<_SwapCase> swapCases = <_SwapCase>[
    (
      name: 'fail_then_ok',
      result: (int call) => call == 0
          ? Future<ActionResult>.error(StateError('fail'))
          : Future<ActionResult>.value(results[0]),
      firstOn: const Key('o04-not-accepted'),
      firstOff: const Key('o04-result'),
      firstTexts: <String?>[ShellLabels.onboardingNotAccepted],
      secondOn: const Key('o04-result'),
      secondOff: const Key('o04-not-accepted'),
      secondTexts: <String?>[results[0].headline, ?results[0].reasonCode],
    ),
    (
      name: 'ok_then_fail',
      result: (int call) => call == 0
          ? Future<ActionResult>.value(results[0])
          : Future<ActionResult>.error(StateError('fail')),
      firstOn: const Key('o04-result'),
      firstOff: const Key('o04-not-accepted'),
      firstTexts: <String?>[results[0].headline, ?results[0].reasonCode],
      secondOn: const Key('o04-not-accepted'),
      secondOff: const Key('o04-result'),
      secondTexts: <String?>[ShellLabels.onboardingNotAccepted],
    ),
  ];

  for (final _SwapCase c in swapCases) {
    testWidgets('O04-07 fail and ok swap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
        result: c.result,
      );
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(autoDeclared),
          actions: actions,
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('o04-action-5')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.firstOn), findsOneWidget);
      expect(find.byKey(c.firstOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.firstOn)), c.firstTexts);
      await tester.tap(find.byKey(const ValueKey<String>('o04-action-5')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.secondOn), findsOneWidget);
      expect(find.byKey(c.secondOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.secondOn)), c.secondTexts);
      expect(actions.ids, <SettingsActionId>[
        ?autoDeclared.stages[5].action?.id,
        ?autoDeclared.stages[5].action?.id,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-08 start state declaration = stage six link (two branches).
  final List<_DeclareCase> declareCases = <_DeclareCase>[
    (name: 'auto_ready', v: autoReady),
    (name: 'advisory', v: advisory),
    (name: 'auto_declared', v: autoDeclared),
    (name: 'declared', v: declared),
  ];

  for (final _DeclareCase c in declareCases) {
    testWidgets('O04-08 declaration link ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(autoReady.stages[5].link, isNotNull); // pre
      expect(advisory.stages[5].link, isNotNull); // pre
      expect(autoDeclared.stages[5].link, isNull); // pre
      expect(declared.stages[5].link, isNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(c.v),
          actions: operatorOk(),
          slots: FakeShellSlotRecorder().build,
          opener: opener,
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const ValueKey<String>('o04-stage-5'))),
        stageTexts(c.v.stages[5]),
      );
      final LinkAction? link = c.v.stages[5].link;
      if (link != null) {
        expect(
          find.byKey(const ValueKey<String>('o04-action-5')),
          findsNothing,
        );
        await tester.tap(find.byKey(const ValueKey<String>('o04-link-5')));
        await tester.pump();
        expect(opener.opened, <String>[link.deepLink]);
      } else {
        expect(find.byKey(const ValueKey<String>('o04-link-5')), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('o04-action-5')),
          findsOneWidget,
        );
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-09 no injection (viewer) = no action button; operator contrast.
  final List<_InjectCase> injectCases = <_InjectCase>[
    (name: 'viewer', actions: () => null, want: false),
    (name: 'operator', actions: operatorOk, want: true),
  ];

  for (final _InjectCase c in injectCases) {
    testWidgets('O04-09 injection null no button ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(autoDeclared),
          actions: c.actions(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        find.byKey(const ValueKey<String>('o04-action-5')),
        c.want ? findsOneWidget : findsNothing,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O04-10 done sentence and the server verdict check lines.
  testWidgets('O04-10 done and checks', (WidgetTester tester) async {
    expect(done.doneLabel, isNotNull); // pre
    expect(done.checks, isNotEmpty); // pre
    await pumpFinish(
      tester,
      overrides: finishOverrides(
        repo: repoOf(done),
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    final ColorScheme cs = csOf(tester);
    expect(shownTexts(tester, find.byKey(const Key('o04-done'))), <String?>[
      done.doneLabel,
    ]);
    for (final (int i, OnboardingFinishCheck k) in done.checks.indexed) {
      final Key key = ValueKey<String>('o04-check-$i');
      expect(shownTexts(tester, find.byKey(key)), <String?>[k.label]);
      final Icon icon = firstIconIn(tester, key);
      final (IconData, Color) want = wantStep(cs, k.state);
      expect(icon.icon, want.$1);
      expect(icon.color, want.$2);
    }
    for (final (int i, _) in done.stages.indexed) {
      expect(find.byKey(ValueKey<String>('o04-action-$i')), findsNothing);
      expect(find.byKey(ValueKey<String>('o04-link-$i')), findsNothing);
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O04-11 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<OnboardingFinishVm>.multi(
        (MultiStreamController<OnboardingFinishVm> c) {},
      ),
      present: <Key>[const Key('o04-loading')],
      absent: <Key>[const Key('o04-headline'), const Key('o04-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) =>
          Stream<OnboardingFinishVm>.error(StateError('fail')),
      present: <Key>[const Key('o04-fail')],
      absent: <Key>[const Key('o04-headline'), const Key('o04-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(auto),
      present: <Key>[const Key('o04-fail')],
      absent: <Key>[const Key('o04-headline'), const Key('o04-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('O04-11 state branch ${c.name}', (WidgetTester tester) async {
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: FakeShellFinishRepository(finish: c.stream),
          actions: operatorOk(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      for (final Key k in c.present) {
        expect(find.byKey(k), findsOneWidget);
      }
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // O04-12 retry.
  testWidgets('O04-12 retry', (WidgetTester tester) async {
    final FakeShellFinishRepository repo = FakeShellFinishRepository(
      finish: (int call) => call == 0
          ? Stream<OnboardingFinishVm>.error(StateError('fail'))
          : one(auto),
    );
    await pumpFinish(
      tester,
      overrides: finishOverrides(
        repo: repo,
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('o04-fail')), findsNothing);
    expect(find.byKey(const Key('o04-headline')), findsOneWidget);
    expect(repo.finishCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O04-13 every shown Text is engine text; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'auto', v: auto),
    (name: 'advisory', v: advisory),
    (name: 'done', v: done),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('O04-13 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpFinish(
        tester,
        overrides: finishOverrides(
          repo: repoOf(c.v),
          actions: operatorOk(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = finishAllowed(c.v, null);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }
}
