// test/golden/v01_golden_test.dart — V-01 조회 전용 QR 페어링 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/v01_golden_test.dart

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
  final PairingVm fixture;
  final Key bottom;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final PairingVm ok = singleFixture(
    FixturePaths.m8PairingOk,
    PairingVm.fromJson,
  );
  final PairingVm fail = singleFixture(
    FixturePaths.m8PairingFail,
    PairingVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'v01_ok',
      fixture: ok,
      bottom: const Key('v01-next'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'v01_fail',
      fixture: fail,
      bottom: const Key('v01-result'),
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
          const ViewerPairing(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: pairingOverrides(
              repo: FakeShellPairingRepository(
                pairing: (int call) => one(flow.fixture),
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
          tester.getTopLeft(find.byKey(const Key('v01-headline'))).dy,
          0.0,
        );

        await expectGolden(flow.name, b);
      });
    }
  }
}
