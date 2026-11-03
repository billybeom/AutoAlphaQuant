// test/golden/o01_golden_test.dart — O-01 단계 목록 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/o01_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

class _Flow {
  const _Flow({
    required this.name,
    required this.fixture,
    required this.bottom,
    required this.steps,
  });

  final String name;
  final OnboardingStepsVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final OnboardingStepsVm fresh = singleFixture(
    FixturePaths.m8OnboardingStepsFresh,
    OnboardingStepsVm.fromJson,
  );
  final OnboardingStepsVm advisory = singleFixture(
    FixturePaths.m8OnboardingStepsAdvisory,
    OnboardingStepsVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'o01_fresh',
      fixture: fresh,
      bottom: const ValueKey<String>('o01-row-3'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'o01_advisory',
      fixture: advisory,
      bottom: const ValueKey<String>('o01-row-4'),
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
          const OnboardingStepList(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: stepOverrides(
              repo: FakeShellStepRepository(
                steps: (int call) => one(flow.fixture),
                detail: (int call) =>
                    Stream<OnboardingStepDetailVm>.error(StateError('unused')),
              ),
              actions: UnimplementedSettingsActions(),
              slots: null,
              opener: RecordingLinkOpener(),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        // 위치 전제 둘
        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(
          tester.getTopLeft(find.byKey(const Key('o01-progress'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
