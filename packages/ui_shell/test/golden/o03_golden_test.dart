// test/golden/o03_golden_test.dart — O-03 검증 결과 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/o03_golden_test.dart

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
    required this.actions,
    required this.bottom,
    required this.steps,
  });

  final String name;
  final SettingsActions Function() actions;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

Future<void> _runVerify(WidgetTester t) async {
  await t.tap(find.byKey(const Key('o03-run')));
  await t.pump();
  await t.pump();
}

void main() {
  final OnboardingStepDetailVm kisMock = singleFixture(
    FixturePaths.m8OnboardingStepDetailKisMock,
    OnboardingStepDetailVm.fromJson,
  );
  final List<ActionResult> results = listFixture(
    FixturePaths.m8OnboardingVerifyResults,
    ActionResult.fromJson,
  ).rows;

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'o03_ok',
      actions: () => FakeShellOnboardingActions(
        result: (int call) => Future<ActionResult>.value(results[0]),
      ),
      bottom: const Key('o03-result'),
      steps: _runVerify,
    ),
    _Flow(
      name: 'o03_fail_code',
      actions: () => FakeShellOnboardingActions(
        result: (int call) => Future<ActionResult>.value(results[1]),
      ),
      bottom: const Key('o03-retry'),
      steps: _runVerify,
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
                detail: (int call) => one(kisMock),
              ),
              actions: flow.actions(),
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
