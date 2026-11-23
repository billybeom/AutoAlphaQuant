// test/hold_banner_test.dart - R16e H-01 hold banner (engine hold lines in
// engine order, one static look, no lines = no banner). ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

void main() {
  final HoldHomeInputs inputs = holdHomeInputs();
  final SafetyState keys = holdRow(0);
  final SafetyState migration = holdRow(1);

  // -- HL-01: one hold line per fixture row, banner above block 1 --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
  ]) {
    testWidgets('HL-01 one hold line ${c.name}', (WidgetTester tester) async {
      expect(c.safety.holdLabels, hasLength(1)); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('h01-holds'))),
        c.safety.holdLabels,
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('h01-holds'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('h01-asof'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('h01-status'))).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byKey(const Key('h01-holds'))).dy,
        ),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-02: two hold lines keep the engine order --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys_then_migration', safety: holdPair(keys, migration)),
    (name: 'migration_then_keys', safety: holdPair(migration, keys)),
  ]) {
    testWidgets('HL-02 hold lines in order ${c.name}', (
      WidgetTester tester,
    ) async {
      expect(c.safety.holdLabels, hasLength(2)); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        shownTexts(tester, find.byKey(const Key('h01-holds'))),
        c.safety.holdLabels,
      );
      expect(
        shownTexts(tester, find.byKey(const ValueKey<String>('hold-line-0'))),
        <String?>[c.safety.holdLabels.first],
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('hold-line-1'))).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const ValueKey<String>('hold-line-0')))
              .dy,
        ),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-03: no hold lines = no banner --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'normal', safety: safetyFixtureRow(0)),
    (name: 'blocked', safety: safetyFixtureRow(3)),
  ]) {
    testWidgets('HL-03 no hold lines ${c.name}', (WidgetTester tester) async {
      expect(c.safety.holdLabels, isEmpty); // pre
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(find.byKey(const Key('h01-status')), findsOneWidget);
      expect(find.byKey(const Key('h01-holds')), findsNothing);
      expect(find.byIcon(Icons.pause_circle_outline), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-04: every line has the same static icon and colors --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
    (name: 'two', safety: holdPair(keys, migration)),
  ]) {
    testWidgets('HL-04 one look ${c.name}', (WidgetTester tester) async {
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      final Finder banner = find.byKey(const Key('h01-holds'));
      final ColorScheme cs = Theme.of(tester.element(banner)).colorScheme;
      final List<Icon> icons = tester
          .widgetList<Icon>(
            find.descendant(of: banner, matching: find.byType(Icon)),
          )
          .toList();
      expect(
        icons.map((Icon i) => i.icon).toList(),
        List<IconData?>.filled(
          c.safety.holdLabels.length,
          Icons.pause_circle_outline,
        ),
      );
      expect(icons.map((Icon i) => i.color).toSet(), <Color?>{
        cs.onTertiaryContainer,
      });
      expect(
        tester
            .widget<Card>(
              find.descendant(of: banner, matching: find.byType(Card)),
            )
            .color,
        cs.tertiaryContainer,
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-05: the banner is not a tap target, no link opens --
  testWidgets('HL-05 banner is not a tap target', (WidgetTester tester) async {
    final RecordingLinkOpener opener = RecordingLinkOpener();
    await pumpOpsHome(
      tester,
      overrides: holdHomeOverrides(
        inputs: inputs,
        safety: (int call) => one(holdPair(keys, migration)),
        opener: opener,
      ),
    );
    final Finder banner = find.byKey(const Key('h01-holds'));
    expect(
      find.descendant(of: banner, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      find.ancestor(of: banner, matching: find.byType(InkWell)),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey<String>('hold-line-0')));
    await tester.pumpAndSettle();
    expect(opener.opened, isEmpty);
    expect(banner, findsOneWidget);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- HL-06: screen text = home texts plus the hold lines, each line once --
  for (final c in <({String name, SafetyState safety})>[
    (name: 'keys', safety: keys),
    (name: 'migration', safety: migration),
    (name: 'two', safety: holdPair(keys, migration)),
  ]) {
    testWidgets('HL-06 screen text ${c.name}', (WidgetTester tester) async {
      await pumpOpsHome(
        tester,
        overrides: holdHomeOverrides(
          inputs: inputs,
          safety: (int call) => one(c.safety),
          opener: RecordingLinkOpener(),
        ),
      );
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((Text t) => t.data)
            .toSet()
            .difference(holdHomeAllowed(inputs, c.safety)),
        isEmpty,
      );
      expect(
        c.safety.holdLabels
            .map((String l) => find.text(l).evaluate().length)
            .toList(),
        List<int>.filled(c.safety.holdLabels.length, 1),
      );
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- HL-07: safety stream error = retry block, no banner --
  testWidgets('HL-07 safety error shows retry and no banner', (
    WidgetTester tester,
  ) async {
    await pumpOpsHome(
      tester,
      overrides: holdHomeOverrides(
        inputs: inputs,
        safety: (int call) => Stream<SafetyState>.error(StateError('fail')),
        opener: RecordingLinkOpener(),
      ),
    );
    expect(find.byKey(const Key('h01-status-fail')), findsOneWidget);
    expect(find.byKey(const Key('h01-holds')), findsNothing);
  });
}
