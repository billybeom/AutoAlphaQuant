// test/operations_test.dart
//
// M9 S05 -- Operations widget tests part 1 of 2 (38 tests).
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

// -- Gate look helper (lib copy) ----------------------------------------------

(IconData, Color) wantGate(ColorScheme cs, GateState s) => switch (s) {
  GateState.pass => (Icons.lock_open, cs.primary),
  GateState.block => (Icons.lock_outline, cs.error),
  GateState.notApplicable => (Icons.remove_circle_outline, cs.onSurfaceVariant),
  GateState.unknown => (Icons.help_outline, cs.error),
};

ColorScheme colorsOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Operations))).colorScheme;

Finder buttonsIn(Key k) => find.descendant(
  of: find.byKey(k),
  matching: find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
);

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
  final SimTrialCard trialProg = simAuto.trial!;
  final SettingsActionCall promote = promotable.mode.promotionAction!;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[10]),
  );
  SettingsActions? noActions() => null;

  // -- M9S05-01 block order and texts -----------------------------------------

  testWidgets('M9S05-01 block order and texts', (WidgetTester tester) async {
    expect(simAuto.operatingMode.options, hasLength(2));
    expect(trialProg.checks, hasLength(5));

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
      shownTexts(tester, find.byKey(const Key('m9s05-chip'))),
      chipTexts(simAuto.statusChip),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s05-mode'))),
      modeOperatorTexts(simAuto.mode),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s05-opmode'))),
      opModeOperatorTexts(simAuto.operatingMode),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s05-trial'))),
      trialTexts(trialProg),
    );
    for (final (int i, SimTrialCheck k) in trialProg.checks.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s05-check-$i'))),
        <String?>[k.label, k.stateLabel, k.detailText],
      );
    }
    for (final (int o, OperatingModeOption _)
        in simAuto.operatingMode.options.indexed) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey<String>('m9s05-option-$o')),
          matching: find.byType(Icon),
        ),
        findsNothing,
      );
    }
    expect(shownTexts(tester, find.byKey(const Key('m9s05-asof'))), <String?>[
      simAuto.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const Key('m9s05-chip'),
      const Key('m9s05-mode'),
      const Key('m9s05-opmode'),
      const Key('m9s05-trial'),
      const Key('m9s05-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    expect(find.byKey(const ValueKey<String>('m9s05-check-5')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s05-option-2')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s05-switch-1')), findsNothing);
    expect(buttonsIn(const Key('m9s05-mode')), findsNWidgets(1));
    expect(buttonsIn(const Key('m9s05-opmode')), findsNothing);
    expect(find.byKey(const Key('m9s05-stale')), findsNothing);
    expect(find.byKey(const Key('m9s05-locked')), findsNothing);
    expect(find.byKey(const Key('m9s05-result')), findsNothing);
    expect(find.byKey(const Key('m9s05-not-accepted')), findsNothing);
    expect(find.byKey(const Key('m9s05-last-request')), findsNothing);
    expect(find.byKey(const Key('m9s05-hold')), findsNothing);
    expect(find.byKey(const Key('m9s05-observation')), findsNothing);
    expect(find.byKey(const Key('m9s05-promote')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S05-02 block texts six cases -----------------------------------------

  for (final c
      in <
        ({String name, OperationsVm v, Matcher modeButtons, Matcher opButtons})
      >[
        (
          name: 'sim_complete',
          v: simComplete,
          modeButtons: findsNWidgets(1),
          opButtons: findsNothing,
        ),
        (
          name: 'live_observe',
          v: observe,
          modeButtons: findsNothing,
          opButtons: findsNothing,
        ),
        (
          name: 'live_promotable',
          v: promotable,
          modeButtons: findsNWidgets(1),
          opButtons: findsNothing,
        ),
        (
          name: 'hold_keys',
          v: holdKeys,
          modeButtons: findsNothing,
          opButtons: findsNothing,
        ),
        (
          name: 'advisory',
          v: advisory,
          modeButtons: findsNothing,
          opButtons: findsNWidgets(1),
        ),
        (
          name: 'locked',
          v: locked,
          modeButtons: findsNothing,
          opButtons: findsNothing,
        ),
      ]) {
    testWidgets('M9S05-02 block texts ${c.name}', (WidgetTester tester) async {
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

      expect(find.byKey(const Key('m9s05-chip')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-chip'))),
        chipTexts(c.v.statusChip),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-mode'))),
        modeOperatorTexts(c.v.mode),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-opmode'))),
        opModeOperatorTexts(c.v.operatingMode),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-trial'))),
        trialTexts(c.v.trial),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-last-request'))),
        <String?>[?c.v.lastRequestNotice],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(buttonsIn(const Key('m9s05-mode')), c.modeButtons);
      expect(buttonsIn(const Key('m9s05-opmode')), c.opButtons);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-03 level and gate icons ------------------------------------------

  for (final c in <({String name, OperationsVm v})>[
    (name: 'sim_auto', v: simAuto),
    (name: 'advisory', v: advisory),
    (name: 'hold_keys', v: holdKeys),
  ]) {
    testWidgets('M9S05-03 level gate icon color ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        <UiLevel>{
          c.v.statusChip.level,
          c.v.mode.level,
          c.v.operatingMode.trust.level,
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

      final Icon chipIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-chip-level')),
      );
      final (IconData chipWant, Color chipColor) = wantLevel(
        cs,
        c.v.statusChip.level,
      );
      expect(chipIcon.icon, chipWant);
      expect(chipIcon.color, chipColor);

      final Icon modeIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-mode-level')),
      );
      final (IconData modeWant, Color modeColor) = wantLevel(
        cs,
        c.v.mode.level,
      );
      expect(modeIcon.icon, modeWant);
      expect(modeIcon.color, modeColor);

      final Icon trustIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-trust-level')),
      );
      final (IconData trustWant, Color trustColor) = wantLevel(
        cs,
        c.v.operatingMode.trust.level,
      );
      expect(trustIcon.icon, trustWant);
      expect(trustIcon.color, trustColor);

      for (final (int g, GateBadge gate)
          in c.v.operatingMode.switchGates.indexed) {
        final Icon gateIcon = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s05-gate-level-$g')),
        );
        final (IconData gateWant, Color gateColor) = wantGate(cs, gate.state);
        expect(gateIcon.icon, gateWant);
        expect(gateIcon.color, gateColor);
      }

      for (final (int i, SimTrialCheck check)
          in (c.v.trial?.checks ?? const <SimTrialCheck>[]).indexed) {
        final Icon checkIcon = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s05-check-level-$i')),
        );
        final (IconData checkWant, Color checkColor) = wantLevel(
          cs,
          check.level,
        );
        expect(checkIcon.icon, checkWant);
        expect(checkIcon.color, checkColor);
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-04 handoff buttons: run once, handoff route ----------------------

  for (final c
      in <
        ({
          String name,
          OperationsVm v,
          Key tap,
          SettingsActionCall call,
          ActionResult r,
        })
      >[
        (
          name: 'mode_wizard',
          v: simAuto,
          tap: const ValueKey<String>('m9s05-switch-0'),
          call: simAuto.mode.switchActions[0],
          r: results[0],
        ),
        (
          name: 'mode_gate',
          v: simComplete,
          tap: const ValueKey<String>('m9s05-switch-0'),
          call: simComplete.mode.switchActions[0],
          r: results[1],
        ),
        (
          name: 'opmode',
          v: advisory,
          tap: const ValueKey<String>('m9s05-opswitch-0'),
          call: advisory.operatingMode.switchActions[0],
          r: results[2],
        ),
      ]) {
    testWidgets('M9S05-04 handoff run once ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNotNull); // pre

      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final FakeSettingsOperationsRepository repo =
          FakeSettingsOperationsRepository(operations: (int call) => one(c.v));
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: repo,
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
      expect(opener.opened, <String>[?c.r.handoffRoute]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s05-result'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s05-chip'))).dy),
      );
      expect(actions.watchCalls, 0);
      expect(repo.operationsCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-05 promotion: run once, result fragment, no handoff --------------

  for (final c in <({String name, ActionResult r})>[
    (name: 'not_enough', r: results[9]),
    (name: 'ok', r: results[10]),
    (name: 'bio', r: results[11]),
    (name: 'not_observing', r: results[12]),
  ]) {
    testWidgets('M9S05-05 promotion run once ${c.name}', (
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
            operations: (int call) => one(promotable),
          ),
          actions: actions,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s05-promote')));
      await tester.pump();
      await tester.pump();

      expect(actions.ids, <SettingsActionId>[promote.id]);
      expect(actions.argsSeen, <Map<String, String>>[promote.args]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final Icon resultIcon = tester.widget<Icon>(
        find.byKey(const Key('m9s05-result-level')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(
        colorsOf(tester),
        c.r.level,
      );
      expect(resultIcon.icon, wantIcon);
      expect(resultIcon.color, wantColor);
      expect(opener.opened, <String>[]);
      expect(find.byKey(const Key('m9s05-not-accepted')), findsNothing);
      expect(find.byKey(const Key('m9s05-promote')), findsOneWidget);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-06 fail <-> ok two directions ------------------------------------

  for (final c
      in <
        ({
          String name,
          Future<ActionResult> Function(int call) factory,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
        })
      >[
        (
          name: 'fail_then_ok',
          factory: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[10]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[10].headline],
        ),
        (
          name: 'ok_then_fail',
          factory: (int call) => call == 0
              ? Future<ActionResult>.value(results[10])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[10].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S05-06 fail ok two directions ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: c.factory,
      );

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(promotable),
          ),
          actions: actions,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s05-promote')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-result'))),
        c.firstRes,
      );

      await tester.tap(find.byKey(const Key('m9s05-promote')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-result'))),
        c.secondRes,
      );
      expect(actions.ids, <SettingsActionId>[promote.id, promote.id]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-07 no double tap while busy --------------------------------------

  for (final c
      in <
        ({String name, OperationsVm v, Key tap, List<SettingsActionId> want})
      >[
        (
          name: 'switch',
          v: simAuto,
          tap: const ValueKey<String>('m9s05-switch-0'),
          want: <SettingsActionId>[simAuto.mode.switchActions[0].id],
        ),
        (
          name: 'promote',
          v: promotable,
          tap: const Key('m9s05-promote'),
          want: <SettingsActionId>[promote.id],
        ),
        (
          name: 'opswitch',
          v: advisory,
          tap: const ValueKey<String>('m9s05-opswitch-0'),
          want: <SettingsActionId>[advisory.operatingMode.switchActions[0].id],
        ),
      ]) {
    testWidgets('M9S05-07 no double tap while busy ${c.name}', (
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
      expect(find.byKey(const Key('m9s05-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-08 viewer: no injection, no buttons, data as-is ------------------

  for (final c in <({String name, OperationsVm v})>[
    (name: 'sim_auto', v: simAuto),
    (name: 'live_promotable', v: promotable),
    (name: 'advisory', v: advisory),
  ]) {
    testWidgets('M9S05-08 viewer no buttons data as-is ${c.name}', (
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

      expect(find.byKey(const Key('m9s05-chip')), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('m9s05-switch-0')),
        findsNothing,
      );
      expect(find.byKey(const Key('m9s05-promote')), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('m9s05-opswitch-0')),
        findsNothing,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-mode'))),
        modeViewerTexts(c.v.mode),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-opmode'))),
        opModeViewerTexts(c.v.operatingMode),
      );
      expect(repo.operationsCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-09 locked: one line, rest as received ----------------------------

  for (final c
      in <
        ({
          String name,
          OperationsVm v,
          List<String?> lockedTexts,
          Matcher promoteMatcher,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          promoteMatcher: findsNothing,
          chain: <Key>[
            const Key('m9s05-locked'),
            const Key('m9s05-chip'),
            const Key('m9s05-asof'),
          ],
        ),
        (
          name: 'normal',
          v: promotable,
          lockedTexts: <String?>[],
          promoteMatcher: findsOneWidget,
          chain: <Key>[const Key('m9s05-chip'), const Key('m9s05-asof')],
        ),
      ]) {
    testWidgets('M9S05-09 locked line ${c.name}', (WidgetTester tester) async {
      expect(locked.lockedLabel, isNotNull); // pre

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

      expect(find.byKey(const Key('m9s05-mode')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-locked'))),
        c.lockedTexts,
      );
      expect(find.byKey(const Key('m9s05-promote')), c.promoteMatcher);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-mode'))),
        modeOperatorTexts(c.v.mode),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-10 asOf line and stale banner ------------------------------------

  for (final c
      in <
        ({String name, Clock clock, List<String?> staleTexts, List<Key> chain})
      >[
        (
          name: 'fresh',
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s05-chip'), const Key('m9s05-asof')],
        ),
        (
          name: 'stale',
          clock: FixedClock(
            simAuto.asOf.observedAt
                .add(simAuto.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?simAuto.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s05-stale'),
            const Key('m9s05-chip'),
            const Key('m9s05-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S05-10 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(simAuto),
          ),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s05-asof')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s05-stale'))),
        c.staleTexts,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S05-11 state branches ------------------------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<OperationsVm> Function(int call) factory,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          factory: (int call) => Stream<OperationsVm>.multi(
            (MultiStreamController<OperationsVm> ctrl) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          factory: (int call) => Stream<OperationsVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S05-11 state branch ${c.name}', (WidgetTester tester) async {
      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(operations: c.factory),
          actions: okActions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s05-loading')), c.loading);
      expect(find.byKey(const Key('m9s05-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s05-chip')), findsNothing);
    });
  }

  // -- M9S05-12 retry ---------------------------------------------------------

  testWidgets('M9S05-12 retry invalidate', (WidgetTester tester) async {
    final FakeSettingsOperationsRepository repo =
        FakeSettingsOperationsRepository(
          operations: (int call) => call == 0
              ? Stream<OperationsVm>.error(StateError('fail'))
              : one(simAuto),
        );

    await pumpOperations(
      tester,
      overrides: operationsOverrides(
        repo: repo,
        actions: okActions(),
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s05-fail')), findsNothing);
    expect(find.byKey(const Key('m9s05-chip')), findsOneWidget);
    expect(repo.operationsCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S05-13 all screen texts, large font ----------------------------------

  for (final c
      in <
        ({
          String name,
          OperationsVm v,
          SettingsActions? Function() actions,
          Set<String> allowed,
        })
      >[
        (
          name: 'sim_auto_operator',
          v: simAuto,
          actions: okActions,
          allowed: <String>{
            ...operationsAllowed(simAuto),
            ...operationsControlTexts(simAuto),
          },
        ),
        (
          name: 'sim_complete_operator',
          v: simComplete,
          actions: okActions,
          allowed: <String>{
            ...operationsAllowed(simComplete),
            ...operationsControlTexts(simComplete),
          },
        ),
        (
          name: 'live_observe_operator',
          v: observe,
          actions: okActions,
          allowed: <String>{
            ...operationsAllowed(observe),
            ...operationsControlTexts(observe),
          },
        ),
        (
          name: 'advisory_operator',
          v: advisory,
          actions: okActions,
          allowed: <String>{
            ...operationsAllowed(advisory),
            ...operationsControlTexts(advisory),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actions: okActions,
          allowed: <String>{
            ...operationsAllowed(locked),
            ...operationsControlTexts(locked),
          },
        ),
        (
          name: 'sim_auto_viewer',
          v: simAuto,
          actions: noActions,
          allowed: operationsAllowed(simAuto),
        ),
      ]) {
    testWidgets('M9S05-13 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpOperations(
        tester,
        overrides: operationsOverrides(
          repo: FakeSettingsOperationsRepository(
            operations: (int call) => one(c.v),
          ),
          actions: c.actions(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

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
