// test/golden/r01_golden_test.dart — R-01 기존 계정에서 다시 시작 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/r01_golden_test.dart

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
  final RestartVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final RestartVm lostPhone = singleFixture(
    FixturePaths.m8RestartVmLostPhone,
    RestartVm.fromJson,
  );
  final RestartVm gap7 = singleFixture(
    FixturePaths.m8RestartVmGap7,
    RestartVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'r01_lost_phone',
      fixture: lostPhone,
      bottom: const Key('r01-inherit'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'r01_gap7',
      fixture: gap7,
      bottom: const Key('r01-inherit'),
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
          const OnboardingRestart(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: restartOverrides(
              repo: FakeShellRestartRepository(
                restart: (int call) => one(flow.fixture),
              ),
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
        expect(
          tester.getTopLeft(find.byKey(const Key('r01-headline'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
