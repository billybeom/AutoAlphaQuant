// test/golden/m9s05_board_golden_test.dart -- M9 S05 board golden (1 name x light/dark = 2 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s05_board_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s05Tall = Size(390, 2160);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final OperationsVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final OperationsVm holdKeys = singleFixture(
    FixturePaths.m9OperationsLiveHoldKeys,
    OperationsVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s05_hold_keys',
      vm: holdKeys,
      bottom: const Key('m9s05-asof'),
      head: const Key('m9s05-chip'),
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
          const Operations(),
          brightness: b,
          logicalSize: _kM9s05Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: operationsOverrides(
              repo: FakeSettingsOperationsRepository(
                operations: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
              opener: RecordingLinkOpener(),
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
          lessThan(_kM9s05Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
