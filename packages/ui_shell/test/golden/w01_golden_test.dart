// test/golden/w01_golden_test.dart — W-01 워치독 상태 골든 (3 names x light/dark = 6 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/w01_golden_test.dart

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
  final WatchdogBoardVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final WatchdogBoardVm delayed = singleFixture(
    FixturePaths.m8WatchdogDelayed,
    WatchdogBoardVm.fromJson,
  );
  final WatchdogBoardVm holiday = singleFixture(
    FixturePaths.m8WatchdogHoliday,
    WatchdogBoardVm.fromJson,
  );
  final WatchdogBoardVm paused = singleFixture(
    FixturePaths.m8WatchdogPaused,
    WatchdogBoardVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'w01_delayed',
      fixture: delayed,
      bottom: const Key('w01-limit'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'w01_holiday',
      fixture: holiday,
      bottom: const Key('w01-limit'),
      steps: (_) async {},
    ),
    _Flow(
      name: 'w01_paused',
      fixture: paused,
      bottom: const Key('w01-limit'),
      steps: (_) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const WatchdogBoard(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: watchdogOverrides(
              ops: FakeShellWatchdogRepository(
                watchdog: (int call) =>
                    Stream<WatchdogBoardVm>.value(flow.fixture),
              ),
              opener: RecordingLinkOpener(),
              clock: FixedClock(kGoldenNowUtc),
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
        expect(tester.getTopLeft(find.byKey(const Key('w01-asof'))).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
