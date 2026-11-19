// test/golden/m9s12_golden_test.dart -- M9 S12 annual review entry golden (3 names x light/dark = 6 PNG).
//
// --update-goldens targets this file only:
//   flutter test --update-goldens test/golden/m9s12_golden_test.dart

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/ui_settings.dart';

import '../settings_fakes.dart';
import 'golden_support.dart';

const Size _kM9s12Tall = Size(390, 400);

class _Flow {
  const _Flow({
    required this.name,
    required this.vm,
    required this.bottom,
    required this.head,
    required this.steps,
  });

  final String name;
  final AnnualReviewIndexVm vm;
  final Key bottom;
  final Key head;
  final Future<void> Function(WidgetTester tester) steps;
}

void main() {
  final AnnualReviewIndexVm open = singleFixture(
    FixturePaths.m9AnnualReviewIndexOpen,
    AnnualReviewIndexVm.fromJson,
  );
  final AnnualReviewIndexVm closed = singleFixture(
    FixturePaths.m9AnnualReviewIndexClosed,
    AnnualReviewIndexVm.fromJson,
  );
  final AnnualReviewIndexVm firstYear = singleFixture(
    FixturePaths.m9AnnualReviewIndexFirstYear,
    AnnualReviewIndexVm.fromJson,
  );

  final List<_Flow> flows = <_Flow>[
    _Flow(
      name: 'm9s12_open',
      vm: open,
      bottom: const Key('m9s12-asof'),
      head: const Key('m9s12-head'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s12_closed',
      vm: closed,
      bottom: const Key('m9s12-asof'),
      head: const Key('m9s12-head'),
      steps: (WidgetTester tester) async {},
    ),
    _Flow(
      name: 'm9s12_first_year',
      vm: firstYear,
      bottom: const Key('m9s12-asof'),
      head: const Key('m9s12-head'),
      steps: (WidgetTester tester) async {},
    ),
  ];

  for (final _Flow flow in flows) {
    for (final Brightness b in Brightness.values) {
      testWidgets('${flow.name} ${brightnessSuffix(b)}', (
        WidgetTester tester,
      ) async {
        await pumpForGolden(
          tester,
          const AnnualReviewEntry(),
          brightness: b,
          logicalSize: _kM9s12Tall,
          wrapApp: (Widget app) => ProviderScope(
            overrides: annualReviewOverrides(
              repo: FakeSettingsAnnualReviewRepository(
                annual: (int call) => one(flow.vm),
              ),
              actions: UnimplementedSettingsActions(),
              opener: RecordingLinkOpener(),
              clock: FixedClock(kGoldenNowUtc),
            ),
            child: app,
          ),
        );
        await tester.pump();
        await flow.steps(tester);
        await tester.pumpAndSettle();

        expect(
          tester.getBottomLeft(find.byKey(flow.bottom)).dy,
          lessThan(_kM9s12Tall.height),
        );
        expect(tester.getTopLeft(find.byKey(flow.head)).dy, 0.0);

        await expectGolden(flow.name, b);
      });
    }
  }
}
