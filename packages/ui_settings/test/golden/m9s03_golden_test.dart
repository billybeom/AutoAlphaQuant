// test/golden/m9s03_golden_test.dart -- M9 S03 accounts golden (3 names x light/dark = 6 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s03_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s03Tall = Size(390, 1640);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final AccountMappingVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AccountMappingVm mapped = singleFixture(
    FixturePaths.m9AccountMapping,
    AccountMappingVm.fromJson,
  );
  final AccountMappingVm unmapped = singleFixture(
    FixturePaths.m9AccountMappingUnmapped,
    AccountMappingVm.fromJson,
  );
  final AccountMappingVm locked = singleFixture(
    FixturePaths.m9AccountMappingLocked,
    AccountMappingVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s03_mapped',
      vm: mapped,
      bottom: const Key('m9s03-asof'),
      head: const ValueKey<String>('m9s03-account-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s03_unmapped',
      vm: unmapped,
      bottom: const Key('m9s03-asof'),
      head: const ValueKey<String>('m9s03-account-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s03_locked',
      vm: locked,
      bottom: const Key('m9s03-asof'),
      head: const Key('m9s03-locked'),
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
          const Accounts(),
          brightness: b,
          logicalSize: _kM9s03Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: accountsOverrides(
              repo: FakeSettingsAccountMappingRepository(
                mapping: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
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
          lessThan(_kM9s03Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
