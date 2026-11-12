// test/golden/h03_golden_test.dart - H-03 device risk golden (2 names x light/dark = 4 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/h03_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final DeviceRiskVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final DeviceRiskVm items = singleFixture(
    FixturePaths.m8DeviceRiskItems,
    DeviceRiskVm.fromJson,
  );
  final DeviceRiskVm empty = singleFixture(
    FixturePaths.m8DeviceRiskEmpty,
    DeviceRiskVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'h03_items',
      vm: items,
      bottom: const Key('h03-guidance'),
      head: const Key('h03-asof'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'h03_empty',
      vm: empty,
      bottom: const Key('h03-guidance'),
      head: const Key('h03-asof'),
      steps: (WidgetTester t) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const DeviceRiskBoard(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: deviceRiskOverrides(
              ops: FakeShellDeviceRiskRepository(
                deviceRisk: (int call) => one(flow.vm),
              ),
              clock: FixedClock(kGoldenNowUtc),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
