// test/golden/d03_golden_test.dart - D-03 emergency stop card golden (1 name x light/dark = 2 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/d03_golden_test.dart

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
    required this.head,
    required this.steps,
  });

  final String name;
  final EmergencyCardVm fixture;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final EmergencyCardVm card = singleFixture(
    FixturePaths.m8EmergencyCard,
    EmergencyCardVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'd03_card',
      fixture: card,
      bottom: const Key('d03-print'),
      head: const Key('d03-title'),
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
          const EmergencyStopCard(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: runbookOverrides(
              repo: FakeShellRunbookRepository(
                index: (int call) => const Stream<RunbookIndexVm>.empty(),
                runbook: (int call) => const Stream<RunbookVm>.empty(),
                card: (int call) => one(flow.fixture),
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

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(kGoldenPhoneSize.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
