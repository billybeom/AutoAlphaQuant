// test/diagnostics_test.dart
//
// M9 S10 - Diagnostics widget tests.
//
// ASCII only - no Korean literals - if 0 - collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// -- Level look helper (lib copy) ---------------------------------------------

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

ColorScheme colorsOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Diagnostics))).colorScheme;

ButtonStyleButton buttonAt(WidgetTester tester, Key key) =>
    tester.widget<ButtonStyleButton>(find.byKey(key));

List<String?> buttonTextsOf(WidgetTester tester) => shownTexts(
  tester,
  find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
);

void main() {
  final DiagnosticsScreenVm normal = singleFixture(
    FixturePaths.m9DiagnosticsScreen,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm diff = singleFixture(
    FixturePaths.m9DiagnosticsScreenDiff,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm running = singleFixture(
    FixturePaths.m9DiagnosticsScreenRunning,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm locked = singleFixture(
    FixturePaths.m9DiagnosticsScreenLocked,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm stale = singleFixture(
    FixturePaths.m9DiagnosticsScreenStale,
    DiagnosticsScreenVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9SelftestActionResults,
    ActionResult.fromJson,
  ).rows;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );
  SettingsActions? noActions() => null;

  // -- M9S10-01: block order, card heads, button presence ---------------------

  for (final c in <({String name, DiagnosticsScreenVm v, List<Key> chain})>[
    (
      name: 'default',
      v: normal,
      chain: <Key>[
        const Key('m9s10-recommend'),
        const Key('m9s10-golden'),
        const Key('m9s10-integrity'),
        const Key('m9s10-board'),
        const Key('m9s10-integrity-run'),
        const Key('m9s10-asof'),
      ],
    ),
    (
      name: 'diff',
      v: diff,
      chain: <Key>[
        const Key('m9s10-golden'),
        const Key('m9s10-golden-run'),
        const Key('m9s10-integrity'),
        const Key('m9s10-board'),
        const Key('m9s10-integrity-run'),
        const Key('m9s10-diffs'),
        const Key('m9s10-asof'),
      ],
    ),
    (
      name: 'running',
      v: running,
      chain: <Key>[
        const Key('m9s10-golden'),
        const Key('m9s10-integrity'),
        const Key('m9s10-board'),
        const Key('m9s10-integrity-run'),
        const Key('m9s10-asof'),
      ],
    ),
  ]) {
    testWidgets('M9S10-01 block order texts buttons ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s10-board')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-recommend'))),
        <String?>[?c.v.recommendText],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-golden'))),
        selfTestCardTexts(c.v.golden),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-integrity'))),
        selfTestCardTexts(c.v.integrity),
      );

      final ColorScheme cs = colorsOf(tester);
      final Icon gl = tester.widget<Icon>(
        find.byKey(const Key('m9s10-golden-level')),
      );
      expect(gl.icon, wantLevel(cs, c.v.golden.level).$1);
      expect(gl.color, wantLevel(cs, c.v.golden.level).$2);
      final Icon il = tester.widget<Icon>(
        find.byKey(const Key('m9s10-integrity-level')),
      );
      expect(il.icon, wantLevel(cs, c.v.integrity.level).$1);
      expect(il.color, wantLevel(cs, c.v.integrity.level).$2);

      expect(buttonTextsOf(tester), diagnosticsRunLabels(c.v));
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-diffs'))),
        <String?>[?c.v.diffsLink?.label],
      );
      expect(shownTexts(tester, find.byKey(const Key('m9s10-asof'))), <String?>[
        c.v.asOf.label,
      ]);

      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }

      expect(find.byKey(const Key('m9s10-stale')), findsNothing);
      expect(find.byKey(const Key('m9s10-locked')), findsNothing);
      expect(find.byKey(const Key('m9s10-golden-result')), findsNothing);
      expect(find.byKey(const Key('m9s10-integrity-result')), findsNothing);
      expect(find.byKey(const Key('m9s10-golden-not-accepted')), findsNothing);
      expect(
        find.byKey(const Key('m9s10-integrity-not-accepted')),
        findsNothing,
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-02: board as received, cell tap does nothing ---------------------

  for (final c in <({String name, DiagnosticsScreenVm v})>[
    (name: 'default', v: normal),
    (name: 'diff', v: diff),
  ]) {
    testWidgets('M9S10-02 board as received cell tap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      final FakeSettingsActions actions = okActions();
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final ColorScheme cs = colorsOf(tester);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-board'))),
        diagnosticsBoardTexts(c.v.board),
      );
      expect(
        find.byWidgetPredicate(isDiagnosticsCellRow),
        findsNWidgets(c.v.board.cells.length),
      );
      for (final (int i, DiagnosticCell cell) in c.v.board.cells.indexed) {
        expect(
          shownTexts(tester, find.byKey(Key('m9s10-cell-$i'))),
          diagnosticsCellTexts(cell),
        );
        final Icon sg = tester.widget<Icon>(find.byKey(Key('m9s10-signal-$i')));
        expect(sg.icon, wantLevel(cs, cell.level).$1);
        expect(sg.color, wantLevel(cs, cell.level).$2);
        await tester.tap(
          find.descendant(
            of: find.byKey(Key('m9s10-cell-$i')),
            matching: find.text(cell.label),
          ),
        );
      }
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[]);
      expect(opener.opened, <String>[]);

      expect(find.text(c.v.board.asOf.label), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-03: golden run, result in the golden card slot -------------------

  for (final c in <({String name, ActionResult r})>[
    (name: 'pass', r: results[0]),
    (name: 'mismatch', r: results[1]),
    (name: 'biometric', r: results[2]),
  ]) {
    testWidgets('M9S10-03 golden run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(diff),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => call == 0
            ? Future<ActionResult>.value(c.r)
            : Completer<ActionResult>().future,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(actions.ids, <SettingsActionId>[]);
      await tester.tap(find.byKey(const Key('m9s10-golden-run')));
      await tester.pump();
      await tester.pump();
      expect(actions.ids, selfTestRunIds(diff.golden));
      expect(actions.argsSeen, selfTestRunArgs(diff.golden));
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-golden-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(buttonAt(tester, const Key('m9s10-golden-run')).enabled, isTrue);

      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s10-golden-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s10-golden-run'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('m9s10-golden-result'))).dy,
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s10-golden-result'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('m9s10-integrity'))).dy,
        ),
      );
      expect(find.byKey(const Key('m9s10-integrity-result')), findsNothing);
      expect(
        buttonAt(tester, const Key('m9s10-integrity-run')).enabled,
        isTrue,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-diffs'))),
        <String?>[?diff.diffsLink?.label],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-board'))),
        diagnosticsBoardTexts(diff.board),
      );
      expect(actions.watchCalls, 0);
      expect(repo.diagnosticsCalls, 1);
      expect(opener.opened, <String>[]);
      expect(find.byKey(const Key('m9s10-golden-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);

      // Press again with a result on screen: while waiting, the result stays.
      await tester.tap(find.byKey(const Key('m9s10-golden-run')));
      await tester.pump();
      expect(buttonAt(tester, const Key('m9s10-golden-run')).enabled, isFalse);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-golden-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
    });
  }

  // -- M9S10-04: integrity run, result in the integrity card slot -------------

  for (final c in <({String name, ActionResult r})>[
    (name: 'ok', r: results[3]),
    (name: 'biometric', r: results[4]),
    (name: 'format_version', r: results[5]),
    (name: 'date_gap', r: results[6]),
    (name: 'chain_broken', r: results[7]),
    (name: 'day_hash', r: results[8]),
    (name: 'rows_before', r: results[9]),
    (name: 'attribution', r: results[10]),
    (name: 'sqlite', r: results[11]),
  ]) {
    testWidgets('M9S10-04 integrity run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(diff),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(actions.ids, <SettingsActionId>[]);
      await tester.tap(find.byKey(const Key('m9s10-integrity-run')));
      await tester.pump();
      await tester.pump();
      expect(actions.ids, selfTestRunIds(diff.integrity));
      expect(actions.argsSeen, selfTestRunArgs(diff.integrity));
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-integrity-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(
        buttonAt(tester, const Key('m9s10-integrity-run')).enabled,
        isTrue,
      );

      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s10-integrity-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s10-integrity-run'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('m9s10-integrity-result'))).dy,
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s10-integrity-result'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s10-diffs'))).dy),
      );
      expect(find.byKey(const Key('m9s10-golden-result')), findsNothing);
      expect(buttonAt(tester, const Key('m9s10-golden-run')).enabled, isTrue);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-diffs'))),
        <String?>[?diff.diffsLink?.label],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-board'))),
        diagnosticsBoardTexts(diff.board),
      );
      expect(actions.watchCalls, 0);
      expect(repo.diagnosticsCalls, 1);
      expect(opener.opened, <String>[]);
      expect(
        find.byKey(const Key('m9s10-integrity-not-accepted')),
        findsNothing,
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-05: waiting blocks only that card, link stays open ---------------

  testWidgets('M9S10-05 waiting per card button and link', (
    WidgetTester tester,
  ) async {
    expect(diff.golden.runAction, isNotNull); // pre
    expect(diff.integrity.runAction, isNotNull); // pre
    expect(diff.diffsLink, isNotNull); // pre
    final FakeSettingsDiagnosticsRepository repo =
        FakeSettingsDiagnosticsRepository(diagnostics: (int call) => one(diff));
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Completer<ActionResult>().future,
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpDiagnostics(
      tester,
      overrides: diagnosticsOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s10-golden-run')));
    await tester.pump();
    expect(buttonAt(tester, const Key('m9s10-golden-run')).enabled, isFalse);
    expect(buttonAt(tester, const Key('m9s10-integrity-run')).enabled, isTrue);
    await tester.tap(find.byKey(const Key('m9s10-golden-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s10-integrity-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s10-integrity-run')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s10-diffs')));
    await tester.pump();
    expect(actions.ids, <SettingsActionId>[
      ...selfTestRunIds(diff.golden),
      ...selfTestRunIds(diff.integrity),
    ]);
    expect(opener.opened, <String>[?diff.diffsLink?.deepLink]);

    expect(
      tester
          .widgetList<ButtonStyleButton>(
            find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
          )
          .map((ButtonStyleButton b) => b.enabled)
          .toSet(),
      <bool>{false},
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(const Key('m9s10-golden-result')), findsNothing);
    expect(find.byKey(const Key('m9s10-integrity-result')), findsNothing);
    expect(find.byKey(const Key('m9s10-golden-not-accepted')), findsNothing);
    expect(find.byKey(const Key('m9s10-integrity-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S10-06: failure and success both directions, two cards ---------------

  for (final c
      in <
        ({
          String name,
          Key run,
          Key na,
          Key res,
          Key otherNa,
          Future<ActionResult> Function(int call) result,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
          SelfTestCard card,
        })
      >[
        (
          name: 'golden_fail_then_ok',
          run: const Key('m9s10-golden-run'),
          na: const Key('m9s10-golden-not-accepted'),
          res: const Key('m9s10-golden-result'),
          otherNa: const Key('m9s10-integrity-not-accepted'),
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline, ?results[0].reasonCode],
          card: diff.golden,
        ),
        (
          name: 'golden_ok_then_fail',
          run: const Key('m9s10-golden-run'),
          na: const Key('m9s10-golden-not-accepted'),
          res: const Key('m9s10-golden-result'),
          otherNa: const Key('m9s10-integrity-not-accepted'),
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline, ?results[0].reasonCode],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
          card: diff.golden,
        ),
        (
          name: 'integrity_fail_then_ok',
          run: const Key('m9s10-integrity-run'),
          na: const Key('m9s10-integrity-not-accepted'),
          res: const Key('m9s10-integrity-result'),
          otherNa: const Key('m9s10-golden-not-accepted'),
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[3]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[3].headline, ?results[3].reasonCode],
          card: diff.integrity,
        ),
        (
          name: 'integrity_ok_then_fail',
          run: const Key('m9s10-integrity-run'),
          na: const Key('m9s10-integrity-not-accepted'),
          res: const Key('m9s10-integrity-result'),
          otherNa: const Key('m9s10-golden-not-accepted'),
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[3])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[3].headline, ?results[3].reasonCode],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
          card: diff.integrity,
        ),
      ]) {
    testWidgets('M9S10-06 fail and ok both ways ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(diff),
          );
      final FakeSettingsActions actions = FakeSettingsActions(result: c.result);
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.run));
      await tester.pump();
      await tester.pump();
      expect(shownTexts(tester, find.byKey(c.na)), c.firstNa);
      expect(shownTexts(tester, find.byKey(c.res)), c.firstRes);
      expect(find.byKey(c.otherNa), findsNothing);

      await tester.tap(find.byKey(c.run));
      await tester.pump();
      await tester.pump();
      expect(shownTexts(tester, find.byKey(c.na)), c.secondNa);
      expect(shownTexts(tester, find.byKey(c.res)), c.secondRes);
      expect(find.byKey(c.otherNa), findsNothing);
      expect(actions.ids, <SettingsActionId>[
        ...selfTestRunIds(c.card),
        ...selfTestRunIds(c.card),
      ]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-07: locked after a result, link stays, result stays --------------

  testWidgets('M9S10-07 locked after result keeps link and result', (
    WidgetTester tester,
  ) async {
    expect(locked.lockedLabel, isNotNull); // pre
    expect(locked.diffsLink, isNotNull); // pre
    final StreamController<DiagnosticsScreenVm> feed =
        StreamController<DiagnosticsScreenVm>();
    addTearDown(feed.close);
    final FakeSettingsDiagnosticsRepository repo =
        FakeSettingsDiagnosticsRepository(
          diagnostics: (int call) => feed.stream,
        );
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Future<ActionResult>.value(results[2]),
    );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    feed.add(diff);
    await pumpDiagnostics(
      tester,
      overrides: diagnosticsOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s10-golden-run')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('m9s10-locked')), findsNothing);
    feed.add(locked);
    await tester.pump();
    await tester.pump();

    expect(shownTexts(tester, find.byKey(const Key('m9s10-locked'))), <String?>[
      ?locked.lockedLabel,
    ]);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s10-golden'))),
      selfTestCardTexts(locked.golden),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s10-golden-result'))),
      <String?>[results[2].headline, ?results[2].reasonCode],
    );

    final List<Key> chain = <Key>[
      const Key('m9s10-locked'),
      const Key('m9s10-golden'),
      const Key('m9s10-golden-result'),
      const Key('m9s10-integrity'),
      const Key('m9s10-board'),
      const Key('m9s10-diffs'),
      const Key('m9s10-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    await tester.tap(find.byKey(const Key('m9s10-diffs')));
    await tester.pump();
    expect(opener.opened, <String>[?locked.diffsLink?.deepLink]);
    expect(actions.ids, selfTestRunIds(diff.golden));
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S10-08: locked line, no buttons, link and board stay -----------------

  for (final c
      in <
        ({
          String name,
          DiagnosticsScreenVm v,
          List<String?> lockedTexts,
          List<String?> buttons,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          buttons: <String?>[],
          chain: <Key>[
            const Key('m9s10-locked'),
            const Key('m9s10-golden'),
            const Key('m9s10-integrity'),
            const Key('m9s10-board'),
            const Key('m9s10-diffs'),
            const Key('m9s10-asof'),
          ],
        ),
        (
          name: 'diff',
          v: diff,
          lockedTexts: <String?>[],
          buttons: diagnosticsRunLabels(diff),
          chain: <Key>[
            const Key('m9s10-golden'),
            const Key('m9s10-golden-run'),
            const Key('m9s10-integrity'),
            const Key('m9s10-board'),
            const Key('m9s10-integrity-run'),
            const Key('m9s10-diffs'),
            const Key('m9s10-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S10-08 locked line and buttons ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.v.diffsLink, isNotNull); // pre
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      final FakeSettingsActions actions = okActions();
      final RecordingLinkOpener opener = RecordingLinkOpener();
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s10-board')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-locked'))),
        c.lockedTexts,
      );
      expect(buttonTextsOf(tester), c.buttons);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      await tester.tap(find.byKey(const Key('m9s10-diffs')));
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[]);
      expect(opener.opened, <String>[?c.v.diffsLink?.deepLink]);

      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-golden'))),
        selfTestCardTexts(c.v.golden),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-board'))),
        diagnosticsBoardTexts(c.v.board),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-09: viewer (no actions) - no buttons, data and link stay ---------

  for (final c in <({String name, DiagnosticsScreenVm v})>[
    (name: 'default', v: normal),
    (name: 'diff', v: diff),
    (name: 'locked', v: locked),
  ]) {
    testWidgets('M9S10-09 viewer no buttons data stays ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: null,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s10-integrity')), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byKey(const Key('m9s10-golden-run')), findsNothing);
      expect(find.byKey(const Key('m9s10-integrity-run')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-golden'))),
        selfTestCardTexts(c.v.golden),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-board'))),
        diagnosticsBoardTexts(c.v.board),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-diffs'))),
        <String?>[?c.v.diffsLink?.label],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-recommend'))),
        <String?>[?c.v.recommendText],
      );
      expect(repo.diagnosticsCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-10: asof line and stale banner -----------------------------------

  for (final c
      in <
        ({
          String name,
          DiagnosticsScreenVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: normal,
          clock: FixedClock(normal.asOf.observedAt),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s10-recommend'), const Key('m9s10-asof')],
        ),
        (
          name: 'stale',
          v: stale,
          clock: FixedClock(
            stale.asOf.observedAt
                .add(stale.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?stale.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s10-stale'),
            const Key('m9s10-recommend'),
            const Key('m9s10-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S10-10 asof line and stale banner ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        normal.board.asOf.observedAt
            .add(normal.board.asOf.staleAfter)
            .isBefore(normal.asOf.observedAt),
        isTrue,
      ); // pre
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s10-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s10-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s10-stale'))),
        c.staleTexts,
      );
      expect(find.text(c.v.board.asOf.label), findsNothing);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S10-11: loading and error branches -----------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<DiagnosticsScreenVm> Function(int call) diagnostics,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          diagnostics: (int call) => Stream<DiagnosticsScreenVm>.multi(
            (MultiStreamController<DiagnosticsScreenVm> m) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          diagnostics: (int call) =>
              Stream<DiagnosticsScreenVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S10-11 loading and error ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(diagnostics: c.diagnostics);
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s10-loading')), c.loading);
      expect(find.byKey(const Key('m9s10-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s10-board')), findsNothing);
      expect(find.byKey(const Key('m9s10-integrity-run')), findsNothing);
    });
  }

  // -- M9S10-12: retry subscribes again ---------------------------------------

  testWidgets('M9S10-12 retry after error', (WidgetTester tester) async {
    final FakeSettingsDiagnosticsRepository repo =
        FakeSettingsDiagnosticsRepository(
          diagnostics: (int call) => call == 0
              ? Stream<DiagnosticsScreenVm>.error(StateError('fail'))
              : one(normal),
        );
    await pumpDiagnostics(
      tester,
      overrides: diagnosticsOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('m9s10-fail')), findsNothing);
    expect(find.byKey(const Key('m9s10-board')), findsOneWidget);
    expect(repo.diagnosticsCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S10-13: every Text is received data or a control label ---------------

  for (final c
      in <
        ({
          String name,
          DiagnosticsScreenVm v,
          SettingsActions? Function() actionsFactory,
          Set<String> allowed,
        })
      >[
        (
          name: 'default_operator',
          v: normal,
          actionsFactory: okActions,
          allowed: <String>{
            ...diagnosticsAllowed(normal),
            ...diagnosticsControlTexts(normal),
          },
        ),
        (
          name: 'diff_operator',
          v: diff,
          actionsFactory: okActions,
          allowed: <String>{
            ...diagnosticsAllowed(diff),
            ...diagnosticsControlTexts(diff),
          },
        ),
        (
          name: 'running_operator',
          v: running,
          actionsFactory: okActions,
          allowed: <String>{
            ...diagnosticsAllowed(running),
            ...diagnosticsControlTexts(running),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actionsFactory: okActions,
          allowed: <String>{
            ...diagnosticsAllowed(locked),
            ...diagnosticsControlTexts(locked),
          },
        ),
        (
          name: 'default_viewer',
          v: normal,
          actionsFactory: noActions,
          allowed: diagnosticsAllowed(normal),
        ),
        (
          name: 'diff_viewer',
          v: diff,
          actionsFactory: noActions,
          allowed: diagnosticsAllowed(diff),
        ),
      ]) {
    testWidgets('M9S10-13 all texts allowed large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final FakeSettingsDiagnosticsRepository repo =
          FakeSettingsDiagnosticsRepository(
            diagnostics: (int call) => one(c.v),
          );
      await pumpDiagnostics(
        tester,
        overrides: diagnosticsOverrides(
          repo: repo,
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byType(EditableText), findsNothing);
      final Set<String> allowed = c.allowed;
      final List<String?> shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data)
          .toList();
      expect(shown, isNotEmpty);
      for (final String? data in shown) {
        expect(data, isIn(allowed));
      }
      expect(find.byType(IconButton), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
