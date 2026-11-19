// test/contribution_test.dart
//
// M9 S13 — MonthlyContribution widget tests (36 tests).
//
// 🔴 ASCII only · no Korean literals · if 0 · collection-if 0.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import 'golden/golden_support.dart';
import 'settings_fakes.dart';

// ── Level look helpers (lib copy) ───────────────────────────────────────────────

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

ColorScheme colorsOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(MonthlyContribution))).colorScheme;

TextField fieldOf(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(const Key('m9s13-input')));

String fieldText(WidgetTester tester) => fieldOf(tester).controller!.text;

ButtonStyleButton changeOf(WidgetTester tester) =>
    tester.widget<ButtonStyleButton>(find.byKey(const Key('m9s13-change')));

void main() {
  final MonthlyContributionVm normal = singleFixture(
    FixturePaths.m9MonthlyContribution,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm pending = singleFixture(
    FixturePaths.m9MonthlyContributionPending,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm noRecord = singleFixture(
    FixturePaths.m9MonthlyContributionNoRecord,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm noLimit = singleFixture(
    FixturePaths.m9MonthlyContributionNoLimitNote,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm locked = singleFixture(
    FixturePaths.m9MonthlyContributionLocked,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm stale = singleFixture(
    FixturePaths.m9MonthlyContributionStale,
    MonthlyContributionVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9ContributionActionResults,
    ActionResult.fromJson,
  ).rows;

  final String base = normal.amountInputText;
  final String edited = '${base}0';

  FakeSettingsContributionActions okActions() =>
      FakeSettingsContributionActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      );
  SettingsActions? noActions() => null;
  Future<void> noSteps(WidgetTester t) async {}
  Future<void> typeEdited(WidgetTester t) async {
    await t.enterText(find.byKey(const Key('m9s13-input')), edited);
    await t.pump();
  }

  // ── M9S13-01: block order and texts (normal · operator) ─────────────────────

  testWidgets('M9S13-01 block order texts normal operator', (
    WidgetTester tester,
  ) async {
    await pumpContribution(
      tester,
      overrides: contributionOverrides(
        repo: FakeSettingsContributionRepository(
          contribution: (int call) => one(normal),
        ),
        actions: okActions(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
      contributionSettingTexts(normal),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s13-edit'))),
      contributionEditTexts(normal),
    );
    expect(fieldText(tester), normal.amountInputText);
    expect(fieldOf(tester).keyboardType, TextInputType.number);
    expect(shownTexts(tester, find.byKey(const Key('m9s13-asof'))), <String?>[
      normal.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const Key('m9s13-setting'),
      const Key('m9s13-input'),
      const Key('m9s13-change'),
      const Key('m9s13-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    expect(find.byType(TextField), findsOneWidget);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(1),
    );
    expect(find.byKey(const Key('m9s13-stale')), findsNothing);
    expect(find.byKey(const Key('m9s13-locked')), findsNothing);
    expect(find.byKey(const Key('m9s13-result')), findsNothing);
    expect(find.byKey(const Key('m9s13-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S13-02: display rows and first-seed per variant ───────────────────────

  for (final c in <({String name, MonthlyContributionVm v})>[
    (name: 'normal', v: normal),
    (name: 'pending', v: pending),
    (name: 'no_record', v: noRecord),
    (name: 'no_limit', v: noLimit),
  ]) {
    testWidgets('M9S13-02 display rows first seed ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: (int call) => one(c.v),
          ),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s13-setting')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
        contributionSettingTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-edit'))),
        contributionEditTexts(c.v),
      );
      expect(fieldText(tester), c.v.amountInputText);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-03: first-seed only — later VM does not overwrite input ────────────

  for (final c
      in <
        ({
          String name,
          Future<void> Function(WidgetTester t) steps,
          String want,
        })
      >[
        (name: 'typed', steps: typeEdited, want: edited),
        (name: 'untouched', steps: noSteps, want: base),
      ]) {
    testWidgets('M9S13-03 first seed only ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(noLimit.amountInputText, isNot(base)); // pre

      final StreamController<MonthlyContributionVm> feed =
          StreamController<MonthlyContributionVm>();
      addTearDown(feed.close);
      final FakeSettingsContributionRepository repo =
          FakeSettingsContributionRepository(
            contribution: (int call) => feed.stream,
          );

      feed.add(normal);
      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: repo,
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      await c.steps(tester);
      feed.add(noLimit);
      await tester.pump();
      await tester.pump();

      expect(fieldText(tester), c.want);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
        contributionSettingTexts(noLimit),
      );
      expect(repo.contributionCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-04: submit raw input and show result headline + reasonCode ─────────

  for (final c in <({String name, String typed, ActionResult r})>[
    (name: 'accepted', typed: edited, r: results[0]),
    (name: 'bio', typed: '0$base', r: results[1]),
    (name: 'blank', typed: '', r: results[2]),
    (name: 'negative', typed: '-$base', r: results[3]),
    (name: 'not_number', typed: '${base}x', r: results[4]),
    (name: 'over_max', typed: '$base$base', r: results[5]),
    (name: 'zero', typed: noLimit.amountInputText, r: results[6]),
    (name: 'spaced_comma', typed: ' $base, ', r: results[7]),
    (name: 'unchanged', typed: base, r: results[8]),
  ]) {
    testWidgets('M9S13-04 submit raw input result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsContributionRepository repo =
          FakeSettingsContributionRepository(
            contribution: (int call) => one(normal),
          );
      final FakeSettingsContributionActions actions =
          FakeSettingsContributionActions(
            result: (int call) => Future<ActionResult>.value(c.r),
          );

      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: repo,
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.enterText(find.byKey(const Key('m9s13-input')), c.typed);
      await tester.pump();
      expect(actions.inputs, <String>[]);
      await tester.tap(find.byKey(const Key('m9s13-change')));
      await tester.pump();
      await tester.pump();
      expect(actions.inputs, <String>[c.typed]);
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      expect(fieldText(tester), c.typed);

      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s13-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);

      expect(
        tester.getTopLeft(find.byKey(const Key('m9s13-change'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s13-result'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s13-result'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s13-asof'))).dy),
      );

      expect(actions.watchCalls, 0);
      expect(repo.contributionCalls, 1);
      expect(changeOf(tester).enabled, isTrue);
      expect(fieldOf(tester).enabled, isTrue);
      expect(find.byKey(const Key('m9s13-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-05: double-tap blocked · button and input disabled during wait ─────

  testWidgets('M9S13-05 double tap blocked input disabled no spinner', (
    WidgetTester tester,
  ) async {
    final FakeSettingsContributionActions actions =
        FakeSettingsContributionActions(
          result: (int call) => Completer<ActionResult>().future,
        );

    await pumpContribution(
      tester,
      overrides: contributionOverrides(
        repo: FakeSettingsContributionRepository(
          contribution: (int call) => one(normal),
        ),
        actions: actions,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s13-change')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('m9s13-change')));
    await tester.pump();

    expect(actions.inputs, <String>[base]);
    expect(
      tester
          .widgetList<ButtonStyleButton>(
            find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
          )
          .map((ButtonStyleButton b) => b.enabled)
          .toSet(),
      <bool>{false},
    );
    expect(fieldOf(tester).enabled, isFalse);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(const Key('m9s13-result')), findsNothing);
    expect(find.byKey(const Key('m9s13-not-accepted')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S13-06: fail ↔ ok two directions ──────────────────────────────────────

  for (final c
      in <
        ({
          String name,
          Future<ActionResult> Function(int call) resultFactory,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
        })
      >[
        (
          name: 'fail_then_ok',
          resultFactory: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline, ?results[0].reasonCode],
        ),
        (
          name: 'ok_then_fail',
          resultFactory: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline, ?results[0].reasonCode],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S13-06 two direction ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsContributionActions actions =
          FakeSettingsContributionActions(result: c.resultFactory);

      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: (int call) => one(normal),
          ),
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s13-change')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-result'))),
        c.firstRes,
      );

      await tester.tap(find.byKey(const Key('m9s13-change')));
      await tester.pump();
      await tester.pump();

      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-result'))),
        c.secondRes,
      );

      expect(actions.inputs, <String>[base, base]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-07: after submit new VM updates display only, input + result intact

  testWidgets('M9S13-07 new VM updates setting only input result intact', (
    WidgetTester tester,
  ) async {
    expect(pending.appliesFromText, isNot(normal.appliesFromText)); // pre

    final StreamController<MonthlyContributionVm> feed =
        StreamController<MonthlyContributionVm>();
    addTearDown(feed.close);
    final FakeSettingsContributionRepository repo =
        FakeSettingsContributionRepository(
          contribution: (int call) => feed.stream,
        );
    final FakeSettingsContributionActions actions =
        FakeSettingsContributionActions(
          result: (int call) => Future<ActionResult>.value(results[0]),
        );

    feed.add(normal);
    await pumpContribution(
      tester,
      overrides: contributionOverrides(
        repo: repo,
        actions: actions,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await typeEdited(tester);
    await tester.tap(find.byKey(const Key('m9s13-change')));
    await tester.pump();
    await tester.pump();

    feed.add(pending);
    await tester.pump();
    await tester.pump();

    expect(
      shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
      contributionSettingTexts(pending),
    );
    expect(fieldText(tester), edited);
    expect(shownTexts(tester, find.byKey(const Key('m9s13-result'))), <String?>[
      results[0].headline,
      ?results[0].reasonCode,
    ]);
    expect(actions.inputs, <String>[edited]);
    expect(repo.contributionCalls, 1);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S13-08: result then VM becomes locked → locked row + no input/button ──

  testWidgets('M9S13-08 result then locked VM locked row no input no button', (
    WidgetTester tester,
  ) async {
    expect(locked.lockedLabel, isNotNull); // pre
    expect(locked.changeLabel, isNull); // pre

    final StreamController<MonthlyContributionVm> feed =
        StreamController<MonthlyContributionVm>();
    addTearDown(feed.close);

    feed.add(normal);
    await pumpContribution(
      tester,
      overrides: contributionOverrides(
        repo: FakeSettingsContributionRepository(
          contribution: (int call) => feed.stream,
        ),
        actions: FakeSettingsContributionActions(
          result: (int call) => Future<ActionResult>.value(results[6]),
        ),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const Key('m9s13-change')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s13-locked')), findsNothing);

    feed.add(locked);
    await tester.pump();
    await tester.pump();

    expect(shownTexts(tester, find.byKey(const Key('m9s13-locked'))), <String?>[
      ?locked.lockedLabel,
    ]);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s13-result'))), <String?>[
      results[6].headline,
      ?results[6].reasonCode,
    ]);

    final List<Key> chain = <Key>[
      const Key('m9s13-locked'),
      const Key('m9s13-setting'),
      const Key('m9s13-result'),
      const Key('m9s13-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }

    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S13-09: locked = locked row + no input/button; normal = input + button

  for (final c
      in <
        ({
          String name,
          MonthlyContributionVm v,
          List<String?> lockedTexts,
          Matcher input,
          Matcher buttons,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          input: findsNothing,
          buttons: findsNothing,
          chain: <Key>[
            const Key('m9s13-locked'),
            const Key('m9s13-setting'),
            const Key('m9s13-asof'),
          ],
        ),
        (
          name: 'normal',
          v: normal,
          lockedTexts: <String?>[],
          input: findsOneWidget,
          buttons: findsOneWidget,
          chain: <Key>[
            const Key('m9s13-setting'),
            const Key('m9s13-input'),
            const Key('m9s13-change'),
            const Key('m9s13-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S13-09 locked vs normal ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(locked.changeLabel, isNull); // pre

      final FakeSettingsContributionActions actions = okActions();

      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: (int call) => one(c.v),
          ),
          actions: actions,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s13-setting')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-locked'))),
        c.lockedTexts,
      );
      expect(find.byType(TextField), c.input);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(actions.inputs, <String>[]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
        contributionSettingTexts(c.v),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-10: viewer (actions null) — no input/button, data intact ──────────

  for (final c in <({String name, MonthlyContributionVm v})>[
    (name: 'normal', v: normal),
    (name: 'pending', v: pending),
    (name: 'locked', v: locked),
  ]) {
    testWidgets('M9S13-10 viewer no input no button data intact ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsContributionRepository repo =
          FakeSettingsContributionRepository(
            contribution: (int call) => one(c.v),
          );

      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: repo,
          actions: null,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const Key('m9s13-edit')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-setting'))),
        contributionSettingTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(find.byKey(const Key('m9s13-setting')), findsOneWidget);
      expect(repo.contributionCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // ── M9S13-11: asOf line and stale banner ─────────────────────────────────────

  for (final c
      in <
        ({
          String name,
          MonthlyContributionVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: normal,
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s13-setting'), const Key('m9s13-asof')],
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
            const Key('m9s13-stale'),
            const Key('m9s13-setting'),
            const Key('m9s13-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S13-11 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: (int call) => one(c.v),
          ),
          actions: okActions(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s13-asof')), findsOneWidget);
      expect(shownTexts(tester, find.byKey(const Key('m9s13-asof'))), <String?>[
        c.v.asOf.label,
      ]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s13-stale'))),
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

  // ── M9S13-12: loading and error states ──────────────────────────────────────

  for (final c
      in <
        ({
          String name,
          Stream<MonthlyContributionVm> Function(int call) streamFactory,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          streamFactory: (int call) => Stream<MonthlyContributionVm>.multi(
            (MultiStreamController<MonthlyContributionVm> c) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          streamFactory: (int call) =>
              Stream<MonthlyContributionVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S13-12 state branch ${c.name}', (WidgetTester tester) async {
      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: c.streamFactory,
          ),
          actions: okActions(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s13-loading')), c.loading);
      expect(find.byKey(const Key('m9s13-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const Key('m9s13-setting')), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });
  }

  // ── M9S13-13: retry re-subscribes, first-seed preserved ─────────────────────

  testWidgets('M9S13-13 retry resubscribes first seed preserved', (
    WidgetTester tester,
  ) async {
    final FakeSettingsContributionRepository repo =
        FakeSettingsContributionRepository(
          contribution: (int call) => call == 0
              ? Stream<MonthlyContributionVm>.error(StateError('fail'))
              : one(normal),
        );

    await pumpContribution(
      tester,
      overrides: contributionOverrides(
        repo: repo,
        actions: okActions(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s13-fail')), findsNothing);
    expect(find.byKey(const Key('m9s13-setting')), findsOneWidget);
    expect(repo.contributionCalls, 2);
    expect(fieldText(tester), base);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // ── M9S13-14: all screen texts + large font (5 cases) ───────────────────────

  for (final c
      in <
        ({
          String name,
          MonthlyContributionVm v,
          SettingsActions? Function() actionsFactory,
          Matcher field,
          Set<String> allowed,
        })
      >[
        (
          name: 'normal_operator',
          v: normal,
          actionsFactory: okActions,
          field: findsOneWidget,
          allowed: <String>{
            ...contributionAllowed(normal),
            ...contributionControlTexts(normal),
          },
        ),
        (
          name: 'no_limit_operator',
          v: noLimit,
          actionsFactory: okActions,
          field: findsOneWidget,
          allowed: <String>{
            ...contributionAllowed(noLimit),
            ...contributionControlTexts(noLimit),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actionsFactory: okActions,
          field: findsNothing,
          allowed: <String>{
            ...contributionAllowed(locked),
            ...contributionControlTexts(locked),
          },
        ),
        (
          name: 'normal_viewer',
          v: normal,
          actionsFactory: noActions,
          field: findsNothing,
          allowed: contributionAllowed(normal),
        ),
        (
          name: 'no_record_viewer',
          v: noRecord,
          actionsFactory: noActions,
          field: findsNothing,
          allowed: contributionAllowed(noRecord),
        ),
      ]) {
    testWidgets('M9S13-14 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpContribution(
        tester,
        overrides: contributionOverrides(
          repo: FakeSettingsContributionRepository(
            contribution: (int call) => one(c.v),
          ),
          actions: c.actionsFactory(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byType(EditableText), c.field);

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
