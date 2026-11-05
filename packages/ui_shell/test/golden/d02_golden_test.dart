// test/golden/d02_golden_test.dart - D-02 runbook golden (2 names x light/dark = 4 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/d02_golden_test.dart

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
    required this.widget,
    required this.index,
    required this.runbook,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final Widget widget;
  final RunbookIndexVm index;
  final RunbookVm runbook;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final RunbookIndexVm index = singleFixture(
    FixturePaths.m8RunbookIndex,
    RunbookIndexVm.fromJson,
  );
  final RunbookVm hostLost = singleFixture(
    FixturePaths.m8RunbookHostLost,
    RunbookVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'd02_list',
      widget: const RunbookList(),
      index: index,
      runbook: hostLost,
      bottom: const ValueKey<String>('d02-list-row-5'),
      head: const ValueKey<String>('d02-list-row-0'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'd02_detail',
      widget: const RunbookDetail(runbookId: 'host-lost'),
      index: index,
      runbook: hostLost,
      bottom: const Key('d02-notice'),
      head: const Key('d02-title'),
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
          flow.widget,
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: runbookOverrides(
              repo: FakeShellRunbookRepository(
                index: (int call) => one(flow.index),
                runbook: (int call) => one(flow.runbook),
                card: (int call) => const Stream<EmergencyCardVm>.empty(),
              ),
              slots: null,
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
