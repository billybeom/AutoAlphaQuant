// test/runbook_list_test.dart - D02-01 ~ D02-06 (D-02 runbook list).

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

typedef _TapCase = ({String name, int row});

typedef _StateCase = ({
  String name,
  Stream<RunbookIndexVm> Function(int call) stream,
  Matcher loadingWant,
  Matcher failWant,
});

typedef _TextCase = ({String name, RunbookIndexVm v});

void main() {
  final RunbookIndexVm index = singleFixture(
    FixturePaths.m8RunbookIndex,
    RunbookIndexVm.fromJson,
  );
  final RunbookIndexVm empty = singleFixture(
    FixturePaths.m8RunbookIndexEmpty,
    RunbookIndexVm.fromJson,
  );

  FakeShellRunbookRepository repoOf(RunbookIndexVm v) =>
      FakeShellRunbookRepository(
        index: (int call) => one(v),
        runbook: (int call) => const Stream<RunbookVm>.empty(),
        card: (int call) => const Stream<EmergencyCardVm>.empty(),
      );

  List<Override> overridesOf(
    FakeShellRunbookRepository repo,
    RecordingLinkOpener opener,
  ) => runbookOverrides(repo: repo, slots: null, opener: opener);

  // D02-01 row order and words.
  testWidgets('D02-01 row order and words', (WidgetTester tester) async {
    await pumpRunbookList(
      tester,
      overrides: overridesOf(repoOf(index), RecordingLinkOpener()),
    );
    expect(index.rows, hasLength(6));
    for (final (int i, RunbookRow r) in index.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('d02-list-row-$i'))),
        <String?>[r.title, ?r.summaryText],
      );
    }
    expect(find.byKey(const Key('d02-list-empty')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-02 row tap opens the row link.
  final List<_TapCase> tapCases = <_TapCase>[
    (name: 'first', row: 0),
    (name: 'last', row: 5),
  ];

  for (final _TapCase c in tapCases) {
    testWidgets('D02-02 row tap link ${c.name}', (WidgetTester tester) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpRunbookList(
        tester,
        overrides: overridesOf(repoOf(index), opener),
      );
      await tester.tap(find.byKey(ValueKey<String>('d02-list-row-${c.row}')));
      await tester.pump();
      expect(opener.opened, <String>[index.rows[c.row].deepLink]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D02-03 empty list shows the received empty label.
  testWidgets('D02-03 empty list label', (WidgetTester tester) async {
    expect(empty.rows, isEmpty); // pre
    expect(empty.emptyLabel, isNotNull); // pre
    await pumpRunbookList(
      tester,
      overrides: overridesOf(repoOf(empty), RecordingLinkOpener()),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('d02-list-empty'))),
      <String?>[empty.emptyLabel],
    );
    expect(find.byKey(const ValueKey<String>('d02-list-row-0')), findsNothing);
    expect(find.byKey(const Key('d02-list-empty')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-04 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<RunbookIndexVm>.multi(
        (MultiStreamController<RunbookIndexVm> c) {},
      ),
      loadingWant: findsOneWidget,
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(index),
      loadingWant: findsNothing,
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('D02-04 state branch ${c.name}', (WidgetTester tester) async {
      await pumpRunbookList(
        tester,
        overrides: overridesOf(
          FakeShellRunbookRepository(
            index: c.stream,
            runbook: (int call) => const Stream<RunbookVm>.empty(),
            card: (int call) => const Stream<EmergencyCardVm>.empty(),
          ),
          RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('d02-list-loading')), c.loadingWant);
      expect(find.byKey(const Key('d02-list-fail')), c.failWant);
      expect(
        find.byKey(const ValueKey<String>('d02-list-row-0')),
        findsNothing,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // D02-05 retry subscribes once more.
  testWidgets('D02-05 retry', (WidgetTester tester) async {
    final FakeShellRunbookRepository repo = FakeShellRunbookRepository(
      index: (int call) => call == 0
          ? Stream<RunbookIndexVm>.error(StateError('fail'))
          : one(index),
      runbook: (int call) => const Stream<RunbookVm>.empty(),
      card: (int call) => const Stream<EmergencyCardVm>.empty(),
    );
    await pumpRunbookList(
      tester,
      overrides: overridesOf(repo, RecordingLinkOpener()),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('d02-list-fail')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('d02-list-row-0')),
      findsOneWidget,
    );
    expect(repo.indexCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D02-06 every shown Text is engine text; no buttons; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'index', v: index),
    (name: 'empty', v: empty),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('D02-06 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpRunbookList(
        tester,
        overrides: overridesOf(repoOf(c.v), RecordingLinkOpener()),
      );
      final Set<String> allowed = runbookIndexAllowed(c.v);
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
