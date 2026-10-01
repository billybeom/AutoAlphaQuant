// packages/ui_analytics/test/golden/s79_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_analytics/ui_analytics.dart';

import '../goal_path_fakes.dart';
import 'golden_support.dart';

const Size kS79GoldenSize = Size(390, 900);

void main() {
  final testCases = <(String, String)>[
    ('s79_on_track', FixturePaths.m7M7GoalPathOn),
    ('s79_off_track', FixturePaths.m7M7GoalPathOff),
    ('s79_hold', FixturePaths.m7M7GoalPathHold),
    ('s79_realworld', FixturePaths.m7M7GoalPathRealworld),
  ];

  for (final (String name, String fixturePath) in testCases) {
    for (final Brightness b in Brightness.values) {
      testWidgets('$name ${brightnessSuffix(b)}', (WidgetTester tester) async {
        final GoalPathVm vm = singleFixture(fixturePath, GoalPathVm.fromJson);
        final repo = FakeGoalPathRepository(vm: vm);

        await pumpForGolden(
          tester,
          ProviderScope(
            overrides: goalPathOverrides(repo: repo),
            child: GoalPathScreen(yyyyMm: vm.yyyyMm),
          ),
          brightness: b,
          logicalSize: kS79GoldenSize,
        );
        await tester.pump();

        expect(
          tester.getBottomLeft(find.byKey(const Key('s79-disclaimer'))).dy,
          lessThan(kS79GoldenSize.height),
        );

        await expectGolden(name, b);
      });
    }
  }
}
