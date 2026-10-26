// test/golden/s01_golden_test.dart — S-01 셸 골든 (2 names x light/dark = 4 PNG).
//
// 🔴 --update-goldens targets this file only:
//      flutter test --update-goldens test/golden/s01_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_shell/ui_shell.dart';

import '../shell_fakes.dart';
import 'golden_support.dart';

class _Flow {
  const _Flow({
    required this.name,
    required this.flags,
    required this.alerts,
    required this.steps,
  });

  final String name;
  final FeatureFlags flags;
  final List<AlertItem> alerts;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final ListResult<AlertItem> alerts12 = listFixture(
    FixturePaths.alerts12,
    AlertItem.fromJson,
  );
  final ListResult<AlertItem> digest = listFixture(
    FixturePaths.m8AlertsDigest,
    AlertItem.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 's01_tabs_p0',
      flags: kFlagsSimAdvisory,
      alerts: alerts12.rows,
      steps: (_) async {},
    ),
    _Flow(
      name: 's01_tabs_clean',
      flags: kFlagsLiveAuto,
      alerts: digest.rows,
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
          const ShellBandOverlay(child: ShellRoot()),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: shellOverrides(
              platform: ShellPlatform.androidOperator,
              config: flagsOf(flow.flags),
              alerts: alertsOf(flow.alerts),
              bodies: const ShellRouteBodies(<String, ShellBodyBuilder>{}),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        // 위치 전제 둘
        expect(
          tester.getBottomLeft(find.byKey(const Key('s01-tabs'))).dy,
          kGoldenPhoneSize.height,
        );
        final Finder topFinder = flow.name == 's01_tabs_p0'
            ? find.byKey(const Key('s01-band'))
            : find.byType(AppBar);
        expect(tester.getTopLeft(topFinder).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
