// test/viewer_pairing_test.dart - V01-01 ~ V01-07 (V-01 viewer-only QR pairing).

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

(IconData, Color) wantResult(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

typedef _SlotCase = ({
  String name,
  ShellSlotBuilder? Function(FakeShellSlotRecorder s) builder,
  Matcher scannerWant,
  List<String> slotsWant,
});

typedef _StateCase = ({
  String name,
  Stream<PairingVm> Function(int call) stream,
  List<Key> present,
  List<Key> absent,
});

typedef _TextCase = ({String name, PairingVm v});

void main() {
  final PairingVm waiting = singleFixture(
    FixturePaths.m8PairingWaiting,
    PairingVm.fromJson,
  );
  final PairingVm ok = singleFixture(
    FixturePaths.m8PairingOk,
    PairingVm.fromJson,
  );
  final PairingVm fail = singleFixture(
    FixturePaths.m8PairingFail,
    PairingVm.fromJson,
  );

  FakeShellPairingRepository repoOf(PairingVm v) =>
      FakeShellPairingRepository(pairing: (int call) => one(v));

  // V01-01 waiting = scanner place only, no result, no next.
  testWidgets('V01-01 waiting scanner only', (WidgetTester tester) async {
    expect(waiting.result, isNull); // pre
    expect(waiting.scannerSlotId, isNotNull); // pre
    final FakeShellPairingRepository repo = repoOf(waiting);
    await pumpPairing(
      tester,
      overrides: pairingOverrides(
        repo: repo,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    expect(repo.pairingCalls, 1);
    expect(find.byKey(const Key('v01-result')), findsNothing);
    expect(find.byKey(const Key('v01-next')), findsNothing);
    expect(find.byKey(const Key('v01-scanner')), findsOneWidget);
    expect(shownTexts(tester, find.byKey(const Key('v01-headline'))), <String?>[
      waiting.headline,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // V01-02 success = engine words plus the next link, opened as received.
  testWidgets('V01-02 success words and next link', (
    WidgetTester tester,
  ) async {
    expect(ok.result?.nextLink, isNotNull); // pre
    expect(ok.result?.reasonCode, isNull); // pre
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpPairing(
      tester,
      overrides: pairingOverrides(
        repo: repoOf(ok),
        slots: FakeShellSlotRecorder().build,
        opener: opener,
      ),
    );
    final ColorScheme cs = csOf(tester);
    final Icon icon = tester.widget<Icon>(find.byKey(const Key('v01-level')));
    final (IconData, Color) want = wantResult(cs, ok.result!.level);
    expect(icon.icon, want.$1);
    expect(icon.color, want.$2);
    expect(shownTexts(tester, find.byKey(const Key('v01-result'))), <String?>[
      ok.result?.headline,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('v01-next'))), <String?>[
      ok.result?.nextLink?.label,
    ]);
    await tester.tap(find.byKey(const Key('v01-next')));
    await tester.pump();
    expect(opener.opened, <String>[ok.result!.nextLink!.deepLink]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // V01-03 failure = engine words and the raw code, no next link.
  testWidgets('V01-03 failure words and raw code', (WidgetTester tester) async {
    expect(fail.result?.reasonCode, isNotNull); // pre
    expect(fail.result?.nextLink, isNull); // pre
    await pumpPairing(
      tester,
      overrides: pairingOverrides(
        repo: repoOf(fail),
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    final ColorScheme cs = csOf(tester);
    final Icon icon = tester.widget<Icon>(find.byKey(const Key('v01-level')));
    final (IconData, Color) want = wantResult(cs, fail.result!.level);
    expect(icon.icon, want.$1);
    expect(icon.color, want.$2);
    expect(shownTexts(tester, find.byKey(const Key('v01-result'))), <String?>[
      fail.result?.headline,
      fail.result?.reasonCode,
    ]);
    expect(find.byKey(const Key('v01-next')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // V01-04 scanner place = slot builder; null builder shows nothing.
  final List<_SlotCase> slotCases = <_SlotCase>[
    (
      name: 'builder',
      builder: (FakeShellSlotRecorder s) => s.build,
      scannerWant: findsOneWidget,
      slotsWant: <String>[?waiting.scannerSlotId],
    ),
    (
      name: 'no_builder',
      builder: (FakeShellSlotRecorder s) => null,
      scannerWant: findsNothing,
      slotsWant: <String>[],
    ),
  ];

  for (final _SlotCase c in slotCases) {
    testWidgets('V01-04 scanner slot ${c.name}', (WidgetTester tester) async {
      expect(waiting.scannerSlotId, isNotNull); // pre
      final FakeShellSlotRecorder slots = FakeShellSlotRecorder();
      await pumpPairing(
        tester,
        overrides: pairingOverrides(
          repo: repoOf(waiting),
          slots: c.builder(slots),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('v01-scanner')), c.scannerWant);
      expect(slots.slotIds, c.slotsWant);
      expect(find.byKey(const Key('v01-headline')), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // V01-05 state branches.
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      stream: (int call) =>
          Stream<PairingVm>.multi((MultiStreamController<PairingVm> c) {}),
      present: <Key>[const Key('v01-loading')],
      absent: <Key>[const Key('v01-headline'), const Key('v01-fail')],
    ),
    (
      name: 'fail',
      stream: (int call) => Stream<PairingVm>.error(StateError('fail')),
      present: <Key>[const Key('v01-fail')],
      absent: <Key>[const Key('v01-headline'), const Key('v01-loading')],
    ),
    (
      name: 'value_then_fail',
      stream: (int call) => valueThenFail(waiting),
      present: <Key>[const Key('v01-fail')],
      absent: <Key>[const Key('v01-headline'), const Key('v01-loading')],
    ),
  ];

  for (final _StateCase c in stateCases) {
    testWidgets('V01-05 state branch ${c.name}', (WidgetTester tester) async {
      await pumpPairing(
        tester,
        overrides: pairingOverrides(
          repo: FakeShellPairingRepository(pairing: c.stream),
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

  // V01-06 retry subscribes once more.
  testWidgets('V01-06 retry', (WidgetTester tester) async {
    final FakeShellPairingRepository repo = FakeShellPairingRepository(
      pairing: (int call) =>
          call == 0 ? Stream<PairingVm>.error(StateError('fail')) : one(ok),
    );
    await pumpPairing(
      tester,
      overrides: pairingOverrides(
        repo: repo,
        slots: FakeShellSlotRecorder().build,
        opener: RecordingLinkOpener(),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('v01-fail')), findsNothing);
    expect(find.byKey(const Key('v01-headline')), findsOneWidget);
    expect(repo.pairingCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // V01-07 every shown Text is engine text; large font.
  final List<_TextCase> textCases = <_TextCase>[
    (name: 'waiting', v: waiting),
    (name: 'ok', v: ok),
    (name: 'fail', v: fail),
  ];

  for (final _TextCase c in textCases) {
    testWidgets('V01-07 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpPairing(
        tester,
        overrides: pairingOverrides(
          repo: repoOf(c.v),
          slots: FakeShellSlotRecorder().build,
          opener: RecordingLinkOpener(),
        ),
      );
      final Set<String> allowed = pairingAllowed(c.v);
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
