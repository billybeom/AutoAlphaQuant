// test/golden/o00_golden_test.dart — O-00 첫 실행 3갈래 골든 (1 name x light/dark = 2 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/o00_golden_test.dart

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
  final OnboardingStartVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final OnboardingStartVm start = singleFixture(
    FixturePaths.m8OnboardingStart,
    OnboardingStartVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'o00_start',
      fixture: start,
      bottom: const Key('o00-viewer'),
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
          const OnboardingStart(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: onboardingOverrides(
              repo: FakeShellOnboardingRepository(
                start: (int call) => one(flow.fixture),
                modeChoice: (int call) =>
                    Stream<OnboardingModeChoiceVm>.error(StateError('unused')),
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
          tester.getTopLeft(find.byKey(const Key('o00-headline'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
