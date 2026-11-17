// test/credentials_test.dart
//
// M9 S02 -- Credentials widget tests (39 tests).
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
    Theme.of(tester.element(find.byType(Credentials))).colorScheme;

void main() {
  final CredentialListVm live = singleFixture(
    FixturePaths.m9Credentials,
    CredentialListVm.fromJson,
  );
  final CredentialListVm simSealed = singleFixture(
    FixturePaths.m9CredentialsSimSealed,
    CredentialListVm.fromJson,
  );
  final CredentialListVm advisory = singleFixture(
    FixturePaths.m9CredentialsAdvisory,
    CredentialListVm.fromJson,
  );
  final CredentialListVm locked = singleFixture(
    FixturePaths.m9CredentialsLocked,
    CredentialListVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9CredentialActionResults,
    ActionResult.fromJson,
  ).rows;
  final SettingsActionCall verifyLive = live.cards[0].verifyAction!;
  final SettingsActionCall verifyIsa = live.cards[1].verifyAction!;
  final SettingsActionCall verifyPaper = live.cards[2].verifyAction!;
  final LinkAction rotate = live.cards[1].rotateLink!;
  final LinkAction runbook = live.leakRunbookLink!;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );
  SettingsActions? noActions() => null;
  SettingsSlotBuilder? recordSlots() => FakeSettingsSlotRecorder().build;
  SettingsSlotBuilder? noSlots() => null;

  // -- M9S02-01 card order and texts ------------------------------------------

  testWidgets('M9S02-01 card order and texts', (WidgetTester tester) async {
    final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

    await pumpCredentials(
      tester,
      overrides: credentialsOverrides(
        repo: FakeSettingsCredentialsRepository(
          credentials: (int call) => one(live),
        ),
        actions: okActions(),
        slots: slots.build,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(live.cards, hasLength(3));
    for (final (int i, CredentialCardVm k) in live.cards.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s02-card-$i'))),
        credentialOperatorTexts(k),
      );
    }
    expect(
      shownTexts(tester, find.byKey(const Key('m9s02-runbook'))),
      <String?>[?live.leakRunbookLink?.label],
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s02-asof'))), <String?>[
      live.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const ValueKey<String>('m9s02-card-0'),
      const ValueKey<String>('m9s02-card-1'),
      const ValueKey<String>('m9s02-card-2'),
      const Key('m9s02-runbook'),
      const Key('m9s02-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }
    expect(find.byKey(const ValueKey<String>('m9s02-card-3')), findsNothing);
    expect(slots.slotIds, credentialSlotIds(live));
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(3),
    );
    expect(find.byKey(const Key('m9s02-stale')), findsNothing);
    expect(find.byKey(const Key('m9s02-locked')), findsNothing);
    expect(find.byKey(const Key('m9s02-result')), findsNothing);
    expect(find.byKey(const Key('m9s02-not-accepted')), findsNothing);
    expect(find.byKey(const Key('m9s02-notice')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // -- M9S02-02 block texts four cases ----------------------------------------

  for (final c in <({String name, CredentialListVm v, Matcher buttons})>[
    (name: 'live', v: live, buttons: findsNWidgets(3)),
    (name: 'sim_sealed', v: simSealed, buttons: findsNWidgets(1)),
    (name: 'advisory', v: advisory, buttons: findsNWidgets(3)),
    (name: 'locked', v: locked, buttons: findsNothing),
  ]) {
    testWidgets('M9S02-02 block texts ${c.name}', (WidgetTester tester) async {
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: slots.build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s02-card-0')),
        findsOneWidget,
      );
      for (final (int i, CredentialCardVm k) in c.v.cards.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s02-card-$i'))),
          credentialOperatorTexts(k),
        );
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-notice'))),
        <String?>[?c.v.modeNotice],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-runbook'))),
        <String?>[?c.v.leakRunbookLink?.label],
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(slots.slotIds, credentialSlotIds(c.v));
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-03 level to icon and color three cases ---------------------------

  for (final c in <({String name, CredentialListVm v})>[
    (name: 'live', v: live),
    (name: 'sim_sealed', v: simSealed),
    (name: 'advisory', v: advisory),
  ]) {
    testWidgets('M9S02-03 level icon color ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        <UiLevel>{for (final CredentialCardVm k in c.v.cards) k.level}.length,
        greaterThan(1),
      ); // pre

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final ColorScheme cs = colorsOf(tester);
      for (final (int i, CredentialCardVm k) in c.v.cards.indexed) {
        final Icon ic = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s02-level-$i')),
        );
        expect(ic.icon, wantLevel(cs, k.level).$1);
        expect(ic.color, wantLevel(cs, k.level).$2);
      }
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-04 verify runs once and shows the result six cases ---------------

  for (final c
      in <({String name, Key tap, SettingsActionCall call, ActionResult r})>[
        (
          name: 'saved',
          tap: const ValueKey<String>('m9s02-verify-2'),
          call: verifyPaper,
          r: results[0],
        ),
        (
          name: 'same',
          tap: const ValueKey<String>('m9s02-verify-0'),
          call: verifyLive,
          r: results[1],
        ),
        (
          name: 'expiring',
          tap: const ValueKey<String>('m9s02-verify-1'),
          call: verifyIsa,
          r: results[2],
        ),
        (
          name: 'wrong_set',
          tap: const ValueKey<String>('m9s02-verify-2'),
          call: verifyPaper,
          r: results[3],
        ),
        (
          name: 'rejected',
          tap: const ValueKey<String>('m9s02-verify-2'),
          call: verifyPaper,
          r: results[4],
        ),
        (
          name: 'bio',
          tap: const ValueKey<String>('m9s02-verify-0'),
          call: verifyLive,
          r: results[5],
        ),
      ]) {
    testWidgets('M9S02-04 verify run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsCredentialsRepository repo =
          FakeSettingsCredentialsRepository(
            credentials: (int call) => one(live),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: repo,
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
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
        shownTexts(tester, find.byKey(const Key('m9s02-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s02-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s02-result'))).dy,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('m9s02-card-0')))
              .dy,
        ),
      );
      expect(opener.opened, <String>[]);
      expect(actions.watchCalls, 0);
      expect(repo.credentialsCalls, 1);
      expect(find.byKey(c.tap), findsOneWidget);
      expect(find.byKey(const Key('m9s02-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-05 fail and ok both directions -----------------------------------

  for (final c
      in <
        ({
          String name,
          Future<ActionResult> Function(int call) result,
          List<String?> firstNa,
          List<String?> firstRes,
          List<String?> secondNa,
          List<String?> secondRes,
        })
      >[
        (
          name: 'fail_then_ok',
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline],
        ),
        (
          name: 'ok_then_fail',
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S02-05 two directions ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(result: c.result);

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(live),
          ),
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      const Key tap = ValueKey<String>('m9s02-verify-2');
      await tester.tap(find.byKey(tap));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-result'))),
        c.firstRes,
      );

      await tester.tap(find.byKey(tap));
      await tester.pump();
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-result'))),
        c.secondRes,
      );
      expect(actions.ids, <SettingsActionId>[verifyPaper.id, verifyPaper.id]);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-06 no double tap while waiting, per button -----------------------
  // Runbook and rotate links both open while waiting (C4r7a-1, C4U-4).

  for (final c in <({String name, Key tap, List<SettingsActionId> want})>[
    (
      name: 'live_card',
      tap: const ValueKey<String>('m9s02-verify-0'),
      want: <SettingsActionId>[verifyLive.id],
    ),
    (
      name: 'isa_card',
      tap: const ValueKey<String>('m9s02-verify-1'),
      want: <SettingsActionId>[verifyIsa.id],
    ),
    (
      name: 'paper_card',
      tap: const ValueKey<String>('m9s02-verify-2'),
      want: <SettingsActionId>[verifyPaper.id],
    ),
  ]) {
    testWidgets('M9S02-06 no double tap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Completer<ActionResult>().future,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(live),
          ),
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.tap(find.byKey(c.tap));
      await tester.pump();
      await tester.tap(find.byKey(const Key('m9s02-runbook')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('m9s02-rotate-1')));
      await tester.pump();

      expect(actions.ids, c.want);
      expect(opener.opened, <String>[runbook.deepLink, rotate.deepLink]);
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
      expect(find.byKey(const Key('m9s02-result')), findsNothing);
      expect(find.byKey(const Key('m9s02-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-07 links open once, run 0 ----------------------------------------

  for (final c in <({String name, Key tap, LinkAction link})>[
    (
      name: 'rotate',
      tap: const ValueKey<String>('m9s02-rotate-1'),
      link: rotate,
    ),
    (name: 'runbook', tap: const Key('m9s02-runbook'), link: runbook),
  ]) {
    testWidgets('M9S02-07 link open ${c.name}', (WidgetTester tester) async {
      final FakeSettingsCredentialsRepository repo =
          FakeSettingsCredentialsRepository(
            credentials: (int call) => one(live),
          );
      final FakeSettingsActions actions = okActions();
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: repo,
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(c.tap));
      await tester.pump();

      expect(opener.opened, <String>[c.link.deepLink]);
      expect(actions.ids, <SettingsActionId>[]);
      expect(find.byKey(const Key('m9s02-result')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-08 viewer: no buttons, no slots, same data -----------------------

  for (final c in <({String name, CredentialListVm v})>[
    (name: 'live', v: live),
    (name: 'sim_sealed', v: simSealed),
    (name: 'advisory', v: advisory),
  ]) {
    testWidgets('M9S02-08 viewer ${c.name}', (WidgetTester tester) async {
      final FakeSettingsCredentialsRepository repo =
          FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          );

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: repo,
          actions: null,
          slots: null,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      for (final (int i, CredentialCardVm k) in c.v.cards.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s02-card-$i'))),
          credentialViewerTexts(k),
        );
        expect(find.byKey(ValueKey<String>('m9s02-slot-$i')), findsNothing);
        expect(find.byKey(ValueKey<String>('m9s02-verify-$i')), findsNothing);
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-notice'))),
        <String?>[?c.v.modeNotice],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-runbook'))),
        <String?>[?c.v.leakRunbookLink?.label],
      );
      expect(
        find.byKey(const ValueKey<String>('m9s02-card-0')),
        findsOneWidget,
      );
      expect(repo.credentialsCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-09 slot place gets the received name; null builder = absent ------

  for (final c
      in <
        ({
          String name,
          CredentialListVm v,
          SettingsSlotBuilder? Function(FakeSettingsSlotRecorder s) builder,
          Matcher paperSlot,
          List<String> slotIds,
        })
      >[
        (
          name: 'slot',
          v: live,
          builder: (FakeSettingsSlotRecorder s) => s.build,
          paperSlot: findsOneWidget,
          slotIds: credentialSlotIds(live),
        ),
        (
          name: 'no_builder',
          v: live,
          builder: (FakeSettingsSlotRecorder s) => null,
          paperSlot: findsNothing,
          slotIds: <String>[],
        ),
        (
          name: 'advisory',
          v: advisory,
          builder: (FakeSettingsSlotRecorder s) => s.build,
          paperSlot: findsNothing,
          slotIds: credentialSlotIds(advisory),
        ),
      ]) {
    testWidgets('M9S02-09 slot place ${c.name}', (WidgetTester tester) async {
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: c.builder(slots),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(slots.slotIds, c.slotIds);
      for (final String id in c.slotIds) {
        expect(find.byKey(ValueKey<String>('fake-slot-$id')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey<String>('m9s02-slot-2')), c.paperSlot);
      expect(
        find.byKey(const ValueKey<String>('m9s02-verify-2')),
        findsOneWidget,
      );
      expect(find.byType(EditableText), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-10 locked line plus received as-is two cases ---------------------

  for (final c
      in <
        ({
          String name,
          CredentialListVm v,
          List<String?> lockedTexts,
          Matcher buttons,
          List<Key> chain,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          buttons: findsNothing,
          chain: <Key>[
            const Key('m9s02-locked'),
            const ValueKey<String>('m9s02-card-0'),
            const Key('m9s02-runbook'),
            const Key('m9s02-asof'),
          ],
        ),
        (
          name: 'normal',
          v: live,
          lockedTexts: <String?>[],
          buttons: findsNWidgets(3),
          chain: <Key>[
            const ValueKey<String>('m9s02-card-0'),
            const Key('m9s02-runbook'),
            const Key('m9s02-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S02-10 locked ${c.name}', (WidgetTester tester) async {
      expect(locked.lockedLabel, isNotNull); // pre
      expect(c.v.leakRunbookLink, isNotNull); // pre

      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('m9s02-card-0')),
        findsOneWidget,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-locked'))),
        c.lockedTexts,
      );
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
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-runbook'))),
        <String?>[?c.v.leakRunbookLink?.label],
      );
      // Runbook link kept while locked opens once (K35, C4r7a-2, C4U-5).
      await tester.tap(find.byKey(const Key('m9s02-runbook')));
      await tester.pump();
      expect(opener.opened, <String>[?c.v.leakRunbookLink?.deepLink]);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // Locked line stays if the VM locks after a result (C4r7b-5, C4r7c-6).
  testWidgets('M9S02-10 locked after_result', (WidgetTester tester) async {
    expect(locked.lockedLabel, isNotNull); // pre

    final StreamController<CredentialListVm> feed =
        StreamController<CredentialListVm>();
    addTearDown(feed.close);
    final FakeSettingsCredentialsRepository repo =
        FakeSettingsCredentialsRepository(
          credentials: (int call) => feed.stream,
        );
    feed.add(live);

    await pumpCredentials(
      tester,
      overrides: credentialsOverrides(
        repo: repo,
        actions: okActions(),
        slots: FakeSettingsSlotRecorder().build,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('m9s02-verify-2')));
    await tester.pump();
    await tester.pump();
    expect(shownTexts(tester, find.byKey(const Key('m9s02-result'))), <String?>[
      results[0].headline,
      ?results[0].reasonCode,
    ]);
    expect(find.byKey(const Key('m9s02-locked')), findsNothing);

    feed.add(locked);
    await tester.pump();
    await tester.pump();

    expect(shownTexts(tester, find.byKey(const Key('m9s02-locked'))), <String?>[
      ?locked.lockedLabel,
    ]);
    expect(shownTexts(tester, find.byKey(const Key('m9s02-result'))), <String?>[
      results[0].headline,
      ?results[0].reasonCode,
    ]);
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNothing,
    );
    final List<Key> chain = <Key>[
      const Key('m9s02-locked'),
      const Key('m9s02-result'),
      const ValueKey<String>('m9s02-card-0'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }
    expect(repo.credentialsCalls, 1);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // -- M9S02-11 asOf line and stale banner two cases --------------------------

  for (final c
      in <
        ({String name, Clock clock, List<String?> staleTexts, List<Key> chain})
      >[
        (
          name: 'fresh',
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[
            const ValueKey<String>('m9s02-card-0'),
            const Key('m9s02-asof'),
          ],
        ),
        (
          name: 'stale',
          clock: FixedClock(
            live.asOf.observedAt
                .add(live.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?live.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s02-stale'),
            const ValueKey<String>('m9s02-card-0'),
            const Key('m9s02-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S02-11 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(live),
          ),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s02-asof')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s02-stale'))),
        c.staleTexts,
      );
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }

  // -- M9S02-12 state branches two cases --------------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<CredentialListVm> Function(int call) stream,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          stream: (int call) => Stream<CredentialListVm>.multi(
            (MultiStreamController<CredentialListVm> c) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          stream: (int call) =>
              Stream<CredentialListVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S02-12 state branch ${c.name}', (WidgetTester tester) async {
      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(credentials: c.stream),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s02-loading')), c.loading);
      expect(find.byKey(const Key('m9s02-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const ValueKey<String>('m9s02-card-0')), findsNothing);
    });
  }

  // -- M9S02-13 retry ---------------------------------------------------------

  testWidgets('M9S02-13 retry invalidate', (WidgetTester tester) async {
    final FakeSettingsCredentialsRepository repo =
        FakeSettingsCredentialsRepository(
          credentials: (int call) => call == 0
              ? Stream<CredentialListVm>.error(StateError('fail'))
              : one(live),
        );

    await pumpCredentials(
      tester,
      overrides: credentialsOverrides(
        repo: repo,
        actions: okActions(),
        slots: FakeSettingsSlotRecorder().build,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    await tester.tap(find.text(SettingsLabels.retry));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('m9s02-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s02-card-0')), findsOneWidget);
    expect(repo.credentialsCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
  });

  // -- M9S02-14 all screen texts large font five cases ------------------------

  for (final c
      in <
        ({
          String name,
          CredentialListVm v,
          SettingsActions? Function() actions,
          SettingsSlotBuilder? Function() slots,
          Set<String> allowed,
        })
      >[
        (
          name: 'live_operator',
          v: live,
          actions: okActions,
          slots: recordSlots,
          allowed: <String>{
            ...credentialsAllowed(live),
            ...credentialsControlTexts(live),
          },
        ),
        (
          name: 'sim_sealed_operator',
          v: simSealed,
          actions: okActions,
          slots: recordSlots,
          allowed: <String>{
            ...credentialsAllowed(simSealed),
            ...credentialsControlTexts(simSealed),
          },
        ),
        (
          name: 'advisory_operator',
          v: advisory,
          actions: okActions,
          slots: recordSlots,
          allowed: <String>{
            ...credentialsAllowed(advisory),
            ...credentialsControlTexts(advisory),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actions: okActions,
          slots: recordSlots,
          allowed: <String>{
            ...credentialsAllowed(locked),
            ...credentialsControlTexts(locked),
          },
        ),
        (
          name: 'live_viewer',
          v: live,
          actions: noActions,
          slots: noSlots,
          allowed: credentialsAllowed(live),
        ),
      ]) {
    testWidgets('M9S02-14 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpCredentials(
        tester,
        overrides: credentialsOverrides(
          repo: FakeSettingsCredentialsRepository(
            credentials: (int call) => one(c.v),
          ),
          actions: c.actions(),
          slots: c.slots(),
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
      expect(find.byType(EditableText), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.text(SettingsLabels.retry), findsNothing); // ⓡ
    });
  }
}
