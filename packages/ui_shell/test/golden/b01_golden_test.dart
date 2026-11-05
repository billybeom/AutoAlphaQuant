// test/golden/b01_golden_test.dart - B-01 handbook contents golden (1 name x light/dark = 2 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/b01_golden_test.dart

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
    required this.index,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final HandbookIndex index;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final HandbookIndex index = singleFixture(
    FixturePaths.m8HandbookIndex,
    HandbookIndex.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'b01_index',
      index: index,
      bottom: const ValueKey<String>('b01-entry-7'),
      head: const ValueKey<String>('b01-entry-0'),
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
          const HandbookContents(),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: handbookOverrides(
              clock: FixedClock(kGoldenNowUtc),
              repo: FakeShellHandbookRepository(
                index: (int call) => one(flow.index),
                page: (int call) => const Stream<HandbookPage>.empty(),
              ),
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
