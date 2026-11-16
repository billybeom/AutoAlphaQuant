// test/devices_test.dart
//
// M9 S06 -- Devices widget tests (42 tests).
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
    Theme.of(tester.element(find.byType(Devices))).colorScheme;

void main() {
  final DeviceAccessVm access = singleFixture(
    FixturePaths.m9DeviceAccess,
    DeviceAccessVm.fromJson,
  );
  final DeviceAccessVm ticket = singleFixture(
    FixturePaths.m9DeviceAccessTicket,
    DeviceAccessVm.fromJson,
  );
  final DeviceAccessVm noViewers = singleFixture(
    FixturePaths.m9DeviceAccessNoViewers,
    DeviceAccessVm.fromJson,
  );
  final DeviceAccessVm staleAccess = singleFixture(
    FixturePaths.m9DeviceAccessStale,
    DeviceAccessVm.fromJson,
  );
  final DeviceAccessVm locked = singleFixture(
    FixturePaths.m9DeviceAccessLocked,
    DeviceAccessVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m9DeviceActionResults,
    ActionResult.fromJson,
  ).rows;
  final SettingsActionCall issue = access.pairing!.issueAction!;
  final SettingsActionCall revokeTablet = access.devices[1].revokeAction!;
  final SettingsActionCall revokeLaptop = access.devices[2].revokeAction!;
  final LinkAction migration = access.migrationLink!;

  FakeSettingsActions okActions() => FakeSettingsActions(
    result: (int call) => Future<ActionResult>.value(results[0]),
  );
  SettingsActions? noActions() => null;
  SettingsSlotBuilder? recordSlots() => FakeSettingsSlotRecorder().build;
  SettingsSlotBuilder? noSlots() => null;
  Future<void> noSteps(WidgetTester t) async {}
  Future<void> openTablet(WidgetTester t) async {
    await t.tap(find.byKey(const ValueKey<String>('m9s06-revoke-1')));
    await t.pump();
  }

  // -- M9S06-01 block order and texts -----------------------------------------

  testWidgets('M9S06-01 block order and texts', (WidgetTester tester) async {
    final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

    await pumpDevices(
      tester,
      overrides: devicesOverrides(
        repo: FakeSettingsDeviceAccessRepository(
          devices: (int call) => one(access),
        ),
        actions: okActions(),
        slots: slots.build,
        opener: RecordingLinkOpener(),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );

    expect(
      shownTexts(tester, find.byKey(const Key('m9s06-pairing'))),
      pairingOperatorTexts(access),
    );
    expect(access.devices, hasLength(4));
    for (final (int i, DeviceRow d) in access.devices.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('m9s06-row-$i'))),
        deviceOperatorTexts(d),
      );
    }
    expect(
      shownTexts(tester, find.byKey(const Key('m9s06-lease'))),
      leaseTexts(access),
    );
    expect(
      shownTexts(tester, find.byKey(const Key('m9s06-migration'))),
      <String?>[?access.migrationLink?.label],
    );
    expect(shownTexts(tester, find.byKey(const Key('m9s06-asof'))), <String?>[
      access.asOf.label,
    ]);

    final List<Key> chain = <Key>[
      const Key('m9s06-pairing'),
      const ValueKey<String>('m9s06-row-0'),
      const ValueKey<String>('m9s06-row-1'),
      const ValueKey<String>('m9s06-row-2'),
      const ValueKey<String>('m9s06-row-3'),
      const Key('m9s06-lease'),
      const Key('m9s06-migration'),
      const Key('m9s06-asof'),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(find.byKey(chain[i - 1])).dy,
        lessThan(tester.getTopLeft(find.byKey(chain[i])).dy),
      );
    }
    expect(find.byKey(const ValueKey<String>('m9s06-row-4')), findsNothing);
    expect(slots.slotIds, pairingSlotIds(access));
    expect(
      find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
      findsNWidgets(3),
    );
    expect(find.byKey(const Key('m9s06-stale')), findsNothing);
    expect(find.byKey(const Key('m9s06-locked')), findsNothing);
    expect(find.byKey(const Key('m9s06-result')), findsNothing);
    expect(find.byKey(const Key('m9s06-not-accepted')), findsNothing);
    expect(find.byKey(const Key('m9s06-empty')), findsNothing);
    expect(find.byKey(const Key('m9s06-qr')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s06-confirm-1')), findsNothing);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S06-02 block texts four cases ----------------------------------------

  for (final c in <({String name, DeviceAccessVm v, Matcher buttons})>[
    (name: 'access', v: access, buttons: findsNWidgets(3)),
    (name: 'ticket', v: ticket, buttons: findsNWidgets(2)),
    (name: 'no_viewers', v: noViewers, buttons: findsNWidgets(1)),
    (name: 'locked', v: locked, buttons: findsNothing),
  ]) {
    testWidgets('M9S06-02 block texts ${c.name}', (WidgetTester tester) async {
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: slots.build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const ValueKey<String>('m9s06-row-0')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-pairing'))),
        pairingOperatorTexts(c.v),
      );
      for (final (int i, DeviceRow d) in c.v.devices.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s06-row-$i'))),
          deviceOperatorTexts(d),
        );
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-lease'))),
        leaseTexts(c.v),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-empty'))),
        <String?>[?c.v.emptyLabel],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-locked'))),
        <String?>[?c.v.lockedLabel],
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-migration'))),
        <String?>[?c.v.migrationLink?.label],
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(slots.slotIds, pairingSlotIds(c.v));
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-03 level to icon and color two cases -----------------------------

  for (final c in <({String name, DeviceAccessVm v})>[
    (name: 'access', v: access),
    (name: 'no_viewers', v: noViewers),
  ]) {
    testWidgets('M9S06-03 level icon color ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(
        <UiLevel>{
          for (final DeviceRow d in c.v.devices) d.level,
          c.v.leaseLevel,
        }.length,
        greaterThan(1),
      ); // pre

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      final ColorScheme cs = colorsOf(tester);
      for (final (int i, DeviceRow d) in c.v.devices.indexed) {
        final Icon ic = tester.widget<Icon>(
          find.byKey(ValueKey<String>('m9s06-level-$i')),
        );
        expect(ic.icon, wantLevel(cs, d.level).$1);
        expect(ic.color, wantLevel(cs, d.level).$2);
      }
      final Icon lease = tester.widget<Icon>(
        find.byKey(const Key('m9s06-lease-level')),
      );
      expect(lease.icon, wantLevel(cs, c.v.leaseLevel).$1);
      expect(lease.color, wantLevel(cs, c.v.leaseLevel).$2);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-04 issue runs once and shows the result three cases --------------

  for (final c in <({String name, ActionResult r})>[
    (name: 'issued', r: results[0]),
    (name: 'net_fail', r: results[1]),
    (name: 'bio', r: results[2]),
  ]) {
    testWidgets('M9S06-04 issue run result ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsDeviceAccessRepository repo =
          FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(access),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: repo,
          actions: actions,
          slots: slots.build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(const Key('m9s06-issue')));
      await tester.pump();
      await tester.pump();

      expect(actions.ids, <SettingsActionId>[issue.id]);
      expect(actions.argsSeen, <Map<String, String>>[issue.args]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s06-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(
        tester.getTopLeft(find.byKey(const Key('m9s06-result'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('m9s06-pairing'))).dy),
      );
      expect(opener.opened, <String>[]);
      expect(actions.watchCalls, 0);
      expect(repo.devicesCalls, 1);
      expect(find.byKey(const Key('m9s06-issue')), findsOneWidget);
      expect(find.byKey(const Key('m9s06-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-05 revoke expands then confirm runs once and collapses -----------

  for (final c
      in <({String name, int row, SettingsActionCall call, ActionResult r})>[
        (name: 'tablet', row: 1, call: revokeTablet, r: results[3]),
        (name: 'laptop', row: 2, call: revokeLaptop, r: results[4]),
        (name: 'already', row: 1, call: revokeTablet, r: results[5]),
      ]) {
    testWidgets('M9S06-05 revoke confirm run ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.r.handoffRoute, isNull); // pre

      final FakeSettingsDeviceAccessRepository repo =
          FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(access),
          );
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Future<ActionResult>.value(c.r),
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: repo,
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      await tester.tap(find.byKey(ValueKey<String>('m9s06-revoke-${c.row}')));
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        shownTexts(
          tester,
          find.byKey(ValueKey<String>('m9s06-confirm-${c.row}')),
        ),
        deviceConfirmTexts(access.devices[c.row]),
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNWidgets(5),
      );
      await tester.tap(
        find.byKey(ValueKey<String>('m9s06-confirm-yes-${c.row}')),
      );
      await tester.pump();
      await tester.pump();
      expect(actions.ids, <SettingsActionId>[c.call.id]);
      expect(actions.argsSeen, <Map<String, String>>[c.call.args]);
      expect(
        find.byKey(ValueKey<String>('m9s06-confirm-${c.row}')),
        findsNothing,
      );

      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-result'))),
        <String?>[c.r.headline, ?c.r.reasonCode],
      );
      final ColorScheme cs = colorsOf(tester);
      final Icon ic = tester.widget<Icon>(
        find.byKey(const Key('m9s06-result-level')),
      );
      expect(ic.icon, wantLevel(cs, c.r.level).$1);
      expect(ic.color, wantLevel(cs, c.r.level).$2);
      expect(opener.opened, <String>[]);
      expect(actions.watchCalls, 0);
      expect(repo.devicesCalls, 1);
      expect(
        find.byKey(ValueKey<String>('m9s06-revoke-${c.row}')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('m9s06-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-06 expand one row only and cancel collapses three cases ----------

  for (final c
      in <
        ({
          String name,
          List<Key> taps,
          Matcher tablet,
          Matcher laptop,
          Matcher buttons,
        })
      >[
        (
          name: 'cancel',
          taps: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-confirm-no-1'),
          ],
          tablet: findsNothing,
          laptop: findsNothing,
          buttons: findsNWidgets(3),
        ),
        (
          name: 'other_row',
          taps: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-revoke-2'),
          ],
          tablet: findsNothing,
          laptop: findsOneWidget,
          buttons: findsNWidgets(5),
        ),
        (
          name: 'same_row',
          taps: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-revoke-1'),
          ],
          tablet: findsOneWidget,
          laptop: findsNothing,
          buttons: findsNWidgets(5),
        ),
      ]) {
    testWidgets('M9S06-06 expand collapse ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = okActions();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(access),
          ),
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.taps) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }

      expect(find.byKey(const ValueKey<String>('m9s06-confirm-1')), c.tablet);
      expect(find.byKey(const ValueKey<String>('m9s06-confirm-2')), c.laptop);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        find.byKey(const ValueKey<String>('m9s06-revoke-1')),
        findsOneWidget,
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-07 fail and ok both directions on both paths ---------------------

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
          name: 'issue_fail_then_ok',
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[0]),
          press: <Key>[const Key('m9s06-issue')],
          call: issue,
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[0].headline],
        ),
        (
          name: 'issue_ok_then_fail',
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[0])
              : Future<ActionResult>.error(StateError('fail')),
          press: <Key>[const Key('m9s06-issue')],
          call: issue,
          firstNa: <String?>[],
          firstRes: <String?>[results[0].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
        (
          name: 'revoke_fail_then_ok',
          result: (int call) => call == 0
              ? Future<ActionResult>.error(StateError('fail'))
              : Future<ActionResult>.value(results[3]),
          press: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-confirm-yes-1'),
          ],
          call: revokeTablet,
          firstNa: <String?>[SettingsLabels.notAccepted],
          firstRes: <String?>[],
          secondNa: <String?>[],
          secondRes: <String?>[results[3].headline],
        ),
        (
          name: 'revoke_ok_then_fail',
          result: (int call) => call == 0
              ? Future<ActionResult>.value(results[3])
              : Future<ActionResult>.error(StateError('fail')),
          press: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-confirm-yes-1'),
          ],
          call: revokeTablet,
          firstNa: <String?>[],
          firstRes: <String?>[results[3].headline],
          secondNa: <String?>[SettingsLabels.notAccepted],
          secondRes: <String?>[],
        ),
      ]) {
    testWidgets('M9S06-07 two directions ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(result: c.result);

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(access),
          ),
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.press) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-not-accepted'))),
        c.firstNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-result'))),
        c.firstRes,
      );
      expect(
        find.byKey(const ValueKey<String>('m9s06-confirm-1')),
        findsNothing,
      );

      for (final Key k in c.press) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.pump();
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-not-accepted'))),
        c.secondNa,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-result'))),
        c.secondRes,
      );
      expect(actions.ids, <SettingsActionId>[c.call.id, c.call.id]);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-08 no double tap while waiting, links still open -----------------

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
          name: 'issue',
          first: <Key>[const Key('m9s06-issue')],
          again: const Key('m9s06-issue'),
          want: <SettingsActionId>[issue.id],
          block: const ValueKey<String>('m9s06-confirm-1'),
          open: findsNothing,
        ),
        (
          name: 'tablet',
          first: <Key>[
            const ValueKey<String>('m9s06-revoke-1'),
            const ValueKey<String>('m9s06-confirm-yes-1'),
          ],
          again: const ValueKey<String>('m9s06-confirm-yes-1'),
          want: <SettingsActionId>[revokeTablet.id],
          block: const ValueKey<String>('m9s06-confirm-1'),
          open: findsOneWidget,
        ),
        (
          name: 'laptop',
          first: <Key>[
            const ValueKey<String>('m9s06-revoke-2'),
            const ValueKey<String>('m9s06-confirm-yes-2'),
          ],
          again: const ValueKey<String>('m9s06-confirm-yes-2'),
          want: <SettingsActionId>[revokeLaptop.id],
          block: const ValueKey<String>('m9s06-confirm-2'),
          open: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S06-08 no double tap ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeSettingsActions actions = FakeSettingsActions(
        result: (int call) => Completer<ActionResult>().future,
      );
      final RecordingLinkOpener opener = RecordingLinkOpener();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(access),
          ),
          actions: actions,
          slots: FakeSettingsSlotRecorder().build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      for (final Key k in c.first) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      await tester.tap(find.byKey(c.again));
      await tester.pump();
      await tester.tap(find.byKey(const Key('m9s06-migration')));
      await tester.pump();

      expect(actions.ids, c.want);
      expect(opener.opened, <String>[migration.deepLink]);
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
      expect(find.byKey(const Key('m9s06-result')), findsNothing);
      expect(find.byKey(const Key('m9s06-not-accepted')), findsNothing);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-09 viewer: no buttons, no qr slot, same data ---------------------

  for (final c in <({String name, DeviceAccessVm v})>[
    (name: 'access', v: access),
    (name: 'ticket', v: ticket),
    (name: 'no_viewers', v: noViewers),
  ]) {
    testWidgets('M9S06-09 viewer ${c.name}', (WidgetTester tester) async {
      final FakeSettingsDeviceAccessRepository repo =
          FakeSettingsDeviceAccessRepository(devices: (int call) => one(c.v));

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
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
      for (final (int i, DeviceRow d) in c.v.devices.indexed) {
        expect(
          shownTexts(tester, find.byKey(ValueKey<String>('m9s06-row-$i'))),
          deviceViewerTexts(d),
        );
        expect(find.byKey(ValueKey<String>('m9s06-revoke-$i')), findsNothing);
      }
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-pairing'))),
        pairingViewerTexts(c.v),
      );
      expect(find.byKey(const Key('m9s06-issue')), findsNothing);
      expect(find.byKey(const Key('m9s06-qr')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-migration'))),
        <String?>[?c.v.migrationLink?.label],
      );
      expect(find.byKey(const ValueKey<String>('m9s06-row-0')), findsOneWidget);
      expect(repo.devicesCalls, 1);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-10 qr slot gets the received name; null builder = absent ---------

  for (final c
      in <
        ({
          String name,
          DeviceAccessVm v,
          SettingsSlotBuilder? Function(FakeSettingsSlotRecorder s) builder,
          Matcher qr,
          List<String> slotIds,
        })
      >[
        (
          name: 'ticket',
          v: ticket,
          builder: (FakeSettingsSlotRecorder s) => s.build,
          qr: findsOneWidget,
          slotIds: pairingSlotIds(ticket),
        ),
        (
          name: 'no_builder',
          v: ticket,
          builder: (FakeSettingsSlotRecorder s) => null,
          qr: findsNothing,
          slotIds: <String>[],
        ),
        (
          name: 'no_ticket',
          v: access,
          builder: (FakeSettingsSlotRecorder s) => s.build,
          qr: findsNothing,
          slotIds: pairingSlotIds(access),
        ),
      ]) {
    testWidgets('M9S06-10 qr slot ${c.name}', (WidgetTester tester) async {
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(c.v),
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
      expect(find.byKey(const Key('m9s06-qr')), c.qr);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-pairing'))),
        pairingOperatorTexts(c.v),
      );
      expect(find.byType(EditableText), findsNothing);
      expect(find.byKey(const Key('m9s06-pairing')), findsOneWidget);
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-11 locked line and received-as-is, link tap ----------------------

  for (final c
      in <
        ({
          String name,
          DeviceAccessVm v,
          List<String?> lockedTexts,
          Matcher buttons,
          Matcher migration,
          List<Key> chain,
          List<Key> links,
          List<String> opened,
        })
      >[
        (
          name: 'locked',
          v: locked,
          lockedTexts: <String?>[?locked.lockedLabel],
          buttons: findsNothing,
          migration: findsNothing,
          chain: <Key>[
            const Key('m9s06-locked'),
            const Key('m9s06-pairing'),
            const ValueKey<String>('m9s06-row-0'),
            const Key('m9s06-lease'),
            const Key('m9s06-asof'),
          ],
          links: <Key>[],
          opened: <String>[],
        ),
        (
          name: 'normal',
          v: access,
          lockedTexts: <String?>[],
          buttons: findsNWidgets(3),
          migration: findsOneWidget,
          chain: <Key>[
            const Key('m9s06-pairing'),
            const ValueKey<String>('m9s06-row-0'),
            const Key('m9s06-lease'),
            const Key('m9s06-migration'),
            const Key('m9s06-asof'),
          ],
          links: <Key>[const Key('m9s06-migration')],
          opened: <String>[migration.deepLink],
        ),
      ]) {
    testWidgets('M9S06-11 locked ${c.name}', (WidgetTester tester) async {
      expect(locked.lockedLabel, isNotNull); // pre

      final FakeSettingsDeviceAccessRepository repo =
          FakeSettingsDeviceAccessRepository(devices: (int call) => one(c.v));
      final FakeSettingsActions actions = okActions();
      final RecordingLinkOpener opener = RecordingLinkOpener();
      final FakeSettingsSlotRecorder slots = FakeSettingsSlotRecorder();

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: repo,
          actions: actions,
          slots: slots.build,
          opener: opener,
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const ValueKey<String>('m9s06-row-0')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-locked'))),
        c.lockedTexts,
      );
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        c.buttons,
      );
      expect(find.byKey(const Key('m9s06-migration')), c.migration);
      for (int i = 1; i < c.chain.length; i++) {
        expect(
          tester.getTopLeft(find.byKey(c.chain[i - 1])).dy,
          lessThan(tester.getTopLeft(find.byKey(c.chain[i])).dy),
        );
      }
      for (final Key k in c.links) {
        await tester.tap(find.byKey(k));
        await tester.pump();
      }
      expect(opener.opened, c.opened);
      expect(actions.ids, <SettingsActionId>[]);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-pairing'))),
        pairingOperatorTexts(c.v),
      );
      expect(find.text(SettingsLabels.retry), findsNothing);
    });
  }

  // -- M9S06-12 asOf line and stale banner two cases --------------------------

  for (final c
      in <
        ({
          String name,
          DeviceAccessVm v,
          Clock clock,
          List<String?> staleTexts,
          List<Key> chain,
        })
      >[
        (
          name: 'fresh',
          v: access,
          clock: FixedClock(kGoldenNowUtc),
          staleTexts: <String?>[],
          chain: <Key>[const Key('m9s06-pairing'), const Key('m9s06-asof')],
        ),
        (
          name: 'stale',
          v: staleAccess,
          clock: FixedClock(
            staleAccess.asOf.observedAt
                .add(staleAccess.asOf.staleAfter)
                .add(const Duration(seconds: 1)),
          ),
          staleTexts: <String?>[
            SettingsLabels.staleBannerTitle,
            ?staleAccess.asOf.staleLabel,
          ],
          chain: <Key>[
            const Key('m9s06-stale'),
            const Key('m9s06-pairing'),
            const Key('m9s06-asof'),
          ],
        ),
      ]) {
    testWidgets('M9S06-12 asof stale ${c.name}', (WidgetTester tester) async {
      expect(staleAccess.asOf.staleLabel, isNotNull); // pre

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(c.v),
          ),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: c.clock,
        ),
      );

      expect(find.byKey(const Key('m9s06-asof')), findsOneWidget);
      expect(
        shownTexts(tester, find.byKey(const Key('m9s06-stale'))),
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

  // -- M9S06-13 state branches two cases --------------------------------------

  for (final c
      in <
        ({
          String name,
          Stream<DeviceAccessVm> Function(int call) stream,
          Matcher loading,
          Matcher fail,
          Matcher retry,
        })
      >[
        (
          name: 'loading',
          stream: (int call) => Stream<DeviceAccessVm>.multi(
            (MultiStreamController<DeviceAccessVm> c) {},
          ),
          loading: findsOneWidget,
          fail: findsNothing,
          retry: findsNothing,
        ),
        (
          name: 'fail',
          stream: (int call) =>
              Stream<DeviceAccessVm>.error(StateError('fail')),
          loading: findsNothing,
          fail: findsOneWidget,
          retry: findsOneWidget,
        ),
      ]) {
    testWidgets('M9S06-13 state branch ${c.name}', (WidgetTester tester) async {
      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(devices: c.stream),
          actions: okActions(),
          slots: FakeSettingsSlotRecorder().build,
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );

      expect(find.byKey(const Key('m9s06-loading')), c.loading);
      expect(find.byKey(const Key('m9s06-fail')), c.fail);
      expect(find.text(SettingsLabels.retry), c.retry);
      expect(find.byKey(const ValueKey<String>('m9s06-row-0')), findsNothing);
    });
  }

  // -- M9S06-14 retry ---------------------------------------------------------

  testWidgets('M9S06-14 retry invalidate', (WidgetTester tester) async {
    final FakeSettingsDeviceAccessRepository repo =
        FakeSettingsDeviceAccessRepository(
          devices: (int call) => call == 0
              ? Stream<DeviceAccessVm>.error(StateError('fail'))
              : one(access),
        );

    await pumpDevices(
      tester,
      overrides: devicesOverrides(
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

    expect(find.byKey(const Key('m9s06-fail')), findsNothing);
    expect(find.byKey(const ValueKey<String>('m9s06-row-0')), findsOneWidget);
    expect(repo.devicesCalls, 2);
    expect(find.text(SettingsLabels.retry), findsNothing);
  });

  // -- M9S06-15 all texts under large font ------------------------------------

  for (final c
      in <
        ({
          String name,
          DeviceAccessVm v,
          SettingsActions? Function() actions,
          SettingsSlotBuilder? Function() slots,
          Future<void> Function(WidgetTester t) steps,
          Matcher open,
          Set<String> allowed,
        })
      >[
        (
          name: 'access_operator',
          v: access,
          actions: okActions,
          slots: recordSlots,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...deviceAccessAllowed(access),
            ...deviceAccessControlTexts(access),
          },
        ),
        (
          name: 'ticket_operator',
          v: ticket,
          actions: okActions,
          slots: recordSlots,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...deviceAccessAllowed(ticket),
            ...deviceAccessControlTexts(ticket),
          },
        ),
        (
          name: 'no_viewers_operator',
          v: noViewers,
          actions: okActions,
          slots: recordSlots,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...deviceAccessAllowed(noViewers),
            ...deviceAccessControlTexts(noViewers),
          },
        ),
        (
          name: 'locked_operator',
          v: locked,
          actions: okActions,
          slots: recordSlots,
          steps: noSteps,
          open: findsNothing,
          allowed: <String>{
            ...deviceAccessAllowed(locked),
            ...deviceAccessControlTexts(locked),
          },
        ),
        (
          name: 'access_viewer',
          v: access,
          actions: noActions,
          slots: noSlots,
          steps: noSteps,
          open: findsNothing,
          allowed: deviceAccessAllowed(access),
        ),
        (
          name: 'expanded_operator',
          v: access,
          actions: okActions,
          slots: recordSlots,
          steps: openTablet,
          open: findsOneWidget,
          allowed: <String>{
            ...deviceAccessAllowed(access),
            ...deviceAccessControlTexts(access),
          },
        ),
      ]) {
    testWidgets('M9S06-15 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpDevices(
        tester,
        overrides: devicesOverrides(
          repo: FakeSettingsDeviceAccessRepository(
            devices: (int call) => one(c.v),
          ),
          actions: c.actions(),
          slots: c.slots(),
          opener: RecordingLinkOpener(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      await c.steps(tester);

      expect(find.byKey(const ValueKey<String>('m9s06-confirm-1')), c.open);
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
