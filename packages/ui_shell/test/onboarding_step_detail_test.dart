// test/onboarding_step_detail_test.dart - O02-01 ~ O03-07 (O-02 step detail, O-03 verify result).

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

FakeShellStepRepository detailRepo(
  Stream<OnboardingStepDetailVm> Function(int call) detail,
) => FakeShellStepRepository(
  steps: (int call) => Stream<OnboardingStepsVm>.error(StateError('unused')),
  detail: detail,
);

(IconData, Color) wantResult(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

typedef _SlotCase = ({
  String name,
  OnboardingStepDetailVm v,
  ShellSlotBuilder? Function(FakeShellSlotRecorder s) builder,
  bool present,
  List<String> slotIds,
});

typedef _StateCase = ({
  String name,
  Stream<OnboardingStepDetailVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _ResultCase = ({String name, ActionResult r, List<String> tail});

typedef _RetryCase = ({
  String name,
  ActionResult r,
  bool retry,
  Future<void> Function(WidgetTester t) flow,
  List<SettingsActionId> want,
});

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

typedef _InjectCase = ({
  String name,
  SettingsActions? Function() actions,
  bool want,
});

typedef _TextCase = ({String name, OnboardingStepDetailVm v});

void main() {
  final OnboardingStepDetailVm kisMock = singleFixture(
    FixturePaths.m8OnboardingStepDetailKisMock,
    OnboardingStepDetailVm.fromJson,
  );
  final OnboardingStepDetailVm noVerify = singleFixture(
    FixturePaths.m8OnboardingStepDetailNoVerify,
    OnboardingStepDetailVm.fromJson,
  );
  final OnboardingStepDetailVm missingV = singleFixture(
    FixturePaths.m8OnboardingStepDetailMissing,
    OnboardingStepDetailVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m8OnboardingVerifyResults,
    ActionResult.fromJson,
  ).rows;
  final String askedId = kisMock.step!.stepId;

  FakeShellOnboardingActions operatorOk() => FakeShellOnboardingActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );

  // O02-01 detail texts, received order, one subscription.
  testWidgets('O02-01 detail texts order', (WidgetTester tester) async {
    expect(kisMock.step, isNotNull); // pre
    expect(kisMock.whereText, isNotNull); // pre
    expect(kisMock.howText, isNotNull); // pre
    final FakeShellStepRepository repo = detailRepo((int call) => one(kisMock));
    final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
    await pumpStepDetail(
      tester,
      stepId: askedId,
      overrides: stepOverrides(
        repo: repo,
        actions: operatorOk(),
        slots: slots.build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(repo.stepIds, <String>[askedId]);
    final OnboardingStep s = kisMock.step!;
    expect(shownTexts(tester, find.byKey(const Key('o02-head'))), <String>[
      s.title,
      s.whyLine,
      s.estimatedText,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('o02-where'))), <String?>[
      kisMock.whereText,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('o02-how'))), <String?>[
      kisMock.howText,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('o03-run'))), <String?>[
      kisMock.verify!.label,
    ]);
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('o02-head')),
      find.byKey(const Key('o02-where')),
      find.byKey(const Key('o02-how')),
      find.byKey(const Key('o02-secret')),
      find.byKey(const Key('o03-run')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O02-02 unknown id = missingLabel value (not an error screen).
  testWidgets('O02-02 missing label is data', (WidgetTester tester) async {
    expect(missingV.step, isNull); // pre
    expect(missingV.missingLabel, isNotNull); // pre
    await pumpStepDetail(
      tester,
      stepId: askedId,
      overrides: stepOverrides(
        repo: detailRepo((int call) => one(missingV)),
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('o02-missing'))), <String?>[
      missingV.missingLabel,
    ]);
    expect(find.byKey(const Key('o02-head')), findsNothing);
    expect(find.byKey(const Key('o03-run')), findsNothing);
    expect(find.byKey(const Key('o02-fail')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O02-03 secret place = slot builder only.
  final List<_SlotCase> slotCases = <_SlotCase>[
    (
      name: 'slot',
      v: kisMock,
      builder: (FakeShellSlotRecorder s) => s.build,
      present: true,
      slotIds: <String>[kisMock.secretSlotId!],
    ),
    (
      name: 'no_builder',
      v: kisMock,
      builder: (FakeShellSlotRecorder s) => null,
      present: false,
      slotIds: <String>[],
    ),
    (
      name: 'no_slot',
      v: noVerify,
      builder: (FakeShellSlotRecorder s) => s.build,
      present: false,
      slotIds: <String>[],
    ),
  ];

  for (final _SlotCase c in slotCases) {
    testWidgets('O02-03 secret slot ${c.name}', (WidgetTester tester) async {
      final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
      final ShellSlotBuilder? builder = c.builder(slots);
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(c.v)),
          actions: operatorOk(),
          slots: builder,
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        find.byKey(const Key('o02-secret')),
        c.present ? findsOneWidget : findsNothing,
      );
      expect(slots.slotIds, c.slotIds);
      for (final String id in c.slotIds) {
        expect(find.byKey(ValueKey<String>('fake-slot-$id')), findsOneWidget);
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O02-04 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<OnboardingStepDetailVm>.multi(
        (MultiStreamController<OnboardingStepDetailVm> c) {},
      ),
      present: <Key>[const Key('o02-loading')],
      absent: <Key>[const Key('o02-head'), const Key('o02-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) =>
          Stream<OnboardingStepDetailVm>.error(StateError('fail')),
      present: <Key>[const Key('o02-fail')],
      absent: <Key>[const Key('o02-head'), const Key('o02-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(kisMock),
      present: <Key>[const Key('o02-fail')],
      absent: <Key>[const Key('o02-head'), const Key('o02-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('O02-04 state branch ${c.name}', (WidgetTester tester) async {
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo(c.stream),
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

  // O02-05 retry.
  testWidgets('O02-05 retry', (WidgetTester tester) async {
    final FakeShellStepRepository repo = detailRepo(
      (int call) => call == 0
          ? Stream<OnboardingStepDetailVm>.error(StateError('fail'))
          : one(kisMock),
    );
    await pumpStepDetail(
      tester,
      stepId: askedId,
      overrides: stepOverrides(
        repo: repo,
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('o02-fail')), findsNothing);
    expect(find.byKey(const Key('o02-head')), findsOneWidget);
    expect(repo.stepIds, <String>[askedId, askedId]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O02-06 head expiry text is data (absent side).
  testWidgets('O02-06 head without expiry text', (WidgetTester tester) async {
    expect(noVerify.step, isNotNull); // pre
    expect(noVerify.step!.verifiedUntilText, isNull); // pre
    await pumpStepDetail(
      tester,
      stepId: noVerify.step!.stepId,
      overrides: stepOverrides(
        repo: detailRepo((int call) => one(noVerify)),
        actions: operatorOk(),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    final OnboardingStep s = noVerify.step!;
    expect(shownTexts(tester, find.byKey(const Key('o02-head'))), <String?>[
      s.title,
      s.whyLine,
      s.estimatedText,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O03-01 verify button = one run with the engine action as received.
  testWidgets('O03-01 verify run once', (WidgetTester tester) async {
    final FakeShellOnboardingActions actions = operatorOk();
    await pumpStepDetail(
      tester,
      stepId: askedId,
      overrides: stepOverrides(
        repo: detailRepo((int call) => one(kisMock)),
        actions: actions,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.byKey(const Key('o03-run')));
    await tester.pump();
    expect(actions.ids, <SettingsActionId>[kisMock.verify!.id]);
    expect(actions.argsSeen, <Map<String, String>>[kisMock.verify!.args]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // O03-02 result three phases, raw code.
  final List<_ResultCase> resultCases = <_ResultCase>[
    (name: 'ok', r: results[0], tail: <String>[]),
    (name: 'fail_retry', r: results[1], tail: <String>[ShellLabels.retry]),
    (name: 'fail_final', r: results[2], tail: <String>[]),
  ];

  for (final _ResultCase c in resultCases) {
    testWidgets('O03-02 result texts ${c.name}', (WidgetTester tester) async {
      expect(results[0].reasonCode, isNull); // pre
      expect(results[1].retryable, isTrue); // pre
      expect(results[2].reasonCode, isNotNull); // pre
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(kisMock)),
          actions: FakeShellOnboardingActions(
            result: (int call) => Future<ActionResult>.value(c.r),
          ),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const Key('o03-run')));
      await tester.pump();
      await tester.pump();
      expect(shownTexts(tester, find.byKey(const Key('o03-result'))), <String?>[
        c.r.headline,
        ?c.r.reasonCode,
        ...c.tail,
      ]);
      expect(
        find.byKey(const Key('o03-retry')),
        c.r.retryable ? findsOneWidget : findsNothing,
      );
      final Icon level = tester.widget<Icon>(
        find.byKey(const Key('o03-level')),
      );
      final (IconData, Color) want = wantResult(
        Theme.of(tester.element(find.byType(Scaffold))).colorScheme,
        c.r.level,
      );
      expect(level.icon, want.$1);
      expect(level.color, want.$2);
      expect(find.byKey(const Key('o03-not-accepted')), findsNothing);
    });
  }

  // O03-03 retry button = retryable data.
  final List<_RetryCase> retryCases = <_RetryCase>[
    (
      name: 'retryable',
      r: results[1],
      retry: true,
      flow: (WidgetTester t) async {
        await t.tap(find.byKey(const Key('o03-retry')));
      },
      want: <SettingsActionId>[kisMock.verify!.id, kisMock.verify!.id],
    ),
    (
      name: 'final',
      r: results[2],
      retry: false,
      flow: (WidgetTester t) async {},
      want: <SettingsActionId>[kisMock.verify!.id],
    ),
  ];

  for (final _RetryCase c in retryCases) {
    testWidgets('O03-03 retry is data ${c.name}', (WidgetTester tester) async {
      final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(kisMock)),
          actions: actions,
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const Key('o03-run')));
      await tester.pump();
      await tester.pump();
      expect(
        find.byKey(const Key('o03-retry')),
        c.retry ? findsOneWidget : findsNothing,
      );
      await c.flow(tester);
      await tester.pump();
      await tester.pump();
      expect(actions.ids, c.want);
    });
  }

  // O03-04 failure <-> success: both directions.
  final List<_SwapCase> swapCases = <_SwapCase>[
    (
      name: 'fail_then_ok',
      result: (int call) => call == 0
          ? Future<ActionResult>.error(StateError('fail'))
          : Future<ActionResult>.value(results[0]),
      firstOn: const Key('o03-not-accepted'),
      firstOff: const Key('o03-result'),
      firstTexts: <String?>[ShellLabels.onboardingNotAccepted],
      secondOn: const Key('o03-result'),
      secondOff: const Key('o03-not-accepted'),
      secondTexts: <String?>[results[0].headline, ?results[0].reasonCode],
    ),
    (
      name: 'ok_then_fail',
      result: (int call) => call == 0
          ? Future<ActionResult>.value(results[0])
          : Future<ActionResult>.error(StateError('fail')),
      firstOn: const Key('o03-result'),
      firstOff: const Key('o03-not-accepted'),
      firstTexts: <String?>[results[0].headline, ?results[0].reasonCode],
      secondOn: const Key('o03-not-accepted'),
      secondOff: const Key('o03-result'),
      secondTexts: <String?>[ShellLabels.onboardingNotAccepted],
    ),
  ];

  for (final _SwapCase c in swapCases) {
    testWidgets('O03-04 fail and ok swap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
        result: c.result,
      );
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(kisMock)),
          actions: actions,
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      await tester.tap(find.byKey(const Key('o03-run')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.firstOn), findsOneWidget);
      expect(find.byKey(c.firstOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.firstOn)), c.firstTexts);
      await tester.tap(find.byKey(const Key('o03-run')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(c.secondOn), findsOneWidget);
      expect(find.byKey(c.secondOff), findsNothing);
      expect(shownTexts(tester, find.byKey(c.secondOn)), c.secondTexts);
      expect(actions.ids, <SettingsActionId>[
        kisMock.verify!.id,
        kisMock.verify!.id,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O03-05 no injection (viewer) = no verify button; operator contrast.
  final List<_InjectCase> injectCases = <_InjectCase>[
    (name: 'viewer', actions: () => null, want: false),
    (name: 'operator', actions: operatorOk, want: true),
  ];

  for (final _InjectCase c in injectCases) {
    testWidgets('O03-05 injection null no button ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(kisMock)),
          actions: c.actions(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        find.byKey(const Key('o03-run')),
        c.want ? findsOneWidget : findsNothing,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // O03-06 every shown Text is engine text; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'kis_mock', v: kisMock),
    (name: 'no_verify', v: noVerify),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('O03-06 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpStepDetail(
        tester,
        stepId: askedId,
        overrides: stepOverrides(
          repo: detailRepo((int call) => one(c.v)),
          actions: operatorOk(),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = stepDetailAllowed(c.v, null);
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

  // O03-07 no second run while waiting.
  testWidgets('O03-07 no second tap while waiting', (
    WidgetTester tester,
  ) async {
    final FakeShellOnboardingActions actions = FakeShellOnboardingActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    await pumpStepDetail(
      tester,
      stepId: askedId,
      overrides: stepOverrides(
        repo: detailRepo((int call) => one(kisMock)),
        actions: actions,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.byKey(const Key('o03-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('o03-run')));
    await tester.pump();
    expect(actions.ids, <SettingsActionId>[?kisMock.verify?.id]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });
}
