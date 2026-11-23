// test/golden/hold_banner_golden_test.dart - R16e H-01 hold banner goldens
// (2 names x light/dark = 4 PNG). ASCII only.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

void main() {
  final HoldHomeInputs inputs = holdHomeInputs();
  for (final c in <({String name, SafetyState safety})>[
    (name: 'hl_h01_keys', safety: holdRow(0)),
    (name: 'hl_h01_two', safety: holdPair(holdRow(0), holdRow(1))),
  ]) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${c.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const OpsHome(),
          brightness: b,
          wrapApp: (Widget app) => ProviderScope(
            overrides: holdHomeOverrides(
              inputs: inputs,
              safety: (int call) => one(c.safety),
              opener: RecordingLinkOpener(),
            ),
            child: app,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byKey(const Key('h01-holds'))).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(tester.getTopLeft(find.byKey(const Key('h01-asof'))).dy, 0.0);
        await expectGolden(c.name, b);
      });
    }
  }
}
