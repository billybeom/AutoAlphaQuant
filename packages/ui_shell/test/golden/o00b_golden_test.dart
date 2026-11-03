// test/golden/o00b_golden_test.dart — O-00b 운영 방식 선택 골든 (3 names x light/dark = 6 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/o00b_golden_test.dart

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
  final OnboardingModeChoiceVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final OnboardingModeChoiceVm unselected = singleFixture(
    FixturePaths.m8OnboardingModeUnselected,
    OnboardingModeChoiceVm.fromJson,
  );
  final OnboardingModeChoiceVm auto = singleFixture(
    FixturePaths.m8OnboardingModeAuto,
    OnboardingModeChoiceVm.fromJson,
  );
  final OnboardingModeChoiceVm advisory = singleFixture(
    FixturePaths.m8OnboardingModeAdvisory,
    OnboardingModeChoiceVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'o00b_unselected',
      fixture: unselected,
      bottom: const Key('o00b-honesty'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'o00b_auto',
      fixture: auto,
      bottom: const Key('o00b-next'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'o00b_advisory',
      fixture: advisory,
      bottom: const Key('o00b-next'),
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
          const OnboardingModePick(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: onboardingOverrides(
              repo: FakeShellOnboardingRepository(
                start: (int call) =>
                    Stream<OnboardingStartVm>.error(StateError('unused')),
                modeChoice: (int call) => one(flow.fixture),
              ),
              actions: UnimplementedSettingsActions(),
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
          tester.getTopLeft(find.byKey(const Key('o00b-headline'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
