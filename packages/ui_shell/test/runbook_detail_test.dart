// test/runbook_detail_test.dart - D02-11 ~ D02-17 (D-02 runbook detail).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

Stream<T> valueThenFail<T>(T v) async* {
  yield v;
  throw StateError('fail');
}

typedef _StateCase = ({
  String name,
  Stream<RunbookVm> Function(int call) stream,
  Matcher loadingWant,
  Matcher failWant,
});

typedef _TextCase = ({String name, RunbookVm v});

void main() {
  final RunbookVm hostLost = singleFixture(
    FixturePaths.m8RunbookHostLost,
    RunbookVm.fromJson,
  );
  final RunbookVm missing = singleFixture(
    FixturePaths.m8RunbookMissing,
    RunbookVm.fromJson,
  );

  const String runbookId = 'host-lost';

  FakeShellRunbookRepository repoOf(RunbookVm v) => FakeShellRunbookRepository(
    index: (int call) => const Stream<RunbookIndexVm>.empty(),
    runbook: (int call) => one(v),
    card: (int call) => const Stream<EmergencyCardVm>.empty(),
  );

  List<Override> overridesOf(
    FakeShellRunbookRepository repo,
    RecordingLinkOpener opener,
  ) => runbookOverrides(repo: repo, slots: null, opener: opener);

  Checkbox checkOf(WidgetTester tester, int i) =>
      tester.widget<Checkbox>(find.byKey(ValueKey<String>('d02-check-$i')));

  // D02-11 step order and words.
  testWidgets('D02-11 step order and words', (WidgetTester tester) async {
    expect(hostLost.introText, isNotNull); // pre
    final FakeShellRunbookRepository repo = repoOf(hostLost);
    await pumpRunbookDetail(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
      runbookId: runbookId,
    );
    expect(hostLost.steps, hasLength(5));
    final List<Key> chain = <Key>[
      const Key('d02-title'),
      const Key('d02-intro'),
      for (int i = 0; i < 5; i++) ValueKey<String>('d02-step-$i'),
      const Key('d02-notice'),
    ];
    final List<double> tops = chain
        .map((Key k) => tester.getTopLeft(find.byKey(k)).dy)
        .toList();
    for (int i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]));
    }
    for (final (int i, RunbookStep s) in hostLost.steps.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('d02-step-$i'))),
        <String?>[s.orderText, s.text],
      );
    }
    expect(repo.runbookIds, <String>[runbookId]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-12 the check mark is local only.
  testWidgets('D02-12 check is local only', (WidgetTester tester) async {
    final FakeShellRunbookRepository repo = repoOf(hostLost);
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpRunbookDetail(
      tester,
      overrides: overridesOf(repo, opener),
      runbookId: runbookId,
    );
    final List<String?> noticeBefore = shownTexts(
      tester,
      find.byKey(const Key('d02-notice')),
    );
    expect(checkOf(tester, 0).value, false);
    await tester.tap(find.byKey(const ValueKey<String>('d02-check-0')));
    await tester.pump();
    expect(checkOf(tester, 0).value, true);
    expect(checkOf(tester, 1).value, false);
    await tester.tap(find.byKey(const ValueKey<String>('d02-check-0')));
    await tester.pump();
    expect(checkOf(tester, 0).value, false);
    expect(checkOf(tester, 1).value, false);
    expect(repo.runbookIds, <String>[runbookId]);
    expect(opener.opened, <String>[]);
    expect(
      shownTexts(tester, find.byKey(const Key('d02-notice'))),
      noticeBefore,
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-13 the notice is received text and sits at the bottom.
  testWidgets('D02-13 notice is data and last', (WidgetTester tester) async {
    await pumpRunbookDetail(
      tester,
      overrides: overridesOf(repoOf(hostLost), RecordingLinkOpener()),
      runbookId: runbookId,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('d02-notice'))).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const ValueKey<String>('d02-step-4'))).dy,
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('d02-notice'))), <String?>[
      hostLost.localCheckNotice,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-14 unknown runbook shows the received missing label.
  testWidgets('D02-14 unknown runbook label', (WidgetTester tester) async {
    expect(missing.steps, isEmpty); // pre
    expect(missing.missingLabel, isNotNull); // pre
    await pumpRunbookDetail(
      tester,
      overrides: overridesOf(repoOf(missing), RecordingLinkOpener()),
      runbookId: runbookId,
    );
    expect(shownTexts(tester, find.byKey(const Key('d02-missing'))), <String?>[
      missing.missingLabel,
    ]);
    expect(find.byKey(const ValueKey<String>('d02-step-0')), findsNothing);
    expect(find.byKey(const ValueKey<String>('d02-check-0')), findsNothing);
    expect(find.byKey(const Key('d02-intro')), findsNothing);
    expect(find.byKey(const Key('d02-missing')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-15 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) =>
          Stream<RunbookVm>.multi((MultiStreamController<RunbookVm> c) {}),
      loadingWant: findsOneWidget,
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(hostLost),
      loadingWant: findsNothing,
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('D02-15 state branch ${c.name}', (WidgetTester tester) async {
      await pumpRunbookDetail(
        tester,
        overrides: overridesOf(
          FakeShellRunbookRepository(
            index: (int call) => const Stream<RunbookIndexVm>.empty(),
            runbook: c.stream,
            card: (int call) => const Stream<EmergencyCardVm>.empty(),
          ),
          RecordingLinkOpener(),
        ),
        runbookId: runbookId,
      );
      expect(find.byKey(const Key('d02-loading')), c.loadingWant);
      expect(find.byKey(const Key('d02-fail')), c.failWant);
      expect(find.byKey(const Key('d02-title')), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // D02-16 retry subscribes once more.
  testWidgets('D02-16 retry', (WidgetTester tester) async {
    final FakeShellRunbookRepository repo = FakeShellRunbookRepository(
      index: (int call) => const Stream<RunbookIndexVm>.empty(),
      runbook: (int call) => call == 0
          ? Stream<RunbookVm>.error(StateError('fail'))
          : one(hostLost),
      card: (int call) => const Stream<EmergencyCardVm>.empty(),
    );
    await pumpRunbookDetail(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
      runbookId: runbookId,
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('d02-fail')), findsNothing);
    expect(find.byKey(const Key('d02-title')), findsOneWidget);
    expect(repo.runbookIds, <String>[runbookId, runbookId]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-17 every shown Text is engine text; no buttons; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'host_lost', v: hostLost),
    (name: 'missing', v: missing),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('D02-17 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpRunbookDetail(
        tester,
        overrides: overridesOf(repoOf(c.v), RecordingLinkOpener()),
        runbookId: runbookId,
      );
      final Set<String> allowed = runbookAllowed(c.v);
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNWidgets(0),
      );
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
