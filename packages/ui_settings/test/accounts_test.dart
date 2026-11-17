// test/accounts_test.dart
//
// M9 S03 -- Accounts widget tests (43 tests).
//
// ASCII only. No Korean literals. collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// -- Level look and mark helpers (lib copy) -----------------------------------

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

IconData wantMark(AccountMappingOption o) =>
    o.selected ? Icons.radio_button_checked : Icons.radio_button_unchecked;

ColorScheme colorsOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Accounts))).colorScheme;

void main() {
  final AccountMappingVm mapping = singleFixture(
    FixturePaths.m9AccountMapping,
    AccountMappingVm.fromJson,
  );
  final AccountMappingVm unmapped = singleFixture(
    FixturePaths.m9AccountMappingUnmapped,
    AccountMappingVm.fromJson,
  );
  final AccountMappingVm locked = singleFixture(
    FixturePaths.m9AccountMappingLocked,
    AccountMappingVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9AccountMappingActionResults,
    ActionResult.fromJson,
  ).rows;
  final SettingsActionCall verify = mapping.verifyAction!;
  final SettingsActionCall mapAIsa =
      mapping.mappings[0].options[1].selectAction!;
  final SettingsActionCall mapBPension =
      mapping.mappings[1].options[1].selectAction!;
  final SettingsActionCall mapBGeneral =
      mapping.mappings[1].options[2].selectAction!;
  final SettingsActionCall mapCIsa =
      mapping.mappings[2].options[2].selectAction!;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );
  SettingsActions? noActions() => null;
  Future<void> noSteps(WidgetTester t) async {}
  Future<void> openAIsa(WidgetTester t) async {
    await t.tap(find.byKey(const ValueKey<String>('m9s03-pick-0-1')));
    await t.pump();
  }

  // -- M9S03-01 block order and texts -----------------------------------------

  testWidgets('M9S03-01 block order and texts', (WidgetTester tester) async {
    await pumpAccounts(
      tester,
      overrides: accountsOverrides(
        repo: FakeSettingsAccountMappingRepository(
          mapping: (int call) => one(mapping),
        ),
        actions: okActions(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(mapping.mappings, hasLength(3));
    for (final (int i, AccountRow a) in mapping.accounts.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s03-account-$i'))),
        accountTexts(a),
      );
    }
    for (final (int i, SleeveMappingRow s) in mapping.mappings.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s03-sleeve-$i'))),
        sleeveOperatorTexts(s),
      );
    }
    expect(shownTexts(tester, find.byKey(const Key('m9s03-verify'))), <String?>[
      ?mapping.verifyAction?.label,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('m9s03-asof'))), <String?>[
      mapping.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const ValueKey<String>('m9s03-account-0'),
      const ValueKey<String>('m9s03-account-1'),
      const ValueKey<String>('m9s03-account-2'),
      const ValueKey<String>('m9s03-account-3'),
      const ValueKey<String>('m9s03-account-4'),
      const ValueKey<String>('m9s03-sleeve-0'),
      const ValueKey<String>('m9s03-sleeve-1'),
      const ValueKey<String>('m9s03-sleeve-2'),
      const Key('m9s03-verify'),
      const Key('m9s03-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }
    expect(find.byKey(const ValueKey<String>('m9s03-account-5')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s03-sleeve-3')), findsNothing);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(6),
    );
    expect(find.byKey(const Key('m9s03-stale')), findsNothing);
    expect(find.byKey(const Key('m9s03-locked')), findsNothing);
    expect(find.byKey(const Key('m9s03-result')), findsNothing);
    expect(find.byKey(const Key('m9s03-not-accepted')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('m9s03-confirm-0-1')),
      findsNothing,
    );
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S03-02 block texts three cases ---------------------------------------

  for (final c in <({String name, AccountMappingVm v, Matcher buttons})>[
    (name: 'mapped', v: mapping, buttons: findsNWidgets(6)),
    (name: 'unmapped', v: unmapped, buttons: findsNWidgets(6)),
    (name: 'locked', v: locked, buttons: findsNothing),
  ]) {
    testWidgets('M9S03-02 block texts ${c.name}', (WidgetTester tester) async {
      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(c.v),
          ),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s03-account-0')),
        findsOneWidget,
      );
      for (final (int i, AccountRow a) in c.v.accounts.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s03-account-$i'))),
          accountTexts(a),
        );
      }
      for (final (int i, SleeveMappingRow s) in c.v.mappings.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s03-sleeve-$i'))),
          sleeveOperatorTexts(s),
        );
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-verify'))),
        <String?>[?c.v.verifyAction?.label],
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-03 level to icon and color two cases -----------------------------

  for (final c in <({String name, AccountMappingVm v})>[
    (name: 'mapped', v: mapping),
    (name: 'unmapped', v: unmapped),
  ]) {
    testWidgets('M9S03-03 level icon color ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        <UiLevel>{
          for (final AccountRow a in c.v.accounts) a.level,
          for (final SleeveMappingRow s in c.v.mappings) s.level,
        }.length,
        greaterThan(1),
      ); // pre

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(c.v),
          ),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final ColorScheme cs = colorsOf(tester);
      for (final (int i, AccountRow a) in c.v.accounts.indexed) {
        final Icon ic = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s03-account-level-$i')),
        );
        expect(ic.icon, wantLevel(cs, a.level).$1);
        expect(ic.color, wantLevel(cs, a.level).$2);
      }
      for (final (int i, SleeveMappingRow s) in c.v.mappings.indexed) {
        final Icon ic = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s03-sleeve-level-$i')),
        );
        expect(ic.icon, wantLevel(cs, s.level).$1);
        expect(ic.color, wantLevel(cs, s.level).$2);
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-04 option rows, marks, pick buttons three cases ------------------

  for (final c in <({String name, AccountMappingVm v})>[
    (name: 'mapped', v: mapping),
    (name: 'unmapped', v: unmapped),
    (name: 'locked', v: locked),
  ]) {
    testWidgets('M9S03-04 option rows ${c.name}', (WidgetTester tester) async {
      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(c.v),
          ),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s03-option-0-0')),
        findsOneWidget,
      );
      for (final (int i, SleeveMappingRow s) in c.v.mappings.indexed) {
        for (final (int o, AccountMappingOption opt) in s.options.indexed) {
          final Icon mk = tester.widget<Icon>(
            find.byKey(ValueKey<String>('m9s03-mark-$i-$o')),
          );
          expect(mk.icon, wantMark(opt));
          expect(
            shownTexts(
              tester,
              find.byKey(ValueKey<String>('m9s03-option-$i-$o')),
            ),
            optionOperatorTexts(opt),
          );
          expect(
            find.byKey(ValueKey<String>('m9s03-pick-$i-$o')),
            opt.selectAction == null ? findsNothing : findsOneWidget,
          );
        }
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-05 pick expands, confirm runs once, result, collapse -------------

  for (final c
      in <
        ({
          String name,
          int row,
          int option,
          SettingsActionCall call,
          ActionResult r,
        })
      >[
        (name: 'pension', row: 1, option: 1, call: mapBPension, r: results[0]),
        (
          name: 'race_saf309',
          row: 1,
          option: 2,
          call: mapBGeneral,
          r: results[2],
        ),
        (name: 'verify_fail', row: 2, option: 2, call: mapCIsa, r: results[3]),
        (name: 'bio', row: 0, option: 1, call: mapAIsa, r: results[4]),
      ]) {
    testWidgets('M9S03-05 pick confirm run ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsAccountMappingRepository repo =
          FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: repo,
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(
        find.byKey(ValueKey<String>('m9s03-pick-${c.row}-${c.option}')),
      );
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        shownTexts(
          tester,
          find.byKey(ValueKey<String>('m9s03-confirm-${c.row}-${c.option}')),
        ),
        optionConfirmTexts(mapping.mappings[c.row].options[c.option]),
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNWidgets(8),
      );
      await tester.tap(
        find.byKey(ValueKey<String>('m9s03-confirm-yes-${c.row}-${c.option}')),
      );
      await tester.pump();
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[c.call.id]);
      expect(actions.argsSeen, <Map<String, String>>[c.call.args]);
      expect(
        find.byKey(ValueKey<String>('m9s03-confirm-${c.row}-${c.option}')),
        findsNothing,
      );

      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s03-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(actions.watchCalls, 0);
      expect(repo.mappingCalls, 1);
      expect(
        find.byKey(ValueKey<String>('m9s03-pick-${c.row}-${c.option}')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m9s03-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-06 verify runs once, result piece ---------------------------------

  for (final c in <({String name, ActionResult r})>[
    (name: 'ok', r: results[5]),
    (name: 'watch', r: results[6]),
    (name: 'fail', r: results[7]),
  ]) {
    testWidgets('M9S03-06 verify run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsAccountMappingRepository repo =
          FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: repo,
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s03-verify')));
      await tester.pump();
      await tester.pump();

      expect(actions.ids, <SettingsActionId>[verify.id]);
      expect(actions.argsSeen, <Map<String, String>>[verify.args]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s03-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s03-result'))).dy,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('m9s03-account-0')))
              .dy,
        ),
      );
      expect(actions.watchCalls, 0);
      expect(repo.mappingCalls, 1);
      expect(find.byKey(const Key('m9s03-verify')), findsOneWidget);
      expect(find.byKey(const Key('m9s03-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-07 one open place, cancel collapses, run 0 ------------------------

  for (final c
      in <
        ({
          String name,
          List<Key> taps,
          Matcher bPension,
          Matcher bGeneral,
          Matcher cPension,
          Matcher buttons,
        })
      >[
        (
          name: 'cancel',
          taps: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-confirm-no-1-1'),
          ],
          bPension: findsNothing,
          bGeneral: findsNothing,
          cPension: findsNothing,
          buttons: findsNWidgets(6),
        ),
        (
          name: 'same_row',
          taps: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-pick-1-2'),
          ],
          bPension: findsNothing,
          bGeneral: findsOneWidget,
          cPension: findsNothing,
          buttons: findsNWidgets(8),
        ),
        (
          name: 'other_row',
          taps: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-pick-2-1'),
          ],
          bPension: findsNothing,
          bGeneral: findsNothing,
          cPension: findsOneWidget,
          buttons: findsNWidgets(8),
        ),
        (
          name: 'again',
          taps: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-pick-1-1'),
          ],
          bPension: findsOneWidget,
          bGeneral: findsNothing,
          cPension: findsNothing,
          buttons: findsNWidgets(8),
        ),
      ]) {
    testWidgets('M9S03-07 single open place ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsAccountMappingRepository repo =
          FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          );
      final FakeSettingsActions actions = okActions();

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: repo,
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.taps) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }

      expect(
        find.byKey(const ValueKey<String>('m9s03-confirm-1-1')),
        c.bPension,
      );
      expect(
        find.byKey(const ValueKey<String>('m9s03-confirm-1-2')),
        c.bGeneral,
      );
      expect(
        find.byKey(const ValueKey<String>('m9s03-confirm-2-1')),
        c.cPension,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        find.byKey(const ValueKey<String>('m9s03-pick-1-1')),
        findsOneWidget,
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-08 fail then ok, ok then fail, two paths ---------------------------

  for (final c
      in <
        ({
          String name,
          Future<ActionResult> Function(int call) result,
          List<Key> press,
          SettingsActionCall call,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
        })
      >[
        (
          name: 'map_fail_then_ok',
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          press: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-confirm-yes-1-1'),
          ],
          call: mapBPension,
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline],
        ),
        (
          name: 'map_ok_then_fail',
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          press: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-confirm-yes-1-1'),
          ],
          call: mapBPension,
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
        (
          name: 'verify_fail_then_ok',
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[5]),
          press: <Key>[const Key('m9s03-verify')],
          call: verify,
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[5].headline],
        ),
        (
          name: 'verify_ok_then_fail',
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[5])
              : Future<ActionResult>.error(StateError('fail')),
          press: <Key>[const Key('m9s03-verify')],
          call: verify,
          firstNa: <String?>[],
          firstRes: <String?>[results[5].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S03-08 two directions ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(result: c.result);

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          ),
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.press) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-result'))),
        c.firstRes,
      );
      expect(
        find.byKey(const ValueKey<String>('m9s03-confirm-1-1')),
        findsNothing,
      );

      for (final Key k in c.press) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-result'))),
        c.secondRes,
      );
      expect(actions.ids, <SettingsActionId>[c.call.id, c.call.id]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-09 no double tap while waiting, all buttons disabled ---------------

  for (final c
      in <
        ({
          String name,
          List<Key> first,
          Key again,
          List<SettingsActionId> want,
          Key block,
          Matcher open,
        })
      >[
        (
          name: 'verify',
          first: <Key>[const Key('m9s03-verify')],
          again: const Key('m9s03-verify'),
          want: <SettingsActionId>[verify.id],
          block: const ValueKey<String>('m9s03-confirm-1-1'),
          open: findsNothing,
        ),
        (
          name: 'b_pension',
          first: <Key>[
            const ValueKey<String>('m9s03-pick-1-1'),
            const ValueKey<String>('m9s03-confirm-yes-1-1'),
          ],
          again: const ValueKey<String>('m9s03-confirm-yes-1-1'),
          want: <SettingsActionId>[mapBPension.id],
          block: const ValueKey<String>('m9s03-confirm-1-1'),
          open: findsOneWidget,
        ),
        (
          name: 'c_isa',
          first: <Key>[
            const ValueKey<String>('m9s03-pick-2-2'),
            const ValueKey<String>('m9s03-confirm-yes-2-2'),
          ],
          again: const ValueKey<String>('m9s03-confirm-yes-2-2'),
          want: <SettingsActionId>[mapCIsa.id],
          block: const ValueKey<String>('m9s03-confirm-2-2'),
          open: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S03-09 no double tap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Completer<ActionResult>().future,
      );

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          ),
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.first) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.tap(find.byKey(c.again));
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
      expect(find.byKey(c.block), c.open);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const Key('m9s03-result')), findsNothing);
      expect(find.byKey(const Key('m9s03-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-10 viewer: injection null, no buttons, data as received -----------

  for (final c in <({String name, AccountMappingVm v})>[
    (name: 'mapped', v: mapping),
    (name: 'unmapped', v: unmapped),
    (name: 'locked', v: locked),
  ]) {
    testWidgets('M9S03-10 viewer ${c.name}', (WidgetTester tester) async {
      final FakeSettingsAccountMappingRepository repo =
          FakeSettingsAccountMappingRepository(mapping: (int call) => one(c.v));

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: repo,
          actions: null,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      for (final (int i, AccountRow a) in c.v.accounts.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s03-account-$i'))),
          accountTexts(a),
        );
      }
      for (final (int i, SleeveMappingRow s) in c.v.mappings.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s03-sleeve-$i'))),
          sleeveViewerTexts(s),
        );
      }
      expect(find.byKey(const Key('m9s03-verify')), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('m9s03-account-0')),
        findsOneWidget,
      );
      expect(repo.mappingCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S03-11 locked line, received as is, buttons absent ---------------------

  for (final c
      in <
        ({
          String name,
          AccountMappingVm v,
          List<String?> lockedTexts,
          Matcher buttons,
          Matcher verify,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          buttons: findsNothing,
          verify: findsNothing,
          chain: <Key>[
            const Key('m9s03-locked'),
            const ValueKey<String>('m9s03-account-0'),
            const ValueKey<String>('m9s03-sleeve-0'),
            const Key('m9s03-asof'),
          ],
        ),
        (
          name: 'normal',
          v: mapping,
          lockedTexts: <String?>[],
          buttons: findsNWidgets(6),
          verify: findsOneWidget,
          chain: <Key>[
            const ValueKey<String>('m9s03-account-0'),
            const ValueKey<String>('m9s03-sleeve-0'),
            const Key('m9s03-verify'),
            const Key('m9s03-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S03-11 locked ${c.name}', (WidgetTester tester) async {
      expect(locked.lockedLabel, isNotNull); // pre

      final FakeSettingsAccountMappingRepository repo =
          FakeSettingsAccountMappingRepository(mapping: (int call) => one(c.v));
      final FakeSettingsActions actions = okActions();

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: repo,
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s03-account-0')),
        findsOneWidget,
      ); // positive anchor
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-locked'))),
        c.lockedTexts,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(find.byKey(const Key('m9s03-verify')), c.verify);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(actions.ids, <SettingsActionId>[]);
      for (final (int i, SleeveMappingRow s) in c.v.mappings.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s03-sleeve-$i'))),
          sleeveOperatorTexts(s),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // Locked line stays if the VM locks after a result (C4r7b-5, C4r7c-6).
  testWidgets('M9S03-11 locked after_result', (WidgetTester tester) async {
    expect(locked.lockedLabel, isNotNull); // pre

    final StreamController<AccountMappingVm> feed =
        StreamController<AccountMappingVm>();
    addTearDown(feed.close);
    final FakeSettingsAccountMappingRepository repo =
        FakeSettingsAccountMappingRepository(
          mapping: (int call) => feed.stream,
        );
    feed.add(mapping);

    await pumpAccounts(
      tester,
      overrides: accountsOverrides(
        repo: repo,
        actions: FakeSettingsActions(
          result: (int call) => Future<ActionResult>.value(results[5]),
        ),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s03-verify')));
    await tester.pump();
    await tester.pump();
    expect(shownTexts(tester, find.byKey(const Key('m9s03-result'))), <String?>[
      results[5].headline,
      ?results[5].reasonCode,
    ]);
    expect(find.byKey(const Key('m9s03-locked')), findsNothing);

    feed.add(locked);
    await tester.pump();
    await tester.pump();

    expect(shownTexts(tester, find.byKey(const Key('m9s03-locked'))), <String?>[
      ?locked.lockedLabel,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('m9s03-result'))), <String?>[
      results[5].headline,
      ?results[5].reasonCode,
    ]);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    final List<Key> chain = <Key>[
      const Key('m9s03-locked'),
      const Key('m9s03-result'),
      const ValueKey<String>('m9s03-account-0'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }
    expect(repo.mappingCalls, 1);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S03-12 asOf line and stale banner two cases ----------------------------

  for (final c
      in <
        ({String name, Clock clock, List<String?> staleTexts, List<Key> chain})
      >[
        (
          name: 'fresh',
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[
            const ValueKey<String>('m9s03-account-0'),
            const Key('m9s03-asof'),
          ],
        ),
        (
          name: 'stale',
          clock: FixedClock(
            mapping.asOf.observedAt
                .add(mapping.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?mapping.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s03-stale'),
            const ValueKey<String>('m9s03-account-0'),
            const Key('m9s03-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S03-12 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(mapping),
          ),
          actions: okActions(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s03-asof')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s03-stale'))),
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

  // -- M9S03-13 state branches two cases -----------------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<AccountMappingVm> Function(int call) stream,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          stream: (int call) => Stream<AccountMappingVm>.multi(
            (MultiStreamController<AccountMappingVm> c) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          stream: (int call) =>
              Stream<AccountMappingVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S03-13 state branch ${c.name}', (WidgetTester tester) async {
      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(mapping: c.stream),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s03-loading')), c.loading);
      expect(find.byKey(const Key('m9s03-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(
        find.byKey(const ValueKey<String>('m9s03-account-0')),
        findsNothing,
      );
    });
  }

  // -- M9S03-14 retry -------------------------------------------------------------

  testWidgets('M9S03-14 retry invalidate', (WidgetTester tester) async {
    final FakeSettingsAccountMappingRepository repo =
        FakeSettingsAccountMappingRepository(
          mapping: (int call) => call == 0
              ? Stream<AccountMappingVm>.error(StateError('fail'))
              : one(mapping),
        );

    await pumpAccounts(
      tester,
      overrides: accountsOverrides(
        repo: repo,
        actions: okActions(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s03-fail')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('m9s03-account-0')),
      findsOneWidget,
    );
    expect(repo.mappingCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S03-15 all texts under large font ----------------------------------------

  for (final c
      in <
        ({
          String name,
          AccountMappingVm v,
          SettingsActions? Function() actions,
          Future<void> Function(WidgetTester t) steps,
          Matcher open,
          Set<String> allowed,
        })
      >[
        (
          name: 'mapped_operator',
          v: mapping,
          actions: okActions,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...accountMappingAllowed(mapping),
            ...accountMappingControlTexts(mapping),
          },
        ),
        (
          name: 'unmapped_operator',
          v: unmapped,
          actions: okActions,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...accountMappingAllowed(unmapped),
            ...accountMappingControlTexts(unmapped),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actions: okActions,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...accountMappingAllowed(locked),
            ...accountMappingControlTexts(locked),
          },
        ),
        (
          name: 'mapped_viewer',
          v: mapping,
          actions: noActions,
          steps: noSteps,
          open: findsNothing,
          allowed: accountMappingAllowed(mapping),
        ),
        (
          name: 'unmapped_viewer',
          v: unmapped,
          actions: noActions,
          steps: noSteps,
          open: findsNothing,
          allowed: accountMappingAllowed(unmapped),
        ),
        (
          name: 'expanded_operator',
          v: mapping,
          actions: okActions,
          steps: openAIsa,
          open: findsOneWidget,
          allowed: <String>{
            ...accountMappingAllowed(mapping),
            ...accountMappingControlTexts(mapping),
          },
        ),
      ]) {
    testWidgets('M9S03-15 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpAccounts(
        tester,
        overrides: accountsOverrides(
          repo: FakeSettingsAccountMappingRepository(
            mapping: (int call) => one(c.v),
          ),
          actions: c.actions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      await c.steps(tester);

      expect(find.byKey(const ValueKey<String>('m9s03-confirm-0-1')), c.open);
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
      expect(find.byType(EditableText), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }
}
