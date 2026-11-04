// test/onboarding_restart_test.dart - R01-01 ~ R01-09 (R-01 restart from an existing account).

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

ColorScheme csOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

(IconData, Color) wantGate(ColorScheme cs, GateState g) => switch (g) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};

Icon firstIconIn(WidgetTester tester, Key key) => tester.widget<Icon>(
  find.descendant(of: find.byKey(key), matching: find.byType(Icon)).first,
);

typedef _GateCase = ({String name, RestartVm v});

typedef _BranchCase = ({String name, RestartVm v, int index});

typedef _InheritCase = ({String name, RestartVm v});

typedef _LoginCase = ({
  String name,
  RestartVm v,
  ShellSlotBuilder? Function(FakeShellSlotRecorder s) builder,
  Matcher loginWant,
  List<String> slotsWant,
  Matcher ledgerWant,
  Matcher branchWant,
});

typedef _StateCase = ({
  String name,
  Stream<RestartVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _TextCase = ({String name, RestartVm v});

void main() {
  final RestartVm lostPhone = singleFixture(
    FixturePaths.m8RestartVmLostPhone,
    RestartVm.fromJson,
  );
  final RestartVm loggedOut = singleFixture(
    FixturePaths.m8RestartVmLoggedOut,
    RestartVm.fromJson,
  );
  final RestartVm gap7 = singleFixture(
    FixturePaths.m8RestartVmGap7,
    RestartVm.fromJson,
  );
  final RestartVm unknown = singleFixture(
    FixturePaths.m8RestartVmUnknown,
    RestartVm.fromJson,
  );

  FakeShellRestartRepository repoOf(RestartVm v) =>
      FakeShellRestartRepository(restart: (int call) => one(v));

  // R01-01 order and texts: login done, ledger, gate, branches, inherit notice.
  testWidgets('R01-01 order and texts', (WidgetTester tester) async {
    expect(lostPhone.loginSlotId, isNull); // pre
    final FakeShellRestartRepository repo = repoOf(lostPhone);
    await pumpRestart(
      tester,
      overrides: restartOverrides(
        repo: repo,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(repo.restartCalls, 1);
    expect(find.byKey(const Key('r01-login')), findsNothing);
    expect(lostPhone.branches, hasLength(2));
    final List<Finder> chain = <Finder>[
      find.byKey(const Key('r01-headline')),
      find.byKey(const Key('r01-ledger')),
      find.byKey(const Key('r01-gate')),
      for (final (int i, _) in lostPhone.branches.indexed)
        find.byKey(ValueKey<String>('r01-branch-$i')),
      find.byKey(const Key('r01-inherit')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }
    expect(shownTexts(tester, find.byKey(const Key('r01-headline'))), <String?>[
      lostPhone.headline,
    ]);
    expect(
      shownTexts(tester, find.byKey(const Key('r01-ledger'))),
      lostPhone.ledgerLines,
    );
    expect(shownTexts(tester, find.byKey(const Key('r01-gate'))), <String?>[
      lostPhone.leaseGate?.label,
    ]);
    for (final (int i, LinkAction b) in lostPhone.branches.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('r01-branch-$i'))),
        <String?>[b.label],
      );
    }
    expect(shownTexts(tester, find.byKey(const Key('r01-inherit'))), <String?>[
      lostPhone.inheritNotice,
    ]);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(lostPhone.branches.length),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // R01-02 lease gate three phases: unknown is a blocking look, not the n/a look.
  final List<_GateCase> gateCases = <_GateCase>[
    (name: 'pass', v: lostPhone),
    (name: 'block', v: gap7),
    (name: 'unknown', v: unknown),
  ];

  for (final _GateCase c in gateCases) {
    testWidgets('R01-02 lease gate look ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(lostPhone.leaseGate?.state, GateState.pass); // pre
      expect(gap7.leaseGate?.state, GateState.block); // pre
      expect(unknown.leaseGate?.state, GateState.unknown); // pre
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: repoOf(c.v),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final ColorScheme cs = csOf(tester);
      final Icon icon = firstIconIn(tester, const Key('r01-gate'));
      final (IconData, Color) want = wantGate(cs, c.v.leaseGate!.state);
      expect(icon.icon, want.$1);
      expect(icon.color, want.$2);
      expect(icon.icon, isNot(wantGate(cs, GateState.notApplicable).$1));
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // R01-03 branch tap opens the received link only.
  final List<_BranchCase> branchCases = <_BranchCase>[
    (name: 'plan', v: lostPhone, index: 0),
    (name: 'emergency', v: lostPhone, index: 1),
    (name: 'gap7', v: gap7, index: 0),
  ];

  for (final _BranchCase c in branchCases) {
    testWidgets('R01-03 branch tap link ${c.name}', (
      WidgetTester tester,
    ) async {
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: repoOf(c.v),
          slots: FakeShellSlotRecorder().build,
          opener: opener,
        ),
      );
      await tester.tap(find.byKey(ValueKey<String>('r01-branch-${c.index}')));
      await tester.pump();
      expect(opener.opened, <String>[c.v.branches[c.index].deepLink]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // R01-04 unknown lease: no branch at all (the gate explains why).
  testWidgets('R01-04 unknown no branch', (WidgetTester tester) async {
    expect(unknown.branches, isEmpty); // pre
    await pumpRestart(
      tester,
      overrides: restartOverrides(
        repo: repoOf(unknown),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(find.byKey(const ValueKey<String>('r01-branch-0')), findsNothing);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(find.byKey(const Key('r01-gate')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // R01-05 inherit notice is data: present and absent sides.
  final List<_InheritCase> inheritCases = <_InheritCase>[
    (name: 'present', v: lostPhone),
    (name: 'absent', v: unknown),
  ];

  for (final _InheritCase c in inheritCases) {
    testWidgets('R01-05 inherit notice ${c.name}', (WidgetTester tester) async {
      expect(lostPhone.inheritNotice, isNotNull); // pre
      expect(unknown.inheritNotice, isNull); // pre
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: repoOf(c.v),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final String? inherit = c.v.inheritNotice;
      if (inherit != null) {
        expect(
          shownTexts(tester, find.byKey(const Key('r01-inherit'))),
          <String?>[inherit],
        );
      } else {
        expect(find.byKey(const Key('r01-inherit')), findsNothing);
        expect(find.text(lostPhone.inheritNotice!), findsNothing);
        expect(find.byKey(const Key('r01-gate')), findsOneWidget);
      }
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // R01-05 차단 게이트 + 승계 고지 있음(gap7): 고지는 데이터라 게이트가 막아도 그대로 보인다.
  testWidgets('R01-05 inherit notice gap7 block', (WidgetTester tester) async {
    expect(gap7.leaseGate?.state, GateState.block); // pre
    expect(gap7.inheritNotice, isNotNull); // pre
    await pumpRestart(
      tester,
      overrides: restartOverrides(
        repo: repoOf(gap7),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(find.byKey(const Key('r01-inherit')), findsOneWidget);
    expect(shownTexts(tester, find.byKey(const Key('r01-inherit'))), <String?>[
      gap7.inheritNotice,
    ]);
    expect(find.byKey(const Key('r01-gate')), findsOneWidget);
    expect(
      firstIconIn(tester, const Key('r01-gate')).icon,
      wantGate(csOf(tester), GateState.block).$1,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('r01-gate'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('r01-inherit'))).dy),
    );
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // R01-06 login place = slot builder; ledger and branches follow the data.
  final List<_LoginCase> loginCases = <_LoginCase>[
    (
      name: 'logged_out',
      v: loggedOut,
      builder: (FakeShellSlotRecorder s) => s.build,
      loginWant: findsOneWidget,
      slotsWant: <String>[?loggedOut.loginSlotId],
      ledgerWant: findsNothing,
      branchWant: findsNothing,
    ),
    (
      name: 'logged_out_no_builder',
      v: loggedOut,
      builder: (FakeShellSlotRecorder s) => null,
      loginWant: findsNothing,
      slotsWant: <String>[],
      ledgerWant: findsNothing,
      branchWant: findsNothing,
    ),
    (
      name: 'logged_in',
      v: lostPhone,
      builder: (FakeShellSlotRecorder s) => s.build,
      loginWant: findsNothing,
      slotsWant: <String>[],
      ledgerWant: findsOneWidget,
      branchWant: findsOneWidget,
    ),
  ];

  for (final _LoginCase c in loginCases) {
    testWidgets('R01-06 login slot ${c.name}', (WidgetTester tester) async {
      expect(loggedOut.loginSlotId, isNotNull); // pre
      expect(loggedOut.ledgerLines, isNull); // pre
      final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: repoOf(c.v),
          slots: c.builder(slots),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('r01-login')), c.loginWant);
      expect(slots.slotIds, c.slotsWant);
      expect(find.byKey(const Key('r01-ledger')), c.ledgerWant);
      expect(find.byKey(const ValueKey<String>('r01-branch-0')), c.branchWant);
      expect(find.byKey(const Key('r01-headline')), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // R01-07 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) =>
          Stream<RestartVm>.multi((MultiStreamController<RestartVm> c) {}),
      present: <Key>[const Key('r01-loading')],
      absent: <Key>[const Key('r01-headline'), const Key('r01-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) => Stream<RestartVm>.error(StateError('fail')),
      present: <Key>[const Key('r01-fail')],
      absent: <Key>[const Key('r01-headline'), const Key('r01-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(lostPhone),
      present: <Key>[const Key('r01-fail')],
      absent: <Key>[const Key('r01-headline'), const Key('r01-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('R01-07 state branch ${c.name}', (WidgetTester tester) async {
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: FakeShellRestartRepository(restart: c.stream),
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

  // R01-08 retry subscribes once more.
  testWidgets('R01-08 retry', (WidgetTester tester) async {
    final FakeShellRestartRepository repo = FakeShellRestartRepository(
      restart: (int call) => call == 0
          ? Stream<RestartVm>.error(StateError('fail'))
          : one(lostPhone),
    );
    await pumpRestart(
      tester,
      overrides: restartOverrides(
        repo: repo,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('r01-fail')), findsNothing);
    expect(find.byKey(const Key('r01-headline')), findsOneWidget);
    expect(repo.restartCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // R01-09 every shown Text is engine text; no extra button; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'lost_phone', v: lostPhone),
    (name: 'gap7', v: gap7),
    (name: 'unknown', v: unknown),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('R01-09 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpRestart(
        tester,
        overrides: restartOverrides(
          repo: repoOf(c.v),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = restartAllowed(c.v);
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
        findsNWidgets(c.v.branches.length),
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
