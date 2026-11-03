// test/onboarding_mode_pick_test.dart - O0B-01 ~ O0B-12 (O-00b operating mode pick).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

FakeShellOnboardingRepository _repoOf(
  Stream<OnboardingModeChoiceVm> Function(int call) modeChoice,
) => FakeShellOnboardingRepository(
  start: (int call) => Stream<OnboardingStartVm>.error(StateError('unused')),
  modeChoice: modeChoice,
);

typedef _PickCase = ({String name, int i});

typedef _SelectedCase = ({
  String name,
  OnboardingModeChoiceVm v,
  Key on,
  Key off,
  int other,
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

typedef _LockCase = ({
  String name,
  OnboardingModeChoiceVm v,
  List<SettingsActionId> want,
});

typedef _InjectCase = ({
  String name,
  SettingsActions? Function() actions,
  bool tappable,
});

typedef _StateCase = ({
  String name,
  Stream<OnboardingModeChoiceVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _TextCase = ({String name, OnboardingModeChoiceVm v});

void main() {
  final OnboardingModeChoiceVm unselected = singleFixture(
    FixturePaths.m8OnboardingModeUnselected,
    OnboardingModeChoiceVm.fromJson,
  );
  final OnboardingModeChoiceVm auto = singleFixture(
    FixturePaths.m8OnboardingModeAuto,
    OnboardingModeChoiceVm.fromJson,
  );
  final OnboardingModeChoiceVm advisory = singleFixture(
    FixturePaths.m8OnboardingModeAdvisory,
    OnboardingModeChoiceVm.fromJson,
  );
  final OnboardingModeChoiceVm locked = singleFixture(
    FixturePaths.m8OnboardingModeLocked,
    OnboardingModeChoiceVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m8OnboardingModeSelectResults,
    ActionResult.fromJson,
  ).rows;

  FakeShellOnboardingActions operatorOk() => FakeShellOnboardingActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );

  // O0B-01 entry: no card is chosen (no default).
  testWidgets('O0B-01 entry no card chosen', (WidgetTester tester) async {
    expect(unselected.selected, isNull); // pre
    expect(unselected.nextDeepLink, isNull); // pre
    expect(unselected.lockedLabel, isNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeShellOnboardingRepository repo = _repoOf(
      (int call) => one(unselected),
    );
    await pumpOnboardingModePick(
      tester,
      overrides: onboardingOverrides(
        repo: repo,
        actions: operatorOk(),
        opener: opener,
      ),
    );
    expect(repo.modeCalls, 1);

    final List<Finder> chain = <Finder>[
      find.byKey(const Key('o00b-headline')),
      find.byKey(const ValueKey<String>('o00b-card-0')),
      find.byKey(const Key('o00b-record-gap')),
      find.byKey(const Key('o00b-honesty')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('o00b-card-0'))).dy,
      tester.getTopLeft(find.byKey(const ValueKey<String>('o00b-card-1'))).dy,
    );

    expect(shownTexts(tester, find.byKey(const Key('o00b-headline'))), <String>[
      unselected.headline,
    ]);
    expect(unselected.options, hasLength(2));
    for (final (int i, OperatingModeOption o) in unselected.options.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('o00b-card-$i'))),
        modeCardTexts(o),
      );
      expect(find.byKey(ValueKey<String>('o00b-check-$i')), findsNothing);
    }
    expect(find.byKey(const ValueKey<String>('o00b-card-2')), findsNothing);
    expect(
      shownTexts(tester, find.byKey(const Key('o00b-record-gap'))),
      <String>[unselected.recordGapNotice],
    );
    expect(shownTexts(tester, find.byKey(const Key('o00b-honesty'))), <String>[
      unselected.honestyText,
    ]);
    expect(find.byKey(const Key('o00b-next')), findsNothing);
    expect(find.byKey(const Key('o00b-locked')), findsNothing);
    expect(find.byKey(const Key('o00b-result')), findsNothing);
    expect(find.byKey(const Key('o00b-not-accepted')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O0B-02 both cards are the same size and shape.
  testWidgets('O0B-02 cards same size and shape', (WidgetTester tester) async {
    await pumpOnboardingModePick(
      tester,
      overrides: onboardingOverrides(
        repo: _repoOf((int call) => one(unselected)),
        actions: operatorOk(),
        opener: RecordingLinkOpener(),
      ),
    );
    final Finder card0 = find.byKey(const ValueKey<String>('o00b-card-0'));
    final Finder card1 = find.byKey(const ValueKey<String>('o00b-card-1'));
    final Card a = tester.widget<Card>(card0);
    final Card b = tester.widget<Card>(card1);
    expect(tester.getSize(card0), tester.getSize(card1));
    expect(a.color, b.color);
    expect(a.elevation, b.elevation);
    expect(a.shape, b.shape);
    expect(a.margin, b.margin);
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: card0,
              matching: find.text(unselected.options[0].title),
            ),
          )
          .style,
      tester
          .widget<Text>(
            find.descendant(
              of: card1,
              matching: find.text(unselected.options[1].title),
            ),
          )
          .style,
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O0B-03 card tap = one run, whitelisted args, no optimistic update.
  final List<_PickCase> pickCases = <_PickCase>[
    (name: 'auto', i: 0),
    (name: 'advisory', i: 1),
  ];

  for (final _PickCase c in pickCases) {
    testWidgets('O0B-03 card tap run once ${c.name}', (
      WidgetTester tester,
    ) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeShellOnboardingActions actions = operatorOk();
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(unselected)),
          actions: actions,
          opener: opener,
        ),
      );
      await tester.tap(find.byKey(ValueKey<String>('o00b-card-${c.i}')));
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[
        SettingsActionId.onboardingOperatingModeSelect,
      ]);
      expect(actions.argsSeen, <Map<String, String>>[
        <String, String>{'operating_mode': unselected.options[c.i].mode.wire},
      ]);
      expect(opener.opened, <String>[]);
      expect(find.byKey(ValueKey<String>('o00b-check-${c.i}')), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-04 chosen state is data: check, next link, can still change.
  final List<_SelectedCase> selectedCases = <_SelectedCase>[
    (
      name: 'auto',
      v: auto,
      on: const ValueKey<String>('o00b-check-0'),
      off: const ValueKey<String>('o00b-check-1'),
      other: 1,
    ),
    (
      name: 'advisory',
      v: advisory,
      on: const ValueKey<String>('o00b-check-1'),
      off: const ValueKey<String>('o00b-check-0'),
      other: 0,
    ),
  ];

  for (final _SelectedCase c in selectedCases) {
    testWidgets('O0B-04 chosen state data ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(auto.options[0].mode, auto.selected); // pre
      expect(advisory.options[1].mode, advisory.selected); // pre
      expect(auto.nextDeepLink, isNotNull); // pre
      expect(advisory.nextDeepLink, isNotNull); // pre
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeShellOnboardingActions actions = operatorOk();
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: actions,
          opener: opener,
        ),
      );
      expect(find.byKey(c.on), findsOneWidget);
      expect(find.byKey(c.off), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('o00b-card-0'))),
        tester.getSize(find.byKey(const ValueKey<String>('o00b-card-1'))),
      );
      expect(actions.ids, <SettingsActionId>[]);
      await tester.tap(find.byKey(const Key('o00b-next')));
      await tester.pump();
      expect(opener.opened, <String>[c.v.nextDeepLink!]);
      await tester.tap(find.byKey(ValueKey<String>('o00b-card-${c.other}')));
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[
        SettingsActionId.onboardingOperatingModeSelect,
      ]);
      expect(actions.argsSeen, <Map<String, String>>[
        <String, String>{'operating_mode': c.v.options[c.other].mode.wire},
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-05 result line = engine headline + reason code as received.
  final List<_ResultCase> resultCases = <_ResultCase>[
    (name: 'accepted', r: results[0]),
    (name: 'rejected', r: results[1]),
  ];

  for (final _ResultCase c in resultCases) {
    testWidgets('O0B-05 result line engine text ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(results[0].reasonCode, isNull); // pre
      expect(results[1].reasonCode, isNotNull); // pre
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(unselected)),
          actions: FakeShellOnboardingActions(
            result: (int call) => Future<ActionResult>.value(c.r),
          ),
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('o00b-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('o00b-card-0'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('o00b-result'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('o00b-result'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('o00b-record-gap'))).dy,
        ),
      );
      expect(find.byKey(const Key('o00b-not-accepted')), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-06 failure <-> success: the three write-fragment cells move together.
  final List<_SwapCase> swapCases = <_SwapCase>[
    (
      name: 'fail_then_ok',
      result: (int call) => call == 0
          ? Future<ActionResult>.error(StateError('fail'))
          : Future<ActionResult>.value(results[0]),
      firstOn: const Key('o00b-not-accepted'),
      firstOff: const Key('o00b-result'),
      firstTexts: <String?>[ShellLabels.onboardingNotAccepted],
      secondOn: const Key('o00b-result'),
      secondOff: const Key('o00b-not-accepted'),
      secondTexts: <String?>[results[0].headline, ?results[0].reasonCode],
    ),
    (
      name: 'ok_then_fail',
      result: (int call) => call == 0
          ? Future<ActionResult>.value(results[0])
          : Future<ActionResult>.error(StateError('fail')),
      firstOn: const Key('o00b-result'),
      firstOff: const Key('o00b-not-accepted'),
      firstTexts: <String?>[results[0].headline, ?results[0].reasonCode],
      secondOn: const Key('o00b-not-accepted'),
      secondOff: const Key('o00b-result'),
      secondTexts: <String?>[ShellLabels.onboardingNotAccepted],
    ),
  ];

  for (final _SwapCase c in swapCases) {
    testWidgets('O0B-06 fail and ok swap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
        result: c.result,
      );
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(unselected)),
          actions: actions,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.firstOn), findsOneWidget);
      expect(find.byKey(c.firstOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.firstOn)), c.firstTexts);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('o00b-card-0'))).dy,
        lessThan(tester.getTopLeft(find.byKey(c.firstOn)).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(c.firstOn)).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('o00b-record-gap'))).dy,
        ),
      );
      await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.secondOn), findsOneWidget);
      expect(find.byKey(c.secondOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.secondOn)), c.secondTexts);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('o00b-card-0'))).dy,
        lessThan(tester.getTopLeft(find.byKey(c.secondOn)).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(c.secondOn)).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('o00b-record-gap'))).dy,
        ),
      );
      expect(actions.ids, <SettingsActionId>[
        SettingsActionId.onboardingOperatingModeSelect,
        SettingsActionId.onboardingOperatingModeSelect,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-07 no second write while waiting.
  testWidgets('O0B-07 no second tap while waiting', (
    WidgetTester tester,
  ) async {
    final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    await pumpOnboardingModePick(
      tester,
      overrides: onboardingOverrides(
        repo: _repoOf((int call) => one(unselected)),
        actions: actions,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
    await tester.tap(find.byKey(const ValueKey<String>('o00b-card-1')));
    await tester.pump();
    expect(actions.ids, <SettingsActionId>[
      SettingsActionId.onboardingOperatingModeSelect,
    ]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O0B-08 lock is data: no tap, no next.
  final List<_LockCase> lockCases = <_LockCase>[
    (name: 'locked', v: locked, want: <SettingsActionId>[]),
    (
      name: 'open',
      v: unselected,
      want: <SettingsActionId>[SettingsActionId.onboardingOperatingModeSelect],
    ),
  ];

  for (final _LockCase c in lockCases) {
    testWidgets('O0B-08 lock is data ${c.name}', (WidgetTester tester) async {
      expect(locked.lockedLabel, isNotNull); // pre
      expect(locked.nextDeepLink, isNull); // pre
      expect(unselected.lockedLabel, isNull); // pre
      final FakeShellOnboardingActions actions = operatorOk();
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: actions,
          opener: RecordingLinkOpener(),
        ),
      );
      final String? lock = c.v.lockedLabel;
      if (lock != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('o00b-locked'))),
          <String>[lock],
        );
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('o00b-card-0')))
              .dy,
          lessThan(tester.getTopLeft(find.byKey(const Key('o00b-locked'))).dy),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('o00b-locked'))).dy,
          lessThan(
            tester.getTopLeft(find.byKey(const Key('o00b-record-gap'))).dy,
          ),
        );
      } else {
        expect(find.byKey(const Key('o00b-locked')), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('o00b-card-0')),
          findsOneWidget,
        );
      }
      expect(find.byKey(const Key('o00b-next')), findsNothing);
      await tester.tap(find.byKey(const ValueKey<String>('o00b-card-0')));
      await tester.pump();
      expect(actions.ids, c.want);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-09 no injection (viewer) = no card tap.
  final List<_InjectCase> injectCases = <_InjectCase>[
    (name: 'viewer', actions: () => null, tappable: false),
    (name: 'operator', actions: operatorOk, tappable: true),
  ];

  for (final _InjectCase c in injectCases) {
    testWidgets('O0B-09 injection null no tap ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(unselected)),
          actions: c.actions(),
          opener: RecordingLinkOpener(),
        ),
      );
      for (final int i in <int>[0, 1]) {
        final InkWell ink = tester.widget<InkWell>(
          find.descendant(
            of: find.byKey(ValueKey<String>('o00b-card-$i')),
            matching: find.byType(InkWell),
          ),
        );
        expect(ink.onTap, c.tappable ? isNotNull : isNull);
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O0B-10 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<OnboardingModeChoiceVm>.multi(
        (MultiStreamController<OnboardingModeChoiceVm> c) {},
      ),
      present: <Key>[const Key('o00b-loading')],
      absent: <Key>[const Key('o00b-headline'), const Key('o00b-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) =>
          Stream<OnboardingModeChoiceVm>.error(StateError('fail')),
      present: <Key>[const Key('o00b-fail')],
      absent: <Key>[const Key('o00b-headline'), const Key('o00b-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(unselected),
      present: <Key>[const Key('o00b-fail')],
      absent: <Key>[const Key('o00b-headline'), const Key('o00b-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('O0B-10 state branch ${c.name}', (WidgetTester tester) async {
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf(c.stream),
          actions: operatorOk(),
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

  // O0B-11 retry.
  testWidgets('O0B-11 retry', (WidgetTester tester) async {
    final FakeShellOnboardingRepository repo = _repoOf(
      (int call) => call == 0
          ? Stream<OnboardingModeChoiceVm>.error(StateError('fail'))
          : one(unselected),
    );
    await pumpOnboardingModePick(
      tester,
      overrides: onboardingOverrides(
        repo: repo,
        actions: operatorOk(),
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('o00b-fail')), findsNothing);
    expect(find.byKey(const Key('o00b-headline')), findsOneWidget);
    expect(repo.modeCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O0B-12 every shown Text is engine text; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'unselected', v: unselected),
    (name: 'auto', v: auto),
    (name: 'advisory', v: advisory),
    (name: 'locked', v: locked),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('O0B-12 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpOnboardingModePick(
        tester,
        overrides: onboardingOverrides(
          repo: _repoOf((int call) => one(c.v)),
          actions: operatorOk(),
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = modePickAllowed(c.v);
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
