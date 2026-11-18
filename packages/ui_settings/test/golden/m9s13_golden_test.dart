// test/golden/m9s13_golden_test.dart -- M9 S13 monthly contribution golden (4 names x light/dark = 8 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s13_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s13Tall = Size(390, 440);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final MonthlyContributionVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final MonthlyContributionVm normal = singleFixture(
    FixturePaths.m9MonthlyContribution,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm pending = singleFixture(
    FixturePaths.m9MonthlyContributionPending,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm noLimit = singleFixture(
    FixturePaths.m9MonthlyContributionNoLimitNote,
    MonthlyContributionVm.fromJson,
  );
  final MonthlyContributionVm locked = singleFixture(
    FixturePaths.m9MonthlyContributionLocked,
    MonthlyContributionVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s13_default',
      vm: normal,
      bottom: const Key('m9s13-asof'),
      head: const Key('m9s13-setting'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s13_pending',
      vm: pending,
      bottom: const Key('m9s13-asof'),
      head: const Key('m9s13-setting'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s13_no_limit_note',
      vm: noLimit,
      bottom: const Key('m9s13-asof'),
      head: const Key('m9s13-setting'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'm9s13_locked',
      vm: locked,
      bottom: const Key('m9s13-asof'),
      head: const Key('m9s13-locked'),
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
          const MonthlyContribution(),
          brightness: b,
          logicalSize: _kM9s13Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: contributionOverrides(
              repo: FakeSettingsContributionRepository(
                contribution: (int call) => one(flow.vm),
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
          lessThan(_kM9s13Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
