// test/kill_slot_test.dart - R16d kill switch slot (S-01 phone app bar,
// S-01 phone link page app bar, S-02 web sidebar). ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  final ListResult<AlertItem> alerts12 = listFixture(
    FixturePaths.alerts12,
    AlertItem.fromJson,
  );

  // -- KS-01: phone home slot = builder widget for the kill switch id --
  for (final c
      in <
        ({
          String name,
          ShellPlatform platform,
          FeatureFlags flags,
          List<AlertItem> alerts,
          Matcher p0,
        })
      >[
        (
          name: 'android_live',
          platform: ShellPlatform.androidOperator,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          p0: isFalse,
        ),
        (
          name: 'android_sim_p0',
          platform: ShellPlatform.androidOperator,
          flags: kFlagsSimAdvisory,
          alerts: alerts12.rows,
          p0: isTrue,
        ),
        (
          name: 'ios_live',
          platform: ShellPlatform.iosViewer,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          p0: isFalse,
        ),
      ]) {
    testWidgets('KS-01 phone home slot ${c.name}', (WidgetTester tester) async {
      expect(hasUnackedP0(c.alerts), c.p0); // pre
      final FakeShellKillSlot slot = FakeShellKillSlot();
      await pumpShell(
        tester,
        overrides: killSlotOverrides(
          platform: c.platform,
          flags: c.flags,
          alerts: c.alerts,
          slots: slot.build,
        ),
      );
      expect(find.byKey(const Key('s01-tabs')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byKey(const Key('s01-kill-slot')),
        ),
        findsOneWidget,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('s01-kill-slot'))),
        <String?>[OpsSlotIds.killSwitch],
      );
      expect(slot.slotIds.toSet(), <String>{OpsSlotIds.killSwitch});
      expect(find.text(OpsSlotIds.killSwitch), findsOneWidget);
      expect(find.byKey(const Key('s01-link-kill-slot')), findsNothing);
      expect(find.byKey(const Key('s02-kill-slot')), findsNothing);
      expect(slot.taps, <String>[]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- KS-02: phone home without builder = no slot, empty actions --
  for (final c in <({String name, ShellPlatform platform})>[
    (name: 'android', platform: ShellPlatform.androidOperator),
    (name: 'ios', platform: ShellPlatform.iosViewer),
  ]) {
    testWidgets('KS-02 phone home no builder ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        overrides: killSlotOverrides(
          platform: c.platform,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          slots: null,
        ),
      );
      expect(find.byKey(const Key('s01-title')), findsOneWidget);
      expect(find.byKey(const Key('s01-kill-slot')), findsNothing);
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isEmpty);
      expect(shownTexts(tester, find.byType(AppBar)), <String?>[
        shellTitle(kFlagsLiveAuto, ShellLabels.tabHome),
      ]);
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- KS-03: phone link page slot (pushed page covers the home app bar) --
  for (final c in <({String name, ShellPlatform platform})>[
    (name: 'android', platform: ShellPlatform.androidOperator),
    (name: 'ios', platform: ShellPlatform.iosViewer),
  ]) {
    testWidgets('KS-03 phone link page slot ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeShellKillSlot slot = FakeShellKillSlot();
      await pumpShell(
        tester,
        overrides: killSlotOverrides(
          platform: c.platform,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          slots: slot.build,
        ),
      );
      await openLink(tester, dummyLink(AppRoutes.reportArchive));
      expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byKey(const Key('s01-link-kill-slot')),
        ),
        findsOneWidget,
      );
      expect(
        shownTexts(tester, find.byKey(const Key('s01-link-kill-slot'))),
        <String?>[OpsSlotIds.killSwitch],
      );
      expect(find.byKey(const Key('s01-kill-slot')), findsNothing);
      expect(find.text(OpsSlotIds.killSwitch), findsOneWidget);
      expect(slot.slotIds.toSet(), <String>{OpsSlotIds.killSwitch});
      await openLink(tester, AppNavActions.back);
      expect(find.byKey(const Key('s01-link-kill-slot')), findsNothing);
      expect(
        shownTexts(tester, find.byKey(const Key('s01-kill-slot'))),
        <String?>[OpsSlotIds.killSwitch],
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- KS-04: phone link page without builder = no slot, empty actions --
  for (final c in <({String name, ShellPlatform platform})>[
    (name: 'android', platform: ShellPlatform.androidOperator),
    (name: 'ios', platform: ShellPlatform.iosViewer),
  ]) {
    testWidgets('KS-04 phone link page no builder ${c.name}', (
      WidgetTester tester,
    ) async {
      await pumpShell(
        tester,
        overrides: killSlotOverrides(
          platform: c.platform,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          slots: null,
        ),
      );
      await openLink(tester, dummyLink(AppRoutes.reportArchive));
      expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
      expect(find.byKey(const Key('s01-link-kill-slot')), findsNothing);
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isEmpty);
      expect(shownTexts(tester, find.byType(AppBar)), <String?>[]);
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- KS-05: web sidebar slot = builder widget, link page has no slot --
  testWidgets('KS-05 web sidebar slot', (WidgetTester tester) async {
    final FakeShellKillSlot slot = FakeShellKillSlot();
    await pumpShell(
      tester,
      overrides: killSlotOverrides(
        platform: ShellPlatform.web,
        flags: kFlagsSimAdvisory,
        alerts: const <AlertItem>[],
        slots: slot.build,
      ),
      size: kWebShellSize,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('s02-sidebar')),
        matching: find.byKey(const Key('s02-kill-slot')),
      ),
      findsOneWidget,
    );
    expect(
      shownTexts(tester, find.byKey(const Key('s02-kill-slot'))),
      <String?>[OpsSlotIds.killSwitch],
    );
    expect(tester.getSize(find.byKey(const Key('s02-kill-slot'))).height, 56.0);
    expect(find.text(OpsSlotIds.killSwitch), findsOneWidget);
    expect(find.byKey(const Key('s01-kill-slot')), findsNothing);
    expect(slot.slotIds.toSet(), <String>{OpsSlotIds.killSwitch});
    await openLink(tester, dummyLink(AppRoutes.reportArchive));
    expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
    expect(find.byKey(const Key('s01-link-kill-slot')), findsNothing);
    expect(
      shownTexts(tester, find.byKey(const Key('s02-kill-slot'))),
      <String?>[OpsSlotIds.killSwitch],
    );
    expect(find.text(OpsSlotIds.killSwitch), findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- KS-06: web sidebar without builder = empty 56 box kept --
  testWidgets('KS-06 web sidebar no builder', (WidgetTester tester) async {
    await pumpShell(
      tester,
      overrides: killSlotOverrides(
        platform: ShellPlatform.web,
        flags: kFlagsSimAdvisory,
        alerts: const <AlertItem>[],
        slots: null,
      ),
      size: kWebShellSize,
    );
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('s02-kill-slot')),
        matching: find.byWidgetPredicate(isAnyWidget),
      ),
      findsNothing,
    );
    expect(tester.getSize(find.byKey(const Key('s02-kill-slot'))).height, 56.0);
    await openLink(tester, dummyLink(AppRoutes.reportArchive));
    expect(dummyOf(AppRoutes.reportArchive), findsOneWidget);
    expect(find.byKey(const Key('s01-link-kill-slot')), findsNothing);
    expect(find.byKey(const Key('s02-kill-slot')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- KS-07: tap passes through the builder widget once, no dialog, no route --
  for (final c
      in <
        ({
          String name,
          ShellPlatform platform,
          Size size,
          Future<void> Function(WidgetTester t) open,
          Key slotKey,
          Matcher pages,
        })
      >[
        (
          name: 'phone_home',
          platform: ShellPlatform.androidOperator,
          size: kGoldenPhoneSize,
          open: (WidgetTester t) async {},
          slotKey: const Key('s01-kill-slot'),
          pages: findsNothing,
        ),
        (
          name: 'phone_link',
          platform: ShellPlatform.androidOperator,
          size: kGoldenPhoneSize,
          open: (WidgetTester t) =>
              openLink(t, dummyLink(AppRoutes.reportArchive)),
          slotKey: const Key('s01-link-kill-slot'),
          pages: findsOneWidget,
        ),
        (
          name: 'web',
          platform: ShellPlatform.web,
          size: kWebShellSize,
          open: (WidgetTester t) async {},
          slotKey: const Key('s02-kill-slot'),
          pages: findsNothing,
        ),
      ]) {
    testWidgets('KS-07 tap passes through ${c.name}', (
      WidgetTester tester,
    ) async {
      final FakeShellKillSlot slot = FakeShellKillSlot();
      await pumpShell(
        tester,
        overrides: killSlotOverrides(
          platform: c.platform,
          flags: kFlagsLiveAuto,
          alerts: const <AlertItem>[],
          slots: slot.build,
        ),
        size: c.size,
      );
      await c.open(tester);
      expect(slot.taps, <String>[]);
      await tester.tap(find.text(OpsSlotIds.killSwitch));
      await tester.pumpAndSettle();
      expect(slot.taps, <String>[OpsSlotIds.killSwitch]);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(ShellLinkPage), c.pages);
      expect(shownTexts(tester, find.byKey(c.slotKey)), <String?>[
        OpsSlotIds.killSwitch,
      ]);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }
}
