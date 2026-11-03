// test/onboarding_step_list_test.dart - O01-01 ~ O01-09 (O-01 step list).

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

FakeShellStepRepository listRepo(
  Stream<OnboardingStepsVm> Function(int call) steps,
) => FakeShellStepRepository(
  steps: steps,
  detail: (int call) =>
      Stream<OnboardingStepDetailVm>.error(StateError('unused')),
);

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

typedef _TapCase = ({String name, int k, List<String> want});

typedef _FinishCase = ({String name, OnboardingStepsVm v, String? want});

typedef _StateCase = ({
  String name,
  Stream<OnboardingStepsVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _TextCase = ({String name, OnboardingStepsVm v});

void main() {
  final OnboardingStepsVm fresh = singleFixture(
    FixturePaths.m8OnboardingStepsFresh,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm advisory = singleFixture(
    FixturePaths.m8OnboardingStepsAdvisory,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm ready = singleFixture(
    FixturePaths.m8OnboardingStepsFinishReady,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm readyWarn = singleFixture(
    FixturePaths.m8OnboardingStepsFinishReadyWarn,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm locked = singleFixture(
    FixturePaths.m8OnboardingStepsAllVerifiedLocked,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm empty = singleFixture(
    FixturePaths.m8OnboardingStepsEmpty,
    OnboardingStepsVm.fromJson,
  );
  final int linkedAt = fresh.rows.indexWhere(
    (OnboardingStep r) => r.detailDeepLink != null,
  );
  final int unlinkedAt = fresh.rows.indexWhere(
    (OnboardingStep r) => r.detailDeepLink == null,
  );

  // O01-01 progress text, row texts, received order.
  testWidgets('O01-01 progress rows order', (WidgetTester tester) async {
    expect(fresh.finishDeepLink, isNull); // pre
    expect(fresh.emptyLabel, isNull); // pre
    final FakeShellStepRepository repo = listRepo((int call) => one(fresh));
    await pumpStepList(
      tester,
      overrides: stepOverrides(
        repo: repo,
        actions: UnimplementedSettingsActions(),
        slots: null,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(repo.listCalls, 1);
    expect(shownTexts(tester, find.byKey(const Key('o01-progress'))), <String>[
      fresh.progressText,
    ]);
    expect(fresh.rows, hasLength(12));
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('o01-progress')),
      for (final (int i, _) in fresh.rows.indexed)
        find.byKey(ValueKey<String>('o01-row-$i')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }
    for (final (int i, OnboardingStep s) in fresh.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('o01-row-$i'))),
        stepRowTexts(s),
      );
    }
    expect(find.byKey(const Key('o01-finish')), findsNothing);
    expect(find.byKey(const Key('o01-empty')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O01-02 state icon = all five StepState values.
  testWidgets('O01-02 state icons all values', (WidgetTester tester) async {
    expect(
      fresh.rows.map((OnboardingStep r) => r.state).toSet(),
      StepState.values.toSet(),
    ); // pre
    await pumpStepList(
      tester,
      overrides: stepOverrides(
        repo: listRepo((int call) => one(fresh)),
        actions: UnimplementedSettingsActions(),
        slots: null,
        opener: RecordingLinkOpener(),
      ),
    );
    final ColorScheme cs = csOf(tester);
    for (final (int i, OnboardingStep s) in fresh.rows.indexed) {
      final Icon icon = firstIconIn(tester, ValueKey<String>('o01-row-$i'));
      final (IconData, Color) want = wantStep(cs, s.state);
      expect(icon.icon, want.$1);
      expect(icon.color, want.$2);
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O01-03 gate three phases: unknown is not notApplicable.
  testWidgets('O01-03 gate marks', (WidgetTester tester) async {
    expect(
      fresh.rows.where(
        (OnboardingStep r) => r.gate?.state == GateState.unknown,
      ),
      isNotEmpty,
    ); // pre
    await pumpStepList(
      tester,
      overrides: stepOverrides(
        repo: listRepo((int call) => one(fresh)),
        actions: UnimplementedSettingsActions(),
        slots: null,
        opener: RecordingLinkOpener(),
      ),
    );
    final ColorScheme cs = csOf(tester);
    for (final (int i, OnboardingStep s) in fresh.rows.indexed) {
      final GateBadge? g = s.gate;
      if (g != null) {
        final Icon icon = firstIconIn(tester, ValueKey<String>('o01-gate-$i'));
        final (IconData, Color) want = wantGate(cs, g.state);
        expect(icon.icon, want.$1);
        expect(icon.color, want.$2);
      } else {
        expect(find.byKey(ValueKey<String>('o01-gate-$i')), findsNothing);
      }
    }
    final int unknownAt = fresh.rows.indexWhere(
      (OnboardingStep r) => r.gate?.state == GateState.unknown,
    );
    final int naAt = fresh.rows.indexWhere(
      (OnboardingStep r) => r.gate?.state == GateState.notApplicable,
    );
    expect(
      firstIconIn(tester, ValueKey<String>('o01-gate-$unknownAt')).icon,
      isNot(firstIconIn(tester, ValueKey<String>('o01-gate-$naAt')).icon),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O01-04 row tap = detailDeepLink as received.
  final List<_TapCase> tapCases = <_TapCase>[
    (
      name: 'linked',
      k: linkedAt,
      want: <String>[fresh.rows[linkedAt].detailDeepLink!],
    ),
    (name: 'unlinked', k: unlinkedAt, want: <String>[]),
  ];

  for (final _TapCase c in tapCases) {
    testWidgets('O01-04 row tap ${c.name}', (WidgetTester tester) async {
      expect(linkedAt, greaterThanOrEqualTo(0)); // pre
      expect(unlinkedAt, greaterThanOrEqualTo(0)); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpStepList(
        tester,
        overrides: stepOverrides(
          repo: listRepo((int call) => one(fresh)),
          actions: UnimplementedSettingsActions(),
          slots: null,
          opener: opener,
        ),
      );
      await tester.tap(find.byKey(ValueKey<String>('o01-row-${c.k}')));
      await tester.pump();
      expect(opener.opened, c.want);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O01-05 next = finishDeepLink as data.
  final List<_FinishCase> finishCases = <_FinishCase>[
    (name: 'ready', v: ready, want: ready.finishDeepLink),
    (name: 'fresh', v: fresh, want: null),
    (name: 'locked', v: locked, want: null),
    (name: 'ready_warn', v: readyWarn, want: readyWarn.finishDeepLink),
  ];

  for (final _FinishCase c in finishCases) {
    testWidgets('O01-05 next is data ${c.name}', (WidgetTester tester) async {
      expect(ready.finishDeepLink, isNotNull); // pre
      expect(fresh.finishDeepLink, isNull); // pre
      expect(locked.finishDeepLink, isNull); // pre
      expect(
        locked.rows.every((OnboardingStep r) => r.state == StepState.verified),
        isTrue,
      ); // pre
      expect(readyWarn.finishDeepLink, isNotNull); // pre
      expect(
        readyWarn.rows.any((OnboardingStep r) => r.state != StepState.verified),
        isTrue,
      ); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpStepList(
        tester,
        overrides: stepOverrides(
          repo: listRepo((int call) => one(c.v)),
          actions: UnimplementedSettingsActions(),
          slots: null,
          opener: opener,
        ),
      );
      final String? want = c.want;
      if (want != null) {
        await tester.tap(find.byKey(const Key('o01-finish')));
        await tester.pump();
        expect(opener.opened, <String>[want]);
      } else {
        expect(find.byKey(const Key('o01-finish')), findsNothing);
        expect(find.byKey(const ValueKey<String>('o01-row-0')), findsOneWidget);
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O01-06 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<OnboardingStepsVm>.multi(
        (MultiStreamController<OnboardingStepsVm> c) {},
      ),
      present: <Key>[const Key('o01-loading')],
      absent: <Key>[const Key('o01-progress'), const Key('o01-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) => Stream<OnboardingStepsVm>.error(StateError('fail')),
      present: <Key>[const Key('o01-fail')],
      absent: <Key>[const Key('o01-progress'), const Key('o01-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(fresh),
      present: <Key>[const Key('o01-fail')],
      absent: <Key>[const Key('o01-progress'), const Key('o01-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('O01-06 state branch ${c.name}', (WidgetTester tester) async {
      await pumpStepList(
        tester,
        overrides: stepOverrides(
          repo: listRepo(c.stream),
          actions: UnimplementedSettingsActions(),
          slots: null,
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

  // O01-07 retry.
  testWidgets('O01-07 retry', (WidgetTester tester) async {
    final FakeShellStepRepository repo = listRepo(
      (int call) => call == 0
          ? Stream<OnboardingStepsVm>.error(StateError('fail'))
          : one(fresh),
    );
    await pumpStepList(
      tester,
      overrides: stepOverrides(
        repo: repo,
        actions: UnimplementedSettingsActions(),
        slots: null,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('o01-fail')), findsNothing);
    expect(find.byKey(const Key('o01-progress')), findsOneWidget);
    expect(repo.listCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O01-08 every shown Text is engine text; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'fresh', v: fresh),
    (name: 'advisory', v: advisory),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('O01-08 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpStepList(
        tester,
        overrides: stepOverrides(
          repo: listRepo((int call) => one(c.v)),
          actions: UnimplementedSettingsActions(),
          slots: null,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = stepListAllowed(c.v);
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

  // O01-09 empty sentence = emptyLabel data.
  testWidgets('O01-09 empty label is data', (WidgetTester tester) async {
    expect(empty.rows, isEmpty); // pre
    expect(empty.emptyLabel, isNotNull); // pre
    await pumpStepList(
      tester,
      overrides: stepOverrides(
        repo: listRepo((int call) => one(empty)),
        actions: UnimplementedSettingsActions(),
        slots: null,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('o01-empty'))), <String?>[
      empty.emptyLabel,
    ]);
    expect(find.byKey(const ValueKey<String>('o01-row-0')), findsNothing);
    expect(find.byKey(const Key('o01-progress')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
