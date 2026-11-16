// test/golden/m9s06_golden_test.dart -- M9 S06 devices golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s06_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s06Tall = Size(390, 960);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final DeviceAccessVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

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
  final DeviceAccessVm locked = singleFixture(
    FixturePaths.m9DeviceAccessLocked,
    DeviceAccessVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s06_devices',
      vm: access,
      bottom: const Key('m9s06-asof'),
      head: const Key('m9s06-pairing'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s06_ticket',
      vm: ticket,
      bottom: const Key('m9s06-asof'),
      head: const Key('m9s06-pairing'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s06_no_viewers',
      vm: noViewers,
      bottom: const Key('m9s06-asof'),
      head: const Key('m9s06-pairing'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s06_locked',
      vm: locked,
      bottom: const Key('m9s06-asof'),
      head: const Key('m9s06-locked'),
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
          const Devices(),
          brightness: b,
          logicalSize: _kM9s06Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: devicesOverrides(
              repo: FakeSettingsDeviceAccessRepository(
                devices: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
              slots: FakeSettingsSlotRecorder().build,
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
          lessThan(_kM9s06Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
