// test/golden/m9s10_golden_test.dart -- M9 S10 diagnostics golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s10_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s10Tall = Size(390, 680);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final DiagnosticsScreenVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final DiagnosticsScreenVm normal = singleFixture(
    FixturePaths.m9DiagnosticsScreen,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm diff = singleFixture(
    FixturePaths.m9DiagnosticsScreenDiff,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm running = singleFixture(
    FixturePaths.m9DiagnosticsScreenRunning,
    DiagnosticsScreenVm.fromJson,
  );
  final DiagnosticsScreenVm locked = singleFixture(
    FixturePaths.m9DiagnosticsScreenLocked,
    DiagnosticsScreenVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s10_default',
      vm: normal,
      bottom: const Key('m9s10-asof'),
      head: const Key('m9s10-recommend'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s10_diff',
      vm: diff,
      bottom: const Key('m9s10-asof'),
      head: const Key('m9s10-golden'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s10_running',
      vm: running,
      bottom: const Key('m9s10-asof'),
      head: const Key('m9s10-golden'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s10_locked',
      vm: locked,
      bottom: const Key('m9s10-asof'),
      head: const Key('m9s10-locked'),
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
          const Diagnostics(),
          brightness: b,
          logicalSize: _kM9s10Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: diagnosticsOverrides(
              repo: FakeSettingsDiagnosticsRepository(
                diagnostics: (int call) => one(flow.vm),
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
          lessThan(_kM9s10Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
