// test/device_risk_board_test.dart - H03-01 ~ H03-08
//
// H-03 device risk board tests.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import 'golden/golden_support.dart';
import 'shell_fakes.dart';

(IconData, Color) wantLevel(ColorScheme cs, UiLevel l) => switch (l) {
  UiLevel.ok => (Icons.check_circle_outline, cs.primary),
  UiLevel.info => (Icons.info_outline, cs.onSurfaceVariant),
  UiLevel.watch => (Icons.visibility_outlined, cs.tertiary),
  UiLevel.act => (Icons.error_outline, cs.secondary),
  UiLevel.blocked => (Icons.block, cs.error),
};

typedef _VmCase = ({String name, DeviceRiskVm v});

typedef _StaleCase = ({
  String name,
  Clock clock,
  Matcher staleMatcher,
  List<String?> staleTexts,
});

typedef _StateCase = ({
  String name,
  FakeShellDeviceRiskRepository Function() opsFactory,
  Key present,
  List<Key> absent,
});

void main() {
  final DeviceRiskVm items = singleFixture(
    FixturePaths.m8DeviceRiskItems,
    DeviceRiskVm.fromJson,
  );
  final DeviceRiskVm empty = singleFixture(
    FixturePaths.m8DeviceRiskEmpty,
    DeviceRiskVm.fromJson,
  );

  FakeShellDeviceRiskRepository opsOf(DeviceRiskVm v) =>
      FakeShellDeviceRiskRepository(deviceRisk: (int call) => one(v));

  // -- H03-01 rows text order guidance
  testWidgets('H03-01 rows text order guidance', (WidgetTester tester) async {
    final FakeShellDeviceRiskRepository ops = opsOf(items);
    await pumpDeviceRiskBoard(
      tester,
      overrides: deviceRiskOverrides(
        ops: ops,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(ops.deviceRiskCalls, 1);

    final List<Finder> chain = <Finder>[
      find.byKey(const Key('h03-asof')),
      find.byKey(const ValueKey<String>('h03-row-0')),
      find.byKey(const ValueKey<String>('h03-row-1')),
      find.byKey(const ValueKey<String>('h03-row-2')),
      find.byKey(const ValueKey<String>('h03-row-3')),
      find.byKey(const ValueKey<String>('h03-row-4')),
      find.byKey(const Key('h03-guidance')),
    ];
    for (int i = 1; i < chain.length; i++) {
      expect(
        tester.getTopLeft(chain[i - 1]).dy,
        lessThan(tester.getTopLeft(chain[i]).dy),
      );
    }

    expect(shownTexts(tester, find.byKey(const Key('h03-asof'))), <String>[
      items.asOf.label,
    ]);
    expect(items.rows, hasLength(5)); // h
    for (final (int i, DeviceRiskItem r) in items.rows.indexed) {
      expect(
        shownTexts(tester, find.byKey(ValueKey<String>('h03-row-$i'))),
        <String>[
          r.label,
          r.currentText,
          r.thresholdText,
          r.actionText,
          r.lastCheckedText,
        ],
      );
    }
    expect(find.byKey(const ValueKey<String>('h03-row-5')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('h03-guidance'))), <String>[
      items.guidanceText,
    ]);
    expect(find.byKey(const Key('h03-empty')), findsNothing);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- H03-02 level to icon and color
  testWidgets('H03-02 level icon color', (WidgetTester tester) async {
    expect(
      items.rows.map((DeviceRiskItem r) => r.level).toSet().length,
      greaterThan(1),
    ); // pre
    await pumpDeviceRiskBoard(
      tester,
      overrides: deviceRiskOverrides(
        ops: opsOf(items),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    final ColorScheme cs = Theme.of(
      tester.element(find.byType(DeviceRiskBoard)),
    ).colorScheme;
    for (final (int i, DeviceRiskItem r) in items.rows.indexed) {
      final Icon icon = tester.widget<Icon>(
        find.byKey(ValueKey<String>('h03-level-$i')),
      );
      final (IconData wantIcon, Color wantColor) = wantLevel(cs, r.level);
      expect(icon.icon, wantIcon);
      expect(icon.color, wantColor);
    }
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- H03-03 empty label is data
  testWidgets('H03-03 empty label data driven', (WidgetTester tester) async {
    expect(empty.rows, isEmpty); // pre
    expect(empty.emptyLabel, isNotNull); // pre
    await pumpDeviceRiskBoard(
      tester,
      overrides: deviceRiskOverrides(
        ops: opsOf(empty),
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    expect(shownTexts(tester, find.byKey(const Key('h03-empty'))), <String>[
      empty.emptyLabel!,
    ]);
    expect(find.byKey(const ValueKey<String>('h03-row-0')), findsNothing);
    expect(shownTexts(tester, find.byKey(const Key('h03-guidance'))), <String>[
      empty.guidanceText,
    ]);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- H03-04 asof header and stale banner
  final List<_StaleCase> staleCases = <_StaleCase>[
    (
      name: 'fresh',
      clock: FixedClock(kGoldenNowUtc),
      staleMatcher: findsNothing,
      staleTexts: <String?>[],
    ),
    (
      name: 'stale',
      clock: FixedClock(kGoldenNowUtc.add(const Duration(days: 2))),
      staleMatcher: findsOneWidget,
      staleTexts: <String?>[
        ShellLabels.staleBannerTitle,
        ?items.asOf.staleLabel,
      ],
    ),
  ];
  for (final _StaleCase c in staleCases) {
    testWidgets('H03-04 asof stale ${c.name}', (WidgetTester tester) async {
      await pumpDeviceRiskBoard(
        tester,
        overrides: deviceRiskOverrides(ops: opsOf(items), clock: c.clock),
      );
      expect(find.byKey(const Key('h03-asof')), findsOneWidget);
      expect(find.byKey(const Key('h03-stale')), c.staleMatcher);
      expect(
        shownTexts(tester, find.byKey(const Key('h03-stale'))),
        c.staleTexts,
      );
      expect(find.byKey(const ValueKey<String>('h03-row-0')), findsOneWidget);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- H03-05 no action buttons
  final List<_VmCase> vmCases = <_VmCase>[
    (name: 'items', v: items),
    (name: 'empty', v: empty),
  ];
  for (final _VmCase c in vmCases) {
    testWidgets('H03-05 no buttons ${c.name}', (WidgetTester tester) async {
      await pumpDeviceRiskBoard(
        tester,
        overrides: deviceRiskOverrides(
          ops: opsOf(c.v),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      expect(find.byKey(const Key('h03-guidance')), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }

  // -- H03-06 state branches
  final List<_StateCase> stateCases = <_StateCase>[
    (
      name: 'loading',
      opsFactory: () => FakeShellDeviceRiskRepository(
        deviceRisk: (int call) => Stream<DeviceRiskVm>.multi(
          (MultiStreamController<DeviceRiskVm> c) {},
        ),
      ),
      present: const Key('h03-loading'),
      absent: <Key>[const Key('h03-asof'), const Key('h03-fail')],
    ),
    (
      name: 'fail',
      opsFactory: () => FakeShellDeviceRiskRepository(
        deviceRisk: (int call) => Stream<DeviceRiskVm>.error(StateError('x')),
      ),
      present: const Key('h03-fail'),
      absent: <Key>[const Key('h03-asof'), const Key('h03-loading')],
    ),
  ];
  for (final _StateCase c in stateCases) {
    testWidgets('H03-06 state branch ${c.name}', (WidgetTester tester) async {
      await pumpDeviceRiskBoard(
        tester,
        overrides: deviceRiskOverrides(
          ops: c.opsFactory(),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      expect(find.byKey(c.present), findsOneWidget);
      for (final Key k in c.absent) {
        expect(find.byKey(k), findsNothing);
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  // -- H03-07 retry
  testWidgets('H03-07 retry', (WidgetTester tester) async {
    final FakeShellDeviceRiskRepository ops = FakeShellDeviceRiskRepository(
      deviceRisk: (int call) =>
          call == 0 ? Stream<DeviceRiskVm>.error(StateError('x')) : one(items),
    );
    await pumpDeviceRiskBoard(
      tester,
      overrides: deviceRiskOverrides(
        ops: ops,
        clock: FixedClock(kGoldenNowUtc),
      ),
    );
    await tester.tap(find.text(ShellLabels.retry));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('h03-fail')), findsNothing);
    expect(find.byKey(const Key('h03-asof')), findsOneWidget);
    expect(ops.deviceRiskCalls, 2);
    expect(find.text(ShellLabels.retry), findsNothing);
  });

  // -- H03-08 all texts and large font
  for (final _VmCase c in vmCases) {
    testWidgets('H03-08 all texts large font ${c.name}', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpDeviceRiskBoard(
        tester,
        overrides: deviceRiskOverrides(
          ops: opsOf(c.v),
          clock: FixedClock(kGoldenNowUtc),
        ),
      );
      final Set<String> allowed = deviceRiskAllowed(c.v);
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
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(ShellLabels.retry), findsNothing);
    });
  }
}
