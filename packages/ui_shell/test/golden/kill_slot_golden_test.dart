// test/golden/kill_slot_golden_test.dart - R16d kill switch slot golden
// (2 names x light/dark = 4 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/kill_slot_golden_test.dart

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
    required this.platform,
    required this.size,
    required this.slot,
    required this.top,
  });

  final String name;
  final ShellPlatform platform;
  final Size size;
  final Key slot;
  final Finder top;
}

void main() {
  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'ks_s01_appbar',
      platform: ShellPlatform.androidOperator,
      size: kGoldenPhoneSize,
      slot: const Key('s01-kill-slot'),
      top: find.byType(AppBar),
    ),
    _Flow(
      name: 'ks_s02_sidebar',
      platform: ShellPlatform.web,
      size: kWebShellSize,
      slot: const Key('s02-kill-slot'),
      top: find.byKey(const Key('s02-sidebar')),
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
          logicalSize: flow.size,
          wrapApp: (Widget app) => ProviderScope(
            overrides: killSlotOverrides(
              platform: flow.platform,
              flags: kFlagsLiveAuto,
              alerts: const <AlertItem>[],
              slots: FakeShellKillSlot().build,
            ),
            child: app,
          ),
        );
        await tester.pump();
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byKey(flow.slot)).dy,
          lessThan(flow.size.height),
        );
        expect(tester.getTopLeft(flow.top).dy, 0.0);
        await expectGolden(flow.name, b);
      });
    }
  }
}
