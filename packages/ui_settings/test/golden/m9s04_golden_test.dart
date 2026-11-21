// test/golden/m9s04_golden_test.dart -- M9 S04 strategy allocation golden (2 names x light/dark = 4 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s04_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s04Tall = Size(390, 1600);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.clock,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final AllocationEditorVm vm;
  final Clock clock;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AllocationEditorVm editor = singleFixture(
    FixturePaths.m9AllocationEditor,
    AllocationEditorVm.fromJson,
  );
  final AllocationEditorVm stale = singleFixture(
    FixturePaths.m9AllocationEditorStale,
    AllocationEditorVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s04_default',
      vm: editor,
      clock: FixedClock(kGoldenNowUtc),
      bottom: const Key('m9s04-asof'),
      head: const Key('m9s04-current'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s04_stale',
      vm: stale,
      clock: FixedClock(
        stale.asOf.observedAt
            .add(stale.asOf.staleAfter)
            .add(const Duration(seconds: 1)),
      ),
      bottom: const Key('m9s04-asof'),
      head: const Key('m9s04-stale'),
      steps: (WidgetTester tester) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const StrategyAllocation(),
          brightness: b,
          logicalSize: _kM9s04Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: allocationOverrides(
              repo: FakeSettingsAllocationRepository(
                allocation: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
              opener: RecordingLinkOpener(),
              clock: flow.clock,
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(_kM9s04Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
