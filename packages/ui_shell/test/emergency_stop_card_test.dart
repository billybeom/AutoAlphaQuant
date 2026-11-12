// test/emergency_stop_card_test.dart - D03-01 ~ D03-06 (D-03 emergency stop card).

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

typedef _SlotCase = ({
  String name,
  ShellSlotBuilder? Function(FakeShellSlotRecorder s) builder,
  Matcher printWant,
  List<String> slotsWant,
});

typedef _StateCase = ({
  String name,
  Stream<EmergencyCardVm> Function(int call) stream,
  Matcher loadingWant,
  Matcher failWant,
});

typedef _TextCase = ({String name, EmergencyCardVm v});

void main() {
  final EmergencyCardVm card = singleFixture(
    FixturePaths.m8EmergencyCard,
    EmergencyCardVm.fromJson,
  );
  final EmergencyCardVm noPrint = singleFixture(
    FixturePaths.m8EmergencyCardNoPrint,
    EmergencyCardVm.fromJson,
  );

  FakeShellRunbookRepository repoOf(EmergencyCardVm v) =>
      FakeShellRunbookRepository(
        index: (int call) => const Stream<RunbookIndexVm>.empty(),
        runbook: (int call) => const Stream<RunbookVm>.empty(),
        card: (int call) => one(v),
      );

  List<Override> overridesOf(
    FakeShellRunbookRepository repo,
    ShellSlotBuilder? slots,
  ) =>
      runbookOverrides(repo: repo, slots: slots, opener: RecordingLinkOpener());

  // D03-01 block order and words.
  testWidgets('D03-01 block order and words', (WidgetTester tester) async {
    expect(card.printSlotId, isNotNull); // pre
    expect(card.contactLine, isNot(card.keepOnPaperNotice)); // pre
    final FakeShellRunbookRepository repo = repoOf(card);
    await pumpEmergencyCard(
      tester,
      overrides: overridesOf(repo, FakeShellSlotRecorder().build),
    );
    expect(card.steps, hasLength(5));
    final List<Key> chain = <Key>[
      const Key('d03-title'),
      for (int i = 0; i < 5; i++) ValueKey<String>('d03-step-$i'),
      const Key('d03-contact'),
      const Key('d03-notice'),
      const Key('d03-print'),
    ];
    final List<double> tops = chain
        .map((Key k) => tester.getTopLeft(find.byKey(k)).dy)
        .toList();
    for (int i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThan(tops[i - 1]));
    }
    for (final (int i, RunbookStep s) in card.steps.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('d03-step-$i'))),
        <String?>[s.orderText, s.text],
      );
    }
    // C4r16a-2(C4N-4): 제목 · 연락처 · 보관 고지 블록도 받은 글자 그대로.
    expect(shownTexts(tester, find.byKey(const Key('d03-title'))), <String?>[
      card.title,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('d03-contact'))), <String?>[
      card.contactLine,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('d03-notice'))), <String?>[
      card.keepOnPaperNotice,
    ]);
    expect(repo.cardCalls, 1);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D03-02 the print place is a slot builder.
  final List<_SlotCase> slotCases = <_SlotCase>[
    (
      name: 'builder',
      builder: (FakeShellSlotRecorder s) => s.build,
      printWant: findsOneWidget,
      slotsWant: <String>[?card.printSlotId],
    ),
    (
      name: 'no_builder',
      builder: (FakeShellSlotRecorder s) => null,
      printWant: findsNothing,
      slotsWant: <String>[],
    ),
  ];

  for (final _SlotCase c in slotCases) {
    testWidgets('D03-02 print slot ${c.name}', (WidgetTester tester) async {
      final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
      await pumpEmergencyCard(
        tester,
        overrides: overridesOf(repoOf(card), c.builder(slots)),
      );
      expect(find.byKey(const Key('d03-print')), c.printWant);
      expect(slots.slotIds, c.slotsWant);
      expect(find.byKey(const Key('d03-notice')), findsOneWidget);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // D03-03 no print name in the data means no print place.
  testWidgets('D03-03 no print name', (WidgetTester tester) async {
    expect(noPrint.printSlotId, isNull); // pre
    final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
    await pumpEmergencyCard(
      tester,
      overrides: overridesOf(repoOf(noPrint), slots.build),
    );
    expect(find.byKey(const Key('d03-print')), findsNothing);
    expect(slots.slotIds, <String>[]);
    expect(find.byKey(const Key('d03-notice')), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D03-04 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) => Stream<EmergencyCardVm>.multi(
        (MultiStreamController<EmergencyCardVm> c) {},
      ),
      loadingWant: findsOneWidget,
      failWant: findsNothing,
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(card),
      loadingWant: findsNothing,
      failWant: findsOneWidget,
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('D03-04 state branch ${c.name}', (WidgetTester tester) async {
      await pumpEmergencyCard(
        tester,
        overrides: overridesOf(
          FakeShellRunbookRepository(
            index: (int call) => const Stream<RunbookIndexVm>.empty(),
            runbook: (int call) => const Stream<RunbookVm>.empty(),
            card: c.stream,
          ),
          FakeShellSlotRecorder().build,
        ),
      );
      expect(find.byKey(const Key('d03-loading')), c.loadingWant);
      expect(find.byKey(const Key('d03-fail')), c.failWant);
      expect(find.byKey(const Key('d03-title')), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // D03-05 retry subscribes once more.
  testWidgets('D03-05 retry', (WidgetTester tester) async {
    final FakeShellRunbookRepository repo = FakeShellRunbookRepository(
      index: (int call) => const Stream<RunbookIndexVm>.empty(),
      runbook: (int call) => const Stream<RunbookVm>.empty(),
      card: (int call) => call == 0
          ? Stream<EmergencyCardVm>.error(StateError('fail'))
          : one(card),
    );
    await pumpEmergencyCard(
      tester,
      overrides: overridesOf(repo, FakeShellSlotRecorder().build),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('d03-fail')), findsNothing);
    expect(find.byKey(const Key('d03-title')), findsOneWidget);
    expect(repo.cardCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // D03-06 every shown Text is engine text; no buttons; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'card', v: card),
    (name: 'no_print', v: noPrint),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('D03-06 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpEmergencyCard(
        tester,
        overrides: overridesOf(repoOf(c.v), FakeShellSlotRecorder().build),
      );
      final Set<String> allowed = emergencyCardAllowed(c.v);
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
