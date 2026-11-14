// test/golden/m9s07_golden_test.dart -- M9 S07 connections golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s07_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s07Tall = Size(390, 1040);

SettingsActions? _nullActions() => null;

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.actions,
    required this.size,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final ConnectionsVm vm;
  final SettingsActions? Function() actions;
  final Size size;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final ConnectionsVm connVm = singleFixture(
    FixturePaths.m9Connections,
    ConnectionsVm.fromJson,
  );
  final ConnectionsVm teleVm = singleFixture(
    FixturePaths.m9ConnectionsTelegram,
    ConnectionsVm.fromJson,
  );
  final ConnectionsVm lockedVm = singleFixture(
    FixturePaths.m9ConnectionsLocked,
    ConnectionsVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s07_connections',
      vm: connVm,
      actions: UnimplementedSettingsActions.new,
      size: _kM9s07Tall,
      bottom: const Key('m9s07-asof'),
      head: const ValueKey<String>('m9s07-row-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s07_telegram',
      vm: teleVm,
      actions: UnimplementedSettingsActions.new,
      size: kGoldenPhoneSize,
      bottom: const Key('m9s07-asof'),
      head: const ValueKey<String>('m9s07-row-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s07_locked',
      vm: lockedVm,
      actions: UnimplementedSettingsActions.new,
      size: kGoldenPhoneSize,
      bottom: const Key('m9s07-asof'),
      head: const Key('m9s07-locked'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s07_viewer',
      vm: connVm,
      actions: _nullActions,
      size: kGoldenPhoneSize,
      bottom: const Key('m9s07-asof'),
      head: const ValueKey<String>('m9s07-row-0'),
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
          const Connections(),
          brightness: b,
          logicalSize: flow.size,
          wrapApp: (Widget app) => ProviderScope(
            overrides: connectionsOverrides(
              repo: FakeSettingsOpsStatusRepository(
                connections: (int call) => one(flow.vm),
              ),
              actions: flow.actions(),
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
          lessThan(flow.size.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
