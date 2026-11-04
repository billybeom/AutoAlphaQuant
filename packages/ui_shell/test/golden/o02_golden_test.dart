// test/golden/o02_golden_test.dart — O-02 단계 상세 골든 (1 name x light/dark = 2 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/o02_golden_test.dart

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
  final OnboardingStepDetailVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final OnboardingStepDetailVm kisMock = singleFixture(
    FixturePaths.m8OnboardingStepDetailKisMock,
    OnboardingStepDetailVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'o02_step',
      fixture: kisMock,
      bottom: const Key('o03-run'),
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
          OnboardingStepDetail(stepId: kisMock.step!.stepId),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: stepOverrides(
              repo: FakeShellStepRepository(
                steps: (int call) =>
                    Stream<OnboardingStepsVm>.error(StateError('unused')),
                detail: (int call) => one(flow.fixture),
              ),
              actions: UnimplementedSettingsActions(),
              slots: FakeShellSlotRecorder().build,
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
        expect(tester.getTopLeft(find.byKey(const Key('o02-head'))).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
