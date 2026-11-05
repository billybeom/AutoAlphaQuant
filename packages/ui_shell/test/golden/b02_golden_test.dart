// test/golden/b02_golden_test.dart - B-02 handbook page golden (3 names x light/dark = 6 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/b02_golden_test.dart

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
    required this.page,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final HandbookPage page;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final HandbookPage sleeveB = singleFixture(
    FixturePaths.m8HandbookPageSleeveB,
    HandbookPage.fromJson,
  );
  final HandbookPage outdated = singleFixture(
    FixturePaths.m8HandbookPageOutdated,
    HandbookPage.fromJson,
  );
  final HandbookPage missing = singleFixture(
    FixturePaths.m8HandbookPageMissing,
    HandbookPage.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'b02_page',
      page: sleeveB,
      bottom: const ValueKey<String>('b02-block-4'),
      head: const Key('b02-asof'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'b02_outdated',
      page: outdated,
      bottom: const ValueKey<String>('b02-block-1'),
      head: const Key('b02-outdated'),
      steps: (WidgetTester t) async {},
    ),
    _Flow(
      name: 'b02_missing',
      page: missing,
      bottom: const Key('b02-missing'),
      head: const Key('b02-title'),
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
          HandbookPageView(anchor: flow.page.anchor),
          brightness: b,
          logicalSize: kGoldenPhoneSize,
          wrapApp: (Widget app) => ProviderScope(
            overrides: handbookOverrides(
              clock: FixedClock(kGoldenNowUtc),
              repo: FakeShellHandbookRepository(
                index: (int call) => const Stream<HandbookIndex>.empty(),
                page: (int call) => one(flow.page),
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
