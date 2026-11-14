// test/operations_board_test.dart
//
// M9 S05 -- Operations widget tests part 2 of 2 (28 tests).
//
// ASCII only. No Korean literals. collection-if 0.

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
    Theme.of(tester.element(find.byType(Operations))).colorScheme;

void main() {
  final OperationsVm simAuto = singleFixture(
    FixturePaths.m9OperationsSimAuto,
    OperationsVm.fromJson,
  );
  final OperationsVm simComplete = singleFixture(
    FixturePaths.m9OperationsSimComplete,
    OperationsVm.fromJson,
  );
  final OperationsVm observe = singleFixture(
    FixturePaths.m9OperationsLiveObserve,
    OperationsVm.fromJson,
  );
  final OperationsVm promotable = singleFixture(
    FixturePaths.m9OperationsLivePromotable,
    OperationsVm.fromJson,
  );
  final OperationsVm holdKeys = singleFixture(
    FixturePaths.m9OperationsLiveHoldKeys,
    OperationsVm.fromJson,
  );
  final OperationsVm advisory = singleFixture(
    FixturePaths.m9OperationsAdvisory,
    OperationsVm.fromJson,
  );
  final OperationsVm locked = singleFixture(
    FixturePaths.m9OperationsLocked,
    OperationsVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9OperationsActionResults,
    ActionResult.fromJson,
  ).rows;
  final SettingsActionCall start = holdKeys.control.startAction!;
  final SettingsActionCall stop0 = simAuto.control.stopActions[0];
  final SettingsActionCall stop1 = simAuto.control.stopActions[1];

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[3]),
  );
  SettingsActions? noActions() => null;

  // -- M9S05-21 board order and texts ------------------------------------------

  testWidgets('M9S05-21 board order and texts', (WidgetTester tester) async {
    expect(simAuto.jobs, hasLength(6));

    await pumpOperations(
      tester,
      overrides: operationsOverrides(
        repo: FakeSettingsOperationsRepository(
          operations: (int call) => one(simAuto),
        ),
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      shownTexts(tester, find.byKey(const Key('m9s05-ramp'))),
      rampTexts(simAuto.ramp),
    );
    for (final (int j, JobRow job) in simAuto.jobs.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s05-job-$j'))),
        jobTexts(job),
      );
    }
    expect(
      shownTexts(tester, find.byKey(const Key('m9s05-control'))),
      controlOperatorTexts(simAuto.control),
    );

    expect(find.byKey(ValueKey<String>('m9s05-job-6')), findsNothing);
    expect(find.byKey(ValueKey<String>('m9s05-stop-2')), findsNothing);
    expect(find.byKey(const Key('m9s05-update')), findsNothing);
    expect(find.byKey(const Key('m9s05-start')), findsNothing);
    expect(find.byKey(const Key('m9s05-dst')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('m9s05-control')),
        matching: find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      ),
      findsNWidgets(2),
    );

    final double dyTrial = tester
        .getTopLeft(find.byKey(const Key('m9s05-trial')))
        .dy;
    final double dyRamp = tester
        .getTopLeft(find.byKey(const Key('m9s05-ramp')))
        .dy;
    final double dyJob0 = tester
        .getTopLeft(find.byKey(ValueKey<String>('m9s05-job-0')))
        .dy;
    final double dyJob5 = tester
        .getTopLeft(find.byKey(ValueKey<String>('m9s05-job-5')))
        .dy;
    final double dyControl = tester
        .getTopLeft(find.byKey(const Key('m9s05-control')))
        .dy;
    final double dyAsof = tester
        .getTopLeft(find.byKey(const Key('m9s05-asof')))
        .dy;

    expect(dyTrial, lessThan(dyRamp));
    expect(dyRamp, lessThan(dyJob0));
    expect(dyJob0, lessThan(dyJob5));
    expect(dyJob5, lessThan(dyControl));
    expect(dyControl, lessThan(dyAsof));

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S05-22 board texts cases ----------------------------------------------

  final List<
    ({String name, OperationsVm v, Matcher controlButtons, List<Key> chain})
  >
  cases22 =
      <
        ({String name, OperationsVm v, Matcher controlButtons, List<Key> chain})
      >[
        (
          name: 'sim_complete',
          v: simComplete,
          controlButtons: findsNWidgets(2),
          chain: <Key>[
            const Key('m9s05-control'),
            const Key('m9s05-update'),
            const Key('m9s05-last-request'),
            const Key('m9s05-asof'),
          ],
        ),
        (
          name: 'live_observe',
          v: observe,
          controlButtons: findsNWidgets(2),
          chain: <Key>[const Key('m9s05-control'), const Key('m9s05-asof')],
        ),
        (
          name: 'hold_keys',
          v: holdKeys,
          controlButtons: findsNWidgets(1),
          chain: <Key>[
            const Key('m9s05-control'),
            const Key('m9s05-update'),
            const Key('m9s05-asof'),
          ],
        ),
        (
          name: 'advisory',
          v: advisory,
          controlButtons: findsNWidgets(2),
          chain: <Key>[const Key('m9s05-control'), const Key('m9s05-asof')],
        ),
        (
          name: 'locked',
          v: locked,
          controlButtons: findsNothing,
          chain: <Key>[const Key('m9s05-control'), const Key('m9s05-asof')],
        ),
      ];

  for (final c in cases22) {
    testWidgets('M9S05-22 board texts ${c.name}', (WidgetTester tester) async {
      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s05-ramp')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-ramp'))),
        rampTexts(c.v.ramp),
      );
      for (final (int j, JobRow job) in c.v.jobs.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s05-job-$j'))),
          jobTexts(job),
        );
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-control'))),
        controlOperatorTexts(c.v.control),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-update'))),
        updateTexts(c.v.updateGate),
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('m9s05-control')),
          matching: find.byWidgetPredicate(
            (Widget w) => w is ButtonStyleButton,
          ),
        ),
        c.controlButtons,
      );

      for (int i = 0; i < c.chain.length - 1; i++) {
        final double dy0 = tester.getTopLeft(find.byKey(c.chain[i])).dy;
        final double dy1 = tester.getTopLeft(find.byKey(c.chain[i + 1])).dy;
        expect(dy0, lessThan(dy1));
      }

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-23 level icon and color -------------------------------------------

  final List<({String name, OperationsVm v})> cases23 =
      <({String name, OperationsVm v})>[
        (name: 'sim_auto', v: simAuto),
        (name: 'sim_complete', v: simComplete),
        (name: 'live_observe', v: observe),
        (name: 'hold_keys', v: holdKeys),
      ];

  for (final c in cases23) {
    testWidgets('M9S05-23 level icons ${c.name}', (WidgetTester tester) async {
      expect(
        <UiLevel>{
          c.v.ramp.level,
          c.v.control.level,
          for (final JobRow j in c.v.jobs) j.level,
        }.length,
        greaterThan(1),
      ); // pre

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final ColorScheme cs = colorsOf(tester);

      final Icon rampIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-ramp-level')),
      );
      expect(rampIcon.icon, wantLevel(cs, c.v.ramp.level).$1);
      expect(rampIcon.color, wantLevel(cs, c.v.ramp.level).$2);

      for (final (int k, RampCondition cond) in c.v.ramp.conditions.indexed) {
        final Icon condIcon = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s05-cond-level-$k')),
        );
        expect(condIcon.icon, wantLevel(cs, cond.level).$1);
        expect(condIcon.color, wantLevel(cs, cond.level).$2);
      }

      for (final (int j, JobRow job) in c.v.jobs.indexed) {
        final Icon jobIcon = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s05-job-level-$j')),
        );
        expect(jobIcon.icon, wantLevel(cs, job.level).$1);
        expect(jobIcon.color, wantLevel(cs, job.level).$2);
      }

      final Icon controlIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-control-level')),
      );
      expect(controlIcon.icon, wantLevel(cs, c.v.control.level).$1);
      expect(controlIcon.color, wantLevel(cs, c.v.control.level).$2);

      for (final UpdateGateCard u in <UpdateGateCard>[?c.v.updateGate]) {
        final Icon updateIcon = tester.widget<Icon>(
          find.byKey(const Key('m9s05-update-level')),
        );
        expect(updateIcon.icon, wantLevel(cs, u.level).$1);
        expect(updateIcon.color, wantLevel(cs, u.level).$2);
      }

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-24 stop taps run once per reason ----------------------------------

  testWidgets('M9S05-24 stop taps run once per reason', (
    WidgetTester tester,
  ) async {
    final FakeSettingsOperationsRepository repo =
        FakeSettingsOperationsRepository(
          operations: (int call) => one(simAuto),
        );
    final RecordingLinkOpener opener = RecordingLinkOpener();
    final FakeSettingsActions actions = FakeSettingsActions(
      result: (int call) => Future<ActionResult>.value(results[3]),
    );

    await pumpOperations(
      tester,
      overrides: operationsOverrides(
        repo: repo,
        actions: actions,
        opener: opener,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(ValueKey<String>('m9s05-stop-0')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(ValueKey<String>('m9s05-stop-1')));
    await tester.pump();
    await tester.pump();

    expect(actions.ids, <SettingsActionId>[stop0.id, stop1.id]);
    expect(actions.argsSeen, <Map<String, String>>[stop0.args, stop1.args]);
    expect(shownTexts(tester, find.byKey(const Key('m9s05-result'))), <String?>[
      results[3].headline,
      ?results[3].reasonCode,
    ]);
    expect(actions.watchCalls, 0);
    expect(repo.operationsCalls, 1);
    expect(opener.opened, <String>[]);

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S05-25 start/stop results cases ----------------------------------------

  final List<
    ({
      String name,
      OperationsVm v,
      Key tap,
      SettingsActionCall call,
      ActionResult r,
    })
  >
  cases25 =
      <
        ({
          String name,
          OperationsVm v,
          Key tap,
          SettingsActionCall call,
          ActionResult r,
        })
      >[
        (
          name: 'already_running',
          v: holdKeys,
          tap: const Key('m9s05-start'),
          call: start,
          r: results[5],
        ),
        (
          name: 'combo_denied',
          v: holdKeys,
          tap: const Key('m9s05-start'),
          call: start,
          r: results[6],
        ),
        (
          name: 'saf405',
          v: holdKeys,
          tap: const Key('m9s05-start'),
          call: start,
          r: results[7],
        ),
        (
          name: 'credential',
          v: holdKeys,
          tap: const Key('m9s05-start'),
          call: start,
          r: results[8],
        ),
        (
          name: 'already_stopped',
          v: simAuto,
          tap: ValueKey<String>('m9s05-stop-0'),
          call: stop0,
          r: results[4],
        ),
      ];

  for (final c in cases25) {
    testWidgets('M9S05-25 start stop result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.pump();

      expect(actions.ids, <SettingsActionId>[c.call.id]);
      expect(actions.argsSeen, <Map<String, String>>[c.call.args]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );

      final ColorScheme cs = colorsOf(tester);
      final Icon resultIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-result-level')),
      );
      expect(resultIcon.icon, wantLevel(cs, c.r.level).$1);
      expect(resultIcon.color, wantLevel(cs, c.r.level).$2);

      expect(opener.opened, <String>[]);
      expect(find.byKey(const Key('m9s05-not-accepted')), findsNothing);

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-26 no double tap while busy ----------------------------------------

  final List<
    ({String name, OperationsVm v, Key tap, List<SettingsActionId> want})
  >
  cases26 =
      <({String name, OperationsVm v, Key tap, List<SettingsActionId> want})>[
        (
          name: 'start',
          v: holdKeys,
          tap: const Key('m9s05-start'),
          want: <SettingsActionId>[start.id],
        ),
        (
          name: 'stop',
          v: simAuto,
          tap: ValueKey<String>('m9s05-stop-0'),
          want: <SettingsActionId>[stop0.id],
        ),
      ];

  for (final c in cases26) {
    testWidgets('M9S05-26 no double tap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Completer<ActionResult>().future,
      );

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.tap(find.byKey(c.tap));
      await tester.pump();

      expect(actions.ids, c.want);
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
      expect(find.byKey(const Key('m9s05-result')), findsNothing);

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-27 viewer no buttons, data intact ----------------------------------

  final List<({String name, OperationsVm v})> cases27 =
      <({String name, OperationsVm v})>[
        (name: 'sim_auto', v: simAuto),
        (name: 'hold_keys', v: holdKeys),
      ];

  for (final c in cases27) {
    testWidgets('M9S05-27 viewer no buttons ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsOperationsRepository repo =
          FakeSettingsOperationsRepository(operations: (int call) => one(c.v));

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: repo,
          actions: null,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byKey(const Key('m9s05-start')), findsNothing);
      expect(find.byKey(ValueKey<String>('m9s05-stop-0')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-control'))),
        controlViewerTexts(c.v.control),
      );
      expect(find.byKey(const Key('m9s05-control')), findsOneWidget);
      expect(repo.operationsCalls, 1);

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-28 all texts and button count large font --------------------------

  final List<
    ({
      String name,
      OperationsVm v,
      SettingsActions? Function() actionsFactory,
      Set<String> Function(OperationsVm) allowed,
      Matcher buttons,
    })
  >
  cases28 =
      <
        ({
          String name,
          OperationsVm v,
          SettingsActions? Function() actionsFactory,
          Set<String> Function(OperationsVm) allowed,
          Matcher buttons,
        })
      >[
        (
          name: 'sim_auto',
          v: simAuto,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(3),
        ),
        (
          name: 'sim_complete',
          v: simComplete,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(3),
        ),
        (
          name: 'live_observe',
          v: observe,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(2),
        ),
        (
          name: 'live_promotable',
          v: promotable,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(3),
        ),
        (
          name: 'hold_keys',
          v: holdKeys,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(1),
        ),
        (
          name: 'advisory',
          v: advisory,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNWidgets(3),
        ),
        (
          name: 'locked_operator',
          v: locked,
          actionsFactory: okActions,
          allowed: (OperationsVm v) => <String>{
            ...operationsAllowed(v),
            ...operationsControlTexts(v),
          },
          buttons: findsNothing,
        ),
        (
          name: 'sim_auto_viewer',
          v: simAuto,
          actionsFactory: noActions,
          allowed: operationsAllowed,
          buttons: findsNothing,
        ),
      ];

  for (final c in cases28) {
    testWidgets('M9S05-28 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: c.actionsFactory(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final Set<String> allowed = c.allowed(c.v);
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
        c.buttons,
      );

      expect(
        find.byWidgetPredicate((Widget w) => w is IconButton),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
